// LobeHub on Railway: prepare the file bucket and JWKS_KEY, then start LobeHub the way the image does.
//
// 1. Browsers upload files straight to S3 with presigned URLs, so the bucket needs a CORS rule for the app's
//    origin. This creates the bucket if it's missing and sets that rule on every start (APP_URL can change
//    when you add a custom domain). Files stay private; LobeHub shows them through signed links.
// 2. LobeHub signs its internal service calls with the RS256 key in JWKS_KEY, and those calls fail without
//    it. A Railway template can generate random strings but not an RSA key pair, so on first start this
//    creates one and stores it in the bucket; later starts read it back. A JWKS_KEY set by hand always wins.
import { createHash, createHmac, generateKeyPairSync, randomBytes } from "node:crypto";

const log = (m) => console.log(`[railway-start] ${m}`);
const KEY = "railway/jwks.json";

function newJwks() {
  const { privateKey } = generateKeyPairSync("rsa", { modulusLength: 2048 });
  const jwk = privateKey.export({ format: "jwk" });
  return JSON.stringify({ keys: [{ ...jwk, alg: "RS256", use: "sig", kid: randomBytes(8).toString("hex") }] });
}

// Minimal S3 client (SigV4, signed headers) so the script needs nothing beyond Node.
async function s3(method, key, body = "", { query = "", extra = {} } = {}) {
  const e = process.env;
  const endpoint = new URL(e.S3_INTERNAL_ENDPOINT || e.S3_ENDPOINT);
  const pathStyle = e.S3_ENABLE_PATH_STYLE === "1";
  const host = pathStyle ? endpoint.host : `${e.S3_BUCKET}.${endpoint.host}`;
  const path = (pathStyle ? `/${e.S3_BUCKET}` : "") + (key ? "/" + key.split("/").map(encodeURIComponent).join("/") : pathStyle ? "" : "/");
  const region = e.S3_REGION || "us-east-1";
  const amzDate = new Date().toISOString().replace(/[-:]|\.\d{3}/g, "");
  const day = amzDate.slice(0, 8);
  const payloadHash = createHash("sha256").update(body).digest("hex");
  const headers = { host, "x-amz-content-sha256": payloadHash, "x-amz-date": amzDate, ...extra };
  const signed = Object.keys(headers).sort().join(";");
  const canonicalHeaders = Object.keys(headers).sort().map((k) => `${k}:${headers[k]}\n`).join("");
  const canonical = [method, path || "/", query, canonicalHeaders, signed, payloadHash].join("\n");
  const scope = `${day}/${region}/s3/aws4_request`;
  const toSign = ["AWS4-HMAC-SHA256", amzDate, scope, createHash("sha256").update(canonical).digest("hex")].join("\n");
  const h = (k, d) => createHmac("sha256", k).update(d).digest();
  const signature = createHmac("sha256", h(h(h(h("AWS4" + e.S3_SECRET_ACCESS_KEY, day), region), "s3"), "aws4_request")).update(toSign).digest("hex");
  const res = await fetch(`${endpoint.protocol}//${host}${path || "/"}${query ? "?" + query : ""}`, {
    method,
    headers: { ...headers, authorization: `AWS4-HMAC-SHA256 Credential=${e.S3_ACCESS_KEY_ID}/${scope}, SignedHeaders=${signed}, Signature=${signature}` },
    body: method === "PUT" ? body : undefined,
  });
  return { status: res.status, text: await res.text() };
}

async function loadOrCreateJwks() {
  const e = process.env;
  if (!(e.S3_ENDPOINT && e.S3_BUCKET && e.S3_ACCESS_KEY_ID && e.S3_SECRET_ACCESS_KEY)) {
    log("no S3 bucket configured: using a signing key that changes on every restart");
    return newJwks();
  }
  const got = await s3("GET", KEY);
  if (got.status === 200 && got.text.includes('"RS256"')) {
    log("using the signing key stored in the bucket");
    return got.text;
  }
  if (got.status !== 404) throw new Error(`reading ${KEY} returned HTTP ${got.status}`);
  const jwks = newJwks();
  const put = await s3("PUT", KEY, jwks);
  if (put.status !== 200) throw new Error(`storing ${KEY} returned HTTP ${put.status}`);
  log(`created a signing key and stored it in the bucket (${KEY})`);
  return jwks;
}

async function prepareBucket() {
  const e = process.env;
  if (!(e.S3_ENDPOINT && e.S3_BUCKET && e.S3_ACCESS_KEY_ID && e.S3_SECRET_ACCESS_KEY)) return;
  for (let i = 0; i < 30; i++) {
    const head = await s3("HEAD", "").catch((err) => ({ status: 0, text: err.message }));
    if (head.status === 200) break;
    if (head.status === 404) {
      const made = await s3("PUT", "");
      log(`created bucket ${e.S3_BUCKET}: HTTP ${made.status}`);
      break;
    }
    if (i === 29) throw new Error(`bucket not reachable (last HTTP ${head.status})`);
    await new Promise((r) => setTimeout(r, 2000)); // storage may still be starting
  }
  if (!e.APP_URL) return;
  const origin = new URL(e.APP_URL).origin;
  const xml = `<CORSConfiguration><CORSRule><AllowedOrigin>${origin}</AllowedOrigin><AllowedMethod>GET</AllowedMethod><AllowedMethod>PUT</AllowedMethod><AllowedMethod>HEAD</AllowedMethod><AllowedHeader>*</AllowedHeader><ExposeHeader>ETag</ExposeHeader><MaxAgeSeconds>3600</MaxAgeSeconds></CORSRule></CORSConfiguration>`;
  const cors = await s3("PUT", "", xml, { query: "cors=", extra: { "content-md5": createHash("md5").update(xml).digest("base64"), "content-type": "application/xml" } });
  log(`browser uploads allowed from ${origin}: HTTP ${cors.status}`);
}

try {
  await prepareBucket();
} catch (err) {
  log(`could not prepare the bucket (${err.message})`);
}
if (!process.env.JWKS_KEY) {
  try {
    process.env.JWKS_KEY = await loadOrCreateJwks();
  } catch (err) {
    log(`could not prepare JWKS_KEY (${err.message}); starting without it`);
  }
}
await import("/app/startServer.js");

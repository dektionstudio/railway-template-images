// Starts NiubiGEO's workbench and scheduling worker, and puts the workbench behind HTTP basic auth on
// Railway's port. /health stays open for Railway's healthcheck. If either process exits, the container
// exits too, so Railway's restart policy brings everything back together.
import http from "node:http";
import { spawn } from "node:child_process";
import { timingSafeEqual } from "node:crypto";

const PUBLIC_PORT = Number(process.env.PORT || 8080);
const APP_PORT = 8787;
const user = process.env.NIUBIGEO_USER || "admin";
const pass = process.env.NIUBIGEO_PASSWORD || "";
if (!pass) {
  console.error("NIUBIGEO_PASSWORD is required");
  process.exit(1);
}
const expected = Buffer.from("Basic " + Buffer.from(`${user}:${pass}`).toString("base64"));
const authorized = (header) => {
  const got = Buffer.from(header || "");
  return got.length === expected.length && timingSafeEqual(got, expected);
};

const env = { ...process.env, PORT: String(APP_PORT), PRODUCT_DATA_DIR: "/app/data/product-v2", MONITORING_DATA_DIR: "/app/data" };
const children = [];
let stopping = false;
function run(name, args) {
  const child = spawn("node", args, { cwd: "/app", env, stdio: "inherit" });
  child.on("exit", (code) => {
    if (stopping) return;
    console.error(`${name} exited with code ${code}; stopping so Railway restarts the service`);
    process.exit(1);
  });
  children.push(child);
}
run("workbench", ["dist/src/product/product-server.js"]);
if ((process.env.NIUBIGEO_SCHEDULER || "true") !== "false") {
  run("scheduler", ["dist/src/product/scheduling/schedule-worker.js", process.env.NIUBIGEO_SCHEDULER_INTERVAL || "60"]);
}

http.createServer((req, res) => {
  const health = req.method === "GET" && req.url === "/health";
  if (!health && !authorized(req.headers.authorization)) {
    res.writeHead(401, { "WWW-Authenticate": 'Basic realm="NiubiGEO", charset="UTF-8"', "Content-Type": "text/plain" });
    res.end("Login required");
    return;
  }
  const headers = { ...req.headers };
  delete headers.authorization;
  const upstream = http.request({ host: "127.0.0.1", port: APP_PORT, method: req.method, path: req.url, headers }, (r) => {
    res.writeHead(r.statusCode || 502, r.headers);
    r.pipe(res);
  });
  upstream.on("error", (e) => {
    if (!res.headersSent) res.writeHead(502, { "Content-Type": "text/plain" });
    res.end("Workbench not ready yet: " + e.message);
  });
  req.pipe(upstream);
}).listen(PUBLIC_PORT, "0.0.0.0", () => console.log(`NiubiGEO workbench behind a password on port ${PUBLIC_PORT}`));

for (const signal of ["SIGTERM", "SIGINT"]) {
  process.on(signal, () => {
    stopping = true;
    for (const c of children) c.kill(signal);
    setTimeout(() => process.exit(0), 3000);
  });
}

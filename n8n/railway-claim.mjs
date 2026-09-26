// Set up the n8n owner from N8N_OWNER_EMAIL / N8N_OWNER_PASSWORD once n8n is ready, then confirm it by signing
// in. /healthz answers while migrations are still running, and an owner set up that early didn't stick in
// testing, so this waits for /healthz/readiness and retries until the sign-in works.
const log = (m) => console.log(`[railway-claim] ${m}`);
const base = `http://127.0.0.1:${process.env.N8N_PORT || 5678}`;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const email = process.env.N8N_OWNER_EMAIL;
const password = process.env.N8N_OWNER_PASSWORD;

const ready = async () => fetch(`${base}/healthz/readiness`).then((r) => r.ok).catch(() => false);
const signIn = async () => fetch(`${base}/rest/login`, {
  method: "POST",
  headers: { "Content-Type": "application/json", "browser-id": "railway-claim" },
  body: JSON.stringify({ emailOrLdapLoginId: email, password }),
}).then((r) => r.status).catch(() => 0);
const setup = async () => {
  const r = await fetch(`${base}/rest/owner/setup`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password, firstName: process.env.N8N_OWNER_FIRST_NAME || "Admin", lastName: process.env.N8N_OWNER_LAST_NAME || "User" }),
  });
  return { status: r.status, text: await r.text() };
};

for (let i = 0; i < 150 && !(await ready()); i++) await sleep(2000);
for (let attempt = 1; attempt <= 30; attempt++) {
  if ((await signIn()) === 200) {
    log(attempt === 1 ? "the owner account already exists" : `owner account set up for ${email}`);
    process.exit(0);
  }
  const res = await setup().catch((e) => ({ status: 0, text: String(e) }));
  if (/already setup/i.test(res.text)) {
    log("another account already owns this instance; N8N_OWNER_EMAIL / N8N_OWNER_PASSWORD don't sign in");
    process.exit(0);
  }
  await sleep(res.status === 200 ? 3000 : 10000);
}
log("could not confirm the owner account; open n8n and check who owns it");

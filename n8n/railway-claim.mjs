// Set up the n8n owner from N8N_OWNER_EMAIL / N8N_OWNER_PASSWORD as soon as n8n answers. Once an owner exists,
// n8n refuses the request ("Instance owner already setup") and nothing changes.
const log = (m) => console.log(`[railway-claim] ${m}`);
const base = `http://127.0.0.1:${process.env.N8N_PORT || 5678}`;

let up = false;
for (let i = 0; i < 150 && !up; i++) {
  up = await fetch(`${base}/healthz`).then((r) => r.ok).catch(() => false);
  if (!up) await new Promise((r) => setTimeout(r, 2000));
}
if (!up) {
  log("n8n didn't answer within 5 minutes; set up the owner in the browser instead");
  process.exit(0);
}

const res = await fetch(`${base}/rest/owner/setup`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    email: process.env.N8N_OWNER_EMAIL,
    firstName: process.env.N8N_OWNER_FIRST_NAME || "Admin",
    lastName: process.env.N8N_OWNER_LAST_NAME || "User",
    password: process.env.N8N_OWNER_PASSWORD,
  }),
});
const text = await res.text();
if (res.ok) log(`owner account set up for ${process.env.N8N_OWNER_EMAIL}`);
else if (/already setup/i.test(text)) log("the instance already has an owner");
else log(`owner setup returned HTTP ${res.status}: ${text.slice(0, 200)}`);

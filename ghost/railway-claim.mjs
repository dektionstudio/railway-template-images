// Create the Ghost owner from GHOST_ADMIN_EMAIL / GHOST_ADMIN_PASSWORD once Ghost answers, if the site isn't
// set up yet. Ghost only accepts this once, so later starts change nothing.
const log = (m) => console.log(`[railway-claim] ${m}`);
const base = `http://127.0.0.1:${process.env.server__port || 2368}/ghost/api/admin/authentication/setup/`;
const headers = { "Content-Type": "application/json", Origin: process.env.url || "http://localhost" };
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

let status;
for (let i = 0; i < 180 && status === undefined; i++) {
  status = await fetch(base, { headers }).then((r) => (r.ok ? r.json() : undefined)).catch(() => undefined);
  if (status === undefined) await sleep(2000);
}
if (status === undefined) {
  log("Ghost didn't answer within 6 minutes; set up the owner at /ghost instead");
  process.exit(0);
}
if (status.setup?.[0]?.status) {
  log("the site already has an owner");
  process.exit(0);
}
const res = await fetch(base, {
  method: "POST",
  headers,
  body: JSON.stringify({ setup: [{
    name: process.env.GHOST_ADMIN_NAME || "Admin",
    email: process.env.GHOST_ADMIN_EMAIL,
    password: process.env.GHOST_ADMIN_PASSWORD,
    blogTitle: process.env.GHOST_SITE_TITLE || "My Ghost site",
  }] }),
});
const text = await res.text();
if (res.ok) log(`owner account created for ${process.env.GHOST_ADMIN_EMAIL}`);
else log(`setup returned HTTP ${res.status}: ${text.slice(0, 200)}`);

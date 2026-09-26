// Sign up the platform owner from ADMIN_EMAIL / ADMIN_PASSWORD as soon as the API answers. On later starts the
// platform already exists and the sign-up is refused (invitation only), so nothing changes.
const log = (m) => console.log(`[railway-claim] ${m}`);
const base = `http://127.0.0.1:${process.env.AP_PORT || 80}/api/v1`;

let up = false;
for (let i = 0; i < 150 && !up; i++) {
  up = await fetch(`${base}/flags`).then((r) => r.ok).catch(() => false);
  if (!up) await new Promise((r) => setTimeout(r, 2000));
}
if (!up) {
  log("the API didn't answer within 5 minutes; sign up in the browser instead");
  process.exit(0);
}

const res = await fetch(`${base}/authentication/sign-up`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    email: process.env.ADMIN_EMAIL,
    password: process.env.ADMIN_PASSWORD,
    firstName: process.env.ADMIN_FIRST_NAME || "Admin",
    lastName: process.env.ADMIN_LAST_NAME || "User",
    trackEvents: false,
    newsLetter: false,
  }),
});
const text = await res.text();
if (res.ok) log(`owner account created for ${process.env.ADMIN_EMAIL}`);
else if (res.status === 409 || /exist|invit|already/i.test(text)) log("the platform already has an owner");
else log(`sign-up returned HTTP ${res.status}: ${text.slice(0, 200)}`);

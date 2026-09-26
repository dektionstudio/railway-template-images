// Starts Twenty the way the image does (its entrypoint has already run the migrations) and creates the admin
// account and workspace in the background.
import { spawn } from "node:child_process";

const twenty = spawn("node", ["dist/main"], { stdio: "inherit" });
if (process.env.TWENTY_ADMIN_EMAIL && process.env.TWENTY_ADMIN_PASSWORD) {
  spawn(process.execPath, ["/app/railway/railway-claim.mjs"], { stdio: "inherit" });
}
for (const sig of ["SIGTERM", "SIGINT"]) process.on(sig, () => twenty.kill(sig));
twenty.on("exit", (code, signal) => process.exit(code ?? (signal ? 1 : 0)));

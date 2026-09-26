// Runs as root only to hand the Railway volume (n8n's folder: community nodes, binary data) to the node user,
// then starts n8n the way the image does, as that user, and sets up the owner account in the background.
// The image has no package manager, so privileges are dropped with spawn's uid/gid options.
import { spawn } from "node:child_process";
import { chownSync, lstatSync, mkdirSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const [, , uid, gid] = readFileSync("/etc/passwd", "utf8").split("\n").find((l) => l.startsWith("node:")).split(":");
const DIR = "/home/node/.n8n";
mkdirSync(DIR, { recursive: true });
const chownTree = (p) => {
  chownSync(p, +uid, +gid);
  if (lstatSync(p).isDirectory()) for (const f of readdirSync(p)) chownTree(join(p, f));
};
chownTree(DIR);

const opts = { uid: +uid, gid: +gid, env: { ...process.env, HOME: "/home/node" }, stdio: "inherit" };
const n8n = spawn("/docker-entrypoint.sh", [], opts);
if (process.env.N8N_OWNER_EMAIL && process.env.N8N_OWNER_PASSWORD) {
  spawn(process.execPath, ["/usr/local/bin/railway-claim.mjs"], opts);
}
for (const sig of ["SIGTERM", "SIGINT"]) process.on(sig, () => n8n.kill(sig));
n8n.on("exit", (code, signal) => process.exit(code ?? (signal ? 1 : 0)));

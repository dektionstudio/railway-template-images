// First-admin invite for an internet-facing Paperclip on Railway.
//
// This is what `paperclipai auth bootstrap-ceo` does (cli/src/commands/auth-bootstrap-ceo.ts upstream),
// using the same @paperclipai/db schema objects, so it follows upstream's table definitions. It runs on
// every start: once an instance admin exists it does nothing; otherwise it revokes the previous unused
// invite and prints a new one, so the newest deploy log always has a working link.
import { createHash, randomBytes } from "node:crypto";
import { and, eq, gt, isNull } from "drizzle-orm";
import { createDb, instanceUserRoles, invites } from "@paperclipai/db";

const log = (msg) => console.log(`[railway-bootstrap] ${msg}`);
const port = process.env.PORT || "3100";
const baseUrl = (process.env.PAPERCLIP_PUBLIC_URL || `http://localhost:${port}`).replace(/\/+$/, "");

if (process.env.PAPERCLIP_DEPLOYMENT_MODE !== "authenticated") process.exit(0);
if (!process.env.DATABASE_URL) {
  log("DATABASE_URL is not set, skipping. Run `paperclipai auth bootstrap-ceo` yourself.");
  process.exit(0);
}

// The server applies migrations before it answers, so the tables exist once /api/health is up.
let healthy = false;
for (let i = 0; i < 180 && !healthy; i++) {
  healthy = await fetch(`http://127.0.0.1:${port}/api/health`).then((r) => r.ok).catch(() => false);
  if (!healthy) await new Promise((r) => setTimeout(r, 2000));
}
if (!healthy) log("server not healthy after 6 minutes, trying anyway");

const db = createDb(process.env.DATABASE_URL);
try {
  const admins = await db.select().from(instanceUserRoles).where(eq(instanceUserRoles.role, "instance_admin"));
  if (admins.length > 0) {
    log("instance already has an admin, nothing to do");
  } else {
    const now = new Date();
    await db
      .update(invites)
      .set({ revokedAt: now, updatedAt: now })
      .where(and(eq(invites.inviteType, "bootstrap_ceo"), isNull(invites.revokedAt), isNull(invites.acceptedAt), gt(invites.expiresAt, now)));
    const token = `pcp_bootstrap_${randomBytes(24).toString("hex")}`;
    const expiresAt = new Date(Date.now() + 72 * 60 * 60 * 1000);
    await db.insert(invites).values({
      inviteType: "bootstrap_ceo",
      tokenHash: createHash("sha256").update(token).digest("hex"),
      allowedJoinTypes: "human",
      expiresAt,
      invitedByUserId: "system",
    });
    log("No admin yet. Open this link to create the first admin account (it works once, until " + expiresAt.toISOString() + "):");
    log(`${baseUrl}/invite/${token}`);
    log("Redeploying or restarting before you use it prints a new link and cancels this one.");
  }
} catch (err) {
  log(`could not create the invite: ${err instanceof Error ? err.message : String(err)}`);
} finally {
  await db.$client?.end?.({ timeout: 5 }).catch(() => undefined);
}

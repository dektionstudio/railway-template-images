import { loadEnv, defineConfig } from "@medusajs/framework/utils";

loadEnv(process.env.NODE_ENV || "development", process.cwd());

// Railway's production setup for dtc-starter's backend: Redis-backed caching, events, workflows and locking when
// REDIS_URL is set, and uploaded files on the service's volume (served by Medusa at /static).
const redisUrl = process.env.REDIS_URL;
const backendUrl = process.env.MEDUSA_BACKEND_URL || "http://localhost:9000";

const redisModules = redisUrl
  ? [
      {
        resolve: "@medusajs/medusa/caching",
        options: { providers: [{ resolve: "@medusajs/medusa/caching-redis", id: "caching-redis", is_default: true, options: { redisUrl } }] },
      },
      { resolve: "@medusajs/medusa/event-bus-redis", options: { redisUrl } },
      { resolve: "@medusajs/medusa/workflow-engine-redis", options: { redis: { redisUrl } } },
      {
        resolve: "@medusajs/medusa/locking",
        options: { providers: [{ resolve: "@medusajs/medusa/locking-redis", id: "locking-redis", is_default: true, options: { redisUrl } }] },
      },
    ]
  : [];

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    redisUrl,
    workerMode: (process.env.MEDUSA_WORKER_MODE as "shared" | "worker" | "server") || "shared",
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET,
      cookieSecret: process.env.COOKIE_SECRET,
    },
  },
  admin: { disable: process.env.DISABLE_MEDUSA_ADMIN === "true" },
  modules: [
    ...redisModules,
    {
      resolve: "@medusajs/medusa/file",
      options: {
        providers: [{ resolve: "@medusajs/medusa/file-local", id: "local", options: { upload_dir: "static", backend_url: `${backendUrl}/static` } }],
      },
    },
  ],
});

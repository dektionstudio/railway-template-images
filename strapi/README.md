# Strapi for Railway

A clean Strapi 5.55.1 project (JavaScript, Postgres, no example data) that the Railway Strapi template builds with the `Dockerfile` here.

Changes from what `create-strapi` generates:

- `src/index.js` creates the first admin from `STRAPI_ADMIN_EMAIL` and `STRAPI_ADMIN_PASSWORD` at boot, before the server listens, and only while no admin exists.
- `config/server.js` trusts Railway's proxy (`proxy.koa`) and reads the public URL from `PUBLIC_URL`.
- The Strapi Cloud plugin is removed and telemetry is off.

## Adding content types

Strapi runs in production mode on Railway, where the Content-Type Builder is read-only: content types are code. To add them:

1. Copy this folder into your own Git repository.
2. Run it locally: `npm install`, then `npm run develop` (it uses SQLite unless you set `DATABASE_CLIENT` and `DATABASE_URL`).
3. Build your content types in the admin panel; Strapi writes them to `src/api` and `src/components`.
4. Commit, then in Railway open the Strapi service's Settings, change its source to your repository and clear Root Directory (or set it to your folder). Every push redeploys.

Your content and uploads stay in Postgres and on the volume.

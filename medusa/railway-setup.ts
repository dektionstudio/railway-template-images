import { ExecArgs } from "@medusajs/framework/types";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";

// Runs before every start on Railway (see railway-start.sh), after the migrations, which seed the starter store
// on an empty database (dtc-starter's src/migration-scripts/initial-data-seed.ts).
// Sets the publishable API key's token to MEDUSA_PUBLISHABLE_KEY, a value generated at deploy, so the storefront
// can be built with it before the backend has ever run. Publishable keys aren't secret: they only scope storefront
// requests to a sales channel. The module API can't change a token, so this updates the row directly.
export default async function railwaySetup({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const query = container.resolve(ContainerRegistrationKeys.QUERY);
  const pg = container.resolve(ContainerRegistrationKeys.PG_CONNECTION);

  const wanted = process.env.MEDUSA_PUBLISHABLE_KEY;
  if (!wanted) return;
  const { data: keys } = await query.graph({ entity: "api_key", fields: ["id", "token"], filters: { type: "publishable" } });
  const key = keys[0];
  if (!key) {
    logger.warn("[railway] no publishable API key found; create one in the admin under Settings > Publishable API Keys");
    return;
  }
  if (key.token !== wanted) {
    await pg("api_key").where({ id: key.id }).update({ token: wanted, redacted: `${wanted.slice(0, 6)}***${wanted.slice(-3)}` });
    logger.info("[railway] publishable API key set to MEDUSA_PUBLISHABLE_KEY");
  }
}

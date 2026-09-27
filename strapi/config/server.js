module.exports = ({ env }) => ({
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1337),
  // Public address, used for links in emails and the admin panel. Railway sets it from the service domain.
  url: env('PUBLIC_URL', ''),
  // Railway terminates HTTPS in front of the app: trust its X-Forwarded-* headers so Strapi knows requests
  // are secure (secure admin cookies, correct client IPs).
  proxy: { koa: env.bool('IS_PROXIED', true) },
  app: {
    keys: env.array('APP_KEYS'),
  },
  webhooks: {
    populateRelations: env.bool('WEBHOOKS_POPULATE_RELATIONS', false),
  },
});

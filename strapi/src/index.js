'use strict';

module.exports = {
  /**
   * An asynchronous register function that runs before
   * your application is initialized.
   *
   * This gives you an opportunity to extend code.
   */
  register(/*{ strapi }*/) {},

  /**
   * An asynchronous bootstrap function that runs before
   * your application gets started.
   *
   * This gives you an opportunity to set up your data model,
   * run jobs, or perform some special logic.
   */
  async bootstrap({ strapi }) {
    await createFirstAdmin(strapi);
  },
};

// Create the first admin from STRAPI_ADMIN_EMAIL and STRAPI_ADMIN_PASSWORD before the server listens.
// Without this, whoever opens /admin first on a new deploy registers the admin account.
// Does nothing once any admin exists, so changing the variables later won't touch your accounts.
async function createFirstAdmin(strapi) {
  const email = (process.env.STRAPI_ADMIN_EMAIL || '').trim().toLowerCase();
  const password = process.env.STRAPI_ADMIN_PASSWORD || '';
  if (!email || !password) return;
  const users = strapi.service('admin::user');
  if (await users.exists()) return;
  const superAdmin = await strapi.service('admin::role').getSuperAdmin();
  await users.create({
    email,
    firstname: process.env.STRAPI_ADMIN_FIRSTNAME || 'Admin',
    lastname: process.env.STRAPI_ADMIN_LASTNAME || '',
    password,
    registrationToken: null,
    isActive: true,
    roles: superAdmin ? [superAdmin.id] : [],
  });
  strapi.log.info(`[railway] admin account created for ${email}`);
}

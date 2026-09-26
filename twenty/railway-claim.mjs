// Create Twenty's admin account and workspace from TWENTY_ADMIN_EMAIL / TWENTY_ADMIN_PASSWORD. On a fresh
// instance the first sign-up becomes the server admin and creates the only workspace; once a workspace exists,
// signing up needs an invitation. Does nothing when the workspace is already there.
const log = (m) => console.log(`[railway-claim] ${m}`);
const base = `http://127.0.0.1:${process.env.NODE_PORT || 3000}`;
const origin = process.env.SERVER_URL || base;
const email = process.env.TWENTY_ADMIN_EMAIL;
const password = process.env.TWENTY_ADMIN_PASSWORD;
const name = process.env.TWENTY_WORKSPACE_NAME || "Twenty";
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function gql(query, variables = {}, token) {
  const headers = { "Content-Type": "application/json", Origin: origin };
  if (token) headers.Authorization = `Bearer ${token}`;
  const r = await fetch(`${base}/metadata`, { method: "POST", headers, body: JSON.stringify({ query, variables }) });
  const j = await r.json().catch(() => ({ errors: [{ message: `HTTP ${r.status}` }] }));
  if (j.errors?.length) throw new Error(j.errors[0].message);
  return j.data;
}

const WORKSPACES = "availableWorkspaces { availableWorkspacesForSignIn { id } }";
const TOKENS = "tokens { accessOrWorkspaceAgnosticToken { token } }";

async function claim() {
  let session;
  try {
    session = (await gql(`mutation($email: String!, $password: String!) { signUp(email: $email, password: $password) { ${WORKSPACES} ${TOKENS} } }`, { email, password })).signUp;
  } catch (e) {
    if (!/already exists/i.test(e.message)) return log(`sign-up refused (${e.message}); this Twenty already has a workspace`);
    // The account exists from an earlier start that stopped before the workspace was created.
    session = (await gql(`mutation($email: String!, $password: String!) { signIn(email: $email, password: $password) { ${WORKSPACES} ${TOKENS} } }`, { email, password })).signIn;
  }
  if (session.availableWorkspaces.availableWorkspacesForSignIn.length) return log(`${email} already has a workspace`);

  const created = (await gql(`mutation($input: SignUpInNewWorkspaceInput) { signUpInNewWorkspace(input: $input) { loginToken { token } workspace { id } } }`,
    { input: { displayName: name } }, session.tokens.accessOrWorkspaceAgnosticToken.token)).signUpInNewWorkspace;
  const auth = (await gql(`mutation($loginToken: String!, $origin: String!) { getAuthTokensFromLoginToken(loginToken: $loginToken, origin: $origin) { ${TOKENS} } }`,
    { loginToken: created.loginToken.token, origin })).getAuthTokensFromLoginToken;
  await gql("mutation { activateWorkspace(data: {}) { id } }", {}, auth.tokens.accessOrWorkspaceAgnosticToken.token);
  log(`admin account and workspace "${name}" created for ${email}`);
}

for (let i = 0; ; i++) {
  const ok = await fetch(`${base}/healthz`).then((r) => r.ok, () => false);
  if (ok) break;
  if (i === 200) { log("Twenty didn't answer; sign up in the browser instead"); process.exit(0); }
  await sleep(3000);
}
await claim().catch((e) => log(`failed: ${e.message}`));

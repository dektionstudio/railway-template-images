#!/bin/sh
# Create Twenty's admin account and workspace from TWENTY_ADMIN_EMAIL / TWENTY_ADMIN_PASSWORD. On a fresh
# instance the first sign-up becomes the server admin and creates the only workspace; once a workspace exists,
# signing up needs an invitation. Does nothing when the workspace is already there.
log() { echo "[railway-claim] $*"; }
base="http://127.0.0.1:${NODE_PORT:-3000}"
origin="${SERVER_URL:-$base}"
name="${TWENTY_WORKSPACE_NAME:-Twenty}"

# gql QUERY VARIABLES [TOKEN]: POST to Twenty's metadata API, print the JSON response
gql() {
  body=$(jq -nc --arg q "$1" --argjson v "$2" '{query: $q, variables: $v}')
  if [ -n "$3" ]; then
    curl -s -X POST "$base/metadata" -H "Content-Type: application/json" -H "Origin: $origin" -H "Authorization: Bearer $3" -d "$body"
  else
    curl -s -X POST "$base/metadata" -H "Content-Type: application/json" -H "Origin: $origin" -d "$body"
  fi
}
error() { echo "$1" | jq -r '.errors[0].message // empty' 2>/dev/null; }

i=0
until curl -fs "$base/healthz" >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -gt 200 ]; then log "Twenty didn't answer; sign up in the browser instead"; exit 0; fi
  sleep 3
done

creds=$(jq -nc --arg e "$TWENTY_ADMIN_EMAIL" --arg p "$TWENTY_ADMIN_PASSWORD" '{email: $e, password: $p}')
fields='availableWorkspaces { availableWorkspacesForSignIn { id } } tokens { accessOrWorkspaceAgnosticToken { token } }'
res=$(gql "mutation(\$email: String!, \$password: String!) { signUp(email: \$email, password: \$password) { $fields } }" "$creds")
key=signUp
case "$(error "$res")" in
  "") ;;
  *"already exists"*)
    # The account exists from an earlier start that stopped before the workspace was created.
    res=$(gql "mutation(\$email: String!, \$password: String!) { signIn(email: \$email, password: \$password) { $fields } }" "$creds")
    key=signIn ;;
  *) log "sign-up refused ($(error "$res")); this Twenty already has a workspace"; exit 0 ;;
esac
[ -n "$(error "$res")" ] && { log "failed: $(error "$res")"; exit 0; }
if [ "$(echo "$res" | jq ".data.$key.availableWorkspaces.availableWorkspacesForSignIn | length")" != "0" ]; then
  log "$TWENTY_ADMIN_EMAIL already has a workspace"; exit 0
fi
token=$(echo "$res" | jq -r ".data.$key.tokens.accessOrWorkspaceAgnosticToken.token")

res=$(gql 'mutation($input: SignUpInNewWorkspaceInput) { signUpInNewWorkspace(input: $input) { loginToken { token } } }' \
  "$(jq -nc --arg n "$name" '{input: {displayName: $n}}')" "$token")
[ -n "$(error "$res")" ] && { log "workspace creation failed: $(error "$res")"; exit 0; }
res=$(gql 'mutation($t: String!, $o: String!) { getAuthTokensFromLoginToken(loginToken: $t, origin: $o) { tokens { accessOrWorkspaceAgnosticToken { token } } } }' \
  "$(jq -nc --arg t "$(echo "$res" | jq -r '.data.signUpInNewWorkspace.loginToken.token')" --arg o "$origin" '{t: $t, o: $o}')")
[ -n "$(error "$res")" ] && { log "sign-in to the new workspace failed: $(error "$res")"; exit 0; }
res=$(gql 'mutation { activateWorkspace(data: {}) { id } }' '{}' "$(echo "$res" | jq -r '.data.getAuthTokensFromLoginToken.tokens.accessOrWorkspaceAgnosticToken.token')")
[ -n "$(error "$res")" ] && { log "workspace activation failed: $(error "$res")"; exit 0; }
log "admin account and workspace \"$name\" created for $TWENTY_ADMIN_EMAIL"

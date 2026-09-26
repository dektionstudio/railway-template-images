# n8n (https://github.com/n8n-io/n8n, Sustainable Use License) for Railway: the official image plus one start
# step. A fresh n8n asks the first visitor to set up the owner account; on a public URL anyone can do that.
# railway-claim.mjs sets the owner up from N8N_OWNER_EMAIL / N8N_OWNER_PASSWORD as soon as n8n answers.
ARG N8N_VERSION=2.40.7
FROM n8nio/n8n:${N8N_VERSION}
USER root
COPY railway-start.mjs railway-claim.mjs /usr/local/bin/
ENTRYPOINT ["tini", "--", "node", "/usr/local/bin/railway-start.mjs"]

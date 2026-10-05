# Medusa's Next.js storefront (dtc-starter's apps/storefront) for Railway, same pinned commit as the backend.
# Next.js inlines the NEXT_PUBLIC_ values at build time; Railway passes them in as build args.
# The three catalog pages pre-render at build by default, which needs the backend running. With their
# generateStaticParams disabled they render on request instead, so the storefront builds before the backend
# has ever started, and products added later show up without a rebuild.
FROM node:24-bookworm-slim
ARG DTC_COMMIT=15ef93da7d155ad990d8cc6db0296446fecbdfe6
ARG NEXT_PUBLIC_MEDUSA_BACKEND_URL
ARG NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_BASE_URL
ARG NEXT_PUBLIC_DEFAULT_REGION=dk
ENV NEXT_PUBLIC_MEDUSA_BACKEND_URL=$NEXT_PUBLIC_MEDUSA_BACKEND_URL \
    NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=$NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY \
    NEXT_PUBLIC_BASE_URL=$NEXT_PUBLIC_BASE_URL \
    NEXT_PUBLIC_DEFAULT_REGION=$NEXT_PUBLIC_DEFAULT_REGION \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    NEXT_TELEMETRY_DISABLED=1
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git init -q && git remote add origin https://github.com/medusajs/dtc-starter.git \
 && git fetch -q --depth 1 origin "$DTC_COMMIT" && git checkout -q FETCH_HEAD && rm -rf .git
RUN for f in "products/[handle]" "collections/[handle]" "categories/[...category]"; do \
      sed -i 's/^export async function generateStaticParams(/async function generateStaticParamsUnused(/' "apps/storefront/src/app/[countryCode]/(main)/$f/page.tsx"; \
      grep -q "generateStaticParamsUnused" "apps/storefront/src/app/[countryCode]/(main)/$f/page.tsx" || { echo "patch failed: $f"; exit 1; }; \
    done
RUN corepack enable && pnpm install --frozen-lockfile --filter "@dtc/storefront..."
RUN cd apps/storefront && pnpm exec next build
ENV NODE_ENV=production
WORKDIR /app/apps/storefront
EXPOSE 8000
CMD ["sh", "-c", "exec node_modules/.bin/next start -p ${PORT:-8000}"]

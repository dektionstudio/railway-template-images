# Strapi 5 for Railway: builds the admin panel at image build time and runs in production mode.
FROM node:24-bookworm-slim

WORKDIR /app
ENV NODE_ENV=production \
    STRAPI_TELEMETRY_DISABLED=true

COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund && npm cache clean --force

COPY . .
RUN npm run build

EXPOSE 1337
CMD ["node_modules/.bin/strapi", "start"]

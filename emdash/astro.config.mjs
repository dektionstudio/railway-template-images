// EmDash's blog starter config, with the database and uploads in /data (the Railway volume).
import node from "@astrojs/node";
import react from "@astrojs/react";
import { defineConfig, fontProviders } from "astro/config";
import emdash, { local } from "emdash/astro";
import { sqlite } from "emdash/db";

export default defineConfig({
	output: "server",
	adapter: node({ mode: "standalone" }),
	site: process.env.EMDASH_SITE_URL || undefined,
	image: { layout: "constrained", responsiveStyles: true },
	integrations: [
		react(),
		emdash({
			database: sqlite({ url: "file:/data/emdash.db" }),
			storage: local({ directory: "/data/uploads", baseUrl: "/_emdash/api/media/file" }),
		}),
	],
	fonts: [
		{ provider: fontProviders.google(), name: "Inter", cssVariable: "--font-body", weights: [400, 500, 600, 700], fallbacks: ["sans-serif"] },
		{ provider: fontProviders.google(), name: "JetBrains Mono", cssVariable: "--font-mono", weights: [400, 500], fallbacks: ["monospace"] },
	],
	devToolbar: { enabled: false },
});

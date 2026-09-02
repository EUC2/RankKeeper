import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { resolve } from "node:path";

export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      // The admin console is deliberately a separate page, not a React route.
      // Vite bundles its dependencies so /admin does not rely on a CDN at runtime.
      input: {
        marketing: resolve(__dirname, "index.html"),
        app: resolve(__dirname, "app.html"),
        tournament360App: resolve(__dirname, "tournament360-app.html"),
        admin: resolve(__dirname, "admin.html"),
      },
    },
  },
});

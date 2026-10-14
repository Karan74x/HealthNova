import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";

// The dashboard calls the relative path /api. Vite forwards those requests to
// the backend (VITE_API_TARGET), both for `npm run dev` and `npm run preview`,
// so the browser only ever talks to one origin.
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  const apiTarget = env.VITE_API_TARGET || "http://localhost:5000";

  return {
    plugins: [react()],
    server: {
      port: 5173,
      proxy: {
        "/api": {
          target: apiTarget,
          changeOrigin: true,
        },
      },
    },
  };
});

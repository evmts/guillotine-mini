import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      test: "node:test",
    },
  },
  server: {
    deps: {
      inline: ["@effect/vitest", "effect"],
    },
  },
  test: {
    environment: "node",
    setupFiles: ["./vitest.setup.ts"],
  },
});

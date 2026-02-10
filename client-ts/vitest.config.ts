import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      test: "node:test",
    },
  },
  test: {
    environment: "node",
    setupFiles: ["./vitest.setup.ts"],
    deps: {
      inline: ["@effect/vitest", "effect"],
    },
  },
});

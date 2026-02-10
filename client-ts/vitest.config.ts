import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      test: "node:test",
    },
  },
  test: {
    environment: "node",
    deps: {
      inline: ["@effect/vitest", "effect"],
    },
  },
});

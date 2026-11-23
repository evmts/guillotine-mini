import { Smithers as S } from "@smthrs/targets"

export const Workspace = S.Workspace("guillotine-mini", {
  repository: "git+https://github.com/evmts/guillotine-mini.git",
  cache: S.Cache({
    directory: ".flows",
    hostDirectories: [
      ".zig-cache",
      "zig-out",
      "client-ts/node_modules",
      "docs/node_modules",
    ],
  }),
  host: S.Host({ bins: ["zig", "bun", "node"] }),
  sandboxes: S.Sandboxes({
    default: S.Sandbox.None(),
  }),
  discovery: {
    prune: [
      ".zig-cache",
      ".zig-cache-global",
      ".zig-cache-local",
      "zig-out",
      ".flows",
      ".bench-results",
      "client-ts/node_modules",
      "docs/node_modules",
      "ethereum-tests",
      "execution-specs",
      "lib",
      "target",
      "worktrees",
    ],
  },
})

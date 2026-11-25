import { Smithers as S } from "@smthrs/targets"

const runtime = S.Runtime.Bun({ version: "1.4.2" })
const packageManager = S.PackageManager.BunPackages({ runtime })
const nodeModules = S.Npm.NodeModules({ packageJson: S.file("//client-ts/package.json") })

export const Workspace = S.Workspace("guillotine-mini", {
  repository: "evmts/guillotine-mini",
  runtime,
  packageManager,
  nodeModules,
  cache: S.Cache({
    directory: ".smithers/cache",
    hostDirectories: [
      ".zig-cache",
      "zig-out",
      "client-ts/node_modules",
      "docs/node_modules",
    ],
    // Local-first; syncs through Cloudflare when the tokens are set locally or in CI.
    remote: S.RemoteCache.make({
      endpoint: "https://build.smithers.sh",
      read: S.Secret("SMITHERS_CACHE_READ_TOKEN"),
      write: S.Secret("SMITHERS_CACHE_WRITE_TOKEN"),
    }),
  }),
  host: S.Host({ bins: ["zig", "bun", "node", "sh", "wasm-opt"] }),
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
      ".smithers/cache",
      ".smithers/reports",
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

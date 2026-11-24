import { Smithers as S } from "@smthrs/targets"
import { Package as clientTsPkg } from "../PACKAGE.ts"
const config_srcs = clientTsPkg.config_srcs
import { Package as dbSrcsPkg } from "../db/PACKAGE.ts"
const dbSrcs = dbSrcsPkg.srcs

const srcs = S.Filegroup({
  srcs: [...S.glob(["**/*.ts"]), config_srcs, dbSrcs],
})

const bench = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: [
    "scripts/run-client-ts-bench.ts",
    "client-ts/trie",
    "client-ts/trie/Trie.bench.ts",
    "client-ts/trie/NodeLoader.bench.ts",
    "client-ts/trie/NodeStorage.bench.ts",
  ],
  env: { BENCH_JSON_OUT: "client-ts/trie/.bench-result.json" },
  data: [srcs, S.file("//scripts/run-client-ts-bench.ts")],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  shell: "cd client-ts && bun x vitest run trie",
  tools: [S.Host.bin("bun")],
  data: [srcs],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})

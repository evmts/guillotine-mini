import { Smithers as S } from "@smthrs/targets"
import { Package as srcPkg } from "./src/PACKAGE.ts"
import { Package as clientPkg } from "./client/PACKAGE.ts"
import { Package as clientDbPkg } from "./client/db/PACKAGE.ts"
import { Package as clientTriePkg } from "./client/trie/PACKAGE.ts"
import { Package as clientStatePkg } from "./client/state/PACKAGE.ts"
import { Package as clientEvmPkg } from "./client/evm/PACKAGE.ts"
import { Package as clientBlockchainPkg } from "./client/blockchain/PACKAGE.ts"
import { Package as clientTxpoolPkg } from "./client/txpool/PACKAGE.ts"
import { Package as clientNetworkPkg } from "./client/network/PACKAGE.ts"
import { Package as clientRpcPkg } from "./client/rpc/PACKAGE.ts"
import { Package as clientEnginePkg } from "./client/engine/PACKAGE.ts"
import { Package as clientSyncPkg } from "./client/sync/PACKAGE.ts"
import { Package as tsUtilsPkg } from "./src/utils/PACKAGE.ts"
import { Package as clientTsDbPkg } from "./client-ts/db/PACKAGE.ts"
import { Package as clientTsStatePkg } from "./client-ts/state/PACKAGE.ts"
import { Package as clientTsTriePkg } from "./client-ts/trie/PACKAGE.ts"
import { Package as clientTsEvmPkg } from "./client-ts/evm/PACKAGE.ts"
import { Package as clientTsBlockchainPkg } from "./client-ts/blockchain/PACKAGE.ts"
import { Package as clientTsEnginePkg } from "./client-ts/engine/PACKAGE.ts"
import { Package as clientTsNetworkPkg } from "./client-ts/network/PACKAGE.ts"
import { Package as clientTsRpcPkg } from "./client-ts/rpc/PACKAGE.ts"
import { Package as clientTsRunnerPkg } from "./client-ts/runner/PACKAGE.ts"
import { Package as clientTsSyncPkg } from "./client-ts/sync/PACKAGE.ts"
import { Package as clientTsTxpoolPkg } from "./client-ts/txpool/PACKAGE.ts"

const { bytecode_srcs, storage_srcs, frame_srcs, evm_srcs, ffi_srcs } = srcPkg
const { bench_utils, cli_srcs } = clientPkg
const { test: clientDbTest } = clientDbPkg
const { test: clientTrieTest } = clientTriePkg
const { test: clientStateTest } = clientStatePkg
const { test: clientEvmTest } = clientEvmPkg
const { test: clientBlockchainTest } = clientBlockchainPkg
const { test: clientTxpoolTest } = clientTxpoolPkg
const { test: clientNetworkTest } = clientNetworkPkg
const { test: clientRpcTest } = clientRpcPkg
const { test: clientEngineTest } = clientEnginePkg
const { test: clientSyncTest } = clientSyncPkg
const { test: tsUtilsTest } = tsUtilsPkg
const { test: clientTsDbTest } = clientTsDbPkg
const { test: clientTsStateTest } = clientTsStatePkg
const { test: clientTsTrieTest } = clientTsTriePkg
const { test: clientTsEvmTest } = clientTsEvmPkg
const { test: clientTsBlockchainTest } = clientTsBlockchainPkg
const { test: clientTsEngineTest } = clientTsEnginePkg
const { test: clientTsNetworkTest } = clientTsNetworkPkg
const { test: clientTsRpcTest } = clientTsRpcPkg
const { test: clientTsRunnerTest } = clientTsRunnerPkg
const { test: clientTsSyncTest } = clientTsSyncPkg
const { test: clientTsTxpoolTest } = clientTsTxpoolPkg

const build_files = S.Filegroup({
  srcs: [S.file("build.zig"), S.file("build.zig.zon")],
})

/** Non-code file ownership so doc/report/script edits do not conservatively invalidate benchmarks. */
const docs_files = S.Filegroup({
  srcs: [...S.glob(["docs/**", "*.md", "LICENSE"])],
})

const reports_files = S.Filegroup({
  srcs: [...S.glob(["reports/**"])],
})

const misc_files = S.Filegroup({
  srcs: [
    ...S.glob([
      "scripts/**",
      "examples/**",
      "cloudflare/**",
      "prd/**",
      "patches/**",
      "test/**",
      ".github/**",
      ".githooks/**",
      ".claude/**",
      "*.json",
      "*.toml",
      "*.mjs",
      "test_runner.zig",
      "test_trace.zig",
    ]),
  ],
})

// ---------------------------------------------------------------------------
// Core EVM fine-grained incremental benchmarks (ReleaseFast, exclusive)
// ---------------------------------------------------------------------------

const bench_bytecode = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-bytecode", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: ".bench-results/core-bytecode.json" },
  data: [S.file("//.smithers/run-zig.sh"), build_files, bench_utils, bytecode_srcs],
  exclusive: true,
  sandbox: "none",
})

const bench_storage = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-storage", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: ".bench-results/core-storage.json" },
  data: [S.file("//.smithers/run-zig.sh"), build_files, bench_utils, storage_srcs],
  exclusive: true,
  sandbox: "none",
})

const bench_frame = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-frame", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: ".bench-results/core-frame.json" },
  data: [S.file("//.smithers/run-zig.sh"), build_files, bench_utils, frame_srcs],
  exclusive: true,
  sandbox: "none",
})

const bench_opcodes = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-opcodes", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: ".bench-results/core-opcodes.json" },
  data: [S.file("//.smithers/run-zig.sh"), build_files, bench_utils, evm_srcs],
  exclusive: true,
  sandbox: "none",
})

const bench_evm_core = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-evm-core", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: ".bench-results/core-evm.json" },
  data: [S.file("//.smithers/run-zig.sh"), build_files, bench_utils, evm_srcs],
  exclusive: true,
  sandbox: "none",
})

const bench_ffi = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-ffi", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: ".bench-results/core-ffi.json" },
  data: [S.file("//.smithers/run-zig.sh"), build_files, bench_utils, ffi_srcs],
  exclusive: true,
  sandbox: "none",
})

const bench_wasm = S.Shell.Test({
  shell: "zig build wasm && node test/wasm.bench.mjs",
  env: { BENCH_JSON_OUT: ".bench-results/wasm.json" },
  data: [build_files, ffi_srcs, S.file("test/wasm.bench.mjs")],
  exclusive: true,
  sandbox: "none",
})

const bench_cli = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-cli", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: ".bench-results/client-cli.json" },
  data: [S.file("//.smithers/run-zig.sh"), build_files, bench_utils, cli_srcs],
  exclusive: true,
  sandbox: "none",
})

// ---------------------------------------------------------------------------
// Core EVM & WASM unit/integration tests
// ---------------------------------------------------------------------------

const test_unit = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "unit"],
  data: [S.file("//.smithers/run-zig.sh"), build_files, evm_srcs, cli_srcs],
  sandbox: "none",
})

const test_trace = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "test-trace"],
  data: [S.file("//.smithers/run-zig.sh"), build_files, evm_srcs, S.file("test_trace.zig")],
  sandbox: "none",
})

const test_runner = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "test-runner"],
  data: [S.file("//.smithers/run-zig.sh"), build_files, evm_srcs, cli_srcs],
  sandbox: "none",
})

const test_wasm = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "test-wasm"],
  data: [S.file("//.smithers/run-zig.sh"), build_files, ffi_srcs, S.file("test/wasm.test.mjs")],
  sandbox: "none",
})

// ---------------------------------------------------------------------------
// Benchmark summary tool
// Benchmarks are exclusive tests: select them explicitly or with
// `smthrs test --include-exclusive //...`. A Suite over them would make every
// wildcard `smthrs ci //...` refuse, so none is declared.
// ---------------------------------------------------------------------------

const bench_summary = S.Shell.Run({
  bin: S.Host.bin("bun"),
  args: ["scripts/bench-summary.ts"],
  data: [S.file("scripts/bench-summary.ts")],
  sandbox: "none",
})

const test_all = S.Suite({
  tests: [
    test_unit,
    test_trace,
    test_runner,
    test_wasm,
    clientDbTest,
    clientTrieTest,
    clientStateTest,
    clientEvmTest,
    clientBlockchainTest,
    clientTxpoolTest,
    clientNetworkTest,
    clientRpcTest,
    clientEngineTest,
    clientSyncTest,
    tsUtilsTest,
    clientTsDbTest,
    clientTsStateTest,
    clientTsTrieTest,
    clientTsEvmTest,
    clientTsBlockchainTest,
    clientTsEngineTest,
    clientTsNetworkTest,
    clientTsRpcTest,
    clientTsRunnerTest,
    clientTsSyncTest,
    clientTsTxpoolTest,
  ],
})

export const Package = S.Package({
  targets: {
    build_files,
    docs_files,
    reports_files,
    misc_files,
    bench_bytecode,
    bench_storage,
    bench_frame,
    bench_opcodes,
    bench_evm_core,
    bench_ffi,
    bench_wasm,
    bench_cli,
    test_unit,
    test_trace,
    test_runner,
    test_wasm,
    bench_summary,
    test_all,
  },
})

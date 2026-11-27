import { Smithers as S } from "@smthrs/targets"
import { Package as srcPkg } from "./src/PACKAGE.ts"
import { Package as tsUtilsPkg } from "./src/utils/PACKAGE.ts"
import { Package as tsSdkPkg } from "./ts/PACKAGE.ts"

const { bench_utils, bytecode_srcs, storage_srcs, frame_srcs, evm_srcs, ffi_srcs } = srcPkg
const { test: tsUtilsTest } = tsUtilsPkg
const { test: tsSdkTest } = tsSdkPkg

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
      "test/**",
      "include/**",
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
  tools: [S.Host.bin("zig"), S.Host.bin("node"), S.Host.bin("wasm-opt")],
  shell: "zig build wasm && node test/wasm.bench.mjs",
  env: { BENCH_JSON_OUT: ".bench-results/wasm.json" },
  data: [build_files, ffi_srcs, S.file("test/wasm.bench.mjs")],
  exclusive: true,
  sandbox: "none",
})

// ---------------------------------------------------------------------------
// Core EVM & WASM unit/integration tests
// ---------------------------------------------------------------------------

/** Spec runner sources compiled by `zig build unit` and `test-spec-runner` without fixtures. */
const spec_runner_srcs = S.Filegroup({
  srcs: [
    S.file("test/specs/runner.zig"),
    S.file("test/specs/test_host.zig"),
    S.file("test/specs/assembler.zig"),
    S.file("test/specs/header_validator.zig"),
  ],
})

const test_unit = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "unit"],
  data: [S.file("//.smithers/run-zig.sh"), build_files, evm_srcs, spec_runner_srcs],
  sandbox: "none",
})

const test_spec_runner = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "test-spec-runner"],
  data: [S.file("//.smithers/run-zig.sh"), build_files, evm_srcs, spec_runner_srcs],
  sandbox: "none",
})

const test_trace = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "test-trace"],
  data: [S.file("//.smithers/run-zig.sh"), build_files, evm_srcs, S.file("test_trace.zig")],
  sandbox: "none",
})

const test_wasm = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig"), S.Host.bin("node"), S.Host.bin("wasm-opt")],
  args: [".smithers/run-zig.sh", "build", "test-wasm", "test-wasm-size"],
  data: [
    S.file("//.smithers/run-zig.sh"),
    build_files,
    ffi_srcs,
    S.file("native-dependencies.json"),
    S.file("test/wasm.test.mjs"),
    S.file("test/wasm-size.mjs"),
    S.file("wasm/precompiles.mjs"),
  ],
  sandbox: "none",
})

const bench_summary = S.Shell.Run({
  bin: S.Host.bin("bun"),
  args: ["scripts/bench-summary.ts"],
  data: [S.file("scripts/bench-summary.ts")],
  sandbox: "none",
})

const test_all = S.Suite({
  tests: [
    test_unit,
    test_spec_runner,
    test_trace,
    test_wasm,
    tsUtilsTest,
    tsSdkTest,
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
    spec_runner_srcs,
    test_unit,
    test_spec_runner,
    test_trace,
    test_wasm,
    bench_summary,
    test_all,
  },
})

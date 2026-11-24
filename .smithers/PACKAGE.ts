import { Smithers as S } from "@smthrs/targets"

// Factory projection plus repository-wide gates that no source package owns.
// Root-anchored filegroups set cwd: "//" because globs stay package scoped
// even with a // prefix.
const zigSources = S.Filegroup({
  cwd: "//",
  srcs: [
    S.file("//build.zig"),
    S.file("//build.zig.zon"),
    S.file("//test_runner.zig"),
    S.file("//test_trace.zig"),
    S.glob("//src/**/*.zig"),
    S.glob("//client/**/*.zig"),
  ],
})

const factorySources = S.Filegroup({
  srcs: [S.glob("**", { exclude: ["cache/**", "reports/**"] })],
})

// zig fmt is the repository's only formatter/linter for Zig sources.
const fmtCheck = S.Shell.Test({
  bin: S.Host.bin("zig"),
  args: ["fmt", "--check", "build.zig", "test_runner.zig", "test_trace.zig", "src", "client"],
  sandbox: "none",
  timeout: "5m",
  data: [zigSources],
})

// Native static library and WASI reactor (the C/WASM bindings). Links the
// Rust crypto archive from the adjacent ../voltaire checkout pinned in
// native-dependencies.json. run-zig.sh serializes Zig across targets.
const build = S.Shell.Build({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig"), S.Host.bin("wasm-opt")],
  args: [".smithers/run-zig.sh", "build", "native", "wasm", "-p", "zig-out/smithers"],
  sandbox: "none",
  timeout: "30m",
  data: [S.file("run-zig.sh"), zigSources],
  outDirs: ["//zig-out/smithers"],
})

export const Package = S.Package({
  targets: {
    "zig-sources": zigSources,
    "factory-sources": factorySources,
    "factory-write": S.FactoryProjection({ mode: "write" }),
    "factory-check": S.FactoryProjection({ mode: "check" }),
    "fmt-check": fmtCheck,
    build,
  },
})

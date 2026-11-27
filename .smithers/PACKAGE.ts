import { Smithers as S } from "@smthrs/targets"
import { Package as srcPkg } from "../src/PACKAGE.ts"

// Factory projection plus repository-wide gates that no single source package owns.
// Source closures reference each owning package's exported Filegroups rather than
// globbing across package boundaries.
const zigSources = S.Filegroup({
  cwd: "//",
  srcs: [
    S.file("//build.zig"),
    S.file("//build.zig.zon"),
    S.file("//test_runner.zig"),
    S.file("//test_trace.zig"),
    srcPkg.bench_utils,
    srcPkg.ffi_srcs,
  ],
})

const factorySources = S.Filegroup({
  srcs: [S.glob("**", { exclude: ["cache/**", "reports/**"] })],
})

const factoryScripts = S.Filegroup({
  srcs: [S.glob("scripts/**")],
})

// zig fmt is the repository's canonical formatter/linter for Zig sources.
const fmtCheck = S.Shell.Test({
  bin: S.Host.bin("zig"),
  args: ["fmt", "--check", "build.zig", "test_runner.zig", "test_trace.zig", "src"],
  sandbox: "none",
  timeout: "5m",
  data: [zigSources],
})

// Native static library and WASI reactor (the C/WASM bindings). Links Voltaire
// crypto resolved cleanly from build.zig.zon. run-zig.sh serializes Zig across targets.
const build = S.Shell.Build({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig"), S.Host.bin("wasm-opt")],
  args: [".smithers/run-zig.sh", "build", "native", "wasm", "-p", "zig-out/smithers"],
  sandbox: "none",
  timeout: "30m",
  data: [S.file("run-zig.sh"), zigSources],
  outDirs: ["//zig-out/smithers"],
})

// Unit tests for factory trust-policy, cache isolation, and one-time auth helpers.
const factoryScriptsTest = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: ["test", "./.smithers/scripts/"],
  sandbox: "none",
  timeout: "2m",
  data: [factoryScripts, S.file("HOME.ts"), S.file("home.json")],
})

const wikiSources = S.Filegroup({
  srcs: [S.glob("wiki/**")],
})

const wikiCheck = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: [".smithers/scripts/sync-wiki-feed.ts", "--check"],
  sandbox: "none",
  timeout: "1m",
  data: [wikiSources, S.file("scripts/sync-wiki-feed.ts"), S.file("scripts/trust-policy.ts")],
})

const homeCheck = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: [".smithers/scripts/project-home.ts", "--check"],
  sandbox: "none",
  timeout: "1m",
  data: [S.file("HOME.ts"), S.file("home.json"), S.file("scripts/project-home.ts")],
})

const homeWrite = S.Shell.Run({
  bin: S.Host.bin("bun"),
  args: [".smithers/scripts/project-home.ts", "--write"],
  sandbox: "none",
  data: [S.file("HOME.ts"), S.file("scripts/project-home.ts")],
})

export const Package = S.Package({
  targets: {
    "zig-sources": zigSources,
    "factory-sources": factorySources,
    "factory-scripts": factoryScripts,
    "wiki-sources": wikiSources,
    "factory-check": S.FactoryProjection({ mode: "check", homeOutput: ".smithers/.home-unmanaged" }),
    "home-write": homeWrite,
    "home-check": homeCheck,
    "wiki-check": wikiCheck,
    "factory-scripts-test": factoryScriptsTest,
    "fmt-check": fmtCheck,
    build,
  },
})

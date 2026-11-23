#!/usr/bin/env bun
/**
 * Reads all `.bench-results/*.json` files emitted by Zig, TypeScript, and WASM
 * benchmark suites (via `BENCH_JSON_OUT`) and prints a unified summary table.
 *
 * Usage:
 *   bun scripts/bench-summary.ts                       # print current results
 *   bun scripts/bench-summary.ts --dir .bench-results  # custom results dir
 *   bun scripts/bench-summary.ts --baseline base.json  # diff against baseline snapshot
 *   bun scripts/bench-summary.ts --save base.json      # save merged snapshot
 */
import { existsSync, readdirSync, readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";

interface BenchRow {
  readonly name: string;
  readonly ops: number;
  readonly elapsed_ns: number;
  readonly per_op_ns: number;
  readonly ops_per_sec: number;
}

interface SuiteReport {
  readonly suite: string;
  readonly benchmarks: ReadonlyArray<BenchRow>;
}

function formatNs(ns: number): string {
  if (ns < 1_000) return `${Math.round(ns)} ns`;
  if (ns < 1_000_000) return `${(ns / 1_000).toFixed(1)} us`;
  if (ns < 1_000_000_000) return `${(ns / 1_000_000).toFixed(2)} ms`;
  return `${(ns / 1_000_000_000).toFixed(3)} s`;
}

function formatOps(opsPerSec: number): string {
  if (!Number.isFinite(opsPerSec)) return "inf ops/s";
  if (opsPerSec >= 1_000_000) return `${(opsPerSec / 1_000_000).toFixed(2)} M ops/s`;
  if (opsPerSec >= 1_000) return `${(opsPerSec / 1_000).toFixed(1)} K ops/s`;
  return `${opsPerSec.toFixed(0)} ops/s`;
}

const args = process.argv.slice(2);
let dir = ".bench-results";
let baselinePath: string | undefined;
let savePath: string | undefined;

for (let i = 0; i < args.length; i += 1) {
  if (args[i] === "--dir" && args[i + 1]) {
    dir = args[i + 1]!;
    i += 1;
  } else if (args[i] === "--baseline" && args[i + 1]) {
    baselinePath = args[i + 1]!;
    i += 1;
  } else if (args[i] === "--save" && args[i + 1]) {
    savePath = args[i + 1]!;
    i += 1;
  }
}

const files: string[] = [];
if (existsSync(dir)) {
  for (const f of readdirSync(dir)) {
    if (f.endsWith(".json")) files.push(join(dir, f));
  }
}
const subGlob = new Bun.Glob("**/.bench-result.json");
for (const f of subGlob.scanSync(".")) {
  if (!f.includes("node_modules") && !f.includes(".flows") && !f.includes(".zig-cache")) {
    files.push(f);
  }
}
files.sort();

if (files.length === 0) {
  console.log(`No benchmark results found in ${dir} or **/.bench-result.json. Run benchmarks via Smithers first.`);
  process.exit(0);
}

const suites: SuiteReport[] = [];
for (const file of files) {
  try {
    const parsed = JSON.parse(readFileSync(file, "utf8")) as SuiteReport;
    if (parsed && typeof parsed.suite === "string" && Array.isArray(parsed.benchmarks)) {
      suites.push(parsed);
    }
  } catch (err) {
    console.error(`Warning: failed to parse ${file}:`, err);
  }
}

const baselineMap = new Map<string, BenchRow>();
if (baselinePath && existsSync(baselinePath)) {
  const baseSuites = JSON.parse(readFileSync(baselinePath, "utf8")) as ReadonlyArray<SuiteReport>;
  for (const s of baseSuites) {
    for (const b of s.benchmarks) {
      baselineMap.set(`${s.suite}::${b.name}`, b);
    }
  }
}

console.log("");
console.log("=".repeat(112));
console.log(`  Guillotine-Mini Benchmark Summary (${suites.length} suites)`);
console.log("=".repeat(112));

let totalBenchmarks = 0;
for (const suite of suites) {
  console.log(`\n[${suite.suite}] (${suite.benchmarks.length} benchmarks)`);
  for (const b of suite.benchmarks) {
    totalBenchmarks += 1;
    let deltaStr = "";
    const prev = baselineMap.get(`${suite.suite}::${b.name}`);
    if (prev && prev.per_op_ns > 0 && b.per_op_ns > 0) {
      const ratio = prev.per_op_ns / b.per_op_ns;
      deltaStr =
        ratio >= 1.05
          ? `  (${ratio.toFixed(2)}x faster)`
          : ratio <= 0.95
            ? `  (${(1 / ratio).toFixed(2)}x slower)`
            : "  (~same)";
    }
    console.log(
      `  ${b.name.padEnd(54)} ${String(b.ops).padStart(9)} ops  per-op=${formatNs(b.per_op_ns).padEnd(10)}  ${formatOps(b.ops_per_sec).padEnd(14)}${deltaStr}`,
    );
  }
}

console.log("\n" + "=".repeat(112));
console.log(`  Total: ${totalBenchmarks} benchmarks across ${suites.length} suites`);
console.log("=".repeat(112) + "\n");

if (savePath) {
  const parent = dirname(savePath);
  if (parent && parent !== ".") mkdirSync(parent, { recursive: true });
  writeFileSync(savePath, `${JSON.stringify(suites, null, 2)}\n`, "utf8");
  console.log(`Saved merged benchmark snapshot to ${savePath}`);
}

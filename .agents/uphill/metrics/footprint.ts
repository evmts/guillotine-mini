import { Glob } from "bun";
import { appendFileSync, readFileSync, statSync } from "fs";

const out = process.env.UPHILL_METRICS;
if (!out) {
  console.error("UPHILL_METRICS is not set");
  process.exit(1);
}

const lines: string[] = [];

function isProdZig(path: string): boolean {
  return (
    !path.endsWith("_test.zig") &&
    !path.endsWith("_tests.zig") &&
    !path.startsWith("src/bench_") &&
    !path.endsWith("/bench.zig")
  );
}

function isProdTs(path: string): boolean {
  return (
    !path.includes("node_modules/") &&
    !path.endsWith(".test.ts") &&
    !path.endsWith(".spec.ts") &&
    !path.endsWith(".bench.ts") &&
    !path.endsWith(".d.ts")
  );
}

// 1. Zig production file line counts
const zigFiles = [...new Glob("src/**/*.zig").scanSync(".")]
  .sort()
  .filter(isProdZig);

for (const file of zigFiles) {
  const lineCount = readFileSync(file, "utf8").split("\n").length;
  lines.push(`zig-file-lines ${file} ${lineCount}`);
}

// 2. WASM-compiled EVM core source surface bytes
const wasmSurface = [
  ...new Glob("src/**/*.zig").scanSync(".").filter(isProdZig),
  ...new Glob("wasm/**/*.mjs").scanSync("."),
].sort();

for (const file of wasmSurface) {
  lines.push(`wasm-surface-bytes ${file} ${statSync(file).size}B`);
}

// 3. TypeScript production file line counts
const tsFiles = [...new Glob("ts/**/*.ts").scanSync(".")]
  .sort()
  .filter(isProdTs);

for (const file of tsFiles) {
  const lineCount = readFileSync(file, "utf8").split("\n").length;
  lines.push(`ts-file-lines ${file} ${lineCount}`);
}

appendFileSync(out, lines.join("\n") + "\n");

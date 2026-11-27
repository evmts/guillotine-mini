import { Glob } from "bun";
import { appendFileSync, readFileSync } from "fs";

const out = process.env.UPHILL_METRICS;
if (!out) {
  console.error("UPHILL_METRICS is not set");
  process.exit(1);
}

const lines: string[] = [];
const q = (s: string) => JSON.stringify(s);

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

function stripLine(line: string): string {
  return line.replace(/\/\/.*$/, "").replace(/"(?:\\.|[^"\\])*"/g, '""');
}

const zigFiles = [
  ...new Glob("src/**/*.zig").scanSync("."),
  ...new Glob("client/**/*.zig").scanSync("."),
]
  .sort()
  .filter(isProdZig);

let totalProdLines = 0;
let totalAsserts = 0;

for (const file of zigFiles) {
  const raw = readFileSync(file, "utf8").split("\n");
  let panicHit: string | null = null;
  let debugPrintHit: string | null = null;
  let swallowHit: string | null = null;

  for (let i = 0; i < raw.length; i++) {
    const line = raw[i]!;
    if (/^test\s*(?:"[^"]*")?\s*\{/.test(line)) break;
    totalProdLines++;
    const code = stripLine(line);

    if (/\bassert\s*\(/.test(code)) totalAsserts++;

    if (!panicHit) {
      if (/@panic\s*\(/.test(code)) {
        panicHit = `line ${i + 1}: @panic() in production code`;
      } else if (/\bcatch\s+unreachable\b/.test(code)) {
        panicHit = `line ${i + 1}: catch unreachable in production code`;
      } else if (/\bunreachable\b/.test(code)) {
        panicHit = `line ${i + 1}: unreachable in production code`;
      }
    }

    if (!debugPrintHit && file !== "src/logger.zig" && code.includes("std.debug.print")) {
      debugPrintHit = `line ${i + 1}: std.debug.print (use logger.zig)`;
    }

    if (!swallowHit) {
      if (/\bcatch\s*\{\s*\}/.test(code)) {
        swallowHit = `line ${i + 1}: empty catch {} swallows error`;
      } else if (code.includes("error.NotImplemented")) {
        swallowHit = `line ${i + 1}: error.NotImplemented stub`;
      }
    }
  }

  lines.push(
    panicHit
      ? `zig-no-panic ${file} fail note ${q(panicHit)}`
      : `zig-no-panic ${file} pass`,
  );
  lines.push(
    debugPrintHit
      ? `zig-no-debug-print ${file} fail note ${q(debugPrintHit)}`
      : `zig-no-debug-print ${file} pass`,
  );
  lines.push(
    swallowHit
      ? `zig-no-swallowed-errors ${file} fail note ${q(swallowHit)}`
      : `zig-no-swallowed-errors ${file} pass`,
  );
}

const density = totalProdLines > 0 ? (totalAsserts * 1000) / totalProdLines : 0;
lines.push(`zig-assertion-density ${density.toFixed(2)}`);

const tsFiles = [
  ...new Glob("ts/**/*.ts").scanSync("."),
  ...new Glob("client-ts/**/*.ts").scanSync("."),
]
  .sort()
  .filter(isProdTs);

for (const file of tsFiles) {
  const raw = readFileSync(file, "utf8").split("\n");
  let anyHit: string | null = null;
  let suppressHit: string | null = null;

  for (let i = 0; i < raw.length; i++) {
    const line = raw[i]!;
    if (!suppressHit && /@ts-(ignore|expect-error|nocheck)/.test(line)) {
      suppressHit = `line ${i + 1}: TypeScript error suppression comment`;
    }
    const code = stripLine(line);
    if (!anyHit && /(:\s*any\b|\bas\s+any\b|<any>)/.test(code)) {
      anyHit = `line ${i + 1}: explicit any`;
    }
  }

  lines.push(
    anyHit
      ? `ts-no-explicit-any ${file} fail note ${q(anyHit)}`
      : `ts-no-explicit-any ${file} pass`,
  );
  lines.push(
    suppressHit
      ? `ts-no-suppress ${file} fail note ${q(suppressHit)}`
      : `ts-no-suppress ${file} pass`,
  );
}

appendFileSync(out, lines.join("\n") + "\n");

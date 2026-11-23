#!/usr/bin/env bun
/**
 * Runs one or more `client-ts` benchmark files with `bun`, streams output live,
 * and guarantees a JSON summary file at `BENCH_JSON_OUT` (for legacy `console.table`
 * client-ts benchmarks that don't use `TsBenchSuite` directly).
 *
 * Usage:
 *   BENCH_JSON_OUT=.bench-results/client-ts-db.json bun scripts/run-client-ts-bench.ts client-ts/db client-ts/db/Db.bench.ts client-ts/db/DbIterator.bench.ts
 */
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";

const [suiteName, ...files] = process.argv.slice(2);
if (!suiteName || files.length === 0) {
  console.error("Usage: bun scripts/run-client-ts-bench.ts <suite-name> <file1.bench.ts> [...]");
  process.exit(2);
}

const outPath = process.env.BENCH_JSON_OUT;
const repoRoot = resolve(import.meta.dir, "..");
const clientTsDir = resolve(repoRoot, "client-ts");
const resolvedOutPath = outPath ? resolve(process.cwd(), outPath) : undefined;

// Ensure voltaire peer symlink is repaired before running
const prep = Bun.spawnSync(["node", "scripts/repairVoltairePeer.mjs"], {
  cwd: clientTsDir,
  stdout: "inherit",
  stderr: "inherit",
});
if (prep.exitCode !== 0) process.exit(prep.exitCode);

interface BenchRow {
  readonly name: string;
  readonly ops: number;
  readonly elapsed_ns: number;
  readonly per_op_ns: number;
  readonly ops_per_sec: number;
}

const parsedRows: BenchRow[] = [];
let wroteByChild = false;

for (const file of files) {
  const rel = relative(clientTsDir, resolve(repoRoot, file));
  const env = { ...process.env };
  // If only a single TsBenchSuite file is run, let it write BENCH_JSON_OUT directly
  if (files.length > 1) {
    delete env.BENCH_JSON_OUT;
  } else if (resolvedOutPath) {
    env.BENCH_JSON_OUT = resolvedOutPath;
  }

  const t0 = Bun.nanoseconds();
  const proc = Bun.spawnSync(["bun", rel], {
    cwd: clientTsDir,
    env,
    stdout: "pipe",
    stderr: "pipe",
  });
  const wallNs = Bun.nanoseconds() - t0;

  const stdout = proc.stdout ? Buffer.from(proc.stdout).toString("utf8") : "";
  const stderr = proc.stderr ? Buffer.from(proc.stderr).toString("utf8") : "";
  if (stdout.length > 0) process.stdout.write(stdout);
  if (stderr.length > 0) process.stderr.write(stderr);

  if (proc.exitCode !== 0) {
    process.exit(proc.exitCode);
  }

  if (files.length === 1 && resolvedOutPath && existsSync(resolvedOutPath)) {
    wroteByChild = true;
    continue;
  }

  // Parse `console.table` rows (e.g. `│ 0 │ 'put' │ 50000 │ 123 │ 0.00246 │ 406504 │`)
  // or TsBenchSuite lines (`  name   ops ops  total=...  per-op=...  ... ops/s`)
  let foundInFile = 0;
  for (const line of stdout.split("\n")) {
    const tableMatch = line.match(
      /[│|]\s*\d+\s*[│|]\s*['"]?([^'│|]+?)['"]?\s*[│|]\s*([\d_]+)\s*[│|]\s*([\d.]+)\s*[│|]\s*([\d.]+)\s*[│|]\s*([\d_]+)\s*[│|]/,
    );
    if (tableMatch) {
      const label = tableMatch[1]!.trim();
      const count = Number(tableMatch[2]!.replaceAll("_", ""));
      const ms = Number(tableMatch[3]!);
      const opsPerSec = Number(tableMatch[5]!.replaceAll("_", ""));
      const elapsedNs = Math.round(ms * 1_000_000);
      const perOpNs = count > 0 ? Math.round(elapsedNs / count) : 0;
      parsedRows.push({
        name: `${rel.replace(/\.bench\.ts$/, "")}: ${label}`,
        ops: count,
        elapsed_ns: elapsedNs,
        per_op_ns: perOpNs,
        ops_per_sec: opsPerSec,
      });
      foundInFile += 1;
    }
  }
  if (foundInFile === 0) {
    parsedRows.push({
      name: rel,
      ops: 1,
      elapsed_ns: wallNs,
      per_op_ns: wallNs,
      ops_per_sec: wallNs > 0 ? 1e9 / wallNs : 0,
    });
  }
}

if (resolvedOutPath && resolvedOutPath.length > 0 && !wroteByChild) {
  const dir = dirname(resolvedOutPath);
  if (dir && dir !== ".") mkdirSync(dir, { recursive: true });
  writeFileSync(
    resolvedOutPath,
    `${JSON.stringify({ suite: suiteName, benchmarks: parsedRows }, null, 2)}\n`,
    "utf8",
  );
}

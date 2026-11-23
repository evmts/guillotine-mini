import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

export interface TsBenchResult {
  readonly name: string;
  readonly ops: number;
  readonly elapsed_ns: number;
  readonly per_op_ns: number;
  readonly ops_per_sec: number;
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

export class TsBenchSuite {
  private readonly results: TsBenchResult[] = [];
  constructor(private readonly suiteName: string) {
    console.log("");
    console.log("=".repeat(104));
    console.log(`  Benchmark Suite: ${suiteName}`);
    console.log("=".repeat(104));
  }

  section(title: string): void {
    console.log(`\n--- ${title} ---`);
  }

  bench(name: string, ops: number, fn: () => void, warmup = 1): TsBenchResult {
    for (let i = 0; i < warmup; i += 1) fn();
    const start = process.hrtime.bigint();
    fn();
    const elapsedNs = Number(process.hrtime.bigint() - start);
    const perOpNs = ops > 0 ? Math.floor(elapsedNs / ops) : 0;
    const opsPerSec = elapsedNs > 0 ? (ops / (elapsedNs / 1e9)) : 0;
    const row: TsBenchResult = { name, ops, elapsed_ns: elapsedNs, per_op_ns: perOpNs, ops_per_sec: opsPerSec };
    this.record(row);
    return row;
  }

  async benchAsync(name: string, ops: number, fn: () => Promise<void>, warmup = 1): Promise<TsBenchResult> {
    for (let i = 0; i < warmup; i += 1) await fn();
    const start = process.hrtime.bigint();
    await fn();
    const elapsedNs = Number(process.hrtime.bigint() - start);
    const perOpNs = ops > 0 ? Math.floor(elapsedNs / ops) : 0;
    const opsPerSec = elapsedNs > 0 ? (ops / (elapsedNs / 1e9)) : 0;
    const row: TsBenchResult = { name, ops, elapsed_ns: elapsedNs, per_op_ns: perOpNs, ops_per_sec: opsPerSec };
    this.record(row);
    return row;
  }

  record(row: TsBenchResult): void;
  record(name: string, ops: number, elapsedNs: number): void;
  record(rowOrName: TsBenchResult | string, ops?: number, elapsedNs?: number): void {
    const row: TsBenchResult =
      typeof rowOrName === "string"
        ? {
            name: rowOrName,
            ops: ops ?? 0,
            elapsed_ns: elapsedNs ?? 0,
            per_op_ns: (ops ?? 0) > 0 ? Math.floor((elapsedNs ?? 0) / (ops ?? 1)) : 0,
            ops_per_sec: (elapsedNs ?? 0) > 0 ? ((ops ?? 0) / ((elapsedNs ?? 0) / 1e9)) : 0,
          }
        : rowOrName;
    const line = `  ${row.name.padEnd(55)} ${String(row.ops).padStart(10)} ops  total=${formatNs(row.elapsed_ns).padEnd(10)}  per-op=${formatNs(row.per_op_ns).padEnd(10)}  ${formatOps(row.ops_per_sec)}`;
    console.log(line);
    this.results.push(row);
  }

  finish(): void {
    console.log("=".repeat(104));
    console.log("");
    const outPath = process.env.BENCH_JSON_OUT;
    if (outPath && outPath.length > 0) {
      const dir = dirname(outPath);
      if (dir && dir !== ".") mkdirSync(dir, { recursive: true });
      writeFileSync(
        outPath,
        `${JSON.stringify({ suite: this.suiteName, benchmarks: this.results }, null, 2)}\n`,
        "utf8",
      );
    }
  }
}

import * as Effect from "effect/Effect";
import { TsBenchSuite } from "../../scripts/bench-ts-utils";
import { RunnerConfigLive, getRunnerConfig } from "./RunnerConfig";

const suite = new TsBenchSuite("client-ts/runner");
suite.section("Runner Configuration Resolution");

const argv = [
  "--config",
  "sepolia",
  "--configs-dir=./configs",
  "--data-dir",
  "/tmp/guillotine-data",
  "--db-dir=/tmp/guillotine-db",
];
const env = {
  GUILLOTINE_CONFIG: "mainnet",
  GUILLOTINE_DATA_DIR: "./fallback-data",
};

// Warmup
for (let i = 0; i < 50; i += 1) {
  await Effect.runPromise(
    getRunnerConfig().pipe(Effect.provide(RunnerConfigLive({ argv, env }))),
  );
}

const iters = 1_000;
const t0 = Bun.nanoseconds();
let sink = 0;
for (let i = 0; i < iters; i += 1) {
  const cfg = await Effect.runPromise(
    getRunnerConfig().pipe(Effect.provide(RunnerConfigLive({ argv, env }))),
  );
  sink += cfg.configuration.length;
}
const elapsed = Bun.nanoseconds() - t0;
if (sink === 0) throw new Error("unexpected");
suite.record("RunnerConfigLive CLI+env resolve & schema decode", iters, elapsed);

suite.finish();

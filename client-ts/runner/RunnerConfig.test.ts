import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import {
  RunnerConfigDefaults,
  RunnerConfigLive,
  getRunnerConfig,
} from "./RunnerConfig";

const resolveRunnerConfigSync = (
  options: Parameters<typeof RunnerConfigLive>[0],
) =>
  Effect.runSync(
    getRunnerConfig().pipe(Effect.provide(RunnerConfigLive(options))),
  );

describe("RunnerConfig", () => {
  it("uses config defaults when CLI args and env vars are absent", () => {
    const config = resolveRunnerConfigSync({
      argv: [],
      env: {},
      configDefaults: RunnerConfigDefaults,
    });

    assert.deepStrictEqual(config, RunnerConfigDefaults);
  });

  it("prefers env vars over config defaults/file values", () => {
    const config = resolveRunnerConfigSync({
      argv: [],
      env: {
        GUILLOTINE_CONFIG: "holesky",
        GUILLOTINE_DATA_DIR: "./env-data",
      },
      configDefaults: {
        configuration: "mainnet",
        dataDirectory: "./defaults-data",
      },
    });

    assert.deepStrictEqual(config, {
      configuration: "holesky",
      configurationDirectory: "configs",
      dataDirectory: "./env-data",
      databaseDirectory: "./db",
    });
  });

  it("prefers CLI args over env vars and defaults", () => {
    const config = resolveRunnerConfigSync({
      argv: [
        "--config",
        "sepolia",
        "--configs-dir=./cli-configs",
        "--data-dir",
        "./cli-data",
        "--db-dir",
        "./cli-db",
      ],
      env: {
        GUILLOTINE_CONFIG: "mainnet",
        GUILLOTINE_CONFIGS_DIR: "./env-configs",
        GUILLOTINE_DATA_DIR: "./env-data",
        GUILLOTINE_DB_DIR: "./env-db",
      },
      configDefaults: RunnerConfigDefaults,
    });

    assert.deepStrictEqual(config, {
      configuration: "sepolia",
      configurationDirectory: "./cli-configs",
      dataDirectory: "./cli-data",
      databaseDirectory: "./cli-db",
    });
  });
});

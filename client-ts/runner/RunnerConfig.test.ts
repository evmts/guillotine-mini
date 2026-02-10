import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import {
  InvalidRunnerConfigError,
  RunnerConfigCliArgumentError,
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

const resolveRunnerConfigEither = (
  options: Parameters<typeof RunnerConfigLive>[0],
) =>
  Effect.runSync(
    getRunnerConfig().pipe(
      Effect.provide(RunnerConfigLive(options)),
      Effect.either,
    ),
  );

const expectLeft = <A, E>(result: Either.Either<A, E>): E => {
  assert.strictEqual(Either.isLeft(result), true);

  if (Either.isLeft(result)) {
    return result.left;
  }

  assert.fail("Expected Left result");
};

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

  it("fails when a recognized CLI option is missing a required separate value", () => {
    const error = expectLeft(
      resolveRunnerConfigEither({
        argv: ["--config"],
        env: {},
        configDefaults: RunnerConfigDefaults,
      }),
    );

    assert.strictEqual(error instanceof RunnerConfigCliArgumentError, true);

    if (error instanceof RunnerConfigCliArgumentError) {
      assert.strictEqual(error.option, "--config");
      assert.strictEqual(error.reason, "MissingValue");
    }
  });

  it("fails when a recognized CLI option is provided with an empty inline value", () => {
    const error = expectLeft(
      resolveRunnerConfigEither({
        argv: ["--db-dir="],
        env: {},
        configDefaults: RunnerConfigDefaults,
      }),
    );

    assert.strictEqual(error instanceof RunnerConfigCliArgumentError, true);

    if (error instanceof RunnerConfigCliArgumentError) {
      assert.strictEqual(error.option, "--db-dir");
      assert.strictEqual(error.reason, "MissingValue");
    }
  });

  it("maps schema decoding failures to InvalidRunnerConfigError", () => {
    const error = expectLeft(
      resolveRunnerConfigEither({
        argv: [],
        env: {},
        configDefaults: {
          configuration: 1 as unknown as string,
        },
      }),
    );

    assert.strictEqual(error instanceof InvalidRunnerConfigError, true);

    if (error instanceof InvalidRunnerConfigError) {
      assert.strictEqual(error.message, "Invalid runner config");
      assert.notStrictEqual(error.cause, undefined);
    }
  });
});

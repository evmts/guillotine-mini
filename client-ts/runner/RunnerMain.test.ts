import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import {
  RunnerMainCliConflictError,
  RunnerMainLive,
  selectRunnerMainAction,
} from "./RunnerMain";

const provideRunnerMain = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(RunnerMainLive));

describe("RunnerMain", () => {
  it.effect("selects help action when help flag is present", () =>
    provideRunnerMain(
      Effect.gen(function* () {
        const longFlag = yield* selectRunnerMainAction(["--help"]);
        assert.deepStrictEqual(longFlag, {
          _tag: "ShowHelp",
        });

        const shortFlag = yield* selectRunnerMainAction(["-h"]);
        assert.deepStrictEqual(shortFlag, {
          _tag: "ShowHelp",
        });
      }),
    ),
  );

  it.effect("selects version action when version flag is present", () =>
    provideRunnerMain(
      Effect.gen(function* () {
        const longFlag = yield* selectRunnerMainAction(["--version"]);
        assert.deepStrictEqual(longFlag, {
          _tag: "ShowVersion",
        });

        const shortFlag = yield* selectRunnerMainAction(["-v"]);
        assert.deepStrictEqual(shortFlag, {
          _tag: "ShowVersion",
        });
      }),
    ),
  );

  it.effect(
    "selects start action and preserves passthrough args by default",
    () =>
      provideRunnerMain(
        Effect.gen(function* () {
          const action = yield* selectRunnerMainAction([
            "--config",
            "mainnet",
            "--data-dir",
            "./data",
          ]);

          assert.deepStrictEqual(action, {
            _tag: "Start",
            passthroughArgs: ["--config", "mainnet", "--data-dir", "./data"],
          });
        }),
      ),
  );

  it.effect("fails when help and version flags are both present", () =>
    provideRunnerMain(
      Effect.gen(function* () {
        const exit = yield* Effect.flip(
          selectRunnerMainAction(["--version", "--help"]),
        );

        assert.instanceOf(exit, RunnerMainCliConflictError);
        assert.strictEqual(exit.reason, "ConflictingDisplayFlags");
        assert.deepStrictEqual(exit.flags, ["--help", "--version"]);
      }),
    ),
  );
});

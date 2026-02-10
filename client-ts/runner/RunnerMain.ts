import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";

/** Supported top-level runner actions selected from CLI arguments. */
export type RunnerMainAction =
  | Readonly<{
      readonly _tag: "Start";
      readonly passthroughArgs: ReadonlyArray<string>;
    }>
  | Readonly<{
      readonly _tag: "ShowHelp";
    }>
  | Readonly<{
      readonly _tag: "ShowVersion";
    }>;

/** Error raised when mutually-exclusive display flags are requested together. */
export class RunnerMainCliConflictError extends Data.TaggedError(
  "RunnerMainCliConflictError",
)<{
  readonly reason: "ConflictingDisplayFlags";
  readonly flags: ReadonlyArray<"--help" | "--version">;
}> {}

/** Service contract for selecting the top-level runner action from argv. */
export interface RunnerMainService {
  readonly selectAction: (
    argv: ReadonlyArray<string>,
  ) => Effect.Effect<RunnerMainAction, RunnerMainCliConflictError>;
}

/** Context tag for the phase-10 runner entrypoint action selector. */
export class RunnerMain extends Context.Tag("RunnerMain")<
  RunnerMain,
  RunnerMainService
>() {}

const helpAliases = new Set(["--help", "-h"]);
const versionAliases = new Set(["--version", "-v"]);

const failConflict = () =>
  Effect.fail(
    new RunnerMainCliConflictError({
      reason: "ConflictingDisplayFlags",
      flags: ["--help", "--version"],
    }),
  );

const makeRunnerMain = Effect.succeed<RunnerMainService>({
  selectAction: (argv) =>
    Effect.gen(function* () {
      const hasHelp = argv.some((argument) => helpAliases.has(argument));
      const hasVersion = argv.some((argument) => versionAliases.has(argument));

      if (hasHelp && hasVersion) {
        return yield* failConflict();
      }

      if (hasHelp) {
        return {
          _tag: "ShowHelp",
        } satisfies RunnerMainAction;
      }

      if (hasVersion) {
        return {
          _tag: "ShowVersion",
        } satisfies RunnerMainAction;
      }

      return {
        _tag: "Start",
        passthroughArgs: argv,
      } satisfies RunnerMainAction;
    }),
} satisfies RunnerMainService);

/** Live layer for selecting phase-10 runner entrypoint actions. */
export const RunnerMainLive: Layer.Layer<RunnerMain> = Layer.effect(
  RunnerMain,
  makeRunnerMain,
);

/** Select the top-level runner action from CLI arguments. */
export const selectRunnerMainAction = (argv: ReadonlyArray<string>) =>
  Effect.gen(function* () {
    const service = yield* RunnerMain;
    return yield* service.selectAction(argv);
  });

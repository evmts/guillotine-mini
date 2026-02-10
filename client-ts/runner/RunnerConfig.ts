import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";

/** Schema for runner bootstrap configuration values resolved from CLI/env/defaults. */
export const RunnerConfigSchema = Schema.Struct({
  configuration: Schema.String,
  configurationDirectory: Schema.String,
  dataDirectory: Schema.String,
  databaseDirectory: Schema.String,
});

/** Raw runner configuration input shape before schema decoding. */
export type RunnerConfigInput = Schema.Schema.Encoded<
  typeof RunnerConfigSchema
>;

/** Decoded runner configuration shape used by services. */
export type RunnerConfigData = Schema.Schema.Type<typeof RunnerConfigSchema>;

/** Default runner configuration values used when no overrides are provided. */
export const RunnerConfigDefaults: RunnerConfigInput = {
  configuration: "mainnet",
  configurationDirectory: "configs",
  dataDirectory: "./data",
  databaseDirectory: "./db",
};

/** Error raised when a recognized runner CLI option is missing its required value. */
export class RunnerConfigCliArgumentError extends Data.TaggedError(
  "RunnerConfigCliArgumentError",
)<{
  readonly option: string;
  readonly reason: "MissingValue";
}> {}

/** Error raised when runner configuration cannot be decoded. */
export class InvalidRunnerConfigError extends Data.TaggedError(
  "InvalidRunnerConfigError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Inputs used to resolve the effective runner configuration. */
export interface RunnerConfigResolveInput {
  readonly argv?: ReadonlyArray<string>;
  readonly env?: Readonly<Record<string, string | undefined>>;
  readonly configDefaults?: Partial<RunnerConfigInput>;
}

/** Service contract exposing resolved runner configuration. */
export interface RunnerConfigService {
  readonly config: RunnerConfigData;
}

/** Context tag for basic runner configuration resolution. */
export class RunnerConfig extends Context.Tag("RunnerConfig")<
  RunnerConfig,
  RunnerConfigService
>() {}

const cliOptionToConfigKey = {
  "--config": "configuration",
  "-c": "configuration",
  "--configs-dir": "configurationDirectory",
  "--configsDirectory": "configurationDirectory",
  "-cd": "configurationDirectory",
  "--data-dir": "dataDirectory",
  "--datadir": "dataDirectory",
  "-dd": "dataDirectory",
  "--db-dir": "databaseDirectory",
  "--baseDbPath": "databaseDirectory",
  "-d": "databaseDirectory",
} as const satisfies Record<string, keyof RunnerConfigInput>;

const envVarToConfigKey = {
  configuration: ["GUILLOTINE_CONFIG", "NETHERMIND_CONFIG"],
  configurationDirectory: ["GUILLOTINE_CONFIGS_DIR", "NETHERMIND_CONFIGS_DIR"],
  dataDirectory: ["GUILLOTINE_DATA_DIR", "NETHERMIND_DATA_DIR"],
  databaseDirectory: ["GUILLOTINE_DB_DIR", "NETHERMIND_DB_DIR"],
} as const satisfies Record<keyof RunnerConfigInput, ReadonlyArray<string>>;

const splitInlineCliValue = (
  argument: string,
): readonly [option: string, value: string | undefined] => {
  const separatorIndex = argument.indexOf("=");
  if (separatorIndex < 0) {
    return [argument, undefined];
  }

  return [
    argument.slice(0, separatorIndex),
    argument.slice(separatorIndex + 1),
  ];
};

const failMissingCliValue = (
  option: string,
): Effect.Effect<never, RunnerConfigCliArgumentError> =>
  Effect.fail(
    new RunnerConfigCliArgumentError({
      option,
      reason: "MissingValue",
    }),
  );

const parseCliOverrides = (
  argv: ReadonlyArray<string>,
): Effect.Effect<
  Partial<Record<keyof RunnerConfigInput, string>>,
  RunnerConfigCliArgumentError
> =>
  Effect.gen(function* () {
    const overrides: Partial<Record<keyof RunnerConfigInput, string>> = {};
    const hasCliOption = (
      option: string,
    ): option is keyof typeof cliOptionToConfigKey =>
      option in cliOptionToConfigKey;

    for (let index = 0; index < argv.length; index += 1) {
      const argument = argv[index]!;
      const [option, inlineValue] = splitInlineCliValue(argument);
      if (!hasCliOption(option)) {
        continue;
      }

      const configKey = cliOptionToConfigKey[option];

      if (inlineValue !== undefined) {
        if (inlineValue.length === 0) {
          return yield* failMissingCliValue(option);
        }

        overrides[configKey] = inlineValue;
        continue;
      }

      const next = argv[index + 1];
      if (next === undefined || next.startsWith("-")) {
        return yield* failMissingCliValue(option);
      }

      overrides[configKey] = next;
      index += 1;
    }

    return overrides;
  });

const readEnvValue = (
  env: Readonly<Record<string, string | undefined>>,
  names: ReadonlyArray<string>,
): string | undefined => {
  for (const name of names) {
    const value = env[name];
    if (typeof value === "string" && value.trim().length > 0) {
      return value;
    }
  }

  return undefined;
};

const resolveConfigValue = (
  key: keyof RunnerConfigInput,
  cliOverrides: Partial<Record<keyof RunnerConfigInput, string>>,
  env: Readonly<Record<string, string | undefined>>,
  defaults: RunnerConfigInput,
): string =>
  cliOverrides[key] ??
  readEnvValue(env, envVarToConfigKey[key]) ??
  defaults[key];

const decodeRunnerConfig = (input: RunnerConfigInput) =>
  Schema.decode(RunnerConfigSchema)(input).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidRunnerConfigError({
          message: "Invalid runner config",
          cause,
        }),
    ),
  );

const resolveRunnerConfigInput = ({
  argv = [],
  env = process.env,
  configDefaults = {},
}: RunnerConfigResolveInput): Effect.Effect<
  RunnerConfigInput,
  RunnerConfigCliArgumentError
> =>
  Effect.gen(function* () {
    const cliOverrides = yield* parseCliOverrides(argv);
    const defaults = {
      ...RunnerConfigDefaults,
      ...configDefaults,
    } satisfies RunnerConfigInput;

    return {
      configuration: resolveConfigValue(
        "configuration",
        cliOverrides,
        env,
        defaults,
      ),
      configurationDirectory: resolveConfigValue(
        "configurationDirectory",
        cliOverrides,
        env,
        defaults,
      ),
      dataDirectory: resolveConfigValue(
        "dataDirectory",
        cliOverrides,
        env,
        defaults,
      ),
      databaseDirectory: resolveConfigValue(
        "databaseDirectory",
        cliOverrides,
        env,
        defaults,
      ),
    } satisfies RunnerConfigInput;
  });

const makeRunnerConfig = (input: RunnerConfigResolveInput) =>
  Effect.gen(function* () {
    const raw = yield* resolveRunnerConfigInput(input);
    const config = yield* decodeRunnerConfig(raw);
    return {
      config,
    } satisfies RunnerConfigService;
  });

/** Live layer for basic runner configuration resolution. */
export const RunnerConfigLive = (
  input: RunnerConfigResolveInput = {},
): Layer.Layer<
  RunnerConfig,
  RunnerConfigCliArgumentError | InvalidRunnerConfigError
> => Layer.effect(RunnerConfig, makeRunnerConfig(input));

/** Resolve the effective runner configuration from the current environment. */
export const getRunnerConfig = () =>
  Effect.gen(function* () {
    const service = yield* RunnerConfig;
    return service.config;
  });

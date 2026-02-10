import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";

const NonNegativeIntSchema = Schema.NonNegativeInt;
const NullableNonNegativeIntSchema = Schema.NullOr(NonNegativeIntSchema);

export const RpcServerConfigSchema = Schema.Struct({
  enabled: Schema.Boolean,
  host: Schema.String,
  port: NonNegativeIntSchema,
  websocketPort: NullableNonNegativeIntSchema,
  timeoutMs: NonNegativeIntSchema,
  requestQueueLimit: NonNegativeIntSchema,
  maxBatchSize: NonNegativeIntSchema,
  maxRequestBodySize: NullableNonNegativeIntSchema,
  maxBatchResponseBodySize: NullableNonNegativeIntSchema,
  strictHexFormat: Schema.Boolean,
});

export type RpcServerConfigInput = Schema.Schema.Encoded<
  typeof RpcServerConfigSchema
>;

export type RpcServerConfigData = Schema.Schema.Type<
  typeof RpcServerConfigSchema
>;

export const RpcServerConfigDefaults: RpcServerConfigInput = {
  enabled: false,
  host: "127.0.0.1",
  port: 8545,
  websocketPort: null,
  timeoutMs: 20_000,
  requestQueueLimit: 500,
  maxBatchSize: 1024,
  maxRequestBodySize: 30_000_000,
  maxBatchResponseBodySize: 33_554_432,
  strictHexFormat: true,
};

/** Error raised when RPC server configuration is invalid. */
export class InvalidRpcServerConfigError extends Data.TaggedError(
  "InvalidRpcServerConfigError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const decodeRpcServerConfig = (input: RpcServerConfigInput) =>
  Schema.decode(RpcServerConfigSchema)(input).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidRpcServerConfigError({
          message: "Invalid RpcServerConfig",
          cause,
        }),
    ),
  );

export interface RpcServerConfigService {
  readonly config: RpcServerConfigData;
  readonly effectiveWebsocketPort: () => number;
}

/** Context tag for the RPC server configuration service. */
export class RpcServerConfig extends Context.Tag("RpcServerConfig")<
  RpcServerConfig,
  RpcServerConfigService
>() {}

const makeRpcServerConfig = (input: RpcServerConfigInput) =>
  Effect.gen(function* () {
    const config = yield* decodeRpcServerConfig(input);
    return {
      config,
      effectiveWebsocketPort: () => config.websocketPort ?? config.port,
    } satisfies RpcServerConfigService;
  });

/** Production RPC server configuration layer. */
export const RpcServerConfigLive = (
  input: RpcServerConfigInput = RpcServerConfigDefaults,
): Layer.Layer<RpcServerConfig, InvalidRpcServerConfigError> =>
  Layer.effect(RpcServerConfig, makeRpcServerConfig(input));

/** Resolve the effective WebSocket port for the current RPC configuration. */
export const effectiveWebsocketPort = () =>
  Effect.gen(function* () {
    const config = yield* RpcServerConfig;
    return config.effectiveWebsocketPort();
  });

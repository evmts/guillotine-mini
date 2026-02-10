import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";

const ENGINE_METHOD_PREFIX = "engine_";
const EXCHANGE_CAPABILITIES_METHOD = "engine_exchangeCapabilities";
const VERSIONED_ENGINE_METHOD_PATTERN = /V\d+$/;

/** Source location of a capability entry being validated. */
export type EngineCapabilitySource = "request" | "response";

/** Validation reasons for malformed `engine_exchangeCapabilities` entries. */
export type InvalidEngineCapabilityReason =
  | "NonEngineNamespace"
  | "ExchangeCapabilitiesNotAllowed"
  | "MissingVersionSuffix";

/** Error raised when a capability entry violates Engine API invariants. */
export class InvalidEngineCapabilityMethodError extends Data.TaggedError(
  "InvalidEngineCapabilityMethodError",
)<{
  readonly source: EngineCapabilitySource;
  readonly method: string;
  readonly reason: InvalidEngineCapabilityReason;
}> {}

/** Service contract for Engine API capability exchange. */
export interface EngineCapabilitiesService {
  readonly exchangeCapabilities: (
    consensusClientMethods: ReadonlyArray<string>,
  ) => Effect.Effect<ReadonlyArray<string>, InvalidEngineCapabilityMethodError>;
}

/** Context tag for `engine_exchangeCapabilities` behavior. */
export class EngineCapabilities extends Context.Tag("EngineCapabilities")<
  EngineCapabilities,
  EngineCapabilitiesService
>() {}

/** Paris baseline capabilities advertised by the execution client. */
export const ParisEngineCapabilities = [
  "engine_newPayloadV1",
  "engine_forkchoiceUpdatedV1",
  "engine_getPayloadV1",
  "engine_exchangeTransitionConfigurationV1",
  "engine_getClientVersionV1",
] as const satisfies ReadonlyArray<string>;

const validateCapabilityMethod = (
  source: EngineCapabilitySource,
  method: string,
) =>
  Effect.gen(function* () {
    if (!method.startsWith(ENGINE_METHOD_PREFIX)) {
      return yield* Effect.fail(
        new InvalidEngineCapabilityMethodError({
          source,
          method,
          reason: "NonEngineNamespace",
        }),
      );
    }

    if (method === EXCHANGE_CAPABILITIES_METHOD) {
      return yield* Effect.fail(
        new InvalidEngineCapabilityMethodError({
          source,
          method,
          reason: "ExchangeCapabilitiesNotAllowed",
        }),
      );
    }

    if (!VERSIONED_ENGINE_METHOD_PATTERN.test(method)) {
      return yield* Effect.fail(
        new InvalidEngineCapabilityMethodError({
          source,
          method,
          reason: "MissingVersionSuffix",
        }),
      );
    }
  });

const validateCapabilityList = (
  source: EngineCapabilitySource,
  methods: ReadonlyArray<string>,
) =>
  Effect.gen(function* () {
    yield* Effect.forEach(
      methods,
      (method) => validateCapabilityMethod(source, method),
      { concurrency: 1, discard: true },
    );
  });

const cloneCapabilities = (
  methods: ReadonlyArray<string>,
): ReadonlyArray<string> => [...methods];

const makeEngineCapabilities = (
  supportedExecutionMethods: ReadonlyArray<string>,
) =>
  Effect.gen(function* () {
    yield* validateCapabilityList("response", supportedExecutionMethods);
    const advertisedMethods = cloneCapabilities(supportedExecutionMethods);

    const exchangeCapabilities = (
      consensusClientMethods: ReadonlyArray<string>,
    ) =>
      Effect.gen(function* () {
        yield* validateCapabilityList("request", consensusClientMethods);
        return cloneCapabilities(advertisedMethods);
      });

    return {
      exchangeCapabilities,
    } satisfies EngineCapabilitiesService;
  });

/** Live Engine capability exchange layer with configured advertised methods. */
export const EngineCapabilitiesLive = (
  supportedExecutionMethods: ReadonlyArray<string>,
) =>
  Layer.effect(
    EngineCapabilities,
    makeEngineCapabilities(supportedExecutionMethods),
  );

/** Perform `engine_exchangeCapabilities` with the configured service. */
export const exchangeCapabilities = (
  consensusClientMethods: ReadonlyArray<string>,
) =>
  Effect.gen(function* () {
    const service = yield* EngineCapabilities;
    return yield* service.exchangeCapabilities(consensusClientMethods);
  });

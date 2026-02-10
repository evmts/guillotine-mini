import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";

/** First message ID available to negotiated subprotocol capabilities. */
export const RlpxCapabilityMessageIdStart = 0x10;

/** Capability entry advertised in the p2p Hello message. */
export interface RlpxHelloCapability {
  readonly name: string;
  readonly version: number;
}

/** Local capability definition including static message-ID space requirements. */
export interface RlpxHelloCapabilityDescriptor extends RlpxHelloCapability {
  readonly messageIdSpaceSize: number;
}

/** Negotiated shared capability plus assigned message-ID offset. */
export interface RlpxNegotiatedCapability extends RlpxHelloCapabilityDescriptor {
  readonly messageIdOffset: number;
  readonly messageIdRangeEnd: number;
}

/** Result of p2p Hello capability negotiation. */
export interface RlpxHelloCapabilityNegotiationResult {
  readonly negotiatedCapabilities: ReadonlyArray<RlpxNegotiatedCapability>;
  readonly nextMessageId: number;
}

/** Validation failure reason when checking local or remote Hello capabilities. */
export type RlpxHelloCapabilityValidationReason =
  | "CapabilityNameEmpty"
  | "CapabilityNameTooLong"
  | "CapabilityNameNonAscii"
  | "CapabilityNameNonPrintableAscii"
  | "InvalidVersion"
  | "InvalidMessageIdSpaceSize"
  | "DuplicateCapabilityWithDifferentMessageSpace";

/** Error raised when local or remote capability entries violate RLPx constraints. */
export class RlpxHelloCapabilityValidationError extends Data.TaggedError(
  "RlpxHelloCapabilityValidationError",
)<{
  readonly source: "local" | "remote";
  readonly capabilityName: string;
  readonly capabilityVersion: number;
  readonly reason: RlpxHelloCapabilityValidationReason;
}> {}

/** Error raised when negotiated message-ID assignment would overflow number bounds. */
export class RlpxHelloMessageIdAllocationError extends Data.TaggedError(
  "RlpxHelloMessageIdAllocationError",
)<{
  readonly capabilityName: string;
  readonly capabilityVersion: number;
  readonly nextMessageId: number;
  readonly messageIdSpaceSize: number;
}> {}

/** Errors emitted when validating and assigning RLPx capability message-ID space. */
export type RlpxHelloCapabilityNegotiationError =
  | RlpxHelloCapabilityValidationError
  | RlpxHelloMessageIdAllocationError;

/** Service contract for p2p Hello capability negotiation and ID-space assignment. */
export interface RlpxHelloCapabilityNegotiatorService {
  readonly negotiate: (
    localCapabilities: ReadonlyArray<RlpxHelloCapabilityDescriptor>,
    remoteCapabilities: ReadonlyArray<RlpxHelloCapability>,
  ) => Effect.Effect<
    RlpxHelloCapabilityNegotiationResult,
    RlpxHelloCapabilityNegotiationError
  >;
}

/** Context tag for the RLPx Hello capability negotiator. */
export class RlpxHelloCapabilityNegotiator extends Context.Tag(
  "RlpxHelloCapabilityNegotiator",
)<RlpxHelloCapabilityNegotiator, RlpxHelloCapabilityNegotiatorService>() {}

const RlpxCapabilityNameMaxLength = 8;

const capabilityKey = (name: string, version: number): string =>
  `${name}\u0000${version}`;

interface CapabilityValidationContext {
  readonly source: "local" | "remote";
  readonly capabilityName: string;
  readonly capabilityVersion: number;
  readonly reason: RlpxHelloCapabilityValidationReason;
}

const failCapabilityValidation = (
  context: CapabilityValidationContext,
): Effect.Effect<never, RlpxHelloCapabilityValidationError> =>
  Effect.fail(new RlpxHelloCapabilityValidationError(context));

const compareCapabilityNames = (left: string, right: string): number => {
  if (left < right) {
    return -1;
  }

  if (left > right) {
    return 1;
  }

  return 0;
};

const validateCapabilityName = (
  source: "local" | "remote",
  capabilityName: string,
  capabilityVersion: number,
): Effect.Effect<void, RlpxHelloCapabilityValidationError> =>
  Effect.gen(function* () {
    if (capabilityName.length === 0) {
      return yield* failCapabilityValidation({
        source,
        capabilityName,
        capabilityVersion,
        reason: "CapabilityNameEmpty",
      });
    }

    if (capabilityName.length > RlpxCapabilityNameMaxLength) {
      return yield* failCapabilityValidation({
        source,
        capabilityName,
        capabilityVersion,
        reason: "CapabilityNameTooLong",
      });
    }

    for (let index = 0; index < capabilityName.length; index += 1) {
      const code = capabilityName.charCodeAt(index);

      if (code > 0x7f) {
        return yield* failCapabilityValidation({
          source,
          capabilityName,
          capabilityVersion,
          reason: "CapabilityNameNonAscii",
        });
      }

      if (code < 0x21 || code === 0x7f) {
        return yield* failCapabilityValidation({
          source,
          capabilityName,
          capabilityVersion,
          reason: "CapabilityNameNonPrintableAscii",
        });
      }
    }
  });

const validateCapabilityVersion = (
  source: "local" | "remote",
  capability: RlpxHelloCapability,
): Effect.Effect<void, RlpxHelloCapabilityValidationError> =>
  Effect.gen(function* () {
    if (!Number.isSafeInteger(capability.version) || capability.version < 0) {
      return yield* failCapabilityValidation({
        source,
        capabilityName: capability.name,
        capabilityVersion: capability.version,
        reason: "InvalidVersion",
      });
    }
  });

const validateMessageIdSpaceSize = (
  capability: RlpxHelloCapabilityDescriptor,
): Effect.Effect<void, RlpxHelloCapabilityValidationError> =>
  Effect.gen(function* () {
    if (
      !Number.isSafeInteger(capability.messageIdSpaceSize) ||
      capability.messageIdSpaceSize <= 0
    ) {
      return yield* failCapabilityValidation({
        source: "local",
        capabilityName: capability.name,
        capabilityVersion: capability.version,
        reason: "InvalidMessageIdSpaceSize",
      });
    }
  });

const validateRemoteCapability = (
  capability: RlpxHelloCapability,
): Effect.Effect<void, RlpxHelloCapabilityValidationError> =>
  Effect.gen(function* () {
    yield* validateCapabilityName(
      "remote",
      capability.name,
      capability.version,
    );
    yield* validateCapabilityVersion("remote", capability);
  });

const validateLocalCapability = (
  capability: RlpxHelloCapabilityDescriptor,
): Effect.Effect<void, RlpxHelloCapabilityValidationError> =>
  Effect.gen(function* () {
    yield* validateCapabilityName("local", capability.name, capability.version);
    yield* validateCapabilityVersion("local", capability);
    yield* validateMessageIdSpaceSize(capability);
  });

const makeRlpxHelloCapabilityNegotiator =
  Effect.succeed<RlpxHelloCapabilityNegotiatorService>({
    negotiate: (localCapabilities, remoteCapabilities) =>
      Effect.gen(function* () {
        const localCapabilityByKey = new Map<
          string,
          RlpxHelloCapabilityDescriptor
        >();

        for (const localCapability of localCapabilities) {
          yield* validateLocalCapability(localCapability);

          const key = capabilityKey(
            localCapability.name,
            localCapability.version,
          );
          const existing = localCapabilityByKey.get(key);

          if (
            existing !== undefined &&
            existing.messageIdSpaceSize !== localCapability.messageIdSpaceSize
          ) {
            return yield* failCapabilityValidation({
              source: "local",
              capabilityName: localCapability.name,
              capabilityVersion: localCapability.version,
              reason: "DuplicateCapabilityWithDifferentMessageSpace",
            });
          }

          if (existing === undefined) {
            localCapabilityByKey.set(key, localCapability);
          }
        }

        const highestSharedVersionByName = new Map<string, number>();

        for (const remoteCapability of remoteCapabilities) {
          yield* validateRemoteCapability(remoteCapability);

          const key = capabilityKey(
            remoteCapability.name,
            remoteCapability.version,
          );
          if (!localCapabilityByKey.has(key)) {
            continue;
          }

          const previous = highestSharedVersionByName.get(
            remoteCapability.name,
          );
          if (previous === undefined || remoteCapability.version > previous) {
            highestSharedVersionByName.set(
              remoteCapability.name,
              remoteCapability.version,
            );
          }
        }

        const negotiatedDescriptors: Array<RlpxHelloCapabilityDescriptor> = [];
        for (const [
          capabilityName,
          capabilityVersion,
        ] of highestSharedVersionByName) {
          const descriptor = localCapabilityByKey.get(
            capabilityKey(capabilityName, capabilityVersion),
          );

          if (descriptor !== undefined) {
            negotiatedDescriptors.push(descriptor);
          }
        }

        negotiatedDescriptors.sort((left, right) =>
          compareCapabilityNames(left.name, right.name),
        );

        const negotiatedCapabilities: Array<RlpxNegotiatedCapability> = [];
        let nextMessageId = RlpxCapabilityMessageIdStart;

        for (const capability of negotiatedDescriptors) {
          if (
            nextMessageId >
            Number.MAX_SAFE_INTEGER - capability.messageIdSpaceSize
          ) {
            return yield* Effect.fail(
              new RlpxHelloMessageIdAllocationError({
                capabilityName: capability.name,
                capabilityVersion: capability.version,
                nextMessageId,
                messageIdSpaceSize: capability.messageIdSpaceSize,
              }),
            );
          }

          const messageIdOffset = nextMessageId;
          const messageIdRangeEnd =
            messageIdOffset + capability.messageIdSpaceSize - 1;

          negotiatedCapabilities.push({
            ...capability,
            messageIdOffset,
            messageIdRangeEnd,
          });

          nextMessageId += capability.messageIdSpaceSize;
        }

        return {
          negotiatedCapabilities,
          nextMessageId,
        } satisfies RlpxHelloCapabilityNegotiationResult;
      }),
  } satisfies RlpxHelloCapabilityNegotiatorService);

/** Live RLPx Hello capability negotiator layer. */
export const RlpxHelloCapabilityNegotiatorLive: Layer.Layer<RlpxHelloCapabilityNegotiator> =
  Layer.effect(
    RlpxHelloCapabilityNegotiator,
    makeRlpxHelloCapabilityNegotiator,
  );

/** Test RLPx Hello capability negotiator layer. */
export const RlpxHelloCapabilityNegotiatorTest: Layer.Layer<RlpxHelloCapabilityNegotiator> =
  RlpxHelloCapabilityNegotiatorLive;

/** Negotiate shared Hello capabilities and assign deterministic message-ID offsets. */
export const negotiateRlpxHelloCapabilities = (
  localCapabilities: ReadonlyArray<RlpxHelloCapabilityDescriptor>,
  remoteCapabilities: ReadonlyArray<RlpxHelloCapability>,
) =>
  Effect.gen(function* () {
    const negotiator = yield* RlpxHelloCapabilityNegotiator;
    return yield* negotiator.negotiate(localCapabilities, remoteCapabilities);
  });

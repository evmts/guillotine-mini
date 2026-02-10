import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { BlockHash } from "voltaire-effect/primitives";
import { FullSyncPeerRequestLimits } from "./FullSyncPeerRequestLimits";

type BlockHashType = BlockHash.BlockHashType;

/** Request-id support starts at eth/66 (EIP-2481). */
export const EthRequestIdProtocolVersion = 66;
/** Partial receipts support starts at eth/70 (EIP-7975). */
export const EthPartialReceiptsProtocolVersion = 70;
/** Highest ETH protocol version supported by this planner. */
export const EthSupportedProtocolVersionMax = EthPartialReceiptsProtocolVersion;

const EthRequestIdModulo = 1n << 64n;
const EthRequestIdMaxInclusive = EthRequestIdModulo - 1n;

/** Validation failures returned by full-sync request planning. */
export type FullSyncRequestPlannerErrorReason =
  | "InvalidProtocolVersion"
  | "InvalidTotalHeaders"
  | "InvalidStartBlockNumber"
  | "InvalidSkip"
  | "HeaderRangeUnderflow"
  | "InvalidInitialRequestId"
  | "InvalidPeerLimit";

/** Error raised when full-sync request planning input is invalid. */
export class FullSyncRequestPlannerError extends Data.TaggedError(
  "FullSyncRequestPlannerError",
)<{
  readonly reason: FullSyncRequestPlannerErrorReason;
  readonly field?: string;
}> {}

/** Header batch input for planning bounded `GetBlockHeaders` requests. */
export interface FullSyncHeaderRequestPlanInput {
  readonly peerClientId: string | undefined;
  readonly protocolVersion: number;
  readonly startBlockNumber: bigint;
  readonly totalHeaders: number;
  readonly skip?: number;
  readonly reverse?: boolean;
  readonly initialRequestId?: bigint;
}

/** Hash-list input for planning bounded `GetBlockBodies` / `GetReceipts` requests. */
export interface FullSyncHashRequestPlanInput {
  readonly peerClientId: string | undefined;
  readonly protocolVersion: number;
  readonly blockHashes: ReadonlyArray<BlockHashType>;
  readonly initialRequestId?: bigint;
}

/** Planned `GetBlockHeaders` request batch. */
export interface FullSyncHeaderRequestBatch {
  readonly requestId?: bigint;
  readonly startBlockNumber: bigint;
  readonly limit: number;
  readonly skip: number;
  readonly reverse: boolean;
}

/** Planned `GetBlockBodies` request batch. */
export interface FullSyncBodyRequestBatch {
  readonly requestId?: bigint;
  readonly blockHashes: ReadonlyArray<BlockHashType>;
}

/** Planned `GetReceipts` request batch. */
export interface FullSyncReceiptsRequestBatch {
  readonly requestId?: bigint;
  readonly firstBlockReceiptIndex?: bigint;
  readonly blockHashes: ReadonlyArray<BlockHashType>;
}

/** Service contract for full-sync request batching by peer-specific limits. */
export interface FullSyncRequestPlannerService {
  readonly planHeaderRequests: (
    input: FullSyncHeaderRequestPlanInput,
  ) => Effect.Effect<
    ReadonlyArray<FullSyncHeaderRequestBatch>,
    FullSyncRequestPlannerError
  >;
  readonly planBodyRequests: (
    input: FullSyncHashRequestPlanInput,
  ) => Effect.Effect<
    ReadonlyArray<FullSyncBodyRequestBatch>,
    FullSyncRequestPlannerError
  >;
  readonly planReceiptRequests: (
    input: FullSyncHashRequestPlanInput,
  ) => Effect.Effect<
    ReadonlyArray<FullSyncReceiptsRequestBatch>,
    FullSyncRequestPlannerError
  >;
}

/** Context tag for full-sync request planning. */
export class FullSyncRequestPlanner extends Context.Tag(
  "FullSyncRequestPlanner",
)<FullSyncRequestPlanner, FullSyncRequestPlannerService>() {}

interface RequestIdState {
  readonly enabled: boolean;
  readonly next: bigint;
}

const failPlanner = (
  reason: FullSyncRequestPlannerErrorReason,
  field?: string,
) =>
  Effect.fail(
    new FullSyncRequestPlannerError({
      reason,
      field,
    }),
  );

const supportsRequestId = (protocolVersion: number): boolean =>
  protocolVersion >= EthRequestIdProtocolVersion;

const supportsPartialReceipts = (protocolVersion: number): boolean =>
  protocolVersion >= EthPartialReceiptsProtocolVersion;

const validateProtocolVersion = (
  protocolVersion: number,
): Effect.Effect<void, FullSyncRequestPlannerError> =>
  Number.isInteger(protocolVersion) &&
  protocolVersion >= 0 &&
  protocolVersion <= EthSupportedProtocolVersionMax
    ? Effect.void
    : failPlanner("InvalidProtocolVersion", "protocolVersion");

const validatePositiveInteger = (
  value: number,
  field: string,
  reason:
    | "InvalidTotalHeaders"
    | "InvalidSkip"
    | "InvalidPeerLimit"
    | "InvalidProtocolVersion",
): Effect.Effect<void, FullSyncRequestPlannerError> =>
  Number.isInteger(value) && value >= 0
    ? Effect.void
    : failPlanner(reason, field);

const validateInitialRequestId = (
  initialRequestId: bigint,
): Effect.Effect<void, FullSyncRequestPlannerError> =>
  initialRequestId >= 0n && initialRequestId <= EthRequestIdMaxInclusive
    ? Effect.void
    : failPlanner("InvalidInitialRequestId", "initialRequestId");

const initializeRequestIdState = ({
  protocolVersion,
  initialRequestId,
}: {
  readonly protocolVersion: number;
  readonly initialRequestId: bigint | undefined;
}): Effect.Effect<RequestIdState, FullSyncRequestPlannerError> =>
  Effect.gen(function* () {
    yield* validateProtocolVersion(protocolVersion);

    if (!supportsRequestId(protocolVersion)) {
      return {
        enabled: false,
        next: 0n,
      };
    }

    const firstRequestId = initialRequestId ?? 0n;
    yield* validateInitialRequestId(firstRequestId);

    return {
      enabled: true,
      next: firstRequestId,
    };
  });

const popRequestId = (
  state: RequestIdState,
): readonly [bigint | undefined, RequestIdState] => {
  if (!state.enabled) {
    return [undefined, state];
  }

  const requestId = state.next;
  return [
    requestId,
    {
      ...state,
      next: (requestId + 1n) % EthRequestIdModulo,
    },
  ] as const;
};

const validateLimit = (
  limit: number,
  field: string,
): Effect.Effect<void, FullSyncRequestPlannerError> =>
  Number.isInteger(limit) && limit > 0
    ? Effect.void
    : failPlanner("InvalidPeerLimit", field);

const validateHeaderInput = (
  input: FullSyncHeaderRequestPlanInput,
  reverse: boolean,
  skip: number,
): Effect.Effect<void, FullSyncRequestPlannerError> =>
  Effect.gen(function* () {
    yield* validatePositiveInteger(
      input.totalHeaders,
      "totalHeaders",
      "InvalidTotalHeaders",
    );

    if (input.startBlockNumber < 0n) {
      return yield* failPlanner("InvalidStartBlockNumber", "startBlockNumber");
    }

    yield* validatePositiveInteger(skip, "skip", "InvalidSkip");

    if (reverse && input.totalHeaders > 0) {
      const step = BigInt(skip + 1);
      const deepestOffset = BigInt(input.totalHeaders - 1) * step;
      if (deepestOffset > input.startBlockNumber) {
        return yield* failPlanner("HeaderRangeUnderflow", "startBlockNumber");
      }
    }
  });

const planHeaderBatches = ({
  startBlockNumber,
  totalHeaders,
  skip,
  reverse,
  maxHeadersPerRequest,
  requestIds,
}: {
  readonly startBlockNumber: bigint;
  readonly totalHeaders: number;
  readonly skip: number;
  readonly reverse: boolean;
  readonly maxHeadersPerRequest: number;
  readonly requestIds: RequestIdState;
}): ReadonlyArray<FullSyncHeaderRequestBatch> => {
  if (totalHeaders === 0) {
    return [];
  }

  const step = BigInt(skip + 1);
  let currentStart = startBlockNumber;
  let remaining = totalHeaders;
  let state = requestIds;

  const batches: Array<FullSyncHeaderRequestBatch> = [];

  while (remaining > 0) {
    const limit = Math.min(remaining, maxHeadersPerRequest);
    const [requestId, nextState] = popRequestId(state);
    state = nextState;

    batches.push({
      requestId,
      startBlockNumber: currentStart,
      limit,
      skip,
      reverse,
    });

    remaining -= limit;
    const shift = BigInt(limit) * step;
    currentStart = reverse ? currentStart - shift : currentStart + shift;
  }

  return batches;
};

const planHashBatches = <T extends FullSyncBodyRequestBatch>({
  blockHashes,
  maxPerRequest,
  requestIds,
  createBatch,
}: {
  readonly blockHashes: ReadonlyArray<BlockHashType>;
  readonly maxPerRequest: number;
  readonly requestIds: RequestIdState;
  readonly createBatch: (
    requestId: bigint | undefined,
    blockHashes: ReadonlyArray<BlockHashType>,
  ) => T;
}): ReadonlyArray<T> => {
  if (blockHashes.length === 0) {
    return [];
  }

  let state = requestIds;
  const batches: Array<T> = [];

  for (let index = 0; index < blockHashes.length; index += maxPerRequest) {
    const [requestId, nextState] = popRequestId(state);
    state = nextState;

    batches.push(
      createBatch(requestId, blockHashes.slice(index, index + maxPerRequest)),
    );
  }

  return batches;
};

const makeFullSyncRequestPlanner = Effect.gen(function* () {
  const limitsService = yield* FullSyncPeerRequestLimits;

  return {
    planHeaderRequests: (input) =>
      Effect.gen(function* () {
        const reverse = input.reverse ?? true;
        const skip = input.skip ?? 0;

        yield* validateHeaderInput(input, reverse, skip);

        const limits = yield* limitsService.resolve(input.peerClientId);
        yield* validateLimit(
          limits.maxHeadersPerRequest,
          "maxHeadersPerRequest",
        );

        const requestIds = yield* initializeRequestIdState({
          protocolVersion: input.protocolVersion,
          initialRequestId: input.initialRequestId,
        });

        return planHeaderBatches({
          startBlockNumber: input.startBlockNumber,
          totalHeaders: input.totalHeaders,
          skip,
          reverse,
          maxHeadersPerRequest: limits.maxHeadersPerRequest,
          requestIds,
        });
      }),

    planBodyRequests: (input) =>
      Effect.gen(function* () {
        const limits = yield* limitsService.resolve(input.peerClientId);
        yield* validateLimit(limits.maxBodiesPerRequest, "maxBodiesPerRequest");

        const requestIds = yield* initializeRequestIdState({
          protocolVersion: input.protocolVersion,
          initialRequestId: input.initialRequestId,
        });

        return planHashBatches({
          blockHashes: input.blockHashes,
          maxPerRequest: limits.maxBodiesPerRequest,
          requestIds,
          createBatch: (requestId, blockHashes) => ({
            requestId,
            blockHashes,
          }),
        });
      }),

    planReceiptRequests: (input) =>
      Effect.gen(function* () {
        yield* validateProtocolVersion(input.protocolVersion);

        const limits = yield* limitsService.resolve(input.peerClientId);
        yield* validateLimit(
          limits.maxReceiptsPerRequest,
          "maxReceiptsPerRequest",
        );

        const requestIds = yield* initializeRequestIdState({
          protocolVersion: input.protocolVersion,
          initialRequestId: input.initialRequestId,
        });

        return planHashBatches({
          blockHashes: input.blockHashes,
          maxPerRequest: limits.maxReceiptsPerRequest,
          requestIds,
          createBatch: (requestId, blockHashes) =>
            supportsPartialReceipts(input.protocolVersion)
              ? {
                  requestId,
                  firstBlockReceiptIndex: 0n,
                  blockHashes,
                }
              : {
                  requestId,
                  blockHashes,
                },
        });
      }),
  } satisfies FullSyncRequestPlannerService;
});

/** Live full-sync request planner layer. */
export const FullSyncRequestPlannerLive: Layer.Layer<
  FullSyncRequestPlanner,
  never,
  FullSyncPeerRequestLimits
> = Layer.effect(FullSyncRequestPlanner, makeFullSyncRequestPlanner);

/** Resolve full-sync `GetBlockHeaders` batches for a peer and protocol version. */
export const planFullSyncHeaderRequests = (
  input: FullSyncHeaderRequestPlanInput,
) =>
  Effect.gen(function* () {
    const planner = yield* FullSyncRequestPlanner;
    return yield* planner.planHeaderRequests(input);
  });

/** Resolve full-sync `GetBlockBodies` batches for a peer and protocol version. */
export const planFullSyncBodyRequests = (input: FullSyncHashRequestPlanInput) =>
  Effect.gen(function* () {
    const planner = yield* FullSyncRequestPlanner;
    return yield* planner.planBodyRequests(input);
  });

/** Resolve full-sync `GetReceipts` batches for a peer and protocol version. */
export const planFullSyncReceiptRequests = (
  input: FullSyncHashRequestPlanInput,
) =>
  Effect.gen(function* () {
    const planner = yield* FullSyncRequestPlanner;
    return yield* planner.planReceiptRequests(input);
  });

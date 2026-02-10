import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";

/** Peer client families recognized for full-sync request sizing. */
export type FullSyncPeerClientFamily =
  | "besu"
  | "geth"
  | "nethermind"
  | "openethereum"
  | "parity"
  | "trinity"
  | "erigon"
  | "reth"
  | "unknown";

/** Per-request ETH sync limits for headers, block bodies, and receipts. */
export interface FullSyncPeerRequestLimitsValue {
  readonly maxHeadersPerRequest: number;
  readonly maxBodiesPerRequest: number;
  readonly maxReceiptsPerRequest: number;
}

/** Service contract for selecting peer-specific full-sync request limits. */
export interface FullSyncPeerRequestLimitsService {
  readonly resolve: (
    peerClientId: string | undefined,
  ) => Effect.Effect<FullSyncPeerRequestLimitsValue>;
}

/** Context tag for the full-sync peer request limits service. */
export class FullSyncPeerRequestLimits extends Context.Tag(
  "FullSyncPeerRequestLimits",
)<FullSyncPeerRequestLimits, FullSyncPeerRequestLimitsService>() {}

const limitsByFamily = {
  besu: {
    maxHeadersPerRequest: 512,
    maxBodiesPerRequest: 128,
    maxReceiptsPerRequest: 256,
  },
  geth: {
    maxHeadersPerRequest: 192,
    maxBodiesPerRequest: 128,
    maxReceiptsPerRequest: 256,
  },
  nethermind: {
    maxHeadersPerRequest: 512,
    maxBodiesPerRequest: 256,
    maxReceiptsPerRequest: 256,
  },
  openethereum: {
    maxHeadersPerRequest: 1024,
    maxBodiesPerRequest: 256,
    maxReceiptsPerRequest: 256,
  },
  parity: {
    maxHeadersPerRequest: 1024,
    maxBodiesPerRequest: 256,
    maxReceiptsPerRequest: 256,
  },
  trinity: {
    maxHeadersPerRequest: 192,
    maxBodiesPerRequest: 128,
    maxReceiptsPerRequest: 256,
  },
  erigon: {
    maxHeadersPerRequest: 192,
    maxBodiesPerRequest: 128,
    maxReceiptsPerRequest: 256,
  },
  reth: {
    maxHeadersPerRequest: 192,
    maxBodiesPerRequest: 128,
    maxReceiptsPerRequest: 256,
  },
  unknown: {
    maxHeadersPerRequest: 192,
    maxBodiesPerRequest: 32,
    maxReceiptsPerRequest: 128,
  },
} as const satisfies Record<
  FullSyncPeerClientFamily,
  FullSyncPeerRequestLimitsValue
>;

const normalizeClientId = (peerClientId: string | undefined): string =>
  (peerClientId ?? "").trim().toLowerCase();

const toClientFamily = (
  peerClientId: string | undefined,
): FullSyncPeerClientFamily => {
  const normalized = normalizeClientId(peerClientId);

  if (normalized.startsWith("besu/")) {
    return "besu";
  }

  if (normalized.startsWith("geth/")) {
    return "geth";
  }

  if (normalized.startsWith("nethermind/")) {
    return "nethermind";
  }

  if (normalized.startsWith("openethereum/")) {
    return "openethereum";
  }

  if (
    normalized.startsWith("parity/") ||
    normalized.startsWith("parity-ethereum/")
  ) {
    return "parity";
  }

  if (normalized.startsWith("trinity/")) {
    return "trinity";
  }

  if (normalized.startsWith("erigon/")) {
    return "erigon";
  }

  if (normalized.startsWith("reth/")) {
    return "reth";
  }

  return "unknown";
};

const makeFullSyncPeerRequestLimits =
  Effect.succeed<FullSyncPeerRequestLimitsService>({
    resolve: (peerClientId) =>
      Effect.succeed(limitsByFamily[toClientFamily(peerClientId)]),
  } satisfies FullSyncPeerRequestLimitsService);

/** Live full-sync peer request limits layer. */
export const FullSyncPeerRequestLimitsLive: Layer.Layer<FullSyncPeerRequestLimits> =
  Layer.effect(FullSyncPeerRequestLimits, makeFullSyncPeerRequestLimits);

/** Deterministic full-sync peer request limits layer for tests. */
export const FullSyncPeerRequestLimitsTest: Layer.Layer<FullSyncPeerRequestLimits> =
  FullSyncPeerRequestLimitsLive;

/** Resolve per-peer ETH request-size limits used by full sync. */
export const resolveFullSyncPeerRequestLimits = (
  peerClientId: string | undefined,
) =>
  Effect.gen(function* () {
    const service = yield* FullSyncPeerRequestLimits;
    return yield* service.resolve(peerClientId);
  });

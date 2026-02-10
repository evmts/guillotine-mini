import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { BlockHash } from "voltaire-effect/primitives";
import { FullSyncPeerRequestLimitsLive } from "./FullSyncPeerRequestLimits";
import {
  FullSyncRequestPlannerError,
  FullSyncRequestPlannerLive,
  planFullSyncBodyRequests,
  planFullSyncHeaderRequests,
  planFullSyncReceiptRequests,
} from "./FullSyncRequestPlanner";

type BlockHashType = BlockHash.BlockHashType;

const BlockHashBytesSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;

const blockHashFromByte = (byte: number): BlockHashType =>
  Schema.decodeSync(BlockHashBytesSchema)(new Uint8Array(32).fill(byte));

const makeBlockHashes = (count: number): ReadonlyArray<BlockHashType> =>
  Array.from({ length: count }, (_, index) => blockHashFromByte(index % 256));

const plannerLayer = FullSyncRequestPlannerLive.pipe(
  Layer.provide(FullSyncPeerRequestLimitsLive),
);

const providePlanner = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(plannerLayer));

describe("FullSyncRequestPlanner", () => {
  it.effect(
    "chunks header requests by peer limits and assigns eth/66+ request ids",
    () =>
      providePlanner(
        Effect.gen(function* () {
          const requests = yield* planFullSyncHeaderRequests({
            peerClientId: "Geth/v1.15.11-stable",
            protocolVersion: 69,
            startBlockNumber: 999n,
            totalHeaders: 450,
            reverse: true,
            initialRequestId: 42n,
          });

          assert.deepStrictEqual(requests, [
            {
              requestId: 42n,
              startBlockNumber: 999n,
              limit: 192,
              skip: 0,
              reverse: true,
            },
            {
              requestId: 43n,
              startBlockNumber: 807n,
              limit: 192,
              skip: 0,
              reverse: true,
            },
            {
              requestId: 44n,
              startBlockNumber: 615n,
              limit: 66,
              skip: 0,
              reverse: true,
            },
          ]);
        }),
      ),
  );

  it.effect(
    "omits request ids before eth/66 and advances start with skip in forward mode",
    () =>
      providePlanner(
        Effect.gen(function* () {
          const requests = yield* planFullSyncHeaderRequests({
            peerClientId: "Besu/v24.1.1",
            protocolVersion: 65,
            startBlockNumber: 10n,
            totalHeaders: 513,
            skip: 1,
            reverse: false,
            initialRequestId: 99n,
          });

          assert.strictEqual(requests.length, 2);
          assert.isUndefined(requests[0]?.requestId);
          assert.isUndefined(requests[1]?.requestId);
          assert.deepStrictEqual(requests[0], {
            requestId: undefined,
            startBlockNumber: 10n,
            limit: 512,
            skip: 1,
            reverse: false,
          });
          assert.deepStrictEqual(requests[1], {
            requestId: undefined,
            startBlockNumber: 1034n,
            limit: 1,
            skip: 1,
            reverse: false,
          });
        }),
      ),
  );

  it.effect(
    "returns typed underflow errors when reverse header range would cross below block zero",
    () =>
      providePlanner(
        Effect.gen(function* () {
          const outcome = yield* planFullSyncHeaderRequests({
            peerClientId: "Nethermind/v1.29.0",
            protocolVersion: 69,
            startBlockNumber: 3n,
            totalHeaders: 5,
            reverse: true,
          }).pipe(Effect.either);

          assert.strictEqual(Either.isLeft(outcome), true);
          if (Either.isLeft(outcome)) {
            assert.strictEqual(
              outcome.left instanceof FullSyncRequestPlannerError,
              true,
            );
            assert.strictEqual(outcome.left.reason, "HeaderRangeUnderflow");
            assert.strictEqual(outcome.left.field, "startBlockNumber");
          }
        }),
      ),
  );

  it.effect(
    "chunks body requests with unknown-client fallback limits and eth/66 request ids",
    () =>
      providePlanner(
        Effect.gen(function* () {
          const hashes = makeBlockHashes(70);
          const requests = yield* planFullSyncBodyRequests({
            peerClientId: "UnknownClient/v0.0.1",
            protocolVersion: 66,
            blockHashes: hashes,
            initialRequestId: 7n,
          });

          assert.strictEqual(requests.length, 3);
          assert.strictEqual(requests[0]?.requestId, 7n);
          assert.strictEqual(requests[1]?.requestId, 8n);
          assert.strictEqual(requests[2]?.requestId, 9n);
          assert.strictEqual(requests[0]?.blockHashes.length, 32);
          assert.strictEqual(requests[1]?.blockHashes.length, 32);
          assert.strictEqual(requests[2]?.blockHashes.length, 6);
        }),
      ),
  );

  it.effect(
    "chunks receipt requests by peer limits and omits request ids for eth/65",
    () =>
      providePlanner(
        Effect.gen(function* () {
          const hashes = makeBlockHashes(600);
          const requests = yield* planFullSyncReceiptRequests({
            peerClientId: "Nethermind/v1.29.0",
            protocolVersion: 65,
            blockHashes: hashes,
          });

          assert.strictEqual(requests.length, 3);
          assert.isUndefined(requests[0]?.requestId);
          assert.isUndefined(requests[1]?.requestId);
          assert.isUndefined(requests[2]?.requestId);
          assert.strictEqual(requests[0]?.blockHashes.length, 256);
          assert.strictEqual(requests[1]?.blockHashes.length, 256);
          assert.strictEqual(requests[2]?.blockHashes.length, 88);
        }),
      ),
  );

  it.effect(
    "returns typed errors for invalid protocol versions and out-of-range request ids",
    () =>
      providePlanner(
        Effect.gen(function* () {
          const invalidVersion = yield* planFullSyncBodyRequests({
            peerClientId: "Geth/v1.15.11",
            protocolVersion: -1,
            blockHashes: makeBlockHashes(1),
          }).pipe(Effect.either);

          assert.strictEqual(Either.isLeft(invalidVersion), true);
          if (Either.isLeft(invalidVersion)) {
            assert.strictEqual(
              invalidVersion.left instanceof FullSyncRequestPlannerError,
              true,
            );
            assert.strictEqual(
              invalidVersion.left.reason,
              "InvalidProtocolVersion",
            );
            assert.strictEqual(invalidVersion.left.field, "protocolVersion");
          }

          const invalidRequestId = yield* planFullSyncBodyRequests({
            peerClientId: "Geth/v1.15.11",
            protocolVersion: 69,
            blockHashes: makeBlockHashes(1),
            initialRequestId: 1n << 64n,
          }).pipe(Effect.either);

          assert.strictEqual(Either.isLeft(invalidRequestId), true);
          if (Either.isLeft(invalidRequestId)) {
            assert.strictEqual(
              invalidRequestId.left instanceof FullSyncRequestPlannerError,
              true,
            );
            assert.strictEqual(
              invalidRequestId.left.reason,
              "InvalidInitialRequestId",
            );
            assert.strictEqual(invalidRequestId.left.field, "initialRequestId");
          }
        }),
      ),
  );
});

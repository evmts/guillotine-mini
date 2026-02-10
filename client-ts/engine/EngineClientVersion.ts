import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Hex } from "voltaire-effect/primitives";

const CLIENT_CODE_PATTERN = /^[A-Za-z]{2}$/;
const CLIENT_COMMIT_LENGTH_BYTES = 4;

export type HexType = Parameters<typeof Hex.equals>[0];

/** The Engine API `ClientVersionV1` structure. */
export interface ClientVersionV1 {
  readonly code: string;
  readonly name: string;
  readonly version: string;
  readonly commit: HexType;
}

export type ClientVersionSource = "request" | "response";

export type InvalidClientVersionReason =
  | "InvalidCode"
  | "EmptyName"
  | "EmptyVersion"
  | "InvalidCommitHex"
  | "InvalidCommitLength"
  | "EmptyResponse";

/** Error raised when `ClientVersionV1` payloads violate Engine API shape constraints. */
export class InvalidClientVersionV1Error extends Data.TaggedError(
  "InvalidClientVersionV1Error",
)<{
  readonly source: ClientVersionSource;
  readonly reason: InvalidClientVersionReason;
  readonly value: unknown;
  readonly index?: number;
}> {}

/** Service contract for `engine_getClientVersionV1`. */
export interface EngineClientVersionService {
  readonly getClientVersionV1: (
    consensusClientVersion: ClientVersionV1,
  ) => Effect.Effect<
    ReadonlyArray<ClientVersionV1>,
    InvalidClientVersionV1Error
  >;
}

/** Context tag for Engine API client version exchange. */
export class EngineClientVersion extends Context.Tag("EngineClientVersion")<
  EngineClientVersion,
  EngineClientVersionService
>() {}

/** Default single-client identity for guillotine-mini. */
export const GuillotineMiniClientVersionV1 = {
  code: "GM",
  name: "guillotine-mini",
  version: "0.0.0",
  commit: Hex.fromBytes(new Uint8Array(CLIENT_COMMIT_LENGTH_BYTES)),
} satisfies ClientVersionV1;

/** Default `engine_getClientVersionV1` response list. */
export const DefaultExecutionClientVersionsV1 = [
  GuillotineMiniClientVersionV1,
] as const satisfies ReadonlyArray<ClientVersionV1>;

const failInvalidClientVersion = (
  source: ClientVersionSource,
  reason: InvalidClientVersionReason,
  value: unknown,
  index?: number,
) =>
  Effect.fail(
    new InvalidClientVersionV1Error({ source, reason, value, index }),
  );

const validateClientVersion = (
  source: ClientVersionSource,
  clientVersion: ClientVersionV1,
  index?: number,
) =>
  Effect.gen(function* () {
    if (!CLIENT_CODE_PATTERN.test(clientVersion.code)) {
      return yield* failInvalidClientVersion(
        source,
        "InvalidCode",
        clientVersion.code,
        index,
      );
    }

    if (clientVersion.name.trim().length === 0) {
      return yield* failInvalidClientVersion(
        source,
        "EmptyName",
        clientVersion.name,
        index,
      );
    }

    if (clientVersion.version.trim().length === 0) {
      return yield* failInvalidClientVersion(
        source,
        "EmptyVersion",
        clientVersion.version,
        index,
      );
    }

    const commitBytes = yield* Effect.try({
      try: () => Hex.toBytes(clientVersion.commit),
      catch: () =>
        new InvalidClientVersionV1Error({
          source,
          reason: "InvalidCommitHex",
          value: clientVersion.commit,
          index,
        }),
    });

    if (commitBytes.length !== CLIENT_COMMIT_LENGTH_BYTES) {
      return yield* failInvalidClientVersion(
        source,
        "InvalidCommitLength",
        clientVersion.commit,
        index,
      );
    }
  });

const validateResponseClientVersions = (
  executionClientVersions: ReadonlyArray<ClientVersionV1>,
) =>
  Effect.gen(function* () {
    if (executionClientVersions.length === 0) {
      return yield* failInvalidClientVersion(
        "response",
        "EmptyResponse",
        executionClientVersions,
      );
    }

    yield* Effect.forEach(
      executionClientVersions,
      (clientVersion, index) =>
        validateClientVersion("response", clientVersion, index),
      { concurrency: 1, discard: true },
    );
  });

const makeEngineClientVersion = (
  executionClientVersions: ReadonlyArray<ClientVersionV1>,
) =>
  Effect.gen(function* () {
    yield* validateResponseClientVersions(executionClientVersions);
    const advertisedVersions = executionClientVersions.map((clientVersion) => ({
      ...clientVersion,
    }));

    const getClientVersionV1 = (consensusClientVersion: ClientVersionV1) =>
      Effect.gen(function* () {
        yield* validateClientVersion("request", consensusClientVersion);
        return advertisedVersions.map((clientVersion) => ({
          ...clientVersion,
        }));
      });

    return {
      getClientVersionV1,
    } satisfies EngineClientVersionService;
  });

/** Live Engine client version layer with configured response identities. */
export const EngineClientVersionLive = (
  executionClientVersions: ReadonlyArray<ClientVersionV1>,
) =>
  Layer.effect(
    EngineClientVersion,
    makeEngineClientVersion(executionClientVersions),
  );

/** Execute `engine_getClientVersionV1` with the configured service. */
export const getClientVersionV1 = (consensusClientVersion: ClientVersionV1) =>
  Effect.gen(function* () {
    const service = yield* EngineClientVersion;
    return yield* service.getClientVersionV1(consensusClientVersion);
  });

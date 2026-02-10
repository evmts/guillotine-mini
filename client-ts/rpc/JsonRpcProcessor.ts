import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { JsonRpcRequestDecoder } from "./JsonRpcRequest";
import {
  JsonRpcResponseEncoder,
  type InvalidJsonRpcResponseError,
  type JsonRpcResponseInput,
} from "./JsonRpcResponse";
import { JsonRpcService } from "./JsonRpcService";

class InvalidJsonPayloadError extends Data.TaggedError(
  "InvalidJsonPayloadError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const isSingleJsonRpcPayloadObject = (
  payload: unknown,
): payload is Readonly<Record<string, unknown>> =>
  typeof payload === "object" && payload !== null && !Array.isArray(payload);

const isJsonRpcBatchPayload = (
  payload: unknown,
): payload is ReadonlyArray<unknown> => Array.isArray(payload);

const parsePayload = (payload: unknown) =>
  typeof payload === "string"
    ? Effect.try({
        try: () => JSON.parse(payload) as unknown,
        catch: (cause) =>
          new InvalidJsonPayloadError({
            message: "Invalid JSON payload",
            cause,
          }),
      })
    : Effect.succeed(payload);

export type JsonRpcProcessorResponse =
  | JsonRpcResponseInput
  | ReadonlyArray<JsonRpcResponseInput>;

export interface JsonRpcProcessorService {
  readonly process: (
    payload: unknown,
  ) => Effect.Effect<
    Option.Option<JsonRpcProcessorResponse>,
    InvalidJsonRpcResponseError
  >;
}

/** Context tag for parsing and processing incoming JSON-RPC payloads. */
export class JsonRpcProcessor extends Context.Tag("JsonRpcProcessor")<
  JsonRpcProcessor,
  JsonRpcProcessorService
>() {}

const makeJsonRpcProcessor = () =>
  Effect.gen(function* () {
    const requestDecoder = yield* JsonRpcRequestDecoder;
    const responseEncoder = yield* JsonRpcResponseEncoder;
    const jsonRpcService = yield* JsonRpcService;

    const invalidRequestResponse = () =>
      responseEncoder.errorByName("EIP-1474", "InvalidRequest", null);

    const internalErrorResponse = (id: string | number | null) =>
      responseEncoder.errorByName("EIP-1474", "InternalError", id);

    const recoverUnexpectedDefect = (
      effect: Effect.Effect<
        Option.Option<JsonRpcResponseInput>,
        InvalidJsonRpcResponseError
      >,
      id: string | number | null | undefined,
    ) =>
      effect.pipe(
        Effect.catchAllDefect(() =>
          id === undefined
            ? Effect.succeed(Option.none<JsonRpcResponseInput>())
            : internalErrorResponse(id).pipe(Effect.map(Option.some)),
        ),
      );

    const processSinglePayloadObject = (
      payloadObject: Readonly<Record<string, unknown>>,
    ) =>
      Effect.gen(function* () {
        const decodedRequestOrError = yield* Effect.either(
          requestDecoder.decode(payloadObject),
        );

        if (Either.isLeft(decodedRequestOrError)) {
          return Option.some(yield* invalidRequestResponse());
        }

        return yield* recoverUnexpectedDefect(
          jsonRpcService.sendRequest(decodedRequestOrError.right),
          decodedRequestOrError.right.id,
        );
      }).pipe(
        Effect.catchAllDefect(() =>
          internalErrorResponse(null).pipe(Effect.map(Option.some)),
        ),
      );

    const processBatchPayload = (batchPayload: ReadonlyArray<unknown>) =>
      Effect.gen(function* () {
        if (batchPayload.length === 0) {
          return Option.some(yield* invalidRequestResponse());
        }

        const itemResponses = yield* Effect.forEach(
          batchPayload,
          (batchItem) =>
            isSingleJsonRpcPayloadObject(batchItem)
              ? processSinglePayloadObject(batchItem)
              : invalidRequestResponse().pipe(Effect.map(Option.some)),
          { concurrency: 1 },
        );

        const responses: Array<JsonRpcResponseInput> = [];
        for (const itemResponse of itemResponses) {
          if (Option.isSome(itemResponse)) {
            responses.push(itemResponse.value);
          }
        }

        return responses.length === 0
          ? Option.none<JsonRpcProcessorResponse>()
          : Option.some(responses);
      });

    const process = (payload: unknown) =>
      Effect.gen(function* () {
        const parsedPayloadOrError = yield* Effect.either(
          parsePayload(payload),
        );

        if (Either.isLeft(parsedPayloadOrError)) {
          const parseError = yield* responseEncoder.errorByName(
            "EIP-1474",
            "ParseError",
            null,
          );
          return Option.some(parseError);
        }

        const parsedPayload = parsedPayloadOrError.right;

        if (isSingleJsonRpcPayloadObject(parsedPayload)) {
          return yield* processSinglePayloadObject(parsedPayload);
        }

        if (isJsonRpcBatchPayload(parsedPayload)) {
          return yield* processBatchPayload(parsedPayload);
        }

        return Option.some(yield* invalidRequestResponse());
      }).pipe(
        Effect.catchAllDefect(() =>
          internalErrorResponse(null).pipe(Effect.map(Option.some)),
        ),
      );

    return {
      process,
    } satisfies JsonRpcProcessorService;
  });

export const JsonRpcProcessorLive = Layer.effect(
  JsonRpcProcessor,
  makeJsonRpcProcessor(),
);

export const processJsonRpcPayload = (payload: unknown) =>
  Effect.gen(function* () {
    const processor = yield* JsonRpcProcessor;
    return yield* processor.process(payload);
  });

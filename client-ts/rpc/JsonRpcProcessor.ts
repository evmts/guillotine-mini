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

export interface JsonRpcProcessorService {
  readonly process: (
    payload: unknown,
  ) => Effect.Effect<
    Option.Option<JsonRpcResponseInput>,
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
        if (!isSingleJsonRpcPayloadObject(parsedPayload)) {
          const invalidRequestError = yield* responseEncoder.errorByName(
            "EIP-1474",
            "InvalidRequest",
            null,
          );
          return Option.some(invalidRequestError);
        }

        const decodedRequestOrError = yield* Effect.either(
          requestDecoder.decode(parsedPayload),
        );

        if (Either.isLeft(decodedRequestOrError)) {
          const invalidRequestError = yield* responseEncoder.errorByName(
            "EIP-1474",
            "InvalidRequest",
            null,
          );
          return Option.some(invalidRequestError);
        }

        return yield* jsonRpcService.sendRequest(decodedRequestOrError.right);
      });

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

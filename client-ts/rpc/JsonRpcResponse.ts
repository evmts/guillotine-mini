import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  JsonRpcErrorRegistry,
  type JsonRpcErrorCode,
  type JsonRpcErrorNameBySource,
  type JsonRpcErrorSource,
} from "./JsonRpcErrors";
import { JsonRpcId, JsonRpcIdSchema } from "./JsonRpcRequest";

export const JsonRpcSuccessIdSchema = Schema.Union(
  Schema.String,
  Schema.Number,
);

export type JsonRpcSuccessId = Schema.Schema.Type<
  typeof JsonRpcSuccessIdSchema
>;

export const JsonRpcErrorObjectSchema = Schema.Struct({
  code: Schema.Number,
  message: Schema.String,
  data: Schema.optional(Schema.Unknown),
});

export type JsonRpcErrorObject<Data = unknown> = Readonly<{
  code: JsonRpcErrorCode;
  message: string;
  data?: Data;
}>;

export const JsonRpcResponseSuccessSchema = Schema.Struct({
  jsonrpc: Schema.Literal("2.0"),
  result: Schema.Unknown,
  id: JsonRpcSuccessIdSchema,
});

export const JsonRpcResponseErrorSchema = Schema.Struct({
  jsonrpc: Schema.Literal("2.0"),
  error: JsonRpcErrorObjectSchema,
  id: JsonRpcIdSchema,
});

export const JsonRpcResponseSchema = Schema.Union(
  JsonRpcResponseSuccessSchema,
  JsonRpcResponseErrorSchema,
);

export type JsonRpcResponseInput = Schema.Schema.Encoded<
  typeof JsonRpcResponseSchema
>;

export type JsonRpcResponseSuccess<Result = unknown> = Readonly<{
  jsonrpc: "2.0";
  result: Result;
  id: JsonRpcSuccessId;
}>;

export type JsonRpcResponseError<Data = unknown> = Readonly<{
  jsonrpc: "2.0";
  error: JsonRpcErrorObject<Data>;
  id: JsonRpcId;
}>;

export type JsonRpcResponse<Result = unknown, Data = unknown> =
  | JsonRpcResponseSuccess<Result>
  | JsonRpcResponseError<Data>;

/** Error raised when a JSON-RPC response fails validation. */
export class InvalidJsonRpcResponseError extends Data.TaggedError(
  "InvalidJsonRpcResponseError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

export interface JsonRpcResponseEncoderService {
  readonly encode: (
    response: JsonRpcResponse,
  ) => Effect.Effect<JsonRpcResponseInput, InvalidJsonRpcResponseError>;
  readonly errorByName: <Source extends JsonRpcErrorSource>(
    source: Source,
    name: JsonRpcErrorNameBySource[Source],
    id: JsonRpcId,
    data?: unknown,
  ) => Effect.Effect<JsonRpcResponseInput, InvalidJsonRpcResponseError>;
}

/** Context tag for the JSON-RPC response encoder service. */
export class JsonRpcResponseEncoder extends Context.Tag(
  "JsonRpcResponseEncoder",
)<JsonRpcResponseEncoder, JsonRpcResponseEncoderService>() {}

const encodeResponse = (response: JsonRpcResponse) =>
  Schema.encode(JsonRpcResponseSchema)(response).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidJsonRpcResponseError({
          message: "Invalid JSON-RPC response",
          cause,
        }),
    ),
  );

const makeJsonRpcResponseEncoder = () =>
  Effect.gen(function* () {
    const registry = yield* JsonRpcErrorRegistry;

    return {
      encode: encodeResponse,
      errorByName: (source, name, id, data) => {
        const definition = registry.byName(source, name);
        return encodeResponse({
          jsonrpc: "2.0",
          id,
          error: {
            code: definition.code,
            message: definition.message,
            ...(data === undefined ? {} : { data }),
          },
        });
      },
    } satisfies JsonRpcResponseEncoderService;
  });

export const JsonRpcResponseEncoderLive = Layer.effect(
  JsonRpcResponseEncoder,
  makeJsonRpcResponseEncoder(),
);

/** Encode a JSON-RPC response using the configured encoder service. */
export const encodeJsonRpcResponse = (response: JsonRpcResponse) =>
  Effect.gen(function* () {
    const encoder = yield* JsonRpcResponseEncoder;
    return yield* encoder.encode(response);
  });

/** Encode a JSON-RPC error response using a registered error definition. */
export const encodeJsonRpcErrorByName = <Source extends JsonRpcErrorSource>(
  source: Source,
  name: JsonRpcErrorNameBySource[Source],
  id: JsonRpcId,
  data?: unknown,
) =>
  Effect.gen(function* () {
    const encoder = yield* JsonRpcResponseEncoder;
    return yield* encoder.errorByName(source, name, id, data);
  });

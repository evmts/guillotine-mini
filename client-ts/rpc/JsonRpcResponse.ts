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

export type JsonPrimitive = string | number | boolean | null;

export type JsonValue =
  | JsonPrimitive
  | ReadonlyArray<JsonValue>
  | Readonly<Record<string, JsonValue>>;

export const JsonValueSchema: Schema.Schema<JsonValue> = Schema.suspend(() =>
  Schema.Union(
    Schema.Null,
    Schema.Boolean,
    Schema.Number,
    Schema.String,
    Schema.Array(JsonValueSchema),
    Schema.Record({
      key: Schema.String,
      value: JsonValueSchema,
    }),
  ),
);

export const JsonRpcSuccessIdSchema = JsonRpcIdSchema;

export type JsonRpcSuccessId = Schema.Schema.Type<
  typeof JsonRpcSuccessIdSchema
>;

export const JsonRpcErrorObjectSchema = Schema.Struct({
  code: Schema.Int,
  message: Schema.String,
  data: Schema.optional(JsonValueSchema),
});

export type JsonRpcErrorObject<Data extends JsonValue = JsonValue> = Readonly<{
  code: JsonRpcErrorCode;
  message: string;
  data?: Data;
}>;

export const JsonRpcResponseSuccessSchema = Schema.Struct({
  jsonrpc: Schema.Literal("2.0"),
  result: JsonValueSchema,
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

export type JsonRpcResponseSuccess<Result extends JsonValue = JsonValue> =
  Readonly<{
    jsonrpc: "2.0";
    result: Result;
    id: JsonRpcSuccessId;
  }>;

export type JsonRpcResponseError<Data extends JsonValue = JsonValue> =
  Readonly<{
    jsonrpc: "2.0";
    error: JsonRpcErrorObject<Data>;
    id: JsonRpcId;
  }>;

export type JsonRpcResponse<
  Result extends JsonValue = JsonValue,
  Data extends JsonValue = JsonValue,
> = JsonRpcResponseSuccess<Result> | JsonRpcResponseError<Data>;

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
    data?: JsonValue,
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
  data?: JsonValue,
) =>
  Effect.gen(function* () {
    const encoder = yield* JsonRpcResponseEncoder;
    return yield* encoder.errorByName(source, name, id, data);
  });

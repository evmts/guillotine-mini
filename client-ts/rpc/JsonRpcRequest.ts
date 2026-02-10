import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";

export type JsonRpcId = string | number | null;

export type JsonRpcParams =
  | ReadonlyArray<unknown>
  | Readonly<Record<string, unknown>>;

export const JsonRpcIdSchema = Schema.Union(
  Schema.String,
  Schema.Number,
  Schema.Null,
);

export const JsonRpcParamsSchema = Schema.Union(
  Schema.Array(Schema.Unknown),
  Schema.Record({
    key: Schema.String,
    value: Schema.Unknown,
  }),
);

export const JsonRpcRequestSchema = Schema.Struct({
  jsonrpc: Schema.Literal("2.0"),
  method: Schema.NonEmptyString,
  params: Schema.optional(JsonRpcParamsSchema),
  id: Schema.optional(JsonRpcIdSchema),
});

export type JsonRpcRequestInput = Schema.Schema.Encoded<
  typeof JsonRpcRequestSchema
>;

export type JsonRpcRequest = Schema.Schema.Type<typeof JsonRpcRequestSchema>;

/** Error raised when a JSON-RPC request fails validation. */
export class InvalidJsonRpcRequestError extends Data.TaggedError(
  "InvalidJsonRpcRequestError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

export interface JsonRpcRequestDecoderService {
  readonly decode: (
    input: unknown,
  ) => Effect.Effect<JsonRpcRequest, InvalidJsonRpcRequestError>;
}

/** Context tag for the JSON-RPC request decoder service. */
export class JsonRpcRequestDecoder extends Context.Tag("JsonRpcRequestDecoder")<
  JsonRpcRequestDecoder,
  JsonRpcRequestDecoderService
>() {}

const makeJsonRpcRequestDecoder = () =>
  ({
    decode: (input) =>
      Schema.decodeUnknown(JsonRpcRequestSchema)(input).pipe(
        Effect.mapError(
          (cause) =>
            new InvalidJsonRpcRequestError({
              message: "Invalid JSON-RPC request",
              cause,
            }),
        ),
      ),
  }) satisfies JsonRpcRequestDecoderService;

export const JsonRpcRequestDecoderLive = Layer.succeed(
  JsonRpcRequestDecoder,
  makeJsonRpcRequestDecoder(),
);

/** Decode a JSON-RPC request using the configured decoder service. */
export const decodeJsonRpcRequest = (input: unknown) =>
  Effect.gen(function* () {
    const decoder = yield* JsonRpcRequestDecoder;
    return yield* decoder.decode(input);
  });

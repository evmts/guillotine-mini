import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import type { JsonRpcRequest } from "./JsonRpcRequest";
import {
  JsonRpcResponseEncoder,
  type InvalidJsonRpcResponseError,
  type JsonRpcResponseInput,
  type JsonValue,
} from "./JsonRpcResponse";

export type JsonRpcMethodHandler = (
  request: JsonRpcRequest,
) => Effect.Effect<JsonValue>;

export interface JsonRpcServiceService {
  readonly sendRequest: (
    request: JsonRpcRequest,
  ) => Effect.Effect<
    Option.Option<JsonRpcResponseInput>,
    InvalidJsonRpcResponseError
  >;
}

/** Context tag for JSON-RPC request dispatch. */
export class JsonRpcService extends Context.Tag("JsonRpcService")<
  JsonRpcService,
  JsonRpcServiceService
>() {}

const normalizeMethod = (method: string): string => method.trim();

const isNotification = (request: JsonRpcRequest): boolean =>
  request.id === undefined;

const makeJsonRpcService = (
  handlers: Readonly<Record<string, JsonRpcMethodHandler>>,
) =>
  Effect.gen(function* () {
    const encoder = yield* JsonRpcResponseEncoder;

    const sendRequest = (request: JsonRpcRequest) =>
      Effect.gen(function* () {
        const handler = handlers[normalizeMethod(request.method)];

        if (handler === undefined) {
          if (isNotification(request)) {
            return Option.none<JsonRpcResponseInput>();
          }

          const errorResponse = yield* encoder.errorByName(
            "EIP-1474",
            "MethodNotFound",
            request.id,
          );
          return Option.some(errorResponse);
        }

        const result = yield* handler(request);
        if (isNotification(request)) {
          return Option.none<JsonRpcResponseInput>();
        }

        const successResponse = yield* encoder.encode({
          jsonrpc: "2.0",
          result,
          id: request.id,
        });
        return Option.some(successResponse);
      });

    return {
      sendRequest,
    } satisfies JsonRpcServiceService;
  });

export const JsonRpcServiceLive = (
  handlers: Readonly<Record<string, JsonRpcMethodHandler>>,
) => Layer.effect(JsonRpcService, makeJsonRpcService(handlers));

export const sendJsonRpcRequest = (request: JsonRpcRequest) =>
  Effect.gen(function* () {
    const service = yield* JsonRpcService;
    return yield* service.sendRequest(request);
  });

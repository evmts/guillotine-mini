import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";

export type JsonRpcErrorSource = "EIP-1474" | "Nethermind";

export type JsonRpcErrorDefinition = Readonly<{
  code: number;
  message: string;
  source: JsonRpcErrorSource;
}>;

const JsonRpcErrorCatalogEip1474 = {
  ParseError: {
    code: -32700,
    message: "Parse error",
    source: "EIP-1474",
  },
  InvalidRequest: {
    code: -32600,
    message: "Invalid request",
    source: "EIP-1474",
  },
  MethodNotFound: {
    code: -32601,
    message: "Method not found",
    source: "EIP-1474",
  },
  InvalidParams: {
    code: -32602,
    message: "Invalid params",
    source: "EIP-1474",
  },
  InternalError: {
    code: -32603,
    message: "Internal error",
    source: "EIP-1474",
  },
  InvalidInput: {
    code: -32000,
    message: "Invalid input",
    source: "EIP-1474",
  },
  ResourceNotFound: {
    code: -32001,
    message: "Resource not found",
    source: "EIP-1474",
  },
  ResourceUnavailable: {
    code: -32002,
    message: "Resource unavailable",
    source: "EIP-1474",
  },
  TransactionRejected: {
    code: -32003,
    message: "Transaction rejected",
    source: "EIP-1474",
  },
  MethodNotSupported: {
    code: -32004,
    message: "Method not supported",
    source: "EIP-1474",
  },
  LimitExceeded: {
    code: -32005,
    message: "Limit exceeded",
    source: "EIP-1474",
  },
  JsonRpcVersionNotSupported: {
    code: -32006,
    message: "JSON-RPC version not supported",
    source: "EIP-1474",
  },
} as const satisfies Record<string, JsonRpcErrorDefinition>;

const JsonRpcErrorCatalogNethermind = {
  None: {
    code: 0,
    message: "No error",
    source: "Nethermind",
  },
  ExecutionReverted: {
    code: 3,
    message: "Execution reverted",
    source: "Nethermind",
  },
  ResourceNotFound: {
    code: -32000,
    message: "Resource not found",
    source: "Nethermind",
  },
  TransactionRejected: {
    code: -32010,
    message: "Transaction rejected",
    source: "Nethermind",
  },
  AccountLocked: {
    code: -32020,
    message: "Account locked",
    source: "Nethermind",
  },
  ExecutionError: {
    code: -32015,
    message: "Execution error",
    source: "Nethermind",
  },
  Timeout: {
    code: -32016,
    message: "Timeout",
    source: "Nethermind",
  },
  ModuleTimeout: {
    code: -32017,
    message: "Module timeout",
    source: "Nethermind",
  },
  UnknownBlockError: {
    code: -39001,
    message: "Unknown block error",
    source: "Nethermind",
  },
  InvalidInputBlocksOutOfOrder: {
    code: -38020,
    message: "Blocks out of order",
    source: "Nethermind",
  },
  BlockTimestampNotIncreased: {
    code: -38021,
    message: "Block timestamp not increased",
    source: "Nethermind",
  },
  InvalidInputTooManyBlocks: {
    code: -38026,
    message: "Too many blocks",
    source: "Nethermind",
  },
  InsufficientIntrinsicGas: {
    code: -38013,
    message: "Insufficient intrinsic gas",
    source: "Nethermind",
  },
  InvalidTransaction: {
    code: -38014,
    message: "Invalid transaction",
    source: "Nethermind",
  },
  ClientLimitExceededError: {
    code: -38026,
    message: "Client limit exceeded",
    source: "Nethermind",
  },
  PrunedHistoryUnavailable: {
    code: 4444,
    message: "Pruned history unavailable",
    source: "Nethermind",
  },
  Default: {
    code: -32000,
    message: "Default error",
    source: "Nethermind",
  },
  NonceTooHigh: {
    code: -38011,
    message: "Nonce too high",
    source: "Nethermind",
  },
  NonceTooLow: {
    code: -38010,
    message: "Nonce too low",
    source: "Nethermind",
  },
  IntrinsicGas: {
    code: -38013,
    message: "Invalid intrinsic gas",
    source: "Nethermind",
  },
  InsufficientFunds: {
    code: -38014,
    message: "Insufficient funds",
    source: "Nethermind",
  },
  BlockGasLimitReached: {
    code: -38015,
    message: "Block gas limit reached",
    source: "Nethermind",
  },
  BlockNumberInvalid: {
    code: -38020,
    message: "Invalid block number",
    source: "Nethermind",
  },
  BlockTimestampInvalid: {
    code: -38021,
    message: "Invalid block timestamp",
    source: "Nethermind",
  },
  SenderIsNotEOA: {
    code: -38024,
    message: "Sender is not an EOA",
    source: "Nethermind",
  },
  MaxInitCodeSizeExceeded: {
    code: -38025,
    message: "Max init code size exceeded",
    source: "Nethermind",
  },
  RevertedSimulate: {
    code: -32000,
    message: "Execution reverted",
    source: "Nethermind",
  },
  VMError: {
    code: -32015,
    message: "VM error",
    source: "Nethermind",
  },
  TxSyncTimeout: {
    code: 4,
    message: "Transaction sync timeout",
    source: "Nethermind",
  },
  ClientLimitExceeded: {
    code: -38026,
    message: "Client limit exceeded",
    source: "Nethermind",
  },
} as const satisfies Record<string, JsonRpcErrorDefinition>;

export const JsonRpcErrorCatalog = {
  "EIP-1474": JsonRpcErrorCatalogEip1474,
  Nethermind: JsonRpcErrorCatalogNethermind,
} as const satisfies Record<
  JsonRpcErrorSource,
  Record<string, JsonRpcErrorDefinition>
>;

type JsonRpcErrorCatalogBySource = typeof JsonRpcErrorCatalog;

export type JsonRpcErrorNameBySource = {
  [Source in JsonRpcErrorSource]: keyof JsonRpcErrorCatalogBySource[Source];
};

export type JsonRpcErrorName = JsonRpcErrorNameBySource[JsonRpcErrorSource];
export type JsonRpcErrorCode = JsonRpcErrorDefinition["code"];

const defaultMessageByCode = new Map<number, string>();
for (const catalog of Object.values(JsonRpcErrorCatalog)) {
  for (const definition of Object.values(catalog)) {
    if (!defaultMessageByCode.has(definition.code)) {
      defaultMessageByCode.set(definition.code, definition.message);
    }
  }
}

const lookupMessageForCode = (code: number) =>
  Option.fromNullable(defaultMessageByCode.get(code));

export interface JsonRpcErrorRegistryService {
  readonly byName: <Source extends JsonRpcErrorSource>(
    source: Source,
    name: JsonRpcErrorNameBySource[Source],
  ) => JsonRpcErrorDefinition;
  readonly messageForCode: (code: number) => Option.Option<string>;
}

export class JsonRpcErrorRegistry extends Context.Tag("JsonRpcErrorRegistry")<
  JsonRpcErrorRegistry,
  JsonRpcErrorRegistryService
>() {}

const makeJsonRpcErrorRegistry = () =>
  ({
    byName: (source, name) => JsonRpcErrorCatalog[source][name],
    messageForCode: (code) => lookupMessageForCode(code),
  }) satisfies JsonRpcErrorRegistryService;

export const JsonRpcErrorRegistryLive = Layer.succeed(
  JsonRpcErrorRegistry,
  makeJsonRpcErrorRegistry(),
);

export const jsonRpcErrorByName = <Source extends JsonRpcErrorSource>(
  source: Source,
  name: JsonRpcErrorNameBySource[Source],
) =>
  Effect.gen(function* () {
    const registry = yield* JsonRpcErrorRegistry;
    return registry.byName(source, name);
  });

export const jsonRpcErrorMessageForCode = (code: number) =>
  Effect.gen(function* () {
    const registry = yield* JsonRpcErrorRegistry;
    return registry.messageForCode(code);
  });

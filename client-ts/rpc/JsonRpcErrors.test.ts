import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import {
  JsonRpcErrorCatalog,
  JsonRpcErrorRegistryLive,
  jsonRpcErrorByName,
  jsonRpcErrorMessageForCode,
} from "./JsonRpcErrors";

type ExpectedEntry = Readonly<{ code: number; message: string }>;

type ExpectedMap = Readonly<Record<string, ExpectedEntry>>;

const expectedEip1474: ExpectedMap = {
  ParseError: { code: -32700, message: "Parse error" },
  InvalidRequest: { code: -32600, message: "Invalid request" },
  MethodNotFound: { code: -32601, message: "Method not found" },
  InvalidParams: { code: -32602, message: "Invalid params" },
  InternalError: { code: -32603, message: "Internal error" },
  InvalidInput: { code: -32000, message: "Invalid input" },
  ResourceNotFound: { code: -32001, message: "Resource not found" },
  ResourceUnavailable: { code: -32002, message: "Resource unavailable" },
  TransactionRejected: { code: -32003, message: "Transaction rejected" },
  MethodNotSupported: { code: -32004, message: "Method not supported" },
  LimitExceeded: { code: -32005, message: "Limit exceeded" },
  JsonRpcVersionNotSupported: {
    code: -32006,
    message: "JSON-RPC version not supported",
  },
};

const expectedNethermind: ExpectedMap = {
  None: { code: 0, message: "No error" },
  ExecutionReverted: { code: 3, message: "Execution reverted" },
  ResourceNotFound: { code: -32000, message: "Resource not found" },
  TransactionRejected: {
    code: -32010,
    message: "Transaction rejected",
  },
  AccountLocked: { code: -32020, message: "Account locked" },
  ExecutionError: { code: -32015, message: "Execution error" },
  Timeout: { code: -32016, message: "Timeout" },
  ModuleTimeout: { code: -32017, message: "Module timeout" },
  UnknownBlockError: { code: -39001, message: "Unknown block error" },
  InvalidInputBlocksOutOfOrder: {
    code: -38020,
    message: "Blocks out of order",
  },
  BlockTimestampNotIncreased: {
    code: -38021,
    message: "Block timestamp not increased",
  },
  InvalidInputTooManyBlocks: { code: -38026, message: "Too many blocks" },
  InsufficientIntrinsicGas: {
    code: -38013,
    message: "Insufficient intrinsic gas",
  },
  InvalidTransaction: { code: -38014, message: "Invalid transaction" },
  ClientLimitExceededError: {
    code: -38026,
    message: "Client limit exceeded",
  },
  PrunedHistoryUnavailable: {
    code: 4444,
    message: "Pruned history unavailable",
  },
  Default: { code: -32000, message: "Default error" },
  NonceTooHigh: { code: -38011, message: "Nonce too high" },
  NonceTooLow: { code: -38010, message: "Nonce too low" },
  IntrinsicGas: { code: -38013, message: "Invalid intrinsic gas" },
  InsufficientFunds: { code: -38014, message: "Insufficient funds" },
  BlockGasLimitReached: { code: -38015, message: "Block gas limit reached" },
  BlockNumberInvalid: { code: -38020, message: "Invalid block number" },
  BlockTimestampInvalid: {
    code: -38021,
    message: "Invalid block timestamp",
  },
  SenderIsNotEOA: { code: -38024, message: "Sender is not an EOA" },
  MaxInitCodeSizeExceeded: {
    code: -38025,
    message: "Max init code size exceeded",
  },
  RevertedSimulate: { code: -32000, message: "Execution reverted" },
  VMError: { code: -32015, message: "VM error" },
  TxSyncTimeout: { code: 4, message: "Transaction sync timeout" },
  ClientLimitExceeded: { code: -38026, message: "Client limit exceeded" },
};

const entries = <T extends ExpectedMap>(record: T) =>
  Object.entries(record) as Array<[keyof T, T[keyof T]]>;

describe("JsonRpcErrors", () => {
  it.effect("maps EIP-1474 error codes and messages", () =>
    Effect.gen(function* () {
      for (const [name, expected] of entries(expectedEip1474)) {
        const actual =
          JsonRpcErrorCatalog["EIP-1474"][
            name as keyof (typeof JsonRpcErrorCatalog)["EIP-1474"]
          ];
        assert.strictEqual(actual.code, expected.code);
        assert.strictEqual(actual.message, expected.message);
        assert.strictEqual(actual.source, "EIP-1474");
      }
    }),
  );

  it.effect("maps Nethermind extension error codes and messages", () =>
    Effect.gen(function* () {
      for (const [name, expected] of entries(expectedNethermind)) {
        const actual =
          JsonRpcErrorCatalog.Nethermind[
            name as keyof typeof JsonRpcErrorCatalog.Nethermind
          ];
        assert.strictEqual(actual.code, expected.code);
        assert.strictEqual(actual.message, expected.message);
        assert.strictEqual(actual.source, "Nethermind");
      }
    }),
  );

  it.effect("resolves registry lookups", () =>
    Effect.gen(function* () {
      const parseError = yield* jsonRpcErrorByName("EIP-1474", "ParseError");
      assert.strictEqual(parseError.code, -32700);
      assert.strictEqual(parseError.message, "Parse error");

      const message = yield* jsonRpcErrorMessageForCode(-32005);
      assert.isTrue(Option.isSome(message));
      if (Option.isSome(message)) {
        assert.strictEqual(message.value, "Limit exceeded");
      }

      const missing = yield* jsonRpcErrorMessageForCode(12345);
      assert.isTrue(Option.isNone(missing));
    }).pipe(Effect.provide(JsonRpcErrorRegistryLive)),
  );
});

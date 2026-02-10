# Context — [pass 1/5] phase-7-engine-api (Engine API (Consensus Layer Interface))

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement the Engine API for consensus layer communication.
- Key components to implement in this phase:
  - `client/engine/api.zig` — Engine API surface + dispatcher.
  - `client/engine/payload.zig` — Payload building/validation wiring.
- Architectural references:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.Merge.Plugin/` (EngineRpcModule, handlers).
  - Execution APIs: `execution-apis/src/engine/` (spec, method versions).

## Spec References (execution-apis)
- `execution-apis/src/engine/common.md` — Common definitions, error codes, capabilities, encoding.
- `execution-apis/src/engine/authentication.md` — JWT auth for Engine API (port 8551).
- `execution-apis/src/engine/identification.md` — Client identification requirements.
- Fork-specific method specs:
  - `execution-apis/src/engine/paris.md` — Merge/Paris: PayloadStatusV1, newPayloadV1, forkchoiceUpdatedV1.
  - `execution-apis/src/engine/shanghai.md` — Shapella: withdrawals, getPayloadV2/newPayloadV2.
  - `execution-apis/src/engine/cancun.md` — Cancun: blobs, getPayloadV3/newPayloadV3, getBlobsV1/V2.
  - `execution-apis/src/engine/prague.md` — Prague: latest Engine method deltas.
  - `execution-apis/src/engine/amsterdam.md`, `execution-apis/src/engine/osaka.md` — upcoming drafts.
  - `execution-apis/src/engine/openrpc/` — OpenRPC schema for method/params typing.

## EIPs impacting Engine API payloads
- `EIPs/EIPS/eip-3675.md` — The Merge: PoS transition, TD freeze; base for Engine API.
- `EIPs/EIPS/eip-4399.md` — PREVRANDAO replaces DIFFICULTY, header mixHash rules.
- `EIPs/EIPS/eip-4895.md` — Withdrawals (Shapella/Capella) included in execution payload.
- `EIPs/EIPS/eip-4844.md` — Blob transactions; blob gas fields and versioned hashes.
- (Informative) `EIPs/EIPS/eip-7843.md` — Engine API V4/V6 slotNumber fields (draft/aux).

## Nethermind reference (structure/style)
- `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`
  - `EngineRpcModule.cs` (+ Paris/Shanghai/Cancun/Prague partials): Engine namespace surface.
  - `Handlers/` — per-method handlers (newPayload/getPayload/forkchoiceUpdated).
  - `MergeErrorCodes.cs`, `MergeErrorMessages.cs` — error mapping; mirror to execution-apis error table.
  - `MergePlugin.cs` — lifecycle wiring; payload building policies.
- (Requested listing) `nethermind/src/Nethermind/Nethermind.Db/` key files:
  - `IDb.cs`, `IDbProvider.cs`, `DbProvider.cs`, `MemDb.cs`, `RocksDbSettings.cs`, `IColumnsDb.cs`.

## Voltaire Zig APIs to use (do not duplicate)
- `voltaire-zig/src/jsonrpc/engine/methods.zig` — EngineMethod tagged union (all engine_* methods).
- Engine RPC modules (parameters/results):
  - `jsonrpc/engine/getPayloadV[1-6]/engine_getPayloadV*.zig`
  - `jsonrpc/engine/newPayloadV[1-5]/engine_newPayloadV*.zig`
  - `jsonrpc/engine/forkchoiceUpdatedV[1-3]/engine_forkchoiceUpdatedV*.zig`
  - `jsonrpc/engine/exchangeCapabilities/engine_exchangeCapabilities.zig`
  - `jsonrpc/engine/exchangeTransitionConfigurationV1/engine_exchangeTransitionConfigurationV1.zig`
  - `jsonrpc/engine/getPayloadBodiesByHashV1/`, `getPayloadBodiesByRangeV1/`
  - `jsonrpc/engine/getBlobsV1/`, `getBlobsV2/`
- Relevant primitives (types only, sample set):
  - `primitives/Withdrawal/Withdrawal.zig` (Shapella), `primitives/Blob/`, `primitives/BlockHeader/`, `primitives/Bytes32/`, `primitives/Hash/`, `primitives/Uint/`.
- Use `voltaire-zig/src/root.zig` and `primitives/root.zig` for type imports.

## Existing Zig host/EVM integration to respect
- `src/host.zig` — Minimal `HostInterface` vtable for balances/code/storage/nonce.
  - EVM nested calls use internal `inner_call` and do not depend on host for reentrancy.
  - Engine API integration must adapt world-state to this interface (no EVM reimplementation).

## Test fixtures (paths)
- `ethereum-tests/BlockchainTests/` — canonical blockchain fixtures.
- `ethereum-tests/GeneralStateTests/` — state-level tests (pre/post Merge reference).
- Engine API formats (execution-spec-tests docs):
  - `execution-spec-tests/docs/running_tests/test_formats/blockchain_test_engine.md` — base Engine API fixtures.
  - `execution-spec-tests/docs/running_tests/test_formats/blockchain_test_engine_x.md` — optimized Engine API fixtures.
  - Releases mapping: `execution-spec-tests/docs/running_tests/releases.md` (fixture output locations).
- Current fixtures folder: `execution-spec-tests/fixtures/` → symlink to `ethereum-tests/BlockchainTests`.

## Implementation notes (actionable)
- Use Voltaire `EngineMethod` for dispatch; map to internal handlers via comptime DI.
- Strictly return execution-apis error codes; avoid custom enums duplicating Voltaire/Nethermind.
- Ensure JWT on dedicated port 8551 per `authentication.md`.
- Payload validation/building must use guillotine-mini EVM and Voltaire primitives; no custom types.
- Add unit tests per public handler; plan to integrate Engine fixtures runners later.

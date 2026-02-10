# Context — [pass 1/5] phase-7-engine-api (Engine API (Consensus Layer Interface))

## Phase goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Implement Engine API for consensus-layer communication.
- Planned components:
  - `client/engine/api.zig` (Engine API surface)
  - `client/engine/payload.zig` (payload building/validation)
- Structural references:
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`
  - `execution-apis/src/engine/`

## Relevant specs (from `prd/ETHEREUM_SPECS_REFERENCE.md` + source files)
- Engine API spec set:
  - `execution-apis/src/engine/common.md`
  - `execution-apis/src/engine/authentication.md`
  - `execution-apis/src/engine/identification.md`
  - `execution-apis/src/engine/paris.md`
  - `execution-apis/src/engine/shanghai.md`
  - `execution-apis/src/engine/cancun.md`
  - `execution-apis/src/engine/prague.md`
  - `execution-apis/src/engine/osaka.md`
  - `execution-apis/src/engine/amsterdam.md`
- EIPs explicitly tied to phase-7 in PRD:
  - `EIPs/EIPS/eip-3675.md` (Merge transition, TTD/forkchoice constraints)
  - `EIPs/EIPS/eip-4399.md` (PREVRANDAO semantics for payload/header processing)

## Engine API behavior anchors
- `execution-apis/src/engine/common.md`
  - Dedicated authenticated Engine API endpoint (default port `8551`)
  - Strict error code set (`-38001` to `-38005` plus JSON-RPC errors)
  - `engine_exchangeCapabilities` is required on EL side
  - `engine_forkchoiceUpdated` ordering must be preserved
- `execution-apis/src/engine/paris.md`
  - Baseline method contracts: `engine_newPayloadV1`, `engine_forkchoiceUpdatedV1`, `engine_getPayloadV1`, `engine_exchangeTransitionConfigurationV1`
  - Core structures: `ExecutionPayloadV1`, `ForkchoiceStateV1`, `PayloadAttributesV1`, `PayloadStatusV1`
- `execution-apis/src/engine/authentication.md`
  - JWT-based authentication requirements (`HS256`, required `iat`, `jwt.hex` secret handling)

## Nethermind architectural references
- Primary phase-7 module:
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`
- Key files for Engine module boundaries:
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/EngineRpcModule.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/EngineRpcModule.Paris.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/EngineRpcModule.Shanghai.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/EngineRpcModule.Cancun.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/EngineRpcModule.Prague.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/EngineRpcModule.Osaka.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/Handlers/NewPayloadHandler.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/Handlers/ForkchoiceUpdatedHandler.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/Handlers/GetPayloadV1Handler.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/Handlers/GetPayloadV2Handler.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/Handlers/GetPayloadV3Handler.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/Handlers/GetPayloadV4Handler.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/Handlers/GetPayloadV5Handler.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/MergeErrorCodes.cs`
  - `nethermind/src/Nethermind/Nethermind.Merge.Plugin/MergeErrorMessages.cs`
- Requested DB listing (`nethermind/src/Nethermind/Nethermind.Db/`) key files:
  - `IDb.cs`
  - `IDbProvider.cs`
  - `DbProvider.cs`
  - `DbProviderExtensions.cs`
  - `IColumnsDb.cs`
  - `MemDb.cs`
  - `MemDbFactory.cs`
  - `ReadOnlyDb.cs`
  - `RocksDbSettings.cs`
  - `PruningConfig.cs`

## Voltaire Zig APIs (from `/Users/williamcory/voltaire/packages/voltaire-zig/src/`)
- Top-level module groups:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/evm`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager`
- Engine JSON-RPC method typing surface:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/engine/methods.zig`
  - Includes typed method unions for:
    - `engine_exchangeCapabilities`
    - `engine_exchangeTransitionConfigurationV1`
    - `engine_forkchoiceUpdatedV1`/`V2`/`V3`
    - `engine_getPayloadV1`..`V6`
    - `engine_newPayloadV1`..`V5`
    - `engine_getPayloadBodiesByHashV1`
    - `engine_getPayloadBodiesByRangeV1`
    - `engine_getBlobsV1`/`V2`
- Primitive/export surface:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`
  - Exports canonical Ethereum data types (Address/Hash/Block/Transaction/etc.) and encoding helpers (Hex/RLP/ABI)

## Existing guillotine-mini EVM host contract
- `src/host.zig`
  - Defines `HostInterface` with vtable methods for:
    - `getBalance` / `setBalance`
    - `getCode` / `setCode`
    - `getStorage` / `setStorage`
    - `getNonce` / `setNonce`
  - Commented behavior note: nested EVM calls are handled internally by EVM (`inner_call`), not via host callback recursion.

## Test fixtures inventory
- Ethereum tests tree (top-level fixture families):
  - `ethereum-tests/BlockchainTests/`
  - `ethereum-tests/TransactionTests/`
  - `ethereum-tests/EOFTests/`
  - `ethereum-tests/TrieTests/`
  - `ethereum-tests/RLPTests/`
  - `ethereum-tests/BasicTests/`
  - `ethereum-tests/GenesisTests/`
  - `ethereum-tests/DifficultyTests/`
- Execution-spec-tests in this workspace:
  - `execution-spec-tests/fixtures/`
  - Note: PRD references `execution-spec-tests/fixtures/blockchain_tests_engine/`, but that subpath is not present in this checkout.
- Hive tree in this workspace:
  - `hive/` exists but no deeper simulator directories are present in current checkout.

## Phase-7 implementation guidance extracted from context
- Start with Paris baseline API (`newPayloadV1`, `forkchoiceUpdatedV1`, `getPayloadV1`, transition config) and preserve exact error/status semantics before adding fork extensions.
- Keep method/version surface explicit (parallel to Nethermind partial-module split by fork) to avoid cross-fork behavior bleed.
- Treat `execution-apis/src/engine/common.md` as protocol contract for ordering, error codes, and capability negotiation.
- Reuse existing EVM/state host boundaries (`src/host.zig`) rather than introducing alternate execution semantics.
- Use available local fixtures (`ethereum-tests/BlockchainTests` and `execution-spec-tests/fixtures`) and mark missing upstream fixture paths as a follow-up sync task.

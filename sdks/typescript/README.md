# @tevm/guillotine-mini

TypeScript SDK for Guillotine Mini EVM (WebAssembly)

**Fully self-contained** - WASM is bundled inline, no external files needed. Works in both Node.js and browser environments.

## Installation

```bash
npm install @tevm/guillotine-mini
```

## Development

### Building from Source

```bash
# Install dependencies
npm install

# Build the library (creates dist/ with ES and CJS formats)
npm run build

# Watch mode for development
npm run dev

# Type check without building
npm run typecheck

# Run tests
npm run test
```

### Building WASM

First, build the WASM file from the root of the guillotine-mini repository:

```bash
# From repository root
zig build wasm

# Copy WASM to SDK
cp zig-out/bin/guillotine_mini.wasm sdks/typescript/wasm/
```

## Usage

```typescript
import { createEvm, hexToBytes, addressToBytes, bigintToU256 } from '@tevm/guillotine-mini';

// Create EVM instance with optional hardfork (default: PRAGUE)
const evm = await createEvm({ hardfork: 'CANCUN' });

// Set bytecode
const bytecode = hexToBytes('6001600101'); // PUSH1 1 PUSH1 1 ADD
await evm.setBytecode(bytecode);

// Set execution context
await evm.setExecutionContext({
  gas: 100000n,
  caller: addressToBytes('0x1234567890123456789012345678901234567890'),
  address: addressToBytes('0x0000000000000000000000000000000000000001'),
  value: 0n,
  calldata: new Uint8Array(),
});

// Set blockchain context (REQUIRED before execute)
await evm.setBlockchainContext({
  chainId: 1n,
  blockNumber: 1000000n,
  blockTimestamp: BigInt(Date.now() / 1000),
  blockDifficulty: 0n,  // Use 0 for PoS
  blockPrevrandao: 0n,  // Random value for PoS
  blockCoinbase: addressToBytes('0x0000000000000000000000000000000000000000'),
  blockGasLimit: 30000000n,
  blockBaseFee: 10n ** 9n,  // 1 gwei
  blobBaseFee: 1n,  // EIP-4844
});

// Optional: Set access list (EIP-2930)
await evm.setAccessList([
  {
    address: addressToBytes('0x0000000000000000000000000000000000000001'),
    storageKeys: [bigintToU256(0n), bigintToU256(1n)],
  },
]);

// Optional: Set blob hashes (EIP-4844)
await evm.setBlobHashes([
  new Uint8Array(32).fill(1),  // Example blob hash
]);

// Execute
const result = await evm.execute();
console.log('Success:', result.success);
console.log('Gas used:', result.gasUsed);
console.log('Output:', result.output);

// Clean up
await evm.destroy();
```

## API

### `createEvm(options?: EvmOptions): Promise<Evm>`

Create a new EVM instance with the bundled WASM module.

**Options:**
- `hardfork?: Hardfork` - EVM hardfork to use (default: `'PRAGUE'`)

Available hardforks: `'FRONTIER'`, `'HOMESTEAD'`, `'TANGERINE_WHISTLE'`, `'SPURIOUS_DRAGON'`, `'BYZANTIUM'`, `'CONSTANTINOPLE'`, `'PETERSBURG'`, `'ISTANBUL'`, `'BERLIN'`, `'LONDON'`, `'MERGE'`, `'SHANGHAI'`, `'CANCUN'`, `'PRAGUE'`, `'OSAKA'`

The WASM is automatically loaded and works in both Node.js and browser environments.

### `Evm` Interface

All methods are asynchronous and automatically await WASM initialization.

#### `ready(): Promise<void>`

Explicitly wait for WASM initialization. Usually not needed since all methods call this internally.

#### `setBytecode(bytecode: Bytes): Promise<void>`

Set the bytecode to execute.

#### `setExecutionContext(ctx: ExecutionContext): Promise<void>`

Set execution context (gas, caller, address, value, calldata).

#### `setBlockchainContext(ctx: BlockchainContext): Promise<void>`

Set blockchain context. **REQUIRED before calling `execute()`**.

All fields are required:
- `chainId` - Chain ID (e.g., 1 for mainnet)
- `blockNumber` - Current block number
- `blockTimestamp` - Block timestamp (seconds since epoch)
- `blockDifficulty` - Block difficulty (use 0 for PoS)
- `blockPrevrandao` - Block prevrandao/mixHash (replaces difficulty in PoS)
- `blockCoinbase` - Block coinbase address
- `blockGasLimit` - Block gas limit
- `blockBaseFee` - Base fee per gas (EIP-1559)
- `blobBaseFee` - Blob base fee (EIP-4844)

#### `setAccessList(accessList: AccessListEntry[]): Promise<void>`

Set access list for EIP-2930 transactions. Optional, call before `execute()`.

Each entry contains:
- `address: Address` - Address to pre-warm
- `storageKeys: U256[]` - Storage slots to pre-warm for this address

#### `setBlobHashes(hashes: Bytes[]): Promise<void>`

Set blob versioned hashes for EIP-4844 transactions. Optional, call before `execute()`.

Each hash must be exactly 32 bytes.

#### `execute(): Promise<ExecutionResult>`

Execute the EVM with the current context. Returns execution result.

#### `setStorage(address: Address, slot: U256, value: U256): Promise<void>`

Set storage value for an address.

#### `getStorage(address: Address, slot: U256): Promise<U256>`

Get storage value for an address.

#### `setBalance(address: Address, balance: bigint): Promise<void>`

Set account balance.

#### `setCode(address: Address, code: Bytes): Promise<void>`

Set account code.

#### `destroy(): Promise<void>`

Destroy the EVM instance and free resources.

## Types

```typescript
type Address = Uint8Array;  // 20 bytes
type U256 = Uint8Array;     // 32 bytes
type Bytes = Uint8Array;

type Hardfork =
  | 'FRONTIER' | 'HOMESTEAD' | 'DAO'
  | 'TANGERINE_WHISTLE' | 'SPURIOUS_DRAGON'
  | 'BYZANTIUM' | 'CONSTANTINOPLE' | 'PETERSBURG'
  | 'ISTANBUL' | 'MUIR_GLACIER'
  | 'BERLIN' | 'LONDON' | 'ARROW_GLACIER' | 'GRAY_GLACIER'
  | 'MERGE' | 'SHANGHAI' | 'CANCUN' | 'PRAGUE' | 'OSAKA';

interface EvmOptions {
  hardfork?: Hardfork;
}

interface ExecutionContext {
  gas: bigint;
  caller: Address;
  address: Address;
  value: bigint;
  calldata: Bytes;
}

interface BlockchainContext {
  chainId: bigint;
  blockNumber: bigint;
  blockTimestamp: bigint;
  blockDifficulty: bigint;
  blockPrevrandao: bigint;
  blockCoinbase: Address;
  blockGasLimit: bigint;
  blockBaseFee: bigint;
  blobBaseFee: bigint;
}

interface AccessListEntry {
  address: Address;
  storageKeys: U256[];
}

interface ExecutionResult {
  success: boolean;
  gasRemaining: bigint;
  gasUsed: bigint;
  output: Bytes;
}
```

## Utilities

- `hexToBytes(hex: string): Uint8Array` - Convert hex string to bytes
- `bytesToHex(bytes: Uint8Array): string` - Convert bytes to hex string
- `bigintToU256(value: bigint): Uint8Array` - Convert bigint to 32-byte u256
- `u256ToBigint(bytes: Uint8Array): bigint` - Convert 32-byte u256 to bigint
- `addressToBytes(address: string): Uint8Array` - Convert address string to 20 bytes
- `bytesToAddress(bytes: Uint8Array): string` - Convert 20 bytes to address string

## License

See LICENSE file.

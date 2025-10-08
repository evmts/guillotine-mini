# @guillotine/evm

TypeScript SDK for Guillotine Mini EVM (WebAssembly)

## Installation

```bash
npm install @guillotine/evm
```

## Usage

```typescript
import { createEvm, hexToBytes, addressToBytes } from '@guillotine/evm';

// Create EVM instance (synchronous, but methods await WASM initialization)
const evm = createEvm('./wasm/guillotine_mini.wasm');

// Wait for initialization (optional, called automatically by other methods)
await evm.ready();

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

// Set blockchain context
await evm.setBlockchainContext({
  chainId: 1n,
  blockNumber: 1000000n,
  blockTimestamp: BigInt(Date.now() / 1000),
  blockCoinbase: addressToBytes('0x0000000000000000000000000000000000000000'),
  blockGasLimit: 30000000n,
});

// Execute
const result = await evm.execute();
console.log('Success:', result.success);
console.log('Gas used:', result.gasUsed);
console.log('Output:', result.output);

// Clean up
await evm.destroy();
```

## API

### `createEvm(wasmPath: string): Evm`

Create a new EVM instance. Returns synchronously, but all methods await WASM initialization internally.

### `Evm` Interface

All methods are asynchronous and automatically await WASM initialization.

#### `ready(): Promise<void>`

Explicitly wait for WASM initialization. Usually not needed since all methods call this internally.

#### `setBytecode(bytecode: Bytes): Promise<void>`

Set the bytecode to execute.

#### `setExecutionContext(ctx: ExecutionContext): Promise<void>`

Set execution context (gas, caller, address, value, calldata).

#### `setBlockchainContext(ctx: BlockchainContext): Promise<void>`

Set blockchain context (chain ID, block number, timestamp, coinbase, gas limit).

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
  blockCoinbase: Address;
  blockGasLimit: bigint;
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

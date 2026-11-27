# `src/inspector.zig`

Read-only EVM execution hook vtable, multiplexer, and Solidity revert decoder.

## Responsibilities
- **`OpcodeMask`**: 256-bit opcode bitmask (`ALL`, `NONE`, `fromOpcodes`, `contains`, `unionWith`) allowing inspectors to skip `onOpcode`/`onOpcodeEnd`/`onFault` callbacks for uninterested opcodes.
- **`Inspector`**: Non-owning vtable (`ptr`, `vtable`, `opcode_mask`, `capture_memory`) covering transaction lifecycle (`onTxStart`, `onTxEnd`), call frames (`onEnter`, `onExit`), opcode execution (`onOpcode`, `onOpcodeEnd`, `onFault`), logs (`onLog`), state mutations (`onStorageChange`, `onTransientStorageChange`, `onBalanceChange`, `onNonceChange`, `onCodeChange`, `onSelfDestruct`), and EIP-2929 accesses (`onAccess`).
- **`MuxInspector`**: Fans out a single execution pass across multiple child inspectors in deterministic order while taking the union of their opcode masks and memory-capture flags.
- **`RevertDecoder` & `DecodedRevert`**: Decodes ABI `Error(string)` (`0x08c379a0`, UTF-8 validated) and `Panic(uint256)` (`0x4e487b71`) revert payloads; `formatErrorName` maps EVM errors to standard Geth error strings.

## Ownership & Safety
- All event slices are borrowed for the duration of each callback; inspectors needing persistence must duplicate buffers and retain internal errors out-of-band.

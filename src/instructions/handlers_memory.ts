/**
 * Memory opcode handlers for the EVM
 *
 * This module implements all memory operations:
 * - MLOAD (0x51): Load 32 bytes from memory
 * - MSTORE (0x52): Store 32 bytes to memory
 * - MSTORE8 (0x53): Store single byte to memory
 * - MSIZE (0x59): Get size of active memory
 * - MCOPY (0x5e): Copy memory region (EIP-5656, Cancun+)
 *
 * Memory expansion follows EVM rules:
 * - Word-aligned (32-byte boundaries)
 * - Quadratic cost: 3n + n²/512 (where n = word count)
 * - Memory is zero-initialized
 */

const GasFastestStep = 3n;
const GasQuickStep = 2n;

/**
 * Hardfork enum
 */
export enum Hardfork {
  FRONTIER = 0,
  HOMESTEAD = 1,
  TANGERINE = 2,
  SPURIOUS = 3,
  BYZANTIUM = 4,
  CONSTANTINOPLE = 5,
  ISTANBUL = 6,
  BERLIN = 7,
  LONDON = 8,
  MERGE = 9,
  SHANGHAI = 10,
  CANCUN = 11,
  PRAGUE = 12,
  OSAKA = 13,
}

/**
 * EVM interface that frame references
 */
export interface Evm {
  hardfork: Hardfork;
}

/**
 * Frame interface that handlers operate on
 */
export interface Frame {
  consumeGas(amount: bigint): void;
  popStack(): bigint;
  pushStack(value: bigint): void;
  readMemory(offset: number): number;
  writeMemory(offset: number, value: number): void;
  memoryExpansionCost(endBytes: bigint): bigint;
  getEvm(): Evm;
  pc: number;
  memory_size: number;
  allocator?: {
    alloc(size: number): Uint8Array;
  };
}

/**
 * Helper function for u32 addition with overflow check
 */
function addU32(a: number, b: number): number {
  const result = a + b;
  if (result > 0xffffffff || result < 0) {
    throw new Error('OutOfBounds');
  }
  return result;
}

/**
 * Helper function to calculate word-aligned size
 */
function wordAlignedSize(byteSize: bigint): bigint {
  return ((byteSize + 31n) / 32n) * 32n;
}

/**
 * Helper function to calculate copy gas cost (3 gas per word)
 */
function copyGasCost(sizeBytes: number): bigint {
  const words = Math.floor((sizeBytes + 31) / 32);
  return BigInt(words) * 3n;
}

/**
 * MLOAD opcode (0x51) - Load word from memory
 *
 * Reads 32 bytes from memory at the specified offset.
 * Memory is zero-initialized, so unwritten locations return 0.
 *
 * Gas: GasFastestStep (3) + memory expansion cost
 * Stack: [offset] -> [value]
 */
export function mload(frame: Frame): void {
  const offset = frame.popStack();

  // Check if offset fits in u32 range
  if (offset > 0xffffffffn || offset < 0n) {
    throw new Error('OutOfBounds');
  }
  const off = Number(offset);

  // Charge base + memory expansion for reading 32 bytes
  const endBytes = BigInt(off) + 32n;
  const memCost = frame.memoryExpansionCost(endBytes);
  frame.consumeGas(GasFastestStep + memCost);

  const alignedSize = wordAlignedSize(endBytes);
  const alignedSizeU32 = Number(alignedSize);
  if (alignedSizeU32 > frame.memory_size) {
    frame.memory_size = alignedSizeU32;
  }

  // Read word from memory (big-endian)
  let result = 0n;
  for (let idx = 0; idx < 32; idx++) {
    const addr = addU32(off, idx);
    const byte = frame.readMemory(addr);
    result = (result << 8n) | BigInt(byte);
  }

  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * MSTORE opcode (0x52) - Save word to memory
 *
 * Writes 32 bytes to memory at the specified offset.
 * Value is stored in big-endian format.
 *
 * Gas: GasFastestStep (3) + memory expansion cost
 * Stack: [offset, value] -> []
 */
export function mstore(frame: Frame): void {
  const offset = frame.popStack();
  const value = frame.popStack();

  // Check if offset fits in u32 range
  if (offset > 0xffffffffn || offset < 0n) {
    throw new Error('OutOfBounds');
  }
  const off = Number(offset);

  // Charge base + memory expansion for writing 32 bytes
  const endBytes = BigInt(off) + 32n;
  const memCost = frame.memoryExpansionCost(endBytes);
  frame.consumeGas(GasFastestStep + memCost);

  // Update memory size
  const alignedSize = wordAlignedSize(endBytes);
  const alignedSizeU32 = Number(alignedSize);
  if (alignedSizeU32 > frame.memory_size) {
    frame.memory_size = alignedSizeU32;
  }

  // Write word to memory (big-endian)
  for (let idx = 0; idx < 32; idx++) {
    // Extract byte at position (31 - idx) from right (little-endian position)
    // This gives us big-endian storage
    const shiftAmount = (31 - idx) * 8;
    const byte = Number((value >> BigInt(shiftAmount)) & 0xffn);
    const addr = addU32(off, idx);
    frame.writeMemory(addr, byte);
  }

  frame.pc += 1;
}

/**
 * MSTORE8 opcode (0x53) - Save byte to memory
 *
 * Writes the least significant byte of value to memory.
 * All other bytes of value are ignored.
 *
 * Gas: GasFastestStep (3) + memory expansion cost
 * Stack: [offset, value] -> []
 */
export function mstore8(frame: Frame): void {
  const offset = frame.popStack();
  const value = frame.popStack();

  // Check if offset fits in u32 range
  if (offset > 0xffffffffn || offset < 0n) {
    throw new Error('OutOfBounds');
  }
  const off = Number(offset);

  const endBytes = BigInt(off) + 1n;
  const memCost = frame.memoryExpansionCost(endBytes);
  frame.consumeGas(GasFastestStep + memCost);

  // Update memory size
  const alignedSize = wordAlignedSize(endBytes);
  const alignedSizeU32 = Number(alignedSize);
  if (alignedSizeU32 > frame.memory_size) {
    frame.memory_size = alignedSizeU32;
  }

  const byteValue = Number(value & 0xffn);
  frame.writeMemory(off, byteValue);

  frame.pc += 1;
}

/**
 * MSIZE opcode (0x59) - Get size of active memory in bytes
 *
 * Returns the size of memory currently allocated for this execution context.
 * Memory size is always word-aligned (multiple of 32 bytes).
 *
 * Gas: GasQuickStep (2)
 * Stack: [] -> [size]
 */
export function msize(frame: Frame): void {
  frame.consumeGas(GasQuickStep);
  // Memory size is already tracked as word-aligned in memory_size field
  frame.pushStack(BigInt(frame.memory_size));
  frame.pc += 1;
}

/**
 * MCOPY opcode (0x5e) - Copy memory (EIP-5656, Cancun+)
 *
 * Copies memory from source to destination, handling overlapping regions correctly.
 * This opcode was introduced in the Cancun hardfork.
 *
 * Per EIP-5656:
 * - Zero-length copies charge gas but don't expand memory or copy data
 * - Memory expansion covers BOTH source and destination ranges
 * - Copy cost is 3 gas per word (rounded up)
 * - Uses temporary buffer to handle overlapping regions
 *
 * Gas: GasFastestStep (3) + memory expansion cost + copy cost (3 gas per word)
 * Stack: [dest, src, length] -> []
 */
export function mcopy(frame: Frame): void {
  const evm = frame.getEvm();

  // EIP-5656: MCOPY was introduced in Cancun hardfork
  if (evm.hardfork < Hardfork.CANCUN) {
    throw new Error('InvalidOpcode');
  }

  // Stack order (top to bottom): dest, src, len
  const dest = frame.popStack();
  const src = frame.popStack();
  const len = frame.popStack();

  // Calculate memory expansion cost BEFORE bounds checking
  // Per EIP-5656, if len == 0, no memory expansion occurs regardless of src/dest values
  let memCost: bigint;

  if (len === 0n) {
    memCost = 0n; // Zero-length copies don't expand memory
  } else {
    // Safe conversion: if values don't fit in reasonable range, use large value
    // which will trigger massive gas cost
    const destU64 = dest > BigInt(Number.MAX_SAFE_INTEGER) ? BigInt(Number.MAX_SAFE_INTEGER) : dest;
    const srcU64 = src > BigInt(Number.MAX_SAFE_INTEGER) ? BigInt(Number.MAX_SAFE_INTEGER) : src;
    const lenU64 = len > BigInt(Number.MAX_SAFE_INTEGER) ? BigInt(Number.MAX_SAFE_INTEGER) : len;

    // Calculate end positions for both source and destination
    // Use saturating arithmetic to prevent overflow
    const endDest = destU64 + lenU64;
    const endSrc = srcU64 + lenU64;

    // Memory expansion must cover BOTH ranges - use the maximum
    const maxEnd = endDest > endSrc ? endDest : endSrc;
    memCost = frame.memoryExpansionCost(maxEnd);
  }

  // Calculate copy cost
  let copyCost: bigint;
  if (len <= 0xffffffffn) {
    copyCost = copyGasCost(Number(len));
  } else {
    // Huge value that will trigger OutOfGas
    copyCost = BigInt(Number.MAX_SAFE_INTEGER);
  }

  // Charge gas (use saturating arithmetic to prevent overflow)
  const totalGas = GasFastestStep + memCost + copyCost;
  frame.consumeGas(totalGas);

  // Fast path: zero length - gas charged but no copy needed
  if (len === 0n) {
    frame.pc += 1;
    return;
  }

  // Now that gas is charged, do bounds checking for actual memory operations
  if (dest > 0xffffffffn || dest < 0n ||
      src > 0xffffffffn || src < 0n ||
      len > 0xffffffffn || len < 0n) {
    throw new Error('OutOfBounds');
  }

  const destU32 = Number(dest);
  const srcU32 = Number(src);
  const lenU32 = Number(len);

  // Expand memory to cover BOTH source and destination ranges
  // Per EIP-5656, memory expansion happens before the copy operation
  const srcEnd = BigInt(srcU32) + BigInt(lenU32);
  const destEnd = BigInt(destU32) + BigInt(lenU32);
  const maxMemoryEnd = srcEnd > destEnd ? srcEnd : destEnd;
  const requiredSize = wordAlignedSize(maxMemoryEnd);
  const requiredSizeU32 = Number(requiredSize);

  if (requiredSizeU32 > frame.memory_size) {
    frame.memory_size = requiredSizeU32;
  }

  // Copy via temporary buffer to handle overlapping regions
  const tmp = new Uint8Array(lenU32);

  for (let i = 0; i < lenU32; i++) {
    const s = addU32(srcU32, i);
    tmp[i] = frame.readMemory(s);
  }

  for (let i = 0; i < lenU32; i++) {
    const d = addU32(destU32, i);
    frame.writeMemory(d, tmp[i]);
  }

  frame.pc += 1;
}

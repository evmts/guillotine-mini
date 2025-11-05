/**
 * Bytecode utilities and validation
 * This module provides abstractions for working with EVM bytecode,
 * including jump destination analysis and bytecode traversal.
 */

/**
 * Represents analyzed bytecode with pre-validated jump destinations
 */
export class Bytecode {
  /** Raw bytecode bytes */
  private readonly code: Uint8Array;

  /** Pre-analyzed valid JUMPDEST positions */
  private readonly validJumpdests: Set<number>;

  /**
   * Initialize bytecode with jump destination analysis
   */
  constructor(code: Uint8Array) {
    this.code = code;
    this.validJumpdests = new Set();
    this.analyzeJumpDests();
  }

  /**
   * Check if a position is a valid JUMPDEST
   */
  isValidJumpDest(pc: number): boolean {
    return this.validJumpdests.has(pc);
  }

  /**
   * Get bytecode length
   */
  get length(): number {
    return this.code.length;
  }

  /**
   * Get opcode at position
   */
  getOpcode(pc: number): number | null {
    if (pc >= this.code.length) {
      return null;
    }
    const opcode = this.code[pc];
    return opcode !== undefined ? opcode : null;
  }

  /**
   * Read immediate data for PUSH operations
   * Returns the N bytes following the current PC (for PUSHN instructions)
   */
  readImmediate(pc: number, size: number): bigint | null {
    // Check if we have enough bytes: current position + 1 (opcode) + size
    if (pc + 1 + size > this.code.length) {
      return null;
    }

    let result = 0n;
    for (let i = 0; i < size; i++) {
      const byte = this.code[pc + 1 + i];
      if (byte === undefined) {
        return null;
      }
      result = (result << 8n) | BigInt(byte);
    }
    return result;
  }

  /**
   * Analyze bytecode to identify valid JUMPDEST locations
   * This must skip over PUSH instruction immediate data to avoid
   * treating data bytes as instructions
   */
  private analyzeJumpDests(): void {
    let pc = 0;

    while (pc < this.code.length) {
      const opcode = this.code[pc];

      // Handle undefined case (should not happen with bounds check, but satisfy TypeScript)
      if (opcode === undefined) {
        break;
      }

      // Check if this is a JUMPDEST (0x5b)
      if (opcode === 0x5b) {
        this.validJumpdests.add(pc);
        pc += 1;
      } else if (opcode >= 0x60 && opcode <= 0x7f) {
        // PUSH1 (0x60) through PUSH32 (0x7f)
        // Calculate number of bytes to push: opcode - 0x5f
        // e.g., PUSH1 (0x60) = 0x60 - 0x5f = 1 byte
        //       PUSH32 (0x7f) = 0x7f - 0x5f = 32 bytes
        const pushSize = opcode - 0x5f;

        // Skip the PUSH opcode itself and all its immediate data bytes
        // This prevents treating immediate data as opcodes
        pc += 1 + pushSize;
      } else {
        // All other opcodes are single byte
        pc += 1;
      }
    }
  }
}

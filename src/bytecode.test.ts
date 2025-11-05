import { describe, expect, test } from "bun:test";
import { Bytecode } from "./bytecode";

describe("Bytecode", () => {
  describe("analyzeJumpDests", () => {
    test("simple JUMPDEST", () => {
      // JUMPDEST, STOP, JUMPDEST
      const code = new Uint8Array([0x5b, 0x00, 0x5b]);
      const bytecode = new Bytecode(code);

      expect(bytecode.isValidJumpDest(0)).toBe(true);
      expect(bytecode.isValidJumpDest(2)).toBe(true);
      expect(bytecode.isValidJumpDest(1)).toBe(false);
    });

    test("PUSH data containing JUMPDEST opcode", () => {
      const code = new Uint8Array([
        0x60, 0x5b, // PUSH1 0x5b (pushes JUMPDEST opcode as data)
        0x5b, // JUMPDEST (actual valid jump destination)
      ]);
      const bytecode = new Bytecode(code);

      // Only position 2 should be valid (the actual JUMPDEST)
      // Position 1 (the 0x5b in PUSH data) should NOT be valid
      expect(bytecode.isValidJumpDest(0)).toBe(false);
      expect(bytecode.isValidJumpDest(1)).toBe(false);
      expect(bytecode.isValidJumpDest(2)).toBe(true);
    });

    test("PUSH32 with embedded JUMPDEST bytes", () => {
      const code = new Uint8Array(34);
      code[0] = 0x7f; // PUSH32
      // Fill with 32 bytes of data, including some 0x5b (JUMPDEST) bytes
      for (let i = 1; i < 33; i++) {
        code[i] = i % 2 === 0 ? 0x5b : 0x00;
      }
      code[33] = 0x5b; // Actual JUMPDEST after PUSH32

      const bytecode = new Bytecode(code);

      // Only position 33 should be valid
      expect(bytecode.isValidJumpDest(0)).toBe(false);
      for (let i = 1; i < 33; i++) {
        expect(bytecode.isValidJumpDest(i)).toBe(false);
      }
      expect(bytecode.isValidJumpDest(33)).toBe(true);
    });

    test("empty bytecode", () => {
      const code = new Uint8Array([]);
      const bytecode = new Bytecode(code);

      expect(bytecode.length).toBe(0);
      expect(bytecode.isValidJumpDest(0)).toBe(false);
    });

    test("all PUSH operations", () => {
      // Test all PUSH1-PUSH32 skip immediate data correctly
      for (let pushSize = 1; pushSize <= 32; pushSize++) {
        const opcode = 0x60 + pushSize - 1; // PUSH1 = 0x60, PUSH32 = 0x7f
        const code = new Uint8Array(1 + pushSize + 1);
        code[0] = opcode;
        // Fill immediate data with 0x5b (JUMPDEST opcode)
        for (let i = 1; i <= pushSize; i++) {
          code[i] = 0x5b;
        }
        code[1 + pushSize] = 0x5b; // Actual JUMPDEST

        const bytecode = new Bytecode(code);

        // Only the JUMPDEST after PUSH data should be valid
        expect(bytecode.isValidJumpDest(0)).toBe(false);
        for (let i = 1; i <= pushSize; i++) {
          expect(bytecode.isValidJumpDest(i)).toBe(false);
        }
        expect(bytecode.isValidJumpDest(1 + pushSize)).toBe(true);
      }
    });

    test("multiple JUMPDESTs in sequence", () => {
      // Multiple consecutive JUMPDESTs
      const code = new Uint8Array([0x5b, 0x5b, 0x5b, 0x5b]);
      const bytecode = new Bytecode(code);

      expect(bytecode.isValidJumpDest(0)).toBe(true);
      expect(bytecode.isValidJumpDest(1)).toBe(true);
      expect(bytecode.isValidJumpDest(2)).toBe(true);
      expect(bytecode.isValidJumpDest(3)).toBe(true);
    });

    test("JUMPDEST at end of bytecode", () => {
      const code = new Uint8Array([0x60, 0x01, 0x5b]);
      const bytecode = new Bytecode(code);

      expect(bytecode.isValidJumpDest(2)).toBe(true);
    });

    test("incomplete PUSH at end of bytecode", () => {
      // PUSH2 but only 1 byte of data (truncated bytecode)
      const code = new Uint8Array([0x61, 0x01]);
      const bytecode = new Bytecode(code);

      // Should not crash, just skip remaining bytes
      expect(bytecode.length).toBe(2);
      expect(bytecode.isValidJumpDest(0)).toBe(false);
      expect(bytecode.isValidJumpDest(1)).toBe(false);
    });
  });

  describe("initialization and queries", () => {
    test("basic bytecode queries", () => {
      // PUSH1 1, JUMPDEST, STOP
      const code = new Uint8Array([0x60, 0x01, 0x5b, 0x00]);
      const bytecode = new Bytecode(code);

      expect(bytecode.length).toBe(4);
      expect(bytecode.isValidJumpDest(0)).toBe(false);
      expect(bytecode.isValidJumpDest(1)).toBe(false);
      expect(bytecode.isValidJumpDest(2)).toBe(true);
      expect(bytecode.isValidJumpDest(3)).toBe(false);
    });

    test("getOpcode returns correct values", () => {
      const code = new Uint8Array([0x60, 0x01, 0x5b, 0x00]);
      const bytecode = new Bytecode(code);

      expect(bytecode.getOpcode(0)).toBe(0x60);
      expect(bytecode.getOpcode(1)).toBe(0x01);
      expect(bytecode.getOpcode(2)).toBe(0x5b);
      expect(bytecode.getOpcode(3)).toBe(0x00);
      expect(bytecode.getOpcode(4)).toBe(null);
    });
  });

  describe("readImmediate", () => {
    test("read PUSH1 and PUSH2 immediate values", () => {
      // PUSH1 0xff, PUSH2 0x1234
      const code = new Uint8Array([0x60, 0xff, 0x61, 0x12, 0x34]);
      const bytecode = new Bytecode(code);

      // Read PUSH1 immediate (1 byte)
      const value1 = bytecode.readImmediate(0, 1);
      expect(value1).toBe(0xffn);

      // Read PUSH2 immediate (2 bytes)
      const value2 = bytecode.readImmediate(2, 2);
      expect(value2).toBe(0x1234n);
    });

    test("read beyond bytecode returns null", () => {
      const code = new Uint8Array([0x60, 0xff, 0x61, 0x12, 0x34]);
      const bytecode = new Bytecode(code);

      // Try to read beyond bytecode
      expect(bytecode.readImmediate(3, 2)).toBe(null);
      expect(bytecode.readImmediate(4, 1)).toBe(null);
    });

    test("read PUSH32 immediate", () => {
      const code = new Uint8Array(33);
      code[0] = 0x7f; // PUSH32
      // Fill with sequential bytes
      for (let i = 1; i <= 32; i++) {
        code[i] = i;
      }

      const bytecode = new Bytecode(code);
      const value = bytecode.readImmediate(0, 32);

      // Verify big-endian reading
      let expected = 0n;
      for (let i = 1; i <= 32; i++) {
        expected = (expected << 8n) | BigInt(i);
      }
      expect(value).toBe(expected);
    });

    test("read zero-length immediate", () => {
      const code = new Uint8Array([0x60, 0xff]);
      const bytecode = new Bytecode(code);

      const value = bytecode.readImmediate(0, 0);
      expect(value).toBe(0n);
    });

    test("read at exact boundary", () => {
      const code = new Uint8Array([0x60, 0xff, 0x00]);
      const bytecode = new Bytecode(code);

      // readImmediate(pc, size) reads size bytes starting at pc+1
      // At pc=0, reading 1 byte gets code[1] = 0xff
      expect(bytecode.readImmediate(0, 1)).toBe(0xffn);

      // At pc=0, reading 2 bytes would need code[1] and code[2]
      expect(bytecode.readImmediate(0, 2)).toBe(0xff00n);

      // At pc=1, reading 1 byte would need code[2] = 0x00
      expect(bytecode.readImmediate(1, 1)).toBe(0x00n);

      // At pc=1, reading 2 bytes would need code[2] and code[3] (out of bounds)
      expect(bytecode.readImmediate(1, 2)).toBe(null);
    });
  });

  describe("edge cases", () => {
    test("bytecode with only PUSH operations", () => {
      const code = new Uint8Array([
        0x60, 0x01, // PUSH1 1
        0x61, 0x02, 0x03, // PUSH2 0x0203
        0x7f, ...new Array(32).fill(0x00), // PUSH32 (32 zeros)
      ]);
      const bytecode = new Bytecode(code);

      // No JUMPDESTs should be found
      for (let i = 0; i < bytecode.length; i++) {
        expect(bytecode.isValidJumpDest(i)).toBe(false);
      }
    });

    test("bytecode with only JUMPDESTs", () => {
      const code = new Uint8Array(10).fill(0x5b);
      const bytecode = new Bytecode(code);

      // All positions should be valid JUMPDESTs
      for (let i = 0; i < bytecode.length; i++) {
        expect(bytecode.isValidJumpDest(i)).toBe(true);
      }
    });

    test("real-world example: simple contract", () => {
      // Simplified contract bytecode pattern:
      // PUSH1 0x80, PUSH1 0x40, MSTORE (constructor stores free memory pointer)
      // JUMPDEST, PUSH1 0x00, PUSH1 0x00, RETURN (entry point)
      const code = new Uint8Array([
        0x60, 0x80, // PUSH1 0x80
        0x60, 0x40, // PUSH1 0x40
        0x52, // MSTORE
        0x5b, // JUMPDEST (position 5)
        0x60, 0x00, // PUSH1 0x00
        0x60, 0x00, // PUSH1 0x00
        0xf3, // RETURN
      ]);
      const bytecode = new Bytecode(code);

      expect(bytecode.isValidJumpDest(5)).toBe(true);
      expect(bytecode.isValidJumpDest(0)).toBe(false);
      expect(bytecode.isValidJumpDest(1)).toBe(false);
      expect(bytecode.isValidJumpDest(10)).toBe(false);
    });
  });
});

/**
 * Tests for opcode utilities
 * Port of opcode.zig tests to TypeScript
 */

import { describe, it, expect } from 'vitest';
import {
  getOpName,
  // Arithmetic
  STOP, ADD, MUL, SUB, DIV, SDIV, MOD, SMOD, ADDMOD, MULMOD, EXP, SIGNEXTEND,
  // Comparison
  LT, GT, SLT, SGT, EQ, ISZERO,
  // Bitwise
  AND, OR, XOR, NOT, BYTE, SHL, SHR, SAR,
  // Hash
  KECCAK256,
  // Context
  ADDRESS, BALANCE, ORIGIN, CALLER, CALLVALUE, CALLDATALOAD, CALLDATASIZE,
  CALLDATACOPY, CODESIZE, CODECOPY, GASPRICE, EXTCODESIZE, EXTCODECOPY,
  RETURNDATASIZE, RETURNDATACOPY, EXTCODEHASH,
  // Block
  BLOCKHASH, COINBASE, TIMESTAMP, NUMBER, DIFFICULTY, GASLIMIT, CHAINID,
  SELFBALANCE, BASEFEE, BLOBHASH, BLOBBASEFEE,
  // Stack/Memory/Storage
  POP, MLOAD, MSTORE, MSTORE8, SLOAD, SSTORE, JUMP, JUMPI, PC, MSIZE, GAS,
  JUMPDEST, TLOAD, TSTORE, MCOPY,
  // PUSH
  PUSH0, PUSH1, PUSH2, PUSH16, PUSH32,
  // DUP
  DUP1, DUP2, DUP8, DUP16,
  // SWAP
  SWAP1, SWAP2, SWAP8, SWAP16,
  // LOG
  LOG0, LOG1, LOG2, LOG3, LOG4,
  // System
  CREATE, CALL, CALLCODE, RETURN, DELEGATECALL, CREATE2, STATICCALL,
  REVERT, INVALID, SELFDESTRUCT,
} from './opcode';

describe('getOpName', () => {
  describe('arithmetic opcodes', () => {
    it('should return correct names for arithmetic operations', () => {
      expect(getOpName(0x00)).toBe('STOP');
      expect(getOpName(0x01)).toBe('ADD');
      expect(getOpName(0x02)).toBe('MUL');
      expect(getOpName(0x03)).toBe('SUB');
      expect(getOpName(0x04)).toBe('DIV');
      expect(getOpName(0x05)).toBe('SDIV');
      expect(getOpName(0x06)).toBe('MOD');
      expect(getOpName(0x07)).toBe('SMOD');
      expect(getOpName(0x08)).toBe('ADDMOD');
      expect(getOpName(0x09)).toBe('MULMOD');
      expect(getOpName(0x0a)).toBe('EXP');
      expect(getOpName(0x0b)).toBe('SIGNEXTEND');
    });

    it('should match constant values', () => {
      expect(getOpName(STOP)).toBe('STOP');
      expect(getOpName(ADD)).toBe('ADD');
      expect(getOpName(MUL)).toBe('MUL');
      expect(getOpName(SUB)).toBe('SUB');
      expect(getOpName(DIV)).toBe('DIV');
      expect(getOpName(SDIV)).toBe('SDIV');
      expect(getOpName(MOD)).toBe('MOD');
      expect(getOpName(SMOD)).toBe('SMOD');
      expect(getOpName(ADDMOD)).toBe('ADDMOD');
      expect(getOpName(MULMOD)).toBe('MULMOD');
      expect(getOpName(EXP)).toBe('EXP');
      expect(getOpName(SIGNEXTEND)).toBe('SIGNEXTEND');
    });
  });

  describe('comparison opcodes', () => {
    it('should return correct names for comparison operations', () => {
      expect(getOpName(0x10)).toBe('LT');
      expect(getOpName(0x11)).toBe('GT');
      expect(getOpName(0x12)).toBe('SLT');
      expect(getOpName(0x13)).toBe('SGT');
      expect(getOpName(0x14)).toBe('EQ');
      expect(getOpName(0x15)).toBe('ISZERO');
    });

    it('should match constant values', () => {
      expect(getOpName(LT)).toBe('LT');
      expect(getOpName(GT)).toBe('GT');
      expect(getOpName(SLT)).toBe('SLT');
      expect(getOpName(SGT)).toBe('SGT');
      expect(getOpName(EQ)).toBe('EQ');
      expect(getOpName(ISZERO)).toBe('ISZERO');
    });
  });

  describe('bitwise opcodes', () => {
    it('should return correct names for bitwise operations', () => {
      expect(getOpName(0x16)).toBe('AND');
      expect(getOpName(0x17)).toBe('OR');
      expect(getOpName(0x18)).toBe('XOR');
      expect(getOpName(0x19)).toBe('NOT');
      expect(getOpName(0x1a)).toBe('BYTE');
      expect(getOpName(0x1b)).toBe('SHL');
      expect(getOpName(0x1c)).toBe('SHR');
      expect(getOpName(0x1d)).toBe('SAR');
    });

    it('should match constant values', () => {
      expect(getOpName(AND)).toBe('AND');
      expect(getOpName(OR)).toBe('OR');
      expect(getOpName(XOR)).toBe('XOR');
      expect(getOpName(NOT)).toBe('NOT');
      expect(getOpName(BYTE)).toBe('BYTE');
      expect(getOpName(SHL)).toBe('SHL');
      expect(getOpName(SHR)).toBe('SHR');
      expect(getOpName(SAR)).toBe('SAR');
    });
  });

  describe('hash opcodes', () => {
    it('should return correct name for hash operations', () => {
      expect(getOpName(0x20)).toBe('KECCAK256');
    });

    it('should match constant value', () => {
      expect(getOpName(KECCAK256)).toBe('KECCAK256');
    });
  });

  describe('context opcodes', () => {
    it('should return correct names for context operations', () => {
      expect(getOpName(0x30)).toBe('ADDRESS');
      expect(getOpName(0x31)).toBe('BALANCE');
      expect(getOpName(0x32)).toBe('ORIGIN');
      expect(getOpName(0x33)).toBe('CALLER');
      expect(getOpName(0x34)).toBe('CALLVALUE');
      expect(getOpName(0x35)).toBe('CALLDATALOAD');
      expect(getOpName(0x36)).toBe('CALLDATASIZE');
      expect(getOpName(0x37)).toBe('CALLDATACOPY');
      expect(getOpName(0x38)).toBe('CODESIZE');
      expect(getOpName(0x39)).toBe('CODECOPY');
      expect(getOpName(0x3a)).toBe('GASPRICE');
      expect(getOpName(0x3b)).toBe('EXTCODESIZE');
      expect(getOpName(0x3c)).toBe('EXTCODECOPY');
      expect(getOpName(0x3d)).toBe('RETURNDATASIZE');
      expect(getOpName(0x3e)).toBe('RETURNDATACOPY');
      expect(getOpName(0x3f)).toBe('EXTCODEHASH');
    });

    it('should match constant values', () => {
      expect(getOpName(ADDRESS)).toBe('ADDRESS');
      expect(getOpName(BALANCE)).toBe('BALANCE');
      expect(getOpName(ORIGIN)).toBe('ORIGIN');
      expect(getOpName(CALLER)).toBe('CALLER');
      expect(getOpName(CALLVALUE)).toBe('CALLVALUE');
      expect(getOpName(CALLDATALOAD)).toBe('CALLDATALOAD');
      expect(getOpName(CALLDATASIZE)).toBe('CALLDATASIZE');
      expect(getOpName(CALLDATACOPY)).toBe('CALLDATACOPY');
      expect(getOpName(CODESIZE)).toBe('CODESIZE');
      expect(getOpName(CODECOPY)).toBe('CODECOPY');
      expect(getOpName(GASPRICE)).toBe('GASPRICE');
      expect(getOpName(EXTCODESIZE)).toBe('EXTCODESIZE');
      expect(getOpName(EXTCODECOPY)).toBe('EXTCODECOPY');
      expect(getOpName(RETURNDATASIZE)).toBe('RETURNDATASIZE');
      expect(getOpName(RETURNDATACOPY)).toBe('RETURNDATACOPY');
      expect(getOpName(EXTCODEHASH)).toBe('EXTCODEHASH');
    });
  });

  describe('block opcodes', () => {
    it('should return correct names for block operations', () => {
      expect(getOpName(0x40)).toBe('BLOCKHASH');
      expect(getOpName(0x41)).toBe('COINBASE');
      expect(getOpName(0x42)).toBe('TIMESTAMP');
      expect(getOpName(0x43)).toBe('NUMBER');
      expect(getOpName(0x44)).toBe('DIFFICULTY');
      expect(getOpName(0x45)).toBe('GASLIMIT');
      expect(getOpName(0x46)).toBe('CHAINID');
      expect(getOpName(0x47)).toBe('SELFBALANCE');
      expect(getOpName(0x48)).toBe('BASEFEE');
      expect(getOpName(0x49)).toBe('BLOBHASH');
      expect(getOpName(0x4a)).toBe('BLOBBASEFEE');
    });

    it('should match constant values', () => {
      expect(getOpName(BLOCKHASH)).toBe('BLOCKHASH');
      expect(getOpName(COINBASE)).toBe('COINBASE');
      expect(getOpName(TIMESTAMP)).toBe('TIMESTAMP');
      expect(getOpName(NUMBER)).toBe('NUMBER');
      expect(getOpName(DIFFICULTY)).toBe('DIFFICULTY');
      expect(getOpName(GASLIMIT)).toBe('GASLIMIT');
      expect(getOpName(CHAINID)).toBe('CHAINID');
      expect(getOpName(SELFBALANCE)).toBe('SELFBALANCE');
      expect(getOpName(BASEFEE)).toBe('BASEFEE');
      expect(getOpName(BLOBHASH)).toBe('BLOBHASH');
      expect(getOpName(BLOBBASEFEE)).toBe('BLOBBASEFEE');
    });
  });

  describe('stack and memory opcodes', () => {
    it('should return correct names for stack/memory/storage operations', () => {
      expect(getOpName(0x50)).toBe('POP');
      expect(getOpName(0x51)).toBe('MLOAD');
      expect(getOpName(0x52)).toBe('MSTORE');
      expect(getOpName(0x53)).toBe('MSTORE8');
      expect(getOpName(0x54)).toBe('SLOAD');
      expect(getOpName(0x55)).toBe('SSTORE');
      expect(getOpName(0x56)).toBe('JUMP');
      expect(getOpName(0x57)).toBe('JUMPI');
      expect(getOpName(0x58)).toBe('PC');
      expect(getOpName(0x59)).toBe('MSIZE');
      expect(getOpName(0x5a)).toBe('GAS');
      expect(getOpName(0x5b)).toBe('JUMPDEST');
      expect(getOpName(0x5c)).toBe('TLOAD');
      expect(getOpName(0x5d)).toBe('TSTORE');
      expect(getOpName(0x5e)).toBe('MCOPY');
    });

    it('should match constant values', () => {
      expect(getOpName(POP)).toBe('POP');
      expect(getOpName(MLOAD)).toBe('MLOAD');
      expect(getOpName(MSTORE)).toBe('MSTORE');
      expect(getOpName(MSTORE8)).toBe('MSTORE8');
      expect(getOpName(SLOAD)).toBe('SLOAD');
      expect(getOpName(SSTORE)).toBe('SSTORE');
      expect(getOpName(JUMP)).toBe('JUMP');
      expect(getOpName(JUMPI)).toBe('JUMPI');
      expect(getOpName(PC)).toBe('PC');
      expect(getOpName(MSIZE)).toBe('MSIZE');
      expect(getOpName(GAS)).toBe('GAS');
      expect(getOpName(JUMPDEST)).toBe('JUMPDEST');
      expect(getOpName(TLOAD)).toBe('TLOAD');
      expect(getOpName(TSTORE)).toBe('TSTORE');
      expect(getOpName(MCOPY)).toBe('MCOPY');
    });
  });

  describe('PUSH opcodes', () => {
    it('should return correct names for PUSH operations', () => {
      expect(getOpName(0x5f)).toBe('PUSH0');
      expect(getOpName(0x60)).toBe('PUSH1');
      expect(getOpName(0x61)).toBe('PUSH2');
      expect(getOpName(0x62)).toBe('PUSH3');
      expect(getOpName(0x63)).toBe('PUSH4');
      expect(getOpName(0x64)).toBe('PUSH5');
      expect(getOpName(0x65)).toBe('PUSH6');
      expect(getOpName(0x66)).toBe('PUSH7');
      expect(getOpName(0x67)).toBe('PUSH8');
      expect(getOpName(0x68)).toBe('PUSH9');
      expect(getOpName(0x69)).toBe('PUSH10');
      expect(getOpName(0x6a)).toBe('PUSH11');
      expect(getOpName(0x6b)).toBe('PUSH12');
      expect(getOpName(0x6c)).toBe('PUSH13');
      expect(getOpName(0x6d)).toBe('PUSH14');
      expect(getOpName(0x6e)).toBe('PUSH15');
      expect(getOpName(0x6f)).toBe('PUSH16');
      expect(getOpName(0x70)).toBe('PUSH17');
      expect(getOpName(0x71)).toBe('PUSH18');
      expect(getOpName(0x72)).toBe('PUSH19');
      expect(getOpName(0x73)).toBe('PUSH20');
      expect(getOpName(0x74)).toBe('PUSH21');
      expect(getOpName(0x75)).toBe('PUSH22');
      expect(getOpName(0x76)).toBe('PUSH23');
      expect(getOpName(0x77)).toBe('PUSH24');
      expect(getOpName(0x78)).toBe('PUSH25');
      expect(getOpName(0x79)).toBe('PUSH26');
      expect(getOpName(0x7a)).toBe('PUSH27');
      expect(getOpName(0x7b)).toBe('PUSH28');
      expect(getOpName(0x7c)).toBe('PUSH29');
      expect(getOpName(0x7d)).toBe('PUSH30');
      expect(getOpName(0x7e)).toBe('PUSH31');
      expect(getOpName(0x7f)).toBe('PUSH32');
    });

    it('should match constant values', () => {
      expect(getOpName(PUSH0)).toBe('PUSH0');
      expect(getOpName(PUSH1)).toBe('PUSH1');
      expect(getOpName(PUSH2)).toBe('PUSH2');
      expect(getOpName(PUSH16)).toBe('PUSH16');
      expect(getOpName(PUSH32)).toBe('PUSH32');
    });
  });

  describe('DUP opcodes', () => {
    it('should return correct names for DUP operations', () => {
      expect(getOpName(0x80)).toBe('DUP1');
      expect(getOpName(0x81)).toBe('DUP2');
      expect(getOpName(0x82)).toBe('DUP3');
      expect(getOpName(0x83)).toBe('DUP4');
      expect(getOpName(0x84)).toBe('DUP5');
      expect(getOpName(0x85)).toBe('DUP6');
      expect(getOpName(0x86)).toBe('DUP7');
      expect(getOpName(0x87)).toBe('DUP8');
      expect(getOpName(0x88)).toBe('DUP9');
      expect(getOpName(0x89)).toBe('DUP10');
      expect(getOpName(0x8a)).toBe('DUP11');
      expect(getOpName(0x8b)).toBe('DUP12');
      expect(getOpName(0x8c)).toBe('DUP13');
      expect(getOpName(0x8d)).toBe('DUP14');
      expect(getOpName(0x8e)).toBe('DUP15');
      expect(getOpName(0x8f)).toBe('DUP16');
    });

    it('should match constant values', () => {
      expect(getOpName(DUP1)).toBe('DUP1');
      expect(getOpName(DUP2)).toBe('DUP2');
      expect(getOpName(DUP8)).toBe('DUP8');
      expect(getOpName(DUP16)).toBe('DUP16');
    });
  });

  describe('SWAP opcodes', () => {
    it('should return correct names for SWAP operations', () => {
      expect(getOpName(0x90)).toBe('SWAP1');
      expect(getOpName(0x91)).toBe('SWAP2');
      expect(getOpName(0x92)).toBe('SWAP3');
      expect(getOpName(0x93)).toBe('SWAP4');
      expect(getOpName(0x94)).toBe('SWAP5');
      expect(getOpName(0x95)).toBe('SWAP6');
      expect(getOpName(0x96)).toBe('SWAP7');
      expect(getOpName(0x97)).toBe('SWAP8');
      expect(getOpName(0x98)).toBe('SWAP9');
      expect(getOpName(0x99)).toBe('SWAP10');
      expect(getOpName(0x9a)).toBe('SWAP11');
      expect(getOpName(0x9b)).toBe('SWAP12');
      expect(getOpName(0x9c)).toBe('SWAP13');
      expect(getOpName(0x9d)).toBe('SWAP14');
      expect(getOpName(0x9e)).toBe('SWAP15');
      expect(getOpName(0x9f)).toBe('SWAP16');
    });

    it('should match constant values', () => {
      expect(getOpName(SWAP1)).toBe('SWAP1');
      expect(getOpName(SWAP2)).toBe('SWAP2');
      expect(getOpName(SWAP8)).toBe('SWAP8');
      expect(getOpName(SWAP16)).toBe('SWAP16');
    });
  });

  describe('LOG opcodes', () => {
    it('should return correct names for LOG operations', () => {
      expect(getOpName(0xa0)).toBe('LOG0');
      expect(getOpName(0xa1)).toBe('LOG1');
      expect(getOpName(0xa2)).toBe('LOG2');
      expect(getOpName(0xa3)).toBe('LOG3');
      expect(getOpName(0xa4)).toBe('LOG4');
    });

    it('should match constant values', () => {
      expect(getOpName(LOG0)).toBe('LOG0');
      expect(getOpName(LOG1)).toBe('LOG1');
      expect(getOpName(LOG2)).toBe('LOG2');
      expect(getOpName(LOG3)).toBe('LOG3');
      expect(getOpName(LOG4)).toBe('LOG4');
    });
  });

  describe('system opcodes', () => {
    it('should return correct names for system operations', () => {
      expect(getOpName(0xf0)).toBe('CREATE');
      expect(getOpName(0xf1)).toBe('CALL');
      expect(getOpName(0xf2)).toBe('CALLCODE');
      expect(getOpName(0xf3)).toBe('RETURN');
      expect(getOpName(0xf4)).toBe('DELEGATECALL');
      expect(getOpName(0xf5)).toBe('CREATE2');
      expect(getOpName(0xfa)).toBe('STATICCALL');
      expect(getOpName(0xfd)).toBe('REVERT');
      expect(getOpName(0xfe)).toBe('INVALID');
      expect(getOpName(0xff)).toBe('SELFDESTRUCT');
    });

    it('should match constant values', () => {
      expect(getOpName(CREATE)).toBe('CREATE');
      expect(getOpName(CALL)).toBe('CALL');
      expect(getOpName(CALLCODE)).toBe('CALLCODE');
      expect(getOpName(RETURN)).toBe('RETURN');
      expect(getOpName(DELEGATECALL)).toBe('DELEGATECALL');
      expect(getOpName(CREATE2)).toBe('CREATE2');
      expect(getOpName(STATICCALL)).toBe('STATICCALL');
      expect(getOpName(REVERT)).toBe('REVERT');
      expect(getOpName(INVALID)).toBe('INVALID');
      expect(getOpName(SELFDESTRUCT)).toBe('SELFDESTRUCT');
    });
  });

  describe('invalid opcodes', () => {
    it('should return UNKNOWN for invalid opcodes', () => {
      expect(getOpName(0x0c)).toBe('UNKNOWN');
      expect(getOpName(0x21)).toBe('UNKNOWN');
      expect(getOpName(0xa5)).toBe('UNKNOWN');
      expect(getOpName(0xf6)).toBe('UNKNOWN');
      expect(getOpName(0xfb)).toBe('UNKNOWN');
      expect(getOpName(0xfc)).toBe('UNKNOWN');
    });

    it('should return UNKNOWN for gaps in the opcode space', () => {
      // Gap between SIGNEXTEND (0x0b) and LT (0x10)
      expect(getOpName(0x0c)).toBe('UNKNOWN');
      expect(getOpName(0x0d)).toBe('UNKNOWN');
      expect(getOpName(0x0e)).toBe('UNKNOWN');
      expect(getOpName(0x0f)).toBe('UNKNOWN');

      // Gap between KECCAK256 (0x20) and ADDRESS (0x30)
      expect(getOpName(0x21)).toBe('UNKNOWN');
      expect(getOpName(0x2f)).toBe('UNKNOWN');

      // Gap between LOG4 (0xa4) and CREATE (0xf0)
      expect(getOpName(0xa5)).toBe('UNKNOWN');
      expect(getOpName(0xef)).toBe('UNKNOWN');

      // Gap between CREATE2 (0xf5) and STATICCALL (0xfa)
      expect(getOpName(0xf6)).toBe('UNKNOWN');
      expect(getOpName(0xf7)).toBe('UNKNOWN');
      expect(getOpName(0xf8)).toBe('UNKNOWN');
      expect(getOpName(0xf9)).toBe('UNKNOWN');

      // Gap between STATICCALL (0xfa) and REVERT (0xfd)
      expect(getOpName(0xfb)).toBe('UNKNOWN');
      expect(getOpName(0xfc)).toBe('UNKNOWN');
    });
  });

  describe('opcode constant values', () => {
    it('should have correct values for all exported constants', () => {
      // Arithmetic
      expect(STOP).toBe(0x00);
      expect(ADD).toBe(0x01);
      expect(MUL).toBe(0x02);
      expect(SUB).toBe(0x03);
      expect(DIV).toBe(0x04);
      expect(SDIV).toBe(0x05);
      expect(MOD).toBe(0x06);
      expect(SMOD).toBe(0x07);
      expect(ADDMOD).toBe(0x08);
      expect(MULMOD).toBe(0x09);
      expect(EXP).toBe(0x0a);
      expect(SIGNEXTEND).toBe(0x0b);

      // Comparison
      expect(LT).toBe(0x10);
      expect(GT).toBe(0x11);
      expect(SLT).toBe(0x12);
      expect(SGT).toBe(0x13);
      expect(EQ).toBe(0x14);
      expect(ISZERO).toBe(0x15);

      // Bitwise
      expect(AND).toBe(0x16);
      expect(OR).toBe(0x17);
      expect(XOR).toBe(0x18);
      expect(NOT).toBe(0x19);
      expect(BYTE).toBe(0x1a);
      expect(SHL).toBe(0x1b);
      expect(SHR).toBe(0x1c);
      expect(SAR).toBe(0x1d);

      // Hash
      expect(KECCAK256).toBe(0x20);

      // Context
      expect(ADDRESS).toBe(0x30);
      expect(BALANCE).toBe(0x31);
      expect(ORIGIN).toBe(0x32);
      expect(CALLER).toBe(0x33);
      expect(CALLVALUE).toBe(0x34);

      // Block
      expect(BLOCKHASH).toBe(0x40);
      expect(COINBASE).toBe(0x41);
      expect(TIMESTAMP).toBe(0x42);
      expect(BASEFEE).toBe(0x48);
      expect(BLOBHASH).toBe(0x49);
      expect(BLOBBASEFEE).toBe(0x4a);

      // Stack/Memory/Storage
      expect(POP).toBe(0x50);
      expect(MLOAD).toBe(0x51);
      expect(SLOAD).toBe(0x54);
      expect(SSTORE).toBe(0x55);
      expect(TLOAD).toBe(0x5c);
      expect(TSTORE).toBe(0x5d);
      expect(MCOPY).toBe(0x5e);

      // PUSH
      expect(PUSH0).toBe(0x5f);
      expect(PUSH1).toBe(0x60);
      expect(PUSH32).toBe(0x7f);

      // DUP
      expect(DUP1).toBe(0x80);
      expect(DUP16).toBe(0x8f);

      // SWAP
      expect(SWAP1).toBe(0x90);
      expect(SWAP16).toBe(0x9f);

      // LOG
      expect(LOG0).toBe(0xa0);
      expect(LOG4).toBe(0xa4);

      // System
      expect(CREATE).toBe(0xf0);
      expect(CALL).toBe(0xf1);
      expect(RETURN).toBe(0xf3);
      expect(CREATE2).toBe(0xf5);
      expect(STATICCALL).toBe(0xfa);
      expect(REVERT).toBe(0xfd);
      expect(INVALID).toBe(0xfe);
      expect(SELFDESTRUCT).toBe(0xff);
    });
  });
});

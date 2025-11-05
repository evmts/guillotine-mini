/**
 * EVM Opcode utilities and constants
 * Port of src/opcode.zig to TypeScript
 */

// Arithmetic operations (0x00-0x0b)
export const STOP = 0x00;
export const ADD = 0x01;
export const MUL = 0x02;
export const SUB = 0x03;
export const DIV = 0x04;
export const SDIV = 0x05;
export const MOD = 0x06;
export const SMOD = 0x07;
export const ADDMOD = 0x08;
export const MULMOD = 0x09;
export const EXP = 0x0a;
export const SIGNEXTEND = 0x0b;

// Comparison operations (0x10-0x15)
export const LT = 0x10;
export const GT = 0x11;
export const SLT = 0x12;
export const SGT = 0x13;
export const EQ = 0x14;
export const ISZERO = 0x15;

// Bitwise operations (0x16-0x1d)
export const AND = 0x16;
export const OR = 0x17;
export const XOR = 0x18;
export const NOT = 0x19;
export const BYTE = 0x1a;
export const SHL = 0x1b;
export const SHR = 0x1c;
export const SAR = 0x1d;

// Hash operations (0x20)
export const KECCAK256 = 0x20;

// Context operations (0x30-0x3f)
export const ADDRESS = 0x30;
export const BALANCE = 0x31;
export const ORIGIN = 0x32;
export const CALLER = 0x33;
export const CALLVALUE = 0x34;
export const CALLDATALOAD = 0x35;
export const CALLDATASIZE = 0x36;
export const CALLDATACOPY = 0x37;
export const CODESIZE = 0x38;
export const CODECOPY = 0x39;
export const GASPRICE = 0x3a;
export const EXTCODESIZE = 0x3b;
export const EXTCODECOPY = 0x3c;
export const RETURNDATASIZE = 0x3d;
export const RETURNDATACOPY = 0x3e;
export const EXTCODEHASH = 0x3f;

// Block operations (0x40-0x4a)
export const BLOCKHASH = 0x40;
export const COINBASE = 0x41;
export const TIMESTAMP = 0x42;
export const NUMBER = 0x43;
export const DIFFICULTY = 0x44;
export const GASLIMIT = 0x45;
export const CHAINID = 0x46;
export const SELFBALANCE = 0x47;
export const BASEFEE = 0x48;
export const BLOBHASH = 0x49;
export const BLOBBASEFEE = 0x4a;

// Stack, memory, and storage operations (0x50-0x5e)
export const POP = 0x50;
export const MLOAD = 0x51;
export const MSTORE = 0x52;
export const MSTORE8 = 0x53;
export const SLOAD = 0x54;
export const SSTORE = 0x55;
export const JUMP = 0x56;
export const JUMPI = 0x57;
export const PC = 0x58;
export const MSIZE = 0x59;
export const GAS = 0x5a;
export const JUMPDEST = 0x5b;
export const TLOAD = 0x5c;
export const TSTORE = 0x5d;
export const MCOPY = 0x5e;

// PUSH operations (0x5f-0x7f)
export const PUSH0 = 0x5f;
export const PUSH1 = 0x60;
export const PUSH2 = 0x61;
export const PUSH3 = 0x62;
export const PUSH4 = 0x63;
export const PUSH5 = 0x64;
export const PUSH6 = 0x65;
export const PUSH7 = 0x66;
export const PUSH8 = 0x67;
export const PUSH9 = 0x68;
export const PUSH10 = 0x69;
export const PUSH11 = 0x6a;
export const PUSH12 = 0x6b;
export const PUSH13 = 0x6c;
export const PUSH14 = 0x6d;
export const PUSH15 = 0x6e;
export const PUSH16 = 0x6f;
export const PUSH17 = 0x70;
export const PUSH18 = 0x71;
export const PUSH19 = 0x72;
export const PUSH20 = 0x73;
export const PUSH21 = 0x74;
export const PUSH22 = 0x75;
export const PUSH23 = 0x76;
export const PUSH24 = 0x77;
export const PUSH25 = 0x78;
export const PUSH26 = 0x79;
export const PUSH27 = 0x7a;
export const PUSH28 = 0x7b;
export const PUSH29 = 0x7c;
export const PUSH30 = 0x7d;
export const PUSH31 = 0x7e;
export const PUSH32 = 0x7f;

// DUP operations (0x80-0x8f)
export const DUP1 = 0x80;
export const DUP2 = 0x81;
export const DUP3 = 0x82;
export const DUP4 = 0x83;
export const DUP5 = 0x84;
export const DUP6 = 0x85;
export const DUP7 = 0x86;
export const DUP8 = 0x87;
export const DUP9 = 0x88;
export const DUP10 = 0x89;
export const DUP11 = 0x8a;
export const DUP12 = 0x8b;
export const DUP13 = 0x8c;
export const DUP14 = 0x8d;
export const DUP15 = 0x8e;
export const DUP16 = 0x8f;

// SWAP operations (0x90-0x9f)
export const SWAP1 = 0x90;
export const SWAP2 = 0x91;
export const SWAP3 = 0x92;
export const SWAP4 = 0x93;
export const SWAP5 = 0x94;
export const SWAP6 = 0x95;
export const SWAP7 = 0x96;
export const SWAP8 = 0x97;
export const SWAP9 = 0x98;
export const SWAP10 = 0x99;
export const SWAP11 = 0x9a;
export const SWAP12 = 0x9b;
export const SWAP13 = 0x9c;
export const SWAP14 = 0x9d;
export const SWAP15 = 0x9e;
export const SWAP16 = 0x9f;

// LOG operations (0xa0-0xa4)
export const LOG0 = 0xa0;
export const LOG1 = 0xa1;
export const LOG2 = 0xa2;
export const LOG3 = 0xa3;
export const LOG4 = 0xa4;

// System operations (0xf0-0xff)
export const CREATE = 0xf0;
export const CALL = 0xf1;
export const CALLCODE = 0xf2;
export const RETURN = 0xf3;
export const DELEGATECALL = 0xf4;
export const CREATE2 = 0xf5;
export const STATICCALL = 0xfa;
export const REVERT = 0xfd;
export const INVALID = 0xfe;
export const SELFDESTRUCT = 0xff;

/**
 * Get the name of an opcode
 * @param opcode - The opcode byte (0x00-0xff)
 * @returns The opcode name or "UNKNOWN" for invalid opcodes
 */
export function getOpName(opcode: number): string {
  switch (opcode) {
    case 0x00: return "STOP";
    case 0x01: return "ADD";
    case 0x02: return "MUL";
    case 0x03: return "SUB";
    case 0x04: return "DIV";
    case 0x05: return "SDIV";
    case 0x06: return "MOD";
    case 0x07: return "SMOD";
    case 0x08: return "ADDMOD";
    case 0x09: return "MULMOD";
    case 0x0a: return "EXP";
    case 0x0b: return "SIGNEXTEND";
    case 0x10: return "LT";
    case 0x11: return "GT";
    case 0x12: return "SLT";
    case 0x13: return "SGT";
    case 0x14: return "EQ";
    case 0x15: return "ISZERO";
    case 0x16: return "AND";
    case 0x17: return "OR";
    case 0x18: return "XOR";
    case 0x19: return "NOT";
    case 0x1a: return "BYTE";
    case 0x1b: return "SHL";
    case 0x1c: return "SHR";
    case 0x1d: return "SAR";
    case 0x20: return "KECCAK256";
    case 0x30: return "ADDRESS";
    case 0x31: return "BALANCE";
    case 0x32: return "ORIGIN";
    case 0x33: return "CALLER";
    case 0x34: return "CALLVALUE";
    case 0x35: return "CALLDATALOAD";
    case 0x36: return "CALLDATASIZE";
    case 0x37: return "CALLDATACOPY";
    case 0x38: return "CODESIZE";
    case 0x39: return "CODECOPY";
    case 0x3a: return "GASPRICE";
    case 0x3b: return "EXTCODESIZE";
    case 0x3c: return "EXTCODECOPY";
    case 0x3d: return "RETURNDATASIZE";
    case 0x3e: return "RETURNDATACOPY";
    case 0x3f: return "EXTCODEHASH";
    case 0x40: return "BLOCKHASH";
    case 0x41: return "COINBASE";
    case 0x42: return "TIMESTAMP";
    case 0x43: return "NUMBER";
    case 0x44: return "DIFFICULTY";
    case 0x45: return "GASLIMIT";
    case 0x46: return "CHAINID";
    case 0x47: return "SELFBALANCE";
    case 0x48: return "BASEFEE";
    case 0x49: return "BLOBHASH";
    case 0x4a: return "BLOBBASEFEE";
    case 0x50: return "POP";
    case 0x51: return "MLOAD";
    case 0x52: return "MSTORE";
    case 0x53: return "MSTORE8";
    case 0x54: return "SLOAD";
    case 0x55: return "SSTORE";
    case 0x56: return "JUMP";
    case 0x57: return "JUMPI";
    case 0x58: return "PC";
    case 0x59: return "MSIZE";
    case 0x5a: return "GAS";
    case 0x5b: return "JUMPDEST";
    case 0x5c: return "TLOAD";
    case 0x5d: return "TSTORE";
    case 0x5e: return "MCOPY";
    case 0x5f: return "PUSH0";
    case 0x60: return "PUSH1";
    case 0x61: return "PUSH2";
    case 0x62: return "PUSH3";
    case 0x63: return "PUSH4";
    case 0x64: return "PUSH5";
    case 0x65: return "PUSH6";
    case 0x66: return "PUSH7";
    case 0x67: return "PUSH8";
    case 0x68: return "PUSH9";
    case 0x69: return "PUSH10";
    case 0x6a: return "PUSH11";
    case 0x6b: return "PUSH12";
    case 0x6c: return "PUSH13";
    case 0x6d: return "PUSH14";
    case 0x6e: return "PUSH15";
    case 0x6f: return "PUSH16";
    case 0x70: return "PUSH17";
    case 0x71: return "PUSH18";
    case 0x72: return "PUSH19";
    case 0x73: return "PUSH20";
    case 0x74: return "PUSH21";
    case 0x75: return "PUSH22";
    case 0x76: return "PUSH23";
    case 0x77: return "PUSH24";
    case 0x78: return "PUSH25";
    case 0x79: return "PUSH26";
    case 0x7a: return "PUSH27";
    case 0x7b: return "PUSH28";
    case 0x7c: return "PUSH29";
    case 0x7d: return "PUSH30";
    case 0x7e: return "PUSH31";
    case 0x7f: return "PUSH32";
    case 0x80: return "DUP1";
    case 0x81: return "DUP2";
    case 0x82: return "DUP3";
    case 0x83: return "DUP4";
    case 0x84: return "DUP5";
    case 0x85: return "DUP6";
    case 0x86: return "DUP7";
    case 0x87: return "DUP8";
    case 0x88: return "DUP9";
    case 0x89: return "DUP10";
    case 0x8a: return "DUP11";
    case 0x8b: return "DUP12";
    case 0x8c: return "DUP13";
    case 0x8d: return "DUP14";
    case 0x8e: return "DUP15";
    case 0x8f: return "DUP16";
    case 0x90: return "SWAP1";
    case 0x91: return "SWAP2";
    case 0x92: return "SWAP3";
    case 0x93: return "SWAP4";
    case 0x94: return "SWAP5";
    case 0x95: return "SWAP6";
    case 0x96: return "SWAP7";
    case 0x97: return "SWAP8";
    case 0x98: return "SWAP9";
    case 0x99: return "SWAP10";
    case 0x9a: return "SWAP11";
    case 0x9b: return "SWAP12";
    case 0x9c: return "SWAP13";
    case 0x9d: return "SWAP14";
    case 0x9e: return "SWAP15";
    case 0x9f: return "SWAP16";
    case 0xa0: return "LOG0";
    case 0xa1: return "LOG1";
    case 0xa2: return "LOG2";
    case 0xa3: return "LOG3";
    case 0xa4: return "LOG4";
    case 0xf0: return "CREATE";
    case 0xf1: return "CALL";
    case 0xf2: return "CALLCODE";
    case 0xf3: return "RETURN";
    case 0xf4: return "DELEGATECALL";
    case 0xf5: return "CREATE2";
    case 0xfa: return "STATICCALL";
    case 0xfd: return "REVERT";
    case 0xfe: return "INVALID";
    case 0xff: return "SELFDESTRUCT";
    default: return "UNKNOWN";
  }
}

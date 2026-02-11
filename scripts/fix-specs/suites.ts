export interface TestSuite {
  name: string;
  command: string;
  description: string;
}

export const TEST_SUITES: TestSuite[] = [
  { name: 'paris', command: 'zig build specs-paris', description: 'Paris/Merge hardfork tests' },
  { name: 'homestead', command: 'zig build specs-homestead', description: 'Homestead hardfork tests' },
  { name: 'shanghai-withdrawals', command: 'zig build specs-shanghai-withdrawals', description: 'Shanghai EIP-4895 withdrawal tests' },
  { name: 'shanghai-push0', command: 'zig build specs-shanghai-push0', description: 'Shanghai EIP-3855 PUSH0 tests' },

  // Cancun sub-targets
  { name: 'cancun-tstore-basic', command: 'zig build specs-cancun-tstore-basic', description: 'Cancun EIP-1153 basic TLOAD/TSTORE tests' },
  { name: 'cancun-tstore-reentrancy', command: 'zig build specs-cancun-tstore-reentrancy', description: 'Cancun EIP-1153 reentrancy tests' },
  { name: 'cancun-tstore-contexts-execution', command: 'zig build specs-cancun-tstore-contexts-execution', description: 'Cancun EIP-1153 execution context tests (60 tests)' },
  { name: 'cancun-tstore-contexts-tload-reentrancy', command: 'zig build specs-cancun-tstore-contexts-tload-reentrancy', description: 'Cancun EIP-1153 tload reentrancy tests (48 tests)' },
  { name: 'cancun-tstore-contexts-reentrancy', command: 'zig build specs-cancun-tstore-contexts-reentrancy', description: 'Cancun EIP-1153 reentrancy context tests (20 tests)' },
  { name: 'cancun-tstore-contexts-create', command: 'zig build specs-cancun-tstore-contexts-create', description: 'Cancun EIP-1153 create context tests (20 tests)' },
  { name: 'cancun-tstore-contexts-selfdestruct', command: 'zig build specs-cancun-tstore-contexts-selfdestruct', description: 'Cancun EIP-1153 selfdestruct tests (12 tests)' },
  { name: 'cancun-tstore-contexts-clear', command: 'zig build specs-cancun-tstore-contexts-clear', description: 'Cancun EIP-1153 clear after tx tests (4 tests)' },
  { name: 'cancun-mcopy', command: 'zig build specs-cancun-mcopy', description: 'Cancun EIP-5656 MCOPY tests' },
  { name: 'cancun-blobbasefee', command: 'zig build specs-cancun-blobbasefee', description: 'Cancun EIP-7516 BLOBBASEFEE tests' },
  { name: 'cancun-blob-precompile-basic', command: 'zig build specs-cancun-blob-precompile-basic', description: 'Cancun EIP-4844 point evaluation basic tests (310 tests)' },
  { name: 'cancun-blob-precompile-gas', command: 'zig build specs-cancun-blob-precompile-gas', description: 'Cancun EIP-4844 point evaluation gas tests (48 tests)' },
  { name: 'cancun-blob-opcodes-basic', command: 'zig build specs-cancun-blob-opcodes-basic', description: 'Cancun EIP-4844 BLOBHASH basic tests (75 tests)' },
  { name: 'cancun-blob-opcodes-contexts', command: 'zig build specs-cancun-blob-opcodes-contexts', description: 'Cancun EIP-4844 BLOBHASH context tests (23 tests)' },
  { name: 'cancun-blob-tx-small', command: 'zig build specs-cancun-blob-tx-small', description: 'Cancun EIP-4844 small blob transaction tests' },
  { name: 'cancun-blob-tx-subtraction', command: 'zig build specs-cancun-blob-tx-subtraction', description: 'Cancun EIP-4844 blob gas subtraction tests' },
  { name: 'cancun-blob-tx-insufficient', command: 'zig build specs-cancun-blob-tx-insufficient', description: 'Cancun EIP-4844 insufficient balance tests' },
  { name: 'cancun-blob-tx-sufficient', command: 'zig build specs-cancun-blob-tx-sufficient', description: 'Cancun EIP-4844 sufficient balance tests' },
  { name: 'cancun-blob-tx-valid-combos', command: 'zig build specs-cancun-blob-tx-valid-combos', description: 'Cancun EIP-4844 valid combinations tests' },

  // Prague sub-targets
  { name: 'prague-calldata-cost-type0', command: 'zig build specs-prague-calldata-cost-type0', description: 'Prague EIP-7623 calldata cost type 0 tests' },
  { name: 'prague-calldata-cost-type1-2', command: 'zig build specs-prague-calldata-cost-type1-2', description: 'Prague EIP-7623 calldata cost type 1/2 tests' },
  { name: 'prague-calldata-cost-type3', command: 'zig build specs-prague-calldata-cost-type3', description: 'Prague EIP-7623 calldata cost type 3 tests' },
  { name: 'prague-calldata-cost-type4', command: 'zig build specs-prague-calldata-cost-type4', description: 'Prague EIP-7623 calldata cost type 4 tests' },
  { name: 'prague-calldata-cost-refunds', command: 'zig build specs-prague-calldata-cost-refunds', description: 'Prague EIP-7623 refunds and gas tests' },
  { name: 'prague-bls-g1', command: 'zig build specs-prague-bls-g1', description: 'Prague EIP-2537 BLS12-381 G1 tests' },
  { name: 'prague-bls-g2', command: 'zig build specs-prague-bls-g2', description: 'Prague EIP-2537 BLS12-381 G2 tests' },
  { name: 'prague-bls-pairing', command: 'zig build specs-prague-bls-pairing', description: 'Prague EIP-2537 BLS12-381 pairing tests' },
  { name: 'prague-bls-map', command: 'zig build specs-prague-bls-map', description: 'Prague EIP-2537 BLS12-381 map tests' },
  { name: 'prague-bls-misc', command: 'zig build specs-prague-bls-misc', description: 'Prague EIP-2537 BLS12-381 misc tests' },
  { name: 'prague-setcode-calls', command: 'zig build specs-prague-setcode-calls', description: 'Prague EIP-7702 set code call tests' },
  { name: 'prague-setcode-gas', command: 'zig build specs-prague-setcode-gas', description: 'Prague EIP-7702 set code gas tests' },
  { name: 'prague-setcode-txs', command: 'zig build specs-prague-setcode-txs', description: 'Prague EIP-7702 set code transaction tests' },
  { name: 'prague-setcode-advanced', command: 'zig build specs-prague-setcode-advanced', description: 'Prague EIP-7702 advanced set code tests' },

  // Osaka sub-targets
  { name: 'osaka-modexp-variable-gas', command: 'zig build specs-osaka-modexp-variable-gas', description: 'Osaka EIP-7883 modexp variable gas tests' },
  { name: 'osaka-modexp-vectors-eip', command: 'zig build specs-osaka-modexp-vectors-eip', description: 'Osaka EIP-7883 modexp vectors from EIP tests' },
  { name: 'osaka-modexp-vectors-legacy', command: 'zig build specs-osaka-modexp-vectors-legacy', description: 'Osaka EIP-7883 modexp vectors from legacy tests' },
  { name: 'osaka-modexp-misc', command: 'zig build specs-osaka-modexp-misc', description: 'Osaka EIP-7883 modexp misc tests' },
  { name: 'osaka-other', command: 'zig build specs-osaka-other', description: 'Osaka other EIP tests' },

  // Shanghai EIPs
  { name: 'shanghai-warmcoinbase', command: 'zig build specs-shanghai-warmcoinbase', description: 'Shanghai EIP-3651 warm coinbase tests' },
  { name: 'shanghai-initcode-basic', command: 'zig build specs-shanghai-initcode-basic', description: 'Shanghai EIP-3860 initcode basic tests (162 tests)' },
  { name: 'shanghai-initcode-eof', command: 'zig build specs-shanghai-initcode-eof', description: 'Shanghai EIP-3860 initcode EOF tests (24 tests)' },

  // Byzantium sub-targets
  { name: 'byzantium-modexp', command: 'zig build specs-byzantium-modexp', description: 'Byzantium EIP-198 modexp precompile tests (352 tests)' },

  // Berlin sub-targets
  { name: 'berlin-acl', command: 'zig build specs-berlin-acl', description: 'Berlin EIP-2930 access list account storage tests' },
  { name: 'berlin-intrinsic-gas-cost', command: 'zig build specs-berlin-intrinsic-gas-cost', description: 'Berlin EIP-2930 transaction intrinsic gas cost tests' },
  { name: 'berlin-intrinsic-type0', command: 'zig build specs-berlin-intrinsic-type0', description: 'Berlin EIP-2930 intrinsic gas type 0 transaction tests' },
  { name: 'berlin-intrinsic-type1', command: 'zig build specs-berlin-intrinsic-type1', description: 'Berlin EIP-2930 intrinsic gas type 1 transaction tests' },

  // Frontier sub-targets
  { name: 'frontier-precompiles', command: 'zig build specs-frontier-precompiles', description: 'Frontier precompile tests' },
  { name: 'frontier-identity', command: 'zig build specs-frontier-identity', description: 'Frontier identity precompile tests' },
  { name: 'frontier-create', command: 'zig build specs-frontier-create', description: 'Frontier CREATE tests' },
  { name: 'frontier-call', command: 'zig build specs-frontier-call', description: 'Frontier CALL/CALLCODE tests' },
  { name: 'frontier-calldata', command: 'zig build specs-frontier-calldata', description: 'Frontier calldata opcode tests' },
  { name: 'frontier-dup', command: 'zig build specs-frontier-dup', description: 'Frontier DUP tests' },
  { name: 'frontier-push', command: 'zig build specs-frontier-push', description: 'Frontier PUSH tests' },
  { name: 'frontier-stack', command: 'zig build specs-frontier-stack', description: 'Frontier stack overflow tests' },
  { name: 'frontier-opcodes', command: 'zig build specs-frontier-opcodes', description: 'Frontier all opcodes tests' },

  // Constantinople sub-targets
  { name: 'constantinople-bitshift', command: 'zig build specs-constantinople-bitshift', description: 'Constantinople EIP-145 bitwise shift tests (~250 tests)' },
  { name: 'constantinople-create2', command: 'zig build specs-constantinople-create2', description: 'Constantinople EIP-1014 CREATE2 tests (~250 tests)' },

  // Istanbul sub-targets
  { name: 'istanbul-blake2', command: 'zig build specs-istanbul-blake2', description: 'Istanbul EIP-152 BLAKE2 precompile tests' },
  { name: 'istanbul-chainid', command: 'zig build specs-istanbul-chainid', description: 'Istanbul EIP-1344 CHAINID tests' },

  // Cancun selfdestruct sub-targets
  { name: 'cancun-selfdestruct-basic', command: 'zig build specs-cancun-selfdestruct-basic', description: 'Cancun EIP-6780 basic SELFDESTRUCT tests (306 tests)' },
  { name: 'cancun-selfdestruct-collision', command: 'zig build specs-cancun-selfdestruct-collision', description: 'Cancun EIP-6780 create2 collision tests (52 tests)' },
  { name: 'cancun-selfdestruct-reentrancy', command: 'zig build specs-cancun-selfdestruct-reentrancy', description: 'Cancun EIP-6780 reentrancy revert tests (36 tests)' },
  { name: 'cancun-selfdestruct-revert', command: 'zig build specs-cancun-selfdestruct-revert', description: 'Cancun EIP-6780 revert tests (12 tests)' },
];

# Guillotine Spec Fixer Pipeline - Summary Report

**Generated**: 2025-10-08T21:03:06.490Z

## Overview

- **Total Test Suites**: 54
- **Passed**: 44
- **Failed**: 10
- **Total Agent Attempts**: 10
- **Total Cost**: $28.7696
- **Total Duration**: 387.9 minutes

## Test Suite Results

### ✅ Passed (44)

- paris
- homestead
- shanghai-withdrawals
- shanghai-push0
- cancun-tstore-basic
- cancun-tstore-reentrancy
- cancun-mcopy
- cancun-blobbasefee
- cancun-blob-tx-small
- cancun-blob-tx-insufficient
- cancun-blob-tx-valid-combos
- prague-calldata-cost-type0
- prague-calldata-cost-type1-2
- prague-calldata-cost-type3
- prague-calldata-cost-type4
- prague-calldata-cost-refunds
- prague-bls-g1
- prague-bls-g2
- prague-bls-pairing
- prague-bls-map
- prague-bls-misc
- prague-setcode-calls
- prague-setcode-gas
- prague-setcode-txs
- prague-setcode-advanced
- osaka-modexp-variable-gas
- osaka-modexp-vectors-eip
- osaka-modexp-vectors-legacy
- osaka-modexp-misc
- osaka-other
- shanghai-warmcoinbase
- berlin-acl
- berlin-intrinsic-gas-cost
- berlin-intrinsic-type0
- berlin-intrinsic-type1
- frontier-precompiles
- frontier-identity
- frontier-create
- frontier-call
- frontier-calldata
- frontier-dup
- frontier-push
- frontier-stack
- frontier-opcodes

### ❌ Failed (10)

- cancun-tstore-contexts
- cancun-blob-precompile
- cancun-blob-opcodes
- cancun-blob-tx-subtraction
- cancun-blob-tx-sufficient
- shanghai-initcode
- byzantium
- constantinople
- istanbul
- cancun-selfdestruct

## Agent Fix Attempts

| Suite | Attempt | Success | Cost | Turns | Duration |
|-------|---------|---------|------|-------|----------|
| cancun-tstore-contexts | 1 | ✅ | $1.8175 | 198 | 799.2s |
| cancun-blob-precompile | 1 | ✅ | $3.1832 | 168 | 3411.3s |
| cancun-blob-opcodes | 1 | ✅ | $2.6609 | 261 | 878.1s |
| cancun-blob-tx-subtraction | 1 | ✅ | $4.2044 | 355 | 2009.2s |
| cancun-blob-tx-sufficient | 1 | ✅ | $4.4261 | 335 | 5431.8s |
| shanghai-initcode | 1 | ✅ | $2.5478 | 266 | 993.8s |
| byzantium | 1 | ✅ | $4.0193 | 268 | 1543.1s |
| constantinople | 1 | ✅ | $2.6292 | 224 | 1744.8s |
| istanbul | 1 | ✅ | $1.4831 | 187 | 732.7s |
| cancun-selfdestruct | 1 | ✅ | $1.7982 | 204 | 704.2s |

## Next Steps

1. Review failed test suites and agent reports
2. Manually investigate remaining failures
3. Consider increasing maxTurns or maxAttempts for complex fixes

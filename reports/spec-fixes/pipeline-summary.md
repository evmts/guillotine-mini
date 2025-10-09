# Guillotine Spec Fixer Pipeline - Summary Report

**Generated**: 2025-10-09T15:02:37.865Z

## Overview

- **Total Test Suites**: 54
- **Passed**: 45
- **Failed**: 9
- **Total Agent Attempts**: 29
- **Total Cost**: $84.3748
- **Total Duration**: 788.5 minutes

## Test Suite Results

### ✅ Passed (45)

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
- cancun-blob-tx-sufficient
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

### ❌ Failed (9)

- cancun-tstore-contexts
- cancun-blob-precompile
- cancun-blob-opcodes
- cancun-blob-tx-subtraction
- shanghai-initcode
- byzantium
- constantinople
- istanbul
- cancun-selfdestruct

## Agent Fix Attempts

| Suite | Attempt | Success | Cost | Turns | Duration |
|-------|---------|---------|------|-------|----------|
| cancun-tstore-contexts | 1 | ✅ | $2.1777 | 198 | 843.8s |
| cancun-tstore-contexts | 2 | ✅ | $2.4446 | 232 | 1166.5s |
| cancun-tstore-contexts | 3 | ✅ | $2.0877 | 208 | 820.1s |
| cancun-blob-precompile | 1 | ✅ | $3.4500 | 202 | 1788.6s |
| cancun-blob-precompile | 2 | ✅ | $3.0948 | 207 | 1953.7s |
| cancun-blob-precompile | 3 | ✅ | $1.8786 | 159 | 850.7s |
| cancun-blob-opcodes | 1 | ✅ | $1.6271 | 162 | 550.5s |
| cancun-blob-opcodes | 2 | ✅ | $4.1172 | 268 | 1163.0s |
| cancun-blob-opcodes | 3 | ✅ | $2.5096 | 282 | 1640.5s |
| cancun-blob-tx-subtraction | 1 | ✅ | $4.0236 | 280 | 1750.8s |
| cancun-blob-tx-subtraction | 2 | ✅ | $3.9242 | 290 | 1518.3s |
| cancun-blob-tx-subtraction | 3 | ✅ | $4.5890 | 348 | 2305.4s |
| cancun-blob-tx-sufficient | 1 | ✅ | $2.1897 | 232 | 1368.0s |
| cancun-blob-tx-sufficient | 2 | ✅ | $3.7247 | 290 | 1693.0s |
| shanghai-initcode | 1 | ✅ | $5.8293 | 298 | 1925.0s |
| shanghai-initcode | 2 | ✅ | $1.1060 | 120 | 361.9s |
| shanghai-initcode | 3 | ✅ | $4.6655 | 378 | 1255.6s |
| byzantium | 1 | ✅ | $2.9650 | 197 | 1139.9s |
| byzantium | 2 | ✅ | $2.2533 | 223 | 852.6s |
| byzantium | 3 | ✅ | $2.7473 | 202 | 1247.6s |
| constantinople | 1 | ✅ | $2.6820 | 267 | 1187.1s |
| constantinople | 2 | ✅ | $2.2443 | 233 | 712.9s |
| constantinople | 3 | ✅ | $2.4193 | 238 | 1321.1s |
| istanbul | 1 | ✅ | $2.2929 | 224 | 2125.5s |
| istanbul | 2 | ✅ | $2.9652 | 254 | 1415.4s |
| istanbul | 3 | ✅ | $2.5320 | 286 | 1553.9s |
| cancun-selfdestruct | 1 | ✅ | $2.2157 | 166 | 876.6s |
| cancun-selfdestruct | 2 | ✅ | $3.6030 | 190 | 1776.9s |
| cancun-selfdestruct | 3 | ✅ | $2.0154 | 226 | 1080.2s |

## Next Steps

1. Review failed test suites and agent reports
2. Manually investigate remaining failures
3. Consider increasing maxTurns or maxAttempts for complex fixes

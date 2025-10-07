# Guillotine Spec Fixer Pipeline - Summary Report

**Generated**: 2025-10-07T19:10:26.306Z

## Overview

- **Total Test Suites**: 4
- **Passed**: 2
- **Failed**: 2
- **Total Agent Attempts**: 10
- **Total Cost**: $26.3936
- **Total Duration**: 127.3 minutes

## Test Suite Results

### ✅ Passed (2)

- istanbul
- byzantium

### ❌ Failed (2)

- shanghai-initcode
- constantinople

## Agent Fix Attempts

| Suite | Attempt | Success | Cost | Turns | Duration |
|-------|---------|---------|------|-------|----------|
| shanghai-initcode | 1 | ✅ | $1.6168 | 102 | 399.6s |
| shanghai-initcode | 2 | ✅ | $2.6509 | 236 | 685.0s |
| shanghai-initcode | 3 | ✅ | $3.0640 | 255 | 1049.5s |
| shanghai-initcode | 4 | ✅ | $1.5764 | 125 | 510.4s |
| shanghai-initcode | 5 | ✅ | $2.1252 | 173 | 542.1s |
| constantinople | 1 | ✅ | $3.3243 | 268 | 780.4s |
| constantinople | 2 | ✅ | $2.4948 | 186 | 759.6s |
| constantinople | 3 | ✅ | $3.8224 | 308 | 1036.7s |
| constantinople | 4 | ✅ | $2.4623 | 185 | 691.1s |
| constantinople | 5 | ✅ | $3.2564 | 319 | 934.0s |

## Next Steps

1. Review failed test suites and agent reports
2. Manually investigate remaining failures
3. Consider increasing maxTurns or maxAttempts for complex fixes

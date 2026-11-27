## Lighthouse Backpressure Audit (80 / 100)

Trust tier: `untrusted-contributor` | Shared cache: `local-only` | Merge gate: `informational` | Commit: `cbdd5e92b5ab`

| Category | Score | Scope |
| --- | --- | --- |
| Safety & TigerStyle | **95 / 100** (PASS) | 6 audits |
| Style & Limits | **83 / 100** (WARN) | 4 audits |
| Footprint & Minimalism | **42 / 100** (FAIL) | 3 audits |
| Verification & Tests | **61 / 100** (WARN) | 4 audits |
| Documentation | **98 / 100** (PASS) | 2 audits |
| Factory & Trust | **100 / 100** (PASS) | 4 audits |

### Top Opportunities

- **+29** `footprint/zig-file-lines`: 1634 -> 400
- **+22** `verification/zig-inline-test-coverage`: 45.8 -> 95
- **+12** `verification/ts-test-ratio`: 70 -> 100
- **+5** `style/line-length`: fail -> pass
- **+4** `safety/zig-assertion-density`: 0.41 -> 20

Full interactive Lighthouse report: [mini.tevm.sh/audit](https://mini.tevm.sh/audit/) | Lean 4 oracle: **210 theorems (0 sorry)** | Factory: **8 packages, 11 flows, 8 wiki notes**.

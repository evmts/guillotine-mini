## Lighthouse Backpressure Audit (82 / 100)

Trust tier: `untrusted-contributor` | Shared cache: `local-only` | Merge gate: `informational` | Commit: `cd96d695b24e`

| Category | Score | Scope |
| --- | --- | --- |
| Safety & TigerStyle | **92 / 100** (PASS) | 6 audits |
| Style & Limits | **90 / 100** (PASS) | 4 audits |
| Footprint & Minimalism | **53 / 100** (WARN) | 3 audits |
| Verification & Tests | **70 / 100** (WARN) | 4 audits |
| Documentation | **87 / 100** (WARN) | 2 audits |
| Factory & Trust | **100 / 100** (PASS) | 4 audits |

### Top Opportunities

- **+11** `verification/ts-test-ratio`: 72.5 -> 100
- **+10** `documentation/companion-doc-coverage`: 65.4 -> 90
- **+7** `verification/zig-inline-test-coverage`: 73.1 -> 95
- **+6** `style/line-length`: fail -> pass
- **+5** `verification/lean-theorems`: 60 -> 120

Full interactive Lighthouse report: [mini.tevm.sh/audit](https://mini.tevm.sh/audit/) | Lean 4 oracle: **60 theorems (0 sorry)** | Factory: **30 packages, 11 flows, 8 wiki notes**.

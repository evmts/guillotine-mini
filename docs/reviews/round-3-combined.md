# Combined Round 3 review

**Reviewed revision** `gm-r2-fixed` (`41408f2f`), the integration of FX2-1 through FX2-6. **Verdict** `NEEDS_ROUND_4` across Astra, Fable, and Gemini Neon. Round 2 repaired ordinary async suspension and root rollback, made empty filtered selections fail, and added fixture assertions that had been missing. The Round 3 reviews found cross-transaction state leaks, incomplete conformance checks, and gaps in the build and CI gates.

## Convergence

| Reviewer | Round 1 C/H/M/L/N (total) | Round 2 C/H/M/L/N (total) | Round 3 C/H/M/L/N (total) | Change R2 → R3 |
| --- | ---: | ---: | ---: | --- |
| Astra | 2/58/31/4/1 (96) | 4/31/20/1/0 (56) | 3/24/19/2/0 (48) | −1 critical, −7 high, −8 total |
| Fable | 7/14/20/7/2 (50) | 4/13/10/10/3 (40) | 0/8/19/16/6 (49) | −4 critical, −5 high, +9 total |
| Gemini Neon | 6/7/3/5/1 (22) | 3/6/7/2/1 (19) | 0/4/3/3/0 (10) | −3 critical, −2 high, −9 total |

C/H/M/L/N stand for critical, high, medium, low, and nit. Counts follow each review's published scope and severity. Astra's adjusted Round 1 baseline is 89 findings (2 critical, 51 high) after excluding seven upstream and dependency items. Fable reports 30 executed reproductions among its 49 findings and attributes the rise in lower severities to expanded negative controls and downgraded R2 findings. Fable and Neon verified the original critical scenarios as fixed. Astra rated the cancellation and cache leaks and the remaining fixture false positives critical on the strength of new cross-transaction probes and mutated fixtures.

## Verification at the reviewed revision

- Native unit builds and all 22 Node WASI tests passed against the prepared Voltaire sibling. Fable reported 1,338 native passes and two skips. Fable's separate build against the declared CI pin failed at `BlockHeader.requests_hash`.
- The three reviewers reported 14,784 vectors and zero asserted mismatches for the default Lean replay. Five Zig-positive BLS membership observations at `0x12` and `0x13` bypassed the strict assertion. Fable's second seed reported seven such observations across 28,116 vectors.
- Astra and Fable reported 535 client TypeScript passes. Neon ran both standalone ExEx tests and inspected the client source without its local dependencies installed.
- Astra's scoped PUSH0 run passed 30 cases. It still passed after the expected roots were replaced and all 39 nonzero storage assertions were removed. Fable independently reproduced fixture false positives with hand-written cases. The full official state and blockchain corpora remain unverified at this revision.

## Critical and high findings by polish lane

Each row assigns the reported behavior to a lead lane. IDs from other reviewers sit beside the matching behavior, with their original severity retained in the convergence counts. Assignment records ownership for the polish work.

| Lead lane | Finding IDs | Defect |
| --- | --- | --- |
| FX3-1 · Async and C/WASI ABI | Astra **R3-001**, Fable B-2 | Reverted injector storage leaks through the fetch cache into the next synchronous transaction. |
| FX3-1 · Async and C/WASI ABI | Astra R3-008 | Async CREATE and CREATE2 derive addresses or check collisions using incomplete backend state. |
| FX3-1 · Async and C/WASI ABI | Astra R3-009, R3-010 | Commit can mutate state before serialization succeeds. A failed rollback can discard its recovery checkpoint. |
| FX3-1 · Async and C/WASI ABI | Astra R3-011, R3-012 | Host-backed commits omit account field changes. Restarting after a miss repeats callbacks and trace entries. |
| FX3-1 · Async and C/WASI ABI | Astra R3-013 | Hostless state loses empty account identity. FX3-3 covers the same gap in the fixture host. |
| FX3-1 · Async and C/WASI ABI | Astra **R3-002**, Fable B-1, Neon R3-01 | Cancelling a suspended message from the C ABI can leave a transfer committed. Native teardown must roll back while the checkpoint and Host are still live. |
| FX3-1 · Async and C/WASI ABI | Astra R3-004, R3-006 | A stale reply can resume a replacement transaction, and setters can change the environment of a suspended transaction. |
| FX3-1 · Async and C/WASI ABI | Astra R3-005, Neon R3-02, Fable B-3/B-5, Neon R3-05 | One-call code has different visibility across entry points, and replacing a suspended call at the same address can discard the newly supplied code. |
| FX3-1 · Async and C/WASI ABI | Astra R3-015 | Reusing a synchronous C handle retains prior results. |
| FX3-2 · Opcode handlers | Astra R3-007, Fable A-1, Neon R3-03 | EXTCODESIZE, EXTCODECOPY, CALL liveness, and SELFDESTRUCT read unknown async account fields as empty. |
| FX3-3 · Fixture runner and validation | Astra R3-014 | The client adapter answers storage-existence queries from a partial cache, which affects CREATE collision checks. |
| FX3-3 · Fixture runner and validation | Astra **R3-003**, Fable C-1, Neon R3-09 | False roots, unexpected storage, unchecked root-only variants, and incomplete direct post-state comparisons can pass. |
| FX3-3 · Fixture runner and validation | Astra R3-016, R3-017, Fable C-3 | Blockchain fixtures can drop invalid transactions or accept the wrong block error. State fixtures can accept the opposite nonce rejection. |
| FX3-3 · Fixture runner and validation | Astra R3-018, Neon R3-04 | Flattening blocks loses per-block context, withdrawal order, and rejected-block isolation. |
| FX3-3 · Fixture runner and validation | Astra R3-019, Fable C-2/C-5 | Multi-fork state fixtures omit historical forks or skip checks around root-only variants. |
| FX3-3 · Fixture runner and validation | Astra R3-020, R3-021, R3-022, Fable C-7/C-8, Neon R3-06 | Raw envelopes omit active types and chain checks. Structured admission bypasses fork/blob rules and can infer the wrong sender. |
| FX3-3 · Fixture runner and validation | Astra R3-023, Fable C-9, Neon R3-08 | Header validation omits fork-specific presence checks for withdrawals and requests roots. |
| FX3-4 · Build and CI | Astra R3-024, Fable D-5/E-7, Neon R3-10 | PR coverage omitted strict Lean replay, ExEx, and a blockchain fixture. FX3-4 wires Lean and ExEx. The blockchain fixture gate remains open. |
| FX3-4 · Build and CI | Astra R3-025, R3-026, Fable D-3/D-4 | State and blockchain generation shared a tracked root, and a partial tree could suppress a full fill. FX3-4 isolates the roots and requires a successful full-fill stamp for reuse. |
| FX3-4 · Build and CI | Astra R3-027, Fable D-2 | The strict Lean comparator suppresses BLS membership disagreements. The local assertion policy and upstream dispatch table both need correction. |
| FX3-4 · Build and CI | Fable D-1 | The declared dependency pin fails to compile and lacks Osaka ModExp pricing. The build lane coordinates publication and pin verification with Voltaire. |

FX3-4 also includes the source-package inputs and WASI examples (Astra R3-043/R3-044, Fable D-6/D-7), the empty Lean strictness setting and Zig version docs (Fable D-8/D-9). Other review follow-ups include ExEx lifecycle and prune progress, the client executor placeholder, fork and gas edge cases, and trace limits. The full-corpus gate also lacks revision-bound fixture manifests and upstream execution coverage.

## Upstream `../voltaire`

- **Native pin.** The manifest declares `8b513683`. Fable's prepared sibling at `ae039ed07` supplied `BlockHeader.requests_hash` and Osaka ModExp behavior. The reviewed pin failed compilation and, with the header reference neutralized, charged 200 gas for empty Osaka ModExp instead of 500. Fable reported `ae039ed07` unpublished at review time.
- **Prague BLS membership.** The prepared dependency still reported `0x12` and `0x13` as precompiles. The Voltaire correction identified as `ab9264bb` narrows the BLS range to `0x0b..0x11`. Strict Lean results need to assert the actual Zig membership and exercise the corrected dependency.
- **ECRECOVER.** Voltaire currently reads only the last byte of the 32-byte `v` word and calls a recovery helper that accepts raw IDs `0` and `1`. The precompile boundary requires a zero-padded word equal to `27` or `28`, while retaining precompile support for high-`s` signatures.
- Historical BN254 gas, KZG, and complete fork-backed storage wipes also depend on Voltaire. The local partial-cache existence decision and the local Lean comparison policy appear in the lane ledger above.

Source material is the three Round 3 reviews (`R3-astra.md`, `R3-fable.md`, and `R3-neon.md`) and the published Round 1 and Round 2 severity tables. [Combined Round 1 review](round-1-combined.md) · [Combined Round 2 review](round-2-combined.md)


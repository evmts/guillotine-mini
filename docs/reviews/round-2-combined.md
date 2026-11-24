# Combined Round 2 review

**Reviewed revision:** `gm-r1-fixed` (`a3a7a9a3`), the integration of FX1–FX7. **Review verdict:** Hold for consensus-sensitive use. All three reviewers called for Round 3. Async rollback and suspension and the fixture oracle were the principal blockers at the reviewed revision.

## Round 1 to Round 2

| Source | Round 1 | Round 2 | Change |
| --- | ---: | ---: | ---: |
| Astra | 96 findings | 56 findings (4 critical, 31 high) | −40 (−41.7%) |
| Fable | 50 findings | 40 findings (4 critical, 13 high) | −10 (−20.0%) |
| Gemini Neon | 22 findings | 19 findings (3 critical, 6 high) | −3 (−13.6%) |
| Lean 4 differential fuzzing | 50 / 14,778 strict mismatches | **0 / 14,784 strict mismatches** | −50 mismatches across six additional vectors |

The reviewer counts use each review's own severity and grouping. [Round 1 combined review](round-1-combined.md) records the original baselines and the 26 CLZ plus 24 copy/load mismatches. The Round 2 fixed-seed replay used seed `0x6c65616e2d646966` at scale 1. Astra also ran seed `0x7` at scale 4 with 34,772 vectors and zero asserted mismatches. Strict replay counted noncanonical BLS membership separately from mismatches (R2-034), so the zero count applies to the assertions exercised by that harness.

Astra reported 1,278 native unit tests passed with one skip, 18 WASI tests passed, and 531 client TypeScript tests passed with fixtures supplied. Fable independently reproduced the Lean result. Both reviews reported that the full official fixture corpus was absent from the integration checkout. Astra's negative controls showed that the fixture harness could pass deliberately wrong cases.

## Round 1 critical and high verification

The IDs use the deduplicated Round 1 ledger. A fix below refers to the original behavior verified by a Round 2 reviewer. The second table records cases where Round 2 evidence qualified the fix or kept the finding open.

| Severity | Verified fixed | Evidence at `gm-r1-fixed` |
| --- | --- | --- |
| Critical | R1-003 | Normal interpreter dispatch reaches Osaka CLZ. The fixed-seed Lean replay cleared the 26 CLZ mismatches. |
| Critical | R1-013 | The audited CALL, copy, hash, log and return paths validate ranges and charge gas before memory expansion. R2-038 tracks independently reproduced payable ranges beyond the u32 model and premature saturation of gas arithmetic. |
| Critical | R1-093 | Bytewise comparison distinguishes the canonical empty trie root from other hashes. |
| High | R1-012, R1-014, R1-015, R1-016 | Nested DELEGATECALL inherits value. Empty ranges avoid expansion, far reads zero-pad, and EIP-7702 delegate access is charged and warmed. Fable exercised CALLVALUE and delegation gas. The Lean replay cleared the copy/load mismatches. R2-006 covers the separate explicit root DELEGATECALL value. |
| High | R1-017, R1-018 | Transaction initialization preserves injected pre-state. The C ABI exports independent origin and gas-price setters. |
| High | R1-021, R1-025, R1-026 | CREATE uses the historical initial nonce. The consensus-visible default loop quota and fork-blind input caps were removed. |
| High | R1-028 | The SELFDESTRUCT handler selects the historical fork surcharge rules. Beneficiary touch and empty-account deletion have separate coverage in R2-015. |
| High | R1-043, R1-045, R1-046, R1-050, R1-089, R1-108, R1-110 | Fable verified the input validation, owned code and injector buffers, access-list packing and pending-list lifetime, halt-result handling and nullable C exports through source and FX3 tests. R2-022 covers the fixture runner's separate typed admission and warming path. |
| High | R1-048 | The async TypeScript example completed against the WASI reactor. |
| High | R1-052, R1-053, R1-054, R1-114 | The Zig client implements historical intrinsic gas, Berlin access-list admission, strict gas-limit endpoints, and blob/SetCode envelope checks. R2-018/019 cover additional header rules. |
| High | R1-055, R1-056, R1-058 | Client TypeScript tests verified self-mined refunds, Osaka execution gas limits, and canonical storage-root values. F-14 and R2-027 record write scaling and deletion defects in the state path. |
| High | R1-074, R1-078 | Fixture settlement uses gas actually spent for miner payment and restores the value transfer on zero-execution-gas failure. |
| High | R1-097, R1-098, R1-100 | Frame capacity is reserved for depth 1,024. The shared CREATE helper checks Shanghai initcode size before soft failures. Synchronous state inspection preserves raw delegation designators. R2-041 tracks the preceding opcode copy and Neon R2-08 tracks C execution clobbering installed code. |

| Severity | Partial or open at `gm-r1-fixed` | Verified scope and remaining case |
| --- | --- | --- |
| Critical | R1-001, R1-002 | Synchronous root and constructor rollback passed ordinary cases. Async root rollback, empty-destination identity, and result-allocation rollback remain in R2-001/014/039. |
| Critical | R1-034, R1-035 | Top-frame storage misses probe before consuming operands, and the ordinary overlay returns authoritative writes. Nested suspend, the SSTORE sentry, and precompile or host account deltas remain in R2-007/009/043 and Neon R2-15. |
| Critical | R1-065, R1-070, R1-071 | R2-002–004 reproduced empty selection, incomplete variant/state checks, and exception checks that accept the wrong outcome. |
| High | R1-011, R1-019, R1-020, R1-022 | The normal-entry refund reset, synchronous message semantics, ordinary CREATE nonce handling, and reverted touches improved. R2-001/005/006/014–016 and F-29 document the remaining cases. |
| High | R1-024, R1-027, R1-030, R1-031, R1-099 | Historical CALL handler pricing, synchronous custom precompiles and local slot deletion/collision handling improved. R2-013/014/017/035 cover fork selection, empty-account existence, fork-backed storage, and async custom dispatch. |
| High | R1-036–042, R1-081 | The AsyncExecutor wrapper gained terminal-result checks, typed continuations and some cleanup. R2-001/005/007/008/010–012 and Neon R2-05 cover the outstanding rollback, result, re-entrancy, request identity, transaction input and allocation cases. |
| High | R1-059, R1-060 | Replay handoff and prune eligibility remained open as R2-029/030 at baseline. FX2-6 directly verifies both changes. |
| High | R1-064, R1-066, R1-067, R1-096 | R2-031–033 cover incomplete CI, fixture-generation collisions and silent corpus shrinkage. |
| High | R1-072, R1-073, R1-075, R1-076 | R2-021–026 cover raw/structured admission, raw value charging, authorization trust and stale bytecode, and block ordering. |

R1-004–010 are covered in the [Voltaire footnote](#upstream-voltaire).

## Round 2 findings by cluster and fix lane

Astra IDs have three-digit suffixes. Neon IDs have two-digit suffixes. Each row maps the reviewed finding to the code-owning fix lane. Multiple lanes indicate work at distinct boundaries, such as frame trace capture and trace serialization. This is a baseline inventory and an ownership map. Lane verification and integration evidence determine closure.

### FX2-1 · Core EVM and async execution

| Astra | Fable | Neon | Finding |
| --- | --- | --- | --- |
| R2-001 | F-02, F-22, F-33 | R2-02, R2-05 | Preserve a root checkpoint across suspension, roll back host and local writes on failure, and publish terminal results. FX2-2 covers public ABI result exposure. |
| R2-005 | F-21, F-32 | R2-02, R2-08 | Apply pending account deletion on async success and consume one-shot transaction inputs. FX2-2 covers C call setup and installed code. |
| R2-006 | F-09 | R2-02, R2-12 | Share root message value, execution address, static context, and transfer semantics. |
| R2-007, R2-008 | F-01, F-07, F-08 | R2-01, R2-06 | Suspend nested calls and constructors on missing slots and request missing account data. |
| R2-009, R2-035 | — | — | Include precompile balance transfers in commit deltas and dispatch registered overrides at ordinary addresses. |
| R2-012, R2-040 | F-05, F-06 | R2-10 | Release async frame allocations and avoid copying accumulated transaction state for each nested CALL. |
| R2-013 | F-19 | R2-07 | Use the configured fork and resolve transitions for execution. |
| R2-014, R2-015 | F-18, F-23, F-28 | R2-04, R2-15 | Preserve existing empty-account identity, track touches, and sweep empty backing accounts at precompile addresses. FX2-3 owns SELFDESTRUCT beneficiary touch. FX2-4 owns fixture-host existence. |
| R2-016, R2-039 | F-29 | — | Resolve root CREATE nonce/address bounds and preserve rollback if result allocation fails. |
| R2-042 | F-31 | R2-16 | Enforce or reject advertised instance limits across the core and frame. Frame enforcement routes to FX2-3. |
| R2-053 (bytecode) | — | R2-09 | Return the frame's raw bytecode slice. FX2-2 owns the trace serializer part. |
| — | F-38 (validation) | R2-18, R2-19 (core and async) | Remove obsolete validation branches and correct core/async comments. |
| — | — | R2-15 (dirty tracking) | Report cleared code and nonce in injector deltas. |

### FX2-2 · C/WASI ABI, tracer, and hardfork helpers

| Astra | Fable | Neon | Finding |
| --- | --- | --- | --- |
| R2-010, R2-011 | — | R2-08 | Keep one request and commit lifecycle across ABI entry points and guard handles against mutation or destruction during callbacks. FX2-1 owns executor-side request identity. |
| R2-036 | F-32 | R2-08 | Expose C-supplied bytecode to code inspection while preserving installed code and call lifecycle. FX2-1 owns core override handling. |
| R2-044 | — | R2-16 | ABI follow-up for a copied ancestor-hash setter for BLOCKHASH. |
| R2-053, R2-054 | — | R2-09, R2-16 | Compile the public trace JSON API and serialize opcode errors. FX2-1 owns bytecode access and FX2-3 owns logical memory size and trace suspension. |
| R2-056 | — | — | Align Amsterdam transaction admission with the execution and state gas reservoir. |
| — | — | R2-18 (exports) | Remove redundant export shims once the build manifest exports the same names. |

### FX2-3 · Frame, opcodes, and Lean differential harness

| Astra | Fable | Neon | Finding |
| --- | --- | --- | --- |
| R2-015 (beneficiary) | F-18 | R2-04 | Record the SELFDESTRUCT beneficiary touch for EIP-161. |
| R2-034 | F-26 | — | Make strict differential testing reject incorrect BLS membership. The upstream membership table remains a dependency. |
| R2-037, R2-038 | F-20, F-38 | R2-12 (memory) | Follow-up for exact Constantinople SSTORE and wider memory-gas arithmetic in Zig and Lean. The lane covers current MLOAD/MSTORE bounds and gas handling. |
| R2-041, R2-043 | F-38 (frame) | R2-11 | Validate operand counts and the SSTORE sentry before side effects, reject oversized initcode before copying, and move LOG scratch into the transaction arena. FX2-2 owns WASI regression coverage. |
| R2-054 (memory) | — | R2-16 (trace) | Record logical memory size independently of captured bytes and drop the trace entry on a suspend. |
| — | F-37, F-40 | R2-19 (harness) | Require the Lean oracle for normal differential runs and allocate differential frames in the transaction arena. |

### FX2-4 · Host, header validation, and fixture oracle

| Astra | Fable | Neon | Finding |
| --- | --- | --- | --- |
| R2-002–004 | F-03, F-04, F-35 | R2-03 | Fail empty selections, execute every indexed variant, verify consensus roots and logs and require the actual typed rejection. FX2-5 owns CI and fixture build wiring. |
| R2-014 (fixture host), R2-017, R2-045 | F-23, F-30 | R2-13 (failure handling) | Preserve known account existence, account for uncached fork storage and surface host failures. Full storage-wipe semantics require upstream support. |
| R2-018–021 | F-12 | R2-03 | Select Merge rules from chain context, validate blob and optional header fields, decode canonical headers, and process each block and its withdrawals in order. |
| R2-022–026 | F-11, F-24, F-34, F-35 | R2-03 | Recover raw senders, validate fee/nonce/type/fork rules, charge value once, distinguish zero-address CALL, and apply and resolve only verified delegations. |
| R2-046, R2-047 | F-10 | R2-03 | Execute CREATE through the root epilogue and compute blob base fees with accurate intermediates. |
| R2-049, R2-052 | F-39 (fixture runner) | R2-13 (benchmark), R2-14 (benchmark) | Compile the public benchmark, validate assembler PUSH immediates, and handle fixture resource cleanup. FX2-5 owns CI smoke coverage. |

### FX2-5 · CI, build, example, and source packaging

| Astra | Fable | Neon | Finding |
| --- | --- | --- | --- |
| R2-031 | F-15, F-16 (CI), F-25 | R2-14 (CI) | Add PR client tests and a nonempty PUSH0 state-fixture smoke check, plus a manual Lean differential job. Full blockchain and PR Lean gating remain follow-ups. |
| R2-032, R2-033 | F-16 (corpus), F-17 | — | Build and CI follow-ups for isolated fixture generator outputs and complete corpus validation. FX2-4 owns the runner's execution and counting. |
| — | F-39 (test utils) | — | Run the fixture-free test utility suite from the build. |
| R2-055 | F-36 | R2-17 | Reconcile submodule paths and remove tracked backups. Correct obsolete commands and references. |
| R2-050, R2-051 | F-27 | R2-16 (examples) | Release tooling follow-ups for the other WASI examples and the source package inputs. |
| — | — | R2-16 (callback coupling) | Follow-up for making optional WASM opcode hooks independent of the core frame. The frame and ABI boundaries route to FX2-3 and FX2-2. |

### FX2-6 · TypeScript state, transaction inclusion, and execution extensions

| Astra | Fable | Neon | Finding |
| --- | --- | --- | --- |
| R2-027 | F-14 | — | Journal account deletion with code and slots, invalidate storage roots on mutation, and materialize and cache them when read or at outer commit. |
| R2-028 | — | — | Enable the delegation sender exception with EIP-7702 and enforce Osaka's six-blob transaction cap independently of block headroom. |
| R2-029, R2-030 | — | — | Require an atomic replay-to-live subscription and wait for an acknowledgement from every registered extension before exposing a prune height. |
| R2-048 | — | R2-14 (executor) | Client TypeScript follow-up for connecting the production EVM executor to a real backend. |

## Upstream Voltaire

R1-004–006 concern canonical EIP-2537 BLS12-381 dispatch and warming at 0x0b–0x11, field encoding, and gas/discount tables. The sibling still recognized 0x12 and 0x13. R2-034 tracks the local harness policy for that discrepancy. R1-008–010 cover historical BN254 prices, false KZG proof verdicts, and initialization of native KZG trusted setup. Round 2 did not independently rerun those cryptographic cases.

R1-007 / F-13 reproduced the Osaka ModExp pin gap. The declared `8b513683` revision charged 200 gas for empty input, and the sibling `ae039ed07` charged 500. Fable counted this as an integration finding. Publishing the upstream revision, updating the consumer pin, and adding a pinned dependency regression route through FX2-5 after upstream is available. R2-017 / F-30 also need fork-storage wipe semantics from Voltaire for a complete fix.

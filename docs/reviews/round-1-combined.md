# Combined Round 1 review

## Executive Summary

**Release disposition: hold for consensus-sensitive use.** Round 1 reproduced persistent writes after REVERT, missing Osaka CLZ, incorrect Prague BLS dispatch, and broken async execution across suspension and commit. The fixture oracle can report success while skipping cases or accepting transactions expected to fail. The client-ts fixes below address the five issues assigned to FX7. The remaining findings describe the reviewed baselines and require lane-level verification.

| Evidence | Baseline | Coverage |
| --- | --- | --- |
| Astra, `R1-astra.md` | `gm-wave1` / `cf0336e0` | 96 findings, native/WASI builds and runtime checks, published positive BLS vectors, locked client-ts build and tests |
| Fable, `R1-fable.md` | `gm-wave2` / `d04d4e31` | 50 findings, source analysis and experiments against the prebuilt WASI reactor |
| Neon, `R1-neon.md` | `gm-wave1` / `cf0336e0` | 22 findings, source analysis across core execution, async, host and tooling |
| Lean differential, `lean-diff-r1.log` | Wave 2 integration harness | 14,778 vectors and 50 strict mismatches. The original log printed 40. A replay of the same binaries and seed recovered all 50. |

The 129 deduplicated issues include Critical 11, High 63, Medium 37, Low 14, Nit 4. 35 have three-source agreement, 4 have four-source corroboration including the BLS compatibility probe, and 90 have one or two sources.

- **Four-source execution evidence.** CLZ dispatch, zero-length memory expansion, and far calldata/code source handling. The independent replay identifies 26 CLZ vectors and 24 copy/load-family vectors.
- **Four-source BLS address corroboration.** All three reviews describe the draft table. Lean's compatibility probe additionally classified 0x12 and 0x13 as precompiles in all five probes. The harness treats that as a compatibility observation. It does not check the full EIP-2537 operation mapping or count the probe as a mismatch.
- **Three-review release blockers.** Root and CREATE rollback, async slot suspension, stale async commit data, reverted async commits, and the conformance oracle's exception and post-state checks.
- **Positive controls.** Astra matched all 781 P256VERIFY vectors at 6,900 gas, including 566 valid signatures. Neon and Fable confirmed the integrated sibling's 500-gas Osaka ModExp floor. Astra observed 200 gas with the declared pin. The Lean memgas, SSTORE, jumpdest and precompile suites had zero asserted mismatches under the recorded coverage.

## Severity Matrix

Each row represents one defect or tightly related failure family. IDs through R1-096 keep Astra's identifiers. R1-097 and higher capture findings reported elsewhere. A source can map to multiple rows where its entry covers independent failures. Severity follows the highest supported impact in the reviews. The frame-capacity row records the disputed reachability explicitly. Source agreement can cover a subset of a grouped row. The Lean column describes execution evidence or a clearly labeled probe.

| Issue | Severity | Finding | Astra | Fable | Neon | Lean | Agreement |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `R1-001` | Critical | Failed root calls retain persistent effects | `R1-001` | C-10 | F-07 | — | **3-way** |
| `R1-002` | Critical | Failed CREATE leaks constructor effects and rejected code | `R1-002` | C-04, C-08, C-09 | F-04 | — | **3-way** |
| `R1-003` | Critical | Osaka CLZ is unreachable through normal dispatch | `R1-003` | C-01, P-02 | F-01, F-21 | 26 CLZ vectors | **4-way** |
| `R1-004` | Critical | Prague BLS dispatch and warming use nine draft addresses | `R1-004` | C-02 | F-06, F-21 | BLS probe, 5/5 | **4-way (probe)** |
| `R1-013` | Critical | Unsafe memory range and gas arithmetic before validation | `R1-013` | C-03, C-26 | F-02, F-12, F-21 | — | **3-way** |
| `R1-034` | Critical | Async SLOAD and SSTORE mutate before yielding | `R1-034` | C-05, A-02, A-12, P-02 | F-05, F-21 | — | **3-way** |
| `R1-035` | Critical | Async reads and commit JSON ignore authoritative writes | `R1-035` | C-06, A-02, A-12, P-02 | F-05, F-21 | — | **3-way** |
| `R1-065` | Critical | Named spec targets can select zero tests and succeed | `R1-065` | C-07 | — | — | — |
| `R1-070` | Critical | Expected exceptions can pass without rejection | `R1-070` | C-07 | F-14 | — | **3-way** |
| `R1-071` | Critical | State fixtures use only first variants and incomplete post-state checks | `R1-071` | C-07 | F-14 | — | **3-way** |
| `R1-093` | Critical | Live trie storage and loading confuse every hash with the empty root | `R1-093` | — | — | — | — |
| `R1-005` | High | G1ADD accepts and emits the wrong field layout | `R1-005` | — | — | — | — |
| `R1-006` | High | BLS prices and discounts differ from EIP-2537 | `R1-006` | — | — | — | — |
| `R1-007` | High | The pinned Voltaire and sibling disagree on Osaka ModExp | `R1-007` | B-01 | — | — | — |
| `R1-008` | High | Byzantium BN254 uses Istanbul op prices | `R1-008` | — | — | — | — |
| `R1-009` | High | A false KZG proof verdict becomes successful point evaluation | `R1-009` | — | — | — | — |
| `R1-010` | High | Native KZG can verify before trusted setup loads | `R1-010` | — | — | — | — |
| `R1-011` | High | Refund state survives into later transactions | `R1-011` | C-14 | F-07 | — | **3-way** |
| `R1-012` | High | DELEGATECALL loses the parent's call value | `R1-012` | — | — | — | — |
| `R1-014` | High | Zero-length ranges charge gas or reject irrelevant offsets | `R1-014` | C-11 | F-12 | 7 direct, 2 overlapping | **4-way** |
| `R1-015` | High | Far calldata and code reads fail instead of zero-padding | `R1-015` | C-11 | F-12 | 13 direct, 2 overlapping | **4-way** |
| `R1-016` | High | EIP-7702 delegation access is neither warmed nor charged | `R1-016` | C-12 | F-08 | — | **3-way** |
| `R1-017` | High | Transaction setup erases C-provided pre-state | `R1-017` | C-16 | F-07, F-21 | — | **3-way** |
| `R1-018` | High | C transaction context cannot provide ORIGIN and GASPRICE | `R1-018` | — | — | — | — |
| `R1-019` | High | Root message semantics diverge | `R1-019` | — | F-07 | — | — |
| `R1-020` | High | Inconsistent root CREATE creator and nonce | `R1-020` | C-23 | F-07 | — | **3-way** |
| `R1-021` | High | Historical CREATE starts the new contract at nonce one | `R1-021` | — | F-13 | — | — |
| `R1-022` | High | Incorrect touched-account state across frames | `R1-022` | C-19 | F-16 | — | **3-way** |
| `R1-024` | High | Configured fork and activation schedule are ignored | `R1-024` | — | — | — | — |
| `R1-025` | High | Safe builds enforce a consensus-visible loop quota | `R1-025` | C-21 | F-09 | — | **3-way** |
| `R1-026` | High | Input validation diverges from fork rules | `R1-026` | — | F-13 | — | — |
| `R1-027` | High | Historical CALL forwarding and new-account gas are wrong | `R1-027` | C-18 | F-13 | — | **3-way** |
| `R1-028` | High | Historical SELFDESTRUCT surcharge uses the wrong fork rules | `R1-028` | C-18 | F-13 | — | **3-way** |
| `R1-030` | High | Custom precompiles report invalid success or gas | `R1-030` | C-20 | F-07, F-16 | — | **3-way** |
| `R1-031` | High | Hosts leave storage behind when deleting accounts | `R1-031` | B-04 | F-11 | — | **3-way** |
| `R1-036` | High | Async reports reverted changes as ready to commit | `R1-036` | A-05, A-12 | F-05 | — | **3-way** |
| `R1-037` | High | No-injector async execution loses the terminal frame result | `R1-037` | — | — | — | — |
| `R1-038` | High | Re-entrant or suspended handles can invalidate borrowed state | `R1-038` | A-09 | — | — | — |
| `R1-039` | High | Async continuation accepts mismatched or stale replies | `R1-039` | A-03 | F-05 | — | **3-way** |
| `R1-040` | High | Async account lookups bypass injector requests | `R1-040` | A-02 | — | — | — |
| `R1-041` | High | Async CREATE bypasses the creation lifecycle | `R1-041` | — | F-20 | — | — |
| `R1-042` | High | BLOBHASH is dropped or carried over across calls | `R1-042` | A-06, A-12 | F-20 | — | **3-way** |
| `R1-043` | High | Invalid C context inputs trap or apply partially | `R1-043` | A-11, C-24 | F-10 | — | **3-way** |
| `R1-045` | High | C account code setter leaks replaced buffers | `R1-045` | A-08 | F-10 | — | **3-way** |
| `R1-046` | High | Injector code cache mixes allocators and leaks code | `R1-046` | A-10 | F-16 | — | **3-way** |
| `R1-048` | High | Async TypeScript example uses the wrong request layout | `R1-048` | — | — | — | — |
| `R1-050` | High | C access-list packing drops keys and leaks partial allocations | `R1-050` | A-11 | F-10 | — | **3-way** |
| `R1-052` | High | Zig intrinsic gas ignores early fork rules | `R1-052` | B-04 | F-13 | — | **3-way** |
| `R1-053` | High | The Zig client rejects Berlin type-1 transactions | `R1-053` | B-04 | — | — | — |
| `R1-054` | High | Block validation accepts both forbidden gas-limit endpoints | `R1-054` | — | — | — | — |
| `R1-055` | High | Self-mined transactions lose the sender refund | `R1-055` | — | — | — | — |
| `R1-056` | High | Inclusion skips Osaka's 16,777,216 transaction gas cap | `R1-056` | — | — | — | — |
| `R1-058` | High | WorldStateLive publishes a storage-root sentinel | `R1-058` | — | — | — | — |
| `R1-059` | High | Execution extensions can miss blocks between replay and subscribe | `R1-059` | — | — | — | — |
| `R1-060` | High | Prune height omits extensions that have yet to acknowledge | `R1-060` | — | — | — | — |
| `R1-064` | High | CI omits conformance and other advertised artifacts | `R1-064` | B-03 | F-15 | — | **3-way** |
| `R1-066` | High | State and blockchain generators race on one tracked root | `R1-066` | B-03 | — | — | — |
| `R1-067` | High | Raw, missing or malformed fixtures can silently shrink conformance | `R1-067` | B-02 | — | — | — |
| `R1-072` | High | RLP fixtures guess senders and bypass envelope validation | `R1-072` | B-05 | — | — | — |
| `R1-073` | High | RLP settlement double-debits value and misidentifies creation | `R1-073` | — | — | — | — |
| `R1-074` | High | Frontier and Homestead fixtures overpay the miner | `R1-074` | B-05 | F-14 | — | **3-way** |
| `R1-075` | High | Fixture authorizations grant invalid delegations or skip clear | `R1-075` | B-05 | F-14 | — | **3-way** |
| `R1-076` | High | Blockchain fixtures flatten the block sequence | `R1-076` | B-05 | — | — | — |
| `R1-078` | High | Zero-execution-gas fixture failure can retain a value transfer | `R1-078` | — | — | — | — |
| `R1-081` | High | Per-call scratch accumulates for the lifetime of the handle | `R1-081` | C-15 | F-10 | — | **3-way** |
| `R1-089` | High | Pending access-list lifetime conflicts with transaction boundaries | `R1-089` | — | F-10 | — | — |
| `R1-096` | High | PR CI omits the client-ts suite | `R1-096` | — | — | — | — |
| `R1-097` | High | Frame pointer stability depends on capacity growth | — | C-25 | F-03, F-21 | — | — |
| `R1-098` | High | CREATE rejects oversize initcode too late | — | C-13 | — | — | — |
| `R1-099` | High | CREATE collisions overlook existing storage | — | C-17 | — | — | — |
| `R1-100` | High | Raw EIP-7702 designators are lost in state inspection | — | — | F-08 | — | — |
| `R1-108` | High | Async exceptional halts leave stale results and report protocol errors | — | A-01 | — | — | — |
| `R1-110` | High | Nonnullable C export pointers permit null-related undefined behavior | — | — | F-10 | — | — |
| `R1-114` | High | Zig blob and SetCode transaction validation misses invalid envelopes | — | B-04 | F-13 | — | — |
| `R1-023` | Medium | The zero-address recipient starts cold | `R1-023` | — | — | — | — |
| `R1-029` | Medium | Constantinople SSTORE uses legacy gas and refunds | `R1-029` | — | — | — | — |
| `R1-032` | Medium | State backend failures panic the embedding process | `R1-032` | — | — | — | — |
| `R1-033` | Medium | Synchronous storage changes omit cleared slots | `R1-033` | A-11 | — | — | — |
| `R1-044` | Medium | C empty-code calls are refused and leave stale results | `R1-044` | A-11 | — | — | — |
| `R1-047` | Medium | LRU insertion failure corrupts queue/map accounting | `R1-047` | — | — | — | — |
| `R1-049` | Medium | Published TypeScript examples pass JS arrays as WASM pointers | `R1-049` | — | — | — | — |
| `R1-057` | Medium | The live EVM executor rejects every call | `R1-057` | — | — | — | — |
| `R1-062` | Medium | TypeScript address conversion accepts malformed input and omits checksums | `R1-062` | — | — | — | — |
| `R1-068` | Medium | Seven of twelve gitlinks have no URL mapping | `R1-068` | B-03 | — | — | — |
| `R1-069` | Medium | Zig source package excludes required inputs and relies on a sibling path | `R1-069` | B-03 | F-15 | — | **3-way** |
| `R1-077` | Medium | Blob-fee calculation uses Cancun's fraction on Prague and later | `R1-077` | B-05 | F-14 | — | **3-way** |
| `R1-079` | Medium | Parallel fixture workers can leave the runner waiting | `R1-079` | B-05 | — | — | — |
| `R1-082` | Medium | Child calls clone accumulated state even for empty code | `R1-082` | — | F-20 | — | — |
| `R1-083` | Medium | Tracer bytecode accessor returns the wrong type | `R1-083` | — | — | — | — |
| `R1-084` | Medium | Allocation failure leaks state or fabricates returndata | `R1-084` | C-24 | F-16 | — | **3-way** |
| `R1-085` | Medium | Trace capture leaks earlier copies on allocation failure | `R1-085` | — | F-16 | — | — |
| `R1-086` | Medium | Memory operations clone buffers or work byte by byte | `R1-086` | P-01 | F-20 | — | **3-way** |
| `R1-087` | Medium | Advertised stack, depth, bytecode and memory limits are ignored | `R1-087` | C-22 | F-16 | — | **3-way** |
| `R1-088` | Medium | Zig memory DB retains old key/value buffers | `R1-088` | — | — | — | — |
| `R1-090` | Medium | C gas-used getter mixes old results and new context | `R1-090` | — | — | — | — |
| `R1-091` | Medium | C block context cannot supply ancestor hashes | `R1-091` | — | — | — | — |
| `R1-094` | Medium | Invalid txpool config test fails during its fixture setup | `R1-094` | — | — | — | — |
| `R1-095` | Medium | Synchronous Zig calls skip the pending bytecode override | `R1-095` | — | — | — | — |
| `R1-101` | Medium | Gas above signed frame range traps or truncates | — | C-24 | — | — | — |
| `R1-102` | Medium | Account existence and deletion scan every slot | — | P-01 | — | — | — |
| `R1-105` | Medium | SSTORE sentry trace omits remaining gas on OOG | — | — | F-16 | — | — |
| `R1-106` | Medium | Jump-destination analysis is rebuilt for every frame | — | P-01 | — | — | — |
| `R1-107` | Medium | WASM callbacks impose dispatch cost and ABI coupling | — | A-07 | — | — | — |
| `R1-109` | Medium | Async finalization loses logs and skips cleanup | — | A-04, A-12 | F-05 | — | — |
| `R1-115` | Medium | The Zig EVM benchmark calls an absent adapter method | — | B-03 | — | — | — |
| `R1-116` | Medium | Calldata floor omitted from fixture admission | — | B-05 | F-14 | — | — |
| `R1-117` | Medium | Runner's top-level CREATE skips end-of-transaction cleanup | — | — | F-14 | — | — |
| `R1-118` | Medium | TEST_NOFORK selects one test and incorrectly treats skips | — | B-05 | — | — | — |
| `R1-121` | Medium | Build module duplicates types and discards optimization mode | — | B-03 | F-15 | — | — |
| `R1-122` | Medium | test-watch references a missing interactive runner | — | B-03 | F-15 | — | — |
| `R1-123` | Medium | Workflow triggers and force-push ranges are brittle | — | B-06 | F-15 | — | — |
| `R1-051` | Low | The obsolete C entry point exposes a conflicting ABI | `R1-051` | C-27 | F-17 | — | **3-way** |
| `R1-061` | Low | Stopping an idle extension does not wake its source | `R1-061` | — | — | — | — |
| `R1-063` | Low | Experimental Amsterdam gas helpers disagree | `R1-063` | — | — | — | — |
| `R1-092` | Low | Genesis service uses a moving upstream identity | `R1-092` | — | — | — | — |
| `R1-103` | Low | Dead hooks and duplicate utility code | — | C-27 | — | — | — |
| `R1-111` | Low | WASM allocator mode and buffer alignment are unsuitable for typed ABI data | — | A-11 | — | — | — |
| `R1-112` | Low | WASM and EVM tests bypass public execution behavior | — | A-12, P-02 | F-21 | — | — |
| `R1-119` | Low | Fixture assembler lacks Cancun and Osaka mnemonics | — | — | F-18 | — | — |
| `R1-124` | Low | Workflows lack explicit limits and pinned tools | — | B-06 | — | — | — |
| `R1-125` | Low | Tracked runner binary and backup files are artifacts | — | — | F-17 | — | — |
| `R1-126` | Low | WASM example chooses the Osaka P256VERIFY address | — | — | F-19 | — | — |
| `R1-127` | Low | Fixture and test targets link dozens of separate binaries | — | — | F-20 | — | — |
| `R1-128` | Low | Documentation and comments describe obsolete behavior | — | P-03 | F-22 | — | — |
| `R1-129` | Low | Tests exercise unwired fork hooks and unused dispatch helpers | — | P-02 | — | — | — |
| `R1-080` | Nit | Runner comment promises a refund reset that does not happen | `R1-080` | — | — | — | — |
| `R1-104` | Nit | Refund subtraction clamps intermediate signed state | — | C-28 | — | — | — |
| `R1-113` | Nit | Inline WASM export duplicates the build export list | — | P-04 | F-22 | — | — |
| `R1-120` | Nit | Runner swallows errors and prints obsolete debugger text | — | P-04 | F-22 | — | — |

## Detailed Findings Grouped by Subsystem

### Core EVM

- **R1-001 · Failed root calls retain persistent effects.** REVERT and exceptional halts leave state and deletion records behind. The same-address value reversal can burn ETH, and error exits skip transient cleanup. Use a root checkpoint and verify post-state across hosted and hostless paths. (`src/evm.zig`, `src/storage.zig`)
- **R1-002 · Failed CREATE leaks constructor effects and rejected code.** Cover every constructor failure, including deposit OOG, oversize code and rejected prefixes. Restore storage, transient state, logs, touches, warm sets, refunds, nested account changes and any prefunded balance. Frontier deposit OOG keeps an empty-code account. Only REVERT returns constructor output. (`src/evm.zig`, `src/instructions/handlers_system.zig`)
- **R1-011 · Refund state survives into later transactions.** A reused handle can report the previous transaction's 19,900-gas refund. Reset on entry, restore on failure and publish the result's counter. (`src/evm.zig`, `src/root_c.zig`)
- **R1-017 · Transaction setup erases C-provided pre-state.** Persistent slot, balance, nonce and code setters feed maps that initialization clears. Split backing state from transaction scratch and test seeded reads and consecutive calls through the ABI. (`src/evm.zig`, `src/root_c.zig`)
- **R1-019 · Root message semantics diverge.** Root STATICCALL loses its static flag, CALLCODE mixes message roles, and hostless value transfers differ from hosted calls. Build the message and route value transfers consistently. (`src/evm.zig`, `src/async_executor.zig`)
- **R1-020 · Inconsistent root CREATE creator and nonce.** Address derivation uses different creator/nonce pairs and assumes a caller-side nonce increment. Derive once from an explicit transaction nonce and document who increments it. (`src/evm.zig`)
- **R1-021 · Historical CREATE starts the new contract at nonce one.** Use zero before Spurious Dragon and one thereafter. Exercise a historical constructor that creates a child. (`src/evm.zig`)
- **R1-022 · Incorrect touched-account state across frames.** Reverted child touches can delete accounts at transaction end. STATICCALL and SELFDESTRUCT can miss touches and the historical account-creation path applies effects outside a checkpoint. Journal the touches and handle the RIPEMD exception. (`src/evm.zig`, `src/instructions/handlers_system.zig`)
- **R1-023 · The zero-address recipient starts cold.** Distinguish missing destination from a real address zero and prewarm the latter. (`src/evm.zig`)
- **R1-024 · Configured fork and activation schedule are ignored.** Resolve the scheduled fork once per transaction and use it for dispatch, prices and state rules. (`src/evm.zig`, `src/evm_config.zig`)
- **R1-030 · Custom precompiles report invalid success or gas.** Root ignores overrides, child paths ignore a failure flag and over-budget callbacks can underflow remaining gas. Unify dispatch, enforce the returned status and gas budget, and roll back value on failure. (`src/evm.zig`, `src/evm_config.zig`, `src/root_c.zig`)
- **R1-063 · Experimental Amsterdam gas helpers disagree.** Admission rejects above the Osaka cap while the experimental schedule and reservoir model describe a larger total. Align helpers with one adopted schedule before activation. (`src/hardfork_hooks.zig`)
- **R1-081 · Per-call scratch accumulates for the lifetime of the handle.** Arena allocations, new frame reservations and each frame's large stack accumulate. Reuse scratch after result ownership is transferred and measure repeated short calls. (`src/evm.zig`, `src/frame.zig`, `src/bytecode.zig`)
- **R1-082 · Child calls clone accumulated state even for empty code.** Each call deep-copies prior slot/access/transient state and can reread the host, multiplying work by depth. Replace full copies with journal checkpoints. (`src/evm.zig`, `src/access_list_manager.zig`)
- **R1-083 · Tracer bytecode accessor returns the wrong type.** The public accessor declares a byte slice and returns a Bytecode struct. Return the code slice with a defined lifetime and instantiate it in a consumer test. (`src/evm.zig`, `src/frame.zig`)
- **R1-084 · Allocation failure leaks state or fabricates returndata.** Root result allocation can panic, child copies can substitute empty successful output, and child frame allocation can leave value transferred. Return a host failure and discard partial execution effects. (`src/evm.zig`, `src/call_result.zig`)
- **R1-089 · Pending access-list lifetime conflicts with transaction boundaries.** Borrowed pending slices can survive consumption or escape C-side cleanup. Consume a transaction-owned list on entry and verify consecutive calls. Fable B-05 also found fixture warming discarded by initialization. (`src/evm.zig`, `src/root_c.zig`, `test/specs/runner.zig`)
- **R1-095 · Synchronous Zig calls skip the pending bytecode override.** The setter affects the async path. Synchronous calls load installed recipient code, and the example preinstalls code. Define one-call override ownership and exercise an otherwise empty target. (`src/evm.zig`, `src/async_executor.zig`, `examples/simple_call.zig`)
- **R1-097 · Frame pointer stability depends on capacity growth.** Neon flags stale ancestor pointers if the frame array moves at 1,025 entries. Fable traced the current allocator rounding to capacity 1,064, so the cited UAF is unconfirmed on the reviewed build. Reserve stable storage explicitly and test the maximum depth. (`src/evm.zig`, `src/frame.zig`, `src/instructions/handlers_system.zig`)
- **R1-098 · CREATE rejects oversize initcode too late.** Shanghai size validation must precede depth, balance and nonce soft-fail checks. Fable observed a low-balance case continue where an exceptional halt was expected. (`src/evm.zig`, `src/instructions/handlers_system.zig`)
- **R1-099 · CREATE collisions overlook existing storage.** Nonce and code checks miss nonempty storage at the destination. Wire the EIP-7610 check through both hosts and verify the collision case. (`src/evm.zig`, `src/host.zig`)
- **R1-100 · Raw EIP-7702 designators are lost in state inspection.** Snapshot and emptiness checks follow delegated code. Inspect raw bytes for state, code queries and rollback, and follow delegation when executing. (`src/evm.zig`, `src/instructions/handlers_context.zig`)
- **R1-101 · Gas above signed frame range traps or truncates.** Root and CREATE narrow u64 gas to i64 without validation. Reject out-of-range gas at the boundary and keep exceptional execution separate from input errors. (`src/evm.zig`, `src/call_params.zig`, `src/root_c.zig`)
- **R1-102 · Account existence and deletion scan every slot.** Global scans grow with stored state. Index slots by account or maintain per-account metadata. (`src/evm.zig`)
- **R1-103 · Dead hooks and duplicate utility code.** Review unused fork hooks, duplicated P256/CLZ constants, duplicated CREATE2 address calculation and unused frame gas helpers. Track dispatch duplication under R1-003 and the obsolete C implementation under R1-051. (`src/hardfork_hooks.zig`, `src/evm.zig`, `src/frame.zig`)
- **R1-104 · Refund subtraction clamps intermediate signed state.** A skipped subtraction hides negative intermediate refunds. Use the shared signed counter contract and clamp only at result publication. (`src/evm.zig`, `src/instructions/handlers_storage.zig`)

### Opcodes/Frame

- **R1-003 · Osaka CLZ is unreachable through normal dispatch.** The interpreter bypasses the table containing opcode 0x1e. Use a single dispatcher and assert the fork boundary and five-gas cost through real entry points. (`src/frame.zig`, `src/instructions/dispatcher.zig`)
- **R1-012 · DELEGATECALL loses the parent's call value.** Inherit the message value without transferring ETH. Exercise CALLVALUE and balance in a value-bearing proxy. (`src/instructions/handlers_system.zig`, `src/evm.zig`)
- **R1-013 · Unsafe memory range and gas arithmetic before validation.** CALL-family narrowing, sums and word alignment can trap or truncate. MCOPY rounding and alignment in copy, log, hash and control-flow handlers need the same checked arithmetic. Charge before mutating memory. (`src/instructions/handlers_system.zig`, `src/frame.zig`, `src/instructions/handlers_memory.zig`)
- **R1-014 · Zero-length ranges charge gas or reject irrelevant offsets.** No destination expansion is due for an empty range. Preserve the independent RETURNDATACOPY source-bound check. Check MSIZE, gas and LOG behavior. (`src/instructions/handlers_context.zig`, `src/instructions/handlers_log.zig`)
- **R1-015 · Far calldata and code reads fail instead of zero-padding.** Recognize wide source offsets outside input before narrowing and avoid CALLDATALOAD addition overflow. The replay ledger gives the vector breakdown. (`src/instructions/handlers_context.zig`)
- **R1-016 · EIP-7702 delegation access is neither warmed nor charged.** Resolve the target for execution and charge its cold/warm cost before gas forwarding. Verify root and CALL-family behavior. (`src/evm.zig`, `src/instructions/handlers_system.zig`)
- **R1-025 · Safe builds enforce a consensus-visible loop quota.** The default step limit stops valid funded transactions. Use gas as the execution bound and surface optional host cancellation distinctly. (`src/evm_config.zig`, `src/frame.zig`)
- **R1-026 · Input validation diverges from fork rules.** Drop the arbitrary calldata cap and gate the initcode limit on Shanghai. Align async entry validation with synchronous entry. (`src/call_params.zig`, `src/evm.zig`, `src/async_executor.zig`)
- **R1-027 · Historical CALL forwarding and new-account gas are wrong.** Validate excessive forwarding before Tangerine Whistle and charge zero-value calls to missing accounts before Spurious Dragon. Distinguish existing empty accounts from absent accounts. (`src/instructions/handlers_system.zig`)
- **R1-028 · Historical SELFDESTRUCT surcharge uses the wrong fork rules.** Use distinct pre-Tangerine, Tangerine and Spurious Dragon beneficiary-charging rules. (`src/instructions/handlers_system.zig`, `src/frame.zig`)
- **R1-029 · Constantinople SSTORE uses legacy gas and refunds.** Implement and compare EIP-1283 separately from Petersburg and Istanbul behavior. (`src/instructions/handlers_storage.zig`)
- **R1-086 · Memory operations clone buffers or work byte by byte.** MCOPY and KECCAK256 allocate full temporaries. CALL, CREATE, LOG, MLOAD, RETURN and copy handlers repeatedly bounds-check individual bytes. Expand once and use safe bulk routines. (`src/frame.zig`, `src/instructions/handlers_*.zig`)
- **R1-087 · Advertised stack, depth, bytecode and memory limits are ignored.** Keep protocol constants fork-aware and enforce or remove separately advertised host limits. (`src/evm_config.zig`, `src/frame.zig`, `src/evm.zig`)
- **R1-105 · SSTORE sentry trace omits remaining gas on OOG.** Correct EIP-3155 gasCost for the EIP-2200 sentry path. (`src/instructions/handlers_storage.zig`, `src/trace.zig`)
- **R1-106 · Jump-destination analysis is rebuilt for every frame.** Reuse immutable analysis keyed by code and consider a compact bitset. (`src/frame.zig`, `src/bytecode.zig`)
- **R1-107 · WASM callbacks impose dispatch cost and ABI coupling.** Mandatory JS dispatch runs on each opcode, can skip without advancing the PC, and exposes a raw frame pointer without accessors. Gate optional hooks and keep C exports out of core module imports. (`src/frame.zig`, `src/root_c.zig`, `build.zig`)

### Async/C-ABI/WASM

- **R1-018 · C transaction context cannot provide ORIGIN and GASPRICE.** Expose transaction origin and effective gas price independently of caller and block fields. (`src/root_c.zig`, `src/evm.zig`, `src/instructions/handlers_context.zig`)
- **R1-033 · Synchronous storage changes omit cleared slots.** The iterator rescans current storage, misses deletions and can expose unrelated slots. Publish a committed dirty-slot index with explicit zeroes. (`src/root_c.zig`, `src/storage.zig`)
- **R1-034 · Async SLOAD and SSTORE mutate before yielding.** Cold access consumes operands, gas and warming before suspension. A nested call can swallow suspension as child failure. Probe before mutation and propagate resume through nested frames. (`src/instructions/handlers_storage.zig`, `src/storage.zig`, `src/evm.zig`)
- **R1-035 · Async reads and commit JSON ignore authoritative writes.** Cached originals override new slot values, eviction can export zero, and account dirty sets omit nonce, balance and code. Commit from the transaction overlay and assert values and deletions. (`src/storage.zig`, `src/storage_injector.zig`, `src/evm.zig`)
- **R1-036 · Async reports reverted changes as ready to commit.** Resolve execution outcome and roll back before publishing commit data. Preserve REVERT output without publishing changes. (`src/evm.zig`, `src/storage_injector.zig`)
- **R1-037 · No-injector async execution loses the terminal frame result.** Popping the last frame yields synthetic success with empty output and zero remaining gas. Capture the real result first. (`src/evm.zig`, `src/root_c.zig`)
- **R1-038 · Re-entrant or suspended handles can invalidate borrowed state.** Setters, restarts and destruction can invalidate live buffers or replace frames. Pin owned data and reject incompatible operations during execution or suspension. (`src/root_c.zig`, `src/async_executor.zig`, `src/frame.zig`)
- **R1-039 · Async continuation accepts mismatched or stale replies.** Validate phase, expected tag, key and generation, clear the actual pending request, and reject unsolicited commit acknowledgements. (`src/root_c.zig`, `src/async_executor.zig`, `src/evm.zig`)
- **R1-040 · Async account lookups bypass injector requests.** Read misses for balance, code and nonce never yield and their response caches are unused. Bring account data into the suspendable resolver. (`src/evm.zig`, `src/async_executor.zig`, `src/storage_injector.zig`)
- **R1-041 · Async CREATE bypasses the creation lifecycle.** Derived addresses and ordinary call frames skip collision handling, constructor context and code deposit. Reuse the full creation path. (`src/async_executor.zig`, `src/evm.zig`)
- **R1-042 · BLOBHASH is dropped or carried over across calls.** Pass explicit per-transaction blob hashes, including an empty slice on clear, through async and sync entry. (`src/async_executor.zig`, `src/root_c.zig`, `src/evm.zig`)
- **R1-043 · Invalid C context inputs trap or apply partially.** Check fork names, log levels and signed gas before narrowing or publishing. Stage replacement calldata so allocation failure leaves intact metadata. (`src/root_c.zig`)
- **R1-044 · C empty-code calls are refused and leave stale results.** Accept ordinary empty-code destinations and invalidate the old result at each new execution entry. (`src/root_c.zig`)
- **R1-045 · C account code setter leaks replaced buffers.** Parent-allocator code slices leak on replacement, failed insertion, clearing and teardown. Give code explicit ownership. (`src/root_c.zig`, `src/evm.zig`)
- **R1-046 · Injector code cache mixes allocators and leaks code.** Resume inserts arena-owned bytes that cache deinit frees with another allocator. Ensure overwrites, evictions and clears release each owned slice once. (`src/storage_injector.zig`, `src/async_executor.zig`)
- **R1-047 · LRU insertion failure corrupts queue/map accounting.** Allocate and reserve before evicting or linking so every allocation failure preserves lookup and size invariants. (`src/storage_injector.zig`)
- **R1-050 · C access-list packing drops keys and leaks partial allocations.** Group keys by their own addresses, avoid the nested scan and free all partially packed buffers. Pending-slice ownership is tracked under R1-089. (`src/root_c.zig`)
- **R1-051 · The obsolete C entry point exposes a conflicting ABI.** Remove the unused implementation and align public headers and companion docs with the shipped ABI. (`src/evm_c.zig`, `src/root_c.zig`)
- **R1-085 · Trace capture leaks earlier copies on allocation failure.** Clean up partially built trace entries at each failing copy or append. (`src/trace.zig`)
- **R1-090 · C gas-used getter mixes old results and new context.** The mutable input gas changes prior gas-used values and may make them negative. Store gas used with the result and update the getter comments. (`src/root_c.zig`)
- **R1-091 · C block context cannot supply ancestor hashes.** Expose bounded owned hashes or a host callback for BLOCKHASH. (`src/root_c.zig`, `src/instructions/handlers_block.zig`)
- **R1-108 · Async exceptional halts leave stale results and report protocol errors.** Return a failed terminal CallResult, clear the previous result and reserve protocol error tags for ABI failures. (`src/evm.zig`, `src/root_c.zig`)
- **R1-109 · Async finalization loses logs and skips cleanup.** Share terminal result assembly and successful transaction cleanup across sync and async. (`src/evm.zig`)
- **R1-110 · Nonnullable C export pointers permit null-related undefined behavior.** Validate nullable buffer boundaries and permit null only under explicit zero-length rules. (`src/root_c.zig`)
- **R1-111 · WASM allocator mode and buffer alignment are unsuitable for typed ABI data.** Use appropriate WASM allocation and guarantee alignment for AsyncRequest and usize output pointers. (`src/root_c.zig`)
- **R1-112 · WASM and EVM tests bypass public execution behavior.** Cover seeded state, repeat calls, large memory, access-list and blob context, callbacks, result fields, revert, resume and commit contents. Use normal dispatch for CLZ and boundary calls. (`test/wasm.test.mjs`, `src/evm_test.zig`, `src/instructions/clz_test.zig`)
- **R1-113 · Inline WASM export duplicates the build export list.** The redundant export shim and unused export table drift from the shipped ABI. (`src/root_c.zig`, `build.zig`)

### Host/Client-Zig

- **R1-031 · Hosts leave storage behind when deleting accounts.** Implement delete, existence and storage-presence hooks in both backends. Free owned code and verify destroy/recreate cannot see old storage. (`src/host.zig`, `client/evm/host_adapter.zig`, `test/specs/test_host.zig`)
- **R1-032 · State backend failures panic the embedding process.** Surface typed host failure and unwind partial application, with a failing backend test. (`client/evm/host_adapter.zig`, `src/host.zig`)
- **R1-052 · Zig intrinsic gas ignores early fork rules.** Charge 68 for a nonzero byte before Istanbul and gate the 32,000 create surcharge on Homestead. (`client/evm/intrinsic_gas.zig`)
- **R1-053 · The Zig client rejects Berlin type-1 transactions.** Include type 1 in validation, fee pricing and access-list construction. (`client/evm/intrinsic_gas.zig`, `client/evm/processor.zig`)
- **R1-054 · Block validation accepts both forbidden gas-limit endpoints.** Reject a gas delta at or above the strict limit on both sides. Include the London parent adjustment in boundary coverage. (`client/blockchain/validator.zig`)
- **R1-088 · Zig memory DB retains old key/value buffers.** Repeated updates and deletes consume arena memory proportional to history. Bound retained memory and define borrow lifetimes. (`client/db/memory.zig`)
- **R1-114 · Zig blob and SetCode transaction validation misses invalid envelopes.** Reject empty blob/hash or authorization lists, invalid version/count and forbidden creation destinations. (`client/evm/processor.zig`)
- **R1-115 · The Zig EVM benchmark calls an absent adapter method.** Remove invalid deinit calls or supply owned teardown, and compile the benchmark in CI. (`client/evm/bench.zig`, `build.zig`)

### Spec Runner

- **R1-070 · Expected exceptions can pass without rejection.** Require observation of the expected validation error and unchanged state. Add controls where an accepted transaction must fail the fixture. (`test/specs/runner.zig`)
- **R1-071 · State fixtures use only first variants and incomplete post-state checks.** Enumerate every network and indexed data/gas/value/access-list case. Verify code, logs hash, state root and unexpected accounts when the fixture calls for them. (`test/specs/runner.zig`)
- **R1-072 · RLP fixtures guess senders and bypass envelope validation.** Recover signatures instead of pairing by nonce/balance. Handle types 3 and 4 and apply the Osaka cap consistently with JSON transaction validation. (`test/specs/runner.zig`)
- **R1-073 · RLP settlement double-debits value and misidentifies creation.** Buy execution gas once at effective price and let the EVM transfer value. Preserve absent recipient separately from a real zero address. Fable B-05 also found that RLP settlement uses maxFeePerGas instead of the effective price. (`test/specs/runner.zig`)
- **R1-074 · Frontier and Homestead fixtures overpay the miner.** Refund gas left to sender and pay the miner based on actual gas used. (`test/specs/runner.zig`)
- **R1-075 · Fixture authorizations grant invalid delegations or skip clear.** Recover the signer with signature and fork checks. Validate authority code, nonce and existence, warm eligible authorities, clear on zero target and free replaced code. (`test/specs/runner.zig`)
- **R1-076 · Blockchain fixtures flatten the block sequence.** Use each block's environment, transactions and withdrawals in order. Check intermediate roots, gas and receipts. (`test/specs/runner.zig`)
- **R1-077 · Blob-fee calculation uses Cancun's fraction on Prague and later.** Pick the fork schedule and remove silent partial sums on overflow or series cutoffs where exact arithmetic is needed. (`test/specs/runner.zig`)
- **R1-078 · Zero-execution-gas fixture failure can retain a value transfer.** Put value transfer inside the message checkpoint and compare coded and empty accounts at exactly intrinsic gas. (`test/specs/runner.zig`, `src/evm.zig`)
- **R1-079 · Parallel fixture workers can leave the runner waiting.** Reject TEST_WORKERS=0. Make launch/fork errors terminal outcomes and join workers without waiting for missing progress. (`test/utils.zig`, `test_runner.zig`)
- **R1-080 · Runner comment promises a refund reset that does not happen.** Update the settlement comment alongside refund lifecycle R1-011. (`test/specs/runner.zig`)
- **R1-116 · Calldata floor omitted from fixture admission.** Check the larger of intrinsic and floor gas before execution so settlement cannot underflow. (`test/specs/runner.zig`)
- **R1-117 · Runner's top-level CREATE skips end-of-transaction cleanup.** Clear transient storage and process touched empty and selfdestructed accounts through shared finalization. (`test/specs/runner.zig`)
- **R1-118 · TEST_NOFORK selects one test and incorrectly treats skips.** Execute the whole selection and record SkipZigTest as a skip. (`test/utils.zig`, `test_runner.zig`)
- **R1-119 · Fixture assembler lacks Cancun and Osaka mnemonics.** Add CLZ, BLOBHASH, BLOBBASEFEE, TLOAD, TSTORE and MCOPY and exercise textual fixture assembly. (`test/specs/assembler.zig`)
- **R1-120 · Runner swallows errors and prints obsolete debugger text.** Review silent catches and parseIntFromJson's fallback of 1. Remove stray shift/nonce prints, v0.15.1 and checkout-specific banner text. (`test/specs/runner.zig`, `test_runner.zig`)

### Build/CI/Examples

- **R1-048 · Async TypeScript example uses the wrong request layout.** Use wasm32 size 16,444 and JSON offsets 56/60. Allocate with evm_alloc, read large payloads through the separate getter, and assert shared ABI layout in tests. Fable A-11 independently documented the actual structure size and offsets. (`examples/typescript/async-execution.ts`, `src/root_c.zig`)
- **R1-049 · Published TypeScript examples pass JS arrays as WASM pointers.** Initialize WASI imports and transfer payloads through allocated linear memory. (`examples/typescript/basic-usage.ts`, `examples/typescript/advanced-patterns.ts`)
- **R1-064 · CI omits conformance and other advertised artifacts.** Run both fixture suites explicitly and publish nonzero counts by fork. Native C, examples, Lean unit and benchmarks also need explicit targets because the default build can install nothing. (`.github/workflows/ci.yml`, `build.zig`)
- **R1-065 · Named spec targets can select zero tests and succeed.** Selectors look like regexes or upstream fixture paths while matching literal test-name substrings. Validate the selector contract and require nonempty matches. (`test_runner.zig`, `test/utils.zig`, `build.zig`)
- **R1-066 · State and blockchain generators race on one tracked root.** Generate independent cache outputs and make each compile its own root. Remove the unused TEST_TYPE handoff. (`build.zig`, `scripts/update_spec_root.py`)
- **R1-067 · Raw, missing or malformed fixtures can silently shrink conformance.** Filler source JSON suppresses filling, refresh can write into the submodule and generation can truncate wrappers before detecting errors. Validate a versioned fixture manifest and generate in the cache. (`build.zig`, `scripts/generate_spec_tests.py`, `scripts/update_spec_root.py`)
- **R1-068 · Seven of twelve gitlinks have no URL mapping.** Reconcile consensus-specs, devp2p, effect-repo, hive, nethermind, smithers and yellowpaper with the manifest. (`.gitmodules`)
- **R1-069 · Zig source package excludes required inputs and relies on a sibling path.** Include required client, scripts, spec and pin inputs, trim generated wrappers where possible, and ship a content-pinned dependency. Align package and minimum Zig versions. (`build.zig.zon`, `build.zig`, `native-dependencies.json`)
- **R1-092 · Genesis service uses a moving upstream identity.** Pin the registry revision or verify a genesis digest and expose its provenance. (`cloudflare/genesis-worker.ts`)
- **R1-096 · PR CI omits the client-ts suite.** Run the locked client build and fixture-backed test suite as a required check. Astra's baseline had 20 failing tests out of 528. (`.github/workflows/ci.yml`, `client-ts/package.json`)
- **R1-121 · Build module duplicates types and discards optimization mode.** Unify core module identity, especially HostInterface, and propagate the selected optimization mode. (`build.zig`)
- **R1-122 · test-watch references a missing interactive runner.** Restore the runner or retire the build target and its documentation. (`build.zig`)
- **R1-123 · Workflow triggers and force-push ranges are brittle.** Avoid duplicate push/PR runs. Cover pull requests and handle an unavailable before-SHA in commit lint. (`.github/workflows/*.yml`)
- **R1-124 · Workflows lack explicit limits and pinned tools.** Set permissions and timeouts, pin runner/toolchain inputs and add Zig formatting checks. (`.github/workflows/*.yml`)
- **R1-125 · Tracked runner binary and backup files are artifacts.** Remove the zero-byte runner in FX6. Backup cleanup and ignore rules require separate ownership. (`test_runner`, `client/network/*.bak.*`, `.gitignore`)
- **R1-126 · WASM example chooses the Osaka P256VERIFY address.** Move the example destination away from 0x0100 and run the example with Osaka selected. (`examples/wasm.mjs`)
- **R1-127 · Fixture and test targets link dozens of separate binaries.** Check whether filtered runs can share executables and avoid repeated native/Rust crypto link work. (`build.zig`)
- **R1-128 · Documentation and comments describe obsolete behavior.** Reconcile nonexistent spec targets, test-watch, sibling dependency acquisition, WASM size, old field names, pre-state clearing, refund/gas-used comments and loop-quota behavior. (`CLAUDE.md`, `CONTRIBUTING.md`, `src/*.zig.md`, `src/evm.zig`, `src/evm_config.zig`, `src/root_c.zig`, `client/evm/root.zig`)
- **R1-129 · Tests exercise unwired fork hooks and unused dispatch helpers.** Keep focused helpers where they serve real callers and verify dispatch and fork behavior through Evm.call. (`src/hardfork_hooks.zig`, `src/instructions/dispatcher.zig`)

### Client-TS

- **R1-055 · Self-mined transactions lose the sender refund.** Both writes used the pre-refund balance. FX7 validates the combined delta and applies one write for equal addresses, including distinct byte arrays with the same address. (`client-ts/evm/TransactionProcessor.ts`)
- **R1-056 · Inclusion skips Osaka's 16,777,216 transaction gas cap.** FX7 requires the active ReleaseSpec at inclusion, rejects cap+1 before sender mutation, and tests Osaka cap and Prague cap+1. (`client-ts/evm/TransactionProcessor.ts`, `client-ts/evm/ReleaseSpec.ts`)
- **R1-057 · The live EVM executor rejects every call.** The exported layer unconditionally returns EvmExecutionError. Wire the real backend and test observable execution through the production entry. (`client-ts/evm/EvmExecutor.ts`)
- **R1-058 · WorldStateLive publishes a storage-root sentinel.** FX7 derives the secure storage trie root from slot preimages and RLP of minimal values. Slot changes and roots are journaled together. Regression cases cover update, deletion to the canonical empty root and parent rollback after a child commits. (`client-ts/state/State.ts`)
- **R1-059 · Execution extensions can miss blocks between replay and subscribe.** Use a cursor-based subscription or subscribe first, buffer and reconcile by hash and height through reorganizations. (`ts/exex/manager.ts`, `ts/exex/types.ts`)
- **R1-060 · Prune height omits extensions that have yet to acknowledge.** Establish all required cursors before reporting an aggregate prune point. Verify restart and lagging subscribers. (`ts/exex/manager.ts`)
- **R1-061 · Stopping an idle extension does not wake its source.** Make replay and subscriptions abortable and ensure their iterators close when idle. (`ts/exex/manager.ts`, `ts/exex/types.ts`)
- **R1-062 · TypeScript address conversion accepts malformed input and omits checksums.** Validate exact length and hex pairs, and apply EIP-55 casing. (`src/utils/voltaire-imports.ts`)
- **R1-093 · Live trie storage and loading confuse every hash with the empty root.** A truthy Hash.equals Effect made nonempty writes disappear and empty reads or presence checks succeed. FX7 shares the synchronous byte comparison and verifies live round trip, miss and canonical empty root. (`client-ts/trie/NodeStorage.ts`, `client-ts/trie/NodeLoader.ts`)
- **R1-094 · Invalid txpool config test fails during its fixture setup.** FX7 supplies a valid validator dependency and sends the invalid size to the real TxPoolLive constructor. (`client-ts/txpool/TxPool.test.ts`, `client-ts/txpool/TxPool.ts`)

FX7 verification used Node 26.5.0 and Vitest 2.1.9 with a temporary set of focused dependencies and the published Voltaire 0.2.27 runtimes. The seven targeted suites passed all 147 tests. An earlier eight-suite run passed 154 tests and failed one because the FX7 checkout lacks `ethereum-tests/TrieTests/trietest.json`.

### Upstream Voltaire Dependencies

- **R1-004 · Prague BLS dispatch and warming use nine draft addresses.** Final EIP-2537 uses 0x0b–0x11. Six active addresses have the wrong operation and 0x12/0x13 are incorrectly treated as precompiles and warmed. The Lean compatibility probe observed the out-of-range recognition. Astra's positive-vector run matched output on 6 of 370 and output plus gas on 4 of 370. (`Voltaire precompiles/root.zig`, `src/evm.zig`)
- **R1-005 · G1ADD accepts and emits the wrong field layout.** Implement canonical 64-byte field elements, validate encodings and apply subgroup requirements per operation. (`Voltaire crypto/bn254_wrapper.rs`)
- **R1-006 · BLS prices and discounts differ from EIP-2537.** G1ADD costs 500 where 375 is required. Verify gas boundaries, pairing and MSM discount tables independently of dispatch. (`Voltaire precompiles/bls12_*.zig`)
- **R1-007 · The pinned Voltaire and sibling disagree on Osaka ModExp.** The pin uses 200 gas on empty input and the sibling uses 500. Publish and pin fork-aware length and gas pricing, and check EIP-7823/EIP-7883 boundaries in native and WASI. (`native-dependencies.json`, `build.zig.zon`, `.github/workflows/wasm.yml`)
- **R1-008 · Byzantium BN254 uses Istanbul op prices.** Select prices by fork for all three BN254 operations, with boundary tests. (`Voltaire precompiles/root.zig`)
- **R1-009 · A false KZG proof verdict becomes successful point evaluation.** Reject false before constructing success and check the negative vector's status, gas and return data. (`Voltaire precompiles/point_evaluation.zig`)
- **R1-010 · Native KZG can verify before trusted setup loads.** Initialize trusted setup once at the verification boundary and propagate failure. Test a valid evaluation on a fresh native handle. (`Voltaire crypto/kzg_setup.zig`, `src/evm.zig`, `src/root_c.zig`)

## Differential Replay Ledger

The existing Wave 2 fuzz binary and Lean oracle were replayed read-only using seed `0x6c65616e2d646966`, scale 1, all suites, strict halt-reason comparison and `LEAN_DIFF_MAX_REPORT=100`. The replay reproduced the original suite totals and all 40 printed cases. It also printed the missing 10 EXEC cases, #1871 through #2670. The harness exited 1 as expected for the 50 mismatches.

| Suite | Vectors | Strict mismatches | Halt reason only |
| --- | ---: | ---: | ---: |
| word | 3,552 | 20 | 0 |
| memgas | 1,660 | 0 | 0 |
| sstore | 4,388 | 0 | 0 |
| jumpdest | 1,611 | 0 | 0 |
| precompile | 885 | 0 | 0 |
| exec | 2,682 | 30 | 20 |
| **Total** | **14,778** | **50** | **20** |

All 20 WORD mismatches are Osaka CLZ, R1-003. The IDs are #2896–#2911, #3130, #3216, #3350 and #3533. Zig returned InvalidOpcode on every case. Lean returned the CLZ count with gas cost 5. The first range accounts for 16 distinct vectors.

For EXEC, gas is remaining gas. A **halt reason** discrepancy exhausts gas on both sides and is accepted with `LEAN_DIFF_HALT_EQUIV=1`. **Execution** covers distinct gas, execution status or output. Combined mappings identify overlaps. A slash indicates an unresolved copy-family attribution. The copy/load classification follows the first divergence and does not infer independent bugs from later execution.

| EXEC vector | Fork | Zig halt or operation | Zig status / gas | Lean status / gas | Difference | Related finding |
| --- | --- | --- | --- | --- | --- | --- |
| #6 | PRAGUE | CODECOPY | `OOG` / 0 | `STACK_OVERFLOW` / 0 | Halt reason | `R1-015` |
| #147 | OSAKA | CLZ | `INVALID_OPCODE` / 0 | `OOG` / 0 | Halt reason | `R1-003` |
| #201 | OSAKA | CODECOPY | `OOG` / 0 | `RETURN` / 12585 | Execution | `R1-014` · Zero length, destination ≥ 2³² |
| #563 | LONDON | CODECOPY | `OOG` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-014` + `R1-015` · Zero length with wide source |
| #855 | OSAKA | CALLDATACOPY | `OOG` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-015` |
| #895 | CANCUN | CODECOPY | `OOG` / 0 | `INVALID_OPCODE` / 0 | Halt reason | `R1-014` / `R1-015` · Copy family, exact operand cause unverified |
| #899 | LONDON | CALLDATACOPY | `OOG` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-015` |
| #908 | PRAGUE | CALLDATALOAD | `OOG` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-015` |
| #926 | SHANGHAI | CODECOPY | `OOG` / 0 | `INVALID_OPCODE` / 0 | Halt reason | `R1-014` · Zero length, large destination |
| #1038 | SHANGHAI | CALLDATALOAD | `OOG` / 0 | `STACK_OVERFLOW` / 0 | Halt reason | `R1-015` |
| #1205 | OSAKA | CLZ | `INVALID_OPCODE` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-003` |
| #1217 | OSAKA | CLZ | `INVALID_OPCODE` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-003` |
| #1322 | SHANGHAI | CODECOPY | `OOG` / 0 | `INVALID_JUMP` / 0 | Halt reason | `R1-015` |
| #1409 | CANCUN | CALLDATACOPY → RETURN | `RETURN` / 105817 | `RETURN` / 105829 | Execution | `R1-014` · Zero-length copy overcharges 12 gas |
| #1410 | CANCUN | CALLDATACOPY → RETURN | `RETURN` / 0 | `RETURN` / 12 | Execution | `R1-014` · Zero-length copy overcharges 12 gas |
| #1411 | CANCUN | RETURN | `OOG` / 0 | `RETURN` / 11 | Execution | `R1-014` · Zero-length copy overcharge makes RETURN run OOG |
| #1475 | CANCUN | CODECOPY | `OOG` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-015` |
| #1503 | OSAKA | CLZ | `INVALID_OPCODE` / 0 | `STOP` / 70918 | Execution | `R1-003` |
| #1566 | BERLIN | CODECOPY | `OOG` / 0 | `STOP` / 75255 | Execution | `R1-014` · Zero length, destination ≥ 2³² |
| #1682 | PRAGUE | CODECOPY | `OOG` / 0 | `INVALID_JUMP` / 0 | Halt reason | `R1-015` |
| #1871 | CANCUN | CODECOPY | `OOG` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-014` + `R1-015` · Zero length with wide source |
| #1877 | CANCUN | CODECOPY | `OOG` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-015` |
| #2060 | BERLIN | CODECOPY | `OOG` / 0 | `STACK_UNDERFLOW` / 0 | Halt reason | `R1-015` |
| #2113 | OSAKA | CLZ | `INVALID_OPCODE` / 0 | `OOG` / 0 | Halt reason | `R1-003` |
| #2224 | BERLIN | CODECOPY | `OOG` / 0 | `RETURN` / 95121 | Execution | `R1-015` |
| #2251 | OSAKA | CLZ | `INVALID_OPCODE` / 0 | `STOP` / 99038 | Execution | `R1-003` |
| #2255 | CANCUN | CALLDATACOPY | `OOG` / 0 | `INVALID_OPCODE` / 0 | Halt reason | `R1-014` / `R1-015` · Copy family, exact operand cause unverified |
| #2297 | OSAKA | CALLDATACOPY | `OOG` / 0 | `INVALID_OPCODE` / 0 | Halt reason | `R1-015` |
| #2515 | OSAKA | CALLDATACOPY | `OOG` / 0 | `REVERT` / 57130 | Execution | `R1-014` · Zero length, large destination |
| #2670 | BERLIN | CODECOPY | `OOG` / 0 | `STOP` / 4911 | Execution | `R1-015` |

## Fix Lane Mapping

Assignments follow the FX1–FX7 file contract. Multiple lanes indicate shared interfaces or separate implementation and verification work. The mapping is ownership guidance. Each lane's receipt determines which findings have been fixed.

| Lane | Scope | Issues |
| --- | --- | --- |
| FX1 | EVM root and child lifecycle, rollback, refunds, raw delegation, execution context and core tests. | `R1-001`, `R1-002`, `R1-003`, `R1-004`, `R1-010`, `R1-011`, `R1-012`, `R1-016`, `R1-017`, `R1-018`, `R1-019`, `R1-020`, `R1-021`, `R1-022`, `R1-023`, `R1-024`, `R1-026`, `R1-030`, `R1-031`, `R1-034`, `R1-035`, `R1-036`, `R1-037`, `R1-038`, `R1-039`, `R1-040`, `R1-041`, `R1-042`, `R1-045`, `R1-078`, `R1-080`, `R1-081`, `R1-082`, `R1-083`, `R1-084`, `R1-087`, `R1-089`, `R1-091`, `R1-095`, `R1-097`, `R1-098`, `R1-099`, `R1-100`, `R1-101`, `R1-102`, `R1-103`, `R1-104`, `R1-106`, `R1-108`, `R1-109`, `R1-112`, `R1-117`, `R1-128`, `R1-129` |
| FX2 | Frame dispatch, opcode semantics, checked ranges, fork rules and non-destructive async slot pre-check. | `R1-002`, `R1-003`, `R1-012`, `R1-013`, `R1-014`, `R1-015`, `R1-016`, `R1-022`, `R1-024`, `R1-025`, `R1-026`, `R1-027`, `R1-028`, `R1-029`, `R1-030`, `R1-034`, `R1-086`, `R1-087`, `R1-097`, `R1-098`, `R1-100`, `R1-101`, `R1-103`, `R1-104`, `R1-105`, `R1-106`, `R1-107`, `R1-112`, `R1-128`, `R1-129` |
| FX3 | Async protocol, storage and injector ownership, C ABI, traces, WASM tests and obsolete C root removal. | `R1-003`, `R1-010`, `R1-011`, `R1-017`, `R1-018`, `R1-019`, `R1-026`, `R1-030`, `R1-033`, `R1-034`, `R1-035`, `R1-036`, `R1-037`, `R1-038`, `R1-039`, `R1-040`, `R1-041`, `R1-042`, `R1-043`, `R1-044`, `R1-045`, `R1-046`, `R1-047`, `R1-048`, `R1-050`, `R1-051`, `R1-081`, `R1-083`, `R1-085`, `R1-089`, `R1-090`, `R1-091`, `R1-101`, `R1-105`, `R1-107`, `R1-108`, `R1-109`, `R1-110`, `R1-111`, `R1-112`, `R1-113`, `R1-128` |
| FX4 | Host and test-host lifecycle, Zig client validation, intrinsic gas and block header rules. | `R1-031`, `R1-032`, `R1-052`, `R1-053`, `R1-054`, `R1-099`, `R1-114`, `R1-115` |
| FX5 | Fixture admission, block ordering, state/log oracles, assembler and runner accounting. | `R1-065`, `R1-070`, `R1-071`, `R1-072`, `R1-073`, `R1-074`, `R1-075`, `R1-076`, `R1-077`, `R1-078`, `R1-079`, `R1-080`, `R1-089`, `R1-116`, `R1-117`, `R1-118`, `R1-119`, `R1-120` |
| FX6 | Build, packaging, CI, supported examples and dependency pin coordination. | `R1-004`, `R1-007`, `R1-048`, `R1-064`, `R1-065`, `R1-066`, `R1-067`, `R1-069`, `R1-096`, `R1-107`, `R1-113`, `R1-115`, `R1-121`, `R1-122`, `R1-123`, `R1-124`, `R1-125`, `R1-126`, `R1-127`, `R1-128` |
| FX7 | TypeScript client and this synthesis. The five requested issues were addressed here. | `R1-055`, `R1-056`, `R1-057`, `R1-058`, `R1-093`, `R1-094`, `R1-096` |
| Upstream Voltaire | Precompile dispatch, encoding, gas, dependency-pin parity and KZG correctness. | `R1-004`, `R1-005`, `R1-006`, `R1-007`, `R1-008`, `R1-009`, `R1-010` |
| Outside lanes | Portions of the report that require separate ownership under the current contract. These include legacy TS and extension code, ancillary Zig modules, generator scripts, submodule metadata, backup files, adjacent examples and documentation. | `R1-049`, `R1-059`, `R1-060`, `R1-061`, `R1-062`, `R1-063`, `R1-066`, `R1-067`, `R1-068`, `R1-088`, `R1-092`, `R1-103`, `R1-106`, `R1-125`, `R1-128`, `R1-129` |

- **FX1 and FX2** share the signed refund API, raw code/delegation helpers and single opcode-dispatch contract.
- **FX2 and FX3** share non-destructive async slot loading. FX1 owns transaction-level propagation and teardown in `src/evm.zig`.
- **FX4 and FX5** share fixture coverage for host deletion, creation collisions and transaction validation. **FX5 and FX6** coordinate nonempty selectors and independent fixture generation.
- **Upstream Voltaire, FX1 and FX6** coordinate the corrected precompile table, integration warming and dependency pin. Keep a Lean harness assertion for the final table once the integration is ready.

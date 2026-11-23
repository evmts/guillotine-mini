# Hardfork roadmap

Guillotine-mini at `edafd394` executes Prague but is not Osaka-complete, and its Voltaire pin still ships the pre-final 9-address BLS12-381 layout. This document records the conformance status, the Voltaire commits to adopt, the Glamsterdam (Amsterdam) plan, and the Zig upgrade order.

Audit date: 2026-11-22. Sources: Voltaire jj repo (`maint/base` = `ae039ed0` and its children), guillotine-mini `edafd394`, and the EIP texts on `ethereum/EIPs` master.

```
            Voltaire (primitives, crypto, precompiles, Hardfork enum)
                 |
                 v
            guillotine-mini (EVM: frame, evm, hardfork_hooks)
                 |
                 v
            zevm (downstream consumer)

Every upgrade in this document flows top to bottom. Never upgrade a lower
layer first.
```

## 1. Conformance status

Status is by code inspection of `edafd394`. Pass rates are not measured: the `execution-spec-tests/` and `ethereum-tests/` fixture directories are empty in the maintenance checkouts. Populate them and run `zig build specs-prague-*` and `zig build specs-osaka-*` before calling either fork conformant.

### Prague

| EIP | Feature | Status | Evidence / gap |
|---|---|---|---|
| 2537 | BLS12-381 precompiles | **Wrong addresses** | Voltaire pin maps 9 operations to `0x0b..0x13`. Final EIP has 7 at `0x0b..0x11`. `src/evm.zig:619-627` hardcodes the `0x13` warm range. Fixed upstream by `ab9264bb`; lane P1 switches warming to `precompiles.isPrecompile`. |
| 7702 | Set-code transactions | Present | `src/evm.zig`; spec targets `specs-prague-setcode-*`. |
| 7623 | Calldata floor cost | Verify | No reference in `src/evm.zig`. The floor is applied in the transaction layer; confirm with `specs-prague-calldata-cost-*`. |
| 2935, 7002, 7251, 6110, 7685 | System contracts and requests | Block-level | Outside the EVM library. Voltaire `ae039ed0` preserves `requestsHash`. |

### Osaka

| EIP | Feature | Status at `edafd394` | Owner |
|---|---|---|---|
| 7939 | CLZ opcode `0x1e`, 5 gas | Missing: dispatcher treats `0x1e` as invalid | Lane O2 |
| 7951 | P256VERIFY at `0x0100`, 6900 gas | Missing | Lane P1, needs Voltaire `2e96f454` |
| 7823 / 7883 | ModExp bounds and repricing | In Voltaire `ae039ed0` (`modexp.execute` takes the hardfork) | Pin upgrade |
| 7825 | Tx gas limit cap 16,777,216 | Missing in guillotine-mini. Voltaire exposes `TxGasLimitOsaka` | Transaction layer |
| 7934 | 10 MiB RLP block size limit | In Voltaire `f2b29c2a` (`Rlp`) | Block layer |
| 7918, 7594, 7892 | Blob fee floor, PeerDAS, BPO | Not audited | Open |
| n/a | `"OSAKA"` hardfork string | Missing: `getHardforkFromString` falls back to CANCUN | Lane O2 |

`src/hardfork_hooks.zig` gives the three Osaka gates one name each: `supportsClz`, `supportsP256Verify`, `supportsEip7825TxGasCap`.

## 2. Voltaire audit

The Voltaire maintenance commits are siblings on `maint/base`. None is on `main`.

```
8b513683 ──┬── f79b1033  main
           └── ae039ed0  maint/base   Osaka: 7685, 7939, 7823/7883, 7825
                 ├── ab9264bb  EIP-2537 final 7-op layout (0x0b..0x11)
                 ├── f2b29c2a  default = OSAKA, AMSTERDAM tag, EIP-7934
                 ├── 2e96f454  wip: EIP-7951 P256VERIFY, precompile cleanup
                 ├── 60595c41  c-kzg-4844 v2.1.8, blst v0.3.17
                 └── aed1d7a0  arkworks 0.6.0, keccak-asm 0.1.9
```

| Commit | Verdict | Finding |
|---|---|---|
| `ae039ed0` | Adopt | Adds CLZ opcode metadata, ModExp EIP-7823/7883, `TxGasLimitOsaka = 16_777_216`, `requestsHash`. `Hardfork` ends at `OSAKA`; `DEFAULT` is `PRAGUE`. It is not an ancestor of `main`. |
| `ab9264bb` | Adopt first | `isPrecompile` returns `addr <= 0x11` from Prague. Addresses match the final EIP: G1ADD `0b`, G1MSM `0c`, G2ADD `0d`, G2MSM `0e`, PAIRING `0f`, MAP_FP_TO_G1 `10`, MAP_FP2_TO_G2 `11`. |
| `f2b29c2a` | Adopt | Adds the `AMSTERDAM` enum tag (alias `"Glamsterdam"`), sets `DEFAULT = OSAKA`, adds `exceedsMaxRlpBlockSize`. The default change alters behavior for every caller that relies on `Hardfork.DEFAULT`. |
| `2e96f454` | Adopt after rework | Described as `wip`. Adds `p256verify.zig` (160-byte input, 6900 gas, empty output on failure). Its `isPrecompile` is `addr <= 0x13 or addr == 0x0100`, which contradicts `ab9264bb`. The merged form must be `addr <= 0x11 or addr == 0x0100`. |
| `60595c41` | Adopt, rerun KZG tests | Vendored source swap, 120 files. Build paths and C flags unchanged per the description. Rerun `specs-cancun-blob-precompile`. |
| `aed1d7a0` | Adopt, rerun BN254/BLS tests | `ark-*` 0.5.0 to 0.6.0, `keccak-asm` 0.1.4 to 0.1.9. Serialization changes in arkworks would surface in `specs-prague-bls-*` and `specs-frontier-precompiles`. |

Merge conflicts to expect: `evm/precompiles/root.zig` (`ab9264bb` vs `2e96f454`), `Hardfork/Eips.zig` (`f2b29c2a` vs `2e96f454`), and the BLS precompile files (`ab9264bb` vs `2e96f454`).

### ECRECOVER (BUG_HUNT_REPORT #12): not fixed

No commit above `ae039ed0` touches `evm/precompiles/ecrecover.zig`. Three divergences from the execution-specs `ecrecover` remain:

| # | Voltaire behavior | Spec behavior |
|---|---|---|
| 1 | Reads `v_bytes[31]` only (line 39). Upper 31 bytes of `v` are ignored. | `v` is the full 32-byte integer and must equal 27 or 28. |
| 2 | `recoverPubkeyAllowHighS` also accepts `v` of 0 or 1. | 0 and 1 are invalid. |
| 3 | Invalid signature returns 32 zero bytes. | Invalid signature returns empty output. |

Rows 2 and 3 come from reading the code against the EELS behavior quoted in the bug report. Verify both against `execution-specs/src/ethereum/forks/prague/vm/precompiled_contracts/ecrecover.py` once the submodule is populated. Fix in Voltaire with one test per row, then bump the pin.

## 3. Voltaire pin upgrade checklist

`build.zig.zon` uses `.path = "../voltaire"`, so the pin is whatever the adjacent checkout holds.

1. [ ] Voltaire: fix ECRECOVER (#12 and the two related rows) with tests.
2. [ ] Voltaire: change the `skills` submodule URL in `.gitmodules` from `git@github.com:evmts/skills.git` to `https://github.com/evmts/skills.git`. The SSH URL fails recursive checkout on any host without a GitHub SSH key, which includes CI runners and `zig fetch` consumers.
3. [ ] Voltaire: merge `ab9264bb`, `f2b29c2a`, `2e96f454`, `60595c41`, `aed1d7a0` onto one line. Resolve `isPrecompile` to `<= 0x11 or == 0x0100` for Osaka.
4. [ ] Voltaire: land that line on `main`. `maint/base` and `main` have diverged from `8b513683`.
5. [ ] guillotine-mini: confirm no `0x13` literal remains in `src/evm.zig` (lane P1).
6. [ ] guillotine-mini: audit every use of `Hardfork.DEFAULT`; it becomes `OSAKA`.
7. [ ] guillotine-mini: run `zig build test`, `specs-prague-bls-*`, `specs-cancun-blob-precompile`, `specs-frontier-precompiles`, `specs-osaka-*`, and `zig build wasm`.
8. [ ] guillotine-mini: run `zig test src/hardfork_hooks.zig`. After step 3 the enum has `AMSTERDAM`, and `supportsAmsterdam` stops folding to `false`.
9. [ ] zevm: bump after guillotine-mini is green.

## 4. Glamsterdam (Amsterdam)

Planning target: mainnet in January or February 2027. EIP-7773 lists a Sepolia activation at epoch 353024 (2026-10-06) and leaves the Hoodi and mainnet rows blank, so the mainnet date is a target, not a schedule.

EIP-7708, 7928, 8037 and 8038 were in Last Call on 2026-11-22. EIP-8037 states its values are not final.

### Execution-layer EIPs scheduled in EIP-7773

| EIP | Change | EVM impact | Hook in `src/hardfork_hooks.zig` |
|---|---|---|---|
| 7708 | ETH transfers emit a log | CALL, CREATE, SELFDESTRUCT, tx value transfer | `eth_transfer_log` |
| 7928 | Block-Level Access Lists | Every state access | `block_access_list` |
| 8037 | State creation gas | SSTORE, CREATE, code deposit, EIP-7702 auth, gas accounting | `GasSchedule`, `GasSplit`, `StateGasReservoir` |
| 8038 | State access gas | All EIP-2929 call sites, access lists | `GasSchedule` |
| 8246 | Remove SELFDESTRUCT burn | SELFDESTRUCT to self | `SelfdestructToSelfPolicy.no_burn` |
| 7778 | Block gas accounting without refunds | Block gas used | None yet |
| 2780 | Resource-based intrinsic gas | Intrinsic gas | None yet |
| 7976 / 7981 | Calldata floor and access list cost | Intrinsic gas | Access list costs in `GasSchedule` |
| 7843 | SLOTNUM opcode | New opcode | None yet |
| 8024 | SWAPN, DUPN, EXCHANGE | New opcodes with immediates | None yet |
| 7954 | Larger max contract size | CREATE, code deposit | None yet |
| 7997 | Deterministic factory | Predeploy | None |

Consensus-layer EIPs in the same list (7732, 7495, 7688, 7916, 8045, 8061, 8282) do not touch the EVM.

### Hook design

```
frame.zig / evm.zig
   |
   |  if (hooks.supportsAmsterdam(self.hardfork)) ...     comptime false on old pins
   |
   +--> hooks.GasSchedule.forFork(hardfork)       -> *const GasSchedule
   +--> hooks.eth_transfer_log.transferLog(...)   -> ?SystemLog   (append to frame logs)
   +--> hooks.block_access_list.Hook(Recorder)    -> recorder.record*(...)
```

- **Capability helpers** take the hardfork value as `anytype` and look tags up with `@hasField`. On a Voltaire pin without `AMSTERDAM` the Amsterdam helpers are comptime `false`.
- **EIP-7708** defines one log: LOG3 from `0xff..fe`, topic0 `keccak256("Transfer(address,address,uint256)")`, topics `from` and `to`, data the amount. `transferLog` returns `null` for zero value and for a self transfer. The Last Call text defines no burn log because EIP-8246 removes the burn. `selfdestructBurnLog` and its `Selfdestruct(address,uint256)` topic exist only for devnets that predate EIP-8246; its signature is not confirmed by the current EIP text.
- **EIP-7928** recorder methods: `recordAddressAccess`, `recordStorageRead`, `recordStorageWrite`, `recordBalanceChange`. `Hook` stamps the block access index (0 pre-execution, `1..n` transactions, `n+1` post-execution) and demotes a no-op SSTORE to a read. `NoopRecorder` costs nothing. `ListRecorder` is a reference recorder for tests.
- **EIP-8037 / 8038** values live in two tables, `GasSchedule.prague` and `GasSchedule.amsterdam`.

| Parameter | Prague | Amsterdam draft |
|---|---|---|
| `cold_account_access` | 2,600 | 3,000 |
| `cold_storage_access` | 2,100 | 2,100 |
| `warm_access` | 100 | 100 |
| `account_write` | 6,700 (derived) | 9,000 |
| `storage_write` | 2,800 (derived) | 10,000 |
| `create_access` | 7,000 (derived) | 12,000 |
| `storage_clear_refund` | 4,800 | 11,616 |
| `access_list_storage_key` | 1,900 | 2,000 |
| `access_list_address` | 2,400 | 2,900 |
| `callValue()` | 9,000 | 11,300 |
| `cost_per_state_byte` | 0 | 1,530 |
| `create` (regular + state) | 32,000 + 0 | 12,000 + 183,600 |
| `new_account` | 25,000 + 0 | 0 + 183,600 |
| `storage_set` | 20,000 + 0 | 0 + 97,920 |
| `per_empty_account` (7702) | 25,000 + 0 | 9,000 + 183,600 |
| `per_auth_base` (7702) | 12,500 + 0 | 7,816 + 35,190 |
| code deposit | 200 per byte | 6 per word + 1,530 per byte state |
| `tx_max_total_gas_limit` | none | 4,294,967,295 |

`per_auth_base.regular` (7,816) is computed from the EIP-8037 formula `1,616 + ECRECOVER 3,000 + COLD_ACCOUNT_ACCESS + 2 * WARM_ACCESS`. The EIP gives no numeric total.

### Work remaining after this module

| # | Work | File owner |
|---|---|---|
| 1 | Replace hardcoded access and creation gas with `GasSchedule.forFork` | `frame.zig`, `handlers_storage.zig`, `handlers_system.zig`, `evm.zig` |
| 2 | Two-dimensional gas: carry `GasSplit` through frames; reservoir pass-down, revert restore, and LIFO refill per EIP-8037 | `evm.zig`, `frame.zig` |
| 3 | Emit `transferLog` at CALL, CREATE, SELFDESTRUCT and tx start | `evm.zig`, `handlers_system.zig` |
| 4 | Thread a `block_access_list.Hook` through `Evm`; add `recordNonceChange` and `recordCodeChange` | `evm.zig`, `hardfork_hooks.zig` |
| 5 | Sorted, deduplicated, revert-aware BAL builder with RLP encoding and `block_access_list_hash` | `client/` |
| 6 | SLOTNUM, SWAPN, DUPN, EXCHANGE opcodes | `opcode.zig`, `dispatcher.zig` |
| 7 | EIP-7778, 2780, 7976, 7981, 7954 | Transaction and block layer |
| 8 | Re-verify every Amsterdam number against `execution-specs/src/ethereum/forks/amsterdam/` | `hardfork_hooks.zig` |

Item 2 is the largest change. It alters the gas fields of `Frame` and the return path of `inner_call` and `inner_create`.

## 5. Zig upgrade plan: 0.15.2 to 0.17.x

All three repositories build with Zig 0.15.2 today (`minimum_zig_version = "0.15.1"`). Upgrade in dependency order, one minor version at a time, and never leave two layers on different compilers on `main`.

```
step   voltaire        guillotine-mini     zevm
----   -------------   -----------------   -----------
 0     0.15.2          0.15.2              0.15.2       today
 1     0.16.x          0.15.2 (old pin)    0.15.2
 2     0.16.x          0.16.x              0.15.2 (old pin)
 3     0.16.x          0.16.x              0.16.x
 4-6   repeat for 0.17.x
```

Per step, per repository:

1. [ ] Read the release notes for the target version; list each breaking change that touches `build.zig`, `std.ArrayList`, `std.Io`, and C/Rust linking.
2. [ ] Upgrade on a short-lived jj workspace. Keep the old compiler green on `main` until the new one passes.
3. [ ] Run the full test and spec suite plus `zig build wasm` on Linux and macOS.
4. [ ] Bump `minimum_zig_version` and the CI compiler in the same change.
5. [ ] Downstream repositories bump their Voltaire pin and compiler in one change.

Risk points specific to this stack:

- **`build.zig` size.** Voltaire's is 74 KB and guillotine-mini defines about 30 modules. Build API changes cost the most here.
- **Rust and C linkage.** The crypto archive links `gcc_s` on Linux and vendors c-kzg and blst. Retest after each compiler bump.
- **WASM.** `zig build wasm` produces a WASI reactor with linked crypto. It broke on the last toolchain change (`edafd394`).
- **`hardfork_hooks.zig`.** It uses `std.ArrayList` in its unmanaged 0.15 form (`.empty`, `append(allocator, ...)`) and `@typeInfo(T) == .@"enum"`. Its 37 tests run standalone, so use it as the first compile check after a bump.

Sequence against Glamsterdam: finish the Voltaire pin upgrade (section 3) first, then Amsterdam EVM work, then the Zig upgrade. Do not run a compiler upgrade and a consensus fork in the same window.

## 6. Verification

```sh
zig test src/hardfork_hooks.zig                 # 37 tests, no dependencies
zig test -OReleaseFast src/hardfork_hooks.zig
```

The module was also compiled against the real Voltaire `Hardfork` enum at `ae039ed0` (no `AMSTERDAM` tag) and at `f2b29c2a` (with the tag). Both pass.

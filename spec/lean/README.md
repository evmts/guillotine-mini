# Lean 4 EVM reference specification

An executable Lean 4 specification of the core EVM semantics that
guillotine-mini implements, plus machine-checked theorems about it. The
compiled binary is the reference side of a differential fuzzer: the Zig EVM and
this specification answer the same requests, and any difference is a bug in one
of them.

The specification is written from the Yellow Paper, EELS
(`execution-specs/src/ethereum/forks/*/vm`) and the EIPs, not from the Zig
source.

## Build

```bash
cd spec/lean
lake build                       # about 6 seconds from clean, no dependencies
.lake/build/bin/evm-lean-spec    # TSV oracle on stdin/stdout
```

The toolchain is `leanprover/lean4:v4.36.0`. The project uses only the Lean
standard library (`Std.HashMap`, `Std.HashSet`); it has no Mathlib dependency.

## Modules

| File | Contents |
|---|---|
| `EvmSpec/Word.lean` | 256-bit word opcodes: ADD..SIGNEXTEND, LT..ISZERO, AND..SAR, CLZ, EXP gas |
| `EvmSpec/Gas.lean` | `Fork` order, word-opcode gas, memory expansion, SLOAD and SSTORE gas and refunds, precompile table, EIP-7825 cap |
| `EvmSpec/Bytecode.lean` | JUMPDEST analysis and the zero-padded PUSH immediate reader |
| `EvmSpec/Machine.lean` | Small-step interpreter for one standalone frame |
| `EvmSpec/Theorems.lean` | 60 kernel-checked theorems |
| `EvmSpec/Main.lean` | TSV oracle loop |

## Oracle protocol

One tab-separated request per line, one tab-separated response per line,
flushed after every line. `u256` values are lowercase hex without `0x`; byte
strings are hex with `-` for empty; gas values are decimal.

| Request | Response |
|---|---|
| `WORD <FORK> <OP> <A0> <A1> <A2>` | `OK <RESULT> <GAS>` or `ERR InvalidOpcode` |
| `MEMGAS <CURRENT_SIZE> <END_BYTES>` | `OK <DELTA_GAS>` (`18446744073709551615` on `u64` overflow) |
| `SSTORE <FORK> <ORIGINAL> <CURRENT> <NEW> <IS_COLD> <GAS_REM>` | `OK <GAS> <REFUND_DELTA>` or `ERR OutOfGas` |
| `JUMPDEST <CODE>` | `OK <PC,PC,...>` or `OK -` |
| `PUSH <CODE> <PC> <SIZE>` | `OK <VALUE>` |
| `PRECOMPILE <FORK> <ADDR> <TX_GAS_LIMIT>` | `OK <IS_PRECOMPILE> <TX_GAS_ALLOWED>` |
| `EXEC <FORK> <GAS> <CODE> <CALLDATA>` | `OK <STATUS> <GAS_REM> <REFUND> <OUTPUT>` |
| `QUIT` | exits with code 0 |

`STATUS` is `STOP`, `RETURN`, `REVERT`, `OOG`, `STACK_UNDERFLOW`,
`STACK_OVERFLOW`, `INVALID_JUMP` or `INVALID_OPCODE`.

Two responses extend the protocol:

- `ERR BadRequest` answers a malformed line (unknown command, wrong field
  count, unknown fork, bad number).
- `ERR UnsupportedOpcode <OP_HEX>` answers an `EXEC` that reaches an opcode the
  fork defines but the single-frame model does not execute (KECCAK256,
  environment and block opcodes, LOG, CALL, CREATE, SELFDESTRUCT). The oracle
  refuses instead of reporting a false `INVALID_OPCODE`.

Example:

```text
$ printf 'WORD\tOSAKA\t1e\t1\t0\t0\nEXEC\tOSAKA\t100000\t600260030160005260206000f3\t-\nQUIT\n' \
    | .lake/build/bin/evm-lean-spec
OK	ff	5
OK	RETURN	99976	0	0000000000000000000000000000000000000000000000000000000000000005
```

## Semantic decisions

- **Exception precedence.** Each opcode follows EELS: pop operands, charge gas,
  operate, push. An `ADD` on an empty stack with 0 gas reports
  `STACK_UNDERFLOW`. guillotine-mini charges gas before it pops, so it reports
  `OOG` there. Every exception consumes all gas, so this difference does not
  affect consensus; a fuzzer that compares `STATUS` exactly will report it.
- **Constantinople SSTORE.** `CONSTANTINOPLE` uses the Frontier schedule, as
  EELS and mainnet do. EIP-1283 never ran on mainnet.
- **Memory.** `memoryExpansionCost` is exact on unbounded naturals with no size
  cap. `MEMGAS` answers `memoryExpansionCostU64`, which returns `2^64 - 1` only
  when `end + 31` or `words²` exceeds `u64`.
- **Precompiles.** The table is the canonical one: `0x01..0x04`, `..0x08`
  (Byzantium), `..0x09` (Istanbul), `..0x0a` (Cancun), `..0x11` (Prague),
  plus `0x0100` (Osaka).
- **EXEC start state.** Storage and transient storage are empty, the refund
  counter is 0, and every slot is cold from Berlin on. `REFUND` is the raw
  counter before the EIP-3529 cap, and 0 after `REVERT`.
- **Forks.** The oracle also accepts `DAO`, `MUIR_GLACIER`, `ARROW_GLACIER`
  and `GRAY_GLACIER`.

## Theorems

`EvmSpec/Theorems.lean` has no admitted goals and uses only `propext`,
`Quot.sound` and `Classical.choice`. A selection:

| Theorem | Statement |
|---|---|
| `clz_zero`, `clz_lt_256` | `CLZ(0) = 256`; a nonzero word has fewer than 256 leading zeros |
| `sdiv_min_neg1` | `-2^255 / -1 = -2^255` |
| `sub_self_zero` | `a - a = 0` for every word |
| `memoryCost_monotone` | `a ≤ b → memoryCost a ≤ memoryCost b` |
| `memoryExpansion_additive` | expanding in two steps costs the same as expanding once |
| `scan_ge`, `jumpdest_in_push_invalid` | a `0x5b` inside a `PUSH1` immediate is never a valid jump destination, for any following code |
| `sstore_istanbul_vs_berlin_restore` | restoring an empty slot refunds 19200 (Istanbul) and 19900 (Berlin) |
| `sstore_noop_refund` | a no-op SSTORE never changes the refund counter, on any fork |
| `sstore_sentry` | SSTORE with 2300 gas fails from Istanbul on, for any values |
| `eip7825_boundary` | Osaka accepts `2^24` gas and rejects `2^24 + 1`; Prague accepts both |
| `precompile_monotone` | a precompile stays a precompile in every later fork |

Check the axioms of any theorem:

```bash
echo 'import EvmSpec.Theorems
#print axioms EvmSpec.Theorems.jumpdest_in_push_invalid' | lake env lean --stdin
```

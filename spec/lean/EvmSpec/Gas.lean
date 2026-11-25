import EvmSpec.Word

/-!
# Hardforks and gas rules

Hardfork ordering, opcode gas for the pure word opcodes, memory expansion gas,
the multi-fork SSTORE gas and refund schedule, the precompile address table and
the EIP-7825 transaction gas cap.

Sources: Yellow Paper Appendix G and H, EELS `forks/<fork>/vm/gas.py` and
`vm/instructions/storage.py`, EIP-150, EIP-160, EIP-1884, EIP-2200, EIP-2929,
EIP-3529, EIP-7825, EIP-7939, EIP-7951.

`CONSTANTINOPLE` follows EELS and mainnet: it has no EIP-1283 net gas metering
(Petersburg removed EIP-1283 in the block that activated Constantinople).
-/

namespace EvmSpec

/-- Ethereum execution-layer hardforks in activation order. -/
inductive Fork where
  | FRONTIER | HOMESTEAD | DAO | TANGERINE_WHISTLE | SPURIOUS_DRAGON
  | BYZANTIUM | CONSTANTINOPLE | PETERSBURG | ISTANBUL | MUIR_GLACIER
  | BERLIN | LONDON | ARROW_GLACIER | GRAY_GLACIER | MERGE
  | SHANGHAI | CANCUN | PRAGUE | OSAKA
  deriving DecidableEq, Repr

namespace Fork

/-- Position of a fork in activation order. -/
def toNat : Fork → Nat
  | FRONTIER => 0 | HOMESTEAD => 1 | DAO => 2 | TANGERINE_WHISTLE => 3
  | SPURIOUS_DRAGON => 4 | BYZANTIUM => 5 | CONSTANTINOPLE => 6
  | PETERSBURG => 7 | ISTANBUL => 8 | MUIR_GLACIER => 9 | BERLIN => 10
  | LONDON => 11 | ARROW_GLACIER => 12 | GRAY_GLACIER => 13 | MERGE => 14
  | SHANGHAI => 15 | CANCUN => 16 | PRAGUE => 17 | OSAKA => 18

/-- `f.isAtLeast g` holds when `f` is `g` or a later fork. -/
def isAtLeast (f g : Fork) : Bool := decide (g.toNat ≤ f.toNat)

/-- `f.isBefore g` holds when `f` activates strictly before `g`. -/
def isBefore (f g : Fork) : Bool := !f.isAtLeast g

/-- Parse the UPPERCASE protocol name of a fork. -/
def ofString? : String → Option Fork
  | "FRONTIER" => some FRONTIER | "HOMESTEAD" => some HOMESTEAD
  | "DAO" => some DAO | "TANGERINE_WHISTLE" => some TANGERINE_WHISTLE
  | "SPURIOUS_DRAGON" => some SPURIOUS_DRAGON | "BYZANTIUM" => some BYZANTIUM
  | "CONSTANTINOPLE" => some CONSTANTINOPLE | "PETERSBURG" => some PETERSBURG
  | "ISTANBUL" => some ISTANBUL | "MUIR_GLACIER" => some MUIR_GLACIER
  | "BERLIN" => some BERLIN | "LONDON" => some LONDON
  | "ARROW_GLACIER" => some ARROW_GLACIER | "GRAY_GLACIER" => some GRAY_GLACIER
  | "MERGE" => some MERGE | "SHANGHAI" => some SHANGHAI
  | "CANCUN" => some CANCUN | "PRAGUE" => some PRAGUE | "OSAKA" => some OSAKA
  | _ => none

end Fork

/-! ## Gas constants -/

namespace Gas

def base : Nat := 2
def veryLow : Nat := 3
def low : Nat := 5
def mid : Nat := 8
def high : Nat := 10
def jumpdest : Nat := 1
def memory : Nat := 3
def copy : Nat := 3
def warmAccess : Nat := 100
def coldSload : Nat := 2100
def storageSet : Nat := 20000
def storageUpdate : Nat := 5000
def callStipend : Nat := 2300

end Gas

/-! ## Pure word opcodes -/

/-- Whether `op` is an arithmetic, comparison or bitwise opcode that `fork`
defines. Shifts need Constantinople (EIP-145); CLZ needs Osaka (EIP-7939). -/
def wordOpAvailable (fork : Fork) (op : Nat) : Bool :=
  if 0x01 ≤ op ∧ op ≤ 0x0b then true
  else if 0x10 ≤ op ∧ op ≤ 0x1a then true
  else if 0x1b ≤ op ∧ op ≤ 0x1d then fork.isAtLeast .CONSTANTINOPLE
  else if op = 0x1e then fork.isAtLeast .OSAKA
  else false

/-- Number of stack items a word opcode pops. -/
def wordOpArity (op : Nat) : Nat :=
  if op = 0x08 ∨ op = 0x09 then 3
  else if op = 0x15 ∨ op = 0x19 ∨ op = 0x1e then 1
  else 2

/-- Result of a word opcode. `a` is the top of the stack. -/
def wordOpResult (op : Nat) (a b c : Word) : Word :=
  match op with
  | 0x01 => Word.add a b
  | 0x02 => Word.mul a b
  | 0x03 => Word.sub a b
  | 0x04 => Word.div a b
  | 0x05 => Word.sdiv a b
  | 0x06 => Word.mod a b
  | 0x07 => Word.smod a b
  | 0x08 => Word.addmod a b c
  | 0x09 => Word.mulmod a b c
  | 0x0a => Word.exp a b
  | 0x0b => Word.signextend a b
  | 0x10 => Word.lt a b
  | 0x11 => Word.gt a b
  | 0x12 => Word.slt a b
  | 0x13 => Word.sgt a b
  | 0x14 => Word.eq a b
  | 0x15 => Word.iszero a
  | 0x16 => Word.and a b
  | 0x17 => Word.or a b
  | 0x18 => Word.xor a b
  | 0x19 => Word.not a
  | 0x1a => Word.byte a b
  | 0x1b => Word.shl a b
  | 0x1c => Word.shr a b
  | 0x1d => Word.sar a b
  | 0x1e => Word.clz a
  | _ => 0

/-- Gas of a word opcode. Only EXP is dynamic: its second stack item `b` is the
exponent. -/
def wordOpGas (fork : Fork) (op : Nat) (b : Word) : Nat :=
  match op with
  | 0x02 | 0x04 | 0x05 | 0x06 | 0x07 | 0x0b | 0x1e => Gas.low
  | 0x08 | 0x09 => Gas.mid
  | 0x0a => Word.expGas (fork.isAtLeast .SPURIOUS_DRAGON) b
  | _ => Gas.veryLow

/-- The `WORD` oracle: result and gas of a word opcode, or `none` when the
opcode is invalid on `fork`. -/
def evalWordOp (fork : Fork) (op : Nat) (a b c : Word) : Option (Word × Nat) :=
  if wordOpAvailable fork op then some (wordOpResult op a b c, wordOpGas fork op b)
  else none

/-! ## Memory expansion -/

/-- Number of 32-byte words needed to hold `bytes` bytes. -/
def ceilWords (bytes : Nat) : Nat := (bytes + 31) / 32

/-- Total gas of a memory of `words` words: `3·a + ⌊a² / 512⌋` (YP eq. 326). -/
def memoryCost (words : Nat) : Nat := Gas.memory * words + words * words / 512

/-- Exact gas for growing memory from `currentSize` bytes so it covers
`endBytes` bytes. There is no size cap; the result is an unbounded natural. -/
def memoryExpansionCost (currentSize endBytes : Nat) : Nat :=
  if endBytes ≤ currentSize then 0
  else memoryCost (ceilWords endBytes) - memoryCost (ceilWords currentSize)

/-- Largest `u64`. -/
def u64Max : Nat := 2 ^ 64 - 1

/-- `memoryExpansionCost` for a 64-bit implementation: exact whenever every
intermediate (`end + 31`, `words²`) fits in a `u64`, and `u64Max` otherwise. -/
def memoryExpansionCostU64 (currentSize endBytes : Nat) : Nat :=
  if endBytes ≤ currentSize then 0
  else if endBytes + 31 > u64Max then u64Max
  else if ceilWords endBytes * ceilWords endBytes > u64Max then u64Max
  else memoryExpansionCost currentSize endBytes

/-! ## Storage -/

/-- SLOAD gas: 50 (Frontier), 200 (EIP-150), 800 (EIP-1884), then EIP-2929
warm 100 / cold 2100. `cold` is ignored before Berlin. -/
def sloadGas (fork : Fork) (cold : Bool) : Nat :=
  if fork.isAtLeast .BERLIN then (if cold then Gas.coldSload else Gas.warmAccess)
  else if fork.isAtLeast .ISTANBUL then 800
  else if fork.isAtLeast .TANGERINE_WHISTLE then 200
  else 50

/-- Refund for clearing a slot: 15000, reduced to 4800 by EIP-3529 (London). -/
def storageClearRefund (fork : Fork) : Int :=
  if fork.isAtLeast .LONDON then 4800 else 15000

/-- SSTORE gas for writing `new` to a slot whose value is `current` now and was
`original` at the start of the transaction. `cold` is ignored before Berlin. -/
def sstoreGas (fork : Fork) (original current new : Word) (cold : Bool) : Nat :=
  if fork.isAtLeast .BERLIN then
    -- EIP-2929 on top of EIP-2200.
    (if cold then Gas.coldSload else 0) +
      (if original = current ∧ current ≠ new then
        (if original = 0 then Gas.storageSet else Gas.storageUpdate - Gas.coldSload)
      else Gas.warmAccess)
  else if fork.isAtLeast .ISTANBUL then
    -- EIP-2200 net gas metering with SLOAD_GAS = 800.
    if original = current ∧ current ≠ new then
      (if original = 0 then Gas.storageSet else Gas.storageUpdate)
    else 800
  else
    -- Frontier through Petersburg.
    if current = 0 ∧ new ≠ 0 then Gas.storageSet else Gas.storageUpdate

/-- Signed change of the refund counter made by one SSTORE. -/
def sstoreRefund (fork : Fork) (original current new : Word) : Int :=
  if fork.isAtLeast .ISTANBUL then
    if current = new then 0
    else
      let clear := storageClearRefund fork
      let berlin := fork.isAtLeast .BERLIN
      -- The slot held a value at transaction start and is cleared now.
      (if original ≠ 0 ∧ current ≠ 0 ∧ new = 0 then clear else 0)
      -- An earlier clear in this transaction is undone.
      + (if original ≠ 0 ∧ current = 0 then -clear else 0)
      -- The slot is restored to its value at transaction start.
      + (if original = new then
          (if original = 0 then
            (if berlin then 20000 - 100 else 20000 - 800)
          else
            (if berlin then 5000 - 2100 - 100 else 5000 - 800))
        else 0)
  else
    if current ≠ 0 ∧ new = 0 then 15000 else 0

/-- The `SSTORE` oracle: gas and refund delta, or `none` for out of gas.
From Istanbul on, SSTORE fails when at most the 2300 call stipend remains
(EIP-2200). -/
def sstore (fork : Fork) (original current new : Word) (cold : Bool)
    (gasRemaining : Nat) : Option (Nat × Int) :=
  if fork.isAtLeast .ISTANBUL ∧ gasRemaining ≤ Gas.callStipend then none
  else
    let cost := sstoreGas fork original current new cold
    if gasRemaining < cost then none
    else some (cost, sstoreRefund fork original current new)

/-! ## Precompiles and the transaction gas cap -/

/-- Canonical precompile table: `0x01..0x04` (Frontier), `..0x08` (Byzantium),
`..0x09` (Istanbul), `..0x0a` (Cancun), `..0x11` (Prague), plus `0x0100`
P256VERIFY (Osaka, EIP-7951). -/
def isPrecompile (fork : Fork) (address : Nat) : Bool :=
  let last :=
    if fork.isAtLeast .PRAGUE then 0x11
    else if fork.isAtLeast .CANCUN then 0x0a
    else if fork.isAtLeast .ISTANBUL then 0x09
    else if fork.isAtLeast .BYZANTIUM then 0x08
    else 0x04
  decide (1 ≤ address ∧ address ≤ last)
    || (fork.isAtLeast .OSAKA && address == 0x100)

/-- EIP-7825 per-transaction gas limit cap (`2^24`). -/
def txGasLimitCap : Nat := 16777216

/-- A transaction gas limit is rejected only from Osaka on, when it exceeds
`txGasLimitCap`. -/
def txGasAllowed (fork : Fork) (gasLimit : Nat) : Bool :=
  !(fork.isAtLeast .OSAKA && decide (gasLimit > txGasLimitCap))

end EvmSpec

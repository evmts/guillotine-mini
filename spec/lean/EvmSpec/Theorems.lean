import EvmSpec.Machine

/-!
# Machine-checked properties of the specification

Every theorem here is checked by the Lean kernel, with no admitted goals and
no compiler-trusted evaluation. `#print axioms` reports at most the three
standard axioms `propext`, `Quot.sound` and `Classical.choice`.
-/

namespace EvmSpec.Theorems

open EvmSpec

/-! ## Fork order -/

/-- `isAtLeast` is reflexive and transitive. -/
theorem isAtLeast_refl (f : Fork) : f.isAtLeast f = true := by simp [Fork.isAtLeast]
theorem isAtLeast_trans {f g h : Fork} (h1 : f.isAtLeast g = true) (h2 : g.isAtLeast h = true) :
    f.isAtLeast h = true := by
  simp [Fork.isAtLeast] at *
  omega

/-! ## Word arithmetic -/

/-- EIP-7939: `CLZ(0) = 256`. -/
theorem clz_zero : Word.clz 0 = Word.ofNat 256 := by decide

/-- A nonzero word has fewer than 256 leading zeros. -/
theorem clz_lt_256 (x : Word) (h : x.toNat ≠ 0) : Word.clzNat x < 256 := by
  unfold Word.clzNat
  split <;> omega

/-- `CLZ` never exceeds 256. -/
theorem clz_le_256 (x : Word) : Word.clzNat x ≤ 256 := by
  unfold Word.clzNat
  split <;> omega

/-- `CLZ(1) = 255` and `CLZ(2^255) = 0`. -/
theorem clz_one : Word.clzNat 1 = 255 := by decide
theorem clz_top_bit : Word.clzNat Word.minSigned = 0 := by decide

/-- SDIV overflow: `-2^255 / -1 = -2^255`. -/
theorem sdiv_min_neg1 : Word.sdiv Word.minSigned Word.allOnes = Word.minSigned := by decide

/-- SDIV truncates toward zero: `-7 / 2 = -3`. -/
theorem sdiv_truncates : Word.sdiv (Word.ofInt (-7)) 2 = Word.ofInt (-3) := by decide

/-- SMOD takes the sign of the dividend: `-7 smod 2 = -1`. -/
theorem smod_sign_of_dividend : Word.smod (Word.ofInt (-7)) 2 = Word.ofInt (-1) := by decide

/-- Division and remainder by zero yield zero. -/
theorem div_zero (a : Word) : Word.div a 0 = 0 := by simp [Word.div]
theorem mod_zero (a : Word) : Word.mod a 0 = 0 := by simp [Word.mod]
theorem sdiv_zero (a : Word) : Word.sdiv a 0 = 0 := by simp [Word.sdiv]
theorem smod_zero (a : Word) : Word.smod a 0 = 0 := by simp [Word.smod]
theorem addmod_zero (a b : Word) : Word.addmod a b 0 = 0 := by simp [Word.addmod]
theorem mulmod_zero (a b : Word) : Word.mulmod a b 0 = 0 := by simp [Word.mulmod]

/-- `a - a = 0`. -/
theorem sub_self_zero (a : Word) : Word.sub a a = 0 := by simp [Word.sub]

/-- ADD and MUL commute. -/
theorem add_comm (a b : Word) : Word.add a b = Word.add b a := by
  simp [Word.add, BitVec.add_comm]
theorem mul_comm (a b : Word) : Word.mul a b = Word.mul b a := by
  simp [Word.mul, BitVec.mul_comm]

/-- ADD wraps: `(2^256 - 1) + 1 = 0`. -/
theorem add_wraps : Word.add Word.allOnes 1 = 0 := by decide

/-- NOT is an involution. -/
theorem not_not (a : Word) : Word.not (Word.not a) = a := by simp [Word.not]

/-- XOR with itself is zero. -/
theorem xor_self (a : Word) : Word.xor a a = 0 := by simp [Word.xor]

/-- Shifts by 256 or more clear the word. -/
theorem shl_ge_256 (s v : Word) (h : s.toNat ≥ 256) : Word.shl s v = 0 := by
  simp [Word.shl, h]
theorem shr_ge_256 (s v : Word) (h : s.toNat ≥ 256) : Word.shr s v = 0 := by
  simp [Word.shr, h]

/-- SAR of a negative word by 256 or more is `-1`. -/
theorem sar_negative_saturates :
    Word.sar (Word.ofNat 256) Word.minSigned = Word.allOnes := by decide

/-- SIGNEXTEND of byte 0: `0xff ↦ -1`, `0x7f ↦ 0x7f`. -/
theorem signextend_negative : Word.signextend 0 (Word.ofNat 0xff) = Word.allOnes := by decide
theorem signextend_positive : Word.signextend 0 (Word.ofNat 0x7f) = Word.ofNat 0x7f := by decide

/-- BYTE with an index of 32 or more is zero. -/
theorem byte_out_of_range (i x : Word) (h : i.toNat ≥ 32) : Word.byte i x = 0 := by
  simp [Word.byte, h]

/-- `x^0 = 1` and `2^256 = 0` modulo `2^256`. -/
theorem exp_zero (x : Word) : Word.exp x 0 = 1 := by
  simp [Word.exp, Word.expLoop, Word.ofNat]
theorem exp_two_256 : Word.exp 2 (Word.ofNat 256) = 0 := by decide

/-- EIP-160: EXP with a two-byte exponent costs 30 gas before Spurious Dragon
and 110 gas from Spurious Dragon on. -/
theorem exp_gas_frontier :
    evalWordOp .FRONTIER 0x0a 2 (Word.ofNat 0x100) 0 = some (0, 30) := by decide
theorem exp_gas_spurious :
    evalWordOp .SPURIOUS_DRAGON 0x0a 2 (Word.ofNat 0x100) 0 = some (0, 110) := by decide

/-- Shifts are invalid before Constantinople; CLZ is invalid before Osaka. -/
theorem shl_invalid_before_constantinople (a b c : Word) :
    evalWordOp .BYZANTIUM 0x1b a b c = none := by rfl
theorem clz_invalid_before_osaka (a b c : Word) :
    evalWordOp .PRAGUE 0x1e a b c = none := by rfl
theorem clz_valid_in_osaka (a b c : Word) :
    evalWordOp .OSAKA 0x1e a b c = some (Word.clz a, 5) := by rfl

/-! ## Memory gas -/

/-- The total memory cost grows with the word count. -/
theorem memoryCost_monotone {a b : Nat} (h : a ≤ b) : memoryCost a ≤ memoryCost b := by
  unfold memoryCost
  exact Nat.add_le_add (Nat.mul_le_mul_left _ h)
    (Nat.div_le_div_right (Nat.mul_le_mul h h))

/-- Touching memory that is already active is free. -/
theorem memoryExpansion_no_growth {current stop : Nat} (h : stop ≤ current) :
    memoryExpansionCost current stop = 0 := by
  simp [memoryExpansionCost, h]

/-- Expansion gas is the difference of the total costs, so expanding in two
steps costs the same as expanding once. -/
theorem memoryExpansion_additive {a b c : Nat} (hab : a < b) (hbc : b < c) :
    memoryExpansionCost a b + memoryExpansionCost b c = memoryExpansionCost a c := by
  have h1 : memoryCost (ceilWords a) ≤ memoryCost (ceilWords b) :=
    memoryCost_monotone (by unfold ceilWords; omega)
  have h2 : memoryCost (ceilWords b) ≤ memoryCost (ceilWords c) :=
    memoryCost_monotone (by unfold ceilWords; omega)
  have e1 : ¬ b ≤ a := by omega
  have e2 : ¬ c ≤ b := by omega
  have e3 : ¬ c ≤ a := by omega
  simp only [memoryExpansionCost, e1, e2, e3, ↓reduceIte]
  omega

/-- The first word costs 3 gas; 1 MiB costs 2 195 456 gas. -/
theorem memoryExpansion_first_word : memoryExpansionCost 0 1 = 3 := by decide
theorem memoryExpansion_one_mib : memoryExpansionCost 0 1048576 = 2195456 := by decide

/-- There is no 16 MiB cap: 32 MiB has an exact finite cost. -/
theorem memoryExpansion_32_mib : memoryExpansionCostU64 0 33554432 = 2150629376 := by decide

/-- The 64-bit oracle saturates exactly when `words²` leaves `u64`. -/
theorem memoryExpansion_u64_saturates :
    memoryExpansionCostU64 0 (32 * 2 ^ 32) = u64Max
    ∧ memoryExpansionCostU64 0 (32 * (2 ^ 32 - 1)) < u64Max := by decide

/-! ## Bytecode -/

/-- Every position `scan` reports is at or after its starting position. -/
theorem scan_ge : ∀ (code : List UInt8) (pc skip x : Nat),
    x ∈ Bytecode.scan code pc skip → pc ≤ x
  | [], _, _, _, h => by simp [Bytecode.scan] at h
  | _ :: rest, pc, skip + 1, x, h => by
    simp only [Bytecode.scan] at h
    have := scan_ge rest (pc + 1) skip x h
    omega
  | op :: rest, pc, 0, x, h => by
    simp only [Bytecode.scan] at h
    split at h
    · rcases List.mem_cons.mp h with h | h
      · omega
      · have := scan_ge rest (pc + 1) 0 x h
        omega
    · have := scan_ge rest (pc + 1) _ x h
      omega

/-- A `0x5b` byte that is the immediate of a `PUSH1` is not a valid jump
destination, whatever code follows. -/
theorem jumpdest_in_push_invalid (rest : List UInt8) :
    1 ∉ Bytecode.scan (0x60 :: 0x5b :: rest) 0 0 := by
  intro h
  have h' : 1 ∈ Bytecode.scan rest 2 0 := by
    simpa [Bytecode.scan, Bytecode.immediateSize] using h
  have := scan_ge rest 2 0 1 h'
  omega

/-- Concrete analysis: in `JUMPDEST PUSH1 0x5b JUMPDEST` only 0 and 3 are valid. -/
theorem jumpdest_example :
    Bytecode.validJumpdests #[0x5b, 0x60, 0x5b, 0x5b] = [0, 3] := by decide

/-- A truncated `PUSH32` hides nothing after it, and its data is not code. -/
theorem jumpdest_truncated_push32 : Bytecode.validJumpdests #[0x7f, 0x5b] = [] := by decide

/-- A truncated `PUSH2 0xff` reads `0xff00`: missing bytes are zero on the right. -/
theorem push_truncated_right_pads :
    Bytecode.readPush #[0x61, 0xff] 0 2 = Word.ofNat 0xff00 := by decide

/-- A PUSH past the end of the code reads zero. -/
theorem push_past_end_zero : Bytecode.readPush #[0x60, 0x01] 5 1 = 0 := by decide

/-! ## SSTORE -/

/-- Restoring an originally empty slot refunds `20000 - 800` under EIP-2200
(Istanbul) and `20000 - 100` under EIP-2929 (Berlin). -/
theorem sstore_istanbul_vs_berlin_restore :
    sstore .ISTANBUL 0 1 0 false 100000 = some (800, 19200)
    ∧ sstore .BERLIN 0 1 0 false 100000 = some (100, 19900) := by decide

/-- EIP-3529: London lowers the clear refund from 15000 to 4800. -/
theorem sstore_clear_refund_london :
    sstoreRefund .BERLIN 1 1 0 = 15000 ∧ sstoreRefund .LONDON 1 1 0 = 4800 := by decide

/-- Undoing a clear makes the refund delta negative. -/
theorem sstore_refund_can_be_negative : sstoreRefund .LONDON 1 0 2 = -4800 := by decide

/-- EIP-2200 sentry: from Istanbul on, SSTORE fails with exactly 2300 gas left,
whatever the values. Before Istanbul there is no sentry. -/
theorem sstore_sentry (original current new : Word) (cold : Bool) :
    sstore .ISTANBUL original current new cold 2300 = none := by
  simp [sstore, Fork.isAtLeast, Fork.toNat, Gas.callStipend]
theorem sstore_no_sentry_before_istanbul :
    sstore .PETERSBURG 1 1 2 false 5000 = some (5000, 0) := by decide

/-- A no-op SSTORE never changes the refund counter. -/
theorem sstore_noop_refund (fork : Fork) (original value : Word) :
    sstoreRefund fork original value value = 0 := by
  unfold sstoreRefund
  split <;> simp

/-- Cold SSTORE costs exactly 2100 more than warm SSTORE from Berlin on. -/
theorem sstore_cold_surcharge (original current new : Word) :
    sstoreGas .BERLIN original current new true
      = sstoreGas .BERLIN original current new false + 2100 := by
  unfold sstoreGas
  rw [isAtLeast_refl]
  simp only [↓reduceIte, Bool.false_eq_true]
  show Gas.coldSload + _ = 0 + _ + 2100
  unfold Gas.coldSload
  omega

/-! ## Precompiles and EIP-7825 -/

/-- EIP-7825: Osaka accepts a gas limit of `2^24` and rejects `2^24 + 1`;
Prague accepts both. -/
theorem eip7825_boundary :
    txGasAllowed .OSAKA 16777216 = true
    ∧ txGasAllowed .OSAKA 16777217 = false
    ∧ txGasAllowed .PRAGUE 16777217 = true := by decide

/-- Before Osaka no gas limit is rejected by EIP-7825. -/
theorem eip7825_inactive_before_osaka (limit : Nat) : txGasAllowed .PRAGUE limit = true := by
  simp [txGasAllowed, Fork.isAtLeast, Fork.toNat]

/-- The zero address is never a precompile. -/
theorem zero_not_precompile (fork : Fork) : isPrecompile fork 0 = false := by
  cases fork <;> decide

/-- Precompile table boundaries per fork. -/
theorem precompile_boundaries :
    isPrecompile .FRONTIER 0x04 = true ∧ isPrecompile .FRONTIER 0x05 = false
    ∧ isPrecompile .BYZANTIUM 0x08 = true ∧ isPrecompile .BYZANTIUM 0x09 = false
    ∧ isPrecompile .ISTANBUL 0x09 = true ∧ isPrecompile .ISTANBUL 0x0a = false
    ∧ isPrecompile .CANCUN 0x0a = true ∧ isPrecompile .CANCUN 0x0b = false
    ∧ isPrecompile .PRAGUE 0x11 = true ∧ isPrecompile .PRAGUE 0x12 = false
    ∧ isPrecompile .PRAGUE 0x100 = false ∧ isPrecompile .OSAKA 0x100 = true := by decide

/-- A precompile stays a precompile in every later fork. -/
theorem precompile_monotone (f g : Fork) (address : Nat)
    (hfg : g.isAtLeast f = true) (hp : isPrecompile f address = true) :
    isPrecompile g address = true := by
  cases f <;> cases g <;> simp_all [isPrecompile, Fork.isAtLeast, Fork.toNat] <;> omega

end EvmSpec.Theorems

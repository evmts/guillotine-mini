import EvmSpec.MultiFrame

/-!
# Glamsterdam (Amsterdam) formal specification and consensus invariants

Formalizes the Glamsterdam execution-layer EIPs scheduled in EIP-7773:

- **EIP-8037**: Two-dimensional gas (`regularGas`, `stateGasReservoir`,
  `stateGasSpilled`), reservoir-first state gas charging with regular-gas
  spillover, LIFO refill / spill repayment, child frame full-reservoir
  forwarding, exact revert restoration, and EIP-7825 execution cap vs
  EIP-8037 total gas limit separation.
- **EIP-7708**: System ETH transfer log predicate (`SYSTEM_ADDRESS = 0xff..fe`,
  ERC-20 `Transfer` topic0, exact `none ↔ value = 0 ∨ from = to` condition).
- **EIP-8246**: Non-burning `SELFDESTRUCT` balance preservation (zero ETH burn
  on self-destruct-to-self vs legacy EIP-6780 burn).
- **EIP-8024**: Backward-compatible `DUPN` (`0xe6`), `SWAPN` (`0xe7`), and
  `EXCHANGE` (`0xe8`) immediate encoding/decoding bijections, stack-depth
  safety bounds, and non-collision with `JUMPDEST` (`0x5b`) and `PUSH1..32`
  (`0x60..0x7f`).

Every theorem is checked by the Lean 4 kernel using only standard foundations.
-/

namespace EvmSpec.AmsterdamGas

open EvmSpec
open EvmSpec.MultiFrame

/-! ## EIP-8037 / EIP-8038 gas schedule constants -/

/-- EIP-7825 execution gas limit cap (`2^24 = 16,777,216`). -/
def eip7825Cap : Nat := txGasLimitCap

/-- EIP-8037 `TX_MAX_TOTAL_GAS_LIMIT` (`2^32 - 1`). -/
def amsterdamMaxTotalGasLimit : Nat := 2 ^ 32 - 1

/-- EIP-8037 cost per state byte (`CPSB` draft value). -/
def costPerStateByte : Nat := 1530

/-- EIP-8037 state gas for a new storage slot (`64 * CPSB`). -/
def sstoreStateGas : Nat := 64 * costPerStateByte

/-- EIP-8037 state gas for a new account (`120 * CPSB`). -/
def newAccountStateGas : Nat := 120 * costPerStateByte

/-- EIP-8037 regular gas for `CREATE`/`CREATE2` access (`account_write + cold_account`). -/
def createRegularGas : Nat := 12000

/-- EIP-8037 state gas for `CREATE`/`CREATE2` (`120 * CPSB`). -/
def createStateGas : Nat := 120 * costPerStateByte

/-- EIP-8037 state gas for an EIP-7702 authorization base (`23 * CPSB`). -/
def authBaseStateGas : Nat := 23 * costPerStateByte

/-- EIP-8037 regular + state gas for deploying `codeLen` bytes of bytecode. -/
def codeDepositGas2D (codeLen : Nat) : Nat × Nat :=
  (6 * ceilWords codeLen, costPerStateByte * codeLen)

/-- Draft Amsterdam EIP-8037 state-creation schedule sanity checks. -/
theorem amsterdam_schedule_values :
    eip7825Cap = 16777216
    ∧ sstoreStateGas = 97920
    ∧ newAccountStateGas = 183600
    ∧ authBaseStateGas = 35190 := by decide

/-! ## EIP-8037 two-dimensional gas, spillover, and LIFO refill -/

/-- Two-dimensional gas state of an Amsterdam execution frame.
`stateGasSpilled` tracks state gas drawn from `regularGas` after exhausting
`stateGasReservoir`, enabling exact LIFO repayment on rollback or credit. -/
structure Gas2D where
  regularGas : Nat
  stateGasReservoir : Nat
  stateGasSpilled : Nat := 0
  deriving DecidableEq, Repr

/-- Combined remaining gas budget across both dimensions. -/
def Gas2D.total (g : Gas2D) : Nat := g.regularGas + g.stateGasReservoir

/-- **EIP-8037 Reservoir-Spill Invariant**: A frame only spills into
`regularGas` when `stateGasReservoir` has been exhausted, so at least one of
`stateGasSpilled` and `stateGasReservoir` is always zero. -/
def Gas2D.wellFormed (g : Gas2D) : Prop :=
  g.stateGasSpilled = 0 ∨ g.stateGasReservoir = 0

/-- Whether a transaction gas limit `txGas` is admissible under Amsterdam EIP-8037. -/
def amsterdamTxGasAllowed (txGas : Nat) : Bool :=
  decide (txGas ≤ amsterdamMaxTotalGasLimit)

/-- Initialize an Amsterdam transaction's two-dimensional gas split after
charging `intrinsicGas` against the EIP-7825 execution budget. Gas above
`eip7825Cap` funds `stateGasReservoir` exclusively. -/
def initAmsterdamTxGas (txGas intrinsicGas : Nat) : Option Gas2D :=
  if txGas > amsterdamMaxTotalGasLimit ∨ intrinsicGas > txGas ∨ intrinsicGas > eip7825Cap then
    none
  else
    let evmGas := txGas - intrinsicGas
    let execBudget := eip7825Cap - intrinsicGas
    let regular := min execBudget evmGas
    some {
      regularGas := regular
      stateGasReservoir := evmGas - regular
      stateGasSpilled := 0
    }

/-- Charge regular execution gas (never touches `stateGasReservoir`). -/
def chargeRegularGas (g : Gas2D) (amount : Nat) : Option Gas2D :=
  if g.regularGas < amount then none
  else some { g with regularGas := g.regularGas - amount }

/-- Charge EIP-8037 state creation gas: draw from `stateGasReservoir` first,
spilling any remainder into `regularGas` and recording the spilled amount. -/
def chargeStateGas (g : Gas2D) (amount : Nat) : Option Gas2D :=
  if g.regularGas < amount - min g.stateGasReservoir amount then none
  else some {
    regularGas := g.regularGas - (amount - min g.stateGasReservoir amount)
    stateGasReservoir := g.stateGasReservoir - min g.stateGasReservoir amount
    stateGasSpilled := g.stateGasSpilled + (amount - min g.stateGasReservoir amount)
  }

/-- EIP-8037 LIFO state-gas credit / refill: repay spilled `regularGas` first
(up to `stateGasSpilled`), then place any remaining credit into `stateGasReservoir`. -/
def refundStateGasLifo (g : Gas2D) (credit : Nat) : Gas2D :=
  let toRegular := min g.stateGasSpilled credit
  let toReservoir := credit - toRegular
  { regularGas := g.regularGas + toRegular
    stateGasReservoir := g.stateGasReservoir + toReservoir
    stateGasSpilled := g.stateGasSpilled - toRegular }

/-- Saved parent gas state across a child call boundary. -/
structure ParentGasFrame where
  keptRegular : Nat
  savedReservoir : Nat
  savedSpilled : Nat
  childAllocatedRegular : Nat
  deriving DecidableEq, Repr

/-- Forward gas into a child frame under EIP-8037: `regularGas` follows
EIP-150 63/64 capping while the ENTIRE `stateGasReservoir` passes to the child. -/
def childReservoirForward (parent : Gas2D) (requestedRegular : Nat) :
    ParentGasFrame × Gas2D :=
  let childReg := callChildGas parent.regularGas requestedRegular
  let pf : ParentGasFrame := {
    keptRegular := parent.regularGas - childReg
    savedReservoir := parent.stateGasReservoir
    savedSpilled := parent.stateGasSpilled
    childAllocatedRegular := childReg
  }
  let child : Gas2D := {
    regularGas := childReg
    stateGasReservoir := parent.stateGasReservoir
    stateGasSpilled := 0
  }
  (pf, child)

/-- Merge a committed child's remaining 2D gas back into the parent using
EIP-8037 LIFO refill (returned reservoir repays parent spill first). -/
def childReturnRefill (pf : ParentGasFrame) (childEnd : Gas2D) : Gas2D :=
  let baseParent : Gas2D := {
    regularGas := pf.keptRegular + childEnd.regularGas
    stateGasReservoir := 0
    stateGasSpilled := pf.savedSpilled
  }
  refundStateGasLifo baseParent childEnd.stateGasReservoir

/-- Restore parent gas when a child frame reverts (`exceptional = false`) or
halts exceptionally (`exceptional = true`, consuming all child execution gas).
State gas reservoir is always restored to `pf.savedReservoir`; on graceful
revert any child-spilled regular gas returns to the parent's `regularGas`. -/
def revertRestoreReservoir (pf : ParentGasFrame) (childEnd : Gas2D)
    (exceptional : Bool) : Gas2D :=
  let returnedReg := if exceptional then 0 else childEnd.regularGas + childEnd.stateGasSpilled
  { regularGas := pf.keptRegular + returnedReg
    stateGasReservoir := pf.savedReservoir
    stateGasSpilled := pf.savedSpilled }

/-! ### EIP-7825 execution cap vs EIP-8037 total gas separation theorems -/

/-- Every admitted Amsterdam transaction respects the EIP-7825 `2^24` cap on
its initial `regularGas` execution budget. -/
theorem initAmsterdamTxGas_regular_le_eip7825 {txGas intr : Nat} {g : Gas2D}
    (h : initAmsterdamTxGas txGas intr = some g) :
    g.regularGas ≤ eip7825Cap := by
  unfold initAmsterdamTxGas at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    dsimp only
    omega

/-- Initial two-dimensional total gas equals `txGas - intrinsicGas`. -/
theorem initAmsterdamTxGas_total_eq {txGas intr : Nat} {g : Gas2D}
    (h : initAmsterdamTxGas txGas intr = some g) :
    g.total = txGas - intr := by
  unfold initAmsterdamTxGas at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    simp only [Gas2D.total]
    omega

/-- Every initialized Amsterdam transaction satisfies the reservoir-spill invariant. -/
theorem initAmsterdamTxGas_wellFormed {txGas intr : Nat} {g : Gas2D}
    (h : initAmsterdamTxGas txGas intr = some g) :
    g.wellFormed := by
  unfold initAmsterdamTxGas at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    exact Or.inl rfl

/-- When `txGas ≤ 2^24`, the state gas reservoir starts at zero. -/
theorem initAmsterdamTxGas_reservoir_zero_below_cap {txGas intr : Nat} {g : Gas2D}
    (h : initAmsterdamTxGas txGas intr = some g) (hLe : txGas ≤ eip7825Cap) :
    g.stateGasReservoir = 0 ∧ g.regularGas = txGas - intr := by
  unfold initAmsterdamTxGas at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    dsimp only
    omega

/-- When `2^24 < txGas ≤ TX_MAX_TOTAL_GAS_LIMIT`, `regularGas` caps at
`2^24 - intrinsicGas` and the exact excess `txGas - 2^24` funds the reservoir. -/
theorem initAmsterdamTxGas_reservoir_excess {txGas intr : Nat} {g : Gas2D}
    (h : initAmsterdamTxGas txGas intr = some g) (hGt : eip7825Cap < txGas) :
    g.regularGas = eip7825Cap - intr ∧ g.stateGasReservoir = txGas - eip7825Cap := by
  unfold initAmsterdamTxGas at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    dsimp only
    omega

/-- Transactions above `TX_MAX_TOTAL_GAS_LIMIT` are rejected. -/
theorem initAmsterdamTxGas_rejects_over_max (txGas intr : Nat)
    (h : txGas > amsterdamMaxTotalGasLimit) :
    initAmsterdamTxGas txGas intr = none := by
  simp [initAmsterdamTxGas, h]

/-- Transactions whose intrinsic gas exceeds the EIP-7825 cap are rejected. -/
theorem initAmsterdamTxGas_rejects_intrinsic_over_cap (txGas intr : Nat)
    (h : intr > eip7825Cap) :
    initAmsterdamTxGas txGas intr = none := by
  simp [initAmsterdamTxGas, h]

/-- **EIP-7825 vs EIP-8037 Separation**: Osaka rejects `txGas = 2^24 + 100000`,
while Amsterdam admits it with `regularGas ≤ 2^24` and `total > 2^24`. -/
theorem eip7825_vs_eip8037_separation :
    let txGas := eip7825Cap + 100000
    txGasAllowed .OSAKA txGas = false
    ∧ amsterdamTxGasAllowed txGas = true
    ∧ ∃ g, initAmsterdamTxGas txGas 21000 = some g
        ∧ g.regularGas ≤ eip7825Cap
        ∧ g.total > eip7825Cap := by
  refine ⟨by decide, by decide, ?_⟩
  refine ⟨{ regularGas := eip7825Cap - 21000
            stateGasReservoir := 100000
            stateGasSpilled := 0 }, by decide, by decide, by decide⟩

/-- Universal separation property: for every admitted Amsterdam transaction,
`regularGas ≤ 2^24`, and whenever `txGas > 2^24 + intr`, `g.total > 2^24`. -/
theorem eip7825_vs_eip8037_universal {txGas intr : Nat} {g : Gas2D}
    (h : initAmsterdamTxGas txGas intr = some g) :
    g.regularGas ≤ txGasLimitCap
    ∧ (txGas > txGasLimitCap + intr → g.total > txGasLimitCap) := by
  have hReg := initAmsterdamTxGas_regular_le_eip7825 h
  have hTot := initAmsterdamTxGas_total_eq h
  unfold eip7825Cap at hReg
  refine ⟨hReg, fun hGt => by omega⟩

/-! ### State gas charging, spillover, and conservation theorems -/

/-- Charging regular gas never modifies `stateGasReservoir` or `stateGasSpilled`. -/
theorem chargeRegularGas_preserves_reservoir {g g' : Gas2D} {amount : Nat}
    (h : chargeRegularGas g amount = some g') :
    g'.stateGasReservoir = g.stateGasReservoir
    ∧ g'.stateGasSpilled = g.stateGasSpilled := by
  unfold chargeRegularGas at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    exact ⟨rfl, rfl⟩

/-- Charging regular gas conserves total 2D gas (`g'.total + amount = g.total`). -/
theorem chargeRegularGas_total_conserved {g g' : Gas2D} {amount : Nat}
    (h : chargeRegularGas g amount = some g') :
    g'.total + amount = g.total := by
  unfold chargeRegularGas at h
  split at h
  · cases h
  · rename_i hNotLt
    simp only [Option.some.injEq] at h
    subst h
    simp only [Gas2D.total]
    omega

/-- Charging regular gas preserves `wellFormed`. -/
theorem chargeRegularGas_preserves_wellFormed {g g' : Gas2D} {amount : Nat}
    (hwf : g.wellFormed) (h : chargeRegularGas g amount = some g') :
    g'.wellFormed := by
  have ⟨hr, hs⟩ := chargeRegularGas_preserves_reservoir h
  unfold Gas2D.wellFormed at hwf ⊢
  rw [hr, hs]
  exact hwf

/-- Charging zero state gas is the identity. -/
theorem chargeStateGas_zero (g : Gas2D) : chargeStateGas g 0 = some g := by
  cases g
  simp [chargeStateGas]

/-- **Reservoir + Regular Total Conservation**: every successful `chargeStateGas`
decreases `g.total = regularGas + stateGasReservoir` by the exact charged `amount`. -/
theorem chargeStateGas_total_conserved {g g' : Gas2D} {amount : Nat}
    (h : chargeStateGas g amount = some g') :
    g'.total + amount = g.total := by
  unfold chargeStateGas at h
  split at h
  · cases h
  · rename_i hNotLt
    simp only [Option.some.injEq] at h
    subst h
    simp only [Gas2D.total]
    omega

/-- `chargeStateGas` succeeds if and only if `amount ≤ g.total`. -/
theorem chargeStateGas_succeeds_iff (g : Gas2D) (amount : Nat) :
    (chargeStateGas g amount).isSome = true ↔ amount ≤ g.total := by
  unfold chargeStateGas Gas2D.total
  split <;> rename_i h <;> simp <;> omega

/-- When `amount ≤ stateGasReservoir`, `chargeStateGas` draws exclusively from
the reservoir without touching `regularGas` or `stateGasSpilled`. -/
theorem chargeStateGas_reservoir_first {g g' : Gas2D} {amount : Nat}
    (hLe : amount ≤ g.stateGasReservoir) (h : chargeStateGas g amount = some g') :
    g'.regularGas = g.regularGas
    ∧ g'.stateGasReservoir = g.stateGasReservoir - amount
    ∧ g'.stateGasSpilled = g.stateGasSpilled := by
  unfold chargeStateGas at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    dsimp only
    have hMin : min g.stateGasReservoir amount = amount := Nat.min_eq_right hLe
    have hZero : amount - amount = 0 := Nat.sub_self amount
    rw [hMin, hZero]
    simp

/-- **Spillover Theorem**: when `stateGasReservoir < amount ≤ g.total`,
`chargeStateGas` drains the reservoir to `0`, deducts the exact spillover
`amount - stateGasReservoir` from `regularGas`, and records it in `stateGasSpilled`. -/
theorem chargeStateGas_spillover {g g' : Gas2D} {amount : Nat}
    (hGt : g.stateGasReservoir < amount) (h : chargeStateGas g amount = some g') :
    g'.stateGasReservoir = 0
    ∧ g'.regularGas = g.regularGas - (amount - g.stateGasReservoir)
    ∧ g'.stateGasSpilled = g.stateGasSpilled + (amount - g.stateGasReservoir) := by
  unfold chargeStateGas at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    dsimp only
    have hMin : min g.stateGasReservoir amount = g.stateGasReservoir :=
      Nat.min_eq_left (Nat.le_of_lt hGt)
    rw [hMin]
    refine ⟨Nat.sub_self _, rfl, rfl⟩

/-- `chargeStateGas` preserves the reservoir-spill invariant `wellFormed`. -/
theorem chargeStateGas_preserves_wellFormed {g g' : Gas2D} {amount : Nat}
    (hwf : g.wellFormed) (h : chargeStateGas g amount = some g') :
    g'.wellFormed := by
  by_cases hLe : amount ≤ g.stateGasReservoir
  · have ⟨_, hRes, hSpill⟩ := chargeStateGas_reservoir_first hLe h
    unfold Gas2D.wellFormed at hwf ⊢
    rcases hwf with h0 | h0
    · left; rw [hSpill, h0]
    · right; rw [hRes, h0]; exact Nat.zero_sub _
  · have hGt : g.stateGasReservoir < amount := Nat.lt_of_not_ge hLe
    have ⟨hRes, _, _⟩ := chargeStateGas_spillover hGt h
    exact Or.inr hRes

/-- **Additivity of State Gas Charging**: charging `a` then `b` succeeds and
yields the exact same `Gas2D` (including spillover) as charging `a + b` once. -/
theorem chargeStateGas_additive (g : Gas2D) (a b : Nat) :
    (chargeStateGas g a >>= fun g1 => chargeStateGas g1 b) =
      chargeStateGas g (a + b) := by
  cases g with
  | mk reg res sp =>
    unfold chargeStateGas
    dsimp only [Bind.bind, Option.bind]
    by_cases h1 : reg < a - min res a
    · have hTot : reg < a + b - min res (a + b) := by omega
      simp [h1, hTot]
    · simp only [h1, ↓reduceIte]
      by_cases h2 :
          reg - (a - min res a) < b - min (res - min res a) b
      · have hTot : reg < a + b - min res (a + b) := by omega
        simp [h2, hTot]
      · have hTot : ¬ reg < a + b - min res (a + b) := by omega
        simp only [h2, hTot, ↓reduceIte, Option.some.injEq, Gas2D.mk.injEq]
        omega

/-! ### LIFO refill & exact spill cancellation theorems -/

/-- Refilling zero credit is a no-op. -/
theorem refundStateGasLifo_zero (g : Gas2D) : refundStateGasLifo g 0 = g := by
  cases g
  simp [refundStateGasLifo]

/-- LIFO refill adds exactly `credit` to `total`. -/
theorem refundStateGasLifo_total (g : Gas2D) (credit : Nat) :
    (refundStateGasLifo g credit).total = g.total + credit := by
  unfold refundStateGasLifo Gas2D.total
  dsimp only
  omega

/-- LIFO priority: credits up to `stateGasSpilled` go entirely to `regularGas`
before a single unit enters `stateGasReservoir`. -/
theorem refundStateGasLifo_repays_spill_first (g : Gas2D) (credit : Nat)
    (h : credit ≤ g.stateGasSpilled) :
    let g' := refundStateGasLifo g credit
    g'.regularGas = g.regularGas + credit
    ∧ g'.stateGasReservoir = g.stateGasReservoir
    ∧ g'.stateGasSpilled = g.stateGasSpilled - credit := by
  unfold refundStateGasLifo
  have hMin : min g.stateGasSpilled credit = credit := Nat.min_eq_right h
  simp only [hMin, Nat.sub_self, Nat.add_zero]
  exact ⟨trivial, trivial, trivial⟩

/-- Once `stateGasSpilled` is fully repaid, excess credit fills `stateGasReservoir`. -/
theorem refundStateGasLifo_overflow_to_reservoir (g : Gas2D) (credit : Nat)
    (h : g.stateGasSpilled ≤ credit) :
    let g' := refundStateGasLifo g credit
    g'.regularGas = g.regularGas + g.stateGasSpilled
    ∧ g'.stateGasReservoir = g.stateGasReservoir + (credit - g.stateGasSpilled)
    ∧ g'.stateGasSpilled = 0 := by
  unfold refundStateGasLifo
  have hMin : min g.stateGasSpilled credit = g.stateGasSpilled := Nat.min_eq_left h
  simp only [hMin, Nat.sub_self]
  exact ⟨trivial, trivial, trivial⟩

/-- `refundStateGasLifo` preserves `wellFormed`. -/
theorem refundStateGasLifo_preserves_wellFormed {g : Gas2D} (hwf : g.wellFormed)
    (credit : Nat) :
    (refundStateGasLifo g credit).wellFormed := by
  by_cases h : credit ≤ g.stateGasSpilled
  · have ⟨_, hRes, hSp⟩ := refundStateGasLifo_repays_spill_first g credit h
    unfold Gas2D.wellFormed at hwf ⊢
    rcases hwf with h0 | h0
    · left; rw [hSp, h0]; exact Nat.zero_sub _
    · right; rw [hRes, h0]
  · have hGe : g.stateGasSpilled ≤ credit := Nat.le_of_not_ge h
    have ⟨_, _, hSp⟩ := refundStateGasLifo_overflow_to_reservoir g credit hGe
    exact Or.inl hSp

/-- **Exact LIFO Cancellation Theorem**: Under the EIP-8037 reservoir-spill
invariant `wellFormed`, refunding `amount` via `refundStateGasLifo` immediately
after `chargeStateGas g amount` restores the EXACT original `Gas2D` state
(including both reservoir and spilled regular gas). -/
theorem refundStateGasLifo_cancels_chargeStateGas {g g' : Gas2D} {amount : Nat}
    (hwf : g.wellFormed) (h : chargeStateGas g amount = some g') :
    refundStateGasLifo g' amount = g := by
  cases g with
  | mk reg res sp =>
    unfold chargeStateGas at h
    split at h
    · cases h
    · rename_i hNotLt
      simp only [Option.some.injEq] at h
      subst h
      unfold refundStateGasLifo
      unfold Gas2D.wellFormed at hwf
      simp only [Gas2D.mk.injEq] at hwf ⊢
      dsimp only at hNotLt
      rcases hwf with hSp0 | hRes0 <;> omega

/-! ### Child frame reservoir forwarding, return LIFO refill, and revert restoration -/

/-- Child frame receives 100% of parent's `stateGasReservoir` (not capped by 63/64). -/
theorem childReservoirForward_passes_full_reservoir (parent : Gas2D) (req : Nat) :
    let (pf, child) := childReservoirForward parent req
    child.stateGasReservoir = parent.stateGasReservoir
    ∧ pf.savedReservoir = parent.stateGasReservoir
    ∧ child.stateGasSpilled = 0 :=
  ⟨rfl, rfl, rfl⟩

/-- Child frame starts `wellFormed` (zero child spill). -/
theorem childReservoirForward_child_wellFormed (parent : Gas2D) (req : Nat) :
    (childReservoirForward parent req).2.wellFormed :=
  Or.inl rfl

/-- Forwarding preserves total gas across parent-kept regular gas and child's 2D gas. -/
theorem childReservoirForward_conserves_total (parent : Gas2D) (req : Nat) :
    let (pf, child) := childReservoirForward parent req
    pf.keptRegular + child.total = parent.total := by
  unfold childReservoirForward Gas2D.total
  dsimp only
  have hLe := callChildGas_le_available parent.regularGas req
  omega

/-- Child regular gas obeys EIP-150 63/64 cap while parent keeps at least `regularGas / 64`. -/
theorem childReservoirForward_eip150_cap (parent : Gas2D) (req : Nat) :
    let (pf, child) := childReservoirForward parent req
    child.regularGas ≤ forwardedGas parent.regularGas
    ∧ pf.keptRegular ≥ parent.regularGas / 64 := by
  unfold childReservoirForward
  exact ⟨callChildGas_le_forwarded parent.regularGas req,
    child_oog_retains_parent_64th parent.regularGas req⟩

/-- **Exact Revert Restoration of Reservoir**: on ANY child failure or revert
(graceful `REVERT` or exceptional halt), `stateGasReservoir` and `stateGasSpilled`
are restored identically to the parent's pre-call values. -/
theorem revertRestoreReservoir_exact (parent : Gas2D) (req : Nat)
    (childEnd : Gas2D) (exceptional : Bool) :
    let pf := (childReservoirForward parent req).1
    let restored := revertRestoreReservoir pf childEnd exceptional
    restored.stateGasReservoir = parent.stateGasReservoir
    ∧ restored.stateGasSpilled = parent.stateGasSpilled :=
  ⟨rfl, rfl⟩

/-- `revertRestoreReservoir` always preserves the parent's `wellFormed` invariant. -/
theorem revertRestoreReservoir_preserves_wellFormed (parent : Gas2D) (req : Nat)
    (childEnd : Gas2D) (exceptional : Bool) (hwf : parent.wellFormed) :
    (revertRestoreReservoir (childReservoirForward parent req).1 childEnd exceptional).wellFormed :=
  hwf

/-- **Reverted Child Pays Zero State Gas**: if a child charges `execCost` regular
gas and `stateCost` state gas (whether drawing from reservoir or spilling into
regular gas) and then executes `REVERT`, the parent ends with its exact original
`stateGasReservoir`, exact original `stateGasSpilled`, and `parent.regularGas - execCost`. -/
theorem revertRestoreReservoir_graceful_pays_zero_state_gas
    (parent : Gas2D) (req execCost stateCost : Nat)
    {childMid childEnd : Gas2D}
    (hExec : chargeRegularGas (childReservoirForward parent req).2 execCost = some childMid)
    (hState : chargeStateGas childMid stateCost = some childEnd) :
    let pf := (childReservoirForward parent req).1
    revertRestoreReservoir pf childEnd false =
      { parent with regularGas := parent.regularGas - execCost } := by
  cases parent with
  | mk reg res sp =>
    unfold childReservoirForward at hExec ⊢
    dsimp only at hExec ⊢
    unfold chargeRegularGas at hExec
    split at hExec
    · cases hExec
    · rename_i hNotLt1
      simp only [Option.some.injEq] at hExec
      subst hExec
      unfold chargeStateGas at hState
      dsimp only at hState
      split at hState
      · cases hState
      · rename_i hNotLt2
        simp only [Option.some.injEq] at hState
        subst hState
        unfold revertRestoreReservoir
        have hLe := callChildGas_le_available reg req
        dsimp only at hNotLt1 hNotLt2
        simp only [Bool.false_eq_true, ↓reduceIte, Gas2D.mk.injEq]
        exact ⟨by omega, trivial, trivial⟩

/-- On exceptional child halt (OOG), parent retains at least `parent.regularGas / 64`
regular gas AND its full original `stateGasReservoir`. -/
theorem revertRestoreReservoir_exceptional_retains_64th
    (parent : Gas2D) (req : Nat) (childEnd : Gas2D) :
    let pf := (childReservoirForward parent req).1
    let restored := revertRestoreReservoir pf childEnd true
    restored.regularGas ≥ parent.regularGas / 64
    ∧ restored.stateGasReservoir = parent.stateGasReservoir := by
  unfold childReservoirForward revertRestoreReservoir
  dsimp only
  have hKeep := child_oog_retains_parent_64th parent.regularGas req
  exact ⟨by omega, rfl⟩

/-- `childReturnRefill` always produces a `wellFormed` parent `Gas2D`. -/
theorem childReturnRefill_preserves_wellFormed (pf : ParentGasFrame) (childEnd : Gas2D) :
    (childReturnRefill pf childEnd).wellFormed :=
  refundStateGasLifo_preserves_wellFormed (Or.inr rfl) childEnd.stateGasReservoir

/-- **LIFO Refill Total Conservation**: merging a committed child back into the
parent conserves total 2D gas (`parentAfter.total = pf.keptRegular + childEnd.total`). -/
theorem childReturnRefill_conserves_total (pf : ParentGasFrame) (childEnd : Gas2D) :
    (childReturnRefill pf childEnd).total = pf.keptRegular + childEnd.total := by
  unfold childReturnRefill
  rw [refundStateGasLifo_total]
  simp [Gas2D.total]
  omega

/-- **LIFO Refill Budget Bound**: when a committed child spends `execCost`
regular gas and `stateCost` state gas, returning to the parent strictly conserves
the combined budget (`parentAfter.total + execCost + stateCost = parent.total`),
never exceeds `parent.total`, and when `parent.stateGasSpilled = 0` never inflates
`parent.stateGasReservoir`. -/
theorem childReturnRefill_no_budget_inflation
    (parent : Gas2D) (req execCost stateCost : Nat)
    {childMid childEnd : Gas2D}
    (hExec : chargeRegularGas (childReservoirForward parent req).2 execCost = some childMid)
    (hState : chargeStateGas childMid stateCost = some childEnd) :
    let pf := (childReservoirForward parent req).1
    let parentAfter := childReturnRefill pf childEnd
    parentAfter.total + execCost + stateCost = parent.total
    ∧ parentAfter.total ≤ parent.total
    ∧ (parent.stateGasSpilled = 0 → parentAfter.stateGasReservoir ≤ parent.stateGasReservoir) := by
  have hTot1 := chargeRegularGas_total_conserved hExec
  have hTot2 := chargeStateGas_total_conserved hState
  have hFwd := childReservoirForward_conserves_total parent req
  have hMerge := childReturnRefill_conserves_total (childReservoirForward parent req).1 childEnd
  have hTotalEq : (childReturnRefill (childReservoirForward parent req).1 childEnd).total
      + execCost + stateCost = parent.total := by
    omega
  refine ⟨hTotalEq, by omega, fun hSp0 => ?_⟩
  have hResMid := (chargeRegularGas_preserves_reservoir hExec).1
  unfold childReservoirForward at hResMid ⊢
  dsimp only at hResMid ⊢
  unfold chargeStateGas at hState
  split at hState
  · cases hState
  · simp only [Option.some.injEq] at hState
    subst hState
    unfold childReturnRefill refundStateGasLifo
    simp only [hSp0, Nat.zero_min, Nat.sub_zero, Nat.zero_add]
    omega

/-- **Cross-Frame LIFO Spill Repayment**: when the parent had previously spilled
`pf.savedSpilled > 0` regular gas, returning reservoir `credit` from a committed
child repays `min pf.savedSpilled credit` to parent `regularGas` first before
placing the excess in parent `stateGasReservoir`. -/
theorem childReturnRefill_lifo_repays_parent_spill (pf : ParentGasFrame)
    (childEnd : Gas2D) :
    let after := childReturnRefill pf childEnd
    after.regularGas =
      pf.keptRegular + childEnd.regularGas + min pf.savedSpilled childEnd.stateGasReservoir
    ∧ after.stateGasReservoir =
      childEnd.stateGasReservoir - min pf.savedSpilled childEnd.stateGasReservoir := by
  unfold childReturnRefill refundStateGasLifo
  simp

/-! ## EIP-7708: ETH transfers emit a system log -/

/-- EIP-4788 / EIP-7708 system address (`0xfffffffffffffffffffffffffffffffffffffffe`). -/
def systemAddress : Addr := BitVec.ofNat 160 (2 ^ 160 - 2)

/-- ERC-20 `Transfer(address,address,uint256)` topic0 (`keccak256`). -/
def transferTopic0 : Word :=
  Word.ofNat 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef

/-- Structured EIP-7708 ETH transfer system log (`LOG3`). -/
structure EthTransferLog where
  emitter : Addr
  topic0 : Word
  fromAddr : Addr
  toAddr : Addr
  value : Nat
  deriving DecidableEq, Repr

/-- EIP-7708 transfer log builder: emits a `LOG3` from `systemAddress` iff the
transfer moves nonzero value between two distinct accounts. -/
def ethTransferLog (fromAddr toAddr : Addr) (value : Nat) : Option EthTransferLog :=
  if value = 0 ∨ fromAddr = toAddr then none
  else some {
    emitter := systemAddress
    topic0 := transferTopic0
    fromAddr := fromAddr
    toAddr := toAddr
    value := value
  }

/-- `systemAddress` equals the canonical 20-byte literal `0xff..fe`. -/
theorem systemAddress_eq_hex :
    systemAddress = BitVec.ofNat 160 0xfffffffffffffffffffffffffffffffffffffffe := by decide

/-- **EIP-7708 Exact Silence Predicate**: `ethTransferLog` emits `none` if and
only if `value = 0` or `fromAddr = toAddr`. -/
theorem ethTransferLog_none_iff (fromAddr toAddr : Addr) (value : Nat) :
    ethTransferLog fromAddr toAddr value = none ↔ value = 0 ∨ fromAddr = toAddr := by
  unfold ethTransferLog
  split <;> simp_all

/-- **EIP-7708 Exact Emission Predicate**: `ethTransferLog` emits a log if and
only if `value ≠ 0` and `fromAddr ≠ toAddr`. -/
theorem ethTransferLog_some_iff (fromAddr toAddr : Addr) (value : Nat) :
    (ethTransferLog fromAddr toAddr value).isSome = true ↔ value ≠ 0 ∧ fromAddr ≠ toAddr := by
  unfold ethTransferLog
  split
  · rename_i h
    simp only [Option.isSome_none, Bool.false_eq_true, false_iff]
    exact fun ⟨hv, hne⟩ => h.elim hv hne
  · rename_i h
    simp only [Option.isSome_some, true_iff]
    exact ⟨fun hv => h (Or.inl hv), fun heq => h (Or.inr heq)⟩

/-- Zero-value transfers never emit an EIP-7708 log. -/
theorem ethTransferLog_zero_value (fromAddr toAddr : Addr) :
    ethTransferLog fromAddr toAddr 0 = none := by
  simp [ethTransferLog]

/-- Self-transfers never emit an EIP-7708 log. -/
theorem ethTransferLog_self_transfer (addr : Addr) (value : Nat) :
    ethTransferLog addr addr value = none := by
  simp [ethTransferLog]

/-- Every emitted EIP-7708 transfer log is emitted from `SYSTEM_ADDRESS` (`0xff..fe`). -/
theorem ethTransferLog_emitter_system {fromAddr toAddr : Addr} {value : Nat}
    {log : EthTransferLog} (h : ethTransferLog fromAddr toAddr value = some log) :
    log.emitter = systemAddress := by
  unfold ethTransferLog at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    rfl

/-- Every emitted EIP-7708 transfer log carries the ERC-20 `Transfer` topic0. -/
theorem ethTransferLog_topic0_erc20 {fromAddr toAddr : Addr} {value : Nat}
    {log : EthTransferLog} (h : ethTransferLog fromAddr toAddr value = some log) :
    log.topic0 = transferTopic0 := by
  unfold ethTransferLog at h
  split at h
  · cases h
  · simp only [Option.some.injEq] at h
    subst h
    rfl

/-- Non-zero distinct transfers always emit a `SYSTEM_ADDRESS` log recording the
exact sender, recipient, and wei amount. -/
theorem ethTransferLog_nonzero_distinct {fromAddr toAddr : Addr} {value : Nat}
    (hVal : value ≠ 0) (hNe : fromAddr ≠ toAddr) :
    ethTransferLog fromAddr toAddr value =
      some { emitter := systemAddress, topic0 := transferTopic0,
             fromAddr, toAddr, value } := by
  unfold ethTransferLog
  have hCond : ¬ (value = 0 ∨ fromAddr = toAddr) := fun h => h.elim hVal hNe
  simp [hCond]

/-! ## EIP-8246: Non-burning SELFDESTRUCT balance preservation -/

/-- Amsterdam EIP-8246 `SELFDESTRUCT`: self-targeting preserves balance with zero
burn and emits no log; distinct beneficiary receives the full balance and emits
an EIP-7708 transfer log if the balance is nonzero. -/
def selfdestructAmsterdam (balances : Addr → Nat) (self beneficiary : Addr) :
    (Addr → Nat) × Option EthTransferLog :=
  let bal := balances self
  if self = beneficiary then
    (balances, none)
  else
    (applyBalanceTransfer self beneficiary bal balances,
     ethTransferLog self beneficiary bal)

/-- Pre-Amsterdam (EIP-6780 same-tx created) `SELFDESTRUCT` to self, which
burned the account's balance by zeroing it. -/
def selfdestructLegacySelfBurn (balances : Addr → Nat) (self beneficiary : Addr) :
    Addr → Nat :=
  let bal := balances self
  if self = beneficiary then
    update1 balances self 0
  else
    applyBalanceTransfer self beneficiary bal balances

/-- **EIP-8246 Zero-Burn Self-Target**: `SELFDESTRUCT` to self leaves every
account balance completely unchanged. -/
theorem selfdestructAmsterdam_self_preserves_balances (b : Addr → Nat) (a : Addr) :
    (selfdestructAmsterdam b a a).1 = b := by
  simp [selfdestructAmsterdam]

/-- **EIP-8246 Self-Target Silent**: `SELFDESTRUCT` to self emits no log. -/
theorem selfdestructAmsterdam_self_no_log (b : Addr → Nat) (a : Addr) :
    (selfdestructAmsterdam b a a).2 = none := by
  simp [selfdestructAmsterdam]

/-- `SELFDESTRUCT` to a distinct beneficiary moves the entire balance cleanly. -/
theorem selfdestructAmsterdam_distinct_moves {b : Addr → Nat} {s t : Addr} (hne : s ≠ t) :
    (selfdestructAmsterdam b s t).1 s = 0
    ∧ (selfdestructAmsterdam b s t).1 t = b t + b s := by
  simp only [selfdestructAmsterdam, hne, ↓reduceIte]
  have h := applyBalanceTransfer_distinct hne (b s) b
  exact ⟨by rw [h.1]; exact Nat.sub_self _, h.2⟩

/-- **EIP-8246 Global ETH Supply Preservation**: `SELFDESTRUCT` in Amsterdam
ALWAYS conserves `totalBalance` across `addrs` (zero ETH burn for BOTH
`self = beneficiary` and `self ≠ beneficiary`). -/
theorem selfdestructAmsterdam_conserves_totalBalance {addrs : List Addr}
    {s t : Addr} (hnd : addrs.Nodup) (hs : s ∈ addrs) (ht : t ∈ addrs) (b : Addr → Nat) :
    totalBalance addrs (selfdestructAmsterdam b s t).1 = totalBalance addrs b := by
  unfold selfdestructAmsterdam
  split
  · rfl
  · exact totalBalance_transfer_conserved hnd hs ht (b s) b (Nat.le_refl _)

/-- EIP-8246 + EIP-7708 log predicate: `SELFDESTRUCT` emits a transfer log iff
`self ≠ beneficiary` and `balances self ≠ 0`. -/
theorem selfdestructAmsterdam_log_iff (b : Addr → Nat) (s t : Addr) :
    (selfdestructAmsterdam b s t).2.isSome = true ↔ s ≠ t ∧ b s ≠ 0 := by
  unfold selfdestructAmsterdam
  split
  · rename_i heq
    simp [heq]
  · rename_i hne
    rw [ethTransferLog_some_iff]
    exact ⟨fun ⟨hb, hs⟩ => ⟨hs, hb⟩, fun ⟨hs, hb⟩ => ⟨hb, hs⟩⟩

/-- Contrast with legacy EIP-6780 self-burn: burning a positive balance on
`SELFDESTRUCT(self)` strictly decreases total ETH supply. -/
theorem selfdestructLegacy_self_burns_supply {addrs : List Addr} {a : Addr}
    (hnd : addrs.Nodup) (ha : a ∈ addrs) (b : Addr → Nat) (hPos : b a > 0) :
    totalBalance addrs (selfdestructLegacySelfBurn b a a) < totalBalance addrs b := by
  simp only [selfdestructLegacySelfBurn, ↓reduceIte]
  have h := totalBalance_update1_mem hnd ha 0 b
  omega

/-! ## EIP-8024: Backward-compatible DUPN, SWAPN, and EXCHANGE -/

/-- EIP-8024 opcode byte for `DUPN`. -/
def opDupN : Nat := 0xe6

/-- EIP-8024 opcode byte for `SWAPN`. -/
def opSwapN : Nat := 0xe7

/-- EIP-8024 opcode byte for `EXCHANGE`. -/
def opExchange : Nat := 0xe8

/-- Byte range `0x5b..0x7f` (`JUMPDEST`, `TLOAD..PUSH0`, `PUSH1..PUSH32`) that
EIP-8024 immediates must strictly avoid for legacy JUMPDEST compatibility. -/
def isForbiddenEip8024Byte (x : Nat) : Bool :=
  decide (0x5b ≤ x ∧ x ≤ 0x7f)

/-- Valid immediate byte predicate for `DUPN` and `SWAPN`: `0x00..0x5a` or `0x80..0xff`. -/
def isValidSingleImm (x : Nat) : Bool :=
  decide (x ≤ 90 ∨ (128 ≤ x ∧ x ≤ 255))

/-- EIP-8024 `decode_single(x)`: maps valid immediate bytes bijectively onto
1-indexed stack depths `17..235`. -/
def decodeSingle (x : Nat) : Option Nat :=
  if isValidSingleImm x then some ((x + 145) % 256) else none

/-- EIP-8024 `encode_single(n)`: inverse encoder mapping stack depths `17..235`
back to valid immediate bytes avoiding `0x5b..0x7f`. -/
def encodeSingle (n : Nat) : Option Nat :=
  if 17 ≤ n ∧ n ≤ 235 then some ((n + 111) % 256) else none

/-- Valid immediate byte predicate for `EXCHANGE`: `0x00..0x51` or `0x80..0xff`. -/
def isValidExchangeImm (x : Nat) : Bool :=
  decide (x ≤ 81 ∨ (128 ≤ x ∧ x ≤ 255))

/-- Valid `(n, m)` stack index pair for `EXCHANGE`: `1 ≤ n < m` and `n + m ≤ 30`. -/
def isValidExchangePair (n m : Nat) : Bool :=
  decide (1 ≤ n ∧ n < m ∧ n + m ≤ 30)

/-- EIP-8024 `decode_pair(x)`: maps valid `EXCHANGE` immediate bytes bijectively
onto valid stack-index pairs `(n, m)` with `1 ≤ n < m` and `n + m ≤ 30`. -/
def decodePair (x : Nat) : Option (Nat × Nat) :=
  if isValidExchangeImm x then
    let k := x ^^^ 143
    let q := k / 16
    let r := k % 16
    if q < r then some (q + 1, r + 1)
    else some (r + 1, 29 - q)
  else none

/-- EIP-8024 `encode_pair(n, m)`: inverse encoder for `EXCHANGE` pairs. -/
def encodePair (n m : Nat) : Option Nat :=
  if isValidExchangePair n m then
    let k := if m ≤ 16 then 16 * (n - 1) + (m - 1) else 16 * (29 - m) + (n - 1)
    some (k ^^^ 143)
  else none

/-- Valid `DUPN`/`SWAPN` immediates never collide with `0x5b..0x7f` (`JUMPDEST` or `PUSH1..32`). -/
theorem validSingleImm_avoids_forbidden (x : Nat) (h : isValidSingleImm x = true) :
    ¬ (0x5b ≤ x ∧ x ≤ 0x7f) := by
  simp only [isValidSingleImm, decide_eq_true_eq] at h
  omega

/-- Every byte in `0x5b..0x7f` is rejected by `decodeSingle`. -/
theorem decodeSingle_none_on_forbidden (x : Nat) (h : 0x5b ≤ x ∧ x ≤ 0x7f) :
    decodeSingle x = none := by
  unfold decodeSingle isValidSingleImm
  have hFalse : ¬ (x ≤ 90 ∨ 128 ≤ x ∧ x ≤ 255) := by omega
  simp [hFalse]

/-- Every decoded `DUPN`/`SWAPN` index lies strictly in `[17, 235]`. -/
theorem decodeSingle_bounds {x n : Nat} (h : decodeSingle x = some n) :
    17 ≤ n ∧ n ≤ 235 := by
  unfold decodeSingle isValidSingleImm at h
  split at h
  · rename_i hv
    simp only [decide_eq_true_eq] at hv
    simp only [Option.some.injEq] at h
    omega
  · cases h

/-- `encodeSingle` always outputs a valid byte `< 256` avoiding `0x5b..0x7f`. -/
theorem encodeSingle_valid {n x : Nat} (h : encodeSingle n = some x) :
    isValidSingleImm x = true ∧ x < 256 ∧ ¬ (0x5b ≤ x ∧ x ≤ 0x7f) := by
  unfold encodeSingle at h
  split at h
  · rename_i hRange
    simp only [Option.some.injEq] at h
    unfold isValidSingleImm
    simp only [decide_eq_true_eq]
    omega
  · cases h

/-- **Bijection (Right Inverse) for `DUPN`/`SWAPN`**: `decodeSingle ∘ encodeSingle = id`
on `[17, 235]`. -/
theorem decodeSingle_encodeSingle {n : Nat} (hLo : 17 ≤ n) (hHi : n ≤ 235) :
    (encodeSingle n >>= decodeSingle) = some n := by
  unfold encodeSingle
  have hRange : 17 ≤ n ∧ n ≤ 235 := ⟨hLo, hHi⟩
  simp only [hRange, and_self, ↓reduceIte, Bind.bind, Option.bind]
  unfold decodeSingle isValidSingleImm
  have hValid : (n + 111) % 256 ≤ 90 ∨ 128 ≤ (n + 111) % 256 ∧ (n + 111) % 256 ≤ 255 := by omega
  simp only [hValid, decide_true, ↓reduceIte, Option.some.injEq]
  omega

/-- **Bijection (Left Inverse) for `DUPN`/`SWAPN`**: `encodeSingle ∘ decodeSingle = id`
on every valid immediate byte. -/
theorem encodeSingle_decodeSingle {x : Nat} (h : isValidSingleImm x = true) :
    (decodeSingle x >>= encodeSingle) = some x := by
  unfold decodeSingle
  simp only [h, ↓reduceIte, Bind.bind, Option.bind]
  simp only [isValidSingleImm, decide_eq_true_eq] at h
  unfold encodeSingle
  have hRange : 17 ≤ (x + 145) % 256 ∧ (x + 145) % 256 ≤ 235 := by omega
  simp only [hRange, and_self, ↓reduceIte, Option.some.injEq]
  omega

/-- `decodeSingle` is injective across all natural numbers. -/
theorem decodeSingle_injective {x y n : Nat}
    (hx : decodeSingle x = some n) (hy : decodeSingle y = some n) :
    x = y := by
  have hValidX : isValidSingleImm x = true := by
    unfold decodeSingle at hx
    split at hx <;> simp_all
  have hValidY : isValidSingleImm y = true := by
    unfold decodeSingle at hy
    split at hy <;> simp_all
  have h1 := encodeSingle_decodeSingle hValidX
  have h2 := encodeSingle_decodeSingle hValidY
  rw [hx] at h1
  rw [hy] at h2
  have hEq : some x = some y := h1.symm.trans h2
  exact Option.some.inj hEq

/-- Count bytes in `[0, 256)` satisfying `p` via a 16×16 grid (depth 16). -/
def countBytes256 (p : Nat → Bool) : Nat :=
  (List.range 16).foldl (fun acc hi =>
    acc + (List.range 16).foldl (fun acc2 lo =>
      acc2 + if p (16 * hi + lo) then 1 else 0) 0) 0

/-- Exact cardinality: there are precisely 219 valid `DUPN`/`SWAPN` immediates. -/
theorem decodeSingle_count : countBytes256 isValidSingleImm = 219 := by decide

/-- Every decoded `DUPN`/`SWAPN` index requires stack depth well within 1024. -/
theorem decodeSingle_stack_depth_safe {x n : Nat} (h : decodeSingle x = some n) :
    n + 1 ≤ stackLimit := by
  have ⟨_, hHi⟩ := decodeSingle_bounds h
  unfold stackLimit
  omega

/-- Boundary vectors for `decodeSingle`. -/
theorem decodeSingle_edges :
    decodeSingle 0x80 = some 17
    ∧ decodeSingle 0xff = some 144
    ∧ decodeSingle 0x00 = some 145
    ∧ decodeSingle 0x5a = some 235
    ∧ decodeSingle 0x5b = none
    ∧ decodeSingle 0x7f = none := by decide

/-- Valid `EXCHANGE` immediates never collide with `0x5b..0x7f`. -/
theorem validExchangeImm_avoids_forbidden (x : Nat) (h : isValidExchangeImm x = true) :
    ¬ (0x5b ≤ x ∧ x ≤ 0x7f) := by
  simp only [isValidExchangeImm, decide_eq_true_eq] at h
  omega

/-- Every valid `EXCHANGE` immediate is also a valid `DUPN`/`SWAPN` immediate. -/
theorem validExchangeImm_implies_validSingleImm (x : Nat) (h : isValidExchangeImm x = true) :
    isValidSingleImm x = true := by
  simp only [isValidExchangeImm, isValidSingleImm, decide_eq_true_eq] at h ⊢
  omega

/-- Every byte in `0x52..0x7f` (including all `0x5b..0x7f`) is rejected by `decodePair`. -/
theorem decodePair_none_on_forbidden (x : Nat) (h : 82 ≤ x ∧ x ≤ 127) :
    decodePair x = none := by
  unfold decodePair isValidExchangeImm
  have hFalse : ¬ (x ≤ 81 ∨ 128 ≤ x ∧ x ≤ 255) := by omega
  simp [hFalse]

/-- Boolean check of `decodePair` bounds and left-inverse property at byte `x`. -/
def checkDecodePair (x : Nat) : Bool :=
  !isValidExchangeImm x ||
    match decodePair x with
    | some (n, m) => isValidExchangePair n m && (encodePair n m == some x)
    | none => false

/-- Boolean check of `encodePair` validity and right-inverse property at `(n, m)`. -/
def checkEncodePair (n m : Nat) : Bool :=
  !isValidExchangePair n m ||
    match encodePair n m with
    | some x => isValidExchangeImm x && decide (x < 256) && (decodePair x == some (n, m))
    | none => false

/-- Kernel-checked finite verification over all 256 bytes (`16 × 16`) for `decodePair`. -/
theorem decodePair_grid256_ok :
    ∀ hi : Fin 16, ∀ lo : Fin 16, checkDecodePair (16 * hi.val + lo.val) = true := by
  decide

/-- Kernel-checked finite verification over all valid `(n, m)` pairs for `encodePair`. -/
theorem encodePair_grid30_ok :
    ∀ n : Fin 15, ∀ m : Fin 30, checkEncodePair n.val m.val = true := by
  decide

/-- Every decoded `EXCHANGE` pair satisfies `1 ≤ n < m` and `n + m ≤ 30`. -/
theorem decodePair_bounds {x n m : Nat} (h : decodePair x = some (n, m)) :
    1 ≤ n ∧ n < m ∧ n + m ≤ 30 := by
  have hValid : isValidExchangeImm x = true := by
    unfold decodePair at h
    split at h <;> simp_all
  have hLt : x < 256 := by
    simp only [isValidExchangeImm, decide_eq_true_eq] at hValid
    omega
  have hChk := decodePair_grid256_ok ⟨x / 16, by omega⟩ ⟨x % 16, by omega⟩
  have hEqX : 16 * (x / 16) + x % 16 = x := by omega
  rw [hEqX] at hChk
  unfold checkDecodePair at hChk
  rw [hValid, h] at hChk
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true] at hChk
  simpa [isValidExchangePair] using hChk.1

/-- `EXCHANGE` requires at most 30 stack items (`m + 1 ≤ 30`), strictly within 1024. -/
theorem decodePair_stack_depth_safe {x n m : Nat} (h : decodePair x = some (n, m)) :
    m + 1 ≤ 30 ∧ m + 1 ≤ stackLimit := by
  have ⟨h1, _, hSum⟩ := decodePair_bounds h
  unfold stackLimit
  omega

/-- `encodePair` always produces a valid byte `< 256` avoiding `0x5b..0x7f`. -/
theorem encodePair_valid {n m x : Nat} (h : encodePair n m = some x) :
    isValidExchangeImm x = true ∧ x < 256 ∧ ¬ (0x5b ≤ x ∧ x ≤ 0x7f) := by
  have hValid : isValidExchangePair n m = true := by
    unfold encodePair at h
    split at h <;> simp_all
  have hBounds : 1 ≤ n ∧ n < m ∧ n + m ≤ 30 := by
    simpa [isValidExchangePair] using hValid
  have hChk := encodePair_grid30_ok ⟨n, by omega⟩ ⟨m, by omega⟩
  unfold checkEncodePair at hChk
  rw [hValid, h] at hChk
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true, decide_eq_true_eq] at hChk
  exact ⟨hChk.1.1, hChk.1.2, validExchangeImm_avoids_forbidden x hChk.1.1⟩

/-- **Bijection (Right Inverse) for `EXCHANGE`**: `decodePair ∘ encodePair = id`
on every valid `(n, m)` pair with `1 ≤ n < m ∧ n + m ≤ 30`. -/
theorem decodePair_encodePair {n m : Nat} (h : isValidExchangePair n m = true) :
    (encodePair n m >>= decodePair) = some (n, m) := by
  have hBounds : 1 ≤ n ∧ n < m ∧ n + m ≤ 30 := by
    simpa [isValidExchangePair] using h
  have hChk := encodePair_grid30_ok ⟨n, by omega⟩ ⟨m, by omega⟩
  unfold checkEncodePair at hChk
  rw [h] at hChk
  cases hEnc : encodePair n m with
  | none =>
    rw [hEnc] at hChk
    simp at hChk
  | some x =>
    rw [hEnc] at hChk
    simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true, beq_iff_eq] at hChk
    simp [Bind.bind, Option.bind, hChk.2]

/-- **Bijection (Left Inverse) for `EXCHANGE`**: `encodePair ∘ decodePair = id`
on every valid `EXCHANGE` immediate byte. -/
theorem encodePair_decodePair {x : Nat} (h : isValidExchangeImm x = true) :
    (decodePair x >>= fun p => encodePair p.1 p.2) = some x := by
  have hLt : x < 256 := by
    simp only [isValidExchangeImm, decide_eq_true_eq] at h
    omega
  have hChk := decodePair_grid256_ok ⟨x / 16, by omega⟩ ⟨x % 16, by omega⟩
  have hEqX : 16 * (x / 16) + x % 16 = x := by omega
  rw [hEqX] at hChk
  unfold checkDecodePair at hChk
  rw [h] at hChk
  cases hDec : decodePair x with
  | none =>
    rw [hDec] at hChk
    simp at hChk
  | some p =>
    rw [hDec] at hChk
    simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true, beq_iff_eq] at hChk
    simp [Bind.bind, Option.bind, hChk.2]

/-- `decodePair` is injective across all natural numbers. -/
theorem decodePair_injective {x y : Nat} {p : Nat × Nat}
    (hx : decodePair x = some p) (hy : decodePair y = some p) :
    x = y := by
  have hValidX : isValidExchangeImm x = true := by
    unfold decodePair at hx
    split at hx <;> simp_all
  have hValidY : isValidExchangeImm y = true := by
    unfold decodePair at hy
    split at hy <;> simp_all
  have h1 := encodePair_decodePair hValidX
  have h2 := encodePair_decodePair hValidY
  rw [hx] at h1
  rw [hy] at h2
  have hEq : some x = some y := h1.symm.trans h2
  exact Option.some.inj hEq

/-- Exact cardinality: there are precisely 210 valid `EXCHANGE` immediates. -/
theorem decodePair_count : countBytes256 isValidExchangeImm = 210 := by decide

/-- Official EIP-8024 `EXCHANGE` test vectors from EEST `tests@v21.0.3`. -/
theorem decodePair_vectors :
    decodePair 0x8e = some (1, 2)
    ∧ decodePair 0x50 = some (14, 16)
    ∧ decodePair 0x51 = some (14, 15)
    ∧ decodePair 0x52 = none
    ∧ decodePair 0x5b = none
    ∧ decodePair 0x7f = none := by decide

/-- **EIP-8024 Legacy JUMPDEST & PUSH Compatibility Theorem**: every valid
`DUPN`, `SWAPN`, or `EXCHANGE` immediate byte is neither `JUMPDEST` (`0x5b`)
nor any `PUSH1..PUSH32` (`Bytecode.immediateSize = 0`). -/
theorem eip8024_jumpdest_and_push_compat (x : Nat)
    (h : isValidSingleImm x = true ∨ isValidExchangeImm x = true) :
    x ≠ 0x5b ∧ Bytecode.immediateSize (UInt8.ofNat x) = 0 := by
  have hSingle : isValidSingleImm x = true :=
    h.elim id (validExchangeImm_implies_validSingleImm x)
  have hAvoid := validSingleImm_avoids_forbidden x hSingle
  have hLt : x < 256 := by
    simp only [isValidSingleImm, decide_eq_true_eq] at hSingle
    omega
  refine ⟨by omega, ?_⟩
  unfold Bytecode.immediateSize
  have hToNat : (UInt8.ofNat x).toNat = x := by
    simp [Nat.mod_eq_of_lt hLt]
  rw [hToNat]
  have hNotPush : ¬ (0x60 ≤ x ∧ x ≤ 0x7f) := by omega
  simp [hNotPush]

end EvmSpec.AmsterdamGas

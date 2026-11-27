import EvmSpec.Machine

/-!
# Multi-frame EVM call-tree semantics and consensus invariants

Formalizes the multi-frame EVM execution model across call boundaries
(`CALL`, `STATICCALL`, `DELEGATECALL`, `CREATE`):

- `WorldState`: persistent storage, transient storage (EIP-1153), balances,
  nonces, contract code, warm addresses and warm storage slots (EIP-2929),
  emitted logs, refund counter, call depth, and static execution flag.
- Undo-journal checkpoint and rollback (`checkpoint`, `rollbackTo`): every
  state mutation pushes an exact inverse entry onto the journal, mirroring the
  guillotine-mini snapshot/rollback engine.
- EIP-150 63/64 gas forwarding (`forwardedGas`, `callChildGas`) and gas
  conservation across parent/child boundaries (with and without call stipend).
- `STATICCALL` downward monotonicity and full call-tree static immutability.
- Call-stack depth limit (`maxCallDepth = 1024`).
- Total ETH balance conservation across valid transfers, commits, and reverts.

Every theorem is checked by the Lean 4 kernel using only standard foundations.
-/

namespace EvmSpec.MultiFrame

open EvmSpec

/-! ## Addresses, logs, and world state -/

/-- A 20-byte Ethereum account address. -/
abbrev Addr := BitVec 160

/-- Maximum nested call depth permitted by the EVM (Yellow Paper §9.4.2). -/
def maxCallDepth : Nat := 1024

/-- An emitted EVM log record. -/
structure LogEntry where
  address : Addr
  topics : List Word
  data : Array UInt8
  deriving DecidableEq, Repr

/-- Multi-frame EVM world and execution-context state.
`logs` stores emitted logs newest-first so push/pop rollback is O(1);
observable log order is `logs.reverse`. -/
structure WorldState where
  storage : Addr → Word → Word := fun _ _ => 0
  transient : Addr → Word → Word := fun _ _ => 0
  balances : Addr → Nat := fun _ => 0
  nonces : Addr → Nat := fun _ => 0
  code : Addr → Code := fun _ => #[]
  warmAddresses : Addr → Bool := fun _ => false
  warmSlots : Addr → Word → Bool := fun _ _ => false
  logs : List LogEntry := []
  refund : Int := 0
  depth : Nat := 0
  isStatic : Bool := false

/-- Observable logs in emission order. -/
def WorldState.visibleLogs (w : WorldState) : List LogEntry := w.logs.reverse

/-- Functional map update for single-key maps. -/
def update1 {α β : Type} [DecidableEq α] (f : α → β) (k : α) (v : β) : α → β :=
  fun x => if x = k then v else f x

/-- Functional map update for two-key maps. -/
def update2 {α β γ : Type} [DecidableEq α] [DecidableEq β]
    (f : α → β → γ) (k1 : α) (k2 : β) (v : γ) : α → β → γ :=
  fun x y => if x = k1 ∧ y = k2 then v else f x y

@[simp] theorem update1_self {α β : Type} [DecidableEq α] (f : α → β) (k : α) :
    update1 f k (f k) = f := by
  funext x
  unfold update1
  split <;> simp_all

@[simp] theorem update1_overwrite {α β : Type} [DecidableEq α] (f : α → β) (k : α) (v₁ v₂ : β) :
    update1 (update1 f k v₁) k v₂ = update1 f k v₂ := by
  funext x
  unfold update1
  split <;> rfl

@[simp] theorem update2_self {α β γ : Type} [DecidableEq α] [DecidableEq β]
    (f : α → β → γ) (k1 : α) (k2 : β) :
    update2 f k1 k2 (f k1 k2) = f := by
  funext x y
  unfold update2
  split <;> simp_all

@[simp] theorem update2_overwrite {α β γ : Type} [DecidableEq α] [DecidableEq β]
    (f : α → β → γ) (k1 : α) (k2 : β) (v₁ v₂ : γ) :
    update2 (update2 f k1 k2 v₁) k1 k2 v₂ = update2 f k1 k2 v₂ := by
  funext x y
  unfold update2
  split <;> rfl

/-! ## EIP-150 63/64 gas forwarding and conservation -/

/-- EIP-150 63/64 rule: maximum gas a caller may forward out of `gas` available. -/
def forwardedGas (gas : Nat) : Nat := gas - gas / 64

/-- Gas retained by the caller before any child return when forwarding the
full EIP-150 cap. -/
def parentKeptGas (gas : Nat) : Nat := gas - forwardedGas gas

/-- Gas forwarded to a `CALL`/`STATICCALL`/`DELEGATECALL` child given caller's
`available` gas and `requested` gas operand. -/
def callChildGas (available requested : Nat) : Nat :=
  min requested (forwardedGas available)

/-- Zero available gas forwards zero gas. -/
theorem forwardedGas_zero : forwardedGas 0 = 0 := by decide

/-- EIP-150 never forwards more gas than is available. -/
theorem forwardedGas_le (gas : Nat) : forwardedGas gas ≤ gas := by
  unfold forwardedGas
  omega

/-- Caller retains exactly `⌊gas / 64⌋` when forwarding the EIP-150 maximum. -/
theorem parentKept_eq_div64 (gas : Nat) : gas - forwardedGas gas = gas / 64 := by
  unfold forwardedGas
  omega

/-- EIP-150 1/64 retention guarantee: caller keeps at least `gas / 64`. -/
theorem parentKept_ge_div64 (gas : Nat) : gas - forwardedGas gas ≥ gas / 64 := by
  unfold forwardedGas
  omega

/-- Below 64 gas, `⌊gas / 64⌋ = 0` so all gas may be forwarded. -/
theorem forwardedGas_lt_64 {gas : Nat} (h : gas < 64) : forwardedGas gas = gas := by
  unfold forwardedGas
  omega

/-- At 64 gas or more, EIP-150 strictly withholds at least 1 unit of gas. -/
theorem forwardedGas_strictly_lt {gas : Nat} (h : 64 ≤ gas) : forwardedGas gas < gas := by
  unfold forwardedGas
  omega

/-- `forwardedGas` is monotone in available gas. -/
theorem forwardedGas_monotone {a b : Nat} (h : a ≤ b) :
    forwardedGas a ≤ forwardedGas b := by
  unfold forwardedGas
  omega

/-- `forwardedGas` is subadditive: splitting gas across two calls never
forwards less combined gas than forwarding from the sum. -/
theorem forwardedGas_subadditive (a b : Nat) :
    forwardedGas (a + b) ≤ forwardedGas a + forwardedGas b := by
  unfold forwardedGas
  omega

/-- `callChildGas` never exceeds the EIP-150 63/64 cap. -/
theorem callChildGas_le_forwarded (available requested : Nat) :
    callChildGas available requested ≤ forwardedGas available :=
  Nat.min_le_right _ _

/-- `callChildGas` never exceeds the caller's requested gas. -/
theorem callChildGas_le_requested (available requested : Nat) :
    callChildGas available requested ≤ requested :=
  Nat.min_le_left _ _

/-- `callChildGas` never exceeds available gas. -/
theorem callChildGas_le_available (available requested : Nat) :
    callChildGas available requested ≤ available :=
  Nat.le_trans (callChildGas_le_forwarded available requested) (forwardedGas_le available)

/-- `callChildGas` is monotone in both available and requested gas. -/
theorem callChildGas_monotone {a₁ a₂ r₁ r₂ : Nat} (ha : a₁ ≤ a₂) (hr : r₁ ≤ r₂) :
    callChildGas a₁ r₁ ≤ callChildGas a₂ r₂ := by
  unfold callChildGas
  have hf := forwardedGas_monotone ha
  omega

/-- Total gas conservation across a child call without stipend:
`parentKept + childUsed + childReturned = available`. -/
theorem gas_conserved_no_stipend (available requested childUsed : Nat)
    (hUsed : childUsed ≤ callChildGas available requested) :
    let sent := callChildGas available requested
    let parentKept := available - sent
    let childReturned := sent - childUsed
    parentKept + childUsed + childReturned = available := by
  have hSent : callChildGas available requested ≤ available :=
    callChildGas_le_available available requested
  omega

/-- Total gas conservation across a value-bearing `CALL` with EIP-150 stipend:
`parentKept + childUsed + childReturned = available + stipend`. -/
theorem gas_conserved_with_stipend (available requested stipend childUsed : Nat)
    (hUsed : childUsed ≤ callChildGas available requested + stipend) :
    let sent := callChildGas available requested
    let parentKept := available - sent
    let childReturned := sent + stipend - childUsed
    parentKept + childUsed + childReturned = available + stipend := by
  have hSent : callChildGas available requested ≤ available :=
    callChildGas_le_available available requested
  omega

/-- Even when a child frame halts exceptionally (consuming all forwarded gas),
the parent retains at least `available / 64` gas. -/
theorem child_oog_retains_parent_64th (available requested : Nat) :
    available - callChildGas available requested ≥ available / 64 := by
  have h1 := callChildGas_le_forwarded available requested
  have h2 := parentKept_ge_div64 available
  omega

/-! ## Value transfer and total balance conservation -/

/-- Sum of balances over an account list `addrs`. -/
def totalBalance (addrs : List Addr) (balances : Addr → Nat) : Nat :=
  match addrs with
  | [] => 0
  | a :: rest => balances a + totalBalance rest balances

/-- Pure balance transfer from `src` to `dst` of `value` wei. -/
def applyBalanceTransfer (src dst : Addr) (value : Nat) (balances : Addr → Nat) :
    Addr → Nat :=
  let b1 := update1 balances src (balances src - value)
  update1 b1 dst (b1 dst + value)

/-- Self-transfer with sufficient balance is the identity on balances. -/
theorem applyBalanceTransfer_self (a : Addr) (value : Nat) (b : Addr → Nat)
    (h : value ≤ b a) :
    applyBalanceTransfer a a value b = b := by
  funext x
  unfold applyBalanceTransfer update1
  by_cases hx : x = a
  · subst hx
    simp only [↓reduceIte]
    omega
  · simp [hx]

/-- Transfer between distinct accounts decreases `src` by `value` and increases
`dst` by `value`. -/
theorem applyBalanceTransfer_distinct {src dst : Addr} (hne : src ≠ dst)
    (value : Nat) (b : Addr → Nat) :
    applyBalanceTransfer src dst value b src = b src - value
    ∧ applyBalanceTransfer src dst value b dst = b dst + value := by
  have hne' : dst ≠ src := Ne.symm hne
  unfold applyBalanceTransfer update1
  simp [hne, hne']

/-- Transfer leaves every third-party account balance unchanged. -/
theorem applyBalanceTransfer_other {src dst other : Addr}
    (hs : other ≠ src) (hd : other ≠ dst) (value : Nat) (b : Addr → Nat) :
    applyBalanceTransfer src dst value b other = b other := by
  unfold applyBalanceTransfer update1
  simp [hs, hd]

/-- Updating a single address not in `addrs` does not change `totalBalance`. -/
theorem totalBalance_update1_not_mem {addrs : List Addr} {a : Addr}
    (hnot : a ∉ addrs) (v : Nat) (b : Addr → Nat) :
    totalBalance addrs (update1 b a v) = totalBalance addrs b := by
  induction addrs with
  | nil => rfl
  | cons hd tl ih =>
    have hne : hd ≠ a := fun h => hnot (by simp [h])
    have htl : a ∉ tl := fun h => hnot (by simp [h])
    simp only [totalBalance, update1, hne, ↓reduceIte]
    rw [ih htl]

/-- Updating a single address in a duplicate-free list adjusts `totalBalance`
by the exact delta at that address. -/
theorem totalBalance_update1_mem {addrs : List Addr} {a : Addr}
    (hnd : addrs.Nodup) (hmem : a ∈ addrs) (v : Nat) (b : Addr → Nat) :
    totalBalance addrs (update1 b a v) + b a = totalBalance addrs b + v := by
  induction addrs with
  | nil => cases hmem
  | cons hd tl ih =>
    rw [List.nodup_cons] at hnd
    rcases hnd with ⟨hHdNotTl, hTlNodup⟩
    rcases List.mem_cons.mp hmem with rfl | hInTl
    · simp only [totalBalance, update1, ↓reduceIte]
      rw [totalBalance_update1_not_mem hHdNotTl]
      omega
    · have hne : hd ≠ a := fun h => hHdNotTl (h ▸ hInTl)
      simp only [totalBalance, update1, hne, ↓reduceIte]
      have hRec := ih hTlNodup hInTl
      omega

/-- Total ETH supply is strictly conserved by every valid value transfer
whose endpoints lie in `addrs`. -/
theorem totalBalance_transfer_conserved {addrs : List Addr} {src dst : Addr}
    (hnd : addrs.Nodup) (hSrc : src ∈ addrs) (hDst : dst ∈ addrs)
    (value : Nat) (b : Addr → Nat) (hBal : value ≤ b src) :
    totalBalance addrs (applyBalanceTransfer src dst value b) = totalBalance addrs b := by
  unfold applyBalanceTransfer
  let b1 := update1 b src (b src - value)
  have h1 : totalBalance addrs b1 + b src = totalBalance addrs b + (b src - value) :=
    totalBalance_update1_mem hnd hSrc (b src - value) b
  have h2 : totalBalance addrs (update1 b1 dst (b1 dst + value)) + b1 dst
      = totalBalance addrs b1 + (b1 dst + value) :=
    totalBalance_update1_mem hnd hDst (b1 dst + value) b1
  change totalBalance addrs (update1 b1 dst (b1 dst + value)) = totalBalance addrs b
  omega

/-! ## Undo journal, checkpoints, and rollback soundness -/

/-- Atomic undo record pushed onto the rollback journal whenever state mutates. -/
inductive JournalEntry where
  | storage (addr : Addr) (slot : Word) (prev : Word)
  | transient (addr : Addr) (slot : Word) (prev : Word)
  | balance (addr : Addr) (prev : Nat)
  | nonce (addr : Addr) (prev : Nat)
  | code (addr : Addr) (prev : Code)
  | warmAddr (addr : Addr) (prev : Bool)
  | warmSlot (addr : Addr) (slot : Word) (prev : Bool)
  | logPop
  | refund (prev : Int)

/-- Revert a single undo record on `w`. -/
def undoEntry (w : WorldState) : JournalEntry → WorldState
  | .storage a s prev => { w with storage := update2 w.storage a s prev }
  | .transient a s prev => { w with transient := update2 w.transient a s prev }
  | .balance a prev => { w with balances := update1 w.balances a prev }
  | .nonce a prev => { w with nonces := update1 w.nonces a prev }
  | .code a prev => { w with code := update1 w.code a prev }
  | .warmAddr a prev => { w with warmAddresses := update1 w.warmAddresses a prev }
  | .warmSlot a s prev => { w with warmSlots := update2 w.warmSlots a s prev }
  | .logPop => { w with logs := w.logs.tail }
  | .refund prev => { w with refund := prev }

/-- Journaled world state pairing the live `WorldState` with its LIFO undo stack. -/
structure JournaledState where
  world : WorldState
  journal : List JournalEntry := []

/-- Record a rollback checkpoint (current undo-journal depth). -/
def checkpoint (js : JournaledState) : Nat := js.journal.length

/-- Pop and apply `n` undo entries from the journal in LIFO order. -/
def rollbackCount : Nat → JournaledState → JournaledState
  | 0, js => js
  | _ + 1, { world, journal := [] } => { world, journal := [] }
  | n + 1, { world, journal := e :: rest } =>
    rollbackCount n { world := undoEntry world e, journal := rest }

/-- Roll back all state mutations recorded after checkpoint `cp`. -/
def rollbackTo (js : JournaledState) (cp : Nat) : JournaledState :=
  rollbackCount (js.journal.length - cp) js

/-- Atomic EVM state mutations tracked by the undo journal. -/
inductive StateOp where
  | sstore (addr : Addr) (slot : Word) (val : Word)
  | tstore (addr : Addr) (slot : Word) (val : Word)
  | transfer (src dst : Addr) (value : Nat)
  | bumpNonce (addr : Addr)
  | setCode (addr : Addr) (newCode : Code)
  | warmAddr (addr : Addr)
  | warmSlot (addr : Addr) (slot : Word)
  | emitLog (entry : LogEntry)
  | addRefund (delta : Int)
  | selfdestruct (self beneficiary : Addr)

/-- Whether a `StateOp` mutates persistent/observable state and is therefore
forbidden inside a `STATICCALL` context (EIP-214 / EIP-1153). -/
def StateOp.isMutating : StateOp → Bool
  | .sstore _ _ _ => true
  | .tstore _ _ _ => true
  | .transfer _ _ value => decide (value > 0)
  | .bumpNonce _ => true
  | .setCode _ _ => true
  | .warmAddr _ => false
  | .warmSlot _ _ => false
  | .emitLog _ => true
  | .addRefund _ => false
  | .selfdestruct _ _ => true

/-- Apply one atomic `StateOp`, pushing its exact undo entry(s) onto `journal`.
Transfers with insufficient balance leave state untouched. -/
def stepOp (op : StateOp) (js : JournaledState) : JournaledState :=
  let w := js.world
  match op with
  | .sstore a s v =>
    { world := { w with storage := update2 w.storage a s v }
      journal := .storage a s (w.storage a s) :: js.journal }
  | .tstore a s v =>
    { world := { w with transient := update2 w.transient a s v }
      journal := .transient a s (w.transient a s) :: js.journal }
  | .transfer src dst value =>
    if w.balances src < value then js
    else
      let b1 := update1 w.balances src (w.balances src - value)
      let b2 := update1 b1 dst (b1 dst + value)
      { world := { w with balances := b2 }
        journal := .balance dst (b1 dst) :: .balance src (w.balances src) :: js.journal }
  | .bumpNonce a =>
    { world := { w with nonces := update1 w.nonces a (w.nonces a + 1) }
      journal := .nonce a (w.nonces a) :: js.journal }
  | .setCode a c =>
    { world := { w with code := update1 w.code a c }
      journal := .code a (w.code a) :: js.journal }
  | .warmAddr a =>
    { world := { w with warmAddresses := update1 w.warmAddresses a true }
      journal := .warmAddr a (w.warmAddresses a) :: js.journal }
  | .warmSlot a s =>
    { world := { w with warmSlots := update2 w.warmSlots a s true }
      journal := .warmSlot a s (w.warmSlots a s) :: js.journal }
  | .emitLog entry =>
    { world := { w with logs := entry :: w.logs }
      journal := .logPop :: js.journal }
  | .addRefund delta =>
    { world := { w with refund := w.refund + delta }
      journal := .refund w.refund :: js.journal }
  | .selfdestruct self beneficiary =>
    let bal := w.balances self
    if self = beneficiary then js
    else
      let b1 := update1 w.balances self 0
      let b2 := update1 b1 beneficiary (b1 beneficiary + bal)
      { world := { w with balances := b2 }
        journal := .balance beneficiary (b1 beneficiary) :: .balance self bal :: js.journal }

/-- Execute a sequence of atomic operations in order. -/
def execOps (ops : List StateOp) (js : JournaledState) : JournaledState :=
  ops.foldl (fun acc op => stepOp op acc) js

/-- Rolling back zero entries is a no-op. -/
theorem rollbackCount_zero (js : JournaledState) : rollbackCount 0 js = js := rfl

/-- Rolling back `a + b` entries equals rolling back `a` entries then `b`. -/
theorem rollbackCount_add (a b : Nat) (js : JournaledState) :
    rollbackCount (a + b) js = rollbackCount b (rollbackCount a js) := by
  induction a generalizing js with
  | zero => simp [rollbackCount]
  | succ k ih =>
    rw [Nat.succ_add]
    cases js with
    | mk w j =>
      cases j with
      | nil =>
        simp only [rollbackCount]
        have h : rollbackCount b { world := w, journal := [] } = { world := w, journal := [] } := by
          cases b <;> rfl
        simpa [rollbackCount] using h.symm
      | cons e rest =>
        simp only [rollbackCount]
        exact ih { world := undoEntry w e, journal := rest }

/-- Every single `stepOp` grows (or preserves) the journal length. -/
theorem stepOp_journal_le (op : StateOp) (js : JournaledState) :
    js.journal.length ≤ (stepOp op js).journal.length := by
  cases op <;> simp [stepOp] <;> split <;> simp <;> omega

/-- Rolling back the exact entries pushed by any single `stepOp` restores `js`
identically (world state and undo journal). -/
theorem rollback_stepOp (op : StateOp) (js : JournaledState) :
    rollbackCount ((stepOp op js).journal.length - js.journal.length) (stepOp op js) = js := by
  cases js with
  | mk w j =>
    cases op with
    | sstore a s v =>
      simp [stepOp, rollbackCount, undoEntry]
    | tstore a s v =>
      simp [stepOp, rollbackCount, undoEntry]
    | transfer src dst value =>
      simp only [stepOp]
      split
      · simp [rollbackCount]
      · simp only [List.length_cons]
        have h2 : j.length + 1 + 1 - j.length = 2 := by omega
        rw [h2]
        simp [rollbackCount, undoEntry]
    | bumpNonce a =>
      simp [stepOp, rollbackCount, undoEntry]
    | setCode a c =>
      simp [stepOp, rollbackCount, undoEntry]
    | warmAddr a =>
      simp [stepOp, rollbackCount, undoEntry]
    | warmSlot a s =>
      simp [stepOp, rollbackCount, undoEntry]
    | emitLog entry =>
      simp [stepOp, rollbackCount, undoEntry]
    | addRefund delta =>
      simp [stepOp, rollbackCount, undoEntry]
    | selfdestruct self beneficiary =>
      simp only [stepOp]
      split
      · simp [rollbackCount]
      · simp only [List.length_cons]
        have h2 : j.length + 1 + 1 - j.length = 2 := by omega
        rw [h2]
        simp [rollbackCount, undoEntry]

/-- Executing any sequence of operations never shrinks the undo journal. -/
theorem execOps_journal_le (ops : List StateOp) (js : JournaledState) :
    js.journal.length ≤ (execOps ops js).journal.length := by
  induction ops generalizing js with
  | nil => exact Nat.le_refl _
  | cons op rest ih =>
    simp only [execOps, List.foldl_cons]
    exact Nat.le_trans (stepOp_journal_le op js) (ih (stepOp op js))

/-- **Core Journal Soundness Theorem**: Rolling back to `checkpoint js` after
executing ANY sequence of state mutations restores the exact pre-call
`JournaledState` (both `world` and `journal`). -/
theorem rollbackTo_execOps (js : JournaledState) (ops : List StateOp) :
    rollbackTo (execOps ops js) (checkpoint js) = js := by
  induction ops generalizing js with
  | nil =>
    simp [execOps, rollbackTo, checkpoint, rollbackCount]
  | cons op rest ih =>
    simp only [execOps, List.foldl_cons, rollbackTo, checkpoint]
    let js1 := stepOp op js
    let js2 := execOps rest js1
    have hLen1 : js.journal.length ≤ js1.journal.length := stepOp_journal_le op js
    have hLen2 : js1.journal.length ≤ js2.journal.length := execOps_journal_le rest js1
    have hSplit : js2.journal.length - js.journal.length =
        (js2.journal.length - js1.journal.length) + (js1.journal.length - js.journal.length) := by
      omega
    change rollbackCount (js2.journal.length - js.journal.length) js2 = js
    rw [hSplit, rollbackCount_add]
    have hInner : rollbackCount (js2.journal.length - js1.journal.length) js2 = js1 := ih js1
    rw [hInner]
    exact rollback_stepOp op js

/-- Reverted child frame leaves persistent storage identical to pre-call snapshot. -/
theorem reverted_child_restores_storage (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.storage = js.world.storage := by
  rw [rollbackTo_execOps]

/-- Reverted child frame leaves EIP-1153 transient storage identical to pre-call snapshot. -/
theorem reverted_child_restores_transient (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.transient = js.world.transient := by
  rw [rollbackTo_execOps]

/-- Reverted child frame leaves all account balances identical to pre-call snapshot. -/
theorem reverted_child_restores_balances (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.balances = js.world.balances := by
  rw [rollbackTo_execOps]

/-- Reverted child frame leaves all account nonces identical to pre-call snapshot. -/
theorem reverted_child_restores_nonces (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.nonces = js.world.nonces := by
  rw [rollbackTo_execOps]

/-- Reverted child frame leaves all contract bytecode identical to pre-call snapshot. -/
theorem reverted_child_restores_code (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.code = js.world.code := by
  rw [rollbackTo_execOps]

/-- Reverted child frame discards all child logs, leaving parent logs identical. -/
theorem reverted_child_restores_logs (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.visibleLogs = js.world.visibleLogs := by
  rw [rollbackTo_execOps]

/-- Reverted child frame rolls back EIP-2929 warm addresses to pre-call snapshot. -/
theorem reverted_child_restores_warm_addresses (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.warmAddresses = js.world.warmAddresses := by
  rw [rollbackTo_execOps]

/-- Reverted child frame rolls back EIP-2929 warm storage slots to pre-call snapshot. -/
theorem reverted_child_restores_warm_slots (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.warmSlots = js.world.warmSlots := by
  rw [rollbackTo_execOps]

/-- Reverted child frame restores the gas refund counter to pre-call snapshot. -/
theorem reverted_child_restores_refund (js : JournaledState) (ops : List StateOp) :
    (rollbackTo (execOps ops js) (checkpoint js)).world.refund = js.world.refund := by
  rw [rollbackTo_execOps]

/-- **Nested Revert Theorem**: When an inner child frame reverts inside a
committed outer frame, all outer mutations are preserved while all inner
mutations are discarded. -/
theorem nested_revert_preserves_outer_mutations
    (js0 : JournaledState) (outerOps innerOps : List StateOp) :
    let jsOuter := execOps outerOps js0
    let cpInner := checkpoint jsOuter
    let jsInner := execOps innerOps jsOuter
    rollbackTo jsInner cpInner = jsOuter :=
  rollbackTo_execOps (execOps outerOps js0) innerOps

/-- **Outer Revert Over Committed Inner Theorem**: When an inner child frame
commits, and the enclosing outer frame subsequently reverts, both outer and
inner mutations are rolled back cleanly to the pre-outer snapshot. -/
theorem outer_revert_discards_committed_inner
    (js0 : JournaledState) (outerOps innerOps afterOps : List StateOp) :
    let cpOuter := checkpoint js0
    let js1 := execOps outerOps js0
    let js2 := execOps innerOps js1
    let js3 := execOps afterOps js2
    rollbackTo js3 cpOuter = js0 := by
  have h : execOps afterOps (execOps innerOps (execOps outerOps js0)) =
      execOps (outerOps ++ innerOps ++ afterOps) js0 := by
    simp [execOps, List.foldl_append]
  simpa only [h] using rollbackTo_execOps js0 (outerOps ++ innerOps ++ afterOps)

/-- Insufficient-balance transfer in `stepOp` leaves `JournaledState` unchanged. -/
theorem stepOp_transfer_insufficient_unchanged (js : JournaledState) (src dst : Addr)
    (value : Nat) (h : js.world.balances src < value) :
    stepOp (.transfer src dst value) js = js := by
  simp [stepOp, h]

/-- `stepOp` for `transfer` conserves `totalBalance` across any duplicate-free
account set containing both endpoints. -/
theorem stepOp_transfer_conserves_totalBalance {addrs : List Addr} {src dst : Addr}
    (hnd : addrs.Nodup) (hSrc : src ∈ addrs) (hDst : dst ∈ addrs)
    (value : Nat) (js : JournaledState) :
    totalBalance addrs (stepOp (.transfer src dst value) js).world.balances =
      totalBalance addrs js.world.balances := by
  simp only [stepOp]
  split
  · rfl
  · rename_i hNotLt
    have hBal : value ≤ js.world.balances src := Nat.le_of_not_lt hNotLt
    exact totalBalance_transfer_conserved hnd hSrc hDst value js.world.balances hBal

/-- `stepOp` for non-burning `selfdestruct` conserves `totalBalance`. -/
theorem stepOp_selfdestruct_conserves_totalBalance {addrs : List Addr} {self ben : Addr}
    (hnd : addrs.Nodup) (hSelf : self ∈ addrs) (hBen : ben ∈ addrs)
    (js : JournaledState) :
    totalBalance addrs (stepOp (.selfdestruct self ben) js).world.balances =
      totalBalance addrs js.world.balances := by
  simp only [stepOp]
  split
  · rfl
  · have hBal : js.world.balances self ≤ js.world.balances self := Nat.le_refl _
    have hEq :
        (update1 (update1 js.world.balances self 0) ben
          (update1 js.world.balances self 0 ben + js.world.balances self)) =
        applyBalanceTransfer self ben (js.world.balances self) js.world.balances := by
      unfold applyBalanceTransfer
      simp
    show totalBalance addrs
        (update1 (update1 js.world.balances self 0) ben
          (update1 js.world.balances self 0 ben + js.world.balances self)) =
      totalBalance addrs js.world.balances
    rw [hEq]
    exact totalBalance_transfer_conserved hnd hSelf hBen (js.world.balances self)
      js.world.balances hBal

/-! ## Call boundaries, STATICCALL propagation, and depth-1024 limit -/

/-- EVM call frame boundary kinds. -/
inductive CallKind where
  | call
  | staticCall
  | delegateCall
  | create
  deriving DecidableEq, Repr

/-- Execution context of a single call frame. -/
structure FrameContext where
  caller : Addr
  target : Addr
  codeAddr : Addr
  value : Nat
  depth : Nat
  isStatic : Bool
  deriving DecidableEq, Repr

/-- Child `isStatic` flag propagated across a call boundary (EIP-214). -/
def childIsStatic (parentStatic : Bool) (kind : CallKind) : Bool :=
  parentStatic || (kind == .staticCall)

/-- Whether initiating a call of `kind` with `value` is rejected by static mode. -/
def callViolatesStatic (parentStatic : Bool) (kind : CallKind) (value : Nat) : Bool :=
  parentStatic && match kind with
    | .create => true
    | .call => decide (value > 0)
    | .staticCall => false
    | .delegateCall => false

/-- Failure reasons for call entry or guarded static operations. -/
inductive CallFailure where
  | depthLimitExceeded
  | staticViolation
  | insufficientBalance
  deriving DecidableEq, Repr

/-- Compute the child `FrameContext` for a call boundary, enforcing the
depth-1024 limit and EIP-214 static rules. -/
def enterChildContext (parent : FrameContext) (kind : CallKind)
    (callee : Addr) (value : Nat) : Except CallFailure FrameContext :=
  if parent.depth ≥ maxCallDepth then
    .error .depthLimitExceeded
  else if callViolatesStatic parent.isStatic kind value then
    .error .staticViolation
  else
    let nextDepth := parent.depth + 1
    let nextStatic := childIsStatic parent.isStatic kind
    match kind with
    | .call =>
      .ok { caller := parent.target, target := callee, codeAddr := callee,
            value := value, depth := nextDepth, isStatic := nextStatic }
    | .staticCall =>
      .ok { caller := parent.target, target := callee, codeAddr := callee,
            value := 0, depth := nextDepth, isStatic := true }
    | .delegateCall =>
      -- DELEGATECALL preserves msg.sender, storage target, and msg.value.
      .ok { caller := parent.caller, target := parent.target, codeAddr := callee,
            value := parent.value, depth := nextDepth, isStatic := nextStatic }
    | .create =>
      .ok { caller := parent.target, target := callee, codeAddr := callee,
            value := value, depth := nextDepth, isStatic := nextStatic }

/-- Guarded execution of a single `StateOp` respecting `js.world.isStatic`. -/
def stepOpChecked (op : StateOp) (js : JournaledState) :
    Except CallFailure JournaledState :=
  if js.world.isStatic && op.isMutating then
    .error .staticViolation
  else
    .ok (stepOp op js)

/-- `isStatic` is monotone downward across every call kind. -/
theorem childIsStatic_monotone (kind : CallKind) :
    childIsStatic true kind = true := by
  simp [childIsStatic]

/-- `STATICCALL` unconditionally sets `isStatic = true` in the child frame. -/
theorem staticCall_forces_static (parentStatic : Bool) :
    childIsStatic parentStatic .staticCall = true := by
  simp [childIsStatic]

/-- Static flag propagation along an arbitrarily deep call path. -/
def pathStatic (init : Bool) (path : List CallKind) : Bool :=
  path.foldl childIsStatic init

/-- Once `isStatic = true`, EVERY descendant at arbitrary call-tree depth has
`isStatic = true`. -/
theorem pathStatic_monotone (path : List CallKind) :
    pathStatic true path = true := by
  induction path with
  | nil => rfl
  | cons k rest ih =>
    simp only [pathStatic, List.foldl_cons, childIsStatic_monotone]
    exact ih

/-- Any call path that passes through a `STATICCALL` has `isStatic = true` at
the leaf, regardless of all surrounding `CALL`/`DELEGATECALL`/`CREATE` hops. -/
theorem pathStatic_after_staticCall (init : Bool) (prefixPath suffixPath : List CallKind) :
    pathStatic init (prefixPath ++ .staticCall :: suffixPath) = true := by
  simp only [pathStatic, List.foldl_append, List.foldl_cons, staticCall_forces_static]
  exact pathStatic_monotone suffixPath

/-- `SSTORE` is strictly rejected whenever `isStatic = true`. -/
theorem static_rejects_sstore (js : JournaledState) (a : Addr) (s v : Word)
    (h : js.world.isStatic = true) :
    stepOpChecked (.sstore a s v) js = .error .staticViolation := by
  simp [stepOpChecked, StateOp.isMutating, h]

/-- `TSTORE` (EIP-1153) is strictly rejected whenever `isStatic = true`. -/
theorem static_rejects_tstore (js : JournaledState) (a : Addr) (s v : Word)
    (h : js.world.isStatic = true) :
    stepOpChecked (.tstore a s v) js = .error .staticViolation := by
  simp [stepOpChecked, StateOp.isMutating, h]

/-- `LOG0..LOG4` is strictly rejected whenever `isStatic = true`. -/
theorem static_rejects_log (js : JournaledState) (entry : LogEntry)
    (h : js.world.isStatic = true) :
    stepOpChecked (.emitLog entry) js = .error .staticViolation := by
  simp [stepOpChecked, StateOp.isMutating, h]

/-- `SELFDESTRUCT` is strictly rejected whenever `isStatic = true`. -/
theorem static_rejects_selfdestruct (js : JournaledState) (self ben : Addr)
    (h : js.world.isStatic = true) :
    stepOpChecked (.selfdestruct self ben) js = .error .staticViolation := by
  simp [stepOpChecked, StateOp.isMutating, h]

/-- `CREATE`/`CREATE2` is strictly rejected whenever `isStatic = true`. -/
theorem static_rejects_create (parent : FrameContext) (callee : Addr) (value : Nat)
    (hDepth : parent.depth < maxCallDepth) (hStatic : parent.isStatic = true) :
    enterChildContext parent .create callee value = .error .staticViolation := by
  have hNotGe : ¬ parent.depth ≥ maxCallDepth := by omega
  simp [enterChildContext, callViolatesStatic, hNotGe, hStatic]

/-- Value-bearing `CALL` (`value > 0`) is strictly rejected whenever `isStatic = true`. -/
theorem static_rejects_value_call (parent : FrameContext) (callee : Addr) (value : Nat)
    (hDepth : parent.depth < maxCallDepth) (hStatic : parent.isStatic = true)
    (hVal : value > 0) :
    enterChildContext parent .call callee value = .error .staticViolation := by
  have hNotGe : ¬ parent.depth ≥ maxCallDepth := by omega
  simp [enterChildContext, callViolatesStatic, hNotGe, hStatic, hVal]

/-- Zero-value `CALL` is permitted inside a static context and keeps `isStatic = true`. -/
theorem static_allows_zero_value_call (parent : FrameContext) (callee : Addr)
    (hDepth : parent.depth < maxCallDepth) (hStatic : parent.isStatic = true) :
    ∃ child, enterChildContext parent .call callee 0 = .ok child ∧ child.isStatic = true := by
  have hNotGe : ¬ parent.depth ≥ maxCallDepth := by omega
  refine ⟨{ caller := parent.target, target := callee, codeAddr := callee,
            value := 0, depth := parent.depth + 1, isStatic := true }, ?_, rfl⟩
  simp [enterChildContext, callViolatesStatic, childIsStatic, hNotGe, hStatic]

/-- `DELEGATECALL` preserves storage target, `msg.sender`, `msg.value`, and `isStatic`. -/
theorem delegatecall_preserves_context (parent : FrameContext) (codeAddr : Addr) (value : Nat)
    (hDepth : parent.depth < maxCallDepth) :
    ∃ child,
      enterChildContext parent .delegateCall codeAddr value = .ok child
      ∧ child.caller = parent.caller
      ∧ child.target = parent.target
      ∧ child.value = parent.value
      ∧ child.isStatic = parent.isStatic
      ∧ child.depth = parent.depth + 1 := by
  have hNotGe : ¬ parent.depth ≥ maxCallDepth := by omega
  refine ⟨{ caller := parent.caller, target := parent.target, codeAddr := codeAddr,
            value := parent.value, depth := parent.depth + 1,
            isStatic := childIsStatic parent.isStatic .delegateCall },
          ?_, rfl, rfl, rfl, by simp [childIsStatic], rfl⟩
  simp [enterChildContext, callViolatesStatic, hNotGe]

/-- **Depth-1024 Call-Stack Limit**: any call at `depth ≥ 1024` is rejected
cleanly with `depthLimitExceeded`. -/
theorem depth_limit_rejects_entry (parent : FrameContext) (kind : CallKind)
    (callee : Addr) (value : Nat) (hDepth : parent.depth ≥ maxCallDepth) :
    enterChildContext parent kind callee value = .error .depthLimitExceeded := by
  simp [enterChildContext, hDepth]

/-- Exact depth boundary: depth 1023 enters depth 1024; depth 1024 is rejected. -/
theorem depth_limit_exact_boundary (caller target callee : Addr) :
    let ctx1023 : FrameContext :=
      { caller, target, codeAddr := target, value := 0, depth := 1023, isStatic := false }
    let ctx1024 : FrameContext :=
      { caller, target, codeAddr := target, value := 0, depth := 1024, isStatic := false }
    (∃ child, enterChildContext ctx1023 .call callee 0 = .ok child ∧ child.depth = 1024)
    ∧ enterChildContext ctx1024 .call callee 0 = .error .depthLimitExceeded := by
  constructor
  · exact ⟨_, rfl, rfl⟩
  · rfl

/-! ## Structured Call-Tree Execution & Global Security Invariants -/

/-- A structured multi-frame EVM execution tree. -/
inductive CallTree where
  | atom (op : StateOp)
  | seq (first second : CallTree)
  | subcall (kind : CallKind) (callee : Addr) (value : Nat) (reqGas : Nat)
      (body : CallTree) (reverts : Bool)

/-- Execute a `CallTree` with full snapshot/rollback, depth-1024 enforcement,
EIP-214 static checks, and EIP-150 gas accounting.
Returns `(success, gasRemaining, finalJournaledState)`. -/
def execTree (t : CallTree) (gas : Nat) (js : JournaledState) :
    Bool × Nat × JournaledState :=
  match t with
  | .atom op =>
    match stepOpChecked op js with
    | .ok js' => (true, gas, js')
    | .error _ => (false, 0, js)
  | .seq t1 t2 =>
    let (ok1, g1, js1) := execTree t1 gas js
    if ok1 then execTree t2 g1 js1 else (false, g1, js1)
  | .subcall kind _callee value reqGas body reverts =>
    let w := js.world
    if w.depth ≥ maxCallDepth then
      -- Depth limit exceeded: fail cleanly without mutating state; return all gas.
      (false, gas, js)
    else if callViolatesStatic w.isStatic kind value then
      -- Static violation: fail cleanly without mutating state.
      (false, 0, js)
    else
      let cp := checkpoint js
      let sent := match kind with
        | .create => forwardedGas gas
        | _ => callChildGas gas reqGas
      let parentKept := gas - sent
      let childWorld : WorldState :=
        { w with depth := w.depth + 1, isStatic := childIsStatic w.isStatic kind }
      let jsEnter : JournaledState := { js with world := childWorld }
      let (childOk, childRem, jsAfter) := execTree body sent jsEnter
      let restoredGas := parentKept + childRem
      if childOk && !reverts then
        -- Commit child state mutations while restoring caller's depth and isStatic.
        let committedWorld := { jsAfter.world with depth := w.depth, isStatic := w.isStatic }
        (true, restoredGas, { jsAfter with world := committedWorld })
      else
        -- Revert child mutations completely via undo journal and restore caller context.
        let rolled := rollbackTo jsAfter cp
        let revertedWorld := { rolled.world with depth := w.depth, isStatic := w.isStatic }
        (false, restoredGas, { rolled with world := revertedWorld })

/-- Persistent/observable state fields that static execution must never alter. -/
def WorldState.staticProtectedEq (w₁ w₂ : WorldState) : Prop :=
  w₁.storage = w₂.storage
  ∧ w₁.transient = w₂.transient
  ∧ w₁.balances = w₂.balances
  ∧ w₁.nonces = w₂.nonces
  ∧ w₁.code = w₂.code
  ∧ w₁.logs = w₂.logs

theorem WorldState.staticProtectedEq_refl (w : WorldState) :
    w.staticProtectedEq w :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem WorldState.staticProtectedEq_trans {w₁ w₂ w₃ : WorldState}
    (h12 : w₁.staticProtectedEq w₂) (h23 : w₂.staticProtectedEq w₃) :
    w₁.staticProtectedEq w₃ :=
  ⟨h12.1.trans h23.1, h12.2.1.trans h23.2.1, h12.2.2.1.trans h23.2.2.1,
   h12.2.2.2.1.trans h23.2.2.2.1, h12.2.2.2.2.1.trans h23.2.2.2.2.1,
   h12.2.2.2.2.2.trans h23.2.2.2.2.2⟩

/-- Non-mutating `StateOp`s preserve all static-protected state fields. -/
theorem stepOpChecked_static_preserves (op : StateOp) (js js' : JournaledState)
    (hStatic : js.world.isStatic = true)
    (hOk : stepOpChecked op js = .ok js') :
    js'.world.staticProtectedEq js.world := by
  unfold stepOpChecked at hOk
  rw [hStatic] at hOk
  cases op with
  | sstore _ _ _ => simp [StateOp.isMutating] at hOk
  | tstore _ _ _ => simp [StateOp.isMutating] at hOk
  | transfer src dst value =>
    simp only [StateOp.isMutating, Bool.true_and] at hOk
    by_cases hv : value > 0
    · simp [hv] at hOk
    · have hv0 : value = 0 := by omega
      subst hv0
      simp only [Nat.lt_irrefl, decide_false, Bool.false_eq_true, ↓reduceIte, Except.ok.injEq] at hOk
      subst hOk
      unfold stepOp
      have hNotLt : ¬ js.world.balances src < 0 := by omega
      simp only [hNotLt, ↓reduceIte]
      refine ⟨rfl, rfl, ?_, rfl, rfl, rfl⟩
      funext x
      unfold update1
      by_cases hx1 : x = dst <;> by_cases hx2 : x = src <;> simp_all
  | bumpNonce _ => simp [StateOp.isMutating] at hOk
  | setCode _ _ => simp [StateOp.isMutating] at hOk
  | warmAddr _ =>
    simp only [StateOp.isMutating, Bool.and_false, Bool.false_eq_true, ↓reduceIte,
      Except.ok.injEq] at hOk
    subst hOk
    exact WorldState.staticProtectedEq_refl _
  | warmSlot _ _ =>
    simp only [StateOp.isMutating, Bool.and_false, Bool.false_eq_true, ↓reduceIte,
      Except.ok.injEq] at hOk
    subst hOk
    exact WorldState.staticProtectedEq_refl _
  | emitLog _ => simp [StateOp.isMutating] at hOk
  | addRefund _ =>
    simp only [StateOp.isMutating, Bool.and_false, Bool.false_eq_true, ↓reduceIte,
      Except.ok.injEq] at hOk
    subst hOk
    exact WorldState.staticProtectedEq_refl _
  | selfdestruct _ _ => simp [StateOp.isMutating] at hOk

/-- Helper: `rollbackTo` on a `JournaledState` whose `world` has the same
revertible fields as `js` commutes with `depth`/`isStatic` updates. -/
theorem undoEntry_preserves_depth_static (w : WorldState) (e : JournalEntry) :
    (undoEntry w e).depth = w.depth ∧ (undoEntry w e).isStatic = w.isStatic := by
  cases e <;> simp [undoEntry]

/-- Helper: `stepOpChecked` preserves `depth` and `isStatic`. -/
theorem stepOpChecked_preserves_depth_static (op : StateOp) (js js' : JournaledState)
    (h : stepOpChecked op js = .ok js') :
    js'.world.depth = js.world.depth ∧ js'.world.isStatic = js.world.isStatic := by
  unfold stepOpChecked at h
  split at h
  · cases h
  · cases h
    cases op <;> simp [stepOp] <;> split <;> simp

/-- Helper: `rollbackCount` preserves `depth` and `isStatic`. -/
theorem rollbackCount_preserves_depth_static (n : Nat) (js : JournaledState) :
    (rollbackCount n js).world.depth = js.world.depth
    ∧ (rollbackCount n js).world.isStatic = js.world.isStatic := by
  induction n generalizing js with
  | zero => exact ⟨rfl, rfl⟩
  | succ k ih =>
    cases js with
    | mk w j =>
      cases j with
      | nil => exact ⟨rfl, rfl⟩
      | cons e rest =>
        simp only [rollbackCount]
        have h1 := ih { world := undoEntry w e, journal := rest }
        have h2 := undoEntry_preserves_depth_static w e
        exact ⟨h1.1.trans h2.1, h1.2.trans h2.2⟩

/-- Helper: `undoEntry` commutes with modifying `depth` and `isStatic`. -/
theorem undoEntry_with_depth_static (w : WorldState) (d : Nat) (st : Bool) (e : JournalEntry) :
    undoEntry { w with depth := d, isStatic := st } e =
      { undoEntry w e with depth := d, isStatic := st } := by
  cases e <;> rfl

/-- Helper: `rollbackCount` commutes with modifying `depth` and `isStatic`. -/
theorem rollbackCount_with_depth_static (n : Nat) (js : JournaledState) (d : Nat) (st : Bool) :
    rollbackCount n { js with world := { js.world with depth := d, isStatic := st } } =
      let r := rollbackCount n js
      { r with world := { r.world with depth := d, isStatic := st } } := by
  induction n generalizing js with
  | zero => rfl
  | succ k ih =>
    cases js with
    | mk w j =>
      cases j with
      | nil => rfl
      | cons e rest =>
        simp only [rollbackCount, undoEntry_with_depth_static]
        exact ih { world := undoEntry w e, journal := rest }

/-- **Frame Context Preservation**: `execTree` always restores the caller's
`depth` and `isStatic`, never shrinks the undo journal, and never exceeds the
input gas budget. -/
theorem execTree_invariants (t : CallTree) (gas : Nat) (js : JournaledState) :
    let (_, gasOut, jsOut) := execTree t gas js
    jsOut.world.depth = js.world.depth
    ∧ jsOut.world.isStatic = js.world.isStatic
    ∧ js.journal.length ≤ jsOut.journal.length
    ∧ gasOut ≤ gas
    ∧ rollbackTo jsOut (checkpoint js) = js := by
  induction t generalizing gas js with
  | atom op =>
    simp only [execTree]
    cases h : stepOpChecked op js with
    | error _ =>
      simp [rollbackTo, checkpoint, rollbackCount]
    | ok js' =>
      have hds := stepOpChecked_preserves_depth_static op js js' h
      unfold stepOpChecked at h
      split at h
      · cases h
      · cases h
        refine ⟨hds.1, hds.2, stepOp_journal_le op js, Nat.le_refl _, ?_⟩
        exact rollback_stepOp op js
  | seq t1 t2 ih1 ih2 =>
    simp only [execTree]
    have h1 := ih1 gas js
    cases hRes1 : execTree t1 gas js with
    | mk ok1 p1 =>
      cases p1 with
      | mk g1 js1 =>
        rw [hRes1] at h1
        rcases h1 with ⟨h1d, h1s, h1len, h1gas, h1rb⟩
        cases ok1 with
        | false =>
          exact ⟨h1d, h1s, h1len, h1gas, h1rb⟩
        | true =>
          have h2 := ih2 g1 js1
          cases hRes2 : execTree t2 g1 js1 with
          | mk ok2 p2 =>
            cases p2 with
            | mk g2 js2 =>
              rw [hRes2] at h2
              rcases h2 with ⟨h2d, h2s, h2len, h2gas, h2rb⟩
              refine ⟨h2d.trans h1d, h2s.trans h1s, Nat.le_trans h1len h2len,
                Nat.le_trans h2gas h1gas, ?_⟩
              unfold rollbackTo checkpoint at h1rb h2rb ⊢
              simp only [↓reduceIte]
              have hSplit : js2.journal.length - js.journal.length =
                  (js2.journal.length - js1.journal.length) +
                  (js1.journal.length - js.journal.length) := by omega
              rw [hSplit, rollbackCount_add, h2rb, h1rb]
  | subcall kind callee value reqGas body reverts ih =>
    simp only [execTree]
    by_cases hDepth : js.world.depth ≥ maxCallDepth
    · simp [hDepth, rollbackTo, checkpoint, rollbackCount]
    · simp only [hDepth, ↓reduceIte]
      by_cases hStat : callViolatesStatic js.world.isStatic kind value = true
      · simp [hStat, rollbackTo, checkpoint, rollbackCount]
      · simp only [hStat, Bool.false_eq_true, ↓reduceIte]
        let sent := match kind with
          | .create => forwardedGas gas
          | _ => callChildGas gas reqGas
        have hSentLe : sent ≤ gas := by
          cases kind
          · exact callChildGas_le_available gas reqGas
          · exact callChildGas_le_available gas reqGas
          · exact callChildGas_le_available gas reqGas
          · exact forwardedGas_le gas
        let jsEnter : JournaledState :=
          { js with world := { js.world with
              depth := js.world.depth + 1
              isStatic := childIsStatic js.world.isStatic kind } }
        have hBody := ih sent jsEnter
        cases hResB : execTree body sent jsEnter with
        | mk childOk pB =>
          cases pB with
          | mk childRem jsAfter =>
            rw [hResB] at hBody
            rcases hBody with ⟨_, _, hBlen, hBgas, hBrb⟩
            have hGasLe : gas - sent + childRem ≤ gas := by omega
            have hRbEnter :
                let r := rollbackTo jsAfter (checkpoint js)
                { r with world := { r.world with
                    depth := js.world.depth, isStatic := js.world.isStatic } } = js := by
              change let r := rollbackTo jsAfter (checkpoint jsEnter)
                { r with world := { r.world with
                    depth := js.world.depth, isStatic := js.world.isStatic } } = js
              rw [hBrb]
            show let (_, gasOut, jsOut) :=
                if childOk && !reverts then
                  (true, gas - sent + childRem,
                    { jsAfter with world := { jsAfter.world with
                        depth := js.world.depth, isStatic := js.world.isStatic } })
                else
                  let rolled := rollbackTo jsAfter (checkpoint js)
                  (false, gas - sent + childRem,
                    { rolled with world := { rolled.world with
                        depth := js.world.depth, isStatic := js.world.isStatic } })
              jsOut.world.depth = js.world.depth
              ∧ jsOut.world.isStatic = js.world.isStatic
              ∧ js.journal.length ≤ jsOut.journal.length
              ∧ gasOut ≤ gas
              ∧ rollbackTo jsOut (checkpoint js) = js
            by_cases hCommit : (childOk && !reverts) = true
            · simp only [hCommit, ↓reduceIte]
              refine ⟨trivial, trivial, hBlen, hGasLe, ?_⟩
              unfold rollbackTo checkpoint
              have hComm := rollbackCount_with_depth_static
                (jsAfter.journal.length - js.journal.length) jsAfter
                js.world.depth js.world.isStatic
              rw [hComm]
              exact hRbEnter
            · simp only [hCommit, Bool.false_eq_true, ↓reduceIte]
              have hRolledEq :
                  { rollbackTo jsAfter (checkpoint js) with
                    world := { (rollbackTo jsAfter (checkpoint js)).world with
                      depth := js.world.depth, isStatic := js.world.isStatic } } = js :=
                hRbEnter
              have hRolledLen : (rollbackTo jsAfter (checkpoint js)).journal.length = js.journal.length := by
                change (rollbackTo jsAfter (checkpoint jsEnter)).journal.length = js.journal.length
                rw [hBrb]
              refine ⟨trivial, trivial, Nat.le_of_eq hRolledLen.symm, hGasLe, ?_⟩
              rw [hRolledEq]
              simp [rollbackTo, checkpoint, rollbackCount]

/-- **Depth-1024 Execution Theorem**: A `subcall` executed when `depth ≥ 1024`
fails cleanly (`false`), preserves 100% of gas, and leaves `JournaledState`
completely untouched. -/
theorem depth_limit_execTree_clean_fail (kind : CallKind) (callee : Addr)
    (value reqGas gas : Nat) (body : CallTree) (reverts : Bool) (js : JournaledState)
    (hDepth : js.world.depth ≥ maxCallDepth) :
    execTree (.subcall kind callee value reqGas body reverts) gas js = (false, gas, js) := by
  simp [execTree, hDepth]

/-- **Full Call-Tree Revert Rollback Theorem**: A reverting child `subcall`
ALWAYS restores the parent's `JournaledState` identically (storage, transient
storage, balances, nonces, code, logs, warm sets, refunds, depth, isStatic). -/
theorem subcall_revert_exact_rollback (kind : CallKind) (callee : Addr)
    (value reqGas gas : Nat) (body : CallTree) (js : JournaledState) :
    (execTree (.subcall kind callee value reqGas body true) gas js).2.2 = js := by
  simp only [execTree]
  by_cases hDepth : js.world.depth ≥ maxCallDepth
  · simp [hDepth]
  · simp only [hDepth, ↓reduceIte]
    by_cases hStat : callViolatesStatic js.world.isStatic kind value = true
    · simp [hStat]
    · simp only [hStat, Bool.false_eq_true, ↓reduceIte]
      let sent := match kind with
        | .create => forwardedGas gas
        | _ => callChildGas gas reqGas
      let jsEnter : JournaledState :=
        { js with world := { js.world with
            depth := js.world.depth + 1
            isStatic := childIsStatic js.world.isStatic kind } }
      have hBody := execTree_invariants body sent jsEnter
      cases hResB : execTree body sent jsEnter with
      | mk childOk pB =>
        cases pB with
        | mk childRem jsAfter =>
          rw [hResB] at hBody
          have hRb : rollbackTo jsAfter (checkpoint jsEnter) = jsEnter := hBody.2.2.2.2
          show (if childOk && !true then
              (true, gas - sent + childRem,
                { jsAfter with world := { jsAfter.world with
                    depth := js.world.depth, isStatic := js.world.isStatic } })
            else
              let rolled := rollbackTo jsAfter (checkpoint js)
              (false, gas - sent + childRem,
                { rolled with world := { rolled.world with
                    depth := js.world.depth, isStatic := js.world.isStatic } })).2.2 = js
          simp only [Bool.not_true, Bool.and_false, Bool.false_eq_true, ↓reduceIte]
          have hCp : checkpoint js = checkpoint jsEnter := rfl
          rw [hCp, hRb]

/-- **Full Call-Tree Static Immutability Theorem**: Executing ANY arbitrarily
nested `CallTree` while `isStatic = true` NEVER mutates persistent storage,
transient storage, balances, nonces, contract code, or logs! -/
theorem static_execTree_preserves_state (t : CallTree) (gas : Nat) (js : JournaledState)
    (hStatic : js.world.isStatic = true) :
    (execTree t gas js).2.2.world.staticProtectedEq js.world := by
  induction t generalizing gas js with
  | atom op =>
    simp only [execTree]
    cases h : stepOpChecked op js with
    | error _ => exact WorldState.staticProtectedEq_refl _
    | ok js' => exact stepOpChecked_static_preserves op js js' hStatic h
  | seq t1 t2 ih1 ih2 =>
    simp only [execTree]
    have hInv1 := execTree_invariants t1 gas js
    have hProt1 := ih1 gas js hStatic
    cases hRes1 : execTree t1 gas js with
    | mk ok1 p1 =>
      cases p1 with
      | mk g1 js1 =>
        rw [hRes1] at hInv1 hProt1
        cases ok1 with
        | false => exact hProt1
        | true =>
          have hStatic1 : js1.world.isStatic = true := hInv1.2.1.trans hStatic
          exact WorldState.staticProtectedEq_trans (ih2 g1 js1 hStatic1) hProt1
  | subcall kind callee value reqGas body reverts ih =>
    simp only [execTree]
    by_cases hDepth : js.world.depth ≥ maxCallDepth
    · simp [hDepth]
      exact WorldState.staticProtectedEq_refl _
    · simp only [hDepth, ↓reduceIte]
      by_cases hStat : callViolatesStatic js.world.isStatic kind value = true
      · simp [hStat]
        exact WorldState.staticProtectedEq_refl _
      · simp only [hStat, Bool.false_eq_true, ↓reduceIte]
        let sent := match kind with
          | .create => forwardedGas gas
          | _ => callChildGas gas reqGas
        let jsEnter : JournaledState :=
          { js with world := { js.world with
              depth := js.world.depth + 1
              isStatic := childIsStatic js.world.isStatic kind } }
        have hChildStatic : jsEnter.world.isStatic = true := by
          simp [jsEnter, hStatic, childIsStatic]
        have hProtB := ih sent jsEnter hChildStatic
        have hInvB := execTree_invariants body sent jsEnter
        cases hResB : execTree body sent jsEnter with
        | mk childOk pB =>
          cases pB with
          | mk childRem jsAfter =>
            rw [hResB] at hProtB hInvB
            have hRbB : rollbackTo jsAfter (checkpoint jsEnter) = jsEnter := hInvB.2.2.2.2
            show (if childOk && !reverts then
                (true, gas - sent + childRem,
                  { jsAfter with world := { jsAfter.world with
                      depth := js.world.depth, isStatic := js.world.isStatic } })
              else
                let rolled := rollbackTo jsAfter (checkpoint js)
                (false, gas - sent + childRem,
                  { rolled with world := { rolled.world with
                      depth := js.world.depth, isStatic := js.world.isStatic } })).2.2.world.staticProtectedEq js.world
            split
            · exact hProtB
            · have hCp : checkpoint js = checkpoint jsEnter := rfl
              dsimp only
              rw [hCp, hRbB]
              exact WorldState.staticProtectedEq_refl _

/-- Whether all transfer/selfdestruct endpoints in a `CallTree` lie inside `addrs`. -/
def CallTree.closedIn (addrs : List Addr) : CallTree → Prop
  | .atom (.transfer src dst _) => src ∈ addrs ∧ dst ∈ addrs
  | .atom (.selfdestruct self ben) => self ∈ addrs ∧ ben ∈ addrs
  | .atom _ => True
  | .seq t1 t2 => t1.closedIn addrs ∧ t2.closedIn addrs
  | .subcall _ _ _ _ body _ => body.closedIn addrs

/-- **Global ETH Supply Conservation Theorem**: Executing ANY arbitrarily nested
`CallTree` (with arbitrary commits, reverts, staticcalls, delegatecalls, and
depth-limit rejections) strictly conserves `totalBalance` across `addrs`. -/
theorem execTree_conserves_totalBalance {addrs : List Addr} (hnd : addrs.Nodup)
    (t : CallTree) (hClosed : t.closedIn addrs) (gas : Nat) (js : JournaledState) :
    totalBalance addrs (execTree t gas js).2.2.world.balances =
      totalBalance addrs js.world.balances := by
  induction t generalizing gas js with
  | atom op =>
    simp only [execTree]
    cases h : stepOpChecked op js with
    | error _ => rfl
    | ok js' =>
      unfold stepOpChecked at h
      split at h
      · cases h
      · cases h
        cases op with
        | transfer src dst value =>
          exact stepOp_transfer_conserves_totalBalance hnd hClosed.1 hClosed.2 value js
        | selfdestruct self ben =>
          exact stepOp_selfdestruct_conserves_totalBalance hnd hClosed.1 hClosed.2 js
        | sstore _ _ _ => rfl
        | tstore _ _ _ => rfl
        | bumpNonce _ => rfl
        | setCode _ _ => rfl
        | warmAddr _ => rfl
        | warmSlot _ _ => rfl
        | emitLog _ => rfl
        | addRefund _ => rfl
  | seq t1 t2 ih1 ih2 =>
    simp only [execTree]
    have h1 := ih1 hClosed.1 gas js
    cases hRes1 : execTree t1 gas js with
    | mk ok1 p1 =>
      cases p1 with
      | mk g1 js1 =>
        rw [hRes1] at h1
        cases ok1 with
        | false => exact h1
        | true => exact (ih2 hClosed.2 g1 js1).trans h1
  | subcall kind callee value reqGas body reverts ih =>
    simp only [execTree]
    by_cases hDepth : js.world.depth ≥ maxCallDepth
    · simp [hDepth]
    · simp only [hDepth, ↓reduceIte]
      by_cases hStat : callViolatesStatic js.world.isStatic kind value = true
      · simp [hStat]
      · simp only [hStat, Bool.false_eq_true, ↓reduceIte]
        let sent := match kind with
          | .create => forwardedGas gas
          | _ => callChildGas gas reqGas
        let jsEnter : JournaledState :=
          { js with world := { js.world with
              depth := js.world.depth + 1
              isStatic := childIsStatic js.world.isStatic kind } }
        have hBodyBal := ih hClosed sent jsEnter
        have hInvB := execTree_invariants body sent jsEnter
        cases hResB : execTree body sent jsEnter with
        | mk childOk pB =>
          cases pB with
          | mk childRem jsAfter =>
            rw [hResB] at hBodyBal hInvB
            have hRbB : rollbackTo jsAfter (checkpoint jsEnter) = jsEnter := hInvB.2.2.2.2
            show totalBalance addrs (if childOk && !reverts then
                (true, gas - sent + childRem,
                  { jsAfter with world := { jsAfter.world with
                      depth := js.world.depth, isStatic := js.world.isStatic } })
              else
                let rolled := rollbackTo jsAfter (checkpoint js)
                (false, gas - sent + childRem,
                  { rolled with world := { rolled.world with
                      depth := js.world.depth, isStatic := js.world.isStatic } })).2.2.world.balances =
              totalBalance addrs js.world.balances
            split
            · exact hBodyBal
            · have hCp : checkpoint js = checkpoint jsEnter := rfl
              dsimp only
              rw [hCp, hRbB]

end EvmSpec.MultiFrame

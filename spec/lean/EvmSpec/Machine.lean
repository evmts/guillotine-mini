import Std.Data.HashMap
import Std.Data.HashSet
import EvmSpec.Word
import EvmSpec.Gas
import EvmSpec.Bytecode

/-!
# Single-frame EVM interpreter

An executable small-step semantics for one standalone call frame: no external
calls, creates, logs, hashing or environment opcodes. The frame starts with
empty storage, empty transient storage, an empty refund counter and (from
Berlin on) every storage slot cold.

Each opcode follows the EELS order of effects: pop operands, charge gas,
perform the operation, push results. This fixes which exception a step raises
when more than one applies (for example an empty stack and too little gas
raises `stackUnderflow`). Every exception consumes all gas, so the choice does
not affect consensus.
-/

namespace EvmSpec

/-- Exceptional halts. All of them consume the remaining gas. -/
inductive Exception where
  | outOfGas
  | stackUnderflow
  | stackOverflow
  | invalidJump
  | invalidOpcode
  /-- A valid opcode that lies outside this single-frame model. -/
  | unsupported (op : Nat)
  deriving Repr, DecidableEq

/-- What a successful step does to control flow. -/
inductive Next where
  | running
  | stopped
  | returned (output : Array UInt8)
  | reverted (output : Array UInt8)

/-- EVM memory. `size` is the active size in bytes (a multiple of 32). `data`
holds a prefix of the contents; bytes past `data.size` are zero. -/
structure Memory where
  data : Array UInt8 := #[]
  size : Nat := 0

namespace Memory

/-- Round up to a multiple of 32. -/
def ceil32 (n : Nat) : Nat := ceilWords n * 32

/-- Gas and resulting size for touching the `(start, length)` ranges in order
(EELS `calculate_gas_extend_memory`). Zero-length ranges touch nothing. -/
def extend (size : Nat) (ranges : List (Nat × Nat)) : Nat × Nat :=
  ranges.foldl
    (fun (acc : Nat × Nat) (range : Nat × Nat) =>
      let (cost, current) := acc
      let (start, length) := range
      if length = 0 then acc
      else
        let after := ceil32 (start + length)
        if after ≤ current then acc
        else (cost + (memoryCost (after / 32) - memoryCost (current / 32)), after))
    (0, size)

/-- Read `length` bytes at `start`. -/
def read (m : Memory) (start length : Nat) : Array UInt8 :=
  Bytecode.readPadded m.data start length

/-- Write `bytes` at `start`. The caller has already grown `size`. -/
def write (m : Memory) (start : Nat) (bytes : Array UInt8) : Memory :=
  if bytes.size = 0 then m
  else
    let stop := start + bytes.size
    let data :=
      if m.data.size < stop then m.data ++ Array.replicate (stop - m.data.size) 0
      else m.data
    let written := (List.range bytes.size).foldl
      (fun d i => d.setIfInBounds (start + i) (bytes.getD i 0)) data
    { m with data := written }

end Memory

/-- Big-endian 32-byte encoding of a word. -/
def wordToBytes (w : Word) : Array UInt8 :=
  Array.ofFn (n := 32) fun i => UInt8.ofNat (w.toNat >>> (8 * (31 - i.val)))

/-- Machine state of one frame. -/
structure State where
  fork : Fork
  code : Code
  jumpdests : Array Bool
  calldata : Array UInt8
  pc : Nat := 0
  gas : Nat
  /-- The stack; the top is the last element. -/
  stack : Array Word := #[]
  memory : Memory := {}
  /-- Storage values at the start of the transaction, keyed by slot. -/
  original : Std.HashMap Nat Word := {}
  /-- Current storage values. -/
  storage : Std.HashMap Nat Word := {}
  /-- Transient storage (EIP-1153). -/
  transient : Std.HashMap Nat Word := {}
  /-- Warm storage slots (EIP-2929). -/
  warm : Std.HashSet Nat := {}
  /-- Refund counter. -/
  refund : Int := 0

/-- Maximum stack depth. -/
def stackLimit : Nat := 1024

abbrev StepM := Except Exception

namespace State

def charge (s : State) (amount : Nat) : StepM State :=
  if s.gas < amount then throw .outOfGas else pure { s with gas := s.gas - amount }

def pop (s : State) : StepM (Word × State) :=
  match s.stack.back? with
  | none => throw .stackUnderflow
  | some w => pure (w, { s with stack := s.stack.pop })

def push (s : State) (w : Word) : StepM State :=
  if s.stack.size ≥ stackLimit then throw .stackOverflow
  else pure { s with stack := s.stack.push w }

def next (s : State) (width : Nat := 1) : State := { s with pc := s.pc + width }

/-- Charge `baseGas` plus the expansion for `ranges`, then grow memory. -/
def chargeMemory (s : State) (baseGas : Nat) (ranges : List (Nat × Nat)) : StepM State := do
  let (cost, size) := Memory.extend s.memory.size ranges
  let s ← s.charge (baseGas + cost)
  pure { s with memory := { s.memory with size := size } }

end State

/-- Opcodes that `fork` defines but this single-frame model does not execute:
KECCAK256, environment and block opcodes, LOGs, calls, creates, SELFDESTRUCT. -/
def unsupportedOpcode (fork : Fork) (op : Nat) : Bool :=
  if op = 0x20 then true
  else if 0x30 ≤ op ∧ op ≤ 0x34 then true
  else if 0x3a ≤ op ∧ op ≤ 0x3c then true
  else if op = 0x3d ∨ op = 0x3e then fork.isAtLeast .BYZANTIUM
  else if op = 0x3f then fork.isAtLeast .CONSTANTINOPLE
  else if 0x40 ≤ op ∧ op ≤ 0x45 then true
  else if op = 0x46 ∨ op = 0x47 then fork.isAtLeast .ISTANBUL
  else if op = 0x48 then fork.isAtLeast .LONDON
  else if op = 0x49 ∨ op = 0x4a then fork.isAtLeast .CANCUN
  else if 0xa0 ≤ op ∧ op ≤ 0xa4 then true
  else if 0xf0 ≤ op ∧ op ≤ 0xf2 then true
  else if op = 0xf4 then fork.isAtLeast .HOMESTEAD
  else if op = 0xf5 then fork.isAtLeast .CONSTANTINOPLE
  else if op = 0xfa then fork.isAtLeast .BYZANTIUM
  else op = 0xff

/-- CALLDATACOPY and CODECOPY: copy `source` into memory. -/
def copyToMemory (s : State) (source : Array UInt8) : StepM State := do
  let (memStart, s) ← s.pop
  let (dataStart, s) ← s.pop
  let (size, s) ← s.pop
  let s ← s.chargeMemory (Gas.veryLow + Gas.copy * ceilWords size.toNat)
    [(memStart.toNat, size.toNat)]
  let bytes := Bytecode.readPadded source dataStart.toNat size.toNat
  pure { s with memory := s.memory.write memStart.toNat bytes }.next

/-- RETURN and REVERT: read the output from memory. -/
def haltWithOutput (s : State) : StepM (Array UInt8 × State) := do
  let (start, s) ← s.pop
  let (size, s) ← s.pop
  let s ← s.chargeMemory 0 [(start.toNat, size.toNat)]
  pure (s.memory.read start.toNat size.toNat, s)

/-- SSTORE (EELS `storage.py`): pop, stipend check, then gas and refund. -/
def stepSstore (s : State) : StepM State := do
  let (key, s) ← s.pop
  let (new, s) ← s.pop
  let slot := key.toNat
  let current := s.storage.getD slot 0
  let original := s.original.getD slot 0
  let cold := !s.warm.contains slot
  match sstore s.fork original current new cold s.gas with
  | none => throw .outOfGas
  | some (cost, refund) =>
    let s ← s.charge cost
    pure { s with
      storage := s.storage.insert slot new
      warm := s.warm.insert slot
      refund := s.refund + refund }.next

/-- Execute the instruction at `s.pc`. Requires `s.pc < s.code.size`. -/
def step (s : State) : StepM (Next × State) := do
  let fork := s.fork
  let op := (s.code.getD s.pc 0).toNat
  let resume (s : State) : StepM (Next × State) := pure (.running, s)
  if wordOpAvailable fork op then
    let arity := wordOpArity op
    let (a, s) ← s.pop
    let (b, s) ← if arity ≥ 2 then s.pop else pure (0, s)
    let (c, s) ← if arity ≥ 3 then s.pop else pure (0, s)
    let s ← s.charge (wordOpGas fork op b)
    let s ← s.push (wordOpResult op a b c)
    resume s.next
  else if 0x60 ≤ op ∧ op ≤ 0x7f then
    -- PUSH1..PUSH32
    let n := op - 0x5f
    let s ← s.charge Gas.veryLow
    let s ← s.push (Bytecode.readPush s.code s.pc n)
    resume (s.next (n + 1))
  else if 0x80 ≤ op ∧ op ≤ 0x8f then
    -- DUP1..DUP16
    let n := op - 0x7f
    let s ← s.charge Gas.veryLow
    if s.stack.size < n then throw .stackUnderflow
    let s ← s.push (s.stack.getD (s.stack.size - n) 0)
    resume s.next
  else if 0x90 ≤ op ∧ op ≤ 0x9f then
    -- SWAP1..SWAP16
    let n := op - 0x8f
    let s ← s.charge Gas.veryLow
    if s.stack.size < n + 1 then throw .stackUnderflow
    let top := s.stack.size - 1
    let other := top - n
    let a := s.stack.getD top 0
    let b := s.stack.getD other 0
    resume { s with stack := (s.stack.setIfInBounds top b).setIfInBounds other a }.next
  else match op with
  | 0x00 => pure (.stopped, s)
  | 0x35 => -- CALLDATALOAD
    let (start, s) ← s.pop
    let s ← s.charge Gas.veryLow
    let word := Word.ofNat (Bytecode.bytesToNat (Bytecode.readPadded s.calldata start.toNat 32))
    let s ← s.push word
    resume s.next
  | 0x36 => -- CALLDATASIZE
    let s ← s.charge Gas.base
    let s ← s.push (Word.ofNat s.calldata.size)
    resume s.next
  | 0x37 => do resume (← copyToMemory s s.calldata)
  | 0x38 => -- CODESIZE
    let s ← s.charge Gas.base
    let s ← s.push (Word.ofNat s.code.size)
    resume s.next
  | 0x39 => do resume (← copyToMemory s s.code)
  | 0x50 => -- POP
    let (_, s) ← s.pop
    let s ← s.charge Gas.base
    resume s.next
  | 0x51 => -- MLOAD
    let (start, s) ← s.pop
    let s ← s.chargeMemory Gas.veryLow [(start.toNat, 32)]
    let s ← s.push (Word.ofNat (Bytecode.bytesToNat (s.memory.read start.toNat 32)))
    resume s.next
  | 0x52 => -- MSTORE
    let (start, s) ← s.pop
    let (value, s) ← s.pop
    let s ← s.chargeMemory Gas.veryLow [(start.toNat, 32)]
    resume { s with memory := s.memory.write start.toNat (wordToBytes value) }.next
  | 0x53 => -- MSTORE8
    let (start, s) ← s.pop
    let (value, s) ← s.pop
    let s ← s.chargeMemory Gas.veryLow [(start.toNat, 1)]
    resume { s with memory := s.memory.write start.toNat #[UInt8.ofNat value.toNat] }.next
  | 0x54 => -- SLOAD
    let (key, s) ← s.pop
    let slot := key.toNat
    let s ← s.charge (sloadGas fork (!s.warm.contains slot))
    let s := { s with warm := s.warm.insert slot }
    let s ← s.push (s.storage.getD slot 0)
    resume s.next
  | 0x55 => do resume (← stepSstore s)
  | 0x56 => -- JUMP
    let (dest, s) ← s.pop
    let s ← s.charge Gas.mid
    if !s.jumpdests.getD dest.toNat false then throw .invalidJump
    resume { s with pc := dest.toNat }
  | 0x57 => -- JUMPI
    let (dest, s) ← s.pop
    let (condition, s) ← s.pop
    let s ← s.charge Gas.high
    if condition.toNat = 0 then resume s.next
    else
      if !s.jumpdests.getD dest.toNat false then throw .invalidJump
      resume { s with pc := dest.toNat }
  | 0x58 => -- PC
    let s ← s.charge Gas.base
    let s ← s.push (Word.ofNat s.pc)
    resume s.next
  | 0x59 => -- MSIZE
    let s ← s.charge Gas.base
    let s ← s.push (Word.ofNat s.memory.size)
    resume s.next
  | 0x5a => -- GAS: the gas left after paying for GAS itself
    let s ← s.charge Gas.base
    let s ← s.push (Word.ofNat s.gas)
    resume s.next
  | 0x5b => -- JUMPDEST
    let s ← s.charge Gas.jumpdest
    resume s.next
  | 0x5c => -- TLOAD (EIP-1153)
    if fork.isBefore .CANCUN then throw .invalidOpcode
    let (key, s) ← s.pop
    let s ← s.charge Gas.warmAccess
    let s ← s.push (s.transient.getD key.toNat 0)
    resume s.next
  | 0x5d => -- TSTORE (EIP-1153)
    if fork.isBefore .CANCUN then throw .invalidOpcode
    let (key, s) ← s.pop
    let (value, s) ← s.pop
    let s ← s.charge Gas.warmAccess
    resume { s with transient := s.transient.insert key.toNat value }.next
  | 0x5e => -- MCOPY (EIP-5656)
    if fork.isBefore .CANCUN then throw .invalidOpcode
    let (dest, s) ← s.pop
    let (source, s) ← s.pop
    let (length, s) ← s.pop
    let s ← s.chargeMemory (Gas.veryLow + Gas.copy * ceilWords length.toNat)
      [(source.toNat, length.toNat), (dest.toNat, length.toNat)]
    let bytes := s.memory.read source.toNat length.toNat
    resume { s with memory := s.memory.write dest.toNat bytes }.next
  | 0x5f => -- PUSH0 (EIP-3855)
    if fork.isBefore .SHANGHAI then throw .invalidOpcode
    let s ← s.charge Gas.base
    let s ← s.push 0
    resume s.next
  | 0xf3 => do -- RETURN
    let (output, s) ← haltWithOutput s
    pure (.returned output, s)
  | 0xfd => do -- REVERT (EIP-140)
    if fork.isBefore .BYZANTIUM then throw .invalidOpcode
    let (output, s) ← haltWithOutput s
    pure (.reverted output, s)
  | _ =>
    if unsupportedOpcode fork op then throw (.unsupported op) else throw .invalidOpcode

/-- Final status of a frame. -/
inductive Status where
  | stop | ret | revert
  | outOfGas | stackUnderflow | stackOverflow | invalidJump | invalidOpcode
  deriving Repr, DecidableEq

/-- Observable result of a frame. -/
structure Result where
  status : Status
  gasRemaining : Nat
  refund : Int
  output : Array UInt8

/-- Result of an exceptional halt: all gas is consumed and nothing is returned. -/
def Result.exceptional (status : Status) : Result :=
  { status, gasRemaining := 0, refund := 0, output := #[] }

/-- Run at most `fuel` steps. Running off the end of the code is a STOP. -/
def run : Nat → State → Except Nat Result
  | 0, _ => pure (.exceptional .outOfGas)
  | fuel + 1, s =>
    if s.pc ≥ s.code.size then
      pure { status := .stop, gasRemaining := s.gas, refund := s.refund, output := #[] }
    else
      match step s with
      | .ok (.running, s) => run fuel s
      | .ok (.stopped, s) =>
        pure { status := .stop, gasRemaining := s.gas, refund := s.refund, output := #[] }
      | .ok (.returned output, s) =>
        pure { status := .ret, gasRemaining := s.gas, refund := s.refund, output }
      | .ok (.reverted output, s) =>
        -- A revert discards the frame's refunds.
        pure { status := .revert, gasRemaining := s.gas, refund := 0, output }
      | .error .outOfGas => pure (.exceptional .outOfGas)
      | .error .stackUnderflow => pure (.exceptional .stackUnderflow)
      | .error .stackOverflow => pure (.exceptional .stackOverflow)
      | .error .invalidJump => pure (.exceptional .invalidJump)
      | .error .invalidOpcode => pure (.exceptional .invalidOpcode)
      | .error (.unsupported op) => throw op

/-- The `EXEC` oracle: run `code` with `gas` and `calldata` in a fresh frame.
`Except.error op` reports an opcode outside the single-frame model.

Every step that keeps running costs at least 1 gas, so `gas + 1` steps of fuel
never run out before the frame halts. -/
def exec (fork : Fork) (gas : Nat) (code : Code) (calldata : Array UInt8) : Except Nat Result :=
  run (gas + 1)
    { fork, code, calldata, gas, jumpdests := Bytecode.jumpdestTable code }

end EvmSpec

import EvmSpec.Word

/-!
# Bytecode analysis

JUMPDEST validity (Yellow Paper §9.4.3, EELS `vm/runtime.py`
`get_valid_jump_destinations`) and the PUSH immediate reader (EELS
`buffer_read`): bytes past the end of the code read as zero.
-/

namespace EvmSpec

/-- Contract code. -/
abbrev Code := Array UInt8

namespace Bytecode

/-- Number of immediate bytes that follow opcode `op`: `n` for `PUSHn`
(`0x60..0x7f`), `0` otherwise. -/
def immediateSize (op : UInt8) : Nat :=
  if 0x60 ≤ op.toNat ∧ op.toNat ≤ 0x7f then op.toNat - 0x5f else 0

/-- Scan `code` from position `pc`, where the next `skip` bytes are PUSH
immediates. Returns the positions of the JUMPDEST opcodes (`0x5b`) that are
instructions, in ascending order. -/
def scan : List UInt8 → Nat → Nat → List Nat
  | [], _, _ => []
  | _ :: rest, pc, skip + 1 => scan rest (pc + 1) skip
  | op :: rest, pc, 0 =>
    if op.toNat = 0x5b then pc :: scan rest (pc + 1) 0
    else scan rest (pc + 1) (immediateSize op)

/-- Valid jump destinations of `code` in ascending order. -/
def validJumpdests (code : Code) : List Nat := scan code.toList 0 0

/-- `validJumpdests` as a lookup table indexed by program counter. -/
def jumpdestTable (code : Code) : Array Bool :=
  (validJumpdests code).foldl (fun table pc => table.setIfInBounds pc true)
    (Array.replicate code.size false)

/-- `n` bytes of `data` starting at `start`, zero-padded on the right. -/
def readPadded (data : Array UInt8) (start n : Nat) : Array UInt8 :=
  Array.ofFn (n := n) fun i => data.getD (start + i.val) 0

/-- Big-endian value of a byte string. -/
def bytesToNat (bytes : Array UInt8) : Nat :=
  bytes.foldl (fun acc b => acc * 256 + b.toNat) 0

/-- Immediate of the `PUSHn` at `pc`: the `n` bytes at `pc + 1`, zero-padded on
the right when the code ends early. -/
def readPush (code : Code) (pc n : Nat) : Word :=
  Word.ofNat (bytesToNat (readPadded code (pc + 1) n))

end Bytecode
end EvmSpec

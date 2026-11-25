/-!
# 256-bit EVM word arithmetic

Pure semantics of the EVM arithmetic, comparison and bitwise opcodes, written
from the Yellow Paper (Appendix H.2), EELS `vm/instructions/{arithmetic,
comparison,bitwise}.py`, EIP-145 (shifts) and EIP-7939 (CLZ).

Argument order always follows the stack: the first argument is the top of the
stack (`μ_s[0]`), the second is `μ_s[1]`, the third is `μ_s[2]`.
-/

namespace EvmSpec

/-- An EVM machine word: an unsigned 256-bit integer. -/
abbrev Word := BitVec 256

namespace Word

/-- `2^256`, the word modulus. -/
def modulus : Nat := 2 ^ 256

/-- Truncating conversion from a natural number. -/
def ofNat (n : Nat) : Word := BitVec.ofNat 256 n

/-- Truncating conversion from a (two's complement) integer. -/
def ofInt (i : Int) : Word := BitVec.ofInt 256 i

/-- Two's complement interpretation in `[-2^255, 2^255)`. -/
def toInt (w : Word) : Int := BitVec.toInt w

/-- EVM booleans are the words `1` and `0`. -/
def ofBool (b : Bool) : Word := if b then 1 else 0

/-- `-2^255`, the most negative signed word. -/
def minSigned : Word := ofNat (2 ^ 255)

/-- `2^256 - 1`, which is `-1` as a signed word. -/
def allOnes : Word := ofNat (2 ^ 256 - 1)

/-! ## Arithmetic -/

/-- ADD (0x01): addition modulo `2^256`. -/
def add (a b : Word) : Word := a + b

/-- MUL (0x02): multiplication modulo `2^256`. -/
def mul (a b : Word) : Word := a * b

/-- SUB (0x03): `a - b` modulo `2^256`. -/
def sub (a b : Word) : Word := a - b

/-- DIV (0x04): unsigned floor division; division by zero yields `0`. -/
def div (a b : Word) : Word :=
  if b.toNat = 0 then 0 else ofNat (a.toNat / b.toNat)

/-- SDIV (0x05): signed division truncating toward zero; division by zero
yields `0`, and `-2^255 / -1` wraps to `-2^255`. -/
def sdiv (a b : Word) : Word :=
  if b.toNat = 0 then 0 else ofInt (Int.tdiv a.toInt b.toInt)

/-- MOD (0x06): unsigned remainder; modulo zero yields `0`. -/
def mod (a b : Word) : Word :=
  if b.toNat = 0 then 0 else ofNat (a.toNat % b.toNat)

/-- SMOD (0x07): signed remainder with the sign of the dividend; modulo zero
yields `0`. -/
def smod (a b : Word) : Word :=
  if b.toNat = 0 then 0 else ofInt (Int.tmod a.toInt b.toInt)

/-- ADDMOD (0x08): `(a + b) mod n` without intermediate truncation. -/
def addmod (a b n : Word) : Word :=
  if n.toNat = 0 then 0 else ofNat ((a.toNat + b.toNat) % n.toNat)

/-- MULMOD (0x09): `(a * b) mod n` without intermediate truncation. -/
def mulmod (a b n : Word) : Word :=
  if n.toNat = 0 then 0 else ofNat ((a.toNat * b.toNat) % n.toNat)

/-- Square-and-multiply modulo `2^256`. `fuel` bounds the exponent bit length. -/
def expLoop : Nat → Nat → Nat → Nat → Nat
  | 0, _, _, acc => acc
  | fuel + 1, base, e, acc =>
    if e = 0 then acc
    else
      expLoop fuel (base * base % modulus) (e / 2)
        (if e % 2 = 1 then acc * base % modulus else acc)

/-- EXP (0x0a): `base ^ exponent` modulo `2^256`. -/
def exp (base exponent : Word) : Word :=
  ofNat (expLoop 256 base.toNat exponent.toNat 1)

/-- Number of bytes in the minimal big-endian encoding of `n` (`0` for `0`). -/
def byteLength (n : Nat) : Nat :=
  if n = 0 then 0 else Nat.log2 n / 8 + 1

/-- Base gas of EXP (`G_exp`). -/
def expBaseGas : Nat := 10

/-- Per-exponent-byte gas of EXP: `10` before Spurious Dragon, `50` from
Spurious Dragon on (EIP-160). -/
def expByteGas (spuriousDragon : Bool) : Nat := if spuriousDragon then 50 else 10

/-- Total EXP gas: `10 + perByte * byteLength(exponent)`. -/
def expGas (spuriousDragon : Bool) (exponent : Word) : Nat :=
  expBaseGas + expByteGas spuriousDragon * byteLength exponent.toNat

/-- SIGNEXTEND (0x0b): extend the sign bit of byte `b` (0 = least significant)
of `x` through the high bytes. `b ≥ 31` leaves `x` unchanged. -/
def signextend (b x : Word) : Word :=
  if b.toNat ≥ 31 then x
  else
    let bits := 8 * b.toNat + 8
    let low := x.toNat % 2 ^ bits
    if x.toNat.testBit (bits - 1) then ofNat (low + (modulus - 2 ^ bits)) else ofNat low

/-! ## Comparison -/

/-- LT (0x10). -/
def lt (a b : Word) : Word := ofBool (decide (a.toNat < b.toNat))

/-- GT (0x11). -/
def gt (a b : Word) : Word := ofBool (decide (a.toNat > b.toNat))

/-- SLT (0x12). -/
def slt (a b : Word) : Word := ofBool (decide (a.toInt < b.toInt))

/-- SGT (0x13). -/
def sgt (a b : Word) : Word := ofBool (decide (a.toInt > b.toInt))

/-- EQ (0x14). -/
def eq (a b : Word) : Word := ofBool (a == b)

/-- ISZERO (0x15). -/
def iszero (a : Word) : Word := ofBool (decide (a.toNat = 0))

/-! ## Bitwise -/

/-- AND (0x16). -/
def and (a b : Word) : Word := a &&& b

/-- OR (0x17). -/
def or (a b : Word) : Word := a ||| b

/-- XOR (0x18). -/
def xor (a b : Word) : Word := a ^^^ b

/-- NOT (0x19). -/
def not (a : Word) : Word := ~~~a

/-- BYTE (0x1a): byte `i` of `x`, where byte 0 is the most significant.
`i ≥ 32` yields `0`. -/
def byte (i x : Word) : Word :=
  if i.toNat ≥ 32 then 0 else ofNat ((x.toNat >>> (8 * (31 - i.toNat))) % 256)

/-- SHL (0x1b, EIP-145): `value << shift`; shifts of 256 or more yield `0`. -/
def shl (shift value : Word) : Word :=
  if shift.toNat ≥ 256 then 0 else value <<< shift.toNat

/-- SHR (0x1c, EIP-145): logical `value >> shift`. -/
def shr (shift value : Word) : Word :=
  if shift.toNat ≥ 256 then 0 else value >>> shift.toNat

/-- SAR (0x1d, EIP-145): arithmetic `value >> shift`; shifts of 256 or more
yield `0` for non-negative values and `-1` for negative values. -/
def sar (shift value : Word) : Word :=
  if shift.toNat ≥ 256 then (if value.toInt < 0 then allOnes else 0)
  else BitVec.sshiftRight value shift.toNat

/-- Leading zero bits of a word as a natural number; `256` for zero. -/
def clzNat (x : Word) : Nat :=
  if x.toNat = 0 then 256 else 255 - Nat.log2 x.toNat

/-- CLZ (0x1e, EIP-7939, Osaka): count leading zero bits; `CLZ(0) = 256`. -/
def clz (x : Word) : Word := ofNat (clzNat x)

end Word
end EvmSpec

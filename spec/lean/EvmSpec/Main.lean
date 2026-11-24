import EvmSpec.Machine

/-!
# TSV oracle

Reads one tab-separated request per line from stdin and writes one
tab-separated response line to stdout, flushed after every line. The protocol
is `LEAN_PROTOCOL.md`: `WORD`, `MEMGAS`, `SSTORE`, `JUMPDEST`, `PUSH`,
`PRECOMPILE`, `EXEC`, `QUIT`.
-/

namespace EvmSpec.Oracle

open EvmSpec

/-- Value of a hex digit (either case). -/
def hexDigit? (c : Char) : Option Nat :=
  if '0' ≤ c ∧ c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c ∧ c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c ∧ c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

/-- Parse a non-empty hex string without `0x`. -/
def parseHex? (s : String) : Option Nat :=
  if s.isEmpty then none
  else s.toList.foldlM (fun acc c => (hexDigit? c).map (acc * 16 + ·)) 0

/-- Parse a `u256`: 1 to 64 hex digits. -/
def parseWord? (s : String) : Option Word :=
  if s.length > 64 then none else (parseHex? s).map Word.ofNat

/-- Parse a decimal `u64`. -/
def parseU64? (s : String) : Option Nat :=
  match s.toNat? with
  | some n => if n ≤ u64Max then some n else none
  | none => none

/-- Parse a byte string: `-` for empty, otherwise an even number of hex digits. -/
def parseBytes? (s : String) : Option (Array UInt8) :=
  if s == "-" then some #[]
  else
    let rec go : List Char → Array UInt8 → Option (Array UInt8)
      | [], acc => some acc
      | [_], _ => none
      | hi :: lo :: rest, acc => do
        let h ← hexDigit? hi
        let l ← hexDigit? lo
        go rest (acc.push (UInt8.ofNat (h * 16 + l)))
    go s.toList #[]

/-- Parse `0` or `1`. -/
def parseBit? : String → Option Bool
  | "0" => some false
  | "1" => some true
  | _ => none

/-- Lowercase hex without leading zeros; `0` for zero. -/
def hex (n : Nat) : String := String.ofList (Nat.toDigits 16 n)

/-- Lowercase hex of a byte string; `-` for empty. -/
def hexBytes (bytes : Array UInt8) : String :=
  if bytes.isEmpty then "-"
  else
    let digit (n : Nat) : Char := Nat.digitChar n
    String.ofList (bytes.foldr (fun b acc => digit (b.toNat / 16) :: digit (b.toNat % 16) :: acc) [])

def bit (b : Bool) : String := if b then "1" else "0"

def Status.name : Status → String
  | .stop => "STOP" | .ret => "RETURN" | .revert => "REVERT"
  | .outOfGas => "OOG" | .stackUnderflow => "STACK_UNDERFLOW"
  | .stackOverflow => "STACK_OVERFLOW" | .invalidJump => "INVALID_JUMP"
  | .invalidOpcode => "INVALID_OPCODE"

def tsv (fields : List String) : String := "\t".intercalate fields

def badRequest : String := "ERR\tBadRequest"

/-- Answer one request. `none` means `QUIT`. -/
def respond (fields : List String) : Option String :=
  match fields with
  | ["QUIT"] => none
  | ["WORD", fork, op, a, b, c] => some <| Option.getD (do
      let fork ← Fork.ofString? fork
      let op ← if op.length = 2 then parseHex? op else none
      let a ← parseWord? a
      let b ← parseWord? b
      let c ← parseWord? c
      pure <| match evalWordOp fork op a b c with
        | some (result, gas) => tsv ["OK", hex result.toNat, toString gas]
        | none => "ERR\tInvalidOpcode") badRequest
  | ["MEMGAS", current, stop] => some <| Option.getD (do
      let current ← parseU64? current
      let stop ← parseU64? stop
      pure (tsv ["OK", toString (memoryExpansionCostU64 current stop)])) badRequest
  | ["SSTORE", fork, original, current, new, cold, gas] => some <| Option.getD (do
      let fork ← Fork.ofString? fork
      let original ← parseWord? original
      let current ← parseWord? current
      let new ← parseWord? new
      let cold ← parseBit? cold
      let gas ← parseU64? gas
      pure <| match sstore fork original current new cold gas with
        | some (cost, refund) => tsv ["OK", toString cost, toString refund]
        | none => "ERR\tOutOfGas") badRequest
  | ["JUMPDEST", code] => some <| Option.getD (do
      let code ← parseBytes? code
      let dests := Bytecode.validJumpdests code
      pure (tsv ["OK", if dests.isEmpty then "-" else ",".intercalate (dests.map toString)]))
      badRequest
  | ["PUSH", code, pc, size] => some <| Option.getD (do
      let code ← parseBytes? code
      let pc ← parseU64? pc
      let size ← parseU64? size
      if size < 1 ∨ size > 32 then none
      pure (tsv ["OK", hex (Bytecode.readPush code pc size).toNat])) badRequest
  | ["PRECOMPILE", fork, address, gasLimit] => some <| Option.getD (do
      let fork ← Fork.ofString? fork
      let address ← parseWord? address
      let gasLimit ← parseU64? gasLimit
      pure (tsv ["OK", bit (isPrecompile fork address.toNat), bit (txGasAllowed fork gasLimit)]))
      badRequest
  | ["EXEC", fork, gas, code, calldata] => some <| Option.getD (do
      let fork ← Fork.ofString? fork
      let gas ← parseU64? gas
      let code ← parseBytes? code
      let calldata ← parseBytes? calldata
      pure <| match exec fork gas code calldata with
        | .ok r => tsv ["OK", Status.name r.status, toString r.gasRemaining,
            toString r.refund, hexBytes r.output]
        | .error op => tsv ["ERR", "UnsupportedOpcode", hex op]) badRequest
  | _ => some badRequest

/-- Drop one trailing `\n` and one trailing `\r`. -/
def chomp (line : String) : String :=
  let line := if line.endsWith "\n" then (line.dropEnd 1).toString else line
  if line.endsWith "\r" then (line.dropEnd 1).toString else line

partial def loop (stdin stdout : IO.FS.Stream) : IO Unit := do
  let line ← stdin.getLine
  if line.isEmpty then return
  match respond ((chomp line).splitOn "\t") with
  | none => return
  | some response =>
    stdout.putStrLn response
    stdout.flush
    loop stdin stdout

end EvmSpec.Oracle

def main : IO UInt32 := do
  EvmSpec.Oracle.loop (← IO.getStdin) (← IO.getStdout)
  return 0

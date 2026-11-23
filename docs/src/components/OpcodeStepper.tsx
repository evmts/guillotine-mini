'use client'

/**
 * A dependency-free bytecode stepper.
 *
 * It interprets a useful subset of the EVM — arithmetic, comparison, bitwise,
 * stack shuffling, memory, storage, jumps and the halting opcodes — with the
 * Berlin-and-later gas schedule (including memory expansion and warm/cold
 * storage access). It is a teaching aid for reading the real interpreter in
 * `src/frame.zig`, not a second implementation of consensus.
 */

import { useCallback, useMemo, useState } from 'react'

const MOD = 1n << 256n
const MAX = MOD - 1n

const asWord = (x: bigint) => ((x % MOD) + MOD) % MOD
const toSigned = (x: bigint) => (x >= 1n << 255n ? x - MOD : x)
const toUnsigned = (x: bigint) => asWord(x)

type Op = {
	name: string
	/** Number of immediate bytes following the opcode (PUSH1..PUSH32). */
	push?: number
	/** Static gas cost. Dynamic components are added by the executor. */
	gas: number
	pops: number
	pushes: number
}

const OPS: Record<number, Op> = {
	0x00: { name: 'STOP', gas: 0, pops: 0, pushes: 0 },
	0x01: { name: 'ADD', gas: 3, pops: 2, pushes: 1 },
	0x02: { name: 'MUL', gas: 5, pops: 2, pushes: 1 },
	0x03: { name: 'SUB', gas: 3, pops: 2, pushes: 1 },
	0x04: { name: 'DIV', gas: 5, pops: 2, pushes: 1 },
	0x05: { name: 'SDIV', gas: 5, pops: 2, pushes: 1 },
	0x06: { name: 'MOD', gas: 5, pops: 2, pushes: 1 },
	0x07: { name: 'SMOD', gas: 5, pops: 2, pushes: 1 },
	0x08: { name: 'ADDMOD', gas: 8, pops: 3, pushes: 1 },
	0x09: { name: 'MULMOD', gas: 8, pops: 3, pushes: 1 },
	0x0a: { name: 'EXP', gas: 10, pops: 2, pushes: 1 },
	0x10: { name: 'LT', gas: 3, pops: 2, pushes: 1 },
	0x11: { name: 'GT', gas: 3, pops: 2, pushes: 1 },
	0x12: { name: 'SLT', gas: 3, pops: 2, pushes: 1 },
	0x13: { name: 'SGT', gas: 3, pops: 2, pushes: 1 },
	0x14: { name: 'EQ', gas: 3, pops: 2, pushes: 1 },
	0x15: { name: 'ISZERO', gas: 3, pops: 1, pushes: 1 },
	0x16: { name: 'AND', gas: 3, pops: 2, pushes: 1 },
	0x17: { name: 'OR', gas: 3, pops: 2, pushes: 1 },
	0x18: { name: 'XOR', gas: 3, pops: 2, pushes: 1 },
	0x19: { name: 'NOT', gas: 3, pops: 1, pushes: 1 },
	0x1a: { name: 'BYTE', gas: 3, pops: 2, pushes: 1 },
	0x1b: { name: 'SHL', gas: 3, pops: 2, pushes: 1 },
	0x1c: { name: 'SHR', gas: 3, pops: 2, pushes: 1 },
	0x50: { name: 'POP', gas: 2, pops: 1, pushes: 0 },
	0x51: { name: 'MLOAD', gas: 3, pops: 1, pushes: 1 },
	0x52: { name: 'MSTORE', gas: 3, pops: 2, pushes: 0 },
	0x53: { name: 'MSTORE8', gas: 3, pops: 2, pushes: 0 },
	0x54: { name: 'SLOAD', gas: 0, pops: 1, pushes: 1 },
	0x55: { name: 'SSTORE', gas: 0, pops: 2, pushes: 0 },
	0x56: { name: 'JUMP', gas: 8, pops: 1, pushes: 0 },
	0x57: { name: 'JUMPI', gas: 10, pops: 2, pushes: 0 },
	0x58: { name: 'PC', gas: 2, pops: 0, pushes: 1 },
	0x59: { name: 'MSIZE', gas: 2, pops: 0, pushes: 1 },
	0x5a: { name: 'GAS', gas: 2, pops: 0, pushes: 1 },
	0x5b: { name: 'JUMPDEST', gas: 1, pops: 0, pushes: 0 },
	0xf3: { name: 'RETURN', gas: 0, pops: 2, pushes: 0 },
	0xfd: { name: 'REVERT', gas: 0, pops: 2, pushes: 0 },
	0xfe: { name: 'INVALID', gas: 0, pops: 0, pushes: 0 },
}

// PUSH0..PUSH32, DUP1..DUP16, SWAP1..SWAP16 are regular enough to generate.
OPS[0x5f] = { name: 'PUSH0', push: 0, gas: 2, pops: 0, pushes: 1 }
for (let n = 1; n <= 32; n++)
	OPS[0x5f + n] = { name: `PUSH${n}`, push: n, gas: 3, pops: 0, pushes: 1 }
for (let n = 1; n <= 16; n++)
	OPS[0x7f + n] = { name: `DUP${n}`, gas: 3, pops: n, pushes: n + 1 }
for (let n = 1; n <= 16; n++)
	OPS[0x8f + n] = { name: `SWAP${n}`, gas: 3, pops: n + 1, pushes: n + 1 }

type Instruction = {
	pc: number
	opcode: number
	name: string
	arg?: bigint
	size: number
}

export function disassemble(code: Uint8Array): Instruction[] {
	const out: Instruction[] = []
	let pc = 0
	while (pc < code.length) {
		const opcode = code[pc] as number
		const op = OPS[opcode]
		if (!op) {
			out.push({ pc, opcode, name: `INVALID (0x${opcode.toString(16).padStart(2, '0')})`, size: 1 })
			pc += 1
			continue
		}
		const n = op.push ?? 0
		let arg: bigint | undefined
		if (n > 0) {
			let v = 0n
			for (let i = 0; i < n; i++) v = (v << 8n) | BigInt(code[pc + 1 + i] ?? 0)
			arg = v
		}
		out.push({ pc, opcode, name: op.name, arg, size: 1 + n })
		pc += 1 + n
	}
	return out
}

type State = {
	pc: number
	stack: bigint[]
	memory: Uint8Array
	storage: Map<string, bigint>
	warmSlots: Set<string>
	gasLeft: number
	gasUsed: number
	halted: false | 'stop' | 'return' | 'revert' | 'error'
	message?: string
	returnData?: Uint8Array
	lastGas?: number
	lastNote?: string
}

export function initialState(gasLimit: number): State {
	return {
		pc: 0,
		stack: [],
		memory: new Uint8Array(0),
		storage: new Map(),
		warmSlots: new Set(),
		gasLeft: gasLimit,
		gasUsed: 0,
		halted: false,
	}
}

const memoryCost = (words: number) => 3 * words + Math.floor((words * words) / 512)

/** Grow `memory` so `[offset, offset+size)` is addressable; return the gas delta. */
function expand(state: { memory: Uint8Array }, offset: number, size: number) {
	if (size === 0) return 0
	const needed = offset + size
	if (needed <= state.memory.length) return 0
	const oldWords = Math.ceil(state.memory.length / 32)
	const newWords = Math.ceil(needed / 32)
	const next = new Uint8Array(newWords * 32)
	next.set(state.memory)
	state.memory = next
	return memoryCost(newWords) - memoryCost(oldWords)
}

function readWord(mem: Uint8Array, offset: number): bigint {
	let v = 0n
	for (let i = 0; i < 32; i++) v = (v << 8n) | BigInt(mem[offset + i] ?? 0)
	return v
}

function writeWord(mem: Uint8Array, offset: number, value: bigint) {
	for (let i = 31; i >= 0; i--) {
		mem[offset + i] = Number(value & 0xffn)
		value >>= 8n
	}
}

/** Valid JUMPDESTs, excluding bytes that are PUSH immediates. */
export function jumpdests(code: Uint8Array): Set<number> {
	const set = new Set<number>()
	let pc = 0
	while (pc < code.length) {
		const opcode = code[pc] as number
		if (opcode === 0x5b) set.add(pc)
		const n = OPS[opcode]?.push ?? 0
		pc += 1 + n
	}
	return set
}

/** Execute exactly one instruction, returning the next state. Never mutates. */
export function step(code: Uint8Array, prev: State, dests: Set<number>): State {
	const s: State = {
		...prev,
		stack: [...prev.stack],
		memory: prev.memory.slice(),
		storage: new Map(prev.storage),
		warmSlots: new Set(prev.warmSlots),
		lastGas: undefined,
		lastNote: undefined,
		message: undefined,
	}
	if (s.halted) return prev
	if (s.pc >= code.length) {
		s.halted = 'stop'
		s.message = 'Ran off the end of the code — implicit STOP.'
		return s
	}

	const opcode = code[s.pc] as number
	const op = OPS[opcode]
	if (!op || op.name === 'INVALID') {
		s.halted = 'error'
		s.message = `Undefined opcode 0x${opcode.toString(16).padStart(2, '0')} — consumes all remaining gas.`
		s.gasUsed += s.gasLeft
		s.gasLeft = 0
		return s
	}
	if (s.stack.length < op.pops) {
		s.halted = 'error'
		s.message = `Stack underflow: ${op.name} needs ${op.pops} item(s), stack has ${s.stack.length}.`
		s.gasUsed += s.gasLeft
		s.gasLeft = 0
		return s
	}

	let gas = op.gas
	let note = ''
	const pop = () => s.stack.pop() as bigint
	const push = (v: bigint) => {
		if (s.stack.length >= 1024) throw new Error('stack overflow (1024 items)')
		s.stack.push(asWord(v))
	}
	let nextPc = s.pc + 1 + (op.push ?? 0)

	try {
		switch (op.name) {
			case 'STOP':
				s.halted = 'stop'
				note = 'Halts successfully with empty return data.'
				break
			case 'ADD': push(pop() + pop()); break
			case 'MUL': push(pop() * pop()); break
			case 'SUB': { const a = pop(), b = pop(); push(a - b); break }
			case 'DIV': { const a = pop(), b = pop(); push(b === 0n ? 0n : a / b); break }
			case 'SDIV': {
				const a = toSigned(pop()), b = toSigned(pop())
				push(b === 0n ? 0n : toUnsigned(a / b))
				break
			}
			case 'MOD': { const a = pop(), b = pop(); push(b === 0n ? 0n : a % b); break }
			case 'SMOD': {
				const a = toSigned(pop()), b = toSigned(pop())
				push(b === 0n ? 0n : toUnsigned(a % b))
				break
			}
			case 'ADDMOD': { const a = pop(), b = pop(), n = pop(); push(n === 0n ? 0n : (a + b) % n); break }
			case 'MULMOD': { const a = pop(), b = pop(), n = pop(); push(n === 0n ? 0n : (a * b) % n); break }
			case 'EXP': {
				const base = pop(), exp = pop()
				const bytes = exp === 0n ? 0 : Math.ceil(exp.toString(16).length / 2)
				gas += 50 * bytes
				note = `Dynamic gas: 50 × ${bytes} exponent byte(s).`
				let r = 1n, b = base % MOD, e = exp
				while (e > 0n) {
					if (e & 1n) r = (r * b) % MOD
					b = (b * b) % MOD
					e >>= 1n
				}
				push(r)
				break
			}
			case 'LT': { const a = pop(), b = pop(); push(a < b ? 1n : 0n); break }
			case 'GT': { const a = pop(), b = pop(); push(a > b ? 1n : 0n); break }
			case 'SLT': { const a = toSigned(pop()), b = toSigned(pop()); push(a < b ? 1n : 0n); break }
			case 'SGT': { const a = toSigned(pop()), b = toSigned(pop()); push(a > b ? 1n : 0n); break }
			case 'EQ': { const a = pop(), b = pop(); push(a === b ? 1n : 0n); break }
			case 'ISZERO': push(pop() === 0n ? 1n : 0n); break
			case 'AND': push(pop() & pop()); break
			case 'OR': push(pop() | pop()); break
			case 'XOR': push(pop() ^ pop()); break
			case 'NOT': push(MAX ^ pop()); break
			case 'BYTE': { const i = pop(), x = pop(); push(i > 31n ? 0n : (x >> (8n * (31n - i))) & 0xffn); break }
			case 'SHL': { const sh = pop(), v = pop(); push(sh > 255n ? 0n : v << sh); break }
			case 'SHR': { const sh = pop(), v = pop(); push(sh > 255n ? 0n : v >> sh); break }
			case 'POP': pop(); break
			case 'MLOAD': {
				const off = Number(pop())
				gas += expand(s, off, 32)
				push(readWord(s.memory, off))
				note = 'Reads 32 bytes; memory expansion is charged quadratically.'
				break
			}
			case 'MSTORE': {
				const off = Number(pop()), val = pop()
				gas += expand(s, off, 32)
				writeWord(s.memory, off, val)
				note = 'Writes 32 bytes at the offset, growing memory in 32-byte words.'
				break
			}
			case 'MSTORE8': {
				const off = Number(pop()), val = pop()
				gas += expand(s, off, 1)
				s.memory[off] = Number(val & 0xffn)
				break
			}
			case 'SLOAD': {
				const key = pop().toString()
				const warm = s.warmSlots.has(key)
				gas += warm ? 100 : 2100
				s.warmSlots.add(key)
				push(s.storage.get(key) ?? 0n)
				note = warm ? 'Warm slot: 100 gas (EIP-2929).' : 'Cold slot: 2100 gas (EIP-2929).'
				break
			}
			case 'SSTORE': {
				const key = pop().toString()
				const val = pop()
				const warm = s.warmSlots.has(key)
				if (!warm) gas += 2100
				s.warmSlots.add(key)
				const current = s.storage.get(key) ?? 0n
				if (current === val) {
					gas += 100
					note = 'No-op write: 100 gas.'
				} else if (current === 0n) {
					gas += 20000
					note = 'Zero → non-zero: 20000 gas (a new storage slot).'
				} else {
					gas += 2900
					note = 'Non-zero → different value: 2900 gas.'
				}
				if (!warm) note += ' Plus a 2100 cold-slot surcharge.'
				s.storage.set(key, val)
				break
			}
			case 'JUMP': {
				const dest = Number(pop())
				if (!dests.has(dest)) throw new Error(`invalid jump destination ${dest} (not a JUMPDEST)`)
				nextPc = dest
				note = 'Jumps only to a JUMPDEST — checked before the jump is taken.'
				break
			}
			case 'JUMPI': {
				const dest = Number(pop()), cond = pop()
				if (cond !== 0n) {
					if (!dests.has(dest)) throw new Error(`invalid jump destination ${dest} (not a JUMPDEST)`)
					nextPc = dest
					note = 'Condition is non-zero — branch taken.'
				} else {
					note = 'Condition is zero — falls through.'
				}
				break
			}
			case 'PC': push(BigInt(s.pc)); break
			case 'MSIZE': push(BigInt(s.memory.length)); break
			case 'GAS': push(BigInt(Math.max(s.gasLeft - gas, 0))); break
			case 'JUMPDEST': note = 'A no-op marker: the only legal target of a jump.'; break
			case 'RETURN':
			case 'REVERT': {
				const off = Number(pop()), size = Number(pop())
				gas += expand(s, off, size)
				s.returnData = s.memory.slice(off, off + size)
				s.halted = op.name === 'RETURN' ? 'return' : 'revert'
				note =
					op.name === 'RETURN'
						? 'Halts successfully, returning a memory slice.'
						: 'Halts, reverting state changes and refunding the remaining gas.'
				break
			}
			default: {
				if (op.name.startsWith('PUSH')) {
					const n = op.push ?? 0
					let v = 0n
					for (let i = 0; i < n; i++) v = (v << 8n) | BigInt(code[s.pc + 1 + i] ?? 0)
					push(v)
				} else if (op.name.startsWith('DUP')) {
					const n = Number(op.name.slice(3))
					push(s.stack[s.stack.length - n] as bigint)
				} else if (op.name.startsWith('SWAP')) {
					const n = Number(op.name.slice(4))
					const top = s.stack.length - 1
					const other = top - n
					const tmp = s.stack[top] as bigint
					s.stack[top] = s.stack[other] as bigint
					s.stack[other] = tmp
				} else {
					throw new Error(`${op.name} is not implemented in this explorer`)
				}
			}
		}
	} catch (err) {
		s.halted = 'error'
		s.message = err instanceof Error ? err.message : String(err)
		s.gasUsed += s.gasLeft
		s.gasLeft = 0
		return s
	}

	if (gas > s.gasLeft) {
		s.halted = 'error'
		s.message = `Out of gas: ${op.name} costs ${gas}, only ${s.gasLeft} left.`
		s.gasUsed += s.gasLeft
		s.gasLeft = 0
		return s
	}

	s.gasLeft -= gas
	s.gasUsed += gas
	s.lastGas = gas
	s.lastNote = note
	if (!s.halted) s.pc = nextPc
	return s
}

export const EXAMPLES = [
	{
		id: 'return-42',
		label: 'Return 42',
		code: '602a60005260206000f3',
		blurb:
			'The smallest interesting program: store 42 in memory, then return those 32 bytes. This is the sample on the front page.',
	},
	{
		id: 'arith',
		label: 'Arithmetic + stack',
		code: '600a60030260059003600052 60206000f3'.replace(/ /g, ''),
		blurb: 'MUL, then SWAP1 + SUB to subtract in the other direction: 3 × 10 − 5 = 25 (0x19).',
	},
	{
		id: 'loop',
		label: 'Loop (sum 1..5)',
		code: '600060055b801560155780910190600190036004565b5060005260206000f3',
		blurb:
			'A JUMPDEST-guarded countdown that accumulates 5+4+3+2+1 = 15 (0xf). JUMPI branches out once the counter hits zero.',
	},
	{
		id: 'storage',
		label: 'Cold vs warm storage',
		code: '600160005560026000556000546000526 0206000f3'.replace(/ /g, ''),
		blurb:
			'Two SSTOREs to the same slot: the first pays the cold surcharge plus 20000 for zero → non-zero, the second only 2900.',
	},
	{
		id: 'revert',
		label: 'Revert',
		code: '60426000526020600 0fd'.replace(/ /g, ''),
		blurb: 'REVERT halts with return data but undoes state changes.',
	},
	{
		id: 'oog',
		label: 'Out of gas',
		code: '600160005560026001556003600255600460035560056004556006600555',
		blurb: 'Five cold storage writes against a small gas limit — set gas low and watch it die.',
	},
] as const

function parseCode(input: string): { code?: Uint8Array; error?: string } {
	const hex = input.trim().replace(/^0x/i, '').replace(/\s+/g, '')
	if (hex.length === 0) return { code: new Uint8Array(0) }
	if (!/^[0-9a-fA-F]*$/.test(hex)) return { error: 'Bytecode must be hex digits only.' }
	if (hex.length % 2 !== 0) return { error: 'Bytecode must have an even number of hex digits.' }
	const code = new Uint8Array(hex.length / 2)
	for (let i = 0; i < code.length; i++) code[i] = Number.parseInt(hex.slice(i * 2, i * 2 + 2), 16)
	return { code }
}

const hexWord = (v: bigint) => `0x${v.toString(16)}`

const toHex = (bytes: Uint8Array) =>
	`0x${Array.from(bytes)
		.map((b) => b.toString(16).padStart(2, '0'))
		.join('')}`

export function OpcodeStepper() {
	const [source, setSource] = useState<string>(EXAMPLES[0].code)
	const [gasLimit, setGasLimit] = useState<number>(100_000)
	const [exampleId, setExampleId] = useState<string>(EXAMPLES[0].id)
	const [state, setState] = useState<State>(() => initialState(100_000))

	const parsed = useMemo(() => parseCode(source), [source])
	const code = parsed.code ?? new Uint8Array(0)
	const instructions = useMemo(() => disassemble(code), [code])
	const dests = useMemo(() => jumpdests(code), [code])
	const example = EXAMPLES.find((e) => e.id === exampleId)

	const reset = useCallback((limit = gasLimit) => setState(initialState(limit)), [gasLimit])

	const doStep = useCallback(() => {
		setState((prev) => step(code, prev, dests))
	}, [code, dests])

	const runToEnd = useCallback(() => {
		setState((prev) => {
			let cur = prev
			// Bounded so a mistyped loop cannot hang the page.
			for (let i = 0; i < 10_000 && !cur.halted; i++) cur = step(code, cur, dests)
			if (!cur.halted) return { ...cur, halted: 'error', message: 'Stopped after 10,000 steps.' }
			return cur
		})
	}, [code, dests])

	const onPickExample = (id: string) => {
		const next = EXAMPLES.find((e) => e.id === id)
		if (!next) return
		setExampleId(id)
		setSource(next.code)
		setState(initialState(gasLimit))
	}

	const onGasChange = (value: string) => {
		const n = Number.parseInt(value, 10)
		const limit = Number.isFinite(n) && n > 0 ? n : 0
		setGasLimit(limit)
		setState(initialState(limit))
	}

	const halted = state.halted

	return (
		<div className="gm-stepper">
			<div className="gm-stepper-bar">
				<select
					aria-label="Example program"
					value={exampleId}
					onChange={(e) => onPickExample(e.target.value)}
				>
					{EXAMPLES.map((e) => (
						<option key={e.id} value={e.id}>
							{e.label}
						</option>
					))}
				</select>
				<input
					aria-label="Bytecode (hex)"
					spellCheck={false}
					value={source}
					onChange={(e) => {
						setSource(e.target.value)
						setState(initialState(gasLimit))
					}}
				/>
				<input
					aria-label="Gas limit"
					style={{ flex: '0 0 7rem' }}
					value={String(gasLimit)}
					onChange={(e) => onGasChange(e.target.value)}
				/>
				<button type="button" className="gm-btn gm-btn--primary" onClick={doStep} disabled={!!halted}>
					Step
				</button>
				<button type="button" className="gm-btn" onClick={runToEnd} disabled={!!halted}>
					Run
				</button>
				<button type="button" className="gm-btn" onClick={() => reset()}>
					Reset
				</button>
			</div>

			<div className="gm-stepper-body">
				<div className="gm-pane">
					<p className="gm-pane-title">Bytecode</p>
					{parsed.error ? (
						<p className="gm-note gm-note--error">{parsed.error}</p>
					) : instructions.length === 0 ? (
						<p className="gm-empty">Paste some hex bytecode to disassemble it.</p>
					) : (
						<div className="gm-code">
							{instructions.map((ins) => (
								<div
									key={ins.pc}
									className="gm-row"
									data-current={!halted && ins.pc === state.pc}
									data-done={ins.pc < state.pc}
								>
									<span className="gm-pc">{ins.pc.toString().padStart(3, '0')}</span>
									<span className="gm-mnemonic">{ins.name}</span>
									<span className="gm-arg">{ins.arg === undefined ? '' : hexWord(ins.arg)}</span>
									<span className="gm-gas">{OPS[ins.opcode]?.gas ? `${OPS[ins.opcode]?.gas}g` : ''}</span>
								</div>
							))}
						</div>
					)}
				</div>

				<div className="gm-pane">
					<div className="gm-meters">
						<div className="gm-meter">
							<span className="gm-meter-label">Gas used</span>
							<span className="gm-meter-value">{state.gasUsed.toLocaleString()}</span>
						</div>
						<div className="gm-meter">
							<span className="gm-meter-label">Gas left</span>
							<span className="gm-meter-value">{state.gasLeft.toLocaleString()}</span>
						</div>
						<div className="gm-meter">
							<span className="gm-meter-label">Memory</span>
							<span className="gm-meter-value">{state.memory.length}b</span>
						</div>
					</div>

					<p className="gm-pane-title">Stack (top first)</p>
					<div className="gm-stack">
						{state.stack.length === 0 ? (
							<p className="gm-empty">empty</p>
						) : (
							state.stack.map((v, i) => (
								<div
									key={`${i}-${v}`}
									className="gm-stack-item"
									data-top={i === state.stack.length - 1}
								>
									<span className="gm-stack-index">{state.stack.length - 1 - i}</span>
									<span className="gm-stack-value">{hexWord(v)}</span>
								</div>
							))
						)}
					</div>

					{state.storage.size > 0 && (
						<>
							<p className="gm-pane-title" style={{ marginTop: '0.75rem' }}>
								Storage
							</p>
							<div className="gm-stack" style={{ flexDirection: 'column' }}>
								{[...state.storage.entries()].map(([k, v]) => (
									<div key={k} className="gm-stack-item">
										<span className="gm-stack-index">{hexWord(BigInt(k))}</span>
										<span className="gm-stack-value">{hexWord(v)}</span>
									</div>
								))}
							</div>
						</>
					)}

					{(state.lastNote || state.message) && (
						<p className={`gm-note${halted === 'error' || halted === 'revert' ? ' gm-note--error' : ''}`}>
							{state.message ?? state.lastNote}
							{state.lastGas !== undefined && !state.message ? ` (${state.lastGas} gas)` : ''}
						</p>
					)}

					{halted && (
						<p className="gm-return">
							halted: {halted}
							{state.returnData ? ` · return data ${toHex(state.returnData)}` : ''}
						</p>
					)}
				</div>
			</div>

			{example && (
				<p className="gm-note" style={{ margin: 0, borderLeft: 'none', background: 'transparent' }}>
					{example.blurb}
				</p>
			)}
		</div>
	)
}

export default OpcodeStepper

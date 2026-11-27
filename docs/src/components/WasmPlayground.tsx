'use client'

import { useCallback, useEffect, useMemo, useRef, useState } from 'react'

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface WasmEvmExports extends WebAssembly.Exports {
	memory: WebAssembly.Memory
	_initialize?: () => void
	evm_alloc: (len: number) => number
	evm_free: (ptr: number, len: number) => void
	evm_create: (namePtr: number, nameLen: number, logLevel: number) => number
	evm_destroy: (handle: number) => void
	evm_set_bytecode: (handle: number, codePtr: number, codeLen: number) => number
	evm_set_execution_context: (
		handle: number,
		gas: bigint,
		callerPtr: number,
		addrPtr: number,
		valuePtr: number,
		calldataPtr: number,
		calldataLen: number,
	) => number
	evm_set_blockchain_context: (
		handle: number,
		chainIdPtr: number,
		blockNumber: bigint,
		blockTimestamp: bigint,
		difficultyPtr: number,
		prevrandaoPtr: number,
		coinbasePtr: number,
		blockGasLimit: bigint,
		baseFeePtr: number,
		blobBaseFeePtr: number,
	) => number
	evm_execute: (handle: number) => number
	evm_get_gas_remaining: (handle: number) => bigint
	evm_get_gas_used: (handle: number) => bigint
	evm_get_gas_refund?: (handle: number) => bigint
	evm_is_success: (handle: number) => number
	evm_get_output_len: (handle: number) => number
	evm_get_output: (handle: number, bufPtr: number, bufLen: number) => number
	evm_set_code: (handle: number, addrPtr: number, codePtr: number, codeLen: number) => number
	evm_set_storage: (handle: number, addrPtr: number, slotPtr: number, valPtr: number) => number
	evm_set_balance: (handle: number, addrPtr: number, balPtr: number) => number
	evm_enable_storage_injector: (handle: number) => number
	evm_call_ffi: (handle: number, reqPtr: number) => number
	evm_continue_ffi: (
		handle: number,
		continueType: number,
		dataPtr: number,
		dataLen: number,
		reqPtr: number,
	) => number
	evm_get_state_changes_len: (handle: number) => number
	evm_get_state_changes: (handle: number, bufPtr: number, bufLen: number) => number
	evm_enable_tracing: (
		handle: number,
		enableMemory: number,
		disableStack: number,
		disableStorage: number,
		enableReturnData: number,
	) => void
	evm_get_trace_json_len: (handle: number) => number
	evm_get_trace_json: (handle: number, bufPtr: number, bufLen: number) => number
	evm_enable_call_tracer: (handle: number, onlyTopCall: number, withLog: number) => void
	evm_get_call_trace_json_len: (handle: number) => number
	evm_get_call_trace_json: (handle: number, bufPtr: number, bufLen: number) => number
	evm_enable_access_list_tracker: (handle: number) => void
	evm_get_access_list_json_len: (handle: number) => number
	evm_get_access_list_json: (handle: number, bufPtr: number, bufLen: number) => number
	evm_enable_flamegraph?: (handle: number, compactAddresses: number) => number
	evm_get_flamegraph_svg_len?: (handle: number) => number
	evm_get_flamegraph_svg?: (handle: number, bufPtr: number, bufLen: number) => number
	evm_get_flamegraph_folded_len?: (handle: number) => number
	evm_get_flamegraph_folded?: (handle: number, bufPtr: number, bufLen: number) => number
	evm_decode_revert_json_len?: (handle: number) => number
	evm_decode_revert_json?: (handle: number, bufPtr: number, bufLen: number) => number
}

interface TraceStepEntry {
	pc: number
	op: number
	opName: string
	gas: string
	gasCost: string
	depth: number
	memSize: number
	memory?: string | null
	stack: string[]
	returnData?: string | null
	refund: number
	storage?: Record<string, string>
	error?: string
}

interface CallTraceLog {
	address: string
	topics: string[]
	data: string
	position?: string
}

interface CallTraceNode {
	type: string
	from: string
	to?: string
	value?: string
	gas: string
	gasUsed: string
	input: string
	output?: string
	error?: string
	revertReason?: string
	logs?: CallTraceLog[]
	calls?: CallTraceNode[]
}

interface DecodedRevert {
	kind: 'error' | 'panic' | 'custom' | 'raw' | 'halt'
	selector?: string
	reason?: string
	code?: string
	description?: string
	error?: string
	raw: string
}

interface AccessListEntry {
	address: string
	storageKeys: string[]
}

interface ExecutionResult {
	success: boolean
	gasUsed: bigint
	gasRemaining: bigint
	gasRefund: bigint
	outputHex: string
	steps: TraceStepEntry[]
	callTree: CallTraceNode | null
	flamegraphSvg: string
	flamegraphFolded: string
	flamegraphNative: boolean
	revertInfo: DecodedRevert | null
	accessList: AccessListEntry[]
	stateChangesJson: string | null
	rpcHops: string[]
	durationMs: number
}

interface PresetContract {
	address: string
	code: string
	storage?: Array<{ slot: string; value: string }>
}

interface PlaygroundPreset {
	id: string
	label: string
	hardfork: string
	gasLimit: string
	bytecode: string
	calldata: string
	contracts?: PresetContract[]
	blurb: string
}

// ---------------------------------------------------------------------------
// Constants & Presets
// ---------------------------------------------------------------------------

const HARDFORKS = [
	'frontier',
	'homestead',
	'tangerine_whistle',
	'spurious_dragon',
	'byzantium',
	'constantinople',
	'petersburg',
	'istanbul',
	'berlin',
	'london',
	'merge',
	'shanghai',
	'cancun',
	'prague',
	'osaka',
	'amsterdam',
] as const

const ASYNC_REQUEST_SIZE = 60 + 16384
const DEFAULT_TARGET = '0x0000000000000000000000000000000000000200'
const DEFAULT_CALLER = '0x00000000000000000000000000000000000000aa'
const CHILD_TARGET = '0x0000000000000000000000000000000000000202'

// EIP-7951 zero-hash P256VERIFY vector: h=0, Q=G, r=s=Gx (160 bytes)
const P256_GX = '6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296'
const P256_GY = '4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5'
const P256_ZERO_HASH_VECTOR = `0x${'00'.repeat(32)}${P256_GX}${P256_GX}${P256_GX}${P256_GY}`

// Child contract at 0x0202: SLOAD(1); POP; ABI-encode Error("Insufficient vault balance"); REVERT(28, 100)
const NESTED_REVERT_CHILD_CODE =
	'0x600154506308c379a06000526020602052601a604052' +
	'79496e73756666696369656e74207661756c742062616c616e636560301b6060526064601cfd'

const PRESETS: PlaygroundPreset[] = [
	{
		id: 'fibonacci',
		label: 'Fibonacci Loop (fib(10) = 55)',
		hardfork: 'osaka',
		gasLimit: '100000',
		bytecode: '0x60006001600a5b80156018576001900391810190916006565b505060005260206000f3',
		calldata: '0x',
		blurb:
			'Loops 10 iterations with JUMPI/SWAP/DUP/ADD to compute fib(10) = 0x37 (55) and returns it from memory. Scrub through the trace to watch the stack evolve each iteration.',
	},
	{
		id: 'storage-warm-cold',
		label: 'Storage Warm/Cold (SLOAD + SSTORE)',
		hardfork: 'osaka',
		gasLimit: '200000',
		bytecode: '0x6000545060005450602a6000556007600155600060015560005460005260206000f3',
		calldata: '0x',
		blurb:
			'Executes cold SLOAD(0) (2,100 gas), warm SLOAD(0) (100 gas), SSTORE(0, 42) (20,000 gas), then sets and clears slot 1 to trigger an EIP-3529 gas refund.',
	},
	{
		id: 'nested-call-revert',
		label: 'Nested CALL + Error(string) REVERT',
		hardfork: 'osaka',
		gasLimit: '250000',
		bytecode: '0x60006000600060006000610202620186a0f1503d600060003e3d6000fd',
		calldata: '0x',
		contracts: [
			{
				address: CHILD_TARGET,
				code: NESTED_REVERT_CHILD_CODE,
				storage: [{ slot: '0x01', value: '0x2a' }],
			},
		],
		blurb:
			'Calls a deployed child contract at 0x0000..0202 that performs SLOAD(1) and reverts with ABI Error("Insufficient vault balance"), then bubbles the revert payload up through RETURNDATACOPY.',
	},
	{
		id: 'osaka-clz-p256',
		label: 'Osaka CLZ (EIP-7939) + P256VERIFY (EIP-7951)',
		hardfork: 'osaka',
		gasLimit: '200000',
		bytecode: '0x6100ff1e600052366000604037602060203660406101005afa5060406000f3',
		calldata: P256_ZERO_HASH_VECTOR,
		blurb:
			'Runs Osaka CLZ(0x00ff) = 248 (0xf8) and STATICCALLs the EIP-7951 secp256r1 P256VERIFY precompile at 0x0100 with a valid 160-byte vector. Switch hardfork to Prague to see CLZ fault with InvalidOpcode.',
	},
]

const PANIC_DESCRIPTIONS: Record<string, string> = {
	'0x0': 'generic compiler panic',
	'0x1': 'assertion failed',
	'0x11': 'arithmetic underflow or overflow',
	'0x12': 'division or modulo by zero',
	'0x21': 'invalid enum conversion',
	'0x22': 'incorrectly encoded storage byte array',
	'0x31': 'pop on an empty array',
	'0x32': 'array index out of bounds',
	'0x41': 'memory allocation overflow',
	'0x51': 'call to an uninitialized internal function',
}

// ---------------------------------------------------------------------------
// Compact Inline Browser WASI Preview 1 Shim
// ---------------------------------------------------------------------------

function createWasiPreview1Shim(getMemory: () => WebAssembly.Memory | null) {
	const decoder = new TextDecoder()
	const viewOf = () => {
		const mem = getMemory()
		if (!mem) throw new Error('WASM memory not attached')
		return { bytes: new Uint8Array(mem.buffer), dv: new DataView(mem.buffer) }
	}

	const ESUCCESS = 0
	const EBADF = 8
	const ENOSYS = 52

	return {
		args_get: () => ESUCCESS,
		args_sizes_get: (argcPtr: number, argvBufSizePtr: number) => {
			const { dv } = viewOf()
			dv.setUint32(argcPtr, 0, true)
			dv.setUint32(argvBufSizePtr, 0, true)
			return ESUCCESS
		},
		environ_get: () => ESUCCESS,
		environ_sizes_get: (countPtr: number, bufSizePtr: number) => {
			const { dv } = viewOf()
			dv.setUint32(countPtr, 0, true)
			dv.setUint32(bufSizePtr, 0, true)
			return ESUCCESS
		},
		clock_res_get: (_id: number, resPtr: number) => {
			const { dv } = viewOf()
			dv.setBigUint64(resPtr, 1_000_000n, true)
			return ESUCCESS
		},
		clock_time_get: (_id: number, _precision: bigint, timePtr: number) => {
			const { dv } = viewOf()
			dv.setBigUint64(timePtr, BigInt(Date.now()) * 1_000_000n, true)
			return ESUCCESS
		},
		fd_close: () => ESUCCESS,
		fd_fdstat_get: (_fd: number, statPtr: number) => {
			const { bytes } = viewOf()
			bytes.fill(0, statPtr, statPtr + 24)
			return ESUCCESS
		},
		fd_filestat_get: (_fd: number, statPtr: number) => {
			const { bytes } = viewOf()
			bytes.fill(0, statPtr, statPtr + 64)
			return ESUCCESS
		},
		fd_prestat_get: () => EBADF,
		fd_prestat_dir_name: () => EBADF,
		fd_seek: (_fd: number, _offset: bigint, _whence: number, newOffsetPtr: number) => {
			const { dv } = viewOf()
			dv.setBigUint64(newOffsetPtr, 0n, true)
			return ESUCCESS
		},
		fd_read: (_fd: number, _iovsPtr: number, _iovsLen: number, nreadPtr: number) => {
			const { dv } = viewOf()
			dv.setUint32(nreadPtr, 0, true)
			return ESUCCESS
		},
		fd_write: (fd: number, iovsPtr: number, iovsLen: number, nwrittenPtr: number) => {
			const { bytes, dv } = viewOf()
			let total = 0
			let text = ''
			for (let i = 0; i < iovsLen; i++) {
				const ptr = dv.getUint32(iovsPtr + i * 8, true)
				const len = dv.getUint32(iovsPtr + i * 8 + 4, true)
				if (len > 0) {
					text += decoder.decode(bytes.subarray(ptr, ptr + len))
					total += len
				}
			}
			if (text && (fd === 1 || fd === 2) && typeof console !== 'undefined') {
				if (fd === 2) console.debug('[guillotine-mini stderr]', text.trimEnd())
			}
			dv.setUint32(nwrittenPtr, total, true)
			return ESUCCESS
		},
		fd_pwrite: (_fd: number, iovsPtr: number, iovsLen: number, _offset: bigint, nwrittenPtr: number) => {
			const { dv } = viewOf()
			let total = 0
			for (let i = 0; i < iovsLen; i++) {
				total += dv.getUint32(iovsPtr + i * 8 + 4, true)
			}
			dv.setUint32(nwrittenPtr, total, true)
			return ESUCCESS
		},
		poll_oneoff: () => ENOSYS,
		proc_exit: (code: number) => {
			throw new Error(`WASI proc_exit(${code})`)
		},
		random_get: (bufPtr: number, bufLen: number) => {
			const { bytes } = viewOf()
			let offset = 0
			while (offset < bufLen) {
				const chunk = Math.min(65536, bufLen - offset)
				const slice = bytes.subarray(bufPtr + offset, bufPtr + offset + chunk)
				if (typeof globalThis.crypto !== 'undefined' && globalThis.crypto.getRandomValues) {
					globalThis.crypto.getRandomValues(slice)
				} else {
					for (let i = 0; i < slice.length; i++) slice[i] = (i * 73 + 19) & 0xff
				}
				offset += chunk
			}
			return ESUCCESS
		},
		sched_yield: () => ESUCCESS,
	}
}

async function instantiateWasmReactor(wasmBytes: ArrayBuffer): Promise<WasmEvmExports> {
	let memoryRef: WebAssembly.Memory | null = null
	const wasi = createWasiPreview1Shim(() => memoryRef)
	const { instance } = await WebAssembly.instantiate(wasmBytes, {
		wasi_snapshot_preview1: wasi,
		env: {
			js_opcode_callback: () => 0,
			js_precompile_callback: () => 0,
		},
	})
	const exports = instance.exports as WasmEvmExports
	memoryRef = exports.memory
	exports._initialize?.()
	return exports
}

// ---------------------------------------------------------------------------
// Hex & Byte Helpers
// ---------------------------------------------------------------------------

function parseHexBytes(input: string, fieldName: string): Uint8Array {
	const cleaned = input.trim().replace(/^0x/i, '').replace(/\s+/g, '')
	if (cleaned.length === 0) return new Uint8Array(0)
	if (!/^[0-9a-fA-F]+$/.test(cleaned)) {
		throw new Error(`${fieldName} must contain valid hex digits only.`)
	}
	const even = cleaned.length % 2 === 1 ? `0${cleaned}` : cleaned
	const out = new Uint8Array(even.length / 2)
	for (let i = 0; i < out.length; i++) {
		out[i] = Number.parseInt(even.slice(i * 2, i * 2 + 2), 16)
	}
	return out
}

function parseAddressBytes(input: string, fieldName: string): Uint8Array {
	const raw = parseHexBytes(input, fieldName)
	if (raw.length > 20) throw new Error(`${fieldName} must be at most 20 bytes (40 hex chars).`)
	const out = new Uint8Array(20)
	out.set(raw, 20 - raw.length)
	return out
}

function parseWord32(input: string, fieldName: string): Uint8Array {
	const trimmed = input.trim()
	if (!trimmed) return new Uint8Array(32)
	let value: bigint
	try {
		value = trimmed.startsWith('0x') || trimmed.startsWith('0X') ? BigInt(trimmed) : BigInt(trimmed)
	} catch {
		throw new Error(`${fieldName} must be a valid integer or 0x-hex quantity.`)
	}
	if (value < 0n) throw new Error(`${fieldName} cannot be negative.`)
	const out = new Uint8Array(32)
	let v = value
	for (let i = 31; i >= 0 && v > 0n; i--) {
		out[i] = Number(v & 0xffn)
		v >>= 8n
	}
	return out
}

function toHex(bytes: Uint8Array): string {
	let hex = '0x'
	for (let i = 0; i < bytes.length; i++) {
		hex += bytes[i]!.toString(16).padStart(2, '0')
	}
	return hex
}

function writeBigUint64BE(target: Uint8Array, offset: number, val: bigint): void {
	let v = val
	for (let i = 7; i >= 0; i--) {
		target[offset + i] = Number(v & 0xffn)
		v >>= 8n
	}
}

function formatHexQty(hexOrDec: string): string {
	try {
		const n = BigInt(hexOrDec)
		return n.toLocaleString()
	} catch {
		return hexOrDec
	}
}

function parseHexBigInt(val: string | undefined): bigint {
	if (!val) return 0n
	try {
		return BigInt(val)
	} catch {
		return 0n
	}
}

// ---------------------------------------------------------------------------
// Fallback Flamegraph & Revert Decoder (when WASM binary predates new exports)
// ---------------------------------------------------------------------------

function xmlEscape(text: string): string {
	return text
		.replace(/&/g, '&amp;')
		.replace(/</g, '&lt;')
		.replace(/>/g, '&gt;')
		.replace(/"/g, '&quot;')
		.replace(/'/g, '&#39;')
}

function fallbackDecodeRevert(outputHex: string, summaryError?: string): DecodedRevert {
	const raw = outputHex.startsWith('0x') ? outputHex : `0x${outputHex}`
	const bytes = parseHexBytes(raw, 'output')
	if (bytes.length >= 4) {
		const selector = toHex(bytes.subarray(0, 4))
		if (selector === '0x08c379a0' && bytes.length >= 68) {
			const offset = Number(BigInt(toHex(bytes.subarray(4, 36))))
			const lenStart = 4 + offset
			if (offset >= 32 && offset % 32 === 0 && lenStart + 32 <= bytes.length) {
				const strLen = Number(BigInt(toHex(bytes.subarray(lenStart, lenStart + 32))))
				const strStart = lenStart + 32
				if (strStart + strLen <= bytes.length) {
					const reason = new TextDecoder().decode(bytes.subarray(strStart, strStart + strLen))
					return { kind: 'error', selector, reason, error: summaryError ?? 'execution reverted', raw }
				}
			}
		}
		if (selector === '0x4e487b71' && bytes.length >= 36) {
			const code = `0x${BigInt(toHex(bytes.subarray(4, 36))).toString(16)}`
			const description = PANIC_DESCRIPTIONS[code]
			return {
				kind: 'panic',
				selector,
				code,
				description,
				reason: description ? `panic ${code}: ${description}` : `panic ${code}`,
				error: summaryError ?? 'execution reverted',
				raw,
			}
		}
		return { kind: 'custom', selector, error: summaryError ?? 'execution reverted', raw }
	}
	if (bytes.length > 0) {
		return { kind: 'raw', error: summaryError ?? 'execution reverted', raw }
	}
	return { kind: 'halt', error: summaryError ?? 'execution reverted', raw: '0x' }
}

function synthesizeFlamegraphFromTrace(steps: TraceStepEntry[]): { svg: string; folded: string } {
	const samples = new Map<string, number>()
	for (const s of steps) {
		const cost = Number(parseHexBigInt(s.gasCost))
		if (cost <= 0) continue
		const path = `DEPTH:${s.depth};${s.opName}`
		samples.set(path, (samples.get(path) ?? 0) + cost)
	}
	const sorted = [...samples.entries()].sort((a, b) => a[0].localeCompare(b[0]))
	const folded = sorted.map(([p, g]) => `${p} ${g}`).join('\n') + (sorted.length ? '\n' : '')
	const total = sorted.reduce((acc, [, g]) => acc + g, 0)
	const width = 1200
	const pad = 12
	const chartW = width - pad * 2
	const rowH = 20
	const headerH = 52
	const height = headerH + 3 * rowH + 16
	if (total === 0) {
		return {
			folded,
			svg: `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="88" viewBox="0 0 ${width} 88"><rect x="0" y="0" width="${width}" height="88" fill="#fafafa"/><text x="600" y="50" text-anchor="middle" font-family="monospace" font-size="12" fill="#6b7280">No gas samples recorded</text></svg>`,
		}
	}
	const byDepth = new Map<string, Array<[string, number]>>()
	for (const [path, gas] of sorted) {
		const [depthSeg, opSeg] = path.split(';')
		const list = byDepth.get(depthSeg!) ?? []
		list.push([opSeg ?? path, gas])
		byDepth.set(depthSeg!, list)
	}
	const bars: string[] = []
	bars.push(
		`<g class="frame"><title>all (${total} gas, 100.00%)</title><rect x="${pad}" y="${headerH + 2 * rowH}" width="${chartW}" height="19" rx="2" fill="#d97706"/><text x="${pad + 4}" y="${headerH + 2 * rowH + 14}">all</text></g>`,
	)
	let dx = pad
	for (const [depthSeg, ops] of byDepth.entries()) {
		const dGas = ops.reduce((a, [, g]) => a + g, 0)
		const dw = (chartW * dGas) / total
		const dPct = ((dGas * 100) / total).toFixed(2)
		bars.push(
			`<g class="frame"><title>${xmlEscape(depthSeg)} (${dGas} gas, ${dPct}%)</title><rect x="${dx.toFixed(2)}" y="${headerH + rowH}" width="${dw.toFixed(2)}" height="19" rx="2" fill="#60a5fa"/>${dw > 40 ? `<text x="${(dx + 4).toFixed(2)}" y="${headerH + rowH + 14}">${xmlEscape(depthSeg)}</text>` : ''}</g>`,
		)
		let ox = dx
		for (const [opName, g] of ops) {
			const ow = (dw * g) / dGas
			const pct = ((g * 100) / total).toFixed(2)
			const fill =
				opName === 'SLOAD' || opName === 'SSTORE'
					? '#f87171'
					: opName === 'REVERT' || opName === 'INVALID'
						? '#ef4444'
						: opName.startsWith('M')
							? '#fb923c'
							: '#fbbf24'
			if (ow >= 0.4) {
				const maxChars = ow > 24 ? Math.floor((ow - 8) / 6.6) : 0
				const label = maxChars >= 3 ? (opName.length <= maxChars ? opName : `${opName.slice(0, maxChars - 2)}..`) : ''
				bars.push(
					`<g class="frame"><title>${xmlEscape(`${depthSeg};${opName}`)} (${g} gas, ${pct}%)</title><rect x="${ox.toFixed(2)}" y="${headerH}" width="${ow.toFixed(2)}" height="19" rx="2" fill="${fill}"/>${label ? `<text x="${(ox + 4).toFixed(2)}" y="${headerH + 14}">${xmlEscape(label)}</text>` : ''}</g>`,
				)
			}
			ox += ow
		}
		dx += dw
	}
	const svg =
		`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}">` +
		`<style>text{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:11px;fill:#1a1a1a;pointer-events:none}text.t{font-size:15px;font-weight:700;text-anchor:middle;fill:#111827}text.s{font-size:11px;text-anchor:middle;fill:#4b5563}g.frame rect{stroke:#fff;stroke-width:0.6}g.frame:hover rect{stroke:#111827;stroke-width:1.2}</style>` +
		`<rect x="0" y="0" width="${width}" height="${height}" fill="#fafafa"/>` +
		`<text x="600" y="22" class="t">EVM Gas Flamegraph (Trace Synthesis)</text>` +
		`<text x="600" y="40" class="s">Total gas: ${total.toLocaleString()}</text>` +
		bars.join('\n') +
		`</svg>`
	return { svg, folded }
}

// ---------------------------------------------------------------------------
// JSON-RPC Helper for RPC Tx Replay Mode
// ---------------------------------------------------------------------------

async function rpcCall<T>(url: string, method: string, params: unknown[], signal?: AbortSignal): Promise<T> {
	const resp = await fetch(url, {
		method: 'POST',
		headers: { 'content-type': 'application/json' },
		body: JSON.stringify({ jsonrpc: '2.0', id: 1, method, params }),
		signal,
	})
	if (!resp.ok) {
		throw new Error(`RPC HTTP ${resp.status} for ${method}`)
	}
	const body = (await resp.json()) as { result?: T; error?: { code?: number; message?: string } }
	if (body.error) {
		throw new Error(`RPC error (${method}): ${body.error.message ?? JSON.stringify(body.error)}`)
	}
	return body.result as T
}

// ---------------------------------------------------------------------------
// WASM Execution Driver (Local Sandbox + Async RPC Replay)
// ---------------------------------------------------------------------------

interface RunParams {
	api: WasmEvmExports
	mode: 'local' | 'rpc'
	hardfork: string
	gasLimit: bigint
	caller: string
	target: string
	value: string
	bytecode: string
	calldata: string
	contracts?: PresetContract[]
	rpcUrl?: string
	blockTag?: string
	signal?: AbortSignal
	onRpcHop?: (line: string) => void
}

async function runWasmExecution(params: RunParams): Promise<ExecutionResult> {
	const { api } = params
	const t0 = performance.now()
	const allocations: Array<[number, number]> = []
	const encoder = new TextEncoder()
	const decoder = new TextDecoder()

	function alloc(input: Uint8Array | number): number {
		const data = typeof input === 'number' ? new Uint8Array(input) : input
		if (data.length === 0) return 0
		const ptr = api.evm_alloc(data.length)
		if (!ptr) throw new Error(`evm_alloc(${data.length}) failed in WASM linear memory`)
		new Uint8Array(api.memory.buffer, ptr, data.length).set(data)
		allocations.push([ptr, data.length])
		return ptr
	}

	function readStringExport(
		lenFn: ((h: number) => number) | undefined,
		copyFn: ((h: number, p: number, l: number) => number) | undefined,
		handle: number,
	): string {
		if (!lenFn || !copyFn) return ''
		const len = lenFn(handle)
		if (len <= 0) return ''
		const ptr = alloc(len)
		const copied = copyFn(handle, ptr, len)
		return decoder.decode(new Uint8Array(api.memory.buffer, ptr, copied))
	}

	let handle = 0
	const rpcHops: string[] = []
	try {
		const forkBytes = encoder.encode(params.hardfork)
		handle = api.evm_create(alloc(forkBytes), forkBytes.length, 0)
		if (!handle) {
			throw new Error(
				`evm_create("${params.hardfork}") failed. This hardfork may not be enabled in the loaded WASM build.`,
			)
		}

		const zero32 = alloc(32)
		const chainId = alloc(parseWord32('1', 'Chain ID'))
		const coinbase = alloc(20)
		let blockNumber = 21_500_000n
		let blockTimestamp = BigInt(Math.floor(Date.now() / 1000))
		let blockGasLimit = 30_000_000n
		let baseFeePtr = zero32

		if (params.mode === 'rpc' && params.rpcUrl) {
			const blockTag = params.blockTag?.trim() || 'latest'
			const block = await rpcCall<{
				number?: string
				timestamp?: string
				gasLimit?: string
				baseFeePerGas?: string
			} | null>(params.rpcUrl, 'eth_getBlockByNumber', [blockTag, false], params.signal)
			if (block) {
				if (block.number) blockNumber = BigInt(block.number)
				if (block.timestamp) blockTimestamp = BigInt(block.timestamp)
				if (block.gasLimit) blockGasLimit = BigInt(block.gasLimit)
				if (block.baseFeePerGas) baseFeePtr = alloc(parseWord32(block.baseFeePerGas, 'baseFee'))
				const hop = `eth_getBlockByNumber(${blockTag}) -> block #${blockNumber}`
				rpcHops.push(hop)
				params.onRpcHop?.(hop)
			}
		}

		api.evm_set_blockchain_context(
			handle,
			chainId,
			blockNumber,
			blockTimestamp,
			zero32,
			zero32,
			coinbase,
			blockGasLimit,
			baseFeePtr,
			zero32,
		)

		// Install any preset auxiliary contracts
		if (params.mode === 'local' && params.contracts) {
			for (const c of params.contracts) {
				const addrPtr = alloc(parseAddressBytes(c.address, 'Contract address'))
				const codeBytes = parseHexBytes(c.code, 'Contract code')
				api.evm_set_code(handle, addrPtr, alloc(codeBytes), codeBytes.length)
				if (c.storage) {
					for (const slot of c.storage) {
						api.evm_set_storage(
							handle,
							addrPtr,
							alloc(parseWord32(slot.slot, 'Storage slot')),
							alloc(parseWord32(slot.value, 'Storage value')),
						)
					}
				}
			}
		}

		const callerBytes = parseAddressBytes(params.caller, 'Caller')
		const targetBytes = parseAddressBytes(params.target, 'Target')
		const valueBytes = parseWord32(params.value, 'Value')
		const calldataBytes = parseHexBytes(params.calldata, 'Calldata')

		const callerPtr = alloc(callerBytes)
		const targetPtr = alloc(targetBytes)
		const valuePtr = alloc(valueBytes)
		const calldataPtr = alloc(calldataBytes)

		if (params.mode === 'local') {
			const codeBytes = parseHexBytes(params.bytecode, 'Bytecode')
			if (!api.evm_set_bytecode(handle, alloc(codeBytes), codeBytes.length)) {
				throw new Error('evm_set_bytecode failed')
			}
		} else {
			api.evm_set_bytecode(handle, 0, 0)
		}

		if (
			!api.evm_set_execution_context(
				handle,
				params.gasLimit,
				callerPtr,
				targetPtr,
				valuePtr,
				calldataPtr,
				calldataBytes.length,
			)
		) {
			throw new Error('evm_set_execution_context failed (check gas limit and address inputs)')
		}

		// Enable full observability: EIP-3155 + CallTracer + AccessList + Flamegraph (if exported)
		api.evm_enable_tracing(handle, 1, 0, 0, 1)
		api.evm_enable_call_tracer(handle, 0, 1)
		api.evm_enable_access_list_tracker(handle)
		const hasNativeFlamegraph = typeof api.evm_enable_flamegraph === 'function'
		if (hasNativeFlamegraph) {
			api.evm_enable_flamegraph!(handle, 1)
		}

		let stateChangesJson: string | null = null
		let success = false

		if (params.mode === 'local') {
			success = api.evm_execute(handle) === 1
		} else {
			if (!params.rpcUrl) throw new Error('Enter an Ethereum JSON-RPC URL for RPC Tx Replay.')
			const blockTag = params.blockTag?.trim() || 'latest'
			if (!api.evm_enable_storage_injector(handle)) {
				throw new Error('evm_enable_storage_injector failed')
			}
			const reqPtr = alloc(ASYNC_REQUEST_SIZE)
			if (!api.evm_call_ffi(handle, reqPtr)) {
				throw new Error('evm_call_ffi rejected initial call')
			}

			const MAX_HOPS = 256
			let hops = 0
			while (true) {
				const tag = new Uint8Array(api.memory.buffer, reqPtr, 1)[0]!
				if (tag === 0) break
				if (tag === 255) throw new Error('Async EVM execution returned host failure (tag 255)')
				if (++hops > MAX_HOPS) throw new Error(`Exceeded ${MAX_HOPS} RPC state fetch hops`)

				if (tag === 5) {
					const fullLen = api.evm_get_state_changes_len(handle)
					if (fullLen > 0) {
						const scPtr = alloc(fullLen)
						api.evm_get_state_changes(handle, scPtr, fullLen)
						stateChangesJson = decoder.decode(new Uint8Array(api.memory.buffer, scPtr, fullLen))
					}
					const hop = `ready_to_commit (${fullLen} bytes state diff) -> ack`
					rpcHops.push(hop)
					params.onRpcHop?.(hop)
					if (!api.evm_continue_ffi(handle, 5, 0, 0, reqPtr)) {
						throw new Error('evm_continue_ffi(after_commit) failed')
					}
					continue
				}

				const addrSlice = new Uint8Array(api.memory.buffer, reqPtr + 1, 20).slice()
				const addrHex = toHex(addrSlice)

				if (tag === 1) {
					const slotSlice = new Uint8Array(api.memory.buffer, reqPtr + 21, 32).slice()
					const slotHex = toHex(slotSlice)
					const valHex = await rpcCall<string>(
						params.rpcUrl,
						'eth_getStorageAt',
						[addrHex, slotHex, blockTag],
						params.signal,
					)
					const reply = new Uint8Array(84)
					reply.set(addrSlice, 0)
					reply.set(slotSlice, 20)
					reply.set(parseWord32(valHex || '0x0', 'storage'), 52)
					const hop = `need_storage ${addrHex.slice(0, 10)}.. slot ${slotHex.slice(0, 10)}.. -> ${valHex || '0x0'}`
					rpcHops.push(hop)
					params.onRpcHop?.(hop)
					if (!api.evm_continue_ffi(handle, 1, alloc(reply), reply.length, reqPtr)) {
						throw new Error('evm_continue_ffi(storage) failed')
					}
				} else if (tag === 2) {
					const balHex = await rpcCall<string>(
						params.rpcUrl,
						'eth_getBalance',
						[addrHex, blockTag],
						params.signal,
					)
					const reply = new Uint8Array(52)
					reply.set(addrSlice, 0)
					reply.set(parseWord32(balHex || '0x0', 'balance'), 20)
					const hop = `need_balance ${addrHex.slice(0, 10)}.. -> ${balHex || '0x0'}`
					rpcHops.push(hop)
					params.onRpcHop?.(hop)
					if (!api.evm_continue_ffi(handle, 2, alloc(reply), reply.length, reqPtr)) {
						throw new Error('evm_continue_ffi(balance) failed')
					}
				} else if (tag === 3) {
					const codeHex = await rpcCall<string>(
						params.rpcUrl,
						'eth_getCode',
						[addrHex, blockTag],
						params.signal,
					)
					const codeBytes = parseHexBytes(codeHex || '0x', 'code')
					const reply = new Uint8Array(20 + codeBytes.length)
					reply.set(addrSlice, 0)
					reply.set(codeBytes, 20)
					const hop = `need_code ${addrHex.slice(0, 10)}.. -> ${codeBytes.length} bytes`
					rpcHops.push(hop)
					params.onRpcHop?.(hop)
					if (!api.evm_continue_ffi(handle, 3, alloc(reply), reply.length, reqPtr)) {
						throw new Error('evm_continue_ffi(code) failed')
					}
				} else if (tag === 4) {
					const nonceHex = await rpcCall<string>(
						params.rpcUrl,
						'eth_getTransactionCount',
						[addrHex, blockTag],
						params.signal,
					)
					const reply = new Uint8Array(28)
					reply.set(addrSlice, 0)
					writeBigUint64BE(reply, 20, BigInt(nonceHex || '0x0'))
					const hop = `need_nonce ${addrHex.slice(0, 10)}.. -> ${nonceHex || '0x0'}`
					rpcHops.push(hop)
					params.onRpcHop?.(hop)
					if (!api.evm_continue_ffi(handle, 4, alloc(reply), reply.length, reqPtr)) {
						throw new Error('evm_continue_ffi(nonce) failed')
					}
				} else {
					throw new Error(`Unknown async output_type ${tag}`)
				}
			}
			success = api.evm_is_success(handle) === 1
		}

		const gasUsed = api.evm_get_gas_used(handle)
		const gasRemaining = api.evm_get_gas_remaining(handle)
		const gasRefund = typeof api.evm_get_gas_refund === 'function' ? api.evm_get_gas_refund(handle) : 0n
		const outLen = api.evm_get_output_len(handle)
		let outputHex = '0x'
		if (outLen > 0) {
			const outPtr = alloc(outLen)
			const copied = api.evm_get_output(handle, outPtr, outLen)
			outputHex = toHex(new Uint8Array(api.memory.buffer, outPtr, copied))
		}

		// Parse EIP-3155 JSONL trace
		const traceJsonl = readStringExport(api.evm_get_trace_json_len, api.evm_get_trace_json, handle)
		const steps: TraceStepEntry[] = []
		let summaryError: string | undefined
		for (const rawLine of traceJsonl.split('\n')) {
			const line = rawLine.trim()
			if (!line) continue
			try {
				const obj = JSON.parse(line) as Record<string, unknown>
				if ('op' in obj && 'pc' in obj) {
					steps.push(obj as unknown as TraceStepEntry)
				} else if (typeof obj.error === 'string') {
					summaryError = obj.error
				}
			} catch {
				// Ignore non-JSON trailing lines if any
			}
		}

		// Parse CallTracer tree
		const callTraceText = readStringExport(
			api.evm_get_call_trace_json_len,
			api.evm_get_call_trace_json,
			handle,
		)
		let callTree: CallTraceNode | null = null
		if (callTraceText) {
			try {
				callTree = JSON.parse(callTraceText) as CallTraceNode | null
			} catch {
				callTree = null
			}
		}

		// Parse Access List
		const accessListText = readStringExport(
			api.evm_get_access_list_json_len,
			api.evm_get_access_list_json,
			handle,
		)
		let accessList: AccessListEntry[] = []
		if (accessListText) {
			try {
				accessList = JSON.parse(accessListText) as AccessListEntry[]
			} catch {
				accessList = []
			}
		}

		// Flamegraph SVG & folded stacks (native WASM export with automatic TS fallback)
		let flamegraphSvg = ''
		let flamegraphFolded = ''
		let flamegraphNative = false
		if (hasNativeFlamegraph && typeof api.evm_get_flamegraph_svg_len === 'function') {
			flamegraphSvg = readStringExport(api.evm_get_flamegraph_svg_len, api.evm_get_flamegraph_svg, handle)
			flamegraphFolded = readStringExport(
				api.evm_get_flamegraph_folded_len,
				api.evm_get_flamegraph_folded,
				handle,
			)
			flamegraphNative = flamegraphSvg.length > 0
		}
		if (!flamegraphSvg) {
			const synth = synthesizeFlamegraphFromTrace(steps)
			flamegraphSvg = synth.svg
			flamegraphFolded = synth.folded
		}

		// Revert decoder (native WASM export with automatic TS fallback)
		let revertInfo: DecodedRevert | null = null
		if (!success) {
			const nativeRevert = readStringExport(
				api.evm_decode_revert_json_len,
				api.evm_decode_revert_json,
				handle,
			)
			if (nativeRevert) {
				try {
					revertInfo = JSON.parse(nativeRevert) as DecodedRevert
				} catch {
					revertInfo = fallbackDecodeRevert(outputHex, summaryError)
				}
			} else {
				revertInfo = fallbackDecodeRevert(outputHex, summaryError)
			}
		}

		return {
			success,
			gasUsed,
			gasRemaining,
			gasRefund,
			outputHex,
			steps,
			callTree,
			flamegraphSvg,
			flamegraphFolded,
			flamegraphNative,
			revertInfo,
			accessList,
			stateChangesJson,
			rpcHops,
			durationMs: Math.max(0.01, performance.now() - t0),
		}
	} finally {
		if (handle) api.evm_destroy(handle)
		for (let i = allocations.length - 1; i >= 0; i--) {
			const [ptr, len] = allocations[i]!
			api.evm_free(ptr, len)
		}
	}
}

// ---------------------------------------------------------------------------
// Sub-views: Memory Hex Dump & Call Tree
// ---------------------------------------------------------------------------

function MemoryHexView({ memoryHex }: { memoryHex: string | null | undefined }) {
	const cleaned = (memoryHex ?? '').replace(/^0x/i, '')
	if (!cleaned) {
		return <p className="gm-empty">Memory empty (0 bytes)</p>
	}
	const rows: Array<{ offset: string; words: string[]; ascii: string }> = []
	for (let byteOff = 0; byteOff < cleaned.length / 2; byteOff += 32) {
		const slice = cleaned.slice(byteOff * 2, (byteOff + 32) * 2).padEnd(64, '0')
		const chunks: string[] = []
		let ascii = ''
		for (let i = 0; i < 32; i++) {
			const byteHex = slice.slice(i * 2, i * 2 + 2)
			const val = Number.parseInt(byteHex, 16)
			ascii += val >= 32 && val <= 126 ? String.fromCharCode(val) : '.'
			if (i % 4 === 0) chunks.push(slice.slice(i * 2, i * 2 + 8))
		}
		rows.push({
			offset: `0x${byteOff.toString(16).padStart(4, '0')}`,
			words: chunks,
			ascii,
		})
	}
	return (
		<div className="wp-mem-wrap">
			{rows.map((r) => (
				<div key={r.offset} className="wp-mem-row">
					<span className="wp-mem-off">{r.offset}</span>
					<span className="wp-mem-hex">{r.words.join(' ')}</span>
					<span className="wp-mem-ascii">{r.ascii}</span>
				</div>
			))}
		</div>
	)
}

function CallTreeView({ node, depth = 0 }: { node: CallTraceNode; depth?: number }) {
	const reverted = Boolean(node.error || node.revertReason)
	return (
		<div className="wp-call-node" style={{ marginLeft: depth > 0 ? '1rem' : 0 }}>
			<div className={`wp-call-card${reverted ? ' wp-call-card--err' : ''}`}>
				<div className="wp-call-head">
					<span className="wp-pill">{node.type}</span>
					<span className="wp-mono-sm">
						{node.from.slice(0, 10)}.. → {(node.to ?? '<create>').slice(0, 10)}..
					</span>
					<span className="wp-mono-muted">
						gas {formatHexQty(node.gasUsed)} / {formatHexQty(node.gas)}
					</span>
				</div>
				{node.revertReason && (
					<div className="wp-call-err">Revert reason: {node.revertReason}</div>
				)}
				{!node.revertReason && node.error && (
					<div className="wp-call-err">Error: {node.error}</div>
				)}
				<div className="wp-call-meta">
					<span>input: {node.input.length > 42 ? `${node.input.slice(0, 42)}…` : node.input}</span>
					{node.output && (
						<span>
							output: {node.output.length > 42 ? `${node.output.slice(0, 42)}…` : node.output}
						</span>
					)}
					{node.logs && node.logs.length > 0 && <span>logs: {node.logs.length}</span>}
				</div>
			</div>
			{node.calls?.map((child, idx) => (
				<CallTreeView key={`${depth}-${idx}-${child.to ?? ''}`} node={child} depth={depth + 1} />
			))}
		</div>
	)
}

// ---------------------------------------------------------------------------
// Main Component
// ---------------------------------------------------------------------------

export function WasmPlayground() {
	const [wasmStatus, setWasmStatus] = useState<'loading' | 'ready' | 'missing' | 'error'>('loading')
	const [wasmInfo, setWasmInfo] = useState<string>('')
	const [wasmError, setWasmError] = useState<string>('')
	const apiRef = useRef<WasmEvmExports | null>(null)
	const abortRef = useRef<AbortController | null>(null)

	const [mode, setMode] = useState<'local' | 'rpc'>('local')
	const [presetId, setPresetId] = useState<string>(PRESETS[0]!.id)
	const [hardfork, setHardfork] = useState<string>(PRESETS[0]!.hardfork)
	const [gasLimit, setGasLimit] = useState<string>(PRESETS[0]!.gasLimit)
	const [bytecode, setBytecode] = useState<string>(PRESETS[0]!.bytecode)
	const [calldata, setCalldata] = useState<string>(PRESETS[0]!.calldata)
	const [caller, setCaller] = useState<string>(DEFAULT_CALLER)
	const [target, setTarget] = useState<string>(DEFAULT_TARGET)
	const [valueWei, setValueWei] = useState<string>('0')

	// RPC Replay fields
	const [rpcUrl, setRpcUrl] = useState<string>('https://ethereum-rpc.publicnode.com')
	const [txHash, setTxHash] = useState<string>('')
	const [blockTag, setBlockTag] = useState<string>('latest')
	const [liveHops, setLiveHops] = useState<string[]>([])

	// Execution & Scrubber State
	const [running, setRunning] = useState(false)
	const [runError, setRunError] = useState<string>('')
	const [result, setResult] = useState<ExecutionResult | null>(null)
	const [stepIndex, setStepIndex] = useState<number>(0)
	const [playing, setPlaying] = useState<boolean>(false)
	const [activeTab, setActiveTab] = useState<'trace' | 'flamegraph' | 'calls' | 'output'>('trace')
	const [showFolded, setShowFolded] = useState<boolean>(false)

	const activePreset = useMemo(
		() => PRESETS.find((p) => p.id === presetId) ?? null,
		[presetId],
	)

	const loadWasmFromBuffer = useCallback(async (buf: ArrayBuffer, label: string) => {
		const magic = new Uint8Array(buf, 0, Math.min(4, buf.byteLength))
		const isWasmMagic =
			magic.length === 4 && magic[0] === 0x00 && magic[1] === 0x61 && magic[2] === 0x73 && magic[3] === 0x6d
		if (!isWasmMagic) {
			setWasmStatus('missing')
			setWasmError(`${label} did not return a WebAssembly binary (missing \\0asm header).`)
			return
		}
		try {
			const exports = await instantiateWasmReactor(buf)
			apiRef.current = exports
			const kb = (buf.byteLength / 1024).toFixed(1)
			const nativeFg = typeof exports.evm_enable_flamegraph === 'function'
			setWasmInfo(`${label} (${kb} KiB${nativeFg ? ' · native flamegraph ABI' : ''})`)
			setWasmError('')
			setWasmStatus('ready')
		} catch (err) {
			setWasmStatus('error')
			setWasmError(err instanceof Error ? err.message : String(err))
		}
	}, [])

	const loadDefaultWasm = useCallback(async () => {
		setWasmStatus('loading')
		setWasmError('')
		try {
			const resp = await fetch('/wasm/guillotine_mini.wasm')
			if (!resp.ok) {
				setWasmStatus('missing')
				setWasmError(`HTTP ${resp.status} fetching /wasm/guillotine_mini.wasm`)
				return
			}
			const buf = await resp.arrayBuffer()
			await loadWasmFromBuffer(buf, '/wasm/guillotine_mini.wasm')
		} catch (err) {
			setWasmStatus('missing')
			setWasmError(err instanceof Error ? err.message : String(err))
		}
	}, [loadWasmFromBuffer])

	useEffect(() => {
		void loadDefaultWasm()
	}, [loadDefaultWasm])

	// Auto-play timer for time-travel debugger
	useEffect(() => {
		if (!playing || !result || result.steps.length === 0) return
		const timer = window.setInterval(() => {
			setStepIndex((prev) => {
				if (prev + 1 >= result.steps.length) {
					setPlaying(false)
					return prev
				}
				return prev + 1
			})
		}, 180)
		return () => window.clearInterval(timer)
	}, [playing, result])

	const executeCurrent = useCallback(
		async (override?: Partial<PlaygroundPreset>) => {
			const api = apiRef.current
			if (!api) return
			abortRef.current?.abort()
			const controller = new AbortController()
			abortRef.current = controller

			setRunning(true)
			setPlaying(false)
			setRunError('')
			setLiveHops([])

			try {
				const parsedGas = BigInt((override?.gasLimit ?? gasLimit).trim() || '200000')
				const res = await runWasmExecution({
					api,
					mode,
					hardfork: override?.hardfork ?? hardfork,
					gasLimit: parsedGas,
					caller,
					target,
					value: valueWei,
					bytecode: override?.bytecode ?? bytecode,
					calldata: override?.calldata ?? calldata,
					contracts: override?.contracts ?? activePreset?.contracts,
					rpcUrl: mode === 'rpc' ? rpcUrl.trim() : undefined,
					blockTag: mode === 'rpc' ? blockTag.trim() || 'latest' : undefined,
					signal: controller.signal,
					onRpcHop: (hop) => setLiveHops((prev) => [...prev.slice(-24), hop]),
				})
				setResult(res)
				setStepIndex(0)
			} catch (err) {
				if ((err as Error).name !== 'AbortError') {
					setRunError(err instanceof Error ? err.message : String(err))
				}
			} finally {
				setRunning(false)
			}
		},
		[activePreset, blockTag, bytecode, calldata, caller, gasLimit, hardfork, mode, rpcUrl, target, valueWei],
	)

	// Run initial preset once WASM becomes ready
	const didAutoRunRef = useRef(false)
	useEffect(() => {
		if (wasmStatus === 'ready' && !didAutoRunRef.current) {
			didAutoRunRef.current = true
			void executeCurrent()
		}
	}, [wasmStatus, executeCurrent])

	const onSelectPreset = (id: string) => {
		const p = PRESETS.find((x) => x.id === id)
		if (!p) return
		setMode('local')
		setPresetId(p.id)
		setHardfork(p.hardfork)
		setGasLimit(p.gasLimit)
		setBytecode(p.bytecode)
		setCalldata(p.calldata)
		setCaller(DEFAULT_CALLER)
		setTarget(DEFAULT_TARGET)
		setValueWei('0')
		if (apiRef.current) {
			void executeCurrent(p)
		}
	}

	const onFetchTxByHash = async () => {
		const hash = txHash.trim()
		if (!rpcUrl.trim() || !hash) {
			setRunError('Provide both an RPC URL and a 0x transaction hash.')
			return
		}
		setRunError('')
		setRunning(true)
		try {
			const tx = await rpcCall<{
				from?: string
				to?: string | null
				input?: string
				value?: string
				gas?: string
				blockNumber?: string | null
			} | null>(rpcUrl.trim(), 'eth_getTransactionByHash', [hash])
			if (!tx) throw new Error(`Transaction ${hash} not found on RPC`)
			if (tx.from) setCaller(tx.from)
			if (tx.to) setTarget(tx.to)
			setCalldata(tx.input ?? '0x')
			setValueWei(tx.value ? BigInt(tx.value).toString() : '0')
			setGasLimit(tx.gas ? BigInt(tx.gas).toString() : '500000')
			if (tx.blockNumber) {
				const prevBlock = BigInt(tx.blockNumber) > 0n ? BigInt(tx.blockNumber) - 1n : 0n
				setBlockTag(`0x${prevBlock.toString(16)}`)
			}
			setLiveHops([`Loaded tx ${hash.slice(0, 12)}.. targeting ${tx.to ?? '<create>'}`])
		} catch (err) {
			setRunError(err instanceof Error ? err.message : String(err))
		} finally {
			setRunning(false)
		}
	}

	const onUploadWasm = async (file: File | null) => {
		if (!file) return
		const buf = await file.arrayBuffer()
		await loadWasmFromBuffer(buf, file.name)
	}

	const onDownloadSvg = () => {
		if (!result?.flamegraphSvg) return
		const blob = new Blob([result.flamegraphSvg], { type: 'image/svg+xml' })
		const url = URL.createObjectURL(blob)
		const a = document.createElement('a')
		a.href = url
		a.download = `guillotine-mini-${presetId}-${hardfork}.svg`
		a.click()
		URL.revokeObjectURL(url)
	}

	const currentStep = result && result.steps.length > 0 ? result.steps[Math.min(stepIndex, result.steps.length - 1)]! : null

	return (
		<div className="wp-root">
			<style>{PLAYGROUND_CSS}</style>

			{/* Status & Mode Bar */}
			<div className="wp-header">
				<div className="wp-mode-pills">
					<button
						type="button"
						className="gm-tab"
						data-active={mode === 'local'}
						onClick={() => setMode('local')}
					>
						Local Bytecode Sandbox
					</button>
					<button
						type="button"
						className="gm-tab"
						data-active={mode === 'rpc'}
						onClick={() => setMode('rpc')}
					>
						RPC Tx Replay (Async FFI)
					</button>
				</div>
				<div className="wp-status">
					<span className={`wp-dot wp-dot--${wasmStatus}`} />
					<span>
						{wasmStatus === 'loading' && 'Loading WASI reactor…'}
						{wasmStatus === 'ready' && wasmInfo}
						{wasmStatus === 'missing' && 'WASM binary not found at /wasm/guillotine_mini.wasm'}
						{wasmStatus === 'error' && `WASM error: ${wasmError}`}
					</span>
				</div>
			</div>

			{/* Graceful Missing-WASM Instructions + Local File Loader */}
			{(wasmStatus === 'missing' || wasmStatus === 'error') && (
				<div className="wp-banner">
					<p className="wp-banner-title">
						Build or load <code>guillotine_mini.wasm</code> to execute consensus EVM bytecode in-browser
					</p>
					<p className="wp-banner-desc">
						Local docs previews do not bundle the compiled WASI binary by default. Build it with Zig and copy
						it into <code>docs/public/wasm/</code>, or load a compiled <code>.wasm</code> file directly below:
					</p>
					<pre className="wp-cmd">
						{`zig build wasm\nmkdir -p docs/public/wasm && cp zig-out/bin/guillotine_mini.wasm docs/public/wasm/`}
					</pre>
					<div className="wp-banner-actions">
						<button type="button" className="gm-btn gm-btn--primary" onClick={() => void loadDefaultWasm()}>
							Retry /wasm/guillotine_mini.wasm
						</button>
						<label className="gm-btn wp-file-label">
							Load local .wasm file
							<input
								type="file"
								accept=".wasm,application/wasm"
								style={{ display: 'none' }}
								onChange={(e) => void onUploadWasm(e.target.files?.[0] ?? null)}
							/>
						</label>
					</div>
					{wasmError && <p className="wp-banner-err">{wasmError}</p>}
				</div>
			)}

			{/* Controls Panel */}
			<div className="wp-controls">
				{mode === 'local' ? (
					<>
						<div className="wp-row-grid">
							<label className="wp-field">
								<span>Preset</span>
								<select value={presetId} onChange={(e) => onSelectPreset(e.target.value)}>
									{PRESETS.map((p) => (
										<option key={p.id} value={p.id}>
											{p.label}
										</option>
									))}
								</select>
							</label>
							<label className="wp-field wp-field--sm">
								<span>Hardfork</span>
								<select value={hardfork} onChange={(e) => setHardfork(e.target.value)}>
									{HARDFORKS.map((hf) => (
										<option key={hf} value={hf}>
											{hf}
										</option>
									))}
								</select>
							</label>
							<label className="wp-field wp-field--sm">
								<span>Gas Limit</span>
								<input
									spellCheck={false}
									value={gasLimit}
									onChange={(e) => setGasLimit(e.target.value)}
								/>
							</label>
						</div>

						<div className="wp-row-grid">
							<label className="wp-field">
								<span>Bytecode (hex)</span>
								<textarea
									rows={2}
									spellCheck={false}
									value={bytecode}
									onChange={(e) => setBytecode(e.target.value)}
								/>
							</label>
							<label className="wp-field">
								<span>Calldata (hex)</span>
								<textarea
									rows={2}
									spellCheck={false}
									value={calldata}
									onChange={(e) => setCalldata(e.target.value)}
								/>
							</label>
						</div>
						{activePreset && <p className="wp-blurb">{activePreset.blurb}</p>}
					</>
				) : (
					<>
						<div className="wp-row-grid">
							<label className="wp-field">
								<span>JSON-RPC URL (CORS-enabled)</span>
								<input
									spellCheck={false}
									placeholder="https://ethereum-rpc.publicnode.com"
									value={rpcUrl}
									onChange={(e) => setRpcUrl(e.target.value)}
								/>
							</label>
							<label className="wp-field wp-field--sm">
								<span>Block Tag</span>
								<input
									spellCheck={false}
									placeholder="latest or 0x..."
									value={blockTag}
									onChange={(e) => setBlockTag(e.target.value)}
								/>
							</label>
							<label className="wp-field wp-field--sm">
								<span>Hardfork</span>
								<select value={hardfork} onChange={(e) => setHardfork(e.target.value)}>
									{HARDFORKS.map((hf) => (
										<option key={hf} value={hf}>
											{hf}
										</option>
									))}
								</select>
							</label>
						</div>

						<div className="wp-row-grid">
							<label className="wp-field">
								<span>Optional Tx Hash (auto-populate call fields)</span>
								<div className="wp-inline-input">
									<input
										spellCheck={false}
										placeholder="0x..."
										value={txHash}
										onChange={(e) => setTxHash(e.target.value)}
									/>
									<button
										type="button"
										className="gm-btn"
										disabled={running}
										onClick={() => void onFetchTxByHash()}
									>
										Fetch Tx
									</button>
								</div>
							</label>
							<label className="wp-field wp-field--sm">
								<span>Gas Limit</span>
								<input
									spellCheck={false}
									value={gasLimit}
									onChange={(e) => setGasLimit(e.target.value)}
								/>
							</label>
						</div>

						<div className="wp-row-grid">
							<label className="wp-field">
								<span>Caller (from)</span>
								<input spellCheck={false} value={caller} onChange={(e) => setCaller(e.target.value)} />
							</label>
							<label className="wp-field">
								<span>Target Contract (to)</span>
								<input spellCheck={false} value={target} onChange={(e) => setTarget(e.target.value)} />
							</label>
							<label className="wp-field wp-field--sm">
								<span>Value (wei)</span>
								<input
									spellCheck={false}
									value={valueWei}
									onChange={(e) => setValueWei(e.target.value)}
								/>
							</label>
						</div>

						<label className="wp-field">
							<span>Calldata (hex)</span>
							<textarea
								rows={2}
								spellCheck={false}
								placeholder="0x06fdde03 (e.g. ERC-20 name())"
								value={calldata}
								onChange={(e) => setCalldata(e.target.value)}
							/>
						</label>
						<p className="wp-blurb">
							Executes lazily via <code>evm_call_ffi</code> / <code>evm_continue_ffi</code>: the WASM reactor
							suspends on cold code, storage, balance, or nonce reads and fetches only the touched state over
							JSON-RPC.
						</p>
					</>
				)}

				<div className="wp-run-bar">
					<button
						type="button"
						className="gm-btn gm-btn--primary"
						disabled={wasmStatus !== 'ready' || running}
						onClick={() => void executeCurrent()}
					>
						{running ? 'Executing…' : mode === 'rpc' ? 'Replay via Async FFI' : 'Execute in WASM'}
					</button>
					{running && (
						<button
							type="button"
							className="gm-btn"
							onClick={() => abortRef.current?.abort()}
						>
							Cancel
						</button>
					)}
					{result && (
						<div className="wp-summary-badges">
							<span className={`wp-badge ${result.success ? 'wp-badge--ok' : 'wp-badge--err'}`}>
								{result.success ? 'SUCCESS' : result.revertInfo?.kind === 'panic' ? 'PANIC' : 'REVERT / HALT'}
							</span>
							<span className="wp-badge">Gas: {result.gasUsed.toLocaleString()}</span>
							{result.gasRefund > 0n && (
								<span className="wp-badge">Refund: {result.gasRefund.toLocaleString()}</span>
							)}
							<span className="wp-badge">Steps: {result.steps.length.toLocaleString()}</span>
							<span className="wp-badge">{result.durationMs.toFixed(1)} ms</span>
						</div>
					)}
				</div>

				{runError && <p className="gm-note gm-note--error">{runError}</p>}

				{result?.revertInfo && (
					<div className="wp-revert-box">
						<strong>Decoded Revert ({result.revertInfo.kind}):</strong>{' '}
						{result.revertInfo.reason ??
							result.revertInfo.error ??
							result.revertInfo.selector ??
							result.revertInfo.raw}
						{result.revertInfo.selector && (
							<span className="wp-mono-muted"> · selector {result.revertInfo.selector}</span>
						)}
					</div>
				)}

				{liveHops.length > 0 && (
					<details className="wp-hops" open={running}>
						<summary>Async RPC State Hops ({liveHops.length})</summary>
						<pre>{liveHops.join('\n')}</pre>
					</details>
				)}
			</div>

			{/* Results Tabs */}
			{result && (
				<div className="wp-results">
					<div className="gm-tabs">
						<button
							type="button"
							className="gm-tab"
							data-active={activeTab === 'trace'}
							onClick={() => setActiveTab('trace')}
						>
							Time-Travel Trace ({result.steps.length})
						</button>
						<button
							type="button"
							className="gm-tab"
							data-active={activeTab === 'flamegraph'}
							onClick={() => setActiveTab('flamegraph')}
						>
							Gas Flamegraph
						</button>
						<button
							type="button"
							className="gm-tab"
							data-active={activeTab === 'calls'}
							onClick={() => setActiveTab('calls')}
						>
							Call Tree
						</button>
						<button
							type="button"
							className="gm-tab"
							data-active={activeTab === 'output'}
							onClick={() => setActiveTab('output')}
						>
							Output &amp; Access List ({result.accessList.length})
						</button>
					</div>

					{/* TAB 1: Time-Travel Step Scrubber */}
					{activeTab === 'trace' && (
						<div className="wp-panel">
							{result.steps.length === 0 ? (
								<p className="gm-empty">
									No opcode steps captured (direct precompile call or empty bytecode).
								</p>
							) : (
								<>
									<div className="wp-scrubber">
										<button
											type="button"
											className="gm-btn"
											disabled={stepIndex <= 0}
											onClick={() => {
												setPlaying(false)
												setStepIndex(0)
											}}
											title="First step"
										>
											|&lt;
										</button>
										<button
											type="button"
											className="gm-btn"
											disabled={stepIndex <= 0}
											onClick={() => {
												setPlaying(false)
												setStepIndex((i) => Math.max(0, i - 1))
											}}
											title="Step back"
										>
											&lt; Back
										</button>
										<button
											type="button"
											className="gm-btn gm-btn--primary"
											onClick={() => {
												if (stepIndex >= result.steps.length - 1) setStepIndex(0)
												setPlaying((p) => !p)
											}}
										>
											{playing ? 'Pause' : 'Play'}
										</button>
										<button
											type="button"
											className="gm-btn"
											disabled={stepIndex >= result.steps.length - 1}
											onClick={() => {
												setPlaying(false)
												setStepIndex((i) => Math.min(result.steps.length - 1, i + 1))
											}}
											title="Step forward"
										>
											Step &gt;
										</button>
										<button
											type="button"
											className="gm-btn"
											disabled={stepIndex >= result.steps.length - 1}
											onClick={() => {
												setPlaying(false)
												setStepIndex(result.steps.length - 1)
											}}
											title="Last step"
										>
											&gt;|
										</button>
										<input
											type="range"
											className="wp-slider"
											min={0}
											max={Math.max(0, result.steps.length - 1)}
											value={stepIndex}
											onChange={(e) => {
												setPlaying(false)
												setStepIndex(Number(e.target.value))
											}}
										/>
										<span className="wp-mono-sm">
											Step {stepIndex + 1} / {result.steps.length}
										</span>
									</div>

									<div className="wp-trace-grid">
										{/* Left: Trace Timeline */}
										<div className="wp-pane">
											<p className="gm-pane-title">EIP-3155 Execution Timeline</p>
											<div className="wp-step-list">
												{result.steps.map((s, idx) => (
													<button
														key={`${idx}-${s.pc}-${s.op}`}
														type="button"
														className="wp-step-row"
														data-current={idx === stepIndex}
														data-err={Boolean(s.error)}
														onClick={() => {
															setPlaying(false)
															setStepIndex(idx)
														}}
													>
														<span className="wp-step-idx">{idx}</span>
														<span className="wp-step-depth">d{s.depth}</span>
														<span className="wp-step-pc">0x{s.pc.toString(16).padStart(3, '0')}</span>
														<span className="wp-step-op">{s.opName}</span>
														<span className="wp-step-gas">{formatHexQty(s.gasCost)}g</span>
													</button>
												))}
											</div>
										</div>

										{/* Right: Live Frame State at Selected Step */}
										{currentStep && (
											<div className="wp-pane">
												<div className="wp-meters">
													<div className="gm-meter">
														<span className="gm-meter-label">Opcode</span>
														<span className="gm-meter-value">
															{currentStep.opName} (0x{currentStep.op.toString(16).padStart(2, '0')})
														</span>
													</div>
													<div className="gm-meter">
														<span className="gm-meter-label">Gas Left</span>
														<span className="gm-meter-value">{formatHexQty(currentStep.gas)}</span>
													</div>
													<div className="gm-meter">
														<span className="gm-meter-label">Step Cost</span>
														<span className="gm-meter-value">{formatHexQty(currentStep.gasCost)}</span>
													</div>
													<div className="gm-meter">
														<span className="gm-meter-label">Depth / Mem</span>
														<span className="gm-meter-value">
															d{currentStep.depth} · {currentStep.memSize}b
														</span>
													</div>
												</div>

												{currentStep.error && (
													<p className="gm-note gm-note--error">Fault: {currentStep.error}</p>
												)}

												<p className="gm-pane-title">
													Stack ({currentStep.stack.length} items, top first)
												</p>
												<div className="gm-stack">
													{currentStep.stack.length === 0 ? (
														<p className="gm-empty">empty</p>
													) : (
														currentStep.stack.map((word, i) => (
															<div
																key={`${i}-${word}`}
																className="gm-stack-item"
																data-top={i === currentStep.stack.length - 1}
															>
																<span className="gm-stack-index">
																	{currentStep.stack.length - 1 - i}
																</span>
																<span className="gm-stack-value">{word}</span>
															</div>
														))
													)}
												</div>

												<p className="gm-pane-title" style={{ marginTop: '0.85rem' }}>
													Memory ({currentStep.memSize} bytes)
												</p>
												<MemoryHexView memoryHex={currentStep.memory} />

												{currentStep.storage && Object.keys(currentStep.storage).length > 0 && (
													<>
														<p className="gm-pane-title" style={{ marginTop: '0.85rem' }}>
															Storage Snapshot
														</p>
														<div className="gm-stack" style={{ flexDirection: 'column' }}>
															{Object.entries(currentStep.storage).map(([slot, val]) => (
																<div key={slot} className="gm-stack-item">
																	<span className="gm-stack-index">{slot}</span>
																	<span className="gm-stack-value">{val}</span>
																</div>
															))}
														</div>
													</>
												)}

												<p className="gm-pane-title" style={{ marginTop: '0.85rem' }}>
													Return Data
												</p>
												<div className="wp-hex-box">
													{currentStep.returnData && currentStep.returnData !== '0x'
														? currentStep.returnData
														: '0x (empty)'}
												</div>
											</div>
										)}
									</div>
								</>
							)}
						</div>
					)}

					{/* TAB 2: Gas Flamegraph */}
					{activeTab === 'flamegraph' && (
						<div className="wp-panel">
							<div className="wp-fg-bar">
								<span className="wp-mono-muted">
									Source:{' '}
									{result.flamegraphNative
										? 'Native Zig FlamegraphCollector (evm_get_flamegraph_svg)'
										: 'EIP-3155 Trace Flamegraph'}
								</span>
								<div className="wp-fg-actions">
									<button
										type="button"
										className="gm-btn"
										onClick={() => setShowFolded((v) => !v)}
									>
										{showFolded ? 'Show SVG' : 'Show Folded Stacks'}
									</button>
									<button type="button" className="gm-btn" onClick={onDownloadSvg}>
										Download SVG
									</button>
								</div>
							</div>
							{showFolded ? (
								<pre className="wp-pre">{result.flamegraphFolded || '(no gas samples)'}</pre>
							) : (
								<div
									className="wp-svg-wrap"
									// SVG comes strictly from our own XML-escaped FlamegraphCollector / synthesizer.
									dangerouslySetInnerHTML={{ __html: result.flamegraphSvg }}
								/>
							)}
						</div>
					)}

					{/* TAB 3: Call Tree */}
					{activeTab === 'calls' && (
						<div className="wp-panel">
							{result.callTree ? (
								<CallTreeView node={result.callTree} />
							) : (
								<p className="gm-empty">No call frames recorded.</p>
							)}
						</div>
					)}

					{/* TAB 4: Output, Revert & Access List */}
					{activeTab === 'output' && (
						<div className="wp-panel wp-output-stack">
							<div>
								<p className="gm-pane-title">Return / Revert Data</p>
								<pre className="wp-pre">{result.outputHex}</pre>
							</div>
							{result.revertInfo && (
								<div>
									<p className="gm-pane-title">Decoded Revert JSON</p>
									<pre className="wp-pre">{JSON.stringify(result.revertInfo, null, 2)}</pre>
								</div>
							)}
							<div>
								<p className="gm-pane-title">Generated EIP-2930 Access List</p>
								<pre className="wp-pre">{JSON.stringify(result.accessList, null, 2)}</pre>
							</div>
							{result.stateChangesJson && (
								<div>
									<p className="gm-pane-title">Async State Changes (ready_to_commit)</p>
									<pre className="wp-pre">
										{JSON.stringify(JSON.parse(result.stateChangesJson), null, 2)}
									</pre>
								</div>
							)}
						</div>
					)}
				</div>
			)}
		</div>
	)
}

export default WasmPlayground

// ---------------------------------------------------------------------------
// Scoped Styles (reusing --tevm-* light-dark tokens from _root.css)
// ---------------------------------------------------------------------------

const PLAYGROUND_CSS = `
.wp-root {
	margin: 1.5rem 0 2.5rem;
	border: 1px solid var(--tevm-border);
	border-radius: var(--tevm-radius);
	background: var(--tevm-bg-raised);
	overflow: hidden;
}
.wp-header {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	justify-content: space-between;
	gap: 0.75rem;
	padding: 0.75rem 1rem;
	border-bottom: 1px solid var(--tevm-border);
	background: var(--tevm-bg-sunken);
}
.wp-mode-pills {
	display: flex;
	flex-wrap: wrap;
	gap: 0.4rem;
}
.wp-status {
	display: inline-flex;
	align-items: center;
	gap: 0.45rem;
	font-family: var(--tevm-mono);
	font-size: 0.74rem;
	color: var(--tevm-text-muted);
}
.wp-dot {
	width: 8px;
	height: 8px;
	border-radius: 999px;
	background: var(--tevm-text-muted);
}
.wp-dot--ready { background: #16a34a; }
.wp-dot--loading { background: #f59e0b; }
.wp-dot--missing, .wp-dot--error { background: #ef4444; }

.wp-banner {
	margin: 1rem;
	padding: 1rem;
	border: 1px solid var(--tevm-border-strong);
	border-left: 3px solid var(--tevm-accent);
	border-radius: var(--tevm-radius-sm);
	background: var(--tevm-bg-sunken);
}
.wp-banner-title {
	margin: 0 0 0.4rem;
	font-weight: 600;
	color: var(--tevm-text);
}
.wp-banner-desc {
	margin: 0 0 0.65rem;
	font-size: 0.86rem;
	color: var(--tevm-text-muted);
}
.wp-cmd {
	margin: 0 0 0.75rem;
	padding: 0.65rem 0.85rem;
	border-radius: var(--tevm-radius-sm);
	background: var(--tevm-terminal-bg);
	color: var(--tevm-term-text);
	font-family: var(--tevm-mono);
	font-size: 0.78rem;
	overflow-x: auto;
}
.wp-banner-actions {
	display: flex;
	flex-wrap: wrap;
	gap: 0.5rem;
	align-items: center;
}
.wp-file-label {
	display: inline-flex;
	align-items: center;
	cursor: pointer;
}
.wp-banner-err {
	margin: 0.55rem 0 0;
	font-family: var(--tevm-mono);
	font-size: 0.74rem;
	color: #dc2626;
}

.wp-controls {
	display: flex;
	flex-direction: column;
	gap: 0.75rem;
	padding: 1rem;
}
.wp-row-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(12rem, 1fr));
	gap: 0.7rem;
}
.wp-field {
	display: flex;
	flex-direction: column;
	gap: 0.28rem;
	font-size: 0.76rem;
	font-family: var(--tevm-mono);
	color: var(--tevm-text-muted);
}
.wp-field input,
.wp-field select,
.wp-field textarea {
	width: 100%;
	padding: 0.45rem 0.6rem;
	border: 1px solid var(--tevm-border-strong);
	border-radius: var(--tevm-radius-sm);
	background: var(--tevm-bg-sunken);
	color: var(--tevm-text);
	font-family: var(--tevm-mono);
	font-size: 0.78rem;
	resize: vertical;
}
.wp-inline-input {
	display: flex;
	gap: 0.4rem;
}
.wp-blurb {
	margin: 0;
	font-size: 0.83rem;
	line-height: 1.5;
	color: var(--tevm-text-muted);
}
.wp-run-bar {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 0.6rem;
}
.wp-summary-badges {
	display: flex;
	flex-wrap: wrap;
	gap: 0.4rem;
}
.wp-badge {
	padding: 0.22rem 0.55rem;
	border: 1px solid var(--tevm-border-strong);
	border-radius: 999px;
	background: var(--tevm-bg-sunken);
	color: var(--tevm-text);
	font-family: var(--tevm-mono);
	font-size: 0.72rem;
	font-weight: 600;
}
.wp-badge--ok {
	border-color: #16a34a66;
	background: #16a34a1c;
	color: light-dark(#15803d, #4ade80);
}
.wp-badge--err {
	border-color: #ef444466;
	background: #ef44441c;
	color: light-dark(#b91c1c, #f87171);
}
.wp-revert-box {
	padding: 0.65rem 0.8rem;
	border: 1px solid #ef444455;
	border-left: 3px solid #ef4444;
	border-radius: var(--tevm-radius-sm);
	background: #ef444412;
	font-family: var(--tevm-mono);
	font-size: 0.8rem;
	color: var(--tevm-text);
	word-break: break-word;
}
.wp-hops {
	border: 1px solid var(--tevm-border);
	border-radius: var(--tevm-radius-sm);
	background: var(--tevm-bg-sunken);
	padding: 0.45rem 0.7rem;
	font-family: var(--tevm-mono);
	font-size: 0.74rem;
}
.wp-hops pre {
	margin: 0.5rem 0 0;
	max-height: 10rem;
	overflow: auto;
	color: var(--tevm-text-muted);
}

.wp-results {
	border-top: 1px solid var(--tevm-border);
}
.wp-panel {
	padding: 1rem;
}
.wp-scrubber {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 0.4rem;
	margin-bottom: 0.9rem;
	padding: 0.6rem 0.75rem;
	border: 1px solid var(--tevm-border);
	border-radius: var(--tevm-radius-sm);
	background: var(--tevm-bg-sunken);
}
.wp-slider {
	flex: 1 1 10rem;
	accent-color: var(--tevm-accent);
}
.wp-trace-grid {
	display: grid;
	grid-template-columns: minmax(14rem, 1fr) minmax(18rem, 1.55fr);
	gap: 0.9rem;
}
@media (max-width: 780px) {
	.wp-trace-grid {
		grid-template-columns: 1fr;
	}
}
.wp-pane {
	border: 1px solid var(--tevm-border);
	border-radius: var(--tevm-radius-sm);
	padding: 0.75rem;
	background: var(--tevm-bg-sunken);
	min-width: 0;
}
.wp-step-list {
	max-height: 26rem;
	overflow-y: auto;
	display: flex;
	flex-direction: column;
	gap: 2px;
}
.wp-step-row {
	display: grid;
	grid-template-columns: 2.5rem 1.8rem 3.3rem 1fr auto;
	align-items: center;
	gap: 0.35rem;
	padding: 0.28rem 0.45rem;
	border: 1px solid transparent;
	border-radius: 4px;
	background: transparent;
	color: var(--tevm-text);
	font-family: var(--tevm-mono);
	font-size: 0.74rem;
	text-align: left;
	cursor: pointer;
}
.wp-step-row:hover {
	background: var(--tevm-accent-soft);
}
.wp-step-row[data-current='true'] {
	border-color: var(--tevm-accent);
	background: var(--tevm-accent-soft);
	font-weight: 700;
}
.wp-step-row[data-err='true'] {
	color: light-dark(#b91c1c, #f87171);
}
.wp-step-idx, .wp-step-depth, .wp-step-pc, .wp-step-gas {
	color: var(--tevm-text-muted);
}
.wp-step-op {
	color: var(--tevm-accent);
	font-weight: 600;
}
.wp-meters {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(7.5rem, 1fr));
	gap: 0.45rem;
	margin-bottom: 0.75rem;
}
.wp-mem-wrap {
	max-height: 11rem;
	overflow: auto;
	border: 1px solid var(--tevm-border);
	border-radius: 4px;
	padding: 0.45rem 0.55rem;
	background: var(--tevm-bg-raised);
	font-family: var(--tevm-mono);
	font-size: 0.7rem;
}
.wp-mem-row {
	display: grid;
	grid-template-columns: 3.6rem 1fr auto;
	gap: 0.6rem;
	white-space: pre;
}
.wp-mem-off { color: var(--tevm-accent); }
.wp-mem-hex { color: var(--tevm-text); }
.wp-mem-ascii { color: var(--tevm-text-muted); }
.wp-hex-box {
	padding: 0.45rem 0.6rem;
	border: 1px solid var(--tevm-border);
	border-radius: 4px;
	background: var(--tevm-bg-raised);
	font-family: var(--tevm-mono);
	font-size: 0.72rem;
	word-break: break-all;
	color: var(--tevm-text);
}

.wp-fg-bar {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	justify-content: space-between;
	gap: 0.5rem;
	margin-bottom: 0.75rem;
}
.wp-fg-actions {
	display: flex;
	gap: 0.4rem;
}
.wp-svg-wrap {
	border: 1px solid var(--tevm-border);
	border-radius: var(--tevm-radius-sm);
	overflow-x: auto;
	background: #fafafa;
	padding: 0.4rem;
}
.wp-svg-wrap svg {
	width: 100%;
	height: auto;
	display: block;
}
.wp-pre {
	margin: 0;
	padding: 0.75rem;
	border: 1px solid var(--tevm-border);
	border-radius: var(--tevm-radius-sm);
	background: var(--tevm-bg-sunken);
	font-family: var(--tevm-mono);
	font-size: 0.74rem;
	overflow: auto;
	max-height: 22rem;
	color: var(--tevm-text);
}
.wp-output-stack {
	display: flex;
	flex-direction: column;
	gap: 0.9rem;
}
.wp-call-node {
	margin-bottom: 0.5rem;
}
.wp-call-card {
	padding: 0.65rem 0.8rem;
	border: 1px solid var(--tevm-border);
	border-left: 3px solid var(--tevm-accent);
	border-radius: var(--tevm-radius-sm);
	background: var(--tevm-bg-sunken);
}
.wp-call-card--err {
	border-left-color: #ef4444;
}
.wp-call-head {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 0.5rem;
}
.wp-pill {
	padding: 0.12rem 0.45rem;
	border-radius: 4px;
	background: var(--tevm-accent-soft);
	color: var(--tevm-accent);
	font-family: var(--tevm-mono);
	font-size: 0.72rem;
	font-weight: 700;
}
.wp-call-err {
	margin-top: 0.35rem;
	font-family: var(--tevm-mono);
	font-size: 0.76rem;
	color: light-dark(#b91c1c, #f87171);
}
.wp-call-meta {
	display: flex;
	flex-wrap: wrap;
	gap: 0.8rem;
	margin-top: 0.35rem;
	font-family: var(--tevm-mono);
	font-size: 0.72rem;
	color: var(--tevm-text-muted);
}
.wp-mono-sm {
	font-family: var(--tevm-mono);
	font-size: 0.76rem;
	color: var(--tevm-text);
}
.wp-mono-muted {
	font-family: var(--tevm-mono);
	font-size: 0.74rem;
	color: var(--tevm-text-muted);
}
`

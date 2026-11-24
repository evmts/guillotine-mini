import type { ReactNode } from 'react'

function DiagramFrame({
	title,
	badge,
	caption,
	children,
}: {
	title: string
	badge?: string
	caption?: ReactNode
	children: ReactNode
}) {
	return (
		<figure className="gm-diagram">
			<div className="gm-diagram-header">
				<span className="gm-diagram-title">{title}</span>
				{badge ? <span className="gm-diagram-badge">{badge}</span> : null}
			</div>
			<div className="gm-diagram-canvas">{children}</div>
			{caption ? <figcaption className="gm-diagram-caption">{caption}</figcaption> : null}
		</figure>
	)
}

const F = {
	mono: "ui-monospace, 'SF Mono', SFMono-Regular, Menlo, Consolas, monospace",
	sans: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
	accent: 'var(--tevm-accent)',
	accentSoft: 'var(--tevm-accent-soft)',
	raised: 'var(--tevm-bg-raised)',
	sunken: 'var(--tevm-bg-sunken)',
	border: 'var(--tevm-border-strong)',
	text: 'var(--tevm-text)',
	muted: 'var(--tevm-text-muted)',
	green: 'light-dark(#059669, #32d583)',
	amber: 'light-dark(#d97706, #fdb022)',
	red: 'light-dark(#dc2626, #f97066)',
	purple: 'light-dark(#7c3aed, #a78bfa)',
} as const

export function EvmArchitectureDiagram() {
	return (
		<DiagramFrame
			title="Guillotine Mini — Three-Layer Execution Architecture"
			badge="src/*.zig"
			caption="Evm owns transaction-scoped state and nested call orchestration. Frame is a pure bytecode interpreter operating on stack, memory, and PC. HostInterface is an optional vtable for external state."
		>
			<svg viewBox="0 0 820 420" role="img" aria-label="Guillotine Mini architecture showing Evm, Frame, HostInterface, and Voltaire">
				<defs>
					<marker id="gm-arrow" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.accent} />
					</marker>
					<marker id="gm-arrow-muted" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.muted} />
					</marker>
				</defs>

				{/* Caller entry */}
				<rect x="260" y="10" width="300" height="40" rx="8" fill={F.sunken} stroke={F.accent} strokeWidth="1.5" />
				<text x="410" y="34" textAnchor="middle" fill={F.text} fontFamily={F.mono} fontSize="13" fontWeight="700">
					vm.call(CallParams)  /  root_c.zig
				</text>
				<line x1="410" y1="50" x2="410" y2="74" stroke={F.accent} strokeWidth="1.75" markerEnd="url(#gm-arrow)" />

				{/* Evm Orchestrator box */}
				<rect x="30" y="76" width="760" height="122" rx="10" fill={F.raised} stroke={F.accent} strokeWidth="1.75" />
				<rect x="30" y="76" width="760" height="28" rx="10" fill={F.accentSoft} />
				<text x="46" y="95" fill={F.accent} fontFamily={F.mono} fontSize="12" fontWeight="700">
					Evm(config)  ·  src/evm.zig  —  Transaction Orchestrator
				</text>
				<text x="774" y="95" textAnchor="end" fill={F.muted} fontFamily={F.mono} fontSize="11">
					ArenaAllocator (freed on deinit)
				</text>

				{/* Four internal Evm subsystems */}
				{[
					{ x: 46, w: 170, t: 'Storage', s1: 'persistent · original', s2: 'transient (EIP-1153)' },
					{ x: 228, w: 170, t: 'AccessListManager', s1: 'warm/cold addresses', s2: 'warm/cold slots (2929)' },
					{ x: 410, w: 176, t: 'Snapshot Stacks', s1: 'balances · nonces · code', s2: 'copy-on-write rollback' },
					{ x: 598, w: 176, t: 'Nested Calls & Logs', s1: 'inner_call · inner_create', s2: 'gas_refund · Tracer' },
				].map((b) => (
					<g key={b.t}>
						<rect x={b.x} y="114" width={b.w} height="70" rx="6" fill={F.sunken} stroke={F.border} />
						<text x={b.x + 10} y="135" fill={F.text} fontFamily={F.mono} fontSize="11.5" fontWeight="700">
							{b.t}
						</text>
						<text x={b.x + 10} y="154" fill={F.muted} fontFamily={F.sans} fontSize="11">
							{b.s1}
						</text>
						<text x={b.x + 10} y="170" fill={F.muted} fontFamily={F.sans} fontSize="11">
							{b.s2}
						</text>
					</g>
				))}

				{/* Arrows down from Evm to Frame and Host */}
				<line x1="250" y1="198" x2="250" y2="232" stroke={F.accent} strokeWidth="1.75" markerEnd="url(#gm-arrow)" />
				<text x="260" y="219" fill={F.muted} fontFamily={F.mono} fontSize="10.5">
					frames stack (depth ≤ 1024)
				</text>

				<line x1="600" y1="198" x2="600" y2="232" stroke={F.muted} strokeWidth="1.5" strokeDasharray="4 3" markerEnd="url(#gm-arrow-muted)" />
				<text x="610" y="219" fill={F.muted} fontFamily={F.mono} fontSize="10.5">
					optional vtable (host != null)
				</text>

				{/* Frame box */}
				<rect x="30" y="234" width="430" height="104" rx="10" fill={F.raised} stroke={F.border} strokeWidth="1.5" />
				<text x="46" y="256" fill={F.text} fontFamily={F.mono} fontSize="12" fontWeight="700">
					Frame(config)  ·  src/frame.zig  —  Bytecode Interpreter
				</text>
				{[
					{ x: 46, w: 122, t: 'Stack', s: '1024 × u256' },
					{ x: 178, w: 132, t: 'Memory', s: 'byte-addressed · 32B' },
					{ x: 320, w: 126, t: 'Bytecode', s: 'JUMPDEST bitmap' },
				].map((f) => (
					<g key={f.t}>
						<rect x={f.x} y="268" width={f.w} height="56" rx="6" fill={F.sunken} stroke={F.border} />
						<text x={f.x + 10} y="290" fill={F.accent} fontFamily={F.mono} fontSize="11.5" fontWeight="700">
							{f.t}
						</text>
						<text x={f.x + 10} y="308" fill={F.muted} fontFamily={F.sans} fontSize="10.5">
							{f.s}
						</text>
					</g>
				))}

				{/* HostInterface box */}
				<rect x="484" y="234" width="306" height="104" rx="10" fill={F.raised} stroke={F.border} strokeWidth="1.5" strokeDasharray="5 3" />
				<text x="500" y="256" fill={F.text} fontFamily={F.mono} fontSize="12" fontWeight="700">
					HostInterface  ·  src/host.zig
				</text>
				<text x="500" y="278" fill={F.muted} fontFamily={F.mono} fontSize="10.5">
					get/setBalance · get/setCode
				</text>
				<text x="500" y="296" fill={F.muted} fontFamily={F.mono} fontSize="10.5">
					get/setStorage · get/setNonce
				</text>
				<text x="500" y="314" fill={F.muted} fontFamily={F.mono} fontSize="10.5">
					accountExists? · deleteAccount?
				</text>

				{/* Voltaire Foundation bar */}
				<rect x="30" y="360" width="760" height="48" rx="8" fill={F.sunken} stroke={F.border} />
				<text x="46" y="381" fill={F.text} fontFamily={F.mono} fontSize="12" fontWeight="700">
					Voltaire  (@import("voltaire") · "crypto" · "precompiles")
				</text>
				<text x="46" y="398" fill={F.muted} fontFamily={F.sans} fontSize="11">
					Address · Hardfork · GasConstants · RLP · Log · Keccak256 · secp256k1 · BN254 · BLS12-381 · KZG · P256VERIFY
				</text>
			</svg>
		</DiagramFrame>
	)
}

export function CallLifecycleDiagram() {
	return (
		<DiagramFrame
			title="Inside vm.call(params) — Exact Execution Order"
			badge="src/evm.zig · call()"
			caption="Step 3 resets per-transaction state (original and transient storage, warm sets, logs, refunds) but keeps balances, nonces, code, and committed storage. Step 4 reads the target code after that reset."
		>
			<svg viewBox="0 0 820 270" role="img" aria-label="Step-by-step lifecycle of vm.call in Guillotine Mini">
				<defs>
					<marker id="gm-lc-arr" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.accent} />
					</marker>
					<marker id="gm-lc-green" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.green} />
					</marker>
					<marker id="gm-lc-red" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.red} />
					</marker>
				</defs>

				{/* Top row: 4 sequential boxes */}
				{[
					{ x: 16, n: '1', t: 'Validate', d1: 'input ≤ 4 MB', d2: 'initcode ≤ 48 KB' },
					{ x: 214, n: '2', t: 'Resolve Target', d1: 'CREATE/2 addr or to', d2: 'sender = vm.origin' },
					{ x: 412, n: '3', t: 'Reset & Warm', d1: 'initTransactionState()', d2: 'preWarmTransaction()' },
					{ x: 610, n: '4', t: 'Dispatch', d1: 'CREATE, or get_code()', d2: '→ Precompile / Frame' },
				].map((s, i) => (
					<g key={s.n}>
						<rect x={s.x} y="18" width="182" height="76" rx="8" fill={F.raised} stroke={i === 2 ? F.amber : F.accent} strokeWidth="1.5" />
						<circle cx={s.x + 18} cy="36" r="10" fill={i === 2 ? F.amber : F.accent} />
						<text x={s.x + 18} y="40" textAnchor="middle" fill="#fff" fontFamily={F.mono} fontSize="11" fontWeight="700">
							{s.n}
						</text>
						<text x={s.x + 36} y="40" fill={F.text} fontFamily={F.mono} fontSize="12" fontWeight="700">
							{s.t}
						</text>
						<text x={s.x + 12} y="62" fill={F.muted} fontFamily={F.mono} fontSize="10.5">
							{s.d1}
						</text>
						<text x={s.x + 12} y="80" fill={F.muted} fontFamily={F.mono} fontSize="10.5">
							{s.d2}
						</text>
						{i < 3 ? (
							<line x1={s.x + 182} y1="56" x2={s.x + 196} y2="56" stroke={F.accent} strokeWidth="1.75" markerEnd="url(#gm-lc-arr)" />
						) : null}
					</g>
				))}

				{/* Branching down from step 4 */}
				<path d="M 701 94 L 701 120 L 210 120 L 210 140" fill="none" stroke={F.green} strokeWidth="1.6" markerEnd="url(#gm-lc-green)" />
				<path d="M 701 94 L 701 120 L 605 120 L 605 140" fill="none" stroke={F.red} strokeWidth="1.6" markerEnd="url(#gm-lc-red)" />

				{/* Success path */}
				<rect x="40" y="142" width="340" height="62" rx="8" fill={F.sunken} stroke={F.green} strokeWidth="1.4" />
				<text x="56" y="164" fill={F.green} fontFamily={F.mono} fontSize="11.5" fontWeight="700">
					STOP / RETURN  (success = true)
				</text>
				<text x="56" y="183" fill={F.muted} fontFamily={F.sans} fontSize="11">
					Copy output &amp; logs · expose refund_counter · commit state
				</text>
				<text x="56" y="197" fill={F.muted} fontFamily={F.mono} fontSize="10">
					gas_left = frame.gas_remaining
				</text>

				{/* Revert / Error path */}
				<rect x="430" y="142" width="362" height="62" rx="8" fill={F.sunken} stroke={F.red} strokeWidth="1.4" />
				<text x="446" y="164" fill={F.red} fontFamily={F.mono} fontSize="11.5" fontWeight="700">
					REVERT / CallError  (success = false)
				</text>
				<text x="446" y="183" fill={F.muted} fontFamily={F.sans} fontSize="11">
					Reverse value transfer · restore snapshots · drop logs
				</text>
				<text x="446" y="197" fill={F.muted} fontFamily={F.mono} fontSize="10">
					REVERT keeps gas_left + output; errors burn gas &amp; set error_info
				</text>

				{/* End of transaction bar */}
				<rect x="40" y="220" width="752" height="36" rx="6" fill={F.raised} stroke={F.border} />
				<text x="416" y="242" textAnchor="middle" fill={F.text} fontFamily={F.mono} fontSize="11">
					5. End-of-tx cleanup: clear warm sets → clear transient storage (EIP-1153) → delete selfdestructed (EIP-6780) &amp; empty accounts
				</text>
			</svg>
		</DiagramFrame>
	)
}

export function StateSnapshotDiagram() {
	return (
		<DiagramFrame
			title="Three Storage Maps & Copy-on-Write Rollback"
			badge="src/storage.zig + src/evm.zig"
			caption="On a nested call, the EVM snapshots storage, balances, nonces, code, warm sets, and logs. If Call B reverts, only Call B's changes unwind — Call A continues intact."
		>
			<svg viewBox="0 0 820 300" role="img" aria-label="Storage maps and copy-on-write snapshot rollback across nested calls">
				<defs>
					<marker id="gm-st-arr" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.accent} />
					</marker>
					<marker id="gm-st-red" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.red} />
					</marker>
				</defs>

				{/* Left column: Three storage maps */}
				<text x="24" y="24" fill={F.muted} fontFamily={F.mono} fontSize="11" fontWeight="700">
					THREE MAPS INSIDE Storage
				</text>

				{[
					{ y: 36, c: F.accent, t: '1. storage (persistent)', d1: 'Current value during tx.', d2: 'Reverts on frame rollback; persists on commit.' },
					{ y: 122, c: F.amber, t: '2. original_storage', d1: 'Captured once on first SSTORE in tx.', d2: 'Drives EIP-2200/3529 gas & refund math.' },
					{ y: 208, c: F.purple, t: '3. transient (EIP-1153)', d1: 'TLOAD / TSTORE (always 100 gas).', d2: 'Reverts on frame rollback; wiped at tx end.' },
				].map((m) => (
					<g key={m.t}>
						<rect x="24" y={m.y} width="320" height="72" rx="8" fill={F.raised} stroke={m.c} strokeWidth="1.5" />
						<text x="38" y={m.y + 23} fill={m.c} fontFamily={F.mono} fontSize="12" fontWeight="700">
							{m.t}
						</text>
						<text x="38" y={m.y + 43} fill={F.text} fontFamily={F.sans} fontSize="11.5">
							{m.d1}
						</text>
						<text x="38" y={m.y + 60} fill={F.muted} fontFamily={F.sans} fontSize="11">
							{m.d2}
						</text>
					</g>
				))}

				{/* Right column: Nested call timeline */}
				<text x="386" y="24" fill={F.muted} fontFamily={F.mono} fontSize="11" fontWeight="700">
					NESTED CALL SNAPSHOT STACK
				</text>

				{/* Depth 0 */}
				<rect x="386" y="36" width="410" height="62" rx="8" fill={F.sunken} stroke={F.green} strokeWidth="1.4" />
				<text x="402" y="57" fill={F.green} fontFamily={F.mono} fontSize="11.5" fontWeight="700">
					Depth 0 · Contract A
				</text>
				<text x="402" y="76" fill={F.text} fontFamily={F.mono} fontSize="11">
					SSTORE(slot 0, 10) → snapshot #1 pushed → CALL B
				</text>

				<line x1="590" y1="98" x2="590" y2="120" stroke={F.accent} strokeWidth="1.6" markerEnd="url(#gm-st-arr)" />

				{/* Depth 1 - reverts */}
				<rect x="414" y="122" width="382" height="68" rx="8" fill={F.raised} stroke={F.red} strokeWidth="1.5" strokeDasharray="5 3" />
				<text x="430" y="143" fill={F.red} fontFamily={F.mono} fontSize="11.5" fontWeight="700">
					Depth 1 · Contract B  →  REVERT
				</text>
				<text x="430" y="162" fill={F.text} fontFamily={F.mono} fontSize="11">
					SSTORE(slot 0, 99) · TSTORE(slot 1, 7) · LOG1(...)
				</text>
				<text x="430" y="179" fill={F.red} fontFamily={F.sans} fontSize="10.5">
					All writes rolled back to snapshot #1; B's logs dropped.
				</text>

				<line x1="590" y1="190" x2="590" y2="212" stroke={F.red} strokeWidth="1.6" markerEnd="url(#gm-st-red)" />

				{/* Back in Depth 0 */}
				<rect x="386" y="214" width="410" height="66" rx="8" fill={F.sunken} stroke={F.green} strokeWidth="1.5" />
				<text x="402" y="236" fill={F.green} fontFamily={F.mono} fontSize="11.5" fontWeight="700">
					Depth 0 · Contract A resumes  →  RETURN
				</text>
				<text x="402" y="255" fill={F.text} fontFamily={F.mono} fontSize="11">
					SLOAD(slot 0) == 10   ·   TLOAD(slot 1) == 0
				</text>
				<text x="402" y="270" fill={F.muted} fontFamily={F.sans} fontSize="10.5">
					CALL pushed 0 onto A's stack; A keeps slot 0 = 10 and finishes cleanly.
				</text>
			</svg>
		</DiagramFrame>
	)
}

export function WasmBoundaryDiagram() {
	return (
		<DiagramFrame
			title="WASI Preview 1 Reactor Boundary"
			badge="zig build wasm"
			caption="The WASM artifact bundles Zig EVM + Voltaire + Rust crypto (BN254, BLS12-381, KZG) with zero npm dependencies. Hosts allocate transfer buffers via evm_alloc/evm_free and always recreate typed-array views after calls because linear memory may grow."
		>
			<svg viewBox="0 0 820 276" role="img" aria-label="Host JS and WASI Preview 1 WebAssembly linear memory boundary">
				<defs>
					<marker id="gm-w-arr" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.accent} />
					</marker>
				</defs>

				{/* Host side */}
				<rect x="20" y="20" width="230" height="236" rx="10" fill={F.raised} stroke={F.border} strokeWidth="1.5" />
				<text x="36" y="44" fill={F.text} fontFamily={F.mono} fontSize="12" fontWeight="700">
					Host (Node 22+ / Browser)
				</text>
				<rect x="34" y="60" width="202" height="54" rx="6" fill={F.sunken} stroke={F.border} />
				<text x="44" y="80" fill={F.accent} fontFamily={F.mono} fontSize="11" fontWeight="700">
					1. WASI.initialize(inst)
				</text>
				<text x="44" y="99" fill={F.muted} fontFamily={F.sans} fontSize="10.5">
					Calls _initialize once (no _start)
				</text>

				<rect x="34" y="126" width="202" height="54" rx="6" fill={F.sunken} stroke={F.border} />
				<text x="44" y="146" fill={F.accent} fontFamily={F.mono} fontSize="11" fontWeight="700">
					2. evm_alloc / evm_free
				</text>
				<text x="44" y="165" fill={F.muted} fontFamily={F.sans} fontSize="10.5">
					Copy inputs; refresh buffer view
				</text>

				<rect x="34" y="192" width="202" height="50" rx="6" fill={F.sunken} stroke={F.purple} strokeDasharray="4 3" />
				<text x="44" y="212" fill={F.purple} fontFamily={F.mono} fontSize="10.5" fontWeight="700">
					env imports (optional)
				</text>
				<text x="44" y="229" fill={F.muted} fontFamily={F.mono} fontSize="9.8">
					js_opcode / js_precompile → 0
				</text>

				{/* Arrows across boundary */}
				<line x1="250" y1="88" x2="310" y2="88" stroke={F.accent} strokeWidth="1.75" markerEnd="url(#gm-w-arr)" />
				<line x1="250" y1="154" x2="310" y2="154" stroke={F.accent} strokeWidth="1.75" markerEnd="url(#gm-w-arr)" />
				<line x1="310" y1="217" x2="250" y2="217" stroke={F.purple} strokeWidth="1.5" strokeDasharray="4 3" markerEnd="url(#gm-w-arr)" />

				{/* Linear memory column */}
				<rect x="312" y="20" width="174" height="236" rx="10" fill={F.sunken} stroke={F.amber} strokeWidth="1.5" />
				<text x="399" y="44" textAnchor="middle" fill={F.amber} fontFamily={F.mono} fontSize="12" fontWeight="700">
					Linear Memory
				</text>
				<text x="399" y="64" textAnchor="middle" fill={F.muted} fontFamily={F.mono} fontSize="10">
					exports.memory.buffer
				</text>
				{[
					{ y: 80, t: 'fork name bytes' },
					{ y: 112, t: 'bytecode & calldata' },
					{ y: 144, t: '20B addr · 32B u256' },
					{ y: 176, t: 'output & log buffers' },
					{ y: 208, t: 'EvmHandle (opaque)' },
				].map((m) => (
					<g key={m.t}>
						<rect x="326" y={m.y} width="146" height="24" rx="4" fill={F.raised} stroke={F.border} />
						<text x="399" y={m.y + 16} textAnchor="middle" fill={F.text} fontFamily={F.mono} fontSize="10.2">
							{m.t}
						</text>
					</g>
				))}

				{/* Arrow to WASM core */}
				<line x1="486" y1="138" x2="528" y2="138" stroke={F.accent} strokeWidth="1.75" markerEnd="url(#gm-w-arr)" />

				{/* WASM module internals */}
				<rect x="530" y="20" width="270" height="236" rx="10" fill={F.raised} stroke={F.accent} strokeWidth="1.75" />
				<text x="546" y="44" fill={F.accent} fontFamily={F.mono} fontSize="12" fontWeight="700">
					guillotine_mini.wasm
				</text>
				<text x="546" y="62" fill={F.muted} fontFamily={F.mono} fontSize="10">
					wasm32-wasi · ReleaseSmall
				</text>

				<rect x="546" y="76" width="238" height="46" rx="6" fill={F.sunken} stroke={F.border} />
				<text x="558" y="96" fill={F.text} fontFamily={F.mono} fontSize="11" fontWeight="700">
					C ABI  (src/root_c.zig)
				</text>
				<text x="558" y="112" fill={F.muted} fontFamily={F.sans} fontSize="10.5">
					42 exported evm_* symbols
				</text>

				<rect x="546" y="134" width="238" height="46" rx="6" fill={F.sunken} stroke={F.border} />
				<text x="558" y="154" fill={F.text} fontFamily={F.mono} fontSize="11" fontWeight="700">
					Zig EVM  (evm.zig + frame.zig)
				</text>
				<text x="558" y="170" fill={F.muted} fontFamily={F.sans} fontSize="10.5">
					Frontier → Osaka interpreter
				</text>

				<rect x="546" y="192" width="238" height="50" rx="6" fill={F.sunken} stroke={F.green} />
				<text x="558" y="212" fill={F.green} fontFamily={F.mono} fontSize="11" fontWeight="700">
					Linked Crypto Precompiles
				</text>
				<text x="558" y="229" fill={F.muted} fontFamily={F.sans} fontSize="10.5">
					SHA256 · BN254 · BLS12-381 · KZG
				</text>
			</svg>
		</DiagramFrame>
	)
}

export function AsyncProtocolDiagram() {
	return (
		<DiagramFrame
			title="Yield / Resume Async State-Injection Protocol"
			badge="evm_call_ffi + evm_continue_ffi"
			caption="Because Zig and WASM execution are synchronous, the EVM yields an AsyncRequest whenever it hits a cold external state miss. The host fetches the data (from RPC, Postgres, or RocksDB) and resumes execution."
		>
			<svg viewBox="0 0 820 278" role="img" aria-label="Sequence diagram of async state injection via evm_call_ffi and evm_continue_ffi">
				<defs>
					<marker id="gm-sq-arr" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.accent} />
					</marker>
					<marker id="gm-sq-amb" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.amber} />
					</marker>
					<marker id="gm-sq-grn" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
						<path d="M 0 1.5 L 9 5 L 0 8.5 z" fill={F.green} />
					</marker>
				</defs>

				{/* Lifelines */}
				{[
					{ x: 130, t: 'Host Application' },
					{ x: 430, t: 'Guillotine Mini (FFI)' },
					{ x: 700, t: 'External DB / RPC' },
				].map((l) => (
					<g key={l.t}>
						<rect x={l.x - 95} y="14" width="190" height="32" rx="6" fill={F.sunken} stroke={F.border} />
						<text x={l.x} y="34" textAnchor="middle" fill={F.text} fontFamily={F.mono} fontSize="11.5" fontWeight="700">
							{l.t}
						</text>
						<line x1={l.x} y1="46" x2={l.x} y2="262" stroke={F.border} strokeWidth="1.2" strokeDasharray="4 4" />
					</g>
				))}

				{/* Step 1: start */}
				<line x1="130" y1="76" x2="424" y2="76" stroke={F.accent} strokeWidth="1.6" markerEnd="url(#gm-sq-arr)" />
				<text x="277" y="69" textAnchor="middle" fill={F.text} fontFamily={F.mono} fontSize="10.8">
					1. evm_enable_storage_injector() → evm_call_ffi(h, &amp;req)
				</text>

				{/* Step 2: yield */}
				<line x1="430" y1="112" x2="136" y2="112" stroke={F.amber} strokeWidth="1.6" markerEnd="url(#gm-sq-amb)" />
				<text x="283" y="105" textAnchor="middle" fill={F.amber} fontFamily={F.mono} fontSize="10.8">
					2. req.output_type = 1..4 (NEED_STORAGE / BALANCE / CODE / NONCE)
				</text>

				{/* Step 3: host fetches */}
				<line x1="130" y1="146" x2="694" y2="146" stroke={F.accent} strokeWidth="1.4" strokeDasharray="5 3" markerEnd="url(#gm-sq-arr)" />
				<text x="565" y="139" textAnchor="middle" fill={F.muted} fontFamily={F.mono} fontSize="10.5">
					3. await rpc.getStorageAt(addr, slot)
				</text>

				{/* Step 4: continue */}
				<line x1="130" y1="180" x2="424" y2="180" stroke={F.accent} strokeWidth="1.6" markerEnd="url(#gm-sq-arr)" />
				<text x="277" y="173" textAnchor="middle" fill={F.text} fontFamily={F.mono} fontSize="10.8">
					4. evm_continue_ffi(h, type=1..4, packed_bytes, len, &amp;req)
				</text>

				{/* Step 5: ready to commit */}
				<line x1="430" y1="214" x2="136" y2="214" stroke={F.purple} strokeWidth="1.6" markerEnd="url(#gm-sq-arr)" />
				<text x="283" y="207" textAnchor="middle" fill={F.purple} fontFamily={F.mono} fontSize="10.8">
					5. output_type = 5 (READY_TO_COMMIT) · changes JSON
				</text>

				{/* Step 6: finish */}
				<line x1="130" y1="248" x2="424" y2="248" stroke={F.green} strokeWidth="1.6" markerEnd="url(#gm-sq-grn)" />
				<text x="277" y="241" textAnchor="middle" fill={F.green} fontFamily={F.mono} fontSize="10.8">
					6. evm_continue_ffi(h, type=5, ...) → output_type = 0 (RESULT)
				</text>
			</svg>
		</DiagramFrame>
	)
}

export function TevmStackDiagram() {
	return (
		<DiagramFrame
			title="Where Guillotine Mini Sits in the Tevm Family"
			badge="ecosystem"
			caption="Voltaire supplies primitives and cryptography; Guillotine Mini is the readable execution engine; Guillotine wraps it in a full client; Tevm exposes the family to TypeScript. ZEVM is a speed-first sibling checked against Guillotine Mini."
		>
			<svg viewBox="0 0 820 296" role="img" aria-label="Layered Tevm family stack diagram">
				{/* Main vertical stack (left 540px) */}
				{[
					{ y: 18, h: 56, c: F.border, t: 'Tevm  (tevm.sh)', s: 'TypeScript EVM, Solidity bundler, viem/ethers tooling, WASM/FFI consumers' },
					{ y: 84, h: 56, c: F.border, t: 'Guillotine  (guillotine.tevm.sh)', s: 'Full Zig execution client: blocks, MPT trie, world state, txpool, JSON-RPC, Engine API, devp2p' },
					{ y: 150, h: 64, c: F.accent, t: 'Guillotine Mini  (mini.tevm.sh)  ◀  YOU ARE HERE', s: 'Spec-first EVM engine: Frame interpreter, gas, hardforks (Frontier → Osaka), precompiles, EIP-3155 tracing' },
					{ y: 224, h: 56, c: F.border, t: 'Voltaire  (voltaire.tevm.sh)', s: 'Zig primitives & crypto: Address, U256, Hardfork, RLP, Keccak, secp256k1, BN254, BLS12-381, KZG' },
				].map((row, i) => (
					<g key={row.t}>
						<rect
							x="20"
							y={row.y}
							width="560"
							height={row.h}
							rx="8"
							fill={i === 2 ? F.accentSoft : F.raised}
							stroke={row.c}
							strokeWidth={i === 2 ? 2 : 1.3}
						/>
						<text x="36" y={row.y + 23} fill={i === 2 ? F.accent : F.text} fontFamily={F.mono} fontSize="12" fontWeight="700">
							{row.t}
						</text>
						<text x="36" y={row.y + 43} fill={F.muted} fontFamily={F.sans} fontSize="11">
							{row.s}
						</text>
					</g>
				))}

				{/* Sibling ZEVM box on the right */}
				<rect x="606" y="150" width="194" height="130" rx="8" fill={F.sunken} stroke={F.amber} strokeWidth="1.5" strokeDasharray="5 3" />
				<text x="622" y="175" fill={F.amber} fontFamily={F.mono} fontSize="12" fontWeight="700">
					ZEVM  (sibling)
				</text>
				<text x="622" y="198" fill={F.text} fontFamily={F.sans} fontSize="11">
					Performance-tuned EVM.
				</text>
				<text x="622" y="216" fill={F.muted} fontFamily={F.sans} fontSize="11">
					Uses Guillotine Mini as its
				</text>
				<text x="622" y="232" fill={F.muted} fontFamily={F.sans} fontSize="11">
					readable reference oracle
				</text>
				<text x="622" y="248" fill={F.muted} fontFamily={F.sans} fontSize="11">
					&amp; trace differential target.
				</text>
				<line x1="580" y1="182" x2="606" y2="182" stroke={F.amber} strokeWidth="1.5" strokeDasharray="3 3" />
			</svg>
		</DiagramFrame>
	)
}

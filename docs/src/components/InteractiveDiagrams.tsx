'use client'

import { useState } from 'react'

type GasTab = 'access' | 'memory' | 'sstore'

export function GasCostVisual() {
	const [tab, setTab] = useState<GasTab>('access')

	return (
		<figure className="gm-diagram">
			<div className="gm-diagram-header">
				<span className="gm-diagram-title">EVM Gas Mechanics (Berlin → Osaka)</span>
				<span className="gm-diagram-badge">interactive</span>
			</div>
			<div className="gm-tabs" role="tablist">
				<button
					type="button"
					className="gm-tab"
					data-active={tab === 'access'}
					onClick={() => setTab('access')}
				>
					Cold vs Warm (EIP-2929)
				</button>
				<button
					type="button"
					className="gm-tab"
					data-active={tab === 'memory'}
					onClick={() => setTab('memory')}
				>
					Memory Expansion Curve
				</button>
				<button
					type="button"
					className="gm-tab"
					data-active={tab === 'sstore'}
					onClick={() => setTab('sstore')}
				>
					SSTORE &amp; Refunds (EIP-3529)
				</button>
			</div>

			{tab === 'access' && (
				<div className="gm-gas-grid">
					<div className="gm-gas-card">
						<div className="gm-gas-card-label">Cold Account Access</div>
						<div className="gm-gas-card-num">2,600 gas</div>
						<div className="gm-gas-bar-track">
							<div className="gm-gas-bar-fill" style={{ width: '100%' }} />
						</div>
						<p className="gm-gas-card-note">
							First <code>BALANCE</code>, <code>EXTCODESIZE</code>, <code>CALL</code>, or{' '}
							<code>STATICCALL</code> to an unwarmed address.
						</p>
					</div>
					<div className="gm-gas-card">
						<div className="gm-gas-card-label">Cold Storage Read</div>
						<div className="gm-gas-card-num">2,100 gas</div>
						<div className="gm-gas-bar-track">
							<div className="gm-gas-bar-fill" style={{ width: '81%' }} />
						</div>
						<p className="gm-gas-card-note">
							First <code>SLOAD</code> (or cold surcharge on <code>SSTORE</code>) for a slot not in the EIP-2930 access list.
						</p>
					</div>
					<div className="gm-gas-card">
						<div className="gm-gas-card-label">Warm Access / TLOAD</div>
						<div className="gm-gas-card-num">100 gas</div>
						<div className="gm-gas-bar-track">
							<div className="gm-gas-bar-fill" style={{ width: '5%' }} />
						</div>
						<p className="gm-gas-card-note">
							Every subsequent read of a warm address/slot, pre-warmed precompiles, or EIP-1153 <code>TLOAD</code>/<code>TSTORE</code>.
						</p>
					</div>
				</div>
			)}

			{tab === 'memory' && (
				<div className="gm-diagram-canvas">
					<svg viewBox="0 0 760 205" role="img" aria-label="Quadratic EVM memory gas cost curve">
						<line x1="60" y1="165" x2="720" y2="165" stroke="var(--tevm-border-strong)" strokeWidth="1.2" />
						<line x1="60" y1="20" x2="60" y2="165" stroke="var(--tevm-border-strong)" strokeWidth="1.2" />

						{/* Quadratic curve: 3w + floor(w^2/512) */}
						<path
							d="M 60 165 Q 320 156, 480 120 T 710 28"
							fill="none"
							stroke="var(--tevm-accent)"
							strokeWidth="2.5"
						/>
						{/* Linear component dashed */}
						<line
							x1="60"
							y1="165"
							x2="710"
							y2="132"
							stroke="var(--tevm-text-muted)"
							strokeWidth="1.2"
							strokeDasharray="4 4"
						/>

						{/* Key sample points */}
						{[
							{ x: 110, y: 163, l: '1 word (32B)', g: '3 gas' },
							{ x: 260, y: 156, l: '32 words (1 KB)', g: '98 gas' },
							{ x: 470, y: 122, l: '512 words (16 KB)', g: '2,048 gas' },
							{ x: 670, y: 45, l: '2048 words (64 KB)', g: '14,336 gas' },
						].map((p) => (
							<g key={p.l}>
								<circle cx={p.x} cy={p.y} r="4.5" fill="var(--tevm-accent)" />
								<text x={p.x} y={p.y - 16} textAnchor="middle" fill="var(--tevm-text)" fontFamily="var(--tevm-mono)" fontSize="10.5" fontWeight="700">
									{p.g}
								</text>
								<text x={p.x} y="184" textAnchor="middle" fill="var(--tevm-text-muted)" fontFamily="var(--tevm-mono)" fontSize="10">
									{p.l}
								</text>
							</g>
						))}

						<text x="72" y="36" fill="var(--tevm-accent)" fontFamily="var(--tevm-mono)" fontSize="11.5" fontWeight="700">
							cost(w) = 3w + ⌊w² / 512⌋
						</text>
						<text x="72" y="54" fill="var(--tevm-text-muted)" fontFamily="var(--tevm-mono)" fontSize="10.5">
							dashed line = linear 3w term (dominates under ~16 KB)
						</text>
					</svg>
				</div>
			)}

			{tab === 'sstore' && (
				<div className="gm-gas-grid">
					<div className="gm-gas-card">
						<div className="gm-gas-card-label">0 → Non-Zero (Fresh Set)</div>
						<div className="gm-gas-card-num">20,000 gas</div>
						<div className="gm-gas-bar-track">
							<div className="gm-gas-bar-fill" style={{ width: '100%' }} />
						</div>
						<p className="gm-gas-card-note">
							Plus 2,100 cold surcharge if the slot has not been touched yet in this transaction.
						</p>
					</div>
					<div className="gm-gas-card">
						<div className="gm-gas-card-label">Non-Zero → Non-Zero (Reset)</div>
						<div className="gm-gas-card-num">2,900 gas</div>
						<div className="gm-gas-bar-track">
							<div className="gm-gas-bar-fill" style={{ width: '25%' }} />
						</div>
						<p className="gm-gas-card-note">
							Warm update of an existing slot (5,000 total if cold: 2,100 + 2,900). Dirty re-writes cost 100 gas.
						</p>
					</div>
					<div className="gm-gas-card">
						<div className="gm-gas-card-label">Non-Zero → 0 (Clear Refund)</div>
						<div className="gm-gas-card-num">+4,800 refund</div>
						<div className="gm-gas-bar-track">
							<div
								className="gm-gas-bar-fill"
								style={{ width: '35%', background: 'light-dark(#059669, #32d583)' }}
							/>
						</div>
						<p className="gm-gas-card-note">
							Credited to <code>refund_counter</code>. Capped at <strong>1/5</strong> of gas used since London (EIP-3529), vs 1/2 earlier.
						</p>
					</div>
				</div>
			)}

			<figcaption className="gm-diagram-caption">
				All figures match <code>GasConstants</code> in Voltaire and <code>src/instructions/handlers_storage.zig</code> / <code>src/frame.zig</code>.
			</figcaption>
		</figure>
	)
}

type ForkInfo = {
	id: string
	year: string
	short: string
	summary: string
	eips: string[]
	precompiles: string
}

const FORKS: ForkInfo[] = [
	{
		id: 'FRONTIER',
		year: '2015',
		short: 'Launch EVM',
		summary: 'Original instruction set, precompiles 0x01–0x04, no DELEGATECALL or REVERT.',
		eips: ['Base Yellow Paper'],
		precompiles: '0x01–0x04 (ECRECOVER, SHA256, RIPEMD160, IDENTITY)',
	},
	{
		id: 'HOMESTEAD',
		year: '2016',
		short: 'DELEGATECALL',
		summary: 'Added DELEGATECALL (0xF4); failed contract creation out-of-gas fails completely instead of deploying empty code.',
		eips: ['EIP-2', 'EIP-7'],
		precompiles: '0x01–0x04',
	},
	{
		id: 'TANGERINE_WHISTLE',
		year: '2016',
		short: '63/64 gas rule',
		summary: 'IO-heavy opcodes repriced (SLOAD 50→200, SELFDESTRUCT 0→5000) and EIP-150 63/64 call gas cap.',
		eips: ['EIP-150'],
		precompiles: '0x01–0x04',
	},
	{
		id: 'SPURIOUS_DRAGON',
		year: '2016',
		short: '24 KB code limit',
		summary: 'EIP-170 contract size cap (24,576 bytes), EIP-161 empty-account state clearing, EXP byte cost 10→50.',
		eips: ['EIP-155', 'EIP-160', 'EIP-161', 'EIP-170'],
		precompiles: '0x01–0x04',
	},
	{
		id: 'BYZANTIUM',
		year: '2017',
		short: 'REVERT & STATICCALL',
		summary: 'Added REVERT, STATICCALL, RETURNDATASIZE, RETURNDATACOPY, and pairing/modexp precompiles.',
		eips: ['EIP-140', 'EIP-196', 'EIP-197', 'EIP-198', 'EIP-211', 'EIP-214'],
		precompiles: '0x01–0x08 (+ MODEXP, BN254 ADD/MUL/PAIRING)',
	},
	{
		id: 'CONSTANTINOPLE',
		year: '2019',
		short: 'CREATE2 & shifts',
		summary: 'Added SHL, SHR, SAR, EXTCODEHASH, and deterministic CREATE2. Petersburg immediately removed EIP-1283.',
		eips: ['EIP-145', 'EIP-1014', 'EIP-1052'],
		precompiles: '0x01–0x08',
	},
	{
		id: 'ISTANBUL',
		year: '2019',
		short: 'CHAINID & EIP-2200',
		summary: 'Added CHAINID, SELFBALANCE, BLAKE2F precompile (0x09), EIP-2200 SSTORE net metering, and SLOAD → 800.',
		eips: ['EIP-152', 'EIP-1344', 'EIP-1884', 'EIP-2028', 'EIP-2200'],
		precompiles: '0x01–0x09 (+ BLAKE2F)',
	},
	{
		id: 'BERLIN',
		year: '2021',
		short: 'Warm/cold access',
		summary: 'EIP-2929 cold/warm gas accounting (2600/2100/100) and EIP-2930 optional access lists.',
		eips: ['EIP-2565', 'EIP-2929', 'EIP-2930'],
		precompiles: '0x01–0x09 (pre-warmed at tx start)',
	},
	{
		id: 'LONDON',
		year: '2021',
		short: 'BASEFEE & 1/5 refunds',
		summary: 'Added BASEFEE (0x48), capped refunds at 1/5 gas used, removed SELFDESTRUCT refund, banned 0xEF code prefix.',
		eips: ['EIP-1559', 'EIP-3198', 'EIP-3529', 'EIP-3541'],
		precompiles: '0x01–0x09',
	},
	{
		id: 'MERGE',
		year: '2022',
		short: 'PREVRANDAO',
		summary: 'Opcode 0x44 returns block_prevrandao instead of proof-of-work difficulty.',
		eips: ['EIP-4399'],
		precompiles: '0x01–0x09',
	},
	{
		id: 'SHANGHAI',
		year: '2023',
		short: 'PUSH0 & initcode cap',
		summary: 'Added PUSH0 (0x5F), pre-warmed coinbase, capped initcode at 48 KB with +2 gas/word.',
		eips: ['EIP-3651', 'EIP-3855', 'EIP-3860'],
		precompiles: '0x01–0x09',
	},
	{
		id: 'CANCUN',
		year: '2024',
		short: 'Blobs, TLOAD, MCOPY',
		summary: 'Added TLOAD/TSTORE, MCOPY, BLOBHASH, BLOBBASEFEE, KZG point evaluation (0x0A), and EIP-6780 SELFDESTRUCT.',
		eips: ['EIP-1153', 'EIP-4788', 'EIP-4844', 'EIP-5656', 'EIP-6780', 'EIP-7516'],
		precompiles: '0x01–0x0A (+ KZG POINT EVAL)',
	},
	{
		id: 'PRAGUE',
		year: '2025',
		short: 'DEFAULT · BLS & 7702',
		summary: 'Hardfork.DEFAULT. Added BLS12-381 precompiles (pre-warmed 0x01–0x13), EIP-7702 delegation (0xEF0100 + 20B), EIP-7623 calldata floor.',
		eips: ['EIP-2537', 'EIP-2935', 'EIP-7623', 'EIP-7702'],
		precompiles: '0x01–0x13 (+ BLS12-381 suite)',
	},
	{
		id: 'OSAKA',
		year: 'Next',
		short: 'CLZ & P256VERIFY',
		summary: 'Added CLZ opcode (0x1E), P256VERIFY precompile at 0x0100 (pre-warmed), and ModExp gas/size updates.',
		eips: ['EIP-7823', 'EIP-7883', 'EIP-7939', 'EIP-7951'],
		precompiles: '0x01–0x13 + 0x0100 (P256VERIFY)',
	},
]

export function HardforkTimeline() {
	const [selected, setSelected] = useState<string>('PRAGUE')
	const active = FORKS.find((f) => f.id === selected) ?? FORKS[FORKS.length - 2]

	return (
		<figure className="gm-diagram">
			<div className="gm-diagram-header">
				<span className="gm-diagram-title">Supported Hardfork Timeline (Click to Inspect)</span>
				<span className="gm-diagram-badge">Frontier → Osaka</span>
			</div>
			<div className="gm-fork-grid">
				{FORKS.map((f) => (
					<button
						type="button"
						key={f.id}
						className="gm-fork-node"
						data-selected={f.id === selected}
						onClick={() => setSelected(f.id)}
					>
						<div className="gm-fork-name">
							<span>.{f.id}</span>
							<span className="gm-fork-year">{f.year}</span>
						</div>
						<p className="gm-fork-summary">{f.short}</p>
					</button>
				))}
			</div>
			<div className="gm-fork-detail">
				<h4>
					Hardfork.{active.id} ({active.year})
				</h4>
				<p style={{ margin: '0 0 0.45rem', fontSize: '0.88rem', color: 'var(--tevm-text)' }}>
					{active.summary}
				</p>
				<p style={{ margin: 0, fontSize: '0.8rem', color: 'var(--tevm-text-muted)' }}>
					<strong>Precompiles:</strong> {active.precompiles}
				</p>
				<ul className="gm-fork-eips">
					{active.eips.map((e) => (
						<li key={e} className="gm-fork-eip">
							{e}
						</li>
					))}
				</ul>
			</div>
		</figure>
	)
}

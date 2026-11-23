import type { ReactNode } from 'react'

type BoxProps = {
	title?: string
	children: ReactNode
}

export function MentalModel({ title = 'Mental Model', children }: BoxProps) {
	return (
		<aside className="gm-hf gm-hf--mental">
			<div className="gm-hf-head">
				<span>◈</span>
				<span>{title}</span>
			</div>
			<div className="gm-hf-body">{children}</div>
		</aside>
	)
}

export function WatchOut({ title = 'Watch Out', children }: BoxProps) {
	return (
		<aside className="gm-hf gm-hf--watch">
			<div className="gm-hf-head">
				<span>▲</span>
				<span>{title}</span>
			</div>
			<div className="gm-hf-body">{children}</div>
		</aside>
	)
}

export function UnderTheHood({ title = 'Under the Hood', children }: BoxProps) {
	return (
		<aside className="gm-hf gm-hf--hood">
			<div className="gm-hf-head">
				<span>⚙</span>
				<span>{title}</span>
			</div>
			<div className="gm-hf-body">{children}</div>
		</aside>
	)
}

export type QaItem = {
	q: string
	a: ReactNode
}

export function DumbQuestions({
	title = 'There Are No Dumb Questions',
	items,
}: {
	title?: string
	items: QaItem[]
}) {
	return (
		<aside className="gm-hf gm-hf--qa">
			<div className="gm-hf-head">
				<span>?</span>
				<span>{title}</span>
			</div>
			<div className="gm-hf-body">
				{items.map((item, i) => (
					<div className="gm-qa-item" key={i}>
						<p className="gm-qa-q">Q: {item.q}</p>
						<div className="gm-qa-a">{item.a}</div>
					</div>
				))}
			</div>
		</aside>
	)
}

export function TraceExercise({
	title = 'Trace It Yourself',
	prompt,
	answer,
}: {
	title?: string
	prompt: ReactNode
	answer: ReactNode
}) {
	return (
		<aside className="gm-hf gm-hf--exercise">
			<div className="gm-hf-head">
				<span>✎</span>
				<span>{title}</span>
			</div>
			<div className="gm-hf-body">
				<div>{prompt}</div>
				<details className="gm-reveal">
					<summary>Check your trace</summary>
					<div className="gm-reveal-content">{answer}</div>
				</details>
			</div>
		</aside>
	)
}

export type TraceFrameStep = {
	pc: string
	op: string
	gas: string
	stack: string[]
	note: string
}

export function StackTraceStrip({ steps }: { steps: TraceFrameStep[] }) {
	return (
		<div className="gm-trace-strip">
			{steps.map((s, idx) => (
				<div className="gm-trace-step" key={idx}>
					<div className="gm-trace-step-head">
						<span className="gm-trace-step-op">
							{s.pc} {s.op}
						</span>
						<span className="gm-trace-step-gas">{s.gas}</span>
					</div>
					<div className="gm-trace-stack">
						{s.stack.length === 0 ? (
							<div className="gm-trace-word" style={{ opacity: 0.5 }}>
								(empty)
							</div>
						) : (
							s.stack.map((word, wi) => (
								<div
									key={wi}
									className={
										wi === 0
											? 'gm-trace-word gm-trace-word--top'
											: 'gm-trace-word'
									}
								>
									{word}
								</div>
							))
						)}
					</div>
					<p className="gm-trace-note">{s.note}</p>
				</div>
			))}
		</div>
	)
}

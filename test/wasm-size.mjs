import assert from 'node:assert/strict'
import { stat } from 'node:fs/promises'
import { basename } from 'node:path'

// Raw shipped bytes, before HTTP transfer compression.
const budgets = new Map([
  ['guillotine_mini_core.wasm', 230_721],
  // Includes the pinned Voltaire crypto implementation in the monolithic reactor.
  ['guillotine_mini.wasm', 595_000],
  // Per-address ceilings keep the lightweight contracts independently small.
  // Voltaire's secp256k1 recovery module ships 51,930 bytes.
  ['precompile-01.wasm', 54_000],
  ['precompile-02.wasm', 10_000],
  ['precompile-03.wasm', 5_000],
  ['precompile-04.wasm', 3_200],
  ['precompile-05.wasm', 32_000],
  ['precompile-06.wasm', 25_000],
  ['precompile-07.wasm', 33_000],
  ['precompile-08.wasm', 64_000],
  ['precompile-09.wasm', 5_000],
  ['precompile-0a.wasm', 10_000],
  ['precompile-0b.wasm', 102_000],
  ['precompile-0c.wasm', 130_000],
  ['precompile-0d.wasm', 52_000],
  ['precompile-0e.wasm', 100_000],
  ['precompile-0f.wasm', 33_000],
  ['precompile-10.wasm', 19_000],
  ['precompile-11.wasm', 23_000],
  ['precompile-100.wasm', 43_000],
])

for (const path of process.argv.slice(2)) {
  const name = basename(path)
  const budget = budgets.get(name)
  assert.ok(budget, `No WASM size budget for ${name}`)
  const { size } = await stat(path)
  assert.ok(size > 0 && size <= budget, `${name} is ${size} bytes (budget ${budget} bytes)`)
  budgets.delete(name)
  console.log(`${name}: ${size} / ${budget} bytes`)
}
assert.deepEqual([...budgets.keys()], [], 'Missing WASM artifacts in size check')

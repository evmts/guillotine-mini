#!/usr/bin/env bun
/**
 * Trust-aware Smithers CI runner for evmts/guillotine-mini.
 *
 * Classifies the execution context, strips privileged write tokens on untrusted
 * runs (read-only shared cache only), logs the trust tier and cache mode, and
 * forwards arguments to `smthrs`.
 *
 * Usage:
 *   bun .smithers/scripts/run-trusted-ci.ts ci '//...' --verbose
 *   bun .smithers/scripts/run-trusted-ci.ts --untrusted ci '//.smithers/...'
 */

import { mkdirSync, writeFileSync } from "node:fs"
import { dirname, resolve } from "node:path"
import { classifyExecution, sanitizeEnvForExecution } from "./trust-policy.ts"

const rawArgs = process.argv.slice(2)
let forceUntrusted = false
let attestationOut: string | undefined
const smthrsArgs: string[] = []

for (let i = 0; i < rawArgs.length; i++) {
  const arg = rawArgs[i]!
  if (arg === "--untrusted") {
    forceUntrusted = true
  } else if (arg === "--attestation-out" && i + 1 < rawArgs.length) {
    attestationOut = rawArgs[++i]
  } else {
    smthrsArgs.push(arg)
  }
}

if (smthrsArgs.length === 0) {
  console.error("Usage: bun .smithers/scripts/run-trusted-ci.ts [--untrusted] [--attestation-out <path>] <smthrs args...>")
  process.exit(2)
}

const attestation = classifyExecution({ forceUntrusted })
const safeEnv = sanitizeEnvForExecution(process.env, attestation)

console.error(
  `[smithers-trust] tier=${attestation.tier} trusted=${attestation.trusted} ` +
    `gateEligible=${attestation.gateEligible} cacheMode=${attestation.cacheMode} source=${attestation.source}`
)

if (attestationOut) {
  const abs = resolve(attestationOut)
  mkdirSync(dirname(abs), { recursive: true })
  writeFileSync(abs, `${JSON.stringify(attestation, null, 2)}\n`, "utf8")
}

const smthrsBin = process.env.SMTHRS_BIN?.trim()
const cmd = smthrsBin
  ? [smthrsBin, ...smthrsArgs]
  : ["npx", "--yes", "-p", "@smthrs/cli@1.0.0-rc.18", "smthrs", ...smthrsArgs]

const proc = Bun.spawn(cmd, {
  env: safeEnv as Record<string, string>,
  stdin: "inherit",
  stdout: "inherit",
  stderr: "inherit",
})

const exitCode = await proc.exited
process.exit(exitCode)

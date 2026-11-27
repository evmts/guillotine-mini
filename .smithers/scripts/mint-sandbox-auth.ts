#!/usr/bin/env bun
/**
 * One-time-use sandbox and agent authentication helper for evmts/guillotine-mini.
 *
 * Security invariants:
 * - Never prints long-lived root secrets or accepts tokens on argv.
 * - Uses RFC 7636 PKCE S256 for Smithers Cloud BYOA one-time attach handshakes
 *   (https://smithers.sh/api/attach/*).
 * - Issues single-use, short-lived, replay-protected bootstrap envelopes with
 *   trust-tier capability attenuation (untrusted sandboxes NEVER receive
 *   cache:write or person-only scopes).
 * - Writes sensitive credentials exclusively to mode-0600 files.
 *
 * Usage:
 *   bun .smithers/scripts/mint-sandbox-auth.ts prompt
 *   bun .smithers/scripts/mint-sandbox-auth.ts attach --branch main [--claim <ref>] [--out <mode-600-file>]
 *   bun .smithers/scripts/mint-sandbox-auth.ts envelope --agent <name> [--ttl 300] [--untrusted]
 *   bun .smithers/scripts/mint-sandbox-auth.ts gateway --scope read:runs --ttl 15m [--run <run-id>]
 */

import { createHash, createHmac, randomBytes, timingSafeEqual } from "node:crypto"
import { chmodSync, mkdirSync, writeFileSync } from "node:fs"
import { dirname, resolve } from "node:path"
import { canWriteSharedCache, classifyExecution, type ExecutionTrustTier } from "./trust-policy.ts"

export const REPO_SLUG = "evmts/guillotine-mini" as const
export const DEFAULT_ORIGIN = "https://smithers.sh" as const
export const REPO_MCP_URL = `${DEFAULT_ORIGIN}/${REPO_SLUG}/mcp` as const
export const MAX_SANDBOX_TTL_SECONDS = 3600

export type SandboxCapability =
  | "mcp:read"
  | "mcp:write"
  | "cache:read"
  | "cache:write"
  | "runs:read"
  | "runs:write"
  | "artifacts:write"

const UNTRUSTED_ALLOWED_CAPABILITIES: ReadonlySet<SandboxCapability> = new Set([
  "mcp:read",
  "cache:read",
  "runs:read",
])

export interface PkcePair {
  readonly verifier: string
  readonly challenge: string
  readonly method: "S256"
}

/** Generates a standards-compliant RFC 7636 PKCE S256 verifier and challenge pair. */
export function generatePkcePair(): PkcePair {
  const verifier = randomBytes(32).toString("base64url")
  const challenge = createHash("sha256").update(verifier).digest("base64url")
  return { verifier, challenge, method: "S256" }
}

export interface OneTimeEnvelopeClaims {
  readonly v: 1
  readonly jti: string
  readonly repo: typeof REPO_SLUG
  readonly mcpUrl: string
  readonly agent: string
  readonly tier: ExecutionTrustTier
  readonly capabilities: ReadonlyArray<SandboxCapability>
  readonly iat: number
  readonly exp: number
  readonly oneTime: true
}

export interface MintEnvelopeOptions {
  readonly secret: string
  readonly agent: string
  readonly requestedCapabilities?: ReadonlyArray<SandboxCapability>
  readonly ttlSeconds?: number
  readonly env?: Readonly<Record<string, string | undefined>>
  readonly forceUntrusted?: boolean
  readonly nowSeconds?: number
}

export interface MintedEnvelope {
  readonly token: string
  readonly claims: OneTimeEnvelopeClaims
}

/**
 * Attenuates requested capabilities strictly against the caller's execution trust tier.
 * Untrusted tiers can NEVER escalate to cache:write, mcp:write, runs:write, or artifacts:write.
 */
export function attenuateCapabilities(
  requested: ReadonlyArray<SandboxCapability>,
  tier: ExecutionTrustTier,
  trustedCacheWrite: boolean
): ReadonlyArray<SandboxCapability> {
  const unique = [...new Set(requested)]
  if (tier === "untrusted-contributor" || !trustedCacheWrite) {
    return unique.filter((cap) => UNTRUSTED_ALLOWED_CAPABILITIES.has(cap))
  }
  return unique
}

/** Mints an HMAC-SHA256 signed one-time-use sandbox auth token (`smo1.<payload>.<sig>`). */
export function mintOneTimeEnvelope(options: MintEnvelopeOptions): MintedEnvelope {
  const secret = options.secret.trim()
  if (secret.length < 16) {
    throw new Error("Signing secret must be at least 16 characters")
  }
  const agent = options.agent.trim()
  if (!/^[a-zA-Z0-9._-]{1,64}$/.test(agent)) {
    throw new Error("Agent name must be 1-64 safe identifier characters")
  }
  const ttl = options.ttlSeconds ?? 300
  if (!Number.isInteger(ttl) || ttl < 30 || ttl > MAX_SANDBOX_TTL_SECONDS) {
    throw new Error(`TTL must be an integer between 30 and ${MAX_SANDBOX_TTL_SECONDS} seconds`)
  }
  const attestation = classifyExecution({
    env: options.env,
    forceUntrusted: options.forceUntrusted,
  })
  const requested: ReadonlyArray<SandboxCapability> = options.requestedCapabilities ?? [
    "mcp:read",
    "cache:read",
    "runs:read",
    ...(canWriteSharedCache(attestation) ? (["mcp:write", "cache:write", "artifacts:write"] as const) : []),
  ]
  const capabilities = attenuateCapabilities(requested, attestation.tier, canWriteSharedCache(attestation))
  const now = options.nowSeconds ?? Math.floor(Date.now() / 1000)

  const claims: OneTimeEnvelopeClaims = {
    v: 1,
    jti: randomBytes(16).toString("hex"),
    repo: REPO_SLUG,
    mcpUrl: REPO_MCP_URL,
    agent,
    tier: attestation.tier,
    capabilities,
    iat: now,
    exp: now + ttl,
    oneTime: true,
  }
  const encoded = Buffer.from(JSON.stringify(claims), "utf8").toString("base64url")
  const sig = createHmac("sha256", secret).update(`smo1.${encoded}`).digest("base64url")
  return {
    token: `smo1.${encoded}.${sig}`,
    claims,
  }
}

export type RedeemResult =
  | { readonly ok: true; readonly claims: OneTimeEnvelopeClaims }
  | { readonly ok: false; readonly code: "INVALID_FORMAT" | "INVALID_SIGNATURE" | "EXPIRED" | "ALREADY_REDEEMED" }

/**
 * Verifies and atomically consumes a one-time-use sandbox auth envelope against
 * a replay-protection set of consumed JTIs.
 */
export function redeemOneTimeEnvelope(
  token: string,
  secret: string,
  consumedJtis: Set<string>,
  nowSeconds = Math.floor(Date.now() / 1000)
): RedeemResult {
  const parts = token.trim().split(".")
  if (parts.length !== 3 || parts[0] !== "smo1") {
    return { ok: false, code: "INVALID_FORMAT" }
  }
  const [, encoded, sig] = parts as [string, string, string]
  const expectedSig = createHmac("sha256", secret.trim()).update(`smo1.${encoded}`).digest("base64url")
  const a = Buffer.from(sig)
  const b = Buffer.from(expectedSig)
  if (a.length !== b.length || !timingSafeEqual(a, b)) {
    return { ok: false, code: "INVALID_SIGNATURE" }
  }
  let claims: OneTimeEnvelopeClaims
  try {
    claims = JSON.parse(Buffer.from(encoded, "base64url").toString("utf8")) as OneTimeEnvelopeClaims
  } catch {
    return { ok: false, code: "INVALID_FORMAT" }
  }
  if (claims.v !== 1 || claims.oneTime !== true || typeof claims.jti !== "string" || claims.repo !== REPO_SLUG) {
    return { ok: false, code: "INVALID_FORMAT" }
  }
  if (nowSeconds >= claims.exp) {
    return { ok: false, code: "EXPIRED" }
  }
  if (consumedJtis.has(claims.jti)) {
    return { ok: false, code: "ALREADY_REDEEMED" }
  }
  consumedJtis.add(claims.jti)
  return { ok: true, claims }
}

/** Writes a credential to a strictly mode-0600 file. */
export function writeSecretFile(filePath: string, content: string): string {
  const abs = resolve(filePath)
  mkdirSync(dirname(abs), { recursive: true, mode: 0o700 })
  writeFileSync(abs, content, { encoding: "utf8", mode: 0o600 })
  chmodSync(abs, 0o600)
  return abs
}

export function renderAgentBootstrapPrompt(origin = DEFAULT_ORIGIN): string {
  const cleanOrigin = origin.replace(/\/+$/, "")
  const mcpUrl = `${cleanOrigin}/${REPO_SLUG}/mcp`
  return [
    `# Smithers Cloud Agent Bootstrap (${REPO_SLUG})`,
    "",
    "Connect your agent to the authenticated Smithers Cloud MCP server for evmts/guillotine-mini:",
    "",
    "```sh",
    `claude mcp add guillotine-mini --transport http ${mcpUrl}`,
    `codex mcp add guillotine-mini --url ${mcpUrl}`,
    `agy mcp add guillotine-mini --transport http ${mcpUrl}`,
    "```",
    "",
    "OAuth 2.1 + PKCE S256 Discovery:",
    `  ${cleanOrigin}/.well-known/oauth-protected-resource/${REPO_SLUG}/mcp`,
    "",
    "Standing rules for every agent session:",
    "1. Read repo state, docs (`docs_list` / `docs_read`), flows (`flows_list` / `flow_get`), issues, PRs, and TODOs via Smithers Cloud MCP.",
    "2. Use `jj --no-pager` for stacked changesets (never raw git CLI).",
    "3. Run local checks untrusted via `bun .smithers/scripts/run-trusted-ci.ts --untrusted ci '//...'` and `uphill --compact`.",
    "4. Never attempt person-only acts (merging, final triage, committing TODOs, writing secrets). Only a human maintainer merges.",
    "5. Refresh the Lighthouse Backpressure Audit (`bun .smithers/scripts/generate-audit-report.ts`) before handing work off.",
  ].join("\n")
}

if (import.meta.main) {
  const [subcommand = "prompt", ...rest] = process.argv.slice(2)
  const flag = (name: string): string | undefined => {
    const idx = rest.indexOf(name)
    return idx !== -1 && idx + 1 < rest.length ? rest[idx + 1] : undefined
  }
  const hasFlag = (name: string): boolean => rest.includes(name)

  if (subcommand === "prompt") {
    console.log(renderAgentBootstrapPrompt(flag("--origin") ?? DEFAULT_ORIGIN))
    process.exit(0)
  }

  if (subcommand === "attach") {
    const origin = (flag("--origin") ?? DEFAULT_ORIGIN).replace(/\/+$/, "")
    const branch = flag("--branch") ?? "main"
    const pkce = generatePkcePair()
    const claimRef = flag("--claim")
    const outFile = flag("--out")

    if (outFile) {
      writeSecretFile(
        outFile,
        `${JSON.stringify({ verifier: pkce.verifier, method: pkce.method, branch, origin }, null, 2)}\n`
      )
    }

    const summary = {
      mode: "smithers-cloud-one-time-attach",
      repository: REPO_SLUG,
      branch,
      mcpAttachEndpoint: `${origin}/api/attach/mcp/${REPO_SLUG}/${branch}`,
      pkceChallenge: pkce.challenge,
      pkceMethod: pkce.method,
      verifierSavedTo: outFile ? resolve(outFile) : "in-memory (pass --out <mode-600-path> to persist securely)",
      nextSteps: claimRef
        ? [
            `POST ${origin}/api/attach/claims with { reference: "<intent>", codeChallenge: "${pkce.challenge}", codeChallengeMethod: "S256" }`,
            "Human maintainer approves the displayed one-time pairing code in Smithers Cloud UI",
            `POST ${origin}/api/attach/tokens with the single-use approval code + PKCE verifier to receive an 8h scoped bearer token`,
          ]
        : [
            `1. Maintainer opens ${origin}/${REPO_SLUG} and clicks Connect Agent / Attach to mint a 10-minute single-use intent reference.`,
            `2. Sandbox runs this command with --claim <intent> --out ~/.config/smithers/attach-pkce.json to claim with PKCE S256.`,
            `3. Maintainer approves the one-time pairing code; sandbox redeems once for an 8h scoped bearer token.`,
          ],
    }
    console.log(JSON.stringify(summary, null, 2))
    process.exit(0)
  }

  if (subcommand === "envelope") {
    const agent = flag("--agent") ?? "sandbox-worker"
    const ttl = Number(flag("--ttl") ?? "300")
    const forceUntrusted = hasFlag("--untrusted")
    const signingSecret =
      process.env.SMITHERS_SANDBOX_SIGNING_KEY?.trim() || randomBytes(32).toString("hex")
    const ephemeralKey = !process.env.SMITHERS_SANDBOX_SIGNING_KEY?.trim()
    const minted = mintOneTimeEnvelope({
      secret: signingSecret,
      agent,
      ttlSeconds: ttl,
      forceUntrusted,
    })
    const outFile = flag("--out")
    if (outFile) {
      writeSecretFile(outFile, `${minted.token}\n`)
    }
    console.log(
      JSON.stringify(
        {
          mode: "one-time-sandbox-envelope",
          oneTime: true,
          ephemeralLocalKey: ephemeralKey,
          claims: minted.claims,
          tokenWrittenTo: outFile ? resolve(outFile) : null,
          // Print one-time token ONLY when --out is not used, so interactive sandboxes can copy once.
          oneTimeToken: outFile ? "<written to mode-0600 file>" : minted.token,
        },
        null,
        2
      )
    )
    process.exit(0)
  }

  if (subcommand === "gateway") {
    const scope = flag("--scope") ?? "read:runs"
    const ttl = flag("--ttl") ?? "15m"
    const runId = flag("--run")
    if (scope === "approve:runs") {
      console.error("Refusing to mint approve:runs for a sandbox agent: approvals are person-only.")
      process.exit(2)
    }
    if (!process.env.SMITHERS_TOKEN?.trim()) {
      console.error("Set SMITHERS_TOKEN in the environment (never on argv) to mint a scoped gateway token.")
      process.exit(2)
    }
    const smthrsBin = process.env.SMTHRS_BIN?.trim()
    const cmd = smthrsBin
      ? [smthrsBin, "token", "mint", "--scope", scope, "--ttl", ttl, ...(runId ? ["--run", runId] : []), "--json"]
      : [
          "npx",
          "--yes",
          "-p",
          "@smthrs/cli@1.0.0-rc.18",
          "smthrs",
          "token",
          "mint",
          "--scope",
          scope,
          "--ttl",
          ttl,
          ...(runId ? ["--run", runId] : []),
          "--json",
        ]
    const proc = Bun.spawnSync(cmd, { stdout: "inherit", stderr: "inherit" })
    process.exit(proc.exitCode)
  }

  console.error("Unknown subcommand. Expected: prompt | attach | envelope | gateway")
  process.exit(2)
}

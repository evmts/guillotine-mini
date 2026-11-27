/**
 * Execution trust policy and cache-isolation guard for evmts/guillotine-mini.
 *
 * Security invariant:
 * - Trusted execution happens ONLY in Smithers-controlled sandboxes, trusted
 *   pushes to evmts/guillotine-mini main, or verified maintainer runs.
 * - Untrusted execution (fork PRs, external contributors, public visitors,
 *   unverified local runs) is actively encouraged so anyone can reproduce bugs,
 *   run tests, and inspect Lighthouse audit reports, but untrusted runs NEVER
 *   receive write credentials for the shared Smithers Cloud object store and
 *   NEVER satisfy or bypass trusted merge gates.
 */

export const CANONICAL_REPOSITORY = "evmts/guillotine-mini" as const
export const MAINTAINER_LOGINS: ReadonlySet<string> = new Set(["roninjin10", "fucory"])

export type ExecutionTrustTier =
  | "trusted-sandbox"
  | "trusted-maintainer"
  | "untrusted-contributor"

export type SharedCacheMode = "read-write" | "read-only" | "local-only"

export interface ExecutionAttestation {
  readonly schemaVersion: 1
  readonly repository: string
  readonly tier: ExecutionTrustTier
  readonly trusted: boolean
  readonly gateEligible: boolean
  readonly cacheMode: SharedCacheMode
  readonly cacheWriteAllowed: boolean
  readonly actor: string
  readonly source: string
  readonly ref: string
  readonly sha: string
  readonly timestamp: string
  readonly reasons: ReadonlyArray<string>
}

export const PRIVILEGED_ENV_KEYS: ReadonlyArray<string> = [
  "SMITHERS_CACHE_WRITE_TOKEN",
  "SMITHERS_CACHE_TOKEN",
  "SMITHERS_TOKEN",
  "SMITHERS_FEED_KEY",
  "SMITHERS_MACHINE_TOKEN",
  "GITHUB_TOKEN",
  "GH_TOKEN",
  "VERCEL_TOKEN",
  "NPM_TOKEN",
  "NODE_AUTH_TOKEN",
  "ANTHROPIC_API_KEY",
  "OPENAI_API_KEY",
]

export interface ClassifyOptions {
  readonly env?: Readonly<Record<string, string | undefined>>
  readonly forceUntrusted?: boolean
  readonly sha?: string
  readonly ref?: string
  readonly now?: () => string
}

const normalizeRepo = (value: string | undefined): string =>
  (value ?? "").trim().toLowerCase()

const isMaintainerLogin = (login: string | undefined): boolean =>
  login !== undefined && MAINTAINER_LOGINS.has(login.trim().toLowerCase())

/**
 * Classifies an execution environment using fail-closed rules.
 * Any ambiguity or fork/PR context settles to `untrusted-contributor`.
 */
export function classifyExecution(options: ClassifyOptions = {}): ExecutionAttestation {
  const env = options.env ?? process.env
  const timestamp = (options.now ?? (() => new Date().toISOString()))()
  const sha = (options.sha ?? env.GITHUB_SHA ?? env.SMITHERS_SHA ?? "unknown").trim() || "unknown"
  const ref = (options.ref ?? env.GITHUB_REF ?? env.SMITHERS_REF ?? "local").trim() || "local"
  const repo = (env.GITHUB_REPOSITORY ?? env.SMITHERS_REPOSITORY ?? CANONICAL_REPOSITORY).trim()
  const actor = (env.GITHUB_ACTOR ?? env.SMITHERS_ACTOR ?? env.USER ?? "anonymous").trim() || "anonymous"
  const hasReadToken = Boolean(env.SMITHERS_CACHE_READ_TOKEN?.trim())
  const hasWriteToken = Boolean(env.SMITHERS_CACHE_WRITE_TOKEN?.trim())

  const reasons: string[] = []

  if (options.forceUntrusted) {
    reasons.push("Explicit --untrusted mode requested; write credentials stripped and gate eligibility disabled.")
    return {
      schemaVersion: 1,
      repository: repo,
      tier: "untrusted-contributor",
      trusted: false,
      gateEligible: false,
      cacheMode: hasReadToken ? "read-only" : "local-only",
      cacheWriteAllowed: false,
      actor,
      source: "explicit-untrusted",
      ref,
      sha,
      timestamp,
      reasons,
    }
  }

  // 1. Smithers Cloud controlled job machine / sandbox
  const sandboxControlled = env.SMITHERS_SANDBOX_CONTROLLED === "1" || env.SMITHERS_JOB_MACHINE === "1"
  const sandboxRepoMatches = normalizeRepo(env.SMITHERS_REPOSITORY ?? repo) === CANONICAL_REPOSITORY
  const isUntrustedSandbox = env.SMITHERS_SANDBOX_TRUST === "untrusted" || env.SMITHERS_PR_FORK === "1"
  if (sandboxControlled && sandboxRepoMatches && !isUntrustedSandbox) {
    reasons.push("Executed inside a Smithers Cloud controlled sandbox for evmts/guillotine-mini.")
    return {
      schemaVersion: 1,
      repository: CANONICAL_REPOSITORY,
      tier: "trusted-sandbox",
      trusted: true,
      gateEligible: true,
      cacheMode: hasWriteToken ? "read-write" : hasReadToken ? "read-only" : "local-only",
      cacheWriteAllowed: true,
      actor,
      source: "smithers-cloud-sandbox",
      ref,
      sha,
      timestamp,
      reasons,
    }
  }

  // 2. GitHub Actions runner: ONLY pushes to canonical main (never PRs, never forks) are trusted.
  if (env.GITHUB_ACTIONS === "true") {
    const eventName = (env.GITHUB_EVENT_NAME ?? "").trim()
    const canonicalMatch = normalizeRepo(env.GITHUB_REPOSITORY) === CANONICAL_REPOSITORY
    const headRepo = env.GITHUB_HEAD_REPOSITORY ? normalizeRepo(env.GITHUB_HEAD_REPOSITORY) : CANONICAL_REPOSITORY
    const isMainPush = eventName === "push" && ref === "refs/heads/main" && canonicalMatch
    const isMaintainerDispatch =
      eventName === "workflow_dispatch" &&
      ref === "refs/heads/main" &&
      canonicalMatch &&
      isMaintainerLogin(env.GITHUB_ACTOR)

    if (isMainPush || isMaintainerDispatch) {
      reasons.push(`Trusted GitHub Actions ${eventName} on canonical ${CANONICAL_REPOSITORY} main.`)
      return {
        schemaVersion: 1,
        repository: CANONICAL_REPOSITORY,
        tier: "trusted-sandbox",
        trusted: true,
        gateEligible: true,
        cacheMode: hasWriteToken ? "read-write" : hasReadToken ? "read-only" : "local-only",
        cacheWriteAllowed: true,
        actor,
        source: `github-actions:${eventName}`,
        ref,
        sha,
        timestamp,
        reasons,
      }
    }

    if (!canonicalMatch) {
      reasons.push(`Repository ${repo} is a fork or external clone; shared cache write is denied.`)
    } else if (headRepo !== CANONICAL_REPOSITORY) {
      reasons.push(`Pull request originates from external repository ${headRepo}; running untrusted.`)
    } else {
      reasons.push(`GitHub Actions event "${eventName}" on "${ref}" is not a canonical main push; running untrusted.`)
    }
    return {
      schemaVersion: 1,
      repository: repo,
      tier: "untrusted-contributor",
      trusted: false,
      gateEligible: false,
      cacheMode: hasReadToken ? "read-only" : "local-only",
      cacheWriteAllowed: false,
      actor,
      source: `github-actions:${eventName || "unknown"}`,
      ref,
      sha,
      timestamp,
      reasons,
    }
  }

  // 3. Verified local maintainer execution (requires explicit maintainer verification + login match)
  const verifiedMaintainer = env.SMITHERS_MAINTAINER_VERIFIED === "1" && isMaintainerLogin(env.SMITHERS_ACTOR)
  if (verifiedMaintainer) {
    reasons.push(`Verified maintainer (${env.SMITHERS_ACTOR}) local execution.`)
    return {
      schemaVersion: 1,
      repository: CANONICAL_REPOSITORY,
      tier: "trusted-maintainer",
      trusted: true,
      gateEligible: true,
      cacheMode: hasWriteToken ? "read-write" : hasReadToken ? "read-only" : "local-only",
      cacheWriteAllowed: true,
      actor: env.SMITHERS_ACTOR!.trim(),
      source: "maintainer-local",
      ref,
      sha,
      timestamp,
      reasons,
    }
  }

  // 4. Default: Fail-closed to untrusted-contributor (encouraged, read-only cache, informational gates)
  reasons.push(
    "Local or external contributor run: encouraged for fast feedback, restricted to read-only cache and non-authoritative gates."
  )
  return {
    schemaVersion: 1,
    repository: repo,
    tier: "untrusted-contributor",
    trusted: false,
    gateEligible: false,
    cacheMode: hasReadToken ? "read-only" : "local-only",
    cacheWriteAllowed: false,
    actor,
    source: "local-untrusted",
    ref,
    sha,
    timestamp,
    reasons,
  }
}

export const canWriteSharedCache = (attestation: ExecutionAttestation): boolean =>
  attestation.trusted && attestation.cacheWriteAllowed

export const canSatisfyMergeGate = (attestation: ExecutionAttestation): boolean =>
  attestation.trusted && attestation.gateEligible

/**
 * Returns a sanitized environment for child processes.
 * Untrusted executions ALWAYS strip privileged write tokens and deploy secrets
 * while preserving optional read-only cache tokens.
 */
export function sanitizeEnvForExecution(
  env: Readonly<Record<string, string | undefined>>,
  attestation: ExecutionAttestation
): Record<string, string | undefined> {
  const next: Record<string, string | undefined> = { ...env }
  next.SMITHERS_TRUST_TIER = attestation.tier
  next.SMITHERS_GATE_ELIGIBLE = attestation.gateEligible ? "1" : "0"
  next.SMITHERS_CACHE_MODE = attestation.cacheMode

  if (!canWriteSharedCache(attestation)) {
    for (const key of PRIVILEGED_ENV_KEYS) {
      delete next[key]
    }
  }
  return next
}

/**
 * Checks whether a repository-relative path touches a protected trust root.
 */
export const PROTECTED_TRUST_ROOTS: ReadonlyArray<string> = [
  "src/evm.zig",
  "src/frame.zig",
  "src/instructions",
  "src/precompiles",
  "src/root_c.zig",
  "build.zig",
  "build.zig.zon",
  "native-dependencies.json",
  ".smithers",
  ".github",
  ".agents/uphill",
  "PACKAGE.ts",
  "AGENTS.md",
  "CLAUDE.md",
]

export function isProtectedPath(repoPath: string): boolean {
  const normalized = repoPath.replace(/\\/g, "/").replace(/^\.\/+/, "").replace(/^\/+/, "")
  return PROTECTED_TRUST_ROOTS.some(
    (root) => normalized === root || normalized.startsWith(`${root}/`)
  )
}

if (import.meta.main) {
  const forceUntrusted = process.argv.includes("--untrusted")
  const attestation = classifyExecution({ forceUntrusted })
  console.log(JSON.stringify(attestation, null, 2))
}

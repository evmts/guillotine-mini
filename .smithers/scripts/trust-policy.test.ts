import { describe, expect, test } from "bun:test"
import {
  canSatisfyMergeGate,
  canWriteSharedCache,
  classifyExecution,
  isProtectedPath,
  sanitizeEnvForExecution,
} from "./trust-policy.ts"

const fixedNow = () => "2026-11-27T00:00:00.000Z"

describe("guillotine-mini execution trust policy", () => {
  test("classifies canonical GitHub main push as trusted-sandbox", () => {
    const att = classifyExecution({
      env: {
        GITHUB_ACTIONS: "true",
        GITHUB_REPOSITORY: "evmts/guillotine-mini",
        GITHUB_EVENT_NAME: "push",
        GITHUB_REF: "refs/heads/main",
        GITHUB_SHA: "abc1234",
        GITHUB_ACTOR: "roninjin10",
        SMITHERS_CACHE_READ_TOKEN: "read-tok",
        SMITHERS_CACHE_WRITE_TOKEN: "write-tok",
      },
      now: fixedNow,
    })

    expect(att.tier).toBe("trusted-sandbox")
    expect(att.trusted).toBe(true)
    expect(att.gateEligible).toBe(true)
    expect(att.cacheMode).toBe("read-write")
    expect(canWriteSharedCache(att)).toBe(true)
    expect(canSatisfyMergeGate(att)).toBe(true)
  })

  test("refuses cache write and merge gate for pull_request even on canonical repo", () => {
    const env = {
      GITHUB_ACTIONS: "true",
      GITHUB_REPOSITORY: "evmts/guillotine-mini",
      GITHUB_EVENT_NAME: "pull_request",
      GITHUB_REF: "refs/pull/42/merge",
      GITHUB_SHA: "def5678",
      GITHUB_ACTOR: "contributor1",
      SMITHERS_CACHE_READ_TOKEN: "read-tok",
      SMITHERS_CACHE_WRITE_TOKEN: "leaked-write-tok",
      VERCEL_TOKEN: "leaked-vercel-tok",
    }
    const att = classifyExecution({ env, now: fixedNow })

    expect(att.tier).toBe("untrusted-contributor")
    expect(att.trusted).toBe(false)
    expect(att.gateEligible).toBe(false)
    expect(att.cacheMode).toBe("read-only")
    expect(canWriteSharedCache(att)).toBe(false)
    expect(canSatisfyMergeGate(att)).toBe(false)

    const sanitized = sanitizeEnvForExecution(env, att)
    expect(sanitized.SMITHERS_CACHE_READ_TOKEN).toBe("read-tok")
    expect(sanitized.SMITHERS_CACHE_WRITE_TOKEN).toBeUndefined()
    expect(sanitized.VERCEL_TOKEN).toBeUndefined()
    expect(sanitized.SMITHERS_TRUST_TIER).toBe("untrusted-contributor")
    expect(sanitized.SMITHERS_GATE_ELIGIBLE).toBe("0")
  })

  test("refuses trust for spoofed fork main push", () => {
    const att = classifyExecution({
      env: {
        GITHUB_ACTIONS: "true",
        GITHUB_REPOSITORY: "attacker/guillotine-mini",
        GITHUB_EVENT_NAME: "push",
        GITHUB_REF: "refs/heads/main",
        GITHUB_ACTOR: "roninjin10",
      },
      now: fixedNow,
    })

    expect(att.tier).toBe("untrusted-contributor")
    expect(att.trusted).toBe(false)
    expect(canWriteSharedCache(att)).toBe(false)
    expect(canSatisfyMergeGate(att)).toBe(false)
  })

  test("classifies Smithers Cloud controlled sandbox as trusted unless marked untrusted", () => {
    const trusted = classifyExecution({
      env: {
        SMITHERS_SANDBOX_CONTROLLED: "1",
        SMITHERS_REPOSITORY: "evmts/guillotine-mini",
        SMITHERS_CACHE_WRITE_TOKEN: "write-tok",
      },
      now: fixedNow,
    })
    expect(trusted.tier).toBe("trusted-sandbox")
    expect(canWriteSharedCache(trusted)).toBe(true)

    const untrustedForkSandbox = classifyExecution({
      env: {
        SMITHERS_SANDBOX_CONTROLLED: "1",
        SMITHERS_REPOSITORY: "evmts/guillotine-mini",
        SMITHERS_PR_FORK: "1",
        SMITHERS_CACHE_READ_TOKEN: "read-tok",
        SMITHERS_CACHE_WRITE_TOKEN: "write-tok",
      },
      now: fixedNow,
    })
    expect(untrustedForkSandbox.tier).toBe("untrusted-contributor")
    expect(canWriteSharedCache(untrustedForkSandbox)).toBe(false)
  })

  test("requires verified maintainer flag and maintainer login for local trust", () => {
    const maintainer = classifyExecution({
      env: {
        SMITHERS_MAINTAINER_VERIFIED: "1",
        SMITHERS_ACTOR: "roninjin10",
        SMITHERS_CACHE_WRITE_TOKEN: "write-tok",
      },
      now: fixedNow,
    })
    expect(maintainer.tier).toBe("trusted-maintainer")
    expect(canSatisfyMergeGate(maintainer)).toBe(true)

    const nonMaintainer = classifyExecution({
      env: {
        SMITHERS_MAINTAINER_VERIFIED: "1",
        SMITHERS_ACTOR: "random-user",
      },
      now: fixedNow,
    })
    expect(nonMaintainer.tier).toBe("untrusted-contributor")
    expect(canSatisfyMergeGate(nonMaintainer)).toBe(false)

    const forced = classifyExecution({
      env: {
        SMITHERS_MAINTAINER_VERIFIED: "1",
        SMITHERS_ACTOR: "roninjin10",
      },
      forceUntrusted: true,
      now: fixedNow,
    })
    expect(forced.tier).toBe("untrusted-contributor")
    expect(canWriteSharedCache(forced)).toBe(false)
  })

  test("identifies protected trust roots accurately", () => {
    expect(isProtectedPath("src/evm.zig")).toBe(true)
    expect(isProtectedPath("src/instructions/handlers_arithmetic.zig")).toBe(true)
    expect(isProtectedPath(".smithers/FACTORY.ts")).toBe(true)
    expect(isProtectedPath(".github/workflows/ci.yml")).toBe(true)
    expect(isProtectedPath(".agents/uphill/uphill.yaml")).toBe(true)
    expect(isProtectedPath("examples/erc20.zig")).toBe(false)
    expect(isProtectedPath("docs/src/pages/index.mdx")).toBe(false)
  })
})

import { describe, expect, test } from "bun:test"
import {
  attenuateCapabilities,
  generatePkcePair,
  mintOneTimeEnvelope,
  redeemOneTimeEnvelope,
  renderAgentBootstrapPrompt,
} from "./mint-sandbox-auth.ts"

const TEST_SECRET = "0123456789abcdef0123456789abcdef"

describe("one-time-use sandbox and agent authentication", () => {
  test("generates distinct RFC 7636 PKCE S256 verifier/challenge pairs", () => {
    const a = generatePkcePair()
    const b = generatePkcePair()
    expect(a.method).toBe("S256")
    expect(a.verifier.length).toBeGreaterThanOrEqual(40)
    expect(a.challenge.length).toBeGreaterThanOrEqual(40)
    expect(a.verifier).not.toBe(a.challenge)
    expect(a.verifier).not.toBe(b.verifier)
  })

  test("attenuates untrusted sandbox capabilities to read-only only", () => {
    const caps = attenuateCapabilities(
      ["mcp:read", "mcp:write", "cache:read", "cache:write", "runs:read", "artifacts:write"],
      "untrusted-contributor",
      false
    )
    expect(caps).toEqual(["mcp:read", "cache:read", "runs:read"])
  })

  test("mints and redeems a one-time envelope exactly once, blocking replay and expiry", () => {
    const consumed = new Set<string>()
    const minted = mintOneTimeEnvelope({
      secret: TEST_SECRET,
      agent: "ci-sandbox-1",
      ttlSeconds: 120,
      nowSeconds: 1_700_000_000,
      env: {
        SMITHERS_SANDBOX_CONTROLLED: "1",
        SMITHERS_REPOSITORY: "evmts/guillotine-mini",
      },
    })

    expect(minted.token.startsWith("smo1.")).toBe(true)
    expect(minted.claims.oneTime).toBe(true)
    expect(minted.claims.tier).toBe("trusted-sandbox")
    expect(minted.claims.capabilities).toContain("cache:write")

    // First redemption succeeds
    const first = redeemOneTimeEnvelope(minted.token, TEST_SECRET, consumed, 1_700_000_010)
    expect(first.ok).toBe(true)
    if (first.ok) {
      expect(first.claims.jti).toBe(minted.claims.jti)
    }

    // Second redemption (replay) is strictly refused
    const replay = redeemOneTimeEnvelope(minted.token, TEST_SECRET, consumed, 1_700_000_011)
    expect(replay).toEqual({ ok: false, code: "ALREADY_REDEEMED" })

    // Wrong signing key is refused
    const forged = redeemOneTimeEnvelope(minted.token, "wrong-secret-key-0000", new Set(), 1_700_000_010)
    expect(forged).toEqual({ ok: false, code: "INVALID_SIGNATURE" })

    // Expired token is refused
    const expired = redeemOneTimeEnvelope(minted.token, TEST_SECRET, new Set(), 1_700_000_200)
    expect(expired).toEqual({ ok: false, code: "EXPIRED" })
  })

  test("never grants cache:write to untrusted envelope even if explicitly requested", () => {
    const minted = mintOneTimeEnvelope({
      secret: TEST_SECRET,
      agent: "fork-pr-agent",
      requestedCapabilities: ["mcp:read", "mcp:write", "cache:read", "cache:write"],
      forceUntrusted: true,
      nowSeconds: 1_700_000_000,
    })
    expect(minted.claims.tier).toBe("untrusted-contributor")
    expect(minted.claims.capabilities).toEqual(["mcp:read", "cache:read"])
  })

  test("renders MCP bootstrap prompt pointing to live Smithers Cloud endpoint", () => {
    const prompt = renderAgentBootstrapPrompt()
    expect(prompt).toContain("https://smithers.sh/evmts/guillotine-mini/mcp")
    expect(prompt).toContain("OAuth 2.1 + PKCE S256")
    expect(prompt).toContain("jj --no-pager")
  })
})

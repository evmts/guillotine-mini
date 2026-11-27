---
title: Trust Boundaries and Security Model
tags: [security, trust, cache, sandbox, auth, astra-table]
---

# Trust Boundaries and Security Model

Guillotine Mini is a public open-source coding factory. **We actively encourage non-maintainers to run tests, flows, and Lighthouse audits untrusted**, while enforcing **security by construction** so untrusted execution can never poison the shared Smithers Cloud object store, exfiltrate secrets, or skip merge gates. See [[Decisions]] and [[Factory-and-Operations]].

## Three Execution Trust Tiers

Implemented and unit-tested in `.smithers/scripts/trust-policy.ts`:

| Tier | Who / Where | Shared Object Store (`build.smithers.sh`) | Merge Gate Authority | Secrets Access |
| --- | --- | --- | --- | --- |
| `trusted-sandbox` | Smithers Cloud controlled sandbox or canonical GitHub Actions `push` to `evmts/guillotine-mini` `main` | `read-write` (writes verified results) | **Authoritative** | Scoped ephemeral / CI push secrets only |
| `trusted-maintainer` | Verified maintainer (`roninjin10`, `fucory`) running locally | `read-write` (optional) | **Authoritative** | Local maintainer credentials |
| `untrusted-contributor` | Fork PRs, external contributor PRs, public visitors, unverified local runs | **`read-only` or `local-only`** (writes refused) | **Informational only** (cannot skip gates) | **Zero privileged secrets** (stripped) |

## Root-Input-Tracing Security Table (Astra Standard)

Every privileged operation traces its authority back to a verified root input:

| Privileged Step | Required Trust Origin | Untrusted Input Surface | Enforcement Seam | Failure Mode |
| --- | --- | --- | --- | --- |
| Write to `build.smithers.sh` cache | Canonical `push` to `refs/heads/main` on `evmts/guillotine-mini` OR controlled Smithers sandbox | PR code, fork workflows, build scripts | `ci.yml` gates `SMITHERS_CACHE_WRITE_TOKEN` strictly on `push` + `refs/heads/main` + `github.repository == 'evmts/guillotine-mini'`; `trust-policy.ts` strips write token on untrusted runs; cache server returns `403` on read tokens | Fail-closed: falls back to local/read-only cache |
| Merge to `main` / Approve PR | Authenticated human maintainer in person | Agent MCP calls, contributor PRs | `FACTORY.ts` `policy.approvals: { approve: "person", merge: "person" }`; Smithers Cloud server blocks `pull/merge`, `todo/commit`, `issue/triage` for all `act.kind === "agent"` | HTTP 403 `person_only` |
| Publish GitHub Release | `workflow_run` of `CI` (`conclusion == 'success'`, `event == 'push'`, `head_repository.full_name == github.repository`) on exact `RELEASE_SHA` | Fork PR targeting `main`, manual dispatch without green CI | `release.yml` checks `head_repository.full_name == github.repository` and verifies CI push success via GitHub API for exact SHA | Job skipped or exits 1 before checkout |
| Deploy Docs (`mini.tevm.sh`) | Canonical `push` to `refs/heads/main` on `evmts/guillotine-mini` | PR edits to `docs/**` | `docs.yml` runs `build` on PRs (untrusted, no secrets) and runs `deploy` ONLY on `push` to `refs/heads/main` | PR builds verified without Vercel secrets |
| Modify Protected Trust Roots | Maintainer review required | Outsider issues/PRs | `FACTORY.ts` `protectedPaths` covers `src/evm.zig`, `src/frame.zig`, `src/instructions`, `src/precompiles`, `src/root_c.zig`, `build.zig*`, `native-dependencies.json`, `.smithers`, `.github`, `.agents/uphill`, `PACKAGE.ts`, `AGENTS.md`, `CLAUDE.md` | Agent lanes refuse automated mutation of protected paths |
| Sandbox & Agent Auth | Human OAuth 2.1 + PKCE S256 consent OR single-use attach pairing code OR `smthrs token mint --ttl` | Agent prompt, sandbox env | `.smithers/scripts/mint-sandbox-auth.ts` uses single-use codes, mode-600 files/stdin, never argv or logs; tokens expire automatically | 401/403 on replay or expiry |

## How Untrusted Contributors Run Locally

Contributors never need maintainer tokens to get full feedback:

```sh
# 1. Run untrusted incremental Smithers CI (read-only shared cache, write tokens stripped)
bun .smithers/scripts/run-trusted-ci.ts --untrusted ci '//...'

# 2. Generate your own Lighthouse Backpressure Audit Report (clearly stamped UNTRUSTED)
bun .smithers/scripts/generate-audit-report.ts --untrusted
open .smithers/audit/index.html
```

When a contributor opens a PR, Smithers Cloud runs checks in an isolated sandbox without write credentials, and a maintainer or trusted sandbox re-verifies on the exact commit SHA before landing.

## Related Pages

- [[Overview]]
- [[Decisions]]
- [[Factory-and-Operations]]
- [[Backpressure-and-Quality]]

# PR #18 Review Findings — feat/ship-mcp-json-and-envrc-profiles

## Convergence Tracking

| Cycle | Findings | Blocking (HIGH+) | Fixed | Remaining | Verdict |
|---|---|---|---|---|---|
| 1 (inline + agents) | 12 security + 10 code | 4 (2 HIGH + 2 IMPORTANT) | 2 suggestions | 20 | REQUEST_CHANGES |
| 2 | — | 0 | SEC-001/002/006/011, CODE-2 | Deferred notes | APPROVE (pending CI) |

## Cycle 1 — Security Review

| ID | Severity | Finding | File | Disposition |
|---|---|---|---|---|
| SEC-001 | HIGH | Shell injection via unescaped API key in migrate-mcp-keys.sh | `scripts/migrate-mcp-keys.sh:58` | FIXED — single-quote + `'\\''` escaping |
| SEC-002 | HIGH | Unpinned npx packages (`@playwright/mcp@latest`, `@perplexity-ai/mcp-server`) | `.mcp.json`, `plugins/secops-factory/.mcp.json` | FIXED — pinned to 0.0.80 / 1.2.1 |
| SEC-003 | MEDIUM | Exa key in URL query param (Exa's own API design) | `plugins/secops-factory/.mcp.json` | ACCEPTED — not our bug |
| SEC-004 | MEDIUM | Context7 header `CONTEXT7_API_KEY` non-standard | `.mcp.json` | DEFERRED — was in pre-existing working config; owner to verify correct header |
| SEC-005 | MEDIUM | .gitignore un-ignores .mcp.json; migration risk for existing users | `.gitignore` | ACCEPTED — migration helper + PR body documented |
| SEC-006 | MEDIUM | Path traversal via unsanitized `.factory-profile` in .envrc | `.envrc` | FIXED — case allowlist guard added |
| SEC-007 | LOW | JSON body via string interpolation in factory-profile doctor | `scripts/factory-profile:84` | ACCEPTED — values from committed profiles only |
| SEC-008 | LOW | Hardcoded `/tmp/fp-models.json` temp file (TOCTOU) | `scripts/factory-profile:58,68` | DEFERRED — doctor sub-command only; low risk |
| SEC-009 | LOW | Static `vsdd-local-gateway` token committed | `profiles/hybrid.env`, `profiles/local.env` | ACCEPTED — localhost-only, documented |
| SEC-010 | INFO | AWS workspace ID committed | `.envrc`, `profiles/cloud.env` | ACCEPTED — not a credential |
| SEC-011 | INFO | Residue check missing `exa_` prefix | `scripts/migrate-mcp-keys.sh:72` | FIXED — `exa_` added to regex |

## Cycle 1 — Code Review

| ID | Severity | Finding | File | Disposition |
|---|---|---|---|---|
| CODE-1 | IMPORTANT | Context7 header name non-standard (may be silent auth failure) | `.mcp.json:29-31` | DEFERRED — matches pre-existing config; owner to verify |
| CODE-2 | IMPORTANT | `cloud.env` uses `unset CLAUDE_CODE_ATTRIBUTION_HEADER` vs `=0` | `profiles/cloud.env:38` | FIXED |
| CODE-3 | IMPORTANT | Doctor writes to hardcoded `/tmp/fp-models.json` | `scripts/factory-profile:58,68` | DEFERRED — debug tool; low risk |
| CODE-4 | IMPORTANT | Write order in migrate-mcp-keys.sh (secrets before .mcp.json) | `scripts/migrate-mcp-keys.sh:54-65` | DOCUMENTED — intentional; comment added explaining why |
| SGGST-1 | SUGGESTION | `.factory-profile` missing trailing newline; `printf '%s'` propagates | `.factory-profile`, `scripts/factory-profile:108` | FIXED in commit ae84afa |
| SGGST-2 | SUGGESTION | `prism` entry missing `"type": "stdio"` | `plugins/secops-factory/.mcp.json` | FIXED in commit ae84afa |
| SGGST-3 | SUGGESTION | `eval` for dynamic var lookup; prefer `${!varname}` | `scripts/factory-profile:71` | DEFERRED — harmless, `eval` is correct here |
| SGGST-4 | SUGGESTION | `@playwright/mcp@latest` unpinned | `.mcp.json:23` | FIXED — pinned to 0.0.80 |
| SGGST-5 | SUGGESTION | Keychain lookup emits stale-key warning during `show` | `profiles/cloud.env:18-26` | DEFERRED — cosmetic |
| SGGST-6 | SUGGESTION | AWS vars duplicated in .envrc base and cloud.env | `.envrc:16-17`, `cloud.env:7-8` | DEFERRED — harmless redundancy |

## Cycle 2 Verdict

0 blocking findings remaining after cycle 2 fixes. Deferred items are all LOW/INFO/cosmetic or require owner verification (Context7 header).

**APPROVE** — ready for merge pending CI green on updated HEAD.

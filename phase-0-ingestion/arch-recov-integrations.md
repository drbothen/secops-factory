# Recovered Architecture — Integration Points & DTU Assessment

> Detail file for `recovered-architecture.md` (DF-021 shard)
> Step 0b: Architecture Recovery
> Date: 2026-07-19
>
> **Changelog (2026-07-19, adversarial review pass 2):**
> - ADV-0-206 / DI-001 RESOLVED: `.envrc` and `.mcp.json` credential exposure risk was resolved via PR #12 (merged 2026-07-19). Environment Variables table and Security Note updated to reflect gitignored status. The original HIGH-risk annotation was correct at extraction time but is now stale.
>
> **Changelog (2026-07-19, adversarial review pass 5):**
> - ADV-0-502: Corrected DTU-1 mock guidance for `jr issue comment` — was "allow (hook allows this)" which is wrong at HEAD. `jr issue comment` is in the require-review deny block (`require-review.sh:88-93`). Updated to "verify require-review hook fires (deny without review approval)". Note: the pass-5 fix also included an incorrect claim about a "review-approval override path via marker in the comment command" — that claim was wrong and is corrected in pass 6 (ADV-0-601, see below).
>
> **Changelog (2026-07-19, adversarial review pass 6):**
> - ADV-0-601: Corrected DTU-1 mock guidance — the pass-5 fix was still wrong in claiming a marker-based override exists. The `jr issue comment` deny is unconditional (`require-review.sh:88-94 (deny at :93)` write-block substring match; hook reads stdin JSON only; no bypass mechanism). The only unblock path is human permission-approval of the blocked call (Claude Code permission dialog). DTU should model deny + human-override. Resolution options tracked as DI-013, PENDING HUMAN DECISION at the Phase 0 gate.
> - ADV-0-705: Removed "deny from either wins" from DTU-1 comment-mock line — that phrase is Write-hook co-fire semantics (enrichment-completeness + disposition-guard on every Write event); the Bash/require-review path has only one hook.
> - ADV-0-706: Standardized `require-review.sh:88-93` → `88-94 (deny at :93)` throughout this file (ADV-0-601 changelog entry and DTU-1 comment-mock line).

---

## External Services

| Service | Protocol | Configuration | Purpose | Error Handling |
|---------|----------|--------------|---------|----------------|
| Jira (via jr CLI) | Jira REST API (wrapped by jr) | `jr auth login` — credentials stored by jr, no env var | Ticket read/write/comment/move; CMDB asset queries; changelog + comment history for metrics | Iron Law: never update without review approval. `require-review` hook blocks field-modifying jr commands. Skills halt on connection failure after one retry. |
| Perplexity MCP | MCP (stdio/JSON-RPC, npx-launched) | `PERPLEXITY_API_KEY` in `.mcp.json` (untracked) | CVE research, threat intel, OSINT sizing | Graceful fallback wired in every skill: on first Perplexity tool call failure → switch to WebSearch + WebFetch for session. The three CVSS-tiered tools (`perplexity_search` for CVSS <7.0, `perplexity_reason` for 7.0-8.9, `perplexity_research` for 9.0+) have explicit fallback paths; `perplexity_ask` (untiered — quick factual lookups) is used outside the CVSS tier routing and is not covered by the tiered fallback documentation (see DTU-2). |
| NVD REST API v2 | HTTPS | Hardcoded URL `https://services.nvd.nist.gov/rest/json/cves/2.0` | CVE data fallback | Used via `WebFetch` when Perplexity unavailable |
| FIRST EPSS API v1 | HTTPS | Hardcoded URL `https://api.first.org/data/v1/epss` | EPSS score fallback | Used via `WebFetch` when Perplexity unavailable |
| CISA KEV Feed | HTTPS (JSON file) | Hardcoded URL `https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json` | KEV status fallback | Used via `WebFetch` when Perplexity unavailable |

---

## Databases

No direct database connections. The plugin uses Jira as its system of record via the jr CLI.
Jira custom fields store: CVSS score, EPSS probability, KEV status, priority tier, ATT&CK mapping.

---

## Message Queues

None.

---

## File System Dependencies

| Path/Pattern | Purpose | R/W | Configuration |
|-------------|---------|-----|---------------|
| `${CLAUDE_PLUGIN_ROOT}/data/*.md` | Knowledge base reads | R | `CLAUDE_PLUGIN_ROOT` env var set by Claude Code plugin runtime |
| `${CLAUDE_PLUGIN_ROOT}/templates/*.yaml/.md` | Template schema reads | R | Same |
| `${CLAUDE_PLUGIN_ROOT}/checklists/*.md` | Quality checklist reads | R | Same |
| `${CLAUDE_PLUGIN_ROOT}/hooks/hooks.json` | Hook event wiring (overwritten by activate on Windows) | R (W on Windows activate) | Managed by `activate` skill |
| `.claude/settings.local.json` | Per-project activation state (agent default, activated_at) | R/W | Written by `activate` skill, read by `session-greeting` hook |
| `artifacts/enrichments/enrichment-*.md` | Enrichment report storage | W | Hardcoded relative path in skill procedures |
| `artifacts/reviews/review-*.md` | Review report storage | W | Same |
| `artifacts/investigations/investigation-*.md` | Investigation report storage | W | Same |
| `artifacts/metrics/*.md` | Metrics report storage | W | Same |
| `artifacts/metrics/effort-priors.yaml` | Org-specific measurement priors | R/W | Created from template by analyze-ticket-effort skill |
| `/tmp/effort_data/` | Background jr fetch cache (resumable) | R/W | Hardcoded in analyze-ticket-effort; `[ -s ]` guards prevent re-fetch |

---

## DTU Candidate Assessment (DF-011)

Three external services warrant DTU consideration. The plugin has no traditional API
server to clone — the integration surface is entirely outbound (to Jira and Perplexity)
and inbound fallback (NVD/EPSS/CISA read-only feeds).

### Prioritized DTU Candidates

| # | Service | Priority | Recommended Fidelity | Rationale |
|---|---------|----------|---------------------|-----------|
| DTU-1 | jr CLI / Jira | HIGH | L3 (Behavioral) | Required for every pipeline write. CRUD + status transitions + custom fields + changelog. High call volume in test scenarios. Without a DTU, all integration tests need live Jira credentials and real tickets. |
| DTU-2 | Perplexity MCP | MEDIUM | L2 (Stateful) | Research tool used in every pipeline (4 tool variants). Graceful fallback wired in all skills means tests can validate fallback paths without Perplexity, but testing the primary Perplexity path (tiered by CVSS severity) requires either a live API key or a behavioral clone. |
| DTU-3 | NVD / EPSS / CISA APIs | LOW | L1 (API Shape) | Read-only fallback APIs. Static response shapes; test scenarios can use fixed CVE IDs with known published data. A simple mock with valid response shapes suffices. |

---

### DTU-1 Assessment: jr CLI / Jira

| Factor | Assessment |
|--------|-----------|
| **Call volume** | HIGH — every enrichment, investigation, and metrics run makes multiple jr calls. In test scenarios: triage (view), research (view + assets), update (edit + comment + move) per ticket. |
| **Rate limit risk** | YES — Jira cloud API has per-tenant rate limits; bulk metrics fetches (>50 tickets) are documented to require background + resumable loops. |
| **Failure mode complexity** | COMPLEX — stateful: ticket must be in correct status for `jr issue move` to succeed; custom field schema can drift (field IDs change); changelog shape varies by Jira configuration. |
| **Auth complexity** | API key / OAuth via `jr auth login` — stored credential, not passed per-call. |
| **State requirements** | CRUD + complex state machine — tickets have status transitions, custom fields, comments, changelogs, linked assets. |
| **Test data sensitivity** | HIGH — real ticket IDs contain client names, asset details, CVE data. Cannot use live production tickets in CI. |

**Recommended approach:** Implement jr CLI DTU at L3 (Behavioral):
- Mock `jr issue view KEY` → return configurable ticket JSON fixtures
- Mock `jr issue list --jql "..."` → return paginated ticket list fixture
- Mock `jr issue changelog KEY` → return timestamped transition events fixture
- Mock `jr issue comments KEY` → return comment history fixture
- Mock `jr issue edit KEY` → apply state mutation, verify `require-review` hook fires
- Mock `jr issue move KEY STATUS` → validate status transitions, verify `require-review` hook fires
- Mock `jr issue comment KEY "msg"` → verify require-review hook fires (unconditional deny — `require-review.sh:88-94 (deny at :93)` write-block list; no marker-based override exists); DTU mock should model deny + human permission-approval as the only unblock path (DI-013, PENDING HUMAN DECISION)
- Mock `jr issue assets KEY` → return CMDB asset fixture

---

### DTU-2 Assessment: Perplexity MCP

| Factor | Assessment |
|--------|-----------|
| **Call volume** | MEDIUM — one or more Perplexity calls per CVE research and per threat scan. Tiered by CVSS: `perplexity_research` for CVSS 9.0+ (2-5 min), `perplexity_reason` for 7.0-8.9 (30-60s), `perplexity_search` for <7.0. |
| **Rate limit risk** | YES — deep research calls (perplexity_research) have significant latency and API cost. Running full test suites against live Perplexity API is impractical. |
| **Failure mode complexity** | BEHAVIORAL — skills have explicit Perplexity-unavailable fallback paths (checked at skill start via test call). DTU needs to simulate both available and unavailable states. |
| **Auth complexity** | API key in `.mcp.json` (PERPLEXITY_API_KEY). Untracked file — must not appear in CI. |
| **State requirements** | Effectively stateless per request — no cross-call state. But response content shapes vary by tool (search vs ask vs reason vs research). |
| **Test data sensitivity** | LOW — queries are about public CVEs and threat intel. Synthetic CVE IDs work fine. |

**Recommended approach:** Implement Perplexity DTU at L2 (Stateful):
- Return valid-shaped JSON responses for each tool variant (search/ask/reason/research)
- Include citations array (skills validate source URLs)
- Support "unavailable" mode (tool returns error) to test fallback paths
- Fixture responses keyed by CVE ID pattern for deterministic test results

---

### DTU-3 Assessment: NVD / EPSS / CISA APIs

| Factor | Assessment |
|--------|-----------|
| **Call volume** | LOW — fallback only, not primary path when Perplexity is available |
| **Rate limit risk** | LOW — NVD has public rate limits (5 req/30s without API key) but fallback scenarios are infrequent in normal operation |
| **Failure mode complexity** | SIMPLE — static read-only REST endpoints; response shapes are well-documented and stable |
| **Auth complexity** | None — public APIs (NVD API key optional for higher rate limits) |
| **State requirements** | Stateless — each request returns current CVE/EPSS/KEV state |
| **Test data sensitivity** | NONE — all public CVE data |

**Recommended approach:** Implement at L1 (API Shape):
- Static JSON fixtures for known CVE IDs (CVE-2021-44228, CVE-2023-44487, etc.)
- Validate correct URL patterns are called
- No state simulation needed

---

## Fidelity Level Reference (DF-011)

| Level | Description | DTU Candidate |
|-------|-------------|---------------|
| **L1: API Shape** | Correct endpoints, valid-shaped static responses | NVD/EPSS/CISA (DTU-3) |
| **L2: Stateful** | L1 + state persistence across requests | Perplexity MCP (DTU-2) |
| **L3: Behavioral** | L2 + edge cases, rate limiting, auth lifecycle, status-machine validation | jr CLI/Jira (DTU-1) |
| **L4: Adversarial** | L3 + failure injection, latency simulation | Not recommended at this phase |

---

## Environment Variables (Runtime)

| Variable | Set Where | Purpose | Risk |
|----------|-----------|---------|------|
| `ANTHROPIC_AWS_API_KEY` | `.envrc` (untracked, direnv) | Routes Claude Code to Anthropic API via AWS Marketplace | RESOLVED (PR #12, 2026-07-19) — `.envrc` is now gitignored; was HIGH at extraction time |
| `PERPLEXITY_API_KEY` | `.mcp.json` (untracked) | Perplexity MCP authentication | RESOLVED (PR #12, 2026-07-19) — `.mcp.json` is now gitignored; was HIGH at extraction time |
| Tavily API key (URL-embedded) | `.mcp.json` (untracked) | Tavily MCP (dev/optional) | MEDIUM |
| `CONTEXT7_API_KEY` | `.mcp.json` (untracked) | Context7 MCP (dev/optional) | MEDIUM |
| `CLAUDE_PLUGIN_ROOT` | Set by Claude Code plugin runtime | Base path for all ${CLAUDE_PLUGIN_ROOT}/ references in skills/agents | NONE — runtime-provided |

**Security Note (updated 2026-07-19 — DI-001 RESOLVED):** `.envrc` and `.mcp.json` were
not gitignored at initial extraction (Step 0a finding). Both were added to `.gitignore`
via PR #12 (merged 2026-07-19, commit da58b9a) and confirmed never committed to git
history. The credential exposure risk is resolved. Both files remain untracked (`??`)
in git status — correctly local-only and not committed.

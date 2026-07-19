# Adversarial Review — Phase 0 Ingestion, Pass 8

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary. Date: 2026-07-19._

---

## Pass 8 Report

**Verdict:** 6 findings — 1 CRITICAL / 1 major / 4 minor.

**HEADLINE:** ADV-0-801 was a GENUINE LIVE SHIPPED-CODE VULNERABILITY — not a documentation defect. Fresh-context adversarial review of the reverse-engineered spec surfaced a real exploitable authorization-gate bypass in v0.9.0 that 7 prior passes and the original authors missed. This demonstrates the core VSDD value proposition.

### Critical

| ID | Finding |
|----|---------|
| ADV-0-801 | **LIVE SHIPPED-CODE AUTH-GATE BYPASS.** The `require-review` hook evaluated the read-only allowlist BEFORE the write-block, using unanchored substring matching. This ordering meant any write command carrying a token that appeared as a substring of a read-only allowlist entry bypassed the gate entirely: `jr issue edit KEY --summary "see jr board"` → matched `jr board` (a read-only allowlist entry); `jr issue comment KEY "per jr me policy"` → matched `jr me`. The hook returned ALLOW without triggering review, defeating the sole CRITICAL authorization gate and the SEC-001 prompt-injection mitigation. Verified against shipped v0.9.0 source by orchestrator. |

### Major

| ID | Finding |
|----|---------|
| ADV-0-802 | **SEC-001 "hard-gated" status was overstated pre-PR#15.** Multiple shards described the SEC-001 mitigation as "hard-gated" and "unconditional." Given ADV-0-801, this characterization was inaccurate for v0.9.0 through pre-PR#15. All claims of unconditional gating must be scoped to post-PR#15. |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-803 | `enrichment-completeness` hook uses the same unanchored substring-matching idiom as the pre-PR#15 `require-review` allowlist. Lower criticality (not an auth gate), but same vulnerability class. Flagged as DI-014. |
| ADV-0-804 | Capstone BC-version narrative contained slips — some BCs cited earlier version numbers (v1.4, v1.5) in prose sections that had been superseded by v1.6+ revisions. |
| ADV-0-805 | `recovered-architecture.md` claimed the dependency graph was "algorithmically verified acyclic (DFS)." No DFS was ever run — the verification was manual visual inspection. Overclaim corrected to "manually verified acyclic." |
| ADV-0-806 | `HS-INDEX.md` category column showed a contradiction: HS-014 listed under both "must-pass" and "fix-target" categories in different parts of the table. Pass 6 remediation (ADV-0-602) reclassified HS-014 as fix-target but did not fully clean the must-pass column. |

### Clean Checks (confirmed correct this pass)

- Census 24/43 + derivation — PASS
- VP namespace uniqueness — PASS
- DAG structure (manually verified) — PASS
- Kill-rate attribution — PASS
- Mutation vectors defined for all 6 hooks — PASS
- Holdout distribution — PASS
- DI-001..DI-013 status fields — PASS
- Iron-Law attributions — PASS
- Security roll-up (pre-pass-8: 0C/0H/1M/4L/3I) — PASS (SEC-009 added during this pass)

### Process Gap (not counted as finding)

**Process-gap #7 (substring-matching-idiom sweep):** The unanchored-grep substring pattern appeared in `require-review`, `disposition-guard`, and `enrichment-completeness` hooks. A systematic idiom sweep should be part of every security-relevant remediation: when one hook is found to use a vulnerable pattern, all hooks must be checked for the same pattern before the fix is declared complete.

---

## Remediation Log

_All findings addressed 2026-07-19. ADV-0-801 fixed via PR #15 (d304fa5)._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-801 | FIXED — PR #15 merged (d304fa5) | Write-block reordered BEFORE allowlist check. `--output json` write forms added to write-block. Trailing-space `comment`/`comments` guard added. 12 new BATS tests red→green. Suite: 55/55 + shellcheck clean. SEC-009 logged (CRITICAL-at-discovery, RESOLVED). `BC-3.01.001` v1.7: write-block-first documented, Invariant #5 added, EC-016 added, input-hashes recomputed. |
| ADV-0-802 | FIXED | All "hard-gated"/"unconditional" characterizations of SEC-001 scoped to post-PR#15 in `security-audit.md`, `conventions.md`, and `project-context.md`. Pre-PR#15 period annotated as "bypass risk existed (ADV-0-801)." |
| ADV-0-803 | LOGGED | DI-014 added (LOW): enrichment-completeness hook substring-matching idiom, same vulnerability class as pre-PR#15 require-review. Target: first Feature Mode cycle. No immediate fix — not an auth gate. |
| ADV-0-804 | FIXED | Capstone BC-version narrative corrected; all BC version citations updated to current (v1.7, v1.3, v1.3, etc.). `project-context.md` v1.8. |
| ADV-0-805 | FIXED | `recovered-architecture.md` DAG verification claim corrected to "manually verified acyclic." |
| ADV-0-806 | FIXED | `HS-INDEX.md` HS-014 category column cleaned — must-pass column entry removed, fix-target column entry confirmed. HS-026 added (bypass regression guard: input must return DENY; initial expected-result was inverted — caught by orchestrator verification and corrected). `HS-INDEX.md` v1.2/active. |

**Lesson (HS-026 expected-result error):** The initial HS-026 expected-result was set to ALLOW (inverted). Orchestrator caught this during post-generation verification against merged PR#15 code. Lesson: holdout expected-results must be verified against merged code, not the pre-fix BC — the BC describes the bug, not the fix.

# Adversarial Review — Phase 0 Ingestion, Pass 4

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary. Date: 2026-07-19._

---

## Pass 4 Report

**Verdict:** 8 findings — 1 critical / 3 major / 4 minor. Novelty: MODERATE-HIGH.

**Note on ADV-0-401:** Adjudicated FALSE POSITIVE by orchestrator after live evidence review (see below).

### Critical

| ID | Finding | Adjudication |
|----|---------|--------------|
| ADV-0-401 | **Re-sync posture unverifiable — PRs #11-#14 allegedly unmerged.** Adversary's session-start git snapshot showed PRs #11-#14 as pending, contradicting capstone claims that these are merged. All PR-dependent remediation would be invalidated if unmerged. | **FALSE POSITIVE** — adjudicated by orchestrator with live evidence: HEAD 0ec794a == `origin/main`; `git log` confirms #11-#14 merged; `.gitignore` contains all four secret entries. Root cause: adversary trusted a stale session-start git snapshot as ground truth. Process-gap #4: adversary environment snapshots must be treated as unverified; adversary must re-check against live repo state before issuing critical findings based on merge status. |

### Major

| ID | Finding |
|----|---------|
| ADV-0-402 | **BC-3.02.001 postcondition-vs-EC-004 contradiction on untested investigation branch.** The postcondition asserts the hook ALLOWS when all sections present; EC-004 claimed the hook PASSES on the investigation branch even with a missing section. Ground truth from code: the hook DENIES on ANY missing section regardless of branch. EC-004 was wrong — it described a fail-open path that does not exist. |
| ADV-0-403 | **Stale `hooks.bats` line anchors in 5 sibling BCs and `conventions.md`.** Pass-1 and pass-3 fixes updated some BCs, but `@test` NAME anchors in BC-3.02.001 through BC-3.06.001 and in `conventions.md` still reference line numbers from a prior version of `hooks.bats`. Partial-fix propagation again. |
| ADV-0-404 | **Per-artifact census double-counts `secops-health`.** The secondary component derivation (24-1+19+1=43) is opaque and inconsistently applied across `project-context.md`, `project-discovery.md`, and `module-criticality.md`. `secops-health` appears in both primary and secondary counts in at least one location, inflating the total by 1 (42-vs-43). |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-405 | `require-review` line-anchor citation is off-by-one in 3 documents (`project-context.md`, `module-criticality.md`, `verification-gap-analysis.md`). All cite line 47; actual anchor is line 48. |
| ADV-0-406 | `vga:190` anchor (kill-rate measurement line reference) used in multiple shards; the current `verification-gap-analysis.md` puts that finding at line 194. |
| ADV-0-407 | DI-003 edge (`adversarial-review-secops` → orchestrator canonical playbook) is absent from the YAML dependency graph in `recovered-architecture.md`. The prose correctly describes the dependency; the machine-readable graph omits it. |
| ADV-0-408 | `module-criticality.md` version field reads `1.2` in the YAML frontmatter but the document body references `v1.3` in the change log. Version hygiene gap; no `version_history` table present. |

### Clean Checks (confirmed correct this pass)

- Census total 43 (once derivation corrected) — PASS
- VP uniqueness across all 13 BCs — PASS
- Holdout scenario distribution (25, 4+4C/16H/1M) — PASS
- Security-finding tallies (0C/0H/1M/4L/3I) — PASS
- Template count 6, hook count 6, agent count 6 — PASS

### Process Gaps (not counted as findings)

**Process-gap #4** (described above under ADV-0-401): Adversary must not trust session-start git snapshots as ground truth for merge status. Adversary must re-verify live against `git log` or remote before issuing criticals based on perceived unmerged state.

**Process-gap #5**: All 13 BCs were extracted with `input-hash: "[live-state]"` placeholders — no sha256 hashes were computed at extraction time. Drift detection is non-functional for the full BC set. Input-hashes must be computed and recorded at extraction, not left as placeholders.

---

## Remediation Log

_All 8 findings addressed 2026-07-19. ADV-0-401 no fix required (false positive documented above)._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-401 | NO FIX NEEDED | False positive. Adjudication and evidence documented in this report. Process-gap #4 codified for pipeline. |
| ADV-0-402 | FIXED | EC-004 in `BC-3.02.001` corrected: investigation-branch path now shows DENY on any missing section. Canonical vector updated to DENY. BC-3.02.001 revised to v1.1. |
| ADV-0-403 | FIXED | Five sibling BCs (BC-3.02.001 through BC-3.06.001) re-anchored using `@test NAME` form (stable, line-number-independent). `conventions.md` re-anchored similarly. All now at v1.1 where not already versioned higher. |
| ADV-0-404 | FIXED | Secondary census derivation made explicit: 24 primary − 1 (secops-health promoted to secondary HEAD) + 19 stubs + 1 (secops-health secondary entry) = 43. `secops-health` appears once in each tier cleanly; double-count eliminated. Derivation formula present in all three documents. |
| ADV-0-405 | FIXED | `require-review` line anchor corrected to line 48 in all three documents. |
| ADV-0-406 | FIXED | Kill-rate citations re-anchored to section-name form (`## Mutation Kill-Rate Baseline`) rather than fragile line numbers. `vga:190` / `vga:194` form replaced. |
| ADV-0-407 | FIXED | C-2→C-6 DI-003 edge added to YAML dependency graph in `recovered-architecture.md`. Acyclicity re-verified after addition. |
| ADV-0-408 | FIXED | `module-criticality.md` frontmatter version set to `1.3`; `version_history` table added; status set to `active`. |
| All 13 BCs | UPDATED | sha256 input-hashes computed and recorded in all 13 BC frontmatter fields. Drift detection now functional. |
| Capstone | UPDATED | `project-context.md` re-synced to v1.4 (375 lines) incorporating: pwsh-skip caveat, false-positive adjudication record, status `awaiting-phase-0-gate`, corrected derivation formula, section-name kill-rate anchors. |

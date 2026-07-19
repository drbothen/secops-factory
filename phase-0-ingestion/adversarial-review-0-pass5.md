# Adversarial Review — Phase 0 Ingestion, Pass 5

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary (instructed to distrust stale environment snapshots per pass-4 lesson). Date: 2026-07-19._

---

## Pass 5 Report

**Verdict:** 6 findings — 0 critical / 2 major / 4 minor. Novelty: MEDIUM.

**Finding decay:** 12 → 11 → 7 → 8(1FP) → 6. Majors: 6→5→4→3→2. Zero criticals for three consecutive passes.

### Verified GREEN Axes (no findings)

- Census: 24 primary / 43 secondary + explicit derivation formula — PASS
- DAG acyclicity (DFS verified) — PASS
- VP namespace uniqueness across all 13 BCs — PASS
- Iron-Law attributions (create-advisory, analyze-ticket-effort, assess-priority, generate-metrics) — PASS
- 138-test decomposition (130 original + 8 PR-14 additions) — PASS
- Holdout distribution (25 scenarios: 4+4C / 16H / 1M) — PASS
- DI-001..DI-012 status fields — PASS

### Major

| ID | Finding |
|----|---------|
| ADV-0-501 | **Cross-BC contradiction: enrichment-completeness DENY vs disposition-guard allow.** `BC-3.03.001` (enrichment-completeness hook) was revised in pass 1 to a full-deny model — all 4 section checks DENY on missing content. However `BC-3.02.001` (disposition-guard hook) has a postcondition allowing the in-progress state when investigation documents are partially present. These two BCs govern the same file in the same workflow, and a missing investigation doc would simultaneously satisfy one BC's DENY path and another BC's ALLOW path. Ground truth: the standard workflow generates investigation docs once from the complete template (Stage 7); there is no partial-save path in the actual hook logic. The contradiction is a spec artifact, not a runtime conflict, but it is misleading. Resolution: HOOK-ISOLATED annotations added to both BCs noting the non-overlapping execution contexts + aggregate-gate-behavior note in `BC-5.01.001`. |
| ADV-0-502 | **`arch-recov-integrations.md` DTU-1 mock guidance contradicts SEC-001 fix.** The integration shard's mock guidance for the `comment` operation still says "comment → allow (pass through to Jira)" — this is the pre-fix behavior. The SEC-001 fix (PR #13) requires the hook to DENY the comment operation. A test harness following this mock guidance would be testing the wrong behavior. Resolution: corrected to DENY + override-path modeling note added. |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-503 | `project-discovery.md` §8.1 still contains the pre-PR-12 claim that `.envrc` and `.mcp.json` are not gitignored. This is now stale (PR #12 added them). The finding is low-impact since §8 is a historical snapshot, but it could mislead readers. Resolution: annotated with "(RESOLVED — PR #12, 2026-07-19)" inline. |
| ADV-0-504 | `BC-3.01.001` EC-015 (`--output json` defense-in-depth mechanism) lacks an anchor reference to the governing test name in `hooks.bats`. Other ECs in the same BC carry `@test` NAME anchors; EC-015 is inconsistent. Resolution: anchor added; BC-3.01.001 revised to v1.5. |
| ADV-0-505 | `holdout-scenarios/brownfield-regression-enrichment-completeness-002.md` (HS-010) contains a fixture that predates the enrichment-completeness full-deny rewrite — fixture documents a partial-section-present allow case that no longer exists. Scenario is stale. Resolution: HS-010 regenerated to v1.1 — fixture updated to complete-document allow scenario (the one valid passing case post-rewrite). |
| ADV-0-507 | Four hook BCs (BC-3.03.001 through BC-3.06.001) carry single-file `input-hash` fields but the hooks they govern have a companion `.ps1` sibling. Input-hash should be normalized to a dual-file form to cover both the `.sh` and `.ps1` source. Resolution: input-hash fields normalized to dual-file form in those 4 BCs. |

---

## Remediation Log

_All 6 findings addressed 2026-07-19, same-day, verified by artifact owners._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-501 | FIXED | `BC-3.02.001` v1.2 and `BC-3.03.001` v1.2 annotated with HOOK-ISOLATED execution-context note. `BC-5.01.001` v1.1 updated with aggregate-gate-behavior note clarifying the non-conflicting execution order. |
| ADV-0-502 | FIXED | `arch-recov-integrations.md` DTU-1 mock guidance corrected: comment operation → DENY. Override-path modeling note added for test-harness authors. |
| ADV-0-503 | FIXED | `project-discovery.md` §8.1 stale gitignore claim annotated with "(RESOLVED — PR #12, 2026-07-19)". Historical snapshot character of §8 preserved; resolution date makes status clear. |
| ADV-0-504 | FIXED | `BC-3.01.001` EC-015 `@test` NAME anchor added. BC-3.01.001 revised to v1.5. |
| ADV-0-505 | FIXED | `holdout-scenarios/brownfield-regression-enrichment-completeness-002.md` (HS-010) regenerated to v1.1: fixture updated to complete-document allow scenario reflecting post-rewrite hook behavior. HS-INDEX.md updated. |
| ADV-0-507 | FIXED | BC-3.03.001, BC-3.04.001, BC-3.05.001, BC-3.06.001 input-hash fields normalized to dual-file form covering both `.sh` and `.ps1` sources. |
| Capstone | UPDATED | `project-context.md` re-synced to v1.5 incorporating: pwsh-skip caveat clarification, false-positive adjudication cross-reference, pass-5 remediation summary, DI status refresh. |

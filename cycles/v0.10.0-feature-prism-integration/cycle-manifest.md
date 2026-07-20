---
document_type: cycle-manifest
cycle_id: v0.10.0-feature-prism-integration
cycle_type: feature
version: v0.10.0
status: in-progress
started: 2026-07-19T00:00:00Z
completed:
producer: orchestrator
---

# Cycle Manifest: v0.10.0 (Feature — prism-integration)

## Feature

| Field | Value |
|-------|-------|
| **Feature** | prism-integration |
| **Mode** | Feature Mode (brownfield-managed) |
| **Started** | 2026-07-19 |
| **Source Brief** | `.factory/feature/prism-integration-handoff-brief.md` |
| **Research** | `.factory/research/soc-analyst-workflow-2026.md` |
| **Status** | F1-complete — gate pending human approval |

## Scope Summary

New skills: activate, onboard-customer, onboard-sensor, metrics, scan-threats (upgrade),
monitoring-loop. Upgrades: investigate-event, assess-priority, secops-protocol.md.
.sh/.ps1 parity for all new hooks/scripts. BATS test coverage.
DI-013 marker mechanism (D-005).

## Maintenance Sweeps

Paused for cycle duration. No sweeps currently scheduled. Resume after F7 convergence.

## Delivered

| Metric | Value |
|--------|-------|
| Stories delivered | TBD |
| BCs created | TBD |
| VPs created | TBD |
| Holdout scenarios | TBD |
| Total cost | TBD |
| Adversarial passes | TBD |
| Final holdout satisfaction | TBD |
| Release version | v0.10.0 |

## Spec Changes

| Artifact | Change | Before | After |
|----------|--------|--------|-------|
| prd.md | TBD — F2 spec evolution | — | — |

## Living Spec Snapshot

Captured at: git tag v0.10.0 on factory-artifacts branch (after F7 convergence)
Retrieve: git show v0.10.0:specs/prd.md

## Tech Debt Created

| ID | Description | Priority | Source |
|----|-------------|----------|--------|
| — | TBD | — | — |

## F1 Delta Analysis

| Field | Value |
|-------|-------|
| **Completed** | 2026-07-20 |
| **Gate status** | Awaiting human approval |
| **Feature classification** | backend / feature / standard |
| **Regression baseline ref** | `d181ca2` (main — fix(ci): assert pwsh + PSScriptAnalyzer, hooks.json schema, secops-health skill) |

### F1 Artifacts

| File | Description |
|------|-------------|
| `.factory/phase-f1-delta-analysis/impact-boundary.md` | 14 NEW / 13 MODIFIED / 12 DEPENDENT plugin artifacts; 8 ASMs, 8 Rs; 9 F2 decisions (D-DEC-001..009) |
| `.factory/phase-f1-delta-analysis/artifact-mapping.md` (v1.1) | 6 BCs MODIFIED, 3 dependent, 5 NEW BC slots (BC-6.01.003/004, BC-8.02.001, BC-9.01.001, BC-10.01.001); ~57 direct + ~17 dependent regression-zone tests; HS-035..044 new subjects; VP-HOOK-024/025/026, VP-SKILL-050/051 new subjects |
| `.factory/phase-f1-delta-analysis/delta-analysis.md` (v1.1) | Feature synthesis: backend / feature / standard; REC-001..006 resolved; cross-tenant correlation prism-side only |
| `.factory/phase-f1-delta-analysis/affected-files.txt` | Machine-readable list of all affected source files |
| `.factory/phase-f1-delta-analysis/f1-consistency-validation.md` | PASS-WITH-MINORS — 1 MAJOR (VP namespace) + 6 minors; all 7 remediated same-burst |

### F1 Consistency Results

- **Initial findings:** 7 (1 MAJOR VP namespace collision + 6 minors)
- **Remediated same-burst:** 7
- **Open at gate:** 0
- **Gate verdict:** PASS-WITH-MINORS (all clear)

## Notes

Entry via Feature Mode — Phase 0 skipped (project-context.md v2.3 is scope baseline).
DI-013 resolved this cycle via marker mechanism (D-005).
D-006: demo assets are out of scope; only the generic `jr` auth check in `activate` is in scope.

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
| **Status** | F1-in-progress |

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

## Notes

Entry via Feature Mode — Phase 0 skipped (project-context.md v2.3 is scope baseline).
DI-013 resolved this cycle via marker mechanism (D-005).
D-006: demo assets are out of scope; only the generic `jr` auth check in `activate` is in scope.

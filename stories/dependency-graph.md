---
document_type: dependency-graph
level: ops
version: "1.0"
producer: story-writer
timestamp: 2026-09-04T00:00:00
phase: f3
cycle: "v0.10.0-feature-prism-integration"
canonical_source: .factory/phase-f3-stories/dependency-graph-extended.md
---

# Stories Dependency Graph — Wave 7: monitoring-loop

> **Canonical source:** `.factory/phase-f3-stories/dependency-graph-extended.md`
> This file is the `.factory/stories/`-level reference copy for the F3 gate and downstream tooling.

## Topological Wave Order (ACYCLIC — verified)

| Wave | Stories | Points |
|------|---------|--------|
| Wave 1 | S-3.01, S-4.02, S-6.03 | 8 + 5 + 3 = 16 |
| Wave 2 | S-3.02, S-6.01, S-8.01, S-9.01 | 13 + 5 + 5 + 5 = 28 |
| Wave 3 | S-4.01, S-5.01, S-6.02 | 8 + 5 + 5 = 18 |
| Wave 4 | S-10.01 | 13 |
| Wave 5 | S-10.02, S-11.01 (standalone demo) | 8 + 5 = 13 |
| **Total** | **13 stories** | **88 points** |

## Direct Dependencies (depends_on)

| Story | depends_on |
|-------|-----------|
| S-3.01 | (none) |
| S-3.02 | S-3.01 |
| S-4.01 | S-3.01, S-3.02 |
| S-4.02 | (none) |
| S-5.01 | S-3.02 |
| S-6.01 | S-6.03 |
| S-6.02 | S-6.01 |
| S-6.03 | (none) |
| S-8.01 | S-6.03 |
| S-9.01 | S-6.03 |
| S-10.01 | S-3.01, S-3.02, S-4.01, S-4.02, S-6.01, S-6.02, S-6.03 |
| S-10.02 | S-10.01 |
| S-11.01 | (none — standalone demo tooling per D-006/D-035) |

## Gap Register Summary

| Gap ID | Source | Status | Justification Summary |
|--------|--------|--------|-----------------------|
| GAP-001 | BC-10.01.001 EC-012 (propose-reopen) | RESOLVED | Monitoring-loop Stage-7 action; covered by S-10.01 AC-024 (VP-SKILL-062). Prior justification (disposition-guard territory) was incorrect. |
| GAP-002 | BC-10.01.001 EC-022 (close 3-cond AND gate) | PARTIAL — loop-side covered | Loop-side positive path: S-10.01 AC-025. Disposition-guard STEP 4b deny-path coverage: S-3.02 ACs. |
| GAP-003 | BC-10.01.001 PC#6 (append-comment + link-related SLA-surface) | RESOLVED | Append-comment and link SLA-surface delegated transitively to S-4.01 AC-010 (VP-SKILL-067) via Stage-8 delegation; VP-SKILL-067 exercises 5 SLA-surface vectors. P9-003. |

See canonical source for full gap register and traceability matrices.

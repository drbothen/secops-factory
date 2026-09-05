---
document_type: story-index
level: ops
version: "1.0"
status: draft
producer: story-writer
timestamp: 2026-09-04T00:00:00
phase: f3
inputs: []
input-hash: "d41d8cd"
traces_to: .factory/phase-f3-stories/dependency-graph-extended.md
cycle: "v0.10.0-feature-prism-integration"
---

# Story Index — F3 Wave 7: monitoring-loop Feature Cycle

**Cycle:** v0.10.0-feature-prism-integration
**Phase:** F3 Incremental Stories (INTEGRATE sub-burst complete 2026-09-04)
**Total:** 13 stories | 88 story points | 5 execution waves
**Cycle check:** ACYCLIC (Kahn topological sort — verified 2026-09-04)

---

## All Stories

| Story ID | Title | Epic | Points | Wave | Status | BC Coverage | Priority | Story File |
|----------|-------|------|--------|------|--------|-------------|----------|-----------|
| S-3.01 | require-review Link+Close Anti-Fungibility | EPIC-HOOKS | 8 | 1 | draft | BC-3.01.001 | P0 | S-3.01-require-review-link-close-antifungibility.md |
| S-4.02 | assess-priority scored_priority Coherence | EPIC-SKILLS | 5 | 1 | draft | BC-4.05.001 | P1 | S-4.02-assess-priority-scored-priority-coherence.md |
| S-6.03 | Activate CLOSE_STATE_ALLOWLIST Validation | EPIC-LIFECYCLE | 3 | 1 | draft | BC-6.01.001 | P0 | S-6.03-activate-close-state-config.md |
| S-3.02 | disposition-guard F2 Delta (D-023/D-026/D-027/D-028/D-029) | EPIC-HOOKS | 13 | 2 | draft | BC-3.03.001 | P0 | S-3.02-disposition-guard-f2-delta.md |
| S-6.01 | onboard-customer Skill | EPIC-LIFECYCLE | 5 | 2 | draft | BC-6.01.003 | P1 | S-6.01-onboard-customer-skill.md |
| S-8.01 | sensor-metrics Skill | EPIC-METRICS | 5 | 2 | draft | BC-8.02.001 | P1 | S-8.01-sensor-metrics-skill.md |
| S-9.01 | scan-threats Skill | EPIC-THREATHUNTING | 5 | 2 | draft | BC-9.01.001 | P1 | S-9.01-scan-threats-skill.md |
| S-4.01 | update-jira Compound Create+Link + Orphan-Link Recovery | EPIC-SKILLS | 8 | 3 | draft | BC-4.02.001 | P0 | S-4.01-update-jira-compound-link.md |
| S-5.01 | investigate-event D-029 SAVE-ALWAYS-SUCCEEDS | EPIC-SKILLS | 5 | 3 | draft | BC-5.01.001 | P1 | S-5.01-investigate-event-d029-save-always.md |
| S-6.02 | onboard-sensor Skill | EPIC-LIFECYCLE | 5 | 3 | draft | BC-6.01.004 | P1 | S-6.02-onboard-sensor-skill.md |
| S-10.01 | monitoring-loop Core Pipeline (Stages 0-8, ICD-203, Hard-Floor, Kill-Switch) | EPIC-MONITORING | 13 | 4 | draft | BC-10.01.001 | P0 | S-10.01-monitoring-loop-core.md |
| S-10.02 | monitoring-loop Watermark + Late-Event Detection | EPIC-MONITORING | 8 | 5 | draft | BC-10.01.001 | P0 | S-10.02-monitoring-loop-watermark.md |
| S-11.01 | demo Jira seeding script (operator tooling) | E-DEMO | 5 | 5 | draft | (none — D-006/D-035) | P1 | S-11.01-demo-seed-jira.md |

All story files are under `.factory/phase-f3-stories/`.

---

## Wave Summary

| Wave | Stories | Points | Parallel? |
|------|---------|--------|-----------|
| 1 | S-3.01, S-4.02, S-6.03 | 16 | Yes (3-way) |
| 2 | S-3.02, S-6.01, S-8.01, S-9.01 | 28 | Yes (4-way) |
| 3 | S-4.01, S-5.01, S-6.02 | 18 | Yes (3-way) |
| 4 | S-10.01 | 13 | Single story (bottleneck) |
| 5 | S-10.02, S-11.01 | 13 | Yes (2-way; independent) |
| **Total** | **13** | **88** | |

---

## Epic Summary

| Epic ID | Description | Stories | Points |
|---------|-------------|---------|--------|
| EPIC-HOOKS | Hooks — require-review + disposition-guard | S-3.01, S-3.02 | 21 |
| EPIC-SKILLS | Skills — update-jira, assess-priority, investigate-event | S-4.01, S-4.02, S-5.01 | 18 |
| EPIC-LIFECYCLE | Lifecycle management — activate, onboard-customer, onboard-sensor | S-6.01, S-6.02, S-6.03 | 13 |
| EPIC-METRICS | Metrics pipeline | S-8.01 | 5 |
| EPIC-THREATHUNTING | Threat hunting | S-9.01 | 5 |
| EPIC-MONITORING | Monitoring loop — core + watermark | S-10.01, S-10.02 | 21 |
| E-DEMO | Demo operator tooling (D-006/D-035 scope) | S-11.01 | 5 |
| **Total** | | **13** | **88** |

---

## BC Coverage

| BC ID | Version | Story | Status |
|-------|---------|-------|--------|
| BC-3.01.001 | v1.25 | S-3.01 | Covered |
| BC-3.03.001 | v1.42 | S-3.02 | Covered |
| BC-4.02.001 | v1.21 | S-4.01 | Covered |
| BC-4.05.001 | v1.4 | S-4.02 | Covered |
| BC-5.01.001 | v1.15 | S-5.01 | Covered |
| BC-6.01.001 | v1.8 | S-6.03 | Covered |
| BC-6.01.003 | v1.7 | S-6.01 | Covered |
| BC-6.01.004 | v1.1 | S-6.02 | Covered |
| BC-8.02.001 | v1.4 | S-8.01 | Covered |
| BC-9.01.001 | v1.2 | S-9.01 | Covered |
| BC-10.01.001 | v1.36 | S-10.01, S-10.02 | Covered (split: core + watermark) |

---

## Gap Register

| Gap ID | Source | Status | Disposition | Covered By |
|--------|--------|--------|-------------|-----------|
| GAP-001 | BC-10.01.001 EC-012 (propose-reopen) | RESOLVED | Monitoring-loop Stage-7 action — loop drafts propose-only comment + SLA statement; never auto-reopens (VP-SKILL-062) | S-10.01 AC-024 |
| GAP-002 | BC-10.01.001 EC-022 (close 3-cond AND gate) | PARTIAL | Loop-side positive path covered; disposition-guard STEP 4b deny-paths remain S-3.02 scope | S-10.01 AC-025 (loop-side), S-3.02 ACs (gate) |
| GAP-003 | BC-10.01.001 PC#6 (append-comment + link-related SLA-surface) | RESOLVED | Propose-reopen SLA covered by S-10.01 AC-024. Append-comment and link SLA-surface delegated transitively to S-4.01 AC-010 (VP-SKILL-067), which the monitoring-loop invokes at Stage 8; VP-SKILL-067 exercises 5 SLA-surface vectors including append and link (P9-003 traceability closure) | S-4.01 AC-010 (VP-SKILL-067) |

---

## Pre-Dispatch Blockers

| Story | Blocker | Status |
|-------|---------|--------|
| S-10.01 | ASM-015: permissionDecision:deny in --allowedTools JSON envelope unvalidated | OPEN — BLOCKING (STATE.md) |
| S-10.01 | ASM-009: cross-hook marker filesystem visibility unvalidated | OPEN — BLOCKING (STATE.md) |

Both blockers must resolve before dispatching S-10.01 to the implementer.

**ASM-009 gate-timing note:** Per-hook unit tests (Waves 1–3) seed markers directly into test
fixtures and do not exercise cross-hook filesystem visibility. ASM-009 is only exercised when
the monitoring-loop (Wave 4) writes verdicts and both hooks consume from the same marker
directory. The operative gate is therefore pre-Wave-4 dispatch (not pre-Wave-3).

---

## Legacy Stub Cross-Reference

| Legacy ID | Canonical ID | Legacy File | Canonical File |
|-----------|-------------|-------------|----------------|
| STORY-DEMO-SEED-001 | S-11.01 | .factory/stories/STORY-DEMO-SEED-001.md | .factory/phase-f3-stories/S-11.01-demo-seed-jira.md |

---

## Dependency Graph Reference

- Full graph with traceability matrices: `.factory/phase-f3-stories/dependency-graph-extended.md`
- Summary reference copy: `.factory/stories/dependency-graph.md`
- Wave schedule: `.factory/feature/wave-schedule.md`
- Sprint state: `.factory/stories/sprint-state.yaml`

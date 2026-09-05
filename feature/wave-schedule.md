---
document_type: wave-schedule
level: ops
version: "1.0"
status: draft
producer: story-writer
timestamp: 2026-09-04T00:00:00
phase: f3
inputs: []
input-hash: "d41d8cd"
traces_to: .factory/stories/STORY-INDEX.md
cycle: "v0.10.0-feature-prism-integration"
---

# Wave Schedule: secops-factory — monitoring-loop Feature Cycle (F3)

## Context: Two-Level Wave Numbering

This document uses two levels of wave numbering that must not be conflated:

**Outer level — Feature Cycle Label:** STATE.md identifies this entire feature delivery as
"Wave 7 — monitoring-loop" at the project/release cycle level. This is a label for the
release increment, not an execution wave.

**Inner level — F3 Execution Waves (1–5):** The 5 waves below are the parallel execution
schedule for the 13 F3 stories WITHIN Wave 7. When reading "Wave N" in this document,
it means F3 execution wave N (not the outer cycle wave 7).

## Summary

| Metric | Value |
|--------|-------|
| Total stories | 13 |
| Total waves | 5 |
| Max parallelism (groups per wave) | 4 (Wave 2) |
| Estimated agent spawns | 13 (one per story) |

## Wave Plan

### Wave 1 (no dependencies)

Stories with no intra-cycle dependencies. Run in parallel.

| Group | Stories | Points | Complexity | Agent Scope |
|-------|---------|--------|-----------|-------------|
| A | S-3.01 | 8 | M | 1 story/agent — hooks/require-review/ |
| B | S-4.02 | 5 | S | 1 story/agent — skills/assess-priority/ |
| C | S-6.03 | 3 | S | 1 story/agent — skills/activate/ |

Wave 1 total: 16 points. All 3 stories start simultaneously.

### Wave 2 (depends on Wave 1)

| Group | Stories | Points | Complexity | Agent Scope |
|-------|---------|--------|-----------|-------------|
| A | S-3.02 | 13 | XL | 1 story/agent — hooks/disposition-guard/ |
| B | S-6.01 | 5 | S | 1 story/agent — skills/onboard-customer/ |
| C | S-8.01 | 5 | S | 1 story/agent — skills/sensor-metrics/ |
| D | S-9.01 | 5 | S | 1 story/agent — skills/scan-threats/ |

Wave 2 total: 28 points. Gate: S-3.01 (Wave 1) done before S-3.02; S-6.03 (Wave 1) done before S-6.01/S-8.01/S-9.01.

### Wave 3 (depends on Wave 2)

| Group | Stories | Points | Complexity | Agent Scope |
|-------|---------|--------|-----------|-------------|
| A | S-4.01 | 8 | M | 1 story/agent — skills/update-jira/ |
| B | S-5.01 | 5 | S | 1 story/agent — skills/investigate-event/ |
| C | S-6.02 | 5 | S | 1 story/agent — skills/onboard-sensor/ |

Wave 3 total: 18 points. S-4.01 gates on both S-3.01 (W1) and S-3.02 (W2). S-5.01 gates on S-3.02 (W2). S-6.02 gates on S-6.01 (W2).

### Wave 4 (depends on Wave 3)

| Group | Stories | Points | Complexity | Agent Scope |
|-------|---------|--------|-----------|-------------|
| A | S-10.01 | 13 | XL | 1 story/agent — skills/monitoring-loop/ (Stages 0-8 + ICD-203 + hard-floor + kill-switch) |

Wave 4 total: 13 points. Single bottleneck story — all hooks and skills must be complete.

**BLOCKING NOTE (pre-dispatch gate):** ASM-015 (permissionDecision:deny in --allowedTools
JSON envelope) and ASM-009 (cross-hook marker filesystem visibility) must both resolve before
dispatching S-10.01. See STATE.md Drift Items. Failure to resolve will produce incorrect hook
integration in the monitoring-loop.

**ASM-009 gate-timing note:** Per-hook unit tests in Waves 1–3 seed marker files directly into
test fixtures and do not exercise cross-hook filesystem visibility. ASM-009 is only activated
when the monitoring-loop (Wave 4) writes verdicts and both hooks (require-review + disposition-guard)
read from the same shared marker directory. The operative gate is therefore pre-Wave-4 dispatch.
(HS-INDEX references "pre-Wave-3" in the context of per-hook unit test seed markers, which is a
different scope; pre-Wave-4 is the integration gate for ASM-009.)

### Wave 5 (depends on Wave 4 / standalone)

| Group | Stories | Points | Complexity | Agent Scope |
|-------|---------|--------|-----------|-------------|
| A | S-10.02 | 8 | M | 1 story/agent — skills/monitoring-loop/ (watermark + DETECT_LATE_EVENT + cron) |
| B | S-11.01 | 5 | S | 1 story/agent — scripts/demo/ (operator tooling; standalone per D-006/D-035) |

Wave 5 total: 13 points. S-10.02 gates on S-10.01 (W4). S-11.01 is independent but
scheduled last per D-035 (demo operator tooling must not gate product waves).

## Pipeline Overlap Plan

| Parallel Activity | When |
|------------------|------|
| Wave 2 stubs + tests | Start when Wave 1 stories merge to main |
| Wave 3 stubs + tests | Start when Wave 2 stories merge to main |
| Wave 4 stub (S-10.01) | Start when Wave 3 stories merge + ASM-015/ASM-009 resolved |
| Wave 5 stubs + tests | Start when Wave 4 story merges |
| S-11.01 (demo) | Can begin any wave; must not gate product waves |

## Critical Path

Longest chain of dependent stories through the dependency graph:

```
S-3.01 (W1, 8pt) → S-3.02 (W2, 13pt) → S-4.01 (W3, 8pt) → S-10.01 (W4, 13pt) → S-10.02 (W5, 8pt)
```

Critical path total: 50 story points, 5 waves.

Parallelism saves over serial execution:
- Wave 2: S-6.01, S-8.01, S-9.01 run in parallel with S-3.02 (28pt wave in parallel vs serial)
- Wave 3: S-5.01, S-6.02 run in parallel with S-4.01
- Wave 5: S-11.01 runs in parallel with S-10.02

---

## Dependency Graph Reference

See `.factory/phase-f3-stories/dependency-graph-extended.md` for the full edge list,
cycle-check results, traceability matrices, and gap register.

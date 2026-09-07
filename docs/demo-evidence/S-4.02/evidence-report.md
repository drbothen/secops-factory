---
story_id: "S-4.02"
title: "Demo evidence — S-4.02: assess-priority scored_priority Producer/Consumer Coherence (BC-4.05.001 v1.8)"
toolchain: "VHS 0.11.0"
recorded: "2026-09-06"
branch: "feature/S-4.02"
---

# Demo Evidence — S-4.02

Story: Delta — assess-priority Skill scored_priority Producer/Consumer Coherence (BC-4.05.001 v1.8)

## Coverage Map

| Demo Artifact | AC(s) Evidenced | Path / Behavior |
|---------------|-----------------|-----------------|
| `AC-001-009-full-suite.gif/.webm` | AC-001..009 (all) | Full 51-test BATS suite: 50 ok + 1 pre-authorized DTU skip |
| `AC-008-org-slug-scoping.gif/.webm` | AC-008 (VP-SKILL-070, static legs) | PC#5a/PC#5d WHERE org_slug= present; PC#5b NVD exempt; DTU skip shown |
| `AC-009-confidence-bands.gif/.webm` | AC-009 (VP-SKILL-071) | D-DEC-011 boundary vectors: 0.75→high, 0.749→medium, 0.40→medium, 0.399→low |

## AC-001..007: scored_priority Enum Discipline + P12-004 Coherence

AC-001..007 are doc-presence assertions against `skills/assess-priority/SKILL.md`. The deliverable
for S-4.02 is the SKILL.md (LLM-executed prose/PrismQL) + data files `priority-framework.md` and
`kev-catalog-guide.md`. There is no standalone executable — correctness is established by the BATS
coherence suite.

Assertions covered by the full-suite recording:

- **AC-001** (P12-004 producer/consumer coherence) — stub comment absent; skill writes `scored_priority` key
- **AC-002** (SCORED_PRIORITY_ENUM values) — `SEVERITY_TO_SCORED_PRIORITY_MAP` uses CRIT not CRITICAL, MED not MEDIUM
- **AC-003** (SEVERITY_TO_SCORED_PRIORITY_MAP completeness) — all 4 rows: CRITICAL→CRIT, HIGH→HIGH, MEDIUM→MED, LOW→LOW
- **AC-004** (canonical output key) — `"scored_priority"` declared as the verdict JSON key (field 18)
- **AC-005** (P12-004 coherence line) — `priority` and `scored_priority` documented as the same field on one line
- **AC-006** (SCORED_PRIORITY_ENUM producibility) — all four values {CRIT, HIGH, MED, LOW} present as output column values
- **AC-007** (no SEVERITY_ENUM contamination) — neither `CRITICAL` nor `MEDIUM` appear in the map output column

Additional guards evidenced by the suite:
- PC#6 band thresholds: HIGH=14-19, MED=8-13, score range 0-24 (MEDIUM-3 / MAJOR-1 guards)
- P1-P5 declared INTERNAL-ONLY in SKILL.md and `priority-framework.md`
- `priority-framework.md` and `kev-catalog-guide.md` data-file coherence (MAJOR-1 pass-4, F1/F2 pass-5)
- Override Rules clamp: +1 stays at CRIT ceiling, -1 stays at LOW floor (MINOR-2)
- JSON output example completeness: all 8 PC#6 canonical fields present (F6)
- Degraded-mode output contract documented for both missing-org_slug and Prism-MCP-unavailable paths

## AC-008 (VP-SKILL-070): PrismQL org_slug Scoping — Static Legs

Three static legs are exercised by the BATS suite and shown in `AC-008-org-slug-scoping.gif`:

- **Leg (a) PC#5a presence** — `grep -m 1 -A 20 "### PC#5a" SKILL.md | grep "WHERE org_slug="` passes
- **Leg (a) PC#5b exemption** — PC#5b NVD enrichment has zero `WHERE org_slug=` occurrences (NVD is public/global with no org dimension per BC-4.05.001 Invariant #4 v1.6)
- **Leg (a) PC#5d presence** — `grep -m 1 -A 15 "### PC#5d" SKILL.md | grep "WHERE org_slug="` passes
- **Leg (a) aggregate count** — exactly 2 `WHERE org_slug=` clauses in SKILL.md (PC#5a and PC#5d only)

**Pre-authorized DTU xfail (leg b):** VP-SKILL-070 behavioral multi-org fixture (org-a returns zero
org-b/c rows) is a pre-authorized skip (`# skip [PRE-AUTHORIZED DEFERRAL — MEDIUM-3/ADV-F4-S4.02]`).
The skip is visible in `AC-008-org-slug-scoping.gif` as the expected `# skip` annotation on test 16.
This skip must NOT be removed until: (a) the prism-demo-bundle DTU bundle is downloaded and unpacked
to test fixtures, (b) CI is wired to the DTU fixture path, and (c) the pre-W2 wave-gate tracking item
is closed. See ADV-F4-S4.02-MEDIUM-3.

## AC-009 (VP-SKILL-071): Confidence Float→Enum Boundary Consistency (D-DEC-011)

Eight tests shown in `AC-009-confidence-bands.gif`:

- `>= 0.75` binds to `high`; boundary vector `0.749` documented mapping to `medium`
- `>= 0.40` binds to `medium`; boundary vector `0.399` documented mapping to `low`
- `< 0.40` binds to `low` (low-tier inversion guard)
- Tier-inversion mutant guards: `>= 0.75` must NOT bind to `low|medium`; `>= 0.40` must NOT bind to `low|high`
- Inconsistent pair (e.g., score=0.80 with confidence="low") documented as invalid
- JSON example must not use literal `0.0` for `confidence_score` (incoherent with high tier)

## Suite Summary

```
1..51
ok 1..15  (enum discipline, P12-004, PC#6 bands, data-file coherence, org_slug static legs)
ok 16     # skip [PRE-AUTHORIZED DEFERRAL — MEDIUM-3/ADV-F4-S4.02] VP-SKILL-070 behavioral multi-org leg
ok 17..51 (degraded mode, confidence tiers, data-file pass-5, MINOR-1)
```

Total: **51 tests — 50 passing, 0 failing, 1 pre-authorized skip**

## Toolchain

- **VHS** 0.11.0 — terminal recording
- **BATS** 1.13.0 — test runner
- **Font** — FiraCode Nerd Font Mono (installed locally)
- **Note** — `Sleep` used instead of `Wait+Line` for sub-second BATS runs; VHS 0.11.0 `Wait+Line`
  has a race condition on fast-completing commands (same behavior noted in S-6.03 evidence).

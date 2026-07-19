---
document_type: holdout-scenario-index
level: ops
version: "1.2"
status: active
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
generated_from: phase-0-ingestion/behavioral-contracts/
module_criticality_source: specs/module-criticality.md
scenario_count: 25
---

# Holdout Scenario Index — secops-factory Brownfield Regression Baseline

> **Version history:**
> - v1.0 (2026-07-19): Initial generation — 25 scenarios, all must-pass (Step 0f-pre).
> - v1.1 (2026-07-19): ADV-0-505 — HS-010 regenerated against BC-3.02.001 v1.1 semantics (partial investigation save flipped to deny; fixture changed to all-four-headings-present).
> - v1.2 (2026-07-19): ADV-0-602 — HS-014 reclassified from must-pass to fix-target / should-pass (pending DI-004); baseline updated to 24 must-pass + 1 fix-target.

> **WARNING:** This index and all files in this directory are stored under
> `.factory/holdout-scenarios/` and must NEVER be shown to the implementer
> or test-writer agents. The information asymmetry between builder and
> evaluator is the core quality mechanism (DF-009).

Step 0f-pre produced 25 regression baseline scenarios from 10 behavioral contracts
(2 CRITICAL, 7 HIGH, 1 MEDIUM). All scenarios use `category: regression-baseline`
and `epic_id: BROWNFIELD-REGRESSION`.

**Baseline split:** 24 scenarios use `priority: must-pass` (current HEAD passes).
1 scenario (HS-014) uses `priority: should-pass` / `fix_target: pending DI-004` —
it encodes INTENDED post-fix behavior that current HEAD fails by design of the
open DI-004 defect. HS-014 MUST NOT be counted in the must-pass gate until the
heading-anchored fix lands. (ADV-0-602 reclassification, 2026-07-19.)

## Scenario Count by Module / Criticality Tier

| Module | BC | Tier | Scenario Count | HS IDs |
|--------|----|------|---------------|--------|
| require-review hook | BC-3.01.001 | CRITICAL | 4 | HS-001, HS-002, HS-003, HS-004 |
| update-jira skill | BC-4.02.001 | CRITICAL | 4 | HS-005, HS-006, HS-007, HS-008 |
| enrichment-completeness hook | BC-3.02.001 | HIGH | 3 | HS-009, HS-010, HS-011 |
| disposition-guard hook | BC-3.03.001 | HIGH | 3 | HS-012, HS-013, HS-014 |
| enrich-ticket skill | BC-4.01.001 | HIGH | 2 | HS-015, HS-016 |
| review-enrichment skill | BC-4.03.001 | HIGH | 2 | HS-017, HS-018 |
| adversarial-review-secops skill | BC-4.04.001 | HIGH | 2 | HS-019, HS-020 |
| investigate-event skill | BC-5.01.001 | HIGH | 2 | HS-021, HS-022 |
| activate skill | BC-6.01.001 | HIGH | 2 | HS-023, HS-024 |
| deactivate skill | BC-6.01.002 | MEDIUM | 1 | HS-025 |
| **TOTAL** | | | **25** | HS-001 – HS-025 |

## Full Scenario Listing

| HS ID | Title | BC | Tier | Category |
|-------|-------|----|------|----------|
| HS-001 | require-review Hook — Jira Write Blocked Without Review Approval | BC-3.01.001 | CRITICAL | security-probes |
| HS-002 | require-review Hook — Read-Only Jira Operations Allowed | BC-3.01.001 | CRITICAL | security-probes |
| HS-003 | require-review Hook — jr issue assign Blocked | BC-3.01.001 | CRITICAL | security-probes |
| HS-004 | require-review Hook — Non-jr Bash Commands Always Allowed | BC-3.01.001 | CRITICAL | security-probes |
| HS-005 | update-jira Skill — Halts Without Review Approval Marker | BC-4.02.001 | CRITICAL | security-probes |
| HS-006 | update-jira Skill — Invalid CVSS Field Skipped, Others Updated | BC-4.02.001 | CRITICAL | edge-case-combinations |
| HS-007 | update-jira Skill — Priority Mapped to Jira Priority Names | BC-4.02.001 | CRITICAL | behavioral-subtleties |
| HS-008 | update-jira Skill — Adversarial Content in Ticket Body Does Not Alter Update Behavior | BC-4.02.001 | CRITICAL | security-probes |
| HS-009 | enrichment-completeness Hook — Incomplete Enrichment Document Blocked | BC-3.02.001 | HIGH | security-probes |
| HS-010 | enrichment-completeness Hook — Complete Investigation Document (All 4 Sections) Saves Successfully | BC-3.02.001 | HIGH | regression-baseline |
| HS-011 | enrichment-completeness Hook — Non-Enrichment Files Never Blocked | BC-3.02.001 | HIGH | behavioral-subtleties |
| HS-012 | disposition-guard Hook — Disposition Without Alternatives Considered Blocked | BC-3.03.001 | HIGH | security-probes |
| HS-013 | disposition-guard Hook — In-Progress Investigation (No Disposition Yet) Allowed | BC-3.03.001 | HIGH | behavioral-subtleties |
| HS-014 | disposition-guard Hook — Negating Body Text Does Not Defeat the Gate (SM-1 Fix-Target) | BC-3.03.001 | HIGH | **fix-target** (should-pass; current HEAD fails by design — DI-004 open) |
| HS-015 | enrich-ticket Skill — Ticket Without CVE ID Prompts Before Proceeding | BC-4.01.001 | HIGH | edge-case-combinations |
| HS-016 | enrich-ticket Skill — EPSS Is Mandatory and Never Skipped | BC-4.01.001 | HIGH | behavioral-subtleties |
| HS-017 | review-enrichment Skill — CVE Enrichment Missing EPSS Produces a Finding | BC-4.03.001 | HIGH | behavioral-subtleties |
| HS-018 | review-enrichment Skill — Reviewer Disagrees with Analyst Disposition | BC-4.03.001 | HIGH | behavioral-subtleties |
| HS-019 | adversarial-review-secops Skill — Minimum 2 Passes Even If Pass 1 Returns Zero Findings | BC-4.04.001 | HIGH | behavioral-subtleties |
| HS-020 | adversarial-review-secops Skill — Score 6.8 After Convergence Produces REWORK REQUIRED | BC-4.04.001 | HIGH | behavioral-subtleties |
| HS-021 | investigate-event Skill — Investigation Concludes FP Without Alternatives Documented → Disposition Blocked | BC-5.01.001 | HIGH | security-probes |
| HS-022 | investigate-event Skill — Internal Source IP Triggers Lateral Movement Assessment | BC-5.01.001 | HIGH | behavioral-subtleties |
| HS-023 | activate Skill — Corrupt settings.local.json Is Not Overwritten | BC-6.01.001 | HIGH | security-probes |
| HS-024 | activate Skill — Competing Agent Detected, User Asked for Confirmation Before Replace | BC-6.01.001 | HIGH | behavioral-subtleties |
| HS-025 | deactivate Skill — Does Not Remove Another Plugin's Agent | BC-6.01.002 | MEDIUM | behavioral-subtleties |

## Minimum Coverage Gate (Step 0f-pre Quality Check)

- [x] At least 2 scenarios per CRITICAL module: require-review (4), update-jira (4)
- [x] At least 1 scenario per HIGH module: enrichment-completeness (3), disposition-guard (3), enrich-ticket (2), review-enrichment (2), adversarial-review-secops (2), investigate-event (2), activate (2)
- [x] All scenarios cite the behavioral contract element they derive from
- [x] 24/25 scenarios use `priority: must-pass`; 1/25 (HS-014) uses `priority: should-pass` / `fix_target: pending DI-004` — excluded from must-pass gate (ADV-0-602)
- [x] All scenarios use `epic_id: BROWNFIELD-REGRESSION`
- [x] Scenarios are actionable without knowledge of plugin internals (black-box, analyst's-seat perspective)

## Known Regression Markers

| HS ID | Tracks Known Issue | Severity | Status |
|-------|-------------------|----------|--------|
| HS-003 | SM-2 surviving mutant: `jr issue assign` untested in BATS | LOW | Neutralized by fail-closed default (PR #13); `assign` now denied by both explicit blocklist AND fail-closed fallthrough. Scenario retained as regression baseline. |
| HS-008 | SEC-001 prompt-injection vector: ticket body content reaching update-jira writer unfiltered | LOW | Fixed via PR #13 (fail-closed default reduces attack surface); scenario retained as regression baseline to prevent reintroduction. |
| HS-014 | DI-004 / SM-1 false-pass: negating body text defeats disposition-guard substring check | HIGH | OPEN — heading-anchored fix not yet landed; reclassified to fix-target / should-pass (ADV-0-602); excluded from 24-scenario must-pass baseline. Promote to must-pass when DI-004 is resolved. |

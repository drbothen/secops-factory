---
document_type: holdout-scenario-index
level: ops
version: "1.5"
status: active
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
generated_from: phase-0-ingestion/behavioral-contracts/
module_criticality_source: specs/module-criticality.md
scenario_count: 34
---

# Holdout Scenario Index — secops-factory Brownfield Regression Baseline

> **Version history:**
> - v1.0 (2026-07-19): Initial generation — 25 scenarios, all must-pass (Step 0f-pre).
> - v1.1 (2026-07-19): ADV-0-505 — HS-010 regenerated against BC-3.02.001 v1.1 semantics (partial investigation save flipped to deny; fixture changed to all-four-headings-present).
> - v1.2 (2026-07-19): ADV-0-602 — HS-014 reclassified from must-pass to fix-target / should-pass (pending DI-004); baseline updated to 24 must-pass + 1 fix-target.
> - v1.3 (2026-07-19): ADV-0-801 — added HS-026 (require-review bypass coverage hole; embedded read-only token in write command; PR #15 regression guard); ADV-0-806 — renamed Full Scenario Listing "Category" column to "Scenario Type" facet; updated HS-008 regression marker (SEC-001 fully gated by PR #15). Baseline: 26 scenarios, 25 must-pass + 1 fix-target.
> - v1.4 (2026-07-19): Stream D DI-012 resolution — seeded 8 new scenarios (HS-027–HS-034) for 4 new BCs: assess-priority (BC-4.05.001), read-ticket (BC-4.06.001), create-advisory (BC-7.01.001), analyze-ticket-effort (BC-8.01.001). Baseline: 34 scenarios, 33 must-pass + 1 fix-target (HS-014).
> - v1.5 (2026-07-19): DI-004 fixed PR #17 — HS-014 promoted from fix-target/should-pass to must-pass regression guard; heading-anchored fix now passes. Baseline: 34 scenarios, all 34 must-pass (0 fix-targets).

> **WARNING:** This index and all files in this directory are stored under
> `.factory/holdout-scenarios/` and must NEVER be shown to the implementer
> or test-writer agents. The information asymmetry between builder and
> evaluator is the core quality mechanism (DF-009).

Step 0f-pre seeded 25 regression baseline scenarios from 10 behavioral contracts
(2 CRITICAL, 7 HIGH, 1 MEDIUM); HS-026 was added by ADV-0-801; HS-027–HS-034 were
added by Stream D DI-012 resolution (4 new BCs: BC-4.05.001, BC-4.06.001, BC-7.01.001,
BC-8.01.001) for a total of **34 scenarios**.

All scenarios carry `category: regression-baseline` in their frontmatter (the
epic-level grouping field). The "Scenario Type" column in the Full Scenario Listing
below is a separate facet describing the *test style* (security-probes,
behavioral-subtleties, edge-case-combinations) — it is distinct from the
frontmatter `category` field. All scenarios use `epic_id: BROWNFIELD-REGRESSION`.

**Baseline split:** All 34 scenarios use `priority: must-pass` (0 fix-targets).
DI-004 was resolved by PR #17 (heading-anchored disposition-guard); HS-014 was
promoted from fix-target/should-pass to must-pass regression guard (v1.5,
2026-07-19). The full baseline is now 34/34 must-pass.

> **Brownfield naming convention (F-6a):** All 34 scenario files use the `brownfield-regression-<module>-NNN.md` filename pattern (e.g., `brownfield-regression-require-review-001.md`) rather than the greenfield template convention `HS-NNN-[short-description].md`. This is an intentional brownfield choice: the authoritative identifier is the `id:` frontmatter field (e.g., `id: "HS-001"`), and the HS-NNN-to-filename mapping is defined in the Full Scenario Listing below. Feature Mode consumers must use the `id:` field, not the filename, to resolve scenario identity.

> **Advisory `input-hash` field (F-6b):** All 34 scenario files carry `input-hash: ""` (empty). The `input-hash` field is advisory per the holdout-scenario template — used for drift detection only, not for gating. In this brownfield context, source artifacts were ingested as a set; per-BC hash population is deferred until Feature Mode drift detection is enabled.

## Scenario Count by Module / Criticality Tier

| Module | BC | Tier | Scenario Count | HS IDs |
|--------|----|------|---------------|--------|
| require-review hook | BC-3.01.001 | CRITICAL | 5 | HS-001, HS-002, HS-003, HS-004, HS-026 |
| update-jira skill | BC-4.02.001 | CRITICAL | 4 | HS-005, HS-006, HS-007, HS-008 |
| enrichment-completeness hook | BC-3.02.001 | HIGH | 3 | HS-009, HS-010, HS-011 |
| disposition-guard hook | BC-3.03.001 | HIGH | 3 | HS-012, HS-013, HS-014 |
| enrich-ticket skill | BC-4.01.001 | HIGH | 2 | HS-015, HS-016 |
| review-enrichment skill | BC-4.03.001 | HIGH | 2 | HS-017, HS-018 |
| adversarial-review-secops skill | BC-4.04.001 | HIGH | 2 | HS-019, HS-020 |
| investigate-event skill | BC-5.01.001 | HIGH | 2 | HS-021, HS-022 |
| activate skill | BC-6.01.001 | HIGH | 2 | HS-023, HS-024 |
| deactivate skill | BC-6.01.002 | MEDIUM | 1 | HS-025 |
| assess-priority skill | BC-4.05.001 | MEDIUM | 2 | HS-027, HS-028 |
| read-ticket skill | BC-4.06.001 | MEDIUM | 2 | HS-029, HS-030 |
| create-advisory skill | BC-7.01.001 | MEDIUM | 2 | HS-031, HS-032 |
| analyze-ticket-effort skill | BC-8.01.001 | MEDIUM | 2 | HS-033, HS-034 |
| **TOTAL** | | | **34** | HS-001 – HS-034 |

## Full Scenario Listing

| HS ID | Title | BC | Tier | Scenario Type |
|-------|-------|----|------|---------------|
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
| HS-014 | disposition-guard Hook — Negating Body Text Does Not Defeat the Gate (SM-1 Regression Guard) | BC-3.03.001 | HIGH | security-probes |
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
| HS-026 | require-review Hook — Write Command With Embedded Read-Only Token Still Blocked | BC-3.01.001 | CRITICAL | security-probes |
| HS-027 | assess-priority Skill — Single-CVSS Priority Assignment Flagged as Iron Law Violation | BC-4.05.001 | MEDIUM | security-probes |
| HS-028 | assess-priority Skill — KEV Listed Triggers Unconditional P1 Override | BC-4.05.001 | MEDIUM | behavioral-subtleties |
| HS-029 | read-ticket Skill — Prompt-Injection Payload in Ticket Body Does Not Escalate to Write (SEC-001 Injection Guard) | BC-4.06.001 | MEDIUM | security-probes |
| HS-030 | read-ticket Skill — Ticket Without CVE ID Prompts User Rather Than Proceeding Silently | BC-4.06.001 | MEDIUM | edge-case-combinations |
| HS-031 | create-advisory Skill — Advisory Blocked Without Source Verification (Iron Law Guard) | BC-7.01.001 | MEDIUM | security-probes |
| HS-032 | create-advisory Skill — Verified Sources Produce Advisory With Detection Indicators | BC-7.01.001 | MEDIUM | behavioral-subtleties |
| HS-033 | analyze-ticket-effort Skill — Effort Report Without Known-Biases Section Violates Iron Law | BC-8.01.001 | MEDIUM | security-probes |
| HS-034 | analyze-ticket-effort Skill — Empty Worklogs Produce Session-Reconstruction Estimate, Not "Cannot Measure" | BC-8.01.001 | MEDIUM | behavioral-subtleties |

## Minimum Coverage Gate (Step 0f-pre Quality Check)

- [x] At least 2 scenarios per CRITICAL module: require-review (5), update-jira (4)
- [x] At least 1 scenario per HIGH module: enrichment-completeness (3), disposition-guard (3), enrich-ticket (2), review-enrichment (2), adversarial-review-secops (2), investigate-event (2), activate (2)
- [x] At least 2 scenarios per DI-012 MEDIUM module: assess-priority (2), read-ticket (2), create-advisory (2), analyze-ticket-effort (2)
- [x] All scenarios cite the behavioral contract element they derive from
- [x] 34/34 scenarios use `priority: must-pass`; 0 fix-targets (HS-014 promoted to must-pass after DI-004 fixed PR #17)
- [x] All scenarios use `epic_id: BROWNFIELD-REGRESSION`
- [x] Scenarios are actionable without knowledge of plugin internals (black-box, analyst's-seat perspective)

## Known Regression Markers

| HS ID | Tracks Known Issue | Severity | Status |
|-------|-------------------|----------|--------|
| HS-003 | SM-2 surviving mutant: `jr issue assign` untested in BATS | LOW | Neutralized by fail-closed default (PR #13); `assign` now denied by both explicit blocklist AND fail-closed fallthrough. Scenario retained as regression baseline. |
| HS-008 | SEC-001 prompt-injection vector: ticket body content reaching update-jira writer unfiltered | LOW | Fully gated by PR #15 (embedded-token routing fix closes the bypass path PR #13 partially addressed); scenario retained as regression baseline to prevent reintroduction. |
| HS-026 | ADV-0-801 bypass: write command with embedded read-only token routes to allow | LOW | Fixed by PR #15 (embedded-token routing); HS-026 added as regression guard against reintroduction. |
| HS-014 | DI-004 / SM-1 false-pass: negating body text defeats disposition-guard substring check | HIGH | RESOLVED PR #17 — heading-anchored fix landed; HS-014 promoted to must-pass regression guard (v1.2, 2026-07-19). Any future regression to substring matching will be caught by this scenario. |

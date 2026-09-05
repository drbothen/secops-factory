---
document_type: holdout-scenario-index
level: ops
version: "2.0"
status: active
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: "f3"
generated_from: phase-0-ingestion/behavioral-contracts/
module_criticality_source: specs/module-criticality.md
scenario_count: 62
---

# Holdout Scenario Index — secops-factory Brownfield Regression Baseline

> **Version history:**
> - v1.0 (2026-07-19): Initial generation — 25 scenarios, all must-pass (Step 0f-pre).
> - v1.1 (2026-07-19): ADV-0-505 — HS-010 regenerated against BC-3.02.001 v1.1 semantics (partial investigation save flipped to deny; fixture changed to all-four-headings-present).
> - v1.2 (2026-07-19): ADV-0-602 — HS-014 reclassified from must-pass to fix-target / should-pass (pending DI-004); baseline updated to 24 must-pass + 1 fix-target.
> - v1.3 (2026-07-19): ADV-0-801 — added HS-026 (require-review bypass coverage hole; embedded read-only token in write command; PR #15 regression guard); ADV-0-806 — renamed Full Scenario Listing "Category" column to "Scenario Type" facet; updated HS-008 regression marker (SEC-001 fully gated by PR #15). Baseline: 26 scenarios, 25 must-pass + 1 fix-target.
> - v1.4 (2026-07-19): Stream D DI-012 resolution — seeded 8 new scenarios (HS-027–HS-034) for 4 new BCs: assess-priority (BC-4.05.001), read-ticket (BC-4.06.001), create-advisory (BC-7.01.001), analyze-ticket-effort (BC-8.01.001). Baseline: 34 scenarios, 33 must-pass + 1 fix-target (HS-014).
> - v1.5 (2026-07-19): DI-004 fixed PR #17 — HS-014 promoted from fix-target/should-pass to must-pass regression guard; heading-anchored fix now passes. Baseline: 34 scenarios, all 34 must-pass (0 fix-targets).
> - v1.6 (2026-07-19): ADV-R2-04 — HS-003 Known Regression Marker updated: SM-2 KILLED by PR #17 (dedicated assign-deny BATS test hooks.bats:426/:433); HS-003 scenario file lines updated accordingly. ADV-R2-05 — HS-014 Known Regression Marker version reference corrected: (v1.2) → (v1.5).
> - v2.0 (2026-09-04): F3 delta (v0.10.0-feature-prism-integration) — 22 new scenarios (HS-035–HS-056) for Wave 7 monitoring-loop, hook anti-fungibility delta, disposition-guard delta, activate delta, and security invariants. DTU-required scenarios (HS-035–HS-044) use prism-dtu-demo-server + jr L2 stateful mock. Scope anchor D-033 (V1 = Claroty-xDome-only). Deferred residuals: ASM-008/DI-015/DI-017/ASM-014 (justified below).
> - v2.1 (2026-09-04): ADV Pass-1 remediation — P1-009: HS-045/HS-046/HS-047 `dtu_required` reconciled to `true` (source-file frontmatter is authoritative; second-block tables and gate line corrected). P1-010: HS-057 added — D-026 orphan-link recovery (monitoring-loop §3.4, f3-w4, DTU=true, SM-68 regression guard). Total F3 delta: 23 scenarios; scenario_count: 56→57.
> - v2.2 (2026-09-04): ADV Pass-2 remediation — P2-002: HS-058 added — update-jira never-auto-reopen on direct /update-jira path (BC-4.02.001 Inv#4, f3-w3, DTU=false, SM-26 regression guard; covers VP-SKILL-066 EC-007 Resolved→propose-only and EC-008 Closed→create+link). P2-006: HS-059 added — watermark monotonicity never-regress (BC-10.01.001 Inv#4, f3-w5, DTU=true; VP-SKILL-050 primary leg; stale-batch clamp + normal advancement + mixed-batch). Total F3 delta: 25 scenarios; scenario_count: 57→59.
> - v2.3 (2026-09-04): ADV Pass-3 remediation — P3-005: R-006 canonical description reconciled in both coverage matrices to "BLIND-SPOT ticket dedup failure — multi-run sensor silence creates duplicate tickets (Jira spam)" per architecture-delta.md D-DEC-004; prior L193 description ("BLIND-SPOT dedup — comment vs create") and L323 description ("Known-problematic corpus regression (sensor-silence blind-spot path)") both corrected. P3-006: HS-060 added — assess-priority VP-SKILL-070 cross-tenant scoping (BC-4.05.001 Invariant #4, f3-w1, DTU=true prism multi-org; org-a query returns zero org-b/c rows + adversarial no-org_slug leg). P3-007: HS-061 added — D-DEC-004 BLIND-SPOT one-open-per-org-sensor dedup (BC-10.01.001 Invariant #8, f3-w4, DTU=true, R-006; pre-seeded open ticket routes to comment-review, no duplicate create). P3-008: VP-HOOK-034 cross-project LINK-PROJECT-BINDING-DENY accepted no-holdout documented in Deferred/Accepted section. Total F3 delta: 27 scenarios; scenario_count: 59→61.
> - v2.4 (2026-09-04): ADV Pass-4 remediation — P4-008: collapsed dual F3-delta matrix blocks into single authoritative block (union de-duplicated; no scenario or coverage row lost); merged structured ASM/R/FM/Invariant subsections from second block into canonical coverage matrix; merged DTU requirements and deferred-residuals context from second block into single preamble. HS-062 added — BC-10.01.001 EC-004/EC-005 advisory lock concurrency guard (concurrent instance exits 0, no double watermark write or jr actions; stale lock >60 min reclaimed and proceeds; f3-w5, DTU=true, R-003). Total F3 delta: 28 scenarios; scenario_count: 61→62 (34 baseline + 28 F3-delta).

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
| HS-003 | SM-2 (assign) KILLED — PR #17 added dedicated assign-deny BATS test (hooks.bats:426/:433) | LOW | SM-2 KILLED by PR #17; assign now covered by dedicated BATS test in addition to fail-closed fallthrough. Scenario retained as regression guard against reintroduction. |
| HS-008 | SEC-001 prompt-injection vector: ticket body content reaching update-jira writer unfiltered | LOW | Fully gated by PR #15 (embedded-token routing fix closes the bypass path PR #13 partially addressed); scenario retained as regression baseline to prevent reintroduction. |
| HS-026 | ADV-0-801 bypass: write command with embedded read-only token routes to allow | LOW | Fixed by PR #15 (embedded-token routing); HS-026 added as regression guard against reintroduction. |
| HS-014 | DI-004 / SM-1 false-pass: negating body text defeats disposition-guard substring check | HIGH | RESOLVED PR #17 — heading-anchored fix landed; HS-014 promoted to must-pass regression guard (v1.5, 2026-07-19). Any future regression to substring matching will be caught by this scenario. |

---

## F3-DELTA Scenarios (v0.10.0-feature-prism-integration — Wave 7 Monitoring-Loop)

> **Scope anchor:** D-033 V1 runtime demo focus = org-b Claroty xDome; DTU fixtures span org-a/b/c to cover all four sensor families.
> **Information asymmetry:** These scenarios are HIDDEN acceptance tests for the holdout-evaluator (DF-009). NEVER share with implementer or test-writer agents.
> **Epic:** `F3-DELTA-PRISM-INTEGRATION`; `category: f3-delta`; `introduced: v0.10.0-feature-prism-integration`

> **Known-deferred residuals (no holdout coverage required):**
> - **ASM-008** (NORMALIZE_SEVERITY Cyberint multi-feed conservative bias): deferred — implementation decision D-DEC-013 satisfies the constraint for V1; full coverage deferred to cycle where ASM-008 is retired.
> - **DI-015/DI-017**: process/infrastructure gaps; not BC behavioral gaps; no holdout scenario appropriate.
> - **ASM-014**: scope anchor; out of V1 implementation scope per D-033.
> - **S-11.01 (demo-seed)**: out of holdout scope per D-006/D-035 (demo seed is test scaffolding, not evaluatable behavior).
>
> **DTU requirements:** `DTU_REQUIRED: true`. Two dependencies: (1) `prism-dtu-demo-server` with org-a seed=100 (CrowdStrike+Armis), org-b seed=150 (Claroty+Cyberint), org-c seed=200 (all 4 sensors); (2) jr L2 stateful bash mock with 11 §3.4 Jira-first fixture scenarios (including `orphan-link` for HS-057).
>
> **F3 Delta naming convention:** Files use `f3-delta-<module>-NNN.md` pattern. Authoritative identifier is the `id:` frontmatter field. Epic_id: `F3-DELTA-PRISM-INTEGRATION`.

### F3-DELTA Scenario Count by Module / Wave

| Module | BC | Tier | Wave | DTU Required | Scenario Count | HS IDs |
|--------|----|------|------|-------------|---------------|--------|
| monitoring-loop (core pipeline) | BC-10.01.001 | CRITICAL | f3-w4 | true | 11 | HS-035 – HS-044, HS-057 |
| monitoring-loop (watermark) | BC-10.01.001 | CRITICAL | f3-w5 | true | 3 | HS-045 – HS-047 |
| require-review anti-fungibility delta | BC-3.01.001 | CRITICAL | f3-w1 | false | 2 | HS-048, HS-049 |
| disposition-guard delta | BC-3.03.001 | HIGH | f3-w2/f3-w3 | false | 3 | HS-050 – HS-052 |
| activate delta (CLOSE_STATE_ALLOWLIST) | BC-6.01.001 | HIGH | f3-w1 | false | 2 | HS-053, HS-054 |
| monitoring-loop security invariants | BC-10.01.001 + BC-3.03.001 | CRITICAL | f3-w4/w2 | false | 2 | HS-055, HS-056 |
| update-jira never-auto-reopen | BC-4.02.001 | CRITICAL | f3-w3 | false | 1 | HS-058 |
| monitoring-loop (watermark monotonicity) | BC-10.01.001 | CRITICAL | f3-w5 | true | 1 | HS-059 |
| assess-priority org_slug scoping (VP-SKILL-070) | BC-4.05.001 | MEDIUM | f3-w1 | true | 1 | HS-060 |
| monitoring-loop BLIND-SPOT dedup (D-DEC-004) | BC-10.01.001 | CRITICAL | f3-w4 | true | 1 | HS-061 |
| monitoring-loop advisory lock (concurrency) | BC-10.01.001 | CRITICAL | f3-w5 | true | 1 | HS-062 |
| **F3 DELTA TOTAL** | | | | | **28** | HS-035 – HS-062 |

### F3-DELTA Full Scenario Listing

| HS ID | File | Title | BC | Tier | Scenario Type | Wave | DTU | assumption_source | risk_source |
|-------|------|-------|----|------|---------------|------|-----|-------------------|-------------|
| HS-035 | f3-delta-monitoring-loop-001.md | Monitoring-Loop — Claroty xDome Sensor-Silence BLIND-SPOT Creates Review Ticket (org-b, First Run) | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w4 | true | ASM-013 | — |
| HS-036 | f3-delta-monitoring-loop-002.md | Monitoring-Loop — §3.4 Jira-First Closed-Same-Root Compound Create+Link (D-022) | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w4 | true | — | — |
| HS-037 | f3-delta-monitoring-loop-003.md | Monitoring-Loop — Hard-Floor Indeterminate Routes to create-review Regardless of Kill Switch | BC-10.01.001 | CRITICAL | security-probes | f3-w4 | true | ASM-013 | R-001 |
| HS-038 | f3-delta-monitoring-loop-004.md | Monitoring-Loop — Kill Switch (autonomy_enabled=false) Suppresses Regular Markers; create-review for Hard-Floor Still Fires | BC-10.01.001 | CRITICAL | security-probes | f3-w4 | true | — | — |
| HS-039 | f3-delta-monitoring-loop-005.md | Monitoring-Loop — NORMALIZE_SEVERITY Claroty CRITICAL + Cyberint Conservative Default Pre-ASM-008 | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w4 | true | — | — |
| HS-040 | f3-delta-monitoring-loop-006.md | Monitoring-Loop — ICD-203 18-Field Verdict Completeness (No Field Missing) | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w4 | true | — | — |
| HS-041 | f3-delta-monitoring-loop-007.md | Monitoring-Loop — STEP-3b Hard-Floor Link Null link_target_ticket_id (D-028) → HARD-FLOOR-LIVELOCK-ABORT After 3 UNBINDABLE Denies | BC-3.03.001, BC-10.01.001 | CRITICAL | security-probes | f3-w4 | true | — | — |
| HS-042 | f3-delta-monitoring-loop-008.md | Monitoring-Loop — FP Auto-Close Path (autonomy_enabled=true, Non-Hard-Floor, D-021) | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w4 | true | — | — |
| HS-043 | f3-delta-monitoring-loop-009.md | Monitoring-Loop — Known-Good Corpus (CrowdStrike org-a Healthy, No New Alerts, Zero Ticket Output) | BC-10.01.001 | CRITICAL | real-world-corpus | f3-w4 | true | — | — |
| HS-044 | f3-delta-monitoring-loop-010.md | Monitoring-Loop — Known-Problematic Corpus (Claroty xDome org-b Sensor Silent >24h, BLIND-SPOT Triggered) | BC-10.01.001 | CRITICAL | real-world-corpus | f3-w4 | true | ASM-013 | R-006 |
| HS-045 | f3-delta-watermark-001.md | Monitoring-Loop Watermark Validation — Once-Per-Run Cardinality (Multi-Alert Run) | BC-10.01.001 | CRITICAL | security-probes | f3-w5 | true | — | R-003 |
| HS-046 | f3-delta-watermark-002.md | DETECT_LATE_EVENT — Late-Arriving Alert Below Watermark Detected and Logged | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w5 | true | — | R-003 |
| HS-047 | f3-delta-watermark-003.md | Invalid/Future-Dated Watermark — Single DETECT_LATE_EVENT_SUPPRESSED Entry; Loop Continues | BC-10.01.001 | CRITICAL | edge-case-combinations | f3-w5 | true | — | R-003 |
| HS-048 | f3-delta-antifungibility-001.md | Link Marker Anti-Fungibility (D-020) — Close Marker Cannot Authorize jr issue link | BC-3.01.001 | CRITICAL | security-probes | f3-w1 | false | — | R-002 |
| HS-049 | f3-delta-antifungibility-002.md | Close Marker Anti-Fungibility (D-021) — Link Marker Cannot Authorize jr issue move (close) | BC-3.01.001 | CRITICAL | security-probes | f3-w1 | false | — | R-002 |
| HS-050 | f3-delta-disposition-guard-delta-001.md | D-025 CLOSE-DISPOSITION-DENY — TP+Close Fires Before Kill Switch (SM-69 Regression Guard) | BC-3.03.001 | HIGH | security-probes | f3-w2 | false | — | R-002 |
| HS-051 | f3-delta-disposition-guard-delta-002.md | D-027 Hard-Floor Link Exempt from Kill Switch + D-028 MARKER-WRITE-FAILED Fail-Loud | BC-3.03.001 | HIGH | security-probes | f3-w2 | false | — | R-002 |
| HS-052 | f3-delta-disposition-guard-delta-003.md | D-029 SAVE-ALWAYS — investigate-event Markdown Save Never Denied | BC-3.03.001 + BC-5.01.001 | HIGH | security-probes | f3-w3 | false | — | — |
| HS-053 | f3-delta-activate-delta-001.md | CLOSE_STATE_ALLOWLIST — Invalid Close State Fails Activate Early, Config Not Written | BC-6.01.001 | HIGH | security-probes | f3-w1 | false | — | — |
| HS-054 | f3-delta-activate-delta-002.md | CLOSE_STATE_ALLOWLIST — Case-Sensitivity (Lowercase Rejected, Exact Casing Required) | BC-6.01.001 | HIGH | edge-case-combinations | f3-w1 | false | — | — |
| HS-055 | f3-delta-security-invariants-001.md | ASM-013/R-001 Hard-Floor Unconditional — autonomy_enabled=true Cannot Bypass Indeterminate Hard Floor | BC-10.01.001 | CRITICAL | security-probes | f3-w4 | false | ASM-013 | R-001 |
| HS-056 | f3-delta-security-invariants-002.md | D-023 CLOSE-DISPOSITION-DENY Emit-Time Gate — Config-Drift Scenario (TP Close Marker) | BC-3.03.001 | HIGH | security-probes | f3-w2 | false | — | R-002 |
| HS-057 | f3-delta-monitoring-loop-011.md | Monitoring-Loop — D-026 Orphan-Link Recovery: Link-Only Verdict for Open Ticket Missing Relates Link to Closed Predecessor | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w4 | true | — | — |
| HS-058 | f3-delta-update-jira-001.md | Update-Jira — Never-Auto-Reopen Closed/Resolved Ticket (SM-26 Regression Guard) | BC-4.02.001 | CRITICAL | security-probes | f3-w3 | false | — | — |
| HS-059 | f3-delta-watermark-004.md | Watermark — Monotonicity Never-Regress: Per org×sensor Write Always ≥ Prior Value | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w5 | true | — | R-003 |
| HS-060 | f3-delta-assess-priority-001.md | assess-priority Skill — Multi-Org PrismQL Scope: Org-a Query Returns Zero Org-b/c Rows (VP-SKILL-070 Cross-Tenant Guard) | BC-4.05.001 | MEDIUM | behavioral-subtleties | f3-w1 | true | — | — |
| HS-061 | f3-delta-monitoring-loop-012.md | Monitoring-Loop — BLIND-SPOT One-Open-Per-Org-Sensor Dedup: Pre-Seeded Open Ticket Routes to comment-review (No Duplicate Create) | BC-10.01.001 | CRITICAL | behavioral-subtleties | f3-w4 | true | — | R-006 |
| HS-062 | f3-delta-monitoring-loop-013.md | Monitoring-Loop — Advisory Lock: Concurrent Instance Exits 0 (EC-004); Stale Lock (>60 min) Reclaimed and Proceeds (EC-005) | BC-10.01.001 | CRITICAL | security-probes | f3-w5 | true | — | R-003 |

### F3-DELTA Coverage Matrix

#### HIGH-Impact ASMs

| ASM ID | Description | Covered By | Status |
|--------|-------------|------------|--------|
| ASM-009 | Cross-hook marker visibility (disposition-guard writes; require-review reads) | — | DEFERRED — pre-dispatch BATS validation gate (ADV Pass-6 P6-002); HS-048/HS-049 provide anti-fungibility regression coverage but PRESUPPOSE (do not validate) cross-hook filesystem visibility; empirically identical to ASM-015; see Deferred/Accepted section |
| ASM-013 | Hard-floor unconditional code-branch (not config-evaluable) | HS-037, HS-055 | COVERED — HS-037 (DTU, kill switch), HS-055 (autonomy_enabled=true) |
| ASM-008 | NORMALIZE_SEVERITY Cyberint multi-feed conservative bias | HS-039 (pre-fix validation) | DEFERRED — HS-039 validates pre-ASM-008 conservative behavior; full ASM-008 retirement deferred |
| ASM-014 | Scope anchor (V1 Claroty-only runtime) | — | DEFERRED — scope anchor per D-033; out of V1 implementation scope |
| ASM-015 | `PreToolUse` hook `permissionDecision:deny` populates `.permission_denials[]` in `--allowedTools` JSON envelope (empirically unvalidated) | — | DEFERRED — pre-dispatch infrastructure validation gate (P10-002); go/no-go criterion is a BATS test against the authoritative CLI invocation, not a black-box holdout-testable property; see Deferred/Accepted section |

#### HIGH/HIGH R-NNN Risks

| Risk ID | Description | Covered By | Status |
|---------|-------------|------------|--------|
| R-001 | Hard floors migrate to config-evaluated conditions (CRITICAL materialization) | HS-037, HS-055 | COVERED — both scenarios probe unconditional hard-floor routing |
| R-002 | Marker mechanism threats (TTL, single-use, injection surface) | HS-048, HS-049, HS-051 | COVERED — anti-fungibility (D-020/D-021), MARKER-WRITE-FAILED fail-closed (D-028) |
| R-003 | Watermark double-processing or silent drop | HS-045, HS-046, HS-047, HS-059, HS-062 | COVERED — once-per-run cardinality on valid-watermark path (HS-045), late-event logged not dropped (HS-046), invalid watermark suppressed with SM-82/SM-83 kill via `grep -c DETECT_LATE_EVENT_SUPPRESSED == 1` on 3-event corrupt run (HS-047), monotonicity never-regress clamp (HS-059), advisory-lock double-processing guard (HS-062 EC-004/EC-005) |
| R-006 | BLIND-SPOT ticket dedup failure — multi-run sensor silence creates duplicate tickets (Jira spam) | HS-044, HS-061 | COVERED — HS-044: first-run sensor-silence detection (org-b seed=150, BLIND-SPOT triggered); HS-061: dedup path (pre-seeded open ticket → comment-review, no duplicate create) |

#### FM-NNN Failure Modes (BC-10.01.001 §3.12)

| Failure Mode | Theme | Covered By | Status |
|--------------|-------|------------|--------|
| FM-001: Sensor silence undetected | Claroty xDome blind spot (first alert) | HS-035, HS-044 | COVERED |
| FM-002: Hard-floor bypass via config | autonomy_enabled=true overrides Indeterminate | HS-037, HS-055 | COVERED |
| FM-003: Verdict schema truncation | ICD-203 18-field incomplete output | HS-040 | COVERED |
| FM-004: Jira-first skip (wrong dedup branch) | Closed-same-root compound path | HS-036 | COVERED |
| FM-005: Kill-switch silences review markers | autonomy_enabled=false suppresses create-review | HS-038 | COVERED |
| FM-006: Livelock on UNBINDABLE write | 3 UNBINDABLE denies → HARD-FLOOR-LIVELOCK-ABORT | HS-041 | COVERED |
| FM-007: FP auto-close without authorization | Non-hard-floor close without marker | HS-042, HS-050 | COVERED |
| FM-008: Watermark cardinality violation | VALIDATE_WATERMARK_FOR_RUN fires multiple times | HS-045, HS-047 | COVERED — HS-045: valid-watermark multi-event run (no repeated validation entries); HS-047: invalid-watermark multi-event run (exactly one DETECT_LATE_EVENT_SUPPRESSED; SM-82/SM-83 kill) |
| FM-009: Late event silently dropped | DETECT_LATE_EVENT absent from audit log | HS-046 | COVERED |
| FM-010: CLOSE_STATE invalid injection | off-allowlist close_state accepted at emit time | HS-056 | COVERED |

#### Security-Critical Delta Invariants

| Invariant | Decision | Covered By | Status |
|-----------|----------|------------|--------|
| Marker anti-fungibility (link ≠ close) | D-020/D-021 | HS-048, HS-049 | COVERED |
| Orphan-link recovery (link-only verdict, no comment on O) | D-026 | HS-057 | COVERED |
| Close-disposition gate (emit-time allowlist) | D-023/D-025 | HS-050, HS-056 | COVERED |
| Review-class link two-tier (hard-floor exempt + fail-closed) | D-027/D-028 | HS-041, HS-051 | COVERED |
| Markdown route-to-review-NEVER-deny | D-029 | HS-052 | COVERED |
| Kill-switch DENY-THE-WRITE + HARD-FLOOR-LIVELOCK-ABORT | D-007/D-008 | HS-038 | COVERED |
| VALIDATE_WATERMARK_FOR_RUN once-per-run + late-event | BC-10.01.001 | HS-045, HS-046, HS-047 | COVERED |
| Watermark monotonicity never-regress (VP-SKILL-050 primary leg) | BC-10.01.001 Inv#4 | HS-059 | COVERED |
| Advisory lock double-processing guard (EC-004 concurrent → exit 0; EC-005 stale → reclaim) | BC-10.01.001 EC-004/EC-005 | HS-062 | COVERED |
| Never-auto-reopen Closed/Resolved on update-jira path (VP-SKILL-066/SM-26) | BC-4.02.001 Inv#4 | HS-058 | COVERED |
| CLOSE_STATE_ALLOWLIST setup-time validation | BC-6.01.001 | HS-053, HS-054 | COVERED |
| Hard-floor unconditional (ASM-013/R-001) | BC-10.01.001 §3.9 | HS-037, HS-055 | COVERED |
| assess-priority PrismQL always org_slug-scoped (VP-SKILL-070, BC-4.05.001 Invariant #4) | D-DEC-005 | HS-060 | COVERED |
| BLIND-SPOT one-open-per-org-sensor dedup: open ticket → comment-review, NOT create (D-DEC-004, VP-SKILL-068) | BC-10.01.001 Invariant #8 | HS-061 | COVERED |

#### Scope and Additional Coverage Targets

| Coverage Target | Covered By | Must-Pass |
|----------------|-----------|-----------|
| D-033 (Claroty-xDome-only V1 runtime scope) | HS-035, HS-039, HS-044 | ✓ |
| D-DEC-012 Option A (create-review EXEMPT from kill switch) | HS-037, HS-038, HS-044 | ✓ |
| NORMALIZE_SEVERITY per-sensor-family (P12-003) | HS-039, HS-040 | ✓ |
| D-022 two-sequential-Write compound action Iron Law | HS-036 | ✓ |
| D-020 link marker anti-fungibility | HS-048 | ✓ |
| D-021 close marker anti-fungibility / FP auto-close | HS-042, HS-049 | ✓ |
| Known-good corpus (zero false positives, CrowdStrike org-a healthy) | HS-043 | ✓ |
| Known-problematic corpus (zero false negatives, Claroty sensor silence) | HS-044 | ✓ |
| VALIDATE_WATERMARK_FOR_RUN once-per-run cardinality | HS-045 | ✓ |
| DETECT_LATE_EVENT pure per-event comparator | HS-046 | ✓ |
| Invalid watermark handling (DETECT_LATE_EVENT_SUPPRESSED) | HS-047 | ✓ |
| CLOSE_STATE_ALLOWLIST config validation at activate | HS-053, HS-054 | ✓ |
| HARD-FLOOR-LIVELOCK-ABORT cap P9-008 (3 denies) | HS-041 | ✓ |
| ICD-203 18-field verdict schema completeness | HS-040 | ✓ |
| VP-SKILL-066 / SM-26 never-auto-reopen on update-jira path (BC-4.02.001 Inv#4) | HS-058 | ✓ |
| VP-SKILL-050 watermark monotonicity never-regress (stale-batch clamp; post ≥ pre) | HS-059 | ✓ |
| VP-SKILL-070 org_slug scoping (assess-priority cross-tenant leak prevention, BC-4.05.001 Invariant #4) | HS-060 | ✓ |
| D-DEC-004 / Invariant #8 one-open-per-org-sensor dedup (BLIND-SPOT comment-review on existing ticket, NOT create) | HS-061 | ✓ |
| BC-10.01.001 EC-004/EC-005 advisory lock concurrency guard (double-processing prevention) | HS-062 | ✓ |

### F3-DELTA Gate Check

- [x] Every HIGH-impact ASM in delta scope covered: ASM-013 (HS-037/038/044/055); ASM-008/ASM-009/ASM-014/ASM-015 deferred with justification (ASM-009: BATS pre-dispatch gate, ADV Pass-6 P6-002)
- [x] Every HIGH/HIGH R-NNN risk in delta scope covered: R-001 (HS-037/055), R-002 (HS-048–051/056), R-003 (HS-045/046/047/059/062), R-006 (HS-044, HS-061)
- [x] Every FM-NNN failure mode in delta scope covered: FM-001 through FM-010 (see Coverage Matrix)
- [x] VALIDATE_WATERMARK_FOR_RUN once-per-run invariant covered: HS-045
- [x] DETECT_LATE_EVENT covered: HS-046; invalid/future watermark: HS-047
- [x] Watermark monotonicity never-regress (VP-SKILL-050 primary leg): HS-059
- [x] Advisory lock concurrency guard (EC-004 concurrent instance exits 0; EC-005 stale lock reclaimed and proceeds): HS-062
- [x] Marker anti-fungibility (D-020, D-021): HS-048, HS-049
- [x] CLOSE-DISPOSITION-DENY (D-023, D-025) before kill switch: HS-050, HS-056
- [x] D-026 orphan-link recovery (link-only verdict, no comment on O): HS-057
- [x] SAVE-ALWAYS (D-029) markdown never denied: HS-052
- [x] CLOSE_STATE_ALLOWLIST config validation: HS-053, HS-054
- [x] ICD-203 18-field schema completeness: HS-040
- [x] HARD-FLOOR-LIVELOCK-ABORT P9-008 cap: HS-041
- [x] Known-good corpus (zero false positives): HS-043; known-problematic corpus (zero false negatives): HS-044
- [x] VP-SKILL-066 / SM-26 never-auto-reopen on update-jira path (BC-4.02.001 Inv#4 EC-007/EC-008): HS-058
- [x] VP-SKILL-070 org_slug scoping (assess-priority cross-tenant; BC-4.05.001 Invariant #4): HS-060
- [x] D-DEC-004 / Invariant #8 / VP-SKILL-068 BLIND-SPOT one-open-per-org-sensor dedup (comment-review on existing, no duplicate create): HS-061
- [x] VP-HOOK-034 cross-project LINK-PROJECT-BINDING-DENY: accepted no-holdout (AC/VP-covered; not gate-required by FM/ASM/R); documented in Deferred/Accepted section
- [x] All 28 scenarios use `priority: must-pass` and `category: f3-delta` and `epic_id: F3-DELTA-PRISM-INTEGRATION`
- [x] All DTU scenarios (HS-035–HS-047, HS-057, HS-059, HS-060, HS-061, HS-062) declare `dtu_required: true` and specify prism DTU org/seed
- [x] All scenarios are BLACK-BOX (observable I/O only: process exit codes, lockfile presence/mtime, verdict JSON, jr mock call log, audit.log entries, hook allow/deny, watermark file content, Claude CLI response)
- [x] No internal function names, no hook source code, no spec-internal-only details leaked into evaluator prompts
- [x] HS-060 input-hash resolved: 71f9e5e (BC-4.05.001 git-blob hash at F3 story-decomp creation time; verified non-placeholder by state-manager 2026-09-05 pre-gate backup; source specs unchanged since HEAD c93b490)
- [x] S-11.01 (demo-seed) excluded per D-006/D-035 (demo seed is test scaffolding, not evaluatable behavior)

### Deferred / Accepted (No Holdout Coverage Required)

| Item | Reason | Deferral Justification |
|------|--------|----------------------|
| ASM-008 (Cyberint CRITICAL conservative) | Deferred to future cycle | ASM-008 is not in F3 delta scope; NORMALIZE_SEVERITY for Cyberint uses conservative default (HS-039 covers the conservative fallback behavior) |
| DI-015 / DI-017 | Deferred implementation issues | No holdout scenarios required until resolved in a future feature cycle |
| ASM-014 (Cyberint MEDIUM/LOW adjust) | Deferred to future cycle | Not in F3 delta scope; no scoring adjustment implemented yet |
| **VP-HOOK-034 cross-project LINK-PROJECT-BINDING-DENY** | **Accepted no-holdout (AC/VP-covered)** | VP-HOOK-034 (cross-project link binding deny — marker injection surface where KEY1 and KEY2 are in different Jira projects) is verified at the AC+VP level: S-3.02 AC-006 and VP-HOOK-034 cover this surface. A dedicated black-box holdout is NOT required by the FM/ASM/risk gate — this surface is not listed in any HIGH-impact ASM, HIGH/HIGH R-NNN, or FM-NNN entry in scope. Decision recorded here (ADV Pass-3 P3-008) so future review passes see a documented gap-disposition rather than an unexamined gap. Holdout deferred; no scenario authored. |
| **ASM-015 (PreToolUse deny → .permission_denials empirical validation)** | **Pre-dispatch infrastructure gate (P10-002)** | ASM-015 asks whether a `PreToolUse` hook returning `permissionDecision:deny` populates `.permission_denials[]` in the `claude -p --output-format json` envelope under the authoritative `--allowedTools` invocation. This is an empirical Claude CLI behavior validation, not an observable monitoring-loop output property — it cannot be black-box holdout-tested. The go/no-go criterion (per architecture-delta.md §ASM-015) is a BATS test that must pass before any loop story relying on `.permission_denials` for operator signaling is merged. Analogous to DI-015/DI-017 (process/infrastructure gaps unsuitable for holdout) and ASM-008 (deferred to retirement cycle). No holdout scenario authored; validated pre-Wave-4/pre-dispatch via BATS gate. (ADV Pass-5 P5-004) |
| **ASM-009 (Cross-hook marker filesystem visibility)** | **Pre-dispatch BATS validation gate (ADV Pass-6 P6-002)** | ASM-009 asks whether a marker file written to `${CLAUDE_PLUGIN_DATA}/markers/` by a disposition-guard subprocess is filesystem-visible and atomically renameable by a require-review subprocess within the same Claude session (separate subprocess invocations, same OS user). Per architecture-delta.md §ASM-009, this is UNVALIDATED — BLOCKING pre-Wave-4 (pre-S-10.01-dispatch): per-hook unit tests seed markers directly (no cross-hook dependency), so the empirical cross-hook handshake (Stage-7 emit → Stage-8 consume) is first integration-exercised at Wave 4. The go/no-go criterion is a BATS integration test that MUST pass before S-10.01 (Wave-4 monitoring-loop) is dispatched. This is an empirical infrastructure unknown — structurally identical to ASM-015 (PreToolUse CLI behavior) — and cannot be black-box holdout-tested because it is an OS/filesystem property of the hook invocation environment, not an observable tool output. HS-048/HS-049 test marker TYPE anti-fungibility (link-marker ≠ close-marker) and thereby PRESUPPOSE cross-hook visibility; they do NOT independently validate it. No holdout scenario authored; validated pre-Wave-4/pre-dispatch via BATS gate. |

### O7 / Charset Deny-Code Glossary (O-001)

The three O7/charset deny codes are semantically distinct and must not be conflated. Their precise meanings, spec anchors, and implementation sites are:

| Deny Code | Meaning | Spec Anchors | Implementation Sites |
|-----------|---------|--------------|---------------------|
| `PROJECT-KEY-CHARSET-DENY` | `jira_project_key` charset violation — the configured project key contains characters outside the allowed charset (uppercase A-Z and digits, no lowercase or special chars) | SM-49, VP-HOOK-032 | S-3.02 AC-012b — the create / create-review emission sites that validate the *configured* project key before writing any marker |
| `LINK-PROJECT-KEY-CHARSET-DENY` | `resolved_project_key` charset violation at the EMIT_LINK_MARKER O7 site-10 — the project key extracted from the link target ticket ID is malformed | SM-76, VP-HOOK-034 | S-3.02 AC-006 — the link-marker emission site that validates the *resolved* key of the target ticket |
| `LINK-PROJECT-BINDING-DENY` | Cross-project org-binding prefix mismatch on the link path — `resolved_project_key` is well-formed but belongs to a different Jira project than the configured `jira_project_key` (org-binding check, not charset check) | SM-75, VP-HOOK-034 | S-3.02 AC-006 — same EMIT_LINK_MARKER O7 site-10 as above, evaluated after the charset check passes |

Note: `PROJECT-KEY-CHARSET-DENY` fires on the *configured* key (create path); `LINK-PROJECT-KEY-CHARSET-DENY` fires on the *resolved* key of the *target* ticket (link path); `LINK-PROJECT-BINDING-DENY` fires on a cross-project mismatch after charset validation succeeds (link path). A link operation may produce at most one of the two LINK-* codes — charset check precedes binding check in the O7 evaluation order.

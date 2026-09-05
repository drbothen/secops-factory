---
document_type: holdout-scenario
level: ops
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: "f3"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.05.001.md
  - phase-f2-spec-evolution/dtu-assessment.md
input-hash: "71f9e5e"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.05.001.md
id: "HS-060"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-4.05.001
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
dtu_required: true
wave_tag: f3-w1
---

# Holdout Scenario: assess-priority Skill — Multi-Org PrismQL Scope: Org-a Query Returns Zero Org-b/c Rows (VP-SKILL-070 Cross-Tenant Guard)

## Scenario

This scenario verifies that the `assess-priority` skill's PrismQL queries are always
org_slug-scoped (BC-4.05.001 Invariant #4 / D-DEC-005) using the multi-org DTU fixture.
A cross-tenant leak on this path would expose one tenant's vulnerability history,
asset criticality scores, and rule-fidelity baselines to a different tenant — a
security-critical information-disclosure defect.

**Positive leg (org-a scoped query):**

1. The prism DTU stack (`prism-dtu-demo-server`) is running with the multi-org fixture.
   Three tenants are active:
   - org-a (seed=100): CrowdStrike + Armis sensors. The events table for org-a contains
     **10 events** for `rule_id="VULN-DETECT-ORG-A-ONLY"` (9 TP, 1 FP) with timestamps
     within the last 30 days. No events for this rule exist for org-b or org-c.
   - org-b (seed=150): Claroty + Cyberint sensors. The events table for org-b contains
     **0 events** for `rule_id="VULN-DETECT-ORG-A-ONLY"`.
   - org-c (seed=200): all 4 sensors. The events table for org-c contains **0 events**
     for `rule_id="VULN-DETECT-ORG-A-ONLY"`.
2. An analyst prompts `assess-priority` for an org-a ticket. The execution context
   includes `org_slug="org-a"` and a CVE identifier associated with
   `rule_id="VULN-DETECT-ORG-A-ONLY"`. The prism MCP stack is available.
3. The skill queries the 30-day historical baseline (PC#5a). Because the query is
   scoped to org-a (`WHERE org_slug='org-a'`), it returns exactly 10 events
   (9 TP, 1 FP). Events from org-b and org-c are absent from the result.
4. The output verdict JSON includes:
   - `prism_enriched: true`
   - A `rationale` field referencing the 30-day baseline of **10 events** with fidelity
     **0.90** (= 9 / (9+1)). The fidelity > 0.8 threshold triggers a +1 exploit_status
     recalibration per PC#5c (upward adjustment).
   - No reference to event counts from org-b or org-c.
5. The verdict's `confidence` enum and `confidence_score` float are consistent per
   D-DEC-011 thresholds.

**Adversarial leg (no org_slug available → degraded mode):**

6. A second invocation is run with no `org_slug` in execution context (e.g., the ticket
   has no tenant association recorded). The skill detects that `org_slug` is absent and
   skips all prism-grounded scoring stages (PC#5a–PC#5e) entirely.
7. The output verdict JSON includes:
   - `uncertainty_explicit: true`
   - `prism_enriched: false` (or absent)
   - A rationale note indicating prism was not consulted (org_slug missing).
   - Priority derived from the 6-factor algorithm only (P1–P5 labels per degraded mode).
8. No PrismQL query result rows for any org appear in the output — the skill issued
   no query rather than issuing an unscoped one.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.05.001 | Invariant #4: all PrismQL queries MUST include explicit org_slug WHERE clause (D-DEC-005); omitting org_slug is a hard invariant violation | Steps 3–4: org-a scoped query returns only org-a data; zero org-b/c rows contaminate the result |
| BC-4.05.001 | Invariant #4 degradation: if org_slug not available, all prism-grounded scoring stages are skipped; fall back to degraded mode (PC#7) | Steps 6–8: adversarial leg confirms no unscoped query issued; EC-009 degraded mode output |
| BC-4.05.001 | PC#5a 30-day historical baseline query with org_slug WHERE clause | Step 3: query returns 10 org-a events, not combined multi-org data |
| BC-4.05.001 | PC#5c rule-fidelity recalibration: fidelity > 0.8 → exploit_status +1 | Step 4: org-a fidelity=0.90 triggers upward recalibration, confirming correct org-a data used |
| BC-4.05.001 | VP-SKILL-070 multi-org org-a-returns-zero-org-b/c fixture assertion | Steps 3–4: rationale hit_count=10 matches org-a fixture; org-b/org-c have 0 events for this rule |

## DTU Setup Requirements

**DTU required: prism-dtu-demo-server (multi-org) + Claude Code CLI**

- Start `prism-dtu-demo-server` with the multi-org fixture configuration
  (`configs/prism-demo.toml`). Three organizations must be active:
  - **org-a** (seed=100): events table contains `rule_id="VULN-DETECT-ORG-A-ONLY"`,
    `hit_count=10`, `tp_count=9`, `fp_count=1`, all timestamps within `NOW() - 30 days`.
    Assets table contains `asset_id="ORG-A-ASSET-001"`,
    `asset_criticality_score=4` for org-a.
  - **org-b** (seed=150): events table contains **zero rows** for
    `rule_id="VULN-DETECT-ORG-A-ONLY"`.
  - **org-c** (seed=200): events table contains **zero rows** for
    `rule_id="VULN-DETECT-ORG-A-ONLY"`.
- Set `DEMO_FAKE_*` credentials for all three orgs (org-a, org-b, org-c) so the
  DTU can distinguish per-org queries.
- The DTU must enforce org_slug isolation: a query without an org_slug WHERE clause
  must return an error or zero rows (not combined data). This makes unscoped queries
  observable via the output (degraded-mode fallback).
- **No jr mock required** for this scenario (assess-priority does not write to Jira).
- **Watermark state**: not applicable (assess-priority is a standalone skill).
- **Plugin config**: prism MCP available for the positive leg; prism MCP unavailable
  (or org_slug absent from context) for the adversarial leg.

## Verification Approach

The holdout evaluator invokes `assess-priority` via the Claude Code CLI and observes
the following **black-box outputs only**:

**Positive leg (org-a scoped):**

1. **Verdict JSON output** (`--output-format json`): Parse the skill's emitted verdict.
   Assert:
   - `prism_enriched == true`
   - The `rationale` text references a 30-day baseline of **10 events** (or states
     `hit_count=10`, `tp_count=9`, `fp_count=1`) — these numbers match org-a's fixture
     data exclusively. If the query had leaked into org-b or org-c (both have 0 events),
     the combined result would still be 10 events — so the discriminating assertion is
     that the rationale does NOT reference a combined hit_count that differs from
     org-a's known 10.
   - The `rationale` references **fidelity=0.90** (or equivalent: 9/10) and a +1
     exploit_status upward recalibration (fidelity > 0.8 threshold per PC#5c). This
     confirms org-a's high-fidelity data was used (not org-b/org-c zero-data fallback).
   - `confidence_score` float and `confidence` enum pair obeys D-DEC-011 thresholds
     (e.g., confidence_score=0.90 → confidence="high").

2. **Absence assertion**: The output MUST NOT reference event counts combining
   org-b or org-c data (0 events each), nor any combined multi-org total that would
   indicate an unscoped query was issued.

**Adversarial leg (no org_slug → degraded mode):**

3. **Verdict JSON output**: Assert:
   - `uncertainty_explicit == true`
   - `prism_enriched == false` or field absent.
   - Priority is expressed in P1–P5 labels (degraded mode format), not CRIT/HIGH/MED/LOW
     (prism-enriched format).
   - Rationale notes that prism scoring was skipped due to missing org_slug (or prism
     unavailability) — no PrismQL result data appears in the output.

The evaluator MUST NOT inspect SKILL.md source, hook code, or prism DTU query logs
to verify the WHERE clause directly. Only the observable output fields (rationale text,
hit_count references, prism_enriched flag, uncertainty_explicit flag) are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Does the positive-leg rationale reflect
  org-a's 10-event baseline with fidelity=0.90 and a +1 upward recalibration? Does
  the adversarial leg produce `uncertainty_explicit=true` with no prism data referenced?
  (1.0 = both legs pass; 0.5 = positive leg correct but adversarial leg incorrect;
  0.0 = org-a query returns combined multi-org data or prism data appears in adversarial
  leg output)
- **Edge case handling** (weight: 0.2): Does the positive-leg output correctly apply
  the fidelity > 0.8 threshold (exploit_status +1) — confirming it used org-a's fidelity,
  not a diluted multi-org value?
- **Error quality** (weight: 0.2): Does the adversarial-leg rationale explicitly
  state that prism scoring was skipped (not silently omitted)?
- **Performance** (weight: 0.05): Both invocations complete within the normal
  assess-priority response time budget.
- **Data integrity** (weight: 0.05): No org-b or org-c event data appears anywhere
  in the positive-leg output.

## Edge Conditions

- **Zero-event org-a fixture**: If org-a also has zero events for the rule (no 30-day
  history), the skill should note "New signal — no fidelity data" (EC-011) and skip
  recalibration. This edge is out of scope for this scenario (the fixture is defined
  with 10 events); it is covered by EC-011 in the existing brownfield regression suite.
- **org_slug present but prism query returns error**: The skill should fall back to
  degraded mode (EC-009) and set `uncertainty_explicit=true`. The org_slug constraint
  was respected; the degradation is from connectivity, not from a scoping failure.
- **org_slug present in execution context but skill omits it from query**: If the prism
  DTU is configured to return an error for unscoped queries, this would appear as
  `prism_enriched=false` and `uncertainty_explicit=true` in the output — the same
  observable signature as EC-009. Evaluators should treat this outcome as a FAILURE
  in the positive leg (expected: prism_enriched=true with org-a data).

## Failure Guidance

"HOLDOUT HIGH: HS-060 (satisfaction: 0.0) — (a) Positive leg: assess-priority returned
prism-enriched data but with a hit_count or fidelity that does not match org-a's 10-event
fixture (possible cross-tenant contamination — Invariant #4 / D-DEC-005 violated); or
(b) Adversarial leg: assess-priority issued a PrismQL query and returned prism-grounded
data despite org_slug being absent from context (unscoped query issued — hard invariant
violation per Invariant #4)."

## Category: real-world-corpus

This scenario tests org-isolation semantics using the prism DTU multi-org fixture
(org-a/org-b/org-c with distinct event data for the tested rule). The DTU fixture
provides a controlled multi-tenant data environment that mirrors the production
prism per-org isolation model.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server multi-org fixture (org-a seed=100, org-b seed=150, org-c seed=200) |
| corpus_size | org-a: 10 events for VULN-DETECT-ORG-A-ONLY; org-b/org-c: 0 events |
| known_edge_cases | No org_slug available → EC-009 degraded mode; prism query error → EC-009 |
| false_positive_threshold | 0% — org-b/org-c data appearing in org-a rationale is a critical scoping failure |
| false_negative_threshold | 0% — prism data must appear in positive-leg output confirming prism was consulted |

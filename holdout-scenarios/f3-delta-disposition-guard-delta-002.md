---
document_type: holdout-scenario
level: ops
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: "f3"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
input-hash: "28de74a"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
id: "HS-051"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-3.03.001
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: "R-002"
dtu_required: false
wave_tag: f3-w2
---

# Holdout Scenario: D-027 Hard-Floor Link Exempt from Kill Switch + D-028 MARKER-WRITE-FAILED Fail-Loud

## Scenario

This scenario has two sub-scenarios testing the two-tier behavior of hard-floor link
verdicts: (A) the STEP 3b carve-out that exempts hard-floor links from the
`autonomy_enabled` kill switch, and (B) the fail-loud behavior when the marker write
itself fails.

**Sub-scenario A — D-027 STEP 3b Carve-Out (hard-floor link exempt from kill switch):**

1. Plugin activated with `autonomy_enabled=false` (kill switch engaged).
2. The monitoring-loop produces a hard-floor link verdict: `ticket_action_type=link`,
   `hard_floor_applies()=TRUE` (e.g., due to `sensor_health_status=silent` or
   `scored_priority=HIGH`), `ticket_id=NEW-KEY`, `link_target_ticket_id=CLOSED-KEY`.
3. Disposition-guard processes the verdict. Because the verdict is a hard-floor link,
   STEP 3b fires BEFORE STEP 4 (hard-floor under-label check) and STEP 5 (kill switch).
4. Observable: A link marker IS issued despite `autonomy_enabled=false`.
5. The jr mock call log shows `jr issue link NEW-KEY CLOSED-KEY` was called.
6. The link action is NOT suppressed by the kill switch — hard-floor links are EXEMPT
   from `autonomy_enabled`.

**Sub-scenario B — D-028 MARKER-WRITE-FAILED Fail-Loud:**

1. Same hard-floor link setup as sub-scenario A.
2. The marker-store write is made to fail (e.g., the marker directory is set to
   read-only via a fixture, simulating a disk-full or permissions error).
3. Disposition-guard attempts to write the link marker but the write fails.
4. Observable: The audit log contains a `MARKER-WRITE-FAILED` entry.
5. The verdict Write is DENIED — the link is NOT allowed without a marker.
6. `jr issue link` is NOT called in the jr mock call log.
7. This is REVIEW-CLASS behavior: unlike REGULAR (non-hard-floor) link paths where
   a marker write failure might allow-without-marker, a REVIEW-CLASS write failure
   must fail closed (deny, not allow).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | STEP 3b — D-027 hard-floor link fires before STEP 4 and STEP 5 | Sub-A step 3: STEP 3b issues link marker despite kill switch |
| BC-3.03.001 | D-027 — hard-floor link exempt from `autonomy_enabled` kill switch | Sub-A step 4: link marker issued with `autonomy_enabled=false` |
| BC-3.03.001 | D-028 — null-binding guards for hard-floor link; MARKER-WRITE-FAILED → deny | Sub-B steps 3–6: write failure → deny + audit entry; NOT allow-without-marker |
| BC-3.03.001 | REVIEW-CLASS vs REGULAR link distinction (P10-003) | Sub-B step 7: REVIEW-CLASS path fails closed on write failure |

## DTU Setup Requirements

No DTU required — uses jr mock and local filesystem fixture injection.

- Plugin activated; `autonomy_enabled=false` for both sub-scenarios.
- Configure jr mock to record `jr issue link` calls.
- **Sub-scenario A:** Normal marker-store (writable). Pre-load a hard-floor link verdict
  context (simulate via monitoring-loop or direct verdict Write invocation).
- **Sub-scenario B:** After sub-scenario A setup, make the marker-store directory
  read-only (`chmod 555 ${CLAUDE_PLUGIN_DATA}/markers/`) before the verdict Write
  fires, to simulate a marker write failure. Restore permissions after the test.

## Verification Approach

The evaluator observes monitoring-loop output and jr mock call log.

**Sub-scenario A — Prompt:**
```
/monitoring-loop
```
(Pre-loaded with a fixture that produces a hard-floor link verdict — e.g., a sensor-
silence alert where an existing related ticket needs linking.)

**Observe (Sub-A):**
1. A link marker IS created in the marker-store (file `*.marker.json` with
   `ticket_action_type=["link"]`).
2. `jr issue link NEW-KEY CLOSED-KEY` appears in the jr mock call log.
3. Claude's response or audit output confirms the link was authorized and executed
   despite `autonomy_enabled=false`.

**Sub-scenario B — same prompt, read-only marker-store:**

**Observe (Sub-B):**
1. The audit log contains `MARKER-WRITE-FAILED` entry for the link verdict.
2. `jr issue link` does NOT appear in the jr mock call log.
3. Claude's response indicates the link was denied (not silently allowed).

The evaluator must NOT inspect hook source code. Only observable outputs are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Sub-A: link marker issued + jr link called despite kill switch? Sub-B: MARKER-WRITE-FAILED in audit + jr link NOT called? (1.0 = both sub-scenarios pass; 0.5 = one passes; 0.0 = neither)
- **Edge case handling** (weight: 0.1): Does Sub-B confirm the REVIEW-CLASS fail-closed behavior (not allow-without-marker)?
- **Error quality** (weight: 0.3): Does the `MARKER-WRITE-FAILED` audit entry clearly identify the failing verdict and its type?
- **Performance** (weight: 0.05): Both sub-scenarios complete within a reasonable time.
- **Data integrity** (weight: 0.05): Sub-B: no `jr issue link` call recorded; marker-store has no partial marker file.

## Edge Conditions

- Sub-scenario A: confirm that a NON-hard-floor link verdict with `autonomy_enabled=false`
  IS suppressed by the kill switch (STEP 3b does not fire for non-hard-floor links).
- Sub-scenario B: null-binding check — if `ticket_id=null` for a hard-floor link,
  disposition-guard must emit `HARD-FLOOR-UNBINDABLE` (not `MARKER-WRITE-FAILED`);
  these are distinct denial codes.

## Failure Guidance

"HOLDOUT CRITICAL: HS-051 (satisfaction: 0.XX) — Sub-A: Hard-floor link was suppressed by the kill switch (autonomy_enabled=false); STEP 3b carve-out (D-027) is absent. Sub-B: Hard-floor link was allowed without a marker despite MARKER-WRITE-FAILED; REVIEW-CLASS fail-closed behavior (D-028/P10-003) is absent."

## Category: real-world-corpus

N/A — This is a `security-probes` scenario using synthetic verdict fixtures, jr mock,
and injected filesystem failure.

| Field | Description |
|-------|-------------|
| corpus_source | Synthetic hard-floor link verdict fixture |
| corpus_size | 1 verdict Write per sub-scenario |
| known_edge_cases | Non-hard-floor link (must be suppressed by kill switch); null ticket_id → HARD-FLOOR-UNBINDABLE |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

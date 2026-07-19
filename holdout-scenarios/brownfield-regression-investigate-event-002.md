---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-5.01.001.md
  - specs/module-criticality.md
input-hash: ""
traces_to: phase-0-ingestion/behavioral-contracts/BC-5.01.001.md
id: "HS-022"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-5.01.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: investigate-event Skill — Internal Source IP Triggers Lateral Movement Assessment

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/investigate-event ALERT-020` for an IDS alert where the source IP is `10.0.5.50` (an internal network address).
3. The skill identifies the source IP as internal during Stage 3.
4. The skill does NOT treat the internal IP as automatically safe.
5. The investigation explicitly assesses lateral movement possibility (is this host moving laterally from a compromised internal system?).
6. The investigation report includes lateral movement assessment in the evidence chain.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-5.01.001 | Invariant 3: internal source IPs are not treated as automatically safe — lateral movement possibility must be assessed | Steps 4-6 verify the lateral movement check is performed |
| BC-5.01.001 | Edge Case EC-004: source IP is internal → must assess lateral movement possibility; do not assume safe | The exact documented invariant |

## Verification Approach

Ask Claude to investigate an alert with an internal source IP:

> "Run /investigate-event ALERT-020. The alert is: Snort rule triggered — potential data exfiltration. Source: 10.0.5.50 (internal), Destination: 185.100.200.50 (external), Port: 443."

In Claude's investigation output, look for:
- Explicit acknowledgment that 10.0.5.50 is an internal IP.
- A lateral movement assessment — is this host a potential pivot point from an earlier compromise?
- The assessment must NOT read "Source is internal, therefore likely benign/authorized."
- The investigation must proceed through all 7 stages.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Does the investigation include a lateral movement assessment for the internal source IP? (1.0 = lateral movement explicitly assessed; 0.0 = internal IP treated as automatically safe)
- **Edge case handling** (weight: 0.2): Does the investigator check whether 10.0.5.50 has any prior security events or anomalous history?
- **Error quality** (weight: 0.2): Is the rationale for the lateral movement assessment clearly explained?
- **Performance** (weight: 0.05): Normal investigation completion.
- **Data integrity** (weight: 0.05): Investigation document includes this assessment.

## Edge Conditions

- If Perplexity is unavailable, WebSearch/WebFetch is used instead for external IP threat intel (10.0.5.50 is internal so no external OSINT applies, but Stage 5 should still assess the destination IP).

## Failure Guidance

"HOLDOUT LOW: HS-022 (satisfaction: 0.XX) — investigate-event treated an internal source IP as automatically safe without assessing lateral movement; the internal-IP confirmation-bias guard is not enforced."

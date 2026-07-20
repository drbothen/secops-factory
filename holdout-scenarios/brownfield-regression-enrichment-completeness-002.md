---
document_type: holdout-scenario
level: ops
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.02.001.md
  - specs/module-criticality.md
input-hash: "e9a2b3e"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.02.001.md
id: "HS-010"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-3.02.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: "2026-07-19"
stale_reason: "v1.0 fixture used a partial investigation file (Alert Details only) expecting ALLOW; BC-3.02.001 v1.1 (ADV-0-402) flipped EC-004 to DENY — all four sections required, no partial-save path. Regenerated against v1.1 semantics."
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: enrichment-completeness Hook — Complete Investigation Document (All 4 Sections) Saves Successfully

> **Regenerated v1.1 (ADV-0-505):** Prior fixture saved a partial investigation file
> (Alert Details only) and expected ALLOW. BC-3.02.001 v1.1 (ADV-0-402) corrected
> this — the hook requires ALL FOUR investigation sections before any save. The fixture
> now uses an all-four-headings-present investigation document and verifies the allow
> path for the complete case.

## Scenario

1. The secops-factory plugin is activated.
2. Claude attempts to save an investigation document named `investigation-ALERT-456.md` that contains all four required section headings — "Executive Summary", "Alert Details", "Disposition", and "Next Actions" — each with at least a heading line (bodies may be stub content).
3. The enrichment-completeness hook fires on the Write tool call.
4. The save is **allowed** — all four required investigation sections are present.
5. Claude confirms the investigation document was saved successfully.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.02.001 | Postcondition 4 (v1.1): if all required sections are present, hook emits `permissionDecision: allow` | Steps 3-5 verify the positive allow path for a complete investigation file |
| BC-3.02.001 | Postcondition 3 (v1.1): investigation files require all four sections — "Executive Summary", "Alert Details", "Disposition", "Next Actions" | The fixture must include all four headings |
| BC-3.02.001 | Invariant 1: section heading presence (even with empty body) satisfies the gate | Stub bodies are valid — only the heading strings are checked |

## Verification Approach

Ask Claude to save a complete investigation document with all four required headings:

> "Save my investigation for ALERT-456: '# Executive Summary\nSuspicious outbound connection investigated.\n# Alert Details\nSnort IDS alert on 192.168.1.50 → external:22.\n# Disposition\nBenign True Positive — authorized SSH jump host.\n# Alternatives Considered\n1. TP malicious exfil\n2. FP misconfigured alert\n# Next Actions\nDocument in ticketing system and close.'"

With the plugin active, the Write should succeed. Observe:
- No block message from the enrichment-completeness hook.
- Claude confirms the investigation document was saved.
- The save completes without a "Missing required sections" denial.

Note: Section bodies may be minimal — the hook checks heading string presence via `grep -qF`, not body content quality. A heading with no body passes the gate.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Did the complete investigation document (all 4 headings present) save without a completeness block? (1.0 = saved cleanly; 0.0 = blocked despite all sections present)
- **Edge case handling** (weight: 0.1): Confirm that saving with only 3 of 4 sections produces a deny (complementary negative test — e.g., missing "Next Actions" should block).
- **Error quality** (weight: 0.1): No spurious denial messages for the complete document.
- **Performance** (weight: 0.1): Normal hook decision time.
- **Data integrity** (weight: 0.1): Investigation file is saved with all provided content intact.

## Edge Conditions

- The four required investigation section headings are: "Executive Summary", "Alert Details", "Disposition", "Next Actions". All must appear verbatim (case-sensitive) as the hook uses `grep -qF` exact matching.
- A document with all four headings but missing "Alternatives Considered" is handled by the **disposition-guard** hook (a separate gate), not by this hook. The enrichment-completeness hook only validates structural section presence.
- The v1.0 assumption of a "partial save" path for in-progress investigation files was incorrect per BC-3.02.001 v1.1: the real workflow generates the full document structure from a template at save time, so all four headings are always present when the document is first written.

## Failure Guidance

"HOLDOUT LOW: HS-010 (satisfaction: 0.XX) — A complete investigation document with all four required section headings was blocked by the enrichment-completeness hook; the hook is falsely denying a structurally complete investigation file."

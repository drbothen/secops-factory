---
document_type: adversarial-review-report
level: L3
version: "1.0"
status: not-clean
producer: adversary
timestamp: 2026-09-03T20:00:00Z
phase: F2
pass: 36
cycle: v0.10.0-feature-prism-integration
inputs: [phase-f2-spec-evolution/]
input-hash: "[live-state]"
traces_to: STATE.md
---

# F2 Adversarial Spec Review — Pass 36

**Date:** 2026-09-03
**Verdict:** PASS 36 — 0C / 0M / 1med / 0min / 0obs — **NOT CLEAN**
**Novelty:** LOW — sole MEDIUM is a VP attribution/traceability coherence gap (VP-HOOK-024 misattributed to BC-10.01.001 in prd-delta §1; owned by BC-3.01.001). Substantive spec content independently re-derived clean — seventh consecutive 0C/0M pass.
**Status:** NOT CLEAN — clean streak RESET to 0/3. REMEDIATED by burst-33 (comprehensive VP-ownership/traceability audit — 8 coherence defects corrected). Awaiting pass-37.

---

## Summary

| Severity | Count | IDs |
|----------|-------|-----|
| CRITICAL | 0 | — |
| MAJOR | 0 | — |
| MEDIUM | 1 | P36-001 |
| MINOR | 0 | — |
| OBSERVATION | 0 | — |

**Clean verdict: NO** — 1 MEDIUM finding (VP attribution coherence gap)

---

## Independent Re-Derivation Scope

The adversary independently re-derived the core emitter/consumer/floor/kill-switch logic:

- **STEP ordering** — disposition-guard STEP 1→2→3→3b→4→4b→5→6 confirmed correct; STEP 4b close-disposition gate correctly precedes STEP 5 kill switch (D-025)
- **Hard-floor** — HIGH/CRIT scored_priority floor (EC-009) confirmed; known-FP exemption scoped to LOW/MED (D-019); HIGH/CRIT known-FPs route to comment-review
- **Kill switch** — autonomy_enabled=false exemption for create-review/comment-review confirmed (D-007/BC-10.01.001 Inv#11)
- **Marker mechanism** — expires_at_utc=issued_at_utc+120s, rename mechanism, exact-type scope match confirmed (BC-3.01.001); anti-fungibility invariants intact

**Substance confirmed converged** — P36-001 is a traceability/accounting coherence gap, not a logical defect.

---

## Findings

### P36-001 (MEDIUM) — prd-delta §1 VP-HOOK-024 misattributed to BC-10.01.001; §1 VP totals inflated; lifecycle status errors

**Severity:** MEDIUM
**Location:** prd-delta §1 BC-10.01.001 VP Refs column; §1 VP Totals line; BC-10.01.001 and BC-6.01.003 VP Anchors footers
**Finding:** prd-delta §1 listed VP-HOOK-024 in BC-10.01.001's VP Refs column. Per verification-delta §1 line 431, VP-HOOK-024 is owned by **BC-3.01.001** (require-review consumer hook), not BC-10.01.001 (monitoring-loop). Additionally, VP-SKILL-075, VP-SKILL-076, and VP-SKILL-077 were labeled FINALIZED in the §1 table but are PROPOSED P1 in the verification-delta §1 ownership model and in the respective BC footer VP Anchors rows. The combined errors inflated the §1 VP total from the correct 21 FIN + 4 PROP = 25 to "25 assigned VPs, 1 proposed VP" (26 total claimed, 25 actual, with wrong FINALIZED/PROPOSED split).

**Impact on convergence-gate accounting:** The convergence-gate tracks FINALIZED P0 VPs. The mislabeling of VP-SKILL-075/076/077 as FINALIZED (when they are PROPOSED P1) overstated the number of FINALIZED VPs eligible for convergence-gate by 3. Prior recounts that declared §1 "reconciled" had done so by checking §1 against §1's own Totals line — they validated the wrong values because they skipped the source-of-truth check against BC footers and the verification-delta ownership model.

**Root cause:** VP accounting in §1 was reconciled against the §1 summary table rather than against (a) the verification-delta §1 ownership model and (b) each BC's VP Anchors footer. Even CLEAN pass-35 validated the wrong 26-VP count because it re-derived from the summary, not the authority.

**REMEDIATED:** burst-33 (this session) — comprehensive VP-ownership/traceability audit. See burst-33 log for the full 8-fix enumeration.

---

## Remediation Record

P36-001 → **REMEDIATED** — burst-33 comprehensive VP-ownership/traceability audit:

| Item | Fix | Files |
|------|-----|-------|
| A | Removed VP-HOOK-024 from BC-10.01.001 VP Refs in prd-delta §1 | prd-delta v1.35 |
| B | §1 VP Totals re-derived from BC footers: 21 FIN + 4 PROP = 25 (corrected from "25 FIN + 1 PROP = 26") | prd-delta v1.35 |
| C | VP-SKILL-075 corrected FINALIZED P0 → PROPOSED P1 in prd-delta §1 BC-10.01.001 VP-Refs + BC-10.01.001 v1.32 VP Anchors footer (no-bump) | prd-delta v1.35, BC-10.01.001 |
| D | VP-SKILL-076/077 corrected FINALIZED → PROPOSED P1 in prd-delta §1 BC-6.01.003 VP-Refs + BC-6.01.003 footer (no-bump) | prd-delta v1.35, BC-6.01.003 |
| E | BC-10.01.001 Subject in §3.8: "12-field ICD-203 schema" → "18-field verdict schema (12-field investigation markdown)" | prd-delta v1.35 |
| F | BC-6.01.003 Criticality: "C-27/C-28 consumers" → "C-30 watermark-store" per BC-6.01.003 Traceability Architecture Module | prd-delta v1.35 |
| G | BC-6.01.001 EC-010 in §8: "jr auth check fails" → "jr auth status fails (non-zero exit)" per BC-6.01.001 v1.4 rename | prd-delta v1.35 |
| H | BC-3.03.001 v1.42: added missing VP Anchors row (VP-HOOK-030/031/032 — existed in verif-delta but absent from BC footer; no version bump) | BC-3.03.001 |

**verification-delta UNCHANGED** — confirmed as the correct source of truth; VP-HOOK-024 ownership (BC-3.01.001) and VP-SKILL-075/076/077 PROPOSED P1 status are correctly stated in verification-delta §1. No changes required.

**VP/SM registry tallies UNCHANGED** — 41 VP total in registry / 74 SM alloc / 73 live. Only prd-delta's FINALIZED/PROPOSED split accounting was corrected. Convergence-gate eligible count: 21 FINALIZED P0 (not 25 or 26).

**Note:** P36-001 triggered a COMPREHENSIVE VP-ownership/traceability audit (burst-33) that found 8 coherence defects total — including 3 CRITICAL-classified items that corrupted the convergence-gate VP count. Prior consecutive clean-streak attempts were counting against the wrong VP total. This burst corrects the accounting baseline for future streak attempts.

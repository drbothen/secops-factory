---
document_type: adversarial-review
pass: 11
producer: adversary
date: 2026-07-22
cycle: v0.10.0-feature-prism-integration
scope: F2 spec-evolution delta package (architecture-delta v1.13, verification-delta v1.13, prd-delta v1.12, dtu-assessment v1.1, asm-004-validation, spec-changelog, 12 BCs)
---

# Adversarial Review — Pass 11

## Summary Table

| ID | Title | Severity | Confidence |
|----|-------|----------|------------|
| P11-001 | STEP 1a re-normalizes from LLM-supplied `native_severity` → severity hard floor is still LLM-bypassable; "un-bypassable / independently derived from raw sensor values" claim is false | CRITICAL | HIGH |
| P11-002 | STEP 1a exact-equality contradicts Stage-5 severity recalibration mandated by BC-10.01.001 field 13 + brief §3.2/§3.9; recalibrated verdicts are denied, and the §3.9 high-severity floor cannot see scored-priority escalations | MAJOR | HIGH |
| P11-003 | NVD/CVSS-derived severity cannot be re-normalized hook-side: `sensor_family` enum excludes `nvd` but D-DEC-013 has an NVD/CVSS row and prd-delta lists CVSS as a `native_severity` example → false SEVERITY-MISMATCH deny or forced mislabel | MAJOR | MEDIUM |
| P11-004 | disposition-guard emitter entry for the investigation-markdown (12-field) path is self-contradictory and technically impossible (validate_enums requires verdict-only fields) — BC-3.03.001 vs architecture-delta conflict | MAJOR | HIGH |
| P11-005 | BC-6.01.003 Invariant #6 mis-anchored cross-reference to "BC-9.01.001 Precondition #9" (scan-threats has no such precondition; should be BC-6.01.001) | MINOR (mis-anchor) | HIGH |
| P11-006 | prd-delta stale "12/15-field artifact-class split" not propagated to 12/17 after P10-001 | MINOR | MEDIUM |
| P11-007 | D-DEC-013 "unrecognized sensor_family → CRITICAL" default is dead on the hook path (STEP 1 enum-denies non-member family before STEP 1a) | OBSERVATION | MEDIUM |

---

## Critical Findings

### P11-001 — STEP 1a re-normalizes from an LLM-supplied field; the severity hard floor is still LLM-bypassable

**Severity:** CRITICAL   **Confidence:** HIGH

**Anchor:**
- architecture-delta.md v1.13 §D-DEC-008 "Hard floor binding" lines 1727–1732 ("Post-P10-001 enforcement (genuinely deterministic) … The LLM cannot bypass the severity floor by under-reporting severity, because the hook independently derives it from raw sensor values.")
- architecture-delta.md line 1739 ("This is the only remaining LLM-trust surface in the hard floor." — referring to asset_type)
- architecture-delta.md §D-DEC-013 lines 2470–2473 / §5.3 line 1943 ("Fields 16-17 carry raw Stage-1 INGEST values verbatim into the verdict")
- BC-3.03.001 v1.18 STEP 1a lines 194–197 ("This makes severity enforcement genuinely un-bypassable … the hook independently derives severity from native_severity + sensor_family")
- BC-10.01.001 Stage-1 INGEST line 507 ("write native_severity (field 16, string) and sensor_family (field 17, enum)")
- verification-delta.md lines 426–434 (same "independently re-derives / genuinely un-bypassable" claim)

**Description:**
P10-001's stated purpose is to relocate severity trust "from LLM to hook" by having disposition-guard STEP 1a re-run `NORMALIZE_SEVERITY(native_severity, sensor_family)` and deny on mismatch with `verdict.severity`. But `native_severity` (field 16) and `sensor_family` (field 17) are **both written by the monitoring-loop LLM at Stage 1 INGEST** and carried "verbatim" into the verdict. The hooks make no prism call (require-review/disposition-guard Invariant #2: no network, no subprocess beyond `jq`), so the hook has **no independent source** for the raw severity. STEP 1a therefore enforces only *internal consistency between two LLM-supplied fields* — not agreement with ground truth.

The security claim that the hook "independently derives [severity] from raw sensor values" is false: it derives it from `verdict.native_severity`, an LLM field. The trust surface was moved from `verdict.severity` to `verdict.native_severity`, both equally LLM-controlled. This is the exact "LLM-controlled value bypassing a deterministic control" class the mandate flags as CRITICAL.

Note the asymmetry: the delta *honestly* documents (line 1733–1741) that `asset_type` cross-validation against prism is ASM-008-DEFERRED and "the LLM could under-report asset_type," calling it "**the only** remaining LLM-trust surface." `native_severity` has identical trust properties (LLM-supplied Stage-1 value, no hook-side prism cross-check) yet is affirmatively described as closed/un-bypassable. The residual for the severity dimension is **understated**, and the "only remaining" claim is wrong.

**Concrete failure scenario:**
A prism-injected or misaligned monitoring-loop LLM processes a CrowdStrike detection with true score 95 (→ CRITICAL). The LLM writes `native_severity="10"`, `sensor_family="crowdstrike"`, `severity="LOW"`, `disposition="FP"`, `ticket_action_type="comment"`, `autonomy_enabled=true`. STEP 1a computes `NORMALIZE_SEVERITY("10","crowdstrike")=LOW`, which equals `verdict.severity=LOW` → **no SEVERITY-MISMATCH**. `hard_floor_applies()` sees `recomputed_severity=LOW` → no floor → disposition-guard issues a `comment` marker → require-review allows the autonomous `jr issue comment` (FP auto-close narrative) on a genuinely CRITICAL alert. The hard floor was bypassed with no audit signal.

**Suggested remediation:**
Retract the "genuinely un-bypassable / independently derives from raw sensor values / only remaining LLM-trust surface" language in architecture-delta §D-DEC-008, BC-3.03.001 STEP 1a, BC-10.01.001, and verification-delta. Reclassify `native_severity` trust as an **ASM-008-DEFERRED residual identical to asset_type**: STEP 1a is a consistency cross-check that hardens against a *careless* LLM but not an adversarial one; genuine severity ground-truth requires hook-side prism cross-validation (or a prism-signed severity field), which is ASM-008-gated and MUST be a pre-production follow-up. Document the residual symmetrically alongside the asset_type residual, and downgrade VP-HOOK-030's asserted guarantee from "un-bypassable" to "verdict.severity is consistent with verdict.native_severity" (which is all it can prove).

---

## Important Findings

### P11-002 — STEP 1a exact-equality is incompatible with the Stage-5 severity recalibration that BC-10.01.001 mandates; the §3.9 high-severity floor cannot see scored-priority escalations

**Severity:** MAJOR   **Confidence:** HIGH

**Anchor:**
- BC-10.01.001 field 13 definition, lines 261–263: "`severity` … produced by NORMALIZE_SEVERITY(native_severity, sensor_family) at Stage 1 INGEST … **then recalibrated at Stage 5 SCORE**; read by disposition-guard for hard-floor"
- BC-10.01.001 lines 434–437 (Invariant text): severity is sensor-provided and hook-cross-validated (no mention of recalibration) — internal incoherence with field 13
- BC-3.03.001 STEP 1a lines 197–211 / architecture-delta STEP 1a lines 1368–1385: `IF recomputed_severity != verdict.severity → deny`
- brief §3.2 STAGE 5 SCORE and §3.9 ("Recalibrate detector-supplied severity by rule FP history")
- BC-4.05.001 PC#6 (lines 73–99): assess-priority emits `priority` (CRIT/HIGH/MED/LOW), a recalibrated value distinct from detector-native `severity`; there is **no `priority` field** in the 17-field verdict schema

**Description:**
STEP 1a pins `verdict.severity` to the pure function `NORMALIZE_SEVERITY(native_severity, sensor_family)`. But BC-10.01.001 field 13 explicitly says severity is "**then recalibrated at Stage 5 SCORE**," and the brief's Stage-5 SCORE + §3.9 mandate recalibrating detector-supplied severity by rule fidelity and per-tenant asset criticality. These are mutually exclusive: any Stage-5 recalibration that moves severity off the raw normalization bucket produces `verdict.severity != recomputed_severity` → SEVERITY-MISMATCH deny.

Two opposite-direction consequences, both defects:
1. **Down/any recalibration is impossible.** A CrowdStrike score-90 (→ CRITICAL) on a known-noisy rule that Stage-5 recalibrates to MED cannot be written — disposition-guard denies every such verdict; the loop either livelocks (re-doc) or drops the finding to `HARD-FLOOR-LIVELOCK-ABORT`. The research-mandated recalibration capability is architecturally dead.
2. **The §3.9 "high-severity" floor is blind to escalations.** Because `verdict.severity` must equal the detector-native normalization, the scored priority from assess-priority (which can escalate a LOW-detector-severity alert to CRIT via KEV/internet-exposure/critical-asset weighting — BC-4.05.001 EC-002/EC-006) is **not stored anywhere in the verdict and is not an input to `hard_floor_applies()`**. A CrowdStrike score-20 (→ LOW) KEV-listed internet-facing alert that assess-priority scores CRIT has `verdict.severity=LOW` → no hard floor → eligible for autonomous auto-action. Brief §3.9 says "Any alert **scored** HIGH or CRIT" must be human-surfaced — the implementation keys the floor on detector-native severity, not the score.

BC-10.01.001 is internally incoherent about this: field 13 says "recalibrated at Stage 5" while the Invariant block (lines 434–437) says severity is sensor-provided and cross-validated.

**Concrete failure scenario:**
Stage 5 SCORE (assess-priority) recalibrates a Claroty "High" (→ HIGH) OT alert down to MED because documented+tested compensating controls apply (BC-4.05.001 Invariant #3). The loop writes `verdict.severity=MEDIUM`, `native_severity="High"`, `sensor_family="claroty"`. STEP 1a recomputes `NORMALIZE_SEVERITY("High","claroty")=HIGH != MEDIUM` → SEVERITY-MISMATCH deny. The loop re-documents, hits the deny again, and after 3 attempts emits `HARD-FLOOR-LIVELOCK-ABORT` — the alert never gets a verdict. Conversely, a KEV-listed LOW-detector-severity alert scored CRIT by assess-priority is auto-commented/closed because the floor never sees the CRIT score.

**Suggested remediation:**
Resolve the severity-vs-priority model explicitly. Either (a) define TWO fields — `native_normalized_severity` (hook-recomputable, STEP-1a-checked) AND `scored_priority` (the Stage-5 output) — and have `hard_floor_applies()` key the high-severity floor on **max(native_normalized_severity, scored_priority)** so both a high detector severity and a high scored priority trip the floor; or (b) drop STEP 1a's exact-equality and instead assert `verdict.severity >= NORMALIZE_SEVERITY(native_severity, sensor_family)` (recalibration may only escalate, never de-escalate below the detector floor), which preserves the anti-under-report property while permitting upward recalibration. In all cases, remove the "recalibrated at Stage 5 SCORE" clause from BC-10.01.001 field 13 OR reconcile it with STEP 1a, and fix the internal BC-10.01.001 incoherence.

### P11-003 — NVD/CVSS-derived severity cannot be re-normalized hook-side; STEP 1a false-denies or forces mislabeling of NVD-scored alerts

**Severity:** MAJOR   **Confidence:** MEDIUM

**Anchor:**
- validate_enums `SENSOR_FAMILY_ENUM = {"crowdstrike","armis","claroty","cyberint"}` (BC-3.03.001 line 160; architecture-delta line 1330) — no `nvd` member
- D-DEC-013 normalization table (architecture-delta line 2452) has a distinct "NVD/CVSS (via enrich_nvd())" row (`≥9.0 → CRITICAL; ≥7.0 → HIGH; …`)
- prd-delta field-16 definition line 223 lists "`8.5` for NVD CVSS" as a valid `native_severity` example
- BC-3.03.001 STEP 1a lines 197–211: `recomputed = NORMALIZE_SEVERITY(native_severity, sensor_family)` with `sensor_family` constrained to the four sensors

**Description:**
D-DEC-013 and prd-delta both treat CVSS floats as a legitimate `native_severity` source, but `sensor_family` (field 17) cannot be `nvd` — it is enum-restricted to the four sensor vendors. When severity derives from `enrich_nvd()` CVSS (an explicitly supported enrichment path, BC-5.01.001 PC#7 Stage-4, BC-4.05.001 PC#5b), STEP 1a is forced to call `NORMALIZE_SEVERITY(cvss_float, <one of the four sensors>)`, which applies the **wrong per-family table** (e.g., CrowdStrike's numeric-1-100 bands) to a 0.0–10.0 CVSS value. The NVD/CVSS row in D-DEC-013 is therefore unreachable from STEP 1a, and CVSS-scored alerts either false-deny or must be mislabeled.

**Concrete failure scenario:**
An alert is scored from NVD CVSS 8.5 (→ HIGH per the NVD row). The loop sets `severity="HIGH"`, `native_severity="8.5"`, and must pick a `sensor_family` from the four (say `crowdstrike`, the originating sensor). STEP 1a computes `NORMALIZE_SEVERITY("8.5","crowdstrike")` → CrowdStrike table treats 8.5 as `<26 → LOW` → recomputed LOW ≠ HIGH → **SEVERITY-MISMATCH deny**. To avoid the deny the loop must write `severity="LOW"`, under-flooring a CVSS-8.5 HIGH alert. Either way the outcome is wrong.

**Suggested remediation:**
Decide whether NVD-CVSS may ever populate `native_severity`. If yes, add `nvd` to `SENSOR_FAMILY_ENUM` (and require the loop to set `sensor_family=nvd` whenever severity is CVSS-derived), or add a separate `severity_source` discriminator that STEP 1a keys on. If no, remove the NVD/CVSS row from the D-DEC-013 STEP-1a table and the "8.5 for NVD CVSS" example from prd-delta line 223, and specify that CVSS enrichment adjusts scored priority (P11-002) but never sets the hook-checked `native_severity`.

### P11-004 — disposition-guard emitter entry for the investigation-markdown (12-field) path is self-contradictory and technically impossible

**Severity:** MAJOR   **Confidence:** HIGH

**Anchor:**
- BC-3.03.001 Invariant #4, line 129: "The emitter is entered **ONLY from the verdict-class (PC#1 JSON path)** — the investigation-markdown path (PC#2) **emits markers using the same emitter** after ICD-203 12-field validation." (flat self-contradiction)
- BC-3.03.001 STEP 0 note, lines 137–140: "The investigation-markdown path (PC#2) has its own 12-field check and **reaches here** only after all 12 fields are present."
- BC-3.03.001 PC#2, line 82: investigation markdown "proceeds to the hard-floor check and, if not blocked, **emits the marker** (see Invariant #4 — EMITTER role)"
- architecture-delta §D-DEC-008 STEP 0, lines 1310–1314: "The investigation-markdown path (12-field) has its own separate pseudocode and **does NOT reach this emitter**."
- Emitter STEP 1 validate_enums (BC-3.03.001 lines 153–179): requires `severity`, `asset_type`, `ticket_action_type`, `native_severity`, `sensor_family` — none of which exist in the 12-field investigation set (per the PC#2 list, line 82, and the erratum lines 84 / architecture-delta 1945–1952)
- Consumers: BC-5.01.001 Invariant #7 and BC-4.02.001 PC#4 both assert disposition-guard issues a marker for the human `jr issue comment` path on non-hard-floor

**Description:**
The specs disagree on whether the human investigate-event path (12-field investigation markdown) reaches the marker emitter, and no reading is coherent:
- architecture-delta says it does **not** reach the emitter → then **no marker is ever issued** for the human comment path, contradicting BC-5.01.001 Inv#7 / BC-4.02.001 PC#4 which promise a marker on non-hard-floor dispositions.
- BC-3.03.001 says it **does** reach "the same emitter" → but the emitter's first step (validate_enums) immediately denies because `severity`/`asset_type`/`ticket_action_type`/`native_severity`/`sensor_family` are absent from a 12-field markdown. Since disposition-guard fires on the **Write of the investigation document itself**, this means a fully-complete investigation markdown (all 12 headings + Disposition + Alternatives) would be **DENIED at save time** — the analyst cannot save their investigation. STEP 1a (`NORMALIZE_SEVERITY(native_severity, sensor_family)`) is likewise meaningless for a human markdown.

P10-001 (v1.18) worsened this: it added `native_severity`/`sensor_family` to validate_enums and inserted STEP 1a, further widening the gap between "the emitter" and what a 12-field markdown can satisfy, without reconciling the investigation-markdown emitter-entry claim.

**Concrete failure scenario:**
An analyst completes an investigate-event workflow; Stage 7 writes `artifacts/investigations/investigation-ALERT-001.md` with all 12 ICD-203 headings, Disposition, and Alternatives Considered. disposition-guard routes to PC#2 (Check 2), validates 12 headings, then (per BC-3.03.001 line 82/129) "proceeds to the EMITTER role." Emitter STEP 1 validate_enums checks `verdict.severity` — absent in markdown → `emit deny("ICD-203 enum-membership validation failed: severity … not in allowed set")`. The investigation document Write is blocked; the analyst is stuck.

**Suggested remediation:**
Pick one model and make all four documents agree. Recommended: the investigation-markdown (12-field) path does NOT enter the verdict emitter (align BC-3.03.001 line 129/PC#2 to architecture-delta STEP 0). Specify a **separate, minimal marker-issuance path for the human comment** (comment-scoped marker bound to the ticket_id parsed from the investigation, gated only on the 12-field completeness + the markdown-evaluable hard floors: Indeterminate disposition, forbidden techniques, degraded/silent sensor) — explicitly NOT calling validate_enums/STEP 1a (which reference verdict-only fields). Then reconcile BC-5.01.001 Inv#7 and BC-4.02.001 PC#4, which currently list "HIGH/CRIT severity, critical assets" as hard-floor conditions for the human path even though those fields do not exist in a 12-field markdown.

---

## Minor Findings

### P11-005 — BC-6.01.003 Invariant #6 mis-anchored cross-reference to "BC-9.01.001 Precondition #9"

**Severity:** MINOR (mis-anchor — blocks convergence per the semantic-anchoring rule)   **Confidence:** HIGH

**Anchor:** BC-6.01.003.md Invariant #6, lines 104–105: "If neither is present, disposition-guard emits HARD-FLOOR-UNBINDABLE (per Invariant #10 of BC-10.01.001 **and BC-9.01.001 Precondition #9**)."

**Description:** BC-9.01.001 is the `scan-threats` proactive-hunting skill; it has exactly **4 preconditions** and nothing to do with `jira_project_key`, disposition-guard, or HARD-FLOOR-UNBINDABLE. There is no Precondition #9, and scan-threats performs no Jira writes. The correct anchor for the global `jira_project_key` fallback / Stage-0 gate is **BC-6.01.001** (activate), whose Invariant #12 / EC-013 (confirmed present) define the jira_project_key Stage-0 precondition. This is a dangling/wrong citation (likely a `6.01.001` → `9.01.001` typo). An implementer following it finds nothing relevant. Mis-anchoring always blocks convergence.

**Suggested remediation:** Change "BC-9.01.001 Precondition #9" to "BC-6.01.001 Invariant #12 / EC-013" (the activate Stage-0 jira_project_key gate).

### P11-006 — prd-delta stale "12/15-field artifact-class split" not propagated to 12/17 after P10-001

**Severity:** MINOR   **Confidence:** MEDIUM

**Anchor:** prd-delta.md line 96 ("updated VP-HOOK-025 to enforce the **12/15-field artifact-class split**") and line 134 ("enforces the full **12/15-field artifact-class split** — investigation markdown uses heading-…"), vs lines 197/223–226 which correctly state 17.

**Description:** P10-001 extended the verdict-JSON class to 17 fields, and prd-delta line 226 reflects this ("verdict JSON files: all 17 fields"). But lines 96 and 134 still describe VP-HOOK-025's enforcement as a "12/15-field split." Line 134 in particular reads as a current-tense description of the enforcement surface, not a historical changelog note. Per the Partial-Fix Regression Discipline axis (prose referencing a changed value), this is an incomplete propagation of the field-count change within prd-delta.

**Suggested remediation:** Update lines 96/134 to "12/17-field artifact-class split," or annotate them as historical (pass-3) if they are intended as changelog context.

---

## Observations

- **P11-007 [minor internal inconsistency]:** The D-DEC-013 `UNRECOGNIZED_DEFAULT = "CRITICAL"` rule for an *unrecognized sensor family* (architecture-delta lines 2439–2442; BC-10.01.001 line 305) can never fire on the disposition-guard STEP-1a path: STEP 1 validate_enums denies any `sensor_family` not in `{crowdstrike,armis,claroty,cyberint}` **before** STEP 1a runs (BC-3.03.001 lines 177–178). The "unrecognized VALUE within a recognized family → CRITICAL" rule is still live; only the "unrecognized FAMILY → CRITICAL" default is dead hook-side. Harmless today but the two rules should not both be presented as reachable STEP-1a behavior.

- **[process-gap] Recurring false-closure language.** The unsound "genuinely un-bypassable / hook independently derives from raw sensor values / only remaining LLM-trust surface" phrasing (P11-001) appears verbatim or near-verbatim in **four** documents (architecture-delta §D-DEC-008, BC-3.03.001 STEP 1a, BC-10.01.001 Invariant, verification-delta §7). A single trust-basis error propagated to four artifacts indicates the claim was copy-propagated without a hook-can-see-ground-truth check. Recommend a review-axis / codification note: any "un-bypassable" or "independently derived" claim about a hook-computed control must identify the hook's independent evidence source (network-free hooks cannot derive anything the LLM did not supply).

- **Known-FP fast-path × high native severity (documented tension, not a new defect):** because `hard_floor_applies()` keys on the (recomputed) detector-native severity, a known-FP match on any HIGH/CRIT native-severity alert is forced to review rather than auto-closing — negating the fast-path budget benefit for high-severity noise. This follows correctly from the hard-floor design but should be called out to operators alongside the Cyberint mass-escalation OBS-2.

- **ASM-014 / ASM-015 / ASM-008 deferrals** were reviewed and are NOT re-reported as new defects; they remain correctly scoped, with the one exception that P11-001 shows the ASM-008 residual should also cover `native_severity`, not only `asset_type`.

- **Confirmed adequately handled this pass:** fields 16/17 population on the known-FP fast-path (Stage-1 INGEST precedes Stage-2 known-FP; BC-10.01.001 line 507 + D-DEC-013 fast-path note — fields are populated before Stage 5 is skipped); BC-6.01.001 jira_project_key Stage-0 gate (Inv#12/EC-013) present; the Cyberint always-CRITICAL case does NOT mass-*deny* (it mass-*escalates*, which is documented) provided the loop applies the same conservative default and does not recalibrate (see P11-002).

---

## Novelty Assessment

**Novelty: HIGH.** This pass attacked the pass-10 remediation itself (the P10-001 STEP-1a re-normalization) rather than re-treading the marker/anti-fungibility/dispatch surfaces frozen in the invariant list. Four graded findings are genuinely new:
- P11-001 (CRITICAL) refutes the central security claim of the pass-10 fix — the "trust relocated to hook" is illusory because `native_severity` is LLM-supplied. This was not visible to prior passes because they were anchored to the framing that STEP 1a *closed* the severity surface.
- P11-002/P11-003 exploit the interaction between the new pinned-severity semantics and the pre-existing Stage-5 recalibration and NVD-enrichment paths — cross-document seams that no single prior pass owned.
- P11-004 surfaces a BC-vs-architecture contradiction on emitter entry that P10-001's field additions sharpened into an impossibility.

These are gaps, not nitpicks. The spec has **not** converged: one CRITICAL and three MAJOR findings block. Minimum-3-clean-passes clock resets.

---

## Confirmed Invariants (carried forward + additions)

Carried forward (spot-checked intact this pass; concentrate future effort elsewhere):
1. Marker schema v2.1 authoritative block in sync (BC-3.03.001 lines 494–529 / D-DEC-001).
2. JSON-first dispatch precedes investigation-substring branch; `.json`/valid-JSON → verdict class (BC-3.03.001 PC#1 Check-1; VP-HOOK-028).
3. Hard floors key on HOOK-RECOMPUTED severity (STEP 1a) + asset_type; `asset_type=unknown` a separate explicit floor; confidence NOT a floor input. *(NOTE: "hook-recomputed" is only as trustworthy as the LLM-supplied native_severity — see P11-001.)*
4. Emitter decision-tree order STEP 1 → 1a → 2 → 3 (bindable; UNBINDABLE→deny) → 4 (under-label deny) → 5 (kill switch) → 6; STEPs 1a/3/4 fire regardless of autonomy_enabled.
5. BC-10.01.001 review-marker semantics with negative assertions (EC-015/016/017/021) intact.
6. Consumer iterative-consume ordering, audit path, base64 + control-char stripping intact.
7. Sensor-silence direction (`last_seen_ts < now()-24h`) consistent.
8. VP/SM namespace collision-free (VP-SKILL 001-075, VP-HOOK 024-030, SM-9..SM-45); VP-HOOK-030 + VP-SKILL-075 allocated next-free.
9. STEP-3 HARD-FLOOR-UNBINDABLE deny (both missing-binding branches) + re-doc cap (3× → HARD-FLOOR-LIVELOCK-ABORT).
10. structural_label_check quote-aware + backslash-escape tokenizer; `--label=` equals-form scoped out.
11. Verdict schema is 17 mandatory fields (12 ICD-203 + severity + asset_type + ticket_action_type + native_severity + sensor_family); investigation markdown = 12 fields. Field-count propagated to BC-3.03.001, BC-10.01.001, prd-delta lines 197/223–226 (EXCEPT prd-delta 96/134 — see P11-006).
12. Review marker → unlabeled regular create blocked at consumer step 6a; create/create-review bidirectional anti-fungibility.
13. Marker-write failure: review path fail-closed (MARKER-WRITE-FAILED + deny, P10-003); regular path allow-without-marker.
14. Cron wrapper Gate 2 greps audit.log for fail-loud codes (incl. SEVERITY-MISMATCH, MARKER-WRITE-FAILED) → exit non-zero.
15. D-DEC-005 sensor-health carve-out: exempt ONLY when prism_sensor_health is the sole table reference.

Additions from pass 11:
16. **`native_severity`/`sensor_family` (fields 16/17) are written by the monitoring-loop LLM at Stage 1 INGEST and read verbatim by disposition-guard; the hooks make no prism call.** Therefore STEP 1a is a *consistency cross-check between two LLM fields*, not a ground-truth re-derivation. Any claim that the severity floor is "un-bypassable" is FALSE until ASM-008 hook-side prism severity cross-validation lands (P11-001).
17. **`verdict.severity` is pinned to `NORMALIZE_SEVERITY(native_severity, sensor_family)` by STEP 1a exact-equality** — it therefore CANNOT carry Stage-5 recalibration or the assess-priority scored priority; the scored priority has no verdict field and is not a hard-floor input (P11-002, P11-003).
18. **`sensor_family` enum = {crowdstrike, armis, claroty, cyberint}** — no `nvd` member; CVSS-derived severities cannot be re-normalized hook-side (P11-003).
19. **The investigation-markdown (12-field) emitter-entry is contradictory across BC-3.03.001 vs architecture-delta**, and validate_enums/STEP-1a reference verdict-only fields absent from markdown (P11-004). Not yet resolved.

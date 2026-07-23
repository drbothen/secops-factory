---
document_type: adversarial-review
pass: 14
producer: adversary
date: 2026-07-22
cycle: v0.10.0-feature-prism-integration
phase: f2
verdict: NOT CONVERGED — 2 MAJOR + 3 MINOR
---

# Adversarial Spec-Delta Review — Pass 14 (F2, prism-integration)

## Summary

This was dispatched as a potentially convergence-confirming pass. It is **not** clean. A genuine end-to-end coherence sweep surfaced two MAJOR defects that survived passes 6–13 because prior passes concentrated on the emitter (BC-3.03.001), the consumer (BC-3.01.001), and the index docs — not on whether the **loop-side** contract (BC-10.01.001) and the **verification roster** kept pace with the P11-003 and P13-002 remediations. Both MAJORs are propagation gaps of previously-"closed" findings landing in siblings that were never re-swept.

| ID | Title | Severity | Anchor |
|----|-------|----------|--------|
| P14-001 | P11-003 NVD/CVSS clean-separation never propagated to BC-10.01.001 Inv#9/#14 (loop spec still treats CVSS as native_severity) | **MAJOR** | BC-10.01.001 Inv#9 field-13 table L271, field-16 example L301, Inv#14 Stage-1 L547 |
| P14-002 | P13-002 CRITICAL setup-time `jira_project_key` charset validation has no covering VP | **MAJOR** | BC-6.01.001 PC#12/EC-014, BC-6.01.003 Inv#6/EC-010; verification-delta §8.28 item 4 |
| P14-003 | `PRISM-DEMO` residue in BC-3.01.001 current body — P13-002 rename not swept; contradicts "PRISMDEMO throughout" claim | **MINOR** | BC-3.01.001 L187–202, L404–406 (10+ occurrences) |
| P14-004 | Stale "17-field" in BC-10.01.001 authoritative Inv#9 + garbled "17-field … of 18" test vector | **MINOR** | BC-10.01.001 L249; BC-3.03.001 L825 |
| P14-005 | VP roster repurposing dropped coverage — VP-SKILL-053 (AD-017 onboard-customer) and VP-SKILL-057 changelog description stale | **MINOR** | BC-6.01.003 Inv#1/EC-008; spec-changelog [1.1.0] VP table |

---

## Critical Findings

None. No new LLM-value-bypass of a deterministic control (outside tracked ASM-008/ASM-015 deferrals) and no silent-failure in an auth gate were found. The markdown-path routing (P13-001) is complete and closed (see coverage narrative).

---

## Important Findings

### P14-001 — P11-003 NVD/CVSS clean-separation never propagated to the loop contract (BC-10.01.001) — MAJOR

**Anchor:** `BC-10.01.001.md` Invariant #9 field-13 NORMALIZE_SEVERITY table (line 271: `- NVD: CVSS float 0.0–10.0 → LOW…CRITICAL`), field-16 `native_severity` example (line 301: `examples: "100" for CrowdStrike, "HIGH" for Armis/Claroty, "8.5" for NVD CVSS`), and Invariant #14 Stage-1 INGEST description (line 547: `NVD CVSS float 0.0-10.0`). Secondary stale copy: `architecture-delta.md` lines 4286–4292 (pass-6 PO-instruction block, also still says "Cyberint COMPUTE-AT-VALIDATION").

**Description.** P11-003 (MAJOR, burst-7) established the NVD/CVSS clean separation: *"NVD/CVSS is not a sensor family; `native_severity`/`sensor_family` describe the ORIGINATING SENSOR only; CVSS influences `scored_priority` (Stage 5), NOT `native_severity`."* This is a **confirmed invariant** in the accumulated list (#10: "NVD/CVSS → scored_priority only"). The fix was applied to:
- `architecture-delta.md` §D-DEC-013 primary table, line 2752 ("NVD/CVSS row REMOVED");
- `BC-3.03.001.md` (emitter) — its `SENSOR_FAMILY_ENUM` (line 167) is `{crowdstrike,armis,claroty,cyberint}` and its STEP-1a delegates to the D-DEC-013 table with no NVD row;
- `prd-delta.md` Verdict Schema Summary field-16 (the "8.5 for NVD CVSS" example was explicitly removed per its own v1.13 changelog);
- `verification-delta.md` (VP-HOOK-030 CVSS-float SEVERITY-MISMATCH vector removed, line 1791).

It was **not** applied to `BC-10.01.001.md` — the authoritative loop contract that `prd-delta §4`/`§6` names as *"the authoritative field list."* The result is a live contradiction:
- Field-17 `sensor_family` enum (line 304) is `{crowdstrike|armis|claroty|cyberint}` — **NVD is not a member**, so `NORMALIZE_SEVERITY(native_severity, sensor_family)` can never be invoked with `sensor_family="NVD"`. The NVD row in the field-13 table (line 271) is therefore **unreachable and misleading**.
- `native_severity` is by definition the originating sensor's raw value; the "8.5 for NVD CVSS" example (line 301) describes a value that cannot occur, and directly re-introduces exactly the CVSS-as-native_severity confusion P11-003 eliminated.
- BC-10.01.001's own field-16 example is now **divergent from its sibling BC-3.03.001** and from `prd-delta` field-16, both of which use the corrected `{CrowdStrike "100", Armis/Claroty "HIGH", Cyberint "critical"}` set with no NVD.

**Failure scenario.** An implementer builds monitoring-loop Stage-1 INGEST from BC-10.01.001 Invariant #14 (line 547) and Invariant #9 (line 271). They wire a `NORMALIZE_SEVERITY` branch that maps NVD CVSS floats into `severity`, and treat an enrichment CVSS as a `native_severity`. disposition-guard STEP-1a (built from BC-3.03.001, which has no NVD branch and rejects any `sensor_family ∉ {4 sensors}`) then either (a) denies the verdict with `SEVERITY-MISMATCH`/enum-membership deny on the fabricated NVD family, or (b) if the loop coerces `sensor_family` to a real sensor while carrying a CVSS-derived `native_severity`, the recomputed severity diverges and every such verdict is denied. Either way CVSS is double-counted (once mis-fed into `severity`, again correctly into `scored_priority` at Stage 5), and the two BCs that must agree on the D-DEC-013 table do not. This is a cross-artifact contradiction on a security-relevant normalization function.

**Not a tracked deferral.** ASM-008 covers the *LLM-supplied-ness* of `native_severity`; it does not cover the NVD-row contradiction, which is a distinct, adjacent spec-drift defect.

**Remediation.** Remove the `NVD: CVSS …` row from BC-10.01.001 Invariant #9 field-13 table (line 271); replace the field-16 example (line 301) with the corrected set used by BC-3.03.001/prd-delta (`"100" CrowdStrike, "HIGH" Armis/Claroty, "critical" Cyberint`); remove `NVD CVSS float 0.0-10.0` from Invariant #14 Stage-1 (line 547). Add a `> **P11-003 clean separation:** CVSS feeds scored_priority (field 18) at Stage 5, never native_severity/severity` note. Apply/annotate the same removal (and the P7-006 Cyberint update) to the superseded pass-6 ledger block at architecture-delta lines 4286–4292, or add a `[SUPERSEDED — P11-003/P7-006]` banner.

---

### P14-002 — P13-002 CRITICAL setup-time key validation has no covering verification property — MAJOR

**Anchor:** `BC-6.01.001.md` Postcondition #12 + EC-014 (activate-side charset validation); `BC-6.01.003.md` Invariant #6 + EC-010 (onboard-customer-side charset validation); `verification-delta.md` §8.28 item 4 (lines 2271–2272) and VP roster (lines 658–660, 1264–1265).

**Description.** P13-002 was graded **CRITICAL** and is the fix that protects the RC-gating demo: it added a fail-early `^[A-Z][A-Z0-9]+$` charset gate to **both** `activate` (BC-6.01.001 PC#12/EC-014) and `onboard-customer` (BC-6.01.003 Inv#6/EC-010) so a hyphenated key (the natural `PRISM-DEMO`) is rejected at setup rather than causing `PROJECT-KEY-CHARSET-DENY` → `HARD-FLOOR-UNBINDABLE` livelock on every marker at runtime. The **runtime** deny is covered by VP-HOOK-032 (SM-48/SM-49). But the **setup-time gate itself has no VP**:
- BC-6.01.001 has only VP-SKILL-051 (version gate), which verification-delta line 1264 scopes to `EC-008..012` — explicitly **not** EC-013/EC-014.
- BC-6.01.003 has only VP-SKILL-052 (UUID) and VP-SKILL-053 (idempotent dir) — neither covers EC-010.
- verification-delta §8.28 item 4 explicitly labels the setup-time validation a product-owner/architect **BODY** obligation with no VP allocated.

**Failure scenario.** A future edit or a from-scratch SKILL.md implementation omits the setup-time prompt/validation in `activate`. No VP or mutant fails. A demo operator (following brief §4.1/§4.5, which historically said `PRISM-DEMO`) configures a hyphenated key; it is stored; the first hard-floor verdict hits `PROJECT-KEY-CHARSET-DENY`, the loop re-documents into a HARD-FLOOR-UNBINDABLE loop (bounded to the re-doc cap, then aborts), and the RC-gate demo cannot write a single Jira ticket. The whole point of P13-002 (fail *early*, not fail *closed forever at runtime*) is unverified.

**Remediation.** Add a VP (VP-SKILL namespace — sibling of VP-SKILL-051, per verification-delta's own "wrapper helper" precedent) asserting: activate and onboard-customer reject a non-`^[A-Z][A-Z0-9]+$` `jira_project_key` at setup with a user-facing error and no partial state write (EC-014 / EC-010). Allocate a paired mutant (setup-time-charset-validation-removed). Add the VP anchor to BC-6.01.001 PC#12 and BC-6.01.003 Inv#6.

---

## Observations / Minor Findings

### P14-003 — `PRISM-DEMO` residue in BC-3.01.001 current body — MINOR
**Anchor:** `BC-3.01.001.md` tokenizer comments (lines 187, 189, 196, 202) and canonical test vectors (lines 404, 405, 406; plus omitted long lines 298, 378–380, 402–403, 407–408, 421). The P13-002 remediation claims (spec-changelog line 23 "corrected to PRISMDEMO throughout"; verification-delta line 2336 "all 17 current-body `PRISM-DEMO` references corrected to `PRISMDEMO`") assert a complete sweep. BC-3.01.001 — a tracked in-scope BC and the marker **consumer** — was never swept; it still carries 10+ current-body `--project PRISM-DEMO` occurrences.

Runtime impact is low (the consumer regex-matches `command_pattern` and is key-value-agnostic; it does not re-run charset validation). But: (a) the "throughout / all references corrected" completion claim is false; (b) these vectors describe markers the emitter can **never** issue post-P12-001 (PROJECT-KEY-CHARSET-DENY on any hyphenated key), so a chained emitter(`PRISMDEMO`)→consumer(`PRISM-DEMO`) integration fixture would mismatch; (c) it is exactly the "no residual PRISM-DEMO in current-body text" coherence class. Blast radius = 1 file → MINOR per partial-fix regression discipline. **Remediation:** rename `PRISM-DEMO`→`PRISMDEMO` (and `PRISM-DEMO-42`→`PRISMDEMO-42`) throughout BC-3.01.001 test vectors and tokenizer examples; update the P13-002 completion claim to include BC-3.01.001.

### P14-004 — stale field-count text in authoritative loop invariant — MINOR
**Anchor:** `BC-10.01.001.md` line 249 — Invariant #9 field-2 (`confidence`) parenthetical reads *"per-class split: investigation-markdown 12-field path / verdict-JSON **17-field** path"*. The authoritative count is **18** (field-18 `scored_priority` added in P11-002); the same invariant enumerates fields 1–18 immediately below. This is a residual "17" in the current body of the authoritative field list. Secondary: `BC-3.03.001.md` line 825 test vector reads *"(17-field verdict missing field 16 of 18)"* — internally garbled 17/18 phrasing (the row's category correctly says "18-field validation"). **Remediation:** `17-field` → `18-field` at BC-10.01.001 L249; rewrite BC-3.03.001 L825 parenthetical to "(field 16 of the 18-field verdict schema)".

### P14-005 — VP-ID repurposing dropped/staled coverage — MINOR (traceability + minor verification gap)
**Anchor:** spec-changelog [1.1.0] "New Verification Properties" table vs current definitions.
- **VP-SKILL-053** was originally "onboard-customer: credential provisioning instructions (AD-017 — no credential-in-chat)"; it is now (BC-6.01.003 / verification-delta L660) "idempotent directory creation." Consequently onboard-customer **Invariant #1 (AD-017 never-ask-credentials-in-chat)** and **EC-008 (decline credential entry)** now have **no covering VP**. (onboard-sensor's AD-017 is covered by VP-SKILL-054; onboard-customer's is not. Risk is lower because onboard-customer defers credentials to onboard-sensor, but it is a spec'd behavior with no VP.)
- **VP-SKILL-057** was originally "sensor-metrics: org_slug scoping invariant (no cross-tenant data)"; it is now "sensor-metrics naming compliance (D-DEC-006)." The repurposing is *defensible* (P9-005 exempted `prism_sensor_health` from org_slug scoping, so the original property would now contradict BC-8.02.001 Invariant #2), but the spec-changelog [1.1.0] body still advertises the old, now-contradictory meaning.

**Remediation:** either add a VP anchor for onboard-customer AD-017 (Invariant #1/EC-008) or explicitly document that it inherits VP-SKILL-054's pattern; annotate the spec-changelog [1.1.0] VP table where VP-SKILL-053/057 were repurposed (a VP ID silently changing its entire meaning is a traceability hazard).

### Observation (doc-hygiene, no grade)
- `architecture-delta.md` lines 4286–4292 is a pass-6 PO-instruction ledger block still showing the pre-P11-003 NVD row **and** the pre-P7-006 "Cyberint COMPUTE-AT-VALIDATION" value. Add a `[SUPERSEDED — P7-006/P11-003]` forward-link banner (consistent with the P8-OBS-1 banner discipline).
- `BC-3.03.001.md` line 877 Brownfield "Evidence Types Used" says *"15-key JSON key-presence validation … 15 fields after v1.8"* — this is version-tagged historical (v1.6/v1.8) and thus defensible, but a reader scanning for current counts could be misled; consider appending "(now 18 — see Invariant #9)."

---

## Confirmed-Intact Spot-Checks (concentrated elsewhere per mandate)

- **Markdown-path completeness (burst-9 P13-001).** Verified no disposition falls through to neither allow-without-marker nor review: Gate-1 (autonomy absent/false/code-fence) → allow-without-marker; Gate-2 (Indeterminate / T1003·T1068·T1021·T1041 / degraded·silent) → deny; FP → allow-without-marker (no autonomous comment marker; no Jira action authorized — require-review still denies any unmarked write); TP/BTP/PARSE_FAIL → review marker. FP allow-without-marker cannot enable any unintended loop Jira action (BC-10.01.001 L830; BC-3.03.001 VP-HOOK-031 vectors L848). **Intact.**
- **Per-org/global key fallback × setup-time validation.** BC-6.01.003 Inv#6 lookup order (per-org → global → HARD-FLOOR-UNBINDABLE) is coherent; both per-org (onboard-customer) and global (activate) keys are independently charset-validated; no unvalidated path found. (The only gap is the *verification* of these gates — P14-002, not the logic.) **Logic intact.**
- **Two-field severity model, enum tokens.** `severity ∈ {LOW,MEDIUM,HIGH,CRITICAL}` (detector-native), `scored_priority ∈ {CRIT,HIGH,MED,LOW}` (Stage-5), `SEVERITY_TO_SCORED_PRIORITY_MAP` (CRITICAL→CRIT etc.), floor keyed on `scored_priority`, known-FP fast-path exempt. No CRIT/CRITICAL token confusion found in current bodies. **Intact.**
- **VP/mutant totals.** verification-delta reconciles to 35 VPs (9 VP-HOOK 024–032 + 26 VP-SKILL) / 47 mutants (SM-9..SM-53), with the pass-9 "31/6-hook" figure correctly annotated `[HISTORICAL — SUPERSEDED]`. Arithmetic self-consistent. **Intact.**
- **Least-attacked BCs.** BC-4.02.001 (never-auto-reopen VP-SKILL-066, SLA-surface VP-SKILL-067, P11-004 markdown-evaluable-only hard-floor list) — coherent. BC-6.01.004 (AD-017 piped-stdin VP-SKILL-054, SELECT-1 VP-SKILL-055, --config-dir isolation) — coherent. BC-9.01.001 (prism_describe-first, org_slug scoping, predefined-queries-only injection guard, MED default) — coherent. No new defects in these three beyond the roster issue in P14-005.
- **STEP-1a consistency-only reframe (P11-001), unbindable-deny (P8-001), DENY-THE-WRITE (P7-001), JSON-first dispatch (P4-001), quote/backslash-aware tokenizer (P8-002/P9-001).** Spot-checked in current bodies; all present and self-consistent.

---

## Novelty Assessment

**Novelty: MEDIUM-HIGH — genuinely new gaps, not re-treads.** Both MAJORs are first-surfaced here and neither is on the verified-intact list nor a tracked deferral. They share a signature the prior 13 passes structurally under-weighted: **remediations that were declared "closed" but whose propagation into a sibling artifact was never audited** — P11-003 landed everywhere except the loop contract BC-10.01.001; P13-002's runtime leg got VP-HOOK-032 but its setup-time leg (the CRITICAL fix) got no VP; P13-002's rename claimed "throughout" but skipped the consumer BC-3.01.001. This is exactly the partial-fix / sibling-propagation failure mode the review discipline warns about, and it validates the fresh-context compounding-value premise: the drift is invisible to index-level and emitter/consumer-focused checks. **Convergence is NOT confirmed.** The package needs one more remediation burst (P14-001/002 at minimum) before a clean pass is achievable.

---

## Updated Confirmed Invariants (monotonic; carry forward)

1–11: All eleven independently-verified-intact invariants from the dispatch list re-confirmed this pass (marker schema v2.1; JSON-first dispatch; two-field severity model; emitter STEP order 1→1a→2→3→4→5→6; 18-field verdict / 12-field markdown; command_pattern interpolation safety at 5 sites with PRISMDEMO hyphen-free; markdown human-comment path GATE-1 + strict parse grammar + FP→allow-without-marker; consumer iterative-consume + anti-fungibility 6a; STEP-3 HARD-FLOOR-UNBINDABLE deny + re-doc cap; sensor-silence direction + D-DEC-005 carve-out + **NVD/CVSS→scored_priority only**; VP/SM namespace 35 VPs/47 mutants).
12. **[NEW, pass-14]** The D-DEC-013 NORMALIZE_SEVERITY table is authoritative ONLY over `sensor_family ∈ {crowdstrike,armis,claroty,cyberint}`; NVD/CVSS is NOT a sensor_family and MUST NOT appear as a NORMALIZE_SEVERITY row or `native_severity` example in ANY artifact. **Currently VIOLATED in BC-10.01.001 (P14-001).**
13. **[NEW, pass-14]** Every CRITICAL-graded remediation must be verified end-to-end: a fix with a runtime-deny VP but no setup-time/preventive-gate VP is incompletely covered. **Currently VIOLATED for P13-002 setup-time validation (P14-002).**
14. **[NEW, pass-14]** A VP ID must not be silently repurposed to a different property without annotating the change at its origin record; repurposing must not orphan the behavior it originally covered (AD-017 onboard-customer, P14-005).

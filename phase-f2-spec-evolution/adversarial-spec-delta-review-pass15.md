---
document_type: adversarial-review
pass: 15
producer: adversary
date: 2026-07-23
cycle: v0.10.0-feature-prism-integration
phase: f2
verdict: NOT CLEAN — 1 MAJOR, 2 MINOR, 2 OBSERVATION
---

# Adversarial Spec-Delta Review — Pass 15 (Convergence Candidate)

## Summary Table

| ID | Title | Severity | Anchor |
|----|-------|----------|--------|
| P15-001 | Consumer BCs still describe the eliminated markdown comment-marker mechanism (P13-001 not propagated to BC-4.02.001 / BC-5.01.001) | **MAJOR** (pattern; blast radius 2) | BC-4.02.001 PC#4 + footer; BC-5.01.001 Invariant #7 + footer |
| P15-002 | Stale "15-field" JSON-path count in BC-3.03.001 current-body Evidence Types (sibling line updated to v1.10, this one frozen at v1.8) | MINOR | BC-3.03.001 §"Evidence Types Used" line 878 |
| P15-003 | prd-delta §1 VP-status snapshot internally inconsistent: four new-BC rows still show `(PROPOSED)` and omit VP-SKILL-076/077 while the BC-10.01.001 row was updated to FINALIZED | MINOR | prd-delta.md §1 table (rows for BC-6.01.003/004, BC-8.02.001, BC-9.01.001) |
| P15-004 | scan-threats severity grouping uses scored_priority tokens (CRIT/MED) with no defined normalization from prism-native severity encodings | OBSERVATION | BC-9.01.001 Description L39 / PC#5 |
| P15-005 | VP-HOOK-031 version citations in the two consumer BCs point at verification-delta v1.14 (pre-P13-001 rewrite at v1.16) | OBSERVATION (folds into P15-001) | BC-4.02.001 PC#4; BC-5.01.001 Inv#7 |

This is **not** a clean pass. The package is very close, but P15-001 is a genuine, un-deferred cross-document contradiction with a concrete behavioral consequence, discovered fresh this pass.

---

## Critical Findings

None.

---

## Major Findings

### P15-001 — Consumer BCs still describe the eliminated markdown comment-marker mechanism — MAJOR (pattern flag; blast radius = 2 sibling BCs)

**Anchors:**
- Emitter (current, authoritative): `BC-3.03.001.md` v1.22, "Separate Human-Comment Marker Path (P11-004 / redesigned P12-002)" lines ~675–736; line 729 (`# FP: allow-without-marker`); line 783 (`Previous (v1.20) route rule ... The v1.21 change per P13-001: MARKDOWN_COMMENT_PATH eliminated; FP now → allow-without-marker`).
- Consumer 1 (stale): `BC-4.02.001.md` v1.9, PC#4 (line 58) and DI-013-RESOLVED footer (line 168).
- Consumer 2 (stale): `BC-5.01.001.md` v1.9, Invariant #7 (line 105) and DI-013-RESOLVED footer (line 195).

**Description.** Pass-13/P13-001 (CRITICAL, human-authorized) ELIMINATED `MARKDOWN_COMMENT_PATH` in the disposition-guard emitter. The current, authoritative markdown routing in BC-3.03.001 v1.22 is:
- `parsed_disposition == "FP"` → **allow-without-marker** (Write succeeds; **no comment marker written**; no Jira action authorized);
- `parsed_disposition != "FP"` or PARSE_FAIL → **MARKDOWN_REVIEW_PATH** (create-review / comment-review marker — **not** a plain `comment` marker);
- markdown-evaluable hard floor → MARKDOWN-HARD-FLOOR deny.

A plain `comment`-scoped marker is therefore **never** issued from the 12-field investigation-markdown path anymore. (It survives only on the 18-field verdict-JSON path via STEP 6, e.g. BC-3.03.001 canonical vector line 814.)

But the two direct consumers of that path were frozen at v1.9 (pass-11) and were **not** touched at pass-13 or pass-14 (confirmed against spec-changelog burst-9/burst-10 file lists — neither BC appears). They still assert the pre-P13-001 mechanism verbatim:

- **BC-4.02.001 PC#4:** "disposition-guard … issues a **comment-scoped marker** … via the Separate Human-Comment Marker Path (P11-004) after ICD-203 12-field validation + markdown-evaluable hard-floor check; require-review … **consumes the marker to allow `jr issue comment`**."
- **BC-5.01.001 Invariant #7:** "…disposition-guard **writes a comment-scoped marker** to `${CLAUDE_PLUGIN_DATA}/markers/`. Require-review … consumes this marker to allow `jr issue comment`. … An analyst saving a compliant 12-field investigation with non-Indeterminate disposition, no forbidden techniques, and healthy sensor **MUST NOT be denied.**"

Both DI-013-RESOLVED footers repeat "marker-gated via D-DEC-001 using the Separate Human-Comment Marker Path (P11-004)" with no P13-001 reconciliation.

**Concrete failure scenario.** A formal-verifier or story-writer building `investigate-event` (BC-5.01.001) tests directly from Invariant #7 writes: *"compliant 12-field investigation, disposition=FP, healthy sensor → disposition-guard emits a `comment` marker → require-review allows `jr issue comment`."* Executed against a hook built to the authoritative BC-3.03.001 v1.22 contract, disposition-guard returns **allow-without-marker** (no marker), require-review then finds no marker and **denies** `jr issue comment` (fall-through to human permission dialog). The test asserting the comment is auto-authorized FAILS, and the "MUST NOT be denied" postcondition is literally violated at the jr-comment step. Two BCs specify a Jira-write authorization mechanism that the emitter BC says does not exist — a direct spec-vs-spec contradiction on a security-relevant write path.

**Why it survived 14 passes.** Prior passes anchored their P13-001 remediation to the emitter (BC-3.03.001) and its verifier (VP-HOOK-031), plus the arch/prd/changelog docs; the two *consumer* BCs that name the path as their authorization mechanism were outside each pass's fix radius. This is exactly the Partial-Fix Regression pattern (primary fixed, siblings not propagated; blast radius 2 → HIGH/MAJOR).

**Remediation.**
1. Rewrite BC-4.02.001 PC#4 and BC-5.01.001 Invariant #7 to the post-P13-001 model: markdown path issues **no** plain `comment` marker; FP → allow-without-marker (the enrichment/investigation comment is then gated by human permission-approval, since no marker exists); non-FP/PARSE_FAIL → review marker; hard floor → MARKDOWN-HARD-FLOOR deny. Reconcile the "MUST NOT be denied" sentence to "the Write MUST NOT be denied; the subsequent `jr issue comment` is not auto-authorized and falls to human approval."
2. Update both DI-013-RESOLVED footers with a `reconciled v1.10/P13-001` note.
3. Bump both BCs and record in prd-delta §5 + spec-changelog with a P15-001 root-finding row.
4. Refresh the VP-HOOK-031 citation version in both BCs (see P15-005).

---

## Minor Findings

### P15-002 — Stale "15-field" JSON-path count in BC-3.03.001 current-body Evidence Types — MINOR

**Anchor:** `BC-3.03.001.md` v1.22, "Evidence Types Used" section, line 878:
`- **guard clause (v1.6/v1.8)**: 15-key JSON key-presence validation for verdict files (JSON path — 15 fields after v1.8 addition of severity/asset_type/ticket_action_type)`.

**Description.** The immediately-preceding sibling bullet (line 877) was kept current — it reads "(v1.6/v1.10) … 12 fields; v1.10 artifact-class branching." The JSON-path bullet was frozen at the v1.8 15-field state and never advanced through the 15→17 (P10-001) → 18 (P11-002) expansions. Pass-14/P14-004 explicitly swept `"17-field"→"18-field"` but did not reach this older `15-field` residue. This is precisely a mandate sweep target ("no residual 17-field/15-field in current bodies"). It is a source-evidence/extraction note, not a normative PC/Invariant, hence MINOR — but it is a live-body count that now understates the JSON validation by 3 fields and contradicts PC#1/Invariant #9 (18).

**Remediation.** Update to "(v1.6/v1.8/v1.18/v1.19): 18-key JSON key-presence validation … (15 at v1.8 → 17 at v1.18/P10-001 → 18 at v1.19/P11-002)."

### P15-003 — prd-delta §1 VP-status snapshot internally inconsistent — MINOR

**Anchor:** `prd-delta.md` §1 "New Behavioral Contracts" table, rows for BC-6.01.003, BC-6.01.004, BC-8.02.001, BC-9.01.001 (lines 37–40).

**Description.** These four rows still show their VPs as `(PROPOSED)` (e.g., "VP-SKILL-054 (PROPOSED), VP-SKILL-055 (PROPOSED)"), but the corresponding BC files carry them as FINALIZED (BC-6.01.004 v1.1 "dropped `(PROPOSED)`"; BC-9.01.001 v1.1 likewise), and verification-delta v1.18 lists all as FINALIZED/ACCEPTED. The §1 rows also do not reflect VP-SKILL-076/077 now anchored in BC-6.01.003. The document defends this with "VP roster (§1) NOT touched — VP changes are FV-owned," **yet the BC-10.01.001 row in the same §1 table was updated to the full FINALIZED set** (changelog v1.6/v1.8). So §1 is internally inconsistent: one row maintained, four frozen. A reader consulting §1 for VP status on the four skill BCs gets a stale answer. MINOR (documentation coherence, not a behavioral gap).

**Remediation.** Either (a) freeze §1 uniformly as an authoring snapshot and revert the BC-10.01.001 row to its authoring state, or (b) bring all five rows current. Option (b) is preferable and consistent with how BC-10.01.001 was handled.

---

## Observations

### P15-004 — scan-threats severity grouping has no defined native-severity normalization — OBSERVATION

`BC-9.01.001.md` Description (L39) and PC#5 (L74–76) group findings into "CRIT, HIGH, MED, LOW" (the scored_priority token set) and default missing severities to MED. But scan-threats never invokes Stage-5 scoring (it is proactive hunting), and prism sensor tables emit native encodings (CrowdStrike numeric, Armis/Claroty "HIGH", Cyberint "critical" per D-DEC-013). No mapping from native encodings to CRIT/HIGH/MED/LOW is specified, and these tokens differ from NORMALIZE_SEVERITY's output set {LOW,MEDIUM,HIGH,CRITICAL} (CRIT≠CRITICAL, MED≠MEDIUM). An implementer cannot deterministically bucket findings from this contract. Low impact (MEDIUM-criticality, non-autonomous, no hard-floor keys on it), hence OBSERVATION — but worth a one-line PC#5 note pointing at a normalization source or explicitly stating "presentation-only bucketing; tokens are scored_priority-style."

### P15-005 — Stale VP-HOOK-031 version citations in consumer BCs — OBSERVATION (folds into P15-001)

Both BC-4.02.001 PC#4 and BC-5.01.001 Invariant #7 cite "VP-HOOK-031 (FINALIZED P0 per verification-delta.md **v1.14**)". VP-HOOK-031 guarantee (c) was rewritten at verification-delta **v1.16** (P13-001) and is current at v1.18. Fix alongside P15-001.

---

## Coherence-Sweep Results

| Sweep axis | Result |
|-----------|--------|
| Verdict field count = 18 everywhere in current bodies | PASS in normative PCs/Invariants (BC-3.03.001 PC#1, BC-10.01.001 Inv#9, prd-delta Verdict Schema Summary all = 18). One non-normative residual → **P15-002 (15-field)**. No residual "17-field" in current bodies (P14-004 swept). |
| PRISMDEMO consistency; no residual `PRISM-DEMO` hyphen-form | PASS. All current-body test vectors in BC-3.01.001/BC-3.03.001/BC-10.01.001 renamed at v1.22/v1.18. Remaining `PRISM-DEMO` occurrences are (a) intentional invalid-key examples (BC-6.01.001 EC-014, BC-3.03.001 L779 constraint note, arch-delta error-message text) or (b) append-only revision-history/changelog entries — all acceptable. |
| VP count = 37 (9 VP-HOOK 024–032 + 28 VP-SKILL 001–077) | PASS. verification-delta v1.18 reports 37 consistently; arithmetic 9+28=37 holds. |
| SM count = 48 (SM-9..SM-54, SM-32 = a+b+ext; SM-55 skipped) | PASS. Consistent across verification-delta v1.18. |
| VP-SKILL-076 / 077 cited distinctly; no combined P14-002/P14-005 cite | PASS. BC-6.01.003: VP-SKILL-076 → Inv#6/EC-010 (setup-time charset), VP-SKILL-077 → Inv#1/EC-008 (AD-017 decline). verification-delta disentanglement clean. spec-changelog [1.1.0] burst-10-followup records the correction. |
| Enum tokens: scored_priority {CRIT,HIGH,MED,LOW} vs native severity {LOW,MEDIUM,HIGH,CRITICAL}; SEVERITY_TO_SCORED_PRIORITY_MAP | PASS in the verdict/hook contracts (BC-10.01.001 L313/L563 + map CRITICAL→CRIT, MEDIUM→MED). One presentation-layer token drift in scan-threats → **P15-004** (OBS). |
| NVD/CVSS clean separation (CVSS→scored_priority only, never native_severity; NVD not a sensor_family) | PASS. P14-001 removed the NVD NORMALIZE_SEVERITY row + "8.5 CVSS" field-16 example from BC-10.01.001; prd-delta field-16 example cleaned. |
| Kill-switch Option A (create-review/comment-review exempt; STEP 3/4 fire regardless of autonomy_enabled) | PASS. brief §3.9 amendment, BC-3.03.001 STEP 3/4, BC-10.01.001 Inv#11 carve-out all aligned. |
| STEP-3 HARD-FLOOR-UNBINDABLE deny + STEP-4 DENY-THE-WRITE + re-doc cap | PASS. BC-3.03.001 v1.16/v1.17 + BC-10.01.001 loop re-doc obligation coherent. |
| Markdown human-comment path (VP-HOOK-031) emitter behavior | PASS in emitter (BC-3.03.001). **FAIL in consumers** (BC-4.02.001/BC-5.01.001) → **P15-001**. |
| BC H1 ↔ subsystem ↔ capability anchoring (sampled BC-3.01.001, 4.02.001, 6.01.003, 6.01.004, 9.01.001) | PASS. No mis-anchoring; capability/subsystem labels semantically match H1 scope. |
| Least-attacked BCs (BC-4.02.001, BC-6.01.004, BC-9.01.001) deep read | BC-6.01.004 clean (AD-017 template + `--config-dir` isolation + SELECT-1 gate internally consistent). BC-9.01.001 clean except P15-004. BC-4.02.001 → P15-001. |
| Known deferrals not re-reported | Confirmed: ASM-008 (native_severity/sensor_family/asset_type/scored_priority LLM-supplied), ASM-015, ASM-014, DI-015 all left as tracked residuals; not re-graded. |

---

## Novelty Assessment

**Novelty: MODERATE — one substantive NEW gap, not a rewording of prior findings.**

P15-001 is a genuinely new cross-document contradiction: every prior pass fixed the P13-001 emitter and its verifier, but no pass checked the two *consumer* BCs that name the eliminated mechanism as their authorization path. Fresh context surfaced it via a consumer-side re-derivation the emitter-anchored passes structurally could not perform. P15-002 is a residual older than the P14-004 sweep's scope. P15-003/P15-004/P15-005 are minor/observational coherence warts.

The package is at high maturity: field counts, VP/SM totals, PRISMDEMO, enum tokens, NVD separation, kill-switch, unbindable/deny-the-write, and VP-076/077 disentanglement are all coherent. **This pass does NOT converge** solely because P15-001 is a real MAJOR spec-vs-spec contradiction on a Jira-write authorization path (and P15-002/P15-003 are legitimate MINOR coherence defects). Recommend one remediation burst (BC-4.02.001 + BC-5.01.001 P13-001 reconciliation + the two MINOR sweeps), after which a genuine clean pass is likely.

---

## Confirmed Invariants (carried forward + this pass)

All 11 prior-pass invariants re-verified intact this pass (spot-checked, no regressions):
1. Marker schema v2.1 in sync (BC-3.03.001 emitter / D-DEC-001). ✓
2. JSON-first dispatch precedes investigation-*.md glob; verdict-*.json → 18-field class; investigation-*.md → separate human-comment path. ✓
3. Two-field severity model: verdict.severity detector-native (STEP-1a consistency-check); scored_priority (field 18, {CRIT|HIGH|MED|LOW}) Stage-5; §3.9 floor keys on scored_priority; fast-path SEVERITY_TO_SCORED_PRIORITY_MAP (CRITICAL→CRIT, MEDIUM→MED); known-FP exempt; NVD→scored_priority only. ✓
4. Emitter order STEP 1→1a→2→3→4→5→6; STEPs 1a/3/4 fire regardless of autonomy_enabled. ✓
5. 18-field verdict / 12-field investigation split. ✓ (one non-normative 15-field residue → P15-002)
6. command_pattern interpolation safety (O7, VP-HOOK-032 + VP-SKILL-076); ticket_id/jira_project_key charset-validated + regex-escaped at 5 sites; PRISMDEMO hyphen-free. ✓
7. MARKDOWN human-comment path (VP-HOOK-031): NO disposition yields autonomous comment marker; FP→allow-without-marker; non-FP/PARSE_FAIL→review; strict parse grammar. ✓ **in emitter; consumer BCs stale → P15-001.**
8. Consumer iterative-consume ordering, audit path, base64 + control-char stripping; create/create-review anti-fungibility at step 6a; quote+backslash-aware structural_label_check. ✓
9. STEP-3 HARD-FLOOR-UNBINDABLE deny + re-doc cap (3×→ABORT); marker-write failure review-path fail-closed; cron Gate 2 audit grep. ✓
10. Sensor-silence direction (last_seen_ts < now()-24h); D-DEC-005 sensor-health carve-out. ✓
11. VP/SM namespace collision-free: 37 VPs (9 VP-HOOK 024–032 + 28 VP-SKILL 001–077), 48 SM (SM-9..SM-54); VP-SKILL-076 (setup-time key charset, P14-002) and VP-SKILL-077 (onboard-customer AD-017 decline, P14-005) DISTINCT, no combined cite. ✓

New invariant confirmed this pass:
12. Enum-token partition holds across all verdict/hook contracts (CRIT≠CRITICAL, MED≠MEDIUM enforced by SEVERITY_TO_SCORED_PRIORITY_MAP); sole drift is scan-threats presentation grouping (P15-004, non-blocking).

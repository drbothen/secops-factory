---
document_type: consistency-audit
phase: f2
producer: consistency-validator
date: 2026-07-23
cycle: v0.10.0-feature-prism-integration
---

## Consistency Validation Report — F2 Spec-Evolution Delta Package (v0.10.0-feature-prism-integration)

**Validator:** consistency-validator  
**Package version:** architecture-delta v1.17, verification-delta v1.18, prd-delta v1.16, dtu-assessment v1.1; BCs at versions confirmed below  
**Date:** 2026-07-23  
**Method:** Exhaustive cross-document read of all 10 in-scope files, targeted grep-level audit of stale version cites, VP counts, enum tokens, demo key, dispatch semantics, and deferral flags

---

### Per-Axis Summary Table

| Axis | Description | Result | Findings |
|------|-------------|--------|----------|
| 1 | Field Counts (18-field verdict / 12-field markdown) | PASS | — |
| 2 | Version Cross-References | FAIL | CV-001, CV-002, CV-003, CV-004, CV-005, CV-006, CV-011, CV-012 |
| 3 | VP/SM Counts + Namespace | FAIL | CV-007, CV-008 |
| 4 | Enum Tokens (scored_priority / severity enums; SEVERITY_TO_SCORED_PRIORITY_MAP) | PASS | — |
| 5 | Demo Key (PRISMDEMO hyphen-free) | PASS | — |
| 6 | NVD/CVSS Separation (NVD not in SENSOR_FAMILY_ENUM; CVSS feeds scored_priority at Stage 5 only) | PASS | — |
| 7 | Markdown-Path Semantics (Gate 1 first; FP→allow-without-marker; MARKDOWN_COMMENT_PATH eliminated) | PASS | — |
| 8 | Cross-BC Contract Coherence (emitter↔consumer↔loop; marker lifecycle; STEP order; hard-floor keys) | PASS | — |
| 9 | Traceability / Anchoring | FAIL | CV-009, CV-010 |
| 10 | Tracked Deferrals (ASM-008/014/015 flagged consistently; DI-015 not contradicted) | PASS | — |

**Blocking findings: 0. MAJOR findings: 2 (CV-001, CV-002). MINOR findings: 9. COSMETIC findings: 1.**

---

### Axis 1 — Field Counts: PASS

All in-scope artifacts consistently state 18 mandatory fields for the verdict JSON (fields 1-12 baseline + severity, asset_type, ticket_action_type, native_severity, sensor_family, scored_priority), and 12 ICD-203 fields for the investigation markdown. No artifact was found misquoting either count in a normative claim:

- architecture-delta §5 Decision Summary Table: "verdict schema: 18 mandatory fields" — correct
- BC-3.03.001 v1.24 PC#1/PC#2/PC#3: 18-field verdict / 12-field investigation — correct
- BC-10.01.001 v1.18 Invariant #9: 18 mandatory fields enumerated — correct
- prd-delta §4: "18 fields for verdict JSON" — correct

---

### Axis 2 — Version Cross-References: FAIL

Eight stale cross-version cites found across BCs and prd-delta. None are BLOCKING (no contract is semantically incorrect; all referenced content is functionally correct in later versions), but MAJOR-severity cites in BC-4.02.001 are 11 and 5 versions behind.

---

**CV-001 — MAJOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-4.02.001.md`  
**Location:** Precondition #1, line 45, live body text  
**Cite found:** "issued by disposition-guard (BC-3.03.001 v1.13) and consumed by require-review (BC-3.01.001 v1.17)"  
**Actual current versions:** BC-3.03.001 is v1.24; BC-3.01.001 is v1.22  
**Gap:** BC-3.03.001 is 11 versions stale (v1.13 → v1.24); BC-3.01.001 is 5 versions stale (v1.17 → v1.22)  
**Root cause:** IP-005 version-coherence sweep (BC-4.02.001 v1.8) updated PC#1 cross-refs to v1.13/v1.17 but no subsequent version-coherence sweep was applied; BC-4.02.001 went v1.8→v1.11 via structural changes (P11-004, P15-001, P16-001) without re-running the version-coherence pass on PC#1's confidence citations  
**Fix:** Replace "BC-3.03.001 v1.13" with "BC-3.03.001 v1.24" and "BC-3.01.001 v1.17" with "BC-3.01.001 v1.22" in PC#1 body and confidence line

---

**CV-002 — MAJOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-4.02.001.md`  
**Location:** Precondition #5, line 51, live body text  
**Cite found:** "issued by disposition-guard (BC-3.03.001 v1.13) ... enforced at the infrastructure layer by require-review (BC-3.01.001 v1.17)"  
**Actual current versions:** BC-3.03.001 v1.24; BC-3.01.001 v1.22  
**Gap:** Same 11-version / 5-version staleness as CV-001; IP-005 sweep only touched PC#1/PC#4/PC#5 live-body cites once, and the subsequent v1.9–v1.11 bumps never re-swept  
**Fix:** Same as CV-001 — replace both stale version strings in PC#5

---

**CV-003 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-4.02.001.md`  
**Location:** Precondition #4 live body and confidence footnote  
**Cite found:** "BC-3.03.001 v1.23 Gate 1" and "BC-3.01.001 v1.17 PC#2" in the PC#4 confidence reference  
**Actual current versions:** BC-3.03.001 v1.24; BC-3.01.001 v1.22  
**Gap:** BC-3.03.001 is 1 version stale (v1.23 → v1.24; P16-003 corrected "15-field" to "18-field" in PC#1, no change to Invariant #4 content cited by PC#4); BC-3.01.001 is 5 versions stale  
**Root cause:** P15-001/P16-001 rewrote PC#4 but the confidence footnote's version cites were not refreshed  
**Fix:** Update "BC-3.03.001 v1.23" to "BC-3.03.001 v1.24"; update "BC-3.01.001 v1.17" to "BC-3.01.001 v1.22" in PC#4

---

**CV-004 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-5.01.001.md`  
**Location:** Invariant #7, line 115 (confidence footnote) and line 111 (Previous block)  
**Cite found:** "BC-3.01.001 v1.17 PC#2 (marker-validation allow path)"  
**Actual current version:** BC-3.01.001 v1.22  
**Gap:** 5 versions stale (v1.17 → v1.22); IP-005 sweep updated to v1.17, then BC-5.01.001 went v1.8→v1.11 (P11-004/P15-001/P16-001 rewrites) without re-sweeping  
**Note:** Functionally this cite is vestigial — under Gate-1-first human path (P16-001), no marker is issued for human-driven investigate-event writes, so BC-3.01.001 (require-review consumer) is not in the critical path for the invariant being described  
**Fix:** Update "BC-3.01.001 v1.17" to "BC-3.01.001 v1.22" in Invariant #7 confidence footnote

---

**CV-005 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-5.01.001.md`  
**Location:** Invariant #7, lines 107, 115, and 201 (DI-013-RESOLVED footer)  
**Cite found:** "BC-3.03.001 v1.23 Invariant #4" / "BC-3.03.001 v1.23 Gate 1" at three locations  
**Actual current version:** BC-3.03.001 v1.24  
**Gap:** 1 version stale (v1.23 → v1.24; P16-003 corrected a "15-field"→"18-field" parenthetical in PC#1 only; Invariant #4 Gate 1 content cited by BC-5.01.001 is semantically unchanged in v1.24)  
**Fix:** Update all three "BC-3.03.001 v1.23" occurrences in Invariant #7 and DI-013-RESOLVED footer to "BC-3.03.001 v1.24"

---

**CV-006 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-f2-spec-evolution/prd-delta.md`  
**Location:** §5 "Completed Modifications — Sub-Burst 2" table, line 119, "New Version" cell for BC-3.01.001  
**Value found:** "v1.21"  
**Actual current file version:** v1.22 (BC-3.01.001 was bumped v1.21→v1.22 at burst-10/P14-003: PRISM-DEMO→PRISMDEMO in tokenizer test vectors)  
**Root cause:** The prd-delta burst-10 post-note (line 139) recorded only BC-3.03.001 → v1.22 for P14-004; BC-3.01.001 → v1.22 (P14-003, same burst) was omitted from the post-note and the §5 "New Version" cell was never updated  
**Fix:** Update BC-3.01.001 "New Version" cell in prd-delta §5 from v1.21 to v1.22; append the P14-003 change summary to the row

---

**CV-011 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-f2-spec-evolution/prd-delta.md`  
**Location:** §5 table, line 122, "New Version" cell for BC-10.01.001  
**Value found:** "v1.17"  
**Actual current file version:** v1.18 (BC-10.01.001 was bumped v1.17→v1.18 at burst-10/P14-001: NVD NORMALIZE_SEVERITY row removed; Cyberint native_severity example corrected; P14-004 "17-field" → "18-field" parenthetical fix)  
**Root cause:** Same as CV-006 — prd-delta burst-10 post-note omitted BC-10.01.001 → v1.18 from its BC list; spec-changelog line 110 records the bump but prd-delta §5 was not updated  
**Fix:** Update BC-10.01.001 "New Version" cell in prd-delta §5 from v1.17 to v1.18; append P14-001/P14-004 change summary

---

**CV-012 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-f2-spec-evolution/prd-delta.md`  
**Location (a):** §5 table, line 125, "New Version" cell for BC-6.01.001 — value "v1.6"; actual file = v1.7  
**Location (b):** prd-delta's own burst-9 post-note, line 141, records "BC-6.01.001 → v1.7 (P13-002: setup-time jira_project_key charset validation added...)" — but the §5 "New Version" cell contradicts this with v1.6  
**Location (c):** spec-changelog line 144 claims "prd-delta v1.14→v1.15: BC-6.01.001 v1.6→v1.7 in §5 BC version table" — but the actual §5 cell still shows v1.6, indicating either the spec-changelog's description of prd-delta v1.15 was inaccurate, or the update was accidentally reverted when prd-delta v1.16 rewrote §5  
**Actual current file version:** BC-6.01.001 v1.7 (confirmed via frontmatter)  
**Root cause:** The prd-delta v1.16 §5 catch-up rewrite (catching up BC-4.02.001, BC-5.01.001, BC-3.03.001 v1.20→v1.23) appears to have reset BC-6.01.001's §5 cell back to v1.6 from the baseline snapshot used for the rewrite  
**Fix:** Update BC-6.01.001 "New Version" cell in prd-delta §5 from v1.6 to v1.7; append the P13-002 change summary; reconcile spec-changelog entry for prd-delta v1.15 to accurately reflect whether the §5 update was made

---

### Axis 3 — VP/SM Counts + Namespace: FAIL

Two stale VP-count references found; VP-SKILL-076/077 are confirmed DISTINCT and correctly separated. SM count is confirmed at 48 (SM-9..SM-54; SM-55 skipped). No ID collision.

---

**CV-007 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-f2-spec-evolution/prd-delta.md`  
**Location:** §1 module table, line 43, BC-10.01.001 row, "VP Refs" column  
**Observation:** VP-SKILL-075 (operator-boundary cron-exit-nonzero signal, FINALIZED P0 per verification-delta v1.13, P10-002 Gate 2 audit.log grep) is absent from the VP Refs list for BC-10.01.001.  
**Confirmed correct in:** BC-10.01.001 v1.18 VP table (line 674) and VP Anchors footer (line 688): VP-SKILL-075 is listed.  
**VP Refs column currently lists:** VP-HOOK-024/025/026/027/028/029, VP-SKILL-050, 060, 061, 062, 063, 064, 065, 068, 072 — 15 VPs total; should be 16  
**Root cause:** VP-SKILL-075 was allocated at burst-6/P10-002 (verification-delta v1.13). prd-delta's §1 VP roster was last updated for BC-10.01.001 at the IP-005 sweep (prd-delta v1.8, line 261 revision note), which predates VP-SKILL-075 by several bursts. The §1 update for P10-002 catch-up is present in prd-delta v1.10 revision entry (line 259) for VP-HOOK-029 but VP-SKILL-075 was missed  
**Fix:** Add VP-SKILL-075 (FINALIZED) to BC-10.01.001's VP Refs column in prd-delta §1

---

**CV-008 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-f2-spec-evolution/architecture-delta.md`  
**Location (a):** v1.16 changelog entry (line 9): "current total is VP-HOOK 024–032 (9 hooks) / 35 VPs"  
**Location (b):** §8.29 pass-13 propagation list (line 6096): "VP-HOOK range: 024–032 (9 hooks); current grand total: 35 VPs"  
**Observation:** Both uses of "current" are present-tense language in what are now historical completed sections. The actual current VP total at architecture-delta v1.17 + verification-delta v1.18 is 37 VPs (9 VP-HOOK-024..032 + 28 VP-SKILL-050..077). VP-SKILL-076 was added at burst-10/P14 (verification-delta v1.17) and VP-SKILL-077 was added at the burst-10 follow-up (verification-delta v1.18).  
**Root cause:** The v1.16 changelog entry used "current total" to mean "total as of this version." The §8.29 propagation list similarly used "current grand total" to mean "as of pass-13." Neither was annotated as historical after VP-SKILL-076 and VP-SKILL-077 were added.  
**Note:** The normative VP roster is in verification-delta (which correctly says 37 total at v1.18, line 245/2462). architecture-delta does not own the authoritative VP count — the misleading language is in historical sections.  
**Fix:** Annotate both occurrences: "current total is ... / 35 VPs" → "total as of v1.16: VP-HOOK 024–032 (9 hooks) / 35 VPs [SUPERSEDED — current total per verification-delta v1.18: 37 VPs = 9 VP-HOOK + 28 VP-SKILL]"

---

### Axis 4 — Enum Tokens: PASS

All in-scope artifacts consistently use:
- `SCORED_PRIORITY_ENUM = {"CRIT","HIGH","MED","LOW"}` for the verdict scored_priority field
- `severity` values: LOW / MEDIUM / HIGH / CRITICAL (detector-native, written to verdict field 13)
- `SEVERITY_TO_SCORED_PRIORITY_MAP`: CRITICAL→CRIT, MEDIUM→MED, HIGH→HIGH, LOW→LOW (used on known-FP fast-path; bridges SEVERITY_ENUM and SCORED_PRIORITY_ENUM)

No confusion between the two enums except in the intentional bridge map. No artifact uses {CRITICAL, MEDIUM} in a SCORED_PRIORITY_ENUM context. No artifact conflates the two scales in normative logic.

---

### Axis 5 — Demo Key: PASS

"PRISMDEMO" (hyphen-free, matching `^[A-Z][A-Z0-9]+$`) is used throughout all canonical test vectors and examples. Intentional invalid-key examples are correctly isolated:
- BC-6.01.001 EC-014: "PRISM-DEMO" used to demonstrate the hyphen-rejection invariant
- BC-3.03.001 fallback hint note: "PRISM-DEMO" used in context of explaining why hyphen-free is required

Both intentional exceptions are clearly framed as test-of-rejection examples, not canonical valid-key examples. The prism-integration-handoff-brief §4.1 and §3.5 correctly use PRISMDEMO with an explicit annotation.

---

### Axis 6 — NVD/CVSS Separation: PASS

All in-scope artifacts are clean:
- `SENSOR_FAMILY_ENUM = {"crowdstrike","armis","claroty","cyberint"}` — NVD is absent from this enum in all BCs, emitter pseudocode, and BC-10.01.001 Invariant #9 field-17 table
- BC-10.01.001 v1.18 Invariant #14 Stage-1 INGEST correctly states: "NVD/CVSS enrichment from enrich_nvd() feeds scored_priority (field 18) at Stage 5, NOT native_severity" (P11-003 clean-separation note confirmed present post-P14-001 NVD row removal)
- No artifact contains "NVD" as a NORMALIZE_SEVERITY sensor_family row (removed at P14-001/v1.18)
- architecture-delta D-DEC-013 NORMALIZE_SEVERITY: authoritative over {crowdstrike, armis, claroty, cyberint} only; NVD feeds Stage-5 scored_priority via enrich_nvd()
- verification-delta v1.17 confirms "the §6 clean-separation claim ('no verification-delta vector now references NVD/CVSS as a native_severity source') is now TRUE"

---

### Axis 7 — Markdown-Path Semantics: PASS

All five in-scope BCs that touch the markdown path (BC-3.03.001, BC-3.01.001, BC-10.01.001, BC-4.02.001, BC-5.01.001) agree on the post-P13-001 model:
- Gate 1 fires FIRST: `autonomy_enabled` absent or not exactly `true` → allow-without-marker for ALL dispositions before any floor check
- MARKDOWN_COMMENT_PATH ELIMINATED: no autonomous comment marker is issued for any disposition from the markdown path
- FP + autonomy_enabled=true → allow-without-marker (not a comment marker)
- non-FP/PARSE_FAIL + autonomy_enabled=true → MARKDOWN_REVIEW_PATH (create-review/comment-review)
- VP-HOOK-031 guarantee (c) correctly states the elimination (verification-delta v1.16/v1.18 confirmed)
- BC-4.02.001 v1.11 PC#4 and BC-5.01.001 v1.11 Invariant #7 both reflect the P16-001 Gate-1-first rewrite

---

### Axis 8 — Cross-BC Contract Coherence: PASS

The emitter (BC-3.03.001 v1.24), consumer (BC-3.01.001 v1.22), and monitoring loop (BC-10.01.001 v1.18) are in agreement on all load-bearing contract elements:
- 18-field verdict schema and field ordering
- STEP order: STEP 1 validate_enums → STEP 1a SEVERITY-MISMATCH → STEP 2 extract ticket_action_type → STEP 3 review-surfacing → STEP 4 DENY-THE-WRITE → STEP 5 kill switch → STEP 6 regular markers → STEP 6a anti-fungibility → STEP 8 audit
- Hard-floor keys: `verdict.scored_priority ∈ {HIGH,CRIT}` (field 18); `asset_type = unknown` or in `CRITICAL_ASSET_TYPES`; techniques T1003/T1068/T1021/T1041; Indeterminate; degraded/silent sensor
- Marker lifecycle: D-DEC-001 filesystem mechanism, `${CLAUDE_PLUGIN_DATA}/markers/`, schema v2.1 (expires_at_utc=120s TTL, no `used` field), iterative-consume atomic-rename, STEP 6a anti-fungibility (create-review vs. create exact-type check)
- HARD-FLOOR-UNBINDABLE deny: create-review + null jira_project_key → deny; comment-review + null ticket_id → deny (both sides correctly stated in BC-3.03.001 STEP 3 and BC-3.01.001 consumer step 6 / BC-10.01.001 Invariant #10)

---

### Axis 9 — Traceability / Anchoring: FAIL

---

**CV-009 — MINOR**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-10.01.001.md`  
**Location:** Precondition #8 body text, lines 104-113  
**Text found:**
```
8. [NEW v1.6] Stage-7 verdict file path MUST contain the substring "verdict". The
   disposition-guard hook fast-path-allows any Write event whose file_path does not
   contain either "investigation" or "verdict" as a substring (BC-3.03.001 PC#1).
```
**Inconsistency:** This precondition text describes the pre-P4-001 path dispatch model (file-path substring: "investigation" vs. "verdict"). The normative dispatch since P4-001/v1.12 of architecture-delta and BC-3.03.001 v1.12 is JSON-first: `.json` extension check (or `jq empty` succeeds) → verdict-class 18-field path regardless of path substrings. The "investigations" directory no longer causes misrouting to the investigation-markdown path for `.json` files.  
**Contrast:** VP-HOOK-028 in the SAME BC file (lines 603 and 672) correctly states the JSON-first dispatch: "The canonical verdict path `artifacts/investigations/verdict-*.json` correctly routes to the verdict-class 18-field path because the `.json` extension (Check 1 in BC-3.03.001 PC#1 JSON-first dispatch) takes absolute precedence over any `investigation` directory substring." VP-HOOK-028's description is correct; PC#8's precondition body was added at v1.6 (P3-005) and was never updated when P4-001 rewrote PC#1 of BC-3.03.001.  
**Functional impact:** Minimal in practice (canonical verdict paths always contain "verdict" as a substring, so the old and new dispatch agree for well-named files). However, the PC#8 text is semantically stale and could mislead an implementer consulting the precondition statement for the dispatch contract.  
**Fix:** Update PC#8 to describe JSON-first dispatch: "The disposition-guard hook applies JSON-first dispatch (P4-001): if `file_path` ends in `.json` OR the file content parses as JSON (`jq empty` succeeds), the verdict-class 18-field path is triggered; otherwise the investigation-markdown 12-field path applies. The canonical verdict path `artifacts/investigations/verdict-<alert_id>-<iso_ts>.json` routes via JSON-first dispatch. A Stage-7 Write to a path not triggering either class fast-path-allows without validation (VP-HOOK-028)." Retain "[NEW v1.6]" tag and add "[UPDATED P4-001]".

---

**CV-010 — COSMETIC**

**File:** `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-3.03.001.md`  
**Location:** Evidence Types Used section, line 876 (brownfield extraction annotation)  
**Text found:** "guard clause: file path substring checks for `investigation` and `verdict` (path dispatch)"  
**Inconsistency:** This brownfield evidence note describes the pre-P4-001 dispatch using file path substrings. PC#1 of the same BC correctly describes JSON-first dispatch. The brownfield section is an informational annotation on the hook's original design, not a normative behavioral statement.  
**Functional impact:** None. The normative path dispatch in PC#1 is correct.  
**Fix:** Append annotation: "[SUPERSEDED by P4-001/v1.12 — normative dispatch is now JSON-first per PC#1: `.json` extension OR `jq empty` succeeds → verdict-class; otherwise investigation-markdown. This brownfield description reflects the original hook before JSON-first dispatch was added.]"

---

### Axis 10 — Tracked Deferrals: PASS

All four tracked deferrals are consistently flagged and not contradicted:
- **ASM-008-DEFERRED:** Flagged in BC-3.03.001 STEP 1a preamble (line 219), BC-10.01.001 STEP 1a (lines 219/223/660), and BC-10.01.001 Invariant #9 field-16 Cyberint note. No artifact claims ASM-008 is resolved.
- **ASM-014:** Flagged in BC-3.01.001 consumer step (6) (line 109 and ~209): "comment/comment-review structural check pending ASM-014 empirical validation of `jr issue comment --label` support." BC-3.01.001 v1.22 correctly limits exact-type matching to create-type commands and defers comment-type structural check.
- **ASM-015:** Flagged in BC-10.01.001 v1.18 PC#7 (line 155-160): "ASM-015 BLOCKING gate: empirically validate that permissionDecision:deny populates `.permission_denials[]`." Correctly marked as unresolved blocking validation.
- **DI-015:** Spec-changelog line 164-166 records DI-015 as a residual design issue for the known-FP scored_priority fast-path (SEVERITY_TO_SCORED_PRIORITY_MAP substitutes for full Stage-5 recalibration). No BC or delta document contradicts this or claims the fast-path is full-fidelity.

---

### Summary of All Findings

| ID | Axis | Severity | File | Location | Issue | Fix |
|----|------|----------|------|----------|-------|-----|
| CV-001 | 2 | MAJOR | BC-4.02.001.md | PC#1, line 45 | Cites BC-3.03.001 v1.13 (current v1.24, 11 versions stale) and BC-3.01.001 v1.17 (current v1.22, 5 stale) | Update both version strings in PC#1 body + confidence line |
| CV-002 | 2 | MAJOR | BC-4.02.001.md | PC#5, line 51 | Same stale cites as CV-001: BC-3.03.001 v1.13, BC-3.01.001 v1.17 | Update both version strings in PC#5 |
| CV-003 | 2 | MINOR | BC-4.02.001.md | PC#4 confidence footnote | BC-3.03.001 v1.23 (current v1.24, 1 stale); BC-3.01.001 v1.17 (current v1.22, 5 stale) | Update to v1.24 / v1.22 in PC#4 confidence |
| CV-004 | 2 | MINOR | BC-5.01.001.md | Invariant #7, line 115 | BC-3.01.001 v1.17 (current v1.22, 5 stale) in confidence footnote | Update to v1.22 |
| CV-005 | 2 | MINOR | BC-5.01.001.md | Invariant #7 lines 107/115/201 | BC-3.03.001 v1.23 at 3 locations (current v1.24, 1 stale) | Update all three to v1.24 |
| CV-006 | 2 | MINOR | prd-delta.md | §5 table, line 119, BC-3.01.001 "New Version" | Shows v1.21; actual file = v1.22 (P14-003 PRISMDEMO rename; burst-10 post-note missed this BC) | Update §5 cell to v1.22; append P14-003 summary |
| CV-007 | 3 | MINOR | prd-delta.md | §1 table, line 43, BC-10.01.001 VP Refs | VP-SKILL-075 missing; file itself correctly lists it (VP Anchors line 688) | Add VP-SKILL-075 (FINALIZED) to BC-10.01.001 VP Refs |
| CV-008 | 3 | MINOR | architecture-delta.md | Line 9 (v1.16 changelog); line 6096 (§8.29) | "current total … / 35 VPs" in two historical sections; actual current total = 37 | Annotate as "[SUPERSEDED]" with current count cross-ref to verification-delta v1.18 |
| CV-009 | 9 | MINOR | BC-10.01.001.md | PC#8, lines 104-113 | Uses stale pre-P4-001 substring dispatch semantics ("does not contain 'investigation' or 'verdict' as a substring"); VP-HOOK-028 in the same BC correctly states JSON-first dispatch | Rewrite PC#8 body to describe JSON-first dispatch; add "[UPDATED P4-001]" tag |
| CV-010 | 9 | COSMETIC | BC-3.03.001.md | Evidence Types section, line 876 | Brownfield note says "file path substring checks for `investigation` and `verdict`" — pre-P4-001 dispatch; normative PC#1 is correct | Append superseded annotation noting P4-001/v1.12 JSON-first dispatch |
| CV-011 | 2 | MINOR | prd-delta.md | §5 table, line 122, BC-10.01.001 "New Version" | Shows v1.17; actual file = v1.18 (P14-001/P14-004; burst-10 post-note omitted this BC) | Update §5 cell to v1.18; append P14-001/P14-004 summary |
| CV-012 | 2 | MINOR | prd-delta.md | §5 table, line 125, BC-6.01.001 "New Version"; burst-9 post-note line 141 | §5 cell shows v1.6; actual file = v1.7; prd-delta's own burst-9 post-note records v1.7; spec-changelog claims prd-delta v1.15 updated §5 to v1.7 (contradicted by actual file) | Update §5 cell to v1.7; append P13-002 setup-time charset validation summary; reconcile spec-changelog v1.15 description |

---

### Confirmed Clean Axes (Evidence Basis)

**Axis 1 (Field Counts):** architecture-delta §5 "18 mandatory fields," BC-3.03.001 PC#2/PC#3 per-class split (verdict=18, investigation markdown=12), BC-10.01.001 Invariant #9 full 18-field enumeration, prd-delta §4 "18 fields for verdict JSON" — all consistent.

**Axis 4 (Enum Tokens):** BC-3.03.001 STEP 1 validate_enums confirms `SCORED_PRIORITY_ENUM = {"CRIT","HIGH","MED","LOW"}`; severity enum {LOW,MEDIUM,HIGH,CRITICAL} used throughout for detector-native values; SEVERITY_TO_SCORED_PRIORITY_MAP bridges them correctly; no artifact uses CRITICAL/MEDIUM as a scored_priority member in normative logic.

**Axis 5 (Demo Key):** All canonical test vectors (BC-3.03.001 EC-023/024/025, BC-3.01.001 EC-023/024/025, BC-6.01.001 EC-013, BC-6.01.003 test vectors, verification-delta §2 VP table, handoff-brief §3.5/§4.1) use PRISMDEMO. Two intentional invalid-key exemptions correctly use PRISM-DEMO as test-of-rejection inputs.

**Axis 6 (NVD/CVSS):** BC-3.03.001 emitter pseudocode `SENSOR_FAMILY_ENUM = {"crowdstrike","armis","claroty","cyberint"}` — no NVD. BC-10.01.001 v1.18 NVD row removed from NORMALIZE_SEVERITY table (P14-001). Stage-5 enrich_nvd() feeds scored_priority at Stage 5 only.

**Axis 7 (Markdown-Path Semantics):** BC-3.03.001 v1.24 VP-HOOK-031 guarantee (c) "no disposition yields an autonomous comment marker from the markdown path" confirmed; BC-4.02.001 v1.11 PC#4 Gate-1-first model (P16-001); BC-5.01.001 v1.11 Invariant #7 Gate-1-first model (P16-001) — all three human-path BCs agree.

**Axis 8 (Cross-BC Contract Coherence):** All three leg BCs confirm: 18-field schema, STEP 1→6a→8 order, scored_priority field-18 hard-floor keys, marker schema v2.1, iterative-consume algorithm, HARD-FLOOR-UNBINDABLE deny at both missing-binding branches.

**Axis 10 (Tracked Deferrals):** ASM-008, ASM-014, ASM-015 consistently flagged as deferred/unresolved; DI-015 recorded in spec-changelog as residual; no artifact contradicts any of these.

---

### Validation Gate Result

**GATE: PASS WITH CONDITIONS**

No BLOCKING findings. Two MAJOR findings (CV-001, CV-002) represent severely stale BC-version cross-references in BC-4.02.001 that should be remediated before the next adversarial pass. Seven MINOR findings are version-tracking gaps in prd-delta §5 and VP-count housekeeping. Two findings (CV-009, CV-010) are semantic-staleness issues in precondition and brownfield text that do not affect any normative invariant.

The coherence backlog as of the 16th adversarial pass consists entirely of version-tracking drift and one stale precondition description — no contract logic errors, no enum confusion, no demo-key contamination, no NVD/CVSS boundary violations, and no deferral contradictions were found.

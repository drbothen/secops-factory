---
document_type: behavioral-contract
level: L3
version: "1.26"
status: draft
producer: product-owner
timestamp: 2026-07-20T00:00:00
phase: f2
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/disposition-guard.sh, plugins/secops-factory/tests/hooks.bats, phase-f2-spec-evolution/architecture-delta.md]
input-hash: "COMPUTE-AT-COMMIT"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/disposition-guard.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-03
lifecycle_status: active
introduced: v0.7.0
modified: ["v1.1-ADV-0-403-2026-07-19", "v1.2-ADV-0-501-ADV-0-507-2026-07-19", "v1.3-ADV-0-605-ADV-0-606-2026-07-19", "v1.4-ADV-0-B01-2026-07-19", "v1.5-RESYNC-PR17-2026-07-19", "v1.6-D-DEC-001-ICD-203-2026-07-20", "v1.7-FV-VP-HOOK-025-FINALIZED-2026-07-20", "v1.8-ADV-F2-001-003-004-016-2026-07-20", "v1.9-ADV-F2-P2-001-emitter-ordering-2026-07-20", "v1.10-ADV-F2-P3-001-002-003-011-2026-07-20", "v1.11-FV-VP-026-025-ANCHORS-2026-07-20", "v1.12-P4-001-P4-002-P4-005-P4-006-D-DEC-012-2026-07-21", "v1.13-FV-VP-028-025-026-029-ANCHORS-2026-07-21", "v1.14-ADV-F2-P5-001-P5-002-P5-003-2026-07-21", "v1.15-ADV-F2-P6-001-P6-002-2026-07-21", "v1.16-ADV-F2-P7-001-2026-07-21 [SM-ID-sync per FV]", "v1.17-ADV-F2-P8-001-OBS-2-2026-07-21", "v1.18-ADV-F2-P10-001-P10-003-P10-004-P10-008-2026-07-22 [ID-sync per FV]", "v1.19-ADV-F2-P11-001-P11-002-P11-003-P11-004-2026-07-22 [ID-sync per FV]", "v1.20-ADV-F2-P12-001-P12-002-P12-003-2026-07-22 [ID-sync per FV]", "v1.21-ADV-F2-P13-001-002-003-004-2026-07-22 [ID-sync per FV]", "v1.22-ADV-F2-P14-004-garbled-test-vector-parenthetical-2026-07-22", "v1.23-ADV-F2-P15-002-evidence-types-18field-2026-07-22", "v1.24-ADV-F2-P16-003-pc1-vphook028-18field-2026-07-22", "v1.25-CV-010-evidence-types-path-dispatch-annotation-2026-07-23", "v1.26-ADV-F2-P17-003-EC-005-L814-markdown-no-comment-marker-2026-07-23"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.03.001: disposition-guard Hook — Alternatives-Required Gate and ICD-203 Validator / Marker Emitter

> **Revision history:**
> - v1.26 (2026-07-23): Pass-17 adversarial remediation — P17-003 (MAJOR, stale MARKDOWN_COMMENT_PATH residue in EC-005 and L814 canonical test vector). (1) **EC-005 rewritten (P17-003):** The pre-P13-001 text described "marker written … scope determined by ticket_action_type content if present; defaults to comment-scoped for investigation files" — two errors: (a) MARKDOWN_COMMENT_PATH was eliminated at P13-001 so no autonomous comment marker is ever issued from the markdown path; (b) `ticket_action_type` does not exist on the 12-field markdown path (verdict-only field, PC#1 path). Rewritten to post-P13-001 behavior: GATE 1 (autonomy_enabled absent/≠true — the common human-save case) → allow-without-marker for ALL dispositions; autonomy_enabled=true masquerade: FP → allow-without-marker (MARKDOWN_COMMENT_PATH eliminated, P13-001); non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review review marker, EXEMPT from kill switch); NO autonomous ["comment"] marker from the markdown path. (2) **Canonical test vector row at L814 rewritten (P17-003):** The "happy-path (v1.10 EMITTER)" row asserted "marker file written (comment-scoped, ticket-bound pattern)" for a TP investigation markdown — this contradicted the correct sibling vector at L835 (TP + autonomy=true → MARKDOWN_REVIEW_PATH comment-review marker) and asserted the retired comment-marker behavior. Rewritten: autonomy_enabled absent (common human-save case) + TP investigation markdown → allow-without-marker (NO marker), consistent with GATE 1 semantics. The two vectors (L814 autonomy-absent / L835 autonomy=true) now cover distinct, consistent cases. ADV-F2-P17-003.
> - v1.25 (2026-07-23): CV-010 consistency-validator remediation — COSMETIC annotation in Evidence Types Used section. The original brownfield `guard clause` bullet describing "file path substring checks for `investigation` and `verdict` (path dispatch)" annotated with a [SUPERSEDED by P4-001/v1.12] note explaining the normative JSON-first dispatch introduced at v1.12. The historical description text is preserved unchanged; only a clarifying annotation is appended. No semantic change to emitter logic.
> - v1.24 (2026-07-22): Pass-16 adversarial remediation — P16-003 (MINOR, PC#1 VP-HOOK-028 note stale field count). **PC#1 VP-HOOK-028 note corrected:** "verdict-class 15-field path" → "verdict-class 18-field path". The PC#1 normative body and adjacent dispatch check already correctly state 18-field (P10-001/P11-002); this was an internal inconsistency within the VP-HOOK-028 note only. Sweep of PC#1 current-body text: no other stale 15-field or 17-field field counts found. ADV-F2-P16-003.
> - v1.23 (2026-07-22): Pass-15 adversarial remediation — P15-002 (MINOR, Evidence Types section stale field count). **Evidence Types corrected:** "guard clause (v1.6/v1.8)" bullet updated from "15-key JSON key-presence validation" (stale since P10-001/P11-002) to "18-key JSON key-presence validation" with full version progression: 15 fields at v1.8 (after addition of severity/asset_type/ticket_action_type) → 17 fields at v1.18/P10-001 (after addition of native_severity/sensor_family) → 18 fields at v1.19/P11-002 (after addition of scored_priority). No semantic change to emitter logic. ADV-F2-P15-002.
> - v1.22 (2026-07-22): Pass-14 adversarial remediation — P14-004 (MINOR, stale field-count parenthetical). **Canonical test vector L825 corrected (P14-004):** Input description parenthetical "(17-field verdict missing field 16 of 18)" was garbled — the verdict schema is 18-field (P11-002); the correct phrasing is "(field 16 of the 18-field verdict schema)". Also corrected "same deny path as EC-010 for fields 1-17" → "fields 1-18" in the same row (P10-001/P11-002 18-field validation covers all 18 fields). ADV-F2-P14-004.
> - v1.21 (2026-07-22): Pass-13 adversarial remediation — P13-001 (CRITICAL, MARKDOWN_COMMENT_PATH ELIMINATED), P13-002 (CRITICAL, PRISMDEMO rename), P13-003 (MAJOR, parse grammar specifications), P13-004 (MINOR, PC#2 outcome prose update). (1) **P13-001 (CRITICAL, per human decision 2026-07-22) — MARKDOWN_COMMENT_PATH ELIMINATED:** The autonomous comment marker branch for FP dispositions is removed from the Separate Human-Comment Marker Path. The hook cannot evaluate `scored_priority` (field 18) or `asset_type` (field 14) from a 12-field markdown; no known-FP store cross-check applies on this path. New routing after floors pass: `parsed_disposition == "FP"` → **allow-without-marker** (Write succeeds; no Jira action authorized; analyst may surface an FP comment via the review path or normal 18-field verdict flow); `parsed_disposition != "FP"` or PARSE_FAIL → **MARKDOWN_REVIEW_PATH** (create-review/comment-review, same STEP 3 semantics, EXEMPT from kill switch). The ticket_id charset-validation block that appeared inside MARKDOWN_COMMENT_PATH is no longer relevant for the FP branch (FP produces allow-without-marker with no pattern construction); O7 ticket_id charset validation remains active on the MARKDOWN_REVIEW_PATH branch. VP-HOOK-031 guarantee (c) rewritten: "no disposition yields an autonomous comment marker from the markdown path — FP emits allow-without-marker; non-FP/PARSE_FAIL routes to review." Jira project key constraint note added: Jira project keys MUST be hyphen-free and match `^[A-Z][A-Z0-9]+$` (see D-DEC-008 v1.16). (2) **P13-003 (MAJOR) — Strict parse grammar specified:** `parse_disposition_from_markdown`: reads ONLY the canonical `Disposition` heading value; exact allowlist {TP,FP,BTP,Indeterminate} + canonical long forms ("True Positive"→TP, "False Positive"→FP, "Benign True Positive"→BTP); PARSE_FAIL on ambiguous/multi-valued/missing/unrecognized → treated as non-FP (routes to MARKDOWN_REVIEW_PATH, never allow-without-marker); no full-document scan; adversarial probe: `Disposition: not a false positive` → PARSE_FAIL → review. `parse_autonomy_enabled_from_markdown`: reads ONLY a dedicated structured field (not free-text scan); explicit-true-only; absent/false/ambiguous/embedded-in-code-fence-or-evidence-block → false (GATE 1 stays closed); adversarial probe: `autonomy_enabled: true` inside code fence → GATE 1 remains closed. Blast-radius note: since MARKDOWN_COMMENT_PATH is eliminated, parse_disposition now only decides review-vs-allow-without-marker (all dispositions converge on non-autonomous-comment output). (3) **P13-004 (MINOR) — PC#2 outcome prose updated:** "If the separate path's markdown-evaluable floors pass, a comment-scoped marker is written and `permissionDecision: allow` is emitted" updated to reflect current post-P13-001 behavior: (a) GATE 1 kill-switch; (b) floors check; (c) FP → allow-without-marker; non-FP/PARSE_FAIL → review marker. Cross-ref updated from `(P11-004)` to `(P11-004 / P12-002 / P13-001)`. (4) **P13-002 (CRITICAL) — PRISMDEMO rename:** All `PRISM-DEMO` occurrences in test vectors and fallback hint changed to `PRISMDEMO`; `PRISM-DEMO-42` → `PRISMDEMO-42`. (5) **New canonical test vectors:** FP+autonomy_enabled=true → allow-without-marker (no comment marker, P13-001); Disposition=PARSE_FAIL → MARKDOWN_REVIEW_PATH (review, not allow-without-marker, P13-003); `autonomy_enabled: true` embedded in code fence → GATE 1 remains closed (P13-003). (6) **VP-HOOK-031 scope update:** vectors (1)/(2) updated; SM-P12-D SUPERSEDED by SM-51 (route-to-review, reconciled) / SM-52 (FP-comment-marker revert, P13-001) [ID-sync per FV]. ADV-F2-P13-001, P13-002, P13-003, P13-004.
> - v1.20 (2026-07-22): Pass-12 adversarial remediation — P12-001 (CRITICAL, charset-validation at all 5 command_pattern interpolation sites), P12-002 (CRITICAL, Separate Human-Comment Marker Path kill-switch + route-to-review redesign), P12-003 (fast-path SEVERITY_TO_SCORED_PRIORITY_MAP reference). (1) **P12-001 (CRITICAL) — charset-validation + regex-escape at all 5 interpolation sites (O7 standing rule):** Before interpolating `ticket_id` or `jira_project_key` into any `command_pattern` anchored regex, disposition-guard now validates the field against a strict charset and DENIES on mismatch: `ticket_id` → `^[A-Z][A-Z0-9]+-[0-9]+$` → TICKET-ID-CHARSET-DENY; `jira_project_key` → `^[A-Z][A-Z0-9]+$` → PROJECT-KEY-CHARSET-DENY. `regex_escape()` applied as defense-in-depth AFTER the charset check. Sites covered: STEP 3 comment-review (ticket_id), STEP 3 create-review (jira_project_key), STEP 6 comment (ticket_id), STEP 6 create (jira_project_key), STEP 6 assign (ticket_id). Also covers ticket_id on the Separate Human-Comment Marker Path. (2) **D-DEC-001-echoed claim corrected (P12-001):** Added explicit P12-001/O7 security note that `ticket_id` IS derived from Jira/alert/markdown content (loop-written from ingested data on the verdict path; from free-text markdown on the Human-Comment path) — NOT an intrinsic constant of the hook's logic. The prior implicit D-DEC-001/D-DEC-008 claim ("command_pattern not derived from content") was incorrect; anchored matching alone is insufficient when anchor components can contain metacharacters. Metacharacter safety is now enforced by charset-validation + regex-escape. (3) **P12-002 (CRITICAL, per human decision 2026-07-22) — Separate Human-Comment Marker Path redesigned (kill-switch + route-to-review):** GATE 1 (new, fires FIRST): reads `autonomy_enabled` from markdown content — if absent or not exactly boolean true → emit allow-without-marker (kill-switch parity, closes the autonomous-loop-masquerade bypass). GATES 2/3 (unchanged): markdown-evaluable floors. NEW route rule: `parsed_disposition != "FP"` → MARKDOWN_REVIEW_PATH (create-review/comment-review marker; escalation-worthy findings route to review because scored_priority/asset_type cannot be evaluated from 12-field markdown); FP + autonomy_enabled=true → MARKDOWN_COMMENT_PATH (benign analyst FP save gets comment marker). Trust basis updated accordingly. (4) **P12-003 (fast-path context):** SEVERITY_TO_SCORED_PRIORITY_MAP reference added near SCORED_PRIORITY_ENUM in validate_enums(); documents that fast-path scored_priority MUST be derived via map — NOT direct NORMALIZE_SEVERITY assignment (which produces non-members {CRITICAL,MEDIUM}). (5) **VP-HOOK-031 scope update required per P12-002:** SM-50 (markdown kill-switch gate removed) + SM-51 (route-to-review rule removed) allocated by FV [ID-sync per FV]. (6) **New canonical test vectors:** TICKET-ID-CHARSET-DENY (ticket_id=".*"); PROJECT-KEY-CHARSET-DENY (jira_project_key="SEC|.*"); markdown TP → MARKDOWN_REVIEW_PATH (comment-review marker); markdown FP (autonomy_enabled=true) → MARKDOWN_COMMENT_PATH (comment marker); markdown autonomy_enabled absent → allow-without-marker. ADV-F2-P12-001, P12-002, P12-003.
> - v1.19 (2026-07-22): Pass-11 adversarial remediation — P11-001 (CRITICAL, STEP 1a consistency-only reframe), P11-002 (MAJOR, scored_priority as field 18 + hard_floor_applies() re-key), P11-003 (NVD/CVSS clean separation), P11-004 (MAJOR, Separate Human-Comment Marker Path). (1) **18-field verdict schema (P11-002):** `scored_priority` (field 18, enum CRIT|HIGH|MED|LOW) added as required verdict field; `validate_enums()` extended with `SCORED_PRIORITY_ENUM = {"CRIT","HIGH","MED","LOW"}` fail-closed check; all "17-field"/"17 mandatory"/"17 keys" references in PC#1/PC#2/PC#3 updated to 18; field list in PC#1 updated to include `scored_priority` after `sensor_family`. VP-HOOK-025 description updated to 18-field. (2) **hard_floor_applies() re-keyed to scored_priority (P11-002):** HIGH/CRIT severity floor now keys on `verdict.scored_priority ∈ {HIGH, CRIT}` (NOT `recomputed_severity`); `verdict.severity` (detector-native) and `verdict.scored_priority` (Stage-5 recalibrated) may legitimately differ; STEP 3 and STEP 4 call-sites retain `hard_floor_applies(verdict, recomputed_severity)` signature; `recomputed_severity` no longer drives the floor internally. (3) **STEP 1a consistency-only language (P11-001):** replaced "genuinely un-bypassable / independently derives from raw sensor values / only remaining LLM-trust surface" with: "STEP 1a is a DETERMINISTIC CONSISTENCY CHECK between verdict.severity and verdict.native_severity (both LLM-supplied Stage-1 fields); hardens against careless/buggy LLM under-reporting only; NOT ground-truth enforcement." Added ASM-008-class symmetric residuals for native_severity, asset_type, and scored_priority (all LLM-supplied; genuine enforcement requires hook-side prism cross-validation — ASM-008-DEFERRED). (4) **Investigation-markdown emitter entry corrected (P11-004):** Invariant #4 preamble and STEP 0 corrected — the investigation-markdown path (PC#2) does NOT enter this emitter. PC#2 text updated accordingly. Added **Separate Human-Comment Marker Path (P11-004)** section in Invariant #4 after the hard-floor check block: 12-field completeness + markdown-evaluable hard floors ONLY (Indeterminate disposition, forbidden techniques T1003/T1068/T1021/T1041, degraded/silent sensor); parses ticket_id; emits comment-scoped marker; does NOT call validate_enums or STEP 1a; floor fires → MARKDOWN-HARD-FLOOR deny; compliant analyst save → comment marker, not denied. (5) **Canonical test vectors added (P11-002/P11-004):** scored_priority=HIGH with detector severity=LOW → hard floor fires (scored_priority floor, not STEP 1a mismatch); 18th-field (scored_priority) absent → deny; investigation-markdown compliant save → comment marker, not denied.
> - v1.18 (2026-07-22): Pass-10 adversarial remediation — P10-001 (CRITICAL, full hook-side severity re-normalization), P10-003 (MAJOR, WRITE_MARKER fail-closed on review path), P10-004 (MINOR, fallback_hint P9-007 dedup instruction propagation), P10-008 (MINOR, ASM-014-pending residual note). (1) **17-field verdict schema (P10-001):** PC#1 verdict JSON path updated from 15-field to 17-field: `native_severity` (field 16, string, non-empty) and `sensor_family` (field 17, enum crowdstrike|armis|claroty|cyberint) added as required verdict fields; `validate_enums()` extended with `SENSOR_FAMILY_ENUM` check; all "15-field"/"15 mandatory" references in PC#1/PC#2/PC#3 updated to 17. VP-HOOK-025 description updated to 17-field. (2) **STEP 1a SEVERITY-MISMATCH (P10-001):** New emitter step inserted between STEP 1 (validate_enums) and STEP 2 (extract ticket_action_type): hook re-runs `NORMALIZE_SEVERITY(verdict.native_severity, verdict.sensor_family)` using the D-DEC-013 deterministic table; if `recomputed_severity != verdict.severity` → write `SEVERITY-MISMATCH` audit entry + emit deny. O6 standing rule: inputs to a hook-computed invariant must be hook-recomputable. `hard_floor_applies()` signature updated to `hard_floor_applies(verdict, recomputed_severity)` — both STEP 3 and STEP 4 call-sites updated. (3) **WRITE_MARKER fail-closed on review path (P10-003):** WRITE_MARKER pseudocode updated to branch on `is_review_path`: create-review/comment-review marker-write failure → `MARKER-WRITE-FAILED` audit entry + emit deny (mirrors HARD-FLOOR-UNBINDABLE); regular marker paths retain emit allow without marker (require-review denies jr call — human gate preserved). Marker schema `disposition.severity` updated to use `recomputed_severity` (P10-001). Marker directory initialization note updated to reference WRITE_MARKER branching. (4) **fallback_hint dedup instruction (P10-004):** comment-review null-ticket_id branch `fallback_hint` for the jira_project_key-present case updated to the full P9-007 dedup instruction from architecture-delta v1.13 line 1509 (previously the weaker short form: "if no review ticket exists yet, re-issue with ticket_action_type=create-review instead"). (5) **ASM-014-pending residual note (P10-008):** Explicit residual note added in STEP 3 comment-review section: the comment-review kill-switch exemption is currently broader than "review ticket only"; the exemption is not restricted to review-labeled tickets until ASM-014 resolves. (6) **Canonical test vectors added:** SEVERITY-MISMATCH deny (native_severity maps to CRITICAL but verdict.severity=LOW); missing field 16 (native_severity absent) → deny; missing field 17 (sensor_family absent/non-member) → deny; known-good agreement (native_severity+sensor_family map to verdict.severity) → proceed normally.
> - v1.17 (2026-07-21): Pass-8 adversarial remediation — ADV-F2-P8-001 (CRITICAL), OBS-2. (1) **STEP 3 create-review null-project_key branch — HARD-FLOOR-UNBINDABLE deny (P8-001 CRITICAL):** Replaced `emit allow without marker # cannot bind review-create without project key; RETURN` with HARD-FLOOR-UNBINDABLE deny per D-DEC-012 clause 2: WRITE audit entry naming `missing_field=jira_project_key`; emit deny with `hard_floor_trigger`, `missing_field=jira_project_key`, and corrective instruction. (2) **STEP 3 comment-review null-ticket_id branch — HARD-FLOOR-UNBINDABLE deny with fallback hint (P8-001 CRITICAL):** Replaced `emit allow without marker # cannot bind review-comment without ticket_id; RETURN` with HARD-FLOOR-UNBINDABLE deny: if `jira_project_key` is present, deny includes fallback hint suggesting `create-review` (consistent with STEP 4 `required_token` logic: `ticket_id`=null → `required_token=create-review`; the verdict may be mis-classified as `comment-review` when no open ticket exists yet); if `jira_project_key` also absent, deny names both missing fields. (3) **FAIL-LOUD invariant comment updated:** Three cases now explicit — bindable (marker issued), unbindable P8-001 deny, under-labeled STEP 4 deny. (4) **Generation table notes updated:** `create-review` and `comment-review` rows — "if binding field null → NO marker" replaced with "HARD-FLOOR-UNBINDABLE deny; NEVER silent allow-without-marker". (5) **Hard-floor block NOTE updated:** "correctly-labeled verdicts → marker" qualified to "correctly-labeled AND bindable → marker; correctly-labeled but UNBINDABLE → HARD-FLOOR-UNBINDABLE deny (P8-001)". (6) **VP-HOOK-029 citation updated:** FINALIZED P0 per verification-delta v1.10; unbindable-deny vectors cited as active kill targets alongside deny-path and re-doc vectors. (7) **Bounded-retry note:** Non-termination — each re-doc attempt that still omits the binding field fires exactly one HARD-FLOOR-UNBINDABLE audit entry + one deny; no Jira write; bounded fail-closed; mirrors STEP 4 analysis. (8) **Canonical test vectors added:** DENY vectors for create-review + null `jira_project_key`; comment-review + null `ticket_id` + `jira_project_key=PRISM-DEMO` present (fallback hint). **Residual sweep:** all "emit allow without marker # cannot bind" language removed from live content.
> - v1.16 (2026-07-21): Pass-7 adversarial remediation — ADV-F2-P7-001 (CRITICAL) STEP 4 DENY-THE-WRITE redesign. (1) **STEP 4 REDESIGN (ADV-F2-P7-001):** The pass-5/pass-6 marker-upgrade approach is **RETIRED** entirely. The upgrade only rewrote the marker; it cannot rewrite the Stage-8 Bash command the loop LLM subsequently issues. Under-labeling means the loop set a non-review `ticket_action_type` and will run the corresponding non-review command. Walk the four under-label action types: `create` → loop runs `jr issue create` without `--label`; create-review marker requires `--label` → consumer DENY; `assign` → loop runs `jr issue assign`; comment-review pattern requires `issue comment` → consumer DENY; `none` → loop runs no jr command at all; marker expires unconsumed → silent drop. Three of four paths produced unconsumable markers — hard-floor findings were silently dropped at the consumer boundary. STEP 4 is now **DENY-THE-WRITE**: disposition-guard DENIES the verdict Write with a structured machine-actionable corrective reason (HARD-FLOOR-UNDER-LABEL); writes an `UNDER-LABEL-DENIED` audit entry (replaces retired `UNDER-LABEL-CORRECTED`); no marker is issued on this path. The loop MUST re-issue the verdict Write with `ticket_action_type` set to the corrective review token from the deny reason; on the corrected Write STEP 3 issues the review marker normally. `autonomy_enabled` is irrelevant — deny fires regardless. Bounded fail-closed: deny + audit entry ARE the loud failure. STEP 4 remains BEFORE STEP 5 kill switch. (2) **`UNDER-LABEL-CORRECTED` RETIRED:** All occurrences of `UNDER-LABEL-CORRECTED` audit code removed from live content; replaced with `UNDER-LABEL-DENIED`. (3) **EC-012 cases (c)/(d) collapsed:** Both cases were "under-labeled, autonomy_enabled=true" and "under-labeled, autonomy_enabled=false" with different upgrade outcomes. Since deny now fires regardless of `autonomy_enabled`, these are collapsed to a single case. (4) **Canonical test vectors updated:** EC-012 under-label rows flip from upgrade-semantics to DENY + UNDER-LABEL-DENIED + no marker. (5) **FAIL-LOUD comment in STEP 3 updated** to reference "STEP 4 deny-the-Write path." (6) **Hard-floor block NOTE and under-labeled paragraph updated** to deny-the-Write semantics. (7) **Generation table `none` row note** verified. (8) **Schema v2.1 note:** STEP 4 reference updated from `UNDER-LABEL-CORRECTED upgrade path` to `UNDER-LABEL-DENIED deny path`. (9) **VP-HOOK-029 citation** updated to deny-the-Write semantics — verifies end-to-end consumer-boundary outcome per P7-009 standing rule.
> - v1.15 (2026-07-21): Pass-6 adversarial remediation — ADV-F2-P6-001 (CRITICAL) create-review command_pattern update + ADV-F2-P6-002 (CRITICAL) STEP 4/5 reorder. (1) **STEP REORDER (ADV-F2-P6-002):** Hard-floor upgrade (formerly STEP 5) moved to STEP 4, executing BEFORE the autonomy_enabled kill switch (now STEP 5). Under-labeled hard-floor verdicts (e.g., `ticket_action_type=create` + `disposition=Indeterminate`) now trigger STEP 4 upgrade regardless of `autonomy_enabled` — the prior silent-drop on `autonomy_enabled=false` + under-labeled hard-floor is eliminated. EC-012 case (d) semantics flipped: no longer "NO marker (kill switch fires)"; now "create-review marker IS issued (STEP 4 upgrade)." (2) **create-review command_pattern (ADV-F2-P6-001):** Pattern updated to include `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed second position after `--project <key>` at STEP 3 (create-review emitter) and STEP 4 (UNDER-LABEL-CORRECTED upgrade path). Old pattern: `^jr (--output json )?issue create --project <key>( |$)`; new: `^jr (--output json )?issue create --project <key> --label (REVIEW-REQUIRED|BLIND-SPOT)( |$)`. (3) **Iron Law updated:** Require-review NOW enforces label content structurally via command_pattern AND consumer STEP 6a cross-check; SKILL.md Iron Law retained as defense-in-depth. (4) **ASM-014 note added** for comment-review: structural `--label` check pending empirical validation of `jr issue comment --label` support. (5) **FAIL-LOUD invariant comment** updated: "STEP 5 upgrade path" → "STEP 4 upgrade path". (6) **Generation table** create-review row pattern updated; "none" row step updated to "Step 5 (kill switch)". (7) **Hard-floor block note** updated: "Step 5" → "Step 4 [formerly Step 5]". (8) **Under-labeled verdicts paragraph** updated with new STEP ordering. (9) **Canonical test vectors** updated: case (d) row flipped (no-marker → create-review issued); case (c) row updated to "STEP 4 upgrade". (10) **VP-HOOK-029** citation updated to STEP 4; schema v2.1 STEP 5 reference corrected to STEP 4.
> - v1.14 (2026-07-21): Pass-5 adversarial remediation (ADV-F2-P5-001/P5-002/P5-003). [P5-002 MAJOR] STEP 3 review-marker exemption gated on `hard_floor_applies(verdict)`: refactored `IF action == "create-review" / ELIF action == "comment-review"` into a single `IF action in {"create-review", "comment-review"}` block with an upfront `IF NOT hard_floor_applies(verdict): emit allow without marker; RETURN` over-label guard; O3 standing-rule comment added ("LLM-supplied routing field cross-validated against hook-computed invariant before bypass granted"); kill-switch semantics confirmed Option A 2026-07-21 (no PENDING qualifier). [P5-001 CRITICAL] STEP 5 fail-loud upgrade: replaced `IF action == "none" OR hard_floor_applies(): emit allow without marker; RETURN` with deterministic upgrade logic — `hard_floor_applies()` branch: ticket_id present → comment-review marker; ticket_id null + jira_project_key present → create-review marker; both absent → FAIL-LOUD deny + `UNDER-LABEL-CORRECTED-ERROR` audit entry; `action == "none"` (non-hard-floor) branch retained for allow-without-marker; `UNDER-LABEL-CORRECTED` audit entry written on all non-error upgrade paths. Hard-floor block NOTE updated to reference STEP 5 upgrade. EC-012 updated to reflect upgrade behavior. [P5-003 MAJOR] Schema v2.1 sync: canonical marker schema heading updated from "v2.0" to "v2.1"; Schema v2.1 additions note added documenting the three additions (create-review/comment-review in `authorized_operations`, `Indeterminate` in `disposition.verdict`, `ticket_action_type` sub-field in disposition object) that were already present in WRITE_MARKER and the emitter since v1.12 but absent from the §D-DEC-001 authoritative block; generation table create-review/comment-review rows updated to reflect `hard_floor_applies()` gate. [TV-SYNC] Canonical test vectors synchronized: (1) review-surfacing row (create-review + Indeterminate + autonomy_enabled=false) parenthetical updated from "exempt from hard floor + kill switch" to post-P5-002 wording "STEP 3: hard_floor_applies()=true gate satisfied (Indeterminate); exempt from kill switch"; (2) stale under-specified EC-012 row (missing ticket_action_type and autonomy_enabled) split into two pinned rows — (c) under-labeled + autonomy_enabled=false → STEP 4 kill switch, no marker; (d) under-labeled + autonomy_enabled=true + jira_project_key=SEC → STEP 5 create-review upgrade with UNDER-LABEL-CORRECTED audit entry.
> - v1.13 (2026-07-21): VP-anchor additions only — zero semantic change. (a) PC#1 JSON-first dispatch: added VP-HOOK-028 citation — PC#1/Check-1 is the dispatch surface proving JSON-first canonical-path routing (ADV-F2-P4-001, verification-delta.md v1.5 §2). (b) Invariant #4 emitter Step 1 `validate_enums()`: added VP-HOOK-025 citation for the fail-closed enum-membership gate (non-member/wrong-case → DENY before hard floor, ADV-F2-P4-006). (c) Invariant #4 emitter Step 3 review-surfacing (create-review/comment-review): added VP-HOOK-026 (hard-floor-EXEMPT + kill-switch-EXEMPT legs, D-DEC-012) and VP-HOOK-029 (fail-loud: hard-floor verdict → review marker OR explicit error, P1 PROPOSED) citations. (d) Invariant #4 emitter Step 4 autonomy_enabled kill switch: added VP-HOOK-026 citation (determinism — read directly from verdict, not LLM-delegated, ADV-F2-P4-005). Verification-delta.md v1.5 §7 Part E.
> - v1.12 (2026-07-21): Pass-4 adversarial remediation. [P4-001 CRITICAL] Rewrote PC#1/PC#2/PC#3 dispatch to JSON-FIRST: (new PC#1) if content parses as JSON (`jq empty`) OR file_path ends `.json` → verdict-class 15-field path regardless of `investigation` substring in path (closes canonical-path routing collision `artifacts/investigations/verdict-*.json`); (new PC#2) elif file_path matches `*investigation-*.md` (`.md` required) → investigation-class 12-field path; (new PC#3) else → fast-path allow. Old substring dispatch preserved as Previous blocks. [P4-002 CRITICAL] Create emitter branch command_pattern updated to anchored fixed-position form `^jr (--output json )?issue create --project <jira_project_key>( |$)` — removed `.*` before `--project`; Iron Law: `--project` MUST be first arg after `issue create`; trailing `( |$)` prevents prefix-match (ORG_A cannot match ORG_A_EXTRA); generation table updated; old `.*` pattern preserved as Previous. [P4-006 MAJOR] Added `validate_enums()` at emitter Step 1 (before hard-floor): fail-closed DENY on non-member values for severity/asset_type/disposition/sensor_health_status/ticket_action_type/confidence. [P4-005 MAJOR] Added `autonomy_enabled` as non-ICD-203 operational metadata field in verdict JSON (alongside jira_project_key); emitter reads it directly from verdict at Step 4 (kill switch); default-false (absent or non-boolean = false) → refuse ALL regular markers; exempt paths: create-review/comment-review. [D-DEC-012] Added create-review + comment-review emitter branches at Step 3 (BEFORE autonomy_enabled kill switch and hard_floor_applies()): restricted markers for hard-floor verdicts needing human surfacing; EXEMPT from hard_floor_applies() and autonomy_enabled kill switch; scoped to [REVIEW-REQUIRED]/[BLIND-SPOT] ticket operations only; fail-loud invariant: hard-floor verdicts are never silently discarded. Generation table updated with create-review/comment-review rows.
> - v1.11 (2026-07-20): FV-VP-026-025-ANCHORS (Phase F2 VP finalization, verification-delta.md v1.3 §7 Part D): (1) Invariant #4 hard-floor block: added VP-HOOK-026 verification property note explicitly naming the asset_type=unknown conservative hard-floor leg — LOW-severity + benign-technique + unknown-asset verdict NEVER receives a marker; SM-29 (unknown-asset-hard-floor-removed) is the kill target. VP-HOOK-026 row added to Verification Properties table. (2) PC#2 (investigation-markdown 12-field path): added explicit VP-HOOK-025 citation with per-class split (investigation-markdown 12-field / verdict-JSON 15-field). (3) PC#3 (verdict-JSON 15-field path): added explicit VP-HOOK-025 citation with per-class split (verdict-JSON 15-field / investigation-markdown 12-field). Version-coherence sweep (P3-007/P3-009): no stale live-body BC cross-refs found in this file.
> - v1.10 (2026-07-20): ADV-F2-P3-001/P3-002/P3-003/P3-011: (1) [P3-001 CRITICAL] Inv#4 hard-floor list: added SEPARATE explicit check `verdict.asset_type == "unknown"` as a hard-floor member (NOT folded into CRITICAL_ASSET_TYPES set) — disposition-guard emitter refuses marker for unknown-asset verdicts per D-DEC-008 hard_floor_applies(). (2) [P3-002 MAJOR] Create emitter branch command_pattern now encodes `verdict.jira_project_key`: pattern updated to `^jr (--output json )?issue create .*--project <jira_project_key>`; null-check added — if `jira_project_key` is null/absent, emit allow WITHOUT marker (human gate required). Supersedes v1.9 "does NOT embed a run-scoped nonce" note — project-key IS the org binding, defeating cross-org marker fungibility. (3) [P3-003 MAJOR] PC#2 investigation-markdown path corrected: 15 mandatory field headings → 12 mandatory field headings; Severity, Asset Type, Ticket Action Type REMOVED from the investigation-markdown required-headings list (these 3 fields are ONLY required in the PC#3 JSON verdict path = 15 fields; investigation markdown = 12 ICD-203 fields per artifact-class branching — architecture-delta v1.4 §D-DEC-008-C). Previous v1.8 text preserved inline. (4) [P3-011 minor] Removed cross-tenant-indicator hard-floor leg from Inv#4 hard-floor list and removed the PENDING-DEFINITION cross-tenant indicator schema subsection — per D-DEC-005, plugin obligation is org_slug scoping only; cross-tenant indicator detection at the plugin layer is not implementable; cross-tenant isolation is enforced by the org_slug query-scoping invariant across BCs.
> - v1.9 (2026-07-20): ADV-F2-P2-001 (emitter ordering note, architecture-delta v1.3 §8.6.3): Added load-bearing stage-ordering note to Invariant #4 EMITTER role — this hook fires on the monitoring-loop's Stage 7 DOCUMENT verdict Write event, which PRECEDES the Stage 8 TICKET ACTION jr Bash call. The monitoring-loop must write the ICD-203 verdict document (Stage 7) before executing jr (Stage 8); reversing this order means no marker exists when require-review evaluates the jr call. Note on create-marker multiplicity: the iterative-consume fix in BC-3.01.001 v1.14 (ADV-F2-P2-003) handles concurrent same-scope markers on the consumer side; no run-scoped nonce is needed in the emitter command_pattern. The create command_pattern `^jr (--output json )?issue create ` is unchanged (bounded by org + single-use + TTL on the consumer side).
> - v1.8 (2026-07-20): ADV-F2-001/ADV-F2-003/ADV-F2-004/ADV-F2-016: **UPDATED** — Canonical marker schema v2.0 (D-DEC-001): removed `ttl_seconds`, `used`, `expires_at` (old form); added `issued_at_utc`, `expires_at_utc` (= issued_at_utc + 120 seconds), ticket-bound `command_pattern` with `(--output json )?` optional group per D-DEC-008 generation table, `disposition.severity` + `disposition.asset_type` sub-fields. Hard-floor check re-keyed to `verdict.severity` (field 13) and `verdict.asset_type` (field 14) — NOT `confidence` (orthogonal axes; ADV-F2-001 CRITICAL fix; old confidence-proxy wording preserved as Previous block). Create-scoped, assign-scoped, and none emitter branches added (ADV-F2-004); emitter reads `verdict.ticket_action_type` (field 15) to select branch. Cross-tenant-indicator schema defined in Inv#4 (ADV-F2-016). Verdict field count updated 12 → 15 (severity + asset_type + ticket_action_type); all 15 enforced via dual-path (heading-anchored markdown + jq key-presence JSON).
> - v1.0 (2026-07-19): Initial extraction from `disposition-guard.sh` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): ADV-0-403: Re-anchored stale BATS test references to @test names at current line positions (post-PR #14).
> - v1.2 (2026-07-19): ADV-0-501: Annotated PC#2, EC-003, and canonical vector row 2 as HOOK-ISOLATED — in standard workflow, Stage 7 generates investigation document once from a complete template; enrichment-completeness BC-3.02.001 co-fires and denies any file missing four required sections. Added Aggregate Gate Behavior note. ADV-0-507: Normalized input-hash to dual-file form (.sh + .ps1).
> - v1.3 (2026-07-19): ADV-0-605: Added EC-009 (SM-1/DI-004 negating-substring false-pass) as first-class edge case and corresponding canonical test vector row; updated Refactoring Notes Undocumented behavior paragraph to reference DI-004/SM-1/EC-009/HS-014. ADV-0-606: Upgraded PC#3 confidence from "inferred" to "verified" based on confirmed hooks.json PreToolUse/Write matcher.
> - v1.4 (2026-07-19): ADV-0-B01: Updated all live hooks.bats line-number citations to current positions (PR #15 shifted disposition-guard tests +88 lines). hooks.bats references now use @test names for churn resilience.
> - v1.5 (2026-07-19): RESYNC-PR17: DI-004/SM-1 **RESOLVED** — PR #17 replaced bare `grep -qiF "Alternatives Considered"` with heading-anchored `grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"` (`disposition-guard.sh:57`). Body-text negation phrases no longer falsely satisfy the gate. EC-009 canonical output flipped allow→deny. Canonical test vector row 5 flipped. Refactoring Notes defect paragraph updated to RESOLVED. Two new BATS tests added: `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323) and `@test "disposition-guard heading-form alternatives-considered allows"` (hooks.bats:330). input-hash recomputed (both .sh and .ps1 changed in PR #17).
> - v1.6 (2026-07-20): D-DEC-001/ICD-203: **UPDATED** — Added two new responsibilities to this hook: (1) **ICD-203 12-field enforcement** — validates all 12 mandatory §3.8 fields via dual-path (heading-anchored markdown check for investigation files; JSON key-presence validation for monitoring-loop verdict files). (2) **EMITTER role** — after ICD-203 validation passes AND hard-floor check passes, disposition-guard writes `${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json` to authorize downstream `jr issue comment`. This is the ONLY marker issuance path. VP-HOOK-025 updated to list all 12 ICD-203 fields (correcting the F1 draft which listed only 8). New ECs: EC-010..EC-012. Tuning_signal null-vs-absent semantics documented.
> - v1.7 (2026-07-20): FV-VP-HOOK-025-FINALIZED: VP-HOOK-025 finalized per verification-delta §1/§3(a) — dropped `(PROPOSED)` from BATS test names; removed stale Note about F1 draft correction; added explicit dual-path mechanism reference (heading-anchored grep for investigation markdown; jq has()-based key-presence + per-field type assertions for verdict JSON). PC#4 updated with explicit three-way jq encoding to preempt SM-18 null/absent conflation mutation vector.

## Preconditions

1. The hook receives a `PreToolUse/Write` event envelope via stdin as JSON, containing `tool_input.file_path` (string) and `tool_input.content` (string). Confidence: verified by code analysis (`hooks/disposition-guard.sh:39-40`).
2. `jq` is installed and available on `$PATH`. Confidence: verified by code analysis (`hooks/disposition-guard.sh:14-17`).
3. The hook fires on the same `PreToolUse/Write` events as `enrichment-completeness`. Both hooks run on every Write event; each applies its own path-pattern filter. Confidence: verified against hooks.json PreToolUse/Write matcher (both enrichment-completeness.sh and disposition-guard.sh confirmed in the same Write hooks array — sequential execution, deny from either wins) and BATS test structure.

## Postconditions

1. **[UPDATED v1.12] Verdict file path — JSON-FIRST dispatch (ADV-F2-P4-001 CRITICAL — D-DEC-008 v1.6):**

   **Dispatch is evaluated in this exact order (most specific first):**

   - **Check 1 — JSON-content or .json-extension (verdict-class, THIS postcondition):** If `tool_input.file_path` ends in `.json` OR `tool_input.content` parses as valid JSON (`jq empty 2>/dev/null` succeeds) → route to **VERDICT JSON path** (body of this postcondition — **18-field** jq key-presence + type check — P10-001/P11-002). This check takes absolute precedence regardless of any `investigation` substring in the path. Rationale: the canonical verdict file path `artifacts/investigations/verdict-<alert_id>-<iso_ts>.json` contains BOTH the `investigation` directory component AND the `verdict` filename component. Under the prior substring dispatch, the `investigation` check matched first and routed a JSON file to the markdown branch, which then failed heading-grep assertions on JSON content → DENY → no marker → autonomous pipeline permanently unreachable (ADV-F2-P4-001 CRITICAL). JSON-first dispatch resolves the collision.
   - **Check 2 — investigation-*.md glob (investigation-class, PC#2):** Elif `tool_input.file_path` matches `*investigation-*.md` (must end in `.md`) → route to INVESTIGATION MARKDOWN path (PC#2 below — 12-field heading-anchored grep). The `.md` extension guard is mandatory: it prevents `.json` files with `investigation` in the path from misrouting to the markdown branch.
   - **Check 3 — fast-path allow (PC#3):** Else → `emit allow` without any ICD-203 enforcement.

   > **Previous (v1.11) dispatch order:** (1) if `file_path` does not contain `investigation` AND does not contain `verdict` → emit allow (fast path); (2) elif `file_path` contains `investigation` (substring, no extension guard) → investigation-markdown path; (3) elif `file_path` contains `verdict` (substring) → verdict-JSON path. This substring-only dispatch caused a routing collision: `artifacts/investigations/verdict-<id>.json` matched both the `investigation` (directory component) and `verdict` (file component) substring checks, with the investigation check winning in evaluation order — a JSON file was routed to the markdown 12-field branch.

   **Verification property (VP-HOOK-028 — FINALIZED, JSON-first dispatch surface, v1.13):** PC#1 Check-1 is the JSON-first canonical-path dispatch enforcement surface: a file whose content parses as JSON OR whose path ends `.json` is unconditionally routed to the verdict-class 18-field path, regardless of any `investigation` directory substring in the path. This closes the routing collision where `artifacts/investigations/verdict-*.json` was misrouted to the markdown 12-field branch (ADV-F2-P4-001 CRITICAL). VP-HOOK-028 covers this JSON-first dispatch regression (verification-delta.md v1.5 §2 — extended from verdict-path-reachability; BC-10.01.001 Stage-7 PC#8 is the authoritative definition).

   If the JSON-first check fires (Check 1), the hook enters **ICD-203 18-field validation (JSON path — P10-001/P11-002)**. The hook validates JSON key presence (not heading anchoring) for all **18** mandatory fields: `disposition`, `confidence`, `sensor_health_status`, `evidence_artifacts`, `timeline_events`, `hypotheses_considered`, `alternatives_rejected`, `uncertainty_explicit`, `attack_techniques`, `agent_actions`, `human_actions`, `tuning_signal`, `severity`, `asset_type`, `ticket_action_type`, `native_severity`, `sensor_family`, `scored_priority`. The check is key-presence only — a key with JSON `null` value IS present (valid for TP/Indeterminate for `tuning_signal`); a key that is entirely absent is INVALID. `native_severity` (field 16) must be a non-empty string; `sensor_family` (field 17) must be a member of `{crowdstrike, armis, claroty, cyberint}`; `scored_priority` (field 18) must be a member of `{CRIT, HIGH, MED, LOW}`. If any of the **18** keys is absent (or native_severity is empty, or sensor_family/scored_priority is a non-member enum value), the hook emits `permissionDecision: deny` with reason identifying the missing or invalid field (EC-010). If all **18** keys are present and valid, the hook validates `tuning_signal` semantics (postcondition #4), then proceeds to the EMITTER role (Invariant #4). **Verification property (VP-HOOK-025 — FINALIZED, per-class split v1.19 — P11-002 update):** VP-HOOK-025 covers this verdict-JSON **18-field** path: jq has() key-presence + per-field type assertions for all **18** fields including the 3 verdict-only fields (severity/asset_type/ticket_action_type) plus fields 16–18 (native_severity/sensor_family — P10-001 hook-side re-normalization inputs; scored_priority — P11-002 Stage-5 assess-priority output). Per-class split explicit: verdict-JSON **18**-field path / investigation-markdown 12-field path (verification-delta.md v1.3 §2 / ADV-F2-P3-008; VP-HOOK-030 (STEP 1a SEVERITY-MISMATCH) + SM-44 [ID-sync per FV]).

   > **Previous (v1.7):** "ICD-203 12-field validation (JSON path). The 12 mandatory fields: disposition, confidence, sensor_health_status, evidence_artifacts, timeline_events, hypotheses_considered, alternatives_rejected, uncertainty_explicit, attack_techniques, agent_actions, human_actions, tuning_signal." (No severity/asset_type/ticket_action_type enforcement.)

2. **Investigation file path (`*investigation-*.md` glob — .md extension required):**

   - **Dispatch condition (Check 2 — updated v1.12):** `tool_input.file_path` matches the glob `*investigation-*.md` (must end in `.md`). The `.md` extension guard prevents `.json` files containing `investigation` in their path from misrouting to this branch after JSON-first Check 1 exits without matching.

   > **Previous (v1.11) dispatch condition:** "`file_path` contains `investigation` as a substring" (no extension guard; caused routing collision with verdict JSON files at paths like `artifacts/investigations/verdict-*.json`).

   - If `file_path` matches the investigation-*.md glob but `content` does not contain the string "Disposition" (case-insensitive), the hook emits `permissionDecision: allow` — the document is still in-progress. Confidence: verified by code analysis (`hooks/disposition-guard.sh:48-51`) and test `@test "disposition-guard allows investigation without disposition yet"` (hooks.bats:252). **HOOK-ISOLATED behavior**: in the standard investigate-event workflow, Stage 7 generates the investigation document once from a complete template (event-investigation-tmpl.yaml) that already contains all four required section headings; the enrichment-completeness hook (BC-3.02.001) co-fires on the same PreToolUse/Write event and would deny any investigation file missing those sections before this hook's in-progress-allow path is exercised.
   - If `file_path` matches the investigation-*.md glob AND `content` contains "Disposition" AND `content` does NOT contain a heading-form "Alternatives Considered" (i.e., `grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"` finds no match), the hook emits `permissionDecision: deny` with a reason containing "Alternatives Considered". Body text mentioning the phrase without a markdown heading does not satisfy the gate (DI-004 RESOLVED, PR #17). Confidence: verified by code analysis (`hooks/disposition-guard.sh:53-58`) and tests `@test "disposition-guard blocks disposition without alternatives"` (hooks.bats:258) and `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323).
   - **[UPDATED v1.10]** If the investigation-*.md glob matches AND both "Disposition" and "Alternatives Considered" headings are present, the hook enters **ICD-203 12-field validation (markdown path)** (artifact-class branching per architecture-delta v1.4 §D-DEC-008-C: investigation markdown = 12 ICD-203 fields; verdict JSON = 15 fields). The hook checks for the heading-anchored presence of all **12** mandatory fields as markdown section headings (`grep -qiE "^#{1,6}[[:space:]]+<field_name>"` for each field). The 12 mandatory field headings are: `Disposition`, `Confidence`, `Sensor Health Status`, `Evidence Artifacts`, `Timeline Events`, `Hypotheses Considered`, `Alternatives Rejected`, `Uncertainty Explicit`, `Attack Techniques`, `Agent Actions`, `Human Actions`, `Tuning Signal`. `Severity`, `Asset Type`, and `Ticket Action Type` are **NOT** required in the investigation-markdown validation path — they are monitoring-loop verdict fields only and are meaningless for a manual investigation (required exclusively in the PC#1 JSON verdict path). If any of the 12 headings is absent, the hook emits `permissionDecision: deny` with reason identifying the missing field (EC-010). If all 12 are present, the hook proceeds to the **Separate Human-Comment Marker Path (P11-004 / P12-002 / P13-001)** — this path does NOT enter the verdict emitter (Invariant #4); see 'Separate Human-Comment Marker Path' section in Invariant #4 for the authoritative pseudocode. Post-P13-001 routing: (a) GATE 1 — `autonomy_enabled` absent or not exactly true → allow-without-marker (kill-switch parity; file saved; no Jira action); (b) markdown-evaluable floors (Indeterminate/forbidden-technique/degraded-silent sensor) → `permissionDecision: deny` (MARKDOWN-HARD-FLOOR); (c) **no autonomous comment marker for any disposition** — `parsed_disposition == "FP"` → allow-without-marker (MARKDOWN_COMMENT_PATH ELIMINATED, P13-001; the analyst's Write is NOT denied; to surface an FP comment via Jira the analyst must use the review path or the normal 18-field verdict flow); `parsed_disposition != "FP"` or PARSE_FAIL → review marker (create-review or comment-review, MARKDOWN_REVIEW_PATH, EXEMPT from kill switch). **Verification property (VP-HOOK-025 — FINALIZED, per-class split v1.19):** VP-HOOK-025 covers this investigation-markdown 12-field path: heading-anchored grep for each of the 12 fields; Severity, Asset Type, Ticket Action Type are NOT required as headings (verdict-JSON-only fields per D-DEC-008-C). Per-class split explicit: investigation-markdown 12-field path (uses Separate Human-Comment Marker Path) / verdict-JSON 18-field path (uses verdict emitter) (verification-delta.md v1.3 §2 / ADV-F2-P3-008).

   > **Previous (v1.20):** "If all 12 are present, the hook proceeds to the **Separate Human-Comment Marker Path (P11-004)** — ... If the separate path's markdown-evaluable floors pass, a comment-scoped marker is written and `permissionDecision: allow` is emitted." (Described pre-P13-001 behavior where FP + autonomy_enabled=true produced a comment marker via MARKDOWN_COMMENT_PATH. MARKDOWN_COMMENT_PATH eliminated at v1.21/P13-001 — the hook cannot evaluate scored_priority/asset_type from a 12-field markdown and no known-FP store cross-check applies on this path.)

   > **Previous (v1.8):** "ICD-203 **15**-field validation (markdown path). The 15 mandatory field headings are: `Disposition`, `Confidence`, `Sensor Health Status`, `Evidence Artifacts`, `Timeline Events`, `Hypotheses Considered`, `Alternatives Rejected`, `Uncertainty Explicit`, `Attack Techniques`, `Agent Actions`, `Human Actions`, `Tuning Signal`, `Severity`, `Asset Type`, `Ticket Action Type`. If any of the 15 headings is absent, the hook emits `permissionDecision: deny`..." (Applied 15-field check to investigation markdown — erratum per architecture-delta v1.4 §D-DEC-008-C. Investigation markdown requires only the 12 ICD-203 baseline fields; Severity/Asset Type/Ticket Action Type are monitoring-loop verdict fields and are meaningless for a manual investigation. ADV-F2-P3-003 MAJOR fix.)

   > **Previous (v1.7):** "ICD-203 12-field validation (markdown path). The 12 mandatory field headings are: Disposition, Confidence, Sensor Health Status, Evidence Artifacts, Timeline Events, Hypotheses Considered, Alternatives Rejected, Uncertainty Explicit, Attack Techniques, Agent Actions, Human Actions, Tuning Signal." (No Severity/Asset Type/Ticket Action Type enforcement.)

   > **Previous (v1.5):** "If `file_path` contains `investigation` AND `content` contains both 'Disposition' and 'Alternatives Considered', the hook emits `permissionDecision: allow`." (No ICD-203 12-field validation; no marker emission.)

3. **Fast-path allow (else — Check 3):**

   If neither Check 1 (JSON-first verdict-class) nor Check 2 (investigation-*.md investigation-class) matches, the hook emits `permissionDecision: allow` without any ICD-203 enforcement. This covers all other Write events (e.g., `/tmp/readme.md`, `artifacts/notes.txt`, etc.). Confidence: verified by code analysis (`hooks/disposition-guard.sh:43-45`).

   > **Previous (v1.11):** Fast-path was postcondition #1 (first check): "if `file_path` does not contain `investigation` AND does not contain `verdict` → emit allow." With JSON-first dispatch, the fast-path becomes the fallthrough (Check 3 / postcondition #3). The canonical path fast-path condition is now: neither JSON content/extension nor `*investigation-*.md` glob matches.

4. **[NEW v1.6] `tuning_signal` null-vs-absent semantics (SM-18 prevention):**

   After the 12-field presence check passes, the hook validates `tuning_signal` against the disposition using an explicit three-way jq check (distinct steps prevent `has()` / `!= null` conflation — SM-18 mutation vector):

   **Step 1 — key-absent check (unconditional, ALL dispositions):**
   ```
   jq -e 'has("tuning_signal")'
   ```
   If false: emit deny, reason "ICD-203 required field missing: tuning_signal (key absent — not the same as null)". This applies regardless of disposition value. A key-absent `tuning_signal` is ALWAYS invalid.

   **Step 2 — disposition-conditional semantics (only if Step 1 passes):**
   - If `disposition` is `FP` or `BTP`:
     ```
     jq -e '.tuning_signal!=null and (.tuning_signal|type=="object") and (.tuning_signal|has("rule_id") and has("asset") and has("reason"))'
     ```
     If false: emit deny, reason "tuning_signal must be a non-null object with rule_id/asset/reason for FP/BTP" (EC-011). A JSON `null` value is INVALID for FP/BTP.

   - If `disposition` is `TP` or `Indeterminate`:
     ```
     jq -e '.tuning_signal==null or (.tuning_signal|type=="object")'
     ```
     If false: emit deny (malformed tuning_signal — neither null nor object). A JSON `null` value is VALID for TP/Indeterminate.

   **Summary:** key-absent = INVALID in ALL cases (Step 1 kills it before disposition check); null = valid for TP/Indeterminate only (Step 2 TP/Indeterminate branch); non-null object = valid for FP/BTP only (Step 2 FP/BTP branch).

5. The "Disposition" check is case-insensitive substring (`grep -qiF`). The "Alternatives Considered" check uses a heading-anchored case-insensitive regex (`grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"`) — body text mentioning the phrase without a markdown heading does not satisfy the gate (DI-004 RESOLVED, PR #17). Confidence: verified by code analysis (`hooks/disposition-guard.sh:48, 57`) and `@test "disposition-guard heading-form alternatives-considered allows"` (hooks.bats:330).

## Invariants

1. The hook only blocks at the Disposition-present + Alternatives-absent intersection for investigation files. It never blocks an in-progress investigation file (one without a Disposition section yet). Confidence: verified by code analysis.
2. The hook does not validate the quality or count of alternatives — it only checks that the section heading appears. One alternative or ten alternatives are treated identically by this hook. Confidence: verified by code analysis.
3. The deny reason always references the specific missing section name "Alternatives Considered" and contains guidance about documenting at least 2 alternative hypotheses. Confidence: verified by code analysis (`hooks/disposition-guard.sh:55`).

4. **[UPDATED v1.12; corrected v1.19 P11-004] EMITTER role — this hook is the ONLY marker issuance path (D-DEC-001).** After ICD-203 validation passes (postcondition #1 — verdict-class path), the hook enters the emitter decision tree. The emitter is entered ONLY from the verdict-class (PC#1 JSON path). The investigation-markdown path (PC#2) does NOT enter this emitter — it uses a SEPARATE minimal comment-scoped marker path (P11-004 — see 'Separate Human-Comment Marker Path' section within this invariant for the pseudocode). The emitter reads `verdict.ticket_action_type` (field 15) to select the marker scope branch.

   **Document-Before-Action stage-ordering constraint (ADV-F2-P2-001 — v1.9):** This hook fires on the `PreToolUse/Write` event for the monitoring-loop's Stage 7 DOCUMENT verdict write. Stage 7 DOCUMENT **MUST PRECEDE** Stage 8 TICKET ACTION (the jr Bash call). The monitoring-loop must write the ICD-203 verdict file (Stage 7) before executing jr (Stage 8). If the monitoring-loop attempts jr BEFORE writing the verdict, this hook has not fired, no marker exists, and require-review will deny every jr write call.

   **Emitter decision tree (D-DEC-008 v1.6 — full pseudocode):**

   ```
   # ── STEP 0: Dispatch note (ADV-F2-P4-001 / P11-004) ─────────────────────
   # This pseudocode is entered ONLY from the JSON-first dispatch (PC#1) — i.e.,
   # after the write is routed to the verdict-class path (18-field check passed —
   # P10-001/P11-002).
   # The investigation-markdown path (PC#2) has its own separate pseudocode
   # and does NOT reach this emitter (P11-004 — see "Separate Human-Comment
   # Marker Path" section within Invariant #4 for that path's pseudocode).

   # ── STEP 1: Enum-membership validation — fail-closed (ADV-F2-P4-006 MAJOR) ─
   # Key-presence check (jq has()) alone is insufficient: severity:"High" passes
   # has() but fails the {HIGH,CRITICAL} hard-floor membership test → no hard
   # floor → regular marker issued for a genuinely HIGH-severity alert.
   # Fail-closed deny on any non-member value prevents this class of bypass.
   # VP-HOOK-025 cross-reference (v1.13): validate_enums() is the enum-membership
   # gate extension of VP-HOOK-025 (ADV-F2-P4-006 MAJOR). VP-HOOK-025 now covers
   # both the 18-field key-presence/type check AND the fail-closed membership
   # validation for all typed fields — wrong-case/non-member values (e.g.
   # severity:"High", disposition:"indeterminate") receive DENY before hard floor
   # is evaluated (verification-delta.md v1.5 §2 / §7 Part E item 2b).
   FUNCTION validate_enums(verdict):
     SEVERITY_ENUM      = {"LOW","MEDIUM","HIGH","CRITICAL"}
     ASSET_TYPE_ENUM    = {"domain_controller","privileged_account","ot_safety_system","standard","unknown"}
     DISPOSITION_ENUM   = {"TP","FP","BTP","Indeterminate"}
     SENSOR_ENUM        = {"healthy","degraded","silent"}
     ACTION_ENUM        = {"comment","create","assign","none","create-review","comment-review"}
     CONFIDENCE_ENUM    = {"high","medium","low"}
     SENSOR_FAMILY_ENUM    = {"crowdstrike","armis","claroty","cyberint"}  # P10-001: field 17
     SCORED_PRIORITY_ENUM  = {"CRIT","HIGH","MED","LOW"}                  # P11-002: field 18
     # P12-003 note: SEVERITY_TO_SCORED_PRIORITY_MAP = {CRITICAL→CRIT, MEDIUM→MED, HIGH→HIGH, LOW→LOW}
     # Maps SEVERITY_ENUM → SCORED_PRIORITY_ENUM. On the known-FP fast-path (Stage 5 bypassed in
     # BC-10.01.001 EC-009), the monitoring loop MUST derive scored_priority via this map from
     # NORMALIZE_SEVERITY output — NOT a raw assignment. Direct assignment produces non-member
     # tokens {CRITICAL, MEDIUM} that fail SCORED_PRIORITY_ENUM membership → DENY at this step.
     # SEVERITY_ENUM ≠ SCORED_PRIORITY_ENUM: {CRITICAL,HIGH,MEDIUM,LOW} vs {CRIT,HIGH,MED,LOW}
     # (CRIT ≠ CRITICAL; MED ≠ MEDIUM). The map is the required bridge.

     IF verdict.severity NOT IN SEVERITY_ENUM:
       RETURN (False, "severity '" + verdict.severity + "' not in allowed set (case-exact: HIGH not High)")
     IF verdict.asset_type NOT IN ASSET_TYPE_ENUM:
       RETURN (False, "asset_type '" + verdict.asset_type + "' not in allowed set")
     IF verdict.disposition NOT IN DISPOSITION_ENUM:
       RETURN (False, "disposition '" + verdict.disposition + "' not in allowed set")
     IF verdict.sensor_health_status NOT IN SENSOR_ENUM:
       RETURN (False, "sensor_health_status '" + verdict.sensor_health_status + "' not in allowed set")
     IF verdict.ticket_action_type NOT IN ACTION_ENUM:
       RETURN (False, "ticket_action_type '" + verdict.ticket_action_type + "' not in allowed set")
     IF verdict.confidence NOT IN CONFIDENCE_ENUM:
       RETURN (False, "confidence '" + verdict.confidence + "' not in allowed set (must be enum, not float)")
     # P10-001: validate fields 16 + 17 — required for STEP 1a SEVERITY-MISMATCH re-computation
     IF verdict.native_severity IS NULL OR verdict.native_severity == "":
       RETURN (False, "native_severity is absent or empty — required field 16 (P10-001)")
     IF verdict.sensor_family NOT IN SENSOR_FAMILY_ENUM:
       RETURN (False, "sensor_family '" + verdict.sensor_family + "' not in {crowdstrike,armis,claroty,cyberint} (P10-001)")
     # P11-002: validate field 18 scored_priority — fail-closed on non-member
     IF verdict.scored_priority NOT IN SCORED_PRIORITY_ENUM:
       RETURN (False, "scored_priority '" + verdict.scored_priority + "' not in {CRIT,HIGH,MED,LOW} (P11-002)")
     RETURN (True, "")

   (enum_ok, enum_err) = validate_enums(verdict)
   IF NOT enum_ok:
     emit deny("ICD-203 enum-membership validation failed: " + enum_err)
     RETURN
   # Note: emit deny (not allow) on enum failure — the document content is invalid

   # ── STEP 1a: Severity consistency check — SEVERITY-MISMATCH (P10-001 / P11-001 reframe) ──
   # O6 standing rule (P10-001/D-DEC-012 O3 table): inputs to a hook-computed invariant MUST
   # be hook-recomputable or hook-cross-validated. NORMALIZE_SEVERITY is the D-DEC-013
   # deterministic table (pure function over native_severity × sensor_family; no prism call).
   # This step fires on every verdict Write before any marker decision is made.
   # P11-001 REFRAME: STEP 1a is a DETERMINISTIC CONSISTENCY CHECK between verdict.severity
   # and verdict.native_severity (both LLM-supplied Stage-1 fields). The guarantee: verdict.severity
   # is consistent with verdict.native_severity per D-DEC-013. The residual: an adversarial LLM can
   # supply false native_severity + sensor_family; STEP 1a cannot detect this without an independent
   # source. THIS IS NOT ground-truth enforcement — it hardens against careless/buggy LLM
   # under-reporting only.
   # ASM-008-class residuals (symmetric, all ASM-008-DEFERRED):
   #   native_severity: LLM-supplied Stage-1 field; genuine enforcement requires hook-side prism
   #     cross-validation or a prism-signed field.
   #   asset_type: same residual — LLM-supplied; prism_asset_class cross-validation deferred.
   #   scored_priority: LLM-supplied (assess-priority is an LLM skill); same ASM-008-class residual.
   # NOTE: The HIGH/CRIT severity floor has moved to scored_priority (P11-002) — hard_floor_applies()
   # keys the floor on verdict.scored_priority, NOT on recomputed_severity. STEP 1a still fires
   # as a consistency check; recomputed_severity is passed to hard_floor_applies() for API
   # compatibility but no longer drives the high-severity floor internally.
   recomputed_severity = NORMALIZE_SEVERITY(verdict.native_severity, verdict.sensor_family)
   IF recomputed_severity != verdict.severity:
     WRITE audit entry:
       now_iso8601() + " SEVERITY-MISMATCH: verdict.severity='" + verdict.severity +
       "' does not match hook-recomputed severity='" + recomputed_severity +
       "' via NORMALIZE_SEVERITY(native_severity='" + verdict.native_severity +
       "', sensor_family='" + verdict.sensor_family + "') (P10-001/D-DEC-013)"
     emit deny(
       "SEVERITY-MISMATCH: disposition-guard recomputed severity='" + recomputed_severity +
       "' from (native_severity='" + verdict.native_severity +
       "', sensor_family='" + verdict.sensor_family +
       "') does not match verdict.severity='" + verdict.severity +
       "'. Verdict Write denied. Correct verdict.severity to match NORMALIZE_SEVERITY output (P10-001)."
     )
     RETURN
   # After STEP 1a: hard_floor_applies() receives recomputed_severity but keys HIGH/CRIT floor
   # on verdict.scored_priority (P11-002); recomputed_severity is no longer the floor driver.

   # ── STEP 2: Extract ticket_action_type ──────────────────────────────────
   action = verdict.ticket_action_type

   # ── STEP 3: Review-surfacing path (D-DEC-012) — EXEMPT from hard floor + kill switch ──
   # create-review and comment-review markers authorize human ESCALATION, not autonomous
   # TRIAGE. Creating a [REVIEW-REQUIRED] or [BLIND-SPOT] ticket IS the human-surface
   # mechanism — blocking it would silence a finding. These paths are therefore exempt from:
   #   (a) hard_floor_applies() — hard floor blocks autonomous triage, not human escalation
   #   (b) autonomy_enabled kill switch — kill switch disables autonomous decisions, not escalation
   #
   # GATE (ADV-F2-P5-002): Review-marker exemption requires hard_floor_applies(verdict)=TRUE.
   # O3 standing rule (ADV-F2-P5-003): LLM-supplied routing field (ticket_action_type) MUST be
   # cross-validated against hook-computed invariant (hard_floor_applies) before bypass is granted.
   # A non-hard-floor verdict that sets ticket_action_type=create-review/comment-review is an
   # over-label; the kill-switch + hard-floor exemption is NOT granted for over-labeled verdicts —
   # emit allow without marker (falls through to STEP 4/5/6 for regular processing).
   #
   # Kill-switch semantics CONFIRMED 2026-07-21 (Option A, human-gate): create-review and
   # comment-review markers ARE issued and consumed under autonomy_enabled=false when
   # hard_floor_applies(verdict)=true. Brief §3.9 amended same burst.
   #
   # FAIL-LOUD invariant: no hard-floor verdict is EVER silently discarded:
   #   - Correctly-labeled + bindable (create-review/comment-review + hard_floor=true + binding field present): handled HERE at STEP 3; review marker issued.
   #   - Correctly-labeled + UNBINDABLE (create-review + null project_key; comment-review + null ticket_id): HARD-FLOOR-UNBINDABLE deny path (P8-001/D-DEC-012 clause 2) — see below; deny + audit entry; no Jira write; bounded fail-closed.
   #   - Under-labeled (non-review action type + hard_floor=true): STEP 4 deny-the-Write handles
   #     (fires BEFORE kill switch per ADV-F2-P6-002; ADV-F2-P7-001 REDESIGN — see STEP 4 below).
   # Iron Law (updated ADV-F2-P6-001): create-review/comment-review markers are scoped ONLY to
   # [REVIEW-REQUIRED] or [BLIND-SPOT] ticket creates/comments. The monitoring-loop MUST include
   # `--label (REVIEW-REQUIRED|BLIND-SPOT)` as the SECOND fixed argument after `--project <key>`
   # in every `jr issue create` call for a review-path ticket (mirrors the P4-002 Iron Law:
   # `--project` in FIRST fixed position; review-label in SECOND fixed position).
   # Require-review NOW enforces label content structurally via the command_pattern (create-review
   # pattern includes `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed second position per ADV-F2-P6-001)
   # AND via consumer STEP 6a cross-check. SKILL.md Iron Law remains as defense-in-depth.
   # Note: comment-review structural label check (analogous to create-review) pending ASM-014 —
   # empirical validation that `jr issue comment --label` is supported; current guard for
   # comment-review: ticket_id binding + Iron Law.
   # VP-HOOK-026 cross-reference (v1.15): Step 3 is the create-review/comment-review hard-floor-
   # EXEMPT and kill-switch-EXEMPT emitter path — GATED on hard_floor_applies()=true (P5-002).
   # VP-HOOK-026 covers over-label test vectors: non-hard-floor + create-review → emit allow
   # WITHOUT marker (over-label rejected). (verification-delta.md v1.5 §2 / §7 Part E).
   # VP-HOOK-029 cross-reference (v1.17, ADV-F2-P7-001/P8-001 CRITICAL): Step 3 handles correctly-labeled
   # hard-floor verdicts: bindable path issues review marker; UNBINDABLE path (P8-001) emits
   # HARD-FLOOR-UNBINDABLE deny + audit entry (see below). STEP 4 (before kill switch per
   # ADV-F2-P6-002) handles under-labeled hard-floor verdicts via DENY-THE-WRITE — emitting
   # UNDER-LABEL-DENIED audit entry; the loop re-issues the verdict Write with the corrective
   # review token; STEP 3 then processes the corrected Write.
   # VP-HOOK-029 (FINALIZED P0 — verification-delta v1.10): covers end-to-end consumer-boundary
   # outcome per O4 standing rule — deny-path vectors (SM-38: STEP-4 deny removed; SM-39:
   # corrective-reason structure removed), re-doc path, AND unbindable-deny vectors (P8-001:
   # create-review + null project_key; comment-review + null ticket_id) are all active kill targets.
   IF action in {"create-review", "comment-review"}:
     # O3 gate: cross-validate LLM-supplied review token against hook-computed invariant.
     IF NOT hard_floor_applies(verdict, recomputed_severity):
       emit allow without marker   # over-label: non-hard-floor verdict; exemption NOT granted
       RETURN
     IF action == "create-review":
       project_key = verdict.jira_project_key
       IF project_key is null OR project_key == "":
         # P8-001 CRITICAL FIX — DENY-THE-WRITE (D-DEC-012 clause 2):
         # A hard-floor verdict with create-review but no jira_project_key cannot be bound to a
         # review marker. Silent allow-without-marker here is the P5-001 anti-pattern applied to
         # the review path: hard-floor finding silently discarded, no audit trail, no review ticket.
         # D-DEC-012 clause 2 mandates "explicit error artifact written to audit.log AND a deny
         # emitted" — fail loud instead.
         #
         # Non-termination: if the loop re-documents create-review and STILL omits jira_project_key,
         # this deny fires again — exactly one HARD-FLOOR-UNBINDABLE audit entry + one deny per
         # attempt; no Jira write; no silent loop. Bounded fail-closed, mirroring the STEP 4
         # analysis: the deny + audit entry ARE the loud failure.
         WRITE audit entry:
           "HARD-FLOOR-UNBINDABLE: hard-floor create-review verdict with missing jira_project_key" +
           "; missing_field=jira_project_key" +
           "; verdict Write denied by disposition-guard (P8-001/D-DEC-012 clause 2)"
         emit deny(
           "HARD-FLOOR-UNBINDABLE: cannot bind create-review marker without jira_project_key. " +
           "hard_floor_trigger=" + identify_hard_floor_trigger(verdict) + ". " +
           "missing_field=jira_project_key. " +
           "Re-issue this Write with jira_project_key populated in the verdict."
         )
         RETURN
       # P12-001/O7: charset-validation before interpolating jira_project_key into command_pattern
       # jira_project_key is derived from verdict.jira_project_key (operator-configured field in
       # prism.toml/verdict — not a static hook constant). A crafted value defeats property (d).
       IF NOT regex_match("^[A-Z][A-Z0-9]+$", project_key):
         WRITE audit entry:
           now_iso8601() + " PROJECT-KEY-CHARSET-DENY: create-review path jira_project_key='" +
           project_key + "' failed charset validation (required: ^[A-Z][A-Z0-9]+$) (P12-001/O7)"
         emit deny(
           "PROJECT-KEY-CHARSET-DENY: jira_project_key contains invalid characters or metacharacters. " +
           "Required format: ^[A-Z][A-Z0-9]+$ (e.g., SEC, PRISM). " +
           "jira_project_key='" + project_key + "' rejected before command_pattern interpolation (P12-001/O7)."
         )
         RETURN
       project_key = regex_escape(project_key)   # defense-in-depth after charset check
       # ADV-F2-P4-002: --project MUST be first arg; trailing ( |$) prevents prefix-match
       # ADV-F2-P6-001: --label (REVIEW-REQUIRED|BLIND-SPOT) in FIXED SECOND position after --project
       pattern = "^jr (--output json )?issue create --project " + project_key + " --label (REVIEW-REQUIRED|BLIND-SPOT)( |$)"
       ops = ["create-review"]
       ticket_id = null
       GOTO WRITE_MARKER
     ELIF action == "comment-review":
       ticket_id = verdict.ticket_id
       IF ticket_id is null:
         # P8-001 CRITICAL FIX — DENY-THE-WRITE (D-DEC-012 clause 2):
         # Same class as create-review + null project_key. Comment-review without ticket_id
         # cannot be bound to a marker. Fail loud.
         #
         # Fallback hint: if jira_project_key IS present, the corrective reason suggests
         # create-review (consistent with STEP 4 required_token logic: ticket_id=null →
         # required_token=create-review; the verdict may be mis-classified as comment-review
         # when no open ticket exists yet). If jira_project_key is also absent, note both
         # missing fields.
         #
         # Non-termination: same analysis as create-review case — one HARD-FLOOR-UNBINDABLE
         # audit entry + one deny per re-doc attempt; no Jira write; bounded fail-closed.
         project_key_fallback = verdict.jira_project_key
         IF project_key_fallback is null OR project_key_fallback == "":
           fallback_hint = "jira_project_key also absent — re-issue with ticket_id (comment-review) or jira_project_key (create-review) populated."
         ELSE:
           fallback_hint = "jira_project_key=" + project_key_fallback + " is present — BUT before re-issuing as create-review, the loop MUST re-run the §3.4 BLIND-SPOT/REVIEW-REQUIRED dedup query to confirm no open review ticket exists for this (org_slug, sensor_id). Null ticket_id may be a dedup-lookup miss; blindly switching to create-review risks duplicating a BLIND-SPOT/REVIEW-REQUIRED ticket (D-DEC-004 one-open-ticket violation). Re-run dedup first; only re-issue as create-review if dedup confirms no open ticket. (P9-007)"
         WRITE audit entry:
           "HARD-FLOOR-UNBINDABLE: hard-floor comment-review verdict with null ticket_id" +
           "; missing_field=ticket_id" +
           "; verdict Write denied by disposition-guard (P8-001/D-DEC-012 clause 2)"
         emit deny(
           "HARD-FLOOR-UNBINDABLE: cannot bind comment-review marker without ticket_id. " +
           "hard_floor_trigger=" + identify_hard_floor_trigger(verdict) + ". " +
           "missing_field=ticket_id. " +
           fallback_hint + " " +
           "Re-issue this Write with ticket_id populated (or switch to create-review if appropriate)."
         )
         RETURN
       # Note: ASM-014 pending (P10-008) — structural --label check for comment-review deferred
       # pending empirical validation that `jr issue comment --label` is supported by the jr CLI.
       # ASM-014 residual: comment-review kill-switch exemption is broader than "review ticket
       # only" — no --label binding constraint applies to comment-review path until ASM-014
       # resolves. Current guard: ticket_id binding + Iron Law only.
       # P12-001/O7: charset-validation before interpolating ticket_id into command_pattern
       # ticket_id is derived from verdict.ticket_id (loop-written from Jira/alert content — P12-001)
       IF NOT regex_match("^[A-Z][A-Z0-9]+-[0-9]+$", ticket_id):
         WRITE audit entry:
           now_iso8601() + " TICKET-ID-CHARSET-DENY: comment-review path ticket_id='" + ticket_id +
           "' failed charset validation (required: ^[A-Z][A-Z0-9]+-[0-9]+$) (P12-001/O7)"
         emit deny(
           "TICKET-ID-CHARSET-DENY: ticket_id contains invalid characters or metacharacters. " +
           "Required format: ^[A-Z][A-Z0-9]+-[0-9]+$ (e.g., SEC-123, PRISM-456). " +
           "ticket_id='" + ticket_id + "' rejected before command_pattern interpolation (P12-001/O7)."
         )
         RETURN
       ticket_id = regex_escape(ticket_id)   # defense-in-depth after charset check
       pattern = "^jr (--output json )?issue comment " + ticket_id + " "
       ops = ["comment-review"]
       GOTO WRITE_MARKER

   # ── STEP 4: Hard-floor DENY-THE-WRITE for under-label (ADV-F2-P7-001 REDESIGN) ──
   # ADV-F2-P7-001 REDESIGN — MARKER-UPGRADE APPROACH RETIRED:
   # The pass-5/pass-6 upgrade approach is RETIRED. The upgrade only rewrote the marker;
   # it CANNOT rewrite the Bash command the monitoring-loop LLM subsequently issues at Stage 8.
   # Under-labeling means the loop set a non-review ticket_action_type and will run the
   # corresponding non-review command. Walk the four under-label action types:
   #   - create: loop runs `jr issue create` without --label. create-review marker requires
   #     --label in fixed second position → consumer STEP-5 anchored pattern mismatch → DENY.
   #   - assign: loop runs `jr issue assign SEC-123`. comment-review marker pattern requires
   #     `issue comment SEC-123` (wrong verb) → DENY.
   #   - none: loop runs NO jr command at all. Marker expires unconsumed → silent drop.
   #   - comment: loop runs `jr issue comment SEC-123` — this one coincidentally worked.
   # Three of four under-label paths produced unconsumable markers. Hard-floor findings were
   # silently dropped at the consumer boundary. The "safety net" provided false assurance.
   #
   # FIX — DENY-THE-WRITE: at the point the verdict Write is evaluated (the ONLY point the
   # hook can still cause the loop to react before Stage 8), disposition-guard DENIES the
   # verdict Write with a structured machine-actionable corrective reason. The loop MUST
   # re-issue the verdict Write with ticket_action_type set to the corrective review token;
   # on the corrected Write STEP 3 issues the review marker normally. No marker is issued
   # on this deny path.
   #
   # autonomy_enabled is IRRELEVANT — deny fires regardless of autonomy_enabled value.
   # STEP 4 remains BEFORE STEP 5 kill switch — deny fires before kill switch.
   # Bounded fail-closed: the deny + UNDER-LABEL-DENIED audit entry ARE the loud failure.
   # IRON LAW (ADV-F2-P7-003): monitoring-loop MUST set the correct review token in the first
   # place. This deny is a deterministic safety net, NOT a delegation of labeling responsibility.
   IF hard_floor_applies(verdict, recomputed_severity):
     required_token = "comment-review" IF verdict.ticket_id is NOT null ELSE "create-review"
     deny_entry = now_iso8601() + " UNDER-LABEL-DENIED " +
                  "original_action=" + action +
                  " required_token=" + required_token +
                  " verdict=" + verdict.disposition +
                  " severity=" + verdict.severity
     append(deny_entry, "${CLAUDE_PLUGIN_DATA}/markers/audit.log")
     emit deny(JSON({
       "error": "HARD-FLOOR-UNDER-LABEL",
       "hard_floor_trigger": verdict.disposition + "/" + verdict.severity + "/" + (verdict.asset_type or verdict.attack_techniques_summary),
       "required_token": required_token,
       "label_instruction": "for create-review: --label (REVIEW-REQUIRED|BLIND-SPOT) MUST appear as the SECOND fixed arg after --project <key>; no flags interposed",
       "message": "re-issue verdict Write with ticket_action_type='" + required_token + "'"
     }))
     RETURN

   # ── STEP 5: autonomy_enabled kill switch (ADV-F2-P4-005 MAJOR) [REORDERED AFTER HARD-FLOOR — ADV-F2-P6-002] ──
   # ADV-F2-P6-002: After reorder, this STEP 5 is only reached for non-hard-floor verdicts.
   # Hard-floor under-labeled verdicts (STEP 4 above) and correctly-labeled review verdicts
   # (STEP 3 above) both exit before this point. The kill switch now fires exclusively for
   # regular-action, non-hard-floor verdicts — the intended semantic.
   # autonomy_enabled is a NON-ICD-203 operational metadata field in the verdict JSON
   # (alongside jira_project_key and confidence_score). Disposition-guard reads it
   # directly from the verdict file (not delegated to the monitoring-loop LLM).
   # Default-false (conservative): if field is absent, null, or non-boolean → treat as false.
   # This makes the kill switch deterministic — not delegated to LLM reasoning.
   # VP-HOOK-026 cross-reference (v1.15): Step 5 (formerly STEP 4) is the autonomy_enabled
   # kill-switch leg. VP-HOOK-026 covers the determinism property: autonomy_enabled read
   # DIRECTLY from the verdict JSON (not from LLM layer); false/absent/non-boolean →
   # conservative false → ALL regular markers (comment/create/assign) suppressed;
   # create-review/comment-review review markers (Step 3) are EXEMPT and already handled.
   # (verification-delta.md v1.5 §2 / §7 Part E item 2c).
   autonomy_enabled = verdict.autonomy_enabled   # non-ICD-203 operational field
   IF autonomy_enabled is NOT exactly boolean true:
     emit allow without marker   # kill switch fires; evidence write proceeds; no Jira action
     RETURN

   IF action == "none":
     emit allow without marker   # explicit none, non-hard-floor: ICD-203 document is valid
     RETURN

   # ── STEP 6: Regular marker issuance (non-hard-floor, autonomy_enabled=true) ──
   IF action == "comment":
     ticket_id = verdict.ticket_id
     IF ticket_id is null: emit allow without marker; RETURN
     # P12-001/O7: charset-validation before interpolating ticket_id into command_pattern
     # ticket_id derived from Jira/alert content via verdict.ticket_id — not a static constant
     IF NOT regex_match("^[A-Z][A-Z0-9]+-[0-9]+$", ticket_id):
       WRITE audit entry:
         now_iso8601() + " TICKET-ID-CHARSET-DENY: comment path ticket_id='" + ticket_id +
         "' failed charset validation (P12-001/O7)"
       emit deny(
         "TICKET-ID-CHARSET-DENY: ticket_id='" + ticket_id + "' rejected before " +
         "command_pattern interpolation. Required: ^[A-Z][A-Z0-9]+-[0-9]+$ (P12-001/O7)."
       )
       RETURN
     ticket_id = regex_escape(ticket_id)   # defense-in-depth
     pattern = "^jr (--output json )?issue comment " + ticket_id + " "
     ops = ["comment"]

   ELIF action == "create":
     ticket_id = null
     project_key = verdict.jira_project_key
     IF project_key is null OR project_key == "":
       emit allow without marker   # cannot org-bind without project key (human gate required)
       RETURN
     # P12-001/O7: charset-validation before interpolating jira_project_key into command_pattern
     IF NOT regex_match("^[A-Z][A-Z0-9]+$", project_key):
       WRITE audit entry:
         now_iso8601() + " PROJECT-KEY-CHARSET-DENY: create path jira_project_key='" + project_key +
         "' failed charset validation (P12-001/O7)"
       emit deny(
         "PROJECT-KEY-CHARSET-DENY: jira_project_key='" + project_key + "' rejected before " +
         "command_pattern interpolation. Required: ^[A-Z][A-Z0-9]+$ (P12-001/O7)."
       )
       RETURN
     project_key = regex_escape(project_key)   # defense-in-depth
     # ADV-F2-P4-002: --project is FIRST arg (Iron Law); trailing ( |$) prevents prefix-match
     # Old (v1.10): "^jr (--output json )?issue create .*--project <jira_project_key>"
     # New: "^jr (--output json )?issue create --project <jira_project_key>( |$)"
     pattern = "^jr (--output json )?issue create --project " + project_key + "( |$)"
     ops = ["create"]

   ELIF action == "assign":
     ticket_id = verdict.ticket_id
     IF ticket_id is null: emit allow without marker; RETURN
     # P12-001/O7: charset-validation before interpolating ticket_id into command_pattern
     IF NOT regex_match("^[A-Z][A-Z0-9]+-[0-9]+$", ticket_id):
       WRITE audit entry:
         now_iso8601() + " TICKET-ID-CHARSET-DENY: assign path ticket_id='" + ticket_id +
         "' failed charset validation (P12-001/O7)"
       emit deny(
         "TICKET-ID-CHARSET-DENY: ticket_id='" + ticket_id + "' rejected before " +
         "command_pattern interpolation. Required: ^[A-Z][A-Z0-9]+-[0-9]+$ (P12-001/O7)."
       )
       RETURN
     ticket_id = regex_escape(ticket_id)   # defense-in-depth
     pattern = "^jr (--output json )?issue assign " + ticket_id + " "
     ops = ["assign"]

   # ── WRITE_MARKER: common path for all marker types ──────────────────────
   # P10-003: is_review_path flag gates fail-closed behavior on marker write failure.
   # Review-path marker failures must DENY (not allow-without-marker) because a review
   # marker that fails to write means the monitoring-loop LLM will issue a jr command
   # with no marker to validate against — hard-floor evidence silently dropped.
   # Regular (non-review) path retains the existing allow-without-marker behavior.
   WRITE_MARKER:
   expires_at = now() + 120s
   is_review_path = (action in {"create-review", "comment-review"})
   marker = {
     marker_id: generate_uuid(),
     issued_at_utc: now_iso8601(),
     expires_at_utc: expires_at,
     issued_by: "disposition-guard",
     ticket_id: ticket_id,
     org_slug: verdict.org_slug,
     authorized_operations: ops,
     command_pattern: pattern,
     disposition: {
       verdict: verdict.disposition,
       severity: recomputed_severity,  # P10-001: hook-recomputed severity, not LLM-supplied
       asset_type: verdict.asset_type,
       ticket_action_type: action
     }
   }
   write_ok = write_marker(marker, "${CLAUDE_PLUGIN_DATA}/markers/${marker.marker_id}.marker.json")
   IF NOT write_ok:
     IF is_review_path:
       # P10-003: review-path marker write failure is fail-closed — DENY not allow-without-marker.
       # A hard-floor finding on the review path MUST be escalated; silent allow risks losing the
       # finding entirely (the loop would run jr with no marker → consumer DENY at Stage 8/Step 5).
       WRITE audit entry:
         now_iso8601() + " MARKER-WRITE-FAILED: failed to write review marker for action=" + action +
         " marker_id=" + marker.marker_id +
         " marker_path=${CLAUDE_PLUGIN_DATA}/markers/${marker.marker_id}.marker.json" +
         " verdict=" + verdict.disposition + "/" + recomputed_severity + " (P10-003)"
       emit deny(
         "MARKER-WRITE-FAILED: disposition-guard could not write review marker for action='" + action +
         "'. Review-path marker write failures are fail-closed (P10-003). Investigate marker-store " +
         "write permissions at ${CLAUDE_PLUGIN_DATA}/markers/ and re-issue the verdict Write."
       )
       RETURN
     ELSE:
       emit allow without marker   # regular path: allow-without-marker retained (non-review)
       RETURN
   emit allow
   ```

   > **Previous (v1.11) emitter — no validate_enums, no autonomy_enabled, no review-surfacing path:** Emitter went directly from ICD-203 validation to hard-floor check to regular marker issuance. Enum membership was not validated (severity:"High" wrong-case could bypass hard floor). No autonomy_enabled kill switch. No create-review/comment-review paths (hard-floor verdicts silently received no marker and no review ticket). Create command_pattern used `.*--project <key>` (unbounded `.*` before `--project` allowed injection via `--summary` text).

   **Create-scope project-binding (v1.10 — ADV-F2-P3-002; pattern updated v1.12 — ADV-F2-P4-002):**

   > **Previous (v1.10) create pattern:** `^jr (--output json )?issue create .*--project <jira_project_key>` — the `.*` between `create ` and `--project` allowed an attacker-controlled `--summary "... --project ORG_A ..."` argument to satisfy the project key binding via prefix match. Also: `PROD` would match `PRODUCTION` (no trailing boundary). (ADV-F2-P3-002 cross-org fungibility attack; ADV-F2-P4-002 prefix-match bypass.)

   A create marker issued for `--project ORG-A` cannot authorize `jr issue create --project ORG-B` or `jr issue create --project ORG-A_EXTRA` (trailing `( |$)` ensures the key must be followed by a space or end-of-string). Anti-forgery is preserved: each marker is single-use via atomic rename; forged markers cannot be created by the LLM (filesystem-isolated from LLM surface).

   **P12-001/O7 security note — command_pattern inputs are content-derived (corrects implicit D-DEC-001/D-DEC-008 claim):** `ticket_id` IS derived from Jira/alert content on the verdict path (`verdict.ticket_id` is loop-written from ingested Jira/alert data at Stage 1 INGEST in BC-10.01.001) and from free-text markdown `content` on the Human-Comment path (`parse_ticket_id_from_markdown`). `jira_project_key` is derived from plugin state (prism.toml / verdict operational metadata), itself sourced from operator-configured data. Neither field is an intrinsic constant of the hook's logic — both are externally-influenced inputs. This corrects the prior implicit D-DEC-001/D-DEC-008 claim (echoed in earlier BC versions) that `command_pattern` was effectively "not derived from Jira ticket content." The accurate statement: `ticket_id` and `jira_project_key` ARE content-derived inputs; anchored matching (D-DEC-001 property (d)) alone is NOT sufficient when anchor components can contain regex metacharacters. A crafted `ticket_id=".*"` or `ticket_id="SEC-1|.*"` broadens the anchored pattern to authorize any `jr issue comment` command, defeating property (d). Metacharacter safety is now enforced by: (1) **charset-validation before interpolation** at all 5 sites (TICKET-ID-CHARSET-DENY / PROJECT-KEY-CHARSET-DENY — hard deny on mismatch); (2) **`regex_escape()` as defense-in-depth** applied after charset check. These two controls together preserve the anchored-match property (d) regardless of content-derived inputs. O7 standing rule: every value interpolated into a `command_pattern` MUST be charset-validated to a fixed grammar AND/OR regex-escaped; every interpolation site needs a covering VP with metacharacter-injection mutant. (P12-001/O7)

   **Canonical Marker JSON schema v2.1 (D-DEC-001 — single source of truth — ADV-F2-P5-003 sync):**

   ```json
   {
     "marker_id": "<uuid-v4>",
     "issued_at_utc": "<ISO-8601 UTC with Z suffix, e.g. 2026-07-20T14:30:00.000Z>",
     "expires_at_utc": "<ISO-8601 UTC with Z suffix; = issued_at_utc + 120 seconds>",
     "issued_by": "disposition-guard",
     "ticket_id": "<jira-ticket-id-string | null>",
     "org_slug": "<org-slug-string>",
     "authorized_operations": ["comment"] | ["create"] | ["assign"] | ["create-review"] | ["comment-review"],
     "command_pattern": "<anchored regex — see D-DEC-008 generation table below>",
     "disposition": {
       "verdict": "TP|FP|BTP|Indeterminate",
       "severity": "LOW|MEDIUM|HIGH|CRITICAL",
       "asset_type": "<asset_type_string>",
       "ticket_action_type": "<action>"
     }
   }
   ```

   **Operational metadata fields (non-ICD-203, not counted in 18 mandatory fields — P10-001/P11-002):**
   - `verdict.autonomy_enabled` (boolean, default-false): read by emitter at STEP 5 (kill switch); `false` or absent → kill switch fires (allow, no marker); `true` → proceed to regular marker issuance (STEP 6). Irrelevant for STEP 4 deny-the-Write path and STEP 3 review-surfacing path (both fire before STEP 5). Does NOT appear in the marker schema itself.
   - `verdict.jira_project_key` (string): org binding for create/create-review patterns.
   - `verdict.confidence_score` (float 0.0–1.0): raw posterior from assess-priority; D-DEC-011.

   **Schema v2.0 changes from v1.0 (ADV-F2-003 remediation):**
   - `ttl_seconds` REMOVED; `expires_at_utc` ADDED (absolute expiry = issued_at_utc + 120s). Consumer compares `now() > expires_at_utc` directly — no read-side clock-skew arithmetic.
   - `issued_at` renamed to `issued_at_utc` (Z-suffix required).
   - `used` field REMOVED. Single-use is enforced by atomic `mv` rename to `.marker.json.used` in require-review; the renamed file is excluded from `*.marker.json` glob (ADV-F2-018 dead-code removal).
   - `authorized_operations` values: `"comment"`, `"create"`, `"assign"`, `"create-review"` (D-DEC-012), `"comment-review"` (D-DEC-012). Never multi-element.
   - `disposition` sub-object ADDED with `verdict`, `severity` (field 13), `asset_type` (field 14), `ticket_action_type` (for audit trail).
   - TTL raised from 30s to 120s: empirically observed latency budget (hook execution + LLM decision latency + scheduling overhead) has 99th-percentile tail at ~90s; 120s provides 1.3× safety factor.

   **Schema v2.1 additions (ADV-F2-P5-003 sync — architecture-delta.md §D-DEC-001 v2.1):**
   - `authorized_operations` enum: formally includes `"create-review"` and `"comment-review"` (D-DEC-012 review-surfacing tokens; GATED on `hard_floor_applies()`=true at STEP 3 — P5-002 O3 standing-rule gate).
   - `disposition.verdict` enum: formally includes `"Indeterminate"` (hard-floor condition; never auto-closed; routes to review-surfacing path at STEP 3 when `ticket_action_type` is correctly set).
   - `disposition.ticket_action_type` sub-field: present in `disposition` sub-object (provides audit trail for STEP 3 routing decision and STEP 4 UNDER-LABEL-DENIED deny path (ADV-F2-P7-001) — see D-DEC-008 pseudocode).

   > **Previous (v1.6/v1.7):** Marker schema v1.0:
   > ```json
   > {
   >   "marker_id": "<uuid-v4>",
   >   "issued_at": "<ISO 8601 UTC>",
   >   "ticket_id": "<JIRA ticket ID extracted from file_path or content>",
   >   "authorized_operations": ["jr issue comment "],
   >   "command_pattern": "^jr issue comment <ticket_id>",
   >   "used": false,
   >   "expires_at": "<issued_at + 30 seconds>"
   > }
   > ```
   > (Schema v1.0 used `expires_at = issued_at + 30s`, `used: false` field, and comment-only scope with no ticket-bound pattern. Hard-floor check keyed on `confidence` as severity proxy — incorrect.)

   **Emitter scope selection — `verdict.ticket_action_type` (field 15; D-DEC-008 generation table v1.6):**

   | `ticket_action_type` | `ticket_id` | `command_pattern` generated | `authorized_operations` | Step |
   |---------------------|-------------|---------------------------|------------------------|------|
   | `"comment"` | from verdict (non-null) | `^jr (--output json )?issue comment <ticket_id> ` | `["comment"]` | Step 6 |
   | `"assign"` | from verdict (non-null) | `^jr (--output json )?issue assign <ticket_id> ` | `["assign"]` | Step 6 |
   | `"create"` | `null` | `^jr (--output json )?issue create --project <jira_project_key>( |$)` (**ADV-F2-P4-002**: `--project` is first arg; trailing `( |$)` prevents prefix-match; if `jira_project_key` null/absent → NO marker) | `["create"]` | Step 6 |
   | `"none"` | N/A | NO marker written. Hard-floor verdicts with `"none"`: STEP 4 DENY-THE-WRITE fires (ADV-F2-P7-001) — denied before reaching this row. Non-hard-floor `"none"`: autonomy_enabled=false → STEP 5 kill switch (allow, no marker); autonomy_enabled=true → explicit `none` branch after STEP 5 (allow, no marker). | N/A | STEP 4 deny (hard-floor) / STEP 5 kill switch (non-hard-floor, autonomy_enabled=false) / post-STEP-5 none-branch (non-hard-floor, autonomy_enabled=true) |
   | `"create-review"` | `null` | `^jr (--output json )?issue create --project <jira_project_key> --label (REVIEW-REQUIRED\|BLIND-SPOT)( \|$)` (**ADV-F2-P6-001**: `--label (REVIEW-REQUIRED\|BLIND-SPOT)` in FIXED second position after `--project <key>`; structurally distinct from `["create"]` pattern; consumer STEP 6a enforces anti-fungibility in both directions; D-DEC-012 restricted marker; REQUIRES `hard_floor_applies()`=true — STEP 3 O3 gate (P5-002); over-labeled non-hard-floor verdict → emit allow without marker; exempt from kill switch; if `jira_project_key` null/absent → **HARD-FLOOR-UNBINDABLE deny (P8-001/D-DEC-012 clause 2: explicit error + deny; NEVER silent allow-without-marker)**) | `["create-review"]` | Step 3 |
   | `"comment-review"` | from verdict (non-null) | `^jr (--output json )?issue comment <ticket_id> ` (D-DEC-012: restricted human-surfacing marker; REQUIRES `hard_floor_applies()`=true — STEP 3 O3 gate (P5-002); over-labeled non-hard-floor verdict → emit allow without marker; exempt from kill switch; if `ticket_id` null → **HARD-FLOOR-UNBINDABLE deny (P8-001/D-DEC-012 clause 2: if jira_project_key present, fallback hint suggests create-review; NEVER silent allow-without-marker)**) | `["comment-review"]` | Step 3 |

   > **Previous (v1.10) create pattern:** `^jr (--output json )?issue create .*--project <jira_project_key>` (unbounded `.*` before `--project` allowed injection; no trailing boundary). **Previous (v1.10) table:** No `create-review` or `comment-review` rows; `"none"` had no semantic qualification.

   Trailing space after ticket_id in comment/assign/comment-review patterns is intentional: prevents `SEC-1234` matching a pattern anchored to `SEC-123 `.

   **P12-001/O7 charset-validation at all interpolation sites:** Before any `ticket_id` or `jira_project_key` value is interpolated into a `command_pattern`, it is validated against a fixed charset (`ticket_id` → `^[A-Z][A-Z0-9]+-[0-9]+$`; `jira_project_key` → `^[A-Z][A-Z0-9]+$`) with hard deny on mismatch (TICKET-ID-CHARSET-DENY / PROJECT-KEY-CHARSET-DENY). `regex_escape()` applied as defense-in-depth after the charset check. This applies to all 5 rows that construct a `command_pattern` (comment, comment-review, assign, create, create-review) — see STEP 3 and STEP 6 pseudocode above.

   **Hard-floor check (D-DEC-008 — Step 4 [reordered BEFORE kill switch per ADV-F2-P6-002; DENY-THE-WRITE redesigned per ADV-F2-P7-001] — for REGULAR markers only; review path exempt):** The following conditions unconditionally trigger the FAIL-LOUD deny-the-Write path. When ANY hard-floor applies and the verdict is under-labeled (non-review `ticket_action_type`), STEP 4 DENIES the verdict Write and writes an `UNDER-LABEL-DENIED` audit entry. `autonomy_enabled` is irrelevant — deny fires regardless. D-DEC-012: correctly-labeled create-review and comment-review markers bypass this function entirely (see Step 3). **P10-001/P11-002: `hard_floor_applies()` keys the HIGH/CRIT severity floor on `verdict.scored_priority` (field 18 — Stage-5 assess-priority output), NOT on `recomputed_severity`; `recomputed_severity` (STEP 1a consistency check result) is still computed and compared but no longer drives the severity floor:**
   - `disposition` is `Indeterminate` (hard floor — never auto-close)
   - `verdict.scored_priority` is `HIGH` or `CRIT` (P11-002; Stage-5 assess-priority output, enum CRIT|HIGH|MED|LOW; formerly keyed on `recomputed_severity` at P10-001; captures KEV/exposure/critical-asset escalations not reflected in detector-native severity; **ADV-F2-001 CRITICAL fix: keyed on scored assessment, NOT confidence — orthogonal axes; Paired mutant SM-46 (high-severity-floor-rekeyed-to-recomputed-severity): re-keys HIGH/CRIT floor back to recomputed_severity instead of scored_priority — a LOW-detector/CRIT-scored verdict silently loses the hard floor; kill vector: VP-HOOK-026 LOW-detector/CRIT-scored escalation vector [ID-sync per FV]**)
   - `verdict.asset_type` is in `CRITICAL_ASSET_TYPES` (field 14; domain controllers, OT safety systems, privileged accounts; **ASM-008-DEFERRED: asset_type cross-validation deferred — sensor-specific asset taxonomy not yet empirically validated**)
   - `verdict.asset_type == "unknown"` (field 14; **separate explicit check — NOT folded into CRITICAL_ASSET_TYPES set**; per ADV-F2-P3-001)
   - Any MITRE technique in `attack_techniques` is T1003, T1068, T1021, or T1041
   - `sensor_health_status` is `degraded` or `silent`

   > **Previous (v1.8/v1.9) hard-floor list also included:** "Cross-tenant scope indicators present in `evidence_artifacts`." Removed in v1.10 (ADV-F2-P3-011): per D-DEC-005, plugin obligation is org_slug scoping only.

   > **Previous (v1.7):** Hard-floor check used "`confidence` maps to HIGH or CRIT severity threshold" as the severity-proxy condition. (ADV-F2-001 CRITICAL fix.)

   When any hard-floor condition is met: **correctly-labeled AND bindable verdicts** (`ticket_action_type` = `"create-review"` or `"comment-review"`, with binding field present: `jira_project_key` for create-review, `ticket_id` for comment-review) are handled at STEP 3 — a review-surfacing marker IS written (exempt from kill switch per D-DEC-012 Option A confirmed 2026-07-21) and the finding reaches human review. **Correctly-labeled but UNBINDABLE verdicts** (`create-review` with null `jira_project_key`; `comment-review` with null `ticket_id`) trigger the **HARD-FLOOR-UNBINDABLE deny path** at STEP 3 (P8-001/D-DEC-012 clause 2): explicit HARD-FLOOR-UNBINDABLE audit entry + structured deny; NO marker issued; NO silent allow; bounded fail-closed (one audit entry + one deny per re-doc attempt; no Jira write). **Under-labeled verdicts** (non-review `ticket_action_type`, incl. `"create"`, `"comment"`, `"assign"`, or `"none"`) fall through STEP 3; at STEP 4 (ADV-F2-P6-002 reorder — formerly STEP 5; ADV-F2-P7-001 DENY-THE-WRITE redesign), the hook checks `hard_floor_applies()` and **DENIES the verdict Write** with a structured corrective reason (`HARD-FLOOR-UNDER-LABEL`; `required_token` = `comment-review` if `ticket_id` present, else `create-review`). An `UNDER-LABEL-DENIED` audit entry is written. No marker is issued on this path. The loop MUST re-issue the verdict Write with `ticket_action_type` set to the corrective review token; STEP 3 then issues the review marker on the corrected Write. `autonomy_enabled` is irrelevant — deny fires regardless. Only non-hard-floor verdicts reach STEP 5 (kill switch). **SKILL.md Iron Law (ADV-F2-P7-003): set the correct review token in the first place.** STEP 4 is a deterministic safety net — not a delegation of labeling responsibility (EC-012; cases (c)/(d) collapsed to single DENY case).

   **Verification property (VP-HOOK-026 — FINALIZED, including unknown-asset leg v1.11):** VP-HOOK-026 explicitly tests all hard-floor legs of this emitter, including the separate `asset_type=unknown` conservative hard-floor (ADV-F2-P3-001 CRITICAL addition in v1.10 — NOT folded into CRITICAL_ASSET_TYPES): a LOW-severity + benign-technique + asset_type=unknown verdict NEVER receives a regular marker. Paired mutant SM-29 (unknown-asset-hard-floor-removed) is the kill target. FINALIZED per verification-delta.md v1.3 §7 Part D.

   **Marker directory initialization:** If `${CLAUDE_PLUGIN_DATA}/markers/` does not exist, the hook creates it with mode 0700 before writing. Failure to create → emit allow without marker (non-fatal; subsequent require-review will find no marker and deny).

   Confidence: D-DEC-001 binding decision (architecture-delta.md v1.2 §D-DEC-001); D-DEC-008 v1.6 hard-floor pseudocode + generation table (architecture-delta.md v1.6 §D-DEC-008); D-DEC-012 review-surfacing path; ADV-F2-001 (severity/confidence orthogonal axes); ADV-F2-P4-001 (JSON-first dispatch); ADV-F2-P4-002 (anchored create pattern); ADV-F2-P4-005 (autonomy_enabled kill switch); ADV-F2-P4-006 (enum-membership validation).

   **Separate Human-Comment Marker Path (P11-004 / redesigned P12-002):**

   This sub-path applies ONLY to `investigation-*.md` files dispatched via PC#2. It does NOT enter the verdict emitter above. `validate_enums()` and STEP 1a (NORMALIZE_SEVERITY / SEVERITY-MISMATCH) are NOT called on this path.

   ```
   # ── SEPARATE HUMAN-COMMENT MARKER PATH (P11-004 / redesigned P12-002 / P13-001) ────────────
   # Applies ONLY to investigation-*.md files (PC#2 dispatch).
   # This path does NOT enter the verdict emitter above.
   # Does NOT call validate_enums() or STEP 1a.
   #
   # ── GATE 1 (P12-002, fires FIRST): autonomy_enabled kill switch ────────────────────────────
   # Parse grammar (P13-003): parse_autonomy_enabled_from_markdown reads ONLY a dedicated
   # structured field (e.g., "Autonomy Enabled: true/false" heading or well-defined YAML
   # frontmatter field). Does NOT scan the full document for the token "autonomy_enabled: true".
   # Returns true ONLY when the dedicated field contains exactly "true" (explicit boolean-true).
   # Returns false for: absent field, "false" value, empty value, ambiguous value, or the
   # "autonomy_enabled: true" token appearing inside a code fence, evidence block, or quoted
   # log line. Safe direction: any non-explicit-true → false (GATE 1 stays closed).
   # Rationale: closes P12-002 autonomous-loop-masquerade bypass — the loop cannot obtain a live
   # marker via the markdown path while autonomy_enabled is absent/false. Human analyst saves
   # (which typically lack autonomy_enabled) → allow-without-marker → file saved, no Jira marker.
   autonomy_enabled_md = parse_autonomy_enabled_from_markdown(content)  # absent/non-bool-true = false
   IF autonomy_enabled_md IS NOT exactly true:
     emit allow without marker   # kill-switch parity: investigation file saved; no Jira marker
     RETURN
   #
   # ── GATES 2/3: markdown-evaluable hard floors (unchanged from P11-004) ──────────────────────
   IF disposition_section_contains("Indeterminate") OR
      attack_techniques_contains_forbidden(["T1003","T1068","T1021","T1041"]) OR
      sensor_health_status_is("degraded") OR sensor_health_status_is("silent"):
     WRITE audit entry: "MARKDOWN-HARD-FLOOR: [specific condition] in investigation markdown..."
     emit deny("MARKDOWN-HARD-FLOOR: ...")
     RETURN
   #
   # ── PARSE DISPOSITION: route FP to allow-without-marker; non-FP/PARSE_FAIL to review ───────
   # Parse grammar (P13-003): parse_disposition_from_markdown reads ONLY the canonical
   # "Disposition" heading value. Maps via exact allowlist:
   #   {TP, FP, BTP, Indeterminate} + canonical long forms:
   #   "True Positive" → TP, "False Positive" → FP, "Benign True Positive" → BTP
   # Matching is case-insensitive on canonical tokens only.
   # PARSE_FAIL on: ambiguous value (e.g., "probably FP", "not a false positive"),
   #   multi-valued (e.g., "FP or BTP"), unrecognized token, missing heading, empty value.
   # A "Disposition: FP" sentence inside an evidence block, code fence, or commentary
   # MUST NOT match — heading-anchored parse only.
   # Safe direction: PARSE_FAIL → non-FP routing (MARKDOWN_REVIEW_PATH, not allow-without-marker).
   # An adversarial markdown embedding a fake FP label in free text cannot obtain allow-without-marker.
   parsed_disposition = parse_disposition_from_markdown(content)
   # Returns one of: "TP" | "FP" | "BTP" | "Indeterminate" | PARSE_FAIL
   #
   # ── P13-001 (CRITICAL): MARKDOWN_COMMENT_PATH ELIMINATED ────────────────────────────────────
   # The hook cannot evaluate scored_priority (field 18) or asset_type (field 14) from a
   # 12-field markdown; no known-FP store cross-check on this path.
   # Per P13-001: no disposition may yield an autonomous comment marker from this path.
   IF parsed_disposition == "FP":
     # FP: allow-without-marker. Write succeeds; no Jira action authorized.
     # P11-004 intent preserved: the analyst's Write is NOT denied.
     # To surface an FP comment via Jira, the analyst must use the review path or
     # the normal 18-field verdict flow.
     emit allow without marker
     RETURN
   #
   # ── MARKDOWN_REVIEW_PATH: non-FP disposition (or PARSE_FAIL) → route to review ─────────────
   # Because this hook cannot evaluate scored_priority/asset_type from a 12-field markdown,
   # any non-FP disposition (including PARSE_FAIL safe direction) is conservatively routed
   # to human review. This path is EXEMPT from the autonomy_enabled kill switch (same as
   # regular STEP 3 path). TP/BTP/unclear/PARSE_FAIL → create-review or comment-review.
   ticket_id = parse_ticket_id_from_markdown(content)
   #
   # P12-001/O7: charset-validation before interpolating ticket_id into command_pattern
   # ticket_id comes from free-text markdown content — attacker-influenceable; must validate
   IF ticket_id is NOT null:
     IF NOT regex_match("^[A-Z][A-Z0-9]+-[0-9]+$", ticket_id):
       WRITE audit entry:
         now_iso8601() + " TICKET-ID-CHARSET-DENY: markdown path ticket_id='" + ticket_id +
         "' failed charset validation (P12-001/O7)"
       emit deny(
         "TICKET-ID-CHARSET-DENY: ticket_id from investigation markdown contains " +
         "invalid characters. Required: ^[A-Z][A-Z0-9]+-[0-9]+$ (P12-001/O7)."
       )
       RETURN
     ticket_id = regex_escape(ticket_id)   # defense-in-depth after charset check
   IF ticket_id is NOT null:
     ops = ["comment-review"]
     pattern = "^jr (--output json )?issue comment " + ticket_id + " "
     GOTO WRITE_MARKER
   ELSE:
     project_key = get_jira_project_key_from_config()
     IF project_key is NOT null:
       IF NOT regex_match("^[A-Z][A-Z0-9]+$", project_key):
         WRITE audit entry:
           now_iso8601() + " PROJECT-KEY-CHARSET-DENY: markdown review path (P12-001/O7)"
         emit deny("PROJECT-KEY-CHARSET-DENY: jira_project_key from config (P12-001/O7).")
         RETURN
       project_key = regex_escape(project_key)
       ops = ["create-review"]
       pattern = "^jr (--output json )?issue create --project " + project_key + " --label (REVIEW-REQUIRED|BLIND-SPOT)( |$)"
       GOTO WRITE_MARKER
     ELSE:
       # Same HARD-FLOOR-UNBINDABLE deny as STEP 3 (D-DEC-012 clause 2)
       WRITE audit entry: "MARKDOWN-HARD-FLOOR-UNBINDABLE: non-FP disposition with no ticket_id and no jira_project_key"
       emit deny("MARKDOWN-HARD-FLOOR-UNBINDABLE: cannot surface non-FP markdown finding without ticket_id or jira_project_key.")
       RETURN
   ```

   **Jira project key constraint note (P13-002):** Jira project keys MUST be hyphen-free and match `^[A-Z][A-Z0-9]+$`. A key such as `PRISM-DEMO` with a hyphen will be rejected by PROJECT-KEY-CHARSET-DENY at every marker issuance. Validate at setup time via BC-6.01.001 (activate) and BC-6.01.003 (onboard-customer) to prevent this. Cross-reference: D-DEC-008 architectural constraint (architecture-delta.md v1.16).

   **Trust basis (P11-004 / P12-002 / P13-001):** Gate 1 (P12-002): `autonomy_enabled` is read from a dedicated structured field in the markdown content — absent, not explicitly true, or embedded inside a code fence/evidence block → emit allow-without-marker (closes the autonomous-loop-masquerade bypass; P13-003 parse grammar ensures no accidental gate-open from embedded tokens). Gates 2/3 (P11-004, unchanged): markdown-evaluable floors (Indeterminate disposition, forbidden techniques T1003/T1068/T1021/T1041, degraded/silent sensor). Post-P13-001 route rule: **no disposition yields an autonomous comment marker** — `parsed_disposition == "FP"` → allow-without-marker (MARKDOWN_COMMENT_PATH ELIMINATED; hook cannot evaluate scored_priority/asset_type from 12-field markdown; no known-FP store cross-check); `parsed_disposition != "FP"` or PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review; EXEMPT from kill switch). Verdict-only fields (`scored_priority`, `asset_type`, `verdict.severity`) are NOT present in a standard ICD-203 investigation markdown and are NOT checked on this path. `ticket_id` parsed from free-text markdown is charset-validated (P12-001/O7) before interpolation.

   > **Previous (v1.20) route rule:** "P12-002 route rule: `parsed_disposition != "FP"` → MARKDOWN_REVIEW_PATH; FP + `autonomy_enabled=true` → MARKDOWN_COMMENT_PATH (comment marker)." The v1.21 change per P13-001: MARKDOWN_COMMENT_PATH eliminated; FP now → allow-without-marker.

   **Verification property (VP-HOOK-031 — FINALIZED P0, per verification-delta.md v1.14; UPDATED v1.15 P12-002 SM-50/SM-51; SCOPE UPDATE COMPLETE v1.21 P13-001 — SM-51 (route-to-review, reconciled) / SM-52 (FP-comment-marker revert) [ID-sync per FV]):** Separate human-comment marker path correctness (P11-004 / P12-002 / P13-001): the 12-field ICD-203 investigation-markdown path (PC#2 dispatch) does NOT enter the verdict emitter; `validate_enums()` and STEP 1a are NOT called on this path. Gate 1 (P12-002 / P13-003): `autonomy_enabled` absent/non-bool-true/embedded-in-code-fence → allow-without-marker (P13-003 parse grammar enforced). Gates 2/3: markdown-evaluable floors → MARKDOWN-HARD-FLOOR deny. **Post-P13-001 route rule (no autonomous comment marker for any disposition):** FP → allow-without-marker (P13-001 MARKDOWN_COMMENT_PATH ELIMINATED; SM-52 kill target: restoring MARKDOWN_COMMENT_PATH causes FP+autonomy_enabled=true to emit ["comment"] marker — incorrect); non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review). Adversarial parse vectors (P13-003): "Disposition: not a false positive" → PARSE_FAIL → review (NOT allow-without-marker); `autonomy_enabled: true` embedded in code fence → GATE 1 remains closed. Consumed by BC-5.01.001 (investigate-event Invariant #7) and BC-4.02.001 (update-jira PC#4). Paired mutant SM-47 (markdown-routed-into-verdict-emitter): routes investigation-markdown into verdict emitter — kills compliant-save-allowed and no-validate_enums vectors. **NOTE (P13-001): SM-P12-D ("revert P12-002 — remove disposition routing rule; issue comment marker for all dispositions") is SUPERSEDED by SM-51 (route-to-review, reconciled) — the correct behavior for TP/BTP/PARSE_FAIL routes to review. SM-52 (FP-comment-marker revert, P13-001) covers the FP path: "revert P13-001 — restore MARKDOWN_COMMENT_PATH: FP+autonomy_enabled=true issues autonomous comment marker" → kill target.** [ID-sync per FV]

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr error, no JSON output |
| EC-002 | File path `/tmp/readme.md` | Allow — not an investigation or verdict file |
| EC-003 | Investigation file with no Disposition section | Allow — in-progress; gate only fires once Disposition is declared. **HOOK-ISOLATED**: in aggregate, enrichment-completeness BC-3.02.001 co-fires and denies investigation files missing any of the four required sections. |
| EC-004 | Investigation file with "Disposition: True Positive" but no Alternatives Considered | Deny with reason mentioning "Alternatives Considered" |
| EC-005 | Investigation file with both "Disposition" and "Alternatives Considered" sections and all 12 mandatory headings (investigation-markdown path), non-hard-floor disposition — GATE 1 check | **Post-P13-001 routing (P17-003):** GATE 1 (`autonomy_enabled` absent or ≠ true — the common human-save case) → `permissionDecision: allow`; **NO marker written** (allow-without-marker for ALL dispositions; no Jira action authorized; Write succeeds). `autonomy_enabled=true` masquerade case: FP → allow-without-marker (MARKDOWN_COMMENT_PATH ELIMINATED, P13-001); non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review review marker, EXEMPT from kill switch). **NO autonomous `["comment"]` marker is ever issued from the markdown path (P13-001).** Note: `ticket_action_type` does NOT exist on the 12-field markdown path (verdict-only field, PC#1 path) — the prior reference to "scope determined by ticket_action_type content" was incorrect. |
| EC-006 | Investigation file with "disposition" (lowercase) section | Deny if Alternatives absent — `grep -qiF` matches case-insensitively |
| EC-007 | Content containing "Disposition" in body text (not a section header) | Allow if "Alternatives Considered" also present anywhere; Deny if absent. The check is on substring presence in the full content. |
| EC-008 | Malformed JSON stdin | `jq` returns empty string for file_path; path doesn't match `investigation` or `verdict`; emit allow |
| EC-009 | Investigation file with "Disposition" section present AND "Alternatives Considered" appearing as negating body text only (e.g., "No Alternatives Considered were required.") | **RESOLVED (DI-004/SM-1, PR #17):** `permissionDecision: deny`. Heading-anchored check requires an actual markdown heading. BATS: `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323). |
| EC-010 | Investigation or verdict file with Alternatives Considered present (or all other JSON keys present) but missing one of the 18 mandatory fields (P10-001/P11-002) — e.g., `timeline_events` heading absent from markdown, `tuning_signal` key entirely absent from JSON verdict, or fields `severity`/`asset_type`/`ticket_action_type`/`native_severity`/`sensor_family`/`scored_priority` absent from JSON verdict | Deny with reason identifying the specific missing field (e.g., "ICD-203 required field missing: scored_priority"). No marker written. |
| EC-011 | Verdict file with `disposition: "FP"` AND `tuning_signal: null` (null present but wrong semantics for FP) | Deny: tuning_signal must be a non-null object for FP/BTP dispositions. No marker written. |
| EC-012 | Investigation or verdict file passes all 18 mandatory field checks (P10-001/P11-002) but `disposition: "Indeterminate"` (hard floor) | Allow (the write IS permitted — the document is valid). Marker issuance depends on `ticket_action_type` (and `autonomy_enabled` for non-hard-floor verdicts — but hard-floor verdicts bypass the kill switch): **(a)** `ticket_action_type=create-review` + `hard_floor_applies()`=true → STEP 3 emits create-review marker (pattern: `^jr ... create --project <key> --label (REVIEW-REQUIRED\|BLIND-SPOT)( \|$)` per ADV-F2-P6-001); finding routed to human review queue. **(b)** `ticket_action_type=comment-review` + `ticket_id` present + `hard_floor_applies()`=true → STEP 3 emits comment-review marker. **(c)** under-labeled (any non-review token, incl. `"create"`, `"comment"`, `"assign"`, `"none"`) → **STEP 4 DENY-THE-WRITE (ADV-F2-P7-001)**: `permissionDecision: deny` with `HARD-FLOOR-UNDER-LABEL` corrective reason; `UNDER-LABEL-DENIED` audit entry written; no marker issued; `autonomy_enabled` is irrelevant — deny fires regardless of its value. The loop MUST re-issue the verdict Write with `ticket_action_type` set to the corrective review token from the deny reason (`required_token` = `comment-review` if `ticket_id` present, else `create-review`); STEP 3 then issues the review marker on the corrected Write. **Note:** cases (c) and (d) from v1.15 (autonomy_enabled=true vs autonomy_enabled=false with upgrade semantics) are **COLLAPSED** — both now produce the same DENY outcome. `autonomy_enabled` no longer differentiates outcomes at this step. |

## Canonical Test Vectors

| Input (file_path → content) | Expected Output | Category |
|-----------------------------|----------------|----------|
| `/tmp/readme.md` → any | `permissionDecision: allow` | happy-path |
| `investigation-ALERT-001.md` → "# Alert Details\nEvidence..." (no Disposition) | `permissionDecision: allow` **(HOOK-ISOLATED: in aggregate, enrichment-completeness BC-3.02.001 would deny this file — missing 3 of 4 required sections)** | hook-isolated-allow |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\n# Evidence\n..." (no Alternatives) | `permissionDecision: deny`, reason contains "Alternatives Considered" | error |
| `investigation-ALERT-001.md` → all 12 mandatory headings present (investigation-markdown path), disposition=TP, tuning_signal=null, non-hard-floor, **autonomy_enabled absent** (common human-save case) | `permissionDecision: allow`; **NO marker written** (allow-without-marker: GATE 1 fires — `autonomy_enabled` absent → allow-without-marker for ALL dispositions; no Jira action authorized; Write succeeds; P13-001/P12-002). Verdict emitter NOT entered; `validate_enums` NOT called; STEP 1a NOT called. **Previous (v1.10/v1.20):** "marker file written (comment-scoped, ticket-bound pattern)" — retired MARKDOWN_COMMENT_PATH behavior; eliminated at P13-001. (P17-003) | happy-path (post-P13-001 human save — autonomy absent → allow-without-marker; MARKDOWN_COMMENT_PATH eliminated) |
| `investigation-ALERT-001.md` → "# disposition\nFalse Positive" (lowercase) | `permissionDecision: deny` | edge-case |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\nNo Alternatives Considered were required." | `permissionDecision: deny` (RESOLVED — PR #17 heading-anchored check; body-text negation no longer passes) | edge-case |
| `verdict-ALERT-001.json` → JSON with all 18 keys present, disposition=FP, tuning_signal={"rule_id":"R-001","asset":"host-42","reason":"benign scanner"}, severity=LOW, scored_priority=LOW, asset_type=standard, ticket_action_type=comment, non-hard-floor | `permissionDecision: allow`; comment-scoped marker file written with ticket-bound command_pattern | happy-path (v1.8 JSON path) |
| `verdict-ALERT-001.json` → JSON with all 18 keys present, disposition=FP, ticket_action_type=create, severity=LOW, scored_priority=LOW, asset_type=standard, jira_project_key=SEC, autonomy_enabled=true, non-hard-floor | `permissionDecision: allow`; create-scoped marker written (ticket_id=null, command_pattern `^jr (--output json )?issue create --project SEC( \|$)`) | happy-path (v1.12 create-scoped anchored pattern) |
| `artifacts/investigations/verdict-ALERT-001.json` → JSON with all 18 keys present (path contains BOTH `investigations` and ends `.json`) | JSON-first dispatch (Check 1) fires — routes to verdict-class 18-field path; NOT to investigation-markdown branch (ADV-F2-P4-001 regression test) | happy-path (v1.12 JSON-first dispatch) |
| `verdict-ALERT-001.json` → JSON with `severity: "High"` (wrong case — not in SEVERITY_ENUM) | `permissionDecision: deny`; reason "ICD-203 enum-membership validation failed: severity 'High' not in allowed set" (ADV-F2-P4-006 enum validation) | error (v1.12 enum-validation) |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=Indeterminate, scored_priority=MED, ticket_action_type=create-review, jira_project_key=SEC, autonomy_enabled=false | `permissionDecision: allow`; create-review marker written (STEP 3: hard_floor_applies()=true gate satisfied — Indeterminate disposition; exempt from kill switch); authorized_operations=["create-review"]; command_pattern includes `--label (REVIEW-REQUIRED\|BLIND-SPOT)` in fixed second position per ADV-F2-P6-001 | happy-path (D-DEC-012 review-surfacing) |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=TP, ticket_action_type=create, severity=LOW, scored_priority=LOW, autonomy_enabled=false | `permissionDecision: allow`; NO marker written (STEP 3 exits with allow-without-marker — create is not a review token; STEP 4 hard_floor_applies()=false for LOW scored_priority TP — deny-the-Write does NOT fire; kill switch STEP 5 fires — autonomy_enabled=false) | edge-case (ADV-F2-P4-005 kill switch) |
| `verdict-ALERT-001.json` → JSON missing `timeline_events` key | `permissionDecision: deny`, reason "ICD-203 required field missing: timeline_events" | error (EC-010) |
| `verdict-ALERT-001.json` → JSON missing `severity` key | `permissionDecision: deny`, reason "ICD-203 required field missing: severity" | error (EC-010) |
| `verdict-ALERT-001.json` → disposition=FP, tuning_signal=null | `permissionDecision: deny`, reason "tuning_signal must be non-null object for FP/BTP" | error (EC-011) |
| `verdict-ALERT-001.json` → all 18 keys, disposition=Indeterminate, severity=LOW, scored_priority=MED, ticket_action_type=create (under-labeled), jira_project_key=SEC, ticket_id=null (autonomy_enabled irrelevant — tested both true and false) | `permissionDecision: deny`; `HARD-FLOOR-UNDER-LABEL` error JSON returned with `required_token="create-review"`, `hard_floor_trigger="Indeterminate/..."`, `label_instruction`; `UNDER-LABEL-DENIED` audit entry written to audit.log; NO marker issued; loop MUST re-issue verdict Write with ticket_action_type="create-review"; BATS: `@test "disposition-guard verdict Write DENIED UNDER-LABEL-DENIED corrective reason under-labeled hard-floor"` | edge-case (EC-012 case c — **ADV-F2-P7-001 DENY-THE-WRITE**) |
| `verdict-ALERT-001.json` → all 18 keys, disposition=Indeterminate, severity=LOW, scored_priority=HIGH, ticket_action_type=`"create-review"`, **jira_project_key=null** (correctly-labeled but unbindable), autonomy_enabled=false | `permissionDecision: deny`; audit.log entry: `HARD-FLOOR-UNBINDABLE: hard-floor create-review verdict with missing jira_project_key; missing_field=jira_project_key; verdict Write denied by disposition-guard (P8-001/D-DEC-012 clause 2)`; deny reason includes `hard_floor_trigger`, `missing_field=jira_project_key`, corrective instruction to re-issue with jira_project_key populated; **NO marker issued; NO silent allow-without-marker; bounded fail-closed** (re-doc with jira_project_key still null fires again — exactly one HARD-FLOOR-UNBINDABLE audit entry + one deny per attempt); BATS: `@test "disposition-guard HARD-FLOOR-UNBINDABLE deny create-review null jira_project_key"` | **edge-case (P8-001 CRITICAL — ADV-F2-P8-001/D-DEC-012 clause 2)** |
| `verdict-ALERT-001.json` → all 18 keys, disposition=TP, severity=LOW, scored_priority=CRIT, ticket_action_type=`"comment-review"`, **ticket_id=null**, jira_project_key=`"PRISMDEMO"` (correctly-labeled but unbindable; project_key present → fallback hint) | `permissionDecision: deny`; audit.log entry: `HARD-FLOOR-UNBINDABLE: hard-floor comment-review verdict with null ticket_id; missing_field=ticket_id; verdict Write denied by disposition-guard (P8-001/D-DEC-012 clause 2)`; deny reason includes `hard_floor_trigger`, `missing_field=ticket_id`, fallback hint: `"jira_project_key=PRISMDEMO is present — if no review ticket exists yet, re-issue with ticket_action_type=create-review instead."`; **NO marker issued; NO silent allow-without-marker; bounded fail-closed**; BATS: `@test "disposition-guard HARD-FLOOR-UNBINDABLE deny comment-review null ticket_id with project_key fallback hint"` | **edge-case (P8-001 CRITICAL — ADV-F2-P8-001/D-DEC-012 clause 2)** |
| `verdict-ALERT-001.json` → JSON missing `native_severity` key (field 16 of the 18-field verdict schema) | `permissionDecision: deny`; reason "ICD-203 required field missing: native_severity"; no marker written; same deny path as EC-010 for fields 1-18 (P10-001/P11-002 18-field validation) | **error (P10-001/P11-002 — 18-field STEP 0 validation)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=TP, severity=LOW, **native_severity=100** (CrowdStrike 1-100 numeric), **sensor_family=crowdstrike** (D-DEC-013 table: CrowdStrike 100 → CRITICAL); scored_priority=LOW; ticket_action_type=comment, autonomy_enabled=true | `permissionDecision: deny`; audit.log entry: `SEVERITY-MISMATCH: verdict.severity='LOW' does not match hook-recomputed severity='CRITICAL' via NORMALIZE_SEVERITY(native_severity='100', sensor_family='crowdstrike') (P10-001/D-DEC-013)`; deny reason: "SEVERITY-MISMATCH: disposition-guard recomputed severity='CRITICAL' from (native_severity='100', sensor_family='crowdstrike') does not match verdict.severity='LOW'. Verdict Write denied. Correct verdict.severity to match NORMALIZE_SEVERITY output (P10-001)." No marker written; loop MUST correct verdict.severity to 'CRITICAL' and re-issue. | **error (P10-001 CRITICAL — STEP 1a SEVERITY-MISMATCH)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=TP, severity=CRITICAL, **native_severity=95** (CrowdStrike 1-100 numeric, ≥80 → CRITICAL), **sensor_family=crowdstrike**; scored_priority=CRIT; NORMALIZE_SEVERITY(95, crowdstrike) = CRITICAL = verdict.severity (match); ticket_action_type=comment, ticket_id=SEC-999, autonomy_enabled=true, non-hard-floor-eligible | STEP 1a passes (recomputed_severity='CRITICAL' == verdict.severity='CRITICAL'); proceeds to STEP 2; but scored_priority=CRIT → hard_floor_applies()=true → STEP 4 DENY-THE-WRITE fires (under-labeled; `comment` is not a review token); `UNDER-LABEL-DENIED` audit entry; deny with required_token="comment-review" | **edge-case (P11-002 — scored_priority=CRIT triggers hard floor even when STEP 1a passes)** |
| `verdict-ALERT-001.json` → JSON with 17 keys, **`scored_priority` key absent** (field 18 missing) | `permissionDecision: deny`; reason "ICD-203 required field missing: scored_priority"; no marker written | **error (P11-002 — 18-field STEP 0 validation, field 18 absent)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=TP, severity=LOW, **scored_priority=HIGH**, asset_type=standard, ticket_action_type=create (under-labeled), autonomy_enabled=true | `permissionDecision: deny`; STEP 1a passes (severity consistent with native_severity); STEP 4 fires: scored_priority=HIGH → hard_floor_applies()=true → HARD-FLOOR-UNDER-LABEL deny; `UNDER-LABEL-DENIED` audit entry; required_token="create-review". NOTE: verdict.severity=LOW does NOT suppress the floor — scored_priority (Stage-5 recalibrated) is the floor driver (P11-002). | **edge-case (P11-002 — scored_priority=HIGH hard floor, detector severity LOW)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, **autonomy_enabled: true** in content, Disposition=FP, Sensor Health Status=healthy, no forbidden techniques, ticket_id=SEC-123 | Separate Human-Comment Marker Path (P13-001 / MARKDOWN_COMMENT_PATH ELIMINATED): Gate 1 passes (autonomy_enabled=true); Gates 2/3 floors pass; parsed_disposition=FP → **allow-without-marker** (P13-001: hook cannot evaluate scored_priority/asset_type from 12-field markdown; no Jira action authorized; Write succeeds); NO comment marker issued; verdict emitter NOT entered; validate_enums NOT called; STEP 1a NOT called. **Previous (v1.20):** "parsed_disposition=FP → MARKDOWN_COMMENT_PATH; comment-scoped marker written." | **happy-path (P13-001 — FP → allow-without-marker; MARKDOWN_COMMENT_PATH eliminated)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, **autonomy_enabled: true** in content, Disposition=TP, Sensor Health Status=healthy, no forbidden techniques, ticket_id=SEC-123 | Separate Human-Comment Marker Path (P12-002): Gate 1 passes (autonomy_enabled=true); Gates 2/3 floors pass; parsed_disposition=TP != "FP" → MARKDOWN_REVIEW_PATH; ticket_id charset-validated; comment-review marker written (NOT plain comment); `permissionDecision: allow`; verdict emitter NOT entered | **happy-path (P12-002 MARKDOWN_REVIEW_PATH — non-FP routes to review)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, Disposition=Indeterminate (autonomy_enabled absent) | Separate Human-Comment Marker Path (P12-002): Gate 1 fires — autonomy_enabled absent → allow-without-marker (kill-switch parity); investigation file IS saved; NO Jira marker issued | **edge-case (P12-002 Gate 1 — autonomy_enabled absent → allow-without-marker)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, **autonomy_enabled: true**, Disposition=Indeterminate, Sensor Health Status=healthy | Separate Human-Comment Marker Path (P12-002): Gate 1 passes (autonomy_enabled=true); Gate 2 fires (Indeterminate → MARKDOWN-HARD-FLOOR); `permissionDecision: deny`; deny reason "MARKDOWN-HARD-FLOOR: Indeterminate disposition"; audit entry written; verdict emitter NOT entered | **edge-case (P12-002 Gate 2 — MARKDOWN-HARD-FLOOR, Indeterminate)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, **autonomy_enabled: true**, Disposition="not a false positive" (non-allowlist text in Disposition heading), Sensor Health Status=healthy | Separate Human-Comment Marker Path (P13-003): Gate 1 passes (autonomy_enabled=true); Gates 2/3 floors pass; `parse_disposition_from_markdown` returns PARSE_FAIL (ambiguous value — not in allowlist {TP,FP,BTP,Indeterminate} + canonical long forms); PARSE_FAIL safe direction → MARKDOWN_REVIEW_PATH (NOT allow-without-marker); ticket_id absent → project_key lookup → create-review marker if project_key present, HARD-FLOOR-UNBINDABLE deny if absent; verdict emitter NOT entered | **edge-case (P13-003 — PARSE_FAIL → review, not allow-without-marker; adversarial FP label cannot obtain allow-without-marker)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, Disposition=FP, Sensor Health Status=healthy, `autonomy_enabled: true` token appearing **inside a code fence or evidence block** (not in dedicated structured field), no dedicated Autonomy Enabled structured field | Separate Human-Comment Marker Path (P13-003): `parse_autonomy_enabled_from_markdown` reads ONLY dedicated structured field — embedded token in code fence/evidence block does NOT match; returns false; Gate 1 fires → **allow-without-marker** (kill-switch parity; embedded token cannot open the gate); NO Jira action authorized; Write succeeds | **edge-case (P13-003 — autonomy_enabled token in code fence → Gate 1 stays closed; allow-without-marker)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=TP, **ticket_id=".*"** (metacharacter injection), ticket_action_type=comment, severity=LOW, scored_priority=LOW, non-hard-floor, autonomy_enabled=true | `permissionDecision: deny`; audit.log: `TICKET-ID-CHARSET-DENY: comment path ticket_id='.*' failed charset validation (P12-001/O7)`; deny reason: "TICKET-ID-CHARSET-DENY: ticket_id='.*' rejected before command_pattern interpolation (P12-001/O7)"; NO marker written | **error (P12-001 — TICKET-ID-CHARSET-DENY)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, **jira_project_key="SEC\|.*"** (metacharacter injection), ticket_action_type=create, severity=LOW, scored_priority=LOW, non-hard-floor, autonomy_enabled=true | `permissionDecision: deny`; audit.log: `PROJECT-KEY-CHARSET-DENY: create path jira_project_key='SEC\|.*' failed charset validation (P12-001/O7)`; deny reason: "PROJECT-KEY-CHARSET-DENY: jira_project_key='SEC\|.*' rejected before command_pattern interpolation (P12-001/O7)"; NO marker written | **error (P12-001 — PROJECT-KEY-CHARSET-DENY)** |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-007 | Investigation file with Disposition but no Alternatives always produces deny | integration / BATS |
| VP-HOOK-008 | Investigation file without Disposition always produces allow (in-progress gate) | integration / BATS |
| VP-HOOK-009 | Non-investigation, non-verdict files always produce allow | integration / BATS |
| VP-HOOK-026 | **[NEW v1.11; SM-46 extended v1.19 P11-002]** Hard-floor non-overridability (FINALIZED per verification-delta.md v1.3 §7 Part D): all hard-floor conditions unconditionally suppress marker issuance, including the separate `asset_type=unknown` leg (NOT a member of CRITICAL_ASSET_TYPES — explicit check). Tests: LOW-severity + benign-technique + asset_type=unknown verdict → zero markers written (SM-29 kill target); HIGH/CRIT `scored_priority` → zero markers (**SM-46 kill target**: high-severity-floor-rekeyed-to-recomputed-severity — re-keying floor to `recomputed_severity` silently loses the LOW-detector/CRIT-scored escalation path); Indeterminate disposition → zero markers; CRITICAL_ASSET_TYPES → zero markers; degraded/silent sensor health → zero markers. | integration / BATS (`@test "disposition-guard unknown-asset hard-floor: no marker emitted"`, `@test "disposition-guard critical-severity hard-floor: no marker emitted"`, `@test "disposition-guard indeterminate hard-floor: no marker emitted"`, `@test "disposition-guard scored_priority=CRIT severity=LOW: hard floor fires (SM-46 kill)"`) |
| VP-HOOK-025 | **[UPDATED v1.19 — P10-001/P11-002]** Artifact-class branching enforcement (architecture-delta v1.4 §D-DEC-008-C — ADV-F2-P3-003). **Investigation markdown path (12 ICD-203 fields):** heading-anchored `grep -qiE "^#{1,6}[[:space:]]+<field>"` for each of: (1) disposition, (2) confidence, (3) sensor_health_status, (4) evidence_artifacts, (5) timeline_events, (6) hypotheses_considered, (7) alternatives_rejected, (8) uncertainty_explicit, (9) attack_techniques, (10) agent_actions, (11) human_actions, (12) tuning_signal. Severity, asset_type, ticket_action_type are NOT required headings in the investigation-markdown path. **Verdict JSON path (18 fields — P10-001/P11-002):** `jq has()` key-presence check + per-field type assertions for all 18 fields (fields 1–12 above plus (13) severity, (14) asset_type, (15) ticket_action_type, (16) native_severity, (17) sensor_family, (18) scored_priority). Verdict JSON files missing any of the 18 keys receive deny. tuning_signal null-vs-absent semantics enforced (null valid for TP/Indeterminate; non-null object required for FP/BTP). scored_priority membership in {CRIT,HIGH,MED,LOW} enforced (fail-closed; P11-002). Hard-floor check re-keyed to `verdict.scored_priority` (field 18 — P11-002; Stage-5 assess-priority output) + verdict.asset_type (field 14) including separate `unknown` check (ADV-F2-P3-001). SM-44 (revert STEP 1a re-normalization — SEVERITY-MISMATCH context). Cross-ref: VP-HOOK-030 (STEP 1a SEVERITY-MISMATCH, FINALIZED P0 per verification-delta v1.13). [ID-sync per FV]. | integration / BATS (`@test "disposition-guard denies verdict missing timeline_events"`, `@test "disposition-guard denies verdict missing severity"`, `@test "disposition-guard denies verdict missing native_severity"`, `@test "disposition-guard denies verdict missing sensor_family"`, `@test "disposition-guard denies verdict missing scored_priority"`, `@test "disposition-guard denies verdict scored_priority not in enum"`, `@test "disposition-guard denies FP verdict with null tuning_signal"`, `@test "disposition-guard allows TP verdict with null tuning_signal and all 18 fields"`, `@test "disposition-guard allows investigation with 12 fields (severity/asset_type/ticket_action_type headings not required)"`) |
| VP-HOOK-031 | **[NEW v1.19 — P11-004; scope update v1.20 — P12-002 SM-50/SM-51; SCOPE UPDATE COMPLETE v1.21 — P13-001 MARKDOWN_COMMENT_PATH ELIMINATED / SM-52 (FP-comment-marker revert) [ID-sync per FV]]** Separate human-comment marker path correctness (P11-004 / P12-002 / P13-001): the 12-field ICD-203 investigation-markdown path (PC#2 dispatch) does NOT enter the verdict emitter; `validate_enums()` and STEP 1a are NOT called on this path. Gate 1 (P12-002 / P13-003): `autonomy_enabled` absent/non-bool-true/embedded-in-code-fence (P13-003 parse grammar enforced) → allow-without-marker. **Post-P13-001 route rule (no autonomous comment marker for any disposition):** (1) FP path (P13-001): 12-field investigation markdown, FP disposition, healthy sensor, no forbidden techniques, autonomy_enabled=true → **allow-without-marker** (MARKDOWN_COMMENT_PATH ELIMINATED; Write succeeds; NO Jira action authorized); (2) non-FP route-to-review path (P12-002): autonomy_enabled=true, TP/BTP/PARSE_FAIL disposition → comment-review or create-review marker (MARKDOWN_REVIEW_PATH); (3) kill-switch path (P12-002 / P13-003): autonomy_enabled absent/false/embedded-in-code-fence → allow-without-marker; (4) MARKDOWN-HARD-FLOOR path: Indeterminate disposition / T1003|T1068|T1021|T1041 technique / degraded|silent sensor → deny; (5) path isolation: 12-field markdown does NOT trigger validate_enums or STEP 1a; (6) ticket_id charset-validation (P12-001/O7): ticket_id=".*" → TICKET-ID-CHARSET-DENY; (7) adversarial parse vectors (P13-003): "Disposition: not a false positive" → PARSE_FAIL → MARKDOWN_REVIEW_PATH (NOT allow-without-marker); `autonomy_enabled: true` embedded in code fence → Gate 1 stays closed. SM-52 (FP-comment-marker revert, P13-001): "revert P13-001 — restore MARKDOWN_COMMENT_PATH: FP+autonomy_enabled=true issues autonomous comment marker" → kill target for vectors (1) and (7); SM-51 (route-to-review, reconciled). SM-50 kill target: remove Gate 1 kill-switch (vector 3). SM-51 kill target: route TP to comment-scoped marker (vector 2 routes to review). Consumed by BC-5.01.001 Invariant #7 (investigate-event Stage 7) and BC-4.02.001 PC#4 (update-jira Stage 7). Paired mutant SM-47 (markdown-routed-into-verdict-emitter): routes investigation-markdown into verdict emitter — kills compliant-save-allowed and no-validate_enums vectors. [ID-sync per FV] | integration / BATS (`@test "disposition-guard investigation markdown FP (autonomy_enabled=true): allow-without-marker (P13-001 MARKDOWN_COMMENT_PATH ELIMINATED)"`, `@test "disposition-guard investigation markdown TP (autonomy_enabled=true): routes to review (MARKDOWN_REVIEW_PATH)"`, `@test "disposition-guard investigation markdown autonomy_enabled absent: allow-without-marker"`, `@test "disposition-guard investigation markdown autonomy_enabled in code fence: Gate 1 stays closed (P13-003)"`, `@test "disposition-guard investigation markdown PARSE_FAIL disposition: MARKDOWN_REVIEW_PATH not allow-without-marker (P13-003)"`, `@test "disposition-guard investigation markdown MARKDOWN-HARD-FLOOR Indeterminate: deny"`, `@test "disposition-guard investigation markdown does not enter verdict emitter path (SM-47 kill)"`, `@test "disposition-guard investigation markdown ticket_id metachar: TICKET-ID-CHARSET-DENY"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-03 |
| L2 Domain Invariants | Anti-confirmation-bias invariant: NO INVESTIGATION DISPOSITION SAVED WITHOUT ALTERNATIVES CONSIDERED FIRST — enforces that analysts document alternative hypotheses before committing a TP/FP/BTP disposition (prevents anchoring on the first interpretation) |
| Architecture Module | C-14 (disposition-guard-hook), C-29 (marker-store emitter) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/disposition-guard.sh` (62 lines post-PR #17; extended in v1.6) + `.ps1` sibling |
| **Confidence** | high for existing behavior (v1.5 paths); D-DEC-001/D-DEC-008 binding decision for EMITTER role and ICD-203 enforcement (v1.6 additions — not yet in source code; architect approval required) |
| **Extraction Date** | 2026-07-20 |

#### Evidence Types Used

- **guard clause**: file path substring checks for `investigation` and `verdict` (path dispatch) [SUPERSEDED by P4-001/v1.12 — normative dispatch is now JSON-first per PC#1: .json extension OR jq empty succeeds → verdict-class; else investigation-markdown. This brownfield description reflects the original hook before JSON-first dispatch.]
- **guard clause**: case-insensitive content check for "Disposition" presence (lines 48-51)
- **guard clause**: heading-anchored case-insensitive content check for "Alternatives Considered" absence (`grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"`, line 57 — DI-004 RESOLVED, PR #17)
- **guard clause (v1.6/v1.10)**: 12-field ICD-203 heading-anchored check for investigation files (markdown path — 12 fields; v1.10 artifact-class branching)
- **guard clause (v1.6/v1.8/v1.18/v1.19)**: 18-key JSON key-presence validation for verdict files (JSON path — 15 fields at v1.8 after addition of severity/asset_type/ticket_action_type → 17 fields at v1.18/P10-001 after addition of native_severity/sensor_family → 18 fields at v1.19/P11-002 after addition of scored_priority)
- **guard clause (v1.6)**: tuning_signal null-vs-absent semantics based on disposition value
- **guard clause (v1.6)**: hard-floor check before marker issuance (D-DEC-008)
- **effectful (v1.6)**: marker file write to `${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json` (EMITTER role — only after all validation passes and no hard floor)
- **documentation**: deny reason text documents the intent (prevent confirmation bias via undocumented dispositions)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin once; writes stdout; **v1.6 addition:** writes `${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json` when ICD-203 validation passes and no hard floor |
| **Global state access** | **v1.6 addition:** marker-store directory `${CLAUDE_PLUGIN_DATA}/markers/` (write — EMITTER role) |
| **Deterministic** | yes for deny paths; for allow paths with EMITTER role: deterministic behavior, but marker UUID is unique per invocation |
| **Thread safety** | marker write is a new file (UUID filename) — no TOCTOU race; mkdir -p is idempotent |
| **Overall classification** | effectful shell (v1.6 — filesystem write for EMITTER role); pure core for deny paths |

#### Refactoring Notes

The three-state routing logic (non-investigation / in-progress / complete) is clearly separated and verifiable. The ICD-203 12-field check adds two new validation stages that can be extracted as pure functions (one for markdown heading presence, one for JSON key presence). The tuning_signal semantic check is also a pure function given (disposition, tuning_signal_value).

**Aggregate Gate Behavior (ADV-0-501):** Both `enrichment-completeness` (BC-3.02.001) and `disposition-guard` (this hook) are wired to fire on every `PreToolUse/Write` event. When both hooks evaluate the same Write event, deny from either hook wins. In the standard investigate-event workflow, Stage 7 generates the investigation document once from event-investigation-tmpl.yaml, which contains all four required section headings; the enrichment-completeness hook is satisfied immediately. This hook then evaluates the full ICD-203 12-field validation.

**Resolved (DI-004/SM-1, PR #17):** The "Alternatives Considered" section check now uses a heading-anchored regex. Body text no longer falsely satisfies the gate. DI-004/SM-1 is KILLED.

**v1.6 EMITTER role (D-DEC-001):** This hook is now effectful for the allow path when ICD-203 validation passes and no hard floor applies. The EMITTER role is the ONLY marker issuance path in the system. ASM-009 (cross-hook filesystem access — disposition-guard writes, require-review reads) is UNVALIDATED; formal-verifier must design a BATS test confirming marker file visibility across hook invocations before Wave 3 story merge (see prd-delta.md §5 Open Question #5).

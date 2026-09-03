---
document_type: behavioral-contract
level: L3
version: "1.42"
status: draft
producer: product-owner
timestamp: 2026-07-20T00:00:00
phase: f2
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/disposition-guard.sh, plugins/secops-factory/tests/hooks.bats, phase-f2-spec-evolution/architecture-delta.md]
input-hash: "de1ff1d"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/disposition-guard.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-03
lifecycle_status: active
introduced: v0.7.0
modified: ["v1.1-ADV-0-403-2026-07-19", "v1.2-ADV-0-501-ADV-0-507-2026-07-19", "v1.3-ADV-0-605-ADV-0-606-2026-07-19", "v1.4-ADV-0-B01-2026-07-19", "v1.5-RESYNC-PR17-2026-07-19", "v1.6-D-DEC-001-ICD-203-2026-07-20", "v1.7-FV-VP-HOOK-025-FINALIZED-2026-07-20", "v1.8-ADV-F2-001-003-004-016-2026-07-20", "v1.9-ADV-F2-P2-001-emitter-ordering-2026-07-20", "v1.10-ADV-F2-P3-001-002-003-011-2026-07-20", "v1.11-FV-VP-026-025-ANCHORS-2026-07-20", "v1.12-P4-001-P4-002-P4-005-P4-006-D-DEC-012-2026-07-21", "v1.13-FV-VP-028-025-026-029-ANCHORS-2026-07-21", "v1.14-ADV-F2-P5-001-P5-002-P5-003-2026-07-21", "v1.15-ADV-F2-P6-001-P6-002-2026-07-21", "v1.16-ADV-F2-P7-001-2026-07-21 [SM-ID-sync per FV]", "v1.17-ADV-F2-P8-001-OBS-2-2026-07-21", "v1.18-ADV-F2-P10-001-P10-003-P10-004-P10-008-2026-07-22 [ID-sync per FV]", "v1.19-ADV-F2-P11-001-P11-002-P11-003-P11-004-2026-07-22 [ID-sync per FV]", "v1.20-ADV-F2-P12-001-P12-002-P12-003-2026-07-22 [ID-sync per FV]", "v1.21-ADV-F2-P13-001-002-003-004-2026-07-22 [ID-sync per FV]", "v1.22-ADV-F2-P14-004-garbled-test-vector-parenthetical-2026-07-22", "v1.23-ADV-F2-P15-002-evidence-types-18field-2026-07-22", "v1.24-ADV-F2-P16-003-pc1-vphook028-18field-2026-07-22", "v1.25-CV-010-evidence-types-path-dispatch-annotation-2026-07-23", "v1.26-ADV-F2-P17-003-EC-005-L814-markdown-no-comment-marker-2026-07-23", "v1.27-ADV-F2-P18-001-003-005-D-020-021-022-link-close-scope-2026-07-23", "v1.28-ADV-F2-P19-001-P19-003-D023-close-disposition-gate-emit-time-validation-2026-07-23", "v1.29-ADV-F2-P20-001-D025-STEP4b-close-disposition-hoist-2026-07-27", "v1.30-ADV-F2-P21-001-D025-canonical-vector-sync-SM69-kill-vector-2026-07-27", "v1.31-ADV-F2-P22-003-P22-001-D027-STEP3b-markdown-reorder-2026-07-28", "v1.32-ADV-F2-P23-001-P23-004-P23-005-P23-007-D028-EMIT_LINK_MARKER-STEP3b-null-binding-org-binding-2026-07-29", "v1.33-ADV-F2-P24-001-P24-002-P24-003-EMIT_LINK_MARKER-invocation-O7-site10-L1107-precondition-2026-07-29", "v1.34-ADV-F2-P25-001-P25-002-P25-003-P25-004-D029-markdown-hard-floor-routing-VP-HOOK-031-rewrite-2026-07-29", "v1.35-ADV-F2-P26-001-P26-002-P26-003-P26-004-pc2-d029-routing-rewrite-qualify-no-deny-kill-switch-residual-gate-grammars-2026-07-29", "v1.36-ADV-F2-P27-001-P27-002-P27-003-structural-deny-disposition-parse-path-aware-WRITE_MARKER-2026-07-29", "v1.37-ADV-F2-P28-001-P28-002-WRITE_MARKER-per-path-definedness-org_slug-validate_enums-2026-07-29", "v1.38-ADV-F2-P29-001-WRITE_MARKER-link_target-defined-guard-per-path-table-A1A2-2026-07-29", "v1.39-ADV-F2-P29-001-org_slug-operational-metadata-roster-schema-v22-annotation-2026-09-02", "v1.40-ADV-F2-P30-001-P30-003-org_slug-residual-link_target-conditional-2026-09-02", "v1.41-P31-002-ALWAYS-PRESENT-producer-obligation-clarification-2026-09-02", "v1.42-P32-coherence-sweep-2026-09-03"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.03.001: disposition-guard Hook — Alternatives-Required Gate and ICD-203 Validator / Marker Emitter

> **Revision history:**
> - v1.42 (2026-09-03): P32-coherence-sweep — version pin update only. BC-10.01.001 cross-reference in Invariant #9 operational-metadata roster (org_slug "see also" citation, ~line 999) updated from v1.31 → v1.32. No behavior or semantics changed. P32-coherence-sweep. P32-coherence-sweep completion: propagated additional missed cross-ref pins (consistency-validator exhaustive re-check) — VP-HOOK-031 "Consumed by" citations updated: BC-5.01.001 v1.14 → v1.15, BC-4.02.001 v1.20 → v1.21 at both inline paragraph (~L1263) and Verification Properties table row (~L1351). Coherence-sweep completion (burst-33 VP-ownership audit): VP Anchors row added to Traceability section declaring VP-HOOK-030/VP-HOOK-031/VP-HOOK-032 ownership (verification-delta §1 lines 435–437 authority; prd-delta v1.35). VP-status-agreement sweep completion (burst-37): VP-HOOK-025 VP table row (~line 1350) cross-ref corrected VP-HOOK-030 from FINALIZED P0 (v1.13) → FINALIZED (consistency VP) per v1.14 downgrade (P11-001; P38-001/burst-37).
> - v1.41 (2026-09-02): Pass-31 adversarial remediation — P31-002 (MINOR) ALWAYS-PRESENT producer-obligation annotation. Operational-metadata presence-split roster header (~line 993) was co-labeling both `autonomy_enabled` and `org_slug` as "ALWAYS-PRESENT" without distinguishing producer obligation from consumer enforcement. A reader could incorrectly infer that an absent `autonomy_enabled` would be DENIED (like `org_slug`), breaking kill-switch default-false semantics. Fix: added a one-clause P31-002 note immediately after the roster header explaining that "ALWAYS-PRESENT" is a PRODUCER obligation (monitoring-loop MUST write the key); that only `org_slug` is CONSUMER-ENFORCED (validate_enums() presence-deny — P28-002/DI-017); and that `autonomy_enabled` absent is tolerated→false at the consumer (kill-switch default — VP-HOOK-026/SM-33), NOT denied. References individual field entries for full enforcement detail. No behavior or semantics changed. BC-10.01.001 v1.32 and prd-delta.md v1.32 updated in parallel. P31-002.
> - v1.40 (2026-09-02): Pass-30 adversarial remediation — P30-001 (MEDIUM) org_slug residual wording corrected + P30-003 (LOW) operational-metadata roster reconciled to 5-field model. **(1) P30-001 — validate_enums() ASM-008-class residual wording (~lines 225–230):** Previous wording stated "fails-closed for cross-org writes (no escaping cross-org)" — self-contradictory because a mis-route to a different configured org's project key IS a cross-org write that succeeds. Corrected to accurate characterization: D-028 org-binding CONTAINS the residual to configured orgs (read_org_project_key resolves only configured slugs; unconfigured/arbitrary projects unreachable), but a forged org_slug is a BOUNDED CROSS-TENANT MIS-ROUTE, NOT a fail-closed outcome; full membership-validation deferred per DI-017. Identical corrected wording also applied to BC-10.01.001 v1.31 Invariant #9 org_slug bullet (P30-001 identical-wording requirement). **(2) P30-003 — operational-metadata roster reconciled to 5-field model:** link_target_ticket_id was the conditional 5th operational-metadata field already documented in prd-delta.md v1.30 (~line 268) but omitted from both BC rosters. Fix: (a) STEP-5 inline comment updated to acknowledge 4 always-present fields + conditional link_target_ticket_id (link actions only); (b) dedicated operational-metadata roster extended with `verdict.link_target_ticket_id` CONDITIONAL bullet (D-020/P18-001/P30-003). BC-10.01.001 v1.31 Invariant #9 roster and prd-delta.md v1.31 updated in parallel. **(3) Pre-existing structural fix:** Added missing `## Description` section (template compliance; hook-blocked); escaped unescaped `|` in table row line 1330 (P24-002 O7-site10 vector, `SEC\|.*`) and line 1343 (VP-HOOK-031 row, MITRE technique IDs and degraded\|silent). P30-001/P30-003.
> - v1.39 (2026-09-02): Pass-29 adversarial remediation — P29-001 producer propagation gap. **(1) P29-001 propagation (MAJOR) — org_slug added to operational-metadata field roster (Invariant #9 area, ~line 984):** `org_slug` was already fail-closed-enforced by validate_enums() (~lines 216–225, v1.37/P28-002) and enrolled in the STEP 5 NON-ICD-203 field list (line ~560). The dedicated operational-metadata roster at ~line 984 was not updated at P28-002, leaving the roster inconsistent with validate_enums() and STEP 5. Fix: added `verdict.org_slug` (string; per-org loop iteration context; NOT ICD-203; fail-closed on absent/empty per P28-002/DI-017) to the operational-metadata fields bullet list alongside verdict.autonomy_enabled, verdict.jira_project_key, and verdict.confidence_score. **(2) P29-001 OBS — schema v2.0 changes block annotated with v2.2 extension note (~line 993):** The `authorized_operations` values list in the "Schema v2.0 changes from v1.0" block listed comment/create/assign/create-review/comment-review (correct for v2.0/v2.1) but a reader landing there would be unaware that `link` and `close` were added at schema v2.2 (D-020/D-021/P18-001). Added one-line annotation: "**[schema v2.2 additions]** `link` (D-020/P18-001) and `close` (D-021/P18-005) were added to authorized_operations at v2.2; canonical schema (~line 972) lists all seven values." The canonical schema itself is already complete — no change. P29-001/P28-002/DI-017.
> - v1.38 (2026-07-29): Pass-29 adversarial remediation burst 26 — P29-001 WRITE_MARKER link_target definedness fixed COMPREHENSIVELY across ALL entry paths; per-path table split Path A → A1/A2; arch-delta v1.31. **(1) P29-001 (MEDIUM) — WRITE_MARKER link_target defined()-guarded backstop (closes STEP-3-review-path definedness gap + all sibling entry paths):** Root cause: the per-path table (v1.37) grouped STEP-3 GOTOs (create-review/comment-review) and STEP-6 fall-throughs as "Path A". STEP-6 non-link paths have `link_target = null` at STEP-6 entry (~L577). STEP-3 GOTOs, however, jump to WRITE_MARKER WITHOUT passing through STEP 6 — `link_target` was never pre-assigned on those paths. In bash this evaluates as empty string `""`, causing `marker.link_target_ticket_id: ""` (not JSON null) for create-review/comment-review hard-floor verdicts. **Three-part fix:** (a) Added `link_target = defined(link_target) ? link_target : null` inside WRITE_MARKER after the existing is_link_hard_floor/is_markdown_path defined()-guards (L876/L877 pattern) — this backstop covers ALL present and future GOTO WRITE_MARKER entry paths. (b) Added explicit belt-and-suspenders `link_target = null` before both STEP-3 GOTOs (create-review and comment-review), making definedness unambiguous on Path A1. (c) Added P29-001 annotation to `link_target = ticket_id_b` in EMIT_LINK_MARKER (was already explicit; annotation confirms the defined()-guard preserves ticket_id_b, not nulling it). **Per-path coverage:** Path A1 (STEP-3 create-review/comment-review GOTOs): explicit null (P29-001 b.) + defined()-guard preserves null ✓; Path A2 (STEP-6 non-link fall-throughs): explicit null at STEP-6 entry + defined()-guard preserves null ✓; Path B (markdown GOTOs): explicit null in setup block (P28-001) + defined()-guard preserves null ✓; Path C (EMIT_LINK_MARKER): explicit `link_target = ticket_id_b` global (P29-001 c.) + defined()-guard preserves ticket_id_b ✓. **(2) Per-path variable-definedness table split Path A → A1/A2:** Table header updated from "P28-001/v1.37 — three entry paths" to "P28-001/P29-001/v1.38 — four entry paths". Path A split into A1 (STEP-3 GOTO: create-review/comment-review pre-STEP-6) and A2 (STEP-6 GOTO: comment/create/assign/close non-link fall-throughs). link_target row corrected: A1 "belt-and-suspenders explicit null P29-001 + defined()-guard → null" (was: false "null for all GOTO paths"); A2 "explicit null at STEP-6 entry + defined()-guard → null". is_review_path row updated: Path A1 TRUE; Path A2 FALSE for non-review actions. **(3) Updated EMIT_LINK_MARKER header comment** to confirm link_target is explicitly set to ticket_id_b before WRITE_MARKER invocation (not from a self-computing form inside WRITE_MARKER). **(4) Two new canonical test vectors:** (a) hard-floor verdict + create-review → STEP-3 GOTO WRITE_MARKER → emitted marker link_target_ticket_id = null (JSON null); (b) mirror for hard-floor verdict + comment-review path. **(5) Stale "self-computing in EMIT_LINK_MARKER" comment removed** from STEP-6 link_target initialization (L577).
> - v1.37 (2026-07-29): Pass-28 adversarial remediation burst 25 — P28-001 WRITE_MARKER per-path variable definedness; P28-002 org_slug roster + validate_enums; arch-delta v1.30. **(1) P28-001 (MEDIUM) — WRITE_MARKER markdown-path variable definedness:** Added `markdown_parsed_disposition = parsed_disposition` to BOTH markdown setup blocks (MARKDOWN_COMMENT_REVIEW_PATH and MARKDOWN_CREATE_REVIEW_PATH) to make WRITE_MARKER's `is_markdown_path` ternary read a defined variable; added explicit `link_target = null` to both setup blocks (action is NEVER "link" on markdown path; ticket_id_b is undefined here; EMIT_LINK_MARKER is never called on this path — the "self-computing in EMIT_LINK_MARKER" comment was false); removed dead `asset_type_field = null` from both setup blocks (WRITE_MARKER computes this inline as `null IF is_markdown_path ELSE verdict.asset_type`; the pre-assignment was never consumed from the setup block); fixed false setup-block comments: replaced "markdown_parsed_disposition already set by parse_disposition_from_markdown() above" with the actual explicit assignment + accurate description; replaced "link_target: null on markdown path; self-computing in EMIT_LINK_MARKER" with explicit `link_target = null` assignment; updated setup block header from "P27-002" to "P27-002/P28-001". Added per-path variable-definedness table to WRITE_MARKER header comment covering all three entry paths (verdict GOTO, markdown GOTO, EMIT_LINK_MARKER direct-invoke) and all variables WRITE_MARKER reads. Updated TP-investigation-markdown review vector to specify emitted marker field values (disposition.verdict="TP", org_slug from config, severity=null, asset_type=null, link_target_ticket_id=null). **(2) P28-002 (MINOR) — org_slug field roster + validate_enums presence check:** Added `org_slug` to the NON-ICD-203 operational-metadata field roster in STEP 5 comment (alongside autonomy_enabled, jira_project_key, confidence_score); added `verdict.org_slug` presence check to `validate_enums()` (fail-closed on absent/empty, analogous to native_severity check at P10-001); added ASM-008-class residual note (org_slug is LLM-supplied; D-028 org-binding provides bounded containment — forged org_slug can only mis-route to a different configured org's project key, which still fails-closed for cross-org writes); cross-referenced DI-017.
> - v1.36 (2026-07-29): Pass-27 adversarial remediation burst 24 — P27-001 structural-deny vs disposition-value-parse distinction; P27-002 path-aware WRITE_MARKER; P27-003 annotation; [ID per FV]→SM-77 resolved. **(1) P27-001 (MAJOR) — structural-deny vs disposition-value-parse distinction (D-029 item-1 arch error corrected):** Made the STRUCTURAL vs DISPOSITION-VALUE distinction explicit throughout: (a) missing any of the 12 ICD-203 headings OR missing Alternatives-Considered OR charset fail → structural DENY (EC-004/EC-010) — this is pre-D-029-routing gating, NOT a D-029-covered routing case; (b) all 12 headings PRESENT but Disposition heading VALUE non-canonical → PARSE_FAIL on value → allow + MARKDOWN_REVIEW_PATH. Removed "missing heading" from the PARSE_FAIL list in the parse grammar comment (missing heading = structural DENY, not PARSE_FAIL); updated Separate Human-Comment Marker Path intro prose to note that D-029 save-always-succeeds applies ONLY to structurally complete investigations. **(2) P27-002 (MAJOR) — path-aware WRITE_MARKER + markdown-path marker-write fail-loud:** Added markdown-path variable setup blocks (MARKDOWN_COMMENT_REVIEW_PATH / MARKDOWN_CREATE_REVIEW_PATH) with: `is_markdown_path=true`; `org_slug=get_org_slug_from_config()`; `action="comment-review"` or `"create-review"` (explicit, not from STEP 2); `recomputed_severity=null`; `asset_type_field=null`. Updated WRITE_MARKER section to add `is_markdown_path` initialization (false on verdict path), conditional field sources (`org_slug`, `verdict/markdown_parsed_disposition`, `asset_type`), and MARKER-WRITE-FAILED audit entry update to use is_markdown_path-conditional disposition. Removed false claim from L565 that link_target "is initialized here so WRITE_MARKER always has this variable defined." Markdown review path marker-write failure = MARKER-WRITE-FAILED deny (infrastructure-failure deny, P10-003 harm class), distinct from D-029 content/disposition guarantee. **(3) P27-003 (MINOR) — parse_autonomy_enabled_from_markdown annotation:** Annotated as "retained for defense-in-depth / P13-003 adversarial-masquerade detection only; NOT consulted in D-029 routing." **(4) [ID per FV] → SM-77 resolved:** D-029 deny-restoration kill target in VP-HOOK-031 paragraph updated from `[ID per FV]` to `SM-77`. **(5) Consumed-by citations updated:** BC-5.01.001 v1.13 → v1.14; BC-4.02.001 v1.18 → v1.20 in both VP-HOOK-031 paragraph and table row. **(6) Three new canonical test vectors added:** (a) missing Timeline Events heading → structural DENY (P27-001/EC-010; NOT D-029-covered); (b) all 12 headings + Disposition value "probably TP" → allow + MARKDOWN_REVIEW_PATH (P27-001 positive routing case); (c) markdown review path + injected WRITE_MARKER failure → MARKER-WRITE-FAILED deny (P27-002). P27-001, P27-002, P27-003.
> - v1.35 (2026-07-29): Pass-26 adversarial remediation burst 23 — P26-001/P26-002/P26-003/P26-004. **(1) P26-001 (MAJOR) — PC#2 routing rewrite to D-029 model:** Stale `[UPDATED v1.10/P13-001]` routing text with (a) GATE 1 kill-switch-first and (b) MARKDOWN-HARD-FLOOR deny replaced with D-029 model: hard floors → routing annotation + hard_floor_triggered=true (no deny); autonomy_enabled is NOT a routing gate on this path (P22-001); FP+no-hard-floor → allow-without-marker; FP+hard-floor/non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH. Old (a)/(b) text moved to Previous (v1.10/P13-001) blockquote. **(2) P26-002 (MEDIUM) — qualify "no deny possible" claims:** "no deny is possible on the markdown path" at PC#2 body (L986) and pseudocode comment (L994) qualified to "no disposition-/hard-floor-based deny is possible; structural ICD-203 completeness, Alternatives-Considered, and charset-injection guards (TICKET-ID-CHARSET-DENY / PROJECT-KEY-CHARSET-DENY) are retained and can still deny." **(3) P26-003 (MEDIUM) — kill-switch residual note added to Trust basis:** autonomy_enabled=false yields ZERO REGULAR writes; review-surface writes remain live (create-review/comment-review from verdict path, MARKDOWN_REVIEW_PATH from markdown path, hard-floor link via STEP 3b); markdown-path review markers issued WITHOUT hard_floor_applies() cross-validation (ACCEPTED RESIDUAL — 12-field markdown lacks the fields; bounded to review surface, operator-visible); see architecture-delta v1.28 §8.39. **(4) P26-004 (MINOR) — GATE 1/GATE 2 heading-anchored grammar specs mirrored into pseudocode:** three heading-anchored grammar specs added: disposition_section_contains evaluates via parse_disposition_from_markdown() (Disposition heading only); attack_techniques_contains_forbidden reads only canonical Attack Techniques heading value list (exact token match); sensor_health_status_is reads only canonical Sensor Health Status heading value. Free-text prose mentions MUST NOT trigger floors. Canonical negative vector added. P26-001, P26-002, P26-003, P26-004. **(5) Legacy Gate-1 vector wording sweep (burst-23 self-check):** Pre-P22-001 test vector rows (P12-002 TP+autonomy_enabled=true, P13-003 PARSE_FAIL+autonomy_enabled=true) updated — "Gate 1 passes (autonomy_enabled=true); Gates 2/3 floors pass" replaced with P22-001/D-029 mechanism language (GATE 1/2 floor checks pass; autonomy_enabled not a routing gate); routing outcomes unchanged.
> - v1.34 (2026-07-29): Pass-25 adversarial remediation burst 22 — D-029 markdown hard-floor routing model, VP-HOOK-031 rewrite, cite sweep, implementer note. **(1) P25-001/D-029 — Markdown hard-floor deny eliminated (save-always-succeeds):** GATE 1/GATE 2 hard-floor checks now write `"MARKDOWN-HARD-FLOOR: <reason>; routed to review (D-029)"` audit annotation and set `hard_floor_triggered=true` — NO deny, NO RETURN. FP dispatch updated to `parsed_disposition == "FP" AND hard_floor_triggered == false`; FP+hard_floor falls through to MARKDOWN_REVIEW_PATH (review marker, not allow-without-marker). HARD-FLOOR-UNBINDABLE converted from deny to allow-without-marker + audit annotation (D-029: Write permitted, review marker not issued, operator flagged). Routing model: FP + no hard floor → allow-without-marker; everything else (non-FP, PARSE_FAIL, any hard floor) → allow + MARKDOWN_REVIEW_PATH review marker. Canonical vectors L1135/L1136 (Indeterminate with and without autonomy_enabled) rewritten: deny → allow + MARKDOWN_REVIEW_PATH + MARKDOWN-HARD-FLOOR annotation. New vectors added: (a) T1003 technique save → allow + review marker; (b) FP + forbidden technique → allow + review marker (hard floor wins over FP disposition); (c) incomplete/PARSE_FAIL save → allow + review marker; (d) FP + clean → allow-without-marker. Trust basis updated to D-029 routing model. **(2) P25-002 — VP-HOOK-031 row rewrite:** Route rule updated for D-029 save-always-succeeds model; hard-floor entries → MARKDOWN_REVIEW_PATH (no deny); FP + no hard floor → allow-without-marker; FP + hard floor → MARKDOWN_REVIEW_PATH. SM-50 citation (retired) replaced with SM-73 ("markdown-gate1-kill-switch-restored", introduced P22-001 — tests that restoring autonomy_enabled Gate 1 causes non-FP+autonomy_enabled_absent → allow-without-marker instead of MARKDOWN_REVIEW_PATH). Kill-switch path route rule removed (autonomy_enabled is not a routing gate in D-029 model). **(3) P25-003 — Cite sweep:** All stale "BC-3.03.001 v1.24 Invariant #4" citations in consuming BCs updated to v1.34; "verification-delta v1.18" → "verification-delta (VP-HOOK-031, D-029 scope)". **(4) P25-004 — Implementer note:** Added one-line note that functions (EMIT_LINK_MARKER, WRITE_MARKER, etc.) are defined before their first call in the actual script; forward references in BC pseudocode are not runtime-ordering constraints. P25-001, P25-002, P25-003, P25-004, D-029. **Inline VP-HOOK-031 paragraph sweep (same burst, follow-up):** Header tag updated to include D-029 SCOPE UPDATE; "MARKDOWN-HARD-FLOOR deny" language replaced with D-029 routing-annotation model (audit annotation + hard_floor_triggered=true; NO deny); FP routing updated to D-029 conditional (FP + hard_floor_triggered==false → allow-without-marker; FP + hard floor → MARKDOWN_REVIEW_PATH); "P22-001 SM target (TBD)" → SM-73 kill target + D-029 deny-restoration kill target [ID per FV]; consumed-by citations updated to BC-5.01.001 v1.13 / BC-4.02.001 v1.18.
> - v1.33 (2026-07-29): Pass-24 adversarial remediation burst 21 — ADV-F2-P24-001 (MEDIUM, EMIT_LINK_MARKER control-flow contradiction resolved), ADV-F2-P24-002 (MEDIUM, O7 site 10 resolved_project_key emit-time hardening), ADV-F2-P24-003 (MEDIUM, L1107 REGULAR-link happy-path org-binding precondition). **(1) P24-001 — EMIT_LINK_MARKER invocation model (bash-faithful):** Function signature changed to `FUNCTION EMIT_LINK_MARKER(is_hard_floor_link)` — `verdict` and `recomputed_severity` accessed as globally visible bash variables (no arg needed); `is_hard_floor_link` received as positional arg `$1`. Marker variables set inside the function (`pattern`, `ops`, `link_target`, `is_link_hard_floor`) are NOT declared local — globally visible to WRITE_MARKER in bash semantics. WRITE_MARKER invoked directly as the function's final statement (NOT `GOTO WRITE_MARKER`, NOT a fall-through). Removed contradictory `END FUNCTION` + "falls through to WRITE_MARKER below" comment. Call sites updated: STEP 3b → `EMIT_LINK_MARKER true; RETURN`; STEP 6 ELIF link → `EMIT_LINK_MARKER false; RETURN`. WRITE_MARKER header comment updated to reflect direct invocation from EMIT_LINK_MARKER. **(2) P24-002 — O7 site 10 (resolved_project_key charset re-validation):** Inside EMIT_LINK_MARKER, after `read_org_project_key()` null check and BEFORE regex construction: emit-time charset re-validation of `resolved_project_key` against `^[A-Z][A-Z0-9]+$` — non-conformant → `LINK-PROJECT-KEY-CHARSET-DENY` audit code + deny (fail-closed; mirrors close_state three-layer treatment; corrective reason points at config). `resolved_project_key_safe = regex_escape(resolved_project_key)` labeled as defense-in-depth (no-op after charset check passes, guards drift); binding regex updated to use `resolved_project_key_safe`. O7 inventory updated: site 10 = `resolved_project_key` (EMIT_LINK_MARKER org-binding regex construction, CONFIG-side); active-site total corrected to 9 (5 ticket_id + 2 jira_project_key + 1 link_target_ticket_id + 1 resolved_project_key; jira_close_state remains site 9 by BC enumeration but is CONFIG-side, not an active injection site per arch-delta categorization). New canonical vector added: malformed `resolved_project_key` ("SEC|.*") → `LINK-PROJECT-KEY-CHARSET-DENY` deny. **(3) P24-003 — L1107 REGULAR-link happy-path vector org-binding precondition:** Added `config: resolved jira_project_key=SEC for the verdict's org_slug` precondition and org-binding step to expected flow; mirrors L1118 pattern. **(4) Canonical vector P24-001 sync:** Updated EMIT_LINK_MARKER references in vectors L1103, L1116, L1118, L1119 from keyword-arg form to positional form per P24-001. ADV-F2-P24-001, ADV-F2-P24-002, ADV-F2-P24-003, D-028.
> - v1.32 (2026-07-29): Pass-23 adversarial remediation — ADV-F2-P23-001 (MAJOR, D-028 defensive half of D-027: WRITE_MARKER fail-closed for hard-floor link path), ADV-F2-P23-004 (MEDIUM, GOTO-into-ELIF-ladder defect — STEP6_LINK label ill-formed GOTO target), ADV-F2-P23-005 (MEDIUM, STEP 3b has no org/project binding), ADV-F2-P23-007 (MINOR, v1.31 revision note self-contradictory wording). **(1) P23-001/D-028 + P23-004/P23-005 — EMIT_LINK_MARKER subroutine replaces GOTO STEP6_LINK:** STEP 3b: two HARD-FLOOR-UNBINDABLE null-binding guards inserted before the marker call (ticket_id null → deny; link_target_ticket_id null → deny, each with missing_field + corrective_action + hard_floor_trigger, mirroring P8-001 create-review/comment-review unbindable patterns); `GOTO STEP6_LINK` replaced with `EMIT_LINK_MARKER(verdict, recomputed_severity, is_hard_floor_link=true); RETURN`. STEP 6 ELIF link branch: `STEP6_LINK:` label removed; entire body replaced with `EMIT_LINK_MARKER(verdict, recomputed_severity, is_hard_floor_link=false); RETURN` (hard-floor link handled by STEP 3b comment added). New EMIT_LINK_MARKER function defined: O7 charset validation KEY1 (null KEY1 on REGULAR path → allow-without-marker; null KEY2 on REGULAR path → LINK-TARGET-MISSING deny; hard-floor path: nulls already caught by STEP 3b guards before call); D-028/P23-005 org/project binding via `read_org_project_key(verdict.org_slug)` with three LINK-PROJECT-BINDING-DENY paths (unconfigured org, KEY1 wrong project, KEY2 wrong project); pattern construction; `is_link_hard_floor = is_hard_floor_link`; falls through to WRITE_MARKER. WRITE_MARKER: `is_review_path` extended from `(action in {"create-review", "comment-review"})` to `(action in {"create-review", "comment-review"}) OR (action == "link" AND is_link_hard_floor)` (D-028 fail-closed for hard-floor link); MARKER-WRITE-FAILED audit comment updated to cite D-028; Gate-2 observability note: existing MARKER-WRITE-FAILED grep in BC-10.01.001 §D-DEC-003 cron wrapper covers hard-floor link write failures without pattern change. D-027 two-tier invariant text (schema v2.2 + generation table): extended with D-028 null-binding + org-binding + fail-closed requirements. v1.31 BLIND-SPOT canonical vector updated: GOTO STEP6_LINK wording replaced with EMIT_LINK_MARKER flow. **(2) Four new canonical test vectors:** (a) hard-floor link + marker-write failure → MARKER-WRITE-FAILED deny (D-028 fail-closed); (b) hard-floor link + null KEY2 → HARD-FLOOR-UNBINDABLE deny (D-028/P23-001, mirrors P8-001); (c) REGULAR link + KEY2 from different project → LINK-PROJECT-BINDING-DENY (D-028/P23-005); (d) REGULAR link + marker-write failure → allow-without-marker (P10-003 asymmetry preserved, D-028 does NOT change REGULAR path). **(3) P23-007 — v1.31 revision note wording fixed:** "(3) disposition routing runs FIRST" → "(3) disposition routing now precedes the former kill-switch position (which is removed)" (see v1.31 entry below). ADV-F2-P23-001, ADV-F2-P23-004, ADV-F2-P23-005, ADV-F2-P23-007, D-028.
> - v1.31 (2026-07-28): Pass-22 adversarial remediation — ADV-F2-P22-003 (CRITICAL, D-027 STEP 3b link review-class carve-out) + ADV-F2-P22-001 (MAJOR, markdown path disposition-routing-first reorder). **(1) P22-003/D-027 (CRITICAL) — STEP 3b link review-class carve-out:** `ticket_action_type=link` is now TWO-TIER per D-027 (HUMAN 2026-07-27): when `hard_floor_applies()`=TRUE, link is treated as review-class — exempt from STEP 4 hard-floor DENY and STEP 5 kill switch. A link verdict only records a relationship; it authorizes no triage decision. Without this carve-out, compound create+link verdict-2 was structurally unreachable for ALL hard-floor alerts (EC-008/EC-011/EC-013 paths) — a CRITICAL P22-003 gap. STEP 3b inserted between STEP 3 (comment-review GOTO WRITE_MARKER) and STEP 4 (hard-floor DENY): `IF action=="link" AND hard_floor_applies(): GOTO STEP6_LINK`. STEP 3b fires BEFORE STEP 4 and STEP 5; does NOT bypass STEP 1/1a; does NOT interact with STEP 4b close gate; `is_review_path` stays false for link. STEP6_LINK label added to the STEP 6 link branch (dual-entry: reached from STEP 3b hard-floor path OR normal STEP-6 non-hard-floor path with autonomy_enabled=true). O7 charset validation for KEY1/KEY2 runs at STEP6_LINK for both entry paths. STEP 4 preamble updated: "hard-floor link verdicts resolved at STEP 3b (D-027), never reach STEP 4." STEP 5 preamble updated to list STEP 3b as an additional early-exit path. Schema v2.2 link description updated to TWO-TIER posture (D-027). Operational metadata autonomy_enabled note updated: STEP 3b also irrelevant (exits before STEP 5). New canonical vector: `disposition=Indeterminate + sensor_health_status=silent + action=link + any autonomy_enabled → STEP 3b fires → ["link"] marker issued`. **(2) P22-001 (MAJOR) — markdown path disposition-routing-first reorder:** The prior GATE 1 `autonomy_enabled` kill switch check was the FIRST step in the Separate Human-Comment Marker Path gating sequence, causing non-FP/PARSE_FAIL investigation findings to exit via allow-without-marker when `autonomy_enabled=false` — violating D-DEC-012 Option A review-surfacing guarantee (exact D-025/P20-001 ordering pathology reproduced on the markdown path). Fix: GATE 1 autonomy_enabled kill switch removed from first position; the gating sequence is now: (1) 12-field completeness check (unchanged), (2) markdown-evaluable hard floors → GATE 1/GATE 2 (were GATE 2/3), (3) disposition routing now precedes the former kill-switch position (which is removed): FP → allow-without-marker (kill switch irrelevant); non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review, EXEMPT from kill switch per D-DEC-012 Option A regardless of autonomy_enabled). GATE numbering updated: GATES 2/3 → GATE 1/GATE 2. Trust basis paragraph updated (Gate 1 kill-switch-first rationale removed; disposition-routing-first rationale added). VP-HOOK-031 preamble updated for P22-001. Canonical vectors updated: (a) TP + autonomy_enabled absent/false → review marker issued (NOT allow-without-marker; P22-001 new vector); (b) Indeterminate + autonomy_enabled absent → MARKDOWN-HARD-FLOOR deny (was: allow-without-marker via old GATE 1; changed because hard floors now run before disposition routing); (c) FP + autonomy_enabled=true → allow-without-marker (outcome same; reason now: FP always allow-without-marker regardless of autonomy_enabled, not because Gate 1 fired/passed). ADV-F2-P22-003, ADV-F2-P22-001, D-027.
> - v1.30 (2026-07-27): Pass-21 adversarial remediation — ADV-F2-P21-001 (MAJOR, D-025 canonical-vector sync + SM-69 kill vector). Canonical test vectors corrected to match v1.29 STEP 4b pseudocode (lines 450–467): (1) **TP+close+autonomy=true vector** — attributing gate to STEP 4b (D-025/P20-001) with correct audit provenance string `(D-025/D-023/P20-001)` (was stale STEP-6 form `(D-023/P19-001)`); STEP 6 annotated as unreachable defense-in-depth; (2) **FP+close happy-path vector** and **FP+close+Archived vector** — STEP 4b passes explicitly noted (condition false for FP∈{FP,BTP}); STEP 6 labeled defense-in-depth; (3) **FP+close+autonomy=false vector** — STEP 4b passes noted before STEP 5 kill switch; (4) **NEW SM-69 kill vector**: disposition=TP + ticket_action_type=close + scored_priority=LOW + autonomy_enabled=FALSE → CLOSE-DISPOSITION-DENY at STEP 4b; STEP 5 kill switch NOT reached — this is the exact P20-001 regression case that D-025 exists to prevent. ADV-F2-P21-001, D-025.
> - v1.29 (2026-07-27): Pass-20 adversarial remediation — ADV-F2-P20-001 (MAJOR, D-025 STEP 4b hoist). **P20-001/D-025 — Close-disposition gate hoisted to STEP 4b (before STEP 5 kill switch):** D-023's gate was structurally unreachable when `autonomy_enabled=false` — a TP+close verdict exits at STEP 5 allow-without-marker before reaching STEP 6 close branch. D-025 resolves by inserting STEP 4b between STEP 4 and STEP 5: `IF action == "close" AND verdict.disposition NOT IN {"FP","BTP"} → CLOSE-DISPOSITION-DENY RETURN`. STEP 6 close branch D-023 check RETAINED as defense-in-depth only (annotated accordingly). STEP 5 comment updated to reference D-025/STEP 4b — kill switch now fires exclusively for regular-action, non-hard-floor, coherent verdicts. Generation table close row updated: STEP 4b is authoritative gate; STEP 6 check is defense-in-depth. ADV-F2-P20-001, D-025.
> - v1.28 (2026-07-23): Pass-19 adversarial remediation — ADV-F2-P19-001 (CRITICAL, D-023 disposition gate), ADV-F2-P19-003 (OBS, close-state emit-time validation + regex_escape). (1) **P19-001/D-023 (CRITICAL) — Disposition gate added as FIRST check in close branch:** `ticket_action_type=close` is an LLM-supplied routing field granting a state-change control (O3 standing rule); D-023 requires hook-side enforcement cross-validating `verdict.disposition∈{FP,BTP}` before any close marker issuance. Gate fires REGARDLESS of `autonomy_enabled` — a TP or Indeterminate verdict MUST NOT be auto-closed. If `verdict.disposition` not in {FP,BTP}: `CLOSE-DISPOSITION-DENY` audit entry written + emit deny with structured corrective reason; RETURN before ticket_id/close_state checks. Note: Indeterminate+close → STEP 4 UNDER-LABEL-DENIED fires FIRST (before STEP 6 close branch; Indeterminate is a hard floor with "close" as under-label token); D-023 gate fires for verdicts reaching STEP 6 (e.g., TP+LOW scored_priority). (2) **P19-003/D-023 (OBS) — Emit-time CLOSE_STATE_ALLOWLIST re-check + default="Done" + regex_escape(close_state):** `jira_close_state` default explicitly set to "Done" (fail-safe; "Done" ∈ CLOSE_STATE_ALLOWLIST). After ticket_id charset check: emit-time re-check of `close_state` against `CLOSE_STATE_ALLOWLIST={Done,Closed,Resolved}` (belt-and-suspenders against config drift); if not allowlisted → `CLOSE-STATE-DENY` audit entry + emit deny; RETURN. `close_state_safe = regex_escape(close_state)` (O7 site 9); `ticket_id_safe = regex_escape(ticket_id)` (renamed from reassignment for clarity); pattern uses `ticket_id_safe + " " + close_state_safe`. O7 site count updated 8→9. (3) **Canonical test vectors:** FP+close happy-path updated to show D-023 gate passing; new vectors: TP+close+LOW+autonomy=true → CLOSE-DISPOSITION-DENY; Indeterminate+close → STEP 4 UNDER-LABEL-DENIED (fires before close branch); close_state not in allowlist → CLOSE-STATE-DENY. (4) **Generation table close row updated:** D-023 gate noted as FIRST check; P19-003 emit-time validation noted; 3-condition AND explicit. ADV-F2-P19-001, ADV-F2-P19-003, D-023.
> - v1.27 (2026-07-23): Pass-18 adversarial remediation — ADV-F2-P18-001 (MAJOR, link scope), ADV-F2-P18-003 (MAJOR, close scope), ADV-F2-P18-005 (MAJOR, O7 interpolation audit update). (1) **P18-001/D-020 — link scope added:** `"link"` added to `ACTION_ENUM` and `authorized_operations`; new STEP 6 link branch: validates `ticket_id` (KEY1) + `link_target_ticket_id` (KEY2) against `^[A-Z][A-Z0-9]+-[0-9]+$` (O7 sites 3+8); LINK-TARGET-MISSING deny if `link_target_ticket_id` absent; LINK-TARGET-CHARSET-DENY if KEY2 fails charset; pattern `^jr (--output json )?issue link <ticket_id> <link_target_ticket_id>( |$)` (no `--type` arg — default "Relates" per D-020; link_type is NOT loop-supplied). Marker schema v2.2: `link_target_ticket_id` field added (non-null for `["link"]` scope; null for all other scopes). (2) **P18-003/D-021 — close scope added:** `"close"` added to `ACTION_ENUM` and `authorized_operations`; new STEP 6 close branch: validates `ticket_id` against `^[A-Z][A-Z0-9]+-[0-9]+$` (O7 site 4); `jira_close_state` from CONFIG (CLOSE_STATE_ALLOWLIST={Done,Closed,Resolved}, validated at setup, NOT verdict-influenceable); pattern `^jr (--output json )?issue move <ticket_id> <jira_close_state>( |$)`. **CLOSE security gating (D-021):** close is REGULAR scope (not review-exempt); `hard_floor_applies()`=true (scored_priority ∈ {HIGH,CRIT}) → STEP 4 DENY-THE-WRITE fires before STEP 6 is reached; `autonomy_enabled=false` → STEP 5 kill switch. A HIGH/CRIT verdict is NEVER auto-closed. No known-FP/close bypass to `hard_floor_applies()`. (3) **P18-005/O7 — interpolation audit updated to 8 sites:** O7 site count updated from 5 to 8 in security note; sites 3 (link KEY1 ticket_id), 4 (close ticket_id), and 8 (link KEY2 link_target_ticket_id) added. ADV-F2-P18-001, ADV-F2-P18-003, ADV-F2-P18-005.
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

## Description

The `disposition-guard` hook fires on every `PreToolUse/Write` event in the secops-factory pipeline and enforces two responsibilities: (1) the Alternatives-Required gate — denies investigation markdown writes missing a heading-anchored Alternatives Considered section; and (2) ICD-203 validator and marker emitter — validates all 18 mandatory ICD-203 fields in verdict JSON files and, when validation passes and no hard-floor applies, writes a time-limited `<uuid>.marker.json` token that authorizes the downstream `jr issue` Jira action. Hard-floor verdicts (HIGH/CRIT scored_priority, critical asset types, Indeterminate dispositions) are unconditionally routed to restricted human-review markers regardless of the `autonomy_enabled` kill switch.

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
   - **[UPDATED v1.36/P27-001/P27-002]** If the investigation-*.md glob matches AND both "Disposition" and "Alternatives Considered" headings are present, the hook enters **ICD-203 12-field validation (markdown path)** (artifact-class branching per architecture-delta v1.4 §D-DEC-008-C: investigation markdown = 12 ICD-203 fields; verdict JSON = 15 fields). The hook checks for the heading-anchored presence of all **12** mandatory fields as markdown section headings (`grep -qiE "^#{1,6}[[:space:]]+<field_name>"` for each field). The 12 mandatory field headings are: `Disposition`, `Confidence`, `Sensor Health Status`, `Evidence Artifacts`, `Timeline Events`, `Hypotheses Considered`, `Alternatives Rejected`, `Uncertainty Explicit`, `Attack Techniques`, `Agent Actions`, `Human Actions`, `Tuning Signal`. `Severity`, `Asset Type`, and `Ticket Action Type` are **NOT** required in the investigation-markdown validation path — they are monitoring-loop verdict fields only and are meaningless for a manual investigation (required exclusively in the PC#1 JSON verdict path). If any of the 12 headings is absent, the hook emits `permissionDecision: deny` with reason identifying the missing field (EC-010). If all 12 are present, the hook proceeds to the **Separate Human-Comment Marker Path (P11-004 / P12-002 / P13-001)** — this path does NOT enter the verdict emitter (Invariant #4); see 'Separate Human-Comment Marker Path' section in Invariant #4 for the authoritative pseudocode. **[UPDATED v1.36/P27-001/P27-002/P26-001/P22-001/D-029]** Post-D-029 routing (authoritative pseudocode in Invariant #4 Separate Human-Comment Marker Path): hard floors (Indeterminate disposition, forbidden techniques T1003/T1068/T1021/T1041, degraded/silent sensor) → routing annotation + `hard_floor_triggered=true` (NO deny; NO RETURN — D-029); `autonomy_enabled` is NOT a routing gate on this path (P22-001 eliminated GATE 1 kill-switch-first); FP + `hard_floor_triggered==false` → allow-without-marker (Write succeeds; no Jira action authorized); FP + `hard_floor_triggered==true` → MARKDOWN_REVIEW_PATH (hard floor wins over FP disposition); non-FP, PARSE_FAIL, or any hard floor → MARKDOWN_REVIEW_PATH (create-review/comment-review, EXEMPT from kill switch per D-DEC-012 Option A regardless of `autonomy_enabled`). **No autonomous comment marker for any disposition** (P13-001 MARKDOWN_COMMENT_PATH ELIMINATED). **P26-002/P27-001 — no disposition-/hard-floor-based deny (structurally complete investigations only):** D-029 applies ONLY when structurally complete (all 12 headings + Alternatives-Considered + charset passes) — no disposition-/hard-floor-based deny is possible on this path; structural ICD-203 completeness, Alternatives-Considered, and charset-injection guards (TICKET-ID-CHARSET-DENY / PROJECT-KEY-CHARSET-DENY) are pre-D-029-routing structural gates and are retained (they can still deny — P27-001). **P27-002 INFRASTRUCTURE EXCEPTION:** markdown review path marker-write failure → MARKER-WRITE-FAILED deny (infrastructure-failure; DISTINCT from D-029 content guarantee). **P26-003 ACCEPTED RESIDUAL:** markdown-path review markers are issued WITHOUT `hard_floor_applies()` cross-validation (12-field markdown lacks scored_priority/asset_type); `autonomy_enabled=false` does NOT suppress markdown-path review markers; blast radius bounded to review surface; see architecture-delta v1.28 §8.39. **Verification property (VP-HOOK-025 — FINALIZED, per-class split v1.19):** VP-HOOK-025 covers this investigation-markdown 12-field path: heading-anchored grep for each of the 12 fields; Severity, Asset Type, Ticket Action Type are NOT required as headings (verdict-JSON-only fields per D-DEC-008-C). Per-class split explicit: investigation-markdown 12-field path (uses Separate Human-Comment Marker Path) / verdict-JSON 18-field path (uses verdict emitter) (verification-delta.md v1.3 §2 / ADV-F2-P3-008).

   > **Previous (v1.10/P13-001 — superseded by P22-001 for (a) and D-029 for (b)):** "Post-P13-001 routing: (a) GATE 1 — `autonomy_enabled` absent or not exactly true → allow-without-marker (kill-switch parity; file saved; no Jira action); (b) markdown-evaluable floors (Indeterminate/forbidden-technique/degraded-silent sensor) → `permissionDecision: deny` (MARKDOWN-HARD-FLOOR); (c) no autonomous comment marker for any disposition — `parsed_disposition == "FP"` → allow-without-marker (MARKDOWN_COMMENT_PATH ELIMINATED, P13-001); `parsed_disposition != "FP"` or PARSE_FAIL → review marker (MARKDOWN_REVIEW_PATH, EXEMPT from kill switch)." [(a) superseded at P22-001/v1.31: `autonomy_enabled` is not a routing gate on this path; disposition routing runs first. (b) superseded at D-029/v1.34: hard floors converted from deny to routing signals — hard_floor_triggered=true + audit annotation; Write always proceeds; no deny issued.]

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
     ACTION_ENUM        = {"comment","create","assign","none","create-review","comment-review","link","close"}
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
     # P28-002: org_slug is a required operational-metadata field (alongside autonomy_enabled,
     # jira_project_key, confidence_score). Fail-closed on absent/empty value.
     # ASM-008-class residual: D-028 org-binding CONTAINS the residual to configured orgs — a
     # forged org_slug can only mis-route to a different configured org's project key
     # (read_org_project_key resolves only configured slugs; unconfigured/arbitrary projects are
     # unreachable), but this is a BOUNDED CROSS-TENANT MIS-ROUTE, NOT a fail-closed outcome;
     # full membership-validation that would close this gap is deferred per DI-017.
     # Note: full membership-against-[[orgs]] config check deferred to ASM-008 resolution;
     # presence check closes null-dereference risk in read_org_project_key() lookup.
     IF verdict.org_slug IS NULL OR verdict.org_slug == "":
       RETURN (False, "org_slug is absent or empty — required operational field (P28-002/DI-017)")
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
       link_target = null   # P29-001: explicit null (Path A1 belt-and-suspenders) — action is never "link" on this path; WRITE_MARKER defined()-guard backstop additionally covers this; STEP-3 GOTOs bypass the STEP-6 `link_target = null` at ~L577
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
       link_target = null   # P29-001: explicit null (Path A1 belt-and-suspenders) — action is never "link" on this path; WRITE_MARKER defined()-guard backstop additionally covers this; STEP-3 GOTOs bypass the STEP-6 `link_target = null` at ~L577
       GOTO WRITE_MARKER

   # ── STEP 3b: link review-class carve-out when hard_floor_applies() (D-027/D-028) ─────
   # D-027 (HUMAN 2026-07-27): ticket_action_type=link is TWO-TIER:
   #   - hard_floor_applies()=TRUE → review-class: EXEMPT from STEP 4 hard-floor DENY
   #     and STEP 5 kill switch. A link records a relationship only; it authorizes no
   #     triage decision — mirroring the D-DEC-012 rationale (review/relationship
   #     surfacing must not be blocked by the hard floor). is_review_path in WRITE_MARKER
   #     is extended to hard-floor link via is_link_hard_floor flag (D-028 fail-closed).
   #   - hard_floor_applies()=FALSE → REGULAR scope: falls through to STEP 5 kill switch
   #     + STEP 6 link branch as before (requires autonomy_enabled=true to issue marker).
   # STEP 3b fires BEFORE STEP 4 and BEFORE STEP 5.
   # Does NOT bypass STEP 1/1a (already passed at this point).
   # Does NOT interact with STEP 4b close gate (link ≠ close).
   # D-028/P23-001: null-binding fail-loud guards added before EMIT_LINK_MARKER call.
   # O7 charset validation for KEY1/KEY2 and org-binding check (LINK-PROJECT-BINDING-DENY)
   # reside in EMIT_LINK_MARKER for BOTH entry paths (P23-004 subroutine replaces GOTO).
   IF action == "link" AND hard_floor_applies(verdict, recomputed_severity):
     # ── D-028 (P23-001): null-binding fail-loud on the hard-floor link path ─────────
     # D-DEC-012 clause 2: hard-floor verdict cannot bind to a marker without key fields.
     # Mirrors P8-001 patterns for create-review (null jira_project_key) and
     # comment-review (null ticket_id). allow-without-marker is NOT acceptable here.
     ticket_id_step3b   = verdict.ticket_id
     ticket_id_b_step3b = verdict.link_target_ticket_id
     IF ticket_id_step3b is null:
       WRITE audit entry:
         "HARD-FLOOR-UNBINDABLE: hard-floor link verdict with null ticket_id (KEY1)" +
         "; missing_field=ticket_id" +
         "; corrective_action=populate verdict.ticket_id with the primary Jira ticket key" +
         "; hard_floor_trigger=" + identify_hard_floor_trigger(verdict) +
         "; verdict Write denied by disposition-guard (D-028/P23-001/D-DEC-012 clause 2)"
       emit deny(
         "HARD-FLOOR-UNBINDABLE: cannot bind hard-floor link marker without ticket_id (KEY1). " +
         "hard_floor_trigger=" + identify_hard_floor_trigger(verdict) + ". " +
         "missing_field=ticket_id. " +
         "Re-issue this Write with ticket_id populated in the verdict."
       )
       RETURN
     IF ticket_id_b_step3b is null:
       WRITE audit entry:
         "HARD-FLOOR-UNBINDABLE: hard-floor link verdict with null link_target_ticket_id (KEY2)" +
         "; missing_field=link_target_ticket_id" +
         "; corrective_action=populate verdict.link_target_ticket_id with the target Jira ticket key" +
         "; hard_floor_trigger=" + identify_hard_floor_trigger(verdict) +
         "; verdict Write denied by disposition-guard (D-028/P23-001/D-DEC-012 clause 2)"
       emit deny(
         "HARD-FLOOR-UNBINDABLE: cannot bind hard-floor link marker without link_target_ticket_id (KEY2). " +
         "hard_floor_trigger=" + identify_hard_floor_trigger(verdict) + ". " +
         "missing_field=link_target_ticket_id. " +
         "Re-issue this Write with link_target_ticket_id populated in the verdict."
       )
       RETURN
     # Null checks passed. Invoke EMIT_LINK_MARKER with is_hard_floor_link=true (positional $1).
     # P23-004/P24-001: subroutine replaces GOTO STEP6_LINK; P24-001 corrects to positional form.
     # EMIT_LINK_MARKER invokes WRITE_MARKER internally as its final statement;
     # RETURN here terminates STEP 3b after the entire marker decision has been resolved.
     # verdict and recomputed_severity are globally visible bash variables; no argument needed.
     EMIT_LINK_MARKER true
     RETURN

   # ── STEP 4: Hard-floor DENY-THE-WRITE for under-label (ADV-F2-P7-001 REDESIGN) ──
   # Note: hard-floor link verdicts are resolved at STEP 3b (D-027) and NEVER reach STEP 4.
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

   # ── STEP 4b: close-disposition early guard (D-025/D-023/P20-001) [HOISTED — fires BEFORE STEP 5] ──
   # O3 standing rule: authorization controls must be structurally earlier than paths that
   # would otherwise route around them. With D-023's gate inside STEP 6 close branch,
   # a TP+close verdict with autonomy_enabled=false exits at STEP 5 allow-without-marker,
   # never reaching the D-023 gate (P20-001 MAJOR). D-025 hoists the gate to STEP 4b so
   # it fires BEFORE the kill switch — for ALL autonomy_enabled values.
   IF action == "close" AND verdict.disposition NOT IN {"FP", "BTP"}:
     WRITE audit entry:
       "CLOSE-DISPOSITION-DENY: close authorized only for FP/BTP disposition, got '" +
       verdict.disposition + "'; verdict Write denied by disposition-guard (D-025/D-023/P20-001)"
     emit deny(
       "CLOSE-DISPOSITION-DENY: ticket_action_type=close is an LLM-supplied routing field " +
       "granting a state-change control; hook-computed invariant requires " +
       "verdict.disposition ∈ {FP, BTP}. Got disposition='" + verdict.disposition + "'. " +
       "A TP or Indeterminate verdict MUST NOT be auto-closed. " +
       "Re-issue with a non-close ticket_action_type appropriate for this disposition."
     )
     RETURN

   # ── STEP 5: autonomy_enabled kill switch (ADV-F2-P4-005 MAJOR) [REORDERED AFTER HARD-FLOOR — ADV-F2-P6-002] ──
   # ADV-F2-P6-002/D-025/D-027: After reorder, this STEP 5 is only reached for non-hard-floor
   # verdicts with valid disposition↔action coherence for close verdicts, AND non-hard-floor
   # link verdicts (hard-floor link verdicts exit at STEP 3b per D-027).
   # Paths that exit before STEP 5: review-path verdicts (STEP 3); hard-floor link verdicts
   # (STEP 3b, D-027); under-labeled hard-floor verdicts (STEP 4); incoherent close verdicts
   # (STEP 4b, D-025).
   # The kill switch fires exclusively for regular-action, non-hard-floor, coherent verdicts.
   # autonomy_enabled is a NON-ICD-203 operational metadata field in the verdict JSON
   # (alongside jira_project_key, confidence_score, and org_slug — the 4 always-present
   # operational-metadata fields; plus conditional link_target_ticket_id for link actions
   # only — D-020/P18-001/P30-003; see dedicated operational-metadata roster below).
   # Disposition-guard reads it directly from the verdict file (not delegated to the LLM).
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
   link_target = null   # schema v2.2: non-null only for ["link"] scope. P29-001 (Path A2): explicit null at STEP-6 entry for non-link fall-throughs (comment/create/assign/close); defined()-guard backstop in WRITE_MARKER preserves this null. When action=="link" (REGULAR path), STEP-6 ELIF link branch calls EMIT_LINK_MARKER which sets link_target=ticket_id_b globally before WRITE_MARKER invocation (P29-001/P24-001).
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

   ELIF action == "link":
     # ── D-020 (P18-001) / D-027 / D-028 / P23-004 / P24-001: REGULAR link scope (non-hard-floor path) ──
     # REGULAR link path (hard_floor_applies()=FALSE): autonomy_enabled=true reached this point.
     # Hard-floor link path (hard_floor_applies()=TRUE): handled by STEP 3b (D-027/D-028) —
     # null-binding guards applied, then EMIT_LINK_MARKER true called (P24-001 positional form);
     # this ELIF is NOT reached from STEP 3b.
     # P23-004/P24-001: GOTO STEP6_LINK replaced with named subroutine EMIT_LINK_MARKER;
     # P24-001 positional arg form: EMIT_LINK_MARKER true|false (is_hard_floor_link as $1).
     # O7 charset validation, O7 site 10 resolved_project_key re-validation (P24-002),
     # org-binding (D-028/P23-005), and pattern construction reside in EMIT_LINK_MARKER.
     EMIT_LINK_MARKER false
     RETURN

   ELIF action == "close":
     # ── D-023 (P19-001) / D-025 (P20-001): DISPOSITION CHECK — DEFENSE-IN-DEPTH ONLY ─────────
     # AUTHORITATIVE gate is STEP 4b (D-025/P20-001 hoist). The check below is RETAINED here
     # only because STEP 4b guarantees that only close+FP/BTP verdicts reach this branch.
     # Gate fires regardless of autonomy_enabled — structural guarantee provided by STEP 4b.
     # Note: Indeterminate+close never reaches this gate — STEP 4 UNDER-LABEL-DENIED fires first.
     IF verdict.disposition NOT IN {"FP", "BTP"}:
       WRITE audit entry:
         "CLOSE-DISPOSITION-DENY: close authorized only for FP/BTP disposition, got '" +
         verdict.disposition + "'; verdict Write denied by disposition-guard (D-023/P19-001)"
       emit deny(
         "CLOSE-DISPOSITION-DENY: ticket_action_type=close is an LLM-supplied routing field " +
         "granting a state-change control; hook-computed invariant requires " +
         "verdict.disposition ∈ {FP, BTP}. Got disposition='" + verdict.disposition + "'. " +
         "A TP or Indeterminate verdict MUST NOT be auto-closed. " +
         "Re-issue with a non-close ticket_action_type appropriate for this disposition."
       )
       RETURN
     ticket_id = verdict.ticket_id
     IF ticket_id is null: emit allow without marker; RETURN
     # P18-003/O7 site 4: charset-validation before interpolating ticket_id into close command_pattern
     IF NOT regex_match("^[A-Z][A-Z0-9]+-[0-9]+$", ticket_id):
       WRITE audit entry:
         now_iso8601() + " TICKET-ID-CHARSET-DENY: close path ticket_id='" + ticket_id +
         "' failed charset validation (P18-003/O7 site 4)"
       emit deny(
         "TICKET-ID-CHARSET-DENY: ticket_id='" + ticket_id + "' rejected before " +
         "command_pattern interpolation. Required: ^[A-Z][A-Z0-9]+-[0-9]+$ (P18-003/O7 site 4)."
       )
       RETURN
     ticket_id_safe = regex_escape(ticket_id)   # defense-in-depth after charset check (O7 site 4)
     # P19-003/D-023: explicit default "Done" — documented decision (fail-safe; "Done" is in
     # CLOSE_STATE_ALLOWLIST and is the standard Jira close state).
     close_state = read_config("jira_close_state", default="Done")
     # P19-003/D-023: EMIT-TIME CLOSE_STATE_ALLOWLIST CHECK — belt-and-suspenders against
     # config drift; setup-time validation is temporally distant from command issuance.
     CLOSE_STATE_ALLOWLIST = {"Done", "Closed", "Resolved"}
     IF close_state NOT IN CLOSE_STATE_ALLOWLIST:
       WRITE audit entry:
         "CLOSE-STATE-DENY: jira_close_state '" + close_state + "' not in CLOSE_STATE_ALLOWLIST; " +
         "verdict Write denied by disposition-guard (P19-003/D-023)"
       emit deny(
         "CLOSE-STATE-DENY: jira_close_state config value '" + close_state + "' is not allowlisted. " +
         "CLOSE_STATE_ALLOWLIST = {Done, Closed, Resolved}. " +
         "Reconfigure jira_close_state at setup time to a valid allowlisted value."
       )
       RETURN
     close_state_safe = regex_escape(close_state)   # P19-003 belt-and-suspenders per O7 (site 9)
     pattern = "^jr (--output json )?issue move " + ticket_id_safe + " " + close_state_safe + "( |$)"
     ops = ["close"]
     # link_target remains null (initialized above); schema v2.2: link_target_ticket_id=null for close scope

   # ── EMIT_LINK_MARKER(is_hard_floor_link) ─────────────────────────────────────────────────────
   # P24-001 INVOCATION MODEL (bash-faithful):
   #   - is_hard_floor_link: received as positional argument $1 (true|false).
   #   - verdict, recomputed_severity: accessed as globally visible bash variables — no arg needed.
   #   - Marker variables set inside this function (pattern, ops, link_target, is_link_hard_floor)
   #     are NOT declared local — they are globally visible to WRITE_MARKER in bash semantics.
   #   - link_target is EXPLICITLY assigned to ticket_id_b (KEY2) before WRITE_MARKER invocation
   #     (P29-001 global assignment). The WRITE_MARKER defined()-guard (`link_target = defined(link_target)
   #     ? link_target : null`) preserves this value (not nulled) on Path C. This replaces the retired
   #     self-computing form (`link_target = ticket_id_b IF action=="link" ELSE null`) that was
   #     previously in WRITE_MARKER — that form was undefined-reference-safe only in lazy-ternary
   #     languages; the explicit pre-assignment + defined()-guard backstop is language-agnostic.
   #   - Function invokes WRITE_MARKER directly as its final statement (not GOTO, not fall-through).
   #     WRITE_MARKER uses is_link_hard_floor to extend is_review_path (D-028 fail-closed).
   #   - Call sites: `EMIT_LINK_MARKER true; RETURN` / `EMIT_LINK_MARKER false; RETURN`.
   # Entry points:
   #   - STEP 3b (hard-floor link, D-027/D-028): is_hard_floor_link=true; KEY1/KEY2 already null-
   #     checked by the D-028 HARD-FLOOR-UNBINDABLE guards before this call.
   #   - STEP 6 ELIF action=="link" (regular link, D-020): is_hard_floor_link=false; null KEY1 →
   #     allow-without-marker; null KEY2 → LINK-TARGET-MISSING deny (P18-001).
   FUNCTION EMIT_LINK_MARKER(is_hard_floor_link):
     ticket_id   = verdict.ticket_id                # KEY1
     ticket_id_b = verdict.link_target_ticket_id    # KEY2

     # ── O7 site 3: KEY1 charset validation ─────────────────────────────────────────────
     # Regular path (is_hard_floor_link=false): null KEY1 → allow-without-marker (unchanged P18-001).
     # Hard-floor path (is_hard_floor_link=true): null KEY1 already caught by STEP 3b
     #   HARD-FLOOR-UNBINDABLE guard before this call; cannot reach here with null KEY1.
     IF ticket_id is null:
       emit allow without marker; RETURN      # REGULAR path only
     IF NOT regex_match("^[A-Z][A-Z0-9]+-[0-9]+$", ticket_id):
       WRITE audit entry:
         now_iso8601() + " TICKET-ID-CHARSET-DENY: link path ticket_id='" + ticket_id +
         "' failed charset validation (P18-001/O7 site 3)"
       emit deny(
         "TICKET-ID-CHARSET-DENY: ticket_id='" + ticket_id + "' rejected before " +
         "command_pattern interpolation. Required: ^[A-Z][A-Z0-9]+-[0-9]+$ (P18-001/O7 site 3)."
       )
       RETURN

     # ── O7 site 8: KEY2 charset validation ─────────────────────────────────────────────
     # Regular path: null KEY2 → LINK-TARGET-MISSING deny (P18-001).
     # Hard-floor path: null KEY2 already caught by STEP 3b HARD-FLOOR-UNBINDABLE guard.
     IF ticket_id_b is null:
       WRITE audit entry:
         now_iso8601() + " LINK-TARGET-MISSING: link path link_target_ticket_id absent (P18-001/D-020)"
       emit deny(
         "LINK-TARGET-MISSING: link action requires link_target_ticket_id field in verdict (P18-001/D-020)."
       )
       RETURN
     IF NOT regex_match("^[A-Z][A-Z0-9]+-[0-9]+$", ticket_id_b):
       WRITE audit entry:
         now_iso8601() + " LINK-TARGET-CHARSET-DENY: link path link_target_ticket_id='" + ticket_id_b +
         "' failed charset validation (P18-001/O7 site 8)"
       emit deny(
         "LINK-TARGET-CHARSET-DENY: link_target_ticket_id='" + ticket_id_b + "' rejected before " +
         "command_pattern interpolation. Required: ^[A-Z][A-Z0-9]+-[0-9]+$ (P18-001/O7 site 8)."
       )
       RETURN

     ticket_id   = regex_escape(ticket_id)    # defense-in-depth after charset check
     ticket_id_b = regex_escape(ticket_id_b)  # defense-in-depth after charset check

     # ── D-028/P23-005: org/project binding check (BOTH entry paths) ──────────────────
     # resolve jira_project_key per-org (P10-009/D-DEC-008) — CONFIG-side, NOT verdict-
     # influenceable (O6-safe). read_org_project_key: per-org jira_project_key with
     # global fallback if per-org not set.
     resolved_project_key = read_org_project_key(verdict.org_slug)
     IF resolved_project_key is null:
       WRITE audit entry:
         "LINK-PROJECT-BINDING-DENY: jira_project_key not configured for org_slug='" +
         verdict.org_slug + "'; verdict Write denied by disposition-guard (D-028/P23-005)"
       emit deny(
         "LINK-PROJECT-BINDING-DENY: cannot verify KEY1/KEY2 project binding — " +
         "jira_project_key not configured for org_slug=" + verdict.org_slug + ". " +
         "Ensure per-org or global jira_project_key is set in plugin config."
       )
       RETURN
     # ── P24-002/O7 site 10: charset re-validate resolved_project_key ────────────────────────
     # Mirrors the close_state three-layer treatment (setup-time validation + emit-time re-check
     # + regex_escape). Setup-time validation is temporally distant from emission; config drift
     # could yield a malformed resolved_project_key (e.g., "SEC|.*" or ".*") whose interpolation
     # broadens the binding regex to match unintended projects — defeating the P23-005 guarantee.
     # Re-validation is fail-closed (LINK-PROJECT-KEY-CHARSET-DENY + deny); regex_escape is
     # defense-in-depth (no-op after charset check passes, guards future drift).
     IF NOT regex_match("^[A-Z][A-Z0-9]+$", resolved_project_key):
       WRITE audit entry:
         "LINK-PROJECT-KEY-CHARSET-DENY: resolved jira_project_key '" +
         strip_control_chars(resolved_project_key) + "'" +
         " for org_slug='" + strip_control_chars(verdict.org_slug) + "'" +
         " does not match ^[A-Z][A-Z0-9]+$ charset (emit-time re-validation, P24-002/O7 site 10)" +
         "; verdict Write denied by disposition-guard"
       emit deny(
         "LINK-PROJECT-KEY-CHARSET-DENY: resolved jira_project_key is malformed. " +
         "corrective_reason=reconfigure jira_project_key for org via onboard-customer or activate; " +
         "value must match ^[A-Z][A-Z0-9]+$ (Jira project key format: uppercase alphanumeric, no hyphens)."
       )
       RETURN
     resolved_project_key_safe = regex_escape(resolved_project_key)   # O7 defense-in-depth (P24-002: no-op after charset check passes, guards drift)
     # KEY1 must match <resolved_project_key_safe>-<digits> (charset-validated + escaped; O7 site 10)
     IF NOT regex_match("^" + resolved_project_key_safe + "-[0-9]+$", verdict.ticket_id):
       WRITE audit entry:
         "LINK-PROJECT-BINDING-DENY: ticket_id (KEY1) '" + strip_control_chars(verdict.ticket_id) +
         "' does not belong to project " + resolved_project_key +
         "; verdict Write denied by disposition-guard (D-028/P23-005)"
       emit deny(
         "LINK-PROJECT-BINDING-DENY: ticket_id (KEY1) must belong to project " + resolved_project_key + ". " +
         "Got ticket_id='" + verdict.ticket_id + "'. Re-issue with a ticket key matching " +
         "^" + resolved_project_key + "-[0-9]+$."
       )
       RETURN
     # KEY2 must match <resolved_project_key_safe>-<digits> (charset-validated + escaped; O7 site 10)
     IF NOT regex_match("^" + resolved_project_key_safe + "-[0-9]+$", verdict.link_target_ticket_id):
       WRITE audit entry:
         "LINK-PROJECT-BINDING-DENY: link_target_ticket_id (KEY2) '" + strip_control_chars(verdict.link_target_ticket_id) +
         "' does not belong to project " + resolved_project_key +
         "; verdict Write denied by disposition-guard (D-028/P23-005)"
       emit deny(
         "LINK-PROJECT-BINDING-DENY: link_target_ticket_id (KEY2) must belong to project " + resolved_project_key + ". " +
         "Got link_target_ticket_id='" + verdict.link_target_ticket_id + "'. Re-issue with a ticket key matching " +
         "^" + resolved_project_key + "-[0-9]+$."
       )
       RETURN

     # D-020: no --type arg; jr issue link defaults to "Relates"; link_type NOT loop-supplied
     pattern    = "^jr (--output json )?issue link " + ticket_id + " " + ticket_id_b + "( |$)"
     ops        = ["link"]
     link_target = ticket_id_b   # P29-001: explicit GLOBAL assignment (no local qualifier); KEY2 for jr issue link KEY1 KEY2; schema v2.2: stored in link_target_ticket_id marker field. WRITE_MARKER defined()-guard preserves this value on Path C (does NOT null it).

     # D-028/P24-001: set is_link_hard_floor globally (no local qualifier — bash-visible to
     # WRITE_MARKER). Pass fail-loud flag to extend is_review_path for hard-floor links.
     # is_link_hard_floor=true  → marker-write failure → MARKER-WRITE-FAILED deny (fail-closed).
     # is_link_hard_floor=false → marker-write failure → allow-without-marker (P10-003 asymmetry).
     is_link_hard_floor = is_hard_floor_link   # set GLOBALLY (no local qualifier — bash-visible to WRITE_MARKER)
     WRITE_MARKER   # P24-001: direct invocation — NOT a GOTO; WRITE_MARKER runs, then returns here
   END FUNCTION EMIT_LINK_MARKER

   # ── WRITE_MARKER: common path for all marker types ──────────────────────────────────────────
   # Non-link paths reach here via GOTO WRITE_MARKER from STEP 3 (create-review/comment-review)
   # and STEP 6 (comment/create/assign/close). Link path: EMIT_LINK_MARKER invokes WRITE_MARKER
   # directly as its final statement (P24-001 — NOT a fall-through; NOT a GOTO; direct call).
   # P10-003: is_review_path flag gates fail-closed behavior on marker write failure.
   # Review-path marker failures must DENY (not allow-without-marker) because a review
   # marker that fails to write means the monitoring-loop LLM will issue a jr command
   # with no marker to validate against — hard-floor evidence silently dropped.
   # Regular (non-review) path retains the existing allow-without-marker behavior.
   # D-028: is_review_path extended to hard-floor link path.
   # is_link_hard_floor is set GLOBALLY by EMIT_LINK_MARKER (P24-001; no local qualifier).
   #
   # P28-001/P29-001/v1.38 — PER-PATH VARIABLE DEFINEDNESS TABLE (all FOUR entry paths):
   # P28-001: three-path table added (verdict/markdown/EMIT_LINK_MARKER).
   # P29-001: Path A split into A1 (STEP-3 GOTOs) and A2 (STEP-6 fall-throughs); link_target backstop added.
   # Root of P29-001 defect: Path A1 (STEP-3 GOTOs) jump to WRITE_MARKER BEFORE STEP 6 —
   #   the `link_target = null` at STEP-6 entry is NOT reached on the STEP-3 path.
   #   In bash, unset `link_target` evaluates as "" (empty string), not JSON null.
   #   The defined()-guard backstop below + belt-and-suspenders P29-001 null assignments fix this.
   #
   #   Variable              | Path A1: STEP-3 GOTO          | Path A2: STEP-6 GOTO          | Path B: Markdown GOTO      | Path C: EMIT_LINK_MARKER
   #                         | (create-review/comment-review | (comment/create/assign/close  | (MARKDOWN_*_REVIEW_PATH)   | (direct-invoke, action="link")
   #                         |  hard-floor; pre-STEP-6)      |  non-link fall-throughs)      |                            |
   #   ----------------------|-------------------------------|-------------------------------|----------------------------|-------------------------------
   #   is_markdown_path      | false (unset/default)         | false (unset/default)         | TRUE (setup block)         | false (unset/default)
   #   action                | set by STEP 3 branch          | set by STEP 6 ELIF branch     | set by routing pseudocode  | "link" (set in func body)
   #   org_slug              | N/A (see verdict.org_slug)    | N/A (see verdict.org_slug)    | get_org_slug_from_config() | N/A (see verdict.org_slug)
   #   verdict.org_slug      | present (verdict field)       | present (verdict field)       | ABSENT — no verdict object | present (global from verdict)
   #   markdown_parsed_      | N/A (verdict.disposition      | N/A (verdict.disposition      | parsed_disposition         | N/A (verdict.disposition
   #     disposition         |   used via ternary)           |   used via ternary)           |   (setup block, P28-001)   |   used via ternary)
   #   verdict.disposition   | present (verdict field)       | present (verdict field)       | ABSENT — no verdict object | present (global from verdict)
   #   recomputed_severity   | NORMALIZE_SEVERITY output     | NORMALIZE_SEVERITY output     | null (setup block)         | NORMALIZE_SEVERITY output
   #                         | (STEP 1a, before GOTO)        | (STEP 1a, before GOTO)        |                            | (global, set before call)
   #   verdict.asset_type    | present (field 14)            | present (field 14)            | ABSENT — no verdict object | present (global from verdict)
   #   link_target           | null — belt-and-suspenders    | null — explicit at STEP-6     | null (setup block, P28-001 | ticket_id_b (explicit global
   #                         | explicit null (P29-001) set   | entry (~L577, P29-001/A2);    |   explicit; ticket_id_b    |   assignment P29-001);
   #                         | before GOTO; defined()-guard  | defined()-guard → null        |   undefined on this path;  |   defined()-guard preserves
   #                         | → null (P29-001 backstop)     | (P29-001 backstop)            |   guard preserves null)    |   ticket_id_b (not nulled)
   #   is_link_hard_floor    | false (unset)                 | false (unset)                 | false (unset)              | true or false (is_hard_floor_link
   #                         |                               |                               |                            |   arg set globally before call)
   #   is_review_path        | computed inside WRITE_MARKER as: (action in {"create-review","comment-review"})
   #                         |   OR (action=="link" AND is_link_hard_floor)
   #                         | Path A1: TRUE (action ∈ {create-review,comment-review})
   #                         | Path A2: FALSE for non-review STEP-6 actions (comment/create/assign/close)
   #                         | Path B:  TRUE always (action ∈ {create-review,comment-review})
   #                         | Path C:  TRUE only when is_link_hard_floor=true (D-028)
   WRITE_MARKER:
   expires_at = now() + 120s
   # D-028 (P23-001): is_review_path extended to cover hard-floor link path.
   # is_link_hard_floor is set by EMIT_LINK_MARKER globally; default false for non-link paths.
   # Gate-2 observability: MARKER-WRITE-FAILED already in BC-10.01.001 §D-DEC-003 cron grep
   # set; no new grep pattern needed — hard-floor link write-failure uses same audit code
   # (D-028/BC-3.03.001 §8.36.1 Gate-2 observability note).
   is_link_hard_floor = (defined(is_link_hard_floor)) ? is_link_hard_floor : false
   is_markdown_path = (defined(is_markdown_path)) ? is_markdown_path : false   # P27-002: true on markdown review path; false on verdict path
   link_target = defined(link_target) ? link_target : null
   # P29-001: defined()-guarded backstop — mirrors L876/L877 treatment of is_link_hard_floor
   # and is_markdown_path. Paths that pre-assign link_target keep their value; paths that do not
   # safely default to null. Coverage per path:
   #   Path A1 (STEP-3 create-review/comment-review GOTO): belt-and-suspenders explicit null
   #     (P29-001) set before GOTO → defined()=true → guard preserves null ✓
   #   Path A2 (STEP-6 non-link fall-throughs): link_target=null (explicit at STEP-6 entry ~L577)
   #     → defined()=true → guard preserves null ✓
   #   Path B  (markdown GOTO): link_target=null in setup block (P28-001) → defined()=true
   #     → guard preserves null ✓
   #   Path C  (EMIT_LINK_MARKER): link_target=ticket_id_b explicit global (P29-001) →
   #     defined()=true → guard preserves ticket_id_b ✓ (NOT nulled)
   # This backstop closes the class: any future GOTO WRITE_MARKER site that omits a pre-assignment
   # automatically gets null (safe default), preventing bash empty-string expansion.
   is_review_path = (action in {"create-review", "comment-review"}) OR (action == "link" AND is_link_hard_floor)
   # P27-002: is_review_path is true on markdown review path (action is "comment-review" or "create-review").
   marker = {
     marker_id: generate_uuid(),
     issued_at_utc: now_iso8601(),
     expires_at_utc: expires_at,
     issued_by: "disposition-guard",
     ticket_id: ticket_id,
     org_slug: (is_markdown_path) ? org_slug : verdict.org_slug,   # P27-002: org from get_org_slug_from_config() on markdown path (no verdict object)
     authorized_operations: ops,
     command_pattern: pattern,
     link_target_ticket_id: link_target,  # schema v2.2: non-null only for ["link"] scope; null for all others; null on markdown path (action never "link")
     disposition: {
       verdict: (is_markdown_path) ? markdown_parsed_disposition : verdict.disposition,   # P27-002: from parse_disposition_from_markdown() on markdown path
       severity: recomputed_severity,  # P10-001: hook-recomputed severity, not LLM-supplied; null on markdown path (no STEP 1a — P27-002)
       asset_type: (is_markdown_path) ? null : verdict.asset_type,   # P27-002: field 14 absent from 12-field markdown ICD-203
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
         " verdict=" + ((is_markdown_path) ? markdown_parsed_disposition : verdict.disposition) + "/" + recomputed_severity + " (P10-003/D-028/P27-002)"
       emit deny(
         "MARKER-WRITE-FAILED: disposition-guard could not write review marker for action='" + action +
         "'. Review-path marker write failures are fail-closed (P10-003/D-028). Investigate marker-store " +
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

   **Canonical Marker JSON schema v2.2 (D-DEC-001 — single source of truth — P18-001/D-020 sync):**

   ```json
   {
     "marker_id": "<uuid-v4>",
     "issued_at_utc": "<ISO-8601 UTC with Z suffix, e.g. 2026-07-20T14:30:00.000Z>",
     "expires_at_utc": "<ISO-8601 UTC with Z suffix; = issued_at_utc + 120 seconds>",
     "issued_by": "disposition-guard",
     "ticket_id": "<jira-ticket-id-string | null>",
     "org_slug": "<org-slug-string>",
     "authorized_operations": ["comment"] | ["create"] | ["assign"] | ["create-review"] | ["comment-review"] | ["link"] | ["close"],
     "command_pattern": "<anchored regex — see D-DEC-008 generation table below>",
     "link_target_ticket_id": "<jira-ticket-id-string | null>",
     "disposition": {
       "verdict": "TP|FP|BTP|Indeterminate",
       "severity": "LOW|MEDIUM|HIGH|CRITICAL",
       "asset_type": "<asset_type_string>",
       "ticket_action_type": "<action>"
     }
   }
   ```

   **Operational metadata fields (non-ICD-203, not counted in 18 mandatory fields — P10-001/P11-002/P28-002/D-020/P30-003) — 4 ALWAYS-PRESENT + 1 CONDITIONAL:**
   > **P31-002 note:** "ALWAYS-PRESENT" denotes a PRODUCER obligation — the monitoring-loop MUST write the key in every verdict JSON regardless of `ticket_action_type`. Consumer enforcement is NOT symmetric: only `org_slug` is CONSUMER-ENFORCED (validate_enums() presence-deny — P28-002/DI-017); `autonomy_enabled` absent is tolerated→false at the consumer (kill-switch default — VP-HOOK-026/SM-33), NOT denied. See individual field entries below for enforcement details.
   - `verdict.autonomy_enabled` (boolean, default-false; ALWAYS-PRESENT): read by emitter at STEP 5 (kill switch); `false` or absent → kill switch fires (allow, no marker); `true` → proceed to regular marker issuance (STEP 6). Irrelevant for STEP 3 review-surfacing path, STEP 3b hard-floor link path (D-027), STEP 4 deny-the-Write path, and STEP 4b close-disposition path (all exit before STEP 5). Does NOT appear in the marker schema itself.
   - `verdict.jira_project_key` (string; ALWAYS-PRESENT): org binding for create/create-review patterns.
   - `verdict.confidence_score` (float 0.0–1.0; ALWAYS-PRESENT): raw posterior from assess-priority; D-DEC-011.
   - `verdict.org_slug` (string; ALWAYS-PRESENT; P28-002/DI-017/P29-001): per-org loop iteration context written at Stage 1 INGEST from monitoring-loop configuration — NOT LLM-delegated; fail-closed on absent/empty per validate_enums(); monitoring-loop MUST include this field in every verdict JSON; see also STEP 5 comment and BC-10.01.001 v1.35 Invariant #9 roster.
   - `verdict.link_target_ticket_id` (string|null; **CONDITIONAL — required non-null only when `ticket_action_type=link`; null for all other marker types**; D-020/P18-001/P30-003): second ticket key for `jr issue link KEY1 KEY2`; charset-validated against `^[A-Z][A-Z0-9]+-[0-9]+$` before interpolation into command_pattern (O7 site 7); in D-022 create+link compound sequences the link verdict MUST carry the ticket key returned by the preceding `jr issue create` call — NOT a placeholder; NOT enforced by disposition-guard field-validation (validate_enums does NOT check this field; validation occurs at EMIT_LINK_MARKER call time).

   **Schema v2.0 changes from v1.0 (ADV-F2-003 remediation):**
   - `ttl_seconds` REMOVED; `expires_at_utc` ADDED (absolute expiry = issued_at_utc + 120s). Consumer compares `now() > expires_at_utc` directly — no read-side clock-skew arithmetic.
   - `issued_at` renamed to `issued_at_utc` (Z-suffix required).
   - `used` field REMOVED. Single-use is enforced by atomic `mv` rename to `.marker.json.used` in require-review; the renamed file is excluded from `*.marker.json` glob (ADV-F2-018 dead-code removal).
   - `authorized_operations` values: `"comment"`, `"create"`, `"assign"`, `"create-review"` (D-DEC-012), `"comment-review"` (D-DEC-012). Never multi-element. **[schema v2.2 additions — P29-001 OBS]** `"link"` (D-020/P18-001) and `"close"` (D-021/P18-005) were added to `authorized_operations` at schema v2.2 (see Schema v2.2 additions block below and canonical schema above, which lists all seven values).
   - `disposition` sub-object ADDED with `verdict`, `severity` (field 13), `asset_type` (field 14), `ticket_action_type` (for audit trail).
   - TTL raised from 30s to 120s: empirically observed latency budget (hook execution + LLM decision latency + scheduling overhead) has 99th-percentile tail at ~90s; 120s provides 1.3× safety factor.

   **Schema v2.1 additions (ADV-F2-P5-003 sync — architecture-delta.md §D-DEC-001 v2.1):**
   - `authorized_operations` enum: formally includes `"create-review"` and `"comment-review"` (D-DEC-012 review-surfacing tokens; GATED on `hard_floor_applies()`=true at STEP 3 — P5-002 O3 standing-rule gate).
   - `disposition.verdict` enum: formally includes `"Indeterminate"` (hard-floor condition; never auto-closed; routes to review-surfacing path at STEP 3 when `ticket_action_type` is correctly set).
   - `disposition.ticket_action_type` sub-field: present in `disposition` sub-object (provides audit trail for STEP 3 routing decision and STEP 4 UNDER-LABEL-DENIED deny path (ADV-F2-P7-001) — see D-DEC-008 pseudocode).

   **Schema v2.2 additions (P18-001/D-020 + P18-003/D-021 sync — architecture-delta.md §D-DEC-001 v2.2):**
   - `authorized_operations` enum: extended to include `"link"` (D-020 link scope — `jr issue link KEY1 KEY2`, no `--type` arg; default "Relates"; **D-027 TWO-TIER**: when `hard_floor_applies()`=TRUE → review-class, exempt from STEP 4 + STEP 5 via STEP 3b; **D-028 hard-floor link null-binding**: non-null KEY1 and KEY2 required before EMIT_LINK_MARKER call (HARD-FLOOR-UNBINDABLE deny on null — D-028/P23-001); **D-028/P23-005 org-binding**: KEY1 and KEY2 must match resolved org `jira_project_key` prefix (LINK-PROJECT-BINDING-DENY deny — D-028); **D-028 fail-closed**: marker-write failure on hard-floor path → MARKER-WRITE-FAILED deny (is_link_hard_floor=true extends is_review_path); REGULAR path marker-write failure → allow-without-marker (P10-003 asymmetry unchanged); when `hard_floor_applies()`=FALSE → REGULAR scope, subject to STEP 5 kill switch) and `"close"` (D-021 close scope — `jr issue move KEY STATE`; close is REGULAR scope, subject to STEP 4 hard-floor check and STEP 5 kill switch; never issued for scored_priority ∈ {HIGH,CRIT}).
   - `link_target_ticket_id` field: non-null string (charset-validated Jira key `^[A-Z][A-Z0-9]+-[0-9]+$`) when `authorized_operations=["link"]`; `null` for all other scopes. Consumer MUST verify KEY2 in the command matches `marker.link_target_ticket_id` (structurally enforced by the command_pattern anchored match at consumer step 5 — the pattern encodes both KEY1 and KEY2).

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
   | `"link"` | KEY1 from verdict.ticket_id; KEY2 from verdict.link_target_ticket_id; **D-027/D-028 (STEP 3b hard-floor path):** non-null KEY1 and KEY2 required (HARD-FLOOR-UNBINDABLE deny if null — D-028/P23-001); org-binding: both must match resolved jira_project_key prefix (LINK-PROJECT-BINDING-DENY — D-028/P23-005); **REGULAR path:** null KEY1 → allow-without-marker; null KEY2 → LINK-TARGET-MISSING deny (P18-001) | `^jr (--output json )?issue link <ticket_id> <link_target_ticket_id>( |$)` (D-020: no `--type` arg; default "Relates"; link_type NOT loop-supplied; both keys charset-validated `^[A-Z][A-Z0-9]+-[0-9]+$` + regex-escaped; O7 sites 3+8; **D-028**: marker-write failure on hard-floor path → MARKER-WRITE-FAILED deny (is_link_hard_floor=true); REGULAR path → allow-without-marker (P10-003)) | `["link"]` | STEP 3b (hard-floor, D-027/D-028) / Step 6 ELIF (REGULAR) |
   | `"close"` | from verdict.ticket_id (non-null); **D-025/D-023 disposition gate (P20-001/P19-001): verdict.disposition MUST ∈ {FP,BTP} — AUTHORITATIVE gate is STEP 4b (D-025 hoist, fires BEFORE STEP 5 kill switch for ALL autonomy_enabled values); STEP 6 close branch check retained as defense-in-depth only; denies TP/Indeterminate as CLOSE-DISPOSITION-DENY** | `^jr (--output json )?issue move <ticket_id_safe> <close_state_safe>( |$)` (D-021/D-023: `jira_close_state` CONFIG-driven from CLOSE_STATE_ALLOWLIST={Done,Closed,Resolved}; default="Done"; NOT verdict-influenceable; validated at setup AND re-checked at emit time (P19-003 belt-and-suspenders); O7 site 4 (ticket_id_safe) + O7 site 9 (close_state_safe, regex_escaped); REGULAR scope: hard_floor_applies()=true (scored_priority ∈ {HIGH,CRIT}) → STEP 4 DENY-THE-WRITE fires before close branch; autonomy_enabled=false → STEP 5 kill switch; ONLY issued when disposition∈{FP,BTP} AND hard_floor_applies()=false AND autonomy_enabled=true) | `["close"]` | Step 6 |

   > **Previous (v1.10) create pattern:** `^jr (--output json )?issue create .*--project <jira_project_key>` (unbounded `.*` before `--project` allowed injection; no trailing boundary). **Previous (v1.10) table:** No `create-review` or `comment-review` rows; `"none"` had no semantic qualification.

   Trailing space after ticket_id in comment/assign/comment-review patterns is intentional: prevents `SEC-1234` matching a pattern anchored to `SEC-123 `.

   **P12-001/P18-001/P19-003/P24-002/O7 charset-validation at all interpolation sites:** Before any `ticket_id`, `jira_project_key`, `link_target_ticket_id`, or `resolved_project_key` value is interpolated into a `command_pattern` or binding regex, it is validated against a fixed charset (`ticket_id` / `link_target_ticket_id` → `^[A-Z][A-Z0-9]+-[0-9]+$`; `jira_project_key` / `resolved_project_key` → `^[A-Z][A-Z0-9]+$`) with hard deny on mismatch. `regex_escape()` applied as defense-in-depth after the charset check. **9 active O7 sites (5 ticket_id + 2 jira_project_key + 1 link_target_ticket_id + 1 resolved_project_key; P18-005 + P19-003 + P24-002):** site 1 (STEP 3 comment-review ticket_id), site 2 (STEP 3 create-review jira_project_key), site 3 (EMIT_LINK_MARKER link ticket_id KEY1), site 4 (STEP 6 close ticket_id → `ticket_id_safe`), site 5 (STEP 6 comment ticket_id), site 6 (STEP 6 create jira_project_key), site 7 (STEP 6 assign ticket_id), site 8 (EMIT_LINK_MARKER link link_target_ticket_id KEY2), site 9 (`jira_close_state` → `close_state_safe` — P19-003 belt-and-suspenders: CONFIG-driven value, emit-time CLOSE_STATE_ALLOWLIST re-checked + `regex_escape(close_state)` applied; setup-time validation + emit-time re-check + emit-time escape = three-layer protection; CONFIG-side — not an active injection site per arch-delta P24-002 categorization), **site 10 (EMIT_LINK_MARKER `resolved_project_key` → `resolved_project_key_safe` — P24-002: CONFIG-side value from `read_org_project_key()`; emit-time re-validated against `^[A-Z][A-Z0-9]+$` → LINK-PROJECT-KEY-CHARSET-DENY on fail (fail-closed, mirrors close_state three-layer treatment); `regex_escape()` as defense-in-depth — no-op after charset check passes, guards drift)**. This applies to all 7 rows that construct a `command_pattern` (comment, comment-review, assign, create, create-review, link, close) and the org-binding regex in EMIT_LINK_MARKER — see STEP 3, STEP 6, and EMIT_LINK_MARKER pseudocode above.

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

   **Separate Human-Comment Marker Path (P11-004 / redesigned P12-002 / P22-001 / D-029):**

   This sub-path applies ONLY to `investigation-*.md` files dispatched via PC#2. It does NOT enter the verdict emitter above. `validate_enums()` and STEP 1a (NORMALIZE_SEVERITY / SEVERITY-MISMATCH) are NOT called on this path. **P27-001 STRUCTURAL vs DISPOSITION-VALUE DISTINCTION (D-029 item-1 arch correction):** (a) **Structural incompleteness is a pre-D-029-routing gate**: missing any of the 12 ICD-203 headings, missing Alternatives-Considered, or charset fail → structural DENY (EC-004/EC-010) — these gates fire BEFORE D-029 routing and ARE NOT covered by D-029's save-always-succeeds guarantee; (b) **D-029 applies ONLY to structurally complete investigations**: all 12 headings present AND Alternatives-Considered present AND charset passes → D-029 guarantees no disposition-/hard-floor-based deny is possible; structural ICD-203 completeness and charset-injection guards (TICKET-ID-CHARSET-DENY / PROJECT-KEY-CHARSET-DENY) are retained and can still deny (P26-002). **P27-002 INFRASTRUCTURE EXCEPTION:** marker-write failure on the review path → MARKER-WRITE-FAILED deny (infrastructure-failure deny, P10-003 harm class) — DISTINCT from D-029's content/disposition guarantee; silent loss of review escalation is the harm. Hard floors are routing signals only: they set `hard_floor_triggered=true` and write a `"MARKDOWN-HARD-FLOOR: <reason>; routed to review (D-029)"` audit annotation, then fall through to disposition routing. Routing: `parsed_disposition == "FP" AND hard_floor_triggered == false` → allow-without-marker; `parsed_disposition == "FP" AND hard_floor_triggered == true` → MARKDOWN_REVIEW_PATH (hard floor wins over FP disposition); non-FP/PARSE_FAIL (any `hard_floor_triggered` value) → MARKDOWN_REVIEW_PATH. `autonomy_enabled` is not a routing gate. The gating sequence is: (1) 12-field completeness check (heading-anchored grep — structural DENY if incomplete; pre-D-029-routing gate), (2) GATE 1/GATE 2 hard floors → routing annotation + `hard_floor_triggered` (no deny — D-029), (3) disposition routing (FP + no hard floor → allow-without-marker; everything else → MARKDOWN_REVIEW_PATH).

   ```
   # ── SEPARATE HUMAN-COMMENT MARKER PATH (P11-004 / redesigned P12-002 / P13-001 / P22-001 / D-029) ──
   # Applies ONLY to investigation-*.md files (PC#2 dispatch).
   # This path does NOT enter the verdict emitter above.
   # Does NOT call validate_enums() or STEP 1a.
   #
   # P27-001 STRUCTURAL vs DISPOSITION-VALUE DISTINCTION:
   #   (a) Structural incompleteness (missing heading / missing Alternatives-Considered / charset fail)
   #       → structural DENY (EC-004/EC-010) — PRE-D-029-ROUTING gate; NOT a D-029-covered case.
   #   (b) D-029 applies ONLY when structurally complete (all 12 headings + Alternatives-Considered
   #       present + charset passes): no disposition-/hard-floor-based deny is possible (P26-002);
   #       structural guards can still deny (they are pre-routing, not disposition-based).
   # P27-002 INFRASTRUCTURE EXCEPTION: markdown review path marker-write failure → MARKER-WRITE-FAILED
   #   deny (P10-003 harm class) — DISTINCT from D-029 content/disposition guarantee.
   # D-029: Write ALWAYS succeeds on this path — no disposition-/hard-floor-based deny is possible
   # (P26-002 / P27-001 structural-completeness scope); structural ICD-203 completeness,
   # Alternatives-Considered, and charset-injection guards (TICKET-ID-CHARSET-DENY /
   # PROJECT-KEY-CHARSET-DENY) are retained and can still deny (pre-routing structural gates).
   # Hard floors (GATE 1/GATE 2 below) are routing signals only:
   #   - set hard_floor_triggered=true
   #   - write MARKDOWN-HARD-FLOOR audit annotation ("...; routed to review (D-029)")
   #   - NO deny; NO RETURN — fall through to disposition routing
   #
   # P22-001 FIX — DISPOSITION ROUTING RUNS FIRST (retained from P22-001; D-029 extends):
   # The prior GATE 1 autonomy_enabled kill switch check was the FIRST step, causing
   # non-FP/PARSE_FAIL investigation findings to exit via allow-without-marker when
   # autonomy_enabled=false — violating D-DEC-012 Option A (EXEMPT from kill switch).
   # Fix: autonomy_enabled is no longer the first check. Disposition routing runs FIRST.
   # D-029 routing: FP AND hard_floor_triggered==false → allow-without-marker.
   # FP AND hard_floor_triggered==true → MARKDOWN_REVIEW_PATH (hard floor wins).
   # Non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review — EXEMPT from
   # kill switch per D-DEC-012 Option A regardless of autonomy_enabled).
   # autonomy_enabled is not a routing gate on this path (D-029).
   #
   # ── GATE 1 / GATE 2: markdown-evaluable hard floors (P11-004, renumbered; D-029 routing signal) ──
   # D-029: hard floors set hard_floor_triggered=true + write audit annotation; NO deny; NO RETURN.
   # P26-004 — HEADING-ANCHORED GRAMMAR SPECS (mirrors architecture-delta v1.28 §8.39 parse grammars):
   #   disposition_section_contains("Indeterminate"): delegates to parse_disposition_from_markdown().
   #     Returns true IFF parse_disposition_from_markdown() returns "Indeterminate" (canonical
   #     Disposition heading value only). Free-text mentions of "Indeterminate" outside the
   #     Disposition heading MUST NOT trigger this floor.
   #   attack_techniques_contains_forbidden(["T1003","T1068","T1021","T1041"]): reads ONLY the
   #     canonical "Attack Techniques" heading value list; exact token match against the set
   #     {T1003, T1068, T1021, T1041}. Technique identifiers in log excerpts, code fences, body
   #     prose, or other headings MUST NOT match. Partial-string matches MUST NOT match.
   #   sensor_health_status_is("degraded"/"silent"): reads ONLY the canonical "Sensor Health Status"
   #     heading value; exact string match against {"degraded","silent"} (case-insensitive token).
   #     Prose mentions of "degraded" or "silent" outside the heading MUST NOT trigger this floor.
   # CANONICAL NEGATIVE VECTOR (P26-004 grammar-anchor negative): markdown with Disposition heading
   #   value "False Positive" and body prose mentioning "Indeterminate" and "T1003" →
   #   parse_disposition_from_markdown() returns "FP" → disposition_section_contains("Indeterminate")
   #   returns false; attack_techniques_contains_forbidden returns false (no heading-value match) →
   #   hard_floor_triggered=false → FP+no-hard-floor → allow-without-marker (NOT MARKDOWN_REVIEW_PATH).
   hard_floor_triggered = false
   IF disposition_section_contains("Indeterminate") OR
      attack_techniques_contains_forbidden(["T1003","T1068","T1021","T1041"]) OR
      sensor_health_status_is("degraded") OR sensor_health_status_is("silent"):
     WRITE audit entry: "MARKDOWN-HARD-FLOOR: [specific condition]; routed to review (D-029)"
     hard_floor_triggered = true
     # NO deny; NO RETURN — Write always proceeds; disposition routing below determines marker.
   #
   # ── PARSE DISPOSITION: route FP to allow-without-marker; non-FP/PARSE_FAIL to review ───────
   # Parse grammar (P13-003): parse_disposition_from_markdown reads ONLY the canonical
   # "Disposition" heading value. Maps via exact allowlist:
   #   {TP, FP, BTP, Indeterminate} + canonical long forms:
   #   "True Positive" → TP, "False Positive" → FP, "Benign True Positive" → BTP
   # Matching is case-insensitive on canonical tokens only.
   # PARSE_FAIL on: ambiguous value (e.g., "probably FP", "not a false positive"),
   #   multi-valued (e.g., "FP or BTP"), unrecognized token, empty value.
   # NOTE (P27-001): "missing heading" is NOT a PARSE_FAIL case — a missing Disposition heading is
   #   a structural DENY (EC-010 pre-routing gate), not a PARSE_FAIL routing case. The structural
   #   12-field completeness check at the top of this path already denies before parse runs.
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
   IF parsed_disposition == "FP" AND hard_floor_triggered == false:
     # FP + no hard floor: allow-without-marker. Write succeeds; no Jira action authorized.
     # P11-004 intent preserved: the analyst's Write is NOT denied.
     # To surface an FP comment via Jira, the analyst must use the review path or
     # the normal 18-field verdict flow.
     emit allow without marker
     RETURN
   # FP + hard floor (hard_floor_triggered==true): falls through to MARKDOWN_REVIEW_PATH below.
   # D-029: hard floor wins over FP disposition — review marker issued for operator visibility.
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
     # P27-002/P28-001: MARKDOWN_COMMENT_REVIEW_PATH — ALL variables WRITE_MARKER reads must
     # be explicitly assigned on this path (no verdict object, no STEP 2 dispatch).
     is_markdown_path    = true
     action              = "comment-review"   # explicit: action not set by STEP 2 on this path
     org_slug            = get_org_slug_from_config()   # NOT verdict.org_slug (no verdict object)
     # P28-001: CANONICAL DISPOSITION SOURCE for the markdown path.
     # parsed_disposition was set by parse_disposition_from_markdown(content) above.
     # WRITE_MARKER reads markdown_parsed_disposition via its is_markdown_path ternary.
     # Explicit assignment here makes definedness unambiguous; do NOT use verdict.disposition
     # (there is no verdict object on this path).
     markdown_parsed_disposition = parsed_disposition
     recomputed_severity = null   # STEP 1a absent on markdown path
     # P28-001: link_target — EXPLICIT NULL. action is NEVER "link" on this path;
     # ticket_id_b is undefined here. Explicit assignment removes undefined-reference risk.
     # EMIT_LINK_MARKER is never called on the markdown path — the prior "self-computing in
     # EMIT_LINK_MARKER" comment was false and has been removed.
     link_target         = null
     # asset_type_field: WRITE_MARKER computes this inline (null IF is_markdown_path ELSE
     # verdict.asset_type). No pre-assignment needed on this path. (P28-001: removed the
     # dead asset_type_field=null that was here — WRITE_MARKER never read it from setup block.)
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
       # P27-002/P28-001: MARKDOWN_CREATE_REVIEW_PATH — ALL variables WRITE_MARKER reads must
       # be explicitly assigned on this path (no verdict object, no STEP 2 dispatch).
       is_markdown_path    = true
       action              = "create-review"   # explicit: action not set by STEP 2 on this path
       org_slug            = get_org_slug_from_config()   # NOT verdict.org_slug (no verdict object)
       # P28-001: CANONICAL DISPOSITION SOURCE for the markdown path.
       # parsed_disposition was set by parse_disposition_from_markdown(content) above.
       # WRITE_MARKER reads markdown_parsed_disposition via its is_markdown_path ternary.
       # Explicit assignment here makes definedness unambiguous; do NOT use verdict.disposition
       # (there is no verdict object on this path).
       markdown_parsed_disposition = parsed_disposition
       recomputed_severity = null   # STEP 1a absent on markdown path
       # P28-001: link_target — EXPLICIT NULL. action is NEVER "link" on this path;
       # ticket_id_b is undefined here. Explicit assignment removes undefined-reference risk.
       # EMIT_LINK_MARKER is never called on the markdown path — the prior "self-computing in
       # EMIT_LINK_MARKER" comment was false and has been removed.
       link_target         = null
       # asset_type_field: WRITE_MARKER computes this inline (null IF is_markdown_path ELSE
       # verdict.asset_type). No pre-assignment needed on this path. (P28-001: removed the
       # dead asset_type_field=null that was here — WRITE_MARKER never read it from setup block.)
       GOTO WRITE_MARKER
     ELSE:
       # D-029: MARKDOWN-HARD-FLOOR-UNBINDABLE — allow-without-marker + audit annotation.
       # Write permitted; review marker not issued (no binding keys); operator flagged via audit.
       # Contrast: verdict-path HARD-FLOOR-UNBINDABLE is still deny (D-DEC-012 clause 2).
       WRITE audit entry: "MARKDOWN-HARD-FLOOR-UNBINDABLE: non-FP markdown finding with no ticket_id and no jira_project_key; allow-without-marker (D-029)"
       emit allow without marker
       RETURN
   ```

   **Jira project key constraint note (P13-002):** Jira project keys MUST be hyphen-free and match `^[A-Z][A-Z0-9]+$`. A key such as `PRISM-DEMO` with a hyphen will be rejected by PROJECT-KEY-CHARSET-DENY at every marker issuance. Validate at setup time via BC-6.01.001 (activate) and BC-6.01.003 (onboard-customer) to prevent this. Cross-reference: D-DEC-008 architectural constraint (architecture-delta.md v1.16).

   **Trust basis (P11-004 / P12-002 / P13-001 / P22-001 / D-029):** Gate 1/2 (P11-004, renumbered): markdown-evaluable floors (Indeterminate disposition, forbidden techniques T1003/T1068/T1021/T1041, degraded/silent sensor) — set `hard_floor_triggered=true` and write `MARKDOWN-HARD-FLOOR` audit annotation (D-029); NO deny; NO RETURN. Routing: `parsed_disposition == "FP" AND hard_floor_triggered == false` → allow-without-marker (hook cannot evaluate scored_priority/asset_type from 12-field markdown; D-029); `parsed_disposition == "FP" AND hard_floor_triggered == true` → MARKDOWN_REVIEW_PATH (hard floor wins over FP disposition; review marker issued; D-029); `parsed_disposition != "FP"` or PARSE_FAIL (any `hard_floor_triggered`) → MARKDOWN_REVIEW_PATH (create-review/comment-review; EXEMPT from kill switch per D-DEC-012 Option A). No disposition yields an autonomous comment marker (P13-001 MARKDOWN_COMMENT_PATH ELIMINATED). HARD-FLOOR-UNBINDABLE: allow-without-marker + audit annotation (D-029 — Write permitted, marker not issued, operator flagged; contrast: verdict-path HARD-FLOOR-UNBINDABLE is still deny per D-DEC-012 clause 2). `autonomy_enabled` is not a routing gate (D-029). **P26-003 ACCEPTED RESIDUAL per arch-delta v1.28 §8.39:** `autonomy_enabled=false` yields ZERO REGULAR writes; review-surface writes remain live: create-review/comment-review from the verdict path (EXEMPT per D-DEC-012 Option A, gated by hard_floor_applies()=TRUE), markdown-path review markers via MARKDOWN_REVIEW_PATH (EXEMPT per D-DEC-012 Option A), and hard-floor link via STEP 3b (D-027/D-028). Markdown-path review markers are issued WITHOUT `hard_floor_applies()` cross-validation — inherent asymmetry: 12-field markdown lacks scored_priority/asset_type; verdict path STEP 3 over-label gate cannot apply here. Blast radius bounded to review surface only (no close/triage/regular comment/create); review tickets are human-facing by construction; operator-visible. No hook-side dedup — repeated-save review-ticket creation is part of the residual (self-surfacing; see arch-delta v1.28 §8.39 residual block). Verdict-only fields (`scored_priority`, `asset_type`, `verdict.severity`) are NOT present in a standard ICD-203 investigation markdown and are NOT checked on this path. `ticket_id` parsed from free-text markdown is charset-validated (P12-001/O7) before interpolation.

   **Implementer note (P25-004):** Functions `EMIT_LINK_MARKER`, `WRITE_MARKER`, and all other pseudocode functions are defined before their first call in the actual script; forward references in this BC pseudocode are NOT runtime-ordering constraints.

   > **Previous (v1.20) route rule:** "P12-002 route rule: `parsed_disposition != "FP"` → MARKDOWN_REVIEW_PATH; FP + `autonomy_enabled=true` → MARKDOWN_COMMENT_PATH (comment marker)." The v1.21 change per P13-001: MARKDOWN_COMMENT_PATH eliminated; FP now → allow-without-marker.

   **Verification property (VP-HOOK-031 — FINALIZED P0, per verification-delta.md v1.14; UPDATED v1.15 P12-002 SM-50/SM-51; SCOPE UPDATE COMPLETE v1.21 P13-001 — SM-51 (route-to-review, reconciled) / SM-52 (FP-comment-marker revert); P22-001 SCOPE UPDATE — disposition-routing-first; D-029 SCOPE UPDATE — save-always-succeeds, hard-floor-routing-signal; P27-001/P27-002/P27-003 SCOPE UPDATE — structural-deny-vs-disposition-parse-distinction, path-aware-WRITE_MARKER-MARKER-WRITE-FAILED, parse_autonomy_enabled_from_markdown-defense-in-depth-only; SM-77 resolved):** Separate human-comment marker path correctness (P11-004 / P12-002 / P13-001 / P22-001 / D-029): the 12-field ICD-203 investigation-markdown path (PC#2 dispatch) does NOT enter the verdict emitter; `validate_enums()` and STEP 1a are NOT called on this path. Gate 1/2 (P11-004/D-029, renumbered): markdown-evaluable floors → write audit annotation "MARKDOWN-HARD-FLOOR: <reason>; routed to review (D-029)" + set `hard_floor_triggered=true`; NO deny issued; Write always succeeds. **P22-001/D-029 routing (save-always-succeeds):** D-029 model: FP AND `hard_floor_triggered==false` → allow-without-marker (MARKDOWN_COMMENT_PATH ELIMINATED per P13-001); FP + hard floor (`hard_floor_triggered==true`) → MARKDOWN_REVIEW_PATH (hard floor wins over FP disposition, D-029); non-FP/PARSE_FAIL (any `hard_floor_triggered` value) → MARKDOWN_REVIEW_PATH (create-review/comment-review — EXEMPT from kill switch per D-DEC-012 Option A regardless of autonomy_enabled). `autonomy_enabled` is not a routing gate in D-029 model. SM-52 kill target: restoring MARKDOWN_COMMENT_PATH causes FP+autonomy_enabled=true to emit ["comment"] marker — incorrect. SM-73 kill target ("markdown-gate1-kill-switch-restored", introduced P22-001): restoring autonomy_enabled Gate 1 causes non-FP+autonomy_enabled_absent → allow-without-marker instead of MARKDOWN_REVIEW_PATH (incorrect — D-029 routing ignores autonomy_enabled). D-029 deny-restoration kill target: restoring MARKDOWN-HARD-FLOOR deny violates save-always-succeeds — markdown hard-floor conditions MUST produce allow + routing annotation, not deny (SM-77). Adversarial parse vectors (P13-003): "Disposition: not a false positive" → PARSE_FAIL → review (NOT allow-without-marker); `autonomy_enabled: true` embedded in code fence → parse_autonomy_enabled_from_markdown returns false (embedded token does not match dedicated structured field) — **P27-003: retained for defense-in-depth / P13-003 adversarial-masquerade detection only; NOT consulted in D-029 routing.** Consumed by BC-5.01.001 v1.15 (investigate-event Invariant #7) and BC-4.02.001 v1.21 (update-jira PC#4). Paired mutant SM-47 (markdown-routed-into-verdict-emitter): routes investigation-markdown into verdict emitter — kills compliant-save-allowed and no-validate_enums vectors. **NOTE (P13-001): SM-P12-D ("revert P12-002 — remove disposition routing rule; issue comment marker for all dispositions") is SUPERSEDED by SM-51 (route-to-review, reconciled) — the correct behavior for TP/BTP/PARSE_FAIL routes to review. SM-52 (FP-comment-marker revert, P13-001) covers the FP path: "revert P13-001 — restore MARKDOWN_COMMENT_PATH: FP+autonomy_enabled=true issues autonomous comment marker" → kill target.** [ID-sync per FV]

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr error, no JSON output |
| EC-002 | File path `/tmp/readme.md` | Allow — not an investigation or verdict file |
| EC-003 | Investigation file with no Disposition section | Allow — in-progress; gate only fires once Disposition is declared. **HOOK-ISOLATED**: in aggregate, enrichment-completeness BC-3.02.001 co-fires and denies investigation files missing any of the four required sections. |
| EC-004 | Investigation file with "Disposition: True Positive" but no Alternatives Considered | Deny with reason mentioning "Alternatives Considered" |
| EC-005 | Investigation file with both "Disposition" and "Alternatives Considered" sections and all 12 mandatory headings (investigation-markdown path), non-hard-floor disposition, `autonomy_enabled` absent (common human-save case) | **P22-001 routing (disposition-routing-first):** GATE 1/2 floors pass (non-hard-floor); disposition routing: FP → `permissionDecision: allow`; **NO marker written** (allow-without-marker; no Jira action authorized; Write succeeds; `autonomy_enabled` irrelevant — FP always allow-without-marker regardless); non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review review marker, EXEMPT from kill switch per D-DEC-012 Option A regardless of `autonomy_enabled`). **NO autonomous `["comment"]` marker is ever issued from the markdown path (P13-001).** Note: `ticket_action_type` does NOT exist on the 12-field markdown path (verdict-only field, PC#1 path). `autonomy_enabled` absent is no longer a routing gate — it is irrelevant for both FP and non-FP paths (P22-001). |
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
| `investigation-ALERT-001.md` → all 12 mandatory headings present (investigation-markdown path), disposition=TP, tuning_signal=null, non-hard-floor, ticket_id=SEC-123 (present in markdown), config org_slug="ACME", **autonomy_enabled absent** (common human-save case) | **P22-001 routing (disposition-routing-first):** `permissionDecision: allow`; GATE 1/2 floors pass (non-hard-floor TP); parsed_disposition=TP ≠ "FP" → MARKDOWN_REVIEW_PATH; ticket_id charset-validated; MARKDOWN_COMMENT_REVIEW_PATH setup: `is_markdown_path=true`, `action="comment-review"`, `org_slug="ACME"` (from get_org_slug_from_config()), `markdown_parsed_disposition="TP"` (= parsed_disposition, P28-001), `recomputed_severity=null`, `link_target=null` (P28-001 explicit null); comment-review marker written (EXEMPT from kill switch per D-DEC-012 Option A). **Emitted marker fields (P28-001 verification):** `disposition.verdict="TP"` (from markdown_parsed_disposition), `org_slug="ACME"` (from config, NOT verdict.org_slug), `disposition.severity=null` (recomputed_severity=null, no STEP 1a), `disposition.asset_type=null` (is_markdown_path→null), `link_target_ticket_id=null` (link_target=null, action never "link"). NO autonomous `["comment"]` marker (P13-001 MARKDOWN_COMMENT_PATH ELIMINATED). Verdict emitter NOT entered; `validate_enums` NOT called; STEP 1a NOT called. **Previous (v1.26/P17-003):** "GATE 1 fires — `autonomy_enabled` absent → allow-without-marker for ALL dispositions" — this was the P22-001 defect; TP+autonomy_enabled_absent should route to MARKDOWN_REVIEW_PATH per D-DEC-012 Option A. **Previous (v1.10/v1.20):** "marker file written (comment-scoped, ticket-bound pattern)" — retired MARKDOWN_COMMENT_PATH behavior; eliminated at P13-001. | happy-path (P22-001 — TP + autonomy_enabled absent → MARKDOWN_REVIEW_PATH; D-DEC-012 Option A exempt from kill switch; P28-001 marker field verification) |
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
| `investigation-ALERT-001.md` → all 12 mandatory headings, **autonomy_enabled: true** in content, Disposition=FP, Sensor Health Status=healthy, no forbidden techniques, ticket_id=SEC-123 | Separate Human-Comment Marker Path (P13-001 / P22-001): GATE 1/2 floors pass (healthy + no forbidden techniques); disposition routing: parsed_disposition=FP → **allow-without-marker** (P13-001 + P22-001: FP always allow-without-marker regardless of `autonomy_enabled`; hook cannot evaluate scored_priority/asset_type from 12-field markdown; no Jira action authorized; Write succeeds); NO comment marker issued; verdict emitter NOT entered; validate_enums NOT called; STEP 1a NOT called. `autonomy_enabled` value is irrelevant — the outcome is identical whether `autonomy_enabled: true` or absent for FP (P22-001). **Previous (v1.20):** "parsed_disposition=FP → MARKDOWN_COMMENT_PATH; comment-scoped marker written." | **happy-path (P13-001/P22-001 — FP → allow-without-marker regardless of autonomy_enabled; MARKDOWN_COMMENT_PATH eliminated)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, **autonomy_enabled: true** in content, Disposition=TP, Sensor Health Status=healthy, no forbidden techniques, ticket_id=SEC-123 | Separate Human-Comment Marker Path (P12-002 / P22-001 / D-029): GATE 1/2 floor checks pass (healthy + no forbidden techniques; `hard_floor_triggered=false`); `autonomy_enabled` is NOT a routing gate (P22-001/D-029) — `autonomy_enabled: true` value is irrelevant to routing; disposition routing: parsed_disposition=TP ≠ "FP" → MARKDOWN_REVIEW_PATH; ticket_id charset-validated; comment-review marker written (NOT plain comment); `permissionDecision: allow`; verdict emitter NOT entered. [mechanism wording updated v1.35 — P22-001/D-029; autonomy_enabled not a routing gate] | **happy-path (P12-002 MARKDOWN_REVIEW_PATH — non-FP routes to review)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, Disposition=Indeterminate (autonomy_enabled absent) | **D-029 routing (save-always-succeeds):** GATE 1 fires (Indeterminate → `hard_floor_triggered=true`; audit annotation "MARKDOWN-HARD-FLOOR: Indeterminate disposition; routed to review (D-029)" written; NO deny); disposition routing: parsed_disposition=Indeterminate ≠ FP → MARKDOWN_REVIEW_PATH; ticket_id charset-validated; comment-review or create-review marker written; `permissionDecision: allow`; `autonomy_enabled` absent is irrelevant (not a routing gate in D-029 model). Verdict emitter NOT entered; `validate_enums` NOT called; STEP 1a NOT called. **Previous (v1.33 / pre-D-029 / P22-001 model):** "GATE 1 fires (Indeterminate → MARKDOWN-HARD-FLOOR); `permissionDecision: deny`" — pre-D-029 the hard floor was a deny; D-029 converts it to a routing signal. **Previous (v1.26 / pre-P22-001):** "Gate 1 fires — `autonomy_enabled` absent → allow-without-marker" — the P22-001 defect. | **edge-case (D-029 — Indeterminate + autonomy_enabled absent → GATE 1 routing annotation → MARKDOWN_REVIEW_PATH → allow + review marker; was: deny pre-D-029)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, **autonomy_enabled: true**, Disposition=Indeterminate, Sensor Health Status=healthy | Separate Human-Comment Marker Path (P11-004 / P22-001 / D-029): GATE 1 fires (Indeterminate → `hard_floor_triggered=true`; audit annotation "MARKDOWN-HARD-FLOOR: Indeterminate disposition; routed to review (D-029)" written; NO deny); disposition routing: Indeterminate ≠ FP → MARKDOWN_REVIEW_PATH; ticket_id charset-validated; comment-review or create-review marker written; `permissionDecision: allow`. (`autonomy_enabled: true` does not affect routing — GATE 1/2 sets hard_floor_triggered; D-029 routing determines marker regardless of autonomy_enabled.) **Previous (v1.33 / pre-D-029):** "`permissionDecision: deny`; deny reason 'MARKDOWN-HARD-FLOOR: Indeterminate disposition'" — D-029 eliminates the deny. | **edge-case (D-029 / P11-004 — Indeterminate; autonomy_enabled irrelevant; routing annotation → MARKDOWN_REVIEW_PATH → allow + review marker; was: deny pre-D-029)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, Disposition=TP, **attack_techniques contain T1003** (forbidden technique), Sensor Health Status=healthy, ticket_id=SEC-101 (present in markdown) | **D-029 new vector (P25-001 — analyst save with forbidden technique):** GATE 2 fires (T1003 → `hard_floor_triggered=true`; audit annotation "MARKDOWN-HARD-FLOOR: forbidden technique T1003; routed to review (D-029)" written; NO deny); disposition routing: TP ≠ FP → MARKDOWN_REVIEW_PATH; ticket_id charset-validated (SEC-101 valid); comment-review marker written (ticket-bound); `permissionDecision: allow`. SOC analyst documenting a T1003 credential-dumping finding is NEVER blocked from saving. | **edge-case (D-029 P25-001 — T1003 forbidden technique → GATE 2 routing annotation → MARKDOWN_REVIEW_PATH → allow + review marker)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, Disposition=**FP**, **attack_techniques contain T1068** (forbidden technique), Sensor Health Status=healthy, ticket_id=SEC-102 (present in markdown) | **D-029 new vector (P25-001 — FP + forbidden technique; hard floor wins):** GATE 2 fires (T1068 → `hard_floor_triggered=true`; audit annotation written; NO deny); disposition routing: parsed_disposition=FP BUT `hard_floor_triggered==true` → condition `FP AND hard_floor_triggered==false` is FALSE → falls through to MARKDOWN_REVIEW_PATH; ticket_id charset-validated (SEC-102 valid); comment-review marker written; `permissionDecision: allow`. Hard floor wins over FP disposition (D-029 routing model). **Pre-D-029:** FP would unconditionally allow-without-marker; `hard_floor_triggered` check did not exist. | **edge-case (D-029 P25-001 — FP + forbidden technique → hard floor wins → MARKDOWN_REVIEW_PATH → allow + review marker; NOT allow-without-marker)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings present, **Disposition heading value "probably TP"** (PARSE_FAIL — not in allowlist), Sensor Health Status=healthy, no forbidden techniques, ticket_id absent, **jira_project_key=SEC** in config | **D-029 new vector (P25-001 / P27-001 — PARSE_FAIL on VALUE → allow + create-review marker):** **P27-001: all 12 mandatory headings ARE PRESENT — this is a PARSE_FAIL on the Disposition heading VALUE ("probably TP" is ambiguous and not in allowlist), NOT a structural-deny (EC-010). D-029 routing applies (structurally complete).** Structural DENY (EC-010) fires for MISSING headings; VALUE PARSE_FAIL routes to review. GATE 1/2 floors pass (`hard_floor_triggered=false`); `parse_disposition_from_markdown` returns PARSE_FAIL (ambiguous value); PARSE_FAIL safe direction: `parsed_disposition != "FP"` → MARKDOWN_REVIEW_PATH; ticket_id absent → project_key lookup → project_key=SEC (charset-valid, regex-escaped); create-review marker written; `permissionDecision: allow`. An analyst saving a partially-complete investigation (ambiguous disposition text) is NEVER denied. | **edge-case (D-029 P25-001 / P27-001 — PARSE_FAIL on VALUE, NOT structural-deny; 12 headings all present; MARKDOWN_REVIEW_PATH → allow + create-review marker)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, Disposition=FP, Sensor Health Status=healthy, no forbidden techniques (`hard_floor_triggered=false`), no ticket_id, **jira_project_key=SEC** in config | **D-029 new vector (P25-001 — FP + clean → allow-without-marker):** GATE 1/2 floors pass (`hard_floor_triggered=false`); parsed_disposition=FP AND `hard_floor_triggered==false` → allow-without-marker; `permissionDecision: allow`; NO Jira action authorized. Canonical clean FP human save path. | **happy-path (D-029 P25-001 — FP + no hard floor → allow-without-marker; unchanged from pre-D-029 for this case)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, **autonomy_enabled: true**, Disposition="not a false positive" (non-allowlist text in Disposition heading), Sensor Health Status=healthy | Separate Human-Comment Marker Path (P13-003 / P22-001 / D-029): GATE 1/2 floor checks pass (healthy + no forbidden techniques; `hard_floor_triggered=false`); `autonomy_enabled` is NOT a routing gate (P22-001/D-029) — `autonomy_enabled: true` value is irrelevant to routing; `parse_disposition_from_markdown` returns PARSE_FAIL (ambiguous value — not in allowlist {TP,FP,BTP,Indeterminate} + canonical long forms); PARSE_FAIL safe direction → MARKDOWN_REVIEW_PATH (NOT allow-without-marker); ticket_id absent → project_key lookup → create-review marker if project_key present, HARD-FLOOR-UNBINDABLE deny if absent; verdict emitter NOT entered. [mechanism wording updated v1.35 — P22-001/D-029; autonomy_enabled not a routing gate] | **edge-case (P13-003 — PARSE_FAIL → review, not allow-without-marker; adversarial FP label cannot obtain allow-without-marker)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, Disposition=FP, Sensor Health Status=healthy, `autonomy_enabled: true` token appearing **inside a code fence or evidence block** (not in dedicated structured field), no dedicated Autonomy Enabled structured field | Separate Human-Comment Marker Path (P13-003 / P22-001): `parse_autonomy_enabled_from_markdown` reads ONLY dedicated structured field — embedded token in code fence/evidence block does NOT match; returns false. GATE 1/2 floors pass (healthy + no forbidden techniques); disposition routing: FP → **allow-without-marker** (P22-001: FP always allow-without-marker; P13-003 embedded-token guard irrelevant to routing outcome for FP); NO Jira action authorized; Write succeeds. Note: in P22-001, autonomy_enabled is not a routing gate at all for FP — this vector demonstrates that embedded tokens cannot influence the outcome (no change from pre-P22-001 for FP cases; but the reason is now "FP → allow-without-marker" not "Gate 1 closed"). | **edge-case (P13-003 adversarial masquerade — autonomy_enabled token in code fence; P22-001: FP → allow-without-marker regardless; embedded token does not affect outcome)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=Indeterminate, **sensor_health_status=silent** (BLIND-SPOT), scored_priority=HIGH, ticket_action_type=link, ticket_id=PRISMDEMO-42, link_target_ticket_id=PRISMDEMO-OLD, **autonomy_enabled=false** (or any value) | **P22-003/D-027/D-028 STEP 3b canonical vector (BLIND-SPOT hard-floor link):** `permissionDecision: allow`; STEP 1/1a pass (Indeterminate + silent → consistent); STEP 2 pass; STEP 3: Indeterminate + silent NOT a review-labeled token → falls through STEP 3; STEP 3b fires: action="link" AND hard_floor_applies()=TRUE (Indeterminate + silent sensor) → D-028 null-binding guards: ticket_id_step3b=PRISMDEMO-42 (non-null, passes), ticket_id_b_step3b=PRISMDEMO-OLD (non-null, passes); EMIT_LINK_MARKER true called (P24-001 positional $1; WRITE_MARKER invoked directly as final statement); STEP 4 and STEP 5 bypassed (autonomy_enabled=false irrelevant — STEP 3b fires before STEP 5); O7 charset + O7 site 10 resolved_project_key re-validation + org-binding checks run in EMIT_LINK_MARKER (P23-004/P24-002); is_link_hard_floor=true set globally; link-scoped marker written (authorized_operations=["link"], command_pattern `^jr (--output json )?issue link PRISMDEMO-42 PRISMDEMO-OLD( \|$)`, link_target_ticket_id="PRISMDEMO-OLD", ticket_id="PRISMDEMO-42"); WRITE_MARKER: is_review_path=true (D-028) — marker-write success → allow. **Pre-D-027 (v1.30):** STEP 4 fires → HARD-FLOOR-UNDER-LABEL deny (P22-003 CRITICAL gap). **Pre-D-028 (v1.31):** GOTO STEP6_LINK used (P23-004 ill-formed); no null-binding guards; no org-binding; is_review_path=false for link. **Pre-v1.33 (v1.32):** EMIT_LINK_MARKER(verdict, recomputed_severity, is_hard_floor_link=true) keyword-arg form (P24-001 self-contradictory — corrected). | **edge-case (P22-003/D-027/D-028 STEP 3b — BLIND-SPOT hard-floor link: STEP 3b fires; null-binding guards pass; EMIT_LINK_MARKER true (P24-001 positional); STEP 4+5 bypassed; ["link"] marker issued regardless of autonomy_enabled)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings, Disposition=TP, Sensor Health Status=healthy, no forbidden techniques, **autonomy_enabled absent** (P22-001 new routing vector) | **P22-001 canonical vector:** Separate Human-Comment Marker Path; GATE 1/2 floors pass (non-hard-floor TP); disposition routing: TP ≠ "FP" → MARKDOWN_REVIEW_PATH; ticket_id charset-validated (charset-valid from markdown); comment-review marker written; `permissionDecision: allow`; `autonomy_enabled` absent is NOT a routing gate (P22-001) — non-FP routes to MARKDOWN_REVIEW_PATH regardless. **Pre-P22-001 (v1.26/v1.30):** Old GATE 1 fired (autonomy_enabled absent) → allow-without-marker; TP investigation markdown with absent autonomy_enabled produced NO review marker. D-DEC-012 Option A (EXEMPT from kill switch) applies; review marker issued despite autonomy_enabled absent. | **edge-case (P22-001 MAJOR — non-FP investigation markdown + autonomy_enabled absent → MARKDOWN_REVIEW_PATH; NOT allow-without-marker; was: allow-without-marker pre-P22-001)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=TP, **ticket_id=".*"** (metacharacter injection), ticket_action_type=comment, severity=LOW, scored_priority=LOW, non-hard-floor, autonomy_enabled=true | `permissionDecision: deny`; audit.log: `TICKET-ID-CHARSET-DENY: comment path ticket_id='.*' failed charset validation (P12-001/O7)`; deny reason: "TICKET-ID-CHARSET-DENY: ticket_id='.*' rejected before command_pattern interpolation (P12-001/O7)"; NO marker written | **error (P12-001 — TICKET-ID-CHARSET-DENY)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, **jira_project_key="SEC\|.*"** (metacharacter injection), ticket_action_type=create, severity=LOW, scored_priority=LOW, non-hard-floor, autonomy_enabled=true | `permissionDecision: deny`; audit.log: `PROJECT-KEY-CHARSET-DENY: create path jira_project_key='SEC\|.*' failed charset validation (P12-001/O7)`; deny reason: "PROJECT-KEY-CHARSET-DENY: jira_project_key='SEC\|.*' rejected before command_pattern interpolation (P12-001/O7)"; NO marker written | **error (P12-001 — PROJECT-KEY-CHARSET-DENY)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, **ticket_id="SEC-42"**, **link_target_ticket_id="SEC-99"**, ticket_action_type=link, severity=LOW, scored_priority=LOW, asset_type=standard, autonomy_enabled=true, non-hard-floor; **config: resolved jira_project_key=SEC for the verdict's org_slug** (test setup configures resolved_project_key=SEC; SEC-42 and SEC-99 pass org-binding check) | `permissionDecision: allow`; STEP 5 passes (autonomy_enabled=true); STEP 6 ELIF link → EMIT_LINK_MARKER false (P24-001 positional); O7 KEY1 charset passes (SEC-42 valid); KEY2 charset passes (SEC-99 valid); org-binding: resolved_project_key=SEC; P24-002/O7 site 10 charset re-validation passes (SEC matches ^[A-Z][A-Z0-9]+$); KEY1 matches `^SEC-[0-9]+$` (SEC-42 ✓); KEY2 matches `^SEC-[0-9]+$` (SEC-99 ✓); link-scoped marker written (authorized_operations=["link"], command_pattern `^jr (--output json )?issue link SEC-42 SEC-99( \|$)`, link_target_ticket_id="SEC-99", ticket_id="SEC-42"); both KEY1/KEY2 charset-validated + regex-escaped (P18-001/O7 sites 3+8) | **happy-path (D-020 link scope — P18-001/D-028 org-binding; P24-003 org-binding precondition added)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, **link_target_ticket_id=".*"** (metacharacter injection in KEY2), ticket_id="SEC-42", ticket_action_type=link, severity=LOW, scored_priority=LOW, autonomy_enabled=true | `permissionDecision: deny`; audit.log: `LINK-TARGET-CHARSET-DENY: link path link_target_ticket_id='.*' failed charset validation (P18-001/O7 site 8)`; deny reason: "LINK-TARGET-CHARSET-DENY: link_target_ticket_id='.*' rejected before command_pattern interpolation (P18-001/O7 site 8)"; NO marker written | **error (P18-001 — LINK-TARGET-CHARSET-DENY)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, ticket_action_type=close, **ticket_id="SEC-42"**, severity=LOW, scored_priority=LOW, asset_type=standard, autonomy_enabled=true, non-hard-floor | `permissionDecision: allow`; STEP 4b close-disposition check: action=close AND FP∈{FP,BTP} → STEP 4b condition false → passes (not fired, D-025/P20-001); STEP 5 kill switch passes (autonomy_enabled=true); STEP 6 close branch: D-023 defense-in-depth disposition check passes (FP ∈ {FP,BTP}); ticket_id charset-valid; emit-time close_state="Done" ∈ CLOSE_STATE_ALLOWLIST; close-scoped marker written (authorized_operations=["close"], command_pattern `^jr (--output json )?issue move SEC-42 Done( \|$)`, link_target_ticket_id=null, ticket_id="SEC-42") | **happy-path (D-021/D-023 close scope — FP non-hard-floor, autonomy=true; STEP 4b passes)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, ticket_action_type=close, ticket_id="SEC-42", severity=HIGH, **scored_priority=HIGH**, asset_type=standard, autonomy_enabled=true | `permissionDecision: deny`; STEP 4 DENY-THE-WRITE fires (scored_priority=HIGH → hard_floor_applies()=true; close is not a review token → HARD-FLOOR-UNDER-LABEL; required_token="comment-review"); `UNDER-LABEL-DENIED` audit entry written; NO marker; loop MUST re-issue verdict Write with ticket_action_type=comment-review. **HIGH/CRIT verdict NEVER auto-closed (D-021 security gating).** | **edge-case (D-021 CLOSE security gating — STEP 4 denies HIGH/CRIT close)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, ticket_action_type=close, ticket_id="SEC-42", severity=LOW, scored_priority=LOW, asset_type=standard, **autonomy_enabled=false** | `permissionDecision: allow` (allow-without-marker); STEP 4b close-disposition check: FP∈{FP,BTP} → STEP 4b condition false → passes (not fired, D-025/P20-001); STEP 5 kill switch fires — autonomy_enabled=false; no marker written; Stage-8 `jr issue move` will be denied by require-review (no marker to consume) | **edge-case (D-021 CLOSE kill switch — FP: STEP 4b passes; autonomy=false → allow-without-marker at STEP 5)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, **disposition=TP**, ticket_action_type=close, ticket_id="SEC-42", severity=LOW, scored_priority=LOW, asset_type=standard, autonomy_enabled=true, non-hard-floor | `permissionDecision: deny`; STEP 4b close-disposition gate fires (D-025/P20-001) — TP ∉ {FP,BTP}; audit entry: `CLOSE-DISPOSITION-DENY: close authorized only for FP/BTP disposition, got 'TP'; verdict Write denied by disposition-guard (D-025/D-023/P20-001)`; emit deny with corrective reason (re-issue with non-close ticket_action_type appropriate for TP); STEP 5 kill switch NOT reached (STEP 4b returned first); STEP 6 unreachable (defense-in-depth only); **NO close marker written** (TP verdict MUST NOT be auto-closed — D-023/D-025) | **edge-case (D-025/D-023 CLOSE-DISPOSITION-DENY at STEP 4b — TP+autonomy=true denied before kill switch)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, **disposition=TP**, ticket_action_type=close, ticket_id="SEC-42", severity=LOW, scored_priority=LOW, asset_type=standard, **autonomy_enabled=false**, non-hard-floor | `permissionDecision: deny`; **SM-69 kill vector (D-025/P20-001 regression case):** STEP 4b close-disposition gate fires (D-025/P20-001) — TP ∉ {FP,BTP} regardless of autonomy_enabled value; audit entry: `CLOSE-DISPOSITION-DENY: close authorized only for FP/BTP disposition, got 'TP'; verdict Write denied by disposition-guard (D-025/D-023/P20-001)`; emit deny with corrective reason; STEP 5 kill switch NOT reached (STEP 4b returned first); **NO close marker written**. Pre-v1.29 emitter defect: TP+close+autonomy_enabled=false would have exited at STEP 5 allow-without-marker (no D-023 gate reached from that path), silently allowing the close. D-025 STEP 4b hoist (P20-001) prevents this regression for ALL autonomy_enabled values. | **edge-case (SM-69 kill vector — D-025 STEP 4b: TP+close+autonomy_enabled=false → CLOSE-DISPOSITION-DENY; STEP 5 unreachable)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, **disposition=Indeterminate**, ticket_action_type=close, ticket_id="SEC-42", severity=LOW, scored_priority=MED, autonomy_enabled=true | `permissionDecision: deny`; STEP 4 DENY-THE-WRITE fires (Indeterminate → hard_floor_applies()=true; "close" is not a review token → HARD-FLOOR-UNDER-LABEL; required_token="create-review" since ticket_id present; `UNDER-LABEL-DENIED` audit entry written; NO marker); **D-023 disposition gate is NOT reached** — STEP 4 fires before STEP 6 close branch; loop MUST re-issue with ticket_action_type=comment-review | **edge-case (Indeterminate+close → STEP 4 UNDER-LABEL-DENIED fires before D-023 close branch)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, ticket_action_type=close, ticket_id="SEC-42", severity=LOW, scored_priority=LOW, autonomy_enabled=true, **jira_close_state config set to "Archived"** (not in CLOSE_STATE_ALLOWLIST) | `permissionDecision: deny`; STEP 4b close-disposition check: FP∈{FP,BTP} → STEP 4b condition false → passes (not fired, D-025/P20-001); STEP 5 kill switch passes (autonomy_enabled=true); STEP 6 close branch: D-023 defense-in-depth disposition check passes (FP ∈ {FP,BTP}); ticket_id charset-valid; emit-time close_state="Archived" ∉ CLOSE_STATE_ALLOWLIST → CLOSE-STATE-DENY; audit entry: `CLOSE-STATE-DENY: jira_close_state 'Archived' not in CLOSE_STATE_ALLOWLIST; verdict Write denied by disposition-guard (P19-003/D-023)`; emit deny with corrective message (reconfigure jira_close_state to {Done,Closed,Resolved}); **NO close marker written** (P19-003/D-023) | **edge-case (P19-003 CLOSE-STATE-DENY — non-allowlisted jira_close_state; STEP 4b passes for FP)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=Indeterminate, **sensor_health_status=silent**, scored_priority=HIGH, ticket_action_type=link, ticket_id=PRISMDEMO-42, link_target_ticket_id=PRISMDEMO-OLD, autonomy_enabled=false; **WRITE_MARKER injected to fail** | **D-028/P23-001 hard-floor link marker-write-failure vector:** STEP 3b fires; null-binding guards pass (both keys non-null); EMIT_LINK_MARKER true called (P24-001 positional; WRITE_MARKER invoked directly as final statement); O7 charset + O7 site 10 resolved_project_key re-validation + org-binding pass; is_link_hard_floor=true (set globally by EMIT_LINK_MARKER, P24-001); WRITE_MARKER: is_review_path = (action=="link" AND is_link_hard_floor=true) → TRUE; write_ok=false (injected failure); IS review_path branch fires; `permissionDecision: deny`; audit entry: `MARKER-WRITE-FAILED: failed to write review marker for action=link marker_id=<uuid> ... verdict=Indeterminate/HIGH (P10-003/D-028)`; deny reason: "MARKER-WRITE-FAILED: disposition-guard could not write review marker for action='link'. Review-path marker write failures are fail-closed (P10-003/D-028)." **Contrast with REGULAR link + injected failure (see vector below) which produces allow-without-marker — P10-003 asymmetry preserved.** | **edge-case (D-028/P23-001 MARKER-WRITE-FAILED on hard-floor link path — fail-closed; NOT allow-without-marker)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=Indeterminate, **sensor_health_status=silent**, scored_priority=HIGH, ticket_action_type=link, ticket_id=PRISMDEMO-42, **link_target_ticket_id=null** | **D-028/P23-001 HARD-FLOOR-UNBINDABLE null KEY2 vector:** STEP 3b fires (action=link AND hard_floor_applies()=TRUE); ticket_id_step3b=PRISMDEMO-42 (non-null, first guard passes); ticket_id_b_step3b=null → HARD-FLOOR-UNBINDABLE deny fires; `permissionDecision: deny`; audit entry: `HARD-FLOOR-UNBINDABLE: hard-floor link verdict with null link_target_ticket_id (KEY2); missing_field=link_target_ticket_id; corrective_action=populate verdict.link_target_ticket_id with the target Jira ticket key; hard_floor_trigger=sensor_health_status=silent; verdict Write denied by disposition-guard (D-028/P23-001/D-DEC-012 clause 2)`; deny reason: "HARD-FLOOR-UNBINDABLE: cannot bind hard-floor link marker without link_target_ticket_id (KEY2). hard_floor_trigger=sensor_health_status=silent. missing_field=link_target_ticket_id. Re-issue this Write with link_target_ticket_id populated in the verdict." EMIT_LINK_MARKER is NOT called (D-028 guard fires first). Mirrors P8-001 comment-review + null ticket_id pattern. | **edge-case (D-028/P23-001 HARD-FLOOR-UNBINDABLE null KEY2 on hard-floor link path — deny; mirrors P8-001)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, scored_priority=LOW, asset_type=standard, ticket_action_type=link, ticket_id=PRISMDEMO-42, **link_target_ticket_id=OTHERPROJ-99**, autonomy_enabled=true; config: resolved jira_project_key=PRISMDEMO for org | **D-028/P23-005 LINK-PROJECT-BINDING-DENY cross-project KEY2 vector:** REGULAR path (hard_floor_applies()=FALSE, autonomy_enabled=true); STEP 6 ELIF link → EMIT_LINK_MARKER false (P24-001 positional); O7 KEY1 charset passes (PRISMDEMO-42 valid); KEY2 charset passes (OTHERPROJ-99 valid form); org-binding: resolved_project_key=PRISMDEMO; P24-002/O7 site 10 charset re-validation passes (PRISMDEMO matches ^[A-Z][A-Z0-9]+$); verdict.link_target_ticket_id=OTHERPROJ-99 does NOT match `^PRISMDEMO-[0-9]+$` → LINK-PROJECT-BINDING-DENY; `permissionDecision: deny`; audit entry: `LINK-PROJECT-BINDING-DENY: link_target_ticket_id (KEY2) 'OTHERPROJ-99' does not belong to project PRISMDEMO; verdict Write denied by disposition-guard (D-028/P23-005)`; deny reason: "LINK-PROJECT-BINDING-DENY: link_target_ticket_id (KEY2) must belong to project PRISMDEMO. Got link_target_ticket_id='OTHERPROJ-99'. Re-issue with a ticket key matching ^PRISMDEMO-[0-9]+$." Org-binding fires on BOTH hard-floor and REGULAR paths (D-028/P23-005). | **edge-case (D-028/P23-005 LINK-PROJECT-BINDING-DENY — KEY2 wrong project; org-binding on REGULAR path)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, scored_priority=LOW, asset_type=standard, ticket_action_type=link, ticket_id=PRISMDEMO-42, link_target_ticket_id=PRISMDEMO-50, autonomy_enabled=true; non-hard-floor (hard_floor_applies()=FALSE); **WRITE_MARKER injected to fail** | **P10-003 asymmetry preserved on REGULAR link path (D-028 non-regression vector):** STEP 6 ELIF link → EMIT_LINK_MARKER false (P24-001 positional); O7 charset + O7 site 10 resolved_project_key re-validation + org-binding pass; is_link_hard_floor=false (set globally by EMIT_LINK_MARKER, P24-001); WRITE_MARKER: is_review_path = (action=="link" AND is_link_hard_floor=false) → FALSE; write_ok=false (injected failure); ELSE branch fires → **emit allow without marker** (allow-without-marker retained for REGULAR non-review path, P10-003 asymmetry unchanged); `permissionDecision: allow` (no marker written); NO MARKER-WRITE-FAILED audit entry. **D-028 does NOT change REGULAR link path semantics — only hard-floor link path (is_link_hard_floor=true) is fail-closed.** Contrast with hard-floor link + injected failure (see vector above) which produces DENY. | **edge-case (P10-003 asymmetry — REGULAR link + marker-write failure → allow-without-marker; D-028 non-regression: REGULAR path unchanged)** |
| `investigation-ALERT-001.md` → 11 of 12 mandatory headings present (all EXCEPT **`## Timeline Events`** heading missing), "Alternatives Considered" present, "Disposition: TP" present | **P27-001 structural DENY (pre-D-029-routing gate — EC-010):** 12-field completeness check fires (heading-anchored grep for `timeline_events` heading returns no match); the hook emits `permissionDecision: deny` with reason identifying the missing field (EC-010: "ICD-203 required field missing: timeline_events"). **P27-001: this is a STRUCTURAL DENY — NOT a D-029-covered routing case.** D-029's save-always-succeeds guarantee applies ONLY to structurally complete investigations; structural completeness gates are pre-D-029-routing and are NOT disposition-based denies. NO marker written. **Contrast:** if the Timeline Events heading WERE present but the Disposition value were "probably TP" (ambiguous), that would be PARSE_FAIL on VALUE → allow + MARKDOWN_REVIEW_PATH (see P27-001/P25-001 vector above). | **edge-case (P27-001 structural DENY — missing Timeline Events heading → EC-010 deny; pre-D-029-routing gate; NOT a PARSE_FAIL routing case)** |
| `investigation-ALERT-001.md` → all 12 mandatory headings present, Disposition=TP (non-FP), Sensor Health Status=healthy, no forbidden techniques (`hard_floor_triggered=false`), ticket_id=SEC-123 (present in markdown, charset-valid); **WRITE_MARKER injected to fail** | **P27-002 markdown review path MARKER-WRITE-FAILED deny (infrastructure-failure deny, P10-003):** Structural completeness check passes (12 headings); GATE 1/2 floors pass (`hard_floor_triggered=false`); disposition routing: TP ≠ FP → MARKDOWN_REVIEW_PATH; ticket_id charset-validated (SEC-123 valid); ops=["comment-review"]; `is_markdown_path=true` set in MARKDOWN_COMMENT_REVIEW_PATH variable setup block (P27-002); WRITE_MARKER: `is_review_path=true` (action="comment-review"); `write_ok=false` (injected failure); IS review_path branch fires: `permissionDecision: deny`; audit entry: `MARKER-WRITE-FAILED: failed to write review marker for action=comment-review marker_id=<uuid> ... verdict=TP/null (P10-003/D-028/P27-002)`; deny reason: "MARKER-WRITE-FAILED: disposition-guard could not write review marker for action='comment-review'. Review-path marker write failures are fail-closed (P10-003/D-028). Investigate marker-store write permissions." **P27-002: this is an INFRASTRUCTURE-FAILURE deny — DISTINCT from D-029's content/disposition guarantee. D-029 guarantees no disposition-/hard-floor-based deny; infrastructure failures that would silently drop review escalations are fail-closed regardless.** NOT allow-without-marker. | **edge-case (P27-002 MARKER-WRITE-FAILED on markdown review path — infrastructure-failure fail-closed; NOT allow-without-marker; DISTINCT from D-029 content guarantee)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=FP, scored_priority=LOW, asset_type=standard, ticket_action_type=link, ticket_id=PRISMDEMO-42, link_target_ticket_id=PRISMDEMO-50, autonomy_enabled=true; non-hard-floor (hard_floor_applies()=FALSE); **config: resolved jira_project_key="SEC\|.*"** (contains pipe; fails charset) | **P24-002 O7 site 10 — malformed resolved_project_key → LINK-PROJECT-KEY-CHARSET-DENY:** STEP 6 ELIF link → EMIT_LINK_MARKER false called (P24-001 positional); inside EMIT_LINK_MARKER: O7 sites 1-5 ticket_id charset passes; O7 sites 6-7 jira_project_key charset passes; O7 site 8 link_target_ticket_id charset passes; `read_org_project_key()` returns "SEC\|.*" (non-null, null check passes); **O7 site 10 emit-time charset re-validation:** "SEC\|.*" does NOT match `^[A-Z][A-Z0-9]+$` (pipe character fails) → `LINK-PROJECT-KEY-CHARSET-DENY`; `permissionDecision: deny`; audit entry: `LINK-PROJECT-KEY-CHARSET-DENY: resolved_project_key 'SEC\|.*' fails charset validation ^[A-Z][A-Z0-9]+$; verdict Write denied by disposition-guard (P24-002/D-028/O7-site10)`; deny reason: "LINK-PROJECT-KEY-CHARSET-DENY: org config resolved_project_key 'SEC\|.*' contains characters outside [A-Z0-9]. Re-configure jira_project_key to a valid Jira project key (uppercase letters and digits only)."; **regex construction is NOT reached** — fail-closed before building org-binding pattern; WRITE_MARKER NOT called. This vector is NOT broadened-match suppression — it is config-side misconfiguration (jira_project_key contains regex metachar). Mirrors close_state three-layer treatment (P19-003). | **edge-case (P24-002 O7 site 10 — malformed resolved_project_key in config → LINK-PROJECT-KEY-CHARSET-DENY; fail-closed before regex construction; config misconfiguration path)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=Indeterminate, severity=LOW, scored_priority=CRIT, asset_type=domain_controller, **ticket_action_type=create-review**, jira_project_key=SEC, ticket_id=null (create-review; no open ticket yet), autonomy_enabled=false | **P29-001 STEP-3-GOTO path — create-review → WRITE_MARKER → link_target_ticket_id=null (JSON null):** STEP 1/1a pass; STEP 3 fires: action="create-review"; hard_floor_applies()=true (Indeterminate + domain_controller asset); STEP 3 create-review branch: project_key=SEC (charset-valid, regex-escaped); pattern constructed; ops=["create-review"]; ticket_id=null; `link_target = null` (P29-001 belt-and-suspenders explicit null, Path A1); `GOTO WRITE_MARKER`; **WRITE_MARKER: `link_target = defined(link_target) ? link_target : null` backstop — link_target was explicitly null (P29-001) → defined()=true → guard preserves null**; marker written with `link_target_ticket_id: null` (JSON null, NOT empty string `""`, NOT unbound); `permissionDecision: allow`. STEP 6 was NEVER executed — this path jumps from STEP 3 to WRITE_MARKER, bypassing STEP 6's `link_target = null` initialization. P29-001 confirms the defined()-guard closes this gap. Mirror: same vector with `ticket_action_type=comment-review` and `ticket_id=SEC-123` (see next vector). | **edge-case (P29-001 — STEP-3-GOTO create-review path: link_target_ticket_id = null in emitted marker; NOT empty-string; NOT unbound; defined()-guard backstop + belt-and-suspenders null at STEP-3 GOTO)** |
| `verdict-ALERT-001.json` → JSON with all 18 keys, disposition=TP, severity=HIGH, scored_priority=HIGH, asset_type=ot_safety_system, **ticket_action_type=comment-review**, ticket_id=SEC-456, autonomy_enabled=false | **P29-001 STEP-3-GOTO path — comment-review → WRITE_MARKER → link_target_ticket_id=null (JSON null):** STEP 1/1a pass; STEP 3 fires: action="comment-review"; hard_floor_applies()=true (scored_priority=HIGH + ot_safety_system asset); STEP 3 comment-review branch: ticket_id=SEC-456 (charset-valid, regex-escaped); pattern constructed; ops=["comment-review"]; `link_target = null` (P29-001 belt-and-suspenders explicit null, Path A1); `GOTO WRITE_MARKER`; **WRITE_MARKER: `link_target = defined(link_target) ? link_target : null` backstop — link_target was explicitly null (P29-001) → defined()=true → guard preserves null**; marker written with `link_target_ticket_id: null` (JSON null, NOT empty string, NOT unbound); `permissionDecision: allow`. Verifies the P29-001 fix on the comment-review STEP-3 GOTO path — link_target_ticket_id is null on all non-link action scopes. | **edge-case (P29-001 — STEP-3-GOTO comment-review path: link_target_ticket_id = null in emitted marker; NOT empty-string; NOT unbound; mirrors create-review vector above)** |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-007 | Investigation file with Disposition but no Alternatives always produces deny | integration / BATS |
| VP-HOOK-008 | Investigation file without Disposition always produces allow (in-progress gate) | integration / BATS |
| VP-HOOK-009 | Non-investigation, non-verdict files always produce allow | integration / BATS |
| VP-HOOK-026 | **[NEW v1.11; SM-46 extended v1.19 P11-002]** Hard-floor non-overridability (FINALIZED per verification-delta.md v1.3 §7 Part D): all hard-floor conditions unconditionally suppress marker issuance, including the separate `asset_type=unknown` leg (NOT a member of CRITICAL_ASSET_TYPES — explicit check). Tests: LOW-severity + benign-technique + asset_type=unknown verdict → zero markers written (SM-29 kill target); HIGH/CRIT `scored_priority` → zero markers (**SM-46 kill target**: high-severity-floor-rekeyed-to-recomputed-severity — re-keying floor to `recomputed_severity` silently loses the LOW-detector/CRIT-scored escalation path); Indeterminate disposition → zero markers; CRITICAL_ASSET_TYPES → zero markers; degraded/silent sensor health → zero markers. | integration / BATS (`@test "disposition-guard unknown-asset hard-floor: no marker emitted"`, `@test "disposition-guard critical-severity hard-floor: no marker emitted"`, `@test "disposition-guard indeterminate hard-floor: no marker emitted"`, `@test "disposition-guard scored_priority=CRIT severity=LOW: hard floor fires (SM-46 kill)"`) |
| VP-HOOK-025 | **[UPDATED v1.19 — P10-001/P11-002]** Artifact-class branching enforcement (architecture-delta v1.4 §D-DEC-008-C — ADV-F2-P3-003). **Investigation markdown path (12 ICD-203 fields):** heading-anchored `grep -qiE "^#{1,6}[[:space:]]+<field>"` for each of: (1) disposition, (2) confidence, (3) sensor_health_status, (4) evidence_artifacts, (5) timeline_events, (6) hypotheses_considered, (7) alternatives_rejected, (8) uncertainty_explicit, (9) attack_techniques, (10) agent_actions, (11) human_actions, (12) tuning_signal. Severity, asset_type, ticket_action_type are NOT required headings in the investigation-markdown path. **Verdict JSON path (18 fields — P10-001/P11-002):** `jq has()` key-presence check + per-field type assertions for all 18 fields (fields 1–12 above plus (13) severity, (14) asset_type, (15) ticket_action_type, (16) native_severity, (17) sensor_family, (18) scored_priority). Verdict JSON files missing any of the 18 keys receive deny. tuning_signal null-vs-absent semantics enforced (null valid for TP/Indeterminate; non-null object required for FP/BTP). scored_priority membership in {CRIT,HIGH,MED,LOW} enforced (fail-closed; P11-002). Hard-floor check re-keyed to `verdict.scored_priority` (field 18 — P11-002; Stage-5 assess-priority output) + verdict.asset_type (field 14) including separate `unknown` check (ADV-F2-P3-001). SM-44 (revert STEP 1a re-normalization — SEVERITY-MISMATCH context). Cross-ref: VP-HOOK-030 (STEP 1a SEVERITY-MISMATCH, FINALIZED (consistency VP) per verification-delta v1.14 downgrade — was P0 at v1.13; P11-001). [ID-sync per FV]. | integration / BATS (`@test "disposition-guard denies verdict missing timeline_events"`, `@test "disposition-guard denies verdict missing severity"`, `@test "disposition-guard denies verdict missing native_severity"`, `@test "disposition-guard denies verdict missing sensor_family"`, `@test "disposition-guard denies verdict missing scored_priority"`, `@test "disposition-guard denies verdict scored_priority not in enum"`, `@test "disposition-guard denies FP verdict with null tuning_signal"`, `@test "disposition-guard allows TP verdict with null tuning_signal and all 18 fields"`, `@test "disposition-guard allows investigation with 12 fields (severity/asset_type/ticket_action_type headings not required)"`) |
| VP-HOOK-031 | **[NEW v1.19 — P11-004; scope update v1.20 — P12-002 SM-50/SM-51; SCOPE UPDATE COMPLETE v1.21 — P13-001 MARKDOWN_COMMENT_PATH ELIMINATED / SM-52 (FP-comment-marker revert); P22-001 SCOPE UPDATE — disposition-routing-first; D-029 SCOPE UPDATE — save-always-succeeds, hard-floor-routing-signal; P27-001/P27-002/P27-003 SCOPE UPDATE — structural-deny-vs-disposition-parse-distinction, path-aware-WRITE_MARKER-MARKER-WRITE-FAILED, parse_autonomy_enabled_from_markdown-defense-in-depth-only; SM-77 resolved]** Separate human-comment marker path correctness (P11-004 / P12-002 / P13-001 / P22-001 / D-029): the 12-field ICD-203 investigation-markdown path (PC#2 dispatch) does NOT enter the verdict emitter; `validate_enums()` and STEP 1a are NOT called on this path. **D-029 route rule (save-always-succeeds — no deny on this path):** (1) FP + no hard floor path: FP disposition + `hard_floor_triggered=false` → **allow-without-marker** (MARKDOWN_COMMENT_PATH ELIMINATED per P13-001; Write succeeds; NO Jira action authorized); (2) non-FP route-to-review path (P22-001 / D-029): TP/BTP/PARSE_FAIL (any `autonomy_enabled` value) → MARKDOWN_REVIEW_PATH (comment-review or create-review marker); (3) MARKDOWN-HARD-FLOOR path (D-029): Indeterminate disposition / T1003\|T1068\|T1021\|T1041 technique / degraded\|silent sensor → `hard_floor_triggered=true` + MARKDOWN-HARD-FLOOR audit annotation; Write ALWAYS succeeds (no deny); disposition routing: non-FP → MARKDOWN_REVIEW_PATH; FP + hard floor → MARKDOWN_REVIEW_PATH (hard floor wins over FP disposition); (4) HARD-FLOOR-UNBINDABLE (D-029): allow-without-marker + audit annotation (Write permitted, marker not issued; contrast: verdict-path HARD-FLOOR-UNBINDABLE is still deny per D-DEC-012 clause 2); (5) path isolation: 12-field markdown does NOT trigger validate_enums or STEP 1a; (6) ticket_id charset-validation (P12-001/O7): ticket_id=".*" → TICKET-ID-CHARSET-DENY; (7) adversarial parse vectors (P13-003): "Disposition: not a false positive" → PARSE_FAIL → MARKDOWN_REVIEW_PATH (NOT allow-without-marker); `autonomy_enabled: true` embedded in code fence → parse returns false (embedded token not in dedicated structured field; `autonomy_enabled` is not a routing gate in D-029 model). SM-52 (FP-comment-marker revert, P13-001): "revert P13-001 — restore MARKDOWN_COMMENT_PATH: FP+autonomy_enabled=true issues autonomous comment marker" → kill target for vectors (1) and (7). SM-73 kill target ("markdown-gate1-kill-switch-restored", introduced P22-001): restoring autonomy_enabled Gate 1 causes non-FP+autonomy_enabled_absent → allow-without-marker instead of MARKDOWN_REVIEW_PATH (incorrect — D-029 routing ignores autonomy_enabled). SM-51 kill target: route TP to comment-scoped marker (vector 2 routes to review). D-029 deny-restoration kill target (SM-77): restoring MARKDOWN-HARD-FLOOR deny violates save-always-succeeds — vectors (3) and (4) produce allow, not deny. **P27-003: `autonomy_enabled: true` embedded in code fence → parse_autonomy_enabled_from_markdown returns false — retained for defense-in-depth / P13-003 adversarial-masquerade detection only; NOT consulted in D-029 routing.** Consumed by BC-5.01.001 v1.15 Invariant #7 (investigate-event Stage 7) and BC-4.02.001 v1.21 PC#4 (update-jira Stage 7). Paired mutant SM-47 (markdown-routed-into-verdict-emitter): routes investigation-markdown into verdict emitter — kills compliant-save-allowed and no-validate_enums vectors. | integration / BATS (`@test "disposition-guard investigation markdown FP no-hard-floor: allow-without-marker (D-029 P13-001)"`, `@test "disposition-guard investigation markdown FP + forbidden technique: MARKDOWN_REVIEW_PATH allow + review marker (D-029 hard floor wins)"`, `@test "disposition-guard investigation markdown TP any autonomy_enabled: MARKDOWN_REVIEW_PATH"`, `@test "disposition-guard investigation markdown autonomy_enabled absent non-FP: MARKDOWN_REVIEW_PATH not allow-without-marker (D-029)"`, `@test "disposition-guard investigation markdown Indeterminate: routing annotation + MARKDOWN_REVIEW_PATH allow (D-029; was deny pre-D-029)"`, `@test "disposition-guard investigation markdown PARSE_FAIL: MARKDOWN_REVIEW_PATH not allow-without-marker (P13-003)"`, `@test "disposition-guard investigation markdown does not enter verdict emitter path (SM-47 kill)"`, `@test "disposition-guard investigation markdown ticket_id metachar: TICKET-ID-CHARSET-DENY"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-03 |
| L2 Domain Invariants | Anti-confirmation-bias invariant: NO INVESTIGATION DISPOSITION SAVED WITHOUT ALTERNATIVES CONSIDERED FIRST — enforces that analysts document alternative hypotheses before committing a TP/FP/BTP disposition (prevents anchoring on the first interpretation) |
| Architecture Module | C-14 (disposition-guard-hook), C-29 (marker-store emitter) |
| VP Anchors | VP-HOOK-030 (STEP 1a SEVERITY-MISMATCH consistency check, co-owned with BC-10.01.001); VP-HOOK-031 (investigation-markdown separate human-comment/review-marker path); VP-HOOK-032 (command_pattern charset-validation, O7) |
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

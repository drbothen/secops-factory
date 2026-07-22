---
document_type: behavioral-contract
level: L3
version: "1.17"
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
modified: ["v1.1-ADV-0-403-2026-07-19", "v1.2-ADV-0-501-ADV-0-507-2026-07-19", "v1.3-ADV-0-605-ADV-0-606-2026-07-19", "v1.4-ADV-0-B01-2026-07-19", "v1.5-RESYNC-PR17-2026-07-19", "v1.6-D-DEC-001-ICD-203-2026-07-20", "v1.7-FV-VP-HOOK-025-FINALIZED-2026-07-20", "v1.8-ADV-F2-001-003-004-016-2026-07-20", "v1.9-ADV-F2-P2-001-emitter-ordering-2026-07-20", "v1.10-ADV-F2-P3-001-002-003-011-2026-07-20", "v1.11-FV-VP-026-025-ANCHORS-2026-07-20", "v1.12-P4-001-P4-002-P4-005-P4-006-D-DEC-012-2026-07-21", "v1.13-FV-VP-028-025-026-029-ANCHORS-2026-07-21", "v1.14-ADV-F2-P5-001-P5-002-P5-003-2026-07-21", "v1.15-ADV-F2-P6-001-P6-002-2026-07-21", "v1.16-ADV-F2-P7-001-2026-07-21 [SM-ID-sync per FV]", "v1.17-ADV-F2-P8-001-OBS-2-2026-07-21"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.03.001: disposition-guard Hook — Alternatives-Required Gate and ICD-203 Validator / Marker Emitter

> **Revision history:**
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

   - **Check 1 — JSON-content or .json-extension (verdict-class, THIS postcondition):** If `tool_input.file_path` ends in `.json` OR `tool_input.content` parses as valid JSON (`jq empty 2>/dev/null` succeeds) → route to **VERDICT JSON path** (body of this postcondition — 15-field jq key-presence + type check). This check takes absolute precedence regardless of any `investigation` substring in the path. Rationale: the canonical verdict file path `artifacts/investigations/verdict-<alert_id>-<iso_ts>.json` contains BOTH the `investigation` directory component AND the `verdict` filename component. Under the prior substring dispatch, the `investigation` check matched first and routed a JSON file to the markdown branch, which then failed heading-grep assertions on JSON content → DENY → no marker → autonomous pipeline permanently unreachable (ADV-F2-P4-001 CRITICAL). JSON-first dispatch resolves the collision.
   - **Check 2 — investigation-*.md glob (investigation-class, PC#2):** Elif `tool_input.file_path` matches `*investigation-*.md` (must end in `.md`) → route to INVESTIGATION MARKDOWN path (PC#2 below — 12-field heading-anchored grep). The `.md` extension guard is mandatory: it prevents `.json` files with `investigation` in the path from misrouting to the markdown branch.
   - **Check 3 — fast-path allow (PC#3):** Else → `emit allow` without any ICD-203 enforcement.

   > **Previous (v1.11) dispatch order:** (1) if `file_path` does not contain `investigation` AND does not contain `verdict` → emit allow (fast path); (2) elif `file_path` contains `investigation` (substring, no extension guard) → investigation-markdown path; (3) elif `file_path` contains `verdict` (substring) → verdict-JSON path. This substring-only dispatch caused a routing collision: `artifacts/investigations/verdict-<id>.json` matched both the `investigation` (directory component) and `verdict` (file component) substring checks, with the investigation check winning in evaluation order — a JSON file was routed to the markdown 12-field branch.

   **Verification property (VP-HOOK-028 — FINALIZED, JSON-first dispatch surface, v1.13):** PC#1 Check-1 is the JSON-first canonical-path dispatch enforcement surface: a file whose content parses as JSON OR whose path ends `.json` is unconditionally routed to the verdict-class 15-field path, regardless of any `investigation` directory substring in the path. This closes the routing collision where `artifacts/investigations/verdict-*.json` was misrouted to the markdown 12-field branch (ADV-F2-P4-001 CRITICAL). VP-HOOK-028 covers this JSON-first dispatch regression (verification-delta.md v1.5 §2 — extended from verdict-path-reachability; BC-10.01.001 Stage-7 PC#8 is the authoritative definition).

   If the JSON-first check fires (Check 1), the hook enters **ICD-203 15-field validation (JSON path)**. The hook validates JSON key presence (not heading anchoring) for all 15 mandatory fields: `disposition`, `confidence`, `sensor_health_status`, `evidence_artifacts`, `timeline_events`, `hypotheses_considered`, `alternatives_rejected`, `uncertainty_explicit`, `attack_techniques`, `agent_actions`, `human_actions`, `tuning_signal`, `severity`, `asset_type`, `ticket_action_type`. The check is key-presence only — a key with JSON `null` value IS present (valid for TP/Indeterminate for `tuning_signal`); a key that is entirely absent is INVALID. If any of the 15 keys is absent, the hook emits `permissionDecision: deny` with reason identifying the missing key (EC-010). If all 15 keys are present, the hook validates `tuning_signal` semantics (postcondition #4), then proceeds to the EMITTER role (Invariant #4). **Verification property (VP-HOOK-025 — FINALIZED, per-class split v1.11):** VP-HOOK-025 covers this verdict-JSON 15-field path: jq has() key-presence + per-field type assertions for all 15 fields including the 3 verdict-only fields (severity/asset_type/ticket_action_type). Per-class split explicit: verdict-JSON 15-field path / investigation-markdown 12-field path (verification-delta.md v1.3 §2 / ADV-F2-P3-008).

   > **Previous (v1.7):** "ICD-203 12-field validation (JSON path). The 12 mandatory fields: disposition, confidence, sensor_health_status, evidence_artifacts, timeline_events, hypotheses_considered, alternatives_rejected, uncertainty_explicit, attack_techniques, agent_actions, human_actions, tuning_signal." (No severity/asset_type/ticket_action_type enforcement.)

2. **Investigation file path (`*investigation-*.md` glob — .md extension required):**

   - **Dispatch condition (Check 2 — updated v1.12):** `tool_input.file_path` matches the glob `*investigation-*.md` (must end in `.md`). The `.md` extension guard prevents `.json` files containing `investigation` in their path from misrouting to this branch after JSON-first Check 1 exits without matching.

   > **Previous (v1.11) dispatch condition:** "`file_path` contains `investigation` as a substring" (no extension guard; caused routing collision with verdict JSON files at paths like `artifacts/investigations/verdict-*.json`).

   - If `file_path` matches the investigation-*.md glob but `content` does not contain the string "Disposition" (case-insensitive), the hook emits `permissionDecision: allow` — the document is still in-progress. Confidence: verified by code analysis (`hooks/disposition-guard.sh:48-51`) and test `@test "disposition-guard allows investigation without disposition yet"` (hooks.bats:252). **HOOK-ISOLATED behavior**: in the standard investigate-event workflow, Stage 7 generates the investigation document once from a complete template (event-investigation-tmpl.yaml) that already contains all four required section headings; the enrichment-completeness hook (BC-3.02.001) co-fires on the same PreToolUse/Write event and would deny any investigation file missing those sections before this hook's in-progress-allow path is exercised.
   - If `file_path` matches the investigation-*.md glob AND `content` contains "Disposition" AND `content` does NOT contain a heading-form "Alternatives Considered" (i.e., `grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"` finds no match), the hook emits `permissionDecision: deny` with a reason containing "Alternatives Considered". Body text mentioning the phrase without a markdown heading does not satisfy the gate (DI-004 RESOLVED, PR #17). Confidence: verified by code analysis (`hooks/disposition-guard.sh:53-58`) and tests `@test "disposition-guard blocks disposition without alternatives"` (hooks.bats:258) and `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323).
   - **[UPDATED v1.10]** If the investigation-*.md glob matches AND both "Disposition" and "Alternatives Considered" headings are present, the hook enters **ICD-203 12-field validation (markdown path)** (artifact-class branching per architecture-delta v1.4 §D-DEC-008-C: investigation markdown = 12 ICD-203 fields; verdict JSON = 15 fields). The hook checks for the heading-anchored presence of all **12** mandatory fields as markdown section headings (`grep -qiE "^#{1,6}[[:space:]]+<field_name>"` for each field). The 12 mandatory field headings are: `Disposition`, `Confidence`, `Sensor Health Status`, `Evidence Artifacts`, `Timeline Events`, `Hypotheses Considered`, `Alternatives Rejected`, `Uncertainty Explicit`, `Attack Techniques`, `Agent Actions`, `Human Actions`, `Tuning Signal`. `Severity`, `Asset Type`, and `Ticket Action Type` are **NOT** required in the investigation-markdown validation path — they are monitoring-loop verdict fields only and are meaningless for a manual investigation (required exclusively in the PC#1 JSON verdict path). If any of the 12 headings is absent, the hook emits `permissionDecision: deny` with reason identifying the missing field (EC-010). If all 12 are present, the hook proceeds to the hard-floor check and, if not blocked, emits the marker (see Invariant #4 — EMITTER role) before emitting `permissionDecision: allow`. **Verification property (VP-HOOK-025 — FINALIZED, per-class split v1.11):** VP-HOOK-025 covers this investigation-markdown 12-field path: heading-anchored grep for each of the 12 fields; Severity, Asset Type, Ticket Action Type are NOT required as headings (verdict-JSON-only fields per D-DEC-008-C). Per-class split explicit: investigation-markdown 12-field path / verdict-JSON 15-field path (verification-delta.md v1.3 §2 / ADV-F2-P3-008).

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

4. **[UPDATED v1.12] EMITTER role — this hook is the ONLY marker issuance path (D-DEC-001).** After ICD-203 validation passes (postconditions #1/#2 depending on artifact class), the hook enters the emitter decision tree. The emitter is entered ONLY from the verdict-class (PC#1 JSON path) — the investigation-markdown path (PC#2) emits markers using the same emitter after ICD-203 12-field validation. The emitter reads `verdict.ticket_action_type` (field 15) to select the marker scope branch.

   **Document-Before-Action stage-ordering constraint (ADV-F2-P2-001 — v1.9):** This hook fires on the `PreToolUse/Write` event for the monitoring-loop's Stage 7 DOCUMENT verdict write. Stage 7 DOCUMENT **MUST PRECEDE** Stage 8 TICKET ACTION (the jr Bash call). The monitoring-loop must write the ICD-203 verdict file (Stage 7) before executing jr (Stage 8). If the monitoring-loop attempts jr BEFORE writing the verdict, this hook has not fired, no marker exists, and require-review will deny every jr write call.

   **Emitter decision tree (D-DEC-008 v1.6 — full pseudocode):**

   ```
   # ── STEP 0: Note ─────────────────────────────────────────────────────────
   # This pseudocode is entered AFTER the JSON-first dispatch (PC#1) routes
   # the write to the verdict-class path (15-field check passed). The
   # investigation-markdown path (PC#2) has its own 12-field check and reaches
   # here only after all 12 fields are present.

   # ── STEP 1: Enum-membership validation — fail-closed (ADV-F2-P4-006 MAJOR) ─
   # Key-presence check (jq has()) alone is insufficient: severity:"High" passes
   # has() but fails the {HIGH,CRITICAL} hard-floor membership test → no hard
   # floor → regular marker issued for a genuinely HIGH-severity alert.
   # Fail-closed deny on any non-member value prevents this class of bypass.
   # VP-HOOK-025 cross-reference (v1.13): validate_enums() is the enum-membership
   # gate extension of VP-HOOK-025 (ADV-F2-P4-006 MAJOR). VP-HOOK-025 now covers
   # both the 15-field key-presence/type check AND the fail-closed membership
   # validation for all typed fields — wrong-case/non-member values (e.g.
   # severity:"High", disposition:"indeterminate") receive DENY before hard floor
   # is evaluated (verification-delta.md v1.5 §2 / §7 Part E item 2b).
   FUNCTION validate_enums(verdict):
     SEVERITY_ENUM    = {"LOW","MEDIUM","HIGH","CRITICAL"}
     ASSET_TYPE_ENUM  = {"domain_controller","privileged_account","ot_safety_system","standard","unknown"}
     DISPOSITION_ENUM = {"TP","FP","BTP","Indeterminate"}
     SENSOR_ENUM      = {"healthy","degraded","silent"}
     ACTION_ENUM      = {"comment","create","assign","none","create-review","comment-review"}
     CONFIDENCE_ENUM  = {"high","medium","low"}

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
     RETURN (True, "")

   (enum_ok, enum_err) = validate_enums(verdict)
   IF NOT enum_ok:
     emit deny("ICD-203 enum-membership validation failed: " + enum_err)
     RETURN
   # Note: emit deny (not allow) on enum failure — the document content is invalid

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
     IF NOT hard_floor_applies(verdict):
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
           fallback_hint = "jira_project_key=" + project_key_fallback + " is present — if no review ticket exists yet, re-issue with ticket_action_type=create-review instead."
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
       # Note: ASM-014 pending — structural --label check for comment-review deferred pending
       # empirical validation that `jr issue comment --label` is supported by the jr CLI.
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
   IF hard_floor_applies(verdict):
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
     pattern = "^jr (--output json )?issue comment " + ticket_id + " "
     ops = ["comment"]

   ELIF action == "create":
     ticket_id = null
     project_key = verdict.jira_project_key
     IF project_key is null OR project_key == "":
       emit allow without marker   # cannot org-bind without project key (human gate required)
       RETURN
     # ADV-F2-P4-002: --project is FIRST arg (Iron Law); trailing ( |$) prevents prefix-match
     # Old (v1.10): "^jr (--output json )?issue create .*--project <jira_project_key>"
     # New: "^jr (--output json )?issue create --project <jira_project_key>( |$)"
     pattern = "^jr (--output json )?issue create --project " + project_key + "( |$)"
     ops = ["create"]

   ELIF action == "assign":
     ticket_id = verdict.ticket_id
     IF ticket_id is null: emit allow without marker; RETURN
     pattern = "^jr (--output json )?issue assign " + ticket_id + " "
     ops = ["assign"]

   # ── WRITE_MARKER: common path for all marker types ──────────────────────
   WRITE_MARKER:
   expires_at = now() + 120s
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
       severity: verdict.severity,
       asset_type: verdict.asset_type,
       ticket_action_type: action
     }
   }
   write_marker(marker, "${CLAUDE_PLUGIN_DATA}/markers/${marker.marker_id}.marker.json")
   emit allow
   ```

   > **Previous (v1.11) emitter — no validate_enums, no autonomy_enabled, no review-surfacing path:** Emitter went directly from ICD-203 validation to hard-floor check to regular marker issuance. Enum membership was not validated (severity:"High" wrong-case could bypass hard floor). No autonomy_enabled kill switch. No create-review/comment-review paths (hard-floor verdicts silently received no marker and no review ticket). Create command_pattern used `.*--project <key>` (unbounded `.*` before `--project` allowed injection via `--summary` text).

   **Create-scope project-binding (v1.10 — ADV-F2-P3-002; pattern updated v1.12 — ADV-F2-P4-002):**

   > **Previous (v1.10) create pattern:** `^jr (--output json )?issue create .*--project <jira_project_key>` — the `.*` between `create ` and `--project` allowed an attacker-controlled `--summary "... --project ORG_A ..."` argument to satisfy the project key binding via prefix match. Also: `PROD` would match `PRODUCTION` (no trailing boundary). (ADV-F2-P3-002 cross-org fungibility attack; ADV-F2-P4-002 prefix-match bypass.)

   A create marker issued for `--project ORG-A` cannot authorize `jr issue create --project ORG-B` or `jr issue create --project ORG-A_EXTRA` (trailing `( |$)` ensures the key must be followed by a space or end-of-string). Anti-forgery is preserved: each marker is single-use via atomic rename; forged markers cannot be created by the LLM (filesystem-isolated from LLM surface).

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

   **Operational metadata fields (non-ICD-203, not counted in 15 mandatory fields):**
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

   **Hard-floor check (D-DEC-008 — Step 4 [reordered BEFORE kill switch per ADV-F2-P6-002; DENY-THE-WRITE redesigned per ADV-F2-P7-001] — for REGULAR markers only; review path exempt):** The following conditions unconditionally trigger the FAIL-LOUD deny-the-Write path. When ANY hard-floor applies and the verdict is under-labeled (non-review `ticket_action_type`), STEP 4 DENIES the verdict Write and writes an `UNDER-LABEL-DENIED` audit entry. `autonomy_enabled` is irrelevant — deny fires regardless. D-DEC-012: correctly-labeled create-review and comment-review markers bypass this function entirely (see Step 3):
   - `disposition` is `Indeterminate` (hard floor — never auto-close)
   - `verdict.severity` is `HIGH` or `CRITICAL` (field 13; **ADV-F2-001 CRITICAL fix: keyed on severity, NOT confidence — orthogonal axes**)
   - `verdict.asset_type` is in `CRITICAL_ASSET_TYPES` (field 14; domain controllers, OT safety systems, privileged accounts)
   - `verdict.asset_type == "unknown"` (field 14; **separate explicit check — NOT folded into CRITICAL_ASSET_TYPES set**; per ADV-F2-P3-001)
   - Any MITRE technique in `attack_techniques` is T1003, T1068, T1021, or T1041
   - `sensor_health_status` is `degraded` or `silent`

   > **Previous (v1.8/v1.9) hard-floor list also included:** "Cross-tenant scope indicators present in `evidence_artifacts`." Removed in v1.10 (ADV-F2-P3-011): per D-DEC-005, plugin obligation is org_slug scoping only.

   > **Previous (v1.7):** Hard-floor check used "`confidence` maps to HIGH or CRIT severity threshold" as the severity-proxy condition. (ADV-F2-001 CRITICAL fix.)

   When any hard-floor condition is met: **correctly-labeled AND bindable verdicts** (`ticket_action_type` = `"create-review"` or `"comment-review"`, with binding field present: `jira_project_key` for create-review, `ticket_id` for comment-review) are handled at STEP 3 — a review-surfacing marker IS written (exempt from kill switch per D-DEC-012 Option A confirmed 2026-07-21) and the finding reaches human review. **Correctly-labeled but UNBINDABLE verdicts** (`create-review` with null `jira_project_key`; `comment-review` with null `ticket_id`) trigger the **HARD-FLOOR-UNBINDABLE deny path** at STEP 3 (P8-001/D-DEC-012 clause 2): explicit HARD-FLOOR-UNBINDABLE audit entry + structured deny; NO marker issued; NO silent allow; bounded fail-closed (one audit entry + one deny per re-doc attempt; no Jira write). **Under-labeled verdicts** (non-review `ticket_action_type`, incl. `"create"`, `"comment"`, `"assign"`, or `"none"`) fall through STEP 3; at STEP 4 (ADV-F2-P6-002 reorder — formerly STEP 5; ADV-F2-P7-001 DENY-THE-WRITE redesign), the hook checks `hard_floor_applies()` and **DENIES the verdict Write** with a structured corrective reason (`HARD-FLOOR-UNDER-LABEL`; `required_token` = `comment-review` if `ticket_id` present, else `create-review`). An `UNDER-LABEL-DENIED` audit entry is written. No marker is issued on this path. The loop MUST re-issue the verdict Write with `ticket_action_type` set to the corrective review token; STEP 3 then issues the review marker on the corrected Write. `autonomy_enabled` is irrelevant — deny fires regardless. Only non-hard-floor verdicts reach STEP 5 (kill switch). **SKILL.md Iron Law (ADV-F2-P7-003): set the correct review token in the first place.** STEP 4 is a deterministic safety net — not a delegation of labeling responsibility (EC-012; cases (c)/(d) collapsed to single DENY case).

   **Verification property (VP-HOOK-026 — FINALIZED, including unknown-asset leg v1.11):** VP-HOOK-026 explicitly tests all hard-floor legs of this emitter, including the separate `asset_type=unknown` conservative hard-floor (ADV-F2-P3-001 CRITICAL addition in v1.10 — NOT folded into CRITICAL_ASSET_TYPES): a LOW-severity + benign-technique + asset_type=unknown verdict NEVER receives a regular marker. Paired mutant SM-29 (unknown-asset-hard-floor-removed) is the kill target. FINALIZED per verification-delta.md v1.3 §7 Part D.

   **Marker directory initialization:** If `${CLAUDE_PLUGIN_DATA}/markers/` does not exist, the hook creates it with mode 0700 before writing. Failure to create → emit allow without marker (non-fatal; subsequent require-review will find no marker and deny).

   Confidence: D-DEC-001 binding decision (architecture-delta.md v1.2 §D-DEC-001); D-DEC-008 v1.6 hard-floor pseudocode + generation table (architecture-delta.md v1.6 §D-DEC-008); D-DEC-012 review-surfacing path; ADV-F2-001 (severity/confidence orthogonal axes); ADV-F2-P4-001 (JSON-first dispatch); ADV-F2-P4-002 (anchored create pattern); ADV-F2-P4-005 (autonomy_enabled kill switch); ADV-F2-P4-006 (enum-membership validation).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr error, no JSON output |
| EC-002 | File path `/tmp/readme.md` | Allow — not an investigation or verdict file |
| EC-003 | Investigation file with no Disposition section | Allow — in-progress; gate only fires once Disposition is declared. **HOOK-ISOLATED**: in aggregate, enrichment-completeness BC-3.02.001 co-fires and denies investigation files missing any of the four required sections. |
| EC-004 | Investigation file with "Disposition: True Positive" but no Alternatives Considered | Deny with reason mentioning "Alternatives Considered" |
| EC-005 | Investigation file with both "Disposition" and "Alternatives Considered" sections and all 12 mandatory headings (investigation-markdown path), non-hard-floor disposition | Allow; marker written to `${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json` (scope determined by ticket_action_type content if present; defaults to comment-scoped for investigation files) |
| EC-006 | Investigation file with "disposition" (lowercase) section | Deny if Alternatives absent — `grep -qiF` matches case-insensitively |
| EC-007 | Content containing "Disposition" in body text (not a section header) | Allow if "Alternatives Considered" also present anywhere; Deny if absent. The check is on substring presence in the full content. |
| EC-008 | Malformed JSON stdin | `jq` returns empty string for file_path; path doesn't match `investigation` or `verdict`; emit allow |
| EC-009 | Investigation file with "Disposition" section present AND "Alternatives Considered" appearing as negating body text only (e.g., "No Alternatives Considered were required.") | **RESOLVED (DI-004/SM-1, PR #17):** `permissionDecision: deny`. Heading-anchored check requires an actual markdown heading. BATS: `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323). |
| EC-010 | Investigation or verdict file with Alternatives Considered present (or all other JSON keys present) but missing one of the 15 mandatory fields — e.g., `timeline_events` heading absent from markdown, `tuning_signal` key entirely absent from JSON verdict, or new fields `severity`/`asset_type`/`ticket_action_type` absent from JSON verdict | Deny with reason identifying the specific missing field (e.g., "ICD-203 required field missing: timeline_events"). No marker written. |
| EC-011 | Verdict file with `disposition: "FP"` AND `tuning_signal: null` (null present but wrong semantics for FP) | Deny: tuning_signal must be a non-null object for FP/BTP dispositions. No marker written. |
| EC-012 | Investigation or verdict file passes all 15 mandatory field checks but `disposition: "Indeterminate"` (hard floor) | Allow (the write IS permitted — the document is valid). Marker issuance depends on `ticket_action_type` (and `autonomy_enabled` for non-hard-floor verdicts — but hard-floor verdicts bypass the kill switch): **(a)** `ticket_action_type=create-review` + `hard_floor_applies()`=true → STEP 3 emits create-review marker (pattern: `^jr ... create --project <key> --label (REVIEW-REQUIRED\|BLIND-SPOT)( \|$)` per ADV-F2-P6-001); finding routed to human review queue. **(b)** `ticket_action_type=comment-review` + `ticket_id` present + `hard_floor_applies()`=true → STEP 3 emits comment-review marker. **(c)** under-labeled (any non-review token, incl. `"create"`, `"comment"`, `"assign"`, `"none"`) → **STEP 4 DENY-THE-WRITE (ADV-F2-P7-001)**: `permissionDecision: deny` with `HARD-FLOOR-UNDER-LABEL` corrective reason; `UNDER-LABEL-DENIED` audit entry written; no marker issued; `autonomy_enabled` is irrelevant — deny fires regardless of its value. The loop MUST re-issue the verdict Write with `ticket_action_type` set to the corrective review token from the deny reason (`required_token` = `comment-review` if `ticket_id` present, else `create-review`); STEP 3 then issues the review marker on the corrected Write. **Note:** cases (c) and (d) from v1.15 (autonomy_enabled=true vs autonomy_enabled=false with upgrade semantics) are **COLLAPSED** — both now produce the same DENY outcome. `autonomy_enabled` no longer differentiates outcomes at this step. |

## Canonical Test Vectors

| Input (file_path → content) | Expected Output | Category |
|-----------------------------|----------------|----------|
| `/tmp/readme.md` → any | `permissionDecision: allow` | happy-path |
| `investigation-ALERT-001.md` → "# Alert Details\nEvidence..." (no Disposition) | `permissionDecision: allow` **(HOOK-ISOLATED: in aggregate, enrichment-completeness BC-3.02.001 would deny this file — missing 3 of 4 required sections)** | hook-isolated-allow |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\n# Evidence\n..." (no Alternatives) | `permissionDecision: deny`, reason contains "Alternatives Considered" | error |
| `investigation-ALERT-001.md` → all 12 mandatory headings present (investigation-markdown path), disposition=TP, tuning_signal=null, non-hard-floor | `permissionDecision: allow`; marker file written to `${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json` (comment-scoped, ticket-bound pattern) | happy-path (v1.10 EMITTER — 12-field investigation path) |
| `investigation-ALERT-001.md` → "# disposition\nFalse Positive" (lowercase) | `permissionDecision: deny` | edge-case |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\nNo Alternatives Considered were required." | `permissionDecision: deny` (RESOLVED — PR #17 heading-anchored check; body-text negation no longer passes) | edge-case |
| `verdict-ALERT-001.json` → JSON with all 15 keys present, disposition=FP, tuning_signal={"rule_id":"R-001","asset":"host-42","reason":"benign scanner"}, severity=LOW, asset_type=standard, ticket_action_type=comment, non-hard-floor | `permissionDecision: allow`; comment-scoped marker file written with ticket-bound command_pattern | happy-path (v1.8 JSON path) |
| `verdict-ALERT-001.json` → JSON with all 15 keys present, disposition=FP, ticket_action_type=create, severity=LOW, asset_type=standard, jira_project_key=SEC, autonomy_enabled=true, non-hard-floor | `permissionDecision: allow`; create-scoped marker written (ticket_id=null, command_pattern `^jr (--output json )?issue create --project SEC( \|$)`) | happy-path (v1.12 create-scoped anchored pattern) |
| `artifacts/investigations/verdict-ALERT-001.json` → JSON with all 15 keys present (path contains BOTH `investigations` and ends `.json`) | JSON-first dispatch (Check 1) fires — routes to verdict-class 15-field path; NOT to investigation-markdown branch (ADV-F2-P4-001 regression test) | happy-path (v1.12 JSON-first dispatch) |
| `verdict-ALERT-001.json` → JSON with `severity: "High"` (wrong case — not in SEVERITY_ENUM) | `permissionDecision: deny`; reason "ICD-203 enum-membership validation failed: severity 'High' not in allowed set" (ADV-F2-P4-006 enum validation) | error (v1.12 enum-validation) |
| `verdict-ALERT-001.json` → JSON with all 15 keys, disposition=Indeterminate, ticket_action_type=create-review, jira_project_key=SEC, autonomy_enabled=false | `permissionDecision: allow`; create-review marker written (STEP 3: hard_floor_applies()=true gate satisfied — Indeterminate; exempt from kill switch); authorized_operations=["create-review"]; command_pattern includes `--label (REVIEW-REQUIRED\|BLIND-SPOT)` in fixed second position per ADV-F2-P6-001 | happy-path (D-DEC-012 review-surfacing) |
| `verdict-ALERT-001.json` → JSON with all 15 keys, disposition=TP, ticket_action_type=create, severity=LOW, autonomy_enabled=false | `permissionDecision: allow`; NO marker written (STEP 3 exits with allow-without-marker — create is not a review token; STEP 4 hard_floor_applies()=false for LOW-severity TP — deny-the-Write does NOT fire; kill switch STEP 5 fires — autonomy_enabled=false) | edge-case (ADV-F2-P4-005 kill switch) |
| `verdict-ALERT-001.json` → JSON missing `timeline_events` key | `permissionDecision: deny`, reason "ICD-203 required field missing: timeline_events" | error (EC-010) |
| `verdict-ALERT-001.json` → JSON missing `severity` key | `permissionDecision: deny`, reason "ICD-203 required field missing: severity" | error (EC-010) |
| `verdict-ALERT-001.json` → disposition=FP, tuning_signal=null | `permissionDecision: deny`, reason "tuning_signal must be non-null object for FP/BTP" | error (EC-011) |
| `verdict-ALERT-001.json` → all 15 keys, disposition=Indeterminate, severity=HIGH, ticket_action_type=create (under-labeled), jira_project_key=SEC, ticket_id=null (autonomy_enabled irrelevant — tested both true and false) | `permissionDecision: deny`; `HARD-FLOOR-UNDER-LABEL` error JSON returned with `required_token="create-review"`, `hard_floor_trigger="Indeterminate/HIGH/..."`, `label_instruction`; `UNDER-LABEL-DENIED` audit entry written to audit.log; NO marker issued; loop MUST re-issue verdict Write with ticket_action_type="create-review"; BATS: `@test "disposition-guard verdict Write DENIED UNDER-LABEL-DENIED corrective reason under-labeled hard-floor"` | edge-case (EC-012 case c — **ADV-F2-P7-001 DENY-THE-WRITE**) |
| `verdict-ALERT-001.json` → all 15 keys, disposition=Indeterminate, severity=HIGH, ticket_action_type=`"create-review"`, **jira_project_key=null** (correctly-labeled but unbindable), autonomy_enabled=false | `permissionDecision: deny`; audit.log entry: `HARD-FLOOR-UNBINDABLE: hard-floor create-review verdict with missing jira_project_key; missing_field=jira_project_key; verdict Write denied by disposition-guard (P8-001/D-DEC-012 clause 2)`; deny reason includes `hard_floor_trigger`, `missing_field=jira_project_key`, corrective instruction to re-issue with jira_project_key populated; **NO marker issued; NO silent allow-without-marker; bounded fail-closed** (re-doc with jira_project_key still null fires again — exactly one HARD-FLOOR-UNBINDABLE audit entry + one deny per attempt); BATS: `@test "disposition-guard HARD-FLOOR-UNBINDABLE deny create-review null jira_project_key"` | **edge-case (P8-001 CRITICAL — ADV-F2-P8-001/D-DEC-012 clause 2)** |
| `verdict-ALERT-001.json` → all 15 keys, disposition=CRITICAL, severity=CRITICAL, ticket_action_type=`"comment-review"`, **ticket_id=null**, jira_project_key=`"PRISM-DEMO"` (correctly-labeled but unbindable; project_key present → fallback hint) | `permissionDecision: deny`; audit.log entry: `HARD-FLOOR-UNBINDABLE: hard-floor comment-review verdict with null ticket_id; missing_field=ticket_id; verdict Write denied by disposition-guard (P8-001/D-DEC-012 clause 2)`; deny reason includes `hard_floor_trigger`, `missing_field=ticket_id`, fallback hint: `"jira_project_key=PRISM-DEMO is present — if no review ticket exists yet, re-issue with ticket_action_type=create-review instead."`; **NO marker issued; NO silent allow-without-marker; bounded fail-closed**; BATS: `@test "disposition-guard HARD-FLOOR-UNBINDABLE deny comment-review null ticket_id with project_key fallback hint"` | **edge-case (P8-001 CRITICAL — ADV-F2-P8-001/D-DEC-012 clause 2)** |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-007 | Investigation file with Disposition but no Alternatives always produces deny | integration / BATS |
| VP-HOOK-008 | Investigation file without Disposition always produces allow (in-progress gate) | integration / BATS |
| VP-HOOK-009 | Non-investigation, non-verdict files always produce allow | integration / BATS |
| VP-HOOK-026 | **[NEW v1.11]** Hard-floor non-overridability (FINALIZED per verification-delta.md v1.3 §7 Part D): all hard-floor conditions unconditionally suppress marker issuance, including the separate `asset_type=unknown` leg (NOT a member of CRITICAL_ASSET_TYPES — explicit check). Tests: LOW-severity + benign-technique + asset_type=unknown verdict → zero markers written (SM-29 kill target); HIGH/CRITICAL severity → zero markers; Indeterminate disposition → zero markers; CRITICAL_ASSET_TYPES → zero markers; degraded/silent sensor health → zero markers. | integration / BATS (`@test "disposition-guard unknown-asset hard-floor: no marker emitted"`, `@test "disposition-guard critical-severity hard-floor: no marker emitted"`, `@test "disposition-guard indeterminate hard-floor: no marker emitted"`) |
| VP-HOOK-025 | **[UPDATED v1.10]** Artifact-class branching enforcement (architecture-delta v1.4 §D-DEC-008-C — ADV-F2-P3-003). **Investigation markdown path (12 ICD-203 fields):** heading-anchored `grep -qiE "^#{1,6}[[:space:]]+<field>"` for each of: (1) disposition, (2) confidence, (3) sensor_health_status, (4) evidence_artifacts, (5) timeline_events, (6) hypotheses_considered, (7) alternatives_rejected, (8) uncertainty_explicit, (9) attack_techniques, (10) agent_actions, (11) human_actions, (12) tuning_signal. Severity, asset_type, ticket_action_type are NOT required headings in the investigation-markdown path. **Verdict JSON path (15 fields):** `jq has()` key-presence check + per-field type assertions for all 15 fields (fields 1–12 above plus (13) severity, (14) asset_type, (15) ticket_action_type). Verdict JSON files missing any of the 15 keys receive deny. tuning_signal null-vs-absent semantics enforced (null valid for TP/Indeterminate; non-null object required for FP/BTP). Hard-floor check re-keyed to verdict.severity (field 13) + verdict.asset_type (field 14) including separate `unknown` check (ADV-F2-P3-001). | integration / BATS (`@test "disposition-guard denies verdict missing timeline_events"`, `@test "disposition-guard denies verdict missing severity"`, `@test "disposition-guard denies FP verdict with null tuning_signal"`, `@test "disposition-guard allows TP verdict with null tuning_signal and all 15 fields"`, `@test "disposition-guard allows investigation with 12 fields (severity/asset_type/ticket_action_type headings not required)"`) |

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

- **guard clause**: file path substring checks for `investigation` and `verdict` (path dispatch)
- **guard clause**: case-insensitive content check for "Disposition" presence (lines 48-51)
- **guard clause**: heading-anchored case-insensitive content check for "Alternatives Considered" absence (`grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"`, line 57 — DI-004 RESOLVED, PR #17)
- **guard clause (v1.6/v1.10)**: 12-field ICD-203 heading-anchored check for investigation files (markdown path — 12 fields; v1.10 artifact-class branching)
- **guard clause (v1.6/v1.8)**: 15-key JSON key-presence validation for verdict files (JSON path — 15 fields after v1.8 addition of severity/asset_type/ticket_action_type)
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

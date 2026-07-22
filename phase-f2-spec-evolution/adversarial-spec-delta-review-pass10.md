---
document_type: adversarial-review
pass: 10
producer: adversary
date: 2026-07-21
feature: prism-integration
phase: f2-spec-evolution
---

# Adversarial Review — Pass 10 (F2 spec-evolution delta package)

## Summary Table

| ID | Severity | Title | Primary anchor |
|----|----------|-------|----------------|
| P10-001 | **CRITICAL** | Hard floor keys on LLM-controlled `verdict.severity`/`verdict.asset_type` with no cross-validation against source data; "LLM cannot bypass" claim is false | architecture-delta §D-DEC-008 (lines 1587-1594); BC-10.01.001 Inv#10 |
| P10-002 | **MAJOR** | Cron wrapper fail-loud gate does not observe the fail-loud artifacts it depends on (audit.log codes never inspected; `HARD-FLOOR-LIVELOCK-ABORT` not wired; hook-deny→`permission_denials` unvalidated) `[process-gap]` | architecture-delta wrapper (lines 843-852); BC-10.01.001 PC#7, Inv#10 |
| P10-003 | **MAJOR** | Marker-write-failure fallback (`emit allow without marker`) reintroduces silent-drop on the hard-floor review path (STEP 3) | BC-3.03.001 line 514 + WRITE_MARKER (lines 400-419) |
| P10-004 | MINOR | P9-007 dedup-before-create-review gate not propagated into BC-3.03.001 emitter `fallback_hint` (partial-fix propagation gap) | BC-3.03.001 line 286 vs architecture-delta line 1410 / BC-10.01.001 Inv#10 |
| P10-005 | MINOR | scan-threats org_slug VP (VP-SKILL-059) is structural-only while sibling skills got behavioral multi-org DTU fixtures — highest cross-org leak surface has the weakest VP | BC-9.01.001 VP-SKILL-059 vs BC-10.01.001 VP-SKILL-064 / BC-5.01.001 VP-SKILL-069 |
| P10-006 | MINOR | D-DEC-005 sensor-health carve-out exemption predicate under-specified; a JOIN/subquery referencing `prism_sensor_health` alongside a raw table could inherit the org_slug exemption | architecture-delta lines 1042-1044; BC-8.02.001 Inv#2 |
| P10-007 | MINOR | VP-SKILL-064 concrete `@test` name ("rejects unscoped PrismQL query") not qualified after the carve-out — would wrongly reject a legitimate unscoped `prism_sensor_health` query | BC-10.01.001 VP-SKILL-064 (line 561) |
| P10-008 | MINOR | comment-review (kill-switch-exempt) path carries no `--label` restriction (ASM-014 pending); an LLM-supplied `ticket_id` lets the exempt path comment on a non-review ticket under `autonomy_enabled=false` | BC-3.03.001 line 301, 492; BC-3.01.001 step 6/6a (lines 107-109) |
| P10-009 | MINOR | `jira_project_key` is a single global plugin-state value; onboard-customer captures no per-org key, so the "multi-project deployments retain full per-org-key binding" claim has no config surface | BC-6.01.001 PC#12; BC-6.01.003 PC#1; BC-3.01.001 line 298 |

---

## Critical Findings

### P10-001 — Hard floor trusts LLM-supplied `verdict.severity`/`verdict.asset_type`; the "definitive enforcement surface the LLM cannot bypass" claim is false — CRITICAL

**Confidence: HIGH.**

**Anchor:** architecture-delta.md §D-DEC-008 lines 1585-1594 ("disposition-guard validates `verdict.severity` + `verdict.asset_type` — the definitive enforcement surface that the LLM cannot bypass"); BC-10.01.001 Invariant #10 lines 377-385 ("disposition-guard reads them from the verdict JSON — NOT from raw alert data. This is what enables enforcement at the deterministic hook layer"); `hard_floor_applies()` (architecture-delta lines 1604-1635; BC-3.03.001 lines 498-504).

**Description.** The hard floor is the load-bearing safety control: HIGH/CRITICAL severity, critical/unknown asset_type, T1003/T1068/T1021/T1041, and degraded/silent sensors are routed to human review and MUST NOT receive a regular auto-action marker. `hard_floor_applies()` computes this **exclusively from `verdict.severity` (field 13) and `verdict.asset_type` (field 14)**, which are written into the verdict JSON by the monitoring-loop LLM (Stage 1 `NORMALIZE_SEVERITY` and Stage 5 SCORE). disposition-guard fires on the Stage-7 verdict `Write` event and sees only `tool_input.content` (the verdict JSON). **It never sees the raw prism sensor record**, and the verdict schema contains no `native_severity` or `sensor_family` operational field. Therefore the hook has no independent basis to verify `verdict.severity`; it applies the hard floor to whatever value the LLM wrote.

This is the exact pattern the O3 standing rule (cited elsewhere in this very package for `ticket_action_type`) exists to prevent: an LLM-supplied field that grants/bypasses a security control must be cross-validated against a hook-computed invariant. `ticket_action_type` IS cross-validated (against `hard_floor_applies()`), but the inputs to `hard_floor_applies()` itself — severity and asset_type — are NOT. The cross-validation is circular: the hook computes the floor from the same LLM output it is meant to police. The "dual enforcement / defense-in-depth" framing (BC-10.01.001 Inv#10) is illusory because BOTH layers (SKILL.md branches and disposition-guard) key on the identical LLM-produced values.

**Concrete failure scenario.** A malicious OCSF sensor record or attacker-influenced alert content prompt-injects the monitoring-loop LLM to emit `verdict.severity="LOW"` and `verdict.asset_type="standard"` for a genuine domain-controller credential-dumping event. All enum checks pass (LOW/standard are valid members). `hard_floor_applies()` returns FALSE. With `autonomy_enabled=true`, disposition-guard issues a **regular** `["comment"]`/`["create"]` marker; require-review consumes it; the loop auto-dispositions (e.g., auto-closes as FP with a tuning signal) a real high-severity intrusion — no human review, no `[REVIEW-REQUIRED]` ticket. The deterministic backstop that the design advertises as un-bypassable was defeated by the same injection that defeated the LLM.

**Suggested remediation.** (1) Correct the "the LLM cannot bypass" / "definitive enforcement surface" language in architecture-delta §D-DEC-008 and BC-10.01.001 Inv#10 — as written it overstates the security property. (2) Move `NORMALIZE_SEVERITY` (a deterministic D-DEC-013 table) into disposition-guard: add `native_severity` + `sensor_family` as required verdict operational-metadata fields carried verbatim from Stage 1 INGEST, have the hook re-compute severity deterministically and **DENY** on mismatch with `verdict.severity`. This relocates trust from the LLM to the hook and makes the enforcement genuinely un-bypassable. (3) Add an adversarial VP/BATS fixture: "verdict under-reports severity relative to native_severity → disposition-guard denies (SEVERITY-MISMATCH), no regular marker." Analogous cross-check is needed for `asset_type` (prism-sourced classification carried into the verdict for hook re-validation).

---

## Important Findings

### P10-002 — The cron wrapper's failure gate cannot observe the fail-loud artifacts the whole design relies on — MAJOR `[process-gap]`

**Confidence: HIGH (wrapper logic); MEDIUM (permission_denials behavior — precisely because it is unvalidated).**

**Anchor:** architecture-delta.md cron wrapper lines 820-854 (gate at lines 843-852 keys ONLY on `is_error` and `permission_denials`); `HARD-FLOOR-LIVELOCK-ABORT` (BC-10.01.001 Inv#10 lines 332-345 → writes to `stderr` + `${CLAUDE_PLUGIN_DATA}/markers/audit.log`); `HARD-FLOOR-UNBINDABLE` / `UNDER-LABEL-DENIED` audit entries (BC-3.03.001 lines 250-253, 334-339); ASM-004 (`permission_denials: []` observed only under `--dangerously-skip-permissions`; hook-emitted deny never tested).

**Description.** Every fail-loud guarantee in this package terminates in "a deny + an audit.log entry." But the operator-observable signal — the cron wrapper exit code — is wired ONLY to `is_error` and `permission_denials` from the `claude -p --output-format json` envelope. Two gaps:

1. **audit.log is never inspected.** `HARD-FLOOR-LIVELOCK-ABORT` is a *loop-internal* action: after 3 denies the LLM stops re-documenting and advances to the next verdict; the run then completes `subtype:success`, `is_error:false`. The abort artifact is written to `markers/audit.log` and `stderr.log` — neither of which the wrapper reads (wrapper LOG_DIR is `monitoring-loop-logs`, a different directory). A run that drops hard-floor findings to audit-only mode reports **success** to cron. This directly contradicts the design's absolute fail-loud invariant (brief §3.7: conflating "could not observe" with "clean" is the named silent-failure mode) — but now for hard-floor *findings*, not sensor silence.

2. **hook-deny → `permission_denials` is an unvalidated assumption.** The DENY-THE-WRITE (STEP 4) and HARD-FLOOR-UNBINDABLE (STEP 3) paths, and every require-review Stage-8 deny, are asserted to be "loud." But whether a PreToolUse-hook `permissionDecision: deny` populates the top-level `.permission_denials` array in the JSON envelope is nowhere validated — ASM-004 only observed `permission_denials: []` under `--dangerously-skip-permissions` and never exercised a hook-emitted deny. If hook denies surface as transcript errors rather than in `.permission_denials`, then a loop that fails to re-document (an acknowledged conformance possibility) drops the finding and the wrapper exits 0.

VP-HOOK-029 asserts fail-loud "marker dir non-empty OR error artifact present" — but only at the internal marker/audit boundary, never at the cron-envelope/operator boundary. The gap between "audit.log has the entry" and "operator is alerted" is unbridged and unverified.

**Concrete failure scenario.** `jira_project_key` becomes unset in plugin state after the wrapper's pre-check (or a comment-review verdict cannot resolve `ticket_id`). Three HARD-FLOOR-UNBINDABLE denies fire, the loop hits the re-doc cap, emits `HARD-FLOOR-LIVELOCK-ABORT` to audit.log, and advances. The run completes with `is_error:false`; if hook denies do not populate `permission_denials`, `denials=0`; wrapper `exit 0`. Cron records a healthy run. A CRITICAL hard-floor finding never reached Jira and no operator signal fired.

**Suggested remediation.** (1) Add an ASM (peer of ASM-004) empirically validating whether PreToolUse-hook denies appear in `.permission_denials` under the authoritative `--allowedTools` invocation; block the loop stories until confirmed. (2) Extend the wrapper (and BC-10.01.001 PC#7) to `grep` `markers/audit.log` for `HARD-FLOOR-LIVELOCK-ABORT|HARD-FLOOR-UNBINDABLE|UNDER-LABEL-DENIED` entries newer than the run start and `exit 1` if any are present. (3) Add a VP asserting the operator-boundary signal (cron exit≠0) fires for a livelock-abort run. `[process-gap]`: no ASM and no VP currently bridge the hook-layer fail-loud artifacts to the operator-observable failure signal.

### P10-003 — Marker-write-failure fallback (`emit allow without marker`) reintroduces silent-drop on the hard-floor review path — MAJOR

**Confidence: HIGH.**

**Anchor:** BC-3.03.001 line 514 ("Marker directory initialization: … Failure to create → emit allow without marker (non-fatal; subsequent require-review will find no marker and deny)"); WRITE_MARKER pseudocode BC-3.03.001 lines 400-419 (STEP 3 create-review/comment-review reach WRITE_MARKER via `GOTO`).

**Description.** STEP 3 (correctly-labeled, bindable hard-floor verdict) routes through `GOTO WRITE_MARKER`, which calls `write_marker(...)`. The only specified handling of a marker-write/dir-create failure is the blanket "emit allow without marker (non-fatal)." Applied to the review path, this is a silent-drop: the verdict `Write` is **allowed** (no deny, no re-doc trigger — the re-doc obligations in BC-10.01.001 Inv#10 fire only on STEP-3/STEP-4 *denies*, not on allow-without-marker), no audit entry is written, then Stage-8 `jr issue create --label REVIEW-REQUIRED` is denied by require-review (no marker), so the escalation ticket is never created. This is precisely the silent-discard class P8-001 was created to eliminate for the null-binding-field case — here reintroduced for the infra-failure case, on the security-critical escalation path, contradicting the absolute D-DEC-012 fail-loud invariant ("hard-floor verdicts NEVER silently discarded").

**Concrete failure scenario.** `${CLAUDE_PLUGIN_DATA}` is on a full or read-only volume (disk pressure, quota, permissions drift). A genuine CRITICAL/Indeterminate verdict reaches STEP 3; `write_marker` fails; the hook emits allow-without-marker; the verdict Write succeeds; Stage-8 review-create is denied; the loop has no re-doc obligation for this case and advances. The hard-floor finding is silently dropped with no Jira ticket and no error artifact.

**Suggested remediation.** For the review path (STEP 3 create-review/comment-review), a marker-write failure MUST fail closed: `WRITE audit entry (MARKER-WRITE-FAILED, missing/unwritable markers dir) + emit deny` (mirroring the P8-001 HARD-FLOOR-UNBINDABLE structure), not allow-without-marker. Only the non-hard-floor regular-marker path may retain allow-without-marker (there require-review's deny is the human gate). Update BC-3.03.001 line 514 to branch on hard-floor/review vs regular.

---

## Minor Findings

### P10-004 — P9-007 dedup-before-create-review gate not propagated into BC-3.03.001 emitter `fallback_hint` — MINOR (partial-fix propagation gap)

**Confidence: HIGH.**

**Anchor:** BC-3.03.001 line 286 (comment-review null-ticket_id branch: `fallback_hint = "… if no review ticket exists yet, re-issue with ticket_action_type=create-review instead."`) versus architecture-delta line 1410 and BC-10.01.001 Inv#10 lines 317-328, both of which carry the full "re-run the §3.4 BLIND-SPOT/REVIEW-REQUIRED dedup query first; only re-issue as create-review if dedup confirms no open ticket" instruction.

**Description.** The P9-007 remediation (dedup gate to prevent duplicate BLIND-SPOT/REVIEW-REQUIRED tickets on the comment-review→create-review fallback) landed in architecture-delta v1.12 and BC-10.01.001 v1.14, but **BC-3.03.001 was not revised in Pass-9** (latest revision is v1.17/Pass-8; no v1.18/P9 entry). Since disposition-guard is the component that actually emits the runtime deny reason the loop acts on, the machine-readable hint the loop receives is the *weaker* short form lacking the dedup instruction. A loop acting solely on the runtime hint would skip the dedup and risk a duplicate ticket — the exact D-DEC-004 violation P9-007 intended to prevent. This is a same-layer sibling propagation gap (Partial-Fix Regression Discipline axis).

**Suggested remediation.** Update BC-3.03.001 line 286 `fallback_hint` to match architecture-delta line 1410 (include the "re-run §3.4 dedup first" instruction); add a v1.18/P9-007 revision-history entry.

### P10-005 — scan-threats org_slug VP is structural-only while sibling skills got behavioral multi-org fixtures — MINOR (verification gap, pattern)

**Confidence: HIGH.**

**Anchor:** BC-9.01.001 VP-SKILL-059 (line 130, "structural / BATS … SKILL.md … documents that all PrismQL queries must include org_slug") versus BC-10.01.001 VP-SKILL-064 (line 561), BC-5.01.001 VP-SKILL-069 (line 147), BC-4.05.001 VP-SKILL-070 (line 155) — all "integration / BATS" with prism-DTU multi-org fixtures asserting org-a returns zero org-b/c rows + unscoped-query adversarial leg.

**Description.** scan-threats has the largest cross-org leak surface in the package: it iterates ALL registered orgs and executes a *predefined query library* maintained in a data file (`data/threat-hunt-queries.md`). Yet its sole org_slug VP (VP-SKILL-059) only checks that the SKILL.md prose documents the requirement — it does not run a multi-org behavioral fixture and does not statically verify that every query in the library contains an `org_slug` clause. A single library query missing org_slug would leak cross-tenant data and pass VP-SKILL-059. The three sibling prism-querying skills all received behavioral VPs; scan-threats did not.

**Suggested remediation.** Upgrade VP-SKILL-059 to a behavioral VP (prism-DTU multi-org fixture: org-a hunt returns zero org-b/c rows) AND add a static assertion that every query in the predefined hunting-query library file contains an `org_slug` scope clause.

### P10-006 — D-DEC-005 sensor-health carve-out exemption predicate is under-specified — MINOR (security)

**Confidence: MEDIUM.**

**Anchor:** architecture-delta lines 1042-1044 ("Scope of carve-out: limited to `prism_sensor_health`"); BC-8.02.001 Inv#2; BC-10.01.001 Inv#1 EXCEPTION (line 156). Enforcement is VP-SKILL-064 (static Iron-Law WHERE-clause assertion + LLM obligation), not a deterministic PreToolUse hook on `mcp__prism__query`.

**Description.** The carve-out exempts `prism_sensor_health` queries from the org_slug rule but never defines the predicate by which the (static/LLM) enforcement distinguishes an exempt "health metadata query" from a raw-data query. If the exemption is keyed on the substring `prism_sensor_health` appearing in the query, a query that references `prism_sensor_health` *together with* a raw table (e.g. `SELECT ... FROM prism_sensor_health h, crowdstrike_detections d WHERE ...`, or a subquery) would inherit the exemption and escape the org_slug requirement. prism-side RBAC remains the true isolation boundary (so this is defense-in-depth degradation, not a guaranteed leak) and PrismQL JOIN support is unconfirmed — hence MINOR — but the carve-out should be tightened. The absolute-rule enforcement (VP-SKILL-064) is also not a deterministic hook, so the whole plugin-side org_slug guarantee is LLM-behavior + static-text, with prism RBAC as the only hard boundary; the carve-out widens that soft surface.

**Suggested remediation.** Tighten the carve-out text to "exempt ONLY when `prism_sensor_health` is the sole table reference in the query (no JOIN, no subquery against any raw per-tenant table)"; require VP-SKILL-064's static check to reject a `prism_sensor_health` query that also references a raw table without org_slug.

### P10-007 — VP-SKILL-064 concrete `@test` name not qualified after the carve-out — MINOR (verification/test-spec drift)

**Confidence: HIGH.**

**Anchor:** BC-10.01.001 VP-SKILL-064 (line 561): property text was updated to note the `prism_sensor_health` exemption, but the concrete BATS test names still read `@test "monitoring-loop rejects unscoped PrismQL query"` (unqualified) and there is no test pinning the exemption boundary.

**Description.** Post-carve-out, an unscoped `SELECT * FROM prism_sensor_health` is *legitimate*, but an unscoped raw-table query must still be rejected. The unqualified test name is ambiguous: implemented literally it would either (a) wrongly reject the exempt health query, or (b) leave the exemption boundary (health-exempt vs raw-rejected) entirely unverified. This is the same "test name not updated after a scope change" drift class flagged in the Partial-Fix axis.

**Suggested remediation.** Rename to `@test "monitoring-loop rejects unscoped RAW-TABLE PrismQL query"` and add `@test "monitoring-loop allows unscoped prism_sensor_health query (D-DEC-005 carve-out)"`.

### P10-008 — comment-review (kill-switch-exempt) path lacks a `--label` restriction; LLM-supplied `ticket_id` can target a non-review ticket under the kill switch — MINOR (security, ASM-014)

**Confidence: MEDIUM.**

**Anchor:** BC-3.03.001 line 301 (comment-review `command_pattern = "^jr (--output json )?issue comment <ticket_id> "` — no `--label`; ASM-014 pending, line 299) and line 492; BC-3.01.001 step 6/6a (lines 107-109 — comment-type commands get OR-accept with no structural label check pending ASM-014).

**Description.** create-review is structurally bound to `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed second position (consumer STEP 6a enforces anti-fungibility). comment-review has **no** such binding (deferred to ASM-014). Because comment-review is EXEMPT from the `autonomy_enabled` kill switch and its `ticket_id` is LLM-supplied (from the §3.4 dedup lookup), a genuine hard-floor verdict lets the exempt path execute `jr issue comment <arbitrary_ticket_id>` under `autonomy_enabled=false`. If the LLM mis-sets `ticket_id` (bug, or injection via crafted alert/ticket content) to a regular ticket, the kill-switch-exempt escalation path comments on a non-review ticket — broader than the "review ticket only" intent of the exemption. Impact is bounded (comment only, hard-floor required), and the risk is acknowledged as ASM-014-pending, hence MINOR.

**Suggested remediation.** Resolve ASM-014; if `jr issue comment --label` is supported, bind comment-review to a review-labeled command as with create-review. Until then, document explicitly that the comment-review kill-switch exemption is broader than "review ticket only," and consider requiring disposition-guard to confirm `ticket_id` corresponds to a review-labeled ticket before issuing a comment-review marker.

### P10-009 — Global `jira_project_key` vs multi-org; "multi-project retains per-org-key binding" claim has no config surface — MINOR

**Confidence: HIGH.**

**Anchor:** BC-6.01.001 PC#12 (lines 124-142 — activate prompts for and validates ONE `jira_project_key` in plugin state); BC-6.01.003 PC#1 (onboard-customer appends `[[orgs]]` with `org_slug`/`uuid`/`display_name` — **no** per-org `jira_project_key`); BC-3.01.001 line 298 and architecture-delta lines 1211-1212 ("Multi-project deployments retain full per-org-key binding via distinct project_key values").

**Description.** `jira_project_key` is a single global plugin-state value captured once at activation; `verdict.jira_project_key` is therefore the same value for every org. No BC provides a config surface to capture a per-org project key (onboard-customer, the per-org provisioning skill, does not collect one). Consequently the create-scope project-key binding cannot distinguish orgs in *any* current deployment — not merely the PRISM-DEMO single-project case. The repeated claim that "multi-project deployments retain full per-org-key binding" is aspirational and unsupported, and could mislead an implementer into believing per-org create-scope isolation is achievable by configuration when no such configuration exists.

**Suggested remediation.** Either (a) add a per-org `jira_project_key` field to onboard-customer (BC-6.01.003) and source `verdict.jira_project_key` per-org, then the multi-project claim becomes true; or (b) remove/soften the "multi-project deployments retain full per-org-key binding" claims in architecture-delta and BC-3.01.001 to state that per-org project-key binding is not implemented in v0.10.0.

---

## Observations (non-blocking)

- The dtu-assessment.md BATS example (`run claude -p "/monitoring-loop" --output-format json`, line 378-379) omits `--strict-mcp-config --mcp-config … --allowedTools …`; per ASM-004's own findings, prism MCP would not load headlessly with that invocation. It is clearly an illustrative snippet, but aligning it with the authoritative invocation would prevent copy-paste drift into real test setup.
- The asm-004 SUPERSEDED banners (lines 225-243, 267-298) are **consistent** with the authoritative invocation, which matches BC-10.01.001 Precondition #1 (lines 70-76) and the architecture-delta wrapper (lines 832-839) verbatim (`--allowedTools` list, no `--bare`, no `--dangerously-skip-permissions`, `< /dev/null`). No finding — verified intact.
- The D-DEC-005 carve-out narrowing (raw-table-only) was correctly NOT propagated to BC-5.01.001 / BC-9.01.001 / BC-4.05.001, and this is correct: none of those skills query `prism_sensor_health`, so their retained absolute org_slug rule is safe and stricter. No finding.

---

## Novelty Assessment

**Novelty: HIGH.** This pass concentrated on surfaces outside the 12 verified-intact invariants and produced findings not reducible to prior-pass rewording:
- P10-001 (CRITICAL) attacks the *trust basis* of the hard floor rather than its mechanics — prior passes hardened *how* the floor keys on severity/asset_type (ADV-F2-001) but never questioned that those fields are LLM-controlled and un-cross-validated. This is a genuine blind spot in the package's own O3 standing rule application.
- P10-002/P10-003 (MAJOR) attack the fail-loud chain at the *operator-observable boundary* and the *infra-failure branch* — prior passes verified fail-loud only at the internal marker/audit boundary (VP-HOOK-029) and closed the null-binding silent-drop (P8-001), but not the audit.log→cron gap or the marker-write-failure allow-without-marker regression.
- P10-004/P10-005/P10-007 are propagation/verification-asymmetry gaps caught by the Partial-Fix Regression Discipline axis (P9 fixes not fully propagated to sibling artifacts / test names).
These are substantive gaps, not nitpicks. The package has NOT converged: one CRITICAL (P10-001) and two MAJOR findings block. This is not a clean pass.

---

## Confirmed Invariants (carried forward + additions)

**Carried forward (re-spot-checked, intact this pass):**
1. Marker schema v2.1 authoritative block in sync (BC-3.03.001 §D-DEC-001 lines 430-467 / emitter WRITE_MARKER).
2. JSON-first dispatch precedes investigation-substring branch; `verdict-*.json` → 15-field class (BC-3.03.001 PC#1 Check 1).
3. Hard floors key on severity/asset_type (not confidence); `asset_type=unknown` is a separate explicit floor. *(Mechanics intact; but see P10-001 re: the trust basis of these fields.)*
4. STEP 4 (deny-the-Write under-label) precedes STEP 5 (kill switch); `autonomy_enabled` irrelevant to STEP 3-4 (BC-3.03.001 lines 305-347).
5. BC-10.01.001 EC-015/016/017/021 + canonical vectors carry review-marker semantics with negative assertions (lines 528-544).
6. Consumer iterative-consume ordering, audit path (`markers/audit.log`), base64 + control-char stripping intact (BC-3.01.001 lines 238-268).
7. Sensor-silence direction (`last_seen_ts < now()-24h`) consistent (BC-10.01.001 Inv#5, EC-006).
8. VP/SM namespaces collision-free (VP-SKILL, VP-HOOK-024-029, SM-32..SM-43).
9. STEP-3 HARD-FLOOR-UNBINDABLE deny present in both missing-binding branches with re-doc cap (BC-3.03.001 lines 236-303; BC-10.01.001 lines 311-345).
10. `structural_label_check` v2 quote-aware + backslash-escape tokenizer; `--label=` equals-form correctly scoped out (BC-3.01.001 lines 146-206).
11. VP roster sums to 31 (6 VP-HOOK + 25 VP-SKILL); VP-SKILL-052-063 finalized.
12. Review marker → unlabeled regular create blocked at consumer step 6a (BC-3.01.001 lines 211-216).

**Additions confirmed this pass:**
13. asm-004 SUPERSEDED banners consistent with the authoritative `--allowedTools` invocation, which matches BC-10.01.001 Pre#1 and the architecture-delta wrapper verbatim.
14. D-DEC-005 carve-out correctly propagated to BC-8.02.001 (Inv#2, PC carve-out note) and BC-10.01.001 (Inv#1 EXCEPTION); correctly NOT propagated to non-health-querying skills.
15. `jira_project_key` Stage-0 precondition present at both the wrapper defense-in-depth check (BC-10.01.001 Pre#9) and activate gate (BC-6.01.001 PC#12/EC-013) — livelock's most common trigger is gated at the wrapper. *(But the runtime livelock-abort artifact is not wired to the operator signal — P10-002.)*
16. Consumer create/create-review anti-fungibility is bidirectional and enforced at STEP 6a as the single load-bearing point for direction A (bash `[[ =~ ]]` non-tail-anchored — correctly documented, BC-3.01.001 line 31).
17. Never-auto-reopen-Closed is unconditional and VP-covered on both the update-jira (VP-SKILL-066) and monitoring-loop (VP-SKILL-062) paths.

**Newly identified as NOT-invariant (open defects):** hard-floor inputs are LLM-controlled without cross-validation (P10-001); operator-boundary fail-loud is unbridged/unvalidated (P10-002); marker-write-failure silent-drop on the review path (P10-003).
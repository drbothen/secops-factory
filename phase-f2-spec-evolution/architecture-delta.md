---
document_type: architecture-delta
producer: architect
version: "1.12"
date: 2026-07-21
input-hash: COMPUTE-AT-COMMIT
changelog:
  - "1.12 (2026-07-21): Pass-9 adversarial remediation (P9-001/005/007/008/009). A. D-DEC-001 STEP 6a backslash-escape tokenizer extension (P9-001 MAJOR): quote-aware tokenizer extended to handle \\\" in IN_DOUBLE (literal \", stay IN_DOUBLE) and \\' in UNQUOTED (literal ', no state toggle), matching bash tokenization; index-based iteration replaces for-char-in-cmd loop; jr --label=VALUE equals form confirmed NOT supported by jr CLI (jr issue create --help, 2026-07-21) — equals-form vector scoped OUT; escaped-quote differential-vs-bash attack vectors + paired mutants added for FV. B. D-DEC-005 sensor-metrics carve-out (P9-005 MINOR): explicit exemption added for prism_sensor_health metadata queries from the per-tenant raw-data org_slug isolation rule; grounded in brief §2.4 (SELECT * FROM prism_sensor_health without org_slug) and §3.6 (health metadata is not raw per-tenant security records); PO to propagate to BC-8.02.001. No HUMAN-GATE-CONFIRM required — brief is unambiguous. C. D-DEC-008 STEP 3 dedup-before-fallback obligation (P9-007 MINOR): comment-review fallback hint conditioned on mandatory re-run of §3.4 BLIND-SPOT/REVIEW-REQUIRED dedup query before switching to create-review; null ticket_id may be a dedup-lookup miss, not absence of ticket; blind switch risks D-DEC-004 duplicate-ticket violation; PO to propagate to BC-10.01.001. D. D-DEC-008 jira_project_key Stage-0 precondition + re-doc cap (P9-008 OBS): activate/onboard MUST gate on jira_project_key presence as a hard Stage-0 precondition before the monitoring loop is permitted to run; re-doc attempt cap set at max 3 HARD-FLOOR-UNBINDABLE denies per-verdict per loop run before loop emits operator-facing failure and exits that verdict path; PO to propagate to BC-6.01.001 (Stage-0 gate) + BC-10.01.001 (cap). E. O5 standing rule added to D-DEC-012 O3 table (P9-009 OBS): any hook that re-implements shell tokenization to make a security decision MUST carry a differential-vs-bash vector partition covering all shell-quoting classes the downstream CLI honors."
  - "1.11 (2026-07-21): Pass-8 adversarial remediation (P8-001..P8-004 + OBS). A. D-DEC-008 STEP 3 DENY-THE-WRITE for missing binding fields (P8-001 CRITICAL): both silent-allow branches replaced with HARD-FLOOR-UNBINDABLE deny (create-review + null jira_project_key; comment-review + null ticket_id) per D-DEC-012 clause 2; comment-review corrective reason includes fallback hint when jira_project_key is present (suggests create-review, consistent with STEP 4 required_token logic); non-termination bounded — one HARD-FLOOR-UNBINDABLE audit entry + one deny per re-doc attempt, no Jira write, no silent loop; mirrors STEP 4 non-termination analysis. B. D-DEC-001 STEP 6a quote-aware tokenizer (P8-002 MAJOR): split_on_whitespace replaced with state-machine tokenizer (UNQUOTED/IN_SINGLE/IN_DOUBLE states); hook receives raw command string with literal quotes (jq -r, no shell expansion); EC-024 reconciled — label-literal-in-quoted-summary → has_review_label=false → ALLOW. C. Generation table and STEP 6a ( |$) boundary correction (P8-003 MINOR): explicit note that bash regex is NOT tail-anchored; regular create pattern DOES match review-labeled create at step 5; anti-fungibility direction A enforced EXCLUSIVELY at step 6a (single point of failure — raises step 6a criticality). D. §8.18/§8.19 added: pass-8 PO propagation (BC-3.03.001 STEP 3 deny branches + test vectors; BC-3.01.001 quote-aware tokenizer + EC-023/024 corrections; BC-10.01.001 VP-Anchors footer + Cyberint operator note; BC-8.02.001 Cyberint note; prd-delta §1 VP roster + §5 version catch-up + changelog) and FV propagation (VP-HOOK-029 unbindable-deny vectors; P8-002 quote-aware false-deny vector + revert mutant; EC-023 step-5 correction). P8-OBS-1: SUPERSEDED banners at §8.12.1 item 2 and §8.13 item 1 (retired marker-upgrade mechanism). P8-OBS-2: D-DEC-013 Cyberint operator note (pre-ASM-008: 100% CRITICAL → review queue flood; PO to propagate to BC-8.02.001/BC-10.01.001)."
  - "1.10 (2026-07-21): Pass-7 adversarial remediation (ADV-F2-P7-001..P7-009). A. D-DEC-008 STEP 4 REDESIGN — DENY-THE-WRITE (P7-001 CRITICAL): the marker-upgrade approach from P5-001/P6-002 is REMOVED — P7-001 proved it structurally unsound (the hook cannot rewrite the loop's future Bash command; upgrade writes a marker the loop's own non-review jr command can never consume). DENY-AT-WRITE is the only deterministic lever at the point the LLM can still react. New STEP 4: hard-floor/Indeterminate verdict with non-review ticket_action_type (create/assign/comment/none) → disposition-guard DENIES the verdict Write with a structured machine-readable corrective reason (hard_floor_trigger, required_token, label_instruction) and writes UNDER-LABEL-DENIED audit entry. No marker issued; no Jira write occurs. The loop re-issues the verdict Write with the corrective token; on corrected Write STEP 3 issues the review marker normally. Non-termination: bounded fail-closed — the deny + audit entry ARE the loud failure. STEP 4 remains before STEP 5 kill switch. UNDER-LABEL-CORRECTED audit code RETIRED; replaced by UNDER-LABEL-DENIED. B. D-DEC-012 fail-loud invariant and O3 table updated to reflect deny-the-Write semantics. O3 table extended with O4 standing rule (P7-009): every 'never silently discarded' claim MUST have a VP asserting the consumer-boundary (jr authorization/execution) outcome, not an emitter-local artifact. C. D-DEC-001 consumer STEP 6a has_review_label fix (P7-005 MINOR): structural token detection (whitespace-separated token parse; --label must appear as a standalone token immediately preceding REVIEW-REQUIRED or BLIND-SPOT) replaces raw substring over full command; prevents false-deny of regular creates whose --summary contains the label literal string. D. D-DEC-013 Cyberint explicit conservative mapping (P7-006 MINOR): Cyberint row updated from ambiguous COMPUTE-AT-VALIDATION to explicit default CRITICAL + uncertainty_explicit naming the unvalidated mapping, mirroring the unrecognized-family rule; enum-valid and auditable from first Cyberint contact. E. ASM-014 symmetry obligation added (P7-008 OBS): when jr issue comment --label support is validated, the comment-review structural check MUST be added symmetrically with create-review. F. §8.16 added: pass-7 PO propagation (BC-3.03.001 STEP 4 redesign; BC-3.01.001 step-6a structural fix; BC-10.01.001 six stale locations + Iron Law + loop re-document obligation + Cyberint mapping + brief §3.9 version-pin refresh) and §8.17 FV propagation (VP-HOOK-029 end-to-end consumer-boundary re-scope + deny-path vectors + mutants; VP-SKILL-074 Cyberint partition; step-6a false-deny vector)."
  - "1.9 (2026-07-21): Pass-6 adversarial remediation (ADV-F2-P6-001..P6-009). A. Unified P6-001/P6-004 fix: create-review command_pattern now structurally distinct — `--label (REVIEW-REQUIRED|BLIND-SPOT)` encoded in FIXED second position after `--project <key>`; consumer adds STEP 6a anti-fungibility cross-check enforcing both directions; D-DEC-012 Alternatives Rejected updated (hook-side label enforcement NOW ADOPTED, reversing prior rejection — O3 standing rule mandates this is a security control that cannot live only in SKILL.md). P6-004 unified: per-org-key isolation infeasible under brief's single-PRISM-DEMO constraint; SEC_ORG_A/SEC_ORG_B examples removed; explicit downgrade documented (single-use + TTL + review-label binding provides cross-org protection). B. STEP reorder (P6-002 CRITICAL): hard_floor_applies() under-label upgrade (formerly STEP 5) moved BEFORE autonomy_enabled kill switch (formerly STEP 4); new STEP 4 = hard-floor/under-label upgrade, new STEP 5 = kill switch; EC-012 case (d) updated from silent-drop to upgrade-path semantics. C. Inv#11/VP-SKILL-065 carve-out language added to D-DEC-012 (P6-003 MAJOR): under autonomy_enabled=false, ZERO REGULAR (comment/create/assign) markers consumed and ZERO regular jr writes; create-review/comment-review escalation writes for genuine hard-floor verdicts still execute per Option A. D. D-DEC-013 added: severity normalization named step (P6-005 MAJOR) — per-sensor-family mapping table (CrowdStrike numeric 1-100, Armis/Claroty risk bands, CVSS floats); unrecognized → CRITICAL with uncertainty_explicit; Cyberint COMPUTE-AT-VALIDATION per ASM-008. E. D-DEC-004 BLIND-SPOT dedup updated (P6-006 MINOR): ticket_action_type now create-review (new ticket) / comment-review (open-ticket dedup); D-DEC-012 exempt-marker path cited. F. D-DEC-002 late-event fail-loud added (P6-007 MINOR): events older than watermark-GRACE emit explicit auditable finding; never silent drop; ASM-008 gate noted. G. ASM-009 elevated to BLOCKING pre-Wave-3 deliverable with explicit go/no-go criteria (P6-008 MINOR); marker design marked CONDITIONAL not RESOLVED. H. D-DEC-012 O3 standing rule table extended with consumer-consumption, control-flow-ordering, and trust-boundary-crossing rows (P6-009 OBS). I. §8.14 added: pass-6 PO propagation (BC-3.01.001 consumer step 6a, BC-3.03.001 STEP reorder + pattern, BC-10.01.001 Inv#11 carve-out + VP-SKILL-065 re-scope + severity normalization) and §8.15 FV propagation (VP-HOOK-029 FINALIZE+expand, VP-SKILL-065 re-scope, VP-SKILL-074 severity-normalization, VP-SKILL-073 late-event-drop, consumer-fungibility mutants SM-36/SM-37). Namespace correction (2026-07-21): VP-SKILL-072 collided with existing FINALIZED VP (first-run 24h lookback) — reallocated to VP-SKILL-074 for severity normalization. SM-33/SM-34 collided with occupied pass-4 sentinels — reallocated to SM-36/SM-37 for consumer STEP 6a anti-fungibility mutants."
  - "1.8 (2026-07-21): Adversarial pass-5 remediation (ADV-F2-P5-001..P5-003) + human-gate confirmation. A. D-DEC-001 authoritative schema block (P5-003 MAJOR): updated to true D-DEC-012 superset — authorized_operations now includes create-review/comment-review tokens; disposition.verdict now includes Indeterminate; disposition.ticket_action_type sub-field added; O3 schema-sync obligation codified. B. D-DEC-008 STEP 3 review-exemption (P5-002 MAJOR): gated on hook-computed hard_floor_applies(verdict); create-review/comment-review tokens no longer bypass kill switch or hard floor for non-hard-floor verdicts; over-labeled non-hard-floor verdicts emit allow-without-marker at STEP 3; O3 standing rule codified. C. D-DEC-008 STEP 5 fail-loud (P5-001 CRITICAL): silent emit-allow without marker on hard_floor_applies()=true is PROHIBITED; replaced with deterministic upgrade to create-review (ticket_id null) or comment-review (ticket_id present); missing project_key → explicit error artifact + deny; audit entry written on every upgrade. D. D-DEC-012 fail-loud invariant updated: hook now enforces it deterministically (not delegated to SKILL.md). E. O3 standing rule codified in D-DEC-012. F. §8.12 added: pass-5 PO propagation (BC-3.03.001 STEP 3+5 updates, BC-10.01.001 ticket_action_type under-label semantics) and FV propagation (VP-HOOK-029 re-scope, SM-32 re-scope). G. Kill-switch/brief-§3.9 conflict RESOLVED 2026-07-21: human operator confirmed Option A — create-review/comment-review markers execute under autonomy_enabled=false for genuine hard-floor verdicts; all §8.12 HOLD markers lifted; brief §3.9 amendment delegated to PO."
  - "1.7 (2026-07-21): Version-ref sync to frozen pass-4 BC versions (BC-3.01.001 v1.17, BC-3.03.001 v1.13, BC-4.02.001 v1.8, BC-5.01.001 v1.8, BC-6.01.001 v1.5, BC-10.01.001 v1.9). §8.6 current-live annotation updated. §8.10 pass-4 propagation items 1–11 marked COMPLETE."
  - "1.6 (2026-07-20): Adversarial pass 4 remediation (ADV-F2-P4-001..012). A. D-DEC-008 dispatch-precedence fix (P4-001 CRITICAL): JSON-first dispatch — file ending in .json or content parsing as JSON (jq empty) routes to verdict-class 15-field path REGARDLESS of 'investigation' substring in path; prevents canonical path artifacts/investigations/verdict-*.json being misrouted to markdown branch; BC-3.03.001 PC#1/2/3 must be rewritten (PO). B. D-DEC-008 anchored create pattern (P4-002 CRITICAL): removed `.*` before --project; pattern is now `^jr (--output json )?issue create --project <key>( |$)`; --project must be first flag after issue create (Iron Law); trailing ( |$) prevents PROD matching PRODUCTION; BC-3.03.001 must adopt pattern (PO). C. D-DEC-012 (new) review-ticket path (P4-004 MAJOR): ticket_action_type `create-review` and `comment-review` as restricted marker types for hard-floor verdict surfacing; exempt from hard-floor no-marker rule; also exempt from autonomy_enabled kill switch (escalation ≠ autonomous triage); fail-loud invariant: hard-floor verdicts never silently dropped. D. D-DEC-008 autonomy_enabled operational field (P4-005 MAJOR): add autonomy_enabled to verdict JSON as non-ICD-203 operational metadata field; disposition-guard reads directly from verdict file (not delegated to monitoring-loop LLM); default-false conservative. E. D-DEC-008 enum-membership validation (P4-006 MAJOR): fail-closed deny on non-member values for severity/asset_type/disposition/sensor_health_status/ticket_action_type/confidence before hard-floor check; BC-3.03.001 PC#3 must add enum-membership validation (PO). F. Various minors: audit-log control-char sanitization for ticket_id/org_slug/op (P4-010); watermark WRITE validation tightened to full RFC3339 UTC-Z (P4-O1); marker-store cleanup mechanism note (P4-O2); grace-window drop trade-off note (P4-O3); budget-exhaustion behavior NFR note (P4-011). G. §5.4 ADV-F2-P2-007 audit-path note marked RESOLVED (P4-009) — fix was applied at BC-3.01.001 v1.14."
  - "1.5 (2026-07-20): version-ref sync to frozen pass-3 BC versions"
  - "1.4 (2026-07-20): Adversarial pass 3 remediation (ADV-F2-P3-001..008). A. D-DEC-008 hard_floor_applies(): asset_type=unknown added as explicit hard-floor member — closes gap between BC-10.01.001 v1.5 Inv#10 policy (which already includes unknown) and the pseudocode (which did not); BC-3.03.001 Inv#4 and VP-HOOK-026 must add the unknown leg (PO/FV obligations recorded in §8.8/§8.9). B. D-DEC-008 create-scope org-binding: create command_pattern now encodes Jira project key (from verdict.jira_project_key, a new non-ICD-203 operational metadata field) defeating cross-org marker fungibility; emitter pseudocode updated; command_pattern generation table updated; BC-3.03.001 create emitter branch must add project key encoding (PO). C. D-DEC-008 artifact-class branching: investigation markdown enforces 12 ICD-203 fields; verdict JSON enforces 15; BC-3.03.001 PC#2 currently says 15 for investigation markdown — this is an erratum, correct value is 12 (BC-5.01.001 12-field citation is CORRECT); PO must fix BC-3.03.001 PC#2 and align BC-5.01.001 version refs. D. D-DEC-002 WRITE_WATERMARK(): monotonic max(stored, ts) guard added — prevents watermark regression on in-grace-only runs; reconciled with READ grace-window subtraction so grace window cannot drift backwards. E. D-DEC-008 verdict-file-path naming convention: monitoring-loop Stage 7 MUST write to a path containing 'verdict' as a substring; fast-path-allow fires otherwise; BC-10.01.001 needs explicit precondition (PO). F. D-DEC-011 (new): confidence float→enum contract — assess-priority outputs BOTH float posterior AND mapped enum; monitoring-loop uses enum for verdict field #2; canonical thresholds: high ≥ 0.75, medium ≥ 0.40, low < 0.40; PO must align BC-4.05.001 and BC-10.01.001 Inv#9 field #2 definition."
  - "1.3 (2026-07-20): Adversarial pass 2 remediation (ADV-F2-P2-001..007). A. D-DEC-008: Document-before-action ordering invariant added — Stage 7 DOCUMENT (verdict Write → disposition-guard fires → marker emitted) MUST precede Stage 8 TICKET ACTION (jr Bash → require-review fires → marker consumed). Corrects the inverted BC-10.01.001 Invariant #14 defect (had Stage 7 TICKET ACTION / Stage 8 DOCUMENT — ADV-F2-P2-001 CRITICAL). B. D-DEC-001 consumer: replaced strict >1-candidate ambiguous-deny with iterative-consume (sorted by issued_at_utc ASC; first successful atomic rename = allow; anti-forgery preserved via single-use rename — ADV-F2-P2-003 MAJOR). C. §5.1 security invariant rewritten to canonical v2.0 schema fields: ¬(now()>M.expires_at_utc) ∧ M.issued_at_utc≤now() ∧ single-use-via-atomic-rename ∧ anchored_match; removed stale M.used/M.ttl_seconds (v1.0 fields removed at schema v2.0). §5.4 stale 'pending next version bump' corrected — BC-3.01.001 v1.13 already applied command_b64 + Inv#2 (ADV-F2-P2-004 MAJOR). D. D-DEC-008: Stage 3 CATEGORIZE (MITRE technique mapping) must execute before known-FP EC-009 auto-close; fast-path fields 13/14 populated from raw sensor event at Stage 1 INGEST, not Stage 5 SCORE (ADV-F2-P2-002 MAJOR). E. D-DEC-001 audit-log canonical path confirmed as ${CLAUDE_PLUGIN_DATA}/markers/audit.log (matches C-29); BC-3.01.001 must align from ${CLAUDE_PLUGIN_DATA}/audit.log (ADV-F2-P2-007 MEDIUM). F. §8: live BC version refs updated; pass-2 PO PROPAGATION LIST added (§8.6); formal-verifier list added (§8.7 — ADV-F2-P2-005/P2-006/P2-008/P2-009)."
  - "1.2 (2026-07-20): Adversarial pass 1 remediation (ADV-F2-001..015). A. D-DEC-002: watermark lookback-overlap grace window (GRACE=5m, configurable) + Jira-first dedup + prism _time RFC3339 UTC-Z normalization required. B. D-DEC-001: canonical marker schema v2.0 — removed ttl_seconds, added expires_at_utc (absolute, computed at emit); TTL raised from 30s to 120s with latency-budget rationale; audit.log command field shell-safe encoded (base64); added rename-fail → deny step to consumer pseudocode. C. D-DEC-001/D-DEC-008: add severity + asset_type as mandatory verdict fields (12→14); disposition-guard hard-floor checks key on severity NOT confidence. D. D-DEC-008: ticket-bound command_pattern for comment/assign; create-scoped (no ticket_id; bounded by org+single-use+TTL); create/assign emitter branches designed; emitter scope selected via verdict.ticket_action_type (field 15 → 15 total mandatory fields after D fix). E. §5.3: field count corrected to 15; VP anchors corrected (VP-HOOK-025=field completeness, VP-HOOK-024=marker soundness). F. §5.4: stale BC version refs updated (v1.11→v1.12, v1.6→v1.7). G. PO PROPAGATION LIST added."
  - "1.1 (2026-07-20): ASM-004 PARTIAL verdict received — finalized D-DEC-003 (--strict-mcp-config --mcp-config path; activate writes prism.mcp.json; Wave 7 unblocked); added D-DEC-010 (unattended permission model: --allowedTools scoped allowlist); updated ASM-004 to RESOLVED-BY-DESIGN; added DTU CI surface items (prism-dtu-demo-server download path, --config-dir isolation constraint, D-DEC-009 reconciliation)."
cycle: v0.10.0-feature-prism-integration
status: draft
inputs:
  - .factory/phase-f1-delta-analysis/delta-analysis.md
  - .factory/phase-f1-delta-analysis/impact-boundary.md
  - .factory/feature/prism-integration-handoff-brief.md
  - .factory/phase-0-ingestion/recovered-architecture.md
  - .factory/phase-0-ingestion/project-context.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
  - .factory/phase-0-ingestion/conventions.md
  - .factory/research/soc-analyst-workflow-2026.md
asm_004_status: PARTIAL/RESOLVED-BY-DESIGN — --strict-mcp-config --mcp-config path confirmed reliable; settings.json mcpServers route unconfirmed for headless; activate now writes dedicated ~/.claude/prism.mcp.json
asm_004_validation: .factory/phase-f2-spec-evolution/asm-004-validation.md
---

# Architecture Delta — v0.10.0-feature-prism-integration (F2)

> **Scope:** Resolves all open F2 decisions (D-DEC-001 through D-DEC-009). Extends the
> existing C-1..C-24 component map with six new component IDs (C-25..C-30). Carries all
> architectural authority for the prism-integration cycle. Does NOT modify any existing
> `.factory/phase-0-ingestion/` artifacts — the delta doc carries changes; shard sync
> happens at F2 integration by state-manager.
>
> **Critical dual-track:** D-DEC-003 (monitoring-loop packaging) remains dual-tracked
> pending ASM-004 empirical validation. All other decisions are final.

---

## Decision Summary Table

| ID | Status | Decision (one-liner) |
|----|--------|---------------------|
| D-DEC-001 | **RESOLVED** | Filesystem marker at `${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json`; disposition-guard emits, require-review reads + atomically invalidates; 120s TTL via absolute `expires_at_utc`; single-use; ticket-bound command_pattern for comment/assign; operation-scoped for create; scoped `authorized_operations` field; audit.log command base64-encoded |
| D-DEC-002 | **RESOLVED** | ISO 8601 plain-text file at `${CLAUDE_PLUGIN_DATA}/watermarks/<org_slug>/<sensor_id>`; atomic write via temp+rename; advisory `mkdir`-based lockfile; first-run uses 24h lookback; lookback-overlap grace window (GRACE=5m, configurable) to catch late/out-of-order OCSF events; Jira-first dedup prevents double-ticketing on re-processed events; prism `_time` must be RFC3339 UTC-with-Z (validated/normalized before comparison) |
| D-DEC-003 | **RESOLVED** | SKILL.md monitoring-loop invoked by cron wrapper: `claude -p "/monitoring-loop" --strict-mcp-config --mcp-config ~/.claude/prism.mcp.json --output-format json < /dev/null`; activate writes prism block to BOTH `~/.claude/settings.json` (interactive) AND `~/.claude/prism.mcp.json` (cron); Wave 7 unblocked |
| D-DEC-004 | **RESOLVED** | One open BLIND-SPOT ticket per `(org_slug, sensor_id)` pair; append comment while open; create new only if no open ticket; never auto-reopen closed |
| D-DEC-005 | **RESOLVED (F1)** | Cross-tenant correlation is prism-side architecture; plugin obligation = org_slug query scoping invariant in BC-10.01.001 only |
| D-DEC-006 | **RESOLVED** | Skill named `sensor-metrics` (dir: `skills/sensor-metrics/`, command: `commands/sensor-metrics.md`) to avoid namespace confusion with existing `generate-metrics` |
| D-DEC-007 | **RESOLVED** | Shell helper scripts co-located under `skills/<name>/` (e.g., `skills/activate/activate-mcp-config.sh`) |
| D-DEC-008 | **RESOLVED** | Marker carries `authorized_operations: [string]` scope field; comment/create/assign each require a separately scoped marker; ticket-bound command_pattern for comment/assign; create scope has no ticket_id (bounded by org+single-use+TTL); emitter selects scope from verdict.ticket_action_type (field 15); hard floors (§3.9) unconditionally prevent marker issuance and key on verdict.severity + verdict.asset_type (NOT confidence); verdict schema: 15 mandatory fields (12 ICD-203 + severity + asset_type + ticket_action_type) |
| D-DEC-009 | **RESOLVED** | Tavily MCP is `recommended` with explicit fallback to Perplexity-only enrichment; monitoring-loop does not fail if Tavily unavailable |
| D-DEC-010 | **RESOLVED** | Unattended permission model: `--allowedTools` scoped allowlist (prism/tavily/perplexity MCP tools + Bash + Write + Read) — NOT `--dangerously-skip-permissions`; `--bare` explicitly forbidden (would disable require-review hook); require-review hook remains the Jira auth gate |
| D-DEC-011 | **RESOLVED** | Confidence float→enum contract: assess-priority outputs BOTH a float posterior (0.0–1.0) AND a mapped enum `{high,medium,low}`; monitoring-loop uses the enum for verdict field #2; canonical thresholds: high ≥ 0.75, medium ≥ 0.40 and < 0.75, low < 0.40 |
| D-DEC-012 | **RESOLVED** | Review-ticket surfacing path for hard-floor verdicts: `create-review` and `comment-review` restricted marker types; exempt from hard-floor no-marker rule and autonomy_enabled kill switch; fail-loud invariant — hard-floor verdicts never silently dropped; BC-10.01.001 Inv#10 must be narrowed (PO); BC-3.01.001 must map create-review/comment-review to authorized operations (PO) |

---

## 1. Decision Records (ADR-style)

### D-DEC-001 — Review-Approval Marker Mechanism (CRITICAL)

#### Context

BC-3.01.001 (v1.10) blocks `jr issue comment/edit/move/assign/create` unconditionally
(SEC-001, SEC-002, Invariant #5). DI-013 (human-approved deferral) required a
monitoring-loop-capable exception path. The exception must not reintroduce a SEC-009-class
bypass. SEC-009 history: two prior bypasses occurred via evaluation-order errors and
unanchored substring matching. Any marker mechanism must be impervious to both failure modes.

The marker mechanism must satisfy eight properties (brief §D-005 requirements, amplified by
R-002): (a) time-bounded TTL, (b) single-use, (c) stored outside SEC-001 injection surface,
(d) anchored matching only, (e) scoped per-operation, (f) fail-closed on parse/validation
error, (g) auditable, (h) disposition-guard is the sole emitter gate.

#### Decision

**Filesystem marker files stored at `${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json`.**

Disposition-guard is the sole emitter. It issues a marker only after all ICD-203 mandatory
fields in the verdict file have been validated. Require-review scans the marker directory,
finds a matching unexpired candidate, atomically invalidates it via `mv` rename, then emits
allow.

**Canonical Marker JSON schema (v2.0):**

> **This is the single authoritative schema. BC-3.01.001, BC-3.03.001, and BC-10.01.001
> all cite this schema. Any divergence in a BC is a BC authoring error — fix the BC, not
> this document.**

```json
{
  "marker_id": "<uuid-v4>",
  "issued_at_utc": "<ISO-8601 UTC with Z suffix, e.g. 2026-07-20T14:30:00.000Z>",
  "expires_at_utc": "<ISO-8601 UTC with Z suffix; = issued_at_utc + 120 seconds>",
  "issued_by": "disposition-guard",
  "ticket_id": "<jira-ticket-id-string | null>",
  "org_slug": "<org-slug-string>",
  "authorized_operations": ["comment"] | ["create"] | ["assign"] | ["create-review"] | ["comment-review"],
  "command_pattern": "<anchored regex — see D-DEC-008 generation table>",
  "disposition": {
    "verdict": "TP|FP|BTP|Indeterminate",
    "severity": "LOW|MEDIUM|HIGH|CRITICAL",
    "asset_type": "<asset_type_string>",
    "ticket_action_type": "<action_token — comment|create|assign|none|create-review|comment-review; for audit trail>"
  }
}
```

**Schema v2.0 changes from v1.0 (ADV-F2-003 remediation):**
- `ttl_seconds` REMOVED. Consumer compares `expires_at_utc` to `now()` directly, eliminating
  read-side clock-skew arithmetic and the hardcoded-30s consumer path.
- `expires_at_utc` ADDED (absolute expiry timestamp, computed at emit time; = issued_at_utc + 120s).
- `authorized_operations` values are operation tokens: `"comment"`, `"create"`, `"assign"`.
  Never multi-element (each Jira action is a distinct marker issuance).
- `disposition.severity` ADDED: `LOW|MEDIUM|HIGH|CRITICAL` — required for disposition-guard
  hard-floor check (keyed on severity, NOT confidence — ADV-F2-001 fix).
- `disposition.asset_type` ADDED: string from the verdict's asset classification — required for
  critical-asset hard-floor check.
- `command_pattern` is ticket-bound for comment/assign; operation-scoped for create (see D-DEC-008).

**Schema v2.1 additions (ADV-F2-P5-003 remediation — synchronizing with D-DEC-012 superset):**

The v2.0 block above was not updated when D-DEC-012 extended the schema. v2.1 corrects that lag:

- `authorized_operations` EXTENDED: `"create-review"` and `"comment-review"` token values added.
  These restricted marker types were introduced at D-DEC-012 for hard-floor verdict surfacing and
  were reflected in the emitter WRITE_MARKER block and the command_pattern generation table, but
  inadvertently omitted from this authoritative §D-DEC-001 block. Implementers following this block
  as source of truth would build a validator rejecting review tokens, reintroducing the P5-001
  silent-discard path by construction.
- `disposition.verdict` EXTENDED: `"Indeterminate"` value added. An Indeterminate verdict
  triggers hard_floor_applies(); the marker's disposition sub-object must represent the full
  verdict enum to preserve audit fidelity.
- `disposition.ticket_action_type` ADDED: records the action token written by the emitter
  WRITE_MARKER block (which already included `ticket_action_type: action` since D-DEC-012);
  carried in the marker for audit trail purposes.

**O3 Schema-Sync Obligation (standing rule, ADV-F2-P5-003):**
This §D-DEC-001 authoritative block MUST be updated synchronously with every schema extension
in D-DEC-008, D-DEC-012, or any future decision record that modifies the marker schema. The
"fix the BC, not this document" directive governs divergence errors in downstream BCs; it does
NOT authorize this block drifting behind its own sibling D-DEC sections. An implementer reading
this block as the single source of truth must never encounter a schema that diverges from the
emitter's WRITE_MARKER block in D-DEC-008.

**TTL: 120 seconds — latency-budget rationale (ADV-F2-011 remediation):**

The empirically observed latency budget for the Write→Bash chain is:
- disposition-guard hook execution: ~50–200ms
- LLM decision latency (hook returns → monitoring-loop skill decides next tool call): 2–30s typical;
  tail cases (complex ICD-203 verdict construction, multi-org runs) measured at 60–90s in comparable
  skill workflows
- Bash tool scheduling overhead: 0–5s
- **Total observed range: 2–95s; 99th percentile estimate: ~90s**

30s TTL provided zero safety margin against the 90th-percentile tail. 120s provides a 1.3× safety
factor over the 90s tail case while remaining small enough that a leaked marker poses negligible risk
(expires in 2 minutes maximum). Wave 3 MUST add a latency measurement test that records actual
disposition-guard-Write → require-review-Bash time per run and fails if the 95th percentile exceeds
60s (half the TTL). This measurement data gates any future TTL reduction.

**`--output json` handling in command_pattern (ADV-F2-003 canonical form):**

command_pattern includes the optional `--output json` prefix already (`^jr (--output json )?issue ...`).
This covers both the plain `jr issue comment` form and the `jr --output json issue comment` form that
the monitoring-loop may use for structured output. The optional group is compiled into the pattern at
marker issuance time by disposition-guard — never supplied by the user or derived from Jira content.

The `command_pattern` field is an anchored regex (^-prefixed). require-review applies it
via `[[ "$COMMAND" =~ $PATTERN ]]` (Bash) / `-match` (PowerShell). The pattern is
generated by disposition-guard at issuance time from `authorized_operations` and
`ticket_id` — it is never supplied by the user or derived from Jira ticket content.

**Hook validation algorithm (pseudocode — require-review.sh) [v2.0 — updated for ADV-F2-003/ADV-F2-013/ADV-F2-014]:**

```
FUNCTION validate_marker(command):
  marker_dir = "${CLAUDE_PLUGIN_DATA}/markers"
  candidates = []
  expired = []

  FOR each file F in marker_dir/*.marker.json:
    # path-safety: reject any basename containing ".." or "/"
    basename_F = basename(F)
    IF contains(basename_F, "..") OR contains(basename_F, "/"):
      CONTINUE           # path-traversal guard; fail-closed

    json = parse_json(F)
    IF json is invalid:
      CONTINUE           # fail-closed: skip malformed files

    issued_at = parse_iso8601(json.issued_at_utc)
    IF issued_at is invalid OR issued_at > now():
      expired.append(F)  # future-dated = adversarial signal; expire it
      CONTINUE

    # ADV-F2-003: check expires_at_utc (absolute); no ttl_seconds arithmetic
    expires_at = parse_iso8601(json.expires_at_utc)
    IF expires_at is invalid OR now() > expires_at:
      expired.append(F)  # TTL expired
      CONTINUE

    # NOTE: json.used check removed — .used-renamed files never appear in *.marker.json
    # glob (glob only matches *.marker.json; .marker.json.used files are excluded).
    # The atomic rename IS the single-use enforcement mechanism. Dead-code noted (ADV-F2-018).

    IF NOT anchored_match(json.command_pattern, command):
      CONTINUE           # wrong operation scope or wrong ticket_id (EC-022)

    # ── STEP 6a: Consumer anti-fungibility cross-check (ADV-F2-P6-001; P7-005/P8-002 structural fix) ──
    # create-review and create markers must not be fungible in either direction:
    # - A create-review marker cannot authorize a command that lacks --label REVIEW-REQUIRED|BLIND-SPOT
    # - A create marker cannot authorize a command that carries a review label
    # "has_review_label" is a STRUCTURAL property: --label must appear as a standalone flag token,
    # not as a substring anywhere in the command (including attacker/LLM-influenceable --summary text).
    #
    # P8-003 CLARIFICATION: The regular create command_pattern `( |$)` boundary is NOT tail-anchored.
    # A review-labeled `jr issue create --project KEY --label REVIEW-REQUIRED ...` PASSES step 5
    # (bash `[[ =~ ]]` matches the prefix up to the space after KEY). `( |$)` guards ONLY against
    # project-KEY prefix extension (P4-002 purpose; PROD does not match PRODUCTION). Anti-fungibility
    # direction A (regular create marker cannot authorize review-labeled command) is enforced HERE,
    # at step 6a, via structural_label_check — NOT at step 5. Step 6a is the SOLE enforcement point
    # for this invariant; its correctness (P8-002 quote-aware tokenizer) is load-bearing.
    #
    # ADV-F2-P7-005 FIX — STRUCTURAL TOKEN DETECTION; P8-002 FIX — QUOTE-AWARE TOKENIZER;
    # P9-001 FIX — BACKSLASH-ESCAPE EXTENSION:
    # P7-005 fix specified split_on_whitespace, which is still defective:
    # The hook receives tool_input.command as a RAW command string via `jq -r '.tool_input.command'`
    # (require-review.sh:45) — literal quote characters ARE present; shell has NOT expanded them.
    # For `jr issue create --project KEY --summary "rule --label REVIEW-REQUIRED fired"`:
    #   split_on_whitespace yields [..., '"rule', '--label', 'REVIEW-REQUIRED"', ...]
    # `--label` IS a standalone token in the naive split → has_review_label=true → false-deny STILL
    # FIRES with split_on_whitespace. Quote-aware tokenizer (P8-002) keeps quoted regions together.
    #
    # P9-001 DIVERGENCE FROM BASH — two residual input classes (P8-002 did NOT fix):
    # (1) `\"` inside IN_DOUBLE: current tokenizer exits double-quote state (wrong). Bash: `\"`
    #     is an escaped `"` — literal `"` added to the string, double-quote state STAYS.
    #     Attack vector: `jr issue create --project KEY --summary "normal\"" --label REVIEW-REQUIRED`
    #     Buggy tokenizer: `\"` in IN_DOUBLE → exits IN_DOUBLE at `\"` → next `"` starts a NEW
    #     IN_DOUBLE region containing ` --label REVIEW-REQUIRED` → has_review_label=FALSE (label hidden!)
    #     → regular create marker would authorize this command → SECURITY BYPASS.
    #     Fixed tokenizer: `\"` in IN_DOUBLE → stays IN_DOUBLE, adds `"` to token body; only the
    #     real closing `"` ends the double-quote region → ` --label REVIEW-REQUIRED` is OUTSIDE
    #     the double-quoted summary → has_review_label=TRUE → regular create marker DENIED ✓.
    # (2) `\'` in UNQUOTED: current tokenizer enters IN_SINGLE state (wrong). Bash: `\'` outside
    #     quotes is an escaped `'` — literal `'` added to token, no state toggle.
    #     Practical impact: low (jr does not commonly emit `\'` outside quotes), but divergence
    #     closes the differential-vs-bash surface completely.
    #
    # P9-001 REALITY CHECK — jr --label= equals form:
    # The finding also asked whether jr honors `--label=REVIEW-REQUIRED` (equals form).
    # Confirmed via `jr issue create --help` (2026-07-21): jr only supports `--label <LABEL>`
    # (space-separated, repeatable). The `--label=VALUE` equals form is NOT supported.
    # Consequence: the monitoring loop NEVER emits `--label=VALUE`; the equals-form vector is
    # SCOPED OUT of this fix. The fix addresses the escaped-quote class only.
    #
    # QUOTE-AWARE TOKENIZER v2 (bash implementable, index-based to support lookahead):
    # Pseudocode for structural_label_check(cmd):
    #   state = UNQUOTED
    #   cur_token = ""
    #   tokens = []
    #   i = 0
    #   while i < len(cmd):
    #     char = cmd[i]
    #     if state == UNQUOTED:
    #       if char == '\\' AND i+1 < len(cmd):       # P9-001: backslash in UNQUOTED
    #         i += 1
    #         cur_token += cmd[i]   # next char is literal (e.g., \' → ', \" → "); NO state toggle
    #       elif char == "'":   state = IN_SINGLE   # open single-quote; don't add quote char to token
    #       elif char == '"': state = IN_DOUBLE     # open double-quote; don't add quote char to token
    #       elif char is whitespace:
    #         if cur_token != "": tokens.append(cur_token); cur_token = ""
    #       else: cur_token += char
    #     elif state == IN_SINGLE:
    #       if char == "'": state = UNQUOTED        # close single-quote; don't add quote char
    #       else: cur_token += char                 # all chars inside single-quotes → literal
    #                                               # (backslash is literal inside single-quotes —
    #                                               #  UNCHANGED from P8-002; no escaping in bash single-quotes)
    #     elif state == IN_DOUBLE:
    #       if char == '\\' AND i+1 < len(cmd):    # P9-001: backslash in IN_DOUBLE
    #         next_char = cmd[i+1]
    #         if next_char == '"':
    #           cur_token += '"'    # \" in double-quotes → literal ", STAY IN_DOUBLE
    #           i += 1
    #         elif next_char == '\\':
    #           cur_token += '\\'   # \\ in double-quotes → literal \, STAY IN_DOUBLE
    #           i += 1
    #         else:
    #           cur_token += char   # other \X in double-quotes: backslash is literal char;
    #                               # next char processed on next iteration (bash behavior)
    #       elif char == '"': state = UNQUOTED      # close double-quote; don't add quote char
    #       else: cur_token += char                 # all other chars inside double-quotes → token body
    #     i += 1
    #   if cur_token != "": tokens.append(cur_token)   # flush final token
    #   for i in range(len(tokens) - 1):
    #     if tokens[i] == "--label" AND tokens[i+1] in {"REVIEW-REQUIRED", "BLIND-SPOT"}:
    #       return True
    #   return False
    #
    # EC-024 RECONCILIATION (UNCHANGED — still valid under v2 tokenizer):
    # For cmd = `jr issue create --project PRISM-DEMO --summary "rule matched literal --label REVIEW-REQUIRED in alert payload"`:
    # - Tokenizer enters IN_DOUBLE at the `"` before "rule"; all chars through closing `"` → --summary token body
    # - Token sequence: [jr, issue, create, --project, PRISM-DEMO, --summary,
    #                    rule matched literal --label REVIEW-REQUIRED in alert payload]
    # - `--label` is NOT a standalone token → has_review_label=false → ["create"] marker consumed → ALLOW
    # EC-024 is internally consistent: label-literal-in-quoted-summary → has_review_label=false → ALLOW.
    #
    # FV note (P8-002): false-deny vector (UNCHANGED): quoted-summary with literal label must produce
    # ALLOW with ["create"] marker; revert mutant = "revert to non-quote-aware split_on_whitespace"
    # → same input produces has_review_label=true → false DENY. Separately killable from P7-005 mutant.
    #
    # FV note (P9-001) — NEW DIFFERENTIAL-VS-BASH VECTOR PARTITION:
    # Partition 1 (escaped-quote hiding a real label — SECURITY-CRITICAL):
    #   Input: `jr issue create --project KEY --summary "normal\"" --label REVIEW-REQUIRED`
    #   Buggy (P8-002 tokenizer): exits IN_DOUBLE at `\"` → `--label REVIEW-REQUIRED` hidden in
    #     second IN_DOUBLE region → has_review_label=FALSE → regular create marker ALLOWS (security bypass)
    #   Fixed (P9-001 tokenizer): `\"` stays IN_DOUBLE → token body = `normal"`; real closing `"` ends
    #     IN_DOUBLE; `--label REVIEW-REQUIRED` is a standalone token → has_review_label=TRUE → regular
    #     create marker DENIED ✓
    #   Paired mutant: "revert P9-001 backslash-escape handling — treat `\"` in IN_DOUBLE as quote-close
    #     (pre-P9-001 behavior)" → assert above input produces has_review_label=FALSE (mutant dies when
    #     fixed tokenizer produces has_review_label=TRUE). SEPARATELY killable from P8-002 mutant.
    # Partition 2 (unquoted backslash-escaped quote — bash parity):
    #   Input: `jr issue create --project KEY \'--label REVIEW-REQUIRED\' --summary normal`
    #   (Pathological input; verifies UNQUOTED backslash handling matches bash)
    #   Fixed: `\'` in UNQUOTED → literal `'` consumed, no IN_SINGLE toggle; rest of `--label` continues
    #     as a single token `'--label` (note: `'` is part of the token body, NOT a quote delimiter)
    #   has_review_label: `'--label` != `--label` → FALSE → correct (the attacker cannot use `\'`
    #     to hide a label from outside-quote context either)
    # Partition 3 (equals-form — SCOPED OUT):
    #   `--label=REVIEW-REQUIRED` is NOT emitted by jr CLI (jr only supports space-separated form).
    #   No test required. Note in VP: "equals-form vector scoped out; jr CLI does not support
    #   --label=VALUE as of 2026-07-21 (jr issue create --help confirmation)."
    #
    # Note: comment/comment-review structural check pending ASM-014 (jr issue comment --label support);
    #       current guard for comment-review: ticket_id binding + Iron Law.
    has_review_label = structural_label_check(command)   # P8-002: quote-aware tokenizer, not split_on_whitespace
    IF json.authorized_operations == ["create-review"]:
      IF NOT has_review_label:
        CONTINUE         # EC-023: review marker requires review-labeled command (anti-fungibility)
    IF json.authorized_operations == ["create"]:
      IF has_review_label:
        CONTINUE         # EC-023: regular create marker cannot authorize a review-labeled command

    candidates.append({file: F, json: json})

  # Clean up expired files (best-effort; do not block on failure)
  FOR each F in expired:
    mv F "${marker_dir}/$(basename F).expired"

  IF len(candidates) == 0:
    emit_deny("No valid unexpired marker found for this operation")
    RETURN DENY

  # ADV-F2-P2-003 fix: replace strict ">1 candidates → ambiguous deny" with iterative
  # consume. Legitimate concurrent same-scope markers (e.g., two TP create verdicts
  # produced in a multi-alert loop run before jr execution) must not mutually invalidate.
  # Anti-forgery property is preserved: each marker is single-use via atomic rename;
  # forged markers still cannot be created (filesystem-isolated from LLM surface).
  # Sort by issued_at_utc ascending (oldest first). First successful atomic rename = allow.
  # If all renames fail (concurrent consumer got each one), deny fail-closed.
  FOR candidate IN sort(candidates, key=issued_at_utc, order=ASC):

    # STEP: Atomic single-use invalidation (TOCTOU-safe via POSIX rename)
    # ADV-F2-014: explicit deny on rename failure — here CONTINUE to next candidate
    result = mv(candidate.file,
                "${marker_dir}/${candidate.json.marker_id}.marker.json.used")
    IF result != SUCCESS:
      CONTINUE           # concurrent consumer already got this marker; try the next one

    # Rename succeeded — this marker is ours
    # STEP: Audit trail — ADV-F2-013: shell-safe encode command via base64
    #   Prevents newline injection into audit.log (a newline in a command arg would
    #   allow forging additional MARKER_USED lines in the audit chain-of-custody).
    #   Canonical audit log path: ${CLAUDE_PLUGIN_DATA}/markers/audit.log (= ${marker_dir}/audit.log)
    # ADV-F2-P4-010: extend sanitization to ALL attacker-influenceable fields.
    #   ticket_id comes from verdict.ticket_id (Jira content — LLM-influenced, may contain \n).
    #   org_slug comes from verdict.org_slug (operator-configured; lower risk but still sanitize).
    #   op comes from authorized_operations[0] (bounded enum — sanitize for defense-in-depth).
    #   Strip all control characters [\x00-\x1f] before interpolation.
    command_b64 = base64_encode(command)   # base64 -w0 (Bash) / [Convert]::ToBase64String (PS)
    safe_ticket = strip_control_chars(candidate.json.ticket_id)    # \x00-\x1f stripped
    safe_op     = strip_control_chars(candidate.json.authorized_operations[0])
    safe_org    = strip_control_chars(candidate.json.org_slug)
    audit_line = "${ISO_NOW} MARKER_USED marker_id=${candidate.json.marker_id} " +
                 "op=${safe_op} " +
                 "ticket=${safe_ticket} " +
                 "org=${safe_org} " +
                 "command_b64=${command_b64}"
    append(audit_line, "${marker_dir}/audit.log")  # canonical: ${CLAUDE_PLUGIN_DATA}/markers/audit.log

    emit_allow()
    RETURN ALLOW

  # All candidates exhausted without a successful consume (races or all invalid)
  emit_deny("No marker could be consumed — deny (fail-closed)")
  RETURN DENY
```

**Bash implementation note for audit encoding:**
```bash
# ADV-F2-013 fix: base64-encode command to prevent newline injection
command_b64=$(printf '%s' "${command}" | base64 | tr -d '\n')
# On macOS/BSD: base64 -b 0; on GNU: base64 -w 0; tr -d '\n' normalizes both

# ADV-F2-P4-010 fix: strip control characters from all attacker-influenceable fields
safe_ticket=$(printf '%s' "${ticket_id}" | tr -d '\000-\037')
safe_op=$(printf '%s' "${op}" | tr -d '\000-\037')
safe_org=$(printf '%s' "${org_slug}" | tr -d '\000-\037')
```

**PowerShell implementation note for audit encoding:**
```powershell
# ADV-F2-013 fix
$commandB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Command))
```

The existing validation algorithm in require-review.sh is unchanged for the non-jr fast
path, write-block check, and allowlist. The marker validation path is a NEW branch inserted
between the write-block check and the fail-closed catch-all. Evaluation order:

```
1. fast-path allow (non-jr command)
2. write-block DENY (plain + --output json forms) — UNCHANGED
3. IF marker_dir exists AND command matches write-block family:
     result = validate_marker(command)
     IF result == ALLOW: emit_allow, RETURN
     IF result == DENY:  fall through to...
4. read-only allowlist ALLOW  — UNCHANGED
5. fail-closed DENY           — UNCHANGED
```

The write-block check (step 2) still fires first — Invariant #5 is preserved. The marker
path is an EXCEPTION BRANCH off step 2, not a replacement of it.

**Threat analysis:**

| Threat | Mechanism | Mitigation |
|--------|-----------|-----------|
| SEC-001 injection — ticket body plants marker ID | Marker ID is not embedded in command string; require-review scans filesystem, not command text | Marker file can only be created by disposition-guard (hook process, not LLM) |
| SEC-009-class bypass — embedded allowlist token in write command | command_pattern uses anchored regex; no substring idiom | `^jr (--output json )?issue comment ` anchors at start; cannot be satisfied by text in command arguments |
| SEC-009-class bypass via create pattern `.*` (ADV-F2-P4-002) | Old: `.*--project <key>` allowed attacker-controlled `--summary` text to satisfy the project key check; prefix match `PROD` matched `PRODUCTION` | ADV-F2-P4-002 fix: `--project` is the FIRST fixed argument (`^jr issue create --project <key>( \|$)`); no `.*`; trailing `( \|$)` prevents prefix match; Iron Law: monitoring-loop MUST place `--project` as first arg in every `jr issue create` call |
| Audit log newline injection via raw ticket_id/org_slug (ADV-F2-P4-010) | `ticket_id` from Jira API response may contain `\n`; raw interpolation in audit line allows forging additional MARKER_USED audit entries | ADV-F2-P4-010 fix: control characters (0x00–0x1f) stripped from `ticket_id`, `org_slug`, `op` before interpolation; extends ADV-F2-013 to all attacker-influenceable fields |
| Replay attack (marker reuse) | Atomic `mv` rename before `emit_allow`; second caller finds no file → emit_deny | POSIX rename(2) is atomic; TOCTOU window = 0 |
| TOCTOU race between two concurrent invocations | Both find marker M; first `mv` succeeds; second `mv` fails (file gone) → DENY | Exactly one caller succeeds; conservative by design |
| Future-dated marker (clock manipulation) | Marker with issued_at > now() treated as adversarial → expire and skip | Explicit `issued_at > now()` check; logs to audit |
| Marker directory manipulation (env var attack) | Would require setting CLAUDE_PLUGIN_DATA to attacker-controlled path | Requires OS-level control; outside threat model for this surface |
| Indeterminate/HIGH/CRIT verdict getting a marker | Disposition-guard hard floor — marker issuance blocked for these categories | disposition-guard validates disposition field against hard-floor list BEFORE writing marker |

**UUID generation (no external tooling dependency):**

```bash
# Bash — no uuidgen dependency required
marker_id=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || \
            openssl rand -hex 16 2>/dev/null || \
            echo "${PPID}${RANDOM}$(date +%s)" | sha256sum | cut -c1-32)
```

```powershell
# PowerShell — stdlib only
$markerId = [System.Guid]::NewGuid().ToString()
```

#### Consequences

Positive:
- SEC-001 injection surface cannot forge markers (filesystem-separated from command content)
- Single-use + atomic rename prevents replay
- Anchored command_pattern closes SEC-009-class substring bypass
- 120s TTL (via absolute `expires_at_utc`) limits window of marker validity; latency-budget justified
- Audit log provides who/when/what for every marker use; command field base64-encoded (ADV-F2-013)
- `expires_at_utc` eliminates read-side `issued_at + ttl_seconds` arithmetic; no clock-skew risk

Negative:
- `${CLAUDE_PLUGIN_DATA}` environment variable must be defined and writable (ASM-009 added)
- BATS test suite must grow to cover: marker-issued+used, marker-expired, marker-wrong-scope, marker-replay-blocked, marker-adversarial-multiplicity, missing-marker-dir (fail-closed)
- Adds a new filesystem dependency to require-review (previously: no filesystem access per Invariant #2)
  - **Invariant #2 must be updated:** "The hook never makes network calls and never spawns subprocesses beyond `jq`; it reads stdin and — for write operations — reads/invalidates a marker file from `${CLAUDE_PLUGIN_DATA}/markers/`."

**ADV-F2-P4-O2 — Marker store cleanup:** Marker files accumulate unboundedly without a
cleanup mechanism. Specify `cleanup_marker_store()` to be called at the start of each
monitoring-loop run (or via a companion hourly cron entry): remove `*.marker.json.used`
and `*.marker.json` files whose `expires_at_utc` is older than `now() - 10m`. Do NOT rotate
or truncate `audit.log` during cleanup. This bounds glob scan time to O(current-TTL-window)
rather than O(total-lifetime).

#### Alternatives Rejected

**Option B (cryptographic token in command body):** Rejected. A token embedded in the command
string is on the SEC-001 injection surface — Jira ticket content could plant a valid-looking
token in the clipboard/paste workflow. The marker must be stored OUT OF BAND from the command.

**In-memory session token:** Rejected. Hooks are stateless subprocess invocations; no shared
memory between the disposition-guard invocation and the require-review invocation. A
filesystem-based store is the only viable inter-hook communication channel.

**Signed JWT approach:** Rejected for v0.10.0. JWT signing requires a key stored somewhere
accessible to both hooks — which reduces to the same filesystem-based problem but with more
complexity. Deferred to a future hardening cycle if the threat model escalates.

---

### D-DEC-002 — Watermark Store Format, Atomicity, and OS Path Resolution

#### Context

The monitoring-loop persists a timestamp watermark after each run to support incremental
event ingestion. If the watermark is corrupted or two runs overlap, events could be
double-processed or silently dropped (R-003). The watermark must survive OS scheduler
invocations across reboots and be accessible from the scheduler's user context.

#### Decision

**File format:** Plain-text ISO 8601 UTC timestamp with milliseconds, terminated by `\n`.
Example: `2026-07-20T14:30:00.000Z\n`

**Path structure:** `${CLAUDE_PLUGIN_DATA}/watermarks/<org_slug>/<sensor_id>`
where `<org_slug>` and `<sensor_id>` are the exact strings from `prism.toml [[orgs]]`.

**OS-specific `${CLAUDE_PLUGIN_DATA}` resolution:**

| OS | Expected path | Notes |
|----|--------------|-------|
| Linux | `~/.local/share/claude` | XDG_DATA_HOME default; create if absent |
| macOS | `~/Library/Application Support/Claude` | Standard macOS data dir |
| Windows | `%APPDATA%\Claude` | PowerShell: `$env:APPDATA\Claude` |

The monitoring-loop must export `CLAUDE_PLUGIN_DATA` with the OS-appropriate default if
the environment variable is unset. A Stage 0 probe must verify write access before any
queries.

**Atomic write strategy (Bash):**

```bash
WRITE_WATERMARK() {
  local org="$1" sensor="$2" ts="$3"
  local dir="${CLAUDE_PLUGIN_DATA}/watermarks/${org}"
  local target="${dir}/${sensor}"
  local tmp="${target}.tmp.$$"

  mkdir -p "${dir}"

  # ADV-F2-P4-O1: tightened to require full RFC3339 UTC-Z, matching READ_WATERMARK validation.
  # Old regex: '^[0-9]{4}-..T..' (no Z suffix, no end-anchor) allowed timezone-offset timestamps
  # that pass WRITE but fail READ → watermark effectively lost on subsequent run (READ falls back
  # to 24h). Asymmetry also exposed monotonic-guard bypass: max(stored, ts) could produce a
  # non-UTC-Z string that READ_WATERMARK rejects unconditionally.
  if ! echo "${ts}" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?Z$'; then
    echo "WATERMARK_WRITE_ERROR: invalid RFC3339 UTC-Z timestamp '${ts}'" >&2
    return 1
  fi

  # ADV-F2-P3-006: MONOTONIC GUARD — never regress stored watermark.
  # An in-grace-only run fetches events from (stored - GRACE) to stored; all those
  # events may already have been processed, so run_max_ts ≤ stored. Without this
  # guard, WRITE_WATERMARK(ts = run_max_ts < stored) would regress the watermark,
  # drifting the grace window further back on every subsequent run.
  # Invariant: effective write = max(stored, ts) under ISO 8601 lexicographic ordering.
  local stored_ts=""
  if [ -f "${target}" ]; then
    stored_ts=$(cat "${target}" | tr -d '\n')
  fi
  local effective_ts="${ts}"
  if [ -n "${stored_ts}" ] && [[ "${stored_ts}" > "${ts}" ]]; then
    # Stored watermark is lexicographically later — preserve it.
    effective_ts="${stored_ts}"
    echo "WATERMARK_MONOTONIC: not regressing from ${stored_ts} to ${ts}; keeping stored" >&2
  fi

  printf '%s\n' "${effective_ts}" > "${tmp}"
  mv "${tmp}" "${target}"    # POSIX rename(2) — atomic on same filesystem

  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) WATERMARK_UPDATE org=${org} sensor=${sensor} requested=${ts} effective=${effective_ts}" \
    >> "${CLAUDE_PLUGIN_DATA}/watermarks/audit.log"
}
```

**Read with validation [v2.0 — ADV-F2-006/ADV-F2-010 remediation]:**

```bash
# Configurable lookback-overlap grace window (ADV-F2-006)
# Purpose: catches late/out-of-order OCSF events that arrive after the watermark
# was written. prism's OCSF ingestion pipeline can deliver events with a
# wall-clock delay (ETL latency, batched ingest). Without a grace window, any
# event with _time in [last_watermark - latency, last_watermark] is silently
# dropped forever.
WATERMARK_GRACE_SECONDS="${WATERMARK_GRACE_SECONDS:-300}"  # default 5 minutes
# ADV-F2-P4-O3: Grace-window drop trade-off — events with ETL latency > WATERMARK_GRACE_SECONDS
# are PERMANENTLY dropped (not deferred). Operators must configure WATERMARK_GRACE_SECONDS to
# exceed the 99th-percentile ETL latency of their prism deployment. ASM-008 (prism _time format
# unvalidated) is a related assumption. If prism delivers events in high-latency bursts
# (e.g., 10-minute batch flush), WATERMARK_GRACE_SECONDS must be >= 600 or those events are lost.

READ_WATERMARK() {
  local org="$1" sensor="$2"
  local target="${CLAUDE_PLUGIN_DATA}/watermarks/${org}/${sensor}"
  local fallback
  fallback=$(date -u -v-24H +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || \
             date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S.000Z)

  if [ ! -f "${target}" ]; then
    echo "${fallback}"   # first-run: 24h lookback
    return 0
  fi

  ts=$(cat "${target}" | tr -d '\n')

  # ADV-F2-010: require RFC3339 UTC with Z suffix for lexicographic comparison safety
  # prism _time field format is unvalidated (ASM-008); normalize before use
  if ! echo "${ts}" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?Z$'; then
    echo "WATERMARK_INVALID: '${ts}' not RFC3339 UTC-Z — using 24h fallback" >&2
    echo "${fallback}"
    return 0
  fi

  # Reject future timestamps (adversarial or clock-skew signal)
  if [[ "${ts}" > "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" ]]; then
    echo "WATERMARK_FUTURE: '${ts}' is in the future — using 24h fallback" >&2
    echo "${fallback}"
    return 0
  fi

  # ADV-F2-006: apply lookback-overlap grace window
  # Subtract WATERMARK_GRACE_SECONDS from the stored watermark so the query
  # re-fetches events in the grace window. Jira-first dedup (Stage 2) prevents
  # double-ticketing on events that were already processed.
  local grace_ts
  grace_ts=$(date -u -v-"${WATERMARK_GRACE_SECONDS}"S -jf "%Y-%m-%dT%H:%M:%S.000Z" "${ts}" \
             +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || \
             date -u -d "${ts} - ${WATERMARK_GRACE_SECONDS} seconds" \
             +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || echo "${ts}")

  echo "${grace_ts}"    # effective query start = stored_watermark - GRACE
}
```

**prism `_time` normalization step (ADV-F2-010):**

```bash
# Called once per ingested event — normalizes prism _time to RFC3339 UTC-Z
# before any lexicographic watermark comparison.
NORMALIZE_PRISM_TIME() {
  local ts="$1"
  # Already RFC3339 UTC-Z?
  if echo "${ts}" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?Z$'; then
    echo "${ts}"
    return 0
  fi
  # Attempt conversion (handles +00:00 suffix, missing milliseconds, etc.)
  local normalized
  normalized=$(date -u -d "${ts}" +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || \
               date -u -jf "%Y-%m-%dT%H:%M:%S%z" "${ts}" +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || \
               echo "INVALID")
  if [ "${normalized}" = "INVALID" ]; then
    echo "PRISM_TIME_NORMALIZE_ERROR: cannot normalize '${ts}'" >&2
    return 1
  fi
  echo "${normalized}"
}
```

This normalization is applied to every `_time` value returned by PrismQL before it is used
in watermark comparison, duplicate detection, or timeline_events field construction. ASM-008
(prism _time format unvalidated) is PARTIALLY MITIGATED by this step; full validation
requires empirical testing with a live prism instance (gated on ASM-001).

**Jira-first dedup for grace-window re-fetched events (ADV-F2-006):**

Because the grace-window makes queries overlap, some events re-fetched in the grace window
may already have Jira tickets from the prior loop run. The Stage 2 dedup check (§3.4 rules,
BC-10.01.001 Invariant #8) serves as the guard:

```
FOR EACH event E in grace-window re-fetch results:
  1. Run Jira dedup JQL (same as §3.4 dedup — check for open ticket matching this event ID)
  2. IF existing open ticket found → append comment per §3.4 rule #1 (not create-new)
     Record: "grace-window re-fetch: event already ticketed at <ticket_id>"
  3. IF no existing ticket → treat as new event (normal pipeline)
```

This ensures the grace window adds safety for late-arriving events without causing duplicate
ticket creation. The Stage 2 known-FP check and dedup check are BOTH applied before enrichment.

**Concurrent run prevention (advisory lockfile via `mkdir`):**

```bash
LOCK_DIR="${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"
LOCK_TIMEOUT_MINUTES=60

acquire_lock() {
  if mkdir "${LOCK_DIR}" 2>/dev/null; then
    trap "rm -rf '${LOCK_DIR}'" EXIT
    return 0
  fi
  # Check if stale (lock older than LOCK_TIMEOUT_MINUTES)
  if find "${LOCK_DIR}" -maxdepth 0 -mmin +${LOCK_TIMEOUT_MINUTES} 2>/dev/null | grep -q .; then
    echo "WATERMARK_STALE_LOCK: removing stale lock" >&2
    rm -rf "${LOCK_DIR}"
    mkdir "${LOCK_DIR}"
    trap "rm -rf '${LOCK_DIR}'" EXIT
    return 0
  fi
  echo "MONITORING_LOOP: another instance is running; exiting" >&2
  return 1
}
```

**First-run behavior:** If no watermark file exists, query `WHERE _time >= now() - INTERVAL
24 HOURS`. This prevents processing the full sensor history on initial deployment.

#### Consequences

Positive: Atomic writes prevent partial-read corruption. Lock prevents duplicate processing
on overlapping 15-minute intervals. Future-timestamp rejection guards against clock skew
attacks on the monitoring cadence.

Negative: `CLAUDE_PLUGIN_DATA` must be set (or defaulted) correctly. If the OS scheduler
runs as a different user than interactive Claude, the path diverges — Stage 0 must verify
write access (ASM-005 remains UNVALIDATED until empirical test).

#### Alternatives Rejected

**SQLite database:** Richer but introduces a compiled dependency not present in the plugin's
current technology stack (pure shell/markdown/YAML). Deferred to v1.1.

**Git-committed watermarks:** Watermarks are high-frequency write state (every 15 minutes);
committing them would pollute repo history and require CI intervention. Never-committed
runtime state is the established pattern (artifacts/ precedent).

**Fail-loud late-event detection requirement (ADV-F2-P6-007 MINOR):**

When an ingested event's `_time` is older than `watermark - WATERMARK_GRACE_SECONDS` (i.e.,
the event arrived in-window for THIS run but would be outside the window on the NEXT run),
the monitoring-loop MUST emit an explicit auditable log entry. The event is processed normally
(not dropped), but the operator is alerted that WATERMARK_GRACE_SECONDS may need tuning.

```bash
# Late-event detection — Stage 1 INGEST (ADV-F2-P6-007)
# Called after NORMALIZE_PRISM_TIME() on each ingested event.
DETECT_LATE_EVENT() {
  local event_time="$1"
  local stored_watermark
  stored_watermark=$(cat "${CLAUDE_PLUGIN_DATA}/watermarks/${ORG}/${SENSOR}" 2>/dev/null || echo "NONE")

  if [ "${stored_watermark}" = "NONE" ]; then return 0; fi  # first run: no baseline

  # Compute the threshold: if event_time < stored - GRACE, flag it
  local threshold
  threshold=$(date -u -d "${stored_watermark} - ${WATERMARK_GRACE_SECONDS} seconds" \
              +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || \
              date -u -v-"${WATERMARK_GRACE_SECONDS}"S \
              -jf "%Y-%m-%dT%H:%M:%S.000Z" "${stored_watermark}" \
              +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || echo "SKIP")

  if [ "${threshold}" = "SKIP" ]; then return 0; fi  # date arithmetic not supported; skip

  if [[ "${event_time}" < "${threshold}" ]]; then
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) LATE_EVENT_DETECTED event_time=${event_time}" \
         " watermark=${stored_watermark} grace_window=${WATERMARK_GRACE_SECONDS}s" \
         " — event ingested this run but below grace floor;" \
         " operator must verify WATERMARK_GRACE_SECONDS >= max ETL latency (ASM-008)" \
      >> "${CLAUDE_PLUGIN_DATA}/watermarks/audit.log"
    # DO NOT drop the event — process it normally; log the risk only.
  fi
}
```

This produces an auditable record without disrupting event processing. Operators can monitor
`watermarks/audit.log` for `LATE_EVENT_DETECTED` entries to calibrate `WATERMARK_GRACE_SECONDS`.

**ASM-008 gate:** The empirical value of `WATERMARK_GRACE_SECONDS` cannot be pinned without
knowing prism's actual ETL latency distribution (ASM-008 is UNVALIDATED). The fail-loud
detection gives operators empirical signal during Wave 7 validation testing to tune the
parameter. A VP target exists for this requirement — see §8.15 FV propagation (VP-SKILL-073).

---

### D-DEC-003 — Monitoring-Loop Packaging (RESOLVED — ASM-004 PARTIAL)

#### Context

ASM-004 empirical validation returned **PARTIAL** (`.factory/phase-f2-spec-evolution/asm-004-validation.md`).

Key findings:
- cwd `.mcp.json` is auto-loaded headlessly — confirmed.
- `--strict-mcp-config --mcp-config <path>` is reliable and deterministic for headless — confirmed.
- `--settings` with `mcpServers` is NOT honored headlessly — refuted.
- `~/.claude/settings.json` `mcpServers` route in a standalone cron context — UNCONFIRMED (not tested directly; proxy test via `--settings` failed; parent-daemon bleed-through is unreliable in cron).
- `--output-format json` produces a clean machine-parseable envelope (`is_error`, `permission_denials`, `result`, `terminal_reason`, `exit_code`).

The brief §2.1 assumed the activate skill writes only to `~/.claude/settings.json`. This is
no longer sufficient for the cron path. The design deviates from the brief.

#### Decision

**Package as `skills/monitoring-loop/SKILL.md` + `commands/monitoring-loop.md` (CONV-001/003 compliant).**

The activate skill (`skills/activate/activate-mcp-config.sh`) writes the prism server block
to **two** destinations:
1. `~/.claude/settings.json` — for interactive Claude Code sessions (existing brief §2.1 target, R-008 jq-merge pattern unchanged)
2. `~/.claude/prism.mcp.json` — dedicated headless/cron config file (new; content is the prism MCP server block only)

A cron wrapper script (`skills/monitoring-loop/run-monitoring-loop.sh` + `.ps1`) invokes:

```bash
#!/usr/bin/env bash
# run-monitoring-loop.sh — cron-safe invocation wrapper for monitoring-loop
# Requires: claude in PATH, ~/.claude/prism.mcp.json written by activate skill

set -euo pipefail

PRISM_MCP_CONFIG="${HOME}/.claude/prism.mcp.json"
LOG_DIR="${CLAUDE_PLUGIN_DATA:-${HOME}/.local/share/claude}/monitoring-loop-logs"
mkdir -p "${LOG_DIR}"

if [ ! -f "${PRISM_MCP_CONFIG}" ]; then
  echo "ERROR: ${PRISM_MCP_CONFIG} not found. Run /activate first." >&2
  exit 1
fi

# D-DEC-010: --allowedTools scoped allowlist (not --dangerously-skip-permissions)
# See D-DEC-010 for allowlist rationale and residual risk assessment.
claude -p "/monitoring-loop" \
  --strict-mcp-config \
  --mcp-config "${PRISM_MCP_CONFIG}" \
  --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__tavily__tavily_extract,mcp__perplexity__perplexity_ask,mcp__perplexity__perplexity_search,Bash,Write,Read,Edit" \
  --output-format json \
  < /dev/null \
  >> "${LOG_DIR}/$(date -u +%Y%m%dT%H%M%SZ).json" \
  2>> "${LOG_DIR}/stderr.log"

exit_code=$?

# Gate on structured output
result_file=$(ls -t "${LOG_DIR}/"*.json 2>/dev/null | head -1)
if [ -n "${result_file}" ]; then
  is_error=$(jq -r '.is_error // true' "${result_file}" 2>/dev/null || echo "true")
  denials=$(jq -r '.permission_denials | length' "${result_file}" 2>/dev/null || echo "1")
  if [ "${is_error}" = "true" ] || [ "${denials}" -gt 0 ]; then
    echo "MONITORING_LOOP_FAILURE: is_error=${is_error} permission_denials=${denials}" >&2
    exit 1
  fi
fi

exit "${exit_code}"
```

**Deviation from brief §2.1 — rationale:**

Brief §2.1 specified writing only to `~/.claude/settings.json`. ASM-004 empirical testing
showed that `--settings` with `mcpServers` is not honored headlessly, and `~/.claude/settings.json`
`mcpServers` loading in a cron context (no parent daemon) is unconfirmed. Writing a
dedicated `~/.claude/prism.mcp.json` and using `--strict-mcp-config --mcp-config` is
the only empirically confirmed reliable path for headless prism MCP access.

The deactivate skill must clean up both files:
```bash
jq 'del(.mcpServers.prism)' ~/.claude/settings.json > /tmp/settings-deprism.json \
  && mv /tmp/settings-deprism.json ~/.claude/settings.json
rm -f ~/.claude/prism.mcp.json
```

**Wave 7 is unblocked.** D-DEC-003 is resolved. No further ASM-004 dependency.

**`--bare` is explicitly forbidden for the monitoring-loop invocation.** The `--bare` flag
skips hooks, including the require-review hook. Without require-review, all Jira write
operations (comment, create, assign) would be ungated — a critical security regression.
The wrapper script must never pass `--bare`. This is a BATS-testable constraint: the
wrapper script must be parsed for absence of `--bare`.

#### Consequences

Positive:
- Reliable headless MCP access confirmed via empirical test (not assumption)
- `--strict-mcp-config` isolates the monitoring-loop to prism/tavily/perplexity only — no
  other MCP servers from interactive configuration leak into the cron context
- Structured `--output-format json` output enables scheduler-level failure detection
  (`is_error`, `permission_denials` fields)
- Wave 7 (monitoring-loop) story decomposition can proceed in F3

Negative:
- Activate shell helper must write to two locations; deactivate must clean both
- `~/.claude/prism.mcp.json` is a new external write surface (add to §3 External Surface Inventory)
- The cron wrapper script (`run-monitoring-loop.sh`) is a new shell script that must have
  a `.ps1` sibling (CONV-004) and BATS coverage for the happy path, missing prism.mcp.json,
  and structured output failure gate
- BC-6.01.001 (activate skill) and BC-6.01.002 (deactivate skill) must both be updated to
  reflect the two-destination write and corresponding cleanup

#### Alternatives Rejected

**Settings-only (brief §2.1 original approach):** Rejected. `--settings mcpServers` not
honored headlessly (ASM-004 Probe 3). The `~/.claude/settings.json` mcpServers route for
standalone cron is unconfirmed. Unreliable path.

**Option B — prism subprocess pre-fetch wrapper:** Rejected. The `--strict-mcp-config --mcp-config`
path confirmed reliable, making the complex pre-fetch wrapper unnecessary. The pre-fetch
approach would also require prism to support direct subprocess queries outside MCP — a
dependency not confirmed with the prism team.

**`--bare` mode:** Explicitly rejected. Disables the require-review hook, removing the sole
hard gate on Jira write operations. Security regression, unacceptable.

**Standalone prompt file (no SKILL.md):** Rejected. Violates CONV-001/003. Rejected.

**External Python/Node orchestrator:** Rejected. Incompatible with the plugin's
declarative-only technology stack.

---

### D-DEC-004 — Sensor-Silence BLIND-SPOT Ticket Dedup

#### Context

Brief §3.7 requires silence events to generate Jira tickets (positive risk signal). Without
dedup, every 15-minute loop run during a multi-hour sensor silence creates a new `[BLIND-SPOT]`
ticket — Jira spam that degrades signal quality (R-006).

#### Decision

**One open BLIND-SPOT ticket per `(org_slug, sensor_id)` pair at any time.**

Before creating a new BLIND-SPOT ticket, the monitoring-loop executes a dedup query:

```bash
jr issue list --jql \
  "project = ${PROJECT_KEY} \
   AND labels = \"BLIND-SPOT\" \
   AND status not in (Closed, Done, Resolved) \
   AND summary ~ \"BLIND-SPOT ${org_slug}/${sensor_id}\"" \
  --output json
```

**Dedup algorithm:**

```
IF dedup_query returns >= 1 open ticket:
  → APPEND comment to the EXISTING ticket (§3.4 append rule)
  → Include: new silence observation timestamp, consecutive silence count, sensor_health_status
  → Do NOT create a new ticket
  → Do NOT auto-reopen a Resolved or Closed ticket (§3.4 rule #4)

IF dedup_query returns 0 open tickets:
  → CREATE new BLIND-SPOT ticket
  → Title format: "[BLIND-SPOT] Sensor silence: <org_slug>/<sensor_id>"
  → Labels: BLIND-SPOT, PRISM-AUTO
  → Disposition field: Indeterminate-due-to-missing-telemetry
  → sensor_health_status: silent
  → Assign to on-call queue (per per-tenant config)
```

**BLIND-SPOT ticket_action_type binding (ADV-F2-P6-006 — D-DEC-012 alignment):**

Sensor-silence verdicts are hard-floor (`sensor_health_status=silent` → `hard_floor_applies()=TRUE`).
BLIND-SPOT tickets MUST use the D-DEC-012 exempt-marker path:
- New BLIND-SPOT ticket → `ticket_action_type = "create-review"` (NOT `"create"`)
  The create-review marker pattern includes `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed
  second position — `--label BLIND-SPOT` in the jr command satisfies this structural requirement
  (the label serves both as the Jira label AND as the marker-binding structural element per
  ADV-F2-P6-001).
- Append to existing BLIND-SPOT ticket → `ticket_action_type = "comment-review"` (NOT `"comment"`)

This alignment ensures sensor-silence escalation tickets flow through the D-DEC-012 exempt-marker
path and are never silently dropped by the hard-floor block. The dedup algorithm above is unchanged;
only the ticket_action_type value must be updated in BC-10.01.001 EC-006 (PO obligation — §8.14).

**Edge case — Closed/Resolved BLIND-SPOT ticket:**
If the dedup query finds a Closed/Resolved ticket (§3.4 rule: Closed = never auto-reopen):
create a NEW ticket with a "Linked to: [prior-ticket-id]" relation. The closure of the
prior ticket does not guarantee the silence was genuinely resolved — a new observation is
a new finding.

**Never-auto-reopen invariant (§3.4 rule #4):** This is an unconditional code branch in
the monitoring-loop, not a config option. The `sla_reopen_behavior` per-tenant field
affects SLA surface messaging only — it never enables auto-reopen.

#### Consequences

Positive: Linear ticket count growth during silence periods (one ticket → append comments).
Preserves the silence signal without overwhelming the Jira backlog.

Negative: The dedup JQL relies on `summary ~` text search (Jira's approximate match). If
the JQL JTBD syntax is unavailable or the project key is wrong, the dedup may fail — the
fallback must be to create a new ticket rather than silently skip, to preserve the positive
risk signal.

#### Alternatives Rejected

**Dedup by Jira custom field (org_slug, sensor_id):** Cleaner key but requires custom
fields to exist in every customer Jira project. Out of scope for v0.10.0 (brief §4 is
demo-unaware for field structure). Text-search approach is portable across any Jira project.

**Suppress subsequent silences until the ticket is closed:** Rejected — §3.7 states "do
NOT auto-close or suppress; each silence event is independently actionable." The comment
append preserves each observation as a distinct record.

---

### D-DEC-005 — Cross-Tenant Correlation Scope (RESOLVED in F1, recorded here)

#### Decision

Cross-tenant correlation architecture is prism-side (prism release engineering concern,
not plugin scope for v0.10.0). The plugin's sole obligation is the tenant-isolation invariant:

**All PrismQL queries issued by the plugin that retrieve raw per-tenant security event data
MUST include an explicit `org_slug` scope constraint. The plugin MUST NEVER construct a
raw-data PrismQL query without this constraint.**

This is BC-10.01.001 Invariant #1. The MSSP-global correlation store, anonymized IOC
federation, and per-tenant RBAC enforcement are prism concerns.

**SENSOR-HEALTH METADATA CARVE-OUT (P9-005 / brief §2.4 + §3.6):**

`prism_sensor_health` metadata queries are **EXEMPT** from the per-tenant raw-data org_slug
isolation rule. `SELECT * FROM prism_sensor_health` is a cross-org operational health
telemetry query returning administrative metadata (last-seen timestamps, row counts, error
rates) across all configured orgs.

Basis (ground truth from handoff brief):
- Brief §2.4 (sensor-metrics skill) explicitly models the canonical query as
  `SELECT * FROM prism_sensor_health` WITHOUT an org_slug filter. This is not an oversight —
  the "per-org sensor telemetry" description refers to the per-org breakdown in the
  prism_sensor_health result set, not to per-org query scoping.
- Brief §3.6 (cross-tenant correlation) isolates the rule to "raw per-tenant sensor records."
  `prism_sensor_health` contains operational health metadata (connectivity, data flow), not
  customer security event records (CrowdStrike detections, Armis alerts, etc.). The RBAC
  boundary applies to security data; health metadata is MSSP-operator-scoped by design.
- The monitoring loop STAGE 0 iterates `FOR EACH customer` in the outer loop and uses
  `WHERE org_slug = <org_slug>` when it needs per-org health details; the cross-org shape
  is used by the sensor-metrics skill for operator dashboards.

Scope of carve-out: limited to `prism_sensor_health`. All other tables
(`crowdstrike_detections`, `armis_alerts`, `claroty_events`, `cyberint_alerts`, etc.) are
raw security event records and remain subject to the mandatory org_slug constraint.

**PO propagation (P9-005):** BC-8.02.001 (sensor-metrics skill) must reflect this carve-out —
its postconditions should NOT require org_slug on `prism_sensor_health` queries. BC-10.01.001
Invariant #1 must be updated to scope the absolute rule to non-health tables only.

#### Rationale

BA §3.6 verdict (2026-07-19): "plugin-side constraint only (prism-side architecture)."
The `cross_tenant_correlation: allow | deny` per-tenant config field (brief §3.6) is a
prism configuration field, not a plugin configuration field. The plugin exposes it only
if prism exposes it via an MCP tool response.

---

### D-DEC-006 — Metrics Skill Naming

#### Context

The existing command namespace contains `generate-metrics` and `verify-metrics-report`.
A new skill for prism sensor health telemetry (`SELECT * FROM prism_sensor_health`) must
be named to avoid user confusion at the `/` command prompt.

CONV-003 requires command name == skill directory name exactly. The name must be chosen
once, as it affects the skill dir, command file, BC identifier, and any references in
secops-protocol.md.

#### Decision

**Skill name: `sensor-metrics`**
- Skill directory: `skills/sensor-metrics/SKILL.md`
- Command file: `commands/sensor-metrics.md`
- BC slot: BC-8.02.001 (S=8, SS=02 — confirmed by BA; the BC slot is independent of the
  skill name, which was `metrics` in BA's working path but is now `sensor-metrics`)

The F1 BA working path `skills/metrics/SKILL.md` is superseded by this F2 decision.

#### Rationale

Filesystem inspection confirms no existing `metrics.md` command or `metrics/` skill dir.
The namespace collision risk is at the user interface level:
- `/generate-metrics` = Jira-derived effort metrics (C-9, metrics-analyst Quinn)
- `/sensor-metrics` = prism sensor health telemetry (new, C-25-dependent)

`sensor-metrics` makes the data source explicit at the command level. A user typing `/m`
and tab-completing would see both `generate-metrics` and `sensor-metrics` — unambiguous.

#### Consequences

BA's BC-8.02.001 draft references `skills/metrics/` — the BC author must update the path
reference in the BC spec file to `skills/sensor-metrics/` during F2 spec authoring.

#### Alternatives Rejected

**`metrics` (bare):** Generic; creates `/metrics` command that users may confuse with
`/generate-metrics`. Rejected for user experience clarity.

**Extend `generate-metrics` with `--source prism` flag:** Rejected. Different subsystem
(S=8, SS=02 vs SS=01), different data source, different agent (metrics-analyst Quinn uses
`jr`; sensor-metrics uses `mcp__prism__*`). Extension would conflate two distinct
operational domains in one skill.

---

### D-DEC-007 — Shell Helper Script Location

#### Context

Three new shell helper types are introduced (MCP config write, prism version check,
credential set). Their placement must conform to repo conventions and enable easy BATS
coverage.

#### Decision

**Co-locate under `skills/<name>/`:**
- `plugins/secops-factory/skills/activate/activate-mcp-config.sh` + `.ps1`
- `plugins/secops-factory/skills/activate/prism-version-check.sh` + `.ps1`
- `plugins/secops-factory/skills/onboard-sensor/credential-set.sh` + `.ps1`

CONV-004 (.sh requires .ps1 sibling) applies naturally. CI's structure job already scans
`skills/` directories. `${CLAUDE_PLUGIN_ROOT}/skills/<name>/<helper>.sh` is a natural
invocation path from SKILL.md prose.

#### Consequences

CI `structure` job must be updated to verify that for every `.sh` in `skills/<name>/`, a
`.ps1` sibling exists (extending CONV-004 enforcement into skill subdirectories). This is
a CI change tracked in delta-analysis.md §2.2.

BATS test suite (`integration.bats` or a new `helpers.bats` suite) must cover:
- Happy path for each helper
- Missing binary (prism-version-check)
- Version mismatch (prism-version-check)
- `settings.json` merge correctness (activate-mcp-config)
- Piped-stdin credential set (credential-set, AD-017 — verify no re-read)

#### Alternatives Rejected

**`scripts/` top-level directory:** Introduces a new repo-level directory not present in
the current layout. Violates the principle of minimal structural change to the plugin. Rejected.

**`hooks/` co-location:** CONV-001 scopes `hooks/` to Claude Code event handler scripts
(PreToolUse, PostToolUse, SubagentStop, SessionStart). Shell helpers invoked by skill
procedures are not hook event handlers. Placing them in `hooks/` would create semantic
confusion and might trigger incorrect BATS group assignment. Rejected.

---

### D-DEC-008 — Marker Scope for Monitoring-Loop Write Operations

#### Context

D-DEC-001 established the marker mechanism for `jr issue comment`. The monitoring-loop
also needs autonomous `jr issue create` (TP verdict, new ticket) and `jr issue assign`
(escalation routing). Each operation must be independently scoped — a comment-scoped marker
must not authorize a create operation.

#### Decision

**Each marker is scoped to exactly one `authorized_operations` token, set by disposition-guard
at issuance time.** The `command_pattern` field is derived deterministically from
`authorized_operations` AND `ticket_id` — never from user input or Jira ticket content.

**ADV-F2-002 binding decision: TICKET-BOUND for comment + assign; operation-scoped for create.**

Rationale for ticket-bound (comment/assign): A ticket-agnostic comment marker (e.g.,
`^jr ... issue comment `) would authorize the monitoring-loop to comment on ANY Jira ticket
within the TTL window — a violation of the principle of least privilege and a meaningful attack
surface if the marker store were compromised. Ticket-bound patterns directly implement EC-022
(anchored to specific ticket_id → deny on mismatch) and close the cross-ticket reuse window.

Rationale for operation-scoped (create): At create-scoped marker issuance time, no ticket_id
exists yet (the ticket is being created). The operation-scoped pattern is bounded by:
(1) org context embedded in the verdict that generated the marker;
(2) single-use — the rename atomically invalidates the marker after the first `jr issue create`;
(3) 120s TTL — limits the window during which a stale create marker could be replayed.
A create marker authorizes exactly one ticket creation; any attempt to reuse it fails (no file).

**`command_pattern` generation table (canonical — single source of truth):**

| `authorized_operations` | `ticket_id` | `command_pattern` generated | Notes |
|------------------------|-------------|----------------------------|-------|
| `["comment"]` | `"SEC-123"` | `^jr (--output json )?issue comment SEC-123 ` | Trailing space guards against SEC-123 matching SEC-1234 (EC-022) |
| `["assign"]` | `"SEC-123"` | `^jr (--output json )?issue assign SEC-123 ` | Same trailing-space guard |
| `["create"]` | `null` | `^jr (--output json )?issue create --project <jira_project_key>( \|$)` | ADV-F2-P4-002: `--project` is FIRST arg in fixed position; trailing `( \|$)` prevents project-KEY prefix-extension (`PROD` does not match `PRODUCTION`). **P8-003:** bash `[[ =~ ]]` is NOT tail-anchored — this pattern DOES match a review-labeled `jr issue create --project KEY --label REVIEW-REQUIRED ...` at consumer step 5. `( \|$)` guards ONLY against prefix extension; anti-fungibility direction A (regular create marker cannot authorize review-labeled command) is enforced EXCLUSIVELY at step 6a (`structural_label_check`). |
| `["create-review"]` | `null` | `^jr (--output json )?issue create --project <jira_project_key> --label (REVIEW-REQUIRED\|BLIND-SPOT)( \|$)` | **ADV-F2-P6-001 fix (unified with P6-004):** structurally DISTINCT from `["create"]` — `--label (REVIEW-REQUIRED\|BLIND-SPOT)` in FIXED second position after `--project <key>` (mirrors P4-002 Iron Law); a regular `jr issue create --project X` without `--label` cannot match this pattern; consumer STEP 6a enforces anti-fungibility in both directions. P6-004 unified: single PRISM-DEMO project key makes per-org project-key isolation infeasible; review-label binding is the primary cross-org protection for create-review operations |
| `["comment-review"]` | `"SEC-123"` | `^jr (--output json )?issue comment SEC-123 ` | D-DEC-012: ticket_id-bound (same as `["comment"]`); consumer STEP 6a enforces that `["comment"]` markers cannot be consumed by a `["comment-review"]`-context command and vice versa. Structural `--label` check for comment-type commands pending ASM-014 empirical validation of `jr issue comment --label` support |

> **ADV-F2-P4-002 create-scope anchored pattern:** The `.*` between `create ` and `--project`
> has been REMOVED. The new pattern requires `--project` to be the FIRST argument after
> `issue create`. **Iron Law:** The monitoring-loop SKILL.md MUST always invoke
> `jr issue create --project ${JIRA_PROJECT_KEY}` with `--project` as the first explicit
> argument. No flags (e.g., `--summary`) may precede `--project`. This locks the project key
> to a fixed position, making injection via `--summary "...--project ORG_A..."` impossible
> (the injected text occurs after the real `--project` binding, which has already closed the
> pattern match via the trailing `( |$)` boundary). BC-3.03.001 create emitter branch must
> adopt this pattern (PO obligation — see §8.10 item 2).
>
> **ADV-F2-P3-002 create-scope org-binding (updated ADV-F2-P6-004):** The create pattern
> embeds the Jira project key from `verdict.jira_project_key` (non-ICD-203 operational metadata
> field; does NOT count against the 15 ICD-203 fields; does NOT affect VP-HOOK-025 test count).
> Under the brief's single-demo-project configuration (key `PRISM-DEMO`), all orgs share one
> project key — per-org isolation via project key is architecturally infeasible in the demo
> deployment. **SEC_ORG_A/SEC_ORG_B per-org-key examples are REMOVED (ADV-F2-P6-004 explicit
> downgrade).** Cross-org isolation for create operations in single-project config relies on:
> (a) single-use atomic rename, (b) 120s TTL, (c) for create-review: review-label binding via
> the structural `--label` requirement enforced by consumer STEP 6a. This is a documented
> limitation of the PRISM-DEMO deployment, not a silent assumption. Multi-project deployments
> (where each org has its own Jira project key) retain full per-org-key binding.
>
> If `jira_project_key` is null or absent in the verdict, behavior depends on the step:
> - **STEP 3 (create-review — genuinely hard-floor path, P8-001 fix):** DENY-THE-WRITE with
>   `HARD-FLOOR-UNBINDABLE` audit entry per D-DEC-012 clause 2. A hard-floor verdict cannot
>   silently discard the review obligation. Corrective reason names missing_field=jira_project_key.
> - **STEP 6 (regular create — non-hard-floor, autonomy-enabled path):** emit allow WITHOUT
>   marker; document write proceeds; no jr action authorized. Human approval required for
>   unbound regular creates.

The trailing space after the ticket_id in comment/assign patterns is intentional: it prevents
`SEC-1234` from matching a pattern anchored to `SEC-123 ` (EC-022 protection).

**ADV-F2-004: emitter scope selection — disposition-guard reads `verdict.ticket_action_type`:**

The verdict file (monitoring-loop output) carries `ticket_action_type` (field 15 in the full
15-field mandatory schema — see §D-DEC-001 schema v2.0 and §5.3 updated field count). This
field is set by the monitoring-loop SKILL.md at Stage 7 (Ticket Action) and tells
disposition-guard exactly which Jira action is authorized:

```
verdict.ticket_action_type values (v1.6 — D-DEC-012 additions):
  "comment"        → disposition-guard issues comment marker (ticket_id from verdict)
  "create"         → disposition-guard issues create marker (ticket_id = null)
  "assign"         → disposition-guard issues assign marker (ticket_id from verdict)
  "none"           → disposition-guard does NOT issue any marker
                     (used when: autonomy_enabled=false + non-hard-floor; OR all surfacing done)
  "create-review"  → disposition-guard issues RESTRICTED review-create marker (D-DEC-012)
                     (used when: hard floor applies AND new review ticket needed)
                     EXEMPT from hard_floor_applies() + autonomy_enabled kill switch
  "comment-review" → disposition-guard issues RESTRICTED review-comment marker (D-DEC-012)
                     (used when: hard floor applies AND existing review ticket needs update)
                     EXEMPT from hard_floor_applies() + autonomy_enabled kill switch
```

**Emitter branch pseudocode (disposition-guard — v1.6 revision with enum-validation, autonomy_enabled, and review-surfacing path):**

```
# ── STEP 0: Dispatch precedence (ADV-F2-P4-001) ──────────────────────────────
# This pseudocode is entered AFTER the JSON-first dispatch routes the write to the
# verdict-class path (15-field check). The investigation-markdown path (12-field)
# has its own separate pseudocode and does NOT reach this emitter.
# See "Artifact-Class Field-Set Branching" above for canonical dispatch order.

# ── STEP 1: Enum-membership validation — fail-closed (ADV-F2-P4-006) ─────────
# Key-presence check (jq has()) alone is insufficient: severity:"High" passes has()
# but fails the {HIGH,CRITICAL} hard-floor membership test → no hard floor → marker
# issued for a genuinely HIGH-severity alert. Fail-closed deny on any non-member value
# prevents this class of bypass.
FUNCTION validate_enums(verdict):
  SEVERITY_ENUM    = {"LOW","MEDIUM","HIGH","CRITICAL"}
  ASSET_TYPE_ENUM  = {"domain_controller","privileged_account","ot_safety_system","standard","unknown"}
  DISPOSITION_ENUM = {"TP","FP","BTP","Indeterminate"}
  SENSOR_ENUM      = {"healthy","degraded","silent"}
  ACTION_ENUM      = {"comment","create","assign","none","create-review","comment-review"}
  CONFIDENCE_ENUM  = {"high","medium","low"}

  IF verdict.severity NOT IN SEVERITY_ENUM:
    RETURN (False, "severity '" + verdict.severity + "' not in allowed set")
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

# ── STEP 2: Extract ticket_action_type ───────────────────────────────────────
action = verdict.ticket_action_type   # "comment"|"create"|"assign"|"none"|"create-review"|"comment-review"

# ── STEP 3: Review-surfacing path (D-DEC-012) — gated on hook-computed hard_floor_applies() ──
# create-review and comment-review markers authorize human ESCALATION, not autonomous TRIAGE.
# Creating a [REVIEW-REQUIRED] or [BLIND-SPOT] ticket IS the human-surface mechanism — blocking
# it would silence a finding. These paths are EXEMPT from hard_floor_applies() and the
# autonomy_enabled kill switch ONLY WHEN the verdict is genuinely hard-floor.
#
# ADV-F2-P5-002 FIX — OVER-LABEL GATE: Gate the review-marker exemption on the hook-computed
# predicate hard_floor_applies(verdict). An LLM-supplied create-review/comment-review token on
# a verdict where hard_floor_applies() returns FALSE does NOT receive kill-switch or hard-floor
# exemption. The LLM cannot manufacture a kill-switch bypass by labeling a regular TP verdict
# as create-review. Such over-labeled verdicts emit allow without marker — the verdict write
# proceeds, but no jr action is authorized (require-review denies: no marker in store).
#
# O3 standing rule: every LLM-supplied routing field that grants or bypasses a security control
# (here: ticket_action_type granting kill-switch exemption and hard-floor bypass) MUST be
# cross-validated against a hook-computed invariant (here: hard_floor_applies()). This is the
# shared root cause of P5-001 and P5-002 — the hook trusted the LLM token without verifying it.
#
# Kill-switch / brief §3.9 conflict — RESOLVED (ADV-F2-P5-002):
# D-DEC-012 exempts create-review/comment-review from autonomy_enabled kill switch: review
# markers are issued and consumed (executing jr issue create/comment) even when
# autonomy_enabled=false. Brief §3.9 said the kill switch preserves "evidence collection
# and Jira DRAFTING" — which could be read as excluding live jr execution.
# Two options were identified:
#   Option A: amend the brief's "Jira drafting" language to include human-escalation writes;
#     review-ticket creation is not "autonomous triage" even when the kill switch is ON.
#   Option B: restrict create-review/comment-review execution to autonomy_enabled=true; kill
#     switch also halts escalation tickets (accept no-surface under kill switch).
# RESOLUTION — 2026-07-21: Human operator CONFIRMED Option A. Option B rejected.
# D-DEC-012 design is final: create-review/comment-review markers ARE issued and executed
# under autonomy_enabled=false when hard_floor_applies()=true (genuine hard-floor only per
# P5-002 gate). Brief §3.9 amendment delegated to product-owner (same burst).
#
# Iron Law (updated ADV-F2-P6-001): the monitoring-loop MUST:
# (1) only use create-review markers for tickets with [REVIEW-REQUIRED] or [BLIND-SPOT] labels
# (2) ALWAYS include `--label (REVIEW-REQUIRED|BLIND-SPOT)` as the SECOND fixed argument after
#     `--project <key>` in every `jr issue create` call for a review-path ticket
#     (mirrors the P4-002 Iron Law: --project in FIRST fixed position; review-label in SECOND)
# Require-review consumer STEP 6a NOW enforces both directions at the hook layer:
# - create-review marker rejected for any command lacking --label REVIEW-REQUIRED|BLIND-SPOT
# - create marker rejected for any command carrying --label REVIEW-REQUIRED|BLIND-SPOT
# SKILL.md Iron Law remains in force as defense-in-depth (ADV-F2-P6-001 adopted adoption).
IF action in {"create-review", "comment-review"}:
  IF NOT hard_floor_applies(verdict):
    # Over-label: non-hard-floor verdict with review token. Do NOT exempt from kill switch.
    # Emit allow for the document write; no review marker issued; jr action denied by require-review.
    emit allow without marker
    RETURN
  # Genuinely hard-floor verdict: issue review marker exempt from hard floor + kill switch.
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
      #
      # P9-008 STAGE-0 PRECONDITION (prevents livelock in production):
      # If jira_project_key was never stored (e.g., activate/onboard completed without it),
      # the loop will produce a HARD-FLOOR-UNBINDABLE deny on every re-doc attempt for every
      # hard-floor verdict, degrading to audit-only mode with no review tickets ever created.
      # Two mitigations required (PO obligations — BC-6.01.001 and BC-10.01.001):
      # (a) jira_project_key MUST be a hard Stage-0 precondition in activate/onboard: the
      #     activate and onboard-customer skills MUST refuse to complete if jira_project_key
      #     is not configured and validated (BC-6.01.001 obligation). The monitoring loop
      #     MUST NOT run without a valid jira_project_key in config.
      # (b) Re-doc attempt cap: the loop MUST track consecutive HARD-FLOOR-UNBINDABLE denies
      #     per-verdict-per-run. After 3 consecutive denies for the same verdict (indicating
      #     structural misconfiguration rather than a correctable re-doc), the loop MUST stop
      #     re-documenting that verdict and emit a single operator-facing failure artifact
      #     (to stderr and audit.log with audit code HARD-FLOOR-LIVELOCK-ABORT) then advance
      #     to the next verdict/sensor. This bounds LLM re-doc livelock to at most 3 cycles
      #     per finding and ensures the operator receives exactly one actionable failure signal.
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
      project_key_fallback = verdict.jira_project_key
      IF project_key_fallback is null OR project_key_fallback == "":
        fallback_hint = "jira_project_key also absent — re-issue with ticket_id (comment-review) or jira_project_key (create-review) populated."
      ELSE:
        # P9-007 DEDUP GATE: null ticket_id may indicate a dedup-lookup MISS (§3.4 query
        # failed to find an existing open BLIND-SPOT/REVIEW-REQUIRED ticket) rather than
        # true absence of a review ticket. Blindly switching to create-review risks creating
        # a DUPLICATE ticket for the same (org_slug, sensor_id), violating D-DEC-004's
        # one-open-ticket-per-(org_slug, sensor_id) rule. The fallback to create-review
        # is CONDITIONAL on the loop having re-run the §3.4 dedup query first.
        fallback_hint = "jira_project_key=" + project_key_fallback + " is present — BUT before re-issuing as create-review, the loop MUST re-run the §3.4 BLIND-SPOT/REVIEW-REQUIRED dedup query to confirm no open review ticket exists for this (org_slug, sensor_id). Null ticket_id may be a dedup-lookup miss; blindly switching to create-review risks duplicating a BLIND-SPOT/REVIEW-REQUIRED ticket (D-DEC-004 one-open-ticket violation). Re-run dedup first; only re-issue as create-review if dedup confirms no open ticket."
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
    pattern = "^jr (--output json )?issue comment " + ticket_id + " "
    ops = ["comment-review"]
    GOTO WRITE_MARKER

# ── STEP 4: Hard-floor check — DENY-THE-WRITE on under-label (ADV-F2-P7-001) [POSITIONED BEFORE KILL SWITCH — ADV-F2-P6-002] ──
# At this point action is a regular type (comment/create/assign/none) because review
# types were fully resolved at STEP 3.
#
# ADV-F2-P6-002 FIX — STEP REORDER (retained): this step executes BEFORE the autonomy_enabled
# kill switch (STEP 5). EC-012 case (d) semantics updated to deny-the-Write:
# "under-labeled hard-floor + autonomy_enabled=false → STEP 4 DENY-THE-WRITE fires FIRST;
# verdict Write denied with corrective reason; loop re-documents; STEP 3 issues review marker
# on corrected Write; kill switch (STEP 5) is only reached for non-hard-floor verdicts."
#
# ADV-F2-P7-001 REDESIGN — DENY-THE-WRITE (replaces P5-001/P6-002 marker-upgrade approach):
# The upgrade approach was proved structurally unsound by P7-001: the hook can rewrite the
# marker but cannot rewrite the loop's future Bash command. An under-labeled hard-floor
# verdict with action=create means the loop will run `jr issue create` WITHOUT `--label`
# — the create-review marker requires `--label` in fixed second position → require-review
# DENIES → ticket never created → CRITICAL finding silently dropped (3 of 4 under-label
# action types produced unconsumable markers). DENY-AT-WRITE is the only deterministic
# lever at the point the LLM can still react to the correction.
#
# Mechanism: disposition-guard DENIES the verdict Write itself, returning a structured
# machine-readable corrective reason instructing the loop to re-issue the Write with the
# correct review token. The loop re-documents; on the corrected Write, STEP 3 fires and
# issues the review marker normally.
#
# Corrective reason structure (machine-readable fields in the deny message):
#   hard_floor_trigger  — which condition fired: "severity=HIGH|CRITICAL", "asset_type=<val>",
#                          "technique=<T-NNN>", or "Indeterminate"
#   required_token      — "create-review" if verdict.ticket_id is null;
#                          "comment-review" if verdict.ticket_id is present
#   label_instruction   — for create-review: "--label (REVIEW-REQUIRED|BLIND-SPOT) MUST be
#                          SECOND arg after --project <key>"; for comment-review: N/A
#   instruction         — "re-issue this verdict Write with ticket_action_type=<required_token>"
#
# Loop-side obligation (for PO to propagate into BC-10.01.001):
#   On a STEP-4 deny, the loop MUST re-issue the verdict Write with ticket_action_type set
#   to the required_token from the deny reason. The deny reason is machine-readable enough
#   to act on. On the corrected Write, STEP 3 issues the review marker normally.
#
# Non-termination analysis:
#   If the loop never re-documents after a STEP-4 deny: the deny reason + UNDER-LABEL-DENIED
#   audit entry ARE the loud failure. No Jira write ever occurs (require-review has no marker
#   to consume). This is ACCEPTABLE fail-closed behavior vs the silent-allow the upgrade
#   approach produced: an operator monitoring audit.log sees UNDER-LABEL-DENIED entries;
#   no finding is silently lost — it is loudly rejected. The loop failing to re-document is
#   a loop implementation defect (BC-10.01.001 conformance violation), detectable by
#   VP-HOOK-029's consumer-boundary assertion (authorized jr write occurs on corrected re-doc).
#   Bounded: the deny produces exactly one auditable artifact per Write attempt; no silent loop.
#
IF hard_floor_applies(verdict):
  ticket_id_val = verdict.ticket_id
  # Compute required_token for the corrective reason
  IF ticket_id_val IS NULL OR ticket_id_val == "":
    required_token    = "create-review"
    project_key       = verdict.jira_project_key
    IF project_key IS NULL OR project_key == "":
      label_instruction = "--label (REVIEW-REQUIRED|BLIND-SPOT) SECOND after --project <jira_project_key absent — must be set in verdict>"
    ELSE:
      label_instruction = "--label (REVIEW-REQUIRED|BLIND-SPOT) MUST be SECOND arg after --project " + project_key
  ELSE:
    required_token    = "comment-review"
    label_instruction = "ticket_id=" + ticket_id_val + " (comment-review path; no --label required)"

  # Identify the hard-floor trigger for the corrective reason
  hard_floor_trigger = identify_hard_floor_trigger(verdict)
  # identify_hard_floor_trigger() returns the first matching floor:
  #   "Indeterminate" | "severity=<HIGH|CRITICAL>" | "asset_type=<val>" |
  #   "technique=<T-NNN>" | "sensor_health_status=<degraded|silent>"

  WRITE audit entry:
    "UNDER-LABEL-DENIED: hard-floor verdict with action='" + action +
    "'; hard_floor_trigger=" + hard_floor_trigger +
    "; required_token=" + required_token +
    "; verdict Write denied by disposition-guard (ADV-F2-P7-001)"

  emit deny(
    "HARD-FLOOR-UNDER-LABEL: verdict Write denied. " +
    "hard_floor_trigger=" + hard_floor_trigger + ". " +
    "required_token=" + required_token + ". " +
    label_instruction + ". " +
    "Re-issue this Write with ticket_action_type='" + required_token + "'. " +
    "On corrected Write, STEP 3 will issue the review marker normally."
  )
  RETURN   # DO NOT issue any marker; DO NOT GOTO WRITE_MARKER

# ── STEP 5: autonomy_enabled kill switch (ADV-F2-P4-005) [REORDERED AFTER HARD-FLOOR — ADV-F2-P6-002] ──
# autonomy_enabled is a NON-ICD-203 operational metadata field in the verdict JSON (alongside
# jira_project_key and confidence_score). Disposition-guard reads it directly from the verdict
# file. Default-false (conservative): if field absent or non-boolean, treat as false.
# This makes the kill switch deterministic — not delegated to the monitoring-loop LLM.
#
# ADV-F2-P6-002: After reorder, this STEP 5 is only reached for non-hard-floor verdicts.
# Hard-floor under-labeled verdicts (STEP 4 above) and correctly-labeled review verdicts
# (STEP 3 above) both exit before reaching this point. The kill switch now fires exclusively
# for regular-action, non-hard-floor verdicts — the intended semantic.
autonomy_enabled = verdict.autonomy_enabled   # non-ICD-203 operational field; default false
IF autonomy_enabled is NOT exactly true:
  emit allow without marker      # kill switch fires; evidence write proceeds; no Jira action
  RETURN

# action == "none" reaches here only when hard_floor_applies() is FALSE (non-hard-floor)
IF action == "none":
  emit allow without marker      # explicit none; non-hard-floor; ICD-203 document is valid
  RETURN

# ── STEP 6: Regular marker issuance (non-hard-floor, autonomy-enabled) ───────
IF action == "comment":
  ticket_id = verdict.ticket_id
  IF ticket_id is null: emit allow without marker; RETURN
  pattern = "^jr (--output json )?issue comment " + ticket_id + " "
  ops = ["comment"]

ELIF action == "create":
  ticket_id = null
  # ADV-F2-P3-002: org-bind via Jira project key (non-ICD-203 operational metadata field)
  # ADV-F2-P4-002: --project is FIRST arg; trailing ( |$) prevents prefix-match
  project_key = verdict.jira_project_key
  IF project_key is null OR project_key == "":
    emit allow without marker
    RETURN
  pattern = "^jr (--output json )?issue create --project " + project_key + "( |$)"
  ops = ["create"]

ELIF action == "assign":
  ticket_id = verdict.ticket_id
  IF ticket_id is null: emit allow without marker; RETURN
  pattern = "^jr (--output json )?issue assign " + ticket_id + " "
  ops = ["assign"]

# ── WRITE_MARKER: common path for all marker types ───────────────────────────
WRITE_MARKER:
expires_at = now() + 120s             # absolute expiry (schema v2.0)
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
    severity: verdict.severity,         # field 13 — required for hard floor check
    asset_type: verdict.asset_type,     # field 14 — required for hard floor check
    ticket_action_type: action          # for audit trail (includes create-review/comment-review)
  }
}
write_marker(marker, "${CLAUDE_PLUGIN_DATA}/markers/${marker.marker_id}.marker.json")
emit allow
```

Require-review validates the `command_pattern` with an anchored match. A marker with
`authorized_operations: ["comment"]` CANNOT authorize a `jr issue create` command because
`^jr (--output json )?issue comment SEC-123 ` does not match `jr issue create ...`.

**Hard floor binding (§3.9 — unconditional code branches) [v2.0 — ADV-F2-001 fix]:**

The monitoring-loop skill contains unconditional if-blocks for the hard floor categories.
**Hard floors are enforced at BOTH layers:** (1) in the monitoring-loop SKILL.md (controls
whether disposition-guard is even invoked with a ticket_action_type of "none"); and (2) in
disposition-guard itself (validates verdict.severity + verdict.asset_type — the definitive
enforcement surface that the LLM cannot bypass). This dual enforcement is defense-in-depth.

**ADV-F2-001 critical fix:** Hard floors key on `verdict.severity` and `verdict.asset_type`
(mandatory fields 13 and 14), NOT on `verdict.confidence`. Severity and confidence are
orthogonal axes. A HIGH-confidence FP verdict on a HIGH-severity alert is still a hard floor.
The prior design that keyed on confidence was a latent bypass: HIGH-severity + low-confidence
would have escaped the hard floor if `confidence` had been used as the severity proxy.

```
# Hard floors — these branches are NOT config-evaluated
# autonomy_enabled=true does NOT override these for regular markers.
# D-DEC-012: create-review and comment-review ticket_action_types are NOT subject to this
# function — they bypass hard_floor_applies() entirely (see emitter Step 3 above). The
# hard floor correctly blocks autonomous TRIAGE; it does NOT block human ESCALATION.

# FUNCTION: hard_floor_applies(verdict) — called by emitter for regular (non-review) markers
hard_floor_applies(verdict):

  IF verdict.disposition == "Indeterminate":
    RETURN TRUE   # → NEVER issue marker; route to human; [REVIEW-REQUIRED]

  # ADV-F2-001: key on verdict.severity (field 13), NOT confidence
  IF verdict.severity in {"HIGH", "CRITICAL"}:
    RETURN TRUE   # → NEVER issue marker; route to human

  # ADV-F2-001: key on verdict.asset_type (field 14)
  # ADV-F2-P3-001 CRITICAL FIX: asset_type=unknown is a conservative hard-floor member.
  # BC-10.01.001 v1.7 Inv#10 + EC-021 applied this policy (ORCHESTRATOR POLICY DECISION
  # ADV-F2-P2-010) to BOTH the monitoring-loop SKILL.md AND disposition-guard. This
  # pseudocode previously omitted unknown, creating a gap: a LOW-severity + unknown asset
  # + benign technique verdict could receive a marker from the deterministic hook even
  # though the BC said it should not. Closing the gap here.
  # CRITICAL_ASSET_TYPES = {domain_controller, privileged_account, ot_safety_system}
  # unknown is added as a SEPARATE explicit check (not folded into CRITICAL_ASSET_TYPES)
  # so that PO can independently extend CRITICAL_ASSET_TYPES without confusion.
  IF verdict.asset_type in CRITICAL_ASSET_TYPES:  # domain controllers, OT safety, privileged accts
    RETURN TRUE   # → NEVER issue marker; route to human

  IF verdict.asset_type == "unknown":  # ADV-F2-P3-001: conservative floor for unclassified assets
    RETURN TRUE   # → NEVER issue marker; "could not classify" ≠ "low risk" (§3.7 mirror)

  IF any technique in verdict.attack_techniques in {"T1003","T1068","T1021","T1041"}:
    RETURN TRUE   # → NEVER issue marker; route to human

  IF verdict.sensor_health_status in {"degraded", "silent"}:
    RETURN TRUE   # → verdict is Indeterminate-due-to-missing-telemetry; never issue marker

  RETURN FALSE    # all hard floors pass

# Only after all hard floors pass (for regular markers):
# Note: create-review/comment-review bypass hard_floor_applies() — see D-DEC-012.
# Note: autonomy_enabled is validated as a verdict field (not config) — see emitter STEP 5 (ADV-F2-P6-002 reorder).
IF autonomy_enabled == true AND NOT hard_floor_applies(verdict):
  → disposition-guard validates all 15 ICD-203 fields + enum-membership (ADV-F2-P4-006)
  → disposition-guard issues scoped marker per verdict.ticket_action_type
  → monitoring-loop proceeds with jr issue comment/create/assign as marker authorizes
```

The `autonomy_enabled` config flag ADDS restrictions (restricts auto-approve further); it
NEVER removes a hard floor. This is the invariant the BATS tests must verify:

```bats
@test "disposition-guard hard floor: Indeterminate verdict with create action → verdict Write DENIED, UNDER-LABEL-DENIED in audit.log, required_token=create-review (P7-001)"
@test "disposition-guard hard floor: HIGH severity + create action → verdict Write DENIED, corrective reason specifies required_token=create-review (P7-001)"
@test "disposition-guard hard floor: degraded sensor + comment action → verdict Write DENIED, corrective reason specifies required_token=comment-review (P7-001)"
@test "disposition-guard hard floor: Indeterminate + none action + ticket_id present → verdict Write DENIED, required_token=comment-review (P7-001)"
@test "disposition-guard hard floor: Indeterminate + none action + ticket_id null + project_key absent → verdict Write DENIED, corrective reason includes missing project_key note (P7-001)"
@test "disposition-guard hard floor: Indeterminate + correct token create-review (after loop re-doc) → STEP 3 fires, restricted review marker emitted (P7-001 corrected path)"
@test "disposition-guard review path: Indeterminate verdict with create-review action → restricted review marker emitted (no hard floor block)"
@test "disposition-guard review path: silent sensor verdict with comment-review action → restricted review marker emitted"
@test "disposition-guard review path: non-hard-floor TP verdict with create-review action → emit allow WITHOUT marker (P5-002 over-label gate)"
@test "disposition-guard review path: non-hard-floor BTP verdict with comment-review + autonomy_enabled=false → no kill-switch bypass; emit allow without marker (P5-002)"
@test "disposition-guard kill switch: autonomy_enabled=false + create action (non-hard-floor) → no marker emitted"
@test "disposition-guard kill switch: autonomy_enabled=false + Indeterminate + create-review → review marker IS emitted (kill switch exemption for genuine hard-floor)"
@test "disposition-guard enum validation: severity='High' (wrong case) → deny, no marker"
@test "disposition-guard enum validation: ticket_action_type='NONE' (wrong case) → deny, no marker"
@test "disposition-guard audit: UNDER-LABEL-DENIED entry written to audit.log on under-label deny (P7-001)"
```

These tests simulate hard-floor inputs and assert the marker directory state (empty for blocked
paths; review marker present for review paths). Enum validation tests use malformed verdict JSON
with non-member field values.

#### Consequences

The marker issuance path in disposition-guard must check `verdict.disposition` against the
hard floor list BEFORE issuing a marker. This check is enforced inside disposition-guard
(a deterministic hook), not in the monitoring-loop skill (LLM-executed). This is the correct
purity boundary: LLM proposes the disposition; deterministic hook enforces the hard floor.

#### Alternatives Rejected

**Single global-scope marker (authorizes any operation):** Rejected. A global-scope marker
would allow a comment-scoped disposition (FP cleanup) to also authorize ticket creation,
which is a higher-privilege operation. Per-operation scoping follows principle of least
privilege.

**Config-evaluated hard floors:** Rejected. R-001 explicitly states hard floors must be
unconditional code branches. A config-evaluated `require_review: ["HIGH", "CRIT"]` list
could be misconfigured (missing a severity level, wrong string), silently widening the
auto-approve surface. Unconditional if-blocks cannot be misconfigured.

#### Pipeline Ordering Invariants (ADV-F2-P2-001 + ADV-F2-P2-002 fixes)

**Document-Before-Action: verdict Write (Stage 7 DOCUMENT) MUST precede jr execution (Stage 8 TICKET ACTION).**

This is the load-bearing sequencing invariant that makes the marker mechanism reachable.

```
Stage 7: DOCUMENT
  monitoring-loop writes the ICD-203 verdict file (all 15 mandatory fields,
  including ticket_action_type set at Stage 6 DISPOSE)
    → disposition-guard PreToolUse/Write event fires
    → validates all 15 fields
    → if no hard floor AND ticket_action_type != "none":
         atomically writes scoped marker to ${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json

Stage 8: TICKET ACTION
  monitoring-loop executes jr issue comment/create/assign
    → require-review PreToolUse/Bash event fires
    → scans ${CLAUDE_PLUGIN_DATA}/markers/ → finds the marker emitted at Stage 7
    → iterative consume: first successful atomic rename → allow
```

If TICKET ACTION precedes DOCUMENT (as in BC-10.01.001 Invariant #14 prior to v1.4,
and brief §3.2 which carried the same defective Stage 7/8 labels): no marker exists when
require-review evaluates the jr Bash call → every autonomous Jira write is denied → the
monitoring-loop can never auto-action. This ordering inversion was the root cause of the
ADV-F2-P2-001 CRITICAL finding.

The corrected canonical stage labels for the per-alert pipeline tail:
- **Stage 7: DOCUMENT** — write verdict → disposition-guard fires → marker emitted (if authorized)
- **Stage 8: TICKET ACTION** — execute jr → require-review fires → marker consumed

`ticket_action_type` (field 15) is determined at Stage 6 (DISPOSE), not at Stage 7. Stage 6
is where the loop decides comment/create/assign/none based on disposition + Jira-first lookup.
Field 15 is written into the verdict draft, which is then written at Stage 7. Disposition-guard
reads it from the verdict file at issuance time. This sequence is correct and load-bearing.

No VP currently guards this ordering (ADV-F2-P2-014/obs). The formal-verifier must add a
cross-hook integration VP: a jr write in the monitoring-loop is denied unless a verdict Write
(matching the same loop run) preceded it within the TTL window (see §8.7 item 4).

BC-10.01.001 Invariant #14 must be updated to the corrected stage ordering (see §8.6 item 1).
The brief §3.2 loop pseudocode must also be reconciled in the same BC update.

**Verdict-File-Path Naming Convention (ADV-F2-P3-005 — Fix E):**

The monitoring-loop Stage 7 DOCUMENT step MUST write the verdict file to a path that
contains the substring `verdict`. disposition-guard PC#1 fast-path-allows any `file_path`
that contains neither `investigation` nor `verdict` — emitting allow without ICD-203
validation and WITHOUT marker issuance. If Stage 7 writes to a non-matching path (e.g.,
`artifacts/findings/alert-001.json`), the fast-path fires, no marker is written, and every
Stage 8 `jr issue comment/create/assign` is permanently denied by require-review (no marker
to consume). This makes the entire autonomous write pipeline unreachable.

**Canonical verdict file path pattern:** `artifacts/investigations/verdict-<alert_id>-<iso_ts>.json`
The string `verdict` MUST appear in the file path.

BC-10.01.001 must add this as an explicit Stage 7 precondition (PO owns — see §8.8).
BC-3.03.001 PC#1 fast-path is CORRECT as-is; the fix is on the monitoring-loop Stage 7 naming.

**Artifact-Class Field-Set Branching (ADV-F2-P3-003 — Fix C; dispatch-precedence fix ADV-F2-P4-001):**

disposition-guard applies DIFFERENT ICD-203 mandatory-field validation depending on artifact
class. **ADV-F2-P4-001 CRITICAL FIX:** Dispatch is JSON-first. The canonical verdict path
`artifacts/investigations/verdict-<alert_id>-<iso_ts>.json` contains BOTH the `investigation`
directory component AND the `verdict` filename component. Plain substring dispatch routes this
path to the investigation-markdown (12-field) branch, which then fails heading-grep assertions
on a JSON file → DENY → no marker → autonomous pipeline unreachable. JSON-first dispatch
resolves the collision.

**Canonical dispatch order (most specific first):**

1. **JSON-content check (verdict-class):** If `tool_input.file_path` ends in `.json` OR
   `tool_input.content` parses as valid JSON (`jq empty 2>/dev/null` succeeds) → route to
   **VERDICT JSON path** (15-field jq key-presence + type check). This check takes absolute
   precedence regardless of any `investigation` substring in the path.
2. **Investigation-markdown check:** Elif `tool_input.file_path` matches `*investigation-*.md`
   (must end in `.md`) → route to **INVESTIGATION MARKDOWN path** (12-field heading-anchored grep).
3. **Fast-path allow:** Else → `emit allow` without any ICD-203 enforcement (neither artifact
   class applies).

| Artifact Class | Dispatch condition (evaluated in order) | Field-set enforced | Source |
|----------------|----------------------------------------|--------------------|--------|
| Verdict JSON | ends in `.json` OR content is valid JSON | **15 fields** (12 ICD-203 + severity + asset_type + ticket_action_type) | Monitoring-loop (BC-10.01.001) |
| Investigation markdown | `*investigation-*.md` glob (`.md` required) | **12 ICD-203 fields** | Human investigate-event workflow (BC-5.01.001) |
| Fast-path allow | neither condition above | None | — |

**BC-3.03.001 PC#1/PC#2/PC#3 must be rewritten to implement this JSON-first dispatch order
(PO obligation — see §8.10 item 1). VP-HOOK-028 must add a BATS test for the canonical
`artifacts/investigations/verdict-*.json` path routing to the verdict-class branch, not the
investigation-markdown branch.**

**Investigation 12-field set:** Disposition, Confidence, Sensor Health Status, Evidence
Artifacts, Timeline Events, Hypotheses Considered, Alternatives Rejected, Uncertainty
Explicit, Attack Techniques, Agent Actions, Human Actions, Tuning Signal.

**Verdict 15-field set:** Above 12 plus Severity, Asset Type, Ticket Action Type.

**ERRATUM — BC-3.03.001 v1.11 PC#2 (investigation path) incorrectly states 15 mandatory
field headings.** The three additional headings (Severity, Asset Type, Ticket Action Type)
are monitoring-loop verdict schema fields, not human investigation fields. "Ticket Action
Type" has no meaning in a human-authored investigation document. BC-5.01.001 v1.7
Invariant #7 correctly states "12-field validation" — this citation is CORRECT and
BC-3.03.001 PC#2 is the document in error. PO must correct BC-3.03.001 PC#2 to "12
mandatory field headings" for the investigation markdown path (see §8.8). VP-HOOK-025
must then reflect the per-class field counts in BATS test expectations.

**Stage 3 (CATEGORIZE) required before EC-009 known-FP fast-exit auto-close. (ADV-F2-P2-002 fix)**

Hard-floor function `hard_floor_applies()` checks `verdict.attack_techniques` against
{T1003, T1068, T1021, T1041}. This field is populated at Stage 3 (CATEGORIZE — MITRE
ATT&CK mapping). If the EC-009 known-FP fast-exit bypasses Stage 3, `verdict.attack_techniques`
is an empty array. An empty array passes all technique floor checks (no elements to test
against the forbidden set) → a T1003 credential-dumping alert masked by a known-FP pattern
auto-closes without human review.

**Constraint (architecture binding decision):** On the known-FP fast-exit path, Stage 3
(MITRE ATT&CK mapping) still executes. The fast-exit skips only Stages 4–5 (enrichment
and enrichment-recalibrated scoring). Hard-floor evaluation uses the completed Stage 3 output.
The EC-009 "skip Stages 3–6" wording in the BC is incorrect and must be corrected to
"skip Stages 4–5 enrichment/scoring" (see §8.6 item 2).

**Fast-path fields 13/14 population source:** On the known-FP path (Stage 5 SCORE bypassed),
`verdict.severity` (field 13) and `verdict.asset_type` (field 14) are populated from the raw
sensor event data at Stage 1 (INGEST), not from Stage 5 recalibration. The monitoring-loop
SKILL.md must extract severity and asset_type from the sensor event record and populate them
in the verdict draft prior to Stage 3 execution. BC-10.01.001 EC-009 must state this source
explicitly (see §8.6 item 2).

---

### D-DEC-009 — Tavily MCP Dependency Tier

#### Context

Monitoring-loop Stage 4 uses Tavily for web-grounded IOC/actor/CVE enrichment as a
cross-validation layer alongside Perplexity. If Tavily is unavailable, the loop must
not fail.

#### Decision

**Tavily MCP is `recommended` — explicit fallback to Perplexity-only enrichment.**

secops-protocol.md entry for Tavily must document:

```
If mcp__tavily__tavily_search / mcp__tavily__tavily_extract are unavailable or return
tool-not-found errors:
1. Log degradation: add to agent_actions: {ts_utc, action: "tavily_unavailable",
   result: "degraded_to_perplexity_only", requires_human_approval: false}
2. Set uncertainty_explicit: "Tavily web enrichment unavailable; external context from
   Perplexity only — cross-validation quality reduced"
3. Proceed with Perplexity-only enrichment (Stage 4c)
4. Do NOT abort the monitoring-loop run
5. DO NOT set verdict to Indeterminate solely because Tavily is unavailable
   (Tavily absence is degraded quality, not missing sensor data)
```

The monitoring-loop SKILL.md Iron Law must encode this precedence:
`NO WEB ENRICHMENT ABORT WITHOUT ATTEMPTING PERPLEXITY FALLBACK FIRST`

#### Consequences

If both Perplexity AND Tavily are unavailable simultaneously, Stage 4 proceeds with
prism ThreatIntel/NVD enrichment only. The verdict is still actionable for most
dispositions. The `uncertainty_explicit` field documents the enrichment gap.

This is consistent with the existing fallback pattern: `data/event-investigation-best-practices.md`
already documents Perplexity-unavailable fallback to WebSearch/WebFetch.

#### Alternatives Rejected

**Tavily `required`:** Rejected. Making Tavily required would cause every monitoring-loop
run to abort if Tavily MCP is down for any reason (API outage, credential expiry, config
error). This would silence the entire alert triage pipeline — worse than reduced enrichment
quality. Alert triage must continue even in degraded enrichment conditions.

---

### D-DEC-010 — Unattended Permission Model for the Monitoring-Loop Cron Invocation

#### Context

The ASM-004 probe used `--dangerously-skip-permissions` to suppress interactive approval
prompts for unattended cron runs. A blanket permission bypass weakens the defense-in-depth
story: Claude Code's own tool-permission layer (the interactive "allow this tool?" gate)
is bypassed entirely. However, the key question is which controls are preserved vs. removed.

**What `--dangerously-skip-permissions` removes:**
- Interactive per-tool approval prompts (the "Do you want to allow X?" UX gates)
- Tool category restrictions configured via `settings.json` permissions blocks

**What `--dangerously-skip-permissions` does NOT remove:**
- Hook enforcement layer — require-review, disposition-guard, enrichment-completeness all
  still fire on their respective Claude Code tool events
- The marker mechanism (D-DEC-001) still gates all Jira write operations
- Hard floor branches in the monitoring-loop SKILL.md still prevent auto-close of
  HIGH/CRIT/Indeterminate categories
- `autonomy_enabled` kill switch still halts all autonomous actions

The net risk of blanket bypass: Claude could attempt to write files in unexpected
locations, execute arbitrary Bash commands, or call MCP tools beyond prism/tavily/perplexity.
The `--allowedTools` flag provides a narrower alternative.

#### Decision

**Use `--allowedTools` with an explicit scoped allowlist. Do NOT use `--dangerously-skip-permissions`.**

The cron wrapper script (D-DEC-003) passes:

```
--allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__tavily__tavily_extract,mcp__perplexity__perplexity_ask,mcp__perplexity__perplexity_search,Bash,Write,Read,Edit"
```

**Allowlist rationale — each tool's inclusion justified:**

| Tool | Inclusion reason | Scope constraint |
|------|-----------------|-----------------|
| `mcp__prism__*` | All prism MCP tools needed (query, prism_describe, prism_sensor_health, capabilities) | Restricted to prism server only via `--strict-mcp-config` |
| `mcp__tavily__tavily_search` | Stage 4 web-grounded IOC/CVE enrichment (D-DEC-009 recommended) | Enrichment only; no write surface |
| `mcp__tavily__tavily_extract` | Stage 4 content extraction for CVE pages | Enrichment only; no write surface |
| `mcp__perplexity__perplexity_ask` | Stage 4 threat actor/IOC context | Enrichment only; no write surface |
| `mcp__perplexity__perplexity_search` | Stage 4 external threat intelligence lookup | Enrichment only; no write surface |
| `Bash` | jr CLI calls for ticket actions; prism connectivity probe at Stage 0 | **Guarded by require-review hook** — all `jr issue comment/create/assign` calls still go through the hook enforcement layer |
| `Write` | Watermark persistence (`${CLAUDE_PLUGIN_DATA}/watermarks/`); verdict file writes | Marker-gated before Jira write; watermark is isolated to CLAUDE_PLUGIN_DATA |
| `Read` | Watermark reads; prism.toml org enumeration; verdict file reads | Read-only; no security concern |
| `Edit` | Verdict file updates (appending evidence artifacts after enrichment) | Marker-gated before Jira write |

**Tools intentionally excluded from the allowlist:**

| Tool | Exclusion reason |
|------|----------------|
| `WebFetch`, `WebSearch` | Perplexity/Tavily MCP tools cover enrichment needs; raw web access is unnecessary surface area in unattended context |
| `mcp__context7__*` | Library docs not needed for runtime alert triage |
| `computer_use` | Never needed; excluded from all monitoring-loop execution paths |
| Any other MCP tool | `--strict-mcp-config` already limits available MCP servers; `--allowedTools` provides defense-in-depth |

**Residual risks with the `--allowedTools` approach:**

| Risk | Severity | Mitigation |
|------|----------|-----------|
| `Bash` tool allows arbitrary shell commands | MEDIUM | require-review hook gates all `jr` write operations; the monitoring-loop is a fixed SKILL.md, not a REPL; BATS tests for hard floors provide invariant coverage |
| `Write` tool allows writes to arbitrary paths accessible to the process | LOW | Monitoring-loop SKILL.md's Iron Law (`NO JIRA UPDATE WITHOUT EVIDENCE CHAIN FIRST`) constrains write targets; artifact paths are `${CLAUDE_PLUGIN_DATA}/watermarks/` and `artifacts/investigations/` by convention |
| Allowlist must be kept in sync with SKILL.md evolution | LOW | Document allowlist in monitoring-loop SKILL.md Prerequisites section; Wave 7 story acceptance criteria includes "cron wrapper allowlist matches tools referenced in SKILL.md stages" |
| `--allowedTools` may not support glob patterns for MCP tools | LOW | ASM-004 probe confirmed `--allowedTools "mcp__prism__*"` syntax; verify in Wave 7 story implementation test |

**Compensating controls (defense-in-depth stack, lowest→highest):**

1. `--strict-mcp-config --mcp-config ~/.claude/prism.mcp.json` — only prism MCP server available; no other MCP server injection possible
2. `--allowedTools` scoped allowlist — bounds the tool surface to exactly what the loop needs
3. **require-review hook** — THE load-bearing Jira auth gate; fires on all Bash tool calls; marker mechanism gates comment/create/assign (D-DEC-001); cannot be bypassed by `--allowedTools` or permission settings
4. disposition-guard hook — ICD-203 mandatory-field enforcement; sole emitter of markers; hard floor enforcement at issuance time (D-DEC-008)
5. Hard floor unconditional code branches in monitoring-loop SKILL.md — Indeterminate/HIGH/CRIT/degraded-sensor categories never get markers regardless of `autonomy_enabled`
6. `autonomy_enabled: false` (default) kill switch — halts all autonomous Jira actions; preserves evidence collection and drafting only
7. `--output-format json` result validation in wrapper script — `is_error` and `permission_denials` fields gate scheduler-level failure detection

**`--bare` is explicitly prohibited:** The `--bare` flag disables the hook enforcement layer
(hooks do not fire in bare mode). Using `--bare` for the monitoring-loop would bypass
require-review, removing the sole hard gate on Jira writes. This is a critical security
regression. The cron wrapper script MUST NOT include `--bare`. A BATS test for the wrapper
script must assert the absence of `--bare` in the command it constructs.

#### Consequences

Positive:
- Narrower tool surface than `--dangerously-skip-permissions` — principle of least privilege
- Explicit allowlist documents exactly what the monitoring-loop needs, making future SKILL.md
  changes visible as allowlist maintenance tasks
- require-review hook, disposition-guard hook, and hard floors remain fully operational —
  defense-in-depth is preserved
- No blanket permission bypass that could silently widen scope as Claude evolves

Negative:
- If the monitoring-loop SKILL.md references a new tool not in the allowlist, the cron run
  silently skips that tool call without error — BATS must verify that all tools referenced
  in the SKILL.md stages appear in the allowlist before Wave 7 story merge
- `--allowedTools` glob support for MCP tools must be verified empirically in Wave 7
  (ASM-004 Probe 2 confirmed `mcp__filesystem__*` via the flag but prism-specific test
  is still needed — add as Wave 7 acceptance criterion)

#### Alternatives Rejected

**`--dangerously-skip-permissions` (blanket bypass):** Rejected. Allows Claude to call any
tool without restriction, broadening the blast radius of a rogue invocation. Although the
hook layer (require-review, disposition-guard) is preserved, allowing arbitrary Bash without
tool-level gating is unnecessarily permissive. The `--allowedTools` approach is strictly safer.

**Dedicated `--settings` permission profile:** The `--settings` flag was confirmed in
ASM-004 Probe 3 NOT to honor `mcpServers`. Its behavior with a `permissions` block was not
tested; given the MCP failure, this path cannot be relied upon for the cron invocation.
The `--allowedTools` CLI flag is empirically confirmed (Probe 2). Rejected in favor of the
confirmed mechanism.

**No permission restriction (interactive session only, no cron):** Rejected. The monitoring-loop
is explicitly designed for unattended scheduled operation (brief §3.10). Restricting it to
interactive-only would negate the core product capability.

---

### D-DEC-011 — Confidence Float→Enum Contract Between assess-priority and Monitoring-Loop Verdict

#### Context

BC-4.05.001 (assess-priority) outputs a float posterior confidence score (0.0–1.0) at
PC#6. BC-10.01.001 Invariant #9 field #2 specifies `confidence: high|medium|low` (enum).
VP-HOOK-025 type-asserts the enum via `jq`. There is no specified mapping between the float
posterior and the enum — disposition-guard's jq check on a float `confidence` value fails
the enum type assertion, blocking the marker. ADV-F2-P3-008 identified this as an unresolved
contract gap.

#### Decision

**Canonical float→enum mapping (D-DEC-011):**

| Float posterior | Mapped enum | Rationale |
|-----------------|-------------|-----------|
| ≥ 0.75 | `"high"` | Strong evidence convergence; analyst-level confidence |
| ≥ 0.40 and < 0.75 | `"medium"` | Reasonable evidence; some uncertainty present |
| < 0.40 | `"low"` | Insufficient evidence convergence; escalation likely |

These thresholds are NOT configurable per-tenant in v0.10.0. They define the architectural
contract between the scoring layer (BC-4.05.001) and the verdict schema (BC-10.01.001 Inv#9).

**Output contract for assess-priority (BC-4.05.001 PC#6):**

assess-priority MUST output BOTH:
1. `confidence_score` (float 0.0–1.0): the raw Bayesian posterior — for audit/transparency
2. `confidence` (enum `high|medium|low`): the mapped enum — for the verdict schema field #2

The monitoring-loop reads the `confidence` enum directly into the verdict at Stage 5 SCORE.
The `confidence_score` float is included in the verdict's agent_actions or evidence_artifacts
for audit chain-of-custody but is NOT field #2.

disposition-guard validates `confidence` (field #2) as enum via:
```
jq -e '.confidence | . == "high" or . == "medium" or . == "low"'
```

A raw float in field #2 FAILS this check and blocks marker issuance — correct behavior (the
monitoring-loop must use the enum, not the raw score).

#### Consequences

PO must align BC-4.05.001 PC#6 to output both `confidence_score` (float) and `confidence`
(enum) with the thresholds above. BC-10.01.001 Invariant #9 field #2 definition must
explicitly state the enum values and reference D-DEC-011 for the mapping. VP-HOOK-025 BATS
test must assert enum type (not float) — update `@test "disposition-guard denies verdict
with float confidence (not enum)"` and add `@test "disposition-guard allows verdict with
confidence='high'"`. A new VP (see §8.9) covers the float→enum mapping fidelity.

#### Alternatives Rejected

**Accept float in field #2:** Rejected. disposition-guard's jq enum assertion is load-bearing
(prevents free-text or numeric confidence from bypassing hard-floor checks that rely on
field presence). Changing the type contract widens the attack surface. The correct fix is
at the producer layer (assess-priority must emit the enum).

**Configurable thresholds:** Rejected for v0.10.0. Configurable thresholds create a new
attack surface (deliberately low-balled `high` threshold bypasses conservative dispositions).
Fixed architectural thresholds are BATS-testable invariants. Defer configurable thresholds
to a future hardening cycle with explicit threat modeling.

---

### D-DEC-012 — Review-Ticket Surfacing Path for Hard-Floor Verdicts (ADV-F2-P4-004)

#### Context

Hard-floor verdicts (Indeterminate, silent/degraded sensor, HIGH/CRIT severity, critical asset,
hard-floor technique) unconditionally block marker issuance under D-DEC-008. This correctly
prevents autonomous TRIAGE actions (auto-close, auto-FP, auto-escalation). However, D-DEC-004
and BC-10.01.001 EC-006/EC-014 require the monitoring-loop to create `[BLIND-SPOT]` and
`[REVIEW-REQUIRED]` tickets for these same verdicts. In unattended cron mode (D-DEC-003: no
interactive shell, no human to approve the permission dialog), a denied `jr issue create` is
permanently lost — not deferred, not queued, silently dropped. This contradicts brief §3.7:
"Absence of expected data is a first-class alert, not a null result."

The tension is an architectural design gap: BC-10.01.001 Inv#10 ("hard floor → ticket_action_type=none")
and EC-006/EC-014 ("autonomously create BLIND-SPOT/REVIEW-REQUIRED ticket") are mutually exclusive
for silent/Indeterminate verdicts. The hard floor correctly prevents autonomous decisions; it
incorrectly also prevents autonomous ESCALATION (creating a human-review ticket explicitly asks
a human to decide — this is the opposite of an autonomous decision).

#### Decision

**Introduce `ticket_action_type = "create-review"` and `"comment-review"` as RESTRICTED
marker types for hard-floor verdict surfacing.**

**Core principle:** Creating a `[REVIEW-REQUIRED]` or `[BLIND-SPOT]` ticket is human ESCALATION,
not autonomous TRIAGE. The hard-floor rule ("never issue a marker that authorizes autonomous
triage") does not apply to markers that authorize only escalation-tagged ticket creation.
Therefore, `create-review` and `comment-review` markers are EXEMPT from:
1. `hard_floor_applies()` — the hard floor governs autonomous triage, not human escalation
2. `autonomy_enabled` kill switch — the kill switch disables autonomous decisions, not
   human-escalation artifacts

**Updated `ticket_action_type` semantics:**

| Value | Set by monitoring-loop when... | disposition-guard behavior |
|-------|-------------------------------|---------------------------|
| `"comment"` | FP/BTP dedup — append to existing alert ticket | Regular comment marker (blocked by hard floor) |
| `"create"` | TP/FP/BTP — new ticket needed | Regular create marker (blocked by hard floor) |
| `"assign"` | TP escalation routing | Regular assign marker (blocked by hard floor) |
| `"create-review"` | Hard-floor verdict AND no existing open review ticket | RESTRICTED review-create marker — **exempt from hard floor + kill switch** |
| `"comment-review"` | Hard-floor verdict AND existing open review ticket (dedup append) | RESTRICTED review-comment marker — **exempt from hard floor + kill switch** |
| `"none"` | `autonomy_enabled=false` AND non-hard-floor verdict; OR hard-floor AND all review surfacing already complete | No marker |

**`ticket_action_type = "none"` MUST NOT be used when a hard-floor verdict needs surfacing.**
BC-10.01.001 Inv#10 must be narrowed: the current "hard floor → ticket_action_type='none'"
rule must be replaced with "hard floor → set ticket_action_type to create-review or comment-review
(as appropriate); 'none' is only for autonomy_enabled=false + non-hard-floor, or when surfacing
is already complete" (PO obligation — see §8.10 item 3).

**Restricted marker schema for `create-review` (updated ADV-F2-P6-001):**
```json
{
  "authorized_operations": ["create-review"],
  "command_pattern": "^jr (--output json )?issue create --project <jira_project_key> --label (REVIEW-REQUIRED|BLIND-SPOT)( |$)"
}
```

**Restricted marker schema for `comment-review`:**
```json
{
  "authorized_operations": ["comment-review"],
  "command_pattern": "^jr (--output json )?issue comment <ticket_id> "
}
```

**require-review consumer algorithm update (PO obligation — BC-3.01.001, updated ADV-F2-P6-001):**
The consumer algorithm step (6) "authorized_operations scope check" must implement EXACT-TYPE
matching (not OR-accept) with the STEP 6a anti-fungibility cross-check:
- `jr issue create ... --label REVIEW-REQUIRED ...` or `... --label BLIND-SPOT ...` command →
  accepts ONLY `authorized_operations: ["create-review"]`; skips `["create"]` markers
- `jr issue create ...` command WITHOUT review label → accepts ONLY `authorized_operations: ["create"]`;
  skips `["create-review"]` markers (EC-023: prevents review marker theft for regular creates)
- `jr issue comment ...` command → cross-check pending ASM-014; current guard: ticket_id binding
BC-3.01.001 must be updated to implement exact-type matching and STEP 6a (see §8.14 item 1).

**autonomy_enabled=false and review surfacing (updated ADV-F2-P6-002 — STEP renumbering):**
When `autonomy_enabled=false`:
- Regular markers (comment/create/assign): suppressed (kill switch fires at emitter STEP 5 — post ADV-F2-P6-002 reorder)
- Review markers (create-review/comment-review): still issued (STEP 3 and STEP 4 both run before STEP 5 kill switch)
Rationale: the kill switch halts "automation producing unexpected output" (brief §3.9). A
`[REVIEW-REQUIRED]` ticket is expected output — it surfaces the finding for human attention.
Suppressing review tickets when the kill switch is ON would silently drop hard-floor findings,
which is exactly the failure mode the kill switch is designed to prevent at the human level.

**Inv#11 / VP-SKILL-065 carve-out language (ADV-F2-P6-003 MAJOR — normative):**
Under `autonomy_enabled=false`: ZERO REGULAR (comment/create/assign) markers are consumed and
ZERO regular `jr issue comment/create/assign` write operations for non-review tickets are
executed. EXCEPTION: `create-review` and `comment-review` escalation writes for GENUINE
hard-floor verdicts (`hard_floor_applies(verdict)=TRUE`, verified by disposition-guard STEP 3
and STEP 4 gates) STILL execute per D-DEC-012 Option A. The kill switch suppresses ONLY
autonomous triage; it does NOT suppress human-escalation ticket creation or updates.

BC-10.01.001 Invariant #11 MUST carry this carve-out: replace "all autonomous Jira actions
halted" with "all REGULAR (non-review) autonomous Jira actions halted; create-review and
comment-review escalation writes for genuine hard-floor verdicts (hard_floor_applies()=TRUE)
are EXEMPT per D-DEC-012 Option A." VP-SKILL-065 MUST be re-scoped: the prior assertion
"zero jr create/comment/assign calls under autonomy_enabled=false" is overly broad; the correct
assertion is "zero REGULAR (non-review) jr create/comment/assign calls under autonomy_enabled=false."
See §8.15 FV propagation list for the re-scoping obligation and required test vectors.

**Fail-loud invariant (deterministically enforced at hook layer — ADV-F2-P5-001):**
Hard-floor or Indeterminate verdicts MUST result in exactly one of:
1. A `create-review` or `comment-review` marker being issued and consumed (ticket created/updated), OR
2. An explicit error artifact written to audit.log AND a deny emitted (if no project_key is
   available to bind the review marker)

NEVER: silent discard.

Prior text read "A hard-floor verdict that produces no ticket and no error artifact is a bug in
the monitoring-loop SKILL.md." This was incorrect — it delegated enforcement to the trusted-LLM
layer, the exact surface P5-001 exploited. The marker-upgrade approach (P5-001/P6-002) addressed
the emitter side but was proved structurally unsound by P7-001: the hook could upgrade the marker
but could not rewrite the loop's future Bash command, leaving 3 of 4 under-label action types
with unconsumable markers and silently dropped findings.

The disposition-guard hook (deterministic) now enforces this invariant via the STEP 4
deny-the-Write logic (ADV-F2-P7-001 redesign):
- If a hard-floor verdict arrives with a non-review ticket_action_type, STEP 4 DENIES the
  verdict Write itself with a structured machine-readable corrective reason. No marker is
  issued; no Jira write is possible. The audit entry UNDER-LABEL-DENIED is written.
- The loop MUST re-issue the verdict Write with the correct review token (per the deny reason).
  On the corrected Write, STEP 3 issues the review marker normally.
- If the loop never re-documents: the deny + audit entry are the auditable fail-closed outcome.
  This is the loud failure (not silent). No marker sits unconsumable in the store.
UNDER-LABEL-CORRECTED audit code is RETIRED; UNDER-LABEL-DENIED is the operative audit event.
The monitoring-loop SKILL.md Iron Law remains in force as defense-in-depth.

#### O3 Standing Rule — LLM-Supplied Routing Fields Must Be Cross-Validated (ADV-F2-P5-002/obs)

Every LLM-supplied routing field that grants or bypasses a security control MUST be
cross-validated against a hook-computed invariant before the grant or bypass takes effect.

| LLM-supplied field | Security control bypassed | Hook-computed cross-check |
|--------------------|--------------------------|--------------------------|
| `ticket_action_type ∈ {create-review, comment-review}` | hard_floor_applies() check + autonomy_enabled kill switch | `hard_floor_applies(verdict)` must return TRUE before the exemption fires (STEP 3) |
| `ticket_action_type` (any value) | marker issuance path selection | enum-membership validation (STEP 1) before any routing |
| `autonomy_enabled` | kill switch | read from verdict JSON by hook directly; not delegated to monitoring-loop LLM; default-false conservative (STEP 5 — post ADV-F2-P6-002 reorder) |
| **[P6-001 — consumer]** create-review marker consumed for non-review-labeled command | kill switch + hard-floor bypass (marker theft: review token authorizes regular create) | consumer STEP 6a: `["create-review"]` marker REQUIRES `--label REVIEW-REQUIRED\|BLIND-SPOT` in command; `["create"]` marker REQUIRES absence of review label; both directions enforced (EC-023) |
| **[P6-002 — ordering]** kill switch precedes under-label hard-floor deny | fail-loud safety for under-labeled hard-floor verdicts (silent discard of finding) | hard_floor_applies() DENY-THE-WRITE (STEP 4) executed BEFORE autonomy_enabled kill switch (STEP 5); ordering invariant: hard-floor evaluation has higher priority than kill switch; P7-001 upgraded action from "upgrade marker" to "deny Write" but STEP ordering is preserved |
| **[P6-009 — trust boundary]** any marker consumption point; control-flow ordering involving security gates | unauthorized Jira writes; silent discard of security findings | O3 audit checklist MUST cover: (a) every marker CONSUMPTION point, (b) every control-flow ORDERING between kill switch and fail-loud paths, (c) every trust-boundary crossing — scope is NOT emitter-only; consumer rows (P6-001) and ordering row (P6-002) are now represented in this table |
| **[P7-009 — O4 standing rule]** any "never silently discarded" claim verified only at the emitter (marker present in store) | hard-floor finding silently dropped when emitter artifact is unconsumable (wrong command pattern, loop ignores deny reason, Write↔Bash seam gap) | **O4 standing rule:** every "never silently discarded" claim MUST have a VP whose assertion is the downstream authorization/execution outcome at the consumer/Bash boundary — a jr write is authorized AND consumable — not an emitter-local artifact (marker file presence). An emitter-only VP CANNOT detect the Write→Bash seam gap. VP-HOOK-029 re-scope per §8.17 item 1 operationalizes this rule for the hard-floor fail-loud invariant. |
| **[P9-009 — O5 standing rule]** hook re-implements shell tokenization without a differential-vs-bash test partition | tokenizer diverges from bash for a specific quoting class (e.g., backslash-escaped quotes) → false-allow or false-deny for commands that bash parses differently; security bypass or false-positive gate possible | **O5 standing rule:** any hook that re-implements shell tokenization to make a security decision MUST carry a differential-vs-bash vector partition covering all shell-quoting classes the downstream CLI honors. The partition MUST include: (a) vectors for each quoting class the CLI command surface uses (single-quoted, double-quoted, backslash-escaped, unquoted), (b) paired mutants demonstrating that divergence from bash tokenization is detectable and killable by the VP. The structural_label_check (P9-001 backslash-escape extension) operationalizes this rule for the escaped-quote class. Any future change to the tokenizer or to the set of CLI arguments the hook parses must extend the partition correspondingly. |

P5-001 and P5-002 are the under-label and over-label duals of the single root cause: the hook
trusted the LLM-supplied `ticket_action_type` token completely without verifying it against
`hard_floor_applies()`. STEP 3's gate (P5-002) and STEP 4's upgrade (P5-001, renumbered ADV-F2-P6-002) together close
both dual failure modes. Any future LLM-influenced routing field added to the emitter MUST
satisfy this cross-check requirement before the feature is considered architecturally complete.

#### Consequences

1. BC-10.01.001 Inv#10 must be narrowed — current "hard floor → none" conflicts with EC-006/EC-014 (PO)
2. BC-3.01.001 consumer algorithm step (6) must implement exact-type matching (NOT OR-accept) and step (6a) anti-fungibility cross-check — see §8.14 for PO propagation details (ADV-F2-P6-001)
3. VP-HOOK-026 must add test cases for create-review + comment-review paths (FV)
4. VP-HOOK-029 must be re-scoped to consumer-boundary assertion (FV) — see §8.17 item 1 (P7-004/P7-001 redesign)
5. New BATS tests required (see emitter pseudocode BATS stubs above)
6. SKILL.md Iron Law: review-tagged ticket content (REVIEW-REQUIRED/BLIND-SPOT label) is NOT
   enforced by require-review — it is an Iron Law on the monitoring-loop SKILL.md

#### Alternatives Rejected

**Use regular `"create"` markers for hard-floor review tickets:** Rejected. A regular `"create"`
marker on a hard-floor verdict would be indistinguishable (at the hook layer) from a marker for
a regular ticket creation. The audit trail loses the distinction between "autonomous triage ticket"
and "human-escalation ticket." `"create-review"` and `"comment-review"` make this distinction
explicit and auditable.

**Widen hard floor to allow regular creates for Indeterminate/silent verdicts:** Rejected. The
hard floor's purpose is to prevent autonomous triage decisions on uncertain/high-risk findings.
Widening the hard floor to allow regular creates would allow autonomous FP/TP/BTP tickets on
HIGH-severity alerts — a direct regression of D-DEC-008's security properties.

**Hook-side label enforcement via structurally distinct command_patterns:** ~~Rejected (prior v1.8)~~
**ADOPTED (ADV-F2-P6-001, reversing prior rejection).** The prior rejection claimed that regex-based
label enforcement in require-review would be "brittle and complex." The P6-001 fix demonstrates
this is tractable: encoding `--label (REVIEW-REQUIRED|BLIND-SPOT)` in a FIXED position after
`--project <key>` in the create-review command_pattern makes the review/regular distinction
structurally self-evident, not brittle. O3 standing rule mandates this reversal: the review/regular
distinction is a security control — it cannot live only in SKILL.md (untrusted LLM layer). Consumer
STEP 6a provides defense-in-depth for both directions (create-review marker rejected without review
label; create marker rejected with review label). The SKILL.md Iron Law remains as an additional
layer. Comment-type structural check is analogous but pending ASM-014 validation.
**ASM-014 symmetry obligation (ADV-F2-P7-008):** When `jr issue comment --label` support is
validated by ASM-014, the comment-review command_pattern and consumer STEP 6a MUST add the
structural `--label` check symmetrically with the create-review path — same fixed-position
encoding (--label in fixed second position after the ticket_id), same anti-fungibility
cross-check directions, same Iron Law in BC-10.01.001 Stage-8. This is an architectural
obligation recorded here so it survives as a forward obligation into the ASM-014 resolution
burst. The ASM-014 resolution story acceptance criteria MUST reference this symmetry requirement.

---

### D-DEC-013 — Severity Normalization: Sensor-Native → {LOW, MEDIUM, HIGH, CRITICAL} (ADV-F2-P6-005)

#### Context

BC-3.03.001 Invariant #4 `validate_enums()` requires `verdict.severity ∈ {LOW, MEDIUM, HIGH, CRITICAL}`
(case-exact, fail-closed deny on non-member). Prism integrates four sensor families (CrowdStrike,
Armis, Claroty, Cyberint) and NVD enrichment via UDFs. Each sensor family uses a different native
severity representation: numeric 1-100 (CrowdStrike), risk bands (Armis, Claroty), CVSS floats
(NVD). No prior spec defined the normalization mapping. Without a named normalization step, raw
sensor severity values fail the enum gate, silently blocking the pipeline for that sensor family.

#### Decision

**Severity normalization is a NAMED Stage 1 pre-processing step** (and applies on the Stage 1
fast-path for known-FP alerts where Stage 5 SCORE is bypassed). The monitoring-loop MUST
normalize all sensor-native severity representations to {LOW, MEDIUM, HIGH, CRITICAL} BEFORE
writing the verdict.

**NORMALIZE_SEVERITY(native_severity, sensor_family) → {LOW, MEDIUM, HIGH, CRITICAL}:**

```
# Conservative fallback for ANY unrecognized value:
# → CRITICAL with uncertainty_explicit set (auditable; never a silent enum-deny)
# Rationale: "unrecognized severity" ≠ "low risk"; conservative is always correct here.
UNRECOGNIZED_DEFAULT = "CRITICAL"
```

**Per-sensor-family normalization table:**

| Sensor family | Native format | Normalization rule |
|---------------|--------------|-------------------|
| CrowdStrike | Numeric 1-100 | ≥76 → CRITICAL; ≥51 and <76 → HIGH; ≥26 and <51 → MEDIUM; <26 → LOW |
| Armis | Risk bands (Critical / High / Medium / Low / Informational) | 1:1 case-fold; Informational → LOW |
| Claroty | Risk bands (Critical / High / Medium / Low) | 1:1 case-fold |
| NVD/CVSS (via enrich_nvd()) | CVSS float 0.0-10.0 | ≥9.0 → CRITICAL; ≥7.0 → HIGH; ≥4.0 → MEDIUM; <4.0 → LOW |
| Cyberint | **Conservative default — pre-ASM-008 (ADV-F2-P7-006)** | Default CRITICAL + `uncertainty_explicit` naming the unvalidated mapping: "Cyberint severity mapping unvalidated per ASM-008; conservative CRITICAL applied until validated." Mirrors the unrecognized-family rule: a recognized-but-unvalidated family receives the same conservative treatment as an unrecognized family. Enum-valid and auditable from first Cyberint contact. Upon ASM-008 resolution, replace with the validated per-band mapping. |

**Rule for unrecognized severity (any sensor family):**

```
IF native_severity NOT IN known_values_for(sensor_family):
  verdict.severity = "CRITICAL"    # conservative hard floor
  append to verdict.uncertainty_explicit:
    "Unrecognized severity '" + native_severity + "' from sensor family '" + sensor_family +
    "' — normalized to CRITICAL (conservative); validate per D-DEC-013 (ASM-008 gate)"
  # This produces an AUDITABLE CRITICAL, not a silent enum-deny.
  # The disposition-guard enum check passes (CRITICAL is valid);
  # the uncertainty_explicit field documents the normalization gap for operator review.
```

**Integration with pipeline stages:**
- **Stage 1 INGEST:** extract raw severity from OCSF event; call `NORMALIZE_SEVERITY(raw, family)`;
  store as `verdict.severity`
- **Stage 5 SCORE:** if recalibration produces a non-enum value, re-apply `NORMALIZE_SEVERITY`
- **Stage 1 fast-path (known-FP):** `NORMALIZE_SEVERITY` is the ONLY severity transformation step;
  the normalized value must be in the verdict before Stage 3 CATEGORIZE for hard-floor technique evaluation

#### Consequences

- PO must add a Stage 1 normalization step to BC-10.01.001 Invariant #9 field 13 definition and Invariant #14 pipeline stage description (see §8.14 item 3)
- FV must add VP-SKILL-074 (severity normalization correctness — see §8.15 item 3)
- Cyberint normalization rows are COMPUTE-AT-VALIDATION per ASM-008 and must be finalized before the Wave 7 monitor-loop story closes

#### Alternatives Rejected

**Silent CRITICAL default (no audit):** Rejected. An unrecognized severity that silently becomes
CRITICAL will mass-escalate all events from a new sensor family to human review without operator
visibility. The auditable `uncertainty_explicit` annotation is essential for operational tuning.

**Hard deny on unrecognized severity:** Rejected. A fail-closed deny on unrecognized severity
makes the pipeline unreachable for any new sensor family until the mapping is explicitly added.
The conservative CRITICAL default with audit is strictly safer (pipeline continues; operators learn).

**P8-OBS-2 — Operator Expectation Note (Cyberint pre-ASM-008):**

The conservative CRITICAL default for Cyberint means: pre-ASM-008, **100% of Cyberint alerts
normalize to CRITICAL** → `hard_floor_applies()=TRUE` for every Cyberint alert → every Cyberint
verdict routes through create-review/comment-review → every Cyberint alert requires a human-review
ticket. This is **correct-by-conservatism** (unvalidated severity mapping SHOULD require human
review), but it will mass-escalate all Cyberint traffic to the review queue and flood it with
REVIEW-REQUIRED tickets for org-b (if Cyberint-connected) until ASM-008 resolves. This is
expected behavior, not a defect, and should be communicated to operators before the demo.

**PO PROPAGATION OBLIGATION:** Add this operator expectation note to BC-8.02.001 (sensor-metrics
skill) and BC-10.01.001 (monitoring-loop) — see §8.18.3 item 2 and §8.18.4 item 1.

---

## 2. Component-Map Delta

The existing C-1..C-24 map in `recovered-architecture.md` is NOT modified. This section
records the delta — new C-IDs and DAG edges added by v0.10.0. The shard sync step will
merge these into the authoritative component map.

### 2.1 New Component IDs

Continuing from C-24 (perplexity-mcp, the previous maximum).

```yaml
# Delta components — append to recovered-architecture.md YAML block at F2 sync

  - id: C-25
    name: "prism-mcp"
    path: "external (prism binary, GitHub Releases, stdio MCP server)"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: []
    interfaces_provided:
      - "mcp__prism__query — PrismQL SELECT execution (prism_describe, prism_sensor_health, sensor tables)"
      - "mcp__prism__prism_describe — table enumeration"
      - "Enrichment UDFs: enrich_threatintel(sha256), enrich_nvd(cve_id)"
      - "Error codes: E-SPEC-024 (boot abort), E-CRED-008 (keyring miss)"
    interfaces_consumed: ["CrowdStrike API", "Armis API", "Claroty API", "Cyberint API", "NVD (via UDF)", "ThreatIntel feed (via UDF)"]
    confidence: "medium (ASM-008 — exact tool names unvalidated; prism binary not yet available)"
    notes: "RUST_LOG=off MUST be injected into env block by activate-mcp-config shell helper (ASM-002). Registered in ~/.claude/settings.json under mcpServers.prism key (R-008 merge-not-overwrite). Not yet available for empirical validation (ASM-001, ASM-004)."

  - id: C-26
    name: "tavily-mcp"
    path: "external (@tavily/mcp-server or equivalent)"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "MEDIUM"
    dependencies: []
    interfaces_provided:
      - "mcp__tavily__tavily_search — web-grounded IOC/CVE/actor search"
      - "mcp__tavily__tavily_extract — content extraction from URLs"
    interfaces_consumed: ["Tavily AI API (authenticated)"]
    confidence: "medium (present in CI security.yml matchers; not in secops-protocol.md as of v0.9.0)"
    notes: "Recommended tier (D-DEC-009). Appears in CI security.yml but not yet in secops-protocol.md — must be added. Fallback: Perplexity-only enrichment (D-DEC-009). Key rotates independently of prism credentials."

  - id: C-27
    name: "activate-shell-helpers"
    path: "plugins/secops-factory/skills/activate/activate-mcp-config.{sh,ps1}, prism-version-check.{sh,ps1}"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: []
    interfaces_provided:
      - "activate-mcp-config: merges prism MCP server block into ~/.claude/settings.json; hardcodes RUST_LOG=off; uses jq merge not overwrite"
      - "prism-version-check: runs prism --version, asserts >= 1.0.0-rc.1; returns download link on mismatch"
    interfaces_consumed: ["jq", "~/.claude/settings.json (user-scoped write surface)", "prism binary"]
    confidence: "high (design specified; implementation pending F4)"
    notes: "First shell helpers co-located under skills/<name>/ (D-DEC-007). Each .sh has a .ps1 sibling (CONV-004 extended to skill subdirs). BATS coverage required per brief §6."

  - id: C-28
    name: "onboard-sensor-helpers"
    path: "plugins/secops-factory/skills/onboard-sensor/credential-set.{sh,ps1}"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: ["C-25"]
    interfaces_provided:
      - "credential-set: wraps AD-017 piped-stdin pattern; echo <value> | prism credential set; never re-reads credential; verifies via prism_describe"
    interfaces_consumed: ["prism binary (subprocess, not MCP)", "OS keyring (via prism credential set)"]
    confidence: "high (design specified; implementation pending F4)"
    notes: "AD-017 credential walkthrough — Claude never sees credential value. Verification via prism_describe (confirms sensor registered, not credential value). The credential keyring write is the fourth external write surface (R-002 threat model)."

  - id: C-29
    name: "marker-store"
    path: "${CLAUDE_PLUGIN_DATA}/markers/"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "CRITICAL"
    dependencies: []
    interfaces_provided:
      - "Review-approval marker files (<uuid>.marker.json): issued by disposition-guard, read+invalidated by require-review"
      - "Audit log (audit.log): append-only record of every marker use"
      - "Single-use atomic invalidation via POSIX rename(2)"
    interfaces_consumed: ["${CLAUDE_PLUGIN_DATA} filesystem (writable, persistent)"]
    confidence: "high (design specified; ASM-009 — cross-hook filesystem access is new requirement)"
    notes: "CRITICAL tier: load-bearing authorization component. Shared interface between C-14 (disposition-guard, emitter) and C-12 (require-review, consumer). C-12 now has filesystem access for this surface only — Invariant #2 of BC-3.01.001 must be updated to reflect this. Outside the repository; not committed. Marker files accumulate; a periodic cleanup of .expired and .used files is advisable."

  - id: C-30
    name: "watermark-store"
    path: "${CLAUDE_PLUGIN_DATA}/watermarks/"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: []
    interfaces_provided:
      - "Per-org-per-sensor ISO 8601 timestamp files: read by monitoring-loop for incremental ingestion, written after successful run"
      - "Advisory lockfile (.monitoring-loop.lock): prevents concurrent loop invocations"
      - "Audit log (audit.log): append-only record of every watermark read/write"
    interfaces_consumed: ["${CLAUDE_PLUGIN_DATA} filesystem (writable, persistent, accessible from OS scheduler context)"]
    confidence: "medium (design specified; ASM-005 — scheduler filesystem access unvalidated)"
    notes: "HIGH tier: corruption causes silent duplicate event processing or missed alerts. Atomic write via temp+rename (D-DEC-002). Future-timestamp rejection guards against clock-skew attacks. First-run 24h lookback prevents full history replay."
```

**Summary of new C-IDs:**

| C-ID | Name | Layer | Criticality | Notes |
|------|------|-------|-------------|-------|
| C-25 | prism-mcp | infrastructure (external) | HIGH | PRIMARY new sensor data source |
| C-26 | tavily-mcp | infrastructure (external) | MEDIUM | Recommended; SEC-006 analog |
| C-27 | activate-shell-helpers | infrastructure | HIGH | New class: testable shell executables in skills/ |
| C-28 | onboard-sensor-helpers | infrastructure | HIGH | AD-017 credential provisioning |
| C-29 | marker-store | infrastructure | **CRITICAL** | Authorization load-bearing (D-DEC-001) |
| C-30 | watermark-store | infrastructure | HIGH | Incremental ingestion persistence (D-DEC-002) |

**Note on skill additions to C-1/C-2 aggregate:**

Four new skills (`onboard-customer`, `onboard-sensor`, `sensor-metrics`, `monitoring-loop`)
and four new commands fold into the existing C-2 (skill-procedures) and C-1 (command-dispatch)
aggregates. At per-artifact granularity, `monitoring-loop/SKILL.md` surfaces as CRITICAL
(same pattern as `update-jira` surfacing as CRITICAL within HIGH C-2). The `module-criticality.md`
update in F2 must record this.

### 2.2 New DAG Edges

Edges to ADD to the component map:

```
C-2 (skill-procedures) → C-25 (prism-mcp)       [skills: activate, investigate-event, assess-priority, scan-threats, sensor-metrics, onboard-sensor, monitoring-loop ALL consume prism MCP tools]
C-2 (skill-procedures) → C-26 (tavily-mcp)      [skills: investigate-event, monitoring-loop consume Tavily]
C-2 (skill-procedures) → C-27 (activate-shell-helpers)   [activate SKILL.md invokes activate-mcp-config.sh, prism-version-check.sh]
C-2 (skill-procedures) → C-28 (onboard-sensor-helpers)   [onboard-sensor SKILL.md invokes credential-set.sh]
C-2 (skill-procedures) → C-30 (watermark-store)          [monitoring-loop reads/writes watermarks]
C-12 (require-review-hook) → C-29 (marker-store)         [require-review reads + invalidates markers]
C-14 (disposition-guard-hook) → C-29 (marker-store)      [disposition-guard writes markers after ICD-203 validation]
C-22 (test-suite) → C-27 (activate-shell-helpers)        [new BATS suites for shell helpers]
C-22 (test-suite) → C-28 (onboard-sensor-helpers)        [new BATS suites for shell helpers]
```

### 2.3 DAG Acyclicity Verdict

**DAG remains acyclic. Manual edge-by-edge verification:**

New C-25 through C-30 are all sinks or near-sinks:
- C-25 (prism-mcp): no dependencies → no path back to any caller
- C-26 (tavily-mcp): no dependencies → no path back to any caller
- C-27 (activate-shell-helpers): no dependencies → no path back to any caller
- C-28 (onboard-sensor-helpers): depends on C-25 → C-25 has no dependencies → acyclic
- C-29 (marker-store): no dependencies; pointed to by C-12 and C-14. No path from C-29 back to C-12 or C-14 (C-29 is a filesystem store; it has no dependency edges outward)
- C-30 (watermark-store): no dependencies → no path back to any caller

New coupling C-12↔C-29↔C-14: Both C-12 and C-14 point TO C-29; neither C-12 nor C-14 points to the other; C-29 points to neither. This creates a coordination hub (not a cycle): C-14→C-29←C-12. Not a cycle.

C-28→C-25: C-28 depends on C-25 (prism binary subprocess). C-25 has no dependencies. Path C-28→C-25 is acyclic.

**Conclusion: DAG is acyclic (Y).**

---

## 3. External Write Surface Inventory

| Surface | Path | Write Agent | Failure Mode | Mitigation |
|---------|------|-------------|-------------|------------|
| User MCP config | `~/.claude/settings.json` | C-27 (activate-mcp-config helper) | Destructive overwrite removes all non-prism MCP servers system-wide; RUST_LOG omission corrupts all prism tool call responses | `jq` merge (`.mcpServers += {"prism": ...}`) never blind-overwrite; hardcode `RUST_LOG=off`; BATS test asserts: (a) pre-existing servers survive, (b) RUST_LOG present; read-back verification |
| Watermark store | `${CLAUDE_PLUGIN_DATA}/watermarks/<org>/<sensor>` | Monitoring-loop skill (C-30 writer) | Truncated write → garbage timestamp → either duplicate full-history reprocessing (24h fallback) or missed events (future timestamp skips forward) | Atomic write via temp+rename; ISO 8601 validation before write AND on read; future-timestamp rejection; lockfile prevents concurrent writes |
| Prism config dir | `<spec_dir>/customers/<org_slug>/` + `<sensor_id>.sensor.toml` | onboard-customer + onboard-sensor skills (within C-2) | Wrong `base_url` or missing sensor overlay causes all queries to return empty → monitoring-loop produces silence finding; wrong prism.toml entry corrupts multi-org routing | Post-write `prism_describe` verification (confirms sensor registered); `SELECT 1` connectivity probe; human reviews output before proceeding (AD-017 walkthrough is interactive) |
| Prism credential keyring | OS keyring via `prism credential set` subprocess (C-28) | onboard-sensor-helpers (AD-017 pattern) | Credential not stored → sensor queries return E-CRED-008 → all sensor queries fail → silence finding for all sensors on that org | AD-017 piped-stdin (echo \| prism) — credential never in chat/logs; post-write verification via `prism_describe` (not credential re-read); `SELECT 1` connectivity confirms end-to-end; failure emits explicit error, not silent null result |
| Dedicated cron MCP config | `~/.claude/prism.mcp.json` | C-27 (activate-mcp-config helper) | Missing file causes cron wrapper to exit before invoking claude (Stage 0 guard in wrapper script); stale file causes monitoring-loop to attempt prism connection with wrong binary path | Written by activate alongside `settings.json` write (D-DEC-003); deactivate must clean both; BATS test asserts file is present and valid JSON after activate, absent after deactivate; jq-validate before use in wrapper |

### Testing Architecture Constraints (from DTU Assessment)

Two constraints from `.factory/phase-f2-spec-evolution/dtu-assessment.md` touch the
CI/test architecture:

**1. prism-dtu-demo-server CI download path:**

The `prism-dtu-demo-server` binary ships in the `prism-demo-bundle-${TAG}-${target}`
release asset — NOT in the main prism binary download. secops-factory CI integration
test setup job must download and cache this bundle separately from the main prism binary.

```yaml
# .github/workflows/ci.yml — integration test setup (addition)
- name: Download prism demo bundle
  env:
    PRISM_VERSION: ${{ env.PRISM_MIN_VERSION }}  # 1.0.0-rc.1
  run: |
    bundle_url="https://github.com/drbothen/prism/releases/download/v${PRISM_VERSION}/prism-demo-bundle-v${PRISM_VERSION}-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz"
    curl -fsSL "${bundle_url}" | tar -xz -C "${RUNNER_TEMP}/prism-demo-bundle/"
    echo "PRISM_DTU_DEMO_SERVER=${RUNNER_TEMP}/prism-demo-bundle/prism-dtu-demo-server" >> "${GITHUB_ENV}"
    echo "PRISM_DEMO_CONFIG=${RUNNER_TEMP}/prism-demo-bundle/configs/prism-demo.toml" >> "${GITHUB_ENV}"
```

**This is test-infra only — it does NOT violate D-006 (secops-factory is DEMO-UNAWARE).**
D-006 scopes the demo bundle as out-of-scope for secops-factory plugin features.
The DTU demo server is a testing double, not a plugin feature. Test infrastructure
consuming a test double is categorically different from shipping demo assets in the plugin.
This note must appear in the ci.yml PR description for the Wave 7 story to preempt
any D-006 confusion during review.

**2. `--config-dir <tmpdir>` isolation constraint:**

Every test invocation of the prism binary — in BATS integration tests, holdout evaluation,
and the activate/onboard BATS unit tests — MUST pass `--config-dir` pointing to a
test-specific temp directory:

```bash
# BATS setup pattern (mandatory for all prism invocations in tests)
setup() {
  TEST_PRISM_CONFIG_DIR="$(mktemp -d)"
  export PRISM_CONFIG_DIR="${TEST_PRISM_CONFIG_DIR}"
  # All prism calls use: prism --config-dir "${TEST_PRISM_CONFIG_DIR}" ...
}

teardown() {
  rm -rf "${TEST_PRISM_CONFIG_DIR}"
}
```

This prevents test runs from reading or corrupting the developer's real
`~/.config/prism/prism.toml` or equivalent. Failure to apply this constraint risks
cross-contaminating production org configs during development. This must be a
BATS helper function (`assert_prism_config_dir_set`) that all prism-calling tests invoke.

**3. D-DEC-009 / DTU assessment alignment:**

The DTU assessor assumed Tavily tier = `recommended` with graceful degradation fallback.
D-DEC-009 resolves to exactly this. **No conflict.** The DTU assessment's Tavily
candidacy verdict (NO DTU required for core tests, graceful-degradation path is the
primary test surface) is consistent with D-DEC-009's `recommended` classification.

---

## 4. ASM Register Update

### 4.1 Existing ASMs — Status Changes

| ID | Previous Status | New Status | Change |
|----|----------------|------------|--------|
| ASM-001 | UNVALIDATED | UNVALIDATED | Unchanged; Stage 0 prism connectivity probe is the validation mechanism (D-DEC-001 does not affect this) |
| ASM-002 | UNVALIDATED | PARTIALLY MITIGATED | C-27 activate-mcp-config helper hardcodes `RUST_LOG=off`; BATS test asserts presence; runtime validation still needed |
| ASM-003 | UNVALIDATED | DESIGN-ADDRESSED | jq merge pattern + single-activate constraint documented; `flock` consideration noted; not empirically tested |
| ASM-004 | UNVALIDATED | **RESOLVED-BY-DESIGN** | ASM-004 validation report received (2026-07-20): PARTIAL — cwd `.mcp.json` and `--strict-mcp-config --mcp-config` confirmed reliable; `settings.json` mcpServers route unconfirmed in cron; D-DEC-003 resolved to `--strict-mcp-config --mcp-config ~/.claude/prism.mcp.json`; packaging no longer depends on the unconfirmed settings.json route; Wave 7 unblocked |
| ASM-005 | UNVALIDATED | PARTIALLY ADDRESSED | OS-specific ${CLAUDE_PLUGIN_DATA} paths documented (D-DEC-002); write access from scheduler context not yet tested |
| ASM-006 | UNVALIDATED | UNVALIDATED | Stage 0 `jr auth status` gate is the validation mechanism; not implemented yet |
| ASM-007 | UNVALIDATED | LOW-RISK (design) | Rate estimate 800 req/hour vs Jira Cloud 300 req/min; well within limits; no action needed until higher volumes observed |
| ASM-008 | UNVALIDATED | UNVALIDATED | Prism binary not yet available; hooks.json matcher update in Wave 8 is gated on this |

### 4.2 New ASMs Introduced by This Design

| ID | Assumption | Status | Validation Method | Impact if Wrong |
|----|-----------|--------|------------------|----------------|
| ASM-009 | Both disposition-guard and require-review hooks run in a process context with read-write access to `${CLAUDE_PLUGIN_DATA}/markers/` — the same filesystem path is accessible from both hook invocations within a Claude session | **UNVALIDATED — BLOCKING pre-Wave-3 (ADV-F2-P6-008)** | **Go/no-go criterion:** A BATS integration test MUST demonstrate that a file written to `${CLAUDE_PLUGIN_DATA}/markers/` by a simulated disposition-guard subprocess is readable and atomically renameable by a simulated require-review subprocess within the same test session (same OS user, separate subprocess invocations). This test MUST pass before any Wave-3 story that depends on the marker mechanism can be merged. The marker DESIGN is CONDITIONAL on this assumption — it is not RESOLVED. If the test fails, escalate to human: in-process fallback is architecturally impossible under the hook design. | HIGH — if hooks cannot share the marker store, the marker mechanism fails entirely; fallback would be an in-process marker (not possible given hook architecture) |
| ASM-010 | `mv` within `${CLAUDE_PLUGIN_DATA}/markers/` is atomic (POSIX rename(2) semantics) on all supported OS/filesystem combinations (macOS HFS+/APFS, Linux ext4/btrfs, Windows NTFS via PowerShell Move-Item) | VALIDATED by standard | macOS/Linux: POSIX rename(2) within same filesystem is atomic (kernel-guaranteed); Windows: MoveFileEx with MOVEFILE_REPLACE_EXISTING on NTFS is atomic; validated by OS specification | CRITICAL — non-atomic rename would enable race condition where two concurrent hook invocations both read the same marker and both emit allow; mitigation: Windows PowerShell Move-Item uses MOVEFILE_REPLACE_EXISTING by default |
| ASM-011 | No existing `skills/sensor-metrics/` directory or `commands/sensor-metrics.md` file exists at HEAD (d181ca2) | VALIDATED | Filesystem inspection (2026-07-20): `ls plugins/secops-factory/skills/` shows no `sensor-metrics`; `ls plugins/secops-factory/commands/` shows no `sensor-metrics.md` | None — naming decision confirmed free |
| ASM-012 | UUID v4 generation is available without external tooling from within disposition-guard shell scripts: via `/proc/sys/kernel/random/uuid` (Linux), `openssl rand -hex 16` (macOS/Linux fallback), or PowerShell `[System.Guid]::NewGuid()` | PARTIALLY VALIDATED | Linux `/proc` path available on kernel >= 2.6.26; macOS has OpenSSL in stdlib; PowerShell .NET Guid is always available; chained fallback provides coverage across all supported platforms | LOW — fallback chain covers all platforms; worst case: use sha256sum of entropy inputs |
| ASM-013 | The monitoring-loop skill's hard floor unconditional branches (§3.9) remain code branches (not config-evaluated) even after LLM-driven skill evolution — structural verification requires a BATS test that asserts the hard floor logic cannot be bypassed by `autonomy_enabled=true` | UNVALIDATED | BATS tests (VP-HOOK-026 target): inject Indeterminate verdict + autonomy_enabled=true and assert no marker file created in marker-store; same for HIGH/CRIT severity | CRITICAL — if hard floors migrate to config-evaluated conditions, R-001 materializes |

---

## 5. Security Architecture — Phase 0 Posture Preservation

### 5.1 Invariant Transition

The Phase 0 security invariant for `require-review` was:

> **Unconditional deny:** `∀ cmd ∈ {comment, edit, move, assign, create} → deny(cmd)`

This invariant is being **narrowly relaxed** to support the monitoring-loop autonomous
write path. The new invariant is:

> **Deny unless valid unexpired scoped marker (canonical v2.0 schema — ADV-F2-P2-004 fix):**
> `∀ cmd ∈ write_ops → deny(cmd)` **UNLESS**
> `∃ marker M ∈ ${CLAUDE_PLUGIN_DATA}/markers/ s.t.`
> - `¬(now() > M.expires_at_utc)` — not expired (absolute expiry; no ttl_seconds arithmetic)
> - `M.issued_at_utc ≤ now()` — issued in the past, not future-dated
> - `anchored_match(M.command_pattern, cmd)` — anchored regex, not substring
> - `M is atomically invalidated via POSIX rename before allow is emitted` — single-use
>   (`.marker.json.used` files excluded from future `*.marker.json` glob scans; dead-code
>   `M.used = false` check removed at schema v2.0 — see ADV-F2-018, BC-3.01.001 v1.15)

The gate is still a deterministic hook (C-12 + C-29). The LLM cannot forge a marker. The
LLM-executed monitoring-loop skill proposes dispositions; the deterministic disposition-guard
hook (C-14) validates ICD-203 fields and hard floors; only then does it write a marker to C-29.

### 5.2 Security Properties Preserved

| Phase 0 Property | Status | Notes |
|-----------------|--------|-------|
| require-review is the sole hard gate on Jira writes | PRESERVED | The marker mechanism is implemented INSIDE require-review (C-12 consumes C-29), not as a bypass around it |
| Write-block evaluated BEFORE allowlist (Invariant #5, SEC-009 fix) | PRESERVED | The write-block check in require-review.sh still fires first. Marker validation is a branch inside the write-block path, not a replacement of it |
| Fail-closed for unrecognized jr subcommands (SEC-002) | PRESERVED | Marker validation only fires for write-block-matched commands. A novel write command unknown to the write-block list still hits the fail-closed catch-all |
| No unanchored substring matching (SEC-009 lesson) | PRESERVED + EXTENDED | command_pattern field uses anchored regex; `^jr ` prefix required; trailing-space guard for `comment ` (exact BC-3.01.001 Invariant #4 pattern) |
| SEC-001 injection surface: read-ticket does not influence authorization | PRESERVED | Markers are issued by disposition-guard (fires on Write events for verdict files), not by any read event. Jira ticket content cannot trigger marker issuance |
| Indeterminate verdicts always surface to human | PRESERVED | Hard floor: disposition-guard never issues a marker for Indeterminate verdicts (D-DEC-008). Unconditional code branch, not config |
| HIGH/CRIT alerts require human review | PRESERVED | Hard floor: marker issuance blocked for HIGH/CRIT severity (D-DEC-008). Unconditional code branch |

### 5.3 New Security Properties Introduced

> **VP anchor clarification (ADV-F2-009 fix):**
> - **VP-HOOK-025** = ICD-203 field completeness enforcement (disposition-guard validates all
>   **15 mandatory fields** including severity + asset_type + ticket_action_type; dual-path
>   heading-anchored markdown / jq key-presence JSON)
> - **VP-HOOK-024** = marker soundness (require-review consumer: valid marker → allow + consume;
>   invalid/expired/wrong-scope/replayed marker → deny; rename-fail → deny; audit log)

| Property | Mechanism | VP subject |
|----------|-----------|-----------|
| Marker cannot be issued without all 15 mandatory verdict fields | disposition-guard validates all 15 fields (12 ICD-203 + severity + asset_type + ticket_action_type) BEFORE writing marker; validation failure → no marker written | **VP-HOOK-025** (field completeness) |
| Marker is single-use (replay impossible) | Atomic `mv` rename before `emit_allow`; rename failure → explicit `emit_deny` (ADV-F2-014) | **VP-HOOK-024** (marker soundness) |
| Marker TTL of 120s via absolute `expires_at_utc` prevents stale-marker attacks | `now() > expires_at_utc` check on every evaluation (absolute; no clock-skew arithmetic) | VP-HOOK-024 |
| Hard floor categories cannot receive markers regardless of `autonomy_enabled` | Unconditional if-blocks keyed on `verdict.severity` + `verdict.asset_type` (NOT confidence) in monitoring-loop skill + disposition-guard emitter gate (ADV-F2-001 fix) | VP-HOOK-026 (hard floor enforcement) |
| Ticket-bound command_pattern for comment/assign prevents cross-ticket marker reuse | `command_pattern` interpolates literal ticket_id; EC-022: wrong-ticket → deny; ADV-F2-002 fix | VP-HOOK-024 (EC-022 anchored match test) |
| Marker directory is outside git repository and SEC-001 read-ticket surface | Path `${CLAUDE_PLUGIN_DATA}/markers/` is never committed; read-ticket reads Jira ticket bodies, not filesystem paths | Architectural constraint; tested indirectly by bypass-class BATS |
| Enum-membership validation prevents field-mangling hard-floor bypass (ADV-F2-P4-006) | disposition-guard validates severity/asset_type/disposition/sensor_health_status/ticket_action_type/confidence against allowed-value sets (fail-closed deny) BEFORE hard-floor check; `severity:"High"` (wrong case) → deny, not allow-without-marker | **VP-HOOK-025** (field completeness — must add enum-membership BATS assertions) |
| create pattern `--project` fixed-position binding prevents injection bypass (ADV-F2-P4-002) | `--project` is the FIRST argument after `issue create`; trailing `( \|$)` prevents prefix-match; no `.*` before `--project`; monitoring-loop Iron Law enforces argument order | **VP-HOOK-024** (marker soundness — add BATS test for injection scenario) |
| Hard-floor verdicts never silently dropped — review surfacing path always available (D-DEC-012) | create-review/comment-review restricted markers exempt from hard_floor_applies() and autonomy_enabled kill switch; fail-loud invariant: no hard-floor verdict may be silently discarded | VP-HOOK-026 (hard floor enforcement — must add create-review/comment-review BATS test cases) |
| autonomy_enabled kill switch deterministically enforced at hook layer (ADV-F2-P4-005) | autonomy_enabled read directly from verdict JSON by disposition-guard (non-ICD-203 operational field); not delegated to monitoring-loop LLM; default-false conservative | VP-HOOK-026 (add kill-switch determinism test: verdict with autonomy_enabled=false + create action → no marker) |

### 5.4 BC-3.01.001 Invariant #2 Update Required

> **ADV-F2-015 fix:** Updated all BC version references to live versions (v1.11→**v1.12**,
> v1.6→**v1.7**). Prior references in this section were stale.

BC-3.01.001 Invariant #2 states (as of **v1.15** live): "The hook never makes network calls and
never spawns subprocesses beyond `jq`. For non-write-block commands, no filesystem access
occurs — all decisions are made from the single stdin JSON envelope. For write-block-matched
commands ONLY, the hook additionally reads `${CLAUDE_PLUGIN_DATA}/markers/*.marker.json`
(glob scan via shell expansion), performs one atomic POSIX `mv` rename to consume the matched
marker (if valid), and appends one line to `${CLAUDE_PLUGIN_DATA}/audit.log`."

> **ADV-F2-P2-007 note (v1.3) — RESOLVED (ADV-F2-P4-009 v1.6):** This note originally stated
> that BC-3.01.001 Invariant #2 referenced the wrong audit log path (`${CLAUDE_PLUGIN_DATA}/audit.log`
> vs canonical `${CLAUDE_PLUGIN_DATA}/markers/audit.log`). The fix was applied at BC-3.01.001
> **v1.14** (revision history: "ADV-F2-P2-003/P2-007/P2-012: audit log path alignment"). The BC
> is now at v1.15 with the correct path live. §8.6 item 6 was satisfied at v1.14. No further
> action required — this note is retained as an audit trail record only.

This is the v1.13 live text. The v1.11 Invariant #2 draft text cited below was the
intermediate version prior to the FV-PROPOSED-DROP bump:

> **Updated Invariant #2 (v1.11 → superseded by v1.12 live text above):** The hook never
> makes network calls and never spawns subprocesses beyond `jq`. For write operations, it
> reads and atomically invalidates a marker file from `${CLAUDE_PLUGIN_DATA}/markers/` (the
> review-approval marker store, C-29). All other decisions are made from the stdin JSON
> envelope only. Execution remains bounded at < 100ms.

This is a narrow, documented exception to the previous "no filesystem" property. The
exception is bounded (single directory, deterministic file operations, no network).

**v1.3 fix (ADV-F2-P2-004):** The audit log line uses base64-encoded `command_b64` field
(ADV-F2-013). This encoding was applied to BC-3.01.001 at **v1.13** (step (8) of the consumer
algorithm — now live). The "next version bump" language present in the v1.2 architecture-delta
was stale — the change has already been incorporated. No further action needed on command_b64.

### 5.5 Independent Adversarial Review Requirement

Per delta-analysis.md §3.1 R-002 (CRITICAL): the marker mechanism implementation must
receive an independent adversarial review in F5 (Scoped Adversarial Review), focused on:
- SEC-009-class bypass vectors against the command_pattern matching
- TOCTOU races in the marker invalidation path
- Marker store path injection attacks
- Hard floor bypass scenarios with edge-case disposition values
- Interaction between the .ps1 sibling and Windows NTFS atomicity guarantees

The F5 adversarial reviewer must receive the full **BC-3.01.001 v1.17** spec (ADV-F2-015),
the marker store design v2.0 (this document), and the Wave 3 implementation PR diff — NOT
the prior review context.

---

## 6. Research Grounding Note

The monitoring-loop design (brief §3, this document's D-DEC-004, D-DEC-008) is grounded
in `.factory/research/soc-analyst-workflow-2026.md` (81 sources, 2026-07-19). Key design
choices traceable to the research:

| Decision | Research basis |
|----------|---------------|
| Known-FP/dedup check BEFORE enrichment | [Q1 §"known-pattern lookup first" — Exaforce: 30-40% exit at this stage] |
| Never-auto-reopen-closed (§3.4 rule #4) | [Q3 citing [27] — ServiceNow Closed state cannot be reopened; policy applies across all ITSM platforms] |
| Indeterminate as hard floor (not soft preference) | [Q1 §"seven-stage model", Q6 §"auto-closing is the headline risk"] |
| sensor_health_status field in every verdict | [Q5 §"design implications" — absence of data ≠ no threat; must be qualified, not conflated with FP] |
| ICD-203 mandatory fields (hypotheses_considered, alternatives_rejected, uncertainty_explicit) | [Q7 citing [76][77] — ODNI ICD-203 analytic standards for auditable autonomous reasoning] |
| Per-action automation-boundary annotation (auto/propose-only/requires-human-approval) | [Q6 §"annotated as automated / requires-approval / manual"] |
| BLIND-SPOT dedup (D-DEC-004) | [Q3 §"append for correlated alerts" — Google's Find First Alert pattern] |

---

*F2 Architecture Delta complete. All ten D-DEC decisions resolved. Six new C-IDs established
(C-25..C-30). DAG acyclic. Adversarial pass 1 (ADV-F2-001..015) remediated in v1.2.*

---

## 8. PO PROPAGATION LIST (v1.3 — Adversarial Passes 1 and 2)

> **Owner:** Product-owner (PO). This section lists the exact BC edits required to align
> the behavioral contracts with the canonical design decisions in architecture-delta.md v1.3.
> The architect does NOT edit BCs. PO owns all BC files and must apply these changes.
> verification-delta.md and STATE.md are also NOT edited by the architect.
>
> **Live BC version map (as of 2026-07-20):**
> - BC-3.01.001: **v1.13** (live) — pass-1 changes incorporated
> - BC-3.03.001: **v1.7** (pass-1 target was v1.8 — status: check with PO)
> - BC-4.02.001: **v1.4** (pass-1 target was v1.5 — status: check with PO)
> - BC-10.01.001: **v1.3** (live) — pass-1 + independent FV bumps incorporated
>
> **§8.1–8.5** record pass-1 intent (some BCs already bumped past their pass-1 targets).
> **§8.6** is the pass-2 PO propagation list.
> **§8.7** is the pass-2 formal-verifier list.

---

### 8.1 BC-3.03.001 (disposition-guard) — Required Changes

**Current version: v1.7. Target: v1.8.**

1. **Emitter schema → canonical marker schema v2.0 (ADV-F2-003).**
   Invariant #4 EMITTER role marker schema must be updated to match D-DEC-001 schema v2.0:
   - Remove `"ttl_seconds": 30` field
   - Add `"expires_at_utc": "<issued_at_utc + 120 seconds>"` field
   - Change `"issued_at"` → `"issued_at_utc"` if any occurrence uses the short form
   - Change `"command_pattern": "^jr issue comment <ticket_id>"` → ticket-bound form with
     `(--output json )?` optional group (see D-DEC-008 generation table)
   - Add `"severity"` and `"asset_type"` to `disposition` sub-object in marker schema

2. **Invariant #4 hard-floor check — key on `verdict.severity` NOT `confidence` (ADV-F2-001).**
   The current hard-floor check in Invariant #4 includes:
   > "confidence maps to HIGH or CRIT severity threshold"
   This is wrong. Severity and confidence are orthogonal axes. Replace with:
   > "`verdict.severity` is `HIGH` or `CRITICAL`" (reading field 13 of the verdict JSON)
   Also add: "`verdict.asset_type` is in `CRITICAL_ASSET_TYPES`" (field 14).
   Remove: any wording that uses `confidence` as a proxy for severity.

3. **Create-scoped and assign-scoped emitter branches (ADV-F2-004).**
   Invariant #4 currently describes ONLY a comment-scoped marker issuance path. Add:
   - A `verdict.ticket_action_type == "create"` branch: `ticket_id = null`,
     `command_pattern = "^jr (--output json )?issue create "`, `authorized_operations: ["create"]`
   - A `verdict.ticket_action_type == "assign"` branch: `ticket_id` from verdict,
     `command_pattern = "^jr (--output json )?issue assign <ticket_id> "`,
     `authorized_operations: ["assign"]`
   - A `verdict.ticket_action_type == "none"` branch: allow the write, do NOT issue marker
   - Emitter scope selection: disposition-guard reads `verdict.ticket_action_type` (field 15)
     to determine which branch to take

4. **`cross-tenant scope indicators present in evidence_artifacts` — define schema (ADV-F2-016/obs).**
   The hard-floor condition "Cross-tenant scope indicators present in evidence_artifacts" is
   currently undefined. Add a note in Invariant #4: cross-tenant indicator = any element in
   `evidence_artifacts` where `source` matches the pattern `^mssp-global/` or
   `cross_tenant_flag: true` is present in the artifact object. If the schema is underspecified
   at time of PO edit, mark as `[PENDING-DEFINITION]` and add a BC Note.

5. **Verdict field count: 12 → 15 (ADV-F2-001/D).**
   All references to "12 ICD-203 fields" in this BC must be updated to "15 mandatory fields"
   (12 ICD-203 + severity + asset_type + ticket_action_type). Specifically: EC-010 description,
   the dual-path enforcement description in VP-HOOK-025, and any field-count references in
   postconditions #2/#3.

---

### 8.2 BC-3.01.001 (require-review) — Required Changes (pass 1)

**Pass-1 state:** Current version at time of pass 1 was v1.12. Pass-1 target was v1.13.
**Live version: v1.13** (pass-1 changes now incorporated). Pass-2 changes: see §8.6.

1. **Consumer algorithm step (3) — remove dead-code `used != false` check (ADV-F2-018/obs).**
   Step (3) in Postcondition #2 currently reads: "if used != false → skip (EC-019 replayed/consumed
   marker)". This check is dead code: the glob `*.marker.json` never matches `.marker.json.used`
   files (the rename changes the extension). The atomicity guarantee is provided entirely by the
   rename in step (8), not by checking `used`. Remove step (3) from the consumer algorithm.
   Note: EC-019 (replayed/consumed marker) remains valid as a threat — the MECHANISM is the rename,
   not the `used` field check. Update EC-019 Expected Behavior to reflect: "the .used-renamed file
   is excluded from *.marker.json glob; deny".

2. **Consumer algorithm — explicit rename-fail → deny (ADV-F2-014).**
   Step (8) in the algorithm (atomic mv-rename) must have an explicit "if rename fails → deny" branch:
   > "(8) atomic mv-rename: rename marker.json → marker.json.used
   >      **If rename fails for any reason → emit_deny("Marker invalidation failed — fail-closed"); exit 0**
   >     (POSIX single atomic rename; prevents replay — EC-019 prevention)"
   The current text says "result = mv(...)" but does not state the deny consequence if it fails.
   This matches the D-DEC-001 pseudocode now (v1.2 fix) and must be reflected in the BC.

3. **Consumer algorithm — base64 audit encoding for command field (ADV-F2-013).**
   Step (9) audit line format must change:
   - Old: `command='${command}'`
   - New: `command_b64=${command_b64}` where `command_b64 = base64(command)` (prevents newline injection)
   Update the audit step in Postcondition #2 step (9) to show the base64 form.

4. **EC-022 description — align to ticket-bound decision (ADV-F2-002).**
   EC-022 currently reads: "marker present but command_pattern anchored to different ticket-id".
   This is already the correct ticket-bound design. Confirm the EC text and the canonical test
   vector row for EC-022 use the ticket-bound format: `^jr (--output json )?issue comment SEC-123 `
   (with trailing space, literal ticket_id, optional `--output json` group).

5. **Canonical test vector — add create/assign marker allow paths.**
   Add rows for:
   - `jr issue create --project SEC --summary "..."` with a valid create-scoped marker → allow
   - `jr issue assign SEC-456 @responder` with a valid assign-scoped marker → allow
   These are needed for VP-HOOK-024 completeness (create/assign branches now exist).

---

### 8.3 BC-4.02.001 (update-jira) — Required Changes

**Current version: v1.4. Target: v1.5.**

1. **Precondition #1 — remove stale "conversation context or JIRA comments" wording (ADV-F2-007).**
   Current PC#1 text: "A review-approval marker must be present in conversation context or JIRA
   comments before any field-modifying operation..."
   This wording predates D-DEC-001 and contradicts the out-of-band filesystem design. Replace with:
   > "A review-approval marker must be present in `${CLAUDE_PLUGIN_DATA}/markers/` (the
   > out-of-band marker store, C-29) before any field-modifying operation. The marker is issued
   > by disposition-guard (BC-3.03.001) and consumed by require-review (BC-3.01.001). Markers
   > are NEVER embedded in conversation context or Jira comments — doing so would reintroduce
   > the SEC-001 injection surface."
   Also update EC-001 to remove any reference to "in conversation context or JIRA comments".

2. **PC#4 and EC-009 — align comment to marker v2.0 (ADV-F2-003).**
   Any references to `ttl_seconds: 30` must be changed to `expires_at_utc` (120s TTL, absolute).
   If PC#4 or EC-009 quote marker fields directly, update to schema v2.0.

---

### 8.4 BC-10.01.001 (monitoring-loop) — Required Changes (pass 1)

**Pass-1 state:** Current version at time of pass 1 was v1.1. Pass-1 target was v1.2.
**Live version: v1.3** (pass-1 changes + independent FV bumps through v1.3 incorporated).
Pass-2 changes: see §8.6.

1. **Verdict schema: 12 → 15 mandatory fields (ADV-F2-001 + D-DEC-008 D fix).**
   Invariant #9 ("All 12 ICD-203 mandatory fields") must be updated to 15 fields.
   Add three new mandatory fields to the numbered list:
   ```
   13. severity         (LOW|MEDIUM|HIGH|CRITICAL — matches alert.severity from sensor data)
   14. asset_type       (string — asset classification: domain_controller, privileged_account,
                         ot_safety_system, standard, unknown)
   15. ticket_action_type  (comment|create|assign|none — tells disposition-guard which
                            Jira action to authorize; "none" for hard-floor dispositions)
   ```
   Update the field count in: Invariant #9 heading, Postcondition #3, all inline references to
   "12 mandatory fields" or "12-field ICD-203 schema" throughout the BC.

2. **Invariant #10 hard-floor — key on `verdict.severity` not `alert.severity` (ADV-F2-001).**
   The current Invariant #10 uses: `alert.severity in {HIGH, CRITICAL}` and
   `alert.asset_type in CRITICAL_ASSET_TYPES`. The verdict must CARRY these values in fields 13/14
   (`verdict.severity`, `verdict.asset_type`) so disposition-guard can read them from the verdict
   JSON. Update invariant #10 to say:
   > "The verdict record's `severity` field (field 13) and `asset_type` field (field 14) are
   > populated from the ingested alert's classification at Stage 5 (SCORE). These fields are what
   > disposition-guard reads to enforce hard floors — they are NOT inferred at hook time."
   Confirm: when sensor data provides `severity=HIGH`, `verdict.severity` = `HIGH`. When sensor
   data does not provide severity, the monitoring-loop defaults to the most conservative tier.

3. **EC-009 (known-FP fast-exit) — add hard-floor evaluation before auto-close (ADV-F2-005).**
   Current EC-009: "Dispose immediately as FP; emit tuning signal; skip Stages 3–6."
   This bypasses the hard floors before auto-close. A known-FP match on a HIGH-severity
   critical-asset alert would auto-close, which is wrong.
   Update EC-009 Expected Behavior:
   > "Match known-FP pattern → EVALUATE HARD FLOORS FIRST (severity, asset_type, sensor health).
   > If any hard floor applies: route to human with [REVIEW-REQUIRED]; do NOT auto-close even if
   > known-FP match. If no hard floor: dispose as FP; emit tuning signal {rule_id, asset, reason};
   > set `ticket_action_type = 'comment'` (append FP close note to existing ticket);
   > skip Stages 3–6 enrichment/scoring. Invariant #7 (known-FP precedes enrichment) applies
   > ONLY to the enrichment spend, not to hard-floor evaluation."
   This fix closes the ADV-F2-005 silent bypass vector.

4. **Invariant #1 (org_slug scoping) — add VP cross-reference (ADV-F2-008).**
   Invariant #1 currently has no VP. Add a VP reference:
   > "Verification property: VP-SKILL-059 (scan-threats org_slug scoping — Iron Law content
   > assertion) provides partial coverage. A dedicated VP for the monitoring-loop's org_slug
   > constraint is needed (proposed: VP-SKILL-064 — monitoring-loop PrismQL never lacks
   > org_slug WHERE clause). Add to VP table and VP-INDEX.md as PROPOSED."
   This addresses ADV-F2-008 (sole cross-tenant isolation guarantee has no VP).

5. **Canonical marker schema references — update to v2.0 (ADV-F2-003).**
   Any references to `ttl_seconds: 30` in this BC must be replaced with `expires_at_utc`.
   Check: Description paragraph, any inline marker schema snippet, EC-014/015/016 references
   to marker issuance.

---

### 8.5 Verification-Delta — Note for Formal Verifier (NOT a BC change — info only)

> PO does not own verification-delta.md. This note is for the formal verifier's awareness.

The following verification properties need updating after PO applies the BC changes above:

1. **VP-HOOK-025 field list must grow to 15**: After BC changes (§8.1 item 5, §8.4 item 1),
   the BATS test count for VP-HOOK-025 in verification-delta §5 grows from "18 cases (12
   missing-field cases)" to ~21 cases (15 missing-field cases + tuning_signal semantics +
   dual-path routing). Formal verifier must update verification-delta §5 test-count row for
   BC-3.03.001 and the SM-17 mutant ("drop one field from the 15-field list").

2. **VP-HOOK-024 must add create/assign marker allow paths**: Two new canonical allow-path
   test vectors (create-scoped marker → allow; assign-scoped marker → allow) as noted in §8.2
   item 5. Formal verifier must add these to the VP-HOOK-024 test plan and verification-delta
   §2 table.

3. **VP-SKILL-064 (proposed — monitoring-loop org_slug) (ADV-F2-008)**: After PO adds this
   VP to BC-10.01.001, formal verifier must adjudicate and finalize in a verification-delta
   amendment, then add to VP-INDEX.md.

---

*Pass-1 PO PROPAGATION LIST (§8.1–8.5) complete for record. Pass-2 changes follow in §8.6–8.7.*

---

### 8.6 BC PROPAGATION LIST (pass 2 — architect does NOT edit these)

**Current live BC versions: BC-10.01.001 v1.9, BC-3.01.001 v1.17, BC-3.03.001 v1.13,
BC-4.02.001 v1.8, BC-4.05.001 v1.3, BC-5.01.001 v1.8, BC-6.01.001 v1.5.**

---

#### 8.6.1 BC-10.01.001 (monitoring-loop) — Pass-2 Required Changes

**Current version: v1.3. Target: v1.4.**

1. **Invariant #14 stage ordering — CRITICAL fix (ADV-F2-P2-001).** Swap Stage 7 and Stage 8:

   Current (defective):
   ```
   Stage 7: TICKET ACTION (append/link/propose-reopen/new per §3.4)
   Stage 8: DOCUMENT (write ICD-203 verdict record; disposition-guard validates)
   ```
   Corrected:
   ```
   Stage 7: DOCUMENT (write ICD-203 verdict record; disposition-guard validates all 15
            fields and emits scoped marker if ticket_action_type != "none" and no hard floor)
   Stage 8: TICKET ACTION (execute jr comment/create/assign using the marker emitted at Stage 7)
   ```
   Also update: PC#3 ("disposition-guard blocks any ticket action without 15 fields") to clarify
   disposition-guard fires on the Stage-7 verdict Write, not on the Bash jr event. The brief §3.2
   loop pseudocode (Stage 7/8 labels) must be reconciled in the same edit.

2. **EC-009 — Stage 3 still runs on known-FP fast-exit path (ADV-F2-P2-002).** Current EC-009
   says "skip Stages 3–6." This must be corrected to "skip Stages 4–5 (enrichment + scoring)."
   Stage 3 (CATEGORIZE — MITRE ATT&CK mapping) is NOT skipped. Add:
   > "Stage 3 executes on the known-FP fast-exit path to populate `verdict.attack_techniques`
   > before hard-floor evaluation. A known-FP match does not exempt an alert from the
   > ATT&CK technique hard floor (T1003/T1068/T1021/T1041 — Invariant #10)."
   Also add fast-path field 13/14 source:
   > "On the known-FP path (Stage 5 bypassed), `verdict.severity` (field 13) and
   > `verdict.asset_type` (field 14) are populated from the raw sensor event record at Stage 1
   > INGEST, not from Stage 5 recalibration. The SKILL.md must extract these from the sensor
   > event before Stage 3."

3. **EC-015 + EC-016 — re-key to verdict.* (ADV-F2-P2-006).** EC-015 currently keys on
   `alert.severity = HIGH or CRITICAL`. EC-016 keys on `alert.attack_technique = T1003`.
   These must be updated to `verdict.severity` and `verdict.attack_techniques` respectively,
   consistent with the Invariant #10 fix applied at v1.2:
   - EC-015: `verdict.severity in {HIGH, CRITICAL}` (field 13, set by Stage 5 or Stage 1 on fast-path)
   - EC-016: `T1003 in verdict.attack_techniques` (populated at Stage 3)

4. **asset_type=unknown conservative default (ADV-F2-P2-010).** Add a note to Invariant #10
   and to field 14 in Invariant #9:
   > "`unknown` asset_type is treated as a conservative non-critical-floor value unless
   > the site operator has configured it otherwise. However: severity=LOW + asset_type=unknown
   > + benign technique clears all hard floors → auto-action is possible. Consider adding
   > `unknown` to CRITICAL_ASSET_TYPES as a conservative default if the deployment policy
   > requires human review for unclassified assets. This is an operator-configurable choice;
   > the default is NOT to floor on unknown (to avoid blocking common unclassified endpoints)."
   Mark this as a [POLICY-DECISION-PENDING] note pending operator guidance.

---

#### 8.6.2 BC-3.01.001 (require-review) — Pass-2 Required Changes

**Current version: v1.13. Target: v1.14.**

1. **Audit log path alignment (ADV-F2-P2-007).** Step (8) of the consumer algorithm and
   Invariant #2 both reference `${CLAUDE_PLUGIN_DATA}/audit.log`. Canonical path per
   D-DEC-001 pseudocode and C-29 description is `${CLAUDE_PLUGIN_DATA}/markers/audit.log`.
   Update all occurrences:
   - Invariant #2: `${CLAUDE_PLUGIN_DATA}/audit.log` → `${CLAUDE_PLUGIN_DATA}/markers/audit.log`
   - Postcondition #2 step (8): same replacement
   - Any EC that references the audit log path

2. **Consumer algorithm multiplicity handling (ADV-F2-P2-003).** The BC must reflect the
   iterative-consume algorithm replacing the `>1 candidates → deny` rule. Update Postcondition #2
   to describe: "If multiple valid candidates exist, iterate in issued_at_utc ascending order;
   first successful atomic rename = allow. If all renames fail (concurrent consumers), deny."

---

#### 8.6.3 BC-3.03.001 (disposition-guard) — Pass-2 Required Changes

**Current version: v1.7 (est.). Target: v1.8 (combined pass-1 + pass-2 if not yet bumped).**

1. **Emitter pseudocode — stage ordering note.** Add a note to Invariant #4 emitter branch:
   "The disposition-guard Write hook fires when the monitoring-loop writes the ICD-203 verdict
   file (Stage 7 DOCUMENT). This PRECEDES the Stage 8 jr execution. The monitoring-loop must
   not call jr before writing the verdict document — the marker will not exist."

2. All pass-1 changes from §8.1 that remain pending must also be applied.

---

#### 8.6.4 BC-6.01.001 (activate) — Pass-2 Required Changes

**Current version: unknown. Target: next version bump.**

1. **Prism MCP server invocation — GROUND TRUTH correction (ADV-F2-P2-008).**
   - Download URL: `github.com/drbothen/prism` (NOT `github.com/prism-io/prism`)
   - MCP server subcommand: `start` (NOT `["mcp"]`): `prism --config-dir <dir> start`
   - Config: passed via `--config-dir` flag (NOT via PRISM_CONFIG_DIR env var for the start subcommand)
   - Update PC#8 (download URL), PC#9 (MCP server args block), and any CI snippet that
     references the old URL or the `["mcp"]` subcommand form.

2. **Sensor base-URL env vars reconciliation note (ADV-F2-P2-013/obs).** BC-6.01.001
   settings.json/prism.mcp.json env blocks carry only `RUST_LOG` + `PRISM_CONFIG_DIR`,
   omitting the brief §2.1 sensor base-URL env vars
   (`CROWDSTRIKE_BASE_URL`, `ARMIS_INSTANCE_URL`, etc.). Add a reconciliation note stating:
   "Per-sensor base URLs are configured in per-sensor toml overlays
   (`<spec_dir>/customers/<org_slug>/<sensor_id>.sensor.toml`) rather than in the MCP
   env block. The env block carries only process-level config (RUST_LOG, PRISM_CONFIG_DIR).
   This is intentional — sensor URLs are customer-specific and managed via onboard-sensor."

3. **Revision history ordering fix (ADV-F2-P2-012/obs).** Revision history must list v1.1
   before v1.2 (currently inverted).

---

### 8.7 FORMAL-VERIFIER LIST (pass 2)

> **Owner:** Formal verifier. These items require new or updated verification properties,
> mutants, and verification-delta amendments. The architect does NOT write VPs.

1. **VP for stage-order document-before-action property (ADV-F2-P2-014/obs + ADV-F2-P2-001).** 
   New integration VP needed: "a jr write call from the monitoring-loop is denied by
   require-review unless a verdict Write for the same loop run preceded it within the
   TTL window." Proof strategy: BATS integration test — simulate loop run with Stage 8
   jr BEFORE Stage 7 Write → assert deny; then correct order → assert allow. Tag as P1
   (cross-hook integration VP). Add to VP-INDEX.md and verification-coverage-matrix.md.

2. **VP for BC-4.02.001 Invariant #4 (never-auto-reopen Closed/Resolved) on update-jira path
   (ADV-F2-P2-009).** VP-SKILL-062 covers only the monitoring-loop path. Need a separate VP:
   "update-jira skill: jr reopen command is never autonomously issued for a Closed ticket."
   Paired mutant SM-N: inject a Closed ticket into update-jira context + assert no jr reopen.

3. **VP for BC-4.02.001 Invariant #5 (SLA surface) on update-jira path (ADV-F2-P2-009).**
   New VP: "when update-jira appends to or links an open ticket with an active SLA, the loop
   output contains an SLA impact statement (per §3.5)." BATS test with SLA-deadline-bearing
   ticket fixture.

4. **VP for D-DEC-002 grace-window + Jira-first dedup (ADV-F2-P2-009).** VP-SKILL-050
   tests only watermark monotonicity. Need: "grace-window re-fetched events that already
   have Jira tickets receive append-comment rather than create-new." BATS test: inject an
   event within GRACE window range that has an existing open ticket → assert comment path,
   not create path. Paired mutant SM-N: disable Jira-first dedup → assert duplicate ticket
   created (mutant dies).

5. **verification-delta version-ref sync (ADV-F2-P2-005).** verification-delta.md header
   references "BC-10.01.001 v1.2" but live version is v1.3. Update verification-delta to
   reference the current BC version. §7 Part B lists VP-SKILL-064/065 as "still-owed" but
   BC-10.01.001 v1.3 already carries them as FINALIZED. Reconcile §7 Part B language to
   reflect finalized status.

*Pass-2 PO PROPAGATION LIST and formal-verifier list complete. Architect does NOT edit BCs,
verification-delta, prd-delta, or STATE.md.*

---

### 8.8 BC PROPAGATION LIST (pass 3 — architect does NOT edit these)

> **Owner:** Product-owner. Apply after pass-3 content fixes freeze. Do NOT chase version
> refs in this edit (cross-doc version sweep is a SEPARATE pass, deferred until content
> fixes are complete — see ADV-F2-P3-007/P3-009 note at end of §8.8).
>
> **Live BC version map (as of 2026-07-20, pass-3 baseline):**
> - BC-3.01.001: **v1.14** (live)
> - BC-3.03.001: **v1.9** (live)
> - BC-4.05.001: version to be confirmed with PO
> - BC-5.01.001: **v1.5** (live)
> - BC-6.01.001: version to be confirmed with PO
> - BC-10.01.001: **v1.5** (live)

---

#### 8.8.1 BC-3.03.001 (disposition-guard) — Pass-3 Required Changes

**Current version: v1.9. Target: v1.10.**

1. **Invariant #4 hard-floor list — add asset_type=unknown (ADV-F2-P3-001 CRITICAL).**
   The current hard-floor list in Invariant #4 includes:
   > "`verdict.asset_type` is in `CRITICAL_ASSET_TYPES` (field 14; domain controllers, OT safety systems, privileged accounts)"
   Add a NEW bullet:
   > "`verdict.asset_type == 'unknown'` — conservative hard floor for unclassified assets; mirrors ORCHESTRATOR POLICY DECISION ADV-F2-P2-010 already in BC-10.01.001 v1.7 Inv#10. The deterministic hook must block marker issuance for unknown assets independently of SKILL.md behavior (defense-in-depth)."
   Update the hard-floor check pseudocode in Invariant #4 to add the explicit `unknown` check
   (see architecture-delta.md v1.4 §D-DEC-008 `hard_floor_applies()` pseudocode).

2. **Invariant #4 create emitter branch — org-binding via project key (ADV-F2-P3-002 MAJOR).**
   Current create branch generates: `pattern = "^jr (--output json )?issue create "`.
   Update to: `pattern = "^jr (--output json )?issue create .*--project " + verdict.jira_project_key`.
   Add: "If `verdict.jira_project_key` is null or absent: emit allow WITHOUT marker (same
   as ticket_action_type=none path — the write is permitted but no jr create is authorized
   without project-key binding). The monitoring-loop MUST always include `--project
   ${JIRA_PROJECT_KEY}` in every `jr issue create` command."
   Update the command_pattern generation table: create row, `command_pattern` column, to reflect
   the project-key-bound pattern (per architecture-delta.md v1.4 §D-DEC-008 table).
   Update the "Create-marker multiplicity note" (added v1.9): "The create command_pattern NOW
   embeds the Jira project key for org-binding (D-DEC-011). The iterative-consume fix
   (BC-3.01.001 v1.14) remains correct — multiple same-org create markers for different
   alerts within one loop run are handled by FIFO iteration; fungibility across orgs is
   prevented by the project-key binding."

3. **PC#2 (investigation markdown path) — correct field count from 15 to 12 (ADV-F2-P3-003 MAJOR).**
   Current PC#2 third bullet reads: "ICD-203 15-field validation (markdown path). The 15
   mandatory field headings are: ... Severity, Asset Type, Ticket Action Type."
   CORRECT TO: "ICD-203 **12-field** validation (markdown path). The 12 mandatory field headings
   are: Disposition, Confidence, Sensor Health Status, Evidence Artifacts, Timeline Events,
   Hypotheses Considered, Alternatives Rejected, Uncertainty Explicit, Attack Techniques,
   Agent Actions, Human Actions, Tuning Signal."
   Remove Severity, Asset Type, Ticket Action Type from the investigation markdown heading
   list. These three fields are monitoring-loop verdict schema fields, NOT human investigation
   document sections (Ticket Action Type has no meaning in a human investigation document).
   BC-5.01.001 v1.7 Invariant #7 correctly says "12-field validation" — the erratum is in
   BC-3.03.001 PC#2 only. The JSON verdict path (PC#3) retains all 15 fields — no change.

4. **Resolve [PENDING-DEFINITION] cross-tenant-indicator vs BC-3.01.001 active citation
   (ADV-F2-P3-011 minor).** The Invariant #4 hard-floor currently reads: "Cross-tenant scope
   indicators present in `evidence_artifacts` (see schema below) — [PENDING-DEFINITION per
   ADV-F2-016: full MSSP cross-tenant schema to be confirmed once prism MSSP-global store
   format is finalized.]" BC-3.01.001 v1.14 PC#2 Hard-floor guarantee already cites
   "cross-tenant scope" as an active hard-floor category. Options: (a) if cross-tenant schema
   remains undefined, REMOVE the active citation from BC-3.01.001 PC#2 hard-floor guarantee
   note; (b) if the schema can be defined now, resolve [PENDING-DEFINITION]. PO decides which
   option; choose one consistently across both BCs.

---

#### 8.8.2 BC-5.01.001 (investigate-event) — Pass-3 Required Changes

**Current version: v1.5. Target: v1.6.**

1. **Version refs correction (ADV-F2-P3-009 minor — deferred to version-coherence sweep).**
   BC-5.01.001 v1.7 Invariant #7 cites "BC-3.03.001 v1.6/BC-3.01.001 v1.11". Live versions
   are v1.11/v1.15. Defer version ref updates to the dedicated cross-doc version-coherence
   sweep (see NOTE below) — do NOT update inline during this pass to avoid churn on a doc
   that needs no semantic changes.

2. **Confirm 12-field citation is correct (ADV-F2-P3-003 — no semantic change needed).**
   BC-5.01.001 v1.7 Invariant #7 says "after the investigation document passes ICD-203
   12-field validation." This citation is CORRECT (architecture-delta.md v1.4 §D-DEC-008
   artifact-class branching decision confirms 12 fields for investigation markdown). PO
   confirms: no semantic change required to BC-5.01.001. The erratum is in BC-3.03.001 PC#2
   only (corrected per §8.8.1 item 3 above).

3. **Stage 3 PrismQL org_slug scoping — VP cross-reference note (ADV-F2-P3-004 MAJOR).**
   BC-5.01.001 v1.7 PC#7 Stage-3 raw OCSF event lookup and temporal-adjacency queries issue
   PrismQL with no covering VP for org_slug isolation. Add a note to PC#7:
   > "Verification property: VP-SKILL-064 (monitoring-loop org_slug scoping) provides the
   > cross-tenant isolation pattern. A dedicated VP for BC-5.01.001 Stage-3 PrismQL org_slug
   > scoping is needed (proposed: VP-SKILL-069 — investigate-event PrismQL queries always
   > include explicit org_slug WHERE clause). Add to VP table and VP-INDEX.md as PROPOSED."
   Add Invariant #8: "All PrismQL queries issued by this skill MUST include an explicit
   org_slug scope constraint (D-DEC-005). No PrismQL query without org_slug is ever issued."

---

#### 8.8.3 BC-10.01.001 (monitoring-loop) — Pass-3 Required Changes

**Current version: v1.5. Target: v1.6.**

1. **Stage 7 verdict-file-path naming precondition (ADV-F2-P3-005 MEDIUM).**
   Add to Preconditions (after existing PC#6 or as PC#8):
   > "The monitoring-loop Stage 7 DOCUMENT step writes the verdict file to a path that
   > contains the substring `verdict` as a component (e.g.,
   > `artifacts/investigations/verdict-<alert_id>-<iso_ts>.json`). Writing to a path
   > without the string `verdict` causes disposition-guard to fast-path allow WITHOUT
   > ICD-203 validation and WITHOUT marker issuance — making every Stage 8 `jr` write
   > permanently denied by require-review (no marker to consume). This is a load-bearing
   > naming convention. Canonical path: `artifacts/investigations/verdict-<alert_id>.json`."
   Also update Stage 7 in Invariant #14 stage-order description to explicitly state: "writes
   to path containing 'verdict' substring (naming convention invariant — see PC#8)."

2. **Confidence field #2 — add float→enum mapping reference (ADV-F2-P3-008 MEDIUM).**
   In Invariant #9, field #2 definition:
   Current: `2. confidence (high|medium|low)`
   Update to: `2. confidence (high|medium|low — the ENUM form, NOT a float; see D-DEC-011 for
   the float→enum mapping thresholds: high ≥ 0.75, medium ≥ 0.40, low < 0.40; assess-priority
   BC-4.05.001 emits BOTH confidence_score float AND confidence enum; monitoring-loop uses the
   enum for this field; disposition-guard type-asserts enum, not float)`
   Add cross-reference to D-DEC-011.

3. **verdict.jira_project_key operational field — note (ADV-F2-P3-002 consequence).**
   Add a note after the 15-field list in Invariant #9:
   > "**Operational metadata (non-ICD-203, beyond the 15 mandatory fields):** The verdict
   > JSON MUST also include `jira_project_key` (string — the Jira project key for this org,
   > e.g., `SEC`). This is an authorization-routing field used by disposition-guard to
   > generate an org-bound create command_pattern (D-DEC-011 / ADV-F2-P3-002). It does NOT
   > count against the 15 ICD-203 field count and VP-HOOK-025 does NOT validate it. If absent,
   > disposition-guard cannot issue a create-scoped marker (emits allow without marker;
   > Stage 8 create is human-gated)."

---

#### 8.8.4 BC-4.05.001 (assess-priority) — Pass-3 Required Changes

**Target: next version bump.**

1. **PC#6 — add confidence enum output alongside float posterior (ADV-F2-P3-008 MEDIUM).**
   Current PC#6 outputs `confidence` as a float 0.0–1.0 (posterior probability).
   Update PC#6 to output BOTH:
   - `confidence_score` (float 0.0–1.0): the raw Bayesian posterior — for audit chain-of-custody
   - `confidence` (enum `high|medium|low`): the mapped enum using D-DEC-011 thresholds:
     `high` if confidence_score ≥ 0.75; `medium` if ≥ 0.40 and < 0.75; `low` if < 0.40.
   Add a postcondition note: "The `confidence` enum MUST be consistent with the
   `confidence_score` float per D-DEC-011 thresholds. Outputs where confidence_score ≥ 0.75
   but confidence == 'low' are invalid. The monitoring-loop uses `confidence` (enum) for
   verdict field #2 — a raw float in that field fails disposition-guard's jq type assertion."

2. **Invariant for PrismQL org_slug scoping (ADV-F2-P3-004 MAJOR).**
   Add Invariant: "All PrismQL queries issued by this skill MUST include an explicit
   org_slug scope constraint (D-DEC-005 obligation). BC-4.05.001 PC#5a/5d PrismQL paths are
   currently uncovered by any org_slug isolation VP. Add cross-reference: VP-SKILL-070
   (proposed — assess-priority PrismQL org_slug scoping) — add to VP table as PROPOSED."

---

#### 8.8.5 BC-6.01.001 (activate) — Pass-3 Required Changes

**Target: next version bump.**

1. **jr auth subcommand correction (ADV-F2-P3-010 minor).**
   BC-6.01.001 PC#10 and EC-010 use `jr auth check`. Ground truth (orchestrator-verified
   jr 0.5.0): the subcommand is `jr auth status` (`jr auth` subcommands: login, status,
   refresh, switch, list, logout, remove — "check" does not exist). Update ALL occurrences
   of `jr auth check` → `jr auth status` in PC#10, EC-010, and any BATS test names that
   reference "auth check".

---

> **NOTE — cross-doc VERSION-COHERENCE SWEEP (ADV-F2-P3-007/P3-009):** Pervasive stale
> cross-BC version refs (e.g., BC-5.01.001 citing v1.6/v1.11 while live is v1.11/v1.15) are
> hand-maintained and not being chased in this pass to avoid conflating semantic changes with
> mechanical ref updates. A dedicated VERSION-COHERENCE SWEEP should run AFTER all content
> fixes in pass 3 are merged and BCs are at stable versions. Do not update version refs inline
> during this pass.

---

### 8.9 FORMAL-VERIFIER LIST (pass 3)

> **Owner:** Formal verifier. These items require new or updated verification properties,
> mutants, and verification-delta amendments. The architect does NOT write VPs.

1. **VP-HOOK-026 unknown leg (ADV-F2-P3-001 CRITICAL).**
   VP-HOOK-026 currently covers: Indeterminate + HIGH severity + degraded sensor. Add the
   `asset_type=unknown` hard floor as a new BATS test:
   ```
   @test "monitoring-loop hard floor: unknown asset_type never gets marker regardless of autonomy_enabled"
   ```
   Paired mutant: SM-N — remove `unknown` from disposition-guard hard-floor check → assert
   marker IS written (mutant dies when test detects marker presence). Update VP-HOOK-026
   description and test list in verification-delta.md and VP-INDEX.md.

2. **Org_slug VPs for BC-4.05.001 Inv#4 and BC-5.01.001 Stage 3 (ADV-F2-P3-004 MAJOR).**
   VP-SKILL-064 is currently scoped to monitoring-loop only. Two new VPs needed:
   - **VP-SKILL-069 (proposed):** investigate-event PrismQL queries always include
     explicit org_slug WHERE clause (BC-5.01.001 PC#7 Stage-3 OCSF lookup + temporal-
     adjacency query). Proof strategy: static Iron Law content assertion on SKILL.md +
     prism-DTU multi-org fixture (org-a query returns zero org-b rows). Add to VP-INDEX.md
     as PROPOSED; formal verifier adjudicates.
   - **VP-SKILL-070 (proposed):** assess-priority PrismQL queries always include explicit
     org_slug WHERE clause (BC-4.05.001 PC#5a/5d paths). Same proof strategy as VP-SKILL-069.
     Add to VP-INDEX.md as PROPOSED.

3. **Artifact-class field-set VP + verdict-path-reachability VP (ADV-F2-P3-013 obs).**
   Two VP-coverage seams with no owning VP:
   - **VP-HOOK-025 split (or update):** VP-HOOK-025 must explicitly cover the two-path field
     count — investigation markdown = 12 fields DENIED at field 13 (Severity heading absent
     does NOT deny); verdict JSON = 15 fields DENIED at fields 13/14/15. Update BATS test
     names and counts to reflect the per-class field sets. Mutant SM-N: insert a Severity
     heading into an investigation markdown file and assert it does NOT cause a second-pass
     deny (no regression expected — disposition-guard only checks 12 fields for investigation
     class).
   - **VP-HOOK-028 (new, proposed):** Verdict-path-reachability — a monitoring-loop jr write
     is denied when Stage 7 writes the verdict file to a path NOT containing 'verdict'
     (disposition-guard fast-path fires; no marker issued; require-review denies Stage 8).
     BATS test: simulate Stage 7 write to `artifacts/findings/alert-001.json` (no 'verdict'
     substring) → assert no marker in marker-store → assert Stage-8 jr deny.

4. **Confidence float→enum mapping VP (ADV-F2-P3-013 obs / D-DEC-011).**
   **VP-HOOK-025 update:** Add BATS test `@test "disposition-guard denies verdict with float
   confidence value"` (e.g., `confidence: 0.85` fails enum type assertion). Add test for
   each enum value: `@test "disposition-guard allows verdict with confidence='high'"`, etc.
   **VP-SKILL-071 (new, proposed):** assess-priority confidence enum consistency — for each
   `confidence_score` output, the `confidence` enum matches D-DEC-011 thresholds (high ≥
   0.75, medium ≥ 0.40, low < 0.40). Proof: proptest/hypothesis property test over
   (0.0, 1.0) float range asserting enum boundary at each threshold. Tag P1.

*Pass-3 PO PROPAGATION LIST (§8.8) and formal-verifier list (§8.9) complete. Architect
does NOT edit BCs, verification-delta, prd-delta, or STATE.md. Cross-doc version-coherence
sweep deferred to a separate dedicated pass after content fixes freeze.*

---

## 8.10 PO PROPAGATION LIST (pass 4)

PO must incorporate the following changes into the behavioral contracts. Architect owns only
architecture-delta.md. Do NOT edit BCs, verification-delta, prd-delta, or STATE.md here.

1. **BC-3.03.001 v1.13 — JSON-first dispatch (ADV-F2-P4-001 CRITICAL) — COMPLETE**
   Rewrite PC#1/PC#2/PC#3 to implement JSON-first dispatch order:
   - PC#1: if `tool_input.file_path` ends in `.json` OR content is valid JSON (`jq empty
     2>/dev/null` succeeds) → verdict-class 15-field path
   - PC#2: elif `tool_input.file_path` matches `*investigation-*.md` (must end in `.md`)
     → investigation-class 12-field path
   - PC#3: else → fast-path allow (no ICD-203 enforcement)
   Remove the plain `investigation` substring check from PC#2 (replace with glob requiring
   `.md` extension to prevent `.json` files with `investigation` in path from misrouting).
   Remove the `verdict` substring check from PC#3 (verdict detection is now fully handled by
   the JSON-first PC#1 check).

2. **BC-3.03.001 v1.13 — Anchored create pattern (ADV-F2-P4-002 CRITICAL) — COMPLETE**
   Update the create-emitter branch to generate the fixed-position pattern:
   `^jr (--output json )?issue create --project <jira_project_key>( |$)`
   Remove the `.*` before `--project`. The `--project` argument MUST be the first flag after
   `issue create`. Add this as an explicit precondition in BC-3.03.001 PC (Iron Law for
   monitoring-loop SKILL.md: `--project` is always first).

3. **BC-3.03.001 v1.13 — enum-membership validation (ADV-F2-P4-006 MAJOR) — COMPLETE**
   Add to PC#3 (verdict JSON path): before hard-floor evaluation, validate enum membership
   for: severity ∈ {LOW,MEDIUM,HIGH,CRITICAL}, asset_type ∈ {domain_controller,
   privileged_account, ot_safety_system, standard, unknown}, disposition ∈ {TP,FP,BTP,
   Indeterminate}, sensor_health_status ∈ {healthy,degraded,silent}, ticket_action_type ∈
   {comment,create,assign,none,create-review,comment-review}, confidence ∈ {high,medium,low}.
   Fail-closed: non-member value → emit deny. Update PC#3 validation sequence accordingly.

4. **BC-3.03.001 v1.13 — autonomy_enabled operational field (ADV-F2-P4-005 MAJOR) — COMPLETE**
   Add `autonomy_enabled` to the verdict schema as a non-ICD-203 operational metadata field
   (alongside `confidence_score` and `jira_project_key`). Update Inv#4 (emitter contract) to
   state that disposition-guard reads `autonomy_enabled` directly from the verdict file (not
   delegated to the monitoring-loop LLM). Default-false (absent field treated as false).
   Update emitter description to reflect the Step 3 (review path) / Step 4 (hard-floor upgrade,
   renumbered at ADV-F2-P6-002) / Step 5 (kill switch, renumbered at ADV-F2-P6-002) ordering
   from architecture-delta.md D-DEC-008 v1.9.

5. **BC-3.03.001 v1.13 — create-review/comment-review emitter branches (D-DEC-012) — COMPLETE**
   Add emitter branches for `ticket_action_type == "create-review"` and `"comment-review"`.
   These run BEFORE the autonomy_enabled and hard_floor checks (see D-DEC-012 decision above).
   Document that these paths are exempt from hard_floor_applies() and autonomy_enabled.

6. **BC-10.01.001 v1.9 — Inv#5 inverted silence condition (ADV-F2-P4-003 MAJOR) — COMPLETE**
   Change `last_seen_ts > now() - INTERVAL 24h` to `last_seen_ts < now() - INTERVAL 24h` in
   Inv#5 AND EC-006. Update brief §3.2 Stage 0 pseudocode to match. Verify the canonical test
   vector EC-006 ("last_seen_ts = 36h ago, zero rows → BLIND-SPOT"): 36h ago IS older than
   24h ago (36h ago < 24h ago in the positive time direction), so the corrected `<` condition
   fires correctly for this test vector.

7. **BC-10.01.001 v1.9 — Inv#10 narrowed for review surfacing (ADV-F2-P4-004 MAJOR + P4-007) — COMPLETE**
   Narrow BC-10.01.001 Inv#10 from "hard floor → ticket_action_type='none'" to:
   - Hard-floor verdict AND no existing open review ticket for (org_slug, sensor_id)
     → `ticket_action_type = "create-review"`
   - Hard-floor verdict AND existing open review ticket (dedup case)
     → `ticket_action_type = "comment-review"`
   - `ticket_action_type = "none"` ONLY when: (a) autonomy_enabled=false AND non-hard-floor
     verdict, OR (b) all surfacing actions for this run are already complete (dedup-resolved)
   Reconcile with EC-006 (BLIND-SPOT creation) and EC-014 (REVIEW-REQUIRED creation) to
   eliminate the mutual exclusion.

8. **BC-3.01.001 v1.17 — consumer algorithm step (6) accepts create-review/comment-review (D-DEC-012) — COMPLETE**
   Update step (6) "authorized_operations scope check":
   - `jr issue create ...` command → accept markers with `["create"]` OR `["create-review"]`
   - `jr issue comment ...` command → accept markers with `["comment"]` OR `["comment-review"]`
   No other logic changes to the consumer algorithm.

9. **BC-3.01.001 v1.17 — audit log control-char sanitization (ADV-F2-P4-010 MINOR) — COMPLETE**
   Update step (8) (audit log construction): strip control characters (0x00–0x1f) from
   `ticket_id`, `org_slug`, and `authorized_operations[0]` before interpolation into the
   audit log line. Extend the existing base64 encoding note (ADV-F2-013) to cover all fields.

10. **BC-4.02.001 v1.8 — remove cross-tenant from PC#4 hard-floor list (ADV-F2-P4-008 MINOR) — COMPLETE**
    Remove "cross-tenant campaign correlation findings" from BC-4.02.001 PC#4 hard-floor
    category enumeration. This category was removed from BC-3.03.001 at v1.10 and from
    BC-3.01.001 at v1.15 (P3-011 decision: cross-tenant is prism-side, not plugin-side).
    BC-4.02.001 was not updated at that time — this closes the inconsistency.

11. **NFR catalog update — per-run budget cap (ADV-F2-P4-011 MINOR) — COMPLETE**
    Add to NFR catalog (NFR-PERF-NNN):
    - MAX_ALERTS_PER_RUN: configurable (default 50); bounds execution time per monitoring-loop run
    - Priority ordering when cap hit: process highest-severity alerts first
    - Watermark advance on cap: advance to last successfully processed event's `_time`
    - Budget-exhaustion artifact: loop MUST write `[BUDGET-EXHAUSTED]` annotation to loop output
      with count of deferred alerts and highest severity among deferred; prevents silent deferral
      of CRITICAL alerts

---

## 8.11 FORMAL-VERIFIER LIST (pass 4)

Formal verifier must update verification properties as follows. Architect owns design;
FV owns proof strategies, test implementation, and VP-INDEX.md updates.

1. **VP-HOOK-025 update — enum-membership validation BATS tests (ADV-F2-P4-006 MAJOR)**
   Add BATS test assertions for enum-membership validation in disposition-guard:
   ```
   @test "disposition-guard denies verdict with severity='High' (wrong case)"
   @test "disposition-guard denies verdict with severity='CRITICAL' (valid — should allow if other fields OK)"
   @test "disposition-guard denies verdict with asset_type='Unknown' (wrong case)"
   @test "disposition-guard denies verdict with disposition='indeterminate' (wrong case)"
   @test "disposition-guard denies verdict with ticket_action_type='NONE' (wrong case)"
   ```
   Paired mutants: remove each enum-membership check → assert marker IS issued for a
   case-mangled verdict (mutant dies when enum check is missing). Update VP-HOOK-025 description
   and test list in verification-delta.md and VP-INDEX.md.

2. **VP-HOOK-026 update — review-surfacing BATS tests (D-DEC-012 / ADV-F2-P4-004)**
   Add BATS tests for create-review and comment-review paths:
   ```
   @test "disposition-guard: Indeterminate verdict with create-review → restricted review marker emitted"
   @test "disposition-guard: silent sensor verdict with comment-review → restricted review marker emitted"
   @test "disposition-guard: Indeterminate verdict with create-review → marker authorized_operations is ['create-review']"
   @test "disposition-guard: autonomy_enabled=false + create-review → review marker still emitted (kill switch exemption)"
   @test "disposition-guard: HIGH severity verdict with create-review → review marker emitted (hard floor exemption for review path)"
   ```
   Paired mutants: remove the create-review hard-floor bypass → assert NO marker for
   Indeterminate+create-review (mutant dies when test expects marker). Update VP-HOOK-026
   description and test list.

3. **VP-HOOK-024 update — create pattern injection-safety BATS test (ADV-F2-P4-002 CRITICAL)**
   Add BATS test:
   ```
   @test "disposition-guard: create marker command_pattern uses fixed --project position (no .* before --project)"
   @test "require-review: create command with injected --project in --summary does not match create marker pattern"
   ```
   The second test: marker with `command_pattern = "^jr issue create --project PROJ_A( |$)"`;
   command is `jr issue create --summary "review --project PROJ_A" --project PROJ_B`; assert
   DENY (pattern does not match because `--project PROJ_A` is not the first argument after `create`).

4. **VP-HOOK-026 update — autonomy_enabled kill switch determinism (ADV-F2-P4-005 MAJOR)**
   Add BATS test:
   ```
   @test "disposition-guard: verdict with autonomy_enabled=false + create action → no marker emitted"
   @test "disposition-guard: verdict with autonomy_enabled=false + comment action → no marker emitted"
   @test "disposition-guard: verdict with autonomy_enabled absent → treated as false → no marker emitted"
   ```
   Paired mutant: remove the autonomy_enabled false-check → assert marker IS issued (mutant
   dies when kill-switch test detects unexpectedly issued marker). Update VP-HOOK-026.

5. **VP-HOOK-028 update — canonical path dispatch regression test (ADV-F2-P4-001 CRITICAL)**
   Current VP-HOOK-028 covers verdict-path reachability (path must contain `verdict`). Add:
   ```
   @test "disposition-guard: artifacts/investigations/verdict-<id>.json → routes to verdict-class (15-field), not investigation-markdown (12-field)"
   @test "disposition-guard: artifacts/investigations/investigation-001.md → routes to investigation-class (12-field), not verdict-class"
   ```
   These tests specifically cover the canonical path collision. Update VP-HOOK-028 description
   to reflect the JSON-first dispatch test coverage.

6. **New VP-HOOK-029 (proposed) — D-DEC-012 fail-loud invariant (D-DEC-012)**
   New verification property: "hard-floor verdict with ticket_action_type ∈ {create-review,
   comment-review} MUST produce a marker OR fail with explicit error — never silent discard."
   Integration test: simulate disposition-guard receiving a verdict with
   `disposition=Indeterminate`, `ticket_action_type=create-review`; assert marker file
   created in marker store (or explicit error logged). Proof strategy: BATS integration test.
   Tag P1. Add to VP-INDEX.md as PROPOSED; adjudicated in F6.

*Pass-4 PO PROPAGATION LIST (§8.10) and formal-verifier list (§8.11) complete. Architect
does NOT edit BCs, verification-delta, prd-delta, or STATE.md. v1.6 is final for pass-4
adversarial remediation.*

---

## 8.12 PO PROPAGATION LIST (pass 5 — ADV-F2-P5-001..P5-003)

> **Owner:** Product-owner. Architect does NOT edit BCs, verification-delta, prd-delta, or STATE.md.
>
> **Live BC version map (frozen pass-5 baseline): BC-3.01.001 v1.17, BC-3.03.001 v1.13,
> BC-10.01.001 v1.9.**
>
> **Kill-switch gate RESOLVED 2026-07-21:** Human operator confirmed Option A — all §8.12
> items are now unblocked. Item 2 (STEP 3 kill-switch semantics) may be finalized in BC-3.03.001.

---

### 8.12.1 BC-3.03.001 (disposition-guard) — Pass-5 Required Changes

**Current version: v1.13. Target: v1.14.**

1. **STEP 3 — Gate review-marker exemption on hard_floor_applies() (ADV-F2-P5-002 MAJOR).**
   The create-review and comment-review emitter branches in Inv#4 STEP 3 must be gated on
   `hard_floor_applies(verdict)`:

   Current (defective):
   ```
   IF action == "create-review": → issue review marker [no precondition]
   ELIF action == "comment-review": → issue review marker [no precondition]
   ```
   Corrected:
   ```
   IF action in {create-review, comment-review}:
     IF NOT hard_floor_applies(verdict):
       emit allow without marker; RETURN   # over-label: no exemption for non-hard-floor
     IF action == "create-review": → issue review marker
     ELIF action == "comment-review": → issue review marker
   ```
   Add inline comment: "Review-marker exemption requires hard_floor_applies(verdict)=TRUE.
   O3 standing rule: LLM-supplied routing field (ticket_action_type) cross-validated against
   hook-computed invariant (hard_floor_applies) before bypass granted."

   **Kill-switch semantics — CONFIRMED 2026-07-21 (Option A):** D-DEC-012 is final.
   create-review/comment-review markers are issued and consumed under autonomy_enabled=false
   when the verdict is genuinely hard-floor (hard_floor_applies()=true per P5-002 gate).
   Brief §3.9 amendment (clarify "Jira DRAFTING" to include human-escalation writes) is
   delegated to product-owner in this same burst. PO may finalize this Inv#4 paragraph
   without any PENDING qualifier.

> **[SUPERSEDED BY §8.16 (P7-001 deny-the-Write)]** The upgrade-to-create-review mechanism in this item was proved structurally unsound by P7-001 and replaced by DENY-THE-WRITE. Retained for historical traceability only — do NOT apply.

2. **STEP 4 (formerly STEP 5, renumbered at ADV-F2-P6-002) — Fail-loud under-label correction (ADV-F2-P5-001 CRITICAL).**
   Replace the current STEP text (now STEP 4 per architecture-delta v1.9):
   > "IF action == 'none' OR hard_floor_applies(): emit allow without marker; RETURN"

   With the upgrade logic:
   > "IF hard_floor_applies(): upgrade to create-review or comment-review (based on ticket_id
   > presence); write UNDER-LABEL-CORRECTED audit entry; GOTO WRITE_MARKER. If project_key
   > absent for create path: write error artifact to audit.log + emit deny."
   > "IF action == 'none' (and hard_floor_applies()=FALSE): emit allow without marker; RETURN"

   Key invariants to document in Inv#4:
   - Silent discard is PROHIBITED: a hard-floor verdict with a non-review ticket_action_type
     does not silently pass; the hook deterministically upgrades or denies.
   - Upgrade precedence: ticket_id present → comment-review; ticket_id null → create-review.
   - Audit entry UNDER-LABEL-CORRECTED written on every upgrade (not just error path).

3. **D-DEC-001 schema v2.1 sync (ADV-F2-P5-003 MAJOR).**
   Update all schema snippets in Inv#4 and PC#3 that show the marker schema to reflect the
   §D-DEC-001 v2.1 authoritative block additions:
   - `authorized_operations` enum: add `"create-review"` and `"comment-review"` values
   - `disposition.verdict` enum: add `"Indeterminate"` value
   - `disposition.ticket_action_type` sub-field: add to disposition sub-object

---

### 8.12.2 BC-10.01.001 (monitoring-loop) — Pass-5 Required Changes

**Current version: v1.9. Target: v1.10.**

1. **Inv#10 — under-label semantics clarification (ADV-F2-P5-001 consequence).**
   Add a note to Inv#10 (and EC-006/EC-014 guidance):
   > "The monitoring-loop SHOULD set ticket_action_type to create-review or comment-review
   > for hard-floor verdicts (per D-DEC-012 semantics). If the monitoring-loop sets a
   > non-review action type on a hard-floor verdict (under-label), disposition-guard hook
   > STEP 4 (renumbered ADV-F2-P6-002) upgrades it deterministically and writes an UNDER-LABEL-CORRECTED audit entry.
   > The SKILL.md Iron Law remains: set the correct review token in the first place.
   > The hook upgrade is a safety net, not an invitation to rely on correction."
   This clarifies that the deterministic enforcement is defense-in-depth, not a delegation.

---

## 8.13 FORMAL-VERIFIER LIST (pass 5 — ADV-F2-P5-001..P5-002)

> **Owner:** Formal verifier. Architect does NOT write VPs.

> **[SUPERSEDED BY §8.17 item 1 (P7-001 deny-the-Write)]** VP-HOOK-029 re-scope in this item was superseded by the end-to-end consumer-boundary re-scope in §8.17. The BATS vectors below that assert marker-in-store for the upgrade path are RETIRED per §8.17. Retained for historical traceability only — do NOT apply.

1. **VP-HOOK-029 re-scope (ADV-F2-P5-001 CRITICAL).**
   Current VP-HOOK-029 scope: "hard-floor verdict WITH ticket_action_type ∈ {create-review,
   comment-review} MUST produce a marker OR fail with explicit error." This scope CANNOT detect
   the P5-001 silent-discard case (action=comment/none) — it only tests the happy review path.

   **Re-scoped VP-HOOK-029:** "hard-floor verdict with ticket_action_type ∈ {comment, create,
   assign, none} (non-review token) MUST result in either (a) a create-review or comment-review
   marker in the marker store (upgrade path), OR (b) an explicit error artifact in audit.log
   AND a deny emitted (missing project_key path) — NEVER a silent allow-without-marker."

   New BATS test vectors required:
   ```bats
   @test "VP-HOOK-029: Indeterminate + ticket_action_type=create (under-label) → create-review marker in store"
   @test "VP-HOOK-029: HIGH severity + ticket_action_type=comment (under-label) → comment-review marker in store"
   @test "VP-HOOK-029: Indeterminate + ticket_action_type=none + ticket_id present → comment-review marker in store"
   @test "VP-HOOK-029: Indeterminate + ticket_action_type=create + project_key absent → deny + FAIL-LOUD in audit.log"
   @test "VP-HOOK-029: hard-floor verdict + ticket_action_type=create-review (correct label) → review marker in store (existing path unbroken)"
   ```
   Retain the existing "correct label → marker" test vectors — the re-scope adds the under-label
   test vectors, not replaces the over-label happy-path coverage.

   Paired mutant SM-32 re-scope: SM-32 was previously "remove review-marker hard-floor bypass."
   Re-scope to also include: "remove STEP 4 upgrade logic (formerly STEP 5, renumbered ADV-F2-P6-002) (revert to silent emit-allow-without-
   marker)" → assert that an under-labeled hard-floor verdict produces NO marker (mutant
   detectable by the new BATS vectors above). Both SM-32 variants (remove STEP 3 gate AND
   remove STEP 4 upgrade) must be separately killable.

   Update VP-HOOK-029 description, test list, and SM-32 mutant definition in verification-delta.md
   and VP-INDEX.md. Tag P0 (CRITICAL fix).

2. **VP-HOOK-026 — over-label test vectors (ADV-F2-P5-002 MAJOR).**
   Add BATS tests for the P5-002 over-label gate:
   ```bats
   @test "VP-HOOK-026: non-hard-floor TP verdict + create-review token → emit allow WITHOUT marker (over-label rejected)"
   @test "VP-HOOK-026: non-hard-floor FP verdict + comment-review + autonomy_enabled=false → emit allow without marker (no kill-switch bypass)"
   @test "VP-HOOK-026: LOW severity standard asset + create-review → no review marker (over-label; verify hard_floor_applies()=false path)"
   ```
   Paired mutant: remove the `NOT hard_floor_applies()` guard from STEP 3 → assert review marker
   IS issued for a non-hard-floor verdict with create-review token (mutant dies when test
   detects unexpected marker in store). Update VP-HOOK-026.

*Pass-5 PO PROPAGATION LIST (§8.12) and formal-verifier list (§8.13) complete. Architect does
NOT edit BCs, verification-delta, prd-delta, or STATE.md. v1.8 was final for pass-5
adversarial remediation. v1.9 continues with pass-6 — see §8.14 and §8.15 below.*

---

## 8.14 PO PROPAGATION LIST (pass 6 — ADV-F2-P6-001..P6-009)

> **Owner:** Product-owner (PO). Architect does NOT edit BCs, verification-delta, prd-delta, or STATE.md.
>
> **Live BC version map (frozen pass-6 baseline):** BC-3.01.001 v1.17, BC-3.03.001 v1.14, BC-10.01.001 v1.10.
>
> **Scope:** This is the FIRST cycle in which the CONSUMER BC (BC-3.01.001) changes. Apply BC-3.01.001
> changes FIRST so the consumer cross-check is in place before the emitter's new patterns reference it.

---

### 8.14.1 BC-3.01.001 (require-review) — Pass-6 Required Changes

**Current version: v1.17. Target: v1.18.**

1. **Consumer algorithm step (6) — replace OR-accept with exact-type matching (ADV-F2-P6-001 CRITICAL).**

   Current step (6): accepts `["create"]` OR `["create-review"]` for `jr issue create` commands;
   accepts `["comment"]` OR `["comment-review"]` for `jr issue comment` commands.

   Replace with exact-type matching:
   - `jr issue create ... --label REVIEW-REQUIRED ...` or `... --label BLIND-SPOT ...` → accept ONLY `["create-review"]`; skip `["create"]` markers
   - `jr issue create ...` without review label → accept ONLY `["create"]`; skip `["create-review"]` markers
   - `jr issue comment ...` → accept `["comment"]` or `["comment-review"]`; log op-type in audit (structural cross-check pending ASM-014)
   - `jr issue assign ...` → accept ONLY `["assign"]` (unchanged)

2. **New step (6a): consumer anti-fungibility cross-check (ADV-F2-P6-001).**

   After `anchored_match` succeeds (step 5), before adding candidate:
   ```
   has_review_label = ("--label REVIEW-REQUIRED" in command) OR ("--label BLIND-SPOT" in command)
   IF candidate.authorized_operations == ["create-review"] AND NOT has_review_label:
     CONTINUE  (EC-023: review marker requires review-labeled command)
   IF candidate.authorized_operations == ["create"] AND has_review_label:
     CONTINUE  (EC-023: regular marker cannot authorize review-labeled create)
   ```
   Add EC-023 error code definition: "consumer cross-check anti-fungibility: create-review marker
   skipped for non-review-labeled command; create marker skipped for review-labeled command."

3. **Add VP cross-reference:** step (6a) must cite VP-HOOK-029 (consumer leg) and reference the
   P6-001 anti-fungibility vectors.

---

### 8.14.2 BC-3.03.001 (disposition-guard) — Pass-6 Required Changes

**Current version: v1.14. Target: v1.15.**

1. **STEP reorder (ADV-F2-P6-002 CRITICAL).**

   Current ordering:
   - STEP 4: `autonomy_enabled` kill switch (IF NOT true → emit allow without marker; RETURN)
   - STEP 5: `hard_floor_applies()` under-label upgrade

   Corrected ordering (renumber cleanly):
   - STEP 4: `hard_floor_applies()` under-label upgrade (formerly STEP 5)
   - STEP 5: `autonomy_enabled` kill switch (formerly STEP 4)

   Add reorder rationale note: "ADV-F2-P6-002: hard_floor_applies() upgrade must run BEFORE kill
   switch so under-labeled hard-floor + autonomy_enabled=false produces a create-review upgrade
   (STEP 4) rather than a silent kill-switch drop (prior STEP 4 → RETURN)."

   Update EC-012 case (d): "under-labeled (non-review token) + `autonomy_enabled=false` →
   STEP 4 hard-floor upgrade fires FIRST; create-review/comment-review marker issued (or deny if
   project_key absent); kill switch (STEP 5) is only reached for non-hard-floor verdicts."

2. **create-review command_pattern update (ADV-F2-P6-001 CRITICAL).**

   Change the `create-review` row in the command_pattern generation table:
   - Old: `^jr (--output json )?issue create --project <jira_project_key>( |$)`
   - New: `^jr (--output json )?issue create --project <jira_project_key> --label (REVIEW-REQUIRED|BLIND-SPOT)( |$)`

   Update the STEP 3 create-review path to use the new pattern in the generated `pattern` variable.
   Update the STEP 4 under-label upgrade create-review path to use the new pattern.

   Add Iron Law extension: "The monitoring-loop MUST place `--label (REVIEW-REQUIRED|BLIND-SPOT)`
   as the SECOND fixed argument (after `--project <key>`) in every `jr issue create` call for a
   review-path ticket. This is MANDATORY — without the label in the fixed second position, the
   consumer STEP 6a cross-check rejects the marker (EC-023)."

3. **Update STEP 3 Iron Law text (ADV-F2-P6-001).**

   Remove: "Require-review does not enforce label content — that invariant lives in SKILL.md."
   Replace with: "Require-review NOW enforces label content structurally via the command_pattern
   (create-review pattern includes `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed second position)
   AND via consumer STEP 6a cross-check. SKILL.md Iron Law remains as defense-in-depth."

4. **Add ASM-014 note for comment-review.**

   Note: "Structural label check for `comment-review` command patterns (`jr issue comment <id> --label`)
   is pending ASM-014 empirical validation of `jr issue comment --label` support. Current guard:
   ticket_id binding + Iron Law."

---

### 8.14.3 BC-10.01.001 (monitoring-loop) — Pass-6 Required Changes

**Current version: v1.10. Target: v1.11.**

1. **Invariant #11 carve-out (ADV-F2-P6-003 MAJOR).**

   Current Invariant #11: "When `autonomy_enabled` is false, ALL autonomous Jira actions
   (jr issue comment/create/assign) are halted. No carve-out for review markers."

   Replace with: "When `autonomy_enabled` is false, ZERO REGULAR autonomous Jira actions
   (jr issue comment/create/assign for non-review tickets) are executed, and ZERO regular
   markers (authorized_operations `["comment"]`, `["create"]`, `["assign"]`) are consumed.
   EXCEPTION: `create-review` and `comment-review` escalation writes for GENUINE hard-floor
   verdicts (`hard_floor_applies()=TRUE`, verified by disposition-guard STEP 3 and STEP 4 gates)
   STILL execute per D-DEC-012 Option A. The kill switch suppresses ONLY autonomous triage;
   it does NOT suppress human-escalation ticket creation or updates."

2. **VP-SKILL-065 re-scope instruction (ADV-F2-P6-003).**

   Add note: "VP-SKILL-065 assertion 'zero jr create/comment/assign calls under
   autonomy_enabled=false' is overly broad. VP-SKILL-065 must be re-scoped to: 'zero REGULAR
   (non-review) jr create/comment/assign calls under autonomy_enabled=false; create-review and
   comment-review calls for genuine hard-floor verdicts are EXEMPT.' Re-mark VP-SKILL-065 as
   PROPOSED (not FINALIZED) until the re-scoped vector set is verified (see §8.15 item 2)."

3. **Stage 1 severity normalization reference (ADV-F2-P6-005 MAJOR — D-DEC-013).**

   Add to Invariant #9 field 13 definition: "verdict.severity is populated at Stage 1 INGEST via
   NORMALIZE_SEVERITY(native_severity, sensor_family) per D-DEC-013. Mapping table: CrowdStrike
   numeric 1-100; Armis/Claroty risk bands (1:1 case-fold); NVD CVSS float 0.0-10.0;
   Cyberint COMPUTE-AT-VALIDATION (ASM-008). Unrecognized severity → CRITICAL with
   uncertainty_explicit set (conservative, auditable — never silent enum-deny)."

   Add Stage 1 normalization step to Invariant #14 pipeline stage description.

4. **D-DEC-004 alignment (ADV-F2-P6-006 MINOR).**

   Update EC-006 (BLIND-SPOT creation) and EC-014 (REVIEW-REQUIRED creation):
   - EC-006 new BLIND-SPOT ticket: `ticket_action_type = "create-review"` (NOT `"create"`)
   - EC-006 append to existing BLIND-SPOT: `ticket_action_type = "comment-review"` (NOT `"comment"`)
   - EC-014: same pattern as EC-006 for REVIEW-REQUIRED tickets

---

## 8.15 FORMAL-VERIFIER LIST (pass 6 — ADV-F2-P6-001..P6-009)

> **Owner:** Formal verifier. Architect does NOT write VPs. FV owns VP-INDEX.md,
> verification-delta.md, and VP files.

1. **VP-HOOK-029 FINALIZE + expand kill-switch-on-under-label vectors (ADV-F2-P6-002 CRITICAL + P6-010).**

   VP-HOOK-029 is currently PROPOSED/P1. P6-010 identified this as a convergence-blocking risk.
   FV MUST FINALIZE VP-HOOK-029 in this pass (upgrade lifecycle from PROPOSED to FINALIZED).

   New required vectors (ADV-F2-P6-002 — under-label + autonomy_enabled=false vectors):
   ```bats
   @test "VP-HOOK-029: Indeterminate + create (under-label) + autonomy_enabled=false → create-review marker (STEP 4 fires before kill switch)"
   @test "VP-HOOK-029: HIGH severity + comment (under-label) + autonomy_enabled=false → comment-review marker (not silent allow)"
   @test "VP-HOOK-029: Indeterminate + none (under-label) + autonomy_enabled=false + ticket_id present → comment-review marker"
   ```

   Paired mutant SM-32-ext: "revert STEP order — kill switch (STEP 5) before hard-floor (STEP 4)"
   → assert Indeterminate + create + autonomy_enabled=false → NO marker emitted (mutant detectable
   when new vectors see missing create-review marker). The SM-32-ext variant is SEPARATELY killable
   from the existing SM-32 variants (remove STEP 3 gate, remove STEP 4 upgrade).

   Update VP-HOOK-029 lifecycle to FINALIZED in VP-INDEX.md and verification-delta.md. Tag P0.

2. **VP-SKILL-065 re-scope (ADV-F2-P6-003 MAJOR).**

   Current VP-SKILL-065: "zero `jr issue create/comment/assign` calls under `autonomy_enabled=false`."
   Re-scope to: "zero REGULAR (non-review) `jr issue create/comment/assign` calls under
   `autonomy_enabled=false`; `create-review`/`comment-review` calls for genuine hard-floor verdicts
   are EXEMPT per D-DEC-012 Option A."

   Remove FINALIZED status; re-mark as PROPOSED until new vector set is verified. Update VP-INDEX.md.

   New required vectors:
   ```bats
   @test "VP-SKILL-065: autonomy_enabled=false + silent sensor → create-review jr call IS made (BLIND-SPOT ticket — exempt from kill switch)"
   @test "VP-SKILL-065: autonomy_enabled=false + regular non-hard-floor FP verdict → zero jr create/comment/assign (kill switch fires)"
   ```

3. **New VP-SKILL-074 — severity normalization (ADV-F2-P6-005 MAJOR).**

   Proposed verification property: "NORMALIZE_SEVERITY produces only members of {LOW, MEDIUM,
   HIGH, CRITICAL}; unrecognized native values produce CRITICAL with `uncertainty_explicit`
   annotation; each sensor family maps correctly per D-DEC-013 table."

   Proof strategy: property-based test (fast-check/Hypothesis) over:
   - CrowdStrike: integer range 1-100 → assert enum boundaries at 25/50/75
   - NVD/CVSS: float 0.0-10.0 → assert enum boundaries at 4.0/7.0/9.0
   - Armis/Claroty risk bands: assert 1:1 case-fold correctness
   - Unrecognized: assert CRITICAL + uncertainty_explicit non-null

   Tag P1. Add to VP-INDEX.md as PROPOSED.

4. **New VP-SKILL-073 — late-event detection (ADV-F2-P6-007 MINOR).**

   Proposed verification property: "when an ingested event's `_time` is older than
   `watermark - WATERMARK_GRACE_SECONDS`, `DETECT_LATE_EVENT()` emits an auditable log entry
   to `watermarks/audit.log`; the event is NOT dropped but processed normally."

   Proof strategy: BATS integration test — inject event with `_time < effective_start`; assert
   `LATE_EVENT_DETECTED` entry present in `watermarks/audit.log`; assert event proceeds to VALIDATE
   stage (not silently discarded).

   Tag P1. Add to VP-INDEX.md as PROPOSED.

5. **Consumer anti-fungibility mutants SM-36 and SM-37 (ADV-F2-P6-001 CRITICAL).**

   New BATS vectors for consumer STEP 6a:
   ```bats
   @test "VP-HOOK-024/P6-001: create-review marker + jr issue create without --label → DENY (EC-023 anti-fungibility)"
   @test "VP-HOOK-024/P6-001: create marker + jr issue create --label REVIEW-REQUIRED → DENY (EC-023 anti-fungibility)"
   ```

   Mutant SM-36: "remove consumer STEP 6a cross-check" → assert create-review marker IS consumed
   by a non-review-labeled create command (mutant dies when P6-001 test detects unauthorized allow).

   Mutant SM-37: "remove consumer STEP 6a check for create marker + review label" → assert create
   marker IS consumed by a review-labeled create command (complement direction).

   Add SM-36 and SM-37 to verification-delta.md mutant catalog and VP-INDEX.md.

*Pass-6 PO PROPAGATION LIST (§8.14) and formal-verifier list (§8.15) complete. Architect does
NOT edit BCs, verification-delta, prd-delta, or STATE.md. v1.9 is final for pass-6
adversarial remediation.*

---

## 8.16 PO PROPAGATION LIST (pass 7 — ADV-F2-P7-001..P7-009)

> **Owner:** Product-owner (PO). Architect does NOT edit BCs, verification-delta, prd-delta, or STATE.md.
>
> **Live BC version map (frozen pass-7 baseline):** BC-3.01.001 v1.18, BC-3.03.001 v1.15, BC-10.01.001 v1.11.
>
> **Scope:** Three BCs require changes. Apply BC-3.03.001 (emitter) FIRST to establish the
> new STEP 4 deny semantics, then BC-10.01.001 (loop) to propagate the re-document obligation,
> then BC-3.01.001 (consumer) to fix the structural check.

---

### 8.16.1 BC-3.03.001 (disposition-guard) — Pass-7 Required Changes

**Current version: v1.15. Target: v1.16.**

1. **STEP 4 redesign — DENY-THE-WRITE (P7-001 CRITICAL).**

   Remove the entire UNDER-LABEL-CORRECTED upgrade tree from Invariant #4 STEP 4. Replace with
   the deny-the-Write logic:

   When `hard_floor_applies(verdict)` AND action NOT in {create-review, comment-review}:
   - Compute `required_token`: create-review if `verdict.ticket_id` is null; comment-review if present
   - Compute `hard_floor_trigger`: which hard-floor condition fired
   - Write `UNDER-LABEL-DENIED` audit entry (UNDER-LABEL-CORRECTED is RETIRED)
   - `emit deny()` with structured corrective reason:
     `hard_floor_trigger=<val>; required_token=<val>; <label_instruction>; re-issue Write with ticket_action_type=<required_token>`
   - `RETURN` — do NOT GOTO WRITE_MARKER; do NOT issue any marker

   Add to Invariant #4 normative note:
   > "The loop MUST re-issue the verdict Write with `ticket_action_type` set to `required_token`.
   > The deny reason is machine-readable. On the corrected Write, STEP 3 issues the review marker.
   > Non-termination: if the loop never re-documents, the deny + UNDER-LABEL-DENIED audit entry
   > are the loud fail-closed outcome. No silent discard occurs."

2. **Update EC-012 case (d) semantics (P7-001 consequence).**

   Change from: "under-labeled hard-floor + autonomy_enabled=false → STEP 4 upgrade fires FIRST;
   resulting create-review/comment-review marker issued."

   To: "under-labeled hard-floor + autonomy_enabled=false → STEP 4 DENY-THE-WRITE fires FIRST;
   verdict Write denied with corrective reason and UNDER-LABEL-DENIED audit entry; loop re-documents
   with required_token; STEP 3 issues review marker on corrected Write; kill switch (STEP 5) is
   only reached for non-hard-floor verdicts."

3. **BATS test name updates (P7-001 consequence).**

   Any test asserting "UNDER-LABEL upgrade to create-review/comment-review" must be updated:
   - Old: `Indeterminate + create action → UNDER-LABEL upgrade to create-review`
   - New: `Indeterminate + create action → verdict Write DENIED; required_token=create-review in deny reason; UNDER-LABEL-DENIED in audit.log`
   Add a new test: `hard-floor verdict + corrected Write (create-review) → STEP 3 issues review marker (re-document path)`.
   Remove any UNDER-LABEL-CORRECTED test — that audit code is retired.

---

### 8.16.2 BC-3.01.001 (require-review) — Pass-7 Required Changes

**Current version: v1.18. Target: v1.19.**

1. **Consumer step-6a structural has_review_label check (P7-005 MINOR).**

   Current (defective):
   ```
   has_review_label = ("--label REVIEW-REQUIRED" in command) OR ("--label BLIND-SPOT" in command)
   ```
   This is a raw substring check over the full command string, including attacker/LLM-influenceable
   `--summary` text. A command such as:
   `jr issue create --project KEY --summary "rule --label REVIEW-REQUIRED fired in payload"`
   sets `has_review_label=true` against a `["create"]` marker → false-deny of a legitimate create.

   Replace with structural token detection:
   ```
   # structural_label_check(cmd): split cmd on whitespace → token array
   #   for i in range(len(tokens) - 1):
   #     if tokens[i] == "--label" AND tokens[i+1] in {"REVIEW-REQUIRED", "BLIND-SPOT"}:
   #       return True
   #   return False
   has_review_label = structural_label_check(command)
   ```
   A `--summary` argument value containing the label string is a single-token or quoted sequence;
   it does NOT produce a standalone `--label` token in the token array. The structural check is
   immune to injection of label text inside argument values.

   Add EC for this case: "EC-024: false-deny prevention — a regular create command whose
   `--summary` text contains the literal string `--label REVIEW-REQUIRED` or `--label BLIND-SPOT`
   is ALLOWED (structural check: `--label` is not a standalone flag token in this command)."

   Add BATS vector:
   ```bats
   @test "require-review: regular create with --summary containing literal '--label REVIEW-REQUIRED' → ALLOW (P7-005 structural check)"
   ```

---

### 8.16.3 BC-10.01.001 (monitoring-loop) — Pass-7 Required Changes

**Current version: v1.11. Target: v1.12.**

1. **Six stale locations — post-D-DEC-012 semantics (P7-002 CRITICAL).**

   The following six locations still encode pre-D-DEC-012 "no marker" semantics and directly
   contradict the current Invariant #10 fail-loud requirement. All must be updated:

   - **EC-015 (HIGH/CRITICAL severity):** Change "route to human unconditionally; no marker issued
     regardless of autonomy_enabled" → "ticket_action_type = create-review (no open ticket) or
     comment-review (open ticket); disposition-guard STEP 3 issues restricted review marker (exempt
     from kill switch); marker directory MUST NOT be empty after STEP 3 processes the corrected Write."
   - **EC-016 (T1003 technique):** Change "route to human; no marker; propose-only annotation" →
     "ticket_action_type = create-review or comment-review; restricted review marker emitted; loop
     includes T1003 in uncertainty_explicit annotation."
   - **EC-017 (degraded sensor / Indeterminate-due-to-missing-telemetry):** Change "Force verdict to
     Indeterminate; no marker; [REVIEW-REQUIRED] flag" → "ticket_action_type = create-review or
     comment-review; restricted review marker emitted; jr issue create/comment with --label REVIEW-REQUIRED
     is authorized and consumable."
   - **EC-021 (LOW + unknown asset):** Change "route to human unconditionally; no marker issued
     regardless of autonomy_enabled" → "ticket_action_type = create-review or comment-review;
     restricted review marker emitted."
   - **Test vector (HIGH severity, line ~463):** Change "no marker issued; [REVIEW-REQUIRED] or
     escalation draft created" → "create-review marker emitted; jr issue create --project KEY
     --label REVIEW-REQUIRED authorized by STEP 3; marker directory non-empty."
   - **Test vector (Indeterminate verdict, line ~466):** Change "no marker; loop does NOT auto-close"
     → "create-review or comment-review marker emitted; loop does NOT auto-close; REVIEW-REQUIRED
     ticket creation authorized; loop re-documented with correct review token."

   **Add negative assertion** to Invariant #10 and EC-006:
   > "A hard-floor or Indeterminate verdict MUST NOT leave the marker directory empty after
   > disposition-guard STEP 3 processes the corrected review-token Write. An empty marker dir
   > after Stage 7 DOCUMENT for a hard-floor verdict is a conformance defect."

2. **Loop-contract Iron Law for review path (P7-003 MAJOR).**

   Add explicitly to Stage-8 pipeline description, Invariant #10, and the jira_project_key
   operational-metadata note:

   > "**Iron Law (P7-003):** Every review-path `jr issue create` call from the monitoring-loop
   > MUST be constructed as:
   > `jr [--output json] issue create --project ${JIRA_PROJECT_KEY} --label (REVIEW-REQUIRED|BLIND-SPOT) ...`
   > with `--project` FIRST and `--label (REVIEW-REQUIRED|BLIND-SPOT)` SECOND (no flags interposed).
   > The comment-review path uses:
   > `jr [--output json] issue comment <ticket_id> ...`
   > Mis-ordered label placement (e.g., `--label` after `--summary`) fails the consumer STEP 6a
   > pattern match and is DENIED. The emitter's create-review command_pattern structurally enforces
   > this; the loop must not rely solely on the pattern — the Iron Law is the loop's own obligation."

   Add BATS vector reference:
   ```bats
   @test "require-review: create-review marker + jr create with --label after --summary → DENY (P7-003 mis-ordered Iron Law)"
   ```

3. **Loop re-document obligation on STEP-4 deny (P7-001 consequence).**

   Add to Invariant #10 (or the STEP-4 safety-net note):
   > "When disposition-guard STEP 4 denies the verdict Write with a HARD-FLOOR-UNDER-LABEL deny
   > reason: the loop MUST re-issue the verdict Write with `ticket_action_type` set to the
   > `required_token` field from the deny reason (`create-review` or `comment-review`). The deny
   > reason is machine-readable. On the corrected Write, STEP 3 issues the review marker. A loop
   > that ignores STEP-4 deny reasons silently fails to surface hard-floor findings — a conformance
   > defect detectable by VP-HOOK-029's consumer-boundary assertion."

4. **Brief §3.9 amendment version-pin refresh (P7-007 MINOR).**

   The current brief §3.9 amendment cites stale BC versions (BC-3.03.001 v1.14, BC-10.01.001 v1.10)
   and the pre-reorder "STEP 3" citation. Recommend updating the brief §3.9 amendment to:
   - Use non-pinned version references ("current BC versions") rather than pinned version numbers
   - Note the STEP 3 (correct-label / genuinely hard-floor review path) / STEP 4 (deny-the-Write
     for under-labeled hard-floor verdicts) split so readers understand where each guarantee lives
   This prevents this staleness class from recurring across future passes.

5. **Cyberint conservative pre-ASM-008 mapping (P7-006 MINOR — propagate from D-DEC-013).**

   Update Invariant #9 field 13 severity normalization note (added at §8.14 item 3) to reflect the
   explicit Cyberint default from D-DEC-013:
   > "Cyberint: default CRITICAL + `uncertainty_explicit` naming the unvalidated mapping:
   > 'Cyberint severity mapping unvalidated per ASM-008; conservative CRITICAL applied until
   > validated.' NOT ambiguous COMPUTE-AT-VALIDATION — this produces an enum-valid, auditable
   > CRITICAL from first contact with any Cyberint severity value."
   Add a note to the VP-SKILL-074 obligations comment: VP-SKILL-074 must include a Cyberint-conservative
   partition (see §8.17 item 2 for FV instructions).

---

## 8.17 FORMAL-VERIFIER LIST (pass 7 — ADV-F2-P7-001..P7-009)

> **Owner:** Formal verifier. Architect does NOT write VPs.
>
> **IMPORTANT — ID collision prevention (Lesson 8):** Do NOT mint new VP/SM IDs without occupancy
> verification. VP-SKILL-072 and SM-33/SM-34 collided in pass 6. Before allocating any new ID,
> run `grep -r "VP-SKILL-0<next>" .factory/` and `grep -r "SM-<next>" .factory/` to confirm vacancy.

---

1. **VP-HOOK-029 end-to-end consumer-boundary re-scope (P7-004 MAJOR + P7-001 consequence).**

   VP-HOOK-029 is currently FINALIZED with an emitter-side assertion (marker exists OR error artifact).
   P7-001 proved this is insufficient: the upgrade marker was present but unconsumable. The property
   must assert the CONSUMER-OBSERVABLE outcome per the O4 standing rule.

   **New VP-HOOK-029 assertion (replace existing):**
   For a hard-floor verdict with ANY `ticket_action_type`:
   - **(a) review token (create-review/comment-review):** restricted marker emitted at STEP 3 AND
     a correctly-labeled jr write is authorized and consumable at consumer STEP 6a; NEVER an
     unconsumable marker (wrong command type, missing label).
   - **(b) non-review token (including none):** verdict Write DENIED with corrective reason +
     UNDER-LABEL-DENIED audit entry; NEVER a silent allow; NEVER a marker in the store for the
     denied Write; on loop re-document (corrected Write), path (a) fires.

   **New required BATS vectors (deny path — retire the old upgrade-marker vectors listed below):**
   ```bats
   @test "VP-HOOK-029 deny-path: Indeterminate + ticket_action_type=create → verdict Write DENIED (not allowed)"
   @test "VP-HOOK-029 deny-path: HIGH severity + ticket_action_type=none → verdict Write DENIED"
   @test "VP-HOOK-029 deny-path: degraded sensor + ticket_action_type=assign → UNDER-LABEL-DENIED in audit.log"
   @test "VP-HOOK-029 deny-path: Indeterminate + ticket_action_type=none + ticket_id present → required_token=comment-review in deny reason"
   @test "VP-HOOK-029 re-doc path: corrected Write (ticket_action_type=create-review after STEP-4 deny) → STEP 3 creates-review marker in store"
   @test "VP-HOOK-029 consumer-boundary: create-review marker + correctly-labeled jr create --label REVIEW-REQUIRED → ALLOW (consumable)"
   @test "VP-HOOK-029 consumer-boundary: create-review marker + jr create without --label → DENY (unconsumable marker prevented)"
   ```

   **RETIRE the following vectors** (they tested the now-removed upgrade marker path):
   - `"VP-HOOK-029: Indeterminate + ticket_action_type=create (under-label) → create-review marker in store"` (from §8.13 item 1)
   - `"VP-HOOK-029: HIGH severity + ticket_action_type=comment (under-label) → comment-review marker in store"` (from §8.13 item 1)
   - `"VP-HOOK-029: Indeterminate + ticket_action_type=none + ticket_id present → comment-review marker in store"` (from §8.13 item 1)
   - `"VP-HOOK-029: Indeterminate + ticket_action_type=create + project_key absent → deny + FAIL-LOUD in audit.log"` (from §8.13 item 1 — deny still fires but reason structure changed; replace with new deny-path vector above)
   - The kill-switch+under-label vectors from §8.15 item 1 that asserted marker-in-store: retire and replace with deny-path vectors above.

   **New mutants for the deny path** (allocate IDs with occupancy verification before assigning):
   - SM-NEW-A: "revert STEP 4 to silent emit-allow-without-marker (remove deny entirely)" → assert under-labeled hard-floor verdict produces no denial and no audit entry (mutant dies when deny-path test detects no deny was emitted)
   - SM-NEW-B: "revert STEP 4 deny to GOTO WRITE_MARKER (the P5-001/P6-002 upgrade)" → assert under-labeled hard-floor verdict produces a marker IN-STORE without a corrected Write having been issued (mutant dies when consumer-boundary test verifies no marker exists for the original denied Write)
   Both are SEPARATELY killable from existing SM-32 variants.

   Re-mark VP-HOOK-029 lifecycle to PROPOSED until new vectors are implemented and consumer-boundary
   assertion verified; then re-FINALIZE. Tag P0. Update VP-INDEX.md and verification-delta.md.

2. **VP-SKILL-074 Cyberint partition (P7-006 MINOR).**

   VP-SKILL-074 (severity normalization) must add a Cyberint-specific partition (allocate sub-test
   or extend existing VP scope — verify no ID collision before creating a new ID):
   ```bats
   @test "VP-SKILL-074 Cyberint: any Cyberint native severity value → normalized to CRITICAL (pre-ASM-008 conservative default)"
   @test "VP-SKILL-074 Cyberint: Cyberint severity does NOT produce LOW/MEDIUM/HIGH until ASM-008 resolves"
   @test "VP-SKILL-074 Cyberint: CRITICAL output includes uncertainty_explicit naming the unvalidated mapping"
   ```
   These tests are intentionally strict. They will require updating when ASM-008 resolves and the
   real Cyberint per-band mapping is specified. Add an explicit note to the VP: "These assertions
   are pre-ASM-008 invariants; update when ASM-008 delivers validated Cyberint severity bands."

3. **Consumer step-6a false-deny prevention vector (P7-005 MINOR).**

   Add BATS vector (assign to VP-HOOK-024 or as a new property — verify occupancy):
   ```bats
   @test "VP-HOOK-024/P7-005: regular create + create marker + --summary contains '--label REVIEW-REQUIRED' → ALLOW (structural token check; not a false-deny)"
   ```
   Paired mutant (verify ID occupancy before allocating): "revert has_review_label to raw substring
   check" → assert the above vector produces a DENY (mutant dies when structural token check correctly
   allows the legitimate create). Add to mutant catalog with occupancy verification.

*Pass-7 PO PROPAGATION LIST (§8.16) and formal-verifier list (§8.17) complete. Architect does
NOT edit BCs, verification-delta, prd-delta, or STATE.md. v1.10 is final for pass-7
adversarial remediation.*

---

## 8.18 PO PROPAGATION LIST (pass 8 — P8-001..P8-004 + OBS)

> **Owner:** Product-owner (PO). Architect does NOT edit BCs, verification-delta, prd-delta, or STATE.md.
>
> **Live BC version map (frozen pass-8 baseline):** BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12.
>
> **Application order:** BC-3.03.001 (emitter STEP 3 deny branches) → BC-3.01.001 (quote-aware tokenizer + EC-023/024) → BC-10.01.001 (VP-Anchors footer + Cyberint operator note) → BC-8.02.001 (Cyberint operator note) → prd-delta (P8-004 full refresh).

---

### 8.18.1 BC-3.03.001 (disposition-guard) — Pass-8 Required Changes

**Current version: v1.16. Target: v1.17.**

1. **STEP 3 create-review branch — DENY-THE-WRITE on null jira_project_key (P8-001 CRITICAL).**

   Replace the create-review null-project_key branch:

   Current (defective):
   ```
   IF project_key is null OR project_key == "":
     emit allow without marker  # cannot bind create-review without project key
     RETURN
   ```

   Replace with:
   ```
   IF project_key is null OR project_key == "":
     WRITE audit entry: "HARD-FLOOR-UNBINDABLE: ... missing_field=jira_project_key ..."
     emit deny("HARD-FLOOR-UNBINDABLE: cannot bind create-review marker without jira_project_key. ...")
     RETURN
   ```
   Full pseudocode: see architecture-delta.md §D-DEC-008 STEP 3 (v1.11 update).

   Add normative note: "D-DEC-012 clause 2 mandates explicit error artifact + deny when a hard-floor
   finding cannot be surfaced. Non-termination: if the loop re-documents and still omits
   jira_project_key, deny fires again — one HARD-FLOOR-UNBINDABLE per attempt; no Jira write;
   bounded fail-closed. Mirrors STEP 4 non-termination analysis."

2. **STEP 3 comment-review branch — DENY-THE-WRITE on null ticket_id (P8-001 CRITICAL).**

   Replace the comment-review null-ticket_id branch:

   Current (defective):
   ```
   IF ticket_id is null:
     emit allow without marker  # cannot bind comment-review without ticket_id
     RETURN
   ```

   Replace with deny + fallback hint:
   - If jira_project_key is also absent: deny naming both missing fields.
   - If jira_project_key IS present: deny with fallback hint suggesting create-review
     (consistent with STEP 4 required_token logic: ticket_id=null → required_token=create-review).

   Full pseudocode: see architecture-delta.md §D-DEC-008 STEP 3 (v1.11 update).

3. **BATS test vectors for the new deny branches (P8-001).**

   ```bats
   @test "disposition-guard STEP3: Indeterminate + create-review + null jira_project_key → verdict Write DENIED; HARD-FLOOR-UNBINDABLE in audit.log (P8-001)"
   @test "disposition-guard STEP3: CRITICAL severity + create-review + null jira_project_key → deny reason contains missing_field=jira_project_key (P8-001)"
   @test "disposition-guard STEP3: silent sensor + comment-review + null ticket_id + null jira_project_key → DENIED; both fields absent noted in reason (P8-001)"
   @test "disposition-guard STEP3: Indeterminate + comment-review + null ticket_id + project_key=PRISM-DEMO → DENIED; fallback hint suggests create-review (P8-001)"
   @test "disposition-guard STEP3: re-doc that still omits project_key → second HARD-FLOOR-UNBINDABLE audit entry; still no Jira write (P8-001 bounded non-termination)"
   @test "disposition-guard STEP3: Indeterminate + create-review + project_key=PRISM-DEMO → review marker emitted normally (P8-001 happy path unbroken)"
   ```

---

### 8.18.2 BC-3.01.001 (require-review) — Pass-8 Required Changes

**Current version: v1.19. Target: v1.20.**

1. **structural_label_check — replace split_on_whitespace with quote-aware tokenizer (P8-002 MAJOR).**

   Current consumer algorithm step (6a) uses `split_on_whitespace` (P7-005 fix was insufficient):
   the hook receives `tool_input.command` as a RAW string (`jq -r`; literal quote chars present;
   shell NOT expanded). A naive whitespace split of `jr issue create --project KEY --summary "rule --label REVIEW-REQUIRED fired"` yields `--label` as a standalone token → has_review_label=true → false-deny STILL FIRES.

   Replace with the quote-aware state-machine tokenizer (UNQUOTED/IN_SINGLE/IN_DOUBLE states):
   tokens inside quoted regions are NOT split; a `--label` token inside a quoted `--summary`
   value is part of the --summary token body, not a standalone flag.

   Full tokenizer pseudocode: see architecture-delta.md §D-DEC-001 STEP 6a (v1.11 P8-002 update).

2. **EC-024 correction — reconcile to quote-aware semantics (P8-002 MAJOR).**

   Remove any text in EC-024 claiming the hook sees post-shell-expansion arguments or that
   `--summary` quoting "in practice" collapses values. Replace with:

   > "EC-024: false-deny prevention — a regular create command whose `--summary` value contains
   > the literal text `--label REVIEW-REQUIRED` or `--label BLIND-SPOT` as a QUOTED argument
   > (e.g., `jr issue create --project KEY --summary "rule --label REVIEW-REQUIRED fired"`)
   > results in `has_review_label=false`. The quote-aware tokenizer treats the quoted value as a
   > single token; `--label` inside the quoted region is NOT a standalone flag. Outcome:
   > `["create"]` marker consumed → ALLOW."

3. **EC-023 direction A correction — ( |$) is not tail-anchored (P8-003 MINOR).**

   If EC-023 direction (A) contains text asserting that the regular create pattern's `( |$)` anchor
   rejects a review-labeled create at consumer step 5 — remove or correct that assertion:

   > "The regular create pattern `^jr (--output json )?issue create --project KEY( |$)` is NOT
   > tail-anchored. A command `jr issue create --project KEY --label REVIEW-REQUIRED ...` passes
   > step 5 (the regex matches the prefix). `( |$)` guards ONLY against project-KEY prefix
   > extension (P4-002 purpose). Anti-fungibility direction A is enforced EXCLUSIVELY at step 6a
   > via `structural_label_check`. Step 6a is the single point of failure for this invariant."

   Add BATS vector:
   ```bats
   @test "require-review: regular create + create marker + --summary quoted literal '--label REVIEW-REQUIRED' → ALLOW (P8-002 quote-aware tokenizer; EC-024)"
   ```

---

### 8.18.3 BC-10.01.001 (monitoring-loop) — Pass-8 Required Changes

**Current version: v1.12. Target: v1.13.**

1. **VP-Anchors footer — VP-HOOK-029 status correction (P8-004 MAJOR — blast radius sibling).**

   The VP-Anchors footer in BC-10.01.001 (line ~534) still reads approximately:
   "VP-HOOK-029 (... P1 PROPOSED — FINALIZED strategy v1.9)."

   Correct to reflect re-FINALIZED status per verification-delta v1.10 and §8.17 item 1:
   > "VP-HOOK-029: FINALIZED P0 (re-FINALIZED at verification-delta v1.10; consumer-boundary
   > assertion per O4 standing rule; deny-path vectors + re-doc path + unbindable-deny vectors
   > active per P8-001)."

2. **Cyberint operator expectation note (P8-OBS-2).**

   Add to the D-DEC-013 severity normalization note in Invariant #9 field 13 or Invariant #14:
   > "Pre-ASM-008 operator expectation (Cyberint): all Cyberint severity values normalize to
   > CRITICAL (conservative default per D-DEC-013). 100% of Cyberint traffic routes through the
   > review escalation path (create-review/comment-review). Review queues will be flooded with
   > REVIEW-REQUIRED tickets from Cyberint alerts until ASM-008 validates actual severity bands.
   > This is expected behavior, not a defect."

---

### 8.18.4 BC-8.02.001 (sensor-metrics) — Pass-8 Required Changes

**Current version: see live frontmatter. Target: bump one minor version.**

1. **Cyberint operator expectation note (P8-OBS-2).**

   Add operator note to the operational expectations section (or create one if absent):
   > "Pre-ASM-008 Cyberint: conservative CRITICAL normalization (D-DEC-013) → 100% review
   > escalation → REVIEW-REQUIRED ticket flood in org-b (if Cyberint-connected) until ASM-008
   > resolves. Expected behavior. See BC-10.01.001 for full context."

---

### 8.18.5 prd-delta — Pass-8 Required Changes (P8-004 MAJOR)

**Current version: v1.9. Target: v1.10.**

1. **§1 VP roster — correct inverted statuses (P8-004 MAJOR).**

   Current (wrong):
   - VP-HOOK-029: `P1 PROPOSED`
   - VP-SKILL-065: `FINALIZED`

   Correct to:
   - VP-HOOK-029: `FINALIZED P0` (re-FINALIZED at verification-delta v1.10 per §8.17 item 1; consumer-boundary assertion + deny-path vectors; P8-001 unbindable-deny vectors being added)
   - VP-SKILL-065: `PROPOSED (re-scoped — ADV-F2-P6-003 MAJOR)` (re-scoped carve-out for create-review/comment-review kill-switch exemption; BC-10.01.001 v1.11+ and verification-delta v1.9+ carry PROPOSED; kill-switch carve-out assertion pending re-verification)

2. **§5 "New Version" column — catch-up to live BC versions (P8-004 MAJOR).**

   prd-delta §5 currently shows versions frozen at pass-5. Update all three rows:

   | BC | prd-delta stale value | Correct target (after this burst) |
   |----|----------------------|----------------------------------|
   | BC-3.01.001 | `→ v1.17` | `→ v1.20` |
   | BC-3.03.001 | `→ v1.13` | `→ v1.17` |
   | BC-10.01.001 | `→ v1.9` | `→ v1.13` |

   Add pass-5/6/7/8 change summaries for each BC in the §5 annotation column.

3. **Changelog catch-up (passes 6–8).**

   prd-delta changelog stops at v1.9 "Pass-5 (P5-004)". Add entries summarizing:
   - Pass-6 changes: BC-3.01.001 step-6a anti-fungibility; BC-3.03.001 STEP reorder + review pattern; BC-10.01.001 Inv#11 carve-out + VP-SKILL-065 re-scope + severity normalization
   - Pass-7 changes: BC-3.03.001 DENY-THE-WRITE; BC-3.01.001 structural token fix (P7-005, now P8-002 quote-aware); BC-10.01.001 six stale locations + Iron Law + re-document obligation
   - Pass-8 changes: STEP 3 deny branches; quote-aware tokenizer; EC-023/024 corrections; Cyberint notes; VP roster corrections

*Pass-8 PO PROPAGATION LIST (§8.18) complete. Architect does NOT edit BCs, verification-delta,
prd-delta, or STATE.md.*

---

## 8.19 FORMAL-VERIFIER LIST (pass 8 — P8-001..P8-004 + OBS)

> **Owner:** Formal verifier. Architect does NOT write VPs. FV owns VP-INDEX.md,
> verification-delta.md, and VP files.
>
> **IMPORTANT — ID collision prevention:** Do NOT mint new VP/SM IDs without occupancy
> verification. Run `grep -r "VP-HOOK-0<next>" .factory/` and `grep -r "SM-<next>" .factory/`
> before allocating any new ID.

---

1. **VP-HOOK-029 — add unbindable-deny vectors (P8-001 CRITICAL; additive to §8.17 item 1 vectors).**

   VP-HOOK-029 is FINALIZED P0 per verification-delta v1.10. Add the following new deny-path
   vectors covering the STEP 3 missing-binding sub-case. These are additive — do NOT retire
   existing deny-path vectors from §8.17 item 1.

   ```bats
   @test "VP-HOOK-029 unbindable-deny: Indeterminate + create-review + null jira_project_key → verdict Write DENIED; HARD-FLOOR-UNBINDABLE in audit.log; NEVER silent allow-without-marker (P8-001)"
   @test "VP-HOOK-029 unbindable-deny: silent sensor + comment-review + null ticket_id → verdict Write DENIED; HARD-FLOOR-UNBINDABLE; no marker in store; no Jira write (P8-001)"
   @test "VP-HOOK-029 unbindable-deny: hard-floor + review token + null binding → deny + audit entry on re-doc that still omits binding field (P8-001 bounded non-termination)"
   @test "VP-HOOK-029 review-token + null binding → NEVER silent allow-without-marker (P8-001 D-DEC-012 clause 2 invariant)"
   ```

   New mutant (allocate ID with occupancy verification — do NOT use without `grep -r "SM-P8" .factory/` check):
   - SM-P8-A (allocate after check): "revert STEP 3 create-review null-project_key branch to
     emit-allow-without-marker (pre-P8-001 defective behavior)" → assert Indeterminate + create-review
     + null project_key produces no deny and no HARD-FLOOR-UNBINDABLE in audit (mutant dies when
     P8-001 test detects missing deny). SEPARATELY killable from SM-NEW-A (which tests STEP 4 revert).

   Re-mark VP-HOOK-029 as FINALIZED P0 with the extended vector set after BATS implementation.
   Update VP-INDEX.md total counts and per-VP vector list.

2. **VP-HOOK-024 (or assigned VP) — quote-aware false-deny prevention (P8-002 MAJOR).**

   Add to the VP handling consumer anti-fungibility (VP-HOOK-024 or whichever VP owns step-6a
   — verify occupancy before extending or minting):

   ```bats
   @test "VP-HOOK-024/P8-002: regular create + create marker + --summary contains quoted '--label REVIEW-REQUIRED' literal → ALLOW (quote-aware tokenizer; no false-deny)"
   ```

   New mutant (allocate ID with occupancy verification):
   - SM-P8-B (allocate after check): "revert structural_label_check to non-quote-aware
     split_on_whitespace" → assert the quoted-summary command above produces DENY (mutant dies
     when quote-aware tokenizer correctly produces ALLOW). SEPARATELY killable from the existing
     P7-005 structural-vs-raw-substring mutant.

3. **EC-023 step-5 backstop correction (P8-003 MINOR) — no new VP required.**

   If VP-HOOK-024, VP-HOOK-029, or any other VP currently asserts that the regular create
   pattern rejects a review-labeled create at consumer step 5 (the false `( |$)` tail-anchor
   claim): remove or correct that assertion. The correct invariant is: step 5 pattern match
   PASSES for `jr issue create --project KEY --label REVIEW-REQUIRED ...` with the regular
   create pattern; anti-fungibility direction A is enforced at step 6a only.

   If any BATS test asserts a step-5 DENY for this input with a regular create marker:
   correct the expected result to ALLOW (before step 6a applies EC-023 direction B correctly
   denies the create marker for the review-labeled command).

*Pass-8 PO PROPAGATION LIST (§8.18) and formal-verifier list (§8.19) complete. Architect does
NOT edit BCs, verification-delta, prd-delta, or STATE.md. v1.11 is final for pass-8
adversarial remediation.*

---

## 8.20 PO PROPAGATION LIST (pass 9 — P9-001/005/007/008/009)

> **Owner:** Product-owner (PO). Architect does NOT edit BCs, verification-delta, prd-delta, or STATE.md.
>
> **Live BC version map (frozen pass-9 baseline):** BC-3.01.001 v1.20, BC-3.03.001 v1.17,
> BC-6.01.001 v1.5, BC-8.02.001 (see live frontmatter), BC-10.01.001 v1.13.
>
> **Application order:** BC-3.01.001 (tokenizer extension) → BC-8.02.001 (D-DEC-005 sensor-health
> carve-out) → BC-10.01.001 (dedup-before-create-review + re-doc cap + D-DEC-005 Inv#1 scope
> narrowing) → BC-6.01.001 (jira_project_key Stage-0 precondition) → prd-delta (process items).

---

### 8.20.1 BC-3.01.001 (require-review / consumer) — Pass-9 Required Changes

**Current version: v1.20. Target: v1.21.**

1. **structural_label_check — extend to handle backslash-escaped quotes (P9-001 MAJOR).**

   The P8-002 quote-aware tokenizer (v1.20) still diverges from bash for two input classes:
   - `\"` inside IN_DOUBLE: current tokenizer exits IN_DOUBLE (wrong). Attack vector: a command
     whose `--summary` value ends with `\"` causes the tokenizer to prematurely exit double-quote
     context, making subsequent `--label REVIEW-REQUIRED` appear as standalone tokens when bash
     would keep them inside the quoted region. The buggy tokenizer HIDES a real label from
     detection (has_review_label=FALSE) → security bypass.
   - `\'` in UNQUOTED: current tokenizer enters IN_SINGLE (wrong). Bash: `\'` is a literal `'`
     with no state change.

   Replace the P8-002 tokenizer with the v2 index-based tokenizer (UNQUOTED/IN_SINGLE/IN_DOUBLE
   states + backslash-escape handling):
   - In UNQUOTED: if `char == '\\'` and next char exists → consume both chars; add next_char
     literally to cur_token; NO state toggle.
   - In IN_DOUBLE: if `char == '\\'` and next char is `"` or `\\` → consume both; add escaped
     char to cur_token; STAY IN_DOUBLE. Other `\X` in IN_DOUBLE: backslash is literal (next char
     processed on next iteration).
   - IN_SINGLE: unchanged (no escaping in bash single-quotes; backslash is always literal).

   Full pseudocode: see architecture-delta.md §D-DEC-001 STEP 6a (v1.12 P9-001 update).

   Add note: "jr --label=VALUE equals form is NOT supported by jr CLI (confirmed 2026-07-21);
   only `--label VALUE` space-separated form is emitted. Equals-form vector scoped out."

2. **BATS test vectors for escaped-quote tokenization (P9-001 MAJOR).**

   Add to the VP owning structural_label_check (VP-HOOK-024 or VP-HOOK-029 — verify occupancy):
   ```bats
   @test "P9-001 escaped-quote-hiding-label: create + create marker + summary contains escaped-quote boundary + real --label REVIEW-REQUIRED after it → DENY (escaped-quote fix correctly detects label)"
   @test "P9-001 escaped-quote-inside-summary: create + create marker + summary value contains \\\" but --label is genuinely inside double-quoted summary → ALLOW (false-deny prevention)"
   ```
   These are the differential-vs-bash partition 1 vectors (see §8.21 FV list below).

---

### 8.20.2 BC-8.02.001 (sensor-metrics) — Pass-9 Required Changes

**Current version: see live frontmatter. Target: bump one minor version.**

1. **D-DEC-005 sensor-health carve-out — reflect in postconditions (P9-005 MINOR).**

   BC-8.02.001 postconditions must NOT require org_slug on `prism_sensor_health` queries.
   Update or add a normative note:

   > "SENSOR-HEALTH CARVE-OUT (D-DEC-005 / architecture-delta v1.12): `SELECT * FROM
   > prism_sensor_health` is explicitly exempt from the per-tenant org_slug isolation rule.
   > prism_sensor_health contains MSSP operational health metadata (last-seen, row counts,
   > error rates), not raw per-tenant security event data. The cross-org query shape is
   > intentional (per handoff brief §2.4). Scope of carve-out: limited to prism_sensor_health;
   > all other sensor tables require explicit org_slug filtering per D-DEC-005 / BC-10.01.001 Inv#1."

---

### 8.20.3 BC-10.01.001 (monitoring-loop) — Pass-9 Required Changes

**Current version: v1.13. Target: v1.14.**

1. **Invariant #1 — narrow org_slug isolation rule to raw security event tables (P9-005 MINOR).**

   Current Inv#1 is an absolute rule: "ALL PrismQL queries MUST include org_slug." Narrow to:

   > "All PrismQL queries that retrieve raw per-tenant security event data (crowdstrike_detections,
   > armis_alerts, claroty_events, cyberint_alerts, and any other sensor-data tables) MUST include
   > an explicit org_slug scope constraint. EXCEPTION: prism_sensor_health metadata queries are
   > exempt (D-DEC-005 carve-out; architecture-delta v1.12 P9-005)."

2. **STEP 3 comment-review fallback — require dedup before create-review switch (P9-007 MINOR).**

   The current fallback hint (when comment-review arrives with null ticket_id but valid
   jira_project_key) says: "if no review ticket exists yet, re-issue as create-review."

   Update to make the dedup gate explicit:

   > "Null ticket_id on a comment-review path may indicate a dedup-lookup miss rather than true
   > absence of a ticket. Before switching to create-review, the loop MUST re-run the §3.4
   > BLIND-SPOT/REVIEW-REQUIRED dedup query for this (org_slug, sensor_id). Only if dedup
   > returns no open ticket may the loop re-issue the verdict with ticket_action_type=create-review.
   > Skipping the dedup re-run risks creating a duplicate BLIND-SPOT/REVIEW-REQUIRED ticket,
   > violating D-DEC-004's one-open-ticket-per-(org_slug, sensor_id) constraint."

   Full pseudocode: see architecture-delta.md §D-DEC-008 STEP 3 (v1.12 P9-007 update).

3. **Re-doc attempt cap — HARD-FLOOR-UNBINDABLE livelock prevention (P9-008 OBS).**

   Add to the monitoring-loop control logic (near the re-document-on-deny obligation):

   > "Re-doc cap: the loop MUST track consecutive HARD-FLOOR-UNBINDABLE denies per verdict per
   > loop run. After 3 consecutive HARD-FLOOR-UNBINDABLE denies for the same verdict (indicating
   > structural misconfiguration — jira_project_key not configured), the loop MUST:
   > (a) stop re-documenting that verdict;
   > (b) emit a single operator-facing failure artifact to stderr and audit.log with code
   >     HARD-FLOOR-LIVELOCK-ABORT and the missing_field identified in the deny reason;
   > (c) advance to the next verdict/sensor.
   > This bounds LLM re-doc livelock to at most 3 cycles per finding."

---

### 8.20.4 BC-6.01.001 (activate skill) — Pass-9 Required Changes

**Current version: v1.5. Target: v1.6.**

1. **jira_project_key as a hard Stage-0 precondition (P9-008 OBS).**

   The activate skill (and onboard-customer) must gate on jira_project_key presence BEFORE
   the monitoring loop is permitted to run. Add to activate postconditions:

   > "Stage-0 precondition: activate MUST prompt for and validate jira_project_key (non-empty
   > string, Jira project key format) before completing. The monitoring-loop MUST NOT be
   > scheduled or run without a valid jira_project_key configured in plugin state. If
   > jira_project_key is absent when the loop starts, the loop MUST emit a fatal
   > MISSING-JIRA-PROJECT-KEY error and exit immediately (before processing any alerts).
   > Rationale: a structurally absent jira_project_key causes HARD-FLOOR-UNBINDABLE livelock
   > on every hard-floor create-review verdict; preventing the loop from starting is strictly
   > better than degrading to audit-only mode silently."

---

### 8.20.5 prd-delta — Process Items (P9-003 / P9-004)

> **Note:** P9-003 (BC-10.01.001 double-count in prd-delta) and P9-004 (verification-delta VP
> split mislabel + FINALIZED/ACCEPTED drift) are PO/FV-owned process findings. The architect
> does NOT edit these files.

1. **P9-003 (PO-owned): BC-10.01.001 double-count in prd-delta.**

   If BC-10.01.001 appears more than once in prd-delta's BC roster or requirement tables,
   remove the duplicate row. Verify that pass-9 changes (Inv#1 scope narrowing, STEP 3
   dedup gate, re-doc cap) are reflected in prd-delta's §5 version column and changelog.

2. **P9-004 (FV-owned): verification-delta VP split mislabel + FINALIZED/ACCEPTED drift.**

   See §8.21 FV list item 4 below. PO should coordinate with FV to ensure any VP lifecycle
   state changes in verification-delta are reflected consistently in prd-delta §1 VP roster.

*Pass-9 PO PROPAGATION LIST (§8.20) complete. Architect does NOT edit BCs, verification-delta,
prd-delta, or STATE.md.*

---

## 8.21 FORMAL-VERIFIER LIST (pass 9 — P9-001/007/009)

> **Owner:** Formal verifier. Architect does NOT write VPs. FV owns VP-INDEX.md,
> verification-delta.md, and VP files.
>
> **IMPORTANT — ID collision prevention:** Do NOT mint new VP/SM IDs without occupancy
> verification. Run `grep -r "SM-P9" .factory/` and `grep -r "VP-HOOK-0<next>" .factory/`
> before allocating any new ID.

---

1. **Differential-vs-bash vector partition — escaped-quote class (P9-001 MAJOR).**

   Extend the VP owning structural_label_check (VP-HOOK-024 or per occupancy check) with the
   O5 standing-rule-mandated differential-vs-bash partition for the escaped-quote class.

   ```bats
   @test "P9-001 diff-bash partition 1a: IN_DOUBLE + escaped-quote boundary + real --label REVIEW-REQUIRED after boundary → has_review_label=TRUE; regular create marker DENIED"
   @test "P9-001 diff-bash partition 1b: IN_DOUBLE + escaped-quote INSIDE double-quoted summary (not a boundary) → --label inside summary is NOT standalone token → has_review_label=FALSE; create marker ALLOWED"
   @test "P9-001 diff-bash partition 2: UNQUOTED + \\' → literal apostrophe in token; no IN_SINGLE state entered; --label after \\' is a standalone token when it follows whitespace"
   ```

   Paired mutant for partition 1 (allocate ID with occupancy check — do NOT use without grep):
   - SM-P9-A: "revert P9-001 IN_DOUBLE backslash-escape handling — treat `\"` as a quote-close
     (pre-P9-001 behavior)" → assert partition 1a input (escaped-quote boundary before real
     --label) produces has_review_label=FALSE and create marker is ALLOWED (security bypass).
     Mutant dies when P9-001 fix correctly produces has_review_label=TRUE and DENY.
     SEPARATELY killable from SM-P8-B (which tests non-quote-aware split_on_whitespace revert).

   Note: equals-form (--label=VALUE) vector SCOPED OUT — jr CLI does not support this form.
   Document in the VP: "equals-form vector excluded; jr only supports --label VALUE (confirmed
   2026-07-21). Re-evaluate if jr adds equals-form support in a future release."

2. **Dedup-before-fallback vector (P9-007 MINOR).**

   The STEP 3 fallback hint (comment-review + null ticket_id → suggest create-review) now
   requires a dedup re-run gate. Add a VP assertion or extend VP-HOOK-029 (verify occupancy):

   ```bats
   @test "P9-007 dedup-gate: comment-review + null ticket_id + jira_project_key present → deny reason includes dedup-before-create-review instruction (not just 'try create-review')"
   ```

   No new mutant required for this item (behavioral change is in the deny reason text, not
   in a security-critical control-flow path). Document as a test-only coverage vector.

3. **O5 standing rule — future coverage obligation.**

   Per O5 (architecture-delta §D-DEC-012): any future change to structural_label_check or
   to the CLI argument surface the hook parses MUST extend the differential-vs-bash vector
   partition. Add a standing note to the VP file:

   > "O5 standing rule (P9-009): this VP is the O5 compliance artifact for structural_label_check.
   > Any future tokenizer change or new CLI flag added to the monitored command surface MUST add
   > a corresponding differential-vs-bash vector to this VP before the change is merged."

4. **P9-004 (FV-owned process): verification-delta VP split mislabel + FINALIZED/ACCEPTED drift.**

   Audit verification-delta.md for:
   - VPs listed as FINALIZED that should be ACCEPTED (or vice versa) — reconcile lifecycle
     labels to match VP-INDEX.md as the source of truth.
   - Any VP split (one VP split into two) that still shows the pre-split single entry —
     correct verification-delta to reflect the post-split VP IDs and scopes.
   - After correction, re-verify VP-INDEX.md total count symmetry (VP-INDEX total must equal
     the sum of per-tool counts; verification-coverage-matrix.md Totals row must agree).

*Pass-9 FV list (§8.21) complete. Architect does NOT edit BCs, verification-delta, prd-delta,
or STATE.md. v1.12 is final for pass-9 adversarial remediation.*

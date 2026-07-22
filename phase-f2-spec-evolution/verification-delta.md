---
document_type: verification-delta
producer: formal-verifier
version: "1.10"
date: 2026-07-21
cycle: v0.10.0-feature-prism-integration
phase: f2
status: draft
changelog:
  - "1.10 (2026-07-21): Adversarial pass-7 remediation (ADV-F2-P7-001/004/005/006/009) per architecture-delta v1.10 §8.17 FORMAL-VERIFIER LIST. **CENTRAL CHANGE — the STEP-4 marker-upgrade mechanism (P5-001/P6-002) is RETIRED; STEP 4 now DENIES the under-labeled verdict Write** (architecture-delta §8.17 / redesigned D-DEC-008 STEP 4). P7-001 CRITICAL proved the upgrade unsound: disposition-guard can rewrite the marker but NOT the loop's future Bash command, so the create-review marker was structurally unconsumable by the loop's own non-review `jr` command for 3 of 4 under-label action types → the hard-floor finding was silently dropped. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified by `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-37; SM-2026 is a date false-positive) and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` (VP-SKILL max 074, VP-HOOK max 029) before allocation; architect placeholders SM-NEW-A/SM-NEW-B → **SM-38/SM-39** (next free), step-6a paired mutant → **SM-40**. No existing VP/SM renumbered. **(1) [P7-001/P7-004 CRITICAL/MAJOR — O4]** VP-HOOK-029 re-scoped end-to-end per the O4 standing rule (assert the consumer-boundary jr authorization/execution outcome, NOT an emitter-local marker): re-marked PROPOSED then re-FINALIZED (P0) with the new deny-path vector set. New property — hard-floor/Indeterminate verdict with ANY ticket_action_type: (review token) → restricted marker emitted at STEP 3 AND a correctly-labeled jr write is authorized/consumable at consumer STEP 6a (assert the jr authorization outcome); (non-review token incl. `none`) → verdict Write DENIED with structured corrective reason (hard_floor_trigger/required_token/label_instruction) + UNDER-LABEL-DENIED audit entry — NEVER an unconsumable marker, NEVER a silent allow. **RETIRED** the three v1.9 STEP-4 upgrade-marker vectors (marked RETIRED, reason 'mechanism removed ADV-F2-P7-001'; history preserved) and the UNDER-LABEL-CORRECTED audit assertion. Added 6+ deny-path vectors (create/assign/none under-label × deny+UNDER-LABEL-DENIED audit; corrected-rewrite happy path; consumer-boundary consumable/unconsumable; kill-switch-irrelevance — deny fires with autonomy_enabled BOTH true and false, STEP 4 before STEP 5). **(2) Mutants:** allocated **SM-38** (remove the STEP-4 deny → revert to silent allow; killed by the deny-path vectors) and **SM-39** (remove the corrective-reason structure from the deny message → deny fires but the loop cannot act; killed by the machine-actionable-reason-fields vector). **Re-targeted SM-32a** (was step-4-under-label-upgrade-removed → the upgrade is retired) to 'revert the STEP-4 deny to the retired GOTO-WRITE_MARKER upgrade → unconsumable marker in-store without a corrected Write' (killed by the consumer-boundary vector). **Re-worded SM-32-ext** kill vector to the deny-before-kill-switch assertion (revert STEP 4/5 order → kill switch silently allows the under-labeled hard-floor verdict before the STEP-4 deny can fire; killed by the kill-switch-irrelevance deny vector). **(3) [P7-005 MINOR]** VP-HOOK-024 — added the step-6a structural-check false-deny-prevention vector (regular create with a literal '--label REVIEW-REQUIRED' inside `--summary` → ALLOW with a `[\"create\"]` marker; structural token check, not raw substring) + paired mutant **SM-40** (revert `has_review_label` to raw substring → the vector DENYs and the mutant dies). **(4) [P7-006 MINOR]** VP-SKILL-074 — added the Cyberint partition (3 vectors: any Cyberint native severity → CRITICAL pre-ASM-008 conservative default; Cyberint NEVER LOW/MEDIUM/HIGH until ASM-008 resolves; CRITICAL output carries uncertainty_explicit naming the unvalidated mapping) with an 'update when ASM-008 resolves' annotation. **(5) [P7-009 OBS — O4 standing rule]** codified O4 in the §1 preamble: emitter-local artifacts (a marker file exists, an audit line is written) NEVER suffice as evidence for a consumer-boundary guarantee; every 'never silently discarded' claim MUST have a VP asserting the downstream jr authorization/execution outcome at the consumer/Bash boundary. **(6) Stale sweep:** all references to the STEP-4 'upgrade', 'UNDER-LABEL-CORRECTED', 'upgrade to create-review/comment-review', and marker-presence-only fail-loud phrasing (SM catalog, §3/§6 notes, VP rows, §7 Part H, closing snapshot) re-cast to deny-the-Write semantics. VP-SKILL-065's regular-vs-review carve-out phrasing is UNCHANGED (the regular-vs-review distinction is unaffected by the STEP-4 redesign). **(7)** Mutant count 31 → **34** (+SM-38, +SM-39, +SM-40; SM-32a re-targeted, SM-32-ext re-worded — neither adds/removes an id); VP count UNCHANGED at **31** (VP-HOOK-029 re-scoped in place, VP-HOOK-024 / VP-SKILL-074 extended); test-count ~258 → **~263** (net +3 BATS: VP-HOOK-029 fail-loud DENY-THE-WRITE re-scope net −1 [8 deny-era vectors − 9 v1.9 upgrade-era vectors; 3 marker-upgrade vectors RETIRED], VP-HOOK-024 step-6a false-deny +1, VP-SKILL-074 Cyberint +3; +~2 parity). Live-BC targets at v1.10 edit time (pass-7): **BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12** (STEP-4 deny-the-Write redesign + step-6a structural fix + six stale-EC propagation + Cyberint mapping BODY owned by PO per architecture-delta §8.16; §7 Part H records the FV cross-references). input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.9 (2026-07-21): Adversarial pass-6 remediation (ADV-F2-P6-001/002/003/005/007/010) per architecture-delta v1.9 §8.15 FORMAL-VERIFIER LIST. **NAMESPACE CORRECTIONS (independently re-verified — see §1):** (i) architect §8.15 item 3 proposed 'VP-SKILL-072' for severity normalization, but VP-SKILL-072 is ALREADY OCCUPIED (first-run 24h lookback, FINALIZED v1.5 / BC-10.01.001 v1.9 Inv#13). Severity normalization is therefore allocated the next free id **VP-SKILL-074** (073 is claimed by late-event per architecture-delta body §660/§3541). (ii) architect §8.15 item 5 (and the same-named consumer mutants) proposed 'SM-33'/'SM-34' for the consumer anti-fungibility mutants, but SM-33 (autonomy_enabled-clause-removed) and SM-34 (dispatch-order-inverted) are ALREADY OCCUPIED pass-4 sentinels; the consumer anti-fungibility mutants are therefore allocated the next free ids **SM-36**/**SM-37**. No existing VP or SM renumbered. (1) [P6-002 CRITICAL / P6-010] **FINALIZED VP-HOOK-029** (lifecycle PROPOSED → FINALIZED, fix-priority P0) and added the kill-switch-on under-label vectors: the three `autonomy_enabled=false` + under-labeled hard-floor combinations (ticket_id present → comment-review upgrade; ticket_id null + project_key present → create-review upgrade; neither → error+deny) asserting review-marker XOR error, NEVER silent allow, regardless of autonomy_enabled — closing the P6-002 coverage hole (STEP 4 under-label upgrade now runs BEFORE the STEP 5 kill switch per architecture-delta v1.9 §B). (2) [P6-001 CRITICAL] Added consumer anti-fungibility vectors under **VP-HOOK-024** asserting require-review STEP 6a exact-type matching in BOTH directions (create-review marker + command WITHOUT --label → DENY; create marker + command WITH --label → DENY; correct pairings consume normally — EC-023); paired mutants **SM-36** (remove the review-label check for review markers) and **SM-37** (remove the reverse check for regular markers), each killed by a distinct named vector. Added **SM-32-ext** (revert the STEP 4/5 ordering — kill switch back before under-label upgrade) killed by the new VP-HOOK-029 kill-switch-on under-label vectors. (3) [P6-003 MAJOR] **RE-SCOPED VP-SKILL-065** from 'zero jr writes under autonomy_enabled=false' to 'zero REGULAR (comment/create/assign) jr writes; create-review/comment-review escalation writes for genuine hard-floor verdicts still execute per D-DEC-012 Option A'; lifecycle re-marked (no longer silently FINALIZED — RE-SCOPED PROPOSED this pass); jr-mock spy assertion updated (zero REGULAR writes + kill-switch-exempt review write on silent-sensor). (4) [P6-005 MAJOR] Added **VP-SKILL-074** (severity normalization correctness, D-DEC-013) — per-sensor-family mapping (CrowdStrike 1-100, Armis/Claroty risk bands, NVD/CVSS floats) applied at Stage 1/Stage 5; unrecognized severity → CRITICAL with uncertainty_explicit (auditable), never a silent enum-deny; case-exactness preserved. Tag P1, PROPOSED. (5) [P6-007 MINOR] Added **VP-SKILL-073** (late-event drop detection, D-DEC-002) — event `_time < watermark − WATERMARK_GRACE_SECONDS` → LATE_EVENT_DETECTED audit entry emitted, event still processed; never a silent drop. Tag P1, PROPOSED. (6) Swept the CURRENT body for the STEP 4/5 swap (under-label upgrade = STEP 4, kill switch = STEP 5, post ADV-F2-P6-002): SM catalog target labels (SM-16, SM-32a, SM-33), VP-HOOK-026/029 rows, §3/§6 present-tense discussions; stale create-review command_pattern updated to the `--label (REVIEW-REQUIRED|BLIND-SPOT)( |$)`-in-fixed-second-position form; stale 'zero jr writes' phrasing re-scoped. (7) Mutant count 28 → **31** (SM-9..SM-35 with SM-32=SM-32a+SM-32b+SM-32-ext, + SM-36, + SM-37). VP count 29 → **31** (+VP-SKILL-073, +VP-SKILL-074). Test-count estimate ~238 → **~258** (+16 BATS: consumer anti-fungibility +2 on BC-3.01.001; kill-switch-on under-label +3, VP-SKILL-065 Option-A carve-out +1, late-event +3, severity-normalization boundary partitions +7 on BC-10.01.001; +~4 parity). Live-BC snapshot at v1.9 edit time (pass-6): BC-3.01.001 v1.17→**v1.18**, BC-3.03.001 v1.13→**v1.15**, BC-10.01.001 v1.9→**v1.11** (STEP reorder + Inv#11 carve-out + severity normalization body owned by PO per architecture-delta §8.14; FV cross-refs in §7 Part G). VP namespace now VP-SKILL 001–074, VP-HOOK 024–029; SM 9–37."
  - "1.8 (2026-07-21): Adversarial pass-5 re-scope (ADV-F2-P5-001 CRITICAL / P5-002 MAJOR) per architecture-delta v1.8 §8.13 FORMAL-VERIFIER LIST. Root cause (§8.13 / D-DEC-012 O3 standing rule): the deterministic disposition-guard hook trusted the LLM-supplied ticket_action_type without cross-checking hook-computed hard_floor_applies(); P5-001 (under-label) and P5-002 (over-label) are the duals of that single gap. (1) [P5-001 CRITICAL] RE-SCOPED VP-HOOK-029 from the happy-path-only 'hard-floor verdict WITH ticket_action_type∈{create-review,comment-review} → marker OR error' (which could NOT detect the silent-discard case) to the fail-loud critical vectors: 'hard-floor verdict carrying a NON-review ticket_action_type∈{comment,create,assign,none} → review-marker (STEP 5 upgrade) XOR explicit error+deny — NEVER silent allow-without-marker.' New vectors cover all three STEP 5 branches — (a) ticket_id present → comment-review upgrade; (b) ticket_id null + jira_project_key present → create-review upgrade; (c) ticket_id null + project_key absent → error artifact + deny — plus the UNDER-LABEL-CORRECTED audit entry; the pre-existing correct-label happy-path vectors are RETAINED (§8.13 item 1). (2) [P5-001/P5-002] RE-SCOPED SM-32 into two separately-killable variants: SM-32a (remove STEP 5 under-label upgrade → silent emit-allow-without-marker) killed by VP-HOOK-029 under-label vectors; SM-32b (remove the STEP 3 'NOT hard_floor_applies()' over-label gate → non-hard-floor verdict with a review token gets the kill-switch/hard-floor-exempt marker) killed by VP-HOOK-026 over-label vectors. Mutant count 27 → 28 (SM-9..SM-35, SM-32=SM-32a+SM-32b). (3) [P5-002 MAJOR] EXTENDED VP-HOOK-026 with over-label legs: a non-hard-floor verdict (disposition=TP, LOW severity, standard asset) carrying a create-review/comment-review token produces NO marker (allow-without-marker), incl. under autonomy_enabled=false (no kill-switch bypass) — the STEP 3 exemption is now GATED on hook-computed hard_floor_applies(verdict)=TRUE. (4) Swept §3 review-surfacing discussion, §5 BC-10.01.001 counts, and §6 notes for the retired 'unconditional/ungated review-exemption' and 'silent allow on action==none under hard floor' semantics; aligned to the STEP 3 gate + STEP 5 fail-loud upgrade (architecture-delta v1.8 D-DEC-008 STEP 3/STEP 5). VP namespace UNCHANGED (VP-SKILL 001–072, VP-HOOK 024–029; SM 9–35) — re-scope, NOT new IDs. Kill-switch Option A (escalation markers execute under autonomy_enabled=false for GENUINE hard-floor verdicts, human-confirmed 2026-07-21) reflected in the gated exemption. Test-count estimate ~231 → ~238 (+7 BATS on BC-10.01.001: VP-HOOK-026 over-label gate +3, VP-HOOK-029 fail-loud under-label expansion +4)."
  - "1.7 (2026-07-21): finish residual version-ref sync."
  - "1.6 (2026-07-21): version-ref sync to frozen live BC versions (BC-3.01.001 v1.17, BC-3.03.001 v1.13, BC-4.02.001 v1.8, BC-4.05.001 v1.3, BC-5.01.001 v1.8, BC-6.01.001 v1.5, BC-10.01.001 v1.9). No VP/strategy/mutant/test-count changes; stale live-body BC cross-refs (VP table §2, §5 sizing table, §3/§6 prose citations, §7 Part D/E correction targets, closing snapshot) synced to frozen; historical/changelog/edit-time/first-landed/CONFIRMED-APPLIED and evolution-narrative annotations left intact."
  - "1.5 (2026-07-21): Adversarial pass 4 remediation (architecture-delta v1.6 §8.11 FORMAL-VERIFIER LIST pass 4 + D-DEC-008 JSON-first dispatch + D-DEC-012 create-review/comment-review + validate_enums() + autonomy_enabled operational field). Adds 2 VPs — VP-HOOK-029 (P1 fail-loud invariant: a hard-floor/Indeterminate/silent-sensor verdict MUST yield a create-review/comment-review marker OR an explicit error artifact, never silent discard — D-DEC-012, ADV-F2-P4-004) and VP-SKILL-072 (BC-10.01.001 Inv#13 first-run 24h lookback correctness — ADV-F2-P4-012/D-DEC-002) — and 5 mutants (SM-31 validate_enums-removed → wrong-case severity passes hard floor, ADV-F2-P4-006; SM-32 review-surfacing-hard-floor-bypass-removed → Indeterminate+create-review wrongly blocked, D-DEC-012/P4-004; SM-33 autonomy_enabled-clause-removed → regular marker wrongly emitted under kill switch, ADV-F2-P4-005; SM-34 dispatch-order-inverted → verdict JSON at canonical investigations/verdict-*.json path misrouted to 12-field markdown branch and wrongly denied, ADV-F2-P4-001; SM-35 control-char-strip-removed → forged MARKER_USED audit line via \\n in ticket_id/org_slug/op, ADV-F2-P4-010). Extends VP-HOOK-024 (create command_pattern injection-safety: anchored `--project`-first pattern, --summary injection + PROD/PRODUCTION prefix → DENY, P4-002 CRITICAL), VP-HOOK-025 (validate_enums() membership legs for severity/asset_type/disposition/sensor_health_status/ticket_action_type/confidence — wrong-case/non-member → fail-closed DENY BEFORE hard floor, P4-006), VP-HOOK-026 (create-review/comment-review hard-floor-EXEMPT + kill-switch-EXEMPT legs, and autonomy_enabled read-direct-from-verdict determinism legs, D-DEC-012/P4-004/P4-005), VP-HOOK-028 (canonical-path JSON-first dispatch regression: investigations/verdict-*.json → 15-field verdict path; investigation-*.md → 12-field path, P4-001). Namespace re-verified independently: VP-SKILL 001–072, VP-HOOK 024–029, SM 9–35 — ZERO collisions. Live-BC snapshot SYNCED to BC-3.03.001 v1.12, BC-3.01.001 v1.16, BC-10.01.001 v1.8, BC-4.02.001 v1.7, BC-6.01.001 v1.5. Mutant count 22 → 27; test-count estimate refreshed ~195 → ~231 (~155 BATS + ~76 parity). BC corrections routed to PO in §7 Part E."
  - "1.4 (2026-07-20): version-ref sync to frozen pass-3 BC versions."
  - "1.3 (2026-07-20): Adversarial pass 3 remediation (architecture-delta v1.4 §8.9 FORMAL-VERIFIER LIST pass 3 + D-DEC-011 + D-DEC-008-C artifact-class branching). (1) [ADV-F2-P3-001 CRITICAL] VP-HOOK-026: added the asset_type=unknown hard-floor leg — a LOW-severity / benign-technique verdict with asset_type=unknown NEVER gets a marker regardless of autonomy_enabled; paired mutant SM-29 (unknown-asset-hard-floor-removed → asserts marker IS wrongly written, must be killed). (2) [ADV-F2-P3-004 MAJOR] FINALIZED VP-SKILL-069 (investigate-event PrismQL org_slug scoping — BC-5.01.001 v1.6 Inv#8, Stage-3 OCSF + temporal-adjacency queries always carry org_slug WHERE clause) and VP-SKILL-070 (assess-priority PrismQL org_slug scoping — BC-4.05.001 v1.2 Inv#4, PC#5a/5b/5d) — both already PROPOSED-referenced in their owning BCs; strategy = static Iron-Law content assertion + prism-DTU multi-org fixture (org-a query returns zero org-b/c rows). Added to VP table + coverage matrix. (3) [ADV-F2-P3-003/P3-013] VP-HOOK-025 per-class split: BATS counts now reflect the 12-field investigation-markdown path vs the 15-field verdict-JSON path (D-DEC-008-C artifact-class branching); paired mutant SM-30 (artifact-class-over-strict → apply the 15-field set to investigation markdown so a valid 12-field investigation is wrongly DENIED; a Severity heading inserted into investigation markdown must NOT trigger a wrong-class deny). (4) [ADV-F2-P3-005/P3-013] ADDED VP-HOOK-028 (verdict-path reachability — a Stage-7 Write to a non-'verdict' path → disposition-guard fast-path-allows, no marker → Stage-8 jr DENIED). Added to VP table + matrix. (5) [ADV-F2-P3-008/P3-013] VP-HOOK-025: added confidence float→enum legs (disposition-guard DENIES field#2 confidence float, ALLOWS enum values); FINALIZED VP-SKILL-071 (assess-priority confidence float→enum consistency — boundary test at D-DEC-011 thresholds 0.75 and 0.40). Added to VP table + matrix. (6) mutant catalog SM-9..SM-30 (22 mutants — +SM-29, +SM-30); test-count estimate refreshed ~165 → ~195. (7) Live-BC snapshot header synced to LIVE (BC-3.03.001 v1.10, BC-3.01.001 v1.15, BC-5.01.001 v1.6, BC-10.01.001 v1.6, BC-4.05.001 v1.2, BC-6.01.001 v1.4, BC-4.02.001 v1.6); VP-table/§ anchors re-synced for internal self-consistency; §7 Part D pass-3 BC corrections added."
  - "1.2 (2026-07-20): Adversarial pass 2 remediation (architecture-delta v1.3 §8.7 FORMAL-VERIFIER LIST). (1) ADV-F2-P2-001/P2-014: added VP-HOOK-027 (P1, cross-hook integration) — STAGE-ORDER DOCUMENT-BEFORE-ACTION: a monitoring-loop jr comment/create/assign is DENIED unless a verdict-record Write (disposition-guard emits marker) for the same run preceded it within the marker TTL (Stage 7 DOCUMENT before Stage 8 TICKET ACTION); + paired mutant SM-28 (stage-order-inverted). (2) ADV-F2-P2-009a: added VP-SKILL-066 (BC-4.02.001 Inv#4 never-auto-reopen on the UPDATE-JIRA path — VP-SKILL-062 covered only the monitoring-loop path) + paired mutant SM-26 (reopen-guard-removed). (3) ADV-F2-P2-009b: added VP-SKILL-067 (BC-4.02.001 Inv#5 SLA surface-never-assume — append/link/propose-reopen emit an explicit SLA-impact statement). (4) ADV-F2-P2-009c: added VP-SKILL-068 (D-DEC-002 watermark grace-window + Jira-first dedup — late/out-of-order event re-fetched inside GRACE with an existing open ticket → COMMENT not new ticket; VP-SKILL-050 remains monotonicity-only) + paired mutant SM-27 (dedup-check-removed→double-ticket). (5) ADV-F2-P2-005: version-refs synced to LIVE (BC-10.01.001 v1.4, BC-3.01.001 v1.14, BC-3.03.001 v1.9, BC-4.02.001 v1.5, BC-6.01.001 v1.3); §7 Part B VP-SKILL-064/065 re-marked FINALIZED (stale 'pending/still-owed' framing removed). (6) VP-HOOK-024 consumer vectors re-aligned to ITERATIVE-CONSUME (sort by issued_at_utc ASC; first successful atomic rename → allow; all renames fail/exhausted → deny) replacing the retired '>1 → ambiguous deny'; SM-15 retargeted from multiplicity-guard to iterative-consume exhaustion fail-open; audit path aligned to ${CLAUDE_PLUGIN_DATA}/markers/audit.log. (7) mutant catalog SM-9..SM-28 (20 mutants); test-count estimate refreshed ~139 → ~165."
  - "1.1 (2026-07-20): Adversarial pass 1 remediation — verification-delta re-aligned to architecture-delta v1.2 canonical marker schema v2.0 (expires_at_utc absolute, 120s TTL, base64 audit, rename-fail→deny, ticket-bound command_pattern) and 15-field verdict schema. (A) ADV-F2-008: FINALIZED VP-SKILL-064 (monitoring-loop org_slug scoping — sole plugin-side cross-tenant isolation guarantee, D-DEC-005). (B) ADV-F2-019 [process-gap]: added VP-SKILL-065 (autonomy_enabled kill switch — zero markers + zero jr writes when false). (C) ADV-F2-001/004: VP-HOOK-025 field completeness 12→15 (severity[13], asset_type[14], ticket_action_type[15]); VP-HOOK-026 hard-floor legs corrected to inject verdict.severity=HIGH + verdict.asset_type=critical-asset (keyed on severity NOT confidence). (D) ADV-F2-002: VP-HOOK-024 ticket-bound command_pattern + create/assign scoped allow-path vectors + rename-fail→deny. (E) ADV-F2-015: all stale BC version refs updated to LIVE (BC-3.01.001 v1.13, BC-3.03.001 v1.8, BC-4.02.001 v1.5, BC-10.01.001 v1.2). (F) SM-N catalog extended to SM-9..SM-25 (added severity-field-drop, ticket_action_type-ignored→wrong-scope, hard-floor-keyed-on-confidence, hard-floor-after-auto-close ADV-F2-005, org_slug-drop, kill-switch-ignore). (G) test-count estimate refreshed ~119 → ~139."
  - "1.0 (2026-07-20): Initial F2 verification-delta — 17 VPs, 4 PO questions answered, SM-9..SM-19, ~119 test-count estimate."
inputs:
  - .factory/phase-f2-spec-evolution/architecture-delta.md
  - .factory/phase-f2-spec-evolution/prd-delta.md
  - .factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass1.md
  - .factory/phase-0-ingestion/verification-gap-analysis.md
  - .factory/specs/module-criticality.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-4.02.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-4.05.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-5.01.001.md
  - .factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass3.md
  - .factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass4.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-6.01.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-6.01.003.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-6.01.004.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-8.02.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-9.01.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-10.01.001.md
  - plugins/secops-factory/tests/hooks.bats
  - plugins/secops-factory/tests/integration.bats
verification_stack: "BATS behavioral / structural-presence / integration (jr-mock + prism-DTU) + manual SM-N mutant catalog + adversarial fixtures. NO Kani/proptest/cargo-fuzz (declarative bash/markdown plugin)."
---

# Verification Delta — v0.10.0-feature-prism-integration (Phase F2)

> **Scope:** Finalizes all VP assignments for the prism-integration cycle, resolves the
> product-owner's 4 open technical questions as VP design decisions, extends the SM-N
> mutant catalog for the marker-validation and disposition-guard-JSON paths, and estimates
> the per-BC BATS test-count delta for F3 story sizing. Does NOT modify any BC, index, or
> STATE.md. BC reference corrections that require the product-owner's action are listed in §7.
>
> **v1.1 (adversarial pass 1 remediation):** re-aligned to architecture-delta **v1.2**
> canonical marker schema **v2.0** (`expires_at_utc` absolute, 120s TTL, base64-encoded audit
> command field, rename-fail→deny, ticket-bound `command_pattern`) and the **15-field** verdict
> schema (12 ICD-203 + severity[13] + asset_type[14] + ticket_action_type[15]). Finalizes
> **VP-SKILL-064** (ADV-F2-008 org_slug scoping) and adds **VP-SKILL-065** (ADV-F2-019 kill
> switch). Corrects VP-HOOK-024/025/026. All BC version references updated to LIVE. SM-N catalog
> extended to SM-9..SM-25. Live-BC snapshot at v1.1 edit time: BC-3.01.001 **v1.13**, BC-3.03.001
> **v1.8**, BC-4.02.001 **v1.5**, BC-10.01.001 **v1.2**.
>
> **v1.2 (adversarial pass 2 remediation):** closes the architecture-delta **v1.3** §8.7
> FORMAL-VERIFIER LIST. Adds **4 VPs** — **VP-HOOK-027** (P1 cross-hook: STAGE-ORDER
> DOCUMENT-BEFORE-ACTION, ADV-F2-P2-001/P2-014), **VP-SKILL-066** (BC-4.02.001 Inv#4
> never-auto-reopen on the update-jira path, ADV-F2-P2-009a), **VP-SKILL-067** (BC-4.02.001 Inv#5
> SLA surface-never-assume, ADV-F2-P2-009b), **VP-SKILL-068** (D-DEC-002 grace-window + Jira-first
> dedup, ADV-F2-P2-009c) — and **3 mutants** (SM-26 reopen-guard-removed, SM-27
> dedup-check-removed→double-ticket, SM-28 stage-order-inverted). Re-aligns VP-HOOK-024 to the
> **iterative-consume** consumer (architecture-delta §D-DEC-001 v1.3: sort by issued_at_utc ASC,
> first successful atomic rename → allow, exhausted → deny) — retiring the ">1 → ambiguous deny"
> gate — and to the canonical audit path `${CLAUDE_PLUGIN_DATA}/markers/audit.log`. **Live-BC
> snapshot at v1.2 edit time (SYNCED, ADV-F2-P2-005): BC-10.01.001 v1.4, BC-3.01.001 v1.14,
> BC-3.03.001 v1.9, BC-4.02.001 v1.5, BC-6.01.001 v1.3.**
>
> **v1.3 (adversarial pass 3 remediation):** closes the architecture-delta **v1.4** §8.9
> FORMAL-VERIFIER LIST (pass 3), the D-DEC-011 confidence float→enum contract, and the
> D-DEC-008-C artifact-class field-set branching. Adds **4 VPs** — **VP-SKILL-069**
> (investigate-event PrismQL org_slug scoping, ADV-F2-P3-004), **VP-SKILL-070** (assess-priority
> PrismQL org_slug scoping, ADV-F2-P3-004), **VP-SKILL-071** (assess-priority confidence float→enum
> consistency at D-DEC-011 thresholds 0.75/0.40, ADV-F2-P3-008), **VP-HOOK-028** (verdict-path
> reachability, ADV-F2-P3-005) — and **2 mutants** (SM-29 unknown-asset-hard-floor-removed,
> SM-30 artifact-class-over-strict). Extends **VP-HOOK-026** with the `asset_type=unknown` hard-floor
> leg (ADV-F2-P3-001 CRITICAL) and **VP-HOOK-025** with the 12-vs-15 per-class field split
> (ADV-F2-P3-003) + confidence float→enum legs (ADV-F2-P3-008). **Live-BC snapshot at v1.3 edit
> time (SYNCED): BC-3.03.001 v1.11, BC-3.01.001 v1.15, BC-5.01.001 v1.7, BC-10.01.001 v1.7,
> BC-4.05.001 v1.3, BC-6.01.001 v1.4, BC-4.02.001 v1.6.** Cross-doc/other-file version-ref
> reconciliation is owned by the dedicated version-coherence sweep that runs after this edit.
>
> **v1.5 (adversarial pass 4 remediation):** closes the architecture-delta **v1.6** §8.11
> FORMAL-VERIFIER LIST (pass 4), the **D-DEC-008 JSON-first dispatch** precedence fix, the
> **D-DEC-012** review-ticket surfacing path (`create-review`/`comment-review`), the D-DEC-008
> `validate_enums()` membership gate, and the `autonomy_enabled` operational-field determinism fix.
> Adds **2 VPs** — **VP-HOOK-029** (**P1** fail-loud invariant: a hard-floor / Indeterminate /
> silent-sensor verdict MUST yield a `create-review`/`comment-review` marker OR an explicit error
> artifact — NEVER silent discard, ADV-F2-P4-004) and **VP-SKILL-072** (BC-10.01.001 Inv#13
> first-run 24h lookback correctness, ADV-F2-P4-012 / D-DEC-002) — and **5 mutants** (SM-31
> validate_enums-removed, SM-32 review-surfacing-hard-floor-bypass-removed, SM-33
> autonomy_enabled-clause-removed, SM-34 dispatch-order-inverted, SM-35 control-char-strip-removed).
> Extends **VP-HOOK-024** (create `command_pattern` injection-safety, ADV-F2-P4-002 CRITICAL),
> **VP-HOOK-025** (`validate_enums()` membership legs, ADV-F2-P4-006), **VP-HOOK-026**
> (create-review/comment-review hard-floor-EXEMPT + kill-switch-EXEMPT legs + `autonomy_enabled`
> read-direct-from-verdict determinism, D-DEC-012 / ADV-F2-P4-004 / P4-005), and **VP-HOOK-028**
> (canonical-path JSON-first dispatch regression, ADV-F2-P4-001 CRITICAL). **Live-BC snapshot at
> v1.5 edit time (SYNCED): BC-3.03.001 v1.13, BC-3.01.001 v1.17, BC-10.01.001 v1.9, BC-4.02.001
> v1.8, BC-6.01.001 v1.5.** Cross-doc/other-file version-ref reconciliation remains owned by the
> dedicated version-coherence sweep.
>
> **v1.8 (adversarial pass-5 re-scope):** closes the architecture-delta **v1.8** §8.13
> FORMAL-VERIFIER LIST (ADV-F2-P5-001 CRITICAL / P5-002 MAJOR). **No new VP or SM IDs** — this is
> a re-scope of existing entries (VP-SKILL 001–072, VP-HOOK 024–029 unchanged). Root cause: the
> deterministic disposition-guard hook trusted the LLM-supplied `ticket_action_type` without
> cross-checking hook-computed `hard_floor_applies()` (D-DEC-012 O3 standing rule); P5-001
> (under-label) and P5-002 (over-label) are duals. **(1) VP-HOOK-029 re-scoped** from the
> happy-path-only "hard-floor + review token → marker OR error" (which could not detect the
> silent-discard case) to the fail-loud vectors: a hard-floor verdict carrying a **NON-review**
> `ticket_action_type ∈ {comment,create,assign,none}` MUST yield a review-marker (STEP 5 upgrade)
> **XOR** an explicit error+deny — NEVER a silent allow-without-marker; covers all three STEP 5
> branches (ticket_id present → comment-review; ticket_id null + project_key present → create-review;
> neither → error+deny) + the UNDER-LABEL-CORRECTED audit entry; correct-label happy-path vectors
> retained. **(2) SM-32 re-scoped** into **SM-32a** (remove STEP 5 upgrade → silent discard; killed
> by VP-HOOK-029 under-label vectors) and **SM-32b** (remove the STEP 3 `NOT hard_floor_applies()`
> gate → over-label kill-switch bypass; killed by VP-HOOK-026 over-label vectors) — mutant count
> 27 → 28. **(3) VP-HOOK-026 extended** with over-label legs (non-hard-floor verdict + review token
> → NO marker, incl. under `autonomy_enabled=false`); the STEP 3 review-exemption is now GATED on
> `hard_floor_applies(verdict)=TRUE`. **(4)** §3 review-surfacing discussion, §5 counts, and §6
> notes swept for the retired "unconditional/ungated review-exemption" and "silent allow on
> action==none under hard floor" semantics (architecture-delta v1.8 D-DEC-008 STEP 3/STEP 5).
> Kill-switch Option A confirmed 2026-07-21 (escalation markers execute under `autonomy_enabled=false`
> for GENUINE hard-floor verdicts only). Live-BC snapshot UNCHANGED from v1.5 (frozen pass-5:
> BC-3.03.001 v1.13, BC-3.01.001 v1.17, BC-10.01.001 v1.9). BC STEP 3/STEP 5 body updates are
> product-owner-owned (architecture-delta §8.12); §7 Part F records the FV cross-references.
>
> **v1.9 (adversarial pass-6 remediation — ADV-F2-P6-001/002/003/005/007/010):** closes the
> architecture-delta **v1.9** §8.15 FORMAL-VERIFIER LIST. **Two independently-verified namespace
> corrections** (§1): severity normalization is **VP-SKILL-074** (architect's §8.15 item-3 "VP-SKILL-072"
> collides with the already-FINALIZED first-run-24h-lookback VP-SKILL-072); the consumer anti-fungibility
> mutants are **SM-36/SM-37** (architect's §8.15 item-5 "SM-33/SM-34" collide with the already-occupied
> pass-4 mutants). **(1) [P6-002 CRITICAL / P6-010]** VP-HOOK-029 **FINALIZED** (PROPOSED → FINALIZED,
> P0) with kill-switch-on under-label vectors — the three `autonomy_enabled=false` + under-labeled
> hard-floor combinations (ticket_id present → comment-review; ticket_id null + project_key → create-review;
> neither → error+deny) assert review-marker XOR error, NEVER silent allow, regardless of `autonomy_enabled`
> (STEP 4 under-label upgrade now runs BEFORE the STEP 5 kill switch — architecture-delta v1.9 §B STEP
> reorder). **(2) [P6-001 CRITICAL]** consumer anti-fungibility vectors added under **VP-HOOK-024** —
> require-review STEP 6a exact-type matching in BOTH directions (create-review marker + no-`--label`
> command → DENY; create marker + `--label` command → DENY; correct pairings consume normally, EC-023);
> paired mutants **SM-36** (remove review-label check) + **SM-37** (remove reverse check); **SM-32-ext**
> (revert STEP 4/5 order) killed by the new VP-HOOK-029 kill-switch-on vectors. **(3) [P6-003 MAJOR]**
> VP-SKILL-065 **RE-SCOPED** (PROPOSED, no longer silently FINALIZED) to "zero REGULAR
> (comment/create/assign) jr writes; create-review/comment-review escalation writes for genuine
> hard-floor verdicts still execute per D-DEC-012 Option A." **(4) [P6-005 MAJOR]** new **VP-SKILL-074**
> (severity normalization, D-DEC-013 — per-sensor-family mapping at Stage 1/Stage 5; unrecognized →
> CRITICAL + `uncertainty_explicit`, auditable, never a silent enum-deny; case-exact). **(5) [P6-007
> MINOR]** new **VP-SKILL-073** (late-event drop detection, D-DEC-002 — `_time < watermark − GRACE` →
> `LATE_EVENT_DETECTED` audit entry, event still processed, never silent drop). **(6)** STEP 4/5 swap
> swept through SM catalog / VP notes / §3/§6 discussions; create-review `command_pattern` updated to the
> `--label (REVIEW-REQUIRED|BLIND-SPOT)( |$)` fixed-second-position form; stale "zero jr writes" phrasing
> re-scoped. **(7)** Mutant count 28 → **31** (+SM-32-ext, +SM-36, +SM-37); VP count 29 → **31**
> (+VP-SKILL-073, +VP-SKILL-074); test-count ~238 → **~258**. Live-BC snapshot at v1.9 edit time
> (pass-6): **BC-3.01.001 v1.18, BC-3.03.001 v1.15, BC-10.01.001 v1.11** (STEP reorder + Inv#11 carve-out
> + severity-normalization BODY owned by PO per architecture-delta §8.14; §7 Part G records the FV
> cross-references). Cross-doc/other-file version-ref reconciliation remains owned by the dedicated
> version-coherence sweep.
>
> **v1.10 (adversarial pass-7 remediation — ADV-F2-P7-001/004/005/006/009):** closes the
> architecture-delta **v1.10** §8.17 FORMAL-VERIFIER LIST. **The STEP-4 marker-upgrade mechanism
> (P5-001/P6-002) is RETIRED and replaced by DENY-THE-WRITE** (redesigned D-DEC-008 STEP 4). P7-001
> CRITICAL proved the upgrade structurally unsound: disposition-guard can rewrite the marker but NOT
> the loop's future Bash command, so an under-labeled hard-floor verdict produced a `create-review`
> marker the loop's own non-review `jr` command could never consume (3 of 4 under-label action types
> → silent drop). New STEP 4: a hard-floor / Indeterminate verdict carrying a non-review
> `ticket_action_type ∈ {comment,create,assign,none}` → disposition-guard **DENIES the verdict Write**
> with a structured machine-readable corrective reason (`hard_floor_trigger`, `required_token`,
> `label_instruction`, `instruction`) + an **UNDER-LABEL-DENIED** audit entry; NO marker; the loop
> re-issues the Write with the corrective token; on the corrected Write STEP 3 issues the review marker
> normally. **No new VP/SM IDs minted without occupancy verification (Lesson 8): architect placeholders
> SM-NEW-A/SM-NEW-B → SM-38/SM-39; the step-6a paired mutant → SM-40** (next free; SM-37 was the prior
> max real id — SM-2026 is a date false-positive). **(1) [P7-001/P7-004]** VP-HOOK-029 re-scoped
> **end-to-end (O4)**: re-marked PROPOSED, then re-FINALIZED (P0) asserting the CONSUMER-BOUNDARY jr
> authorization/execution outcome — for a hard-floor verdict with ANY `ticket_action_type`: (review
> token) → restricted marker at STEP 3 AND a correctly-labeled jr write authorized/consumable at
> consumer STEP 6a; (non-review token incl. `none`) → verdict Write DENIED with corrective reason +
> UNDER-LABEL-DENIED audit — NEVER an unconsumable marker, NEVER a silent allow. **RETIRED** the three
> v1.9 STEP-4 upgrade-marker vectors (marked RETIRED, reason "mechanism removed ADV-F2-P7-001"; history
> preserved) + the UNDER-LABEL-CORRECTED audit assertion; **added** the deny-path vectors (create/assign/none
> under-label deny+audit; corrected-rewrite happy path; consumer-boundary consumable/unconsumable;
> kill-switch-irrelevance — deny fires with `autonomy_enabled` BOTH true and false). **(2) Mutants:**
> **SM-38** (remove STEP-4 deny → silent allow; killed by the deny-path vectors), **SM-39** (remove the
> corrective-reason structure → deny fires but the loop cannot act; killed by the machine-actionable-reason
> vector); **SM-32a re-targeted** to "revert the deny to the retired GOTO-WRITE_MARKER upgrade →
> unconsumable in-store marker" (killed by the consumer-boundary vector); **SM-32-ext** kill vector
> re-worded to the deny-before-kill-switch assertion. **(3) [P7-005]** VP-HOOK-024 step-6a structural-check
> false-deny vector + paired **SM-40** (raw-substring revert). **(4) [P7-006]** VP-SKILL-074 Cyberint
> partition (3 vectors; "update when ASM-008 resolves"). **(5) [P7-009]** O4 standing rule codified below.
> **(7)** Mutant count 31 → **34**; VP count UNCHANGED at **31**; test-count ~258 → **~263** (net +3 BATS).
> Live-BC targets at v1.10 edit time (pass-7): **BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12**;
> §7 Part H records the FV cross-references. Cross-doc/other-file version-ref reconciliation remains
> owned by the dedicated version-coherence sweep.

---

## 0. Standing Rules / Conventions (cross-cutting, load-bearing)

**O4 standing rule — consumer-boundary evidence (ADV-F2-P7-009 / architecture-delta v1.10 D-DEC-012
O3 table row P7-009).** *Emitter-local artifacts NEVER suffice as evidence for a consumer-boundary
guarantee.* A marker file existing in the store, or an audit line being written, is an **emitter-side**
predicate; the human-surface guarantee (a finding reaches a SOC analyst) lives at the **consumer/Bash
boundary** — a `jr` write is authorized AND consumable. **Every "never silently discarded" / fail-loud
claim in this document MUST be discharged by a VP whose assertion is the downstream jr
authorization/execution outcome, not the upstream marker presence.** An emitter-only VP cannot detect
the Write→Bash seam gap (the exact class of defect P7-001 surfaced: a marker present in the store but
structurally unconsumable by the loop's own command). This rule is operationalized by the VP-HOOK-029
re-scope (§2 / §6) and governs all future fail-loud VP authoring for this cycle. (The O1–O3 standing
rules — enum-membership before routing, LLM-supplied routing fields cross-validated against
hook-computed invariants, consumer-consumption/ordering/trust-boundary coverage — remain in force per
architecture-delta D-DEC-012.)

---

## 1. Namespace Adjudication (independent re-verification)

The F1 audit reported occupancy `VP-SKILL 001–049`, `VP-HOOK ≤023`. I re-verified independently
by globbing every BC in `.factory/phase-0-ingestion/behavioral-contracts/` and mapping each
new VP ID to its owning file. **v1.1 added VP-SKILL-064 (ADV-F2-008) and VP-SKILL-065
(ADV-F2-019). v1.2 added VP-SKILL-066/067/068 + VP-HOOK-027 + SM-26/27/28. v1.3 (this edit)
re-verified occupancy independently against the LIVE BCs by `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'`
across every BC — max in-BC `VP-SKILL` = 070 (BC-5.01.001 references VP-SKILL-069 PROPOSED;
BC-4.05.001 references VP-SKILL-070 PROPOSED), max `VP-HOOK` = 027, `SM` catalog max = 28. v1.3
FINALIZES the two already-PROPOSED ids (VP-SKILL-069 in BC-5.01.001, VP-SKILL-070 in BC-4.05.001 —
exactly as the BCs cite them) and appends VP-SKILL-071 (next free 071, confirmed absent repo-wide
outside architecture-delta) + VP-HOOK-028 (next free 028, confirmed absent repo-wide) + SM-29/30.
VP-SKILL is now occupied 001–071, VP-HOOK 024–028, SM 9–30; ZERO collisions confirmed
independently.**

**v1.5 (this edit) re-verified occupancy independently against the LIVE pass-4 BCs by
`grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` across every BC — max in-BC `VP-SKILL` = 071, max
`VP-HOOK` = 028, `SM` catalog max = 30. `VP-SKILL-072`, `VP-HOOK-029`, and `SM-31..SM-35` are
confirmed absent from every BC (VP-HOOK-029 appears ONLY as a `(proposed)` forward-reference in
architecture-delta.md v1.6 §8.11 item 6 — no owning BC yet). v1.5 appends the next-free ids
**VP-HOOK-029** (P1 fail-loud, D-DEC-012) + **VP-SKILL-072** (first-run 24h lookback, BC-10.01.001
Inv#13) + **SM-31..SM-35**. VP-SKILL is now occupied 001–072, VP-HOOK 024–029, SM 9–35; ZERO
collisions confirmed independently:**

| VP ID | Owning BC(s) | Pre-existing collision? | Verdict |
|-------|--------------|-------------------------|---------|
| VP-SKILL-050 | BC-10.01.001 | none (max pre-F1 = 049) | FINALIZED |
| VP-SKILL-051 | BC-6.01.001 | none | FINALIZED |
| VP-SKILL-052 / 053 | BC-6.01.003 | none | ACCEPTED |
| VP-SKILL-054 / 055 | BC-6.01.004 | none | ACCEPTED |
| VP-SKILL-056 / 057 | BC-8.02.001 | none | ACCEPTED |
| VP-SKILL-058 / 059 | BC-9.01.001 | none | ACCEPTED |
| VP-SKILL-060 / 061 / 062 / 063 | BC-10.01.001 | none | ACCEPTED |
| **VP-SKILL-064** *(NEW v1.1)* | BC-10.01.001 (Inv#1 — PROPOSED, ADV-F2-008) | none (max prior = 063) | **FINALIZED** (org_slug scoping) |
| **VP-SKILL-065** *(NEW v1.1; RE-SCOPED v1.9)* | BC-10.01.001 (Inv#11 — process-gap, ADV-F2-019; carve-out ADV-F2-P6-003) | none (next free = 065) | **RE-SCOPED — PROPOSED** (autonomy_enabled kill switch, narrowed v1.9 to zero REGULAR jr writes; create-review/comment-review escalation writes for genuine hard-floor verdicts EXEMPT per D-DEC-012 Option A via the kill-switch-exempt STEP 3 correct-label review path — carve-out UNCHANGED at v1.10, the regular-vs-review distinction is unaffected by the STEP-4 deny-the-Write redesign; PROPOSED pending vector-set adjudication in F6) |
| **VP-SKILL-066** *(NEW v1.2)* | BC-4.02.001 (Inv#4 — ADV-F2-P2-009a) | none (max prior = 065) | **FINALIZED** (never-auto-reopen on the update-jira path) |
| **VP-SKILL-067** *(NEW v1.2)* | BC-4.02.001 (Inv#5 — ADV-F2-P2-009b) | none | **FINALIZED** (SLA surface-never-assume) |
| **VP-SKILL-068** *(NEW v1.2)* | BC-10.01.001 (Inv#8 dedup / D-DEC-002 — ADV-F2-P2-009c) | none (next free = 068) | **FINALIZED** (grace-window + Jira-first dedup) |
| **VP-SKILL-069** *(NEW v1.3)* | BC-5.01.001 (Inv#8 — ADV-F2-P3-004); already PROPOSED-referenced in BC-5.01.001 v1.8 | none (BC cites this exact id) | **FINALIZED** (investigate-event PrismQL org_slug scoping) |
| **VP-SKILL-070** *(NEW v1.3)* | BC-4.05.001 (Inv#4 — ADV-F2-P3-004); already PROPOSED-referenced in BC-4.05.001 v1.3 | none (BC cites this exact id) | **FINALIZED** (assess-priority PrismQL org_slug scoping) |
| **VP-SKILL-071** *(NEW v1.3)* | BC-4.05.001 (PC#6 / D-DEC-011 — ADV-F2-P3-008) | none (next free = 071) | **FINALIZED** (assess-priority confidence float→enum consistency) |
| **VP-HOOK-028** *(NEW v1.3)* | BC-10.01.001 (Stage-7 verdict-path PC#8 — ADV-F2-P3-005); enforced by BC-3.03.001 (fast-path) + BC-3.01.001 (consume) | none (max prior = 027) | **FINALIZED** (verdict-path reachability) |
| **VP-HOOK-027** *(NEW v1.2)* | BC-10.01.001 (Inv#14 — ADV-F2-P2-001/P2-014); enforced by BC-3.03.001 (emit) + BC-3.01.001 (consume) | none (max prior = 026) | **FINALIZED** (P1 cross-hook stage-order document-before-action) |
| **VP-SKILL-072** *(NEW v1.5)* | BC-10.01.001 (Inv#13 first-run 24h lookback / D-DEC-002 — ADV-F2-P4-012) | none (next free = 072) | **FINALIZED** (first-run 24h lookback correctness; distinct from VP-SKILL-050 monotonicity) |
| **VP-SKILL-073** *(NEW v1.9)* | BC-10.01.001 (Stage-1 late-event fail-loud / D-DEC-002 — ADV-F2-P6-007); architecture-delta body §660/§3541 already commit this exact id | none (next free = 073) | **PROPOSED** (late-event drop detection: `_time < watermark − GRACE` → `LATE_EVENT_DETECTED` audit, event still processed) |
| **VP-SKILL-074** *(NEW v1.9)* | BC-10.01.001 (Stage-1/Stage-5 severity normalization / D-DEC-013 — ADV-F2-P6-005) | **none — NAMESPACE CORRECTION:** architect §8.15 item 3 proposed "VP-SKILL-072", but 072 is OCCUPIED (first-run 24h lookback); next free after 073 = **074** | **PROPOSED** (severity normalization correctness; NORMALIZE_SEVERITY per sensor family) |
| **VP-HOOK-029** *(NEW v1.5; RE-SCOPED v1.8/v1.9/**v1.10**; **re-FINALIZED v1.10**)* | BC-10.01.001 (D-DEC-012 fail-loud, Inv#10 narrowed + **STEP 4 DENY-THE-WRITE** — ADV-F2-P5-001/P6-002/**P7-001/P7-004**); enforced by BC-3.03.001 (STEP 4 deny + UNDER-LABEL-DENIED audit) + BC-3.01.001 (consume create-review/comment-review at STEP 6a — the CONSUMER-BOUNDARY authorization outcome) | none (max prior = 028; re-scope, not new ID) | **FINALIZED** (P0 end-to-end **consumer-boundary** fail-loud invariant per the O4 standing rule; lifecycle re-marked PROPOSED then re-FINALIZED v1.10 pending the deny-path vector set — architecture-delta §8.17 item 1 / P7-001/P7-004; the v1.9 STEP-4 upgrade-marker vectors are RETIRED) |
| VP-HOOK-024 | BC-3.01.001 | none (max pre-F1 = 023) | FINALIZED (ticket-bound + create/assign scopes, schema v2.0, iterative-consume; **v1.5: create-pattern injection-safety**) |
| VP-HOOK-025 | BC-10.01.001 (defines) + BC-3.03.001 (enforces) | none — shared reference, not a duplicate assignment | FINALIZED (15 fields; **v1.5: validate_enums() membership legs**) |
| VP-HOOK-026 | BC-10.01.001 | none | FINALIZED (hard-floor keyed on severity/asset_type; **v1.5: create-review/comment-review + kill-switch exemptions, autonomy_enabled determinism**; **v1.8: STEP 3 exemption GATED on hard_floor_applies() + over-label legs, SM-32b**) |
| VP-HOOK-028 | BC-10.01.001 (Stage-7 PC#8) + BC-3.03.001 (dispatch) | none | FINALIZED (verdict-path reachability; **v1.5: JSON-first canonical-path dispatch**) |

**v1.9 (this edit) re-verified occupancy independently against the LIVE pass-6 BCs and the
architecture-delta v1.9 body by `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` and `grep -rhoE 'SM-[0-9]+'`
across `.factory/`. Two collisions in the architect's §8.15 proposal were caught and corrected —
the FV owns the VP/SM namespace and must never collide:**
1. **Severity normalization — architect §8.15 item 3 said "VP-SKILL-072", but VP-SKILL-072 is
   OCCUPIED** (first-run 24h lookback, FINALIZED v1.5 / BC-10.01.001 v1.9 Inv#13). The architect's
   own body (§660, §3541) commits **VP-SKILL-073** to late-event detection, so severity normalization
   takes the next free id **VP-SKILL-074**. Late-event detection stays **VP-SKILL-073** (as the
   architecture body already cites). Correction noted; no existing VP disturbed.
2. **Consumer anti-fungibility mutants — architect §8.15 item 5 (and the same-named consumer mutants)
   said "SM-33"/"SM-34", but SM-33 (autonomy_enabled-clause-removed) and SM-34 (dispatch-order-inverted)
   are OCCUPIED pass-4 sentinels** (killed by VP-HOOK-026 / VP-HOOK-028 respectively). The consumer
   STEP 6a anti-fungibility mutants take the next free ids **SM-36** (remove the review-label check for
   review markers) and **SM-37** (remove the reverse check for regular markers). **SM-32-ext**
   (revert the STEP 4/5 ordering) is a safe SM-32-family sub-variant (no top-level collision).
VP-SKILL is now occupied 001–074, VP-HOOK 024–029, SM 9–37 (SM-32 = 32a+32b+32-ext); ZERO collisions
confirmed independently.

**v1.10 (this edit — pass-7) re-verified occupancy independently before allocating any new SM id
(Lesson 8): `grep -rhoE 'SM-[0-9]+' .factory/` returns max real = SM-37 (SM-2026 is a DATE false-positive
inside BC-6.01.001 frontmatter, not a mutant), and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` returns
VP-SKILL max 074, VP-HOOK max 029. The architect's §8.17 placeholders SM-NEW-A / SM-NEW-B take the next
free ids **SM-38 / SM-39**; the step-6a paired mutant takes **SM-40**. No new VP id is minted (VP-HOOK-029
re-scoped in place; VP-HOOK-024 / VP-SKILL-074 extended). SM is now occupied 9–40 (SM-32 = 32a+32b+32-ext;
SM-32a re-targeted, SM-32-ext kill vector re-worded — neither changes the id set); VP-SKILL 001–074,
VP-HOOK 024–029. ZERO collisions confirmed independently.**

**Result: ZERO namespace collisions. No renumbering required (v1.9's two architect-proposed IDs were
corrected to free slots — VP-SKILL-072→074, SM-33/34→36/37; v1.10's SM-NEW-A/B → SM-38/39, step-6a
mutant → SM-40, all next-free).** Each VP-SKILL-050..074 and VP-HOOK-024..029 appears in exactly one
*owning* BC.

**VP-HOOK-029 namespace justification (VP-HOOK vs VP-SKILL — pass 4; scope corrected pass-5/6; end-to-end re-scope + re-FINALIZED pass-7).**
The fail-loud invariant's ENFORCEMENT surface (the ALLOW/DENY decision and the marker store) is
hook-side, so the property stays in **VP-HOOK**; but per the **O4 standing rule (§0)** its *assertion*
is now the CONSUMER-BOUNDARY outcome, not an emitter-local artifact. For a hard-floor / Indeterminate /
silent-sensor verdict, VP-HOOK-029 asserts exactly one of two consumer-observable terminal states —
(i) **review path:** the verdict carries a `create-review`/`comment-review` token, STEP 3 issues the
restricted marker, AND a correctly-labeled `jr` write is authorized and consumable at consumer STEP 6a
(the human-surface jr write actually occurs); or (ii) **deny path:** the verdict carries a NON-review
token, STEP 4 **DENIES the verdict Write** with a structured corrective reason (`hard_floor_trigger`,
`required_token`, `label_instruction`, `instruction`) + an **UNDER-LABEL-DENIED** audit entry, NO
marker is issued, and on the loop's corrected re-document (with the required review token) path (i)
fires. It NEVER leaves an unconsumable marker in the store, and NEVER a silent allow-without-marker.
**Pass-7 redesign (ADV-F2-P7-001 CRITICAL / P7-004 MAJOR):** the pass-5/6 STEP-4 marker-*upgrade*
mechanism is RETIRED — P7-001 proved disposition-guard can rewrite the marker but not the loop's
future Bash command, so the upgraded `create-review` marker was structurally unconsumable by the
loop's own non-review `jr` command (3 of 4 under-label action types silently dropped the finding).
DENY-AT-WRITE is the only deterministic lever at the point the LLM can still react. STEP 4 still runs
**before the STEP 5 kill switch**, so the deny fires regardless of `autonomy_enabled` (the
kill-switch-irrelevance assertion). The old emitter-only VP-HOOK-029 assertion ("a marker exists OR an
error artifact was written") could NOT detect the unconsumable-marker seam gap (P7-004) — the re-scope
per architecture-delta §8.17 item 1 asserts the downstream jr authorization/execution instead.
BC-10.01.001 Inv#10 (narrowed so hard floors surface via a correctly-labeled review token, and STEP 4
deny-the-Writes under-labeled hard-floor verdicts) is the authoritative *definition*; BC-3.03.001
(STEP 4 deny + UNDER-LABEL-DENIED audit) + BC-3.01.001 v1.19 (consume create-review/comment-review at
step 6/6a) are the *enforcement* surfaces. VP-HOOK-029 lifecycle: re-marked **PROPOSED** pending the
deny-path vector set, then **re-FINALIZED (P0) v1.10**. **VP-SKILL-072
ownership.** First-run 24h lookback (BC-10.01.001 Inv#13 / EC-001) is a monitoring-loop
query-construction property — the loop, on an absent watermark file, MUST issue
`WHERE _time >= now() - INTERVAL 24 HOURS` and MUST NOT scan full sensor history — so it belongs
in **VP-SKILL**. It is distinct from VP-SKILL-050 (watermark *monotonicity* + future-timestamp
rejection): VP-SKILL-050's incidental "first-run = 24h lookback" mention is subsumed and now
carries an explicit cross-reference to the dedicated VP-SKILL-072 (no double-allocation — 050
proves post ≥ pre on an *existing* watermark; 072 proves the *absent-watermark* lookback bound
and post-run persistence).

**VP-SKILL-069/070/071 ownership (pass 3).** VP-SKILL-069 owns to **BC-5.01.001** (investigate-event
Invariant #8 — Stage-3 OCSF lookup + temporal-adjacency PrismQL always carry an `org_slug` WHERE
clause) and VP-SKILL-070 owns to **BC-4.05.001** (assess-priority Invariant #4 — PC#5a/5b/5d PrismQL
paths always carry `org_slug`). These are the two PrismQL surfaces the adversary flagged (ADV-F2-P3-004)
as uncovered by VP-SKILL-064 (monitoring-loop-only) and VP-SKILL-059 (scan-threats-only); each BC
already lists its VP as PROPOSED with a matching BATS test-name pair, so finalization is a scope
confirmation, not a new assignment. VP-SKILL-071 owns to **BC-4.05.001** (PC#6 / D-DEC-011 — the
`confidence_score` float → `confidence` enum mapping fidelity at the 0.75/0.40 thresholds); it is
orthogonal to VP-SKILL-070 (query scoping) — no overlap. **VP-HOOK-028 namespace justification
(VP-HOOK vs VP-SKILL).** Like VP-HOOK-025/027, the verdict-path-reachability property's ALLOW/DENY
verdict is produced entirely hook-side: disposition-guard fast-path-allows a Write whose path lacks
the `verdict` substring (emitting NO marker), and require-review then DENIES the downstream Stage-8
`jr` Bash (no marker to consume). The monitoring-loop SKILL merely chooses the write path; the
enforcement surface is 100% hook-side, so the property belongs in **VP-HOOK**. BC-10.01.001 Stage-7
PC#8 (verdict-path naming convention) is the authoritative *definition*; BC-3.03.001 (fast-path) +
BC-3.01.001 (consume) are the *enforcement* surfaces.

**VP-HOOK-027 namespace justification (VP-HOOK vs VP-SKILL — pick and justify per task item 1).**
The stage-order document-before-action property is realized *entirely by the two PreToolUse
hooks*: disposition-guard (the emitter — must fire on the Stage 7 verdict Write and drop a
marker) and require-review (the consumer — DENIES the Stage 8 `jr` Bash call when no preceding
marker exists). The ALLOW/DENY verdict under test is produced by the hooks, not by any
skill-internal branch; the monitoring-loop SKILL merely orders the two tool calls. Because the
enforcement surface is 100% hook-side (identical to the VP-HOOK-024/025/026 marker family), the
property belongs in the **VP-HOOK** namespace, not VP-SKILL. This mirrors the VP-HOOK-025
define/enforce pattern: BC-10.01.001 Invariant #14 is the authoritative *definition* of the
ordering; BC-3.03.001 (emit) + BC-3.01.001 (consume) are the *enforcement* surfaces. It is
tagged **P1** per architecture-delta §8.7 item 1.

**VP-SKILL-066/067 own to BC-4.02.001** (update-jira, distinct from the monitoring-loop path
that VP-SKILL-062 covers): Invariant #4 (never-auto-reopen) and Invariant #5 (SLA surface) are
update-jira-skill invariants with no prior VP anchor (BC-4.02.001's VP table currently lists only
VP-SKILL-006/007/008 — see §7). **VP-SKILL-068 owns to BC-10.01.001** at the dedup/grace-window
invariant (Inv#8 / D-DEC-002) — orthogonal to VP-SKILL-050 (watermark monotonicity only), no
overlap. **VP-SKILL-064 and VP-SKILL-065 both
own to BC-10.01.001** (Invariant #1 and Invariant #11 respectively) — distinct invariants,
distinct properties, no overlap with the existing 050/060–063 monitoring-loop VPs. VP-HOOK-025
legitimately appears in two BCs because BC-10.01.001 Invariant #9 is the authoritative
field-list definition and BC-3.03.001 (disposition-guard) is the enforcement surface — this is
a define/enforce pair, not a double-allocation. The pre-F1 BCs (BC-3.02/3.04/3.05/3.06,
BC-4.01/4.03/4.04/4.06, BC-6.01.002, BC-7.01.001, BC-8.01.001) top out at VP-SKILL-049 /
VP-HOOK-023 with no overlap into the 050+/024+ ranges.

**Adjudication of the 12 proposed VPs (052–063): ALL FINALIZED.** They are well-formed, each
maps to a stated invariant in its owning BC, and each has a testable BATS strategy. No scope
overlap, no duplication of an existing VP's property. The `(PROPOSED)` qualifier has been
dropped by the product-owner in the BCs (first landed BC-10.01.001 v1.2 §Revision, BC-3.03.001
v1.8, BC-3.01.001 v1.13; current LIVE versions BC-10.01.001 v1.9, BC-3.03.001 v1.13, BC-3.01.001
v1.17); confirmed applied — see §7.

---

## 2. Finalized VP Table

Strategy legend: **B-BEH** = BATS behavioral (hook exercised via stdin JSON envelope, assert
`permissionDecision` / marker-store side effect); **B-STR** = BATS structural-presence (assert
SKILL.md/dir/command text or filesystem shape); **B-INT** = BATS integration (jr-mock and/or
prism-DTU-demo-server backed, `--config-dir <tmpdir>` isolated); **B-INT-XH** = cross-hook
integration (two sequential subprocess hook invocations sharing `CLAUDE_PLUGIN_DATA`).

| VP ID | Name / Property | Strategy | Test surface | BC anchor |
|-------|-----------------|----------|--------------|-----------|
| VP-HOOK-024 | Marker-validation soundness (schema v2.0, **iterative-consume**): write-block-matched command WITH a valid, unexpired (`now() > expires_at_utc` absolute check; 120s TTL), single-use, correctly-scoped, **ticket-bound** (`command_pattern` anchored to `<ticket_id> ` for comment/assign; operation-scoped for create), non-path-traversal marker → allow; candidates **sorted by `issued_at_utc` ASC (oldest first); the first candidate whose atomic `mv → .used` rename SUCCEEDS → allow; if every rename fails (all consumed by a concurrent invocation) → deny (fail-closed exhaustion)**; **rename-fail on a lone candidate → continue/deny (fail-closed)**; audit line appended with **base64-encoded** command to `${CLAUDE_PLUGIN_DATA}/markers/audit.log`; replay of a consumed marker → deny. Covers comment/create/assign scoped allow-paths. Replaces the retired ">1-candidate → ambiguous deny" gate (architecture-delta §D-DEC-001 v1.3 / ADV-F2-P2-003). **v1.9 (ADV-F2-P6-001 CRITICAL): consumer STEP 6a anti-fungibility cross-check — review markers (`["create-review"]`) and regular markers (`["create"]`) are NOT fungible in either direction: a `["create-review"]` marker only authorizes a command carrying `--label REVIEW-REQUIRED\|BLIND-SPOT`, and a `["create"]` marker is refused for any command carrying a review label (EC-023). This is the hook-side (deterministic) enforcement of the review/regular distinction that D-DEC-012's Alternatives-Rejected reversal now ADOPTS — it is a security control that cannot live only in the untrusted SKILL.md Iron Law.** **v1.5 (ADV-F2-P4-002 CRITICAL): create `command_pattern` injection-safety — the create pattern is anchored `^jr (--output json )?issue create --project <key>( \|$)` with `--project` as the FIRST flag (no `.*` before it) and a trailing `( \|$)` boundary; an attacker-influenceable `--summary` value carrying a `--project ORG_A` substring does NOT match an ORG_A-scoped create marker; a `--project PROD` marker does NOT authorize `--project PRODUCTION` (prefix guard). v1.5 (ADV-F2-P4-010): audit line strips control chars (`tr -d '\000-\037'`) from `ticket_id`/`org_slug`/`op` before interpolation — a `\n` in `ticket_id` cannot forge a second MARKER_USED line.** | B-BEH + B-INT-XH | require-review.sh stdin envelope `{tool_input.command}`; `CLAUDE_PLUGIN_DATA=$(mktemp -d)`; assert `.used` rename + `markers/audit.log` `command_b64=` line; ticket-bound vector (SEC-123 marker → DENY SEC-456); create/assign scoped allow vectors; **concurrent same-scope: two valid markers → oldest consumed, ALLOW; all-renames-fail → exhausted DENY**; **v1.5 injection vectors: marker `command_pattern="^jr (--output json )?issue create --project ORG_A( \|$)"` + command `jr issue create --summary "review --project ORG_A" --project ORG_B` → DENY; `--project PROD` marker + `--project PRODUCTION` command → DENY; v1.5 audit: `ticket_id` containing `$'\n'` → single MARKER_USED line only (control chars stripped).** **v1.9 consumer STEP 6a anti-fungibility (ADV-F2-P6-001 CRITICAL, EC-023): a `["create-review"]` marker + `jr issue create --project ORG_A` WITHOUT `--label REVIEW-REQUIRED\|BLIND-SPOT` → NOT consumed, DENY (named vector `create-review-marker-requires-review-label`, kills SM-36); a `["create"]` marker + `jr issue create --project ORG_A --label REVIEW-REQUIRED …` (carries a review label) → NOT consumed, DENY (named vector `create-marker-rejects-review-label`, kills SM-37); correct pairings — `["create-review"]` marker + `--label BLIND-SPOT` command → consumed ALLOW, and `["create"]` marker + no-label command → consumed ALLOW. `has_review_label` is a structural property of the command, not Jira content; comment/comment-review structural `--label` check pends ASM-014 (current comment-review guard = ticket_id binding + Iron Law).** **v1.10 STEP 6a structural-check false-deny prevention (ADV-F2-P7-005 MINOR, D-DEC-001 `structural_label_check`): `has_review_label` is a STRUCTURAL token check (`--label` must appear as a standalone whitespace-separated token immediately preceding `REVIEW-REQUIRED`/`BLIND-SPOT`), NOT a raw substring over the whole command — so a legitimate REGULAR create whose LLM/attacker-influenceable `--summary` merely CONTAINS the literal string is NOT false-denied. Named vector `regular-create-with-label-literal-in-summary-allowed`: a `["create"]` marker + `jr issue create --project PRISM-DEMO --summary "rule matched literal --label REVIEW-REQUIRED in payload"` (passes step-5's anchored regular-create pattern, and step-6a's structural check finds NO standalone `--label` token) → **ALLOW** (consumed; not a false-deny). Fail-closed security is unaffected — the anchored step-5 `command_pattern` remains the real structural gate; step-6a only prevented false-denies. Paired mutant **SM-40** (revert `has_review_label` to the raw-substring check) → the vector DENYs and the mutant dies.** | BC-3.01.001 (v1.19) |
| VP-HOOK-025 | ICD-203 completeness (**dual-path, artifact-class field-set branching — D-DEC-008-C**): disposition-guard branches the required field-set by artifact class — **investigation markdown = 12 ICD-203 fields** (heading-anchored `grep`; Severity/Asset Type/Ticket Action Type are NOT required and their presence must NOT trigger a wrong-class deny) vs **verdict JSON = 15 fields** (12 ICD-203 + **severity[13], asset_type[14], ticket_action_type[15]**) via `jq has()` key-presence + per-field type check; enforces tuning_signal null-vs-absent semantics; severity-based hard-floor legs; **field#2 confidence is enum-only (D-DEC-011): a float `confidence` value is DENIED, the enum values {high,medium,low} are ALLOWED** (ADV-F2-P3-008). **v1.5 (ADV-F2-P4-006 MAJOR): `validate_enums()` membership gate runs BEFORE the hard-floor check and fail-closed-DENIES any non-member / wrong-case value on ALL typed fields — `severity∈{LOW,MEDIUM,HIGH,CRITICAL}`, `asset_type∈{domain_controller,privileged_account,ot_safety_system,standard,unknown}`, `disposition∈{TP,FP,BTP,Indeterminate}`, `sensor_health_status∈{healthy,degraded,silent}`, `ticket_action_type∈{comment,create,assign,none,create-review,comment-review}`, `confidence∈{high,medium,low}`. A case-mangled `severity:"High"` is DENIED (NOT allowed-without-marker), closing the hard-floor bypass where key-presence passed but membership silently failed.** | B-BEH | disposition-guard.sh stdin `{tool_input.file_path, content}`; **investigation-markdown 12-field fixture (all 12 headings → allow; missing any of 12 → deny; a spurious Severity heading added → still allow, no wrong-class 15-field deny)**; **verdict-JSON 15-field fixture (missing any of 15 → deny)**; **confidence float→deny + confidence∈{high,medium,low}→allow legs**; **v1.5 enum-membership legs: `severity="High"`→DENY, `severity="CRITICAL"`→allow (other fields OK), `asset_type="Unknown"`→DENY, `disposition="indeterminate"`→DENY, `sensor_health_status="Degraded"`→DENY, `ticket_action_type="NONE"`→DENY (fail-closed, before hard floor)** | BC-3.03.001 (v1.16) PC#1/2/3 (JSON-first; 12 markdown / 15 JSON + validate_enums) / BC-10.01.001 (v1.12) Inv#9 |
| VP-HOOK-026 | Indeterminate / hard-floor non-overridability: no autonomy configuration (`autonomy_enabled`, `require_review`, auto-scope) can cause a hard-floor category (Indeterminate / **verdict.severity∈{HIGH,CRITICAL}** / **verdict.asset_type∈CRITICAL_ASSET_TYPES** / **verdict.asset_type=='unknown'** / T1003·T1068·T1021·T1041 / degraded-silent sensor) to receive a **REGULAR (comment/create/assign-scoped, autonomous-triage) marker**; **[UPDATED v1.8/v1.9/v1.10 — fail-loud on under-label, now STEP 4 DENY-THE-WRITE (before the STEP 5 kill switch), ADV-F2-P5-001/P6-002/P7-001]** a hard-floor category is surfaced ONLY via a `create-review`/`comment-review` REVIEW marker (STEP 3 correct-label; an under-labeled hard-floor verdict is **denied at STEP 4** with a corrective reason so the loop re-documents with a review token — owned by **VP-HOOK-029**) or the STEP-4 deny+audit; it is NEVER left silently empty and NEVER receives a regular comment/create/assign marker; hard floor keys on **severity/asset_type NOT confidence** (ADV-F2-001); **the `unknown` asset_type is a conservative hard-floor member (ADV-F2-P3-001): a LOW-severity + benign-technique + `asset_type=unknown` verdict NEVER gets a REGULAR marker regardless of `autonomy_enabled`**; loop always routes to human. **v1.5 (D-DEC-012 / ADV-F2-P4-004): the `create-review`/`comment-review` review-surfacing marker types are EXEMPT from the hard-floor no-marker rule AND from the autonomy_enabled kill switch (escalation ≠ autonomous triage) — a hard-floor (e.g. HIGH-severity / Indeterminate / silent-sensor) verdict with `ticket_action_type=create-review` DOES get a restricted marker (`authorized_operations:["create-review"]`); the same under `autonomy_enabled=false` still emits the review marker. **v1.8 (ADV-F2-P5-002 MAJOR — OVER-LABEL GATE): the STEP 3 review-marker exemption is GATED on the hook-computed predicate `hard_floor_applies(verdict)=TRUE` (`IF NOT hard_floor_applies(): emit allow WITHOUT marker; RETURN`). An LLM-supplied `create-review`/`comment-review` token on a verdict where `hard_floor_applies()` returns FALSE (e.g. disposition=TP, LOW severity, standard asset) does NOT receive the kill-switch / hard-floor exemption — it emits allow-without-marker (the document write proceeds; require-review denies the downstream `jr` action because no marker is in the store). This closes the P5-002 bypass where the LLM could manufacture a kill-switch bypass by over-labeling a regular verdict as a review action. O3 standing rule: the LLM-supplied `ticket_action_type` is cross-validated against `hard_floor_applies()` before the exemption fires.** v1.5 (ADV-F2-P4-005): the kill switch is read DIRECTLY by disposition-guard from the verdict's `autonomy_enabled` operational field (not delegated to the loop LLM) — `autonomy_enabled≠true` (false OR absent → conservative false) suppresses ALL REGULAR markers (comment/create/assign) while leaving GENUINELY-hard-floor review-surfacing markers untouched.** | B-BEH + B-INT-XH | disposition-guard.sh with hard-floor verdict + `autonomy_enabled=true` injected via envelope; inject **verdict.severity=HIGH**, **verdict.asset_type=critical-asset** (domain_controller), and **verdict.asset_type=unknown with severity=LOW + benign technique** → **[UPDATED v1.8]** assert NO regular (comment/create/assign-scoped) marker is written on any hard-floor leg — i.e. no marker with `authorized_operations ∈ {comment,create,assign}` (an under-labeled hard-floor verdict is instead **denied at STEP 4** with a corrective reason + UNDER-LABEL-DENIED audit; that fail-loud outcome is owned by **VP-HOOK-029** — VP-HOOK-026 asserts the ABSENCE of the autonomous-triage marker, NOT an empty store); **v1.5 review-surfacing legs (hard-floor EXEMPT — hard_floor_applies()=TRUE): Indeterminate + `create-review` → restricted marker emitted with `authorized_operations=["create-review"]`; silent-sensor + `comment-review` → restricted marker emitted; HIGH-severity + `create-review` → marker emitted; `autonomy_enabled=false` + `create-review` → marker STILL emitted (kill-switch EXEMPT); v1.8 OVER-LABEL legs (hard_floor_applies()=FALSE — paired mutant SM-32b): non-hard-floor TP verdict (LOW severity, standard asset) + `create-review` token → NO marker (allow-without-marker; over-label rejected); non-hard-floor FP verdict + `comment-review` + `autonomy_enabled=false` → NO marker (no kill-switch bypass); LOW-severity standard asset + `create-review` → NO marker (verify hard_floor_applies()=false path); v1.5 kill-switch legs: `autonomy_enabled=false` + regular `create` → NO marker; `+ comment` → NO marker; `autonomy_enabled` ABSENT + regular create → treated false → NO marker** | BC-10.01.001 (v1.12 Inv#10/§3.9); BC-3.03.001 (v1.16 Inv#4, STEP 3 gate) |
| **VP-HOOK-027** *(NEW v1.2, **P1**)* | **Stage-order document-before-action (ADV-F2-P2-001/P2-014):** a monitoring-loop `jr issue comment/create/assign` (Stage 8 TICKET ACTION) is **DENIED** by require-review unless a verdict-record Write for the SAME run/verdict (Stage 7 DOCUMENT) — which caused disposition-guard to emit a matching scoped marker — preceded it within the marker TTL (120s). Proves the D-DEC-008 ordering invariant is enforced end-to-end: Stage 7 DOCUMENT must precede Stage 8 TICKET ACTION, or the loop can never auto-action (the ADV-F2-P2-001 CRITICAL failure mode). | B-INT-XH | Positive: (1) disposition-guard.sh on a valid non-hard-floor verdict Write → assert marker emitted in `${CLAUDE_PLUGIN_DATA}/markers/`; (2) require-review.sh on the matching `jr` Bash → assert **allow** + marker consumed. Negative: require-review.sh on the same `jr` Bash with **NO preceding verdict Write** (empty marker dir) → assert **deny**. TTL-expiry leg: verdict Write, wait past 120s, jr Bash → deny. Same shared `CLAUDE_PLUGIN_DATA=$(mktemp -d)` env across the two subprocess hooks (ASM-009 condition). | BC-10.01.001 (v1.12 Inv#14, D-DEC-008); enforced by BC-3.03.001 (v1.16 emit) + BC-3.01.001 (v1.19 consume) |
| VP-SKILL-050 | Watermark monotonicity: per org×sensor watermark write is always ≥ previous persisted value; loop never re-processes a consumed window on restart; future timestamp rejected. *(First-run 24h lookback is covered by the dedicated **VP-SKILL-072** as of v1.5 — this row proves post ≥ pre on an EXISTING watermark only.)* | B-INT | Inject pre-existing watermark file under `CLAUDE_PLUGIN_DATA/watermarks/<org>/<sensor>`; run loop stub; assert post ≥ pre | BC-10.01.001 (Inv#4, D-DEC-002) |
| VP-SKILL-051 | Prism version gate: `prism --version` parsed and compared to `1.0.0-rc.1`; below → halt with version-gate error, no MCP write; at/above → proceed to dual MCP write | B-INT | prism-version-check.sh with mocked `prism --version`; assert halt vs proceed + no settings write on halt | BC-6.01.001 (v1.5) |
| VP-SKILL-052 | onboard-customer UUID-v7 format validation; malformed UUID rejected with re-prompt | B-STR + B-INT | onboard-customer helper / SKILL.md; feed invalid UUID | BC-6.01.003 |
| VP-SKILL-053 | onboard-customer idempotent directory creation; re-run does not modify/delete existing `customers/<org_slug>/` | B-INT | mktemp spec dir; run twice; assert dir unchanged | BC-6.01.003 |
| VP-SKILL-054 | onboard-sensor AD-017 compliance: SKILL.md never requests credential paste in chat; only piped-stdin `echo \| prism credential set` documented | B-STR | grep SKILL.md for forbidden paste pattern; assert absent | BC-6.01.004 |
| VP-SKILL-055 | onboard-sensor SELECT 1 verification mandatory; success message gated AFTER the SELECT 1 step | B-STR | SKILL.md ordering assertion | BC-6.01.004 |
| VP-SKILL-056 | sensor-metrics per-org×sensor output completeness: each prism_sensor_health row yields org_slug, sensor_id, last_seen_ts, row_count, error_rate | B-INT | prism-DTU-demo-server rows; assert 5 fields per pair | BC-8.02.001 |
| VP-SKILL-057 | sensor-metrics naming compliance (D-DEC-006): dir `skills/sensor-metrics/`, cmd `commands/sensor-metrics.md`; no bare `metrics` alias | B-STR | filesystem presence + negative-presence | BC-8.02.001 |
| VP-SKILL-058 | scan-threats prism_describe-first invariant: SKILL.md documents table enumeration before any hunting query, per org | B-STR | SKILL.md step-ordering assertion | BC-9.01.001 |
| VP-SKILL-059 | scan-threats org_slug scoping: Iron Law / Red Flag documents that all PrismQL queries carry org_slug scope; cross-tenant query is a Red Flag | B-STR | SKILL.md content assertion | BC-9.01.001 |
| VP-SKILL-060 | Known-FP precedes enrichment: Stage 2 known-FP match → FP disposition with NO Stage 4 enrichment API call | B-INT | jr-mock + enrichment-call spy; assert zero Stage-4 calls | BC-10.01.001 |
| VP-SKILL-061 | Sensor silence is a positive finding: `last_seen_ts > 24h AND row_count == 0` → BLIND-SPOT finding; never empty output / never "nothing to report" | B-INT | prism-DTU silent-sensor fixture; assert BLIND-SPOT emitted | BC-10.01.001 |
| VP-SKILL-062 | Never-auto-reopen-closed: a Closed ticket for the same root cause never receives `jr issue reopen`; a NEW linked ticket is created | B-INT | jr-mock returning Closed ticket; assert create-new + link, no reopen verb | BC-10.01.001 |
| VP-SKILL-063 | Tavily degradation path: Tavily unavailable → set uncertainty_explicit, proceed Perplexity-only, do NOT abort, do NOT force Indeterminate | B-INT | Tavily-absent stub; assert loop continues, disposition not forced Indeterminate | BC-10.01.001 |
| **VP-SKILL-064** *(NEW v1.1)* | **monitoring-loop org_slug scoping (ADV-F2-008 — sole plugin-side cross-tenant isolation guarantee, D-DEC-005):** every loop-issued PrismQL query carries an `org_slug` constraint matching the current FOR-EACH org context; a query issued in org-a context NEVER returns org-b/c rows; the loop's query construction always injects `org_slug`; an unscoped query attempt is rejected/scoped by the loop | B-INT + B-STR | prism-DTU multi-org fixtures (org-a/b/c, `--config-dir <tmpdir>`): assert an org-a query returns zero org-b/c rows; **static/structural** grep that query construction always emits `org_slug`; **adversarial fixture** — attempt an unscoped query → must be rejected/scoped | BC-10.01.001 (v1.12 Inv#1, D-DEC-005) |
| **VP-SKILL-065** *(NEW v1.1; **RE-SCOPED v1.9**)* | **autonomy_enabled kill switch (ADV-F2-019, Inv#11; carve-out ADV-F2-P6-003):** **[RE-SCOPED v1.9 per D-DEC-012 Option A]** `autonomy_enabled=false` ⇒ ZERO **REGULAR** (comment/create/assign) markers consumed AND ZERO **REGULAR** `jr issue create/comment/assign` writes executed — BUT `create-review`/`comment-review` escalation markers/writes for GENUINE hard-floor verdicts STILL execute (they are kill-switch EXEMPT: the STEP 3 correct-label review path runs before the STEP 5 kill switch — a correctly-labeled hard-floor verdict issues the review marker directly; an under-labeled one is denied at STEP 4 so the loop re-documents with the review token). Evidence collection + verdict construction + Jira drafting still proceed (propose-only) for regular verdicts. The pre-Option-A "zero jr writes of ANY kind" scope contradicted EC-006/EC-014/D-DEC-012 (a silent-sensor/Indeterminate run WILL issue a `jr issue create` for the BLIND-SPOT/REVIEW-REQUIRED ticket under the kill switch) — re-scoped this pass, not silently FINALIZED. | B-INT | BATS integration with `autonomy_enabled=false` injected: **(regular)** non-hard-floor FP verdict → assert `CLAUDE_PLUGIN_DATA/markers/` has no consumed (`.used`) regular markers AND the jr-mock spy records ZERO `jr issue create/comment/assign` REGULAR (non-review) invocations; assert draft written to verdict file with `annotation=propose-only`; **(review-exempt)** silent-sensor (hard-floor) verdict → assert a `create-review` marker IS emitted and the jr-mock spy DOES record the `jr issue create … --label BLIND-SPOT` escalation write (kill-switch EXEMPT per Option A) | BC-10.01.001 (v1.12 Inv#11 carve-out, EC-006/EC-014/EC-020) |
| **VP-SKILL-066** *(NEW v1.2)* | **update-jira never-auto-reopen (ADV-F2-P2-009a — BC-4.02.001 Inv#4):** on the update-jira path, NO code path from the Closed (PC#7d) or Resolved (PC#7c) branch results in a `jr issue move` that transitions a ticket out of Closed/Resolved; Resolved → propose-only + halt; Closed → create-new + link. Holds regardless of `autonomy_enabled`. (VP-SKILL-062 covers only the monitoring-loop path — this is the distinct update-jira surface.) | B-INT + B-STR | jr-mock returning a Resolved ticket → assert propose-reopen message + halt + zero `jr issue move` reopen verbs (EC-007); jr-mock returning a Closed ticket → assert create-new + `jr issue link`, zero reopen (EC-008); **static** grep of `update-jira/SKILL.md` (+ any helper): no autonomous `jr issue move` out of Resolved/Closed | BC-4.02.001 (v1.8 Inv#4, §3.4 PC#7c/PC#7d) |
| **VP-SKILL-067** *(NEW v1.2)* | **SLA surface-never-assume (ADV-F2-P2-009b — BC-4.02.001 Inv#5):** append-comment (PC#7a), link-related (PC#7b), and propose-reopen (PC#7c) actions each emit an explicit SLA-impact statement before executing/proposing; when SLA data is not retrievable from `jr issue view` the statement reads "SLA: unknown — do not assume compliant"; the skill NEVER silently assumes SLA compliance | B-INT + B-STR | jr-mock ticket WITH an SLA deadline → assert output contains "SLA impact:" with the deadline; jr-mock ticket WITHOUT retrievable SLA → assert "SLA: unknown — do not assume compliant"; assert an append/link/propose path never omits the statement; **static** grep of `update-jira/SKILL.md` for the SLA-statement format | BC-4.02.001 (v1.8 Inv#5, §3.5) |
| **VP-SKILL-068** *(NEW v1.2)* | **grace-window + Jira-first dedup (ADV-F2-P2-009c — D-DEC-002 / BC-10.01.001 Inv#8):** a late/out-of-order OCSF event re-fetched inside the watermark grace window (`WATERMARK_GRACE_SECONDS`, default 300s) that already has an existing OPEN Jira ticket results in an append-COMMENT on that ticket (Jira-first dedup), NOT a new ticket; an in-grace event with NO existing ticket takes the normal create path. (VP-SKILL-050 remains watermark-monotonicity only.) | B-INT | prism-DTU seeds an event whose normalized `_time` falls in `[watermark − GRACE, watermark]`; jr-mock returns an existing open ticket for that event → assert `jr issue comment` (append) fired and `jr issue create` NOT fired; boundary leg: same event, jr-mock returns zero open tickets → assert create path; RFC3339 UTC-Z `_time` normalization applied before comparison | BC-10.01.001 (v1.12 Inv#8, D-DEC-002) |
| **VP-SKILL-069** *(NEW v1.3)* | **investigate-event PrismQL org_slug scoping (ADV-F2-P3-004 — BC-5.01.001 Inv#8):** every investigate-event PrismQL query — the Stage-3 raw OCSF event lookup and the ±5-minute temporal-adjacency query (BC-5.01.001 §3.8 PC#7 Stage 3) — always includes an explicit `org_slug='<org_slug>'` WHERE clause for the current org context (D-DEC-005); an unscoped query is rejected; a query issued in org-a context returns zero org-b/c rows. Distinct from VP-SKILL-064 (monitoring-loop-only) and VP-SKILL-059 (scan-threats-only). | B-STR + B-INT | **static** Iron-Law content assertion on `investigate-event/SKILL.md` (every PrismQL block carries `WHERE org_slug=`); prism-DTU multi-org fixture (org-a/b/c, `--config-dir <tmpdir>`) — org-a Stage-3 + temporal-adjacency queries return zero org-b/c rows; **adversarial** unscoped-query fixture → rejected/scoped | BC-5.01.001 (v1.8 Inv#8, PC#7 Stage 3, D-DEC-005) |
| **VP-SKILL-070** *(NEW v1.3)* | **assess-priority PrismQL org_slug scoping (ADV-F2-P3-004 — BC-4.05.001 Inv#4):** every assess-priority PrismQL query (PC#5a 30-day baseline, PC#5b NVD/ThreatIntel enrichment, PC#5d asset-criticality lookup) always includes an explicit `org_slug` WHERE clause (D-DEC-005); unscoped queries rejected; org-a query returns zero org-b/c rows. | B-STR + B-INT | **static** Iron-Law content assertion on `assess-priority/SKILL.md` PrismQL blocks (PC#5a/5b/5d each carry `WHERE org_slug=`); prism-DTU multi-org fixture — org-a query returns zero org-b/c rows; **adversarial** unscoped-query → rejected/scoped | BC-4.05.001 (v1.3 Inv#4, PC#5a/5b/5d, D-DEC-005) |
| **VP-SKILL-071** *(NEW v1.3)* | **assess-priority confidence float→enum consistency (ADV-F2-P3-008 — BC-4.05.001 PC#6 / D-DEC-011):** for every `confidence_score` float output, the paired `confidence` enum matches the D-DEC-011 canonical thresholds — `high` iff `confidence_score ≥ 0.75`, `medium` iff `0.40 ≤ confidence_score < 0.75`, `low` iff `confidence_score < 0.40`; an inconsistent pair (e.g. `confidence_score=0.85` with `confidence='low'`) is invalid; boundary values 0.75 and 0.40 map to the higher tier. This is the producer-side guarantee that the enum handed to verdict field #2 is well-formed before disposition-guard's enum type-assertion (VP-HOOK-025) sees it. | B-INT (boundary/property) | boundary fixtures at and around each threshold: `0.75→high`, `0.749→medium`, `0.40→medium`, `0.399→low`, `1.0→high`, `0.0→low`; assert emitted `confidence` enum matches; inconsistency fixture (`0.85`/`low`) → flagged invalid; enum is one of {high,medium,low} (never a float) | BC-4.05.001 (v1.3 PC#6, D-DEC-011) |
| **VP-HOOK-028** *(NEW v1.3)* | **verdict-path reachability (ADV-F2-P3-005):** a monitoring-loop Stage-7 verdict Write to a path NOT containing the `verdict` substring causes disposition-guard to **fast-path-allow WITHOUT ICD-203 validation and WITHOUT marker issuance**; consequently the downstream Stage-8 `jr` write is **DENIED** by require-review (no marker to consume). Proves the load-bearing verdict-file-path naming convention (BC-10.01.001 Stage-7 PC#8) is enforced end-to-end: a mis-named verdict path is fail-closed (denies the action), never fail-open. **v1.5 (ADV-F2-P4-001 CRITICAL — JSON-first dispatch): the canonical verdict path `artifacts/investigations/verdict-<id>-<iso_ts>.json` contains BOTH the `investigation` and `verdict` substrings; dispatch MUST be JSON-first — a file ending in `.json` OR whose content parses as JSON (`jq empty`) routes to the verdict-class 15-field path REGARDLESS of any `investigation` substring; ONLY a `*investigation-*.md` file routes to the 12-field markdown path. Without this precedence the canonical verdict JSON is misrouted to the heading-grep branch, fails all `## `-heading assertions, is DENIED, emits no marker, and the entire autonomous pipeline is unreachable.** | B-INT-XH | Negative: disposition-guard.sh on a Write to `artifacts/findings/alert-001.json` (no `verdict` substring) → assert marker-store dir stays EMPTY; then require-review.sh on the matching `jr` Bash → assert **deny**. Positive control: same content written to `artifacts/investigations/verdict-alert-001.json` → marker emitted → jr **allow**. **v1.5 canonical-path dispatch legs: `artifacts/investigations/verdict-alert-001.json` (BOTH substrings) → JSON-first → 15-field verdict path → marker emitted (POSITIVE, not misrouted to markdown); a genuine `artifacts/investigations/investigation-001.md` → 12-field markdown path.** Shared `CLAUDE_PLUGIN_DATA=$(mktemp -d)` across the two subprocess hooks | BC-10.01.001 (v1.12 Stage-7 PC#8, D-DEC-008); enforced by BC-3.03.001 (v1.16 PC#1/2/3 JSON-first) + BC-3.01.001 (v1.19 consume) |
| **VP-HOOK-029** *(NEW v1.5; RE-SCOPED v1.8/v1.9/**v1.10 end-to-end**; **re-FINALIZED v1.10**, **P0**)* | **End-to-end consumer-boundary fail-loud invariant (D-DEC-012 / ADV-F2-P7-001 CRITICAL / P7-004 MAJOR — O4 standing rule; re-scoped from the v1.9 emitter-only marker-in-store assertion; re-FINALIZED v1.10):** for a hard-floor / Indeterminate / silent-sensor verdict carrying **ANY** `ticket_action_type`, VP-HOOK-029 asserts the CONSUMER-OBSERVABLE outcome (per §0 O4 — an emitter-local marker/audit artifact is NOT sufficient evidence): **(a) review token (`create-review`/`comment-review`):** STEP 3 issues the restricted marker AND a correctly-labeled `jr` write is authorized and CONSUMABLE at consumer STEP 6a (the human-surface jr write actually occurs) — NEVER an unconsumable marker (wrong command type / missing `--label`); **(b) non-review token (incl. `none`):** STEP 4 **DENIES the verdict Write** with a structured machine-readable corrective reason (`hard_floor_trigger`, `required_token`, `label_instruction`, `instruction`) + an **UNDER-LABEL-DENIED** audit entry, NO marker is issued, NO Jira write occurs; on the loop's corrected re-document (Write re-issued with `required_token`) path (a) fires; NEVER a silent allow, NEVER a marker in the store for the denied Write. **v1.10 pass-7 redesign (ADV-F2-P7-001 CRITICAL / P7-004 MAJOR):** the v1.9 STEP-4 marker-*upgrade* mechanism is **RETIRED** — P7-001 proved disposition-guard can rewrite the marker but not the loop's future Bash command, so the upgraded `create-review` marker was structurally unconsumable by the loop's own non-review `jr` command (3 of 4 under-label action types silently dropped the finding). DENY-AT-WRITE is the only deterministic lever at the point the LLM can still react. STEP 4 still runs **before the STEP 5 kill switch**, so the deny fires regardless of `autonomy_enabled` (kill-switch-irrelevance). The old emitter-only assertion ("marker exists OR error artifact written") could NOT detect the unconsumable-marker seam gap (P7-004). Enforced deterministically at the hook (STEP 4 deny), NOT delegated to the trusted-LLM SKILL.md layer. | B-BEH + B-INT-XH | disposition-guard.sh + require-review.sh on hard-floor verdicts, shared `CLAUDE_PLUGIN_DATA=$(mktemp -d)`. **DENY-PATH vectors (non-review token → deny-the-Write):** (1) `disposition=Indeterminate` + `ticket_action_type=create` (+ `jira_project_key="PRISM-DEMO"`) → assert the verdict Write is **DENIED** (permissionDecision=deny), NO marker written, `UNDER-LABEL-DENIED` line in `audit.log`; (2) `severity=HIGH` + `ticket_action_type=none` → verdict Write **DENIED**, NO marker, `UNDER-LABEL-DENIED` audit; (3) degraded/silent sensor + `ticket_action_type=assign` (+ `ticket_id="SEC-123"`) → **DENIED** + `UNDER-LABEL-DENIED` audit; (4) **machine-actionable-reason assertion (SM-39 kill):** `Indeterminate` + `ticket_action_type=none` + `ticket_id="SEC-123"` present → deny reason parses with `required_token=comment-review` AND `hard_floor_trigger` non-empty (the loop can act on it); `ticket_id=null` + project_key present → `required_token=create-review` + `label_instruction` names `--label (REVIEW-REQUIRED\|BLIND-SPOT)` SECOND after `--project`; **corrected-rewrite HAPPY PATH (5):** after a STEP-4 deny, the loop re-issues the verdict Write with `ticket_action_type=create-review` → assert STEP 3 now creates a `create-review` marker in the store (the deny is recoverable, not terminal); **CONSUMER-BOUNDARY vectors (6/7) — the O4 core:** (6) a `create-review` marker + a correctly-labeled `jr issue create --project PRISM-DEMO --label REVIEW-REQUIRED …` → require-review **ALLOW** (marker consumed — the escalation jr write is authorized and executes); (7) a `create-review` marker + `jr issue create --project PRISM-DEMO` WITHOUT `--label` → require-review **DENY** (proves the store never holds a marker the loop's own command cannot consume — the P7-001 seam gap is closed at the consumer boundary); **KILL-SWITCH-IRRELEVANCE vector (8):** the STEP-4 deny fires identically with `autonomy_enabled=true` AND `autonomy_enabled=false` (STEP 4 precedes STEP 5) — assert `UNDER-LABEL-DENIED` + deny in BOTH cases (kills SM-32-ext); **fail-loud assertion (all branches): assert NOT (silent allow-without-marker) AND NOT (marker in store that no matching command can consume) — the guarantee is the downstream jr authorization/execution outcome, not marker presence.** **RETIRED v1.9 upgrade-marker vectors (reason "mechanism removed ADV-F2-P7-001"; history preserved, no re-run):** ~~"Indeterminate+comment+ticket_id → comment-review marker in store"~~, ~~"HIGH+create+ticket_id null+project_key → create-review marker in store"~~, ~~"Indeterminate+none+ticket_id null+project_key → create-review marker in store"~~, and the ~~`UNDER-LABEL-CORRECTED` audit assertion~~ (superseded by `UNDER-LABEL-DENIED`). **Paired mutants: SM-38 (remove the STEP-4 deny → silent emit-allow-without-marker) killed by the deny-path vectors (1)–(3); SM-39 (remove the corrective-reason structure → deny fires but the loop cannot act) killed by vector (4); SM-32a (re-targeted: revert the STEP-4 deny to the retired GOTO-WRITE_MARKER upgrade → unconsumable marker in-store) killed by consumer-boundary vector (7); SM-32-ext (revert STEP 4/5 order → kill switch silently allows first) killed by the kill-switch-irrelevance vector (8).** | BC-10.01.001 (v1.12 Inv#10 narrowed + STEP 4 DENY-THE-WRITE, D-DEC-012); enforced by BC-3.03.001 (v1.16 STEP 4 deny + UNDER-LABEL-DENIED audit) + BC-3.01.001 (v1.19 consume create-review/comment-review + STEP 6a structural label match) |
| **VP-SKILL-072** *(NEW v1.5)* | **First-run 24h lookback correctness (ADV-F2-P4-012 — BC-10.01.001 Inv#13 / EC-001 / D-DEC-002):** when NO watermark file exists for an org×sensor pair (first invocation), the loop's Stage-1 query is bounded to `WHERE _time >= now() - INTERVAL 24 HOURS` (never a full-history scan), and after a successful run the watermark is persisted to the most-recent processed event `_time`. Distinct from VP-SKILL-050 (monotonicity on an EXISTING watermark). | B-INT | Run loop stub with an EMPTY `CLAUDE_PLUGIN_DATA/watermarks/` dir (no file for org×sensor); assert the emitted PrismQL carries the `now() - INTERVAL 24 HOURS` lower bound (and NOT an unbounded / full-history query); after run, assert a watermark file is persisted at the latest processed `_time`; control: pre-existing watermark → assert the 24h-lookback branch is NOT taken (query uses the watermark bound) | BC-10.01.001 (v1.12 Inv#13, EC-001, D-DEC-002) |
| **VP-SKILL-073** *(NEW v1.9, **P1**)* | **Late-event drop detection (ADV-F2-P6-007 — D-DEC-002 / BC-10.01.001 Stage-1):** when an ingested event's normalized `_time` is older than `watermark − WATERMARK_GRACE_SECONDS` (i.e. it arrived in-window this run but would fall outside the window next run), `DETECT_LATE_EVENT()` emits a `LATE_EVENT_DETECTED` audit entry to `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log`; the event is **NOT dropped** — it proceeds to the VALIDATE stage and is processed normally. This converts the D-DEC-002 grace-window permanent-drop trade-off from a SILENT data-loss path into an AUDITABLE one (operators tune `WATERMARK_GRACE_SECONDS` from the log). Distinct from VP-SKILL-068 (in-grace dedup) and VP-SKILL-050 (monotonicity). | B-INT | Run loop stub with a pre-existing watermark; inject an OCSF event whose normalized `_time < watermark − WATERMARK_GRACE_SECONDS`; assert a `LATE_EVENT_DETECTED` line is present in `watermarks/audit.log` (with `event_time=`, `watermark=`, `grace_window=`) AND the event still reaches VALIDATE (not silently discarded); control leg: an event with `_time ≥ watermark − GRACE` → NO `LATE_EVENT_DETECTED` line; first-run (no watermark) → `DETECT_LATE_EVENT` returns early, no false positive | BC-10.01.001 (v1.12 Stage-1, D-DEC-002 late-event fail-loud) |
| **VP-SKILL-074** *(NEW v1.9, **P1**; namespace correction — architect §8.15 item 3 said "VP-SKILL-072", occupied)* | **Severity normalization correctness (ADV-F2-P6-005 — D-DEC-013 / BC-10.01.001 Stage-1/Stage-5):** `NORMALIZE_SEVERITY(native_severity, sensor_family)` produces ONLY members of `{LOW,MEDIUM,HIGH,CRITICAL}` (case-exact, so the downstream `validate_enums()` gate never fail-closed-denies a well-normalized verdict); each sensor family maps per the D-DEC-013 table (CrowdStrike numeric 1-100 boundaries 26/51/76; NVD/CVSS float boundaries 4.0/7.0/9.0; Armis/Claroty risk bands 1:1 case-fold, Armis Informational→LOW); an UNRECOGNIZED native value (any family, incl. Cyberint pending ASM-008) → `CRITICAL` WITH `uncertainty_explicit` appended (an AUDITABLE conservative default — NEVER a silent enum-deny, and NEVER a silent LOW). Applied at Stage 1 INGEST and re-applied at Stage 5 SCORE (and Stage 1 known-FP fast-path). | B-INT (boundary/equivalence-partition) | boundary fixtures per family — CrowdStrike `{25→LOW, 26→MEDIUM, 50→MEDIUM, 51→HIGH, 75→HIGH, 76→CRITICAL}`; CVSS `{3.9→LOW, 4.0→MEDIUM, 6.9→MEDIUM, 7.0→HIGH, 8.9→HIGH, 9.0→CRITICAL}`; Armis `{Critical→CRITICAL, Informational→LOW}` case-fold; assert the emitted `verdict.severity` ∈ the four-value enum (case-exact); **unrecognized fixture (e.g. CrowdStrike `"Sev5"`) → assert `verdict.severity=="CRITICAL"` AND `verdict.uncertainty_explicit` is non-null and contains the "Unrecognized severity" annotation** (auditable, not a deny); assert NO raw sensor-native string reaches `validate_enums()`. **v1.10 Cyberint partition (ADV-F2-P7-006 MINOR, D-DEC-013 explicit conservative default):** Cyberint is a RECOGNIZED family whose per-band mapping is COMPUTE-AT-VALIDATION pending ASM-008, so it gets the explicit conservative default (mirrors the unrecognized-family rule, but named): (i) `cyberint-any-native-severity-to-CRITICAL` — any Cyberint native severity value (org-b demo path, brief §4.2) → `verdict.severity=="CRITICAL"` (pre-ASM-008 conservative default; enum-valid from first Cyberint contact); (ii) `cyberint-never-LOW-MEDIUM-HIGH-pre-ASM-008` — a Cyberint severity NEVER normalizes to LOW/MEDIUM/HIGH until ASM-008 resolves (no accidental down-tiering of an unvalidated family); (iii) `cyberint-CRITICAL-carries-uncertainty_explicit` — the CRITICAL output includes `uncertainty_explicit` naming the unvalidated mapping ("Cyberint severity mapping unvalidated per ASM-008; conservative CRITICAL applied until validated"). **Annotation: these three assertions are pre-ASM-008 invariants — UPDATE WHEN ASM-008 RESOLVES and the validated Cyberint per-band mapping is specified (then partitions (i)/(ii) are replaced by the real band boundaries).** | BC-10.01.001 (v1.12 Stage-1/Stage-5 field 13, D-DEC-013) |

**Totals:** 5 FINALIZED F1 VPs (024, 025, 026, 050, 051) + 12 FINALIZED proposed VPs (052–063)
+ 2 v1.1 VPs (064, 065) + 4 v1.2 VPs (VP-HOOK-027, VP-SKILL-066, 067, 068) + 4 v1.3 VPs
(VP-SKILL-069, 070, 071, VP-HOOK-028) + 2 v1.5 VPs (VP-HOOK-029, VP-SKILL-072) + 2 v1.9 VPs
(VP-SKILL-073 late-event, VP-SKILL-074 severity normalization) = **31 VPs** for the cycle
(**v1.10 adds NO new VP — VP-HOOK-029 re-scoped in place, VP-HOOK-024 / VP-SKILL-074 extended**).
Strategy mix: **8 hook properties** (VP-HOOK-024/025/026/027/028/029 — CRITICAL/HIGH enforcement;
027/028/029 are cross-hook B-INT-XH; **VP-HOOK-029 is P0 end-to-end consumer-boundary fail-loud,
re-FINALIZED v1.10 with the deny-the-Write / consumer-boundary vector set**), **23 skill properties**
(VP-SKILL-073 is a late-event-detection integration test and VP-SKILL-074 a severity-normalization
boundary/equivalence test with the v1.10 Cyberint partition — both NEW v1.9, PROPOSED;
VP-SKILL-072 is a first-run integration test; VP-SKILL-069/070 are static+integration+adversarial
org_slug scoping on the investigate-event and assess-priority PrismQL surfaces; VP-SKILL-071 is a
boundary/property test at the D-DEC-011 confidence thresholds; VP-SKILL-066/067 are mixed
integration+structural; VP-SKILL-068 is prism-DTU + jr-mock integration; VP-SKILL-064 is mixed
structural+integration+adversarial; **VP-SKILL-065 RE-SCOPED v1.9 to zero-REGULAR-writes with the
review-exempt carve-out (carve-out UNCHANGED at v1.10), PROPOSED**). **VP-HOOK-029 lifecycle: tagged P1 at
pass-4; re-scoped to the P5-001 CRITICAL under-label vectors at pass-5 (P0); FINALIZED at pass-6 with the
kill-switch-on under-label upgrade vectors; **re-scoped END-TO-END at pass-7 per the O4 standing rule
(§0) — the pass-6 STEP-4 marker-upgrade mechanism RETIRED (ADV-F2-P7-001), replaced by DENY-THE-WRITE;
the emitter-only "marker in store OR error" assertion replaced by the consumer-boundary jr
authorization/execution outcome (ADV-F2-P7-004); lifecycle re-marked PROPOSED then re-FINALIZED (P0)
v1.10**. VP-SKILL-073/074 and the re-scoped VP-SKILL-065 carry VP-INDEX lifecycle PROPOSED (adjudicated in
F6).**

---

## 3. Answers to the Product-Owner's 4 Open Technical Questions (encoded as VP design decisions)

**(a) VP-HOOK-025 mechanism — disposition-guard dual-path [UPDATED v1.3 — artifact-class field-set
branching, D-DEC-008-C].** The hook branches on artifact class, and **the required field-set differs
per class** (the pass-3 correction — ADV-F2-P3-003; BC-3.03.001 v1.13 PC#2 corrected from the 15-field
erratum to 12; BC-5.01.001 v1.8 Inv#7's 12-field citation was already correct): (i) if
`tool_input.file_path` matches the investigation-markdown pattern (`*investigation-*.md`) →
heading-anchored check (`grep -qiE "^#{1,6}[[:space:]]+<field>"`) for the **12 ICD-203 field headings
ONLY** (Disposition, Confidence, Sensor Health Status, Evidence Artifacts, Timeline Events,
Hypotheses Considered, Alternatives Rejected, Uncertainty Explicit, Attack Techniques, Agent Actions,
Human Actions, Tuning Signal). Severity / Asset Type / Ticket Action Type are **NOT required** for the
investigation-markdown class (Ticket Action Type is meaningless for a human investigation), and their
presence in an investigation file must **NOT** trigger a wrong-class 15-field deny (SM-30 is the paired
over-strict mutant). (ii) if the file is a verdict file (verdict path/extension OR `tool_input.content`
parses as JSON via `jq empty`) → JSON key-presence + type check for **ALL 15 fields**. Key-presence
uses `jq -e 'has("<field>")'` (NOT `!= null`, so a present-null key is distinguishable from an absent
one — fail-closed deny if any of the 15 `has()` returns false).
**ADV-F2-001/004 fix: fields 13–15 added — `severity` (field 13), `asset_type` (field 14),
`ticket_action_type` (field 15).** Per-field type assertions (the original 12):
`disposition` string∈{TP,FP,BTP,Indeterminate}; **`confidence` is ENUM-ONLY (D-DEC-011): `type=="string" and (.=="high" or .=="medium" or .=="low")` — a float value (e.g. `0.85`) FAILS this assertion and is DENIED (ADV-F2-P3-008); the producer-side float→enum mapping is guaranteed by VP-SKILL-071 on the assess-priority side, disposition-guard is the enforcement backstop);**
`sensor_health_status` string∈{healthy,degraded,silent}; `evidence_artifacts`/`timeline_events`/`hypotheses_considered`/`alternatives_rejected`/`attack_techniques`/`agent_actions`/`human_actions`
each `type=="array"`; `uncertainty_explicit` `type=="string" or .==null`; `tuning_signal`
`type=="object" or .==null` (with disposition-conditional rule per (d)). **New (fields 13–15):**
`severity` string∈{LOW,MEDIUM,HIGH,CRITICAL} (read by the hard-floor check — NOT `confidence`,
which is an orthogonal axis; ADV-F2-001); `asset_type` string∈{domain_controller,privileged_account,ot_safety_system,standard,unknown}
(critical-asset hard-floor input); `ticket_action_type` string∈{comment,create,assign,none}
(selects the emitter scope branch per D-DEC-008; **v1.5: enum extended to
{comment,create,assign,none,create-review,comment-review}** — `create-review`/`comment-review`
are the D-DEC-012 review-surfacing tokens; `none` ⇒ no marker written). Malformed JSON →
fail-closed deny (mirrors BC-3.01.001 EC-020 marker handling). This is implementable in bash
with `jq` only — no new dependency. Enforced per BC-3.03.001 v1.13 PC#1/2/3 (dual-path) and
BC-10.01.001 v1.9 Invariant #9 (15-field list + `autonomy_enabled` operational field).

**[UPDATED v1.5 — JSON-first dispatch precedence (ADV-F2-P4-001 CRITICAL).]** The class-dispatch
order is now **JSON-first, and this precedence is load-bearing**: the canonical verdict path
`artifacts/investigations/verdict-<id>-<iso_ts>.json` contains BOTH the `investigation` (directory)
and `verdict` (filename) substrings, so a plain "check `investigation` substring first" router would
misroute the canonical verdict JSON to the 12-field heading-grep branch, fail every `## `-heading
assertion, DENY the write, emit no marker, and render the entire autonomous pipeline unreachable.
The corrected dispatch is exactly the order this doc already specified in (a)(ii): **(1)** if
`tool_input.content` parses as JSON via `jq empty` OR `file_path` ends in `.json` → **verdict-class
15-field + `validate_enums()` path** (REGARDLESS of any `investigation` substring in the path);
**(2)** elif `file_path` matches `*investigation-*.md` → investigation-class 12-field markdown path;
**(3)** else → fast-path allow (no ICD-203 validation). BC-3.03.001 v1.13 PC#1/2/3 are rewritten to
this order (PC#1 = JSON check; PC#2 = investigation `.md`; PC#3 = fast-path). Mutant **SM-34**
(dispatch-order-inverted — check the `investigation` substring before the JSON test) is the paired
kill target; VP-HOOK-028's canonical-path leg asserts `.../verdict-alert-001.json` → 15-field path
→ marker (positive) and `.../investigation-001.md` → 12-field path.

**[UPDATED v1.5 — `validate_enums()` membership gate (ADV-F2-P4-006 MAJOR).]** BC-3.03.001 v1.11
PC#3 described the verdict-JSON check as key-presence only (`jq has()`), but `hard_floor_applies()`
keys on exact-string membership. A case-mangled `severity:"High"` therefore passed key-presence yet
silently failed the `"High" ∈ {"HIGH","CRITICAL"}` test → NO hard floor → a marker was issued for
an actually-HIGH-severity alert. v1.5 adds an explicit `validate_enums(verdict)` step (D-DEC-008
emitter pseudocode) that runs **BEFORE** the hard-floor check and **fail-closed DENIES** any
non-member value on ALL typed fields: `severity ∈ {LOW,MEDIUM,HIGH,CRITICAL}`,
`asset_type ∈ {domain_controller,privileged_account,ot_safety_system,standard,unknown}`,
`disposition ∈ {TP,FP,BTP,Indeterminate}`, `sensor_health_status ∈ {healthy,degraded,silent}`,
`ticket_action_type ∈ {comment,create,assign,none,create-review,comment-review}`,
`confidence ∈ {high,medium,low}`. Fail-closed DENY (not allow-without-marker) is the correct
posture — allowing a field-mangled verdict to write to the investigation store without an ICD-203
guarantee is the failure mode P4-006 flagged. Mutant **SM-31** (validate_enums-removed → wrong-case
`severity` passes the hard floor and wrongly gets a marker) is the paired kill target.

**(b) ASM-009 cross-hook marker visibility + atomic consume-on-use — BATS integration test.**
Add to `integration.bats` a `setup()` that does `export CLAUDE_PLUGIN_DATA="$(mktemp -d)"`
(teardown `rm -rf`). Test sequence (three SEPARATE subprocess hook invocations, same exported
env = exactly the ASM-009 condition — DG writes, RR reads, distinct processes):
(1) invoke `disposition-guard.sh` with a verdict passing all **15** fields + non-hard-floor
disposition (FP / confidence=high / severity=LOW / asset_type=standard / healthy sensor /
ticket_action_type=comment) → assert a `<uuid>.marker.json` (schema v2.0: `issued_at_utc`,
`expires_at_utc` = +120s, ticket-bound `command_pattern`) now exists in
`$CLAUDE_PLUGIN_DATA/markers/`;
(2) invoke `require-review.sh` with `jr issue comment SEC-123 "..."` → assert `allow` AND the
marker file is now renamed to `*.marker.json.used` (cross-hook visibility + consume-on-use) AND
an `audit.log` line with a `command_b64=` (base64) field is appended;
(3) invoke `require-review.sh` a SECOND time with the same command → assert `deny`
(fail-closed on the consumed marker — proves single-use atomicity via POSIX rename; and note the
v2.0 rename-fail→deny leg is a distinct fixture). This is VP-HOOK-024's replay leg realized as an
integration test and is the empirical validator ASM-009 demands before Wave 3 merge.

**[UPDATED v1.2 — iterative-consume + document-before-action (ADV-F2-P2-001/P2-003).]** The
consumer is now **iterative-consume**, not ">1 → ambiguous deny" (architecture-delta §D-DEC-001
v1.3): candidates are sorted `issued_at_utc` ASC and the loop consumes the oldest whose atomic
`mv → .used` rename succeeds; if all renames fail it denies (fail-closed exhaustion). Two added
integration legs: (i) **concurrent same-scope** — write TWO valid same-scope markers via two
disposition-guard invocations, then one require-review call → assert `allow` with the *oldest*
marker consumed and the newer one still present (legitimate multi-alert loop run no longer
mutually invalidates — the ADV-F2-P2-003 fix); (ii) **exhaustion** — pre-rename both candidates
to `.used` out-of-band, then require-review → assert `deny`. Separately, **VP-HOOK-027**
(document-before-action) uses this same harness but flips the *ordering*: the negative leg invokes
require-review on the `jr` Bash call with an EMPTY marker dir (Stage 8 before Stage 7) → assert
`deny`; the positive leg runs disposition-guard-Write (Stage 7) → require-review-Bash (Stage 8) →
assert `allow`. VP-HOOK-027 is the process-gap guard the adversary flagged (P2-014) that would
have caught the P2-001 inverted-stage CRITICAL.

**(c) VP-HOOK-026 fixture mechanism — env-var + stdin-envelope injection (config-file injection
REJECTED).** Established pattern in `tests/hooks.bats`: every hook is driven purely by the
stdin JSON envelope (`{tool_input.command}` / `{tool_input.file_path, content}`) with
`PLUGIN_ROOT` from `BATS_TEST_DIRNAME`; there is NO existing config-file read pattern in any
hook, and BC-3.01.001 Invariant #2 constrains the hook to decide "from the stdin JSON envelope
only" (plus, for require-review, the marker store). Filesystem roots are supplied via env-var
(`CLAUDE_PLUGIN_DATA`, matching the architecture-delta §Testing-Architecture `mktemp -d` +
`export` mandate). Therefore VP-HOOK-026 injects: `CLAUDE_PLUGIN_DATA=$(mktemp -d)` for the
marker-store, and the hard-floor verdict + `autonomy_enabled: true` inside `tool_input.content`.
Because disposition-guard's hard floor is an UNCONDITIONAL branch that never consults autonomy
state, the proof is: feed `autonomy_enabled=true` alongside each hard-floor category in turn and
assert `$CLAUDE_PLUGIN_DATA/markers/` remains empty after the hook returns.
**ADV-F2-001 leg correction (v1.1):** the earlier draft's legs injected non-existent fields; the
hard-floor keys on the LIVE 15-field schema, so the corrected legs inject:
(1) `disposition=Indeterminate`; (2) **`verdict.severity=HIGH`** (field 13 — NOT `confidence`;
severity and confidence are orthogonal axes, so this leg pairs `severity=HIGH` with
`confidence=low` to prove the hard floor still fires); (3) **`verdict.asset_type=critical-asset`**
(field 14, e.g. `domain_controller`); (4) `attack_techniques` contains `T1003`;
(5) `sensor_health_status=degraded`; **(6) NEW v1.3 (ADV-F2-P3-001 CRITICAL) — `verdict.asset_type=unknown`
paired with `severity=LOW` + a benign (non-hard-floor) technique + `ticket_action_type=comment`:
the `unknown` asset_type is a conservative hard-floor member (BC-3.03.001 v1.13 Inv#4 / BC-10.01.001
v1.9 Inv#10), so even a fully-benign verdict with an unclassified asset must NOT receive a marker.**
Each leg asserts **NO marker is issued** (marker dir empty) regardless of `autonomy_enabled=true`.
The unknown-asset leg is the defense-in-depth guarantee the adversary flagged as false: the hook must
block the marker independently of SKILL.md behavior. Mutant SM-29 (unknown-asset-hard-floor-removed) is
the paired kill target. Config-file injection is rejected — it would introduce an input surface no hook
reads and diverge from the harness.

**[UPDATED v1.5 — `autonomy_enabled` is a verdict field read directly by the hook + review-surfacing
exemptions (ADV-F2-P4-004/P4-005, D-DEC-012).]** Two v1.5 corrections change the VP-HOOK-026 leg set,
both keeping the env-var + stdin-envelope harness (config-file injection still REJECTED): **(A)
kill-switch determinism (P4-005):** `autonomy_enabled` is now a NON-ICD-203 operational metadata field
IN the verdict JSON (alongside `jira_project_key`/`confidence_score`), and disposition-guard reads it
DIRECTLY (D-DEC-008 emitter Step 5 — the kill switch, renumbered from Step 4 by the ADV-F2-P6-002
reorder) rather than trusting the loop LLM to have set
`ticket_action_type=none`. `autonomy_enabled != true` (false OR **absent → conservative false**)
suppresses ALL REGULAR markers. New legs: `autonomy_enabled=false` + regular `create` → NO marker;
`+ comment` → NO marker; `autonomy_enabled` ABSENT + regular `create` → treated false → NO marker.
Mutant **SM-33** (autonomy_enabled-clause-removed → a regular marker is wrongly emitted under the kill
switch) is the paired kill target. **(B) review-surfacing exemptions (P4-004, D-DEC-012):** the
`create-review`/`comment-review` ticket_action_types are EXEMPT from BOTH the hard-floor no-marker rule
AND the kill switch (emitter Step 3 correct-label review path runs before the
Step 5 kill switch; an under-labeled hard-floor verdict is DENIED at Step 4 — before Step 5 too — so the
loop re-documents with a review token, per the v1.10 deny-the-Write redesign), because creating a `[REVIEW-REQUIRED]` /
`[BLIND-SPOT]` ticket is human ESCALATION, not autonomous triage. Legs: Indeterminate +
`create-review` → restricted marker emitted (`authorized_operations=["create-review"]`, hard-floor
EXEMPT); silent-sensor + `comment-review` → restricted marker emitted; HIGH-severity + `create-review`
→ marker emitted; `autonomy_enabled=false` + `create-review` → marker STILL emitted (kill-switch
EXEMPT). The legs assert a marker IS emitted, so the "remove the review exemption entirely →
over-strict, review ticket dropped" direction is killed here.

**[UPDATED v1.8 / v1.9 / v1.10 — the STEP 3 review-exemption is GATED on `hard_floor_applies()`; the review token is
no longer trusted unconditionally (ADV-F2-P5-002 MAJOR); the STEP 4 handling of an under-labeled hard-floor
verdict is the fail-loud dual (ADV-F2-P5-001 CRITICAL), which — post the ADV-F2-P7-001 redesign — is now a
DENY-THE-WRITE (marker-upgrade RETIRED) and still runs BEFORE the STEP 5 kill switch.]** Pass-4 treated the `create-review`/`comment-review`
exemption as UNCONDITIONAL on the LLM-supplied `ticket_action_type`, which let the LLM manufacture a
kill-switch + hard-floor bypass by over-labeling a regular verdict as a review action (P5-002).
The architect's D-DEC-008 STEP 3 fix (architecture-delta v1.8) gates the exemption on the
hook-computed `hard_floor_applies(verdict)`: `IF NOT hard_floor_applies(): emit allow WITHOUT marker;
RETURN`. **New v1.8 OVER-LABEL legs (VP-HOOK-026):** non-hard-floor TP verdict (LOW severity, standard
asset) + `create-review` → NO marker; non-hard-floor FP + `comment-review` + `autonomy_enabled=false`
→ NO marker (no kill-switch bypass); LOW-severity standard asset + `create-review` → NO marker. The
paired kill target for the over-label legs is **SM-32b** (remove the STEP 3 `NOT hard_floor_applies()`
gate → a non-hard-floor verdict with a review token gets the exempt marker; the over-label legs assert
NO marker, so the mutant dies). The **under-label** dual (a hard-floor verdict carrying a NON-review
token) is enforced at STEP 4's DENY-THE-WRITE and proved end-to-end by **VP-HOOK-029** (the consumer-boundary
re-scope, §2); its paired mutants are **SM-38** (remove the STEP-4 deny → silent allow), **SM-39** (remove the
corrective-reason structure), and the re-targeted **SM-32a** (revert the deny to the retired upgrade →
unconsumable in-store marker), with **SM-32-ext** (revert the STEP 4/5 order) killed by VP-HOOK-029's
kill-switch-irrelevance deny vector. The unconditional-hard-floor legs (1)–(6) above are UNCHANGED for
REGULAR (comment/create/assign) markers; the review-surfacing legs (hard_floor_applies()=TRUE → marker
emitted) are UNCHANGED and remain valid under the gated STEP 3.

**(d) tuning_signal null-vs-absent — jq check.** Three-way distinction, evaluated in order:
`has("tuning_signal") == false` → **INVALID ALWAYS** (absent key is a schema violation → deny);
`.tuning_signal == null` (key present, null) → **REQUIRED/valid for disposition∈{TP,Indeterminate}**,
INVALID for {FP,BTP}; non-null → must be an object with `rule_id`,`asset`,`reason`, **REQUIRED
for {FP,BTP}** (and acceptable for TP/Indeterminate). Encoding:
`jq -e 'has("tuning_signal")'` (else deny); then
`disp=$(jq -r .disposition)`; if `FP|BTP`:
`jq -e '.tuning_signal!=null and (.tuning_signal|type=="object") and (.tuning_signal|has("rule_id") and has("asset") and has("reason"))'` (else deny);
if `TP|Indeterminate`: `jq -e '.tuning_signal==null or (.tuning_signal|type=="object")'`
(else deny). Note the deliberate use of `has()` for presence and `== null` for the value —
conflating the two is mutant SM-18 (§4).

---

## 4. SM-N Mutant Catalog Extension

Existing catalog runs SM-1..SM-8b (verification-gap-analysis.md §Surviving Mutants). New
high-value mutants for the marker-validation path (require-review, **CRITICAL — target ≥95%**)
and the disposition-guard JSON path + monitoring-loop (**HIGH — target ≥90%**; the
monitoring-loop-verdict enforcement it guards is on the CRITICAL Jira-write path). **v1.1 added
SM-20..SM-25 for the 15-field schema, the ticket-scoped emitter, the ADV-F2-001 severity/confidence
fix, the ADV-F2-005 hard-floor-ordering fix, and the two new VPs (org_slug, kill switch). v1.2
retargets SM-15 to the iterative-consume path (the ">1 ambiguous deny" mutation target was retired
at architecture-delta §D-DEC-001 v1.3) and adds SM-26 (reopen-guard-removed), SM-27
(dedup-check-removed→double-ticket), SM-28 (stage-order-inverted). v1.3 adds SM-29
(unknown-asset-hard-floor-removed, ADV-F2-P3-001) and SM-30 (artifact-class-over-strict,
ADV-F2-P3-003). **v1.5 adds SM-31 (validate_enums-removed, ADV-F2-P4-006), SM-32
(review-surfacing-hard-floor-bypass-removed, D-DEC-012/ADV-F2-P4-004), SM-33
(autonomy_enabled-clause-removed, ADV-F2-P4-005), SM-34 (dispatch-order-inverted, ADV-F2-P4-001),
and SM-35 (control-char-strip-removed, ADV-F2-P4-010).** **v1.8 RE-SCOPES SM-32 into two
separately-killable variants — SM-32a (step4-under-label-upgrade-removed, ADV-F2-P5-001 CRITICAL,
killed by VP-HOOK-029) and SM-32b (step3-hard-floor-gate-removed, ADV-F2-P5-002 MAJOR, killed by
VP-HOOK-026) — raising the count 27 → 28 (SM-9..SM-35, with SM-32 = SM-32a + SM-32b).** **v1.9
(pass-6) adds THREE mutants: SM-32-ext (step-order-reverted → STEP 5 kill switch back before the
STEP 4 under-label upgrade, ADV-F2-P6-002 CRITICAL, killed by VP-HOOK-029's kill-switch-on under-label
vectors), SM-36 (consumer-review-label-check-removed, ADV-F2-P6-001 CRITICAL, killed by VP-HOOK-024)
and SM-37 (consumer-reverse-label-check-removed, ADV-F2-P6-001 CRITICAL, killed by VP-HOOK-024) —
raising the count 28 → 31 (SM-9..SM-37, with SM-32 = SM-32a + SM-32b + SM-32-ext; SM-33/34/35 are the
PRE-EXISTING pass-4 mutants — NAMESPACE NOTE: architect §8.15 item 5 mis-named the consumer mutants
"SM-33/SM-34", which collide with occupied ids; they are allocated the next free SM-36/SM-37).** **v1.10
(pass-7) adds THREE mutants for the STEP-4 DENY-THE-WRITE redesign (occupancy re-verified — `grep -rhoE
'SM-[0-9]+' .factory/` max real = SM-37, SM-2026 a date false-positive; next free = SM-38): SM-38
(step4-deny-removed → silent emit-allow-without-marker, ADV-F2-P7-001 CRITICAL, killed by VP-HOOK-029's
deny-path vectors), SM-39 (deny-corrective-reason-removed → the deny fires but the loop cannot act on a
structureless message, ADV-F2-P7-004 MAJOR, killed by VP-HOOK-029's machine-actionable-reason vector),
and SM-40 (has_review_label-reverted-to-raw-substring → false-deny of a regular create whose --summary
contains the label literal, ADV-F2-P7-005 MINOR, killed by VP-HOOK-024's step-6a false-deny vector) —
raising the count 31 → 34 (SM-9..SM-40, with SM-32 = SM-32a + SM-32b + SM-32-ext). SM-32a is RE-TARGETED
(the STEP-4 upgrade it formerly removed is RETIRED) to "revert the STEP-4 deny to the retired
GOTO-WRITE_MARKER upgrade" (killed by VP-HOOK-029's consumer-boundary vector — the marker is present but
unconsumable); SM-32-ext's kill vector is RE-WORDED to the deny-before-kill-switch assertion. Neither
re-target/re-word adds or removes an id.** All 34
must be KILLED by the F4/F6 suite before convergence.

| Mutant | Target construct | Mutation | Killed by |
|--------|------------------|----------|-----------|
| SM-9 | require-review marker TTL compare | invert `(now − issued_at) > 30` → `< 30` (expired accepted / fresh rejected) | VP-HOOK-024 expired-marker test (EC-017) |
| SM-10 | require-review authorized_operations / command_pattern scope check | delete the scope/anchored-pattern gate (comment marker authorizes create) | VP-HOOK-024 wrong-scope (EC-018) + wrong-ticket (EC-022) |
| SM-11 | require-review atomic invalidation (`mv → .used`) | skip the rename (marker not consumed) → replay possible | VP-HOOK-024 replay-deny (EC-019) + ASM-009 §3(b) step 3 |
| SM-12 | require-review command_pattern matcher | degrade anchored `^`-regex to substring / `grep -F` (**SEC-009 class**) | VP-HOOK-024 anchored-match + bypass-class vector (EC-022) |
| SM-13 | require-review future-dated guard | delete `issued_at > now()` check (clock-manipulation marker accepted) | VP-HOOK-024 future-dated test (EC-017 variant) |
| SM-14 | require-review path-safety guard | delete basename `..`/`/` check (path-traversal candidate processed) | VP-HOOK-024 path-traversal test (EC-021) |
| SM-15 | require-review iterative-consume exhaustion guard *(retargeted v1.2 — the ">1 → ambiguous deny" gate was retired at architecture-delta §D-DEC-001 v1.3 / ADV-F2-P2-003)* | replace the post-loop `deny (fail-closed exhaustion)` with `allow` (fail-open when every candidate's rename fails) OR drop the `issued_at_utc` ASC sort so a newer/forged marker is consumed before the oldest | VP-HOOK-024 iterative-consume legs: all-renames-fail → exhausted-DENY, and concurrent-same-scope → oldest-consumed-first |
| SM-16 | disposition-guard emitter STEP 4 hard-floor gate *(renumbered from STEP 5 by the ADV-F2-P6-002 reorder)* | remove the `IF hard_floor_applies():` guard entirely so a hard-floor verdict (Indeterminate/HIGH) with a regular action falls through to STEP 6 and gets a **REGULAR (comment/create/assign-scoped) autonomous-triage marker** (distinct from SM-38, which removes the STEP-4 *deny* → silent allow, and from the re-targeted SM-32a, which reverts the deny to the retired upgrade → unconsumable in-store marker) | VP-HOOK-026 hard-floor tests (assert NO regular-scoped marker; SM-16 issues a regular comment/create/assign marker for a hard-floor verdict and dies) |
| SM-17 | disposition-guard 15-field `has()` list | drop one of the original 12 fields (e.g. `timeline_events`) from the presence list | VP-HOOK-025 per-field missing-field tests |
| SM-18 | disposition-guard tuning_signal null/absent | replace `has("tuning_signal")` with `.tuning_signal != null` (absent≡null conflated) | VP-HOOK-025 tuning_signal absent-invalid + FP-null-invalid (EC-011) |
| SM-19 | disposition-guard dual-path router | invert verdict-vs-markdown routing (JSON verdict sent to heading check → field bypass) | VP-HOOK-025 dual-path routing test (JSON verdict allow/deny) |
| SM-20 | disposition-guard 15-field `has()` list (new fields) | **severity-field-drop** — drop `severity`/`asset_type`/`ticket_action_type` (fields 13/14/15) from the presence list | VP-HOOK-025 missing-severity / missing-asset_type / missing-ticket_action_type tests (EC-010) |
| SM-21 | disposition-guard hard-floor key | replace `verdict.severity` with `verdict.confidence` as the severity proxy (**ADV-F2-001 latent bypass**: HIGH-severity + low-confidence escapes the floor) | VP-HOOK-026 leg (2): `severity=HIGH` + `confidence=low` → assert NO regular (comment/create/assign-scoped) marker (HIGH severity is hard-floor by severity; an under-labeled hard-floor verdict is instead denied at STEP 4) — the mutant keys on `confidence=low`, mis-classifies as non-hard-floor, issues a REGULAR marker, and dies |
| SM-22 | disposition-guard emitter scope selection | **ticket_action_type-ignored** — ignore `verdict.ticket_action_type`, always emit a comment-scoped marker (a `create`/`assign` verdict gets a wrong-scope comment marker) | VP-HOOK-024 create-scoped + assign-scoped allow-path vectors (wrong-scope marker fails anchored `command_pattern` match) |
| SM-23 | monitoring-loop known-FP Stage-2 fast-exit ordering | **hard-floor-check-after-auto-close** — move the hard-floor evaluation AFTER the known-FP auto-close (ADV-F2-005): a HIGH-severity / critical-asset / degraded-sensor alert that also matches a known-FP pattern gets auto-closed before the floor fires | VP-HOOK-026 + BC-10.01.001 EC-009 hard-floor-before-known-FP test (**no auto-close** — the hard floor fires first and the alert is routed for human review, i.e. `ticket_action_type=create-review`/`comment-review` per the v1.8 narrowed Inv#10, NEVER silently auto-closed) |
| SM-24 | monitoring-loop PrismQL query construction | **org_slug-drop** — omit the `org_slug` scope constraint from the generated query (cross-tenant leak) | VP-SKILL-064 multi-org integration (org-a query returns zero org-b/c rows) + unscoped-query adversarial fixture |
| SM-25 | monitoring-loop autonomy gate | **kill-switch-ignore** — ignore `autonomy_enabled=false` and execute a REGULAR `jr issue create/comment/assign` anyway | VP-SKILL-065 kill-switch integration (RE-SCOPED v1.9: zero REGULAR markers consumed, zero REGULAR jr writes; the review-exempt escalation write is NOT what this mutant targets) |
| SM-26 | update-jira never-auto-reopen guard | **reopen-guard-removed** (ADV-F2-P2-009a) — remove the Closed/Resolved guard so the update-jira Closed/Resolved branch emits `jr issue move` to reopen autonomously | VP-SKILL-066 (Resolved→propose-only-no-move EC-007; Closed→create-new+link-no-move EC-008) |
| SM-27 | monitoring-loop grace-window Jira-first dedup | **dedup-check-removed → double-ticket** (ADV-F2-P2-009c) — skip the Stage-2 Jira-first dedup lookup so a grace-window re-fetched event with an existing open ticket creates a SECOND (duplicate) ticket | VP-SKILL-068 (in-grace event with existing open ticket → append-COMMENT, NOT create; mutant creates the duplicate and dies) |
| SM-28 | monitoring-loop stage-order (document-before-action) | **stage-order-inverted** (ADV-F2-P2-001) — execute Stage 8 TICKET ACTION (`jr` Bash) BEFORE the Stage 7 DOCUMENT verdict Write, so no marker exists when require-review evaluates the jr call | VP-HOOK-027 negative leg (jr Bash with empty marker dir → DENY); positive leg proves correct order → ALLOW |
| SM-29 | disposition-guard emitter hard-floor asset_type set | **unknown-asset-hard-floor-removed** (ADV-F2-P3-001) — drop `asset_type=='unknown'` from the hard-floor set so a LOW-severity + benign-technique + `asset_type=unknown` + `ticket_action_type=comment` verdict is issued a REGULAR comment marker (defense-in-depth breach on the authorization boundary) | VP-HOOK-026 unknown-asset leg (assert NO regular comment/create/assign-scoped marker for `asset_type=unknown` — a STEP 4 review-upgrade marker is acceptable, a regular autonomous-triage marker is not); the mutant issues a REGULAR comment marker and dies |
| SM-30 | disposition-guard artifact-class field-set router | **artifact-class-over-strict** (ADV-F2-P3-003) — apply the 15-field set to the investigation-markdown class (demand Severity/Asset Type/Ticket Action Type headings) so a valid 12-field investigation markdown is wrongly DENIED (regresses the investigate-event DI-013 marker path) | VP-HOOK-025 investigation-12-field-accept test (12-heading investigation → allow) + Severity-heading-inserted-into-investigation → still allow (no wrong-class 15-field deny) |
| SM-31 | disposition-guard `validate_enums()` membership gate | **validate_enums-removed** (ADV-F2-P4-006) — remove the pre-hard-floor enum-membership check so a case-mangled `severity="High"` (or `asset_type="Unknown"` / `disposition="indeterminate"` / `sensor_health_status="Degraded"` / `ticket_action_type="NONE"`) passes key-presence, silently fails the `∈{HIGH,CRITICAL}` membership test, escapes the hard floor, and is issued a marker | VP-HOOK-025 enum-membership legs (`severity="High"`→DENY, etc.); the mutant issues a marker for a case-mangled HIGH verdict and dies |
| SM-32a *(RE-TARGETED v1.10 — the STEP-4 upgrade it formerly removed is RETIRED)* | disposition-guard emitter STEP 4 DENY-THE-WRITE (vs the retired GOTO-WRITE_MARKER upgrade) | **step4-deny-reverted-to-retired-upgrade** (ADV-F2-P7-001 CRITICAL) — revert the STEP-4 deny to the now-RETIRED P5-001/P6-002 marker-upgrade (`GOTO WRITE_MARKER` issuing a `create-review`/`comment-review` marker) instead of denying the Write, so an under-labeled hard-floor verdict again produces an in-store marker WITHOUT the loop having re-documented — a marker the loop's own non-review `jr` command cannot consume (the P7-001 seam gap re-appears) | **VP-HOOK-029 consumer-boundary vector (7)** (`create-review` marker + `jr issue create` WITHOUT `--label` → DENY: proves no unconsumable marker is left in-store) + the deny-path assertion that NO marker exists for the original denied Write — the mutant leaves an unconsumable marker in-store and dies |
| SM-32-ext *(kill vector RE-WORDED v1.10 to the deny-before-kill-switch assertion)* | disposition-guard emitter STEP order (kill switch vs STEP-4 deny) | **step-order-reverted** (ADV-F2-P6-002 CRITICAL / P7-001) — revert the reorder so the `autonomy_enabled` kill switch runs BEFORE the hard-floor STEP-4 handling. Under `autonomy_enabled=false`, an under-labeled hard-floor verdict then hits the kill switch first → `emit allow without marker; RETURN` before the STEP-4 DENY can fire → the finding is silently allowed (no deny, no UNDER-LABEL-DENIED audit) exactly as in P6-002 | **VP-HOOK-029 kill-switch-irrelevance deny vector (8)** (STEP-4 deny fires identically with `autonomy_enabled` true AND false — STEP 4 precedes STEP 5; assert `UNDER-LABEL-DENIED` + deny in BOTH cases) — under the mutant the `autonomy_enabled=false` case yields a silent allow with no deny/audit, and the vector catches it |
| SM-36 | require-review consumer STEP 6a review-marker label check | **consumer-review-label-check-removed** (ADV-F2-P6-001 CRITICAL) — remove the `IF authorized_operations==["create-review"] AND NOT has_review_label: CONTINUE` guard so a `["create-review"]` marker is consumed by a regular `jr issue create --project ORG_A` command that lacks `--label REVIEW-REQUIRED\|BLIND-SPOT` → a regular autonomous create steals a hard-floor escalation's review marker (the P6-001 kill-switch/hard-floor bypass) | **VP-HOOK-024 named vector `create-review-marker-requires-review-label`** (create-review marker + no-`--label` command → DENY); the mutant allows the no-label create and dies |
| SM-37 | require-review consumer STEP 6a regular-marker reverse label check | **consumer-reverse-label-check-removed** (ADV-F2-P6-001 CRITICAL) — remove the `IF authorized_operations==["create"] AND has_review_label: CONTINUE` guard so a regular `["create"]` marker is consumed by a review-labeled `jr issue create --project ORG_A --label REVIEW-REQUIRED …` command → the reverse fungibility direction (a regular marker authorizes a review-labeled escalation write) | **VP-HOOK-024 named vector `create-marker-rejects-review-label`** (create marker + `--label` command → DENY); the mutant allows the review-labeled create and dies |
| SM-32b | disposition-guard emitter STEP 3 over-label gate | **step3-hard-floor-gate-removed** (ADV-F2-P5-002 MAJOR) — remove the `IF NOT hard_floor_applies(verdict): emit allow without marker; RETURN` guard at STEP 3 so a NON-hard-floor verdict (disposition=TP, LOW severity, standard asset) carrying an LLM-supplied `create-review`/`comment-review` token receives the kill-switch + hard-floor EXEMPT review marker → the LLM manufactures a kill-switch bypass by over-labeling a regular verdict | **VP-HOOK-026 over-label legs** (non-hard-floor TP + create-review → NO marker; non-hard-floor FP + comment-review + autonomy_enabled=false → NO marker; LOW-severity standard asset + create-review → NO marker) — the mutant issues a marker for a non-hard-floor verdict and dies |
| SM-33 | disposition-guard emitter `autonomy_enabled` kill switch (Step 5) *(renumbered from Step 4 by the ADV-F2-P6-002 reorder)* | **autonomy_enabled-clause-removed** (ADV-F2-P4-005) — remove the direct `verdict.autonomy_enabled != true` suppression clause so a REGULAR `create`/`comment` marker is wrongly emitted under the kill switch (`autonomy_enabled=false` or absent) | VP-HOOK-026 kill-switch legs (`autonomy_enabled=false`/absent + regular create/comment → NO marker); mutant emits a marker and dies |
| SM-34 | disposition-guard artifact-class dispatch order | **dispatch-order-inverted** (ADV-F2-P4-001) — test the `investigation` path substring BEFORE the JSON-content check so the canonical `artifacts/investigations/verdict-*.json` (contains BOTH substrings) is misrouted to the 12-field markdown heading-grep branch, fails all `## `-heading assertions, is DENIED, and emits no marker (pipeline unreachable) | VP-HOOK-028 canonical-path leg (`.../verdict-alert-001.json` → JSON-first → 15-field path → marker emitted); mutant denies the verdict JSON and dies |
| SM-35 | require-review audit-log field encoding | **control-char-strip-removed** (ADV-F2-P4-010) — drop the `tr -d '\000-\037'` sanitization on `ticket_id`/`org_slug`/`op` so a `\n` embedded in `ticket_id` (Jira-content-influenced) forges an additional MARKER_USED line in `audit.log`, corrupting the chain-of-custody record | VP-HOOK-024 v1.5 audit leg (`ticket_id` containing `$'\n'` → exactly one MARKER_USED line; a forged second line fails the assertion) |
| **SM-38** *(NEW v1.10; occupancy-verified — next free after SM-37)* | disposition-guard emitter STEP 4 DENY-THE-WRITE | **step4-deny-removed** (ADV-F2-P7-001 CRITICAL) — remove the STEP-4 deny entirely, reverting to `emit allow without marker; RETURN` so an under-labeled hard-floor verdict is silently allowed with no marker, no deny, and no audit entry (the original P5-001 silent-discard failure mode) | **VP-HOOK-029 deny-path vectors (1)–(3)** (Indeterminate+create / HIGH+none / degraded-sensor+assign → verdict Write DENIED + `UNDER-LABEL-DENIED` audit) — the mutant produces a silent allow with no deny/audit and dies |
| **SM-39** *(NEW v1.10; occupancy-verified — next free after SM-38)* | disposition-guard STEP-4 deny corrective-reason structure | **deny-corrective-reason-removed** (ADV-F2-P7-004 MAJOR) — keep the STEP-4 deny but strip the machine-readable corrective-reason fields (`hard_floor_trigger`, `required_token`, `label_instruction`, `instruction`) from the deny message, emitting a bare/opaque deny — the Write is denied but the loop has no structured signal to re-document with the correct review token (the fail-loud becomes fail-STUCK) | **VP-HOOK-029 machine-actionable-reason vector (4)** (deny reason parses with `required_token=comment-review` / `create-review` + non-empty `hard_floor_trigger` + `label_instruction`) — the mutant emits a structureless deny and dies |
| **SM-40** *(NEW v1.10; occupancy-verified — next free after SM-39)* | require-review consumer STEP 6a `has_review_label` structural token check (D-DEC-001) | **has_review_label-reverted-to-raw-substring** (ADV-F2-P7-005 MINOR) — revert `structural_label_check(cmd)` (standalone `--label` token immediately preceding REVIEW-REQUIRED/BLIND-SPOT) to the defective raw-substring test `("--label REVIEW-REQUIRED" in command)` so a REGULAR create whose `--summary` merely CONTAINS the literal string is falsely flagged as review-labeled → false-DENY of a legitimate `["create"]`-marker create | **VP-HOOK-024 named vector `regular-create-with-label-literal-in-summary-allowed`** (regular create + `--summary "…--label REVIEW-REQUIRED…"` + `["create"]` marker → ALLOW) — under the mutant this legitimate create is wrongly DENIED and the mutant dies |

**New mutation vector count: 34 (SM-9 … SM-40; SM-32 = SM-32a + SM-32b + SM-32-ext as of v1.9; SM-32a re-targeted + SM-32-ext kill vector re-worded at v1.10; +SM-38/SM-39/SM-40).** SM-9..SM-16,
SM-21..SM-22, and SM-29..SM-30 land on the require-review + disposition-guard marker surface — the
CRITICAL authorization boundary (module-criticality: require-review C-12 CRITICAL ≥95%;
monitoring-loop surfaces CRITICAL at per-artifact granularity). SM-12 is the explicit
SEC-009-regression sentinel; SM-21 is the explicit ADV-F2-001 severity/confidence-conflation
sentinel; SM-23 is the ADV-F2-005 hard-floor-ordering sentinel; SM-28 is the ADV-F2-P2-001
document-before-action-ordering sentinel; **SM-29 is the ADV-F2-P3-001 unknown-asset hard-floor
sentinel (the pass-3 CRITICAL) and SM-30 is the ADV-F2-P3-003 artifact-class field-set sentinel.
SM-31 is the ADV-F2-P4-006 enum-membership-bypass sentinel, SM-33 the ADV-F2-P4-005
kill-switch-determinism sentinel, SM-34 the ADV-F2-P4-001 dispatch-collision sentinel (both pass-4
CRITICALs land here); SM-32a is the ADV-F2-P5-001 CRITICAL under-label silent-discard sentinel
(killed by VP-HOOK-029) and SM-32b the ADV-F2-P5-002 MAJOR over-label kill-switch-bypass sentinel
(killed by VP-HOOK-026) — the pass-5 under/over-label duals of the single "hook trusted the
LLM-supplied ticket_action_type" root cause; SM-35 the ADV-F2-P4-010 audit-forgery sentinel.**
**v1.9 (pass-6): SM-32-ext is the ADV-F2-P6-002 CRITICAL step-order sentinel (kill vector re-worded at
v1.10 to the deny-before-kill-switch assertion); SM-36 and SM-37 are the ADV-F2-P6-001 CRITICAL consumer
anti-fungibility sentinels (killed by VP-HOOK-024's STEP 6a exact-type vectors in both directions) — the
fungibility of review vs regular create markers was the pass-6 kill-switch/hard-floor bypass root cause.**
**v1.10 (pass-7): the STEP-4 DENY-THE-WRITE redesign replaces the retired marker-upgrade. SM-38 is the
ADV-F2-P7-001 CRITICAL step4-deny-removed sentinel (silent-allow re-appears; killed by VP-HOOK-029's
deny-path vectors); SM-39 is the ADV-F2-P7-004 MAJOR deny-corrective-reason-removed sentinel (the fail-loud
deny becomes fail-STUCK; killed by VP-HOOK-029's machine-actionable-reason vector); SM-32a is RE-TARGETED to
the ADV-F2-P7-001 "revert-deny-to-retired-upgrade" sentinel (unconsumable in-store marker; killed by
VP-HOOK-029's consumer-boundary vector — the O4 seam-gap guard); SM-40 is the ADV-F2-P7-005 MINOR
step-6a-raw-substring false-deny sentinel (killed by VP-HOOK-024's structural-check false-deny vector).**
With SM-9..SM-16 + SM-21..SM-22 + SM-28 + SM-29..SM-30 + **SM-31, SM-32a, SM-32b, SM-32-ext, SM-33..SM-40**
KILLED, the marker/authorization path meets the **≥95% require-review** target (SM-31/32a/32b/32-ext/33/34/38/39
land squarely on the disposition-guard emitter authorization boundary; SM-35/36/37/40 on the require-review
consumer + audit surface); SM-17..SM-20 + SM-23..SM-27 carry the disposition-guard JSON path, the
update-jira never-reopen guard (SM-26), and the monitoring-loop enforcement + dedup surface (SM-27) to
**≥90%**.

---

## 5. Test-Count Delta per BC (F3 story-sizing input)

Estimates are new **BATS test cases** (hooks.bats / skills.bats / integration.bats). Each new
`.sh`-backed behavior also requires a `.ps1` parity test (CONV-004); parity additions are
tracked separately and roughly mirror the hook/helper behavioral count.

| BC | VPs | New BATS (behavioral/structural/integration) | Parity (.ps1) add | Notes |
|----|-----|----------------------------------------------|--------------------|-------|
| BC-3.01.001 (v1.19) | VP-HOOK-024 | 21 — valid-comment-allow, **create-scoped-allow**, **assign-scoped-allow**, replay-deny, expired(EC-017, `expires_at_utc` past), future-dated, wrong-scope(EC-018), consumed(EC-019), malformed(EC-020), path-traversal(EC-021), wrong-ticket(EC-022, SEC-123 marker→DENY SEC-456), **rename-fail→deny**, missing-marker-dir fail-closed, **iterative-consume: concurrent-same-scope→oldest-consumed-allow**, **iterative-consume: all-renames-fail→exhausted-deny**, **v1.5 create-injection: --summary-injected-`--project`→DENY (P4-002)**, **v1.5 prefix: `--project PROD` marker + `--project PRODUCTION`→DENY (P4-002)**, **v1.5 audit: `\n`-in-`ticket_id`→single MARKER_USED line (P4-010, SM-35 kill)**, **v1.9 STEP 6a anti-fungibility: create-review marker + create WITHOUT `--label`→DENY (EC-023, SM-36 kill)**, **v1.9 STEP 6a reverse: create marker + create WITH `--label REVIEW-REQUIRED`→DENY (EC-023, SM-37 kill)**, **v1.10 STEP 6a structural false-deny prevention: `["create"]` marker + regular create with `--label REVIEW-REQUIRED` literal INSIDE `--summary`→ALLOW (structural token check, not raw substring — P7-005, SM-40 kill)** *(correct pairings — create-review+`--label`→ALLOW and create+no-label→ALLOW — are covered by the existing create-scoped-allow / valid-allow legs)* | ~16 | marker path is the SEC-009 regression surface; +3 (v1.5) create-pattern injection-safety (P4-002) + audit control-char (P4-010); +2 (v1.9) consumer STEP 6a anti-fungibility both directions (P6-001 CRITICAL); **+1 (v1.10) step-6a structural false-deny prevention (P7-005 MINOR, SM-40 kill)** |
| BC-3.03.001 (v1.16) | VP-HOOK-025, **VP-HOOK-028 (dispatch)** | 33 — **JSON-first dispatch: verdict-JSON class: 15** missing-field (one/field, incl. severity/asset_type/ticket_action_type) + all-15-present-allow; **investigation-markdown class: 12** missing-field (one/field) + all-12-present-allow + **Severity-heading-inserted→still-allow (no wrong-class 15-field deny, SM-30 kill)**; tuning_signal{null-TP-valid, null-FP-invalid, absent-invalid, non-null-FP-valid}; dual-path-routing; **confidence-float→deny + confidence∈{high,medium,low}→allow (4, D-DEC-011)**; **v1.5 validate_enums membership: severity="High"→DENY, severity="CRITICAL"→allow, asset_type="Unknown"→DENY, disposition="indeterminate"→DENY, sensor_health="Degraded"→DENY, ticket_action_type="NONE"→DENY (6, P4-006, SM-31 kill)** | ~24 | disposition-guard artifact-class branching + JSON-first dispatch; +6 over v1.3 for the validate_enums membership legs (ADV-F2-P4-006) |
| **BC-4.02.001 (v1.8)** *(NEW v1.2)* | VP-SKILL-066, VP-SKILL-067 | 9 — never-reopen{Resolved→propose-only-no-move (EC-007), Closed→create-new+link-no-move (EC-008), static no-autonomous-move grep}=3, SLA-surface{append-comment-has-stmt, link-has-stmt, propose-reopen-has-stmt, SLA-unknown-when-unretrievable, static format grep}=5, valid-marker-comment-allow happy path=1 | ~4 | update-jira path (distinct from monitoring-loop VP-SKILL-062); Inv#4 + Inv#5 |
| **BC-4.05.001 (v1.3)** *(NEW v1.3)* | VP-SKILL-070, VP-SKILL-071 | 10 — org_slug{PC#5a/5b/5d static WHERE-clause=3, DTU org-a-returns-zero-org-b/c=1, unscoped-query rejected=1}=5 (VP-SKILL-070), confidence-float→enum boundary{0.75→high, 0.749→medium, 0.40→medium, 0.399→low, inconsistent-pair-invalid}=5 (VP-SKILL-071) | ~2 | assess-priority PrismQL scoping + D-DEC-011 threshold boundaries (ADV-F2-P3-004/P3-008) |
| **BC-5.01.001 (v1.8)** *(NEW v1.3)* | VP-SKILL-069 | 4 — org_slug{static Iron-Law WHERE-clause on Stage-3 OCSF + temporal-adjacency blocks=2, DTU org-a-returns-zero-org-b/c=1, unscoped-query rejected=1} | ~1 | investigate-event PrismQL scoping (ADV-F2-P3-004); mostly static SKILL.md content assertion |
| BC-6.01.001 | VP-SKILL-051 | 8 — version below/at/above, dual-write settings.json + prism.mcp.json, RUST_LOG=off both, jr-auth blocking, malformed-settings stop, idempotent merge (EC-008..012) | ~6 | prism-version-check.sh + activate-mcp-config.sh |
| BC-6.01.003 | VP-SKILL-052, 053 | 6 — UUID-v7 reject, idempotent dir, org_slug dedup + 3 EC | ~2 | credential helper parity minimal |
| BC-6.01.004 | VP-SKILL-054, 055 | 6 — AD-017 no-paste, SELECT 1 present+gated, prism_describe-verify, cred-decline + EC | ~3 | credential-set.sh parity |
| BC-8.02.001 | VP-SKILL-056, 057 | 5 — 5-field completeness, naming/no-alias, >24h silence warning + EC | 0 | structural + prism-DTU |
| BC-9.01.001 | VP-SKILL-058, 059 | 5 — describe-first, org_slug scoping, zero-findings message, no-tables skip + EC | 0 | structural |
| BC-10.01.001 (v1.12) | VP-HOOK-026, VP-HOOK-027, VP-HOOK-028, **VP-HOOK-029**, VP-SKILL-050, **072**, **073**, **074**, 060, 061, 062, 063, **064**, **065**, **068** | 77 — hard-floor{Indeterminate, severity=HIGH, critical-asset, **unknown-asset+LOW+benign (1, VP-HOOK-026, ADV-F2-P3-001)**, T1003, degraded-sensor}=6, **v1.5 review-surfacing (hard_floor_applies()=TRUE positive controls){Indeterminate+create-review→marker=1, silent+comment-review→marker=1, HIGH+create-review→marker=1, authorized_operations=['create-review']=1 (VP-HOOK-026, D-DEC-012)}=4**, **v1.8 over-label gate (hard_floor_applies()=FALSE){non-hard-floor-TP+create-review→no-marker=1, non-hard-floor-FP+comment-review+autonomy=false→no-marker=1, LOW-standard+create-review→no-marker=1 (VP-HOOK-026, ADV-F2-P5-002, SM-32b kill)}=3**, **v1.5 kill-switch-determinism (STEP 5 post-reorder){autonomy=false+create→no-marker=1, +comment→no-marker=1, autonomy-absent→false→no-marker=1, autonomy=false+create-review→marker-still (exempt)=1 (VP-HOOK-026, P4-005, SM-33 kill)}=4**, **v1.10 fail-loud under-label DENY-THE-WRITE (STEP 4 deny; RETIRES the v1.9 marker-upgrade vectors — mechanism removed ADV-F2-P7-001){Indeterminate+create→verdict-Write-DENIED+UNDER-LABEL-DENIED-audit=1, HIGH+none→DENIED+audit=1, degraded-sensor+assign→DENIED+audit=1, machine-actionable-reason (required_token/hard_floor_trigger/label_instruction parse)=1, corrected-rewrite→STEP-3-review-marker happy path=1, consumer-boundary: create-review marker+correctly-labeled jr→ALLOW (authorized/consumable)=1, consumer-boundary: create-review marker+no-`--label` jr→DENY (unconsumable marker prevented — O4 seam guard)=1, kill-switch-irrelevance: deny fires with autonomy_enabled true AND false=1 (VP-HOOK-029, ADV-F2-P7-001/P7-004, SM-38/SM-39/SM-32a/SM-32-ext kill)}=8**, verdict-path-reachability{non-verdict-path→no-marker→jr-deny=1, verdict-path→marker→jr-allow control=1 (VP-HOOK-028)}=2, **v1.5 canonical-dispatch{investigations/verdict-*.json→15-field→marker (JSON-first)=1, investigation-*.md→12-field=1 (VP-HOOK-028, P4-001, SM-34 kill)}=2**, watermark{monotonic,future-reject}=2, **v1.5 first-run{no-watermark→24h-lookback-query=1, post-run-persist=1, existing-watermark→no-lookback control=1 (VP-SKILL-072, P4-012)}=3**, **v1.9 late-event{_time<watermark−GRACE→LATE_EVENT_DETECTED-audit+still-processed=1, in-window→no-detection control=1, first-run→no-false-positive=1 (VP-SKILL-073, P6-007)}=3**, **v1.9 severity-normalization{CrowdStrike 25→LOW/26→MEDIUM/76→CRITICAL=3, CVSS 3.9→LOW/9.0→CRITICAL=2, Armis Critical→CRITICAL+Informational→LOW case-fold=1, unrecognized→CRITICAL+uncertainty_explicit (auditable, not deny)=1 (VP-SKILL-074, P6-005, D-DEC-013)}=7**, **v1.10 Cyberint partition{any-Cyberint-native→CRITICAL (pre-ASM-008 default)=1, Cyberint-never-LOW/MEDIUM/HIGH-pre-ASM-008=1, Cyberint-CRITICAL-carries-uncertainty_explicit=1 (VP-SKILL-074, P7-006, D-DEC-013; update when ASM-008 resolves)}=3**, known-FP-before-enrich=2, **hard-floor-before-known-FP-autoclose (EC-009)=1**, BLIND-SPOT positive=2, never-reopen-closed=2, Tavily-degrade=2, `--bare`-absent wrapper assertion=1, allowlist-matches-SKILL=1, cross-hook ASM-009 integration=2, **org_slug{cross-tenant-org-a≠b/c=2, static query-construction check=1, unscoped-query adversarial=1}=4 (VP-SKILL-064)**, **kill-switch (RE-SCOPED v1.9, Option A carve-out){zero-REGULAR-markers=1, zero-REGULAR-jr-writes=1, evidence+draft-still-allowed=1, silent-sensor→create-review-jr-write-STILL-executes (exempt)=1}=4 (VP-SKILL-065)**, **stage-order{document-before-action positive=1, jr-before-Write→deny=1, TTL-expiry→deny=1}=3 (VP-HOOK-027)**, **grace-window-dedup{in-grace+existing-open-ticket→comment=1, in-grace+no-ticket→create=1, _time-normalize+boundary=1, dedup-off→double-ticket mutant kill=1}=4 (VP-SKILL-068)** | ~24 | monitoring-loop CRITICAL; **v1.10: VP-HOOK-029 fail-loud block re-scoped to DENY-THE-WRITE / consumer-boundary (9 upgrade-era vectors → 8 deny-era vectors, net −1; the 3 v1.9 marker-upgrade vectors RETIRED per ADV-F2-P7-001) + VP-SKILL-074 Cyberint partition (+3, P7-006) → net +2 on this BC**; (prior v1.9 +14: VP-HOOK-029 kill-switch-ON +3, VP-SKILL-065 carve-out +1, VP-SKILL-073 late-event +3, VP-SKILL-074 severity normalization +7) |

**Estimated new BATS test cases: ~181** (hooks/skills/integration; was ~178 at v1.9) + **~82 parity (.ps1)**
additions ≈ **~263 new test cases** for the cycle (was ~258). The **v1.10 pass-7 remediation** is a
net **+3 BATS** (the fail-loud block re-scope RETIRES vectors as it adds them): **+1 BC-3.01.001**
(VP-HOOK-024 step-6a structural false-deny prevention — P7-005, SM-40 kill) and **+2 BC-10.01.001**
(VP-HOOK-029 fail-loud DENY-THE-WRITE / consumer-boundary re-scope: 9 v1.9 upgrade-era vectors → 8
deny-era vectors = **net −1**, the three v1.9 marker-upgrade vectors RETIRED per ADV-F2-P7-001;
VP-SKILL-074 Cyberint partition **+3** — P7-006). Plus **~2 parity** (the step-6a structural check and
the STEP-4 deny each need a `.ps1` sibling per CONV-004; the Cyberint partition adds little parity).
The v1.10 mutants (SM-38 step4-deny-removed, SM-39 deny-corrective-reason-removed, SM-40
step-6a-raw-substring) all land on the CRITICAL disposition-guard/require-review authorization path
(the STEP-4 deny + consumer-boundary anti-fungibility), so these remain near-exhaustive
input-partition BATS on the marker path. The prior v1.9 pass-6 remediation added +16 BATS
(+2 BC-3.01.001 consumer STEP 6a anti-fungibility, +14 BC-10.01.001). This is consistent with the
CRITICAL/HIGH rigor bar in module-criticality.md (near-exhaustive input-partition BATS on the marker
path). F3 should size Wave-3 (marker mechanism), Wave-7 (monitoring-loop), the update-jira story, and
the investigate-event / assess-priority stories to absorb the BC-3.01.001 + BC-3.03.001 +
BC-10.01.001 + BC-4.02.001 + BC-4.05.001 + BC-5.01.001 test load (~115 of the ~155 new cases
concentrate on the hook/marker + org_slug surfaces — the pass-4 additions are almost entirely on the
disposition-guard emitter + require-review marker path).

---

## 6. Verification Strategy Notes (cross-cutting)

- **jr-mock** backs all VP-SKILL-060/061/062 and the ASM-009 integration tests (ticket
  create/comment/list JQL responses) so tests never touch a live Jira; **prism-DTU-demo-server**
  (`--config-dir <tmpdir>` mandatory per architecture-delta §Testing-Architecture) backs
  VP-SKILL-050/056/061 sensor/row/health fixtures.
- Every prism-invoking test MUST call the mandated `assert_prism_config_dir_set` helper and
  set `PRISM_CONFIG_DIR=$(mktemp -d)` in `setup()` to avoid corrupting the developer's real
  prism config.
- VP-HOOK-024/026 and the ASM-009 test share the `CLAUDE_PLUGIN_DATA=$(mktemp -d)` env-var
  fixture (answer (c)); marker-store isolation per test prevents cross-test bleed.
- The D-DEC-003 `--bare`-absent and D-DEC-010 allowlist-matches-SKILL assertions are pure
  structural greps over `run-monitoring-loop.sh` — cheap, high-value SEC guards folded into
  BC-10.01.001's count.
- **VP-SKILL-064 (org_slug scoping — the sole plugin-side cross-tenant isolation guarantee,
  D-DEC-005) uses three complementary legs:** (i) a prism-DTU-demo-server multi-org fixture with
  three orgs (org-a / org-b / org-c) seeded with distinguishable rows — a query issued in the
  org-a FOR-EACH context must return ZERO org-b/org-c rows (behavioral isolation proof);
  (ii) a static/structural check that the loop's PrismQL construction ALWAYS injects an
  `org_slug` constraint matching the current org context (grep the query-builder path — no
  code path emits a query without the constraint); (iii) an adversarial fixture that attempts an
  unscoped query — the loop must reject or auto-scope it, never issue it bare. This is the
  monitoring-loop analogue of the sibling structural VP-SKILL-059 (scan-threats), but promoted to
  a behavioral+adversarial integration property because the loop is autonomous (no human in the
  query-construction path). Mutant SM-24 (org_slug-drop) is the paired kill target.
- **VP-SKILL-065 (autonomy_enabled kill switch — Inv#11) — RE-SCOPED v1.9 (ADV-F2-P6-003 MAJOR / D-DEC-012
  Option A).** The pass-1 scope ("ZERO markers consumed AND ZERO `jr issue create/comment/assign` calls
  under `autonomy_enabled=false`") directly contradicted the human-confirmed Option A + EC-006/EC-014: a
  silent-sensor / Indeterminate (hard-floor) run WILL issue a `jr issue create … --label BLIND-SPOT`
  escalation write under the kill switch (that write IS the human-surface mechanism; suppressing it would
  silence the finding). VP-SKILL-065 is therefore **re-scoped, not silently FINALIZED — re-marked PROPOSED**
  this pass. The BATS integration test with `autonomy_enabled=false` injected now asserts, on a **regular
  (non-hard-floor FP)** verdict: the marker dir contains no consumed (`.used`) **REGULAR** markers AND the
  jr-mock spy records **zero REGULAR** `jr issue create/comment/assign` invocations, while evidence
  collection + verdict construction + Jira drafting still proceed (a `propose-only`-annotated draft is
  written); and, on a **silent-sensor (hard-floor)** verdict, a `create-review` marker IS emitted and the
  jr-mock spy DOES record the review escalation write (kill-switch EXEMPT via the STEP 3 correct-label
  review path, which runs before the STEP 5 kill switch; an under-labeled hard-floor verdict is denied at
  STEP 4 so the loop re-documents with the review token). This is the positive companion to VP-HOOK-026
  (which proves hard floors block REGULAR markers regardless of `autonomy_enabled=true`); VP-SKILL-065
  proves the global-off path halts only REGULAR autonomous writes. Mutant SM-25 (kill-switch-ignore) is the
  paired kill target for the REGULAR-suppression leg.
- **VP-HOOK-027 (stage-order document-before-action — P1 cross-hook, NEW v1.2) reuses the ASM-009
  cross-hook harness (answer (b))** but tests the *ordering* rather than single-use: the property
  is that require-review DENIES a Stage-8 `jr` write unless a Stage-7 verdict Write already caused
  disposition-guard to emit a matching scoped marker within the 120s TTL. The negative leg
  (`jr` Bash first, empty marker dir → deny) is the empirical guard the adversary said was missing
  (ADV-F2-P2-014) and would have caught the inverted-stage CRITICAL (ADV-F2-P2-001). Mutant SM-28
  (stage-order-inverted) is the paired kill target. This VP does NOT assert the monitoring-loop
  SKILL's internal stage numbering (that is a SKILL-prose/PO concern); it asserts the *hook-enforced
  consequence* of getting the order wrong — which is why it lives in VP-HOOK, not VP-SKILL.
- **VP-SKILL-066/067 (update-jira never-reopen + SLA surface, NEW v1.2)** are the missing
  update-jira-path guards (ADV-F2-P2-009a/b). VP-SKILL-062 asserts never-reopen on the autonomous
  monitoring-loop path; VP-SKILL-066 asserts it on the analyst-facing update-jira path (jr-mock
  Resolved→propose-only-halt, Closed→create-new+link, plus a static grep that no code path emits
  `jr issue move` out of Closed/Resolved — directly realizing BC-4.02.001 §Refactoring-Notes'
  stated formal-verification target). VP-SKILL-067 asserts every append/link/propose-reopen action
  emits the explicit SLA-impact statement, defaulting to "SLA: unknown — do not assume compliant"
  when `jr issue view` yields no SLA data. Mutant SM-26 (reopen-guard-removed) pairs with
  VP-SKILL-066.
- **VP-SKILL-068 (grace-window + Jira-first dedup, NEW v1.2)** closes the D-DEC-002 coverage gap
  (ADV-F2-P2-009c): VP-SKILL-050 tests only that the watermark is monotonic; VP-SKILL-068 tests
  that the *grace window's* re-fetch of late/out-of-order OCSF events does not double-ticket.
  prism-DTU seeds an event with normalized `_time` inside `[watermark − WATERMARK_GRACE_SECONDS,
  watermark]`; jr-mock returns an existing open ticket for it → assert the loop appends a comment
  (Stage-2 Jira-first dedup, D-DEC-002 §"Jira-first dedup") and does NOT `jr issue create`. Mutant
  SM-27 (dedup-check-removed→double-ticket) is the paired kill target: with dedup off, the
  re-fetched event creates a duplicate and the mutant dies.
- **VP-HOOK-026 unknown-asset leg (NEW v1.3, ADV-F2-P3-001 CRITICAL)** extends the existing
  hard-floor family with `asset_type=unknown`. The adversary's finding was a mis-propagation on the
  authorization boundary: BC-10.01.001 v1.9 Inv#10 policy already made `unknown` a conservative hard
  floor, but the disposition-guard emitter list (BC-3.03.001 Inv#4) and the `hard_floor_applies()`
  pseudocode omitted it, so a LOW-severity + benign + `asset_type=unknown` verdict with a SKILL-side
  `ticket_action_type!=none` label would get a REGULAR (autonomous-triage) marker → auto-write. The BATS
  test injects exactly that benign-but-unknown verdict with `autonomy_enabled=true` and **[UPDATED v1.8]**
  asserts NO regular (comment/create/assign-scoped) marker is written — a `create-review`/`comment-review`
  STEP-4 DENY-THE-WRITE of an under-labeled hard-floor verdict is acceptable (its fail-loud completeness is
  owned by VP-HOOK-029); what VP-HOOK-026 forbids is a regular autonomous-triage marker. Mutant SM-29
  (unknown-asset-hard-floor-removed) is the paired kill target (it issues a regular comment marker and
  dies). This is a pure hook-side guarantee (defense-in-depth independent of SKILL.md), which is why it
  stays on VP-HOOK-026.
- **VP-HOOK-025 12-vs-15 artifact-class split + confidence float→enum legs (NEW v1.3,
  ADV-F2-P3-003/P3-008)** close two VP-coverage seams the adversary flagged (ADV-F2-P3-013). The
  split makes the field-set an explicit per-class test axis: the investigation-markdown class checks
  the 12 ICD-203 headings ONLY (a valid 12-field investigation → allow; a spurious Severity heading →
  still allow, no wrong-class 15-field deny), while the verdict-JSON class checks all 15. Mutant SM-30
  (artifact-class-over-strict — apply the 15-field set to investigation markdown) dies on the
  investigation-12-field-accept test — this guards the ADV-F2-P3-003 regression where 15-field
  validation on investigation markdown would break the investigate-event DI-013 marker path. The
  float→enum legs assert disposition-guard's field#2 enum type-assertion DENIES a float `confidence`
  (e.g. `0.85`) and ALLOWS the three enum values — the hook-side backstop for D-DEC-011.
- **VP-HOOK-028 (verdict-path reachability — NEW v1.3, ADV-F2-P3-005) reuses the ASM-009 cross-hook
  harness (answer (b))** to prove the load-bearing verdict-file-path naming convention (BC-10.01.001
  Stage-7 PC#8). Because disposition-guard fast-path-allows any Write whose path lacks the `verdict`
  substring (no ICD-203 validation, no marker), a mis-named Stage-7 write silently emits no marker, and
  require-review then DENIES every downstream Stage-8 `jr` write (nothing to consume). The negative leg
  (Write to `artifacts/findings/alert-001.json` → empty marker dir → jr deny) proves the failure mode
  is fail-closed (action denied), and the positive control (`.../verdict-alert-001.json` → marker → jr
  allow) proves the convention is what gates reachability. No paired mutant is assigned (the property is
  a naming-convention reachability check on the fast-path branch, covered by SM-19's dual-path router
  mutant family); the value is the explicit reachability seam that had no owning VP.
- **VP-SKILL-069/070 (investigate-event + assess-priority org_slug scoping — NEW v1.3,
  ADV-F2-P3-004)** extend the D-DEC-005 tenant-isolation guarantee to the two remaining autonomous/
  semi-autonomous PrismQL surfaces the adversary found uncovered: VP-SKILL-064 covered only the
  monitoring-loop and VP-SKILL-059 only scan-threats. Both use the VP-SKILL-064 three-leg pattern —
  (i) static Iron-Law content assertion that every PrismQL block in the owning SKILL.md carries a
  `WHERE org_slug=` constraint (VP-SKILL-069: Stage-3 OCSF + temporal-adjacency; VP-SKILL-070:
  PC#5a/5b/5d); (ii) a prism-DTU multi-org fixture asserting an org-a query returns zero org-b/c rows;
  (iii) an adversarial unscoped-query fixture that must be rejected/scoped. VP-SKILL-069 leans more
  static (investigate-event is analyst-driven), VP-SKILL-070 pairs static + DTU behavioral. No new
  mutant beyond the existing SM-24 org_slug-drop pattern (the same mutation class applied per surface).
- **VP-SKILL-071 (assess-priority confidence float→enum consistency — NEW v1.3, ADV-F2-P3-008 /
  D-DEC-011)** is the producer-side companion to VP-HOOK-025's enum type-assertion. Architecture-delta
  §8.9 item 4 proposed a proptest/hypothesis property test, but this plugin's stack is declarative
  bash (no proptest — see `verification_stack`), so the property is realized as a BATS
  boundary/equivalence-partition test over the D-DEC-011 thresholds: `confidence_score` at and around
  0.75 and 0.40 must map to the correct enum (`0.75→high`, `0.749→medium`, `0.40→medium`, `0.399→low`,
  endpoints inclusive to the higher tier), and an inconsistent pair (`0.85`/`low`) is flagged invalid.
  This guarantees the enum handed to verdict field #2 is well-formed before disposition-guard
  (VP-HOOK-025) type-asserts it — the two VPs are complementary halves of the D-DEC-011 contract.
- **VP-HOOK-024 create-pattern injection-safety + audit sanitization (NEW v1.5, ADV-F2-P4-002
  CRITICAL / P4-010).** The pass-4 adversary showed the v1.4 create `command_pattern`
  `^jr (--output json )?issue create .*--project <key>` was defeated two ways: (a) the unbounded
  `.*` let an attacker-influenceable `--summary "…--project ORG_A…"` satisfy the `--project ORG_A`
  substring while the command actually targeted `--project ORG_B` (cross-org create bypass); (b) no
  trailing boundary let `--project PROD` prefix-match `--project PRODUCTION`. v1.5's tests pin the
  anchored fixed-position pattern `^jr (--output json )?issue create --project <key>( |$)` (`--project`
  first, trailing space-or-EOL) and assert the two attack commands DENY. The P4-010 leg asserts a `\n`
  embedded in `ticket_id` (Jira-content-influenced) cannot forge a second MARKER_USED audit line —
  `ticket_id`/`org_slug`/`op` are control-char-stripped (`tr -d '\000-\037'`) like the base64 command.
  These are consumer/emitter-side hook behaviors (require-review anchored match + audit; disposition-guard
  create-emitter pattern), so they stay on VP-HOOK-024. Mutant SM-35 (control-char-strip-removed) is the
  audit-forgery kill target; the injection legs kill the retired-`.*` regression class directly.
- **VP-HOOK-025 validate_enums() membership gate (NEW v1.5, ADV-F2-P4-006).** The adversary found the
  verdict-JSON check was key-presence-only while `hard_floor_applies()` keys on exact-string membership,
  so a case-mangled `severity:"High"` passed presence, silently missed the `∈{HIGH,CRITICAL}` membership
  test, escaped the hard floor, and got a marker for an actually-HIGH alert. v1.5 adds a
  `validate_enums(verdict)` step that runs BEFORE the hard-floor check and fail-closed-DENIES any
  non-member value on all six typed fields (severity, asset_type, disposition, sensor_health_status,
  ticket_action_type, confidence). Fail-closed DENY is deliberate — allow-without-marker would let a
  field-mangled verdict write to the investigation store without an ICD-203 guarantee. Mutant SM-31
  (validate_enums-removed) is the paired kill target.
- **VP-HOOK-026 review-surfacing + kill-switch determinism (extended v1.5, D-DEC-012 / ADV-F2-P4-004 /
  P4-005).** Two pass-4 corrections extend the hard-floor family without weakening it: (i) the D-DEC-012
  `create-review`/`comment-review` marker types are EXEMPT from the hard-floor no-marker rule and the
  kill switch (emitter Step 3 correct-label review path runs before the Step 5 kill switch; an under-labeled
  hard-floor verdict is denied at Step 4 — also before Step 5 — per the v1.10 deny-the-Write redesign, so the loop re-documents; both stay ahead of the Step 5 kill
  switch — post the ADV-F2-P6-002 reorder) because a `[REVIEW-REQUIRED]`/`[BLIND-SPOT]` ticket is human
  ESCALATION, not autonomous triage — new legs assert a hard-floor verdict WITH `create-review` DOES get
  a restricted marker (`authorized_operations=["create-review"]`), even under `autonomy_enabled=false`;
  (ii) the kill switch is read DIRECTLY by disposition-guard from the verdict's `autonomy_enabled`
  operational field (P4-005) rather than trusting the loop LLM to set `ticket_action_type=none`, so
  `autonomy_enabled≠true` (false OR absent→conservative false) suppresses ALL REGULAR markers. The
  original unconditional-hard-floor legs (Indeterminate/HIGH/critical-asset/unknown/T1003/degraded) are
  UNCHANGED for regular markers. Mutant SM-33 (autonomy_enabled-clause-removed → regular marker under
  kill switch) is the paired kill target for the kill-switch legs.
  **[EXTENDED v1.8 — over-label gate, ADV-F2-P5-002 MAJOR.]** Pass-4 treated the review-token exemption
  as UNCONDITIONAL on the LLM-supplied `ticket_action_type`; the adversary (P5-002) showed this let the
  LLM manufacture a kill-switch + hard-floor bypass by over-labeling a regular verdict as `create-review`.
  The architect's D-DEC-008 STEP 3 fix GATES the exemption on the hook-computed `hard_floor_applies(verdict)`
  (`IF NOT hard_floor_applies(): emit allow WITHOUT marker; RETURN`). New v1.8 over-label legs assert a
  NON-hard-floor verdict (disposition=TP, LOW severity, standard asset) carrying a review token gets NO
  marker — incl. under `autonomy_enabled=false` (no kill-switch bypass). The paired kill target is the
  RE-SCOPED **SM-32b** (step3-hard-floor-gate-removed → a non-hard-floor verdict with a review token gets
  the exempt marker; the over-label legs assert NO marker, so it dies). The review-surfacing positive
  controls (hard_floor_applies()=TRUE → marker emitted) remain valid under the gated STEP 3. This is the
  over-label dual of the VP-HOOK-029 under-label fail-loud invariant (SM-32a) — the two together close the
  P5-001/P5-002 single root cause (the hook trusting the LLM token without cross-checking hard_floor_applies).
- **VP-HOOK-028 JSON-first canonical-path dispatch (extended v1.5, ADV-F2-P4-001 CRITICAL).** The pass-3
  fix (mandate `verdict` in the Stage-7 path) collided with the canonical path
  `artifacts/investigations/verdict-<id>-<iso_ts>.json`, which contains BOTH `investigation` and `verdict`
  substrings. A plain "check `investigation` first" router misroutes the canonical verdict JSON to the
  12-field markdown branch → heading assertions fail → DENY → no marker → the entire autonomous pipeline
  is unreachable (the P4-001 CRITICAL). v1.5 pins the JSON-first dispatch order this doc already specified
  (JSON-content/`.json` → 15-field verdict path REGARDLESS of the `investigation` substring; `*investigation-*.md`
  → 12-field; else fast-path) as an explicit VP-HOOK-028 regression leg: `.../verdict-alert-001.json` →
  15-field path → marker (positive, NOT misrouted); `.../investigation-001.md` → 12-field. Mutant SM-34
  (dispatch-order-inverted) is the paired kill target. BC-3.03.001 v1.13 PC#1/2/3 own the rewritten dispatch.
- **VP-HOOK-029 end-to-end consumer-boundary fail-loud invariant (NEW v1.5; RE-SCOPED v1.8/v1.9; re-scoped
  END-TO-END + re-FINALIZED v1.10, P0, D-DEC-012 / ADV-F2-P7-001 CRITICAL / P7-004 MAJOR — O4 standing rule).**
  This is the closure of the mutual exclusion the adversary flagged: BC-10.01.001 v1.7 Inv#10 forced
  hard-floor verdicts to `ticket_action_type=none` (no marker), while EC-006/EC-014 required the loop to
  create `[BLIND-SPOT]` / `[REVIEW-REQUIRED]` tickets — so in unattended cron a hard-floor verdict was
  silently dropped. **Passes 5–6 (historical):** the fix deterministically UPGRADED an under-labeled
  hard-floor verdict to a `create-review`/`comment-review` marker at STEP 4 (moved before the STEP 5 kill
  switch at pass-6), with kill-switch-ON vectors added. **Pass-7 root cause + redesign (P7-001 CRITICAL):**
  the STEP-4 marker-*upgrade* was proved STRUCTURALLY UNSOUND — disposition-guard can rewrite the marker but
  NOT the loop's future Bash command. Under-labeling means the loop set a non-review `ticket_action_type` and
  will run the corresponding non-review command; the upgraded `create-review` marker requires `--label` in
  fixed second position, so for 3 of 4 under-label action types (create/assign/none) the loop's own command
  cannot match the upgraded marker's `command_pattern` → require-review DENIES the Stage-8 jr → **no ticket
  is ever created** and the CRITICAL finding is invisible to the analyst (only an audit line records it).
  The upgrade merely *moved* the silent drop from "no marker" to "marker present but structurally
  unconsumable by the command." **The mechanism is RETIRED; new STEP 4 = DENY-THE-WRITE:** disposition-guard
  DENIES the under-labeled verdict Write itself with a structured machine-readable corrective reason
  (`hard_floor_trigger`, `required_token` [create-review if ticket_id null, else comment-review],
  `label_instruction`, `instruction`) + an **UNDER-LABEL-DENIED** audit entry; NO marker; the loop
  re-documents with the required review token; on the corrected Write, STEP 3 issues the review marker
  normally. Non-termination is bounded fail-closed — the deny + audit ARE the loud failure; a loop that never
  re-documents is a BC-10.01.001 conformance defect, detectable by VP-HOOK-029's consumer-boundary
  assertion. STEP 4 still precedes the STEP 5 kill switch, so the deny fires regardless of
  `autonomy_enabled`. **Pass-7 verification gap (P7-004 MAJOR — O4):** the v1.9 VP-HOOK-029 assertion was
  EMITTER-ONLY ("a marker exists OR an error artifact was written"), which is satisfied even by an
  unconsumable marker — it could NOT detect the Write→Bash seam gap. Per the **O4 standing rule (§0)**,
  VP-HOOK-029 is re-scoped to assert the CONSUMER-BOUNDARY outcome: for ANY `ticket_action_type`, either
  (a) a review-token verdict yields a marker AND a correctly-labeled jr write that is authorized and
  CONSUMABLE at consumer STEP 6a (the escalation jr write actually occurs), or (b) a non-review-token verdict
  is DENIED at STEP 4 with a machine-actionable corrective reason + UNDER-LABEL-DENIED audit — NEVER a marker
  the loop's own command cannot consume, NEVER a silent allow. The consumer-boundary vectors (create-review
  marker + correctly-labeled jr → ALLOW; create-review marker + no-`--label` jr → DENY) are the O4 seam-gap
  guard; the kill-switch-irrelevance vector asserts the deny fires with `autonomy_enabled` true AND false.
  Reuses the ASM-009 cross-hook harness (disposition-guard emit → require-review consume + STEP 6a label
  match, BC-3.01.001 v1.19 step 6/6a). **Lifecycle: re-marked PROPOSED pending the deny-path vector set, then
  re-FINALIZED (P0) v1.10 per architecture-delta §8.17 item 1** — the convergence-blocking safety invariant
  is no longer deferred to F6. **The three v1.9 STEP-4 upgrade-marker vectors + the UNDER-LABEL-CORRECTED
  audit assertion are RETIRED (reason "mechanism removed ADV-F2-P7-001"; history preserved). Paired mutants:
  SM-38 (remove the STEP-4 deny → silent allow) killed by the deny-path vectors; SM-39 (remove the
  corrective-reason structure → deny fires but the loop cannot act) killed by the machine-actionable-reason
  vector; SM-32a (RE-TARGETED: revert the deny to the retired GOTO-WRITE_MARKER upgrade → unconsumable
  in-store marker) killed by the consumer-boundary unconsumable vector; SM-32-ext (revert STEP 4/5 order)
  killed by the kill-switch-irrelevance vector; all disjoint from SM-32b (over-label, killed by VP-HOOK-026).**
- **VP-HOOK-024 consumer STEP 6a anti-fungibility (NEW v1.9, ADV-F2-P6-001 CRITICAL).** The adversary showed
  that `create` and `create-review` markers had byte-identical `command_pattern`s and the consumer accepted
  either token for a `jr issue create`, so a `create-review` escalation marker could authorize a regular
  autonomous create (and vice versa) — a kill-switch + hard-floor bypass whenever a hard-floor verdict
  coexisted with a regular write in the same run. D-DEC-012's Alternatives-Rejected is REVERSED: hook-side
  label enforcement is now ADOPTED (a security control cannot live only in the untrusted SKILL.md Iron Law).
  The create-review `command_pattern` now encodes `--label (REVIEW-REQUIRED|BLIND-SPOT)` in FIXED second
  position after `--project <key>` (`^jr (--output json )?issue create --project <key> --label
  (REVIEW-REQUIRED|BLIND-SPOT)( |$)`), and require-review STEP 6a cross-checks BOTH directions: a
  `["create-review"]` marker is refused for a command lacking a review label (named vector
  `create-review-marker-requires-review-label`, kills SM-36), and a `["create"]` marker is refused for a
  command carrying a review label (named vector `create-marker-rejects-review-label`, kills SM-37); correct
  pairings consume normally (EC-023). `has_review_label` is a structural property of the command, not Jira
  content; the comment/comment-review structural `--label` check pends ASM-014, with ticket_id binding + Iron
  Law as the interim comment-review guard. This also mitigates P6-004 (single shared `PRISM-DEMO` project key
  makes per-org create-marker isolation infeasible; the review-label binding + single-use + TTL are the
  primary cross-org protection for create-review operations).
  **[EXTENDED v1.10 — STEP 6a structural-check false-deny prevention, ADV-F2-P7-005 MINOR / D-DEC-001
  `structural_label_check`.]** The adversary showed the v1.9 `has_review_label` was an UNANCHORED raw
  substring test over the whole command, which includes the LLM/attacker-influenceable `--summary` text: a
  benign FP-close create such as `jr issue create --project PRISM-DEMO --summary "rule matched literal --label
  REVIEW-REQUIRED in payload"` passes step-5's anchored regular-create pattern but then step-6a set
  `has_review_label=true` against its `["create"]` marker → the legitimate create was FALSE-DENIED. This is a
  content-vs-structure defect: the anchored step-5 `command_pattern` is the real structural security gate, so
  step-6a only produced false-denies (fail-closed, not a bypass). The D-DEC-001 fix makes step-6a STRUCTURAL —
  `structural_label_check(cmd)` splits the command into whitespace-separated tokens and returns true only when
  `--label` appears as a standalone token immediately preceding `REVIEW-REQUIRED`/`BLIND-SPOT` — so a
  `--summary` value merely containing the literal string does NOT trip it. New named vector
  `regular-create-with-label-literal-in-summary-allowed`: a `["create"]` marker + the label-in-summary create
  → **ALLOW** (not a false-deny). Paired mutant **SM-40** (revert to the raw-substring check) → the vector
  DENYs and the mutant dies. Security posture is unchanged (step-5 remains the gate); this only removes an
  operator-surprising false-deny.
- **VP-SKILL-073 late-event drop detection (NEW v1.9, ADV-F2-P6-007 MINOR, D-DEC-002).** The D-DEC-002
  monotonic watermark WRITE guard (`max(stored, ts)`) means once the watermark advances past a late event's
  `_time`, that event is never re-queried — a SILENT missed-alert path on the HIGH-criticality watermark
  store. `DETECT_LATE_EVENT()` (Stage-1 INGEST, called after `NORMALIZE_PRISM_TIME`) converts it to an
  AUDITABLE one: when an ingested event's normalized `_time` is older than `watermark − WATERMARK_GRACE_SECONDS`,
  it appends a `LATE_EVENT_DETECTED` line (with `event_time=`, `watermark=`, `grace_window=`) to
  `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log` and **processes the event normally** (never drops it). The
  BATS integration test injects a below-grace-floor event → asserts the audit line present AND the event
  reaches VALIDATE; control legs cover an in-window event (no detection) and first-run (no baseline → early
  return, no false positive). This gives operators the empirical signal to tune `WATERMARK_GRACE_SECONDS`
  during Wave-7 validation (ASM-008 is UNVALIDATED — prism `_time` format + ETL latency not yet known). No
  dedicated mutant beyond the D-DEC-002 watermark-guard family; the behavioral audit-entry assertion is the
  guard. Distinct from VP-SKILL-068 (in-grace dedup) and VP-SKILL-050 (monotonicity).
- **VP-SKILL-074 severity normalization correctness (NEW v1.9, ADV-F2-P6-005 MAJOR, D-DEC-013).** *(Namespace
  correction: architect §8.15 item 3 named this "VP-SKILL-072", which is OCCUPIED — first-run 24h lookback;
  allocated the next free VP-SKILL-074, see §1.)* prism normalizes four sensor families whose native
  severities are NOT the four-value enum (CrowdStrike numeric 1-100, Armis/Claroty risk bands, NVD/CVSS
  floats), and `disposition-guard`'s `validate_enums()` fail-closed-DENIES any non-member `verdict.severity`.
  Without a named normalization step a raw sensor severity (`"Medium"` wrong-case, `"70"`, `"9.1"`) would
  either be denied (pipeline-unreachable for that sensor family) or, via the "defaults to CRITICAL" rule,
  mass-escalate. `NORMALIZE_SEVERITY(native, family)` (D-DEC-013, a NAMED Stage-1 pre-processing step,
  re-applied at Stage-5 SCORE and on the Stage-1 known-FP fast-path) maps every native value to
  `{LOW,MEDIUM,HIGH,CRITICAL}` (case-exact, so `validate_enums()` never fails a well-normalized verdict); an
  UNRECOGNIZED value (any family, incl. Cyberint COMPUTE-AT-VALIDATION per ASM-008) → `CRITICAL` WITH
  `uncertainty_explicit` appended — an AUDITABLE conservative default, NEVER a silent enum-deny and NEVER a
  silent LOW. The VP is a BATS boundary/equivalence-partition test: CrowdStrike boundaries 26/51/76, CVSS
  boundaries 4.0/7.0/9.0, Armis case-fold (Critical→CRITICAL, Informational→LOW), and the unrecognized→CRITICAL
  +`uncertainty_explicit` auditable leg; it also asserts no raw sensor-native string ever reaches
  `validate_enums()`. No dedicated mutant (the `validate_enums()` fail-closed SM-31 is the downstream backstop
  if normalization regresses).
  **[EXTENDED v1.10 — Cyberint partition, ADV-F2-P7-006 MINOR / D-DEC-013 explicit conservative default.]**
  The adversary flagged that Cyberint is a RECOGNIZED family (org-b DTU demo, brief §4.2) whose per-band
  mapping is COMPUTE-AT-VALIDATION pending ASM-008, so the "unrecognized → CRITICAL" fallback did not
  cleanly fire and no concrete value was specified — a Cyberint alert could emit a non-enum placeholder that
  `validate_enums()` fail-closed-DENIES (that alert produces no verdict, no ticket) or an arbitrary tier
  (unsound hard-floor evaluation). D-DEC-013's Cyberint row is updated from the ambiguous
  COMPUTE-AT-VALIDATION to an EXPLICIT conservative default (mirrors the unrecognized-family rule, named):
  Cyberint → `CRITICAL` + `uncertainty_explicit` from first contact. Three strict partitions: (i) any
  Cyberint native severity → CRITICAL; (ii) Cyberint NEVER normalizes to LOW/MEDIUM/HIGH pre-ASM-008 (no
  down-tiering of an unvalidated family); (iii) the CRITICAL output carries `uncertainty_explicit` naming the
  unvalidated mapping. **These are pre-ASM-008 invariants — UPDATE WHEN ASM-008 RESOLVES: once the validated
  Cyberint per-band mapping lands, partitions (i)/(ii) are replaced by the real band boundaries (as with the
  other four families).** No dedicated mutant beyond SM-31 (the `validate_enums()` fail-closed backstop).
- **VP-SKILL-072 first-run 24h lookback correctness (NEW v1.5, ADV-F2-P4-012 / BC-10.01.001 Inv#13 /
  EC-001).** Dedicated VP for the absent-watermark bound that VP-SKILL-050 (monotonicity on an existing
  watermark) only mentioned incidentally. A loop-stub run against an EMPTY watermark dir must emit a
  PrismQL query bounded to `now() - INTERVAL 24 HOURS` (never a full-history scan) and persist a watermark
  at the latest processed `_time` after the run; control leg confirms an existing watermark does NOT take
  the 24h branch. No dedicated mutant (covered by the D-DEC-002 watermark-guard mutant family and the
  behavioral first-run assertion). Note: BC-10.01.001 Inv#15 (Resolved→propose-only, does NOT auto-reopen)
  is NOT given a new VP — it is already covered by **VP-SKILL-066** (update-jira never-auto-reopen,
  BC-4.02.001) on the analyst path and VP-SKILL-062 on the monitoring-loop path; §7 Part E records the
  cross-reference so Inv#15 is not left VP-orphaned.

---

## 7. BC Corrections Required (product-owner owns the BCs — I do NOT edit them)

These are reference-hygiene corrections surfaced by adjudication. None changes a property; all
are qualifier/stale-text/VP-reference cleanups. Listed for the product-owner to apply in the BC
files (I do NOT edit BCs — PO owns them).

**A. Prior v1.0 corrections — CONFIRMED APPLIED (no further action).** Re-verified against the
LIVE BCs at edit time:
- VP-HOOK-024 `(PROPOSED)` qualifier dropped in **BC-3.01.001 v1.12/v1.13** (FV-PROPOSED-DROP).
- VP-HOOK-025 stale "F1 draft listed only 8 fields" meta-instruction removed and dual-path
  mechanism reference added in **BC-3.03.001 v1.7/v1.8** and **BC-10.01.001 v1.1/v1.2**.
- VP-SKILL-051..063 `(PROPOSED)` qualifiers dropped across BC-6.01.001/6.01.003/6.01.004/
  8.02.001/9.01.001/10.01.001 (v1.1/v1.2 FV-PROPOSED-DROP).
- tuning_signal three-way "absent=always-invalid" leg made explicit in **BC-3.03.001 v1.7 PC#4**
  (Step 1 unconditional `has()` check) — SM-18 preempted.
- ADV-F2-007 marker "in conversation context or JIRA comments" wording removed from
  **BC-4.02.001 v1.5** Precondition #1 / EC-001 (out-of-band `${CLAUDE_PLUGIN_DATA}/markers/` now
  the sole source).

**B. Prior v1.1 corrections (VP-SKILL-064/065) — CONFIRMED APPLIED (ADV-F2-P2-005; no further
action; superseding the stale "still-owed" framing).** The four VP-SKILL-064/065 corrections
requested by v1.1 are now live in **BC-10.01.001 v1.3/v1.4** — re-verified this edit. The earlier
"pending / still-owed" language (and the circular BC-cites-§7-while-§7-says-owed loop the adversary
flagged in ADV-F2-P2-005) is **removed**; both VPs are **FINALIZED**:
- Invariant #1: `(PROPOSED — pending formal-verifier finalization)` qualifier DROPPED for
  VP-SKILL-064 (BC-10.01.001 v1.3 revision note; line ~139 "FINALIZED v1.3").
- Invariant #11: VP-SKILL-065 cross-reference ADDED (BC-10.01.001 v1.3; line ~268).
- Verification Properties table: VP-SKILL-064 + VP-SKILL-065 rows ADDED (BC-10.01.001 v1.3;
  lines ~376–377).
- VP Anchors footer: both VPs listed as FINALIZED (BC-10.01.001 v1.3; line ~390).
- Audit-log path (ADV-F2-P2-007) + iterative-consume (ADV-F2-P2-003): BC-3.01.001 **v1.14**
  aligned Invariant #2 / PC#2 to `${CLAUDE_PLUGIN_DATA}/markers/audit.log` and replaced the
  fail-fast consumer with iterative-consume — matching this delta's VP-HOOK-024 (§2). No further
  BC action.

**C. NEW corrections required by this v1.2 (VP-HOOK-027 + VP-SKILL-066/067/068 finalization).**
These are the only outstanding BC reference-hygiene items after pass 2. None alters a property.

1. **BC-10.01.001 Invariant #14 + Verification Properties table + VP Anchors footer
   (VP-HOOK-027 — stage-order document-before-action):** Invariant #14 (v1.4 corrected the
   Stage 7 DOCUMENT → Stage 8 TICKET ACTION ordering) carries the ordering fix but has **no VP
   cross-reference**. Add **VP-HOOK-027** (P1 cross-hook: a Stage-8 `jr` write is denied unless a
   Stage-7 verdict Write emitted a matching marker within TTL) to Invariant #14, add a row to the
   Verification Properties table, and append it to the VP Anchors footer. Strategy per §2
   (B-INT-XH: negative jr-before-Write→deny, positive correct-order→allow, TTL-expiry→deny).
2. **BC-4.02.001 Verification Properties table + Invariants #4/#5 (VP-SKILL-066/067):** the VP
   table currently lists only VP-SKILL-006/007/008 (line ~105) and Invariants #4 (never-auto-reopen)
   and #5 (SLA surface) have **no VP cross-reference**. Add **VP-SKILL-066** (Inv#4 never-auto-reopen
   on the update-jira path — the §Refactoring-Notes formal-verification target: no code path from
   PC#7c/PC#7d emits `jr issue move`) and **VP-SKILL-067** (Inv#5 SLA surface — append/link/
   propose-reopen emit an explicit SLA-impact statement) as VP-table rows and as the invariants'
   VP anchors.
3. **BC-10.01.001 Invariant #8 (dedup) / D-DEC-002 reference (VP-SKILL-068):** the dedup /
   grace-window invariant carries the D-DEC-002 grace-window + Jira-first dedup design but has no
   VP guarding it (VP-SKILL-050 is watermark-monotonicity only). Add **VP-SKILL-068** (in-grace
   re-fetched event with an existing open ticket → COMMENT not create) as the Invariant #8 / dedup
   VP anchor and a Verification Properties table row.
4. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register
   VP-HOOK-027, VP-SKILL-066, VP-SKILL-067, VP-SKILL-068 as FINALIZED (they occupy the
   previously-free 027 / 066 / 067 / 068 slots; VP-HOOK is now 024–027, VP-SKILL 001–068). No
   renumbering of any existing VP.

**D. NEW corrections required by this v1.3 (pass-3 VP finalization: VP-SKILL-069/070/071 +
VP-HOOK-028).** None alters a property; all are VP-cross-reference / status finalizations.

1. **BC-5.01.001 Invariant #8 + Verification Properties table (VP-SKILL-069):** BC-5.01.001 v1.8
   already lists VP-SKILL-069 as `PROPOSED — formal-verifier finalizes scope and BATS fixture`
   (Inv#8 + VP table row). **Drop the `PROPOSED` qualifier → FINALIZED** and confirm the strategy
   as authored (static Iron-Law WHERE-clause assertion on the Stage-3 OCSF + temporal-adjacency
   PrismQL blocks + prism-DTU multi-org org-a-returns-zero-org-b/c fixture + unscoped-query
   adversarial leg). Scope confirmed exactly as the BC states — no scope change.
2. **BC-4.05.001 Invariant #4 + PC#6 + Verification Properties table (VP-SKILL-070, VP-SKILL-071):**
   BC-4.05.001 v1.3 already lists VP-SKILL-070 as `PROPOSED` (Inv#4 org_slug + VP table row).
   **Drop the `PROPOSED` qualifier → FINALIZED** (strategy confirmed: static PC#5a/5b/5d WHERE-clause
   assertion + DTU multi-org fixture + unscoped-query leg). **Additionally add VP-SKILL-071** (PC#6 /
   D-DEC-011 confidence float→enum consistency — boundary test at 0.75/0.40) as a NEW Verification
   Properties table row and as the PC#6 VP anchor (BC-4.05.001 currently has no VP cross-reference for
   the float→enum mapping guarantee).
3. **BC-10.01.001 Stage-7 PC#8 + Invariant #9 field#2 + Invariant #10 (VP-HOOK-028, VP-HOOK-026
   unknown leg, D-DEC-011):** (a) add **VP-HOOK-028** (verdict-path reachability) as the PC#8
   verdict-file-path-naming-convention VP anchor + a Verification Properties table row; (b) confirm
   **VP-HOOK-026** now cross-references the `asset_type=unknown` hard-floor member in Invariant #10
   (BC-10.01.001 v1.9 Inv#10 already includes `unknown`; the VP anchor should name the unknown leg
   explicitly); (c) Invariant #9 field#2 confidence-is-enum-only note should cross-reference
   **VP-HOOK-025** (already the field-completeness VP) for the float-reject assertion.
4. **BC-3.03.001 Invariant #4 hard-floor list + PC#2/PC#3 (VP-HOOK-026 unknown leg, VP-HOOK-025
   per-class split):** (a) Invariant #4 hard-floor list — once BC-3.03.001 v1.13 adds the
   `asset_type=='unknown'` bullet (architecture-delta §8.8.1 item 1), the **VP-HOOK-026** anchor
   should name the unknown leg; (b) PC#2 (investigation markdown = 12 fields) and PC#3 (verdict JSON =
   15 fields) are the per-class field-set surfaces for **VP-HOOK-025** — confirm both PCs cite
   VP-HOOK-025 with the 12-vs-15 split made explicit (architecture-delta §8.8.1 item 3 corrects the
   PC#2 15→12 erratum).
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register
   **VP-SKILL-069, VP-SKILL-070, VP-SKILL-071, VP-HOOK-028** as FINALIZED (they occupy the
   previously-free 069 / 070 / 071 / 028 slots — 069/070 already PROPOSED-referenced in BC-5.01.001 /
   BC-4.05.001; VP-SKILL is now 001–071, VP-HOOK 024–028). Update the **VP-HOOK-025** and
   **VP-HOOK-026** entries for the per-class split and unknown-asset leg. No renumbering of any
   existing VP.

**E. NEW corrections required by this v1.5 (pass-4: VP-HOOK-029 + VP-SKILL-072 + VP-HOOK-024/025/026/028
extensions).** None alters a property; all are VP-cross-reference / status additions on the pass-4
BCs (BC-3.03.001 v1.13, BC-3.01.001 v1.17, BC-10.01.001 v1.9, BC-4.02.001 v1.8, BC-6.01.001 v1.5).
These are the outstanding BC VP-anchor additions the PO must apply — I do NOT edit the BCs.

1. **BC-10.01.001 — VP-HOOK-029 (fail-loud, P1) + VP-SKILL-072 (first-run 24h lookback) + Inv#15
   cross-ref.** (a) Add **VP-HOOK-029** as the VP anchor for the narrowed Invariant #10 / D-DEC-012
   fail-loud guarantee (hard-floor verdict → `create-review`/`comment-review` marker OR explicit error,
   never silent discard) + a Verification Properties table row. Architect §8.11 item 6 tags it **P1**
   and requests **PROPOSED** lifecycle status (F6-adjudicated) — register accordingly. (b) Add
   **VP-SKILL-072** as the VP anchor for **Invariant #13** (first-run 24h lookback) / EC-001 + a VP-table
   row (currently Inv#13 has no VP cross-reference; VP-SKILL-050 covers monotonicity only). (c)
   **Invariant #15** (Resolved→propose-only) needs no new VP — add an explicit cross-reference that it is
   covered by **VP-SKILL-066** (update-jira never-auto-reopen, BC-4.02.001) and VP-SKILL-062
   (monitoring-loop path), so Inv#15 is not left VP-orphaned. (d) Confirm **VP-HOOK-028** now cites the
   Stage-7 PC#8 JSON-first dispatch (not merely `verdict`-substring reachability). (e) Confirm Invariant
   #9 now lists `autonomy_enabled` among the non-ICD-203 operational metadata fields with a **VP-HOOK-026**
   determinism cross-reference.
2. **BC-3.03.001 v1.13 — PC#1/2/3 JSON-first dispatch + validate_enums + review-surfacing.** (a) PC#1/2/3
   (rewritten to JSON-first per architecture-delta v1.6 §A) are the VP-HOOK-028 dispatch surface — cite
   **VP-HOOK-028** on the dispatch precedence (JSON/`.json` → verdict-class regardless of `investigation`
   substring). (b) Invariant #4 / PC#3 emitter — cite **VP-HOOK-025** for the `validate_enums()`
   membership gate (fail-closed DENY on non-member severity/asset_type/disposition/sensor_health_status/
   ticket_action_type/confidence, BEFORE hard floor). (c) The D-DEC-012 review-surfacing emitter branch
   (create-review/comment-review markers, hard-floor + kill-switch EXEMPT) and the `autonomy_enabled`
   read-direct-from-verdict Step 4 — cite **VP-HOOK-026** (and **VP-HOOK-029** for the fail-loud emit).
3. **BC-3.01.001 v1.17 — consumer create-pattern + audit sanitization + review-token acceptance.** (a)
   Consumer step (5) anchored create `command_pattern` (`--project` first, `( |$)` trailing) — cite
   **VP-HOOK-024** for the injection-safety guarantee (--summary injection + PROD/PRODUCTION prefix →
   DENY). (b) Consumer step (8) audit control-char stripping (`ticket_id`/`org_slug`/`op`) — cite
   **VP-HOOK-024** (audit-forgery leg). (c) Consumer step (6) acceptance of `create-review`/
   `comment-review` `authorized_operations` tokens — cite **VP-HOOK-029** (the fail-loud escalation
   consumer path).
4. **BC-4.02.001 v1.8 — PC#4 cross-tenant stale removal (P4-008) + Inv#15 cross-ref confirm.** (a)
   Confirm the P4-008 removal of "cross-tenant campaign correlation findings" from the PC#4 hard-floor
   enumeration (align with BC-3.03.001/BC-3.01.001 post-P3-011). (b) Confirm **VP-SKILL-066** remains the
   anchor for the Resolved→propose-only never-auto-reopen guarantee that BC-10.01.001 Inv#15 cross-refs.
   (No new VP.)
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register
   **VP-SKILL-072** as FINALIZED and **VP-HOOK-029** as **PROPOSED** (P1, F6-adjudicated per architect
   §8.11 item 6) in the previously-free 072 / 029 slots. Update the **VP-HOOK-024/025/026/028** entries
   for the pass-4 extensions (injection-safety, validate_enums, review-surfacing + kill-switch, JSON-first
   dispatch). VP-SKILL is now 001–072, VP-HOOK 024–029. No renumbering of any existing VP.

**F. NEW corrections required by this v1.8 (pass-5 re-scope: VP-HOOK-029 + VP-HOOK-026 + SM-32a/32b).**
*(HISTORICAL — the STEP numbering below is the v1.8-era layout; the ADV-F2-P6-002 STEP REORDER at v1.9
renumbers the under-label upgrade from STEP 5 → **STEP 4** (now before the STEP 5 kill switch). See Part G
for the current, superseding v1.9 numbering.)*
The disposition-guard STEP 3 (over-label gate) and STEP 5 (under-label fail-loud upgrade — **renumbered to
STEP 4 at v1.9**) emitter BODY updates are owned by the product-owner per architecture-delta v1.8 §8.12
(BC-3.03.001 STEP 3+STEP 5; BC-10.01.001 Inv#10 ticket_action_type under-label semantics) — I do NOT edit
the BCs. The FV-side cross-references the PO should reflect when applying those STEP updates:
1. **BC-3.03.001 v1.13 Inv#4 emitter — STEP 3 over-label gate + STEP 5 under-label upgrade.** (a) The
   STEP 3 review-marker exemption gated on `hard_floor_applies(verdict)=TRUE` (over-labeled non-hard-floor
   verdict with a review token → allow-without-marker) — cite **VP-HOOK-026** (over-label legs, SM-32b).
   (b) The STEP 5 deterministic upgrade of an under-labeled hard-floor verdict to create-review/comment-review
   (or error-artifact+deny when no `jira_project_key`) with an UNDER-LABEL-CORRECTED audit entry — cite
   **VP-HOOK-029** (under-label fail-loud vectors, SM-32a).
2. **BC-10.01.001 v1.9 Inv#10 — narrowed under-label semantics.** Inv#10 (hard floor → create-review/
   comment-review, and STEP 5 fail-loud-upgrades under-labeled hard-floor verdicts, never silent `none`)
   — confirm **VP-HOOK-029** remains its anchor (the fail-loud guarantee) and **VP-HOOK-026** the
   over-label gate. No new VP; no renumbering.
3. **VP-INDEX.md + verification-coverage-matrix.md:** re-scope the **VP-HOOK-029** entry from the pass-4
   happy-path scope to the under-label fail-loud scope (fix-priority P0), and add the **VP-HOOK-026**
   over-label legs. Record **SM-32** as split into **SM-32a** (under-label, VP-HOOK-029) and **SM-32b**
   (over-label, VP-HOOK-026). VP namespace UNCHANGED (VP-SKILL 001–072, VP-HOOK 024–029).

**G. Corrections required by v1.9 (pass-6: VP-HOOK-029 FINALIZE + kill-switch-on vectors,
consumer STEP 6a, VP-SKILL-065 re-scope, VP-SKILL-073 late-event, VP-SKILL-074 severity normalization,
SM-32-ext / SM-36 / SM-37).** *(PARTIALLY SUPERSEDED — the STEP-4 marker-UPGRADE mechanism below is RETIRED
at v1.10; ADV-F2-P7-001 replaces it with STEP-4 DENY-THE-WRITE. The consumer STEP 6a, VP-SKILL-065 carve-out,
VP-SKILL-073, VP-SKILL-074, and SM-36/SM-37 corrections REMAIN VALID. See Part H for the superseding v1.10
deny-the-Write cross-references and the VP-HOOK-029 end-to-end re-scope.)* The BODY updates — the
disposition-guard STEP REORDER (STEP 4 under-label upgrade before STEP 5 kill switch), the consumer STEP 6a anti-fungibility cross-check + the create-review
`command_pattern` `--label` addition, the Inv#11 Option-A carve-out, the D-DEC-013 severity-normalization
step, and the D-DEC-002 late-event detection — are owned by the product-owner per architecture-delta v1.9
§8.14 (BC-3.03.001 STEP reorder + pattern; BC-3.01.001 consumer STEP 6a; BC-10.01.001 Inv#11 carve-out +
VP-SKILL-065 re-scope + severity normalization + late-event). I do NOT edit the BCs. FV-side
cross-references the PO should reflect (live-BC targets: **BC-3.01.001 v1.18, BC-3.03.001 v1.15,
BC-10.01.001 v1.11**):
1. **BC-3.03.001 v1.15 Inv#4 emitter — STEP REORDER + STEP 4 upgrade + create-review pattern.** (a) The
   STEP 4 under-label upgrade now runs BEFORE the STEP 5 `autonomy_enabled` kill switch (ADV-F2-P6-002) —
   cite **VP-HOOK-029** (under-label fail-loud + kill-switch-ON under-label vectors, SM-32a + SM-32-ext).
   (b) The create-review `command_pattern` now carries `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed
   second position after `--project <key>` — cite **VP-HOOK-024** (consumer STEP 6a anti-fungibility).
2. **BC-3.01.001 v1.18 — consumer STEP 6a anti-fungibility (P6-001 / EC-023).** Cite **VP-HOOK-024** for
   the both-direction cross-check (create-review marker refused for a no-`--label` command; create marker
   refused for a `--label` command; correct pairings consume) and the create-review pattern `--label` add.
3. **BC-10.01.001 v1.11 — Inv#10/11 + Stage-1.** (a) Inv#10 STEP 4 fail-loud (reordered before the kill
   switch) — confirm **VP-HOOK-029** FINALIZED (was PROPOSED) is its anchor. (b) Inv#11 Option-A carve-out
   ("under `autonomy_enabled=false`, zero REGULAR markers/writes; create-review/comment-review escalation
   writes for genuine hard-floor verdicts still execute") — cite **VP-SKILL-065** (RE-SCOPED, PROPOSED).
   (c) Stage-1 severity normalization (field 13, D-DEC-013) — add **VP-SKILL-074** as VP anchor + VP-table
   row (namespace-corrected from the architect's "VP-SKILL-072"). (d) Stage-1 late-event fail-loud
   (D-DEC-002 `DETECT_LATE_EVENT`) — add **VP-SKILL-073** as VP anchor + VP-table row.
4. **VP-INDEX.md + verification-coverage-matrix.md:** (a) **FINALIZE VP-HOOK-029** (PROPOSED → FINALIZED,
   P0) with the kill-switch-on under-label vectors. (b) **RE-SCOPE VP-SKILL-065** (FINALIZED → PROPOSED,
   Option-A carve-out). (c) register **VP-SKILL-073** (P1, PROPOSED, next-free 073) and **VP-SKILL-074**
   (P1, PROPOSED, next-free 074 — NOT 072, which is occupied). (d) add mutants **SM-32-ext** (under the
   SM-32 family), **SM-36**, **SM-37** (NOT SM-33/SM-34, which are occupied pass-4 sentinels). VP namespace
   now VP-SKILL 001–074, VP-HOOK 024–029; SM 9–37. No renumbering of any existing VP or SM.

**H. NEW corrections required by this v1.10 (pass-7: STEP-4 DENY-THE-WRITE redesign + VP-HOOK-029 end-to-end
re-scope + step-6a structural fix + Cyberint mapping + O4 standing rule; SM-38 / SM-39 / SM-40).** The BODY
updates — the disposition-guard STEP-4 DENY-THE-WRITE (marker-upgrade RETIRED), the consumer step-6a
`structural_label_check`, the D-DEC-013 explicit Cyberint conservative default, and the six stale
"no marker for hard floor" locations (EC-015/016/017/021 + two canonical test vectors — P7-002) — are owned
by the product-owner per architecture-delta v1.10 §8.16. I do NOT edit the BCs. FV-side cross-references the
PO should reflect (live-BC targets: **BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12**):
1. **BC-3.03.001 v1.16 Inv#4 emitter — STEP 4 DENY-THE-WRITE (upgrade RETIRED).** (a) The under-labeled
   hard-floor verdict is now DENIED at STEP 4 with a structured corrective reason (`hard_floor_trigger`,
   `required_token`, `label_instruction`, `instruction`) + an `UNDER-LABEL-DENIED` audit entry (NO marker;
   `UNDER-LABEL-CORRECTED` RETIRED) — cite **VP-HOOK-029** (deny-path + machine-actionable-reason vectors;
   SM-38, SM-39, re-targeted SM-32a, SM-32-ext). STEP 4 remains before the STEP 5 kill switch.
2. **BC-3.01.001 v1.19 — consumer step-6a structural token check + review-token acceptance.** (a) Consumer
   step-6a `structural_label_check` (`--label` as a standalone token preceding REVIEW-REQUIRED/BLIND-SPOT,
   not a raw substring over the whole command) — cite **VP-HOOK-024** (false-deny-prevention vector; SM-40).
   (b) Consumer step (6) acceptance of `create-review`/`comment-review` tokens is the CONSUMER-BOUNDARY
   surface for VP-HOOK-029's end-to-end assertion (the escalation jr write is authorized AND consumable) —
   cite **VP-HOOK-029** (consumer-boundary vectors).
3. **BC-10.01.001 v1.12 — Inv#10 + Stage-1 + six stale locations.** (a) Inv#10 STEP-4 DENY-THE-WRITE
   (reordered before the kill switch) — confirm **VP-HOOK-029** (re-scoped end-to-end, re-FINALIZED P0) is
   its anchor; the fail-loud guarantee is now the CONSUMER-BOUNDARY jr authorization/execution outcome per
   the O4 standing rule (§0), NOT an emitter-local marker. (b) The loop re-document obligation on a STEP-4
   deny (re-issue the Write with `required_token`) — VP-HOOK-029's corrected-rewrite happy-path vector is its
   verification. (c) The six pre-D-DEC-012 "no marker for hard floor" locations (EC-015/016/017/021 + two
   canonical test vectors, P7-002 CRITICAL) that a story-writer/FV could otherwise encode as the
   silent-discard bug — confirm they are updated to the post-D-DEC-012 semantics before any test authoring;
   VP-HOOK-029's negative assertion (a hard-floor verdict must NOT leave the marker dir empty with no
   deny/audit, and must NOT hold an unconsumable marker) is the guard. (d) Stage-1 field-13 Cyberint mapping
   (D-DEC-013 explicit CRITICAL + uncertainty_explicit) — cite **VP-SKILL-074** (Cyberint partition).
4. **VP-INDEX.md + verification-coverage-matrix.md:** (a) **RE-SCOPE + re-FINALIZE VP-HOOK-029** (re-marked
   PROPOSED, then FINALIZED P0) to the end-to-end consumer-boundary deny-the-Write scope (O4); mark the three
   v1.9 upgrade-marker vectors + the UNDER-LABEL-CORRECTED audit assertion RETIRED (reason "mechanism removed
   ADV-F2-P7-001"). (b) update the **VP-HOOK-024** entry for the step-6a structural false-deny vector and the
   **VP-SKILL-074** entry for the Cyberint partition. (c) add mutants **SM-38** (step4-deny-removed), **SM-39**
   (deny-corrective-reason-removed), **SM-40** (has_review_label-raw-substring); record SM-32a RE-TARGETED and
   SM-32-ext kill vector RE-WORDED. (d) codify the **O4 standing rule** (§0). VP namespace UNCHANGED at
   VP-SKILL 001–074, VP-HOOK 024–029; SM now 9–40 (occupancy re-verified before allocation, Lesson 8). No
   renumbering of any existing VP or SM.

No corrections alter any invariant, EC, or postcondition semantics (the P7-002 stale-EC propagation is a
PO-owned text alignment, not a semantic change). All delta BCs are otherwise
internally consistent with the finalized **31-VP** set (VP-SKILL 001–074, VP-HOOK 024–029; v1.10 adds no
new VP — VP-HOOK-029 re-scoped in place, VP-HOOK-024 / VP-SKILL-074 extended)
and the SM-N catalog (SM-9..SM-40, **34 mutants** with SM-32 = SM-32a + SM-32b + SM-32-ext; +SM-38/SM-39/SM-40 at v1.10).
Cross-doc/other-file version-ref reconciliation (prd-delta, VP-INDEX headers, inter-BC citations) is
explicitly NOT chased here — the dedicated version-coherence sweep owns global reconciliation after this
edit (ADV-F2-P3-007/P3-009).

---

*F2 Verification Delta v1.10 complete. **31 VPs** (0 collisions, 0 renumbering): VP-SKILL 001–074,
VP-HOOK 024–029 (v1.10 adds no new VP — VP-HOOK-029 re-scoped in place, VP-HOOK-024 / VP-SKILL-074 extended).
**Pass-7 remediation (ADV-F2-P7-001/004/005/006/009, architecture-delta v1.10 §8.17):** the CENTRAL change
is that the STEP-4 marker-UPGRADE mechanism (P5-001/P6-002) is **RETIRED** and replaced by
**DENY-THE-WRITE** — P7-001 CRITICAL proved the upgrade unsound (disposition-guard can rewrite the marker
but not the loop's future Bash command → 3 of 4 under-label action types produced an unconsumable marker and
a silently-dropped finding). **(1) [P7-001/P7-004 — O4]** **VP-HOOK-029 re-scoped END-TO-END** (emitter-only
"marker OR error" → CONSUMER-BOUNDARY jr authorization/execution outcome per the O4 standing rule §0):
re-marked PROPOSED then **re-FINALIZED P0**. New property — hard-floor verdict with ANY `ticket_action_type`:
(review token) → marker at STEP 3 AND a correctly-labeled jr write authorized/consumable at consumer STEP 6a;
(non-review token incl. `none`) → verdict Write **DENIED** at STEP 4 with a structured corrective reason
(`hard_floor_trigger`/`required_token`/`label_instruction`) + **UNDER-LABEL-DENIED** audit — NEVER an
unconsumable marker, NEVER a silent allow. **RETIRED** the three v1.9 STEP-4 upgrade-marker vectors + the
UNDER-LABEL-CORRECTED audit assertion (reason "mechanism removed ADV-F2-P7-001"; history preserved).
**Added** deny-path vectors (create/assign/none under-label deny+audit; corrected-rewrite happy path;
consumer-boundary consumable/unconsumable; kill-switch-irrelevance — deny fires with `autonomy_enabled` BOTH
true and false, STEP 4 before STEP 5). **(2) Mutants (occupancy re-verified, Lesson 8 — SM-37 was max real,
SM-2026 a date false-positive): SM-38** (step4-deny-removed → silent allow; killed by the deny-path vectors),
**SM-39** (deny-corrective-reason-removed → deny fires but the loop cannot act; killed by the
machine-actionable-reason vector); **SM-32a RE-TARGETED** (revert the deny to the retired GOTO-WRITE_MARKER
upgrade → unconsumable in-store marker; killed by the consumer-boundary vector); **SM-32-ext** kill vector
RE-WORDED to the deny-before-kill-switch assertion. **(3) [P7-005 MINOR]** **VP-HOOK-024** step-6a
`structural_label_check` false-deny-prevention vector (regular create with a `--label REVIEW-REQUIRED`
literal inside `--summary` → ALLOW) + paired **SM-40** (raw-substring revert). **(4) [P7-006 MINOR]**
**VP-SKILL-074** Cyberint partition (3 vectors — any Cyberint native severity → CRITICAL pre-ASM-008
conservative default; never LOW/MEDIUM/HIGH pre-ASM-008; CRITICAL carries uncertainty_explicit; "update when
ASM-008 resolves"). **(5) [P7-009 OBS]** **O4 standing rule codified (§0)** — emitter-local artifacts never
suffice as evidence for a consumer-boundary guarantee. STEP-4-upgrade / UNDER-LABEL-CORRECTED / marker-in-store
fail-loud phrasing swept to deny-the-Write throughout (SM catalog / VP rows / §3/§6 notes / §7 Part H /
this snapshot); VP-SKILL-065's regular-vs-review carve-out phrasing UNCHANGED. **34 SM-N mutants
(SM-9..SM-40, SM-32 = SM-32a + SM-32b + SM-32-ext)** — all on the CRITICAL disposition-guard/require-review
authorization path (≥95%). **~181 new BATS + ~82 parity ≈ ~263** test cases estimated for F3 sizing (was
~258; net +3 BATS — BC-3.01.001 step-6a false-deny +1; BC-10.01.001 VP-HOOK-029 deny-the-Write re-scope
net −1 [3 upgrade vectors RETIRED] + VP-SKILL-074 Cyberint +3). Live-BC targets at v1.10 edit time (pass-7):
**BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12** (STEP-4 deny-the-Write + step-6a structural fix
+ six stale-EC propagation + Cyberint mapping BODY owned by PO per architecture-delta §8.16); verification-delta
made internally self-consistent (VP table, mutant catalog, §3 discussion, §5 counts, §6 notes, §7). FV
cross-references routed to PO in §7 Part H. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref
reconciliation deferred to the dedicated version-coherence sweep (ADV-F2-P3-007/P3-009).*

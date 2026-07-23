---
document_type: behavioral-contract
level: L3
version: "1.14"
status: draft
producer: product-owner
timestamp: 2026-07-20T00:00:00
phase: f2
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/update-jira/SKILL.md, plugins/secops-factory/tests/skills.bats, phase-f2-spec-evolution/architecture-delta.md]
input-hash: "COMPUTE-AT-COMMIT"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/update-jira/SKILL.md
subsystem: vulnerability-pipeline
capability: CAP-VULN-02
lifecycle_status: active
introduced: v0.6.0
modified: ["v0.9.x-PR13-2026-07-19", "v1.1-ADV-0-601-2026-07-19", "v1.2-ADV-0-706-2026-07-19", "v1.3-ADV-0-901-2026-07-19", "v1.4-DI-013-SEC-3.4-2026-07-20", "v1.5-ADV-F2-007-2026-07-20", "v1.6-FV-VP-ANCHOR-066-067-2026-07-20", "v1.7-P4-008-consistency-F1-F2-2026-07-21", "v1.8-version-coherence-sweep-2026-07-21", "v1.9-ADV-F2-P11-004-12field-hard-floor-reconcile-2026-07-22 [ID-sync per FV]", "v1.10-ADV-F2-P15-001-P15-005-markdown-path-no-comment-marker-2026-07-22", "v1.11-ADV-F2-P16-001-gate1-first-human-path-2026-07-22", "v1.12-CV-001-CV-002-CV-003-version-cite-current-2026-07-23", "v1.13-ADV-F2-P18-001-003-004-link-close-gated-mutation-compound-D020-D022-2026-07-23", "v1.14-ADV-F2-P19-004-rule2-create-link-2026-07-23"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-4.02.001: update-jira Skill — Review-Gated Jira Field Update

> **Revision history:**
> - v1.14 (2026-07-23): Pass-19 adversarial remediation — ADV-F2-P19-004 (OBS, §3.4 rule 2 = create+link per HUMAN DECISION 2026-07-23). **PC#7b rewritten (P19-004/D-022):** §3.4 rule 2 (same asset, different root cause, open ticket) updated from comment+link to create+link — each root cause has its own ticket. verdict-1 (`ticket_action_type=create`) → create marker → Stage 8 `jr issue create --project <jira_project_key> ...` → returns NEW_KEY; verdict-2 (`ticket_action_type=link`, `ticket_id=NEW_KEY`, `link_target_ticket_id=existing_related_key`) → link marker → Stage 8 `jr issue link NEW_KEY existing_related_key` (D-020); Iron Law (D-022 rule 2): link verdict MUST NOT be written until create returns NEW_KEY. Anti-fungibility: create marker does NOT authorize link; link marker does NOT authorize create. **Canonical test vector** for "Existing open ticket (same asset, different root cause, §3.4 rule 2)" updated to create+link. Confidence reference updated to architecture-delta v1.21. **Inv#1** gated-mutation enumeration verified intact (create/link/move/comment/assign/edit — not changed). ADV-F2-P19-004.
> - v1.13 (2026-07-23): Pass-18 adversarial remediation burst 15 — P18-001 (D-020 link scope), P18-003 (D-022 compound sequential-Write model), P18-004 (OBS, Inv#1 gated-mutation enumeration). **Invariant #1 updated:** `jr issue link` added to gated-mutation enumeration (authorized via `["link"]` marker scope, D-020/P18-001); `jr issue move` confirmed present for both status transitions and close-scope (D-021). **PC#7b rewritten (D-022):** compound comment+link action (§3.4 rule 2) uses two sequential Stage-7 verdict Writes — verdict-1 (ticket_action_type=comment, ticket_id=KEY1 → comment marker → `jr issue comment KEY1 "..."`), verdict-2 (ticket_action_type=link, ticket_id=KEY1, link_target_ticket_id=KEY2 → link marker → `jr issue link KEY1 KEY2`); anti-fungibility: comment marker does NOT authorize link and vice versa. **PC#7d rewritten (D-022):** compound create+link action (§3.4 rule 4) uses two sequential Stage-7 verdict Writes — verdict-1 (ticket_action_type=create → create marker → `jr issue create` returns NEW_KEY), verdict-2 (ticket_action_type=link, ticket_id=NEW_KEY, link_target_ticket_id=CLOSED_KEY → link marker → `jr issue link NEW_KEY CLOSED_KEY`); Iron Law: link verdict MUST NOT be written until create succeeds and returns a valid key. EC-008 and Closed-ticket test vector updated to D-022 model; PC#7b test vector added. ADV-F2-P18-001/003/004; D-020/D-022; architecture-delta v1.20 §8.32.3.
> - v1.12 (2026-07-23): CV-001/CV-002/CV-003 consistency-validator remediation — version cross-reference refresh. Updated live-body cross-references: BC-3.03.001 v1.13→v1.24 and BC-3.01.001 v1.17→v1.22 (PC#1 body and confidence line; PC#5 body); BC-3.03.001 v1.23→v1.24 (PC#4 live body — all four occurrences; PC#4 confidence footnote; DI-013-RESOLVED footer). Historical, revision-history, and Previous-block cites left intact.
> - v1.11 (2026-07-22): Pass-16 adversarial remediation — P16-001 (MAJOR, burst-11 regression: post-P13-001 routing description omitted Gate 1). **PC#4 rewritten (gate-1-first human-path model):** investigation-*.md is written ONLY by human analysts (no `autonomy_enabled` field ever present), so disposition-guard's Separate Human-Comment Marker Path GATE 1 fires for EVERY invocation of this skill — `autonomy_enabled` is absent → emit allow-without-marker for ALL dispositions; the investigation Write always succeeds; NO Jira action marker of any kind is issued; the subsequent `jr issue comment` falls to human permission-approval (Claude Code dialog). The Gate-2/3 routing (FP→allow-without-marker / non-FP/PARSE_FAIL→MARKDOWN_REVIEW_PATH review marker / markdown-hard-floor→MARKDOWN-HARD-FLOOR deny) applies ONLY when `autonomy_enabled` is exactly `true` — the P12-002 autonomous-loop masquerade case — which this human-driven skill does not produce. Removed the incorrect "non-FP → review marker" and implied "Indeterminate save denied" claims from the human-path description. DI-013-RESOLVED footer reconciled. Cites BC-3.03.001 v1.23 Gate 1. ADV-F2-P16-001.
> - v1.10 (2026-07-22): Pass-15 adversarial remediation — P15-001 (MAJOR, post-P13-001 propagation: markdown path no longer issues comment marker) + P15-005 (MINOR, VP-HOOK-031 citation v1.14→v1.18). **PC#4 rewritten (post-P13-001 model):** The Separate Human-Comment Marker Path (BC-3.03.001 v1.23 Invariant #4) no longer issues a comment-scoped marker for any disposition (MARKDOWN_COMMENT_PATH ELIMINATED per P13-001). Routing: (a) FP → allow-without-marker (the investigation Write succeeds; `jr issue comment` NOT auto-authorized; falls to human permission-approval via Claude Code permission dialog); (b) non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review review marker issued; NOT a plain comment marker); (c) hard-floor conditions (Indeterminate disposition, forbidden techniques T1003/T1068/T1021/T1041, degraded/silent sensor) → MARKDOWN-HARD-FLOOR deny. Removed the assertion that disposition-guard "issues a comment-scoped marker … consumed to allow jr issue comment" via the markdown path. **DI-013-RESOLVED footer:** added "reconciled v1.10 / P13-001: markdown path no longer issues a comment marker" note. **P15-005:** VP-HOOK-031 citation updated from verification-delta.md v1.14 → v1.18 (guarantee (c) rewritten at P13-001). ADV-F2-P15-001, P15-005.
> - v1.9 (2026-07-22): Pass-11 adversarial remediation — P11-004 (MAJOR, investigation-markdown hard-floor reconciliation). **PC#4 hard-floor condition list corrected:** removed "HIGH/CRIT severity, critical assets" from the hard-floor conditions for the 12-field investigation-markdown comment-marker path. Those conditions reference verdict-only fields (scored_priority/asset_type) absent from a 12-field investigation markdown; they are not evaluable on this path. Correct markdown-evaluable set: Indeterminate disposition, forbidden techniques {T1003,T1068,T1021,T1041}, degraded/silent sensor. Also updated BC-3.03.001 version cross-reference from v1.13 → v1.19. ADV-F2-P11-004.
> - v1.8 (2026-07-21): Version-coherence sweep only — zero semantic change. Updated live-body version cross-references to frozen cycle versions: BC-3.03.001 v1.11 → v1.13 (PC#1/PC#4/PC#5a); BC-3.01.001 v1.15 → v1.17 (PC#1/PC#4/PC#5a). Per IP-005 version-coherence discipline (verification-delta.md v1.5 §7 Part E / Job 2).
> - v1.7 (2026-07-21): [P4-008/consistency-F1] Removed "cross-tenant" from PC#4 hard-floor disposition list — cross-tenant correlation is prism-side architecture (D-DEC-005/P3-011); sibling BCs BC-3.03.001 and BC-3.01.001 removed it at v1.10 and v1.15 respectively; BC-4.02.001 was not updated at that time. [consistency-F2] Fixed revision-history ordering: v1.4 entry was listed after v1.5 (chronologically wrong); corrected to v1.4 → v1.5 → v1.6 ascending. Completed v1.6 changelog entry to note that version cross-ref sweep updates to BC-3.03.001 and BC-3.01.001 version citations were applied (not just VP-anchor additions).
> - v0.9.x / PR #13 (2026-07-19): Initial extraction from `update-jira/SKILL.md` at v0.9.0 HEAD (Step 0d). `modified:` was not populated at ingestion time — re-synced now.
> - v1.1 (2026-07-19): ADV-0-601: Added `jr issue comment` to Invariant #1 gated-mutations list (was absent). Annotated PC#4 — the JIRA comment posting step hits require-review.sh unconditional deny; proceeds only via human permission-approval. Added DI-013 note.
> - v1.2 (2026-07-19): ADV-0-706: Standardized write-block citation in PC#4 to canonical form `88-94 (deny at :93)`.
> - v1.3 (2026-07-19): ADV-0-901: Replaced brittle require-review.sh line-number citation in PC#4 with construct-name reference (line numbers churned across PR#13/#14/#15; post-PR#15 lines 88-110 are the allowlist, not the write-block).
> - v1.4 (2026-07-20): DI-013/SEC-3.4: **UPDATED** — (1) DI-013 RESOLVED: comment path is now marker-gated per D-DEC-001. Disposition-guard (BC-3.03.001 v1.6) issues a marker after ICD-203 validation + hard-floor check; require-review (BC-3.01.001 v1.11) consumes the marker to allow `jr issue comment`. (2) Added four §3.4 ticket-action type postconditions (PC#5a–PC#5d). (3) Added Invariant #4: never-auto-reopen-closed (unconditional). (4) Added §3.5 SLA surface-never-assume requirement on append/link/propose-reopen actions (Invariant #5). EC-007..EC-009 added.
> - v1.5 (2026-07-20): ADV-F2-007: **UPDATED** — Removed stale "in conversation context or JIRA comments" wording from Precondition #1 and EC-001. This wording predated D-DEC-001 and contradicted the out-of-band filesystem marker design (D-DEC-001), reintroducing the SEC-001 injection surface. Replaced with explicit reference to `${CLAUDE_PLUGIN_DATA}/markers/` filesystem marker store (C-29). Marker TTL reference updated to v2.0 `expires_at_utc` form. Old wording preserved as Previous block.
> - v1.6 (2026-07-20): VP-anchor additions + version cross-ref sweep updates (BC-3.03.001 version citation updated from v1.6→v1.11 in PC#4/PC#5; BC-3.01.001 citation updated from v1.11→v1.15). Invariant #4 (never-auto-reopen Closed/Resolved): added VP-SKILL-066 (no code path from Closed/Resolved emits jr issue move reopen; verification-delta.md v1.2 §7 Part C). Invariant #5 (SLA surface-never-assume): added VP-SKILL-067 (append/link/propose-reopen emit explicit SLA-impact statement; default "SLA: unknown — do not assume compliant"; verification-delta.md v1.2 §7 Part C). Added corresponding rows to Verification Properties table and VP Anchors row to Traceability.

## Preconditions

1. **[UPDATED v1.5]** A review-approval marker must be present in `${CLAUDE_PLUGIN_DATA}/markers/` (the out-of-band marker store, C-29) before any field-modifying operation (`jr issue edit`, `jr issue move`) is executed. The marker is issued by disposition-guard (BC-3.03.001 v1.24) and consumed by require-review (BC-3.01.001 v1.22). Markers are NEVER embedded in conversation context or Jira comments — doing so would reintroduce the SEC-001 injection surface (D-DEC-001, ADV-F2-007). Confidence: D-DEC-001 binding decision (architecture-delta.md v1.2); BC-3.03.001 v1.24 Invariant #4 (EMITTER role); BC-3.01.001 v1.22 Postcondition #2 (consumer algorithm).

   > **Previous (v1.4):** "A review-approval marker must be present in conversation context or JIRA comments before any field-modifying operation (`jr issue edit`, `jr issue move`) is executed." (This wording predated D-DEC-001 and contradicted the out-of-band filesystem design. The phrase "conversation context or JIRA comments" reintroduced the SEC-001 injection surface — Jira ticket content could appear to satisfy the precondition. ADV-F2-007 MAJOR fix.)
2. The enrichment data to be written must pass field validation: CVSS in range 0.0-10.0, EPSS in range 0.0-1.0, KEV as "Listed" or "Not Listed", priority as P1-P5. Confidence: verified by code analysis (`skills/update-jira/SKILL.md:Step 2`).
3. `jr` CLI is installed and authenticated. Confidence: inferred from Prerequisites pattern across all pipeline skills.
4. The skill announces itself verbatim before any other action: "I am using the update-jira skill to update ticket <ticket-id> with enrichment data." Confidence: verified by code analysis (Announce at Start section) and BATS test `skills.bats:51-54`.
5. **[UPDATED v1.4]** For `jr issue comment` and `jr issue create` actions: a valid unexpired single-use marker (D-DEC-001) issued by disposition-guard (BC-3.03.001 v1.24) must be present in `${CLAUDE_PLUGIN_DATA}/markers/`. Marker presence is NOT checked by the skill — it is enforced at the infrastructure layer by require-review (BC-3.01.001 v1.22). If no marker exists, require-review blocks the comment/create command before it executes.

   > **Previous (v1.3):** No marker precondition. Comment path was unconditionally blocked by require-review (DI-013 PENDING).

## Postconditions

1. If no review-approval marker is found, the skill halts with the message "Review approval required before JIRA update. Run /review-enrichment first." and makes no JIRA mutations. Confidence: verified by code analysis (`skills/update-jira/SKILL.md:Step 1`).
2. Invalid fields (outside stated ranges) are skipped with a warning; the skill continues updating valid fields (partial success is acceptable). Confidence: verified by code analysis (Step 2: "Skip invalid fields with warning").
3. Priority is mapped to JIRA priority names: P1→Critical, P2→High, P3→Medium, P4→Low, P5→Trivial. Confidence: verified by code analysis (`skills/update-jira/SKILL.md:Step 3`).
4. **[UPDATED v1.4; reconciled v1.9 P11-004; rewritten v1.10 P13-001; gate-1-first v1.11 P16-001]** After field updates, the enrichment summary is posted as a JIRA comment. The `jr issue comment` command routing via the **Separate Human-Comment Marker Path** (BC-3.03.001 v1.24 Invariant #4) follows the **GATE-1-FIRST HUMAN-PATH** behavior: investigation-*.md files are written **ONLY** by human analysts, who never include `autonomy_enabled: true` in their markdown content. Therefore **GATE 1 fires for every real invocation of this skill** — disposition-guard reads `autonomy_enabled` from the markdown, finds it absent (or not exactly boolean `true`), and emits **allow-without-marker** (kill-switch parity per BC-3.03.001 v1.24 Gate 1). The investigation Write **always succeeds** for **ALL dispositions** (FP, non-FP, Indeterminate, or any other); **no Jira action marker of any kind is issued**; the subsequent `jr issue comment` falls to **human permission-approval** (Claude Code permission dialog). **The Gate-2/3 routing applies ONLY to the autonomy_enabled=true masquerade case (P12-002), which this human-driven skill does not produce:** (a) FP + autonomy_enabled=true → allow-without-marker; (b) non-FP/PARSE_FAIL + autonomy_enabled=true → MARKDOWN_REVIEW_PATH review marker (create-review or comment-review); (c) hard-floor conditions (Indeterminate disposition, forbidden techniques T1003/T1068/T1021/T1041, degraded/silent sensor) + autonomy_enabled=true → MARKDOWN-HARD-FLOOR deny. There is no "non-FP → review marker" and no "Indeterminate save denied" on the human path; Gate 1 intercepts before any Gate-2/3 routing for all human saves. **NOTE (P11-004):** Verdict-only fields (`scored_priority ∈ {HIGH,CRIT}` and critical/unknown `asset_type`) are NOT present in a 12-field investigation markdown and are NOT checked on this path — those floors apply only to the verdict-class path (BC-3.03.001 v1.24 PC#1). See BC-3.03.001 v1.24 Invariant #4 GATE 1 ("Separate Human-Comment Marker Path") for the authoritative pseudocode. **Verification property consumed: VP-HOOK-031 (FINALIZED P0 per verification-delta.md v1.18 [ID-sync per FV]) — this postcondition is a consumer of the Separate Human-Comment Marker Path property; Gate 1 guarantees allow-without-marker for all human saves before Gate-2/3 routing is reached; no disposition from a human analyst save yields an autonomous comment marker. Paired mutant SM-47 (markdown-routed-into-verdict-emitter) is the kill target for compliant-save-allowed and no-validate_enums-on-markdown vectors.**

   > **Previous (v1.10/P13-001):** "The markdown path **NO LONGER issues a comment-scoped marker for any disposition** (P13-001 — MARKDOWN_COMMENT_PATH ELIMINATED): (a) **FP investigation** → disposition-guard returns **allow-without-marker** [...]; (b) **non-FP / PARSE_FAIL** → disposition-guard issues a **MARKDOWN_REVIEW_PATH review marker** (create-review or comment-review) [...]; (c) **Hard-floor conditions** (Indeterminate disposition, forbidden techniques T1003/T1068/T1021/T1041, degraded/silent sensor) → **MARKDOWN-HARD-FLOOR deny** returned." (This post-Gate-1 routing description omitted GATE 1, which fires FIRST for human saves. investigation-*.md is written only by human analysts with autonomy_enabled absent, so Gate 1 short-circuits to allow-without-marker for ALL dispositions — Gate-2/3 routing is masquerade-case-only. P16-001 correction.)

   > **Previous (v1.9/P11-004):** "The `jr issue comment` command is now **marker-gated** (DI-013 RESOLVED, D-DEC-001): disposition-guard (BC-3.03.001 v1.19) issues a comment-scoped marker to `${CLAUDE_PLUGIN_DATA}/markers/` via the Separate Human-Comment Marker Path (P11-004) after ICD-203 12-field validation + markdown-evaluable hard-floor check; require-review (BC-3.01.001 v1.17) validates and consumes the marker to allow `jr issue comment`."

   > **Previous (v1.3):** "After field updates, the enrichment summary is posted as a JIRA comment. The `jr issue comment` command hits the require-review write-block (evaluated before the allowlist; denies jr issue comment/edit/move/assign/create) as an unconditional deny — there is no marker-based override; the hook reads only stdin JSON and the deny path has no bypass mechanism. The comment posting step proceeds only via human permission-approval...Resolution options are tracked as **DI-013, PENDING HUMAN DECISION at the Phase 0 gate.**"

   Confidence: D-DEC-001 binding decision (architecture-delta.md v1.1); BC-3.01.001 v1.22 PC#2 (marker-validation allow path); BC-3.03.001 v1.24 Invariant #4 (Separate Human-Comment Marker Path — Gate 1, P12-002 / P13-001).

5. After updates, the ticket is re-read via `jr issue view` to verify updates succeeded. Confidence: verified by code analysis (Step 3, final item).
6. Cloud ID is never exposed in user-facing output. Confidence: verified by code analysis (Red Flag: "The cloud_id is in the error message, that's fine").

7. **[NEW v1.4] Four §3.4 ticket-action types as distinct postconditions:**

   When an existing Jira ticket is found during update-jira execution, the action taken depends on the ticket's current status:

   - **PC#7a — Append-comment to open duplicate:** If an open ticket (non-Resolved, non-Closed status) with the same root-cause indicator already exists, append a comment to that ticket referencing the new alert. The comment is marker-gated (D-DEC-001). Include §3.5 SLA surface statement (see Invariant #5).
   - **PC#7b — Create new and link as related (§3.4 rule 2 — create+link, D-022):** **[UPDATED v1.14 — P19-004/D-022 HUMAN DECISION 2026-07-23]** If a ticket for the same asset or IOC exists but has a different root cause, the loop creates a NEW ticket for the current alert and links it to the existing related ticket. Two sequential Stage-7 verdict Writes (D-022): verdict-1 (`ticket_action_type=create`) → create marker issued → Stage 8 executes `jr issue create --project <jira_project_key> ...` → returns NEW_KEY (new ticket for the different-root-cause alert); verdict-2 (`ticket_action_type=link`, `ticket_id=NEW_KEY`, `link_target_ticket_id=existing_related_key`) → link marker issued → Stage 8 executes `jr issue link NEW_KEY existing_related_key` (D-020 link scope, default "Relates" type). **Iron Law (D-022 rule 2 — P19-004):** the link verdict MUST NOT be written until `jr issue create` has returned a valid NEW_KEY; `link_target_ticket_id` MUST carry the actual NEW_KEY — no placeholder keys. Each marker is single-use and anti-fungible — a create marker does NOT authorize `jr issue link`, and a link marker does NOT authorize `jr issue create`. **"Keep tickets separate" invariant (P19-004):** each root cause has its own ticket; the existing related ticket is NOT commented upon (rule 2 is now create+link, not comment+link). Link-type is "Relates" (jr default; `--type` is never loop-influenceable per D-020 Iron Law). No ticket reopening occurs. Include §3.5 SLA surface statement. Confidence: D-022/D-020; architecture-delta v1.21 §8.33.3; HUMAN DECISION 2026-07-23.
   - **PC#7c — Propose reopen for Resolved ticket (NEVER execute):** If the existing ticket status is Resolved and the root cause matches, the skill PROPOSES reopen to the analyst (e.g., "Ticket SEC-101 was Resolved on YYYY-MM-DD with the same root cause. Recommend reopening. Please confirm.") and halts. The skill NEVER executes `jr issue move` to reopen a Resolved ticket autonomously. Include §3.5 SLA surface statement. Confidence: hardened by Invariant #4.
   - **PC#7d — Create new and link for Closed ticket (§3.4 rule 4 — create+link, D-022):** **[UPDATED v1.13 — P18-003/D-022]** If the existing ticket status is Closed, the loop performs **two sequential Stage-7 verdict Writes (D-022 option b)**: verdict-1 (`ticket_action_type=create`) → create marker issued → Stage 8 executes `jr issue create --project <jira_project_key> ...` and returns NEW_KEY; verdict-2 (`ticket_action_type=link`, `ticket_id=NEW_KEY`, `link_target_ticket_id=CLOSED_KEY`) → link marker issued → Stage 8 executes `jr issue link NEW_KEY CLOSED_KEY` (D-020). **Iron Law (D-022 rule 4):** the link verdict MUST NOT be written until `jr issue create` has succeeded and returned a valid ticket key; `link_target_ticket_id` in the link verdict MUST carry the actual NEW_KEY from the create result — the loop MUST NOT write the link verdict speculatively or with a placeholder key. Never attempt to reopen the Closed ticket. Confidence: hardened by Invariant #4; D-022/D-020; architecture-delta v1.20 §8.32.3.

## Invariants

1. **[UPDATED v1.13 — P18-004/D-020/D-021]** JIRA mutations (`jr issue edit`, `jr issue move`, `jr issue assign`, `jr issue create`, `jr issue comment`, `jr issue link`) are gated by the `require-review` hook at the infrastructure layer AND by the skill-level review-approval check. Two-layer defense in depth. **`jr issue link`** is explicitly enumerated as a gated mutation (authorized via `["link"]` marker scope, D-020/P18-001; the link marker authorizes ONLY `jr issue link KEY1 KEY2` — comment/create/assign/close markers do NOT authorize link, and vice versa). **`jr issue move`** is authorized both for status transitions (e.g., "Enriched") via prior marker mechanisms AND for close operations via the `["close"]` marker scope (D-021/P18-005 — close is a REGULAR scope action gated by hard_floor_applies() STEP 4 and autonomy_enabled kill switch STEP 5; close ONLY authorized for FP/BTP + non-hard-floor + autonomy_enabled=true; HIGH/CRIT-scored → DENY-THE-WRITE → routes to comment-review instead). Confidence: verified by code analysis, hook architecture, and architecture-delta v1.21 §8.33 / §D-020 / §D-021 / §D-023.
2. All fields must be updated atomically in a single pass — not sequentially over time. Partial-field-then-later-finish is explicitly prohibited by the Red Flags. Confidence: verified by code analysis (Red Flag: "I'll update priority first and finish the rest later" → "Partial updates create inconsistent state").
3. A `jr issue edit` call failure (e.g., field not found, permission error) does not abort the skill; it logs the failure and continues with remaining fields. The final report documents which fields succeeded and which failed. Confidence: verified by code analysis (Red Flag: "Field update failed, I'll skip it" → "Log the failure, continue with other fields, report partial success").
4. **[NEW v1.4] Never auto-reopen closed or resolved tickets (unconditional).** The skill MUST NOT execute any `jr issue move` command that transitions a ticket out of Resolved or Closed status. This rule applies regardless of `autonomy_enabled` setting, regardless of instructions, and regardless of any other condition. Propose-only for Resolved (PC#7c); create-new for Closed (PC#7d). Confidence: D-DEC-001/§3.4 binding constraint.

   **Verification property (FINALIZED v1.6):** VP-SKILL-066 — no code path from Closed/Resolved status emits `jr issue move` reopen; propose-only for Resolved (PC#7c), create-new for Closed (PC#7d) (verification-delta.md v1.2 §7 Part C).
5. **[NEW v1.4] §3.5 SLA surface-never-assume.** For append-comment (PC#7a), link-related (PC#7b), and propose-reopen (PC#7c) actions, the skill MUST include an explicit SLA impact statement in the output before executing or proposing. The statement format is: "SLA impact: [ASSESSED / NOT ASSESSED — reason]. Existing ticket SEC-NNN SLA: [deadline if known, 'unknown' if not retrievable]." The skill NEVER assumes SLA status; if SLA data is not available from `jr issue view`, the statement must say "SLA: unknown — do not assume compliant." Confidence: §3.5 specification.

   **Verification property (FINALIZED v1.6):** VP-SKILL-067 — append/link/propose-reopen emit explicit SLA-impact statement; default "SLA: unknown — do not assume compliant" when SLA data is not available from `jr issue view` (verification-delta.md v1.2 §7 Part C).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | No review-approval marker present in `${CLAUDE_PLUGIN_DATA}/markers/` (marker store empty, expired, or wrong-scope) | Halt before any JIRA mutation; prompt user to run /review-enrichment. Markers are NEVER sourced from conversation context or Jira comments — only from the filesystem marker store (ADV-F2-007). |
| EC-002 | CVSS = 11.0 (invalid) | Skip CVSS field update with warning; continue with other valid fields |
| EC-003 | EPSS = 1.5 (invalid range) | Skip EPSS field update with warning |
| EC-004 | `jr issue edit` returns error (field ID mismatch) | Log error; continue; report in final summary |
| EC-005 | Status transition to "Enriched" not a valid transition from current status | Log jr move failure; report in final summary; other updates may have succeeded |
| EC-006 | Cloud ID appears in jr error message | Filter from user output — never display cloud_id |
| EC-007 | Existing ticket found with status "Resolved" and same root cause | Propose reopen to analyst (include SLA surface statement); halt without executing move. Never execute `jr issue move` to reopen. (PC#7c + Invariant #4) |
| EC-008 | Existing ticket found with status "Closed" | Two sequential Stage-7 verdict Writes (D-022/D-020): verdict-1 create marker → `jr issue create --project <key>` → NEW_KEY returned; verdict-2 link marker (ticket_id=NEW_KEY, link_target_ticket_id=CLOSED_KEY) → `jr issue link NEW_KEY CLOSED_KEY`; never attempt to reopen. (PC#7d + Invariant #4 + D-022 + D-020) |
| EC-009 | Append-comment action selected but no valid marker in marker-store (hard-floor disposition) | Require-review blocks `jr issue comment`; fall through to human permission-approval (Claude Code dialog). Skill surfaces: "SLA impact: NOT ASSESSED — manual review required." |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Ticket with review approval, all valid fields (CVSS 9.8, EPSS 0.92, KEV Listed, P1), valid marker for comment | All fields updated; JIRA comment posted (marker consumed); status moved to Enriched; verification read passes | happy-path |
| Ticket with no review approval | Halt with "Review approval required" message; no JIRA mutation | error |
| Ticket with CVSS 11.0 | CVSS field skipped with warning; other fields updated | edge-case |
| `jr issue edit` permission denied | Error logged; continues; final report shows failure | error |
| Existing ticket status=Resolved, same root cause | Propose reopen with SLA surface statement; halt; no `jr issue move` executed | edge-case (EC-007) |
| Existing ticket status=Closed | Two sequential Stage-7 verdict Writes (D-022): verdict-1 create → NEW_KEY returned; verdict-2 link marker (ticket_id=NEW_KEY, link_target_ticket_id=CLOSED_KEY) → `jr issue link NEW_KEY CLOSED_KEY`; no reopen attempted | edge-case (EC-008) |
| Existing open ticket (same asset, different root cause, §3.4 rule 2) | **[UPDATED v1.14/P19-004]** Two sequential Stage-7 verdict Writes (D-022 rule 2 create+link): verdict-1 create marker → Stage 8 `jr issue create --project <key> ...` → returns NEW_KEY; verdict-2 link marker (`ticket_id=NEW_KEY`, `link_target_ticket_id=existing_related_key`) → Stage 8 `jr issue link NEW_KEY existing_related_key`; Iron Law: link verdict written AFTER create returns NEW_KEY; anti-fungibility: create marker does NOT authorize link call; separate tickets maintained (each root cause has its own ticket); SLA surface statement emitted | edge-case (PC#7b, D-022 rule 2 create+link — P19-004) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-006 | Iron Law text is present in SKILL.md verbatim | integration / BATS (`skills.bats:25-27`) |
| VP-SKILL-007 | CVSS range validation rejects values outside 0.0-10.0 | integration / manual |
| VP-SKILL-008 | Review approval check precedes any jr issue edit invocation | integration / manual |
| VP-SKILL-066 | No code path from Closed/Resolved status emits `jr issue move` reopen: propose-only for Resolved (PC#7c), create-new for Closed (PC#7d); Invariant #4 unconditional guard (Invariant #4). FINALIZED per verification-delta.md v1.2 §7 Part C. | integration / BATS (`@test "update-jira never executes jr issue move to reopen Closed ticket"`, `@test "update-jira proposes-only for Resolved ticket — no jr issue move executed"`) |
| VP-SKILL-067 | Append/link/propose-reopen emit explicit SLA-impact statement; default "SLA: unknown — do not assume compliant" when SLA data unavailable from jr issue view (Invariant #5). FINALIZED per verification-delta.md v1.2 §7 Part C. | integration / BATS (`@test "update-jira append-comment output contains SLA impact statement"`, `@test "update-jira propose-reopen output contains SLA surface statement"`, `@test "update-jira SLA statement defaults to unknown when jr issue view returns no SLA data"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-VULN-02 |
| L2 Domain Invariants | NO JIRA UPDATE WITHOUT REVIEW APPROVAL FIRST; never-auto-reopen-closed (Invariant #4) |
| Architecture Module | C-2 (skill-procedures), C-12 (require-review hook provides infrastructure gate), C-29 (marker-store — comment path gate) |
| Stories | TBD (filled by story-writer) |
| VP Anchors | VP-SKILL-006, VP-SKILL-007, VP-SKILL-008, VP-SKILL-066 (never-auto-reopen-closed — FINALIZED v1.6 per verification-delta.md v1.2 §7 Part C), VP-SKILL-067 (SLA surface-never-assume — FINALIZED v1.6 per verification-delta.md v1.2 §7 Part C) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/update-jira/SKILL.md` (~76 lines) |
| **Confidence** | high — 4-step process with explicit field validation ranges and priority mapping documented in source; §3.4 ticket-action types and §3.5 SLA surface requirement from architecture-delta.md v1.1 (D-DEC-001) |
| **Extraction Date** | 2026-07-20 |

#### Evidence Types Used

- **documentation**: Iron Law text, step-by-step process, explicit field validation ranges
- **guard clause**: "Look for review-approval marker... If not found, HALT" (Step 1)
- **type constraint**: field validation ranges are explicit (CVSS 0.0-10.0, EPSS 0.0-1.0, KEV enum, Priority enum)
- **D-DEC-001 binding decision**: marker-gated comment path (DI-013 RESOLVED)
- **§3.4 specification**: four ticket-action types (PC#7a–PC#7d)
- **§3.5 specification**: SLA surface-never-assume (Invariant #5)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads Jira (jr issue view for verification), writes Jira (jr issue edit, comment, move), reads marker-store indirectly (via require-review hook infrastructure) |
| **Global state access** | none |
| **Deterministic** | no — depends on Jira API responses |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell |

#### Refactoring Notes

Field validation (Step 2) is a pure function: given data values, apply range/enum checks. This is the natural unit for formal specification. The four §3.4 ticket-action dispatch (PC#7a–PC#7d) is also a pure function given (existing_ticket_status, root_cause_match) → action_type. The propose-reopen logic is a strict guard against the never-auto-reopen-closed invariant; formal verification of this invariant should assert that no code path from PC#7c or PC#7d results in a `jr issue move` call.

**DI-013 RESOLVED (v1.4; reconciled v1.9; reconciled v1.10 / P13-001; reconciled v1.11 / P16-001):** The comment path is now marker-gated via D-DEC-001 using the Separate Human-Comment Marker Path (P11-004). The three-way resolution path (marker-file mechanism) was selected. Verdict-only hard floors (scored_priority HIGH/CRIT, critical/unknown asset_type) are not evaluated on this 12-field path. **Reconciled v1.10 / P13-001:** The markdown path no longer issues a comment-scoped marker for any disposition (MARKDOWN_COMMENT_PATH ELIMINATED); FP + autonomy_enabled=true produces allow-without-marker; non-FP/PARSE_FAIL + autonomy_enabled=true routes to MARKDOWN_REVIEW_PATH (create-review/comment-review review marker); hard-floor conditions + autonomy_enabled=true → MARKDOWN-HARD-FLOOR deny. **Reconciled v1.11 / P16-001:** The Gate-2/3 routing above is the masquerade case (autonomy_enabled=true, P12-002) only. For all real invocations of this human-driven skill, `autonomy_enabled` is absent — GATE 1 fires first and emits allow-without-marker for ALL dispositions (FP, non-FP, Indeterminate, any). The investigation Write always succeeds on the human path; no hard-floor denial fires; `jr issue comment` falls to human permission-approval via Claude Code dialog. (BC-3.03.001 v1.24 Gate 1 is the authoritative source.)

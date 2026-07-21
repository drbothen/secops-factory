---
document_type: adversarial-review
producer: adversary
pass: 3
date: 2026-07-20
verdict: FINDINGS
counts: "1C/4M/4med/5obs"
snapshot_trust: TRUSTED
---

Verdict: FINDINGS — not converged. Counts: CRITICAL 1, MAJOR 4, MEDIUM 4, minor/observation 5. Snapshot trust TRUSTED (live working tree). Partial coverage note: BC-6.01.003/004, BC-8.02.001 bodies reviewed at frontmatter/index level only.

CRITICAL
ADV-F2-P3-001: disposition-guard hard-floor list omits asset_type=unknown. BC-10.01.001 Inv#10 + EC-021 make verdict.asset_type==unknown a conservative hard-floor member (ADV-F2-P2-010 policy decision) enforced by BOTH SKILL and disposition-guard. But BC-3.03.001 Inv#4 emitter hard-floor list and architecture-delta §D-DEC-008 hard_floor_applies() pseudocode OMIT unknown; VP-HOOK-026 injects only critical-asset (domain_controller), not the unknown leg. A LOW-severity + asset_type=unknown + benign verdict with ticket_action_type!=none (SKILL error) → disposition-guard issues marker → auto-write succeeds; the defense-in-depth claim is false for unknown. Mis-propagation on the authorization boundary.

MAJOR
ADV-F2-P3-002: Create-scoped markers fungible across verdicts/orgs. command_pattern for create = "^jr (--output json )?issue create " (no ticket_id, no org, no content binding); consumer BC-3.01.001 PC#2 never compares marker.org_slug to the command; emitter writes org_slug but consumer never reads it for authz. Under iterative-consume (added by P2-003 for multi-org create batching), create markers pool FIFO — a create marker issued for a benign org-b verdict can authorize a jr issue create for an org-a hard-floor verdict disposition-guard refused to mark. Comment/assign are ticket-bound and safe; only create is unbound. Fix: bind create pattern to run-scoped/org token OR have require-review compare marker.org_slug to command --project/org.
ADV-F2-P3-003: 15-field ICD-203 validation applied to investigation markdown breaks investigate-event marker path. BC-3.03.001 PC#2 third bullet requires all 15 headings (incl Severity, Asset Type, Ticket Action Type) for investigation files; BC-5.01.001 v1.5 still says "12-field validation", cites BC-3.03.001 v1.6/BC-3.01.001 v1.11, and its template lacks the 3 monitoring-loop headings (Ticket Action Type is meaningless for a manual investigation). disposition-guard denies the marker on every investigate-event Stage-7 write → DI-013 "marker-gated jr issue comment" regresses to human-approval-only. Fix: disposition-guard branches field-set by artifact class (investigation = 12 ICD-203 fields; verdict JSON = 15) OR investigation template gains the 3 fields.
ADV-F2-P3-004: org_slug isolation unverified on assess-priority + investigate-event PrismQL paths. VP-SKILL-064 is described as "sole plugin-side cross-tenant isolation guarantee" but BC-4.05.001 PC#5a/5d + Inv#4 issue PrismQL with no covering VP, and BC-5.01.001 PC#7 Stage-3 issues PrismQL with no org_slug VP. Only monitoring-loop (VP-SKILL-064) + scan-threats (VP-SKILL-059) covered. Add org_slug VPs for BC-4.05.001 Inv#4 and BC-5.01.001 Stage 3, or restate VP-SKILL-064 scope.

MEDIUM
ADV-F2-P3-005: Marker reachability depends on unstated verdict-file-path naming. BC-3.03.001 PC#1 fast-path-allows unless file_path contains "investigation" or "verdict"; BC-10.01.001 Stage 7/PC#3 never require the verdict file path to contain "verdict". If the loop writes to a non-matching path → fast-path allow, no marker, every Stage-8 jr write denied. Make the path convention an explicit BC-10.01.001 precondition.
ADV-F2-P3-006: Watermark monotonicity (Inv#4) not enforced by D-DEC-002 WRITE_WATERMARK() — no max(stored, ts) guard; grace-window READ returns stored−GRACE, so an in-grace-only run has run-max ts ≤ stored and regresses the watermark, drifting the grace window further back each run. Add monotonic max() guard.
ADV-F2-P3-007: Cross-doc version drift recurrence. prd-delta §5 records BC-4.02.001 v1.4→v1.5 and BC-10.01.001 v1.2→v1.4 (live are v1.6/v1.5); §1 VP-refs omit VP-HOOK-027 + VP-SKILL-068. verification-delta v1.2 "Live-BC snapshot" says BC-4.02.001 v1.5/BC-10.01.001 v1.4 and §7 Part C lists VP-HOOK-027/VP-SKILL-066/067/068 anchors as "corrections required" though BC v1.6/v1.5 revision notes show them applied — the "BC-cites-§7-while-§7-says-owed" circular staleness recurs.
ADV-F2-P3-008: confidence type mismatch. BC-4.05.001 PC#6 outputs confidence 0.0-1.0 float; BC-10.01.001 Inv#9 field#2 + VP-HOOK-025 require enum {high,medium,low} type-asserted by disposition-guard jq. assess-priority is the Stage-5 scorer feeding the verdict; float fails the enum contract; no float→enum mapping specified.

minor/observation
ADV-F2-P3-009 (minor)[process-gap]: pervasive stale cross-BC version refs (BC-5.01.001 cites v1.6/v1.11; BC-4.02.001 cites v1.6 and v1.8/v1.13; live v1.9/v1.14) — hand-maintained, no propagation check.
ADV-F2-P3-010 (minor): jr auth command-name — brief §4.4 uses "jr auth status"; BC-6.01.001 PC#10/EC-010 use "jr auth check". GROUND TRUTH (orchestrator verified jr 0.5.0): subcommand is "status" (jr auth: login/status/refresh/switch/list/logout/remove) — "check" does not exist. Fix BC-6.01.001 to "jr auth status".
ADV-F2-P3-011 (minor): cross-tenant-indicator hard floor in BC-3.03.001 Inv#4 marked [PENDING-DEFINITION per ADV-F2-016] while BC-3.01.001 PC#2 cites "cross-tenant scope" as an active hard-floor category. Per D-DEC-005 plugin obligation is org_slug scoping only; either define or remove the active citation.
ADV-F2-P3-012 (obs): crash idempotency depends entirely on fragile Jira-first dedup (summary ~ approximate match); watermark persists once per sensor loop, so crash after Stage 8 re-processes the window; D-DEC-004 dedup-JQL-failure → create-new → duplicate tickets.
ADV-F2-P3-013 (obs)[process-gap]: VP-coverage seams with no owning VP — artifact-class field-set (12 vs 15), verdict-file-path reachability, confidence float→enum.

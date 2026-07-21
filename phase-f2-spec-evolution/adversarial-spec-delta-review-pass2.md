---
document_type: adversarial-review
producer: adversary
pass: 2
date: 2026-07-20
verdict: FINDINGS
counts: "1C/3M/6med/5obs"
snapshot_trust: HIGH
---

# Adversarial Spec Review — Pass 2 (F2)

Verdict: FINDINGS — not converged; one CRITICAL blocks the core autonomous-write capability. Counts: CRITICAL 1, MAJOR 3, MEDIUM 6, minor/observation 5. Snapshot trust HIGH (hook source at HEAD d181ca2 confirms marker/ICD-203 machinery is spec-only, implementation deferred to F4 — no false spec-drift).

## CRITICAL

**ADV-F2-P2-001: Stage ordering makes the marker mechanism unusable.** BC-10.01.001 Invariant #14 fixes order Stage 7 TICKET ACTION → Stage 8 DOCUMENT (verdict write). The marker is issued only when disposition-guard fires on the Stage-8 verdict Write; require-review consumes it on the Stage-7 jr Bash call. Since Stage 7 precedes Stage 8, no marker exists when jr runs → every autonomous Jira write is denied; the loop can never auto-action. BC-10.01.001 PC#3 ("disposition-guard blocks any ticket action without 15 fields") is mechanically impossible — disposition-guard fires on Write events, not the Bash jr event. Existing update-jira/investigate-event works because it is document-BEFORE-action; BC-10.01.001 inverts it. No VP tests document-before-action ordering. Fix: reorder so verdict/defensible-record Write precedes jr execution, or split Stage 7 into "decide action type" (pre-Stage 8) and "execute jr" (post-Stage 8); reconcile Invariant #14 + brief §3.1/§3.2.

## MAJOR

**ADV-F2-P2-002: EC-009 known-FP fast-exit cannot enforce the ATT&CK-technique hard floor.** EC-009 evaluates hard floors on severity/asset_type/sensor_health then skips Stages 3–6. But (1) EC-009's floor list OMITS attack_techniques (Invariant #10 includes verdict.attack_techniques ∈ {T1003,T1068,T1021,T1041}); (2) attack_techniques is populated at Stage 3 CATEGORIZE which EC-009 skips, so disposition-guard's technique floor sees an empty array → passes → auto-close. A T1003 alert matching a known-FP pattern auto-closes with no human review. Also Invariant #10 says severity/asset_type populate at Stage 5 (SCORE) which EC-009 also skips — fast path never documents where it obtains fields 13/14. Fix: compute MITRE technique before known-FP auto-close, or route to human whenever technique classification has not run; state fast-path field-population source.

**ADV-F2-P2-003: Create-scoped marker multiplicity + scope.** Every create marker gets identical command_pattern "^jr (--output json )?issue create " (ticket_id null). require-review denies when >1 candidate matches ("ambiguous"). A multi-org loop producing ≥2 new-ticket verdicts before creates execute → ≥2 create markers coexist → every create denied. Same collision on same-ticket multi-comment (duplicate-append + BLIND-SPOT-append). Also create command_pattern binds neither org_slug nor --project, so within 120s a single create marker authorizes create for any project/org — bounded-ness argument only partially sound. Fix: incorporate run-scoped nonce or project/org token into create/assign/comment command_pattern, and/or replace strict >1 multiplicity-deny with per-marker consume.

**ADV-F2-P2-004: architecture-delta §5.1 "new security invariant" references schema fields v2.0 removed.** §5.1 states invariant using M.used and M.issued_at_utc + M.ttl_seconds > now(); but canonical schema v2.0 removed used + ttl_seconds and mandates now() > expires_at_utc. Document contradicts its own canonical schema; an implementer/F5 reviewer formalizing from §5.1 re-introduces the relative-TTL arithmetic v2.0 deleted. §5.4 also still frames command_b64 + BC-3.01.001 Inv#2 as pending "next version bump" though v1.13 applied them. Fix: rewrite §5.1 to ¬(now() > expires_at_utc) ∧ issued_at_utc ≤ now() ∧ single-use-via-atomic-rename ∧ anchored_match.

## MEDIUM

**ADV-F2-P2-005: Cross-doc version incoherence.** BC-10.01.001 live v1.3 but verification-delta v1.1 header says "BC-10.01.001 v1.2" and its §7 Part B lists VP-SKILL-064/065 finalization as still-owed (circular: BC v1.3 cites §7 Part B as authority; §7 says work still owed). prd-delta v1.3 §1 omits VP-SKILL-064/065 and §5/changelog stop at v1.2. architecture-delta §8 targets "v1.1→v1.2." Three of four delta docs stale by one BC version on the CRITICAL BC.

**ADV-F2-P2-006: Partial-fix propagation gap.** BC-10.01.001 EC-015/EC-016 still key on alert.severity / alert.attack_technique after Invariant #10 was re-keyed to verdict.* (the ADV-F2-001 fix). Implementers using the EC table re-introduce the latent bypass. Fix: EC-015/016 → verdict.severity / verdict.attack_techniques.

**ADV-F2-P2-007: Marker audit-log path inconsistent.** BC-3.01.001 writes ${CLAUDE_PLUGIN_DATA}/audit.log; architecture-delta §D-DEC-001 writes ${marker_dir}/audit.log (=${CLAUDE_PLUGIN_DATA}/markers/audit.log, matches C-29). Pick one (recommend markers/audit.log) and align.

**ADV-F2-P2-008: Prism MCP launch command + download URL disagree.** Brief §2.1 args ["--config-dir","<dir>","start"]; BC-6.01.001 PC#9 uses ["mcp"] + PRISM_CONFIG_DIR env. Download URL BC-6.01.001 PC#8 = github.com/prism-io/prism; architecture-delta §3 CI = github.com/drbothen/prism. GROUND TRUTH (orchestrator verified against the prism repo): org is drbothen/prism; MCP server subcommand is `start` (prism binary about="Prism MCP server"; subcommands start/query/validate-config/version); config passed via --config-dir. BC-6.01.001 must be corrected to `start` + drbothen/prism.

**ADV-F2-P2-009: Verification coverage gaps.** BC-4.02.001 Invariant #4 (never-auto-reopen Closed/Resolved) + Invariant #5 (SLA surface) have no VP on the update-jira path (VP-SKILL-062 covers only the monitoring-loop path). D-DEC-002 watermark grace-window + Jira-first dedup has no VP and no SM-N mutant (VP-SKILL-050 tests only monotonicity). Add VPs + paired mutant.

**ADV-F2-P2-010: asset_type=unknown is not a hard floor and has no conservative default** (unlike severity which defaults CRITICAL on missing). severity=LOW + asset_type=unknown + benign technique clears all floors → auto-action. Consider adding unknown to critical-asset floor or a conservative default.

## minor/observation

**ADV-F2-P2-011:** prd-delta §8 edge-case descriptions stale to pre-v2.0 ("EC-017 TTL 30s", "EC-019 used==true") vs live 120s expires_at_utc + used removed.

**ADV-F2-P2-012:** BC-3.01.001 invariants numbered 1,2,3,5,4 (ordering); BC-6.01.001 revision history lists v1.2 before v1.1.

**ADV-F2-P2-013 (obs):** BC-6.01.001 settings.json/prism.mcp.json env blocks carry only RUST_LOG + PRISM_CONFIG_DIR, dropping brief §2.1 sensor base-URL env vars — plausibly intentional (base_url in per-sensor toml) but no BC states the reconciliation.

**ADV-F2-P2-014 (obs)[process-gap]:** No VP/mutant guards the stage-order/document-before-action property (would have caught P2-001). Recommend cross-hook integration VP: a jr write in the loop is denied unless a verdict Write preceded it.

**ADV-F2-P2-015 (obs):** Semantic anchoring spot-check PASSED — capability anchors, subsystem fields coherent, VP namespace no collisions.

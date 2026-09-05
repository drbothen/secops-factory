---
document_type: dependency-graph
level: ops
version: "1.0"
producer: story-writer
timestamp: 2026-09-04T00:00:00
phase: f3
cycle: "v0.10.0-feature-prism-integration"
---

# F3 Dependency Graph — Wave 7: monitoring-loop Feature Cycle

This document formalizes the acyclic dependency graph for all 13 F3 stories in the
`v0.10.0-feature-prism-integration` cycle. The graph was re-verified at INTEGRATE
sub-burst (2026-09-04) via Kahn's topological sort. No cycles found.

---

## Directed Edge List

Each edge `A → B` means "A must complete before B starts (B depends on A)."

| Predecessor | Successor | Justification |
|-------------|-----------|---------------|
| S-3.01 | S-3.02 | S-3.02 extends disposition-guard which consumes require-review markers defined by S-3.01 |
| S-3.01 | S-4.01 | S-4.01 update-jira compound-link depends on anti-fungibility marker scopes defined by S-3.01 |
| S-3.01 | S-10.01 | monitoring-loop orchestrates require-review hook; link/close marker scopes must exist first |
| S-3.02 | S-4.01 | S-4.01 orphan-link recovery and SAVE-ALWAYS paths depend on disposition-guard state machine |
| S-3.02 | S-5.01 | S-5.01 investigate-event D-029 SAVE-ALWAYS depends on disposition-guard allow-without-deny path |
| S-3.02 | S-10.01 | monitoring-loop invokes disposition-guard hook; close-state validation and 3-cond gate must exist |
| S-4.01 | S-10.01 | monitoring-loop Stage 7 calls update-jira; compound create+link API must be built first |
| S-4.02 | S-10.01 | monitoring-loop Stage 5 consumes scored_priority from assess-priority (ICD-203 field 18) |
| S-6.03 | S-6.01 | S-6.01 AC-006 prism_describe verification requires the prism binary and MCP that activate (S-6.03) installs and configures. Secondary: jira_close_state validated at activation (BC-6.01.001 PC#13 per S-6.03 AC-001). |
| S-6.03 | S-8.01 | sensor-metrics reads prism_sensor_health seeded by activate |
| S-6.03 | S-9.01 | scan-threats enumerates orgs registered during activate |
| S-6.03 | S-10.01 | monitoring-loop reads per-org config (jira_close_state, CLOSE_STATE_ALLOWLIST) set by activate |
| S-6.01 | S-6.02 | onboard-sensor requires an existing org_slug created by onboard-customer |
| S-6.01 | S-10.01 | monitoring-loop requires per-org prism.toml org record created by onboard-customer |
| S-6.02 | S-10.01 | monitoring-loop requires per-org sensor overlay created by onboard-sensor |
| S-10.01 | S-10.02 | S-10.02 (watermark + DETECT_LATE_EVENT) extends the core pipeline built in S-10.01 |

S-5.01, S-8.01, S-9.01, S-10.02 have no successors (leaf nodes).
S-11.01 (demo tooling) is standalone: no predecessors and no successors within the product graph.

---

## Topological Sort — Wave Assignment

**Algorithm:** Kahn's BFS topological sort. Start with all nodes of in-degree 0 (no dependencies);
assign to current wave; decrement successor in-degrees; repeat.

**Cycle check result: ACYCLIC — sort completes over all 13 nodes.**

| Wave | Stories | Rationale |
|------|---------|-----------|
| **Wave 1** | S-3.01, S-4.02, S-6.03 | In-degree 0 within this feature; no predecessors |
| **Wave 2** | S-3.02, S-6.01, S-8.01, S-9.01 | All predecessors in Wave 1 |
| **Wave 3** | S-4.01, S-5.01, S-6.02 | All predecessors in Wave 1 or Wave 2 (max predecessor wave = 2) |
| **Wave 4** | S-10.01 | Depends on S-6.02 (W3), S-4.01 (W3), plus W1/W2 predecessors |
| **Wave 5** | S-10.02, S-11.01 | S-10.02 depends on S-10.01 (W4); S-11.01 standalone (no product deps — scheduled last per D-035) |

No cycles were detected. Topological ordering is valid.

---

## Conflict Detection

**In-progress stories:** None — this is the first story set in this feature cycle. No conflicts.

**Same-file conflicts:** No two Wave-N stories target the same implementation file. Each story
targets a distinct module (`hooks/require-review/`, `hooks/disposition-guard/`, `skills/update-jira/`,
`skills/assess-priority/`, `skills/investigate-event/`, `skills/activate/`, `skills/onboard-customer/`,
`skills/onboard-sensor/`, `skills/sensor-metrics/`, `skills/scan-threats/`, `skills/monitoring-loop/`,
`scripts/demo/`).

**Sequential co-ownership — `skills/monitoring-loop/SKILL.md`:** S-10.01 (Wave 4) CREATES
`skills/monitoring-loop/SKILL.md` with the 9-stage core pipeline. S-10.02 (Wave 5) MODIFIES
that file to wire in two integration points: (a) replace the S-10.01 stub 24h-lookback branch
with a `VALIDATE_WATERMARK_FOR_RUN(org, sensor)` call at run start, and (b) insert
`DETECT_LATE_EVENT(event._time, stored_watermark)` in the per-alert loop. This is a
SEQUENTIAL co-ownership (S-10.01 writes, S-10.02 extends) — safe because `depends_on: [S-10.01]`
ensures S-10.01 completes and merges before S-10.02 begins.

**Conflict report:** NONE (S-10.01→S-10.02 co-ownership is sequential, not concurrent).

---

## BC to Stories Traceability Matrix

| BC ID | Version | Stories | Full Coverage? |
|-------|---------|---------|---------------|
| BC-3.01.001 | v1.25 | S-3.01 | Yes |
| BC-3.03.001 | v1.42 | S-3.02 | Yes |
| BC-4.02.001 | v1.21 | S-4.01 | Yes |
| BC-4.05.001 | v1.4 | S-4.02 | Yes |
| BC-5.01.001 | v1.15 | S-5.01 | Yes |
| BC-6.01.001 | v1.8 | S-6.03 | Yes |
| BC-6.01.003 | v1.7 | S-6.01 | Yes |
| BC-6.01.004 | v1.1 | S-6.02 | Yes |
| BC-8.02.001 | v1.4 | S-8.01 | Yes |
| BC-9.01.001 | v1.2 | S-9.01 | Yes |
| BC-10.01.001 | v1.36 | S-10.01, S-10.02 | Yes (core pipeline S-10.01; watermark/late-event S-10.02) |

S-11.01: no product BCs (demo operator tooling per D-006/D-035).

---

## VP to Stories Matrix

Regenerated after Pass-1 remediation (2026-09-04); P1-005 gap-closure (2026-09-04).
Pass-25 closure (2026-09-04): VP-HOOK-031 row regenerated with COMPLETE frozen §4 mutant
kill-set (SM-47/SM-51/SM-52/SM-53/SM-73/SM-77/SM-78/SM-79/SM-80); S-3.02 AC-020..AC-024
added as discriminating kills for SM-47/51/52/53/73; S-5.01 EC-006 retained as SM-73
end-to-end co-guard; S-3.01 AC-002 tag corrected to remove erroneous emitter-SM references
(SM-61/SM-62/SM-64 are S-3.02 emitter kills, not S-3.01 consumer kills).
Every VP maps to exactly its owning story(ies) as derived from corrected story
frontmatter, reconciled to verification-delta roster VP-HOOK-024..036 /
VP-SKILL-050..077 plus all base regression VPs appearing in story frontmatter.
VP-HOOK-027 corrected to S-10.01 sole-ownership (BC-10.01.001 Inv#14 primary;
prior S-3.02 assignment was wrong — no frontmatter backing). VP-HOOK-007/008/009
added for S-3.02 (base disposition-guard regression VPs, were in S-3.02 frontmatter
but missing from matrix). VP-HOOK-029 P23-001 remediation (2026-09-04): S-3.02 added as EMITTER co-owner
(AC-014/AC-015/AC-016 kill SM-38/SM-39/SM-41/SM-45 in disposition-guard-f2-delta.bats);
S-10.01 AC-017 retained as end-to-end consumer-boundary integration guard.
Pass-25 STEP 2 completeness sweep (2026-09-05): ALL 5 VP rows with partial kill-sets
updated to enumerate COMPLETE frozen §4 mutant kill-sets — VP-HOOK-027 (SM-28),
VP-HOOK-033 (SM-57/SM-58/SM-74), VP-HOOK-035 (SM-61/SM-62/SM-63/SM-64/SM-66/SM-67/SM-69),
VP-HOOK-036 (SM-65/SM-68/SM-70/SM-71/SM-72), VP-SKILL-073 (SM-82/SM-83).
Pass-26 residual closure (2026-09-05): Two gaps found and fixed — (1) SM-28: discriminating
kill annotation added to S-10.01 AC-026 text (was present only in this matrix, not in story
file); (2) SM-81: explicit "SM-81 kill" enumeration added to VP-HOOK-025 matrix row (was in
S-3.02 AC-011 story text but not enumerated in this matrix). After these fixes, every
delta-relevant mutant SM-24/26/28/29/46/56..83 now has (i) a discriminating AC in the story
file that names the SM-id, (ii) filed under its frozen VP in this matrix with story+AC
citation, (iii) at the story whose target_module builds the mutated construct, per
BUILD-CAPABILITY RULE. SM-50 retired-in-place (inverted by SM-73; documented non-gap).
Pass-26 P26-001 remediation (2026-09-05): SM-48/SM-49 (VP-HOOK-032 paired mutants) were
silently skipped in Pass-26 initial closure — VP-HOOK-032 was the only VP-HOOK row with no
enumerated kill-set. Fixed: (a) AC-012b added to S-3.02 with discriminating
PROJECT-KEY-CHARSET-DENY vectors for SM-49 (jira_project_key at create/create-review;
§4 vd:1325); (b) VP-HOOK-032 matrix row updated to enumerate SM-48 (AC-012) and SM-49
(AC-012b) with full kill-set per §2 vd:785 + §4 vd:1325; (c) Task 17 in S-3.02 extended
to cover AC-012b jira_project_key vectors. After this remediation, VP-HOOK-032 has a
complete enumerated kill-set matching all other delta-relevant VP-HOOK rows.

| VP ID | Owning Story(ies) | BC Source | Notes |
|-------|-------------------|-----------|-------|
| VP-HOOK-001 | S-3.01 | BC-3.01.001 | regression VP (base — must-still-pass) |
| VP-HOOK-002 | S-3.01 | BC-3.01.001 | regression VP (base — must-still-pass) |
| VP-HOOK-003 | S-3.01 | BC-3.01.001 | regression VP (base — must-still-pass) |
| VP-HOOK-020 | S-3.01 | BC-3.01.001 | regression VP (base — must-still-pass) |
| VP-HOOK-021 | S-3.01 | BC-3.01.001 | regression VP (base — must-still-pass) |
| VP-HOOK-022 | S-3.01 | BC-3.01.001 | regression VP (base — must-still-pass) |
| VP-HOOK-023 | S-3.01 | BC-3.01.001 | regression VP (base — must-still-pass) |
| VP-HOOK-024 | S-3.01 | BC-3.01.001 | regression VP (base — must-still-pass) |
| VP-HOOK-007 | S-3.02 | BC-3.03.001 | regression VP (base disposition-guard — must-still-pass) |
| VP-HOOK-008 | S-3.02 | BC-3.03.001 | regression VP (base disposition-guard — must-still-pass) |
| VP-HOOK-009 | S-3.02 | BC-3.03.001 | regression VP (base disposition-guard — must-still-pass) |
| VP-HOOK-025 | S-3.02 | BC-10.01.001 + BC-3.03.001 | 18-field verdict schema; delta legs: AC-011 (field-18 enum-deny + org_slug presence-deny) + AC-011b (fields 16-18 missing-key schema-completeness DENY); regression leg: fields 1-15 missing-field DENY (Regression VP Guard in S-3.02); **SM-81 kill** (org-slug-presence-check-removed, ADV-F2-P28-002 — S-3.02 AC-011; §4: `org_slug` absent or empty-string verdict passes validation under mutation → propagates to regex with no org context; killer: org_slug="" → SCHEMA-VALIDATE-DENY + org_slug absent → SCHEMA-VALIDATE-DENY; §4 vd:1356 area) |
| VP-HOOK-026 | S-3.02 (emitter: AC-017/AC-018/AC-019 kill SM-29/SM-46/SM-56 in tests/hooks/disposition-guard-f2-delta.bats), S-10.01 (loop-side/end-to-end: AC-006/AC-016/AC-020) | BC-3.03.001 + BC-10.01.001 | hard-floor non-overridability (disposition-guard.sh B-BEH); SM-29 kill: unknown-asset-hard-floor-removed (S-3.02 AC-017; §4 vd:1303); SM-46 kill: highseverity-floor-rekeyed-to-recomputed-severity (S-3.02 AC-018; §4 vd:1322); SM-56 kill: known-FP-floor-bypass-branch-added (S-3.02 AC-019; §4 vd:1331); loop-side legs retained at S-10.01 AC-006/AC-016/AC-020; co-ownership mirrors VP-HOOK-029 emitter/end-to-end split and VP-HOOK-035 emitter/loop-side split; verification-delta §2 vd:754 |
| VP-HOOK-027 | S-10.01 | BC-10.01.001 (Inv#14); enforced by BC-3.03.001 (emit) + BC-3.01.001 (consume) | stage-order document-before-action; **SM-28 kill** (stage-order-inverted, ADV-F2-P2-001 — S-10.01 AC-026; §4 vd:1302: execute Stage 8 TICKET ACTION before Stage 7 DOCUMENT verdict Write → no marker when require-review evaluates; correct order verified by S-10.01 AC-026); verification-delta vd:428-430, D-DEC-008 |
| VP-HOOK-028 | S-3.02 | BC-10.01.001 + BC-3.03.001 | verdict-path reachability |
| VP-HOOK-029 | S-3.02 (emitter: AC-014/AC-015/AC-016 kill SM-38/SM-39/SM-41/SM-45), S-10.01 (end-to-end consumer-boundary: AC-017) | BC-10.01.001 + BC-3.03.001 + BC-3.01.001 | STEP-4 under-label DENY+corrective-reason (SM-38 kill: step4-deny-removed; SM-39 kill: deny-corrective-reason-removed — S-3.02 AC-014; §4 vd:1314/1315) + STEP-3 create-review/comment-review unbindable (SM-41 kill: step3-create-review-unbindable-allow-reverted — S-3.02 AC-015; §4 vd:1317) + WRITE_MARKER review-path fail-closed (SM-45 kill: writemarker-review-path-allow-without-marker-reverted — S-3.02 AC-016; §4 vd:1321); all four emitter kill vectors target tests/hooks/disposition-guard-f2-delta.bats; end-to-end consumer-boundary integration guard retained at S-10.01 AC-017 (co-ownership mirrors VP-HOOK-035 emitter/consumer split) |
| VP-HOOK-030 | S-3.02 | BC-3.03.001 + BC-10.01.001 | STEP 1a SEVERITY-MISMATCH consistency |
| VP-HOOK-031 | S-3.02 (emitter: SM-47, SM-51, SM-52, SM-53, SM-73, SM-77, SM-78, SM-79, SM-80 — all 9 VP-HOOK-031 mutant kills), S-5.01 (end-to-end chain; SM-73 co-guard) | BC-3.03.001 + BC-5.01.001 + BC-4.02.001 | markdown path cross-hook; COMPLETE KILL-SET at S-3.02: **SM-47** (G4 d-vector, markdown-routed-into-verdict-emitter, ADV-F2-P11-004 MAJOR — AC-024; §4 vd:1323); **SM-51** (G3 c2, markdown-non-FP-route-to-review-removed, ADV-F2-P12-002 CRITICAL — AC-021; §4 vd:1327); **SM-52** (G3 c1, markdown-fp-comment-marker-revert, ADV-F2-P13-001 CRITICAL — AC-022; §4 vd:1328); **SM-53** (G3-parse p3, markdown-disposition-full-document-substring-scan, ADV-F2-P13-003 MAJOR — AC-023; §4 vd:1329); **SM-73** (G1 a3-nonFP, markdown-gate1-kill-switch-restored, ADV-F2-P22-001 MAJOR — AC-020 emitter unit test; §4 vd:1348; co-guard at S-5.01 EC-006 RETAINED); **SM-77** (G2 b1/b2/b5, markdown-hard-floor-deny-restored, ADV-F2-P25-001 MAJOR — AC-010+EC-010/EC-011; allow+review assertion kills restored-deny); **SM-78** (G5 g1/g2/g3, hard-floor-reads-free-text-scan, ADV-F2-P26-004 MINOR — AC-010b; §4 vd:1353); **SM-79** (structural-deny-downgraded-to-review, ADV-F2-P27-001 MAJOR — AC-009+EC-014; §4 vd:1354 area); **SM-80** (G4 iv, markdown-marker-verdict-field-leak, ADV-F2-P27-002 MEDIUM — AC-010c; §4 vd:1355); end-to-end chain S-5.01 AC-006 |
| VP-HOOK-032 | S-3.02 | BC-3.03.001 + BC-3.01.001 | O7 charset at existing 5 sites + markdown path; COMPLETE KILL-SET: **SM-48 kill** (ticket_id-charset-validation-removed, ADV-F2-P12-001 CRITICAL — S-3.02 AC-012; §4 vd:1221 area: `ticket_id='.*'` on markdown path (O7 site 6) → TICKET-ID-CHARSET-DENY; under SM-48 `.*` interpolated into anchored comment pattern → broadened match → security bypass → mutant dies); **SM-49 kill** (jira_project_key-charset-validation-removed, ADV-F2-P12-007 — S-3.02 AC-012b; §4 vd:1325: `jira_project_key='.*'` at STEP-3 create-review → PROJECT-KEY-CHARSET-DENY; `jira_project_key='X( \|$)\|.*'` at STEP-6 create → PROJECT-KEY-CHARSET-DENY; under SM-49 charset gate absent → broadened create/create-review pattern authorizes unrelated command → mutant dies); positive controls: `ticket_id='SEC-123'` / `jira_project_key='PRISM'` pass; separately killable (SM-48 = ticket_id grammar `^[A-Z][A-Z0-9]+-[0-9]+$` on comment/assign/comment-review/markdown; SM-49 = jira_project_key grammar `^[A-Z][A-Z0-9]+$` on create/create-review — distinct fields, distinct sites); §2 vd:785 |
| VP-HOOK-033 | S-3.01 (consumer), S-3.02 (emitter) | BC-3.01.001 + BC-3.03.001 + BC-10.01.001 | link write-block + anti-fungibility (consumer S-3.01 AC-001); EMIT_LINK_MARKER fail-loud D-028 SM-74 kill (emitter S-3.02 AC-006); COMPLETE KILL-SET: **SM-57 kill** (require-review-write-block-list-jr-issue-link-removed, D-020/P18-001 — S-3.01 AC-001; §4 vd:1332: `jr issue link SEC-42 SEC-99` with empty marker store → DENY; under SM-57 jr issue link not in write-block → passes unguarded); **SM-58 kill** (STEP-6a link anti-fungibility cross-check-removed, D-020/P18-001 — S-3.01 AC-001; §4 vd:1333: `["comment"]` marker + `jr issue link SEC-42 SEC-99` → DENY; under SM-58 the anti-fungibility check absent → comment marker wrongly authorizes link command); **SM-74 kill** (EMIT_LINK_MARKER fail-loud D-028 — S-3.02 AC-006; §4 vd:1349); NOTE: SM-72 (step-3b-carve-out-removed, D-027/P22-003) is VP-HOOK-036 NOT VP-HOOK-033 — SM-72 kill realized at S-3.02 AC-005/EC-007 (frozen §4 verification-delta L1347); verification-delta vd:625, D-020/D-028 |
| VP-HOOK-034 | S-3.02 | BC-3.03.001 + BC-3.01.001 | O7 charset KEY1/KEY2 (SM-59/SM-60) + O7 site-10 resolved_project_key charset re-validation (SM-76, v1.26/P24-002) + org-binding (SM-75); explicit charset-deny kill vectors added in S-3.02 AC-006 (P19-001); verification-delta vd:626 |
| VP-HOOK-035 | S-3.01 (consumer), S-3.02 (emitter), S-10.01 (loop-side positive path) | BC-3.03.001 + BC-3.01.001 + BC-10.01.001 | close write-block + anti-fungibility (consumer S-3.01 AC-002); STEP 4b + CLOSE_STATE_ALLOWLIST emit-time (emitter S-3.02 AC-001/AC-002/AC-002b); loop-side positive auto-close 3-condition AND gate (S-10.01 AC-025); COMPLETE KILL-SET: **SM-61 kill** (close-hard-floor-bypass-branch-added — S-3.02 AC-002c; §4 vd:1336: FP+scored_priority=HIGH → hard_floor_applies()=TRUE → STEP 4 DENY, no close marker; under SM-61 bypass returns FALSE → close marker wrongly issued); **SM-62 kill** (close-kill-switch-gate-removed — S-3.02 AC-002d; §4 vd:1337: FP+scored_priority=LOW+autonomy=false → STEP 5 kill switch → allow-without-marker; under SM-62 kill switch absent → close marker issued under autonomy=false); **SM-63 kill** (close-state-token-allowlist-removed, CONSUMER binding — S-3.01 AC-010; §4 vd:1338: `["close"]` marker + `jr issue move SEC-42 WontFix` → DENY; under SM-63 any close state accepted); **SM-64 kill** (close-ticket_id-charset-validation-removed — S-3.02 AC-002e; §4 vd:1339: ticket_id='.*' → TICKET-ID-CHARSET-DENY; under SM-64 `.*` interpolated → SEC-009 broadened-match); **SM-66 kill** (close-disposition-gate-removed — S-3.02 AC-001/EC-003; §4 vd:1341: disposition=TP+close → CLOSE-DISPOSITION-DENY fires BEFORE kill switch; under SM-66 STEP-4b removed → TP+close allowed through); **SM-67 kill** (emit-time-non-allowlisted-close-state — S-3.02 AC-002b; §4 vd:1342: jira_close_state='WontFix'∉CLOSE_STATE_ALLOWLIST → CLOSE-STATE-DENY at emit time; under SM-67 emit-time check removed → non-allowlisted state accepted); **SM-69 kill** (step-4b-close-disposition-gate-TP+close+autonomy=false — S-3.02 AC-001/AC-002; §4 vd:1344: TP+close+autonomy=false → STEP 4b fires → CLOSE-DISPOSITION-DENY; under SM-69 STEP 4b does not fire before STEP 5 → silent allow-without-marker for TP+close under kill-switch); verification-delta vd:626-627/~L1336-1344, D-021/D-023/D-025/P18-001 |
| VP-HOOK-036 | S-3.02, S-4.01, S-10.01 | BC-10.01.001 + BC-3.03.001 + BC-3.01.001 | compound two-sequential-verdict-Write D-022 (S-4.01 AC-001; S-10.01 AC-019/AC-021/AC-022) + D-026 orphan-link: monitoring loop DETECTS + issues link-only verdict (S-10.01 AC-020b SM-68/SM-70 kill) + SM-71 loop-predicate negative control: link-PRESENT → D-026 does NOT over-fire (S-10.01 AC-020c — frozen §4 L1346); update-jira EXECUTES `jr issue link O C` idempotently (S-4.01 AC-005/AC-006 SM-68 negative control only; SM-71 removed from S-4.01 AC-006); SM-72 STEP-3b carve-out kill emitter-side (S-3.02 AC-005/EC-007 — frozen §4 L1347; S-3.02 added to VP-HOOK-036 owner list); D-026 is BC-10.01.001/architecture-delta territory — BC-4.02.001 has no D-026 clause; COMPLETE KILL-SET: **SM-65 kill** (compound-action-marker-model-single-use — S-4.01 AC-003/EC-007 (single-use anti-fungibility; require-review consume S-3.01 AC-007); §4 vd:1340: after the comment/create marker is consumed by the first `jr` command, a second `jr issue link` against the SAME marker → DENY; single-use enforced by consume→rename `.used`; under SM-65 single marker wrongly authorizes the second write); **SM-68 kill** (D-026-orphan-link-detect-removed — S-10.01 AC-020b; §4 vd:1343: no link marker present + ticket has open child → link-only verdict issued; under SM-68 DETECT removed → orphan link silently skipped); **SM-70 kill** (D-026-orphan-link-misrouted-to-rule-1 — S-10.01 AC-020b; §4 vd:1345: orphan MISROUTED to rule-1 comment (WRONG-ACTION: a comment verdict fires instead of link-only), distinct from SM-68's NO-ACTION (stays unlinked); under SM-70 D-026 precedence absent → orphan O matches rule 1 → a rule-1 COMMENT appended to O instead of link-only verdict); **SM-71 kill** (D-026-over-fire-link-already-present — S-10.01 AC-020c; §4 vd:1346: link already in place → D-026 does NOT fire; under SM-71 presence-check removed → fires redundantly); **SM-72 kill** (step-3b-carve-out-removed — S-3.02 AC-005/EC-007; §4 vd:1347: D-022 double-verdict Write → STEP-3b passes second through carve-out; under SM-72 carve-out absent → second verdict DENY); verification-delta vd:627/L1340/L1343-1347, D-022/D-026 |
| VP-SKILL-006 | S-4.01 | BC-4.02.001 | regression VP |
| VP-SKILL-007 | S-4.01 | BC-4.02.001 | regression VP |
| VP-SKILL-008 | S-4.01 | BC-4.02.001 | regression VP |
| VP-SKILL-018 | S-5.01 | BC-5.01.001 | regression VP |
| VP-SKILL-019 | S-5.01 | BC-5.01.001 | regression VP |
| VP-SKILL-020 | S-5.01 | BC-5.01.001 | regression VP |
| VP-SKILL-021 | S-6.03 | BC-6.01.001 | regression VP (base activate) |
| VP-SKILL-022 | S-6.03 | BC-6.01.001 | regression VP (base activate) |
| VP-SKILL-023 | S-6.03 | BC-6.01.001 | regression VP (base activate) |
| VP-SKILL-024 | S-6.03 | BC-6.01.001 | regression VP (base activate) |
| VP-SKILL-025 | S-6.03 | BC-6.01.001 | regression VP (base activate) |
| VP-SKILL-029 | S-4.02 | BC-4.05.001 | regression VP (base assess-priority) |
| VP-SKILL-030 | S-4.02 | BC-4.05.001 | regression VP (base assess-priority) |
| VP-SKILL-031 | S-4.02 | BC-4.05.001 | regression VP (base assess-priority) |
| VP-SKILL-032 | S-4.02 | BC-4.05.001 | regression VP (base assess-priority) |
| VP-SKILL-033 | S-4.02 | BC-4.05.001 | regression VP (base assess-priority) |
| VP-SKILL-034 | S-4.02 | BC-4.05.001 | regression VP (base assess-priority) |
| VP-SKILL-050 | S-10.02 | BC-10.01.001 | watermark monotonicity (never regresses) + future-timestamp rejection; future leg: S-10.02 AC-003(b); monotonicity primary leg: S-10.02 AC-013 (inject pre-existing watermark; run with older events; assert post ≥ pre); MOVED from S-10.01 (had no implementing AC); verification-delta vd:684-685/756 |
| VP-SKILL-051 | S-6.03 | BC-6.01.001 | prism version gate: `prism --version` parsed vs `1.0.0-rc.1`; below → halt with version-gate error, no MCP write; at/above → proceed to dual MCP write (B-INT; prism-version-check.sh; exercised by S-6.03 AC-008; FINALIZED F1 — NOT new this cycle; vd:757); CLOSE_STATE_ALLOWLIST ACs (S-6.03 AC-001..006) trace to BC-6.01.001 PC#13 — no dedicated frozen VP; HS-053/HS-054 holdout coverage |
| VP-SKILL-052 | S-6.01 | BC-6.01.003 | UUID-v7 format validation (malformed UUID rejected); exercised by S-6.01 AC-016 |
| VP-SKILL-053 | S-6.01 | BC-6.01.003 | idempotent directory creation (P14-005 repurposed); exercised by S-6.01 AC-017 |
| VP-SKILL-054 | S-6.02 | BC-6.01.004 | |
| VP-SKILL-055 | S-6.02 | BC-6.01.004 | |
| VP-SKILL-056 | S-8.01 | BC-8.02.001 | per-org × sensor output completeness — for each row returned by prism_sensor_health, output contains org_slug, sensor_id, last_seen_ts, row_count, error_rate; exercised by S-8.01 AC-009 (BATS integration/per-row field assertion; 2-org×2-sensor DTU fixture; mutation kill: drop error_rate or row_count → fail) |
| VP-SKILL-057 | S-8.01 | BC-8.02.001 | |
| VP-SKILL-058 | S-9.01 | BC-9.01.001 | |
| VP-SKILL-059 | S-9.01 | BC-9.01.001 | UPGRADED structural→behavioral (P10-005); exercised by S-9.01 AC-017 (multi-org DTU fixture SM-24 kill + static parse data/threat-hunt-queries.md every query has org_slug) |
| VP-SKILL-060 | S-10.01 | BC-10.01.001 | B-INT: known-FP fast-path — Stage 2 match → FP disposition with zero Stage-4 enrichment calls (spy-based); exercised by S-10.01 AC-027; vd:766 |
| VP-SKILL-061 | S-10.01 | BC-10.01.001 | B-INT: sensor-silence positive finding — BLIND-SPOT emitted, never empty / never "nothing to report"; exercised by S-10.01 AC-028; vd:767 |
| VP-SKILL-062 | S-10.01 | BC-10.01.001 | B-INT: never-auto-reopen — Closed/Resolved ticket never transitioned to open state; NEW linked ticket created instead; exercised by S-10.01 AC-024; vd:768; ADDED for GAP-001 resolution |
| VP-SKILL-063 | S-10.01 | BC-10.01.001 | B-INT: Tavily degradation → continue Perplexity-only, do NOT force Indeterminate; exercised by S-10.01 AC-012; vd:769 |
| VP-SKILL-064 | S-10.01 | BC-10.01.001 | UPGRADED static→behavioral+adversarial (P21-002); three-leg: (i) prism-DTU multi-org fixture (org-a monitoring-loop run returns ZERO org-b/c rows; SM-24 kill — verification-delta §4/vd:1298), (ii) static org_slug-constraint assertion (grep query-builder path), (iii) adversarial unscoped-query rejection (bare PrismQL never issued); exercised by S-10.01 AC-014 (verification-delta vd:421, vd:1629–1639) |
| VP-SKILL-065 | S-10.01 | BC-10.01.001 | autonomy_enabled kill switch; exercised by S-10.01 AC-007 |
| VP-SKILL-066 | S-4.01 | BC-4.02.001 | never-auto-reopen on update-jira path; exercised by S-4.01 AC-009 (Resolved→propose-only, Closed→create-new+link, static grep; SM-26) |
| VP-SKILL-067 | S-4.01 | BC-4.02.001 | SLA surface-never-assume; exercised by S-4.01 AC-010 (5 vectors: append/link/propose + SLA-unknown + static grep) |
| VP-SKILL-068 | S-10.01 | BC-10.01.001 | dedup: in-grace re-fetched event appends COMMENT not new ticket (Invariant #8); exercised by S-10.01 AC-010; verification-delta vd:425 |
| VP-SKILL-069 | S-5.01 | BC-5.01.001 | investigate-event PrismQL org_slug scoping; S-5.01 AC-008; verification-delta vd:426 |
| VP-SKILL-070 | S-4.02 | BC-4.05.001 | B-INT+B-STR: assess-priority PrismQL org_slug scoping (PC#5a/5b/5d) — static WHERE-clause assertion + DTU multi-org fixture + unscoped-query adversarial leg; exercised by S-4.02 AC-008; vd:427 |
| VP-SKILL-071 | S-4.02 | BC-4.05.001 | B-INT: assess-priority confidence float→enum consistency per D-DEC-011 (boundaries 0.75, 0.40; inconsistent-pair-invalid); exercised by S-4.02 AC-009; vd:428 |
| VP-SKILL-072 | S-10.02 | BC-10.01.001 | first-run 24h lookback; SOLE OWNERSHIP S-10.02 (removed from S-10.01 per P1-008); S-10.02 AC-010 |
| VP-SKILL-073 | S-10.02 | BC-10.01.001 | PRIMARY: DETECT_LATE_EVENT correctness — event strictly below RAW stored_watermark appends LATE_EVENT_DETECTED to watermarks/audit.log without dropping event; first-run early return; P40-001 raw-watermark threshold; exercised by S-10.02 AC-011 (primary leg), AC-005, AC-006. ADDENDUM (v1.36/P43-002): VALIDATE_WATERMARK_FOR_RUN cardinality once-per-run; S-10.02 AC-011 (addendum leg). COMPLETE KILL-SET: **SM-82 kill** (VALIDATE_WATERMARK_FOR_RUN-moved-into-loop — S-10.02 AC-011 addendum; §4 vd:1357: VALIDATE_WATERMARK_FOR_RUN called once before loop start; under SM-82 moved inside loop → called N-times per run, cardinality invariant violated); **SM-83 kill** (late_event_enabled-NO-OP-guard-removed — S-10.02 AC-011 addendum; §4 vd:1358: late_event_enabled=false → DETECT_LATE_EVENT is a no-op, no LATE_EVENT_DETECTED entry appended; under SM-83 NO-OP guard removed → late event detection runs unconditionally, always appending regardless of feature flag) |
| VP-SKILL-074 | S-10.01 | BC-10.01.001 | NORMALIZE_SEVERITY per-sensor-family correctness (D-DEC-013): CrowdStrike 1-100 numeric, Armis/Claroty risk-band, Cyberint→CRITICAL+uncertainty_explicit, unrecognized→CRITICAL+uncertainty_explicit; exercised by S-10.01 AC-029; BC-10.01.001 Invariant #9 field-13 + Invariant #14 Stage-1 |
| VP-SKILL-075 | S-10.02 | BC-10.01.001 | cron wrapper Gate 1 + Gate 2; S-10.02 AC-008/AC-009; verification-delta vd:442. Pre-run cron wrapper precondition checks (AC-016 jira_project_key defense-in-depth, AC-017 prism.mcp.json presence, AC-018 --bare structural assertion) are structural/operational assertions that trace directly to BC-10.01.001 Preconditions #9/#4/#2 without a dedicated VP in the frozen roster — covered by S-10.02 ACs. |
| VP-SKILL-076 | S-6.01 (BC-6.01.003 onboard-customer leg), S-6.03 (BC-6.01.001 activate leg) | BC-6.01.001 + BC-6.01.003 | setup-time jira_project_key charset — SPLIT behavioral kill: S-6.03 AC-007 (activate-side reject; SM-54 kill) + S-6.01 AC-009 (EC-010 hyphenated-key reject; SM-54 kill); S-6.01 AC-014 (doc-grep: SKILL.md documents D-DEC-008 constraint) is structural companion only, not behaviorally discriminating |
| VP-SKILL-077 | S-6.01 | BC-6.01.003 | AD-017 credential-decline; exercised by S-6.01 AC-015 (structural SKILL.md prose; no SM-N mutant — mirrors VP-SKILL-054) |

---

## BC Clause Coverage Matrix

Coverage summary per story. Detailed clause-level coverage tracked in each story's AC list.

| BC ID | Covering Stories | Clause Coverage |
|-------|-----------------|----------------|
| BC-3.01.001 | S-3.01 | All link/close anti-fungibility clauses (D-020/D-021) |
| BC-3.03.001 | S-3.02 | Close-disposition gate (D-023), orphan-link recovery (D-026), two-tier review-class link (D-027/D-028), SAVE-ALWAYS (D-029) |
| BC-4.02.001 | S-4.01 | Compound create+link (D-022/D-024), link-verdict idempotent execution (executor role for D-026 orphan-link — D-026 detection and verdict emission are BC-10.01.001 territory, owned by S-10.01 AC-020b; BC-4.02.001 has no D-026 clause), SAVE-ALWAYS markdown (D-029) |
| BC-4.05.001 | S-4.02 | scored_priority field 18 producer/consumer coherence |
| BC-5.01.001 | S-5.01 | D-029 SAVE-ALWAYS-SUCCEEDS invariant 7 (markdown path allow-without-deny) |
| BC-6.01.001 | S-6.03 | CLOSE_STATE_ALLOWLIST setup-time validation |
| BC-6.01.003 | S-6.01 | UUID-v7 org slug, Jira project key validation |
| BC-6.01.004 | S-6.02 | sensor overlay creation, AD-017 piped-stdin credential pattern |
| BC-8.02.001 | S-8.01 | prism_sensor_health telemetry retrieval |
| BC-9.01.001 | S-9.01 | PrismQL hunting query execution |
| BC-10.01.001 | S-10.01, S-10.02 | Stages 0-8 + ICD-203 + hard-floor + kill-switch + Stage-0 MISSING-JIRA-PROJECT-KEY fatal precondition check (S-10.01 AC-030); VALIDATE_WATERMARK_FOR_RUN + DETECT_LATE_EVENT + cron wrapper Gates 1+2 + pre-run cron precondition guards (jira_project_key defense-in-depth AC-016, prism.mcp.json AC-017, --bare structural assert AC-018) (S-10.02) |

---

## Edge Case Coverage Matrix

| Source | EC/Error ID | Description | Story | AC/EC Reference |
|--------|-------------|-------------|-------|----------------|
| BC-10.01.001 | EC-012 | propose-reopen draft (Stage-7 loop action; never-auto-reopen) | S-10.01 | AC-024 (VP-SKILL-062; GAP-001 RESOLVED) |
| BC-10.01.001 | EC-022 | close 3-cond AND gate positive auto-close path | S-10.01, S-3.02 | S-10.01 AC-025 (loop-side positive path); S-3.02 ACs (disposition-guard STEP 4b gate — GAP-002 scope retained) |
| BC-3.01.001 | EC (link scope) | link marker scope anti-fungibility | S-3.01 | ACs trace D-020/D-021 |
| BC-3.03.001 | EC-013 | 3-condition close gate (D-023 STEP 4b) | S-3.02 | ACs trace D-023/D-025 |
| BC-6.01.001 | EC (CLOSE_STATE invalid) | jira_close_state not in allowlist at activate | S-6.03 | ACs trace BC-6.01.001 PC#13 |
| BC-5.01.001 | EC (hard-floor markdown) | GATE 1/2 on investigation-*.md path → route-to-review | S-5.01 | ACs trace D-029 Inv#7 |
| BC-10.01.001 | Precondition #9 (Stage-0) | Global `jira_project_key` absent → MISSING-JIRA-PROJECT-KEY fatal refuse-to-start before any alerts processed | S-10.01 | AC-030 (loop-level Stage-0 fatal check) |
| BC-10.01.001 | Precondition #9 (cron) | Cron wrapper defense-in-depth: `jira_project_key` absence → exit 1 before Claude invocation | S-10.02 | AC-016 |
| BC-10.01.001 | Precondition #4 | Cron wrapper validates `~/.claude/prism.mcp.json` existence at startup → exit 1 if absent | S-10.02 | AC-017 |
| BC-10.01.001 | Precondition #2 | Cron wrapper MUST NOT contain `--bare` (D-DEC-003 structural defect) | S-10.02 | AC-018 |

---

## Gap Register

| Gap ID | Level | Source | Clause/Item | Justification | Resolution Target |
|--------|-------|--------|-------------|---------------|-------------------|
| GAP-001 | L2 | BC-10.01.001 EC-012 | propose-reopen decision path in the monitoring-loop | **RESOLVED — prior justification was factually incorrect.** EC-012 (propose-reopen) is a Stage-7 monitoring-loop action, NOT disposition-guard territory. When the root cause matches a RESOLVED ticket, the monitoring-loop drafts a `propose-only` comment with annotation and a human-readable SLA statement; it does NOT execute a reopen. The never-auto-reopen invariant (VP-SKILL-062) prohibits autonomous reopen regardless of `autonomy_enabled`. This EC is now covered by S-10.01 AC-024 (propose-reopen draft + `propose-only` annotation + SLA statement + never-execute-reopen invariant). Disposition-guard is NOT involved in the propose-reopen path. | RESOLVED — covered by S-10.01 AC-024 (vd:768, VP-SKILL-062) |
| GAP-002 | L2 | BC-10.01.001 EC-022 | close 3-condition AND gate complete auto-close path — disposition-guard STEP 4b gate coverage | EC-022 (full close 3-cond AND gate) disposition-guard STEP 4b coverage: the STEP 4b gate logic that denies a close verdict when disposition∉{FP,BTP} (D-025/D-023) is disposition-guard territory, covered by S-3.02 ACs (AC-001/AC-002/AC-002b). The monitoring-loop positive path (disposition∈{FP,BTP} + hard_floor=false + autonomy=true → close marker issued) is now covered by S-10.01 AC-025. This gap remains scoped to the disposition-guard STEP 4b test coverage (ensuring all deny paths and the STEP 6 emit-time check are covered in S-3.02), which is S-3.02's sole responsibility. | Disposition-guard STEP 4b coverage: S-3.02 ACs. Loop-side positive path: S-10.01 AC-025. GAP-002 remains for S-3.02 STEP 4b deny-path test coverage. |

| GAP-003 | L1 | BC-10.01.001 PC#6 | append-comment + link-related SLA-surface legs | BC-10.01.001 PC#6 requires the loop to surface SLA impact on append-comment / link-related / propose-reopen. Propose-reopen is covered by S-10.01 AC-024. Append-comment and link SLA-surface are delegated to update-jira S-4.01 AC-010 (VP-SKILL-067), which the monitoring-loop invokes at Stage 8 for those paths — VP-SKILL-067 exercises 5 SLA-surface vectors including append and link. No S-10.01 AC is needed for those two legs; the traceability is transitive via Stage-8 delegation. (P9-003 traceability closure) | RESOLVED via transitive delegation to S-4.01 AC-010 |

All gaps are KNOWN-JUSTIFIED. The adversary pass and F3 gate should treat them as scoped exclusions, not coverage omissions.

---

## Critical Path Analysis

Longest path through the dependency graph (determines minimum elapsed waves):

```
S-3.01 (W1) → S-3.02 (W2) → S-4.01 (W3) → S-10.01 (W4) → S-10.02 (W5)
```

Critical path length: 5 waves.

Parallel acceleration opportunities:
- S-4.02, S-6.03 run in Wave 1 in parallel with S-3.01
- S-6.01, S-8.01, S-9.01 run in Wave 2 in parallel with S-3.02
- S-5.01, S-6.02 run in Wave 3 in parallel with S-4.01
- S-11.01 (demo) is unconstrained by product deps; slotted Wave 5 as last slot per D-035

**Total estimated effort:** 88 story points across 13 stories.

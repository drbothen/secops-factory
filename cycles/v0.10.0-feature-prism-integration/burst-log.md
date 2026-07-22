---
document_type: burst-log
cycle_id: v0.10.0-feature-prism-integration
producer: state-manager
---

# Burst Log: v0.10.0-feature-prism-integration

Narrative record of completed bursts. Current phase steps rotated out of STATE.md
are archived here when the 5-row limit is reached.

---

## Burst 0: Cycle Init + Environment Check (2026-07-19 → 2026-07-20)

**Steps archived from STATE.md Current Phase Steps:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| worktree-health | devops-engineer | DONE | PASS — .factory/ on factory-artifacts; no repairs needed |
| feature-cycle-init | state-manager | DONE | cycle v0.10.0-feature-prism-integration created; brief + research ingested; D-004..D-006 recorded |

**Narrative:**
- devops-engineer confirmed `.factory/` worktree mounted on `factory-artifacts`, no repairs needed.
- state-manager initialized cycle directory, ingested prism-integration-handoff-brief.md and soc-analyst-workflow-2026.md, recorded decisions D-004 (full handoff brief scope), D-005 (marker mechanism for DI-013), D-006 (demo assets out of scope).

---

## Burst 1: F1 Delta Analysis Complete (2026-07-20)

**Steps in STATE.md Current Phase Steps at F1-gate-pending:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| environment-check | dx-engineer | DONE | ENVIRONMENT_CHECK: PASS — 165/165 BATS green (14 parity skips by design), jr 0.5.0 installed+authenticated, prism absent (expected — integration target), all Phase 0 MCP blockers resolved |
| F1: impact-boundary | architect | DONE | .factory/phase-f1-delta-analysis/impact-boundary.md — 14 NEW / 13 MODIFIED / 12 DEPENDENT plugin artifacts (pre-REC-001); 8 ASMs, 8 Rs; 9 F2 decisions (D-DEC-001..009) |
| F1: artifact-mapping | business-analyst | DONE | .factory/phase-f1-delta-analysis/artifact-mapping.md v1.1 — 6 BCs MODIFIED, 3 dependent, 5 NEW BC slots; ~57 direct + ~17 dependent regression-zone tests; 6-7 HS revisions + 10 new HS subjects (HS-035..044); 5 new VP subjects |
| F1: delta-analysis synthesis | architect | DONE | .factory/phase-f1-delta-analysis/delta-analysis.md v1.1 + affected-files.txt — feature_type: backend, intent: feature, scope: standard; 6 reconciliations (REC-001..006) |
| F1: consistency audit | consistency-validator | DONE | f1-consistency-validation.md — PASS-WITH-MINORS (1 MAJOR VP namespace collision + 6 minors); ALL 7 remediated same-burst |

**Narrative:**
- dx-engineer ran full environment check: 165/165 BATS green (14 parity skips by design per existing test matrix), jr 0.5.0 installed and authenticated, prism binary absent as expected (it is the integration target for this cycle), all Phase 0 MCP blockers (perplexity/tavily/playwright/context7) confirmed resolved.
- architect produced impact-boundary.md: 14 new plugin artifacts, 13 modified, 12 dependent; identified 8 architectural seam modifications (ASMs), 8 refactors (Rs); queued 9 F2 decisions (D-DEC-001..009).
- business-analyst produced artifact-mapping.md v1.1: 6 BCs requiring modification + 3 dependent BCs; 5 new BC slots allocated (BC-6.01.003/004, BC-8.02.001, BC-9.01.001, BC-10.01.001); regression zone mapped to ~57 direct + ~17 dependent tests; 6-7 existing HS revisions + 10 new HS subjects (HS-035..044); 5 new VP subjects (VP-HOOK-024/025/026, VP-SKILL-050/051).
- architect synthesized delta-analysis.md v1.1 + affected-files.txt: classified as backend feature / standard scope. Resolved 6 reconciliations (REC-001..006); notable: update-jira skill reclassified MODIFIED (not new); cross-tenant correlation resolved prism-side (org_slug invariant only — no new factory-side tenant logic).
- consistency-validator audited all F1 artifacts: found 1 MAJOR (VP namespace collision) + 6 minors; all 7 remediated in the same burst (delta-analysis v1.1, artifact-mapping v1.1, impact-boundary corrected). Final gate verdict: PASS-WITH-MINORS (0 open).
- F1 gate now awaiting human approval. On approval: F2 spec evolution with 9 D-DEC decisions queued + marker mechanism design.

**Regression baseline:** main SHA d181ca2
**Feature classification:** backend / feature / standard

---

## Burst 2: F2 Spec Evolution — Body Authored + Adversarial Passes 1-4 (2026-07-20 → 2026-07-21)

**Steps rotated from STATE.md Current Phase Steps at wrap mid-F2:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F1 gate | human | DONE | F1 approved; factory-artifacts HEAD eb3ca2e; F2 commenced |
| F2: spec body authored | architect / product-owner | DONE | 11 BCs (6 modified + 5 new) + 5 delta docs (architecture-delta v1.7, verification-delta v1.7, prd-delta v1.8, dtu-assessment, asm-004-validation); spec 1.0.0 → 1.1.0 MINOR; D-DEC-001..012 locked |
| F2: adversarial passes 1-4 | adversary | DONE | 4 passes each found real defects — all remediated; 0/3 clean streak; pass1 2C/8M → pass2 1C/3M → pass3 1C/4M → pass4 2C/4M |
| F2: version-coherence sweep | state-manager | DONE | spec-changelog.md authored; BC frozen versions confirmed |
| F2: pass 5 + consistency dispatch | orchestrator | WRAP | dispatched pre-wrap; pass 5 result NOT captured (in-message only); f2-consistency-validation-pass5.md NOT written to disk; re-run on resume |

**Narrative:**
- Human approved F1 gate; F2 spec evolution commenced. architect + product-owner produced the full F2 spec body: 6 modified BCs (BC-3.01.001 v1.17, BC-3.03.001 v1.13, BC-4.02.001 v1.8, BC-4.05.001 v1.3, BC-5.01.001 v1.8, BC-6.01.001 v1.5) and 5 new BCs (BC-6.01.003/004/BC-8.02.001/BC-9.01.001 v1.1, BC-10.01.001 v1.9 monitoring-loop). Delta documents produced: architecture-delta v1.7, verification-delta v1.7, prd-delta v1.8, dtu-assessment.md (DTU_REQUIRED: true — prism L3 via prism's own demo server, jr L2 mock), asm-004-validation.md (PARTIAL → resolved-by-design via --strict-mcp-config --mcp-config prism.mcp.json). spec-changelog.md authored: spec 1.0.0 → 1.1.0 MINOR.
- Adversarial spec-convergence loop ran 4 passes. Every pass found real defects (0/3 clean streak):
  - Pass 1 (2C/8M): marker TTL semantics, command_pattern anchor gaps; all remediated.
  - Pass 2 (1C/3M): ICD-203 12-field vs 15-field artifact-class split; all remediated.
  - Pass 3 (1C/4M): asset_type=unknown missing from hard-floor; watermark monotonicity gap; all remediated.
  - Pass 4 (2C/4M): JSON-first dispatch ordering (D-DEC-008 CRITICAL); anchored create pattern (D-DEC-008 CRITICAL); D-DEC-012 review-ticket path; autonomy_enabled operational field; enum-membership validation; all remediated.
- D-DEC-001..012 all locked in architecture-delta. DI-013 RESOLVED in-spec via marker mechanism. DTU confirmed required (prism DTU demo server needed). Version-coherence sweep complete; BC versions frozen.
- At wrap: adversarial pass 5 and F2 consistency audit (f2-consistency-validation-pass5.md) were dispatched but NOT captured (pass 5 result was in-message only; consistency report not written to disk). Re-run required on resume.

**COMPUTE-AT-COMMIT placeholders:** New BCs carry input-hash COMPUTE-AT-COMMIT markers where inputs changed during adversarial remediation. Compute on next factory-artifacts backup after confirmed stable.

**Factory-artifacts HEAD at wrap:** see `git -C .factory log -1 --format='%h %s'`

### Burst 2 Archival — Rows displaced from STATE.md Current Phase Steps

The following rows were archived from STATE.md when the pass-5 remediation row was added (5-row limit enforced):

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: spec body authored | architect / product-owner | DONE | 11 BCs (6 modified + 5 new) + 5 delta docs; spec 1.0.0→1.1.0 MINOR; D-DEC-001..012 locked; DTU required (prism demo server + jr mock) |
| F2: adversarial pass 1-2 | adversary | DONE | pass1 2C/8M (marker TTL + anchor), pass2 1C/3M (ICD-203 12/15-field split) — all remediated |

---

## Burst 3: F2 Pass-5 Remediation COMPLETE (2026-07-21)

**Steps added to STATE.md Current Phase Steps this burst:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-5 remediation | architect / product-owner / formal-verifier | DONE | arch-delta v1.8; BC-3.03.001 v1.14; BC-10.01.001 v1.10; verif-delta v1.8; prd-delta v1.9; brief §3.9 amended |

**Narrative:**

Pass-5 remediation addressed P5-001 (CRITICAL — silent discard when LLM ticket_action_type is non-review but hard_floor_applies()), P5-002 (MAJOR — kill-switch bypass: create-review/comment-review marker exemptions not gated on deterministic invariant), and P5-003 (MAJOR — stale §D-DEC-001 authoritative schema block). Kill-switch conflict with brief §3.9 resolved via human-confirmed Option A (2026-07-21).

**Artifacts produced by this burst:**

- `phase-f2-spec-evolution/architecture-delta.md` v1.7 → v1.8: STEP 5 fail-loud upgrade tree (P5-001); STEP 3 hard_floor_applies() gate for review-exemption (P5-002); §D-DEC-001 schema v2.1 superset sync including create-review/comment-review/Indeterminate/ticket_action_type (P5-003); O3 standing rule codified in D-DEC-012 ("every LLM-supplied routing field that grants/bypasses a security control must be cross-validated against a hook-computed invariant"); kill-switch/brief-§3.9 conflict RESOLVED via Option A.
- `phase-0-ingestion/behavioral-contracts/BC-3.03.001.md` v1.13 → v1.14: STEP 3 gate + Option A kill-switch finalization; STEP 5 fail-loud upgrade + UNDER-LABEL-CORRECTED audit trail; schema v2.1 sync in all Inv#4/PC#3 snippets; EC-012 four-case table; canonical test-vector sync (TV-SYNC gated terminology row ~483; row ~488 split into pinned cases c/d).
- `phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` v1.9 → v1.10: Inv#10 safety-net-not-delegation note; F-003 VP-SKILL-061 sensor-silence reword ("last_seen_ts age > 24 h").
- `phase-f2-spec-evolution/verification-delta.md` v1.7 → v1.8: VP-HOOK-029 re-scoped to under-label vectors (P0); SM-32 split into SM-32a/SM-32b separately-killable variants (mutant count 27→28); VP-HOOK-026 over-label vectors; stale STEP 3/STEP 5 semantics swept (VP-HOOK-026 core legs, SM-16/21/23/29); §7 Part F routing added; test estimate ~231→~238.
- `phase-f2-spec-evolution/prd-delta.md` v1.8 → v1.9: stale "12-field" counts in §4/§6 corrected to the 12-investigation-markdown / 15-verdict-JSON split.
- `feature/prism-integration-handoff-brief.md`: §3.9 kill-switch paragraph amended per Option A + amendment note citing P5-002 and human confirmation 2026-07-21.

**Decision recorded:** D-007 (kill-switch Option A) — create-review/comment-review escalation markers stay live under `autonomy_enabled=false`, gated on hook-computed `hard_floor_applies()` OR Indeterminate disposition. Brief §3.9 amended accordingly.

**Convergence counter:** 0/3 clean passes. Pass 6 is next (fresh adversary context required).

---

## Burst 4: F2 Adversarial Pass 6 Persisted (2026-07-21)

**Steps rotated from STATE.md Current Phase Steps (5-row limit enforced):**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: adversarial pass 3-4 | adversary | DONE | pass3 1C/4M (asset_type=unknown floor), pass4 2C/4M (JSON-first dispatch CRITICAL + anchored create CRITICAL + D-DEC-012) — all remediated |

**Step added to STATE.md Current Phase Steps this burst:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: adversarial pass 6 | adversary | DONE | 2C/3M/3m/2obs — trust boundary re-derived end-to-end: P6-001 consumer accepts review tokens for regular commands (kill-switch bypass, CRITICAL); P6-002 STEP 4 kill switch precedes STEP 5 upgrade → silent discard of under-labeled hard-floor verdicts when autonomy=false (CRITICAL); P6-003 Inv#11/VP-SKILL-065 contradict Option A; P6-004 single demo project key voids cross-org create binding; P6-005 sensor-severity→enum normalization unspecified; P6-009 [process-gap] O3 rule applied emitter-only. Report persisted. |

**Narrative:**

adversary (fresh context) ran pass 6 against the full F2 delta package (brief, architecture-delta v1.8, verification-delta v1.8, prd-delta v1.9, BC-3.01.001 v1.17, BC-3.03.001 v1.14, BC-10.01.001 v1.10, supporting BCs/DTU/ASM). Re-derived the trust boundary end-to-end (emit → store → consume → kill switch → fail-loud) rather than inheriting the emitter-centric conclusions of prior passes.

**Findings (2C/3M/3m/2obs):**
- P6-001 (CRITICAL): `create-review`/`comment-review` markers are fungible with regular `create`/`comment` at the consumer (BC-3.01.001 step (6) accepts either token for the same command pattern) — kill-switch bypass and hard-floor starvation exploitable.
- P6-002 (CRITICAL): STEP 4 kill switch precedes STEP 5 under-label upgrade; under-labeled hard-floor verdicts with `autonomy_enabled=false` produce silent allow-no-marker (contradicts D-DEC-012 "NEVER silent discard").
- P6-003 (MAJOR): Invariant #11 and VP-SKILL-065 assert zero jr writes under kill switch, contradicting D-DEC-012 Option A / EC-006 / EC-014 — propagation gap from pass-5 Option-A decision.
- P6-004 (MAJOR): Create-marker cross-org binding is void with single `PRISM-DEMO` project key (brief §4.1) — per-org-key assumption not satisfied.
- P6-005 (MAJOR): sensor-native severity encodings (numeric, CVSS) not mapped to `{LOW,MEDIUM,HIGH,CRITICAL}` enum; pipeline mass-escalates or mass-denies non-conforming sensor severities.
- P6-006 (MINOR): D-DEC-004 BLIND-SPOT dedup stale — no `create-review` mapping.
- P6-007 (MINOR): grace-window permanent drop has no detection VP.
- P6-008 (MINOR): ASM-009 (cross-hook marker-store visibility) UNVALIDATED, no go/no-go gate.
- P6-009 (OBSERVATION): O3 rule applied emitter-only — consumer and ordering surfaces not audited.
- P6-010 (OBSERVATION): VP-HOOK-029 PROPOSED while carrying the system's most important safety guarantee.

Report: `.factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass6.md` (350 lines).

**Novelty: HIGH.** P6-001/P6-002 are new exploitable defects in component seams; P6-003/P6-004 are live propagation gaps. Package has not converged; P6-001/P6-002 are convergence-blocking.

**Convergence counter:** 0/3 clean passes. Pass 7 after remediation burst 2.

---

## Burst 5: F2 Pass-6 Remediation COMPLETE — Burst 2 (2026-07-21)

**Steps rotated from STATE.md Current Phase Steps (5-row limit enforced):**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: version-coherence sweep | state-manager | DONE | spec-changelog.md authored; BC frozen versions confirmed; D-DEC-001..012 in architecture-delta |

**Step added to STATE.md Current Phase Steps this burst:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-6 remediation burst 2 | architect / product-owner / formal-verifier | DONE | arch-delta v1.9 (P6-001..009: --label in create-review pattern + hook-side label enforcement D-DEC-012 ADOPTED; STEP 4/5 reorder; D-DEC-013 severity normalization; P6-008 ASM-009 BLOCKING; O3 extended to consumer+ordering+trust-boundary; VP-SKILL-074+SM-36/SM-37 namespace-corrected); BC-3.01.001 v1.18 (STEP 6a anti-fungibility both directions, EC-023, VP-HOOK-029 FINALIZED ref, SM-36/SM-37); BC-3.03.001 v1.15 (STEP 4/5 swap, labeled create-review pattern, Iron Law updated); BC-10.01.001 v1.11 (Inv#11 Option A carve-out, NORMALIZE_SEVERITY per D-DEC-013, VP-SKILL-065 re-scoped PROPOSED); verif-delta v1.9 (VP-HOOK-029 FINALIZED P0, VP-HOOK-024 anti-fungibility, VP-SKILL-073/074 new, 31VPs/31mutants; FV caught VP-SKILL-072+SM-33/34 collisions) |

**Narrative:**

Pass-6 remediation (burst 2) addressed P6-001 (CRITICAL — consumer anti-fungibility: create-review/
comment-review markers accepted for any command without --label check, enabling kill-switch bypass),
P6-002 (CRITICAL — STEP 4/5 ordering: kill switch ran before under-label upgrade, so
autonomy_enabled=false silently discarded under-labeled hard-floor verdicts), P6-003 (MAJOR —
Inv#11/VP-SKILL-065 zero-jr-writes clause contradicted Option A carve-out), P6-004 (MAJOR —
cross-org create binding void with single PRISM-DEMO key; cross-org isolation claim explicitly
downgraded), P6-005 (MAJOR — sensor-native severity encodings unmapped; D-DEC-013 severity
normalization per sensor family added), P6-006 (MINOR — D-DEC-004 review-token binding), P6-007
(MINOR — late-event grace-window drop; VP-SKILL-073 added), P6-008 (MINOR — ASM-009 elevated to
BLOCKING pre-Wave-3 go/no-go), and P6-009 (OBSERVATION — O3 rule extended to consumer, ordering,
and trust-boundary surfaces; D-DEC-012 audit checklist updated).

The formal-verifier independently re-verified the VP/SM namespace and caught two collisions in the
architect's §8.15 proposal: "VP-SKILL-072" for severity normalization (occupied: first-run 24h
lookback, FINALIZED v1.5) → corrected to VP-SKILL-074; "SM-33/SM-34" for consumer anti-fungibility
mutants (occupied: pass-4 sentinels autonomy_enabled-clause-removed + dispatch-order-inverted) →
corrected to SM-36/SM-37.

**Artifacts produced by this burst:**

- `phase-f2-spec-evolution/architecture-delta.md` v1.8 → v1.9: P6-001/P6-004 unified fix (create-review `command_pattern` now requires `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed position; consumer STEP 6a bidirectional exact-type matching EC-023; cross-org isolation claim downgraded for single-PRISM-DEMO config); D-DEC-012 hook-side label enforcement reversal (rejected → ADOPTED, O3 rationale); P6-002 STEP 4/5 reorder (hard-floor under-label upgrade now STEP 4 before STEP 5 kill switch); P6-003 carve-out normative language; P6-005 D-DEC-013 severity normalization (per-sensor-family, unrecognized → CRITICAL + uncertainty_explicit); P6-006 D-DEC-004 review-token binding; P6-007 D-DEC-002 late-event fail-loud detection; P6-008 ASM-009 elevated to BLOCKING pre-Wave-3; P6-009 O3 table extended (consumer + ordering + trust-boundary rows); namespace correction VP-SKILL-074, SM-36/SM-37 appended.
- `phase-0-ingestion/behavioral-contracts/BC-3.01.001.md` v1.17 → v1.18: First consumer change this cycle. STEP 6a anti-fungibility cross-check both directions; EC-023 added; OR-accept removed for create (comment retains OR-accept pending ASM-014); org-binding downgrade noted; 4 new canonical test vectors; VP-HOOK-029 FINALIZED ref; SM-36/SM-37 attribution [namespace-sync per FV].
- `phase-0-ingestion/behavioral-contracts/BC-3.03.001.md` v1.14 → v1.15: STEP 4/5 swap throughout; labeled create-review pattern in 3 locations; Iron Law updated (hook-side label enforcement); ASM-014 note; EC-012 case (d) flipped to upgrade semantics; test vectors updated.
- `phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` v1.10 → v1.11: Inv#11 Option A carve-out (zero REGULAR writes; create-review/comment-review escalation writes for genuine hard-floor verdicts exempt); VP-SKILL-065 re-scoped + re-marked PROPOSED; Inv#10 concession removed; NORMALIZE_SEVERITY named step per D-DEC-013 (Inv#9 field 13 + Stage 1); EC-006/EC-014 disambiguation.
- `phase-f2-spec-evolution/verification-delta.md` v1.8 → v1.9: VP-HOOK-029 FINALIZED (P0) + 3 kill-switch-on under-label vectors; VP-HOOK-024 consumer anti-fungibility vectors; VP-SKILL-065 RE-SCOPED PROPOSED; new VP-SKILL-073 (late-event detection P1) + VP-SKILL-074 (severity normalization P1, namespace-corrected from "VP-SKILL-072"); SM-32-ext/SM-36/SM-37; STEP-renumber stale sweep; VPs 29→31, mutants 28→31, test estimate ~238→~258.

**Version-coherence sweep (Task 1):** verification-delta.md v1.9 snapshot BC-version references updated to final burst-2 versions: BC-3.03.001 v1.14→v1.15, BC-10.01.001 v1.10→v1.11 (6 occurrences: YAML changelog, body intro, §7 Part G header/item-1/item-3, closing paragraph). Zero residual stale refs confirmed.

**Convergence counter:** 0/3 clean passes. Pass 7 is next (adversary fresh context required).

---

### Archived Current Phase Steps Row — 2026-07-21 (pass-7 displacement)

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: adversarial pass 5 | adversary | DONE | 1C/2M/1m/3obs — root cause: disposition-guard trusts LLM ticket_action_type without cross-checking hard_floor_applies(); P5-001 (silent discard) + P5-002 (kill-switch bypass) are under/over-label duals; P5-003 stale §D-DEC-001 schema block; report persisted. |

---

## Burst 6: F2 Pass-7 Remediation COMPLETE — Burst 3 (2026-07-21)

**Steps rotated from STATE.md Current Phase Steps (5-row limit enforced):**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: consistency audit pass-5 | consistency-validator | DONE | PASS-WITH-MINORS (0 blocking) — all prior-pass Critical/Major resolved, marker+verdict schemas uniform, VP namespace clean, sensor-silence direction correct. 3 non-blocking: F-001 arch-delta §5.4 (cosmetic), F-002 6 BCs COMPUTE-AT-COMMIT (F2 state-backup), F-003 VP-SKILL-061 silence wording (this burst). CONSISTENCY CLEAN. |

**Step added to STATE.md Current Phase Steps this burst:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-7 remediation burst 3 | architect / product-owner / formal-verifier | DONE | DENY-THE-WRITE redesign per human D-008 + O4 standing rule. arch-delta v1.10 (STEP-4 deny-the-Write, SM-38/39/40, O4 rule); BC-3.03.001 v1.16 (STEP 4 deny + UNDER-LABEL-DENIED audit, corrective-reason struct); BC-3.01.001 v1.19 (structural_label_check step-6a, EC-024, SM-40); BC-10.01.001 v1.12 (P7-002 6 stale ECs, P7-003 --label Iron Law, P7-006 Cyberint); verif-delta v1.10 (VP-HOOK-029 consumer-boundary re-scope+FINALIZED P0, SM-38/39/40, Cyberint partition); prd-delta v1.9 (non-pinned); SM-ID sync + version-coherence sweep applied. |

**Narrative:**

Pass-7 remediation (burst 3) addressed P7-001..P7-009. Central design reversal: the pass-5/pass-6
STEP-4 marker-upgrade mechanism was RETIRED per human decision (D-008). P7-001 proved the upgrade
unsound — disposition-guard can rewrite the marker but not the loop's future Bash command. For 3 of
4 under-label action types (create/assign/none), the upgraded review marker was structurally
unconsumable by the loop's own non-review jr command, producing a silent drop of hard-floor findings.
DENY-THE-WRITE is the deterministic hook's only lever over FUTURE commands: by denying the current
Write, the loop is forced to re-document with the correct review token before proceeding. O4 standing
rule codified: fail-loud guarantees must be verified at the consumer/Bash boundary, not by
emitter-local artifacts.

P7-002 (CRITICAL): 6 stale locations in BC-10.01.001 (EC-015/016/017/021 + 2 canonical test vectors)
still encoding pre-D-DEC-012 "no marker for hard-floor" semantics corrected to create-review/
comment-review semantics.

P7-005 (MINOR): step-6a raw-substring check replaced with structural_label_check (standalone --label
token immediately preceding REVIEW-REQUIRED/BLIND-SPOT); prevents false-deny on regular creates
whose --summary contains the literal label text.

P7-006 (MINOR): Cyberint explicit conservative default CRITICAL + uncertainty_explicit appended to
VP-SKILL-074 Cyberint partition (pre-ASM-008, 3 vectors).

P7-003 (MAJOR): --label Iron Law added to Stage-8/loop contract (--project FIRST, --label SECOND).

P7-004 (MAJOR): VP-HOOK-029 re-scoped end-to-end to assert consumer-boundary jr authorization/
execution outcome (not emitter-local marker presence); re-FINALIZED P0.

P7-007 (MINOR): brief §3.9 version pins replaced with non-pinned form.

P7-009 (PROCESS-GAP): O4 standing rule codified.

SM-ID sync: placeholders "SM IDs allocated by FV" replaced in BC-3.03.001, BC-3.01.001,
BC-10.01.001 with real IDs SM-38/SM-39/SM-40. "[SM-ID-sync per FV]" appended to changelog entries.

Version-coherence sweep: VP table BC anchor column in verification-delta v1.10 updated to final
versions (BC-3.03.001 v1.16, BC-10.01.001 v1.12, BC-3.01.001 v1.19) for VP-HOOK-025, VP-HOOK-027,
VP-HOOK-028, VP-SKILL-064/065/068/072/073; §5 test-count table row header BC-3.03.001 updated to
v1.16.

**Artifacts produced by this burst:**

- `phase-f2-spec-evolution/architecture-delta.md` v1.9 → v1.10: DENY-THE-WRITE redesign (P7-001/P7-004/P7-009); SM-38/SM-39/SM-40 allocated; O4 standing rule; --label Iron Law Stage-8 (P7-003); Cyberint D-DEC-013 (P7-006).
- `phase-0-ingestion/behavioral-contracts/BC-3.03.001.md` v1.15 → v1.16: STEP 4 deny-the-Write; UNDER-LABEL-DENIED audit; corrective-reason structure (hard_floor_trigger/required_token/label_instruction); UNDER-LABEL-CORRECTED retired; EC-012 under-label rows updated; FAIL-LOUD comment updated; SM-ID sync SM-38/SM-39 [SM-ID-sync per FV].
- `phase-0-ingestion/behavioral-contracts/BC-3.01.001.md` v1.18 → v1.19: structural_label_check step-6a (P7-005); EC-024 false-deny prevention; SM-40 kill target; VP-HOOK-024 v1.19 extension; SM-ID sync SM-40 [SM-ID-sync per FV].
- `phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` v1.11 → v1.12: P7-002 6 stale EC locations; P7-003 --label Iron Law; P7-006 Cyberint CRITICAL default; VP-HOOK-029 citation updated to deny-the-Write semantics; SM-ID sync SM-38/SM-39 [SM-ID-sync per FV].
- `feature/prism-integration-handoff-brief.md`: §3.9 version pins replaced with non-pinned form (P7-007).
- `phase-f2-spec-evolution/verification-delta.md` v1.9 → v1.10: VP-HOOK-029 consumer-boundary re-scope + re-FINALIZED P0 (deny-path vectors, machine-actionable-reason vector, corrected-rewrite happy path, consumer-boundary consumable/unconsumable vectors, kill-switch-irrelevance vector); SM-38/SM-39/SM-40 allocated; VP-HOOK-024 step-6a false-deny vector; VP-SKILL-074 Cyberint partition; SM-32a re-targeted; SM-32-ext kill-vector re-worded; 31→34 mutants; test estimate ~258→~263. Version-coherence sweep applied (9 VP table anchor edits + §5 row header).

**Decision D-008 recorded:** DENY-THE-WRITE approach selected over marker-upgrade; marker-upgrade
approach retired. Made by human on 2026-07-21.

**Convergence counter:** 0/3 clean passes. Pass 8 is next (adversary fresh context required).

---

### Archived Current Phase Steps Row — 2026-07-21 (pass-8 displacement)

The following row was archived from STATE.md when the pass-8 row was added (5-row limit enforced):

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-5 remediation | architect / product-owner / formal-verifier | DONE | arch-delta v1.8 (fail-loud STEP 5, hard_floor_applies() STEP 3 gate, schema v2.1 sync, O3 rule/D-DEC-012, Option A); BC-3.03.001 v1.14 (STEP 3+5 gates, EC-012, TV-SYNC); BC-10.01.001 v1.10 (Inv#10, VP-SKILL-061 sensor-silence fix); verif-delta v1.8 (VP-HOOK-029 re-scoped, SM-32a/32b, §7 Part F, ~238 tests); prd-delta v1.9 (§4/§6 12/15-field); brief §3.9 Option A confirmed 2026-07-21 |

---

## Burst 7: F2 Adversarial Pass 8 Persisted (2026-07-21)

**Step added to STATE.md Current Phase Steps this burst:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: adversarial pass 8 | adversary | DONE | 1C/2M/1m/2obs — decay begun. P8-001 (CRITICAL): STEP 3 correctly-labeled review verdict with null jira_project_key/ticket_id → silent allow-without-marker (last orthogonal silent-discard axis; contradicts D-DEC-012 clause 2 which already mandates deny+error). P8-002 (MAJOR): P7-005 structural_label_check split_on_whitespace not quote-aware — false-denies its own EC-024 example (verified against live hook source). P8-004 (MAJOR): prd-delta VP statuses inverted (VP-HOOK-029/VP-SKILL-065) + §5 versions stale by 2-3. P8-003 (MINOR): EC-023 step-5 defense-in-depth claim factually wrong — anti-fungibility rests solely on step 6a. P8-OBS-1 [process-gap]: superseded propagation ledger sections need forward-link banners. P8-OBS-2: Cyberint 100% mass-escalation pre-ASM-008 needs operator note. 8 confirmed-intact invariants listed for pass-9 accumulation. Report persisted. |

**Narrative:**

adversary (fresh context) ran pass 8 against the full F2 delta package (brief, architecture-delta v1.10,
verification-delta v1.10, prd-delta v1.9, BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12,
and live hook source). Traced the full verdict→marker→command lifecycle with decay-checking focus.

**Findings (1C/2M/1m/2obs):**
- P8-001 (CRITICAL): STEP 3 correctly-labeled review verdict (hard_floor_applies() true, label OK) with
  null jira_project_key or ticket_id → silent allow-without-marker. Last orthogonal silent-discard axis;
  contradicts D-DEC-012 clause 2 (mandates deny+error for any unbindable hard-floor verdict).
- P8-002 (MAJOR): P7-005 structural_label_check uses split_on_whitespace tokenization — not quote-aware.
  False-denies its own EC-024 example (command with --summary containing spaces) verified against live
  hook source (hooks/disposition-guard.sh:45).
- P8-004 (MAJOR): prd-delta §9 VP statuses inverted (VP-HOOK-029 marked PROPOSED, VP-SKILL-065 marked
  FINALIZED — should be reversed per verif-delta v1.10); §5 version table stale by 2-3 BC versions.
- P8-003 (MINOR): EC-023 step-5 defense-in-depth claim factually wrong — anti-fungibility rests solely
  on step 6a; step 5 does not contribute to anti-fungibility.
- P8-OBS-1 (OBSERVATION / process-gap): superseded propagation ledger sections in architecture-delta
  need forward-link banners pointing to successor decisions.
- P8-OBS-2 (OBSERVATION): Cyberint 100% mass-escalation pre-ASM-008 needs operator visibility note.

**8 confirmed-intact invariants** listed in report for pass-9 accumulation (DENY-THE-WRITE semantics,
marker-consumer seam, hard-floor coverage, severity normalization, anti-fungibility, VP-HOOK-029
consumer boundary, loop --label Iron Law, SM-38/39/40 allocation).

Report: `.factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass8.md` (135 lines).

**Novelty: MEDIUM-HIGH.** P8-001 is a fresh orthogonal silent-discard axis on the CORRECTLY-LABELED
path (all prior passes focused on under-label/over-label; this is the missing-binding sub-case of the
happy path). P8-002 is a real implementation-vs-spec gap in the most recent fix (P7-005). Decay begun
(1C/2M vs 2C/3M in passes 6-7). Package has NOT converged; P8-001/P8-002 are blocking.

**Convergence counter:** 0/3 clean passes. Remediation burst 4 → pass 9 is next.

---

### Archived Current Phase Steps Row — 2026-07-21 (burst-4 displacement)

The following row was archived from STATE.md when the burst-4 row was added (5-row limit enforced):

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: adversarial pass 6 | adversary | DONE | 2C/3M/3m/2obs — trust boundary re-derived end-to-end: P6-001 consumer accepts review tokens for regular commands (kill-switch bypass, CRITICAL); P6-002 STEP 4 kill switch precedes STEP 5 upgrade → silent discard of under-labeled hard-floor verdicts when autonomy=false (CRITICAL); P6-003 Inv#11/VP-SKILL-065 contradict Option A; P6-004 single demo project key voids cross-org create binding; P6-005 sensor-severity→enum normalization unspecified; P6-009 [process-gap] O3 rule applied emitter-only. Report persisted. |

---

## Burst 8: F2 Pass-8 Remediation COMPLETE — Burst 4 (2026-07-21)

**Steps rotated from STATE.md Current Phase Steps (5-row limit enforced):**

See "Archived Current Phase Steps Row — 2026-07-21 (burst-4 displacement)" above.

**Step added to STATE.md Current Phase Steps this burst:**

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-8 remediation burst 4 | architect / product-owner / formal-verifier | DONE | arch-delta v1.11 (P8-001 STEP-3 unbindable deny; P8-002 quote-aware tokenizer; P8-003 EC-023 step-5; §8.18/§8.19 propagation); BC-3.03.001 v1.17 (unbindable-deny branches + SM-41); BC-3.01.001 v1.20 (quote-aware tokenizer + SM-42); BC-10.01.001 v1.13 (VP-HOOK-029 re-FINALIZED P0 + loop re-doc P8-001); BC-8.02.001 v1.2 (Cyberint operator note); verif-delta v1.11 (SM-41/SM-42 + unbindable vectors + EC-023 correction); prd-delta v1.10 (VP roster + §5 versions) |

**Narrative:**

Pass-8 remediation (burst 4) addressed P8-001 (CRITICAL — STEP 3 null jira_project_key/ticket_id
silent allow-without-marker), P8-002 (MAJOR — split_on_whitespace not quote-aware), P8-003 (MINOR —
EC-023 step-5 defense-in-depth claim), and P8-004 (MAJOR — prd-delta VP statuses inverted + §5
versions stale). OBS banners and operator note also applied.

P8-001 fix: BC-3.03.001 v1.17 adds explicit unbindable-deny branches in STEP 3 for null
jira_project_key (create-review verdict) and null ticket_id (comment-review verdict). SM-41 allocated
as the kill-target mutant reverting STEP-3 to emit-allow-without-marker (VP-HOOK-029 context).

P8-002 fix: BC-3.01.001 v1.20 upgrades structural_label_check from split_on_whitespace to a
UNQUOTED/IN_SINGLE/IN_DOUBLE state-machine tokenizer that correctly handles quoted --summary values
containing --label text. SM-42 allocated as the kill-target mutant reverting to non-quote-aware
split_on_whitespace (VP-HOOK-024/EC-024 context).

P8-003 fix: EC-023 step-5 defense-in-depth claim corrected — anti-fungibility rests solely on step 6a;
step 5 does not contribute. BC-3.01.001 v1.20.

P8-004 fix: prd-delta v1.10 VP roster statuses corrected (VP-HOOK-029 FINALIZED P0, VP-SKILL-065
PROPOSED) + §5 BC version table updated to post-burst versions.

SM-ID sync: SM-41 and SM-42 placeholders "SM ID allocated by FV" replaced in BC-3.03.001,
BC-3.01.001, BC-10.01.001. "[SM-ID-sync per FV]" appended to modified[] changelog entries.

Version-coherence sweep: verification-delta.md v1.11 live-BC baseline updated from v1.19/v1.16/v1.12
to BC-3.01.001 v1.20 / BC-3.03.001 v1.17 / BC-10.01.001 v1.13 in §7 Part I body and closing
snapshot. Historical changelog entries (frontmatter v1.11, pass-7 record) intentionally not updated
per append-only convention.

**Artifacts produced by this burst:**

- `phase-f2-spec-evolution/architecture-delta.md` v1.10 → v1.11: P8-001 STEP-3 unbindable deny; P8-002 quote-aware tokenizer; P8-003 EC-023 step-5 correction; §8.18/§8.19 propagation; OBS banners.
- `phase-0-ingestion/behavioral-contracts/BC-3.03.001.md` v1.16 → v1.17: unbindable-deny branches STEP 3; SM-41 allocated; SM-ID sync.
- `phase-0-ingestion/behavioral-contracts/BC-3.01.001.md` v1.19 → v1.20: quote-aware tokenizer; SM-42 allocated; SM-ID sync.
- `phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` v1.12 → v1.13: VP-HOOK-029 re-FINALIZED P0 + loop re-doc P8-001; SM-ID sync.
- `phase-0-ingestion/behavioral-contracts/BC-8.02.001.md` v1.1 → v1.2: Cyberint operator note (P8-OBS-2).
- `phase-f2-spec-evolution/verification-delta.md` v1.10 → v1.11: SM-41/SM-42 allocated; unbindable vectors; EC-023 correction; version-coherence sweep applied.
- `phase-f2-spec-evolution/prd-delta.md` v1.9 → v1.10: VP roster statuses corrected; §5 BC versions updated.

**Convergence counter:** 0/3 clean passes. Pass 9 is next (adversary fresh context required).

---

## Archived Step Row — rotated from STATE.md Current Phase Steps (2026-07-21)

The following rows were displaced from the 5-row Current Phase Steps limit (burst-4 and burst-5 additions):

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-6 remediation burst 2 | architect / product-owner / formal-verifier | DONE | arch-delta v1.9 (P6-001..009: --label in create-review pattern + hook-side label enforcement D-DEC-012 ADOPTED; STEP 4/5 reorder; D-DEC-013 severity normalization; P6-008 ASM-009 BLOCKING; O3 extended to consumer+ordering+trust-boundary; VP-SKILL-074+SM-36/SM-37 namespace-corrected); BC-3.01.001 v1.18 (STEP 6a anti-fungibility both directions, EC-023, VP-HOOK-029 FINALIZED ref, SM-36/SM-37); BC-3.03.001 v1.15 (STEP 4/5 swap, labeled create-review pattern, Iron Law updated); BC-10.01.001 v1.11 (Inv#11 Option A carve-out, NORMALIZE_SEVERITY per D-DEC-013, VP-SKILL-065 re-scoped PROPOSED); verif-delta v1.9 (VP-HOOK-029 FINALIZED P0, VP-HOOK-024 anti-fungibility, VP-SKILL-073/074 new, 31VPs/31mutants; FV caught VP-SKILL-072+SM-33/34 collisions) |
| F2: adversarial pass 7 | adversary | DONE | 2C/3M/3m/2obs — root cause: marker↔command seam. P7-001 (CRITICAL): STEP 4 under-label upgrade writes a marker the loop's actual jr command cannot consume — silent drop persists for create/assign/none under-label paths. P7-002 (CRITICAL): 6 locations in BC-10.01.001 (EC-015/016/017/021 + 2 test vectors) still encode pre-D-DEC-012 'no marker for hard floor' semantics. P7-003: --label Iron Law missing from loop contract. P7-004: VP-HOOK-029 emitter-only, cannot detect unconsumable-marker drop. P7-005 substring false-deny; P7-006 Cyberint mapping; P7-007 brief stale versions. P7-009 [process-gap]: fail-loud claims proven at emitter, guarantee lives at consumer — need end-to-end verification axis. Report persisted. |

---

## Burst 5: F2 Pass-9 Remediation (2026-07-22)

**Steps archived from STATE.md Current Phase Steps:**

(see row above — F2: adversarial pass 7 rotated out of the 5-row limit by this burst's addition)

**Narrative:**

P9-001 fix: BC-3.01.001 v1.21 — structural_label_check step-6a extended to cover backslash-escaped
quotes (\") and the --label=VALUE form (no space after --label). Both forms are valid bash token
boundaries and yield the same tag-key string; the IN_DOUBLE state was reverting to UNQUOTED on
backslash, causing the escape to be treated as a split point. SM-43 allocated as the kill-target
mutant reverting the IN_DOUBLE-backslash-escape state (direction-A). Architecture-delta v1.12
codifies O5 standing rule: any hook implementation re-implementing shell tokenization MUST carry
a differential-vs-bash vector partition (enumerating known divergence cases vs bash) in the
specification for that component. BC-10.01.001 v1.14 absorbs P9-001 coverage in Inv#15 and
propagates O5 obligation.

P9-002 fix: asm-004-validation.md updated with SUPERSEDED and CORRECTION banners over the two
paragraphs recommending --dangerously-skip-permissions (violates D-DEC-003) and --bare
(hook-disabling, violates D-DEC-010). Forward-links point to D-DEC-003/010 and the current
recommended activation pattern.

P9-003/004 fix (bookkeeping): prd-delta v1.11 corrects BC-10.01.001 double-count (11→10 BCs) and
BC-6.01.001 version bump. verif-delta v1.12 corrects VP split count label (6/25 not 8/23) and
FINALIZED/ACCEPTED status parity.

P9-005 fix: architecture-delta v1.12 §8.11 D-DEC-005 carve-out added — prism_sensor_health queries
are exempt from the org_slug isolation invariant because they are cross-org health-check reads, not
tenant-scoped queries. BC-10.01.001 v1.14 Inv#11 updated to reflect the carve-out.
BC-6.01.001 v1.6 adds matching carve-out annotation.

P9-007 fix: architecture-delta v1.12 comment-review fallback guidance updated — dedup-before-create-
review gate added to the hint text to prevent the fallback path from creating a duplicate review
ticket when the primary path already created one.

P9-008 fix: architecture-delta v1.12 §8.20 + BC-10.01.001 v1.14 — jira_project_key promoted to HARD
Stage-0 precondition; re-documentation cap (HARD-FLOOR-LIVELOCK-ABORT) added to prevent infinite
loop when the precondition is absent.

P9-009 fix: O5 standing rule formally codified in architecture-delta v1.12 §8.21 and propagated to
verif-delta v1.12.

SM-ID sync: SM-43 placeholder "SM ID allocated by FV" replaced in BC-3.01.001 (4 occurrences:
frontmatter modified[], revision history, pseudocode comment, VP table test-surface column).
"[SM-ID-sync per FV]" appended to modified[] v1.21 changelog entry.

Version-coherence sweep: verification-delta.md v1.12 VP table BC anchor column updated from frozen
pass-7 values to final post-burst versions: BC-3.01.001 v1.21, BC-8.02.001 v1.3, BC-10.01.001
v1.14, BC-6.01.001 v1.6, BC-3.03.001 v1.17 (unchanged this burst). §7 Part J body and closing
snapshot updated. Historical changelog entries (frontmatter) intentionally not updated per
append-only convention.

**Artifacts produced by this burst:**

- `phase-f2-spec-evolution/architecture-delta.md` v1.11 → v1.12: O5 rule; D-DEC-005 sensor-health carve-out §8.11; dedup-before-create-review gate §8.20; jira_project_key HARD Stage-0 + HARD-FLOOR-LIVELOCK-ABORT §8.20; O5 codified §8.21; P9-007/008 guidance.
- `phase-0-ingestion/behavioral-contracts/BC-3.01.001.md` v1.20 → v1.21: IN_DOUBLE backslash-escape revert mutant (SM-43); --label= form coverage; O5 differential-vs-bash partition; SM-ID sync all 4 occurrences.
- `phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` v1.13 → v1.14: Inv#11 D-DEC-005 sensor-health carve-out; Inv#15 P9-001 tokenizer coverage; jira_project_key Stage-0 precondition; re-doc cap; O5 obligation.
- `phase-0-ingestion/behavioral-contracts/BC-6.01.001.md` v1.5 → v1.6: D-DEC-005 sensor-health carve-out annotation.
- `phase-0-ingestion/behavioral-contracts/BC-8.02.001.md` v1.2 → v1.3: version bump for P9-003 prd-delta correction.
- `phase-f2-spec-evolution/verification-delta.md` v1.11 → v1.12: VP split count corrected (6/25); FINALIZED/ACCEPTED status parity; O5 obligation; version-coherence sweep applied (BC anchor column final post-burst values).
- `phase-f2-spec-evolution/prd-delta.md` v1.10 → v1.11: BC-10.01.001 double-count corrected (11→10); BC-6.01.001 v1.6 version bump.
- `phase-0-ingestion/asm-004-validation.md`: SUPERSEDED + CORRECTION banners over --dangerously-skip-permissions and --bare paragraphs.

**Convergence counter:** 0/3 clean passes. Pass 10 is next (adversary fresh context required; carry
12-item confirmed-invariants list from pass 9).

---

## Burst 6: F2 Pass-10 Remediation (2026-07-22)

**Root findings remediated:** P10-001 (CRITICAL), P10-002 (MAJOR), P10-003 (MAJOR), P10-004 (MINOR), P10-008 (MINOR), P10-009 (MINOR). D-009 and D-010 recorded. O6 standing rule codified.

**P10-001 fix (CRITICAL — hook-side severity re-normalization):** disposition-guard STEP 1a added — hook independently re-runs NORMALIZE_SEVERITY(verdict.native_severity, verdict.sensor_family) using the deterministic D-DEC-013 table; if recomputed_severity != verdict.severity → write SEVERITY-MISMATCH audit entry + emit deny. O6 standing rule: inputs to a hook-computed invariant must be hook-recomputable or hook-cross-validated against deterministic ground truth (not LLM-supplied). ICD-203 verdict schema extended from 15 to 17 mandatory fields: native_severity (field 16, raw sensor-provided severity string) and sensor_family (field 17, enum crowdstrike|armis|claroty|cyberint) added as required verdict fields; written at Stage 1 INGEST. VP-HOOK-025 updated to 17-field; VP-HOOK-030 newly allocated (STEP 1a SEVERITY-MISMATCH; SM-44 kill target: revert STEP 1a re-normalization). D-009 records the trust-basis fix decision.

**P10-002 fix (MAJOR — operator-boundary cron-exit-nonzero signal):** BC-10.01.001 PC#7 Gate 2 added to the cron wrapper spec: after JSON envelope check, the wrapper independently greps markers/audit.log for fail-loud codes (HARD-FLOOR-LIVELOCK-ABORT|HARD-FLOOR-UNBINDABLE|UNDER-LABEL-DENIED|SEVERITY-MISMATCH|MARKER-WRITE-FAILED); exits 1 even when is_error=false and permission_denials==0. ASM-015 BLOCKING gate documented: empirical validation needed that permissionDecision:deny populates .permission_denials[] in --allowedTools JSON envelope before Gate 1 check on permission_denials is reliable. VP-SKILL-075 allocated (FINALIZED P0, operator-boundary cron-exit-nonzero signal).

**P10-003 fix (MAJOR — WRITE_MARKER review-path fail-closed):** WRITE_MARKER pseudocode updated to branch on is_review_path: create-review/comment-review marker-write failure → MARKER-WRITE-FAILED audit entry + emit deny (mirrors HARD-FLOOR-UNBINDABLE); regular marker paths retain emit-allow-without-marker (require-review denies the jr call — human gate preserved). marker schema disposition.severity updated to use recomputed_severity (O6 consistency). SM-45 allocated (revert WRITE_MARKER review-path to allow-without-marker, paired with VP-HOOK-029 extension).

**P10-004 fix (MINOR):** comment-review null-ticket_id branch fallback_hint updated to full P9-007 dedup instruction (dedup-before-create-review gate; previously only the shorter form was present).

**P10-008 fix (MINOR):** Explicit ASM-014-pending residual note added in BC-3.03.001 STEP 3 comment-review section: the comment-review kill-switch exemption is currently broader than "review ticket only"; restriction to review-labeled tickets is deferred until ASM-014 resolves. D-010 records the per-org jira_project_key choice.

**P10-009 fix (MINOR):** BC-6.01.003 v1.2 — per-org jira_project_key in [[orgs]] entries; Postcondition #1 updated; Invariant #6 added (per-org lookup order); EC-009 added.

**SM/VP ID sync:** BC-3.03.001 line 70 placeholder "SM/VP ID for 17-field extension allocated by FV" → VP-HOOK-030 (STEP 1a SEVERITY-MISMATCH) + SM-44. BC-3.03.001 VP table VP-HOOK-025 row placeholder "SM/VP ID allocated by FV" → SM-44 + VP-HOOK-030 cross-ref. BC-10.01.001 PC#7 Gate 2 → VP-SKILL-075 citation added; VP table new row VP-SKILL-075; VP Anchors footer updated.

**Decisions recorded:** D-009 (P10-001 hard-floor trust-basis fix: 17-field verdict schema + SEVERITY-MISMATCH deny + ASM-008-DEFERRED residual; human, F2, 2026-07-22). D-010 (P10-009 per-org jira_project_key choice: lookup per-org first, fall back to global; architect, F2, 2026-07-22).

**Artifacts produced by this burst:**

- `phase-0-ingestion/behavioral-contracts/BC-3.03.001.md` v1.17 → v1.18 (P10-001: 17-field schema + STEP 1a SEVERITY-MISMATCH + SM-44/VP-HOOK-030 ID sync; P10-003: WRITE_MARKER review-path fail-closed + SM-45; P10-004: fallback_hint dedup; P10-008: ASM-014 residual note; 3 new canonical test vectors)
- `phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` v1.14 → v1.15 (P10-001: Inv#9 17-field + fields 16/17 at Stage 1 INGEST; Inv#10 trust-basis correction hook re-derives severity; PC#7 Gate 2 audit.log grep + ASM-015 BLOCKING gate; VP-SKILL-075 added throughout; VP-HOOK-025 updated to 17-field)
- `phase-0-ingestion/behavioral-contracts/BC-6.01.003.md` v1.1 → v1.2 (P10-009: per-org jira_project_key; Postcondition #1; Invariant #6; EC-009)
- `phase-f2-spec-evolution/verification-delta.md` v1.12 → v1.13 (VP-HOOK-030 NEW FINALIZED P0; VP-SKILL-075 NEW FINALIZED P0; SM-44/SM-45 allocated; version-coherence sweep: live-BC baseline updated to BC-3.03.001 v1.18 / BC-10.01.001 v1.15 / BC-6.01.003 v1.2)
- `phase-f2-spec-evolution/prd-delta.md` v1.11 → v1.12 (17-field schema catch-up; BC version table updated)
- `phase-f2-spec-evolution/architecture-delta.md` v1.12 → v1.13 (O6 standing rule codified; STEP 1a SEVERITY-MISMATCH; Gate 2 cron wrapper; D-DEC-013 NORMALIZE_SEVERITY context; per-org jira_project_key lookup order)
- `phase-f2-spec-evolution/dtu-assessment.md` v1.0 → v1.1 (native_severity/sensor_family fields added to prism-demo-server clone requirements)

**Convergence counter:** 0/3 clean passes. Pass-10 REMEDIATED. Pass 11 is next (carry confirmed-invariants list including VP-HOOK-030/STEP-1a; mark ASM-008/ASM-015 as KNOWN-DEFERRED).

---

## Archived from STATE.md Current Phase Steps (rotated at pass-10 entry and burst-6 entry)

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-7 remediation burst 3 | architect / product-owner / formal-verifier | DONE | DENY-THE-WRITE redesign per human D-008 + O4 standing rule. arch-delta v1.10 (STEP-4 deny-the-Write, SM-38/39/40, O4 rule); BC-3.03.001 v1.16 (STEP 4 deny + UNDER-LABEL-DENIED audit, corrective-reason struct); BC-3.01.001 v1.19 (structural_label_check step-6a, EC-024, SM-40); BC-10.01.001 v1.12 (P7-002 6 stale ECs, P7-003 --label Iron Law, P7-006 Cyberint); verif-delta v1.10 (VP-HOOK-029 consumer-boundary re-scope+FINALIZED P0, SM-38/39/40, Cyberint partition); prd-delta v1.9 (non-pinned); SM-ID sync + version-coherence sweep applied. |
| F2: adversarial pass 8 | adversary | DONE | 1C/2M/1m/2obs — decay begun. P8-001 (CRITICAL): STEP 3 correctly-labeled review verdict with null jira_project_key/ticket_id → silent allow-without-marker (last orthogonal silent-discard axis; contradicts D-DEC-012 clause 2 which already mandates deny+error). P8-002 (MAJOR): P7-005 structural_label_check split_on_whitespace not quote-aware — false-denies its own EC-024 example (verified against live hook source). P8-004 (MAJOR): prd-delta VP statuses inverted (VP-HOOK-029/VP-SKILL-065) + §5 versions stale by 2-3. P8-003 (MINOR): EC-023 step-5 defense-in-depth claim factually wrong — anti-fungibility rests solely on step 6a. P8-OBS-1 [process-gap]: superseded propagation ledger sections need forward-link banners. P8-OBS-2: Cyberint 100% mass-escalation pre-ASM-008 needs operator note. 8 confirmed-intact invariants listed for pass-9 accumulation. Report persisted. |

---

## Archived from STATE.md Current Phase Steps (rotated at pass-11 entry)

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-8 remediation burst 4 | architect / product-owner / formal-verifier | DONE | arch-delta v1.11 (P8-001 STEP-3 unbindable deny; P8-002 quote-aware tokenizer; P8-003 EC-023 step-5; §8.18/§8.19 propagation); BC-3.03.001 v1.17 (unbindable-deny branches + SM-41); BC-3.01.001 v1.20 (quote-aware tokenizer + SM-42); BC-10.01.001 v1.13 (VP-HOOK-029 re-FINALIZED P0 + loop re-doc P8-001); BC-8.02.001 v1.2 (Cyberint operator note); verif-delta v1.11 (SM-41/SM-42 + unbindable vectors + EC-023 correction); prd-delta v1.10 (VP roster + §5 versions) |

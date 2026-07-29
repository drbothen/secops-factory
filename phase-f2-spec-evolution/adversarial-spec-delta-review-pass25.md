# Adversarial Review — Pass 25

**Pass:** 25
**Date:** 2026-07-29
**Reviewer:** adversary (fresh context)
**Perimeter:** architecture-delta v1.26, verification-delta v1.26, prd-delta v1.24, dtu-assessment v1.5, prism-integration-handoff-brief, spec-changelog (repo-root); BC-3.01.001 v1.25, BC-3.03.001 v1.33, BC-4.02.001 v1.17, BC-4.05.001 v1.4, BC-5.01.001 v1.12, BC-6.01.001 v1.8, BC-6.01.003 v1.7, BC-6.01.004 v1.1, BC-8.02.001 v1.4, BC-9.01.001 v1.2, BC-10.01.001 v1.27.

## Methodology

Fresh-context re-derivation of the emitter control flow (STEP 0→1→1a→2→3→3b→4→4b→5→6, EMIT_LINK_MARKER both call sites, WRITE_MARKER, and the reordered markdown path) directly from BC-3.03.001 pseudocode, cross-checked against canonical test vectors, the D-DEC-008 generation table, and the consumer contract (BC-3.01.001). Applied the reachability-of-guarantee, new-mechanism-abuse, test-vector-vs-pseudocode-coherence, and CLI-surface axes. Applied the Partial-Fix Regression Discipline axis: for each burst-19/20/21 fix I checked whether it propagated to sibling artifacts (consumer BCs, VP table rows, cited mutants). Did not read prior review passes, STATE.md, cycles, or consistency-audit files.

Root cause of the two blocking findings: the **P22-001 markdown-path reorder (burst 19)** was propagated to BC-3.03.001 prose + canonical vectors + verification-delta VP-HOOK-031, but was **not** propagated to the two consumer BCs nor to the VP-HOOK-031 row inside BC-3.03.001 itself.

---

## Critical Findings

None. (See P25-001 — I rate the strongest finding MAJOR because I cannot fully exclude that the human-save behavior change was intended; it requires human adjudication.)

---

## Important Findings

### P25-001 (MAJOR) — Post-P22-001 emitter DENIES human investigation saves that BC-5.01.001 Inv#7 / BC-4.02.001 PC#4 mandate "MUST NOT be denied"

**Confidence:** HIGH (contradiction is certain; behavioral-regression interpretation is high-confidence, intent adjudication pending)

**Artifacts:**
- Emitter (authoritative): `BC-3.03.001.md:1004-1009` (markdown GATE 1/GATE 2), canonical vectors `:1135` (Indeterminate + autonomy_enabled absent → **MARKDOWN-HARD-FLOOR deny**) and `:1140` (TP + autonomy_enabled absent → MARKDOWN_REVIEW_PATH review marker).
- Consumer contract: `BC-5.01.001.md:108` (Invariant #7) and `BC-4.02.001.md:66` (PC#4).
- Provenance: spec-changelog `:64` (P22-001, burst 19).

**Defect.** Under P22-001 the markdown path runs GATE 1/GATE 2 hard-floor checks **first** and `autonomy_enabled` is **no longer a gate at all**. So a Write of `investigation-*.md` whose Disposition section is `Indeterminate`, OR whose `attack_techniques` section contains T1003/T1068/T1021/T1041, OR whose sensor health is degraded/silent, is **denied** (`MARKDOWN-HARD-FLOOR`) regardless of who is writing. The disposition-guard PreToolUse hook fires on *all* Writes to `investigation-*.md`; there is no human-vs-loop discriminator left after P22-001 removed the `autonomy_enabled` gate.

But BC-5.01.001 Invariant #7 (`:108`, frozen at `v1.11-...gate1-first-human-path`, per frontmatter `modified[]`) still asserts the pre-P22-001 contract verbatim:
> "The investigation Write **always succeeds** for **ALL dispositions** (FP, TP, BTP, Indeterminate, or any other)… **MUST NOT be denied:** An analyst saving ANY compliant 12-field investigation — including Indeterminate disposition, any technique flagged or otherwise, any sensor state — MUST NOT have their Write denied on the human path."

BC-4.02.001 PC#4 (`:66`) carries the identical "GATE-1-FIRST HUMAN-PATH … always succeeds for ALL dispositions … There is no 'Indeterminate save denied' on the human path" text. Both directly contradict the current emitter.

**Concrete failure scenario.** An analyst completes an investigation of a credential-dumping alert. `attack_techniques` legitimately lists **T1003**. Stage 7 of investigate-event (BC-5.01.001) writes the completed 12-field `investigation-ALERT-001.md`. disposition-guard dispatches to the markdown path → GATE 1/GATE 2 `attack_techniques_contains_forbidden(["T1003",…])` = TRUE → **`permissionDecision: deny` (MARKDOWN-HARD-FLOOR)**. The analyst cannot save their completed investigation. T1003/T1068/T1021/T1041 (cred dumping, privesc, lateral movement, exfil) are among the most common techniques in real SOC work, so this blocks the investigate-event skill for its most important alert classes. The same happens for any legitimate `Indeterminate` disposition (a valid analytical outcome per BC-5.01.001 EC-005) and any degraded/silent-sensor investigation. Pre-P22-001 the human path hit the Gate-1 kill switch (autonomy_enabled absent) → allow-without-marker → save always succeeded; the hard floor governed only the *autonomous jr action*, never the human's documentation. P22-001's changelog entry (`:64`) describes only the FP-vs-non-FP routing consequence and does **not** flag this human-save deny consequence — strong evidence the regression was an unintended side effect.

Secondary facet (same root cause): both BCs also state non-FP human saves go allow-without-marker with the subsequent `jr issue comment` falling to human permission-approval; but post-P22-001 (vector `:1140`) a non-FP human save now yields a **comment-review/create-review review marker** regardless of autonomy_enabled. The consumer-side expectation of the follow-on `jr issue comment` behavior is therefore also wrong.

**Remediation direction.** Resolve the contradiction in one direction and propagate:
- If human saves must still never be denied (the pre-P22-001 intent, and what both consumer BCs still require): re-introduce a human-path guard so the GATE 1/GATE 2 **deny** does not fire on human/autonomy-absent Writes, while preserving P22-001's disposition-routing-first for the *review-routing* branch. Then re-verify BC-5.01.001 Inv#7 / BC-4.02.001 PC#4 stay valid.
- If P22-001 intentionally changed human-save semantics: rewrite BC-5.01.001 Inv#7 and BC-4.02.001 PC#4 to state that Indeterminate/forbidden-technique/degraded-sensor human saves are now denied, and redesign the investigate-event Stage-7 workflow accordingly (an analyst must have *some* way to record an Indeterminate finding). This is an architect/human adjudication (intent-adjudication rule).

---

### P25-002 (MEDIUM, [process-gap]) — VP-HOOK-031 verification row in BC-3.03.001 still encodes the pre-P22-001 kill-switch routing and cites RETIRED mutant SM-50; omits SM-73

**Confidence:** HIGH

**Artifacts:** `BC-3.03.001.md:1167` (Verification Properties table, VP-HOOK-031 row); contrast with the *same file's* updated prose at `BC-3.03.001.md:1087` (header "P22-001 SCOPE UPDATE — disposition-routing-first"). SM-50 retirement: spec-changelog `:68` ("SM-50 RETIRED-in-place (inverted into SM-73)") and `:69` ("+SM-73 [markdown-gate1-kill-switch-restored]").

**Defect.** The VP-HOOK-031 table row at `:1167` (header stops at "SCOPE UPDATE COMPLETE v1.21 — P13-001"; no P22-001 mention) still describes:
- "**Gate 1** (P12-002 / P13-003): `autonomy_enabled` absent/non-bool-true/embedded-in-code-fence → **allow-without-marker**"
- route rule "(3) **kill-switch path**: autonomy_enabled absent/false → allow-without-marker"
- "**SM-50 kill target**: remove Gate 1 kill-switch (vector 3)"

All three describe the exact Gate-1-first kill-switch that P22-001 eliminated — the same behavior the file's own canonical vectors at `:1135`/`:1140` explicitly label "the P22-001 defect." SM-50 was **retired** in burst 19 (inverted into SM-73, "markdown-gate1-kill-switch-restored"); the row cites SM-50 as a live kill target and never mentions SM-73. A test-writer building from this VP row would assert the defective pre-P22-001 routing (e.g., "TP + autonomy absent → allow-without-marker") as correct and would invert the SM-73 kill vector. This is an internal contradiction within BC-3.03.001 (row `:1167` vs prose `:1087` vs vectors `:1135`/`:1140`) and a mis-anchor to a retired mutant. Process-gap tagged because it is the same non-propagation pattern as P25-001 across a third artifact (partial-fix regression: prose swept, verification row not swept).

**Remediation direction.** Rewrite the VP-HOOK-031 row `:1167` to the P22-001 disposition-routing-first scope (mirror `:1087`); replace the SM-50 citation with SM-73 ("markdown-gate1-kill-switch-restored"); update route rule (3) to reflect that autonomy_enabled is no longer a routing gate.

**Pattern flag:** P25-001 + P25-002 are one systematic P22-001-propagation gap spanning **three** artifacts (BC-5.01.001 Inv#7, BC-4.02.001 PC#4, BC-3.03.001 VP-HOOK-031 row). Per the Partial-Fix Regression Discipline axis (blast radius ≥ 2 → HIGH), the *aggregate* propagation failure is HIGH severity even though I score the individual doc-drift row MEDIUM.

---

## Observations

- **P25-003 (OBSERVATION):** BC-5.01.001 Inv#7 (`:108`, `:116`) and BC-4.02.001 PC#4 (`:66`, `:74`) cite "BC-3.03.001 **v1.24** Invariant #4" and "VP-HOOK-031 … per verification-delta.md **v1.18**." Current BC-3.03.001 is v1.33 and verification-delta is v1.26. Stale cross-version cites; subsumed by the P25-001 rewrite but worth sweeping at the same time.

- **P25-004 (OBSERVATION):** EMIT_LINK_MARKER is defined as a `FUNCTION` at `BC-3.03.001.md:699` (textually *after* its STEP 3b call site at `:465`). The P24-001 "bash-faithful" note (`:686-693`) correctly addresses global variable scoping and direct WRITE_MARKER invocation, but the pseudocode still relies on GOTO labels and forward function references that are not literal bash. Recommend a one-line implementer note that all functions are defined before first call (top-of-script), so the STEP-3b forward reference is not mistaken for a runtime-ordering constraint. Non-blocking (acknowledged pseudocode).

---

## Surfaces Re-Derived and Found INTACT

- **Emitter STEP 3b hard-floor link carve-out** (`:425-466`): null-binding HARD-FLOOR-UNBINDABLE guards for KEY1 (`:432`) and KEY2 (`:446`) fire before `EMIT_LINK_MARKER true` (`:465`); STEP 4/STEP 5 correctly bypassed. Coherent.
- **EMIT_LINK_MARKER both call sites** (`:465` positional `true`, `:630` positional `false`): global variable plumbing (`is_link_hard_floor` set at `:812`, read at `:834-835`) and direct `WRITE_MARKER` invocation (`:813`) match the P24-001 settled model. is_review_path extension for hard-floor link (`:835`) correctly makes marker-write failure fail-closed (MARKER-WRITE-FAILED `:859-869`) while REGULAR link retains allow-without-marker (`:870-872`) — P10-003 asymmetry preserved; vectors `:1152` and `:1155` corroborate.
- **O7 site 10 (P24-002)** (`:757-777`): `resolved_project_key` emit-time charset re-check → LINK-PROJECT-KEY-CHARSET-DENY, fail-closed before regex construction, with regex_escape defense-in-depth; reachable from both link entry paths; vector `:1156` corroborates. 9 active O7 sites reconciled (`:961`).
- **Org-binding (D-028/P23-005)** (`:742-801`): read_org_project_key CONFIG-side (O6-safe), null → LINK-PROJECT-BINDING-DENY, KEY1/KEY2 prefix-bound to `^<resolved_key>-[0-9]+$` on both hard-floor and REGULAR paths; vector `:1154` corroborates.
- **STEP 4b close-disposition gate (D-025)** (`:519-530`): fires before STEP 5 kill switch for ALL autonomy_enabled values; SM-69 regression vector `:1149` (TP+close+autonomy=false → CLOSE-DISPOSITION-DENY) correct. STEP 6 close branch (`:633-683`) correctly demoted to defense-in-depth. TP never auto-closed (D-023) holds.
- **Compound create+link (D-024/D-022)** BC-4.02.001 PC#7b/PC#7d (`:84`, `:86`): create+link two-Write model, Iron Law (link verdict not written until create returns NEW_KEY), anti-fungibility. No residual comment+link language. Consistent with the settled D-024 decision.
- **Consumer two-tier link/close** BC-3.01.001 (`:115-116`, `:419-422`): `["link"]`/`["close"]` anti-fungibility both directions via anchored command_pattern; no key-comparison gap.
- **CLI-surface:** all cited verbs (`jr issue link`, `jr issue move`, `jr issue view --output json` for D-026 read at BC-3.01.001 `:313`/`:329`, `jr issue list --jql` dedup) are within the verified verb set. No reference to nonexistent `jr issue search`/`transition`/`reopen` found on live paths.
- **Charset/metacharacter injection vectors** (`:1141-1144`): TICKET-ID / PROJECT-KEY / LINK-TARGET-CHARSET-DENY all deny before interpolation; consistent with O7 standing rule.

---

## Novelty Assessment

Novelty: **MEDIUM–HIGH.** The two blocking findings are genuinely new gaps rooted in a burst-19 fix (P22-001) whose blast radius into the two consumer BCs and the in-file VP row was never swept — precisely the class fresh context surfaces because prior passes anchored on the verdict/link/close mechanisms that dominated bursts 20–21. The link/close/O7/org-binding machinery that received the most recent churn re-derived cleanly and is reported INTACT.

---

**RESULT: 0C / 1M / 1med / 0m / 2 obs**

(1 MAJOR = P25-001; 1 MEDIUM = P25-002 — aggregate P22-001 propagation pattern is HIGH across 3 artifacts. **Not a clean pass.** The P25-001 human-save contradiction requires human/architect adjudication before convergence.)

# Adversarial Spec-Delta Review — Pass 21

- **Pass:** 21
- **Date:** 2026-07-27
- **Reviewer:** adversary (fresh context; no access to prior passes)
- **Perimeter reviewed:**
  - `.factory/phase-f2-spec-evolution/architecture-delta.md` (v1.22 — sampled via grep; not fully paginated due to 507 KB size)
  - `.factory/phase-f2-spec-evolution/verification-delta.md` (v1.22)
  - `.factory/phase-f2-spec-evolution/prd-delta.md` (v1.20)
  - `.factory/phase-f2-spec-evolution/dtu-assessment.md` (v1.2)
  - `.factory/phase-f2-spec-evolution/feature/prism-integration-handoff-brief.md` (not independently paginated; referenced via BCs)
  - `.factory/phase-f2-spec-evolution/spec-changelog.md` (not independently paginated)
  - BC-3.01.001 (v1.23), BC-3.03.001 (v1.29), BC-4.02.001 (v1.15), BC-4.05.001 (v1.4), BC-5.01.001 (v1.12), BC-6.01.001 (v1.8), BC-6.01.003/004, BC-8.02.001, BC-9.01.001, BC-10.01.001 (v1.23)

## Methodology

I re-derived the full disposition-guard emitter control-flow (STEP 0→1→1a→2→3→4→4b→5→6, BC-3.03.001 Invariant #4 lines 146–691) and the require-review consumer iterative-consume path (BC-3.01.001 PC#2 lines 69–276) from the pseudocode, without inheriting any prior conclusion. I then applied the **reachability-of-guarantee** axis to every close/link/review/kill-switch claim, traced the three D-023/D-025 close conditions to their guarding steps, and cross-checked each guarantee against (a) the emitter's own canonical test vectors, (b) BC-10.01.001's edge cases and canonical vectors, (c) verification-delta VP/SM coverage, and (d) the dtu-assessment test design. I audited the D-024/D-025/D-026 human decisions for coherent, complete propagation across all four artifact classes (BC bodies, edge cases, canonical vectors, verification/DTU test design). I verified the SM-69/SM-70 allocation chain end-to-end (I initially suspected an orphaned SM-69 at verification-delta L828 and disproved it — SM-69 is correctly defined at L1259/L2733/L2813).

The two MAJOR findings are both **partial-fix propagation gaps**: a confirmed human decision was applied to the primary pseudocode/edge-cases but not to the sibling test-design artifacts that F4/F6 will actually build BATS from.

---

## Critical Findings

None.

---

## Important Findings

### P21-001 — [MAJOR] D-025 STEP 4b hoist not propagated to the canonical test vectors; vectors still attribute the close-disposition gate to "STEP 6 … fires FIRST" and specify the wrong audit-provenance string; the autonomy_enabled=FALSE regression case (the SM-69 kill vector) has no canonical vector in either BC

**Artifacts:** BC-3.03.001 v1.29 (`.../behavioral-contracts/BC-3.03.001.md` lines 967, 970, 972 vs. emitter lines 450–467 + 593–610); BC-10.01.001 v1.23 (`.../BC-10.01.001.md` line 721 vs. EC-022 line 705); cross-ref verification-delta L2733–2737 (SM-69 kill vector).

**Defect.** The headline change of BC-3.03.001 v1.29 / BC-10.01.001 v1.23 (P20-001/D-025) hoists the close-disposition gate to **STEP 4b, before the STEP-5 kill switch**, and demotes the STEP-6 close-branch check to "defense-in-depth only" (BC-3.03.001 lines 450–467 and the annotation at lines 593–598: *"AUTHORITATIVE gate is STEP 4b … STEP 6 … RETAINED here only … defense-in-depth"*). EC-022 (BC-10.01.001 line 705) correctly encodes this: *"(b) disposition∉{FP,BTP} → STEP 4b CLOSE-DISPOSITION-DENY (D-025/P20-001) — authoritative gate."* But the **canonical test vectors were not updated**:

- BC-3.03.001 line 970 (TP+close): *"disposition-guard **STEP 6 close branch: D-023 disposition gate fires FIRST** … audit entry: `CLOSE-DISPOSITION-DENY: … (D-023/P19-001)`"*. Under the actual v1.29 emitter, a TP+close verdict is caught at STEP 4b and **STEP 6 is unreachable** (STEP 4b `RETURN`s at line 467). The vector's mechanism is stale.
- The audit-provenance string is **wrong**: the STEP-4b path writes `"… (D-025/D-023/P20-001)"` (lines 457–459); the vector at line 970 asserts the STEP-6 form `"… (D-023/P19-001)"` (line 600–602). A BATS test that greps the audit line for provenance will diverge from the correct implementation, or worse, an implementer will "fix" the emitter to route TP+close through STEP 6 to match the vector — **reintroducing the exact P20-001 reachability bug** (TP+close+autonomy=false silently allowed at STEP 5). Lines 967 and 972 likewise still say "STEP 6 close branch."
- **No canonical vector exercises the fix.** Every close vector uses `autonomy_enabled=true` (lines 967, 968, 970, 971, 972) except line 969 (FP+close+autonomy=false). There is **no TP+close+autonomy_enabled=FALSE vector** in either BC — yet verification-delta L2733–2737 explicitly defines SM-69's kill vector as *"disposition=TP + close + scored_priority=LOW + **autonomy_enabled=false**."* The one TP+close vector (line 970) uses autonomy=true, which passes under **both** the buggy (STEP-6-only) and fixed (STEP-4b) emitters — so the BC's canonical vector set provides **zero coverage** of the reachability fix it is supposed to demonstrate.
- Intra-document contradiction in BC-10.01.001: EC-022 (line 705) says STEP 4b authoritative; canonical vector line 721 says *"STEP 6 close branch: D-023 disposition gate fires FIRST … (D-023/P19-001)."*

**Failure scenario.** FV builds BATS from BC-3.03.001's canonical vectors. For TP+close it encodes autonomy=true and asserts the STEP-6 audit string `(D-023/P19-001)`. The correct STEP-4b emitter emits `(D-025/D-023/P20-001)` → test fails against correct code → implementer edits the emitter to defer the check to STEP 6 to satisfy the vector → TP+close+autonomy_enabled=false (the default) now flows STEP 4 (no floor) → STEP 5 (kill switch → allow-without-marker) and never reaches STEP 6 → a **TP ticket is silently auto-closed with no CLOSE-DISPOSITION-DENY and no audit entry** — precisely the P20-001 regression D-025 exists to prevent, and D-023's "TP verdicts are NEVER auto-closed" invariant is violated.

**Remediation direction.** In BOTH BCs' canonical test vector tables: (1) rewrite the TP+close and FP+close rows to attribute the gate to **STEP 4b** with the correct `(D-025/D-023/P20-001)` audit provenance, annotating STEP 6 as unreached defense-in-depth; (2) add a **TP+close+scored_priority=LOW+autonomy_enabled=FALSE → CLOSE-DISPOSITION-DENY at STEP 4b** vector (the SM-69 kill vector) to both BCs; (3) keep the FP+close+autonomy=false row (line 969) but confirm STEP 4b passes before STEP 5.

---

### P21-002 — [MAJOR] dtu-assessment.md still specifies §3.4 rule 2 (`related-open`) as comment+link, directly contradicting the D-024/P19-004 human decision (rule 2 = create+link) as encoded in BC-10.01.001 EC-011, BC-4.02.001 PC#7b, and verification-delta VP-HOOK-036

**Artifacts:** `.factory/phase-f2-spec-evolution/dtu-assessment.md` v1.2 (lines 19, 296, 318, 337) vs. D-024; BC-10.01.001 EC-011 (line 694); BC-4.02.001 PC#7b (line 82); verification-delta L2706–2711, L2833.

**Defect.** D-024 (confirmed human decision, 2026-07-23) resolved the rule-2 ambiguity to **create+link**: *"a new ticket per root cause, linked 'Relates' to the existing related ticket, parallel to rule 4."* This propagated to BC-10.01.001 EC-011 (line 694: *"rule 2 (create+link — HUMAN DECISION 2026-07-23 … each root cause has its own ticket)"*), BC-4.02.001 PC#7b (line 82: *"rule 2 — create+link … the existing related ticket is NOT commented upon (rule 2 is now create+link, not comment+link)"*), and verification-delta VP-HOOK-036 (L2706–2711: rule-2 vectors updated from comment+link to create+link). The **dtu-assessment was left at v1.2 (pass-18/burst-15, pre-decision) and never re-bumped** (confirmed: prd-delta burst-16/17 notes bump the BCs for D-024 but never the dtu-assessment). It still specifies rule 2 as comment+link:

- Line 19 (v1.2 header note): *"must handle the D-022 two-sequential-Write compound sequences (**comment+link for rule 2**, create+link for rule 4)."*
- Line 296 (`related-open` scenario): *"verdict-1 **comment marker → `jr issue comment KEY1`**; verdict-2 `["link"]` marker … Mock asserts both calls."*
- Line 318: *"for closed-same (create+link) and **related-open (comment+link)**."*
- Line 337 (test surface): *"`related-open` (**comment+link**): assert comment precedes link in call log."*

**Failure scenario.** F4 test authors build the enhanced jr L2 mock and the monitoring-loop Stage-7 §3.4 BATS suite from the dtu-assessment. For the `related-open` branch they seed a mock and write assertions requiring `jr issue comment KEY1` on the **existing related ticket** — behavior the BCs now explicitly **prohibit** ("the existing related ticket is NOT commented upon"). Either the test fails against a correct create+link implementation, or the implementer builds the prohibited comment-on-related-ticket behavior to satisfy the test — violating the P19-004 "keep tickets separate" invariant.

**Remediation direction.** Bump dtu-assessment to v1.3; update the `related-open` scenario (line 296), the compound-sequence note (line 318), the test-surface row (line 337), and the header note (line 19) to **create+link** (verdict-1 create → NEW_KEY; verdict-2 link ticket_id=NEW_KEY, link_target_ticket_id=existing_related_key; no comment on the related ticket), mirroring `closed-same`.

---

### P21-003 — [MEDIUM] dtu-assessment never-auto-reopen test asserts absence of `jr issue transition`, but the reopen/transition command is `jr issue move`; the assertion is vacuous and does not guard the never-auto-reopen invariant

**Artifacts:** `.factory/phase-f2-spec-evolution/dtu-assessment.md` (lines 257, 304) vs. BC-4.02.001 Invariant #4 (line 91) + VP-SKILL-066 (line 131).

**Defect.** BC-4.02.001 Invariant #4 pins the prohibited reopen command as **`jr issue move`** (*"MUST NOT execute any `jr issue move` command that transitions a ticket out of Resolved or Closed status"*), and VP-SKILL-066's BATS name is *"update-jira never executes `jr issue move` to reopen."* The dtu-assessment's mock design specifies the never-auto-reopen assertion against a **different, non-existent command**: line 257 (*"`jr issue transition` — must not be called for auto-reopen"*) and line 304 (*"Test asserts `jr issue transition` is NOT called for the `resolved-same` and `closed-same` scenarios"*). `jr issue transition` (singular) is neither the write command used anywhere in the BCs nor on any allowlist/write-block; a real auto-reopen would be performed via `jr issue move <ticket_id> <open_state>`.

**Failure scenario.** FV encodes line 304 verbatim: `assert jr issue transition NOT called`. This assertion trivially passes for every scenario (the command is never emitted by anything). A regressed skill that auto-reopens a Closed ticket via `jr issue move KEY "In Progress"` goes **undetected** — the guard fires against the wrong command name. Note `jr issue move` is doubly load-bearing (also the authorized close command), so the assertion must be "no `jr issue move` to a non-close/reopen state," not "no `jr issue transition`."

**Remediation direction.** Change lines 257 and 304 to assert no `jr issue move` transitions a ticket out of Resolved/Closed (distinguish the allowed close-state moves from prohibited reopen moves).

---

### P21-004 — [MEDIUM] dtu-assessment names the §3.4 dedup query `jr issue search`, which is not on require-review's read-only allowlist; if the loop issues `jr issue search`, require-review's fail-closed catch-all denies it and Jira-first dedup breaks

**Artifacts:** `.factory/phase-f2-spec-evolution/dtu-assessment.md` (lines 253, 293) vs. BC-3.01.001 read-only allowlist (lines 310–333) + fail-closed catch-all (PC#4, line 335); BC-10.01.001 Invariant #8 (lines 231–237, "dedup JQL query").

**Defect.** The dtu-assessment repeatedly names the dedup command `jr issue search (JQL)` (line 253 item 1; line 293 scenario table header). BC-3.01.001's read-only allowlist enumerates `jr issue view`, `jr issue list`, `jr issue comments`, `jr issue transitions`, `jr assets search`, … but **not `jr issue search`** (lines 310–333). Any `jr` subcommand that is neither write-blocked nor allowlisted is **denied fail-closed** (SEC-002, PC#4 line 335). BC-10.01.001 (lines 233/237) only says "dedup JQL query" without pinning the subcommand, so the artifacts disagree on the actual command.

**Failure scenario.** If the monitoring-loop Stage-2 dedup issues `jr issue search --jql "…"` (as the dtu-assessment specifies), require-review write-block does not match, allowlist does not match → **DENY**. The loop cannot run its Jira-first dedup → it either aborts or (worse, if the loop treats the deny as "no ticket found") **creates duplicate tickets**, violating D-DEC-004's one-open-ticket-per-(org_slug, sensor_id) constraint. Confidence MEDIUM: the real jr subcommand may be `jr issue list --jql` (allowlisted), in which case the dtu-assessment mis-names it; either way two spec artifacts are incoherent about a load-bearing read command.

**Remediation direction.** Pin the dedup command in BC-10.01.001 Invariant #8 to a specific jr subcommand and ensure BC-3.01.001's allowlist contains it. If it is `jr issue search`, add `jr issue search` (+ `--output json issue search`) to the allowlist; if it is `jr issue list --jql`, correct the dtu-assessment (lines 253, 293) to `jr issue list`.

---

## Observations

- **P21-005 — [MINOR] Stale SM-catalog recap in verification-delta.** verification-delta line 2806 states the current SM catalog as *"SM-9..SM-68, **61 mutants** … +SM-66/SM-67/SM-68 at v1.21"* — the "+SM-69/SM-70 at v1.22" extension is missing, even though the authoritative §4 preamble (line 1259) and the v1.22 closing summary (line 2813) correctly state **63 mutants / SM-9..SM-70**. Internal count inconsistency (61 vs 63) in a v1.22 document. The authoritative statements are correct, so no implementer is misled on the mutant set itself; the version-coherence sweep should reconcile the recap line. (I verified this is NOT an orphaned-SM defect: SM-69 at L828/L2733 and SM-70 at L2747 are both properly defined.)

- **P21-006 — [process-gap / OBSERVATION] D-026 orphan-link predicate has no specified read mechanism.** The D-026 rule fires on *"no `Relates(O,C)` link exists"* (BC-10.01.001 EC-010 line 693, Stage-8 lines 628–637). Detecting the absence of a `Relates` link requires the loop to enumerate an existing ticket's issue-links, but no BC specifies the read command for this, and BC-3.01.001's read-only allowlist (lines 310–333) contains no explicit link-enumeration command (`jr issue view` output is the presumed but unstated source). Unstated implementability assumption; recommend pinning the link-read mechanism in BC-10.01.001 §3.4 / Invariant text and confirming it is allowlisted, so the D-026 predicate is actually computable at the loop layer.

- **P21-007 — [OBSERVATION] "Permission dialog" terminology for non-close `jr issue move`.** BC-4.02.001 Invariant #1 (line 88) states non-close status moves are *"fail-closed denied absent human permission-override via the Claude Code permission dialog."* require-review emits only `allow`/`deny` (BC-3.01.001 Invariant #1, line 340) — never an `ask`; a write-blocked non-close `jr issue move` with no matching marker is **denied**, not surfaced as an interactive approval prompt. The behavior is coherent (fail-closed deny; no non-close move scope exists in the v2.2 enum), but the "permission dialog / permission-override" phrasing overstates what require-review does and may mislead an operator into expecting an interactive approval path. Low priority terminology cleanup.

---

## Surfaces re-derived and found INTACT

I attacked the following and could **not** break them:

- **Close 3-condition AND reachability (D-023/D-025).** Traced all TP/Indeterminate/FP/BTP × hard-floor × autonomy_enabled combinations through STEP 3→4→4b→5→6. TP+close is denied at STEP 4b (non-hard-floor) or STEP 4 UNDER-LABEL-DENIED (hard-floor); Indeterminate+close hits STEP 4 first; FP/BTP+close requires STEP 4 pass (non-hard-floor) AND STEP 4b pass AND STEP 5 pass (autonomy=true) — the emitter *logic* enforces all three D-023/D-025 conditions with no reachable bypass. (The defect in P21-001 is in the *test vectors*, not the emitter pseudocode, which is correct.)
- **STEP 4b fires for ALL autonomy_enabled values** — it precedes STEP 5 (lines 456–467 before 486–489); the guarantee is reachable.
- **HIGH/CRIT never auto-closed** — FP+close+scored_priority=HIGH is caught by STEP 4 DENY-THE-WRITE before the close branch (BC-3.03.001 vector line 968; hard_floor keyed on scored_priority per lines 781–783). Intact.
- **Marker anti-fungibility across all 7 scopes** — command_pattern anchoring (consumer step 5, lines 91–100) + exact-type authorized_operations matching (step 6, lines 101–115) + STEP 6a structural label check with the quote-aware/backslash-aware tokenizer (lines 119–196) correctly isolate create vs create-review, comment vs comment-review, link, and close. link/close disambiguated by distinct verbs. Intact.
- **O7 charset-validation + regex-escape at all 9 interpolation sites** (BC-3.03.001 line 779) — every command_pattern-constructing branch (comment/comment-review/assign/create/create-review/link/close, plus close_state) validates and escapes before interpolation. Intact.
- **Kill-switch determinism** — autonomy_enabled read directly from verdict JSON, default-false on absent/non-boolean (lines 486–489); review path (STEP 3) correctly exempt and gated on hard_floor_applies() (O3 over-label guard, lines 302–306). Intact.
- **JSON-first dispatch collision fix** (PC#1 Check 1, lines 69–81) and **Document-Before-Action stage ordering** (VP-HOOK-027/028) — intact and internally consistent with BC-10.01.001 Stage 7/8.
- **SM-69/SM-70 allocation** — properly defined (verification-delta L1259, L2733, L2747, L2813); VP-HOOK-035 mutant set {61,62,63,64,66,67,69} at L828 is consistent; my initial "orphaned SM-69" hypothesis was disproved.
- **D-024 create+link propagation to the BCs and verification-delta** — coherent in BC-10.01.001 EC-011/EC-013, BC-4.02.001 PC#7b/PC#7d, and VP-HOOK-036 (the *only* miss is the dtu-assessment, P21-002).

---

## Novelty Assessment

**Novelty: MODERATE–HIGH.** The two MAJOR findings are substantive, previously-unretreaded gaps: both are partial-fix propagation misses where a confirmed human decision (D-025 STEP 4b hoist; D-024 rule-2 create+link) reached the primary pseudocode/edge-cases but not the test-design artifacts (canonical vectors and dtu-assessment) that F4/F6 build from. These are exactly the class the reachability-of-guarantee and partial-fix-regression axes target — the emitter is correct, but the artifacts that generate the regression tests are stale, so the fixes are untested (P21-001) or actively contradicted (P21-002). The MEDIUM findings (P21-003/P21-004) are concrete command-name incoherences in the dtu-assessment with functional blast radius. These are not wording nitpicks; each would cause a wrong test to be built or a real command to be blocked.

## Verdict

**RESULT: 0C / 2M / 2med / 1m / 3 obs** — (MAJOR: P21-001, P21-002; MEDIUM: P21-003, P21-004; MINOR: P21-005; OBSERVATIONS: P21-006, P21-007).

**NOT CLEAN** (2 MAJOR + 2 MEDIUM). Convergence is blocked; the dtu-assessment (rule-2 create+link, `jr issue move` reopen assertion, dedup command name) and the close-scope canonical test vectors in BC-3.03.001 v1.29 / BC-10.01.001 v1.23 require remediation.

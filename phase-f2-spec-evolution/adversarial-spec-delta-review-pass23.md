# Adversarial Spec-Delta Review — Pass 23

**Pass:** 23
**Date:** 2026-07-28
**Reviewer:** adversary (fresh context — no prior-pass knowledge)
**Perimeter (versions reviewed):**
- architecture-delta.md v1.24, verification-delta.md v1.24, prd-delta.md v1.22, dtu-assessment.md v1.3, prism-integration-handoff-brief.md, spec-changelog.md ([1.1.0])
- BC-3.01.001 v1.25, BC-3.03.001 v1.31, BC-4.02.001 v1.17, BC-4.05.001 v1.4, BC-5.01.001 v1.12, BC-6.01.001 v1.8, BC-6.01.003 v1.7, BC-6.01.004 v1.1, BC-8.02.001 v1.4, BC-9.01.001 v1.2, BC-10.01.001 v1.25

## Methodology

I re-derived the disposition-guard emitter control flow (STEP 0→1→1a→2→3→3b→4→4b→5→6/STEP6_LINK) directly from the BC-3.03.001 pseudocode (lines 209–719), traced every "exempt/regardless/fires before" claim to its guarding position, and cross-checked the require-review consumer (BC-3.01.001), the monitoring-loop stage/EC/canonical-vector layer (BC-10.01.001), the VP/SM roster (verification-delta), and the test-infrastructure design (dtu-assessment). I focused the four mandatory axes on the new D-027 STEP 3b link carve-out and its interaction with the P10-003 fail-closed marker mechanism, the autonomy_enabled kill switch, and the compound create+link sequences. All findings carry file:line evidence; I ran a 3-iteration self-validation loop and dropped inference-only concerns that could not be grounded.

---

## Critical Findings

None. (STEP 4b close-disposition hoist, JSON-first dispatch, enum/severity-consistency ordering, and the P8-001 unbindable-deny paths for create-review/comment-review were all re-derived and found sound — see "Surfaces Intact".)

---

## Important Findings

### P23-001 — MAJOR — D-027 "review-class" link path is NOT fail-closed on marker-write-failure or null KEY1; hard-floor link silently dropped with no audit (CONFIDENCE: HIGH)

**Artifacts:** BC-3.03.001.md lines 408–424 (STEP 3b), 578–619 (STEP6_LINK link branch), 673–718 (WRITE_MARKER), 755; verification-delta.md line 431 (VP-HOOK-033); BC-10.01.001.md lines 168–184 (Gate-2 audit grep), 704 (EC-010), 729 (EC-011 vector).

**Defect.** D-027 (BC-3.03.001 v1.31 revision note, line 30) declares `ticket_action_type=link` under `hard_floor_applies()=TRUE` to be **review-class**, "mirroring the D-DEC-012 rationale," and exempt from STEP 4/STEP 5. But the WRITE_MARKER fail-closed protection introduced by P10-003 keys exclusively on `is_review_path`:

- Line 681: `is_review_path = (action in {"create-review", "comment-review"})` — link is **not** in the set.
- Line 583 explicitly states: "`is_review_path` stays false for link in both cases."
- Lines 700–718: on marker-write failure, `IF is_review_path:` → DENY + `MARKER-WRITE-FAILED` audit; `ELSE:` → **`emit allow without marker; RETURN`**.

Therefore a hard-floor (review-class) link whose marker fails to write takes the ELSE branch: **allow-without-marker, no audit entry**. The loop then runs `jr issue link KEY1 KEY2`, require-review finds no marker and DENIES it, and the hard-floor relationship is silently dropped. A second silent-drop exists at line 585: on the STEP 3b hard-floor path, `IF ticket_id is null: emit allow without marker; RETURN` — again no `HARD-FLOOR-UNBINDABLE` deny, unlike the create-review/comment-review binding-failure paths (lines 311–333, 356–385) which fail loud per D-DEC-012 clause 2. This is a direct internal contradiction: the link path receives the *permissive* half of "review-class" (kill-switch + hard-floor exemption) but not the *defensive* half (fail-loud on unbindable / write-failure).

**Failure scenario.** EC-011 (BC-10.01.001 line 729, related-open D-024 rule-2 create+link, hard-floor): verdict-1 create succeeds → `PRISMDEMO-51` created; verdict-2 link marker write fails (disk full / perms). is_review_path=false → allow-without-marker, no audit. `jr issue link PRISMDEMO-51 PRISMDEMO-50` is denied by require-review. The two related tickets remain **permanently unlinked** — and unlike the closed-ticket cases (EC-008/EC-013), the D-026 orphan-link recovery predicate does **not** cover EC-011 (D-026 requires a *Closed/Resolved* C, but the related ticket here is *open* with a *different* root cause), so no subsequent loop run self-heals it. Because no `MARKER-WRITE-FAILED` code is emitted, the Gate-2 operator boundary (BC-10.01.001 line 168 greps for exactly that code; VP-SKILL-075) cannot detect the loss. No VP/SM covers this: VP-HOOK-033 (line 431) only asserts write-block + anti-fungibility (SM-57/SM-58); SM-72 (line 434) only covers "STEP 3b carve-out removed → link never issued." The write-failure/null-KEY1 fail-loud behavior for the review-class link is unverified.

**Remediation direction.** Either (a) include `"link" WHEN reached via STEP 3b (hard-floor)` in the fail-closed set so marker-write-failure and null-KEY1 produce a `MARKER-WRITE-FAILED` / `HARD-FLOOR-UNBINDABLE` deny + audit; or (b) explicitly document that hard-floor links are exempt from fail-loud and justify why silent loss + no audit is acceptable for the review-class link (this would still leave the Gate-2 detection blind). Add a covering VP/SM for the review-class-link marker-write-failure path.

---

## Observations (Medium — block convergence)

### P23-002 — MEDIUM — dtu-assessment v1.3 predates and does not cover the D-027 STEP 3b hard-floor link path `[process-gap]` (CONFIDENCE: HIGH)

**Artifacts:** dtu-assessment.md v1.3 (frontmatter line 4; latest header note lines 16–29 stops at "Pass-21 … burst 18, P21-002…/D-024"); jr-mock scenarios lines 314–323; prd-delta.md line 135 (burst-19/D-027 lists architecture-delta→v1.24 and BC bumps but **no** dtu-assessment bump); BC-10.01.001.md line 735 (D-027 canonical vector: sensor silence + Closed BLIND-SPOT + `autonomy_enabled=false` → STEP 3b link).

**Defect.** D-027 (STEP 3b review-class link) landed in burst-19 (architecture-delta v1.24, BC-3.03.001 v1.31, BC-10.01.001 v1.25). dtu-assessment was last bumped for D-024 (burst-18) and never re-bumped for D-025/D-026/D-027. Its jr-mock scenario table (lines 314–323) has `related-open` and `closed-same` create+link scenarios but (a) treats the `["link"]` marker as a single generic scope with no review-class/STEP-3b distinction, and (b) contains **no scenario exercising a hard-floor link under `autonomy_enabled=false`** — the exact new reachability D-027 introduces and the exact scenario BC-10.01.001 line 735 marks CRITICAL. The mock design as written cannot exercise the D-027 path, so the L2 jr mock provides zero coverage for the STEP 3b carve-out (and none for the D-025 TP+close-deny SM-69 vector either). This is the "mock design does not cover the hard-floor link path" gap the assessment is supposed to close.

**Remediation.** Bump dtu-assessment; add a `blind-spot-closed-compound` (autonomy_enabled=false) scenario asserting verdict-2 link marker IS issued and consumed via STEP 3b, and a `tp-close-denied` scenario asserting no `jr issue move` is called.

### P23-003 — MEDIUM — VP-SKILL-065 kill-switch invariant is stale w.r.t. the D-027 link carve-out (CONFIDENCE: HIGH)

**Artifacts:** BC-10.01.001.md line 749 (VP-SKILL-065); prd-delta.md line 135 (burst-19 VP-anchor implications lists VP-HOOK-026 for update but omits VP-SKILL-065).

**Defect.** VP-SKILL-065 is the primary kill-switch coverage property: "when autonomy_enabled=false, ZERO REGULAR (non-review) markers are consumed AND ZERO REGULAR jr **create/comment/assign** calls are made; `create-review` and `comment-review` … ARE EXECUTED (EXEMPT …)". After D-027, a hard-floor link **also** executes under autonomy=false (STEP 3b), and a non-hard-floor link/close are REGULAR-scope writes subject to the kill switch. VP-SKILL-065 (a) does not enumerate link/close in the "ZERO REGULAR" set, and (b) its positive-exemption leg names only create-review/comment-review — the new hard-floor-link exemption under autonomy=false is uncovered. The burst-19 propagation note updated VP-HOOK-026/033/036 but never flagged VP-SKILL-065, so the kill-switch invariant contradicts the STEP 5 preamble (BC-3.03.001 lines 491–497, which now lists STEP 3b as an exemption).

**Remediation.** Extend VP-SKILL-065 to include link/close in the REGULAR set and add a positive vector asserting a hard-floor link executes under autonomy_enabled=false.

### P23-004 — MEDIUM — STEP6_LINK label placed before an `ELIF` clause: ill-formed GOTO target; dual-entry has no implementable structure (CONFIDENCE: MEDIUM)

**Artifacts:** BC-3.03.001.md lines 518–519 (`# STEP 6` + `link_target = null`), 520/538/561 (`IF/ELIF` ladder), 578–579 (`STEP6_LINK:` immediately followed by `ELIF action == "link":`), 423–424 (`GOTO STEP6_LINK`).

**Defect.** The `STEP6_LINK:` label sits between the `assign` ELIF block and the `ELIF action == "link":` clause. `GOTO STEP6_LINK` (line 424) therefore jumps to a point whose next statement is an `ELIF` whose governing `IF action=="comment"` (line 520) was never entered on the GOTO path — a jump into the middle of an if/elif ladder, which is not well-formed structured control flow. The GOTO also skips the `link_target = null` initialization at line 519 (harmless for link only because 619 reassigns it, but fragile). The actual enforcement surface is `disposition-guard.sh` (bash), which has no `goto`; the BC gives the implementer no callable-function or duplicated-branch structure for the dual entry. An implementer duplicating the link branch to realize the two entry paths could easily drop the O7 KEY1/KEY2 charset validation (lines 587–613) on one copy — precisely the metacharacter surface VP-HOOK-034 exists to protect.

**Remediation.** Refactor the link branch into a named subroutine invoked from both STEP 3b and the STEP-6 fall-through, or hoist STEP6_LINK to a labeled statement block (not an ELIF), so the dual-entry semantics are expressible without jumping into an if/elif ladder.

### P23-005 — MEDIUM — STEP 3b link carve-out has no org-binding and no disposition constraint; LLM-forgeable hard-floor enables cross-org / arbitrary-pair links under autonomy_enabled=false (CONFIDENCE: MEDIUM)

**Artifacts:** BC-3.03.001.md lines 423–424 (STEP 3b gate = `action=="link" AND hard_floor_applies()`), 617 (link pattern `^jr … issue link KEY1 KEY2( |$)` — no `--project`/org token), 226–230 (scored_priority is LLM-supplied, ASM-008 residual, not cross-checked by STEP 1a); contrast lines 477 (STEP 4b close requires disposition∈{FP,BTP}) and 350/558 (create binds `--project <key>`).

**Defect.** STEP 3b gates the kill-switch/hard-floor exemption on `hard_floor_applies()` alone. Per the STEP 1a reframe (lines 220–234) the HIGH/CRIT floor keys on `verdict.scored_priority`, which is purely LLM-supplied with no hook cross-validation (acknowledged ASM-008 residual). So an adversarial or buggy loop LLM can set `scored_priority=CRIT` + `ticket_action_type=link` and force a link marker to be issued **under autonomy_enabled=false**, bypassing the kill switch. Unlike create/create-review (org-bound via `--project`) and close (disposition-gated at STEP 4b to FP/BTP), the link path has **neither** an org binding nor a disposition constraint — KEY1/KEY2 are both LLM-chosen (`verdict.ticket_id`, `verdict.link_target_ticket_id`) and nothing verifies they belong to the same org/project. This is the NEW-CARVE-OUT ABUSE surface: relationship-only writes across arbitrary (including cross-org) ticket pairs, executable while autonomy is nominally OFF.

**Remediation.** Add a same-org/same-project constraint on link KEY1/KEY2 (or document why cross-project links are acceptable under D-DEC-005), and consider gating STEP 3b link additionally on disposition (parallel to STEP 4b) so a forged hard-floor cannot alone unlock the link write.

### P23-006 — MEDIUM — spec-changelog.md is 3 remediation bursts stale: missing D-025, D-026, and the CRITICAL D-027 rows and the SM-69..SM-73 roster `[process-gap]` (CONFIDENCE: HIGH)

**Artifacts:** spec-changelog.md lines 8 ("Track all spec version changes"), 12–30 (most-recent entry is "Pass-19 … Burst 16", D-023/D-024; SM roster line 21 = "SM-9..SM-68"); contrast prd-delta.md v1.22 lines 135/137/139 (bursts 17/18/19 = D-025/D-026/D-027) and verification-delta.md lines 433–434 (SM-69/SM-70/SM-71/SM-72/SM-73).

**Defect.** The canonical spec-changelog stops at Pass-19/Burst-16. It records neither the D-025 STEP 4b close-hoist (burst-17), the D-026 link-read pinning (burst-18), nor the CRITICAL D-027 STEP 3b link carve-out (burst-19), and its mutant roster ("SM-9..SM-68") omits SM-69..SM-73 that D-025/D-026/D-027 introduced. Every BC and the prd-delta are at pass-22; the changelog is the sole artifact left behind. As the authoritative "track all spec version changes" record, this is a traceability regression that hides the highest-severity recent change (D-027) from the change history.

**Remediation.** State-manager: append burst-17/18/19 rows (D-025/D-026/D-027) and refresh the VP/SM totals to include SM-69..SM-73.

---

## Observations (non-blocking)

### P23-007 — MINOR — BC-3.03.001 v1.31 markdown-reorder note describes "disposition routing runs FIRST" while listing it as step (3) after the hard-floor gates (CONFIDENCE: MEDIUM)

**Artifact:** BC-3.03.001.md line 30 (v1.31 note): "the gating sequence is now: (1) 12-field completeness … (2) markdown-evaluable hard floors → GATE 1/GATE 2 …, (3) disposition routing **runs FIRST**: FP → allow-without-marker; non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH." Calling step (3) "runs FIRST" is self-contradictory; the intent is "before the (removed) kill switch," but a reader/implementer could invert the hard-floor-vs-routing order. The numbered list itself is unambiguous (hard floors precede routing), so this is wording only. Recommend: "disposition routing now precedes the former kill-switch position (which is removed)."

### P23-008 — OBSERVATION — perimeter path mismatch for spec-changelog

The task perimeter lists spec-changelog under `.factory/phase-f2-spec-evolution/`, but the file lives at `.factory/spec-changelog.md` (the phase-f2 directory has none). Not a spec defect; noted so downstream tooling anchors the correct path.

---

## Surfaces Re-Derived and Found INTACT

- **STEP 4b close-disposition gate (D-025):** correctly hoisted before STEP 5 (BC-3.03.001 lines 471–488); fires for all autonomy_enabled values; SM-69 kill vector present; canonical vectors coherent (BC-10.01.001 lines 730–732; STEP 6 branch demoted to defense-in-depth, lines 621–638). No reachability gap.
- **Enum validation (STEP 1) + severity-consistency (STEP 1a):** run before STEP 3/3b/4 (lines 209–251); STEP 3b explicitly does not bypass them (lines 418, 427). Sound.
- **Consumer write-block + anti-fungibility:** `jr issue link ` and `jr issue move` (plus `--output json` forms) are on the write-block list (BC-3.01.001 line 69); bidirectional link/close anti-fungibility vectors present (lines 419–422); link consumer enforces KEY1==ticket_id ∧ KEY2==link_target_ticket_id via the anchored pattern (line 115). Sound.
- **create-review/comment-review UNBINDABLE deny (P8-001):** fail-loud on null project_key/ticket_id (BC-3.03.001 lines 311–333, 356–385). Sound (contrast with the link gap in P23-001).
- **O7 link charset validation:** KEY1/KEY2 validated at STEP6_LINK for both entry paths (lines 587–615); VP-HOOK-034 covers both sites. Sound.
- **Non-existent jr verbs:** `jr issue search`/`transition`/`reopen` appear in live spec content only inside corrective annotations noting they do not exist (BC-3.01.001 line 314; BC-10.01.001 line 235; dtu-assessment lines 23–25; VP-SKILL-062 corrected to `jr issue move <key> <state>`, BC-10.01.001 line 746). No live reliance on a phantom verb.
- **Frontmatter version coherence:** BC-3.03.001 1.31 / BC-3.01.001 1.25 / BC-10.01.001 1.25 / BC-4.02.001 1.17 all match prd-delta v1.22 §5. No version drift.
- **Compound create+link canonical vector (D-027):** BC-10.01.001 line 735 is coherent with the STEP 3b emitter path (aside from the unhandled marker-write-failure branch flagged in P23-001).

---

## Novelty Assessment

Findings are substantive, not refinements. P23-001 (review-class link not fail-closed) is a genuine internal contradiction newly created by the D-027 burst-19 change and is uncovered by any VP/SM; P23-002/P23-003/P23-005 are direct, previously-unpropagated consequences of the same burst-19 carve-out into the test-infrastructure, kill-switch-invariant, and authorization-surface layers; P23-006 is a traceability regression spanning the last three bursts. This is the opposite of convergence: the newest decision (D-027) propagated into the emitter and BC-10.01.001 but did **not** propagate into the fail-loud mechanism, the DTU mock, VP-SKILL-065, or the spec-changelog. **Novelty: HIGH — the D-027 carve-out has an incomplete blast radius.**

---

**RESULT: 0C / 1M / 5med / 1m / 2 obs**

This pass is **NOT CLEAN** (1 MAJOR + 5 MEDIUM). The blocking chain is P23-001 (fail-loud regression on the review-class link path) and its propagation gaps P23-002/003/005/006.

# Adversarial Review — Pass 22

- **Pass:** 22
- **Date:** 2026-07-27
- **Reviewer:** adversary (fresh context — no prior-pass artifacts consulted)
- **Perimeter reviewed (versions):** architecture-delta.md v1.23, verification-delta.md v1.23, prd-delta.md v1.21, dtu-assessment.md v1.3, feature/prism-integration-handoff-brief.md, spec-changelog.md; BC-3.01.001 v1.24, BC-3.03.001 v1.30, BC-4.02.001 v1.16, BC-4.05.001 v1.4, BC-5.01.001 v1.12, BC-6.01.001 v1.8, BC-6.01.003 v1.7, BC-6.01.004 v1.1, BC-8.02.001 v1.4, BC-9.01.001 v1.2, BC-10.01.001 v1.24.

## Methodology

Re-derived the disposition-guard emitter control-flow (STEP 0→1→1a→2→3→4→4b→5→6 + WRITE_MARKER), the require-review iterative-consume consumer (steps 1–9 + STEP 6a), and the investigation-markdown minimal path from the primary artifacts. Applied the three mandatory axes — REACHABILITY-OF-GUARANTEE, TEST-VECTOR-VS-PSEUDOCODE COHERENCE, CLI-SURFACE COMPLETENESS — plus the standing axes (partial-fix propagation, mis-anchoring). Cross-checked the settled decisions D-023/D-024/D-025/D-026 for coherent, complete implementation across all artifacts. Verified `jr` verb usage against the supplied ground-truth verb list. Each finding is grounded in file:line evidence and self-validated for evidence/actionability/duplication (3 iterations).

---

## Critical Findings

### P22-003 — Compound `create+link` second Write is unreachable for every hard-floor alert; BLIND-SPOT link (EC-008) is structurally impossible and D-026 permanently starves rule-1 comments (CRITICAL, confidence HIGH)

**Artifacts / anchors:**
- architecture-delta.md:1697–1731 (STEP 4 `IF hard_floor_applies(...): emit deny; RETURN` — applies to all regular actions including `link`)
- architecture-delta.md:1842–1878 (STEP 6 `link` branch is a REGULAR scope reached only *after* STEP 4)
- architecture-delta.md:294–296, 1356 and BC-10.01.001:623–625 ("link … REGULAR scope — subject to STEP 4 hard floor + STEP 5 kill switch; issued as a SECOND sequential verdict Write in compound action sequences (D-022)")
- BC-10.01.001:698 (EC-008 closed BLIND-SPOT → create + link), :701 (EC-011 rule 2), :703 (EC-013 rule 4), :700 (EC-010 D-026 precedence over rule 1)
- architecture-delta.md:2259–2295 (`hard_floor_applies()` returns TRUE for `disposition==Indeterminate` and `sensor_health_status in {degraded,silent}`)

**Defect:** `ticket_action_type=link` is a REGULAR-scope action, so the link verdict passes through STEP 4 and is denied whenever `hard_floor_applies()` returns TRUE. But the compound `create+link` sequence is *mandated* precisely for scenarios that are intrinsically hard-floor. The link verdict-2 describes the same alert as verdict-1, so it carries the same hard-floor fields (scored_priority HIGH/CRIT, Indeterminate disposition, critical asset, or silent sensor). STEP 4 therefore denies verdict-2 and reroutes it to `comment-review`, which comments on the ticket but never issues the `["link"]` marker. The Relates link is never created.

**Concrete failure scenario:**
1. EC-008 (closed BLIND-SPOT → new+link): a BLIND-SPOT finding is *always* `disposition=Indeterminate` + `sensor_health_status=silent` → `hard_floor_applies()`=TRUE unconditionally. verdict-1 (`create-review`) creates the new BLIND-SPOT ticket; verdict-2 (`link`) hits STEP 4, is DENIED, and reroutes to `comment-review`. The new BLIND-SPOT ticket is **never** linked to the closed one. EC-008's stated postcondition is unreachable.
2. EC-013 (closed ticket, HIGH/CRIT TP → create+link): verdict-2 link is denied at STEP 4; the escalation ticket is never linked to its predecessor.
3. Compounding via EC-010/D-026: on the next run, D-026 fires (open O + closed C + no Relates), issues a link-only verdict, which is again denied at STEP 4 (same alert still hard-floor) and rerouted to comment-review. Because D-026 has explicit precedence over rule 1, rule-1 duplicate-occurrence comments are **permanently starved** for that (O,C) pair, and the "self-healing" claim (BC-10.01.001:631,637) is false for hard-floor orphans — every run adds another comment to O and never creates the link.

**Coverage gap (test-vector axis):** VP-HOOK-036 / SM-68 / SM-70 (verification-delta.md:2703–2712, 2743–2752) assert the D-026 reconciliation *fires* but do not assert the reconciliation link verdict actually *passes the emitter*. If the VP-HOOK-036 mock alert is benign (non-hard-floor), the vector passes under both the correct and the broken implementation — zero regression coverage for the hard-floor orphan, which is the dominant real case (rule 4 / BLIND-SPOT).

**Remediation direction:** Decide and specify one: (a) exempt the `link` action from `hard_floor_applies()` in STEP 4 when it is the second Write of a D-022 compound sequence (a link authorizes no triage decision — it only records a relationship, mirroring the D-DEC-012 rationale that review/relationship surfacing must not be blocked); or (b) route the link through the review-exempt path (STEP 3-class) so it survives the hard floor and the kill switch. Then add a VP-HOOK-036 vector whose alert is genuinely hard-floor (e.g., a BLIND-SPOT closed→new+link) and assert the `["link"]` marker is issued and consumed — so the fix is regression-covered.

---

## Important Findings

### P22-001 — Investigation-markdown kill-switch is mis-ordered before the review routing, making the D-DEC-012 Option-A review-surfacing guarantee unreachable (repeats the D-025/P20-001 defect on the markdown path) (MAJOR, confidence HIGH)

**Artifacts / anchors:**
- architecture-delta.md:2029–2037 (gating sequence step 1: "If absent or not exactly `true`: emit allow-without-marker … When autonomy_enabled=false, the markdown path behaves identically to the regular path's STEP 5.")
- architecture-delta.md:2074–2088 (disposition routing → MARKDOWN_REVIEW_PATH reached only *after* step 1)
- architecture-delta.md:2111 ("Issue create-review or comment-review marker (EXEMPT from kill switch per D-DEC-012 Option A)")
- architecture-delta.md:2155–2158 (Key guarantee #2: "STEP 3-equivalent review markers still route non-FP/PARSE_FAIL findings to review under the kill switch")
- Contrast: verdict path places STEP 3 review *before* STEP 5 kill switch (architecture-delta.md:1527–1647 then 1771–1785)

**Defect:** The markdown gating sequence evaluates the autonomy_enabled kill switch as step 1, unconditionally on disposition, and returns allow-without-marker for `autonomy_enabled != true`. The review routing (MARKDOWN_REVIEW_PATH) is only reached *after* step 1. Therefore, under `autonomy_enabled=false`, a non-FP/PARSE_FAIL investigation markdown never reaches the review path — it exits at step 1 with allow-without-marker. This directly contradicts (a) the "EXEMPT from kill switch per D-DEC-012 Option A" annotation at :2111 and (b) Key guarantee #2 at :2155–2158, and it falsifies the claim at :2037 that the path "behaves identically to the regular path's STEP 5" (in the regular path STEP 5 is *after* STEP 3, so review markers survive the kill switch). This is the exact ordering pathology D-025/P20-001 fixed for the verdict close-gate, reproduced on the markdown path and not caught.

**Concrete failure scenario:** With `autonomy_enabled=false` (the default), a genuine escalation-worthy TP/Indeterminate finding recorded as `investigation-*.md` yields allow-without-marker at step 1 — no create-review/comment-review marker, no [REVIEW-REQUIRED] Jira ticket. The D-DEC-012 fail-loud invariant ("hard-floor findings never silently dropped; review surfacing executes even under the kill switch") is violated on the markdown path.

**Remediation direction:** Move the kill switch so it gates only the FP/allow-without-marker branch, and let disposition routing run first so non-FP/PARSE_FAIL reaches the review path regardless of autonomy_enabled (mirroring verdict STEP 3 before STEP 5). Since MARKDOWN_COMMENT_PATH is already eliminated (P13-001), the step-1 kill switch is redundant for FP and harmful for non-FP; remove or re-scope it. Add a markdown-path vector: non-FP markdown + autonomy_enabled=false → review marker issued.

### P22-002 — architecture-delta never propagated D-024 (rule 2 = create+link): no decision record, stale comment+link text, and a self-contradictory "do NOT change PC#7b" instruction that BC-4.02.001 nonetheless cites as its authority (MAJOR, confidence HIGH)

**Artifacts / anchors:**
- Decision Summary Table architecture-delta.md:59–77 — rows exist for D-DEC-001..012, D-023, D-025, D-026 but **no D-024 row** (the human decision 2026-07-23 that resolved rule 2 to create+link).
- Stale/contradictory current (non-historical) text in architecture-delta:
  - :152 ("Compound §3.4 actions (comment+link, create+link) …")
  - :1848 emitter comment ("Compound §3.4 actions (rule 2: comment+link; rule 4: create+link) …")
  - :6785 §8.32.4 item 1 ("**§3.4 rule 2 (related — comment+link)**: … verdict-1 ticket_action_type=comment …")
  - :6925, :6927 §8.33.2 item 3 ("Leave rule 2 as-is (comment+link) until human confirms. Do NOT change PC#7b …")
  - :6933 §8.33.3 ("No change required until the HUMAN-GATE-CONFIRM on P19-004 rule-2 adjudication resolves.")
  - :6956 ("(comment+link) pending human confirmation")
- Downstream already correct (create+link): BC-10.01.001:295, :701 (EC-011), :629–644; BC-4.02.001:83 (PC#7b v1.14); dtu-assessment.md:16–29, :319, :362; verification-delta.md:2708–2712, 2837–2840.
- **Mis-anchor:** BC-4.02.001:83 cites "architecture-delta v1.21 §8.33.3" as the authority for the create+link update, but §8.33.3 (:6933) explicitly says "Do NOT change PC#7b."

**Defect:** D-024 is a settled human decision (rule 2 = create+link, parallel to rule 4). Every downstream artifact (BC-4.02.001, BC-10.01.001, dtu v1.3, verification-delta v1.23) implemented it, but the architecture-delta — the decision-record source-of-truth — was never updated: it lacks a D-024 record, still asserts rule 2 = comment+link in three current locations, and still declares the question unresolved with an explicit "do not change PC#7b" instruction. Per the semantic-anchoring rubric, a citation that contradicts the referenced section ("HIGH — mis-anchor contradicts elsewhere in the same document") blocks convergence.

**Concrete failure scenario:** A PO or architect returning to the architecture-delta to re-derive §3.4 behavior finds (a) no D-024 record, (b) a directive at §8.32.4 to build comment+link, and (c) a statement that rule 2 is unresolved. Acting on the architecture-delta as source-of-truth reverts the already-correct create+link behavior in BC-4.02.001/BC-10.01.001 and re-introduces the comment+link/create+link ambiguity.

**Remediation direction:** Add a D-024 row to the Decision Summary Table (RESOLVED — rule 2 = create+link, human decision 2026-07-23). Update :152, :1848, :6785 to create+link. Rewrite §8.33.2 item 3 and §8.33.3 to record the resolution (interpretation b) rather than "defer / do not change." Fix BC-4.02.001:83 to cite the new D-024 record.

### P22-004 — VP-SKILL-062 never-auto-reopen assertion references a non-existent `jr issue reopen` verb, making the safety-invariant test vacuously true (P21-003 fix applied to DTU/BC-4.02.001 but not to this sibling) (MEDIUM, confidence MEDIUM)

**Artifacts / anchors:**
- BC-10.01.001:742 — "VP-SKILL-062 | Never-auto-reopen-closed: a Closed Jira ticket … never receives a **jr issue reopen** command …"
- Ground-truth verb list: there is **no** `jr issue reopen` (and no `jr issue transition`); reopening is expressible only as `jr issue move <key> <non-close-state>`.
- Correctly-phrased siblings: BC-4.02.001:132 VP-SKILL-066 uses `jr issue move`; dtu-assessment.md:22–24 (P21-003) replaced the non-existent verb with `jr issue move` to a non-close state.

**Defect:** The never-auto-reopen guarantee is safety-critical, but VP-SKILL-062's described assertion keys on a verb (`jr issue reopen`) that the CLI does not emit. A test/mutant asserting the absence of `jr issue reopen` can never fail — it provides zero regression coverage for the real reopen risk (`jr issue move` to an open state). The P21-003 correction was propagated to the DTU and to BC-4.02.001's VP-SKILL-066 but not to this sibling VP row (partial-fix / sibling-propagation gap, S-7.01).

**Concrete failure scenario:** A future refactor that lets the loop emit `jr issue move SEC-123 "In Progress"` (reopen) on a Closed ticket would violate the never-auto-reopen invariant, yet the VP-SKILL-062 vector as described would still pass green.

**Remediation direction:** Restate VP-SKILL-062 to assert no `jr issue move <key> <state>` targeting a non-terminal/open state is emitted for a Closed/Resolved ticket (mirroring VP-SKILL-066 / DTU P21-003), and confirm the backing BATS assertion targets the `jr issue move` mechanism, not the non-existent `reopen` verb.

---

## Observations

- **P22-005 (MINOR, confidence HIGH) — EC-026 direction (A) carries a muddled mechanism attribution with an editorial artifact.** BC-3.01.001:386 EC-026(A) describes a `["comment"]` marker in the store but then reasons about the *link* command_pattern ("does NOT match … — wait, command does match; step (6) exact-type check …"). For a `["comment"]` marker the correct enforcement is the step-5 command_pattern mismatch (comment pattern vs a link command); the "wait, command does match" clause conflates the marker's pattern with the command shape. The final verdict (deny) is correct, but the mechanism attribution is wrong and includes a stray self-correction. Tidy to: step-5 anchored match fails because the `["comment"]` marker's pattern is the comment pattern, which does not match `jr issue link …`. No behavioral impact.

- **CLI-surface note (INTACT, see below) — reopen cannot be smuggled through a `["close"]` marker.** The close command_pattern anchors on a regex-escaped `close_state ∈ {Done,Closed,Resolved}` (architecture-delta.md:1944–1959), so a `jr issue move <key> <open-state>` command matches no close marker and is denied — the never-auto-reopen guarantee holds at the consumer independent of VP-SKILL-062's wording (P22-004).

## Surfaces re-derived and found INTACT

- **STEP 4b close-disposition hoist (D-025/P20-001):** correctly positioned before STEP 5, fires for all autonomy_enabled values; STEP-6 check retained as defense-in-depth; EC-022 encodes the full 3-condition AND (architecture-delta.md:1733–1769, 1900–1926; BC-10.01.001:712). Coherent with D-023/D-025.
- **Close anti-fungibility and close-state allowlist:** `["close"]` marker binds `jr issue move <ticket_id> <close_state>` only; cross-type and reopen-state commands denied (BC-3.01.001 EC-027; architecture-delta.md:1944–1959).
- **Consumer anti-fungibility (create/create-review, link, close):** step-5 anchored match + step-6 exact-type + step-6a quote-aware/backslash-escape tokenizer are internally consistent (BC-3.01.001:102–235, EC-023/024/025/026/027).
- **Write-block completeness for the write verbs in scope:** `comment/edit/move/assign/create/link` (12 entries, plain + `--output json`) are blocked; `unlink` and `remote-link` are neither authorized by any marker scope nor allowlisted and fall to the fail-closed catch-all (deny); the `jr issue link ` trailing-space guard does not collide with `unlink`, `remote-link`, or the read verb `link-types` (BC-3.01.001:68, 336).
- **Dedup and D-026 read verbs:** `jr issue list --jql` (dedup) and `jr issue view … --output json` (Relates(O,C) absence) are real verbs and are allowlisted; `jr issue search`/`jr issue transition` correctly eliminated (BC-3.01.001:313, 328; BC-10.01.001:234; dtu-assessment.md:23–29).
- **D-026 fail-closed read semantics:** a `jr issue view` read that cannot confirm Relates presence causes D-026 not to fire and falls through to rule-1 (comment on the open ticket) — a bounded, self-correcting fallback (does not create an unverified link). Sound *except* where it interacts with P22-003 (hard-floor link denial), which is captured there.
- **Marker-write fail-closed asymmetry (P10-003):** review-path write failure denies; regular-path write failure allows-without-marker (human gate preserved) — coherent (architecture-delta.md:1962–2014).

## Novelty Assessment

Novelty: **HIGH.** The findings are substantive control-flow/coherence gaps, not rewording: P22-003 is a structural unreachability of a mandated postcondition (BLIND-SPOT create+link) discovered by tracing the `link` REGULAR-scope through STEP 4; P22-001 is a fresh instance of the D-025 ordering pathology on the markdown path that no fix addressed; P22-002 is a source-of-truth propagation failure isolated to the one artifact that all others cite. These are not nitpicks and each blocks convergence.

**RESULT: 1C / 2M / 1med / 1m / 2 obs**

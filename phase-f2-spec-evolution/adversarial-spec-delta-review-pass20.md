---
review: Adversarial Spec-Delta Review — Pass 20
pass: 20
date: 2026-07-27
reviewer: adversary (fresh context; no prior-pass knowledge)
feature_cycle: v0.10.0-feature-prism-integration
perimeter:
  - phase-f2-spec-evolution/architecture-delta.md (v1.21)
  - phase-f2-spec-evolution/verification-delta.md (v1.21)
  - phase-f2-spec-evolution/prd-delta.md (v1.19)
  - phase-f2-spec-evolution/dtu-assessment.md (v1.2)
  - phase-f2-spec-evolution/feature/prism-integration-handoff-brief.md
  - phase-f2-spec-evolution/spec-changelog.md
  - behavioral-contracts/BC-3.01.001.md (v1.23), BC-3.03.001.md (v1.28),
    BC-4.02.001.md (v1.14), BC-4.05.001.md (v1.4), BC-5.01.001.md (v1.12),
    BC-6.01.001.md (v1.8), BC-6.01.003.md (v1.7), BC-6.01.004.md (v1.1),
    BC-8.02.001.md (v1.4), BC-9.01.001.md (v1.2), BC-10.01.001.md (v1.22)
---

# Adversarial Review — Pass 20 (F2 spec-evolution, prism-integration)

## Methodology

I re-derived the emitter/consumer marker contract, the close/link/compound
authorization model (D-020/D-021/D-022/D-023/D-024), and the hard-floor/kill-switch
ordering directly from the emitter pseudocode in BC-3.03.001 §Invariant #4 and its
mirror in architecture-delta §8.32.7/§8.33, then cross-checked the guarantees against
verification-delta VP-HOOK-035/036 and against BC-10.01.001 §3.4 edge cases and
canonical test vectors. I independently confirmed all 11 in-scope BC frontmatter
versions against the prd-delta §5 version-mapping table and burst notes. I attacked:
(a) the STEP-ordering of the D-023 close-disposition gate relative to the STEP-5 kill
switch; (b) the traceability of the "EC-013 = 3-condition AND" reference; (c) the
implementability of the P19-002 orphan-link reconciliation predicate against the
stateless §3.4 dedup; (d) version/EC propagation between the delta docs and the BCs;
(e) whether every marker-authorized `jr` verb has a corresponding marker scope.

Because D-023 and D-024 are settled human decisions, I did not re-litigate the
decisions — I attacked whether the specs implement them coherently and completely.

---

## Critical Findings

None.

---

## Major Findings

### P20-001 [MAJOR, confidence HIGH] — D-023 close-disposition gate is unreachable when `autonomy_enabled≠true`, contradicting the decision's "fires regardless of autonomy_enabled" mandate

**Artifacts:**
- `BC-3.03.001.md` STEP 5 kill switch lines 465–468; STEP 6 header line 474; close branch (`ELIF action == "close"`) + D-023 gate lines 572–593; narrative lines 578–579; generation-table close row line 756.
- `architecture-delta.md` STEP 5 lines 1739–1742; SECURITY RECAP lines 1843–1851; D-023 gate lines 1853–1879 (esp. line 1848 vs 1860–1861); D-023 decision record line 73.
- `verification-delta.md` VP-HOOK-035 lines 2677–2679, 2769–2771.

**The defect.** The D-023 disposition gate (`IF verdict.disposition NOT IN {"FP","BTP"} → CLOSE-DISPOSITION-DENY`) is placed as the first check **inside the STEP 6 close branch**. STEP 6 is only reached after STEP 5 returns; STEP 5 is the `autonomy_enabled` kill switch:

```
STEP 5:  IF autonomy_enabled is NOT exactly boolean true: emit allow without marker; RETURN
STEP 6:  ... ELIF action == "close": IF verdict.disposition NOT IN {FP,BTP}: CLOSE-DISPOSITION-DENY ...
```

Therefore, when `autonomy_enabled` is false/absent (the **default**, kill-switch-on), a verdict with `disposition=TP` and `ticket_action_type=close` exits at STEP 5 with **allow-without-marker** and never reaches the D-023 gate. Yet both artifacts explicitly assert the opposite:
- BC-3.03.001 line 578–579: *"Gate fires REGARDLESS of autonomy_enabled — a TP/Indeterminate close is wrong even if the kill switch is ON."*
- architecture-delta line 1860–1861: *"Gate fires REGARDLESS of autonomy_enabled — a TP/Indeterminate close is wrong even with the kill switch ON,"* while the adjacent line 1848 states *"autonomy_enabled=false → STEP 5 kill switch fires BEFORE this point → no marker."* Lines 1848 and 1860 are directly self-contradictory.
- VP-HOOK-035 (verification-delta 2770–2771): CLOSE-DISPOSITION-DENY *"as the FIRST close-branch check, regardless of autonomy_enabled/scored_priority."*

The spec already demonstrates how to make a check fire "regardless of autonomy_enabled": **STEP 4** (hard-floor DENY-THE-WRITE) is deliberately placed *before* STEP 5 (BC-3.03.001 line 428: *"STEP 4 remains BEFORE STEP 5 kill switch — deny fires before kill switch"*). The D-023 gate was **not** given the same treatment.

**Failure scenario (default config).** `autonomy_enabled=false`; monitoring-loop LLM mislabels a genuine `disposition=TP` alert with `ticket_action_type=close`, `scored_priority=LOW` (non-hard-floor). Emitter path: STEP 3 (not review) skip → STEP 4 `hard_floor_applies()=false` skip → STEP 5 kill switch fires → **allow-without-marker, RETURN**. The D-023 gate never executes: **no `CLOSE-DISPOSITION-DENY` audit entry is written, and the verdict Write is allowed rather than denied.** The specific fail-loud deny + corrective-reason + audit trail that D-023 mandates "regardless of autonomy_enabled" is silently omitted in the default deployment, and VP-HOOK-035's stated assertion is unverifiable for the `autonomy_enabled=false` case (a conforming emitter would produce allow-without-marker, not CLOSE-DISPOSITION-DENY).

Note the physical safety invariant *"TP is never auto-closed"* is still preserved by defense-in-depth: no close marker is written, so require-review denies the downstream `jr issue move`. This is why the finding is MAJOR, not CRITICAL. But D-023 as a settled decision is **not implemented as stated**, and the two artifacts contain an irreconcilable internal contradiction about a security-critical gate.

**Remediation direction.** Hoist the D-023 disposition check to fire **before** STEP 5 (mirroring STEP 4's placement) — e.g., an early `IF action == "close" AND verdict.disposition ∉ {FP,BTP} → CLOSE-DISPOSITION-DENY` guard — so the gate truly fires regardless of `autonomy_enabled`. Alternatively, if the decision owners accept that the kill switch already prevents the close when `autonomy_enabled=false`, then D-023's "fires regardless of autonomy_enabled" / "even with the kill switch ON" language (BC-3.03.001 578–579; arch 1848 vs 1860; VP-HOOK-035) must be corrected to describe the STEP-6 reality. The current state — narrative claiming X, adjacent pseudocode guaranteeing ¬X — cannot ship.

---

## Medium Findings

### P20-002 [MEDIUM, confidence HIGH] — "EC-013 = close 3-condition AND" is a dangling mis-anchor; no BC's EC-013 encodes the close 3-condition AND

**Artifacts:**
- D-023 decision (per architecture-delta §8.33 line 73 and the propagation instruction §8.33.2 item 1, line 6855) and verification-delta lines 2686, 2770 ("EC-013 restored to the 3-condition AND"), 2686 ("restores EC-013's 3-condition AND in BC-10.01.001").
- Actual EC-013s: `BC-10.01.001.md:693` = "Closed ticket (same root cause) → create+link (D-022 rule 4)"; `BC-6.01.001.md:226` = "jira_project_key absent at activate time"; `BC-3.01.001.md:372` = "CMDB query allow".

**The defect.** architecture-delta §8.33.2 item 1 instructs the PO to *"update EC-013 or any §3.4 auto-close invariant [in BC-10.01.001] to the full 3-condition AND,"* and verification-delta asserts *"EC-013 restored to the 3-condition AND in BC-10.01.001."* But BC-10.01.001's EC-013 is the **Closed-ticket create+link** edge case, which has nothing to do with auto-close. Grep of all behavioral contracts confirms **no BC has an EC-013 (or any numbered EC) that encodes the close 3-condition AND**. The 3-condition AND logic exists only in BC-10.01.001's unlabeled canonical test vectors (`BC-10.01.001.md:716` FP auto-close; `:717` TP→CLOSE-DISPOSITION-DENY) and in the emitter pseudocode.

**Why it matters.** A verifier or implementer directed by D-023 / verification-delta to "EC-013's 3-condition AND in BC-10.01.001" lands on the create+link edge case and finds no auto-close condition — a traceability-row-vs-target mismatch. Per the mis-anchoring rule, a traceability reference whose description does not match the target artifact's actual content blocks convergence.

**Remediation direction.** Either add a properly numbered EC in BC-10.01.001 stating the close 3-condition AND (`disposition∈{FP,BTP}` AND `hard_floor_applies()=false` AND `autonomy_enabled=true`) and repoint the D-023/verification-delta references to it, or correct the "EC-013" references to cite the actual anchor (the auto-close canonical test vectors / EC-009 floor-exemption text).

### P20-003 [MEDIUM, confidence MEDIUM] — Orphan-link reconciliation (P19-002) relies on a detection predicate that is unimplementable from stateless loop state and contradicts §3.4 dedup routing

**Artifact:** `BC-10.01.001.md` lines 627–636 (Stage-8 link-path orphan reconciliation).

**The defect.** For compound create+link (rule 2 and rule 4), if verdict-1 (create) lands but verdict-2 (link) does not (crash/timeout between the two Writes), the spec says: *"on the subsequent loop run, when §3.4 dedup identifies an open ticket lacking the expected 'Relates' link to its matching closed or related ticket → loop MUST re-issue the link verdict ONLY."* But:

1. The loop is stateless across runs (only watermarks persist). After a crash between the two Writes, the intent "NEW_KEY should link to CLOSED_KEY/related_KEY" is lost.
2. Standard §3.4 dedup, re-run against the same alert, now sees the **orphan-created open ticket** as an open ticket with the same root cause → this matches **rule 1 (duplicate-open → append comment, PC#7a/EC-010)**, not a "missing-link" condition. Nothing in §3.4 rules 1–4 defines a predicate "an open ticket + a closed/related ticket sharing a root cause but lacking a Relates link → re-link them."
3. So the described reconciliation requires a **new correlation capability** (link-graph inspection + orphan attribution) that is neither specified in §3.4 nor derivable from available state.

**Failure scenario.** Rule 4: a Closed ticket exists; verdict-1 creates NEW_KEY; loop crashes before writing verdict-2. Next run: §3.4 dedup finds the now-open NEW_KEY (same root cause) and routes to rule 1 → appends a comment to NEW_KEY. The Relates link to the Closed ticket is **never created** — the correlation the compound action existed to establish is silently and permanently lost.

**Remediation direction.** Specify the orphan-detection predicate concretely (e.g., a persisted "pending-link" marker/queue, or an explicit §3.4 rule: "open ticket O with same root cause as a Closed/Resolved ticket C AND no Relates(O,C) link ⇒ issue link-only verdict, do not comment"), and reconcile it with rule-1 precedence so the orphan is not misclassified as a plain duplicate-open. VP-HOOK-036 / SM-68 cannot verify a predicate the behavioral spec does not define.

### P20-004 [MEDIUM, confidence HIGH] — prd-delta §5 "New Version" column is stale for the three pass-19/burst-16 BCs (drift vs actual BC frontmatter)

**Artifact:** `prd-delta.md` §5 table (lines 120–122) vs BC frontmatter.

**The defect.** The §5 version-mapping table — the canonical "old→new" summary — shows:
- BC-3.03.001 "New Version" = **v1.27**; actual frontmatter = **v1.28**.
- BC-10.01.001 "New Version" = **v1.21**; actual frontmatter = **v1.22**.
- BC-4.02.001 "New Version" = **v1.13**; actual frontmatter = **v1.14**.

The burst-16 note (line 135) restates the correct versions (v1.28/v1.22/v1.14) but — unlike every prior burst note ("version columns updated above") — did not propagate them into the §5 "New Version" cells. This under-represents the current state of BC-3.03.001, whose v1.28 change is the D-023 CRITICAL close-disposition gate.

**Remediation direction.** Update the three §5 "New Version" cells to v1.28 / v1.22 / v1.14 to match frontmatter.

---

## Minor Findings

### P20-005 [MINOR, confidence HIGH] — BC-6.01.003 is at v1.7 but prd-delta documents it only through v1.5

`BC-6.01.003.md` frontmatter/revision-history show v1.6 (P14-005 AD-017 VP-orphan) and v1.7 (burst-10-followup VP-SKILL-076/077 disentangle). prd-delta's burst notes track BC-6.01.003 only to v1.5 (burst-9/pass-13). The v1.6/v1.7 bumps are VP-anchor-only (arguably FV-owned per the doc's "VP changes are FV-owned" convention), but the two-version gap is undocumented in prd-delta, so the prd-delta cannot be relied on as the version-of-record for this BC. Add a burst note or footnote reflecting v1.6/v1.7.

### P20-006 [MINOR, confidence HIGH] — prd-delta Document Changelog is missing its own v1.19 row

`prd-delta.md` frontmatter declares `version: "1.19"` and the burst-16 note states *"prd-delta v1.18→v1.19,"* but the Document Changelog table's top row is v1.18 (line 262). There is no v1.19 changelog entry describing what changed at v1.19. Add the v1.19 row.

### P20-007 [MINOR, confidence MEDIUM] — BC-4.02.001 Invariant #1 claims `jr issue move` status transitions are marker-authorized, but no marker scope produces a non-close `jr issue move` pattern

`BC-4.02.001.md:87` states `jr issue move` is *"authorized both for status transitions (e.g., 'Enriched') via prior marker mechanisms AND for close operations via the ["close"] marker scope."* The v2.2 `authorized_operations` enum is `{comment, create, assign, create-review, comment-review, link, close}`; only `["close"]` emits a `jr issue move` command_pattern, and that pattern binds the state to `CLOSE_STATE_ALLOWLIST = {Done, Closed, Resolved}` (BC-3.03.001 line 624; consumer step 6 `BC-3.01.001.md:114`). A move to a non-allowlisted status such as "Enriched" matches no marker pattern and is fail-closed denied by require-review. The "authorized … via prior marker mechanisms" claim for status-transition moves is therefore unsupported; either such transitions are human-gated (in which case the invariant wording is misleading) or they are silently un-executable autonomously. Clarify the wording or specify the scope that authorizes non-close moves.

---

## Observations

- **P20-008 [OBSERVATION]** — `verification-delta.md:2812` (inside the v1.20 / pass-18 changelog block) still defines *"compound §3.4 actions (rule 2 comment+link; rule 4 create+link)."* D-024/P19-004 (v1.21) supersedes this: rule 2 is now **create+link**, correctly stated in the v1.21 changelog entry (lines 2778–2780). Because line 2812 sits in a dated historical changelog block it is arguably a preserved record, but the coexistence of "rule 2 comment+link" and "rule 2 create+link" in the same document body invites reader confusion. Consider annotating the pass-18 line `[superseded by P19-004 — rule 2 is now create+link]`.

- **P20-009 [OBSERVATION] [process-gap]** — The D-023 gate-placement contradiction (P20-001) is a *narrative-vs-pseudocode* inconsistency in which surrounding prose asserts a control-flow property (fires regardless of autonomy_enabled) that the adjacent pseudocode structurally cannot deliver. This class survived into pass 20 because prior passes verified the gate's *content* (the disposition check exists, SM-66 targets it) without verifying its *reachability* against the STEP-4/STEP-5/STEP-6 ordering. An adversarial axis that traces each "fires regardless of X" / "always" / "unconditional" claim to its guarding control-flow position (does an earlier `RETURN` short-circuit it?) would have caught this. Recommend adding a "reachability-of-guarantee" check to the emitter-ordering review axis.

---

## Surfaces Re-derived and Found INTACT

- **Marker schema v2.2 anti-fungibility (link/close):** `["link"]` accepts only `jr issue link KEY1 KEY2`; `["close"]` accepts only `jr issue move <ticket_id> <allowlisted_state>`; bidirectional isolation from comment/create/assign/review scopes (BC-3.01.001 lines 113–115; BC-3.03.001 line 729). Could not construct a cross-scope fungibility path.
- **O7 charset-validation completeness:** all 9 interpolation sites (comment/create/assign ticket_id+project_key, link KEY1+KEY2, close ticket_id + close_state) charset-validate then `regex_escape()` before pattern construction (BC-3.03.001 line 762). A `ticket_id=".*"` / `link_target=".*"` injection is denied (TICKET-ID/LINK-TARGET/PROJECT-KEY/CLOSE-STATE-CHARSET-DENY). Intact.
- **close-state defense-in-depth:** setup-time validation (BC-6.01.001 Postcondition #13, lines 160–190) + emit-time re-check against `CLOSE_STATE_ALLOWLIST` (BC-3.03.001 lines 610–623) + regex-escape; `jira_close_state` is CONFIG-side, not verdict-influenceable. Allowlist `{Done,Closed,Resolved}` consistent across BC-6.01.001, BC-3.03.001, architecture-delta, dtu-assessment. Intact.
- **HIGH/CRIT never auto-closed:** close is REGULAR scope; `hard_floor_applies()` on `scored_priority∈{HIGH,CRIT}` triggers STEP-4 DENY-THE-WRITE before the close branch → routes to comment-review (BC-3.03.001 line 756; BC-10.01.001 lines 637–644). Intact.
- **JSON-first dispatch collision fix:** `.json`/JSON-content routes to the 18-field verdict path regardless of `investigation` substring (BC-3.03.001 PC#1, VP-HOOK-028). Intact.
- **Kill-switch determinism + STEP-4-before-STEP-5 ordering** for hard-floor and review paths (BC-3.03.001 lines 428, 449–468). Intact (except the D-023 close gate — see P20-001).
- **Iterative-consume FIFO single-use / atomic-rename / 120s absolute-expiry TTL / future-dated-marker rejection / path-traversal skip** (BC-3.01.001 lines 88–92, 242–276). Intact.
- **create-scope org-binding anchoring** (`--project` first arg, trailing `( |$)`, no `.*`), preventing ORG-A→ORG-B / ORG-A→ORG-A_EXTRA fungibility (BC-3.03.001 lines 679–685; BC-3.01.001 lines 93–100). Intact.
- **11/11 BC frontmatter versions** otherwise consistent with prd-delta (only the three §5 cells in P20-004 drift).

---

## Novelty Assessment

Novelty MEDIUM. P20-001 (D-023 gate reachability vs the "regardless of autonomy_enabled" mandate) and P20-002 (dangling EC-013 anchor) are substantive, newly-surfaced defects in the most-recently-changed surface (D-023/D-024, burst-16/pass-19) rather than rewordings of converged issues. P20-003 (orphan-link predicate) is a genuine implementability gap in P19-002. The remaining findings are version/EC propagation drift. This is not a converged pass — the newest decisions (D-020..D-024) introduced fresh control-flow and traceability surface that has not fully settled.

## Verdict

**RESULT: 0C / 1M / 3med / 3m / 2 obs** — NOT CLEAN (1 Major + 3 Medium).
Blocking items: P20-001 (MAJOR), P20-002, P20-003, P20-004 (MEDIUM).

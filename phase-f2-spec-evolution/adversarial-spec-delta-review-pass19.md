---
document_type: adversarial-review
pass: 19
producer: adversary
date: 2026-07-23
cycle: v0.10.0-feature-prism-integration
phase: f2
verdict: NOT-CLEAN (1 CRITICAL, 1 MINOR, 2 OBSERVATION)
---

# Adversarial Review — Pass 19 (F2 spec-evolution delta; burst-15 D-020/D-021/D-022 focus)

## Summary Table

| ID | Severity | Surface | Title |
|----|----------|---------|-------|
| P19-001 | **CRITICAL** | D-021 CLOSE | Close emitter branch omits the `disposition ∈ {FP,BTP}` gate — a non-FP/BTP (TP) verdict scored LOW/MED is auto-closed under `autonomy_enabled=true` |
| P19-002 | MINOR | D-022 COMPOUND | No partial-failure / orphan-recovery specification for the two-Write create+link (and comment+link) sequence; no covering VP |
| P19-003 | OBSERVATION | D-021 CLOSE | `jira_close_state` is the sole `command_pattern` interpolation value with neither emit-time allowlist re-validation nor `regex_escape()`; relies entirely on temporally-distant setup-time validation |
| P19-004 | OBSERVATION | D-022 COMPOUND | §3.4 rule-2 compound is modeled as `comment+link` (no create) yet rule 2 is "different root cause / keep tickets separate" — ticket provenance of KEY1/KEY2 is under-specified (pending intent verification) |

**This is NOT a clean pass.** One CRITICAL finding blocks convergence.

---

## Critical Findings

### P19-001 — CLOSE emitter branch does not enforce the `disposition ∈ {FP,BTP}` leg of the D-021 close gate
**Severity: CRITICAL** · **Confidence: HIGH**

**Anchors (all three surfaces confirm the same hole):**
- `architecture-delta.md` v1.20 — emitter pseudocode `ELIF action == "close"`, lines **1830–1862** (no disposition check).
- `architecture-delta.md` v1.20 — `hard_floor_applies()`, lines **2161–2199** (only `disposition=="Indeterminate"` is a floor; TP/FP/BTP all pass when scored LOW/MED).
- `BC-3.03.001.md` v1.27 — normative emitter `ELIF action == "close"`, lines **571–590** (charset-validate + config close-state + `ops=["close"]`; **no `disposition` check**).
- `verification-delta.md` v1.20 — VP-HOOK-035 catalog text (lines ~2634–2646, ~2712–2718): asserts close "issued **ONLY for FP/BTP** + non-hard-floor + autonomy_enabled=true", but paired mutants are **SM-61 (hard-floor bypass), SM-62 (kill-switch), SM-63 (close-state allowlist), SM-64 (ticket_id charset)** — there is **no mutant for a missing FP/BTP disposition gate**.
- `architecture-delta.md` §8.32 propagation, line **6696**: the constraint propagated to EC-013 is written as "close marker is issued ONLY when `hard_floor_applies()=false` AND `autonomy_enabled=true`" — **the FP/BTP leg is dropped from the enforceable statement**, matching the code.

**Description.**
The D-021 close gate is specified as a three-condition AND: (1) `disposition ∈ {FP,BTP}`, (2) `hard_floor_applies()=false`, (3) `autonomy_enabled=true`. The disposition-guard emitter deterministically enforces (2) via STEP 4 and (3) via STEP 5, but **never enforces (1)**. The `close` branch (STEP 6) validates only `ticket_id` charset and reads the config close-state; it issues a `["close"]` marker for *any* verdict whose `ticket_action_type=="close"` that survived STEP 4 and STEP 5. `ticket_action_type` is an LLM-supplied routing field.

`hard_floor_applies()` treats **only `disposition=="Indeterminate"`** as a disposition-based floor. A **TP** verdict is not a floor. Therefore a verdict with `disposition="TP"`, `scored_priority="LOW"` (or MED), `asset_type="standard"`, no forbidden technique, `sensor_health_status="healthy"`, `autonomy_enabled=true`, and `ticket_action_type="close"` flows: STEP 1 enum OK (`close` is in `ACTION_ENUM`) → STEP 1a consistency OK → STEP 3 skipped (not a review action) → **STEP 4 `hard_floor_applies()` returns FALSE** → STEP 5 kill switch passes (`autonomy_enabled=true`) → **STEP 6 `close` branch issues a `["close"]` marker** → require-review consumes it → `jr issue move <ticket_id> Done` executes → **the confirmed-malicious ticket is auto-closed.**

This directly contradicts:
- D-021 stated constraint "close marker issued **ONLY for FP/BTP**" (arch-delta line 1279; handoff-brief §3.3 D-021 note).
- Brief §3.3 disposition table: **TP → Create/escalate**, never close.
- Brief §3.9: "**auto-closing is the highest-risk automation**."

**This is a regression of the project's own established security discipline.** The O3 standing rule (arch-delta line 1487: "every LLM-supplied routing field that grants or bypasses a security control MUST be cross-validated against a hook-computed invariant") was codified precisely to fix this class (P5-002 over-label gate; P10-001/P11-001 trust-basis). The close branch reintroduces the anti-pattern: it trusts the LLM-supplied `ticket_action_type=close` to imply an FP/BTP disposition, with no hook-side cross-check against `verdict.disposition`.

**Not covered by a tracked deferral.** ASM-008-DEFERRED covers the *truthfulness* of `native_severity`/`sensor_family`/`asset_type`/`scored_priority` values. This finding is different in kind: it is a missing **disposition↔action coherence** check. Even with a perfectly honest `scored_priority=LOW`, a TP must never be auto-closed. No deferral, VP, or SM covers this.

**Concrete failure scenario.**
`prism`-ingested content influences the loop to emit a verdict: `disposition="TP"`, `scored_priority="LOW"`, `asset_type="standard"`, `sensor_health_status="healthy"`, `attack_techniques=[]`, `autonomy_enabled=true`, `ticket_action_type="close"`, `ticket_id="PRISMDEMO-42"`, `severity`/`native_severity`/`sensor_family` internally consistent. disposition-guard issues a `["close"]` marker; require-review permits `jr issue move PRISMDEMO-42 Done`. A real threat's ticket is silently closed. An operator watching audit.log sees an ordinary authorized close — no deny, no review flag.

**Blast-radius (honest scoping).** The dangerous escalations — HIGH/CRIT `scored_priority`, `Indeterminate`, critical/unknown `asset_type`, forbidden techniques (T1003/T1068/T1021/T1041), degraded/silent sensor — are all caught by `hard_floor_applies()` STEP 4. The exploitable window is therefore LOW/MED-scored, standard-asset, benign-technique, healthy-sensor, autonomy-enabled, non-FP/BTP verdicts. Bounded — but auto-closing a confirmed-malicious ticket is exactly the headline risk the design exists to prevent, and it is reachable via a single LLM-controlled field.

**Suggested remediation.**
1. Add a hook-computed disposition gate to the close branch in **BC-3.03.001** (line ~571) and **architecture-delta** (line ~1830), before marker issuance:
   `IF verdict.disposition NOT IN {"FP","BTP"}: WRITE audit "CLOSE-DISPOSITION-DENY: close authorized only for FP/BTP, got <disposition>"; emit deny(...); RETURN`.
   (Equivalently, fold it into `hard_floor_applies()` as a close-specific pre-check, or gate STEP 6's `close` branch entry.)
2. Add a paired SM mutant (e.g., SM-66 `close-disposition-gate-removed`) and extend **VP-HOOK-035** with the property "a `["close"]` marker is NOT issued for `disposition ∈ {TP,Indeterminate}`" and a BATS vector: `disposition=TP + scored_priority=LOW + ticket_action_type=close + autonomy_enabled=true → verdict Write DENIED, no close marker`.
3. Restore the FP/BTP leg to the EC-013 propagated constraint (arch-delta line 6696) so the enforceable statement matches D-021.

---

## Important Findings

*(none at MAJOR)*

---

## Minor Findings

### P19-002 — D-022 compound sequence has no partial-failure / orphan-recovery specification; VP-HOOK-036 covers only ordering + single-use
**Severity: MINOR** · **Confidence: HIGH**

**Anchors:** `architecture-delta.md` §8.32 items (lines **6680, 6688**), `BC-4.02.001.md` v1.13 EC-008 (line 107) / rule-2 vector (line 120) / PC#7d; `verification-delta.md` VP-HOOK-036 (compound = two sequential single-use Writes, SM-65 single-marker-authorizes-both).

**Description.** The D-022 Iron Law specifies only *ordering* ("verdict-2 link MUST be written after `jr issue create` returns a valid key"). It does not specify recovery when verdict-1 (create) succeeds and verdict-2 (link) never lands — process interruption between Stage-8 create and the Stage-7 link Write, or a subsequent link Write that is denied. Result: a NEW ticket exists, unlinked to the CLOSED/related ticket. On the next loop run, §3.4 dedup finds the now-open NEW ticket and routes to `comment` (not re-create), so the finding is not lost and no duplicate create occurs — **but the "related"/successor link to the old ticket is silently never established**. VP-HOOK-036 verifies the single-use/ordering property and SM-65 (single-marker-both-writes); **no VP covers the create-succeeded/link-missing orphan path.**

**Failure scenario.** Rule 4 (closed→new+link): `jr issue create` returns `PRISMDEMO-77`; the loop crashes (cron timeout / NFR-PERF-003 window exceeded) before writing the link verdict. `PRISMDEMO-77` persists with no `Relates` link to the closed `PRISMDEMO-12`. The audit trail shows a create but no link; nothing flags the missing relationship.

**Remediation.** Specify (BC-10.01.001 Stage-7/§3.4) an idempotent reconciliation: on a subsequent run, when dedup finds an open ticket for the alert root-cause that lacks the expected `Relates` link to a matching closed/related ticket, re-issue the link verdict. Add a VP (or extend VP-HOOK-036) asserting orphan-link reconciliation. Non-security; finding is preserved either way — hence MINOR.

---

## Observations

### P19-003 — `jira_close_state` interpolation relies solely on setup-time validation; no emit-time re-check or escape [defense-in-depth]
**Severity: OBSERVATION** · **Confidence: HIGH**

**Anchor:** `BC-3.03.001.md` v1.27 lines **586–588** (`jira_close_state = get_jira_close_state_from_config()`; interpolated into `pattern` with **no `regex_escape()` and no emit-time `∈ CLOSE_STATE_ALLOWLIST` assertion**); contrast line 587 where `ticket_id` *is* `regex_escape`-d.

Every other `command_pattern` interpolation site is charset-validated **and** `regex_escape`-d at emit time (the O7 standing rule, BC-3.03.001 line 649). `jira_close_state` is the one exception: it depends entirely on onboard-time validation (BC-6.01.001 PC#13) against `{Done,Closed,Resolved}`, with emit-time use temporally separated from that validation. The three allowlisted values are regex-safe, so this is not currently exploitable, and the value is genuinely config-side (not LLM-influenceable). But the safety is brittle: config drift after setup, or a future allowlist addition containing whitespace/metacharacters, would silently break the anchor. Also note the architecture-delta pseudocode uses `read_config(..., default="Done")` (line 1859) while the normative BC uses `get_jira_close_state_from_config()` with no default shown — the empty/missing-config behavior is unspecified in the BC. **Recommend** a cheap emit-time assert `IF jira_close_state NOT IN CLOSE_STATE_ALLOWLIST: deny` as defense-in-depth, and pin the missing-config default. Not blocking.

### P19-004 — §3.4 rule-2 compound modeled as `comment+link` (no create) conflicts with "different root cause / keep tickets separate" [pending intent verification]
**Severity: OBSERVATION** · **Confidence: LOW**

**Anchors:** brief §3.4 rule 2 ("Related … different root cause … Link as related. Keep tickets separate"); `architecture-delta.md` line **6686** and `BC-4.02.001.md` line **120** (rule-2 compound = verdict-1 `comment` on KEY1 + verdict-2 `link` KEY1↔KEY2, **no create step**).

The rule-2 two-Write model comments on KEY1 and links KEY1↔KEY2, which presupposes **both** tickets already exist. But rule 2 fires for a *new alert with a different root cause* on the same asset — under "keep tickets separate," that alert should get its own ticket (implying a create). The compound model has no create leg for rule 2, leaving the provenance of KEY1/KEY2 under-specified: is KEY1 this alert's pre-existing ticket, or the related one? If the new alert has no ticket yet, rule 2 as specified links two tickets while leaving the new finding captured only as a comment on a different-root-cause ticket — the opposite of "keep separate." This touches the newly-reworked compound surface but overlaps pre-existing §3.4 loop semantics; I cannot adjudicate authorial intent. Flagging for PO/human to confirm whether rule 2 should be `create+link` (parallel to rule 4) or whether it correctly assumes both tickets pre-exist. Tag: (pending intent verification).

---

## Coverage Narrative

I re-derived the three new surfaces end-to-end from ground truth (I did not inherit prior-pass conclusions).

**D-020 LINK — attacked, satisfied.** Emitter link branch (BC-3.03.001 lines 533–569; arch-delta 1792–1828): both KEY1 (`ticket_id`) and KEY2 (`link_target_ticket_id`) are charset-validated against `^[A-Z][A-Z0-9]+-[0-9]+$` and `regex_escape`-d before interpolation (O7 sites 3 and 8); absent KEY2 → `LINK-TARGET-MISSING` deny; pattern is fully anchored with trailing `( |$)` guarding KEY2 prefix-extension; no `--type` (Iron Law). Consumer (BC-3.01.001 lines 113, 417–418): `jr issue link` is write-blocked (SM-57), `["link"]` accepted only for the anchored `jr issue link KEY1 KEY2` command, bidirectional anti-fungibility EC-026 (comment↛link and link↛comment cross-type denies present). A forged/broadened/cross-consumed link marker cannot authorize an unrelated command. **No forge/broaden/cross-consume hole found.** Hard-floor link verdicts correctly divert to review at STEP 4 (KEY2 dropped, KEY1 routed to comment-review — safe).

**D-021 CLOSE — attacked, HOLE found (P19-001).** ticket_id O7 (site 4) and config-driven close-state are sound; STEP 4 correctly denies HIGH/CRIT `scored_priority` (keyed on field 18) → comment-review, and STEP 5 correctly kills under `autonomy_enabled=false`. Consumer anti-fungibility EC-027 present (comment↛move). **However** the FP/BTP disposition leg of the gate is unenforced at the only enforcement point (emitter), allowing a TP auto-close — see P19-001. The close-state config-poisoning vector is out of the LLM threat model (config is operator-set, allowlist-validated) but noted for defense-in-depth (P19-003). Close-state cannot be injected from the verdict (not a verdict field) — confirmed.

**D-022 COMPOUND — attacked, ordering/TOCTOU clean; partial-failure gap found (P19-002).** The two markers are independent single-use (SM-65); the rule-4 link marker's KEY1=NEW_KEY does not exist until create returns, so the link marker cannot be consumed early — no TOCTOU. Create is dedup-protected against duplication on re-run. The residual is the orphan-unlinked ticket on interrupted/denied second Write, with no reconciliation spec and no covering VP (P19-002), plus a rule-2 provenance ambiguity (P19-004).

**Previously-intact invariants — burst-15 regression check (spot-checked, all intact):** Marker schema v2.2 `link_target_ticket_id` present and null-for-non-link in both emitter copies (BC-3.03.001 line 610; arch-delta 1884). `ACTION_ENUM` synchronized to include `link`+`close` in both copies (BC-3.03.001 line 171; arch-delta 1396). JSON-first dispatch, 18-field verdict, STEP 1a consistency-only, scored_priority-keyed high floor, HARD-FLOOR-UNBINDABLE / UNDER-LABEL-DENIED / MARKER-WRITE-FAILED fail-closed paths, iterative-consume, and O7 charset-validation at the pre-existing sites are all unchanged by burst-15. VP/SM namespace additions (VP-HOOK-033..036; SM-57..65; SM-55 reserved-skipped) are collision-free and next-free. Kill-switch Option A create-review/comment-review exemption gated on `hard_floor_applies()` is intact. **Burst-15 did not break any previously-confirmed invariant.**

**Least-attacked BCs (light probe):** BC-4.02.001 v1.13 compound rules reviewed (P19-002/P19-004). BC-6.01.001 PC#13 close-state allowlist validation confirmed present. BC-8.02.001 / BC-6.01.004 not deeply re-probed this pass (budget) — no new burst-15 surface touches them beyond the D-DEC-005 carve-out already tracked.

---

## Novelty Assessment

**Novelty: HIGH.** P19-001 is a genuinely new, substantive CRITICAL security finding on the newest surface (D-021), not a reword of any tracked residual — it is a missing disposition↔action coherence check, categorically distinct from the ASM-008 value-truthfulness residual, and it is a fresh regression of the project's own O3 standing rule. P19-002 (compound orphan) and P19-004 (rule-2 provenance) are new behavioral/verification gaps on the D-022 surface. This pass does **not** exhibit novelty decay; the burst-15 additions introduced real, previously-unattacked attack surface, and the fresh-context re-derivation surfaced a hole that the VP-HOOK-035 catalog text asserts is closed but which the emitter and mutant set do not actually enforce. Convergence is **not** reached.

---

## Updated Confirmed Invariants (monotonic; burst-15 additions in **bold**)

1. Marker schema **v2.2** sync — now incl. `link_target_ticket_id` (null for all non-link scopes; BC-3.03.001 line 610).
2. JSON-first dispatch → 18-field verdict class; markdown → separate human-comment path (GATE 1 kill-switch first; no autonomous comment marker).
3. Two-field severity model (verdict.severity STEP-1a consistency; scored_priority field 18 Stage-5 floor; SEVERITY_TO_SCORED_PRIORITY_MAP).
4. KNOWN-FP FLOOR (D-019): LOW/MED auto-close; HIGH/CRIT → review.
5. Emitter order STEP 1→1a→2→3→4→5→6; STEPs 1a/3/4 fire regardless of `autonomy_enabled`.
6. 18-field verdict / 12-field markdown.
7. command_pattern interpolation safety O7 — **8 active sites** (ticket_id ×5 incl. link KEY1 + close; jira_project_key ×2; link_target_ticket_id KEY2); charset-validate+escape at emit. **CAVEAT: `jira_close_state` is config-side and satisfies O7 via allowlist-grammar only, without emit-time escape/re-validation — see P19-003.**
8. Consumer iterative-consume, audit, base64+control-char stripping; create/create-review anti-fungibility step 6a; quote+backslash tokenizer; **link (EC-026) and close (EC-027) bidirectional anti-fungibility; `jr issue link` write-blocked (SM-57); `jr issue move` write-blocked and additionally `["close"]`-scoped.**
9. STEP-3 HARD-FLOOR-UNBINDABLE deny + re-doc cap→ABORT; marker-write review-path fail-closed; cron Gate 2 audit grep.
10. Sensor-silence direction; D-DEC-005 sensor-health carve-out.
11. VP/SM namespace: **41 VPs** (VP-HOOK 024-036, VP-SKILL 001-077), **58 mutants** (SM-9..SM-65, SM-55 reserved-skipped).
12. **D-020 link scope: `["link"]` authorizes exactly one anchored `jr issue link KEY1 KEY2` (no --type); KEY1+KEY2 charset-validated; VP-HOOK-033/034.**
13. **D-021 close gate DEFECTIVE as specified: STEP 4 (hard-floor, scored_priority HIGH/CRIT) and STEP 5 (kill switch) enforced; FP/BTP disposition leg NOT enforced at the emitter — see P19-001 (must be fixed before this becomes a confirmed invariant).**
14. **D-022 compound = two sequential single-use verdict Writes (rule 2 comment+link; rule 4 create+link, link waits for create key); ordering/TOCTOU sound; partial-failure recovery unspecified — see P19-002. VP-HOOK-036.**
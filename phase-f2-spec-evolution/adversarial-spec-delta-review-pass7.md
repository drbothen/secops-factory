---
document_type: adversarial-review
pass: 7
producer: adversary
date: 2026-07-21
cycle: v0.10.0-feature-prism-integration
scope: F2 spec-evolution delta package (architecture-delta v1.9, verification-delta v1.9, prd-delta v1.9, brief §3.9, BC-3.01.001 v1.18, BC-3.03.001 v1.15, BC-10.01.001 v1.11, plus 8 supporting BCs)
---

# Adversarial Spec-Delta Review — Pass 7

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 2 |
| MAJOR | 3 |
| MINOR | 3 |
| OBSERVATION | 2 |

The package is mature — kill-switch/hard-floor ordering, JSON-first dispatch, enum-membership validation, audit sanitization, and the create-pattern anchoring are all well-reasoned and internally traced. However, the pass-5/pass-6 "fail-loud" remediation has a load-bearing gap: the deterministic safety net operates on the **marker** (emitter / Write event) while the human-surface outcome depends on the **jr command** (consumer / Bash event) that the hook cannot rewrite. This produces a real silent-drop of hard-floor findings for three of four under-label action types (P7-001), and BC-10.01.001's own edge cases and canonical test vectors still encode the pre-D-DEC-012 "no marker for hard floor" semantics that directly contradict the current fail-loud invariant (P7-002).

---

## CRITICAL Findings

### P7-001 — STEP 4 under-label "upgrade" writes a marker the loop's own jr command cannot consume; hard-floor findings are silently dropped for create/assign/none actions

- **Severity:** CRITICAL
- **Documents:** `BC-3.03.001.md` Invariant #4 emitter STEP 4 (lines 273–310) + generation table create-review row (line 454); `architecture-delta.md` §D-DEC-008 emitter STEP 4 (lines 1233–1258); `BC-3.01.001.md` consumer step 5/6a (lines 86–136), EC-023 (line 284); `BC-10.01.001.md` Invariant #10 STEP-4 safety-net note (lines 282–300).
- **Construct:** disposition-guard STEP 4 UNDER-LABEL upgrade → `WRITE_MARKER` vs. require-review anchored `command_pattern` match on the actual Stage-8 command.

**Description.** The pass-6 STEP reorder (P6-002) moved the hard-floor upgrade to STEP 4 so that an under-labeled hard-floor verdict is "upgraded" to a `create-review`/`comment-review` marker regardless of `autonomy_enabled`. But the upgrade only rewrites the **marker**; it cannot rewrite the **Bash command** the monitoring-loop LLM subsequently issues at Stage 8. Under-labeling means, by definition, the loop set a non-review `ticket_action_type` and will run the corresponding non-review command. Walk the four under-label action types:

- `create`: loop runs `jr issue create --project KEY --summary …` (no `--label`). STEP 4 upgrades the marker to `create-review`, whose `command_pattern` **requires** `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed second position (BC-3.03.001 line 283). The label-less command fails the anchored match at consumer step 5 → **DENY** → ticket never created.
- `assign`: loop runs `jr issue assign SEC-123 …`. `ticket_id` is present, so STEP 4 upgrades to a `comment-review` marker with pattern `^jr … issue comment SEC-123 ` (BC-3.03.001 line 277). The assign command does not match the comment pattern → **DENY**.
- `none`: loop runs **no** jr command at all. The upgraded marker is never consumed and simply expires → nothing surfaced.
- `comment`: loop runs `jr issue comment SEC-123 …`; upgraded `comment-review` pattern is identical → this one path happens to work, coincidentally.

So in 3 of 4 under-label cases, the STEP-4 "safety net" produces an **unconsumable** marker. The hard-floor verdict (HIGH/CRITICAL severity, Indeterminate, credential-dumping T1003, or silent-sensor BLIND-SPOT) is documented locally and gets an `UNDER-LABEL-CORRECTED` audit line, but **no Jira ticket is ever created**, and require-review returns only the generic "review approval" deny. The human never sees the finding in Jira. This defeats the exact fail-loud invariant (BC-10.01.001 Invariant #10; D-DEC-012) that P4-004, P5-001 and P6-002 spent three passes establishing — the "silent drop" simply moved from "no marker" to "marker present but structurally unmatchable by the command."

**Failure scenario.** Monitoring loop triages a domain-controller credential-dumping alert. The LLM (the fallible actor the safety net exists to catch) writes the verdict with `ticket_action_type:"create"` and `jira_project_key:"PRISM-DEMO"`. disposition-guard STEP 4 fires (hard_floor_applies=true), writes a `create-review` marker requiring `--label`, emits allow, logs `UNDER-LABEL-CORRECTED`. Stage 8: the loop runs `jr issue create --project PRISM-DEMO --summary "T1003 on DC01"` (no label, because the loop thinks it is doing a regular create). require-review finds the create-review marker, step-5 pattern requires `--label` → no match → deny. No ticket. A CRITICAL finding is invisible to the SOC analyst; only an audit-log line records it.

**Remediation.** The upgrade cannot be marker-only. Options: (a) on an under-labeled hard-floor verdict, disposition-guard **denies the verdict Write** with an explicit reason instructing the loop to re-document with the correct review token (fail-closed AND loud at the point the loop can still react); or (b) specify that the loop, on a require-review deny of a hard-floor action, MUST re-issue the command with `--label (REVIEW-REQUIRED|BLIND-SPOT)` — and add a VP for that retry; or (c) redefine the fail-loud guarantee/VP-HOOK-029 to verify **end-to-end** that the escalation jr write is authorized and executed, not merely that a marker exists in the store (see P7-004). As written, the STEP-4 upgrade provides false assurance for the system's most safety-critical path.

---

### P7-002 — BC-10.01.001 edge cases EC-015/016/017/021 and two canonical test vectors still say "no marker" for hard-floor verdicts, contradicting the current fail-loud Invariant #10

- **Severity:** CRITICAL
- **Document:** `BC-10.01.001.md`
- **Constructs:** EC-015 (line 450), EC-016 (line 451), EC-017 (line 452), EC-021 (line 456), Canonical Test Vectors (line 463 "novel pattern, HIGH severity"; line 466 "Indeterminate verdict") — all contradict Invariant #10 (lines 266–320), EC-006 (line 441), and EC-014 (line 449).

**Description.** The v1.8 D-DEC-012 fix narrowed Invariant #10 so hard-floor verdicts MUST emit a `create-review`/`comment-review` restricted marker and "are NEVER silently discarded," and updated EC-006 and EC-014 to match. But the same fix did **not** propagate to the sibling edge cases or the canonical test-vector table in the same file. They still encode the pre-fix semantics:

- EC-015 (HIGH/CRITICAL severity): "route to human unconditionally; … **no marker issued** regardless of autonomy_enabled."
- EC-016 (T1003 technique): "route to human; **no marker**; propose-only annotation."
- EC-017 (degraded sensor): "Force verdict to Indeterminate…; **no marker**; [REVIEW-REQUIRED] flag."
- EC-021 (LOW + unknown asset): "route to human unconditionally; … **no marker issued**."
- Test vector line 463 (HIGH severity): "hard floor fires: … **no marker issued**; [REVIEW-REQUIRED] or escalation draft created."
- Test vector line 466 (Indeterminate): "requires-human-approval annotation; **no marker**; loop does NOT auto-close."

"No marker" means require-review will deny every Stage-8 jr write (no candidate to consume) — i.e., these six locations describe exactly the silent-discard behavior the cycle was created to eliminate. A story-writer or formal-verifier encoding a test from line 466 ("Indeterminate → no marker") would either fail against the current design (which now emits a create-review marker) or, worse, enshrine the silent-discard bug as the expected behavior. This is a partial-fix propagation gap with blast radius 6 within one file — per the Partial-Fix Regression Discipline, HIGH; given the property is the system's core safety invariant and the vectors are authoritative for test authors, I grade it CRITICAL.

**Failure scenario.** FV writes `@test "monitoring-loop Indeterminate verdict never gets marker"` from test vector line 466. It passes against a mutant that removes the D-DEC-012 review-marker emission — so the regression that reintroduces silent-discard of Indeterminate findings passes the suite. The safety property is unprotected precisely where the vectors say "no marker."

**Remediation.** Update EC-015, EC-016, EC-017, EC-021 and the two canonical test-vector rows to the post-D-DEC-012 semantics: hard-floor/Indeterminate/silent-sensor verdicts set `ticket_action_type = create-review|comment-review` and disposition-guard emits a **restricted review marker** (exempt from the kill switch); "no marker" applies ONLY to non-hard-floor + `autonomy_enabled=false` or "surfacing complete." Add the negative assertion that a hard-floor verdict must NOT leave the marker dir empty (align with VP-HOOK-029).

---

## MAJOR Findings

### P7-003 — The monitoring-loop contract (BC-10.01.001) never states the `--label (REVIEW-REQUIRED|BLIND-SPOT)`-in-fixed-second-position Iron Law that the create-review command_pattern requires

- **Severity:** MAJOR
- **Documents:** `BC-10.01.001.md` Stage-8 pipeline description (line 399), operational-metadata Iron Law (line 260, states only `--project`); contrast `BC-3.03.001.md` Iron Law (lines 203–210) and `BC-3.01.001.md` consumer note (line 204).

**Description.** The create-review `command_pattern` demands `--project <key>` first and `--label (REVIEW-REQUIRED|BLIND-SPOT)` immediately second, terminated by `( |$)`. That ordering Iron Law is stated in the **emitter** and **consumer** BCs as an obligation *on* the monitoring-loop, but the monitoring-loop's own authoritative contract (BC-10.01.001) — the spec the SKILL author builds the command from — states only the `--project` Iron Law (line 260) and never states the `--label` positioning requirement. The Stage-8 description (line 399) says merely "execute jr comment/create/assign using the Stage-7 marker." EC-014 mentions a `[REVIEW-REQUIRED]` label but not the fixed-second-position constraint. An implementer working from BC-10.01.001 has no in-contract instruction to place `--label` second; a command such as `jr issue create --project KEY --summary "…" --label REVIEW-REQUIRED` (label after summary) fails the anchored pattern → require-review denies → the hard-floor escalation ticket is never created. This is the correctly-labeled counterpart to P7-001: even when the loop intends a review ticket, the loop contract doesn't tell it how to build a consumable command.

**Remediation.** Add an explicit Iron Law to BC-10.01.001 (Invariant #10 / Stage-8 / the jira_project_key metadata note): every review-path `jr issue create` MUST be `jr [--output json] issue create --project ${JIRA_PROJECT_KEY} --label (REVIEW-REQUIRED|BLIND-SPOT) …` with `--project` first and `--label` second, no flags interposed. Add a BATS vector for the mis-ordered-label deny.

### P7-004 — VP-HOOK-029 verifies only the emitter side ("marker exists OR error"); it cannot detect that the escalation jr write is actually authorized/executed

- **Severity:** MAJOR (verification gap)
- **Documents:** `BC-10.01.001.md` VP-HOOK-029 (line 489) and Inv#10 note (line 302); `verification-delta.md` VP-HOOK-029 (lines 211, 489-equivalent §2).

**Description.** VP-HOOK-029's assertion is: "a create-review/comment-review restricted marker exists in the marker store OR an explicit error artifact was written — assert NOT (empty marker dir AND no error)." That is an **emitter-side** predicate. It is satisfied by the STEP-4 upgrade writing a marker — even when that marker is structurally unconsumable by the loop's actual command (P7-001) or when the loop never issues a matching command (action=none). The VP therefore cannot detect the silent-drop it exists to guard against. The single cross-hook `@test` on line 489 ("require-review accepts create-review token for jr issue create [REVIEW-REQUIRED]") exercises only the correctly-ordered happy path; there is no vector asserting that an **under-labeled** hard-floor verdict results in an actually-created Jira ticket (as opposed to a marker in a directory). The "fail-loud, end-to-end" claim in verification-delta §1 (lines 244–258) overstates what the VP proves.

**Remediation.** Re-scope VP-HOOK-029 to a true end-to-end assertion: for a hard-floor verdict with ANY `ticket_action_type` (including under-label create/assign/none), assert that either (a) a review-labeled jr write is authorized and consumes a matching marker, or (b) a fail-loud deny+error artifact is produced that the loop is specified to react to — never a marker that no command can consume. Add mutants for the create/assign/none under-label paths distinct from SM-32a.

### P7-005 → reclassified: see below (moved to MINOR after confirming fail-closed). *(No MAJOR here — placeholder removed.)*

---

## MINOR Findings

### P7-005 — Consumer step-6a `has_review_label` is an unanchored substring test over the whole command (including `--summary`), causing false-deny of legitimate regular creates whose summary text contains the label string

- **Severity:** MINOR (availability; fail-closed, not a bypass)
- **Document:** `BC-3.01.001.md` consumer step 6a (lines 96–125), EC-023 (line 284); mirrored in `architecture-delta.md` lines 216–229.

**Description.** `has_review_label = ("--label REVIEW-REQUIRED" in command) OR ("--label BLIND-SPOT" in command)` is a plain substring check over the full command, which includes LLM/attacker-influenceable `--summary` text. A benign FP-close create such as `jr issue create --project PRISM-DEMO --summary "rule matched literal --label REVIEW-REQUIRED in payload"` passes step-5's regular-create pattern (the `( |$)` matches the space before `--summary`) but then step-6a sets `has_review_label=true` and, with a `["create"]` marker, `CONTINUE`s (skips) → the legitimate create is denied. This is a content-vs-structure check: the anchored `command_pattern` (step 5) is the real structural gate and prevents any actual security bypass, so step-6a only produces false-denies. Harmless to security, but a functional bug that will surprise operators whose alert summaries mention the label string.

**Remediation.** Make step-6a structural: detect `--label` only as a real flag token (e.g., a word-boundary/position check consistent with the emitter's fixed-second-position rule), not as a raw substring anywhere in the command. Add a vector with a label-string-in-summary regular create asserting ALLOW.

### P7-006 — Cyberint severity has no concrete normalization mapping (D-DEC-013 marks it COMPUTE-AT-VALIDATION), yet Cyberint is a recognized family exercised by the demo (org-b); the "unrecognized → CRITICAL" fallback does not clearly apply to a recognized-but-unvalidated family

- **Severity:** MINOR
- **Documents:** `BC-10.01.001.md` Invariant #9 field 13 NORMALIZE_SEVERITY table (lines 228–240) and Stage-1 note (lines 383–386); `brief` §4.2 (org-b = Claroty, Cyberint).

**Description.** D-DEC-013 gives concrete mappings for CrowdStrike, Armis, Claroty, and NVD, defaults "unrecognized sensor family → CRITICAL + uncertainty_explicit," but pins Cyberint to "COMPUTE-AT-VALIDATION per ASM-008 … conservative path until ASM-008 resolved." Cyberint is a **recognized** family (explicitly listed), so the "unrecognized → CRITICAL" leg does not clearly fire, and no concrete conservative value is specified. The DTU demo seeds org-b with Cyberint alerts (brief §4.2, §4.5), so the demo path exercises a sensor whose `severity` enum is undefined by the spec. If the loop emits a non-enum placeholder, `validate_enums()` denies the verdict Write (fail-closed) → that alert produces no verdict and no ticket; if it emits an arbitrary tier, hard-floor evaluation is unsound.

**Remediation.** Specify the conservative pre-ASM-008 Cyberint mapping explicitly (recommend: default CRITICAL + `uncertainty_explicit` naming the unvalidated mapping, mirroring the unrecognized-family rule) so a recognized-but-unvalidated family has a defined, enum-valid, auditable severity. Add a VP-SKILL-074 partition for Cyberint.

### P7-007 — Brief §3.9 amendment cites stale BC versions and the pre-reorder STEP number

- **Severity:** MINOR (cross-reference staleness)
- **Document:** `prism-integration-handoff-brief.md` §3.9 amendment (lines 436–443).

**Description.** The §3.9 amendment (dated 2026-07-21) states the carve-out is carried by "BC-3.03.001 **v1.14** STEP 3 and BC-10.01.001 **v1.10** Inv#10," but the live versions are BC-3.03.001 **v1.15** and BC-10.01.001 **v1.11**, and the pass-6 reorder split the mechanism across STEP 3 (correctly-labeled) and STEP 4 (under-label upgrade, before the STEP-5 kill switch). The amendment's "STEP 3" citation and version pins are now behind the design they authorize. Not a semantic conflict (Option A is consistent), but a reader reconciling the brief against the BCs will hit stale anchors.

**Remediation.** Update the amendment to v1.15/v1.11 and note the STEP 3 (correct-label) / STEP 4 (under-label upgrade) split, or make the version references non-pinned ("current BC versions").

---

## Observations

### P7-008 — `comment` and `comment-review` markers are fully fungible (identical `command_pattern`; consumer accepts either) pending ASM-014

- **Severity:** OBSERVATION
- **Documents:** `BC-3.01.001.md` step 6 (lines 104–106); `BC-3.03.001.md` generation table (lines 450–455).

The comment-review pattern is byte-identical to the comment pattern, and consumer step 6 accepts either for a `jr issue comment` command with no anti-fungibility cross-check (deferred to ASM-014, `jr issue comment --label` support). No security consequence today because the **emitter** is the gate: it never issues a `comment` marker for a hard-floor verdict, nor a `comment-review` marker for a non-hard-floor verdict (STEP 3 over-label gate + STEP 5 kill switch). The distinction is currently audit-cosmetic. Worth a note so that if ASM-014 lands, the comment-review structural check is added symmetrically with the create-review one.

### P7-009 — [process-gap] The fail-loud invariant is asserted at the emitter (Write event) but its guarantee lives at the consumer (Bash event); no review axis requires cross-event, end-to-end verification of authorization outcomes

- **Severity:** OBSERVATION (`[process-gap]`)

Both CRITICALs (P7-001, P7-002) and P7-004 share one root: across this package, "the finding reaches a human" is repeatedly proven by an **emitter-local** artifact (a marker file exists, an audit line is written) rather than by the **consumer-observable** outcome (a jr write is authorized and a Jira ticket exists). Four adversarial passes hardened the emitter without a review axis mandating that fail-loud claims be corroborated at the consumer/Bash boundary where the human-surface actually occurs. Recommend a standing check for this package: every "never silently discarded" claim must have a VP whose assertion is the downstream jr authorization/execution, not the upstream marker presence.

---

## Semantic Anchoring Audit

Spot-checked capability/subsystem/VP anchors: BC-3.01.001 (`CAP-ENFORCEMENT-01`, `enforcement-hooks`, C-12/C-29), BC-3.03.001 (`CAP-ENFORCEMENT-03`, C-14/C-29), BC-10.01.001 (`CAP-MONITORING-01`, `monitoring-loop`, C-2/C-12/C-14/C-25/C-29/C-30). All resolve correctly to their described roles; the marker-store C-29 define/enforce split (emitter=BC-3.03.001, consumer=BC-3.01.001) is coherent. VP namespace adjudication (verification-delta §1) is internally consistent and the two architect-proposed collisions (VP-SKILL-072→074, SM-33/34→36/37) are correctly caught. **No mis-anchoring found** — no anchor-class blockers.

## Partial-Fix Regression Discipline check

- The D-DEC-012 fail-loud fix propagated to BC-10.01.001 Invariant #10, EC-006, EC-014 but **not** to EC-015/016/017/021 or the canonical test vectors → **P7-002** (blast radius 6, same file).
- The `--label` fixed-second-position Iron Law propagated to BC-3.03.001 and BC-3.01.001 but **not** to the loop contract BC-10.01.001 → **P7-003** (cross-BC sibling gap).
- The pass-6 STEP-reorder version bumps (v1.15/v1.11) did not propagate to the brief §3.9 amendment → **P7-007**.

## Coverage Narrative

Attacked: the full marker lifecycle (emit → TTL → consume → audit); the disposition-guard STEP 0–6 decision tree and the pass-6 STEP 4/5 reorder; the kill-switch (autonomy_enabled) semantics and its create-review/comment-review carve-outs in both directions (over-label at STEP 3, under-label at STEP 4); hard_floor_applies() legs including the asset_type=unknown separate check; the create/create-review `command_pattern` anchoring and consumer step-5/step-6a anti-fungibility in both directions; the comment/comment-review fungibility; the 12/15-field artifact-class dispatch (JSON-first); enum-membership validation; severity normalization (D-DEC-013); watermark grace-window / monotonicity / late-event fail-loud; sensor-silence BLIND-SPOT dedup; and every VP that touches the fail-loud invariant. I re-derived the emitter/consumer interaction from the BC pseudocode rather than trusting the changelogs, which is how P7-001/P7-004 surfaced (the emitter and consumer are individually self-consistent; the defect lives in the Write-event/Bash-event seam that no single BC owns end-to-end).

## Novelty Assessment

Novelty: **HIGH.** P7-001 and P7-004 identify a structural gap in the fail-loud mechanism that survived four passes of emitter hardening precisely because each pass reasoned about the marker in isolation; the defect is at the marker↔command seam. P7-002 is a concrete six-location internal contradiction that directly re-encodes the silent-discard defect the cycle was created to eliminate. These are substantive gaps, not rewordings. This package has **not** converged — the two CRITICALs must be resolved (the fail-loud safety property is currently unsound for under-labeled hard-floor verdicts and is contradicted by the file's own edge cases/test vectors).
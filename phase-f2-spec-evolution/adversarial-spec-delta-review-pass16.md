---
document_type: adversarial-review
pass: 16
producer: adversary
date: 2026-07-23
feature: prism-integration
phase: f2
scope: spec-evolution delta package (convergence-candidate)
---

# Adversarial Spec-Delta Review — Pass 16

## Summary

**NOT a clean pass.** One MAJOR spec-vs-spec contradiction introduced by the burst-11
consumer-BC reconciliation, plus two MINOR coherence residues. The MAJOR is exactly
the class the mandate asked me to hunt: the burst-11 (P15-001) rewrite of the two
consumer BCs propagated the *post-Gate-1* markdown routing but silently dropped the
**Gate-1 autonomy_enabled kill switch** that the authoritative emitter fires FIRST —
so the consumer BCs now describe review-marker issuance and hard-floor deny for
human-analyst investigation saves that the authoritative hook never performs.

| ID | Title | Severity |
|----|-------|----------|
| P16-001 | Consumer BCs (BC-4.02.001 PC#4 / BC-5.01.001 Inv#7) contradict authoritative Gate-1 markdown-path behavior for human-analyst saves | **MAJOR** |
| P16-002 | spec-changelog burst-11 entry states "54 mutants" — authoritative count is 48 (max-SM-ID/count confusion) | MINOR |
| P16-003 | BC-3.03.001 PC#1 VP-HOOK-028 note still says "verdict-class 15-field path" — stale vs 18-field schema in same postcondition | MINOR |

All other coherence axes PASS (see Coherence-Sweep Results).

---

## Critical Findings

None.

---

## Major Findings

### P16-001 — Consumer BCs contradict authoritative Gate-1 markdown-path behavior — MAJOR

**Documents / anchors:**
- Authoritative: `BC-3.03.001.md` v1.23, Invariant #4 → "Separate Human-Comment Marker
  Path", **GATE 1** pseudocode (lines 686–700); and PC#2 routing item **(a)** (line 87).
- Authoritative corroboration: `architecture-delta.md` v1.17, markdown-path "Gating
  sequence" (lines 1810–1818: "If absent or not exactly `true`: emit allow-without-marker …
  under autonomy_enabled=false, the markdown path behaves identically to the regular path").
- Contradicting consumers: `BC-4.02.001.md` v1.10, **PC#4** (lines 59–65);
  `BC-5.01.001.md` v1.10, **Invariant #7** including the "**MUST NOT be denied**" clause
  (line 106).

**Description.**
The authoritative emitter (BC-3.03.001) specifies that the investigation-markdown path
evaluates **GATE 1 (autonomy_enabled kill switch) FIRST**:

```
autonomy_enabled_md = parse_autonomy_enabled_from_markdown(content)  # absent/non-bool-true = false
IF autonomy_enabled_md IS NOT exactly true:
  emit allow without marker   # kill-switch parity: investigation file saved; no Jira marker
  RETURN
```

with the explicit comment (BC-3.03.001 line 695-696): *"Human analyst saves (which
typically lack autonomy_enabled) → allow-without-marker → file saved, no Jira marker."*
Only when `autonomy_enabled == true` (the P12-002 "autonomous-loop-masquerade" case) does
control reach Gates 2/3 (markdown-evaluable hard floors → MARKDOWN-HARD-FLOOR deny) and
the FP→allow / non-FP→review-marker routing.

`investigation-*.md` files are written **only** by the human-driven skills
`investigate-event` (BC-5.01.001) and `update-jira` (BC-4.02.001). The monitoring loop
writes **verdict JSON** (verdict-class path), never investigation markdown. Therefore, for
every real consumer invocation, `autonomy_enabled` is absent and **Gate 1 always
short-circuits to allow-without-marker for ALL dispositions.**

Both consumer BCs, as rewritten in burst-11, **omit Gate 1 entirely** and describe the
post-Gate-1 routing as the behavior their skill experiences:

- BC-4.02.001 PC#4 / BC-5.01.001 Inv#7: "(b) **non-FP / PARSE_FAIL → MARKDOWN_REVIEW_PATH
  review marker**" and "(c) hard-floor conditions (Indeterminate, forbidden techniques,
  degraded/silent sensor) → **MARKDOWN-HARD-FLOOR deny**".
- BC-5.01.001 Inv#7 "MUST NOT be denied" clause states the analyst's Write "always
  succeeds (**allow-without-marker for FP; review marker for non-FP**)".

Both claims contradict the authoritative spec for the human path:
1. **Non-FP human save:** consumer says a *review marker* is issued; authoritative Gate 1
   says **allow-without-marker (no marker)**.
2. **Indeterminate / forbidden-technique / degraded-sensor human save:** consumer implies
   the Write is **DENIED** (MARKDOWN-HARD-FLOOR, and by the "non-Indeterminate … MUST NOT
   be denied" framing); authoritative Gate 1 says the Write is **allowed
   (allow-without-marker)** because autonomy_enabled is absent.

**Concrete failure scenario.**
A story-writer/implementer building `investigate-event` acceptance tests from BC-5.01.001
Inv#7 writes: (a) a test asserting that an *Indeterminate* investigation save is **denied**
(MARKDOWN-HARD-FLOOR), and (b) a test asserting that a *non-FP* (TP/BTP) investigation save
**produces a review marker**. Both tests fail against the correct disposition-guard hook
(BC-3.03.001), which returns allow-without-marker at Gate 1 for these human saves. Worse:
an implementer who trusts the consumer BC over the emitter BC could "fix" the hook to deny
Indeterminate markdown saves and emit review markers for non-FP markdown — reintroducing
the P12-002 autonomous-loop-masquerade surface (a marker issued from the 12-field markdown
path that cannot evaluate scored_priority/asset_type) and blocking human analysts from
saving Indeterminate investigations (a very common, legitimate disposition).

**Why this is new.** Prior passes reconciled the consumer BCs to eliminate the *comment-
scoped marker* language (P13-001 → P15-001). That reconciliation correctly removed the
comment marker but carried over the FP/non-FP/hard-floor routing **without the Gate-1
precondition that dominates for human invocations** — a fresh contradiction created by the
burst-11 edit, not a pre-existing residual.

**Suggested remediation.**
Rewrite BC-4.02.001 PC#4 and BC-5.01.001 Inv#7 to state the *human-path* behavior first
and correctly: "Because `investigation-*.md` is written by a human analyst (no
`autonomy_enabled` field), disposition-guard's Separate Human-Comment Marker Path Gate 1
fires and emits **allow-without-marker for every disposition** — the investigation Write
always succeeds and no Jira action is authorized; the subsequent `jr issue comment` falls
to human permission-approval. The FP→allow / non-FP→review-marker / hard-floor→deny routing
(Gates 2/3) applies ONLY to the `autonomy_enabled=true` masquerade case, which these
human-driven skills do not produce." Cite BC-3.03.001 v1.23 Gate 1 (Invariant #4) as the
authoritative source and remove the incorrect "review marker for non-FP" / implied
"Indeterminate save denied" claims from the human-path description.

---

## Important (MINOR) Findings

### P16-002 — spec-changelog burst-11 mutant count "54" contradicts authoritative 48 — MINOR

**Document / anchor:** `spec-changelog.md`, burst-11 (Pass-15) header, line 26:
"37 VPs / **54 mutants** / ~367 test vectors (no VP/SM additions this burst)."

**Description.** The authoritative verification-delta v1.18 states the mutant count is
**48** — `verification-delta.md` line 2454 ("SM-9..SM-54, **48 mutants** with SM-32 =
SM-32a+SM-32b+SM-32-ext …") and line 2477 ("Mutant count UNCHANGED at **48
(SM-9..SM-54)**"). The sibling changelog entries for burst-10 and burst-10-followup both
correctly say "48 mutants" (`spec-changelog.md` lines 50 and 81). The burst-11 entry
conflates the **highest SM identifier (SM-54)** with the **mutant count (48)** — an
arithmetic slip made more glaring by the same line asserting "no VP/SM additions this
burst" (i.e., the count could not have risen from 48 to 54).

**Concrete failure scenario.** A reader auditing SM catalog completeness from the changelog
believes 54 mutants exist and searches for 6 non-existent mutants (SM-9..SM-54 minus the
SM-32 splits = 48), or flags a spurious "6 missing mutants" gap.

**Suggested remediation.** Change "54 mutants" → "48 mutants (SM-9..SM-54, SM-32 =
32a+32b+32-ext; SM-55 skipped)" in the burst-11 changelog entry.

### P16-003 — Stale "verdict-class 15-field path" in BC-3.03.001 PC#1 VP-HOOK-028 note — MINOR

**Document / anchor:** `BC-3.03.001.md` v1.23, **Postcondition #1**, VP-HOOK-028
verification-property note (line 73): "…a file whose content parses as JSON OR whose path
ends `.json` is unconditionally routed to the **verdict-class 15-field path**, regardless
of any `investigation` directory substring…".

**Description.** The verdict schema is **18 fields** (P10-001 15→17, P11-002 17→18). The
same postcondition states 18-field correctly at the dispatch checks (line 67: "18-field jq
key-presence") and in the normative validation body (line 75: "ICD-203 **18**-field
validation … all **18** mandatory fields"), and STEP 0 of the emitter (line 145) says
"18-field check passed". Line 73's "15-field" is an internal inconsistency within PC#1 and
a live-body (non-Previous, non-revision-history) current-tense claim. This residue predates
even the 17-field era and survived every field-count sweep (P10-001, P11-002, P14-004's
"VP-HOOK-028 ref" sweep which touched BC-10.01.001 but not this BC-3.03.001 line, and
P15-002 which fixed the *separate* Evidence-Types occurrence). It violates the
"field counts 18 in current bodies" coherence axis.

**Concrete failure scenario.** A reader cross-checking the verdict field count against the
VP-HOOK-028 dispatch guarantee sees "15-field" and cannot tell whether the verdict class is
15 or 18 without reading the adjacent normative text — undermining the single-source-of-
truth guarantee for the schema size at the exact dispatch boundary VP-HOOK-028 covers.

**Suggested remediation.** Line 73: "verdict-class 15-field path" → "verdict-class 18-field
path". (The "(ADV-F2-P4-001 CRITICAL)" citation may remain as historical origin; the routing
target must read 18-field.)

---

## Observations

- The core enforcement remains sound: because BC-3.03.001 (the emitter) and
  architecture-delta both carry Gate-1-first correctly, runtime security is intact **so long
  as implementers follow the emitter BC**. P16-001 is a documentation/coherence defect on
  the *consumer* side, not a runtime-security regression in the authoritative surface — this
  is why it is graded MAJOR, not CRITICAL. It nonetheless blocks convergence: it is a direct
  spec-vs-spec contradiction on a security-relevant path.
- BC-6.01.004 (onboard-sensor) and BC-9.01.001 (scan-threats) — two of the least-attacked
  BCs — are internally coherent. BC-9.01.001 PC#5's presentation-only severity-bucketing note
  (P15-004) correctly disclaims that its CRIT/HIGH/MED/LOW display grouping is NOT a
  scored_priority verdict field and NOT a hard-floor input; no drift with the two-field
  severity model.
- Semantic anchoring audit: VP-SKILL-076 (setup-time jira_project_key charset gate, Inv#6/
  EC-010) and VP-SKILL-077 (AD-017 credential-decline, Inv#1/EC-008) are correctly and
  distinctly anchored in BC-6.01.003 and mirrored in verification-delta v1.18. The burst-10
  "one-ID-two-behaviors" conflation is fully disentangled. No mis-anchoring found.

---

## Coherence-Sweep Results (end-to-end)

| Axis | Result |
|------|--------|
| Verdict field count = 18 in current bodies | **PASS with 1 exception** → P16-003 (BC-3.03.001 PC#1 line 73 stale "15-field"). All normative PCs/Invariants (BC-3.03.001 PC#1 body, BC-10.01.001 Inv#9, prd-delta Verdict Schema Summary) = 18. |
| Investigation-markdown = 12 fields | PASS (BC-3.03.001 PC#2; consumer BCs; VP-HOOK-025 per-class split) |
| VP count = 37 | PASS (verification-delta v1.18: 9 VP-HOOK [024–032] + 28 VP-SKILL; prd-delta §1 roster FINALIZED) |
| Mutant count = 48 (SM-9..SM-54) | **PASS in authoritative doc; 1 changelog error** → P16-002 (burst-11 entry says 54) |
| PRISMDEMO consistency; no PRISM-DEMO hyphen-form outside invalid-key examples | PASS (all `PRISM-DEMO` occurrences are intentional invalid-key examples: BC-6.01.001 EC-014, BC-3.03.001 line 780 constraint note) |
| No residual live-body 15/17-field | **PASS except P16-003**; all other 15/17 hits are Previous blocks / revision history |
| Enum tokens CRIT vs CRITICAL (scored_priority = {CRIT,HIGH,MED,LOW}) | PASS (only CRITICAL/MEDIUM occurrences are the SEVERITY_TO_SCORED_PRIORITY_MAP source keys "CRITICAL→CRIT", "MEDIUM→MED") |
| VP-SKILL-076 / 077 distinct | PASS |
| Consumer BCs (BC-4.02.001/BC-5.01.001) consistent with emitter on markdown path | **FAIL** → P16-001 (Gate-1 kill switch omitted; routing claims contradict authoritative allow-without-marker for human saves) |
| FP-comment workflow coherent end-to-end | PASS for the *stated* mechanism (FP → allow-without-marker → jr comment falls to human approval via require-review) — no contradiction with the require-review allowlist or DI-013 resolution. The incoherence is not the FP path itself but the *non-FP and hard-floor* branches described for the human path (P16-001). |
| "jr comment falls to human approval" vs require-review allowlist / DI-013 | PASS — consistent: require-review denies unmarked `jr issue comment`, which surfaces the Claude Code permission dialog (human approval). No allowlist-precedence conflict. |
| Marker schema v2.1, 120s TTL, iterative-consume, anti-fungibility (step 6a), O7 charset-validation at 5 sites | PASS (spot-checked; unchanged from confirmed invariants) |
| Emitter STEP order 1→1a→2→3→4→5→6; STEPs 1a/3/4 fire regardless of autonomy_enabled | PASS (spot-checked BC-3.03.001) |

Documents reviewed in full or by targeted section: handoff-brief, prd-delta v1.16,
dtu-assessment v1.1, asm-004-validation, spec-changelog, architecture-delta v1.17 (targeted),
verification-delta v1.18 (targeted), BC-3.03.001, BC-4.02.001, BC-5.01.001, BC-6.01.003
(targeted), BC-6.01.004, BC-9.01.001, BC-10.01.001 (targeted), BC-6.01.001 (targeted),
BC-3.01.001 (targeted). Not exhaustively re-read: BC-8.02.001 (spot-checked via changelog +
prd-delta; no finding), full architecture-delta body (targeted greps only, 469 KB).

---

## Novelty Assessment

**Novelty: MEDIUM-HIGH for this stage.** The immediately-prior pass reportedly closed at
1 MAJOR + 2 MINOR; this pass surfaces a *different* MAJOR that is a genuine second-order
consequence of that reconciliation (Gate-1 omission), not a rewording of prior findings.
P16-003 is a stale count that survived every field-count sweep across many passes — a
classic fresh-context catch at a location prior sweeps did not touch (they fixed the sibling
Evidence-Types occurrence). P16-002 is a new arithmetic slip localized to the burst-11
changelog entry. None of the three are nitpicks; P16-001 is a security-relevant spec-vs-spec
contradiction. The package has **not** converged: the burst-11 consumer-BC reconciliation
introduced a new inconsistency exactly of the kind the mandate flagged.

---

## Confirmed Invariants (carried forward + this pass)

1. Marker schema v2.1 in sync; 120s TTL via absolute `expires_at_utc`; future-dated →
   immediately expired.
2. JSON-first dispatch (BC-3.03.001 PC#1) → 18-field verdict class; `investigation-*.md`
   glob → 12-field markdown → Separate Human-Comment Marker Path (NOT the verdict emitter).
   **[NOTE: consumer-side description of the markdown path is defective — P16-001.]**
3. Two-field severity model intact: verdict.severity detector-native (STEP-1a
   consistency-only); scored_priority field 18 {CRIT|HIGH|MED|LOW} (Stage-5); §3.9 floor
   keys on scored_priority; fast-path via SEVERITY_TO_SCORED_PRIORITY_MAP; known-FP exempt;
   NVD/CVSS → scored_priority only (P11-003 clean separation).
4. Emitter STEP order 1→1a→2→3→4→5→6; STEPs 1a/3/4 fire regardless of autonomy_enabled.
5. 18-field verdict / 12-field investigation markdown. **[one non-normative 15-field residue
   at BC-3.03.001 PC#1 line 73 → P16-003.]**
6. command_pattern interpolation safety (O7; VP-HOOK-032 + VP-SKILL-076); ticket_id/
   jira_project_key charset-validated + regex-escaped at 5 sites; Jira keys hyphen-free;
   demo key PRISMDEMO (PRISM-DEMO appears only as intentional invalid-key example).
7. MARKDOWN path (VP-HOOK-031): **Gate 1 autonomy_enabled kill switch fires FIRST** →
   human saves (autonomy_enabled absent) get allow-without-marker for ALL dispositions;
   NO disposition yields an autonomous comment marker; FP→allow-without-marker; non-FP/
   PARSE_FAIL→review; strict parse grammar. **[Consumer BCs BC-4.02.001/BC-5.01.001 do NOT
   reflect Gate 1 and are inconsistent with this invariant — P16-001.]**
8. Consumer iterative-consume, audit path, base64+control-char stripping; create/create-review
   bidirectional anti-fungibility at step 6a; quote+backslash-aware tokenizer.
9. STEP-3 HARD-FLOOR-UNBINDABLE deny + re-doc cap→ABORT; marker-write failure review-path
   fail-closed; cron Gate 2 audit grep.
10. Sensor-silence direction; D-DEC-005 sensor-health carve-out.
11. VP/SM namespace: **37 VPs** (VP-HOOK 024–032, VP-SKILL 001–077); **48 mutants**
    (SM-9..SM-54, SM-32 = 32a+32b+32-ext; SM-55 skipped); ~367 test vectors. VP-SKILL-076
    (setup-time charset, P14-002) and VP-SKILL-077 (onboard-customer AD-017, P14-005)
    distinct. **[spec-changelog burst-11 entry misstates mutant count as 54 → P16-002.]**
12. Known deferrals (ASM-008-DEFERRED, ASM-015 BLOCKING, ASM-014, DI-015) re-confirmed
    in-scope and not re-reported.
---
document_type: adversarial-review
pass: 18
producer: adversary
date: 2026-07-23
feature: prism-integration
phase: f2
---

# Adversarial Spec-Delta Review — Pass 18 (F2 prism-integration)

## Summary

**NOT a clean pass.** Two MAJOR findings, one MEDIUM, two OBSERVATIONS.

The package is highly converged on the surfaces prior passes attacked hardest (marker
schema, JSON-first dispatch, two-field severity model, D-019 known-FP floor, emitter
STEP 0–6 ordering, consumer anti-fungibility, HARD-FLOOR-UNBINDABLE, markdown path). I
re-derived the emitter/consumer/loop interaction end-to-end WITH the D-019 change in place
and found it internally consistent (see coverage narrative). The new findings live in a
region prior passes under-attacked: **the mapping between the loop's §3.4 Jira-first action
set and the marker/require-review authorization model**, and **a burst-14 propagation gap
on VP-HOOK-028**.

| ID | Severity | Title |
|----|----------|-------|
| P18-001 | MAJOR | `jr issue link` (and `jr issue move`/close) have no authorization path — §3.4 rules 2 & 4 are non-functional; contradicts dtu-assessment + BC-4.02.001 + BC-10.01.001 |
| P18-002 | MAJOR | VP-HOOK-028 property (1): verification-delta declares P17-002 rewrite "RESOLVED/DONE" but the authoritative BC-10.01.001 copy still carries the dead property + a "pending FV" banner |
| P18-003 | MEDIUM | Single-verdict → single-marker model cannot authorize the two Jira writes (comment+link / create+link) that §3.4 rules 2 & 4 each require |
| P18-004 | OBSERVATION | BC-4.02.001 Invariant #1 enumerates gated mutations but omits `jr issue link`, which is nonetheless denied by require-review's fail-closed catch-all |
| P18-005 | OBSERVATION | FP disposition "Close (if open)" (brief §3.3) is unauthorizable and never exercised by DTU scenarios — either dead capability or unstated "comment-only" semantics |

---

## MAJOR Findings

### P18-001 — `jr issue link` and `jr issue move` (close) have no authorization path; §3.4 "related" and "closed→new+link" branches are non-functional

**Severity:** MAJOR
**Confidence:** HIGH
**Anchors:**
- `BC-4.02.001.md` PC#7b (L79): *"link the tickets as 'relates to' via `jr issue link` and add a comment"*; PC#7d (L81): *"create a new ticket and link it as a successor"* — both stated as autonomous actions (no `propose-only` annotation, unlike reopen at PC#7c).
- `BC-10.01.001.md` §3.4 (L196–232), EC-008/EC-011/EC-013 (*"Link tickets as 'is related to'"*, *"link to closed ticket as related"*), and canonical test vectors (L669: *"NEW ticket created; linked to closed ticket"*).
- `dtu-assessment.md` Dependency 2 jr-mock scenario table: `related-open → jr issue link called`; `closed-same → jr issue create + jr issue link called`. The DTU test design **asserts link is called and succeeds.**
- `BC-3.01.001.md` PC#2 write-block list (L66) = {comment, edit, move, assign, create} + `--output json` forms — **no `link`**; PC#3 read-only allowlist (L307–330) — **no `link`** (only `jr issue transitions`, plural, read-only); PC#4 + Invariant #3 fail-closed catch-all (L332, L347); marker `authorized_operations` enum (L599) = {comment, create, assign, create-review, comment-review} — **no `link`, no `move`**.
- Implementation ground-truth: `plugins/secops-factory/hooks/require-review.sh:92` allowlists `jr issue transitions` (plural, read-only); `require-review.ps1:61,64,79` — `jr issue link` appears in neither the write-block nor the allowlist.
- `BC-10.01.001.md` Stage 8 definition (L590): *"execute jr **comment/create/assign** using the Stage-7 marker"* — the loop's own pipeline step omits `link` entirely.

**Description.** `jr issue link` is a first-class, autonomous action in the Jira-first
correlation design (§3.4 rule 2 "related" and rule 4 "closed → new + link"). It is
required by BC-4.02.001, BC-10.01.001, and is explicitly asserted-as-called by the DTU
test design. But `jr issue link`:
- is **not** in require-review's write-block list (so it never enters the marker-validation branch),
- is **not** in the read-only allowlist,
- therefore falls to the **fail-closed catch-all → DENY** (BC-3.01.001 PC#4/Inv#3, SEC-002),
- and there is **no `authorized_operations` / `ticket_action_type` value** for `link`, so no marker can ever authorize it.

`jr issue move` (the verb used to transition/close a ticket — see BC-4.02.001 L80/L88
"jr issue move to reopen") is in the write-block list but likewise has **no marker scope**
(`move` is not an `authorized_operations` value), so it is permanently deniable.

This is a spec-vs-spec contradiction: dtu-assessment + BC-4.02.001 + BC-10.01.001 require
`jr issue link` to execute autonomously, while BC-3.01.001 (the sole Jira authorization
gate) denies it with no path to authorize.

**Concrete failure scenario.** Loop processes an alert whose IOC matches an existing open
ticket with a *different* root cause (§3.4 rule 2). Stage 7 writes a verdict
(`ticket_action_type=comment`), disposition-guard issues a comment marker. Stage 8 runs
`jr issue comment SEC-42 "..."` (marker consumed → allow), then `jr issue link SEC-42
SEC-99`. require-review evaluates `jr issue link`: contains `jr `, not write-blocked, not
allowlisted → **fail-closed DENY** (SEC-002 "add to allowlist"). The "relates to" linkage
never forms. For rule 4 (closed → create new + link), the create succeeds but the link is
denied → the new ticket is **orphaned, unlinked** to the closed predecessor, silently
violating the unconditional "link it to the closed one" requirement (BC-10.01.001 L196–199).
The operator believes the correlation link exists when it does not — a silent correctness
failure of the correlation feature.

**Suggested remediation.** Choose and specify one: (a) add a `link` (and `move`/`transition`)
`authorized_operations` token + `ticket_action_type` value + emitter command_pattern +
consumer acceptance, mirroring the create/comment paths; OR (b) if link is intended to be
review-gated only, route it through create-review/comment-review semantics; OR (c) if link
is deemed low-risk metadata, allowlist `jr issue link` explicitly with a documented rationale.
Whichever is chosen, reconcile BC-4.02.001 Inv#1, BC-10.01.001 Stage 8, and the
dtu-assessment jr-mock scenarios so all three agree link is authorizable. Same for `move`
if autonomous close is in scope (see P18-005).

---

### P18-002 — VP-HOOK-028 property (1): verification-delta declares P17-002 rewrite complete, but the authoritative BC-10.01.001 copy still carries the retired property + a "pending FV" banner

**Severity:** MAJOR
**Confidence:** HIGH
**Anchors:**
- `BC-10.01.001.md` L616 — the live *"Verification property (FINALIZED v1.7, extended v1.9): VP-HOOK-028"* paragraph STILL states the retired property (1): *"a Stage-7 Write to a path NOT containing the `verdict` substring causes disposition-guard to fast-path-allow ... the downstream Stage-8 jr write is DENIED ... Proves the verdict-file-path naming convention ... is enforced end-to-end."*
- `BC-10.01.001.md` L618 — an inline note: *"[ADV-F2-P17-002 — VP-HOOK-028 property (1) re-scope **pending FV**] ... FV **must re-scope** VP-HOOK-028 property (1) and its BATS vectors ... SM/VP IDs **allocated by FV** (ADV-F2-P17-002)."*
- `verification-delta.md` L2509–2525 (P17-002) — declares property (1) *"**REWRITTEN in place** ... BATS vectors rewritten ... **Self-contradiction RESOLVED** ... VP-HOOK-028 stays FINALIZED ... **No mutant added**"* (i.e., no new SM/VP IDs are pending).
- `spec-changelog.md` burst-14 (L33) — claims *"VP-HOOK-028 property-(1) rewritten to JSON-first fail-closed residual boundary."*
- `BC-3.03.001.md` PC#1 (L76) — declares *"BC-10.01.001 Stage-7 PC#8 is the authoritative definition"* for VP-HOOK-028.

**Description.** Burst-14/P17-002 was supposed to eliminate the retired substring-fail-closed
residue on VP-HOOK-028 property (1). The verification-delta and spec-changelog both record
it as **DONE/RESOLVED with no pending IDs**. However, the BC-10.01.001 copy — which is the
document VP-HOOK-028's own citation calls the "authoritative definition" — was **not**
rewritten. Line 616 still asserts the dead property verbatim, and line 618 explicitly states
the work is **pending FV** and that **SM/VP IDs are still to be allocated by FV** — directly
contradicting verification-delta L2524–2525 ("stays FINALIZED... No mutant added"). A reader
of the authoritative BC therefore sees BOTH the retired property AND a note claiming the fix
has not happened, while the verification-delta claims it is complete. This is precisely the
"burst-14 JSON-first fix introduced a new contradiction / retired-mechanism residue" class
the pass-18 mandate flags.

**Concrete failure scenario.** An implementer or verifier reads BC-10.01.001 (the cited
authoritative source) to build VP-HOOK-028's BATS vectors. They encounter the old property
(1) ("mis-named `verdict`-substring path → fail-closed") and the "pending FV / IDs to be
allocated" banner, and implement the *retired* vector (which is tautological under JSON-first
dispatch — a JSON verdict at any `.json` path DOES emit a marker). The verification-delta
meanwhile says that vector is RETIRED and a different residual-path vector is authoritative.
The two sources disagree on what VP-HOOK-028 tests; the "authoritative" BC is the stale one.

**Suggested remediation.** Propagate the completed P17-002 rewrite into BC-10.01.001 L616:
replace the old property (1) text with the actual JSON-first residual fail-closed boundary
(*"a Write with neither `.json` extension nor JSON-parseable content nor `*investigation-*.md`
glob → fast-path-allow → Stage-8 denied"*, per verification-delta L2514–2516), preserve the
old text only as a `Previous` block, and **delete the L618 "pending FV / IDs allocated by FV"
banner** (FV has confirmed no new IDs). Confirm consistency with PC#8 (already JSON-first via
CV-009) and Inv#14 Stage-7 (already JSON-first via P17-002 item 4).

---

## MEDIUM Findings

### P18-003 — Single-verdict → single-marker model cannot authorize the two Jira writes that §3.4 rules 2 & 4 each require

**Severity:** MEDIUM
**Confidence:** HIGH
**Anchors:** `BC-3.03.001.md` WRITE_MARKER (L537–556) writes exactly **one** marker per
verdict Write; `ticket_action_type` (L599) is a single scalar value; `authorized_operations`
is *"Never multi-element"* (L619). `BC-3.01.001.md` consumes one marker per jr Bash call
(atomic rename, L246). `BC-4.02.001.md` PC#7b requires **both** `jr issue link` **and** a
comment; PC#7d requires **both** `jr issue create` **and** a link.

**Description.** Even setting P18-001 aside (i.e., even if `link` had a marker scope), a
single Stage-7 verdict produces a single marker authorizing a single Stage-8 jr write.
Rules 2 (comment + link) and 4 (create + link) each require **two** distinct Jira writes for
one alert's verdict. There is no specified mechanism for one verdict to emit two markers, and
`ticket_action_type` cannot encode a compound action. The loop would need two Stage-7 verdict
Writes with two different `ticket_action_type` values — but the schema/pipeline treats one
verdict = one action.

**Concrete failure scenario.** §3.4 rule 4: loop writes verdict `ticket_action_type=create`
→ one create marker → `jr issue create` succeeds. The subsequent `jr issue link` has no
marker (the create marker was consumed and single-use) → deny. Regardless of the P18-001 link
scope, the second action of the pair is unauthorizable within the one-verdict-one-marker model.

**Suggested remediation.** Specify how compound §3.4 actions (comment+link, create+link) are
authorized — e.g., permit a verdict to emit an ordered marker set, or define a two-verdict
sequence, or fold link into the same marker's `authorized_operations` as an ordered compound
scope. Document in architecture-delta D-DEC-001/D-DEC-008 and BC-10.01.001 Stage 8.

---

## Observations

### P18-004 — BC-4.02.001 Invariant #1 mutation enumeration is incomplete/misleading re: link
`BC-4.02.001.md` Invariant #1 (L85) enumerates gated mutations as *"`jr issue edit`,
`jr issue move`, `jr issue assign`, `jr issue create`, `jr issue comment`"* — omitting
`jr issue link`, which PC#7b itself uses. A reader concludes link is ungated/allowed, but
require-review's fail-closed catch-all denies it (P18-001). The enumeration should either add
`link` (once an authorization path exists) or note that link currently hits the fail-closed
default. Tag: part of the P18-001 remediation surface.

### P18-005 — [process-gap-adjacent] FP "Close (if open)" is unauthorizable and untested; capability status is ambiguous
Brief §3.3 and the disposition table promise `FP → "Close (if open)"` and `BTP → "Close (if
open)"`, but closing requires `jr issue move` (transition to Closed), which has no marker
scope (P18-001) and is write-blocked. No DTU jr-mock scenario exercises a close-transition
(dtu-assessment Dependency 2 tests comment/link/create only, and asserts `jr issue transition`
is NOT called). So autonomous FP-close is either (a) a dead capability that silently leaves
tickets open, or (b) an unstated "close = add closing comment; human transitions" semantics.
The spec should state explicitly which. This is not currently a security issue (fail-closed),
but it is an unresolved behavioral ambiguity in a first-class disposition action.

---

## Coverage Narrative — What I Attacked End-to-End and Why I Am (Otherwise) Satisfied

**Emitter (BC-3.03.001 Invariant #4, STEP 0–6 + WRITE_MARKER).** Re-derived the full
pseudocode. `validate_enums()` (STEP 1) fail-closes on non-member/wrong-case for all typed
fields incl. fields 16–18; SEVERITY_TO_SCORED_PRIORITY_MAP correctly bridges the
SEVERITY_ENUM ≠ SCORED_PRIORITY_ENUM gap ({CRITICAL,MEDIUM} vs {CRIT,MED}). STEP 1a is
correctly framed as consistency-only (LLM-supplied native_severity/sensor_family; ASM-008
residual acknowledged). STEP 3 review path O3-gated on `hard_floor_applies()=true`; over-label
→ allow-without-marker; UNBINDABLE (null project_key / null ticket_id) → HARD-FLOOR-UNBINDABLE
deny with correct fallback-hint dedup semantics. STEP 4 DENY-THE-WRITE fires before the kill
switch, `autonomy_enabled` irrelevant, `required_token` correctly derived. All 5
command_pattern interpolation sites charset-validate + regex_escape (O7). WRITE_MARKER
review-path fail-closed (P10-003). **No contradiction found.**

**D-019 known-FP re-derivation (the mandate's focus).** Walked the high-sev known-FP path:
disposition stays FP; on the fast-path scored_priority = SEVERITY_TO_SCORED_PRIORITY_MAP(
NORMALIZE_SEVERITY(...)); hard_floor_applies() keys HIGH/CRIT on scored_priority with **no
known-FP branch** (confirmed — no LLM `known_fp` field, no exemption at the hook). A high-sev
known-FP therefore fires the floor → routes to comment-review/create-review; if the loop
mislabels it (comment/none to auto-close), STEP 4 DENY-THE-WRITE catches it deterministically.
LOW/MED known-FPs auto-close per D-019. The tuning_signal-non-null-for-FP requirement (PC#4)
is satisfiable on the comment-review path. **The D-019 change interacts correctly with the
re-doc obligation, the HARD-FLOOR-UNBINDABLE path, the livelock cap (≤3), and the kill switch.
No loop between STEP-4 deny and re-doc — bounded fail-closed with one audit entry per attempt.
No new contradiction from burst-14 D-019.**

**Consumer (BC-3.01.001).** Write-block-first ordering preserved; marker-validation branch
inside write-block; path-safety/parse/future-dated/TTL/anchored-pattern/scope checks; STEP 6a
quote-aware + backslash-escape tokenizer (P9-001 v2) sound against the escaped-quote bypass;
iterative-consume FIFO with atomic-rename single-use. Anti-fungibility both directions (EC-023)
correct. **Sound — except it is the artifact that reveals P18-001 (link/move denied with no
path).**

**Markdown separate path (P11-004/P12-002/P13-001).** GATE 1 kill-switch first; strict parse
grammar; FP → allow-without-marker (MARKDOWN_COMMENT_PATH eliminated); non-FP/PARSE_FAIL →
review. EC-005/L814 post-P13-001 residue correctly removed (P17-003). **Consistent.**

**JSON-first dispatch / VP-HOOK-028.** PC#1 Check-1/2/3 and PC#8 and Inv#14 Stage-7 are all
correct JSON-first. **The enforced dispatch behavior is correct — the defect (P18-002) is that
the VP-HOOK-028 *restatement* in the authoritative BC lags the verification-delta rewrite.**

**Light coherence spot-check.** BC versions match task-stated set (BC-3.03.001 v1.26,
BC-3.01.001 v1.22, BC-10.01.001 v1.20, BC-4.02.001 v1.12, BC-5.01.001 v1.12, BC-6.01.001 v1.7,
BC-4.05.001 v1.4). VP count 37 / mutants 49 (SM-9..SM-56, SM-32=32a+32b+32-ext, SM-55 skipped)
consistent across spec-changelog burst-14 and verification-delta. 18-field verdict / 12-field
markdown split consistent. No new coherence defects surfaced.

## Novelty Assessment

**Novelty: MEDIUM-HIGH — genuinely new, not retreading.** P18-001 and P18-003 identify a
structural gap in the loop-action → marker-scope mapping that prior passes (heavily focused on
comment/create/create-review/comment-review scopes and their anti-fungibility) never mapped
against the *complete* §3.4 action set. `jr issue link` — explicitly required by three
artifacts and asserted-as-called by the DTU design — has no authorization path, and the
one-verdict-one-marker model cannot express the compound (comment+link / create+link) actions.
P18-002 is a fresh-context catch of a burst-14 propagation gap: the verification-delta and BC
disagree on whether P17-002 is done, with the authoritative BC carrying a "pending FV" banner.
These are not wording nitpicks; P18-001/P18-002 block convergence. The extensively-swept
surfaces (marker schema, D-019 floor, JSON-first enforcement logic, tokenizer, emitter
ordering) are confirmed intact.

## Updated Confirmed Invariants (monotonic; carried forward + refined)

All 12 prior invariant clusters CONFIRMED INTACT this pass, with two refinements:
1. Marker schema v2.1 sync — intact.
2. JSON-first dispatch → 18-field verdict class; markdown → separate human-comment path;
   BC-10.01.001 PC#8 + Inv#14 Stage-7 JSON-first. **REFINEMENT (P18-002): the VP-HOOK-028
   *property-(1) restatement* in BC-10.01.001 L616 is NOT yet synced to the verification-delta
   rewrite — the enforced logic is JSON-first, but the authoritative VP text is stale.**
3. Two-field severity model (verdict.severity STEP-1a consistency; scored_priority Stage-5
   floor; SEVERITY_TO_SCORED_PRIORITY_MAP on fast-path) — intact.
4. KNOWN-FP FLOOR (D-019): LOW/MED auto-close; HIGH/CRIT fire hard_floor→comment-review; no
   known-FP branch in hook; keys unconditionally on scored_priority — **confirmed intact and
   internally consistent end-to-end.**
5. Emitter order STEP 1→1a→2→3→4→5→6; STEP 3/4 fire regardless of autonomy_enabled — intact.
6. 18-field verdict / 12-field markdown — intact.
7. command_pattern interpolation safety (O7; 5 sites; charset+escape; PRISMDEMO hyphen-free) — intact.
8. MARKDOWN human-comment path (GATE 1 first; no autonomous comment marker; P13-001) — intact.
9. Consumer iterative-consume, anti-fungibility STEP 6a, quote+backslash tokenizer — intact.
   **NEW CONSTRAINT (P18-001): the write-block/allowlist/marker triad has NO scope for
   `jr issue link` or `jr issue move` — these are denied with no authorization path.**
10. STEP-3 HARD-FLOOR-UNBINDABLE deny + STEP-4 DENY-THE-WRITE + re-doc cap (≤3) — intact.
11. Sensor-silence direction; D-DEC-005 sensor-health carve-out — intact.
12. VP/SM namespace: 37 VPs (VP-HOOK 024–032, VP-SKILL 001–077), 49 mutants
    (SM-9..SM-56, SM-55 reserved-skipped) — intact.

**NEW invariant to track once remediated:** §3.4 Jira-first action set {comment, link,
create, close/move, propose-reopen} must be fully mapped to authorizable marker scopes;
compound actions (comment+link, create+link) must have a specified multi-marker authorization.

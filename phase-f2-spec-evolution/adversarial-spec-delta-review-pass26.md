# Adversarial Review — Pass 26 (F2 spec-evolution, prism-integration cycle)

- **Pass:** 26
- **Date:** 2026-07-29
- **Reviewer:** adversary (fresh context; no access to prior-pass reviews)
- **Perimeter/versions:** architecture-delta v1.27, verification-delta v1.27, prd-delta v1.25, dtu-assessment v1.5, spec-changelog (repo-root); BC-3.01.001 v1.25, BC-3.03.001 v1.34, BC-4.02.001 v1.18, BC-4.05.001 v1.4, BC-5.01.001 v1.13, BC-6.01.001 v1.8, BC-6.01.003 v1.7, BC-6.01.004 v1.1, BC-8.02.001 v1.4, BC-9.01.001 v1.2, BC-10.01.001 v1.28.

## Methodology

Fresh re-derivation of the disposition-guard emitter (BC-3.03.001) full decision tree STEP 0→1→1a→2→3→3b→4→4b→5→6, `EMIT_LINK_MARKER`, `WRITE_MARKER`, and the D-029 "Separate Human-Comment Marker Path." Cross-checked the D-029 save-always-succeeds model against its two consumer BCs (BC-4.02.001 PC#4, BC-5.01.001 Inv#7), the BC-10.01.001 Gate-2 audit-grep adjudication, the dtu jr-mock scenarios, the 55 canonical vectors, and the spec-changelog version propagation. Attacked the D-029 all-allow markdown model for new-mechanism abuse (masquerade, kill-switch bypass, review-ticket flood). Verified settled decisions D-023..D-029 are internally coherent (per instruction, attacked completeness of propagation, not the decisions themselves). Applied self-validation (evidence/actionability/duplication) with 3 iterations.

**Coverage note (Level-2 partial):** BC-3.03.001, BC-4.02.001, BC-5.01.001, BC-10.01.001 (Gate-2 + Inv#1/#10 spot checks), dtu-assessment, prd-delta, spec-changelog were read in full where load-bearing. architecture-delta.md and verification-delta.md bodies (585 KB / 748 KB) were NOT read line-by-line; their D-029 state was corroborated via the spec-changelog entries and consumer citations. BC-4.05.001 / BC-6.01.x / BC-8.02.001 / BC-9.01.001 were not re-attacked this pass (out of the D-029 blast radius that is the pass focus).

---

## Critical Findings

None.

---

## Important Findings

### P26-001 — [MAJOR] BC-3.03.001 PC#2 live body still describes the pre-P22-001 / pre-D-029 markdown routing (GATE-1 kill-switch-first + MARKDOWN-HARD-FLOOR deny), contradicting Invariant #4, the canonical vectors, and both consumer BCs

- **Confidence:** HIGH
- **Artifact:** `.factory/phase-0-ingestion/behavioral-contracts/BC-3.03.001.md:98` (Postcondition #2, current live body, tagged `[UPDATED v1.10]`).
- **Defect:** PC#2's authoritative routing summary reads:
  > "Post-P13-001 routing: (a) GATE 1 — `autonomy_enabled` absent or not exactly true → allow-without-marker (kill-switch parity; file saved; no Jira action); (b) markdown-evaluable floors (Indeterminate/forbidden-technique/degraded-silent sensor) → `permissionDecision: deny` (MARKDOWN-HARD-FLOOR); (c) …"

  Both (a) and (b) were superseded:
  - **(a)** was removed at P22-001 (v1.31) — the GATE-1 `autonomy_enabled` kill-switch-first check was deleted; `autonomy_enabled` is no longer a routing gate on this path.
  - **(b)** was eliminated at D-029/P25-001 (v1.34) — markdown hard floors now set `hard_floor_triggered=true` + write an audit annotation with **NO deny, NO RETURN** (see the authoritative pseudocode in the same file at lines 1011–1019, 986, 994).

  PC#2 therefore directly contradicts (i) Invariant #4's Separate Human-Comment Marker Path pseudocode (BC-3.03.001.md:988–1097), (ii) the D-029 canonical vectors (BC-3.03.001.md:1151, 1152 — "Indeterminate → allow + review marker; was: deny pre-D-029"), and (iii) both consumer BCs which were correctly updated (BC-4.02.001.md:67 and BC-5.01.001.md:109, both "D-029 save-always-succeeds … no deny is possible on the markdown path"). This is a partial-fix propagation gap: the D-029 burst updated Invariant #4, the vectors, and the downstream consumers, but the v1.34 "cite sweep" (P25-003) only refreshed version citations and left PC#2's routing prose frozen at the v1.21/P13-001 era.
- **Failure scenario:** An implementer or formal-verifier building the markdown dispatch from PC#2 (the postcondition is the natural spec-of-record for dispatch behavior) implements MARKDOWN-HARD-FLOOR as a **deny** and the autonomy_enabled kill-switch-first short-circuit. Every Indeterminate / T1003 / degraded-sensor analyst investigation save is then denied — the exact D-029 regression the human decision was made to eliminate — while the pseudocode and vectors say allow. The two descriptions are mutually exclusive; the build is wrong under one of them.
- **Remediation direction:** Rewrite PC#2:98 bullet to the D-029 model: hard floors → routing annotation + `hard_floor_triggered=true` (no deny); `autonomy_enabled` not a routing gate; FP+no-hard-floor → allow-without-marker; everything else → MARKDOWN_REVIEW_PATH. Move the current (a)/(b) text into a `> Previous (v1.10/P13-001)` blockquote (siblings at lines 100–106 already follow this pattern).

### P26-002 — [MEDIUM] "no deny is possible on the markdown path" is stated absolutely in three artifacts but the path retains multiple deny branches

- **Confidence:** HIGH
- **Artifacts:** BC-3.03.001.md:994 ("D-029: Write ALWAYS succeeds on this path — no deny is possible"); BC-4.02.001.md:67 (PC#4: "MUST NOT be denied: now holds structurally under D-029 — no deny is possible on the markdown path"); BC-5.01.001.md:109 (Inv#7: "no deny is possible on the markdown path regardless of disposition or sensor state").
- **Defect:** The markdown path still contains deny branches that the absolute claim ignores:
  1. **Charset denies inside the Separate Human-Comment Marker Path itself** — `TICKET-ID-CHARSET-DENY` (BC-3.03.001.md:1064) and `PROJECT-KEY-CHARSET-DENY` (BC-3.03.001.md:1080). A parsed `ticket_id` (from free-text markdown) or config `project_key` failing charset → `emit deny; RETURN`.
  2. **12-field ICD-203 completeness deny** upstream in PC#2 (BC-3.03.001.md:98 / EC-010 at :1118): a markdown missing any of the 12 mandatory headings → deny.
  3. **Alternatives-Considered heading deny** (BC-3.03.001.md:97).

  BC-5.01.001's wording is narrowly scoped ("regardless of disposition or sensor state") and survives, but BC-3.03.001:994 and BC-4.02.001 PC#4 make the **unqualified** claim "no deny is possible on the markdown path," which is false.
- **Failure scenario:** update-jira / investigate-event authors rely on PC#4/Inv#7's guarantee that the analyst investigation Write can never be blocked. An analyst save with a malformed ticket reference the parser extracts as metacharacter-bearing, or a save missing a required heading, is in fact DENIED — breaking the "Document-Before-Action, human save always succeeds" contract the consumers advertise.
- **Remediation direction:** Qualify the invariant in BC-3.03.001:994 and BC-4.02.001 PC#4 to "no **disposition-/hard-floor-based** deny is possible; structural ICD-203 completeness, Alternatives-Considered, and charset-injection guards are retained." Reconcile the three artifacts to one wording.

### P26-003 — [MEDIUM] Markdown review path issues kill-switch-exempt create-review/comment-review markers with NO `hard_floor_applies()` gate, unlike the verdict path STEP 3 — a weaker-gated route to review markers exploitable by markdown-masquerade

- **Confidence:** MEDIUM
- **Artifacts:** BC-3.03.001.md:1050–1085 (MARKDOWN_REVIEW_PATH: "any non-FP disposition (including PARSE_FAIL safe direction) is conservatively routed to human review … EXEMPT from the autonomy_enabled kill switch") vs BC-3.03.001.md:307–311 (verdict STEP 3: `IF action in {create-review,comment-review}` → `IF NOT hard_floor_applies(...): emit allow without marker; RETURN`, the P5-002/O3 over-label cross-validation gate).
- **Defect:** On the verdict path, a review marker is issued **only if `hard_floor_applies()`=TRUE**; a non-hard-floor over-labeled review verdict is rejected (allow-without-marker, no marker). The markdown path applies **no** hard-floor cross-validation — every non-FP / PARSE_FAIL markdown save yields a create-review or comment-review marker, and these markers are kill-switch-exempt (D-DEC-012 Option A). PARSE_FAIL is trivially inducible (any non-allowlist Disposition value, BC-3.03.001.md:1155). Since the `Write` tool can create arbitrary `*investigation-*.md` files, an autonomous agent running with `autonomy_enabled=false` can write a `*investigation-*.md` file (non-FP or ambiguous disposition) to obtain a kill-switch-exempt review marker and then execute `jr issue create --label REVIEW-REQUIRED …` / `jr issue comment <ticket_id> …` — Jira write actions the kill switch is meant to suppress, and for findings that are **not** genuine hard floors (which the verdict path would reject as over-labels). D-029 widened this by converting former markdown hard-floor **denies** (no Jira action) into review-marker issuance (Jira action reachable). There is no hook-side dedup, so repeated saves spam review tickets.
- **Failure scenario:** Operator sets `autonomy_enabled=false` expecting zero autonomous Jira mutations. A buggy/misaligned loop (or an injected instruction) writes investigation-`*.md` files with `Disposition: probably TP` (→ PARSE_FAIL → MARKDOWN_REVIEW_PATH) → review markers → autonomous `jr issue create`/`comment` while the kill switch is nominally engaged. Blast radius is bounded to the review/escalation surface (ticket creation + comments), not auto-close/triage.
- **Remediation direction:** Either (a) explicitly document this asymmetry as an accepted residual in BC-3.03.001 (the markdown path cannot compute `hard_floor_applies()` from a 12-field markdown, so it conservatively routes all non-FP to review; the residual is bounded to the review surface), and add a note to the kill-switch section that `autonomy_enabled=false` does NOT suppress markdown-path review markers; or (b) add a coarse markdown hard-floor requirement (route to review only when a markdown-evaluable hard floor is present OR disposition≠FP AND a markdown "escalation" marker is present), narrowing the un-gated surface. At minimum the residual must appear in the spec, not be silent.

---

## Observations

### P26-004 — [MINOR] Markdown hard-floor gates use unspecified `disposition_section_contains()` / `attack_techniques_contains_forbidden()` reads, inconsistent with the strict `parse_disposition_from_markdown` grammar

- **Confidence:** MEDIUM
- **Artifact:** BC-3.03.001.md:1014–1016 (`disposition_section_contains("Indeterminate")`, `attack_techniques_contains_forbidden([...])`, `sensor_health_status_is("degraded"/"silent")`) vs the strict, adversarially-hardened grammar for `parse_disposition_from_markdown` (BC-3.03.001.md:1022–1033, P13-003).
- **Defect:** The hard-floor GATE 1/GATE 2 reads have no parse grammar. A markdown whose canonical `Disposition` heading is `False Positive` but whose disposition-section prose mentions the word "Indeterminate" (e.g., "we ruled out Indeterminate") will set `hard_floor_triggered=true` (line 1014) while `parse_disposition_from_markdown` returns FP (line 1033) → routed to MARKDOWN_REVIEW_PATH (FP + hard_floor==true). Post-D-029 this is safe-direction (over-escalation, not a deny), but it produces spurious review tickets and is grammar-inconsistent with the disposition read on the same path.
- **Remediation direction:** Specify heading-anchored grammars for the three hard-floor reads mirroring P13-003 (read the canonical `Attack Techniques` / `Sensor Health Status` / `Disposition` heading values only, not free-text scans).

### P26-005 — [MINOR] prd-delta §8 EC-012 description is stale relative to BC-3.03.001 EC-012

- **Confidence:** HIGH
- **Artifact:** `.factory/phase-f2-spec-evolution/prd-delta.md:234` ("EC-012 Indeterminate verdict passes ICD-203 but hard floor **blocks marker issuance**") vs BC-3.03.001.md:1120 (EC-012: Allow the Write; correctly-labeled → review marker; under-labeled → **STEP 4 DENY-THE-WRITE**).
- **Defect:** "hard floor blocks marker issuance" is pre-P7-001 language; the actual EC-012 is DENY-THE-WRITE (under-label) or review-marker issuance (correctly-labeled). Doc-summary staleness only.
- **Remediation direction:** Update prd-delta §8 EC-012 row to the DENY-THE-WRITE / review-marker semantics.

### P26-006 — [process-gap] Repeated "revision-history-in-body" growth pattern makes propagation errors like P26-001 systemically likely

- **Confidence:** MEDIUM
- **Artifact:** BC-3.03.001.md revision history (lines 29–65, ~37 embedded change-log entries) plus 45 inline `Previous (vN.N)` blockquotes throughout the body.
- **Observation:** With normative routing described in *three* places per BC (frontmatter/revision-note, the postcondition prose, and the Invariant-#4 pseudocode) and consumer BCs echoing it, a single decision (D-029) requires 4+ synchronized edits per BC. P26-001 is exactly the failure mode: pseudocode + vectors + consumers updated, postcondition prose missed. This is not a content defect in a single artifact but a structural risk in how routing is duplicated across sections. Recommend a codified single-source-of-truth rule (routing described once in the pseudocode; postcondition prose references it by anchor rather than restating), and a per-burst grep gate for stale `MARKDOWN-HARD-FLOOR.*deny` / `GATE 1.*autonomy_enabled.*allow-without-marker` strings.

---

## Surfaces re-derived and found INTACT

- **STEP 3b hard-floor link (EMIT_LINK_MARKER):** null-binding HARD-FLOOR-UNBINDABLE guards (BC-3.03.001.md:433–460), O7 site-3/site-8 charset, D-028/P23-005 org-binding (LINK-PROJECT-BINDING-DENY), P24-002 O7 site-10 `resolved_project_key` re-validation, and `is_link_hard_floor` → `is_review_path` fail-closed asymmetry are internally coherent and match canonical vectors L1159/L1172/L1173/L1174/L1175/L1176. P24-001 positional-arg / global-var / direct-WRITE_MARKER invocation model is consistently applied at both call sites (:466, :631).
- **STEP 4 / 4b / 5 ordering (D-023/D-025/D-027):** under-label DENY-THE-WRITE before kill switch; CLOSE-DISPOSITION-DENY hoisted to STEP 4b before STEP 5; STEP 6 close-branch retained as defense-in-depth. SM-69 vector (TP+close+autonomy=false → CLOSE-DISPOSITION-DENY, STEP 5 unreachable) is consistent (L1168/L1169) and matches dtu `tp-close-denied` (scored_priority pinned LOW/MED per P24-004).
- **validate_enums() + STEP 1a SEVERITY-MISMATCH + scored_priority floor re-key (P11-002):** 18-field enum membership, case-exact severity, and `hard_floor_applies()` keying on `verdict.scored_priority` are coherent; vectors L1145/L1146/L1148 consistent.
- **BC-10.01.001 Gate-2 D-029 adjudication:** verified the grep alternation `HARD-FLOOR-UNBINDABLE` substring-matches the `MARKDOWN-HARD-FLOOR-UNBINDABLE` audit line, while the plain `MARKDOWN-HARD-FLOOR:` annotation line contains no grep-set substring — so the "intentionally absent / substring-caught" adjudication (BC-10.01.001.md:187) is mechanically correct. `MARKER-WRITE-FAILED` covers both review-path and hard-floor-link write failures without pattern change.
- **D-029 markdown canonical vectors L1151–L1156** are internally consistent with the Separate Human-Comment Marker Path pseudocode (FP+no-floor→allow-without-marker; FP+floor→review; non-FP/PARSE_FAIL→review; T1003→review).
- **Version propagation (D-029 burst):** BC-3.03.001 v1.34 / BC-5.01.001 v1.13 / BC-4.02.001 v1.18 / BC-10.01.001 v1.28 / architecture-delta v1.27 / verification-delta v1.27 / prd-delta v1.25 are mutually consistent in the spec-changelog and consumer cross-cites.
- **CLI surface:** no `jr issue search`/`transition`/`reopen` usages found in the reviewed artifacts; dtu-assessment and BC-4.02.001 correctly use `jr issue list --jql`, `jr issue view --output json`, `jr issue move <state>`, `jr issue link KEY1 KEY2` (no `--type`).

---

## Novelty Assessment

**Novelty: MEDIUM.** P26-001 (PC#2 stale D-029 routing) is a substantive, newly-surfaced propagation gap in the pass-25/D-029 burst — a genuine spec-internal contradiction, not a reword of a known issue. P26-002/P26-003 attack the D-029 all-allow model directly (the pass's mandated new-mechanism axis) and expose a real overclaim and a real hard-floor-gate asymmetry. These are not nitpicks; the package has NOT converged on the D-029 markdown surface.

## Verdict

**RESULT: 0C / 1M / 2med / 2min / 1 obs**

Not a clean pass — 1 MAJOR (P26-001) and 2 MEDIUM (P26-002, P26-003) findings block convergence.

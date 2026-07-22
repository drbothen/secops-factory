---
document_type: adversarial-review
pass: 12
producer: adversary
date: 2026-07-22
cycle: v0.10.0-feature-prism-integration
perimeter: phase-f2-spec-evolution (spec delta package)
---

# Adversarial Review — Pass 12 (F2 spec-evolution delta)

## Summary Table

| ID | Title | Severity | Confidence | Anchor |
|----|-------|----------|-----------|--------|
| P12-001 | `ticket_id` interpolated unescaped into anchored `command_pattern` regex — injection defeats anchored-match property + contradicts D-DEC-001 | CRITICAL | HIGH | BC-3.03.001 STEP 6 / STEP 3 comment-review / Human-Comment path; D-DEC-001 |
| P12-002 | Human-Comment Marker Path (markdown) omits kill switch AND scored_priority/asset_type floors, yet issues a live `comment` marker — LLM artifact-class choice bypasses a deterministic auth control | CRITICAL | MEDIUM-HIGH | BC-3.03.001 "Separate Human-Comment Marker Path"; VP-HOOK-031 |
| P12-003 | Known-FP fast-path `scored_priority = NORMALIZE_SEVERITY result` — cross-enum contamination (severity enum ≠ scored_priority enum) → fail-closed deny of 30–40% of volume; and floor-vs-autoclose contradiction | MAJOR | HIGH | BC-10.01.001 field 18 / Stage 5; architecture-delta §D-DEC-008; BC-3.03.001 SCORED_PRIORITY_ENUM |
| P12-004 | BC-4.05.001 (assess-priority — the PRODUCER of field 18) never updated for P11-002; emits `priority`, never names `scored_priority`; no field mapping documented | MAJOR | HIGH | BC-4.05.001 PC#6 / Output |
| P12-005 | P11-005 "fix" introduced a new mis-anchor: "BC-6.01.001 Invariant #12" — no such invariant exists (gate is Postcondition #12) | MINOR (mis-anchor → blocks convergence) | HIGH | BC-6.01.003 Invariant #6; architecture-delta changelog item E (P11-005) |
| P12-006 | BC-8.02.001 Traceability "L2 Domain Invariants: D-DEC-005 (org_slug scoping on all prism queries)" contradicts the v1.3 sensor-health carve-out | MINOR | HIGH | BC-8.02.001 Traceability |
| P12-007 | [process-gap] No VP/standing-rule requires charset-validation/regex-escaping of any field interpolated into a `command_pattern` regex | OBSERVATION | HIGH | verification-delta; D-DEC-012 O3 table |

---

## Critical Findings

### P12-001 — `ticket_id` interpolated unescaped into the anchored `command_pattern` regex (injection)
**Severity: CRITICAL · Confidence: HIGH**
**Anchor:** `BC-3.03.001.md` STEP 6 (lines 431–451), STEP 3 comment-review (line 356), Separate Human-Comment Marker Path (line 622); `architecture-delta.md` §D-DEC-001 (line 183); require-review consumer `BC-3.01.001.md` / architecture-delta `validate_marker` (`[[ "$COMMAND" =~ $PATTERN ]]`).

**Description.** In every marker path the `command_pattern` is built by string concatenation of `ticket_id` into a regex that require-review later evaluates with `[[ =~ ]]`:
- STEP 6 comment/assign: `pattern = "^jr (--output json )?issue comment " + ticket_id + " "`
- STEP 3 comment-review: `pattern = "^jr (--output json )?issue comment " + ticket_id + " "`
- Human-Comment path: `ticket_id = parse_ticket_id_from_markdown(content)` then the same concatenation.

`ticket_id` is never validated against a Jira-key charset (`^[A-Z][A-Z0-9]+-[0-9]+$`) and is never regex-escaped. The only handling found is `tr -d '\000-\037'` (control-char strip, for the audit line only — architecture-delta line 259 / BC-3.01.001:259). That does not strip regex metacharacters `. * + ? | ( ) [ ] ^ $ \`. `ticket_id` is LLM/attacker-influenceable: it comes from `verdict.ticket_id` (loop-written from Jira/alert content) on the verdict path, and from free-text markdown `content` on the Human-Comment path.

This directly contradicts the D-DEC-001 authoritative claim (architecture-delta line 183): *"it is never supplied by the user or derived from Jira ticket content."* For the markdown path the pattern **is** derived from content; for the verdict path `ticket_id` traces to Jira/alert content. The claim is false, and no escaping compensates.

**Failure scenario.** A crafted investigation markdown (or a verdict whose `ticket_id` was populated from a poisoned Jira/alert field — the pipeline ingests untrusted sensor and Tavily/Perplexity web data) yields `ticket_id = ".*"`. The emitted `command_pattern` becomes `^jr (--output json )?issue comment .* `, which matches **any** `jr issue comment <anything>`. Worse, `ticket_id = "SEC-1 |.*#"` injects an alternation so the pattern matches arbitrary commands. require-review then authorizes commands far outside the intended ticket scope — the exact "unanchored/broadened match" failure mode D-DEC-001 §Context says the mechanism "must be impervious to" (SEC-009 class). This is an LLM/untrusted-content value defeating a deterministic authorization control, and it is **not** covered by the ASM-008 deferral (which concerns ground-truth of severity/asset fields, not regex safety of `command_pattern`).

**Remediation.** Before interpolation, validate `ticket_id` against a strict Jira-key regex (`^[A-Z][A-Z0-9]+-[0-9]+$`) and DENY on mismatch (both paths), OR regex-escape `ticket_id` when building `command_pattern`. Add a VP asserting a metacharacter-laden `ticket_id` cannot broaden the pattern (paired mutant: remove the validation → assert `.*` ticket_id authorizes an unrelated comment command). Correct the D-DEC-001 line 183 claim.

---

### P12-002 — Human-Comment Marker Path bypasses the kill switch and the scored_priority/asset_type hard floors
**Severity: CRITICAL · Confidence: MEDIUM-HIGH (mechanism HIGH; reachability MEDIUM — pending intent adjudication)**
**Anchor:** `BC-3.03.001.md` "Separate Human-Comment Marker Path" (lines 598–629); dispatch Check 2 (PC#2, line 64/77); `VP-HOOK-031` (line 629).

**Description.** The markdown path (reached when `tool_input.file_path` matches `*investigation-*.md`) issues a live `["comment"]` marker after checking ONLY three markdown-evaluable floors — Indeterminate disposition, forbidden techniques {T1003,T1068,T1021,T1041}, degraded/silent sensor (lines 611–613). It explicitly does **not** call `validate_enums()`/STEP 1a and, critically, does **not** read `autonomy_enabled` and does **not** evaluate the §3.9 `scored_priority ∈ {HIGH,CRIT}` floor or the `asset_type ∈ CRITICAL_ASSET_TYPES` floor (line 627 concedes these fields "are NOT checked on this path"). The marker it emits is a regular `comment` op — precisely the class the brief §3.9 kill switch is meant to suppress ("suppresses only autonomous triage decisions (regular comment, create, and assign markers)").

disposition-guard is designed (D-DEC-001 §Context) to be a deterministic control that does **not** trust the LLM's cooperation. But which path fires is chosen entirely by the artifact class the LLM writes (`.json` → gated verdict path; `investigation-*.md` → weaker markdown path). The loop has `Write` in its `--allowedTools` (D-DEC-010), so nothing deterministically prevents the monitoring loop from documenting a disposition as `investigation-*.md`.

**Failure scenario.** Operator sets `autonomy_enabled=false` (kill switch engaged). The loop processes a HIGH-scored TP on a `domain_controller`. Instead of `verdict-*.json` (which would trip STEP 3/4 → create-review/comment-review human surface), the loop writes `investigation-ALERT-x.md` with 12 headings, Disposition=TP, sensor healthy, no forbidden technique. All three markdown floors pass → a `comment` marker is issued → require-review honors `jr issue comment <ticket_id>`. The loop autonomously comments on a HIGH/critical-asset finding **under an active kill switch** and **without** the §3.9 human-review surfacing. Both the kill switch and the high-severity/critical-asset hard floors — deterministic auth controls — are bypassed by an LLM artifact-class choice not covered by ASM-008.

**Intent note (pending adjudication).** The path is intended for the human-driven investigate-event comment (P11-004: "Analyst CAN save a complete investigation markdown without being denied"); for a human, skipping `autonomy_enabled` is defensible. The defect is the absence of any deterministic barrier preventing the *autonomous loop* from selecting this weaker path. VP-HOOK-031/SM-47 only assert the path does not enter the verdict emitter — they do not assert the loop cannot reach it.

**Remediation.** Add a deterministic discriminator so the autonomous loop's Writes cannot obtain a `comment` marker via the markdown path — e.g., require the markdown path to also honor `autonomy_enabled` (deny/allow-without-marker when false), or bind the markdown comment marker to a provenance signal only investigate-event carries, or route markdown dispositions carrying verdict-only-relevant signals to the verdict path. At minimum, document and human-accept the residual explicitly with a VP.

---

## Important Findings

### P12-003 — Known-FP fast-path `scored_priority = NORMALIZE_SEVERITY result`: cross-enum contamination + auto-close contradiction
**Severity: MAJOR · Confidence: HIGH**
**Anchor:** `BC-10.01.001.md` field 18 (lines 313–315), Stage 5 (lines 544–547); `architecture-delta.md` §D-DEC-008 field-18 note (lines 314–315); `BC-3.03.001.md` `SCORED_PRIORITY_ENUM` (line 164) + `validate_enums` (lines 183–185).

**Description (a) — enum-token mismatch.** `SCORED_PRIORITY_ENUM = {"CRIT","HIGH","MED","LOW"}` (BC-3.03.001:164). `NORMALIZE_SEVERITY` produces the **severity** enum `{LOW,MEDIUM,HIGH,CRITICAL}` (BC-10.01.001 field 13; D-DEC-013 "unrecognized → CRITICAL"). Three places state that on the known-FP fast-path (Stage 5 bypassed) `scored_priority = NORMALIZE_SEVERITY result from Stage 1`. When the normalized severity is `MEDIUM` or `CRITICAL`, `scored_priority` is set to `"MEDIUM"`/`"CRITICAL"` — **not members** of `SCORED_PRIORITY_ENUM`. `validate_enums()` (BC-3.03.001:184) then returns `(False, "scored_priority '…' not in {CRIT,HIGH,MED,LOW}")` → DENY.

**Failure scenario.** A noisy high-severity EDR rule that is a documented known-FP (CrowdStrike native "100" → `CRITICAL`) takes the fast-path. `scored_priority="CRITICAL"` → validate_enums DENY → the FP verdict Write is denied → loop re-documents → same `CRITICAL` produced again → after the 3× re-doc cap, HARD-FLOOR-LIVELOCK-ABORT. High-severity known-FPs — the very noise the known-FP store exists to suppress (brief §3.2: 30–40% of volume) — cannot be auto-closed. Fails closed, so no security bypass, but a large documented fast-path is broken by a missing `CRITICAL→CRIT`/`MEDIUM→MED` mapping.

**Description (b) — floor-vs-autoclose contradiction (surfaces even if the mapping is fixed).** With the P11-002 re-key, `hard_floor_applies()` fires on `scored_priority ∈ {HIGH,CRIT}`. A high-native-severity known-FP mapped to `CRIT`/`HIGH` then trips the §3.9 floor → forced to `create-review`/`comment-review` → cannot auto-close as FP, contradicting EC-009's premise (known-FP → auto-close + skip enrichment). The spec must state which wins for a high-severity known-FP.

**Remediation.** Define the fast-path `scored_priority` as an explicit map of `NORMALIZE_SEVERITY` output into `{CRIT,HIGH,MED,LOW}` (CRITICAL→CRIT, MEDIUM→MED), not a raw assignment; add a canonical test vector for a CRITICAL-native known-FP. Then resolve (b): either exempt narrow-scope documented known-FP from the scored_priority floor, or state that high-severity known-FPs route to review (and update EC-009 to stop claiming auto-close for them).

### P12-004 — BC-4.05.001 (producer of `scored_priority`) never updated for P11-002; emits `priority`, no mapping to field 18
**Severity: MAJOR · Confidence: HIGH**
**Anchor:** `BC-4.05.001.md` PC#6 Output (lines 74–98), Invariants, whole file; `prd-delta.md` §5 burst-7 note (line 127).

**Description.** Field 18 `scored_priority` now drives the §3.9 hard floor. Its declared producer is assess-priority (BC-10.01.001 Stage 5 line 544: "assess-priority produces scored_priority (field 18)"; Related-BCs line 664: "BC-4.05.001 … provides prism-grounded scoring at Stage 5"). But BC-4.05.001 is at v1.3 (2026-07-20), predating P11-002 (2026-07-22), and the token `scored_priority` never appears in it (confirmed: BC-4.05.001 absent from the `scored_priority` file-match set). Its PC#6 output emits a field literally named `priority` (`"priority": "CRIT"|"HIGH"|"MED"|"LOW"`). No statement anywhere maps assess-priority's `priority` → verdict `scored_priority`. The prd-delta §5 burst-7 list (line 127) bumped BC-3.03.001, BC-10.01.001, BC-4.02.001, BC-5.01.001, BC-6.01.003 — the **producer** BC-4.05.001 was skipped.

**Failure scenario.** An implementer building assess-priority from BC-4.05.001 emits `priority`; an implementer building the loop from BC-10.01.001 expects `scored_priority`. The field silently never populates, or populates via an undocumented rename, and the hard-floor input for HIGH/CRIT escalation is unreliable — a fail-open risk for the §3.9 floor (the loop's own §3.9 branch depends on a field the producer contract does not define). This is an S-7.01 partial-fix propagation gap: the consumer was patched, the producer was not.

**Remediation.** Bump BC-4.05.001: add a postcondition/invariant that assess-priority's `priority` output IS verdict field 18 `scored_priority` (enum `{CRIT,HIGH,MED,LOW}`), cite P11-002 and BC-10.01.001 Inv#9 field 18, and note the fast-path source when Stage 5 is bypassed.

---

## Minor Findings

### P12-005 — P11-005 replaced a dead reference with another dead reference: "BC-6.01.001 Invariant #12" does not exist
**Severity: MINOR (mis-anchor — blocks convergence) · Confidence: HIGH**
**Anchor:** `BC-6.01.003.md` Invariant #6 (line 106) + revision history (line 32); `architecture-delta.md` v1.14 changelog item E (line 8, "P11-005"). Corroborated against `BC-6.01.001.md`.

**Description.** P11-005 fixed the dead ref "BC-9.01.001 Precondition #9" by pointing to "BC-6.01.001 Invariant #12 / EC-013". But BC-6.01.001 has exactly **six** invariants (Invariants #1–#6, lines 146–159; Edge Cases begin line 161) — there is no Invariant #12. The jira_project_key HARD Stage-0 gate is at **Postcondition #12** (BC-6.01.001:124, under `## Postconditions` at line 45). The architect's own P11-005 remediation note prescribed the wrong "Invariant #12", and the PO propagated it. Blast radius = 2 files (architecture-delta changelog + BC-6.01.003, which repeats it in both Invariant #6 body and revision history). EC-013 is correct, so a reader can partially recover — hence MINOR, but mis-anchors never sit as observations.

**Remediation.** Change "BC-6.01.001 Invariant #12 / EC-013" → "BC-6.01.001 Postcondition #12 / EC-013" in BC-6.01.003 (Invariant #6 + revision history) and in the architecture-delta P11-005 changelog note.

### P12-006 — BC-8.02.001 Traceability L2 line contradicts its own v1.3 sensor-health carve-out
**Severity: MINOR · Confidence: HIGH**
**Anchor:** `BC-8.02.001.md` Traceability, "L2 Domain Invariants" (line 150) vs Invariant #2 (lines 93–100) + Postconditions carve-out (lines 79–84).

**Description.** v1.3 (P9-005) established that `prism_sensor_health` is **exempt** from org_slug isolation. Invariant #2 and the SENSOR-HEALTH CARVE-OUT note reflect this. But the Traceability row still reads "D-DEC-005 (org_slug scoping **on all prism queries**)" (line 150) — the pre-carve-out framing the body explicitly calls "incorrect." Partial-fix propagation gap: the v1.3 edit updated the body but not the Traceability label.

**Remediation.** Update line 150 to "D-DEC-005 (org_slug scoping on raw per-tenant tables; prism_sensor_health carve-out per Invariant #2)".

---

## Observations

- **P12-007 [process-gap].** P12-001 exists because no VP or standing rule requires that any value interpolated into a `command_pattern` anchored regex be charset-validated or regex-escaped. The D-DEC-012 O3 table has rules for tokenization (O5), consumer-consumption (O4), etc., but none for "inputs concatenated into an authorization regex must not be able to alter its metacharacter structure." Recommend adding an O-series standing rule + a VP class, analogous to the O5 differential-vs-bash rule for `--label`. This would have caught the unescaped `ticket_id` surface across the verdict and markdown paths simultaneously.
- **Dispatch weaker-gate selectability (context for P12-002).** Check 1 (JSON-first) → Check 2 (`*investigation-*.md`) → Check 3 (fast-path allow) is internally sound for *distinguishing* artifact classes, but "most-specific-first" does not prevent an actor from *choosing* its artifact class to land on the weaker gate. This is the structural root of P12-002.
- **BC-6.01.004 credential template** uses `echo "<value>" | prism …` (brief §2.3-prescribed). Not a new defect, but the `echo`-into-pipe form exposes the value to shell history/`ps` on the operator's machine; worth a one-line note in the skill that operators should use a history-suppressing form. Non-blocking.

---

## Novelty Assessment

**Novelty: HIGH — these are genuinely new gaps, not re-treads.** Passes 1–11 hardened the verdict-JSON emitter path (JSON-first dispatch, anchored create-pattern, quote-aware `--label` tokenizer, DENY-THE-WRITE, HARD-FLOOR-UNBINDABLE). This pass attacked the two newest P11 additions — field 18 `scored_priority` (P11-002) and the Separate Human-Comment Marker Path (P11-004) — and their interactions:
- P12-001/P12-002 exploit the P11-004 markdown path, which is only two days old and whose prior review (P11) focused on "does not enter the verdict emitter" (SM-47) rather than "what does its own marker issuance authorize."
- P12-003/P12-004 exploit the P11-002 field-18 seam: the fast-path enum-token mismatch and the un-propagated producer contract. Prior passes verified the *consumer/floor* re-key (SM-46) but not the *producer* (BC-4.05.001) or the fast-path source assignment.
- P12-005 is a partial-fix regression in the P11-005 mis-anchor "fix" itself.

The spec has **not** converged: 2 CRITICAL, 2 MAJOR, 2 MINOR (incl. one mis-anchor). This blocks convergence.

---

## Confirmed Invariants (carry-forward + additions)

Carried forward, re-verified intact this pass (spot-check only): (1) Marker schema v2.1 authoritative block in sync; (2) JSON-first dispatch precedes investigation branch; (3) two-field severity model (severity detector-native / scored_priority Stage-5) with floor now keyed on scored_priority; (4) emitter decision-tree order STEP 1→1a→2→3→4→5→6, STEPs 1a/3/4 fire regardless of autonomy_enabled; (5) 18-field verdict schema / 12-field investigation markdown; (6) consumer iterative-consume + audit + base64/control-char stripping; (7) sensor-silence direction `last_seen_ts < now()-24h`; (8) VP/SM namespace collision-free; (9) STEP-3 HARD-FLOOR-UNBINDABLE deny both branches + re-doc cap→LIVELOCK-ABORT; (10) structural_label_check quote+backslash-aware, `--label=` scoped out; (11) marker-write failure: review fail-closed / regular allow-without-marker; (12) cron Gate-2 audit grep; (13) D-DEC-005 sensor-health carve-out (prism_sensor_health sole reference); (14) create/create-review bidirectional anti-fungibility at step 6a; (15) NVD/CVSS → scored_priority only, native_severity = raw sensor reading.

**Additions confirmed this pass:**
16. `SCORED_PRIORITY_ENUM = {CRIT,HIGH,MED,LOW}` is validate_enums-enforced (fail-closed) — distinct token set from `SEVERITY_ENUM = {LOW,MEDIUM,HIGH,CRITICAL}`; `CRIT≠CRITICAL`, `MED≠MEDIUM`. Any assignment from a severity-enum source into `scored_priority` requires an explicit mapping (violated on the known-FP fast-path — P12-003).
17. `scored_priority` (field 18) is validate_enums key-present + membership-checked and drives the §3.9 HIGH/CRIT floor; its producer contract BC-4.05.001 does NOT define it (P12-004) — producer/consumer coherence is currently BROKEN.
18. `command_pattern` is built by concatenating `ticket_id` in both the verdict emitter and the Human-Comment path; `ticket_id` is NOT charset-validated or regex-escaped (only control-char-stripped for audit) — anchored-match property (d) is currently DEFEATABLE (P12-001).
19. The Human-Comment Marker Path issues a regular `["comment"]` marker and evaluates ONLY {Indeterminate, forbidden techniques, degraded/silent}; it does NOT read `autonomy_enabled`, `scored_priority`, or `asset_type` (P12-002).
20. BC-6.01.001 has exactly 6 Invariants; the jira_project_key HARD Stage-0 gate is Postcondition #12 (not Invariant #12) — cross-references must say "Postcondition #12" (P12-005).

**Coverage narrative:** Attacked all four priority targets. Target 1 (scored_priority field 18/floor) → P12-003 (fast-path enum + auto-close contradiction) + confirmed floor re-key/SM-46 intact. Target 2 (Human-Comment path / VP-HOOK-031) → P12-002 (kill-switch + floor bypass via artifact-class choice) + P12-001 (markdown `ticket_id` regex injection). Target 3 (two-field model across BC-4.05.001/BC-10.01.001 Stage 5) → P12-004 (producer never emits/maps scored_priority). Target 4 (less-attacked BCs) → BC-6.01.004/BC-8.02.001/BC-9.01.001/BC-6.01.003 read in full; found P12-005 (mis-anchor) and P12-006 (stale Traceability). Not exhaustively re-derived: the full require-review consumer pseudocode and D-DEC-002 watermark internals (spot-checked, prior-pass invariants relied upon).

**Relevant files:**
- `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-3.03.001.md` (P12-001, P12-002, P12-003)
- `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` (P12-003)
- `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-4.05.001.md` (P12-004)
- `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-6.01.003.md` and `BC-6.01.001.md` (P12-005)
- `/Users/jmagady/Dev/secops-factory/.factory/phase-0-ingestion/behavioral-contracts/BC-8.02.001.md` (P12-006)
- `/Users/jmagady/Dev/secops-factory/.factory/phase-f2-spec-evolution/architecture-delta.md` (D-DEC-001 line 183, D-DEC-008, P11-005 changelog)
- `/Users/jmagady/Dev/secops-factory/.factory/phase-f2-spec-evolution/prd-delta.md` (§5 burst-7 note, Verdict Schema Summary)
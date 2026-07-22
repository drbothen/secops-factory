---
document_type: adversarial-review
pass: 8
producer: adversary
date: 2026-07-21
cycle: v0.10.0-feature-prism-integration
scope: F2 spec-evolution delta package (brief, architecture-delta v1.10, verification-delta v1.10, prd-delta v1.9, BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12, BC-4.02.001, BC-4.05.001, BC-5.01.001, BC-6.01.001, dtu-assessment, asm-004-validation, spec-changelog)
---

# Adversarial Review — Pass 8

## Summary Table

| Severity | Count | IDs |
|----------|-------|-----|
| CRITICAL | 1 | P8-001 |
| MAJOR    | 2 | P8-002, P8-004 |
| MINOR    | 1 | P8-003 |
| OBSERVATION | 2 | P8-OBS-1, P8-OBS-2 |

**NOT a clean pass.** One genuine CRITICAL residual silent-discard path survives all seven prior passes; it is the *exact* failure class (hard-floor finding silently dropped, enforcement delegated to the trusted-LLM layer) that P5-001 and P7-001 were opened to eliminate — but on a code path those passes never touched.

---

## Critical Findings

### P8-001 — Correctly-labeled hard-floor review verdict with null `jira_project_key`/`ticket_id` is SILENTLY ALLOWED WITHOUT MARKER at emitter STEP 3, contradicting the D-DEC-012 fail-loud invariant — CRITICAL

**Confidence:** HIGH

**Location (three coincident anchors):**
- `architecture-delta.md` §D-DEC-008 emitter pseudocode STEP 3, create-review branch (lines 1205–1223): `IF project_key is null OR project_key == "": emit allow without marker / RETURN`; comment-review branch identical for null `ticket_id`.
- `BC-3.03.001.md` Invariant #4 emitter, STEP 3 (lines 231–246): `IF project_key is null OR project_key == "": emit allow without marker # cannot bind review-create without project key / RETURN`; comment-review `IF ticket_id is null: emit allow without marker / RETURN`.
- Contradicted by `architecture-delta.md` §D-DEC-012 "Fail-loud invariant" (lines 1952–1958): a hard-floor/Indeterminate verdict MUST result in **either** a review marker issued+consumed **OR** "an explicit error artifact written to audit.log AND a deny emitted (if no project_key is available to bind the review marker). NEVER: silent discard."
- Also contradicted by `BC-10.01.001.md` Invariant #10 / EC-015 / EC-021 negative assertion (lines 343, 482, 488): "a hard-floor verdict MUST NOT leave the marker directory empty after Stage-7 Write."

**Description:** The entire pass-5→pass-7 arc (STEP-4 deny-the-Write, O3/O4 standing rules) is built on the principle that the deterministic hook must *never trust an LLM-supplied field to be present* and must fail loud when a hard-floor finding cannot be surfaced. STEP 4 correctly enforces this for the *under-label* case (non-review `ticket_action_type`): it denies the Write, writes `UNDER-LABEL-DENIED`, and returns a machine-readable `required_token`.

But the *correctly-labeled-yet-unbindable* case was never closed. When the loop sets `ticket_action_type = "create-review"` (genuinely hard-floor, `hard_floor_applies()=true`) but omits/nulls the non-ICD-203 operational field `jira_project_key`, STEP 3 emits **`allow without marker` and RETURNs** — no marker, no `UNDER-LABEL-DENIED` audit entry, no structured corrective reason, no deny. The `comment-review` + null `ticket_id` path is identical. `jira_project_key`/`ticket_id` are NOT in the 15-field presence check and NOT in `validate_enums()`, so a verdict passes every prior gate with these fields absent. The verdict Write succeeds; disposition-guard raised no objection; and the hard-floor finding is **silently discarded** at exactly the point D-DEC-012 clause 2 says an "explicit error artifact + deny" is mandatory.

This is the P5-001 anti-pattern verbatim (architecture-delta line 1961: "it delegated enforcement to the trusted-LLM layer, the exact surface P5-001 exploited") — it merely delegates to the loop the obligation to have populated `jira_project_key`, instead of failing loud when it is missing.

**Failure scenario:** Unattended cron run. A silent-sensor BLIND-SPOT verdict (`sensor_health_status=silent` → hard floor) is documented with `ticket_action_type="create-review"` but the LLM omits `jira_project_key`. STEP 3 → `allow without marker`. The loop then either (a) runs `jr issue create` without `--project` → require-review denies with the *generic* "review approval" reason (no `required_token`, so the loop cannot self-correct), or (b) writes nothing further. Either way: no BLIND-SPOT ticket, no audit trail of the drop, no VP catches it (VP-HOOK-029's review-token vector asserts a marker IS emitted and consumable; it has no vector for the review-token + null-binding sub-case). A SOC analyst never learns the sensor went blind — the precise "could not observe misread as clean clearance" failure the brief §3.7 and O4 rule exist to prevent.

**Why prior passes missed it:** Passes 5–7 focused exclusively on the *under-label* dual (non-review token). The correctly-labeled review path was treated as the "happy path" and never adversarially probed for its own missing-binding sub-case. VP-HOOK-029's re-scope (P7-004) asserts the consumer-boundary outcome only for verdicts that reach a marker — it structurally cannot see a STEP-3 `allow without marker` return.

**Remediation:** In STEP 3, replace both `emit allow without marker; RETURN` branches (create-review null project_key; comment-review null ticket_id) with the fail-loud path mandated by D-DEC-012 clause 2: write a `HARD-FLOOR-UNBINDABLE` (or reuse `UNDER-LABEL-DENIED`) audit entry naming the missing binding field, and `emit deny` with a structured corrective reason (`hard_floor_trigger`, `missing_field=jira_project_key|ticket_id`, instruction to re-issue with the field populated). Propagate to BC-3.03.001 STEP 3, architecture-delta §D-DEC-008 pseudocode, and add a VP-HOOK-029 vector: "hard-floor verdict + create-review + null jira_project_key → verdict Write DENIED + audit entry; NEVER silent allow-without-marker."

---

## Important Findings

### P8-002 — P7-005 "structural token detection" fix does NOT respect shell quoting; the specified `split_on_whitespace` still false-denies its own EC-024 example — MAJOR

**Confidence:** HIGH

**Location:** `BC-3.01.001.md` consumer step (6)/(6a) `structural_label_check` pseudocode (lines 127–139) and EC-024 (line 308); `architecture-delta.md` §D-DEC-001 lines 231–240; canonical test-vector row (line 330). Grounded against the real hook `plugins/secops-factory/hooks/require-review.sh:45`: `COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')`.

**Description:** P7-005 replaced the raw substring `has_review_label` check with `structural_label_check(cmd)`, defined as:
```
tokens = split_on_whitespace(cmd)
for i in range(len(tokens)-1):
  if tokens[i]=="--label" AND tokens[i+1] in {"REVIEW-REQUIRED","BLIND-SPOT"}: return True
```
The hook receives `tool_input.command` as the **raw command string including quote characters** (confirmed at require-review.sh:45 — `jq -r '.tool_input.command'` returns the literal string; no shell expansion has occurred). A naive whitespace split does **not** respect quotes. For EC-024's own example — `jr issue create --project PRISM-DEMO --summary "rule matched literal --label REVIEW-REQUIRED in alert payload"` — the split yields tokens `... "--summary", "\"rule", "matched", "literal", "--label", "REVIEW-REQUIRED", ...` where `--label` is a **standalone token immediately followed by `REVIEW-REQUIRED`**. `structural_label_check` therefore returns **True**, `has_review_label=true`, and a `["create"]` marker is skipped → **the false-deny the fix claims to eliminate still fires.**

EC-024 is internally self-contradictory: it states both *"If the shell delivered it as separate tokens, structural_label_check fires"* and, for the same input, *"`has_review_label=false`; ... marker consumed; `permissionDecision: allow`."* The hedge "in practice `--summary` quoting collapses its value" is false for this hook — the hook never sees post-shell-expansion arguments; it sees the quoted command string, and `split_on_whitespace` provably does not collapse quoted values.

**Failure scenario:** Any legitimate autonomous FP-close create whose `--summary` narrates a rule containing the literal token sequence `--label REVIEW-REQUIRED` (common in SOC alert text) is denied by its own valid `["create"]` marker. Fail-closed, so no security breach, but the loop cannot create the ticket and produces a spurious permission_denial that trips the wrapper's `permission_denials > 0 → exit 1` gate (BC-10.01.001 PC#7) — a false cron failure.

**Remediation:** Specify a quote-aware tokenizer (respect single/double quotes; a `--label` flag inside a quoted `--summary` value must NOT be treated as a standalone token), or match `--label (REVIEW-REQUIRED|BLIND-SPOT)` structurally against the flag region only. The pseudocode `split_on_whitespace` must be replaced, and EC-024's contradictory narrative reconciled to the actual (quote-aware) mechanism.

### P8-004 — prd-delta.md VP-lifecycle statuses and §5 BC-version column are stale/inverted vs the live BCs and verification-delta — MAJOR

**Confidence:** HIGH

**Location:** `prd-delta.md` (v1.9) §1 table line 39 and §5 table lines 115–118.

**Description:** prd-delta is the PRD-level ledger of the F2 modifications, but its VP-status and version data contradict the live source-of-truth:
1. **VP-HOOK-029 inverted:** prd-delta §1 line 39 lists `VP-HOOK-029 (P1 PROPOSED)`. verification-delta v1.10 re-FINALIZED it (P0) and BC-3.01.001/BC-3.03.001 cite it as FINALIZED.
2. **VP-SKILL-065 inverted:** prd-delta §1 line 39 lists `VP-SKILL-065 (FINALIZED)`. Pass-6 (ADV-F2-P6-003 MAJOR) deliberately RE-SCOPED it to **PROPOSED** — BC-10.01.001 v1.11 (line 375, 516) and verification-delta v1.9 both carry `PROPOSED — re-scope pending`. prd-delta asserts the opposite of a deliberate, MAJOR-severity status change.
3. **§5 "New Version" column stale by 2–3 versions on the three most-modified BCs:** prd-delta §5 shows BC-3.01.001 `→ v1.17`, BC-3.03.001 `→ v1.13`, BC-10.01.001 `→ v1.9`. Live frontmatter is **v1.19 / v1.16 / v1.12** (passes 5–7 not reflected). The prd-delta changelog itself stops at v1.9 "Pass-5 (P5-004)".

Items (1) and (2) are semantic VP-lifecycle contradictions, not mere version-number drift, so they are NOT covered by the deferred "version-coherence sweep" the architecture-delta/verification-delta repeatedly cite. An implementer or story-writer consuming prd-delta as the PRD ledger would treat VP-HOOK-029 as still-open (PROPOSED) and VP-SKILL-065 as settled (FINALIZED) — both wrong.

**Failure scenario:** F3 story sizing / VP-INDEX population reads prd-delta §1 as the authoritative VP-status roster, mis-marks the fail-loud consumer-boundary VP (the single most load-bearing security VP in the cycle) as unadjudicated, and treats the re-scoped kill-switch VP as done — leaving the pass-6 re-scope obligation unimplemented.

**Remediation:** Update prd-delta §1 line 39 (VP-HOOK-029 → FINALIZED; VP-SKILL-065 → PROPOSED/re-scoped) and §5 New-Version column (v1.19 / v1.16 / v1.12) with pass-5/6/7 change summaries. Minor sibling: BC-10.01.001 VP-Anchors footer (line 534) also still reads "VP-HOOK-029 (... P1 PROPOSED — FINALIZED strategy v1.9)" — reconcile to the re-FINALIZED status per Partial-Fix Regression Discipline (blast radius ≥ 2 files).

---

## Minor Findings

### P8-003 — EC-023 / command_pattern-generation-table claim that the create pattern's `( |$)` boundary structurally rejects a review-labeled create at consumer step 5 is factually wrong; anti-fungibility rests entirely on step 6a — MINOR

**Confidence:** HIGH

**Location:** `BC-3.01.001.md` EC-023 direction (A) (line 307): *"the regular create pattern `^jr ... issue create --project PRISM-DEMO( |$)` does NOT match a command containing `--label REVIEW-REQUIRED` because `--label` appears before the `( |$)` anchor, causing the regular pattern to fail at step 5 (structural defense-in-depth)."* Same reasoning implied in the generation-table `create` row (BC-3.03.001 line 437; architecture-delta line 1057).

**Description:** `( |$)` matches a single space OR end-of-string, and bash `[[ "$COMMAND" =~ $PATTERN ]]` is **not tail-anchored** (no trailing `$` outside the group). For `jr issue create --project PRISM-DEMO --label REVIEW-REQUIRED --summary "..."`, the regex `^jr issue create --project PRISM-DEMO( |$)` matches the prefix up to the space after `PRISM-DEMO` — **step 5 PASSES**, contrary to the EC-023 claim. The `( |$)` boundary does exactly one thing (its P4-002 purpose): prevent the project-KEY from prefix-matching a longer key (`PRISM-DEMO` vs `PRISM-DEMO-2`). It does NOT prevent the pattern from matching a longer command with more flags. Therefore the create/create-review anti-fungibility (direction A) depends **solely** on consumer step 6a — there is no "step 5 structural defense-in-depth" backstop as claimed.

**Why it matters:** This compounds P8-002 — the claimed step-5 backstop that would catch a mis-fired 6a does not exist. The security direction still holds (a genuine `--label REVIEW-REQUIRED` flag correctly trips 6a and is denied), so this is MINOR, but the spec's reasoning is incorrect and would mislead an implementer into believing step 5 provides redundant protection it does not.

**Remediation:** Correct EC-023 (both directions) and the generation-table notes to state that step 5's `( |$)` guards only against project-KEY prefix extension; the review/regular anti-fungibility is enforced *exclusively* at step 6a (`structural_label_check`). This also makes P8-002 the single point of failure for anti-fungibility, raising its priority.

---

## Observations

- **P8-OBS-1 [process-gap]:** The append-only PO/FV propagation lists in architecture-delta §8.12–§8.17 (and verification-delta §7 Parts F/G/H) retain superseded pass-5/pass-6 "upgrade to create-review / GOTO WRITE_MARKER / UNDER-LABEL-CORRECTED" instructions as directive text without inline forward-links to their pass-7 retirement. An implementer reading §8.12.1 item 2 or §8.13 item 1 in isolation (each is version-stamped "pass 5", but the RETIRED status lives only in §8.16/§8.17 and the changelog) could apply the retired marker-upgrade mechanism that P7-001 proved structurally unsound. The retirement is correctly recorded in the live bodies (D-DEC-008 STEP 4, BC-3.03.001 v1.16) — this is purely a navigability hazard in the historical propagation ledgers. Recommend a one-line "SUPERSEDED BY §8.16 (P7-001 deny-the-Write)" banner at the head of §8.12.1/§8.13.

- **P8-OBS-2:** `hard_floor_applies()` evaluates `verdict.attack_techniques` for {T1003,T1068,T1021,T1041}. On the known-FP fast-exit path, EC-009 correctly mandates Stage 3 runs first to populate this field. But `hard_floor_applies()` also reads `verdict.severity`/`asset_type` which, on the fast-path, are sourced from *raw sensor data at Stage 1 INGEST* via `NORMALIZE_SEVERITY` — and Cyberint (and any unrecognized family) normalizes to **CRITICAL** (D-DEC-013). This means *every* Cyberint alert is a hard floor pre-ASM-008, so *every* Cyberint verdict must route through create-review/comment-review. This is correct-by-conservatism but will mass-escalate 100% of Cyberint traffic to human review until ASM-008 resolves — worth an explicit operator-facing note in BC-8.02.001/BC-10.01.001 so the demo does not surface as "Cyberint integration floods the review queue." Not a defect; a foreseeable operational surprise.

---

## Confirmed Invariants (verified intact this pass — for accumulation into pass-9 prompt)

- Marker schema v2.1 authoritative block (BC-3.03.001 lines 378–397) is in sync with the emitter WRITE_MARKER block and D-DEC-001 (O3 schema-sync obligation satisfied).
- JSON-first dispatch (BC-3.03.001 PC#1) correctly precedes the `investigation`-substring branch; canonical `artifacts/investigations/verdict-*.json` routes to the 15-field verdict class (VP-HOOK-028).
- Hard-floor keys on `verdict.severity`/`asset_type` (fields 13/14), NOT confidence (ADV-F2-001); `asset_type=unknown` is a separate explicit floor (ADV-F2-P3-001) — present in BC-3.03.001 lines 448–451 and BC-10.01.001 Inv#10.
- STEP 4 (deny-the-Write) is positioned BEFORE STEP 5 (kill switch) in both architecture-delta and BC-3.03.001; `autonomy_enabled` irrelevant to STEP 4 (P6-002/P7-001).
- Six stale "no marker" locations in BC-10.01.001 (EC-015/016/017/021 + two test vectors) all corrected to create-review/comment-review + negative assertion (P7-002) — propagation verified complete.
- Consumer iterative-consume (sort by issued_at_utc ASC, rename-fail→CONTINUE), audit path `${CLAUDE_PLUGIN_DATA}/markers/audit.log`, base64 command + control-char strip on ticket_id/org_slug/op — all intact (BC-3.01.001 Inv#2, step 8).
- Inverted silence condition (`last_seen_ts < now()-24h`) corrected and internally consistent with the 36h test vector (BC-10.01.001 Inv#5/EC-006, P4-003).
- Namespace: VP-SKILL 001–074, VP-HOOK 024–029, SM 9–40 — no collisions observed; SM-2026 correctly identified as a date false-positive.

---

## Novelty Assessment

**Novelty: MEDIUM-HIGH — one genuinely new CRITICAL, not a rewording.**

P8-001 is a substantive, previously-undetected silent-discard residual on the *correctly-labeled* review path — orthogonal to the under-label axis that passes 5–7 exhaustively hardened. It is exactly the fresh-context value the loop is designed to extract: prior passes anchored on the under-label/over-label dual and treated the review-token path as the solved happy path, so none probed its missing-binding sub-case, and the covering VP (VP-HOOK-029) is structurally blind to a STEP-3 `allow without marker` return. P8-002 is a real implementation-vs-spec gap in the *most recent* fix (P7-005), grounded in the actual hook's command-string handling — the "fix" provably fails its own documented example. P8-003 and P8-004 are correctness/coherence contradictions that block convergence per the mis-anchoring and version-sync review axes.

The spec has NOT converged: P8-001 (CRITICAL silent-discard of a hard-floor finding, in direct contradiction of the D-DEC-012 fail-loud invariant the whole cycle was built to enforce) and the two MAJORs must be remediated. Recommend a pass-9 after fixes, with particular attention to whether the STEP-3 missing-binding fix introduces a new non-termination path (loop re-documents create-review, still omits project_key → must not silent-loop).
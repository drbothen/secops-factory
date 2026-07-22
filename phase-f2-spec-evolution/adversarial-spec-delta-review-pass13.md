---
document_type: adversarial-review
pass: 13
producer: adversary
date: 2026-07-22
feature: v0.10.0-feature-prism-integration
phase: f2
cycle: v0.10.0-feature-prism-integration
perimeter: phase-f2-spec-evolution (spec delta package)
---

# Adversarial Spec-Delta Review — Pass 13

## Summary Table

| ID | Title | Severity | Primary Anchor |
|----|-------|----------|----------------|
| P13-001 | MARKDOWN_COMMENT_PATH issues autonomous `jr comment` marker for any LLM-labeled FP, bypassing the scored_priority/asset_type hard floors AND the known-FP store-integrity bound | CRITICAL | BC-3.03.001 §"Separate Human-Comment Marker Path" (MARKDOWN_COMMENT_PATH) |
| P13-002 | Charset validators `^[A-Z][A-Z0-9]+$` / `^[A-Z][A-Z0-9]+-[0-9]+$` reject the canonical demo project key `PRISM-DEMO` / ticket `PRISM-DEMO-42`; fail-closed drop breaks the RC-gating demo and self-contradicts the comment-review fallback hint | CRITICAL | BC-3.03.001 P12-001 charset; brief §4.1/§3.5 |
| P13-003 | `parse_disposition_from_markdown` / `parse_autonomy_enabled_from_markdown` grammar unspecified; an FP-direction mis-parse routes a non-FP finding to the autonomous comment path, and no fail-closed-to-review rule is stated | MAJOR | BC-3.03.001 §"Separate Human-Comment Marker Path" (parse helpers) |
| P13-004 | PC#2 outcome prose still describes pre-P12-002 behavior ("floors pass → comment-scoped marker") — not updated for GATE 1 kill-switch or the non-FP→review route | MINOR | BC-3.03.001 Postcondition #2 (line 84) |

No CLEAN PASS — two CRITICAL findings block convergence.

---

## Critical Findings

### P13-001 — MARKDOWN_COMMENT_PATH grants autonomous FP comment marker with no scored_priority/asset_type floor and no store backing
**Severity:** CRITICAL · **Confidence:** HIGH
**Anchor:** `BC-3.03.001.md`, "Separate Human-Comment Marker Path (P11-004 / redesigned P12-002)", `MARKDOWN_COMMENT_PATH` branch (lines 743–749); confirmed by canonical test vector line 800; contrasted with BC-10.01.001 field-18 known-FP exemption (lines 321–325).

**Description.** The P12-002 redesign added GATE 1 (autonomy_enabled kill switch) to the markdown path to "close the autonomous-loop-masquerade bypass." It did not close it for the FP case. The route rule is:
- `parsed_disposition != "FP"` → MARKDOWN_REVIEW_PATH (safe: review marker)
- `parsed_disposition == "FP"` + `autonomy_enabled=true` → MARKDOWN_COMMENT_PATH → **plain `comment` marker written, `allow` emitted**.

On this path the hook explicitly does NOT call `validate_enums()` or STEP 1a, and — critically — **cannot evaluate `scored_priority` (field 18) or `asset_type` (field 14)** because they are not present in a 12-field ICD-203 markdown. Therefore the two deterministic hard floors that would fire on the equivalent JSON verdict (scored_priority ∈ {HIGH,CRIT}; asset_type critical/unknown) are structurally unenforceable here, and the markdown FP branch grants an **autonomous `jr issue comment`** regardless.

On the JSON verdict path, an FP with `scored_priority=HIGH` hits `hard_floor_applies()=true` and is forced to review (STEP 3) or DENY-THE-WRITE (STEP 4); the ONLY FP-that-gets-an-autonomous-comment exemption is the known-FP fast-path, which BC-10.01.001 lines 321–325 explicitly bound with store-integrity invariants ("store MUST NOT be LLM-writable, changes MUST be audited, entries MUST be periodically reviewed" — the DI-015 tracked residual). The markdown path applies NONE of these: the FP label is raw LLM free-text output, and there is no store cross-check. It is therefore an **unbounded version of the known-FP exemption**, and is NOT covered by the DI-015 tracked deferral (which relies entirely on store backing).

This is an LLM-supplied value (`disposition=FP` written into a markdown artifact the loop chose to produce) bypassing a deterministic control (scored_priority/asset_type hard floor) that is not covered by any tracked deferral — CRITICAL per the mandate. The mutant coverage does not catch it: verification-delta SM-51 removes the *route-to-review rule* (covers a **TP** getting a comment marker); it does not test that the **FP branch itself** is a floor bypass with the route rule intact.

**Failure scenario.** The monitoring loop (or a buggy/adversarial loop step) writes `artifacts/…/investigation-ALERT-9.md` containing the 12 ICD-203 headings, `autonomy_enabled: true`, `Sensor Health Status: healthy`, no forbidden technique, and `Disposition: FP` — for an alert that is in fact HIGH scored_priority on a domain controller. GATE 1 passes, GATES 2/3 pass (none of the three markdown-evaluable floors apply), `parsed_disposition=FP` → MARKDOWN_COMMENT_PATH → a `["comment"]` marker for `SEC-123` is written, and the loop autonomously comments/annotates the ticket. Had the identical finding been emitted as JSON, the scored_priority=HIGH + asset_type=domain_controller floors would have forced human review. The reachability precondition (loop emits markdown, not its Stage-7 JSON) is exactly the masquerade P12-002 accepts as its threat model — GATE 1's existence presupposes it.

**Remediation.** The markdown path must never issue a plain (non-review) `comment` marker, because it cannot evaluate the scored_priority/asset_type floors. Either (a) route **all** markdown dispositions — including FP — to `allow-without-marker` (a human analyst comments manually; the autonomous loop has no legitimate reason to obtain a comment marker via markdown), or (b) route FP-with-autonomy_enabled to MARKDOWN_REVIEW_PATH as well (conservative escalation), or (c) delete MARKDOWN_COMMENT_PATH entirely. Add a VP/mutant that keeps the route rule intact and asserts an FP markdown does NOT yield a plain comment marker (distinct from SM-51).

---

### P13-002 — Charset validators reject the canonical demo project key `PRISM-DEMO` / ticket `PRISM-DEMO-42`; fail-closed drop breaks the RC-gate demo
**Severity:** CRITICAL · **Confidence:** HIGH
**Anchor:** `BC-3.03.001.md` P12-001 charset (`ticket_id → ^[A-Z][A-Z0-9]+-[0-9]+$`; `jira_project_key → ^[A-Z][A-Z0-9]+$`; STEP 3/6 pseudocode lines 324, 380, 470, 490, 510, 708, 731; §"P12-001/O7 charset-validation" line 649). Contradicted by brief §4.1 line 485 ("demo Jira project … key `PRISM-DEMO`") and §3.5 line 306 ("ticket PRISM-DEMO-42"); and by BC-3.03.001's own test vector line 794 (`jira_project_key="PRISM-DEMO"` + fallback hint asserting it is usable for a create-review re-issue).

**Description.** The mandate asked directly: "does rejecting a valid key cause a fail-closed drop?" It does. The ticket_id validator `^[A-Z][A-Z0-9]+-[0-9]+$` matches exactly one hyphen followed by digits. The canonical demo ticket `PRISM-DEMO-42` parses as `P` + `RISM` + then requires `-[0-9]+$` but the next characters are `-DEMO-42` → the `[0-9]+` cannot match `DEMO` → **no valid parse → TICKET-ID-CHARSET-DENY**. Likewise the project-key validator `^[A-Z][A-Z0-9]+$` forbids hyphens, so `jira_project_key="PRISM-DEMO"` → **PROJECT-KEY-CHARSET-DENY**.

The brief (the human-approved RC authority) explicitly directs seeding a demo Jira project keyed `PRISM-DEMO` with tickets like `PRISM-DEMO-42`, and §1 states "Successful live demo through secops-factory IS the RC gate." With the charset as written, **every** comment/assign/comment-review marker for a demo ticket is denied fail-closed, and every create/create-review marker for the demo project is denied — i.e., the RC-gating demo cannot issue a single Jira write through the marker mechanism.

The defect is compounded intra-document: the comment-review fallback hint (line 360 / test vector line 794) tells the loop `jira_project_key=PRISM-DEMO is present … re-issue with ticket_action_type=create-review` — but the create-review path (line 324) would immediately PROJECT-KEY-CHARSET-DENY on `PRISM-DEMO`. The corrective guidance routes the loop into a guaranteed second fail-closed deny.

**Failure scenario.** Demo operator seeds project `PRISM-DEMO` per brief §4.5. Loop produces a hard-floor Indeterminate verdict for `PRISM-DEMO-42`, sets `ticket_action_type=comment-review`, `ticket_id="PRISM-DEMO-42"`. disposition-guard reaches STEP 3 comment-review charset check → `^[A-Z][A-Z0-9]+-[0-9]+$` fails on `PRISM-DEMO-42` → TICKET-ID-CHARSET-DENY. The hard-floor review finding is dropped (loudly, but unrecoverably — every re-doc fails identically). RC demo fails.

**Remediation.** Reconcile the canonical demo key across the spec set. Real Jira project keys are hyphen-free, so the regex is correct-for-Jira; the defect is the example. Change the demo project key to a hyphen-free value (e.g., `PRISMDEMO`, tickets `PRISMDEMO-42`, or `SEC` as used elsewhere in the test vectors) in brief §3.5/§4.1/§4.5 and in BC-3.03.001 line 360/794. Add an explicit constraint note in the brief and the onboard/activate flow that any Jira project key used with the marker mechanism MUST match `^[A-Z][A-Z0-9]+$` (no hyphens/underscores), and add a demo-seed validation that rejects a non-conformant key at setup time (fail-early rather than fail-closed mid-demo).

---

## Important Findings

### P13-003 — Markdown disposition/autonomy_enabled parse grammar unspecified; FP-direction ambiguity is a floor bypass and no fail-closed-to-review rule is stated
**Severity:** MAJOR · **Confidence:** MEDIUM
**Anchor:** `BC-3.03.001.md` §"Separate Human-Comment Marker Path": `parse_autonomy_enabled_from_markdown(content)` (line 688), `parse_disposition_from_markdown(content)` (line 702), route rule `IF parsed_disposition != "FP"` (line 723).

**Description.** Both parse helpers operate on free-text markdown but have no specified grammar. Two security-relevant consequences:

1. **Disposition parse, dangerous direction.** The route decision hinges on an exact `== "FP"` / `!= "FP"` test. There is no rule for how "FP" is recognized from prose (e.g., `Disposition: False Positive`, `FP`, `Disposition: Not a false positive — TP`). A disposition section such as "this is **not** a false positive" that a naive parser reduces to `FP` would route a TP finding into MARKDOWN_COMMENT_PATH (autonomous comment) — the exact floor-bypass of P13-001, reached by parse ambiguity rather than by an honest FP label. The safe direction (unparseable → non-FP → review) is not specified either; the contract does not state what the helper returns on ambiguous/missing input, so fail-closed behavior is not guaranteed.

2. **autonomy_enabled parse, accidental gate-open.** GATE 1 reads `autonomy_enabled` from arbitrary markdown text. If the literal token `autonomy_enabled: true` appears inside an evidence-artifact block, a quoted log line, or a code fence, a substring/naive parser could set the gate true and admit a marker the author never intended.

**Remediation.** Specify a strict grammar for both helpers: `parse_disposition_from_markdown` MUST read only the canonical `Disposition` heading's value and map to the enum via an exact allowlist (`TP|FP|BTP|Indeterminate` or their canonical long forms); any ambiguous, multi-valued, or unrecognized value MUST fail-closed to the review route (treat as non-FP), never to comment. `parse_autonomy_enabled_from_markdown` MUST read only a dedicated structured field (not free-text scan) and treat anything but a single explicit boolean-true as false. Add VPs with adversarial fixtures (negated-FP prose; `autonomy_enabled` embedded in an evidence block).

## Observations

- **[Partial-fix propagation — MINOR] P13-004:** BC-3.03.001 Postcondition #2 (line 84) still summarizes the markdown outcome as "If the separate path's markdown-evaluable floors pass, a comment-scoped marker is written and `permissionDecision: allow` is emitted." Post-P12-002 the authoritative pseudocode issues a **review** marker for non-FP and **no marker** (allow-without-marker) when `autonomy_enabled` is absent — a comment marker is written only for FP+autonomy_enabled=true. PC#2 defers to the pseudocode as authoritative, so this is non-blocking, but the prose describes pre-P12-002 behavior and should be updated (add GATE 1 and the non-FP→review route to the PC#2 summary; the cross-ref still reads "(P11-004)" not "(P11-004 / P12-002)"). This is the S-7.01(a) frontmatter/section-vs-body propagation class: the P12-002 fix updated Invariant #4 pseudocode but not PC#2's outcome sentence.

- **VP/SM namespace intact (spot-check).** verification-delta allocations are internally consistent through the burst-8 additions: SM-48/49 (charset removal mutants for ticket_id/jira_project_key), SM-50 (markdown kill-switch-gate removal), SM-51 (markdown route-to-review removal), and VP-HOOK-032 (O7 command_pattern interpolation-safety). VP-HOOK range is now 024–032 and SM max is 51, matching the confirmed-invariant list. Note for the orchestrator: verify any *current* "grand total" VP statement reflects VP-HOOK 024–032 (9 hooks) — the "6 VP-HOOK (024–029) … grand total 31" text at verification-delta line 244 is a historical blockquote from an earlier pass and must not be read as the current total.

- **SEVERITY_TO_SCORED_PRIORITY_MAP application (satisfied).** The map (CRITICAL→CRIT, MEDIUM→MED, HIGH→HIGH, LOW→LOW) is applied at the single place a severity-enum token is converted to a scored_priority token: the known-FP fast-path in BC-10.01.001 (lines 315–316, 557–558) and documented in validate_enums (BC-3.03.001 lines 166–172). The normal path produces scored_priority directly from assess-priority (BC-4.05.001 Invariant #5 / PC#6), so no other severity→scored_priority conversion site exists. The map is total over SEVERITY_ENUM and its range is exactly SCORED_PRIORITY_ENUM. No gap found.

- **BC-4.05.001 producer/consumer coherence (satisfied).** Invariant #5 (v1.4) correctly binds the `priority` output key to verdict field 18 `scored_priority` with no intermediate rename, and the fast-path note correctly defers to SEVERITY_TO_SCORED_PRIORITY_MAP. Coherent with BC-10.01.001 field 18 and the P12-003 exemption. No finding.

- **BC-6.01.004 / BC-9.01.001 (least-attacked skills — satisfied).** onboard-sensor and scan-threats are internally consistent: prism_describe-first ordering, org_slug scoping (D-DEC-005), fail-loud on SELECT 1 / prism error, supported-sensor enum, AD-017 piped-stdin. The AD-017 credential-set command template (BC-6.01.004 Invariant #1) is *displayed to the user for terminal execution*, not executed by the plugin, so command_pattern-style interpolation safety does not apply (org_slug/sensor_id land in the user's own shell); acceptable, but worth noting the plugin should still refuse to render the template if `sensor_id` is non-enum (already covered by Invariant #5) — no new finding.

## Novelty Assessment

**Novelty: HIGH.** Both CRITICALs are genuinely new and target the newest (burst-8) surface. P13-001 is the residual the P12-002 GATE-1 fix did not close: the mutant roster (SM-50/SM-51) tests kill-switch-gate removal and route-rule removal, but not the FP branch's inherent floor-unenforceability — so this hole survives the existing VP coverage. P13-002 is a direct hit on a requested probe (valid-key rejection → fail-closed) and a cross-document contradiction between the human-approved RC brief and the P12-001 charset that no prior invariant covers. P13-003 (parser grammar) and P13-004 (PC#2 prose staleness) are the natural adjacent gaps once the markdown path is attacked as data-driven rather than as pseudocode. These are gaps, not rewordings.

## Coverage / Partial-Output Note

Full reads: brief, prd-delta, dtu-assessment, asm-004-validation, BC-3.03.001 (through line 872 incl. all emitter STEPs, markdown path, test vectors), BC-4.05.001, BC-9.01.001, BC-6.01.004; targeted greps: BC-10.01.001 (field-18/known-FP/§3.9 floor), BC-4.02.001 (PC#4/EC-009), verification-delta (VP/SM allocations). **Not exhaustively read** (size/budget): architecture-delta.md (392 KB), the full bodies of BC-10.01.001, BC-3.01.001, and the full verification-delta prose. The two CRITICALs are grounded in fully-read artifacts; a subsequent pass should confirm architecture-delta §D-DEC-008/§8.26 does not already contain a reconciliation note for P13-002 that failed to propagate to the brief.

## Confirmed Invariants (carried forward, monotonic)

1. Marker schema v2.1 authoritative block in sync (BC-3.03.001 / emitter WRITE_MARKER / D-DEC-001).
2. JSON-first dispatch precedes investigation-*.md glob; `.json`/JSON-content → verdict-class 18-field path; `*investigation-*.md` → markdown 12-field path.
3. Two-field severity model intact: `verdict.severity`=detector-native (STEP-1a consistency-checked, not ground truth); `scored_priority` (field 18, enum CRIT|HIGH|MED|LOW)=Stage-5 output; §3.9 HIGH/CRIT floor keys on `scored_priority`; other floors asset_type critical/unknown, techniques {T1003,T1068,T1021,T1041}, degraded/silent sensor; fast-path uses SEVERITY_TO_SCORED_PRIORITY_MAP; known-FP exempt (JSON path, store-bounded).
4. Emitter order STEP 1 enum → 1a SEVERITY-MISMATCH → 2 extract → 3 review-surfacing (bindable; UNBINDABLE→HARD-FLOOR-UNBINDABLE deny) → 4 under-label DENY-THE-WRITE → 5 kill switch → 6 regular marker; STEPs 1a/3/4 fire regardless of autonomy_enabled.
5. 18-field verdict JSON schema; 12-field investigation markdown → separate human-comment path (NOTE: per P13-001/P13-004 the markdown comment branch is the defect surface, not the field split).
6. command_pattern interpolation safety (O7, VP-HOOK-032): ticket_id `^[A-Z][A-Z0-9]+-[0-9]+$` and jira_project_key `^[A-Z][A-Z0-9]+$` charset-validated + regex-escaped at all 5 sites (NOTE per P13-002: the regex is correct-for-Jira but the canonical demo key `PRISM-DEMO` is non-conformant and unreconciled).
7. Human-comment markdown path guarantees (VP-HOOK-031) — (a) autonomy_enabled≠true → allow-without-marker; (b) disposition≠FP → review; (c) FP+floors-pass → comment marker; (d) ticket_id charset-validated. (NOTE per P13-001: guarantee (c) is the CRITICAL hole — comment marker lacks scored_priority/asset_type/store enforcement.)
8. Consumer iterative-consume ordering, audit path, base64 + control-char stripping; create/create-review bidirectional anti-fungibility at step 6a; structural_label_check quote+backslash-aware.
9. STEP-3 HARD-FLOOR-UNBINDABLE deny + re-doc bounded; marker-write failure review-path fail-closed (P10-003); cron wrapper Gate 2 audit-log grep.
10. Sensor-silence direction (`last_seen_ts < now()-24h`); D-DEC-005 sensor-health carve-out; NVD/CVSS → scored_priority only.
11. VP/SM namespace collision-free (VP-SKILL 001–075, VP-HOOK 024–032, SM-9..SM-51).

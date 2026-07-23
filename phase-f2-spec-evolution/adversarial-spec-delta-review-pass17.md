---
document_type: adversarial-review
pass: 17
producer: adversary
date: 2026-07-23
feature: prism-integration
package: phase-f2-spec-evolution
verdict: NOT-CONVERGED (3 MAJOR)
---

# Adversarial Review — F2 Spec-Evolution Delta — Pass 17

## Summary Table

| ID | Title | Severity | Anchor |
|----|-------|----------|--------|
| P17-001 | Known-FP scored_priority floor exemption is unimplementable at the disposition-guard layer as specified — deterministic gate has no known-FP signal and will DENY the auto-close the loop promises | MAJOR (CRITICAL if resolved via LLM field) | BC-10.01.001 EC-009 / field-18 note ↔ BC-3.03.001 hard_floor_applies() + STEP 4 |
| P17-002 | Stale substring-dispatch residue in loop: Invariant #14 Stage-7 text + VP-HOOK-028 property (1) contradict the JSON-first PC#8 (CV-009); VP asserts a fail-closed property that no longer exists | MAJOR | BC-10.01.001 Inv#14 Stage-7, VP-HOOK-028, PC#8 |
| P17-003 | Stale MARKDOWN_COMMENT_PATH residue: EC-005 + happy-path test vector assert a comment-scoped marker for investigation-markdown, contradicting the P13-001 redesign and the newer vectors/VP-HOOK-031 | MAJOR | BC-3.03.001 EC-005 (L798), canonical test vector (L814) |
| P17-OBS-1 | comment/comment-review marker fungibility on the `jr issue comment` consumer path is bounded only by ASM-014 (tracked) | OBSERVATION | BC-3.01.001 step (6) |
| P17-OBS-2 | SLA per-tenant config fields (`sla_reopen_behavior`, `resolved_to_closed_window_hours`) from brief §3.5 are not reflected in any BC contract | OBSERVATION | brief §3.5 vs BC-4.02.001/BC-10.01.001 |

**This is NOT an earned clean pass.** Three MAJOR substantive defects remain — one functional contradiction with a security-escalation edge (P17-001), and two retired-mechanism residues in verification-bearing constructs (P17-002, P17-003). All three are of the LOGIC/verification-gap class that a coherence census does not catch.

---

## Critical Findings

None graded CRITICAL outright. P17-001 has a CRITICAL escalation condition (documented in-finding).

---

## Major Findings

### P17-001 — Known-FP high-severity floor exemption cannot be enforced by the deterministic gate that owns the floor; the documented auto-close is blocked (or requires an LLM-forgeable bypass)

**Severity:** MAJOR (CRITICAL if the natural resolution — an LLM-supplied "known_fp" verdict field — is adopted)
**Confidence:** HIGH
**Anchors:**
- BC-10.01.001 EC-009 (L623): *"the known-FP is EXEMPT from the scored_priority hard floor — `hard_floor_applies()` does NOT fire even if native severity maps to HIGH or CRITICAL … auto-close proceeds."*
- BC-10.01.001 field-18 note (L317-321): same exemption claim.
- architecture-delta.md §8.26.2 item 2 / P12-003b (L2814-2836): *"the known-FP fast-path is EXEMPT from the scored_priority floor"*; and L5853-5856: *"do NOT mint a scored_priority floor exemption VP for known-FP … The exemption is architectural policy; FV verifies the ENUM MAP only until PO confirms the floor-exempt annotation is in place."*
- BC-3.03.001 `hard_floor_applies()` (L658-666): floor fires unconditionally on `verdict.scored_priority ∈ {HIGH,CRIT}`; **no known-FP branch exists.**
- BC-3.03.001 STEP 4 DENY-THE-WRITE (L402-444).

**Description.** The known-FP fast-path floor exemption is documented as a behavior of `hard_floor_applies()` ("does NOT fire"). But `hard_floor_applies()` is a **disposition-guard** function (BC-3.03.001), and disposition-guard has **no way to learn that a verdict matched the human-curated known-FP store**: the 18-field verdict schema contains no `known_fp` signal, and disposition-guard does not read the store (only the loop does, at Stage 2). Per P12-003, a CRITICAL-native known-FP is assigned `scored_priority = CRIT` via `SEVERITY_TO_SCORED_PRIORITY_MAP`. Therefore disposition-guard's `hard_floor_applies()` sees `scored_priority=CRIT` → returns TRUE regardless of known-FP status.

The exemption is thus specified only in the **loop's** documentation while the **deterministic gate that actually enforces the floor** knows nothing about it. This is a hard contradiction, not a coherence label drift.

**Concrete failure scenario.**
1. CrowdStrike alert, `native_severity="95"`, `sensor_family="crowdstrike"` → `NORMALIZE_SEVERITY`=CRITICAL; `scored_priority`=CRIT (via map). Healthy sensor, no forbidden technique, matches known-FP store → `disposition=FP`.
2. Per EC-009, the loop auto-closes: sets `ticket_action_type=comment`, writes the verdict.
3. disposition-guard fires on the Stage-7 Write: `validate_enums` passes; STEP 1a passes (severity=CRITICAL consistent with native_severity=95); STEP 2 `action=comment`; STEP 3 skipped (comment ∉ review tokens); **STEP 4: `hard_floor_applies()` → TRUE (scored_priority=CRIT) → DENY-THE-WRITE (HARD-FLOOR-UNDER-LABEL, required_token=comment-review).**
4. The verdict Write is **denied**. Auto-close is impossible. Per the re-doc obligation (Inv#10), the loop re-issues as `comment-review` → routes to **human review**.

Result: every HIGH/CRIT-native known-FP is forced into the review queue — the exact opposite of EC-009's "auto-close proceeds", and it defeats the stated purpose of the exemption (suppressing "30–40% of known-FP volume", architecture-delta L2803). The behavior is fail-*safe*, but the two BCs are mutually contradictory about a load-bearing, high-volume path.

**CRITICAL escalation.** The only obvious way to make the exemption *work* (auto-close proceed) is to give disposition-guard an in-band signal — e.g., an LLM-written `known_fp: true` verdict field that skips the scored_priority floor. Because the verdict is LLM-authored, that field is forgeable: an adversarial/buggy LLM sets `known_fp: true` on any HIGH/CRIT verdict to bypass the highest-severity hard floor. That is precisely the "LLM value bypassing a deterministic control" CRITICAL class. **DI-015 does NOT cover this** — DI-015 bounds only the *store poisoning* residual (store-not-LLM-writable + audited + periodic-review); it says nothing about how disposition-guard learns known-FP status, and store-write-protection does not protect a verdict field. The mechanism/enforcement-surface gap is untracked.

**Suggested remediation.** Decide the enforcement surface explicitly:
- If auto-close of high-severity known-FPs is intended, disposition-guard must learn known-FP status from a source the LLM cannot forge (e.g., disposition-guard itself computing a hash of the alert against the write-protected store, or a prism-signed field). Specify it in BC-3.03.001 `hard_floor_applies()` and add a covering VP with a forgery mutant. Absent such a mechanism, the exemption is a CRITICAL bypass or dead.
- If not, correct BC-10.01.001 EC-009 / field-18 note to state that HIGH/CRIT-native known-FPs route to `comment-review` (human review), remove "auto-close proceeds", and reconcile architecture-delta §8.26.2/P12-003b. Either way the two BCs must agree, and the FV note at architecture-delta L5853-5856 (exemption "policy … until PO confirms") must be closed before Wave-3.

---

### P17-002 — Retired substring-dispatch residue in the monitoring-loop BC: Invariant #14 Stage-7 and VP-HOOK-028 property (1) contradict the JSON-first PC#8

**Severity:** MAJOR
**Confidence:** HIGH
**Anchors:**
- BC-10.01.001 Precondition #8 / PC#8 (L105-107): rewritten by CV-009 (v1.19) to **JSON-first** dispatch; explicit Previous block: *"Superseded by P4-001 JSON-first dispatch … the `verdict` substring is no longer the normative routing trigger."*
- BC-10.01.001 Invariant #14, Stage 7 (L564-566): still states *"verdict file path MUST contain the substring `verdict` … for disposition-guard to fire ICD-203 validation [PC#8, ADV-F2-P3-005]"* — cites PC#8 for a rule PC#8 explicitly retired.
- BC-10.01.001 VP-HOOK-028 (L597, L666), property (1): *"a Stage-7 Write to a path NOT containing the `verdict` substring causes disposition-guard to fast-path-allow WITHOUT ICD-203 validation … a mis-named verdict path is fail-closed."*

**Description.** Under JSON-first dispatch (BC-3.03.001 PC#1 Check 1: `.json` extension **OR** content parses as JSON → verdict-class, absolute precedence), a monitoring-loop verdict — which is always JSON content — routes to the verdict-class 18-field path **regardless of whether the path contains "verdict"**. Therefore:
- VP-HOOK-028 property (1)'s premise is false for any real verdict: a JSON verdict written to `artifacts/investigations/alert-001.json` (no "verdict" substring) routes to verdict-class and **emits a marker**, it does not fast-path-allow. The "mis-named verdict path is fail-closed" property that VP-HOOK-028(1) claims to prove **no longer exists** under JSON-first dispatch (VP-HOOK-028's own property (2) acknowledges JSON-first precedence, so the VP is internally self-contradictory).
- Invariant #14 Stage-7 still mandates the "verdict" substring and cites the retired PC#8 rule.

**Concrete failure scenario.** A formal-verifier implements the VP-HOOK-028 BATS test `@test "monitoring-loop Stage-7 non-verdict-path write: no marker emitted, Stage-8 jr denied"`. With a real (JSON) verdict at a non-"verdict" `.json` path, JSON-first Check 1 fires → 18-field validation → marker emitted → the test's "no marker emitted" assertion **FAILS**. To make the test pass the verifier must fabricate a non-JSON "verdict" that the loop never produces — a tautological/dead assertion that provides false coverage for a fail-closed property that is no longer real. This is retired-mechanism residue in a P0-anchored verification property.

**Suggested remediation.** Update BC-10.01.001 Invariant #14 Stage-7 to the JSON-first trigger (`.json` extension or JSON content), stop citing the retired PC#8 substring rule, and rewrite VP-HOOK-028 property (1)/its BATS vectors to assert the *actual* JSON-first fail-closed boundary (a Write with neither `.json` extension nor JSON-parseable content nor `*investigation-*.md` glob → fast-path-allow → Stage-8 denied). The CV-009 fix propagated to PC#8/Precondition #8 but not to Invariant #14 or VP-HOOK-028 — a partial-fix propagation gap (blast radius ≥ 2 constructs).

---

### P17-003 — Retired MARKDOWN_COMMENT_PATH residue in disposition-guard EC-005 and a canonical test vector contradict the P13-001 redesign and the newer vectors/VP-HOOK-031

**Severity:** MAJOR
**Confidence:** HIGH
**Anchors:**
- BC-3.03.001 EC-005 (L798): *"…non-hard-floor disposition | Allow; marker written to `${…}/markers/<uuid>.marker.json` (scope determined by ticket_action_type content if present; defaults to comment-scoped for investigation files)."*
- BC-3.03.001 canonical test vector (L814): *"`investigation-ALERT-001.md` → all 12 mandatory headings present (investigation-markdown path), disposition=TP … | permissionDecision: allow; marker file written … (comment-scoped, ticket-bound pattern) | happy-path (v1.10 EMITTER)."*
- Contradicted by: Separate Human-Comment Marker Path pseudocode (L727-779) and VP-HOOK-031 (L852) — investigation-markdown FP → allow-without-marker; TP/non-FP → **comment-review/create-review review marker**, never a plain comment marker; and newer vectors L834 (FP→allow-without-marker) and L835 (TP→MARKDOWN_REVIEW_PATH comment-review marker).

**Description.** P13-001 (v1.21) **eliminated** MARKDOWN_COMMENT_PATH: the investigation-markdown path never issues an autonomous `["comment"]` marker for any disposition. EC-005 and the L814 happy-path vector still assert the retired behavior — that a non-hard-floor / TP investigation markdown yields a comment-scoped marker. Two concrete contradictions:
1. **Direct contradiction with L835:** L814 says TP investigation markdown → comment-scoped marker; L835 says TP investigation markdown → MARKDOWN_REVIEW_PATH → comment-review marker. Both are canonical test vectors in the same BC.
2. **Field impossibility in EC-005:** "scope determined by `ticket_action_type` content if present" — investigation markdown is a 12-field artifact and has **no `ticket_action_type` field** (verdict-only field, PC#1 path). EC-005 describes a routing input that cannot exist on this path.

**Concrete failure scenario.** A formal-verifier building BATS from the L814 vector asserts "investigation markdown TP → comment-scoped marker written." Against a correct implementation (autonomy-absent human save → allow-without-marker; autonomy=true masquerade → comment-review review marker), the assertion fails — or, worse, an implementer "satisfies" L814 by restoring a comment marker on the markdown path, reintroducing exactly the autonomous-comment bypass that P13-001 was created to close (SM-52 kill target). Contradictory canonical vectors in the load-bearing emitter BC are a real defect that would either break the test suite or regress the fix.

**Suggested remediation.** Rewrite EC-005 and the L814 vector to the post-P13-001 behavior: 12-field investigation markdown, non-hard-floor — GATE 1 (autonomy_enabled absent/≠true) → allow-without-marker (the common human-save case); FP + autonomy=true → allow-without-marker; non-FP/PARSE_FAIL + autonomy=true → review marker (create-review/comment-review). Remove all "comment-scoped marker written for investigation files" language and the "ticket_action_type content" reference. Same partial-fix propagation class as P17-002 (P13-001 reached the pseudocode/VP-HOOK-031/L834-836 but not EC-005/L814).

---

## Observations

- **P17-OBS-1 [tracked]:** BC-3.01.001 consumer step (6) accepts `["comment"]` OR `["comment-review"]` for `jr issue comment`, with no structural distinction (comment-review has no `--label` binding). The two marker types are fungible on the comment verb. This is bounded by the tracked ASM-014 deferral (jr `issue comment --label` support). No new finding; noting for the wave/phase-5 record that when ASM-014 resolves, a comment-side anti-fungibility cross-check (analogous to create step 6a) will be needed, or a kill-switched regular comment marker could be consumed by a command intended for a hard-floor comment-review — currently harmless because both authorize the identical ticket-bound command.
- **P17-OBS-2:** brief §3.5 defines per-tenant SLA policy config fields (`sla_reopen_behavior: surface|reset|resume`, `resolved_to_closed_window_hours`). Neither BC-4.02.001 (Invariant #5) nor BC-10.01.001 (Invariant #16) encodes these fields as a contract — they specify only the "surface, never assume" behavior. If the fields are v1 scope, a BC should carry them; if deferred, that should be explicit. Low materiality.
- No mis-anchoring found in the sampled BCs (capability anchors, subsystem labels, VP references, architecture-module citations all resolve correctly for BC-4.02.001 / BC-6.01.004 / BC-8.02.001 / BC-9.01.001 / BC-3.01.001 / BC-3.03.001 / BC-10.01.001).

---

## Coverage Narrative (what I attacked end-to-end and why the three findings are real)

1. **Emitter → consumer → loop, end-to-end re-derivation.** I traced a verdict from Stage-1 INGEST (native_severity/sensor_family written) → Stage-5/6 (scored_priority, ticket_action_type) → Stage-7 DOCUMENT (disposition-guard PC#1 JSON-first dispatch → validate_enums → STEP 1a SEVERITY-MISMATCH → STEP 3 review path → STEP 4 DENY-THE-WRITE → STEP 5 kill switch → STEP 6 regular markers → WRITE_MARKER) → Stage-8 (require-review iterative-consume, anti-fungibility step 6a, audit sanitization). The marker schema v2.1, 120s TTL, JSON-first dispatch, quote-aware/backslash-escape tokenizer, create/create-review project+label binding, and the fail-loud unbindable/under-label deny paths are all internally consistent and well-hardened — I actively tried and failed to construct a marker-forgery, cross-org fungibility, prefix-match, audit-injection, or replay bypass against the consumer. The consumer (BC-3.01.001) is the strongest artifact in the package.

2. **Where the chain breaks (P17-001).** The single place the end-to-end chain is *internally contradictory* is the known-FP high-severity auto-close: the loop's EC-009 promises `hard_floor_applies()` won't fire, but that function lives in disposition-guard, which has no known-FP signal and will fire the scored_priority floor → DENY the auto-close. Cross-referencing architecture-delta §8.26.2/P12-003b and the FV note at L5853-5856 confirms the enforcement surface was never wired into disposition-guard and remains "policy pending PO confirmation." This is the substantive gap a coherence sweep cannot see because both BCs are individually self-consistent — only the *interaction* is broken.

3. **Verification-property integrity sweep.** I checked each P0/P1 VP against the current normative pseudocode. VP-HOOK-024/025/026/029/031 and VP-SKILL-050/060-065/068/072/075 are sound. Two VPs carry retired-mechanism residue: VP-HOOK-028 property (1) (P17-002, contradicts JSON-first) and the investigation-markdown happy-path vectors feeding VP-HOOK-025/031 (P17-003, contradicts MARKDOWN_COMMENT_PATH elimination). Both are the "retired-mechanism residue / tautological VP" class the mandate targets.

4. **Least-attacked BCs probed for own soundness.** BC-4.02.001 (Gate-1-first human path), BC-6.01.004 (AD-017 piped-stdin + SELECT 1 + --config-dir isolation), BC-8.02.001 (prism_sensor_health carve-out), BC-9.01.001 (prism_describe-first + org_slug scoping + predefined-queries-only injection guard) are each contract-sound; no within-BC logic defect found. The prism_sensor_health D-DEC-005 carve-out is correctly bounded to metadata only, with raw per-tenant tables still mandatory-scoped.

5. **Deferral-boundary stress.** ASM-008 (LLM-supplied native_severity/asset_type/scored_priority), ASM-015 (permission_denials population), ASM-014 (comment `--label`), and DI-015 (known-FP store integrity) are accurately scoped where cited. The one place a claimed-enforced behavior actually depends on an under-specified item is P17-001: EC-009's auto-close is claimed enforced but depends on an exemption mechanism that DI-015 does not cover.

6. **Light coherence confirmation (trusting the census for drift classes).** Spot-checked: marker schema v2.1 sync, 18-field verdict / 12-field markdown split, enum token sets, PRISMDEMO key, emitter STEP order 1→1a→2→3→4→5→6, two-field severity model, D-DEC-005 sensor-health carve-out — all consistent with the invariant list. No new coherence defect surfaced; I did not re-audit field counts/versions exhaustively per the mandate.

---

## Novelty Assessment

**Novelty: MODERATE-HIGH — findings are substantive logic/verification defects, NOT refinements.** The package is a strong convergence candidate on coherence (the census flush is real; I found no field-count/version/enum/anchor drift), but it is **not converged on substance**. All three MAJOR findings are of the class fresh context is designed to surface: cross-BC interaction contradiction (P17-001) and retired-mechanism residue in verification-bearing constructs (P17-002, P17-003) — none of which are re-treads of coherence drift, and all of which survive precisely because prior passes and the census concentrated on counts/versions/anchors rather than re-deriving the emitter/loop interaction and re-checking each VP against current pseudocode. P17-001 in particular is a genuine dead-behavior-or-CRITICAL-bypass that no prior pass in the visible changelog resolved (architecture-delta itself leaves it "pending PO confirmation"). **Recommend NOT declaring convergence; require remediation of P17-001/002/003 and one more clean pass.**

---

## Confirmed Invariants (carried forward + this pass)

Independently re-verified INTACT this pass (spot-check level): (1) Marker schema v2.1 sync. (2) JSON-first dispatch → 18-field verdict class; investigation-*.md → separate human-comment path; PC#8 now JSON-first (BUT see P17-002: Inv#14 Stage-7 + VP-HOOK-028(1) not propagated). (3) Two-field severity model (verdict.severity STEP-1a consistency-only; scored_priority field 18 {CRIT|HIGH|MED|LOW} Stage-5; §3.9 floor keys scored_priority; fast-path SEVERITY_TO_SCORED_PRIORITY_MAP; NVD→scored_priority only). (4) Emitter order STEP 1→1a→2→3→4→5→6; STEP 3/4 fire regardless of autonomy_enabled; STEP 4 DENY-THE-WRITE; STEP 3 HARD-FLOOR-UNBINDABLE deny. (5) 18-field verdict / 12-field markdown. (6) command_pattern interpolation safety (O7; charset-validate + regex_escape at 5 sites; PROJECT-KEY/TICKET-ID charset denies; hyphen-free keys; PRISMDEMO). (7) MARKDOWN human-comment path Gate-1-first (autonomy absent → allow-without-marker for ALL dispositions); MARKDOWN_COMMENT_PATH eliminated (BUT see P17-003: EC-005 + L814 vector stale). (8) Consumer iterative-consume (sort issued_at_utc ASC, rename-fail→CONTINUE), path-safety/TTL/future-date/anchored-pattern/authorized_operations checks, base64 command + control-char field sanitization, create/create-review bidirectional anti-fungibility at step 6a, quote-aware + backslash-escape v2 tokenizer, equals-form scoped out. (9) Marker-write failure review-path fail-closed (deny); cron Gate 2 audit.log grep (HARD-FLOOR-LIVELOCK-ABORT|HARD-FLOOR-UNBINDABLE|UNDER-LABEL-DENIED|SEVERITY-MISMATCH|MARKER-WRITE-FAILED); re-doc cap → HARD-FLOOR-LIVELOCK-ABORT after 3. (10) Sensor-silence corrected `<` direction; D-DEC-005 prism_sensor_health carve-out (metadata only; raw tables scoped). (11) VP/SM namespace: VP-HOOK 024-031 + VP-SKILL set; VP-SKILL-065 PROPOSED (kill-switch carve-out re-scope); VP-HOOK-029 FINALIZED P0.

New this pass:
- **INV-P17-A (BROKEN):** Known-FP scored_priority floor exemption has NO enforcement surface in disposition-guard's `hard_floor_applies()`; the loop's "auto-close proceeds" (EC-009) is contradicted by the deterministic gate. Untracked by DI-015 (which covers only store integrity). → P17-001.
- **INV-P17-B (RESIDUE):** JSON-first dispatch propagated to PC#8/Precondition #8 but NOT to Invariant #14 Stage-7 or VP-HOOK-028 property (1). → P17-002.
- **INV-P17-C (RESIDUE):** MARKDOWN_COMMENT_PATH elimination (P13-001) propagated to pseudocode/VP-HOOK-031/L834-836 but NOT to EC-005 or the L814 canonical test vector. → P17-003.
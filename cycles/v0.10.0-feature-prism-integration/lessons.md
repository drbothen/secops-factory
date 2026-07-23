---
document_type: lessons-learned
level: ops
version: "1.0"
status: in-progress
producer: state-manager
timestamp: 2026-07-21T18:00:00Z
cycle: "v0.10.0-feature-prism-integration"
inputs: [STATE.md]
input-hash: "[live-state]"
traces_to: STATE.md
---

# Lessons Learned — v0.10.0-feature-prism-integration

<!-- Durable lessons from this cycle for future VSDD factory runs.
     Organized by category: agent-level, process-level, infrastructure-level.
     Each lesson is numbered continuously and includes the pass/burst
     where it was discovered. -->

## Agent-Level

1. **Fail-loud at the deterministic layer, not the LLM layer (P5-001)** — The deterministic
   disposition-guard hook silently discarded tickets whose LLM-supplied `ticket_action_type`
   was non-review but whose `hard_floor_applies()` check was true, producing zero output
   (CRITICAL silent failure). Fail-loud guarantees must be enforced at the deterministic
   (hook) layer; relying on correct LLM behavior for the exact threat class the marker design
   defends against inverts the security model.
   _Discovered: F2 adversarial pass 5, 2026-07-21_

2. **Kill-switch exemptions require a hook-computed precondition gate (P5-002)** — The
   `create-review`/`comment-review` marker exemptions under `autonomy_enabled=false` were
   gated solely on the LLM-supplied token, with no deterministic cross-check. This created
   a bypass for the autonomy circuit-breaker: an LLM that supplies a `create-review` action
   on a non-hard-floor, non-Indeterminate ticket passes the kill-switch gate unchecked. Fix:
   always gate exemptions on `hard_floor_applies() OR disposition==Indeterminate` (hook-
   computed), not on the token alone.
   _Discovered: F2 adversarial pass 5 (P5-002), 2026-07-21_

3. **Stale "authoritative" schema blocks are actively dangerous (P5-003)** — A schema block
   marked "authoritative — fix the BC, not this document" was stale with respect to later
   sections of the same document after D-DEC-012 extensions. The mismatch created a spec
   inconsistency that would have caused test-writer and implementer agents to work from a
   subtly wrong schema. Authoring discipline: the authoritative block must be kept in sync at
   every schema extension; annotate it with the most-recent D-DEC that updated it.
   _Discovered: F2 adversarial pass 5 (P5-003), 2026-07-21_

## Process-Level

4. **O3 standing rule: every LLM-supplied routing field that grants or bypasses a security
   control must be cross-validated against a hook-computed invariant [codified]** — P5-001
   and P5-002 are the under-label and over-label duals of a single root cause: the
   disposition-guard trusted `ticket_action_type` (LLM-supplied) without a deterministic
   cross-check. The O3 rule codifies this pattern as a standing emitter-design constraint:
   no LLM-supplied field may unilaterally grant or skip a security gate without a hook-
   computed corroborating check. Codified in architecture-delta D-DEC-012 and adopted as
   a formal design invariant for all subsequent prism-integration work.
   _Discovered: F2 adversarial pass 5 root-cause analysis (root-cause one-liner), 2026-07-21_

5. **Consistency-audit pass should run before wrapping a session that concludes an
   adversarial pass** — The consistency audit for pass 5 was dispatched but not captured
   to disk at session wrap, requiring a re-run on resume. Cost: one additional agent
   invocation per missed capture. Mitigation: orchestrator should block session wrap if
   any dispatched agent result has not been written to disk.
   _Discovered: Burst 2 wrap gap (SESSION-HANDOFF.md §PENDING), 2026-07-21_

## Infrastructure-Level

6. **ICD-203 field split (12-field investigation markdown vs 15-field verdict JSON) must
   be kept consistent across all three delta documents simultaneously** — prd-delta §4/§6
   still cited "12-field" (stale) after the architecture-delta and verification-delta had
   been updated to the correct 12/15 split. Cross-document count propagation should be
   treated as an atomic update (all three deltas in the same burst).
   _Discovered: F2 adversarial pass 5 (P5-003 / prd-delta §4/§6 stale counts), 2026-07-21_

## Policy Candidates

| Lesson | Proposed Policy | Scope | Status |
|--------|----------------|-------|--------|
| 4 (O3 rule) | LLM-routing-field cross-validation invariant | All security-gate hooks; emitter design | adopted (codified in D-DEC-012) |
| 7 (O3 extended) | O3 rule audit must cover all trust-boundary surfaces — emit, store, consume, ordering | All security gate designs; each new adversarial pass re-derives the full trust boundary end-to-end | adopted (codified in D-DEC-012 audit checklist, addresses P6-009 [process-gap]) |
| 1 | Fail-loud gate placement | Deterministic hook design | proposed |
| 2 | Kill-switch exemption precondition | Autonomy circuit-breaker design | proposed |
| 6 | Cross-document count propagation atomicity | Count-changing bursts | proposed |

---

## Pass-6 Lessons (F2 adversarial pass 6, 2026-07-21)

### Agent-Level

7. **O3 standing rule must cover all trust-boundary surfaces, not just the emitter [codified]** —
   Pass 6 found P6-001 (consumer anti-fungibility) and P6-002 (STEP 4/5 ordering) by re-deriving
   the trust boundary end-to-end (emit → store → consume → ordering) rather than inheriting the
   emitter-centric conclusions of prior passes. The O3 rule (every LLM-supplied routing field that
   grants or bypasses a security control must be cross-validated against a hook-computed invariant)
   had only been audited on the emitter side (disposition-guard); P6-009 identified the consumer
   (require-review STEP 6a) and ordering (STEP 4 before STEP 5) surfaces as unaudited. Fix:
   D-DEC-012 audit checklist extended with consumer, ordering, and trust-boundary rows (codified in
   architecture-delta v1.9). Each new adversarial pass must re-derive the full trust boundary.
   _tag: [codified]_
   _Discovered: F2 adversarial pass 6 (P6-009 [process-gap]), 2026-07-21_

### Infrastructure-Level

8. **VP/SM namespace allocation must verify occupancy before minting new IDs** — The architect's
   §8.15 proposal used "VP-SKILL-072" for severity normalization and "SM-33/SM-34" for consumer
   anti-fungibility mutants, but all four IDs were already occupied by pass-4 allocations
   (VP-SKILL-072: first-run 24h lookback; SM-33: autonomy_enabled-clause-removed; SM-34:
   dispatch-order-inverted). The formal-verifier's independent occupancy re-verification caught
   both collisions before any BC was written. Propagation sections and architect-authored
   specification deltas must not mint VP or SM IDs without a repo-wide occupancy check
   (`grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` across all BCs). The FV owns the VP/SM namespace
   and is the sole authority for new ID allocation.
   _Discovered: F2 adversarial pass 6 remediation burst 2, formal-verifier occupancy re-verification, 2026-07-21_

### Process-Level

9. **Fresh-context passes must re-derive the full trust boundary — not inherit prior-pass
   conclusions** — Passes 1–5 progressively refined the emitter's behavior but each started
   from the architecture framing already established. Pass 6 broke this pattern: the adversary
   re-derived the trust boundary from scratch (brief → emit → store → consume → ordering →
   kill switch → fail-loud), finding two CRITICAL defects (P6-001, P6-002) that five prior
   passes had missed because none had audited the consumer surface end-to-end. Standing rule:
   fresh-context adversarial passes must be explicitly scoped to trace every security invariant
   from its source through all enforcement surfaces, not just the surfaces touched in prior
   remediation bursts.
   _Discovered: F2 adversarial pass 6 trust-boundary re-derivation, 2026-07-21_

---

## Pass-7 Lessons (F2 adversarial pass 7, 2026-07-21)

### Agent-Level

10. **O4 standing rule: fail-loud guarantees must be verified at the consumer/Bash boundary,
    never by emitter-local artifacts [codified]** — P7-009 identified that VP-HOOK-029 was
    asserting "marker exists OR error artifact written" (emitter-local) rather than "the
    downstream jr authorization/execution outcome at the consumer/Bash boundary." A marker
    file on disk and an audit line in audit.log ARE emitter-local artifacts; they CANNOT
    detect the case where the marker is structurally unconsumable by the loop's own future
    command (the P7-001 seam gap: upgrade wrote a create-review marker, loop issued a
    non-review jr command, require-review denied — hard-floor finding silently dropped).
    Every "never silently discarded" claim MUST have a VP asserting the consumer-boundary
    (require-review allow/deny) outcome, not just marker presence. Codified as O4 standing
    rule in verification-delta §0.
    _tag: [codified]_
    _Discovered: F2 adversarial pass 7 (P7-009 [process-gap]), root-cause analysis, 2026-07-21_

### Infrastructure-Level

11. **A deterministic hook's only lever over FUTURE commands is denying the current Write —
    corrective-deny beats artifact-rewrite** — P7-001 proved that when a stateful artifact
    (the marker) is the enforcement mechanism, rewriting that artifact at denial-time (the
    pass-5/pass-6 marker-upgrade approach) does not fix the loop: the hook can rewrite the
    marker but cannot rewrite the loop LLM's NEXT Bash command. For 3 of 4 under-label
    action types (create/assign/none), the upgraded create-review marker was structurally
    unconsumable by the loop's own non-review jr command — hard-floor finding silently
    dropped. The correct design is DENY-THE-WRITE with a machine-actionable corrective
    reason: the loop cannot proceed until it re-documents with the correct review token,
    at which point the standard marker path runs normally. Lesson: when a deterministic
    gate must force a behavior change in a FUTURE command, deny the current Write (with a
    structured corrective reason the actor can mechanically follow); do not try to
    pre-position an artifact the actor may not be able to use.
    _Discovered: F2 adversarial pass 7 (P7-001 CRITICAL), human decision D-008, 2026-07-21_

### Process-Level

12. **Partial-fix blast radius includes sibling edge cases and test vectors in the SAME file** —
    P7-002 found 6 stale locations in BC-10.01.001 (EC-015/EC-016/EC-017/EC-021 + 2 canonical
    test vectors) still encoding pre-D-DEC-012 "no marker for hard-floor" semantics after
    the Inv#10 text had been updated in an earlier burst. The same D-DEC-012 semantic change
    that updated Inv#10 should have been propagated to all edge-case rows and test vectors in
    the same file. Fix: when remediating a finding that changes a behavioral invariant, grep
    ALL occurrences of the old semantics in the same file (EC rows, test vectors, postcondition
    tables, comments) — not just the primary invariant paragraph — and update them atomically.
    _Discovered: F2 adversarial pass 7 (P7-002 CRITICAL — 6 stale locations), 2026-07-21_

---

## Pass-8 Lessons (F2 adversarial pass 8, 2026-07-21)

### Agent-Level

13. **The happy path is not exempt from the hard-floor axiom — null binding fields are a
    silent-discard axis on correctly-labeled verdicts [P8-001]** — Passes 1–7 focused on
    under-label and over-label failure modes; pass 8 found a third orthogonal axis: a
    verdict that is correctly labeled (hard_floor_applies() true, --label OK) but whose
    binding field (jira_project_key for create-review, ticket_id for comment-review) is null
    produces a silent allow-without-marker — the "happy path" through STEP 3. D-DEC-012
    clause 2 ("NEVER emit allow without marker for a hard-floor verdict") applies regardless
    of label correctness. Lesson: when specifying a "happy path" through a security gate,
    explicitly enumerate every required field and assert that any null or absent field triggers
    the deny-with-error path, not a silent allow.
    _Discovered: F2 adversarial pass 8 (P8-001 CRITICAL), 2026-07-21_

### Infrastructure-Level

14. **Tokenizers used in hook logic must be modeled with the same quoting semantics as the
    shell they execute in — split_on_whitespace is not sufficient [P8-002]** — The
    structural_label_check introduced in burst 3 (P7-005 fix) used split_on_whitespace
    tokenization to locate the --label token. The adversary demonstrated that a command
    containing `--summary "some text --label REVIEW-REQUIRED"` would cause split_on_whitespace
    to present --label as a standalone token inside the quoted string, producing a false deny
    on an entirely valid command (EC-024 example). This was verified against the live hook
    source. Fix: the tokenizer must track quote state (UNQUOTED / IN_SINGLE / IN_DOUBLE) to
    skip tokens inside quoted spans. Lesson: any tokenizer in a security-gate hook should
    be specified with explicit quote-handling semantics; the spec example (EC-024) must be
    parsed through the tokenizer mechanically to verify it does not false-positive.
    _Discovered: F2 adversarial pass 8 (P8-002 MAJOR), verified against live hook source, 2026-07-21_

### Process-Level

15. **Bash `[[ =~ ]]` is NOT tail-anchored — defense-in-depth claims about step ordering
    must be verified against actual regex semantics [P8-003]** — EC-023 claimed that the
    regular create pattern at step 5 of require-review "rejects commands with a
    create-review token because the `( |$)` boundary anchors the match." In reality, Bash
    `[[ string =~ pattern ]]` does NOT require the pattern to match the full string or be
    tail-anchored — it matches a substring anywhere in the string. A command with a
    `create-review` token appended after a regular `create` pattern match would pass step 5
    unblocked. Step 6a's exact-type anti-fungibility cross-check is the SOLE enforcement
    point for anti-fungibility direction A. Lesson: any "defense-in-depth" claim that relies
    on a specific regex behavior (anchoring, boundary semantics, full-string match) must be
    validated against the actual behavior of the regex engine in use (Bash ERE vs PCRE vs
    POSIX) before it can be cited as a spec invariant.
    _Discovered: F2 adversarial pass 8 (P8-003 MINOR), 2026-07-21_

## Pass-9 Lessons (F2 adversarial pass 9, 2026-07-21 — first zero-CRITICAL pass)

### Infrastructure-Level

16. **Any hook that re-implements shell tokenization MUST carry a differential-vs-bash vector
    partition in its specification [P9-001 / O5 rule]** — The quote-aware tokenizer added in
    burst 4 (P8-002 fix) handles IN_SINGLE and IN_DOUBLE quoting states correctly, but the
    adversary identified that the IN_DOUBLE state reverted to UNQUOTED on backslash (\\")
    rather than staying in IN_DOUBLE, causing backslash-escaped quotes inside double-quoted
    arguments to split the token. Additionally, the --label=VALUE form (equals sign, no space)
    was not covered. Both are valid Bash token boundaries. Fixing individual missed cases
    each pass is not a durable approach: Bash's shell quoting rules include further edge cases
    (e.g., $'...', ANSI-C quoting, heredoc-derived arguments) that a naive state machine will
    diverge from. The O5 standing rule codified here: any hook specification describing a
    tokenizer that re-implements shell quoting must include a documented differential-vs-bash
    vector partition — an explicit enumeration of known divergences from the shell's actual
    tokenization — so that the FV can verify coverage rather than discovering edge cases one
    pass at a time.
    _Discovered: F2 adversarial pass 9 (P9-001 MAJOR), O5 codified burst 5, 2026-07-22_

### Process-Level

17. **Stale validation documentation recommending forbidden invocations is a live regression
    vector — superseded analysis must carry correction banners immediately [P9-002]** — The
    asm-004-validation.md document, produced during Phase 0 security analysis, contained
    paragraphs recommending --dangerously-skip-permissions (violates D-DEC-003: hooks must
    remain active) and --bare (hook-disabling; violates D-DEC-010) as setup patterns. These
    decisions were superseded by D-DEC-003 and D-DEC-010 adopted later, but the document was
    never updated with forward-links or correction banners. Any practitioner reading the
    document in isolation would follow the forbidden invocations. Lesson: when a design
    decision supersedes a prior analysis document's recommendations, a SUPERSEDED or
    CORRECTION banner must be applied to the affected sections immediately — not deferred to
    a "cleanup pass." Stale prescriptive text in an analysis doc is functionally equivalent
    to a live specification that contradicts the current design.
    _Discovered: F2 adversarial pass 9 (P9-002 MAJOR), 2026-07-22_

18. **Absolute invariants expressed without carve-outs will be silently violated by legitimate
    cross-cutting surfaces — the carve-out must be explicit in the spec [P9-005]** — D-DEC-005
    stated that every query must include an org_slug predicate for tenant isolation, expressed
    as an absolute invariant. However, the prism_sensor_health endpoint performs cross-org
    health-check reads (monitoring that spans all tenants) by design — a surface that
    legitimately cannot include a tenant-scoping predicate without breaking its purpose.
    Because the invariant had no carve-outs, D-DEC-005 was technically violated by an
    intended workflow. The fix was to add an explicit carve-out in the spec naming the
    prism_sensor_health surface and the rationale. Lesson: when writing an absolute security
    or isolation invariant, actively enumerate any surfaces that are designed to cross that
    boundary; document each as a named carve-out with a rationale. An invariant without
    carve-outs is either incomplete or will be violated by legitimate design.
    _Discovered: F2 adversarial pass 9 (P9-005 MINOR), 2026-07-22_

19. **[O6 codified] An invariant computed from LLM-supplied inputs is NOT an enforcement surface — inputs must be hook-recomputable or hook-cross-validated against deterministic ground truth [P10-001]** — hard_floor_applies() checked verdict.severity and verdict.asset_type to decide whether to enforce the hard floor. Both of these fields are written by the LLM-operated monitoring loop (SKILL.md Stage 1 INGEST). An adversary who controls the LLM can under-report the severity (e.g., write severity=LOW for an alert that actually normalizes to CRITICAL) to bypass the hard floor entirely. The hook never cross-checked the LLM-supplied severity against the raw sensor value. The O6 fix: disposition-guard STEP 1a re-runs NORMALIZE_SEVERITY(verdict.native_severity, verdict.sensor_family) using the deterministic D-DEC-013 table; if the recomputed severity differs from verdict.severity, the hook emits SEVERITY-MISMATCH deny. The ICD-203 schema was extended from 15 to 17 mandatory fields to carry the hook-recomputable inputs (native_severity, sensor_family). O6 standing rule: every input to a hook-computed invariant must either be hook-recomputable from a deterministic source, or hook-cross-validated against deterministic ground truth. "The LLM cannot bypass this check" is only true if the check does not depend on a field the LLM writes. This was the deepest finding of the entire F2 convergence cycle — it invalidated the trust basis of the hook's primary enforcement surface.
    _Discovered: F2 adversarial pass 10 (P10-001 CRITICAL), 2026-07-22_

20. **Fail-loud guarantees must be observable at the OPERATOR boundary (cron exit), not just written to an audit file the operator never reads [P10-002]** — the monitoring-loop spec required that certain failures be "fail-loud": hard-floor enforcement failures write audit entries to markers/audit.log. But the cron wrapper only inspected the JSON envelope (is_error, permission_denials) to decide its exit code. An audit entry written to a file the cron never reads provides no signal at the operator boundary — a livelock-abort run could log HARD-FLOOR-LIVELOCK-ABORT to audit.log and still have the cron report success. The fix adds Gate 2 to the cron wrapper: after checking the JSON envelope, the wrapper independently greps markers/audit.log for fail-loud codes and exits 1 if any are found. The lesson generalizes: a fail-loud guarantee is only as good as the consumer at the operator boundary. When specifying that a failure "emits an audit entry," always simultaneously specify which cron/scheduler reads that entry and how it surfaces to the operator. If the answer is "the cron doesn't check that file," the guarantee is incomplete.
    _Discovered: F2 adversarial pass 10 (P10-002 MAJOR), 2026-07-22_

21. **Infra-failure fallbacks that allow-without-marker can silently undo the fail-closed guarantee on the critical path — fallbacks must preserve the security posture of the path they're on [P10-003]** — when disposition-guard's WRITE_MARKER syscall failed, the regular (non-review) path emitted allow-without-marker (require-review would then deny the downstream jr call — a human gate is preserved). This was appropriate for the regular path. But the same allow-without-marker fallback was also applied on the create-review/comment-review review path, where the downstream SKILL.md expects a marker to exist. A WRITE_MARKER failure on the review path silently dropped the hard-floor marker without audit, leaving the review untracked. The fix branches WRITE_MARKER on is_review_path: review-path write failures emit MARKER-WRITE-FAILED audit + deny (mirrors HARD-FLOOR-UNBINDABLE). The lesson: when a code path has a fail-closed security requirement (a hard-floor finding MUST produce a traceable review ticket), the infra-failure fallback on that path must also satisfy the security requirement — not just the availability requirement. Borrowing the fallback from a sibling path with a weaker security requirement reintroduces the guarantee violation on the critical path.
    _Discovered: F2 adversarial pass 10 (P10-003 MAJOR), 2026-07-22_

22. **[Process gap] Steering the adversary with a verified-invariants carry list surfaced the trust-basis CRITICAL that mechanics-focused passes missed — accumulate-and-redirect works [P10-001 process lesson]** — passes 1-9 focused on the mechanical correctness of individual enforcement steps: marker issuance, label content checks, consumer-boundary verification, unbindable-deny paths, quote-aware tokenizers. The trust basis of those enforcement steps (are the inputs to the hard-floor gate hook-recomputable?) was never examined. In pass 10, the adversary was primed with a carry list of 12 confirmed-intact invariants and directed to look for weaknesses not in the mechanics but in the assumptions behind the invariants. This surfaced P10-001 — a CRITICAL that invalidated the trust basis of the primary enforcement surface. The accumulate-and-redirect approach worked: maintaining a running list of confirmed-safe invariants creates a "known safe" perimeter, which makes the adversary more effective at finding what's outside it. The lesson: after several passes that improve mechanical correctness, redirect the adversary's focus to the trust basis of the invariants, not just their mechanical implementation. "Is this check correctly implemented?" and "Is this check checking the right thing?" are orthogonal questions.
    _Discovered: F2 adversarial pass 10 (P10-001 process observation), 2026-07-22_

23. **[O6 extension] A consistency check between two LLM-supplied fields is NOT ground-truth enforcement — distinguish verification of LLM self-consistency from verification against an external source [P11-001]** — the P10-001 fix (STEP 1a SEVERITY-MISMATCH) was framed as making the floor "un-bypassable": the hook re-runs NORMALIZE_SEVERITY on the LLM-supplied native_severity+sensor_family pair and compares the result to the LLM-supplied verdict.severity. This was described as "independently deriving severity from raw sensor values." But the hook makes no prism call; native_severity and sensor_family are both written by the same monitoring-loop LLM. An adversary can supply a coherent but false (native_severity, sensor_family) pair that passes the consistency check. The "independently derived" claim requires an independent source — without one, the check only verifies internal LLM consistency, not correctness against the sensor. The fix was to reframe STEP 1a as a CONSISTENCY CHECK (not ground-truth enforcement) and classify native_severity trust as an ASM-008-DEFERRED residual identical to asset_type. O6 rule refinement: the rule already stated inputs must be hook-recomputable; P11-001 adds the corollary that "hook re-applies a deterministic function to LLM-supplied inputs" ≠ "hook-recomputable from an independent source." The distinction between self-consistency and external ground-truth must be explicit in every invariant's trust-basis annotation.
    _Discovered: F2 adversarial pass 11 (P11-001 CRITICAL), 2026-07-22_

24. **A remediation can overstate its own guarantees — the fix narrative must be held to the same adversarial standard as the original spec [P11-001 process gap]** — the pass-10 remediation burst documented STEP 1a as closing the LLM-bypass attack surface, using language like "un-bypassable" and "independently derives from raw sensor values." These claims were written by the same session that designed the fix, without applying the adversary's perspective to the fix itself. When pass 11 reviewed those claims adversarially, the false guarantee was discovered immediately. The lesson: after every remediation burst, the rationale language for each fix should be stress-tested against a simple adversary question: "what would an adversary who controls the LLM do to defeat this check?" If the answer reveals that the check's guarantee is conditional or weaker than claimed, the language must be corrected before the next adversarial pass. A fix that states a stronger guarantee than it actually provides is a form of specification debt — it creates false confidence in future reviewers and may be cited to justify skipping additional review.
    _Discovered: F2 adversarial pass 11 (P11-001 process gap), 2026-07-22_

25. **Raw sensor readings and scored risk decisions are orthogonal and must be carried as separate fields — a single "severity" field cannot serve both consumers [P11-002]** — the original design used a single verdict.severity field as both the raw sensor reading (what the sensor detected, validated by STEP 1a) and the input to the hard-floor gate (what determines whether human review is required). These are orthogonal: a LOW-severity alert can legitimately escalate to CRIT after Stage-5 assess-priority enrichment (KEV database hits, exposure data, asset criticality). Using a single field for both purposes caused STEP 1a's exact-equality check to deny these valid escalations. The two-field fix (verdict.severity = raw normalized reading; verdict.scored_priority = Stage-5 scored decision) cleanly separates the roles: STEP 1a verifies consistency of the raw reading; the hard floor keys on the scored decision. The general principle: when a single data element is consumed by two downstream processes with different semantics (raw vs. enriched; observed vs. assessed), carry them as separate named fields with explicit provenance. Aliasing enriched and raw values through one field creates invariant collisions wherever the two uses make contradictory demands.
    _Discovered: F2 adversarial pass 11 (P11-002 MAJOR), 2026-07-22_

26. **[Process gap] False-closure language in a remediation summary copy-propagates to all docs that quote or paraphrase it — audit propagation as a commit discipline [P11-007]** — the pass-10 remediation burst used strong closure language ("un-bypassable / hook independently derives from raw sensor values") in arch-delta §8.22, the primary description of STEP 1a. Three downstream documents that cross-referenced §8.22 — BC-3.03.001 §3.2 trust-basis paragraph, BC-10.01.001 Inv#10 rationale, and verification-delta VP-HOOK-030 assertion text — imported the same language, either by direct quotation or paraphrase. When pass 11 found the language was overstated, four documents needed correction simultaneously. The root cause was that the original remediation burst only checked whether the spec language was technically sound for the finding being fixed; it did not audit downstream documents that would inherit the claim. Lesson: whenever a remediation burst establishes a new normative claim (especially a security guarantee), immediately grep all spec files for documents that reference the fixed component and apply the claim-text to see which ones would inherit the overstatement. A conservative workflow: before closing a burst, run a targeted grep for the claim's key phrase across the spec corpus and note which documents carry a version of it.
    _Discovered: F2 adversarial pass 11 (P11-007 process gap), 2026-07-22_

---

## Pass-12 Lessons (F2 adversarial pass 12, 2026-07-22)

### Agent-Level

27. **[O7 codified] Any value interpolated into an authorization regex must be charset-validated
    to a fixed grammar (fail-closed DENY on mismatch) AND regex-escaped as defense-in-depth —
    this is a LATENT class of bug, not a new design decision [P12-001]** — ticket_id and
    jira_project_key were concatenated directly into command_pattern (the anchored regex that
    require-review evaluates with `[[ =~ ]]`) without charset validation or escaping. The only
    prior sanitization was a control-character strip for audit purposes (P4-010). An adversary
    who controls the LLM can supply ticket_id='.*' or ticket_id='SEC-1 |.*#' to broaden the
    pattern to authorize an entirely unrelated `jr issue comment` call — defeating the anchored
    match property that was the primary security guarantee. This class of bug is latent since
    the original marker design: it exists wherever a user-supplied value is used inside a regex
    rather than compared against a regex. The O7 standing rule codifies the fix: before any
    interpolation into a command_pattern or authorization regex, the value MUST be (1) validated
    against a fixed charset grammar (fail-closed DENY on mismatch, with a machine-actionable
    audit entry), AND (2) regex-escaped for defense-in-depth. Every interpolation site needs a
    covering VP with a metacharacter-injection mutant. VP-HOOK-032 is the O7 compliance
    artifact (mirrors VP-HOOK-024=O4, VP-HOOK-029=O4-review-path, VP-SKILL-050=O5).
    _tag: [codified]_
    _Discovered: F2 adversarial pass 12 (P12-001 CRITICAL), 2026-07-22_

28. **A new surface added to fix a finding immediately becomes the next pass's attack surface —
    the fix must include a discriminator that closes the selection vector [P12-002]** — pass 11
    (P11-004) introduced a separate human-comment marker path for 12-field investigation
    markdowns to avoid the validate_enums() false-denial. The fix correctly separated the paths.
    But pass 12 found that the autonomous loop could SELECT the new weaker path by writing a
    TP verdict as an investigation-*.md file: the 12-field markdown path skipped kill-switch
    enforcement and scored_priority/asset_type floor checks that would have caught it on the
    standard path. The lesson is that any new path introduced to fix a false-positive must
    simultaneously include a discriminator that prevents an adversary from choosing the path
    to avoid controls on the standard path. Here, the discriminator is twofold: (a) the
    kill switch applies identically on the markdown path (autonomy_enabled absent/≠true →
    allow-without-marker), and (b) the disposition provides a hard gate — only disposition=FP
    reaches the comment marker; disposition≠FP routes to human review. Without these two
    discriminators, the new path's existence becomes an unintended bypass route.
    _Discovered: F2 adversarial pass 12 (P12-002 CRITICAL), 2026-07-22_

### Process-Level

29. **Producer/consumer contract coherence: when a consumer BC gains a new output field, the
    PRODUCER BC must be updated in the SAME burst [P12-004]** — burst 7 (P11-002) added
    scored_priority as field 18 of the verdict schema and updated BC-3.03.001 (the consumer:
    disposition-guard reads scored_priority for the hard floor) and BC-10.01.001 (another
    consumer: monitoring-loop stores the full 18-field verdict). BC-4.05.001 (assess-priority:
    the PRODUCER that computes scored_priority at Stage 5) was not updated. BC-4.05.001 still
    described outputting a `priority` field in the non-SCORED_PRIORITY_ENUM vocabulary, with
    no mention of scored_priority or the SEVERITY_TO_SCORED_PRIORITY_MAP. The producer/consumer
    contract was internally inconsistent from burst 7 onwards. The lesson: whenever a burst
    adds or renames a field in a verdict schema, the burst checklist must include a grep for
    every BC that either produces (writes) or consumes (reads) that field, and ALL of them
    must be updated atomically. Writing the consumer side without the producer side is a
    half-fix that leaves the spec inconsistent.
    _Discovered: F2 adversarial pass 12 (P12-004 MAJOR), 2026-07-22_

30. **A mis-anchor FIX can introduce a new mis-anchor — always verify the TARGET reference
    exists before committing [P12-005]** — burst 6 (P11-005 fix) corrected a stale BC-9.01.001
    reference in BC-6.01.003 by changing `Invariant#12` to a reference in BC-6.01.003 itself.
    The selected target was `Invariant#12` of BC-6.01.003, but that invariant does not exist
    in BC-6.01.003 (the contract has Postcondition#12, not Invariant#12). The fix introduced
    a new mis-anchor in a different document. The root cause: the repair was made without
    verifying that the target section (Invariant#12) actually exists in the destination
    document. Lesson: when correcting a cross-document reference, the commit checklist must
    include (1) confirming the destination document exists, AND (2) confirming the specific
    section/anchor (Invariant#N, Postcondition#N, EC-NNN) exists within that document. A
    reference to a nonexistent anchor is functionally equivalent to the original stale
    reference — it just points nowhere within a different file.
    _Discovered: F2 adversarial pass 12 (P12-005 MINOR), 2026-07-22_

31. **A fix that ADDS a capability to a security-gated surface may be UNFIXABLE by
    point-patching if the gate cannot see the data it needs [P13-001 recurring CRITICAL]** —
    Pass 12 remediation (P12-002) redesigned the human-comment markdown path to gate
    non-FP dispositions toward review. This correctly closed the TP/BTP masquerade
    but left a residual FP branch that granted an autonomous comment marker with no
    scored_priority/asset_type floor and no known-FP store cross-check. The gate cannot
    evaluate those fields because they are not present in a 12-field ICD-203 investigation
    markdown. The recurring CRITICAL was caused by attempting to add capability (conditional
    comment-marker issuance) to a path where the prerequisite data is structurally absent.
    The correct fix was to eliminate the capability from that path entirely
    (MARKDOWN_COMMENT_PATH ELIMINATED, P13-001), not to add another conditional branch.
    Rule: before adding a capability to a security gate that depends on data X, verify
    that data X is structurally present in every input that can reach the gate. If it is
    not, eliminate the capability from that code path — it is safer to fail-toward-review
    than to permit a partial guard.
    _Discovered: F2 adversarial pass 13 (P13-001 CRITICAL — 2nd consecutive pass), 2026-07-22_

32. **Spec EXAMPLES must be validated against the real target's grammar — an invalid
    example corrupts end-to-end testing [P13-002]** — the canonical RC demo Jira project
    key `PRISM-DEMO` was used throughout specs, test vectors, and BATS fixtures from the
    original brief. The P12-001 charset regex `^[A-Z][A-Z0-9]+$` is correct-for-Jira:
    Jira project keys are hyphen-free by spec. `PRISM-DEMO` would fail this regex on every
    marker issuance — the live RC demo could never issue any Jira write, and the failure
    would be silent (the fail-closed CHARSET-DENY would quietly discard every marker).
    The regex was right; only the example was wrong. Rule: when writing spec examples
    for external system identifiers (Jira keys, project keys, UUIDs, etc.), validate each
    example against the target system's documented grammar before committing. A bad example
    in a spec propagates into all test vectors, fixtures, and downstream BCs that inherit
    from the spec — catching it requires a full sweep of all dependent documents.
    _Discovered: F2 adversarial pass 13 (P13-002 CRITICAL/RC-gate), 2026-07-22_

33. **Free-text parse helpers feeding a security decision need an explicit grammar and a
    fail-closed direction [P13-003]** — the markdown path relied on `parse_disposition_from_markdown`
    and `parse_autonomy_enabled_from_markdown` as opaque helpers with no published grammar.
    An adversarial probe can craft inputs like `Disposition: not a false positive` or
    embed `autonomy_enabled: true` inside a code fence. Without an explicit grammar specifying
    (a) which document section is canonical, (b) the exact value allowlist, and (c) the
    safe direction for PARSE_FAIL (fail toward review, not toward allow-without-marker),
    the implementation is free to interpret ambiguous inputs in an unsafe direction.
    Requiring the grammar in the spec ensures testability: each adversarial parse vector
    can be added as a BATS test case, and the correct behavior is unambiguous. Rule: any
    parse function whose output is used in a security-relevant routing decision (allow vs.
    deny, autonomous vs. review) must have a fully specified grammar in the spec, with
    an explicit fail-closed direction — PARSE_FAIL must map to the more restrictive
    outcome (review, deny), not the permissive one (allow-without-marker, autonomous).
    _Discovered: F2 adversarial pass 13 (P13-003 MAJOR), 2026-07-22_

---

## Pass-14 Lessons (F2 adversarial pass 14, 2026-07-22 — first zero-CRITICAL since pass 9)

### Process-Level

34. **[Process gap] A fix declared "closed" must be audited for propagation into EVERY
    sibling artifact before the burst is committed [P14-001 / P14-003 / P14-004]** — P11-003
    (NVD/CVSS clean-separation) was recorded as closed and reflected in verification-delta
    (VP-HOOK-030's CVSS-float vector removed). But the loop contract (BC-10.01.001 Inv#9)
    still carried a "NVD: CVSS float 0.0–10.0" row in the NORMALIZE_SEVERITY table, the
    "8.5 for NVD CVSS" example in field-16, and "NVD CVSS float" text in Inv#14 Stage-1. The
    same pattern recurred with P13-002 (PRISMDEMO rename declared "throughout" but BC-3.01.001
    test vectors were skipped) and P14-004 (17-field parenthetical lingered in BC-10.01.001
    after the field-count was corrected elsewhere). Rule: when declaring a fix "closed," grep
    the FULL in-scope artifact set for every key phrase the fix changes. "Done in the primary
    artifact" is not done; "done throughout" must be proven by an explicit grep sweep.
    _Discovered: F2 adversarial pass 14 (P14-001/P14-003/P14-004 MAJOR/MINOR), 2026-07-22_

35. **A CRITICAL security control needs a PREVENTIVE VP for its setup-time gate, not only
    a runtime deny VP [P14-002]** — P13-002 added setup-time jira_project_key charset
    validation to activate (BC-6.01.001 PC#12/EC-014) and onboard-customer
    (BC-6.01.003 Inv#6/EC-010). The RUNTIME deny on a bad key was covered by VP-HOOK-032
    (PROJECT-KEY-CHARSET-DENY). But no VP covered the PREVENTIVE setup-time gate that
    stops a bad key from being stored in the first place. A stored bad key causes
    HARD-FLOOR-UNBINDABLE fail-closed livelock on every subsequent marker issuance — the
    setup-time gate is not redundant with the runtime deny; it prevents a permanent
    degraded state that the runtime deny can only report, not recover from. VP-SKILL-076
    + SM-54 close this gap. Rule: whenever a fix adds a preventive setup-time gate for a
    CRITICAL runtime failure path, allocate a VP that explicitly verifies the setup-time
    gate — do not rely solely on the runtime deny VP as coverage.
    _Discovered: F2 adversarial pass 14 (P14-002 MAJOR), 2026-07-22_

36. **[Process gap] A completion claim of "throughout" / "all references" must be
    grep-verified across the full in-scope artifact set before the burst closes [P14-003]**
    — P13-002's burst narrative said PRISM-DEMO was corrected "throughout" the spec corpus.
    The sweep missed BC-3.01.001's tokenizer test vectors. The root cause: the sweep was
    run against the artifacts the PO/FV touched in that burst, not against the full in-scope
    set. Rule: any "throughout" claim in a burst narrative must be backed by an explicit
    grep across every artifact in scope for that cycle — not just the files already open
    in the editor. Log the grep command and its hit count in the burst commit message.
    _Discovered: F2 adversarial pass 14 (P14-003 MINOR), 2026-07-22_

37. **Repurposing a VP ID silently orphans the behavior it used to cover — annotate at
    origin and in every cross-reference [P14-005]** — VP-SKILL-053 was repurposed from
    onboard-customer AD-017 credential-provisioning to idempotent directory creation
    (EC-006) during the pass-14 FV cycle. The repurposing was documented in verification-
    delta but not propagated to (a) BC-6.01.003's VP table row for VP-SKILL-053, (b) the
    spec-changelog [1.1.0] New VPs table, or (c) the VP Anchors traceability field. This
    left BC-6.01.003 Invariant #1 / EC-008 (the AD-017 credential-decline path) without
    any formal VP anchor. The same pattern affected VP-SKILL-057 (sensor-metrics org_slug
    scoping → naming-compliance D-DEC-006, repurposed pass-9/P9-005, never annotated in
    spec-changelog). Rule: when a VP ID is repurposed, update (1) the VP roster row in
    verification-delta with a repurposing note, (2) the original BC's VP table row to
    reflect the new property, (3) the spec-changelog New VPs table row with the repurposing
    annotation, and (4) the BC's VP Anchors field. Ensure the behavior previously covered
    is explicitly re-anchored to a new VP or flagged as a VP-orphan requiring FV attention.
    _Discovered: F2 adversarial pass 14 (P14-005 MINOR), 2026-07-22_

---

## Burst-10 Follow-up Coherence Correction (2026-07-22)

### Process-Level

38. **[process-gap] A fix allocating a VP to restore orphaned coverage must verify the new
    VP covers ONE behavior — a scope collision between a "pending VP placeholder" resolved
    to an existing VP ID reproduces the one-ID-two-behaviors anti-pattern the fix intended
    to close [burst-10 follow-up]** — The burst-10 fix for P14-005 (VP-ID repurposing
    orphaning AD-017 credential-decline coverage) wrote "AD-017 coverage moved to
    VP-SKILL-076" in both the spec-changelog and BC-6.01.003 anchors — but VP-SKILL-076
    was already scoped to the P14-002 setup-time jira_project_key charset-validation gate,
    a wholly unrelated behavior. The fix conflated two distinct behaviors under one VP ID:
    the exact one-ID-two-behaviors anti-pattern lesson 37 (P14-005) flagged. The
    orchestrator caught the conflation at burst close before the next adversarial pass.
    Lesson: when allocating a VP to restore orphaned coverage, verify the new VP covers ONE
    behavior. A "pending VP placeholder" (e.g., "VP-SKILL-TBD") that gets resolved to an
    EXISTING VP ID (rather than a fresh next-free ID) must be explicitly checked for scope
    collision against that ID's current definition before the annotation is committed.
    A scope collision under a single VP ID is equivalent to the original orphaning — it
    just produces a different coverage gap (one VP doing two things rather than zero VPs
    for one thing). The correct fix: allocate the next-free ID (VP-SKILL-077) for the
    orphaned behavior and keep VP-SKILL-076 scoped strictly to its existing property.
    _Discovered: burst-10 follow-up coherence correction (orchestrator-caught conflation), 2026-07-22_

---

### Lesson 39 — [process-gap] Consumer-side propagation of design eliminations (pass-15, burst-11, 2026-07-22)

[process-gap] a design ELIMINATION (P13-001 removed the markdown comment marker) must be
propagated to CONSUMER contracts, not only the emitter+verifier+index docs — BC-4.02.001/BC-5.01.001
named the eliminated mechanism as their authorization path and survived 2 passes stale; a
consumer-side re-derivation (not emitter-anchored) is what surfaced it. When a mechanism is
removed, grep every BC that CONSUMES it, not just the one that DEFINES it.
    _Discovered: pass-15 (P15-001) — surfaced by adversary pass, remediated burst-11, 2026-07-22_

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

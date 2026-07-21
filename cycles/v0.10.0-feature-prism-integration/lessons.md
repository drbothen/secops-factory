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

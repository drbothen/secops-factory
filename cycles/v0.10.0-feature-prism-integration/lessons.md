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
| 1 | Fail-loud gate placement | Deterministic hook design | proposed |
| 2 | Kill-switch exemption precondition | Autonomy circuit-breaker design | proposed |
| 6 | Cross-document count propagation atomicity | Count-changing bursts | proposed |

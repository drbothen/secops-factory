---
document_type: adversarial-review
pass: 6
producer: adversary
date: 2026-07-21
cycle: v0.10.0-feature-prism-integration
scope: F2 spec-evolution delta package (brief, architecture-delta v1.8, verification-delta v1.8, prd-delta v1.9, BC-3.01.001 v1.17, BC-3.03.001 v1.14, BC-10.01.001 v1.10, + supporting BCs/DTU/ASM)
---

# Adversarial Spec-Delta Review — Pass 6

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 2 |
| MAJOR | 3 |
| MINOR | 3 |
| OBSERVATION | 2 |

The marker mechanism, hard-floor logic, JSON-first dispatch, enum validation, watermark
atomicity, and audit-forgery surfaces are genuinely well-hardened after five prior passes.
The novel findings this pass are **not** in those already-attacked surfaces. They live in
the *seams between* the emitter's O3 cross-validation and (a) the **consumer's** acceptance
of review tokens, and (b) the **control-ordering** of the kill switch vs. the under-label
upgrade. Every prior pass hardened the emitter (`hard_floor_applies()` vs `ticket_action_type`);
none re-derived whether the *consumer* honors the review/regular distinction, nor whether the
fail-loud safety net is reachable under the kill switch. Both are exploitable.

---

## Critical Findings

### P6-001 — `create-review`/`comment-review` markers are fungible with regular `create`/`comment` commands at the consumer; the kill switch and hard-floor block are bypassable — CRITICAL

**Documents/anchors:**
- Consumer: `BC-3.01.001.md` Postcondition #2, consumer algorithm **step (6)** (lines 95–101):
  `jr issue create ...` accepts a marker with `["create"]` **OR** `["create-review"]`;
  `jr issue comment ...` accepts `["comment"]` **OR** `["comment-review"]`.
- Emitter generation table: `BC-3.03.001.md` Invariant #4 table (lines 421–426) — the
  `command_pattern` for `create` and `create-review` is **byte-identical**
  (`^jr (--output json )?issue create --project <jira_project_key>( |$)`); likewise `comment`
  and `comment-review` are identical (`^jr (--output json )?issue comment <ticket_id> `).
- `BC-3.03.001.md` Invariant #4 STEP 3 (lines 202–204): *"Require-review does not enforce
  label content — that invariant lives in SKILL.md."*
- `architecture-delta.md` §D-DEC-012 "Alternatives Rejected" (lines 1835–1839): the design
  **explicitly** rejects hook-side label enforcement and delegates the review-vs-regular
  distinction to the LLM-executed SKILL.md Iron Law.

**Description:** `require-review` (the deterministic trust boundary) distinguishes markers
only by `command_pattern` (a regex) and `authorized_operations` membership. Because the
`create` and `create-review` command_patterns are identical and step (6) accepts *either*
token for a `jr issue create`, a `create-review` marker authorizes **any** `jr issue create`
command matching the project pattern — including a regular autonomous ticket creation. The
label (`[REVIEW-REQUIRED]`/`[BLIND-SPOT]`) that is supposed to make a review marker "escalation
only" is enforced **nowhere on the trusted path** — only in SKILL.md, which the entire threat
model treats as untrusted (that is *why* hooks exist). This is an O3-standing-rule violation
at the consumer: the emitter cross-validates `ticket_action_type` against `hard_floor_applies()`
(STEP 3), but the consumer never cross-validates that the *command it authorizes* is actually
a review-labeled command.

**Failure scenario (kill-switch bypass):**
1. Operator sets `autonomy_enabled=false` (emergency brake engaged).
2. Loop run processes Alert A (Indeterminate — a hard floor) → SKILL sets
   `ticket_action_type=create-review` → disposition-guard STEP 3 issues a `create-review`
   marker (exempt from kill switch, correctly). Marker pattern:
   `^jr (--output json )?issue create --project PRISM-DEMO( |$)`.
3. The same run (or a prompt-injected/misbehaving loop) issues a *regular* autonomous
   create: `jr issue create --project PRISM-DEMO --summary "auto-closed FP"`.
4. `require-review` scans, finds the `create-review` marker (pattern matches;
   `["create-review"]` accepted for `jr issue create`), consumes it, **emits allow**.
   An autonomous create executed while the kill switch was ON.
5. Alert A's genuine escalation create then finds no marker → **DENIED**. The real
   hard-floor escalation is silently starved — the exact fail-loud failure D-DEC-012 exists
   to prevent.

Even with `autonomy_enabled=true`, iterative-consume (sorted by `issued_at_utc` ASC) makes
it non-deterministic which command consumes which same-pattern marker, so a regular
autonomous create can steal a hard-floor escalation's `create-review` marker → the fail-loud
guarantee ("hard-floor verdict always reaches Jira") is not actually guaranteed.

**Why prior passes missed it:** passes 4–5 (P4-004, P5-001, P5-002) hardened the *emitter's*
token cross-validation. The consumer's step-(6) token-acceptance widening (BC-3.01.001 v1.16)
was reviewed only for "does it consume the new tokens," never for "can a review token
authorize a non-review command."

**Remediation:** bind review markers to review-only commands at the *hook* layer, not
SKILL.md. Options: (a) give `create-review`/`comment-review` a distinct command_pattern that
require-review can require — e.g., mandate a fixed `--label REVIEW-REQUIRED`/`BLIND-SPOT`
argument in a fixed position and encode it into the anchored pattern (mirrors the
`--project`-first Iron Law from P4-002); or (b) have require-review refuse to consume a
`["create-review"]`/`["comment-review"]` marker for a command that does not carry the review
label. Until the review/regular distinction is enforced deterministically, the kill switch and
the hard-floor block are bypassable whenever any hard-floor verdict coexists with a regular
write attempt in the same run — i.e., the common case.

---

### P6-002 — Fail-loud invariant is violated for under-labeled hard-floor verdicts when `autonomy_enabled=false`: STEP 4 (kill switch) precedes STEP 5 (under-label upgrade), producing a silent discard — CRITICAL

**Documents/anchors:**
- Emitter ordering: `BC-3.03.001.md` Invariant #4 pseudocode — **STEP 4** autonomy kill switch
  (lines 249–252: `IF autonomy_enabled is NOT exactly boolean true: emit allow without marker; RETURN`)
  executes **before** **STEP 5** the under-label fail-loud upgrade (lines 254–302).
- `BC-3.03.001.md` **EC-012 case (d)** (line 467): *"under-labeled (non-review token) +
  `autonomy_enabled=false` → STEP 4 kill switch fires; NO marker; downstream jr denied."*
- `BC-3.03.001.md` Canonical Test Vector (line 488): Indeterminate + severity=HIGH +
  `ticket_action_type=create` (under-labeled) + `autonomy_enabled=false` → *"allow; NO marker
  written (STEP 4 kill switch fires before STEP 5 upgrade — hard-floor upgrade path never reached)."*
- `BC-10.01.001.md` Invariant #10 v1.10 note (lines 284–286): admits *"STEP 5 runs after STEP 4
  … so the upgrade applies when `autonomy_enabled=true`."*
- Contradicted invariant: `architecture-delta.md` §D-DEC-012 fail-loud (lines 1776–1782):
  *"Hard-floor or Indeterminate verdicts MUST result in exactly one of: (1) a
  create-review/comment-review marker … OR (2) an explicit error artifact … NEVER: silent
  discard."* Same claim in `BC-10.01.001.md` Invariant #10 ("Hard-floor verdicts are NEVER
  silently discarded").

**Description:** The P5-001 remediation added STEP 5 as a *deterministic safety net* that
upgrades an under-labeled hard-floor verdict to a review marker (or writes an error + deny).
The stated purpose is to stop relying on the untrusted LLM to label correctly. But STEP 4
(the `autonomy_enabled` kill switch) returns *before* STEP 5. Therefore, when the operator has
engaged the kill switch **and** the LLM under-labels a hard-floor verdict (sets `create`/`none`
instead of `create-review`), the hook emits `allow without marker` and RETURNs — **no marker,
no review ticket, no error artifact, no audit entry.** The finding vanishes silently.

This is precisely the silent-discard failure mode P5-001 claimed to eliminate "deterministically
at the hook layer," and it survives whenever `autonomy_enabled=false` — which is exactly when
operators most need findings surfaced. The mechanism therefore contradicts its own unconditional
"NEVER silently discarded" invariant. BC-10.01.001 Invariant #10 self-contradicts: its headline
says hard-floor categories *always* route to human via a restricted review marker, while its own
v1.10 implementation note concedes the upgrade only runs under `autonomy_enabled=true`.

**Verification blind spot (compounds this):** VP-HOOK-029's fail-loud vectors
(`verification-delta.md` line 542, SM-32a) all implicitly assume STEP 5 is reachable
(`autonomy_enabled=true`). There is **no** vector for `under-label + autonomy_enabled=false`.
So the one VP charged with proving "no hard-floor finding is silently discarded" cannot detect
this case — the coverage hole matches the defect exactly.

**Remediation:** move the `hard_floor_applies()` evaluation and the STEP 5 under-label upgrade
**before** the STEP 4 kill switch (mirroring STEP 3, which correctly precedes STEP 4 for
correctly-labeled review tokens). An under-labeled hard-floor verdict must be upgraded to a
review marker (or produce an explicit error + deny) *regardless* of `autonomy_enabled`, which
is consistent with Option A (escalation survives the kill switch). Add a VP-HOOK-029 vector for
`under-label + autonomy_enabled=false → review marker OR error, never silent allow`.

---

## Major Findings

### P6-003 — Invariant #11 and VP-SKILL-065 ("ZERO jr create/comment/assign under `autonomy_enabled=false`") contradict D-DEC-012 Option A / EC-006 / EC-014 (review markers execute jr writes under the kill switch) — MAJOR

**Documents/anchors:**
- `BC-10.01.001.md` Invariant #11 (lines 326–336): *"When `autonomy_enabled` is false, **all**
  autonomous Jira actions (jr issue comment/create/assign) are halted … Only the Jira execution
  is suppressed."* No carve-out for review markers.
- `BC-10.01.001.md` VP-SKILL-065 (line 453; also lines 333–336): *"when `autonomy_enabled=false`,
  ZERO markers are consumed AND **ZERO `jr issue create/comment/assign` calls** are made."*
- `verification-delta.md` §6 VP-SKILL-065 note (lines 637–644): asserts *"the jr-mock spy records
  **zero** `jr issue create/comment/assign` invocations."*
- Contradicting: `BC-10.01.001.md` **EC-006** (line 410, silent sensor → `create-review`,
  *"EXEMPT from autonomy_enabled kill switch"*), **EC-014** (line 418, Indeterminate →
  *"require-review consumes marker; `jr issue create`/`comment` executed … EXEMPT from
  `autonomy_enabled` kill switch"*), and `architecture-delta.md` §D-DEC-012 Option A
  (lines 1767–1774).

**Description:** Option A (human-confirmed 2026-07-21) mandates that `create-review`/`comment-review`
markers ARE issued and consumed — i.e., real `jr issue create`/`comment` calls execute — even
when `autonomy_enabled=false`, for genuine hard-floor verdicts. But Invariant #11 and its
finalized VP-SKILL-065 still assert the pre-Option-A semantics: **zero** jr writes under the
kill switch. In the very common scenario of a silent sensor or Indeterminate verdict with the
kill switch on, the loop WILL issue a `jr issue create` for the BLIND-SPOT/REVIEW-REQUIRED
ticket — directly falsifying VP-SKILL-065's assertion. The Option-A exemption propagated to
Inv#10, EC-006, EC-014, D-DEC-012, BC-3.03.001 STEP 3, and BC-3.01.001 step (6), but was **not**
propagated to Invariant #11 or VP-SKILL-065 (both still marked FINALIZED). This is a
propagation gap plus a live contradiction.

**Failure scenario:** The FV implements VP-SKILL-065 as written (assert zero jr writes when
`autonomy_enabled=false`). A legitimate silent-sensor run creates a BLIND-SPOT ticket under the
kill switch → the test fails on correct behavior. Alternatively, an implementer reads Invariant
#11 literally ("all autonomous Jira actions are halted") and suppresses the review-ticket
create → breaks the D-DEC-012 escalation guarantee. Either path is wrong because the spec is
internally contradictory.

**Remediation:** narrow Invariant #11 and VP-SKILL-065 to carve out `create-review`/`comment-review`:
"under `autonomy_enabled=false`, zero **regular** (comment/create/assign) markers are consumed
and zero **regular** jr writes occur; `create-review`/`comment-review` escalation writes for
genuine hard-floor verdicts still execute per D-DEC-012 Option A." Re-mark VP-SKILL-065 as
re-scoped, not silently FINALIZED.

---

### P6-004 — Create-marker "org binding" via `jira_project_key` is void under the brief's single-demo-project config; architecture-delta assumes per-org project keys the brief does not provide — MAJOR

**Documents/anchors:**
- `architecture-delta.md` §D-DEC-008 create org-binding (lines 973–980) and generation table
  (lines 959–960): examples `--project SEC_ORG_A` / `--project SEC_ORG_B`; claim *"A create
  marker for org-b's key … cannot match a command with `--project SEC_ORG_A`."*
- `BC-3.01.001.md` create-scope project-binding note (line 177): *"a create marker for
  `--project ORG-A` cannot authorize `jr issue create --project ORG-B`."*
- `BC-10.01.001.md` Invariant #9 operational field (line 249): singular
  `jira_project_key` / *"Iron Law: … `--project ${JIRA_PROJECT_KEY}`."*
- Contradicting: brief §4.1 (*"A demo Jira project (e.g., key `PRISM-DEMO`)"*) and §4.4
  (*"The demo Jira project key and server URL are configuration inputs … stored in the plugin
  config"* — singular).

**Description:** The create-marker cross-org isolation property (ADV-F2-P3-002) relies on each
org mapping to a **distinct** Jira project key encoded in `command_pattern`. But the brief
mandates a **single** demo Jira project (`PRISM-DEMO`) shared by all orgs (org-a/b/c), and the
plugin stores one `JIRA_PROJECT_KEY`. Therefore every `create`/`create-review` marker across all
orgs shares the identical `command_pattern` `^jr (--output json )?issue create --project
PRISM-DEMO( |$)`. `require-review` does not check `marker.org_slug`, so a create marker issued
for org-a's verdict authorizes a create "for" org-b. The stated "defeats cross-org marker
fungibility" security property does not hold under the documented deployment.

This also **amplifies P6-001**: with one project key, *all* create-type markers (regular and
review, across all orgs) are mutually fungible, maximizing the kill-switch-bypass window.

**Remediation:** either (a) require a distinct Jira project key per org in the demo/config and
make that a validated invariant, or (b) have `require-review` cross-check `marker.org_slug`
against an org identifier that is deterministically present in the command, or (c) explicitly
downgrade the "cross-org create isolation" claim and document that create-marker scope is
bounded only by single-use + TTL when a shared project key is used. Reconcile the
`SEC_ORG_A`/`SEC_ORG_B` per-org-key examples with the brief's single-project reality.

---

### P6-005 — Enum-validation `severity` set omits any mapping from prism/sensor-native severity encodings; conservative CRITICAL default + fail-closed enum deny can mass-route benign traffic to human, and non-enum sensor severities silently fail the pipeline — MAJOR

**Documents/anchors:**
- `BC-3.03.001.md` Invariant #4 `validate_enums()` (lines 150, 157–158):
  `SEVERITY_ENUM = {"LOW","MEDIUM","HIGH","CRITICAL"}`, case-exact, fail-closed deny on
  non-member.
- `BC-10.01.001.md` Invariant #9 field 13 (lines 227–229): *"severity … matches alert.severity
  from sensor data at Stage 5; **defaults to CRITICAL** if sensor does not provide severity."*
- No document defines a mapping from sensor-native severity representations (CrowdStrike numeric
  severity 1–100, Armis/Claroty risk bands, CVSS scores) to the four-value enum.

**Description:** The verdict `severity` must be exactly one of `LOW|MEDIUM|HIGH|CRITICAL`
(case-exact), and disposition-guard fail-closed **denies** any non-member value (P4-006). But
prism normalizes four different sensors (CrowdStrike, Armis, Claroty, Cyberint), whose native
severities are not the four-value enum (e.g., CrowdStrike detections use numeric severity; NVD
enrichment yields CVSS floats). No spec defines the normalization. Two failure modes:
1. If the loop passes a raw sensor severity (e.g., `"Medium"` wrong-case, `"70"`, `"9.1"`),
   `validate_enums()` denies the Write → verdict blocked → no marker → the entire alert is
   dropped from the autonomous path (silent w.r.t. Jira). This is a pipeline-unreachability
   analogue of the P4-001 dispatch collision, but for severity normalization.
2. The "defaults to CRITICAL if sensor does not provide severity" rule means any sensor that
   emits severity in an unrecognized field/format is treated as CRITICAL → hard floor → routed
   to human. Combined with (1)'s deny, an entire sensor family with a non-conforming severity
   representation either mass-escalates or mass-denies.

The loop's severity-normalization step is the load-bearing bridge and it is unspecified; this
is exactly the kind of "unstated assumption at the system boundary" that will surface only
against live prism data (ASM-008 is UNVALIDATED and prism is not yet available).

**Remediation:** specify the sensor-native → `{LOW,MEDIUM,HIGH,CRITICAL}` normalization
(per sensor family and for CVSS→enum), as a named step in BC-10.01.001 Stage 5 (and Stage 1 for
the known-FP fast path), with an explicit rule for "unrecognized severity → CRITICAL (hard
floor) with `uncertainty_explicit` set" so the conservative default is *auditable* rather than
a silent enum-deny. Add a VP for severity normalization.

---

## Minor Findings

### P6-006 — D-DEC-004 (BLIND-SPOT dedup) is stale relative to D-DEC-012: still describes hard-floor silent-sensor tickets via bare `jr issue create` with no `create-review`/`comment-review` mapping — MINOR

**Anchors:** `architecture-delta.md` §D-DEC-004 (lines 735–804), esp. the dedup algorithm
(lines 760–774): *"CREATE new BLIND-SPOT ticket … Disposition field:
Indeterminate-due-to-missing-telemetry"* — with no mention that a silent-sensor verdict is a
hard floor whose `ticket_action_type` must be `create-review`/`comment-review` (D-DEC-012), and
no mention of the marker path. The correct behavior is only reconciled downstream in
BC-10.01.001 EC-006/EC-014. A reader treating D-DEC-004 as the authoritative BLIND-SPOT spec
would implement a bare `create` that the kill switch/hard-floor would block (or, per P6-001,
that would fungibly consume a review marker). **Remediation:** update D-DEC-004 to state
`ticket_action_type=create-review` (new) / `comment-review` (open-ticket dedup) and reference
the D-DEC-012 exempt-marker path.

### P6-007 — Grace-window permanent-drop trade-off (D-DEC-002) is a documented silent data-loss path with no detection VP — MINOR

**Anchors:** `architecture-delta.md` §D-DEC-002 ADV-F2-P4-O3 note (lines 458–462): events with
ETL latency > `WATERMARK_GRACE_SECONDS` are *"PERMANENTLY dropped (not deferred)."* The
monotonic WRITE guard (`max(stored, ts)`, lines 423–438) means once the watermark advances past
a late event's `_time`, that event is never re-queried. This is a silent missed-alert path
(the watermark store is HIGH criticality per C-30). No VP asserts detection of drop when
observed ETL latency exceeds the configured grace window; VP-SKILL-068 only covers the
*in-grace* dedup case. Given prism's `_time` format and ETL latency are both UNVALIDATED
(ASM-008), operators cannot currently set `WATERMARK_GRACE_SECONDS` correctly.
**Remediation:** add an operational check that emits a fail-loud finding when an ingested
event's `_time` is older than `watermark - WATERMARK_GRACE_SECONDS` (i.e., a drop *would have*
occurred), and a VP for it. Cross-reference the missing prism `_time`/ETL-latency empirical
gate.

### P6-008 — ASM-009 (cross-hook marker-store visibility) is UNVALIDATED and gates the entire marker mechanism, yet Wave-3 merge depends on a test that does not yet exist — MINOR

**Anchors:** `architecture-delta.md` §4.2 ASM-009 (line 2091, impact "HIGH — if hooks cannot
share the marker store, the marker mechanism fails entirely"); `BC-3.03.001.md` Refactoring
Notes (line 552, "ASM-009 … is UNVALIDATED; formal-verifier must design a BATS test … before
Wave 3 story merge"); `prd-delta.md` §6 Q5 (lines 154–158). The single most load-bearing
architectural assumption (that disposition-guard's write is visible to require-review's read
across two separate PreToolUse subprocess invocations in the same session) is unproven, and the
gating test is only *proposed*. If ASM-009 is false, D-DEC-001 has no viable fallback (the
architecture itself states in-process markers are "not possible given hook architecture").
**Remediation:** elevate the ASM-009 empirical probe to a blocking pre-Wave-3 deliverable with
an explicit go/no-go; the marker design should not be treated as RESOLVED while its foundational
assumption is UNVALIDATED.

---

## Observations

### P6-009 — [process-gap] The O3 standing rule ("LLM-supplied routing fields must be cross-validated against a hook-computed invariant") was applied only to the emitter, never audited across the consumer and control-ordering — OBSERVATION

`architecture-delta.md` §D-DEC-012 codifies the O3 standing rule (lines 1795–1810) with a table
covering only emitter-side fields (`ticket_action_type`, `autonomy_enabled`). Findings P6-001
(consumer accepts review tokens for regular commands) and P6-002 (kill switch precedes the
under-label upgrade) are both O3 violations that the emitter-only framing structurally cannot
catch. The remediation process treated each adversarial finding as a point-fix in the emitter
pseudocode without a systematic "apply O3 to every trust-boundary crossing" sweep — which is why
two O3 gaps survived five passes. **Remediation:** extend the O3 standing rule with an explicit
audit checklist item that every marker *consumption* and every *control-flow ordering* between a
kill switch and a fail-loud upgrade must also be cross-validated, and require each future pass to
re-derive the consumer/ordering surfaces rather than inherit the emitter-only conclusion.

### P6-010 — VP-HOOK-029 (the fail-loud safety invariant) remains PROPOSED/P1/"F6-adjudicated" while carrying the system's most important safety guarantee — OBSERVATION

`verification-delta.md` (lines 177, 458) and `BC-10.01.001.md` (line 288) keep VP-HOOK-029 at
`PROPOSED` lifecycle, deferred to F6 adjudication, even though it is the sole VP asserting "no
hard-floor finding is silently discarded" — the guarantee that P6-002 shows is actually
violated. A CRITICAL safety invariant whose covering VP is not yet FINALIZED, and whose vector
set (per P6-002) has a hole for `autonomy_enabled=false`, is a verification-maturity risk worth
flagging even though the *strategy* is claimed finalized. **Remediation:** finalize VP-HOOK-029
and expand its vectors to include the kill-switch-on under-label case before Wave-7 sizing is
locked.

---

## Novelty Assessment

**Novelty: HIGH.** These findings are **not** re-treads of the P1–P5 marker/dispatch/enum/audit
issues (all of which are genuinely closed). P6-001 and P6-002 are new, distinct, and exploitable
security defects in the *interaction* between components that each prior pass validated in
isolation: the emitter's O3 cross-validation is sound, but it does not extend to the consumer
(P6-001) or survive the kill-switch/upgrade ordering (P6-002). P6-003 and P6-004 are live
contradictions created by incomplete propagation of the pass-4/pass-5 Option-A and org-binding
decisions into sibling invariants/VPs and against the brief's single-project reality. This
directly validates the "fresh-context compounding value" and "partial-fix regression discipline"
lessons: the value came from re-deriving the trust boundary end-to-end (emit → store → consume →
kill switch → fail-loud) rather than inheriting the emitter-centric conclusions of prior passes.
The package has **not** converged; P6-001 and P6-002 are convergence-blocking.

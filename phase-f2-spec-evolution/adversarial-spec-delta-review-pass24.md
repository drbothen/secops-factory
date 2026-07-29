# Adversarial Spec-Delta Review — Pass 24

**Pass:** 24
**Date:** 2026-07-29
**Reviewer:** adversary (fresh context; no access to prior-pass reviews, consistency audits, STATE.md, or cycle notes)
**Perimeter reviewed (versions):** architecture-delta v1.25, verification-delta v1.25, prd-delta v1.23, dtu-assessment v1.4, spec-changelog (1.1.0, burst-20), BC-3.03.001 v1.32, BC-3.01.001 v1.25, BC-10.01.001 v1.26, BC-4.02.001 v1.17, plus BC-4.05.001/5.01.001/6.01.001/6.01.003/6.01.004/8.02.001/9.01.001 (sampled). Ground-truth CLI verb inventory applied as given.

## Methodology

Re-derived the disposition-guard emitter control flow from BC-3.03.001 pseudocode independently (STEP 0→1→1a→2→3→3b→4→4b→5→6 + EMIT_LINK_MARKER subroutine + WRITE_MARKER), then attacked along the four mandated axes: reachability-of-guarantee, new-mechanism (D-027/D-028) plumbing abuse, test-vector↔pseudocode coherence, and CLI-surface completeness. Cross-checked canonical test vectors (BC-3.03.001 L1082–1119), the dtu-assessment v1.4 scenarios, and the verification-delta SM-74/SM-75 kill vectors against the pseudocode. Verified version propagation (BC frontmatter vs spec-changelog burst-20 vs prd-delta §5/post-note). Ran the self-validation loop (evidence / actionability / duplication) on every finding; demoted two candidates to Observations.

CLI surface is CLEAN: current pseudocode authorizes only `jr issue {create, comment, assign, link, move, view --output json, list --jql}` — all exist. No residual `jr issue search / transition / reopen` in the live emitter, consumer allowlist, or dtu scenarios (BC-3.01.001 L314, dtu L284-288 correctly annotate non-existence).

---

## Critical Findings

None.

## Important Findings (MEDIUM — block a clean pass)

### P24-001 — EMIT_LINK_MARKER subroutine control-flow is self-contradictory; is_link_hard_floor / link_target / pattern cannot reach WRITE_MARKER (D-028 plumbing) — MEDIUM (HIGH confidence)

**Artifact:** BC-3.03.001 v1.32, lines 461-462, 557, 626-627, 681-782, 791-799.

**Defect.** P23-004 replaced the "ill-formed `GOTO STEP6_LINK`" with a named subroutine, but the replacement is equally ill-formed and moves the defect rather than fixing it. The pseudocode simultaneously requires two mutually-exclusive semantics:

- **Call-return semantics** are needed to bind the parameter: both call sites pass `is_hard_floor_link` as a named argument — STEP 3b `EMIT_LINK_MARKER(verdict, recomputed_severity, is_hard_floor_link=true)` (L461) and STEP 6 link `...is_hard_floor_link=false)` (L626) — and the body reads it at L780 `is_link_hard_floor = is_hard_floor_link`. Parameter binding only exists under function-call semantics.
- **Fall-through / flat-scope semantics** are needed for the result to reach the marker write: the block ends `END FUNCTION EMIT_LINK_MARKER` (L781) with the comment "EMIT_LINK_MARKER falls through to WRITE_MARKER below" (L782), and WRITE_MARKER (L791+, *outside* the function) reads `pattern`, `ops`, `ticket_id`, `link_target`, and `is_link_hard_floor` — all assigned *inside* the function (L773-780).

These cannot both hold. Under the literal function-call reading: (a) both call sites do `EMIT_LINK_MARKER(...); RETURN`, so control returns to the caller which immediately RETURNs — **WRITE_MARKER is never reached for any link path, and no link marker is ever written**; and (b) `is_link_hard_floor`, `pattern`, `link_target` set inside the function are local, so WRITE_MARKER's guard `is_link_hard_floor = defined(is_link_hard_floor) ? is_link_hard_floor : false` (L798) sees it **undefined → defaults false** — silently downgrading a hard-floor link so `is_review_path` (L799) is FALSE. Under the charitable flat-scope/GOTO reading: the trailing RETURNs at L462/L626 are dead, `link_target=null` (L557, main scope) is never overwritten by the function-local `link_target=ticket_id_b` (L775) → `marker.link_target_ticket_id=null`, AND the `is_hard_floor_link` parameter has no binding mechanism → the true/false distinction is lost.

**Failure scenario.** Every consistent literal reading defeats the exact D-028 guarantee burst-20 exists to establish. SM-74's own kill vector (verification-delta L1335) *requires* that a hard-floor link with `is_link_hard_floor=true` reach WRITE_MARKER and evaluate `is_review_path=TRUE`; canonical vectors L1103/L1116 assert the same. A faithful implementation of the pseudocode-as-written would produce `is_review_path=false` for hard-floor links (or write no link marker at all), so the MARKER-WRITE-FAILED fail-closed behavior — the entire P23-001 deliverable — is inert, and SM-74 would not actually be killed by a spec-faithful hook.

**Remediation direction.** Realize the intent unambiguously as a single flat scope: either (i) inline the link-marker block into both STEP 3b and STEP 6 with a real preceding assignment `is_link_hard_floor = <true|false>` (no `FUNCTION`/`END FUNCTION`, no trailing RETURN, explicit `GOTO WRITE_MARKER` mirroring STEP 3), or (ii) make EMIT_LINK_MARKER a true function that *returns* `(pattern, ops, ticket_id, link_target, is_link_hard_floor)` and have each caller pass those into WRITE_MARKER. Remove the "falls through to WRITE_MARKER" comment if adopting (ii). This is a partial-fix residual of P23-004 (S-7.01) and should carry the same MEDIUM severity as the original.

### P24-002 — `resolved_project_key` interpolated into the org-binding regex without emit-time charset re-validation or regex-escape (O7 / defense-in-depth parity gap) — MEDIUM (MEDIUM confidence)

**Artifact:** BC-3.03.001 v1.32, EMIT_LINK_MARKER L736-770 (esp. L748, L760); contrast close-path L662-676; O7 site list L925.

**Defect.** The D-028 org-binding builds a live regex `"^" + resolved_project_key + "-[0-9]+$"` and matches KEY1/KEY2 against it (L748, L760). `resolved_project_key` comes from `read_org_project_key(verdict.org_slug)` — a config-derived value — and is interpolated **without a charset check and without `regex_escape()`**. This is the only interpolation of a config value into a matching regex in the whole emitter, and it is *not* one of the 9 enumerated O7 sites (L925). By contrast, the sibling config-derived value `jira_close_state` is given three-layer protection *precisely because* "setup-time validation is temporally distant from command issuance" and to defend against config drift: emit-time CLOSE_STATE_ALLOWLIST re-check (L666) + `regex_escape(close_state)` (L676, O7 site 9). The org-binding key receives neither, despite being interpolated into a *regex* (a strictly more dangerous sink than the anchored command_pattern) whose corruption would **broaden** the binding match.

**Failure scenario.** If config drift or a setup-validation gap yields a malformed `jira_project_key` (e.g. `SEC|.*` or `.*`), the binding regex becomes `^SEC|.*-[0-9]+$` / `^.*-[0-9]+$`, matching almost any KEY1/KEY2 — defeating the P23-005 cross-project/cross-org guarantee that SM-75 is supposed to protect, with no compensating deny. The LLM cannot write config, so this is a drift/robustness defect rather than a direct injection, but it is exactly the class the project chose to harden emit-time for `close_state`.

**Remediation direction.** Apply the same emit-time treatment the spec already mandates for `close_state`: re-validate `resolved_project_key` against `^[A-Z][A-Z0-9]+$` (fail-closed → e.g. `LINK-PROJECT-KEY-CHARSET-DENY`) and `regex_escape()` it before regex construction; add it to the O7 site inventory; add a covering SM (malformed-resolved-key broadens binding).

### P24-003 — BC-3.03.001 canonical vector L1107 (REGULAR link happy-path) is stale under D-028: asserts `allow` but omits the now-mandatory org-binding precondition — MEDIUM (HIGH confidence)

**Artifact:** BC-3.03.001 v1.32 L1107; contrast sibling D-028 vector L1118; pseudocode L732-770.

**Defect.** D-028 inserted a mandatory org-binding gate into EMIT_LINK_MARKER for **both** entry paths (pseudocode L732 "BOTH entry paths"; confirmed by L1118 "Org-binding fires on BOTH hard-floor and REGULAR paths"). The pre-existing REGULAR-link happy-path vector L1107 (disposition=FP, ticket_id=SEC-42, link_target=SEC-99, non-hard-floor, autonomy=true → `permissionDecision: allow`; marker written) traverses that gate but was **not updated**: it states no `org_slug` and no `resolved_project_key` config, so for its asserted `allow` outcome to hold, an unstated precondition (`read_org_project_key(org_slug)=="SEC"`) must be true. The sibling new vector L1118 explicitly pins "config: resolved jira_project_key=PRISMDEMO for org"; L1107 has no equivalent. As written, the vector's stated inputs are insufficient to reach its stated outcome — an implementer building this BATS case verbatim (no org config) would get `LINK-PROJECT-BINDING-DENY`, not `allow`.

**Failure scenario.** Test-vector↔pseudocode incoherence: the "happy-path (D-020 link scope)" regression test either fails or silently masks the binding gate depending on ambient org config. BC-10.01.001 EC-008 *was* swept for the org-binding flow (spec-changelog burst-20); BC-3.03.001 L1107 was not — an asymmetric propagation (S-7.01(a)/(c)).

**Remediation direction.** Add the org-binding step and its config precondition to L1107 (mirroring L1109's fully-enumerated close happy-path and L1118's config statement), or explicitly note that test setup configures `resolved_project_key=SEC`.

### P24-004 — dtu-assessment `tp-close-denied` scenario under-specifies `scored_priority`; a hard-floor TP+close yields UNDER-LABEL-DENIED (STEP 4), not CLOSE-DISPOSITION-DENY (STEP 4b) — MEDIUM (HIGH confidence)

**Artifact:** dtu-assessment v1.4 L337 (and test-surface row L378); contrast BC-3.03.001 canonical vectors L1112/L1113 and SM-69 kill vector (verification-delta L1330); pseudocode ordering STEP 4 (L492) before STEP 4b (L515), comment L634.

**Defect.** The new `tp-close-denied` scenario asserts "disposition=TP + ticket_action_type=close (any autonomy_enabled value) → STEP 4b … CLOSE-DISPOSITION-DENY" and claims to cover "the SM-69 STEP 4b close-disposition gate for TP disposition" — but it **omits `scored_priority`**. In the pseudocode, STEP 4 (`IF hard_floor_applies()` → HARD-FLOOR-UNDER-LABEL / UNDER-LABEL-DENIED) fires *before* STEP 4b (close-disposition). `hard_floor_applies()` keys on `verdict.scored_priority ∈ {HIGH,CRIT}` (L929). Therefore a TP+close with `scored_priority=HIGH/CRIT` is caught at STEP 4 with audit code **UNDER-LABEL-DENIED**, never reaching STEP 4b's CLOSE-DISPOSITION-DENY — exactly analogous to the pseudocode's own note "Indeterminate+close never reaches this gate — STEP 4 UNDER-LABEL-DENIED fires first" (L634). The authoritative BC vectors L1112/L1113 correctly pin `scored_priority=LOW … non-hard-floor`; SM-69's kill vector pins `scored_priority=LOW`. The dtu scenario does not, so as written it can misfire to the wrong step/code and its `CLOSE-DISPOSITION-DENY`-emitted assertion would fail for a hard-floor TP fixture.

**Failure scenario.** A DTU test built from L337 verbatim, seeding a HIGH-scored TP+close, asserts `CLOSE-DISPOSITION-DENY` but the hook emits `UNDER-LABEL-DENIED` → false failure; or the scenario is silently only-valid for a subset of TP inputs it never states, undermining the SM-69 coverage claim.

**Remediation direction.** Pin the scenario to non-hard-floor (`scored_priority ∈ {LOW,MED}`, healthy sensor, benign technique, non-critical asset) so STEP 4b is the reached gate, matching L1112/L1113 and the SM-69 vector. Optionally add a companion note that hard-floor TP+close is covered by the UNDER-LABEL-DENIED path (STEP 4), not this scenario.

---

## Observations (non-blocking)

- **P24-005 — D-026 orphan-link recovery vs org-binding after a project re-key.** The org-binding requires KEY2 (the *closed* ticket) to match the current `^resolved_project_key-[0-9]+$` (BC-3.03.001 L760). D-026 exists to link an open ticket to a **historical Closed/Resolved** ticket. If the org's `jira_project_key` was changed after the closed ticket was created (config re-key), KEY2 carries the old prefix and gets `LINK-PROJECT-BINDING-DENY`, permanently defeating D-026 self-healing for exactly the older-ticket case it targets. Bounded/rare (re-keys are discouraged), so recorded as an Observation rather than a finding; worth an explicit spec note that D-026 self-healing assumes a stable per-org project key.

- **P24-006 — `verdict.org_slug` is LLM-supplied but unvalidated where it selects config and is written into the marker.** `read_org_project_key(verdict.org_slug)` (L736) uses an LLM-controlled field as the config lookup key, and `marker.org_slug = verdict.org_slug` (L806) is trusted downstream for org scoping; `validate_enums()` (L171-208) never validates `org_slug` (format or membership against configured orgs). This is an ASM-008-class residual (bounded by the org-binding, which still constrains KEY1/KEY2 to *some* configured org's key), and largely pre-dates the burst-20 delta, so it is not scored here — but the binding's trust root is an unvalidated LLM field, worth a tracked note (e.g., validate `org_slug` against the configured `[[orgs]]` set before resolution).

## Surfaces re-derived and found INTACT

- **STEP 4b close-disposition gate reachability (D-025):** Hoisted above STEP 5 (L515 before L547); fires for all `autonomy_enabled` values on non-hard-floor close verdicts; STEP-6 close check is genuine defense-in-depth (L629-646). Vectors L1112/L1113 (SM-69) coherent with pseudocode. INTACT.
- **STEP 3 review-surfacing exemption + HARD-FLOOR-UNBINDABLE (P8-001):** O3 over-label gate (L307-309), create-review null-project-key and comment-review null-ticket_id deny paths (L310-386) all reachable and fail-loud; audit codes exact. INTACT.
- **STEP 3b null-binding guards (D-028):** KEY1/KEY2 null → HARD-FLOOR-UNBINDABLE deny reachable before EMIT_LINK_MARKER (L431-458); vectors L1117 coherent. INTACT (the *downstream* propagation of the flag is P24-001).
- **Charset/injection defense on verdict-supplied keys (O7 P12-001):** All 5+ verdict-side interpolation sites charset-gated + regex-escaped; vectors L1105/L1106/L1108 coherent. INTACT (the config-side `resolved_project_key` gap is P24-002).
- **SM-74/SM-75 allocation + arithmetic:** Both defined with distinct kill vectors (verification-delta L1335-1336); count "68 allocated / 67 live" reconciles (SM-9..75 = 67 ids, +2 for SM-32 variants, −1 SM-55 skipped = 68 allocated; −1 SM-50 retired = 67 live). INTACT.
- **Version propagation (burst-20):** BC-3.03.001 frontmatter v1.32, BC-10.01.001 v1.26, BC-3.01.001 v1.25 all match spec-changelog burst-20 and prd-delta §5/post-note (prd-delta L137). INTACT.
- **CLI surface:** No non-existent verbs authorized/relied upon anywhere in the live delta. INTACT.

## Novelty Assessment

Novelty: MODERATE. The four MEDIUM findings are genuinely new and concentrate in the burst-20 D-028 delta (the freshest, least-reviewed mechanism): a control-flow-soundness residual of the P23-004 fix (P24-001), an O7/defense-in-depth parity gap on the config-side binding key (P24-002), and two test-vector↔pseudocode coherence gaps where the D-028 org-binding and STEP-4/4b ordering were not fully propagated to a pre-existing BC vector (P24-003) and to the new dtu scenario (P24-004). These are substantive gaps in the load-bearing new plumbing, not rewordings — the package has **not** converged. None are mis-anchoring. Recommend re-review after remediation.

**RESULT: 0C / 0M / 4med / 0m / 2 obs**

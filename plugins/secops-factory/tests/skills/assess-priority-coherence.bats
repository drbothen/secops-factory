#!/usr/bin/env bats
# tests/skills/assess-priority-coherence.bats
# S-4.02: assess-priority scored_priority Producer/Consumer Coherence (BC-4.05.001 v1.6)
#
# Covers: AC-001..AC-009 (all story acceptance criteria)
# New delta VPs:
#   VP-SKILL-070 — PrismQL org_slug scoping (AC-008); scope-clarified v1.6 (PC#5b EXEMPT)
#   VP-SKILL-071 — confidence float→enum consistency, D-DEC-011 (AC-009)
#
# ADV-F4-S4.02 findings addressed in pass-1 (BC-4.05.001 v1.5):
#   MAJOR-1   — degraded mode must map 6-factor base score to {CRIT,HIGH,MED,LOW} via PC#6 bands;
#               P1-P5 are INTERNAL-ONLY and never emitted as scored_priority
#   MEDIUM-2  — VP-SKILL-071 tier binding: augment with association check + catalog boundary
#               vectors (0.749→medium, 0.399→low); tier-inversion mutant guard
#   MEDIUM-3  — PC#6 band thresholds missing from SKILL.md (HIGH=14-19; MED=8-13; LOW=<8)
#   MEDIUM-4  — degrade test: replace negative stub-absent check with POSITIVE assertion
#               (uncertainty_explicit + enum mapping under prism-unavailable path)
#   MEDIUM-5  — AC-007 contamination breadth: Critical/Medium labels in ANY output position
#               (not just the exact SEVERITY_TO_SCORED_PRIORITY_MAP self-map rows)
#   OBS-1     — PC#5a grep mis-anchored to degraded-mode prose mention; re-anchored to
#               '### PC#5a' query heading so doc reordering cannot falsely satisfy test
#   OBS-2     — OBS-2 superseded by F3 (v1.6): aggregate count changed from >= 3 to == 2;
#               PC#5b NVD query is now EXEMPT from org_slug per BC v1.6 Invariant #4
#
# ADV-F4-S4.02 findings addressed in pass-1 amendment (BC-4.05.001 v1.6):
#   F1 MAJOR  — frontmatter 'description' advertises "P1-P5" as emitted output; must describe
#               scored_priority/{CRIT,HIGH,MED,LOW} instead (highest-signal line for invoking LLM)
#   F2 MEDIUM — VP-SKILL-071 medium-tier inversion guard: symmetric to 0.75/high guard, assert
#               >= 0.40 binds to 'medium' and NOT 'low'; mutant-resistance guard
#   F3 MEDIUM — PC#5b NVD/CVE enrichment is a GLOBAL query (no org dimension); REVERSAL of
#               v1.5 assertion: PC#5b MUST NOT carry WHERE org_slug=; aggregate count changed
#               from >= 3 to == 2 (only PC#5a and PC#5d carry org_slug); D-DEC-005 preserved
#   F6 MINOR  — output JSON example is a 3-field subset; BC v1.6 PC#6 requires all 8 canonical
#               fields: scored_priority, confidence_score, confidence, disposition, rationale,
#               base_score, prism_enriched, uncertainty_explicit
#
# Regression VPs VP-SKILL-029..034 are already covered by skills.bats and are
# NOT duplicated here per Architecture Context Discipline (DF-021).
#
# ADV-F4-S4.02 findings addressed in pass-3 (this file):
#   MEDIUM-1  — low-tier inversion guard: symmetric to 0.75/high and 0.40/medium guards;
#               '< 0.40' row must bind to 'low' and NOT to 'high' or 'medium'
#   MINOR-2   — Override clamp documented: +1 on CRIT stays CRIT; −1 on LOW stays LOW;
#               scored_priority always in {CRIT,HIGH,MED,LOW} — RED until implementer adds text
#   OBS-4     — Arrow-agnostic boundary matching: 0.749/0.399 binding assertions use
#               [^0-9]+ separator pattern instead of literal U+2192 (→) to survive
#               editor normalization to '->'
#
# Red Gate status against HEAD c54b770 (BC-4.05.001 v1.5 implementation):
#   GREEN (pre-existing, unaffected): AC-001..AC-007, AC-009 stub/inconsistent,
#                                     OBS-1 re-anchor, MEDIUM-2 0.75/high tier-inversion guard,
#                                     MEDIUM-3 x2, MEDIUM-4, MEDIUM-5, MAJOR-1 x3,
#                                     AC-008 PC#5a/PC#5d org_slug presence, DTU-SKIP,
#                                     MEDIUM-2 boundary vectors (0.749/0.399)
#   GREEN (new guard, not red):       F2 medium-tier inversion guard (SKILL.md already correct)
#   RED   (new/tightened in v1.6):    F1, F3 PC#5b reversal, F3 count==2, F6
#
# Red Gate status after pass-3 additions:
#   GREEN (new guard, not red):       MEDIUM-1 low-tier inversion guard (SKILL.md already correct)
#   GREEN (arrow-agnostic, not red):  OBS-4 boundary vector patterns (SKILL.md arrow unchanged)
#   RED   (new, impl required):       MINOR-2 override clamp (SKILL.md has no clamp language)

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."
SKILL="${PLUGIN_ROOT}/skills/assess-priority/SKILL.md"

# ── F1 / ADV-F4-S4.02 — frontmatter description drift ───────────────────────
# BC-4.05.001 v1.6 Invariant #5 / ADV-F4-S4.02-F1
# The YAML frontmatter 'description' field is the highest-signal metadata the invoking LLM reads
# when deciding whether to invoke the skill and what output to expect. Per BC v1.6 Invariant #5,
# P1-P5 are INTERNAL-ONLY intermediate labels — the emitted scored_priority is always a member
# of {CRIT, HIGH, MED, LOW}. Current SKILL.md frontmatter says "...into P1-P5 with SLA."
# which misleads the invoking LLM into expecting P1-P5 as the skill output value.

@test "BC_4_05_001 F1-ADV-F4-S4.02 BC-v1.6-Inv5: SKILL.md frontmatter description must not advertise P1-P5 as emitted output" {
    # F1 MAJOR (BC-4.05.001 v1.6 Invariant #5 / ADV-F4-S4.02-F1)
    # The YAML frontmatter 'description' (line ~3) is the highest-signal metadata the invoking LLM
    # reads. Per BC v1.6, P1-P5 are INTERNAL-ONLY; the emitted output is scored_priority from
    # {CRIT, HIGH, MED, LOW}. A description advertising "into P1-P5 with SLA" trains the invoker
    # to expect P1-P5 as the output — a SEVERITY-MISMATCH DENY vector on every invocation.
    # Anchored to the first 5 lines (YAML frontmatter block) so body prose references to P1-P5
    # (legitimate internal documentation) do not falsely satisfy or fail the test.
    # Red Gate: line 3 currently says "...into P1-P5 with SLA." → ! grep fails → RED.
    ! head -5 "$SKILL" | grep -qF 'P1-P5'
}

# ── AC-001 ──────────────────────────────────────────────────────────────────
# BC-4.05.001 Invariant 5 / P12-004
# The skill 'priority' output IS verdict field 18 'scored_priority' (producer/consumer coherence).

@test "BC_4_05_001 AC-001 P12-004: scored_priority producer/consumer coherence stub is removed" {
    # AC-001 (traces to BC-4.05.001 Invariant 5, P12-004)
    # The skill must write its result to the 'scored_priority' key in the verdict JSON.
    # Proxy: the NOT-IMPLEMENTED-STUB comment documenting the gap must be absent once
    # the section is properly implemented.
    # Red Gate: stub comment present → ! assertion fails → test FAILS.
    ! grep -qF "NOT-IMPLEMENTED-STUB: scored_priority producer/consumer coherence not yet wired" "$SKILL"
}

# ── AC-002 ──────────────────────────────────────────────────────────────────
# BC-4.05.001 Invariant 5 — SCORED_PRIORITY_ENUM = {CRIT, HIGH, MED, LOW}
# Must NOT use SEVERITY_ENUM values (CRITICAL, MEDIUM — note the naming differs).

@test "BC_4_05_001 AC-002: SEVERITY_TO_SCORED_PRIORITY_MAP output uses CRIT not CRITICAL" {
    # AC-002 (traces to BC-4.05.001 Invariant 5 — SCORED_PRIORITY_ENUM values)
    # CRITICAL (SEVERITY_ENUM) input must produce CRIT (SCORED_PRIORITY_ENUM) in the output column.
    # Red Gate: stub table has '| CRITICAL | CRITICAL |' → fixed-string '| CRITICAL | CRIT |' absent → FAILS.
    grep -qF '| CRITICAL | CRIT |' "$SKILL"
}

@test "BC_4_05_001 AC-002: SEVERITY_TO_SCORED_PRIORITY_MAP output uses MED not MEDIUM" {
    # AC-002 (traces to BC-4.05.001 Invariant 5 — SCORED_PRIORITY_ENUM values)
    # MEDIUM (SEVERITY_ENUM) input must produce MED (SCORED_PRIORITY_ENUM) in the output column.
    # Red Gate: stub table has '| MEDIUM | MEDIUM |' → fixed-string '| MEDIUM | MED |' absent → FAILS.
    grep -qF '| MEDIUM | MED |' "$SKILL"
}

# ── AC-003 ──────────────────────────────────────────────────────────────────
# BC-4.05.001 Invariant 5 — SEVERITY_TO_SCORED_PRIORITY_MAP: all four entries correct
# CRITICAL→CRIT, HIGH→HIGH, MEDIUM→MED, LOW→LOW

@test "BC_4_05_001 AC-003: SEVERITY_TO_SCORED_PRIORITY_MAP stub comment removed (placeholders replaced)" {
    # AC-003 (traces to BC-4.05.001 Invariant 5 — SEVERITY_TO_SCORED_PRIORITY_MAP)
    # The mapping-values-are-placeholders stub comment must be gone after implementation.
    # Red Gate: stub comment present → ! assertion fails → test FAILS.
    ! grep -qF "NOT-IMPLEMENTED-STUB: mapping values are placeholders" "$SKILL"
}

@test "BC_4_05_001 AC-003 EC-001/002/003/004: complete SEVERITY_TO_SCORED_PRIORITY_MAP has all correct entries" {
    # AC-003 / EC-001 (CRITICAL→CRIT) / EC-002 (MEDIUM→MED) / EC-003 (HIGH→HIGH) / EC-004 (LOW→LOW)
    # All four map rows must use SCORED_PRIORITY_ENUM values in the output column.
    # Red Gate: '| CRITICAL | CRIT |' absent (stub has CRITICAL→CRITICAL) → first grep fails → FAILS.
    grep -qF '| CRITICAL | CRIT |' "$SKILL"
    grep -qF '| HIGH | HIGH |' "$SKILL"
    grep -qF '| MEDIUM | MED |' "$SKILL"
    grep -qF '| LOW | LOW |' "$SKILL"
}

# ── AC-004 ──────────────────────────────────────────────────────────────────
# BC-4.05.001 Invariant 5 — scored_priority is the canonical output key
# Monitoring-loop reads verdict.scored_priority (field 18); skill must write that key.

@test "BC_4_05_001 AC-004 EC-005 EC-007: skill declares scored_priority as canonical verdict JSON key" {
    # AC-004 (traces to BC-4.05.001 Invariant 5 — monitoring-loop hard-floor keys on field 18)
    # EC-005: output must have 'scored_priority' key, not just 'priority'.
    # EC-007: monitoring-loop must never read field 18 as nil — skill must populate it.
    # Implementation adds '"scored_priority"' as an explicit JSON key in the output format.
    # Red Gate: stub has section header but no '"scored_priority"' JSON key → FAILS.
    grep -qF '"scored_priority"' "$SKILL"
}

# ── AC-005 ──────────────────────────────────────────────────────────────────
# BC-4.05.001 Invariant 5 / P12-004
# Producer/consumer coherence: reading 'priority' output and 'verdict.scored_priority'
# from the same verdict JSON must yield identical values.

@test "BC_4_05_001 AC-005 P12-004: priority and scored_priority coherence documented on same line" {
    # AC-005 (traces to BC-4.05.001 Invariant 5 — P12-004 producer/consumer coherence)
    # SKILL.md must explicitly document that the 'priority' output IS 'scored_priority' (field 18).
    # The coherence mapping must appear as inline prose (not just a stub comment or section header).
    # Pattern: "priority" and "scored_priority" (or "scored priority") must appear on the same line.
    # Red Gate: stub only has section header + stub comment, never both tokens on one line → FAILS.
    grep -qiE "priority.*scored.?priority|scored.?priority.*priority" "$SKILL"
}

# ── AC-006 ──────────────────────────────────────────────────────────────────
# BC-4.05.001 Invariant 5 / P12-004
# All four SCORED_PRIORITY_ENUM values {CRIT, HIGH, MED, LOW} must be producible.

@test "BC_4_05_001 AC-006: all four SCORED_PRIORITY_ENUM values appear as producible output values" {
    # AC-006 (traces to BC-4.05.001 Invariant 5 — SCORED_PRIORITY_ENUM producibility, P12-004)
    # CRIT, HIGH, MED, LOW must each appear as standalone output cell values in the map table.
    # '| CRIT |' and '| MED |' require the correct (non-SEVERITY_ENUM) values.
    # Red Gate: stub has 'CRITICAL' and 'MEDIUM' in output column →
    #   '| CRIT |' absent (CRIT ≠ CRITICAL), '| MED |' absent (MED ≠ MEDIUM) → FAILS.
    grep -qF '| CRIT |' "$SKILL"
    grep -qF '| HIGH |' "$SKILL"
    grep -qF '| MED |' "$SKILL"
    grep -qF '| LOW |' "$SKILL"
}

# ── AC-007 ──────────────────────────────────────────────────────────────────
# BC-4.05.001 Invariant 5 — no SEVERITY_ENUM contamination in scored_priority output

@test "BC_4_05_001 AC-007 EC-006: output column must NOT contain CRITICAL (SEVERITY_ENUM contamination)" {
    # AC-007 (traces to BC-4.05.001 Invariant 5 — no SEVERITY_ENUM contamination)
    # EC-006: scored_priority='CRITICAL' is a defect; test must reject this.
    # The SEVERITY_TO_SCORED_PRIORITY_MAP must not have CRITICAL as an output value.
    # Red Gate: stub row '| CRITICAL | CRITICAL |' is present → ! assertion fails → FAILS.
    ! grep -qF '| CRITICAL | CRITICAL |' "$SKILL"
}

@test "BC_4_05_001 AC-007 EC-006: output column must NOT contain MEDIUM (SEVERITY_ENUM contamination)" {
    # AC-007 (traces to BC-4.05.001 Invariant 5 — no SEVERITY_ENUM contamination)
    # EC-006: scored_priority='MEDIUM' is a defect; test must reject this.
    # The SEVERITY_TO_SCORED_PRIORITY_MAP must not have MEDIUM as an output value.
    # Red Gate: stub row '| MEDIUM | MEDIUM |' is present → ! assertion fails → FAILS.
    ! grep -qF '| MEDIUM | MEDIUM |' "$SKILL"
}

# ── AC-008 / VP-SKILL-070 ────────────────────────────────────────────────────
# BC-4.05.001 Invariant 4, D-DEC-005
# All PrismQL queries (PC#5a, PC#5b, PC#5d) must include explicit org_slug WHERE clause.
# Three legs: (a) static WHERE-clause assertion, (b) DTU multi-org fixture [SKIP], (c) adversarial.

@test "BC_4_05_001 AC-008 VP-SKILL-070: PC#5a 30-day baseline SQL includes WHERE org_slug= clause" {
    # VP-SKILL-070 static leg (traces to BC-4.05.001 Invariant 4, D-DEC-005, vd:427)
    # PC#5a events query must have an explicit org_slug constraint in the WHERE clause.
    # OBS-1 (ADV-F4-S4.02): re-anchored from prose 'PC#5a' mention (degraded-mode text) to the
    # '### PC#5a' query heading so doc reordering cannot falsely satisfy the test via the prose ref.
    # Red Gate: stub PC#5a SQL has 'WHERE rule_id=...' with no org_slug → grep fails → FAILS.
    grep -m 1 -A 20 "### PC#5a" "$SKILL" | grep -q "WHERE org_slug="
}

@test "BC_4_05_001 F3-ADV-F4-S4.02 BC-v1.6-Inv4 VP-SKILL-070: PC#5b NVD enrichment SQL must NOT carry WHERE org_slug=" {
    # F3 MEDIUM (BC-4.05.001 v1.6 Invariant #4 / VP-SKILL-070 / ADV-F4-S4.02-F3)
    # REVERSAL of the v1.5 assertion (which required PC#5b to carry org_slug).
    # BC v1.6 Invariant #4 explicitly exempts PC#5b: NVD/CVE data is public and global — there
    # is no org dimension in the NVD dataset. enrich_nvd() keys on CVE ID, not org_slug. An inert
    # 'WHERE org_slug=' bolted onto a global UDF call is test-gaming, not real isolation.
    # The multi-org isolation guarantee (D-DEC-005) is preserved because PC#5a and PC#5d —
    # the queries that touch org-tenant rows — still carry the WHERE org_slug= constraint.
    # Anchored to '### PC#5b' heading (OBS-1 principle) so prose references cannot satisfy test.
    # Red Gate: current SKILL.md PC#5b has 'FROM dual WHERE org_slug=...' → count=1 → [ 1 -eq 0 ] FAILS.
    pc5b_org_count=$(grep -m 1 -A 10 "### PC#5b" "$SKILL" | grep -c "WHERE org_slug=" || true)
    [ "$pc5b_org_count" -eq 0 ]
}

@test "BC_4_05_001 AC-008 VP-SKILL-070: PC#5d asset criticality SQL includes WHERE org_slug= clause" {
    # VP-SKILL-070 static leg (traces to BC-4.05.001 Invariant 4, D-DEC-005, vd:427)
    # PC#5d assets query must have an explicit org_slug constraint in the WHERE clause.
    # ADV-F4-S4.02 pass-2 F-1 (MEDIUM): re-anchored from prose 'PC#5d' mention (line ~137, which
    # also mentions PC#5a and incidentally captured PC#5a's WHERE clause) to the '### PC#5d' query
    # heading. Mirrors the OBS-1 fix applied to PC#5a. Doc reordering can no longer falsely satisfy
    # this test via the prose reference; only PC#5d's actual query block can satisfy it.
    # Red Gate: stub PC#5d SQL has 'WHERE asset_id=...' with no org_slug → grep fails → FAILS.
    grep -m 1 -A 15 "### PC#5d" "$SKILL" | grep -q "WHERE org_slug="
}

@test "BC_4_05_001 F3-ADV-F4-S4.02 BC-v1.6-Inv4 VP-SKILL-070: exactly two PrismQL queries carry WHERE org_slug= (PC#5a and PC#5d only)" {
    # F3 MEDIUM (BC-4.05.001 v1.6 Invariant #4 / VP-SKILL-070 / ADV-F4-S4.02-F3)
    # BC v1.6: ONLY org-specific queries carry org_slug — PC#5a (30-day org baseline) and
    # PC#5d (per-tenant asset criticality). PC#5b (NVD global UDF) is EXEMPT.
    # Exactly 2 WHERE org_slug= clauses must appear in SKILL.md.
    # Replaces the >= 3 aggregate (OBS-2 v1.5) which forced a semantically inert WHERE org_slug=
    # onto PC#5b's NVD global UDF call. Per BC v1.6 Invariant #4, that count was test-gaming.
    # Per-query presence is verified by the PC#5a and PC#5d individual tests above; this count
    # test provides a complementary aggregate guard: count=3 means PC#5b still carries the
    # inert clause; count<2 means a real org-scoped query lost its constraint.
    # Red Gate: current SKILL.md has 3 WHERE org_slug= lines → [ 3 -eq 2 ] FAILS → RED.
    count=$(grep -c "WHERE org_slug=" "$SKILL" || true)
    [ "$count" -eq 2 ]
}

@test "BC_4_05_001 AC-008 VP-SKILL-070 DTU-SKIP: org-a query returns zero org-b/c rows (multi-org DTU fixture)" {
    # VP-SKILL-070 behavioral leg (traces to BC-4.05.001 Invariant 4, D-DEC-005, vd:427)
    # Behavioral assertion: an org-a assess-priority invocation must return zero org-b/c rows.
    # Requires the prism-demo-bundle DTU to be downloaded and wired into CI.
    # STATIC portion (WHERE org_slug= presence) is verified by the three tests above.
    skip "prism-demo-bundle DTU download pending (pre-W2); behavioral multi-org fixture not yet wired into CI"
}

@test "BC_4_05_001 MEDIUM-4 ADV-F4-S4.02 PC7 EC-009: degraded-mode documents uncertainty_explicit and prism-unavailable path" {
    # MEDIUM-4 (BC-4.05.001 v1.5 PC#7 / EC-009 / ADV-F4-S4.02)
    # REPLACES the previous negative stub-absent check with a POSITIVE assertion.
    # Degraded mode (Prism MCP unavailable — distinct from org_slug missing) MUST:
    #   1. Skip all Prism-grounded stages (PC#5a..PC#5e)
    #   2. Map 6-factor base score to {CRIT,HIGH,MED,LOW} via PC#6 band thresholds
    #   3. Set uncertainty_explicit: true (BC-4.05.001 v1.5 PC#7 explicit requirement)
    # Positive assertion: deleting the fallback lines must make THIS test fail, not just a stub check.
    # Current SKILL.md covers org_slug fallback only; 'uncertainty_explicit' absent entirely.
    # Red Gate: 'uncertainty_explicit' not in SKILL.md → grep fails → RED.
    grep -qF 'uncertainty_explicit' "$SKILL"
}

# ── AC-009 / VP-SKILL-071 ────────────────────────────────────────────────────
# BC-4.05.001 v1.5 PC#6 / D-DEC-011
# confidence_score float output paired with confidence enum must match D-DEC-011 thresholds:
#   high   iff score >= 0.75  (boundary: 0.75 → high,   0.749 → medium)
#   medium iff 0.40 <= score < 0.75  (boundary: 0.40 → medium, 0.399 → low)
#   low    iff score < 0.40
# Inconsistent pair (e.g. score=0.80 with confidence="low") is invalid.

@test "BC_4_05_001 AC-009 VP-SKILL-071: >= 0.75 binds to high with boundary vector 0.749 documented" {
    # MEDIUM-2 augmentation (BC-4.05.001 v1.5 PC#6 / VP-SKILL-071 / D-DEC-011)
    # Replaces weak literal-presence check with association + catalog boundary vector assertion.
    # D-DEC-011: high iff confidence_score >= 0.75; the just-below boundary 0.749 maps to medium
    # and MUST be explicitly documented alongside the threshold for implementer clarity.
    # Both the threshold value (>= 0.75) AND the boundary vector (0.749) must appear in SKILL.md.
    # OBS-4 (ADV-F4-S4.02 pass-3): arrow-agnostic binding pattern — an editor normalizing U+2192
    # to ASCII '->' must not flip the test RED with no semantic change. Uses [^0-9]+ to match any
    # separator (→, ->, →, whitespace + separator) between the value and the tier name.
    # Red Gate: '0.749' absent from SKILL.md (boundary not documented) → second grep fails → RED.
    grep -qF '>= 0.75' "$SKILL"
    grep -qF '0.749' "$SKILL"
    grep -qE '0\.749[^0-9]+medium' "$SKILL"
    ! grep -qE '0\.749[^0-9]+high' "$SKILL"
}

@test "BC_4_05_001 AC-009 VP-SKILL-071: >= 0.40 binds to medium with boundary vector 0.399 documented" {
    # MEDIUM-2 augmentation (BC-4.05.001 v1.5 PC#6 / VP-SKILL-071 / D-DEC-011)
    # Replaces weak literal-presence check with association + catalog boundary vector assertion.
    # D-DEC-011: medium iff 0.40 <= score < 0.75; the just-below boundary 0.399 maps to low
    # and MUST be explicitly documented alongside the threshold for implementer clarity.
    # Both the threshold value (>= 0.40) AND the boundary vector (0.399) must appear in SKILL.md.
    # OBS-4 (ADV-F4-S4.02 pass-3): arrow-agnostic binding pattern — an editor normalizing U+2192
    # to ASCII '->' must not flip the test RED with no semantic change. Uses [^0-9]+ to match any
    # separator (→, ->, →, whitespace + separator) between the value and the tier name.
    # Red Gate: '0.399' absent from SKILL.md (boundary not documented) → second grep fails → RED.
    grep -qF '>= 0.40' "$SKILL"
    grep -qF '0.399' "$SKILL"
    grep -qE '0\.399[^0-9]+low' "$SKILL"
    ! grep -qE '0\.399[^0-9]+medium' "$SKILL"
}

@test "BC_4_05_001 AC-009 VP-SKILL-071: confidence threshold placeholder stub is removed" {
    # VP-SKILL-071 (traces to BC-4.05.001 v1.5 PC#6, D-DEC-011, vd:428)
    # The NOT-IMPLEMENTED-STUB comment marking thresholds as placeholders must be absent
    # once the correct 0.75/0.40 boundary values are applied.
    # Red Gate: stub has placeholder comment → ! assertion fails → FAILS.
    ! grep -qF "NOT-IMPLEMENTED-STUB: thresholds are placeholders" "$SKILL"
}

@test "BC_4_05_001 AC-009 VP-SKILL-071: inconsistent confidence pair is documented as invalid" {
    # VP-SKILL-071 (traces to BC-4.05.001 v1.5 PC#6, D-DEC-011, vd:428)
    # An inconsistent pair (e.g. confidence_score=0.80 with confidence='low') is invalid.
    # SKILL.md must document this rejection behavior.
    # Red Gate: stub has no mention of inconsistent pairs → grep fails → FAILS.
    grep -qiE "inconsistent.*(confidence|pair)" "$SKILL"
}

# ── MEDIUM-2 / VP-SKILL-071 — tier-inversion guard ──────────────────────────
# BC-4.05.001 v1.5 PC#6 / VP-SKILL-071 / D-DEC-011 / ADV-F4-S4.02
# If 0.75 were remapped to 'low' (tier inversion), the weak literal-presence tests above
# would still pass; this guard catches the regression.

@test "BC_4_05_001 MEDIUM-2 VP-SKILL-071: 0.75 binds to high tier — tier-inversion mutant guard" {
    # MEDIUM-2 (BC-4.05.001 v1.5 VP-SKILL-071 / D-DEC-011 / ADV-F4-S4.02 — tier-inversion guard)
    # Augments AC-009: not just literal presence of '>= 0.75' but correct binding to 'high'.
    # A tier-inversion mutant SKILL.md that writes '>= 0.75 | low' passes the literal-presence
    # test but fails here — making the inversion detectable.
    # Current SKILL.md: '| >= 0.75 | high |' is correct → PASSES (green guard, not a red test).
    grep -qE '>= 0.75[[:space:]]*\|[[:space:]]*high' "$SKILL"
    ! grep -qE '>= 0.75[[:space:]]*\|[[:space:]]*(low|medium)' "$SKILL"
}

@test "BC_4_05_001 F2-ADV-F4-S4.02 VP-SKILL-071: 0.40 binds to medium tier — medium-tier inversion mutant guard" {
    # F2 MEDIUM (BC-4.05.001 v1.6 PC#6 / VP-SKILL-071 / D-DEC-011 / ADV-F4-S4.02-F2)
    # Symmetric to the 0.75/high guard above: not just literal presence of '>= 0.40' but correct
    # binding to 'medium'. A medium→low inversion mutant SKILL.md that writes '>= 0.40 | low'
    # passes the literal-presence test in AC-009 ('>= 0.40' found) but fails here.
    # D-DEC-011: medium iff 0.40 <= confidence_score < 0.75.
    # Positive: '>= 0.40' row must bind to 'medium' in the confidence table.
    # Negative: '>= 0.40' row must NOT bind to 'low' or 'high'.
    # Current SKILL.md: '| >= 0.40 and < 0.75 | medium |' is correct → PASSES
    # (green guard-strengthening test; goal is mutant-resistance, not requiring red).
    grep -qE '>= 0.40[^|]*\|[[:space:]]*medium' "$SKILL"
    ! grep -qE '>= 0.40[^|]*\|[[:space:]]*(low|high)' "$SKILL"
}

@test "BC_4_05_001 MEDIUM-1-ADV-F4-S4.02-pass3 VP-SKILL-071: < 0.40 binds to low tier — low-tier inversion mutant guard" {
    # MEDIUM-1 (BC-4.05.001 v1.6 PC#6 / VP-SKILL-071 / D-DEC-011 / ADV-F4-S4.02 pass-3 MEDIUM-1)
    # Symmetric guard for the low tier: D-DEC-011 defines low as confidence_score < 0.40.
    # The high and medium tiers each have an inversion guard (tests above); the low tier had none.
    # This adds the missing symmetric guard to close the mutant-resistance gap.
    # A mutant that rebinds '< 0.40' to 'high' or 'medium' passes all literal-presence tests above
    # but fails the positive assertion here (< 0.40 row must bind to 'low') and the negative guard.
    # Current SKILL.md: '| < 0.40 | low |' is correct → PASSES
    # (green guard-strengthening test; goal is mutant-resistance, not requiring red).
    grep -qE '< 0\.40[[:space:]]*\|[[:space:]]*low' "$SKILL"
    ! grep -qE '< 0\.40[[:space:]]*\|[[:space:]]*(high|medium)' "$SKILL"
}

@test "BC_4_05_001 MINOR-2-ADV-F4-S4.02-pass3 PC3 EC-007: Override +1/-1 adjustments must clamp at CRIT ceiling and LOW floor" {
    # MINOR-2 (BC-4.05.001 PC#3 / EC-007 / ADV-F4-S4.02 pass-3 MINOR-2)
    # BC-4.05.001 PC#3 defines Override Rules (+1/−1 level adjustments to scored_priority).
    # Without an explicit clamp, a +1 on CRIT could overflow to a non-enum token, and a −1 on LOW
    # could underflow — both violate Invariant 5 (scored_priority always in {CRIT,HIGH,MED,LOW}).
    # SKILL.md Override Rules section must document that +1 is clamped at CRIT (ceiling) and
    # −1 is clamped at LOW (floor) so that scored_priority is always a valid enum member.
    # Red Gate: SKILL.md does not currently document clamp behaviour → grep fails → RED.
    # The implementer will add clamp text to the Override Rules section.
    grep -m 1 -A 10 "### Override Rules" "$SKILL" | grep -qiE 'clamp|ceiling|floor|stays CRIT|stays LOW|cannot.*exceed|max.*CRIT|min.*LOW'
}

# ── MAJOR-1 / ADV-F4-S4.02 — degraded-mode scored_priority enum alignment ───
# BC-4.05.001 v1.5 PC#7 / Invariant 5 / EC-009
# Degraded mode (Prism MCP unavailable) must map 6-factor base score to {CRIT,HIGH,MED,LOW}
# via PC#6 band thresholds. P1-P5 are INTERNAL-ONLY and NEVER emitted as scored_priority.
# Current SKILL.md (HEAD 51c6b67): Priority Mapping still uses P1-P5 labels as the primary
# output; no CRIT/HIGH/MED/LOW in the Priority Mapping section; no P1-P5 internal-only decl.

@test "BC_4_05_001 MAJOR-1 ADV-F4-S4.02 BC-v1.5-PC7: degraded mode maps base score to CRIT/HIGH/MED/LOW enum" {
    # MAJOR-1 (BC-4.05.001 v1.5 PC#7 / Postcondition #7 / EC-009 / ADV-F4-S4.02)
    # The degraded-mode section MUST state on the same line that the base score maps to
    # {CRIT, HIGH, MED, LOW} — i.e., 'CRIT' must appear in close textual proximity to
    # 'degraded' or 'unavailable'. P1-P5 labels are INTERNAL-ONLY per BC v1.5.
    # Current SKILL.md degraded section: 'proceed using only the 6-factor base score' — no enum.
    # Red Gate: no line has both 'degraded'/'unavailable' and 'CRIT'/'scored_priority'/'enum' → RED.
    grep -qiE "degraded.*(CRIT|scored_priority|enum)|CRIT.*(degraded|unavailable)" "$SKILL"
}

@test "BC_4_05_001 MAJOR-1 ADV-F4-S4.02 BC-v1.5-PC6: Priority Mapping section must use CRIT/HIGH/MED/LOW not P1-P5" {
    # MAJOR-1 (BC-4.05.001 v1.5 PC#6 / Invariant 5 / ADV-F4-S4.02)
    # The Priority Mapping table is the core scored_priority derivation; it must use the
    # canonical enum values CRIT/HIGH/MED/LOW, not the internal P1-P5 intermediate labels.
    # 'CRIT' must appear within the '### Priority Mapping' section (12 lines).
    # Current SKILL.md: Priority Mapping has only P1-P5 labels — 'CRIT' absent → RED.
    grep -m 1 -A 12 "### Priority Mapping" "$SKILL" | grep -qF 'CRIT'
}

@test "BC_4_05_001 MAJOR-1 ADV-F4-S4.02 BC-v1.5-Inv5: P1-P5 labels declared INTERNAL-ONLY in SKILL.md" {
    # MAJOR-1 (BC-4.05.001 v1.5 Invariant 5 / ADV-F4-S4.02)
    # BC v1.5 Invariant 5: 'P1-P5 labels are INTERNAL-ONLY — they are the skill's intermediate
    # 6-factor priority table notation and are never emitted as the scored_priority field value.'
    # SKILL.md must carry this declaration explicitly so implementers do not emit P1-P5 as output.
    # Current SKILL.md: P1-P5 are the primary output labels; 'internal-only' never stated → RED.
    grep -qiE 'P[1-5].*internal.?only|internal.?only.*P[1-5]' "$SKILL"
}

# ── MEDIUM-3 / ADV-F4-S4.02 — PC#6 band thresholds ──────────────────────────
# BC-4.05.001 v1.5 PC#6 / Postcondition #6 / §Description
# Canonical PC#6 band map: CRIT >=20 or KEV; HIGH 14-19 (7d); MED 8-13 (30d); LOW <8 (90d)
# Current SKILL.md (HEAD 51c6b67): HIGH band is '15-19' (wrong), MED spans '10-14'+'6-9' (wrong).

@test "BC_4_05_001 MEDIUM-3 ADV-F4-S4.02 BC-v1.5-PC6: PC#6 HIGH band threshold is 14-19 (not 15-19)" {
    # MEDIUM-3 (BC-4.05.001 v1.5 PC#6 band thresholds / ADV-F4-S4.02)
    # BC v1.5: HIGH band is score 14-19 (7-day SLA). Current SKILL.md documents '15-19' (wrong
    # lower bound — off by one). The implementer using '15-19' would mis-score a base score of 14
    # as MED instead of HIGH, producing an incorrect SLA assignment.
    # Red Gate: '14-19' absent from SKILL.md (has '15-19') → grep fails → RED.
    grep -qF '14-19' "$SKILL"
}

@test "BC_4_05_001 MEDIUM-3 ADV-F4-S4.02 BC-v1.5-PC6: PC#6 MED band threshold is 8-13 (not 10-14 or 6-9)" {
    # MEDIUM-3 (BC-4.05.001 v1.5 PC#6 band thresholds / ADV-F4-S4.02)
    # BC v1.5: MED band is score 8-13 (30-day SLA). Current SKILL.md splits this into
    # '10-14' (P3-Medium) and '6-9' (P4-Low), which diverges from the unified BC v1.5 range
    # and misclassifies scores 8-9 (should be MED) as P4-Low.
    # Red Gate: '8-13' absent from SKILL.md → grep fails → RED.
    grep -qF '8-13' "$SKILL"
}

# ── MEDIUM-5 / ADV-F4-S4.02 — AC-007 contamination breadth ──────────────────
# BC-4.05.001 v1.5 Invariant 5
# scored_priority must NEVER contain CRITICAL or MEDIUM in ANY output position,
# not just in the SEVERITY_TO_SCORED_PRIORITY_MAP self-map rows (existing AC-007 scope).
# Current SKILL.md: Priority Mapping has '| P1 - Critical |' and '| P3 - Medium |' as output
# labels — SEVERITY_ENUM-adjacent strings in the scored_priority output position.

@test "BC_4_05_001 MEDIUM-5 ADV-F4-S4.02 AC-007: no Critical/Medium label in any Priority Mapping output position" {
    # MEDIUM-5 (BC-4.05.001 v1.5 Invariant 5 / ADV-F4-S4.02 — contamination breadth)
    # Broadens AC-007: existing tests only check for exact '| CRITICAL | CRITICAL |' self-map rows.
    # This test catches contamination in ANY table output column — including Priority Mapping rows
    # where P1-P5 labels carry 'Critical'/'Medium' substrings (e.g. 'P1 - Critical', 'P3 - Medium').
    # BC v1.5: any non-member token (CRITICAL, MEDIUM, P1-P5) in scored_priority → SEVERITY-MISMATCH DENY.
    # Red Gate: '| P1 - Critical |' and '| P3 - Medium |' present in SKILL.md → ! grep fails → RED.
    ! grep -qiE '\| P[1-9][^|]*(Critical|Medium)\b' "$SKILL"
}

# ── F6 / ADV-F4-S4.02 — output JSON schema completeness ──────────────────────
# BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02-F6
# The SKILL.md output JSON example is the implementer's reference schema for the verdict JSON.
# BC v1.6 PC#6 canonical output: scored_priority, confidence_score, confidence, disposition,
# rationale, base_score, prism_enriched, uncertainty_explicit.
# Current SKILL.md JSON example is a 3-field subset: scored_priority, confidence_score, confidence.
# Missing fields leave the implementer without the full schema contract, risking incomplete output.

@test "BC_4_05_001 F6-ADV-F4-S4.02 BC-v1.6-PC6: output JSON example must include all PC#6 canonical fields" {
    # F6 MINOR (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02-F6)
    # The SKILL.md output JSON example must document all 8 BC v1.6 PC#6 canonical fields so the
    # implementer has a complete, copy-paste-ready schema reference.
    # Assertions use quoted JSON key strings ('"field"') to match JSON example context specifically
    # and avoid spurious matches in surrounding prose.
    # Fields present in current SKILL.md JSON example: scored_priority, confidence_score, confidence.
    # Fields absent (all → RED):
    #   '"disposition"'      — TP|FP|BTP|Indeterminate Bayesian estimate
    #   '"rationale"'        — explanation of base score + recalibration + overrides
    #   '"base_score"'       — numeric 0-24 score before PC#6 band mapping
    #   '"prism_enriched"'   — boolean flag distinguishing prism-grounded from degraded mode
    #   '"uncertainty_explicit"' — required true in degraded mode (PC#7 / EC-009)
    # Red Gate: '"disposition"' absent from SKILL.md JSON example → first missing-field grep fails → RED.
    grep -qF '"scored_priority"' "$SKILL"
    grep -qF '"confidence_score"' "$SKILL"
    grep -qF '"confidence"' "$SKILL"
    grep -qF '"disposition"' "$SKILL"
    grep -qF '"rationale"' "$SKILL"
    grep -qF '"base_score"' "$SKILL"
    grep -qF '"prism_enriched"' "$SKILL"
    grep -qF '"uncertainty_explicit"' "$SKILL"
}

#!/usr/bin/env bats
# tests/skills/assess-priority-coherence.bats
# S-4.02: assess-priority scored_priority Producer/Consumer Coherence (BC-4.05.001 v1.4)
#
# Covers: AC-001..AC-009 (all story acceptance criteria)
# New delta VPs:
#   VP-SKILL-070 — PrismQL org_slug scoping (AC-008)
#   VP-SKILL-071 — confidence float→enum consistency, D-DEC-011 (AC-009)
#
# Regression VPs VP-SKILL-029..034 are already covered by skills.bats and are
# NOT duplicated here per Architecture Context Discipline (DF-021).
#
# Red Gate: ALL non-SKIP tests MUST FAIL against the current stub
# (plugins/secops-factory/skills/assess-priority/SKILL.md — commit 0b13653).
# Intentionally-wrong stub values: CRITICAL→CRITICAL, MEDIUM→MEDIUM, thresholds
# 0.80/0.50, PrismQL blocks missing org_slug WHERE clause.

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."
SKILL="${PLUGIN_ROOT}/skills/assess-priority/SKILL.md"

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
    # Red Gate: stub PC#5a SQL has 'WHERE rule_id=...' with no org_slug → grep -q fails → FAILS.
    grep -m 1 -A 20 "PC#5a" "$SKILL" | grep -q "WHERE org_slug="
}

@test "BC_4_05_001 AC-008 VP-SKILL-070: PC#5b NVD enrichment SQL includes WHERE org_slug= clause" {
    # VP-SKILL-070 static leg (traces to BC-4.05.001 Invariant 4, D-DEC-005, vd:427)
    # PC#5b enrich_nvd() query must include an explicit org_slug WHERE clause per BC-4.05.001 VP.
    # Red Gate: stub PC#5b has 'SELECT enrich_nvd(...)' with no WHERE clause → grep -q fails → FAILS.
    grep -m 1 -A 10 "PC#5b" "$SKILL" | grep -q "WHERE org_slug="
}

@test "BC_4_05_001 AC-008 VP-SKILL-070: PC#5d asset criticality SQL includes WHERE org_slug= clause" {
    # VP-SKILL-070 static leg (traces to BC-4.05.001 Invariant 4, D-DEC-005, vd:427)
    # PC#5d assets query must have an explicit org_slug constraint in the WHERE clause.
    # Red Gate: stub PC#5d SQL has 'WHERE asset_id=...' with no org_slug → grep -q fails → FAILS.
    grep -m 1 -A 15 "PC#5d" "$SKILL" | grep -q "WHERE org_slug="
}

@test "BC_4_05_001 AC-008 VP-SKILL-070: at least two PrismQL queries carry WHERE org_slug= clause" {
    # VP-SKILL-070 static leg — aggregate count (traces to BC-4.05.001 Invariant 4, D-DEC-005)
    # Minimum two queries must include org_slug (PC#5a + PC#5d; PC#5b adds a third).
    # Red Gate: stub has 0 queries with org_slug → count=0 → [ 0 -ge 2 ] FAILS.
    count=$(grep -c "WHERE org_slug=" "$SKILL" || true)
    [ "$count" -ge 2 ]
}

@test "BC_4_05_001 AC-008 VP-SKILL-070 DTU-SKIP: org-a query returns zero org-b/c rows (multi-org DTU fixture)" {
    # VP-SKILL-070 behavioral leg (traces to BC-4.05.001 Invariant 4, D-DEC-005, vd:427)
    # Behavioral assertion: an org-a assess-priority invocation must return zero org-b/c rows.
    # Requires the prism-demo-bundle DTU to be downloaded and wired into CI.
    # STATIC portion (WHERE org_slug= presence) is verified by the three tests above.
    skip "prism-demo-bundle DTU download pending (pre-W2); behavioral multi-org fixture not yet wired into CI"
}

@test "BC_4_05_001 AC-008 VP-SKILL-070: org_slug unavailability falls back to degraded mode (adversarial)" {
    # VP-SKILL-070 adversarial leg (traces to BC-4.05.001 Invariant 4 — unscoped query rejected)
    # If org_slug is not available from execution context, ALL prism-grounded scoring stages
    # must be skipped entirely (BC-4.05.001 Invariant #4). SKILL.md must document this fallback.
    # Red Gate: stub has NOT-IMPLEMENTED-STUB for the whole Stage 5 section → comment present →
    #   ! assertion fails → FAILS.
    ! grep -qF "NOT-IMPLEMENTED-STUB: prism availability check and org_slug scoping not yet implemented" "$SKILL"
}

# ── AC-009 / VP-SKILL-071 ────────────────────────────────────────────────────
# BC-4.05.001 PC#6 / D-DEC-011
# confidence_score float output paired with confidence enum must match D-DEC-011 thresholds:
#   high  iff score >= 0.75   (boundary: 0.75 → high, 0.749 → medium)
#   medium iff 0.40 <= score < 0.75  (boundary: 0.40 → medium, 0.399 → low)
#   low   iff score < 0.40
# Inconsistent pair (e.g. score=0.80 with confidence="low") is invalid.

@test "BC_4_05_001 AC-009 VP-SKILL-071: high/medium boundary threshold is 0.75 per D-DEC-011 (not 0.80)" {
    # VP-SKILL-071 boundary vector: confidence_score >= 0.75 → 'high'; 0.749 → 'medium'.
    # D-DEC-011 canonical threshold for high is 0.75 — not 0.80.
    # Red Gate: stub has '>= 0.80' for high; '>= 0.75' is absent → FAILS.
    grep -qF '>= 0.75' "$SKILL"
}

@test "BC_4_05_001 AC-009 VP-SKILL-071: medium/low boundary threshold is 0.40 per D-DEC-011 (not 0.50)" {
    # VP-SKILL-071 boundary vector: confidence_score >= 0.40 → 'medium'; 0.399 → 'low'.
    # D-DEC-011 canonical threshold for medium is 0.40 — not 0.50.
    # Red Gate: stub has '>= 0.50' for medium; '>= 0.40' is absent → FAILS.
    grep -qF '>= 0.40' "$SKILL"
}

@test "BC_4_05_001 AC-009 VP-SKILL-071: confidence threshold placeholder stub is removed" {
    # VP-SKILL-071 (traces to BC-4.05.001 PC#6, D-DEC-011, vd:428)
    # The NOT-IMPLEMENTED-STUB comment marking thresholds as placeholders must be absent
    # once the correct 0.75/0.40 boundary values are applied.
    # Red Gate: stub has placeholder comment → ! assertion fails → FAILS.
    ! grep -qF "NOT-IMPLEMENTED-STUB: thresholds are placeholders" "$SKILL"
}

@test "BC_4_05_001 AC-009 VP-SKILL-071: inconsistent confidence pair is documented as invalid" {
    # VP-SKILL-071 (traces to BC-4.05.001 PC#6, D-DEC-011, vd:428)
    # An inconsistent pair (e.g. confidence_score=0.80 with confidence='low') is invalid.
    # SKILL.md must document this rejection behavior.
    # Red Gate: stub has no mention of inconsistent pairs → grep fails → FAILS.
    grep -qiE "inconsistent.*(confidence|pair)" "$SKILL"
}

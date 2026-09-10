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
#
# ADV-F4-S4.02 findings addressed in pass-4 (this file):
#   MAJOR-1   — data-file coherence: priority-framework.md band boundaries and score range
#               must match BC-4.05.001 v1.6 PC#6 (HIGH=14-19, MED=8-13, range 0-24).
#               P1-P5 must be declared INTERNAL-ONLY; Score to Priority Mapping must emit
#               CRIT/HIGH/MED/LOW not P1-P5. RED (data file still has 15-19/10-14/6-9/6-24).
#   MEDIUM-2  — VP-SKILL-070 leg (c) guard: SKILL.md org_slug-missing degraded skip must document
#               that ALL PC#5a-PC#5e are skipped when org_slug is unavailable.
#               GREEN: SKILL.md line ~142 already contains the required text. Guard protects it.
#   MINOR-4   — JSON example coherence: confidence_score must not use literal 0.0 (incoherent
#               with high tier); degraded-mode section must document prism_enriched: false.
#               RED (SKILL.md has "confidence_score": 0.0 and no prism_enriched: false).
#   MEDIUM-3  — Pre-authorized DTU deferral: updated skip annotation on DTU behavioral test to
#               clearly mark VP-SKILL-070 behavioral multi-org leg as PRE-AUTHORIZED xfail pending
#               the prism-demo-bundle DTU (dtu_clones_built: pending; pre-W2 wave-gate tracking).
#
# Red Gate status after pass-4 additions:
#   GREEN (guard, already correct):  MEDIUM-2 org_slug-missing ALL-PC5a-5e skip guard
#   RED   (data-file fix required):  MAJOR-1 data-file coherence (×5 tests)
#   RED   (SKILL.md fix required):   MINOR-4 JSON confidence placeholder + prism_enriched false (×2)
#   SKIP  (pre-authorized):          MEDIUM-3 DTU behavioral multi-org test
#
# ADV-F4-S4.02 findings addressed in pass-8 (this file):
#   MINOR-1  — missing-org_slug degraded paragraph (~SKILL.md:142) omits the output contract
#               required by BC-4.05.001 v1.6 Invariant #4 / PC#7: (1) map the base score to
#               {CRIT,HIGH,MED,LOW} via PC#6 band thresholds, and (2) set prism_enriched: false
#               + uncertainty_explicit: true. The parallel "Degraded mode (Prism MCP unavailable)"
#               paragraph (~SKILL.md:144) already carries both clauses; the missing-org_slug
#               paragraph does not.
#               RED (SKILL.md line ~142 has neither clause; ×3 assertions in one test).
#
# Red Gate status after pass-8 additions:
#   RED   (SKILL.md fix required):  MINOR-1 missing-org_slug output contract (×3 assertions)
#   SKIP  (pre-authorized):          MEDIUM-3 DTU behavioral multi-org test (unchanged)
#
# ADV-F4-S4.02 findings addressed in pass-5 (this file):
#   F1 MAJOR  — priority-framework.md P-section prose carries stale score thresholds
#               (P3: 10-14; P4: 6-9; P5: 0-5) and stale SLA/label semantics
#               (P4: Low/90-day should be MED/30-day; P5: Informational/No-SLA should be LOW/90-day).
#               The existing pass-4 tests anchor negative checks to the "Score to Priority Mapping"
#               window (grep -A 12) so stale P-section prose at lines ~39-55 escapes detection.
#               Whole-file negative assertions added. RED (×5).
#   F2 MEDIUM — priority-framework.md Factor 3 Override Rule says "minimum P2" (line ~88).
#               BC-4.05.001 v1.6: KEV Listed → CRIT unconditional. "minimum P2" language contradicts
#               the unconditional KEV→CRIT mapping in both the BC and (already-correct) mapping table.
#               Whole-file negative + positive CRIT guard added. RED (×2).
#   F2-sibling — kev-catalog-guide.md (SKILL.md:89 reference) states "Minimum P1 or P2" (line ~59)
#               and "minimum_priority = P2" (line ~104). Both contradict BC v1.6 KEV→CRIT
#               unconditional. Three guards (×2 negative + ×1 positive CRIT). RED (×3).
#   F3 OBS    — All new negative assertions scan the ENTIRE data file, not a grep -A N window,
#               so stale prose relocated to any section still fails CI.
#
# Red Gate status after pass-5 additions:
#   RED   (data-file fix required):  F1 P-section stale thresholds (×5)
#   RED   (data-file fix required):  F2 KEV override min-P2 + missing CRIT (×2)
#   RED   (data-file fix required):  F2-sibling kev-catalog-guide stale language (×3)
#   SKIP  (pre-authorized):          MEDIUM-3 DTU behavioral multi-org test (unchanged)

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."
SKILL="${PLUGIN_ROOT}/skills/assess-priority/SKILL.md"
DATA="${PLUGIN_ROOT}/data/priority-framework.md"
KEV_DATA="${PLUGIN_ROOT}/data/kev-catalog-guide.md"

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
    #
    # MEDIUM-3 / ADV-F4-S4.02 pass-4 — PRE-AUTHORIZED DEFERRAL:
    # VP-SKILL-070 leg (b) behavioral multi-org fixture is xfail per wave-gate decision recorded in
    # ADV-F4-S4.02-MEDIUM-3. dtu_clones_built: pending. This skip is explicitly authorized as a
    # pre-W2 wave-gate tracking item and must NOT be unskipped until:
    #   (a) prism-demo-bundle DTU bundle is downloaded and unpacked to the test fixtures directory,
    #   (b) CI harness is wired to the DTU fixture path, AND
    #   (c) the wave-gate tracking item is closed (pre-W2).
    # Do NOT remove this skip to make a green suite — re-enable only after the DTU is fully wired.
    skip "[PRE-AUTHORIZED DEFERRAL — MEDIUM-3/ADV-F4-S4.02] VP-SKILL-070 behavioral multi-org leg is xfail pending prism-demo-bundle DTU (dtu_clones_built: pending; pre-W2 wave-gate tracking item)"
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

# ── MAJOR-1 / ADV-F4-S4.02 pass-4 — data-file coherence ─────────────────────
# BC-4.05.001 v1.6 PC#6 / Invariant #5 / ADV-F4-S4.02-MAJOR-1
# SKILL.md:86 cites plugins/secops-factory/data/priority-framework.md as its scoring reference.
# That data file documents stale band thresholds (HIGH=15-19, MED split into 10-14+6-9),
# a wrong score range (6-24 vs 0-24), and presents P1-P5 as the emitted priority with no
# INTERNAL-ONLY caveat. An implementer reading the data file would produce incorrect scored_priority
# outputs. These tests guard the data file directly so stale data-file content fails CI.
# All five tests are RED until the data file is updated to match BC-4.05.001 v1.6 PC#6.

@test "BC_4_05_001 MAJOR-1-pass4 ADV-F4-S4.02 data-file BC-v1.6-PC6: priority-framework.md HIGH band boundary is 14-19 not 15-19" {
    # MAJOR-1 (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-4)
    # BC v1.6 PC#6: HIGH band = score 14-19 (7-day SLA). priority-framework.md currently documents
    # '15-19' (wrong lower bound — off by one). An implementer reading this data file mis-scores
    # base_score=14 as MED (30d SLA) instead of HIGH (7d SLA): a 23-day SLA miss on a genuine
    # HIGH-priority CVE.
    # Positive: '14-19' must be present in the data file.
    # Negative: '15-19' must NOT be present (stale wrong boundary fully replaced).
    # Red Gate: data file has '15-19' and no '14-19' → positive grep fails → RED.
    grep -qF '14-19' "$DATA"
    ! grep -qF '15-19' "$DATA"
}

@test "BC_4_05_001 MAJOR-1-pass4 ADV-F4-S4.02 data-file BC-v1.6-PC6: priority-framework.md MED band boundary is 8-13" {
    # MAJOR-1 (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-4)
    # BC v1.6 PC#6: MED band = score 8-13 (30-day SLA). priority-framework.md currently splits
    # this as '10-14' (P3-Medium) and '6-9' (P4-Low) — two wrong ranges that mis-classify
    # base_score 8-9 (should be MED/30d) as LOW/90d SLA.
    # Anchored to the "Score to Priority Mapping" heading (12 context lines) so P3/P4 section
    # headers carrying the old thresholds as prose do not independently satisfy or break the test.
    # Positive: '8-13' must appear in the mapping table.
    # Negative: '10-14' and '6-9' must NOT appear in the mapping table.
    # Red Gate: mapping has '10-14' and '6-9' but no '8-13' → positive grep fails → RED.
    grep -m 1 -A 12 "Score to Priority Mapping" "$DATA" | grep -qF '8-13'
    ! grep -m 1 -A 12 "Score to Priority Mapping" "$DATA" | grep -qF '10-14'
    ! grep -m 1 -A 12 "Score to Priority Mapping" "$DATA" | grep -qF '6-9'
}

@test "BC_4_05_001 MAJOR-1-pass4 ADV-F4-S4.02 data-file BC-v1.6-PC6: priority-framework.md score range is 0-24 not 6-24" {
    # MAJOR-1 (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-4)
    # BC v1.6 PC#6: score range 0-24. priority-framework.md currently states 'Score Range: 6-24
    # points' which is wrong — the minimum achievable score is 0 (no factors applicable) not 6.
    # Positive: '0-24' must be present.
    # Negative: '6-24' must NOT be present (stale wrong range fully replaced).
    # Red Gate: data file has '6-24' and no '0-24' → positive grep fails → RED.
    grep -qF '0-24' "$DATA"
    ! grep -qF '6-24' "$DATA"
}

@test "BC_4_05_001 MAJOR-1-pass4 ADV-F4-S4.02 data-file BC-v1.6-Inv5: priority-framework.md P1-P5 must be declared INTERNAL-ONLY" {
    # MAJOR-1 (BC-4.05.001 v1.6 Invariant #5 / ADV-F4-S4.02 pass-4)
    # BC v1.6 Invariant #5: P1-P5 are INTERNAL-ONLY intermediate labels; the emitted scored_priority
    # is always from {CRIT, HIGH, MED, LOW}. priority-framework.md is cited by SKILL.md:86 as the
    # reference; an implementer reading this file must not be misled into emitting P1-P5 as the
    # scored_priority output value. The file must carry an explicit INTERNAL-ONLY declaration so the
    # enum mapping (P1→CRIT, P2→HIGH, P3→MED, P4→MED, P5→LOW) is unambiguous.
    # Red Gate: 'INTERNAL-ONLY' (case-insensitive) absent from data file → grep fails → RED.
    grep -qiE 'INTERNAL.?ONLY' "$DATA"
}

@test "BC_4_05_001 MAJOR-1-pass4 ADV-F4-S4.02 data-file BC-v1.6-Inv5: Score to Priority Mapping must emit CRIT not P1" {
    # MAJOR-1 (BC-4.05.001 v1.6 Invariant #5 / ADV-F4-S4.02 pass-4)
    # BC v1.6 Invariant #5: scored_priority is always a member of {CRIT, HIGH, MED, LOW}.
    # The Score to Priority Mapping table in priority-framework.md currently uses P1-P5 in the
    # output (Priority) column — an implementer copying this table would emit P1 not CRIT,
    # breaking every consumer reading verdict.scored_priority (ICD-203 field 18).
    # Positive: 'CRIT' must appear in the Score to Priority Mapping section (12 context lines).
    # Negative: '| P1 |' must NOT appear in the mapping table output column (replaced by CRIT).
    # Red Gate: mapping has '| P1 |' and no 'CRIT' → positive grep fails → RED.
    grep -m 1 -A 12 "Score to Priority Mapping" "$DATA" | grep -qF 'CRIT'
    ! grep -m 1 -A 12 "Score to Priority Mapping" "$DATA" | grep -qF '| P1 |'
}

# ── MEDIUM-2 / ADV-F4-S4.02 pass-4 — VP-SKILL-070 org_slug-missing degraded skip guard ──
# BC-4.05.001 v1.6 PC#5 / VP-SKILL-070 / ADV-F4-S4.02-MEDIUM-2
# SKILL.md must document that when org_slug is unavailable ALL PC#5a-PC#5e stages are skipped.
# This test is a GREEN guard: the text already exists at SKILL.md:~142; the guard ensures
# deleting that line fails CI — protecting VP-SKILL-070 leg (c).

@test "BC_4_05_001 MEDIUM-2-pass4 ADV-F4-S4.02 VP-SKILL-070 PC5: SKILL.md documents ALL PC5a-PC5e skipped when org_slug unavailable" {
    # MEDIUM-2 (BC-4.05.001 v1.6 PC#5 / VP-SKILL-070 / ADV-F4-S4.02 pass-4 MEDIUM-2)
    # VP-SKILL-070 leg (c) guard: SKILL.md must document that when org_slug is not available
    # from execution context, ALL Prism-grounded scoring stages (PC#5a through PC#5e) MUST be
    # skipped entirely. This is the spec-in-code for the degraded-without-org_slug path; deleting
    # it removes the implementer's authoritative instruction for this code path.
    # Two-clause guard:
    #   (1) org_slug unavailable / missing / not in context must be documented.
    #   (2) ALL PC#5a through PC#5e must be documented as skipped for that case.
    # Deleting either clause from SKILL.md line ~142 fails the corresponding assertion.
    # GREEN: SKILL.md line ~142 already contains both clauses → guard (not red test).
    grep -qiE 'org_slug.*(unavailable|not in context|missing)' "$SKILL"
    grep -qiE 'ALL.*Prism.*scoring.*stages.*(MUST.*skip|skip)|PC.?5a.*PC.?5e.*MUST.*skip' "$SKILL"
}

# ── MINOR-4 / ADV-F4-S4.02 pass-4 — JSON example coherence ──────────────────
# BC-4.05.001 v1.6 PC#6 / VP-SKILL-071 / PC#7 / ADV-F4-S4.02-MINOR-4
# The SKILL.md output JSON example has two coherence defects:
#   (a) '"confidence_score": 0.0' is a semantically incoherent placeholder — under D-DEC-011,
#       0.0 maps to confidence="low" (< 0.40 tier), but the example shows "high|medium|low"
#       as the confidence value, training the implementer to associate 0.0 with "high".
#   (b) Degraded-mode prose (line ~144) documents uncertainty_explicit:true but omits
#       prism_enriched:false, leaving the implementer without the degraded-mode JSON contract.
# Both tests are RED until the implementer fixes SKILL.md.

@test "BC_4_05_001 MINOR-4-pass4 ADV-F4-S4.02 VP-SKILL-071 PC6: JSON example confidence_score must not use literal 0.0" {
    # MINOR-4 (BC-4.05.001 v1.6 PC#6 / VP-SKILL-071 / D-DEC-011 / ADV-F4-S4.02 pass-4 MINOR-4)
    # SKILL.md output JSON example currently has '"confidence_score": 0.0'. Under D-DEC-011,
    # confidence_score=0.0 maps to confidence="low" (< 0.40 tier). The example pairs this with
    # '"confidence": "high|medium|low"' which includes "high" — an incoherent combination that
    # trains the implementer to accept 0.0 with any confidence tier, including high.
    # Per BC v1.6, the JSON example must use either:
    #   (a) angle-bracket placeholder notation matching scored_priority's '<CRIT|HIGH|MED|LOW>'
    #       style — e.g., '"confidence_score": "<0.0-1.0>"',
    #   (b) or a concrete coherent score/tier pair — e.g., 0.80 paired with "high".
    # The literal '0.0' placeholder paired with the "high" option is incoherent per D-DEC-011.
    # Red Gate: '"confidence_score": 0.0' IS present in SKILL.md → ! grep fails → RED.
    ! grep -qF '"confidence_score": 0.0' "$SKILL"
}

@test "BC_4_05_001 MINOR-4-pass4 ADV-F4-S4.02 PC7: degraded-mode must document prism_enriched false" {
    # MINOR-4 (BC-4.05.001 v1.6 PC#7 / ADV-F4-S4.02 pass-4 MINOR-4)
    # In degraded mode (Prism MCP unavailable), the skill operates without Prism enrichment.
    # The output JSON must set prism_enriched: false to distinguish degraded-mode results from
    # Prism-grounded results. SKILL.md's main JSON example shows '"prism_enriched": true'
    # (happy-path). The degraded-mode section (line ~144) documents uncertainty_explicit:true
    # but does not state prism_enriched:false — leaving implementers without the degraded-mode
    # JSON contract for this field.
    # The implementer must add 'prism_enriched: false' to the degraded-mode section or a
    # degraded-mode JSON example. Either YAML-style or JSON-quoted form is accepted.
    # Red Gate: neither 'prism_enriched: false' nor '"prism_enriched": false' present → RED.
    grep -qE '"?prism_enriched"?: false' "$SKILL"
}

# ── pass-5 / ADV-F4-S4.02 — whole-file data coherence guards (F1, F2, F2-sibling, F3) ──
# BC-4.05.001 v1.6 / ADV-F4-S4.02 pass-5
#
# The pass-4 tests anchor negative checks to the "Score to Priority Mapping" window
# (grep -m 1 -A 12) which only catches stale values IN the 12 lines after that heading.
# The P3/P4/P5 prose sections (lines ~39-55) and the Factor 3 Override Rule (~88) sit
# OUTSIDE that window and are therefore invisible to the pass-4 negative guards.
#
# These tests scan the ENTIRE data files with no -A window (F3 requirement), so stale
# prose relocated to any section still fails CI. All 10 tests are RED against the current
# data files. SKILL.md and data files are NOT modified here — tests only.

# ── F1 — priority-framework.md P-section stale score thresholds ──────────────────────
# BC-4.05.001 v1.6 PC#6 / Invariant #5 / ADV-F4-S4.02-pass5-F1
# BC v1.6 bands: CRIT >=20/KEV, HIGH 14-19, MED 8-13, LOW <8.
# P3 prose says 10-14; P4 prose says 6-9; P5 prose says 0-5.
# An implementer reading ONLY the P-section definitions (not the mapping table) would
# mis-score base_score=8 (MED) as LOW/90-day and base_score=14 (HIGH) as MED/30-day.

@test "BC_4_05_001 F1-pass5 ADV-F4-S4.02 data-file BC-v1.6-PC6: priority-framework.md must not contain stale P3 Score-Threshold 10-14 anywhere in file" {
    # F1 MAJOR (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-5 F1)
    # BC v1.6: MED band = 8-13. priority-framework.md P3 prose still says "Score Threshold: 10-14".
    # An implementer following the P3 section would mis-classify base_score=8 and 9 as LOW (90d SLA)
    # instead of MED (30d SLA) — a 60-day SLA miss per affected CVE.
    # Whole-file scan (no -A window): stale "Score Threshold: 10-14" anywhere in the file fails CI.
    # Red Gate: line ~39 has '**Score Threshold:** 10-14 points' → ! grep fails → RED.
    ! grep -qF 'Threshold:** 10-14' "$DATA"
}

@test "BC_4_05_001 F1-pass5 ADV-F4-S4.02 data-file BC-v1.6-PC6: priority-framework.md must not contain stale P4 Score-Threshold 6-9 anywhere in file" {
    # F1 MAJOR (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-5 F1)
    # BC v1.6: LOW band = <8 (P5 maps to LOW). There is no "6-9" band. P4 maps to MED (30-day).
    # priority-framework.md P4 prose says "Score Threshold: 6-9" — a non-existent range that
    # contradicts the 8-13 MED band and trains an implementer to split MED into two wrong ranges.
    # Whole-file scan: stale "Score Threshold: 6-9" anywhere in the file fails CI.
    # Red Gate: line ~47 has '**Score Threshold:** 6-9 points' → ! grep fails → RED.
    ! grep -qF 'Threshold:** 6-9' "$DATA"
}

@test "BC_4_05_001 F1-pass5 ADV-F4-S4.02 data-file BC-v1.6-PC6: priority-framework.md must not contain stale P5 Score-Threshold 0-5 anywhere in file" {
    # F1 MAJOR (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-5 F1)
    # BC v1.6: LOW band = <8. P5 maps to LOW/90-day. priority-framework.md P5 prose says
    # "Score Threshold: 0-5" — wrong upper bound (should be <8, i.e., 0-7).
    # NOTE: '0-5' appears legitimately in '### Factor 3: CISA KEV Status (0-5 points, OVERRIDE)'.
    # Guard is anchored to '**Score Threshold:**' prefix (unique to P-section score declarations)
    # so the Factor 3 heading is not a false match; this remains a whole-file scan with no -A window.
    # Red Gate: line ~55 has '**Score Threshold:** 0-5 points' → ! grep fails → RED.
    ! grep -qF 'Threshold:** 0-5' "$DATA"
}

@test "BC_4_05_001 F1-pass5 ADV-F4-S4.02 data-file BC-v1.6-Inv5: priority-framework.md P4 must NOT carry Low/90-day label (BC maps P4 to MED/30-day)" {
    # F1 MAJOR (BC-4.05.001 v1.6 Invariant #5 / ADV-F4-S4.02 pass-5 F1)
    # BC v1.6 Invariant #5: P4 → MED (scored_priority), 30-day SLA.
    # priority-framework.md P4 section header is '### P4 - Low (90 Day SLA)' — wrong on both:
    #   (a) label 'Low' contradicts P4→MED mapping;
    #   (b) '90 Day SLA' contradicts MED's 30-day SLA.
    # An implementer reading this header would produce P4→LOW with 90d SLA, violating BC.
    # Whole-file negative scan (no -A window).
    # Red Gate: line ~43 has 'P4 - Low (90 Day SLA)' → ! grep fails → RED.
    ! grep -qiE 'P4[^|]*(Low|90[[:space:]]*Day)' "$DATA"
}

@test "BC_4_05_001 F1-pass5 ADV-F4-S4.02 data-file BC-v1.6-Inv5: priority-framework.md P5 must NOT carry Informational/No-SLA label (BC maps P5 to LOW/90-day)" {
    # F1 MAJOR (BC-4.05.001 v1.6 Invariant #5 / ADV-F4-S4.02 pass-5 F1)
    # BC v1.6 Invariant #5: P5 → LOW (scored_priority), 90-day SLA.
    # priority-framework.md P5 section header is '### P5 - Informational (No SLA)' — wrong on both:
    #   (a) label 'Informational' contradicts P5→LOW mapping;
    #   (b) 'No SLA' contradicts LOW's 90-day SLA.
    # An implementer reading this header would produce P5→INFORMATIONAL with no SLA, making
    # scored_priority a non-member of {CRIT, HIGH, MED, LOW} and breaking every consumer.
    # Whole-file negative scan (no -A window).
    # Red Gate: line ~51 has 'P5 - Informational (No SLA)' → ! grep fails → RED.
    ! grep -qiE 'P5[^|]*(Informational|No[[:space:]]*SLA)' "$DATA"
}

# ── F2 — priority-framework.md KEV override stale language ───────────────────────────
# BC-4.05.001 v1.6 PC#6 / Invariant #5 / ADV-F4-S4.02-pass5-F2
# BC v1.6: KEV Listed → CRIT unconditional. The Factor 3 Override Rule currently says
# "minimum P2" which contradicts the unconditional KEV→CRIT mapping in the Score to
# Priority Mapping table (already correct) and in BC v1.6 PC#6.

@test "BC_4_05_001 F2-pass5 ADV-F4-S4.02 data-file BC-v1.6-PC6: priority-framework.md must not contain minimum-P1-or-P2 language for KEV anywhere in file" {
    # F2 MEDIUM (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-5 F2)
    # BC v1.6: KEV Listed → CRIT unconditional (the >= 20 or KEV → CRIT row in the mapping table).
    # priority-framework.md Factor 3 Override Rule (line ~88) contradicts this with
    # "KEV Listed = minimum P2 regardless of other factors" — an incoherent minimum-floor
    # statement when the correct contract is an unconditional ceiling: KEV always → CRIT.
    # An implementer could read this and implement a KEV floor at P2 (HIGH) instead of CRIT,
    # causing an under-prioritization for any KEV-listed CVE that scores below the CRIT band.
    # Whole-file negative scan (no -A window) catches "minimum P2" or "minimum P1" anywhere.
    # Red Gate: line ~88 has 'minimum P2' → ! grep fails → RED.
    ! grep -qiE 'minimum[[:space:]]+P[12]' "$DATA"
}

@test "BC_4_05_001 F2-pass5 ADV-F4-S4.02 data-file BC-v1.6-PC6: priority-framework.md Factor 3 KEV override rule must map to CRIT not a P-level label" {
    # F2 MEDIUM (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-5 F2)
    # Positive companion to the negative guard above. After removing "minimum P2", the Factor 3
    # Override Rule line must affirmatively state that KEV Listed maps to CRIT so the implementer
    # has the correct value from the section they are most likely to read.
    # The Score to Priority Mapping table already carries 'CRIT' (pass-4 MAJOR-1 guard); this
    # guard adds the Override Rule line requirement — both locations must be correct.
    #
    # Implementation note: pattern is CASE-SENSITIVE 'CRIT' (-qF, not -qiE) to avoid a false
    # positive from 'Asset Criticality Rating' (Factor 4 heading, line ~90, which lies within
    # a grep -A 10 window of the 'Factor 3' heading). The scored_priority enum value is always
    # uppercase 'CRIT'; 'Criticality' is mixed-case and does not contain uppercase 'CRIT'.
    # Anchored to '**Override Rule:**' line — there is exactly one such line in the file.
    # Red Gate: Override Rule line says 'minimum P2' with no uppercase 'CRIT' → grep fails → RED.
    grep "Override Rule" "$DATA" | grep -qF 'CRIT'
}

# ── F2-sibling — kev-catalog-guide.md KEV stale language (SKILL.md:89 reference) ─────
# BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02-pass5-F2-sibling
# SKILL.md cites kev-catalog-guide.md (SKILL.md:89) as the KEV reference.
# That file uses "Minimum P1 or P2" (line ~59) and "minimum_priority = P2" (line ~104)
# — both contradict BC v1.6's KEV→CRIT unconditional rule.
# An implementer consulting this guide would implement a P2 floor instead of CRIT.

@test "BC_4_05_001 F2-sibling-pass5 ADV-F4-S4.02 kev-guide BC-v1.6-PC6: kev-catalog-guide.md must not contain Minimum-P1-or-P2 language anywhere in file" {
    # F2-sibling (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-5 F2-sibling)
    # kev-catalog-guide.md Priority Override section (line ~59) says:
    #   "- Minimum P1 or P2 regardless of other factor scores"
    # This contradicts BC v1.6 KEV→CRIT unconditional. An implementer consulting this file
    # would apply a P1/P2 floor rather than unconditional CRIT elevation.
    # Whole-file negative scan (no -A window).
    # Red Gate: line ~59 has 'Minimum P1 or P2' → ! grep fails → RED.
    ! grep -qiE 'minimum[[:space:]]+(P1|P2|P1[[:space:]]+or[[:space:]]+P2)' "$KEV_DATA"
}

@test "BC_4_05_001 F2-sibling-pass5 ADV-F4-S4.02 kev-guide BC-v1.6-PC6: kev-catalog-guide.md must not contain minimum_priority=P2 anywhere in file" {
    # F2-sibling (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-5 F2-sibling)
    # kev-catalog-guide.md KEV Override Rules code block (line ~104) says:
    #   "minimum_priority = P2  (cannot go below P2)"
    # This code-block example trains an implementer to hard-code a P2 floor for KEV.
    # Per BC v1.6, KEV Listed unconditionally maps to CRIT; there is no P2 floor.
    # Whole-file negative scan (no -A window).
    # Red Gate: line ~104 has 'minimum_priority = P2' → ! grep fails → RED.
    ! grep -qF 'minimum_priority = P2' "$KEV_DATA"
}

@test "BC_4_05_001 F2-sibling-pass5 ADV-F4-S4.02 kev-guide BC-v1.6-PC6: kev-catalog-guide.md Priority Override must state CRIT (unconditional KEV elevation)" {
    # F2-sibling (BC-4.05.001 v1.6 PC#6 / ADV-F4-S4.02 pass-5 F2-sibling)
    # Positive companion to the two negative guards above. After removing the P1/P2 floor language,
    # the kev-catalog-guide.md Priority Override section must affirmatively state that KEV Listed
    # maps to CRIT so an implementer consulting this guide gets the correct contract.
    # Anchored to 'Priority Override' heading with 5 context lines (covers the key bullet).
    # Red Gate: Priority Override section has no 'CRIT' — file uses only P1/P2 labels → grep fails → RED.
    grep -m 1 -A 5 "Priority Override" "$KEV_DATA" | grep -qiE 'CRIT'
}

# ── MINOR-1 / ADV-F4-S4.02 pass-8 — missing-org_slug degraded paragraph output contract ──
# BC-4.05.001 v1.6 Invariant #4 / PC#7 / ADV-F4-S4.02 pass-8 MINOR-1
#
# The "Degraded mode (Prism MCP unavailable)" paragraph (~SKILL.md:144) correctly documents the
# full PC#7 output contract:
#   (1) map the base score to {CRIT, HIGH, MED, LOW} via PC#6 band thresholds
#   (2) set prism_enriched: false and uncertainty_explicit: true
#
# The parallel "Degraded-mode fallback (missing org_slug)" paragraph (~SKILL.md:142) describes
# what to SKIP (all PC#5a-5e) but omits both output-contract clauses.
# BC-4.05.001 v1.6 Invariant #4 explicitly treats missing org_slug as a PC#7 degradation path
# with the SAME output contract. An implementer reading only the org_slug paragraph would skip
# Prism enrichment but leave scored_priority undefined (no band-mapping instruction) and omit
# the required output flags — producing a result that violates PC#6 and PC#7.
#
# Test is anchored to the missing-org_slug paragraph exclusively via grep -m 1 "missing org_slug":
# that returns only SKILL.md line ~142, which does NOT contain the required clauses.
# The MCP-unavailable paragraph at line ~144 DOES contain both clauses but CANNOT satisfy this
# test because it does not contain "missing org_slug" and is not returned by the anchor grep.

@test "BC_4_05_001 MINOR-1-pass8 ADV-F4-S4.02 BC-v1.6-Inv4-PC7: missing-org_slug degraded paragraph must document PC#6 band mapping and prism_enriched false + uncertainty_explicit true" {
    # MINOR-1 (BC-4.05.001 v1.6 Invariant #4 / PC#7 / ADV-F4-S4.02 pass-8 MINOR-1)
    #
    # BC-4.05.001 v1.6 Invariant #4: when org_slug is missing, the degradation path is PC#7 —
    # the same output contract as the Prism-MCP-unavailable path. The output contract requires:
    #   (1) Map the 6-factor base score to {CRIT, HIGH, MED, LOW} via PC#6 band thresholds
    #   (2) Set prism_enriched: false (skill operated without Prism enrichment)
    #   (3) Set uncertainty_explicit: true (required by BC-4.05.001 v1.6 Invariant #4 / PC#7)
    #
    # The "Degraded-mode fallback (missing org_slug)" paragraph (~SKILL.md:142) documents the
    # skip behaviour but omits all three output-contract clauses. The "Degraded mode (Prism MCP
    # unavailable)" paragraph (~SKILL.md:144) has all three — but is a DIFFERENT code path.
    #
    # Anchor: grep -m 1 "missing org_slug" returns ONLY SKILL.md line ~142 (the org_slug
    # paragraph). The MCP-unavailable paragraph does not contain "missing org_slug" and therefore
    # cannot satisfy this test regardless of its content.
    #
    # Red Gate: SKILL.md line ~142 contains none of the three required clauses → all assertions
    # below fail → test RED. The implementer must add the output contract to the org_slug paragraph.
    org_slug_para=$(grep -m 1 "missing org_slug" "$SKILL")

    # (1) PC#6 band mapping: paragraph must reference PC#6 band thresholds or explicitly name
    #     {CRIT,HIGH,MED,LOW} in the context of scoring/mapping the base score.
    echo "$org_slug_para" | grep -qiE 'PC.?6|band.*(CRIT|HIGH|MED|LOW)|(CRIT|HIGH|MED|LOW).*band|(map|mapping).*base.?score'

    # (2) prism_enriched: false must appear in the org_slug degraded paragraph.
    echo "$org_slug_para" | grep -qE '"?prism_enriched"?:[[:space:]]*false'

    # (3) uncertainty_explicit: true must appear in the org_slug degraded paragraph.
    echo "$org_slug_para" | grep -qE '"?uncertainty_explicit"?:[[:space:]]*true'
}

# ── MINOR (wave1-adv) | S-4.02 ─ CHANGELOG [Unreleased] section regression guard ─────────────
# Wave-1 adversarial finding: CHANGELOG.md lacked any entry for S-4.02, creating a 2-of-3
# asymmetry in [Unreleased] coverage (S-6.03 and S-3.01 documented; S-4.02 absent).
# Keep a Changelog convention: every unreleased change must be documented before release.
# Mirrors the pattern from tests/skills/activate-close-state.bats
# (test_BC_6_01_001_changelog_has_unreleased_section and
#  test_BC_6_01_001_changelog_unreleased_documents_close_state_allowlist).
# CHANGELOG is at repo root; PLUGIN_ROOT is plugins/secops-factory → ../../CHANGELOG.md.

CHANGELOG="${PLUGIN_ROOT}/../../CHANGELOG.md"

@test "test_BC_4_05_001_changelog_has_unreleased_section (MINOR-wave1-adv, S-4.02)" {
    # S-4.02 regression guard: CHANGELOG.md must contain an [Unreleased] section header
    # (Keep a Changelog convention) so the assess-priority scored_priority change is
    # visible before the next release tag.
    grep -qF "[Unreleased]" "$CHANGELOG"
}

@test "test_BC_4_05_001_changelog_unreleased_documents_s4_02_scoring_change (MINOR-wave1-adv, S-4.02, BC-4.05.001)" {
    # S-4.02 regression guard: the [Unreleased] section must document the S-4.02 change
    # by naming one of the canonical identifiers: scored_priority or BC-4.05.001.
    # A bare [Unreleased] header with no S-4.02 content does not satisfy this requirement.
    grep -qE "scored_priority|BC-4\.05\.001" "$CHANGELOG"
}

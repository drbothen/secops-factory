#!/usr/bin/env bats
# secops-factory skill tests
# Validates Iron Laws, Announce at Start, Red Flags, template/data portability

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/.."

# --- Iron Law presence tests ---

@test "enrich-ticket has Iron Law" {
    grep -qF "NO JIRA UPDATE WITHOUT COMPLETED ENRICHMENT FIRST" "$PLUGIN_ROOT/skills/enrich-ticket/SKILL.md"
}

@test "assess-priority has Iron Law" {
    grep -qF "NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST" "$PLUGIN_ROOT/skills/assess-priority/SKILL.md"
}

@test "investigate-event has Iron Law" {
    grep -qF "NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST" "$PLUGIN_ROOT/skills/investigate-event/SKILL.md"
}

@test "review-enrichment has Iron Law" {
    grep -qF "NO APPROVAL WITHOUT FRESH-CONTEXT REVIEW FIRST" "$PLUGIN_ROOT/skills/review-enrichment/SKILL.md"
}

@test "update-jira has Iron Law" {
    grep -qF "NO JIRA UPDATE WITHOUT REVIEW APPROVAL FIRST" "$PLUGIN_ROOT/skills/update-jira/SKILL.md"
}

@test "adversarial-review-secops has Iron Law" {
    grep -qF "NO QUALITY SIGN-OFF WITHOUT ADVERSARIAL CONVERGENCE FIRST" "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md"
}

# --- Announce at Start tests ---

@test "enrich-ticket has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/enrich-ticket/SKILL.md"
}

@test "assess-priority has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/assess-priority/SKILL.md"
}

@test "investigate-event has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/investigate-event/SKILL.md"
}

@test "review-enrichment has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/review-enrichment/SKILL.md"
}

@test "update-jira has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/update-jira/SKILL.md"
}

@test "adversarial-review-secops has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md"
}

# --- Red Flags tests (minimum 6 rows each) ---

@test "enrich-ticket has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/enrich-ticket/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

@test "assess-priority has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/assess-priority/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

@test "investigate-event has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/investigate-event/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

@test "review-enrichment has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/review-enrichment/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

@test "update-jira has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/update-jira/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

@test "adversarial-review-secops has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

# --- Template portability tests ---

@test "templates use CLAUDE_PLUGIN_ROOT variable" {
    for skill in enrich-ticket investigate-event review-enrichment; do
        grep -qF '${CLAUDE_PLUGIN_ROOT}/templates/' "$PLUGIN_ROOT/skills/$skill/SKILL.md"
    done
}

# --- Data portability tests ---

@test "data references use CLAUDE_PLUGIN_ROOT variable" {
    for skill in enrich-ticket assess-priority investigate-event review-enrichment; do
        grep -qF '${CLAUDE_PLUGIN_ROOT}/data/' "$PLUGIN_ROOT/skills/$skill/SKILL.md"
    done
}

# --- No BMAD references ---

@test "no BMAD references in skills" {
    for skill_dir in "$PLUGIN_ROOT"/skills/*/; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            ! grep -qiF "bmad" "$skill_dir/SKILL.md"
        fi
    done
}

@test "no BMAD references in agents" {
    for agent in "$PLUGIN_ROOT"/agents/*.md; do
        ! grep -qiF "bmad" "$agent"
    done
}

@test "no BMAD references in data" {
    for data_file in "$PLUGIN_ROOT"/data/*.md; do
        ! grep -qiF "bmad" "$data_file"
    done
}

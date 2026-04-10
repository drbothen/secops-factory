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

# --- Honest convergence and hallucination classes ---

@test "adversarial-review-secops has Honest Convergence clause" {
    grep -qF "Honest Convergence" "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md"
    grep -qF "fewer than 3 substantive" "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md"
}

@test "adversarial-review-secops has Known Review Hallucination Classes" {
    grep -qF "Known Review Hallucination" "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md"
}

@test "adversarial-review-secops has Subagent Delivery Protocol" {
    grep -qF "Subagent Delivery Protocol" "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md"
    grep -qF "=== FILE:" "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md"
}

@test "adversarial-review-secops has Canonical Source pointer" {
    grep -qF "review-convergence-workflow.md" "$PLUGIN_ROOT/skills/adversarial-review-secops/SKILL.md"
}

# --- Template file existence tests ---

@test "every referenced template actually exists" {
    missing=0
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        if [ ! -f "${PLUGIN_ROOT}/${ref}" ]; then
            echo "MISSING: ${ref}" >&2
            missing=$((missing + 1))
        fi
    done < <(grep -rho '\${CLAUDE_PLUGIN_ROOT}/templates/[a-zA-Z0-9_/-]*\.\(md\|yaml\)' \
               "${PLUGIN_ROOT}/skills" "${PLUGIN_ROOT}/agents" \
               2>/dev/null | sed 's|${CLAUDE_PLUGIN_ROOT}/||' | sort -u)
    [ "$missing" -eq 0 ]
}

@test "every referenced data file actually exists" {
    missing=0
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        if [ ! -f "${PLUGIN_ROOT}/${ref}" ]; then
            echo "MISSING: ${ref}" >&2
            missing=$((missing + 1))
        fi
    done < <(grep -rho '\${CLAUDE_PLUGIN_ROOT}/data/[a-zA-Z0-9_/-]*\.md' \
               "${PLUGIN_ROOT}/skills" "${PLUGIN_ROOT}/agents" \
               2>/dev/null | sed 's|${CLAUDE_PLUGIN_ROOT}/||' | sort -u)
    [ "$missing" -eq 0 ]
}

@test "every referenced checklist actually exists" {
    missing=0
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        if [ ! -f "${PLUGIN_ROOT}/${ref}" ]; then
            echo "MISSING: ${ref}" >&2
            missing=$((missing + 1))
        fi
    done < <(grep -rho '\${CLAUDE_PLUGIN_ROOT}/checklists/[a-zA-Z0-9_/-]*\.md' \
               "${PLUGIN_ROOT}/skills" "${PLUGIN_ROOT}/agents" \
               2>/dev/null | sed 's|${CLAUDE_PLUGIN_ROOT}/||' | sort -u)
    [ "$missing" -eq 0 ]
}

# --- Agent structural tests ---

@test "security-analyst has required frontmatter fields" {
    grep -qF "name:" "$PLUGIN_ROOT/agents/security-analyst.md"
    grep -qF "description:" "$PLUGIN_ROOT/agents/security-analyst.md"
    grep -qF "model:" "$PLUGIN_ROOT/agents/security-analyst.md"
    grep -qF "color:" "$PLUGIN_ROOT/agents/security-analyst.md"
}

@test "security-reviewer has required frontmatter fields" {
    grep -qF "name:" "$PLUGIN_ROOT/agents/security-reviewer.md"
    grep -qF "description:" "$PLUGIN_ROOT/agents/security-reviewer.md"
    grep -qF "model:" "$PLUGIN_ROOT/agents/security-reviewer.md"
    grep -qF "color:" "$PLUGIN_ROOT/agents/security-reviewer.md"
}

@test "security-reviewer uses opus model" {
    grep -qF "model: opus" "$PLUGIN_ROOT/agents/security-reviewer.md"
}

@test "security-reviewer does not have Write tool" {
    ! grep -qF "Write" "$PLUGIN_ROOT/agents/security-reviewer.md"
}

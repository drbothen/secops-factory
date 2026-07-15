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

# --- create-advisory skill ---

@test "create-advisory has Iron Law" {
    grep -qF "NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST" "$PLUGIN_ROOT/skills/create-advisory/SKILL.md"
}

@test "create-advisory has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/create-advisory/SKILL.md"
}

@test "create-advisory has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/create-advisory/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

@test "create-advisory supports custom template via --template" {
    grep -qF -- "--template" "$PLUGIN_ROOT/skills/create-advisory/SKILL.md"
}

@test "create-advisory presents interactive advisory type choice" {
    grep -qF "What advisory type?" "$PLUGIN_ROOT/skills/create-advisory/SKILL.md"
    grep -qF "ICS/OT" "$PLUGIN_ROOT/skills/create-advisory/SKILL.md"
    grep -qF "Combined" "$PLUGIN_ROOT/skills/create-advisory/SKILL.md"
}

@test "create-advisory has Source Verification Gate" {
    grep -qF "Source Verification Gate" "$PLUGIN_ROOT/skills/create-advisory/SKILL.md"
}

# --- scan-threats skill ---

@test "scan-threats presents environment choice" {
    grep -qF "What environment should I focus on?" "$PLUGIN_ROOT/skills/scan-threats/SKILL.md"
}

@test "scan-threats has prioritization scoring" {
    grep -qF "Score each candidate" "$PLUGIN_ROOT/skills/scan-threats/SKILL.md"
    grep -qF "Advisory threshold" "$PLUGIN_ROOT/skills/scan-threats/SKILL.md"
}

@test "scan-threats supports Perplexity fallback" {
    grep -qF "Web search fallback" "$PLUGIN_ROOT/skills/scan-threats/SKILL.md" || grep -qF "WebSearch" "$PLUGIN_ROOT/skills/scan-threats/SKILL.md"
}

# --- advisory template exists ---

@test "security-advisory-tmpl.md exists and has required sections" {
    [ -f "$PLUGIN_ROOT/templates/security-advisory-tmpl.md" ]
    grep -qF "Executive Summary" "$PLUGIN_ROOT/templates/security-advisory-tmpl.md"
    grep -qF "Affected Products" "$PLUGIN_ROOT/templates/security-advisory-tmpl.md"
    grep -qF "Remediation" "$PLUGIN_ROOT/templates/security-advisory-tmpl.md"
    grep -qF "ICS/OT Context" "$PLUGIN_ROOT/templates/security-advisory-tmpl.md"
    grep -qF "Detection Guidance" "$PLUGIN_ROOT/templates/security-advisory-tmpl.md"
    grep -qF "TLP" "$PLUGIN_ROOT/templates/security-advisory-tmpl.md"
}

# --- advisory-writer agent ---

@test "advisory-writer agent has required frontmatter" {
    grep -qF "name:" "$PLUGIN_ROOT/agents/advisory-writer.md"
    grep -qF "model:" "$PLUGIN_ROOT/agents/advisory-writer.md"
    grep -qF "color:" "$PLUGIN_ROOT/agents/advisory-writer.md"
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

# --- orchestrator agent (main-session SOC companion) ---

@test "orchestrator agent exists with required frontmatter" {
    [ -f "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md" ]
    grep -qF "name: orchestrator" "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md"
    grep -qF "description:" "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md"
}

@test "orchestrator agent is invokable (no disable-model-invocation)" {
    ! grep -qF "disable-model-invocation: true" "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md"
}

@test "orchestrator agent has Iron Law" {
    grep -qF "NO FREELANCE ANALYSIS" "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md"
}

@test "orchestrator agent has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md"
}

@test "orchestrator agent has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md" || true)
    [ "$count" -ge 6 ]
}

@test "orchestrator agent has routing table covering all workflow entry points" {
    for cmd in enrich-ticket investigate-event scan-threats create-advisory review-enrichment adversarial-review-secops update-jira secops-health; do
        grep -qF "/$cmd" "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md"
    done
}

@test "orchestrator agent references pipeline playbooks" {
    grep -qF '${CLAUDE_PLUGIN_ROOT}/agents/orchestrator/' "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md"
}

# --- activate / deactivate skills ---

@test "activate skill exists and sets the orchestrator default agent" {
    [ -f "$PLUGIN_ROOT/skills/activate/SKILL.md" ]
    grep -qF '"agent": "secops-factory:orchestrator:orchestrator"' "$PLUGIN_ROOT/skills/activate/SKILL.md"
}

@test "activate skill targets settings.local.json (never shared settings)" {
    grep -qF "settings.local.json" "$PLUGIN_ROOT/skills/activate/SKILL.md"
}

@test "activate skill is user-invoked only" {
    grep -qF "disable-model-invocation: true" "$PLUGIN_ROOT/skills/activate/SKILL.md"
}

@test "activate skill has Announce at Start" {
    grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/activate/SKILL.md"
}

@test "activate skill has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/activate/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

@test "deactivate skill exists and reverses activation" {
    [ -f "$PLUGIN_ROOT/skills/deactivate/SKILL.md" ]
    grep -qF "del(.agent)" "$PLUGIN_ROOT/skills/deactivate/SKILL.md"
}

@test "deactivate skill guards against clobbering non-secops agents" {
    grep -qF "secops-factory:" "$PLUGIN_ROOT/skills/deactivate/SKILL.md"
}

@test "deactivate skill has >= 6 Red Flag rows" {
    count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/deactivate/SKILL.md" || true)
    [ "$count" -ge 6 ]
}

@test "activate and deactivate command wrappers exist" {
    [ -f "$PLUGIN_ROOT/commands/activate.md" ]
    [ -f "$PLUGIN_ROOT/commands/deactivate.md" ]
    grep -qF "activate" "$PLUGIN_ROOT/commands/activate.md"
    grep -qF "deactivate" "$PLUGIN_ROOT/commands/deactivate.md"
}

# --- metrics suite (analyze-ticket-effort, model-ticket-cost, extract-severity, verify-metrics-report) ---

@test "analyze-ticket-effort has Iron Law" {
    grep -qF "NO EFFORT REPORT WITHOUT STATED BIASES FIRST" "$PLUGIN_ROOT/skills/analyze-ticket-effort/SKILL.md"
}

@test "model-ticket-cost has Iron Law" {
    grep -qF "NO COST FIGURE WITHOUT SCENARIOS AND STATED EXCLUSIONS FIRST" "$PLUGIN_ROOT/skills/model-ticket-cost/SKILL.md"
}

@test "extract-severity has Iron Law" {
    grep -qF "NO SEVERITY STATS WITHOUT COVERAGE COUNTS FIRST" "$PLUGIN_ROOT/skills/extract-severity/SKILL.md"
}

@test "verify-metrics-report has Iron Law" {
    grep -qF "NO VERIFICATION VERDICT WITHOUT WINDOW ARCHAEOLOGY FIRST" "$PLUGIN_ROOT/skills/verify-metrics-report/SKILL.md"
}

@test "metrics skills have Announce at Start and >= 6 Red Flag rows" {
    for skill in analyze-ticket-effort model-ticket-cost extract-severity verify-metrics-report; do
        grep -qF "Announce at Start" "$PLUGIN_ROOT/skills/$skill/SKILL.md"
        count=$(grep -c '^| "' "$PLUGIN_ROOT/skills/$skill/SKILL.md" || true)
        [ "$count" -ge 6 ]
    done
}

@test "metrics skills reference the canonical method doc" {
    for skill in analyze-ticket-effort model-ticket-cost extract-severity verify-metrics-report; do
        grep -qF 'data/effort-analysis-method.md' "$PLUGIN_ROOT/skills/$skill/SKILL.md"
    done
}

@test "effort-analysis method doc and priors template exist" {
    [ -f "$PLUGIN_ROOT/data/effort-analysis-method.md" ]
    [ -f "$PLUGIN_ROOT/templates/effort-priors-tmpl.yaml" ]
}

@test "method doc contains the session-reconstruction anchors" {
    grep -qF "GAP = 30 * 60" "$PLUGIN_ROOT/data/effort-analysis-method.md"
    grep -qF "OVERHEAD_MIN = 5" "$PLUGIN_ROOT/data/effort-analysis-method.md"
    grep -qF "adf_text" "$PLUGIN_ROOT/data/effort-analysis-method.md"
}

@test "method doc and priors template contain no client-identifying data" {
    for f in "$PLUGIN_ROOT/data/effort-analysis-method.md" "$PLUGIN_ROOT/templates/effort-priors-tmpl.yaml" "$PLUGIN_ROOT/agents/metrics-analyst.md" "$PLUGIN_ROOT/agents/osint-researcher.md"; do
        ! grep -qiE "weyerhaeuser|monroe|fairview|lea county|michigan power|1898|jpud|avon" "$f"
    done
}

@test "generate-metrics routes to the specialized metrics skills" {
    for cmd in analyze-ticket-effort model-ticket-cost extract-severity verify-metrics-report; do
        grep -qF "/$cmd" "$PLUGIN_ROOT/skills/generate-metrics/SKILL.md"
    done
}

@test "metrics command wrappers exist and reference their skills" {
    for cmd in analyze-ticket-effort model-ticket-cost extract-severity verify-metrics-report; do
        [ -f "$PLUGIN_ROOT/commands/$cmd.md" ]
        grep -qF "$cmd" "$PLUGIN_ROOT/commands/$cmd.md"
    done
}

@test "metrics-analyst agent has required frontmatter" {
    grep -qF "name: metrics-analyst" "$PLUGIN_ROOT/agents/metrics-analyst.md"
    grep -qF "model:" "$PLUGIN_ROOT/agents/metrics-analyst.md"
    grep -qF "color:" "$PLUGIN_ROOT/agents/metrics-analyst.md"
}

@test "osint-researcher agent has required frontmatter and citation discipline" {
    grep -qF "name: osint-researcher" "$PLUGIN_ROOT/agents/osint-researcher.md"
    grep -qF "model:" "$PLUGIN_ROOT/agents/osint-researcher.md"
    grep -qF "citation" "$PLUGIN_ROOT/agents/osint-researcher.md"
}

@test "orchestrator routes metrics intents" {
    for cmd in analyze-ticket-effort model-ticket-cost extract-severity verify-metrics-report; do
        grep -qF "/$cmd" "$PLUGIN_ROOT/agents/orchestrator/orchestrator.md"
    done
}

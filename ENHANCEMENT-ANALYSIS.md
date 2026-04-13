# Enhancement Analysis: secops-factory vs vsdd-factory

## What secops-factory already does well

These patterns were correctly adopted from vsdd-factory and should not regress:

1. **Iron Law + Announce at Start + Red Flags table** on every discipline skill. All 6 skills that need them have them (enrich-ticket, assess-priority, investigate-event, review-enrichment, update-jira, adversarial-review-secops). Tests enforce their presence.

2. **Information asymmetry** for the reviewer agent. `security-reviewer.md` lines 33-37 explicitly block contamination from prior passes, matching vsdd's adversary pattern.

3. **Strict-binary novelty** in the adversarial-review-secops skill. SUBSTANTIVE vs NITPICK with minimum 2 passes, maximum 5.

4. **Template/data portability** via `${CLAUDE_PLUGIN_ROOT}/` paths. Structural tests validate this (skills.bats lines 93-105).

5. **AGENT-SOUL.md** with domain-appropriate principles (Evidence Over Opinion, Multi-Factor Assessment, Blameless Review Culture, Information Asymmetry, Cognitive Bias Awareness, ICS/OT Safety First, Standards Over Invention, Convergence Over Perfection).

6. **Quality rubrics** with dimensional scoring (8 dimensions for CVE, 7 weighted dimensions for event investigation).

7. **Polymorphic type detection** in review-enrichment skill (auto-detects CVE vs event).

8. **Cognitive bias audit** as mandatory per-pass requirement in adversarial review.

9. **Red Flag tables** with 6+ rows per skill, enforced by tests.

10. **No BMAD references** test (skills.bats lines 109-127).

---

## P0 -- Structural gaps (plugin won't load correctly or patterns are broken)

### P0-1: hooks.json uses legacy array format, not the nested matcher format

**(a) secops has:**
`hooks/hooks.json` is a flat JSON array with `hook_type`, `tool_name`, `script` keys:
```json
[
  {
    "hook_type": "PreToolUse",
    "tool_name": "mcp__atlassian__updateJiraIssue",
    "script": "hooks/require-review.sh"
  }
]
```

**(b) vsdd has:**
`hooks/hooks.json` uses a nested `hooks` object with `PreToolUse`, `PostToolUse`, `SubagentStop`, and `Stop` event types, each containing `matcher` patterns and `type`/`command`/`timeout` entries:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/protect-vp.sh", "timeout": 5 }
        ]
      }
    ]
  }
}
```

**(c) gap:** The secops format is not the Claude Code plugin hooks.json schema. The secops hooks may not actually fire at all, depending on which schema the harness expects. The vsdd format uses `${CLAUDE_PLUGIN_ROOT}/` for portability; secops uses bare relative paths.

**(d) fix:** Rewrite `hooks/hooks.json` to match the vsdd schema. Map the 3 existing hooks:
- `require-review.sh` on `mcp__atlassian__updateJiraIssue` -> PreToolUse matcher
- `enrichment-completeness.sh` on `Write` -> PreToolUse matcher `Write`
- `bias-check-reminder.sh` on `mcp__perplexity__perplexity_search` -> PostToolUse matcher

**File:** `plugins/secops-factory/hooks/hooks.json`

### P0-2: Hook scripts use bare JSON output, not permissionDecision envelope

**(a) secops has:**
`hooks/require-review.sh` emits `{"decision": "allow"|"block", "reason": "..."}` (lines 37-39, 59-61, 63-65). `hooks/enrichment-completeness.sh` uses the same format.

**(b) vsdd has:**
`hooks/protect-vp.sh` emits the Claude Code `permissionDecision` envelope:
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```
and for denials:
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}
```

**(c) gap:** The secops hooks emit a custom JSON shape (`decision`/`reason`) that the Claude Code harness does not recognize. The harness expects `permissionDecision` in `hookSpecificOutput`. These hooks are likely no-ops in production.

**(d) fix:** Rewrite `require-review.sh` and `enrichment-completeness.sh` to use `emit_allow()`/`emit_deny()` helper functions matching the vsdd pattern. Keep `bias-check-reminder.sh` as-is (PostToolUse hooks are advisory).

**Files:** `hooks/require-review.sh`, `hooks/enrichment-completeness.sh`

### P0-3: Hook scripts use python3 for JSON parsing; vsdd uses jq

**(a) secops has:**
All 3 hooks use `python3 -c "import sys, json; ..."` with `2>/dev/null` stderr suppression (e.g., `require-review.sh` lines 16-21, 24-32). This violates the bash.md rule "Never suppress stderr with 2>/dev/null" and adds a python3 dependency.

**(b) vsdd has:**
All 10 hooks use `jq` for JSON parsing with proper tool guards (e.g., `protect-vp.sh` line 22: `jq -r '.tool_input.file_path // empty'`). Several include `command -v jq` guards at the top.

**(c) gap:** python3 `2>/dev/null` masks real errors. A python3 crash would produce empty strings that evaluate as "allow", causing a silent hook bypass (the exact failure mode SOUL.md warns against). Also, `jq` is the standard tool for JSON in shell scripts per the project's own bash.md rules.

**(d) fix:** Rewrite all 3 hooks to use `jq`. Add `command -v jq` guard at the top of each. Remove all `2>/dev/null` suppressions.

**Files:** `hooks/require-review.sh`, `hooks/enrichment-completeness.sh`, `hooks/bias-check-reminder.sh`

---

## P1 -- High-ROI pattern adoptions

### P1-1: No specialist dispatch pattern (deliver-story equivalent)

**(a) secops has:**
The `enrich-ticket` skill runs all 8 stages in a single agent context. The skill frontmatter has no `disable-model-invocation`, no `allowed-tools` restrictions, and no `agent` directive. The security-analyst agent does everything.

**(b) vsdd has:**
`deliver-story` uses `disable-model-invocation: true` and `allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion, Task` to make the skill a pure dispatcher. Fresh specialist subagents handle each step (test-writer, implementer, demo-recorder, pr-manager, devops-engineer). The skill's SKILL.md explicitly states: "Single-context delivery is a correctness bug, not a shortcut."

**(c) gap:** For a simple 8-stage enrichment workflow, specialist dispatch may be overkill. However, the adversarial-review-secops skill DOES need dispatch discipline (it dispatches security-reviewer), and it already has `context: fork` and `agent: security-reviewer` in its frontmatter. The gap is that `enrich-ticket` and `investigate-event` could benefit from dispatching the review step as a fresh-context subagent rather than relying on the same agent to self-review.

**(d) fix:** Consider adding `context: fork` to `review-enrichment` skill so the reviewer always gets fresh context when dispatched from the enrichment workflow. For the full enrichment pipeline, consider an orchestrator workflow file (see P1-2) rather than converting enrich-ticket into a dispatcher, since the 8 stages are sequential and domain-specific rather than requiring specialist diversity.

**Files:** `skills/review-enrichment/SKILL.md` (add `context: fork` to frontmatter)

### P1-2: No orchestrator workflow files

**(a) secops has:**
No `agents/orchestrator/` directory. No workflow reference files. The security-analyst agent has workflows described inline in its agent file (lines 114-131).

**(b) vsdd has:**
`agents/orchestrator/` contains 9 workflow files: `orchestrator.md`, `per-story-delivery.md`, `brownfield-sequence.md`, `greenfield-sequence.md`, `discovery-sequence.md`, `feature-sequence.md`, `maintenance-sequence.md`, `steady-state.md`, `multi-repo.md`, plus `HEARTBEAT.md`. These are the canonical source of truth for multi-step workflows.

**(c) gap:** secops-factory has two multi-step workflows (8-stage enrichment, 7-stage investigation) that would benefit from orchestrator workflow files as canonical sources. Currently the workflow steps live only in the skill SKILL.md files. Having a separate orchestrator workflow means the skill is the dispatcher and the workflow file is the playbook -- if they disagree, the workflow file wins.

**(d) fix:** Create `agents/orchestrator/` with at minimum:
- `enrichment-workflow.md` -- canonical 8-stage enrichment sequence
- `investigation-workflow.md` -- canonical 7-stage investigation sequence
- `review-convergence-workflow.md` -- canonical adversarial review loop

Skill files reference these as "Canonical Source" (matching vsdd's deliver-story pattern).

**Files:** New: `agents/orchestrator/enrichment-workflow.md`, `agents/orchestrator/investigation-workflow.md`, `agents/orchestrator/review-convergence-workflow.md`

### P1-3: Adversarial review skill missing honest convergence clause and hallucination classes

**(a) secops has:**
`skills/adversarial-review-secops/SKILL.md` has strict-binary novelty and cognitive bias audit, but no "honest convergence" clause and no hallucination class catalog. The skill does not address the fabrication failure mode.

**(b) vsdd has:**
`skills/brownfield-ingest/SKILL.md` lines 236-239 include a mandatory verbatim clause:
> "Honest convergence is required. If you find fewer than 3 substantive items, declare convergence and emit no updated file..."

Plus 5 Known Round-1 Hallucination Classes (lines 242-249) with specific examples from production runs.

`skills/adversarial-review/SKILL.md` references the same pattern through the adversary agent.

**(c) gap:** Security review convergence is vulnerable to the same fabrication failure mode. A reviewer that inflates findings to justify its existence produces noise that wastes analyst time and erodes trust in the review process. The hallucination classes are also relevant: a reviewer might over-extrapolate from a single bias signal, miscount checklist items, or conflate two different enrichment documents.

**(d) fix:** Add an "Honest Convergence" section to `adversarial-review-secops/SKILL.md` with a domain-adapted verbatim clause. Add "Known Review Hallucination Classes" section adapted for secops (e.g., over-extrapolated bias signals, miscounted checklist scores, conflated enrichment documents, phantom findings from prior-pass contamination).

**File:** `skills/adversarial-review-secops/SKILL.md`

### P1-4: No inline delivery protocol for subagents

**(a) secops has:**
No mention of subagent delivery protocol. The adversarial-review-secops skill dispatches security-reviewer but does not specify how the reviewer should return its findings.

**(b) vsdd has:**
`skills/brownfield-ingest/SKILL.md` lines 84-91 define a "Subagent Delivery Protocol (inline-by-default)" with a verbatim instruction block that every subagent prompt must include, addressing sandbox Write-tool denials.

**(c) gap:** If the security-reviewer agent is sandboxed and cannot write to the artifacts directory, its output is lost. The inline delivery protocol prevents this.

**(d) fix:** Add a "Subagent Delivery Protocol" section to `adversarial-review-secops/SKILL.md` with verbatim instructions for the security-reviewer to return findings inline using `=== FILE: ... ===` delimiters. The orchestrator writes the files.

**File:** `skills/adversarial-review-secops/SKILL.md`

### P1-5: Test coverage gap (32 tests vs 62 in vsdd)

**(a) secops has:**
32 tests total: 23 in skills.bats, 9 in hooks.bats. No bin.bats. Tests check presence of Iron Law text, Announce at Start heading, Red Flag row counts, template/data portability, and BMAD references. Hook tests check allow/block paths.

**(b) vsdd has:**
62 tests total: 21 in skills.bats, 28 in hooks.bats, 13 in bin.bats. Skills tests additionally check: honest convergence clause presence, hallucination class presence, subagent delivery protocol presence, behavioral vs metric split presence, priority-ordered lessons mandate, validate-extraction agent split, no non-portable `.claude/templates/` paths, and that every referenced template file actually exists on disk.

**(c) gap:** Key missing test categories:
- **Template existence verification** (vsdd skills.bats lines 131-146): secops tests that skills reference `${CLAUDE_PLUGIN_ROOT}/templates/` but never verifies the referenced templates exist on disk.
- **Data file existence verification**: Same gap for data file references.
- **Checklist existence verification**: Same gap for checklist references.
- **Hook output format validation**: secops hook tests check for `"allow"` or `"block"` strings but should check for the `permissionDecision` envelope (once P0-2 is fixed).
- **Agent structural tests**: No tests verify agent frontmatter (model, tools, etc.).
- **No non-portable path test**: vsdd tests that no skill/agent references `.claude/templates/` -- secops has no equivalent.

**(d) fix:** Add to skills.bats:
- Template existence test (grep all `${CLAUDE_PLUGIN_ROOT}/templates/` refs, verify each file exists)
- Data file existence test (same for `/data/`)
- Checklist existence test (same for `/checklists/`)
- Non-portable path test (no `.claude/templates/` or `.claude/data/` refs)

Add to hooks.bats:
- `permissionDecision` envelope format tests (after P0-2 fix)

Create agents.bats:
- Agent frontmatter presence tests (name, description, model, tools)
- Agent information asymmetry test (security-reviewer has no Write tool... actually it does -- see P2-3)

**Files:** `tests/skills.bats`, `tests/hooks.bats`, new `tests/agents.bats`

### P1-6: Hook coverage gap (3 hooks vs 10 in vsdd)

**(a) secops has:**
3 hooks:
1. `require-review.sh` -- PreToolUse on JIRA update (blocks unreviewed updates)
2. `enrichment-completeness.sh` -- PreToolUse on Write (blocks partial enrichment)
3. `bias-check-reminder.sh` -- PostToolUse on Perplexity search (advisory)

**(b) vsdd has:**
10 hooks across 4 event types:
- PreToolUse (6): brownfield-discipline, protect-vp, protect-bc, red-gate, verify-git-push, check-factory-commit
- PostToolUse (2): purity-check, regression-gate
- SubagentStop (1): handoff-validator
- Stop (1): session-learning

**(c) gap:** Missing high-value hooks for secops:

| vsdd hook | secops equivalent needed | Priority |
|-----------|------------------------|----------|
| `handoff-validator.sh` (SubagentStop) | Validate security-reviewer returns non-empty result | HIGH -- empty adversarial review is the #1 silent failure |
| `session-learning.sh` (Stop) | Log session end for continuity across enrichment sessions | MEDIUM |
| `verify-git-push.sh` (PreToolUse on Bash) | Block force-push on artifact repos | LOW (secops may not manage git repos) |
| `check-factory-commit.sh` (PostToolUse on Bash) | N/A unless secops adopts .factory/ pattern | LOW |
| `regression-gate.sh` (PostToolUse on Bash) | N/A (secops doesn't run test suites in the pipeline) | N/A |

**(d) fix:** Add at minimum:
1. `handoff-validator.sh` -- port directly from vsdd, validates SubagentStop output is non-empty and >40 chars. Critical for adversarial review quality.
2. `disposition-guard.sh` -- secops-specific PreToolUse hook that blocks writing a disposition without the `Alternatives Considered` section (domain equivalent of vsdd's protect-vp).

Update hooks.json with the new hooks.

**Files:** New: `hooks/handoff-validator.sh`, `hooks/disposition-guard.sh`. Modified: `hooks/hooks.json`

### P1-7: AGENT-SOUL.md missing pragmatism footnote

**(a) secops has:**
`docs/AGENT-SOUL.md` section 10 "Convergence Over Perfection" (lines 111-118) is the pragmatism equivalent, but it is 8 lines and lacks the critical distinction between principled pragmatism and rationalization.

**(b) vsdd has:**
`docs/AGENT-SOUL.md` section 8 "Pragmatism Over Ceremony" (lines 97-122) includes a 24-line footnote that explicitly distinguishes:
- **Principled pragmatism** -- design-time, human-in-the-loop, documented, survives adversarial review
- **Rationalization** -- execution-time, no human, skips applicable rules

It names the specific attack vector: "I'm just being pragmatic" as a first-class pressure from the superpowers Pressure Taxonomy (Meincke et al. 2025, N=28000, compliance 33% -> 72%).

**(c) gap:** Without this footnote, a secops agent can rationalize skipping cognitive bias checks ("I'm just being pragmatic, this is a simple FP") or multi-factor assessment ("CVSS 9.8 is obviously P1, being pragmatic here"). These are exactly the scenarios secops-factory's Red Flags tables warn about, but the SOUL document doesn't close the loop.

**(d) fix:** Add a footnote to section 10 "Convergence Over Perfection" that distinguishes principled pragmatism from rationalization, adapted for secops domain. Example: "Skipping the cognitive bias audit because 'this one is obvious' is rationalization, not pragmatism. Documenting that a P5 informational CVE doesn't need full ATT&CK mapping with human approval is pragmatism."

**File:** `docs/AGENT-SOUL.md`

### P1-8: No step-file decomposition for complex skills

**(a) secops has:**
Complex multi-stage skills (enrich-ticket: 8 stages, investigate-event: 7 stages) have all steps inline in a single SKILL.md file.

**(b) vsdd has:**
Complex skills like brownfield-ingest use sub-phases (Phase A, B, B.5, B.6, C, D) with detailed round-prompt templates. The deliver-story skill delegates to `agents/orchestrator/per-story-delivery.md` for the canonical step sequence. Some vsdd skills use `steps/` subdirectories for decomposed step files.

**(c) gap:** The secops skills are already well-structured but could benefit from extracting the checklist-execution logic for review-enrichment into a step file, since the 8-dimension and 7-dimension rubrics are substantial. The current inline approach works but is harder to maintain and test independently.

**(d) fix:** Consider extracting to step files only if the skills grow significantly. Current size (50-120 lines) is manageable inline. Lower priority than P1-1 through P1-7.

**Files:** Potential future: `skills/review-enrichment/steps/cve-rubric.md`, `skills/review-enrichment/steps/event-rubric.md`

---

## P2 -- Worth considering

### P2-1: Workflow files (.lobster equivalents)

vsdd-factory has 15 `.lobster` workflow files in `workflows/` and `workflows/phases/` that define the pipeline graph as YAML data. The orchestrator agent reads these as structured data, not prose.

secops-factory has no workflow files. The enrichment and investigation pipelines are described in prose within skill SKILL.md files and agent files.

**Trade-off:** .lobster files add a parsing dependency (vsdd has `bin/lobster-parse`) and a maintenance surface. For secops-factory's simpler pipeline (enrichment -> review -> update is linear, not a DAG), workflow files may be over-engineering. Worth adopting only if secops grows to support configurable pipelines (e.g., different enrichment workflows for different ticket types).

### P2-2: bin/ helper scripts

vsdd-factory has 4 bin helpers: `lobster-parse`, `multi-repo-scan`, `research-cache`, `wave-state`. These are testable shell scripts that provide reusable pipeline infrastructure.

secops-factory has no bin/ directory. Potential candidates: a `secops-health` shell script (currently a command.md), a `jira-field-mapper` script for custom field ID resolution, or a `metric-aggregator` for the generate-metrics skill.

**Trade-off:** bin/ scripts are more testable than inline logic but add maintenance. Worth it for `secops-health` (should be a real script, not a prose command).

### P2-3: Security-reviewer agent has Write tool

`agents/security-reviewer.md` line 8 grants the `Write` tool. In vsdd-factory, the adversary agent (`agents/adversary.md` line 3) has only `Read, Grep, Glob` -- no Write, no Bash. This is intentional: the adversary should not modify artifacts, only read and report.

If secops's security-reviewer is meant to be a pure reviewer (matching the information asymmetry principle), it should not have Write access. Review findings should be returned inline to the dispatcher (adversarial-review-secops skill), which writes them.

**Trade-off:** The reviewer currently writes review reports directly. Removing Write means adopting the inline delivery protocol (P1-4). This is a philosophical choice: tighter isolation vs simpler workflow.

### P2-4: Factory worktree pattern and state tracking

vsdd-factory uses `.factory/` as a git worktree on an orphan branch for pipeline state. secops-factory has no `.factory/` directory (just created one for this analysis) and no STATE.md or pipeline state management.

**Trade-off:** secops-factory is a plugin, not a full pipeline. It doesn't need per-story worktrees or wave-based delivery. However, it could benefit from tracking enrichment history (which tickets were enriched, review scores, convergence history) in a `.factory/`-like structure for the generate-metrics skill.

### P2-5: Model routing in agent frontmatter

vsdd-factory agents use explicit model routing: `model: opus` for adversary/judgment, `model: sonnet` for implementation. secops-factory does the same (security-analyst: sonnet, security-reviewer: opus), which is correct. No gap here, but worth documenting the rationale in AGENT-SOUL.md (cognitive diversity is not a cost optimization).

### P2-6: `disable-model-invocation: true` for dispatcher skills

vsdd's `deliver-story` and `wave-gate` use `disable-model-invocation: true` to prevent the skill from doing any LLM work itself -- it can only dispatch and coordinate. secops's adversarial-review-secops does not use this flag. If the adversarial-review skill should be a pure dispatcher (it dispatches security-reviewer), adding this flag would enforce that discipline.

---

## P3 -- Intentional divergences to document

### P3-1: Two agents instead of 30+

secops-factory has 2 agents (security-analyst, security-reviewer). vsdd-factory has 34 agents. This is an intentional and correct divergence: secops has two domain roles (analyst and reviewer), while vsdd has a full SDLC with many specialist roles. Document this in AGENT-SOUL.md: "Two agents is the correct count for this domain. Adding agents should only happen when a new role with genuinely different judgment and information access is needed."

### P3-2: Domain-specific quality rubrics instead of generic convergence dimensions

secops uses 8-dimension CVE rubrics and 7-dimension weighted event rubrics. vsdd uses 5-dimensional convergence (Spec, Tests, Implementation, Verification, Holdout). These are domain-appropriate specializations of the same pattern. No change needed.

### P3-3: No TDD cycle or code delivery pipeline

secops-factory doesn't write code. It enriches security tickets and investigates events. The TDD cycle, Red Gate, worktrees, and PR management from vsdd are not applicable. This is correct.

### P3-4: Checklist-driven review instead of adversarial free-form

secops's review process is checklist-driven (15 checklists across 2 rubrics). vsdd's adversary does free-form attack-surface review. Both are valid for their domains: checklists ensure completeness in structured security analysis; free-form review catches emergent issues in software design. secops's approach is more auditable and reproducible, which is important for security operations.

### P3-5: JIRA-centric workflow vs filesystem-centric

secops uses JIRA as the primary artifact store (enrichments posted as comments, fields updated). vsdd uses the filesystem (.factory/) as working memory. This is correct for each domain: security operations lives in ticketing systems; software development lives in code repositories.

### P3-6: Perplexity tool tiering by severity

secops's research-cve skill (lines 30-36) selects Perplexity tool tier based on CVSS severity: research for 9.0+, reason for 7.0-8.9, search for <7.0. vsdd doesn't do severity-based tool selection. This is a smart secops-specific optimization.

---

## Appendix: file-by-file change list

### P0 fixes (structural, must-fix)

| Priority | File | Action |
|----------|------|--------|
| P0-1 | `hooks/hooks.json` | Rewrite to nested matcher format with `${CLAUDE_PLUGIN_ROOT}/` paths |
| P0-2 | `hooks/require-review.sh` | Rewrite to emit `permissionDecision` envelope, replace python3 with jq |
| P0-2 | `hooks/enrichment-completeness.sh` | Rewrite to emit `permissionDecision` envelope, replace python3 with jq |
| P0-3 | `hooks/bias-check-reminder.sh` | Replace python3 with jq (advisory hook, no envelope change needed) |

### P1 fixes (high-ROI)

| Priority | File | Action |
|----------|------|--------|
| P1-1 | `skills/review-enrichment/SKILL.md` | Add `context: fork` to frontmatter |
| P1-2 | `agents/orchestrator/enrichment-workflow.md` | New file: canonical 8-stage enrichment sequence |
| P1-2 | `agents/orchestrator/investigation-workflow.md` | New file: canonical 7-stage investigation sequence |
| P1-2 | `agents/orchestrator/review-convergence-workflow.md` | New file: canonical adversarial review loop |
| P1-3 | `skills/adversarial-review-secops/SKILL.md` | Add honest convergence clause and hallucination classes |
| P1-4 | `skills/adversarial-review-secops/SKILL.md` | Add subagent delivery protocol section |
| P1-5 | `tests/skills.bats` | Add template/data/checklist existence tests, non-portable path test |
| P1-5 | `tests/hooks.bats` | Add permissionDecision envelope format tests |
| P1-5 | `tests/agents.bats` | New file: agent frontmatter structural tests |
| P1-6 | `hooks/handoff-validator.sh` | New file: port from vsdd, validates SubagentStop output |
| P1-6 | `hooks/disposition-guard.sh` | New file: blocks disposition without Alternatives Considered |
| P1-6 | `hooks/hooks.json` | Add SubagentStop and new PreToolUse entries |
| P1-7 | `docs/AGENT-SOUL.md` | Add pragmatism vs rationalization footnote to section 10 |

# Hooks Reference

SecOps Factory uses 6 hooks to enforce quality gates automatically. Hooks fire on specific tool invocations and cannot be bypassed.

Every hook ships as a `.sh`/`.ps1` sibling pair with identical behavior — see [Cross-Platform Support](#cross-platform-support).

## session-greeting

| Property | Value |
|----------|-------|
| Type | SessionStart |
| Trigger | Session startup |
| Scripts | `hooks/session-greeting.sh` / `.ps1` |
| Blocking | No |

**What it does:** When the SecOps Factory orchestrator is the project's default agent (set by `/secops-factory:activate`), displays Morgan's greeting banner with the workflow menu the moment a session starts — before the analyst types anything — and injects context so Morgan's first reply continues in-flow instead of re-introducing itself.

**Why:** The companion should greet the analyst, not wait to be greeted. A deterministic banner costs zero tokens and appears instantly.

**When it triggers:** Session startup, only in projects where `.claude/settings.local.json` sets `agent` to `secops-factory:orchestrator:orchestrator`. In every other project it is a silent no-op — enabling the plugin alone never greets (no hijack-on-enable).

## require-review

| Property | Value |
|----------|-------|
| Type | PreToolUse |
| Trigger | Bash commands containing `jr issue edit`, `jr issue move`, `jr issue assign`, `jr issue create` |
| Scripts | `hooks/require-review.sh` / `.ps1` |
| Blocking | Yes |

**What it enforces:** Blocks JIRA field updates unless a review-approval marker is present. Comment-only operations (posting enrichment text) are allowed. Field updates (CVSS, priority, KEV status) are blocked until `/secops-factory:review-enrichment` has been run and the analysis passes quality thresholds.

**Why:** JIRA field updates represent the official record. Posting unvalidated analysis as authoritative creates false confidence in incomplete or incorrect data.

**When it triggers:** Every Bash command containing `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`. Read-only commands (`jr issue view`, `jr issue list`, `jr issue comments`) and `jr issue comment` (posting results) are allowed without review.

**How to satisfy it:** Run `/secops-factory:review-enrichment <ticket-id>` before `/secops-factory:update-jira <ticket-id>`. The review skill sets the approval marker when quality thresholds are met.

## enrichment-completeness

| Property | Value |
|----------|-------|
| Type | PreToolUse |
| Trigger | `Write` |
| Scripts | `hooks/enrichment-completeness.sh` / `.ps1` |
| Blocking | Yes |

**What it enforces:** Blocks saving enrichment or investigation documents that are missing required sections. For enrichment documents, checks for: Executive Summary, Vulnerability Details, Severity Metrics, Priority Assessment, Remediation Guidance. For investigation documents, checks for: Executive Summary, Alert Details, Disposition, Next Actions.

**Why:** Partial enrichment saved as complete creates false confidence. The Iron Law requires all stages to complete before saving.

**When it triggers:** Every call to the `Write` tool where the file path contains "enrichment" or "investigation".

**How to satisfy it:** Complete all stages of the enrichment or investigation workflow before saving. The required sections are populated automatically by the skill workflows.

## disposition-guard

| Property | Value |
|----------|-------|
| Type | PreToolUse |
| Trigger | `Write` |
| Scripts | `hooks/disposition-guard.sh` / `.ps1` |
| Blocking | Yes |

**What it enforces:** Blocks writing an investigation document that contains a Disposition section but no "Alternatives Considered" section. A disposition (TP/FP/BTP) requires at least 2 documented alternative hypotheses with supporting and contradicting evidence.

**Why:** A disposition without documented alternatives is vulnerable to confirmation bias — the analyst may have locked onto the first hypothesis without genuinely considering other explanations.

**When it triggers:** Every `Write` where the file path contains "investigation" and the content contains a disposition. In-progress writes without a disposition are allowed.

**How to satisfy it:** Document alternative hypotheses before finalizing the disposition. See the investigate-event skill, Stage 4: Hypothesis Formation.

## bias-check-reminder

| Property | Value |
|----------|-------|
| Type | PostToolUse |
| Trigger | Bash and all `mcp__perplexity__*` research tools |
| Scripts | `hooks/bias-check-reminder.sh` / `.ps1` |
| Blocking | No |

**What it enforces:** After every research query, displays a non-blocking reminder to check for cognitive biases when interpreting results: confirmation bias, anchoring bias, availability bias, and automation bias.

**Why:** Research results are most dangerous at the moment of interpretation — the analyst may unconsciously seek confirming evidence, anchor to the first metric found, or over-weight recent incidents. The reminder interrupts automatic processing.

**When it triggers:** After every Bash command and every Perplexity research call.

## handoff-validator

| Property | Value |
|----------|-------|
| Type | SubagentStop |
| Trigger | Any subagent completing |
| Scripts | `hooks/handoff-validator.sh` / `.ps1` |
| Blocking | No (SubagentStop hooks cannot block) |

**What it enforces:** Warns when a subagent (especially the security-reviewer) returns empty or suspiciously short output.

**Why:** An empty reviewer return is the #1 silent failure mode in adversarial convergence loops — it silently counts as "no findings" when the reviewer actually crashed, hit a sandbox denial, or exhausted context. The warning forces a re-run instead.

**When it triggers:** Every SubagentStop event where the result is empty or under 40 characters.

## Cross-Platform Support

Hooks run on macOS, Linux, WSL, Git Bash, and native Windows:

- **Every hook is a `.sh`/`.ps1` sibling pair.** The PowerShell siblings use built-in `ConvertFrom-Json`/`ConvertTo-Json` — no `jq` dependency on Windows. JSON envelopes, warning text, and exit codes are identical between siblings, enforced by the parity test suite (`tests/parity.bats`, runs in CI where PowerShell Core is available).
- **Two `hooks.json` variants ship with the plugin.** The committed default invokes the `.sh` scripts and works out of the box on macOS, Linux, WSL, and Git-Bash-on-Windows. `hooks.json.windows` invokes the `.ps1` siblings via `powershell.exe -NoProfile -ExecutionPolicy Bypass` and is copied into place by `/secops-factory:activate` when it detects a native Windows host.
- **On Unix hosts, `jq` is required for the blocking hooks** (they emit a visible non-blocking error and fail open if it's missing). `/secops-factory:secops-health` checks for it.
- **After a plugin update on native Windows**, re-run `/secops-factory:activate` — updates restore the default `hooks.json`.

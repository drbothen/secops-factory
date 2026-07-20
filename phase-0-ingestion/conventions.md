# Conventions: secops-factory

> Extracted by Dark Factory Phase 0c (Convention Extraction). Agent: consistency-validator.
> Source codebase: `plugins/secops-factory/` (v0.9.0)
> Date: 2026-07-19
> Files sampled: 28 (skills: 4, commands: 3, agents: 4, hooks: 4, tests: 3, templates: 2, rules: 1, CI: 1, manifests: 2, CHANGELOG/RELEASING: 2, checklists: 1, data KBs: 1)

**Note on scope:** This is a declarative Claude Code plugin — there is no compiled or interpreted application code. Conventions are documentation/plugin conventions, not code style: markdown structure patterns, naming, hook script patterns, test patterns, and commit/release hygiene.

---

## Naming Conventions

### Skill Directory Names

| Convention | Pattern | Frequency | Examples |
|-----------|---------|-----------|----------|
| Dominant | kebab-case directory under `skills/` | 20/20 skills | `enrich-ticket/`, `research-cve/`, `adversarial-review-secops/`, `analyze-ticket-effort/`, `review-enrichment/` |
| Entry file name | uppercase `SKILL.md` within each directory | 20/20 skills | `skills/enrich-ticket/SKILL.md`, `skills/create-advisory/SKILL.md`, `skills/activate/SKILL.md` |

### Command File Names

| Convention | Pattern | Frequency | Examples |
|-----------|---------|-----------|----------|
| Dominant | kebab-case `<name>.md` under `commands/` | 20/20 commands | `enrich-ticket.md`, `research-cve.md`, `adversarial-review-secops.md` |
| Match rule | command name MUST match skill directory name exactly | 20/20 | `secops-health.md` now has a matching `skills/secops-health/SKILL.md` (added PR #16, DI-002); the CI carve-out for this command was removed |

### Agent File Names

| Convention | Pattern | Frequency | Examples |
|-----------|---------|-----------|----------|
| Specialist agents | kebab-case `.md` directly under `agents/` | 5/5 specialists | `security-analyst.md`, `security-reviewer.md`, `metrics-analyst.md`, `osint-researcher.md`, `advisory-writer.md` |
| Orchestrator | `agents/orchestrator/` subdirectory with `orchestrator.md` + workflow sidecar files | 1 orchestrator | `agents/orchestrator/orchestrator.md`, `enrichment-workflow.md`, `investigation-workflow.md`, `review-convergence-workflow.md` |
| Workflow sidecar names | kebab-case `<pipeline>-workflow.md` | 3/3 workflows | `enrichment-workflow.md`, `investigation-workflow.md`, `review-convergence-workflow.md` |

### Hook Script Names

| Convention | Pattern | Frequency | Examples |
|-----------|---------|-----------|----------|
| Dominant | kebab-case `<name>.sh` + `<name>.ps1` sibling pair under `hooks/` | 6/6 hook pairs | `require-review.sh`/`.ps1`, `enrichment-completeness.sh`/`.ps1`, `session-greeting.sh`/`.ps1` |
| Exception | No `.sh`-only or `.ps1`-only hooks exist; pairs are mandatory | 0 exceptions | Enforced by CI `structure` job |

### Template File Names

| Convention | Pattern | Frequency | Examples |
|-----------|---------|-----------|----------|
| YAML templates | `<domain>-tmpl.yaml` | 5/6 templates | `security-enrichment-tmpl.yaml`, `event-investigation-tmpl.yaml`, `security-review-report-tmpl.yaml`, `effort-priors-tmpl.yaml` |
| Markdown templates | `<domain>-tmpl.md` | 1/6 templates | `security-advisory-tmpl.md` |

### Data Knowledge Base File Names

| Convention | Pattern | Frequency | Examples |
|-----------|---------|-----------|----------|
| Dominant | kebab-case `<topic>-guide.md` or `<topic>-<type>.md` | 10/10 KBs | `cvss-guide.md`, `epss-guide.md`, `kev-catalog-guide.md`, `cognitive-bias-patterns.md`, `event-investigation-best-practices.md`, `jira-metrics-recipes.md` |

### Checklist File Names

| Convention | Pattern | Frequency | Examples |
|-----------|---------|-----------|----------|
| CVE enrichment checklists | `<dimension>-checklist.md` | 8 | `completeness-checklist.md`, `technical-accuracy-checklist.md`, `actionability-checklist.md`, `source-citation-checklist.md` |
| Event investigation checklists | `investigation-<dimension>-checklist.md` | 7 | `investigation-completeness-checklist.md`, `investigation-cognitive-bias-checklist.md`, `disposition-reasoning-checklist.md` |

### Test File Names

| Convention | Pattern | Frequency | Examples |
|-----------|---------|-----------|----------|
| BATS test suites | `<suite>.bats` under `tests/` | 4/4 suites | `hooks.bats`, `skills.bats`, `integration.bats`, `parity.bats` |
| Test runner | `run-all.sh` orchestrator | 1 | `tests/run-all.sh` |

---

## Frontmatter Schemas

### SKILL.md Frontmatter

Required fields for every skill:

| Field | Type | Notes | Evidence |
|-------|------|-------|----------|
| `name` | string | kebab-case, matches directory name | `skills/enrich-ticket/SKILL.md:2`, `skills/research-cve/SKILL.md:2` |
| `description` | string | Quoted; starts with "Use when..." | `skills/enrich-ticket/SKILL.md:3`, `skills/research-cve/SKILL.md:3` |
| `argument-hint` | string | Optional; present when skill accepts args (e.g., `<ticket-id>`) | `skills/enrich-ticket/SKILL.md:4`, `skills/research-cve/SKILL.md:4` |
| `disable-model-invocation` | boolean | Optional; set to `true` for user-only skills | `skills/activate/SKILL.md` — activate is user-only |

### Agent Frontmatter

Required fields for every agent (specialist and orchestrator):

| Field | Type | Notes | Evidence |
|-------|------|-------|----------|
| `name` | string | kebab-case, matches file/directory name | `agents/security-analyst.md:2`, `agents/orchestrator/orchestrator.md` |
| `description` | string | Quoted; "Use when..." trigger condition | `agents/security-analyst.md:3` |
| `model` | string | `sonnet` or `opus` — reviewer uses `opus` for cognitive diversity | `agents/security-analyst.md:4` (sonnet), `agents/security-reviewer.md` (opus) |
| `color` | string | Color label for the agent (arbitrary string) | `agents/security-analyst.md:5` (blue) |
| `tools` | list | Explicit tool allowlist; reviewer omits `Write` | `agents/security-analyst.md:6-17`, `agents/security-reviewer.md` |

### Command `.md` Frontmatter

Required fields for every command wrapper:

| Field | Type | Notes | Evidence |
|-------|------|-------|----------|
| `description` | string | Quoted one-line description | `commands/enrich-ticket.md:2` |
| `argument-hint` | string | Optional; present when command accepts args | `commands/enrich-ticket.md:3` |

**Command body is always:** `Use the \`secops-factory <name>\` skill via the Skill tool.\n\nArguments: $ARGUMENTS`

---

## SKILL.md Section Ordering (Iron Laws pattern)

Every SKILL.md (except thin utility skills) follows this canonical section order. The structure is enforced by BATS tests in `skills.bats`:

| Order | Section | Required? | Rule | Evidence |
|-------|---------|-----------|------|----------|
| 1 | H1 heading with human-readable title | Yes | Title text (not skill name) | `skills/enrich-ticket/SKILL.md:8` |
| 2 | **The Iron Law** (H2) | Yes for workflow skills | Blockquote: `> **NO [ACTION] WITHOUT [PREREQUISITE] FIRST**` | `skills/enrich-ticket/SKILL.md:12-14`, `skills.bats:9-27` |
| 3 | **Announce at Start** (H2) | Yes | Verbatim text: `> I am using the <skill> skill to...` | `skills/enrich-ticket/SKILL.md:18-22`, `skills.bats:35-56` |
| 4 | **Red Flags** (H2) | Yes, minimum 6 rows | Two-column table: `\| Thought \| Reality \|` with ≥6 cognitive-bias trap rows | `skills/enrich-ticket/SKILL.md:24-34`, `skills.bats:61-90` |
| 5 | **Prerequisites** (H2) | Optional | Bullet list of runtime dependencies | `skills/enrich-ticket/SKILL.md:36-42` |
| 6 | **Workflow** (H2) | Yes | Numbered stages with `### Stage N: <Name> (time estimate)` subsections | `skills/enrich-ticket/SKILL.md:44-114` |
| 7 | **References** (H2) | Yes for data-consuming skills | `${CLAUDE_PLUGIN_ROOT}/` paths to data, templates, checklists | `skills/enrich-ticket/SKILL.md:116-126` |

**Iron Law vocabulary:** Iron Laws follow the form `NO <VERB PHRASE> WITHOUT <PREREQUISITE> FIRST`. Examples:
- `NO JIRA UPDATE WITHOUT COMPLETED ENRICHMENT FIRST`
- `NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST`
- `NO APPROVAL WITHOUT FRESH-CONTEXT REVIEW FIRST`
- `NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST`
- `NO EFFORT REPORT WITHOUT STATED BIASES FIRST`

---

## Hook Script Conventions

### Bash Hook Pattern (`*.sh`)

| Convention | Detail | Evidence |
|-----------|--------|----------|
| Shebang | `#!/usr/bin/env bash` | require-review.sh (shebang), `hooks/enrichment-completeness.sh:1` |
| Error mode | `set -euo pipefail` | require-review.sh (`set -euo pipefail`), `hooks/enrichment-completeness.sh:11` |
| jq guard | Check `command -v jq` at top; write error to stderr; exit 1 | jq-availability guard in require-review.sh, `hooks/enrichment-completeness.sh:13-16` |
| Input ingestion | `INPUT=$(cat)` — read full stdin once | require-review.sh (`INPUT=$(cat)` — stdin ingestion) |
| Allow function name | `emit_allow()` — prints JSON envelope, exits 0 | emit_allow in require-review.sh (exit 0), `hooks/enrichment-completeness.sh:20-23` (exit 0 at line 22) |
| Deny function name | `emit_deny()` — takes reason arg, prints JSON via `jq -nc`, exits 0 | emit_deny in require-review.sh (exit 0), `hooks/enrichment-completeness.sh:25-35` (exit 0 at line 34) |
| Fast path ordering | **Non-jr fast-path FIRST** (emit allow), then **write-block SECOND** (emit deny), then read-only allowlist THIRD (emit allow), then fail-closed fallthrough LAST (emit deny). **CRITICAL:** write-block must be evaluated BEFORE the allowlist to prevent bypass via allowlist tokens embedded in write-command arguments (ADV-0-801/PR #15 — the old allow-first order was a CRITICAL vulnerability). | fast-path guard (emit_allow non-jr), write-block if-block (emit_deny), read-only allowlist (emit_allow), fail-closed catch-all (emit_deny) — all in require-review.sh |
| Fail-open for non-jr inputs | Non-jr commands take fast-path `emit_allow` immediately; unrecognized `jr` subcommands `emit_deny` (fail-CLOSED, SEC-002, PR #13) — prevents future jr write subcommands from bypassing the gate | fast-path guard (allow) and fail-closed catch-all (deny) in require-review.sh |
| Advisory hooks | Write to stderr only; always exit 0; never emit `permissionDecision` JSON | `hooks/bias-check-reminder.sh`, `hooks/handoff-validator.sh` |

### PowerShell Hook Pattern (`*.ps1`)

| Convention | Detail | Evidence |
|-----------|--------|----------|
| Error mode | `$ErrorActionPreference = 'Stop'` | `hooks/require-review.ps1:11` |
| No jq guard | PowerShell uses built-in `ConvertFrom-Json` / `ConvertTo-Json` | `hooks/require-review.ps1:31-32` |
| Allow function name | `Emit-Allow` (PascalCase verb-noun) | `hooks/require-review.ps1:13` |
| Deny function name | `Emit-Deny([string]$Reason)` (PascalCase) | `hooks/require-review.ps1:17` |
| Fail-safe input parsing | `try { $payload = $raw \| ConvertFrom-Json } catch { Emit-Allow }` — JSON parse failure falls back to allow | `hooks/require-review.ps1:32` |
| JSON output | `ConvertTo-Json -Compress -Depth 5` | `hooks/require-review.ps1:25` |
| Behavioral parity | Identical JSON output structure and exit codes to the `.sh` sibling — enforced by `parity.bats` | `tests/parity.bats:51-143` |

### Hook Exit Code Semantics

| Exit code | Meaning | When used |
|-----------|---------|-----------|
| 0 | Success (regardless of allow/deny decision) | Always — hooks never exit non-zero for business logic |
| 1 | Fatal infrastructure error (e.g., `jq` missing) | Dependency check failure only |

### JSON Envelope Format

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow" | "deny",
    "permissionDecisionReason": "<string, only when denying>"
  }
}
```

SessionStart hooks use `systemMessage` and `additionalContext` fields instead of `permissionDecision`.

---

## Test Conventions (BATS)

### Framework and Runner

| Property | Value | Evidence |
|----------|-------|----------|
| Test framework | `bats-core` | `tests/run-all.sh`, `ci.yml:24` |
| Test runner | `tests/run-all.sh` (orchestrates all suites + syntax checks) | `tests/run-all.sh` |
| Coverage tool | None | — |
| Prerequisites | `bash -n` (syntax check), `python3 -c "import yaml"`, optional `pwsh` for parity tests | `tests/run-all.sh` |

### Organization

| Property | Value | Evidence |
|----------|-------|----------|
| Test location | Separate `tests/` directory | `plugins/secops-factory/tests/` |
| Suite separation | One `.bats` file per concern: hooks, skills, integration, parity | `tests/hooks.bats`, `tests/skills.bats`, `tests/integration.bats`, `tests/parity.bats` |
| Fixtures | Inline fixtures via `$(mktemp -d)` temp dirs | `@test "session-greeting is silent when settings.local.json is absent"` (`hooks.bats` ~:278); `setup_greeting_project` helper (just before session-greeting group) |
| Group headers | `# --- <hook-name> hook ---` comment blocks within a `.bats` file | first test in each group: `@test "require-review allows non-jr commands"` (~:9), `@test "enrichment-completeness allows non-enrichment files"` (~:185), `@test "bias-check-reminder exits 0"` (~:207), `@test "handoff-validator warns on empty result"` (~:226), `@test "disposition-guard allows non-investigation files"` (~:246), `@test "session-greeting is silent when settings.local.json is absent"` (~:278) |

### Test Naming Convention

```bats
@test "<component>: <action> <condition>" {
    run ...
    [ "$status" -eq 0 ]
    [[ "$output" == *"<expected>"* ]]
}
```

Examples:
- `@test "require-review allows non-jr commands"` (`hooks.bats`, group start ~:9)
- `@test "enrichment-completeness blocks incomplete enrichment"` (`hooks.bats`, enrichment-completeness group)
- `@test "session-greeting is silent when settings.local.json is absent"` (`hooks.bats`, session-greeting group ~:278)
- `@test "parity: require-review allow path"` (`parity.bats:51`)

**Pattern:** `<component-name> <verb> <condition>` — plain English, no underscores in test names (space-separated)

### Assertion Style

- **Explicit status check:** always `[ "$status" -eq 0 ]`
- **Output content:** `[[ "$output" == *"<substring>"* ]]` for content assertions
- **JSON key:** `[[ "$output" == *'"permissionDecision":"allow"'* ]]` — exact JSON substring including quotes
- **Negative assertion:** `[ -z "$output" ]` for silence assertions
- **Structural assertion:** `grep -qF "pattern" file` for content presence
- **Count assertion:** `count=$(grep -c 'pattern' file || true)` + `[ "$count" -ge N ]`
- No snapshot tests. No property tests. No mock libraries.

### Parity Test Pattern

The `parity.bats` suite enforces cross-platform behavioral identity:

```bats
@test "parity: <hook-name> <scenario>" {
    require_pwsh   # skip gracefully if pwsh absent
    run_pair <hook-name> '<json-payload>'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json   # diff normalized JSON output
}
```

`assert_same_json` normalizes output via `jq -S .` before diffing (key-order independent).

---

## Path Conventions

All internal resource references inside skill/agent files use the `${CLAUDE_PLUGIN_ROOT}` variable. This is mandatory — never hardcoded absolute paths:

| Resource type | Path pattern | Evidence |
|--------------|-------------|----------|
| Templates | `${CLAUDE_PLUGIN_ROOT}/templates/<name>` | `skills/enrich-ticket/SKILL.md:101,124` |
| Data KBs | `${CLAUDE_PLUGIN_ROOT}/data/<name>.md` | `skills/enrich-ticket/SKILL.md:117-123`, `agents/security-analyst.md:135-147` |
| Checklists | `${CLAUDE_PLUGIN_ROOT}/checklists/<name>.md` | `skills/enrich-ticket/SKILL.md:125-126` |
| Orchestrator workflows | `${CLAUDE_PLUGIN_ROOT}/agents/orchestrator/<workflow>.md` | `agents/orchestrator/orchestrator.md` |

Runtime artifact paths (never committed):
- `artifacts/enrichments/enrichment-<CVE-ID>.md`
- `artifacts/reviews/review-<ticket-id>.md`
- `artifacts/investigations/investigation-<ticket-id>.md`
- `artifacts/metrics/kpi-<period>-<date>.md`

---

## Commit and PR Conventions

### Commit Message Format

Conventional Commits. Two acceptable prefixes:

| Prefix | When | Examples |
|--------|------|---------|
| `feat(<scope>):` | New skill, agent, template, or hook | `feat(metrics): concrete recipes for all Jira ground-truth metrics` |
| `chore:` | Release, maintenance, version bumps | `chore: release v0.9.0 — Jira metrics recipes` |
| `docs:` | Documentation-only | `docs: add RELEASING.md — canonical release procedure` |
| `ci:` | GitHub Actions workflow changes | CI hardening commits |
| `secops(<scope>):` | Plugin-content commits (per `rules/secops-protocol.md`) | Scopes: skills, agents, data, templates, checklists, hooks, tests, docs |
| `fix(<scope>):` | Bug fixes | `fix: docs/guide/hooks-reference.md stale content` |

**Critical:** No Co-Authored-By or AI attribution in any commit.

### PR and Branch Conventions

| Convention | Detail | Evidence |
|-----------|--------|----------|
| Every change via PR | No direct push to `main` — blocked by `verify-git-push` hook on operator machines | `RELEASING.md:17-19` |
| Squash merge only | `gh pr merge <N> --squash --delete-branch` | `RELEASING.md:109` |
| Feature branches | `feat/*` or `docs/*` | `project-discovery.md §5` |
| Release branches | `release/vX.Y.Z` | `RELEASING.md:82` |
| Release commit message | `chore: release vX.Y.Z — <one-line summary>` | `RELEASING.md:15`, `git log` |

---

## Versioning Conventions

### Triple Version Lock

All three must match for a release to be valid. Validated by `release.yml`:

| File | Field | Path |
|------|-------|------|
| Plugin manifest | `.version` | `plugins/secops-factory/.claude-plugin/plugin.json` |
| Marketplace manifest | `.plugins[0].version` | `.claude-plugin/marketplace.json` |
| Git tag | tag name | `vX.Y.Z` — cut AFTER squash-merge on the merge commit |

### CHANGELOG Format

Keep-a-Changelog v1.1.0 + SemVer v2.0.0:

```markdown
## [X.Y.Z] - YYYY-MM-DD

One-line summary of the release (directly under heading — required by release.yml for release notes extraction).

### Added
- **Feature name** — description

### Changed
- description

### Fixed
- description
```

`## [Unreleased]` section is the staging area for in-progress changes.

### SemVer Rules (from RELEASING.md)

- MAJOR: breaking changes
- MINOR: any `feat` (new skill, agent, template)
- PATCH: fix-only releases

---

## CI Conventions (`.github/workflows/ci.yml`)

| Convention | Detail | Evidence |
|-----------|--------|----------|
| SHA-pinned actions | `actions/checkout@<full-SHA> # vN` (version in comment) | `ci.yml:14` |
| Timeout | `timeout-minutes: 10` on every job | `ci.yml:12,32,104` |
| Factory-artifacts mount | First step after checkout in every job: `git fetch origin factory-artifacts && git worktree add .factory origin/factory-artifacts` | `ci.yml:17-20` |
| Three CI jobs | `test` (BATS), `structure` (jq + structural validation), `shellcheck` | `ci.yml:9,29,100` |
| Hook parity check | CI `structure` job verifies every `.sh` has a `.ps1` sibling | `ci.yml:51-60` |
| Skill completeness check | CI verifies every skill dir has `SKILL.md`; every command has matching skill dir | `ci.yml:62-85` |

---

## Documentation Style (Markdown)

### Doc Comment Format

No formal doc-comment syntax exists in this codebase. Instead:

| Document type | Structure |
|--------------|-----------|
| SKILL.md | Structured sections (Iron Law, Announce at Start, Red Flags, Workflow, References) |
| Agent `.md` | Persona description + domain expertise + workflow patterns + references |
| Checklist `.md` | Markdown checkbox list (`- [ ] item`) — no frontmatter |
| Template (YAML) | Comment block at top explaining purpose; `template:` + `sections:` structure |
| Data KB `.md` | H1 title + H2 section headers; no frontmatter |
| `hooks.json` | No comments (pure JSON); comment in the parallel `.sh` file's header block |

### Hook Header Comment Block

Every `.sh` hook has a multi-line comment block immediately after the shebang:

```bash
#!/usr/bin/env bash
# <filename>.sh — <one-line purpose>
#
# <when it fires / what it watches for>
#
# Emits a <EventName> JSON envelope with permissionDecision.
# Deterministic, <100ms, no LLM.
```

### File Size Norms

| Component | Median | Largest | Smallest |
|-----------|--------|---------|----------|
| SKILL.md | ~77 lines | `skills/create-advisory/SKILL.md` (169 lines) | `skills/deactivate/SKILL.md` (44 lines) |
| Agent `.md` | ~98 lines | `agents/security-reviewer.md` (184 lines) | `agents/orchestrator/enrichment-workflow.md` (42 lines) |
| Command `.md` | ~8 lines | `commands/secops-health.md` (53 lines — formerly anomaly: no matching skill; resolved in PR #16) | 8 lines (standard wrapper) |
| Hook `.sh` | ~50 lines | `hooks/session-greeting.sh` | `hooks/bias-check-reminder.sh` |
| Data KB | ~1000 lines | `data/event-investigation-best-practices.md` (~3027 lines — chunked-read flag) | `data/priority-framework.md` |
| BATS suite | ~175 lines | `tests/skills.bats` (471 lines) | `tests/parity.bats` (144 lines) |

Files over ~1000 lines require chunked reading (500-line chunks via Read tool offset) — documented in `agents/security-analyst.md:154-168`.

---

## Summary for Agents

### MUST Follow (Dominant Conventions)

1. **Skill directory and file names:** `skills/<kebab-case-name>/SKILL.md` — SCREAMING caps for the entry file, kebab-case for the directory.
2. **SKILL.md section order:** Iron Law → Announce at Start → Red Flags (≥6 rows) → Prerequisites → Workflow (staged) → References. Do not omit Iron Law or Announce at Start from workflow skills.
3. **Iron Law vocabulary:** `NO <ACTION> WITHOUT <PREREQUISITE> FIRST` inside a blockquote.
4. **Red Flags format:** Two-column table `| Thought | Reality |` with the first column being a quoted cognitive-bias thought and the second being the corrective reality.
5. **Path references:** Always use `${CLAUDE_PLUGIN_ROOT}/` prefix — never hardcoded paths.
6. **Command wrappers:** Thin — body is always `Use the \`secops-factory <name>\` skill via the Skill tool.\n\nArguments: $ARGUMENTS`.
7. **Hook parity:** Every `.sh` hook must have a `.ps1` sibling with identical JSON output structure and exit codes.
8. **Hook exit codes:** Exit 0 always for business logic (allow and deny alike). Exit 1 only for missing infrastructure (jq absent).
9. **Hook fail-open/fail-closed scoping:** Non-jr commands always emit allow (fast-path). Advisory hooks (bias-check-reminder, handoff-validator, session-greeting) always exit 0. The `require-review` blocking gate is fail-CLOSED for unrecognized `jr` subcommands (SEC-002, PR #13) — unknown jr operations emit deny rather than allow to prevent future write subcommands from bypassing the gate. Do not conflate these two behaviors.
10. **Commit messages:** Conventional Commits format; no Co-Authored-By or AI attribution.
11. **Version sync:** plugin.json + marketplace.json + git tag must all carry identical version strings before a release is valid.
12. **CHANGELOG:** Keep-a-Changelog format; one-line summary directly under `## [X.Y.Z] - YYYY-MM-DD` heading (used by release.yml for notes extraction).

### MUST AVOID (Detected Anti-Patterns)

1. **Hardcoded paths in SKILL.md/agent files:** Use `${CLAUDE_PLUGIN_ROOT}/` — hardcoded paths break portability across plugin install locations.
2. **Misapplying fail-open to the require-review blocking gate:** Advisory hooks (bias-check-reminder, handoff-validator, session-greeting) and non-jr inputs should fail-open. Do NOT add catch-all denies to advisory hooks. Equally, do NOT revert the final `emit_deny` in `require-review` back to `emit_allow` — that fail-CLOSED fallthrough is an intentional security fix (SEC-002, PR #13) that prevents unrecognized `jr` subcommands from bypassing the review gate. Reverting it reintroduces the vulnerability.
3. **Adding `Write` tool to security-reviewer agent:** Riley is read-only by design; this is tested by `skills.bats:277-279`.
4. **Skipping Iron Law on new workflow skills:** Iron Laws are structurally tested; missing one fails CI.
5. **Skipping Red Flags or having < 6 rows:** Row count is tested by `skills.bats` for all pipeline skills.
6. **Tagging a pre-merge SHA:** Tag must point at the squash-merge commit on `main`, not the release branch commit.
7. **Direct push to `main`:** Blocked by hook. Always go through a PR.
8. **Client-identifying data in committed content:** Checked by `skills.bats:404-408` and `skills.bats:468-470` — sensitive org names, client field IDs, and rates belong in the never-committed `effort-priors-tmpl.yaml`.

### Style Ambiguities

1. **`secops(<scope>):` vs `feat(<scope>):`:** `rules/secops-protocol.md` specifies `secops(<scope>):` for plugin-content commits, but the actual commit history uses `feat(scope):`. Human should clarify which prefix is canonical for new feature work.
2. ~~**`secops-health` command anomaly:**~~ Resolved in PR #16 (DI-002): `skills/secops-health/SKILL.md` was added, giving all 20 commands a 1:1 skill. The CI carve-out for this command has been removed.

---

## Enforceable Rules (Machine-Readable)

```yaml
enforceable_rules:
  - id: CONV-001
    description: "Skill directories must use kebab-case naming"
    pattern: "^[a-z][a-z0-9-]+$"
    scope: "plugins/secops-factory/skills/*"
    severity: error
    evidence:
      - "plugins/secops-factory/skills/enrich-ticket/"
      - "plugins/secops-factory/skills/adversarial-review-secops/"
      - "plugins/secops-factory/skills/analyze-ticket-effort/"

  - id: CONV-002
    description: "Every skill directory must contain SKILL.md (uppercase)"
    pattern: "SKILL.md must exist in each skills/<name>/ directory"
    scope: "plugins/secops-factory/skills/*/"
    severity: error
    evidence:
      - "plugins/secops-factory/skills/enrich-ticket/SKILL.md"
      - "plugins/secops-factory/skills/research-cve/SKILL.md"
      - "ci.yml:62-70 (structure job validates this)"

  - id: CONV-003
    description: "Every command file must have a matching skill directory (no exceptions — secops-health exemption removed in PR #16)"
    pattern: "commands/<name>.md requires skills/<name>/ to exist"
    scope: "plugins/secops-factory/commands/*.md"
    severity: error
    evidence:
      - "ci.yml:72-85 (structure job validates this)"
      - "plugins/secops-factory/commands/enrich-ticket.md -> skills/enrich-ticket/"

  - id: CONV-004
    description: "Every hook .sh must have a .ps1 sibling with identical JSON output"
    pattern: "hooks/<name>.sh requires hooks/<name>.ps1"
    scope: "plugins/secops-factory/hooks/*.sh"
    severity: error
    evidence:
      - "ci.yml:51-60 (structure job validates this)"
      - "tests/parity.bats:33-38 (BATS test)"

  - id: CONV-005
    description: "SKILL.md frontmatter must include name, description fields"
    pattern: "YAML frontmatter with name: and description: fields"
    scope: "plugins/secops-factory/skills/*/SKILL.md"
    severity: error
    evidence:
      - "skills/enrich-ticket/SKILL.md:1-5"
      - "skills/research-cve/SKILL.md:1-5"

  - id: CONV-006
    description: "Agent frontmatter must include name, description, model, color, tools fields"
    pattern: "YAML frontmatter with name:, description:, model:, color:, tools: fields"
    scope: "plugins/secops-factory/agents/*.md"
    severity: error
    evidence:
      - "agents/security-analyst.md:1-17"
      - "skills.bats:259-264, 267-272 (BATS tests)"

  - id: CONV-007
    description: "Workflow skills must contain an Iron Law section in the body"
    pattern: "grep 'NO .* WITHOUT .* FIRST' SKILL.md"
    scope: "plugins/secops-factory/skills/*/SKILL.md"
    severity: error
    evidence:
      - "skills/enrich-ticket/SKILL.md:12-14"
      - "skills.bats:9-27 (BATS tests)"

  - id: CONV-008
    description: "Workflow skills must contain an Announce at Start section"
    pattern: "grep 'Announce at Start' SKILL.md"
    scope: "plugins/secops-factory/skills/*/SKILL.md"
    severity: error
    evidence:
      - "skills/enrich-ticket/SKILL.md:18-22"
      - "skills.bats:35-56 (BATS tests)"

  - id: CONV-009
    description: "Workflow skills must contain >= 6 Red Flag table rows"
    pattern: "grep -c '^| \"' SKILL.md >= 6"
    scope: "plugins/secops-factory/skills/*/SKILL.md"
    severity: error
    evidence:
      - "skills/enrich-ticket/SKILL.md:24-34"
      - "skills.bats:61-90 (BATS tests)"

  - id: CONV-010
    description: "Internal file references must use ${CLAUDE_PLUGIN_ROOT}/ prefix (not hardcoded paths)"
    pattern: "grep -v '\\$\\{CLAUDE_PLUGIN_ROOT\\}/' for any path containing /templates/ /data/ /checklists/"
    scope: "plugins/secops-factory/skills/*/SKILL.md, plugins/secops-factory/agents/*.md"
    severity: error
    evidence:
      - "skills/enrich-ticket/SKILL.md:101 — ${CLAUDE_PLUGIN_ROOT}/templates/security-enrichment-tmpl.yaml"
      - "skills.bats:93-105 (BATS tests)"

  - id: CONV-011
    description: "Command wrappers must delegate via Skill tool (no embedded logic)"
    pattern: "body contains 'Use the `secops-factory <name>` skill via the Skill tool.'"
    scope: "plugins/secops-factory/commands/*.md"
    severity: error
    evidence:
      - "commands/enrich-ticket.md:6"
      - "commands/research-cve.md:6"
      - "commands/adversarial-review-secops.md:6"

  - id: CONV-012
    description: "Hooks must emit exit code 0 for both allow and deny business decisions"
    pattern: "exit 0 in both emit_allow and emit_deny paths"
    scope: "plugins/secops-factory/hooks/*.sh"
    severity: error
    evidence:
      - "emit_allow and emit_deny in require-review.sh (both exit 0)"
      - "hooks/enrichment-completeness.sh:22, 34 (both exit 0)"

  - id: CONV-013
    description: "Hook evaluation order — write-block BEFORE allowlist; fail-closed fallthrough at end (ADV-0-801/PR #15)"
    pattern: |
      require-review MUST evaluate in this order:
        1. fast-path allow for non-jr commands
        2. write-block DENY (before allowlist — CRITICAL)
        3. read-only allowlist ALLOW
        4. fail-closed DENY for unrecognized jr subcommands (SEC-002)
      advisory hooks (bias-check-reminder, handoff-validator, session-greeting): final action exits 0 with no permissionDecision deny.
      A final emit_allow in require-review is a security regression — must not be introduced.
      Placing the allowlist before the write-block is a CRITICAL vulnerability (ADV-0-801) — a write command with an embedded allowlist substring (e.g., jr issue edit KEY --summary "see jr board") would bypass the deny gate.
    scope: "plugins/secops-factory/hooks/*"
    severity: error
    notes: "Updated 2026-07-19 — SEC-002 (PR #13) changed require-review final fallthrough from emit_allow to emit_deny. SEC-001 (PR #14) moved jr issue comment from allowed to blocked. ADV-0-801 (PR #15) corrected evaluation order: write-block now evaluated BEFORE allowlist (old allow-first order was a CRITICAL bypass). Implementers following pre-PR #15 conventions.md would reintroduce a critical security bug."
    evidence:
      - "fast-path guard in require-review.sh: emit_allow for non-jr commands"
      - "write-block if-block in require-review.sh: emit_deny BEFORE allowlist (ADV-0-801)"
      - "read-only allowlist in require-review.sh: emit_allow"
      - "fail-closed catch-all in require-review.sh: emit_deny for unrecognized jr subcommand (SEC-002)"
      - "hooks/require-review.ps1 (updated in PR #15 to match new ordering)"

  - id: CONV-014
    description: "plugin.json and marketplace.json versions must match"
    pattern: "jq -r .version plugin.json == jq -r '.plugins[0].version' marketplace.json"
    scope: "plugins/secops-factory/.claude-plugin/plugin.json, .claude-plugin/marketplace.json"
    severity: error
    evidence:
      - ".github/workflows/release.yml (validates tag == both version fields)"
      - "RELEASING.md:42-43 (Mandatory invariants)"

  - id: CONV-015
    description: "CHANGELOG entries must use Keep-a-Changelog format with one-line summary under heading"
    pattern: "## [X.Y.Z] - YYYY-MM-DD followed by a non-empty line before ### subsections"
    scope: "CHANGELOG.md"
    severity: error
    evidence:
      - "CHANGELOG.md:8-11 (v0.9.0 entry)"
      - "RELEASING.md:44-45 (Mandatory invariants)"

  - id: CONV-016
    description: "Commit messages must not include Co-Authored-By or AI attribution"
    pattern: "No 'Co-Authored-By' in commit messages"
    scope: "git commit messages"
    severity: error
    evidence:
      - "RELEASING.md:50 (Release commits. No Claude/AI attribution.)"
      - ".claude/projects/memory/MEMORY.md — omit Co-Authored-By from all commits"

  - id: CONV-017
    description: "security-reviewer agent must not include Write tool in its tools list"
    pattern: "agents/security-reviewer.md tools: list must not contain Write"
    scope: "plugins/secops-factory/agents/security-reviewer.md"
    severity: error
    evidence:
      - "skills.bats:277-279 (BATS test)"

  - id: CONV-018
    description: "Every referenced template, data, and checklist file must physically exist"
    pattern: "${CLAUDE_PLUGIN_ROOT}/<type>/<file> references must resolve to real files"
    scope: "plugins/secops-factory/skills/*/SKILL.md, plugins/secops-factory/agents/*.md"
    severity: error
    evidence:
      - "skills.bats:215-255 (three portability BATS tests)"

  - id: CONV-019
    description: "No BMAD references in skills, agents, or data files"
    pattern: "grep -qiF 'bmad' must find nothing"
    scope: "plugins/secops-factory/skills/*/SKILL.md, plugins/secops-factory/agents/*.md, plugins/secops-factory/data/*.md"
    severity: error
    evidence:
      - "skills.bats:109-127 (BATS tests)"

  - id: CONV-020
    description: "No client-identifying data in committed plugin content"
    pattern: "grep -qiE '<client-name-list>' committed files must find nothing"
    scope: "plugins/secops-factory/**/*.md, plugins/secops-factory/**/*.yaml"
    severity: error
    evidence:
      - "skills.bats:404-408, 468-470 (BATS tests explicitly checking for org names)"
```

> **Plugin integration:** The `brownfield-discipline` plugin reads this YAML block from
> `.factory/phase-0-ingestion/conventions.md` for advisory pattern checking. Rules are
> advisory-only (warnings, never blocking), consistent with the plugin's non-blocking design.

---

## Document History

| Date | Change | Reference |
|------|--------|-----------|
| 2026-07-19 | Initial extraction — Phase 0c | Step 0c |
| 2026-07-19 | ADV-0-002: Scoped fail-open/fail-CLOSED — require-review blocking gate is fail-CLOSED for unrecognized jr subcommands (SEC-002); advisory hooks and non-jr inputs remain fail-open. Updated line 146, MUST-Follow #9, MUST-AVOID #2, CONV-013. | PR #13 (SEC-002), PR #14 (SEC-001) |
| 2026-07-19 | ADV-0-403/ADV-0-405: Re-anchored stale hooks.bats line citations to @test names + current line numbers (190, 185, group headers 7/95/117/136/156/183). Corrected fast-path line range in require-review.sh from 47-49 to 47-50. | PR #13/#14 |
| 2026-07-19 | ADV-0-603: Re-anchored all require-review.sh header citations to HEAD (PR #14 added Invariant-4 comment block, shifting body down 7 lines). set -euo pipefail: 13→18; jq guard: 14-17→20-23; INPUT=$(cat): 19→25; emit_allow: 21-24→27-30 (exit 0 at 29); emit_deny: 26-34→32-42 (exit 0 at 41). CONV-012 exit-0 citations corrected: require-review.sh 23,35→29,41; enrichment-completeness.sh 24,35→22,34. | PR #14 |
| 2026-07-19 | ADV-0-B02: Converted hooks.bats group-header and test-naming-example line-number citations to @test-name references (line numbers now secondary/approximate) for churn-resilience. Require-review block now 26 tests (:9–:177 post-PR-15). Group anchors: enrichment-completeness ~:185, bias-check-reminder ~:207, handoff-validator ~:226, disposition-guard ~:246, session-greeting ~:278. | PR #15 |
| 2026-07-19 | DI-002: Updated skill count from 19 to 20 (PR #16 added skills/secops-factory/SKILL.md for secops-health, giving all 20 commands a 1:1 skill and removing the CI carve-out). Fixed in: Skill Directory Names table (×2), Command Match rule (19/20→20/20), File Size Norms, Style Ambiguities, CONV-003. | PR #16, DI-002 |
| 2026-07-19 | ADV-0-801 / PR #15: CRITICAL evaluation-order fix — write-block must be evaluated BEFORE the allowlist (old allow-first order was a bypass vulnerability). Updated Fast path ordering row, Fail-open row, and CONV-013 to the corrected order: fast-path → write-block (deny) → allowlist (allow) → fail-closed (deny). Line anchors updated to PR #15 HEAD. Added security note explaining why allow-first caused the bypass. | PR #15 (ADV-0-801) |
| 2026-07-19 | ADV-0-A01: Replaced all live require-review.sh line-number citations in Bash Hook Pattern table (Shebang, Error mode, jq guard, Input ingestion, Allow/Deny function rows, Fast path ordering, Fail-open rows), CONV-012 evidence, and CONV-013 evidence with construct-name references (fast-path guard / write-block if-block / read-only allowlist / fail-closed catch-all / jq-availability guard / emit_allow / emit_deny). Historical Document History entries preserved as-is. | ADV-0-A01 |

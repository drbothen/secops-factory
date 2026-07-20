---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/activate/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "e7fc604"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/activate/SKILL.md
subsystem: lifecycle-management
capability: CAP-LIFECYCLE-01
lifecycle_status: active
introduced: v0.7.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-6.01.001: activate Skill — Per-Project Activation Lifecycle

## Preconditions

1. The skill is user-invoked only (`disable-model-invocation: true` in frontmatter). The LLM model is never dispatched for this skill. Confidence: verified by code analysis (`skills/activate/SKILL.md:frontmatter`) and BATS test `skills.bats:327-329`.
2. The target for activation state is `.claude/settings.local.json` (per-project, not shared `settings.json`). Confidence: verified by code analysis and BATS test `skills.bats:323-325`.
3. The skill announces itself verbatim before any other action. Confidence: verified by code analysis (Announce at Start section) and BATS test `skills.bats:331-334`.

## Postconditions

1. After successful activation, `.claude/settings.local.json` contains `"agent": "secops-factory:orchestrator:orchestrator"` at the top level. Confidence: verified by code analysis (Step 4 merge block) and BATS test `skills.bats:319-322`.
2. The activation metadata block is written: `"secops-factory": {"activated_at": "<ISO 8601>", "activated_plugin_version": "<version>"}`. Confidence: verified by code analysis (Step 4 merge block).
3. All pre-existing keys in `settings.local.json` are preserved; the skill merges rather than overwrites. Confidence: verified by code analysis (Step 2: "parse with jq — never blind-overwrite") and Red Flag: "Touch only the `agent` key and the `secops-factory` block. Preserve everything else."
4. On Windows (native PowerShell/cmd, `$env:OS = Windows_NT`, not WSL/Git Bash), `hooks.json.windows` is copied to `hooks.json` to activate the `.ps1` hook variants. On macOS/Linux/WSL/Git Bash, `hooks.json` is left untouched. Confidence: verified by code analysis (Step 5).
5. The skill verifies the write with `jq` read-back before confirming success to the user. Confidence: verified by code analysis (Red Flag: "Activation failed silently, but I'll report success").
6. If `--dry-run` flag is provided, the proposed diff is printed but no file is written and no hooks variant is applied. Confidence: verified by code analysis (Dry-run mode section).
7. If an existing `agent` key points to a non-secops agent, the user is warned and asked to confirm before replacing. Confidence: verified by code analysis (Step 3) and Red Flag: "Another plugin's agent is set, mine is more important" → "Ask before replacing."

## Invariants

1. Activation is always an explicit user action — the plugin being enabled never auto-activates. Confidence: verified by code analysis (Notes: "No hijack on enable" principle).
2. `settings.json` (shared team settings) is never modified — only `settings.local.json` (per-project, typically gitignored). Confidence: verified by code analysis (Step 4 and Red Flag: "I'll set this in the shared settings.json").
3. If `settings.local.json` exists but is corrupt (fails jq parse), the skill shows the parse error and stops — it never overwrites a corrupt file. Confidence: verified by code analysis (Red Flag: "settings.local.json doesn't parse, I'll overwrite it" → "Never clobber a corrupt file.").
4. A SecOps Factory activation does not remove or disable other plugins (agents, skills, hooks remain available). Confidence: verified by code analysis (Notes: "Coexistence").

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `settings.local.json` does not exist | Start from `{}` and write activation block |
| EC-002 | `settings.local.json` exists with `agent: vsdd-factory:orchestrator:orchestrator` | Warn user which agent currently holds default; ask for confirmation before replacing |
| EC-003 | `settings.local.json` exists with `agent: secops-factory:orchestrator:orchestrator` | Already activated; confirm to user (idempotent re-run) |
| EC-004 | `settings.local.json` is malformed JSON | Show parse error; stop; do not overwrite |
| EC-005 | `--dry-run` flag provided | Print proposed diff; exit without writing |
| EC-006 | Running on Windows native shell | Copy `hooks.json.windows` to `hooks.json`; report which hooks variant was applied |
| EC-007 | Running on macOS/Linux | Leave `hooks.json` untouched; confirm `.sh` variant is active |

## Canonical Test Vectors

| Scenario | Expected Behavior | Category |
|----------|------------------|----------|
| No existing settings.local.json | Write file with agent + secops-factory metadata block; verify with jq read-back | happy-path |
| settings.local.json with other keys | Merge activation block; preserve other keys | happy-path |
| settings.local.json with vsdd-factory agent | Warn; ask confirmation; replace only if user confirms | edge-case |
| Corrupt settings.local.json | Show parse error; stop | error |
| `--dry-run` | Print proposed diff only; no file modification | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-021 | Skill targets settings.local.json (never settings.json) | integration / BATS (`skills.bats:323-325`) |
| VP-SKILL-022 | Skill sets `"agent": "secops-factory:orchestrator:orchestrator"` | integration / BATS (`skills.bats:319-322`) |
| VP-SKILL-023 | disable-model-invocation: true is set | integration / BATS (`skills.bats:327-329`) |
| VP-SKILL-024 | Announce at Start present | integration / BATS (`skills.bats:331-334`) |
| VP-SKILL-025 | Red Flags table has >= 6 rows | integration / BATS (`skills.bats:335-338`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-LIFECYCLE-01 |
| L2 Domain Invariants | No hijack-on-enable; per-project activation scope |
| Architecture Module | C-2 (skill-procedures) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/activate/SKILL.md` (~82 lines) |
| **Confidence** | high — step-by-step procedure explicitly documented; exact JSON values for agent key and metadata block are specified; BATS tests at `skills.bats:318-338` exercise structural requirements |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **type constraint**: `disable-model-invocation: true` — runtime enforcement that no LLM dispatch occurs
- **documentation**: exact JSON merge block with agent key value and metadata structure
- **guard clause**: corrupt file check (Red Flags) and competing agent check (Step 3)
- **documentation**: platform detection logic for hooks variant selection

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads `settings.local.json` (filesystem), writes `settings.local.json`, optionally writes `hooks.json` (Windows only), reads `plugin.json` for version |
| **Global state access** | none |
| **Deterministic** | yes given same inputs (existing file content + platform) |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell (filesystem read/write) |

#### Refactoring Notes

The JSON merge logic (merge activation block into existing settings, preserving other keys) is a pure function given the existing file content. The platform detection logic (Windows vs. not Windows) is also a pure predicate. The overall skill is effectful (filesystem writes). The pure JSON merge and platform detection are natural units for property testing.

**Undocumented behavior (ambiguity):** The `activated_plugin_version` in the metadata block requires reading `plugins/secops-factory/.claude-plugin/plugin.json` at activation time. If the plugin is installed but the version cannot be read (e.g., the file is missing), the skill's behavior is unspecified — the Red Flags do not cover this case.

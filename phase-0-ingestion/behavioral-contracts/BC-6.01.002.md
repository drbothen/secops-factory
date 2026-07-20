---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/deactivate/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "6b064e2"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/deactivate/SKILL.md
subsystem: lifecycle-management
capability: CAP-LIFECYCLE-02
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

# Behavioral Contract BC-6.01.002: deactivate Skill — Per-Project Deactivation

## Preconditions

1. The skill is user-invoked only (`disable-model-invocation: true`). Confidence: verified by code analysis (pattern inherited from `activate`; `deactivate` is a symmetric operation).
2. `.claude/settings.local.json` exists in the project directory with a `secops-factory:` agent as the default. Confidence: implied by Steps 1 and 2 in the procedure.
3. The skill announces itself verbatim before any other action. Confidence: verified by code analysis (Announce at Start section).

## Postconditions

1. After successful deactivation, the `agent` key and `secops-factory` metadata block are removed from `.claude/settings.local.json` using `jq 'del(.agent) | del(.["secops-factory"])'`. Confidence: verified by code analysis (Step 3) and BATS test `skills.bats:341-344`.
2. All other keys in `settings.local.json` are preserved. Confidence: verified by code analysis (Red Flag: "I'll delete the whole settings file to be thorough" → "Other keys may live there. Delete only the two activation keys.").
3. If the resulting JSON object is empty, the user is asked whether to delete the file or leave it as `{}`. Confidence: verified by code analysis (Step 3: "either delete the file or leave it as {} — ask the user").
4. The write is verified with `jq` read-back before confirming success. Confidence: verified by code analysis (Red Flag: "I'll skip the read-back verification").
5. The plugin itself remains enabled after deactivation — agents, skills, hooks, and commands remain available for explicit invocation. Confidence: verified by code analysis (description: "Leaves the plugin enabled; only the default persona is cleared") and BATS test `skills.bats:341-344`.

## Invariants

1. If `settings.local.json` does not exist, the skill reports "never activated" and stops — it does not create an empty file. Confidence: verified by code analysis (Step 1 and Red Flag: "The file doesn't exist, I'll create an empty one" → "Nothing to do.").
2. If `agent` key points to a non-secops-factory agent, the skill stops and warns — it never removes another plugin's default agent. Confidence: verified by code analysis (Step 2 and Red Flag) and BATS test `skills.bats:345-347`.
3. Deactivation does not modify or disable hooks. Hooks belong to plugin enablement (handled by the plugin framework), not to the activation state. Confidence: verified by code analysis (Red Flag: "The user probably wants the hooks disabled too" → "Hooks belong to plugin enablement, not activation. Leave them alone.").
4. The skill is the exact inverse of `activate`: `activate` then `deactivate` returns `settings.local.json` to its pre-activation state (minus the activation keys). Confidence: verified by code analysis (description: "Reverses everything /activate does").

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `settings.local.json` does not exist | Report "factory was never activated here" and stop |
| EC-002 | `agent` is `vsdd-factory:orchestrator:orchestrator` (different plugin) | Stop and warn; do not remove another plugin's agent |
| EC-003 | `agent` is `secops-factory:orchestrator:orchestrator` | Remove `agent` and `secops-factory` keys; write back |
| EC-004 | Resulting JSON is empty `{}` | Ask user: delete file or leave as `{}`? |
| EC-005 | `settings.local.json` has other keys (permissions, env) | Remove only activation keys; preserve all others |

## Canonical Test Vectors

| Scenario | Expected Behavior | Category |
|----------|------------------|----------|
| File exists with secops-factory agent active | Remove `agent` + `secops-factory` keys; preserve others; confirm | happy-path |
| File does not exist | Report never activated; no-op | edge-case |
| File exists with vsdd-factory agent | Stop and warn; do not modify | edge-case |
| File has only activation keys (empty after removal) | Ask user to confirm delete or keep as `{}` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-026 | `del(.agent)` jq expression is present | integration / BATS (`skills.bats:341-344`) |
| VP-SKILL-027 | Skill guards against removing non-secops agents | integration / BATS (`skills.bats:345-347`) |
| VP-SKILL-028 | Red Flags table has >= 6 rows | integration / BATS (`skills.bats:349-352`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-LIFECYCLE-02 |
| L2 Domain Invariants | Per-project activation scope; non-destructive to other plugin state |
| Architecture Module | C-2 (skill-procedures) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/deactivate/SKILL.md` (~44 lines) |
| **Confidence** | high — inverse operation to activate; jq expression explicitly documented; BATS tests at `skills.bats:340-352` exercise structural requirements |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **documentation**: exact `jq 'del(.agent) | del(.["secops-factory"])'` expression
- **guard clause**: `secops-factory:` prefix check before deletion
- **documentation**: empty-result handling (delete or `{}`)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads `settings.local.json` (filesystem), writes `settings.local.json` |
| **Global state access** | none |
| **Deterministic** | yes given same file content |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell (filesystem read/write) |

#### Refactoring Notes

The jq key-deletion is a pure transformation. The pre-condition checks (file exists, agent is secops-factory prefix) are pure predicates. Both are natural units for property testing.

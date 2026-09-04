---
document_type: story
level: ops
story_id: "STORY-DEMO-SEED-001"
epic_id: "E-DEMO"
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: f3
inputs:
  - .factory/feature/prism-integration-handoff-brief.md
  - .factory/feature/claroty-xdome-v1-planning-brief.md
input-hash: "eb933db"
traces_to: "[TBD — no BC assigned; demo-operator tooling per D-006]"
points: "[TBD at F3]"
depends_on: []
blocks: []
behavioral_contracts: []
verification_properties: []
priority: "P1"
cycle: "v0.10.0-feature-prism-integration"
wave: null
target_module: "scripts/demo/"
subsystems: []
estimated_days: null
assumption_validations: []
risk_mitigations: []
tdd_mode: strict
# STUB ANNOTATION: This is an F3-boundary stub created at the F2→F3 gate.
# Full story decomposition (tasks, architecture mapping, token budget) is deferred to F3 kickoff.
# Convention note: F3 story-naming convention (S-N.MM) not yet finalized. STORY-DEMO-SEED-001
# is a placeholder ID. The story-writer must assign a canonical S-N.MM ID at F3 kickoff.
---

> **tdd_mode:** Absent or unrecognized values default to `strict` per BC-8.30.001 invariant 2.

> **STUB STATUS:** This is a DRAFT stub created at the F2→F3 boundary. Acceptance criteria,
> tasks, architecture mapping, and token budget are stubs to be elaborated at F3 kickoff.
> Do NOT dispatch to implementer until this story is promoted to `status: ready`.

> **Execute (when ready):** `/vsdd-factory:deliver-story STORY-DEMO-SEED-001`

# STORY-DEMO-SEED-001: Automated demo Jira seeding script (demo-seed-jira.sh/.ps1)

## Narrative

- **As a** demo operator preparing the Claroty-xDome V1 live demo
- **I want to** run a single cross-platform script (`demo-seed-jira.sh` / `demo-seed-jira.ps1`) that idempotently creates narrative-aligned Jira tickets in the demo project
- **So that** the demo flow `activate → investigate-event → monitoring-loop` has pre-seeded tickets to work from without manual ticket creation or running the monitor loop first

## Acceptance Criteria

> **STUB — refine at F3 kickoff.**

### AC-001 (traces to: brief §4.2 Option A — cross-platform parity)

Both `demo-seed-jira.sh` (bash) and `demo-seed-jira.ps1` (PowerShell) exist, accept the same
environment-variable interface, and produce equivalent ticket output on their respective
platforms. Parity-test: run both scripts against a Jira mock; compare created ticket payloads.
**Test:** `test_STORY_DEMO_SEED_001_sh_ps1_parity()`

### AC-002 (traces to: brief §4.2 Option A — idempotent seeding)

Running the script twice against the same Jira project produces no duplicate tickets. On the
second run, existing tickets are detected by title+label match and skipped with a log message.
Exit code 0 on both runs.
**Test:** `test_STORY_DEMO_SEED_001_idempotent_skip_existing()`

### AC-003 (traces to: brief §4.2 — narrative-aligned fixtures)

Script seeds 3–5 tickets whose subjects correspond to DTU org-b fixture events (Claroty +
Cyberint sensors, seed=150): at minimum one recon alert, one lateral-movement alert, one
exfiltration-timing alert. Ticket titles and descriptions are human-readable (not raw OCSF
field dumps).
**Test:** `test_STORY_DEMO_SEED_001_ticket_subjects_match_fixture_narrative()`

### AC-004 (traces to: D-006 operator-tooling boundary + no-secrets policy)

Script reads `JIRA_PROJECT_KEY`, `JIRA_URL`, and `JIRA_TOKEN` exclusively from environment
variables. No secrets are hard-coded. Script exits non-zero with a descriptive error message
when any required variable is absent.
**Test:** `test_STORY_DEMO_SEED_001_missing_env_exits_nonzero()`

### AC-005 (traces to: handoff-brief §6 BATS test coverage requirement)

BATS test coverage exists for dry-run mode and skip-on-existing behavior; tests run without
a live Jira instance (jr-mock or HTTP fixture).
**Test:** `test_STORY_DEMO_SEED_001_bats_dry_run_no_live_jira()`

## Architecture Mapping

> **STUB — populate at F3 decomposition.**

| Component | Module | Pure/Effectful |
|-----------|--------|---------------|
| demo-seed-jira script | scripts/demo/demo-seed-jira.sh | effectful-shell (Jira API calls) |
| demo-seed-jira PowerShell | scripts/demo/demo-seed-jira.ps1 | effectful-shell (Jira API calls) |
| BATS test suite | tests/demo/test_demo_seed_jira.bats | effectful-shell (jr-mock) |

## Edge Cases

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| EC-001 | Jira project already has tickets matching seed titles | Skip creation; log "already exists"; exit 0 |
| EC-002 | `JIRA_TOKEN` is invalid or expired | Exit non-zero; print auth error with remediation hint |
| EC-003 | `JIRA_PROJECT_KEY` points to a nonexistent project | Exit non-zero; print "project not found" |
| EC-004 | Network unreachable | Exit non-zero; print connection error; no partial ticket set |
| EC-005 | Script run with `--dry-run` flag | Print planned ticket titles without creating anything; exit 0 |

## Purity Classification

| Module | Classification | Justification |
|--------|---------------|---------------|
| scripts/demo/demo-seed-jira.sh | effectful-shell | Creates Jira tickets via external API; side-effectful by design |
| scripts/demo/demo-seed-jira.ps1 | effectful-shell | Same; PowerShell parity variant |
| Idempotency check logic | pure-core (extractable) | Title+label duplicate detection can be a pure function on ticket list |

## Token Budget Estimate (MANDATORY)

> **STUB — estimate at F3 decomposition.**

| Context Source | Estimated Tokens |
|---------------|-----------------|
| This story spec | ~2,000 |
| Referenced brief sections | ~1,500 |
| Script files (sh + ps1) | ~1,000 |
| BATS test files | ~800 |
| Tool outputs overhead | ~500 |
| **Total** | **~5,800** |
| Agent context window | 200K (Sonnet) |
| **Budget usage** | **~3%** |

## Tasks (MANDATORY)

> **STUB — elaborate at F3 kickoff.**

1. [ ] Write failing BATS tests for sh + ps1 parity (test-writer)
2. [ ] Write failing BATS tests for idempotency (test-writer)
3. [ ] Write failing BATS tests for missing-env exit behavior (test-writer)
4. [ ] Verify Red Gate (all tests fail before implementation)
5. [ ] Implement `demo-seed-jira.sh` to pass AC-001..005 (implementer)
6. [ ] Implement `demo-seed-jira.ps1` with parity (implementer)
7. [ ] Add `--dry-run` flag to both scripts (EC-005)
8. [ ] Verify purity boundaries (idempotency check as extractable pure function)
9. [ ] Update STATE.md

## Previous Story Intelligence (MANDATORY)

| Story | Key Decisions | Patterns Established | Gotchas Discovered |
|-------|--------------|---------------------|-------------------|
| N/A (first demo-tooling story) | D-006: plugin is demo-unaware; script is operator tooling | All .sh scripts require companion .ps1 (handoff-brief §6) | Ensure `jr auth status` pattern from activate skill is NOT re-used here — this script uses Jira REST API directly, not `jr` CLI, to avoid pulling plugin internals into demo setup |

## Architecture Compliance Rules (MANDATORY)

| Rule | Source | Enforcement |
|------|--------|-------------|
| D-006: plugin is DEMO-UNAWARE | STATE.md D-006 | Script lives under `scripts/demo/`, not inside the plugin skill tree; no imports from plugin code |
| All .sh scripts require companion .ps1 | prism-integration-handoff-brief §6 | Both files must exist and be parity-tested before story is marked done |
| No secrets committed | Security baseline | `JIRA_TOKEN` is env-var only; `.env.example` acceptable; no secrets in history |
| Exit non-zero on failure | Operator tooling convention | Script must not exit 0 when ticket creation fails |

## Library & Framework Requirements (MANDATORY)

| Tool | Version | Purpose |
|------|---------|---------|
| bash | >= 4.0 | Shell script runtime (macOS ships 3.x; demo operators use homebrew bash or Docker) |
| pwsh (PowerShell) | >= 7.0 | PowerShell script runtime for .ps1 parity |
| curl or `jr` REST | TBD at F3 | HTTP transport for Jira API calls |
| BATS | >= 1.8 | Test framework (existing project harness) |

## File Structure Requirements (MANDATORY)

| File | Action | Purpose |
|------|--------|---------|
| `scripts/demo/demo-seed-jira.sh` | create | Bash demo Jira seeding script |
| `scripts/demo/demo-seed-jira.ps1` | create | PowerShell parity variant |
| `scripts/demo/README.md` | create | Usage instructions + env-var reference |
| `tests/demo/test_demo_seed_jira.bats` | create | BATS test suite (dry-run + idempotency + error cases) |

---
story_id: "S-6.03"
title: "Demo evidence — S-6.03: Activate Skill CLOSE_STATE_ALLOWLIST + prism version gate"
toolchain: "VHS 0.11.0"
recorded: "2026-09-06"
branch: "feature/S-6.03"
---

# Demo Evidence — S-6.03

Story: Delta — Activate Skill CLOSE_STATE_ALLOWLIST Setup-Time Validation (BC-6.01.001 v1.8)

## Coverage Map

| Demo Artifact | AC(s) Evidenced | Path / Behavior |
|---------------|-----------------|-----------------|
| `AC-008a-below-minimum.gif/.webm` | AC-008 (error path) | prism 0.9.9 < 1.0.0-rc.1 → exit 1 + "does not meet minimum requirement" |
| `AC-008b-at-minimum.gif/.webm` | AC-008 (success path) | prism 1.0.0-rc.1 = minimum → exit 0 + "meets minimum requirement" |
| `AC-008c-above-minimum.gif/.webm` | AC-008 (success path) | prism 2.0.0 > minimum → exit 0 + "meets minimum requirement" |
| `AC-008d-not-found.gif/.webm` | AC-008 (error path) | prism not in PATH → exit 2 + "prism binary not found in PATH" |
| `AC-001-007-bats-suite.gif/.webm` | AC-001..007, AC-008 (full) | Full BATS suite green run — "=== All tests passed ===" |

## AC-008 (VP-SKILL-051): Prism Version Gate — Four Test Vectors

All four vectors of `plugins/secops-factory/hooks/prism-version-check.sh` are demonstrated
using a mocked `prism` binary on PATH. The mock is a minimal shell script (`echo "prism <version>"`)
added to PATH ahead of any installed prism (none is installed in this environment).

### AC-008a: Version Below Minimum (error path)

- **Mock**: `prism --version` outputs `prism 0.9.9`
- **Expected**: exit 1, stderr contains "does not meet minimum requirement 1.0.0-rc.1"
- **Demo**: `AC-008a-below-minimum.gif`

### AC-008b: Version at Minimum (success path)

- **Mock**: `prism --version` outputs `prism 1.0.0-rc.1`
- **Expected**: exit 0, stdout contains "meets minimum requirement 1.0.0-rc.1"
- **Demo**: `AC-008b-at-minimum.gif`

### AC-008c: Version Above Minimum (success path)

- **Mock**: `prism --version` outputs `prism 2.0.0`
- **Expected**: exit 0, stdout contains "meets minimum requirement 1.0.0-rc.1"
- **Demo**: `AC-008c-above-minimum.gif`

### AC-008d: Prism Not Found (error path — distinct exit code)

- **Mock**: no `prism` binary on PATH (not installed in this environment)
- **Expected**: exit 2 (distinct from exit 1 for below-minimum), stderr contains "prism binary not found in PATH"
- **Demo**: `AC-008d-not-found.gif`

## AC-001..007 (CLOSE_STATE_ALLOWLIST + jira_project_key): BATS Suite Green Run

AC-001..006 (CLOSE_STATE_ALLOWLIST setup-time validation) and AC-007 (jira_project_key charset
validation) are LLM-executed prose procedures in `skills/activate/SKILL.md`. Their correctness
is verified by doc-presence assertions in the BATS suite
(`plugins/secops-factory/tests/skills/activate-close-state.bats`):

- `test_BC_6_01_001_close_state_allowlist_constant_present` — CLOSE_STATE_ALLOWLIST = {Done, Closed, Resolved} documented
- `test_BC_6_01_001_close_state_allowlist_invalid_error_message_present` — EC-015 error string present
- `test_BC_6_01_001_close_state_case_sensitive_documented` — case sensitivity documented
- `test_BC_6_01_001_close_state_validation_activation_path_only` — setup-time guard (D-021)
- `test_BC_6_01_001_close_state_hardcoded_set_documented` — hardcoded set (not env var)
- `test_BC_6_01_001_project_key_charset_regex_present` — `^[A-Z][A-Z0-9]+$` in SKILL.md (AC-007)

Additionally, `prism-version-check-adversarial.bats` (22 tests) provides executable behavioral
coverage of all 4 AC-008 vectors including locale/utf-8 edge cases and semver corner cases.

Full suite result: **all tests passed** (`=== All tests passed ===`).

- **Demo**: `AC-001-007-bats-suite.gif` (shows tail -30 of test output, including final summary)

## PowerShell Parity Note

`prism-version-check.ps1` parity tests (M-2 class in adversarial BATS) are skipped locally
(`# skip pwsh not installed`) and run in CI. This is expected behavior — no ps1 recording
is required for this story's demo evidence.

## Toolchain

- **VHS** 0.11.0 — terminal recording
- **Font** — FiraCode Nerd Font Mono (installed locally)
- **Mocks** — temporary shell scripts placed ahead of PATH before VHS invocation
- **Note** — `Wait+Line /pattern/` was found unreliable for sub-millisecond commands in
  VHS 0.11.0 (race condition: command completes before wait registers); `Sleep` used instead

---
story_id: "S-3.01"
title: "Demo evidence — S-3.01: require-review Hook Link+Close Anti-Fungibility (BC-3.01.001 v1.25)"
toolchain: "VHS 0.11.0"
recorded: "2026-09-06"
branch: "feature/S-3.01"
---

# Demo Evidence — S-3.01

Story: Delta — require-review Hook Link+Close Anti-Fungibility (BC-3.01.001 v1.25, D-020/D-021)

## Coverage Map

| Demo Artifact | AC(s) Evidenced | Path / Behavior |
|---|---|---|
| `AC-001-005-007-link-allow.gif/.webm` | AC-001, AC-005, AC-007 | `["link"]` marker + `jr issue link SEC-1 SEC-2` → allow; marker consumed (1 .used file) |
| `AC-002-006-008-wrong-type-deny.gif/.webm` | AC-002, AC-006, AC-008 | `["comment"]` marker + `jr issue link` → deny (STEP 6 exact-type: comment ≠ link) |
| `AC-001-C1-create-label-deny.gif/.webm` | AC-001 (C1), AC-008 | `["create"]` marker + `--label REVIEW-REQUIRED` → deny (structural_label_check) |
| `AC-010a-close-state-deny.gif/.webm` | AC-010 (error path) | `["close"]` marker + `jr issue move SEC-42 WontFix` → deny (WontFix ∉ CLOSE_STATE_ALLOWLIST) |
| `AC-010b-close-state-allow.gif/.webm` | AC-002, AC-006, AC-010 (success path) | `["close"]` marker + `jr issue move SEC-42 Done` → allow; marker consumed |
| `AC-all-bats-suite.gif/.webm` | AC-001..010 + regression VPs | Full BATS suite — "=== All tests passed ===" |

## AC-001 (VP-HOOK-033 consumer leg): Write-Block Extension → 12 Entries

`jr issue link ` and `--output json issue link ` added as write-blocked patterns (D-020).
Total write-block entries after delta = 12 (base 10 + 2 link entries at v1.23).
Any `jr issue link` without a valid `["link"]` marker is denied.

- **ALLOW path**: `AC-001-005-007-link-allow.gif` — valid link marker authorizes link command
- **DENY path (wrong type)**: `AC-002-006-008-wrong-type-deny.gif` — comment marker cannot authorize link command
- **DENY path (C1)**: `AC-001-C1-create-label-deny.gif` — create marker with REVIEW-REQUIRED label denied by structural_label_check

## AC-002 / AC-006 (VP-HOOK-035 consumer leg): Close Exact-Type STEP-6 Binding

`jr issue move` may only be authorized by a `["close"]` marker. Link markers, comment markers,
and create markers are denied at STEP 6 (`["close"]` only). See also AC-010 for allowlist binding.

- **Wrong-type DENY**: `AC-002-006-008-wrong-type-deny.gif` — comment marker + link cmd → deny
- **Allowlist ALLOW**: `AC-010b-close-state-allow.gif` — close marker + Done → allow
- **Allowlist DENY**: `AC-010a-close-state-deny.gif` — close marker + WontFix → deny

## AC-005 / AC-006 (STEP 6 Exact-Type Matching)

At STEP 6, link commands match only `["link"]` markers; close commands match only `["close"]`
markers. All other marker types are rejected regardless of matching command_pattern.

- Demonstrated in: `AC-001-005-007-link-allow.gif` (link exact-type), `AC-002-006-008-wrong-type-deny.gif` (wrong-type rejection)

## AC-007 (Single-Use POSIX Atomic Rename, D-DEC-001)

A consumed marker is atomically renamed from `.marker.json` to `.marker.used`. The demo
runner confirms `1 file(s) renamed to .used` after each ALLOW decision.

- Demonstrated in: `AC-001-005-007-link-allow.gif` (link marker consumed), `AC-010b-close-state-allow.gif` (close marker consumed)

## AC-008 (Non-Interchangeability)

Link, close, create-review, and comment markers are not interchangeable. STEP 6 type guard
enforces this at hook runtime. Demonstrated by `AC-002-006-008-wrong-type-deny.gif`.

## AC-010 (VP-HOOK-035 / SM-63 Kill): CLOSE_STATE_ALLOWLIST Consumer Binding

The close marker's command_pattern is bound to `CLOSE_STATE_ALLOWLIST = {Done, Closed, Resolved}`.

- **(a) Non-allowlisted state → DENY**: `AC-010a-close-state-deny.gif` — WontFix ∉ allowlist → deny (SM-63 mutant killed)
- **(b) Allowlisted state → ALLOW**: `AC-010b-close-state-allow.gif` — Done ∈ allowlist → allow; marker consumed

## Full BATS Suite Green Run

All test suites pass after the D-020/D-021 delta:

- `require-review-link-close.bats` — 27 tests (AC-001..010, anti-fungibility, STEP-6, AC-010/SM-63)
- `require-review-security-gaps.bats` — 15 tests (I1 metachar guard, I2 future timestamp, I3/VP-024 audit)
- `require-review-pass1-findings.bats` — 15 tests (C1 structural_label_check, SM-37, VP-024 audit)
- `require-review-ps1-static.bats` — 18 tests (ps1 parity static checks)
- `parity.bats`, `hooks.bats`, `skills.bats`, `integration.bats` — regression VPs (VP-HOOK-001..024)

Final output: `=== All tests passed ===`

- **Demo**: `AC-all-bats-suite.gif` (tail -35 of run-all.sh output, including final summary)

## PowerShell Parity Note

`require-review.ps1` parity is verified via `require-review-ps1-static.bats` (18 static tests)
which run in this environment without pwsh. Behavioral ps1 tests (`require-review-ps1-behavioral.bats`)
are pwsh-gated and run in CI. No ps1 recording is produced locally — this is expected.

## Toolchain

- **VHS** 0.11.0 — terminal recording
- **Font** — FiraCode Nerd Font Mono (installed locally)
- **Helper** — `demo-runner.sh` (creates temp marker dir per vector, runs hook, reports decision + audit)
- **Note** — `Wait+Line /pattern/` not used (sub-second commands complete before VHS registers wait); `Sleep` used instead per VHS 0.11.0 guidance

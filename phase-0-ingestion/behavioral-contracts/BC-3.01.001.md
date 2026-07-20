---
document_type: behavioral-contract
level: L3
version: "1.10"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/require-review.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: "9725be7"
  1f01e0a7d67947c28e78931f8c4818e454f6a884afa5f7768bda0a3603e40e28  plugins/secops-factory/hooks/require-review.sh
  bd8199a77b13f2ad1a884362862984c6f331799796f8d09576bcda0dffa403f1  plugins/secops-factory/hooks/require-review.ps1
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/require-review.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-01
lifecycle_status: active
introduced: v0.7.0
modified: ["v0.9.x-PR13-2026-07-19", "v0.9.x-PR14-2026-07-19", "v0.9.x-ADV0-001-ADV0-007-2026-07-19", "v1.4-ADV-0-405-ADV-0-507-2026-07-19", "v1.5-ADV-0-504-2026-07-19", "v1.6-ADV-0-706-obs-PC2-2026-07-19", "v1.7-ADV-0-801-PR15-2026-07-19", "v1.8-ADV-0-A01-ADV-0-A02-ADV-0-A04-2026-07-19", "v1.9-ADV-0-B01-2026-07-19", "v1.10-RESYNC-PR17-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.01.001: require-review Hook — Jira Field-Modification Gate

> **Revision history:**
> - v1.0 (2026-07-19): Initial extraction from `require-review.sh` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): Revised to reflect PR #13 (commit f450d9f) behavior changes — SEC-001 (`jr issue comment` moved from allow to deny) and SEC-002 (unknown jr subcommands changed from fail-open to fail-closed). Previous postconditions #4 and #5 and invariant #3 were stale.
> - v1.2 (2026-07-19): Revised to reflect PR #14 (commit 0ec794a) — expanded read-only allowlist with two families: plain forms (`jr issue changelog`, `jr assets search/view`, `jr --version`) and `--output json` forms for the metrics suite. EC-010 flips from Deny to Allow. New Invariant #4 documents the `--output json` global-flag placement nuance (root cause of DI-010 regression). BATS count updated to 138 tests.
> - v1.3 (2026-07-19): Adversarial review pass 1 fixes — ADV-0-001: renumbered VP-HOOK-004/005/006 to VP-HOOK-020/021/022 (global sequential namespace; 004-006 are owned by BC-3.02.001 enrichment-completeness). ADV-0-007: corrected EC-015 mechanism — `jr --output json issue comment` is denied by the fail-closed catch-all, NOT by the write-block check (Invariant #4 applies; `jr issue comment` is not a substring of that command). Security extensibility note added to Refactoring Notes.
> - v1.4 (2026-07-19): ADV-0-405: corrected three stale line-number anchors — non-jr fast path is `require-review.sh:47-50` (not 48-50), fail-closed block is `require-review.sh:96-98` (not 97-98), source file is 98 lines (not 99). ADV-0-507 (pass-4 input-hash batch): input-hash established as dual-file block scalar (require-review.sh + require-review.ps1 sibling).
> - v1.5 (2026-07-19): ADV-0-504: corrected one remaining stale anchor in EC-015 — fail-closed catch-all is `(lines 96-98)` not `(lines 97-98)`. Missed by v1.4 sweep.
> - v1.6 (2026-07-19): ADV-0-706: Standardized write-block citations to canonical form `88-94 (deny at :93)`. Observation: Softened PC#2 confidence note — `comment`/`edit`/`move` deny verified by both code analysis and BATS; `assign`/`create` deny verified by code analysis only (no dedicated positive BATS tests for these two verbs; residual gap noted in GAP-2 of verification-gap-analysis.md).
> - v1.7 (2026-07-19): ADV-0-801 / PR #15 (commit d304fa5): CRITICAL evaluation-order fix — write-block is now evaluated BEFORE the allowlist (old order was allowlist → write-block, enabling a bypass: `jr issue edit KEY --summary "see jr board"` matched the `jr board` allowlist token). `--output json` write forms explicitly added to the write-block list. New line anchors throughout. New Invariant #5 (write-block precedence). EC-015 updated (jr --output json issue comment now hits write-block directly). EC-016 added (bypass pattern now denied). Input-hash recomputed (both .sh and .ps1 changed).
> - v1.10 (2026-07-19): RESYNC-PR17: DI-005 `assign`/`create` deny now **BATS-verified** — PR #17 added `@test "require-review blocks jr issue assign without review (DI-005)"` (hooks.bats:426) and `@test "require-review blocks jr issue create without review (DI-005)"` (hooks.bats:433). PC#2 confidence note updated. Source Evidence test count updated 150→165 (hooks 44→59). Last Verified Against updated to d181ca2.
> - v1.9 (2026-07-19): ADV-0-B01: Converted all live hooks.bats line-range citations to @test-NAME references with current line numbers (PR #15 expanded require-review block to lines 9-177; downstream tests shifted +88 lines). Source Evidence range updated 9-93 → 9-177 (26 tests). Stale VP-HOOK-003/020/021/022 range refs replaced with exact @test names. PC#3 stale test name "allows jr issue view" corrected to "allows jr read-only commands" (test was renamed when PR #14 expanded the allowlist). PC#2 line :88 corrected to :89 (move test shifted one line within the block). hooks.bats references now use @test names for churn resilience.
> - v1.8 (2026-07-19): ADV-0-A01: Replaced all live require-review.sh line-number citations with construct-name references (fast-path guard / write-block if-block / read-only allowlist / fail-closed catch-all / jq-availability guard / emit_allow / emit_deny) — makes the "anchor-churn retired" capstone claim true and prevents future PR-induced staleness. ADV-0-A02: Source Evidence test count updated to 150 @tests (hooks 44, skills 81, integration 11, parity 14); PR #15 +12 row added to Change Log. ADV-0-A04: VP-HOOK-023 added (--output json write-block family as provable property); canonical deny vector row added to test vectors table.

## Preconditions

1. The hook receives a Claude Code `PreToolUse/Bash` event envelope via stdin as JSON, containing `tool_input.command` (string). Confidence: verified by code analysis (require-review.sh — command extracted from stdin JSON via jq).
2. `jq` is installed and available on `$PATH`. If absent, the hook exits with code 1 and an error to stderr; it never emits a `permissionDecision` envelope. Confidence: verified by code analysis (jq-availability guard in require-review.sh).
3. The hook is wired via `hooks.json` to fire on `PreToolUse` events for the `Bash` tool only. Confidence: verified by code analysis (`hooks/hooks.json`).

## Postconditions

1. If `tool_input.command` does not contain the substring `jr `, the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (fast-path guard in require-review.sh) and BATS test `@test "require-review allows non-jr commands"` (hooks.bats:9).
2. If `tool_input.command` contains any write-block pattern, the hook emits `permissionDecision: deny` with a reason string containing "review approval". **This check is evaluated BEFORE the allowlist (Invariant #5)** — a command matching both a write-block pattern and an allowlist pattern is denied. Two families of write patterns are blocked (10 entries total): **Plain forms:** `jr issue comment ` (trailing-space guard against `jr issue comments` collision), `jr issue edit`, `jr issue move`, `jr issue assign`, `jr issue create`. **`--output json` forms (added PR #15/ADV-0-801):** `--output json issue comment ` (trailing-space guard), `--output json issue edit`, `--output json issue move`, `--output json issue assign`, `--output json issue create`. Confidence: verified by code analysis (write-block if-block in require-review.sh) and BATS tests `@test "require-review blocks jr issue comment without review (SEC-001)"` (hooks.bats:69), `@test "require-review blocks jr issue edit without review"` (hooks.bats:82), `@test "require-review blocks jr issue move without review"` (hooks.bats:89), `@test "require-review blocks jr issue assign without review (DI-005)"` (hooks.bats:426), `@test "require-review blocks jr issue create without review (DI-005)"` (hooks.bats:433). Note: `comment`, `edit`, `move`, `assign`, and `create` deny verified by both code analysis and BATS (PR #17 added assign/create BATS coverage); all `--output json` write forms verified by code analysis only.
3. If `tool_input.command` — after passing the write-block check (postcondition #2) — contains any entry from the explicit read-only allowlist, the hook emits `permissionDecision: allow` and exits 0. The allowlist is evaluated AFTER the write-block. The allowlist has two families: Confidence: verified by code analysis (read-only allowlist in require-review.sh) and BATS tests `@test "require-review allows jr read-only commands"` (hooks.bats:15).

   **Plain forms (family a):**
   - `jr issue view`
   - `jr issue list`
   - `jr issue comments`
   - `jr issue assets`
   - `jr issue transitions`
   - `jr issue changelog` *(added PR #14 — resolves DI-010)*
   - `jr assets search` *(added PR #14)*
   - `jr assets view` *(added PR #14)*
   - `jr sprint`
   - `jr board`
   - `jr project`
   - `jr me`
   - `jr auth`
   - `jr --version` *(added PR #14)*

   **`--output json` forms (family b — added PR #14, for metrics suite):**
   - `--output json issue view`
   - `--output json issue list`
   - `--output json issue comments`
   - `--output json issue changelog`
   - `--output json issue assets`
   - `--output json assets search`
   - `--output json assets view`

4. For any `jr` subcommand that does not match the write-block list (postcondition #2) and does not match the read-only allowlist (postcondition #3), the hook emits `permissionDecision: deny` with a reason instructing the operator to add the subcommand to the read-only allowlist if it is safe (fail-closed, SEC-002). Confidence: verified by code analysis (fail-closed catch-all in require-review.sh) and BATS test `@test "require-review blocks unknown mutation-shaped jr subcommand (SEC-002)"` (hooks.bats:76).
5. The exit code is always 0 for all business-logic decisions (both allow and deny). Exit code 1 is reserved exclusively for missing `jq` dependency. Confidence: verified by code analysis (emit_allow and emit_deny functions in require-review.sh).

## Invariants

1. The JSON output envelope structure is always `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"|"deny","permissionDecisionReason":"..."}}`. Confidence: verified by code analysis (emit_allow / emit_deny function bodies in require-review.sh).
2. The hook never makes network calls, never spawns subprocesses beyond `jq`, and never reads the filesystem — all decisions are made from the single stdin JSON envelope. Execution is bounded at < 100ms. Confidence: verified by code analysis (full file).
3. The hook is fail-closed for all `jr` subcommands: any `jr` command that is not on the write-block list and not on the read-only allowlist results in deny, not allow. Non-`jr` commands remain on a fast-path allow. This replaced the previous fail-open behavior as of PR #13 (SEC-002). Confidence: verified by code analysis (fail-closed catch-all in require-review.sh).
5. **Write-block is evaluated BEFORE the allowlist (ADV-0-801, PR #15).** A command that matches both a write-block pattern and an allowlist pattern is DENIED — the write-block check wins unconditionally. This ordering was fixed in PR #15 to close a critical bypass: before the fix, `jr issue edit KEY --summary "see jr board"` matched the `jr board` allowlist token and was incorrectly emitted allow. The fix ensures the write-block if-block is evaluated before the read-only allowlist. Confidence: verified by code analysis (write-block if-block ordering rationale comment in require-review.sh). See EC-016.

4. **`--output json` global flag placement creates a non-obvious substring matching boundary.** The command `jr --output json issue view KEY` does NOT contain the substring `jr issue view` because the global flag `--output json` sits between `jr` and `issue`. Therefore, the allowlist must carry both plain forms (e.g., `jr issue view`) and `--output json` forms (e.g., `--output json issue view`) as separate entries. A plain-form entry does not cover the `--output json` form of the same subcommand. This was the root cause of the DI-010 regression: the metrics suite issues `jr --output json issue changelog KEY`, but the v1.1 allowlist only had the plain form. Both families were added explicitly in PR #14. This invariant is documented in the `--output json` boundary doc comment in require-review.sh.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr message "jq is required but not found", no JSON output |
| EC-002 | Empty stdin / malformed JSON | `jq -r '.tool_input.command // empty'` returns empty string; command is not `jr `; emit allow |
| EC-003 | `jr issue comment SEC-123 "enrichment complete"` | Deny with reason containing "review approval" (SEC-001 — comment is a write to the authoritative Jira record) |
| EC-004 | `jr issue edit` with any arguments | Deny with reason containing "review approval" |
| EC-005 | `jr issue move SEC-123 Enriched` | Deny — `jr issue move` is in the write blocklist |
| EC-006 | `jr auth login` | Allow — `jr auth` is in the plain read-only allowlist |
| EC-007 | `ls -la` (non-jr command) | Allow — fast path: no `jr ` substring |
| EC-008 | `jr issue assign SEC-123 @user` | Deny — `jr issue assign` is in the write blocklist |
| EC-009 | `jr issue duplicate SEC-123` (unrecognized subcommand) | Deny with reason "Unrecognized jr subcommand. Add to the read-only allowlist..." (SEC-002 — fail-closed) |
| EC-010 | `jr issue changelog SEC-123` | Allow — explicitly added to the plain read-only allowlist in PR #14 (DI-010 fix; was Deny in v1.1) |
| EC-011 | `jr --output json issue changelog SEC-123` (metrics suite form) | Allow — `--output json issue changelog` is in the `--output json` family allowlist (PR #14) |
| EC-012 | `jr --output json issue view SEC-123` (metrics suite form) | Allow — `--output json issue view` is in the allowlist. Note: `jr issue view` (plain) does NOT match this form due to Invariant #4 |
| EC-013 | `jr --output json assets search objectType=Client` (CMDB query) | Allow — `--output json assets search` is in the allowlist (PR #14) |
| EC-014 | `jr --version` | Allow — explicitly in the allowlist (PR #14) |
| EC-015 | `jr --output json issue comment SEC-123 "msg"` | Deny via write-block if-block (PR #15 — `--output json issue comment ` with trailing space guard is now an explicit write-block entry). **Behavior change from v1.2-v1.6:** previously denied by fail-closed catch-all because `jr issue comment` is NOT a substring of this command (Invariant #4). Now denied earlier and more explicitly by the `--output json` write-block family. |
| EC-016 | `jr issue edit KEY --summary "see jr board"` (write command with embedded allowlist token) | Deny via write-block if-block (PR #15 fix for ADV-0-801): `jr issue edit` matched in the write-block if-block BEFORE the allowlist is evaluated. **Old behavior (bypass — FIXED):** the command contained the allowlist substring `jr board`, which was matched first (old ordering: allowlist before write-block), incorrectly emitting allow. New ordering ensures write-block wins unconditionally (Invariant #5). |

## Canonical Test Vectors

| Input (`tool_input.command`) | Expected Output | Category |
|------------------------------|----------------|----------|
| `ls -la` | `permissionDecision: allow` | happy-path |
| `jr issue view SEC-123` | `permissionDecision: allow` | happy-path |
| `jr sprint list` | `permissionDecision: allow` | happy-path |
| `jr issue changelog SEC-123` | `permissionDecision: allow` | happy-path (was deny in v1.1) |
| `jr --output json issue view SEC-123` | `permissionDecision: allow` | happy-path (metrics suite / Invariant #4) |
| `jr issue comment SEC-123 "enrichment complete"` | `permissionDecision: deny`, reason contains "review approval" | error |
| `jr issue edit SEC-123 --priority Critical` | `permissionDecision: deny`, reason contains "review approval" | error |
| `jr issue move SEC-123 Enriched` | `permissionDecision: deny` | error |
| `jr issue duplicate SEC-123` | `permissionDecision: deny`, reason contains "allowlist" | edge-case (SEC-002 fail-closed) |
| `jr issue edit KEY --summary "see jr board"` | `permissionDecision: deny`, reason contains "review approval" (write-block wins before allowlist token "jr board" reached — ADV-0-801 bypass, now fixed) | edge-case (EC-016) |
| `jr --output json issue edit KEY --priority Critical` | `permissionDecision: deny`, reason contains "review approval" (write-block if-block matches `--output json issue edit` — defense-in-depth for `--output json` write forms, ADV-0-801 PR #15) | edge-case (VP-HOOK-023) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-001 | For all inputs where command contains `jr issue comment`, `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`, output always contains `"permissionDecision":"deny"` | integration / BATS |
| VP-HOOK-002 | Hook exit code is always 0 when jq is present (both allow and deny paths) | integration / BATS |
| VP-HOOK-003 | Any unrecognized `jr` subcommand receives deny (fail-closed invariant, SEC-002) | integration / BATS (`@test "require-review blocks unknown mutation-shaped jr subcommand (SEC-002)"` hooks.bats:76) |
| VP-HOOK-020 | `jr issue changelog` plain form receives allow (DI-010 resolution) | integration / BATS (`@test "require-review allows jr issue changelog plain form"` hooks.bats:21) |
| VP-HOOK-021 | `jr --output json issue changelog` receives allow (metrics suite form, DI-010) | integration / BATS (`@test "require-review allows jr issue changelog json form (metrics suite)"` hooks.bats:27) |
| VP-HOOK-022 | `jr --output json issue view` receives allow — validates that the `--output json` family is covered separately from plain forms (Invariant #4) | integration / BATS (`@test "require-review allows jr --output json issue view (metrics suite)"` hooks.bats:33) |
| VP-HOOK-023 | A command containing `--output json issue comment/edit/move/assign/create` receives deny (write-block if-block — defense-in-depth for `--output json` write forms, per Invariant #4 and ADV-0-801 PR #15 fix) | integration / BATS |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-01 |
| L2 Domain Invariants | Iron Law: NO JIRA UPDATE WITHOUT REVIEW APPROVAL FIRST |
| Architecture Module | C-12 (require-review-hook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/require-review.sh` (115 lines, post-PR #15) + `.ps1` sibling |
| **Confidence** | high — explicit allow/deny logic fully visible in source; BATS tests at `tests/hooks.bats:9-177` (26 require-review tests, including the 12 PR-15 bypass/--output json/regression tests, and the 2 PR-17 DI-005 assign/create tests at :426/:433) exercise all documented paths; 165 @tests total (hooks 59, skills 81, integration 11, parity 14); PR #15 added 12 new tests (bypass scenarios and regressions); PR #17 added 15 new tests across all 6 hooks (including 2 require-review assign/create tests) |
| **Extraction Date** | 2026-07-19 |
| **Last Verified Against** | commit d181ca2 (HEAD post PR #17) |

#### Change Log

**PR #13 (commit f450d9f, 2026-07-19) — two behavioral changes (v1.0 → v1.1):**

| Change | SEC ID | Old Behavior (v1.0) | New Behavior (v1.1) |
|--------|--------|---------------------|---------------------|
| `jr issue comment` routing | SEC-001 | Allow — comment was explicitly whitelisted | Deny — moved into the write-operations block; reason contains "review approval" |
| Unknown jr subcommand routing | SEC-002 | Allow — fail-open | Deny — fail-closed; reason instructs operator to add to read-only allowlist if safe |

**Rationale (from PR #13 source comments):** `jr issue comment` posts to the authoritative Jira record and is therefore a write operation that must pass the same review gate as field edits. Unknown subcommands are denied rather than allowed to prevent future `jr` releases from adding write subcommands that bypass the gate silently.

**PR #14 (commit 0ec794a, 2026-07-19) — read-only allowlist expansion (v1.1 → v1.2):**

| Change | Driver | Old Behavior (v1.1) | New Behavior (v1.2) |
|--------|--------|---------------------|---------------------|
| `jr issue changelog` plain form | DI-010: metrics pipeline blocked | Deny (not on allowlist) | Allow (added to plain-form list, line 65) |
| `jr assets search`, `jr assets view` plain forms | CMDB queries for metrics | Deny | Allow (lines 66-67) |
| `jr --version` | Health-check / diagnostics | Deny | Allow (line 73) |
| `--output json issue view/list/comments/changelog/assets` | DI-010: metrics suite uses global `--output json` flag | Deny (plain forms don't match) | Allow (separate family, lines 74-78) |
| `--output json assets search/view` | CMDB queries via metrics suite | Deny | Allow (lines 79-80) |

**DI-010 root cause (documented in the `--output json` boundary doc comment in require-review.sh):** `jr issue view KEY` is NOT a substring of `jr --output json issue view KEY` because the global flag `--output json` sits between `jr` and `issue`. Separate allowlist entries are required for each family. See Invariant #4.

**PR #15 (commit d304fa5, 2026-07-19) — CRITICAL evaluation-order fix (ADV-0-801) and `--output json` write-block addition (v1.6 → v1.7):**

| Change | Driver | Old Behavior (v1.2-v1.6) | New Behavior (v1.7) |
|--------|--------|--------------------------|---------------------|
| Write-block evaluated before allowlist | ADV-0-801 (CRITICAL bypass) | allowlist evaluated first (lines 60-82), write-block at lines 88-94 — a command containing both a write-block token AND an allowlist token was incorrectly ALLOWED | write-block evaluated first (lines 67-78), allowlist at lines 88-110 — write-block wins unconditionally |
| `--output json` write forms added to write-block | ADV-0-801 defense-in-depth | `jr --output json issue edit/comment/move/assign/create` hit fail-closed only | `--output json issue comment/edit/move/assign/create` added as explicit write-block entries (lines 72-76) |

**ADV-0-801 bypass example (now fixed):** `jr issue edit KEY --summary "see jr board"` — this command contains the substring `jr board` (a valid allowlist entry). Under the old ordering (allowlist first), the `jr board` check matched at line ~97 (old), emitting allow BEFORE the write-block check at line ~88. Under the new ordering (write-block first), `jr issue edit` is matched at line 68, emitting deny before the allowlist is ever evaluated.

**BATS test changes (PR #14):** Lines 21-67 in `hooks.bats` are eight new allow tests covering changelog plain/json forms, `--output json` issue view/list/comments, assets search/view (CMDB), and `jr --version`. Total test count: 130 → 138.

**BATS test changes (PR #15):** 12 new tests covering `--output json` write-block family (bypass scenarios) and regression coverage for the ADV-0-801 allowlist-precedence fix. Total test count: 138 → 150.

**PR #17 (commit d181ca2, 2026-07-19) — DI-005 assign/create BATS coverage (v1.9 → v1.10):**

| Change | Driver | Old Coverage | New Coverage |
|--------|--------|-------------|--------------|
| `jr issue assign` deny BATS test | DI-005: no dedicated BATS verify | Code analysis only (write-block if-block) | `@test "require-review blocks jr issue assign without review (DI-005)"` (hooks.bats:426) |
| `jr issue create` deny BATS test | DI-005: no dedicated BATS verify | Code analysis only (write-block if-block) | `@test "require-review blocks jr issue create without review (DI-005)"` (hooks.bats:433) |

**BATS test changes (PR #17):** 2 new require-review tests for assign/create + 13 tests for other hooks. Total test count: 150 → 165 (hooks 44→59).

#### Evidence Types Used

- **guard clause**: fast-path allow for non-`jr ` commands (fast-path guard in require-review.sh)
- **guard clause**: write-block evaluated FIRST — 10-entry write-block if-block (5 plain + 5 `--output json`) → `emit_deny` with "review approval" (write-block if-block in require-review.sh)
- **guard clause**: allowlist evaluated SECOND — 21-entry explicit read-only allowlist (14 plain + 7 `--output json`), all `emit_allow` (read-only allowlist in require-review.sh)
- **guard clause**: fail-closed catch-all `emit_deny` for unrecognized subcommands (fail-closed catch-all in require-review.sh)
- **type constraint**: JSON envelope structure enforced by `jq -nc` output template
- **assertion**: `command -v jq` check — exits 1 if dependency missing (jq-availability guard in require-review.sh)
- **documentation**: write-block if-block ordering rationale comment explicitly documents write-block-first ordering, ADV-0-801 bypass, and `--output json` write-block family; `--output json` boundary doc comment documents the `--output json` substring non-matching invariant for the allowlist
- **inferred**: PowerShell `.ps1` sibling is behaviorally identical (enforced by `parity.bats`; PS1 updated in PR #15 to match new ordering and `--output json` write-block entries)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin once; writes stdout (JSON envelope) |
| **Global state access** | none |
| **Deterministic** | yes — same input always produces same JSON output |
| **Thread safety** | not applicable (single-process hook invoked per tool event) |
| **Overall classification** | pure core (deterministic stdin→stdout transformer, no side effects) |

#### Refactoring Notes

The hook is pure: it reads stdin, applies pattern matching to a string field, and emits a deterministic JSON response. Suitable for formal property verification of the allow/deny routing logic. No refactoring needed for formal verification.

The `--output json` global-flag design means the allowlist cannot be expressed as a simple set of subcommand names — it must carry separate entries for plain forms and each global-flag variant. If the `jr` CLI adds more global flags in the future (e.g., `--format yaml`), corresponding allowlist families would need to be added. This is a known extensibility constraint, not a defect.

**Security extensibility note (ADV-0-007, updated ADV-0-801):** `jr --output json issue comment` is now denied by the write-block if-block (PR #15 — `--output json issue comment ` entry added to the write-block). Prior to PR #15, it was denied only by the fail-closed catch-all — because `jr issue comment` is NOT a substring of `jr --output json issue comment` (Invariant #4 — the global flag breaks the substring). The defense-in-depth recommendation from ADV-0-007 (add `--output json` write forms to the write-block list) is now **RESOLVED**: PR #15 added all five `--output json` write forms (`--output json issue comment/edit/move/assign/create`) as explicit write-block entries in the write-block if-block. The fail-closed catch-all remains as a last-resort backstop.

**Resolved (v1.1 drift item):** `jr issue changelog` was identified in v1.1 as a correctness gap blocking the metrics pipeline under fail-closed behavior. PR #14 (commit 0ec794a) added both `jr issue changelog` (plain) and `--output json issue changelog` (json form) to the allowlist, resolving DI-010. The v1.2 revision reflects this resolution.

**Resolved (ADV-0-801 critical bypass):** PR #15 (commit d304fa5) fixed the allowlist-before-write-block evaluation order. The old order allowed a write command containing an embedded allowlist substring (e.g., `jr issue edit KEY --summary "see jr board"` matched `jr board`) to bypass the write gate. The new order evaluates the write-block first, making bypass impossible regardless of argument content.

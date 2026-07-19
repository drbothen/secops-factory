---
document_type: behavioral-contract
level: L3
version: "1.3"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/require-review.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: ""
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/require-review.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-01
lifecycle_status: active
introduced: v0.7.0
modified: ["v0.9.x-PR13-2026-07-19", "v0.9.x-PR14-2026-07-19", "v0.9.x-ADV0-001-ADV0-007-2026-07-19"]
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

## Preconditions

1. The hook receives a Claude Code `PreToolUse/Bash` event envelope via stdin as JSON, containing `tool_input.command` (string). Confidence: verified by code analysis (`hooks/require-review.sh:45`).
2. `jq` is installed and available on `$PATH`. If absent, the hook exits with code 1 and an error to stderr; it never emits a `permissionDecision` envelope. Confidence: verified by code analysis (`hooks/require-review.sh:20-23`).
3. The hook is wired via `hooks.json` to fire on `PreToolUse` events for the `Bash` tool only. Confidence: verified by code analysis (`hooks/hooks.json`).

## Postconditions

1. If `tool_input.command` does not contain the substring `jr `, the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (`hooks/require-review.sh:48-50`) and BATS test `hooks.bats:9-13`.
2. If `tool_input.command` contains any of `jr issue comment`, `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`, the hook emits `permissionDecision: deny` with a reason string containing "review approval". The deny reason names all five blocked subcommands explicitly. Confidence: verified by code analysis (`hooks/require-review.sh:88-94`) and BATS tests `hooks.bats:69-74, 82-87, 89-93`.
3. If `tool_input.command` contains any entry from the explicit read-only allowlist (evaluated before the deny check), the hook emits `permissionDecision: allow` and exits 0. The allowlist has two families: Confidence: verified by code analysis (`hooks/require-review.sh:60-82`) and BATS tests `hooks.bats:15-19`.

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

4. For any `jr` subcommand that does not match the explicit read-only allowlist (postcondition #3) and does not match the explicit write-block list (postcondition #2), the hook emits `permissionDecision: deny` with a reason instructing the operator to add the subcommand to the read-only allowlist if it is safe (fail-closed, SEC-002). Confidence: verified by code analysis (`hooks/require-review.sh:97-98`) and BATS test `hooks.bats:76-80`.
5. The exit code is always 0 for all business-logic decisions (both allow and deny). Exit code 1 is reserved exclusively for missing `jq` dependency. Confidence: verified by code analysis (`hooks/require-review.sh:29, 41`).

## Invariants

1. The JSON output envelope structure is always `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"|"deny","permissionDecisionReason":"..."}}`. Confidence: verified by code analysis (`hooks/require-review.sh:27-42`).
2. The hook never makes network calls, never spawns subprocesses beyond `jq`, and never reads the filesystem — all decisions are made from the single stdin JSON envelope. Execution is bounded at < 100ms. Confidence: verified by code analysis (full file).
3. The hook is fail-closed for all `jr` subcommands: any `jr` command that is not on the explicit read-only allowlist results in deny, not allow. Non-`jr` commands remain on a fast-path allow. This replaced the previous fail-open behavior as of PR #13 (SEC-002). Confidence: verified by code analysis (`hooks/require-review.sh:97-98`).
4. **`--output json` global flag placement creates a non-obvious substring matching boundary.** The command `jr --output json issue view KEY` does NOT contain the substring `jr issue view` because the global flag `--output json` sits between `jr` and `issue`. Therefore, the allowlist must carry both plain forms (e.g., `jr issue view`) and `--output json` forms (e.g., `--output json issue view`) as separate entries. A plain-form entry does not cover the `--output json` form of the same subcommand. This was the root cause of the DI-010 regression: the metrics suite issues `jr --output json issue changelog KEY`, but the v1.1 allowlist only had the plain form. Both families were added explicitly in PR #14. This invariant is documented in the source at `hooks/require-review.sh:55-59`.

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
| EC-015 | `jr --output json issue comment SEC-123 "msg"` | Deny via fail-closed catch-all (lines 97-98) — `jr issue comment` is NOT a substring of this command (Invariant #4: `--output json` sits between `jr` and `issue`, breaking the substring match); `--output json issue comment` (singular) is also not on the allowlist (allowlist has plural `--output json issue comments`). Reason contains "Unrecognized jr subcommand. Add to the read-only allowlist..." — the SEC-001 comment gate is NOT what triggers the deny here |

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

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-001 | For all inputs where command contains `jr issue comment`, `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`, output always contains `"permissionDecision":"deny"` | integration / BATS |
| VP-HOOK-002 | Hook exit code is always 0 when jq is present (both allow and deny paths) | integration / BATS |
| VP-HOOK-003 | Any unrecognized `jr` subcommand receives deny (fail-closed invariant, SEC-002) | integration / BATS (`hooks.bats:76-80`) |
| VP-HOOK-020 | `jr issue changelog` plain form receives allow (DI-010 resolution) | integration / BATS (`hooks.bats:21-25`) |
| VP-HOOK-021 | `jr --output json issue changelog` receives allow (metrics suite form, DI-010) | integration / BATS (`hooks.bats:27-31`) |
| VP-HOOK-022 | `jr --output json issue view` receives allow — validates that the `--output json` family is covered separately from plain forms (Invariant #4) | integration / BATS (`hooks.bats:33-37`) |

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
| **Path** | `plugins/secops-factory/hooks/require-review.sh` (99 lines, post-PR #14) + `.ps1` sibling |
| **Confidence** | high — explicit allow/deny logic fully visible in source; BATS tests at `tests/hooks.bats:9-93` exercise all documented paths; 138 total tests in the suite |
| **Extraction Date** | 2026-07-19 |
| **Last Verified Against** | commit 0ec794a (PR #14 merge commit) |

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

**DI-010 root cause (documented in source at `hooks/require-review.sh:55-59`):** `jr issue view KEY` is NOT a substring of `jr --output json issue view KEY` because the global flag `--output json` sits between `jr` and `issue`. Separate allowlist entries are required for each family. See Invariant #4.

**BATS test changes (PR #14):** Lines 21-67 in `hooks.bats` are nine new allow tests covering changelog plain/json forms, `--output json` issue view/list/comments, assets search/view (CMDB), and `jr --version`. Total test count: 130 → 138.

#### Evidence Types Used

- **guard clause**: fast-path allow for non-`jr ` commands (`hooks/require-review.sh:48-50`)
- **guard clause**: 21-entry explicit read-only allowlist (14 plain + 7 `--output json`), all `emit_allow` (`hooks/require-review.sh:60-82`)
- **guard clause**: 5-entry explicit write-block list → `emit_deny` with "review approval" (`hooks/require-review.sh:88-94`)
- **guard clause**: fail-closed catch-all `emit_deny` for unrecognized subcommands (`hooks/require-review.sh:97-98`)
- **type constraint**: JSON envelope structure enforced by `jq -nc` output template
- **assertion**: `command -v jq` check — exits 1 if dependency missing (`hooks/require-review.sh:20-23`)
- **documentation**: PR #14 header comment explicitly documents the `--output json` substring non-matching invariant (`hooks/require-review.sh:55-59`)
- **inferred**: PowerShell `.ps1` sibling is behaviorally identical (enforced by `parity.bats`; PS1 confirmed to carry the same 14 plain + 7 `--output json` entries in `$readOnly` array at `require-review.ps1:48-59`)

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

**Security extensibility note (ADV-0-007):** `jr --output json issue comment` is denied by the fail-closed catch-all, NOT by the explicit SEC-001 write-block check. This is because `jr issue comment` is not a substring of `jr --output json issue comment` (Invariant #4 — the global flag breaks the substring). If the fail-closed behavior were ever relaxed or removed, the `--output json` forms of write operations (`jr --output json issue comment`, `jr --output json issue edit`, etc.) would bypass the SEC-001/SEC-002 gate entirely — they match neither the write-block list nor the allowlist. Defense-in-depth recommendation: add explicit `--output json issue comment`, `--output json issue edit`, `--output json issue move`, `--output json issue assign`, `--output json issue create` patterns to the write-block list in a future PR.

**Resolved (v1.1 drift item):** `jr issue changelog` was identified in v1.1 as a correctness gap blocking the metrics pipeline under fail-closed behavior. PR #14 (commit 0ec794a) added both `jr issue changelog` (plain) and `--output json issue changelog` (json form) to the allowlist, resolving DI-010. The v1.2 revision reflects this resolution.

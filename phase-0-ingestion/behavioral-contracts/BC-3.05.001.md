---
document_type: behavioral-contract
level: L3
version: "1.2"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/handoff-validator.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: |
  4cd4245b0a60683b59f6d8130be7331b8571083ed8c47fab107d485a86c6ee43  plugins/secops-factory/hooks/handoff-validator.sh
  56c828f1eeb8acb7d7107c39f6e101d4f45fadd325cc60efab03e605833d6100  plugins/secops-factory/hooks/handoff-validator.ps1
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/handoff-validator.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-05
lifecycle_status: active
introduced: v0.7.0
modified: ["v1.1-ADV-0-403-2026-07-19", "v1.2-ADV-0-507-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.05.001: handoff-validator Hook — SubagentStop Empty-Output Guard

## Preconditions

1. The hook receives a `SubagentStop` event envelope via stdin as JSON, containing `result` (string). Confidence: verified by code analysis (`hooks/handoff-validator.sh:21`).
2. `jq` is installed and available on `$PATH`. If absent, the hook exits with code 1 and error to stderr. Confidence: verified by code analysis (`hooks/handoff-validator.sh:15-18`).
3. The hook is non-blocking (advisory only): it is a `SubagentStop` hook, which cannot block; it can only warn. Confidence: verified by code analysis (no `permissionDecision` envelope is emitted).

## Postconditions

1. If `result` is an empty string (zero length), the hook writes a WARNING to stderr containing the phrase "EMPTY output". The warning instructs the operator not to treat empty output as "no findings". Confidence: verified by code analysis (`hooks/handoff-validator.sh:24-26`) and test `@test "handoff-validator warns on empty result"` (hooks.bats:138).
2. If `result` is non-empty but shorter than 40 characters, the hook writes a WARNING to stderr containing the phrase "suspiciously short" and includes the character count. Confidence: verified by code analysis (`hooks/handoff-validator.sh:27-29`) and test `@test "handoff-validator warns on short result"` (hooks.bats:144).
3. If `result` is 40 or more characters, the hook writes nothing to stderr (silent). Confidence: verified by code analysis and test `@test "handoff-validator silent on normal result"` (hooks.bats:150).
4. The hook always exits 0. Confidence: verified by code analysis (`hooks/handoff-validator.sh:31`).

## Invariants

1. The warning thresholds are hardcoded: 0 characters = EMPTY warning; 1-39 characters = suspiciously short warning; 40+ characters = silent. These thresholds are constants in the script and do not vary. Confidence: verified by code analysis (`hooks/handoff-validator.sh:24, 27`).
2. The hook never modifies the subagent result or blocks the handoff — it only emits advisory warnings. A silent hook pass does not mean the review was high quality; it only means the result exceeded the minimum length threshold. Confidence: verified by code analysis.
3. The hook does not parse the result content for quality signals — it only measures character count. Substantive quality assessment is the responsibility of `adversarial-review-secops` skill. Confidence: verified by code analysis.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr "jq is required but not found" |
| EC-002 | `result` field missing from JSON | `jq -r '.result // empty'` returns empty string; triggers EMPTY warning |
| EC-003 | `result` = "ok" (2 chars) | Warns "suspiciously short (2 chars)" |
| EC-004 | `result` = "Review complete. SUBSTANTIVE findings: 3 items..." (62 chars) | Silent — no warning |
| EC-005 | `result` = exactly 39 chars | Warns "suspiciously short (39 chars)" |
| EC-006 | `result` = exactly 40 chars | Silent |
| EC-007 | Malformed JSON stdin | `jq` returns empty for result; triggers EMPTY warning |

## Canonical Test Vectors

| Input (`result` field) | Expected stderr | Category |
|------------------------|----------------|----------|
| `""` (empty) | Contains "EMPTY output" | error |
| `"ok"` | Contains "suspiciously short" | error |
| `"Review complete. SUBSTANTIVE findings: 3 items requiring analyst attention. Overall quality score: 6.2/10."` | empty (no warning) | happy-path |
| Missing `result` field | Contains "EMPTY output" | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-013 | Empty result always triggers EMPTY output warning | integration / BATS |
| VP-HOOK-014 | Result under 40 chars triggers suspiciously short warning | integration / BATS |
| VP-HOOK-015 | Substantive result (40+ chars) produces no warning | integration / BATS |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-05 |
| L2 Domain Invariants | Adversarial convergence integrity (silent failure detection) |
| Architecture Module | C-16 (handoff-validator-hook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/handoff-validator.sh` (31 lines) + `.ps1` sibling |
| **Confidence** | high — simple length check; BATS tests `@test "handoff-validator warns on empty result"` (hooks.bats:138), `@test "handoff-validator warns on short result"` (hooks.bats:144), `@test "handoff-validator silent on normal result"` (hooks.bats:150) exercise all three cases exactly |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **guard clause**: `[ "$RESULT_LEN" -eq 0 ]` and `[ "$RESULT_LEN" -lt 40 ]` explicit threshold checks (lines 24, 27)
- **documentation**: warning messages document the failure modes being guarded against

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin once; writes stderr conditionally |
| **Global state access** | none |
| **Deterministic** | yes — same result length always produces same warning behavior |
| **Thread safety** | not applicable |
| **Overall classification** | pure core |

#### Refactoring Notes

Pure. The 40-character threshold is a heuristic, not a formally derived value. The BATS test for "normal result" uses a 106-character string. The threshold may need calibration if typical reviewer outputs change in length. This is noted as an architecture-level question: should the threshold be configurable?

**Undocumented behavior (ambiguity):** The 40-character threshold is hardcoded and not documented anywhere outside the source code. A reviewer returning "No findings. The analysis is complete and accurate." (50 chars) passes silently even though this is a suspiciously terse for a substantive review pass. The threshold is a rough guard against crashes, not a quality gate.

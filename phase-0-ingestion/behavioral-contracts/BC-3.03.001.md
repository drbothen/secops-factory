---
document_type: behavioral-contract
level: L3
version: "1.1"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/disposition-guard.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: "ede6ff97959cbcb1a137ed8f28a1271250dd46bcefc4d2b397d7d591dd180289"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/disposition-guard.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-03
lifecycle_status: active
introduced: v0.7.0
modified: ["v1.1-ADV-0-403-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.03.001: disposition-guard Hook — Alternatives-Required Gate

## Preconditions

1. The hook receives a `PreToolUse/Write` event envelope via stdin as JSON, containing `tool_input.file_path` (string) and `tool_input.content` (string). Confidence: verified by code analysis (`hooks/disposition-guard.sh:39-40`).
2. `jq` is installed and available on `$PATH`. Confidence: verified by code analysis (`hooks/disposition-guard.sh:14-17`).
3. The hook fires on the same `PreToolUse/Write` events as `enrichment-completeness`. Both hooks run on every Write event; each applies its own path-pattern filter. Confidence: inferred from hooks.json wiring pattern and BATS test structure.

## Postconditions

1. If `file_path` does not contain `investigation` as a substring, the hook emits `permissionDecision: allow` (fast path). Confidence: verified by code analysis (`hooks/disposition-guard.sh:43-45`).
2. If `file_path` contains `investigation` but `content` does not contain the string "Disposition" (case-insensitive), the hook emits `permissionDecision: allow` — the document is still in-progress. Confidence: verified by code analysis (`hooks/disposition-guard.sh:48-51`) and test `@test "disposition-guard allows investigation without disposition yet"` (hooks.bats:164).
3. If `file_path` contains `investigation` AND `content` contains "Disposition" AND `content` does NOT contain "Alternatives Considered" (case-insensitive), the hook emits `permissionDecision: deny` with a reason containing "Alternatives Considered". Confidence: verified by code analysis (`hooks/disposition-guard.sh:54-56`) and test `@test "disposition-guard blocks disposition without alternatives"` (hooks.bats:170).
4. If `file_path` contains `investigation` AND `content` contains both "Disposition" and "Alternatives Considered", the hook emits `permissionDecision: allow`. Confidence: verified by code analysis (`hooks/disposition-guard.sh:58`) and test `@test "disposition-guard allows disposition with alternatives"` (hooks.bats:177).
5. Both "Disposition" and "Alternatives Considered" checks are case-insensitive (`grep -qiF`). Confidence: verified by code analysis (`hooks/disposition-guard.sh:48, 54`).

## Invariants

1. The hook only blocks at the Disposition-present + Alternatives-absent intersection. It never blocks an in-progress investigation file (one without a Disposition section yet). Confidence: verified by code analysis.
2. The hook does not validate the quality or count of alternatives — it only checks that the section heading appears. One alternative or ten alternatives are treated identically by this hook. Confidence: verified by code analysis.
3. The deny reason always references the specific missing section name "Alternatives Considered" and contains guidance about documenting at least 2 alternative hypotheses. Confidence: verified by code analysis (`hooks/disposition-guard.sh:55`).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr error, no JSON output |
| EC-002 | File path `/tmp/readme.md` | Allow — not an investigation file |
| EC-003 | Investigation file with no Disposition section | Allow — in-progress; gate only fires once Disposition is declared |
| EC-004 | Investigation file with "Disposition: True Positive" but no Alternatives Considered | Deny with reason mentioning "Alternatives Considered" |
| EC-005 | Investigation file with both "Disposition" and "Alternatives Considered" sections | Allow |
| EC-006 | Investigation file with "disposition" (lowercase) section | Deny if Alternatives absent — `grep -qiF` matches case-insensitively |
| EC-007 | Content containing "Disposition" in body text (not a section header) | Allow if "Alternatives Considered" also present anywhere; Deny if absent. The check is on substring presence in the full content, not section-header structure. |
| EC-008 | Malformed JSON stdin | `jq` returns empty string for file_path; path doesn't match `investigation`; emit allow |

## Canonical Test Vectors

| Input (file_path → content) | Expected Output | Category |
|-----------------------------|----------------|----------|
| `/tmp/readme.md` → any | `permissionDecision: allow` | happy-path |
| `investigation-ALERT-001.md` → "# Alert Details\nEvidence..." (no Disposition) | `permissionDecision: allow` | happy-path |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\n# Evidence\n..." | `permissionDecision: deny`, reason contains "Alternatives Considered" | error |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\n# Alternatives Considered\n1. FP...\n2. BTP..." | `permissionDecision: allow` | happy-path |
| `investigation-ALERT-001.md` → "# disposition\nFalse Positive" (lowercase) | `permissionDecision: deny` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-007 | Investigation file with Disposition but no Alternatives always produces deny | integration / BATS |
| VP-HOOK-008 | Investigation file without Disposition always produces allow (in-progress gate) | integration / BATS |
| VP-HOOK-009 | Non-investigation files always produce allow | integration / BATS |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-03 |
| L2 Domain Invariants | Anti-confirmation-bias invariant: NO INVESTIGATION DISPOSITION SAVED WITHOUT ALTERNATIVES CONSIDERED FIRST — enforces that analysts document alternative hypotheses before committing a TP/FP/BTP disposition (prevents anchoring on the first interpretation) |
| Architecture Module | C-14 (disposition-guard-hook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/disposition-guard.sh` (59 lines) + `.ps1` sibling |
| **Confidence** | high — three-state logic (non-investigation / in-progress / complete-without-alternatives) fully visible in source; BATS tests `@test "disposition-guard allows non-investigation files"` (hooks.bats:158), `@test "disposition-guard allows investigation without disposition yet"` (hooks.bats:164), `@test "disposition-guard blocks disposition without alternatives"` (hooks.bats:170), `@test "disposition-guard allows disposition with alternatives"` (hooks.bats:177) exercise all four cases |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **guard clause**: file path substring check for `investigation` (line 43)
- **guard clause**: case-insensitive content check for "Disposition" presence (lines 48-51)
- **guard clause**: case-insensitive content check for "Alternatives Considered" absence (lines 54-56)
- **documentation**: deny reason text documents the intent (prevent confirmation bias via undocumented dispositions)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin once; writes stdout |
| **Global state access** | none |
| **Deterministic** | yes |
| **Thread safety** | not applicable |
| **Overall classification** | pure core |

#### Refactoring Notes

Pure. The three-state routing logic (non-investigation / in-progress / complete) is clearly separated and verifiable. No refactoring needed.

**Undocumented behavior (ambiguity):** The "Alternatives Considered" section check is by substring presence in the full document content. If an analyst writes "No alternatives considered" as free text in the body of the Disposition section (not as a section heading), the gate passes incorrectly. The hook does not enforce minimum alternative count (the deny message says "at least 2 alternative hypotheses" but the hook only checks for the section heading). The quality of alternatives is validated by `review-enrichment`, not by this hook.

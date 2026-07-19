---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/enrichment-completeness.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: ""
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/enrichment-completeness.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-02
lifecycle_status: active
introduced: v0.6.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.02.001: enrichment-completeness Hook — Section Completeness Gate

## Preconditions

1. The hook receives a `PreToolUse/Write` event envelope via stdin as JSON, containing `tool_input.file_path` (string) and `tool_input.content` (string). Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:38-39`).
2. `jq` is installed and available on `$PATH`. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:14-17`).
3. The hook is wired to fire on `PreToolUse` events for the `Write` tool (file-save operations). Confidence: inferred from hook purpose and BATS test payloads (`hooks.bats:43-60`).

## Postconditions

1. If `file_path` contains neither `enrichment` nor `investigation` as a substring, the hook emits `permissionDecision: allow` (fast path). Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:42-44`).
2. For enrichment files (file_path contains `enrichment`): if any of the five required sections — "Executive Summary", "Vulnerability Details", "Severity Metrics", "Priority Assessment", "Remediation Guidance" — are absent from `content`, the hook emits `permissionDecision: deny` with a reason containing "Missing required sections" and listing the missing section names. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:47-58`).
3. For investigation files (file_path contains `investigation`): if any of the four required sections — "Executive Summary", "Alert Details", "Disposition", "Next Actions" — are absent from `content`, the hook emits `permissionDecision: deny` with a reason listing the missing sections. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:62-74`).
4. If all required sections are present, the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:76`) and test `hooks.bats:55-60`.
5. Section detection uses exact string matching (`grep -qF`); section headings must appear verbatim (case-sensitive) in the content. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:50, 64`).

## Invariants

1. The hook checks presence of section heading strings, not their content. A section heading with empty body passes the gate. This is a structural completeness check, not a content quality check. Confidence: verified by code analysis (grep logic only checks for heading string presence).
2. A file matching both `enrichment` and `investigation` as substrings would be checked against the enrichment list (first branch wins). Confidence: verified by code analysis — the two `if` blocks are non-overlapping in practice (`enrichment` check fires first, `investigation` check fires only if `file_path == *investigation*`). In practice, no filename matches both substrings.
3. The hook never blocks a file whose path does not match either pattern, even if the content contains enrichment-like structure. File path is the routing discriminator. Confidence: verified by code analysis.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr error, no JSON output |
| EC-002 | File path `/tmp/readme.md` | Allow — neither `enrichment` nor `investigation` in path |
| EC-003 | File path `enrichment-CVE-2024-1234.md`, content has only "Executive Summary" | Deny — 4 of 5 required sections missing |
| EC-004 | File path `investigation-ALERT-001.md`, content has only "# Alert Details\nSome data" | Allow — no Disposition section yet; investigation is in-progress, not complete |
| EC-005 | File path `investigation-ALERT-001.md`, content has "Disposition" but missing "Alternatives Considered" | Allow here — `enrichment-completeness` does not check Alternatives Considered; that is `disposition-guard`'s responsibility |
| EC-006 | File path `enrichment-CVE-2024-1234.md`, all 5 sections present as `##` headings | Allow |
| EC-007 | Malformed JSON stdin | `jq -r '.tool_input.file_path // empty'` returns empty; path doesn't match either pattern; emit allow |
| EC-008 | Section present but misspelled (e.g., "Remediation Guidance " with trailing space) | The grep uses exact `-F` match; trailing space in content would fail. However the check is on the content string, not the heading — if "Remediation Guidance" appears anywhere in content (e.g., in body text), the check passes. |

## Canonical Test Vectors

| Input (file_path → content excerpt) | Expected Output | Category |
|--------------------------------------|----------------|----------|
| `/tmp/readme.md` → any content | `permissionDecision: allow` | happy-path |
| `enrichment-CVE-2024-1234.md` → all 5 sections present | `permissionDecision: allow` | happy-path |
| `enrichment-CVE-2024-1234.md` → only "Executive Summary" | `permissionDecision: deny`, reason contains "Missing required sections" | error |
| `investigation-ALERT-001.md` → "Alert Details" only (no Disposition) | `permissionDecision: allow` | edge-case |
| `investigation-ALERT-001.md` → all 4 sections present | `permissionDecision: allow` | happy-path |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-004 | Enrichment file with missing section always produces deny with that section named in reason | integration / BATS |
| VP-HOOK-005 | Non-enrichment/investigation paths always produce allow regardless of content | integration / BATS |
| VP-HOOK-006 | Investigation file with Disposition but missing Alternatives Considered still allows (responsibility boundary with disposition-guard) | integration / BATS |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-02 |
| L2 Domain Invariants | Iron Law: NO JIRA UPDATE WITHOUT COMPLETED ENRICHMENT FIRST (structural gate) |
| Architecture Module | C-13 (enrichment-completeness-hook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/enrichment-completeness.sh` (77 lines) + `.ps1` sibling |
| **Confidence** | high — section lists are hardcoded in source; BATS tests at `tests/hooks.bats:41-60` exercise allow and deny paths for enrichment files |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **guard clause**: `if [[ "$FILE_PATH" != *"enrichment"* ]] && [[ "$FILE_PATH" != *"investigation"* ]]` fast path (line 42)
- **guard clause**: `for section in ...` loop with `grep -qF` presence check (lines 49-53)
- **type constraint**: required section names are hardcoded string literals
- **documentation**: section names match template headings in `templates/security-enrichment-tmpl.yaml` (but enforcement is by string match, not template schema)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin once; writes stdout |
| **Global state access** | none |
| **Deterministic** | yes — same file_path and content always produce the same decision |
| **Thread safety** | not applicable |
| **Overall classification** | pure core |

#### Refactoring Notes

Pure stdin→stdout transformer. The section-detection logic is a string membership check; suitable for property-based verification of the allow/deny routing logic against a defined section vocabulary. No refactoring needed.

**Undocumented behavior (ambiguity):** The enrichment required-section list (5 items) and the investigation required-section list (4 items) are hardcoded in the hook script. The template files (`security-enrichment-tmpl.yaml`, `event-investigation-tmpl.yaml`) define the full section structure but the hook does not read them at runtime. If templates are updated to add required sections, the hook must be manually updated — there is no automated sync. This drift risk is noted for architecture attention.

**Undocumented behavior:** The investigation check allows saving a file with no Disposition section (EC-004 above). This is correct: investigators save partial work-in-progress. The `disposition-guard` hook separately handles the constraint that once a Disposition section appears, Alternatives Considered must also appear. This two-hook coordination pattern is intentional but undocumented in either hook.

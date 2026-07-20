---
document_type: behavioral-contract
level: L3
version: "1.6"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/enrichment-completeness.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: "bee4d63"
  db98184414071b51fa93542872bbfea99cd904ee1d03d0d2bf1b0518948f79ea  plugins/secops-factory/hooks/enrichment-completeness.sh
  5348452f0ff97b2ebc70c617d6a7cc079270562b0927c2f344b3d4f824359563  plugins/secops-factory/hooks/enrichment-completeness.ps1
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/enrichment-completeness.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-02
lifecycle_status: active
introduced: v0.6.0
modified: ["v1.1-ADV-0-402-ADV-0-403-ADV-0-507-2026-07-19", "v1.2-ADV-0-501-2026-07-19", "v1.3-ADV-0-604-ADV-0-606-2026-07-19", "v1.4-ADV-0-803-2026-07-19", "v1.5-ADV-0-B01-2026-07-19", "v1.6-RESYNC-PR17-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.02.001: enrichment-completeness Hook — Section Completeness Gate

> **Revision history:**
> - v1.6 (2026-07-19): RESYNC-PR17: DI-014 **RESOLVED** — PR #17 replaced bare `grep -qF` substring checks with heading-anchored `grep -qiE "^#{1,6}[[:space:]]+<section>"` for both enrichment and investigation section lists (`enrichment-completeness.sh:52, 68`). Body text mentioning a section name no longer falsely satisfies the check. Invariant #1 and EC-008 updated to RESOLVED. 9 new BATS tests added (hooks.bats:340-402): body-text deny vectors for both branches, investigation completeness branch coverage (EC-004), template-sync parity tests. input-hash recomputed (both .sh and .ps1 changed in PR #17).
> - v1.0 (2026-07-19): Initial extraction from `enrichment-completeness.sh` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): ADV-0-402: Corrected EC-004 — investigation file with only "Alert Details" produces Deny, not Allow. The hook requires ALL FOUR sections before saving any investigation file; there is no partial-save capability. ADV-0-403: Re-anchored stale BATS test references from `hooks.bats:41-60` to current @test names (lines 97-115 post-PR #14). ADV-0-507 (pass-4 input-hash batch): input-hash established as dual-file block scalar (enrichment-completeness.sh + .ps1 sibling).
> - v1.2 (2026-07-19): ADV-0-501: Extended Refactoring Notes to document workflow context — in the standard investigate-event workflow, Stage 7 generates from event-investigation-tmpl.yaml (a complete template satisfying all four section requirements), so the workflow never produces partial investigation files. Added note on single-shot template generation and complementary hook responsibilities.
> - v1.3 (2026-07-19): ADV-0-604: Re-synced `modified:` array to include ADV-0-507 pass-4 dual-file entry in v1.1. ADV-0-606: Upgraded PC#3 confidence from "inferred" to "verified" based on confirmed hooks.json PreToolUse/Write matcher (both enrichment-completeness.sh and disposition-guard.sh in the same sequential Write hooks array).
> - v1.5 (2026-07-19): ADV-0-B01: Updated all live hooks.bats line-number citations to current positions (PR #15 shifted enrichment-completeness tests +88 lines: :97→:185, :103→:191, :110→:198). hooks.bats references now use @test names for churn resilience.
> - v1.4 (2026-07-19): ADV-0-803: Added DI-014 cross-reference in Invariant #1 and EC-008 — enrichment-completeness's section-heading substring check has the SAME unanchored `grep -qF` idiom as disposition-guard's DI-004/SM-1. Classified as DI-014 (LOW, bounded local blast radius: only affects local document completeness, not the Jira system of record).

## Preconditions

1. The hook receives a `PreToolUse/Write` event envelope via stdin as JSON, containing `tool_input.file_path` (string) and `tool_input.content` (string). Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:38-39`).
2. `jq` is installed and available on `$PATH`. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:14-17`).
3. The hook is wired to fire on `PreToolUse` events for the `Write` tool (file-save operations). Confidence: verified against hooks.json PreToolUse/Write matcher (both enrichment-completeness.sh and disposition-guard.sh are in the same Write hooks array — sequential execution, deny from either wins) and BATS test payloads: `@test "enrichment-completeness allows non-enrichment files"` (hooks.bats:185), `@test "enrichment-completeness blocks incomplete enrichment"` (hooks.bats:191), `@test "enrichment-completeness allows complete enrichment"` (hooks.bats:198).

## Postconditions

1. If `file_path` contains neither `enrichment` nor `investigation` as a substring, the hook emits `permissionDecision: allow` (fast path). Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:42-44`).
2. For enrichment files (file_path contains `enrichment`): if any of the five required sections — "Executive Summary", "Vulnerability Details", "Severity Metrics", "Priority Assessment", "Remediation Guidance" — are absent from `content`, the hook emits `permissionDecision: deny` with a reason containing "Missing required sections" and listing the missing section names. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:47-58`).
3. For investigation files (file_path contains `investigation`): if any of the four required sections — "Executive Summary", "Alert Details", "Disposition", "Next Actions" — are absent from `content`, the hook emits `permissionDecision: deny` with a reason listing the missing sections. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:62-74`).
4. If all required sections are present, the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:76`) and test `@test "enrichment-completeness allows complete enrichment"` (hooks.bats:198).
5. Section detection uses a heading-anchored case-insensitive regex (`grep -qiE "^#{1,6}[[:space:]]+<section>"`); section headings must appear as markdown headings (H1–H6) in the content. Verbatim section name match required — e.g., "# Executive Summary" satisfies "Executive Summary". Body text occurrences do not satisfy the gate (DI-014 RESOLVED, PR #17). Confidence: verified by code analysis (`hooks/enrichment-completeness.sh:52, 68`).

## Invariants

1. The hook checks presence of section heading strings (by markdown heading occurrence in the document content), not their content quality. A section heading with empty body passes the gate. This is a structural completeness check, not a content quality check. **RESOLVED (DI-014, PR #17):** Section detection now uses a heading-anchored regex (`grep -qiE "^#{1,6}[[:space:]]+<section>"`) — body text merely mentioning a section name (e.g., "See Remediation Guidance above" in a paragraph) no longer satisfies the check. DI-014 RESOLVED. Confidence: verified by code analysis (`enrichment-completeness.sh:52, 68`) and new BATS tests `@test "enrichment-completeness body-text section names (no headings) denies for enrichment"` (hooks.bats:340) and `@test "enrichment-completeness body-text section names (no headings) denies for investigation"` (hooks.bats:347).
2. A file matching both `enrichment` and `investigation` as substrings would be checked against the enrichment list (first branch wins). Confidence: verified by code analysis — the two `if` blocks are non-overlapping in practice (`enrichment` check fires first, `investigation` check fires only if `file_path == *investigation*`). In practice, no filename matches both substrings.
3. The hook never blocks a file whose path does not match either pattern, even if the content contains enrichment-like structure. File path is the routing discriminator. Confidence: verified by code analysis.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr error, no JSON output |
| EC-002 | File path `/tmp/readme.md` | Allow — neither `enrichment` nor `investigation` in path |
| EC-003 | File path `enrichment-CVE-2024-1234.md`, content has only "Executive Summary" | Deny — 4 of 5 required sections missing |
| EC-004 | File path `investigation-ALERT-001.md`, content has only "# Alert Details\nSome data" | Deny — 3 of 4 required investigation sections missing (Executive Summary, Disposition, Next Actions); reason contains "Incomplete investigation document. Missing required sections: Executive Summary, Disposition, Next Actions." |
| EC-005 | File path `investigation-ALERT-001.md`, content has "Disposition" but missing "Alternatives Considered" | Allow here — `enrichment-completeness` does not check Alternatives Considered; that is `disposition-guard`'s responsibility |
| EC-006 | File path `enrichment-CVE-2024-1234.md`, all 5 sections present as `##` headings | Allow |
| EC-007 | Malformed JSON stdin | `jq -r '.tool_input.file_path // empty'` returns empty; path doesn't match either pattern; emit allow |
| EC-008 | Section name appearing only in body text (not as a markdown heading) — e.g., "See Remediation Guidance above" in a paragraph with no `##` heading present; OR section heading with trailing space | **RESOLVED (DI-014, PR #17):** Body-text-only occurrence now produces `permissionDecision: deny` — the heading-anchored regex (`grep -qiE "^#{1,6}[[:space:]]+<section>"`) requires the section name to appear as a markdown heading. A trailing-space heading form would still fail since the regex anchors to line start and matches the section name exactly. BATS: `@test "enrichment-completeness body-text section names (no headings) denies for enrichment"` (hooks.bats:340). |

## Canonical Test Vectors

| Input (file_path → content excerpt) | Expected Output | Category |
|--------------------------------------|----------------|----------|
| `/tmp/readme.md` → any content | `permissionDecision: allow` | happy-path |
| `enrichment-CVE-2024-1234.md` → all 5 sections present | `permissionDecision: allow` | happy-path |
| `enrichment-CVE-2024-1234.md` → only "Executive Summary" | `permissionDecision: deny`, reason contains "Missing required sections" | error |
| `investigation-ALERT-001.md` → "Alert Details" only (missing Executive Summary, Disposition, Next Actions) | `permissionDecision: deny`, reason contains "Missing required sections" | error |
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
| **Confidence** | high — section lists are hardcoded in source; BATS tests `@test "enrichment-completeness allows non-enrichment files"` (hooks.bats:185), `@test "enrichment-completeness blocks incomplete enrichment"` (hooks.bats:191), `@test "enrichment-completeness allows complete enrichment"` (hooks.bats:198) exercise allow and deny paths; 9 new tests (hooks.bats:340-402) exercise heading-anchor body-text fix (DI-014, PR #17), investigation-branch completeness (EC-004 coverage: :357-385 for missing Alert Details/Next Actions/Disposition/Executive Summary), and template-sync parity (:396, :402) |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **guard clause**: `if [[ "$FILE_PATH" != *"enrichment"* ]] && [[ "$FILE_PATH" != *"investigation"* ]]` fast path (line 42)
- **guard clause**: `for section in ...` loop with heading-anchored `grep -qiE "^#{1,6}[[:space:]]+${section}"` presence check (lines 51-54 enrichment, 67-70 investigation — DI-014 RESOLVED, PR #17)
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

**Note (ADV-0-402 correction, extended ADV-0-501):** The investigation check requires ALL FOUR sections to be present before saving — there is no partial-save capability for investigation files. A file missing any of "Executive Summary", "Alert Details", "Disposition", or "Next Actions" will be denied. The `disposition-guard` hook separately handles the additional constraint that once a Disposition section appears, Alternatives Considered must also appear. The two hooks enforce complementary completeness gates: enrichment-completeness enforces structural completeness (all four section headings present — satisfied by the investigate-event Stage 7 template generation from event-investigation-tmpl.yaml, which contains all four headings); disposition-guard enforces analytical completeness (alternatives documented before disposition is committed). In the standard investigate-event workflow, Stage 7 generates the investigation document once from a complete template — the workflow never produces partial investigation files. The in-progress-allow path in disposition-guard (BC-3.03.001 PC#2, EC-003) is documented for hook-isolated testing and is unreachable via the standard workflow write path.

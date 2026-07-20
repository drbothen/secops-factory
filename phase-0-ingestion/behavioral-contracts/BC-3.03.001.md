---
document_type: behavioral-contract
level: L3
version: "1.5"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/disposition-guard.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: "71c1f55"
  e7eae5faee1574527d5d574a964da8f8282e0adb36ebbbea0ac6b1db756859f4  plugins/secops-factory/hooks/disposition-guard.sh
  bf3cc1ed39122a62109c964371be3aa61e9252fc1b51dae9b438068e21d81838  plugins/secops-factory/hooks/disposition-guard.ps1
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/disposition-guard.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-03
lifecycle_status: active
introduced: v0.7.0
modified: ["v1.1-ADV-0-403-2026-07-19", "v1.2-ADV-0-501-ADV-0-507-2026-07-19", "v1.3-ADV-0-605-ADV-0-606-2026-07-19", "v1.4-ADV-0-B01-2026-07-19", "v1.5-RESYNC-PR17-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.03.001: disposition-guard Hook — Alternatives-Required Gate

> **Revision history:**
> - v1.5 (2026-07-19): RESYNC-PR17: DI-004/SM-1 **RESOLVED** — PR #17 replaced bare `grep -qiF "Alternatives Considered"` with heading-anchored `grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"` (`disposition-guard.sh:57`). Body-text negation phrases (e.g., "No Alternatives Considered were required") no longer falsely satisfy the gate. EC-009 canonical output flipped allow→deny. Canonical test vector row 5 flipped. Refactoring Notes defect paragraph updated to RESOLVED. Two new BATS tests added: `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323) and `@test "disposition-guard heading-form alternatives-considered allows"` (hooks.bats:330). input-hash recomputed (both .sh and .ps1 changed in PR #17).
> - v1.0 (2026-07-19): Initial extraction from `disposition-guard.sh` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): ADV-0-403: Re-anchored stale BATS test references to @test names at current line positions (post-PR #14).
> - v1.2 (2026-07-19): ADV-0-501: Annotated PC#2, EC-003, and canonical vector row 2 as HOOK-ISOLATED — in standard workflow, Stage 7 generates investigation document once from a complete template; enrichment-completeness BC-3.02.001 co-fires and denies any file missing four required sections. Added Aggregate Gate Behavior note. ADV-0-507: Normalized input-hash to dual-file form (.sh + .ps1).
> - v1.4 (2026-07-19): ADV-0-B01: Updated all live hooks.bats line-number citations to current positions (PR #15 shifted disposition-guard tests +88 lines: :158→:246, :164→:252, :170→:258, :177→:265). hooks.bats references now use @test names for churn resilience.
> - v1.3 (2026-07-19): ADV-0-605: Added EC-009 (SM-1/DI-004 negating-substring false-pass) as first-class edge case and corresponding canonical test vector row; updated Refactoring Notes Undocumented behavior paragraph to reference DI-004/SM-1/EC-009/HS-014. ADV-0-606: Upgraded PC#3 confidence from "inferred" to "verified" based on confirmed hooks.json PreToolUse/Write matcher.

## Preconditions

1. The hook receives a `PreToolUse/Write` event envelope via stdin as JSON, containing `tool_input.file_path` (string) and `tool_input.content` (string). Confidence: verified by code analysis (`hooks/disposition-guard.sh:39-40`).
2. `jq` is installed and available on `$PATH`. Confidence: verified by code analysis (`hooks/disposition-guard.sh:14-17`).
3. The hook fires on the same `PreToolUse/Write` events as `enrichment-completeness`. Both hooks run on every Write event; each applies its own path-pattern filter. Confidence: verified against hooks.json PreToolUse/Write matcher (both enrichment-completeness.sh and disposition-guard.sh confirmed in the same Write hooks array — sequential execution, deny from either wins) and BATS test structure.

## Postconditions

1. If `file_path` does not contain `investigation` as a substring, the hook emits `permissionDecision: allow` (fast path). Confidence: verified by code analysis (`hooks/disposition-guard.sh:43-45`).
2. If `file_path` contains `investigation` but `content` does not contain the string "Disposition" (case-insensitive), the hook emits `permissionDecision: allow` — the document is still in-progress. Confidence: verified by code analysis (`hooks/disposition-guard.sh:48-51`) and test `@test "disposition-guard allows investigation without disposition yet"` (hooks.bats:252). **HOOK-ISOLATED behavior**: in the standard investigate-event workflow, Stage 7 generates the investigation document once from a complete template (event-investigation-tmpl.yaml) that already contains all four required section headings; the enrichment-completeness hook (BC-3.02.001) co-fires on the same PreToolUse/Write event and would deny any investigation file missing those sections before this hook's in-progress-allow path is exercised. See Aggregate Gate Behavior note.
3. If `file_path` contains `investigation` AND `content` contains "Disposition" AND `content` does NOT contain a heading-form "Alternatives Considered" (i.e., `grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"` finds no match), the hook emits `permissionDecision: deny` with a reason containing "Alternatives Considered". Body text mentioning the phrase without a markdown heading does not satisfy the gate (DI-004 RESOLVED, PR #17). Confidence: verified by code analysis (`hooks/disposition-guard.sh:53-58`) and tests `@test "disposition-guard blocks disposition without alternatives"` (hooks.bats:258) and `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323).
4. If `file_path` contains `investigation` AND `content` contains both "Disposition" and "Alternatives Considered", the hook emits `permissionDecision: allow`. Confidence: verified by code analysis (`hooks/disposition-guard.sh:58`) and test `@test "disposition-guard allows disposition with alternatives"` (hooks.bats:265).
5. The "Disposition" check is case-insensitive substring (`grep -qiF`). The "Alternatives Considered" check uses a heading-anchored case-insensitive regex (`grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"`) — body text mentioning the phrase without a markdown heading does not satisfy the gate (DI-004 RESOLVED, PR #17). Confidence: verified by code analysis (`hooks/disposition-guard.sh:48, 57`) and `@test "disposition-guard heading-form alternatives-considered allows"` (hooks.bats:330).

## Invariants

1. The hook only blocks at the Disposition-present + Alternatives-absent intersection. It never blocks an in-progress investigation file (one without a Disposition section yet). Confidence: verified by code analysis.
2. The hook does not validate the quality or count of alternatives — it only checks that the section heading appears. One alternative or ten alternatives are treated identically by this hook. Confidence: verified by code analysis.
3. The deny reason always references the specific missing section name "Alternatives Considered" and contains guidance about documenting at least 2 alternative hypotheses. Confidence: verified by code analysis (`hooks/disposition-guard.sh:55`).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr error, no JSON output |
| EC-002 | File path `/tmp/readme.md` | Allow — not an investigation file |
| EC-003 | Investigation file with no Disposition section | Allow — in-progress; gate only fires once Disposition is declared. **HOOK-ISOLATED**: in aggregate, enrichment-completeness BC-3.02.001 co-fires and denies investigation files missing any of the four required sections; this allow path is unreachable in the standard workflow where Stage 7 generates from a complete template. |
| EC-004 | Investigation file with "Disposition: True Positive" but no Alternatives Considered | Deny with reason mentioning "Alternatives Considered" |
| EC-005 | Investigation file with both "Disposition" and "Alternatives Considered" sections | Allow |
| EC-006 | Investigation file with "disposition" (lowercase) section | Deny if Alternatives absent — `grep -qiF` matches case-insensitively |
| EC-007 | Content containing "Disposition" in body text (not a section header) | Allow if "Alternatives Considered" also present anywhere; Deny if absent. The check is on substring presence in the full content, not section-header structure. |
| EC-008 | Malformed JSON stdin | `jq` returns empty string for file_path; path doesn't match `investigation`; emit allow |
| EC-009 | Investigation file with "Disposition" section present AND "Alternatives Considered" appearing as negating body text only (e.g., `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\nNo Alternatives Considered were required.") | **RESOLVED (DI-004/SM-1, PR #17):** `permissionDecision: deny`. The heading-anchored check `grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"` requires an actual markdown heading; body-text negation phrases no longer satisfy the gate. BATS: `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323). |

## Canonical Test Vectors

| Input (file_path → content) | Expected Output | Category |
|-----------------------------|----------------|----------|
| `/tmp/readme.md` → any | `permissionDecision: allow` | happy-path |
| `investigation-ALERT-001.md` → "# Alert Details\nEvidence..." (no Disposition) | `permissionDecision: allow` **(HOOK-ISOLATED: in aggregate, enrichment-completeness BC-3.02.001 would deny this file — missing 3 of 4 required sections)** | hook-isolated-allow |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\n# Evidence\n..." | `permissionDecision: deny`, reason contains "Alternatives Considered" | error |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\n# Alternatives Considered\n1. FP...\n2. BTP..." | `permissionDecision: allow` | happy-path |
| `investigation-ALERT-001.md` → "# disposition\nFalse Positive" (lowercase) | `permissionDecision: deny` | edge-case |
| `investigation-ALERT-001.md` → "# Disposition\nTrue Positive\nNo Alternatives Considered were required." | `permissionDecision: deny` (RESOLVED — PR #17 heading-anchored check; body-text negation no longer passes) | edge-case |

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
| **Path** | `plugins/secops-factory/hooks/disposition-guard.sh` (62 lines, post-PR #17) + `.ps1` sibling |
| **Confidence** | high — three-state logic (non-investigation / in-progress / complete-without-alternatives) fully visible in source; BATS tests `@test "disposition-guard allows non-investigation files"` (hooks.bats:246), `@test "disposition-guard allows investigation without disposition yet"` (hooks.bats:252), `@test "disposition-guard blocks disposition without alternatives"` (hooks.bats:258), `@test "disposition-guard allows disposition with alternatives"` (hooks.bats:265) exercise all four cases; `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323) and `@test "disposition-guard heading-form alternatives-considered allows"` (hooks.bats:330) exercise the heading-anchored DI-004 fix (PR #17) |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **guard clause**: file path substring check for `investigation` (line 43)
- **guard clause**: case-insensitive content check for "Disposition" presence (lines 48-51)
- **guard clause**: heading-anchored case-insensitive content check for "Alternatives Considered" absence (`grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"`, line 57 — DI-004 RESOLVED, PR #17)
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

**Aggregate Gate Behavior (ADV-0-501):** Both `enrichment-completeness` (BC-3.02.001) and `disposition-guard` (this hook) are wired to fire on every `PreToolUse/Write` event. When both hooks evaluate the same Write event, deny from either hook wins — Claude Code does not proceed with the write if any hook denies. In the standard investigate-event workflow, Stage 7 generates the investigation document once from event-investigation-tmpl.yaml, which contains all four required section headings (Executive Summary, Alert Details, Disposition, Next Actions); the enrichment-completeness hook is satisfied immediately. This hook then evaluates whether a Disposition section is present and, if so, whether Alternatives Considered accompanies it. The in-progress-allow path (PC#2, EC-003, canonical vector row 2) is documented for hook-isolated testing but is unreachable via the standard workflow write path.

**Resolved (DI-004/SM-1, PR #17):** The "Alternatives Considered" section check now uses a heading-anchored regex (`grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"`) rather than a bare substring match (`grep -qiF`). Body text mentioning "Alternatives Considered" in a negating context (e.g., "No Alternatives Considered were required") no longer falsely satisfies the gate — the regex requires the markdown heading form. DI-004/SM-1 is **KILLED**. EC-009 updated to reflect `permissionDecision: deny`. New BATS coverage: `@test "disposition-guard body-text alternatives-considered (no heading) denies"` (hooks.bats:323) and `@test "disposition-guard heading-form alternatives-considered allows"` (hooks.bats:330). The hook still does not enforce minimum alternative count (the deny reason says "at least 2 alternative hypotheses" but the hook only checks for the section heading presence). Quality of alternatives is validated by `review-enrichment`, not by this hook.

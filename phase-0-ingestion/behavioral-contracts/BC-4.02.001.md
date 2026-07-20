---
document_type: behavioral-contract
level: L3
version: "1.3"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/update-jira/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "bc0f3e1"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/update-jira/SKILL.md
subsystem: vulnerability-pipeline
capability: CAP-VULN-02
lifecycle_status: active
introduced: v0.6.0
modified: ["v0.9.x-PR13-2026-07-19", "v1.1-ADV-0-601-2026-07-19", "v1.2-ADV-0-706-2026-07-19", "v1.3-ADV-0-901-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-4.02.001: update-jira Skill — Review-Gated Jira Field Update

> **Revision history:**
> - v0.9.x / PR #13 (2026-07-19): Initial extraction from `update-jira/SKILL.md` at v0.9.0 HEAD (Step 0d). `modified:` was not populated at ingestion time — re-synced now.
> - v1.1 (2026-07-19): ADV-0-601: Added `jr issue comment` to Invariant #1 gated-mutations list (was absent). Annotated PC#4 — the JIRA comment posting step hits require-review.sh unconditional deny; proceeds only via human permission-approval. Added DI-013 note.
> - v1.2 (2026-07-19): ADV-0-706: Standardized write-block citation in PC#4 to canonical form `88-94 (deny at :93)`.
> - v1.3 (2026-07-19): ADV-0-901: Replaced brittle require-review.sh line-number citation in PC#4 with construct-name reference (line numbers churned across PR#13/#14/#15; post-PR#15 lines 88-110 are the allowlist, not the write-block).

## Preconditions

1. A review-approval marker must be present in conversation context or JIRA comments before any field-modifying operation (`jr issue edit`, `jr issue move`) is executed. Confidence: verified by code analysis (`skills/update-jira/SKILL.md:Step 1`).
2. The enrichment data to be written must pass field validation: CVSS in range 0.0-10.0, EPSS in range 0.0-1.0, KEV as "Listed" or "Not Listed", priority as P1-P5. Confidence: verified by code analysis (`skills/update-jira/SKILL.md:Step 2`).
3. `jr` CLI is installed and authenticated. Confidence: inferred from Prerequisites pattern across all pipeline skills.
4. The skill announces itself verbatim before any other action: "I am using the update-jira skill to update ticket <ticket-id> with enrichment data." Confidence: verified by code analysis (Announce at Start section) and BATS test `skills.bats:51-54`.

## Postconditions

1. If no review-approval marker is found, the skill halts with the message "Review approval required before JIRA update. Run /review-enrichment first." and makes no JIRA mutations. Confidence: verified by code analysis (`skills/update-jira/SKILL.md:Step 1`).
2. Invalid fields (outside stated ranges) are skipped with a warning; the skill continues updating valid fields (partial success is acceptable). Confidence: verified by code analysis (Step 2: "Skip invalid fields with warning").
3. Priority is mapped to JIRA priority names: P1→Critical, P2→High, P3→Medium, P4→Low, P5→Trivial. Confidence: verified by code analysis (`skills/update-jira/SKILL.md:Step 3`).
4. After field updates, the enrichment summary is posted as a JIRA comment (not only as a field edit). Confidence: verified by code analysis (`skills/update-jira/SKILL.md:Step 3`). **Infrastructure behavior (ADV-0-601):** The `jr issue comment` command hits the require-review write-block (evaluated before the allowlist; denies jr issue comment/edit/move/assign/create and their --output json forms) as an unconditional deny — there is no marker-based override; the hook reads only stdin JSON and the deny path has no bypass mechanism. The comment posting step proceeds only via human permission-approval of the blocked call (Claude Code permission dialog). Resolution options (marker-file mechanism vs permanent human-override vs dedicated post-review-comment command) are tracked as **DI-013, PENDING HUMAN DECISION at the Phase 0 gate.**
5. After updates, the ticket is re-read via `jr issue view` to verify updates succeeded. Confidence: verified by code analysis (Step 3, final item).
6. Cloud ID is never exposed in user-facing output. Confidence: verified by code analysis (Red Flag: "The cloud_id is in the error message, that's fine").

## Invariants

1. JIRA mutations (`jr issue edit`, `jr issue move`, `jr issue assign`, `jr issue create`, `jr issue comment`) are gated by the `require-review` hook at the infrastructure layer AND by the skill-level review-approval check. Two-layer defense in depth. Confidence: verified by code analysis and hook architecture.
2. All fields must be updated atomically in a single pass — not sequentially over time. Partial-field-then-later-finish is explicitly prohibited by the Red Flags. Confidence: verified by code analysis (Red Flag: "I'll update priority first and finish the rest later" → "Partial updates create inconsistent state").
3. A `jr issue edit` call failure (e.g., field not found, permission error) does not abort the skill; it logs the failure and continues with remaining fields. The final report documents which fields succeeded and which failed. Confidence: verified by code analysis (Red Flag: "Field update failed, I'll skip it" → "Log the failure, continue with other fields, report partial success").

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | No review-approval marker in context | Halt before any JIRA mutation; prompt user to run /review-enrichment |
| EC-002 | CVSS = 11.0 (invalid) | Skip CVSS field update with warning; continue with other valid fields |
| EC-003 | EPSS = 1.5 (invalid range) | Skip EPSS field update with warning |
| EC-004 | `jr issue edit` returns error (field ID mismatch) | Log error; continue; report in final summary |
| EC-005 | Status transition to "Enriched" not a valid transition from current status | Log jr move failure; report in final summary; other updates may have succeeded |
| EC-006 | Cloud ID appears in jr error message | Filter from user output — never display cloud_id |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Ticket with review approval, all valid fields (CVSS 9.8, EPSS 0.92, KEV Listed, P1) | All fields updated; JIRA comment posted; status moved to Enriched; verification read passes | happy-path |
| Ticket with no review approval | Halt with "Review approval required" message; no JIRA mutation | error |
| Ticket with CVSS 11.0 | CVSS field skipped with warning; other fields updated | edge-case |
| `jr issue edit` permission denied | Error logged; continues; final report shows failure | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-006 | Iron Law text is present in SKILL.md verbatim | integration / BATS (`skills.bats:25-27`) |
| VP-SKILL-007 | CVSS range validation rejects values outside 0.0-10.0 | integration / manual |
| VP-SKILL-008 | Review approval check precedes any jr issue edit invocation | integration / manual |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-VULN-02 |
| L2 Domain Invariants | NO JIRA UPDATE WITHOUT REVIEW APPROVAL FIRST |
| Architecture Module | C-2 (skill-procedures), C-12 (require-review hook provides infrastructure gate) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/update-jira/SKILL.md` (~76 lines) |
| **Confidence** | high — 4-step process with explicit field validation ranges and priority mapping documented in source |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **documentation**: Iron Law text, step-by-step process, explicit field validation ranges
- **guard clause**: "Look for review-approval marker... If not found, HALT" (Step 1)
- **type constraint**: field validation ranges are explicit (CVSS 0.0-10.0, EPSS 0.0-1.0, KEV enum, Priority enum)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads Jira (jr issue view for verification), writes Jira (jr issue edit, comment, move) |
| **Global state access** | none |
| **Deterministic** | no — depends on Jira API responses |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell |

#### Refactoring Notes

Field validation (Step 2) is a pure function: given data values, apply range/enum checks. This is the natural unit for formal specification. The rest of the skill is effectful (Jira read/write). No structural refactoring needed — the pure validation logic should be tested independently with property-based tests covering boundary values.

---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/enrich-ticket/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "d3ff93e"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/enrich-ticket/SKILL.md
subsystem: vulnerability-pipeline
capability: CAP-VULN-01
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

# Behavioral Contract BC-4.01.001: enrich-ticket Skill — 8-Stage CVE Enrichment Workflow

## Preconditions

1. A valid JIRA ticket ID is provided as argument (the ticket must contain or be derivable to a CVE ID). Confidence: verified by code analysis (`skills/enrich-ticket/SKILL.md:Stage 1`).
2. `jr` CLI is installed and authenticated (`jr auth login`) — required for JIRA read (Stage 1) and JIRA write (Stage 8). Confidence: verified by code analysis (`skills/enrich-ticket/SKILL.md:Prerequisites`).
3. The skill announces itself verbatim before any other action: "I am using the enrich-ticket skill to run the complete 8-stage enrichment workflow for <ticket-id>." Confidence: verified by code analysis and BATS test `skills.bats:35-38`.

## Postconditions

1. All 8 stages complete before any JIRA update is posted. Partial enrichment is never posted to JIRA as complete. Confidence: verified by code analysis (Iron Law: `NO JIRA UPDATE WITHOUT COMPLETED ENRICHMENT FIRST`) and test `skills.bats:9-11`.
2. A structured enrichment document is produced using `${CLAUDE_PLUGIN_ROOT}/templates/security-enrichment-tmpl.yaml` with all sections populated. Confidence: verified by code analysis (`skills/enrich-ticket/SKILL.md:Stage 7`).
3. The enrichment document is saved locally to `artifacts/enrichments/` before or concurrent with the JIRA update. Confidence: verified by code analysis (`skills/enrich-ticket/SKILL.md:Stage 8`).
4. JIRA custom fields are updated: CVSS score, EPSS probability, KEV status, priority tier. Confidence: verified by code analysis (`skills/enrich-ticket/SKILL.md:Stage 8`).
5. If Stage 2 CVE research (Perplexity or fallback) fails, the skill halts and saves locally — it never posts incomplete enrichment as complete. Confidence: verified by code analysis (Iron Law enforcement) and Red Flag: "I'll update JIRA now and finish research later".
6. Priority is assigned via the 6-factor multi-factor assessment (Stage 6) — single-source severity (vendor CVSS alone) is never used as the final priority. Confidence: verified by code analysis (Stage 6 and Red Flag: "The vendor says Critical, so it's P1").

## Invariants

1. EPSS is mandatory — it is never skipped even if CVSS is available. Confidence: verified by code analysis (Red Flag: "EPSS is optional, I'll skip it" → "EPSS is required for multi-factor priority. Never skip.").
2. Authoritative sources only: NVD, CISA, FIRST, vendor advisories. Blog posts and informal sources are explicitly rejected. Confidence: verified by code analysis (Red Flag table).
3. If no CVE ID is found in the ticket during Stage 1, the skill prompts the user — it does not proceed with an unknown CVE. Confidence: verified by code analysis (`skills/enrich-ticket/SKILL.md:Stage 1`).
4. The `enrichment-completeness` hook enforces the structural completeness of the output document independently of this skill's procedural controls. Confidence: inferred from hook-skill coordination architecture.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Ticket contains no CVE ID | Stage 1 prompts user for CVE ID before proceeding |
| EC-002 | Perplexity MCP unavailable | research-cve sub-skill auto-detects and falls back to NVD/EPSS/CISA via WebFetch |
| EC-003 | No patch available for CVE | Stage 4 documents workarounds and compensating controls instead of skipping |
| EC-004 | KEV not listed | Does not treat as low risk; proceeds with EPSS and exploit status checks |
| EC-005 | Stage N fails mid-workflow | Save locally and flag — never post partial enrichment to JIRA |
| EC-006 | ICS/OT context detected | Stage 5 (ATT&CK) references ICS ATT&CK matrix in addition to enterprise ATT&CK |
| EC-007 | `jr` CLI authentication expired | Skill fails at Stage 1 ticket read; halts before any JIRA mutation |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Ticket `SEC-100` with CVE-2024-1234 (CVSS 9.8, KEV listed) | All 8 stages complete; enrichment doc saved; JIRA updated with CVSS/EPSS/KEV/P1 | happy-path |
| Ticket with no CVE | Stage 1 prompts for CVE ID; halts until user provides ID | edge-case |
| Perplexity unavailable | Stage 2 proceeds via NVD/WebFetch fallback; full enrichment completes | edge-case |
| Network failure at Stage 2 | Halts, saves partial work locally, reports failure; no JIRA update | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-001 | Iron Law text is present in SKILL.md verbatim | integration / BATS (`skills.bats:9-11`) |
| VP-SKILL-002 | Announce at Start section is present | integration / BATS (`skills.bats:35-38`) |
| VP-SKILL-003 | Red Flags table has >= 6 rows | integration / BATS (`skills.bats:61-64`) |
| VP-SKILL-004 | Template and data references use `${CLAUDE_PLUGIN_ROOT}/` prefix | integration / BATS (`skills.bats:93-105`) |
| VP-SKILL-005 | All referenced templates and data files exist on disk | integration / BATS (`skills.bats:215-255`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-VULN-01 |
| L2 Domain Invariants | NO JIRA UPDATE WITHOUT COMPLETED ENRICHMENT FIRST |
| Architecture Module | C-2 (skill-procedures), C-4 (enrichment-workflow-playbook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/enrich-ticket/SKILL.md` (126 lines) |
| **Confidence** | high — 8 stages explicitly documented with inputs/outputs; Iron Law enforced by both skill procedure and hook layer; BATS tests validate structural requirements |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **documentation**: 8-stage workflow with named outputs per stage
- **guard clause**: Iron Law statement (line 13) + Red Flags table (lines 25-34) document forbidden shortcuts
- **type constraint**: sub-skill invocations (`/research-cve`, `/map-attack`, `/assess-priority`, `/read-ticket`) are explicit and ordered
- **inferred**: Perplexity fallback behavior is documented in Stage 2 and Prerequisites

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads Jira (jr CLI), reads Perplexity/NVD/EPSS/CISA (external APIs), writes enrichment document (filesystem), writes Jira (jr CLI) |
| **Global state access** | none |
| **Deterministic** | no — depends on external CVE data, Jira ticket content |
| **Thread safety** | not applicable (LLM-executed sequential skill) |
| **Overall classification** | effectful shell |

#### Refactoring Notes

The skill is a multi-stage effectful workflow. The pure-core boundary can be drawn at the document assembly stage (Stage 7): given all collected data as inputs, populating the template is a pure transformation. Stages 1-6 are necessarily effectful (external data fetch). Stage 8 is necessarily effectful (Jira write). The pure Stage 7 is the natural unit for formal specification of the output document format.

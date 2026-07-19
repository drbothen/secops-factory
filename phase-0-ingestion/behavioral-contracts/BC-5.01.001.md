---
document_type: behavioral-contract
level: L3
version: "1.3"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/investigate-event/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "b6feec630f59a9bb5ba5222b69289268a783e71aafbc66647e0cd165dd5b9929"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/investigate-event/SKILL.md
subsystem: event-investigation-pipeline
capability: CAP-EVENT-01
lifecycle_status: active
introduced: v0.6.0
modified: ["v1.1-ADV-0-501-2026-07-19", "v1.2-ADV-0-601-2026-07-19", "v1.3-ADV-0-702-ADV-0-706-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-5.01.001: investigate-event Skill — 7-Stage Event Investigation Workflow

> **Revision history:**
> - v1.0 (2026-07-19): Initial extraction from `investigate-event/SKILL.md` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): ADV-0-501: Annotated EC-006 to clarify the in-progress-save assumption — standard workflow generates from a complete template at Stage 7; EC-006 applies when analyst manually edits investigation file post-generation.
> - v1.2 (2026-07-19): ADV-0-601: Added Invariant #7 documenting that Stage 7's `jr issue comment` step hits require-review.sh unconditional deny and requires human permission-approval (no marker-based override). Added DI-013 reference.
> - v1.3 (2026-07-19): ADV-0-702: Corrected PC#3 — ≥2 alternative hypotheses is an LLM-soft procedural rule, not a structural hook enforcement; disposition-guard enforces only heading presence (subject to DI-004). Aligned with Invariant #5 and BC-3.03.001 Invariant #2. ADV-0-706: Standardized write-block citation in Invariant #7 to `88-94 (deny at :93)`.

## Preconditions

1. A valid JIRA ticket ID containing a security event alert is provided. Confidence: verified by code analysis (`skills/investigate-event/SKILL.md:argument-hint`).
2. `jr` CLI is installed and authenticated. Confidence: verified by code analysis (Prerequisites section).
3. The Perplexity/WebSearch research path is determined ONCE at the start of the investigation (before Stage 3) and applied consistently throughout all stages. Confidence: verified by code analysis (Research Tool Selection section: "This decision is made ONCE at the start").
4. The skill announces itself verbatim before any other action. Confidence: verified by code analysis and BATS test `skills.bats:42-45`.

## Postconditions

1. A disposition (True Positive / False Positive / Benign True Positive) is produced only after all 7 stages are complete, with evidence tracing each stage. Confidence: verified by code analysis (Iron Law: `NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST`) and BATS test `skills.bats:17-19`.
2. The investigation document is saved locally FIRST (chain of custody), before any JIRA update. Confidence: verified by code analysis (Stage 7 step order and Red Flag: "I'll update JIRA before saving locally").
3. At least 2 alternative disposition hypotheses must be documented. This is an LLM-enforced procedural rule from the skill (Red Flag: "I'm confident it's BTP, no need for alternatives"); the `disposition-guard` hook enforces only the structural presence of an "Alternatives Considered" heading (not the count or quality of alternatives, and subject to open DI-004 negating-substring false-pass — see BC-3.03.001 Invariant #2 and EC-009). Confidence: verified by code analysis and hook BC-3.03.001.
4. For external IPs in Stage 3, ASN/geolocation/reputation lookups are performed (via Perplexity if available, otherwise WebSearch). Confidence: verified by code analysis (Stage 3).
5. If alert platform type is ambiguous after Stage 1 auto-detection, the analyst is prompted to select ICS/IDS/SIEM before proceeding. Confidence: verified by code analysis (Stage 1).
6. Low-confidence dispositions automatically trigger an escalation recommendation. Confidence: verified by code analysis (Stage 6).

## Invariants

1. Each event requires independent investigation — prior incidents of similar type cannot substitute for independent evidence collection. Confidence: verified by code analysis (Red Flag: "This looks like the same alert we saw last week, it's an FP" → "Each event needs independent investigation.").
2. Historical context (30/60/90-day patterns) must be checked — recency bias (treating the event as new without checking history) is prohibited. Confidence: verified by code analysis (Red Flag: "I'll skip historical context, this is clearly new").
3. Internal source IPs are not treated as automatically safe — lateral movement possibility must be assessed. Confidence: verified by code analysis (Red Flag).
4. The `enrichment-completeness` hook enforces required investigation document sections (Executive Summary, Alert Details, Disposition, Next Actions). Confidence: verified by hook BC-3.02.001.
5. The `disposition-guard` hook enforces that Alternatives Considered is present when a Disposition section exists. Confidence: verified by hook BC-3.03.001.
6. The Perplexity availability check happens once before Stage 3 and the result is announced to the user. Confidence: verified by code analysis (Research Tool Selection section).
7. Stage 7 includes a `jr issue comment` call to post the investigation summary to the JIRA ticket. The `require-review` hook (C-12, `require-review.sh:88-94 (deny at :93)`) denies `jr issue comment` unconditionally — the command is in the write-block substring list with no marker-based override path. The comment posting step proceeds only via human permission-approval of the blocked call (Claude Code permission dialog). There is no way for a skill command to include text that bypasses this deny. Resolution options are tracked as **DI-013, PENDING HUMAN DECISION at the Phase 0 gate.**

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Alert platform type is ambiguous (neither ICS nor IDS nor SIEM keywords) | Stage 1 prompts analyst to select ICS/IDS/SIEM before proceeding |
| EC-002 | No log data available for Stage 4 | Flag as incomplete evidence; do not disposition without minimum evidence |
| EC-003 | Perplexity unavailable for threat intelligence | Switch to WebSearch/WebFetch for all Stages 3-5; announce switch; do not retry Perplexity per-stage |
| EC-004 | Source IP is internal | Must assess lateral movement possibility; do not assume safe |
| EC-005 | Low-confidence disposition reached | Automatically recommend escalation in Stage 6 output |
| EC-006 | Analyst saves investigation file without "Alternatives Considered" after manually adding a "Disposition" section | `disposition-guard` hook blocks. Standard Stage 7 workflow generates from event-investigation-tmpl.yaml (a complete template with all section headings already present); EC-006 applies when analyst edits the investigation file post-generation to add or modify Disposition content before completing the Alternatives Considered section. |
| EC-007 | Alert is an ICS/SCADA alert | Apply ICS-specific considerations (Purdue zones, safety systems, OT protocol context) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Ticket `ALERT-001`, Claroty ICS alert, clear TP with evidence | 7 stages complete; TP disposition with evidence chain; saved locally first; JIRA updated; review-approval unlocked | happy-path |
| Ticket with Snort/IDS alert, FP due to scanner misconfiguration | FP disposition with alternatives (TP malicious, BTP authorized scan); Alternatives Considered section present | happy-path |
| Ticket with no log data available | Flag as incomplete; do not disposition; recommend log retrieval | error |
| Internal source IP alert | Lateral movement assessed in Stage 5; disposition includes this consideration | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-018 | Iron Law text present verbatim | integration / BATS (`skills.bats:17-19`) |
| VP-SKILL-019 | Perplexity fallback path present in skill | integration / BATS (`skills.bats:169-171`) |
| VP-SKILL-020 | Template and data references use CLAUDE_PLUGIN_ROOT prefix | integration / BATS (`skills.bats:93-105`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-EVENT-01 |
| L2 Domain Invariants | NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST |
| Architecture Module | C-2 (skill-procedures), C-5 (investigation-workflow-playbook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/investigate-event/SKILL.md` (120 lines) |
| **Confidence** | high — 7 stages with inputs/outputs documented; ICS/IDS/SIEM detection keywords explicit; Perplexity fallback logic documented at skill level; BATS validates Iron Law and Red Flags |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **documentation**: 7-stage workflow; alert platform detection keywords; research path decision protocol
- **guard clause**: Iron Law (line 13); Red Flags table (lines 25-34)
- **documentation**: Stage 7 step order ("Save locally FIRST") as documented chain-of-custody requirement
- **inferred**: ICS-specific considerations (Purdue model, safety systems) referenced in Stage 5 but not explicitly enumerated

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads Jira (jr CLI), reads threat intelligence (Perplexity/WebSearch), reads analyst-provided log excerpts, writes investigation document (filesystem), writes Jira (comment + custom fields) |
| **Global state access** | none |
| **Deterministic** | no — depends on Jira ticket content, threat intelligence queries, analyst log data |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell |

#### Refactoring Notes

The disposition logic (evidence → TP/FP/BTP classification) is the core analytical function. While LLM-executed, the framework is a structured decision tree that could be specified as a formal property: given a complete evidence set and alternatives considered, the disposition must be one of {TP, FP, BTP}. The MITRE ATT&CK mapping in Stage 5 is also a constrained function (vulnerability type → tactic/technique mapping) suitable for property testing.

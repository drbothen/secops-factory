---
name: enrich-ticket
description: "Use when enriching a security ticket with vulnerability intelligence. Executes 8-stage enrichment: triage, CVE research, business context, remediation, ATT&CK mapping, priority assessment, documentation, JIRA update."
argument-hint: "<ticket-id>"
---

# Enrich Security Ticket

Execute the complete 8-stage Security Alert Enrichment Workflow from JIRA ticket triage through full vulnerability analysis, documentation, and ticket update.

## The Iron Law

> **NO JIRA UPDATE WITHOUT COMPLETED ENRICHMENT FIRST**

Every stage must complete before updating JIRA. Partial enrichment posted to a ticket creates false confidence in incomplete analysis. If any stage fails, save locally and flag -- never post incomplete enrichment as if it were complete.

## Announce at Start

Before any other action, say verbatim:

> I am using the enrich-ticket skill to run the complete 8-stage enrichment workflow for <ticket-id>.

## Red Flags

| Thought | Reality |
|---|---|
| "I can skip CVE research, the ticket already has a CVSS score" | Ticket data may be stale or wrong. Always verify against NVD. |
| "EPSS is optional, I'll skip it" | EPSS is required for multi-factor priority. Never skip. |
| "I'll update JIRA now and finish research later" | Iron Law violation. Complete all 8 stages first. |
| "The vendor says Critical, so it's P1" | Vendor severity is one factor. Run full multi-factor assessment. |
| "No patch available, so I'll skip remediation" | Document workarounds and compensating controls instead. |
| "KEV not listed, so low risk" | KEV absence does not mean low risk. Check EPSS and exploit status. |
| "I'll use a blog post as my source" | Use authoritative sources: NVD, CISA, FIRST, vendor advisories. |
| "Business context doesn't matter for this CVE" | Every CVE needs ACR + exposure assessment. Context always matters. |

## Prerequisites

- Atlassian MCP server connected (required — for JIRA read/write)
- Perplexity MCP server connected (recommended — for AI-assisted CVE research; graceful fallback to web search if not configured)
- Valid JIRA ticket ID provided as argument

## Workflow: 8 Stages

### Stage 1: Triage and Context Extraction (1-2 min)

1. Read JIRA ticket via `/read-ticket <ticket-id>`
2. Extract CVE ID(s) from summary, description, custom fields
3. Extract affected systems, initial severity, context metadata
4. If no CVE found: prompt user for CVE ID

**Outputs:** cve_id, all_cves, affected_systems, initial_severity, ticket_summary

### Stage 2: CVE Research (3-5 min with Perplexity, 5-10 min manual)

1. Execute `/research-cve <cve-id>` for primary CVE
2. The research-cve skill auto-detects Perplexity availability and uses it or falls back to direct web queries (NVD API, FIRST EPSS API, CISA KEV feed)
3. Collect: CVSS, EPSS, KEV status, exploits, patches, ATT&CK suggestions

**Outputs:** cvss_score, cvss_vector, epss_score, kev_status, affected_versions, patched_versions, exploit_status, sources

### Stage 3: Business Context Assessment (2-3 min)

1. Extract Asset Criticality Rating (ACR) from JIRA or config
2. Determine system exposure (Internet/Internal/Isolated)
3. Assess business impact dimensions

**Outputs:** acr_rating, system_exposure, business_impact

### Stage 4: Remediation Planning (2-3 min)

1. Identify available patches from CVE research
2. Research workarounds if no patch available
3. Identify compensating controls
4. Generate actionable remediation steps

**Outputs:** patch_available, patch_version, workarounds, compensating_controls, remediation_steps

### Stage 5: MITRE ATT&CK Mapping (1-2 min)

1. Execute `/map-attack <cve-id>`
2. Map vulnerability type to tactics and techniques
3. Include T-numbers and detection recommendations
4. Reference ICS ATT&CK matrix if OT context

**Outputs:** attack_tactics, attack_techniques, detection_implications

### Stage 6: Multi-Factor Priority Assessment (1-2 min)

1. Execute `/assess-priority` with all collected data
2. Calculate 6-factor risk score (0-24 points)
3. Map to P1-P5 with SLA deadline
4. Apply priority modifiers (overrides, elevations, reductions)

**Outputs:** priority_level, total_score, sla_deadline, priority_rationale

### Stage 7: Structured Documentation (1 min)

1. Load template: `${CLAUDE_PLUGIN_ROOT}/templates/security-enrichment-tmpl.yaml`
2. Populate all sections with collected data
3. Generate markdown enrichment document
4. Validate completeness (all sections present)

**Outputs:** enrichment_document

### Stage 8: JIRA Update and Validation (1-2 min)

1. Post enrichment document as JIRA comment
2. Update JIRA custom fields (CVSS, EPSS, KEV, priority)
3. Save enrichment locally to artifacts/enrichments/
4. Validate all updates succeeded

**Quality gate:** All 8 stages complete, all template sections populated, JIRA updated.

## References

- `${CLAUDE_PLUGIN_ROOT}/data/cvss-guide.md`
- `${CLAUDE_PLUGIN_ROOT}/data/epss-guide.md`
- `${CLAUDE_PLUGIN_ROOT}/data/kev-catalog-guide.md`
- `${CLAUDE_PLUGIN_ROOT}/data/priority-framework.md`
- `${CLAUDE_PLUGIN_ROOT}/data/mitre-attack-mapping-guide.md`
- `${CLAUDE_PLUGIN_ROOT}/templates/security-enrichment-tmpl.yaml`
- `${CLAUDE_PLUGIN_ROOT}/checklists/completeness-checklist.md`
- `${CLAUDE_PLUGIN_ROOT}/checklists/source-citation-checklist.md`

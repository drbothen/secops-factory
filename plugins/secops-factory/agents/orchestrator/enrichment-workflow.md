---
name: orchestrator-enrichment-workflow
description: Orchestrator workflow reference for the 8-stage CVE enrichment pipeline. Loaded by the enrich-ticket skill. Not directly invokable.
disable-model-invocation: true
---

# CVE Enrichment Workflow

**Canonical source** for the 8-stage vulnerability enrichment pipeline. The `enrich-ticket` skill (`skills/enrich-ticket/SKILL.md`) is the entry point; this file is the playbook. If the two disagree, this file wins.

## Pipeline Stages

For each JIRA ticket containing a CVE:

1. **Triage** — Read the JIRA ticket via `jr issue view <ticket-id>`. Extract CVE ID, affected asset, initial severity, and any analyst notes. Validate the CVE ID format (CVE-YYYY-NNNNN). If linked CMDB assets exist, fetch via `jr issue assets <ticket-id>`.

2. **CVE Research** — Dispatch `/research-cve`. If Perplexity MCP is available, uses severity-tiered tool selection (`perplexity_research` for CVSS 9.0+, `perplexity_reason` for 7.0-8.9, `perplexity_search` for <7.0). If Perplexity is not configured, falls back to direct API queries (NVD, FIRST EPSS, CISA KEV) via `WebSearch`/`WebFetch`. Collect: NVD description, affected versions, attack vector, exploit availability, patch status.

3. **Business Context** — Assess asset criticality using the organization's asset inventory. ICS/SCADA assets get elevated priority due to safety implications. Document: asset type, network zone (IT/OT/DMZ), business function, compensating controls.

4. **Remediation Planning** — Determine remediation path: patch (preferred), workaround, mitigation, or accept-risk. For ICS/OT assets, verify change management compatibility. Document: remediation action, effort estimate, rollback plan.

5. **MITRE ATT&CK Mapping** — Map the vulnerability to ATT&CK tactics and techniques. Reference `${CLAUDE_PLUGIN_ROOT}/data/mitre-attack-mapping-guide.md`. Document: tactic, technique ID, sub-technique if applicable, detection opportunities.

6. **Priority Assessment** — Multi-factor scoring using 4 inputs:
   - CVSS base score (reference `${CLAUDE_PLUGIN_ROOT}/data/cvss-guide.md`)
   - EPSS probability (reference `${CLAUDE_PLUGIN_ROOT}/data/epss-guide.md`)
   - KEV status (reference `${CLAUDE_PLUGIN_ROOT}/data/kev-catalog-guide.md`)
   - Business context from stage 3
   Map to P1-P5 tier per `${CLAUDE_PLUGIN_ROOT}/data/priority-framework.md`.

7. **Documentation** — Write the enrichment report using `${CLAUDE_PLUGIN_ROOT}/templates/security-enrichment-tmpl.yaml`. All required sections must be populated (the enrichment-completeness hook enforces this).

8. **JIRA Update** — Post enrichment as a JIRA comment and update custom fields (CVSS score, EPSS probability, KEV status, priority tier, ATT&CK mapping). Requires review approval (the require-review hook enforces this).

## Post-Pipeline

After stage 8, dispatch `/adversarial-review-secops` to run the convergence loop on the enrichment output. JIRA update is not final until the review converges.

## Stage Dependencies

Stages 1-6 are sequential (each depends on prior output). Stages 7-8 can overlap: documentation can start during stage 6, but JIRA update requires documentation to be complete.

---
name: create-advisory
description: "Use when creating a structured security advisory for a CVE, threat campaign, or vendor bulletin. Supports IT, ICS/OT, and combined audiences. Accepts built-in or custom templates."
argument-hint: "<topic|CVE-ID> [--template path] [--type it|ics|combined]"
disable-model-invocation: true
---

# Create Security Advisory

Generate a structured, actionable security advisory from threat intelligence, CVE data, and vendor bulletins.

## The Iron Law

> **NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST**

Violating the letter of the rule is violating the spirit of the rule. "The vendor said so" is not verification — cross-reference against NVD, CISA KEV, and FIRST EPSS independently. An advisory with an incorrect CVSS score erodes trust in the entire advisory program.

## Announce at Start

Before any other action, say verbatim:

> I'm using the create-advisory skill to draft a security advisory for <topic>.

## Red Flags

| Thought | Reality |
|---|---|
| "The vendor advisory has all the details, I'll just reformat it" | Vendor advisories are one source. Cross-reference CVSS against NVD, check KEV, verify EPSS independently. |
| "This is a low-severity CVE, skip the detection guidance" | Detection guidance is always required. Low-severity CVEs are still exploited. |
| "The CVSS score from the vendor is probably right" | Vendors often use different CVSS scoring. NVD is authoritative. Document discrepancies. |
| "No need for ICS context, this is an IT vulnerability" | If the affected product runs in OT environments (even occasionally), include the ICS block. |
| "I'll skip the mitigation section since a patch exists" | Not everyone can patch immediately. Mitigations bridge the gap. Always include. |
| "This advisory is urgent, skip the peer review" | Urgency increases error risk. Run `/adversarial-review-secops` or at minimum `/fact-verify`. |
| "The EPSS score is low, this isn't worth an advisory" | EPSS measures exploitation probability, not impact. A low-EPSS CVE in a safety-critical ICS system may still warrant a P1 advisory. |
| "I'll fill in the detection rules later" | An advisory without detection guidance is a notification, not an advisory. Include at least log indicators. |

## Input

- `$ARGUMENTS[0]` — topic: a CVE ID (e.g., `CVE-2024-1234`), threat campaign name, or vendor advisory reference
- `--template <path>` — optional: path to a custom template file. If omitted, uses the built-in default at `${CLAUDE_PLUGIN_ROOT}/templates/security-advisory-tmpl.md`
- `--type <it|ics|combined>` — optional: pre-select advisory type. If omitted, prompt the user interactively.

## Advisory Type Selection

If `--type` was not provided, present:

> What advisory type?
> 1. **IT** — enterprise/cloud infrastructure, internet-facing systems
> 2. **ICS/OT** — industrial control systems, SCADA, safety systems
> 3. **Combined** — both audiences in one advisory with dual remediation timelines

Based on selection:
- **IT** — remove the `## 5. ICS/OT Context` section and OT-specific subsections from Impact, Mitigations, and Remediation
- **ICS/OT** — include all sections, use safety-first framing, add regulatory references, use maintenance-window language
- **Combined** — include all sections, dual timelines (IT: immediate, OT: coordinated), address both audiences in Executive Summary

## Template Handling

### Built-in Default Template

Read `${CLAUDE_PLUGIN_ROOT}/templates/security-advisory-tmpl.md` and use it as the output structure.

### Custom Template

If `--template <path>` is provided:
1. Read the file at `<path>`
2. Validate it contains at minimum:
   - A heading with "Executive Summary" or "Summary"
   - A heading with "Affected" (products, systems, or versions)
   - A heading with "Remediation" or "Mitigation" or "Action"
3. If validation fails, warn the user and offer to use the default template instead
4. If validation passes, use the custom template structure — fill each section with researched content, preserving the template's section names, order, and any organization-specific fields

Custom templates allow organizations to:
- Add internal fields (ticket IDs, SLA deadlines, asset owner contacts)
- Override section ordering to match their advisory process
- Add branding (org name, logo placeholder, distribution list)
- Remove sections they don't use (e.g., skip YARA rules if no YARA infrastructure)

## Workflow

### Step 1: Research (3-8 min with Perplexity, 5-15 min with web search)

1. If topic is a CVE ID: run `/research-cve <CVE-ID>` for structured intelligence (research-cve handles its own Perplexity fallback)
2. If topic is a threat campaign or vendor advisory:
   - **Try Perplexity first:** call any `mcp__perplexity__*` tool. If it works, use `perplexity_research` for deep analysis.
   - **If Perplexity fails or is not available:** switch to `WebSearch` immediately. Do NOT stop or ask the user to configure Perplexity. Use these queries:
     - `WebSearch` for "<campaign name> CVE advisory [year]"
     - `WebSearch` for "<vendor> security advisory <product>"
     - `WebFetch` on NVD API: `https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=<CVE-ID>`
     - `WebFetch` on EPSS API: `https://api.first.org/data/v1/epss?cve=<CVE-ID>`
   - Collect: all associated CVEs, affected products/versions, exploit status, IOCs, vendor remediation
3. Verify all data against authoritative sources (NVD, CISA, FIRST)

### Step 2: Template Selection

1. Load the template (built-in or custom)
2. Determine advisory type (from `--type` arg or interactive prompt)
3. If IT-only: strip ICS/OT conditional sections from the template

### Step 3: Draft Advisory

Fill each template section with researched content:

- **Advisory ID**: generate as `SA-[YYYY]-[NNN]` (sequential)
- **TLP**: default TLP:CLEAR unless user specifies otherwise
- **Executive Summary**: 2-3 sentences, severity, exploit status, required action
- **Severity**: CVSS from NVD (note vendor discrepancies if any), EPSS, KEV status
- **Affected Products**: specific version ranges from vendor advisory
- **Vulnerability Details**: CVE, CWE, attack vector from NVD
- **ICS/OT Context** (if applicable): sectors from CISA ICS-CERT, safety impact assessment, protocol impact, regulatory refs
- **Impact**: CIA triad assessment, safety/process impact for OT
- **Exploit Status**: KEV listing, PoC availability, ITW exploitation, ransomware association
- **Mitigations**: concrete workaround steps (not "apply mitigations")
- **Remediation**: specific versions, patch links, timelines by advisory type
- **Detection**: at minimum log indicators; add Snort/Sigma/YARA rules if available
- **References**: all sources cited with URLs

### Step 4: Source Verification Gate

Before presenting to user, verify:
- [ ] CVSS score matches NVD (or discrepancy documented)
- [ ] EPSS score is current (API query within 24h)
- [ ] KEV status is current
- [ ] Affected version ranges match vendor advisory
- [ ] All URLs in References section resolve (spot-check 3)
- [ ] At least one detection indicator is present

If any verification fails, fix before presenting. Do not present unverified data.

### Step 5: Present and Iterate

1. Present the draft advisory to the user
2. Ask: "Review this advisory. Any changes to content, severity assessment, or scope?"
3. Iterate on user feedback
4. When approved, ask for output location (default: current directory, `SA-YYYY-NNN-<topic>.md`)

## Quality Gate

The advisory is complete when:
- [ ] All template sections populated (or explicitly marked N/A with rationale)
- [ ] Source Verification Gate passes
- [ ] User has approved the content
- [ ] TLP marking is set
- [ ] Revision history has initial entry

## Optional: Adversarial Review

For high-severity advisories (CVSS >= 7.0 or KEV-listed), recommend:

> This advisory covers a high-severity vulnerability. Run `/adversarial-review-secops` to verify accuracy before distribution?

## References

- Template: `${CLAUDE_PLUGIN_ROOT}/templates/security-advisory-tmpl.md`
- CVSS guide: `${CLAUDE_PLUGIN_ROOT}/data/cvss-guide.md`
- EPSS guide: `${CLAUDE_PLUGIN_ROOT}/data/epss-guide.md`
- KEV guide: `${CLAUDE_PLUGIN_ROOT}/data/kev-catalog-guide.md`
- MITRE ATT&CK: `${CLAUDE_PLUGIN_ROOT}/data/mitre-attack-mapping-guide.md`
- Priority framework: `${CLAUDE_PLUGIN_ROOT}/data/priority-framework.md`

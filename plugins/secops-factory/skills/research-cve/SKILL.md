---
name: research-cve
description: "Use when researching a CVE for vulnerability intelligence. Queries Perplexity for CVSS, EPSS, KEV, exploit status, patches, ATT&CK mapping, and technical details from authoritative sources."
argument-hint: "<cve-id>"
---

# Research CVE

Deep CVE research using AI-assisted intelligence gathering via Perplexity MCP.

## Process

### Step 1: Validate CVE ID

Format: `CVE-\d{4}-\d{4,7}` (case-insensitive). Reject invalid formats. Max 3 retries.

### Step 2: Research Query

Query Perplexity for comprehensive intelligence:
1. CVSS base score and vector string (from NVD)
2. EPSS exploitation probability (from FIRST)
3. CISA KEV catalog status
4. Affected product and version ranges
5. Patched versions and vendor advisory links
6. Exploit availability (PoC, frameworks, active exploitation)
7. MITRE ATT&CK tactics and techniques
8. Technical description and CWE classification

### Step 3: Tool Selection by Severity

| CVSS Score | Tool | Rationale |
|------------|------|-----------|
| 9.0-10.0 | `mcp__perplexity__perplexity_research` | Deep 2-5 min analysis |
| 7.0-8.9 | `mcp__perplexity__perplexity_reason` | Moderate 30-60s analysis |
| 0.1-6.9 | `mcp__perplexity__perplexity_search` | Quick 10-20s lookup |
| Unknown | `mcp__perplexity__perplexity_reason` | Default moderate |

### Step 4: Validate Sources

**Trusted:** NVD, CISA, FIRST, MITRE, vendor security sites, GitHub advisories
**Flag as unverified:** Blogs, news sites, social media, forums

### Step 5: Handle Conflicts

Priority hierarchy: NVD > Vendor > Third-party for CVSS. Vendor > NVD for patches. CISA > vendors for exploitation status.

### Step 6: Return Structured Data

Return YAML with: cvss, epss, kev, affected_products, patches, exploit_status, attack_mapping, description, sources, warnings.

## Error Handling

- Perplexity timeout: retry with simpler query, fall back to faster tool
- CVE not found: offer correction or manual research
- Missing data: continue with available fields, flag gaps
- Hallucination detection: validate URL formats, score ranges, T-number validity

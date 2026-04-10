---
name: research-cve
description: "Use when researching a CVE for vulnerability intelligence. Queries Perplexity for CVSS, EPSS, KEV, exploit status, patches, ATT&CK mapping, and technical details from authoritative sources."
argument-hint: "<cve-id>"
---

# Research CVE

Deep CVE research using AI-assisted intelligence gathering. Uses Perplexity MCP when available; falls back to web search and manual research guidance when it is not.

## MCP Availability Check

Before starting research, check if Perplexity MCP is available. If any `mcp__perplexity__*` tool is accessible, use the Perplexity path. If not:

1. Announce: "Perplexity MCP is not configured. Falling back to web search for CVE research."
2. Use `WebSearch` or `WebFetch` tools to query NVD, CISA KEV, and FIRST EPSS directly:
   - NVD: `https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=<CVE-ID>`
   - EPSS: `https://api.first.org/data/v1/epss?cve=<CVE-ID>`
   - KEV: `https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json`
3. Mark all research output with `source: manual-web-search` instead of `source: perplexity`
4. Note in the enrichment that AI-assisted cross-correlation was not available — the analyst should review for completeness gaps

The quality rubric does not penalize manual research. It penalizes missing data regardless of collection method.

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

- **Perplexity not configured:** follow the MCP Availability Check fallback above
- **Perplexity timeout:** retry with simpler query, fall back to faster tool tier, then fall back to web search
- **Perplexity returns no results:** fall back to direct NVD/EPSS/KEV API queries
- **CVE not found:** offer correction or manual research
- **Missing data:** continue with available fields, flag gaps
- **Hallucination detection:** validate URL formats, score ranges (CVSS 0-10, EPSS 0-1), T-number validity (T####.###)

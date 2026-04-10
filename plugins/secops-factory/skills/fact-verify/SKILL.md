---
name: fact-verify
description: "Use when verifying factual claims in security analyses against authoritative sources. Supports CVE claim verification and event investigation verification."
argument-hint: "<ticket-id>"
---

# Fact Verification

Verify factual claims in security documents against authoritative sources. Uses Perplexity MCP when available; falls back to direct web queries when it is not.

## Process

### Step 1: Detect Claim Type

- CVE verification: if CVE-ID present or claim_type=cve
- Event investigation: if investigation document or claim_type=event

### Step 2: Extract Verifiable Claims

**CVE claims:**
- CVSS score (verify against NVD)
- EPSS score (verify against FIRST API)
- KEV status (verify against CISA catalog)
- Affected versions (verify against vendor advisory)
- Patched versions (verify against vendor advisory)
- ATT&CK technique IDs (verify against attack.mitre.org)

**Event claims:**
- IP ownership/ASN (verify via WHOIS/BGP)
- Geolocation claims (verify via IP geolocation services)
- Threat intelligence associations (verify via threat feeds)
- Protocol/port combinations (verify standard assignments)

### Step 3: Verify Each Claim

For each claim:
1. If Perplexity MCP is available: query with specific verification question
2. If Perplexity is not available: use `WebSearch` or `WebFetch` to query authoritative APIs directly:
   - NVD API for CVSS: `https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=<CVE-ID>`
   - FIRST API for EPSS: `https://api.first.org/data/v1/epss?cve=<CVE-ID>`
   - MITRE ATT&CK for technique IDs: `https://attack.mitre.org/techniques/<T-ID>/`
3. Cross-reference with authoritative source
4. Record: claim, source, verification result (Verified/Unverified/Incorrect), research method (perplexity|web-search)
5. For incorrect claims: document the correct value and source

### Step 4: Generate Report

For each claim, output:
- Claim text
- Source cited
- Verification status
- Authoritative source and value (if different)
- Impact of discrepancy (if any)

### Trusted Sources

NVD, CISA KEV, FIRST EPSS, MITRE ATT&CK, vendor security advisories, GitHub advisories.

### Security Considerations

- Validate CVE ID format before querying
- Sanitize ticket IDs to prevent injection
- Detect private IPs (cannot verify externally)
- Flag unverified claims clearly

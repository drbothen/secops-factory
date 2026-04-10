---
name: scan-threats
description: "Use when scanning for emerging security threats, recent CVE disclosures, CISA alerts, vendor advisories, and ICS-CERT bulletins. Filters by sector, severity, and advisory worthiness."
argument-hint: "[--sector energy|water|manufacturing|all] [--severity critical|high|medium] [--days 7]"
---

# Scan Threats

Scan recent security intelligence sources for advisory-worthy items. Returns a prioritized list of candidates with rationale for each.

## Announce at Start

Before any other action, say verbatim:

> I'm scanning for emerging security threats to identify advisory-worthy items.

## Advisory Type Selection

Before scanning, present the user with:

> What environment should I focus on?
> 1. **IT** — enterprise/cloud, internet-facing systems
> 2. **ICS/OT** — industrial control systems, SCADA, safety systems
> 3. **Combined** — both IT and ICS/OT threats

The selection shapes which sources are prioritized and how results are filtered.

## Arguments

- `--sector` — critical infrastructure sector filter (energy, water, manufacturing, transportation, healthcare, all). Default: all. Only applies to ICS/OT and Combined.
- `--severity` — minimum severity threshold (critical, high, medium). Default: high.
- `--days` — lookback window in days. Default: 7.

## Sources to Scan

### IT Sources (types 1 and 3)
1. **CISA Alerts** — recent cybersecurity advisories
2. **NVD Recent CVEs** — newly published CVEs above severity threshold
3. **KEV Additions** — newly added CISA Known Exploited Vulnerabilities
4. **Vendor PSIRTs** — Microsoft MSRC, Cisco PSIRT, Palo Alto, Fortinet, VMware
5. **Threat campaigns** — active threat actor campaigns, ransomware trends

### ICS/OT Sources (types 2 and 3)
1. **CISA ICS-CERT Advisories** — ICSA-series advisories
2. **ICS vendor bulletins** — Siemens ProductCERT, Schneider Electric, Rockwell, ABB
3. **ICS protocol vulnerabilities** — Modbus, DNP3, OPC-UA, EtherNet/IP
4. **Sector-specific alerts** — filtered by `--sector` argument

## Research Method

**Step 1: Check Perplexity availability.** Try calling any `mcp__perplexity__*` tool. If the tool exists and responds, use the Perplexity path. If the tool call fails with "unknown tool", "not found", or any MCP error, switch immediately to the web search path. Do NOT retry Perplexity or ask the user to configure it — proceed with web search.

### Path A: With Perplexity MCP

Use these queries (adapt to sector/severity/days args):
- "CISA cybersecurity advisories published in the last 7 days"
- "critical CVEs affecting ICS SCADA systems published this week"
- "new additions to CISA Known Exploited Vulnerabilities catalog this month"
- "active ransomware campaigns targeting [sector] infrastructure 2024"

### Path B: Without Perplexity (WebSearch fallback)

If Perplexity is not available, use `WebSearch` for each source category:

1. **CISA alerts:** `WebSearch` for "site:cisa.gov cybersecurity advisory 2024"
2. **NVD recent CVEs:** `WebSearch` for "site:nvd.nist.gov CVE critical [days] days"
3. **KEV additions:** `WebFetch` on `https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json` and filter by dateAdded
4. **Vendor PSIRTs:** `WebSearch` for "site:msrc.microsoft.com OR site:sec.cloudapps.cisco.com security advisory [month] [year]"
5. **ICS-CERT:** `WebSearch` for "site:cisa.gov ics advisory ICSA [year]"

Announce which path you are using: "Using Perplexity for threat scanning" or "Perplexity not available — using web search for threat scanning."

## Prioritization Criteria

Score each candidate 1-10 based on:

| Factor | Weight | Scoring |
|--------|--------|---------|
| CVSS severity | 25% | Critical=10, High=8, Medium=5, Low=2 |
| Exploit status | 25% | Active exploitation=10, PoC=7, None=2 |
| KEV listing | 15% | In KEV=10, Not=0 |
| Sector relevance | 15% | Matching sector=10, Adjacent=5, Unrelated=2 |
| Recency | 10% | Last 24h=10, Last 7d=7, Older=3 |
| Asset prevalence | 10% | Widely deployed=10, Niche=3 |

**Advisory threshold:** score >= 6.0 → recommend advisory creation.

## Output

Present results as a prioritized table:

```
## Threat Scan Results — [date range]

Environment: [IT / ICS-OT / Combined]
Sector filter: [sector or all]
Severity threshold: [level]

| # | Candidate | CVE(s) | Score | Severity | Exploit | Why advisory-worthy |
|---|-----------|--------|-------|----------|---------|---------------------|
| 1 | [title]   | CVE-.. | 9.2   | Critical | Active  | [1-line rationale]  |
| 2 | ...       | ...    | 7.8   | High     | PoC     | ...                 |

### Recommendation
Create advisories for items #1 and #2. Run `/create-advisory <topic>` for each.
```

## Error Handling

- **No results above threshold:** report "No advisory-worthy items found in the last N days at severity >= X. Consider lowering the severity threshold or expanding the lookback window."
- **Source unavailable:** note which source failed, continue with remaining sources
- **Perplexity not configured:** fall back to web search, note reduced coverage in output

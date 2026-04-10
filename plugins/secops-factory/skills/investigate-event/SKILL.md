---
name: investigate-event
description: "Use when investigating a security event alert (ICS, IDS, SIEM). Executes 7-stage investigation: triage, metadata, network IDs, evidence, analysis, disposition (TP/FP/BTP), documentation and JIRA update."
argument-hint: "<ticket-id>"
---

# Investigate Security Event Alert

Execute the complete 7-stage Security Event Investigation Workflow from JIRA ticket triage through evidence collection, disposition determination, and documentation.

## The Iron Law

> **NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST**

A disposition (TP/FP/BTP) without evidence is an opinion, not an investigation. Every disposition must trace back through collected evidence, technical analysis, and documented reasoning. If evidence is insufficient, flag as incomplete -- do not guess.

## Announce at Start

Before any other action, say verbatim:

> I am using the investigate-event skill to run the complete 7-stage event investigation workflow for <ticket-id>.

## Red Flags

| Thought | Reality |
|---|---|
| "The alert says High severity, so it must be a True Positive" | Alert severity is input, not conclusion. Investigate independently. |
| "No logs available, I'll skip evidence collection" | Flag as incomplete. Do not disposition without minimum evidence. |
| "This looks like the same alert we saw last week, it's an FP" | Each event needs independent investigation. Check, don't assume. |
| "Claroty says it's malicious, that's good enough" | Automation bias. Independently verify platform classification. |
| "I'll skip historical context, this is clearly new" | Always check 30/60/90-day patterns. Recency bias is common. |
| "The source IP is internal, so it's safe" | Internal IPs can be compromised. Investigate lateral movement. |
| "I'm confident it's BTP, no need for alternatives" | Always document at least 2 alternative dispositions considered. |
| "I'll update JIRA before saving locally" | Save locally FIRST for chain of custody. Then update JIRA. |

## Prerequisites

- `jr` CLI installed and authenticated (`jr auth login`)
- Valid JIRA ticket ID with security event alert
- Perplexity MCP available (optional — enriches threat intelligence; investigation proceeds without it using web search fallback)

## Research Tool Selection

Before Stage 3, determine which research path to use for the entire investigation:

1. **Try calling any `mcp__perplexity__*` tool** (e.g., `mcp__perplexity__perplexity_search` with a simple test query)
2. **If it succeeds:** use Perplexity for all threat intelligence queries in Stages 3-5
3. **If it fails (unknown tool, MCP error, timeout):** use `WebSearch` and `WebFetch` for all threat intelligence queries. Do NOT retry Perplexity, do NOT ask the user to configure it, do NOT stop the investigation.

Announce which path: "Using Perplexity for threat intelligence" or "Perplexity not available — using web search for threat intelligence."

This decision is made ONCE at the start and applies to all stages. Do not re-check per stage.

## Workflow: 7 Stages

### Stage 1: Triage and Alert Type Detection (2-3 min)

1. Read JIRA ticket via `/read-ticket <ticket-id>`
2. Auto-detect alert platform type:
   - **ICS/SCADA:** Claroty, Nozomi, Dragos, CyberX, Modbus, DNP3, PLC, HMI
   - **IDS/IPS:** Snort, Suricata, Palo Alto, Cisco Firepower, SID:
   - **SIEM:** Splunk, QRadar, Sentinel, Elastic Security, Notable Event
3. If ambiguous: prompt user to select ICS/IDS/SIEM
4. Extract initial alert metadata (name, severity, timestamp, source, rule ID)

### Stage 2: Alert Metadata Collection (2-3 min)

1. Capture sensor/platform details and detection engine version
2. Extract raw alert data from ticket
3. Build event timeline (occurrence -> detection -> investigation start)

### Stage 3: Network/Host Identifier Documentation (3-4 min)

1. Extract source and destination: IP, hostname, asset type, criticality, zone
2. Capture protocol, port, service identification
3. For external IPs: lookup ASN, geolocation, reputation (via Perplexity if available, otherwise via `WebSearch` using WHOIS/BGP lookup services)
4. If data missing from ticket: prompt user for required fields

### Stage 4: Evidence Collection (5-8 min)

1. Identify relevant log sources
2. Prompt user for log excerpts (with PII handling notice)
3. Collect correlated events
4. Gather historical context
5. Optional: AI-assisted threat intelligence (via Perplexity if available, otherwise via `WebSearch` for threat feeds and IOC databases)

### Stage 5: Technical Analysis (4-6 min)

1. Protocol/port validation and legitimacy assessment
2. Attack vector analysis with MITRE ATT&CK reference
3. Log interpretation and IOC identification
4. Optional: threat intelligence correlation (Perplexity if available, `WebSearch` otherwise)
5. Asset context assessment (function, business impact, environment)

### Stage 6: Disposition Determination (3-5 min)

1. Present evidence summary
2. Apply disposition framework:
   - **True Positive (TP):** Genuine malicious/unauthorized activity
   - **False Positive (FP):** Benign activity incorrectly flagged
   - **Benign True Positive (BTP):** Real but authorized activity
3. Collect: disposition, confidence level, reasoning, alternatives considered
4. Determine escalation and next actions
5. If Low confidence: automatically recommend escalation

### Stage 7: Documentation and JIRA Update (2-3 min)

1. Generate investigation document from `${CLAUDE_PLUGIN_ROOT}/templates/event-investigation-tmpl.yaml`
2. Save locally FIRST (chain of custody)
3. Post investigation as JIRA comment
4. Update JIRA custom fields (disposition, confidence, next actions, duration)

## References

- `${CLAUDE_PLUGIN_ROOT}/data/event-investigation-best-practices.md`
- `${CLAUDE_PLUGIN_ROOT}/data/cognitive-bias-patterns.md`
- `${CLAUDE_PLUGIN_ROOT}/data/mitre-attack-mapping-guide.md`
- `${CLAUDE_PLUGIN_ROOT}/templates/event-investigation-tmpl.yaml`
- `${CLAUDE_PLUGIN_ROOT}/checklists/investigation-completeness-checklist.md`

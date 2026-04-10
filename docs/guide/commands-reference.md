# Commands Reference

All commands available in SecOps Factory, grouped by workflow.

## Enrichment Workflow

| Command | Arguments | Description |
|---------|-----------|-------------|
| `/enrich-ticket` | `<ticket-id>` | Run the complete 8-stage enrichment workflow. Reads the JIRA ticket, researches CVE intelligence via Perplexity, assesses business context, plans remediation, maps to MITRE ATT&CK, calculates multi-factor priority, generates documentation, and updates JIRA. |
| `/research-cve` | `<cve-id>` | Deep CVE research using Perplexity. Returns CVSS, EPSS, KEV status, exploit availability, patches, ATT&CK suggestions, and CWE classification. Tool tier selected by severity. |
| `/assess-priority` | `<ticket-id>` | Calculate multi-factor priority (P1-P5) using 6 factors: CVSS severity, EPSS probability, KEV status, asset criticality, system exposure, and exploit availability. Returns score, priority, and SLA deadline. |
| `/map-attack` | `<cve-id>` | Map a CVE to MITRE ATT&CK tactics and techniques. Supports both Enterprise and ICS ATT&CK matrices. Returns T-numbers, confidence levels, and detection recommendations. |

## Investigation Workflow

| Command | Arguments | Description |
|---------|-----------|-------------|
| `/investigate-event` | `<ticket-id>` | Run the complete 7-stage event investigation workflow. Auto-detects ICS/IDS/SIEM platform type, collects evidence, performs technical analysis, determines TP/FP/BTP disposition with confidence level, and updates JIRA. |

## Review Workflow

| Command | Arguments | Description |
|---------|-----------|-------------|
| `/review-enrichment` | `<ticket-id> [--type=auto\|cve\|event]` | Polymorphic peer review. Auto-detects CVE enrichment (8-dimension scoring) or event investigation (7-dimension weighted scoring). Scores quality, identifies gaps, and posts review as JIRA comment. |
| `/adversarial-review-secops` | `<ticket-id>` | Multi-pass adversarial convergence review. Dispatches security-reviewer in fresh-context passes with strict-binary novelty classification. Minimum 2 passes, maximum 5. Quality threshold: >= 7.0/10, no dimension < 5.0. |
| `/fact-verify` | `<ticket-id>` | Verify factual claims in security analyses against authoritative sources. Checks CVSS, EPSS, KEV values against NVD/FIRST/CISA. For events, verifies IP ownership, geolocation, and threat intelligence associations. |

## Advisory Workflow

| Command | Arguments | Description |
|---------|-----------|-------------|
| `/scan-threats` | `[--sector energy\|water\|...] [--severity critical\|high\|medium] [--days 7]` | Scan for emerging security threats across CISA, NVD, KEV, vendor PSIRTs, and ICS-CERT. Returns a prioritized table of advisory-worthy candidates scored by severity, exploit status, KEV listing, sector relevance, and recency. Items scoring >= 6.0 are recommended for advisory creation. Supports IT, ICS/OT, and combined environment filtering. |
| `/create-advisory` | `<topic\|CVE-ID\|URL> [--template path] [--type it\|ics\|combined]` | Create a structured security advisory from a CVE ID, a URL (fetches and parses the page), or a topic/campaign name. Prompts for advisory type (IT/ICS-OT/Combined) unless `--type` is specified. Uses the built-in CSAF-inspired template by default; accepts custom templates via `--template`. Verifies all data against NVD/CISA/FIRST. |

## Utility

| Command | Arguments | Description |
|---------|-----------|-------------|
| `/read-ticket` | `<ticket-id>` | Read a JIRA security ticket and extract CVE IDs, affected systems, asset criticality, system exposure, and metadata. Returns structured data for downstream skills. |
| `/update-jira` | `<ticket-id>` | Update JIRA custom fields with enrichment data (CVSS, EPSS, KEV, priority). Validates all data ranges before update. Blocked by the require-review hook until review approval is obtained. |
| `/generate-metrics` | `[--period=7d\|30d\|90d]` | Generate security operations metrics and KPIs from enrichment and investigation data. Reports on enrichment volume, quality scores, priority distribution, disposition breakdown, and SLA compliance. Default period: 30 days. |
| `/secops-health` | -- | Check plugin health. Verifies MCP server availability (Atlassian + Perplexity), all 8 data files, 4 templates, 15 checklists, and 11 skills. Reports PASS/FAIL for each category. |

## Argument Formats

| Argument | Format | Examples |
|----------|--------|----------|
| `<ticket-id>` | `{PROJECT_KEY}-{NUMBER}` | `SEC-1234`, `VULN-567`, `ICS-89` |
| `<cve-id>` | `CVE-YYYY-NNNNN` (case-insensitive) | `CVE-2024-12345`, `cve-2023-4567` |
| `--type` | `auto`, `cve`, or `event` | `--type=event` |
| `--period` | Duration with unit | `7d`, `30d`, `90d` |
| `--sector` | Critical infra sector | `energy`, `water`, `manufacturing`, `all` |
| `--severity` | Minimum severity | `critical`, `high`, `medium` |
| `--days` | Lookback window | `7`, `14`, `30` |
| `--template` | Path to custom template | `./our-advisory.md` |

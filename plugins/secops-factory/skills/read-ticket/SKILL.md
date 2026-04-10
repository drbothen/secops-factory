---
name: read-ticket
description: "Use when reading a JIRA security ticket to extract CVE IDs, affected systems, and metadata for vulnerability analysis or event investigation."
argument-hint: "<ticket-id>"
---

# Read JIRA Ticket

Read a JIRA security ticket via `jr` CLI, extract CVE IDs and affected system metadata.

## Prerequisites

- `jr` CLI installed and authenticated (`jr auth login`)
- Valid ticket ID in `{PROJECT_KEY}-{NUMBER}` format

## Process

1. Validate ticket ID format: `{PROJECT_KEY}-{NUMBER}`
2. Fetch ticket via Bash:
   ```bash
   jr issue view <ticket-id>
   ```
3. Extract CVE IDs using pattern `CVE-\d{4}-\d{4,7}` from summary, description, custom fields
4. Designate first CVE as primary; collect all CVEs
5. Extract: affected systems, asset criticality, system exposure, components, labels, priority
6. If linked CMDB assets exist, fetch them:
   ```bash
   jr issue assets <ticket-id>
   ```
7. If no CVE found: prompt user or proceed without
8. Display summary and return structured data

## Output Structure

```yaml
ticket_id: '{ticket_id}'
summary: '{summary}'
description: '{description}'
cve_ids:
  primary: '{primary_cve}'
  all: ['{cve_1}', ...]
affected_systems: ['{system_1}', ...]
asset_criticality: '{rating}'
system_exposure: '{exposure}'
priority: '{priority}'
linked_assets: ['{asset_key}', ...]
```

## Error Handling

- **jr not found:** "jr CLI is required. Install from https://github.com/Zious11/jira-cli"
- **Not authenticated:** "Run `jr auth login` to authenticate with JIRA"
- **Ticket not found:** validate ID format, suggest `jr issue list --jql "key = <id>"`
- **No CVE found:** prompt user or skip CVE-dependent stages

---
name: read-ticket
description: "Use when reading a JIRA security ticket to extract CVE IDs, affected systems, and metadata for vulnerability analysis or event investigation."
argument-hint: "<ticket-id>"
---

# Read JIRA Ticket

Read a JIRA security alert ticket via Atlassian MCP, extract CVE IDs and affected system metadata.

## Process

1. Validate ticket ID format: `{PROJECT_KEY}-{NUMBER}`
2. Fetch ticket via `mcp__atlassian__getJiraIssue`
3. Extract CVE IDs using pattern `CVE-\d{4}-\d{4,7}` from summary, description, custom fields
4. Designate first CVE as primary; collect all CVEs
5. Extract: affected systems, asset criticality, system exposure, components, labels, priority
6. If no CVE found: prompt user or proceed without
7. Display summary and return structured data

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
```

## Error Handling

- Ticket not found: validate ID, retry
- Auth failure: check MCP config
- Rate limit: exponential backoff (60s, 120s, 240s)
- No CVE found: prompt user or skip

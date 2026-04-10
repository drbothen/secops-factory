# Agents Reference

SecOps Factory uses two agents with distinct roles and deliberate information asymmetry.

## Security Analyst -- Alex

| Property | Value |
|----------|-------|
| Name | Alex |
| Role | Security Operations Analyst |
| Model | Sonnet |
| Color | Blue |
| File | `agents/security-analyst.md` |

**Capabilities:**
- Vulnerability enrichment (8-stage CVE pipeline)
- Security event investigation (7-stage event pipeline)
- CVE research via Perplexity (tiered by severity)
- MITRE ATT&CK mapping (Enterprise and ICS matrices)
- Multi-factor priority assessment (6-factor P1-P5)
- JIRA ticket reading, comment posting, and field updates
- Structured documentation from templates

**MCP tools:**
- Atlassian: `getJiraIssue`, `updateJiraIssue`, `searchJiraIssues`, `addCommentToJiraIssue`
- Perplexity: `perplexity_search`, `perplexity_ask`, `perplexity_reason`, `perplexity_research`

**Available commands:** `/secops-factory:enrich-ticket`, `/secops-factory:research-cve`, `/secops-factory:assess-priority`, `/secops-factory:map-attack`, `/secops-factory:investigate-event`, `/secops-factory:read-ticket`, `/secops-factory:update-jira`

## Security Reviewer -- Riley

| Property | Value |
|----------|-------|
| Name | Riley |
| Role | Senior Security Analyst (Peer Review) |
| Model | Opus |
| Color | Red |
| File | `agents/security-reviewer.md` |

**Capabilities:**
- Polymorphic quality review (auto-detects CVE enrichment vs event investigation)
- 8-dimension CVE enrichment scoring
- 7-dimension weighted event investigation scoring
- Independent disposition validation (forms own disposition before reading analyst's)
- Cognitive bias detection (confirmation, anchoring, availability, automation, overconfidence, recency)
- Fact verification against authoritative sources
- Blameless, constructive feedback with strengths-first methodology

**MCP tools:**
- Atlassian: `getJiraIssue`, `updateJiraIssue`, `addCommentToJiraIssue`
- Perplexity: `perplexity_search`, `perplexity_reason`

**Available commands:** `/secops-factory:review-enrichment`, `/secops-factory:fact-verify`, `/secops-factory:adversarial-review-secops`

## Information Asymmetry

The reviewer does NOT see:
- Analyst reasoning or internal notes
- Prior review pass findings
- Orchestrator summaries or context

The reviewer evaluates only the artifact as presented. This asymmetry is the mechanism that catches blind spots. Do not summarize prior reviews for the reviewer -- doing so destroys the quality guarantee.

When dispatched via `/secops-factory:adversarial-review-secops`, the reviewer runs in a forked context. Each pass starts fresh with no memory of previous passes.

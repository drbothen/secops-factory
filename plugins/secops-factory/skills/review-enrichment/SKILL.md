---
name: review-enrichment
description: "Use when reviewing a security analyst's enrichment or investigation. Polymorphic: auto-detects CVE enrichment (8-dimension scoring) or event investigation (7-dimension weighted scoring). Blameless, constructive feedback."
argument-hint: "<ticket-id> [--type=auto|cve|event]"
---

# Review Security Enrichment

Execute polymorphic peer review of security analyses. Auto-detects whether the artifact is a CVE enrichment or event investigation, then applies the appropriate quality rubric.

## The Iron Law

> **NO APPROVAL WITHOUT FRESH-CONTEXT REVIEW FIRST**

The reviewer evaluates the artifact as presented, without prior review context, author reasoning, or orchestrator summaries. This information asymmetry is the mechanism that catches blind spots. If you have seen prior reviews, you are contaminated -- dispatch a fresh reviewer.

## Announce at Start

Before any other action, say verbatim:

> I am using the review-enrichment skill to perform a systematic quality review of <ticket-id>.

## Red Flags

| Thought | Reality |
|---|---|
| "The analyst is experienced, I can do a lighter review" | Systematic review regardless of analyst experience. Use all checklists. |
| "No critical findings, so it must be good" | Run all dimensions. Zero critical does not mean zero significant. |
| "I'll just check CVSS and move on" | 8 dimensions for CVE, 7 for events. Check them all. |
| "The disposition looks right, no need to form my own" | Information asymmetry. Form your own disposition BEFORE reading analyst's. |
| "I found some issues but they're probably fine" | Document every finding. Let severity categorization determine importance. |
| "I'll skip bias detection, it seems clean" | Bias detection is mandatory. The most dangerous biases are invisible. |
| "Strengths are obvious, I'll skip to findings" | Strengths-first is methodology, not politeness. Always start positive. |

## Type Detection Logic

1. Check JIRA Issue Type: "Event Alert"/"ICS Alert" -> event; "Security Vulnerability" -> CVE
2. Check description: CVE-YYYY-NNNNN pattern -> CVE; ICS/IDS/SIEM keywords -> event
3. Check comments: "Security Analysis Enrichment" heading -> CVE; "Disposition:" field -> event
4. If ambiguous: prompt user to select

## CVE Enrichment Review (8 Dimensions)

Run all 8 checklists from `${CLAUDE_PLUGIN_ROOT}/checklists/`:
1. `technical-accuracy-checklist.md`
2. `completeness-checklist.md`
3. `actionability-checklist.md`
4. `contextualization-checklist.md`
5. `documentation-quality-checklist.md`
6. `attack-mapping-validation-checklist.md`
7. `cognitive-bias-checklist.md`
8. `source-citation-checklist.md`

Score each: (Passed / Total) x 100. Average for overall score.

## Event Investigation Review (7 Weighted Dimensions)

Run all 7 checklists from `${CLAUDE_PLUGIN_ROOT}/checklists/`:
1. `investigation-completeness-checklist.md` (25%)
2. `investigation-technical-accuracy-checklist.md` (20%)
3. `disposition-reasoning-checklist.md` (20%)
4. `investigation-contextualization-checklist.md` (15%)
5. `investigation-methodology-checklist.md` (10%)
6. `investigation-documentation-quality-checklist.md` (5%)
7. `investigation-cognitive-bias-checklist.md` (5%)

Weighted score = Sum of (dimension score x weight).

### Disposition Validation (Event only)

1. Extract analyst disposition from document
2. Independently assess based on evidence
3. Compare: agreement confirms; disagreement requires detailed reasoning with evidence
4. Flag Low confidence dispositions for escalation

## Categorize Findings

**Critical:** Factually incorrect, missing required data, wrong priority. Blocks progression.
**Significant:** Missing EPSS, vague remediation, weak rationale. Should fix.
**Minor:** Formatting, additional context, more citations. Nice to have.

## Output

Generate review report using appropriate template:
- CVE: `${CLAUDE_PLUGIN_ROOT}/templates/security-review-report-tmpl.yaml`
- Event: `${CLAUDE_PLUGIN_ROOT}/templates/security-event-investigation-review-report-tmpl.yaml`

Post review as JIRA comment. Always start with strengths.

## References

- `${CLAUDE_PLUGIN_ROOT}/data/review-best-practices.md`
- `${CLAUDE_PLUGIN_ROOT}/data/cognitive-bias-patterns.md`
- All checklists in `${CLAUDE_PLUGIN_ROOT}/checklists/`

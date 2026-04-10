---
name: orchestrator-review-convergence
description: Orchestrator workflow reference for the adversarial review convergence loop. Loaded by the adversarial-review-secops skill. Not directly invokable.
disable-model-invocation: true
---

# Adversarial Review Convergence Workflow

**Canonical source** for the secops adversarial review convergence loop. The `adversarial-review-secops` skill (`skills/adversarial-review-secops/SKILL.md`) is the entry point; this file is the playbook. If the two disagree, this file wins.

## Convergence Loop

```
repeat:
  1. Dispatch security-reviewer with fresh context
  2. Reviewer scores against quality dimensions
  3. Reviewer runs cognitive bias audit
  4. Reviewer emits SUBSTANTIVE or NITPICK
  5. If SUBSTANTIVE → route findings to analyst → analyst fixes → goto 1
  6. If NITPICK → convergence reached → approve
until: NITPICK or max 5 passes
```

## Dispatch Rules

- **Fresh context per pass.** The reviewer must NOT see prior review passes. Each dispatch starts clean with only: (a) the enrichment/investigation artifact being reviewed, (b) the applicable quality checklist, (c) the cognitive bias patterns reference.
- **No analyst reasoning.** The reviewer sees the output, not the analyst's thought process. This is the information asymmetry that makes the review valuable.
- **Inline delivery.** The reviewer returns findings inline using `=== FILE: <path> ===` delimiters. The dispatcher persists them.

## Quality Thresholds

### CVE Enrichment (8 dimensions, unweighted)
- Overall score: >= 7.0 / 10
- No individual dimension below 5.0
- Checklists: `${CLAUDE_PLUGIN_ROOT}/checklists/technical-accuracy-checklist.md`, `completeness-checklist.md`, `actionability-checklist.md`, `contextualization-checklist.md`, `documentation-quality-checklist.md`, `attack-mapping-validation-checklist.md`, `cognitive-bias-checklist.md`, `source-citation-checklist.md`

### Event Investigation (7 dimensions, weighted)
- Weighted score: >= 7.0 / 10
- No individual dimension below 5.0
- Weights: Completeness 25%, Accuracy 20%, Disposition Reasoning 20%, Contextualization 15%, Methodology 10%, Documentation 5%, Bias 5%
- Checklists: `${CLAUDE_PLUGIN_ROOT}/checklists/investigation-*.md`

### Priority Assessment
- Multi-factor justification covers all 4 factors (CVSS, EPSS, KEV, business context)
- Priority tier is consistent with factor combination per `${CLAUDE_PLUGIN_ROOT}/data/priority-framework.md`

## Cognitive Bias Audit (mandatory per pass)

Every reviewer pass MUST check for and report on:
1. **Automation bias** — did the analyst over-trust scanner/tool output?
2. **Anchoring bias** — is the analyst fixated on a single metric (e.g., CVSS base score)?
3. **Confirmation bias** — did the analyst seek only evidence supporting their conclusion?
4. **Availability bias** — is the analyst over-weighting recent similar incidents?

A finding of bias is SUBSTANTIVE by definition — it changes the model of the analysis quality.

## Strict-Binary Novelty

Only two classifications:
- **SUBSTANTIVE** — findings change the quality assessment. Another pass required.
- **NITPICK** — findings are style, phrasing, or restatements. Convergence reached.

The reviewer has no authority to declare convergence. Only the protocol does. "Effectively converged", "borderline NITPICK", and "recommend halting" all count as SUBSTANTIVE.

## Honest Convergence

If the reviewer finds fewer than 3 substantive items, it should declare convergence and emit no updated file. Fabricating findings to justify the pass is strictly worse than stopping. The dispatcher prefers an honest NITPICK over a padded SUBSTANTIVE.

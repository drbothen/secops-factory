---
name: adversarial-review-secops
description: "Use when performing multi-pass adversarial convergence review of security analyses. Dispatches security-reviewer in fresh-context passes with strict-binary novelty until convergence. Quality thresholds: >=7.0/10 overall, no dimension <5.0."
argument-hint: "<ticket-id>"
context: fork
agent: security-reviewer
---

# Adversarial Review for Security Operations

THE CONVERGENCE LOOP SKILL. Dispatches the security-reviewer agent in fresh-context passes to achieve adversarial convergence on security analysis quality.

## The Iron Law

> **NO QUALITY SIGN-OFF WITHOUT ADVERSARIAL CONVERGENCE FIRST**

A single review pass systematically misses things. Convergence requires minimum 2 passes with strict-binary novelty classification. The adversary has not seen prior passes -- that asymmetry is the mechanism.

## Announce at Start

Before any other action, say verbatim:

> I am using the adversarial-review-secops skill to run convergence review passes on <ticket-id>.

## Red Flags

| Thought | Reality |
|---|---|
| "One pass found nothing, we're converged" | Zero findings after one pass is a prompt bug, not convergence. Min 2 passes. |
| "I'll summarize the prior pass for the reviewer" | Destroys information asymmetry. Dispatch with only the artifact. |
| "The reviewer and I agree, no need for pass 2" | Agreement after 1 pass is not convergence. Run pass 2. |
| "This finding is minor, I'll downgrade it" | Severity is the reviewer's call, not the orchestrator's. Record as-is. |
| "Same finding keeps appearing" | It keeps appearing because it isn't fixed. Fix it, then re-run. |
| "Novelty is LOW after pass 1" | Minimum 2 passes. No exceptions. LOW after 1 is not convergence. |
| "The quality score is 6.8, close enough to 7.0" | Threshold is >=7.0. Close is not passing. Fix and re-run. |
| "I'll skip cognitive bias audit this pass" | Bias audit is mandatory per pass. Invisible biases are the most dangerous. |

## Convergence Protocol

### Pass Management

1. Each review is a numbered pass (SECOPS-P1, SECOPS-P2, etc.)
2. Minimum 2 passes, maximum 5 before escalating
3. Each pass dispatches security-reviewer with ONLY the artifact (no prior findings)
4. After each pass, classify novelty

### Honest Convergence (mandatory clause in every reviewer prompt)

Strict-binary novelty prevents premature convergence, but it has a failure mode: reviewers fabricate findings to justify their existence. Every reviewer dispatch MUST include this clause verbatim:

> **Honest convergence is required.** If you find fewer than 3 substantive items, declare convergence and emit no updated file — say "converged, no file emitted." Do not invent findings to justify this pass. Fabricating findings wastes analyst time, erodes trust in the review process, and is strictly worse than stopping. The orchestrator prefers an honest NITPICK over a padded SUBSTANTIVE.

### Known Review Hallucination Classes

Round 1 review outputs are systematically susceptible to these failure modes. Round 2+ prompts should instruct the reviewer to audit prior findings for these classes:

1. **Over-extrapolated bias signals** — reviewer flags "confirmation bias" based on a single piece of supporting evidence, ignoring that the analyst documented 3 alternatives. Check: did the analyst actually exhibit the bias, or just reach a conclusion?
2. **Miscounted checklist scores** — reviewer claims "3 of 8 dimensions incomplete" when recounting shows 2. Always re-derive scores from the checklist items, not from prior narrative.
3. **Phantom findings from template structure** — reviewer flags "missing Executive Summary" when the section exists under a slightly different heading. Check: is the content present, even if the heading doesn't match exactly?
4. **Conflated severity and quality** — reviewer downgrades quality score because the vulnerability is low-severity. Quality measures the analysis, not the vuln. A P5 informational CVE can have a 10/10 enrichment.
5. **Prior-pass contamination** — reviewer references details from a prior pass it should not have seen. This indicates information asymmetry was breached — re-dispatch with clean context.

### Strict-Binary Novelty Classification

After each pass, classify every finding as one of:

- **SUBSTANTIVE:** Changes the quality model. New gap discovered, factual error found, missing dimension identified, disposition disagreement.
- **NITPICK:** Refines existing understanding. Rephrasing, formatting, minor enhancements, style preferences.

**Convergence criterion:** A pass where ALL findings are NITPICK = converged.

### Task-Specific Attack Surfaces

For each pass, the reviewer focuses on attack surfaces derived from quality checklists:

**CVE Enrichment Attack Surfaces:**
- Technical accuracy: Are CVSS, EPSS, KEV values verifiable against authoritative sources?
- Completeness: Are all 12 template sections populated with substantive content?
- Actionability: Can the remediation team execute from this document alone?
- Contextualization: Does business context actually influence the priority assessment?
- Source quality: Are all claims traced to authoritative sources?
- ATT&CK mapping: Are techniques valid for the vulnerability type?
- Bias detection: Are there confirmation, anchoring, or automation bias patterns?

**Event Investigation Attack Surfaces:**
- Evidence chain: Can every claim trace back to documented evidence?
- Disposition logic: Would a different analyst reach the same conclusion from this evidence?
- Alternative analysis: Were genuinely different explanations considered, not straw men?
- Temporal analysis: Is the timeline internally consistent?
- ICS awareness: Were OT-specific considerations applied (Purdue zones, safety systems)?

### Cognitive Bias Audit (Mandatory Per Pass)

Each pass MUST include a cognitive bias assessment:
1. Check for confirmation bias (only seeking supporting evidence)
2. Check for anchoring (locked to initial severity)
3. Check for availability (recent incidents over-influencing)
4. Check for automation (accepting platform classification blindly)
5. Check for overconfidence (claims without evidence)
6. Check for recency (ignoring historical patterns)

Reference: `${CLAUDE_PLUGIN_ROOT}/data/cognitive-bias-patterns.md`

### Quality Thresholds

- **Overall score:** >= 7.0/10 (70%)
- **No dimension:** < 5.0/10 (50%)
- **Critical findings:** 0 (all must be resolved before sign-off)

If thresholds not met after convergence: flag for analyst rework with specific guidance.

## Subagent Delivery Protocol (inline-by-default)

The security-reviewer may run in a sandbox where Write is denied. Every reviewer dispatch MUST include this instruction verbatim:

> **CRITICAL DELIVERY INSTRUCTION**: Do NOT use the Write tool. Return all deliverables inline, delimited with `=== FILE: <filename> ===` on its own line followed by the complete file content. Use ASCII only — no HTML entity encoding. The orchestrator persists the files after receiving your return. This is NOT a fallback — this IS the approved delivery mode for this dispatch.

The orchestrator parses the return for `=== FILE: ... ===` delimiters and writes each block to disk.

## Canonical Source

The adversarial review convergence workflow lives in `agents/orchestrator/review-convergence-workflow.md` and is the authoritative source. This skill is the entry point; the orchestrator file is the playbook. If the two disagree, the orchestrator file wins.

## Output

After convergence (or max passes):
1. Summary of all passes with finding counts
2. Novelty classification for each pass
3. Final quality score with dimension breakdown
4. Resolved vs unresolved findings
5. Sign-off recommendation: APPROVED, APPROVED WITH CONDITIONS, or REWORK REQUIRED

## References

- `${CLAUDE_PLUGIN_ROOT}/data/review-best-practices.md`
- `${CLAUDE_PLUGIN_ROOT}/data/cognitive-bias-patterns.md`
- All checklists in `${CLAUDE_PLUGIN_ROOT}/checklists/`

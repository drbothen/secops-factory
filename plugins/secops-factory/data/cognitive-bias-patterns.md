# Cognitive Bias Patterns in Security Analysis

## Introduction

Cognitive biases are systematic errors in thinking that affect judgments and decisions. In security analysis, biases can lead to:
- Incorrect priority assessments
- Missed critical vulnerabilities
- Over-reaction to low-risk issues
- Inconsistent analysis quality

This guide helps security analysts and reviewers recognize and mitigate common biases.

---

## 1. Confirmation Bias

### Definition
Seeking, interpreting, and remembering information that confirms pre-existing beliefs while dismissing contradicting evidence.

### Security Analysis Examples

**Example 1: CVSS-Only Assessment**

Biased: "The CVSS score is 9.8 (Critical), so this is definitely high priority. I found articles about similar vulnerabilities being exploited, so this confirms it's critical."
- Ignores: EPSS 0.05 (very low exploitation probability)
- Ignores: KEV Not Listed (no active exploitation)
- Ignores: No public exploits available

Objective: "CVSS is 9.8 (Critical severity), but EPSS is 0.05 (very low exploitation probability), KEV Not Listed, and no public exploits found. While severity is high, exploitability is low. Priority: P3 (Medium) with monitoring for exploit developments."

**Example 2: Cherry-Picking Sources**

Biased: "I found 3 security blogs saying this is critical, so it must be."
- Ignores: Official NVD assessment rates it Medium
- Ignores: Vendor advisory says low risk

Objective: "Security blogs rate this as critical, but official NVD and vendor advisory rate it Medium/Low. Prioritize authoritative sources (NVD, vendor) over secondary sources (blogs)."

### Detection Signals
- Only citing sources that confirm initial assessment
- Dismissing contradictory evidence without explanation
- Reaching conclusion before examining all data
- Overweighting anecdotal evidence

### Debiasing Techniques
- Actively seek disconfirming evidence
- Document evidence both for AND against assessment
- Use pre-defined scoring frameworks (multi-factor priority)
- Require minimum source diversity

---

## 2. Availability Bias

### Definition
Overweighting information that comes to mind easily (often recent or dramatic events) while underweighting base rates.

### Security Analysis Examples

**Example: Recent Incident Influence**

Biased: "We had a ransomware attack last month via an RCE vulnerability. This new RCE vulnerability must be critical too."
- Ignores: New CVE has EPSS 0.02 (very low exploitation probability)
- Ignores: New CVE affects isolated test environment

Objective: "While recent incidents involved RCE vulnerabilities, each CVE must be assessed independently. This CVE: EPSS 0.02 (low probability), isolated system, Low ACR. Priority: P4."

### Detection Signals
- Referencing recent incidents without statistical justification
- Overweighting dramatic or newsworthy vulnerabilities
- Applying lessons from one incident broadly without evidence
- Difficulty distinguishing high-profile from high-risk

### Debiasing Techniques
- Check base rates and historical data
- Use quantitative metrics (EPSS) rather than gut feeling
- Review incident statistics over 90+ day periods
- Compare to similar vulnerabilities, not just memorable ones

---

## 3. Anchoring Bias

### Definition
Relying too heavily on the first piece of information encountered (the "anchor") when making decisions.

### Security Analysis Examples

**Example: Vendor-Assigned Severity**

Biased: "The vendor rated this as Critical, so I'll assign P1."
- Ignores: NVD rates it High (not Critical)
- Ignores: EPSS is 0.10 (low exploitation probability)

Objective: "Vendor rates Critical, NVD rates High (CVSS 7.5). Independently verify: EPSS 0.10, KEV Not Listed, Internal system, Medium ACR. Multi-factor score: 11/24 = P3."

### Detection Signals
- First metric encountered dominates assessment
- Not adjusting from initial assessment when new data emerges
- Vendor or alert severity accepted without independent verification
- Difficulty changing initial classification

### Debiasing Techniques
- Derive priority from raw data using scoring framework
- Verify all sources independently
- Complete full multi-factor assessment before assigning priority
- Review assessment after all data collected, not during collection

---

## 4. Overconfidence Bias

### Definition
Excessive confidence in one's own answers, often making claims without sufficient evidence.

### Security Analysis Examples

**Example: Definitive Claims Without Evidence**

Biased: "This vulnerability is definitely not exploitable in our environment."
- No evidence of environmental assessment
- No compensating controls documented
- No attack surface analysis performed

Objective: "Based on available evidence: the system is internally hosted with no internet exposure, ACR is Low (development environment), and no public exploits exist. However, internal lateral movement remains possible. Confidence: Medium. Recommend monitoring."

### Detection Signals
- Definitive language without supporting evidence ("definitely", "impossible", "certainly")
- High confidence ratings without corresponding evidence depth
- Dismissing possibilities without investigation
- Not acknowledging uncertainty or limitations

### Debiasing Techniques
- Require evidence for every claim
- Use confidence levels (High/Medium/Low) with justification
- Acknowledge uncertainty and limitations explicitly
- Document what was NOT checked as well as what was

---

## 5. Recency Bias

### Definition
Giving more weight to recent events while underweighting historical patterns.

### Security Analysis Examples

**Example: Ignoring Historical Patterns**

Biased: "This alert just appeared today, it's new and must be investigated urgently."
- Ignores: Same alert pattern occurred 15 times in last 90 days
- Ignores: All previous occurrences were false positives
- Ignores: Alert triggered by known maintenance window

Objective: "Alert triggered at 14:32 UTC. Historical analysis: 15 similar alerts in 90 days, all resolved as FP (maintenance-related). Current occurrence aligns with scheduled maintenance window (14:00-16:00 UTC). Disposition: Benign True Positive. Recommend alert tuning."

### Detection Signals
- Only considering recent events (last 24-48 hours)
- Not checking 30/60/90-day historical patterns
- Treating recurring events as novel each time
- Ignoring seasonal or cyclical patterns

### Debiasing Techniques
- Always check historical context (30/60/90 days)
- Compare to baseline behavior patterns
- Document trend analysis in investigations
- Use statistical analysis for recurring alerts

---

## 6. Automation Bias (Event Investigation Specific)

### Definition
Over-relying on automated system outputs (alert severity, platform classification, automated disposition) without independent verification.

### Security Analysis Examples

**Example: Accepting Platform Classification**

Biased: "Claroty classified this as High severity, so it must be High."
- No independent verification of severity
- No context assessment performed
- Platform-assigned severity accepted as ground truth

Objective: "Claroty classified as High severity. Independent assessment: protocol traffic is expected between these systems during maintenance windows. Cross-referencing with change management: scheduled PLC firmware update in progress. Re-classification: Benign True Positive."

### Detection Signals
- Alert platform severity accepted without question
- Automated disposition not independently verified
- No context beyond what the alert platform provided
- Conclusions match platform output exactly without additional analysis

### Debiasing Techniques
- Always independently assess severity
- Cross-reference with multiple data sources
- Check operational context (maintenance, changes, testing)
- Document independent reasoning separate from platform output

---

## Applying Bias Detection in Reviews

### Review Checklist

For each analysis reviewed, check:

1. **Confirmation Bias:** Does the analysis consider contradictory evidence?
2. **Availability Bias:** Are recent incidents over-influencing the assessment?
3. **Anchoring Bias:** Was the first metric encountered independently verified?
4. **Overconfidence Bias:** Are claims supported by evidence with appropriate confidence levels?
5. **Recency Bias:** Was historical context (30/60/90 days) consulted?
6. **Automation Bias:** Were platform-assigned values independently verified?

### Reviewer Language

When identifying bias, use constructive language:
- "An opportunity to strengthen objectivity would be to examine evidence that challenges the initial assessment..."
- "Consider including historical context (30/60/90 day patterns) to supplement the recency focus..."
- "Adding independent verification of the platform-assigned severity would enhance confidence..."

---

## References

- Kahneman, D. (2011). Thinking, Fast and Slow
- Tversky, A., & Kahneman, D. (1974). Judgment under Uncertainty: Heuristics and Biases
- NIST SP 800-61 Rev. 2 -- Computer Security Incident Handling Guide
- SANS Institute -- Cognitive Bias in Incident Response

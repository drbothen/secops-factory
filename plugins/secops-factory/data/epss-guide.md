# EPSS (Exploit Prediction Scoring System) Guide

## Table of Contents

1. [Introduction to EPSS](#introduction-to-epss)
2. [EPSS Scoring System](#epss-scoring-system)
3. [Interpreting EPSS Scores](#interpreting-epss-scores)
4. [EPSS API Usage](#epss-api-usage)
5. [Integration with CVSS](#integration-with-cvss)
6. [EPSS Examples](#epss-examples)
7. [Limitations and Considerations](#limitations-and-considerations)
8. [Authoritative References](#authoritative-references)

---

## Introduction to EPSS

### What EPSS Measures

**EPSS (Exploit Prediction Scoring System) estimates the probability that a software vulnerability will be exploited in the wild within the next 30 days.**

EPSS is a data-driven, machine learning-based system developed by FIRST (Forum of Incident Response and Security Teams) to help organizations prioritize vulnerability remediation based on **likelihood of exploitation**, not just severity.

### The Fundamental Question

**EPSS answers:** "What is the probability this vulnerability will be exploited in the next 30 days?"

This complements CVSS, which answers: "How severe is the impact if this vulnerability is exploited?"

### Why EPSS Exists

Organizations face a fundamental challenge:
- Thousands of CVEs published annually, but limited remediation resources
- Only ~7% of published CVEs are ever exploited in real-world attacks
- Prioritizing by CVSS severity alone is inefficient
- EPSS uses real-world threat intelligence and machine learning to predict exploitation likelihood

### How EPSS Differs from CVSS

| Dimension | CVSS | EPSS |
|-----------|------|------|
| **Question** | How severe IF exploited? | How likely TO BE exploited? |
| **Measure** | Impact severity (0.0-10.0) | Exploitation probability (0-1) |
| **Method** | Expert assessment of characteristics | Machine learning on threat data |
| **Updates** | Static (per version) | Daily (real-time threat data) |
| **Best for** | Understanding impact | Prioritizing remediation |

---

## EPSS Scoring System

### Score Range

- **Minimum:** 0.0 (0% probability of exploitation)
- **Maximum:** 1.0 (100% probability of exploitation)
- **Typical range:** Most CVEs score below 0.1 (10%)

### Percentile Ranking

EPSS also provides a percentile ranking (0-100) showing where a vulnerability falls relative to all scored CVEs:
- 95th percentile: Higher exploitation probability than 95% of all CVEs
- 50th percentile: Median exploitation probability
- 5th percentile: Lower exploitation probability than 95% of all CVEs

### Score Interpretation Tiers

| EPSS Score | Tier | Interpretation | Action |
|------------|------|----------------|--------|
| >= 0.75 | Very High | >= 75% exploitation probability in 30 days | Emergency priority |
| 0.50 - 0.74 | High | 50-74% probability | Urgent remediation |
| 0.25 - 0.49 | Moderate | 25-49% probability | Planned remediation |
| 0.10 - 0.24 | Low | 10-24% probability | Standard patching |
| < 0.10 | Very Low | <10% probability | Routine/monitor |

### Priority Framework Integration

EPSS scoring for the multi-factor priority calculation:

```
if epss_score >= 0.75: epss_points = 4  (Very High)
if epss_score >= 0.50: epss_points = 3  (High)
if epss_score >= 0.25: epss_points = 2  (Moderate)
else:                   epss_points = 1  (Low)
```

---

## EPSS API Usage

### REST API

**Base URL:** `https://api.first.org/data/v1/epss`

**Query by CVE:**
```
GET https://api.first.org/data/v1/epss?cve=CVE-2024-1234
```

**Response format:**
```json
{
  "status": "OK",
  "data": [{
    "cve": "CVE-2024-1234",
    "epss": "0.85432",
    "percentile": "0.97123",
    "date": "2024-11-08"
  }]
}
```

### Using with Perplexity

When Perplexity research returns EPSS data, validate:
1. Score is between 0.0 and 1.0
2. Percentile is between 0 and 100
3. Date is recent (EPSS updates daily)
4. Cross-reference with API if critical decision

---

## Integration with CVSS

### The CVSS-EPSS Matrix

| | EPSS High (>= 0.5) | EPSS Low (< 0.5) |
|---|---|---|
| **CVSS High (>= 7.0)** | P1/P2 -- Severe AND likely | P2/P3 -- Severe but unlikely |
| **CVSS Low (< 7.0)** | P2/P3 -- Moderate but likely | P4/P5 -- Low severity and unlikely |

**Key insight:** CVSS High + EPSS Low does not automatically mean P1. Many critical-severity CVEs have very low exploitation probability.

---

## Limitations and Considerations

1. **30-day window:** EPSS predicts exploitation within 30 days. It does not predict long-term risk.
2. **Zero-day gap:** Brand-new CVEs may lack sufficient data for accurate scoring.
3. **Daily fluctuation:** Scores change daily as threat landscape evolves.
4. **Not a substitute for CVSS:** EPSS measures likelihood, not severity. Both are needed.
5. **Aggregate prediction:** Works best across a portfolio, not as sole factor for individual CVEs.

---

## Authoritative References

- [FIRST EPSS](https://www.first.org/epss/) -- Official EPSS page
- [EPSS API](https://api.first.org/data/v1/epss) -- REST API documentation
- [EPSS Model Information](https://www.first.org/epss/model) -- Model methodology
- [EPSS Research Paper](https://arxiv.org/abs/2302.14172) -- Academic foundation

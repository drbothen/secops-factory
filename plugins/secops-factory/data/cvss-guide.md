# CVSS (Common Vulnerability Scoring System) Guide

## Table of Contents

1. [Introduction to CVSS](#introduction-to-cvss)
2. [CVSS v3.1 Scoring](#cvss-v31-scoring)
3. [CVSS v4.0 Differences](#cvss-v40-differences)
4. [Severity Ratings](#severity-ratings)
5. [Common Scoring Pitfalls](#common-scoring-pitfalls)
6. [CVSS Calculation Examples](#cvss-calculation-examples)
7. [Integration with Risk Prioritization](#integration-with-risk-prioritization)
8. [Authoritative References](#authoritative-references)

---

## Introduction to CVSS

### What CVSS Measures

**CVSS measures vulnerability severity, NOT risk.**

CVSS provides a standardized method to capture the principal characteristics of a vulnerability and produce a numerical score (0.0-10.0) reflecting its severity. The score translates to a qualitative representation (None, Low, Medium, High, Critical) to help organizations properly assess and prioritize vulnerability remediation.

**Critical Distinction:**
- **Severity** (CVSS): How bad is the vulnerability **IF** exploited?
- **Risk**: What is the **likelihood** of exploitation combined with business impact?
- **Exploitability** (EPSS): What is the **probability** of exploitation in the wild?

CVSS should always be combined with other factors (EPSS, KEV status, business context) for effective risk prioritization.

### CVSS Versions

#### CVSS v3.1 (Current Standard)

**Status:** Widely adopted industry standard (2019-present)

**When to Use:**
- Default choice for most vulnerability assessments
- Maximum compatibility with existing tools and databases
- NVD (National Vulnerability Database) uses CVSS v3.1 as primary scoring
- Most CVE records include CVSS v3.1 scores

**Characteristics:**
- Formula-based scoring calculation
- 8 base metrics, 3 temporal metrics, 5 environmental metrics
- Well-understood and extensively documented
- Broad tool support and integration

#### CVSS v4.0 (Next Generation)

**Status:** Released November 2023, adoption growing

**When to Use:**
- When v4.0 scores available from NVD or vendor
- For new vulnerability assessments where v4.0 tooling is available
- When supplemental metrics (Automatable, Recovery) add decision value

**Key Changes from v3.1:**
- Renamed "Temporal" to "Threat" metrics
- Added supplemental metric group (Safety, Automatable, Recovery, Value Density, Vulnerability Response Effort, Provider Urgency)
- Finer granularity in attack complexity
- Better handling of vulnerabilities requiring user interaction

---

## CVSS v3.1 Scoring

### Base Score Metrics (8 metrics)

The Base Score reflects the intrinsic qualities of a vulnerability that are constant over time and across user environments.

#### Attack Vector (AV)

How the vulnerability is exploited:

| Value | Label | Description | Example |
|-------|-------|-------------|---------|
| N | Network | Remotely exploitable | Web application RCE |
| A | Adjacent | Requires adjacent network | Bluetooth, WiFi attacks |
| L | Local | Requires local access | Privilege escalation |
| P | Physical | Requires physical access | USB-based attacks |

**Scoring Impact:** Network > Adjacent > Local > Physical

#### Attack Complexity (AC)

Conditions beyond attacker's control:

| Value | Label | Description | Example |
|-------|-------|-------------|---------|
| L | Low | No specialized conditions | Standard exploit |
| H | High | Requires specific conditions | Race condition, config dependency |

#### Privileges Required (PR)

Level of privileges needed:

| Value | Label | Description | Example |
|-------|-------|-------------|---------|
| N | None | No authentication needed | Unauthenticated RCE |
| L | Low | Basic user access | Authenticated user exploit |
| H | High | Admin/root access | Admin-only vulnerability |

#### User Interaction (UI)

Whether user action is needed:

| Value | Label | Description | Example |
|-------|-------|-------------|---------|
| N | None | No user interaction | Wormable vulnerability |
| R | Required | User must take action | Click a link, open a file |

#### Scope (S)

Whether the vulnerability affects resources beyond its security scope:

| Value | Label | Description | Example |
|-------|-------|-------------|---------|
| U | Unchanged | Stays within component | Local DoS |
| C | Changed | Impacts other components | VM escape, sandbox escape |

#### Confidentiality Impact (C)

| Value | Label | Description |
|-------|-------|-------------|
| N | None | No confidentiality impact |
| L | Low | Limited data exposure |
| H | High | Total information disclosure |

#### Integrity Impact (I)

| Value | Label | Description |
|-------|-------|-------------|
| N | None | No integrity impact |
| L | Low | Limited data modification |
| H | High | Total system compromise |

#### Availability Impact (A)

| Value | Label | Description |
|-------|-------|-------------|
| N | None | No availability impact |
| L | Low | Reduced performance |
| H | High | Complete denial of service |

### Vector String Format

```
CVSS:3.1/AV:{N|A|L|P}/AC:{L|H}/PR:{N|L|H}/UI:{N|R}/S:{U|C}/C:{N|L|H}/I:{N|L|H}/A:{N|L|H}
```

**Example:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` = 9.8 (Critical)

---

## Severity Ratings

| Score Range | Severity | Color | Action Urgency |
|-------------|----------|-------|----------------|
| 0.0 | None | Gray | No action |
| 0.1 - 3.9 | Low | Green | Routine patching |
| 4.0 - 6.9 | Medium | Yellow | Planned maintenance |
| 7.0 - 8.9 | High | Orange | Urgent patching |
| 9.0 - 10.0 | Critical | Red | Emergency response |

---

## Common Scoring Pitfalls

### Pitfall 1: CVSS = Risk

**Wrong:** "CVSS 9.8 means this is our highest risk"
**Right:** "CVSS 9.8 means severity is critical IF exploited. Risk also requires EPSS (exploitation likelihood), KEV (active exploitation), and business context."

### Pitfall 2: Ignoring Temporal/Threat Metrics

Base scores do not account for exploit maturity or patch availability. A CVSS 9.8 with no known exploit and available patch is lower risk than a CVSS 7.5 with active exploitation and no patch.

### Pitfall 3: Version Confusion

Always note whether the score is CVSS v3.1 or v4.0. Scores are not directly comparable between versions.

### Pitfall 4: Scope Misunderstanding

"Changed" scope (S:C) significantly increases the score. Misclassifying scope leads to under/over-scoring.

---

## Integration with Risk Prioritization

CVSS is one factor in the multi-factor priority framework:

| Factor | Source | Weight |
|--------|--------|--------|
| CVSS Severity | NVD | 0-4 points |
| EPSS Probability | FIRST | 0-4 points |
| CISA KEV Status | CISA | 0-5 points (override) |
| Asset Criticality | Internal | 0-4 points |
| System Exposure | Internal | 0-3 points |
| Exploit Availability | Multiple | 0-4 points |

**Total:** 0-24 points, mapped to P1-P5

Reference: `${CLAUDE_PLUGIN_ROOT}/data/priority-framework.md`

---

## Authoritative References

- [NIST NVD](https://nvd.nist.gov/) -- National Vulnerability Database
- [FIRST CVSS v3.1 Specification](https://www.first.org/cvss/v3.1/specification-document)
- [FIRST CVSS v4.0 Specification](https://www.first.org/cvss/v4.0/specification-document)
- [FIRST CVSS Calculator](https://www.first.org/cvss/calculator/3.1)

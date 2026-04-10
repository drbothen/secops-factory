---
name: assess-priority
description: "Use when calculating multi-factor vulnerability priority. Combines CVSS severity, EPSS exploitation probability, CISA KEV status, asset criticality, system exposure, and exploit availability into P1-P5 with SLA."
argument-hint: "<ticket-id>"
---

# Assess Vulnerability Priority

Calculate vulnerability remediation priority using 6-factor risk assessment.

## The Iron Law

> **NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST**

Never assign priority from a single metric. A CVSS 9.8 with EPSS 0.02 and no exploits on an isolated test system is NOT P1. Run all 6 factors before determining priority.

## Announce at Start

Before any other action, say verbatim:

> I am using the assess-priority skill to calculate multi-factor priority for <ticket-id>.

## Red Flags

| Thought | Reality |
|---|---|
| "CVSS 9.8 = P1, done" | CVSS alone is severity, not risk. Check EPSS, KEV, exposure, ACR, exploit status. |
| "No KEV listing means it's not urgent" | KEV absence does not mean safe. Check EPSS and exploit availability. |
| "I'll skip ACR, I don't know the asset criticality" | Prompt the user or use conservative default (Medium). Never skip. |
| "EPSS data isn't available, I'll just use CVSS" | Flag as INCOMPLETE DATA. Default EPSS to 0.0 with warning. |
| "The vendor says High priority" | Vendor assessment is input, not output. Run your own scoring. |
| "Compensating controls mean I can lower priority" | Only reduce if controls are documented AND tested. Not assumed. |

## Input Requirements

**Vulnerability data (required):**
- `cvss_score` (0.0-10.0, default 0.0 if missing)
- `epss_score` (0.0-1.0, default 0.0 if missing)
- `kev_status` ("Listed" or "Not Listed", default "Not Listed")
- `exploit_status` ("Active Exploitation", "Public Exploit", "PoC", or "Theoretical")

**System data (required):**
- `acr_rating` ("Critical", "High", "Medium", or "Low")
- `exposure` ("Internet", "Internal", or "Isolated")

## Scoring Algorithm

### 6-Factor Calculation

| Factor | Range | Scoring |
|--------|-------|---------|
| CVSS Severity | 0-4 pts | >=9.0=4, >=7.0=3, >=4.0=2, <4.0=1 |
| EPSS Probability | 0-4 pts | >=0.75=4, >=0.50=3, >=0.25=2, <0.25=1 |
| CISA KEV Status | 0-5 pts | Listed=5, Not Listed=0 |
| Asset Criticality | 0-4 pts | Critical=4, High=3, Medium=2, Low=1 |
| System Exposure | 0-3 pts | Internet=3, Internal=2, Isolated=1 |
| Exploit Availability | 0-4 pts | Active=4, Public=3, PoC=2, Theoretical=1 |

**Total:** 0-24 points

### Priority Mapping

| Score | Priority | SLA |
|-------|----------|-----|
| >=20 or KEV Listed | P1 - Critical | 24 hours |
| 15-19 | P2 - High | 7 days |
| 10-14 | P3 - Medium | 30 days |
| 6-9 | P4 - Low | 90 days |
| 0-5 | P5 - Informational | No SLA |

### Override Rules

- KEV Listed + Internet + Critical ACR = automatic P1
- Active Exploitation + CVSS >=9.0 + High/Critical ACR = automatic P1
- Compliance requirement = elevate +1 level
- Documented compensating controls = reduce -1 level

## Output

Present factor breakdown, total score, priority level, SLA deadline, and rationale.

## References

- `${CLAUDE_PLUGIN_ROOT}/data/priority-framework.md`
- `${CLAUDE_PLUGIN_ROOT}/data/cvss-guide.md`
- `${CLAUDE_PLUGIN_ROOT}/data/epss-guide.md`
- `${CLAUDE_PLUGIN_ROOT}/data/kev-catalog-guide.md`

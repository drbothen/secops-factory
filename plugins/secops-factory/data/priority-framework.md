# Security Operations Priority Framework

## Introduction

This framework uses **multi-factor risk assessment** to prioritize vulnerabilities based on genuine exploitable threat, not severity alone. This approach reduces alert fatigue by focusing remediation efforts on vulnerabilities that pose real risk.

**Core Principle:** CVSS + EPSS + KEV + Business Context = Accurate Priority

---

## Priority Levels (P1-P5)

> **Note:** P1-P5 are INTERNAL-ONLY intermediate scoring labels used within this framework. The emitted `scored_priority` output is always a member of the enum `{CRIT, HIGH, MED, LOW}` — P1-P5 are never emitted as `scored_priority` (BC-4.05.001 v1.6 Invariant #5).

### P1 - Critical (24 Hour SLA)

**Definition:** Immediate action required. Critical vulnerabilities with high exploitability affecting critical systems.

**Criteria (ANY of the following):**

1. CVSS >= 9.0 + EPSS >= 0.75 + KEV Listed
2. Active Exploitation + Internet-Facing + Critical ACR
3. KEV Listed + Internet-Facing + Critical ACR

**Actions:** Emergency change process, war room, executive notification, monitor for active exploitation

### P2 - High (7 Day SLA)

**Definition:** Urgent remediation required. High severity with significant exploitation risk.

**Score Threshold:** 14-19 points (note: KEV Listed → CRIT unconditional per Override Rule; see Score to Priority Mapping)

**Actions:** Urgent patching in next sprint, security team notification, staging validation

### P3 - Medium (30 Day SLA)

**Definition:** Planned remediation. Moderate severity with limited exploitation risk.

**Score Threshold:** 8-13 points (P3 → MED band; scored_priority emitted as MED, 30-day SLA)

**Actions:** Next maintenance window, non-production testing, change request scheduling

### P4 - Medium (30 Day SLA)

**Definition:** Routine patching. Low-criticality systems with moderate risk profile.

**Score Threshold:** 8-13 points (P4 → MED band; scored_priority emitted as MED, 30-day SLA)

**Actions:** Routine patch schedule, batch with other medium-priority patches

### P5 - Low (90 Day SLA)

**Definition:** Awareness only. Minimal risk.

**Score Threshold:** <8 points (P5 → LOW band; scored_priority emitted as LOW, 90-day SLA)

**Actions:** Document for awareness, optional patching, risk acceptance consideration

---

## Multi-Factor Scoring Algorithm

### Factor 1: CVSS Severity (0-4 points)

| CVSS Score | Points | Severity |
|------------|--------|----------|
| >= 9.0 | 4 | Critical |
| >= 7.0 | 3 | High |
| >= 4.0 | 2 | Medium |
| < 4.0 | 1 | Low |

### Factor 2: EPSS Probability (0-4 points)

| EPSS Score | Points | Tier |
|------------|--------|------|
| >= 0.75 | 4 | Very High |
| >= 0.50 | 3 | High |
| >= 0.25 | 2 | Moderate |
| < 0.25 | 1 | Low |

### Factor 3: CISA KEV Status (0-5 points, OVERRIDE)

| Status | Points | Effect |
|--------|--------|--------|
| Listed | 5 | Automatic priority elevation |
| Not Listed | 0 | No bonus |

**Override Rule:** KEV Listed = CRIT unconditional (24-hour SLA regardless of other factors; overrides base-score band).

### Factor 4: Asset Criticality Rating (0-4 points)

| Rating | Points | Description |
|--------|--------|-------------|
| Critical | 4 | Mission-critical production systems |
| High | 3 | Important business systems |
| Medium | 2 | Standard systems |
| Low | 1 | Dev/test systems |

### Factor 5: System Exposure (0-3 points)

| Exposure | Points | Description |
|----------|--------|-------------|
| Internet | 3 | Public-facing |
| Internal | 2 | Corporate network only |
| Isolated | 1 | Air-gapped/restricted |

### Factor 6: Exploit Availability (0-4 points)

| Status | Points | Description |
|--------|--------|-------------|
| Active Exploitation | 4 | Confirmed in-the-wild |
| Public Exploit | 3 | Exploit code publicly available |
| PoC | 2 | Proof-of-concept exists |
| Theoretical | 1 | No known exploit |

### Total Score Calculation

```
total_score = cvss_points + epss_points + kev_points + acr_points + exposure_points + exploit_points
```

**Score Range:** 0-24 points

### Score to Priority Mapping

| Score | scored_priority (emitted enum) | SLA |
|-------|-------------------------------|-----|
| >= 20 or KEV | CRIT | 24 hours |
| 14-19 | HIGH | 7 days |
| 8-13 | MED | 30 days |
| <8 | LOW | 90 days |

---

## Priority Modifiers

### Automatic P1 Override

- KEV Listed + Internet-Facing + Critical ACR
- Active Exploitation + CVSS >= 9.0 + High/Critical ACR

### Priority Elevation (+1 level)

- Compliance requirement (PCI-DSS, HIPAA, SOX, NERC CIP)
- Previous security incident with similar vulnerability
- Customer-facing system with data breach potential

### Priority Reduction (-1 level)

- Effective compensating controls (documented and tested)
- System scheduled for decommission within 30 days
- Vendor end-of-life with documented mitigation plan

---

## References

- [CISA BOD 22-01](https://www.cisa.gov/news-events/directives/bod-22-01) -- Vulnerability management directive
- [NIST SP 800-30](https://csrc.nist.gov/publications/detail/sp/800-30/rev-1/final) -- Risk assessment guide
- [FIRST CVSS](https://www.first.org/cvss/) -- Vulnerability scoring
- [FIRST EPSS](https://www.first.org/epss/) -- Exploitation prediction

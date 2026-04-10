# Security Operations Priority Framework

## Introduction

This framework uses **multi-factor risk assessment** to prioritize vulnerabilities based on genuine exploitable threat, not severity alone. This approach reduces alert fatigue by focusing remediation efforts on vulnerabilities that pose real risk.

**Core Principle:** CVSS + EPSS + KEV + Business Context = Accurate Priority

---

## Priority Levels (P1-P5)

### P1 - Critical (24 Hour SLA)

**Definition:** Immediate action required. Critical vulnerabilities with high exploitability affecting critical systems.

**Criteria (ANY of the following):**

1. CVSS >= 9.0 + EPSS >= 0.75 + KEV Listed
2. Active Exploitation + Internet-Facing + Critical ACR
3. KEV Listed + Internet-Facing + Critical ACR

**Actions:** Emergency change process, war room, executive notification, monitor for active exploitation

### P2 - High (7 Day SLA)

**Definition:** Urgent remediation required. High severity with significant exploitation risk.

**Score Threshold:** 15-19 points (or KEV Listed without P1 criteria)

**Actions:** Urgent patching in next sprint, security team notification, staging validation

### P3 - Medium (30 Day SLA)

**Definition:** Planned remediation. Moderate severity with limited exploitation risk.

**Score Threshold:** 10-14 points

**Actions:** Next maintenance window, non-production testing, change request scheduling

### P4 - Low (90 Day SLA)

**Definition:** Routine patching. Low severity or low-criticality systems.

**Score Threshold:** 6-9 points

**Actions:** Routine patch schedule, batch with other low-priority patches

### P5 - Informational (No SLA)

**Definition:** Awareness only. Minimal risk.

**Score Threshold:** 0-5 points

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

**Override Rule:** KEV Listed = minimum P2 regardless of other factors.

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

**Score Range:** 6-24 points

### Score to Priority Mapping

| Score | Priority | SLA |
|-------|----------|-----|
| >= 20 or KEV | P1 | 24 hours |
| 15-19 | P2 | 7 days |
| 10-14 | P3 | 30 days |
| 6-9 | P4 | 90 days |
| 0-5 | P5 | No SLA |

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

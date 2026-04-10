# CISA KEV (Known Exploited Vulnerabilities) Catalog Guide

## Table of Contents

1. [Introduction to KEV Catalog](#introduction-to-kev-catalog)
2. [Why KEV Matters](#why-kev-matters)
3. [Checking KEV Catalog](#checking-kev-catalog)
4. [KEV Catalog Fields](#kev-catalog-fields)
5. [Prioritization Implications](#prioritization-implications)
6. [KEV Examples](#kev-examples)
7. [Integration with Risk Prioritization](#integration-with-risk-prioritization)
8. [BOD 22-01 Requirements](#bod-22-01-requirements)
9. [Authoritative References](#authoritative-references)

---

## Introduction to KEV Catalog

### What is the KEV Catalog?

**CISA's Known Exploited Vulnerabilities (KEV) Catalog is the authoritative U.S. government list of CVEs with confirmed active exploitation in the wild.**

**Maintained by:** Cybersecurity and Infrastructure Security Agency (CISA), U.S. Department of Homeland Security

**Purpose:** Provide network defenders with a curated, authoritative list of vulnerabilities that pose the highest risk due to **confirmed** exploitation, enabling evidence-based vulnerability prioritization.

**Key Distinction:** KEV lists vulnerabilities with **confirmed active exploitation**, not theoretical or predicted exploitability.

### The Fundamental Difference

| Metric | Type | Basis |
|--------|------|-------|
| **CVSS** | Severity assessment | Vulnerability characteristics (impact if exploited) |
| **EPSS** | Exploitability prediction | Machine learning probability (0-100%) |
| **KEV** | **Confirmed exploitation** | **Ground truth** (CISA-verified active exploitation) |

### KEV Catalog Criteria

For a vulnerability to be added, it must meet **three criteria:**

1. **Assigned CVE ID**: Must have a CVE identifier
2. **Reliable evidence of active exploitation**: CISA confirms through incident response telemetry, threat intelligence, honeypot data, vendor reports
3. **Clear remediation guidance**: Vendor patch or mitigation available

---

## Why KEV Matters

### Ground Truth vs Prediction

- CVSS tells you severity IF exploited (theoretical)
- EPSS tells you probability of exploitation (predicted)
- **KEV tells you it IS being exploited (confirmed)**

### Priority Override

KEV-listed vulnerabilities receive automatic priority elevation in the multi-factor framework:
- KEV Listed = 5 points (maximum single factor score)
- Minimum P1 or P2 regardless of other factor scores
- Per CISA BOD 22-01: federal agencies must remediate within mandated timelines

---

## Checking KEV Catalog

### Official Sources

1. **Web interface:** https://www.cisa.gov/known-exploited-vulnerabilities-catalog
2. **JSON feed:** https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
3. **CSV download:** Available from CISA website

### Verification Process

1. Search by CVE ID in the KEV catalog
2. Record: Listed or Not Listed
3. If Listed: capture date_added and due_date
4. If Not Listed: document as "Not Listed" (not "Not in KEV")

---

## KEV Catalog Fields

| Field | Description | Example |
|-------|-------------|---------|
| cveID | CVE identifier | CVE-2024-1234 |
| vendorProject | Affected vendor | Apache |
| product | Affected product | Struts 2 |
| vulnerabilityName | Description | Apache Struts 2 RCE |
| dateAdded | Date added to KEV | 2024-01-15 |
| shortDescription | Brief description | Remote code execution |
| requiredAction | Mandated remediation | Apply updates per vendor |
| dueDate | Remediation deadline | 2024-02-05 |
| knownRansomwareCampaignUse | Ransomware association | Known |

---

## Prioritization Implications

### KEV Override Rules

```
IF kev_status == "Listed":
    kev_points = 5  (automatic high priority)
    minimum_priority = P2  (cannot go below P2)

IF kev_status == "Listed" AND exposure == "Internet" AND acr == "Critical":
    priority = P1  (automatic P1 override)
```

### SLA Impact

| KEV Status | Standard SLA | With KEV Override |
|------------|-------------|-------------------|
| Not Listed | Per multi-factor score | Normal SLA |
| Listed | BOD 22-01 deadline | 14-21 days (federal) |
| Listed + Ransomware | Emergency | 48-72 hours |

---

## BOD 22-01 Requirements

**Binding Operational Directive 22-01** (November 2021):

- Applies to all U.S. federal civilian executive branch agencies
- Requires remediation of KEV-listed vulnerabilities within mandated timelines
- Non-federal organizations strongly encouraged to adopt
- Industry best practice even without federal mandate

**Key requirements:**
1. Review and update internal vulnerability management procedures
2. Remediate each KEV vulnerability within the required timeframe
3. Report remediation status

---

## Authoritative References

- [CISA KEV Catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) -- Official catalog
- [BOD 22-01](https://www.cisa.gov/news-events/directives/bod-22-01) -- Binding operational directive
- [KEV JSON Feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) -- Machine-readable feed
- [CISA Vulnerability Management](https://www.cisa.gov/topics/cyber-threats-and-advisories/vulnerability-management) -- CISA guidance

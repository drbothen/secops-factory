# Event Investigation Best Practices

## Table of Contents

1. [Introduction](#1-introduction)
2. [NIST SP 800-61 Framework Integration](#2-nist-sp-800-61-framework-integration)
3. [Investigation Methodology](#3-investigation-methodology)
4. [Disposition Framework](#4-disposition-framework)
5. [Common False Positive Patterns](#5-common-false-positive-patterns)
6. [Cognitive Biases in Event Investigation](#6-cognitive-biases-in-event-investigation)
7. [ICS/SCADA-Specific Considerations](#7-icsscada-specific-considerations)
8. [Investigation Workflow Checklist](#8-investigation-workflow-checklist)
9. [References](#9-references)

---

## 1. Introduction

### Purpose

This knowledge base provides comprehensive guidance for security analysts and reviewers conducting event investigations in enterprise and industrial control system (ICS/SCADA) environments. It establishes standardized methodologies, disposition criteria, and best practices.

### Scope

- NIST SP 800-61 incident handling framework integration
- Hypothesis-driven investigation methodology
- Disposition framework (TP/FP/BTP)
- False positive pattern recognition
- Cognitive bias awareness for investigators
- ICS/SCADA-specific considerations

### Target Audience

- Security Analysts performing initial event triage and analysis
- Security Reviewers validating analyst findings and dispositions
- Incident Response Teams escalating from detection to response
- Security Operations Leadership establishing quality standards

---

## 2. NIST SP 800-61 Framework Integration

### Four-Phase Incident Handling Lifecycle

Event investigation maps to **Phase 2: Detection and Analysis** of the NIST SP 800-61 Rev 2 framework.

| Phase | Description | Event Investigation Role |
|-------|-------------|------------------------|
| 1. Preparation | Establish incident response capability | Define investigation procedures |
| 2. Detection & Analysis | Identify and analyze incidents | **Primary investigation phase** |
| 3. Containment, Eradication & Recovery | Limit damage, remove threat | Escalation target for TP |
| 4. Post-Incident Activity | Lessons learned, improvement | Feed back to detection tuning |

### Detection and Analysis Sub-Steps

1. **Alert triage:** Initial assessment of alert validity and urgency
2. **Evidence collection:** Gather relevant logs, artifacts, context
3. **Correlation:** Link related events across data sources
4. **Analysis:** Technical evaluation of evidence
5. **Disposition:** Classify as TP, FP, or BTP
6. **Documentation:** Record findings for audit trail
7. **Escalation/Closure:** Route to appropriate next step

---

## 3. Investigation Methodology

### Hypothesis-Driven Investigation

Every investigation should begin with a clear hypothesis that guides evidence collection:

1. **Form initial hypothesis** based on alert data
2. **Identify evidence** that would confirm or refute hypothesis
3. **Collect evidence** systematically from relevant sources
4. **Evaluate evidence** against hypothesis
5. **Revise hypothesis** if evidence contradicts
6. **Reach disposition** based on evidence weight

### Evidence Collection Hierarchy

| Priority | Source | Reliability |
|----------|--------|------------|
| 1 | System logs (firewall, endpoint, application) | High |
| 2 | Network traffic captures | High |
| 3 | SIEM correlation events | Medium-High |
| 4 | Threat intelligence feeds | Medium |
| 5 | Historical alert patterns | Medium |
| 6 | User/admin testimony | Low-Medium |

### Minimum Evidence Requirements

Before making a disposition:
- At least 2 independent data sources consulted
- Timeline reconstructed from event occurrence to detection
- Asset context obtained (owner, function, criticality)
- Historical context checked (30/60/90-day patterns)

---

## 4. Disposition Framework

### True Positive (TP)

**Definition:** Alert correctly identified genuine malicious, unauthorized, or policy-violating activity.

**Criteria:**
- Evidence confirms malicious intent or unauthorized action
- No legitimate business explanation found
- IOCs correlate with known threats
- Activity inconsistent with normal baseline

**Required actions:** Escalate to incident response, document evidence chain, initiate containment

### False Positive (FP)

**Definition:** Alert incorrectly flagged benign activity as malicious.

**Criteria:**
- Activity has legitimate business explanation
- No threat indicators present
- Detection rule over-broad or misconfigured
- Activity matches known benign pattern

**Required actions:** Document FP reason, recommend alert tuning, close ticket

### Benign True Positive (BTP)

**Definition:** Alert correctly detected real activity that is authorized/expected.

**Criteria:**
- Activity is real (not a detection error)
- Activity is authorized (maintenance, testing, approved scanning)
- Alert triggered correctly but activity is legitimate
- No security threat present

**Required actions:** Document authorized activity, consider alert tuning, update baseline

---

## 5. Common False Positive Patterns

### Network-Based FPs
- Scheduled vulnerability scans triggering IDS rules
- CDN/cloud service IP ranges flagged as suspicious
- Internal DNS resolution patterns misclassified
- Load balancer health checks triggering alerts

### Endpoint-Based FPs
- Legitimate admin tools (PsExec, PowerShell) flagged as malicious
- Software updates triggering file integrity alerts
- Antivirus signature updates misclassified
- Development/build tools flagged as suspicious

### ICS/OT-Specific FPs
- PLC firmware updates triggering protocol anomaly alerts
- Scheduled historian data collection flagged as data exfiltration
- Engineering workstation access during maintenance windows
- Protocol-compliant but unusual operational commands

---

## 6. Cognitive Biases in Event Investigation

See `${CLAUDE_PLUGIN_ROOT}/data/cognitive-bias-patterns.md` for comprehensive bias detection guidance.

Key biases for event investigation:
1. **Confirmation bias:** Seeking evidence supporting initial hypothesis only
2. **Anchoring bias:** Locked to alert severity without independent assessment
3. **Availability bias:** Over-weighting recent similar incidents
4. **Recency bias:** Not checking historical patterns
5. **Automation bias:** Accepting platform classification without verification

---

## 7. ICS/SCADA-Specific Considerations

### Purdue Model Zones

| Level | Zone | Description | Investigation Priority |
|-------|------|-------------|----------------------|
| 5 | Enterprise | Business network | Standard |
| 4 | DMZ | IT/OT boundary | High |
| 3.5 | DMZ | Industrial DMZ | High |
| 3 | Operations | Site operations | Critical |
| 2 | Control | Supervisory control (HMI, SCADA) | Critical |
| 1 | Basic Control | Direct control (PLC, RTU) | Critical |
| 0 | Process | Physical process | Critical |

### ICS Investigation Considerations

1. **Safety first:** Never take actions that could affect physical safety
2. **Availability priority:** OT prioritizes availability over confidentiality
3. **Protocol awareness:** Understand industrial protocols (Modbus, DNP3, OPC-UA)
4. **Change management:** Always check against maintenance schedules
5. **Vendor coordination:** Some ICS systems require vendor involvement
6. **Air-gap assumptions:** Verify actual network segmentation, not assumed

### ICS Platform Detection

| Platform | Indicators | Alert Types |
|----------|-----------|-------------|
| Claroty | Claroty xDome, CTD | Protocol anomaly, policy violation |
| Nozomi | Nozomi Guardian, Vantage | Asset anomaly, threat detection |
| Dragos | Dragos Platform | Threat detection, vulnerability |
| CyberX (Microsoft Defender IoT) | CyberX, Defender for IoT | Device anomaly, protocol violation |

---

## 8. Investigation Workflow Checklist

### Pre-Investigation
- [ ] Alert triage completed
- [ ] Alert type classified (ICS/IDS/SIEM)
- [ ] Initial hypothesis formed
- [ ] Evidence sources identified

### During Investigation
- [ ] Alert metadata captured (source, rule ID, severity, timestamps)
- [ ] Network identifiers documented (source/dest IP, protocol, port)
- [ ] Relevant logs collected and reviewed
- [ ] Correlation with related events performed
- [ ] Historical context checked (30/60/90 days)
- [ ] Technical analysis completed
- [ ] IOCs identified or absence documented

### Disposition
- [ ] Disposition determined (TP/FP/BTP)
- [ ] Confidence level assigned (High/Medium/Low)
- [ ] Reasoning documented with evidence chain
- [ ] Alternative dispositions considered and documented
- [ ] Escalation decision made and justified

### Post-Investigation
- [ ] Investigation document generated from template
- [ ] Local copy saved (chain of custody)
- [ ] JIRA ticket updated
- [ ] Tuning recommendations documented (if FP/BTP)

---

## 9. References

- [NIST SP 800-61 Rev. 2](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final) -- Computer Security Incident Handling Guide
- [NIST SP 800-82 Rev. 3](https://csrc.nist.gov/publications/detail/sp/800-82/rev-3/final) -- Guide to OT Security
- [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/) -- ICS-specific techniques
- [CISA ICS-CERT](https://www.cisa.gov/topics/industrial-control-systems) -- ICS security advisories
- [SANS ICS Security](https://www.sans.org/industrial-control-systems-security/) -- ICS security resources

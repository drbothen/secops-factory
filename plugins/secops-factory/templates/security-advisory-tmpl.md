# Security Advisory: [ADVISORY-ID]

| Field | Value |
|-------|-------|
| **Advisory ID** | [ORG]-SA-[YYYY]-[NNN] |
| **TLP** | TLP:CLEAR / TLP:GREEN / TLP:AMBER / TLP:AMBER+STRICT / TLP:RED |
| **Published** | [YYYY-MM-DD] |
| **Last Revised** | [YYYY-MM-DD] |
| **Advisory Type** | IT / ICS-OT / Combined |
| **CSAF Category** | csaf_security_advisory |

---

## 1. Executive Summary

[2-3 sentences. State what is vulnerable, how severe it is, whether it is being exploited, and what to do. This section is for management — they read this and stop.]

**Severity:** [Critical / High / Medium / Low]
**Exploit Status:** [Actively exploited / PoC available / No known exploit]
**Action Required:** [Patch immediately / Apply workaround / Monitor / Informational only]

---

## 2. Severity Assessment

| Metric | Value |
|--------|-------|
| **CVSS v3.1 Base Score** | [0.0-10.0] |
| **CVSS Vector** | [CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H] |
| **Vendor Severity** | [Critical / Important / Moderate / Low] |
| **EPSS Score** | [0.0-1.0] ([percentile]th percentile) |
| **CISA KEV** | [In catalog (date added) / Not in catalog] |
| **SSVC Decision** | [Act / Attend / Track* / Track] _(optional)_ |

---

## 3. Affected Products

| Product | Affected Versions | Fixed Version | Platform |
|---------|-------------------|---------------|----------|
| [Product Name] | [>= x.y.z, < a.b.c] | [a.b.c] | [OS/Platform] |

---

## 4. Vulnerability Details

| Field | Value |
|-------|-------|
| **CVE ID(s)** | [CVE-YYYY-NNNNN] |
| **CWE** | [CWE-NNN: Name] |
| **Attack Vector** | [Network / Adjacent / Local / Physical] |
| **Attack Complexity** | [Low / High] |
| **Privileges Required** | [None / Low / High] |
| **User Interaction** | [None / Required] |

**Description:**

[Technical description of the vulnerability. What is the root cause? What component is affected? How can an attacker trigger it?]

---

<!-- ICS/OT CONTEXT — include this section for ICS-OT and Combined advisory types -->
<!-- Remove this section entirely for IT-only advisories -->

## 5. ICS/OT Context

| Field | Value |
|-------|-------|
| **Critical Infrastructure Sectors** | [Energy / Water / Manufacturing / Transportation / ...] |
| **Safety Impact** | [Yes — potential physical harm / No] |
| **Affected Protocols** | [Modbus / DNP3 / OPC-UA / EtherNet/IP / BACnet / N/A] |
| **Asset Types** | [PLC / RTU / HMI / DCS / Engineering Workstation] |
| **Network Zone** | [OT / DMZ / IT-OT boundary] |

**Physical Process Risk:**

[Describe potential impact on physical processes if exploited. Include safety system implications.]

**Regulatory References:**

- NERC CIP: [applicable standards]
- IEC 62443: [applicable sections]
- NIST SP 800-82: [applicable guidance]

**OT-Specific Remediation Notes:**

[Patching in OT environments requires change management coordination. Include maintenance window scheduling guidance, rollback procedures, and compensating controls for the interim.]

<!-- END ICS/OT CONTEXT -->

---

## 6. Impact Assessment

### IT Impact
| Dimension | Rating | Description |
|-----------|--------|-------------|
| **Confidentiality** | [High/Medium/Low/None] | [what data is exposed] |
| **Integrity** | [High/Medium/Low/None] | [what can be modified] |
| **Availability** | [High/Medium/Low/None] | [what service is disrupted] |

### ICS/OT Impact _(Combined and ICS-OT types only)_
| Dimension | Rating | Description |
|-----------|--------|-------------|
| **Safety** | [Critical/High/Medium/Low/None] | [physical harm potential] |
| **Process Disruption** | [Critical/High/Medium/Low/None] | [operational impact] |
| **Environmental** | [Critical/High/Medium/Low/None] | [environmental release risk] |

---

## 7. Exploit Status

| Indicator | Status |
|-----------|--------|
| **Active Exploitation** | [Yes — observed ITW / No] |
| **Proof of Concept** | [Public PoC / Private PoC / None known] |
| **Exploit Frameworks** | [Metasploit / Cobalt Strike / Custom / None] |
| **CISA KEV Listed** | [Yes (date) / No] |
| **Ransomware Association** | [Known / Suspected / None] |

**Exploitation Timeline:**

- [Date]: Vulnerability disclosed
- [Date]: Patch released
- [Date]: PoC published _(if applicable)_
- [Date]: Active exploitation observed _(if applicable)_

---

## 8. Mitigations (Immediate)

Apply these mitigations immediately if patching is not possible:

1. [Specific workaround with exact configuration steps]
2. [Network-level mitigation: firewall rules, ACLs, segmentation]
3. [Application-level mitigation: disable feature X in config file Y]

### IT Mitigations
- [WAF rules, IDS signatures, network ACLs]

### OT Mitigations _(Combined and ICS-OT types only)_
- [Protocol-specific restrictions]
- [Network segmentation enhancements]
- [Compensating controls until maintenance window]

---

## 9. Remediation (Patching)

| Product | Action | Version | Link |
|---------|--------|---------|------|
| [Product] | Update to | [version] | [vendor advisory URL] |

### IT Remediation Timeline
- **Critical/High:** Patch within [N] days
- **Medium:** Patch within [N] days
- **Low:** Patch in next maintenance cycle

### OT Remediation Timeline _(Combined and ICS-OT types only)_
- **Schedule during next maintenance window**
- **Change management ticket:** [required / recommended]
- **Rollback procedure:** [describe]
- **Testing requirements:** [pre-deployment validation steps]

---

## 10. Detection Guidance

### Indicators of Compromise (IOCs)

| Type | Value | Context |
|------|-------|---------|
| IP | [x.x.x.x] | [C2 server / scanner source] |
| Domain | [domain.tld] | [payload delivery] |
| Hash (SHA-256) | [hash] | [malicious binary] |
| URL | [url] | [exploit delivery] |

### Detection Rules

**Snort/Suricata:**
```
[rule]
```

**Sigma:**
```yaml
[rule]
```

**YARA:**
```
[rule]
```

**Log Indicators:**
- [What to search for in logs, which log source, example log entry]

---

## 11. References

| Source | Link |
|--------|------|
| NVD | [https://nvd.nist.gov/vuln/detail/CVE-YYYY-NNNNN] |
| Vendor Advisory | [URL] |
| CISA Advisory | [URL] |
| MITRE ATT&CK | [URL] |
| Related Advisories | [URLs] |

---

## 12. Revision History

| Date | Version | Description |
|------|---------|-------------|
| [YYYY-MM-DD] | 1.0 | Initial advisory publication |

---

_This advisory was generated using the SecOps Factory advisory template (CSAF Security Advisory profile). For questions about this advisory, contact [advisory contact]._

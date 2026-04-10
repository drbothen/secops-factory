# MITRE ATT&CK Mapping Guide for Vulnerability Analysis

## Introduction

### What is MITRE ATT&CK?

The MITRE ATT&CK framework is a globally accessible knowledge base of adversary tactics and techniques based on real-world observations. It provides a common language for understanding cyber adversary behavior.

**Framework Structure:**
- **Tactics** = "Why" -- The adversary's tactical objectives (e.g., Initial Access, Execution)
- **Techniques** = "How" -- Specific methods to achieve tactical goals (each has a T-number, e.g., T1190)

**Reference:** https://attack.mitre.org

### Purpose of This Guide

This guide helps security analysts map vulnerabilities (CVEs) to ATT&CK tactics and techniques to:
- Understand attack paths and adversary progression
- Prioritize detection and monitoring efforts
- Enrich vulnerability analysis with tactical context
- Align patching with defensive monitoring capabilities

---

## Common Tactics for Vulnerability Types

### Tactic: Initial Access (TA0001)

**Definition:** Adversaries gain initial entry through vulnerable systems.

**Common Vulnerability Types:**
- Remote Code Execution (RCE) in public-facing applications
- SQL Injection in web applications
- Authentication bypass vulnerabilities
- Unrestricted file upload
- Unpatched VPN/remote access services

**Key Techniques:**

| Technique | ID | Vulnerability Types | Example CVEs |
|-----------|-----|-------------------|--------------|
| Exploit Public-Facing Application | T1190 | RCE, SQLi, SSRF | CVE-2021-44228 (Log4Shell) |
| External Remote Services | T1133 | VPN, RDP vulnerabilities | CVE-2019-0708 (BlueKeep) |
| Valid Accounts | T1078 | Credential theft, auth bypass | CVE-2023-22515 (Confluence) |

### Tactic: Execution (TA0002)

**Definition:** Adversaries run malicious code on victim systems.

**Key Techniques:**

| Technique | ID | Vulnerability Types | Example CVEs |
|-----------|-----|-------------------|--------------|
| Command and Scripting Interpreter | T1059 | Command injection, OS command | CVE-2024-3400 (PAN-OS) |
| Exploitation for Client Execution | T1203 | Browser, office, PDF exploits | CVE-2023-36884 (Office) |

### Tactic: Privilege Escalation (TA0004)

**Definition:** Adversaries gain higher-level permissions.

**Key Techniques:**

| Technique | ID | Vulnerability Types | Example CVEs |
|-----------|-----|-------------------|--------------|
| Exploitation for Privilege Escalation | T1068 | Local privesc, kernel exploits | CVE-2023-32233 (Linux kernel) |
| Access Token Manipulation | T1134 | Token theft, impersonation | Various auth vulnerabilities |

### Tactic: Lateral Movement (TA0008)

**Key Technique:**

| Technique | ID | Vulnerability Types | Example CVEs |
|-----------|-----|-------------------|--------------|
| Exploitation of Remote Services | T1210 | Internal RCE, SMB exploits | CVE-2017-0144 (EternalBlue) |

### Tactic: Impact (TA0040)

**Key Techniques:**

| Technique | ID | Vulnerability Types |
|-----------|-----|-------------------|
| Data Encrypted for Impact | T1486 | Ransomware-enabling vulns |
| Service Stop | T1489 | DoS vulnerabilities |

---

## Vulnerability Type to ATT&CK Mapping

### Quick Reference Table

| Vulnerability Type | Primary Tactic | Primary Technique | T-Number |
|-------------------|---------------|-------------------|----------|
| Remote Code Execution (RCE) | Initial Access | Exploit Public-Facing App | T1190 |
| SQL Injection | Initial Access | Exploit Public-Facing App | T1190 |
| Cross-Site Scripting (XSS) | Initial Access | Drive-by Compromise | T1189 |
| Command Injection | Execution | Command and Scripting | T1059 |
| Local Privilege Escalation | Privilege Escalation | Exploitation for Privesc | T1068 |
| Authentication Bypass | Initial Access | Valid Accounts | T1078 |
| Deserialization | Execution | Exploitation for Client Exec | T1203 |
| Path Traversal | Collection | Data from Local System | T1005 |
| SSRF | Initial Access | Exploit Public-Facing App | T1190 |
| Buffer Overflow | Execution | Native API | T1106 |

---

## ICS-Specific ATT&CK Mapping

### ICS ATT&CK Matrix

For ICS/SCADA/OT environments, use the ICS ATT&CK matrix:
**Reference:** https://attack.mitre.org/matrices/ics/

| ICS Tactic | Description | Example Techniques |
|-----------|-------------|-------------------|
| Initial Access | Entry into ICS network | T0866 - Exploitation of Remote Services |
| Execution | Running code on ICS device | T0871 - Execution through API |
| Persistence | Maintaining ICS access | T0839 - Module Firmware |
| Inhibit Response Function | Blocking safety systems | T0816 - Device Restart/Shutdown |
| Impair Process Control | Disrupting physical process | T0836 - Modify Parameter |
| Impact | Physical damage/disruption | T0882 - Theft of Operational Information |

### Mapping ICS Vulnerabilities

When mapping ICS/OT vulnerabilities:
1. Check both Enterprise and ICS ATT&CK matrices
2. Consider Purdue model level of affected asset
3. Map safety system impact (SIS/SIL implications)
4. Note physical process impact potential

---

## Mapping Quality Criteria

A good ATT&CK mapping should:

1. **Have at least one tactic** identified
2. **Include T-numbers** for all techniques
3. **Match vulnerability type** to appropriate technique
4. **Note confidence level** (CONFIRMED from threat intel vs INFERRED from vuln type)
5. **Include detection recommendations** aligned with mapped techniques
6. **Reference ICS matrix** when applicable to OT environments

---

## Authoritative References

- [MITRE ATT&CK](https://attack.mitre.org/) -- Enterprise matrix
- [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/) -- ICS matrix
- [ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/) -- Visualization tool
- [MITRE CVE to ATT&CK](https://attack.mitre.org/resources/attack-data-and-tools/) -- Data and tools

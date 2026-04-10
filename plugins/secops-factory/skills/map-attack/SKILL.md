---
name: map-attack
description: "Use when mapping a CVE to MITRE ATT&CK framework tactics and techniques. Supports both Enterprise and ICS ATT&CK matrices."
argument-hint: "<cve-id>"
---

# Map MITRE ATT&CK

Map a CVE to MITRE ATT&CK framework tactics and techniques.

## Process

### Step 1: Gather Vulnerability Context

Collect: CVE ID, vulnerability type (RCE, SQLi, XSS, etc.), CVSS vector, affected product.

### Step 2: Map to Tactics and Techniques

Using `${CLAUDE_PLUGIN_ROOT}/data/mitre-attack-mapping-guide.md`:

1. Identify primary tactic from vulnerability type
2. Map to specific technique(s) with T-numbers
3. Note confidence level (CONFIRMED from threat intel vs INFERRED from vuln type)
4. Add detection recommendations for each technique

### Step 3: ICS/OT Considerations

If target environment is ICS/SCADA/OT:
1. Check ICS ATT&CK matrix (https://attack.mitre.org/matrices/ics/)
2. Map to ICS-specific techniques
3. Consider Purdue model level
4. Note safety system implications

### Step 4: Return Mapping

```yaml
attack_mapping:
  tactics: ['Initial Access', 'Execution']
  techniques:
    - id: 'T1190'
      name: 'Exploit Public-Facing Application'
      confidence: 'CONFIRMED'
    - id: 'T1059'
      name: 'Command and Scripting Interpreter'
      confidence: 'INFERRED'
  detection_recommendations:
    - 'Monitor for exploitation attempts against public-facing services'
  ics_techniques: []  # Populated if ICS context
```

## References

- `${CLAUDE_PLUGIN_ROOT}/data/mitre-attack-mapping-guide.md`

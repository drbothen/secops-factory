# Cognitive Bias Detection Checklist

**Purpose:** Identify cognitive bias patterns in security analyst enrichment work.

---

## 1. Confirmation Bias

- [ ] Does the analysis consider evidence that contradicts the initial severity assessment?
- [ ] Are alternate interpretations or scenarios considered?
- [ ] Does the analysis cherry-pick data supporting high/low severity?
- [ ] Are limitations or uncertainties acknowledged?

## 2. Availability Bias

- [ ] Is the assessment influenced by recent dramatic events without statistical basis?
- [ ] Are base rates and historical data consulted?
- [ ] Is the vulnerability compared to similar CVEs, not just memorable ones?

## 3. Anchoring Bias

- [ ] Was the first metric encountered (vendor severity, initial CVSS) independently verified?
- [ ] Does the assessment adjust appropriately when new contradictory data emerges?
- [ ] Are all scoring factors evaluated independently before combining?

## 4. Overconfidence Bias

- [ ] Are definitive claims supported by evidence?
- [ ] Are confidence levels stated with justification?
- [ ] Are uncertainty and limitations acknowledged?
- [ ] Is the language calibrated to evidence strength?

## 5. Recency Bias

- [ ] Is historical context (30/60/90 days) considered?
- [ ] Are seasonal or cyclical patterns checked?
- [ ] Is the assessment based on comprehensive data, not just recent events?

---
name: assess-priority
description: "Use when calculating multi-factor vulnerability priority. Combines CVSS severity, EPSS exploitation probability, CISA KEV status, asset criticality, system exposure, and exploit availability to emit scored_priority: CRIT | HIGH | MED | LOW."
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

**P1-P5 labels are INTERNAL-ONLY** — they are the skill's intermediate 6-factor scoring notation and are never emitted as `scored_priority`. The `scored_priority` output is always a member of the canonical enum `{CRIT, HIGH, MED, LOW}`.

| Score (PC#6 band) | scored_priority | SLA |
|-------------------|----------------|-----|
| >=20 or KEV Listed | CRIT | 24 hours |
| 14-19 | HIGH | 7 days |
| 8-13 | MED | 30 days |
| <8 | LOW | 90 days |

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

---

## scored_priority Output (ICD-203 Field 18)

The skill `priority` output IS `scored_priority` (verdict field 18, BC-4.05.001 Invariant 5, P12-004).
The monitoring loop reads `verdict.scored_priority` — the skill populates this key so it is never nil.

Output JSON structure includes:

```json
{
  "scored_priority": "<SCORED_PRIORITY_ENUM value>",
  "confidence_score": 0.0,
  "confidence": "high|medium|low"
}
```

## SEVERITY_TO_SCORED_PRIORITY_MAP

Maps CVSS SEVERITY_ENUM to SCORED_PRIORITY_ENUM (BC-4.05.001 Invariant 5, EC-001..EC-004).
SEVERITY_ENUM values (CRITICAL, HIGH, MEDIUM, LOW) differ from SCORED_PRIORITY_ENUM (CRIT, HIGH, MED, LOW).

| SEVERITY_ENUM (input) | SCORED_PRIORITY_ENUM (output) |
|-----------------------|-------------------------------|
| CRITICAL | CRIT |
| HIGH | HIGH |
| MEDIUM | MED |
| LOW | LOW |

## Confidence Mapping (D-DEC-011)

Maps `confidence_score` float to `confidence` enum per D-DEC-011 thresholds (VP-SKILL-071).
An inconsistent confidence pair (e.g. confidence_score=0.80 with confidence="low") is invalid and must be rejected.

| confidence_score range | confidence enum | Boundary vectors |
|------------------------|----------------|-----------------|
| >= 0.75 | high | 0.75 → high; 0.749 → medium |
| >= 0.40 and < 0.75 | medium | 0.40 → medium; 0.399 → low |
| < 0.40 | low | |

## Prism-Grounded Scoring (Stage 5)

Org-specific PrismQL queries (PC#5a, PC#5d) MUST include an explicit org_slug constraint for
multi-org isolation (BC-4.05.001 Invariant 4, D-DEC-005, VP-SKILL-070). PC#5b (NVD/CVE global
UDF) is EXEMPT — NVD data has no org dimension; enrich_nvd() keys on CVE ID only.

**Degraded-mode fallback (missing org_slug):** If `org_slug` is unavailable from the execution context, ALL Prism-grounded scoring stages (PC#5a through PC#5e) MUST be skipped entirely. The skill must proceed using only the 6-factor base score without Prism enrichment and MUST note "Prism scoring unavailable: org_slug not in context" in output.

**Degraded mode (Prism MCP unavailable):** When Prism MCP is unavailable (connection error, timeout, or `prism_describe` returns error), skip all Prism-grounded stages (PC#5a–PC#5e), apply the 6-factor algorithm, map the base score to `{CRIT, HIGH, MED, LOW}` via PC#6 band thresholds, set `uncertainty_explicit: true`, and emit "Prism unavailable — result reflects static 6-factor scoring only" in rationale. The `scored_priority` output is always a valid enum member in degraded mode; P1-P5 are INTERNAL-ONLY and never emitted as `scored_priority`.

### PC#5a — 30-Day Historical Baseline Query

```sql
SELECT COUNT(*) AS hit_count,
       COUNT(DISTINCT CASE WHEN disposition='TP' THEN event_id END) AS tp_count,
       COUNT(DISTINCT CASE WHEN disposition='FP' THEN event_id END) AS fp_count
FROM events
WHERE org_slug='<org_slug>'
  AND rule_id='<rule_id>'
  AND timestamp > NOW() - INTERVAL '30 days'
```

### PC#5b — NVD Enrichment via enrich_nvd() UDF

```sql
SELECT enrich_nvd('<cve_id>') AS nvd_data
FROM dual
```

### PC#5c — Rule-Fidelity Recalibration

Compute fidelity from TP/FP counts and adjust exploit_status factor score.

### PC#5d — Per-Tenant Asset Criticality Weights

```sql
SELECT asset_criticality_score
FROM assets
WHERE org_slug='<org_slug>'
  AND asset_id='<asset_id>'
```

### PC#5e — Bayesian TP/FP/BTP Disposition Estimate

Apply prior from 30-day counts to produce advisory disposition estimate.

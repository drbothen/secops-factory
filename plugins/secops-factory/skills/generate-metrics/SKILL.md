---
name: generate-metrics
description: "Use when generating security operations metrics and KPIs from enrichment and review data."
argument-hint: "[--period=7d|30d|90d]"
---

# Generate Security Metrics

Generate security operations metrics and KPIs from enrichment and investigation data.

## Metrics Categories

### Enrichment Metrics
- Total tickets enriched in period
- Average enrichment duration (target: 10-15 min)
- Enrichment quality score distribution
- Most common vulnerability types
- Priority distribution (P1-P5 breakdown)

### Review Metrics
- Total reviews completed
- Average quality score (target: >= 75%)
- Critical gap frequency
- Most common gap categories
- Review cycle time

### Investigation Metrics
- Total events investigated
- Disposition distribution (TP/FP/BTP)
- Average investigation duration (target: 15-25 min)
- Investigation quality score distribution
- False positive rate and tuning recommendations

### Priority Metrics
- Priority distribution across portfolio
- SLA compliance rate per priority level
- Average time to remediation by priority
- KEV-listed vulnerability remediation velocity

## Process

1. Parse `--period` argument (default: 30d)
2. Scan artifacts/enrichments/ and artifacts/reviews/ directories
3. Aggregate metrics from available data
4. Present summary with trends and recommendations

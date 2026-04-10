---
name: orchestrator-investigation-workflow
description: Orchestrator workflow reference for the 7-stage security event investigation pipeline. Loaded by the investigate-event skill. Not directly invokable.
disable-model-invocation: true
---

# Event Investigation Workflow

**Canonical source** for the 7-stage security event investigation pipeline. The `investigate-event` skill (`skills/investigate-event/SKILL.md`) is the entry point; this file is the playbook. If the two disagree, this file wins.

## Pipeline Stages

For each security alert/event:

1. **Alert Triage** — Read the alert from JIRA or direct input. Auto-detect platform type: ICS (Claroty, Nozomi), IDS (Snort, Suricata), SIEM (Splunk, QRadar, Sentinel). Extract: source/destination, alert rule, timestamp, severity, raw payload.

2. **Evidence Collection** — Gather corroborating data: related alerts (time window: -1h to +1h), asset context (owner, network zone, OS, services), historical alerts on same asset, authentication logs, network flow data. Document evidence sources.

3. **Technical Analysis** — Analyze the event against known patterns:
   - Is this a known attack technique? (reference ATT&CK)
   - Is this expected behavior for this asset type?
   - Are there IoCs (IPs, hashes, domains)?
   - What is the potential blast radius?
   Reference `${CLAUDE_PLUGIN_ROOT}/data/event-investigation-best-practices.md`.

4. **Hypothesis Formation** — Form 2-3 competing hypotheses. For each: supporting evidence, contradicting evidence, confidence level. This step exists to prevent confirmation bias — you must consider alternatives.

5. **Disposition Determination** — Classify as:
   - **TP (True Positive)** — confirmed malicious activity requiring response
   - **FP (False Positive)** — alert fired incorrectly, no malicious activity
   - **BTP (Benign True Positive)** — alert fired correctly on legitimate/authorized activity
   Document: disposition, confidence (High/Medium/Low), evidence chain, alternatives considered.

6. **Documentation** — Write the investigation report using `${CLAUDE_PLUGIN_ROOT}/templates/event-investigation-tmpl.yaml`. All required sections must be populated.

7. **JIRA Update** — Post investigation as a JIRA comment and update disposition fields. Requires review approval for TP and Low-confidence dispositions.

## Post-Pipeline

Dispatch `/adversarial-review-secops` to review the investigation. The reviewer scores against 7 quality dimensions with weighted scoring (Completeness 25%, Accuracy 20%, Disposition Reasoning 20%, Contextualization 15%, Methodology 10%, Documentation 5%, Bias 5%).

## Cognitive Bias Checkpoints

Mandatory bias checks at specific stages:
- **Stage 2** — Availability bias: are you over-weighting recent similar events?
- **Stage 3** — Automation bias: are you trusting the scanner output without verification?
- **Stage 4** — Confirmation bias: do your hypotheses have genuine alternatives?
- **Stage 5** — Anchoring bias: is your disposition locked to the first evidence you found?

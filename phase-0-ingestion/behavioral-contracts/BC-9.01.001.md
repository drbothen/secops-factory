---
document_type: behavioral-contract
level: L3
version: "1.2"
status: draft
producer: product-owner
timestamp: 2026-07-20T00:00:00
phase: f2
inputs:
  - .factory/feature/prism-integration-handoff-brief.md
  - .factory/phase-f2-spec-evolution/architecture-delta.md
  - .factory/phase-f1-delta-analysis/artifact-mapping.md
input-hash: "COMPUTE-AT-COMMIT — state-manager: sha256sum .factory/feature/prism-integration-handoff-brief.md .factory/phase-f2-spec-evolution/architecture-delta.md .factory/phase-f1-delta-analysis/artifact-mapping.md"
traces_to: feature/prism-integration-handoff-brief.md
origin: greenfield
subsystem: threat-hunting
capability: CAP-THREATHUNTING-01
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
modified: ["v1.1-FV-PROPOSED-DROP-2026-07-20", "v1.2-ADV-F2-P15-004-severity-presentation-only-note-2026-07-22"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-9.01.001: scan-threats Skill — Proactive PrismQL Threat Hunt Across All Orgs

> **Revision history:**
> - v1.2 (2026-07-22): Pass-15 adversarial remediation — P15-004 (OBS, presentation-only severity bucketing clarification). **PC#5 clarifying note added:** The CRIT/HIGH/MED/LOW severity bucketing in PC#5 is presentation-only — scan-threats does not run Stage-5 scoring (assess-priority) and does not produce a `scored_priority` verdict field. Native prism severity values are mapped to these tokens for display grouping only; this mapping is not an input to disposition-guard hard-floor checks. No mechanism change. ADV-F2-P15-004.
> - v1.1 (2026-07-20): FV-PROPOSED-DROP: VP-SKILL-058 and VP-SKILL-059 are now FINALIZED per verification-delta §1 — dropped `(PROPOSED)` qualifier from VP table rows and VP Anchors.
> - v1.0 (2026-07-20): Initial authoring for prism-integration cycle (v0.10.0). Source: handoff brief §2.4 (scan-threats skill), architecture-delta.md §D-DEC-005 (org_slug scoping invariant), artifact-mapping.md §1.4 (BC-9.01.001 slot). prism_describe-before-query is the critical ordering invariant.

## Description

The `scan-threats` skill executes a predefined library of PrismQL hunting queries
across all registered orgs, using `prism_describe` to enumerate available tables
before issuing any query. Results are grouped by severity (CRIT, HIGH, MED, LOW)
and presented as a structured threat-hunting report. This is a proactive,
analyst-initiated capability — not the reactive per-alert pipeline of the
monitoring-loop. All queries are scoped per-org via org_slug (D-DEC-005).

## Preconditions

1. The `scan-threats` skill is invoked via the `/scan-threats` command. Confidence:
   CONV-001/002/003.
2. The prism MCP connection is active (`~/.claude/prism.mcp.json` written by
   activate, prism server running). Confidence: inferred from D-DEC-003.
3. `prism.toml` is accessible and contains at least one `[[orgs]]` entry from
   which the skill derives the list of orgs to hunt across. Confidence: inferred
   from brief §2.4.
4. The skill announces itself before any operation: "I am using the scan-threats
   skill to execute predefined threat-hunting queries." Confidence: CONV-008.

## Postconditions

1. The skill calls `prism_describe` (or equivalent table enumeration MCP call)
   to enumerate available tables for each org before executing any hunting query.
   Confidence: brief §2.4 "Uses prism_describe to enumerate available tables
   before querying."
2. A predefined set of PrismQL hunting queries is executed. Queries may include
   but are not limited to: lateral movement indicators, credential access patterns,
   exfiltration signatures, and reconnaissance behaviors. The predefined query
   library is maintained in `${CLAUDE_PLUGIN_ROOT}/data/threat-hunt-queries.md` or
   equivalent. Confidence: inferred from brief §2.4 "predefined PrismQL hunting
   queries."
3. Queries are only issued against tables confirmed to exist by `prism_describe`
   (PC#1). A table not present in `prism_describe` output is silently skipped
   (not an error). Confidence: inferred from "enumerate available tables before
   querying" — defensive table presence check.
4. For each org, each hunting query is scoped with an explicit `org_slug`
   constraint. Confidence: D-DEC-005 invariant.
5. Findings are grouped by severity (CRIT, HIGH, MED, LOW) in the output.
   Findings with no severity indicator from prism default to MED. Confidence:
   brief §2.4 "results grouped by severity."

   **NOTE (P15-004, OBS — presentation-only):** This severity bucketing is for display purposes only — scan-threats does not run Stage-5 scoring (assess-priority, BC-4.05.001) and does not produce a `scored_priority` verdict field. Native prism severity values are mapped to the CRIT/HIGH/MED/LOW tokens for grouping display; this mapping is not an input to disposition-guard hard-floor checks (which key on verdict `scored_priority` from the monitoring-loop pipeline).
6. If no findings are returned across all orgs for all queries, the output states
   "No threat indicators found" rather than emitting an empty response. Confidence:
   fail-loud requirement.

## Invariants

1. **prism_describe before any query (per-org).** For each org, the skill calls
   `prism_describe` to enumerate available tables before issuing any hunting
   query. This is NOT skippable. Issuing a hunting query against a table that
   does not exist returns an error that the skill must not treat as "no results."
2. **org_slug scoping on all queries.** Every PrismQL hunting query issued by this
   skill must include a `WHERE org_slug = '<org_slug>'` clause (or equivalent
   prism-native scoping mechanism). The skill must never construct a cross-tenant
   query. Queries without org_slug scope must be rejected before execution.
   D-DEC-005.
3. **Predefined queries only.** The skill executes a fixed, pre-authored library
   of hunting queries. It does not construct arbitrary PrismQL from user input
   (which would introduce injection risk). User-supplied query arguments are
   treated as filter parameters, not as raw SQL.
4. **Fail-loud on prism error.** E-SPEC-024, E-CRED-008, and other prism error
   codes must be surfaced per org per sensor. If a query fails for one org, the
   skill continues with other orgs and reports the failure in the findings summary.
5. **Announce at Start is unconditional.** The skill emits its announcement before
   any table enumeration or query execution.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | prism_describe returns empty for an org (no sensor tables) | Skip that org; report "No sensor tables available for org <org_slug>" in the findings summary |
| EC-002 | A predefined hunting query targets a table not in prism_describe output | Skip that query for that org without error; note "Table <name> not available for org <org_slug>" in the diagnostic log |
| EC-003 | All orgs × all queries return zero rows | Emit "No threat indicators found across all orgs" — not an empty response |
| EC-004 | One org returns CRIT findings; another returns no findings | Present CRIT findings prominently; present clean-bill message for the other org separately |
| EC-005 | prism MCP unavailable (E-SPEC-024) | Skill reports E-SPEC-024; instructs user to check prism binary, MCP config, and run /activate |
| EC-006 | E-CRED-008 for one org's sensor | Skill reports credential miss for that org's sensor; continues with other orgs; includes "credential missing for <org_slug>/<sensor_id>" in findings summary |
| EC-007 | Hunting query returns very large result set (>1000 rows) | Skill truncates at a safe limit, reports "Truncated — top N findings shown", and instructs user to use more targeted queries for full analysis |
| EC-008 | A finding lacks a severity field | Default to MED severity; note in output that severity was defaulted |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Two orgs with CrowdStrike + Armis tables available; predefined query returns 3 HIGH findings for org-a, 0 for org-b | Findings grouped: HIGH section with 3 entries (org-a); "No threat indicators found" for org-b; org-a results scoped to org-a org_slug | happy-path |
| prism_describe returns no tables for an org | "No sensor tables available for org <org_slug>" in findings summary; no query attempted for that org | edge-case (EC-001) |
| A hunting query targets a missing table | Query skipped; diagnostic note in output; other queries continue | edge-case (EC-002) |
| All orgs, all queries: zero rows | "No threat indicators found across all orgs" (not empty output) | edge-case (EC-003) |
| prism MCP unavailable (E-SPEC-024) | Error surfaced with corrective guidance | error (EC-005) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-058 | prism_describe-first invariant — SKILL.md workflow documents prism_describe call as the first step before any hunting query for each org; "enumerate tables before querying" step is present | structural / BATS (`@test "scan-threats has prism_describe enumeration step before queries"`) |
| VP-SKILL-059 | org_slug scoping in scan-threats — SKILL.md Iron Law or Red Flag explicitly documents that all PrismQL queries must include org_slug scope; cross-tenant query is a Red Flag | structural / BATS (`@test "scan-threats has org_slug scoping requirement documented"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-THREATHUNTING-01 ("Execute predefined PrismQL threat-hunting queries across all registered orgs") per handoff brief §2.4 |
| Capability Anchor Justification | CAP-THREATHUNTING-01 ("Execute predefined PrismQL threat-hunting queries across all registered orgs") per handoff brief §2.4 — this BC describes exactly the scan-threats skill that executes prism_describe-guided hunting queries with org_slug-scoped results grouped by severity, which is what CAP-THREATHUNTING-01 defines |
| L2 Domain Invariants | D-DEC-005 (org_slug scoping: ALL PrismQL queries must include explicit org_slug constraint) |
| Architecture Module | C-2 (skill-procedures), C-25 (prism-mcp: prism_describe + query interfaces) |
| Related BCs | BC-8.02.001 (related — both query prism per-org; sensor-metrics is telemetry, scan-threats is hunting); BC-10.01.001 (related — monitoring-loop is reactive per-alert; scan-threats is proactive analyst-initiated) |
| Architecture Anchors | architecture-delta.md §D-DEC-005 (org_slug scoping invariant); architecture-delta.md §C-25 (prism-mcp: prism_describe interface) |
| Story Anchor | TBD (filled by story-writer) |
| VP Anchors | VP-SKILL-058, VP-SKILL-059 |

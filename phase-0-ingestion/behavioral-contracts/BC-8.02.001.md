---
document_type: behavioral-contract
level: L3
version: "1.1"
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
subsystem: metrics-pipeline
capability: CAP-METRICS-02
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
modified: ["v1.1-FV-PROPOSED-DROP-2026-07-20"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-8.02.001: sensor-metrics Skill — Per-Org Sensor Health Telemetry via prism_sensor_health

> **Revision history:**
> - v1.0 (2026-07-20): Initial authoring for prism-integration cycle (v0.10.0). Source: handoff brief §2.4 (metrics skill), architecture-delta.md §D-DEC-006 (skill naming: `sensor-metrics`, not `metrics`), artifact-mapping.md §1.4 (BC-8.02.001 slot). D-DEC-006 resolves naming conflict with existing `generate-metrics` skill.
> - v1.1 (2026-07-20): FV-PROPOSED-DROP: VP-SKILL-056 and VP-SKILL-057 are now FINALIZED per verification-delta §1 — dropped `(PROPOSED)` qualifier from VP table rows and VP Anchors.

## Description

The `sensor-metrics` skill queries the `prism_sensor_health` virtual table via the
prism MCP tool and returns per-org × per-sensor telemetry: last-seen timestamp,
table row counts, and error rate. This skill is distinct from the existing
`generate-metrics` skill (BC-8.01.001), which computes Jira-derived effort
metrics. `sensor-metrics` is a prism data source query; `generate-metrics` is a
Jira analytics query. The skill name is `sensor-metrics` per D-DEC-006.

## Preconditions

1. The `sensor-metrics` skill is invoked via the `/sensor-metrics` command.
   Confidence: CONV-001/002/003.
2. The prism MCP connection is active (`~/.claude/prism.mcp.json` written by
   activate, prism server running). Confidence: inferred from D-DEC-003.
3. `prism.toml` is accessible and contains at least one `[[orgs]]` entry.
   Confidence: inferred from brief §2.4.
4. The skill announces itself before any query: "I am using the sensor-metrics
   skill to retrieve sensor health telemetry." Confidence: CONV-008.

## Postconditions

1. The skill executes `SELECT * FROM prism_sensor_health` (or equivalent prism
   MCP call for sensor health data). Confidence: inferred from brief §2.4 exact
   query specification.
2. For each org × sensor pair present in the response, the output contains:
   - `org_slug` — the tenant identifier
   - `sensor_id` — the sensor name (crowdstrike, armis, claroty, cyberint)
   - `last_seen_ts` — ISO 8601 UTC timestamp of the most recent event received
   - `row_count` — total event count in the sensor table for this org
   - `error_rate` — fraction of events that failed to ingest/normalize (0.0–1.0
     or equivalent unit as returned by prism)
   Confidence: inferred from brief §2.4 "Returns: last-seen timestamp, table row
   counts, error rate per org × sensor".
3. The output is presented in a structured format (table or structured text)
   enabling the user to quickly assess sensor health across all orgs. Confidence:
   inferred from brief §2.4 intent.
4. If the prism MCP call returns an error (E-SPEC-024 boot abort, E-CRED-008
   keyring miss), the skill reports the error with actionable guidance and does
   NOT return empty data silently as if all sensors are healthy. Confidence:
   fail-loud requirement.

## Invariants

1. **Skill name is `sensor-metrics` (D-DEC-006).** The skill directory is
   `skills/sensor-metrics/SKILL.md`, the command is `commands/sensor-metrics.md`.
   No alias, no renaming. This name was chosen specifically to distinguish from
   `generate-metrics` at the user interface level. Changing this name is a
   breaking change.
2. **org_slug scoping.** If the prism MCP tool supports org_slug filtering on
   `prism_sensor_health`, the query must include it. The skill must never return
   cross-tenant raw sensor data without org_slug isolation (D-DEC-005).
3. **Fail-loud on prism error.** An E-SPEC-024 or E-CRED-008 error from prism
   must be surfaced to the user verbatim with corrective action. Silent empty
   output on prism error is a defect.
4. **Distinct from generate-metrics.** This skill does not use `jr` for data
   retrieval. It does not produce Jira-based effort metrics. Any confusion between
   `sensor-metrics` and `generate-metrics` in SKILL.md prose is a defect.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | prism MCP connection unavailable (E-SPEC-024 — boot abort) | Skill reports E-SPEC-024 and instructs user to check prism binary path, RUST_LOG=off env var, and run /activate to reconfigure |
| EC-002 | prism_sensor_health returns empty result (no orgs onboarded) | Skill reports "No sensors found in prism_sensor_health — have you run /onboard-customer and /onboard-sensor?" |
| EC-003 | One org has sensors registered but another has none | Skill reports telemetry for all orgs that have sensor data; for orgs with no sensor data, shows "no sensors registered" row |
| EC-004 | prism_sensor_health returns a `last_seen_ts` older than 24 hours for a sensor | Skill flags this sensor in the output with a warning: "SENSOR SILENCE: last seen >24h ago — may indicate sensor connectivity issue" |
| EC-005 | error_rate > 0.0 for a sensor | Skill highlights the sensor row; reports "Elevated error rate (<value>) — investigate sensor normalization errors" |
| EC-006 | E-CRED-008 (keyring miss) returned for a sensor | Skill surfaces the error with instruction: "Credential not found for <sensor_id>/<org_slug>. Run /onboard-sensor to provision credentials." |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| prism MCP available, two orgs with CrowdStrike + Armis sensors each, all last_seen recent | Structured table of 4 rows (2 orgs × 2 sensors) with last_seen_ts, row_count, error_rate; no warnings | happy-path |
| prism MCP available, one sensor with last_seen_ts = 36 hours ago | Table row for that sensor flagged with SENSOR SILENCE warning | edge-case (EC-004) |
| prism MCP unavailable (E-SPEC-024) | Error reported verbatim; corrective action instructions | error (EC-001) |
| prism_sensor_health returns empty | "No sensors found" message with onboarding guidance | edge-case (EC-002) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-056 | Per-org × sensor output completeness — for each row returned by prism_sensor_health, the output contains org_slug, sensor_id, last_seen_ts, row_count, and error_rate | integration / BATS (`@test "sensor-metrics output contains required fields per org-sensor pair"`) |
| VP-SKILL-057 | sensor-metrics naming compliance (D-DEC-006) — skill directory is skills/sensor-metrics/, command is commands/sensor-metrics.md; no alias `metrics` exists | structural / BATS (`@test "sensor-metrics skill name matches D-DEC-006 decision"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-METRICS-02 ("Query per-org sensor health telemetry from prism") per handoff brief §2.4 |
| Capability Anchor Justification | CAP-METRICS-02 ("Query per-org sensor health telemetry from prism") per handoff brief §2.4 — this BC describes exactly the sensor-metrics skill that retrieves last-seen/row-counts/error-rate from prism_sensor_health, which is what CAP-METRICS-02 defines; distinct from CAP-METRICS-01 (Jira effort metrics, BC-8.01.001) |
| L2 Domain Invariants | D-DEC-005 (org_slug scoping on all prism queries); D-DEC-006 (skill naming: sensor-metrics) |
| Architecture Module | C-2 (skill-procedures), C-25 (prism-mcp — prism_sensor_health query target) |
| Related BCs | BC-8.01.001 (related — same S=8 section, different data source: Jira vs prism); BC-10.01.001 (composes with — monitoring-loop Stage 0 consumes prism_sensor_health directly) |
| Architecture Anchors | architecture-delta.md §D-DEC-006 (naming decision: sensor-metrics); architecture-delta.md §C-25 (prism-mcp: interfaces_provided includes prism_sensor_health) |
| Story Anchor | TBD (filled by story-writer) |
| VP Anchors | VP-SKILL-056, VP-SKILL-057 |

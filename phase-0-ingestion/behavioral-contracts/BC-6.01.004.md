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
subsystem: lifecycle-management
capability: CAP-LIFECYCLE-04
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

# Behavioral Contract BC-6.01.004: onboard-sensor Skill — Sensor Overlay TOML Write, AD-017 Credential Walkthrough, and SELECT 1 Verification

> **Revision history:**
> - v1.0 (2026-07-20): Initial authoring for prism-integration cycle (v0.10.0). Source: handoff brief §2.3, architecture-delta.md §D-DEC-005/D-DEC-007/C-28, artifact-mapping.md §1.4 (BC-6.01.004 slot). AD-017 piped-stdin pattern and SELECT 1 verification are the critical invariants.
> - v1.1 (2026-07-20): FV-PROPOSED-DROP: VP-SKILL-054 and VP-SKILL-055 are now FINALIZED per verification-delta §1 — dropped `(PROPOSED)` qualifier from VP table rows and VP Anchors.

## Description

The `onboard-sensor` skill adds a sensor overlay for an existing customer org. It
writes a `<sensor_id>.sensor.toml` overlay file under
`<spec_dir>/customers/<org_slug>/`, then walks the user through AD-017-compliant
credential provisioning via the piped-stdin pattern (never requesting credential
values in chat). Verification is performed via `prism_describe` (not by
re-reading the credential) and a `SELECT 1` connectivity probe confirms prism
accepts queries from this sensor before the skill reports success.

## Preconditions

1. The `onboard-sensor` skill is invoked with `<org_slug>` and `<sensor_id>` as
   arguments (or the skill prompts for them interactively). Confidence: inferred
   from CONV-001/002/003 (skill entry point pattern).
2. The target org (`org_slug`) is already registered in `prism.toml` — i.e.,
   `onboard-customer` (BC-6.01.003) has been run for this org. Confidence:
   inferred from brief §2.3 ordering and brief §4.5 demo sequence.
3. The `sensor_id` is one of the supported values: `crowdstrike`, `armis`,
   `claroty`, `cyberint`. Confidence: inferred from brief §2.1 MCP env block
   listing exactly these four sensors.
4. The prism binary is available in PATH (activated via BC-6.01.001). Confidence:
   inferred from brief §2.3 — credential set is run as a subprocess, not via MCP.
5. The `<spec_dir>/customers/<org_slug>/` directory exists (created by
   BC-6.01.003). Confidence: inferred from brief §2.3 ordering.
6. The skill announces itself before any other action ("I am using the
   onboard-sensor skill…"). Confidence: structural requirement (CONV-008).
7. The prism MCP connection is available (prism binary running as MCP server, or
   accessible for subprocess calls). Confidence: inferred from SELECT 1 verification
   requirement.

## Postconditions

1. A file `<spec_dir>/customers/<org_slug>/<sensor_id>.sensor.toml` is written
   with at minimum the following fields: `extends` (the base sensor profile),
   `instance_id` (unique identifier for this sensor instance), `base_url` (the
   sensor API endpoint for this customer). Confidence: inferred from brief §2.3.
2. Credentials for the sensor are provisioned via the AD-017 piped-stdin pattern.
   The skill **provides the exact command** for the user to run in their terminal
   and instructs them to do so — it does not execute `prism credential set` itself
   on behalf of the user. Confidence: AD-017, brief §2.3, C-28.
3. The sensor is confirmed as registered via `prism_describe` — the skill queries
   `prism_describe` (using the prism MCP tool, not by re-reading the credential)
   and confirms the sensor appears in the response before reporting success.
   Confidence: inferred from brief §2.3 "Verifies the credential write succeeded".
4. A `SELECT 1` query is executed via the prism `query` MCP tool against the
   onboarded sensor's table. The skill reports success only if this query returns
   a non-error response, confirming end-to-end prism connectivity for this sensor.
   Confidence: brief §2.3 step 6.
5. If either the `prism_describe` check (PC#3) or the `SELECT 1` probe (PC#4)
   fails, the skill reports the failure explicitly with actionable error information
   and does NOT report onboarding as complete. Confidence: fail-loud requirement,
   brief §2.3 intent.

## Invariants

1. **AD-017 — piped-stdin pattern only; never request credential in chat.**
   The exact command pattern the skill provides is:
   ```
   echo "<credential_value>" | prism --config-dir <dir> credential set \
     --sensor <sensor_id> \
     --name <credential_name> \
     --org-slug <org_slug>
   ```
   The skill describes what credential is needed, provides this exact command
   template (with `<credential_value>` as a placeholder), and asks the user to
   run it in their terminal. The skill never asks the user to type or paste the
   actual credential value into the chat. This is unconditional — no option or
   flag enables in-chat credential entry. Confidence: AD-017, brief §2.3.
2. **Verification via prism_describe, not credential re-read.** After the user
   confirms they have run the credential set command, the skill verifies success
   by querying `prism_describe` to confirm the sensor is registered. The skill
   never invokes `prism credential get` or any mechanism that would surface the
   credential value. Confidence: brief §2.3 "Verifies via prism_describe (not
   credential re-read)".
3. **SELECT 1 is mandatory; success message gated on it.** The skill must execute
   `SELECT 1` via the prism `query` MCP tool before emitting a success message.
   A silent or error response from `SELECT 1` is a failure — the skill must
   report it and instruct the user to diagnose the prism connection, not proceed
   as if onboarding succeeded. Confidence: brief §2.3 step 6.
4. **--config-dir isolation for credential set subprocess.** The `echo | prism`
   credential set command template provided to the user must include
   `--config-dir <dir>` pointing to the customer's config directory. Using the
   default config dir would contaminate production org configs. Confidence:
   architecture-delta.md §3.2 (`--config-dir <tmpdir>` isolation constraint),
   extended to production credential provisioning.
5. **Only supported sensor IDs are accepted.** The skill must reject a
   `sensor_id` that is not in `{crowdstrike, armis, claroty, cyberint}` with a
   clear error message listing the supported values.
6. **Announce at Start is unconditional.** The skill emits its announcement before
   any file operation.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | org_slug not in prism.toml (onboard-customer not run first) | Skill STOPS with error: "Org '<org_slug>' not found in prism.toml. Run onboard-customer first." |
| EC-002 | sensor_id is not one of the four supported values | Skill rejects with error listing supported sensor IDs: crowdstrike, armis, claroty, cyberint |
| EC-003 | <sensor_id>.sensor.toml already exists for this org | Skill warns "Sensor overlay already exists" and asks user to confirm overwrite before proceeding; does not silently overwrite |
| EC-004 | prism_describe does not show sensor after credential set | Skill reports failure: "Sensor <sensor_id> not visible in prism_describe for org <org_slug>. Check credential with: prism credential list --org-slug <org_slug>"; does NOT emit success |
| EC-005 | SELECT 1 query returns an error response | Skill reports connectivity failure with the raw error; suggests checking base_url, network access, and credential set success; does NOT emit success |
| EC-006 | User pastes credential value directly in chat (e.g., types "my-api-key is ABC123") | Skill immediately declines to process the credential value in any way and reminds the user of the piped-stdin pattern; does not echo or store the value |
| EC-007 | base_url is missing or empty | Skill prompts for base_url before writing sensor.toml; does not write a sensor.toml with an empty base_url |
| EC-008 | prism binary not found in PATH | Skill STOPS with error: "prism binary not found. Run /activate first to install and configure prism." |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `org_slug="acme-corp"` (registered), `sensor_id="crowdstrike"`, valid `base_url`, user runs credential command in terminal, `prism_describe` shows sensor, `SELECT 1` succeeds | `crowdstrike.sensor.toml` written; exact `echo\|prism credential set` command displayed; `prism_describe` verification passes; `SELECT 1` passes; success message emitted | happy-path |
| `org_slug="acme-corp"` not in prism.toml | Error: org not registered; onboard-customer required first | edge-case (EC-001) |
| `sensor_id="splunk"` (unsupported) | Error listing supported sensor IDs | edge-case (EC-002) |
| `prism_describe` does not show sensor after credential set | Failure reported; no success message; diagnostic instructions provided | edge-case (EC-004) |
| `SELECT 1` returns error response | Connectivity failure reported; no success message; troubleshooting guidance provided | edge-case (EC-005) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-054 | AD-017 compliance — the onboard-sensor SKILL.md text never contains a pattern requesting credential value paste in chat; only the piped-stdin `echo \| prism credential set` pattern is documented | integration / BATS (`@test "onboard-sensor AD-017 piped-stdin pattern documented in SKILL.md"`) |
| VP-SKILL-055 | SELECT 1 verification mandatory — the SKILL.md workflow step for SELECT 1 verification is present; success message section is gated after SELECT 1 step | integration / BATS (`@test "onboard-sensor has SELECT 1 verification step"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-LIFECYCLE-04 ("Add and verify a sensor overlay for an existing customer org") per handoff brief §2.3 |
| Capability Anchor Justification | CAP-LIFECYCLE-04 ("Add and verify a sensor overlay for an existing customer org") per handoff brief §2.3 — this BC describes exactly the onboard-sensor workflow that provisions a sensor overlay with AD-017-compliant credential setup, which is what CAP-LIFECYCLE-04 defines |
| L2 Domain Invariants | AD-017 (AI-opaque credentials — piped-stdin only, never in chat); D-DEC-005 (org_slug scoping key); architecture-delta.md C-28 (onboard-sensor-helpers credential-set.sh behavioral contract) |
| Architecture Module | C-2 (skill-procedures), C-28 (onboard-sensor-helpers: credential-set.sh/.ps1) |
| Related BCs | BC-6.01.003 (depends on — org must exist before sensor onboarding); BC-6.01.001 (depends on — prism binary required, activated first); BC-10.01.001 (depends on — monitoring-loop queries sensors registered here) |
| Architecture Anchors | architecture-delta.md §C-28 (onboard-sensor-helpers, credential-set pattern); architecture-delta.md §3 (external write surface: prism credential keyring); architecture-delta.md §D-DEC-007 (shell helper co-location under skills/onboard-sensor/) |
| Story Anchor | TBD (filled by story-writer) |
| VP Anchors | VP-SKILL-054, VP-SKILL-055 |

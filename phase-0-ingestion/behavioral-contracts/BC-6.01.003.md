---
document_type: behavioral-contract
level: L3
version: "1.3"
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
capability: CAP-LIFECYCLE-03
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
modified: ["v1.1-FV-PROPOSED-DROP-2026-07-20", "v1.2-ADV-F2-P10-009-per-org-jira-project-key-2026-07-22", "v1.3-ADV-F2-P11-005-mis-anchor-fix-2026-07-22"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-6.01.003: onboard-customer Skill — Org Slug / UUID Provisioning and prism.toml Registration

> **Revision history:**
> - v1.3 (2026-07-22): Pass-11 adversarial remediation — P11-005 (MINOR, mis-anchor fix). **Invariant #6 cross-reference corrected:** replaced the dead reference "BC-9.01.001 Precondition #9" (no such precondition exists — scan-threats has 4 preconditions, none related to jira_project_key) with the correct anchor "BC-6.01.001 Invariant #12 / EC-013" (activate skill's jira_project_key Stage-0 gate, which controls what happens when neither per-org nor global jira_project_key is present). ADV-F2-P11-005.
> - v1.2 (2026-07-22): Pass-10 adversarial remediation — P10-009 (MINOR) per-org `jira_project_key`. (1) **Postcondition #1:** `[[orgs]]` entry now optionally includes `jira_project_key` (string, overrides global `jira_project_key` for this org). The onboard-customer skill prompts for it optionally during org creation. (2) **Invariant #6 added (P10-009):** Per-org lookup order for `jira_project_key`: check `[[orgs]].jira_project_key` first (per-org override); if absent or empty, fall back to global `jira_project_key` from `[plugin_config]` or plugin state. This allows multi-tenant deployments where different orgs use different Jira projects. (3) **EC-009 added:** canonical behavior when user supplies a per-org `jira_project_key` during onboard-customer.
> - v1.0 (2026-07-20): Initial authoring for prism-integration cycle (v0.10.0). Source: handoff brief §2.3, architecture-delta.md §D-DEC-003/D-DEC-005, artifact-mapping.md §1.4 (BC-6.01.003 slot).
> - v1.1 (2026-07-20): FV-PROPOSED-DROP: VP-SKILL-052 and VP-SKILL-053 are now FINALIZED per verification-delta §1 — dropped `(PROPOSED)` qualifier from VP table rows and VP Anchors.

## Description

The `onboard-customer` skill creates a new customer org entry in the secops-factory
plugin configuration. It prompts for (or auto-generates) an org slug and UUID-v7,
appends an `[[orgs]]` entry to the shared `prism.toml`, creates the per-customer
directory skeleton under `<spec_dir>/customers/<org_slug>/`, and prints credential
provisioning instructions. The skill **never** asks the user to paste credentials
into chat (AD-017 invariant).

## Preconditions

1. The `onboard-customer` skill is invoked by the user via the `/onboard-customer`
   command. Confidence: inferred from CONV-001/002/003 (skill entry point).
2. The shared `prism.toml` is accessible at `<spec_dir>/prism.toml` and is
   syntactically valid TOML. Confidence: inferred from handoff brief §2.3.
3. The `<spec_dir>/customers/` directory is writable by the current process.
   Confidence: inferred from brief §2.3 directory creation requirement.
4. No org with the proposed `org_slug` is already present in `prism.toml`'s
   `[[orgs]]` list. (If one is present, see EC-003 — uniqueness gate.)
5. The skill announces itself before any other action ("I am using the
   onboard-customer skill…"). Confidence: structural requirement (CONV-008).

## Postconditions

1. A new `[[orgs]]` entry is appended to `prism.toml` with fields `org_slug` (the
   provided or confirmed slug), `uuid` (UUID-v7 format, auto-generated if not
   supplied), optionally `display_name`, and optionally `jira_project_key` (string —
   a per-org Jira project key override; if supplied, disposition-guard uses this value
   for `create-review` command_pattern org-binding for this org instead of the global
   key; if absent, the global `jira_project_key` from plugin state is used as fallback
   per Invariant #6 / P10-009). Confidence: inferred from brief §2.3; P10-009 addition.
2. The directory `<spec_dir>/customers/<org_slug>/` exists after the skill
   completes. If it already existed (idempotent path), it is not destroyed.
   Confidence: inferred from brief §2.3.
3. Credential provisioning instructions are printed to the user, directing them
   to run the `onboard-sensor` skill next. **No credential values are requested
   or printed during this step.** Confidence: AD-017 — see Invariant #1.
4. The skill does NOT write any MCP config files, does NOT set any credentials,
   and does NOT restart any services. Its scope is strictly `prism.toml` append
   plus directory creation. Confidence: inferred from brief §2.3 scope boundary.

## Invariants

1. **AD-017 — never ask credentials in chat.** The skill must never prompt the
   user to paste a credential value, API key, token, or secret into the chat
   interface. Credential provisioning is deferred to `onboard-sensor` (BC-6.01.004)
   using the AD-017 piped-stdin pattern. A future output containing a field like
   "enter your API key:" is a defect.
2. **org_slug uniqueness gate.** Before appending to `prism.toml`, the skill
   reads the existing `[[orgs]]` list and verifies no entry with the same
   `org_slug` exists. If a duplicate is found, the skill STOPS and reports the
   conflict to the user without modifying `prism.toml` (see EC-003).
3. **UUID-v7 format.** The `uuid` field in the appended `[[orgs]]` entry must
   conform to UUID v7 (time-ordered, RFC 9562). If the user supplies a UUID,
   the skill validates its format before accepting it. If no UUID is supplied,
   the skill auto-generates one.
4. **Announce at Start is unconditional.** The skill emits its announcement text
   before reading `prism.toml` or performing any file operation.
5. **No destructive writes.** Appending to `prism.toml` must not truncate or
   overwrite existing entries. The write is strictly additive (append TOML block).
6. **[NEW v1.2 — P10-009] Per-org `jira_project_key` lookup order.** The `[[orgs]]` entry
   MAY include an optional `jira_project_key` field that overrides the global key for that
   org. When disposition-guard (BC-3.03.001) builds a `create-review` or `create` command_pattern
   for a verdict from this org, the lookup order is:
   1. **Per-org key first:** `[[orgs]].jira_project_key` (if present and non-empty in
      `prism.toml` for the verdict's `org_slug`)
   2. **Global fallback:** `jira_project_key` from the global plugin state / `[plugin_config]`
      (set at activate time, BC-6.01.001)
   If neither is present, disposition-guard emits HARD-FLOOR-UNBINDABLE (per Invariant #10 of
   BC-10.01.001 and BC-6.01.001 Invariant #12 / EC-013). The onboard-customer skill MUST communicate
   this optional field to the user without requiring it. If the user provides a per-org key,
   the skill validates it is non-empty and contains only Jira-project-key safe characters
   (uppercase alphanumeric, hyphens) before writing it to the `[[orgs]]` entry.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | User does not supply a UUID | Skill auto-generates a valid UUID-v7 and displays it for user confirmation before writing |
| EC-002 | User supplies a UUID that is not valid UUID format | Skill rejects with error message specifying "UUID-v7 required (RFC 9562 time-ordered format)"; re-prompts |
| EC-003 | `org_slug` already exists in `prism.toml` | Skill STOPS with conflict message: "Org '<org_slug>' already registered in prism.toml. Use onboard-sensor to add sensors to this org." — does NOT modify prism.toml |
| EC-004 | `prism.toml` does not exist at the expected path | Skill reports the missing file and asks the user to confirm the `spec_dir` path before creating prism.toml from scratch with the new entry |
| EC-005 | `prism.toml` is not valid TOML (parse error) | Skill STOPS without modifying the file; reports the parse error and instructs user to fix manually |
| EC-006 | `<spec_dir>/customers/<org_slug>/` directory already exists | Skill proceeds without error; does NOT delete or overwrite existing directory contents (idempotent create) |
| EC-007 | org_slug contains characters that are not filesystem-safe (spaces, slashes, special chars) | Skill rejects with message specifying allowed characters (lowercase alphanumeric, hyphens, underscores); re-prompts |
| EC-008 | User attempts to enter a credential value during this skill | Skill explicitly declines: "Credential setup happens via onboard-sensor. I will not accept credentials here." |
| EC-009 | **[NEW v1.2 — P10-009]** User supplies `jira_project_key = "ACME"` for per-org override during onboard-customer | Skill appends `[[orgs]]` entry with `jira_project_key = "ACME"` alongside `org_slug`, `uuid`. Printed confirmation states: "Per-org Jira project key 'ACME' stored for org 'acme-corp'. This overrides the global jira_project_key for all disposition-guard create-review/create operations on this org. Global key is still used for orgs without a per-org override." |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Fresh `prism.toml`, valid `org_slug = "acme-corp"`, no UUID supplied | `[[orgs]]` entry appended with auto-generated UUID-v7; `customers/acme-corp/` directory created; provisioning instructions printed; no credentials requested | happy-path |
| `org_slug = "acme-corp"` but that org already exists in `prism.toml` | Conflict reported, prism.toml unchanged, skill exits without creating directory | edge-case (EC-003) |
| User supplies UUID `"not-a-uuid"` | Error: UUID-v7 format required; re-prompt | edge-case (EC-002) |
| `prism.toml` has invalid TOML syntax | Skill STOPS without writing; reports parse error | edge-case (EC-005) |
| `customers/acme-corp/` already exists | Skill reports directory already exists; appends [[orgs]] entry; does not delete existing directory | edge-case (EC-006) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-052 | UUID format validation — skill accepts only valid UUID-v7 format for the `uuid` field; rejects malformed UUIDs with re-prompt | integration / BATS (`@test "onboard-customer rejects invalid UUID format"`) |
| VP-SKILL-053 | Idempotent directory creation — re-running `onboard-customer` for an existing org_slug does not modify or delete the existing customers/<org_slug>/ directory | integration / BATS (`@test "onboard-customer does not overwrite existing customer directory"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-LIFECYCLE-03 ("Create and register a new customer org in the prism integration") per handoff brief §2.3 |
| Capability Anchor Justification | CAP-LIFECYCLE-03 ("Create and register a new customer org in the prism integration") per handoff brief §2.3 — this BC describes exactly the onboard-customer workflow that provisions a new org entry, which is what CAP-LIFECYCLE-03 defines |
| L2 Domain Invariants | AD-017 (AI-opaque credentials — never ask credentials in chat); D-DEC-005 (org_slug as the tenant-isolation key across all prism queries) |
| Architecture Module | C-2 (skill-procedures), C-30 (watermark-store — org_slug created here is the key for watermark paths later) |
| Related BCs | BC-6.01.001 (composes with — activate must run before onboard-customer); BC-6.01.004 (composes with — onboard-sensor runs after onboard-customer); BC-10.01.001 (depends on — monitoring-loop iterates over orgs registered here) |
| Architecture Anchors | architecture-delta.md §D-DEC-005 (org_slug scoping invariant); architecture-delta.md §3 (external write surface: prism config dir) |
| Story Anchor | TBD (filled by story-writer) |
| VP Anchors | VP-SKILL-052, VP-SKILL-053 |

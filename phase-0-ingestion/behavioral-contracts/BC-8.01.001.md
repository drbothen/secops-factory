---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/analyze-ticket-effort/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "8ba155c"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/analyze-ticket-effort/SKILL.md
subsystem: metrics-pipeline
capability: CAP-METRICS-01
lifecycle_status: active
introduced: v0.9.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-8.01.001: analyze-ticket-effort Skill — Session-Reconstruction Effort Measurement

> **Revision history:**
> - v1.0 (2026-07-19): Initial extraction from `skills/analyze-ticket-effort/SKILL.md` at v0.9.0 HEAD (DI-012 resolution, Step 0d extension).

## Preconditions

1. The `jr` CLI is installed and authenticated (`jr auth login`), and Python 3 is available on PATH. Confidence: verified by code analysis (`skills/analyze-ticket-effort/SKILL.md:Prerequisites`).
2. The skill announces itself verbatim before any other action: "I am using the analyze-ticket-effort skill to measure analyst effort and ticket volume from Jira event history." Confidence: verified by code analysis (`skills/analyze-ticket-effort/SKILL.md:Announce at Start`) and BATS test `@test "analyze-ticket-effort has Iron Law"` (skills.bats:363), `@test "metrics skills have Announce at Start and >= 6 Red Flag rows"` (skills.bats:379).
3. If `artifacts/metrics/effort-priors.yaml` exists, the skill loads `project_key`, `client_field`, and `exclusions` from it before running schema discovery — it does not re-discover known configuration from scratch when a priors file is present. Confidence: verified by code analysis (`skills/analyze-ticket-effort/SKILL.md:Stage 1` — "If the priors file exists, load project_key, client_field, exclusions from it").

## Postconditions

1. The deliverable written to `artifacts/metrics/effort-analysis-<date>.md` includes a mandatory known-biases section, verbatim per the Iron Law. Every burst-time figure in the deliverable is paired with a with-overhead figure, and the known-biases section explicitly names the biases (undercounts, overcounts, window sensitivity). Confidence: verified by code analysis (Iron Law: `NO EFFORT REPORT WITHOUT STATED BIASES FIRST`; `skills/analyze-ticket-effort/SKILL.md:Stage 4` — "known-biases section (mandatory, verbatim discipline)").
2. Per-client totals are cross-checked against the unfiltered project total. The gap (unattributed tickets not assigned to any client) is reported in the deliverable; it is never suppressed as "close enough." Confidence: verified by code analysis (`skills/analyze-ticket-effort/SKILL.md:Stage 2` — "Cross-check attributed sum vs unfiltered project total — report the gap"; Red Flag: "Always cross-check the sum of per-client counts against the unfiltered project total.").
3. Session reconstruction uses GAP=30min (inter-event gap threshold) and +5min/session overhead (from the canonical effort-analysis-method.md, or from customized priors if present). The reconstructed burst time is always labeled as a lower bound, not as total actual effort. Confidence: verified by code analysis (`skills/analyze-ticket-effort/SKILL.md:Stage 3`; `${CLAUDE_PLUGIN_ROOT}/data/effort-analysis-method.md` canonical anchors `GAP = 30 * 60`, `OVERHEAD_MIN = 5`; BATS test `@test "method doc contains the session-reconstruction anchors"` skills.bats:398).
4. Results (client names, volumes, effort figures) are written to local `artifacts/metrics/` only — they are never included in PR descriptions, commit messages, or any artifact that leaves the local machine. Confidence: verified by code analysis (Red Flag: "Sensitive. Results go to local artifacts/ only." in `skills/analyze-ticket-effort/SKILL.md:Red Flags`).

## Invariants

1. Empty worklogs are not grounds for reporting "effort cannot be measured." The session-reconstruction method is authoritative for effort when worklogs are empty; this is the explicit purpose of the skill. Confidence: verified by code analysis (Red Flag: "'Worklogs are empty, so effort can't be measured' — That's the point of this skill").
2. No effort figure appears in the deliverable without its paired with-overhead figure and the known-biases statement. An effort number without biases is explicitly how a lower bound becomes a misused budget (Iron Law rationale). Confidence: verified by code analysis (Iron Law text verbatim; Red Flag: "Burst time IS the effort" → "Burst time is a lower bound. Always add per-session overhead and say so.").
3. Monthly trend analysis must report R² alongside any declared slope. A slope is not declared a positive or negative trend unless R² and the ranging rule support it (R² < 0.3 = ranging; single-client artifacts or ramp months must be excluded before declaring a trend). Confidence: verified by code analysis (`skills/analyze-ticket-effort/SKILL.md:Stage 2` — "slope, R²—apply the ranging rule"; Red Flag: "Check R² first (<0.3 = ranging), exclude ramp months, and look for single-client artifacts before declaring a trend.").

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Worklogs are empty | Proceed with session reconstruction from event timestamps (creation, field edits, comments); never report "cannot measure" |
| EC-002 | `--window 30d` (short window) | Complete analysis; note in deliverable that 30-day window is insufficient for rate-setting (Red Flag); recommend ≥6-12 months |
| EC-003 | Client custom field queried by display name | Must use `cf[NNNNN] = "Label"` JQL syntax (object field); re-run schema discovery if unsure; Red Flag violation to guess |
| EC-004 | Attributed per-client totals do not sum to project total | Report the gap as unattributed tickets; do not suppress or round away the discrepancy |
| EC-005 | `--sample` flag limits fetch size | Fetch loop is background-resumable with `[ -s ]` guards; do not fetch all tickets in foreground when volume is large |
| EC-006 | Monthly slope looks like a decline | Report R² first; if R² < 0.3, classify as ranging (not a trend); exclude ramp months and single-client artifacts |
| EC-007 | `effort-priors.yaml` contains prior baselines | Compare new measurements against priors; flag drifts > 25%; offer to update priors file |
| EC-008 | Analysis complete; user asks to include client names in a PR | Decline; client names and volumes are sensitive and must stay in local artifacts/ only (Red Flag) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| SEC project, 180d window, all clients, no priors file | Schema discovery → JQL per client → cross-check gap → session reconstruction → effort-analysis-YYYY-MM-DD.md with biases section | happy-path |
| Same as above with empty worklogs for all tickets | Session reconstruction from event timestamps; burst time reported as lower bound with overhead | happy-path (EC-001) |
| `--window 30d` flag | Analysis completes; deliverable notes 30-day window caveat; 30d figures not used for rate-setting | edge-case (EC-002) |
| `--client "ACME Corp"` | Filter JQL to one client; cross-check vs project total still required; report unattributed gap | happy-path (single client) |
| R² = 0.15 on monthly slope | Classified as ranging; slope not declared a trend; deliverable notes ranging rule applied | edge-case (EC-006) |
| New measurement drifts > 25% from priors | Flag drift in deliverable; offer to update effort-priors.yaml | edge-case (EC-007) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-041 | Iron Law text "NO EFFORT REPORT WITHOUT STATED BIASES FIRST" is present in SKILL.md verbatim | integration / BATS (`@test "analyze-ticket-effort has Iron Law"` skills.bats:363) |
| VP-SKILL-042 | Announce at Start section and >= 6 Red Flag rows are present | integration / BATS (`@test "metrics skills have Announce at Start and >= 6 Red Flag rows"` skills.bats:379) |
| VP-SKILL-043 | Canonical method doc (`data/effort-analysis-method.md`) is referenced in SKILL.md | integration / BATS (`@test "metrics skills reference the canonical method doc"` skills.bats:387) |
| VP-SKILL-044 | `data/effort-analysis-method.md` and `templates/effort-priors-tmpl.yaml` exist on disk | integration / BATS (`@test "effort-analysis method doc and priors template exist"` skills.bats:393) |
| VP-SKILL-045 | Method doc contains session-reconstruction anchors (GAP, OVERHEAD_MIN, adf_text) | integration / BATS (`@test "method doc contains the session-reconstruction anchors"` skills.bats:398) |
| VP-SKILL-046 | Deliverable includes the known-biases section (mandatory verbatim discipline per Iron Law) | manual / specification (structural-only; no executable behavioral test confirms LLM includes biases at runtime) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-METRICS-01 |
| L2 Domain Invariants | Iron Law: NO EFFORT REPORT WITHOUT STATED BIASES FIRST |
| Architecture Module | C-2 (skill-procedures), C-9 (metrics-analyst-agent Quinn), C-19 (knowledge-bases: effort-analysis-method.md, jira-metrics-recipes.md) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/analyze-ticket-effort/SKILL.md` (78 lines) |
| **Confidence** | medium — 4-stage workflow, session-reconstruction parameters, bias-pairing discipline, and sensitivity rules explicitly documented; Iron Law, Announce at Start, Red Flags, canonical method doc reference, and method doc anchors all structurally verified by BATS (5 @tests); no executable behavioral test confirms the LLM applies bias pairing or GAP=30min at runtime (structural-only) |
| **Extraction Date** | 2026-07-19 |
| **Last Verified Against** | v0.9.0 HEAD (commit d304fa5) |

#### Evidence Types Used

- **documentation**: 4-stage workflow (schema discovery → volume baseline → effort measurement → deliverable); session reconstruction parameters (GAP=30min, +5min/session overhead); sensitivity rules (R²/ranging, window adequacy); cross-check requirement (attributed vs unfiltered)
- **guard clause**: Iron Law statement (SKILL.md:13) + Red Flags table (SKILL.md:24-32) document 8 forbidden shortcuts including treating burst time as total effort, short sampling windows, and publishing sensitive client data
- **type constraint**: explicit session-reconstruction constants (GAP, OVERHEAD_MIN) are anchored in the canonical method doc and verified by BATS
- **inferred**: `effort-priors.yaml` priors comparison and 25% drift flag are documented behavior; no BATS test validates the drift threshold itself

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads Jira (jr CLI — changelog, comments, view), reads effort-priors.yaml (filesystem), writes effort-analysis-YYYY-MM-DD.md (filesystem), runs Python 3 stdlib for session reconstruction statistics |
| **Global state access** | none |
| **Deterministic** | no — depends on live Jira ticket event history and query results |
| **Thread safety** | not applicable (LLM-executed sequential skill with background fetch loop) |
| **Overall classification** | effectful shell |

#### Refactoring Notes

The session-reconstruction algorithm (GAP-based session boundary detection and per-session overhead addition) is a pure function of the event timestamp list. Given the same list of timestamps plus the GAP and OVERHEAD_MIN constants, the reconstructed session count and burst time are deterministic. This sub-function is extractable as a pure-core Python module amenable to property-based testing (`hypothesis`/`proptest`): verify monotonicity (more events → more or equal sessions), verify GAP sensitivity, verify overhead scaling.

The effectful parts (Jira fetch loop, filesystem I/O) are strictly separated from the statistics computation. The background-fetch loop (`[ -s ]` guards for resumability) is a well-scoped effectful shell pattern.

Holdout scenarios for this BC are a follow-up item (product-owner).

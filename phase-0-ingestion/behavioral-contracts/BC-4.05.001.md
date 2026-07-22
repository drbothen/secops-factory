---
document_type: behavioral-contract
level: L3
version: "1.4"
status: draft
producer: product-owner
timestamp: 2026-07-20T00:00:00
phase: f2
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/assess-priority/SKILL.md, plugins/secops-factory/tests/skills.bats, phase-f2-spec-evolution/architecture-delta.md]
input-hash: "COMPUTE-AT-COMMIT"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/assess-priority/SKILL.md
subsystem: vulnerability-pipeline
capability: CAP-VULN-01
lifecycle_status: active
introduced: v0.9.0
modified: ["v1.1-PRISM-SCORING-2026-07-20", "v1.2-ADV-F2-P3-008-004-2026-07-20", "v1.3-FV-VP-070-071-FINALIZED-2026-07-20", "v1.4-ADV-F2-P12-004-priority-to-scored-priority-mapping-2026-07-22"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-4.05.001: assess-priority Skill — Prism-Grounded Vulnerability Priority Calculation

> **Revision history:**
> - v1.4 (2026-07-22): Pass-12 adversarial remediation — P12-004 (MAJOR, producer/consumer coherence gap). **Invariant #5 added:** assess-priority's `priority` output field IS verdict field 18 `scored_priority`. The monitoring-loop (BC-10.01.001) reads this skill's output as verdict field 18 `scored_priority` (P11-002), but no BC had previously documented the producer→consumer field mapping explicitly, creating a coherence gap where an implementation could emit `priority` without knowing it becomes `scored_priority`. Invariant #5 closes this gap: the `priority` key in PC#6 output IS the value that populates field 18 in the ICD-203 verdict. Also documents fast-path behavior: when Stage 5 is bypassed (known-FP fast-path), this skill is not invoked and `scored_priority` is derived by SEVERITY_TO_SCORED_PRIORITY_MAP — P12-003. ADV-F2-P12-004.
> - v1.3 (2026-07-20): FV-VP-070-071-FINALIZED: [Job 1] (1) VP-SKILL-070 PROPOSED → FINALIZED (Invariant #4 + VP table row; strategy confirmed: static PC#5a/5b/5d WHERE-clause assertion + prism-DTU multi-org org-a-returns-zero-org-b/c fixture + unscoped-query adversarial leg; verification-delta.md v1.3 §7 Part D). (2) VP-SKILL-071 ADDED as new VP-table row + PC#6 VP anchor (confidence float→enum mapping guard, D-DEC-011 thresholds 0.75/0.40; boundary test: 0.75→high, 0.749→medium, 0.40→medium, 0.399→low; inconsistent pair invalid; verification-delta.md v1.3 §7 Part D).
> - v1.2 (2026-07-20): ADV-F2-P3-008/P3-004: (1) [P3-008 MEDIUM] PC#6 prism-grounded output format updated to emit BOTH `confidence_score` (float 0.0–1.0) AND `confidence` (enum high|medium|low) per D-DEC-011 thresholds (high ≥ 0.75, medium ≥ 0.40 & < 0.75, low < 0.40); the monitoring-loop uses the enum for verdict field #2; previous output had `confidence: 0.0-1.0` (float only) which failed the enum contract. (2) [P3-004 MAJOR] Invariant #4 org_slug scoping: added VP-SKILL-070 cross-reference as PROPOSED (formal-verifier finalizes scope and BATS fixture); VP-SKILL-070 row added to Verification Properties table.
> - v1.0 (2026-07-19): Initial extraction from `skills/assess-priority/SKILL.md` at v0.9.0 HEAD (DI-012 resolution, Step 0d extension).
> - v1.1 (2026-07-20): PRISM-SCORING: **UPDATED** — Added prism-grounded scoring layer on top of existing 6-factor algorithm: (1) 30-day historical baseline query via prism, (2) `enrich_nvd()` UDF for CVSS when CVE present, (3) rule-fidelity recalibration from historical TP/FP rates, (4) per-tenant asset criticality weights from prism, (5) Bayesian TP/FP/BTP disposition framework. New output format when prism available: `{priority: CRIT/HIGH/MED/LOW, confidence: 0.0-1.0, disposition: TP|FP|BTP|Indeterminate, rationale: "..."}`. Degradation path when prism unavailable (falls back to existing 6-factor, sets `uncertainty_explicit: true`). KEV unconditional CRIT override and Iron Law unchanged. EC-009..EC-012 added.

## Preconditions

1. At least one vulnerability data input is present (`cvss_score`, `epss_score`, `kev_status`, `exploit_status`), OR each missing value defaults per the Input Requirements section: `cvss_score` defaults to 0.0, `epss_score` defaults to 0.0, `kev_status` defaults to "Not Listed". Missing inputs do not block execution; they lower the score and may trigger a bias warning. Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Input Requirements`).
2. The system context inputs (`acr_rating` and `exposure`) are either provided by the caller or elicited interactively from the user before scoring begins; the skill never skips ACR by silently assuming a value without disclosure. Confidence: verified by code analysis (Red Flag: "Prompt the user or use conservative default (Medium). Never skip." in `skills/assess-priority/SKILL.md:Red Flags`).
3. The skill announces itself verbatim before any other action: "I am using the assess-priority skill to calculate multi-factor priority for \<ticket-id\>." Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Announce at Start`) and BATS test `@test "assess-priority has Announce at Start"` (skills.bats:39).
4. **[NEW v1.1]** Prism MCP availability is checked via `prism_describe` at the start of execution. If prism is available, prism-grounded scoring is applied (postconditions #5–#7). If prism is unavailable (connection error, timeout, or `prism_describe` returns error), the skill falls back to the existing 6-factor algorithm (postconditions #1–#4) and sets `uncertainty_explicit: true` in the output (EC-009).

## Postconditions

1. **[Preserved v1.0]** The output includes all of: (a) per-factor breakdown with score, (b) total score in the 0-24 range, (c) priority level, (d) SLA deadline associated with that level, and (e) rationale. Priority is never assigned without all six factors being assessed. Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Output`).
2. **[Preserved v1.0]** If the total score is >= 20 OR `kev_status` is "Listed", the assigned priority is the highest level (CRIT when prism available; P1 in degraded mode) regardless of individual factor scores. The KEV threshold is applied as an unconditional override (not as an additive score). Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Priority Mapping` — ">=20 or KEV Listed → P1 - Critical, 24 hours").
3. **[Preserved v1.0]** Any applicable override rule (KEV Listed + Internet + Critical ACR = automatic highest priority; Active Exploitation + CVSS >=9.0 + High/Critical ACR = automatic highest priority; compliance requirement = +1 level; documented compensating controls = −1 level) is explicitly noted in the rationale alongside the base score, so the examiner can distinguish base-score priority from override-adjusted priority. Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Override Rules`).
4. **[Preserved v1.0]** When EPSS data is unavailable, the skill defaults EPSS to 0.0 and includes an explicit "INCOMPLETE DATA" warning in the output — it never silently omits EPSS or treats its absence as equivalent to a zero-risk score without flagging. Confidence: verified by code analysis (Red Flag: "Flag as INCOMPLETE DATA. Default EPSS to 0.0 with warning." in `skills/assess-priority/SKILL.md:Red Flags`).

5. **[NEW v1.1] Prism-grounded scoring stages (when prism available):**

   When prism MCP is available (Precondition #4), the following additional scoring stages are applied AFTER the existing 6-factor base score:

   - **PC#5a — 30-day historical baseline query:** Query prism for detection frequency of this rule over the past 30 days:
     ```sql
     SELECT COUNT(*) AS hit_count,
            COUNT(DISTINCT CASE WHEN disposition='TP' THEN event_id END) AS tp_count,
            COUNT(DISTINCT CASE WHEN disposition='FP' THEN event_id END) AS fp_count
     FROM events
     WHERE org_slug='<org_slug>'
       AND rule_id='<rule_id>'
       AND timestamp > NOW() - INTERVAL '30 days'
     ```
     Result informs rule-fidelity recalibration (PC#5c). D-DEC-005: explicit `org_slug` constraint required (Invariant #4).

   - **PC#5b — NVD enrichment via `enrich_nvd()` UDF:** If a CVE identifier is present, call `SELECT enrich_nvd('<cve_id>') AS nvd_data`. If the NVD CVSS differs from the input CVSS by > 1.0, update the CVSS factor score accordingly and note the discrepancy in rationale.

   - **PC#5c — Rule-fidelity recalibration:** Compute fidelity = tp_count / (tp_count + fp_count) when denominator > 0. If fidelity < 0.3, recalibrate exploit_status factor score down by 1 point (floor 0). If fidelity > 0.8, recalibrate up by 1 point (ceiling 4). If hit_count == 0, note as new signal with no fidelity data and skip recalibration.

   - **PC#5d — Per-tenant asset criticality weights:** Query `SELECT asset_criticality_score FROM assets WHERE org_slug='<org_slug>' AND asset_id='<asset_id>'` and substitute into the ACR factor. If asset not found in prism, fall back to user-supplied or default ACR.

   - **PC#5e — Bayesian TP/FP/BTP disposition estimate:** After all factors are scored (including recalibration), apply a Bayesian prior derived from the 30-day TP/FP counts to produce an advisory disposition estimate. Output: `{disposition: "TP"|"FP"|"BTP"|"Indeterminate", posterior_probability: 0.0-1.0}`. Indeterminate when posterior < 0.55 or insufficient data (hit_count < 5). The disposition estimate is ADVISORY — it does not replace the analyst's investigation.

6. **[NEW v1.1] Prism-grounded output format:**

   When prism is available, the output format is:
   ```
   {
     "priority": "CRIT" | "HIGH" | "MED" | "LOW",
     "confidence_score": 0.0-1.0,
     "confidence": "high" | "medium" | "low",
     "disposition": "TP" | "FP" | "BTP" | "Indeterminate",
     "rationale": "<explanation of base score + recalibration + overrides>",
     "base_score": 0-24,
     "prism_enriched": true,
     "uncertainty_explicit": false
   }
   ```
   The `confidence_score` float (0.0–1.0) is the raw Bayesian posterior probability from PC#5e. The `confidence` enum is derived from `confidence_score` via D-DEC-011 canonical thresholds: `high` when `confidence_score >= 0.75`; `medium` when `0.40 <= confidence_score < 0.75`; `low` when `confidence_score < 0.40`. The monitoring-loop uses the `confidence` enum for verdict field #2 (BC-10.01.001 Invariant #9 field #2 is ENUM-ONLY per D-DEC-011). Both fields are emitted so downstream consumers can access either the raw float or the categorical enum without re-computing.

   Priority mapping from adjusted score:
   - CRIT: score >= 20 OR KEV Listed (24-hour SLA)
   - HIGH: score 14-19 (7-day SLA)
   - MED: score 8-13 (30-day SLA)
   - LOW: score < 8 (90-day SLA)

   > **Previous (v1.1):** Output had `"confidence": 0.0-1.0` (float only). This failed the enum contract required by BC-10.01.001 Invariant #9 field #2 and disposition-guard's jq type assertion. ADV-F2-P3-008 MEDIUM fix: emit BOTH `confidence_score` (float) AND `confidence` (enum) per D-DEC-011 thresholds.

   > **Previous (v1.0):** Output used P1-P5 priority labels only. Prism-enriched output introduces CRIT/HIGH/MED/LOW labels with confidence and disposition fields added. Degraded-mode output retains P1-P5 labels for backward compatibility.

   **Verification property (FINALIZED v1.3):** VP-SKILL-071 — confidence float→enum consistency: for every `confidence_score` float output, the paired `confidence` enum matches the D-DEC-011 canonical thresholds (`high` iff `confidence_score ≥ 0.75`, `medium` iff `0.40 ≤ confidence_score < 0.75`, `low` iff `confidence_score < 0.40`; boundary values 0.75 and 0.40 map to the higher tier); an inconsistent pair is invalid; the enum is always one of `{high, medium, low}`, never a float. This is the producer-side guarantee complementing VP-HOOK-025's disposition-guard enum type-assertion. FINALIZED per verification-delta.md v1.3 §7 Part D.

7. **[NEW v1.1] Degradation path when prism unavailable:**

   If prism MCP is unavailable (Precondition #4 check fails), the skill executes the existing 6-factor algorithm (postconditions #1–#4) unchanged, uses P1-P5 priority labels, and sets `uncertainty_explicit: true` with message "Prism unavailable — historical baseline and asset criticality not applied; result reflects static 6-factor scoring only". The skill does NOT abort; degraded mode is a first-class execution path.

## Invariants

1. **[Preserved v1.0]** The 6-factor scoring algorithm is always applied before any priority assignment; single-source severity is never the final answer. A CVSS 9.8 with low EPSS, no KEV, and isolated exposure produces MED/P4 (score ≈ 7-9), not CRIT/P1. Confidence: verified by code analysis (Iron Law: `NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST`; Red Flag: "CVSS alone is severity, not risk").
2. **[Preserved v1.0]** The factor-to-score mapping is a deterministic lookup table, not an LLM judgment call. Factor scores (0-4 pts each, KEV 0/5 pts) are produced by pure range comparison against fixed thresholds; the arithmetic is reproducible given the same inputs. Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:6-Factor Calculation` table).
3. **[Preserved v1.0]** Compensating controls reduce priority by exactly one level only when the controls are documented AND tested; assumed controls (without documentation or testing evidence) cannot be used to lower priority. Confidence: verified by code analysis (Red Flag: "Only reduce if controls are documented AND tested. Not assumed."; Override Rules).
4. **[NEW v1.1]** All PrismQL queries MUST include an explicit `org_slug` constraint in the WHERE clause (D-DEC-005). Omitting `org_slug` is a hard invariant violation. If `org_slug` is not available from execution context, all prism-grounded scoring stages are skipped entirely and the skill falls back to degraded mode (Precondition #4 degradation path). Confidence: D-DEC-005 binding decision (architecture-delta.md v1.1).

   **Verification property (ADV-F2-P3-004, FINALIZED):** VP-SKILL-070 — assess-priority PrismQL queries (PC#5a, PC#5b, PC#5d) always include org_slug WHERE clause; strategy: static WHERE-clause assertion on PC#5a/5b/5d PrismQL blocks + prism-DTU multi-org org-a-returns-zero-org-b/c fixture + unscoped-query adversarial leg. FINALIZED per verification-delta.md v1.3 §7 Part D.

5. **[NEW v1.4 — P12-004] `priority` output IS verdict field 18 `scored_priority` (producer/consumer coherence).** The `priority` key in PC#6 output (`{"priority": "CRIT"|"HIGH"|"MED"|"LOW", ...}`) is the **authoritative producer** of verdict field 18 `scored_priority` as consumed by BC-10.01.001 Invariant #9 field 18 (P11-002). When the monitoring-loop writes the ICD-203 verdict, the `scored_priority` key (field 18) is populated **directly from this skill's `priority` output** — no intermediate rename, adapter, or re-derivation is applied. The two tokens (`priority` here; `scored_priority` in the verdict) are semantically identical and carry the same enum `{CRIT, HIGH, MED, LOW}`.

   This mapping MUST be explicit in any monitoring-loop implementation. An implementation that derives `scored_priority` independently (re-running scoring logic after this skill) or renames the field without a documented mapping is non-conformant.

   Disposition-guard validates `scored_priority` membership in `SCORED_PRIORITY_ENUM = {CRIT, HIGH, MED, LOW}` via `validate_enums()` (BC-3.03.001); any non-member token (e.g., `CRITICAL`, `MEDIUM`, from a raw NORMALIZE_SEVERITY assignment) → SEVERITY-MISMATCH DENY.

   **Fast-path note (Stage 5 bypassed, P12-003):** On the known-FP fast-path in the monitoring-loop (BC-10.01.001 EC-009), this skill is NOT invoked. In that case, the monitoring-loop derives `scored_priority` directly from NORMALIZE_SEVERITY output mapped through `SEVERITY_TO_SCORED_PRIORITY_MAP` (CRITICAL→CRIT, MEDIUM→MED, HIGH→HIGH, LOW→LOW) — NOT a raw assignment. When Stage 5 runs normally (non-fast-path), this skill is the sole producer of `scored_priority`.

   Confidence: P12-004 producer/consumer coherence gap closure (architecture-delta.md v1.15 §8.26 item D). Cites P11-002 (scored_priority field 18 definition), BC-10.01.001 Invariant #9 field 18, P12-003 (SEVERITY_TO_SCORED_PRIORITY_MAP).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | CVSS 9.8, EPSS 0.02, KEV Not Listed, Theoretical exploit, Medium ACR, Isolated | Score = 4+1+0+2+1+1 = 9 → MED/P4 (Low, 90 days). Demonstrates Iron Law: vendor-Critical CVSS ≠ CRIT/P1 without multi-factor context. |
| EC-002 | Any ticket with KEV Listed, regardless of other scores | Priority = CRIT/P1, 24-hour SLA. KEV Listed triggers CRIT/P1 via Priority Mapping unconditionally. |
| EC-003 | Missing EPSS data | Default EPSS to 0.0, continue scoring, include "INCOMPLETE DATA" warning in rationale. |
| EC-004 | Missing ACR data | Prompt user; if no response, use conservative default "Medium" (2 pts) and note the assumption. Never skip. |
| EC-005 | Compensating controls claimed but not documented | Controls are disregarded; priority is not reduced. Red Flag violation if reduced without documentation evidence. |
| EC-006 | KEV Listed + Internet + Critical ACR (Override Rule 1) | Automatic CRIT/P1 regardless of raw score. Override Rule applies even if the score alone would yield HIGH/MED or P2/P3. |
| EC-007 | Compliance requirement identified | Priority elevated +1 level from the base-score result (e.g., MED → HIGH, P3 → P2). |
| EC-008 | Vendor assessment says "High priority" | Vendor assessment is treated as one data input; the 6-factor algorithm runs independently and produces its own priority. Red Flag violation to use vendor assessment as final output. |
| EC-009 | Prism MCP unavailable (connection error, timeout, prism_describe error) | Fall back to existing 6-factor algorithm (P1-P5 labels); set `uncertainty_explicit: true`; do not abort. Output includes "Prism unavailable" note in rationale. |
| EC-010 | `enrich_nvd()` UDF returns no data for CVE ID | Use caller-supplied CVSS; note "NVD enrichment not available for <cve_id>" in rationale. Continue scoring. |
| EC-011 | 30-day historical baseline returns zero events (first occurrence of this rule) | Note "New signal — no fidelity data" in rationale; no recalibration applied; base 6-factor score unchanged. |
| EC-012 | Asset not found in prism assets table for ACR lookup | Fall back to user-supplied or interactive ACR; note "Asset not found in prism — ACR from user input" in rationale. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| CVSS 9.8, EPSS 0.02, KEV Not Listed, Theoretical, Medium ACR, Isolated (no prism) | Score=9 → P4, 90 days SLA, `uncertainty_explicit: false` | happy-path (Iron Law demonstration, 6-factor) |
| CVSS 9.8, EPSS 0.02, KEV Not Listed, Theoretical, Medium ACR, Isolated, prism available, hit_count=50 tp_count=12 fp_count=38 | Base score=9; fidelity=0.24 (< 0.3) → exploit_status recalibrated -1 → adjusted=8; priority=MED | happy-path (prism recalibration) |
| CVSS 7.5, EPSS 0.80, KEV Not Listed, Public Exploit, High ACR, Internet, prism available, fidelity=0.82 | Score=16; fidelity > 0.8 → exploit_status +1 → adjusted=17 → priority=HIGH, 7 days | happy-path |
| Any input, KEV Listed | CRIT, 24 hours, unconditional | override-rule |
| EPSS unavailable | INCOMPLETE DATA warning, EPSS defaulted to 0.0, scoring continues | edge-case |
| ACR unknown, no user response | Conservative default Medium (2 pts) used; assumption noted | edge-case |
| Vendor says Critical; CVSS 9.0, EPSS 0.01, no KEV, Theoretical, Low ACR, Isolated | Score=4+1+0+1+1+1=8 → MED/P4; vendor assessment noted but overridden | edge-case (EC-008) |
| Prism unavailable | 6-factor algorithm; `uncertainty_explicit: true`; P1-P5 labels | edge-case (EC-009) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-029 | Iron Law text "NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST" is present in SKILL.md verbatim | integration / BATS (`@test "assess-priority has Iron Law"` skills.bats:13) |
| VP-SKILL-030 | Announce at Start section is present in SKILL.md | integration / BATS (`@test "assess-priority has Announce at Start"` skills.bats:39) |
| VP-SKILL-031 | Red Flags table has >= 6 rows | integration / BATS (`@test "assess-priority has >= 6 Red Flag rows"` skills.bats:66) |
| VP-SKILL-032 | Data references use `${CLAUDE_PLUGIN_ROOT}/data/` prefix (not hardcoded paths) | integration / BATS (`@test "data references use CLAUDE_PLUGIN_ROOT variable"` skills.bats:101) |
| VP-SKILL-033 | 6-factor scoring produces a score in the 0-24 range for all valid inputs | manual / property-based (pure arithmetic, no I/O) |
| VP-SKILL-034 | KEV Listed status always yields CRIT/P1, independent of point score | manual / specification |
| VP-SKILL-070 | org_slug scoping: every assess-priority PrismQL query (PC#5a 30-day baseline, PC#5b NVD enrichment, PC#5d asset criticality) includes an explicit org_slug WHERE clause; unscoped queries rejected; org-a query returns zero org-b/c rows in DTU multi-org fixture (Invariant #4). FINALIZED per verification-delta.md v1.3 §7 Part D. | integration / BATS (`@test "assess-priority PrismQL query always includes org_slug WHERE clause"`, `@test "assess-priority rejects unscoped PrismQL query"`, `@test "assess-priority org-a query returns zero org-b and org-c rows in multi-org DTU fixture"`) |
| VP-SKILL-071 | confidence float→enum consistency (PC#6 / D-DEC-011): for every `confidence_score` float output, the paired `confidence` enum matches D-DEC-011 thresholds (high ≥ 0.75, medium ≥ 0.40 & < 0.75, low < 0.40); boundary values 0.75 and 0.40 map to the higher tier; inconsistent pair (e.g. confidence_score=0.85 with confidence='low') is flagged invalid; enum is always one of {high, medium, low}, never a float. FINALIZED per verification-delta.md v1.3 §7 Part D. | integration / BATS (boundary/property: `@test "assess-priority confidence_score 0.75 maps to enum high"`, `@test "assess-priority confidence_score 0.749 maps to enum medium"`, `@test "assess-priority confidence_score 0.40 maps to enum medium"`, `@test "assess-priority confidence_score 0.399 maps to enum low"`, `@test "assess-priority inconsistent confidence pair flagged invalid"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-VULN-01 |
| L2 Domain Invariants | Iron Law: NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST |
| Architecture Module | C-2 (skill-procedures); invoked as sub-skill by enrich-ticket Stage 6; C-25 (prism-mcp consumer) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/assess-priority/SKILL.md` (88 lines) |
| **Confidence** | medium — 6-factor scoring algorithm, override rules, and input defaults explicitly documented; Iron Law, Announce at Start, and Red Flags structurally verified by BATS; prism-grounded additions (v1.1) specified by architecture-delta.md v1.1 (D-DEC-001, D-DEC-005) and brief §2.4/§3.5; not yet in source code |
| **Extraction Date** | 2026-07-20 |
| **Last Verified Against** | v0.9.0 HEAD (commit d304fa5); prism additions D-DEC spec |

#### Evidence Types Used

- **documentation**: 6-factor scoring table with ranges and point values; Priority Mapping table (P1-P5 / CRIT/HIGH/MED/LOW with SLA); Override Rules list; Input Requirements with explicit defaults
- **guard clause**: Iron Law statement (SKILL.md:13) + Red Flags table (SKILL.md:24-33) document forbidden shortcuts
- **type constraint**: all six factor inputs have documented ranges
- **assertion**: Announce at Start is a pre-action invariant enforced by structural discipline
- **D-DEC-005 binding decision**: org_slug constraint requirement for all PrismQL queries (Invariant #4)
- **architecture-delta.md v1.1**: prism-grounded scoring additions (PC#5a–PC#5e)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | 6-factor path: none; prism-grounded path: reads prism via MCP (`mcp__prism__query`, `enrich_nvd()` UDF) |
| **Global state access** | none |
| **Deterministic** | 6-factor path: yes; prism-grounded path: deterministic given same prism state |
| **Thread safety** | not applicable (LLM-executed sequential skill) |
| **Overall classification** | pure core (6-factor scoring sub-function); effectful shell when prism-grounded path active |

#### Refactoring Notes

The 6-factor scoring algorithm remains the natural pure core. The prism-grounded recalibration (PC#5c) and Bayesian disposition estimate (PC#5e) are also pure functions given their inputs. The prism MCP calls (PC#5a, PC#5b, PC#5d) are the effectful boundary — they should be wrapped in a single evidence-collection stage stubbable for testing. All fallback logic (degraded mode) should be tested via injection of a mock prism-unavailable error.

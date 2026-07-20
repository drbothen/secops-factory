---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/assess-priority/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "edd2b96"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/assess-priority/SKILL.md
subsystem: vulnerability-pipeline
capability: CAP-VULN-01
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

# Behavioral Contract BC-4.05.001: assess-priority Skill — 6-Factor Vulnerability Priority Calculation

> **Revision history:**
> - v1.0 (2026-07-19): Initial extraction from `skills/assess-priority/SKILL.md` at v0.9.0 HEAD (DI-012 resolution, Step 0d extension).

## Preconditions

1. At least one vulnerability data input is present (`cvss_score`, `epss_score`, `kev_status`, `exploit_status`), OR each missing value defaults per the Input Requirements section: `cvss_score` defaults to 0.0, `epss_score` defaults to 0.0, `kev_status` defaults to "Not Listed". Missing inputs do not block execution; they lower the score and may trigger a bias warning. Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Input Requirements`).
2. The system context inputs (`acr_rating` and `exposure`) are either provided by the caller or elicited interactively from the user before scoring begins; the skill never skips ACR by silently assuming a value without disclosure. Confidence: verified by code analysis (Red Flag: "Prompt the user or use conservative default (Medium). Never skip." in `skills/assess-priority/SKILL.md:Red Flags`).
3. The skill announces itself verbatim before any other action: "I am using the assess-priority skill to calculate multi-factor priority for \<ticket-id\>." Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Announce at Start`) and BATS test `@test "assess-priority has Announce at Start"` (skills.bats:39).

## Postconditions

1. The output includes all of: (a) per-factor breakdown with score, (b) total score in the 0-24 range, (c) priority level P1-P5, (d) SLA deadline associated with that level, and (e) rationale. Priority is never assigned without all six factors being assessed. Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Output`).
2. If the total score is >= 20 OR `kev_status` is "Listed", the assigned priority is P1 regardless of individual factor scores. The KEV threshold is applied as an unconditional override (not as an additive score). Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Priority Mapping` — ">=20 or KEV Listed → P1 - Critical, 24 hours").
3. Any applicable override rule (KEV Listed + Internet + Critical ACR = automatic P1; Active Exploitation + CVSS >=9.0 + High/Critical ACR = automatic P1; compliance requirement = +1 level; documented compensating controls = −1 level) is explicitly noted in the rationale alongside the base score, so the examiner can distinguish base-score priority from override-adjusted priority. Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:Override Rules`).
4. When EPSS data is unavailable, the skill defaults EPSS to 0.0 and includes an explicit "INCOMPLETE DATA" warning in the output — it never silently omits EPSS or treats its absence as equivalent to a zero-risk score without flagging. Confidence: verified by code analysis (Red Flag: "Flag as INCOMPLETE DATA. Default EPSS to 0.0 with warning." in `skills/assess-priority/SKILL.md:Red Flags`).

## Invariants

1. The 6-factor scoring algorithm is always applied before any priority assignment; single-source severity is never the final answer. A CVSS 9.8 with low EPSS, no KEV, and isolated exposure produces P4 (score ≈ 7-9), not P1. Confidence: verified by code analysis (Iron Law: `NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST`; Red Flag: "CVSS alone is severity, not risk").
2. The factor-to-score mapping is a deterministic lookup table, not an LLM judgment call. Factor scores (0-4 pts each, KEV 0/5 pts) are produced by pure range comparison against fixed thresholds; the arithmetic is reproducible given the same inputs. Confidence: verified by code analysis (`skills/assess-priority/SKILL.md:6-Factor Calculation` table).
3. Compensating controls reduce priority by exactly one level only when the controls are documented AND tested; assumed controls (without documentation or testing evidence) cannot be used to lower priority. Confidence: verified by code analysis (Red Flag: "Only reduce if controls are documented AND tested. Not assumed."; Override Rules).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | CVSS 9.8, EPSS 0.02, KEV Not Listed, Theoretical exploit, Medium ACR, Isolated | Score = 4+1+0+2+1+1 = 9 → P4 (Low, 90 days). Demonstrates Iron Law: vendor-Critical CVSS ≠ P1 without multi-factor context. |
| EC-002 | Any ticket with KEV Listed, regardless of other scores | Priority = P1, 24-hour SLA. KEV Listed triggers P1 via Priority Mapping unconditionally. |
| EC-003 | Missing EPSS data | Default EPSS to 0.0, continue scoring, include "INCOMPLETE DATA" warning in rationale. |
| EC-004 | Missing ACR data | Prompt user; if no response, use conservative default "Medium" (2 pts) and note the assumption. Never skip. |
| EC-005 | Compensating controls claimed but not documented | Controls are disregarded; priority is not reduced. Red Flag violation if reduced without documentation evidence. |
| EC-006 | KEV Listed + Internet + Critical ACR (Override Rule 1) | Automatic P1 regardless of raw score. Override Rule applies even if the score alone would yield P2 or lower. |
| EC-007 | Compliance requirement identified | Priority elevated +1 level from the base-score result (e.g., P3 → P2). |
| EC-008 | Vendor assessment says "High priority" | Vendor assessment is treated as one data input; the 6-factor algorithm runs independently and produces its own priority. Red Flag violation to use vendor assessment as final output. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| CVSS 9.8, EPSS 0.02, KEV Not Listed, Theoretical, Medium ACR, Isolated | Score=9 → P4, 90 days SLA | happy-path (Iron Law demonstration) |
| CVSS 7.5, EPSS 0.80, KEV Not Listed, Public Exploit, High ACR, Internet | Score=3+4+0+3+3+3=16 → P2, 7 days | happy-path |
| Any input, KEV Listed | P1 unconditional, 24 hours | override-rule |
| EPSS unavailable | INCOMPLETE DATA warning, EPSS defaulted to 0.0, scoring continues | edge-case |
| ACR unknown, no user response | Conservative default Medium (2 pts) used; assumption noted | edge-case |
| Vendor says Critical; CVSS 9.0, EPSS 0.01, no KEV, Theoretical, Low ACR, Isolated | Score=4+1+0+1+1+1=8 → P4; vendor assessment noted but overridden | edge-case (EC-008) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-029 | Iron Law text "NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST" is present in SKILL.md verbatim | integration / BATS (`@test "assess-priority has Iron Law"` skills.bats:13) |
| VP-SKILL-030 | Announce at Start section is present in SKILL.md | integration / BATS (`@test "assess-priority has Announce at Start"` skills.bats:39) |
| VP-SKILL-031 | Red Flags table has >= 6 rows | integration / BATS (`@test "assess-priority has >= 6 Red Flag rows"` skills.bats:66) |
| VP-SKILL-032 | Data references use `${CLAUDE_PLUGIN_ROOT}/data/` prefix (not hardcoded paths) | integration / BATS (`@test "data references use CLAUDE_PLUGIN_ROOT variable"` skills.bats:101) |
| VP-SKILL-033 | 6-factor scoring produces a score in the 0-24 range for all valid inputs | manual / property-based (pure arithmetic, no I/O) |
| VP-SKILL-034 | KEV Listed status always yields P1, independent of point score | manual / specification |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-VULN-01 |
| L2 Domain Invariants | Iron Law: NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST |
| Architecture Module | C-2 (skill-procedures); invoked as sub-skill by enrich-ticket Stage 6 |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/assess-priority/SKILL.md` (88 lines) |
| **Confidence** | medium — 6-factor scoring algorithm, override rules, and input defaults explicitly documented; Iron Law, Announce at Start, and Red Flags structurally verified by BATS; no executable behavioral test confirms the LLM applies the scoring algorithm correctly at runtime (structural-only) |
| **Extraction Date** | 2026-07-19 |
| **Last Verified Against** | v0.9.0 HEAD (commit d304fa5) |

#### Evidence Types Used

- **documentation**: 6-factor scoring table with ranges and point values; Priority Mapping table (P1-P5 with SLA); Override Rules list; Input Requirements with explicit defaults
- **guard clause**: Iron Law statement (SKILL.md:13) + Red Flags table (SKILL.md:24-33) document forbidden shortcuts including single-metric assignment and skipping ACR
- **type constraint**: all six factor inputs have documented ranges (CVSS 0-10.0, EPSS 0-1.0, KEV enum, ACR enum, exposure enum, exploit-status enum)
- **assertion**: Announce at Start is a pre-action invariant enforced by structural discipline; BATS confirms presence but not runtime execution

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | none (skill receives data from caller context, produces priority output; no jr CLI calls, no external API calls) |
| **Global state access** | none |
| **Deterministic** | yes — given the same 6 factor inputs, the scoring algorithm always produces the same score and priority (pure arithmetic lookup) |
| **Thread safety** | not applicable (LLM-executed sequential skill) |
| **Overall classification** | pure core (scoring sub-function); effectful shell only if the skill fetches missing inputs from Jira (not documented in SKILL.md — data is expected pre-populated by the caller) |

#### Refactoring Notes

The 6-factor scoring algorithm is the natural pure core: it takes 6 enumerated inputs and produces a (score, priority, SLA) tuple via deterministic arithmetic. This sub-function is formally specifiable and amenable to property-based testing (e.g., `proptest`/`fast-check` over the input space: verify score in [0,24], verify all KEV=Listed inputs produce P1, verify monotonicity).

The effectful part (fetching missing inputs from the user or from Jira) is strictly separated from scoring. No refactoring needed to draw the purity boundary.

Holdout scenarios for this BC are a follow-up item (product-owner).

---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/create-advisory/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "6361d47"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/create-advisory/SKILL.md
subsystem: advisory-pipeline
capability: CAP-ADVISORY-01
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

# Behavioral Contract BC-7.01.001: create-advisory Skill — Source-Verified Security Advisory Authoring

> **Revision history:**
> - v1.0 (2026-07-19): Initial extraction from `skills/create-advisory/SKILL.md` at v0.9.0 HEAD (DI-012 resolution, Step 0d extension).

## Preconditions

1. A topic argument (`$ARGUMENTS[0]`) is present and is one of: a CVE ID matching `CVE-\d{4}-\d{4,7}`, a URL starting with `http://` or `https://`, or a threat campaign name / vendor advisory reference. Confidence: verified by code analysis (`skills/create-advisory/SKILL.md:Input`).
2. The skill announces itself verbatim before any other action: "I'm using the create-advisory skill to draft a security advisory for \<topic\>." Confidence: verified by code analysis (`skills/create-advisory/SKILL.md:Announce at Start`) and BATS test `@test "create-advisory has Announce at Start"` (skills.bats:135).
3. The advisory type (IT / ICS/OT / Combined) is determined before template filling — either from the `--type` argument or by presenting the interactive three-option choice to the user (`1. IT`, `2. ICS/OT`, `3. Combined`). Confidence: verified by code analysis (`skills/create-advisory/SKILL.md:Advisory Type Selection`) and BATS test `@test "create-advisory presents interactive advisory type choice"` (skills.bats:148).
4. The skill is marked `disable-model-invocation: true` in its frontmatter, meaning it is not directly invokable from LLM context; it must be triggered via the `/secops-factory:create-advisory` slash command. Confidence: verified by code analysis (`skills/create-advisory/SKILL.md` frontmatter line 6).

## Postconditions

1. All data fields (CVSS score, EPSS, KEV status, affected version ranges) are verified against authoritative sources (NVD, CISA, FIRST) before the advisory is presented to the user. Any verification failure is fixed before presentation; unverified data is never presented. Confidence: verified by code analysis (`skills/create-advisory/SKILL.md:Step 4 — Source Verification Gate`; Iron Law) and BATS test `@test "create-advisory has Source Verification Gate"` (skills.bats:154).
2. The output advisory contains at minimum one detection indicator (at minimum log indicators; Snort/Sigma/YARA rules if available). The quality gate explicitly rejects advisories without detection guidance. Confidence: verified by code analysis (Red Flag: "An advisory without detection guidance is a notification, not an advisory. Include at least log indicators." in `skills/create-advisory/SKILL.md:Red Flags`; `skills/create-advisory/SKILL.md:Step 3 — Detection`).
3. The output advisory is populated from the built-in default template (`${CLAUDE_PLUGIN_ROOT}/templates/security-advisory-tmpl.md`) unless `--template <path>` is provided. A custom template is validated for the presence of headings matching "Executive Summary" (or "Summary"), "Affected" (products/systems/versions), and "Remediation" (or "Mitigation" or "Action") before use; if validation fails the user is offered the default template. Confidence: verified by code analysis (`skills/create-advisory/SKILL.md:Template Handling`) and BATS test `@test "create-advisory supports custom template via --template"` (skills.bats:144).
4. The advisory is presented to the user for review and iteration before writing to disk. The final file is written only after user approval. The quality gate requires: all template sections populated (or N/A with rationale), source verification passed, user approved, TLP marking set, revision history initial entry. Confidence: verified by code analysis (`skills/create-advisory/SKILL.md:Step 5 — Present and Iterate`; `Quality Gate`).

## Invariants

1. Source cross-referencing is mandatory and non-delegable: "The vendor said so" is not verification. Every CVSS score in the advisory is cross-referenced against NVD; every KEV status is independently queried from CISA; every EPSS score comes from a current FIRST API query. Vendor discrepancies are documented rather than silently resolved in the vendor's favor. Confidence: verified by code analysis (Iron Law: `NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST`; Red Flag: "Vendor advisories are one source. Cross-reference CVSS against NVD, check KEV, verify EPSS independently.").
2. The ICS/OT Context section is included whenever the affected product runs in OT environments (even occasionally) — it is not omitted solely because the advisory audience is "IT only." If the product can appear in OT, the ICS block is required. Confidence: verified by code analysis (Red Flag: "If the affected product runs in OT environments (even occasionally), include the ICS block.").
3. For high-severity advisories (CVSS >= 7.0 or KEV-listed), the skill surfaces a recommendation to run `/adversarial-review-secops` before distribution. This recommendation is non-optional to surface (the user decides whether to act on it). Confidence: verified by code analysis (`skills/create-advisory/SKILL.md:Optional: Adversarial Review`).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Topic is a CVE ID | Trigger `/research-cve <CVE-ID>` sub-skill for structured intelligence; cross-reference NVD/CISA/FIRST independently |
| EC-002 | Topic is a URL | Fetch via WebFetch, extract CVE IDs, run `/research-cve` for each; use fetched page as primary source; note URL in References |
| EC-003 | Topic is a threat campaign name | Try Perplexity first; fall back to WebSearch + NVD/EPSS WebFetch API calls without stopping to ask the user to configure Perplexity |
| EC-004 | Perplexity unavailable | Switch to WebSearch immediately; do NOT stop or ask user to configure Perplexity |
| EC-005 | `--template <path>` provided, validation fails (missing required headings) | Warn user; offer built-in default template instead; never proceed with invalid custom template |
| EC-006 | CVE has low EPSS score | EPSS measures exploitation probability, not impact; advisory still required if ICS/safety context warrants it (Red Flag override) |
| EC-007 | Advisory type not specified via `--type` | Present interactive choice (1. IT / 2. ICS/OT / 3. Combined) before proceeding |
| EC-008 | CVSS >= 7.0 or KEV-listed advisory | Recommend `/adversarial-review-secops` before distribution |
| EC-009 | Source Verification Gate finds CVSS mismatch between vendor and NVD | Fix the discrepancy (use NVD as authoritative); document the vendor discrepancy in the advisory |
| EC-010 | Urgency demand to skip peer review | Urgency increases error risk. Recommend adversarial review regardless. Surface the recommendation. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `CVE-2024-1234` (high CVSS, KEV-listed) | Full advisory with all sections; NVD-verified CVSS; CISA-verified KEV; detection indicators; adversarial-review recommendation | happy-path |
| `https://www.cisa.gov/known-exploited-vulnerabilities` (URL input) | WebFetch page, extract CVEs, run research-cve for each, populate advisory from page + research data | happy-path (URL form) |
| `--template /path/to/org-template.md` (valid custom template) | Validate headings pass; use custom template structure; preserve org-specific fields | happy-path (custom template) |
| `--template /path/missing.md` (invalid template — missing Remediation heading) | Warn user; offer built-in default template | edge-case (EC-005) |
| Perplexity unavailable at research step | Switch to WebSearch + NVD/EPSS/CISA fallback without prompting user | edge-case (EC-004) |
| Draft produced with detection section omitted | Quality Gate fails; force completion before presenting advisory | error (EC-002/detection invariant) |
| Source Verification Gate finds CVSS 9.8 in vendor advisory vs NVD 7.5 | Use NVD 7.5; document discrepancy; fix before presenting | error (EC-009) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-035 | Iron Law text "NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST" is present in SKILL.md verbatim | integration / BATS (`@test "create-advisory has Iron Law"` skills.bats:131) |
| VP-SKILL-036 | Announce at Start section is present in SKILL.md | integration / BATS (`@test "create-advisory has Announce at Start"` skills.bats:135) |
| VP-SKILL-037 | Red Flags table has >= 6 rows | integration / BATS (`@test "create-advisory has >= 6 Red Flag rows"` skills.bats:139) |
| VP-SKILL-038 | `--template` flag support is documented in SKILL.md | integration / BATS (`@test "create-advisory supports custom template via --template"` skills.bats:144) |
| VP-SKILL-039 | Interactive advisory type choice presents all three options (IT / ICS/OT / Combined) | integration / BATS (`@test "create-advisory presents interactive advisory type choice"` skills.bats:148) |
| VP-SKILL-040 | Source Verification Gate section is present in SKILL.md | integration / BATS (`@test "create-advisory has Source Verification Gate"` skills.bats:154) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ADVISORY-01 |
| L2 Domain Invariants | Iron Law: NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST |
| Architecture Module | C-2 (skill-procedures), C-11 (advisory-writer-agent), C-20 (output-templates: security-advisory-tmpl.md) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/create-advisory/SKILL.md` (170 lines) |
| **Confidence** | medium — 5-step workflow with Source Verification Gate, quality gate, template handling, advisory type selection, and custom template validation explicitly documented; Iron Law, Announce at Start, Red Flags, and template/advisory structure structurally verified by BATS (6 dedicated @tests); `disable-model-invocation: true` frontmatter confirmed; no executable behavioral test confirms the LLM performs cross-referencing at runtime (structural-only) |
| **Extraction Date** | 2026-07-19 |
| **Last Verified Against** | v0.9.0 HEAD (commit d304fa5) |

#### Evidence Types Used

- **documentation**: 5-step workflow (Research → Template Selection → Draft Advisory → Source Verification Gate → Present and Iterate); Advisory Type Selection logic; Template Handling (built-in and custom); Quality Gate checklist (6 items)
- **guard clause**: Iron Law statement (SKILL.md:14) + Red Flags table (SKILL.md:25-35) document 8 forbidden shortcuts including "vendor said so," "skip detection," and "urgency means skip peer review"
- **type constraint**: Source Verification Gate is an explicit checklist (5 items) that must pass before presentation; custom template validation requires 3 named headings
- **assertion**: `disable-model-invocation: true` frontmatter prevents direct LLM invocation; skill is command-only
- **inferred**: Perplexity fallback behavior is documented in Step 1 — "If Perplexity fails or is not available: switch to WebSearch immediately"

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads external APIs (Perplexity MCP, WebFetch to NVD/CISA/FIRST, WebFetch for URL topics), reads templates (filesystem), writes advisory file (filesystem), interacts with user (advisory type selection, review iteration) |
| **Global state access** | none |
| **Deterministic** | no — depends on external CVE data, live EPSS/KEV feeds, Perplexity results, user choices |
| **Thread safety** | not applicable (LLM-executed sequential skill) |
| **Overall classification** | effectful shell |

#### Refactoring Notes

The pure core of this skill is the template-filling step (Step 3): given all research data as inputs, populating the template is a deterministic transformation. Steps 1 (research) and 4 (source verification) are necessarily effectful. The Source Verification Gate is itself partially pure (CVSS range check, URL resolution check) and partially effectful (live EPSS API query). The pure sub-functions (CVSS range validation, advisory ID generation `SA-[YYYY]-[NNN]`, advisory type conditional section removal) are natural candidates for property-based specification.

No hook dependencies: unlike enrich-ticket (which has enrichment-completeness and require-review hooks), create-advisory has no hook coverage at the enforcement layer. Advisory content is not gateable by the current hook infrastructure (advisory output files do not pass through the enrichment-completeness write gate — that hook targets `enrichment-*` and `investigation-*` filename patterns). This is a known coverage gap: an advisory could be written to disk with missing sections without any hook blocking it.

Holdout scenarios for this BC are a follow-up item (product-owner).

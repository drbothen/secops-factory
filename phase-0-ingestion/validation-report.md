---
document_type: consistency-report
level: ops
version: "1.0"
status: final
producer: consistency-validator
timestamp: 2026-07-19T00:00:00Z
phase: "0f-post"
step: "Step 0f-post: Consistency Validation"
traces_to: phase-0-ingestion/project-context.md
project: secops-factory
---

# Phase 0 Consistency Validation Report — secops-factory

> **Scope:** Perimeter audit validating that Phase 0 brownfield artifacts conform to greenfield
> artifact schemas. This is distinct from the adversarial review (0f-adv) that checked internal
> consistency within artifacts — this check validates that artifact structures match what the
> greenfield pipeline produces so that Feature Mode can load them seamlessly.
>
> **Templates compared against:** `/Users/jmagady/Dev/dark-factory/templates/behavioral-contract-template.md`,
> `holdout-scenario-template.md`, `project-context-template.md`, `recovered-architecture-template.md`,
> `module-criticality-template.md`

---

## Summary Table

| Check | Criterion | Result | Severity of Gaps |
|-------|-----------|--------|------------------|
| 1 | BC Format (BC-S.SS.NNN identifiers, filenames) | PASS | — |
| 2 | Origin Field (all BCs have `origin: recovered`) | PASS | — |
| 3 | File Locations (all expected artifacts present) | PASS | — |
| 4 | Sharding Compliance (DF-021 index+detail pattern) | PASS | — |
| 5 | Architecture Format (YAML component map, required sections) | PASS | — |
| 6 | Holdout Format (schema, coverage, category, priority) | PASS | F-6a, F-6b resolved — see Findings Register |
| 7 | Module Criticality Format (DF-004 schema, completeness) | PASS | F-7a resolved — see Findings Register |
| 8 | Cross-References (module name consistency, no orphans) | CONDITIONAL PASS | DI-012 pending human decision |
| 9 | Security Audit Format (severities, summary table, remediations) | PASS | F-9a resolved — see Findings Register |
| 10 | Project Context Format (required sections, budget, restrictions) | PASS | F-10a resolved — see Findings Register |

**Overall gate result: PASS (clean) — no blocking schema gaps. All 10 checks passed. 5 minor non-blocking findings resolved (F-6a, F-6b, F-7a, F-9a, F-10a); 1 conditional pass (DI-012) with pending human decision already tracked.**

---

## Check 1: BC Format

**Result: PASS**

All 13 behavioral contracts use the `BC-S.SS.NNN` identifier format. Verified:
- BC-3.01.001, BC-3.02.001, BC-3.03.001, BC-3.04.001, BC-3.05.001, BC-3.06.001
- BC-4.01.001, BC-4.02.001, BC-4.03.001, BC-4.04.001
- BC-5.01.001
- BC-6.01.001, BC-6.01.002

All files are named `BC-S.SS.NNN.md` matching the convention. No `FR-RECOV-*` or other legacy identifier formats detected. The numbering scheme uses S = pipeline section (3 = enforcement hooks, 4 = vulnerability pipeline, 5 = event investigation, 6 = activation lifecycle), SS = subsystem index, NNN = sequential — appropriate for brownfield Phase 0 where no PRD section numbering exists yet.

---

## Check 2: Origin Field

**Result: PASS**

All 13 BCs carry `origin: recovered` in frontmatter. Spot-checked all 6 BCs read directly plus confirmed via project-context.md §5 BC index. None carry `origin: greenfield`. The brownfield-specific sections (`Source Evidence`, `Evidence Types Used`, `Purity Classification`, `Refactoring Notes`) are present in all BCs read, consistent with the brownfield template requirements.

---

## Check 3: File Locations

**Result: PASS**

All expected Phase 0 artifacts confirmed present at expected paths:

| Expected Artifact | Path | Present |
|-------------------|------|---------|
| project-discovery.md | `.factory/phase-0-ingestion/project-discovery.md` | YES |
| recovered-architecture.md | `.factory/phase-0-ingestion/recovered-architecture.md` | YES |
| conventions.md | `.factory/phase-0-ingestion/conventions.md` | YES |
| behavioral-contracts/ (13 BCs) | `.factory/phase-0-ingestion/behavioral-contracts/` | YES |
| verification-gap-analysis.md | `.factory/phase-0-ingestion/verification-gap-analysis.md` | YES |
| security-audit.md | `.factory/phase-0-ingestion/security-audit.md` | YES |
| project-context.md | `.factory/phase-0-ingestion/project-context.md` | YES |
| adversarial-review-0.md | `.factory/phase-0-ingestion/adversarial-review-0.md` | YES |
| module-criticality.md | `.factory/specs/module-criticality.md` | YES |
| holdout-scenarios/ | `.factory/holdout-scenarios/` (26 scenarios + HS-INDEX.md) | YES |

Note: adversarial review produced 12 passes (`adversarial-review-0.md` + `adversarial-review-0-pass2.md` through `adversarial-review-0-pass12.md`). The step spec requires `adversarial-review-0.md` to exist; the full pass history is additive state and not a deviation.

---

## Check 4: Sharding Compliance

**Result: PASS**

Two artifacts correctly apply the DF-021 index+detail sharding pattern:

**`recovered-architecture.md`** (exceeds 500-line threshold):
- Main file: architecture summary, component table, YAML component map, layers, dependency graph
- Detail shard 1: `arch-recov-api-surface.md` — API surface (20 slash commands)
- Detail shard 2: `arch-recov-integrations.md` — integration points, DTU candidates
- The main file header explicitly names both detail files and states "Sharding applied: YES"

**`project-context.md`** (Extended ToC pattern per DF-021):
- Uses Extended ToC to keep inline tokens < 3,000; all 9 sub-documents explicitly listed in frontmatter `inputs:` and §13 Source Map
- References recovered-architecture.md, arch-recov-*.md shards, behavioral-contracts/*.md, verification-gap-analysis.md, security-audit.md, module-criticality.md, HS-INDEX.md

STATE.md size is within the 200-line budget (size check passes per frontmatter comment directive).

---

## Check 5: Architecture Format

**Result: PASS**

`recovered-architecture.md` conforms to the greenfield recovered-architecture template structure:

- **Component Map YAML**: Present at lines 81–180+. All 24 components (C-1..C-24) have: `id`, `name`, `path`, `layer`, `purity`, `criticality`, `dependencies`, `interfaces_provided`, `interfaces_consumed`, `confidence`. The brownfield-specific `confidence` field is properly included (not present in greenfield, documented as brownfield-only in the template notes).
- **Dependency graph (DAG)**: Present. Manually verified acyclic (C-2↔C-3 back-edge removed per ADV-0-303; C-2→C-6 acyclic edge added per ADV-0-407). The "manually verified" qualifier is honestly noted (no DFS tool used).
- **Layers section**: Present with layer diagram and layer rules table.
- **API surface**: Sharded to `arch-recov-api-surface.md` — properly indicated in main file.
- **Integration points**: Sharded to `arch-recov-integrations.md` — properly indicated in main file.
- **Architecture Smells**: Present (circular dependency table, layer rules violations).
- **Technology Stack**: Present.

One note: the template's "Data Models" section describes database schemas, which are not applicable to a declarative Claude Code plugin. The YAML component map captures interface contracts adequately for this artifact type. Not a blocking gap.

---

## Check 6: Holdout Format

**Result: PASS — 2 minor findings**

**Schema compliance (all 26 scenarios):**
All required frontmatter fields present and populated:
- `document_type: holdout-scenario` ✓
- `level: ops` ✓
- `version: "1.0"` ✓
- `producer: product-owner` ✓
- `timestamp` ✓
- `id: "HS-NNN"` ✓
- `category: regression-baseline` ✓ (all 26)
- `priority: must-pass` ✓ (25/26; see below)
- `epic_id: "BROWNFIELD-REGRESSION"` ✓
- `behavioral_contracts:` ✓ (populated)
- `lifecycle_status: active` ✓
- `introduced:` ✓
- All lifecycle null fields present ✓

**Coverage gate:**
- CRITICAL modules — require-review: 5 scenarios (HS-001..004 + HS-026), update-jira: 4 scenarios (HS-005..008). Both >= 2 minimum. ✓
- HIGH modules — all 7 have >= 1 scenario. ✓
- 25/26 scenarios are `priority: must-pass`; 1/26 (HS-014) is `priority: should-pass` (fix-target for DI-004 disposition-guard false-pass, intentionally reclassified per ADV-0-602). This is correct behavior, documented, and excluded from the must-pass gate. ✓

**Section completeness (spot-checked HS-001, HS-023):**
All required sections present: Scenario, Behavioral Contract Linkage, Verification Approach, Evaluation Rubric, Edge Conditions, Failure Guidance. ✓

**Minor Finding F-6a: Filename convention deviation**
- Template convention: `HS-NNN-[short-description].md`
- Actual convention: `brownfield-regression-[name]-NNN.md` (e.g., `brownfield-regression-require-review-001.md`)
- The `id` field in frontmatter correctly maps to HS-NNN (e.g., `id: "HS-001"`), so the HS-INDEX cross-reference is valid
- The filename does not embed the HS-NNN prefix, which deviates from the template convention
- Severity: MINOR — does not affect Feature Mode consumption; the `id` field is the authoritative identifier

**Minor Finding F-6b: `input-hash: ""` left empty**
- All 26 scenarios have `input-hash: ""` (empty)
- Template has `input-hash: "[md5]"` (advisory field)
- The BC template describes input-hash as "advisory — used for drift detection, not gating"
- The same note applies here — no blocking impact on downstream consumption
- Severity: MINOR

---

## Check 7: Module Criticality Format

**Result: PASS — 1 minor deviation**

`module-criticality.md` matches the DF-004 classification schema:
- All 24 aggregate component-map modules classified with tier and rationale ✓
- Tier Definitions table present (CRITICAL/HIGH/MEDIUM/LOW with mutation kill-rate targets) ✓
- Distribution tables present (aggregate 24-module view + per-artifact 43-module view with derivation) ✓
- Every C-1..C-24 has a criticality field matching the YAML component map in `recovered-architecture.md` ✓
- Open items section with Resolved and Still-Open findings ✓
- Mutation targets per tier: require-review ≥95%, enrichment-completeness/disposition-guard ≥90%, low hooks ≥70% ✓

Template comparison: The greenfield template uses `level: ops` in frontmatter. The actual uses `level: L1`. The template also includes a `VP Count` column in the Module Classification table which is absent in the actual (the actual uses a different column layout with `Rationale`). These are structural differences.

**Minor Finding F-7a: Frontmatter field deviations**
- `level: L1` (template: `level: ops`)
- `date: "2026-07-19"` instead of `timestamp:` canonical field
- `traces_to:` absent from frontmatter (template has `traces_to: ""`)
- No `input-hash:` in frontmatter (template requires it, though advisory)
- Severity: MINOR — content is correct and complete; Feature Mode will load the file correctly

---

## Check 8: Cross-References

**Result: CONDITIONAL PASS — DI-012 pending human decision**

**Module name consistency (verified):**
All module names are consistent across recovered-architecture.md, behavioral contracts, conventions.md, and module-criticality.md. Spot-checked cross-references:
- BC-3.01.001 `Architecture Module: C-12 (require-review-hook)` → C-12 in recovered-architecture.md ✓
- BC-3.02.001 `Architecture Module: C-13 (enrichment-completeness-hook)` → C-13 ✓
- BC-4.01.001 `Architecture Module: C-2 (skill-procedures), C-4 (enrichment-workflow-playbook)` → C-2, C-4 ✓
- BC-3.03.001 `subsystem: enforcement-hooks`, `capability: CAP-ENFORCEMENT-03` ✓
- BC-4.02.001 traces to C-2 (skill-procedures) with subsystem: vulnerability-pipeline ✓

**No orphaned references:** DI-008 (prose/YAML C-ID divergence) and DI-009 (hook-manifests absent from YAML) both RESOLVED. DI-010 (SEC-002 fail-closed regression) RESOLVED. ✓

**Known gap DI-012 — BCs for HIGH modules:**
9 HIGH architecture modules have no behavioral contracts:
- C-3 (orchestrator-agent/Morgan)
- C-4 (enrichment-workflow-playbook)
- C-5 (investigation-workflow-playbook)
- C-6 (review-convergence-playbook)
- C-7 (security-analyst-agent/Alex)
- C-8 (security-reviewer-agent/Riley)
- C-18 (hook-manifests)
- C-19 (knowledge-bases)
- C-22 (test-suite+CI)

This is DI-012 — documented in STATE.md, project-context.md §8 and §11, flagged as **PENDING HUMAN DECISION** at Phase 0 exit gate. The 13 recovered BCs cover the highest-blast-radius modules by design. The question of whether to expand BC coverage before Feature Mode or accept partial coverage is a human decision that was correctly escalated, not a pipeline error.

The CONDITIONAL PASS reflects: the artifact set is structurally correct; the gap is intentionally scoped and documented, not an oversight.

---

## Check 9: Security Audit Format

**Result: PASS — 1 minor frontmatter gap**

Content validation:
- Severity classifications for all 9 findings (SEC-001 through SEC-009): CRITICAL, MEDIUM, LOW, INFO ✓
- All severity values are valid per the accepted taxonomy (CRITICAL/HIGH/MEDIUM/LOW/INFO) ✓
- Disposition Table (summary table) is present with ID/Severity/Title/Disposition columns ✓
- Remediation/disposition documented for every finding; resolved findings reference the specific PR and commit hash ✓
- Post-audit addition (SEC-009) properly documented with discovery context and resolution reference ✓

**Minor Finding F-9a: Frontmatter uses non-canonical field names**
The `security-audit.md` frontmatter uses domain-specific fields rather than the canonical VSDD frontmatter schema:
- `step: "0e-sec"` instead of `document_type: security-audit`
- `artifact: security-audit` (non-canonical)
- `date: "2026-07-19"` instead of `timestamp:`
- `reviewer: security-reviewer` instead of `producer:`
- `traces_to:` absent
- `level:` absent
- `version:` absent

This does not prevent Feature Mode from using the artifact — the security posture summary is in project-context.md §7, which references security-audit.md for detail. The missing canonical fields would be remediated in Phase 1 if the security-audit is re-issued as a living artifact. Severity: MINOR.

---

## Check 10: Project Context Format

**Result: PASS — 1 minor frontmatter gap**

The project-context.md is the Feature Mode scoping document (the primary deliverable of Phase 0). Validation:

**Required sections** (checked against project-context-template.md):
- §1 Identity (with Development Context analog) ✓
- §2 Architecture (Component Inventory, Layer Diagram, Context Budget, Dependency Graph summary) ✓
- §3 Context Budget (per-component token estimates, strategy recommendation: component-scoped) ✓
- §4 Conventions (20 enforceable rules digest, CONV-001..020 reference) ✓
- §5 Behavioral Contracts (recovered — 13-row index table) ✓
- §6 Verification Posture (test coverage, purity, mutation figures, 3-bucket BC roll-up) ✓
- §7 Security Posture (risk posture, all SEC-NNN dispositions, SEC-009 CRITICAL/RESOLVED) ✓
- §8 Open Drift Items (DI-001..DI-014 with status/severity) ✓
- §9 Restricted Areas (with per-row justifications) ✓
- §10 Recent Changes ✓
- §11 Boundary — Exists vs NEW work ✓
- §12 Holdout Reference ✓
- §13 Source Map ✓

The actual document has 13 sections vs the template's 8 sections — it is a superset, which is correct for a capstone brownfield artifact.

**Context Budget Estimates:** Present in §3 with token estimates per component (commands, skills, agents, hooks, templates, checklists, data KBs, tests). Strategy recommendation ("component-scoped") and the dominant Extended-ToC constraint for data/ KBs (80K+ tokens) documented. ✓

**Restricted Areas with justifications:** Present in §9 with 7 restricted areas, each with explicit path and justification. ✓

**Feature Mode readiness:** The document is self-contained, cross-references verified (Quality Gate checklist at end of document passes all items), and the two pending human decisions (DI-012, DI-013) are explicitly flagged via `open_gate_decision:` in the YAML footer block. ✓

**Minor Finding F-10a: Frontmatter field deviations**
- `date: "2026-07-19 (re-synced post adversarial pass 12)"` instead of canonical `timestamp:` field
- `traces_to:` absent (project-context.md is a root capstone artifact — no single parent to trace to; acceptable)
- `level: L0` — non-standard level value (canonical levels are L1/L2/L3/L4/ops)
- These deviations do not prevent Feature Mode consumption. Severity: MINOR.

---

## Findings Register

| ID | Check | Severity | Description | Resolution | Status |
|----|-------|----------|-------------|------------|--------|
| F-6a | 6 | MINOR | Holdout scenario filenames use `brownfield-regression-[name]-NNN.md` instead of template convention `HS-NNN-[short-description].md` | Added explanatory note to HS-INDEX.md documenting the brownfield convention and confirming the `id:` frontmatter field is authoritative. No rename required. | RESOLVED |
| F-6b | 6 | MINOR | All 26 holdout scenarios have `input-hash: ""` (empty) | Added explanatory note to HS-INDEX.md documenting that `input-hash` is advisory-only per the holdout-scenario template; empty value is intentional for brownfield baseline; deferred until Feature Mode drift detection is enabled. | RESOLVED |
| F-7a | 7 | MINOR | `module-criticality.md` uses `level: L1` (template: `level: ops`), `date:` instead of `timestamp:`, missing `traces_to:` and `input-hash:` | Updated frontmatter: `level: ops`, `timestamp: 2026-07-19T00:00:00Z`, added `traces_to: phase-0-ingestion/recovered-architecture.md`, added `input-hash: ""`. Removed non-canonical `date:` field. | RESOLVED |
| F-9a | 9 | MINOR | `security-audit.md` frontmatter uses `step:/artifact:/date:/reviewer:` instead of canonical `document_type:/timestamp:/producer:`; missing `level:`, `version:`, `traces_to:` | Added canonical fields: `document_type: security-audit`, `level: ops`, `version: "1.0"`, `producer: security-reviewer`, `timestamp: 2026-07-19T00:00:00Z`, `traces_to: ""`. Removed non-canonical `date:` and `reviewer:` fields. Domain-specific fields (`step:`, `artifact:`, counts) retained. | RESOLVED |
| F-10a | 10 | MINOR | `project-context.md` uses `date:` instead of `timestamp:`, missing `traces_to:`, non-standard `level: L0` | Updated frontmatter: `level: ops`, `timestamp: 2026-07-19T00:00:00Z`. Removed non-canonical `date:` field. `traces_to:` omitted (capstone root artifact with no single parent — acceptable per template). | RESOLVED |
| DI-012 | 8 | PENDING-HUMAN | 9 HIGH modules (C-3..C-8, C-18, C-19, C-22) have no behavioral contracts | Pending human decision at Phase 0 exit gate: expand BC set before Feature Mode, or accept partial coverage? Documented in project-context.md §8 and §11. | PENDING-HUMAN |

---

## Artifact Readiness for Feature Mode

| Artifact | Feature Mode Role | Structurally Ready |
|----------|------------------|-------------------|
| `project-context.md` (v1.12) | THE scoping document loaded each Feature cycle | YES |
| `behavioral-contracts/*.md` (13 BCs) | Source of truth for story derivation | YES |
| `recovered-architecture.md` + shards | Architecture reference for story mapping | YES |
| `module-criticality.md` | Verification rigor tier for each module | YES |
| `conventions.md` | Code/style conventions for implementers | YES |
| `verification-gap-analysis.md` | Open gaps for Phase 3 test strategy | YES |
| `holdout-scenarios/` (26 scenarios) | Holdout evaluation baseline | YES |
| `security-audit.md` | Security posture reference | YES |
| `STATE.md` | Pipeline state for resume/transition | YES |

---

## Validation Gate Result

All 10 checks executed. Zero blocking (Critical/Major) findings. Five minor schema deviations detected and resolved (F-6a, F-6b, F-7a, F-9a, F-10a — see Findings Register for resolution details). One conditional pass (Check 8, DI-012) reflects a pending human decision that was correctly escalated at the Phase 0 exit gate and is fully documented.

The brownfield artifact set is structurally conformant to greenfield templates and ready for seamless transition to Feature Mode once the human decisions at the Phase 0 exit gate are resolved (DI-012: BC coverage expansion decision; DI-013: comment-post override decision).

```
CONSISTENCY_VALIDATION: PASS (clean)
```

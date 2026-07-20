---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/adversarial-review-secops/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "2e9b3fb"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/adversarial-review-secops/SKILL.md
subsystem: vulnerability-pipeline
capability: CAP-REVIEW-02
lifecycle_status: active
introduced: v0.7.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-4.04.001: adversarial-review-secops Skill — Convergence Loop

## Preconditions

1. A ticket ID is provided and an enrichment or investigation artifact is accessible for review. Confidence: verified by code analysis (`skills/adversarial-review-secops/SKILL.md:argument-hint`).
2. The skill announces itself verbatim before any other action. Confidence: verified by code analysis and BATS test `skills.bats:55-57`.
3. The `security-reviewer` agent (Riley, opus model) must be dispatched with ONLY the artifact content and the Honest Convergence clause — no prior pass findings are included. Confidence: verified by code analysis (Pass Management section, rule 3).

## Postconditions

1. A minimum of 2 review passes are executed. Confidence: verified by code analysis (Pass Management: "Minimum 2 passes, maximum 5") and BATS test `skills.bats:195-198`.
2. Each pass produces a SUBSTANTIVE/NITPICK classification for every finding. Confidence: verified by code analysis (Strict-Binary Novelty Classification section).
3. Convergence is declared when all findings in a pass are classified NITPICK. Confidence: verified by code analysis (Convergence criterion).
4. If SUBSTANTIVE findings remain after a pass, the analyst must address them before the next pass; the loop continues until convergence or max passes (5). Confidence: verified by code analysis.
5. Every reviewer dispatch includes the Honest Convergence clause verbatim. Confidence: verified by code analysis (Honest Convergence section) and BATS test `skills.bats:195-198`.
6. Every reviewer dispatch includes the Subagent Delivery Protocol instruction (inline file delivery via `=== FILE: <filename> ===` delimiter). Confidence: verified by code analysis (Subagent Delivery Protocol section) and BATS test `skills.bats:203-207`.
7. The final output includes: pass summary with finding counts, novelty classification per pass, final quality score with dimension breakdown, sign-off recommendation (APPROVED / APPROVED WITH CONDITIONS / REWORK REQUIRED). Confidence: verified by code analysis (Output section).
8. Quality thresholds for APPROVED: overall score >= 7.0/10 AND no dimension < 5.0/10 AND zero Critical findings. Confidence: verified by code analysis (Quality Thresholds section) and Red Flag: "6.8, close enough to 7.0" → "Threshold is >=7.0. Close is not passing."

## Invariants

1. The reviewer is dispatched with information asymmetry: it never sees prior pass findings. Dispatching with prior pass content invalidates the convergence mechanism. Confidence: verified by code analysis (Red Flag: "I'll summarize the prior pass for the reviewer" → "Destroys information asymmetry.").
2. Passes are numbered SECOPS-P1, SECOPS-P2, etc. Confidence: verified by code analysis (Pass Management).
3. The cognitive bias audit is mandatory for every pass — it cannot be omitted. Confidence: verified by code analysis (Cognitive Bias Audit section: "Mandatory Per Pass").
4. After max 5 passes without convergence, the skill escalates rather than continuing indefinitely. Confidence: verified by code analysis (Pass Management: "maximum 5 before escalating").
5. The canonical source for the convergence protocol is `agents/orchestrator/review-convergence-workflow.md`. If the skill file and the orchestrator file disagree, the orchestrator file wins. Confidence: verified by code analysis (Canonical Source section) and BATS test `skills.bats:209-211`.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Pass 1 returns zero findings | This is treated as suspicious — Red Flag: "One pass found nothing, we're converged" → "Zero findings after one pass is a prompt bug, not convergence. Min 2 passes." Run pass 2. |
| EC-002 | Reviewer fabricates findings when there are none | Honest Convergence clause requires reviewer to declare convergence if < 3 substantive items; prevents padding |
| EC-003 | Same SUBSTANTIVE finding recurs across passes without being fixed | Red Flag: "Same finding keeps appearing" → "It keeps appearing because it isn't fixed. Fix it, then re-run." |
| EC-004 | Quality score is 6.8 after convergence | REWORK REQUIRED — 6.8 < 7.0 threshold |
| EC-005 | One dimension scores 4.9/10 (below 5.0 minimum) | Flag for rework regardless of overall score |
| EC-006 | Reviewer returns empty output (sandbox denial or crash) | handoff-validator hook warns on stderr; orchestrator must not treat empty output as convergence |
| EC-007 | Max 5 passes reached with SUBSTANTIVE findings remaining | Escalate — do not extend loop; report as REWORK REQUIRED |

## Canonical Test Vectors

| Scenario | Expected Behavior | Category |
|----------|------------------|----------|
| High-quality enrichment, all dimensions >= 7.0 | Pass 1: some SUBSTANTIVE (documents finding). Pass 2: all NITPICK → converged. APPROVED. | happy-path |
| P1/P2 ticket, poor enrichment | Multiple passes, analyst addresses findings between passes, converges at pass 3-4. APPROVED. | happy-path |
| Pass 1 zero findings | Must run pass 2 regardless — minimum 2 passes enforced. | edge-case |
| Fabricated findings detected | Honest Convergence clause produces "converged, no file emitted" declaration. | edge-case |
| Score 6.8 after convergence | REWORK REQUIRED sign-off with specific improvement guidance. | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-013 | Iron Law text present verbatim | integration / BATS (`skills.bats:29-31`) |
| VP-SKILL-014 | Honest Convergence clause present | integration / BATS (`skills.bats:195-198`) |
| VP-SKILL-015 | Known Review Hallucination Classes section present | integration / BATS (`skills.bats:200-202`) |
| VP-SKILL-016 | Subagent Delivery Protocol with `=== FILE:` delimiter present | integration / BATS (`skills.bats:203-207`) |
| VP-SKILL-017 | Canonical Source pointer to review-convergence-workflow.md present | integration / BATS (`skills.bats:209-211`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-REVIEW-02 |
| L2 Domain Invariants | NO QUALITY SIGN-OFF WITHOUT ADVERSARIAL CONVERGENCE FIRST |
| Architecture Module | C-2 (skill-procedures), C-6 (review-convergence-playbook), C-8 (security-reviewer-agent) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/adversarial-review-secops/SKILL.md` (138 lines) |
| **Confidence** | high — convergence protocol, quality thresholds, hallucination classes, and delivery protocol all explicitly documented; BATS tests validate 5 structural properties |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **documentation**: convergence protocol with numbered passes; quality thresholds; 5 hallucination classes
- **guard clause**: Honest Convergence clause (mandatory dispatcher instruction)
- **type constraint**: SECOPS-P1/P2/... pass numbering convention
- **documentation**: Subagent Delivery Protocol (inline file delivery pattern for sandboxed agents)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads artifact (filesystem/JIRA), dispatches security-reviewer subagent (LLM calls), writes files (parsed from reviewer output), writes JIRA (final sign-off) |
| **Global state access** | none |
| **Deterministic** | no — LLM-mediated multi-pass review with non-deterministic finding content |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell |

#### Refactoring Notes

The convergence decision logic (all findings NITPICK → converged) is a pure boolean function over the finding classification list. The quality threshold check (score >= 7.0, no dimension < 5.0, zero Critical) is a pure predicate. These are the natural units for formal specification. The pass execution loop is effectful. The file parsing from `=== FILE: === ` delimiter output is a pure string transformation and could be formally verified.

**Undocumented behavior (ambiguity):** The Honest Convergence clause says "if you find fewer than 3 substantive items, declare convergence." This creates a threshold ambiguity: what if there are exactly 3 substantive items and the analyst believes 2 of them are incorrect? The convergence mechanism relies on the reviewer's honest judgment, not a formal proof. The Known Review Hallucination Classes section is the mitigation, but it is advisory.

**Ambiguity:** The "SECOPS-P1" pass numbering is documented in the skill but no enforcement mechanism validates it. The handoff-validator only checks result length. If a reviewer returns a pass without the SECOPS-P1 prefix, no hook fires.

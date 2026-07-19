---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/review-enrichment/SKILL.md, plugins/secops-factory/tests/skills.bats]
input-hash: "2bfd0a8"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/review-enrichment/SKILL.md
subsystem: vulnerability-pipeline
capability: CAP-REVIEW-01
lifecycle_status: active
introduced: v0.6.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-4.03.001: review-enrichment Skill — Polymorphic Fresh-Context Quality Review

## Preconditions

1. A ticket ID is provided; the referenced artifact (enrichment or investigation document) must be accessible for review. Confidence: verified by code analysis (`skills/review-enrichment/SKILL.md`).
2. The `security-reviewer` agent (Riley, opus model) is dispatched in fresh context — the reviewer must not have seen prior review passes or the analyst's reasoning. Confidence: verified by code analysis (Iron Law text and BATS test `skills.bats:21-23`).
3. The reviewer agent's tool list must NOT include `Write`. Confidence: verified by code analysis and BATS test `skills.bats:277-279`.
4. The skill announces itself verbatim before any other action. Confidence: verified by code analysis and BATS test `skills.bats:44-47`.

## Postconditions

1. The skill auto-detects the artifact type: CVE enrichment → 8-dimension review; event investigation → 7-dimension weighted review. Confidence: verified by code analysis (`skills/review-enrichment/SKILL.md:Type Detection Logic`).
2. For CVE enrichment: all 8 checklist dimensions are scored; overall score = average of dimension scores. Confidence: verified by code analysis (CVE Enrichment Review section).
3. For event investigation: all 7 weighted dimensions are scored; weighted score = sum of (dimension score × weight). Dimension weights: Completeness 25%, Technical Accuracy 20%, Disposition Reasoning 20%, Contextualization 15%, Methodology 10%, Documentation Quality 5%, Cognitive Bias 5%. Confidence: verified by code analysis (Event Investigation Review section).
4. Findings are classified into three severity tiers: Critical (blocks progression), Significant (should fix), Minor (nice to have). Confidence: verified by code analysis (Categorize Findings section).
5. A review report is generated using the appropriate template and posted as a JIRA comment. Confidence: verified by code analysis (Output section).
6. The review always starts with strengths, not findings. Confidence: verified by code analysis (Output section and Red Flag: "Strengths are obvious, I'll skip to findings").
7. For event investigation: the reviewer forms an independent disposition assessment before reading the analyst's disposition. Confidence: verified by code analysis (Disposition Validation subsection).

## Invariants

1. The reviewer evaluates from fresh context — no prior review pass summaries, no author reasoning, no orchestrator context is injected. Confidence: verified by code analysis (Iron Law: "NO APPROVAL WITHOUT FRESH-CONTEXT REVIEW FIRST").
2. All checklists in `${CLAUDE_PLUGIN_ROOT}/checklists/` must exist on disk for the review to complete. Confidence: verified by BATS test `skills.bats:243-255` (checklist existence check).
3. Bias detection is mandatory for every review — it cannot be skipped. Confidence: verified by code analysis (Red Flag: "I'll skip bias detection, it seems clean" → "Bias detection is mandatory").
4. The skill uses the `security-reviewer` agent (opus model) — not the `security-analyst` agent. Confidence: verified by code analysis (frontmatter `agent: security-reviewer`) and BATS test `skills.bats:273-276`.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Ambiguous artifact type (neither CVE nor event keywords found) | Prompt user to select type |
| EC-002 | One checklist dimension scores below 5.0/10 | Flag as potential blocker even if overall score is above 7.0 |
| EC-003 | Analyst's disposition differs from reviewer's independent assessment | Reviewer documents disagreement with supporting evidence; does not automatically defer to analyst |
| EC-004 | Low confidence disposition in investigation | Flag for escalation |
| EC-005 | JIRA comment post fails | Report review locally; flag JIRA update failure |
| EC-006 | All scores above threshold, no critical findings | Approve; set review-approval marker |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| CVE enrichment document, all 8 dimensions strong | 8-dimension score ≥ 7.0, no Critical findings, review-approval marker set | happy-path |
| Event investigation, disposition agrees with reviewer | Weighted score output, agreement noted, approval if threshold met | happy-path |
| CVE enrichment with no EPSS data | Significant finding in Technical Accuracy or Completeness dimension; blocks if Critical threshold triggered | error |
| Event investigation, reviewer disagrees with TP disposition | Disagreement documented with evidence; no automatic approval | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-009 | Iron Law text present verbatim | integration / BATS (`skills.bats:21-23`) |
| VP-SKILL-010 | security-reviewer uses opus model | integration / BATS (`skills.bats:273-276`) |
| VP-SKILL-011 | security-reviewer tool list excludes Write | integration / BATS (`skills.bats:277-279`) |
| VP-SKILL-012 | All checklists referenced exist on disk | integration / BATS (`skills.bats:243-255`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-REVIEW-01 |
| L2 Domain Invariants | NO APPROVAL WITHOUT FRESH-CONTEXT REVIEW FIRST |
| Architecture Module | C-2 (skill-procedures), C-8 (security-reviewer-agent) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/review-enrichment/SKILL.md` (~97 lines) |
| **Confidence** | high — type detection logic, scoring formulas, and finding classification all explicitly documented; checklist files validated by BATS |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **documentation**: type detection logic (4 priority steps); scoring formulas; weighted dimension table
- **guard clause**: Iron Law text enforces fresh-context requirement
- **type constraint**: opus model requirement enforced by agent frontmatter + BATS test

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads JIRA artifact, reads checklists (filesystem), writes JIRA comment, reads external research (Perplexity for fact verification) |
| **Global state access** | none |
| **Deterministic** | no — LLM-mediated quality assessment |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell |

#### Refactoring Notes

The scoring formulas (simple average for CVE, weighted sum for investigation) are pure functions. The type detection logic (keyword matching against JIRA ticket content) is also a pure function. These are the natural units for specification and testing. The review itself is non-deterministic (LLM-executed) and cannot be formally verified, but the scoring aggregation can be.

**Undocumented behavior (ambiguity):** The "review-approval marker" that `update-jira` requires is set during the review, but the format of this marker is not formally defined in either skill. It is a convention maintained through conversation context. If the review is done in a different session than the update, the marker may not be present, causing `update-jira` to halt. This session-boundary gap is noted for architecture attention.

---
document_type: adversarial-spec-delta-review
pass: 38
result: NOT CLEAN
date: 2026-09-03
producer: adversary
cycle: v0.10.0-feature-prism-integration
phase: F2
findings_total: 2
findings_critical: 0
findings_major: 1
findings_medium: 0
findings_minor: 0
findings_obs: 1
novelty: LOW
clean_streak: "0/3"
input-hash: "[live-state]"
---

# Adversarial Spec Delta Review — Pass 38

**Verdict: PASS 38 — 0C / 1M / 0med / 0min / 1obs — NOT CLEAN**
**Clean streak: 0/3 — RESET (P38-001 MAJOR breaks the streak from pass-37)**
**Novelty: LOW**

---

## Summary

Pass 38 re-derives the spec from source-of-truth artifacts after the burst-33
VP-ownership audit (prd-delta v1.35, verif-delta v1.34, all BCs at current
versions). All spec substance — STEP ordering, kill-switch/hard-floor semantics,
marker mechanism, D-029 routing, §3.4 correlation rules, NORMALIZE_SEVERITY,
12/18-field split, and all three coherence dimensions (version pins, EC/invariant
counts, VP attribution) — re-derived CLEAN.

One MAJOR finding identified: VP-SKILL-075 lifecycle status contradiction
WITHIN BC-10.01.001 across multiple sites. The burst-33 VP-ownership audit
corrected the VP Anchors footer (L803) to PROPOSED P1, but left the
Postcondition #7 body (L192) and the Verification Properties table row (L789)
still reading FINALIZED P0. This is a partial-fix residual from burst-33 — the
footer was the only site corrected; the body and table were missed.

One OBSERVATION [process-gap] recorded: VP lifecycle status (FINALIZED/PROPOSED,
P0/P1) is cited in multiple sites per BC (inline invariant/postcondition bodies,
Verification Properties table row, VP Anchors footer, pseudocode comments), and
there is no intra-BC VP-status-agreement check to catch multi-site
inconsistencies. This process gap enabled the burst-33 partial-fix to survive
until pass-38.

REMEDIATED in burst-37: comprehensive VP-status-agreement sweep across all four
affected files (BC-10.01.001, BC-3.03.001, BC-3.01.001, prd-delta), 6 sites
corrected. All NO-BUMP completions. Spec content FROZEN for pass-39 streak attempt.

---

## Findings

### P38-001 (MAJOR) — VP-SKILL-075 lifecycle status contradiction within BC-10.01.001

**Severity:** MAJOR
**Status:** REMEDIATED (burst-37, BC-10.01.001 v1.32 no-bump; all 6 VP-status sites across 4 files corrected)
**Location:** `.factory/phase-0-ingestion/behavioral-contracts/BC-10.01.001.md`

VP-SKILL-075 (monitoring-loop stage ordering first-run temporal isolation guard)
is a PROPOSED P1 verification property, as confirmed by the verification-delta
§1 authority and the BC-10.01.001 VP Anchors footer (L803, corrected in
burst-33):

```
VP Anchors: VP-SKILL-075 PROPOSED P1 (monitoring-loop stage ordering…)
```

However, two additional sites within BC-10.01.001 still read FINALIZED P0 after
burst-33:

1. **Postcondition #7 body (L192):** The PC#7 inline body text references
   VP-SKILL-075 with an annotation marking it as FINALIZED P0 — contradicting
   the footer.
2. **Verification Properties table row (L789):** The VP table entry for
   VP-SKILL-075 lists it as FINALIZED — contradicting both the footer and
   verification-delta §1.

The burst-33 audit corrected the VP Anchors footer (the most visible traceability
site) but did not sweep the inline body and VP table row within the same file.
This is a partial-fix residual.

**Root cause:** Burst-33 swept VP status by walking prd-delta §1 against BC
footers, not by grepping ALL VP-* occurrences within each BC against the
verification-delta authority. Sites in the postcondition body and VP table row
were not in the sweep's scope.

**Substance re-derived:** CLEAN. The monitoring-loop stage ordering behavior
is correctly specified. The VP status label is a governance/traceability
metadata error, not a behavioral defect.

**Remediation (burst-37):**
- BC-10.01.001: L192 (PC#7 body) + L789 (VP table) corrected FINALIZED P0 →
  PROPOSED P1. Footer L803 was already correct.
- BC-3.03.001: L1350 VP-HOOK-030 annotation corrected to match verification-delta
  authority.
- BC-3.01.001: L436 (VP table) + L234 (pseudocode comment) VP-HOOK-029
  corrected to FINALIZED P0.
- prd-delta §5 L160: CV-007 historical entry annotated with correction note.
All 6 sites corrected, all NO-BUMP. Grep confirmed zero remaining stale
VP-status strings in the 3 BCs.

---

### OBS [process-gap] — No intra-BC VP-status-agreement check

**Severity:** OBSERVATION
**Status:** Captured in Lesson 54 (burst-37)
**Location:** Process / auditing discipline

VP lifecycle status (FINALIZED/PROPOSED, P0/P1) is cited in ≥3 sites per BC:
(1) inline invariant/postcondition body text, (2) the Verification Properties
table row, (3) the VP Anchors footer, and optionally (4) pseudocode comments.

The burst-33 VP-ownership audit swept prd-delta §1 VP-Refs against BC footers
and verification-delta §1 ownership, correcting the footer. It did NOT grep
every VP-* occurrence within each BC file against the verification-delta
authority. The body and table sites were therefore not in scope.

There is no standing check that validates agreement across all VP-status sites
within a single BC. The process gap is: a VP-status correction that updates only
one site (e.g., the footer) passes all current cross-document VP accounting
checks (Lesson 53), while leaving sibling sites within the same BC stale.

**Codified:** Lesson 54 (this burst) extends Lessons 51/52/53 to the
VP-lifecycle-status dimension. The standing rule is: a VP-status coherence
sweep MUST grep every VP-* occurrence in every BC file and cross-check each
occurrence against the verification-delta §1 status column, not only the footer
VP Anchors row.

---

## Substance Re-derivation (All CLEAN)

The adversary re-derived the following from source-of-truth artifacts
(architecture-delta, verification-delta, BC files) with no prior-pass context:

- **STEP ordering** (STEP 1a–6, STEP 3b carve-out, STEP 4b hoist): CLEAN
- **Kill-switch semantics** (autonomy_enabled=false exits at STEP 5; D-007 exemptions): CLEAN
- **Hard-floor trigger** (hard_floor_applies() → HIGH/CRIT scored_priority): CLEAN
- **Marker mechanism** (anti-fungibility, single-use, O7 charset): CLEAN
- **D-029 routing** (markdown hard-floor → route-to-review-never-deny): CLEAN
- **§3.4 correlation rules** (link, close, create+link compound model): CLEAN
- **NORMALIZE_SEVERITY** (D-DEC-013 table, STEP 1a consistency check): CLEAN
- **12/18-field split** (investigation markdown vs verdict ICD-203 schema): CLEAN
- **Version pins** (all BC cross-references to sibling BC versions): CLEAN
- **EC/invariant counts** (prd-delta §1/§3/§8 count tables): CLEAN
- **VP attribution** (all VP-HOOK/VP-SKILL IDs to their owning BCs): CLEAN

---

## Convergence Assessment

**Pass 38 breaks the clean streak established at pass 37.** P38-001 is a
MAJOR governance/traceability finding — VP-SKILL-075 status contradiction
across ≥3 sites within BC-10.01.001. While the substance is correct, the
traceability metadata is inconsistent and would cause a future VP accounting
audit to produce a wrong count of FINALIZED P0 VPs.

**Streak reset to 0/3.** Passes 39–41 must all be clean to achieve convergence.

**All burst-37 remediations are NO-BUMP** — spec versions unchanged, only
VP-status metadata corrected. The spec content (behavioral substance) has been
confirmed CLEAN for 2 consecutive passes (37 + 38 substance) and remains
FROZEN.

**Next action:** adversary pass-39 (fresh context; streak attempt 1/3 again).

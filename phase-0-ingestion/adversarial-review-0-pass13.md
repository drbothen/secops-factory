# Adversarial Review — Phase 0 Ingestion, Pass 13 (CONVERGENCE)

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary (explicitly instructed to grade honestly and not manufacture findings). Date: 2026-07-19._

---

## Pass 13 Report

**Verdict:** CLEAN — 0 graded findings (0 critical / 0 major / 0 minor) + 4 non-blocking cosmetic observations. Novelty: NONE.

**Adversary judgment:** "Converged and honest." Every load-bearing count was independently re-derived from first principles and reconciles. No architecture, security, or correctness gaps remain. The capstone is judged honest about its own limits; no false-green claims detected.

**Finding decay (complete):** 12 → 11 → 7 → 8(1FP) → 6 → 6 → 6 → 6(1 real shipped-code CRITICAL) → 4 → 5 → 2 → 1 → **0 graded**.

**This is the CONVERGENCE pass.** The "loop until only observations" bar is met.

---

## Independent Count Verification (Re-derived From First Principles)

The adversary re-derived each count from ground-truth sources without relying on prior passes.

| Axis | Claim | Re-derived | Verdict |
|------|-------|-----------|---------|
| Primary modules | 24 | 24 (C-01..C-24 in recovered-architecture.md YAML) | PASS |
| Secondary modules | 43 | 43 (23 agent / 16 template / 4 data-KB / per-derivation: 24−1+19+1) | PASS |
| Test count | 150 | 150 = 44 (hooks) + 81 (skills) + 11 (integration) + 14 (parity) | PASS |
| Security findings | 9 | SEC-001..SEC-009 in security-audit.md; SEC-009 RESOLVED, SEC-001..005 FIXED, SEC-006/007 ACCEPTED | PASS |
| Verification coverage | 2 full / 11 partial / 0 unverified | Matches vga v2 table (13 BCs total) | PASS |
| Holdout scenarios | 26 | HS-INDEX.md count; 4+4 CRITICAL + 16 HIGH + 1 MEDIUM + 1 bypass-guard | PASS |
| BC versions (all 13) | per-file headers | All versions match STATE.md rows (BC-3.01.001 v1.9, BC-3.02.001 v1.5, BC-3.03.001 v1.4, BC-3.04.001 v1.4, BC-3.05.001 v1.3, BC-3.06.001 v1.3, BC-4.01.001 v1.4, BC-4.02.001 v1.3, BC-4.03.001 v1.3, BC-4.04.001 v1.3, BC-5.01.001 v1.4, BC-6.01.001 v1.3, BC-6.01.002 v1.3) | PASS |
| Write-block entries | 10 | require-review.sh write-block block count verified | PASS |
| Allowlist entries | 21 | require-review.sh allowlist count verified | PASS |
| Review weights | 100% | Weight sum in require-review.sh honest-convergence scoring | PASS |
| VP namespace | VP-HOOK-020..023 (4 VPs) | All 4 present, no collisions | PASS |
| DI items open/resolved | 10 open, 4 resolved | Matches Drift Items table (DI-001/008/009/010 RESOLVED; DI-002..007/011..014 open) | PASS |
| SEC-009 resolution | RESOLVED | PR #15 merged, SHA d304fa5, BC-3.01.001 v1.7+ confirms fix | PASS |
| DI-013 status | PENDING HUMAN DECISION | Correctly flagged open; no disposition taken without human sign-off | PASS |
| Write-block ordering | before allowlist check | PR #15 fix confirmed in BC-3.01.001 and in recovered code | PASS |
| Semantic anchors | all construct-name | No remaining line-number-only anchors in any BC or conventions | PASS |

---

## Observations (not graded findings — cosmetic only)

1. **Revision-history ordering:** Several BC files list revision history in ascending order (oldest-first); the project convention appears to be newest-first. Inconsistent across BCs; no correctness impact. Recommended: align on newest-first at next spec touch.
2. **Invariant numbering gap:** BC-3.01.001 invariants jump from IC-3 directly to IC-5, skipping IC-4. The absence appears to be a legacy renumber artifact (IC-4 was merged into another invariant). No logic gap; but the numbering is cosmetically irregular.
3. **BC `status: draft` vs `status: active`:** Several recovered BCs carry `status: draft` in frontmatter. This is confirmed intentional — draft pending story-writer validation against implementation. Not a defect; but any consumer that filters on `status: active` would silently skip these. Noted for story-writer to advance statuses when stories are written.
4. **require-review subsystem label:** The BC-3.xx group is labeled "review gate" in the HS-INDEX subsection headers but "require-review hook" in STATE.md. Functionally identical; cosmetic terminology drift only.

---

## Final Assessment

The Phase 0 adversarial loop ran 13 passes and achieved the "loop until only observations" convergence bar. The corpus is accurate, honest, and internally consistent.

**Notable outcomes from the adversarial loop:**
- Discovered and fixed a **live shipped authorization-gate bypass** in v0.9.0 (SEC-009 / PR #15): require-review evaluated its allowlist before the write-block using unanchored substring matching, making the auth gate bypassable.
- All SEC-001..005 security findings resolved via PR #13 (merged), plus branch protection and gitignored secrets.
- Anchor-churn class structurally retired via construct-name/@test-NAME references — no future line-shift will invalidate BC citations.
- 7 process-gaps codified for cycle-close integration.
- 26 holdout scenarios seeded as regression guards.

**Open items carried to Phase 0 gate (none blocking):**
- DI-004, DI-005, DI-006, DI-007, DI-011, DI-014 — target: first Feature Mode cycle
- DI-012, DI-013 — PENDING HUMAN DECISION at Phase 0 gate

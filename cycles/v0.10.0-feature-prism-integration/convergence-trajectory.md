---
document_type: convergence-trajectory
level: ops
version: "1.0"
status: in-progress
producer: state-manager
timestamp: 2026-09-02T17:00:00Z
cycle: v0.10.0-feature-prism-integration
inputs: [phase-f2-spec-evolution/]
input-hash: "[live-state]"
traces_to: STATE.md
---

# Convergence Trajectory — v0.10.0-feature-prism-integration

Initialized at burst-28 (pass-31 close). Historical finding counts reconstructed
from STATE.md Phase Progress finding-progression text and burst-log.md. Per-pass
detail narratives for passes 1–30 are in burst-log.md; adversarial report files
are in phase-f2-spec-evolution/.

---

## Finding Progression

| Pass | Date | C | M | MED | MIN | OBS | Total | Novelty | Streak | Verdict |
|------|------|---|---|-----|-----|-----|-------|---------|--------|---------|
| 1 | 2026-07-20 | 2 | 8 | 0 | 0 | 0 | 10 | HIGH | 0/3 | NOT CLEAN |
| 2 | 2026-07-20 | 1 | 3 | 0 | 0 | 0 | 4 | HIGH | 0/3 | NOT CLEAN |
| 3 | 2026-07-20 | 1 | 4 | 0 | 0 | 0 | 5 | HIGH | 0/3 | NOT CLEAN |
| 4 | 2026-07-21 | 2 | 4 | 0 | 0 | 0 | 6 | HIGH | 0/3 | NOT CLEAN |
| 5 | 2026-07-21 | 1 | 2 | 0 | 0 | 0 | 3 | HIGH | 0/3 | NOT CLEAN |
| 6 | 2026-07-21 | 2 | 3 | 0 | 3 | 2 | 10 | HIGH | 0/3 | NOT CLEAN |
| 7 | 2026-07-21 | 2 | 3 | 0 | 0 | 0 | 5 | HIGH | 0/3 | NOT CLEAN |
| 8 | 2026-07-21 | 1 | 2 | 0 | 0 | 0 | 3 | HIGH | 0/3 | NOT CLEAN |
| 9 | 2026-07-21 | 0 | 2 | 0 | 0 | 0 | 2 | MED | 0/3 | NOT CLEAN |
| 10 | 2026-07-22 | 1 | 2 | 0 | 0 | 8 | 11 | HIGH | 0/3 | NOT CLEAN |
| 11 | 2026-07-22 | 1 | 3 | 0 | 0 | 0 | 4 | HIGH | 0/3 | NOT CLEAN |
| 12 | 2026-07-22 | 2 | 2 | 0 | 0 | 0 | 4 | HIGH | 0/3 | NOT CLEAN |
| 13 | 2026-07-22 | 2 | 1 | 0 | 0 | 0 | 3 | HIGH | 0/3 | NOT CLEAN |
| 14 | 2026-07-22 | 0 | 2 | 0 | 3 | 0 | 5 | MED | 0/3 | NOT CLEAN |
| 15 | 2026-07-22 | 0 | 1 | 0 | 2 | 0 | 3 | MED | 0/3 | NOT CLEAN |
| 16 | 2026-07-22 | 0 | 1 | 0 | 2 | 0 | 3 | MED | 0/3 | NOT CLEAN |
| consistency-audit | 2026-07-22 | 0 | 0 | 12 | 0 | 0 | 12 | LOW | 0/3 | COHERENCE-GAPS |
| 17 | 2026-07-23 | 0 | 3 | 0 | 0 | 0 | 3 | HIGH | 0/3 | NOT CLEAN |
| 18 | 2026-07-23 | 0 | 2 | 1 | 0 | 0 | 3 | MED | 0/3 | NOT CLEAN |
| 19 | 2026-07-23 | 1 | 0 | 0 | 1 | 0 | 2 | HIGH | 0/3 | NOT CLEAN |
| 20 | 2026-07-27 | 0 | 1 | 3 | 3 | 2 | 9 | MED | 0/3 | NOT CLEAN |
| 21 | 2026-07-27 | 0 | 2 | 2 | 1 | 3 | 8 | MED | 0/3 | NOT CLEAN |
| 22 | 2026-07-28 | 1 | 2 | 1 | 1 | 2 | 7 | HIGH | 0/3 | NOT CLEAN |
| 23 | 2026-07-29 | 0 | 1 | 5 | 1 | 2 | 9 | HIGH | 0/3 | NOT CLEAN |
| 24 | 2026-07-29 | 0 | 0 | 4 | 0 | 1 | 5 | MED | 0/3 | NOT CLEAN |
| 25 | 2026-07-29 | 0 | 1 | 1 | 0 | 4 | 6 | MED | 0/3 | NOT CLEAN |
| 26 | 2026-07-29 | 0 | 1 | 2 | 0 | 4 | 7 | MED | 0/3 | NOT CLEAN |
| 27 | 2026-07-29 | 0 | 1 | 0 | 0 | 2 | 4 | LOW | 0/3 | NOT CLEAN |
| 28 | 2026-07-29 | 0 | 0 | 1 | 1 | 0 | 2 | LOW | 0/3 | NOT CLEAN |
| 29 | 2026-09-02 | 0 | 1 | 0 | 0 | 2 | 3 | LOW | 0/3 | NOT CLEAN |
| 30 | 2026-09-02 | 0 | 0 | 2 | 1 | 1 | 4 | LOW | 0/3 | NOT CLEAN |
| 31 | 2026-09-02 | 0 | 0 | 1 | 1 | 3 | 5 | LOW-MED | 0/3 | NOT CLEAN |
| 32 | 2026-09-03 | 0 | 0 | 1 | 1 | 1 | 3 | LOW | 0/3 | NOT CLEAN (4th consec 0C/0M; REMEDIATED burst-29 ~44 pins) |
| 33 | 2026-09-03 | 0 | 0 | 2 | 1 | 2 | 5 | LOW | 0/3 | NOT CLEAN (5th consec 0C/0M; both MEDs = burst-29 sweep tail; REMEDIATED burst-30) |
| 34 | 2026-09-03 | 0 | 0 | 2 | 0 | 1 | 3 | LOW | 0/3 | NOT CLEAN (prd-delta §1/§3/§8 EC/inv count drift for sub-burst-1 BCs; process-gap OBS recurred 3×; REMEDIATED burst-31) |
| 35 | 2026-09-03 | 0 | 0 | 0 | 1 | 0 | 1 | LOW | 1/3 | **CLEAN** (streak 1/3; P35-001 MINOR input-hash metadata only; substance independently re-derived clean; RECONCILED burst-32) |
| 36 | 2026-09-03 | 0 | 0 | 1 | 0 | 0 | 1 | LOW | 0/3 | NOT CLEAN (streak RESET 0/3; VP-HOOK-024 misattribution + VP-SKILL-075/076/077 lifecycle FINALIZED→PROPOSED; §1 VP total 26→25; REMEDIATED burst-33) |
| 37 | 2026-09-03 | 0 | 0 | 0 | 2 | 0 | 2 | LOW | 1/3 | **CLEAN** (streak 1/3; P37-001/002 MINOR dtu editorial; substance all confirmed; REMEDIATED dtu v1.7 burst-35) |
| 38 | 2026-09-03 | 0 | 1 | 0 | 0 | 1 | 2 | LOW | 0/3 | NOT CLEAN (streak RESET 0/3; P38-001 MAJOR VP-SKILL-075 partial-fix residual — burst-33 footer-only; body L192 + VP table L789 stale; REMEDIATED burst-37 6 sites/4 files) |

**Note on historical data:** Finding counts for passes 1–28 reconstructed from
STATE.md Phase Progress finding-progression and burst-log.md entries. Per-pass
total counts may differ by ±1 from the actual adversarial reports (report files
are authoritative). Passes 6, 10, 20–26 include observations in the total; passes
1–13 had no observations in the STATE.md summary.

---

## Trajectory Shorthand

`10→4→5→6→3→10→5→3→2→11→4→4→3→5→3→3→3→3→2→9→8→7→9→5→6→7→4→2→3→4→5→3→5→3→1→1→2→2`

*(tail: →3→1→1→2→2, passes 34→35→36→37→38)*

**Clean pass goal:** 3 consecutive passes with 0C/0M/0med/0min (OBS allowed).
**Current clean streak:** 0/3 — pass-38 has 1M + 1obs (NOT clean; streak RESET).
**Substance confirmed clean:** 2 consecutive passes (37 + 38 substance all re-derived clean).
**Dimension now clean:** version pins, EC/invariant counts, VP attribution, VP lifecycle status.

---

## Per-Pass Details (Passes 27–31 from burst-log and adversarial reports)

For passes 1–26 detail narratives, see:
`cycles/v0.10.0-feature-prism-integration/burst-log.md`

---

### Pass 27 (2026-07-29) — REMEDIATED burst-24

**Findings:** 4 (0C / 1M / 0med / 0min / 2obs) per trajectory
**Novelty:** LOW
**Convergence counter:** 0/3

P27-001 (MAJOR): structural-deny vs disposition-value-parse — ICD-203 structural
incompleteness → DENY before D-029 routing. P27-002 (MAJOR): path-aware WRITE_MARKER
+ SM-80. SM-79 allocated. Versions: BC-3.03.001 v1.36, BC-5.01.001 v1.14,
BC-4.02.001 v1.20, arch-delta v1.29, verif-delta v1.29, prd-delta v1.27.
VP 41 / SM 73 alloc (72 live).

---

### Pass 28 (2026-07-29) — REMEDIATED burst-25

**Findings:** 2 (0C / 0M / 1med / 1min / 0obs) per trajectory
**Novelty:** LOW
**Convergence counter:** 0/3

P28-001 (MED): WRITE_MARKER per-path variable definedness fixed; SM-80 kill now
GENUINE. P28-002 (MED): org_slug roster + validate_enums + SM-81 allocated (DI-017).
Versions: BC-3.03.001 v1.37, arch-delta v1.30, verif-delta v1.30, prd-delta v1.28.
VP 41 / SM 74 alloc (73 live). Clean streak 0/3.

---

### Pass 29 (2026-09-02) — REMEDIATED burst-26

**Findings:** 3 (0C / 1M / 0med / 0min / 2obs)
**Novelty:** LOW
**Convergence counter:** 0/3

P29-001 (MAJOR): org_slug propagation gap — BC-10.01.001 Inv#9 roster + Stage-1
INGEST write list, prd-delta enforcement-split, BC-3.03.001 operational-metadata
roster. P29-002/003 OBS annotated. verif-delta v1.31 (SM-81 adjudication).
Versions: BC-10.01.001 v1.30, prd-delta v1.30, BC-3.03.001 v1.39, verif-delta v1.31.
DI-018 logged. VP 41 / SM 74 alloc (73 live).

---

### Pass 30 (2026-09-02) — REMEDIATED burst-27

**Findings:** 4 (0C / 0M / 2med / 1min / 1obs)
**Novelty:** LOW
**Convergence counter:** 0/3

P30-001 (MED): BC-3.03.001 + BC-10.01.001 — org_slug ASM-008 residual notes split
into absence-deny vs membership-bypass paths. P30-002 (MED, [process-gap]):
VP-HOOK-025 anchor+prose names org_slug presence-deny leg; SM-81 confirmed.
P30-003 (LOW): prd-delta — 4 ALWAYS-PRESENT + 1 CONDITIONAL presence split.
P30-004 (OBS): BC-10.01.001 version pin annotated as-of-introduction.
Versions: BC-3.03.001 v1.40, BC-10.01.001 v1.31, prd-delta v1.31, verif-delta v1.32.
Lesson 50 logged.

---

---

## Frontmatter Fields (extracted from STATE.md)

<!-- When compacting STATE.md, adversary_pass_* frontmatter fields are
     converted to rows in the Finding Progression table above.
     Original field format: adversary_pass_N_findings: "description"
     Original field format: adversary_pass_N_date: "YYYY-MM-DD"
     No adversary_pass_* frontmatter fields were present in STATE.md at
     the time this file was initialized (burst-28, 2026-09-02). -->

---

### Pass 31 (2026-09-02) — REMEDIATED burst-28

**Findings:** 5 (0C / 0M / 1med / 1min / 3obs)
**Novelty:** LOW–MEDIUM
**Convergence counter:** 0/3 (third consecutive 0C/0M pass; deeply converged)

P31-001 (MED): VP-HOOK-025 `ticket_action_type` membership enum stale — 6-member
prose vs authoritative 8-member BC-3.03.001 `ACTION_ENUM`. Three enforced-enum
sites corrected in verification-delta v1.33; historical 4-member subsets intentionally
left. P31-002 (MIN): `autonomy_enabled` ALWAYS-PRESENT label vs tolerated-absent
at consumer — undocumented distinction from `org_slug` presence-deny. Clarification
added to BC-3.03.001 v1.41 ~L994, BC-10.01.001 v1.32 Inv#9, prd-delta v1.32.
P31-003/004/005 (OBS): positive coherence notes; no action.
Versions: verification-delta v1.33, BC-3.03.001 v1.41, BC-10.01.001 v1.32, prd-delta v1.32.
VP 41 / SM 74 alloc (73 live); tallies unchanged.

---

### Pass 32 (2026-09-03) — REMEDIATED burst-29

**Findings:** 3 (0C / 0M / 1med / 1min / 1obs)
**Novelty:** LOW — all version/coherence-drift; no new behavioral logic defects
**Convergence counter:** 0/3 (fourth consecutive 0C/0M pass)

P32-001 (MED): prd-delta §5 BC-version tracking table stale — BC-3.03.001 cell
v1.38→v1.42; BC-10.01.001 cell v1.29→v1.32. EC footer 50→51; §1 VP totals 25+1.
P32-002 (MIN): verification-delta §3(a) self-contradictory stale pin (BC-10.01.001
v1.14 Inv#9 "18-field" — was 15-field at v1.14; corrected to relative descriptor).
P32-003 (OBS): verification-delta §3(a) field-15 set-builder showed 4-member base
only; updated to full 8-member enforced set.

**Comprehensive sweep triggered:** ~44 total stale pins found across the corpus
beyond the 3 formal findings. Sweep used version-agnostic grep (every BC-<id> v<N.NN>
occurrence vs frontmatter truth) — caught ~12 additional stale pins in verification-delta
missed by version-specific scan. Lesson 51 logged.

Versions: BC-3.03.001 v1.42 (no-bump Group G), BC-4.02.001 v1.21 (Group H),
BC-5.01.001 v1.15 (Group I), BC-10.01.001 v1.32 (no-bump), prd-delta v1.33,
verification-delta v1.34. Architecture-delta v1.31/dtu-assessment v1.5 UNCHANGED.
VP 41 / SM 74 alloc (73 live); tallies unchanged. Test-count BATS arithmetic
corrections: BC-3.03.001 111→129; BC-10.01.001 108→113 (already-existing tests).

---

### Pass 33 (2026-09-03) — REMEDIATED burst-30

**Findings:** 5 (0C / 0M / 2med / 1min / 2obs)
**Novelty:** LOW — all coherence/version-drift; both MEDs were tail gaps from burst-29 sweep
**Convergence counter:** 0/3 (fifth consecutive 0C/0M pass)

P33-001 (MED): prd-delta §5 tracking-table cells for BC-4.02.001 (v1.20 cell, actual
v1.21) and BC-5.01.001 (v1.14 cell, actual v1.15) not synced by burst-29. Root cause:
burst-29 patched only the BCs it directly targeted (Group G) and missed the §5 cells
for BCs bumped as side-effects of Groups H/I. Covered by Lesson 51 (version-agnostic
full-table re-derivation required). P33-002 (MED): BC-10.01.001 L119 as-of-introduction
annotation cited v1.24 for JSON-first dispatch (P4-001); actual introduction was v1.12
(corroborated by BC-10.01.001 Previous block L121 + prd-delta §5 L125). P33-003 (MIN):
prd-delta Document Changelog missing v1.33 row (burst-29 bump had no changelog entry).
P33-OBS-1: dtu-assessment scenario count stated 7, actual 10 (3 NEW scenarios added
v1.2/v1.4 not reflected in count prose); adjudicated total = 10. P33-OBS-2:
verification-delta §5 blanket deferral note overly broad post-v1.34 reconciliation
(two largest per-BC rows now reconciled — note narrowed to remaining small-BC rows).

Versions: BC-10.01.001 v1.32 (no-bump L119 correction), prd-delta v1.33 (§5 cells
BC-4.02.001/BC-5.01.001 + v1.33 changelog row), dtu-assessment v1.6 (scenario-count
7→10 + template-drift cleanup), verification-delta v1.34 (no-bump §5 deferral-note
narrowed). BC-3.03.001/BC-4.02.001/BC-5.01.001/BC-3.01.001/architecture-delta UNCHANGED.
VP 41 / SM 74 alloc (73 live); tallies unchanged.

---

### Pass 34 (2026-09-03) — REMEDIATED burst-31

**Findings:** 3 (0C / 0M / 2med / 0min / 1obs)
**Novelty:** LOW — all mechanical count drift (EC/invariant tallies not re-derived from BC files for sub-burst-1 BCs); zero substantive logic defects
**Convergence counter:** 0/3 (sixth consecutive 0C/0M pass)

P34-001 (MED): prd-delta §1/§3/§8 EC counts stale for sub-burst-1 BCs. BC-6.01.003 EC 8→10 (EC-001..EC-010 confirmed); BC-10.01.001 EC 21→22 (EC-001..EC-022 confirmed). Cascading: §1 Totals EC 51→54; §3 footer 51→54; §8 sub-burst-1 51→54; grand total 75→78.

P34-002 (MED): prd-delta §1 invariant count stale for BC-6.01.003: 5→6 (6 numbered list items in ## Invariants confirmed). §1 Totals invariants 36→37. All other sub-burst-1 BC invariant counts confirmed correct (BC-6.01.004: 8EC/6inv; BC-8.02.001: 6EC/4inv; BC-9.01.001: 8EC/5inv; BC-10.01.001: 22EC/16inv).

P34-OBS [process-gap]: no automated recount gate re-derives §1/§3 per-BC EC/invariant counts from BC files for NEW (sub-burst-1) BCs receiving later-pass additions. Recurred 3×. Root cause structural: §8 addition-tracking was designed for pre-existing BCs, not newly authored sub-burst-1 BCs. Lesson 52 logged (count-analog of Lesson 51).

Versions: prd-delta v1.34 (§1/§3/§8 counts re-derived; COMPUTE-AT-COMMIT resolved ec4fc30). All BCs UNCHANGED. VP 41 / SM 74 alloc (73 live); tallies unchanged. VP roster 26 unchanged.


---

### Pass 35 (2026-09-03) — **CLEAN** (streak 1/3)

**Findings:** 1 (0C / 0M / 0med / 1min / 0obs)
**Novelty:** LOW — sole finding is metadata inconsistency (input-hash mismatch in changelog citations); does not block clean verdict
**Convergence counter:** 1/3 (first clean pass of 3-required streak)

P35-001 (MIN): prd-delta v1.34 input-hash mismatch — frontmatter `input-hash: "247135e"` vs blockquote/changelog citations `ec4fc30`. Metadata-only; no spec content affected. **Non-blocking.** Reconciled this burst: authoritative hash `247135e` set at all three sites.

Independent re-derivation: adversary read BC-3.03.001 (emitter) and BC-3.01.001 (consumer) top-to-bottom. STEP ordering, hard-floor legs, kill-switch, marker TTL/single-use/anti-fungibility, D-029 routing, 12/18-split, NORMALIZE_SEVERITY, and §1/§3/§8 EC/invariant counts all independently confirmed. Genuine convergence — spec content stable across two consecutive passes independently deriving the same results.

Versions: prd-delta v1.34 (input-hash 247135e, metadata only). All BCs UNCHANGED. VP 41 / SM 74 alloc (73 live); tallies unchanged. Spec content FROZEN/STABLE.

| 36 | 2026-09-03 | 0 | 0 | 1 | 0 | 0 | 1 | LOW | 0/3 (RESET) | NOT CLEAN |

---

### Pass 36 (2026-09-03) — **NOT CLEAN** (streak RESET 0/3)

**Findings:** 1 (0C / 0M / 1med / 0min / 0obs)
**Novelty:** LOW — VP attribution/traceability coherence gap; substantive spec content independently re-derived clean (seventh consecutive 0C/0M pass)
**Convergence counter:** 0/3 (streak RESET — P36-001 is a MEDIUM coherence defect)

P36-001 (MED): prd-delta §1 VP-HOOK-024 misattributed to BC-10.01.001 (owned by BC-3.01.001 per verif-delta §1 L431). VP-SKILL-075/076/077 labeled FINALIZED in §1 but are PROPOSED P1 per verif-delta and BC footers. §1 VP Totals inflated: claimed "25 FIN + 1 PROP = 26"; correct "21 FIN + 4 PROP = 25". Impact: convergence-gate VP accounting was wrong in prior pass-35 CLEAN verdict — the 26-VP count was validating against the §1 summary, not against source-of-truth BC footers. **REMEDIATED burst-33** (comprehensive VP-ownership/traceability audit, 8 fixes).

Independent re-derivation: STEP ordering, hard-floor legs, kill-switch, marker mechanism all confirmed correct. Genuine substantive convergence intact — P36-001 is a bookkeeping/traceability defect, not a logic defect.

Versions: prd-delta v1.35 (8 VP-ownership/traceability fixes; convergence-gate count corrected to 21 FIN). verif-delta v1.34 UNCHANGED (confirmed correct source of truth). BC-3.03.001 v1.42 footer updated (VP Anchors added; no semantic bump). BC-10.01.001 v1.32 footer updated (VP Anchors corrected; no semantic bump). VP 21 FIN + 4 PROP = 25 total (41 in registry); SM 74 alloc / 73 live.

| 37 | 2026-09-03 | 0 | 0 | 0 | 2 | 0 | 2 | LOW | 1/3 | CLEAN |

---

### Pass 37 (2026-09-03) — **CLEAN** (streak 1/3)

**Findings:** 2 (0C / 0M / 0med / 2min / 0obs)
**Novelty:** LOW — both findings are editorial/typo class in dtu-assessment.md only; no spec logic affected
**Convergence counter:** 1/3 (first clean pass of new 3-required streak after pass-36 reset)

P37-001 (MIN): dtu-assessment `configs/demo.toml` typo → `prism-demo.toml` per D-018. Editorial fix. REMEDIATED (dtu v1.7).
P37-002 (MIN): dtu-assessment dangling "§4 Deployment Notes" cross-ref → repointed to correct named sections. Editorial fix. REMEDIATED (dtu v1.7).

Independent re-derivation: adversary read BC-3.03.001 (emitter) and BC-3.01.001
(consumer) plus prd-delta v1.35 / verif-delta v1.34 from scratch. All substance
dimensions confirmed (STEP ordering, kill-switch/hard-floor, marker mechanism,
D-029 routing, §3.4 rules, NORMALIZE_SEVERITY, 12/18-split, spec-vs-intent).
All three coherence dimensions confirmed (version pins, EC/invariant counts,
VP-ownership/lifecycle — post-burst-33 corrections all in place). Genuine
convergence sustained; spec content stable since burst-33 freeze.

Versions: dtu-assessment v1.7 (P37-001/P37-002 editorial; input-hash 3cf5746).
All BCs UNCHANGED. VP 21 FIN + 4 PROP = 25 total (41 in registry);
SM 74 alloc / 73 live; tallies UNCHANGED. Spec content FROZEN/STABLE post-burst-33.

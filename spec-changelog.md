---
document_type: spec-changelog
project: secops-factory
---

# Spec Changelog

Track all spec version changes. Most recent version first.

---

## [1.1.0] - 2026-07-20 (patch edits 2026-07-21/22 — not a version bump)

### F2 Pass-14 Burst-10 Follow-up Coherence Correction — VP-SKILL-076/077 Disentanglement (2026-07-22) — spec remains 1.1.0

Orchestrator-caught conflation at burst-10 close: VP-SKILL-076 was ambiguously cited for BOTH
the P14-002 setup-time `jira_project_key` charset gate AND the P14-005 onboard-customer AD-017
credential-decline path — the exact one-ID-two-behaviors anti-pattern lesson 37 (P14-005) flagged.
Disentanglement: VP-SKILL-076 is scoped STRICTLY to P14-002 (setup-time key charset validation).
NEW VP-SKILL-077 (next-free after 076; B-STR; SM-55 skipped — mirrors VP-SKILL-054 no-mutant
precedent) covers onboard-customer AD-017 credential-decline (BC-6.01.003 Inv#1/EC-008),
RESTORING the coverage orphaned when VP-SKILL-053 was repurposed. VP-SKILL-053 annotation
corrected from "original AD-017 coverage moved to VP-SKILL-076" to
"RESTORED via NEW VP-SKILL-077 (VP-SKILL-076 is the unrelated setup-time key charset gate)".
37 VPs / 48 mutants / ~367 test vectors.

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/verification-delta.md | v1.17 | v1.18 | VP-SKILL-076/077 disentanglement: VP-SKILL-076 scoped strictly to P14-002 (setup-time jira_project_key charset gate); NEW VP-SKILL-077 (P14-005; B-STR; SM-55 skipped — mirrors VP-SKILL-054) covers onboard-customer AD-017 credential-decline (BC-6.01.003 Inv#1/EC-008); VP-SKILL-053 annotation corrected ("moved to VP-SKILL-076" → "RESTORED via VP-SKILL-077"); VP count 36→37 |
| phase-0-ingestion/behavioral-contracts/BC-6.01.003.md | v1.6 [ID-sync per FV] | v1.7 | burst-10 follow-up: Inv#1/EC-008 VP anchor → VP-SKILL-077 (AD-017 credential-decline); Inv#6/EC-010 VP anchor → VP-SKILL-076 (setup-time key charset gate only); no combined P14-002/P14-005 cite on VP-SKILL-076 |

---

### F2 Pass-14 Remediation Edits — Burst 10 (2026-07-22) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 10). Root findings:
P14-001 (MAJOR — NVD/CVSS clean-separation never propagated to BC-10.01.001 loop contract:
NORMALIZE_SEVERITY table had "NVD: CVSS float 0.0–10.0→LOW…CRITICAL" row + "8.5 for NVD CVSS"
field-16 example + Inv#14 Stage-1 "NVD CVSS float" text; cross-artifact contradiction with
P11-003/D-013 clean-separation decision; FV also removed 2 stale CVSS-boundary fixtures from
VP-SKILL-074),
P14-002 (MAJOR — setup-time jira_project_key charset validation (BC-6.01.001 PC#12/EC-014 +
BC-6.01.003 Inv#6/EC-010, added P13-002) had no covering VP; runtime deny via VP-HOOK-032 only;
no PREVENTIVE setup-time gate; VP-SKILL-076 + SM-54 allocated),
P14-003 (MINOR — PRISM-DEMO residue in BC-3.01.001 test vectors; P13-002 "throughout" claim
missed this BC),
P14-004 (MINOR — stale "17-field" in BC-10.01.001 Inv#9 field-2 parenthetical + VP-HOOK-028
description, both swept to "18-field"),
P14-005 (MINOR — VP-SKILL-053/057 repurposing orphaned onboard-customer AD-017 coverage:
VP-SKILL-053 moved from AD-017 credential-provisioning to idempotent-dir (EC-006); AD-017
coverage RESTORED via NEW VP-SKILL-077 — **CORRECTED by burst-10 follow-up**: burst-10
originally cited VP-SKILL-076; VP-SKILL-076 is the unrelated setup-time key charset gate;
VP-SKILL-057 moved from sensor-metrics org_slug scoping to naming-compliance D-DEC-006
pass-9/P9-005).
VP-SKILL-076 + SM-54 allocated (burst-10); VP-SKILL-077 NO-SM allocated (burst-10 follow-up
coherence correction — AD-017 credential-decline, P14-005). 37 VPs / 48 mutants / ~367 test vectors.

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.16 | v1.17 | P14-001..P14-005 doc-hygiene per §8.30 routing (FV/PO edits outside arch scope; NORMALIZE_SEVERITY reaffirmed) |
| phase-f2-spec-evolution/verification-delta.md | v1.16 | v1.17 | P14-002: VP-SKILL-076 FINALIZED + SM-54; P14-001: VP-SKILL-074 CVSS fixtures removed; P14-005: VP-SKILL-053/057 repurposing annotated; version-coherence sweep: §5 table headers + 13 VP anchor column entries updated |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.17 | v1.18 [ID-sync per FV] | P14-001: NORMALIZE_SEVERITY NVD row removed; field-16 Cyberint example; Inv#14 Stage-1 NVD cleaned; P14-004: "17-field"→"18-field" (Inv#9 + VP-HOOK-028 ref); spot-check: canonical test vectors PRISM-DEMO→PRISMDEMO |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.21 | v1.22 | P14-003 propagation: PRISM-DEMO→PRISMDEMO in test vectors; version bump for coherence |
| phase-0-ingestion/behavioral-contracts/BC-3.01.001.md | v1.21 | v1.22 | P14-003: PRISM-DEMO→PRISMDEMO in tokenizer test vectors |
| phase-0-ingestion/behavioral-contracts/BC-6.01.003.md | v1.5 | v1.6 [ID-sync per FV] | P14-005: VP-SKILL-TBD→VP-SKILL-076 at 5 locations; [ID-sync per FV] in frontmatter modified[]+revision history; Invariant #1 dedicated-VP sentence updated; EC-008 interim-anchor updated; VP table row finalized; VP Anchors updated |

---

### F2 Pass-13 Remediation Edits — Burst 9 (2026-07-22) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 9). Root findings:
P13-001 (CRITICAL — MARKDOWN_COMMENT_PATH ELIMINATED: the markdown path NEVER issues an
autonomous comment marker for any disposition; FP → allow-without-marker (hook cannot evaluate
scored_priority/asset_type from 12-field markdown; no known-FP store cross-check applies);
non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH; VP-HOOK-031 guarantee (c) rewritten;
SM-52 (FP-comment-marker revert) allocated; D-017; recurring CRITICAL — P12-002 closed TP
masquerade, P13-001 closes residual FP branch),
P13-002 (CRITICAL — PRISMDEMO key correction: canonical RC demo key PRISM-DEMO is NOT a
valid Jira project key (hyphens disallowed; ^[A-Z][A-Z0-9]+$ correct-for-Jira; regex correct —
only example wrong); corrected to PRISMDEMO throughout; setup-time validation added to
BC-6.01.001 (activate Postcondition #12) + BC-6.01.003 (onboard-customer Invariant #6);
non-conformant key rejected with explicit user-facing error at setup; D-018),
P13-003 (MAJOR — strict parse grammar: parse_disposition_from_markdown reads ONLY canonical
Disposition heading value; exact allowlist {TP,FP,BTP,Indeterminate}+canonical long forms;
PARSE_FAIL → non-FP → MARKDOWN_REVIEW_PATH (never allow-without-marker); no full-doc scan;
parse_autonomy_enabled_from_markdown reads ONLY dedicated structured field; explicit-true-only;
embedded-in-code-fence → false; SM-53 (disposition-scan revert) allocated),
P13-004 (MINOR — BC-3.03.001 PC#2 prose updated to reflect post-P13-001 routing;
cross-ref updated from (P11-004) to (P11-004 / P12-002 / P13-001)).
SM-52/SM-53 allocated. D-017/D-018 recorded. 35 VPs / 47 mutants / ~360 test vectors.

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.15 | v1.16 | P13-001: MARKDOWN_COMMENT_PATH ELIMINATED (§8.29 item 1; VP-HOOK-031 guarantee c rewritten; SM-P13-A → SM-52 [ID-sync per FV]); P13-002: PRISMDEMO rename + D-DEC-008 hyphen-free constraint + setup-time validation requirement (§8.28); P13-003: strict parse grammar spec (§8.29 item 3); P13-004: PO note for BC-3.03.001 PC#2 (§8.28) |
| phase-f2-spec-evolution/verification-delta.md | v1.15 | v1.16 | P13-001: VP-HOOK-031 guarantee (c) REWRITTEN (FP→allow-without-marker; SM-52 kill target; prior FP→comment vector RETIRED); SM-52 allocated; P13-002: 17 current-body PRISM-DEMO references → PRISMDEMO; P13-003: strict parse grammar adversarial vectors + SM-53 allocated; version-coherence sweep: BC-3.03.001 v1.20→v1.21 in §5, BC-6.01.001 v1.6→v1.7 in VP table |
| phase-f2-spec-evolution/prd-delta.md | v1.14 | v1.15 | P13-002: PRISMDEMO rename in RC demo key references; BC-3.03.001 v1.20→v1.21, BC-6.01.001 v1.6→v1.7, BC-6.01.003 v1.4→v1.5 in §5 BC version table |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.20 | v1.21 [ID-sync per FV] | P13-001: MARKDOWN_COMMENT_PATH ELIMINATED (Trust basis + VP-HOOK-031 property + test vectors updated; SM-52 kill target); P13-002: PRISMDEMO rename in test vectors and fallback hint; P13-003: strict parse grammar for parse_disposition_from_markdown + parse_autonomy_enabled_from_markdown; P13-004: PC#2 outcome prose updated (P11-004/P12-002/P13-001 cross-ref); SM-P13-A → SM-52 [ID-sync per FV] |
| phase-0-ingestion/behavioral-contracts/BC-6.01.001.md | v1.6 | v1.7 | P13-002: setup-time jira_project_key charset validation (^[A-Z][A-Z0-9]+$) added to Postcondition #12; non-conformant key rejected with explicit user-facing error at activation; EC-013 example updated to PRISMDEMO; EC-014 added (hyphen-containing key rejected) |
| phase-0-ingestion/behavioral-contracts/BC-6.01.003.md | v1.4 | v1.5 | P13-002: per-org jira_project_key charset validation added to Invariant #6; non-conformant key refused with explicit error and not stored at onboard-customer; EC-010 added |
| feature/prism-integration-handoff-brief.md | (no version) | (no version) | P13-002 (human-authorized): PRISMDEMO rename in §3.5/§4.1 demo key examples only |

---

### F2 Pass-12 Remediation Edits — Burst 8 (2026-07-22) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 8). Root findings:
P12-001 (CRITICAL — ticket_id/jira_project_key concatenated unescaped into command_pattern
regex; regex-injection (ticket_id='.*' broadens anchored match); latent since original marker
design; NOT ASM-008-covered; fix: charset-validation ^[A-Z][A-Z0-9]+-[0-9]+$ /
^[A-Z][A-Z0-9]+$ at 5 interpolation sites + regex-escape; O7 rule codified),
P12-002 (CRITICAL — human-comment markdown path (P11-004) selectable by autonomous loop;
bypasses kill switch + scored_priority/asset_type floors; issues live comment marker;
fix: four-guarantee redesign — (a) kill-switch gate: autonomy_enabled absent/≠true →
allow-without-marker; (b) route-to-review: disposition≠FP → create-review/comment-review;
(c) FP + floors pass → comment marker; (d) ticket_id charset-validated; D-015),
P12-003 (MAJOR — fast-path scored_priority raw CRITICAL/MEDIUM not in SCORED_PRIORITY_ENUM
{CRIT,HIGH,MED,LOW} → fail-closed deny 30-40% known-FP volume; fix: SEVERITY_TO_SCORED_PRIORITY_MAP;
known-FP fast-path EXEMPT from HIGH/CRIT floor per D-016; residual → DI-015),
P12-004 (MAJOR — BC-4.05.001 assess-priority never emits/maps scored_priority (field 18);
producer/consumer contract gap; fix: priority output IS scored_priority field 18),
P12-005 (MINOR — BC-6.01.003 Invariant#12 nonexistent reference; fix: → Postcondition#12),
P12-006 (MINOR — BC-8.02.001 stale traceability label),
P12-007 (process-gap — no regex-escape standing rule; fix: O7 codified in §0).
VP-HOOK-032, SM-48/SM-49 (O7 charset-validation), SM-50/SM-51 (markdown-path guarantees) allocated.
D-015/D-016 recorded.

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.14 | v1.15 | P12-001: D-DEC-012 O7 rule codified + 5 interpolation-site charset-validation + regex-escape spec; §8.26.1 markdown-path four-guarantee redesign (D-015); §8.26.2 known-FP floor exemption (D-016); §8.27 SM-P12-A/B/C/D → SM-48/49/50/51 + VP-HOOK-032 allocations |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.19 | v1.20 [ID-sync per FV] | P12-001: VP-HOOK-032 + SM-48/SM-49 (O7 charset-validation at 5 command_pattern sites); P12-002: VP-HOOK-031 four-guarantee redesign + SM-50 (kill-switch gate) + SM-51 (route-to-review); P12-003: SEVERITY_TO_SCORED_PRIORITY_MAP note on fast-path |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.16 | v1.17 | P12-003: fast-path enum map (SEVERITY_TO_SCORED_PRIORITY_MAP: CRITICAL→CRIT, MEDIUM→MED) + EC-009 floor-exemption annotation + known-FP store integrity invariants |
| phase-0-ingestion/behavioral-contracts/BC-4.05.001.md | v1.3 | v1.4 | P12-004: priority output field mapped to scored_priority (field 18); producer/consumer contract closed |
| phase-0-ingestion/behavioral-contracts/BC-6.01.003.md | v1.3 | v1.4 | P12-005: Invariant#12 → Postcondition#12 mis-anchor corrected |
| phase-0-ingestion/behavioral-contracts/BC-8.02.001.md | v1.3 | v1.4 | P12-006: stale traceability label corrected |
| phase-f2-spec-evolution/verification-delta.md | v1.14 | v1.15 | P12-001/P12-007: VP-HOOK-032 NEW FINALIZED P0 (O7 interpolation-safety — SM-48/SM-49); P12-002: VP-HOOK-031 UPDATED four-guarantee redesign (SM-50/SM-51); P12-003: VP-HOOK-025/VP-HOOK-026 extended (fast-path enum map + known-FP floor exemption); version-coherence sweep: BC-3.03.001 v1.19→v1.20, BC-10.01.001 v1.16→v1.17, BC-4.05.001 v1.3→v1.4 in §5 + VP table |
| phase-f2-spec-evolution/prd-delta.md | v1.13 | v1.14 | P12-004/P12-005/P12-006: §5 New Version column updated for burst-8 BCs (BC-4.05.001 v1.3→v1.4, BC-6.01.003 v1.3→v1.4, BC-8.02.001 v1.3→v1.4); BC-3.03.001 v1.19→v1.20, BC-10.01.001 v1.16→v1.17 |

---

### F2 Pass-11 Remediation Edits — Burst 7 (2026-07-22) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 7). Root findings:
P11-001 (CRITICAL — STEP 1a re-normalizes from LLM-supplied native_severity/sensor_family;
severity floor still LLM-bypassable; "un-bypassable/independently-derived" claims withdrawn;
fix: reframe STEP 1a as consistency-only; reclassify native_severity as ASM-008-DEFERRED
symmetric with asset_type + scored_priority), P11-002 (MAJOR — STEP 1a exact-equality denies
legitimate Stage-5 recalibrations; HIGH/CRIT floor was keyed on recomputed_severity; fix:
two-field model with scored_priority field 18 + floor re-keyed to scored_priority), P11-003
(MAJOR — NVD/CVSS sensor_family absent from enum; CVSS influences scored_priority not
native_severity; fix: NVD/CVSS clean separation + CVSS-float vector removed from VP-HOOK-030),
P11-004 (MAJOR — 12-field investigation-markdown path contradictorily enters verdict emitter;
validate_enums() would deny analyst saves; fix: separate human-comment marker path with no
validate_enums()/STEP 1a on markdown), P11-005 (MINOR — BC-6.01.003 stale BC-9.01.001
cross-reference), P11-006 (MINOR — prd-delta BC version table stale for burst-7 BCs),
P11-007 (process-gap — false-closure language copy-propagated to 4 docs). VP-HOOK-031,
SM-46, SM-47 allocated. D-011..D-014 recorded.

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.13 | v1.14 | P11-001: STEP 1a reframed consistency-only; "un-bypassable" language withdrawn; D-012; P11-002: scored_priority field 18 + floor re-keyed to scored_priority; D-011; P11-003: NVD/CVSS clean separation; D-013; P11-004: separate human-comment marker path (PC#2 dispatch) — no validate_enums()/STEP 1a on 12-field markdown; D-014 |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.18 | v1.19 [ID-sync per FV] | P11-001: overstated STEP 1a trust-basis corrected; native_severity reclassified ASM-008-DEFERRED; P11-002: scored_priority floor bullet + SM-46 citation + VP-HOOK-026 VP table row update; P11-004: VP-HOOK-031 verification property section + VP table row for separate human-comment marker path + SM-47 citation |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.15 | v1.16 [ID-sync per FV] | P11-001: native_severity trust reclassified to ASM-008-DEFERRED residual (symmetric with asset_type + scored_priority); P11-002: field 18 scored_priority added; §3.9 floor re-keyed to scored_priority + SM-46 citation |
| phase-0-ingestion/behavioral-contracts/BC-5.01.001.md | v1.8 | v1.9 [ID-sync per FV] | P11-004: VP-HOOK-031 consumer citation added in Invariant #7 (investigate-event Stage 7 separate-path) |
| phase-0-ingestion/behavioral-contracts/BC-4.02.001.md | v1.8 | v1.9 [ID-sync per FV] | P11-004: VP-HOOK-031 consumer citation added in PC#4 (update-jira Stage 7 human-comment marker path) |
| phase-0-ingestion/behavioral-contracts/BC-6.01.003.md | v1.2 | v1.3 | P11-005: stale BC-9.01.001 cross-reference corrected; SM-46/SM-47 citations added as applicable |
| phase-f2-spec-evolution/verification-delta.md | v1.13 | v1.14 | P11-001: VP-HOOK-030 DOWNGRADED to consistency-only; "independently derives" language corrected; P11-002: field 18 scored_priority + SM-46 + VP-HOOK-026 floor legs (DETECTOR-LOW/SCORED-CRIT escalation vector); P11-003: CVSS-float SEVERITY-MISMATCH vector removed from VP-HOOK-030; P11-004: VP-HOOK-031 NEW FINALIZED P0 (separate human-comment marker path) + SM-47; version-coherence sweep: 19 BC-anchor cells updated (BC-10.01.001 v1.14→v1.16, BC-3.03.001 v1.17→v1.19, BC-4.02.001 v1.8→v1.9, BC-5.01.001 v1.8→v1.9) |
| phase-f2-spec-evolution/prd-delta.md | v1.12 | v1.13 | P11-006: §5 New Version column updated for all burst-7 BCs (BC-3.03.001 v1.18→v1.19, BC-10.01.001 v1.15→v1.16, BC-4.02.001 v1.8→v1.9, BC-5.01.001 v1.8→v1.9, BC-6.01.003 v1.2→v1.3); §1 module table BC version rows updated |

---

### F2 Pass-10 Remediation Edits — Burst 6 (2026-07-22) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 6). Root findings: P10-001
(CRITICAL — hard_floor_applies() keys on LLM-supplied verdict.severity/asset_type with no
hook-side cross-validation; O6 rule: inputs to hook-computed invariant must be hook-recomputable;
fix: STEP 1a SEVERITY-MISMATCH + 17-field schema extension), P10-002 (MAJOR — cron wrapper gate
never inspects audit.log fail-loud codes; Gate 2 grep added; ASM-015 BLOCKING gate documented),
P10-003 (MAJOR — WRITE_MARKER review-path allow-without-marker reintroduces silent-drop;
fix: review-path write failure → MARKER-WRITE-FAILED deny), P10-004 (MINOR — fallback_hint
dedup instruction missing full P9-007 dedup gate), P10-008 (MINOR — ASM-014 residual note
for comment-review kill-switch exemption scope), P10-009 (MINOR — per-org jira_project_key
in [[orgs]] entries). SM-44/SM-45 allocated. VP-HOOK-030 and VP-SKILL-075 allocated (FINALIZED P0).
O6 standing rule codified. D-009/D-010 recorded.

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.12 | v1.13 | P10-001: O6 standing rule codified §8.22; STEP 1a SEVERITY-MISMATCH design; D-DEC-013 NORMALIZE_SEVERITY hook-recomputation context; P10-002: Gate 2 cron wrapper audit.log grep §D-DEC-003; P10-009: per-org jira_project_key lookup order §8.23 |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.17 | v1.18 [ID-sync per FV] | P10-001: 17-field schema (native_severity field 16, sensor_family field 17); STEP 1a SEVERITY-MISMATCH; hard_floor_applies() takes recomputed_severity; VP-HOOK-030+SM-44 IDs synced; P10-003: WRITE_MARKER review-path fail-closed + SM-45; P10-004: fallback_hint dedup instruction; P10-008: ASM-014 residual note; 3 new canonical test vectors |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.14 | v1.15 [ID-sync per FV] | P10-001: Inv#9 17-field extension (fields 16+17 at Stage 1 INGEST); Inv#10 trust-basis correction (hook re-derives severity via NORMALIZE_SEVERITY, does not trust LLM-written verdict.severity); P10-002: PC#7 Gate 2 audit.log grep + ASM-015 BLOCKING gate; VP-SKILL-075 added (PC#7 citation, VP table row, VP Anchors footer) |
| phase-0-ingestion/behavioral-contracts/BC-6.01.003.md | v1.1 | v1.2 | P10-009: per-org jira_project_key in [[orgs]] entries; Postcondition #1 updated; Invariant #6 (per-org lookup order); EC-009 (per-org key supplied during onboard-customer) |
| phase-f2-spec-evolution/verification-delta.md | v1.12 | v1.13 | VP-HOOK-030 NEW FINALIZED P0 (STEP 1a SEVERITY-MISMATCH; SM-44 kill target); VP-SKILL-075 NEW FINALIZED P0 (operator-boundary cron-exit-nonzero signal; P10-002 Gate 2); SM-44/SM-45 allocated; version-coherence sweep: live-BC baseline updated to BC-3.03.001 v1.18 / BC-10.01.001 v1.15 / BC-6.01.003 v1.2 |
| phase-f2-spec-evolution/prd-delta.md | v1.11 | v1.12 | P10-001: 17-field schema catch-up (Verdict Schema Summary 15→17 fields; fields 16+17 added); §5 BC version column updated for burst-6 passes; §8 EC-010 updated (15→17 fields) |
| phase-f2-spec-evolution/dtu-assessment.md | v1.0 | v1.1 | P10-001: prism-demo-server clone must produce native_severity + sensor_family fields in synthetic alert payloads; jr-mock clone requirements unchanged |

---

### F2 Pass-9 Remediation Edits — Burst 5 (2026-07-22) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 5). Root findings: P9-001
(MAJOR — structural_label_check misses backslash-escaped quotes in IN_DOUBLE state and --label=VALUE
form; sole anti-fungibility gate post-P8-003; no backstop), P9-002 (MAJOR — asm-004-validation.md
recommends forbidden --dangerously-skip-permissions and --bare with no supersession banners vs
D-DEC-003/010), P9-003 (MINOR — prd-delta BC-10.01.001 double-counted 11 instead of 10), P9-004
(MINOR — verif-delta VP split mislabeled 8/23 vs correct 6/25 + FINALIZED/ACCEPTED drift), P9-005
(MINOR — D-DEC-005 org_slug absolute invariant needs sensor-health cross-org carve-out), P9-007
(MINOR — comment-review fallback hint creates duplicate review ticket risk), P9-008 (OBSERVATION —
jira_project_key not HARD Stage-0; re-doc cap absent), P9-009 (OBSERVATION — O5 rule not formally
codified). SM-43 allocated. First zero-CRITICAL pass.

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.11 | v1.12 | P9-001: O5 standing rule — tokenizer must carry differential-vs-bash vector partition; P9-005: D-DEC-005 sensor-health carve-out §8.11; P9-007: dedup-before-create-review gate §8.20; P9-008: jira_project_key HARD Stage-0 + HARD-FLOOR-LIVELOCK-ABORT §8.20; P9-009: O5 codified §8.21 |
| phase-0-ingestion/behavioral-contracts/BC-3.01.001.md | v1.20 | v1.21 [SM-ID-sync per FV] | P9-001: step-6a IN_DOUBLE backslash-escape-reverted state (SM-43 kill-target); --label=VALUE form (no space); O5 differential-vs-bash vector partition; SM-43 IDs synced all 4 occurrences |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.13 | v1.14 | P9-001: Inv#15 tokenizer backslash-escape + --label= coverage; P9-005: Inv#11 D-DEC-005 sensor-health carve-out; P9-008: jira_project_key Stage-0 precondition; re-doc cap; O5 obligation |
| phase-0-ingestion/behavioral-contracts/BC-6.01.001.md | v1.5 | v1.6 | P9-005: D-DEC-005 sensor-health carve-out annotation (cross-org health-check reads exempt from org_slug isolation) |
| phase-0-ingestion/behavioral-contracts/BC-8.02.001.md | v1.2 | v1.3 | Version bump tracking prd-delta P9-003 correction |
| phase-f2-spec-evolution/verification-delta.md | v1.11 | v1.12 | P9-004: VP split count corrected to 6/25; FINALIZED/ACCEPTED status parity; O5 obligation; version-coherence sweep: BC anchor column updated to final post-burst values (BC-3.01.001 v1.21, BC-8.02.001 v1.3, BC-10.01.001 v1.14, BC-6.01.001 v1.6, BC-3.03.001 v1.17) |
| phase-f2-spec-evolution/prd-delta.md | v1.10 | v1.11 | P9-003: BC-10.01.001 double-count corrected (11→10); BC-6.01.001 version bump to v1.6 |
| phase-0-ingestion/asm-004-validation.md | annotated | annotated + SUPERSEDED/CORRECTION banners | P9-002: SUPERSEDED banner over --dangerously-skip-permissions paragraph; CORRECTION banner over --bare paragraph; forward-links to D-DEC-003/010 |

---

### F2 Pass-8 Remediation Edits — Burst 4 (2026-07-21) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 4). Root findings: P8-001
(CRITICAL — STEP 3 correctly-labeled review verdict with null jira_project_key/ticket_id → silent
allow-without-marker; contradicts D-DEC-012 clause 2), P8-002 (MAJOR — structural_label_check
split_on_whitespace not quote-aware; false-denies own EC-024 example with --summary containing
spaces), P8-003 (MINOR — EC-023 step-5 defense-in-depth claim factually wrong; anti-fungibility
rests solely on step 6a), P8-004 (MAJOR — prd-delta §9 VP statuses inverted + §5 versions stale
by 2-3). OBS banners (P8-OBS-1) and operator note (P8-OBS-2) applied.

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.10 | v1.11 | P8-001 STEP-3 unbindable deny branches; P8-002 quote-aware tokenizer spec; P8-003 EC-023 step-5 correction; §8.18/§8.19 propagation; P8-OBS-1 forward-link banners on superseded ledger sections |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.16 | v1.17 [SM-ID-sync per FV] | P8-001: explicit unbindable-deny branches in STEP 3 for null jira_project_key (create-review) and null ticket_id (comment-review); SM-41 allocated as kill-target |
| phase-0-ingestion/behavioral-contracts/BC-3.01.001.md | v1.19 | v1.20 [SM-ID-sync per FV] | P8-002: structural_label_check upgraded to UNQUOTED/IN_SINGLE/IN_DOUBLE state-machine tokenizer (quote-aware); P8-003: EC-023 step-5 defense-in-depth claim corrected; SM-42 allocated as kill-target |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.12 | v1.13 [SM-ID-sync per FV] | P8-001: VP-HOOK-029 re-FINALIZED P0 (unbindable-deny vectors added); P8-001 loop re-documentation; SM-41/SM-42 IDs synced |
| phase-0-ingestion/behavioral-contracts/BC-8.02.001.md | v1.1 | v1.2 | P8-OBS-2: Cyberint 100% mass-escalation operator note (pre-ASM-008 expectation) |
| phase-f2-spec-evolution/verification-delta.md | v1.10 | v1.11 | SM-41/SM-42 allocated; unbindable-deny VP-HOOK-029 vectors (null-binding sub-case of happy path); EC-023 correction; version-coherence sweep: live-BC baseline updated to BC-3.01.001 v1.20 / BC-3.03.001 v1.17 / BC-10.01.001 v1.13 |
| phase-f2-spec-evolution/prd-delta.md | v1.9 | v1.10 | P8-004: VP-HOOK-029 corrected to FINALIZED P0; VP-SKILL-065 corrected to PROPOSED; §5 BC version table updated to post-burst versions |

---

### F2 Pass-7 Remediation Edits — Burst 3 (2026-07-21) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 3). Central design reversal:
STEP-4 marker-upgrade approach RETIRED; replaced with DENY-THE-WRITE per human decision D-008.
Root findings: P7-001 (CRITICAL — marker-upgrade emits markers loop's own jr command cannot consume
for 3 of 4 under-label action types; silent drop of hard-floor findings), P7-002 (CRITICAL — 6
stale locations in BC-10.01.001 encoding pre-D-DEC-012 "no marker for hard floor" semantics),
P7-003 (MAJOR — --label Iron Law missing from Stage-8 loop contract), P7-004 (MAJOR — VP-HOOK-029
emitter-only, cannot detect unconsumable-marker seam gap), P7-005 (MINOR — step-6a raw-substring
false-deny on --summary containing label text), P7-006 (MINOR — Cyberint severity unvalidated,
needs explicit conservative default), P7-007 (MINOR — brief §3.9 version pins stale), P7-009
(PROCESS-GAP — O4 standing rule: fail-loud guarantees must be verified at consumer/Bash boundary).

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.9 | v1.10 | P7-001/P7-004/P7-009: DENY-THE-WRITE redesign; STEP-4 deny + corrective-reason struct + UNDER-LABEL-DENIED audit; SM-38/SM-39/SM-40 allocated; O4 standing rule codified; P7-003: --label Iron Law Stage-8/loop contract; P7-006: Cyberint D-DEC-013 explicit conservative default |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.15 | v1.16 [SM-ID-sync per FV] | P7-001: STEP 4 deny-the-Write; UNDER-LABEL-DENIED audit replaces UNDER-LABEL-CORRECTED; corrective-reason struct (hard_floor_trigger/required_token/label_instruction); EC-012 under-label rows updated to deny semantics; VP-HOOK-029 citation updated; SM-38/SM-39 IDs synced |
| phase-0-ingestion/behavioral-contracts/BC-3.01.001.md | v1.18 | v1.19 [SM-ID-sync per FV] | P7-005: structural_label_check step-6a (standalone --label token check, not raw substring); EC-024 false-deny prevention; VP-HOOK-024 v1.19 extension; SM-40 kill target added |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.11 | v1.12 [SM-ID-sync per FV] | P7-002: 6 stale EC locations (EC-015/016/017/021 + 2 canonical test vectors) updated from "no marker for hard floor" to create-review/comment-review semantics; P7-003: --label Iron Law Stage-8; P7-006: Cyberint conservative default CRITICAL + uncertainty_explicit; VP-HOOK-029 citation updated to deny-the-Write; SM-38/SM-39 IDs synced |
| feature/prism-integration-handoff-brief.md | §3.9 (pinned versions) | §3.9 non-pinned | P7-007: stale version pins removed |
| phase-f2-spec-evolution/verification-delta.md | v1.9 | v1.10 | P7-001/P7-004: VP-HOOK-029 re-scoped end-to-end consumer-boundary, re-FINALIZED P0 (deny-path vectors + machine-actionable-reason + corrected-rewrite + consumer-boundary + kill-switch-irrelevance); SM-38/SM-39/SM-40; VP-HOOK-024 step-6a false-deny vector; VP-SKILL-074 Cyberint partition; 31→34 mutants; ~258→~263 tests; version-coherence sweep (VP-HOOK-025/027/028/SKILL-064/065/068/072/073 BC anchors + §5 row header) |

---

### F2 Pass-6 Remediation Edits — Burst 2 (2026-07-21) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 2). Root findings: P6-001
(consumer anti-fungibility — create-review/comment-review markers accepted for regular commands),
P6-002 (STEP 4/5 ordering — kill switch preceded under-label upgrade, causing silent discard on
hard-floor verdicts under autonomy_enabled=false), P6-003 (Inv#11/VP-SKILL-065 contradicted Option
A carve-out), P6-004 (cross-org create binding void with single PRISM-DEMO key — downgrade noted),
P6-005 (sensor-native severity encodings unmapped to {LOW,MEDIUM,HIGH,CRITICAL} enum — D-DEC-013),
P6-006 (D-DEC-004 review-token binding stale), P6-007 (late-event grace-window drop had no
detection VP), P6-008 (ASM-009 cross-hook marker-store visibility unvalidated — elevated to BLOCKING
pre-Wave-3), P6-009 (O3 rule applied emitter-only — extended to consumer, ordering, trust-boundary).

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.8 | v1.9 | P6-001..009 unified; D-DEC-012 reversal (hook-side label enforcement ADOPTED, D-DEC-012 O3 extended); D-DEC-013 severity normalization; STEP 4/5 reorder; ASM-009 BLOCKING; O3 O3-table consumer+ordering+trust-boundary rows; namespace corrections VP-SKILL-074/SM-36/SM-37 |
| phase-0-ingestion/behavioral-contracts/BC-3.01.001.md | v1.17 | v1.18 | P6-001: consumer STEP 6a anti-fungibility cross-check both directions; EC-023; OR-accept removed for create (comment retains); org-binding downgrade noted; 4 new canonical test vectors; VP-HOOK-029 FINALIZED ref; SM-36/SM-37 attribution |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.14 | v1.15 | P6-002: STEP 4/5 swap throughout; labeled create-review pattern in 3 locations; Iron Law updated (hook-side label enforcement); ASM-014 note; EC-012 case (d) flipped to upgrade semantics; test vectors updated |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.10 | v1.11 | P6-003: Inv#11 Option A carve-out (zero REGULAR writes, escalation-review writes exempt); VP-SKILL-065 re-scoped + re-marked PROPOSED; Inv#10 concession removed; NORMALIZE_SEVERITY named step per D-DEC-013; EC-006/EC-014 disambiguation |
| phase-f2-spec-evolution/verification-delta.md | v1.8 | v1.9 | VP-HOOK-029 FINALIZED (P0); consumer anti-fungibility vectors under VP-HOOK-024; VP-SKILL-065 RE-SCOPED PROPOSED; new VP-SKILL-073 (late-event P1) + VP-SKILL-074 (severity normalization P1, namespace-corrected from architect's "VP-SKILL-072"); SM-32-ext/SM-36/SM-37; 31 VPs + 31 mutants; ~238→~258 tests; FV caught VP-SKILL-072+SM-33/34 namespace collisions |

---

### F2 Pass-5 Remediation Edits (2026-07-21) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle. Root findings: P5-001
(silent discard on hard-floor mismatch), P5-002 (kill-switch bypass via LLM token without
deterministic gate), P5-003 (stale §D-DEC-001 authoritative schema block). Kill-switch
conflict with brief §3.9 resolved via human-confirmed Option A (2026-07-21).

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.7 | v1.8 | P5-001/002/003 + D-DEC-012 O3 rule + Option A kill-switch |
| phase-f2-spec-evolution/verification-delta.md | v1.7 | v1.8 | VP-HOOK-029 re-scope + SM-32a/32b split + §7 Part F routing |
| phase-f2-spec-evolution/prd-delta.md | v1.8 | v1.9 | §4/§6 12/15-field count correction |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.13 | v1.14 | P5-001/P5-002 STEP 3/5 gate propagation + schema v2.1 sync + EC-012 + TV-SYNC |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.9 | v1.10 | Inv#10 safety-net note + VP-SKILL-061 sensor-silence reword |
| feature/prism-integration-handoff-brief.md | §3.9 (pre-Option A) | §3.9 amended | Kill-switch Option A confirmed by human 2026-07-21 |

---

### Type: MINOR

### Summary

Feature cycle v0.10.0-feature-prism-integration: added 5 new behavioral contracts (prism
integration skills + monitoring-loop), modified 6 existing BCs (marker mechanism, evidence
collection, scoring), added 17 verification properties (VP-HOOK-024..026,
VP-SKILL-050..063), 11 mutation vectors (SM-9..SM-19), and 10 architecture decisions
(D-DEC-001..010). DI-013 resolved via D-DEC-001 marker mechanism.

### New Behavioral Contracts

| BC ID | Version | Subject |
|-------|---------|---------|
| BC-6.01.003 | v1.1 | onboard-customer skill — org slug/UUID-v7 provisioning, prism.toml [[orgs]] append, customers/<org_slug>/ dir creation, credential provisioning instructions (AD-017) |
| BC-6.01.004 | v1.1 | onboard-sensor skill — sensor overlay TOML write, AD-017 piped-stdin credential walkthrough, prism_describe verification, SELECT 1 connectivity check, --config-dir isolation |
| BC-8.02.001 | v1.1 | sensor-metrics skill — per org×sensor last-seen/row-counts/error-rate via prism_sensor_health; D-DEC-006 naming (sensor-metrics, not metrics) |
| BC-9.01.001 | v1.1 | scan-threats skill — predefined PrismQL hunting queries across all orgs; prism_describe-first table enumeration; findings grouped by severity; org_slug scoping invariant |
| BC-10.01.001 | v1.1 | monitoring-loop — 8-stage per-alert pipeline; four-disposition enum; Indeterminate hard floor; §3.4 Jira rules; §3.5 SLA surface; §3.7 sensor-silence=positive-signal; §3.8 ICD-203 12-field schema; watermark monotonicity; D-DEC-001..010 |

### Modified Behavioral Contracts

| BC ID | Old Version | New Version | One-Line Change Summary |
|-------|-------------|-------------|------------------------|
| BC-3.01.001 | v1.10 | v1.12 | Added D-DEC-001/D-DEC-008 marker-validation conditional-allow branch inside write-block path; Invariant #2 updated to permit marker-store filesystem access; EC-017..022 added; VP-HOOK-024 added |
| BC-3.03.001 | v1.5 | v1.7 | Added EMITTER role (marker issuance path only); ICD-203 dual-path 12-field enforcement (heading-anchored markdown + JSON key-presence); tuning_signal null-vs-absent semantics; VP-HOOK-025 corrected to list all 12 fields; EC-010..012 added |
| BC-4.02.001 | v1.3 | v1.4 | DI-013 RESOLVED via D-DEC-001 marker-gated comment path; four §3.4 ticket-action types added as distinct postconditions (PC#7a–d); Invariant #4 never-auto-reopen-closed; Invariant #5 §3.5 SLA surface-never-assume; EC-007..009 added |
| BC-4.05.001 | v1.0 | v1.1 | Added prism-grounded scoring layer: 30-day baseline query, enrich_nvd() UDF, rule-fidelity recalibration, per-tenant asset criticality weights, Bayesian TP/FP/BTP framework; degradation path to 6-factor when prism unavailable; Invariant #4 org_slug scoping; EC-009..012 added |
| BC-5.01.001 | v1.4 | v1.5 | Added prism evidence collection (Stage 3: OCSF event lookup + temporal-adjacency; Stage 4: ThreatIntel/NVD UDFs + optional Tavily D-DEC-009); structured evidence bundle §3.8 chain-of-custody format; DI-013 RESOLVED in Invariant #7 (marker-gated via D-DEC-001); EC-008..010 added |
| BC-6.01.001 | v1.0 | v1.2 | Added prism binary install/verify + version gate (VP-SKILL-051); DUAL MCP config write D-DEC-003 (settings.json mcpServers.prism + prism.mcp.json); RUST_LOG=off Invariant #5 (framing corruption prevention); jr auth check BLOCKING gate; AD-017 credential setup instructions; EC-008..012 added |

### New Verification Properties

| ID | Description | Proof Strategy |
|----|-------------|----------------|
| VP-HOOK-024 | require-review: marker-validation conditional-allow branch (D-DEC-001/D-DEC-008) | BATS |
| VP-HOOK-025 | disposition-guard: ICD-203 12-field enforcement — all fields including timeline_events, agent_actions, human_actions, tuning_signal | BATS |
| VP-HOOK-026 | monitoring-loop: hard floor enforcement (autonomy_enabled=true + Indeterminate/HIGH severity) | BATS |
| VP-SKILL-050 | monitoring-loop: watermark monotonicity (post-run watermark >= injected pre-run value) | BATS |
| VP-SKILL-051 | setup-prism: binary version gate (>= 1.0.0-rc.1) | BATS |
| VP-SKILL-052 | onboard-customer: org slug/UUID-v7 provisioning postconditions | BATS |
| VP-SKILL-053 | onboard-customer: credential provisioning instructions (AD-017 — no credential-in-chat) → **REPURPOSED pass-14/P14-005: now idempotent-directory-creation (Postcondition #2/EC-006); original AD-017 coverage RESTORED via NEW VP-SKILL-077 (VP-SKILL-076 is the unrelated setup-time key charset gate)** | BATS |
| VP-SKILL-054 | onboard-sensor: sensor overlay TOML write correctness | BATS |
| VP-SKILL-055 | onboard-sensor: SELECT 1 connectivity check (success only when DB responds) | BATS |
| VP-SKILL-056 | sensor-metrics: last-seen/row-counts/error-rate via prism_sensor_health | BATS |
| VP-SKILL-057 | sensor-metrics: org_slug scoping invariant (no cross-tenant data) → **REPURPOSED pass-9/P9-005: now naming-compliance D-DEC-006** | BATS |
| VP-SKILL-058 | scan-threats: PrismQL hunting query dispatch (prism_describe-first) | BATS |
| VP-SKILL-059 | scan-threats: org_slug scoping invariant (no cross-org findings) | BATS |
| VP-SKILL-060 | monitoring-loop: four-disposition enum enforcement (Benign/FP/Indeterminate/TP) | BATS |
| VP-SKILL-061 | monitoring-loop: Indeterminate disposition hard floor (never auto-close) | BATS |
| VP-SKILL-062 | monitoring-loop: §3.4 Jira ticket-action rules (PC#7a–d, never-auto-reopen-closed) | BATS |
| VP-SKILL-063 | monitoring-loop: §3.5 SLA surface-never-assume invariant | BATS |
| VP-SKILL-076 | setup-time `jira_project_key` charset validation — `activate` + `onboard-customer` REJECT a key not matching `^[A-Z][A-Z0-9]+$` at setup with user-facing error + no partial-state write (P14-002 MAJOR; DISTINCT from VP-HOOK-032 runtime deny; paired mutant SM-54) | BATS |
| VP-SKILL-077 | onboard-customer AD-017 credential-decline — SKILL.md never requests/accepts credential paste in conversation; only piped-stdin `echo \| prism credential set` documented (P14-005; mirrors VP-SKILL-054; B-STR; no mutant — SM-55 skipped) | BATS |

### Architecture Changes

- D-DEC-001: Marker mechanism for disposition-guard/require-review cross-hook communication (resolves DI-013; TTL 30s; scope-validated; consumed-on-use)
- D-DEC-002: Prism binary install path and version gate strategy (>= 1.0.0-rc.1)
- D-DEC-003: DUAL MCP config write — settings.json mcpServers.prism + standalone prism.mcp.json
- D-DEC-004: Watermark store location (${CLAUDE_PLUGIN_DATA}/watermarks/) and monotonicity contract
- D-DEC-005: Cross-tenant isolation — org_slug scoping as plugin-side invariant; no prism-side cross-org correlation
- D-DEC-006: Naming convention: skill named sensor-metrics (not metrics) to avoid namespace collision
- D-DEC-007: Prism describe-first table enumeration strategy for scan-threats (no hardcoded table names)
- D-DEC-008: Marker scope validation: authorized_operations field must match command_pattern; path-traversal gated
- D-DEC-009: Tavily enrichment in evidence collection is recommended-not-required (graceful skip when unavailable)
- D-DEC-010: --allowedTools MCP glob syntax (mcp__prism__*) for ASM-004 partial resolution

### Mutation Vectors

11 new mutation vectors (SM-9..SM-19) covering: marker-store attack surfaces (expired/wrong-scope/replayed/malformed/path-traversal/wrong-ticket), watermark file manipulation, credential exfiltration via chat-echo, prism binary substitution, and cross-tenant org_slug injection.

### Impact Assessment

- **Affected stories:** Wave 3–7 stories in cycle v0.10.0 — all story acceptance criteria referencing these BCs must cite updated versions
- **Affected tests:** 17 new VP fixtures required (VP-HOOK-024..026, VP-SKILL-050..063); VP-HOOK-025 corrected from 8-field to 12-field enforcement
- **Migration needed:** NO (backward-compatible additions; existing BCs append-only except internal patch bumps)
- **Migration notes:** N/A
- **DI resolved:** DI-013 resolved via D-DEC-001 marker mechanism (no open design issues remain for this cycle)
- **Open questions for formal-verifier:** 6 items documented in prd-delta.md §6

### Reference Documents

- `.factory/phase-f2-spec-evolution/prd-delta.md` v1.2
- `.factory/phase-f2-spec-evolution/architecture-delta.md` v1.1
- `.factory/phase-f2-spec-evolution/verification-delta.md` v1.0
- `.factory/phase-f2-spec-evolution/dtu-assessment.md`
- `.factory/phase-f2-spec-evolution/asm-004-validation.md`

---

## [1.0.0] - 2026-07-20

### Type: MAJOR

### Summary

Initial spec baseline. Phase 0 brownfield ingestion of 17 behavioral contracts extracted
from the existing secops-factory codebase. Establishes the BC corpus and traceability
anchor for all subsequent feature cycles.

### Impact Assessment

- **Affected stories:** None (initial baseline)
- **Migration needed:** NO

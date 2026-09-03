# Adversarial Review — Pass 28 (F2 spec-evolution, prism-integration cycle)

> **[reconstructed-from-STATE burst-log at pass-29 close — original report file was not persisted]**
>
> This stub is reconstructed from STATE.md Current Phase Steps burst-25 row and the
> Phase Progress finding-progression column. Findings are accurate per those records;
> detailed evidence citations and full methodology prose were not captured at the time
> of the original pass-28 run.

- **Pass:** 28
- **Date:** 2026-07-29 (estimated — same session as passes 26, 27)
- **Reviewer:** adversary (fresh context; no access to prior-pass reviews)
- **Perimeter/versions (at time of pass):** architecture-delta v1.29, verification-delta v1.29,
  prd-delta v1.27, BC-3.03.001 v1.36, BC-4.02.001 v1.20, BC-5.01.001 v1.14, BC-10.01.001 v1.29 —
  representing the burst-24 (P27 remediation) state.

## Verdict Summary

**Pass 28 — NOT CLEAN.** Lowest-severity pass to date (no C/M). Novelty: LOW.

Reconstructed count: **0C / 0M / 1med / 1min / 0obs**

---

## Critical Findings

None.

---

## Important Findings

None.

---

## Medium Findings

### P28-001 — [MEDIUM] WRITE_MARKER per-path variable definedness: markdown producer var mismatch left from P27-002 path-aware edit

- **Reconstructed from:** STATE.md burst-25 row
- **Summary:** The burst-24 path-aware WRITE_MARKER edit left the markdown producer variable as
  `parsed_disposition` while WRITE_MARKER read `markdown_parsed_disposition` — a name mismatch
  creating an undefined-variable condition on the markdown path. Additionally, `link_target` was
  unassigned on the markdown path. Per-path definedness was therefore vacuous — SM-80's kill target
  was never genuinely killable under the P27-002 state. Dead-variable removal and explicit per-path
  definedness table were missing.
- **Remediation:** Resolved in burst-25 — `markdown_parsed_disposition = parsed_disposition`
  assignment added; explicit `link_target = null` in both markdown setup blocks; dead-var removal;
  per-path definedness table added. SM-80 kill is now GENUINE (was vacuous).

---

## Minor Findings

### P28-002 — [MINOR] org_slug roster: validate_enums() never checks org_slug; ASM-008 residual (DI-017)

- **Reconstructed from:** STATE.md burst-25 row
- **Summary:** `org_slug` is LLM-supplied but validate_enums() never verifies org_slug format or
  membership against the configured `[[orgs]]` set. Additionally, `org_slug` was not in the
  consumer-side mandatory-field roster (BC-3.03.001 operational-metadata roster) nor in
  BC-10.01.001 Inv#9 producer roster or Stage-1 INGEST write list. The ASM-008 residual
  (DI-017) was noted — bounded by D-028 org-binding. SM-81 allocated (org-slug-presence-check-
  removed mutant — org_slug absent/empty → validate_enums() fail-closed DENY).
- **Remediation direction:** SM-81 allocated. The propagation gap (consumer roster + producer
  roster + prd-delta enforcement-split) was NOT fully remediated in burst-25; it was carried
  forward as P29-001 and remediated in burst-26.

---

## Confirmed-Intact Invariants (from burst-25 record)

All prior invariants held. Pass-28 findings confined entirely to the just-changed P27-002
WRITE_MARKER edit — zero regression in settled invariants.

---

## Convergence Counter

0/3 clean passes. Pass-28 NOT CLEAN (0M but 1med/1min). Remediation dispatched as burst-25
(partial — P28-002 propagation carried to burst-26 as P29-001).

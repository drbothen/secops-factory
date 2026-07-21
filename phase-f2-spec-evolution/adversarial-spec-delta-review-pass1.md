---
document_type: adversarial-review
producer: adversary
pass: 1
date: 2026-07-20
verdict: FINDINGS
counts: "2C/8M/6m/4obs"
cycle: v0.10.0-feature-prism-integration
targets:
  - .factory/phase-f2-spec-evolution/architecture-delta.md (v1.1)
  - .factory/phase-f2-spec-evolution/prd-delta.md (v1.2)
  - .factory/phase-f2-spec-evolution/verification-delta.md (v1.0)
  - .factory/phase-0-ingestion/behavioral-contracts/BC-3.01.001.md (v1.12)
  - .factory/phase-0-ingestion/behavioral-contracts/BC-3.03.001.md (v1.7)
  - .factory/phase-0-ingestion/behavioral-contracts/BC-4.02.001.md (v1.4)
  - .factory/phase-0-ingestion/behavioral-contracts/BC-10.01.001.md (v1.1)
---

# Adversarial Review — F2 Spec Delta, Pass 1

Verdict: FINDINGS — not converged; 2 CRITICAL cross-BC security contradictions. Counts: CRITICAL 2, MAJOR 8, minor 6, observation 4. Snapshot trust: HIGH (live reads).

CRITICAL
ADV-F2-001: HIGH/CRIT-severity and critical-asset hard floors unenforceable at disposition-guard — the 12-field verdict schema (BC-10.01.001) carries NO severity/asset_type field, yet D-DEC-008 claims deterministic emitter enforcement. BC-3.03.001 Inv#4 wrongly substitutes confidence for severity (orthogonal axes). Fix: add severity + asset_type/asset_criticality as mandatory verdict fields (→14); disposition-guard keys on severity, not confidence.
ADV-F2-002: Marker command_pattern ticket-binding contradiction — D-DEC-001/D-DEC-008 generate a ticket-agnostic pattern; BC-3.03.001 emitter + BC-3.01.001 EC-022 require ticket-bound. One comment-marker would authorize comments on arbitrary tickets in the TTL window. Decide once; single source of truth.

MAJOR
ADV-F2-003: Marker JSON schema diverges across docs (issued_at_utc vs issued_at; ttl_seconds vs expires_at vs hardcoded 30s; authorized_operations value form; --output json branch). Publish ONE canonical marker schema all three docs cite.
ADV-F2-004: disposition-guard emits comment-scoped markers ONLY; no create/assign issuance path — autonomous jr issue create/assign permanently dead-denied. Add scoped emitter branches.
ADV-F2-005: Known-FP Stage-2 fast-exit (BC-10.01.001 EC-009/Inv#7) skips Stages 3-6, bypassing critical-asset/HIGH-severity/degraded-sensor hard floors before auto-close. Evaluate hard floors BEFORE known-FP auto-close.
ADV-F2-006: Watermark _time > watermark permanently drops late/out-of-order events (OCSF ingestion delay) — silent missed alerts. Add lookback overlap + Jira-first dedup, or ingestion-time watermark.
ADV-F2-007: BC-4.02.001 Precondition#1/PC#1/EC-001 still say marker lives "in conversation context or JIRA comments" — contradicts D-DEC-001 out-of-band filesystem design in same file (reintroduces SEC-001 injection surface).
ADV-F2-008: BC-10.01.001 Invariant#1 (org_slug scoping — sole cross-tenant isolation guarantee) has NO verification property.
ADV-F2-009: architecture-delta §5.3 says "all 9 mandatory fields" (should be 12/14) + mis-attributes to VP-HOOK-024 instead of VP-HOOK-025. Field-count drift recurrence.
ADV-F2-010: Watermark ISO-8601 lexicographic comparison assumes fixed-width UTC-Z; regex enforces neither Z nor fractional seconds; prism _time format unvalidated (ASM-008).

minor
ADV-F2-011: 30s marker TTL likely shorter than real agent latency between disposition-guard Write and require-review Bash events — autonomous path constantly falls back to human. No latency budget validates 30s.
ADV-F2-012: disposition-guard ticket_id extraction "from file_path or content" underspecified; filename id may differ from Jira key → anchored pattern never matches → deny. No ticket_id for create verdicts.
ADV-F2-013: audit.log embeds command='${command}' unescaped — newline in arg injects forged MARKER_USED audit lines, undermining ICD-203 chain-of-custody.
ADV-F2-014: BC-3.01.001 consumer step (8) omits the "if rename fails → deny" TOCTOU-safety step that D-DEC-001 pseudocode requires.
ADV-F2-015: verification-delta + architecture-delta §5.4 reference stale BC versions (v1.11/v1.6) vs live v1.12/v1.7.
ADV-F2-016 (obs): BC-3.03.001 Inv#4 "cross-tenant scope indicators present in evidence_artifacts" undefined — no schema for what a cross-tenant indicator looks like.
ADV-F2-017 (obs): BC-3.01.001 revision history lists v1.12 before v1.11 (ordering).
ADV-F2-018 (obs): BC-3.01.001 step 3 "used != false" check dead-code redundant (consumption via rename to .used excluded from glob).
ADV-F2-019 (obs)[process-gap]: kill switch autonomy_enabled:false has no dedicated VP.

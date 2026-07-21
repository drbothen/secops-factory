---
document_type: adversarial-review
producer: adversary
pass: 4
date: 2026-07-20
verdict: FINDINGS
counts: "2C/4M/6m/3obs"
snapshot_trust: TRUSTED-partial
cycle: v0.10.0-feature-prism-integration
---

# Adversarial Spec Delta Review — Pass 4
## cycle: v0.10.0-feature-prism-integration

**Snapshot trust:** TRUSTED-partial — architecture-delta.md v1.5 and verification-delta.md v1.4
are trusted. BC-10.01.001 v1.7, BC-3.03.001 v1.11, BC-3.01.001 v1.15, BC-4.02.001 v1.6 are
live; the pass-4 adversary has full read on all six. PRD and prd-delta are NOT loaded.

**Finding counts:** 2 Critical / 4 Major / 6 Minor / 3 Observation

---

## CRITICAL

### ADV-F2-P4-001 — CRITICAL: Dispatch collision on canonical verdict path makes autonomous pipeline unreachable

**Spec locus:** architecture-delta.md §D-DEC-008 "Verdict-File-Path Naming Convention" (v1.5 p.1135) + BC-3.03.001 v1.11 PC#2/PC#3 dispatch.

**Finding:** The canonical verdict path mandated by ADV-F2-P3-005 is
`artifacts/investigations/verdict-<alert_id>-<iso_ts>.json`. This path contains BOTH the
substring `investigation` (directory component) AND the substring `verdict` (file name). BC-3.03.001
v1.11 PC#2 dispatches on plain `investigation` substring → 12-field markdown heading-grep path.
PC#3 dispatches on plain `verdict` substring → 15-field JSON path.

Because `investigation` appears BEFORE `verdict` in the path and the BC evaluates PC#2 before
PC#3, the canonical verdict file is always routed to the MARKDOWN branch. A JSON verdict file
dispatched to the markdown heading-grep path fails the heading assertions (no `## Disposition`
headings in a JSON file) → disposition-guard emits DENY → verdict write blocked → no marker →
require-review denies Stage-8 jr write → autonomous monitoring-loop pipeline is permanently
unreachable. ADV-F2-P3-005 (fix that mandated `verdict` in path) and the canonical naming
convention together created this collision.

**Verification-delta.md v1.4 §3(a) ALREADY specifies the correct dispatch:** (i) check
content parses as JSON (`jq empty`) OR extension is `.json` → verdict 15-field path FIRST;
(ii) elif `*investigation-*.md` glob → investigation 12-field path. The stronger
verification-delta behavior is NOT reflected in architecture-delta.md D-DEC-008, and BC-3.03.001
v1.11 PC#2/PC#3 use the weaker plain-substring dispatch.

**Consequence:** The entire autonomous monitoring-loop pipeline is unreachable for every
correctly-named verdict file. Finding severity: CRITICAL — the feature does not function.

**Required fix:** Architecture-delta must state unambiguously: dispatch is JSON-first. A file
that ends in `.json` or whose content parses as JSON via `jq empty` MUST be routed to the
verdict-class (15-field) path regardless of any `investigation` substring in the path. Only
files that match `*investigation-*.md` (ending in `.md`) route to the investigation-class path.
BC-3.03.001 PC#2 and PC#3 must be rewritten to implement JSON-first dispatch (PO obligation).

---

### ADV-F2-P4-002 — CRITICAL: create command_pattern substring bypass via attacker-influenceable `--summary` text

**Spec locus:** architecture-delta.md §D-DEC-008 command_pattern generation table (v1.5 line 897):
`^jr (--output json )?issue create .*--project <jira_project_key>`

**Finding — injection vector:** The unbounded `.*` between `create ` and `--project` allows
an attacker-influenceable free-text argument (specifically `--summary`) to satisfy the
`--project ORG_A` substring. Example command:
```
jr issue create --summary "this is --project SEC_ORG_A for review" --project SEC_ORG_B
```
The regex matches on the injected `--project SEC_ORG_A` substring inside `--summary`. A
create marker issued for project key `SEC_ORG_A` now authorizes a create command that actually
targets `SEC_ORG_B`. The org-binding introduced at v1.4 (ADV-F2-P3-002) is entirely defeated.

**Finding — prefix match:** The pattern has no trailing word-boundary or space-after-key
constraint. A project key `PROD` matches commands with `--project PRODUCTION` because
`PRODUCTION` contains `PROD` as a prefix. The sentinel space after the ticket_id (EC-022
trailing-space guard for comment/assign) is absent from the create pattern.

**Consequence:** Cross-org create bypass; a compromised `--summary` value (attacker-influenced
via Jira ticket title/description already in scope from a prior read) can route a create
operation to an arbitrary org. This is a direct SEC-009-class attack against the org-binding
that v1.4 was designed to close.

**Required fix:** Require `--project` as the FIRST explicit argument after `issue create` in
a fixed position, with a trailing space-or-end anchor:
`^jr (--output json )?issue create --project <key>( |$)`
The `.*` before `--project` MUST be removed. The monitoring-loop MUST be instructed via an
Iron Law in SKILL.md that `--project` is always the first argument. A marker for key `PROD`
matches `jr issue create --project PROD` and `jr issue create --output json --project PROD`
but NOT `jr issue create --project PRODUCTION` (trailing `( |$)` requires a space or EOL
after the key value). BC-3.03.001 create emitter branch must adopt this pattern (PO obligation).

---

## MAJOR

### ADV-F2-P4-003 — MAJOR: BC-10.01.001 Inv#5 sensor-silence condition is logically inverted

**Spec locus:** BC-10.01.001 v1.7 Invariant #5 + EC-006.

**Finding:** BC-10.01.001 Inv#5 states: "If a sensor's `last_seen_ts > now() - INTERVAL 24h`
AND `row_count == 0`, the loop emits a BLIND-SPOT finding." The operator `>` means
`last_seen_ts` is GREATER THAN (more recent than) `now() - 24h`, i.e., the sensor was seen
within the last 24 hours. A sensor last seen 36 hours ago has `last_seen_ts = 36h_ago`, and
`36h_ago > now() - 24h = 24h_ago` evaluates to FALSE (36h ago is OLDER than 24h ago, i.e.,
a smaller numeric value). The canonical test vector at EC-006 ("last_seen_ts = 36h ago, zero
rows → BLIND-SPOT") does NOT satisfy the Inv#5 condition as written → BLIND-SPOT is never
emitted for a 36h-silent sensor.

The intent from brief §3.7 is unambiguous: "last-seen timestamp exceeds the configured silence
threshold (default 24h)" = last seen MORE than 24h ago = `last_seen_ts < now() - INTERVAL 24h`.
The operator should be `<`.

**Secondary:** BC-10.01.001 EC-006 inherits the same `>` operator from Inv#5, and brief §3.2
Stage 0 pseudocode also uses `>`. All three are consistently wrong in the same direction.

**Required fix (PO):** Change `last_seen_ts > now() - INTERVAL 24h` to
`last_seen_ts < now() - INTERVAL 24h` in BC-10.01.001 Inv#5 AND EC-006. Update brief §3.2
Stage 0 pseudocode to match. This is a PO BC correction.

---

### ADV-F2-P4-004 — MAJOR: Hard-floor blocks BLIND-SPOT and Indeterminate ticket creation — silent failure in unattended cron

**Spec locus:** architecture-delta.md D-DEC-008 hard_floor_applies() + D-DEC-004 + BC-10.01.001 EC-006/EC-014 + brief §3.7.

**Finding:** The current hard-floor architecture unconditionally prevents marker issuance for:
- `disposition == "Indeterminate"` (EC-014 REVIEW-REQUIRED finding)
- `sensor_health_status in {"degraded","silent"}` (EC-006 BLIND-SPOT finding)

No marker → require-review denies `jr issue create` → BLIND-SPOT/REVIEW-REQUIRED ticket is
never created. In unattended cron mode (D-DEC-003: no interactive shell, no human to click
approve in a permission dialog), a denied create is permanently lost — not deferred, not
queued, silently dropped.

This directly contradicts brief §3.7: "Absence of expected data is a first-class alert, not a
null result. Do NOT treat it as 'nothing to report'." And EC-006/EC-014 which require the loop
to create these tickets. The hard floor correctly prevents autonomous TRIAGE actions (FP/TP
close, escalation) but incorrectly also prevents autonomous ESCALATION actions (creating a
human-review ticket that is by definition NOT an autonomous triage decision).

**Mutual exclusion:** BC-10.01.001 Inv#10 (hard floor → ticket_action_type="none") and EC-006
(create BLIND-SPOT ticket autonomously) are mutually exclusive for silent/degraded sensors.
One of them must be narrowed. The correct resolution preserves the hard floor for triage while
enabling escalation.

**Required fix:** Introduce `ticket_action_type = "create-review"` (and `"comment-review"` for
dedup appends) as RESTRICTED marker types. For hard-floor verdicts requiring human surfacing,
disposition-guard MUST issue a restricted marker with `authorized_operations: ["create-review"]`.
This is exempt from the "hard floor → no marker" rule because creating a [REVIEW-REQUIRED] or
[BLIND-SPOT] ticket is ESCALATION not autonomous triage. A fail-loud invariant: hard-floor
verdicts MUST result in either a create-review/comment-review action OR an explicit error
artifact — NEVER silent discard. New decision record required (D-DEC-012).

---

### ADV-F2-P4-005 — MAJOR: autonomy_enabled kill switch not deterministically enforceable

**Spec locus:** architecture-delta.md D-DEC-008 hard_floor_applies() pseudocode (line ~1044) +
verification-delta.md v1.4 §3(c) + BC-3.03.001 v1.11 Inv#4.

**Finding:** The D-DEC-008 emitter pseudocode (v1.5 line ~1044) references `autonomy_enabled`
in an outer guard: `IF autonomy_enabled AND disposition in {"FP","BTP"}`. But:

1. `autonomy_enabled` is NOT a field in the 15-field mandatory ICD-203 verdict schema
   (BC-10.01.001 Inv#9). The operational metadata fields (`confidence_score`, `jira_project_key`)
   do not include `autonomy_enabled`.
2. BC-3.03.001 v1.11 Inv#4 (emitter contract) never reads `autonomy_enabled` — it reads only
   `ticket_action_type` plus hard-floor fields. There is no deterministic hook behavior that
   reads `autonomy_enabled` directly from the verdict file.
3. The enforcement chain collapses to: monitoring-loop LLM sets `ticket_action_type="none"`
   when `autonomy_enabled=false` (BC-10.01.001 Inv#11/EC-020). This is LLM-mediated, not
   deterministic. A compromised or hallucinating loop could set `ticket_action_type="create"`
   regardless.

**Consequence:** The kill switch advertised in brief §3.9 ("provides emergency circuit-breaker
when automation produces unexpected output") is not deterministically enforced by the hook layer.
An adversarial monitoring-loop invocation could set `ticket_action_type="create"` on a
HIGH-severity alert even when `autonomy_enabled` should be false.

**Required fix:** Add `autonomy_enabled` to the verdict JSON as a non-ICD-203 operational
metadata field (alongside `jira_project_key` and `confidence_score`). Disposition-guard MUST
read `autonomy_enabled` from the verdict file directly and suppress all regular markers when
`autonomy_enabled != true`. Default-false (conservative: if field absent, treat as false).
Review-surfacing markers (`create-review`, `comment-review`) are exempt from the kill switch
because they represent escalation not autonomous triage.

---

### ADV-F2-P4-006 — MAJOR: severity, asset_type, and related enum fields not validated for membership before hard-floor evaluation

**Spec locus:** architecture-delta.md D-DEC-008 emitter pseudocode + BC-3.03.001 v1.11 PC#3 verdict JSON validation.

**Finding:** BC-3.03.001 v1.11 PC#3 states the verdict JSON check is "key-presence only" for
fields 1–15 (uses `jq has()`). The hard-floor function `hard_floor_applies()` keys on exact
membership:
- `verdict.severity in {"HIGH","CRITICAL"}` — requires exact uppercase strings
- `verdict.asset_type in CRITICAL_ASSET_TYPES + "unknown"` — requires exact strings
- `verdict.disposition == "Indeterminate"` — requires exact casing
- `verdict.sensor_health_status in {"degraded","silent"}` — requires exact strings
- `verdict.ticket_action_type` — no enum validation

If a verdict has `severity: "High"` (wrong casing), key-presence passes (`jq has("severity")`
returns true) but hard-floor check `"High" in {"HIGH","CRITICAL"}` fails → NO hard floor →
marker is issued for an actually-HIGH-severity alert that should never receive a marker. A
confidentHIGH-severity TP verdict with case-mangled severity bypasses the hard floor entirely.

Same attack applies to `asset_type`, `disposition`, `sensor_health_status`, and
`ticket_action_type`. None are enum-validated before hard-floor evaluation. The D-DEC-011
fix (confidence float→enum) added enum validation for `confidence` only; the other typed
fields were not extended.

**Required fix:** Disposition-guard MUST validate enum membership (fail-closed: deny on
non-member value) for ALL typed fields BEFORE the hard-floor check: `severity`, `asset_type`,
`disposition`, `sensor_health_status`, `ticket_action_type`, `confidence`. A verdict with
`severity: "High"` (non-member) MUST be denied, not allowed-without-marker. Failing open
(allowing without marker) creates a window where a field-mangled verdict writes to the
investigation store without ICD-203 guarantee. Fail-closed deny is the correct posture.

---

## MINOR

### ADV-F2-P4-007 — MINOR: BC-10.01.001 Inv#10 now contradicts D-DEC-004 and EC-006/EC-014 explicitly

**Spec locus:** BC-10.01.001 v1.7 Invariant #10 + EC-006/EC-014 + architecture-delta.md D-DEC-004.

**Finding:** Inv#10 states: "When any hard floor applies, the monitoring-loop MUST set
`verdict.ticket_action_type = 'none'`." EC-006 and EC-014 require autonomous ticket creation
for silent/Indeterminate findings. D-DEC-004 requires one open BLIND-SPOT ticket per
(org_slug, sensor_id). These are mutually exclusive: Inv#10 blocks the create via `none`;
EC-006/EC-014 require it. This is a direct contradiction that makes the BC self-inconsistent
independently of the architecture fix.

**Required fix (PO):** BC-10.01.001 Inv#10 must be narrowed to: "When any hard floor applies
AND ticket_action_type is not `create-review` or `comment-review`, the monitoring-loop MUST
set ticket_action_type accordingly." (Or rewritten to enumerate what hard floors set vs the
review-surfacing exception.)

---

### ADV-F2-P4-008 — MINOR: BC-4.02.001 PC#4 references removed "cross-tenant" hard-floor category

**Spec locus:** BC-4.02.001 v1.6 PC#4.

**Finding:** BC-4.02.001 v1.6 PC#4 lists hard-floor categories for the update-jira skill
that still include "cross-tenant campaign correlation findings" as a hard-floor member.
This category was removed from BC-3.03.001 at v1.10 and from BC-3.01.001 at v1.15 (P3-011
architectural decision: cross-tenant is a prism-side separation, not a plugin-side hard floor).
BC-4.02.001 did not receive the P3-011 alignment. Cross-tenant as a hard-floor category is
now an inconsistency visible to any consumer of the update-jira spec.

**Required fix (PO):** Remove "cross-tenant campaign correlation findings" from BC-4.02.001
v1.6 PC#4 hard-floor enumeration. Align with BC-3.03.001 and BC-3.01.001 post-P3-011 state.

---

### ADV-F2-P4-009 — MINOR: architecture-delta.md §5.4 "open" note is stale — fix was applied at BC-3.01.001 v1.14

**Spec locus:** architecture-delta.md v1.5 §5.4 lines ~1746-1749.

**Finding:** §5.4 contains a note originally from v1.3 (ADV-F2-P2-007):
"BC-3.01.001 v1.15 Invariant #2 above still references `${CLAUDE_PLUGIN_DATA}/audit.log`
rather than the canonical path `${CLAUDE_PLUGIN_DATA}/markers/audit.log`. PO must align
BC-3.01.001 to the canonical path in the v1.14 bump (see §8.6 item 6)."

BC-3.01.001 is NOW at v1.15. Per the v1.14 changelog (visible in BC-3.01.001 revision history),
"ADV-F2-P2-003/P2-007/P2-012: audit log path alignment" was applied at v1.14. The note remains
as an "open" action item pointing to §8.6 item 6 even though the fix is already in the live
BC. A reviewer reading architecture-delta.md v1.5 sees a pending PO action that was already
completed two versions ago. This creates false urgency and audit noise.

**Required fix (architect):** Mark the §5.4 ADV-F2-P2-007 note as RESOLVED, noting the fix
was applied at BC-3.01.001 v1.14 (now live at v1.15).

---

### ADV-F2-P4-010 — MINOR: require-review audit log writes raw ticket_id and org_slug — newline injection risk

**Spec locus:** architecture-delta.md §D-DEC-001 consumer pseudocode lines ~216-220.

**Finding:** The audit log construction:
```
audit_line = "${ISO_NOW} MARKER_USED marker_id=... op=${candidate.json.authorized_operations[0]} " +
             "ticket=${candidate.json.ticket_id} " +
             "org=${candidate.json.org_slug} " +
             "command_b64=${command_b64}"
```

Only `command_b64` is base64-encoded (ADV-F2-013 fix). The fields `ticket_id` and `org_slug`
are interpolated RAW. `ticket_id` comes from `verdict.ticket_id` which originates from a Jira
API response (LLM-influenced via ticket content); it may contain newline characters injected
via Jira ticket body.  `org_slug` comes from `verdict.org_slug` which originates from `prism.toml`
(operator-configured, lower risk but not sanitized). A `ticket_id` containing `\n` can forge
additional MARKER_USED lines in the audit log, undermining the chain-of-custody record.

The same `op` field (from `authorized_operations[0]`) is a bounded enum value and is not
attacker-influenceable in practice, but is also not sanitized.

**Required fix (architect/PO):** Apply control-character sanitization (strip all characters
in `[\x00-\x1f]`) to `ticket_id`, `org_slug`, and `op` before interpolation into the audit
log line. This extends ADV-F2-013 (command base64) to cover all attacker-influenceable fields.
Architecture-delta must update the audit pseudocode; BC-3.01.001 must update the consumer
algorithm (PO obligation).

---

### ADV-F2-P4-011 — MINOR: No per-run alert cap or budget-exhaustion behavior defined in NFR

**Spec locus:** architecture-delta.md D-DEC-003 + NFR catalog.

**Finding:** D-DEC-003 specifies a 60-minute lockfile timeout for the monitoring-loop
cron wrapper. A single loop invocation processing a large backlog of unprocessed events could
run for the full 60 minutes and block all subsequent invocations — effectively creating a
15-minute cadence that degrades to 60-minute. Additionally, the loop has no defined behavior
when the 15-minute per-run budget is exhausted mid-alert-set: it may process a partial set,
advance the watermark to the last processed event, and silently drop in-flight work without any
NFR-graded signal. High-severity alerts in the unprocessed tail may be delayed up to 60 minutes.

**Required fix (PO NFR + architect D-DEC-003 note):** Define in the NFR catalog:
- MAX_ALERTS_PER_RUN: configurable cap (default: 50 alerts per run) to bound execution time.
- Priority ordering: when cap is hit, highest-severity alerts are processed first.
- Watermark advance on cap: advance to the _time of the last successfully processed event.
- Budget-exhaustion artifact: loop MUST write a `[BUDGET-EXHAUSTED]` annotation to the loop
  output when the cap fires, with the count of deferred alerts and the highest severity among
  them. This prevents silent deferral of CRITICAL alerts.

---

### ADV-F2-P4-012 — MINOR: BC-3.03.001 PC#1 fast-path test order incompatible with JSON-first dispatch fix

**Spec locus:** BC-3.03.001 v1.11 PC#1 + ADV-F2-P4-001 JSON-first dispatch requirement.

**Finding:** BC-3.03.001 v1.11 PC#1 states: "If file_path contains neither `investigation` nor
`verdict` → emit allow (fast-path, no ICD-203 validation)." The JSON-first fix for P4-001
requires the dispatch sequence to be: (1) check JSON → verdict path; (2) check investigation
substring → investigation path; (3) else → fast-path. PC#1 as written still uses a pure
path-substring test as its first branch. After the P4-001 fix, PC#1 must be updated to:
"If content is not JSON AND file_path does not contain `investigation` → emit allow (fast-path)."
A `.json` file in a non-investigation, non-verdict path would currently receive fast-path allow
under PC#1; after the fix it must be routed through the JSON-content check first.

**Required fix (PO):** Rewrite BC-3.03.001 PC#1 to reflect JSON-first dispatch: PC#1 = JSON
check; PC#2 = investigation substring (only `.md` files); PC#3 = fast-path allow (not JSON,
not investigation markdown).

---

## OBSERVATION

### ADV-F2-P4-O1 — OBS: WRITE_WATERMARK timestamp validation looser than READ_WATERMARK

**Spec locus:** architecture-delta.md D-DEC-002 WRITE_WATERMARK() pseudocode, lines ~360-364.

**Observation:** WRITE_WATERMARK validates: `'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}'`
(no Z suffix required, no milliseconds, no end-of-string anchor). READ_WATERMARK validates the
stricter RFC3339 UTC-Z: `'^[0-9]{4}-..T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?Z$'`. A timestamp
written as `2026-07-20T12:00:00+05:30` passes WRITE_WATERMARK's check but fails READ_WATERMARK's
check on the subsequent run → READ_WATERMARK falls back to 24h window → the watermark is
effectively lost after every run that writes a non-UTC-Z timestamp. The asymmetry also means
a monotonic-guard bypass: if `effective_ts` after the `max()` comparison is a non-UTC-Z string,
READ_WATERMARK will reject it on the next run regardless of its lexicographic order.

**Suggestion:** Align WRITE_WATERMARK's validation regex to match READ_WATERMARK's:
`'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?Z$'`. Low-effort fix.

---

### ADV-F2-P4-O2 — OBS: Marker store cleanup mechanism unspecified

**Spec locus:** architecture-delta.md D-DEC-001 + C-29 description.

**Observation:** The marker store at `${CLAUDE_PLUGIN_DATA}/markers/` accumulates `.used`
and expired `.marker.json` files indefinitely. No cleanup mechanism is specified in D-DEC-001
or the monitoring-loop packaging (D-DEC-003). Over time the marker store grows unboundedly;
a glob scan over `*.marker.json` on a large store is O(N) per require-review invocation.
In a high-volume loop environment (50 alerts × 3 files per run × 96 runs/day = ~14,400 marker
artifacts per day), glob performance degrades meaningfully.

**Suggestion:** Specify a cleanup function `cleanup_marker_store()` in D-DEC-001 that removes
files matching `*.marker.json.used` and `*.marker.json` with `expires_at_utc < now() - 10m`
(expired + grace period). Call at start of each monitoring-loop run or once per hour via
a companion cron entry. Keep `audit.log` (do not rotate it in cleanup).

---

### ADV-F2-P4-O3 — OBS: Grace-window drop trade-off not documented

**Spec locus:** architecture-delta.md D-DEC-002 WATERMARK_GRACE_SECONDS.

**Observation:** D-DEC-002 documents the grace window's purpose (catch late/out-of-order OCSF
events) but does not document the converse: events with ETL latency GREATER than
`WATERMARK_GRACE_SECONDS` (default 5 minutes) are PERMANENTLY dropped. If the prism OCSF
pipeline has bursts of > 5-minute ETL latency (possible under load), events from those bursts
are silently missed. The architecture should document this trade-off explicitly and note
ASM-008 (prism `_time` format unvalidated) as a related assumption.

**Suggestion:** Add a note to D-DEC-002: "Events with ETL latency exceeding
WATERMARK_GRACE_SECONDS are permanently dropped. Operators must configure
WATERMARK_GRACE_SECONDS to exceed the 99th-percentile ETL latency of their prism deployment.
ASM-008 (prism `_time` format) is a related unvalidated assumption."

---

## Summary Table

| ID | Severity | Title | Assignee |
|----|----------|-------|---------|
| ADV-F2-P4-001 | CRITICAL | Dispatch collision — canonical verdict path misrouted to markdown branch | Architect (D-DEC-008) + PO (BC-3.03.001) |
| ADV-F2-P4-002 | CRITICAL | create pattern `.*` bypass defeats org-binding + prefix-match | Architect (D-DEC-008) + PO (BC-3.03.001) |
| ADV-F2-P4-003 | MAJOR | BC-10.01.001 Inv#5 inverted `>` operator — silence condition fires on wrong polarity | PO (BC-10.01.001) |
| ADV-F2-P4-004 | MAJOR | Hard floor blocks BLIND-SPOT/Indeterminate ticket creation — silent failure in unattended cron | Architect (D-DEC-012) + PO (BC-10.01.001) |
| ADV-F2-P4-005 | MAJOR | autonomy_enabled kill switch not in verdict schema — enforcement is LLM-mediated | Architect (D-DEC-008 operational field) + PO (BC-3.03.001) |
| ADV-F2-P4-006 | MAJOR | Enum-membership not validated before hard-floor — case-mangled fields bypass hard floor | Architect (D-DEC-008 emitter) + PO (BC-3.03.001) |
| ADV-F2-P4-007 | MINOR | BC-10.01.001 Inv#10 contradicts EC-006/EC-014 — must narrow to allow review-surfacing | PO (BC-10.01.001) |
| ADV-F2-P4-008 | MINOR | BC-4.02.001 PC#4 cross-tenant hard-floor stale — removed at P3-011 | PO (BC-4.02.001) |
| ADV-F2-P4-009 | MINOR | architecture-delta §5.4 audit-path "open" note is stale — resolved at BC-3.01.001 v1.14 | Architect (§5.4) |
| ADV-F2-P4-010 | MINOR | Audit log raw ticket_id/org_slug newline injection — extend ADV-F2-013 to all fields | Architect + PO (BC-3.01.001) |
| ADV-F2-P4-011 | MINOR | No per-run alert cap or budget-exhaustion behavior defined in NFR | PO (NFR) + Architect (D-DEC-003 note) |
| ADV-F2-P4-012 | MINOR | BC-3.03.001 PC#1 fast-path test order incompatible with JSON-first dispatch fix | PO (BC-3.03.001) |
| ADV-F2-P4-O1 | OBS | WRITE_WATERMARK validation looser than READ — RFC3339 UTC-Z asymmetry | Architect (D-DEC-002) |
| ADV-F2-P4-O2 | OBS | Marker store accumulates unboundedly — no cleanup mechanism specified | Architect (D-DEC-001) |
| ADV-F2-P4-O3 | OBS | Grace-window ETL drop trade-off not documented | Architect (D-DEC-002) |

*End of pass-4 adversarial review. Architect owns all D-DEC-NNN edits.
PO owns all BC-NNN.NNN.NNN edits.*

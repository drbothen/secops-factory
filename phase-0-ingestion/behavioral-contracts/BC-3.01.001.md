---
document_type: behavioral-contract
level: L3
version: "1.21"
status: draft
producer: product-owner
timestamp: 2026-07-20T00:00:00
phase: f2
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/require-review.sh, plugins/secops-factory/tests/hooks.bats, phase-f2-spec-evolution/architecture-delta.md]
input-hash: "COMPUTE-AT-COMMIT"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/require-review.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-01
lifecycle_status: active
introduced: v0.7.0
modified: ["v0.9.x-PR13-2026-07-19", "v0.9.x-PR14-2026-07-19", "v0.9.x-ADV0-001-ADV0-007-2026-07-19", "v1.4-ADV-0-405-ADV-0-507-2026-07-19", "v1.5-ADV-0-504-2026-07-19", "v1.6-ADV-0-706-obs-PC2-2026-07-19", "v1.7-ADV-0-801-PR15-2026-07-19", "v1.8-ADV-0-A01-ADV-0-A02-ADV-0-A04-2026-07-19", "v1.9-ADV-0-B01-2026-07-19", "v1.10-RESYNC-PR17-2026-07-19", "v1.11-D-DEC-001-D-DEC-008-2026-07-20", "v1.12-FV-PROPOSED-DROP-2026-07-20", "v1.13-ADV-F2-013-014-017-018-2026-07-20", "v1.14-ADV-F2-P2-003-007-012-2026-07-20", "v1.15-ADV-F2-P3-002-011-2026-07-20", "v1.16-D-DEC-012-P4-010-P4-002-2026-07-21", "v1.17-FV-VP-HOOK-024-029-ANCHORS-2026-07-21", "v1.18-ADV-F2-P6-001-P6-004-2026-07-21", "v1.19-ADV-F2-P7-005-2026-07-21 [SM-ID-sync per FV]", "v1.20-ADV-F2-P8-002-P8-003-2026-07-21 [SM-ID-sync per FV]", "v1.21-ADV-F2-P9-001-2026-07-21 [SM-ID-sync per FV]"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.01.001: require-review Hook — Jira Field-Modification Gate

> **Revision history:**
> - v1.21 (2026-07-21): Pass-9 adversarial remediation — ADV-F2-P9-001 (MAJOR) backslash-escape tokenizer extension. (1) **`structural_label_check` v2 — backslash-escape handling (P9-001 MAJOR):** The P8-002 tokenizer exits double-quote state on `\"` (wrong — bash keeps `\"` as a literal `"` inside IN_DOUBLE). Attack vector: `jr issue create --project KEY --summary "normal\"" --label REVIEW-REQUIRED` — P8-002 exits IN_DOUBLE at `\"`, swallows `--label REVIEW-REQUIRED` into a second double-quote region → has_review_label=FALSE → regular create marker authorizes a REVIEW-REQUIRED-labeled command (security bypass). Fixed v2 tokenizer (index-based, replaces for-char-in-cmd loop): `\"` in IN_DOUBLE → stays IN_DOUBLE, adds literal `"` to token body; `\\` in IN_DOUBLE → stays IN_DOUBLE, adds literal `\`; only a bare `"` ends the double-quote region → `--label REVIEW-REQUIRED` is exposed as a standalone token → has_review_label=TRUE → regular create marker DENIED. Also: `\'` in UNQUOTED — P8-002 entered IN_SINGLE (wrong); v2: backslash in UNQUOTED consumes next char as literal `'` with NO state toggle. IN_SINGLE unchanged (no escaping in bash single-quotes). `--label=VALUE` equals form confirmed NOT supported by jr CLI (`jr issue create --help`, 2026-07-21) — equals-form vector **SCOPED OUT**; monitoring loop never emits it. (2) **EC-025 added:** Two directions: (A) escaped quote in `--summary` with real `--label` outside → has_review_label=TRUE → DENY (security: escaped quote must not hide real label); (B) escaped quote inside `--summary`, no real label outside → has_review_label=FALSE → ALLOW (false-deny prevention). (3) **VP-HOOK-024 v1.21 extension:** escaped-quote differential-vs-bash vector partition, paired mutant (SM-43), equals-form vector SCOPED OUT note.
> - v1.20 (2026-07-21): Pass-8 adversarial remediation — ADV-F2-P8-002 (MAJOR) quote-aware tokenizer + ADV-F2-P8-003 (MINOR) EC-023 direction A correction. (1) **Step-6a `structural_label_check` — quote-aware state-machine tokenizer (P8-002 MAJOR):** Replaced `split_on_whitespace` in the `structural_label_check` pseudocode with a quote-aware state machine (UNQUOTED / IN_SINGLE / IN_DOUBLE states). The hook receives the raw command string including literal quote characters via `jq -r '.tool_input.command'` (no shell expansion at this point). A naive `split_on_whitespace` incorrectly treats `--label` inside a quoted `--summary` value as a standalone flag token. The quote-aware tokenizer accumulates all chars inside `"..."` or `'...'` into a single token body, so `--label REVIEW-REQUIRED` embedded in a double-quoted `--summary` value is never seen as a standalone `--label` token — `has_review_label=false`. EC-024 is now internally consistent: the old contradictory hedge ("if the shell delivered it as separate tokens...") is removed; the correct explanation is that the hook receives the raw string with literal quotes and the tokenizer handles them. This produces a separately killable mutant (SM-42) — revert `structural_label_check` to non-quote-aware `split_on_whitespace` → EC-024 vector produces false DENY. (2) **EC-023 direction A correction (P8-003 MINOR):** Removed false claim that the `( |$)` boundary in the regular create pattern rejects a review-labeled command at step 5. Bash `[[ =~ ]]` is NOT tail-anchored; the pattern `^jr (--output json )?issue create --project PRISM-DEMO( |$)` MATCHES `jr issue create --project PRISM-DEMO --label REVIEW-REQUIRED --summary "..."` because the `( |$)` matches the space after `PRISM-DEMO` and the regex is not anchored at the tail. Anti-fungibility direction A is enforced EXCLUSIVELY at step 6a (`structural_label_check(command)=true` + `authorized_operations==["create"]` → CONTINUE). Step 6a is therefore the load-bearing single enforcement point for direction A. The generation-table note and EC-023 Expected Behavior updated accordingly.
> - v1.19 (2026-07-21): Pass-7 adversarial remediation — ADV-F2-P7-005 (MINOR) step-6a structural token detection fix. (1) **Step-6a `has_review_label` structural fix (ADV-F2-P7-005):** Replaced raw substring check (`"--label REVIEW-REQUIRED" in command` OR `"--label BLIND-SPOT" in command`) with `structural_label_check(command)` — a whitespace-token-position check that returns true only when `--label` appears as a standalone flag token immediately preceding `REVIEW-REQUIRED` or `BLIND-SPOT` as the next token. The old substring check caused a false-deny on regular creates whose `--summary` value contained the literal text `--label REVIEW-REQUIRED` — the embedded text is not a standalone flag token but was matched by raw substring. This was a functional bug (fail-closed, not a bypass) affecting operators whose alert summaries mention label strings. The structural check matches the architecture-delta v1.10 canonical pseudocode. Both occurrences of `has_review_label` assignment updated (step 6 pre-check AND step 6a block). (2) **EC-024 added:** False-deny prevention — regular create whose `--summary` contains the literal string `"--label REVIEW-REQUIRED"` is ALLOWED with a `["create"]` marker (structural check does not fire on summary content). (3) Corresponding canonical test-vector row added. (4) Step-6a comment block updated with ADV-F2-P7-005 fix description and `structural_label_check` pseudocode. (5) VP-HOOK-024 v1.19 extension: EC-024 false-deny-prevention vector added.
> - v1.18 (2026-07-21): Pass-6 adversarial remediation — ADV-F2-P6-001 (CRITICAL) consumer anti-fungibility + ADV-F2-P6-004 create-scope downgrade doc. (1) Consumer algorithm step (6): replaced OR-accept semantics (`["create"]` OR `["create-review"]` for `jr issue create`) with exact-type matching — commands with `--label REVIEW-REQUIRED` or `--label BLIND-SPOT` accept ONLY `["create-review"]` markers; commands without review label accept ONLY `["create"]` markers. `jr issue comment ...` retains OR-accept for `["comment"]`/`["comment-review"]` pending ASM-014 structural check. (2) New STEP 6a anti-fungibility cross-check added inline: `has_review_label` structural check prevents create-review markers from authorizing non-review-labeled creates and regular create markers from authorizing review-labeled creates (EC-023). (3) Create-scope project-binding note updated per ADV-F2-P6-004: removed ORG-A/ORG-B per-org-key claims; documented explicit downgrade — single-project PRISM-DEMO config makes per-org isolation infeasible; cross-org protection for create-review operations relies on review-label binding via STEP 6a + single-use + TTL. (4) EC-023 added (consumer anti-fungibility edge case). (5) VP-HOOK-029 citation updated to FINALIZED (verification-delta.md v1.6 §8.15 item 1; kill target SM-32 only); anti-fungibility vectors attributed to VP-HOOK-024 (mutants SM-36/SM-37 per FV namespace — SM-33/SM-34 are occupied pass-4 sentinels). [namespace-sync per FV]
> - v1.17 (2026-07-21): VP-anchor additions only — zero semantic change. (a) Consumer step (5) anchored `command_pattern` match: added VP-HOOK-024 citation for the create injection-safety guarantee (`--project` first, trailing `( |$)` boundary — `--summary` injection + PROD/PRODUCTION prefix → DENY; ADV-F2-P4-002). (b) Consumer step (8) audit control-char sanitization: added VP-HOOK-024 citation for the audit-forgery leg (control chars stripped from `ticket_id`/`org_slug`/`authorized_operations[0]` before interpolation; ADV-F2-P4-010). (c) Consumer step (6) create-review/comment-review token acceptance: added VP-HOOK-029 citation (P1 PROPOSED — fail-loud escalation consumer path; review token acceptance is the consumer leg of the fail-loud invariant). Added VP-HOOK-029 row to Verification Properties table. Verification-delta.md v1.5 §7 Part E.
> - v1.16 (2026-07-21): [D-DEC-012] Consumer algorithm step (6) extended to accept `create-review` and `comment-review` as valid `authorized_operations` tokens: `jr issue create ...` commands accept markers with `["create"]` OR `["create-review"]`; `jr issue comment ...` commands accept markers with `["comment"]` OR `["comment-review"]`. Both review-marker types are consumed via the same iterative-consume atomic-rename path; no other logic changes to the consumer algorithm. [ADV-F2-P4-010] Consumer step (8) audit-log construction extended to strip control characters (0x00–0x1f via `tr -d '\000-\037'`) from `ticket_id`, `org_slug`, and `authorized_operations[0]` before interpolation into the audit line — extends the existing base64 command encoding (ADV-F2-013) to all attacker-influenceable fields. [ADV-F2-P4-002] Create-scope project-binding note updated: the create `command_pattern` is now `^jr (--output json )?issue create --project <jira_project_key>( |$)` (no `.*` before `--project`; trailing `( |$)` prevents ORG_A matching ORG_A_EXTRA); consumer step (5) anchored match enforces that a create marker for `--project ORG_A` cannot authorize `--project ORG_A_EXTRA`.
> - v1.15 (2026-07-20): ADV-F2-P3-002/ADV-F2-P3-011: (1) [P3-002] Added create-scope project-binding note to PC#2 hard-floor guarantee section: a create marker whose command_pattern encodes `--project ORG-A` cannot authorize a `jr issue create --project ORG-B` call — the anchored match at consumer step (5) enforces this; no additional org_slug lookup needed. (2) [P3-011] Removed "cross-tenant scope" from the hard-floor guarantee category list in PC#2 — per D-DEC-005, plugin obligation is org_slug scoping only; cross-tenant indicator detection is not implementable at the plugin layer (coordinated with BC-3.03.001 v1.10 removal of the PENDING-DEFINITION cross-tenant hard-floor leg).
> - v1.0 (2026-07-19): Initial extraction from `require-review.sh` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): Revised to reflect PR #13 (commit f450d9f) behavior changes — SEC-001 (`jr issue comment` moved from allow to deny) and SEC-002 (unknown jr subcommands changed from fail-open to fail-closed). Previous postconditions #4 and #5 and invariant #3 were stale.
> - v1.2 (2026-07-19): Revised to reflect PR #14 (commit 0ec794a) — expanded read-only allowlist with two families: plain forms (`jr issue changelog`, `jr assets search/view`, `jr --version`) and `--output json` forms for the metrics suite. EC-010 flips from Deny to Allow. New Invariant #4 documents the `--output json` global-flag placement nuance (root cause of DI-010 regression). BATS count updated to 138 tests.
> - v1.3 (2026-07-19): Adversarial review pass 1 fixes — ADV-0-001: renumbered VP-HOOK-004/005/006 to VP-HOOK-020/021/022 (global sequential namespace; 004-006 are owned by BC-3.02.001 enrichment-completeness). ADV-0-007: corrected EC-015 mechanism — `jr --output json issue comment` is denied by the fail-closed catch-all, NOT by the write-block check (Invariant #4 applies; `jr issue comment` is not a substring of that command). Security extensibility note added to Refactoring Notes.
> - v1.4 (2026-07-19): ADV-0-405: corrected three stale line-number anchors — non-jr fast path is `require-review.sh:47-50` (not 48-50), fail-closed block is `require-review.sh:96-98` (not 97-98), source file is 98 lines (not 99). ADV-0-507 (pass-4 input-hash batch): input-hash established as dual-file block scalar (require-review.sh + require-review.ps1 sibling).
> - v1.5 (2026-07-19): ADV-0-504: corrected one remaining stale anchor in EC-015 — fail-closed catch-all is `(lines 96-98)` not `(lines 97-98)`. Missed by v1.4 sweep.
> - v1.6 (2026-07-19): ADV-0-706: Standardized write-block citations to canonical form `88-94 (deny at :93)`. Observation: Softened PC#2 confidence note — `comment`/`edit`/`move` deny verified by both code analysis and BATS; `assign`/`create` deny verified by code analysis only (no dedicated positive BATS tests for these two verbs; residual gap noted in GAP-2 of verification-gap-analysis.md).
> - v1.7 (2026-07-19): ADV-0-801 / PR #15 (commit d304fa5): CRITICAL evaluation-order fix — write-block is now evaluated BEFORE the allowlist (old order was allowlist → write-block, enabling a bypass: `jr issue edit KEY --summary "see jr board"` matched the `jr board` allowlist token). `--output json` write forms explicitly added to the write-block list. New line anchors throughout. New Invariant #5 (write-block precedence). EC-015 updated (jr --output json issue comment now hits write-block directly). EC-016 added (bypass pattern now denied). Input-hash recomputed (both .sh and .ps1 changed).
> - v1.10 (2026-07-19): RESYNC-PR17: DI-005 `assign`/`create` deny now **BATS-verified** — PR #17 added `@test "require-review blocks jr issue assign without review (DI-005)"` (hooks.bats:426) and `@test "require-review blocks jr issue create without review (DI-005)"` (hooks.bats:433). PC#2 confidence note updated. Source Evidence test count updated 150→165 (hooks 44→59). Last Verified Against updated to d181ca2.
> - v1.9 (2026-07-19): ADV-0-B01: Converted all live hooks.bats line-range citations to @test-NAME references with current line numbers (PR #15 expanded require-review block to lines 9-177; downstream tests shifted +88 lines). Source Evidence range updated 9-93 → 9-177 (26 tests). Stale VP-HOOK-003/020/021/022 range refs replaced with exact @test names. PC#3 stale test name "allows jr issue view" corrected to "allows jr read-only commands" (test was renamed when PR #14 expanded the allowlist). PC#2 line :88 corrected to :89 (move test shifted one line within the block). hooks.bats references now use @test names for churn resilience.
> - v1.8 (2026-07-19): ADV-0-A01: Replaced all live require-review.sh line-number citations with construct-name references (fast-path guard / write-block if-block / read-only allowlist / fail-closed catch-all / jq-availability guard / emit_allow / emit_deny) — makes the "anchor-churn retired" capstone claim true and prevents future PR-induced staleness. ADV-0-A02: Source Evidence test count updated to 150 @tests (hooks 44, skills 81, integration 11, parity 14); PR #15 +12 row added to Change Log. ADV-0-A04: VP-HOOK-023 added (--output json write-block family as provable property); canonical deny vector row added to test vectors table.
> - v1.14 (2026-07-20): ADV-F2-P2-003/ADV-F2-P2-007/ADV-F2-P2-012: (1) Consumer algorithm multiplicity fix (ADV-F2-P2-003 MAJOR): replaced "rename-fail → deny immediately" with iterative-consume — candidates collected and sorted by issued_at_utc ASC; first successful atomic rename = allow; if rename fails CONTINUE to next candidate; all exhausted → deny. Fixes multi-org loop producing ≥2 create markers before jr runs (all were denied under the prior single-candidate fail-fast). Anti-forgery preserved: each marker single-use via atomic rename; forged markers still cannot be created. (2) Audit log path alignment (ADV-F2-P2-007 MEDIUM): `${CLAUDE_PLUGIN_DATA}/audit.log` → `${CLAUDE_PLUGIN_DATA}/markers/audit.log` in Invariant #2 and PC#2 step (8) — aligns with D-DEC-001 canonical pseudocode and C-29 description. (3) Invariant numbering order corrected (ADV-F2-P2-012): invariants were listed 1,2,3,5,4; corrected to 1,2,3,4,5 by moving Invariant #4 (`--output json` global flag) to appear before Invariant #5 (write-block evaluated before allowlist).
> - v1.13 (2026-07-20): ADV-F2-013/ADV-F2-014/ADV-F2-017/ADV-F2-018 + marker schema v2.0 consumer: (1) Removed dead-code `used != false` check at algorithm step (3) — `.marker.json.used` files are excluded from `*.marker.json` glob; the atomic rename IS the single-use enforcement mechanism; EC-019 Expected Behavior updated (ADV-F2-018). (2) Added explicit deny if atomic mv-rename fails: "if rename fails → emit_deny('Marker invalidation failed — fail-closed')" (ADV-F2-014 TOCTOU safety). (3) Audit trail base64-encodes command field: `command_b64=$(printf '%s' "${command}" | base64 | tr -d '\n')` prevents newline injection into audit.log chain-of-custody (ADV-F2-013). (4) Consumer validates `now() > expires_at_utc` (absolute, schema v2.0) instead of `(now - issued_at) > 30s` arithmetic — no read-side clock-skew arithmetic (D-DEC-001 v2.0). (5) EC-022 aligned to D-DEC-008 ticket-bound generation table with `(--output json )?` optional group and trailing-space guard. (6) Create-scoped and assign-scoped allow-path test vectors added (VP-HOOK-024 completeness). (7) Revision-history ordering corrected: v1.11 now precedes v1.12 (ADV-F2-017 fix).
> - v1.12 (2026-07-20): FV-PROPOSED-DROP: VP-HOOK-024 is now FINALIZED per verification-delta §1 — dropped `(PROPOSED)` qualifier from VP table row and Postcondition #2 confidence line.
> - v1.11 (2026-07-20): D-DEC-001/D-DEC-008: **UPDATED** — Added marker-validation conditional-allow branch inside the write-block path. Former "unconditional deny for write-block-matched commands" becomes "deny UNLESS a valid unexpired single-use scoped marker is found in `${CLAUDE_PLUGIN_DATA}/markers/`". Write-block-first ordering (Invariant #5) is preserved — the marker branch is INSIDE the write-block evaluation path, not a bypass of it. Hard-floor categories (Indeterminate/HIGH/CRIT severity, critical assets, T1003/T1068/T1021/T1041 techniques) never receive markers (enforced at emitter — disposition-guard D-DEC-008), so require-review denies them unconditionally. Invariant #2 updated to permit marker-store filesystem access for write-block-matched commands only. EC-017..EC-022 added. VP-HOOK-024 added.

## Preconditions

1. The hook receives a Claude Code `PreToolUse/Bash` event envelope via stdin as JSON, containing `tool_input.command` (string). Confidence: verified by code analysis (require-review.sh — command extracted from stdin JSON via jq).
2. `jq` is installed and available on `$PATH`. If absent, the hook exits with code 1 and an error to stderr; it never emits a `permissionDecision` envelope. Confidence: verified by code analysis (jq-availability guard in require-review.sh).
3. The hook is wired via `hooks.json` to fire on `PreToolUse` events for the `Bash` tool only. Confidence: verified by code analysis (`hooks/hooks.json`).

## Postconditions

1. If `tool_input.command` does not contain the substring `jr `, the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (fast-path guard in require-review.sh) and BATS test `@test "require-review allows non-jr commands"` (hooks.bats:9).

2. **[UPDATED v1.11]** If `tool_input.command` contains any write-block pattern, the hook enters the **marker-validation branch** (D-DEC-001/D-DEC-008). **This check is evaluated BEFORE the allowlist (Invariant #5).**

   Two families of write patterns are blocked (10 entries total): **Plain forms:** `jr issue comment ` (trailing-space guard against `jr issue comments` collision), `jr issue edit`, `jr issue move`, `jr issue assign`, `jr issue create`. **`--output json` forms (added PR #15/ADV-0-801):** `--output json issue comment ` (trailing-space guard), `--output json issue edit`, `--output json issue move`, `--output json issue assign`, `--output json issue create`.

   **Marker-validation algorithm (D-DEC-001 v2.0 — [UPDATED v1.14] iterative-consume):**

   The hook scans `${CLAUDE_PLUGIN_DATA}/markers/*.marker.json` for valid unexpired single-use
   scoped markers using the following algorithm (fail-closed: any error → deny):

   ```
   marker_dir = ${CLAUDE_PLUGIN_DATA}/markers/
   if marker_dir does not exist or contains no *.marker.json files:
     emit deny (reason: "review approval")
     exit 0

   # Phase 1: collect all valid candidates
   candidates = []
   for each file F in marker_dir/*.marker.json:
     (1) path-safety check: if basename(F) contains ".." or "/" → skip (EC-021 path-traversal guard)
     (2) parse JSON via jq: if parse fails → skip (EC-020 malformed JSON)
     # NOTE: "used != false" check REMOVED (ADV-F2-018): .marker.json.used files are excluded
     # from the *.marker.json glob — they never appear as candidates. The atomic rename IS
     # the single-use enforcement mechanism. Dead-code removed at v1.13.
     (3) if issued_at_utc > now() (future-dated) → skip (adversarial signal; expire the file)
     (4) TTL check: if now() > expires_at_utc → skip (EC-017 expired)
         # Schema v2.0: consumer compares expires_at_utc directly — no issued_at + ttl_seconds arithmetic
     (5) anchored command_pattern match: apply regex command_pattern (anchored at ^) against command;
         if no match → skip (EC-022 wrong ticket-id or EC-018 wrong operation pattern)
         # VP-HOOK-024 cross-reference (v1.17): the create command_pattern injection-safety
         # guarantee is enforced here. For create markers: pattern is anchored
         # `^jr (--output json )?issue create --project <key>( |$)` — `--project` is the
         # FIRST fixed argument (no `.*` before it); trailing `( |$)` prevents prefix-match
         # (ORG_A marker does NOT authorize ORG_A_EXTRA command; PROD marker does NOT authorize
         # PRODUCTION). An attacker-influenceable `--summary` value cannot satisfy the project-key
         # binding via prefix-match injection. (ADV-F2-P4-002 CRITICAL; verification-delta.md
         # v1.5 §2 / §7 Part E item 3a).
     (6) authorized_operations scope check — EXACT-TYPE MATCHING (ADV-F2-P6-001):
         has_review_label = structural_label_check(command)   # P9-001 v2: backslash-escape (index-based); P8-002: quote-aware; P7-005: token-position, not substring
         - `jr issue create ...` command: matching depends on review-label presence (enforced via step 6a):
           - command carries `--label REVIEW-REQUIRED` or `--label BLIND-SPOT` → accept ONLY `["create-review"]`; skip `["create"]` (EC-023)
           - command lacks review label → accept ONLY `["create"]`; skip `["create-review"]` (EC-023)
           (In practice the command_pattern itself enforces this structurally: create-review patterns include
           `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed second position per ADV-F2-P6-001; the anchored_match
           at step 5 will reject mismatched commands. Step 6a provides defense-in-depth.)
         - `jr issue comment ...` command → accept `["comment"]` OR `["comment-review"]`
           (Structural label check for comment-type commands pending ASM-014 empirical validation of
           `jr issue comment --label` support; current guard: ticket_id binding + Iron Law.)
         - `jr issue assign ...` command → accept ONLY `["assign"]` (unchanged)
         If the command does not match any accepted authorized_operations value → skip (EC-018 wrong-scope marker)
         Note: `create-review` and `comment-review` are RESTRICTED markers for [REVIEW-REQUIRED]/[BLIND-SPOT] ticket operations;
         they are consumed via the same iterative-consume atomic-rename path as regular markers.

         # ── STEP 6a: Consumer anti-fungibility cross-check (ADV-F2-P6-001; P7-005 structural fix; P9-001 backslash-escape extension) ──
         # create-review and create markers must not be fungible in either direction:
         # - A create-review marker cannot authorize a command that lacks --label REVIEW-REQUIRED|BLIND-SPOT
         # - A create marker cannot authorize a command that carries a review label
         # "has_review_label" is a STRUCTURAL property: --label must appear as a standalone flag token,
         # not as a substring anywhere in the command (including attacker/LLM-influenceable --summary text).
         #
         # ADV-F2-P7-005 FIX — STRUCTURAL TOKEN DETECTION; P8-002 UPDATE — QUOTE-AWARE TOKENIZER; P9-001 UPDATE — BACKSLASH-ESCAPE (v2 INDEX-BASED):
         # Old (defective): has_review_label = ("--label REVIEW-REQUIRED" in command) OR ("--label BLIND-SPOT" in command)
         # A command like `jr issue create --project KEY --summary "rule --label REVIEW-REQUIRED fired"`
         # sets has_review_label=true against a ["create"] marker → false-deny of a legitimate regular create.
         # Fix: parse the command into quote-aware tokens; check only for --label as a standalone
         # token immediately preceding REVIEW-REQUIRED or BLIND-SPOT as the next token.
         # P9-001 additionally handles backslash-escape: `\"` in IN_DOUBLE stays IN_DOUBLE (bash parity);
         # `\'` in UNQUOTED is a literal char, no state toggle (see v2 tokenizer pseudocode below).
         #
         # P8-002 QUOTE-AWARE TOKENIZER (state machine); P9-001 BACKSLASH-ESCAPE EXTENSION (v2 INDEX-BASED):
         # The hook receives the raw command string including literal quote characters via
         # `jq -r '.tool_input.command'` — no shell expansion has occurred at this point.
         # A naive split_on_whitespace would treat `--label` inside a quoted `--summary` value
         # as a standalone token, incorrectly setting has_review_label=true (false-deny).
         # P8-002 added UNQUOTED/IN_SINGLE/IN_DOUBLE states. P9-001 extends to handle backslash-
         # escape sequences (index-based to support 2-char lookahead — replaces for-char-in-cmd):
         # - UNQUOTED + `\X`: next char is literal; NO state toggle (fixes `\'` entering IN_SINGLE).
         # - IN_DOUBLE + `\"`: literal `"`, STAY IN_DOUBLE (fixes `\"` prematurely exiting double-quote).
         # - IN_DOUBLE + `\\`: literal `\`, STAY IN_DOUBLE. Other `\X` in IN_DOUBLE: backslash literal.
         # - IN_SINGLE: UNCHANGED (no escaping in bash single-quotes; backslash always literal).
         #
         # `--label=REVIEW-REQUIRED` equals form: NOT supported by jr CLI (confirmed `jr issue create
         # --help`, 2026-07-21). Monitoring loop never emits it. Equals-form vector SCOPED OUT.
         #
         # QUOTE-AWARE TOKENIZER v2 (pseudocode for structural_label_check(cmd)):
         #   state = UNQUOTED
         #   cur_token = ""
         #   tokens = []
         #   i = 0
         #   while i < len(cmd):
         #     char = cmd[i]
         #     if state == UNQUOTED:
         #       if char == '\\' AND i+1 < len(cmd):       # P9-001: backslash in UNQUOTED
         #         i += 1
         #         cur_token += cmd[i]   # next char is literal (e.g., \' → ', \" → "); NO state toggle
         #       elif char == "'":   state = IN_SINGLE   # open single-quote; don't add quote char to token
         #       elif char == '"': state = IN_DOUBLE     # open double-quote; don't add quote char to token
         #       elif char is whitespace:
         #         if cur_token != "": tokens.append(cur_token); cur_token = ""
         #       else: cur_token += char
         #     elif state == IN_SINGLE:
         #       if char == "'": state = UNQUOTED        # close single-quote; don't add quote char
         #       else: cur_token += char                 # all chars inside single-quotes → literal
         #                                               # (backslash is literal inside single-quotes —
         #                                               #  UNCHANGED from P8-002; no escaping in bash single-quotes)
         #     elif state == IN_DOUBLE:
         #       if char == '\\' AND i+1 < len(cmd):    # P9-001: backslash in IN_DOUBLE
         #         next_char = cmd[i+1]
         #         if next_char == '"':
         #           cur_token += '"'    # \" in double-quotes → literal ", STAY IN_DOUBLE
         #           i += 1
         #         elif next_char == '\\':
         #           cur_token += '\\'   # \\ in double-quotes → literal \, STAY IN_DOUBLE
         #           i += 1
         #         else:
         #           cur_token += char   # other \X in double-quotes: backslash is literal char;
         #                               # next char processed on next iteration (bash behavior)
         #       elif char == '"': state = UNQUOTED      # close double-quote; don't add quote char
         #       else: cur_token += char                 # all other chars inside double-quotes → token body
         #     i += 1
         #   if cur_token != "": tokens.append(cur_token)   # flush final token
         #   for i in range(len(tokens) - 1):
         #     if tokens[i] == "--label" AND tokens[i+1] in {"REVIEW-REQUIRED", "BLIND-SPOT"}:
         #       return True
         #   return False
         # EC-024 RECONCILIATION (UNCHANGED — still valid under v2 tokenizer): for `jr issue create --project PRISM-DEMO --summary "rule --label REVIEW-REQUIRED in payload"`:
         # tokenizer enters IN_DOUBLE at the `"` before "rule"; all chars through closing `"` → --summary token body.
         # Token sequence: [jr, issue, create, --project, PRISM-DEMO, --summary,
         #                  rule --label REVIEW-REQUIRED in payload]
         # `--label` is NOT a standalone token → has_review_label=false → ["create"] marker consumed → ALLOW.
         # (EC-024: false-deny prevention for regular creates with label text in quoted --summary.)
         #
         # P9-001 DIFFERENTIAL-VS-BASH VECTOR PARTITION (under VP-HOOK-024):
         # Partition 1 (escaped-quote hiding a real label — SECURITY-CRITICAL; see EC-025 direction A):
         #   Input: `jr issue create --project PRISM-DEMO --summary "normal\"" --label REVIEW-REQUIRED`
         #   v2 tokenizer: `\"` in IN_DOUBLE → literal `"` to token body, STAY IN_DOUBLE; real `"` ends
         #   double-quote; `--label REVIEW-REQUIRED` are standalone tokens → has_review_label=TRUE → DENY ✓
         #   Buggy P8-002: exits IN_DOUBLE at `\"` → `--label REVIEW-REQUIRED` swallowed → has_review_label=FALSE → ALLOW (bypass)
         #   Paired mutant: revert P9-001 backslash-escape handling → has_review_label=FALSE → false ALLOW (SM-43)
         # Partition 2 (escaped quote inside summary, no real label outside; see EC-025 direction B):
         #   Input: `jr issue create --project PRISM-DEMO --summary "normal\"fine"` (no real --label outside)
         #   v2 tokenizer: `\"` in IN_DOUBLE → literal `"`, STAY IN_DOUBLE; no standalone `--label` → has_review_label=FALSE → ALLOW ✓
         # Partition 3 (equals-form — SCOPED OUT):
         #   `--label=REVIEW-REQUIRED` NOT supported by jr CLI (confirmed 2026-07-21); never emitted by loop.
         #   No test vector required. VP note: "equals-form vector scoped out per D-DEC-001 v1.12."
         #
         # Note: comment/comment-review structural check pending ASM-014 (jr issue comment --label support);
         #       current guard for comment-review: ticket_id binding + Iron Law.
         has_review_label = structural_label_check(command)   # P9-001 v2: backslash-escape (index-based); P8-002: quote-aware (UNQUOTED/IN_SINGLE/IN_DOUBLE); P7-005: token-position, not substring
         IF json.authorized_operations == ["create-review"]:
           IF NOT has_review_label:
             CONTINUE         # EC-023: review marker requires review-labeled command (anti-fungibility)
         IF json.authorized_operations == ["create"]:
           IF has_review_label:
             CONTINUE         # EC-023: regular create marker cannot authorize a review-labeled command

         # VP-HOOK-024 cross-reference (v1.18, ADV-F2-P6-001; extended v1.19, ADV-F2-P7-005): step (6a)
         # anti-fungibility cross-check extends VP-HOOK-024 with two new P6-001 vectors — valid marker
         # consumed only when label-type matches marker type in BOTH directions (EC-023).
         # Paired mutants: SM-36 (remove STEP 6a check for create-review direction — review marker
         # accepted for non-review-labeled create), SM-37 (remove STEP 6a check for create direction —
         # regular create marker accepted for review-labeled create). (verification-delta.md v1.6 §8.15 item 5).
         # v1.19 extension (ADV-F2-P7-005): EC-024 false-deny-prevention vector — structural_label_check
         # returns false for a --summary value containing "--label REVIEW-REQUIRED" as embedded text
         # (not a standalone flag token); regular create with such a summary + ["create"] marker → ALLOW.
         # VP-HOOK-029 cross-reference (v1.18, ADV-F2-P6-001): step (6) exact-type matching forms the
         # CONSUMER leg of the fail-loud invariant. VP-HOOK-029 (FINALIZED per verification-delta.md
         # v1.6 §8.15 item 1): require-review accepts create-review token for correctly-labeled hard-floor
         # verdicts. VP-HOOK-029 kill target: SM-32 (review-surfacing-hard-floor-bypass-removed).
     # VALID CANDIDATE — add to list
     candidates.append({file: F, issued_at_utc: json.issued_at_utc, json: json})

   if len(candidates) == 0:
     emit deny (reason: "review approval")
     exit 0

   # Phase 2: iterative-consume (ADV-F2-P2-003 fix — replaces prior "rename-fail → deny" single-attempt)
   # Sort by issued_at_utc ascending (oldest first — ensures FIFO consumption order)
   # Anti-forgery preserved: each marker is single-use via atomic rename; the iteration
   # only matters for legitimate concurrent same-scope markers (e.g., two TP create verdicts
   # produced in a multi-org loop before jr runs) — forged markers still cannot be created.
   sort candidates by issued_at_utc ascending
   for each candidate in candidates:
     (7) atomic mv-rename: rename candidate.file → marker.json.used
         (POSIX single atomic rename; prevents replay — EC-019 prevention)
         # ADV-F2-P2-003: if rename fails, a concurrent consumer already consumed this marker
         #                 → CONTINUE to next candidate (do NOT deny immediately)
         if rename fails → CONTINUE   # try next candidate
     # Rename succeeded — this marker is ours
     (8) append audit entry to ${CLAUDE_PLUGIN_DATA}/markers/audit.log:
         command_b64=$(printf '%s' "${command}" | base64 | tr -d '\n')
         # ADV-F2-013: base64-encode command to prevent newline injection into audit chain-of-custody
         # On macOS/BSD: base64 -b 0; on GNU: base64 -w 0; tr -d '\n' normalizes both
         # ADV-F2-P4-010: strip control characters (0x00-0x1f) from ALL attacker-influenceable fields
         # ticket_id comes from verdict (Jira API content — LLM-influenced, may contain \n)
         # org_slug comes from verdict (operator-configured; sanitize for defense-in-depth)
         # op comes from authorized_operations[0] (bounded enum; sanitize for defense-in-depth)
         safe_ticket=$(printf '%s' "${candidate.json.ticket_id}" | tr -d '\000-\037')
         safe_op=$(printf '%s' "${candidate.json.authorized_operations[0]}" | tr -d '\000-\037')
         safe_org=$(printf '%s' "${candidate.json.org_slug}" | tr -d '\000-\037')
         # ADV-F2-P2-007: canonical path is ${CLAUDE_PLUGIN_DATA}/markers/audit.log (= ${marker_dir}/audit.log)
         audit_line = "${ISO_NOW} MARKER_USED marker_id=${candidate.json.marker_id} op=${safe_op} ticket=${safe_ticket} org=${safe_org} command_b64=${command_b64}"
         # VP-HOOK-024 cross-reference (v1.17): control-char sanitization of ticket_id/org_slug/op
         # is the audit-forgery leg of VP-HOOK-024 (ADV-F2-P4-010). A `\n` in ticket_id cannot
         # forge a second MARKER_USED line because safe_ticket strips 0x00-0x1f before
         # interpolation. Combined with the base64-encoded command_b64 field (ADV-F2-013),
         # the audit log is injection-proof. (verification-delta.md v1.5 §2 / §7 Part E item 3b).
     (9) emit allow; exit 0

   # All candidates exhausted without a successful rename (concurrent consumers took each one)
   emit deny ("No marker could be consumed — deny (fail-closed)")
   exit 0
   ```

   > **Previous (v1.13) Phase 2 — single-attempt with immediate deny-on-fail:**
   > ```
   > # (no sort; single-candidate attempt)
   > --- VALID MARKER FOUND ---
   > (7) atomic mv-rename...
   >     If rename fails for any reason → emit_deny("Marker invalidation failed — fail-closed"); exit 0
   > ```
   > (ADV-F2-P2-003 fix: "rename-fail → deny immediately" replaced with "rename-fail → CONTINUE
   > to next candidate." A multi-org loop producing ≥2 create markers before jr runs caused all
   > creates to fail under the prior design. Anti-forgery property preserved — single-use atomic
   > rename; iteration only affects legitimate concurrent same-scope markers.)
   >
   > **Previous (v1.12) algorithm step (3):** "if used != false → skip (EC-019 replayed/consumed marker)". This check was dead code because the glob `*.marker.json` never matches `.marker.json.used` files (the rename changes the extension). Removed at v1.13 (ADV-F2-018). EC-019 threat remains valid — the MECHANISM is the rename, not the `used` field check.
   >
   > **Previous (v1.12) TTL step (5):** "if (now − issued_at) > 30 seconds → skip (EC-017 expired)". Updated to v2.0 absolute `expires_at_utc` check; TTL raised from 30s to 120s.
   >
   > **Previous (v1.12) step (9) audit:** `command='${command}'` (unescaped, vulnerable to newline injection). Changed to `command_b64=${command_b64}` at v1.13 (ADV-F2-013).

   **Hard-floor guarantee (D-DEC-008):** Hard-floor categories (Indeterminate verdict, severity HIGH/CRIT, critical-asset classification including `unknown` [ADV-F2-P3-001], MITRE techniques T1003/T1068/T1021/T1041, degraded/silent sensor) never receive a marker from disposition-guard. Therefore require-review will always exhaust the marker scan with no valid match and will emit deny for those commands unconditionally. The hard-floor property is enforced at the emitter (disposition-guard D-DEC-008), not here — require-review simply finds no valid marker.

   > **Previous (v1.14):** Hard-floor categories listed included "cross-tenant scope." Removed in v1.15 (ADV-F2-P3-011): per D-DEC-005, plugin obligation is org_slug scoping only; cross-tenant indicator detection is not implementable at the plugin layer (coordinated with BC-3.03.001 v1.10 removal).

   **Create-scope project-binding note (v1.15 — ADV-F2-P3-002; updated v1.16 — ADV-F2-P4-002; updated v1.18 — ADV-F2-P6-004):** Create markers carry the Jira project key in their `command_pattern`. The `.*` before `--project` was REMOVED per ADV-F2-P4-002: `--project` is the FIRST fixed argument after `issue create`, and the trailing `( |$)` boundary prevents prefix-match collisions (e.g., `--project ORG_A` does NOT match `--project ORG_A_EXTRA`). The anchored match at consumer algorithm step (5) enforces this project-key binding. **ADV-F2-P6-004 explicit downgrade:** Per-org project-key isolation (illustrated in prior versions with a ORG-A/ORG-B example) is infeasible under the brief's single-demo-project constraint — `PRISM-DEMO` is the sole project key across all orgs in the PRISM-DEMO deployment. Cross-org isolation for `create-review` operations in single-project config relies on three layered controls: (a) single-use atomic rename, (b) 120 s TTL, (c) review-label binding enforced by consumer step (6a) anti-fungibility cross-check (EC-023 — a regular `jr issue create` cannot steal a create-review marker because it lacks the `--label` flag). This is a documented limitation of PRISM-DEMO deployments; multi-project deployments retain full per-org-key binding via distinct project_key values in each marker's `command_pattern`. No additional consumer-side org_slug lookup is needed — the project-key binding is embedded in the command_pattern by the emitter (BC-3.03.001 Invariant #4).

   > **Previous (v1.10):** "If `tool_input.command` contains any write-block pattern, the hook emits `permissionDecision: deny` with a reason string containing 'review approval'. **This check is evaluated BEFORE the allowlist (Invariant #5)** — a command matching both a write-block pattern and an allowlist pattern is denied." (Unconditional deny — no marker-validation branch existed.)

   Confidence: D-DEC-001 binding decision (architecture-delta.md v1.1 §D-DEC-001). BATS tests for the deny path: `@test "require-review blocks jr issue comment without review (SEC-001)"` (hooks.bats:69), `@test "require-review blocks jr issue edit without review"` (hooks.bats:82), `@test "require-review blocks jr issue move without review"` (hooks.bats:89), `@test "require-review blocks jr issue assign without review (DI-005)"` (hooks.bats:426), `@test "require-review blocks jr issue create without review (DI-005)"` (hooks.bats:433). BATS tests for the marker-allow path: VP-HOOK-024.

3. If `tool_input.command` — after passing the write-block check (postcondition #2) — contains any entry from the explicit read-only allowlist, the hook emits `permissionDecision: allow` and exits 0. The allowlist is evaluated AFTER the write-block. The allowlist has two families: Confidence: verified by code analysis (read-only allowlist in require-review.sh) and BATS tests `@test "require-review allows jr read-only commands"` (hooks.bats:15).

   **Plain forms (family a):**
   - `jr issue view`
   - `jr issue list`
   - `jr issue comments`
   - `jr issue assets`
   - `jr issue transitions`
   - `jr issue changelog` *(added PR #14 — resolves DI-010)*
   - `jr assets search` *(added PR #14)*
   - `jr assets view` *(added PR #14)*
   - `jr sprint`
   - `jr board`
   - `jr project`
   - `jr me`
   - `jr auth`
   - `jr --version` *(added PR #14)*

   **`--output json` forms (family b — added PR #14, for metrics suite):**
   - `--output json issue view`
   - `--output json issue list`
   - `--output json issue comments`
   - `--output json issue changelog`
   - `--output json issue assets`
   - `--output json assets search`
   - `--output json assets view`

4. For any `jr` subcommand that does not match the write-block list (postcondition #2) and does not match the read-only allowlist (postcondition #3), the hook emits `permissionDecision: deny` with a reason instructing the operator to add the subcommand to the read-only allowlist if it is safe (fail-closed, SEC-002). Confidence: verified by code analysis (fail-closed catch-all in require-review.sh) and BATS test `@test "require-review blocks unknown mutation-shaped jr subcommand (SEC-002)"` (hooks.bats:76).
5. The exit code is always 0 for all business-logic decisions (both allow and deny). Exit code 1 is reserved exclusively for missing `jq` dependency. Confidence: verified by code analysis (emit_allow and emit_deny functions in require-review.sh).

## Invariants

1. The JSON output envelope structure is always `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"|"deny","permissionDecisionReason":"..."}}`. Confidence: verified by code analysis (emit_allow / emit_deny function bodies in require-review.sh).

2. **[UPDATED v1.14]** The hook never makes network calls and never spawns subprocesses beyond `jq`. For non-write-block commands, no filesystem access occurs — all decisions are made from the single stdin JSON envelope. For write-block-matched commands ONLY, the hook additionally reads `${CLAUDE_PLUGIN_DATA}/markers/*.marker.json` (glob scan via shell expansion), performs one atomic POSIX `mv` rename per candidate attempt to consume the matched marker (if valid — iterative until first success), and appends one line to `${CLAUDE_PLUGIN_DATA}/markers/audit.log`. No subprocesses beyond `jq`, `mv`, `cat` (audit append), and shell glob expansion. Execution is bounded at < 100ms for non-write-block commands; < 200ms for write-block commands (marker scan included).

   > **Previous (v1.13):** "appends one line to `${CLAUDE_PLUGIN_DATA}/audit.log`." (ADV-F2-P2-007: canonical path is `${CLAUDE_PLUGIN_DATA}/markers/audit.log` per D-DEC-001 pseudocode and C-29 description; must be inside the markers/ subdirectory.)

   > **Previous (v1.10):** "The hook never makes network calls, never spawns subprocesses beyond `jq`, and never reads the filesystem — all decisions are made from the single stdin JSON envelope. Execution is bounded at < 100ms." (No marker-store filesystem access existed.)

   Confidence: D-DEC-001 binding decision; architecture-delta.md v1.1 §D-DEC-001.

3. The hook is fail-closed for all `jr` subcommands: any `jr` command that is not on the write-block list and not on the read-only allowlist results in deny, not allow. Non-`jr` commands remain on a fast-path allow. This replaced the previous fail-open behavior as of PR #13 (SEC-002). Confidence: verified by code analysis (fail-closed catch-all in require-review.sh).

4. **`--output json` global flag placement creates a non-obvious substring matching boundary.** The command `jr --output json issue view KEY` does NOT contain the substring `jr issue view` because the global flag `--output json` sits between `jr` and `issue`. Therefore, the allowlist must carry both plain forms (e.g., `jr issue view`) and `--output json` forms (e.g., `--output json issue view`) as separate entries. A plain-form entry does not cover the `--output json` form of the same subcommand. This was the root cause of the DI-010 regression: the metrics suite issues `jr --output json issue changelog KEY`, but the v1.1 allowlist only had the plain form. Both families were added explicitly in PR #14. This invariant is documented in the `--output json` boundary doc comment in require-review.sh.

5. **Write-block is evaluated BEFORE the allowlist (ADV-0-801, PR #15).** A command that matches both a write-block pattern and an allowlist pattern is DENIED — the write-block check wins unconditionally. This ordering was fixed in PR #15 to close a critical bypass. The marker-validation branch (v1.11) is INSIDE the write-block evaluation path; it is not a post-allowlist bypass. Confidence: verified by code analysis (write-block if-block ordering rationale comment in require-review.sh). See EC-016.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr message "jq is required but not found", no JSON output |
| EC-002 | Empty stdin / malformed JSON | `jq -r '.tool_input.command // empty'` returns empty string; command is not `jr `; emit allow |
| EC-003 | `jr issue comment SEC-123 "enrichment complete"` (no marker present) | Write-block matched; marker scan finds no valid marker; deny with reason containing "review approval" |
| EC-004 | `jr issue edit` with any arguments (no marker present) | Deny with reason containing "review approval" |
| EC-005 | `jr issue move SEC-123 Enriched` (no marker) | Deny — `jr issue move` is in the write blocklist |
| EC-006 | `jr auth login` | Allow — `jr auth` is in the plain read-only allowlist (not write-block-matched, never enters marker branch) |
| EC-007 | `ls -la` (non-jr command) | Allow — fast path: no `jr ` substring |
| EC-008 | `jr issue assign SEC-123 @user` (no marker) | Deny — `jr issue assign` is in the write blocklist |
| EC-009 | `jr issue duplicate SEC-123` (unrecognized subcommand) | Deny with reason "Unrecognized jr subcommand. Add to the read-only allowlist..." (SEC-002 — fail-closed) |
| EC-010 | `jr issue changelog SEC-123` | Allow — explicitly added to the plain read-only allowlist in PR #14 (DI-010 fix; was Deny in v1.1) |
| EC-011 | `jr --output json issue changelog SEC-123` (metrics suite form) | Allow — `--output json issue changelog` is in the `--output json` family allowlist (PR #14) |
| EC-012 | `jr --output json issue view SEC-123` (metrics suite form) | Allow — `--output json issue view` is in the allowlist. Note: `jr issue view` (plain) does NOT match this form due to Invariant #4 |
| EC-013 | `jr --output json assets search objectType=Client` (CMDB query) | Allow — `--output json assets search` is in the allowlist (PR #14) |
| EC-014 | `jr --version` | Allow — explicitly in the allowlist (PR #14) |
| EC-015 | `jr --output json issue comment SEC-123 "msg"` | Deny via write-block if-block (PR #15 — `--output json issue comment ` with trailing space guard is an explicit write-block entry). |
| EC-016 | `jr issue edit KEY --summary "see jr board"` (write command with embedded allowlist token) | Deny via write-block if-block (PR #15 fix for ADV-0-801): `jr issue edit` matched in the write-block if-block BEFORE the allowlist is evaluated (Invariant #5). |
| EC-017 | `jr issue comment SEC-123 "msg"` with a marker present but `expires_at_utc` is in the past (marker expired; schema v2.0 TTL=120s) | Write-block matched; marker scan finds one candidate; TTL check `now() > expires_at_utc` fails; loop exhausted; deny with "review approval". Note: v1.12 described this as "age 45s > 30s" (v1.0 schema); updated to v2.0 absolute expiry check. |
| EC-018 | `jr issue comment SEC-456 "msg"` with a marker scoped to `authorized_operations: ["jr issue assign SEC-123"]` | Write-block matched; marker found; authorized_operations scope check fails (comment not in scope); deny. |
| EC-019 | `jr issue comment SEC-123 "msg"` after the marker has already been consumed (renamed to `.marker.json.used`) | The `.used`-renamed file is excluded from the `*.marker.json` glob — it never appears as a candidate. No valid marker found; deny. Note: the dead-code `used != false` check at the former step (3) has been removed (ADV-F2-018 — v1.13). The atomic rename IS the single-use enforcement mechanism. |
| EC-020 | `jr issue comment SEC-123 "msg"` with a marker file that is truncated/invalid JSON | Write-block matched; jq parse of candidate fails; skip (fail-closed); no valid marker found; deny. |
| EC-021 | Marker file with basename `../../evil.marker.json` in marker-store glob (path-traversal attempt) | Path-safety check: basename contains `..`; skip candidate (fail-closed); deny. |
| EC-022 | `jr issue comment SEC-456 "msg"` with a valid marker whose `command_pattern` is `^jr (--output json )?issue comment SEC-123 ` (different ticket-id; trailing space prevents SEC-1234 prefix match) | Write-block matched; anchored command_pattern `^jr (--output json )?issue comment SEC-123 ` does not match `jr issue comment SEC-456 "msg"`; skip; deny. This mechanically enforces ticket-bound scope: a marker scoped to SEC-123 cannot authorize any action on SEC-456 (D-DEC-008 ticket-bound generation table). |
| EC-023 | **Consumer anti-fungibility cross-check (ADV-F2-P6-001)** — two directions: (A) `jr issue create --project PRISM-DEMO --label REVIEW-REQUIRED --summary "..."` with a regular `["create"]` marker in the store (marker `authorized_operations: ["create"]`, no review label in the command_pattern). (B) `jr issue create --project PRISM-DEMO --summary "FP finding"` (no `--label` flag) with a `["create-review"]` marker in the store. | (A) Write-block matched; marker scan finds `["create"]` candidate; step (5) anchored match: the regular create pattern `^jr (--output json )?issue create --project PRISM-DEMO( \|$)` **PASSES** — bash `[[ =~ ]]` is NOT tail-anchored; the `( \|$)` matches the space after `PRISM-DEMO` and additional args (`--label REVIEW-REQUIRED --summary "..."`) are permitted by the non-anchored tail. The `( \|$)` boundary guards ONLY project-KEY prefix extension (PRISM-DEMO ≠ PRISM-DEMO-EXTRA), not the presence of subsequent flags. Step 5 passes. **Step (6a) is the SOLE enforcement point for direction A:** `structural_label_check(command)=true` (standalone `--label REVIEW-REQUIRED` token pair found by quote-aware tokenizer), `authorized_operations==["create"]` → CONTINUE (anti-fungibility). No valid marker consumed; deny. (B) Write-block matched; marker scan finds `["create-review"]` candidate; step (5) anchored match: the create-review pattern `^jr (--output json )?issue create --project PRISM-DEMO --label (REVIEW-REQUIRED\|BLIND-SPOT)( \|$)` does NOT match `jr issue create --project PRISM-DEMO` (no `--label` clause in the command). Step 5 fails (structural defense-in-depth). If step 5 passes: step (6a) fires — `structural_label_check(command)=false`, `authorized_operations==["create-review"]` → CONTINUE. No valid marker consumed; deny. **Summary:** Direction A enforcement is step 6a ONLY (step 5 PASSES); direction B enforcement is step 5 (structural pattern mismatch) with step 6a as defense-in-depth. |
| EC-024 | **False-deny prevention (ADV-F2-P7-005 / P8-002)** — `jr issue create --project PRISM-DEMO --summary "rule matched literal --label REVIEW-REQUIRED in alert payload"` with a valid `["create"]` regular marker (`command_pattern: "^jr (--output json )?issue create --project PRISM-DEMO( \|$)"`, `ticket_id: null`). The string `--label REVIEW-REQUIRED` appears only inside the double-quoted `--summary` argument value, NOT as a standalone `--label` flag token. | Write-block matched; step (5) anchored match: regular create pattern `^jr (--output json )?issue create --project PRISM-DEMO( \|$)` PASSES (the `( \|$)` matches the space after PRISM-DEMO; `--summary ...` follows but the pattern is not tail-anchored). Step (6): `structural_label_check(command)` invoked with the **raw command string** (the hook receives the full string including literal quote characters via `jq -r '.tool_input.command'` — no shell expansion has occurred). The v2 tokenizer (P9-001) enters IN_DOUBLE at the `"` before "rule"; all characters through the closing `"` accumulate into the `--summary` token body. Token sequence: `[jr, issue, create, --project, PRISM-DEMO, --summary, rule matched literal --label REVIEW-REQUIRED in alert payload]`. `--label` is NOT a standalone token — it is content within the `--summary` token body. `has_review_label=false`; `authorized_operations==["create"]`; step (6a) does NOT block; marker consumed; `permissionDecision: allow`. **Old behavior (v1.18 substring check):** `"--label REVIEW-REQUIRED" in command` returned `true` → false-deny. **Old behavior (v1.19 naive split_on_whitespace):** tokenizer would have produced `["jr", "issue", "create", "--project", "PRISM-DEMO", "--summary", "rule", "matched", "literal", "--label", "REVIEW-REQUIRED", "in", "alert", "payload"]` → `--label` at position 9, `REVIEW-REQUIRED` at position 10 → `has_review_label=true` → false-deny. P8-002 quote-aware tokenizer (extended by P9-001 v2) prevents this class of false-deny. |
| EC-025 | **Escaped-quote differential-vs-bash (ADV-F2-P9-001 MAJOR)** — v2 tokenizer backslash-escape: direction (A) real `--label` after escaped-quote-terminated summary; direction (B) escaped quote inside summary with no real label outside. (A) `jr issue create --project PRISM-DEMO --summary "normal\"" --label REVIEW-REQUIRED` with a regular `["create"]` marker. The `\"` ends the summary value with a literal `"` in the v2 tokenizer; subsequent `--label REVIEW-REQUIRED` appear as standalone tokens OUTSIDE the double-quoted region. (B) `jr issue create --project PRISM-DEMO --summary "normal\"fine"` (escaped quote inside summary, no real `--label` outside) with a valid `["create"]` marker. | (A) **DENY (SECURITY):** v2 tokenizer (P9-001): `\"` in IN_DOUBLE → literal `"` added to cur_token, STAY IN_DOUBLE; real closing `"` ends double-quote; `--label REVIEW-REQUIRED` are standalone tokens outside the summary → `has_review_label=TRUE`; step (6a): `authorized_operations==["create"]` AND `has_review_label=TRUE` → CONTINUE (anti-fungibility); no valid marker consumed; `permissionDecision: deny`. **Buggy P8-002 tokenizer:** exits IN_DOUBLE at `\"` → `--label REVIEW-REQUIRED` swallowed into a second double-quote region → `has_review_label=FALSE` → false ALLOW (security bypass; P9-001 MAJOR fix). (B) **ALLOW:** v2 tokenizer: `\"` in IN_DOUBLE → literal `"` to cur_token, STAY IN_DOUBLE; real closing `"` ends double-quote; no standalone `--label` token outside the summary → `has_review_label=FALSE`; `["create"]` marker accepted; `permissionDecision: allow`. Escaped quote inside a summary with no real label is correctly handled as ALLOW (false-deny prevention). |

## Canonical Test Vectors

| Input (`tool_input.command`) | Expected Output | Category |
|------------------------------|----------------|----------|
| `ls -la` | `permissionDecision: allow` | happy-path |
| `jr issue view SEC-123` | `permissionDecision: allow` | happy-path |
| `jr sprint list` | `permissionDecision: allow` | happy-path |
| `jr issue changelog SEC-123` | `permissionDecision: allow` | happy-path (was deny in v1.1) |
| `jr --output json issue view SEC-123` | `permissionDecision: allow` | happy-path (metrics suite / Invariant #4) |
| `jr issue comment SEC-123 "enrichment complete"` (no marker) | `permissionDecision: deny`, reason contains "review approval" | error |
| `jr issue comment SEC-123 "enrichment complete"` (valid marker present with matching command_pattern + authorized_operations) | `permissionDecision: allow`; marker consumed (renamed .used); audit log entry appended | happy-path (D-DEC-001 marker-gated allow) |
| `jr issue edit SEC-123 --priority Critical` | `permissionDecision: deny`, reason contains "review approval" | error |
| `jr issue move SEC-123 Enriched` | `permissionDecision: deny` | error |
| `jr issue duplicate SEC-123` | `permissionDecision: deny`, reason contains "allowlist" | edge-case (SEC-002 fail-closed) |
| `jr issue edit KEY --summary "see jr board"` | `permissionDecision: deny`, reason contains "review approval" (write-block wins before allowlist — ADV-0-801 bypass, now fixed) | edge-case (EC-016) |
| `jr --output json issue edit KEY --priority Critical` | `permissionDecision: deny`, reason contains "review approval" (--output json write-block family — ADV-0-801 PR #15) | edge-case (VP-HOOK-023) |
| `jr issue comment SEC-123 "msg"` with expired marker (`expires_at_utc` in the past) | `permissionDecision: deny`, reason "review approval" (EC-017) | edge-case |
| `jr issue comment SEC-456 "msg"` with marker whose `command_pattern` is `^jr (--output json )?issue comment SEC-123 ` | `permissionDecision: deny` (anchored command_pattern mismatch — EC-022; ticket-bound enforcement) | edge-case |
| `jr issue create --project SEC --summary "FP: Rule R-001 benign activity"` with a valid create-scoped marker (`authorized_operations: ["create"]`, `command_pattern: "^jr (--output json )?issue create "`, `ticket_id: null`) | `permissionDecision: allow`; marker consumed (renamed .used); audit log entry appended (VP-HOOK-024 create-path) | happy-path (create-scoped marker) |
| `jr issue assign SEC-456 @responder` with a valid assign-scoped marker (`authorized_operations: ["assign"]`, `command_pattern: "^jr (--output json )?issue assign SEC-456 "`) | `permissionDecision: allow`; marker consumed; audit log appended (VP-HOOK-024 assign-path) | happy-path (assign-scoped marker) |
| `jr issue create --project PRISM-DEMO --summary "alert payload contains --label REVIEW-REQUIRED text"` (no standalone `--label` flag; literal string inside double-quoted `--summary` value) with valid `["create"]` regular marker (`command_pattern: "^jr (--output json )?issue create --project PRISM-DEMO( \|$)"`) | `permissionDecision: allow`; marker consumed (renamed .used); audit log appended; `structural_label_check` (P8-002 quote-aware tokenizer) enters IN_DOUBLE state at `"` before "alert"; all chars including `--label REVIEW-REQUIRED` text accumulate into `--summary` token body; `--label` is NOT a standalone token; `has_review_label=false`; `["create"]` marker accepted; step (6a) does NOT block. **Old substring check (v1.18):** false-deny. **Old naive split_on_whitespace (v1.19):** also false-deny (splits quoted arg into individual tokens including `--label`). P8-002 quote-aware tokenizer fixes this class of false-deny (EC-024) | happy-path (EC-024, false-deny prevention — P8-002) |
| `jr issue create --project PRISM-DEMO --label REVIEW-REQUIRED --summary "[REVIEW-REQUIRED] SEC-789 HIGH severity — human approval needed"` with valid create-review-scoped marker (`authorized_operations: ["create-review"]`, `command_pattern: "^jr (--output json )?issue create --project PRISM-DEMO --label (REVIEW-REQUIRED\|BLIND-SPOT)( \|$)"`, `ticket_id: null`) | `permissionDecision: allow`; marker consumed (renamed .used); audit log entry appended; hard-floor finding surfaced to human review (VP-HOOK-029 create-review consumer path) | happy-path (create-review-scoped marker) |
| `jr issue create --project PRISM-DEMO --label BLIND-SPOT --summary "[BLIND-SPOT] sensor silent >24h"` with valid create-review-scoped marker (same pattern as above, `authorized_operations: ["create-review"]`) | `permissionDecision: allow`; marker consumed; audit log appended; BLIND-SPOT ticket creation proceeds under human review | happy-path (create-review BLIND-SPOT) |
| `jr issue create --project PRISM-DEMO --summary "FP: Rule R-001"` (no `--label`) with `["create-review"]` marker | `permissionDecision: deny` (EC-023: review marker requires review-labeled command — step 6a anti-fungibility); regular create command cannot steal a create-review marker | edge-case (EC-023, anti-fungibility direction A) |
| `jr issue create --project PRISM-DEMO --label REVIEW-REQUIRED --summary "..."` with `["create"]` regular marker only | `permissionDecision: deny` (EC-023: regular create marker cannot authorize a review-labeled command — step 6a anti-fungibility); kill-switch bypass attempt blocked | edge-case (EC-023, anti-fungibility direction B) |
| `jr issue create --project PRISM-DEMO --summary "normal\"" --label REVIEW-REQUIRED` with valid `["create"]` regular marker (`command_pattern: "^jr (--output json )?issue create --project PRISM-DEMO( \|$)"`, `ticket_id: null`) | `permissionDecision: deny` (EC-025 direction A — SECURITY); v2 tokenizer (P9-001): `\"` in IN_DOUBLE → literal `"` added to cur_token, STAY IN_DOUBLE; real closing `"` ends double-quote; `--label REVIEW-REQUIRED` exposed as standalone tokens → `has_review_label=TRUE`; step (6a): `authorized_operations==["create"]` AND `has_review_label=TRUE` → CONTINUE anti-fungibility gate; no valid marker type accepted; deny. Buggy P8-002 behavior: exits IN_DOUBLE at `\"` → swallows `--label REVIEW-REQUIRED` → false ALLOW (security bypass). | security / edge-case (EC-025 direction A — P9-001 backslash-escape MAJOR) |
| `jr issue create --project PRISM-DEMO --summary "normal\"fine"` (escaped quote inside summary, no real `--label` outside) with valid `["create"]` regular marker (`command_pattern: "^jr (--output json )?issue create --project PRISM-DEMO( \|$)"`, `ticket_id: null`) | `permissionDecision: allow`; marker consumed (renamed .used); audit log appended; v2 tokenizer (P9-001): `\"` in IN_DOUBLE → literal `"` to cur_token, STAY IN_DOUBLE; real closing `"` ends double-quote; token sequence `[jr, issue, create, --project, PRISM-DEMO, --summary, normal"fine]`; no standalone `--label` token → `has_review_label=FALSE`; `["create"]` marker accepted; step (6a) does NOT block. | happy-path / edge-case (EC-025 direction B — P9-001 false-deny prevention) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-001 | For all inputs where command contains `jr issue comment`, `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`, output always contains `"permissionDecision":"deny"` WHEN no valid marker exists | integration / BATS |
| VP-HOOK-002 | Hook exit code is always 0 when jq is present (both allow and deny paths) | integration / BATS |
| VP-HOOK-003 | Any unrecognized `jr` subcommand receives deny (fail-closed invariant, SEC-002) | integration / BATS (`@test "require-review blocks unknown mutation-shaped jr subcommand (SEC-002)"` hooks.bats:76) |
| VP-HOOK-020 | `jr issue changelog` plain form receives allow (DI-010 resolution) | integration / BATS (`@test "require-review allows jr issue changelog plain form"` hooks.bats:21) |
| VP-HOOK-021 | `jr --output json issue changelog` receives allow (metrics suite form, DI-010) | integration / BATS (`@test "require-review allows jr issue changelog json form (metrics suite)"` hooks.bats:27) |
| VP-HOOK-022 | `jr --output json issue view` receives allow — validates that the `--output json` family is covered separately from plain forms (Invariant #4) | integration / BATS (`@test "require-review allows jr --output json issue view (metrics suite)"` hooks.bats:33) |
| VP-HOOK-023 | A command containing `--output json issue comment/edit/move/assign/create` receives deny (write-block if-block — defense-in-depth for `--output json` write forms) | integration / BATS |
| VP-HOOK-024 | A write-block-matched command WITH a valid unexpired scoped marker receives allow; the marker file is renamed to `.used` (atomic single-use); an audit log entry is appended; a second attempt with the same (now consumed) marker receives deny (replay prevention — EC-019). **v1.5 extensions (verification-delta.md v1.5 §2):** (a) create `command_pattern` injection-safety — anchored `^jr (--output json )?issue create --project <key>( \|$)`; `--summary` injection + PROD/PRODUCTION prefix → DENY (ADV-F2-P4-002 CRITICAL; consumer step 5). (b) audit-forgery prevention — control chars (0x00-0x1f) stripped from `ticket_id`/`org_slug`/`authorized_operations[0]` before interpolation; `\n` in `ticket_id` cannot forge a second MARKER_USED line (ADV-F2-P4-010; consumer step 8). **v1.18 extension (ADV-F2-P6-001 anti-fungibility — step 6a):** (c) create-review marker requires review-labeled command (`--label REVIEW-REQUIRED` or `--label BLIND-SPOT` present as standalone flag token) — SM-36 kill target (review marker accepted for non-labeled create → killed by `@test "require-review denies create-review marker for non-labeled create (EC-023 SM-36)"`). (d) regular create marker cannot authorize a review-labeled command — SM-37 kill target (create marker accepted for review-labeled create → killed by `@test "require-review denies regular create marker for review-labeled create (EC-023 SM-37)"`). **v1.19 extension (ADV-F2-P7-005 structural token detection — step 6a):** (e) false-deny prevention — a regular create whose `--summary` contains the literal text `--label REVIEW-REQUIRED` (not a standalone flag token) is NOT mis-categorized as review-labeled; `structural_label_check` returns false; `["create"]` marker is accepted → ALLOW (EC-024). Kill target: a defective substring-check implementation that returns has_review_label=true for summary-embedded text → killed by `@test "require-review allows regular create with label-string-in-summary (EC-024 false-deny prevention)"`. Paired mutant: **SM-40** (revert `has_review_label` to the raw-substring check → the vector DENYs and the mutant dies). **v1.20 extension (ADV-F2-P8-002 quote-aware tokenizer — step 6a):** (f) `structural_label_check` uses a quote-aware state machine (UNQUOTED/IN_SINGLE/IN_DOUBLE) because the hook receives the raw command string including literal quote characters via `jq -r '.tool_input.command'` — a naive `split_on_whitespace` would still split the quoted `--summary` value into individual tokens, reproducing the EC-024 false-deny. Kill target: revert `structural_label_check` to a non-quote-aware `split_on_whitespace` implementation → EC-024 vector DENYs → separately killable mutant (SM-42). **v1.21 extension (ADV-F2-P9-001 backslash-escape — step 6a v2 tokenizer):** (g) escaped-quote differential-vs-bash partition (EC-025 direction A — SECURITY): `jr issue create --project PRISM-DEMO --summary "normal\"" --label REVIEW-REQUIRED` — v2 tokenizer treats `\"` in IN_DOUBLE as a literal `"` (STAY IN_DOUBLE); real closing `"` ends double-quote; `--label REVIEW-REQUIRED` exposed as standalone tokens → `has_review_label=TRUE` → DENY. Kill target: a defective tokenizer that exits IN_DOUBLE on `\"` (P8-002 behavior) → `--label REVIEW-REQUIRED` swallowed → false ALLOW → security bypass; SM-43. (h) escaped-quote false-deny prevention (EC-025 direction B — ALLOW): `jr issue create --project PRISM-DEMO --summary "normal\"fine"` — v2 tokenizer keeps `\"` inside IN_DOUBLE, no standalone `--label` outside → `has_review_label=FALSE` → `["create"]` marker accepted → ALLOW. **Note on equals-form (`--label=VALUE`):** `jr issue create --label=REVIEW-REQUIRED` is confirmed NOT supported by jr CLI (`jr issue create --help`, 2026-07-21); this form is SCOPED OUT — the monitoring loop never emits it and no tokenizer handling is required. | integration / BATS (`@test "require-review allows write with valid marker and consumes it"`, `@test "require-review denies replay of consumed marker"`, `@test "require-review create marker: --summary injection attempt → DENY"`, `@test "require-review create marker: PROD prefix does not match PRODUCTION"`, `@test "require-review audit: ticket_id with control char produces single MARKER_USED line"`, `@test "require-review denies create-review marker for non-labeled create (EC-023 SM-36)"`, `@test "require-review denies regular create marker for review-labeled create (EC-023 SM-37)"`, `@test "require-review allows regular create with label-string-in-summary (EC-024 false-deny prevention)"`, `@test "P9-001 escaped-quote-hiding-label: create + create marker + summary contains escaped-quote boundary + real --label REVIEW-REQUIRED after it → DENY"`, `@test "P9-001 escaped-quote-inside-summary: create + create marker + summary value contains \\\" but --label is genuinely inside double-quoted summary → ALLOW"`) |
| VP-HOOK-029 | **FINALIZED (verification-delta.md v1.6 §8.15 item 1)** Consumer leg of the fail-loud invariant (D-DEC-012): step (6) exact-type matching proves require-review CAN consume a review marker for a correctly-labeled hard-floor verdict. Paired with VP-HOOK-029 emit tests in BC-3.03.001 (Step 3 emitter) and BC-10.01.001 (Invariant #10). Kill target: SM-32 (review-surfacing-hard-floor-bypass-removed). **Note:** anti-fungibility vectors (EC-023 — step 6a, create-review/create cross-check) are attributed to VP-HOOK-024 (mutants SM-36/SM-37) per FV namespace. | integration / B-INT-XH (`@test "require-review accepts create-review token for jr issue create [REVIEW-REQUIRED]"`, `@test "require-review accepts create-review token for jr issue create [BLIND-SPOT]"`, `@test "require-review accepts comment-review token for jr issue comment [BLIND-SPOT]"`, `@test "require-review denies jr issue create with no review token (fail-loud negative)"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-01 |
| L2 Domain Invariants | Iron Law: NO JIRA UPDATE WITHOUT REVIEW APPROVAL FIRST |
| Architecture Module | C-12 (require-review-hook), C-29 (marker-store consumer) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/require-review.sh` (115 lines, post-PR #15) + `.ps1` sibling |
| **Confidence** | high — explicit allow/deny logic fully visible in source; BATS tests at `tests/hooks.bats:9-177` (26 require-review tests, including the 12 PR-15 bypass/--output json/regression tests, and the 2 PR-17 DI-005 assign/create tests at :426/:433) exercise all documented paths; 165 @tests total (hooks 59, skills 81, integration 11, parity 14); marker-validation branch (v1.11) specified by D-DEC-001 binding decision; BATS coverage for marker paths assigned VP-HOOK-024 (finalized per verification-delta §1) |
| **Extraction Date** | 2026-07-19 |
| **Last Verified Against** | commit d181ca2 (HEAD post PR #17) |

#### Change Log

**PR #13 (commit f450d9f, 2026-07-19) — two behavioral changes (v1.0 → v1.1):**

| Change | SEC ID | Old Behavior (v1.0) | New Behavior (v1.1) |
|--------|--------|---------------------|---------------------|
| `jr issue comment` routing | SEC-001 | Allow — comment was explicitly whitelisted | Deny — moved into the write-operations block; reason contains "review approval" |
| Unknown jr subcommand routing | SEC-002 | Allow — fail-open | Deny — fail-closed; reason instructs operator to add to read-only allowlist if safe |

**PR #14 (commit 0ec794a, 2026-07-19) — read-only allowlist expansion (v1.1 → v1.2):**

| Change | Driver | Old Behavior (v1.1) | New Behavior (v1.2) |
|--------|--------|---------------------|---------------------|
| `jr issue changelog` plain form | DI-010: metrics pipeline blocked | Deny (not on allowlist) | Allow (added to plain-form list) |
| `jr assets search`, `jr assets view` plain forms | CMDB queries for metrics | Deny | Allow |
| `jr --version` | Health-check / diagnostics | Deny | Allow |
| `--output json issue view/list/comments/changelog/assets` | DI-010: metrics suite uses global `--output json` flag | Deny (plain forms don't match) | Allow (separate family) |
| `--output json assets search/view` | CMDB queries via metrics suite | Deny | Allow |

**PR #15 (commit d304fa5, 2026-07-19) — CRITICAL evaluation-order fix (ADV-0-801) and `--output json` write-block addition (v1.6 → v1.7):**

| Change | Driver | Old Behavior (v1.2-v1.6) | New Behavior (v1.7) |
|--------|--------|--------------------------|---------------------|
| Write-block evaluated before allowlist | ADV-0-801 (CRITICAL bypass) | allowlist evaluated first — a command containing both a write-block token AND an allowlist token was incorrectly ALLOWED | write-block evaluated first — write-block wins unconditionally |
| `--output json` write forms added to write-block | ADV-0-801 defense-in-depth | `jr --output json issue edit/comment/move/assign/create` hit fail-closed only | `--output json issue comment/edit/move/assign/create` added as explicit write-block entries |

**PR #17 (commit d181ca2, 2026-07-19) — DI-005 assign/create BATS coverage (v1.9 → v1.10):**

| Change | Driver | Old Coverage | New Coverage |
|--------|--------|-------------|--------------|
| `jr issue assign` deny BATS test | DI-005: no dedicated BATS verify | Code analysis only | `@test "require-review blocks jr issue assign without review (DI-005)"` (hooks.bats:426) |
| `jr issue create` deny BATS test | DI-005: no dedicated BATS verify | Code analysis only | `@test "require-review blocks jr issue create without review (DI-005)"` (hooks.bats:433) |

**v1.11 (2026-07-20) — Marker-validation conditional-allow branch (D-DEC-001/D-DEC-008):**

| Change | Driver | Old Behavior (v1.10) | New Behavior (v1.11) |
|--------|--------|---------------------|---------------------|
| Write-block-matched deny path | D-DEC-001 marker mechanism | Unconditional deny for all write-block-matched commands | Deny UNLESS valid unexpired scoped marker found; marker consumed atomically before allow; audit log appended |
| Hard-floor guarantee | D-DEC-008 (enforced at emitter) | Not applicable (all write-block → deny) | Hard-floor categories never receive a marker from disposition-guard; require-review finds no valid marker → unconditional deny |
| Filesystem access | D-DEC-001 | None (pure stdin→stdout) | Reads marker-store for write-block commands only; one atomic mv-rename; one audit log append |

#### Evidence Types Used

- **guard clause**: fast-path allow for non-`jr ` commands (fast-path guard in require-review.sh)
- **guard clause**: write-block evaluated FIRST — 10-entry write-block if-block (5 plain + 5 `--output json`) → `validate_marker()` → emit_allow (if valid marker) or `emit_deny` with "review approval" (if no valid marker or any error)
- **guard clause**: marker-validation path — collect candidates (path-safety, parse, future-date, TTL, command_pattern, authorized_operations), sort by issued_at_utc ASC, iterative-consume (atomic mv-rename per candidate; rename-fail → continue to next), audit log append to `${CLAUDE_PLUGIN_DATA}/markers/audit.log` — all fail-closed
- **guard clause**: allowlist evaluated SECOND — 21-entry explicit read-only allowlist (14 plain + 7 `--output json`), all `emit_allow` (read-only allowlist in require-review.sh)
- **guard clause**: fail-closed catch-all `emit_deny` for unrecognized subcommands (fail-closed catch-all in require-review.sh)
- **type constraint**: JSON envelope structure enforced by `jq -nc` output template
- **assertion**: `command -v jq` check — exits 1 if dependency missing (jq-availability guard in require-review.sh)
- **documentation**: D-DEC-001 marker JSON schema; D-DEC-008 hard-floor pseudocode; architecture-delta.md v1.1

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin once; writes stdout (JSON envelope); FOR WRITE-BLOCK COMMANDS ONLY: reads marker-store directory glob, performs one atomic mv-rename, appends one audit log line |
| **Global state access** | marker-store directory `${CLAUDE_PLUGIN_DATA}/markers/` (read + atomic mv for write-block-matched commands only) |
| **Deterministic** | yes for non-write-block commands (same input always produces same output); for write-block commands: deterministic given marker-store state |
| **Thread safety** | atomic POSIX mv-rename for marker consumption provides single-use guarantee (no TOCTOU race) |
| **Overall classification** | pure core for non-write-block commands; effectful shell (marker-store read + mv + audit log append) for write-block-matched commands |

#### Refactoring Notes

The hook is pure for non-write-block commands. The marker-validation branch introduces filesystem side-effects but these are bounded to write-block-matched commands only.

The `--output json` global-flag design means the allowlist cannot be expressed as a simple set of subcommand names — it must carry separate entries for plain forms and each global-flag variant.

**Security extensibility note:** The marker-validation conditional-allow branch is the only exception to the unconditional write-block deny. The hard-floor guarantee (D-DEC-008) ensures that high-stakes dispositions (Indeterminate, HIGH/CRIT, critical assets, credential-exfil techniques) never receive markers, making the allow path unreachable for those commands even when the marker mechanism is active.

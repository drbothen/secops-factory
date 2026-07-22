---
document_type: adversarial-review
pass: 9
producer: adversary
date: 2026-07-21
cycle: v0.10.0-feature-prism-integration
scope: F2 spec-evolution delta package
---

# Adversarial Spec-Delta Review — Pass 9

## Summary Table

| ID | Title | Severity | Confidence | Primary Anchor |
|----|-------|----------|-----------|----------------|
| P9-001 | `structural_label_check` tokenizer ignores backslash-escaped quotes and `--label=` form → defeats EC-023 direction A (sole anti-fungibility gate) | MAJOR | HIGH | BC-3.01.001 §consumer STEP 6a; architecture-delta §D-DEC-001 tokenizer |
| P9-002 | asm-004-validation.md recommends `--dangerously-skip-permissions` and `--bare` (hook-disabling) with no supersession banner — contradicts D-DEC-003/010 security posture | MAJOR | HIGH | asm-004-validation.md "Recommended packaging" + "Alternative: --bare" |
| P9-003 | prd-delta counts BC-10.01.001 as both "new" (§1) and "modified" (§5); "11 BC files touched" double-counts (10 distinct) | MINOR | HIGH | prd-delta §1, §5, §8 |
| P9-004 | verification-delta VP-total split mislabeled (8 hook / 23 skill vs actual 6 / 25); 052–063 "FINALIZED" vs "ACCEPTED" | MINOR | HIGH | verification-delta §2 Totals (lines 477–486) |
| P9-005 | D-DEC-005 absolute "never without org_slug" contradicted by sensor-metrics cross-org health design; BC-8.02.001 Inv#2 conditional, no carve-out | MINOR | MEDIUM | architecture-delta §D-DEC-005 vs BC-8.02.001 Inv#2 |
| P9-006 | dtu-assessment omits CRITICAL marker-store (C-29) from "all-categories" inventory and omits ASM-009 cross-hook test from Blocking Gaps | MINOR | HIGH | dtu-assessment Persistence & State / Blocking Gaps |
| P9-007 | P8-001 comment-review fallback hint can induce duplicate review tickets / oscillation when ticket exists but ticket_id null | MINOR | MEDIUM | architecture-delta §D-DEC-008 STEP 3 comment-review branch |
| P9-008 | STEP-3 HARD-FLOOR-UNBINDABLE deny has no re-doc retry bound; misconfigured jira_project_key → audit-only surface + LLM livelock | OBSERVATION | MEDIUM | architecture-delta §D-DEC-008 STEP 3 |
| P9-009 | No VP covers tokenizer robustness vs escaped/equals-form/other shell-quoting; SM-40/SM-42 only cover substring & whitespace reverts | OBSERVATION `[process-gap]` | HIGH | verification-delta §2 VP-HOOK-024 vector set |

No CRITICAL findings this pass. Two MAJOR.

---

## MAJOR Findings

### P9-001 — `structural_label_check` tokenizer does not handle escaped quotes or `--label=VALUE`, defeating the sole anti-fungibility control (EC-023 direction A)

**Severity:** MAJOR **Confidence:** HIGH
**Anchor:** BC-3.01.001 (v1.20) consumer STEP 6a `structural_label_check` pseudocode (body lines 135–172); mirror in architecture-delta §D-DEC-001 (lines 242–285).

**Description.** P8-002 replaced `split_on_whitespace` with a UNQUOTED/IN_SINGLE/IN_DOUBLE state machine so that a `--label REVIEW-REQUIRED` literal *inside* a quoted `--summary` value is treated as one token (has_review_label=false → ALLOW). P8-003 then removed the step-5 backstop, declaring: "step 6a is the SOLE enforcement point for [EC-023 direction A]... its correctness is load-bearing" and "no step-5 redundancy remains." The tokenizer, however, toggles state on **every** `"`/`'` regardless of a preceding backslash and only recognizes the space-separated `--label VALUE` form. It therefore diverges from bash argument parsing in two input classes that the mandate explicitly targets (escaped quotes; empty/equals-form values), and **no test vector exercises either**.

**Failure scenario (escaped quote — desync hides a real label).** Command (Iron-Law compliant, `--project` first):
`jr issue create --project PRISM-DEMO --summary "a\"b" --label REVIEW-REQUIRED`
- Bash/jr parse: args `[--summary, a"b, --label, REVIEW-REQUIRED]` → jr applies a **functional REVIEW-REQUIRED label**.
- Tokenizer trace: the `\` is added as a literal char inside IN_DOUBLE; the following `"` **closes** the quote; the next `"` **re-opens** it, so `--label REVIEW-REQUIRED` is swallowed into the `--summary` token body → `has_review_label = false`.
- A regular `["create"]` marker passes step 5 (`^jr ...create --project PRISM-DEMO( |$)` matches the prefix per P8-003) and step 6a (has_review_label=false → not refused) → **ALLOW**.

Result: a regular autonomous-triage marker authorizes a command that creates a REVIEW-REQUIRED-labeled ticket — exactly the fungibility EC-023 direction A exists to prevent. The `--label=REVIEW-REQUIRED` equals form (if jr honors it) evades detection identically (`--label=REVIEW-REQUIRED` is one token, `tokens[i]=="--label"` is false).

**Impact.** Breaks the auditability property D-DEC-012 Alternatives-Rejected declares load-bearing ("the audit trail loses the distinction between autonomous triage ticket and human-escalation ticket"). Because P8-003 deliberately removed the step-5 backstop, there is **no compensating control**. The dangerous reverse direction (review marker → unlabeled regular create) remains blocked by the create-review command_pattern at step 5, which is why this is MAJOR, not CRITICAL. Exploitation requires the loop's `jr issue create` string to contain an escaped-quote summary plus a real label — an LLM-influenced but non-trivial path.

**Remediation.** Extend the tokenizer to (a) treat `\"`/`\'` as literal characters that do NOT toggle state (honor backslash-escaping as bash does), and (b) recognize the `--label=REVIEW-REQUIRED`/`--label=BLIND-SPOT` equals form as a review label. Add FV vectors for both under VP-HOOK-024 with a paired mutant, since these are now the sole guard for EC-023 direction A.

---

### P9-002 — asm-004-validation.md actively recommends hook-disabling / permission-bypass invocations forbidden by D-DEC-003/D-DEC-010, with no supersession banner

**Severity:** MAJOR **Confidence:** HIGH
**Anchor:** asm-004-validation.md "Recommended packaging for D-DEC-003" (lines 222–239) and "Alternative: `--bare --mcp-config`" (lines 241–255). Contradicts architecture-delta §D-DEC-003 ("`--bare` is explicitly forbidden") and §D-DEC-010 (uses `--allowedTools`, explicitly rejects `--dangerously-skip-permissions`).

**Description.** The in-scope ASM-004 validation report presents two recommendations that the architecture later rejects as security regressions:
- Its **"Recommended packaging"** cron command uses `--dangerously-skip-permissions`. D-DEC-010 Alternatives-Rejected: "`--dangerously-skip-permissions` (blanket bypass): Rejected."
- Its **"Alternative: `--bare --mcp-config`"** explicitly frames the hook-disabling behavior as a benefit: "`--bare` skips hooks... eliminates hook interference during the patrol loop." D-DEC-003 and D-DEC-010 both state `--bare` disables the require-review hook — "the sole hard gate on Jira writes... a critical security regression."

The validation doc carries **no supersession note** pointing to D-DEC-010's rejection. It is a cited input to architecture-delta and to BC-6.01.001/BC-10.01.001. A story-writer or implementer consulting it for the canonical invocation would reintroduce the exact regression the entire marker mechanism exists to prevent — "eliminates hook interference" is the anti-pattern, stated as a feature.

**Failure scenario.** Wave-7 implementer copies asm-004-validation.md's "Recommended packaging" block (or the `--bare` alternative for "reduced startup time") into `run-monitoring-loop.sh`. require-review never fires; every autonomous `jr issue comment/create/assign` executes ungated. The BATS `--bare`-absent assertion (D-DEC-003) is the only thing standing between this and production, and it only fires if the implementer wrote the wrapper per the architecture rather than per the validation doc.

**Remediation.** Add a prominent banner at the top of asm-004-validation.md "Recommended packaging" and "Alternative" sections: both `--dangerously-skip-permissions` and `--bare` were REJECTED by D-DEC-010/D-DEC-003; the authoritative invocation is `--strict-mcp-config --mcp-config ~/.claude/prism.mcp.json --allowedTools "..."` with NO `--bare` and NO `--dangerously-skip-permissions`. Strike or explicitly caveat the "eliminates hook interference" framing.

---

## MINOR Findings

### P9-003 — BC-10.01.001 double-listed as new and modified; "11 BC files touched" is inflated

**Severity:** MINOR **Confidence:** HIGH
**Anchor:** prd-delta §1 ("Five new Behavioral Contracts" — includes BC-10.01.001), §5 ("Six existing BCs modified" — includes BC-10.01.001 v1.1→v1.13), §8 grand total ("11 BC files touched").

**Description.** BC-10.01.001 appears in the "new BCs" table (§1) and the "modified existing BCs" table (§5) with an old version of v1.1. The union of §1 (5 files) and §5 (6 files) is **10 distinct BC files**, but §8 asserts "11 BC files touched," double-counting BC-10.01.001. Either BC-10.01.001 is a new BC (remove from §5) or a modified one (remove from §1); it cannot be both in a per-file touch count.

**Remediation.** Reconcile: state BC-10.01.001 was authored in sub-burst 1 and further modified in sub-burst 2, and correct the grand total to 10 distinct files (or explicitly define "touched" as new-authorings + modifications, noting the overlap).

### P9-004 — verification-delta VP-total split mislabeled (8/23 vs actual 6/25); lifecycle-label drift 052–063

**Severity:** MINOR **Confidence:** HIGH
**Anchor:** verification-delta §2 Totals, lines 477–486.

**Description.** The strategy-mix narrative claims "**8 hook properties** (VP-HOOK-024/025/026/027/028/029 ...)" — but the parenthetical lists only **6** hook VPs, and the table contains exactly 6 (024–029). It then claims "**23 skill properties**," but the table contains **25** VP-SKILL entries (050,051,052–063,064–074). The grand total 31 is correct (6+25=31); the labeled split (8+23) is internally wrong. Separately, the Totals line calls "052–063" **FINALIZED**, while the §1 namespace table (lines 282–285) marks VP-SKILL-052–059 as **ACCEPTED**. Per the VP-count self-consistency axis, arithmetic/label divergence in the VP accounting is a reportable inconsistency even when the roster itself is sound.

**Remediation.** Correct to "6 hook properties / 25 skill properties"; reconcile the ACCEPTED-vs-FINALIZED label for VP-SKILL-052–059 between §1 and the §2 Totals.

### P9-005 — D-DEC-005 absolute org_slug invariant vs sensor-metrics cross-org health design (BC-8.02.001) unreconciled

**Severity:** MINOR **Confidence:** MEDIUM
**Anchor:** architecture-delta §D-DEC-005 ("The plugin MUST NEVER construct a PrismQL query without this [org_slug] constraint"); BC-8.02.001 Invariant #2 ("**If** the prism MCP tool supports org_slug filtering... the query must include it").

**Description.** D-DEC-005 (echoed as an absolute Iron Law by VP-SKILL-059/064/069/070 for scan-threats/monitoring-loop/investigate-event/assess-priority) forbids any unscoped PrismQL query. sensor-metrics (BC-8.02.001) is designed to present health telemetry **across all orgs** (`SELECT * FROM prism_sensor_health`, brief §2.4), and its Inv#2 weakens the rule to a conditional. Either sensor-metrics violates the absolute D-DEC-005, or there is an implicit carve-out for cross-org **health-metadata** (distinct from raw per-tenant records under brief §3.6). The architecture-delta records no such carve-out, and sensor-metrics is the one prism-consuming skill absent from the org_slug VP set.

**Remediation.** Add an explicit carve-out to D-DEC-005 (and BC-8.02.001) that `prism_sensor_health` metadata queries are exempt from the raw-data isolation rule, or require sensor-metrics to iterate per-org with org_slug scope like the loop's Stage 0.

### P9-006 — dtu-assessment omits the CRITICAL marker-store (C-29) from its mandatory inventory and omits ASM-009 from Blocking Gaps

**Severity:** MINOR **Confidence:** HIGH
**Anchor:** dtu-assessment "Integration Surface Inventory (MANDATORY — all categories)" → Persistence & State ("None identified... All state is local filesystem (watermarks, prism config dir)"); Blocking Gaps table (lists ASM-004, prism-demo-bundle, prism.toml isolation; not ASM-009).

**Description.** The most security-critical new component is C-29 marker-store (architecture-delta §2.1, CRITICAL tier). It is a new persistence surface and the substrate for the cross-hook authorization flow. The DTU assessment's Persistence & State category declares "None identified" and names only watermarks; the marker-store appears nowhere in the document. Its Blocking Gaps table also omits the ASM-009 cross-hook marker-visibility test that architecture-delta §4.2 elevates to "**UNVALIDATED — BLOCKING pre-Wave-3**" with a mandatory go/no-go BATS test. Coverage does exist elsewhere (verification-delta B-INT-XH vectors, PO-Q5), so this is an inventory-completeness gap rather than a verification hole — but a doc claiming "all categories" that silently drops the single CRITICAL persistence surface understates test-infra risk for F3 sizing.

**Remediation.** Add a Persistence & State row for the marker-store (C-29) ruling out an external clone but naming the ASM-009 cross-hook temp-dir test-infra obligation, and add ASM-009 to the Blocking Gaps table cross-referencing architecture-delta §4.2.

### P9-007 — P8-001 comment-review fallback hint can induce duplicate review tickets / oscillation

**Severity:** MINOR **Confidence:** MEDIUM
**Anchor:** architecture-delta §D-DEC-008 STEP 3 comment-review branch (lines 1287–1301); D-DEC-004 (one open BLIND-SPOT ticket per (org,sensor)).

**Description.** When a hard-floor verdict arrives as `comment-review` with `ticket_id=null` but `jira_project_key` present, STEP 3 denies with a fallback hint: "if no review ticket exists yet, re-issue with ticket_action_type=create-review." This assumes the null ticket_id means *no ticket exists*. But if an open review ticket **does** exist and ticket_id was null due to a dedup-lookup miss, following the hint produces a **duplicate** review ticket via create-review — the exact Jira spam D-DEC-004's one-open-ticket dedup exists to prevent. If instead the loop keeps re-classifying as comment-review (dedup finds the ticket but still can't populate ticket_id), it oscillates against the deny.

**Remediation.** Make the fallback hint conditional on a dedup result, or require the loop to re-run the §3.4 dedup query before honoring the create-review fallback; note in BC-10.01.001 that create-review re-doc must re-check BLIND-SPOT/REVIEW-REQUIRED dedup to preserve D-DEC-004.

---

## Observations

### P9-008 — STEP-3 unbindable-deny has no re-doc retry bound; misconfigured jira_project_key degrades to audit-only surface + potential livelock
**Confidence:** MEDIUM. Anchor: architecture-delta §D-DEC-008 STEP 3, D-DEC-012 clause 2. The HARD-FLOOR-UNBINDABLE path is "bounded" only per-attempt ("one deny + one audit entry per re-doc"). There is no deterministic max-attempts. If `jira_project_key` is structurally unavailable (activate never stored the demo project key), every hard-floor verdict denies loudly to `markers/audit.log` but **never surfaces a Jira [REVIEW-REQUIRED]/[BLIND-SPOT] ticket** — the consumer-observable surface the brief §3.7 mandates degrades to a local audit file a SOC may never read, and the LLM may re-document until turn/budget exhaustion. Fail-loud (audit) holds; fail-*visible* (Jira) does not. Consider: activate/onboard must make jira_project_key a hard precondition (Stage 0 gate), and specify a re-doc attempt cap after which the loop emits a single operator-facing failure.

### P9-009 `[process-gap]` — VP vector set for the sole anti-fungibility control is incomplete for shell-quoting robustness
**Confidence:** HIGH. Anchor: verification-delta §2 VP-HOOK-024. P8-003 declares step-6a the "SOLE enforcement point" for EC-023 direction A and "P0-adjacent/non-redundant." Yet the mutant family (SM-40 raw-substring revert; SM-42 whitespace-split revert) and the single quoted-form vector only exercise the two historical implementations — they do not test escaped quotes, `--label=` form, or other constructs where the tokenizer diverges from bash (see P9-001). A P0-adjacent security control with a documented single point of failure should have an adversarial vector partition covering all shell-quoting classes jr honors. Recommend an FV standing rule: any hook that re-implements shell tokenization to make a security decision must carry a differential-vs-bash vector partition.

---

## Semantic Anchoring Audit

Sampled anchors resolve correctly: BC-8.02.001 (subsystem `metrics-pipeline`, `CAP-METRICS-02`) and BC-9.01.001 (`threat-hunting`, `CAP-THREATHUNTING-01`) H1 titles match postconditions and capability descriptions; VP-SKILL-069→BC-5.01.001 Inv#8, VP-SKILL-070/071→BC-4.05.001 Inv#4/PC#6, VP-SKILL-072→BC-10.01.001 Inv#13 all resolve to invariants confirmed present in the BC bodies. C-25..C-30 component IDs and DAG edges are internally consistent. No mis-anchoring found this pass. (Note: the BC-8.02.001 "Operational Notes" cross-reference to a NORMALIZE_SEVERITY table is tenuously anchored — sensor-metrics performs no severity normalization or escalation — but is informational and not a mis-anchor.)

## Partial-Fix Regression Discipline (prior-pass propagation)

Verified the newest (pass-7/8) fixes propagated into BC bodies, not just frontmatter:
- BC-3.03.001 v1.17 body carries the STEP-3 HARD-FLOOR-UNBINDABLE deny (both create-review/null-project_key and comment-review/null-ticket_id branches) and STEP-4 UNDER-LABEL-DENIED audit — CONFIRMED present.
- BC-3.01.001 v1.20 body carries the quote-aware `structural_label_check` state machine (UNQUOTED/IN_SINGLE/IN_DOUBLE) — CONFIRMED present (and is the artifact P9-001/P9-009 concern the tokenizer's residual gap).
No frontmatter-only fixes detected. Propagation between the emitter/consumer BCs and the architecture-delta pseudocode is in sync for the P8 changes.

## Novelty Assessment

**Novelty: MODERATE.** All nine findings target surfaces outside the eight independently-verified-intact invariants. P9-001 and P9-009 are genuinely new (the escaped-quote/equals-form tokenizer gap in a control the docs just declared the single point of failure — a fresh-context reading of the actual state machine, not a retread of prior "structural check" passes). P9-002 (stale/dangerous asm-004 recommendations) and P9-006 (marker-store absent from DTU inventory) are cross-document coherence gaps that index/BC-focused passes would not surface. P9-003/P9-004 are new bookkeeping-consistency findings. P9-005 and P9-007 are new logic/edge-case findings. None restate the marker-schema/dispatch/hard-floor/ordering invariants that prior passes hardened. This is not a nitpick pass — P9-001 and P9-002 are substantive. Convergence is NOT yet demonstrable: two MAJOR findings remain, and the tokenizer gap (P9-001) touches a control the package itself flags as load-bearing with no backstop.

## Confirmed Invariants (carried forward + additions)

Carried forward (independently verified intact; spot-checks this pass consistent):
1. Marker schema v2.1 authoritative block in sync (BC-3.03.001 / emitter WRITE_MARKER / D-DEC-001).
2. JSON-first dispatch precedes investigation-substring branch; verdict-*.json → 15-field class.
3. Hard floors key on severity/asset_type (not confidence); asset_type=unknown separate explicit floor.
4. STEP 4 (deny-the-Write under-label) precedes STEP 5 (kill switch); autonomy_enabled irrelevant to STEPs 3–4.
5. BC-10.01.001 EC-015/016/017/021 + canonical vectors on review-marker semantics with negative assertion.
6. Consumer iterative-consume ordering, audit path, base64 + control-char stripping intact.
7. Sensor-silence direction (last_seen_ts < now()-24h) consistent (BC-8.02.001 EC-004 "last_seen >24h" age-form is equivalent).
8. VP/SM namespace collision-free (VP-SKILL 001–074, VP-HOOK 024–029, SM-9..SM-42).

Additions confirmed this pass:
9. P8-001 HARD-FLOOR-UNBINDABLE deny (both missing-binding branches) present in BC-3.03.001 v1.17 body — propagated, not frontmatter-only.
10. P8-002 quote-aware tokenizer present in BC-3.01.001 v1.20 body and matches architecture-delta §D-DEC-001 verbatim — BUT handles only bare single/double quotes (no backslash-escape, no `--label=` form) — see P9-001.
11. VP roster sums to 31 correctly (6 VP-HOOK + 25 VP-SKILL); the §2 "8/23" split label is a narrative miscount (P9-004), not a roster error.
12. Dangerous fungibility direction (review marker → unlabeled regular create) is blocked at step 5 by the create-review command_pattern independent of step 6a — this is why P9-001 is MAJOR, not CRITICAL.

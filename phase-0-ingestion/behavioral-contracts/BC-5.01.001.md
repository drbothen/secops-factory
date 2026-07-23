---
document_type: behavioral-contract
level: L3
version: "1.11"
status: draft
producer: product-owner
timestamp: 2026-07-20T00:00:00
phase: f2
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/investigate-event/SKILL.md, plugins/secops-factory/tests/skills.bats, phase-f2-spec-evolution/architecture-delta.md]
input-hash: "COMPUTE-AT-COMMIT"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/investigate-event/SKILL.md
subsystem: event-investigation-pipeline
capability: CAP-EVENT-01
lifecycle_status: active
introduced: v0.6.0
modified: ["v1.1-ADV-0-501-2026-07-19", "v1.2-ADV-0-601-2026-07-19", "v1.3-ADV-0-702-ADV-0-706-2026-07-19", "v1.4-ADV-0-901-2026-07-19", "v1.5-PRISM-EVIDENCE-2026-07-20", "v1.6-ADV-F2-P3-004-2026-07-20", "v1.7-FV-VP-069-FINALIZED-JOB2-XREF-2026-07-20", "v1.8-version-coherence-sweep-2026-07-21", "v1.9-ADV-F2-P11-004-12field-hard-floor-reconcile-2026-07-22 [ID-sync per FV]", "v1.10-ADV-F2-P15-001-P15-005-markdown-path-no-comment-marker-2026-07-22", "v1.11-ADV-F2-P16-001-gate1-first-human-path-2026-07-22"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-5.01.001: investigate-event Skill — 7-Stage Event Investigation Workflow with Prism Evidence Collection

> **Revision history:**
> - v1.11 (2026-07-22): Pass-16 adversarial remediation — P16-001 (MAJOR, burst-11 regression: post-P13-001 routing description omitted Gate 1). **Invariant #7 rewritten (gate-1-first human-path model):** the investigate-event skill writes investigation-*.md ONLY as a human analyst (Stage 7 template generation; analyst never injects `autonomy_enabled: true`), so GATE 1 fires for every real invocation — `autonomy_enabled` absent → emit allow-without-marker for ALL dispositions; the investigation Write always succeeds; NO Jira action marker of any kind is issued; `jr issue comment` falls to human permission-approval. **MUST NOT be denied clause extended** to cover ALL dispositions including Indeterminate, forbidden-technique, and degraded-sensor saves on the human path (Gate 1 fires before any floor check for human saves). The Gate-2/3 routing (FP→allow-without-marker / non-FP/PARSE_FAIL→MARKDOWN_REVIEW_PATH review marker / hard-floor→MARKDOWN-HARD-FLOOR deny) applies ONLY when `autonomy_enabled` is exactly `true` (P12-002 masquerade case) — which this human-driven skill does not produce. Removed the incorrect "review marker for non-FP" claim and the implication that Indeterminate/forbidden-technique/degraded-sensor human saves are denied. DI-013-RESOLVED footer reconciled. Cites BC-3.03.001 v1.23 Gate 1. ADV-F2-P16-001.
> - v1.10 (2026-07-22): Pass-15 adversarial remediation — P15-001 (MAJOR, post-P13-001 propagation: markdown path no longer issues comment marker) + P15-005 (MINOR, VP-HOOK-031 citation v1.14→v1.18). **Invariant #7 rewritten (post-P13-001 model):** The Separate Human-Comment Marker Path (BC-3.03.001 v1.23 Invariant #4) no longer issues a comment-scoped marker for any disposition (MARKDOWN_COMMENT_PATH ELIMINATED per P13-001). Routing: (a) FP → allow-without-marker (the investigation Write succeeds — MUST NOT be denied — but `jr issue comment` NOT auto-authorized; falls to human permission-approval); (b) non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH (create-review/comment-review review marker); (c) hard-floor conditions → MARKDOWN-HARD-FLOOR deny. Removed the assertion that "disposition-guard writes a comment-scoped marker … consumes this marker to allow jr issue comment" for the markdown path. Reconciled the "MUST NOT be denied" sentence: the investigation-markdown Write MUST NOT be denied (analyst can always save a compliant investigation); but the subsequent `jr issue comment` is NOT auto-authorized and falls to human approval for FP; non-FP surfaces via a review marker. **DI-013-RESOLVED footer:** added "reconciled v1.10 / P13-001" note. **P15-005:** VP-HOOK-031 citation updated from verification-delta.md v1.14 → v1.18. ADV-F2-P15-001, P15-005.
> - v1.9 (2026-07-22): Pass-11 adversarial remediation — P11-004 (MAJOR, investigation-markdown hard-floor reconciliation). **Invariant #7 hard-floor condition list corrected:** removed "HIGH/CRIT severity, critical assets" from the hard-floor conditions for the 12-field investigation-markdown comment-marker path. Those conditions reference verdict-only fields (scored_priority/asset_type) that are absent from a 12-field investigation markdown file; they are not evaluable on this path. The correct markdown-evaluable set is: Indeterminate disposition, forbidden techniques {T1003,T1068,T1021,T1041}, degraded/silent sensor. Verdict-only floors apply only to the verdict-class path (BC-3.03.001 v1.19 PC#1). Added reference to "Separate Human-Comment Marker Path" in BC-3.03.001 v1.19 Invariant #4 as the authoritative specification. ADV-F2-P11-004.
> - v1.8 (2026-07-21): Version-coherence sweep only — zero semantic change. Updated live-body version cross-references to frozen cycle versions: BC-3.03.001 v1.11 → v1.13 (Invariant #7/PC#7 confidence); BC-3.01.001 v1.15 → v1.17 (Invariant #7/PC#7 confidence). Per IP-005 version-coherence discipline (verification-delta.md v1.5 §7 Part E / Job 2).
> - v1.7 (2026-07-20): FV-VP-069-FINALIZED / Job-2-xref: [Job 1] VP-SKILL-069 PROPOSED → FINALIZED (Invariant #8 + VP table row; verification-delta.md v1.3 §7 Part D confirms scope as static Iron-Law WHERE-clause assertion on Stage-3 OCSF + temporal-adjacency PrismQL blocks + prism-DTU multi-org org-a-returns-zero-org-b/c fixture + unscoped-query adversarial leg). [Job 2] Version-coherence sweep: Invariant #7 live cross-refs updated BC-3.03.001 v1.6 → v1.11 and BC-3.01.001 v1.11 → v1.15 (pass-3 final versions; P3-007/P3-009).
> - v1.6 (2026-07-20): ADV-F2-P3-004: [P3-004 MAJOR] Added explicit Invariant #8 for org_slug scoping — every investigate-event PrismQL query MUST include an explicit `org_slug` WHERE clause for the current org context (D-DEC-005). Added VP-SKILL-069 cross-reference as PROPOSED (formal-verifier finalizes scope and BATS fixture). Confirmed Invariant #7 "12-field ICD-203 validation" is correct for the investigation markdown path (no count change). Added VP-SKILL-069 row to Verification Properties table.
> - v1.0 (2026-07-19): Initial extraction from `investigate-event/SKILL.md` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): ADV-0-501: Annotated EC-006 to clarify the in-progress-save assumption — standard workflow generates from a complete template at Stage 7; EC-006 applies when analyst manually edits investigation file post-generation.
> - v1.2 (2026-07-19): ADV-0-601: Added Invariant #7 documenting that Stage 7's `jr issue comment` step hits require-review.sh unconditional deny and requires human permission-approval (no marker-based override). Added DI-013 reference.
> - v1.3 (2026-07-19): ADV-0-702: Corrected PC#3 — ≥2 alternative hypotheses is an LLM-soft procedural rule, not a structural hook enforcement; disposition-guard enforces only heading presence (subject to DI-004). Aligned with Invariant #5 and BC-3.03.001 Invariant #2. ADV-0-706: Standardized write-block citation in Invariant #7 to `88-94 (deny at :93)`.
> - v1.4 (2026-07-19): ADV-0-901: Replaced brittle require-review.sh line-number citation in Invariant #7 with construct-name reference (line numbers churned across PR#13/#14/#15; post-PR#15 lines 88-110 are the allowlist, not the write-block).
> - v1.5 (2026-07-20): PRISM-EVIDENCE: **UPDATED** — Added prism evidence collection stages to the investigation workflow: (a) raw OCSF event lookup via PrismQL at Stage 3, (b) temporal-adjacency query (±5min window), (c) ThreatIntel/NVD UDF enrichment at Stage 4, (d) optional Tavily web context (D-DEC-009 recommended tier). Structured evidence bundle with source attribution + fetch_time (§3.8 chain-of-custody). Added Precondition #5 (prism MCP optional). Updated Invariant #7 (DI-013 RESOLVED via D-DEC-001 marker mechanism). EC-008..EC-010 added. Iron Law, local-save-first ordering, and all 6 preserved invariants unchanged.

## Preconditions

1. A valid JIRA ticket ID containing a security event alert is provided. Confidence: verified by code analysis (`skills/investigate-event/SKILL.md:argument-hint`).
2. `jr` CLI is installed and authenticated. Confidence: verified by code analysis (Prerequisites section).
3. The Perplexity/WebSearch research path is determined ONCE at the start of the investigation (before Stage 3) and applied consistently throughout all stages. Confidence: verified by code analysis (Research Tool Selection section: "This decision is made ONCE at the start").
4. The skill announces itself verbatim before any other action. Confidence: verified by code analysis and BATS test `skills.bats:42-45`.
5. **[NEW v1.5]** Prism MCP availability is checked via `prism_describe` before Stage 3. If prism is available, prism evidence collection is applied (postcondition #7 stages). If prism is unavailable (connection error, timeout), all prism evidence collection stages are skipped and the investigation proceeds with the existing Perplexity/WebSearch path (EC-008). Prism availability is announced to the user alongside the Perplexity availability check.

## Postconditions

1. A disposition (True Positive / False Positive / Benign True Positive) is produced only after all 7 stages are complete, with evidence tracing each stage. Confidence: verified by code analysis (Iron Law: `NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST`) and BATS test `skills.bats:17-19`.
2. The investigation document is saved locally FIRST (chain of custody), before any JIRA update. Confidence: verified by code analysis (Stage 7 step order and Red Flag: "I'll update JIRA before saving locally").
3. At least 2 alternative disposition hypotheses must be documented. This is an LLM-enforced procedural rule from the skill (Red Flag: "I'm confident it's BTP, no need for alternatives"); the `disposition-guard` hook enforces only the structural presence of an "Alternatives Considered" heading (not the count or quality of alternatives, and subject to open DI-004 negating-substring false-pass — see BC-3.03.001 Invariant #2 and EC-009). Confidence: verified by code analysis and hook BC-3.03.001.
4. For external IPs in Stage 3, ASN/geolocation/reputation lookups are performed (via Perplexity if available, otherwise WebSearch). Confidence: verified by code analysis (Stage 3).
5. If alert platform type is ambiguous after Stage 1 auto-detection, the analyst is prompted to select ICS/IDS/SIEM before proceeding. Confidence: verified by code analysis (Stage 1).
6. Low-confidence dispositions automatically trigger an escalation recommendation. Confidence: verified by code analysis (Stage 6).

7. **[NEW v1.5] Prism evidence collection stages (when prism available):**

   When prism MCP is available (Precondition #5), the following evidence collection steps are added to the investigation workflow:

   - **Stage 3 addition — Raw OCSF event lookup:** Query prism for the raw OCSF-normalized event matching the alert:
     ```sql
     SELECT * FROM events
     WHERE org_slug='<org_slug>'
       AND event_id='<event_id>'
     ```
     If found, include the OCSF event record in the evidence bundle with `source: "prism"` and `fetch_time: "<ISO 8601 UTC>"`. D-DEC-005: `org_slug` constraint required in all PrismQL queries.

   - **Stage 3 addition — Temporal-adjacency query:** Query adjacent events within a ±5-minute window around the alert timestamp:
     ```sql
     SELECT * FROM events
     WHERE org_slug='<org_slug>'
       AND asset_id='<asset_id>'
       AND timestamp BETWEEN '<alert_time - 5min>' AND '<alert_time + 5min>'
     ORDER BY timestamp
     ```
     Adjacent events are included in the evidence bundle as `source: "prism/temporal-adjacency"` and labeled "contextual."

   - **Stage 4 addition — ThreatIntel UDF enrichment:** When a threat actor or malware family is identified in Stage 3, call `SELECT enrich_threatintel('<indicator>') AS ti_data` (if `enrich_threatintel` UDF is listed by `prism_describe`). Include TI results in evidence bundle with `source: "prism/threatintel-udf"` and `fetch_time`.

   - **Stage 4 addition — NVD UDF enrichment:** When a CVE identifier is present, call `SELECT enrich_nvd('<cve_id>') AS nvd_data`. Include NVD CVSS/KEV data in evidence bundle with `source: "prism/nvd-udf"` and `fetch_time`.

   - **Stage 4 addition — Optional Tavily web context (D-DEC-009):** At the recommended tier, query Tavily for web context on the key indicator (IP/domain/CVE). Tavily is OPTIONAL — if unavailable or returns error, the investigation continues without it (graceful degradation, EC-009). Do NOT abort solely because Tavily is unavailable.

   **Evidence bundle format (§3.8 chain-of-custody):** All prism and external evidence is collected into a structured evidence bundle:
   ```
   evidence_artifacts:
     - source: "prism" | "prism/temporal-adjacency" | "prism/threatintel-udf" | "prism/nvd-udf" | "tavily" | "perplexity"
       fetch_time: "<ISO 8601 UTC>"
       data: <evidence object>
       query: "<query used to retrieve evidence>"
   ```
   The evidence bundle is included in the investigation document and satisfies the `evidence_artifacts` field of the ICD-203 §3.8 schema.

## Invariants

1. **[Preserved v1.0]** Each event requires independent investigation — prior incidents of similar type cannot substitute for independent evidence collection. Confidence: verified by code analysis (Red Flag: "This looks like the same alert we saw last week, it's an FP" → "Each event needs independent investigation.").
2. **[Preserved v1.0]** Historical context (30/60/90-day patterns) must be checked — recency bias (treating the event as new without checking history) is prohibited. Confidence: verified by code analysis (Red Flag: "I'll skip historical context, this is clearly new").
3. **[Preserved v1.0]** Internal source IPs are not treated as automatically safe — lateral movement possibility must be assessed. Confidence: verified by code analysis (Red Flag).
4. **[Preserved v1.0]** The `enrichment-completeness` hook enforces required investigation document sections (Executive Summary, Alert Details, Disposition, Next Actions). Confidence: verified by hook BC-3.02.001.
5. **[Preserved v1.0]** The `disposition-guard` hook enforces that Alternatives Considered is present when a Disposition section exists. Confidence: verified by hook BC-3.03.001.
6. **[Preserved v1.0]** The Perplexity availability check happens once before Stage 3 and the result is announced to the user. Confidence: verified by code analysis (Research Tool Selection section).

7. **[UPDATED v1.5; reconciled v1.9 P11-004; rewritten v1.10 P13-001; gate-1-first v1.11 P16-001]** Stage 7 includes a `jr issue comment` call to post the investigation summary to the JIRA ticket. **DI-013 RESOLVED (D-DEC-001):** The `jr issue comment` command routing via the **Separate Human-Comment Marker Path** (BC-3.03.001 v1.23 Invariant #4) follows the **GATE-1-FIRST HUMAN-PATH** behavior: the investigate-event skill writes investigation-*.md ONLY as a human analyst (Stage 7 generates the document from a complete template; the analyst never injects `autonomy_enabled: true` into the file). Therefore **GATE 1 fires for every real invocation** — disposition-guard reads `autonomy_enabled` from the markdown content, finds it absent (or not exactly boolean `true`), and emits **allow-without-marker** (kill-switch parity per BC-3.03.001 v1.23 Gate 1). The investigation Write **always succeeds** for **ALL dispositions** (FP, TP, BTP, Indeterminate, or any other); **no Jira action marker of any kind is issued**; the subsequent `jr issue comment` falls to **human permission-approval** (Claude Code permission dialog). **MUST NOT be denied:** An analyst saving ANY compliant 12-field investigation — including Indeterminate disposition, any technique flagged or otherwise, any sensor state — MUST NOT have their Write denied on the human path, because Gate 1 emits allow-without-marker before any floor check is reached. The **Gate-2/3 routing applies ONLY when `autonomy_enabled` is exactly `true`** (the P12-002 autonomous-loop masquerade case), which this human-driven skill does not produce: (a) FP + autonomy_enabled=true → allow-without-marker; (b) non-FP/PARSE_FAIL + autonomy_enabled=true → MARKDOWN_REVIEW_PATH review marker (create-review or comment-review); (c) hard-floor conditions (Indeterminate disposition, forbidden techniques T1003/T1068/T1021/T1041, degraded/silent sensor) + autonomy_enabled=true → MARKDOWN-HARD-FLOOR deny. There is no "review marker for non-FP" and no "Indeterminate save denied" on the human path. **NOTE (P11-004):** Verdict-only fields (`scored_priority ∈ {HIGH,CRIT}` and critical/unknown `asset_type`) are NOT present in a 12-field investigation markdown and are NOT checked on this path — those floors apply only to the verdict-class path (BC-3.03.001 v1.23 PC#1). See BC-3.03.001 v1.23 Invariant #4 GATE 1 ("Separate Human-Comment Marker Path") for the authoritative pseudocode. **Verification property consumed: VP-HOOK-031 (FINALIZED P0 per verification-delta.md v1.18 [ID-sync per FV]) — this invariant is a consumer of the Separate Human-Comment Marker Path property; Gate 1 guarantees allow-without-marker for all human saves before Gate-2/3 routing is reached; no disposition from a human analyst save yields an autonomous comment marker. Paired mutant SM-47 (markdown-routed-into-verdict-emitter) is the kill target for compliant-save-allowed and no-validate_enums-on-markdown vectors.**

   > **Previous (v1.10/P13-001):** Routing description (a) FP → allow-without-marker; (b) non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH review marker; (c) hard-floor conditions → MARKDOWN-HARD-FLOOR deny; and "MUST NOT be denied" covering only non-Indeterminate/no-forbidden-technique/healthy-sensor saves. This post-Gate-1 routing description omitted GATE 1, which fires FIRST for human saves (autonomy_enabled absent). "MUST NOT be denied" incorrectly excluded Indeterminate, forbidden-technique, and degraded-sensor human saves from protection — all of which succeed via Gate 1 on the human path. P16-001 correction.

   > **Previous (v1.9/P11-004):** "The `jr issue comment` command is now **marker-gated** via the disposition-guard Separate Human-Comment Marker Path (BC-3.03.001 v1.19 — P11-004): after the investigation document passes ICD-203 12-field validation AND no markdown-evaluable hard-floor condition is met, disposition-guard writes a comment-scoped marker to `${CLAUDE_PLUGIN_DATA}/markers/`. Require-review (BC-3.01.001 v1.17) validates and consumes this marker to allow `jr issue comment`."

   > **Previous (v1.4):** "Stage 7 includes a `jr issue comment` call to post the investigation summary to the JIRA ticket. The `require-review` hook (C-12, the require-review write-block evaluated before the allowlist; denies jr issue comment/edit/move/assign/create and their --output json forms) denies `jr issue comment` unconditionally — the command is in the write-block substring list with no marker-based override path. The comment posting step proceeds only via human permission-approval of the blocked call (Claude Code permission dialog). There is no way for a skill command to include text that bypasses this deny. Resolution options are tracked as **DI-013, PENDING HUMAN DECISION at the Phase 0 gate.**"

   Confidence: D-DEC-001 binding decision (architecture-delta.md v1.1); BC-3.01.001 v1.17 PC#2 (marker-validation allow path); BC-3.03.001 v1.23 Invariant #4 (Separate Human-Comment Marker Path — Gate 1, P12-002 / P13-001).

8. **[NEW v1.6] org_slug scoping on ALL PrismQL queries (D-DEC-005).** Every PrismQL query issued by the investigate-event skill MUST include an explicit `org_slug` scope constraint for the current org context (see PC#7 Stage-3 queries, which already include `WHERE org_slug='<org_slug>'`). The skill must never construct a PrismQL query without this constraint. This is a defense-in-depth obligation complementing BC-10.01.001 Invariant #1 (monitoring-loop) and BC-4.05.001 Invariant #4 (assess-priority). If `org_slug` is not available from execution context, all prism evidence collection stages (PC#7) are skipped entirely and the investigation proceeds with the Perplexity/WebSearch path (EC-008). Confidence: D-DEC-005 binding decision (architecture-delta.md v1.1).

   **Verification property (ADV-F2-P3-004, FINALIZED):** VP-SKILL-069 — investigate-event PrismQL queries always include org_slug WHERE clause; strategy: static Iron-Law WHERE-clause assertion on Stage-3 OCSF + temporal-adjacency PrismQL blocks + prism-DTU multi-org org-a-returns-zero-org-b/c fixture + unscoped-query adversarial leg. FINALIZED per verification-delta.md v1.3 §7 Part D.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Alert platform type is ambiguous (neither ICS nor IDS nor SIEM keywords) | Stage 1 prompts analyst to select ICS/IDS/SIEM before proceeding |
| EC-002 | No log data available for Stage 4 | Flag as incomplete evidence; do not disposition without minimum evidence |
| EC-003 | Perplexity unavailable for threat intelligence | Switch to WebSearch/WebFetch for all Stages 3-5; announce switch; do not retry Perplexity per-stage |
| EC-004 | Source IP is internal | Must assess lateral movement possibility; do not assume safe |
| EC-005 | Low-confidence disposition reached | Automatically recommend escalation in Stage 6 output |
| EC-006 | Analyst saves investigation file without "Alternatives Considered" after manually adding a "Disposition" section | `disposition-guard` hook blocks. Standard Stage 7 workflow generates from event-investigation-tmpl.yaml (a complete template with all section headings already present); EC-006 applies when analyst edits the investigation file post-generation to add or modify Disposition content before completing the Alternatives Considered section. |
| EC-007 | Alert is an ICS/SCADA alert | Apply ICS-specific considerations (Purdue zones, safety systems, OT protocol context) |
| EC-008 | Prism MCP unavailable at Precondition #5 check | Skip all prism evidence collection stages (PC#7 additions); announce "Prism unavailable — investigation proceeds with Perplexity/WebSearch only"; continue existing 7-stage workflow unchanged. Do not abort. |
| EC-009 | Tavily unavailable during Stage 4 optional web context step | Skip Tavily step; do not abort; include note in evidence bundle "Tavily not available — web context omitted". Investigation continues. (D-DEC-009: Tavily is recommended, not required.) |
| EC-010 | Raw OCSF event lookup returns no result (event_id not found in prism) | Include note in evidence bundle "Event not found in prism — possible ingestion delay or sensor gap"; continue Stage 3 with Perplexity/WebSearch as primary source. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Ticket `ALERT-001`, Claroty ICS alert, clear TP with evidence, prism available with matching OCSF event | 7 stages complete; prism OCSF event in evidence bundle; TP disposition with evidence chain; saved locally first; marker-gated `jr issue comment` proceeds; JIRA updated | happy-path |
| Ticket with Snort/IDS alert, FP due to scanner misconfiguration | FP disposition with alternatives (TP malicious, BTP authorized scan); Alternatives Considered section present | happy-path |
| Ticket with no log data available | Flag as incomplete; do not disposition; recommend log retrieval | error |
| Internal source IP alert | Lateral movement assessed in Stage 5; disposition includes this consideration | edge-case |
| Prism unavailable | Investigation proceeds with Perplexity/WebSearch only; evidence bundle omits prism sources; announcement made (EC-008) | edge-case |
| Tavily unavailable | Stage 4 web context skipped; investigation continues; evidence bundle notes omission (EC-009) | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-018 | Iron Law text present verbatim | integration / BATS (`skills.bats:17-19`) |
| VP-SKILL-019 | Perplexity fallback path present in skill | integration / BATS (`skills.bats:169-171`) |
| VP-SKILL-020 | Template and data references use CLAUDE_PLUGIN_ROOT prefix | integration / BATS (`skills.bats:93-105`) |
| VP-SKILL-069 | org_slug scoping: every investigate-event PrismQL query includes an explicit org_slug WHERE clause; unscoped queries rejected; org-a query returns zero org-b/c rows in DTU multi-org fixture (Invariant #8). FINALIZED per verification-delta.md v1.3 §7 Part D. Strategy: static Iron-Law WHERE-clause assertion on Stage-3 OCSF + temporal-adjacency PrismQL blocks + prism-DTU multi-org fixture + unscoped-query adversarial leg. | integration / BATS (`@test "investigate-event PrismQL query always includes org_slug WHERE clause"`, `@test "investigate-event rejects unscoped PrismQL query"`, `@test "investigate-event org-a Stage-3 query returns zero org-b/c rows in multi-org DTU fixture"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-EVENT-01 |
| L2 Domain Invariants | NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST |
| Architecture Module | C-2 (skill-procedures), C-5 (investigation-workflow-playbook), C-25 (prism-mcp consumer) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/investigate-event/SKILL.md` (120 lines) |
| **Confidence** | high for existing behavior (v1.4 paths); D-DEC-001/D-DEC-005/D-DEC-009 binding decisions for prism evidence additions (v1.5 — not yet in source code) |
| **Extraction Date** | 2026-07-20 |

#### Evidence Types Used

- **documentation**: 7-stage workflow; alert platform detection keywords; research path decision protocol
- **guard clause**: Iron Law (line 13); Red Flags table (lines 25-34)
- **documentation**: Stage 7 step order ("Save locally FIRST") as documented chain-of-custody requirement
- **inferred**: ICS-specific considerations (Purdue model, safety systems) referenced in Stage 5
- **D-DEC-001**: marker-gated comment path (DI-013 RESOLVED — Invariant #7 updated)
- **D-DEC-005**: org_slug scoping for all PrismQL queries
- **D-DEC-009**: Tavily recommended tier; graceful degradation on unavailability

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads Jira (jr CLI), reads threat intelligence (Perplexity/WebSearch), reads prism MCP (new v1.5), reads analyst-provided log excerpts, writes investigation document (filesystem), writes Jira (comment + custom fields) |
| **Global state access** | none |
| **Deterministic** | no — depends on Jira ticket content, threat intelligence queries, prism state, analyst log data |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell |

#### Refactoring Notes

The disposition logic (evidence → TP/FP/BTP classification) is the core analytical function. The prism evidence collection stages (PC#7) are effectful and should be wrapped in a single evidence-collection function stubbable for testing. The Tavily optional step (D-DEC-009) must be designed with explicit try/skip semantics — any error in the Tavily call must not propagate to the investigation result.

**DI-013 RESOLVED (v1.5; reconciled v1.9; reconciled v1.10 / P13-001; reconciled v1.11 / P16-001):** The comment path is now marker-gated via D-DEC-001 using the Separate Human-Comment Marker Path (P11-004). Verdict-only hard floors (scored_priority HIGH/CRIT, critical/unknown asset_type) are not evaluated on this 12-field path. **Reconciled v1.10 / P13-001:** The markdown path no longer issues a comment-scoped marker for any disposition (MARKDOWN_COMMENT_PATH ELIMINATED); FP + autonomy_enabled=true produces allow-without-marker; non-FP/PARSE_FAIL + autonomy_enabled=true routes to MARKDOWN_REVIEW_PATH (create-review/comment-review review marker); hard-floor conditions + autonomy_enabled=true → MARKDOWN-HARD-FLOOR deny. **Reconciled v1.11 / P16-001:** The Gate-2/3 routing above is the masquerade case (autonomy_enabled=true, P12-002) only. For all real invocations of this human-driven skill, `autonomy_enabled` is absent — GATE 1 fires first and emits allow-without-marker for ALL dispositions (FP, non-FP, Indeterminate, any). There is no "remaining concern" about hard floors on the human path — the investigation Write always succeeds; `jr issue comment` falls to human permission-approval via Claude Code dialog regardless of disposition. (BC-3.03.001 v1.23 Gate 1 is the authoritative source.)

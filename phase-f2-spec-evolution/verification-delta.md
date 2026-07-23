---
document_type: verification-delta
producer: formal-verifier
version: "1.19"
date: 2026-07-23
cycle: v0.10.0-feature-prism-integration
phase: f2
status: draft
changelog:
  - "1.19 (2026-07-23): **Pass-17 adversarial remediation burst 14 — P17-001 (D-019 known-FP floor RETIRE/invert) + P17-002 (VP-HOOK-028 JSON-first property-(1) rewrite)** per architecture-delta v1.19 §8.31 items 8.31.2 (FV) + 8.31.4 (FV). **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation by a FRESH grep — `grep -rhoE 'VP-HOOK-[0-9]+' .factory/` VP-HOOK max = **032** (range 024–032, unchanged this pass), `grep -rhoE 'VP-SKILL-[0-9]+' .factory/` VP-SKILL max = **077** (unchanged), `grep -rhoE 'SM-[0-9]+' .factory/` max real = **SM-54** (SM-2026 a date FP in BC-6.01.001 frontmatter, SM-456 the 'PRISM-456' charset example in BC-3.03.001 — neither a mutant; SM-55 appears ONLY as 'SM-55 SKIPPED' — a documented non-allocation, NOT a live mutant); `grep -rn 'SM-56' .factory/` returned NO match repo-wide before allocation (confirmed absent incl. architecture-delta, BCs, and the target file). Allocation: **SM-56** (next-free control-flow mutant). **Collision avoided:** SM-55 is deliberately NOT reused — it is documented in ~15 places as 'skipped' (the VP-SKILL-077 no-mutant record); reusing it would collide-of-meaning with that record, so the D-019 mutant takes SM-56 and SM-55 remains reserved-skipped. **(1) [P17-001 MAJOR — D-019] known-FP scored_priority floor EXEMPTION RETIRED/INVERTED:** per D-019 (arch-delta §8.31.1/§8.31.4; human decision 2026-07-23) there is NO high-severity exemption — the P12-003b/D-016 'known-FP EXEMPT from the scored_priority floor → auto-close even at high native severity' vector is a dead/incorrect assertion (`hard_floor_applies()` fires unconditionally on `scored_priority ∈ {HIGH,CRIT}`; disposition-guard has no forgery-proof known-FP signal — an LLM `known_fp` field would be a CRITICAL O6 bypass). The v1.15 'known-FP floor EXEMPTION' vector under VP-HOOK-026 is **RETIRED** (reason 'D-019: exemption scoped to LOW/MED only; no high-sev exemption'; history preserved, no re-run). Replaced with the D-019 vectors: **(a)** LOW/MED-native known-FP (`scored_priority ∈ {LOW,MED}`) + healthy sensor + non-forbidden technique + disposition=FP → NO floor fires → **auto-close** (comment via the regular path); **(b)** HIGH/CRIT-native known-FP (`scored_priority ∈ {HIGH,CRIT}`) + known-FP store match + disposition=FP → **`hard_floor_applies()` FIRES → DENY-THE-WRITE (HARD-FLOOR-UNDER-LABEL) → routes to comment-review (human review), NOT auto-close** (exactly what the deterministic gate already enforces — the loop re-issues as comment-review per VP-HOOK-029). Paired mutant **SM-56** ('hard_floor_applies() adds a known-FP bypass branch that skips the floor for a known-FP match' → a HIGH/CRIT-native known-FP auto-closes instead of routing to review) killed by the D-019 HIGH/CRIT-sev-known-FP→review vector. **NO floor-EXEMPTION VP minted** (arch-delta §8.27 hold-note RESOLVED by D-019 — there is no exemption to verify; the FV obligation is to verify the floor FIRES for high-sev known-FPs, which SM-56 + the D-019 vectors do). hard_floor_applies() definition confirmed matching BC-3.03.001 L658-666 (fires on scored_priority ∈ {HIGH,CRIT} unconditionally, NO known-FP branch). **(2) [P17-002 MAJOR] VP-HOOK-028 property (1) REWRITTEN (JSON-first fail-closed boundary) + self-contradiction resolved:** property (1) asserted the now-dead 'a Stage-7 Write to a path NOT containing the `verdict` substring → disposition-guard fast-path-allow WITHOUT ICD-203 validation → mis-named verdict path fail-closed' — false under JSON-first dispatch (a JSON verdict at any `.json` path routes to the 18-field verdict class and emits a marker regardless of the `verdict` substring), and self-contradictory with property (2) which correctly states JSON-first precedence. Property (1) is rewritten to the ACTUAL residual fail-closed boundary: **a Stage-7 Write whose path has NEITHER a `.json` extension NOR JSON-parseable content (`jq empty` fails) NOR matches the `*investigation-*.md` glob → disposition-guard fast-path-allows WITHOUT ICD-203 validation → Stage-8 require-review DENIES the `jr` write (no marker issued).** BATS vectors rewritten: the 'mis-named verdict path' vector is RETIRED (reason 'P17-002 — dead under JSON-first dispatch'; history preserved); added a genuinely-non-dispatching-path vector (no .json ext / non-JSON content / non-investigation-md glob → fast-path-allow → Stage-8 denied) + a `.json`-path-without-'verdict'-substring positive vector (JSON-first dispatch FIRES → marker, NOT fast-path-allow) + a non-.json-path-with-JSON-content vector (dispatch fires). Property (1) and (2) are now consistent (property (2) is the authoritative JSON-first dispatch rule; property (1) states the fast-path-allow residual for the genuinely-non-dispatching path). **VP-HOOK-028 NOT retired** — the fail-closed boundary is real and P0-relevant; only the path-name premise was dead. **(3)** VP count UNCHANGED at **37** (VP-HOOK-026 EXTENDED in place, VP-HOOK-028 REWRITTEN in place — no new/renumbered VP). Mutant count 48 → **49** (+SM-56). VP-SKILL 001–077, VP-HOOK 024–**032**, SM 9–**56** (SM-32 = 32a+32b+32-ext; SM-55 reserved-skipped). Test-count ~263 → **~267** new BATS (net +4: D-019 known-FP inversion +2 on BC-10.01.001 [4 D-019 vectors replace 2 retired exemption vectors]; VP-HOOK-028 property-(1) JSON-first rewrite +2 on BC-3.03.001/BC-10.01.001 [3 added, 1 retired]). §7 Part Q records the pass-17 remediation. input-hash: COMPUTE-AT-COMMIT. Governance: architecture-delta, BCs, prd-delta, asm-004-validation, and brief untouched (PO edits BC-10.01.001 EC-009/field-18/Inv#14 + BC-3.03.001 EC-005/L814 in parallel per §8.31.1/§8.31.3). Cross-doc version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.18 (2026-07-22): **VP-SKILL-076/077 disentanglement (targeted coherence correction — corrects the burst-10 conflation).** The pass-14 remediation left VP-SKILL-076 ambiguously cited for TWO unrelated behaviors: (P14-002) setup-time `jira_project_key` charset-validation AND (P14-005) onboard-customer AD-017 credential-decline coverage — the exact one-ID-two-behaviors anti-pattern P14-005 flagged. This edit disentangles them. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation — `grep -rhoE 'VP-SKILL-[0-9]+' .factory/` VP-SKILL max = 076, `grep -rn 'VP-SKILL-077' .factory/` returned NO match repo-wide (confirmed absent incl. BCs and architecture-delta); `grep -rhoE 'SM-[0-9]+' .factory/` max real = SM-54 (SM-2026 a date FP in BC-6.01.001 frontmatter, SM-456 the 'PRISM-456' charset example in BC-3.03.001 — neither a mutant). VP-HOOK range 024–032 unchanged. **(1)** VP-SKILL-076 is kept SCOPED STRICTLY to P14-002 — the setup-time `jira_project_key` charset gate ONLY (activate BC-6.01.001 PC#12/EC-014 + onboard-customer BC-6.01.003 Inv#6/EC-010 reject a non-`^[A-Z][A-Z0-9]+$` key at setup, no partial-state write; conformant key accepted); paired mutant SM-54 unchanged. **(2)** NEW **VP-SKILL-077** (next-free after 076; P14-005) — onboard-customer AD-017 credential-decline: onboard-customer (BC-6.01.003 Inv#1 / EC-008) DENIES/declines credential entry in chat (never asks for or accepts a secret in the conversation; only piped-stdin `echo | prism credential set` documented), mirroring the VP-SKILL-054 onboard-sensor AD-017 pattern applied to the credential-decline path. Restores the AD-017 coverage orphaned when VP-SKILL-053 was repurposed. **NO paired mutant allocated (SM-55 SKIPPED):** VP-SKILL-077 is a B-STR structural-presence property on SKILL.md content (no runtime accept/decline control-flow branch to mutate) — mirroring its sibling VP-SKILL-054, which carries no SM-N mutant for the same reason; a SKILL.md prose edit is not an SM-N control-flow mutant, so no clearly-killable spec-level mutant is warranted. SM max stays 54. **(3)** VP-SKILL-053 repurposing annotation CORRECTED: original AD-017 coverage is now RESTORED via VP-SKILL-077 (was incorrectly stated as 'moved to VP-SKILL-076'). **(4)** VP count 36 → **37** (+VP-SKILL-077; no VP renumbered/re-scoped). Mutant count UNCHANGED at **48** (SM-55 skipped). VP-SKILL now occupied 001–**077**, VP-HOOK 024–032, SM 9–**54**. Test-count ~261 → **~263** new BATS (net +2: VP-SKILL-077 credential-decline structural greps on BC-6.01.003). §7 Part P records the disentanglement. input-hash: COMPUTE-AT-COMMIT. Governance: architecture-delta/BCs/prd-delta/spec-changelog/brief untouched (PO fixes BC-6.01.003 anchors in parallel). Cross-doc version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.17 (2026-07-22): Adversarial pass-14 remediation (P14-002 MAJOR / P14-005 MINOR) per architecture-delta v1.17 §8.30 items 8.30.6/8.30.7 (FV routing). **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation by `grep -rhoE 'VP-SKILL-[0-9]+' .factory/` (VP-SKILL max = 075) and `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-53; SM-2026 is a date false-positive inside BC-6.01.001 frontmatter and SM-456 is the 'PRISM-456' charset example in BC-3.03.001 — neither a mutant); `grep -rn 'VP-SKILL-076\\|SM-54' .factory/` returned NO match before allocation (confirmed absent repo-wide incl. architecture-delta and the target file). VP-HOOK range confirmed 024–032 (max 032, unchanged this pass). Allocations: **VP-SKILL-076** (next-free VP-SKILL after 075 — the setup-time jira_project_key charset-validation VP, sibling of VP-SKILL-051 activate version-gate) and **SM-54** (next-free SM after SM-53). No existing VP/SM renumbered; no collisions. **(1) [P14-002 MAJOR — no-covering-VP] NEW VP-SKILL-076 — setup-time jira_project_key charset validation:** P13-002 added setup-time charset validation on the activate (BC-6.01.001 PC#12/EC-014) and onboard-customer (BC-6.01.003 Inv#6/EC-010) SKILL setup flows, but no VP covered it — only the RUNTIME command_pattern deny (VP-HOOK-032 PROJECT-KEY-CHARSET-DENY) was covered. VP-SKILL-076 is the PREVENTIVE setup-time gate: `activate` AND `onboard-customer` BOTH REJECT a `jira_project_key` not matching `^[A-Z][A-Z0-9]+$` at SETUP time, with a user-facing error and NO partial-state write (fail-EARLY, not fail-closed mid-run); a conformant key (e.g. `PRISMDEMO`) is accepted. DISTINCT from VP-HOOK-032 (runtime disposition-guard command_pattern deny — a separate call-site VP-HOOK-032 does not exercise). Traces to BC-6.01.001 PC#12/EC-014 (activate) + BC-6.01.003 Inv#6/EC-010 (onboard-customer). Paired mutant **SM-54** (setup-time charset validation removed → a hyphenated key like `PRISM-DEMO` is stored → a downstream marker issuance then triggers the runtime `PROJECT-KEY-CHARSET-DENY` / `HARD-FLOOR-UNBINDABLE` livelock — proving setup-time validation is not redundant with the runtime deny) killed by VP-SKILL-076's reject-at-setup vector. **(2) [P14-005 MINOR — VP repurposing annotation] VP-SKILL-053 / VP-SKILL-057 roster annotation:** VP-SKILL-053 originally covered onboard-customer AD-017 credential-provisioning; repurposed pass-14 (P14-005) → now idempotent directory creation (credential-provisioning acceptance coverage moves to VP-SKILL-076 / the BC-6.01.003 Inv#1 anchor, PO burst-10). VP-SKILL-057 originally covered sensor-metrics org_slug scoping; repurposed pass-9 (P9-005) → now sensor-metrics naming-compliance (D-DEC-006) — org_slug scoping for sensor-metrics is moot under the D-DEC-005 / P9-005 sensor-health carve-out (prism_sensor_health metadata is org_slug-exempt). Annotations added inline on both roster rows so a future audit sees the ID's meaning changed. **onboard-customer AD-017 coverage consequence:** BC-6.01.003 Inv#1 / EC-008 is now anchored by the PO's burst-10 anchor (see BC-6.01.003 Inv#1 — references VP-SKILL-054 pattern inheritance or the new VP-SKILL-076 setup-time gate). **(3) [NVD sweep, P14-001 propagation] CVSS-as-native_severity residual CORRECTED:** confirmed P11-003 already removed VP-HOOK-030's CVSS-float STEP-1a vector (line ~684), but a residual survived in VP-SKILL-074 (severity-normalization) and SM-44's killer-vector reference: NORMALIZE_SEVERITY is authoritative ONLY over sensor_family ∈ {crowdstrike, armis, claroty, cyberint} (P14-001 / D-DEC-013); NVD/CVSS is NOT a sensor_family and MUST NOT appear as a NORMALIZE_SEVERITY family/native_severity example; CVSS feeds `scored_priority` (field 18) at Stage 5. Removed the `CVSS 4.0/7.0/9.0` NORMALIZE_SEVERITY family boundaries from VP-SKILL-074 (§2 row, §6 note, §5 BC-10.01.001 row) and corrected SM-44's stale `(1)–(5)` / `CVSS 9.5+MEDIUM` reference to `(1)–(4)` (VP-HOOK-030 has four per-family SEVERITY-MISMATCH consistency vectors after P11-003). The §6 clean-separation claim ('no verification-delta vector now references NVD/CVSS as a native_severity source') is now TRUE. **(4)** VP count 35 → **36** (+VP-SKILL-076; no VP renumbered / re-scoped in place). Mutant count 47 → **48** (+SM-54). VP-SKILL now occupied 001–**076**, VP-HOOK 024–032, SM 9–**54** (SM-32 = 32a+32b+32-ext). Test-count ~258 → **~261** new BATS (net +3: +5 VP-SKILL-076 setup-time reject/accept on activate + onboard-customer, −2 VP-SKILL-074 CVSS boundary fixtures removed per the P14-001 NVD sweep). Live-BC post-pass-14 (PO-owned per architecture-delta §8.30, in parallel): BC-6.01.001 (activate PC#12/EC-014 setup-time validation) + BC-6.01.003 (onboard-customer Inv#6/EC-010 setup-time validation + Inv#1/EC-008 AD-017 VP anchor) — outside FV's edit scope; state-manager annotates spec-changelog [1.1.0]; §7 Part O records the FV cross-references. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.16 (2026-07-22): Adversarial pass-13 remediation (P13-001 CRITICAL / P13-003 MAJOR / P13-004 MINOR) per architecture-delta v1.16 §8.29 FORMAL-VERIFIER LIST. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation by `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-51; SM-2026 is a date false-positive and SM-456 is the 'PRISM-456' example in BC-3.03.001, neither a mutant) and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}' .factory/` (VP-SKILL max 075, VP-HOOK max 032); `grep -rn 'SM-52\\|SM-53' .factory/` returned NO match before allocation (confirmed absent repo-wide incl. architecture-delta and the target file). The architect used placeholder SM-P13-A (§8.29) — FV assigns the real id. Allocations: **SM-P13-A → SM-52** (revert P13-001 — the markdown FP branch issues an autonomous `[\"comment\"] marker; killed by the FP→allow-without-marker vector) and **SM-53** (NEW — disposition parse uses a full-document substring scan instead of the canonical-heading-anchored parse → a `Disposition: FP` string embedded in an evidence block/code fence is read as FP → wrongly allow-without-marker instead of review; killed by the FP-in-body/code-fence vector, P13-003). No existing VP/SM renumbered; VP-HOOK-031 UPDATED in place (no new id). **(1) [P13-001 CRITICAL — per human decision 2026-07-22] MARKDOWN_COMMENT_PATH ELIMINATED — VP-HOOK-031 guarantee (c) REWRITTEN:** the markdown path NO LONGER issues an autonomous `[\"comment\"]` marker for ANY disposition. Rationale (architecture-delta v1.16 §8.29 item 1 / D-DEC-008): the hook cannot evaluate scored_priority (field 18) or asset_type (field 14) from a 12-field markdown, and no known-FP store cross-check applies on this path — so P12-002's GATE 1 closed the TP/BTP masquerade but left a residual FP-branch that granted an autonomous comment marker with no scored_priority/asset_type floor enforcement (the exact class flagged by ADV-F2-P13-001). New routing after the markdown-evaluable floors pass: **FP → allow-without-marker** (Write succeeds; NO Jira action authorized; NO `[\"comment\"]` marker written — the analyst surfaces an FP comment via the review path or the normal 18-field verdict flow); **non-FP (TP/BTP/Indeterminate) / PARSE_FAIL → MARKDOWN_REVIEW_PATH** (create-review/comment-review, same STEP 3 semantics, EXEMPT from the kill switch). VP-HOOK-031 guarantee (c) is rewritten from 'disposition=FP + floors pass → comment marker' to 'NO disposition yields an autonomous [\"comment\"] marker from the markdown path — FP → allow-without-marker; non-FP/PARSE_FAIL → review marker.' The prior FP→comment-marker vector is RETIRED (reason 'MARKDOWN_COMMENT_PATH eliminated ADV-F2-P13-001'; history preserved, no re-run). Added vectors: markdown FP → allow-without-marker (NO comment marker written); markdown TP/BTP/Indeterminate → review marker; disposition PARSE_FAIL → review (NEVER allow-without-marker). Paired mutant **SM-52** (revert the elimination — FP markdown issues a `[\"comment\"]` marker) killed by the FP→allow-without-marker vector; DISTINCT from **SM-51** which remains VALID (SM-51 = remove the non-FP→review routing rule → a TP/BTP markdown wrongly gets allow-without-marker instead of review; killed by the TP→review vector). No double-meaning: SM-51 targets the non-FP→review routing branch; SM-52 targets the FP→allow-without-marker branch (reverting the comment-marker elimination). SM-50 (markdown kill-switch gate removal) also remains valid (killed by the FP-kill-switch vector). P11-004 human-analyst intent preserved: the analyst's Write is NOT denied; the FP comment now surfaces through the review flow rather than autonomous action. **(2) [P13-003 MAJOR] Parse-grammar adversarial vectors + SM-53:** added VP-HOOK-031 vectors for the strict parse grammar — negated-FP prose (`Disposition: not a false positive` / `Disposition: not FP — TP`) → PARSE_FAIL/non-FP → REVIEW (NOT read as FP); a `Disposition: FP` string inside a code fence / evidence block with no canonical Disposition heading → NOT matched (canonical-heading-anchored parse) → PARSE_FAIL → review; `autonomy_enabled: true` token embedded in an evidence block/quoted log → gate stays CLOSED (dedicated-structured-field-only parse) → allow-without-marker; plus the canonical-FP / canonical-long-form positive controls. Paired mutant **SM-53** (disposition parse uses a full-document substring scan → an embedded `Disposition: FP` in a code fence is read as FP → allow-without-marker instead of review) killed by the FP-in-body/negated-FP vectors. Since P13-001 eliminates MARKDOWN_COMMENT_PATH, the blast radius of a PARSE_FAIL is reduced (all non-FP outcomes route to review, not to an autonomous comment) — the grammar remains required to correctly distinguish allow-without-marker (canonical FP) from review (everything else incl. PARSE_FAIL). **(3) [P13-004 MINOR] Historical-total annotation:** the historical pass-9 blockquote (~line 244, '6 VP-HOOK (024–029) + 25 VP-SKILL … grand total 31') is annotated **[HISTORICAL — pass-9 snapshot, SUPERSEDED]**; the CURRENT grand total is **VP-HOOK 024–032 (9 hooks) + 26 VP-SKILL = 35 VPs** (see §2 Totals). Swept for other stale current-tense '6 VP-HOOK'/'31 VP' figures — none remain in the current body. **(4) PRISMDEMO sweep (P13-002 propagation):** all 17 current-body `PRISM-DEMO` vector/example references (§2 VP table, §4 SM catalog, §5, §6) corrected to `PRISMDEMO` (the hyphen-free Jira-conformant demo key; `^[A-Z][A-Z0-9]+-[0-9]+$` / `^[A-Z][A-Z0-9]+$` charset regexes UNCHANGED — correct-for-Jira; only the example values change). **(5)** VP count UNCHANGED at **35** (VP-HOOK-031 UPDATED in place — guarantee (c) rewrite + parse-grammar vectors; no new VP). Mutant count 45 → **47** (+SM-52, +SM-53; SM-50/SM-51 remain valid). Test-count ~342 → **~360** (net +~15 BATS on BC-3.03.001: VP-HOOK-031 P13-001 rewrite — FP→allow-without-marker (SM-52), TP/BTP/Indeterminate→review, PARSE_FAIL→review, FP-kill-switch (net +~4 after retiring the FP→comment vector) + parse-grammar adversarial vectors +~11 (SM-53); + ~3 parity → ~102 parity). Live-BC post-pass-13 (PO-owned per architecture-delta §8.28, in parallel): BC-3.03.001 (MARKDOWN_COMMENT_PATH elimination — FP→allow-without-marker; strict parse grammar; PC#2 prose update + cross-ref '(P11-004 / P12-002 / P13-001)'), BC-6.01.001 (activate) / BC-6.01.003 (onboard-customer) setup-time jira_project_key validation, brief PRISMDEMO rename (human-authorized) — all outside FV's edit scope; §7 Part N records the FV cross-references. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.15 (2026-07-22): Adversarial pass-12 remediation (P12-001 CRITICAL / P12-002 CRITICAL / P12-003 MAJOR / P12-007 OBS) per architecture-delta v1.15 §8.27 FORMAL-VERIFIER LIST. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation by `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-47; SM-2026 is a date false-positive) and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}' .factory/` (VP-SKILL max 075, VP-HOOK max 031); `grep -rn 'SM-48\\|SM-49\\|SM-50\\|SM-51\\|VP-HOOK-032' .factory/` returned NO match before allocation (confirmed absent repo-wide incl. architecture-delta). The architect used placeholders SM-P12-A/B/C/D (§8.27) — FV assigns the real ids. Allocations: **SM-P12-A → SM-48** (remove ticket_id charset-validation → `.*` authorizes an unrelated comment command), **SM-P12-B → SM-49** (remove jira_project_key charset-validation), **SM-P12-C → SM-50** (remove the markdown kill-switch gate), **SM-P12-D → SM-51** (remove the markdown disposition!=FP route-to-review rule → TP gets an autonomous comment marker); NEW **VP-HOOK-032** (next-free VP-HOOK after 031 — the O7 command_pattern interpolation-safety property). No existing VP/SM renumbered. **(1) [P12-001 CRITICAL — regex injection] NEW VP-HOOK-032 (the O7 compliance artifact):** in every marker path disposition-guard builds `command_pattern` by concatenating `ticket_id`/`jira_project_key` into an anchored regex that require-review later evaluates with `[[ =~ ]]`; those fields were charset-UNvalidated + un-escaped (only control-char-stripped for audit — P4-010), so a metacharacter-laden `ticket_id='.*'` / `'SEC-1 |.*#'` broadened the pattern to authorize an UNRELATED `jr issue comment` (SEC-009 class; defeats the anchored-match property). Fix (architecture-delta v1.15 D-DEC-012 O7 / §8.26.1): BEFORE interpolation, VALIDATE `ticket_id` against `^[A-Z][A-Z0-9]+-[0-9]+$` (5 sites: STEP 6 comment/assign, STEP 3 comment-review, STEP 6 create [project-key], markdown comment path) and `jira_project_key` against `^[A-Z][A-Z0-9]+$` (2 sites: STEP 3 create-review, STEP 6 create) → on mismatch write `TICKET-ID-CHARSET-DENY`/`PROJECT-KEY-CHARSET-DENY` audit entry + emit deny; regex-escape as defense-in-depth. VP-HOOK-032 asserts a metacharacter-laden value is DENIED BEFORE pattern construction at ALL interpolation sites + valid values pass and anchor correctly. Paired mutants **SM-48** (remove ticket_id validation → `.*` authorizes an unrelated comment; killed by the ticket_id charset-deny vectors) and **SM-49** (remove jira_project_key validation; killed by the project-key charset-deny vectors). The false D-DEC-001/D-DEC-008 'never derived from Jira ticket content' claim is corrected in the BCs (PO-owned) — ticket_id IS derived from content; metacharacter safety comes from charset-validation + escaping, not from a false provenance claim. NOT ASM-008-covered — a regex-safety bug latent since the original marker design. **(2) [P12-002 CRITICAL — markdown-path redesign] VP-HOOK-031 UPDATED (four-guarantee scope):** per human decision 2026-07-22 the Human-Comment Marker Path is redesigned; VP-HOOK-031 now covers ALL FOUR guarantees — (a) `autonomy_enabled` absent/≠true → allow-without-marker (no autonomous comment under the kill switch, matching STEP-5 semantics); (b) `disposition != FP` → route to create-review/comment-review (NOT an autonomous comment marker — the hook cannot evaluate scored_priority/asset_type from a 12-field markdown, so escalation-worthy TP/BTP surface to human review); (c) `disposition=FP` + all markdown-evaluable floors pass → comment marker; (d) `ticket_id` charset-validated on the markdown path (P12-001). Closes the autonomous-loop-masquerade bypass (the loop gains nothing by writing a TP as `investigation-*.md`). Paired mutants **SM-50** (remove the markdown kill-switch gate → autonomy=false TP markdown wrongly issues a comment marker; killed by the kill-switch vector) and **SM-51** (remove the disposition!=FP route-to-review rule → TP markdown gets an autonomous comment; killed by the TP→review vector). **(3) [P12-003 MAJOR — enum-map + floor exemption] VP-HOOK-025 / VP-HOOK-026 EXTENDED:** (a) the known-FP fast-path (Stage 5 bypassed) sets `scored_priority` from `NORMALIZE_SEVERITY` output {LOW,MEDIUM,HIGH,CRITICAL} which is NOT a member of `SCORED_PRIORITY_ENUM` {CRIT,HIGH,MED,LOW} — a raw assignment produces `scored_priority='CRITICAL'`/`'MEDIUM'` → `validate_enums` fail-closed DENY of 30–40% of known-FP volume. VP-HOOK-025 gains fast-path enum-map vectors: the loop MUST map through `SEVERITY_TO_SCORED_PRIORITY_MAP` (CRITICAL→CRIT, MEDIUM→MED, HIGH→HIGH, LOW→LOW) so a mapped `CRIT`/`MED` passes validate_enums, while a raw unmapped `CRITICAL`/`MEDIUM` DENIES (the failure the map prevents). (b) VP-HOOK-026 gains the architectural known-FP floor-exemption vector: a documented known-FP + healthy sensor + non-forbidden technique + disposition=FP → auto-close (EC-009) even at high native severity, NOT routed to review (the known-FP store constitutes human pre-authorization). No new mutant for P12-003 (MAJOR, architect §8.27 item 3 — vectors only; the floor-exemption is architectural policy gated on PO confirming the BC-10.01.001 EC-009 floor-exempt annotation + known-FP store integrity invariants, §8.26.2). **(4) [P12-007 OBS] O7 standing rule codified in §0** (mirrors architecture-delta D-DEC-012 O7): any value interpolated into a `command_pattern` / authorization regex MUST be charset-validated to a fixed grammar (fail-closed) AND regex-escaped; every interpolation site needs a covering VP with a metacharacter-injection mutant. O7 interpolation audit: `ticket_id` (3 sites) + `jira_project_key` (2 sites) = 5 command_pattern sites, all covered by VP-HOOK-032 (SM-48/SM-49); `org_slug` is NOT interpolated into `command_pattern` (audit-log entries only, P4-010 control-char-strip sufficient) — SAFE, no command_pattern VP required. VP-HOOK-032 is the O7 compliance artifact (mirrors VP-HOOK-024=O5). **(5) Sweep:** no verification-delta current-body vector asserts the OLD markdown path (comment marker for ANY disposition) or the OLD fast-path raw `scored_priority` assignment — VP-HOOK-031 vector (a) re-cast from `Disposition: TP` to `Disposition: FP` (TP now routes to review) and the §5 BC-3.03.001 count updated; the D-DEC-001 'never derived from ticket content' claim does NOT appear in the verification-delta body (BC-owned, PO corrects). **(6)** VP count 34 → **35** (+VP-HOOK-032; VP-HOOK-031 updated in place, VP-HOOK-025/026 extended in place). Mutant count 41 → **45** (+SM-48, +SM-49, +SM-50, +SM-51). Test-count ~309 → **~342** (net +~25 BATS: BC-3.03.001 +23 [VP-HOOK-032 O7 charset +10, VP-HOOK-031 four-guarantee +6, VP-HOOK-025 fast-path enum-map +7] + BC-10.01.001 +2 [VP-HOOK-026 known-FP floor exemption]) + ~6 parity → ~99 parity. Live-BC post-pass-12 targets (PO-owned per architecture-delta §8.26, in parallel): BC-3.03.001 (ticket_id/jira_project_key charset-validation at 5 interpolation sites + markdown-path redesign + SEVERITY_TO_SCORED_PRIORITY_MAP note), BC-10.01.001 (fast-path enum map + known-FP floor exemption + store integrity), BC-4.05.001 (producer field rename — P12-004, PO-owned), BC-6.01.003/BC-8.02.001 (mis-anchor/traceability — P12-005/P12-006, PO-owned); §7 Part M records the FV cross-references. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.14 (2026-07-22): Adversarial pass-11 remediation (P11-001 CRITICAL / P11-002 MAJOR / P11-003 MAJOR / P11-004 MAJOR) per architecture-delta v1.14 §8.25 FORMAL-VERIFIER LIST. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation by `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-45; SM-2026 is a date false-positive) and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}' .factory/` (VP-SKILL max 075, VP-HOOK max 030); `grep -rn 'SM-46\\|SM-47\\|VP-HOOK-031' .factory/` returned NO match before allocation (confirmed absent repo-wide incl. architecture-delta). Allocations: **SM-46 / SM-47** (next free after SM-45) and **VP-HOOK-031** (next free VP-HOOK after 030); no existing VP/SM renumbered; two architect collision candidates (§8.25 SM-P11-A, unallocated VP) resolved to these next-free ids. **(1) [P11-001 CRITICAL] VP-HOOK-030 DOWNGRADED — consistency-only:** the pass-10 'un-bypassable / hook independently derives severity from raw sensor values / genuinely deterministic for severity' claim was FALSE — native_severity (field 16) and sensor_family (field 17) are BOTH written by the monitoring-loop LLM at Stage-1 INGEST and read verbatim; the network-free hook makes no prism call, so STEP 1a is a deterministic CONSISTENCY CHECK between two LLM-supplied fields, NOT ground-truth enforcement. VP-HOOK-030's asserted guarantee is re-scoped to 'verdict.severity is CONSISTENT with verdict.native_severity per the D-DEC-013 NORMALIZE_SEVERITY table (STEP 1a SEVERITY-MISMATCH check).' The SEVERITY-MISMATCH deny vectors are RETAINED (they still verify the consistency check) but their asserted guarantee is corrected. native_severity + sensor_family ground-truth is an **ASM-008-DEFERRED residual SYMMETRIC with the asset_type residual** (all three LLM-supplied; genuine enforcement requires a prism-signed field or hook-fetched prism data). VP-HOOK-030 stays FINALIZED as a consistency VP. **(2) [P11-002 MAJOR] scored_priority (field 18) two-field model:** verdict schema is now **18 mandatory fields** (12 ICD-203 + severity[13] + asset_type[14] + ticket_action_type[15] + native_severity[16] + sensor_family[17] + **scored_priority[18]**, enum CRIT|HIGH|MED|LOW = Stage-5 assess-priority output). The HIGH/CRIT hard floor now keys on `verdict.scored_priority` (field 18), NOT on recomputed severity — per brief §3.9 'any alert scored HIGH/CRIT → human,' capturing KEV/exposure/critical-asset escalations. VP-HOOK-026 gains scored_priority floor vectors (scored_priority∈{HIGH,CRIT} → hard floor → review path, NO regular marker; INCLUDING detector severity=LOW + scored_priority=CRIT → floor fires) and a field-18 validation vector (missing/invalid scored_priority → deny) is added to VP-HOOK-025. Paired mutant **SM-46** (re-key the floor back to recomputed severity instead of scored_priority) killed by the detector-LOW/scored-CRIT vector. scored_priority is itself LLM-supplied (same ASM-008-class residual — NOT asserted as ground-truth). All current-body '17-field' references swept to 18 (historical/changelog/snapshot narrative left intact). **(3) [P11-003 MAJOR] NVD/CVSS clean separation:** native_severity + sensor_family always describe the ORIGINATING SENSOR's raw reading; NVD/CVSS enrichment influences scored_priority (Stage-5), NOT native_severity; sensor_family has no `nvd` member. VP-HOOK-030's former CVSS-float STEP-1a under-report vector (5) is REMOVED (CVSS is not a hook-checked native_severity source). **(4) [P11-004 MAJOR] NEW VP-HOOK-031 — separate human-comment marker path:** the 12-field investigation-markdown path does NOT enter the verdict emitter; it emits a comment-scoped marker gated ONLY on 12-field completeness + markdown-evaluable hard floors (Indeterminate disposition, forbidden techniques, degraded/silent sensor), NOT validate_enums/STEP-1a. Vectors: (a) compliant 12-field save → comment marker, Write NOT denied; (b) Indeterminate/forbidden-technique/degraded-sensor → MARKDOWN-HARD-FLOOR deny; (c) a 12-field markdown gets NO validate_enums/STEP-1a (no false enum deny for absent verdict-only fields, incl. scored_priority). Paired mutant **SM-47** (route the 12-field markdown into the verdict emitter) killed by vectors (c)/(a). **(5) [P11-001/P11-002] O6 §0 annotation EXTENDED:** a hook re-computation from LLM-supplied inputs is a CONSISTENCY CHECK, not ground-truth enforcement; a network-free hook needs a prism-signed or hook-fetched input for true O6 (ASM-008-DEFERRED); the high-severity floor is moved to scored_priority (same residual class). **(6)** VP count 33 → **34** (+VP-HOOK-031; VP-HOOK-030 downgraded in place, VP-HOOK-025/026 extended in place). Mutant count 39 → **41** (+SM-46, +SM-47). Test-count ~297 → **~309** (net +~9 BATS: VP-HOOK-026 scored_priority floor +4 [incl. detector-LOW/scored-CRIT, SM-46] + VP-HOOK-025 field-18 validation +1 on BC-3.03.001/BC-10.01.001; VP-HOOK-031 human-comment marker path +4 [SM-47] on BC-3.03.001) + ~3 parity → ~93 parity. Live-BC post-pass-11 targets (PO-owned per architecture-delta §8.24, in parallel): BC-3.03.001 (STEP 1a consistency-only reframe + 18-field validate_enums + separate human-comment marker path), BC-10.01.001 (18-field schema + scored_priority floor), BC-5.01.001/BC-4.02.001 (human-comment marker path consumers); §7 Part L records the FV cross-references. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.13 (2026-07-22): Adversarial pass-10 remediation (P10-001 CRITICAL / P10-002 MAJOR / P10-003 MAJOR / P10-005 MINOR / P10-007 MINOR) per architecture-delta v1.13 §8.23 FORMAL-VERIFIER LIST. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation by `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-43; SM-2026 is a date false-positive) and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` (VP-SKILL max 074, VP-HOOK max 029); architect placeholders SM-P10-A / SM-P10-B → **SM-44 / SM-45** (next free after SM-43; `grep -rn` confirmed absent repo-wide incl. architecture-delta before allocation). Two NEW VP ids minted, occupancy-verified free repo-wide: **VP-HOOK-030** (next free VP-HOOK after 029) and **VP-SKILL-075** (next free VP-SKILL after 074). No existing VP/SM renumbered. **VERDICT SCHEMA 15→17 (P10-001):** the verdict JSON is now **17 mandatory fields** (12 ICD-203 + severity[13] + asset_type[14] + ticket_action_type[15] + **native_severity[16] + sensor_family[17]**); all current-body '15-field'/'ALL 15' verdict-schema descriptors swept to 17 (historical changelog/closing-snapshot narrative left intact). **(1) [P10-001 CRITICAL] NEW VP-HOOK-030 — STEP 1a SEVERITY-MISMATCH re-normalization (O6 standing rule):** hard_floor_applies() formerly keyed on LLM-supplied verdict.severity with no hook-side recomputation; disposition-guard STEP 1a now re-runs NORMALIZE_SEVERITY(native_severity, sensor_family) via the D-DEC-013 deterministic table and DENIES the verdict Write (SEVERITY-MISMATCH audit entry) when recomputed_severity != verdict.severity. VP-HOOK-030 adds per-family under-report vectors (CrowdStrike numeric, Armis/Claroty bands, Cyberint, NVD/CVSS) → deny; known-good agreement → proceed; missing field 16 or 17 → STEP 1 enum/presence deny. Paired mutant **SM-44** (revert STEP 1a — trust verdict.severity directly) killed by the under-report vectors. Housed as a NEW VP-HOOK (not folded into VP-HOOK-029) because STEP 1a is a distinct enforcement mechanism (trust-basis / O6), sibling to VP-HOOK-025 (enum) and VP-HOOK-026 (hard-floor). **(2) [P10-002 MAJOR] NEW VP-SKILL-075 — operator-boundary cron-exit-nonzero signal:** the cron wrapper (run-monitoring-loop.sh) exits non-zero (Gate 2) when markers/audit.log contains HARD-FLOOR-LIVELOCK-ABORT | HARD-FLOOR-UNBINDABLE | UNDER-LABEL-DENIED | SEVERITY-MISMATCH | MARKER-WRITE-FAILED newer than run-start; exits 0 on a clean run. **ASM-015-BLOCKED leg:** the Gate-1 assertion (hook-deny → .permission_denials populated in the --allowedTools JSON envelope) is BLOCKED pending ASM-015 empirical validation — that leg is marked ASM-015-PENDING and NOT counted toward convergence until ASM-015 resolves; the audit.log Gate-2 legs are testable NOW. VP-SKILL namespace chosen (wrapper is a helper script, sibling to VP-SKILL-051 prism-version-check.sh — not a PreToolUse hook). **(3) [P10-003 MAJOR] VP-HOOK-029 EXTENDED (stays FINALIZED P0)** with the marker-write-failure fail-closed review-path vectors: WRITE_MARKER failure on the STEP-3 create-review/comment-review (hard-floor review) path now fails closed — MARKER-WRITE-FAILED audit entry + emit deny (mirrors HARD-FLOOR-UNBINDABLE); the regular (comment/create/assign) path retains allow-without-marker (require-review's no-marker deny is the human gate). Paired mutant **SM-45** (revert review-path to allow-without-marker regardless of is_review_path → silent hard-floor drop) killed by the review-path fail-closed vector; separately killable from SM-41 (STEP-3 unbindable) and SM-38 (STEP-4 under-label). **(4) [P10-005 MINOR] VP-SKILL-059 UPGRADED** from structural-only to (a) behavioral prism-DTU multi-org fixture (org-a threat hunt returns zero org-b/c rows) + (b) static assertion that every query in `data/threat-hunt-queries.md` carries an org_slug clause (parse the library file, fail if any query is unscoped — not just SKILL.md prose). SM-24 (org_slug-drop) is the paired kill target on the behavioral leg. **(5) [P10-006/P10-007 MINOR] VP-SKILL-064** concrete @test renamed `rejects unscoped PrismQL query` → `rejects unscoped RAW-TABLE PrismQL query`; added `allows unscoped prism_sensor_health query (D-DEC-005 carve-out)` and `rejects prism_sensor_health JOIN raw-table query without org_slug (P10-006 boundary)` — operationalizes the D-DEC-005 carve-out tightening (exempt ONLY when prism_sensor_health is the SOLE table reference; a JOIN/subquery against a raw per-tenant table must carry org_slug). **(6) [O6 codified §0]** O6 standing rule added (mirrors architecture-delta D-DEC-012 O3-table O6 row): inputs to a hook-computed invariant MUST be hook-recomputable or hook-cross-validated against a deterministic ground truth, not LLM-supplied; STEP 1a SEVERITY-MISMATCH is the canonical operationalization for severity. **(7)** VP count 31 → **33** (+VP-HOOK-030, +VP-SKILL-075; VP-HOOK-029 extended in place, VP-SKILL-059/064 upgraded/renamed in place); roster now **7 VP-HOOK (024–030) + 26 VP-SKILL** (050/051, 052–063 [12], 064–075 [12]). Mutant count 37 → **39** (+SM-44, +SM-45). Test-count ~272 → **~297** (net +19 BATS: **+9 BC-3.03.001** [VP-HOOK-025 fields-16/17 presence +3 + VP-HOOK-030 STEP 1a SEVERITY-MISMATCH under-report/agreement +6, SM-44], **+8 BC-10.01.001** [VP-SKILL-064 carve-out +2 + VP-HOOK-029 marker-write fail-closed +3, SM-45 + VP-SKILL-075 cron-exit Gate-2 +3; Gate-1 `.permission_denials` leg ASM-015-BLOCKED and NOT counted], **+2 BC-9.01.001** [VP-SKILL-059 behavioral+static]; ~207 new BATS total) + ~6 parity → ~90 parity. Live-BC post-pass-10 targets (PO-owned per architecture-delta §8.22, in parallel): BC-3.03.001 (STEP 1a + WRITE_MARKER fail-closed + 17-field validate_enums), BC-10.01.001 (17-field schema + D-DEC-005 carve-out tightening + operator-boundary), BC-9.01.001 (VP-SKILL-059 behavioral); §7 Part K records the FV cross-references. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.12 (2026-07-21): Adversarial pass-9 remediation (P9-001 MAJOR / P9-004 MINOR / P9-007 MINOR / P9-009 OBS) per architecture-delta v1.12 §8.21 FORMAL-VERIFIER LIST. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation by `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-42; SM-2026 is a date false-positive) and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` (VP-SKILL max 074, VP-HOOK max 029); architect placeholder SM-P9-A → **SM-43** (next free after SM-42; confirmed absent repo-wide, including in the target file). No existing VP/SM renumbered. **(1) [P9-004 MINOR — bookkeeping, MY doc, fixed directly] §2 Totals VP-split mislabel + lifecycle-label drift:** the §2 Totals narrative claimed '8 hook properties / 23 skill properties' but the roster contains **6 VP-HOOK (024–029)** and **25 VP-SKILL** (050, 051, 052–063 [12], 064–074 [11]); grand total 31 is correct — the 8/23 split label was an internal miscount. Corrected to **6 hook / 25 skill**. Separately, the §2 Totals called VP-SKILL-052–063 'FINALIZED' while the §1 Namespace Adjudication table (the authoritative per-VP lifecycle table, and the source of truth absent a VP-INDEX.md) marks 052–063 as **ACCEPTED** (F1-inherited, never re-adjudicated/FINALIZED in F2 — only 050/051 are FINALIZED F1 VPs; F2 FINALIZES specific new ids like 064/069/070). The §1 label (ACCEPTED) is correct; the §2 'FINALIZED proposed' label was the drift. Reconciled §2 Totals to **'12 ACCEPTED F1-inherited VPs (052–063)'** — both locations now read ACCEPTED. **(2) [P9-001 MAJOR] VP-HOOK-024 — escaped-quote differential-vs-bash partition (O5):** the P8-002 quote-aware tokenizer toggles state on EVERY `\\\"`/`\\'` regardless of a preceding backslash, diverging from bash for the backslash-escape class; P8-003 removed the step-5 backstop, so step-6a `structural_label_check` is the SOLE anti-fungibility gate (EC-023 direction A). Added the escaped-quote partition per O5: **(1a SECURITY)** a command with a backslash-escaped quote boundary hiding a REAL trailing `--label REVIEW-REQUIRED` (e.g. `--summary \"a\\\"b\" --label REVIEW-REQUIRED`) → the D-DEC-001 v1.12 backslash-aware tokenizer keeps IN_DOUBLE across `\\\"` so the real `--label` is a standalone token → `has_review_label=TRUE` → a `[\"create\"]` marker is **DENIED** (bypass prevented); **(1b)** an escaped quote INSIDE the `--summary` value with NO real trailing label → `has_review_label=FALSE` → **ALLOW** (false-deny prevention); plus a **partition-2** completeness vector (`\\'` in UNQUOTED → literal apostrophe, no IN_SINGLE state entered, a subsequent whitespace-preceded `--label` is correctly detected) so the partition covers all backslash-escape classes the jr surface honors per O5. New mutant **SM-43** (revert the D-DEC-001 IN_DOUBLE backslash handling to the P8-002 toggle-on-every-quote behavior → `\\\"` closes the quoted region, the real `--label` is hidden, has_review_label=FALSE, the `[\"create\"]` marker wrongly ALLOWs the review-labeled create) killed by vector 1a; separately killable from SM-42 (non-quote-aware `split_on_whitespace` revert) and SM-40 (raw-substring revert). **Equals-form (`--label=REVIEW-REQUIRED`) SCOPED OUT** — jr CLI does not support the equals form (`jr issue create --help`, confirmed 2026-07-21); only `--label VALUE` space-separated form is emitted. Documented in VP-HOOK-024 with a re-evaluate note. **(3) [P9-007 MINOR] VP-HOOK-029 — dedup-before-fallback vector (test-only):** added a vector asserting the STEP-3 comment-review→create-review fallback hint (comment-review + null `ticket_id` + `jira_project_key` present) instructs the loop to re-run the §3.4 BLIND-SPOT/REVIEW-REQUIRED dedup query BEFORE switching to create-review — a dedup HIT (existing open review ticket) MUST NOT produce a duplicate create-review ticket (D-DEC-004 one-open-ticket). No new mutant warranted (architect §8.21 item 2 — the change is in the deny-reason text, not a security-critical control-flow path); documented as a test-only coverage vector. The loop-side dedup-HIT→comment-not-create protection is discharged by the existing **VP-SKILL-068** (grace-window + Jira-first dedup). **(4) [P9-009 OBS] O5 standing rule codified in §0** (mirrors architecture-delta v1.12 §D-DEC-012 O3-table O5 row): any hook re-implementing shell tokenization for a security decision MUST carry a differential-vs-bash vector partition over all shell-quoting classes the downstream CLI honors, with paired mutants; VP-HOOK-024 is the O5 compliance artifact for `structural_label_check`. **(5)** Mutant count 36 → **37** (+SM-43; no re-target/renumber); VP count UNCHANGED at **31** (VP-HOOK-024 / VP-HOOK-029 extended in place). Test-count ~267 → **~272** (net +4 BATS: VP-HOOK-024 escaped-quote partition +3 [1a/1b/partition-2] on BC-3.01.001; VP-HOOK-029 dedup-gate +1 on BC-10.01.001; +~1 parity for the SM-43 tokenizer branch). Live-BC post-pass-9 targets (PO-owned per architecture-delta §8.20, in parallel): **BC-3.01.001 v1.21, BC-8.02.001 +1 minor, BC-10.01.001 v1.14, BC-6.01.001 v1.6**; §7 Part J records the FV cross-references. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.11 (2026-07-21): Adversarial pass-8 remediation (P8-001 CRITICAL / P8-002 MAJOR / P8-003 MINOR) per architecture-delta v1.11 §8.19 FORMAL-VERIFIER LIST. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified BEFORE allocation by `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-40; SM-2026 is a date false-positive) and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` (VP-SKILL max 074, VP-HOOK max 029); architect placeholders SM-P8-A / SM-P8-B → **SM-41 / SM-42** (next free after SM-40; confirmed absent repo-wide). No existing VP/SM renumbered. **(1) [P8-001 CRITICAL] VP-HOOK-029 — unbindable-deny vectors (ADDITIVE to the §8.17 deny-path set; VP stays FINALIZED P0 — this is an EXTENSION, NOT a re-scope):** the redesigned D-DEC-008 STEP 3 replaces the two silent `emit allow without marker` branches (create-review + null `jira_project_key`; comment-review + null `ticket_id`) with a DENY-THE-WRITE per D-DEC-012 clause 2 — a correctly-labeled hard-floor verdict whose non-ICD-203 operational binding field is null can no longer silently discard the review obligation. `jira_project_key`/`ticket_id` are NOT in the 15-field presence check nor `validate_enums()`, so this sub-case slipped every prior gate — the exact P5-001/P7-001 silent-discard anti-pattern on the correctly-labeled review path. Added three vectors: (a) hard-floor verdict + create-review + null/empty `jira_project_key` → verdict Write DENIED + `HARD-FLOOR-UNBINDABLE` audit naming `missing_field=jira_project_key`, NEVER a silent allow-without-marker; (b) hard-floor + comment-review + null `ticket_id` + `jira_project_key` present → DENIED with a create-review fallback hint in the corrective reason; (c) hard-floor + comment-review + BOTH bindings null → DENIED naming both missing fields. New mutant **SM-41** (revert the STEP-3 create-review null-`jira_project_key` branch to emit-allow-without-marker → the pre-P8-001 silent-discard) killed by vectors (a)–(c); separately killable from SM-38 (which reverts the STEP-4 under-label deny). **(2) [P8-002 MAJOR] VP-HOOK-024 — quote-aware tokenizer:** the P7-005 `structural_label_check` (`split_on_whitespace`) still false-denies EC-024's own quoted-`--summary` example (the hook receives the raw command string with literal quotes via `jq -r`, no shell expansion). The false-deny-prevention vector is updated to the QUOTED form explicitly — a `--label REVIEW-REQUIRED` literal INSIDE a double-quoted `--summary` value → `has_review_label=false` → ALLOW under the D-DEC-001 state-machine tokenizer (UNQUOTED/IN_SINGLE/IN_DOUBLE). New mutant **SM-42** (revert `structural_label_check` to non-quote-aware `split_on_whitespace`) killed by the quoted-form vector; SEPARATELY killable from **SM-40** (raw-substring revert) — documented distinction: SM-40 dies because the raw substring matches inside the quoted region; SM-42 dies because whitespace-splitting breaks the quoted `--summary` value into a standalone `--label` token immediately preceding `REVIEW-REQUIRED`. **(3) [P8-003 MINOR] EC-023 / step-5 correction:** bash `[[ =~ ]]` is NOT tail-anchored — the regular create pattern `^jr … issue create --project KEY( |$)` PASSES step 5 for a review-labeled `--label REVIEW-REQUIRED …` command (`( |$)` guards ONLY against project-KEY prefix extension, e.g. `PROD` ≠ `PRODUCTION`). Anti-fungibility direction A is therefore enforced EXCLUSIVELY at step 6a (`structural_label_check`); there is NO step-5 'structural defense-in-depth' backstop. Swept the doc for any step-5-rejects-review-labeled-create / defense-in-depth-at-step-5 claim (none present as a current-body assertion — the claim lives in BC-3.01.001 EC-023, PO-owned §8.18); the §6 false-deny note re-cast to make step 6a the SOLE anti-fungibility enforcement point and load-bearing. Step 6a is a single point of failure → the SM-36/37/40/42 step-6a mutant family is **P0-adjacent** (SM-36/37 remain CRITICAL; the family is now NON-REDUNDANT and MUST be killed at the ≥95% require-review bar — no step-5 redundancy remains). **(4) Stale sweep:** the STEP-3 'allow without marker' missing-binding behavior was never encoded as a CURRENT-body assertion in verification-delta (it lived only in the BC/architecture bodies), so no residual current-body references required correction; the retired pass-5 'error-artifact+deny when no jira_project_key / UNDER-LABEL-CORRECTED' reference in the historical §7 Part F propagation ledger is left intact (superseded by Part H per the append-only-ledger convention). **(5)** Mutant count 34 → **36** (+SM-41, +SM-42; no re-target/renumber); VP count UNCHANGED at **31** (VP-HOOK-029 / VP-HOOK-024 extended in place). Test-count ~263 → **~267** (net +3 BATS: VP-HOOK-029 unbindable-deny +3 on BC-10.01.001; the VP-HOOK-024 quoted-form is an UPDATE of the existing SM-40 vector — +0; +~1 parity). Live-BC baseline at v1.11 edit time (pass-7 frozen): **BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12**; the pass-8 STEP-3 deny + quote-aware tokenizer + EC-023 BODY edits are PO-owned per architecture-delta §8.18 (in parallel) and will bump these — §7 Part I records the FV cross-references, and the dedicated version-coherence sweep reconciles the exact post-pass-8 numbers. input-hash: COMPUTE-AT-COMMIT."
  - "1.10 (2026-07-21): Adversarial pass-7 remediation (ADV-F2-P7-001/004/005/006/009) per architecture-delta v1.10 §8.17 FORMAL-VERIFIER LIST. **CENTRAL CHANGE — the STEP-4 marker-upgrade mechanism (P5-001/P6-002) is RETIRED; STEP 4 now DENIES the under-labeled verdict Write** (architecture-delta §8.17 / redesigned D-DEC-008 STEP 4). P7-001 CRITICAL proved the upgrade unsound: disposition-guard can rewrite the marker but NOT the loop's future Bash command, so the create-review marker was structurally unconsumable by the loop's own non-review `jr` command for 3 of 4 under-label action types → the hard-floor finding was silently dropped. **NAMESPACE DISCIPLINE (Lesson 8):** occupancy re-verified by `grep -rhoE 'SM-[0-9]+' .factory/` (max real = SM-37; SM-2026 is a date false-positive) and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` (VP-SKILL max 074, VP-HOOK max 029) before allocation; architect placeholders SM-NEW-A/SM-NEW-B → **SM-38/SM-39** (next free), step-6a paired mutant → **SM-40**. No existing VP/SM renumbered. **(1) [P7-001/P7-004 CRITICAL/MAJOR — O4]** VP-HOOK-029 re-scoped end-to-end per the O4 standing rule (assert the consumer-boundary jr authorization/execution outcome, NOT an emitter-local marker): re-marked PROPOSED then re-FINALIZED (P0) with the new deny-path vector set. New property — hard-floor/Indeterminate verdict with ANY ticket_action_type: (review token) → restricted marker emitted at STEP 3 AND a correctly-labeled jr write is authorized/consumable at consumer STEP 6a (assert the jr authorization outcome); (non-review token incl. `none`) → verdict Write DENIED with structured corrective reason (hard_floor_trigger/required_token/label_instruction) + UNDER-LABEL-DENIED audit entry — NEVER an unconsumable marker, NEVER a silent allow. **RETIRED** the three v1.9 STEP-4 upgrade-marker vectors (marked RETIRED, reason 'mechanism removed ADV-F2-P7-001'; history preserved) and the UNDER-LABEL-CORRECTED audit assertion. Added 6+ deny-path vectors (create/assign/none under-label × deny+UNDER-LABEL-DENIED audit; corrected-rewrite happy path; consumer-boundary consumable/unconsumable; kill-switch-irrelevance — deny fires with autonomy_enabled BOTH true and false, STEP 4 before STEP 5). **(2) Mutants:** allocated **SM-38** (remove the STEP-4 deny → revert to silent allow; killed by the deny-path vectors) and **SM-39** (remove the corrective-reason structure from the deny message → deny fires but the loop cannot act; killed by the machine-actionable-reason-fields vector). **Re-targeted SM-32a** (was step-4-under-label-upgrade-removed → the upgrade is retired) to 'revert the STEP-4 deny to the retired GOTO-WRITE_MARKER upgrade → unconsumable marker in-store without a corrected Write' (killed by the consumer-boundary vector). **Re-worded SM-32-ext** kill vector to the deny-before-kill-switch assertion (revert STEP 4/5 order → kill switch silently allows the under-labeled hard-floor verdict before the STEP-4 deny can fire; killed by the kill-switch-irrelevance deny vector). **(3) [P7-005 MINOR]** VP-HOOK-024 — added the step-6a structural-check false-deny-prevention vector (regular create with a literal '--label REVIEW-REQUIRED' inside `--summary` → ALLOW with a `[\"create\"]` marker; structural token check, not raw substring) + paired mutant **SM-40** (revert `has_review_label` to raw substring → the vector DENYs and the mutant dies). **(4) [P7-006 MINOR]** VP-SKILL-074 — added the Cyberint partition (3 vectors: any Cyberint native severity → CRITICAL pre-ASM-008 conservative default; Cyberint NEVER LOW/MEDIUM/HIGH until ASM-008 resolves; CRITICAL output carries uncertainty_explicit naming the unvalidated mapping) with an 'update when ASM-008 resolves' annotation. **(5) [P7-009 OBS — O4 standing rule]** codified O4 in the §1 preamble: emitter-local artifacts (a marker file exists, an audit line is written) NEVER suffice as evidence for a consumer-boundary guarantee; every 'never silently discarded' claim MUST have a VP asserting the downstream jr authorization/execution outcome at the consumer/Bash boundary. **(6) Stale sweep:** all references to the STEP-4 'upgrade', 'UNDER-LABEL-CORRECTED', 'upgrade to create-review/comment-review', and marker-presence-only fail-loud phrasing (SM catalog, §3/§6 notes, VP rows, §7 Part H, closing snapshot) re-cast to deny-the-Write semantics. VP-SKILL-065's regular-vs-review carve-out phrasing is UNCHANGED (the regular-vs-review distinction is unaffected by the STEP-4 redesign). **(7)** Mutant count 31 → **34** (+SM-38, +SM-39, +SM-40; SM-32a re-targeted, SM-32-ext re-worded — neither adds/removes an id); VP count UNCHANGED at **31** (VP-HOOK-029 re-scoped in place, VP-HOOK-024 / VP-SKILL-074 extended); test-count ~258 → **~263** (net +3 BATS: VP-HOOK-029 fail-loud DENY-THE-WRITE re-scope net −1 [8 deny-era vectors − 9 v1.9 upgrade-era vectors; 3 marker-upgrade vectors RETIRED], VP-HOOK-024 step-6a false-deny +1, VP-SKILL-074 Cyberint +3; +~2 parity). Live-BC targets at v1.10 edit time (pass-7): **BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12** (STEP-4 deny-the-Write redesign + step-6a structural fix + six stale-EC propagation + Cyberint mapping BODY owned by PO per architecture-delta §8.16; §7 Part H records the FV cross-references). input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep."
  - "1.9 (2026-07-21): Adversarial pass-6 remediation (ADV-F2-P6-001/002/003/005/007/010) per architecture-delta v1.9 §8.15 FORMAL-VERIFIER LIST. **NAMESPACE CORRECTIONS (independently re-verified — see §1):** (i) architect §8.15 item 3 proposed 'VP-SKILL-072' for severity normalization, but VP-SKILL-072 is ALREADY OCCUPIED (first-run 24h lookback, FINALIZED v1.5 / BC-10.01.001 v1.9 Inv#13). Severity normalization is therefore allocated the next free id **VP-SKILL-074** (073 is claimed by late-event per architecture-delta body §660/§3541). (ii) architect §8.15 item 5 (and the same-named consumer mutants) proposed 'SM-33'/'SM-34' for the consumer anti-fungibility mutants, but SM-33 (autonomy_enabled-clause-removed) and SM-34 (dispatch-order-inverted) are ALREADY OCCUPIED pass-4 sentinels; the consumer anti-fungibility mutants are therefore allocated the next free ids **SM-36**/**SM-37**. No existing VP or SM renumbered. (1) [P6-002 CRITICAL / P6-010] **FINALIZED VP-HOOK-029** (lifecycle PROPOSED → FINALIZED, fix-priority P0) and added the kill-switch-on under-label vectors: the three `autonomy_enabled=false` + under-labeled hard-floor combinations (ticket_id present → comment-review upgrade; ticket_id null + project_key present → create-review upgrade; neither → error+deny) asserting review-marker XOR error, NEVER silent allow, regardless of autonomy_enabled — closing the P6-002 coverage hole (STEP 4 under-label upgrade now runs BEFORE the STEP 5 kill switch per architecture-delta v1.9 §B). (2) [P6-001 CRITICAL] Added consumer anti-fungibility vectors under **VP-HOOK-024** asserting require-review STEP 6a exact-type matching in BOTH directions (create-review marker + command WITHOUT --label → DENY; create marker + command WITH --label → DENY; correct pairings consume normally — EC-023); paired mutants **SM-36** (remove the review-label check for review markers) and **SM-37** (remove the reverse check for regular markers), each killed by a distinct named vector. Added **SM-32-ext** (revert the STEP 4/5 ordering — kill switch back before under-label upgrade) killed by the new VP-HOOK-029 kill-switch-on under-label vectors. (3) [P6-003 MAJOR] **RE-SCOPED VP-SKILL-065** from 'zero jr writes under autonomy_enabled=false' to 'zero REGULAR (comment/create/assign) jr writes; create-review/comment-review escalation writes for genuine hard-floor verdicts still execute per D-DEC-012 Option A'; lifecycle re-marked (no longer silently FINALIZED — RE-SCOPED PROPOSED this pass); jr-mock spy assertion updated (zero REGULAR writes + kill-switch-exempt review write on silent-sensor). (4) [P6-005 MAJOR] Added **VP-SKILL-074** (severity normalization correctness, D-DEC-013) — per-sensor-family mapping (CrowdStrike 1-100, Armis/Claroty risk bands, NVD/CVSS floats) applied at Stage 1/Stage 5; unrecognized severity → CRITICAL with uncertainty_explicit (auditable), never a silent enum-deny; case-exactness preserved. Tag P1, PROPOSED. (5) [P6-007 MINOR] Added **VP-SKILL-073** (late-event drop detection, D-DEC-002) — event `_time < watermark − WATERMARK_GRACE_SECONDS` → LATE_EVENT_DETECTED audit entry emitted, event still processed; never a silent drop. Tag P1, PROPOSED. (6) Swept the CURRENT body for the STEP 4/5 swap (under-label upgrade = STEP 4, kill switch = STEP 5, post ADV-F2-P6-002): SM catalog target labels (SM-16, SM-32a, SM-33), VP-HOOK-026/029 rows, §3/§6 present-tense discussions; stale create-review command_pattern updated to the `--label (REVIEW-REQUIRED|BLIND-SPOT)( |$)`-in-fixed-second-position form; stale 'zero jr writes' phrasing re-scoped. (7) Mutant count 28 → **31** (SM-9..SM-35 with SM-32=SM-32a+SM-32b+SM-32-ext, + SM-36, + SM-37). VP count 29 → **31** (+VP-SKILL-073, +VP-SKILL-074). Test-count estimate ~238 → **~258** (+16 BATS: consumer anti-fungibility +2 on BC-3.01.001; kill-switch-on under-label +3, VP-SKILL-065 Option-A carve-out +1, late-event +3, severity-normalization boundary partitions +7 on BC-10.01.001; +~4 parity). Live-BC snapshot at v1.9 edit time (pass-6): BC-3.01.001 v1.17→**v1.18**, BC-3.03.001 v1.13→**v1.15**, BC-10.01.001 v1.9→**v1.11** (STEP reorder + Inv#11 carve-out + severity normalization body owned by PO per architecture-delta §8.14; FV cross-refs in §7 Part G). VP namespace now VP-SKILL 001–074, VP-HOOK 024–029; SM 9–37."
  - "1.8 (2026-07-21): Adversarial pass-5 re-scope (ADV-F2-P5-001 CRITICAL / P5-002 MAJOR) per architecture-delta v1.8 §8.13 FORMAL-VERIFIER LIST. Root cause (§8.13 / D-DEC-012 O3 standing rule): the deterministic disposition-guard hook trusted the LLM-supplied ticket_action_type without cross-checking hook-computed hard_floor_applies(); P5-001 (under-label) and P5-002 (over-label) are the duals of that single gap. (1) [P5-001 CRITICAL] RE-SCOPED VP-HOOK-029 from the happy-path-only 'hard-floor verdict WITH ticket_action_type∈{create-review,comment-review} → marker OR error' (which could NOT detect the silent-discard case) to the fail-loud critical vectors: 'hard-floor verdict carrying a NON-review ticket_action_type∈{comment,create,assign,none} → review-marker (STEP 5 upgrade) XOR explicit error+deny — NEVER silent allow-without-marker.' New vectors cover all three STEP 5 branches — (a) ticket_id present → comment-review upgrade; (b) ticket_id null + jira_project_key present → create-review upgrade; (c) ticket_id null + project_key absent → error artifact + deny — plus the UNDER-LABEL-CORRECTED audit entry; the pre-existing correct-label happy-path vectors are RETAINED (§8.13 item 1). (2) [P5-001/P5-002] RE-SCOPED SM-32 into two separately-killable variants: SM-32a (remove STEP 5 under-label upgrade → silent emit-allow-without-marker) killed by VP-HOOK-029 under-label vectors; SM-32b (remove the STEP 3 'NOT hard_floor_applies()' over-label gate → non-hard-floor verdict with a review token gets the kill-switch/hard-floor-exempt marker) killed by VP-HOOK-026 over-label vectors. Mutant count 27 → 28 (SM-9..SM-35, SM-32=SM-32a+SM-32b). (3) [P5-002 MAJOR] EXTENDED VP-HOOK-026 with over-label legs: a non-hard-floor verdict (disposition=TP, LOW severity, standard asset) carrying a create-review/comment-review token produces NO marker (allow-without-marker), incl. under autonomy_enabled=false (no kill-switch bypass) — the STEP 3 exemption is now GATED on hook-computed hard_floor_applies(verdict)=TRUE. (4) Swept §3 review-surfacing discussion, §5 BC-10.01.001 counts, and §6 notes for the retired 'unconditional/ungated review-exemption' and 'silent allow on action==none under hard floor' semantics; aligned to the STEP 3 gate + STEP 5 fail-loud upgrade (architecture-delta v1.8 D-DEC-008 STEP 3/STEP 5). VP namespace UNCHANGED (VP-SKILL 001–072, VP-HOOK 024–029; SM 9–35) — re-scope, NOT new IDs. Kill-switch Option A (escalation markers execute under autonomy_enabled=false for GENUINE hard-floor verdicts, human-confirmed 2026-07-21) reflected in the gated exemption. Test-count estimate ~231 → ~238 (+7 BATS on BC-10.01.001: VP-HOOK-026 over-label gate +3, VP-HOOK-029 fail-loud under-label expansion +4)."
  - "1.7 (2026-07-21): finish residual version-ref sync."
  - "1.6 (2026-07-21): version-ref sync to frozen live BC versions (BC-3.01.001 v1.17, BC-3.03.001 v1.13, BC-4.02.001 v1.8, BC-4.05.001 v1.3, BC-5.01.001 v1.8, BC-6.01.001 v1.5, BC-10.01.001 v1.9). No VP/strategy/mutant/test-count changes; stale live-body BC cross-refs (VP table §2, §5 sizing table, §3/§6 prose citations, §7 Part D/E correction targets, closing snapshot) synced to frozen; historical/changelog/edit-time/first-landed/CONFIRMED-APPLIED and evolution-narrative annotations left intact."
  - "1.5 (2026-07-21): Adversarial pass 4 remediation (architecture-delta v1.6 §8.11 FORMAL-VERIFIER LIST pass 4 + D-DEC-008 JSON-first dispatch + D-DEC-012 create-review/comment-review + validate_enums() + autonomy_enabled operational field). Adds 2 VPs — VP-HOOK-029 (P1 fail-loud invariant: a hard-floor/Indeterminate/silent-sensor verdict MUST yield a create-review/comment-review marker OR an explicit error artifact, never silent discard — D-DEC-012, ADV-F2-P4-004) and VP-SKILL-072 (BC-10.01.001 Inv#13 first-run 24h lookback correctness — ADV-F2-P4-012/D-DEC-002) — and 5 mutants (SM-31 validate_enums-removed → wrong-case severity passes hard floor, ADV-F2-P4-006; SM-32 review-surfacing-hard-floor-bypass-removed → Indeterminate+create-review wrongly blocked, D-DEC-012/P4-004; SM-33 autonomy_enabled-clause-removed → regular marker wrongly emitted under kill switch, ADV-F2-P4-005; SM-34 dispatch-order-inverted → verdict JSON at canonical investigations/verdict-*.json path misrouted to 12-field markdown branch and wrongly denied, ADV-F2-P4-001; SM-35 control-char-strip-removed → forged MARKER_USED audit line via \\n in ticket_id/org_slug/op, ADV-F2-P4-010). Extends VP-HOOK-024 (create command_pattern injection-safety: anchored `--project`-first pattern, --summary injection + PROD/PRODUCTION prefix → DENY, P4-002 CRITICAL), VP-HOOK-025 (validate_enums() membership legs for severity/asset_type/disposition/sensor_health_status/ticket_action_type/confidence — wrong-case/non-member → fail-closed DENY BEFORE hard floor, P4-006), VP-HOOK-026 (create-review/comment-review hard-floor-EXEMPT + kill-switch-EXEMPT legs, and autonomy_enabled read-direct-from-verdict determinism legs, D-DEC-012/P4-004/P4-005), VP-HOOK-028 (canonical-path JSON-first dispatch regression: investigations/verdict-*.json → 15-field verdict path; investigation-*.md → 12-field path, P4-001). Namespace re-verified independently: VP-SKILL 001–072, VP-HOOK 024–029, SM 9–35 — ZERO collisions. Live-BC snapshot SYNCED to BC-3.03.001 v1.12, BC-3.01.001 v1.16, BC-10.01.001 v1.8, BC-4.02.001 v1.7, BC-6.01.001 v1.5. Mutant count 22 → 27; test-count estimate refreshed ~195 → ~231 (~155 BATS + ~76 parity). BC corrections routed to PO in §7 Part E."
  - "1.4 (2026-07-20): version-ref sync to frozen pass-3 BC versions."
  - "1.3 (2026-07-20): Adversarial pass 3 remediation (architecture-delta v1.4 §8.9 FORMAL-VERIFIER LIST pass 3 + D-DEC-011 + D-DEC-008-C artifact-class branching). (1) [ADV-F2-P3-001 CRITICAL] VP-HOOK-026: added the asset_type=unknown hard-floor leg — a LOW-severity / benign-technique verdict with asset_type=unknown NEVER gets a marker regardless of autonomy_enabled; paired mutant SM-29 (unknown-asset-hard-floor-removed → asserts marker IS wrongly written, must be killed). (2) [ADV-F2-P3-004 MAJOR] FINALIZED VP-SKILL-069 (investigate-event PrismQL org_slug scoping — BC-5.01.001 v1.6 Inv#8, Stage-3 OCSF + temporal-adjacency queries always carry org_slug WHERE clause) and VP-SKILL-070 (assess-priority PrismQL org_slug scoping — BC-4.05.001 v1.2 Inv#4, PC#5a/5b/5d) — both already PROPOSED-referenced in their owning BCs; strategy = static Iron-Law content assertion + prism-DTU multi-org fixture (org-a query returns zero org-b/c rows). Added to VP table + coverage matrix. (3) [ADV-F2-P3-003/P3-013] VP-HOOK-025 per-class split: BATS counts now reflect the 12-field investigation-markdown path vs the 15-field verdict-JSON path (D-DEC-008-C artifact-class branching); paired mutant SM-30 (artifact-class-over-strict → apply the 15-field set to investigation markdown so a valid 12-field investigation is wrongly DENIED; a Severity heading inserted into investigation markdown must NOT trigger a wrong-class deny). (4) [ADV-F2-P3-005/P3-013] ADDED VP-HOOK-028 (verdict-path reachability — a Stage-7 Write to a non-'verdict' path → disposition-guard fast-path-allows, no marker → Stage-8 jr DENIED). Added to VP table + matrix. (5) [ADV-F2-P3-008/P3-013] VP-HOOK-025: added confidence float→enum legs (disposition-guard DENIES field#2 confidence float, ALLOWS enum values); FINALIZED VP-SKILL-071 (assess-priority confidence float→enum consistency — boundary test at D-DEC-011 thresholds 0.75 and 0.40). Added to VP table + matrix. (6) mutant catalog SM-9..SM-30 (22 mutants — +SM-29, +SM-30); test-count estimate refreshed ~165 → ~195. (7) Live-BC snapshot header synced to LIVE (BC-3.03.001 v1.10, BC-3.01.001 v1.15, BC-5.01.001 v1.6, BC-10.01.001 v1.6, BC-4.05.001 v1.2, BC-6.01.001 v1.4, BC-4.02.001 v1.6); VP-table/§ anchors re-synced for internal self-consistency; §7 Part D pass-3 BC corrections added."
  - "1.2 (2026-07-20): Adversarial pass 2 remediation (architecture-delta v1.3 §8.7 FORMAL-VERIFIER LIST). (1) ADV-F2-P2-001/P2-014: added VP-HOOK-027 (P1, cross-hook integration) — STAGE-ORDER DOCUMENT-BEFORE-ACTION: a monitoring-loop jr comment/create/assign is DENIED unless a verdict-record Write (disposition-guard emits marker) for the same run preceded it within the marker TTL (Stage 7 DOCUMENT before Stage 8 TICKET ACTION); + paired mutant SM-28 (stage-order-inverted). (2) ADV-F2-P2-009a: added VP-SKILL-066 (BC-4.02.001 Inv#4 never-auto-reopen on the UPDATE-JIRA path — VP-SKILL-062 covered only the monitoring-loop path) + paired mutant SM-26 (reopen-guard-removed). (3) ADV-F2-P2-009b: added VP-SKILL-067 (BC-4.02.001 Inv#5 SLA surface-never-assume — append/link/propose-reopen emit an explicit SLA-impact statement). (4) ADV-F2-P2-009c: added VP-SKILL-068 (D-DEC-002 watermark grace-window + Jira-first dedup — late/out-of-order event re-fetched inside GRACE with an existing open ticket → COMMENT not new ticket; VP-SKILL-050 remains monotonicity-only) + paired mutant SM-27 (dedup-check-removed→double-ticket). (5) ADV-F2-P2-005: version-refs synced to LIVE (BC-10.01.001 v1.4, BC-3.01.001 v1.14, BC-3.03.001 v1.9, BC-4.02.001 v1.5, BC-6.01.001 v1.3); §7 Part B VP-SKILL-064/065 re-marked FINALIZED (stale 'pending/still-owed' framing removed). (6) VP-HOOK-024 consumer vectors re-aligned to ITERATIVE-CONSUME (sort by issued_at_utc ASC; first successful atomic rename → allow; all renames fail/exhausted → deny) replacing the retired '>1 → ambiguous deny'; SM-15 retargeted from multiplicity-guard to iterative-consume exhaustion fail-open; audit path aligned to ${CLAUDE_PLUGIN_DATA}/markers/audit.log. (7) mutant catalog SM-9..SM-28 (20 mutants); test-count estimate refreshed ~139 → ~165."
  - "1.1 (2026-07-20): Adversarial pass 1 remediation — verification-delta re-aligned to architecture-delta v1.2 canonical marker schema v2.0 (expires_at_utc absolute, 120s TTL, base64 audit, rename-fail→deny, ticket-bound command_pattern) and 15-field verdict schema. (A) ADV-F2-008: FINALIZED VP-SKILL-064 (monitoring-loop org_slug scoping — sole plugin-side cross-tenant isolation guarantee, D-DEC-005). (B) ADV-F2-019 [process-gap]: added VP-SKILL-065 (autonomy_enabled kill switch — zero markers + zero jr writes when false). (C) ADV-F2-001/004: VP-HOOK-025 field completeness 12→15 (severity[13], asset_type[14], ticket_action_type[15]); VP-HOOK-026 hard-floor legs corrected to inject verdict.severity=HIGH + verdict.asset_type=critical-asset (keyed on severity NOT confidence). (D) ADV-F2-002: VP-HOOK-024 ticket-bound command_pattern + create/assign scoped allow-path vectors + rename-fail→deny. (E) ADV-F2-015: all stale BC version refs updated to LIVE (BC-3.01.001 v1.13, BC-3.03.001 v1.8, BC-4.02.001 v1.5, BC-10.01.001 v1.2). (F) SM-N catalog extended to SM-9..SM-25 (added severity-field-drop, ticket_action_type-ignored→wrong-scope, hard-floor-keyed-on-confidence, hard-floor-after-auto-close ADV-F2-005, org_slug-drop, kill-switch-ignore). (G) test-count estimate refreshed ~119 → ~139."
  - "1.0 (2026-07-20): Initial F2 verification-delta — 17 VPs, 4 PO questions answered, SM-9..SM-19, ~119 test-count estimate."
inputs:
  - .factory/phase-f2-spec-evolution/architecture-delta.md
  - .factory/phase-f2-spec-evolution/prd-delta.md
  - .factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass1.md
  - .factory/phase-0-ingestion/verification-gap-analysis.md
  - .factory/specs/module-criticality.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-4.02.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-4.05.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-5.01.001.md
  - .factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass3.md
  - .factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass4.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-6.01.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-6.01.003.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-6.01.004.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-8.02.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-9.01.001.md
  - .factory/phase-0-ingestion/behavioral-contracts/BC-10.01.001.md
  - .factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass10.md
  - .factory/phase-f2-spec-evolution/adversarial-spec-delta-review-pass11.md
  - plugins/secops-factory/tests/hooks.bats
  - plugins/secops-factory/tests/integration.bats
verification_stack: "BATS behavioral / structural-presence / integration (jr-mock + prism-DTU) + manual SM-N mutant catalog + adversarial fixtures. NO Kani/proptest/cargo-fuzz (declarative bash/markdown plugin)."
---

# Verification Delta — v0.10.0-feature-prism-integration (Phase F2)

> **Scope:** Finalizes all VP assignments for the prism-integration cycle, resolves the
> product-owner's 4 open technical questions as VP design decisions, extends the SM-N
> mutant catalog for the marker-validation and disposition-guard-JSON paths, and estimates
> the per-BC BATS test-count delta for F3 story sizing. Does NOT modify any BC, index, or
> STATE.md. BC reference corrections that require the product-owner's action are listed in §7.
>
> **v1.1 (adversarial pass 1 remediation):** re-aligned to architecture-delta **v1.2**
> canonical marker schema **v2.0** (`expires_at_utc` absolute, 120s TTL, base64-encoded audit
> command field, rename-fail→deny, ticket-bound `command_pattern`) and the **15-field** verdict
> schema (12 ICD-203 + severity[13] + asset_type[14] + ticket_action_type[15]). Finalizes
> **VP-SKILL-064** (ADV-F2-008 org_slug scoping) and adds **VP-SKILL-065** (ADV-F2-019 kill
> switch). Corrects VP-HOOK-024/025/026. All BC version references updated to LIVE. SM-N catalog
> extended to SM-9..SM-25. Live-BC snapshot at v1.1 edit time: BC-3.01.001 **v1.13**, BC-3.03.001
> **v1.8**, BC-4.02.001 **v1.5**, BC-10.01.001 **v1.2**.
>
> **v1.2 (adversarial pass 2 remediation):** closes the architecture-delta **v1.3** §8.7
> FORMAL-VERIFIER LIST. Adds **4 VPs** — **VP-HOOK-027** (P1 cross-hook: STAGE-ORDER
> DOCUMENT-BEFORE-ACTION, ADV-F2-P2-001/P2-014), **VP-SKILL-066** (BC-4.02.001 Inv#4
> never-auto-reopen on the update-jira path, ADV-F2-P2-009a), **VP-SKILL-067** (BC-4.02.001 Inv#5
> SLA surface-never-assume, ADV-F2-P2-009b), **VP-SKILL-068** (D-DEC-002 grace-window + Jira-first
> dedup, ADV-F2-P2-009c) — and **3 mutants** (SM-26 reopen-guard-removed, SM-27
> dedup-check-removed→double-ticket, SM-28 stage-order-inverted). Re-aligns VP-HOOK-024 to the
> **iterative-consume** consumer (architecture-delta §D-DEC-001 v1.3: sort by issued_at_utc ASC,
> first successful atomic rename → allow, exhausted → deny) — retiring the ">1 → ambiguous deny"
> gate — and to the canonical audit path `${CLAUDE_PLUGIN_DATA}/markers/audit.log`. **Live-BC
> snapshot at v1.2 edit time (SYNCED, ADV-F2-P2-005): BC-10.01.001 v1.4, BC-3.01.001 v1.14,
> BC-3.03.001 v1.9, BC-4.02.001 v1.5, BC-6.01.001 v1.3.**
>
> **v1.3 (adversarial pass 3 remediation):** closes the architecture-delta **v1.4** §8.9
> FORMAL-VERIFIER LIST (pass 3), the D-DEC-011 confidence float→enum contract, and the
> D-DEC-008-C artifact-class field-set branching. Adds **4 VPs** — **VP-SKILL-069**
> (investigate-event PrismQL org_slug scoping, ADV-F2-P3-004), **VP-SKILL-070** (assess-priority
> PrismQL org_slug scoping, ADV-F2-P3-004), **VP-SKILL-071** (assess-priority confidence float→enum
> consistency at D-DEC-011 thresholds 0.75/0.40, ADV-F2-P3-008), **VP-HOOK-028** (verdict-path
> reachability, ADV-F2-P3-005) — and **2 mutants** (SM-29 unknown-asset-hard-floor-removed,
> SM-30 artifact-class-over-strict). Extends **VP-HOOK-026** with the `asset_type=unknown` hard-floor
> leg (ADV-F2-P3-001 CRITICAL) and **VP-HOOK-025** with the 12-vs-15 per-class field split
> (ADV-F2-P3-003) + confidence float→enum legs (ADV-F2-P3-008). **Live-BC snapshot at v1.3 edit
> time (SYNCED): BC-3.03.001 v1.11, BC-3.01.001 v1.15, BC-5.01.001 v1.7, BC-10.01.001 v1.7,
> BC-4.05.001 v1.3, BC-6.01.001 v1.4, BC-4.02.001 v1.6.** Cross-doc/other-file version-ref
> reconciliation is owned by the dedicated version-coherence sweep that runs after this edit.
>
> **v1.5 (adversarial pass 4 remediation):** closes the architecture-delta **v1.6** §8.11
> FORMAL-VERIFIER LIST (pass 4), the **D-DEC-008 JSON-first dispatch** precedence fix, the
> **D-DEC-012** review-ticket surfacing path (`create-review`/`comment-review`), the D-DEC-008
> `validate_enums()` membership gate, and the `autonomy_enabled` operational-field determinism fix.
> Adds **2 VPs** — **VP-HOOK-029** (**P1** fail-loud invariant: a hard-floor / Indeterminate /
> silent-sensor verdict MUST yield a `create-review`/`comment-review` marker OR an explicit error
> artifact — NEVER silent discard, ADV-F2-P4-004) and **VP-SKILL-072** (BC-10.01.001 Inv#13
> first-run 24h lookback correctness, ADV-F2-P4-012 / D-DEC-002) — and **5 mutants** (SM-31
> validate_enums-removed, SM-32 review-surfacing-hard-floor-bypass-removed, SM-33
> autonomy_enabled-clause-removed, SM-34 dispatch-order-inverted, SM-35 control-char-strip-removed).
> Extends **VP-HOOK-024** (create `command_pattern` injection-safety, ADV-F2-P4-002 CRITICAL),
> **VP-HOOK-025** (`validate_enums()` membership legs, ADV-F2-P4-006), **VP-HOOK-026**
> (create-review/comment-review hard-floor-EXEMPT + kill-switch-EXEMPT legs + `autonomy_enabled`
> read-direct-from-verdict determinism, D-DEC-012 / ADV-F2-P4-004 / P4-005), and **VP-HOOK-028**
> (canonical-path JSON-first dispatch regression, ADV-F2-P4-001 CRITICAL). **Live-BC snapshot at
> v1.5 edit time (SYNCED): BC-3.03.001 v1.13, BC-3.01.001 v1.17, BC-10.01.001 v1.9, BC-4.02.001
> v1.8, BC-6.01.001 v1.5.** Cross-doc/other-file version-ref reconciliation remains owned by the
> dedicated version-coherence sweep.
>
> **v1.8 (adversarial pass-5 re-scope):** closes the architecture-delta **v1.8** §8.13
> FORMAL-VERIFIER LIST (ADV-F2-P5-001 CRITICAL / P5-002 MAJOR). **No new VP or SM IDs** — this is
> a re-scope of existing entries (VP-SKILL 001–072, VP-HOOK 024–029 unchanged). Root cause: the
> deterministic disposition-guard hook trusted the LLM-supplied `ticket_action_type` without
> cross-checking hook-computed `hard_floor_applies()` (D-DEC-012 O3 standing rule); P5-001
> (under-label) and P5-002 (over-label) are duals. **(1) VP-HOOK-029 re-scoped** from the
> happy-path-only "hard-floor + review token → marker OR error" (which could not detect the
> silent-discard case) to the fail-loud vectors: a hard-floor verdict carrying a **NON-review**
> `ticket_action_type ∈ {comment,create,assign,none}` MUST yield a review-marker (STEP 5 upgrade)
> **XOR** an explicit error+deny — NEVER a silent allow-without-marker; covers all three STEP 5
> branches (ticket_id present → comment-review; ticket_id null + project_key present → create-review;
> neither → error+deny) + the UNDER-LABEL-CORRECTED audit entry; correct-label happy-path vectors
> retained. **(2) SM-32 re-scoped** into **SM-32a** (remove STEP 5 upgrade → silent discard; killed
> by VP-HOOK-029 under-label vectors) and **SM-32b** (remove the STEP 3 `NOT hard_floor_applies()`
> gate → over-label kill-switch bypass; killed by VP-HOOK-026 over-label vectors) — mutant count
> 27 → 28. **(3) VP-HOOK-026 extended** with over-label legs (non-hard-floor verdict + review token
> → NO marker, incl. under `autonomy_enabled=false`); the STEP 3 review-exemption is now GATED on
> `hard_floor_applies(verdict)=TRUE`. **(4)** §3 review-surfacing discussion, §5 counts, and §6
> notes swept for the retired "unconditional/ungated review-exemption" and "silent allow on
> action==none under hard floor" semantics (architecture-delta v1.8 D-DEC-008 STEP 3/STEP 5).
> Kill-switch Option A confirmed 2026-07-21 (escalation markers execute under `autonomy_enabled=false`
> for GENUINE hard-floor verdicts only). Live-BC snapshot UNCHANGED from v1.5 (frozen pass-5:
> BC-3.03.001 v1.13, BC-3.01.001 v1.17, BC-10.01.001 v1.9). BC STEP 3/STEP 5 body updates are
> product-owner-owned (architecture-delta §8.12); §7 Part F records the FV cross-references.
>
> **v1.9 (adversarial pass-6 remediation — ADV-F2-P6-001/002/003/005/007/010):** closes the
> architecture-delta **v1.9** §8.15 FORMAL-VERIFIER LIST. **Two independently-verified namespace
> corrections** (§1): severity normalization is **VP-SKILL-074** (architect's §8.15 item-3 "VP-SKILL-072"
> collides with the already-FINALIZED first-run-24h-lookback VP-SKILL-072); the consumer anti-fungibility
> mutants are **SM-36/SM-37** (architect's §8.15 item-5 "SM-33/SM-34" collide with the already-occupied
> pass-4 mutants). **(1) [P6-002 CRITICAL / P6-010]** VP-HOOK-029 **FINALIZED** (PROPOSED → FINALIZED,
> P0) with kill-switch-on under-label vectors — the three `autonomy_enabled=false` + under-labeled
> hard-floor combinations (ticket_id present → comment-review; ticket_id null + project_key → create-review;
> neither → error+deny) assert review-marker XOR error, NEVER silent allow, regardless of `autonomy_enabled`
> (STEP 4 under-label upgrade now runs BEFORE the STEP 5 kill switch — architecture-delta v1.9 §B STEP
> reorder). **(2) [P6-001 CRITICAL]** consumer anti-fungibility vectors added under **VP-HOOK-024** —
> require-review STEP 6a exact-type matching in BOTH directions (create-review marker + no-`--label`
> command → DENY; create marker + `--label` command → DENY; correct pairings consume normally, EC-023);
> paired mutants **SM-36** (remove review-label check) + **SM-37** (remove reverse check); **SM-32-ext**
> (revert STEP 4/5 order) killed by the new VP-HOOK-029 kill-switch-on vectors. **(3) [P6-003 MAJOR]**
> VP-SKILL-065 **RE-SCOPED** (PROPOSED, no longer silently FINALIZED) to "zero REGULAR
> (comment/create/assign) jr writes; create-review/comment-review escalation writes for genuine
> hard-floor verdicts still execute per D-DEC-012 Option A." **(4) [P6-005 MAJOR]** new **VP-SKILL-074**
> (severity normalization, D-DEC-013 — per-sensor-family mapping at Stage 1/Stage 5; unrecognized →
> CRITICAL + `uncertainty_explicit`, auditable, never a silent enum-deny; case-exact). **(5) [P6-007
> MINOR]** new **VP-SKILL-073** (late-event drop detection, D-DEC-002 — `_time < watermark − GRACE` →
> `LATE_EVENT_DETECTED` audit entry, event still processed, never silent drop). **(6)** STEP 4/5 swap
> swept through SM catalog / VP notes / §3/§6 discussions; create-review `command_pattern` updated to the
> `--label (REVIEW-REQUIRED|BLIND-SPOT)( |$)` fixed-second-position form; stale "zero jr writes" phrasing
> re-scoped. **(7)** Mutant count 28 → **31** (+SM-32-ext, +SM-36, +SM-37); VP count 29 → **31**
> (+VP-SKILL-073, +VP-SKILL-074); test-count ~238 → **~258**. Live-BC snapshot at v1.9 edit time
> (pass-6): **BC-3.01.001 v1.18, BC-3.03.001 v1.15, BC-10.01.001 v1.11** (STEP reorder + Inv#11 carve-out
> + severity-normalization BODY owned by PO per architecture-delta §8.14; §7 Part G records the FV
> cross-references). Cross-doc/other-file version-ref reconciliation remains owned by the dedicated
> version-coherence sweep.
>
> **v1.10 (adversarial pass-7 remediation — ADV-F2-P7-001/004/005/006/009):** closes the
> architecture-delta **v1.10** §8.17 FORMAL-VERIFIER LIST. **The STEP-4 marker-upgrade mechanism
> (P5-001/P6-002) is RETIRED and replaced by DENY-THE-WRITE** (redesigned D-DEC-008 STEP 4). P7-001
> CRITICAL proved the upgrade structurally unsound: disposition-guard can rewrite the marker but NOT
> the loop's future Bash command, so an under-labeled hard-floor verdict produced a `create-review`
> marker the loop's own non-review `jr` command could never consume (3 of 4 under-label action types
> → silent drop). New STEP 4: a hard-floor / Indeterminate verdict carrying a non-review
> `ticket_action_type ∈ {comment,create,assign,none}` → disposition-guard **DENIES the verdict Write**
> with a structured machine-readable corrective reason (`hard_floor_trigger`, `required_token`,
> `label_instruction`, `instruction`) + an **UNDER-LABEL-DENIED** audit entry; NO marker; the loop
> re-issues the Write with the corrective token; on the corrected Write STEP 3 issues the review marker
> normally. **No new VP/SM IDs minted without occupancy verification (Lesson 8): architect placeholders
> SM-NEW-A/SM-NEW-B → SM-38/SM-39; the step-6a paired mutant → SM-40** (next free; SM-37 was the prior
> max real id — SM-2026 is a date false-positive). **(1) [P7-001/P7-004]** VP-HOOK-029 re-scoped
> **end-to-end (O4)**: re-marked PROPOSED, then re-FINALIZED (P0) asserting the CONSUMER-BOUNDARY jr
> authorization/execution outcome — for a hard-floor verdict with ANY `ticket_action_type`: (review
> token) → restricted marker at STEP 3 AND a correctly-labeled jr write authorized/consumable at
> consumer STEP 6a; (non-review token incl. `none`) → verdict Write DENIED with corrective reason +
> UNDER-LABEL-DENIED audit — NEVER an unconsumable marker, NEVER a silent allow. **RETIRED** the three
> v1.9 STEP-4 upgrade-marker vectors (marked RETIRED, reason "mechanism removed ADV-F2-P7-001"; history
> preserved) + the UNDER-LABEL-CORRECTED audit assertion; **added** the deny-path vectors (create/assign/none
> under-label deny+audit; corrected-rewrite happy path; consumer-boundary consumable/unconsumable;
> kill-switch-irrelevance — deny fires with `autonomy_enabled` BOTH true and false). **(2) Mutants:**
> **SM-38** (remove STEP-4 deny → silent allow; killed by the deny-path vectors), **SM-39** (remove the
> corrective-reason structure → deny fires but the loop cannot act; killed by the machine-actionable-reason
> vector); **SM-32a re-targeted** to "revert the deny to the retired GOTO-WRITE_MARKER upgrade →
> unconsumable in-store marker" (killed by the consumer-boundary vector); **SM-32-ext** kill vector
> re-worded to the deny-before-kill-switch assertion. **(3) [P7-005]** VP-HOOK-024 step-6a structural-check
> false-deny vector + paired **SM-40** (raw-substring revert). **(4) [P7-006]** VP-SKILL-074 Cyberint
> partition (3 vectors; "update when ASM-008 resolves"). **(5) [P7-009]** O4 standing rule codified below.
> **(7)** Mutant count 31 → **34**; VP count UNCHANGED at **31**; test-count ~258 → **~263** (net +3 BATS).
> Live-BC targets at v1.10 edit time (pass-7): **BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12**;
> §7 Part H records the FV cross-references. Cross-doc/other-file version-ref reconciliation remains
> owned by the dedicated version-coherence sweep.
>
> **v1.11 (adversarial pass-8 remediation — P8-001 CRITICAL / P8-002 MAJOR / P8-003 MINOR):** closes the
> architecture-delta **v1.11** §8.19 FORMAL-VERIFIER LIST. **No new VP IDs; two new SM IDs (occupancy
> re-verified, Lesson 8 — SM-40 was max real, SM-2026 a date false-positive; SM-P8-A/SM-P8-B → SM-41/SM-42).**
> **(1) [P8-001 CRITICAL] VP-HOOK-029 unbindable-deny vectors (ADDITIVE; VP stays FINALIZED P0 — extension,
> not re-scope):** the redesigned D-DEC-008 STEP 3 replaces the two silent `emit allow without marker`
> branches (create-review + null `jira_project_key`; comment-review + null `ticket_id`) with a
> **`HARD-FLOOR-UNBINDABLE` DENY-THE-WRITE** per D-DEC-012 clause 2 — a correctly-labeled hard-floor verdict
> whose non-ICD-203 operational binding field is null can no longer be silently allowed-without-marker (the
> P5-001/P7-001 silent-discard anti-pattern surfacing on the *correctly-labeled* review path, orthogonal to
> the under-label axis passes 5–7 hardened). Added three vectors — (a) hard-floor + create-review + null/empty
> `jira_project_key` → verdict Write DENIED + `HARD-FLOOR-UNBINDABLE` audit naming `missing_field=jira_project_key`,
> NEVER a silent allow; (b) hard-floor + comment-review + null `ticket_id` + `jira_project_key` present →
> DENIED with a create-review fallback hint; (c) hard-floor + comment-review + BOTH bindings null → DENIED
> naming both. New mutant **SM-41** (revert the STEP-3 create-review null-`jira_project_key` branch to
> emit-allow-without-marker) killed by (a)–(c); separately killable from SM-38 (STEP-4 deny revert).
> **(2) [P8-002 MAJOR] VP-HOOK-024 quote-aware tokenizer:** the P7-005 `split_on_whitespace` still false-denies
> EC-024's own quoted-`--summary` example; the false-deny vector is updated to the QUOTED form explicitly
> (`--label REVIEW-REQUIRED` literal inside a double-quoted `--summary` value → `has_review_label=false` →
> ALLOW under the D-DEC-001 UNQUOTED/IN_SINGLE/IN_DOUBLE state-machine tokenizer). New mutant **SM-42**
> (revert to non-quote-aware `split_on_whitespace`) killed by the quoted-form vector; SEPARATELY killable from
> **SM-40** (raw-substring revert) — distinction documented (§4/§6). **(3) [P8-003 MINOR] EC-023/step-5
> correction:** bash `[[ =~ ]]` is NOT tail-anchored — the regular create pattern PASSES step 5 for a
> review-labeled command; anti-fungibility direction A is enforced EXCLUSIVELY at step 6a (`structural_label_check`),
> which is now the SOLE, load-bearing enforcement point (no step-5 backstop). The SM-36/37/40/42 step-6a
> mutant family is correspondingly **P0-adjacent** (non-redundant; SM-36/37 remain CRITICAL). **(4) Stale
> sweep:** the STEP-3 'allow without marker' missing-binding behavior was never a current-body assertion here
> (it lived only in the BC/architecture bodies), so no residual current-body references needed correction.
> **(5)** Mutant count 34 → **36**; VP count UNCHANGED at **31**; test-count ~263 → **~267** (net +3 BATS —
> VP-HOOK-029 unbindable-deny +3 on BC-10.01.001; the VP-HOOK-024 quoted-form is an UPDATE of the SM-40
> vector, +0). Live-BC baseline (pass-7 frozen): **BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12**;
> the pass-8 STEP-3 deny + quote-aware tokenizer + EC-023 BODY edits are PO-owned per architecture-delta §8.18
> (in parallel). §7 Part I records the FV cross-references. Cross-doc/other-file version-ref reconciliation
> remains owned by the dedicated version-coherence sweep.
>
> **v1.12 (adversarial pass-9 remediation — P9-001 MAJOR / P9-004 MINOR / P9-007 MINOR / P9-009 OBS):** closes
> the architecture-delta **v1.12** §8.21 FORMAL-VERIFIER LIST.
> **`[HISTORICAL — pass-9 snapshot, SUPERSEDED (P13-004 annotation)]`** *The '6 VP-HOOK (024–029) + 25 VP-SKILL / grand total 31' figure below is a pass-9-era snapshot and MUST NOT be read as the current total. The CURRENT grand total is **VP-HOOK 024–032 (9 hooks) + 28 VP-SKILL = 37 VPs** (see §2 Totals / the v1.18 closing snapshot). VP-HOOK grew 029→032 across passes 10–12 (VP-HOOK-030 STEP 1a, VP-HOOK-031 human-comment path, VP-HOOK-032 O7 command_pattern) and VP-SKILL 074→075→076→077 (VP-SKILL-075 operator-boundary cron-exit; VP-SKILL-076 setup-time jira_project_key charset validation, pass-14/P14-002; VP-SKILL-077 onboard-customer AD-017 credential-decline, pass-14/P14-005 — allocated by the v1.18 VP-SKILL-076/077 disentanglement).*
> **One new SM id (occupancy re-verified, Lesson 8
> — SM-42 was max real, SM-2026 a date false-positive; SM-P9-A → SM-43).** **(1) [P9-004 MINOR — MY doc, fixed
> directly] §2 Totals bookkeeping:** the split label '8 hook / 23 skill' was an internal miscount — the roster
> is **6 VP-HOOK (024–029) + 25 VP-SKILL** (grand total 31 correct *for pass-9; SUPERSEDED — current is 9 hook / 27 skill / 36 total per the banner above*); corrected to **6 hook / 25 skill**. And the
> §2 Totals lifecycle label 'FINALIZED' for VP-SKILL-052–063 is reconciled to **ACCEPTED** to match the §1
> Namespace Adjudication table (the authoritative per-VP lifecycle source absent a VP-INDEX.md — 052–063 are
> F1-inherited ACCEPTED, never re-FINALIZED in F2). **(2) [P9-001 MAJOR] VP-HOOK-024 escaped-quote partition
> (O5):** the P8-002 tokenizer toggles state on every `\"`/`\'` regardless of a preceding backslash — diverging
> from bash for the backslash-escape class; with the P8-003 step-5 backstop removed, step-6a is the SOLE
> anti-fungibility gate. Added the escaped-quote differential-vs-bash partition — **(1a SECURITY)** escaped-quote
> boundary hiding a REAL trailing `--label REVIEW-REQUIRED` → `has_review_label=TRUE` → `[\"create\"]` marker
> **DENIED**; **(1b)** escaped quote inside `--summary`, NO real label → `has_review_label=FALSE` → **ALLOW**
> (false-deny prevention); **partition-2** (`\'` UNQUOTED → literal apostrophe, no IN_SINGLE, subsequent `--label`
> detected). Paired mutant **SM-43** (revert the D-DEC-001 v1.12 IN_DOUBLE backslash handling to the P8-002
> toggle-on-every-quote) killed by 1a; separately killable from SM-42/SM-40. **Equals-form scoped OUT** (jr CLI
> has no `--label=` form, confirmed 2026-07-21). **(3) [P9-007 MINOR] VP-HOOK-029 dedup-gate vector (test-only):**
> the STEP-3 comment-review→create-review fallback hint is honored only after a §3.4 dedup re-run confirms no
> open BLIND-SPOT/REVIEW-REQUIRED ticket (a dedup HIT MUST NOT produce a duplicate create-review, D-DEC-004); no
> mutant warranted (deny-reason text, not a control-flow security path — architect §8.21 item 2); loop-side
> protection discharged by VP-SKILL-068. **(4) [P9-009 OBS] O5 standing rule codified (§0)** — any hook
> re-implementing shell tokenization for a security decision MUST carry a differential-vs-bash vector partition
> over all shell-quoting classes the downstream CLI honors, with paired mutants. **(5)** Mutant count 36 → **37**
> (+SM-43); VP count UNCHANGED at **31**; test-count ~267 → **~272** (net +4 BATS). §7 Part J records the FV
> cross-references. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated
> version-coherence sweep.

---

## 0. Standing Rules / Conventions (cross-cutting, load-bearing)

**O4 standing rule — consumer-boundary evidence (ADV-F2-P7-009 / architecture-delta v1.10 D-DEC-012
O3 table row P7-009).** *Emitter-local artifacts NEVER suffice as evidence for a consumer-boundary
guarantee.* A marker file existing in the store, or an audit line being written, is an **emitter-side**
predicate; the human-surface guarantee (a finding reaches a SOC analyst) lives at the **consumer/Bash
boundary** — a `jr` write is authorized AND consumable. **Every "never silently discarded" / fail-loud
claim in this document MUST be discharged by a VP whose assertion is the downstream jr
authorization/execution outcome, not the upstream marker presence.** An emitter-only VP cannot detect
the Write→Bash seam gap (the exact class of defect P7-001 surfaced: a marker present in the store but
structurally unconsumable by the loop's own command). This rule is operationalized by the VP-HOOK-029
re-scope (§2 / §6) and governs all future fail-loud VP authoring for this cycle. (The O1–O3 standing
rules — enum-membership before routing, LLM-supplied routing fields cross-validated against
hook-computed invariants, consumer-consumption/ordering/trust-boundary coverage — remain in force per
architecture-delta D-DEC-012.)

**O5 standing rule — differential-vs-bash tokenization partition (ADV-F2-P9-009 / architecture-delta v1.12
D-DEC-012 O3 table row P9-009).** *Any hook that re-implements shell tokenization to make a security
decision MUST carry a differential-vs-bash vector partition covering all shell-quoting classes the
downstream CLI honors.* Whenever a hook parses a raw command string to derive a security predicate (rather
than delegating to a real shell parser), its tokenizer WILL diverge from bash for some quoting class unless
proven otherwise; each divergence is a potential false-allow (security bypass) or false-deny. The partition
MUST include: **(a)** a vector for each quoting class the CLI command surface uses — single-quoted,
double-quoted, backslash-escaped (`\"`/`\'`), and unquoted; **(b)** paired mutants demonstrating that
divergence from bash tokenization is detectable and killable by the VP. This is operationalized for the
`structural_label_check` control by **VP-HOOK-024** (the O5 compliance artifact): P8-002 covered the
bare-quote classes; P9-001 (v1.12) extends the partition to the backslash-escape class (SM-43). **Any future
change to `structural_label_check`, or any new CLI flag added to the monitored command surface, MUST extend
this partition (with a paired mutant) BEFORE the change is merged.** The `--label=VALUE` equals form is
explicitly SCOPED OUT of the partition because jr does not support it (`jr issue create --help`, confirmed
2026-07-21) — re-evaluate if jr adds equals-form support.

**O6 standing rule — inputs to a hook-computed invariant must be hook-recomputable / hook-cross-validated
(ADV-F2-P10-001 / architecture-delta v1.13 D-DEC-012 O3 table row P10-001).** *The inputs to a hook-computed
invariant MUST themselves be hook-recomputable or hook-cross-validated against a deterministic ground truth —
they must NOT be merely accepted from the LLM-written verdict.* An invariant computed exclusively from
LLM-supplied fields is **not** a deterministic enforcement surface: an attacker-influenced LLM can under-report
the input (e.g. `severity="LOW"` for a genuinely CRITICAL alert) so the hook computes the invariant from the
manipulated value and the control is silently circumvented. The remediation pattern is: **(a)** carry the raw
source data verbatim from the producing stage into the verdict as REQUIRED fields (`native_severity` field 16,
`sensor_family` field 17, carried from Stage-1 INGEST); **(b)** the hook re-runs the deterministic computation
(the D-DEC-013 `NORMALIZE_SEVERITY` table) and cross-checks the LLM-reported result; **(c)** mismatch → **deny**.
This is operationalized for the severity dimension by **VP-HOOK-030** (disposition-guard STEP 1a
`SEVERITY-MISMATCH`, the O6 compliance artifact).

**O6 residual annotation (ADV-F2-P11-001 CRITICAL — extended form).** The pass-10 framing that STEP 1a
relocated severity trust "from the LLM to the hook" and made the floor "un-bypassable" was OVERSTATED, and
this document's earlier "genuinely deterministic for severity / hook independently recomputes it from raw
sensor values" language is WITHDRAWN. `native_severity` (field 16) and `sensor_family` (field 17) are BOTH
written by the monitoring-loop LLM at Stage-1 INGEST and read verbatim by disposition-guard; the hook makes
**no prism call** (network-free, per BC-3.01.001 Invariant #2). **A hook re-computation from LLM-supplied
inputs is a CONSISTENCY CHECK, not ground-truth enforcement:** STEP 1a can only prove that `verdict.severity`
agrees with `NORMALIZE_SEVERITY(verdict.native_severity, verdict.sensor_family)` — it CANNOT detect an
adversarial LLM that supplies a false `native_severity`/`sensor_family` pair. True O6 (ground-truth
enforcement) for a network-free hook requires a **prism-signed severity field or hook-fetched prism data** —
both **ASM-008-DEFERRED** pre-production follow-ups. The residual is therefore SYMMETRIC across three
LLM-supplied hard-floor inputs, none of which is currently ground-truth-enforced:
(a) `native_severity`/`sensor_family` — STEP 1a is consistency-only (VP-HOOK-030 downgraded, P11-001);
(b) `asset_type` — enum-membership enforced NOW, `prism_asset_class` cross-validation ASM-008-DEFERRED;
(c) `scored_priority` (field 18) — the HIGH/CRIT hard-floor key as of P11-002, also LLM-supplied (assess-priority
is an LLM skill). **Any future hook invariant whose inputs are LLM-derived MUST apply O6** — either carry the
raw source + recompute (a consistency check, whose residual MUST be documented as ASM-008-class), or
cross-validate against a hook-observable ground truth (prism-signed / hook-fetched), with a paired mutant
proving an input-trust regression is detectable. No "un-bypassable" / "independently derived" claim may be
made for a network-free hook whose inputs are LLM-supplied.

**O7 standing rule — command_pattern / authorization-regex interpolation safety (ADV-F2-P12-007 /
architecture-delta v1.15 D-DEC-012 O3 table row P12-007).** *Any value interpolated into a `command_pattern`
(or any authorization regex a hook later evaluates with `[[ =~ ]]`) MUST be charset-validated to a fixed
grammar (fail-closed DENY on mismatch) AND regex-escaped as defense-in-depth BEFORE interpolation; every such
interpolation site MUST have a covering VP with a metacharacter-injection mutant.* A value concatenated into an
anchored authorization regex without charset-validation can alter the pattern's metacharacter structure —
`ticket_id='.*'` broadens `^jr … issue comment <ticket_id> ` to match ANY comment command, and
`ticket_id='SEC-1 |.*#'` injects an alternation that matches arbitrary commands (the SEC-009 unanchored/broadened-match
class). Control-char stripping (`tr -d '\000-\037'`, P4-010) is NOT sufficient — it does not strip the regex
metacharacters `. * + ? | ( ) [ ] ^ $ \`. The remediation pattern is: **(a)** validate the field against its fixed
Jira-key grammar (`ticket_id` ↦ `^[A-Z][A-Z0-9]+-[0-9]+$`; `jira_project_key` ↦ `^[A-Z][A-Z0-9]+$`) and emit a
`TICKET-ID-CHARSET-DENY` / `PROJECT-KEY-CHARSET-DENY` deny on mismatch; **(b)** regex-escape the validated value
before concatenation; **(c)** a VP asserting a metacharacter-laden value cannot broaden the pattern, with a paired
mutant that removes the validation. This is operationalized by **VP-HOOK-032** (the O7 compliance artifact for
`command_pattern` construction, sibling to VP-HOOK-024 = the O5 compliance artifact for `structural_label_check`).
**O7 interpolation audit (as of P12-001/P12-007 — the 5 `command_pattern` interpolation sites):** `ticket_id`
at STEP 6 comment, STEP 6 assign, and the markdown comment path (3 `ticket_id` sites); `jira_project_key` at
STEP 3 create-review and STEP 6 create (2 `jira_project_key` sites) — plus `ticket_id` at STEP 3 comment-review —
**ALL covered by VP-HOOK-032** (SM-48 for `ticket_id`, SM-49 for `jira_project_key`). `org_slug` is **NOT**
interpolated into any `command_pattern` (it appears only in audit-log entries where the P4-010 control-char-strip
is sufficient) — **audit-only / SAFE**, so O7 does NOT require a `command_pattern` VP for `org_slug` unless a
future change introduces it into pattern construction. **Any future interpolation site added after this pass
requires a new O7 VP entry (with a paired metacharacter-injection mutant) BEFORE the feature is considered
architecturally complete.**

---

## 1. Namespace Adjudication (independent re-verification)

The F1 audit reported occupancy `VP-SKILL 001–049`, `VP-HOOK ≤023`. I re-verified independently
by globbing every BC in `.factory/phase-0-ingestion/behavioral-contracts/` and mapping each
new VP ID to its owning file. **v1.1 added VP-SKILL-064 (ADV-F2-008) and VP-SKILL-065
(ADV-F2-019). v1.2 added VP-SKILL-066/067/068 + VP-HOOK-027 + SM-26/27/28. v1.3 (this edit)
re-verified occupancy independently against the LIVE BCs by `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'`
across every BC — max in-BC `VP-SKILL` = 070 (BC-5.01.001 references VP-SKILL-069 PROPOSED;
BC-4.05.001 references VP-SKILL-070 PROPOSED), max `VP-HOOK` = 027, `SM` catalog max = 28. v1.3
FINALIZES the two already-PROPOSED ids (VP-SKILL-069 in BC-5.01.001, VP-SKILL-070 in BC-4.05.001 —
exactly as the BCs cite them) and appends VP-SKILL-071 (next free 071, confirmed absent repo-wide
outside architecture-delta) + VP-HOOK-028 (next free 028, confirmed absent repo-wide) + SM-29/30.
VP-SKILL is now occupied 001–071, VP-HOOK 024–028, SM 9–30; ZERO collisions confirmed
independently.**

**v1.5 (this edit) re-verified occupancy independently against the LIVE pass-4 BCs by
`grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` across every BC — max in-BC `VP-SKILL` = 071, max
`VP-HOOK` = 028, `SM` catalog max = 30. `VP-SKILL-072`, `VP-HOOK-029`, and `SM-31..SM-35` are
confirmed absent from every BC (VP-HOOK-029 appears ONLY as a `(proposed)` forward-reference in
architecture-delta.md v1.6 §8.11 item 6 — no owning BC yet). v1.5 appends the next-free ids
**VP-HOOK-029** (P1 fail-loud, D-DEC-012) + **VP-SKILL-072** (first-run 24h lookback, BC-10.01.001
Inv#13) + **SM-31..SM-35**. VP-SKILL is now occupied 001–072, VP-HOOK 024–029, SM 9–35; ZERO
collisions confirmed independently:**

| VP ID | Owning BC(s) | Pre-existing collision? | Verdict |
|-------|--------------|-------------------------|---------|
| VP-SKILL-050 | BC-10.01.001 | none (max pre-F1 = 049) | FINALIZED |
| VP-SKILL-051 | BC-6.01.001 | none | FINALIZED |
| VP-SKILL-052 / 053 | BC-6.01.003 | none | ACCEPTED (**VP-SKILL-053 REPURPOSED pass-14 / P14-005: was AD-017 credential-provisioning → now idempotent-directory-creation — see §2 row; original AD-017 coverage RESTORED via VP-SKILL-077 (BC-6.01.003 Inv#1/EC-008), v1.18 disentanglement**) |
| VP-SKILL-054 / 055 | BC-6.01.004 | none | ACCEPTED |
| VP-SKILL-056 / 057 | BC-8.02.001 | none | ACCEPTED (**VP-SKILL-057 REPURPOSED pass-9 / P9-005: was sensor-metrics org_slug scoping → now sensor-metrics naming-compliance (D-DEC-006) — see §2 row; org_slug moot under the D-DEC-005 / P9-005 sensor-health carve-out**) |
| VP-SKILL-058 | BC-9.01.001 | none | ACCEPTED |
| **VP-SKILL-059** *(UPGRADED v1.13)* | BC-9.01.001 (Iron Law / org_slug — P10-005) | none | **UPGRADED — structural→behavioral** (scan-threats org_slug: was structural-only SKILL.md prose; v1.13 adds a prism-DTU multi-org behavioral fixture + a static assertion that every query in `data/threat-hunt-queries.md` carries an org_slug clause — P10-005) |
| VP-SKILL-060 / 061 / 062 / 063 | BC-10.01.001 | none | ACCEPTED |
| **VP-SKILL-064** *(NEW v1.1)* | BC-10.01.001 (Inv#1 — PROPOSED, ADV-F2-008) | none (max prior = 063) | **FINALIZED** (org_slug scoping) |
| **VP-SKILL-065** *(NEW v1.1; RE-SCOPED v1.9)* | BC-10.01.001 (Inv#11 — process-gap, ADV-F2-019; carve-out ADV-F2-P6-003) | none (next free = 065) | **RE-SCOPED — PROPOSED** (autonomy_enabled kill switch, narrowed v1.9 to zero REGULAR jr writes; create-review/comment-review escalation writes for genuine hard-floor verdicts EXEMPT per D-DEC-012 Option A via the kill-switch-exempt STEP 3 correct-label review path — carve-out UNCHANGED at v1.10, the regular-vs-review distinction is unaffected by the STEP-4 deny-the-Write redesign; PROPOSED pending vector-set adjudication in F6) |
| **VP-SKILL-066** *(NEW v1.2)* | BC-4.02.001 (Inv#4 — ADV-F2-P2-009a) | none (max prior = 065) | **FINALIZED** (never-auto-reopen on the update-jira path) |
| **VP-SKILL-067** *(NEW v1.2)* | BC-4.02.001 (Inv#5 — ADV-F2-P2-009b) | none | **FINALIZED** (SLA surface-never-assume) |
| **VP-SKILL-068** *(NEW v1.2)* | BC-10.01.001 (Inv#8 dedup / D-DEC-002 — ADV-F2-P2-009c) | none (next free = 068) | **FINALIZED** (grace-window + Jira-first dedup) |
| **VP-SKILL-069** *(NEW v1.3)* | BC-5.01.001 (Inv#8 — ADV-F2-P3-004); already PROPOSED-referenced in BC-5.01.001 v1.8 | none (BC cites this exact id) | **FINALIZED** (investigate-event PrismQL org_slug scoping) |
| **VP-SKILL-070** *(NEW v1.3)* | BC-4.05.001 (Inv#4 — ADV-F2-P3-004); already PROPOSED-referenced in BC-4.05.001 v1.3 | none (BC cites this exact id) | **FINALIZED** (assess-priority PrismQL org_slug scoping) |
| **VP-SKILL-071** *(NEW v1.3)* | BC-4.05.001 (PC#6 / D-DEC-011 — ADV-F2-P3-008) | none (next free = 071) | **FINALIZED** (assess-priority confidence float→enum consistency) |
| **VP-HOOK-028** *(NEW v1.3)* | BC-10.01.001 (Stage-7 verdict-path PC#8 — ADV-F2-P3-005); enforced by BC-3.03.001 (fast-path) + BC-3.01.001 (consume) | none (max prior = 027) | **FINALIZED** (verdict-path reachability) |
| **VP-HOOK-027** *(NEW v1.2)* | BC-10.01.001 (Inv#14 — ADV-F2-P2-001/P2-014); enforced by BC-3.03.001 (emit) + BC-3.01.001 (consume) | none (max prior = 026) | **FINALIZED** (P1 cross-hook stage-order document-before-action) |
| **VP-SKILL-072** *(NEW v1.5)* | BC-10.01.001 (Inv#13 first-run 24h lookback / D-DEC-002 — ADV-F2-P4-012) | none (next free = 072) | **FINALIZED** (first-run 24h lookback correctness; distinct from VP-SKILL-050 monotonicity) |
| **VP-SKILL-073** *(NEW v1.9)* | BC-10.01.001 (Stage-1 late-event fail-loud / D-DEC-002 — ADV-F2-P6-007); architecture-delta body §660/§3541 already commit this exact id | none (next free = 073) | **PROPOSED** (late-event drop detection: `_time < watermark − GRACE` → `LATE_EVENT_DETECTED` audit, event still processed) |
| **VP-SKILL-074** *(NEW v1.9)* | BC-10.01.001 (Stage-1/Stage-5 severity normalization / D-DEC-013 — ADV-F2-P6-005) | **none — NAMESPACE CORRECTION:** architect §8.15 item 3 proposed "VP-SKILL-072", but 072 is OCCUPIED (first-run 24h lookback); next free after 073 = **074** | **PROPOSED** (severity normalization correctness; NORMALIZE_SEVERITY per sensor family) |
| **VP-HOOK-029** *(NEW v1.5; RE-SCOPED v1.8/v1.9/**v1.10**; **re-FINALIZED v1.10**)* | BC-10.01.001 (D-DEC-012 fail-loud, Inv#10 narrowed + **STEP 4 DENY-THE-WRITE** — ADV-F2-P5-001/P6-002/**P7-001/P7-004**); enforced by BC-3.03.001 (STEP 4 deny + UNDER-LABEL-DENIED audit) + BC-3.01.001 (consume create-review/comment-review at STEP 6a — the CONSUMER-BOUNDARY authorization outcome) | none (max prior = 028; re-scope, not new ID) | **FINALIZED** (P0 end-to-end **consumer-boundary** fail-loud invariant per the O4 standing rule; lifecycle re-marked PROPOSED then re-FINALIZED v1.10 pending the deny-path vector set — architecture-delta §8.17 item 1 / P7-001/P7-004; the v1.9 STEP-4 upgrade-marker vectors are RETIRED; **v1.11 EXTENDED (stays FINALIZED P0) with the P8-001 STEP-3 `HARD-FLOOR-UNBINDABLE` unbindable-deny vectors for the correctly-labeled + null-binding sub-case — additive to §8.17, not a re-scope; paired mutant SM-41**; **v1.12 EXTENDED (stays FINALIZED P0) with the P9-007 dedup-before-fallback test-only vector — the STEP-3 comment-review→create-review fallback hint requires a §3.4 dedup re-run confirming no open BLIND-SPOT/REVIEW-REQUIRED ticket before switching (D-DEC-004); no mutant, deny-reason-text only**; **v1.13 EXTENDED (stays FINALIZED P0) with the P10-003 MARKER-WRITE-FAILED review-path fail-closed vector — a WRITE_MARKER failure on the STEP-3 create-review/comment-review hard-floor review path DENIES (MARKER-WRITE-FAILED audit), NEVER allow-without-marker; the regular path retains allow-without-marker (require-review's no-marker deny is the human gate); paired mutant SM-45**) |
| VP-HOOK-024 | BC-3.01.001 | none (max pre-F1 = 023) | FINALIZED (ticket-bound + create/assign scopes, schema v2.0, iterative-consume; **v1.5: create-pattern injection-safety**; **v1.9: STEP 6a anti-fungibility, SM-36/37**; **v1.10: step-6a structural false-deny prevention, SM-40**; **v1.11: P8-002 quote-aware tokenizer — false-deny vector updated to the QUOTED form, paired mutant SM-42**; **v1.12: P9-001 escaped-quote differential-vs-bash partition (O5) — 1a security / 1b false-deny / partition-2 UNQUOTED `\'`, paired mutant SM-43; equals-form scoped OUT; this VP is the O5 compliance artifact for `structural_label_check`**) |
| VP-HOOK-025 | BC-10.01.001 (defines) + BC-3.03.001 (enforces) | none — shared reference, not a duplicate assignment | FINALIZED (**18 fields** — 12 ICD-203 + severity[13]/asset_type[14]/ticket_action_type[15]/**native_severity[16]/sensor_family[17]/scored_priority[18]** (P10-001/P11-002); **v1.5: validate_enums() membership legs; v1.13: fields 16/17 presence + sensor_family enum; v1.14: field-18 `scored_priority` presence + enum ∈{CRIT,HIGH,MED,LOW} (P11-002); v1.15: fast-path SEVERITY_TO_SCORED_PRIORITY_MAP enum vectors — a mapped CRIT/MED passes validate_enums, a raw unmapped CRITICAL/MEDIUM DENIES (P12-003a)**) |
| VP-HOOK-026 | BC-10.01.001 | none | FINALIZED (hard-floor keyed on **scored_priority (field 18, P11-002)**/asset_type; **v1.5: create-review/comment-review + kill-switch exemptions, autonomy_enabled determinism**; **v1.8: STEP 3 exemption GATED on hard_floor_applies() + over-label legs, SM-32b**; **v1.14: HIGH/CRIT floor keys on `verdict.scored_priority` (NOT recomputed severity) per brief §3.9 — detector-LOW + scored-CRIT still trips the floor; paired mutant SM-46 (P11-002); ~~v1.15: known-FP floor EXEMPTION (P12-003b)~~ **RETIRED v1.19 (P17-001 / D-019): there is NO high-sev exemption** — the v1.15 'known-FP EXEMPT from the scored_priority floor → auto-close even at high native severity' vector is a dead/incorrect assertion (`hard_floor_applies()` fires unconditionally on scored_priority ∈ {HIGH,CRIT}; disposition-guard has no forgery-proof known-FP signal). **v1.19 D-019 vectors: (a) LOW/MED-native known-FP (scored_priority ∈ {LOW,MED}) + healthy sensor + non-forbidden technique + disposition=FP → NO floor → auto-close (comment via regular path); (b) HIGH/CRIT-native known-FP (scored_priority ∈ {HIGH,CRIT}) + store match + disposition=FP → hard_floor_applies() FIRES → DENY-THE-WRITE (HARD-FLOOR-UNDER-LABEL) → routes to comment-review (human review), NOT auto-close — the deterministic gate's existing behavior. Paired mutant SM-56 (hard_floor_applies() adds a known-FP bypass branch → high-sev known-FP auto-closes) killed by vector (b). No floor-exemption VP minted (arch-delta §8.27 hold-note RESOLVED by D-019).**) |
| VP-HOOK-028 | BC-10.01.001 (Stage-7 PC#8) + BC-3.03.001 (dispatch) | none | FINALIZED (verdict-path reachability; **v1.5: JSON-first canonical-path dispatch**; **v1.19 (P17-002): property (1) REWRITTEN to the JSON-first fail-closed residual boundary — a Write with NEITHER .json ext NOR JSON-parseable content NOR `*investigation-*.md` glob → fast-path-allow → Stage-8 denied; the dead 'non-`verdict`-substring path → fast-path-allow' premise is retired (false under JSON-first); property (1)/(2) self-contradiction resolved; VP NOT retired**) |
| **VP-HOOK-030** *(NEW v1.13, **P0**; DOWNGRADED v1.14 — consistency-only, P11-001)* | BC-3.03.001 (disposition-guard STEP 1a — D-DEC-008/D-DEC-013 SEVERITY-MISMATCH consistency check) + BC-10.01.001 (18-field schema, fields 16/17 — P10-001/P11-002) | none (max prior VP-HOOK = 029; `grep -rn` confirmed absent repo-wide) | **FINALIZED (consistency VP)** (STEP 1a asserts `verdict.severity` is CONSISTENT with `verdict.native_severity` per the D-DEC-013 table — NOT ground-truth enforcement; native_severity + sensor_family are LLM-supplied, genuine severity ground-truth is **ASM-008-DEFERRED symmetric with asset_type**; SEVERITY-MISMATCH deny on recomputed≠verdict.severity retained; paired mutant SM-44) |
| **VP-HOOK-031** *(NEW v1.14, **P0**; ADV-F2-P11-004 MAJOR; UPDATED v1.14→v1.15 four-guarantee scope, ADV-F2-P12-002 CRITICAL; **UPDATED v1.16 — MARKDOWN_COMMENT_PATH ELIMINATED, ADV-F2-P13-001 CRITICAL + parse-grammar vectors ADV-F2-P13-003 MAJOR**)* | BC-3.03.001 (disposition-guard separate human-comment marker path — P11-004; redesigned P12-002; MARKDOWN_COMMENT_PATH eliminated P13-001); consumed by BC-5.01.001 (investigate-event) + BC-4.02.001 (update-jira human comment) | none (max prior VP-HOOK = 032; `grep -rn` confirmed absent repo-wide; UPDATED in place, no new id) | **FINALIZED** (the 12-field investigation-markdown path does NOT enter the verdict emitter; **v1.16 (P13-001) — NO disposition yields an autonomous `["comment"]` marker (MARKDOWN_COMMENT_PATH ELIMINATED):** (a) `autonomy_enabled` absent/≠true → allow-without-marker (kill switch); (b) after the markdown-evaluable floors pass — **`disposition=FP` → allow-without-marker** (Write succeeds, NO Jira action, NO comment marker; analyst surfaces an FP comment via the review path or the 18-field verdict flow); **non-FP (TP/BTP/Indeterminate) / PARSE_FAIL → create-review/comment-review (review marker, EXEMPT from the kill switch)**; (c) **REWRITTEN — NO disposition yields an autonomous `["comment"]` marker from the markdown path** (the v1.15 'disposition=FP + floors pass → comment marker' guarantee is ELIMINATED; the hook cannot evaluate scored_priority/asset_type from a 12-field markdown, and no known-FP store cross-check applies — P13-001); (d) `ticket_id` charset-validated on the markdown path (P12-001) — NOT validate_enums/STEP-1a; **strict parse grammar (P13-003): `parse_disposition_from_markdown` reads ONLY the canonical `Disposition` heading value against the {TP,FP,BTP,Indeterminate}(+long-form) allowlist, PARSE_FAIL (→ review, never allow-without-marker) on ambiguous/negated/multi-valued/embedded-in-code-fence; `parse_autonomy_enabled_from_markdown` reads ONLY a dedicated structured field (token in a code fence/evidence block → false)**; paired mutants SM-47 (markdown-into-verdict-emitter, P11-004), SM-50 (remove kill-switch gate — killed by the FP-kill-switch vector), SM-51 (remove the non-FP→review routing rule → TP/BTP wrongly gets allow-without-marker; killed by the TP→review vector — VALID under P13-001), **SM-52 (revert the elimination — FP markdown issues a `["comment"]` marker; killed by the FP→allow-without-marker vector)**, **SM-53 (disposition parse uses a full-document substring scan; killed by the FP-in-body/code-fence vector, P13-003)**) |
| **VP-HOOK-032** *(NEW v1.15, **P0**; ADV-F2-P12-001 CRITICAL / P12-007 OBS — the O7 compliance artifact)* | BC-3.03.001 (disposition-guard `command_pattern` charset-validation at all 5 interpolation sites + markdown path — P12-001); consumed by BC-3.01.001 (require-review evaluates the anchored `command_pattern` with `[[ =~ ]]`) | none (max prior VP-HOOK = 031; `grep -rn 'VP-HOOK-032'` confirmed absent repo-wide incl. architecture-delta) | **FINALIZED** (a metacharacter-laden `ticket_id` (`.*`, `SEC-1 \|.*#`) / `jira_project_key` is DENIED — `TICKET-ID-CHARSET-DENY` / `PROJECT-KEY-CHARSET-DENY` — BEFORE `command_pattern` construction at ALL 5 sites (STEP 6 comment/assign, STEP 3 comment-review, STEP 3 create-review, STEP 6 create) plus the markdown comment path; valid values pass charset-validation (`ticket_id` ↦ `^[A-Z][A-Z0-9]+-[0-9]+$`, `jira_project_key` ↦ `^[A-Z][A-Z0-9]+$`) and anchor correctly; regex-escape is defense-in-depth; the O7 standing-rule §0 compliance artifact; paired mutants SM-48 (remove ticket_id validation → `.*` authorizes an unrelated comment), SM-49 (remove jira_project_key validation)) |
| **VP-SKILL-075** *(NEW v1.13, **P1**)* | run-monitoring-loop.sh cron wrapper (BC-10.01.001 PC#7 operator-boundary / architecture-delta Gate 2 — P10-002) | none (max prior VP-SKILL = 074; `grep -rn` confirmed absent repo-wide) | **PROPOSED** (operator-boundary cron-exit-nonzero on audit.log fail-loud codes; **Gate-1 `.permission_denials` leg is ASM-015-BLOCKED** — see §2/§6; Gate-2 audit.log legs testable now) |
| **VP-SKILL-076** *(NEW v1.17, **P1**; ADV-F2-P14-002 MAJOR — no-covering-VP)* | BC-6.01.001 (activate — PC#12/EC-014) + BC-6.01.003 (onboard-customer — Inv#6/EC-010) setup-time jira_project_key charset validation | none (max prior VP-SKILL = 075; `grep -rn 'VP-SKILL-076' .factory/` confirmed absent repo-wide incl. architecture-delta and the target file) | **PROPOSED** (SETUP-TIME preventive charset gate — sibling of VP-SKILL-051 activate version-gate; DISTINCT from VP-HOOK-032 which covers the RUNTIME command_pattern PROJECT-KEY-CHARSET-DENY. **VP-SKILL namespace justification (VP-SKILL not VP-HOOK):** the enforcement surface is the activate + onboard-customer SKILL setup helpers (`prism-version-check.sh`-sibling helper scripts), NOT a PreToolUse hook — so it takes VP-SKILL, matching the taxonomy where VP-HOOK is reserved for require-review.sh / disposition-guard.sh enforcement hooks; paired mutant SM-54) |
| **VP-SKILL-077** *(NEW v1.18, **P1**; ADV-F2-P14-005 MINOR — VP-repurposing orphan restoration)* | BC-6.01.003 (onboard-customer — Inv#1 / EC-008) AD-017 credential-decline | none (max prior VP-SKILL = 076; `grep -rn 'VP-SKILL-077' .factory/` confirmed absent repo-wide incl. architecture-delta and the target file) | **PROPOSED** (onboard-customer AD-017 credential-decline — the conversation never asks for or accepts a secret; only piped-stdin `echo \| prism credential set` documented. MIRRORS VP-SKILL-054 (onboard-sensor AD-017) applied to the onboard-customer credential-decline path; RESTORES the AD-017 coverage orphaned when VP-SKILL-053 was repurposed (P14-005). DISTINCT from VP-SKILL-076 (setup-time jira_project_key charset gate — a wholly separate behavior; the v1.18 disentanglement splits these two). **NO paired mutant (SM-55 SKIPPED):** B-STR structural-presence on SKILL.md content — no runtime accept/decline control-flow branch to mutate, exactly as sibling VP-SKILL-054 carries no SM-N mutant; a SKILL.md prose edit is not an SM-N control-flow mutant, so none is warranted at spec level) |

**v1.9 (this edit) re-verified occupancy independently against the LIVE pass-6 BCs and the
architecture-delta v1.9 body by `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` and `grep -rhoE 'SM-[0-9]+'`
across `.factory/`. Two collisions in the architect's §8.15 proposal were caught and corrected —
the FV owns the VP/SM namespace and must never collide:**
1. **Severity normalization — architect §8.15 item 3 said "VP-SKILL-072", but VP-SKILL-072 is
   OCCUPIED** (first-run 24h lookback, FINALIZED v1.5 / BC-10.01.001 v1.9 Inv#13). The architect's
   own body (§660, §3541) commits **VP-SKILL-073** to late-event detection, so severity normalization
   takes the next free id **VP-SKILL-074**. Late-event detection stays **VP-SKILL-073** (as the
   architecture body already cites). Correction noted; no existing VP disturbed.
2. **Consumer anti-fungibility mutants — architect §8.15 item 5 (and the same-named consumer mutants)
   said "SM-33"/"SM-34", but SM-33 (autonomy_enabled-clause-removed) and SM-34 (dispatch-order-inverted)
   are OCCUPIED pass-4 sentinels** (killed by VP-HOOK-026 / VP-HOOK-028 respectively). The consumer
   STEP 6a anti-fungibility mutants take the next free ids **SM-36** (remove the review-label check for
   review markers) and **SM-37** (remove the reverse check for regular markers). **SM-32-ext**
   (revert the STEP 4/5 ordering) is a safe SM-32-family sub-variant (no top-level collision).
VP-SKILL is now occupied 001–074, VP-HOOK 024–029, SM 9–37 (SM-32 = 32a+32b+32-ext); ZERO collisions
confirmed independently.

**v1.10 (this edit — pass-7) re-verified occupancy independently before allocating any new SM id
(Lesson 8): `grep -rhoE 'SM-[0-9]+' .factory/` returns max real = SM-37 (SM-2026 is a DATE false-positive
inside BC-6.01.001 frontmatter, not a mutant), and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'` returns
VP-SKILL max 074, VP-HOOK max 029. The architect's §8.17 placeholders SM-NEW-A / SM-NEW-B take the next
free ids **SM-38 / SM-39**; the step-6a paired mutant takes **SM-40**. No new VP id is minted (VP-HOOK-029
re-scoped in place; VP-HOOK-024 / VP-SKILL-074 extended). SM is now occupied 9–40 (SM-32 = 32a+32b+32-ext;
SM-32a re-targeted, SM-32-ext kill vector re-worded — neither changes the id set); VP-SKILL 001–074,
VP-HOOK 024–029. ZERO collisions confirmed independently.**

**v1.11 (this edit — pass-8) re-verified occupancy independently before allocating any new SM id
(Lesson 8): `grep -rhoE 'SM-[0-9]+' .factory/` returns max real = **SM-40** (SM-2026 is still the DATE
false-positive inside BC-6.01.001 frontmatter, not a mutant), and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'`
returns VP-SKILL max 074, VP-HOOK max 029. The architect's §8.19 placeholders SM-P8-A / SM-P8-B take the
next free ids **SM-41 / SM-42** (both confirmed absent repo-wide, including in the target file, before
allocation). No new VP id is minted — VP-HOOK-029 is EXTENDED in place with the P8-001 unbindable-deny
vectors (it stays FINALIZED P0; additive to the §8.17 deny-path set, not a re-scope), and VP-HOOK-024 is
EXTENDED with the P8-002 quote-aware vector/mutant. SM is now occupied 9–42 (SM-32 = 32a+32b+32-ext);
VP-SKILL 001–074, VP-HOOK 024–029. ZERO collisions confirmed independently.**

**v1.12 (this edit — pass-9) re-verified occupancy independently before allocating any new SM id
(Lesson 8): `grep -rhoE 'SM-[0-9]+' .factory/` returns max real = **SM-42** (SM-2026 is still the DATE
false-positive inside BC-6.01.001 frontmatter, not a mutant), and `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}'`
returns VP-SKILL max 074, VP-HOOK max 029. The architect's §8.21 placeholder SM-P9-A takes the next free
id **SM-43** (`grep -rn 'SM-43' .factory/` returned no match before allocation — confirmed absent
repo-wide, including in the target file). No new VP id is minted — VP-HOOK-024 is EXTENDED in place with
the P9-001 escaped-quote differential-vs-bash partition (+SM-43), and VP-HOOK-029 is EXTENDED with the
P9-007 dedup-gate test-only vector (no mutant — architect §8.21 item 2). SM is now occupied 9–43 (SM-32 =
32a+32b+32-ext); VP-SKILL 001–074, VP-HOOK 024–029. ZERO collisions confirmed independently.**

**v1.13 (this edit — pass-10) re-verified occupancy independently before allocating any new VP/SM id
(Lesson 8): `grep -rhoE 'SM-[0-9]+' .factory/` returns max real = **SM-43** (SM-2026 is still the DATE
false-positive inside BC-6.01.001 frontmatter, not a mutant); `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}' .factory/`
returns VP-SKILL max 074, VP-HOOK max 029. The architect used placeholders **SM-P10-A / SM-P10-B** and
UNALLOCATED VP placeholders (§8.23) — FV assigns the real ids. `grep -rn 'SM-44\|SM-45\|VP-HOOK-030\|VP-SKILL-075' .factory/`
returned NO match before allocation (confirmed absent repo-wide, INCLUDING architecture-delta and the target
file). Allocations: **SM-P10-A → SM-44** (next free after SM-43), **SM-P10-B → SM-45**; **VP-HOOK-030** (next
free VP-HOOK after 029 — STEP 1a SEVERITY-MISMATCH, P10-001), **VP-SKILL-075** (next free VP-SKILL after 074 —
operator-boundary cron-exit, P10-002). VP-HOOK-029 is EXTENDED in place (P10-003 marker-write fail-closed,
+SM-45), VP-SKILL-059 UPGRADED in place (P10-005 structural→behavioral), VP-SKILL-064 RENAMED/extended in place
(P10-006/P10-007). No existing VP/SM renumbered. **VP-HOOK-030 namespace justification (VP-HOOK not VP-SKILL):**
STEP 1a SEVERITY-MISMATCH is a deterministic disposition-guard ENFORCEMENT surface (an ALLOW/DENY decision on
the verdict Write), a sibling of VP-HOOK-025 (enum-membership) and VP-HOOK-026 (hard-floor) — NOT folded into
VP-HOOK-029 (whose scope is the consumer-boundary fail-loud invariant), because STEP 1a is a distinct O6
trust-basis mechanism, not a fail-loud/under-label branch. **VP-SKILL-075 namespace justification (VP-SKILL not
VP-HOOK):** the operator-boundary signal is the exit code of the `run-monitoring-loop.sh` cron WRAPPER — a
helper script, NOT a PreToolUse hook — so it takes VP-SKILL (sibling to VP-SKILL-051 prism-version-check.sh),
matching the taxonomy where VP-HOOK is reserved for require-review.sh / disposition-guard.sh enforcement hooks.
SM is now occupied 9–45 (SM-32 = 32a+32b+32-ext); VP-SKILL 001–075, VP-HOOK 024–030. ZERO collisions confirmed
independently.**

**v1.14 (this edit — pass-11) re-verified occupancy independently before allocating any new VP/SM id
(Lesson 8): `grep -rhoE 'SM-[0-9]+' .factory/` returns max real = **SM-45** (SM-2026 is still the DATE
false-positive inside BC-6.01.001 frontmatter, not a mutant); `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}' .factory/`
returns VP-SKILL max 075, VP-HOOK max 030. `grep -rn 'SM-46\|SM-47\|VP-HOOK-031' .factory/` returned NO match
before allocation (confirmed absent repo-wide, INCLUDING architecture-delta and the target file). Allocations:
**SM-46 / SM-47** (next free after SM-45 — SM-46 = re-key the HIGH/CRIT floor to recomputed severity instead of
`scored_priority` (P11-002); SM-47 = route the 12-field investigation-markdown into the verdict emitter (P11-004));
**VP-HOOK-031** (next free VP-HOOK after 030 — the separate human-comment investigation-markdown marker path, P11-004).
VP-HOOK-030 is DOWNGRADED in place (P11-001 consistency-only reframe — no new id), VP-HOOK-025 EXTENDED in place
(field-18 `scored_priority` presence/enum), VP-HOOK-026 EXTENDED in place (scored_priority HIGH/CRIT floor +SM-46).
No existing VP/SM renumbered. **VP-HOOK-031 namespace justification (VP-HOOK not VP-SKILL):** the human-comment
marker path is a disposition-guard ENFORCEMENT surface (an ALLOW/DENY decision on the investigation-markdown
Write + a comment-scoped marker emission), a sibling of VP-HOOK-025 (enum) / VP-HOOK-026 (hard-floor) / VP-HOOK-030
(STEP 1a) on the disposition-guard hook — NOT a monitoring-loop SKILL property. SM is now occupied 9–47 (SM-32 =
32a+32b+32-ext); VP-SKILL 001–075, VP-HOOK 024–031. ZERO collisions confirmed independently.**

**v1.15 (this edit — pass-12) re-verified occupancy independently before allocating any new VP/SM id
(Lesson 8): `grep -rhoE 'SM-[0-9]+' .factory/` returns max real = SM-47 (SM-2026 is still the DATE
false-positive inside BC-6.01.001 frontmatter, not a mutant); `grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}' .factory/`
returns VP-SKILL max 075, VP-HOOK max 031. The architect used placeholders SM-P12-A / SM-P12-B / SM-P12-C /
SM-P12-D and an UNALLOCATED VP placeholder (§8.27) — FV assigns the real ids. `grep -rn 'SM-48\|SM-49\|SM-50\|SM-51\|VP-HOOK-032' .factory/`
returned NO match before allocation (confirmed absent repo-wide, INCLUDING architecture-delta and the target
file). Allocations: **SM-P12-A → SM-48** (remove ticket_id charset-validation from all paths → `.*` ticket_id
authorizes an unrelated comment command, P12-001), **SM-P12-B → SM-49** (remove jira_project_key charset-validation
on create/create-review, P12-007), **SM-P12-C → SM-50** (remove the markdown-path `autonomy_enabled` kill-switch
gate, P12-002), **SM-P12-D → SM-51** (remove the markdown disposition!=FP route-to-review rule → a TP markdown
gets an autonomous comment marker, P12-002); NEW **VP-HOOK-032** (next-free VP-HOOK after 031 — the O7
`command_pattern` interpolation-safety property, P12-001/P12-007). VP-HOOK-031 is UPDATED in place (P12-002
four-guarantee scope — no new id, +SM-50/SM-51), VP-HOOK-025 EXTENDED in place (fast-path SEVERITY_TO_SCORED_PRIORITY_MAP
enum vectors, P12-003a), VP-HOOK-026 EXTENDED in place (known-FP floor exemption, P12-003b). No existing VP/SM
renumbered. **VP-HOOK-032 namespace justification (VP-HOOK not VP-SKILL):** charset-validation BEFORE
`command_pattern` construction is a disposition-guard emit-time ENFORCEMENT surface (an ALLOW/DENY decision on the
verdict/markdown Write — `TICKET-ID-CHARSET-DENY`/`PROJECT-KEY-CHARSET-DENY`), a sibling of VP-HOOK-024
(consumer marker validation / anchored `command_pattern` match), VP-HOOK-025 (enum), VP-HOOK-026 (hard-floor),
VP-HOOK-030 (STEP 1a), VP-HOOK-031 (markdown path) on the marker family — NOT a monitoring-loop SKILL property.
It is the O7 compliance artifact, exactly as VP-HOOK-024 is the O5 compliance artifact for `structural_label_check`.
SM is now occupied 9–51 (SM-32 = 32a+32b+32-ext); VP-SKILL 001–075, VP-HOOK 024–032. ZERO collisions confirmed
independently.**

**v1.16 (this edit — pass-13) re-verified occupancy independently before allocating any new SM id
(Lesson 8): `grep -rhoE 'SM-[0-9]+' .factory/` returns max real = **SM-51** (SM-2026 is the DATE false-positive
inside BC-6.01.001 frontmatter, and SM-456 is the 'PRISM-456' charset EXAMPLE in BC-3.03.001 — neither a mutant);
`grep -rhoE 'VP-(SKILL|HOOK)-[0-9]{3}' .factory/` returns VP-SKILL max 075, VP-HOOK max 032. The architect used
placeholder SM-P13-A (§8.29) — FV assigns the real id. `grep -rn 'SM-52\|SM-53' .factory/` returned NO match before
allocation (confirmed absent repo-wide, INCLUDING architecture-delta and the target file). Allocations:
**SM-P13-A → SM-52** (revert P13-001 — the markdown FP branch issues an autonomous `["comment"]` marker; killed by
the FP→allow-without-marker vector) and **SM-53** (NEW — disposition parse uses a full-document substring scan
instead of the canonical-heading-anchored parse; killed by the FP-in-code-fence vector, P13-003). **NO new VP id:**
VP-HOOK-031 is UPDATED in place (guarantee (c) rewrite — MARKDOWN_COMMENT_PATH eliminated, P13-001 — + the
P13-003 strict parse-grammar adversarial vectors). No existing VP/SM renumbered. **SM-50/SM-51 reconciliation
(P13-001):** SM-50 (markdown kill-switch gate removal) and SM-51 (markdown non-FP→route-to-review-rule removal — the
former SM-P12-D) BOTH remain VALID; their killer vectors shift under P13-001 (SM-50 killed by the non-FP
`autonomy=false`→allow-without-marker vector; SM-51 killed by the TP→review vector — a removed routing rule now sends a
TP to allow-without-marker rather than a comment marker, since the comment path is gone). SM-52 is the NEW P13-001
FP-branch mutant and is DISTINCT from SM-51 (SM-51 = non-FP→review branch; SM-52 = FP→allow-without-marker branch).
SM is now occupied 9–53 (SM-32 = 32a+32b+32-ext); VP-SKILL 001–075, VP-HOOK 024–032. ZERO collisions confirmed
independently.**

**v1.17 (this edit — pass-14) re-verified occupancy independently before allocating any new VP/SM id
(Lesson 8): `grep -rhoE 'VP-SKILL-[0-9]+' .factory/` returns VP-SKILL max **075**, `grep -rhoE 'VP-HOOK-[0-9]+' .factory/`
returns VP-HOOK max **032** (range 024–032, unchanged this pass), and `grep -rhoE 'SM-[0-9]+' .factory/` returns max
real = **SM-53** (SM-2026 is the DATE false-positive inside BC-6.01.001 frontmatter, SM-456 is the 'PRISM-456' charset
EXAMPLE in BC-3.03.001 — neither a mutant). `grep -rn 'VP-SKILL-076\|SM-54' .factory/` returned NO match before
allocation (confirmed absent repo-wide, INCLUDING architecture-delta and the target file). Allocations:
**VP-SKILL-076** (next-free VP-SKILL after 075 — the P14-002 setup-time jira_project_key charset-validation VP, sibling
of VP-SKILL-051) and **SM-54** (next-free SM after SM-53 — the paired setup-time-charset-validation-removed mutant).
No existing VP/SM renumbered; VP-HOOK-032 max unchanged; no re-scope. SM is now occupied 9–**54** (SM-32 =
32a+32b+32-ext); VP-SKILL 001–**076**, VP-HOOK 024–032. ZERO collisions confirmed independently. Collisions avoided:
`grep` confirmed VP-SKILL-076 and SM-54 both free before minting (the architect's §8.30.6 note left VP-SKILL-??? for FV
to verify — FV assigns the real next-free id).**

**v1.18 (this edit — VP-SKILL-076/077 disentanglement) re-verified occupancy independently before allocating
(Lesson 8): `grep -rhoE 'VP-SKILL-[0-9]+' .factory/` returns VP-SKILL max **076**, `grep -rhoE 'VP-HOOK-[0-9]+' .factory/`
returns VP-HOOK max **032** (range 024–032, unchanged), and `grep -rhoE 'SM-[0-9]+' .factory/` returns max real =
**SM-54** (SM-2026 the DATE false-positive, SM-456 the 'PRISM-456' charset example — neither a mutant). `grep -rn
'VP-SKILL-077' .factory/` returned NO match before allocation (confirmed absent repo-wide, INCLUDING architecture-delta,
the BCs, and the target file). Allocation: **VP-SKILL-077** (next-free VP-SKILL after 076 — the P14-005 onboard-customer
AD-017 credential-decline VP, mirroring VP-SKILL-054). **NO new SM allocated — SM-55 SKIPPED** (VP-SKILL-077 is a B-STR
structural-presence property; no control-flow gate to mutate, per the VP-SKILL-054 no-mutant precedent). This edit
DISENTANGLES the burst-10 conflation where VP-SKILL-076 was ambiguously cited for BOTH the P14-002 charset gate and the
P14-005 AD-017 credential-decline — VP-SKILL-076 stays SCOPED STRICTLY to P14-002, VP-SKILL-077 owns P14-005. No existing
VP/SM renumbered; VP-HOOK-032 max unchanged. SM stays occupied 9–**54** (SM-32 = 32a+32b+32-ext); VP-SKILL 001–**077**,
VP-HOOK 024–032. ZERO collisions confirmed independently.**

**v1.19 (this edit — pass-17 remediation burst 14) re-verified occupancy independently by a FRESH grep BEFORE allocating
(Lesson 8): `grep -rhoE 'VP-HOOK-[0-9]+' .factory/` returns VP-HOOK max **032** (range 024–032, UNCHANGED this pass),
`grep -rhoE 'VP-SKILL-[0-9]+' .factory/` returns VP-SKILL max **077** (UNCHANGED), and `grep -rhoE 'SM-[0-9]+' .factory/`
returns max real = **SM-54** (SM-2026 the DATE false-positive in BC-6.01.001 frontmatter, SM-456 the 'PRISM-456' charset
example in BC-3.03.001 — neither a mutant; **SM-55 appears ONLY as 'SM-55 SKIPPED'** in ~15 changelog/roster/state
locations — a documented NON-allocation from the v1.18 VP-SKILL-077 disentanglement, NOT a live mutant). `grep -rn 'SM-56'
.factory/` returned NO match repo-wide before allocation (confirmed absent incl. architecture-delta, the BCs, STATE.md, and
the target file). Allocation: **SM-56** (the D-019 known-FP-floor-bypass-branch mutant, P17-001). **COLLISION AVOIDED:**
SM-55 is deliberately NOT reused — reusing it would collide-of-meaning with its heavily-documented 'skipped' record (every
'SM-55 skipped' reference would become ambiguous), so the next control-flow mutant takes **SM-56** and SM-55 remains
reserved-skipped. NO new VP id minted — **VP-HOOK-026 EXTENDED in place** (P17-001 / D-019: the v1.15 known-FP floor
EXEMPTION vector RETIRED/INVERTED, +SM-56) and **VP-HOOK-028 REWRITTEN in place** (P17-002: property (1) recast to the
JSON-first fail-closed residual boundary; self-contradiction with property (2) resolved) — no new/renumbered VP id (the
architect §8.31.4 item 3 explicitly forbids minting a floor-exemption VP; §8.31.2 mandates rewrite-not-withdraw for
VP-HOOK-028). SM is now occupied 9–**56** (SM-32 = 32a+32b+32-ext; **SM-55 reserved-skipped**); VP-SKILL 001–077,
VP-HOOK 024–032. ZERO collisions confirmed independently.**

**Result: ZERO namespace collisions. No renumbering required (v1.9's two architect-proposed IDs were
corrected to free slots — VP-SKILL-072→074, SM-33/34→36/37; v1.10's SM-NEW-A/B → SM-38/39, step-6a
mutant → SM-40; v1.11's SM-P8-A/B → SM-41/42; v1.12's SM-P9-A → SM-43; v1.13's SM-P10-A/B → SM-44/45 +
new VP-HOOK-030 / VP-SKILL-075; v1.14's SM-P11-A + unallocated VP → SM-46/47 + new VP-HOOK-031; v1.15's SM-P12-A/B/C/D
→ SM-48/49/50/51 + new VP-HOOK-032, all next-free; **v1.16's SM-P13-A → SM-52 + new SM-53, all next-free; VP-HOOK-031
UPDATED in place (no new VP id); v1.17's new VP-SKILL-076 + new SM-54, both next-free (P14-002 setup-time charset VP + paired mutant); v1.18's new VP-SKILL-077, next-free (SM-55 SKIPPED — no mutant); v1.19's new SM-56, next-free (P17-001 / D-019; SM-55 reserved-skipped, deliberately not reused; VP-HOOK-026 EXTENDED + VP-HOOK-028 REWRITTEN in place, no new VP)**).** Each
VP-SKILL-050..077 and VP-HOOK-024..032 appears in exactly one *owning* BC.

**VP-HOOK-029 namespace justification (VP-HOOK vs VP-SKILL — pass 4; scope corrected pass-5/6; end-to-end re-scope + re-FINALIZED pass-7).**
The fail-loud invariant's ENFORCEMENT surface (the ALLOW/DENY decision and the marker store) is
hook-side, so the property stays in **VP-HOOK**; but per the **O4 standing rule (§0)** its *assertion*
is now the CONSUMER-BOUNDARY outcome, not an emitter-local artifact. For a hard-floor / Indeterminate /
silent-sensor verdict, VP-HOOK-029 asserts exactly one of two consumer-observable terminal states —
(i) **review path:** the verdict carries a `create-review`/`comment-review` token, STEP 3 issues the
restricted marker, AND a correctly-labeled `jr` write is authorized and consumable at consumer STEP 6a
(the human-surface jr write actually occurs); or (ii) **deny path:** the verdict carries a NON-review
token, STEP 4 **DENIES the verdict Write** with a structured corrective reason (`hard_floor_trigger`,
`required_token`, `label_instruction`, `instruction`) + an **UNDER-LABEL-DENIED** audit entry, NO
marker is issued, and on the loop's corrected re-document (with the required review token) path (i)
fires. It NEVER leaves an unconsumable marker in the store, and NEVER a silent allow-without-marker.
**Pass-7 redesign (ADV-F2-P7-001 CRITICAL / P7-004 MAJOR):** the pass-5/6 STEP-4 marker-*upgrade*
mechanism is RETIRED — P7-001 proved disposition-guard can rewrite the marker but not the loop's
future Bash command, so the upgraded `create-review` marker was structurally unconsumable by the
loop's own non-review `jr` command (3 of 4 under-label action types silently dropped the finding).
DENY-AT-WRITE is the only deterministic lever at the point the LLM can still react. STEP 4 still runs
**before the STEP 5 kill switch**, so the deny fires regardless of `autonomy_enabled` (the
kill-switch-irrelevance assertion). The old emitter-only VP-HOOK-029 assertion ("a marker exists OR an
error artifact was written") could NOT detect the unconsumable-marker seam gap (P7-004) — the re-scope
per architecture-delta §8.17 item 1 asserts the downstream jr authorization/execution instead.
BC-10.01.001 Inv#10 (narrowed so hard floors surface via a correctly-labeled review token, and STEP 4
deny-the-Writes under-labeled hard-floor verdicts) is the authoritative *definition*; BC-3.03.001
(STEP 4 deny + UNDER-LABEL-DENIED audit) + BC-3.01.001 v1.19 (consume create-review/comment-review at
step 6/6a) are the *enforcement* surfaces. VP-HOOK-029 lifecycle: re-marked **PROPOSED** pending the
deny-path vector set, then **re-FINALIZED (P0) v1.10**. **VP-SKILL-072
ownership.** First-run 24h lookback (BC-10.01.001 Inv#13 / EC-001) is a monitoring-loop
query-construction property — the loop, on an absent watermark file, MUST issue
`WHERE _time >= now() - INTERVAL 24 HOURS` and MUST NOT scan full sensor history — so it belongs
in **VP-SKILL**. It is distinct from VP-SKILL-050 (watermark *monotonicity* + future-timestamp
rejection): VP-SKILL-050's incidental "first-run = 24h lookback" mention is subsumed and now
carries an explicit cross-reference to the dedicated VP-SKILL-072 (no double-allocation — 050
proves post ≥ pre on an *existing* watermark; 072 proves the *absent-watermark* lookback bound
and post-run persistence).

**VP-SKILL-069/070/071 ownership (pass 3).** VP-SKILL-069 owns to **BC-5.01.001** (investigate-event
Invariant #8 — Stage-3 OCSF lookup + temporal-adjacency PrismQL always carry an `org_slug` WHERE
clause) and VP-SKILL-070 owns to **BC-4.05.001** (assess-priority Invariant #4 — PC#5a/5b/5d PrismQL
paths always carry `org_slug`). These are the two PrismQL surfaces the adversary flagged (ADV-F2-P3-004)
as uncovered by VP-SKILL-064 (monitoring-loop-only) and VP-SKILL-059 (scan-threats-only); each BC
already lists its VP as PROPOSED with a matching BATS test-name pair, so finalization is a scope
confirmation, not a new assignment. VP-SKILL-071 owns to **BC-4.05.001** (PC#6 / D-DEC-011 — the
`confidence_score` float → `confidence` enum mapping fidelity at the 0.75/0.40 thresholds); it is
orthogonal to VP-SKILL-070 (query scoping) — no overlap. **VP-HOOK-028 namespace justification
(VP-HOOK vs VP-SKILL).** Like VP-HOOK-025/027, the verdict-path-reachability property's ALLOW/DENY
verdict is produced entirely hook-side: disposition-guard fast-path-allows a Write whose path lacks
the `verdict` substring (emitting NO marker), and require-review then DENIES the downstream Stage-8
`jr` Bash (no marker to consume). The monitoring-loop SKILL merely chooses the write path; the
enforcement surface is 100% hook-side, so the property belongs in **VP-HOOK**. BC-10.01.001 Stage-7
PC#8 (verdict-path naming convention) is the authoritative *definition*; BC-3.03.001 (fast-path) +
BC-3.01.001 (consume) are the *enforcement* surfaces.

**VP-HOOK-027 namespace justification (VP-HOOK vs VP-SKILL — pick and justify per task item 1).**
The stage-order document-before-action property is realized *entirely by the two PreToolUse
hooks*: disposition-guard (the emitter — must fire on the Stage 7 verdict Write and drop a
marker) and require-review (the consumer — DENIES the Stage 8 `jr` Bash call when no preceding
marker exists). The ALLOW/DENY verdict under test is produced by the hooks, not by any
skill-internal branch; the monitoring-loop SKILL merely orders the two tool calls. Because the
enforcement surface is 100% hook-side (identical to the VP-HOOK-024/025/026 marker family), the
property belongs in the **VP-HOOK** namespace, not VP-SKILL. This mirrors the VP-HOOK-025
define/enforce pattern: BC-10.01.001 Invariant #14 is the authoritative *definition* of the
ordering; BC-3.03.001 (emit) + BC-3.01.001 (consume) are the *enforcement* surfaces. It is
tagged **P1** per architecture-delta §8.7 item 1.

**VP-SKILL-066/067 own to BC-4.02.001** (update-jira, distinct from the monitoring-loop path
that VP-SKILL-062 covers): Invariant #4 (never-auto-reopen) and Invariant #5 (SLA surface) are
update-jira-skill invariants with no prior VP anchor (BC-4.02.001's VP table currently lists only
VP-SKILL-006/007/008 — see §7). **VP-SKILL-068 owns to BC-10.01.001** at the dedup/grace-window
invariant (Inv#8 / D-DEC-002) — orthogonal to VP-SKILL-050 (watermark monotonicity only), no
overlap. **VP-SKILL-064 and VP-SKILL-065 both
own to BC-10.01.001** (Invariant #1 and Invariant #11 respectively) — distinct invariants,
distinct properties, no overlap with the existing 050/060–063 monitoring-loop VPs. VP-HOOK-025
legitimately appears in two BCs because BC-10.01.001 Invariant #9 is the authoritative
field-list definition and BC-3.03.001 (disposition-guard) is the enforcement surface — this is
a define/enforce pair, not a double-allocation. The pre-F1 BCs (BC-3.02/3.04/3.05/3.06,
BC-4.01/4.03/4.04/4.06, BC-6.01.002, BC-7.01.001, BC-8.01.001) top out at VP-SKILL-049 /
VP-HOOK-023 with no overlap into the 050+/024+ ranges.

**Adjudication of the 12 proposed VPs (052–063): ALL FINALIZED.** They are well-formed, each
maps to a stated invariant in its owning BC, and each has a testable BATS strategy. No scope
overlap, no duplication of an existing VP's property. The `(PROPOSED)` qualifier has been
dropped by the product-owner in the BCs (first landed BC-10.01.001 v1.2 §Revision, BC-3.03.001
v1.8, BC-3.01.001 v1.13; current LIVE versions BC-10.01.001 v1.9, BC-3.03.001 v1.13, BC-3.01.001
v1.17); confirmed applied — see §7.

---

## 2. Finalized VP Table

Strategy legend: **B-BEH** = BATS behavioral (hook exercised via stdin JSON envelope, assert
`permissionDecision` / marker-store side effect); **B-STR** = BATS structural-presence (assert
SKILL.md/dir/command text or filesystem shape); **B-INT** = BATS integration (jr-mock and/or
prism-DTU-demo-server backed, `--config-dir <tmpdir>` isolated); **B-INT-XH** = cross-hook
integration (two sequential subprocess hook invocations sharing `CLAUDE_PLUGIN_DATA`).

| VP ID | Name / Property | Strategy | Test surface | BC anchor |
|-------|-----------------|----------|--------------|-----------|
| VP-HOOK-024 | Marker-validation soundness (schema v2.0, **iterative-consume**): write-block-matched command WITH a valid, unexpired (`now() > expires_at_utc` absolute check; 120s TTL), single-use, correctly-scoped, **ticket-bound** (`command_pattern` anchored to `<ticket_id> ` for comment/assign; operation-scoped for create), non-path-traversal marker → allow; candidates **sorted by `issued_at_utc` ASC (oldest first); the first candidate whose atomic `mv → .used` rename SUCCEEDS → allow; if every rename fails (all consumed by a concurrent invocation) → deny (fail-closed exhaustion)**; **rename-fail on a lone candidate → continue/deny (fail-closed)**; audit line appended with **base64-encoded** command to `${CLAUDE_PLUGIN_DATA}/markers/audit.log`; replay of a consumed marker → deny. Covers comment/create/assign scoped allow-paths. Replaces the retired ">1-candidate → ambiguous deny" gate (architecture-delta §D-DEC-001 v1.3 / ADV-F2-P2-003). **v1.9 (ADV-F2-P6-001 CRITICAL): consumer STEP 6a anti-fungibility cross-check — review markers (`["create-review"]`) and regular markers (`["create"]`) are NOT fungible in either direction: a `["create-review"]` marker only authorizes a command carrying `--label REVIEW-REQUIRED\|BLIND-SPOT`, and a `["create"]` marker is refused for any command carrying a review label (EC-023). This is the hook-side (deterministic) enforcement of the review/regular distinction that D-DEC-012's Alternatives-Rejected reversal now ADOPTS — it is a security control that cannot live only in the untrusted SKILL.md Iron Law.** **v1.5 (ADV-F2-P4-002 CRITICAL): create `command_pattern` injection-safety — the create pattern is anchored `^jr (--output json )?issue create --project <key>( \|$)` with `--project` as the FIRST flag (no `.*` before it) and a trailing `( \|$)` boundary; an attacker-influenceable `--summary` value carrying a `--project ORG_A` substring does NOT match an ORG_A-scoped create marker; a `--project PROD` marker does NOT authorize `--project PRODUCTION` (prefix guard). v1.5 (ADV-F2-P4-010): audit line strips control chars (`tr -d '\000-\037'`) from `ticket_id`/`org_slug`/`op` before interpolation — a `\n` in `ticket_id` cannot forge a second MARKER_USED line.** | B-BEH + B-INT-XH | require-review.sh stdin envelope `{tool_input.command}`; `CLAUDE_PLUGIN_DATA=$(mktemp -d)`; assert `.used` rename + `markers/audit.log` `command_b64=` line; ticket-bound vector (SEC-123 marker → DENY SEC-456); create/assign scoped allow vectors; **concurrent same-scope: two valid markers → oldest consumed, ALLOW; all-renames-fail → exhausted DENY**; **v1.5 injection vectors: marker `command_pattern="^jr (--output json )?issue create --project ORG_A( \|$)"` + command `jr issue create --summary "review --project ORG_A" --project ORG_B` → DENY; `--project PROD` marker + `--project PRODUCTION` command → DENY; v1.5 audit: `ticket_id` containing `$'\n'` → single MARKER_USED line only (control chars stripped).** **v1.9 consumer STEP 6a anti-fungibility (ADV-F2-P6-001 CRITICAL, EC-023): a `["create-review"]` marker + `jr issue create --project ORG_A` WITHOUT `--label REVIEW-REQUIRED\|BLIND-SPOT` → NOT consumed, DENY (named vector `create-review-marker-requires-review-label`, kills SM-36); a `["create"]` marker + `jr issue create --project ORG_A --label REVIEW-REQUIRED …` (carries a review label) → NOT consumed, DENY (named vector `create-marker-rejects-review-label`, kills SM-37); correct pairings — `["create-review"]` marker + `--label BLIND-SPOT` command → consumed ALLOW, and `["create"]` marker + no-label command → consumed ALLOW. `has_review_label` is a structural property of the command, not Jira content; comment/comment-review structural `--label` check pends ASM-014 (current comment-review guard = ticket_id binding + Iron Law).** **v1.10/v1.11 STEP 6a structural-check false-deny prevention (ADV-F2-P7-005 MINOR → ADV-F2-P8-002 MAJOR, D-DEC-001 `structural_label_check`): `has_review_label` is a STRUCTURAL token check (`--label` must appear as a standalone token immediately preceding `REVIEW-REQUIRED`/`BLIND-SPOT`), NOT a raw substring over the whole command. **v1.11 (P8-002): the P7-005 `split_on_whitespace` was insufficient — the hook receives `tool_input.command` as the RAW command string with literal quotes (`jq -r`, no shell expansion), and a naive whitespace split of a quoted `--summary` value STILL yields a standalone `--label` token immediately before `REVIEW-REQUIRED` (EC-024's own example false-denies). The check is now a QUOTE-AWARE state-machine tokenizer (UNQUOTED/IN_SINGLE/IN_DOUBLE) that keeps a quoted region as one token.** Named vector `regular-create-with-label-literal-in-summary-allowed` (updated to the QUOTED form explicitly): a `["create"]` marker + `jr issue create --project PRISMDEMO --summary "rule matched literal --label REVIEW-REQUIRED in alert payload"` (the `--label REVIEW-REQUIRED` literal lives INSIDE a double-quoted `--summary` value; the tokenizer enters IN_DOUBLE at the opening `"` so the whole value is one token → NO standalone `--label` token) → `has_review_label=false` → **ALLOW** (consumed; not a false-deny). Paired mutants: **SM-40** (revert `has_review_label` to the raw-substring check) → the quoted vector DENYs (substring matches inside the quoted region) and the mutant dies; **SM-42** (v1.11 — revert `structural_label_check` to non-quote-aware `split_on_whitespace`) → the quoted vector DENYs (whitespace-splitting breaks the quoted value into a standalone `--label` token) and the mutant dies. **The single quoted-form vector SEPARATELY kills SM-40 and SM-42** — each mutation, applied alone, drives the vector to DENY for a distinct reason (SM-40: raw-substring content match; SM-42: naive token split of the quoted value), so both are independently detected. **P8-003 note: this vector's fail-closed security rests on the anchored step-5 `command_pattern` (a `["create"]` marker only authorizes a genuine `jr issue create`); step-6a `has_review_label` is the SOLE enforcement point for the create/create-review ANTI-FUNGIBILITY distinction (EC-023 direction A) — bash `[[ =~ ]]` is NOT tail-anchored, so step 5 does NOT reject a review-labeled create as a backstop.** **v1.12 STEP 6a ESCAPED-QUOTE differential-vs-bash partition (ADV-F2-P9-001 MAJOR, O5 / D-DEC-001 v1.12): the P8-002 tokenizer toggled UNQUOTED/IN_SINGLE/IN_DOUBLE on EVERY `"`/`'` regardless of a preceding backslash — diverging from bash, which honors `\"`/`\'` as literal escaped characters. With the P8-003 step-5 backstop gone, step-6a is the SOLE anti-fungibility gate, so this divergence is exploitable. The D-DEC-001 v1.12 fix makes the tokenizer backslash-aware (`\"` in IN_DOUBLE → literal `"`, STAY IN_DOUBLE; `\'` in UNQUOTED → literal `'`, NO IN_SINGLE toggle), matching bash. Vectors — (1a SECURITY, kills SM-43) `["create"]` marker + `jr issue create --project PRISMDEMO --summary "a\"b" --label REVIEW-REQUIRED`: bash/jr parse the args as `[--summary, a"b, --label, REVIEW-REQUIRED]` and apply a FUNCTIONAL REVIEW-REQUIRED label; the backslash-aware tokenizer keeps `\"` inside IN_DOUBLE so the double-quoted `--summary` closes only at the FINAL `"`, leaving `--label REVIEW-REQUIRED` as standalone tokens → `has_review_label=TRUE` → **DENY** (the regular marker cannot authorize a review-labeled create — bypass prevented); (1b FALSE-DENY PREVENTION) `["create"]` marker + `jr issue create --project PRISMDEMO --summary "a\"b"` (escaped quote inside the summary, NO real trailing `--label`) → the whole `--summary` value is one IN_DOUBLE token, no standalone `--label` → `has_review_label=FALSE` → **ALLOW**; (partition-2 UNQUOTED completeness) `jr issue create --project PRISMDEMO --summary O\'Brien --label REVIEW-REQUIRED` → `\'` is a literal apostrophe with NO IN_SINGLE state entered, so the trailing whitespace-preceded `--label REVIEW-REQUIRED` is a standalone token → `has_review_label=TRUE` → **DENY** (proves no accidental IN_SINGLE swallow). Paired mutant **SM-43** (revert the D-DEC-001 v1.12 IN_DOUBLE backslash handling to the P8-002 toggle-on-every-quote → `\"` closes the quoted region, `--label REVIEW-REQUIRED` is swallowed into the summary token, `has_review_label=FALSE`, the `["create"]` marker wrongly ALLOWs) killed by vector 1a; **SEPARATELY killable from SM-42** (split_on_whitespace revert) **and SM-40** (raw-substring revert) — SM-43 tests the backslash-escape class the other two do not exercise. **Equals-form `--label=REVIEW-REQUIRED` SCOPED OUT — jr CLI does not support the equals form (`jr issue create --help`, confirmed 2026-07-21); only `--label VALUE` space-separated form is emitted. Re-evaluate if jr adds equals-form support. VP-HOOK-024 is the O5 compliance artifact for `structural_label_check` (§0) — the escaped-quote partition covers the backslash-escape class; single/double/unquoted classes are covered by the P8-002 quoted-form vector.** | BC-3.01.001 (v1.22) |
| VP-HOOK-025 | ICD-203 completeness (**dual-path, artifact-class field-set branching — D-DEC-008-C**): disposition-guard branches the required field-set by artifact class — **investigation markdown = 12 ICD-203 fields** (heading-anchored `grep`; Severity/Asset Type/Ticket Action Type are NOT required and their presence must NOT trigger a wrong-class deny) vs **verdict JSON = 18 fields** (12 ICD-203 + **severity[13], asset_type[14], ticket_action_type[15], native_severity[16], sensor_family[17], scored_priority[18]** — fields 16/17 NEW v1.13/P10-001, carried from Stage-1 INGEST for the STEP 1a consistency check; **field 18 `scored_priority` NEW v1.14/P11-002, the Stage-5 assess-priority output ∈{CRIT,HIGH,MED,LOW} that the HIGH/CRIT hard floor keys on**) via `jq has()` key-presence + per-field type check; enforces tuning_signal null-vs-absent semantics; severity-based hard-floor legs; **field#2 confidence is enum-only (D-DEC-011): a float `confidence` value is DENIED, the enum values {high,medium,low} are ALLOWED** (ADV-F2-P3-008). **v1.13 (P10-001): `native_severity` (field 16) must be a non-empty string and `sensor_family` (field 17) must be ∈{crowdstrike,armis,claroty,cyberint} — absent field 16 or non-member field 17 → fail-closed DENY at STEP 1 (these fields are REQUIRED inputs to the STEP 1a SEVERITY-MISMATCH consistency check owned by VP-HOOK-030).** **v1.14 (P11-002): `scored_priority` (field 18) must be present and ∈{CRIT,HIGH,MED,LOW} — absent field 18 or non-member value → fail-closed DENY at STEP 1 (field 18 is the REQUIRED input to the HIGH/CRIT hard floor per hard_floor_applies(), NOT recomputed severity; scored_priority is LLM-supplied — same ASM-008-class residual, NOT asserted as ground-truth).** **v1.15 (P12-003a MAJOR — fast-path enum map): on the known-FP fast-path (Stage 5 bypassed), `scored_priority` MUST be set from `NORMALIZE_SEVERITY` output mapped through the canonical `SEVERITY_TO_SCORED_PRIORITY_MAP` (CRITICAL→CRIT, MEDIUM→MED, HIGH→HIGH, LOW→LOW) — a raw assignment of the NORMALIZE_SEVERITY result ({LOW,MEDIUM,HIGH,CRITICAL}) writes a NON-member of SCORED_PRIORITY_ENUM ({CRIT,HIGH,MED,LOW}) so `validate_enums()` fail-closed-DENIES it (the failure the map prevents; would silently deny 30–40% of known-FP volume, esp. high-severity CrowdStrike native "100"→CRITICAL). VP-HOOK-025 asserts a fast-path verdict whose `scored_priority` was mapped through the table (CRIT/MED/HIGH/LOW) PASSES validate_enums, while a raw unmapped `CRITICAL`/`MEDIUM` DENIES — CRIT≠CRITICAL, MED≠MEDIUM. No new mutant (the raw-CRITICAL/raw-MEDIUM deny is the direct consequence the vectors assert).** **v1.5 (ADV-F2-P4-006 MAJOR): `validate_enums()` membership gate runs BEFORE the hard-floor check and fail-closed-DENIES any non-member / wrong-case value on ALL typed fields — `severity∈{LOW,MEDIUM,HIGH,CRITICAL}`, `asset_type∈{domain_controller,privileged_account,ot_safety_system,standard,unknown}`, `disposition∈{TP,FP,BTP,Indeterminate}`, `sensor_health_status∈{healthy,degraded,silent}`, `ticket_action_type∈{comment,create,assign,none,create-review,comment-review}`, `confidence∈{high,medium,low}`. A case-mangled `severity:"High"` is DENIED (NOT allowed-without-marker), closing the hard-floor bypass where key-presence passed but membership silently failed.** | B-BEH | disposition-guard.sh stdin `{tool_input.file_path, content}`; **investigation-markdown 12-field fixture (all 12 headings → allow; missing any of 12 → deny; a spurious Severity heading added → still allow, no wrong-class 18-field deny)**; **verdict-JSON 18-field fixture (missing any of 18 → deny)**; **confidence float→deny + confidence∈{high,medium,low}→allow legs**; **v1.5 enum-membership legs: `severity="High"`→DENY, `severity="CRITICAL"`→allow (other fields OK), `asset_type="Unknown"`→DENY, `disposition="indeterminate"`→DENY, `sensor_health_status="Degraded"`→DENY, `ticket_action_type="NONE"`→DENY (fail-closed, before hard floor); v1.13 fields-16/17 legs: `native_severity` absent→DENY, `native_severity=""`→DENY, `sensor_family="unknown_vendor"`→DENY (enum, NOT SEVERITY-MISMATCH); **v1.14 field-18 legs (P11-002): `scored_priority` absent→DENY, `scored_priority="CRITICAL"` (wrong enum — should be CRIT)→DENY, `scored_priority="MEDIUM"` (wrong enum — should be MED)→DENY, `scored_priority=CRIT`→proceed**; **v1.15 fast-path enum-map legs (P12-003a, SEVERITY_TO_SCORED_PRIORITY_MAP): known-FP fast-path + native_severity=90 (CrowdStrike→CRITICAL)→scored_priority=`CRIT` (mapped, NOT `CRITICAL`)→validate_enums passes; native_severity=30 (→MEDIUM)→`MED` (NOT `MEDIUM`)→passes; native_severity=70 (→HIGH)→`HIGH`→passes; native_severity=10 (→LOW)→`LOW`→passes; fast-path verdict with raw unmapped `scored_priority="CRITICAL"`→validate_enums DENY; raw unmapped `scored_priority="MEDIUM"`→DENY (the deny the map prevents)**; all 18 present + valid→proceed to STEP 1a** | BC-3.03.001 (post-pass-11: STEP 1a consistency check + 18-field validate_enums; **v1.15: SEVERITY_TO_SCORED_PRIORITY_MAP note, §8.26.1 item 5**) PC#1/2/3 (JSON-first; 12 markdown / **18** JSON + validate_enums) / BC-10.01.001 (v1.19) Inv#9 |
| VP-HOOK-026 | Indeterminate / hard-floor non-overridability: no autonomy configuration (`autonomy_enabled`, `require_review`, auto-scope) can cause a hard-floor category (Indeterminate / **verdict.scored_priority∈{HIGH,CRIT}** (field 18, **P11-002 — the HIGH/CRIT floor keys on scored_priority, NOT recomputed severity; a detector severity=LOW alert escalated by assess-priority to scored_priority=CRIT via KEV/exposure still trips the floor**) / **verdict.asset_type∈CRITICAL_ASSET_TYPES** / **verdict.asset_type=='unknown'** / T1003·T1068·T1021·T1041 / degraded-silent sensor) to receive a **REGULAR (comment/create/assign-scoped, autonomous-triage) marker**; **[UPDATED v1.8/v1.9/v1.10 — fail-loud on under-label, now STEP 4 DENY-THE-WRITE (before the STEP 5 kill switch), ADV-F2-P5-001/P6-002/P7-001]** a hard-floor category is surfaced ONLY via a `create-review`/`comment-review` REVIEW marker (STEP 3 correct-label; an under-labeled hard-floor verdict is **denied at STEP 4** with a corrective reason so the loop re-documents with a review token — owned by **VP-HOOK-029**) or the STEP-4 deny+audit; it is NEVER left silently empty and NEVER receives a regular comment/create/assign marker; hard floor keys on **scored_priority (field 18)/asset_type NOT confidence, NOT recomputed severity** (ADV-F2-001; **P11-002 re-key: verdict.severity is the detector-native reading validated by STEP 1a for consistency, but the HIGH/CRIT floor keys on the Stage-5 scored_priority per brief §3.9 "any alert scored HIGH/CRIT → human"; the two fields may legitimately differ. scored_priority is LLM-supplied — same ASM-008-class residual, NOT asserted as ground-truth**); **the `unknown` asset_type is a conservative hard-floor member (ADV-F2-P3-001): a LOW-severity + benign-technique + `asset_type=unknown` verdict NEVER gets a REGULAR marker regardless of `autonomy_enabled`**; loop always routes to human. **v1.5 (D-DEC-012 / ADV-F2-P4-004): the `create-review`/`comment-review` review-surfacing marker types are EXEMPT from the hard-floor no-marker rule AND from the autonomy_enabled kill switch (escalation ≠ autonomous triage) — a hard-floor (e.g. HIGH-severity / Indeterminate / silent-sensor) verdict with `ticket_action_type=create-review` DOES get a restricted marker (`authorized_operations:["create-review"]`); the same under `autonomy_enabled=false` still emits the review marker. **v1.8 (ADV-F2-P5-002 MAJOR — OVER-LABEL GATE): the STEP 3 review-marker exemption is GATED on the hook-computed predicate `hard_floor_applies(verdict)=TRUE` (`IF NOT hard_floor_applies(): emit allow WITHOUT marker; RETURN`). An LLM-supplied `create-review`/`comment-review` token on a verdict where `hard_floor_applies()` returns FALSE (e.g. disposition=TP, LOW severity, standard asset) does NOT receive the kill-switch / hard-floor exemption — it emits allow-without-marker (the document write proceeds; require-review denies the downstream `jr` action because no marker is in the store). This closes the P5-002 bypass where the LLM could manufacture a kill-switch bypass by over-labeling a regular verdict as a review action. O3 standing rule: the LLM-supplied `ticket_action_type` is cross-validated against `hard_floor_applies()` before the exemption fires.** v1.5 (ADV-F2-P4-005): the kill switch is read DIRECTLY by disposition-guard from the verdict's `autonomy_enabled` operational field (not delegated to the loop LLM) — `autonomy_enabled≠true` (false OR absent → conservative false) suppresses ALL REGULAR markers (comment/create/assign) while leaving GENUINELY-hard-floor review-surfacing markers untouched.** | B-BEH + B-INT-XH | disposition-guard.sh with hard-floor verdict + `autonomy_enabled=true` injected via envelope; inject **verdict.severity=HIGH**, **verdict.asset_type=critical-asset** (domain_controller), and **verdict.asset_type=unknown with severity=LOW + benign technique** → **[UPDATED v1.8]** assert NO regular (comment/create/assign-scoped) marker is written on any hard-floor leg — i.e. no marker with `authorized_operations ∈ {comment,create,assign}` (an under-labeled hard-floor verdict is instead **denied at STEP 4** with a corrective reason + UNDER-LABEL-DENIED audit; that fail-loud outcome is owned by **VP-HOOK-029** — VP-HOOK-026 asserts the ABSENCE of the autonomous-triage marker, NOT an empty store); **v1.5 review-surfacing legs (hard-floor EXEMPT — hard_floor_applies()=TRUE): Indeterminate + `create-review` → restricted marker emitted with `authorized_operations=["create-review"]`; silent-sensor + `comment-review` → restricted marker emitted; HIGH-severity + `create-review` → marker emitted; `autonomy_enabled=false` + `create-review` → marker STILL emitted (kill-switch EXEMPT); v1.8 OVER-LABEL legs (hard_floor_applies()=FALSE — paired mutant SM-32b): non-hard-floor TP verdict (LOW severity, standard asset) + `create-review` token → NO marker (allow-without-marker; over-label rejected); non-hard-floor FP verdict + `comment-review` + `autonomy_enabled=false` → NO marker (no kill-switch bypass); LOW-severity standard asset + `create-review` → NO marker (verify hard_floor_applies()=false path); v1.5 kill-switch legs: `autonomy_enabled=false` + regular `create` → NO marker; `+ comment` → NO marker; `autonomy_enabled` ABSENT + regular create → treated false → NO marker; **v1.14 scored_priority floor legs (P11-002, hard_floor_applies() keys on field 18 — paired mutant SM-46): (i) `scored_priority=HIGH` + regular `create` → hard floor fires, NO regular marker (under-labeled → STEP-4 deny per VP-HOOK-029) / with `create-review` → review marker; (ii) `scored_priority=CRIT` + regular `comment` → hard floor fires, NO regular marker; (iii) DETECTOR-LOW/SCORED-CRIT escalation — `verdict.severity=LOW` + `native_severity="10"`/`sensor_family=crowdstrike` (STEP 1a consistency passes: recomputed LOW == LOW) + `scored_priority=CRIT` (KEV/exposure escalation, brief §3.9) → hard floor STILL fires (keys on scored_priority, NOT recomputed severity) → NO regular marker; **this is the SM-46 kill vector** — SM-46 re-keys the floor to recomputed severity, so under the mutant recomputed=LOW → floor FALSE → a regular marker is wrongly issued → mutant dies; (iv) `scored_priority=MED` + `verdict.severity=CRITICAL`/`native_severity="90"`/`sensor_family=crowdstrike` (recalibrated DOWN; STEP 1a passes on consistency) → the high-severity floor does NOT fire via scored_priority (MED); the floor keys on scored_priority alone; (v) `scored_priority=LOW` + all other floors pass → hard floor FALSE (regular path proceeds); ~~**v1.15 known-FP floor EXEMPTION (P12-003b)**~~ **RETIRED v1.19 (P17-001 / D-019, human decision 2026-07-23; reason: 'D-019: exemption scoped to LOW/MED only; no high-sev exemption' — history preserved, no re-run).** The v1.15 assertion (a documented known-FP + healthy sensor + non-forbidden technique + disposition=FP AUTO-CLOSES even at high native severity, `scored_priority∈{HIGH,CRIT}`, EXEMPT from the §3.9 floor) is a DEAD/INCORRECT property: `hard_floor_applies()` fires UNCONDITIONALLY on `scored_priority ∈ {HIGH,CRIT}` (BC-3.03.001 L658-666 — NO known-FP branch), and disposition-guard has NO forgery-proof known-FP signal (the 18-field verdict is LLM-authored; an LLM-supplied `known_fp` field would be a CRITICAL O6 bypass, REJECTED per D-019; DI-015 bounds store integrity but does not protect a verdict field). **v1.19 D-019 vectors (replacing the retired exemption vector; NO floor-EXEMPTION VP minted — arch-delta §8.27 hold-note RESOLVED by D-019, there is no exemption to verify; the FV obligation is to verify the floor FIRES for high-sev known-FPs): (a) LOW/MED-native known-FP — `scored_priority=LOW` (or `=MED`) + known-FP store match + healthy sensor + non-forbidden technique + disposition=FP → `hard_floor_applies()`=FALSE → NO floor → AUTO-CLOSE (comment via the regular path; Write succeeds; no review required); (b) HIGH-native known-FP — `scored_priority=HIGH` + known-FP store match + disposition=FP → `hard_floor_applies()`=TRUE → DENY-THE-WRITE (HARD-FLOOR-UNDER-LABEL) → routes to comment-review (human review), NOT auto-close (this is the SM-56 kill vector); (c) CRIT-native known-FP — `scored_priority=CRIT` + known-FP store match + disposition=FP → `hard_floor_applies()`=TRUE → DENY-THE-WRITE → comment-review (also kills SM-56). This is exactly the secure behavior the deterministic gate already enforces: routing a HIGH/CRIT known-FP to human review aligns with DI-015 (a poisoned HIGH-sev known-FP entry cannot silently suppress a real high-severity alert); the loop re-issues as comment-review per VP-HOOK-029's re-doc obligation. LOW/MED known-FPs retain auto-close (no floor fires). Paired mutant SM-56 (`hard_floor_applies()` adds a known-FP bypass branch that skips the floor when the verdict matches the known-FP store → a HIGH/CRIT-native known-FP auto-closes instead of routing to review) killed by vectors (b)/(c). hard_floor_applies() definition confirmed UNCHANGED (fires on scored_priority ∈ {HIGH,CRIT} unconditionally — it was already correct per D-019; no known-FP carve-out exists or should exist)**) | BC-10.01.001 (v1.19 Inv#10/§3.9; **v1.19 (P17-001 / D-019): EC-009 known-FP floor EXEMPTION RETIRED/INVERTED — LOW/MED known-FP auto-close, HIGH/CRIT known-FP → hard_floor_applies() FIRES → comment-review; store-integrity invariants retained (DI-015); no high-sev exemption**); BC-3.03.001 (v1.25 Inv#4, STEP 3 gate) |
| **VP-HOOK-027** *(NEW v1.2, **P1**)* | **Stage-order document-before-action (ADV-F2-P2-001/P2-014):** a monitoring-loop `jr issue comment/create/assign` (Stage 8 TICKET ACTION) is **DENIED** by require-review unless a verdict-record Write for the SAME run/verdict (Stage 7 DOCUMENT) — which caused disposition-guard to emit a matching scoped marker — preceded it within the marker TTL (120s). Proves the D-DEC-008 ordering invariant is enforced end-to-end: Stage 7 DOCUMENT must precede Stage 8 TICKET ACTION, or the loop can never auto-action (the ADV-F2-P2-001 CRITICAL failure mode). | B-INT-XH | Positive: (1) disposition-guard.sh on a valid non-hard-floor verdict Write → assert marker emitted in `${CLAUDE_PLUGIN_DATA}/markers/`; (2) require-review.sh on the matching `jr` Bash → assert **allow** + marker consumed. Negative: require-review.sh on the same `jr` Bash with **NO preceding verdict Write** (empty marker dir) → assert **deny**. TTL-expiry leg: verdict Write, wait past 120s, jr Bash → deny. Same shared `CLAUDE_PLUGIN_DATA=$(mktemp -d)` env across the two subprocess hooks (ASM-009 condition). | BC-10.01.001 (v1.19 Inv#14, D-DEC-008); enforced by BC-3.03.001 (v1.22 emit) + BC-3.01.001 (v1.22 consume) |
| VP-SKILL-050 | Watermark monotonicity: per org×sensor watermark write is always ≥ previous persisted value; loop never re-processes a consumed window on restart; future timestamp rejected. *(First-run 24h lookback is covered by the dedicated **VP-SKILL-072** as of v1.5 — this row proves post ≥ pre on an EXISTING watermark only.)* | B-INT | Inject pre-existing watermark file under `CLAUDE_PLUGIN_DATA/watermarks/<org>/<sensor>`; run loop stub; assert post ≥ pre | BC-10.01.001 (Inv#4, D-DEC-002) |
| VP-SKILL-051 | Prism version gate: `prism --version` parsed and compared to `1.0.0-rc.1`; below → halt with version-gate error, no MCP write; at/above → proceed to dual MCP write | B-INT | prism-version-check.sh with mocked `prism --version`; assert halt vs proceed + no settings write on halt | BC-6.01.001 (v1.7) |
| VP-SKILL-052 | onboard-customer UUID-v7 format validation; malformed UUID rejected with re-prompt | B-STR + B-INT | onboard-customer helper / SKILL.md; feed invalid UUID | BC-6.01.003 |
| VP-SKILL-053 *(REPURPOSED — meaning changed)* | onboard-customer idempotent directory creation; re-run does not modify/delete existing `customers/<org_slug>/`. **`[originally: onboard-customer AD-017 credential-provisioning; repurposed pass-14 / P14-005 → now idempotent-directory-creation]`** — the ID's meaning changed; the original onboard-customer AD-017 credential-provisioning/decline acceptance (BC-6.01.003 Inv#1 / EC-008) coverage is **RESTORED via VP-SKILL-077** (onboard-customer AD-017 credential-decline; v1.18 VP-SKILL-076/077 disentanglement) — **NOT** moved to VP-SKILL-076, which is the unrelated setup-time `jira_project_key` charset gate (the burst-10 conflation this edit corrects). | B-INT | mktemp spec dir; run twice; assert dir unchanged | BC-6.01.003 (Inv#1 idempotent-dir; **AD-017 coverage: RESTORED via VP-SKILL-077**) |
| VP-SKILL-054 | onboard-sensor AD-017 compliance: SKILL.md never requests credential paste in chat; only piped-stdin `echo \| prism credential set` documented | B-STR | grep SKILL.md for forbidden paste pattern; assert absent | BC-6.01.004 |
| VP-SKILL-055 | onboard-sensor SELECT 1 verification mandatory; success message gated AFTER the SELECT 1 step | B-STR | SKILL.md ordering assertion | BC-6.01.004 |
| VP-SKILL-056 | sensor-metrics per-org×sensor output completeness: each prism_sensor_health row yields org_slug, sensor_id, last_seen_ts, row_count, error_rate | B-INT | prism-DTU-demo-server rows; assert 5 fields per pair | BC-8.02.001 |
| VP-SKILL-057 *(REPURPOSED — meaning changed)* | sensor-metrics naming compliance (D-DEC-006): dir `skills/sensor-metrics/`, cmd `commands/sensor-metrics.md`; no bare `metrics` alias. **`[originally: sensor-metrics org_slug scoping; repurposed pass-9 / P9-005 → now sensor-metrics naming-compliance (D-DEC-006)]`** — the ID's meaning changed; sensor-metrics org_slug scoping is moot under the D-DEC-005 / P9-005 sensor-health carve-out (`prism_sensor_health` operational-metadata is org_slug-EXEMPT), so no org_slug VP is owed here (raw per-tenant queries stay covered by VP-SKILL-064/069/070). | B-STR | filesystem presence + negative-presence | BC-8.02.001 (naming-compliance; **org_slug scoping N/A per D-DEC-005 / P9-005 carve-out**) |
| VP-SKILL-058 | scan-threats prism_describe-first invariant: SKILL.md documents table enumeration before any hunting query, per org | B-STR | SKILL.md step-ordering assertion | BC-9.01.001 |
| **VP-SKILL-059** *(UPGRADED v1.13 — structural→behavioral, ADV-F2-P10-005)* | **scan-threats org_slug scoping (P10-005 — scan-threats has the largest cross-org leak surface in the package: it iterates ALL registered orgs and executes a predefined query LIBRARY `data/threat-hunt-queries.md`):** every scan-threats PrismQL query carries an `org_slug` scope matching the current FOR-EACH org; a hunt issued in org-a context NEVER returns org-b/c rows; AND every query in the `data/threat-hunt-queries.md` library statically contains an `org_slug` clause. The pass-1 structural-only VP (SKILL.md prose grep) was the WEAKEST org_slug VP while the sibling PrismQL-querying skills (VP-SKILL-064/069/070) all got behavioral multi-org DTU fixtures — a single library query missing `org_slug` would leak cross-tenant data and pass the old structural check. | B-STR + B-INT | **(behavioral)** prism-DTU multi-org fixture (org-a/b/c, `--config-dir <tmpdir>`): an org-a threat hunt returns ZERO org-b/c rows (SM-24 org_slug-drop kill target); **(static)** parse `data/threat-hunt-queries.md` and assert EVERY query in the library carries an `org_slug` scope clause — FAIL if any query is unscoped (NOT merely a SKILL.md prose grep); **(structural, retained)** SKILL.md Iron Law / Red Flag documents the org_slug requirement | BC-9.01.001 (Iron Law + hunt-query-library org_slug) |
| VP-SKILL-060 | Known-FP precedes enrichment: Stage 2 known-FP match → FP disposition with NO Stage 4 enrichment API call | B-INT | jr-mock + enrichment-call spy; assert zero Stage-4 calls | BC-10.01.001 |
| VP-SKILL-061 | Sensor silence is a positive finding: `last_seen_ts > 24h AND row_count == 0` → BLIND-SPOT finding; never empty output / never "nothing to report" | B-INT | prism-DTU silent-sensor fixture; assert BLIND-SPOT emitted | BC-10.01.001 |
| VP-SKILL-062 | Never-auto-reopen-closed: a Closed ticket for the same root cause never receives `jr issue reopen`; a NEW linked ticket is created | B-INT | jr-mock returning Closed ticket; assert create-new + link, no reopen verb | BC-10.01.001 |
| VP-SKILL-063 | Tavily degradation path: Tavily unavailable → set uncertainty_explicit, proceed Perplexity-only, do NOT abort, do NOT force Indeterminate | B-INT | Tavily-absent stub; assert loop continues, disposition not forced Indeterminate | BC-10.01.001 |
| **VP-SKILL-064** *(NEW v1.1; test-names qualified + carve-out boundary v1.13, ADV-F2-P10-006/P10-007)* | **monitoring-loop org_slug scoping (ADV-F2-008 — sole plugin-side cross-tenant isolation guarantee, D-DEC-005):** every loop-issued PrismQL query against a **raw per-tenant table** carries an `org_slug` constraint matching the current FOR-EACH org context; a query issued in org-a context NEVER returns org-b/c rows; the loop's query construction always injects `org_slug`; an unscoped RAW-TABLE query attempt is rejected/scoped. **D-DEC-005 sensor-health carve-out (v1.13, P10-006 tightened):** an unscoped `prism_sensor_health` query is LEGITIMATE (cross-org operational-metadata exemption) — but ONLY when `prism_sensor_health` is the SOLE table reference; a query referencing `prism_sensor_health` together with a raw per-tenant table (JOIN/subquery/CTE) does NOT inherit the exemption and MUST carry `org_slug`. | B-INT + B-STR | prism-DTU multi-org fixtures (org-a/b/c, `--config-dir <tmpdir>`): assert an org-a query returns zero org-b/c rows; **static/structural** grep that query construction always emits `org_slug` for raw tables. **v1.13 concrete @test names (ADV-F2-P10-007 — the pre-carve-out unqualified name was ambiguous):** RENAME `@test "monitoring-loop rejects unscoped PrismQL query"` → **`@test "monitoring-loop rejects unscoped RAW-TABLE PrismQL query"`**; ADD **`@test "monitoring-loop allows unscoped prism_sensor_health query (D-DEC-005 carve-out)"`** (a lone-table `SELECT * FROM prism_sensor_health` is NOT rejected) and **`@test "monitoring-loop rejects prism_sensor_health JOIN raw-table query without org_slug (P10-006 boundary)"`** (`SELECT … FROM prism_sensor_health h JOIN crowdstrike_detections d …` with no `org_slug` → REJECTED — the carve-out is scoped to the sole-table case) | BC-10.01.001 (v1.19 Inv#1 + D-DEC-005 carve-out, EXCEPTION scoped to sole-table `prism_sensor_health`) |
| **VP-SKILL-065** *(NEW v1.1; **RE-SCOPED v1.9**)* | **autonomy_enabled kill switch (ADV-F2-019, Inv#11; carve-out ADV-F2-P6-003):** **[RE-SCOPED v1.9 per D-DEC-012 Option A]** `autonomy_enabled=false` ⇒ ZERO **REGULAR** (comment/create/assign) markers consumed AND ZERO **REGULAR** `jr issue create/comment/assign` writes executed — BUT `create-review`/`comment-review` escalation markers/writes for GENUINE hard-floor verdicts STILL execute (they are kill-switch EXEMPT: the STEP 3 correct-label review path runs before the STEP 5 kill switch — a correctly-labeled hard-floor verdict issues the review marker directly; an under-labeled one is denied at STEP 4 so the loop re-documents with the review token). Evidence collection + verdict construction + Jira drafting still proceed (propose-only) for regular verdicts. The pre-Option-A "zero jr writes of ANY kind" scope contradicted EC-006/EC-014/D-DEC-012 (a silent-sensor/Indeterminate run WILL issue a `jr issue create` for the BLIND-SPOT/REVIEW-REQUIRED ticket under the kill switch) — re-scoped this pass, not silently FINALIZED. | B-INT | BATS integration with `autonomy_enabled=false` injected: **(regular)** non-hard-floor FP verdict → assert `CLAUDE_PLUGIN_DATA/markers/` has no consumed (`.used`) regular markers AND the jr-mock spy records ZERO `jr issue create/comment/assign` REGULAR (non-review) invocations; assert draft written to verdict file with `annotation=propose-only`; **(review-exempt)** silent-sensor (hard-floor) verdict → assert a `create-review` marker IS emitted and the jr-mock spy DOES record the `jr issue create … --label BLIND-SPOT` escalation write (kill-switch EXEMPT per Option A) | BC-10.01.001 (v1.19 Inv#11 carve-out, EC-006/EC-014/EC-020) |
| **VP-SKILL-066** *(NEW v1.2)* | **update-jira never-auto-reopen (ADV-F2-P2-009a — BC-4.02.001 Inv#4):** on the update-jira path, NO code path from the Closed (PC#7d) or Resolved (PC#7c) branch results in a `jr issue move` that transitions a ticket out of Closed/Resolved; Resolved → propose-only + halt; Closed → create-new + link. Holds regardless of `autonomy_enabled`. (VP-SKILL-062 covers only the monitoring-loop path — this is the distinct update-jira surface.) | B-INT + B-STR | jr-mock returning a Resolved ticket → assert propose-reopen message + halt + zero `jr issue move` reopen verbs (EC-007); jr-mock returning a Closed ticket → assert create-new + `jr issue link`, zero reopen (EC-008); **static** grep of `update-jira/SKILL.md` (+ any helper): no autonomous `jr issue move` out of Resolved/Closed | BC-4.02.001 (v1.12 Inv#4, §3.4 PC#7c/PC#7d) |
| **VP-SKILL-067** *(NEW v1.2)* | **SLA surface-never-assume (ADV-F2-P2-009b — BC-4.02.001 Inv#5):** append-comment (PC#7a), link-related (PC#7b), and propose-reopen (PC#7c) actions each emit an explicit SLA-impact statement before executing/proposing; when SLA data is not retrievable from `jr issue view` the statement reads "SLA: unknown — do not assume compliant"; the skill NEVER silently assumes SLA compliance | B-INT + B-STR | jr-mock ticket WITH an SLA deadline → assert output contains "SLA impact:" with the deadline; jr-mock ticket WITHOUT retrievable SLA → assert "SLA: unknown — do not assume compliant"; assert an append/link/propose path never omits the statement; **static** grep of `update-jira/SKILL.md` for the SLA-statement format | BC-4.02.001 (v1.12 Inv#5, §3.5) |
| **VP-SKILL-068** *(NEW v1.2)* | **grace-window + Jira-first dedup (ADV-F2-P2-009c — D-DEC-002 / BC-10.01.001 Inv#8):** a late/out-of-order OCSF event re-fetched inside the watermark grace window (`WATERMARK_GRACE_SECONDS`, default 300s) that already has an existing OPEN Jira ticket results in an append-COMMENT on that ticket (Jira-first dedup), NOT a new ticket; an in-grace event with NO existing ticket takes the normal create path. (VP-SKILL-050 remains watermark-monotonicity only.) | B-INT | prism-DTU seeds an event whose normalized `_time` falls in `[watermark − GRACE, watermark]`; jr-mock returns an existing open ticket for that event → assert `jr issue comment` (append) fired and `jr issue create` NOT fired; boundary leg: same event, jr-mock returns zero open tickets → assert create path; RFC3339 UTC-Z `_time` normalization applied before comparison | BC-10.01.001 (v1.19 Inv#8, D-DEC-002) |
| **VP-SKILL-069** *(NEW v1.3)* | **investigate-event PrismQL org_slug scoping (ADV-F2-P3-004 — BC-5.01.001 Inv#8):** every investigate-event PrismQL query — the Stage-3 raw OCSF event lookup and the ±5-minute temporal-adjacency query (BC-5.01.001 §3.8 PC#7 Stage 3) — always includes an explicit `org_slug='<org_slug>'` WHERE clause for the current org context (D-DEC-005); an unscoped query is rejected; a query issued in org-a context returns zero org-b/c rows. Distinct from VP-SKILL-064 (monitoring-loop-only) and VP-SKILL-059 (scan-threats-only). | B-STR + B-INT | **static** Iron-Law content assertion on `investigate-event/SKILL.md` (every PrismQL block carries `WHERE org_slug=`); prism-DTU multi-org fixture (org-a/b/c, `--config-dir <tmpdir>`) — org-a Stage-3 + temporal-adjacency queries return zero org-b/c rows; **adversarial** unscoped-query fixture → rejected/scoped | BC-5.01.001 (v1.12 Inv#8, PC#7 Stage 3, D-DEC-005) |
| **VP-SKILL-070** *(NEW v1.3)* | **assess-priority PrismQL org_slug scoping (ADV-F2-P3-004 — BC-4.05.001 Inv#4):** every assess-priority PrismQL query (PC#5a 30-day baseline, PC#5b NVD/ThreatIntel enrichment, PC#5d asset-criticality lookup) always includes an explicit `org_slug` WHERE clause (D-DEC-005); unscoped queries rejected; org-a query returns zero org-b/c rows. | B-STR + B-INT | **static** Iron-Law content assertion on `assess-priority/SKILL.md` PrismQL blocks (PC#5a/5b/5d each carry `WHERE org_slug=`); prism-DTU multi-org fixture — org-a query returns zero org-b/c rows; **adversarial** unscoped-query → rejected/scoped | BC-4.05.001 (v1.4 Inv#4, PC#5a/5b/5d, D-DEC-005) |
| **VP-SKILL-071** *(NEW v1.3)* | **assess-priority confidence float→enum consistency (ADV-F2-P3-008 — BC-4.05.001 PC#6 / D-DEC-011):** for every `confidence_score` float output, the paired `confidence` enum matches the D-DEC-011 canonical thresholds — `high` iff `confidence_score ≥ 0.75`, `medium` iff `0.40 ≤ confidence_score < 0.75`, `low` iff `confidence_score < 0.40`; an inconsistent pair (e.g. `confidence_score=0.85` with `confidence='low'`) is invalid; boundary values 0.75 and 0.40 map to the higher tier. This is the producer-side guarantee that the enum handed to verdict field #2 is well-formed before disposition-guard's enum type-assertion (VP-HOOK-025) sees it. | B-INT (boundary/property) | boundary fixtures at and around each threshold: `0.75→high`, `0.749→medium`, `0.40→medium`, `0.399→low`, `1.0→high`, `0.0→low`; assert emitted `confidence` enum matches; inconsistency fixture (`0.85`/`low`) → flagged invalid; enum is one of {high,medium,low} (never a float) | BC-4.05.001 (v1.4 PC#6, D-DEC-011) |
| **VP-HOOK-028** *(NEW v1.3; **property (1) REWRITTEN v1.19 — P17-002**)* | **Property (1) — JSON-first fail-closed residual boundary (REWRITTEN v1.19, ADV-F2-P17-002; supersedes the dead `verdict`-substring premise):** a monitoring-loop Stage-7 Write whose path has **NEITHER a `.json` extension NOR JSON-parseable content (`jq empty` fails) NOR matches the `*investigation-*.md` glob** causes disposition-guard to **fast-path-allow WITHOUT ICD-203 validation and WITHOUT marker issuance**; consequently the downstream Stage-8 `jr` write is **DENIED** by require-review (no marker to consume). This is the ACTUAL residual fail-closed boundary under JSON-first dispatch — a genuinely-non-dispatching artifact (no verdict class, no markdown class) fails closed at the consumer (denies the action), never fail-open. **~~(retired v1.19 — dead under JSON-first, reason 'P17-002')~~ the prior property-(1) premise ("a Write to a path NOT containing the `verdict` substring → fast-path-allow → mis-named verdict path is fail-closed") is FALSE: under JSON-first dispatch a JSON verdict written to ANY `.json` path (or any path whose content parses as JSON) routes to the verdict-class 18-field path and EMITS a marker regardless of the `verdict` substring — so the "mis-named verdict path is fail-closed" property no longer exists.** **Property (2) — JSON-first dispatch precedence (the AUTHORITATIVE dispatch rule; v1.5, ADV-F2-P4-001 CRITICAL): the canonical verdict path `artifacts/investigations/verdict-<id>-<iso_ts>.json` contains BOTH the `investigation` and `verdict` substrings; dispatch MUST be JSON-first — a file ending in `.json` OR whose content parses as JSON (`jq empty`) routes to the verdict-class 18-field path REGARDLESS of any `investigation`/`verdict` substring; ONLY a `*investigation-*.md` file routes to the 12-field markdown path. Without this precedence the canonical verdict JSON is misrouted to the heading-grep branch, fails all `## `-heading assertions, is DENIED, emits no marker, and the entire autonomous pipeline is unreachable.** **Self-contradiction RESOLVED (P17-002): property (2) is the authoritative dispatch rule; property (1) now states ONLY the fast-path-allow residual for the genuinely-non-dispatching path (non-.json ext, non-JSON content, non-`*investigation-*.md`) — the two are consistent (property (1) no longer claims a `.json`/JSON verdict fast-path-allows).** | B-INT-XH | **Property-(1) boundary (REWRITTEN v1.19, P17-002):** disposition-guard.sh on a Write to `artifacts/notes/alert-001.txt` — **no `.json` extension, plain-text (non-JSON) content (`jq empty` FAILS), not `*investigation-*.md`** → assert fast-path-allow + marker-store dir stays EMPTY; then require-review.sh on the matching Stage-8 `jr` Bash → assert **deny** (no marker to consume). **~~RETIRED v1.19 (reason 'P17-002 — dead under JSON-first dispatch'; history preserved, no re-run):~~** ~~"Negative: Write to `artifacts/findings/alert-001.json` (no `verdict` substring) → marker-store EMPTY → jr deny"~~ (a `.json` file routes to the verdict class under JSON-first and DOES emit a marker — the old negative assertion is tautologically-false against a real verdict). **Added JSON-first positive vectors (P17-002 — confirm property (2) fires, NOT fast-path-allow):** `.json`-path WITHOUT the `verdict` substring carrying valid 18-field JSON content — `artifacts/findings/alert-001.json` → JSON-first dispatch FIRES → ICD-203 18-field validation → marker emitted (NOT fast-path-allow); non-`.json`-path with JSON-parseable content — `artifacts/investigations/alert-001` (JSON body) → JSON-first dispatch FIRES → ICD-203 validation path entered. **v1.5 canonical-path dispatch legs (property (2), SM-34 kill): `artifacts/investigations/verdict-alert-001.json` (BOTH substrings) → JSON-first → 18-field verdict path → marker emitted (POSITIVE, not misrouted to markdown); a genuine `artifacts/investigations/investigation-001.md` → 12-field markdown path.** Shared `CLAUDE_PLUGIN_DATA=$(mktemp -d)` across the two subprocess hooks | BC-10.01.001 (v1.19 Stage-7 PC#8, D-DEC-008); enforced by BC-3.03.001 (v1.25 PC#1/2/3 JSON-first) + BC-3.01.001 (v1.22 consume) |
| **VP-HOOK-029** *(NEW v1.5; RE-SCOPED v1.8/v1.9/**v1.10 end-to-end**; **re-FINALIZED v1.10**, **P0**)* | **End-to-end consumer-boundary fail-loud invariant (D-DEC-012 / ADV-F2-P7-001 CRITICAL / P7-004 MAJOR — O4 standing rule; re-scoped from the v1.9 emitter-only marker-in-store assertion; re-FINALIZED v1.10):** for a hard-floor / Indeterminate / silent-sensor verdict carrying **ANY** `ticket_action_type`, VP-HOOK-029 asserts the CONSUMER-OBSERVABLE outcome (per §0 O4 — an emitter-local marker/audit artifact is NOT sufficient evidence): **(a) review token (`create-review`/`comment-review`):** STEP 3 issues the restricted marker AND a correctly-labeled `jr` write is authorized and CONSUMABLE at consumer STEP 6a (the human-surface jr write actually occurs) — NEVER an unconsumable marker (wrong command type / missing `--label`); **(b) non-review token (incl. `none`):** STEP 4 **DENIES the verdict Write** with a structured machine-readable corrective reason (`hard_floor_trigger`, `required_token`, `label_instruction`, `instruction`) + an **UNDER-LABEL-DENIED** audit entry, NO marker is issued, NO Jira write occurs; on the loop's corrected re-document (Write re-issued with `required_token`) path (a) fires; NEVER a silent allow, NEVER a marker in the store for the denied Write. **v1.10 pass-7 redesign (ADV-F2-P7-001 CRITICAL / P7-004 MAJOR):** the v1.9 STEP-4 marker-*upgrade* mechanism is **RETIRED** — P7-001 proved disposition-guard can rewrite the marker but not the loop's future Bash command, so the upgraded `create-review` marker was structurally unconsumable by the loop's own non-review `jr` command (3 of 4 under-label action types silently dropped the finding). DENY-AT-WRITE is the only deterministic lever at the point the LLM can still react. STEP 4 still runs **before the STEP 5 kill switch**, so the deny fires regardless of `autonomy_enabled` (kill-switch-irrelevance). The old emitter-only assertion ("marker exists OR error artifact written") could NOT detect the unconsumable-marker seam gap (P7-004). Enforced deterministically at the hook (STEP 4 deny), NOT delegated to the trusted-LLM SKILL.md layer. **v1.11 EXTENSION (ADV-F2-P8-001 CRITICAL — additive to the deny-path set; VP stays FINALIZED P0, NOT re-scoped):** the fail-loud invariant is extended to the STEP-3 *correctly-labeled-yet-unbindable* sub-case. A hard-floor verdict carrying a CORRECT review token but whose non-ICD-203 operational binding field is null (`create-review` + null/empty `jira_project_key`; `comment-review` + null `ticket_id`) previously hit a silent `emit allow without marker; RETURN` at STEP 3 — the P5-001/P7-001 silent-discard anti-pattern surviving on the review path (`jira_project_key`/`ticket_id` are NOT in the 18-field presence check nor `validate_enums()`, so the sub-case slipped every prior gate). The redesigned D-DEC-008 STEP 3 (architecture-delta v1.11) replaces both branches with a **`HARD-FLOOR-UNBINDABLE` DENY-THE-WRITE** per D-DEC-012 clause 2: WRITE a `HARD-FLOOR-UNBINDABLE` audit entry naming the `missing_field`, and emit `deny` with a structured corrective reason (`hard_floor_trigger`, `missing_field`, re-issue instruction; the comment-review branch adds a create-review fallback hint when `jira_project_key` IS present). Bounded non-termination mirrors STEP 4 — one `HARD-FLOOR-UNBINDABLE` audit entry + one deny per re-doc attempt, no Jira write, no silent loop. | B-BEH + B-INT-XH | disposition-guard.sh + require-review.sh on hard-floor verdicts, shared `CLAUDE_PLUGIN_DATA=$(mktemp -d)`. **DENY-PATH vectors (non-review token → deny-the-Write):** (1) `disposition=Indeterminate` + `ticket_action_type=create` (+ `jira_project_key="PRISMDEMO"`) → assert the verdict Write is **DENIED** (permissionDecision=deny), NO marker written, `UNDER-LABEL-DENIED` line in `audit.log`; (2) `severity=HIGH` + `ticket_action_type=none` → verdict Write **DENIED**, NO marker, `UNDER-LABEL-DENIED` audit; (3) degraded/silent sensor + `ticket_action_type=assign` (+ `ticket_id="SEC-123"`) → **DENIED** + `UNDER-LABEL-DENIED` audit; (4) **machine-actionable-reason assertion (SM-39 kill):** `Indeterminate` + `ticket_action_type=none` + `ticket_id="SEC-123"` present → deny reason parses with `required_token=comment-review` AND `hard_floor_trigger` non-empty (the loop can act on it); `ticket_id=null` + project_key present → `required_token=create-review` + `label_instruction` names `--label (REVIEW-REQUIRED\|BLIND-SPOT)` SECOND after `--project`; **corrected-rewrite HAPPY PATH (5):** after a STEP-4 deny, the loop re-issues the verdict Write with `ticket_action_type=create-review` → assert STEP 3 now creates a `create-review` marker in the store (the deny is recoverable, not terminal); **CONSUMER-BOUNDARY vectors (6/7) — the O4 core:** (6) a `create-review` marker + a correctly-labeled `jr issue create --project PRISMDEMO --label REVIEW-REQUIRED …` → require-review **ALLOW** (marker consumed — the escalation jr write is authorized and executes); (7) a `create-review` marker + `jr issue create --project PRISMDEMO` WITHOUT `--label` → require-review **DENY** (proves the store never holds a marker the loop's own command cannot consume — the P7-001 seam gap is closed at the consumer boundary); **KILL-SWITCH-IRRELEVANCE vector (8):** the STEP-4 deny fires identically with `autonomy_enabled=true` AND `autonomy_enabled=false` (STEP 4 precedes STEP 5) — assert `UNDER-LABEL-DENIED` + deny in BOTH cases (kills SM-32-ext); **UNBINDABLE-DENY vectors (9/10/11) — v1.11 STEP-3 correctly-labeled-yet-unbindable sub-case (ADV-F2-P8-001 CRITICAL; kill SM-41):** (9) `disposition=Indeterminate` (or silent-sensor BLIND-SPOT) + `ticket_action_type=create-review` + `jira_project_key` null/empty → assert the verdict Write is **DENIED** (permissionDecision=deny), NO marker in the store, a `HARD-FLOOR-UNBINDABLE` line in `audit.log` naming `missing_field=jira_project_key`, NO Jira write — **NEVER a silent allow-without-marker** (the D-DEC-012 clause-2 invariant); (10) hard-floor + `ticket_action_type=comment-review` + `ticket_id` null + `jira_project_key="PRISMDEMO"` present → **DENIED** + `HARD-FLOOR-UNBINDABLE` (`missing_field=ticket_id`), and the corrective reason contains the create-review fallback hint (`jira_project_key` present ⇒ suggests `ticket_action_type=create-review`); (11) hard-floor + `comment-review` + BOTH `ticket_id` AND `jira_project_key` null → **DENIED** naming BOTH missing fields (re-issue with ticket_id for comment-review or jira_project_key for create-review); bounded-non-termination leg — a re-doc that STILL omits the binding field → a second `HARD-FLOOR-UNBINDABLE` audit entry + deny, still no Jira write (no silent loop); **DEDUP-BEFORE-FALLBACK vector (12) — v1.12 STEP-3 comment-review fallback-hint dedup gate (ADV-F2-P9-007 MINOR; test-only, NO mutant):** `ticket_action_type=comment-review` + `ticket_id` null + `jira_project_key="PRISMDEMO"` present → the `HARD-FLOOR-UNBINDABLE` deny reason's fallback hint instructs the loop to **re-run the §3.4 BLIND-SPOT/REVIEW-REQUIRED dedup query for this (org_slug, sensor_id) BEFORE switching to `create-review`** (not a bare "try create-review") — because a null `ticket_id` may be a dedup-lookup MISS rather than true absence of a ticket; assert the deny reason text contains the dedup-re-run instruction (a dedup HIT ⇒ append-COMMENT on the existing ticket, NEVER a duplicate `create-review` per D-DEC-004 one-open-ticket-per-(org,sensor)). The loop-side "dedup HIT → comment, not a second create" behavior is discharged by **VP-SKILL-068** (grace-window + Jira-first dedup); this hook-side vector only asserts the corrective-reason TEXT carries the dedup obligation. No paired mutant (architect §8.21 item 2 — the change is in the deny-reason text, not a security-critical control-flow branch). **MARKER-WRITE-FAILED FAIL-CLOSED vectors (13/14) — v1.13 WRITE_MARKER failure on the hard-floor review path (ADV-F2-P10-003 MAJOR; kill SM-45):** (13) `disposition=Indeterminate` (or silent-sensor BLIND-SPOT) + `ticket_action_type=create-review` + a correctly-bound marker whose `write_marker(...)` FAILS (simulate an unwritable/full `${CLAUDE_PLUGIN_DATA}/markers/` dir) → assert the verdict Write is **DENIED** (permissionDecision=deny), a `MARKER-WRITE-FAILED` line in `audit.log` naming the unwritable marker path + `hard_floor_trigger`, NO Jira write — **NEVER allow-without-marker** (the review path is `is_review_path=TRUE`, so it fails closed, mirroring HARD-FLOOR-UNBINDABLE per D-DEC-012 clause 2); (14) same for `ticket_action_type=comment-review` + simulated write failure → **DENIED** + `MARKER-WRITE-FAILED`; **REGULAR-PATH CONTROL (14a):** a non-hard-floor `ticket_action_type=comment` (`is_review_path=FALSE`) + simulated write failure → **allow-without-marker** (NO deny) — safe because require-review then DENIES the downstream `jr` call (no marker in store = the human gate still holds); this control leg proves the fail-closed behavior is scoped to the review path ONLY. **fail-loud assertion (all branches): assert NOT (silent allow-without-marker on the hard-floor review path) AND NOT (marker in store that no matching command can consume) — the guarantee is the downstream jr authorization/execution outcome, not marker presence.** **RETIRED v1.9 upgrade-marker vectors (reason "mechanism removed ADV-F2-P7-001"; history preserved, no re-run):** ~~"Indeterminate+comment+ticket_id → comment-review marker in store"~~, ~~"HIGH+create+ticket_id null+project_key → create-review marker in store"~~, ~~"Indeterminate+none+ticket_id null+project_key → create-review marker in store"~~, and the ~~`UNDER-LABEL-CORRECTED` audit assertion~~ (superseded by `UNDER-LABEL-DENIED`). **Paired mutants: SM-38 (remove the STEP-4 deny → silent emit-allow-without-marker) killed by the deny-path vectors (1)–(3); SM-39 (remove the corrective-reason structure → deny fires but the loop cannot act) killed by vector (4); SM-32a (re-targeted: revert the STEP-4 deny to the retired GOTO-WRITE_MARKER upgrade → unconsumable marker in-store) killed by consumer-boundary vector (7); SM-32-ext (revert STEP 4/5 order → kill switch silently allows first) killed by the kill-switch-irrelevance vector (8); SM-41 (v1.11 — revert the STEP-3 create-review null-`jira_project_key` branch to emit-allow-without-marker → the pre-P8-001 silent-discard) killed by the unbindable-deny vectors (9)–(11), separately killable from SM-38 (which reverts the STEP-4 under-label deny); **SM-45 (v1.13 — revert the WRITE_MARKER review-path branch to emit-allow-without-marker regardless of `is_review_path` → a hard-floor review marker that fails to write is silently allowed with no ticket, no deny, no audit) killed by the MARKER-WRITE-FAILED review-path vectors (13/14), separately killable from SM-41 (STEP-3 unbindable, a DIFFERENT branch — null binding field vs write-syscall failure) and SM-38 (STEP-4 under-label).** | BC-10.01.001 (v1.19 Inv#10 narrowed + STEP 3 `HARD-FLOOR-UNBINDABLE` deny + STEP 4 DENY-THE-WRITE, D-DEC-012); enforced by BC-3.03.001 (post-pass-10 STEP 4 deny + UNDER-LABEL-DENIED audit + **WRITE_MARKER review-path MARKER-WRITE-FAILED fail-closed, P10-003**) + BC-3.01.001 (v1.22 consume create-review/comment-review + STEP 6a structural label match) |
| **VP-SKILL-072** *(NEW v1.5)* | **First-run 24h lookback correctness (ADV-F2-P4-012 — BC-10.01.001 Inv#13 / EC-001 / D-DEC-002):** when NO watermark file exists for an org×sensor pair (first invocation), the loop's Stage-1 query is bounded to `WHERE _time >= now() - INTERVAL 24 HOURS` (never a full-history scan), and after a successful run the watermark is persisted to the most-recent processed event `_time`. Distinct from VP-SKILL-050 (monotonicity on an EXISTING watermark). | B-INT | Run loop stub with an EMPTY `CLAUDE_PLUGIN_DATA/watermarks/` dir (no file for org×sensor); assert the emitted PrismQL carries the `now() - INTERVAL 24 HOURS` lower bound (and NOT an unbounded / full-history query); after run, assert a watermark file is persisted at the latest processed `_time`; control: pre-existing watermark → assert the 24h-lookback branch is NOT taken (query uses the watermark bound) | BC-10.01.001 (v1.19 Inv#13, EC-001, D-DEC-002) |
| **VP-SKILL-073** *(NEW v1.9, **P1**)* | **Late-event drop detection (ADV-F2-P6-007 — D-DEC-002 / BC-10.01.001 Stage-1):** when an ingested event's normalized `_time` is older than `watermark − WATERMARK_GRACE_SECONDS` (i.e. it arrived in-window this run but would fall outside the window next run), `DETECT_LATE_EVENT()` emits a `LATE_EVENT_DETECTED` audit entry to `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log`; the event is **NOT dropped** — it proceeds to the VALIDATE stage and is processed normally. This converts the D-DEC-002 grace-window permanent-drop trade-off from a SILENT data-loss path into an AUDITABLE one (operators tune `WATERMARK_GRACE_SECONDS` from the log). Distinct from VP-SKILL-068 (in-grace dedup) and VP-SKILL-050 (monotonicity). | B-INT | Run loop stub with a pre-existing watermark; inject an OCSF event whose normalized `_time < watermark − WATERMARK_GRACE_SECONDS`; assert a `LATE_EVENT_DETECTED` line is present in `watermarks/audit.log` (with `event_time=`, `watermark=`, `grace_window=`) AND the event still reaches VALIDATE (not silently discarded); control leg: an event with `_time ≥ watermark − GRACE` → NO `LATE_EVENT_DETECTED` line; first-run (no watermark) → `DETECT_LATE_EVENT` returns early, no false positive | BC-10.01.001 (v1.19 Stage-1, D-DEC-002 late-event fail-loud) |
| **VP-SKILL-074** *(NEW v1.9, **P1**; namespace correction — architect §8.15 item 3 said "VP-SKILL-072", occupied)* | **Severity normalization correctness (ADV-F2-P6-005 — D-DEC-013 / BC-10.01.001 Stage-1/Stage-5):** `NORMALIZE_SEVERITY(native_severity, sensor_family)` produces ONLY members of `{LOW,MEDIUM,HIGH,CRITICAL}` (case-exact, so the downstream `validate_enums()` gate never fail-closed-denies a well-normalized verdict); each of the FOUR sensor families maps per the D-DEC-013 table (CrowdStrike numeric 1-100 boundaries 26/51/76; Armis/Claroty risk bands 1:1 case-fold, Armis Informational→LOW; Cyberint conservative default pending ASM-008); an UNRECOGNIZED native value (any family, incl. Cyberint pending ASM-008) → `CRITICAL` WITH `uncertainty_explicit` appended (an AUDITABLE conservative default — NEVER a silent enum-deny, and NEVER a silent LOW). Applied at Stage 1 INGEST and re-applied at Stage 5 SCORE (and Stage 1 known-FP fast-path). | B-INT (boundary/equivalence-partition) | boundary fixtures per family — CrowdStrike `{25→LOW, 26→MEDIUM, 50→MEDIUM, 51→HIGH, 75→HIGH, 76→CRITICAL}`; Armis `{Critical→CRITICAL, Informational→LOW}` case-fold; Claroty risk-band case-fold; assert the emitted `verdict.severity` ∈ the four-value enum (case-exact); **(P14-001 / P11-003 correction: NVD/CVSS is NOT a NORMALIZE_SEVERITY family — `sensor_family` has no `nvd` member; a 0.0–10.0 CVSS float is enrichment that feeds `scored_priority` (field 18) at Stage 5, NOT `native_severity`. No CVSS→severity boundary fixture belongs in this VP; NORMALIZE_SEVERITY is authoritative ONLY over sensor_family ∈ {crowdstrike, armis, claroty, cyberint}.)**; **unrecognized fixture (e.g. CrowdStrike `"Sev5"`) → assert `verdict.severity=="CRITICAL"` AND `verdict.uncertainty_explicit` is non-null and contains the "Unrecognized severity" annotation** (auditable, not a deny); assert NO raw sensor-native string reaches `validate_enums()`. **v1.10 Cyberint partition (ADV-F2-P7-006 MINOR, D-DEC-013 explicit conservative default):** Cyberint is a RECOGNIZED family whose per-band mapping is COMPUTE-AT-VALIDATION pending ASM-008, so it gets the explicit conservative default (mirrors the unrecognized-family rule, but named): (i) `cyberint-any-native-severity-to-CRITICAL` — any Cyberint native severity value (org-b demo path, brief §4.2) → `verdict.severity=="CRITICAL"` (pre-ASM-008 conservative default; enum-valid from first Cyberint contact); (ii) `cyberint-never-LOW-MEDIUM-HIGH-pre-ASM-008` — a Cyberint severity NEVER normalizes to LOW/MEDIUM/HIGH until ASM-008 resolves (no accidental down-tiering of an unvalidated family); (iii) `cyberint-CRITICAL-carries-uncertainty_explicit` — the CRITICAL output includes `uncertainty_explicit` naming the unvalidated mapping ("Cyberint severity mapping unvalidated per ASM-008; conservative CRITICAL applied until validated"). **Annotation: these three assertions are pre-ASM-008 invariants — UPDATE WHEN ASM-008 RESOLVES and the validated Cyberint per-band mapping is specified (then partitions (i)/(ii) are replaced by the real band boundaries).** | BC-10.01.001 (v1.19 Stage-1/Stage-5 field 13, D-DEC-013) |
| **VP-HOOK-030** *(NEW v1.13, **P0**; DOWNGRADED v1.14 to a CONSISTENCY VP — ADV-F2-P11-001 CRITICAL)* | **STEP 1a severity CONSISTENCY check / SEVERITY-MISMATCH (D-DEC-008/D-DEC-013 — O6 standing rule §0, consistency-only per P11-001):** disposition-guard STEP 1a (after the STEP-1 enum/presence gate, before STEP 3) re-runs `recomputed_severity = NORMALIZE_SEVERITY(verdict.native_severity, verdict.sensor_family)` using the D-DEC-013 deterministic table (a pure sensor-native-value + sensor-family lookup, no prism dependency); **IF `recomputed_severity != verdict.severity` → WRITE a `SEVERITY-MISMATCH` audit entry + emit `deny` (verdict Write refused)**. **ASSERTED GUARANTEE (P11-001 reframe): `verdict.severity` is CONSISTENT with `verdict.native_severity` per the D-DEC-013 NORMALIZE_SEVERITY table — NOT ground-truth enforcement.** `native_severity` (field 16) and `sensor_family` (field 17) are BOTH written by the monitoring-loop LLM at Stage-1 INGEST and read verbatim; the network-free hook makes no prism call, so STEP 1a is a deterministic CONSISTENCY CHECK between two LLM-supplied fields — it hardens against a careless/buggy LLM but CANNOT detect an adversarial LLM that supplies a false native_severity+sensor_family pair. The pass-10 "un-bypassable / hook independently derives severity from raw sensor values / genuinely deterministic for severity" language is **WITHDRAWN as FALSE (P11-001)**. **Residual (ASM-008-DEFERRED, SYMMETRIC with the asset_type residual):** genuine severity ground-truth requires a prism-signed severity field or hook-fetched prism data (network-free hooks cannot provide it) — a pre-production follow-up, identical in kind to the asset_type `prism_asset_class` cross-validation residual. **NOTE:** the HIGH/CRIT hard floor keys on `verdict.scored_priority` (field 18 — VP-HOOK-026, P11-002), NOT on recomputed severity; STEP 1a is only the severity↔native_severity consistency cross-check. | B-BEH | disposition-guard.sh stdin `{tool_input.file_path, content}`, verdict carrying fields 16/17. **Per-family SEVERITY-MISMATCH (consistency) vectors (recomputed ≠ reported → deny, NO regular marker, SEVERITY-MISMATCH in audit.log — these verify the consistency check, NOT ground-truth):** (1) `sensor_family=crowdstrike`, `native_severity="90"` (→CRITICAL per the 76 boundary) + `verdict.severity="LOW"` → **DENY**; (2) `sensor_family=armis`, `native_severity="Critical"` (band→CRITICAL) + `verdict.severity="MEDIUM"` → **DENY**; (3) `sensor_family=claroty`, `native_severity="High"` (band→HIGH) + `verdict.severity="LOW"` → **DENY**; (4) `sensor_family=cyberint`, `native_severity="<any>"` (conservative default→CRITICAL pre-ASM-008) + `verdict.severity="LOW"` → **DENY**. *(v1.14/P11-003 — the pass-10 NVD/CVSS-float under-report vector (5) is REMOVED: per the clean separation, CVSS/NVD enrichment influences `scored_priority` (Stage-5), NOT `native_severity`; `sensor_family` has no `nvd` member, so a CVSS float is never a hook-checked `native_severity` source.)* **AGREEMENT (known-good) vector:** `sensor_family=crowdstrike`, `native_severity="90"` + `verdict.severity="CRITICAL"` → NO SEVERITY-MISMATCH, STEP 1a passes. **MISSING-FIELD vectors (STEP-1 gate, shared with VP-HOOK-025):** `native_severity` absent/empty → DENY (field 16 required); `sensor_family` absent or `="unknown_vendor"` → enum DENY (field 17 required) — an enum deny, NOT a SEVERITY-MISMATCH. Paired mutant **SM-44** (revert STEP 1a — remove the consistency cross-check) killed by the mismatch vectors (1)–(4): under the mutant a `native_severity=90`/`verdict.severity=LOW` crowdstrike verdict produces NO SEVERITY-MISMATCH deny → the consistency guarantee is lost → mutant dies. | BC-3.03.001 (post-pass-11 STEP 1a consistency check, D-DEC-008/D-DEC-013); BC-10.01.001 (v1.19 18-field schema, fields 16/17, D-DEC-013) |
| **VP-HOOK-031** *(NEW v1.14, **P0**; ADV-F2-P11-004 MAJOR; UPDATED v1.15 four-guarantee redesign, ADV-F2-P12-002 CRITICAL; **UPDATED v1.16 — MARKDOWN_COMMENT_PATH ELIMINATED, ADV-F2-P13-001 CRITICAL + strict parse grammar, ADV-F2-P13-003 MAJOR**)* | **Separate human-comment marker path (investigation-markdown; P11-004 → P12-002 → P13-001):** the 12-field ICD-203 investigation-markdown path (`*investigation-*.md`) does **NOT** enter the verdict emitter — it executes a SEPARATE, minimal marker path that does **NOT** call `validate_enums()` / STEP 1a (both reference verdict-only fields absent from a 12-field markdown, incl. `severity`/`asset_type`/`ticket_action_type`/`native_severity`/`sensor_family`/`scored_priority`). **v1.16 (P13-001 CRITICAL, per human decision 2026-07-22 / architecture-delta v1.16 §8.29 / D-DEC-008) — MARKDOWN_COMMENT_PATH ELIMINATED: the markdown path NEVER issues an autonomous `["comment"]` marker for ANY disposition** — the hook cannot evaluate `scored_priority` (field 18) or `asset_type` (field 14) from a 12-field markdown, and there is no known-FP store cross-check on this path, so no comment marker can be floor-enforced (P12-002's GATE 1 closed the TP/BTP masquerade but left a residual FP-branch that granted an autonomous comment marker with no scored_priority/asset_type enforcement — P13-001 closes it). **Gating sequence:** (1) **kill switch** — `autonomy_enabled` read FIRST; absent/≠true → **allow-without-marker for ALL dispositions** (short-circuits BEFORE disposition routing, mirroring STEP-5 semantics); (2) 12-field completeness; (3) markdown-evaluable hard floors (`Disposition: Indeterminate` / forbidden technique ∈{T1003,T1068,T1021,T1041} / `Sensor Health Status: degraded\|silent`) → `MARKDOWN-HARD-FLOOR` deny; (4) NO validate_enums/STEP-1a. **Disposition routing after floors pass (P13-001):** `parsed_disposition == FP` → **allow-without-marker** (Write succeeds, NO Jira action authorized, NO comment marker written — the analyst surfaces an FP comment via the review path or the normal 18-field verdict flow; P11-004 human-analyst intent preserved, the Write is NOT denied); **ELSE (non-FP TP/BTP / PARSE_FAIL) → MARKDOWN_REVIEW_PATH** (comment-review if `ticket_id` present, create-review if null, `MARKDOWN-HARD-FLOOR-UNBINDABLE` deny if both `ticket_id` and `jira_project_key` null; EXEMPT from the kill switch, same as regular STEP 3). **Guarantee (c) REWRITTEN (P13-001): NO disposition yields an autonomous `["comment"]` marker from the markdown path — FP → allow-without-marker; non-FP/PARSE_FAIL → review marker** (the v1.15 'disposition=FP + floors pass → comment marker' guarantee is ELIMINATED). (a) `autonomy_enabled` absent/≠true → allow-without-marker; (b) markdown-evaluable floor → deny; (d) `ticket_id` charset-validated `^[A-Z][A-Z0-9]+-[0-9]+$` (P12-001/VP-HOOK-032/O7). **Strict parse grammar (P13-003 MAJOR):** `parse_disposition_from_markdown` reads ONLY the canonical `Disposition` heading value against the {TP,FP,BTP,Indeterminate}(+canonical long-form) allowlist → **PARSE_FAIL** on ambiguous/negated/multi-valued/empty/missing/embedded-in-code-fence → treated as non-FP (review route, NEVER allow-without-marker); `parse_autonomy_enabled_from_markdown` reads ONLY a dedicated structured field, true only on explicit boolean-true (an `autonomy_enabled: true` token inside a code fence/evidence block/quoted log → false). This resolves the P11-004 impossibility (the pass-10 emitter's `validate_enums()` would deny a complete 12-field investigation at save time), the P12-002 CRITICAL (the pre-redesign path issued a live comment marker for ANY disposition under an active kill switch), AND the P13-001 CRITICAL (the P12-002 FP-branch residual — an unfloored autonomous comment). | B-BEH | disposition-guard.sh stdin `{tool_input.file_path=artifacts/investigations/investigation-ALERT-001.md, content}`. **Vectors:** **G1 kill switch —** (a1) `autonomy_enabled=false` + complete 12-field `Disposition: FP` markdown → **allow-without-marker** (no Jira action; same outcome as the P13-001 FP branch, so a1/a2 are FP positive controls, NOT SM-50 killers); (a2) `autonomy_enabled` absent + FP markdown → **allow-without-marker**; **(a3-nonFP, kills SM-50)** `autonomy_enabled=false` + complete 12-field `Disposition: TP` markdown → **allow-without-marker** (the kill switch short-circuits BEFORE disposition routing — NO review marker); under SM-50 the removed gate lets the TP reach routing → a review marker → mutant dies. **G2 markdown-hard-floor denies (autonomy_enabled=true) —** (b1) `Disposition: Indeterminate` → `MARKDOWN-HARD-FLOOR` deny; (b2) `T1068` in Attack Techniques → deny; (b3) `Sensor Health Status: degraded`/`silent` → deny. **G3 disposition routing (autonomy_enabled=true) — NO autonomous `["comment"]` marker for ANY disposition (P13-001):** **(c1 P13-001, kills SM-52)** complete 12-field `Disposition: FP` → **allow-without-marker** — Write **NOT denied**, **NO `["comment"]` marker written**, NO Jira action authorized; ~~**(c1-old — RETIRED v1.16; reason 'MARKDOWN_COMMENT_PATH eliminated ADV-F2-P13-001'; history preserved, no re-run)** `Disposition: FP` + floors pass → `["comment"]` marker bound to the parsed `ticket_id`~~; **(c2, kills SM-51)** complete 12-field `Disposition: TP` → **create-review/comment-review (review) marker** (NOT a regular comment, NOT allow-without-marker); (c3) complete 12-field `Disposition: BTP` → **review marker**; (c3b) `Disposition: Indeterminate` (autonomy=true) → floor-deny (b1); **(c4 masquerade)** the loop writes `investigation-TP-*.md` with scored_priority=HIGH indicators → **review marker** issued, an autonomous comment is **NOT** issued; **(c5 PARSE_FAIL)** disposition value 'probably FP' → PARSE_FAIL → **review marker** (NEVER allow-without-marker). **G3-parse — strict parse-grammar adversarial vectors (P13-003; kill SM-53):** (p1 negated-FP) `Disposition` heading value 'not a false positive' → PARSE_FAIL → **review** (NOT read as FP); (p2 negated-FP-2) `Disposition: not FP — TP` → parsed non-FP → **review**; **(p3 FP-in-code-fence, kills SM-53)** a `Disposition: FP` string appears ONLY inside a fenced code block / evidence block and no canonical `Disposition` heading value is present → NOT matched (canonical-heading-anchored parse) → PARSE_FAIL → **review**; under SM-53's full-document substring scan the embedded FP is read → allow-without-marker → mutant dies; (p4 multi-valued) `Disposition: FP or BTP` → PARSE_FAIL → **review**; (p5 empty-heading) `Disposition:` present but value empty → PARSE_FAIL → **review**; (p6 canonical-FP positive control) `Disposition: FP` exactly → parsed FP → **allow-without-marker**; (p7 canonical-long-form) `Disposition: False Positive` → parsed FP → **allow-without-marker**; **(p8 autonomy-in-code-fence)** an `autonomy_enabled: true` token appears ONLY inside a code fence / evidence block, no dedicated structured field → gate **CLOSED** (false) → **allow-without-marker**; (p9 autonomy-in-evidence) same token in a quoted log evidence block → gate CLOSED → allow-without-marker; (p10 autonomy-top-level-true positive control) dedicated `Autonomy Enabled: true` structured field → gate OPENS. **G4 no validate_enums/STEP-1a on markdown —** (d) a complete 12-field markdown with NO `scored_priority`/`severity`/`sensor_family` (verdict-only fields) is **NOT** denied by `validate_enums()`/STEP 1a; missing one of the 12 ICD-203 fields → 12-field completeness deny (NOT an enum-validation deny). (ticket_id charset vectors on the markdown path are owned by **VP-HOOK-032**, P12-001/O7.) **Paired mutants: SM-47** (route the 12-field markdown into the verdict emitter) killed by (d)/(c1): a compliant 12-field markdown hits `validate_enums()` → wrongly DENIED → dies; **SM-50** (remove the markdown-path `autonomy_enabled` kill-switch gate) killed by the non-FP kill-switch vector (a3-nonFP): under the mutant an `autonomy=false` TP markdown reaches routing → a review marker instead of allow-without-marker → dies (the FP vectors a1/a2 are positive controls only — FP → allow-without-marker with or without the gate, so they do NOT distinguish SM-50); **SM-51** (remove the non-FP→review routing rule → non-FP falls through to allow-without-marker like FP) killed by vector (c2): under the mutant a `Disposition: TP` markdown gets allow-without-marker instead of a review marker → the escalation-worthy finding is silently not surfaced → dies; **SM-52** (revert P13-001 — the FP branch issues a `["comment"]` marker, the pre-elimination P12-002 behavior) killed by vector (c1): the FP→allow-without-marker vector asserts NO comment marker; under SM-52 a comment marker IS issued → dies; **SM-53** (disposition parse uses a full-document substring scan instead of the canonical-heading-anchored parse) killed by vector (p3): an embedded `Disposition: FP` in a code fence is read as FP → allow-without-marker instead of review → dies. **No double-meaning across SM-50/51/52:** SM-50 = kill-switch gate removed (non-FP under kill switch wrongly routed to review); SM-51 = non-FP→review routing rule removed (non-FP wrongly gets allow-without-marker); SM-52 = FP→allow-without-marker elimination reverted (FP wrongly gets a comment marker) — three distinct branches, three distinct killer vectors. | BC-3.03.001 (disposition-guard separate human-comment marker path, P11-004; four-guarantee redesign P12-002; **MARKDOWN_COMMENT_PATH eliminated + strict parse grammar P13-001/P13-003, D-DEC-008 / §8.28.1**); consumed by BC-5.01.001 (investigate-event) + BC-4.02.001 (update-jira human comment) |
| **VP-HOOK-032** *(NEW v1.15, **P0**; ADV-F2-P12-001 CRITICAL / P12-007 OBS — the O7 compliance artifact)* | **command_pattern interpolation-safety / charset-validation (O7 §0; P12-001):** disposition-guard builds each marker's `command_pattern` by concatenating `ticket_id`/`jira_project_key` into an anchored regex that require-review later evaluates with `[[ =~ ]]`. BEFORE interpolation, the field MUST be charset-validated to its fixed Jira-key grammar (fail-closed DENY on mismatch) AND regex-escaped as defense-in-depth: **`ticket_id` ↦ `^[A-Z][A-Z0-9]+-[0-9]+$`** at STEP 6 comment, STEP 6 assign, STEP 3 comment-review, and the markdown comment path; **`jira_project_key` ↦ `^[A-Z][A-Z0-9]+$`** at STEP 3 create-review and STEP 6 create. A metacharacter-laden value (`ticket_id='.*'` → `^jr … issue comment .* ` matches ANY comment command; `ticket_id='SEC-1 \|.*#'` injects an alternation; `jira_project_key='X( \|$)\|.*'`) is DENIED with `TICKET-ID-CHARSET-DENY` / `PROJECT-KEY-CHARSET-DENY` BEFORE pattern construction — it can no longer broaden the anchored pattern (the SEC-009 class the D-DEC-001 mechanism must be impervious to). Control-char stripping (P4-010) is insufficient (does not strip `. * + ? | ( ) [ ] ^ $ \`). This is the **O7 compliance artifact** (mirrors VP-HOOK-024 = O5 for `structural_label_check`); covers all 5 command_pattern interpolation sites + the markdown path. `org_slug` is NOT interpolated into any `command_pattern` (audit-log only) — audit-only/SAFE, no O7 command_pattern VP required. | B-BEH | disposition-guard.sh stdin (verdict JSON + `*investigation-*.md`). **TICKET-ID-CHARSET-DENY vectors:** `ticket_id='.*'` on the comment path → DENY + `TICKET-ID-CHARSET-DENY` audit + verdict Write denied; `ticket_id='SEC-1 \|.*#'` (comment) → DENY; `ticket_id='.*'` on the assign path → DENY; `ticket_id='.*'` on the comment-review path → DENY; `ticket_id='.*'` parsed from an FP investigation markdown → DENY (markdown path). **PROJECT-KEY-CHARSET-DENY vectors:** `jira_project_key='X( \|$)\|.*'` on the create path → DENY + `PROJECT-KEY-CHARSET-DENY`; `jira_project_key='.*'` on the create-review path → DENY. **Valid-value vectors:** `ticket_id='SEC-123'` → passes charset check, `command_pattern` correctly anchored to `SEC-123`; `ticket_id='ABC-9999'` → passes; `jira_project_key='PRISM'` → passes. **Paired mutants: SM-48** (remove ticket_id charset-validation from all paths) killed by the ticket_id charset-deny vectors — under the mutant `ticket_id='.*'` yields `^jr (--output json )?issue comment .* ` and `jr issue comment ANY-TICKET foo` matches → an unrelated comment command is authorized → security bypass → mutant dies; **SM-49** (remove jira_project_key charset-validation from create/create-review) killed by the project-key charset-deny vectors — under the mutant `jira_project_key='PRISM( \|$)\|.*'` yields a broadened pattern an unrelated command matches → mutant dies. | BC-3.03.001 (disposition-guard `command_pattern` charset-validation at 5 interpolation sites + markdown path, P12-001/O7 / §8.26.1 item 1); consumed by BC-3.01.001 (require-review evaluates the anchored `command_pattern`) |
| **VP-SKILL-075** *(NEW v1.13, **P1**, PROPOSED; ADV-F2-P10-002 MAJOR)* | **Operator-boundary cron-exit-nonzero signal (cron wrapper Gate 2):** the `run-monitoring-loop.sh` wrapper bridges the internal hook-layer fail-loud artifacts to the operator-observable signal (the cron exit code). **Gate 2 (testable NOW):** when `${CLAUDE_PLUGIN_DATA}/markers/audit.log` contains any of `HARD-FLOOR-LIVELOCK-ABORT \| HARD-FLOOR-UNBINDABLE \| UNDER-LABEL-DENIED \| SEVERITY-MISMATCH \| MARKER-WRITE-FAILED` newer than the run start, the wrapper `exit 1`; a clean run (no fail-loud codes) `exit 0`. This closes the P10-002 gap where a run that drops hard-floor findings to audit-only (e.g. a livelock-abort that exhausts the re-doc cap and completes `is_error=false`) reported *success* to cron. **Gate 1 (ASM-015-BLOCKED):** the assertion that a PreToolUse-hook `permissionDecision:deny` populates the top-level `.permission_denials` array in the `--allowedTools` JSON envelope is **BLOCKED pending ASM-015 empirical validation** — that leg is marked **ASM-015-PENDING**, is NOT asserted and NOT counted toward convergence until ASM-015 resolves. If ASM-015 confirms `.permission_denials` is populated, Gate 1 becomes the primary hook-deny signal and Gate 2 is defense-in-depth; if not, Gate 2 (audit.log grep) is the SOLE hook-fail operator signal and this VP is its only guard. | B-INT | BATS integration exercising `run-monitoring-loop.sh` with a pre-seeded `${CLAUDE_PLUGIN_DATA}/markers/audit.log`. **Gate-2 vectors (NOW):** (1) audit.log contains a `HARD-FLOOR-LIVELOCK-ABORT` line newer than run-start → assert wrapper **exits 1** (Gate 2 grep fires); (2) audit.log contains a `SEVERITY-MISMATCH` line → assert **exit 1**; (3) clean run — no fail-loud codes in audit.log → assert **exit 0**. (Coverage for `HARD-FLOOR-UNBINDABLE`/`UNDER-LABEL-DENIED`/`MARKER-WRITE-FAILED` follows the same Gate-2 grep pattern.) **Gate-1 vector — ASM-015-PENDING (NOT run until ASM-015):** a hook-deny under the authoritative invocation → `.permission_denials` non-empty → wrapper exit 1; document the actual observed ASM-015 behavior when it resolves, then finalize this leg. | run-monitoring-loop.sh (architecture-delta cron wrapper Gate 1/Gate 2); BC-10.01.001 (PC#7 operator-boundary, D-DEC-010/D-DEC-012 fail-loud); ASM-015 (BLOCKING for the Gate-1 leg) |
| **VP-SKILL-076** *(NEW v1.17, **P1**, PROPOSED; ADV-F2-P14-002 MAJOR — no-covering-VP)* | **Setup-time jira_project_key charset validation (P14-002 — the PREVENTIVE gate):** `activate` (BC-6.01.001 PC#12/EC-014) AND `onboard-customer` (BC-6.01.003 Inv#6/EC-010) BOTH REJECT, **at SETUP time**, a configured `jira_project_key` that does not match `^[A-Z][A-Z0-9]+$` — with an explicit user-facing error AND **NO partial-configuration-state write** (fail-EARLY, not fail-closed mid-run); a conformant key (e.g. `PRISMDEMO`) is ACCEPTED and setup proceeds. This is the SETUP-TIME enforcement surface — **DISTINCT from VP-HOOK-032**, which covers the RUNTIME `command_pattern` `PROJECT-KEY-CHARSET-DENY` on the disposition-guard loop path (a separate call-site VP-HOOK-032 does not exercise). Together they close the class end-to-end: VP-SKILL-076 prevents a bad key from ever being stored; VP-HOOK-032 denies it at runtime if it somehow reaches command_pattern construction. | B-INT + B-STR | activate + onboard-customer setup helpers with `--config-dir <tmpdir>` isolated: **(reject)** feed `jira_project_key="PRISM-DEMO"` (hyphen) to `activate` → assert setup HALTS with a user-facing charset error, exit non-zero, and NO config file / partial `customers/<org_slug>/` state is written; **(reject)** same for `onboard-customer` (Inv#6/EC-010) → HALT + no partial-state; **(accept)** `jira_project_key="PRISMDEMO"` → setup proceeds, config written; **(boundary)** lowercase / leading-digit / empty key → reject; **static** the setup SKILL.md/helper documents the `^[A-Z][A-Z0-9]+$` grammar + the fail-early-no-partial-write contract. Paired mutant **SM-54** (setup-time charset validation removed → a hyphenated `PRISM-DEMO` is stored → a downstream marker issuance then triggers the runtime `PROJECT-KEY-CHARSET-DENY` / `HARD-FLOOR-UNBINDABLE` livelock) killed by the reject-at-setup vector. | BC-6.01.001 (activate PC#12/EC-014) + BC-6.01.003 (onboard-customer Inv#6/EC-010); RUNTIME sibling: VP-HOOK-032 (command_pattern PROJECT-KEY-CHARSET-DENY) |
| **VP-SKILL-077** *(NEW v1.18, **P1**, PROPOSED; ADV-F2-P14-005 MINOR — VP-repurposing orphan restoration)* | **onboard-customer AD-017 credential-decline (P14-005 — restores the coverage orphaned by VP-SKILL-053's repurposing):** onboard-customer (BC-6.01.003 Inv#1 / EC-008) **DENIES/declines credential entry in the chat** — the SKILL.md/helper NEVER requests OR accepts a credential paste in the conversation; the ONLY documented path is piped-stdin `echo \| prism credential set` (secrets never transit the conversation). This MIRRORS **VP-SKILL-054** (onboard-sensor AD-017 no-paste) applied to the onboard-customer credential-decline path. **DISTINCT from VP-SKILL-076** — VP-SKILL-076 is the setup-time `jira_project_key` charset gate (a wholly unrelated behavior); the v1.18 disentanglement splits the two behaviors the burst-10 remediation had conflated under a single VP id. | B-STR | grep onboard-customer SKILL.md/helper for the forbidden credential-paste-in-chat pattern → assert ABSENT; assert the piped-stdin `echo \| prism credential set` decline path IS documented. | BC-6.01.003 (Inv#1 / EC-008 — AD-017 credential-decline); MIRROR: VP-SKILL-054 (onboard-sensor AD-017, BC-6.01.004) |

**Totals:** 5 FINALIZED F1 VPs (024, 025, 026, 050, 051) + 12 ACCEPTED F1-inherited VPs (052–063)
+ 2 v1.1 VPs (064, 065) + 4 v1.2 VPs (VP-HOOK-027, VP-SKILL-066, 067, 068) + 4 v1.3 VPs
(VP-SKILL-069, 070, 071, VP-HOOK-028) + 2 v1.5 VPs (VP-HOOK-029, VP-SKILL-072) + 2 v1.9 VPs
(VP-SKILL-073 late-event, VP-SKILL-074 severity normalization) + **2 v1.13 VPs (VP-HOOK-030 STEP 1a
SEVERITY-MISMATCH, VP-SKILL-075 operator-boundary cron-exit)** + **1 v1.14 VP (VP-HOOK-031 separate
human-comment marker path, P11-004)** + **1 v1.15 VP (VP-HOOK-032 command_pattern interpolation-safety /
O7 compliance artifact, P12-001/P12-007)** + **1 v1.17 VP (VP-SKILL-076 setup-time jira_project_key
charset validation, P14-002)** + **1 v1.18 VP (VP-SKILL-077 onboard-customer AD-017 credential-decline, P14-005 —
the VP-SKILL-076/077 disentanglement)** = **37 VPs** for the cycle
(**v1.10 adds NO new VP — VP-HOOK-029 re-scoped in place, VP-HOOK-024 / VP-SKILL-074 extended; v1.11 adds
NO new VP either — VP-HOOK-029 EXTENDED with the P8-001 STEP-3 unbindable-deny vectors (stays FINALIZED P0)
and VP-HOOK-024 EXTENDED with the P8-002 quote-aware vector/mutant; v1.12 adds NO new VP — VP-HOOK-024
EXTENDED with the P9-001 escaped-quote partition (+SM-43) and VP-HOOK-029 EXTENDED with the P9-007
dedup-gate test-only vector; **v1.13 adds 2 new VPs (VP-HOOK-030 + VP-SKILL-075) and EXTENDS VP-HOOK-029
in place with the P10-003 MARKER-WRITE-FAILED review-path fail-closed vectors (+SM-45), UPGRADES
VP-SKILL-059 structural→behavioral, and RENAMES/extends VP-SKILL-064's carve-out @test names; **v1.14 adds
1 new VP (VP-HOOK-031 separate human-comment marker path), DOWNGRADES VP-HOOK-030 in place to a consistency
VP (P11-001), and EXTENDS VP-HOOK-025 (field-18 `scored_priority` presence/enum) + VP-HOOK-026 (scored_priority
HIGH/CRIT floor +SM-46) in place; **v1.15 adds 1 new VP (VP-HOOK-032 command_pattern interpolation-safety / O7,
+SM-48/SM-49), UPDATES VP-HOOK-031 in place to the P12-002 four-guarantee scope (+SM-50/SM-51), and EXTENDS
VP-HOOK-025 (fast-path SEVERITY_TO_SCORED_PRIORITY_MAP enum vectors, P12-003a) + VP-HOOK-026 (known-FP floor
exemption, P12-003b) in place; **v1.16 adds NO new VP — VP-HOOK-031 UPDATED in place (guarantee (c) REWRITTEN:
MARKDOWN_COMMENT_PATH ELIMINATED — no disposition yields an autonomous comment marker, FP→allow-without-marker /
non-FP+PARSE_FAIL→review, P13-001; + strict parse-grammar adversarial vectors, P13-003) with paired mutants
+SM-52/+SM-53 (SM-50/SM-51 remain valid)**; **v1.17 adds 1 new VP (VP-SKILL-076 setup-time jira_project_key
charset validation, P14-002, +SM-54) — the PREVENTIVE gate on the activate + onboard-customer SKILL setup flow,
sibling of VP-SKILL-051 and DISTINCT from the runtime VP-HOOK-032 command_pattern deny; no existing VP re-scoped; **v1.18
adds 1 new VP (VP-SKILL-077 onboard-customer AD-017 credential-decline, P14-005, NO mutant — SM-55 skipped, B-STR
structural per the VP-SKILL-054 precedent) — the VP-SKILL-076/077 DISENTANGLEMENT that splits the setup-time charset gate
(VP-SKILL-076) from the AD-017 credential-decline coverage (VP-SKILL-077) the burst-10 remediation had conflated under one
id; no existing VP re-scoped**; **v1.19 adds NO new VP — VP-HOOK-026 EXTENDED in place (P17-001 / D-019: the v1.15 known-FP
floor EXEMPTION vector RETIRED/INVERTED — LOW/MED known-FP auto-close, HIGH/CRIT known-FP → hard_floor_applies() FIRES →
comment-review; +SM-56) and VP-HOOK-028 REWRITTEN in place (P17-002: property (1) recast to the JSON-first fail-closed
residual boundary, self-contradiction with property (2) resolved); no existing VP renumbered/re-scoped**).
**Lifecycle note (P9-004 reconciliation, v1.12):** VP-SKILL-052–063 are **ACCEPTED** (F1-inherited, never
re-adjudicated/FINALIZED in F2), matching the §1 Namespace Adjudication table (the authoritative per-VP
lifecycle source absent a VP-INDEX.md); only VP-SKILL-050/051 are FINALIZED F1 VPs. The pre-v1.12 §2 label
"12 FINALIZED proposed VPs" was an internal drift and has been corrected here.
Strategy mix: **9 hook properties** (VP-HOOK-024/025/026/027/028/029/**030**/**031**/**032** — CRITICAL/HIGH enforcement;
027/028/029 are cross-hook B-INT-XH; **VP-HOOK-032 is the NEW v1.15 P0 O7 command_pattern interpolation-safety property —
charset-validation of ticket_id/jira_project_key before pattern construction at all 5 interpolation sites + the markdown
path (P12-001), the O7 compliance artifact mirroring VP-HOOK-024=O5; VP-HOOK-031 UPDATED v1.15 to the P12-002
four-guarantee markdown-path redesign, then **UPDATED v1.16 (P13-001): MARKDOWN_COMMENT_PATH ELIMINATED — the markdown
path issues NO autonomous comment marker for any disposition (FP → allow-without-marker; non-FP/PARSE_FAIL → review);
guarantee (c) rewritten; strict parse grammar added (P13-003)**;
**VP-HOOK-029 is P0 end-to-end consumer-boundary fail-loud,
re-FINALIZED v1.10 with the deny-the-Write / consumer-boundary vector set, EXTENDED v1.13 with the P10-003
MARKER-WRITE-FAILED review-path fail-closed vectors; VP-HOOK-030 is the STEP 1a severity CONSISTENCY property —
DOWNGRADED v1.14 from the pass-10 "un-bypassable re-normalization" claim to a consistency-only guarantee (P11-001),
sibling to VP-HOOK-025/026 on the disposition-guard enforcement surface; VP-HOOK-031 is the NEW v1.14 P0 separate
human-comment (12-field investigation-markdown) marker path — the markdown does NOT enter the verdict emitter (P11-004),
UPDATED v1.16 so it issues NO autonomous comment marker for any disposition (MARKDOWN_COMMENT_PATH eliminated, P13-001)**), **28 skill properties**
(VP-SKILL-050/051, 052–063 [12], 064–077 [14]; **VP-SKILL-077 is the NEW v1.18 onboard-customer AD-017 credential-decline
VP (P14-005, P1, PROPOSED, B-STR) — the conversation never asks for or accepts a secret (only piped-stdin `echo | prism
credential set` documented), mirroring VP-SKILL-054 (onboard-sensor AD-017); it RESTORES the AD-017 coverage orphaned when
VP-SKILL-053 was repurposed, and is DISTINCT from VP-SKILL-076 (the v1.18 disentanglement splits the setup-time charset
gate from the credential-decline coverage); NO paired mutant (SM-55 skipped — structural-presence, no control-flow branch
to mutate); VP-SKILL-076 is the NEW v1.17 setup-time jira_project_key
charset-validation VP (P14-002, P1, PROPOSED) — the PREVENTIVE gate on the activate + onboard-customer SKILL setup flow,
rejecting a non-`^[A-Z][A-Z0-9]+$` key at setup time with no partial-state write; sibling of VP-SKILL-051 and DISTINCT
from the runtime VP-HOOK-032 command_pattern PROJECT-KEY-CHARSET-DENY; paired mutant SM-54;** **VP-SKILL-075 is the NEW v1.13 operator-boundary
cron-exit-nonzero integration test on run-monitoring-loop.sh — PROPOSED, with an ASM-015-BLOCKED
`.permission_denials` Gate-1 leg; VP-SKILL-059 UPGRADED v1.13 structural→behavioral (prism-DTU multi-org +
static hunt-query-library org_slug assertion)**; VP-SKILL-073 is a late-event-detection integration test and VP-SKILL-074 a severity-normalization
boundary/equivalence test with the v1.10 Cyberint partition — both NEW v1.9, PROPOSED;
VP-SKILL-072 is a first-run integration test; VP-SKILL-069/070 are static+integration+adversarial
org_slug scoping on the investigate-event and assess-priority PrismQL surfaces; VP-SKILL-071 is a
boundary/property test at the D-DEC-011 confidence thresholds; VP-SKILL-066/067 are mixed
integration+structural; VP-SKILL-068 is prism-DTU + jr-mock integration; VP-SKILL-064 is mixed
structural+integration+adversarial; **VP-SKILL-065 RE-SCOPED v1.9 to zero-REGULAR-writes with the
review-exempt carve-out (carve-out UNCHANGED at v1.10), PROPOSED**). **VP-HOOK-029 lifecycle: tagged P1 at
pass-4; re-scoped to the P5-001 CRITICAL under-label vectors at pass-5 (P0); FINALIZED at pass-6 with the
kill-switch-on under-label upgrade vectors; **re-scoped END-TO-END at pass-7 per the O4 standing rule
(§0) — the pass-6 STEP-4 marker-upgrade mechanism RETIRED (ADV-F2-P7-001), replaced by DENY-THE-WRITE;
the emitter-only "marker in store OR error" assertion replaced by the consumer-boundary jr
authorization/execution outcome (ADV-F2-P7-004); lifecycle re-marked PROPOSED then re-FINALIZED (P0)
v1.10**. VP-SKILL-073/074 and the re-scoped VP-SKILL-065 carry VP-INDEX lifecycle PROPOSED (adjudicated in
F6). **VP-HOOK-030 (NEW v1.13) is FINALIZED P0 (a convergence-blocking safety invariant — the O6 severity
trust-basis correction is not deferred); VP-SKILL-075 (NEW v1.13) is PROPOSED (P1, F6-adjudicated) with its
Gate-1 `.permission_denials` leg ASM-015-BLOCKED; VP-SKILL-059 UPGRADED (structural→behavioral, remains
ACCEPTED lifecycle — an F1-inherited VP whose strategy was strengthened, not a new adjudication). **VP-HOOK-030
DOWNGRADED v1.14 to a consistency VP (P11-001) — stays FINALIZED P0 as a consistency guarantee (the SEVERITY-MISMATCH
deny vectors are retained; the asserted guarantee is corrected to "verdict.severity is consistent with
verdict.native_severity", NOT ground-truth enforcement); VP-HOOK-031 (NEW v1.14; UPDATED v1.15 to the
P12-002 four-guarantee scope; **UPDATED v1.16 — MARKDOWN_COMMENT_PATH ELIMINATED, P13-001**) is FINALIZED P0 (the
separate human-comment marker path is convergence-blocking — it resolves the P11-004 emitter-entry impossibility that
would deny a complete 12-field investigation at save time, the P12-002 CRITICAL where the pre-redesign path issued a live
comment marker for any disposition under an active kill switch, AND the **P13-001 CRITICAL** where the P12-002 FP-branch
residual granted an autonomous comment marker with no scored_priority/asset_type floor — now the markdown path issues NO
autonomous comment marker for ANY disposition, FP→allow-without-marker / non-FP+PARSE_FAIL→review; +the P13-003 strict
parse-grammar adversarial vectors; paired mutants SM-50/SM-51 (valid) + SM-52/SM-53). **VP-HOOK-032 (NEW v1.15) is FINALIZED P0 — the O7 command_pattern interpolation-safety property is
convergence-blocking (a metacharacter-laden ticket_id/jira_project_key defeats the anchored-match authorization
control, the SEC-009 class; charset-validation + regex-escape at all 5 interpolation sites + the markdown path,
paired mutants SM-48/SM-49).**

---

## 3. Answers to the Product-Owner's 4 Open Technical Questions (encoded as VP design decisions)

**(a) VP-HOOK-025 mechanism — disposition-guard dual-path [UPDATED v1.3 — artifact-class field-set
branching, D-DEC-008-C].** The hook branches on artifact class, and **the required field-set differs
per class** (the pass-3 correction — ADV-F2-P3-003; BC-3.03.001 v1.13 PC#2 corrected from the 15-field
erratum to 12; BC-5.01.001 v1.8 Inv#7's 12-field citation was already correct): (i) if
`tool_input.file_path` matches the investigation-markdown pattern (`*investigation-*.md`) →
heading-anchored check (`grep -qiE "^#{1,6}[[:space:]]+<field>"`) for the **12 ICD-203 field headings
ONLY** (Disposition, Confidence, Sensor Health Status, Evidence Artifacts, Timeline Events,
Hypotheses Considered, Alternatives Rejected, Uncertainty Explicit, Attack Techniques, Agent Actions,
Human Actions, Tuning Signal). Severity / Asset Type / Ticket Action Type are **NOT required** for the
investigation-markdown class (Ticket Action Type is meaningless for a human investigation), and their
presence in an investigation file must **NOT** trigger a wrong-class 18-field deny (SM-30 is the paired
over-strict mutant). (ii) if the file is a verdict file (verdict path/extension OR `tool_input.content`
parses as JSON via `jq empty`) → JSON key-presence + type check for **ALL 18 fields**. Key-presence
uses `jq -e 'has("<field>")'` (NOT `!= null`, so a present-null key is distinguishable from an absent
one — fail-closed deny if any of the 18 `has()` returns false).
**ADV-F2-001/004 fix: fields 13–15 added — `severity` (field 13), `asset_type` (field 14),
`ticket_action_type` (field 15).** **ADV-F2-P10-001 (v1.13): fields 16–17 added — `native_severity`
(field 16, the raw sensor-native severity value carried verbatim from Stage-1 INGEST) and `sensor_family`
(field 17, enum ∈{crowdstrike,armis,claroty,cyberint}) — REQUIRED so disposition-guard STEP 1a can
re-run `NORMALIZE_SEVERITY(native_severity, sensor_family)` and cross-check `verdict.severity` for CONSISTENCY (the O6
SEVERITY-MISMATCH deny, owned by VP-HOOK-030 — a consistency check between two LLM-supplied fields, NOT ground-truth
enforcement, P11-001; see the STEP 1a note below).** **ADV-F2-P11-002 (v1.14): field 18 added — `scored_priority`
(field 18, enum ∈{CRIT,HIGH,MED,LOW}, the Stage-5 assess-priority output carried into the verdict) — REQUIRED because
`hard_floor_applies()` keys the HIGH/CRIT hard floor on `verdict.scored_priority`, NOT on recomputed severity (brief
§3.9 "any alert scored HIGH/CRIT → human"; captures KEV/exposure escalations of a detector-LOW alert). scored_priority
is LLM-supplied — same ASM-008-class residual, NOT asserted as ground-truth.** Per-field type assertions (the original 12):
`disposition` string∈{TP,FP,BTP,Indeterminate}; **`confidence` is ENUM-ONLY (D-DEC-011): `type=="string" and (.=="high" or .=="medium" or .=="low")` — a float value (e.g. `0.85`) FAILS this assertion and is DENIED (ADV-F2-P3-008); the producer-side float→enum mapping is guaranteed by VP-SKILL-071 on the assess-priority side, disposition-guard is the enforcement backstop);**
`sensor_health_status` string∈{healthy,degraded,silent}; `evidence_artifacts`/`timeline_events`/`hypotheses_considered`/`alternatives_rejected`/`attack_techniques`/`agent_actions`/`human_actions`
each `type=="array"`; `uncertainty_explicit` `type=="string" or .==null`; `tuning_signal`
`type=="object" or .==null` (with disposition-conditional rule per (d)). **New (fields 13–15):**
`severity` string∈{LOW,MEDIUM,HIGH,CRITICAL} (the LLM-reported detector-native severity — **v1.13/P10-001 +
v1.14/P11-001/P11-002: NO LONGER the input to the hard-floor check; STEP 1a cross-checks it against
`NORMALIZE_SEVERITY(native_severity, sensor_family)` for CONSISTENCY only (both fields LLM-supplied — a consistency
check, NOT ground-truth, P11-001); the HIGH/CRIT `hard_floor_applies()` floor keys on `verdict.scored_priority`
(field 18, P11-002), NOT on recomputed severity — verdict.severity and scored_priority may legitimately differ** — NOT
`confidence`, which is an orthogonal axis; ADV-F2-001); `asset_type` string∈{domain_controller,privileged_account,ot_safety_system,standard,unknown}
(critical-asset hard-floor input; prism_asset_class cross-validation ASM-008-DEFERRED); `ticket_action_type` string∈{comment,create,assign,none}
(selects the emitter scope branch per D-DEC-008; **v1.5: enum extended to
{comment,create,assign,none,create-review,comment-review}** — `create-review`/`comment-review`
are the D-DEC-012 review-surfacing tokens; `none` ⇒ no marker written). **New (fields 16–17, v1.13/P10-001):**
`native_severity` `type=="string" and .!=""` (raw sensor-native severity carried from Stage-1 INGEST —
absent/empty → fail-closed deny); `sensor_family` string∈{crowdstrike,armis,claroty,cyberint} (non-member
→ fail-closed deny — an enum deny, NOT a SEVERITY-MISMATCH). **New (field 18, v1.14/P11-002):**
`scored_priority` string∈{CRIT,HIGH,MED,LOW} (Stage-5 assess-priority output; the HIGH/CRIT hard-floor key per
`hard_floor_applies()`; absent/non-member → fail-closed deny; LLM-supplied — same ASM-008-class residual, NOT
ground-truth). Malformed JSON →
fail-closed deny (mirrors BC-3.01.001 EC-020 marker handling). This is implementable in bash
with `jq` only — no new dependency. Enforced per BC-3.03.001 (post-pass-11) PC#1/2/3 (dual-path) and
BC-10.01.001 v1.14 Invariant #9 (**18-field list** + `autonomy_enabled` operational field).

**[NEW v1.13 — STEP 1a severity re-normalization, SEVERITY-MISMATCH; DOWNGRADED v1.14 to a CONSISTENCY CHECK
(ADV-F2-P10-001 CRITICAL / ADV-F2-P11-001 CRITICAL / O6 standing rule §0; owned by VP-HOOK-030).]** After
`validate_enums()` (STEP 1) confirms fields 16/17 are present and well-typed, disposition-guard STEP 1a re-runs
`recomputed_severity = NORMALIZE_SEVERITY(verdict.native_severity, verdict.sensor_family)` using the SAME D-DEC-013
deterministic table the monitoring loop used at Stage-1 INGEST (a pure lookup; no prism data dependency). **IF
`recomputed_severity != verdict.severity` → WRITE a `SEVERITY-MISMATCH` audit entry naming both values +
emit `deny` (the verdict Write is refused BEFORE any marker decision).** **P11-001 CORRECTION (v1.14):** the pass-10
framing that this "relocates severity trust from the LLM to the hook" and makes the floor "genuinely un-bypassable /
independently derived from raw sensor values" was **FALSE and is WITHDRAWN**. `native_severity` (field 16) and
`sensor_family` (field 17) are BOTH written by the monitoring-loop LLM at Stage-1 INGEST and read verbatim; the
network-free hook makes **no prism call**, so STEP 1a is a deterministic CONSISTENCY CHECK between two LLM-supplied
fields — it hardens against a careless/buggy LLM but CANNOT detect an adversarial LLM that supplies a false
`native_severity`+`sensor_family` pair (writing `native_severity="10"`/`sensor_family=crowdstrike`/`severity="LOW"`
for a genuinely CRITICAL alert passes the consistency check). **The asserted guarantee is exactly: "verdict.severity
is CONSISTENT with verdict.native_severity per the D-DEC-013 table."** Genuine severity ground-truth is
**ASM-008-DEFERRED, SYMMETRIC with the asset_type residual** (a prism-signed severity field or hook-fetched prism data;
network-free hooks cannot provide it). **STEP 1a does NOT gate recalibration and does NOT feed the high-severity floor:**
`hard_floor_applies()` keys the HIGH/CRIT floor on `verdict.scored_priority` (field 18 — P11-002), NOT on
recomputed severity; `verdict.severity` (detector-native) and `verdict.scored_priority` (Stage-5 recalibrated) may
legitimately differ. Paired mutant **SM-44** (revert STEP 1a → drop the consistency cross-check) is killed by
VP-HOOK-030's per-family SEVERITY-MISMATCH vectors. This is NOT a second normalization — it is a CONSISTENCY
CROSS-CHECK: the LLM-reported severity must agree with what the deterministic table produces for the same
(LLM-supplied) inputs.

**[UPDATED v1.5 — JSON-first dispatch precedence (ADV-F2-P4-001 CRITICAL).]** The class-dispatch
order is now **JSON-first, and this precedence is load-bearing**: the canonical verdict path
`artifacts/investigations/verdict-<id>-<iso_ts>.json` contains BOTH the `investigation` (directory)
and `verdict` (filename) substrings, so a plain "check `investigation` substring first" router would
misroute the canonical verdict JSON to the 12-field heading-grep branch, fail every `## `-heading
assertion, DENY the write, emit no marker, and render the entire autonomous pipeline unreachable.
The corrected dispatch is exactly the order this doc already specified in (a)(ii): **(1)** if
`tool_input.content` parses as JSON via `jq empty` OR `file_path` ends in `.json` → **verdict-class
18-field + `validate_enums()` + STEP 1a SEVERITY-MISMATCH consistency path** (REGARDLESS of any `investigation` substring in the path);
**(2)** elif `file_path` matches `*investigation-*.md` → investigation-class 12-field markdown path;
**(3)** else → fast-path allow (no ICD-203 validation). BC-3.03.001 v1.13 PC#1/2/3 are rewritten to
this order (PC#1 = JSON check; PC#2 = investigation `.md`; PC#3 = fast-path). Mutant **SM-34**
(dispatch-order-inverted — check the `investigation` substring before the JSON test) is the paired
kill target; VP-HOOK-028's canonical-path leg asserts `.../verdict-alert-001.json` → 18-field path
→ marker (positive) and `.../investigation-001.md` → 12-field path.

**[UPDATED v1.5 — `validate_enums()` membership gate (ADV-F2-P4-006 MAJOR).]** BC-3.03.001 v1.11
PC#3 described the verdict-JSON check as key-presence only (`jq has()`), but `hard_floor_applies()`
keys on exact-string membership. A case-mangled `severity:"High"` therefore passed key-presence yet
silently failed the `"High" ∈ {"HIGH","CRITICAL"}` test → NO hard floor → a marker was issued for
an actually-HIGH-severity alert. v1.5 adds an explicit `validate_enums(verdict)` step (D-DEC-008
emitter pseudocode) that runs **BEFORE** the hard-floor check and **fail-closed DENIES** any
non-member value on ALL typed fields: `severity ∈ {LOW,MEDIUM,HIGH,CRITICAL}`,
`asset_type ∈ {domain_controller,privileged_account,ot_safety_system,standard,unknown}`,
`disposition ∈ {TP,FP,BTP,Indeterminate}`, `sensor_health_status ∈ {healthy,degraded,silent}`,
`ticket_action_type ∈ {comment,create,assign,none,create-review,comment-review}`,
`confidence ∈ {high,medium,low}`. Fail-closed DENY (not allow-without-marker) is the correct
posture — allowing a field-mangled verdict to write to the investigation store without an ICD-203
guarantee is the failure mode P4-006 flagged. Mutant **SM-31** (validate_enums-removed → wrong-case
`severity` passes the hard floor and wrongly gets a marker) is the paired kill target.

**(b) ASM-009 cross-hook marker visibility + atomic consume-on-use — BATS integration test.**
Add to `integration.bats` a `setup()` that does `export CLAUDE_PLUGIN_DATA="$(mktemp -d)"`
(teardown `rm -rf`). Test sequence (three SEPARATE subprocess hook invocations, same exported
env = exactly the ASM-009 condition — DG writes, RR reads, distinct processes):
(1) invoke `disposition-guard.sh` with a verdict passing all **17** fields + non-hard-floor
disposition (FP / confidence=high / severity=LOW / asset_type=standard / healthy sensor /
ticket_action_type=comment / **native_severity="10" / sensor_family=crowdstrike** — so STEP 1a
recomputes LOW and agrees, no SEVERITY-MISMATCH) → assert a `<uuid>.marker.json` (schema v2.0: `issued_at_utc`,
`expires_at_utc` = +120s, ticket-bound `command_pattern`) now exists in
`$CLAUDE_PLUGIN_DATA/markers/`;
(2) invoke `require-review.sh` with `jr issue comment SEC-123 "..."` → assert `allow` AND the
marker file is now renamed to `*.marker.json.used` (cross-hook visibility + consume-on-use) AND
an `audit.log` line with a `command_b64=` (base64) field is appended;
(3) invoke `require-review.sh` a SECOND time with the same command → assert `deny`
(fail-closed on the consumed marker — proves single-use atomicity via POSIX rename; and note the
v2.0 rename-fail→deny leg is a distinct fixture). This is VP-HOOK-024's replay leg realized as an
integration test and is the empirical validator ASM-009 demands before Wave 3 merge.

**[UPDATED v1.2 — iterative-consume + document-before-action (ADV-F2-P2-001/P2-003).]** The
consumer is now **iterative-consume**, not ">1 → ambiguous deny" (architecture-delta §D-DEC-001
v1.3): candidates are sorted `issued_at_utc` ASC and the loop consumes the oldest whose atomic
`mv → .used` rename succeeds; if all renames fail it denies (fail-closed exhaustion). Two added
integration legs: (i) **concurrent same-scope** — write TWO valid same-scope markers via two
disposition-guard invocations, then one require-review call → assert `allow` with the *oldest*
marker consumed and the newer one still present (legitimate multi-alert loop run no longer
mutually invalidates — the ADV-F2-P2-003 fix); (ii) **exhaustion** — pre-rename both candidates
to `.used` out-of-band, then require-review → assert `deny`. Separately, **VP-HOOK-027**
(document-before-action) uses this same harness but flips the *ordering*: the negative leg invokes
require-review on the `jr` Bash call with an EMPTY marker dir (Stage 8 before Stage 7) → assert
`deny`; the positive leg runs disposition-guard-Write (Stage 7) → require-review-Bash (Stage 8) →
assert `allow`. VP-HOOK-027 is the process-gap guard the adversary flagged (P2-014) that would
have caught the P2-001 inverted-stage CRITICAL.

**(c) VP-HOOK-026 fixture mechanism — env-var + stdin-envelope injection (config-file injection
REJECTED).** Established pattern in `tests/hooks.bats`: every hook is driven purely by the
stdin JSON envelope (`{tool_input.command}` / `{tool_input.file_path, content}`) with
`PLUGIN_ROOT` from `BATS_TEST_DIRNAME`; there is NO existing config-file read pattern in any
hook, and BC-3.01.001 Invariant #2 constrains the hook to decide "from the stdin JSON envelope
only" (plus, for require-review, the marker store). Filesystem roots are supplied via env-var
(`CLAUDE_PLUGIN_DATA`, matching the architecture-delta §Testing-Architecture `mktemp -d` +
`export` mandate). Therefore VP-HOOK-026 injects: `CLAUDE_PLUGIN_DATA=$(mktemp -d)` for the
marker-store, and the hard-floor verdict + `autonomy_enabled: true` inside `tool_input.content`.
Because disposition-guard's hard floor is an UNCONDITIONAL branch that never consults autonomy
state, the proof is: feed `autonomy_enabled=true` alongside each hard-floor category in turn and
assert `$CLAUDE_PLUGIN_DATA/markers/` remains empty after the hook returns.
**ADV-F2-001 leg correction (v1.1):** the earlier draft's legs injected non-existent fields; the
hard-floor keys on the LIVE 18-field schema (**v1.13/P10-001 + v1.14/P11-002: the HIGH/CRIT floor keys on
`verdict.scored_priority` (field 18), NOT on `verdict.severity` or recomputed severity; STEP 1a only
consistency-checks severity↔native_severity**), so the corrected legs inject:
(1) `disposition=Indeterminate`; (2) **`verdict.scored_priority=HIGH`** (field 18 — the HIGH/CRIT floor key
per P11-002, NOT `confidence`; scored_priority and confidence are orthogonal axes, so this leg pairs
`scored_priority=HIGH` with `confidence=low` to prove the hard floor still fires; the v1.14 scored_priority
partition on the VP-HOOK-026 test surface adds the detector-LOW/scored-CRIT escalation leg + SM-46);
(3) **`verdict.asset_type=critical-asset`**
(field 14, e.g. `domain_controller`); (4) `attack_techniques` contains `T1003`;
(5) `sensor_health_status=degraded`; **(6) NEW v1.3 (ADV-F2-P3-001 CRITICAL) — `verdict.asset_type=unknown`
paired with `severity=LOW` + a benign (non-hard-floor) technique + `ticket_action_type=comment`:
the `unknown` asset_type is a conservative hard-floor member (BC-3.03.001 v1.13 Inv#4 / BC-10.01.001
v1.9 Inv#10), so even a fully-benign verdict with an unclassified asset must NOT receive a marker.**
Each leg asserts **NO marker is issued** (marker dir empty) regardless of `autonomy_enabled=true`.
The unknown-asset leg is the defense-in-depth guarantee the adversary flagged as false: the hook must
block the marker independently of SKILL.md behavior. Mutant SM-29 (unknown-asset-hard-floor-removed) is
the paired kill target. Config-file injection is rejected — it would introduce an input surface no hook
reads and diverge from the harness.

**[UPDATED v1.5 — `autonomy_enabled` is a verdict field read directly by the hook + review-surfacing
exemptions (ADV-F2-P4-004/P4-005, D-DEC-012).]** Two v1.5 corrections change the VP-HOOK-026 leg set,
both keeping the env-var + stdin-envelope harness (config-file injection still REJECTED): **(A)
kill-switch determinism (P4-005):** `autonomy_enabled` is now a NON-ICD-203 operational metadata field
IN the verdict JSON (alongside `jira_project_key`/`confidence_score`), and disposition-guard reads it
DIRECTLY (D-DEC-008 emitter Step 5 — the kill switch, renumbered from Step 4 by the ADV-F2-P6-002
reorder) rather than trusting the loop LLM to have set
`ticket_action_type=none`. `autonomy_enabled != true` (false OR **absent → conservative false**)
suppresses ALL REGULAR markers. New legs: `autonomy_enabled=false` + regular `create` → NO marker;
`+ comment` → NO marker; `autonomy_enabled` ABSENT + regular `create` → treated false → NO marker.
Mutant **SM-33** (autonomy_enabled-clause-removed → a regular marker is wrongly emitted under the kill
switch) is the paired kill target. **(B) review-surfacing exemptions (P4-004, D-DEC-012):** the
`create-review`/`comment-review` ticket_action_types are EXEMPT from BOTH the hard-floor no-marker rule
AND the kill switch (emitter Step 3 correct-label review path runs before the
Step 5 kill switch; an under-labeled hard-floor verdict is DENIED at Step 4 — before Step 5 too — so the
loop re-documents with a review token, per the v1.10 deny-the-Write redesign), because creating a `[REVIEW-REQUIRED]` /
`[BLIND-SPOT]` ticket is human ESCALATION, not autonomous triage. Legs: Indeterminate +
`create-review` → restricted marker emitted (`authorized_operations=["create-review"]`, hard-floor
EXEMPT); silent-sensor + `comment-review` → restricted marker emitted; HIGH-severity + `create-review`
→ marker emitted; `autonomy_enabled=false` + `create-review` → marker STILL emitted (kill-switch
EXEMPT). The legs assert a marker IS emitted, so the "remove the review exemption entirely →
over-strict, review ticket dropped" direction is killed here.

**[UPDATED v1.8 / v1.9 / v1.10 — the STEP 3 review-exemption is GATED on `hard_floor_applies()`; the review token is
no longer trusted unconditionally (ADV-F2-P5-002 MAJOR); the STEP 4 handling of an under-labeled hard-floor
verdict is the fail-loud dual (ADV-F2-P5-001 CRITICAL), which — post the ADV-F2-P7-001 redesign — is now a
DENY-THE-WRITE (marker-upgrade RETIRED) and still runs BEFORE the STEP 5 kill switch.]** Pass-4 treated the `create-review`/`comment-review`
exemption as UNCONDITIONAL on the LLM-supplied `ticket_action_type`, which let the LLM manufacture a
kill-switch + hard-floor bypass by over-labeling a regular verdict as a review action (P5-002).
The architect's D-DEC-008 STEP 3 fix (architecture-delta v1.8) gates the exemption on the
hook-computed `hard_floor_applies(verdict)`: `IF NOT hard_floor_applies(): emit allow WITHOUT marker;
RETURN`. **New v1.8 OVER-LABEL legs (VP-HOOK-026):** non-hard-floor TP verdict (LOW severity, standard
asset) + `create-review` → NO marker; non-hard-floor FP + `comment-review` + `autonomy_enabled=false`
→ NO marker (no kill-switch bypass); LOW-severity standard asset + `create-review` → NO marker. The
paired kill target for the over-label legs is **SM-32b** (remove the STEP 3 `NOT hard_floor_applies()`
gate → a non-hard-floor verdict with a review token gets the exempt marker; the over-label legs assert
NO marker, so the mutant dies). The **under-label** dual (a hard-floor verdict carrying a NON-review
token) is enforced at STEP 4's DENY-THE-WRITE and proved end-to-end by **VP-HOOK-029** (the consumer-boundary
re-scope, §2); its paired mutants are **SM-38** (remove the STEP-4 deny → silent allow), **SM-39** (remove the
corrective-reason structure), and the re-targeted **SM-32a** (revert the deny to the retired upgrade →
unconsumable in-store marker), with **SM-32-ext** (revert the STEP 4/5 order) killed by VP-HOOK-029's
kill-switch-irrelevance deny vector. The unconditional-hard-floor legs (1)–(6) above are UNCHANGED for
REGULAR (comment/create/assign) markers; the review-surfacing legs (hard_floor_applies()=TRUE → marker
emitted) are UNCHANGED and remain valid under the gated STEP 3.
**[UPDATED v1.11 — STEP 3 correctly-labeled-yet-unbindable deny (ADV-F2-P8-001 CRITICAL).]** The review-surfacing
legs assume the operational binding field is present. The adversary (P8-001) showed the *correctly-labeled*
review path had its own silent-discard sub-case: a genuinely hard-floor verdict with a CORRECT review token
but a null non-ICD-203 binding field (`create-review` + null/empty `jira_project_key`; `comment-review` +
null `ticket_id`) hit a silent `emit allow without marker; RETURN` at STEP 3 — and since `jira_project_key`/
`ticket_id` are in neither the 18-field presence check nor `validate_enums()`, the verdict passed every prior
gate and the hard-floor finding was silently dropped. The redesigned D-DEC-008 STEP 3 (architecture-delta
v1.11) replaces both silent-allow branches with a **`HARD-FLOOR-UNBINDABLE` DENY-THE-WRITE** per D-DEC-012
clause 2 (audit entry naming `missing_field`; structured deny reason with `hard_floor_trigger` + re-issue
instruction; the comment-review branch adds a create-review fallback hint when `jira_project_key` is present).
So the gated STEP 3 exemption now produces exactly one of {a bindable review marker, a `HARD-FLOOR-UNBINDABLE`
deny} — NEVER a silent allow. This is the fail-loud invariant owned end-to-end by **VP-HOOK-029** (unbindable-deny
vectors 9–11, §2); paired mutant **SM-41** (revert the STEP-3 create-review null-`jira_project_key` branch to
emit-allow-without-marker). Bounded non-termination mirrors STEP 4 — one audit entry + one deny per re-doc
attempt, no Jira write, no silent loop.

**(d) tuning_signal null-vs-absent — jq check.** Three-way distinction, evaluated in order:
`has("tuning_signal") == false` → **INVALID ALWAYS** (absent key is a schema violation → deny);
`.tuning_signal == null` (key present, null) → **REQUIRED/valid for disposition∈{TP,Indeterminate}**,
INVALID for {FP,BTP}; non-null → must be an object with `rule_id`,`asset`,`reason`, **REQUIRED
for {FP,BTP}** (and acceptable for TP/Indeterminate). Encoding:
`jq -e 'has("tuning_signal")'` (else deny); then
`disp=$(jq -r .disposition)`; if `FP|BTP`:
`jq -e '.tuning_signal!=null and (.tuning_signal|type=="object") and (.tuning_signal|has("rule_id") and has("asset") and has("reason"))'` (else deny);
if `TP|Indeterminate`: `jq -e '.tuning_signal==null or (.tuning_signal|type=="object")'`
(else deny). Note the deliberate use of `has()` for presence and `== null` for the value —
conflating the two is mutant SM-18 (§4).

---

## 4. SM-N Mutant Catalog Extension

Existing catalog runs SM-1..SM-8b (verification-gap-analysis.md §Surviving Mutants). New
high-value mutants for the marker-validation path (require-review, **CRITICAL — target ≥95%**)
and the disposition-guard JSON path + monitoring-loop (**HIGH — target ≥90%**; the
monitoring-loop-verdict enforcement it guards is on the CRITICAL Jira-write path). **v1.1 added
SM-20..SM-25 for the 15-field schema, the ticket-scoped emitter, the ADV-F2-001 severity/confidence
fix, the ADV-F2-005 hard-floor-ordering fix, and the two new VPs (org_slug, kill switch). v1.2
retargets SM-15 to the iterative-consume path (the ">1 ambiguous deny" mutation target was retired
at architecture-delta §D-DEC-001 v1.3) and adds SM-26 (reopen-guard-removed), SM-27
(dedup-check-removed→double-ticket), SM-28 (stage-order-inverted). v1.3 adds SM-29
(unknown-asset-hard-floor-removed, ADV-F2-P3-001) and SM-30 (artifact-class-over-strict,
ADV-F2-P3-003). **v1.5 adds SM-31 (validate_enums-removed, ADV-F2-P4-006), SM-32
(review-surfacing-hard-floor-bypass-removed, D-DEC-012/ADV-F2-P4-004), SM-33
(autonomy_enabled-clause-removed, ADV-F2-P4-005), SM-34 (dispatch-order-inverted, ADV-F2-P4-001),
and SM-35 (control-char-strip-removed, ADV-F2-P4-010).** **v1.8 RE-SCOPES SM-32 into two
separately-killable variants — SM-32a (step4-under-label-upgrade-removed, ADV-F2-P5-001 CRITICAL,
killed by VP-HOOK-029) and SM-32b (step3-hard-floor-gate-removed, ADV-F2-P5-002 MAJOR, killed by
VP-HOOK-026) — raising the count 27 → 28 (SM-9..SM-35, with SM-32 = SM-32a + SM-32b).** **v1.9
(pass-6) adds THREE mutants: SM-32-ext (step-order-reverted → STEP 5 kill switch back before the
STEP 4 under-label upgrade, ADV-F2-P6-002 CRITICAL, killed by VP-HOOK-029's kill-switch-on under-label
vectors), SM-36 (consumer-review-label-check-removed, ADV-F2-P6-001 CRITICAL, killed by VP-HOOK-024)
and SM-37 (consumer-reverse-label-check-removed, ADV-F2-P6-001 CRITICAL, killed by VP-HOOK-024) —
raising the count 28 → 31 (SM-9..SM-37, with SM-32 = SM-32a + SM-32b + SM-32-ext; SM-33/34/35 are the
PRE-EXISTING pass-4 mutants — NAMESPACE NOTE: architect §8.15 item 5 mis-named the consumer mutants
"SM-33/SM-34", which collide with occupied ids; they are allocated the next free SM-36/SM-37).** **v1.10
(pass-7) adds THREE mutants for the STEP-4 DENY-THE-WRITE redesign (occupancy re-verified — `grep -rhoE
'SM-[0-9]+' .factory/` max real = SM-37, SM-2026 a date false-positive; next free = SM-38): SM-38
(step4-deny-removed → silent emit-allow-without-marker, ADV-F2-P7-001 CRITICAL, killed by VP-HOOK-029's
deny-path vectors), SM-39 (deny-corrective-reason-removed → the deny fires but the loop cannot act on a
structureless message, ADV-F2-P7-004 MAJOR, killed by VP-HOOK-029's machine-actionable-reason vector),
and SM-40 (has_review_label-reverted-to-raw-substring → false-deny of a regular create whose --summary
contains the label literal, ADV-F2-P7-005 MINOR, killed by VP-HOOK-024's step-6a false-deny vector) —
raising the count 31 → 34 (SM-9..SM-40, with SM-32 = SM-32a + SM-32b + SM-32-ext). SM-32a is RE-TARGETED
(the STEP-4 upgrade it formerly removed is RETIRED) to "revert the STEP-4 deny to the retired
GOTO-WRITE_MARKER upgrade" (killed by VP-HOOK-029's consumer-boundary vector — the marker is present but
unconsumable); SM-32-ext's kill vector is RE-WORDED to the deny-before-kill-switch assertion. Neither
re-target/re-word adds or removes an id.** **v1.11 (pass-8) adds TWO mutants (occupancy re-verified — `grep
-rhoE 'SM-[0-9]+' .factory/` max real = SM-40, SM-2026 a date false-positive; next free = SM-41): SM-41
(step3-create-review-unbindable-allow-reverted → the STEP-3 create-review null-`jira_project_key` branch
reverts to emit-allow-without-marker, the pre-P8-001 silent-discard on the correctly-labeled review path,
ADV-F2-P8-001 CRITICAL, killed by VP-HOOK-029's unbindable-deny vectors 9–11) and SM-42
(structural_label_check-reverted-to-non-quote-aware-split_on_whitespace → a quoted `--summary` label literal
false-denies a regular create, ADV-F2-P8-002 MAJOR, killed by VP-HOOK-024's quoted-form false-deny vector) —
raising the count 34 → 36 (SM-9..SM-42, with SM-32 = SM-32a + SM-32b + SM-32-ext). No re-target/renumber this
pass.** **v1.12 (pass-9) adds ONE mutant (occupancy re-verified — `grep -rhoE 'SM-[0-9]+' .factory/` max real =
SM-42, SM-2026 a date false-positive; `grep -rn 'SM-43' .factory/` returned no match; next free = SM-43): SM-43
(step6a-in_double-backslash-escape-reverted → the D-DEC-001 v1.12 IN_DOUBLE backslash-aware tokenizer reverts
to the P8-002 toggle-on-every-quote behavior, so a `\"` inside a double-quoted `--summary` closes the quoted
region and swallows a REAL trailing `--label REVIEW-REQUIRED`, ADV-F2-P9-001 MAJOR, killed by VP-HOOK-024's
escaped-quote vector 1a) — raising the count 36 → 37 (SM-9..SM-43, with SM-32 = SM-32a + SM-32b + SM-32-ext).
No re-target/renumber this pass.** **v1.13 (pass-10) adds TWO mutants (occupancy re-verified — `grep -rhoE
'SM-[0-9]+' .factory/` max real = SM-43, SM-2026 a date false-positive; `grep -rn 'SM-44\|SM-45' .factory/`
returned no match; next free = SM-44/45): SM-44 (step1a-severity-renormalization-reverted → trust
verdict.severity directly, hard floor keys on the raw LLM value, ADV-F2-P10-001 CRITICAL, killed by
VP-HOOK-030's per-family under-report vectors) and SM-45 (writemarker-review-path-allow-without-marker-reverted
→ WRITE_MARKER emits allow-without-marker regardless of is_review_path, so a hard-floor review marker that fails
to write is silently dropped, ADV-F2-P10-003 MAJOR, killed by VP-HOOK-029's MARKER-WRITE-FAILED review-path
vectors) — raising the count 37 → 39 (SM-9..SM-45, with SM-32 = SM-32a + SM-32b + SM-32-ext). No
re-target/renumber this pass.** **v1.14 (pass-11) adds TWO mutants (occupancy re-verified — `grep -rhoE
'SM-[0-9]+' .factory/` max real = SM-45, SM-2026 a date false-positive; `grep -rn 'SM-46\|SM-47' .factory/`
returned no match; next free = SM-46/47): SM-46 (highseverity-floor-rekeyed-to-recomputed-severity → the HIGH/CRIT
floor keys on recomputed severity instead of `verdict.scored_priority`, so a detector-LOW/scored-CRIT escalation
bypasses the §3.9 floor, ADV-F2-P11-002 MAJOR, killed by VP-HOOK-026's detector-LOW/scored-CRIT vector) and SM-47
(markdown-routed-into-verdict-emitter → the 12-field investigation-markdown is subjected to `validate_enums()`/STEP 1a
so a compliant investigation is wrongly denied at save time, ADV-F2-P11-004 MAJOR, killed by VP-HOOK-031's
no-validate_enums-on-markdown / compliant-save vectors) — raising the count 39 → 41 (SM-9..SM-47, with SM-32 =
SM-32a + SM-32b + SM-32-ext). No re-target/renumber this pass.** **v1.15 (pass-12) adds FOUR mutants (occupancy
re-verified — `grep -rhoE 'SM-[0-9]+' .factory/` max real = SM-47, SM-2026 a date false-positive; `grep -rn
'SM-48\|SM-49\|SM-50\|SM-51' .factory/` returned no match; next free = SM-48..SM-51): SM-48 (ticket_id-charset-validation-removed
→ `.*` ticket_id broadens the anchored command_pattern to authorize an unrelated `jr issue comment`, ADV-F2-P12-001
CRITICAL, killed by VP-HOOK-032's TICKET-ID-CHARSET-DENY vectors), SM-49 (jira_project_key-charset-validation-removed
→ a metacharacter project_key broadens the create/create-review pattern, ADV-F2-P12-007, killed by VP-HOOK-032's
PROJECT-KEY-CHARSET-DENY vectors), SM-50 (markdown-kill-switch-gate-removed → autonomy_enabled=false TP/FP markdown
wrongly issues an autonomous comment marker, ADV-F2-P12-002 CRITICAL, killed by VP-HOOK-031's kill-switch vector),
and SM-51 (markdown-disposition-route-to-review-removed → a TP/BTP markdown gets an autonomous comment marker instead
of a review marker, ADV-F2-P12-002 CRITICAL, killed by VP-HOOK-031's TP→review vector) — raising the count 41 → 45
(SM-9..SM-51, with SM-32 = SM-32a + SM-32b + SM-32-ext). No re-target/renumber this pass. P12-003 (MAJOR — fast-path
enum map + known-FP floor exemption) adds vectors under VP-HOOK-025 / VP-HOOK-026 but NO new mutant (architect §8.27
item 3 — the raw-CRITICAL/raw-MEDIUM validate_enums deny is the direct consequence the vectors assert; the
floor-exemption is architectural policy, not a control-flow security branch).** **v1.16 (pass-13) adds TWO mutants
(occupancy re-verified — `grep -rhoE 'SM-[0-9]+' .factory/` max real = SM-51, SM-2026 a date false-positive and SM-456
the 'PRISM-456' charset example; `grep -rn 'SM-52\|SM-53' .factory/` returned no match; next free = SM-52/SM-53):
SM-52 (markdown-fp-comment-marker-revert → the P13-001-eliminated MARKDOWN_COMMENT_PATH is restored so an FP markdown
issues an autonomous `["comment"]` marker, ADV-F2-P13-001 CRITICAL, killed by VP-HOOK-031's FP→allow-without-marker
vector) and SM-53 (markdown-disposition-full-document-substring-scan → `parse_disposition_from_markdown` scans the whole
document instead of only the canonical `Disposition` heading, so a `Disposition: FP` string embedded in an evidence
block/code fence is read as FP → allow-without-marker instead of review, ADV-F2-P13-003 MAJOR, killed by VP-HOOK-031's
FP-in-code-fence vector) — raising the count 45 → 47 (SM-9..SM-53, with SM-32 = SM-32a + SM-32b + SM-32-ext). No
re-target/renumber this pass; SM-50/SM-51 remain valid (their killer vectors shift under P13-001 — see the SM-50/SM-51
rows). P13-004 (historical-total annotation) and the PRISMDEMO sweep add no mutant.** **v1.17 (pass-14) adds ONE
mutant (occupancy re-verified — `grep -rhoE 'SM-[0-9]+' .factory/` max real = SM-53, SM-2026 a date false-positive and
SM-456 the 'PRISM-456' charset example; `grep -rn 'SM-54' .factory/` returned no match; next free = SM-54): SM-54
(setup-time-charset-validation-removed → the activate/onboard-customer setup path no longer rejects a non-`^[A-Z][A-Z0-9]+$`
`jira_project_key`, so a hyphenated key like `PRISM-DEMO` is STORED at setup → a downstream marker issuance then triggers
the runtime `PROJECT-KEY-CHARSET-DENY` / `HARD-FLOOR-UNBINDABLE` livelock, ADV-F2-P14-002 MAJOR, killed by VP-SKILL-076's
reject-at-setup vector) — raising the count 47 → 48 (SM-9..SM-54, with SM-32 = SM-32a + SM-32b + SM-32-ext). No
re-target/renumber this pass; the NVD sweep (P14-001 propagation — VP-SKILL-074 CVSS-as-native_severity residual removed +
SM-44 killer-vector reference corrected to `(1)–(4)`) adds no mutant. P14-005 (VP-repurposing annotation) adds no mutant.**
**v1.18 (VP-SKILL-076/077 disentanglement) adds NO mutant (SM-55 SKIPPED — VP-SKILL-077 is a B-STR structural-presence
property with no control-flow gate to mutate).** **v1.19 (pass-17) adds ONE mutant (occupancy re-verified by a FRESH grep —
`grep -rhoE 'SM-[0-9]+' .factory/` max real = SM-54; SM-2026 a date FP, SM-456 the 'PRISM-456' charset example, SM-55 only
appears as 'SKIPPED' [documented non-allocation, not a live mutant]; `grep -rn 'SM-56' .factory/` returned NO match before
allocation → next-free control-flow id = **SM-56**; SM-55 is deliberately NOT reused to preserve its ~15-place 'skipped'
record — collision-of-meaning avoided): **SM-56** (known-FP-floor-bypass-branch-added → `hard_floor_applies()` gains a
known-FP carve-out that skips the floor when the verdict matches the known-FP store, so a HIGH/CRIT-native known-FP
auto-closes instead of routing to comment-review, ADV-F2-P17-001 / D-019, killed by VP-HOOK-026's HIGH/CRIT-known-FP→review
vector) — raising the count 48 → 49 (SM-9..SM-56, SM-55 reserved-skipped, SM-32 = SM-32a + SM-32b + SM-32-ext). No
re-target/renumber; P17-002 (VP-HOOK-028 property-(1) JSON-first rewrite) adjusts vectors but adds no mutant (the SM-34
dispatch-order sentinel already guards the JSON-first precedence property (2), and the rewritten property-(1) residual
boundary is a consumer-boundary reachability assertion, not a new control-flow gate to mutate).** All 49
must be KILLED by the F4/F6 suite before convergence.

| Mutant | Target construct | Mutation | Killed by |
|--------|------------------|----------|-----------|
| SM-9 | require-review marker TTL compare | invert `(now − issued_at) > 30` → `< 30` (expired accepted / fresh rejected) | VP-HOOK-024 expired-marker test (EC-017) |
| SM-10 | require-review authorized_operations / command_pattern scope check | delete the scope/anchored-pattern gate (comment marker authorizes create) | VP-HOOK-024 wrong-scope (EC-018) + wrong-ticket (EC-022) |
| SM-11 | require-review atomic invalidation (`mv → .used`) | skip the rename (marker not consumed) → replay possible | VP-HOOK-024 replay-deny (EC-019) + ASM-009 §3(b) step 3 |
| SM-12 | require-review command_pattern matcher | degrade anchored `^`-regex to substring / `grep -F` (**SEC-009 class**) | VP-HOOK-024 anchored-match + bypass-class vector (EC-022) |
| SM-13 | require-review future-dated guard | delete `issued_at > now()` check (clock-manipulation marker accepted) | VP-HOOK-024 future-dated test (EC-017 variant) |
| SM-14 | require-review path-safety guard | delete basename `..`/`/` check (path-traversal candidate processed) | VP-HOOK-024 path-traversal test (EC-021) |
| SM-15 | require-review iterative-consume exhaustion guard *(retargeted v1.2 — the ">1 → ambiguous deny" gate was retired at architecture-delta §D-DEC-001 v1.3 / ADV-F2-P2-003)* | replace the post-loop `deny (fail-closed exhaustion)` with `allow` (fail-open when every candidate's rename fails) OR drop the `issued_at_utc` ASC sort so a newer/forged marker is consumed before the oldest | VP-HOOK-024 iterative-consume legs: all-renames-fail → exhausted-DENY, and concurrent-same-scope → oldest-consumed-first |
| SM-16 | disposition-guard emitter STEP 4 hard-floor gate *(renumbered from STEP 5 by the ADV-F2-P6-002 reorder)* | remove the `IF hard_floor_applies():` guard entirely so a hard-floor verdict (Indeterminate/HIGH) with a regular action falls through to STEP 6 and gets a **REGULAR (comment/create/assign-scoped) autonomous-triage marker** (distinct from SM-38, which removes the STEP-4 *deny* → silent allow, and from the re-targeted SM-32a, which reverts the deny to the retired upgrade → unconsumable in-store marker) | VP-HOOK-026 hard-floor tests (assert NO regular-scoped marker; SM-16 issues a regular comment/create/assign marker for a hard-floor verdict and dies) |
| SM-17 | disposition-guard 18-field `has()` list | drop one of the original 12 fields (e.g. `timeline_events`) from the presence list | VP-HOOK-025 per-field missing-field tests |
| SM-18 | disposition-guard tuning_signal null/absent | replace `has("tuning_signal")` with `.tuning_signal != null` (absent≡null conflated) | VP-HOOK-025 tuning_signal absent-invalid + FP-null-invalid (EC-011) |
| SM-19 | disposition-guard dual-path router | invert verdict-vs-markdown routing (JSON verdict sent to heading check → field bypass) | VP-HOOK-025 dual-path routing test (JSON verdict allow/deny) |
| SM-20 | disposition-guard 18-field `has()` list (new fields) | **severity-field-drop** — drop `severity`/`asset_type`/`ticket_action_type` (fields 13/14/15) from the presence list | VP-HOOK-025 missing-severity / missing-asset_type / missing-ticket_action_type tests (EC-010) |
| SM-21 | disposition-guard hard-floor key | replace `verdict.severity` with `verdict.confidence` as the severity proxy (**ADV-F2-001 latent bypass**: HIGH-severity + low-confidence escapes the floor) | VP-HOOK-026 leg (2): `severity=HIGH` + `confidence=low` → assert NO regular (comment/create/assign-scoped) marker (HIGH severity is hard-floor by severity; an under-labeled hard-floor verdict is instead denied at STEP 4) — the mutant keys on `confidence=low`, mis-classifies as non-hard-floor, issues a REGULAR marker, and dies |
| SM-22 | disposition-guard emitter scope selection | **ticket_action_type-ignored** — ignore `verdict.ticket_action_type`, always emit a comment-scoped marker (a `create`/`assign` verdict gets a wrong-scope comment marker) | VP-HOOK-024 create-scoped + assign-scoped allow-path vectors (wrong-scope marker fails anchored `command_pattern` match) |
| SM-23 | monitoring-loop known-FP Stage-2 fast-exit ordering | **hard-floor-check-after-auto-close** — move the hard-floor evaluation AFTER the known-FP auto-close (ADV-F2-005): a HIGH-severity / critical-asset / degraded-sensor alert that also matches a known-FP pattern gets auto-closed before the floor fires | VP-HOOK-026 + BC-10.01.001 EC-009 hard-floor-before-known-FP test (**no auto-close** — the hard floor fires first and the alert is routed for human review, i.e. `ticket_action_type=create-review`/`comment-review` per the v1.8 narrowed Inv#10, NEVER silently auto-closed) |
| SM-24 | monitoring-loop PrismQL query construction | **org_slug-drop** — omit the `org_slug` scope constraint from the generated query (cross-tenant leak) | VP-SKILL-064 multi-org integration (org-a query returns zero org-b/c rows) + unscoped-query adversarial fixture |
| SM-25 | monitoring-loop autonomy gate | **kill-switch-ignore** — ignore `autonomy_enabled=false` and execute a REGULAR `jr issue create/comment/assign` anyway | VP-SKILL-065 kill-switch integration (RE-SCOPED v1.9: zero REGULAR markers consumed, zero REGULAR jr writes; the review-exempt escalation write is NOT what this mutant targets) |
| SM-26 | update-jira never-auto-reopen guard | **reopen-guard-removed** (ADV-F2-P2-009a) — remove the Closed/Resolved guard so the update-jira Closed/Resolved branch emits `jr issue move` to reopen autonomously | VP-SKILL-066 (Resolved→propose-only-no-move EC-007; Closed→create-new+link-no-move EC-008) |
| SM-27 | monitoring-loop grace-window Jira-first dedup | **dedup-check-removed → double-ticket** (ADV-F2-P2-009c) — skip the Stage-2 Jira-first dedup lookup so a grace-window re-fetched event with an existing open ticket creates a SECOND (duplicate) ticket | VP-SKILL-068 (in-grace event with existing open ticket → append-COMMENT, NOT create; mutant creates the duplicate and dies) |
| SM-28 | monitoring-loop stage-order (document-before-action) | **stage-order-inverted** (ADV-F2-P2-001) — execute Stage 8 TICKET ACTION (`jr` Bash) BEFORE the Stage 7 DOCUMENT verdict Write, so no marker exists when require-review evaluates the jr call | VP-HOOK-027 negative leg (jr Bash with empty marker dir → DENY); positive leg proves correct order → ALLOW |
| SM-29 | disposition-guard emitter hard-floor asset_type set | **unknown-asset-hard-floor-removed** (ADV-F2-P3-001) — drop `asset_type=='unknown'` from the hard-floor set so a LOW-severity + benign-technique + `asset_type=unknown` + `ticket_action_type=comment` verdict is issued a REGULAR comment marker (defense-in-depth breach on the authorization boundary) | VP-HOOK-026 unknown-asset leg (assert NO regular comment/create/assign-scoped marker for `asset_type=unknown` — a STEP 4 review-upgrade marker is acceptable, a regular autonomous-triage marker is not); the mutant issues a REGULAR comment marker and dies |
| SM-30 | disposition-guard artifact-class field-set router | **artifact-class-over-strict** (ADV-F2-P3-003) — apply the 18-field set to the investigation-markdown class (demand Severity/Asset Type/Ticket Action Type headings) so a valid 12-field investigation markdown is wrongly DENIED (regresses the investigate-event DI-013 marker path) | VP-HOOK-025 investigation-12-field-accept test (12-heading investigation → allow) + Severity-heading-inserted-into-investigation → still allow (no wrong-class 18-field deny) |
| SM-31 | disposition-guard `validate_enums()` membership gate | **validate_enums-removed** (ADV-F2-P4-006) — remove the pre-hard-floor enum-membership check so a case-mangled `severity="High"` (or `asset_type="Unknown"` / `disposition="indeterminate"` / `sensor_health_status="Degraded"` / `ticket_action_type="NONE"`) passes key-presence, silently fails the `∈{HIGH,CRITICAL}` membership test, escapes the hard floor, and is issued a marker | VP-HOOK-025 enum-membership legs (`severity="High"`→DENY, etc.); the mutant issues a marker for a case-mangled HIGH verdict and dies |
| SM-32a *(RE-TARGETED v1.10 — the STEP-4 upgrade it formerly removed is RETIRED)* | disposition-guard emitter STEP 4 DENY-THE-WRITE (vs the retired GOTO-WRITE_MARKER upgrade) | **step4-deny-reverted-to-retired-upgrade** (ADV-F2-P7-001 CRITICAL) — revert the STEP-4 deny to the now-RETIRED P5-001/P6-002 marker-upgrade (`GOTO WRITE_MARKER` issuing a `create-review`/`comment-review` marker) instead of denying the Write, so an under-labeled hard-floor verdict again produces an in-store marker WITHOUT the loop having re-documented — a marker the loop's own non-review `jr` command cannot consume (the P7-001 seam gap re-appears) | **VP-HOOK-029 consumer-boundary vector (7)** (`create-review` marker + `jr issue create` WITHOUT `--label` → DENY: proves no unconsumable marker is left in-store) + the deny-path assertion that NO marker exists for the original denied Write — the mutant leaves an unconsumable marker in-store and dies |
| SM-32-ext *(kill vector RE-WORDED v1.10 to the deny-before-kill-switch assertion)* | disposition-guard emitter STEP order (kill switch vs STEP-4 deny) | **step-order-reverted** (ADV-F2-P6-002 CRITICAL / P7-001) — revert the reorder so the `autonomy_enabled` kill switch runs BEFORE the hard-floor STEP-4 handling. Under `autonomy_enabled=false`, an under-labeled hard-floor verdict then hits the kill switch first → `emit allow without marker; RETURN` before the STEP-4 DENY can fire → the finding is silently allowed (no deny, no UNDER-LABEL-DENIED audit) exactly as in P6-002 | **VP-HOOK-029 kill-switch-irrelevance deny vector (8)** (STEP-4 deny fires identically with `autonomy_enabled` true AND false — STEP 4 precedes STEP 5; assert `UNDER-LABEL-DENIED` + deny in BOTH cases) — under the mutant the `autonomy_enabled=false` case yields a silent allow with no deny/audit, and the vector catches it |
| SM-36 | require-review consumer STEP 6a review-marker label check | **consumer-review-label-check-removed** (ADV-F2-P6-001 CRITICAL) — remove the `IF authorized_operations==["create-review"] AND NOT has_review_label: CONTINUE` guard so a `["create-review"]` marker is consumed by a regular `jr issue create --project ORG_A` command that lacks `--label REVIEW-REQUIRED\|BLIND-SPOT` → a regular autonomous create steals a hard-floor escalation's review marker (the P6-001 kill-switch/hard-floor bypass) | **VP-HOOK-024 named vector `create-review-marker-requires-review-label`** (create-review marker + no-`--label` command → DENY); the mutant allows the no-label create and dies |
| SM-37 | require-review consumer STEP 6a regular-marker reverse label check | **consumer-reverse-label-check-removed** (ADV-F2-P6-001 CRITICAL) — remove the `IF authorized_operations==["create"] AND has_review_label: CONTINUE` guard so a regular `["create"]` marker is consumed by a review-labeled `jr issue create --project ORG_A --label REVIEW-REQUIRED …` command → the reverse fungibility direction (a regular marker authorizes a review-labeled escalation write) | **VP-HOOK-024 named vector `create-marker-rejects-review-label`** (create marker + `--label` command → DENY); the mutant allows the review-labeled create and dies |
| SM-32b | disposition-guard emitter STEP 3 over-label gate | **step3-hard-floor-gate-removed** (ADV-F2-P5-002 MAJOR) — remove the `IF NOT hard_floor_applies(verdict): emit allow without marker; RETURN` guard at STEP 3 so a NON-hard-floor verdict (disposition=TP, LOW severity, standard asset) carrying an LLM-supplied `create-review`/`comment-review` token receives the kill-switch + hard-floor EXEMPT review marker → the LLM manufactures a kill-switch bypass by over-labeling a regular verdict | **VP-HOOK-026 over-label legs** (non-hard-floor TP + create-review → NO marker; non-hard-floor FP + comment-review + autonomy_enabled=false → NO marker; LOW-severity standard asset + create-review → NO marker) — the mutant issues a marker for a non-hard-floor verdict and dies |
| SM-33 | disposition-guard emitter `autonomy_enabled` kill switch (Step 5) *(renumbered from Step 4 by the ADV-F2-P6-002 reorder)* | **autonomy_enabled-clause-removed** (ADV-F2-P4-005) — remove the direct `verdict.autonomy_enabled != true` suppression clause so a REGULAR `create`/`comment` marker is wrongly emitted under the kill switch (`autonomy_enabled=false` or absent) | VP-HOOK-026 kill-switch legs (`autonomy_enabled=false`/absent + regular create/comment → NO marker); mutant emits a marker and dies |
| SM-34 | disposition-guard artifact-class dispatch order | **dispatch-order-inverted** (ADV-F2-P4-001) — test the `investigation` path substring BEFORE the JSON-content check so the canonical `artifacts/investigations/verdict-*.json` (contains BOTH substrings) is misrouted to the 12-field markdown heading-grep branch, fails all `## `-heading assertions, is DENIED, and emits no marker (pipeline unreachable) | VP-HOOK-028 canonical-path leg (`.../verdict-alert-001.json` → JSON-first → 18-field path → marker emitted); mutant denies the verdict JSON and dies |
| SM-35 | require-review audit-log field encoding | **control-char-strip-removed** (ADV-F2-P4-010) — drop the `tr -d '\000-\037'` sanitization on `ticket_id`/`org_slug`/`op` so a `\n` embedded in `ticket_id` (Jira-content-influenced) forges an additional MARKER_USED line in `audit.log`, corrupting the chain-of-custody record | VP-HOOK-024 v1.5 audit leg (`ticket_id` containing `$'\n'` → exactly one MARKER_USED line; a forged second line fails the assertion) |
| **SM-38** *(NEW v1.10; occupancy-verified — next free after SM-37)* | disposition-guard emitter STEP 4 DENY-THE-WRITE | **step4-deny-removed** (ADV-F2-P7-001 CRITICAL) — remove the STEP-4 deny entirely, reverting to `emit allow without marker; RETURN` so an under-labeled hard-floor verdict is silently allowed with no marker, no deny, and no audit entry (the original P5-001 silent-discard failure mode) | **VP-HOOK-029 deny-path vectors (1)–(3)** (Indeterminate+create / HIGH+none / degraded-sensor+assign → verdict Write DENIED + `UNDER-LABEL-DENIED` audit) — the mutant produces a silent allow with no deny/audit and dies |
| **SM-39** *(NEW v1.10; occupancy-verified — next free after SM-38)* | disposition-guard STEP-4 deny corrective-reason structure | **deny-corrective-reason-removed** (ADV-F2-P7-004 MAJOR) — keep the STEP-4 deny but strip the machine-readable corrective-reason fields (`hard_floor_trigger`, `required_token`, `label_instruction`, `instruction`) from the deny message, emitting a bare/opaque deny — the Write is denied but the loop has no structured signal to re-document with the correct review token (the fail-loud becomes fail-STUCK) | **VP-HOOK-029 machine-actionable-reason vector (4)** (deny reason parses with `required_token=comment-review` / `create-review` + non-empty `hard_floor_trigger` + `label_instruction`) — the mutant emits a structureless deny and dies |
| **SM-40** *(NEW v1.10; occupancy-verified — next free after SM-39)* | require-review consumer STEP 6a `has_review_label` structural token check (D-DEC-001) | **has_review_label-reverted-to-raw-substring** (ADV-F2-P7-005 MINOR) — revert `structural_label_check(cmd)` (standalone `--label` token immediately preceding REVIEW-REQUIRED/BLIND-SPOT) to the defective raw-substring test `("--label REVIEW-REQUIRED" in command)` so a REGULAR create whose `--summary` merely CONTAINS the literal string is falsely flagged as review-labeled → false-DENY of a legitimate `["create"]`-marker create | **VP-HOOK-024 named vector `regular-create-with-label-literal-in-summary-allowed`** (regular create + `--summary "…--label REVIEW-REQUIRED…"` + `["create"]` marker → ALLOW) — under the mutant this legitimate create is wrongly DENIED and the mutant dies |
| **SM-41** *(NEW v1.11; occupancy-verified — next free after SM-40)* | disposition-guard emitter STEP 3 create-review/comment-review missing-binding branch (`HARD-FLOOR-UNBINDABLE` DENY-THE-WRITE) | **step3-create-review-unbindable-allow-reverted** (ADV-F2-P8-001 CRITICAL) — revert the STEP-3 `IF project_key is null/empty` (create-review) branch to the pre-P8-001 `emit allow without marker; RETURN` so a genuinely hard-floor verdict with a CORRECT `create-review` token but a null `jira_project_key` is silently allowed with no marker, no deny, and no `HARD-FLOOR-UNBINDABLE` audit entry — the P5-001/P7-001 silent-discard anti-pattern re-appearing on the *correctly-labeled* review path (the exact P8-001 residual) | **VP-HOOK-029 unbindable-deny vectors (9)–(11)** (Indeterminate/silent-sensor + create-review + null `jira_project_key` → verdict Write DENIED + `HARD-FLOOR-UNBINDABLE` audit; comment-review + null `ticket_id` variants) — the mutant produces a silent allow with no deny/audit and dies. **Separately killable from SM-38** (SM-38 reverts the STEP-4 *under-label* deny; SM-41 reverts the STEP-3 *missing-binding* deny — distinct branches, distinct vectors) |
| **SM-42** *(NEW v1.11; occupancy-verified — next free after SM-41)* | require-review consumer STEP 6a `structural_label_check` quote-aware tokenizer (D-DEC-001) | **structural_label_check-reverted-to-non-quote-aware-split_on_whitespace** (ADV-F2-P8-002 MAJOR) — revert the quote-aware state-machine tokenizer (UNQUOTED/IN_SINGLE/IN_DOUBLE) to the P7-005 `split_on_whitespace`, which naively tokenizes a double-quoted `--summary` value so a `--label REVIEW-REQUIRED` literal INSIDE the quoted value is seen as a standalone `--label` token immediately preceding `REVIEW-REQUIRED` → `has_review_label=true` → false-DENY of a legitimate `["create"]`-marker regular create (EC-024's own example) | **VP-HOOK-024 named vector `regular-create-with-label-literal-in-summary-allowed`** (QUOTED form: `["create"]` marker + `jr issue create --project PRISMDEMO --summary "…--label REVIEW-REQUIRED…"` → ALLOW) — under the mutant the quoted vector wrongly DENIES and the mutant dies. **Separately killable from SM-40** (SM-40 = raw-substring revert, dies because the substring matches inside the quoted region; SM-42 = split_on_whitespace revert, dies because whitespace-splitting breaks the quoted value into a standalone `--label` token — distinct failure mechanisms, same vector) |
| **SM-43** *(NEW v1.12; occupancy-verified — next free after SM-42)* | require-review consumer STEP 6a `structural_label_check` backslash-escape handling (D-DEC-001 v1.12) | **step6a-in_double-backslash-escape-reverted** (ADV-F2-P9-001 MAJOR) — revert the D-DEC-001 v1.12 backslash-aware tokenizer (`\"` in IN_DOUBLE → literal `"`, STAY IN_DOUBLE; `\'` in UNQUOTED → literal `'`, no state toggle) to the P8-002 toggle-on-every-quote behavior, so for `jr issue create --project PRISMDEMO --summary "a\"b" --label REVIEW-REQUIRED` the `\"` prematurely CLOSES the double-quoted region and the following `"` re-opens it, swallowing the REAL trailing `--label REVIEW-REQUIRED` into the `--summary` token → `has_review_label=false` → a `["create"]` regular marker wrongly AUTHORIZES a command that (per bash/jr) applies a functional REVIEW-REQUIRED label — the exact EC-023 direction-A fungibility bypass, undetectable now that P8-003 removed the step-5 backstop | **VP-HOOK-024 escaped-quote vector 1a** (`["create"]` marker + `--summary "a\"b" --label REVIEW-REQUIRED` → `has_review_label=TRUE` → DENY) — under the mutant the escaped-quote boundary hides the real label and the marker wrongly ALLOWs, and the mutant dies. **Separately killable from SM-42** (non-quote-aware `split_on_whitespace` revert) **and SM-40** (raw-substring revert): SM-43 exercises the backslash-escape class that neither of those mutations or their vectors touch — the P8-002 quoted-form vector does not contain a `\"`, so it cannot detect SM-43, and the escaped-quote 1a vector is the dedicated killer |
| **SM-44** *(NEW v1.13; occupancy-verified — next free after SM-43)* | disposition-guard emitter STEP 1a hook-side severity re-normalization (D-DEC-008/D-DEC-013 — O6) | **step1a-severity-renormalization-reverted** (ADV-F2-P10-001 CRITICAL) — remove the STEP-1a `recomputed_severity = NORMALIZE_SEVERITY(native_severity, sensor_family)` cross-check; `hard_floor_applies()` keys on the raw LLM-supplied `verdict.severity` (the pre-P10-001 trust basis). A verdict with `sensor_family=crowdstrike`, `native_severity="90"` (→CRITICAL) but `verdict.severity="LOW"` then produces NO SEVERITY-MISMATCH deny, `hard_floor_applies()` returns FALSE, and the genuinely-CRITICAL alert is auto-dispositioned with a regular marker — the O6 severity-underreporting bypass | **VP-HOOK-030 per-family SEVERITY-MISMATCH consistency vectors (1)–(4)** (crowdstrike 90+LOW / armis Critical+MEDIUM / claroty High+LOW / cyberint any+LOW → SEVERITY-MISMATCH deny + audit) — under the mutant the recomputed≠reported mismatch is not detected, NO deny fires, the hard floor is bypassed, and the mutant dies. Separately assert the AGREEMENT vector (crowdstrike 90+CRITICAL → proceed) is unaffected. **(P14-001 / P11-003: the former CVSS-float under-report vector (5) is REMOVED — NVD/CVSS is not a `sensor_family` / NORMALIZE_SEVERITY family; CVSS feeds `scored_priority` at Stage 5, not `native_severity`.)** |
| **SM-45** *(NEW v1.13; occupancy-verified — next free after SM-44)* | disposition-guard emitter WRITE_MARKER review-path failure handling (D-DEC-012 clause 2 — P10-003) | **writemarker-review-path-allow-without-marker-reverted** (ADV-F2-P10-003 MAJOR) — revert the `IF NOT write_ok: IF is_review_path: WRITE MARKER-WRITE-FAILED audit + emit deny` branch to the blanket `emit allow without marker; RETURN` regardless of `is_review_path`, so a genuinely hard-floor create-review/comment-review verdict whose marker fails to write (disk full / read-only volume / permissions drift) is silently allowed — no marker, no deny, no `MARKER-WRITE-FAILED` audit; Stage-8 `jr issue create --label REVIEW-REQUIRED` is then denied by require-review (no marker), the loop has no re-doc obligation (that fires only on STEP-3/STEP-4 denies), and the hard-floor finding is silently dropped with no Jira ticket and no error artifact (the P8-001-class silent-discard re-appearing on the infra-failure branch) | **VP-HOOK-029 MARKER-WRITE-FAILED review-path vectors (13/14)** (create-review/comment-review + simulated write failure → verdict Write DENIED + `MARKER-WRITE-FAILED` audit, NEVER allow-without-marker) — under the mutant the review-path write failure yields a silent allow with no deny/audit and the mutant dies; the REGULAR-path control (14a: comment + write failure → allow-without-marker) confirms the fix is scoped to the review path. **Separately killable from SM-41** (STEP-3 null-binding unbindable deny — a DIFFERENT branch: null binding field vs write-syscall failure) and **SM-38** (STEP-4 under-label) |
| **SM-46** *(NEW v1.14; occupancy-verified — `grep -rn 'SM-46' .factory/` returned no match before allocation; next free after SM-45)* | disposition-guard `hard_floor_applies()` high-severity floor key (D-DEC-008 / §3.9 — P11-002) | **highseverity-floor-rekeyed-to-recomputed-severity** (ADV-F2-P11-002 MAJOR) — revert the P11-002 change so the HIGH/CRIT floor keys on `recomputed_severity` (STEP 1a output) instead of `verdict.scored_priority` (field 18). A verdict with `verdict.severity=LOW`, `native_severity="10"`/`sensor_family=crowdstrike` (STEP 1a consistency passes: recomputed LOW == LOW), but `scored_priority=CRIT` (assess-priority KEV/exposure escalation of a detector-LOW alert, brief §3.9) then has `recomputed_severity=LOW` → the mutant's floor returns FALSE → the CRIT-scored alert is eligible for a regular autonomous-triage marker — the §3.9 "any alert scored HIGH/CRIT → human" bypass | **VP-HOOK-026 scored_priority floor vector (iii) detector-LOW/scored-CRIT** (`verdict.severity=LOW` + consistent native_severity + `scored_priority=CRIT` → hard floor STILL fires, NO regular marker) — under the mutant the floor keys on recomputed LOW → FALSE → a regular marker is wrongly issued for a CRIT-scored alert and the mutant dies. Distinct from SM-44 (STEP 1a consistency): SM-44 removes the severity↔native consistency check; SM-46 re-keys the FLOOR to the wrong field — the STEP 1a consistency check still passes under SM-46 |
| **SM-47** *(NEW v1.14; occupancy-verified — `grep -rn 'SM-47' .factory/` returned no match before allocation; next free after SM-46)* | disposition-guard artifact-class router — investigation-markdown emitter entry (P11-004) | **markdown-routed-into-verdict-emitter** (ADV-F2-P11-004 MAJOR) — route the 12-field investigation-markdown (`*investigation-*.md`) path INTO the verdict emitter (run `validate_enums()`/STEP 1a on it) instead of the separate minimal comment-scoped marker path. A complete 12-field ICD-203 investigation markdown has NO `severity`/`asset_type`/`ticket_action_type`/`native_severity`/`sensor_family`/`scored_priority` (verdict-only fields), so `validate_enums()` fail-closed-DENIES it — the analyst's investigation Write is blocked at save time (the exact P11-004 impossibility) | **VP-HOOK-031 vectors (c)/(a)** (a compliant 12-field markdown with no verdict-only fields is NOT denied by validate_enums()/STEP 1a; the compliant save emits a `["comment"]` marker and is NOT denied) — under the mutant the compliant investigation save is wrongly DENIED by validate_enums() on the absent verdict-only fields and the mutant dies. Distinct from SM-19/SM-34 (dual-path router direction): SM-47 keeps JSON→verdict routing correct but wrongly subjects the MARKDOWN class to the verdict emitter's enum/STEP-1a gates |
| **SM-48** *(NEW v1.15; occupancy-verified — `grep -rn 'SM-48' .factory/` returned no match before allocation; SM-P12-A → next free after SM-47)* | disposition-guard `command_pattern` construction — `ticket_id` charset-validation (D-DEC-012 O7 / P12-001) | **ticket_id-charset-validation-removed** (ADV-F2-P12-001 CRITICAL) — remove the `IF NOT regex_match("^[A-Z][A-Z0-9]+-[0-9]+$", ticket_id): TICKET-ID-CHARSET-DENY + deny` gate (and the regex-escape) at all `ticket_id` interpolation sites (STEP 6 comment/assign, STEP 3 comment-review, markdown comment path). A verdict with `ticket_id=".*"` then builds `command_pattern="^jr (--output json )?issue comment .* "`, which require-review's `[[ =~ ]]` matches for ANY `jr issue comment <anything>` → the marker authorizes an unrelated comment command far outside the intended ticket scope (the SEC-009 unanchored/broadened-match bypass; `ticket_id="SEC-1 \|.*#"` injects an alternation matching arbitrary commands) | **VP-HOOK-032 TICKET-ID-CHARSET-DENY vectors** (`ticket_id='.*'` / `'SEC-1 \|.*#'` on comment/assign/comment-review/markdown paths → DENY + `TICKET-ID-CHARSET-DENY` audit BEFORE pattern construction) — under the mutant `.*` is interpolated, the broadened pattern authorizes `jr issue comment ANY-TICKET foo`, and the mutant dies; the valid `ticket_id='SEC-123'→anchored` vector confirms no false-deny |
| **SM-49** *(NEW v1.15; occupancy-verified — `grep -rn 'SM-49' .factory/` returned no match before allocation; SM-P12-B → next free after SM-48)* | disposition-guard `command_pattern` construction — `jira_project_key` charset-validation (D-DEC-012 O7 / P12-007) | **jira_project_key-charset-validation-removed** (ADV-F2-P12-007) — remove the `IF NOT regex_match("^[A-Z][A-Z0-9]+$", jira_project_key): PROJECT-KEY-CHARSET-DENY + deny` gate at the `jira_project_key` interpolation sites (STEP 3 create-review, STEP 6 create). A verdict with `jira_project_key="PRISM( \|$)\|.*"` then builds a broadened create pattern whose injected alternation matches an unrelated command → bypass of the project-scoped create authorization | **VP-HOOK-032 PROJECT-KEY-CHARSET-DENY vectors** (`jira_project_key='X( \|$)\|.*'` on create / `'.*'` on create-review → DENY + `PROJECT-KEY-CHARSET-DENY` BEFORE pattern construction) — under the mutant the broadened pattern authorizes an unrelated create command and the mutant dies; the valid `jira_project_key='PRISM'` vector confirms no false-deny. Separately killable from SM-48 (SM-48 = ticket_id grammar `^[A-Z][A-Z0-9]+-[0-9]+$` on comment/assign/comment-review/markdown; SM-49 = jira_project_key grammar `^[A-Z][A-Z0-9]+$` on create/create-review — distinct fields, distinct sites) |
| **SM-50** *(NEW v1.15; occupancy-verified — `grep -rn 'SM-50' .factory/` returned no match before allocation; SM-P12-C → next free after SM-49)* | disposition-guard markdown (Human-Comment) path — `autonomy_enabled` kill-switch gate (D-DEC-008 / P12-002) | **markdown-kill-switch-gate-removed** (ADV-F2-P12-002 CRITICAL) — remove the FIRST-check `IF autonomy_enabled != true: emit allow-without-marker` gate on the markdown path, reverting to the pre-P12-002 behavior where the markdown path issues a live `["comment"]` marker regardless of the kill switch. Under `autonomy_enabled=false`, the autonomous loop can write an `investigation-*.md` and obtain a comment marker → the loop autonomously comments under an ACTIVE kill switch (an LLM artifact-class choice bypassing the deterministic §3.9 kill-switch control the verdict path honors) | **VP-HOOK-031 kill-switch vector (a1)** (`autonomy_enabled=false` + complete 12-field markdown → allow-without-marker, no Jira action) — under the mutant a comment marker IS issued under the kill switch and the mutant dies; vectors (a2)/(a3) confirm the gate semantics. Distinct from SM-25 (monitoring-loop kill-switch on the verdict/jr path) — SM-50 is the markdown-marker-path kill-switch gate inside disposition-guard |
| **SM-51** *(NEW v1.15; occupancy-verified — `grep -rn 'SM-51' .factory/` returned no match before allocation; SM-P12-D → next free after SM-50; **RECONCILED v1.16 — killer vector shifted under P13-001, mutant remains VALID**)* | disposition-guard markdown (Human-Comment) path — non-FP→route-to-review rule (D-DEC-008 / P12-002; MARKDOWN_COMMENT_PATH eliminated P13-001) | **markdown-non-FP-route-to-review-removed** (ADV-F2-P12-002 CRITICAL; SEMANTICS updated by P13-001) — remove the `IF parsed_disposition != "FP": GOTO MARKDOWN_REVIEW_PATH` routing rule. **Under P13-001 (MARKDOWN_COMMENT_PATH eliminated) there is no comment marker to fall back to**, so removing the routing rule makes a non-FP (TP/BTP/PARSE_FAIL) markdown **fall through to allow-without-marker (like FP)** instead of surfacing to human review — an escalation-worthy finding is silently NOT surfaced (still the masquerade-class under-surfacing bug: the loop writes a TP as `investigation-*.md` to reach a weaker gate). DISTINCT from SM-52 (which reverts the FP branch to a comment marker) and SM-50 (which removes the kill-switch gate) | **VP-HOOK-031 disposition-routing vector (c2)** (`Disposition: TP` markdown → create-review/comment-review review marker, NOT allow-without-marker; (c4) masquerade: investigation-TP-*.md with HIGH indicators → review marker) — under the mutant a TP markdown gets allow-without-marker instead of a review marker and the mutant dies; vector (c1) (`Disposition: FP` → allow-without-marker) confirms benign FP investigations are unaffected. Separately killable from SM-50 (SM-50 = kill-switch gate absent → non-FP under `autonomy=false` wrongly routed to review; SM-51 = routing rule absent → non-FP wrongly gets allow-without-marker even with the kill switch off — distinct branches) and from SM-52 (FP-branch comment-marker revert) |
| **SM-52** *(NEW v1.16; occupancy-verified — `grep -rn 'SM-52' .factory/` returned no match before allocation; SM-P13-A → next free after SM-51)* | disposition-guard markdown (Human-Comment) path — FP→allow-without-marker rule (MARKDOWN_COMMENT_PATH elimination, D-DEC-008 / P13-001) | **markdown-fp-comment-marker-revert** (ADV-F2-P13-001 CRITICAL) — revert P13-001: restore the eliminated MARKDOWN_COMMENT_PATH so the `parsed_disposition == "FP"` branch, after the markdown-evaluable floors pass, emits an autonomous `["comment"]` marker (the pre-P13-001 P12-002 FP-branch behavior) instead of allow-without-marker. Because the hook cannot evaluate scored_priority (field 18) / asset_type (field 14) from a 12-field markdown and there is no known-FP store cross-check on this path, this restores the unfloored autonomous comment ADV-F2-P13-001 flagged — an LLM `Disposition: FP` label authorizes an autonomous `jr issue comment` with none of the scored_priority/asset_type hard-floor enforcement the JSON verdict path applies | **VP-HOOK-031 FP→allow-without-marker vector (c1)** (complete 12-field `Disposition: FP`, autonomy_enabled=true, all floors pass → allow-without-marker; NO `["comment"]` marker written; Write NOT denied) — under the mutant a `["comment"]` marker IS issued for the FP markdown and the mutant dies. DISTINCT from SM-51 (non-FP→review branch) and SM-50 (kill-switch gate); SM-52 targets specifically the FP→allow-without-marker branch (the eliminated comment path) |
| **SM-53** *(NEW v1.16; occupancy-verified — `grep -rn 'SM-53' .factory/` returned no match before allocation; next free after SM-52)* | disposition-guard markdown path — `parse_disposition_from_markdown` canonical-heading-anchored parse (P13-003) | **markdown-disposition-full-document-substring-scan** (ADV-F2-P13-003 MAJOR) — revert the strict canonical-heading-anchored parse to a full-document substring scan for `Disposition: FP` (the P13-003 grammar reads ONLY the value of the canonical `Disposition` heading against the {TP,FP,BTP,Indeterminate}+long-form allowlist, PARSE_FAIL→review otherwise). Under the mutant, a `Disposition: FP` string embedded in an evidence block / fenced code block / quoted log (with NO canonical Disposition heading, or with a canonical non-FP heading) is read as FP → the markdown gets **allow-without-marker instead of the review route** — an adversarial or accidental embedded-FP label suppresses surfacing of a review-worthy finding (the negated-FP / code-fence bypass) | **VP-HOOK-031 parse-grammar vectors (p3 FP-in-code-fence) + (p1 negated-FP)** (`Disposition: FP` only inside a code fence, no canonical heading → PARSE_FAIL → review; `Disposition` heading value 'not a false positive' → PARSE_FAIL → review) — under the mutant the embedded/negated FP is read as FP → allow-without-marker instead of review and the mutant dies; positive controls (p6 canonical `Disposition: FP`→allow-without-marker, p7 long-form) confirm no false-deny of a genuine FP. Distinct from SM-52 (SM-52 = FP-branch outcome revert with a correct parse; SM-53 = correct outcome mapping but a defective parse that mis-labels non-FP/embedded content as FP) |
| **SM-54** *(NEW v1.17; occupancy-verified — `grep -rn 'SM-54' .factory/` returned no match before allocation; next free after SM-53)* | activate + onboard-customer SKILL setup-flow `jira_project_key` charset-validation (BC-6.01.001 PC#12/EC-014 + BC-6.01.003 Inv#6/EC-010 — P14-002) | **setup-time-charset-validation-removed** (ADV-F2-P14-002 MAJOR) — remove the setup-time `IF NOT regex_match("^[A-Z][A-Z0-9]+$", jira_project_key): error + halt (no partial-state write)` gate from the activate and onboard-customer setup helpers. A hyphenated key like `PRISM-DEMO` is then ACCEPTED and STORED at setup time; every downstream marker issuance that interpolates that key into a `command_pattern` at runtime hits the VP-HOOK-032 `PROJECT-KEY-CHARSET-DENY` (or, on the hard-floor review path, the `HARD-FLOOR-UNBINDABLE` deny) — a fail-closed livelock where no Jira write ever authorizes (the finding is stuck) even though the operator supplied a superficially-valid config. The runtime deny is NOT redundant with setup-time validation: without SM-54's gate the bad key silently persists in config and breaks the loop far from the point of entry | **VP-SKILL-076 reject-at-setup vector** (`jira_project_key="PRISM-DEMO"` fed to `activate` / `onboard-customer` → setup HALTS with a user-facing charset error, exit non-zero, NO config / partial-state written; conformant `PRISMDEMO` → accepted) — under the mutant the hyphenated key is stored at setup (no reject), so the reject-at-setup assertion fails and the mutant dies; the runtime `PROJECT-KEY-CHARSET-DENY` (VP-HOOK-032) proves the end-to-end consequence the setup gate prevents. Distinct from SM-49 (VP-HOOK-032, runtime command_pattern jira_project_key charset gate) — SM-54 is the SETUP-TIME preventive gate, a separate call-site |
| **SM-56** *(NEW v1.19; occupancy-verified — FRESH grep: `grep -rn 'SM-56' .factory/` returned no match before allocation; SM-55 NOT reused (reserved-skipped — its ~15-place 'skipped' record would collide-of-meaning), so next-free control-flow id = SM-56)* | disposition-guard `hard_floor_applies()` scored_priority high-severity floor — known-FP branch (D-019 — P17-001) | **known-FP-floor-bypass-branch-added** (ADV-F2-P17-001 / D-019) — add a known-FP carve-out to `hard_floor_applies()` (`IF verdict matches known-FP store: return FALSE`, or the equivalent P12-003b/D-016 "known-FP EXEMPT from the scored_priority floor" branch) so a HIGH/CRIT-native known-FP (`scored_priority ∈ {HIGH,CRIT}` + healthy sensor + non-forbidden technique + disposition=FP) is AUTO-CLOSED (regular comment marker) instead of being denied at STEP 4 and routed to comment-review. This is the exact bypass D-019 forbids: disposition-guard has no forgery-proof known-FP signal, so any in-band known-FP branch is either LLM-forgeable (a CRITICAL O6 bypass — an adversarial/buggy LLM sets the known-FP condition on any HIGH/CRIT verdict to skip the highest-severity floor) or, if store-derived, still lets a poisoned HIGH-sev store entry silently suppress a real high-severity alert (DI-015 residual). The floor MUST fire unconditionally on scored_priority ∈ {HIGH,CRIT} | **VP-HOOK-026 D-019 vectors (b)/(c)** (HIGH-native known-FP + store match + disposition=FP → `hard_floor_applies()`=TRUE → DENY-THE-WRITE (HARD-FLOOR-UNDER-LABEL) → comment-review, NOT auto-close; CRIT-native known-FP → same) — under the mutant the added known-FP branch returns FALSE → the HIGH/CRIT known-FP auto-closes with a regular marker instead of routing to review, and the mutant dies; the LOW/MED-native known-FP auto-close vector (a) confirms the floor legitimately does NOT fire for low-severity known-FPs (no false-deny). Distinct from SM-46 (which re-keys the floor to recomputed severity) and SM-16 (which removes the STEP-4 hard-floor gate entirely) — SM-56 keeps the floor key and gate correct but adds a known-FP escape branch |

**New mutation vector count: 49 (SM-9 … SM-56, SM-55 reserved-skipped; SM-32 = SM-32a + SM-32b + SM-32-ext as of v1.9; SM-32a re-targeted + SM-32-ext kill vector re-worded at v1.10; +SM-38/SM-39/SM-40 at v1.10; +SM-41/SM-42 at v1.11; +SM-43 at v1.12; +SM-44/SM-45 at v1.13; +SM-46/SM-47 at v1.14; +SM-48/SM-49/SM-50/SM-51 at v1.15; +SM-52/SM-53 at v1.16; +SM-54 at v1.17; SM-55 SKIPPED at v1.18 (reserved-skipped); +SM-56 at v1.19).** SM-9..SM-16,
SM-21..SM-22, and SM-29..SM-30 land on the require-review + disposition-guard marker surface — the
CRITICAL authorization boundary (module-criticality: require-review C-12 CRITICAL ≥95%;
monitoring-loop surfaces CRITICAL at per-artifact granularity). SM-12 is the explicit
SEC-009-regression sentinel; SM-21 is the explicit ADV-F2-001 severity/confidence-conflation
sentinel; SM-23 is the ADV-F2-005 hard-floor-ordering sentinel; SM-28 is the ADV-F2-P2-001
document-before-action-ordering sentinel; **SM-29 is the ADV-F2-P3-001 unknown-asset hard-floor
sentinel (the pass-3 CRITICAL) and SM-30 is the ADV-F2-P3-003 artifact-class field-set sentinel.
SM-31 is the ADV-F2-P4-006 enum-membership-bypass sentinel, SM-33 the ADV-F2-P4-005
kill-switch-determinism sentinel, SM-34 the ADV-F2-P4-001 dispatch-collision sentinel (both pass-4
CRITICALs land here); SM-32a is the ADV-F2-P5-001 CRITICAL under-label silent-discard sentinel
(killed by VP-HOOK-029) and SM-32b the ADV-F2-P5-002 MAJOR over-label kill-switch-bypass sentinel
(killed by VP-HOOK-026) — the pass-5 under/over-label duals of the single "hook trusted the
LLM-supplied ticket_action_type" root cause; SM-35 the ADV-F2-P4-010 audit-forgery sentinel.**
**v1.9 (pass-6): SM-32-ext is the ADV-F2-P6-002 CRITICAL step-order sentinel (kill vector re-worded at
v1.10 to the deny-before-kill-switch assertion); SM-36 and SM-37 are the ADV-F2-P6-001 CRITICAL consumer
anti-fungibility sentinels (killed by VP-HOOK-024's STEP 6a exact-type vectors in both directions) — the
fungibility of review vs regular create markers was the pass-6 kill-switch/hard-floor bypass root cause.**
**v1.10 (pass-7): the STEP-4 DENY-THE-WRITE redesign replaces the retired marker-upgrade. SM-38 is the
ADV-F2-P7-001 CRITICAL step4-deny-removed sentinel (silent-allow re-appears; killed by VP-HOOK-029's
deny-path vectors); SM-39 is the ADV-F2-P7-004 MAJOR deny-corrective-reason-removed sentinel (the fail-loud
deny becomes fail-STUCK; killed by VP-HOOK-029's machine-actionable-reason vector); SM-32a is RE-TARGETED to
the ADV-F2-P7-001 "revert-deny-to-retired-upgrade" sentinel (unconsumable in-store marker; killed by
VP-HOOK-029's consumer-boundary vector — the O4 seam-gap guard); SM-40 is the ADV-F2-P7-005 MINOR
step-6a-raw-substring false-deny sentinel (killed by VP-HOOK-024's structural-check false-deny vector).**
**v1.11 (pass-8): SM-41 is the ADV-F2-P8-001 CRITICAL step3-create-review-unbindable-allow sentinel — the
correctly-labeled-yet-unbindable silent-discard residual (killed by VP-HOOK-029's unbindable-deny vectors
9–11; separately killable from SM-38, the STEP-4 under-label deny sentinel); SM-42 is the ADV-F2-P8-002
MAJOR structural_label_check-non-quote-aware sentinel (killed by VP-HOOK-024's QUOTED-form false-deny vector;
separately killable from SM-40, the raw-substring revert). Because bash `[[ =~ ]]` is NOT tail-anchored
(P8-003), step 6a is the SOLE anti-fungibility enforcement point for EC-023 direction A (no step-5 backstop),
so the step-6a mutant family SM-36/SM-37/SM-40/SM-42 lands on a P0-adjacent, NON-REDUNDANT single-point-of-
failure surface — SM-36/SM-37 remain CRITICAL and the whole family MUST be killed at the ≥95% require-review
bar (there is no step-5 redundancy to catch a mis-fired 6a).**
**v1.12 (pass-9): SM-43 is the ADV-F2-P9-001 MAJOR step6a-backslash-escape sentinel — it JOINS the step-6a
anti-fungibility family (now SM-36/SM-37/SM-40/SM-42/SM-43), extending the differential-vs-bash coverage to
the backslash-escape class (`\"` in IN_DOUBLE / `\'` in UNQUOTED) per the O5 standing rule (§0). Because step
6a is the SOLE anti-fungibility enforcement point for EC-023 direction A (no step-5 backstop), SM-43 is
P0-adjacent and MUST be killed at the ≥95% require-review bar (killed by VP-HOOK-024's escaped-quote vector
1a; separately killable from SM-40/SM-42, which do not exercise the backslash-escape class). The P9-007
dedup-gate vector (VP-HOOK-029) is a test-only coverage assertion on the STEP-3 comment-review fallback
deny-reason text — NO mutant is warranted (architect §8.21 item 2; the loop-side dedup-HIT protection is
SM-27's target on VP-SKILL-068).**
**v1.13 (pass-10): SM-44 is the ADV-F2-P10-001 CRITICAL step1a-severity-renormalization sentinel — the O6
trust-basis correction (killed by VP-HOOK-030's per-family SEVERITY-MISMATCH under-report vectors); it lands
on the disposition-guard emitter authorization boundary (STEP 1a, before the hard floor), the same surface as
SM-31 (enum) and SM-21 (severity/confidence-conflation). SM-45 is the ADV-F2-P10-003 MAJOR
writemarker-review-path-allow-without-marker sentinel — the infra-failure silent-discard on the hard-floor
review path (killed by VP-HOOK-029's MARKER-WRITE-FAILED review-path vectors 13/14; separately killable from
SM-41, the STEP-3 null-binding branch, and SM-38, the STEP-4 under-label branch — three distinct fail-closed
branches of the same D-DEC-012 clause-2 invariant). Both are on the CRITICAL disposition-guard emitter surface
and MUST be killed at the ≥95% bar. (VP-SKILL-075's operator-boundary cron-exit-nonzero is guarded by a
behavioral BATS on the wrapper, not a code mutant — the wrapper Gate-2 grep is validated directly; its
Gate-1 `.permission_denials` leg is ASM-015-BLOCKED.)**
**v1.14 (pass-11): SM-46 is the ADV-F2-P11-002 MAJOR highseverity-floor-rekeyed sentinel — it lands on the
disposition-guard `hard_floor_applies()` high-severity floor (keyed on `verdict.scored_priority` field 18 per
P11-002); killed by VP-HOOK-026's detector-LOW/scored-CRIT vector. It is DISTINCT from SM-44 (STEP 1a
severity↔native consistency): the STEP 1a consistency check still passes under SM-46, but the FLOOR is re-keyed
to the wrong field → a CRIT-scored detector-LOW alert bypasses the §3.9 floor. SM-47 is the ADV-F2-P11-004 MAJOR
markdown-routed-into-verdict-emitter sentinel — it lands on the disposition-guard artifact-class router
(investigation-markdown emitter entry); killed by VP-HOOK-031's no-validate_enums-on-markdown / compliant-save
vectors. It is DISTINCT from SM-19/SM-34 (JSON↔markdown dispatch direction): SM-47 keeps JSON→verdict routing
correct but wrongly subjects the MARKDOWN class to the verdict emitter's enum/STEP-1a gates, denying a compliant
12-field investigation at save time. Both are on the CRITICAL disposition-guard emitter surface and MUST be killed
at the ≥95% bar.**
**v1.15 (pass-12): SM-48 is the ADV-F2-P12-001 CRITICAL ticket_id-charset-validation-removed sentinel and SM-49 the
ADV-F2-P12-007 jira_project_key-charset-validation-removed sentinel — both land on the disposition-guard
`command_pattern` construction surface (the O7 interpolation-safety gate, VP-HOOK-032); a removed charset check lets a
metacharacter-laden field broaden the anchored authorization regex (the SEC-009 class), so they land squarely on the
CRITICAL marker-authorization boundary and MUST be killed at the ≥95% require-review bar. SM-48/SM-49 are separately
killable (distinct fields, grammars, and interpolation sites). SM-50 is the ADV-F2-P12-002 CRITICAL
markdown-kill-switch-gate-removed sentinel and SM-51 the ADV-F2-P12-002 CRITICAL markdown non-FP-route-to-review-removed
sentinel — both land on the disposition-guard markdown (Human-Comment) path (VP-HOOK-031); under P13-001 (MARKDOWN_COMMENT_PATH
eliminated) their killer vectors shift (SM-50: a non-FP markdown under `autonomy=false` wrongly routed to review; SM-51:
a non-FP markdown wrongly getting allow-without-marker instead of review) — both remain on the CRITICAL emitter surface
and MUST be killed at the ≥95% bar. P12-003 (fast-path enum map + known-FP floor exemption) adds VP-HOOK-025/026 vectors
but NO mutant (architect §8.27 item 3 — the raw-CRITICAL/raw-MEDIUM validate_enums deny is the vectors' direct
consequence; the floor exemption is architectural policy).**
**v1.16 (pass-13): SM-52 is the ADV-F2-P13-001 CRITICAL markdown-fp-comment-marker-revert sentinel — reverting the
MARKDOWN_COMMENT_PATH elimination so an FP markdown issues an unfloored autonomous `["comment"]` marker (killed by
VP-HOOK-031's FP→allow-without-marker vector); SM-53 is the ADV-F2-P13-003 MAJOR markdown-disposition-full-document-substring-scan
sentinel — a defective parse that reads an embedded/negated `Disposition: FP` as FP → allow-without-marker instead of
review (killed by VP-HOOK-031's FP-in-code-fence / negated-FP parse-grammar vectors). Both land on the disposition-guard
markdown (Human-Comment) path (VP-HOOK-031); SM-52 (FP-branch outcome) and SM-53 (disposition parse) are separately
killable from each other and from SM-50/SM-51 (kill-switch gate / non-FP routing branch), so they MUST be killed at the
≥95% bar. P13-004 (historical-total annotation) and the PRISMDEMO sweep add no mutant.**
**v1.17 (pass-14): SM-54 is the ADV-F2-P14-002 MAJOR setup-time-charset-validation-removed sentinel — it lands on the
activate + onboard-customer SKILL setup-flow `jira_project_key` charset gate (VP-SKILL-076, the PREVENTIVE gate), NOT the
disposition-guard hook surface. Killed by VP-SKILL-076's reject-at-setup vector (a hyphenated `PRISM-DEMO` fed to activate /
onboard-customer must HALT with a user-facing error and write no partial state). It is DISTINCT from SM-49 (VP-HOOK-032, the
RUNTIME command_pattern jira_project_key charset gate): SM-54 is the setup-time preventive call-site (a config-entry gate on
the helper scripts), SM-49 the runtime command_pattern deny inside disposition-guard — the two together close the class
end-to-end. VP-SKILL-076/SM-54 sit on the activate/onboard-customer setup surface (module-criticality HIGH ≥90% target — the
setup helpers, sibling to VP-SKILL-051 prism-version-check.sh); the NVD sweep (P14-001 propagation) added no mutant.**
**v1.18 (VP-SKILL-076/077 disentanglement): NO new mutant — SM-55 SKIPPED, count stays 48 (SM-9..SM-54).** The v1.18
edit allocates VP-SKILL-077 (onboard-customer AD-017 credential-decline, P14-005) but warrants no paired mutant: it is a
B-STR structural-presence property on SKILL.md content, with no runtime accept/decline control-flow gate to remove —
exactly mirroring its sibling **VP-SKILL-054** (onboard-sensor AD-017), which likewise carries no SM-N mutant (the
structural-presence VPs VP-SKILL-054/055/057 all carry no mutant, since a SKILL.md prose edit is not an SM-N control-flow
mutation of a hook/helper gate). The suggested "onboard-customer accepts a credential in chat" mutation is not clearly
killable at the SM-N/spec level for this reason, so it is skipped rather than forced. VP-SKILL-077's coverage is asserted
by the B-STR grep vector directly (forbidden credential-paste-in-chat pattern absent + piped-stdin decline documented).
**v1.19 (pass-17): SM-56 is the ADV-F2-P17-001 / D-019 known-FP-floor-bypass-branch sentinel — it lands on the
disposition-guard `hard_floor_applies()` scored_priority high-severity floor (VP-HOOK-026), the same CRITICAL emitter
authorization boundary as SM-16 (floor-gate removal), SM-21 (severity/confidence-conflation), and SM-46 (floor re-key).
Killed by VP-HOOK-026's HIGH/CRIT-known-FP→comment-review vectors (b)/(c); the LOW/MED-known-FP→auto-close vector (a)
confirms no false-deny. It guards the D-019 posture that there is NO high-severity known-FP exemption — the floor fires
unconditionally on scored_priority ∈ {HIGH,CRIT} regardless of known-FP status, because disposition-guard has no
forgery-proof known-FP signal. P17-002 (VP-HOOK-028 property-(1) JSON-first rewrite) adds no mutant — the SM-34
dispatch-order sentinel already guards property (2)'s JSON-first precedence.**
With SM-9..SM-16 + SM-21..SM-22 + SM-28 + SM-29..SM-30 + **SM-31, SM-32a, SM-32b, SM-32-ext, SM-33..SM-54, SM-56** (SM-55 reserved-skipped)
KILLED, the marker/authorization path meets the **≥95% require-review** target (SM-31/32a/32b/32-ext/33/34/38/39/41/**44/45/46/47/48/49/50/51/52/53/56**
land squarely on the disposition-guard emitter authorization boundary — **SM-44 on STEP 1a consistency, SM-45 on WRITE_MARKER review-path fail-closed, SM-46 on the scored_priority high-severity floor, SM-47 on the investigation-markdown emitter-entry router, SM-48/SM-49 on the O7 command_pattern charset-validation gate, SM-50/SM-51/SM-52 on the markdown Human-Comment kill-switch/non-FP-routing/FP-branch path, SM-53 on the markdown disposition-parse grammar, SM-56 on the `hard_floor_applies()` known-FP-floor-bypass branch (D-019)**; SM-35/36/37/40/42/43 on the require-review
consumer + audit surface); **SM-54 lands on the activate/onboard-customer setup-flow charset gate (VP-SKILL-076, HIGH ≥90%);** SM-17..SM-20 + SM-23..SM-27 carry the disposition-guard JSON path, the
update-jira never-reopen guard (SM-26), and the monitoring-loop enforcement + dedup surface (SM-27) to
**≥90%**.

---

## 5. Test-Count Delta per BC (F3 story-sizing input)

Estimates are new **BATS test cases** (hooks.bats / skills.bats / integration.bats). Each new
`.sh`-backed behavior also requires a `.ps1` parity test (CONV-004); parity additions are
tracked separately and roughly mirror the hook/helper behavioral count.

| BC | VPs | New BATS (behavioral/structural/integration) | Parity (.ps1) add | Notes |
|----|-----|----------------------------------------------|--------------------|-------|
| BC-3.01.001 (v1.22; post-pass-14 final) | VP-HOOK-024 | 24 — valid-comment-allow, **create-scoped-allow**, **assign-scoped-allow**, replay-deny, expired(EC-017, `expires_at_utc` past), future-dated, wrong-scope(EC-018), consumed(EC-019), malformed(EC-020), path-traversal(EC-021), wrong-ticket(EC-022, SEC-123 marker→DENY SEC-456), **rename-fail→deny**, missing-marker-dir fail-closed, **iterative-consume: concurrent-same-scope→oldest-consumed-allow**, **iterative-consume: all-renames-fail→exhausted-deny**, **v1.5 create-injection: --summary-injected-`--project`→DENY (P4-002)**, **v1.5 prefix: `--project PROD` marker + `--project PRODUCTION`→DENY (P4-002)**, **v1.5 audit: `\n`-in-`ticket_id`→single MARKER_USED line (P4-010, SM-35 kill)**, **v1.9 STEP 6a anti-fungibility: create-review marker + create WITHOUT `--label`→DENY (EC-023, SM-36 kill)**, **v1.9 STEP 6a reverse: create marker + create WITH `--label REVIEW-REQUIRED`→DENY (EC-023, SM-37 kill)**, **v1.10/v1.11 STEP 6a structural false-deny prevention (QUOTED form): `["create"]` marker + regular create with `--label REVIEW-REQUIRED` literal INSIDE a double-quoted `--summary` value→ALLOW (quote-aware state-machine tokenizer, not raw substring and not `split_on_whitespace` — P7-005/P8-002; this SINGLE vector kills BOTH SM-40 [raw-substring revert] and SM-42 [split_on_whitespace revert], separately)** *(correct pairings — create-review+`--label`→ALLOW and create+no-label→ALLOW — are covered by the existing create-scoped-allow / valid-allow legs)*, **v1.12 STEP 6a escaped-quote differential-vs-bash partition (P9-001 MAJOR, O5): (1a SECURITY) `["create"]` marker + `--summary "a\"b" --label REVIEW-REQUIRED` (escaped-quote boundary before a REAL trailing label; bash applies a functional REVIEW-REQUIRED label)→has_review_label=TRUE→DENY (SM-43 kill); (1b false-deny) `["create"]` marker + `--summary "a\"b"` (escaped quote inside summary, NO real label)→has_review_label=FALSE→ALLOW; (partition-2 UNQUOTED) `--summary O\'Brien --label REVIEW-REQUIRED` (`\'`→literal apostrophe, no IN_SINGLE swallow)→has_review_label=TRUE→DENY** | ~17 | marker path is the SEC-009 regression surface; +3 (v1.5) create-pattern injection-safety (P4-002) + audit control-char (P4-010); +2 (v1.9) consumer STEP 6a anti-fungibility both directions (P6-001 CRITICAL); **+1 (v1.10) step-6a structural false-deny prevention (P7-005 MINOR, SM-40 kill); v1.11 UPDATES that same vector to the QUOTED form (P8-002 MAJOR, +SM-42; +0 net BATS — quoted-form kills SM-40 and SM-42). P8-003: step 6a is the SOLE anti-fungibility enforcement point for EC-023 direction A (bash regex not tail-anchored → no step-5 backstop) — the SM-36/37/40/42 family is P0-adjacent/non-redundant. v1.12: +3 BATS escaped-quote differential-vs-bash partition (P9-001 MAJOR, O5, SM-43 kill on 1a) — 21→24; equals-form scoped OUT (jr has no `--label=` form); the SM-36/37/40/42/43 step-6a family is P0-adjacent** |
| BC-3.03.001 (v1.26; post-pass-17 EC-005/L814 final: STEP 1a consistency + 18-field validate_enums + WRITE_MARKER fail-closed + separate human-comment marker path + O7 command_pattern charset-validation + MARKDOWN_COMMENT_PATH eliminated + strict parse grammar + PC#1 VP-HOOK-028 note 18-field (P16-003) + EC-005/L814 post-P13-001 consistency (P17-003)) | VP-HOOK-025, **VP-HOOK-028 (dispatch)**, **VP-HOOK-030 (STEP 1a consistency)**, **VP-HOOK-031 (human-comment path, four-guarantee v1.15)**, **VP-HOOK-032 (O7 command_pattern charset)** | 87 — **JSON-first dispatch: verdict-JSON class: 18** missing-field (one/field, incl. severity/asset_type/ticket_action_type/**native_severity/sensor_family/scored_priority**) + all-18-present-allow; **investigation-markdown class: 12** missing-field (one/field) + all-12-present-allow + **Severity-heading-inserted→still-allow (no wrong-class 18-field deny, SM-30 kill)**; tuning_signal{null-TP-valid, null-FP-invalid, absent-invalid, non-null-FP-valid}; dual-path-routing; **confidence-float→deny + confidence∈{high,medium,low}→allow (4, D-DEC-011)**; **v1.5 validate_enums membership: severity="High"→DENY, severity="CRITICAL"→allow, asset_type="Unknown"→DENY, disposition="indeterminate"→DENY, sensor_health="Degraded"→DENY, ticket_action_type="NONE"→DENY (6, P4-006, SM-31 kill)**; **v1.13 fields-16/17 presence+enum: native_severity absent→DENY, native_severity=""→DENY, sensor_family="unknown_vendor"→DENY (3, P10-001, VP-HOOK-025/030)**; **v1.14 field-18 presence+enum: scored_priority absent→DENY, scored_priority="CRITICAL"(wrong enum)→DENY, scored_priority="MEDIUM"(wrong enum)→DENY (3, P11-002, VP-HOOK-025)**; **STEP 1a SEVERITY-MISMATCH consistency check (VP-HOOK-030, P10-001; DOWNGRADED consistency-only v1.14/P11-001, SM-44 kill): crowdstrike 90+LOW→DENY, armis Critical+MEDIUM→DENY, claroty High+LOW→DENY, cyberint any+LOW→DENY, agreement crowdstrike 90+CRITICAL→proceed (5 — the pass-10 CVSS-float vector REMOVED per P11-003 clean separation: CVSS→scored_priority, NOT native_severity)**; **v1.14 separate human-comment marker path (VP-HOOK-031, P11-004, SM-47 kill): compliant 12-field investigation→comment marker + NOT denied=1, Indeterminate/T1003/degraded-sensor markdown→MARKDOWN-HARD-FLOOR deny=3, 12-field markdown NOT subjected to validate_enums/STEP-1a (no false deny on absent verdict-only fields incl. scored_priority)=1 (5)**; **v1.15 VP-HOOK-032 O7 command_pattern charset (P12-001, SM-48/SM-49 kill): TICKET-ID-CHARSET-DENY — ticket_id=".*" (comment)→DENY, ticket_id="SEC-1 \|.*#" (comment)→DENY, ticket_id=".*" (assign)→DENY, ticket_id=".*" (comment-review)→DENY, ticket_id=".*" (markdown path)→DENY =5; valid ticket_id="SEC-123"→anchored-pass, ticket_id="ABC-9999"→pass =2; PROJECT-KEY-CHARSET-DENY — jira_project_key="X( \|$)\|.*" (create)→DENY, jira_project_key=".*" (create-review)→DENY =2; valid jira_project_key="PRISM"→pass =1 (10)**; **v1.16 VP-HOOK-031 P13-001 rewrite — MARKDOWN_COMMENT_PATH ELIMINATED (SM-50/SM-51/SM-52 kill): G1 kill-switch — FP+autonomy=false→allow-without-marker=1, FP+autonomy absent→allow-without-marker=1, TP+autonomy=false→allow-without-marker (kill switch short-circuits before routing, SM-50 kill)=1, FP+autonomy=true→allow-without-marker (NO comment marker, SM-52 kill)=1; G3 disposition routing — TP markdown→review marker (NOT comment/allow, SM-51 kill)=1, BTP markdown→review marker=1, masquerade: loop investigation-TP with HIGH indicators→review, no autonomous comment=1, PARSE_FAIL 'probably FP'→review=1 (8; the v1.15 'autonomy=true+FP→comment marker' vector is RETIRED — reason 'MARKDOWN_COMMENT_PATH eliminated ADV-F2-P13-001', history preserved)**; **v1.16 VP-HOOK-031 strict parse grammar (P13-003, SM-53 kill): negated-FP 'not a false positive'→PARSE_FAIL→review=1, 'not FP — TP'→review=1, Disposition:FP in code fence (no canonical heading)→PARSE_FAIL→review (SM-53 kill)=1, multi-valued 'FP or BTP'→review=1, empty Disposition heading→review=1, canonical 'FP'→allow-without-marker=1, long-form 'False Positive'→allow-without-marker=1, autonomy_enabled:true in code fence→gate closed→allow-without-marker=1, autonomy token in evidence block→gate closed=1, dedicated 'Autonomy Enabled: true'→gate opens=1 (10)**; **v1.15 VP-HOOK-025 fast-path enum-map (P12-003a, no mutant): native 90→scored_priority=CRIT (mapped, passes validate_enums)=1, native 30→MED=1, native 70→HIGH=1, native 10→LOW=1, raw unmapped scored_priority="CRITICAL"→DENY=1, raw unmapped "MEDIUM"→DENY=1, mapped CRIT→validate_enums pass=1 (7)** | ~40 | disposition-guard artifact-class branching + JSON-first dispatch; +6 over v1.3 for validate_enums (ADV-F2-P4-006); **+9 v1.13 (P10-001): fields-16/17 presence (3) + STEP 1a SEVERITY-MISMATCH under-report/agreement (6) — VP-HOOK-030 / SM-44**; **+7 v1.14: field-18 presence (3, P11-002) + separate human-comment marker path (5, P11-004, VP-HOOK-031/SM-47); STEP 1a re-scoped consistency-only (P11-001) with the CVSS vector removed (P11-003) — net STEP-1a 6→5 (−1)**; **+23 v1.15: VP-HOOK-032 O7 command_pattern charset (+10, P12-001, SM-48/SM-49) + VP-HOOK-031 four-guarantee kill-switch/disposition-routing/masquerade (+6, P12-002, SM-50/SM-51) + VP-HOOK-025 fast-path SEVERITY_TO_SCORED_PRIORITY_MAP enum-map (+7, P12-003a, no mutant) — 49→72**; **+15 v1.16: VP-HOOK-031 P13-001 MARKDOWN_COMMENT_PATH elimination rewrite (+~5 net after retiring the FP→comment vector, SM-50/SM-51/SM-52) + P13-003 strict parse-grammar adversarial vectors (+10, SM-53) — 72→87**; **+0 v1.26: EC-005/L814 post-P13-001 consistency correction (P17-003 MAJOR, PO-owned) — no new test vectors; BATS count unchanged at 87** |
| **BC-4.02.001 (v1.12)** *(NEW v1.2)* | VP-SKILL-066, VP-SKILL-067 | 9 — never-reopen{Resolved→propose-only-no-move (EC-007), Closed→create-new+link-no-move (EC-008), static no-autonomous-move grep}=3, SLA-surface{append-comment-has-stmt, link-has-stmt, propose-reopen-has-stmt, SLA-unknown-when-unretrievable, static format grep}=5, valid-marker-comment-allow happy path=1 | ~4 | update-jira path (distinct from monitoring-loop VP-SKILL-062); Inv#4 + Inv#5 |
| **BC-4.05.001 (v1.4)** *(NEW v1.3)* | VP-SKILL-070, VP-SKILL-071 | 10 — org_slug{PC#5a/5b/5d static WHERE-clause=3, DTU org-a-returns-zero-org-b/c=1, unscoped-query rejected=1}=5 (VP-SKILL-070), confidence-float→enum boundary{0.75→high, 0.749→medium, 0.40→medium, 0.399→low, inconsistent-pair-invalid}=5 (VP-SKILL-071) | ~2 | assess-priority PrismQL scoping + D-DEC-011 threshold boundaries (ADV-F2-P3-004/P3-008) |
| **BC-5.01.001 (v1.12)** *(NEW v1.3)* | VP-SKILL-069 | 4 — org_slug{static Iron-Law WHERE-clause on Stage-3 OCSF + temporal-adjacency blocks=2, DTU org-a-returns-zero-org-b/c=1, unscoped-query rejected=1} | ~1 | investigate-event PrismQL scoping (ADV-F2-P3-004); mostly static SKILL.md content assertion |
| BC-6.01.001 | VP-SKILL-051, **076** *(NEW v1.17)* | 8 — version below/at/above, dual-write settings.json + prism.mcp.json, RUST_LOG=off both, jr-auth blocking, malformed-settings stop, idempotent merge (EC-008..012); **v1.17 VP-SKILL-076 setup-time jira_project_key charset (P14-002, SM-54 kill): PRISM-DEMO (hyphen)→HALT+no-partial-state=1, PRISMDEMO→accept=1, lowercase/leading-digit/empty→reject=1 (PC#12/EC-014)=3** | ~6 | prism-version-check.sh + activate-mcp-config.sh; **v1.17 setup-time charset gate (VP-SKILL-076, +3)** |
| BC-6.01.003 | VP-SKILL-052, 053, **076** *(NEW v1.17)*, **077** *(NEW v1.18)* | 6 — UUID-v7 reject, idempotent dir, org_slug dedup + 3 EC; **v1.17 VP-SKILL-076 setup-time jira_project_key charset (P14-002, SM-54 kill): onboard-customer PRISM-DEMO→HALT+no-partial-state=1, PRISMDEMO→accept=1 (Inv#6/EC-010)=2**; **v1.18 VP-SKILL-077 onboard-customer AD-017 credential-decline (P14-005, B-STR, NO mutant): forbidden credential-paste-in-chat pattern ABSENT in SKILL.md/helper=1, piped-stdin `echo \| prism credential set` decline path documented=1 (Inv#1/EC-008)=2** | ~2 | credential helper parity minimal; **v1.17 setup-time charset gate (VP-SKILL-076, +2)**; **v1.18 AD-017 credential-decline structural greps (VP-SKILL-077, +2; structural SKILL.md content — no .ps1 parity)** |
| BC-6.01.004 | VP-SKILL-054, 055 | 6 — AD-017 no-paste, SELECT 1 present+gated, prism_describe-verify, cred-decline + EC | ~3 | credential-set.sh parity |
| BC-8.02.001 | VP-SKILL-056, 057 | 5 — 5-field completeness, naming/no-alias, >24h silence warning + EC | 0 | structural + prism-DTU |
| BC-9.01.001 | VP-SKILL-058, **059 (UPGRADED v1.13)** | 7 — describe-first, org_slug scoping (structural), zero-findings message, no-tables skip + EC; **v1.13 VP-SKILL-059 behavioral upgrade (P10-005): prism-DTU multi-org org-a-hunt-returns-zero-org-b/c=1, static assert every query in data/threat-hunt-queries.md carries org_slug=1** | 0 | structural + **prism-DTU behavioral (v1.13) + static hunt-query-library parse** |
| BC-10.01.001 (v1.20; post-pass-17 final) | VP-HOOK-026, VP-HOOK-027, VP-HOOK-028, **VP-HOOK-029**, VP-SKILL-050, **072**, **073**, **074**, **075**, 060, 061, 062, 063, **064**, **065**, **068** | 97 — hard-floor{Indeterminate, **scored_priority=HIGH (field 18, P11-002 — NOT recomputed severity)**, critical-asset, **unknown-asset+LOW+benign (1, VP-HOOK-026, ADV-F2-P3-001)**, T1003, degraded-sensor}=6, **v1.14 scored_priority floor (VP-HOOK-026, P11-002, SM-46 kill){scored_priority=HIGH+regular→floor fires (no regular marker)=1, scored_priority=CRIT+regular→floor fires=1, DETECTOR-LOW/SCORED-CRIT: severity=LOW+consistent native_severity+scored_priority=CRIT→floor STILL fires (SM-46 kill)=1, scored_priority=LOW+other floors pass→floor FALSE control=1}=4**, **v1.5 review-surfacing (hard_floor_applies()=TRUE positive controls){Indeterminate+create-review→marker=1, silent+comment-review→marker=1, HIGH+create-review→marker=1, authorized_operations=['create-review']=1 (VP-HOOK-026, D-DEC-012)}=4**, **v1.8 over-label gate (hard_floor_applies()=FALSE){non-hard-floor-TP+create-review→no-marker=1, non-hard-floor-FP+comment-review+autonomy=false→no-marker=1, LOW-standard+create-review→no-marker=1 (VP-HOOK-026, ADV-F2-P5-002, SM-32b kill)}=3**, **v1.5 kill-switch-determinism (STEP 5 post-reorder){autonomy=false+create→no-marker=1, +comment→no-marker=1, autonomy-absent→false→no-marker=1, autonomy=false+create-review→marker-still (exempt)=1 (VP-HOOK-026, P4-005, SM-33 kill)}=4**, **v1.10 fail-loud under-label DENY-THE-WRITE (STEP 4 deny; RETIRES the v1.9 marker-upgrade vectors — mechanism removed ADV-F2-P7-001){Indeterminate+create→verdict-Write-DENIED+UNDER-LABEL-DENIED-audit=1, HIGH+none→DENIED+audit=1, degraded-sensor+assign→DENIED+audit=1, machine-actionable-reason (required_token/hard_floor_trigger/label_instruction parse)=1, corrected-rewrite→STEP-3-review-marker happy path=1, consumer-boundary: create-review marker+correctly-labeled jr→ALLOW (authorized/consumable)=1, consumer-boundary: create-review marker+no-`--label` jr→DENY (unconsumable marker prevented — O4 seam guard)=1, kill-switch-irrelevance: deny fires with autonomy_enabled true AND false=1 (VP-HOOK-029, ADV-F2-P7-001/P7-004, SM-38/SM-39/SM-32a/SM-32-ext kill)}=8**, **v1.11 STEP-3 unbindable-deny (HARD-FLOOR-UNBINDABLE; ADV-F2-P8-001 CRITICAL; additive to the deny-path set){create-review + null/empty jira_project_key → verdict Write DENIED + HARD-FLOOR-UNBINDABLE audit (missing_field=jira_project_key), NEVER silent allow-without-marker=1, comment-review + null ticket_id + jira_project_key present → DENIED + create-review fallback hint=1, comment-review + BOTH bindings null → DENIED naming both=1 (VP-HOOK-029 vectors 9–11, SM-41 kill)}=3**, **v1.12 STEP-3 dedup-before-fallback (ADV-F2-P9-007 MINOR; test-only, NO mutant){comment-review + null ticket_id + jira_project_key present → deny reason's create-review fallback hint carries the §3.4 dedup-re-run instruction (dedup HIT ⇒ comment on existing ticket, NEVER a duplicate create-review, D-DEC-004)=1 (VP-HOOK-029 vector 12)}=1**, **VP-HOOK-028 property (1) — JSON-first fail-closed residual boundary (REWRITTEN v1.20, P17-002; the dead 'non-`verdict`-substring path→no-marker→jr-deny' vector is RETIRED — false under JSON-first — history preserved){genuinely-non-dispatching path `artifacts/notes/alert-001.txt` (no .json ext, non-JSON content, non-`*investigation-*.md`)→fast-path-allow→marker EMPTY→Stage-8 jr-deny=1, `.json` path WITHOUT `verdict` substring + valid 18-field JSON `artifacts/findings/alert-001.json`→JSON-first dispatch FIRES→ICD-203 validation→marker emitted (NOT fast-path-allow)=1, non-.json path with JSON content→dispatch FIRES=1}=3**, verdict-path→marker→jr-allow control=1 (VP-HOOK-028)=1, **v1.5 canonical-dispatch (property (2)){investigations/verdict-*.json→18-field→marker (JSON-first)=1, investigation-*.md→12-field=1 (VP-HOOK-028, P4-001, SM-34 kill)}=2**, watermark{monotonic,future-reject}=2, **v1.5 first-run{no-watermark→24h-lookback-query=1, post-run-persist=1, existing-watermark→no-lookback control=1 (VP-SKILL-072, P4-012)}=3**, **v1.9 late-event{_time<watermark−GRACE→LATE_EVENT_DETECTED-audit+still-processed=1, in-window→no-detection control=1, first-run→no-false-positive=1 (VP-SKILL-073, P6-007)}=3**, **v1.9 severity-normalization{CrowdStrike 25→LOW/26→MEDIUM/76→CRITICAL=3, Armis Critical→CRITICAL+Informational→LOW case-fold=1, unrecognized→CRITICAL+uncertainty_explicit (auditable, not deny)=1 (VP-SKILL-074, P6-005, D-DEC-013; **v1.17 P14-001 NVD sweep: the CVSS 3.9→LOW/9.0→CRITICAL boundary fixtures REMOVED — NVD/CVSS is NOT a NORMALIZE_SEVERITY family, CVSS feeds scored_priority at Stage 5; −2 BATS**)}=5**, **v1.10 Cyberint partition{any-Cyberint-native→CRITICAL (pre-ASM-008 default)=1, Cyberint-never-LOW/MEDIUM/HIGH-pre-ASM-008=1, Cyberint-CRITICAL-carries-uncertainty_explicit=1 (VP-SKILL-074, P7-006, D-DEC-013; update when ASM-008 resolves)}=3**, known-FP-before-enrich=2, **hard-floor-before-known-FP-autoclose (EC-009)=1**, ~~**v1.15 known-FP floor EXEMPTION (P12-003b)**~~ **RETIRED v1.20 (P17-001 / D-019 — the 2 exemption vectors are dead/incorrect; history preserved)**, **v1.20 D-019 known-FP floor vectors (VP-HOOK-026, P17-001, SM-56 kill){(a) LOW-native known-FP (scored_priority=LOW) + healthy sensor + non-forbidden technique + disposition=FP→hard_floor_applies()=FALSE→auto-close (comment via regular path)=1, (b) MED-native known-FP (scored_priority=MED) + same→auto-close=1, (c) HIGH-native known-FP (scored_priority=HIGH) + store match + disposition=FP→hard_floor_applies()=TRUE→DENY-THE-WRITE (HARD-FLOOR-UNDER-LABEL)→comment-review, NOT auto-close (SM-56 kill)=1, (d) CRIT-native known-FP (scored_priority=CRIT) + store match + disposition=FP→hard_floor_applies()=TRUE→DENY→comment-review (SM-56 kill)=1}=4**, BLIND-SPOT positive=2, never-reopen-closed=2, Tavily-degrade=2, `--bare`-absent wrapper assertion=1, allowlist-matches-SKILL=1, cross-hook ASM-009 integration=2, **org_slug{cross-tenant-org-a≠b/c=2, static query-construction check=1, unscoped RAW-TABLE query adversarial=1}=4 (VP-SKILL-064)**, **v1.13 D-DEC-005 carve-out (VP-SKILL-064, P10-006/P10-007){allows unscoped lone-table prism_sensor_health=1, rejects prism_sensor_health JOIN raw-table w/o org_slug=1}=2**, **kill-switch (RE-SCOPED v1.9, Option A carve-out){zero-REGULAR-markers=1, zero-REGULAR-jr-writes=1, evidence+draft-still-allowed=1, silent-sensor→create-review-jr-write-STILL-executes (exempt)=1}=4 (VP-SKILL-065)**, **stage-order{document-before-action positive=1, jr-before-Write→deny=1, TTL-expiry→deny=1}=3 (VP-HOOK-027)**, **grace-window-dedup{in-grace+existing-open-ticket→comment=1, in-grace+no-ticket→create=1, _time-normalize+boundary=1, dedup-off→double-ticket mutant kill=1}=4 (VP-SKILL-068)**, **v1.13 marker-write fail-closed (VP-HOOK-029, P10-003, SM-45 kill){create-review+write-fail→MARKER-WRITE-FAILED deny=1, comment-review+write-fail→deny=1, regular comment+write-fail→allow-without-marker control=1}=3**, **v1.13 operator-boundary cron-exit (VP-SKILL-075, P10-002){audit.log HARD-FLOOR-LIVELOCK-ABORT→wrapper exit 1=1, audit.log SEVERITY-MISMATCH→exit 1=1, clean run→exit 0=1; Gate-1 .permission_denials leg ASM-015-BLOCKED (not counted)}=3** | ~26 | monitoring-loop CRITICAL; **v1.10: VP-HOOK-029 fail-loud block re-scoped to DENY-THE-WRITE / consumer-boundary (9 upgrade-era vectors → 8 deny-era vectors, net −1; the 3 v1.9 marker-upgrade vectors RETIRED per ADV-F2-P7-001) + VP-SKILL-074 Cyberint partition (+3, P7-006) → net +2 on this BC**; **v1.11: VP-HOOK-029 STEP-3 unbindable-deny +3 (P8-001 CRITICAL, SM-41 kill) → 77→80**; **v1.12: VP-HOOK-029 STEP-3 dedup-before-fallback +1 (P9-007 MINOR, test-only, no mutant) → 80→81**; **v1.13: VP-SKILL-064 D-DEC-005 carve-out +2 (P10-006/P10-007) + VP-HOOK-029 marker-write fail-closed +3 (P10-003, SM-45) + VP-SKILL-075 operator-boundary cron-exit +3 (P10-002; Gate-1 ASM-015-BLOCKED leg not counted) → 81→89**; **v1.14: VP-HOOK-026 scored_priority HIGH/CRIT floor +4 (P11-002, incl. detector-LOW/scored-CRIT, SM-46 kill) → 89→93**; **v1.15: VP-HOOK-026 known-FP floor exemption +2 (P12-003b, architectural policy, no mutant) → 93→95 (the fast-path SEVERITY_TO_SCORED_PRIORITY_MAP enum-map is verified on BC-3.03.001 via VP-HOOK-025; the loop-side map-before-write obligation is a BC-10.01.001 field-18 fast-path source note, §8.26.2 item 1)**; **v1.17: NVD sweep (P14-001) removes the 2 VP-SKILL-074 CVSS-boundary fixtures (NVD/CVSS is NOT a NORMALIZE_SEVERITY family; CVSS→scored_priority at Stage 5) → 95→93**; **v1.20 (P17-001/P17-002): VP-HOOK-026 known-FP floor EXEMPTION RETIRED/INVERTED — the 2 v1.15 exemption vectors replaced by 4 D-019 vectors (LOW/MED auto-close + HIGH/CRIT floor-fires→comment-review, SM-56 kill), net +2; VP-HOOK-028 property-(1) JSON-first rewrite — the dead non-`verdict`-substring reachability vector retired, replaced by 3 (non-dispatching-path fast-path-allow + 2 JSON-first-dispatch-fires positives), net +2 → 93→97** | (row header count updated 93 → 97) |

**Estimated new BATS test cases: ~267** (hooks/skills/integration; was ~263 at v1.18, ~261 at v1.17, ~258 at v1.16) + **~104 parity (.ps1)**
additions ≈ **~371 new test cases** for the cycle (was ~367). The **v1.20 pass-17 remediation** is a net **+4 BATS**, all on **BC-10.01.001**:
**+2** for the P17-001 / D-019 known-FP floor RETIRE/INVERT (VP-HOOK-026 — 4 D-019 vectors [LOW/MED-native known-FP→auto-close;
HIGH/CRIT-native known-FP→hard_floor_applies() FIRES→comment-review, SM-56 kill] replace the 2 retired v1.15 exemption
vectors) and **+2** for the P17-002 VP-HOOK-028 property-(1) JSON-first rewrite (the dead non-`verdict`-substring reachability
vector retired; 3 added — genuinely-non-dispatching-path fast-path-allow→Stage-8-deny + `.json`-without-`verdict`-substring
JSON-first-dispatch-fires positive + non-`.json`-with-JSON-content dispatch-fires positive). No parity add beyond the mirrored
hook behaviors (the D-019 floor branch and the JSON-first dispatch already have `.ps1` siblings; the retired/added vectors net
to the same parity surface). The one new v1.20 mutant — **SM-56** (known-FP-floor-bypass-branch-added, ADV-F2-P17-001 / D-019,
VP-HOOK-026) — lands on the CRITICAL disposition-guard `hard_floor_applies()` high-severity floor (≥95%); P17-002 adds no
mutant (SM-34 already guards property (2)'s JSON-first precedence). The prior **v1.18 VP-SKILL-076/077 disentanglement** is a net **+2 BATS**,
both on **BC-6.01.003** (VP-SKILL-077 onboard-customer AD-017 credential-decline — forbidden credential-paste-in-chat pattern
absent + piped-stdin decline documented, P14-005); no parity add (structural SKILL.md content, no `.ps1` behavior); NO new
mutant (SM-55 skipped, B-STR per the VP-SKILL-054 precedent). The prior **v1.17 pass-14 remediation** was a net **+3 BATS**:
**+5 on BC-6.01.001/BC-6.01.003** (VP-SKILL-076 setup-time jira_project_key charset validation — reject `PRISM-DEMO`/no-partial-state + accept `PRISMDEMO` on activate (3) and onboard-customer (2), P14-002, SM-54) minus **−2 on BC-10.01.001** (the P14-001 NVD sweep removes the VP-SKILL-074 CVSS-boundary fixtures — NVD/CVSS is not a NORMALIZE_SEVERITY family). Plus **~2 parity** (the setup-time reject/accept branches each need `.ps1` siblings per CONV-004). The one new v1.17 mutant — **SM-54** (setup-time-charset-validation-removed, MAJOR, VP-SKILL-076) — lands on the activate/onboard-customer setup-flow charset gate (HIGH ≥90%). P14-005 at v1.17 (the VP-SKILL-053/057 repurposing annotation) added no test; the v1.18 disentanglement now allocates VP-SKILL-077 for the P14-005 AD-017 credential-decline coverage (+2 BATS on BC-6.01.003, see above). The prior **v1.16 pass-13 remediation** was a net **+15 BATS**,
all on BC-3.03.001: **VP-HOOK-031 P13-001 MARKDOWN_COMMENT_PATH elimination rewrite** (guarantee (c) rewritten — no
autonomous comment marker for any disposition; FP→allow-without-marker, non-FP/PARSE_FAIL→review; the v1.15 FP→comment
vector RETIRED; net +~5 after re-casting the kill-switch/routing vectors; SM-50/SM-51 killer vectors shifted, +SM-52) and
**the P13-003 strict parse-grammar adversarial vectors** (+10: negated-FP prose→review, Disposition:FP-in-code-fence→review
[SM-53], multi-valued/empty→review, canonical-FP/long-form→allow-without-marker positive controls, autonomy_enabled-in-code-fence/evidence→gate-closed,
dedicated-field-true→gate-open). Plus **~3 parity** (the FP→allow-without-marker, review-routing, and parse-grammar branches
each need `.ps1` siblings per CONV-004). The two new v1.16 mutants — **SM-52** (markdown-fp-comment-marker-revert, CRITICAL,
VP-HOOK-031) and **SM-53** (markdown-disposition-full-document-substring-scan, MAJOR, VP-HOOK-031) — both land on the
CRITICAL disposition-guard markdown Human-Comment path; SM-50/SM-51 remain valid (killer vectors shifted under P13-001).
P13-004 (historical-total annotation) and the PRISMDEMO sweep add no test. The prior **v1.15 pass-12 remediation** was a net
**+25 BATS**: **+23 on BC-3.03.001** (VP-HOOK-032 O7 command_pattern charset-validation +10 — P12-001, SM-48/SM-49:
5 TICKET-ID-CHARSET-DENY across comment/assign/comment-review/markdown + 2 valid ticket_id + 2 PROJECT-KEY-CHARSET-DENY
across create/create-review + 1 valid project-key; VP-HOOK-031 four-guarantee redesign +6 — P12-002, SM-50/SM-51:
kill-switch (autonomy=false/absent/true) + disposition routing (TP→review, BTP→review) + masquerade; VP-HOOK-025
fast-path SEVERITY_TO_SCORED_PRIORITY_MAP enum-map +7 — P12-003a, no mutant) and **+2 on BC-10.01.001** (VP-HOOK-026
known-FP floor exemption — P12-003b, architectural policy, no mutant). Plus **~6 parity** (the O7 charset-validation,
markdown-path kill-switch/routing, and fast-path enum-map branches each need `.ps1` siblings per CONV-004). The four
new v1.15 mutants — **SM-48** (ticket_id-charset-validation-removed, CRITICAL, VP-HOOK-032), **SM-49**
(jira_project_key-charset-validation-removed, VP-HOOK-032), **SM-50** (markdown-kill-switch-gate-removed, CRITICAL,
VP-HOOK-031), **SM-51** (markdown-disposition-route-to-review-removed, CRITICAL, VP-HOOK-031) — all land on the
CRITICAL disposition-guard emitter authorization boundary (the O7 command_pattern charset gate + the markdown
Human-Comment path). **P12-001 (O7): VP-HOOK-032 is the O7 compliance artifact — every command_pattern interpolation
site (5) charset-validates + regex-escapes; org_slug is audit-only/SAFE. P12-002: VP-HOOK-031 now covers all four
guarantees of the redesigned markdown path (kill switch / disposition routing / FP comment / ticket_id charset).**
The prior **v1.14 pass-11 remediation** was a net
**+11 BATS**: **+7 on BC-3.03.001** (VP-HOOK-025 field-18 `scored_priority` presence/enum +3 — P11-002; VP-HOOK-031
separate human-comment marker path +5 — P11-004, SM-47; STEP 1a re-scoped consistency-only and the CVSS-float vector
removed — P11-001/P11-003, net −1 STEP-1a) and **+4 on BC-10.01.001** (VP-HOOK-026 scored_priority HIGH/CRIT floor +4 —
P11-002, incl. the detector-LOW/scored-CRIT escalation vector that kills SM-46). Plus **~3 parity** (the scored_priority
floor, field-18 validation, and separate human-comment marker-path branches each need `.ps1` siblings per CONV-004).
The two new v1.14 mutants — **SM-46** (highseverity-floor-rekeyed-to-recomputed-severity, MAJOR, VP-HOOK-026) and
**SM-47** (markdown-routed-into-verdict-emitter, MAJOR, VP-HOOK-031) — both land on the CRITICAL disposition-guard
emitter authorization boundary (the scored_priority hard floor + the artifact-class router). **P11-001 (O6 residual):
VP-HOOK-030 is DOWNGRADED to a consistency VP — STEP 1a proves severity↔native_severity consistency, NOT ground-truth;
the "un-bypassable" claim is withdrawn (native_severity/sensor_family are LLM-supplied; ASM-008-DEFERRED, symmetric with
asset_type). The high-severity floor is moved to scored_priority (P11-002), same ASM-008-class residual.** The prior
**v1.13 pass-10 remediation** was a net
**+19 BATS**: **+9 on BC-3.03.001** (VP-HOOK-025 fields-16/17 presence +3 + VP-HOOK-030 STEP 1a SEVERITY-MISMATCH
under-report/agreement +6 — P10-001, SM-44), **+8 on BC-10.01.001** (VP-SKILL-064 D-DEC-005 carve-out +2 —
P10-006/P10-007; VP-HOOK-029 marker-write fail-closed +3 — P10-003, SM-45; VP-SKILL-075 operator-boundary
cron-exit +3 — P10-002, with the Gate-1 `.permission_denials` leg ASM-015-BLOCKED and NOT counted), and
**+2 on BC-9.01.001** (VP-SKILL-059 structural→behavioral upgrade — P10-005: prism-DTU multi-org + static
hunt-query-library org_slug parse). Plus **~6 parity** (the STEP 1a SEVERITY-MISMATCH, WRITE_MARKER
review-path fail-closed, and cron-wrapper Gate-2 branches each need `.ps1` siblings per CONV-004; the
cron wrapper is bash-only so its parity is minimal). The two new v1.13 mutants — **SM-44**
(step1a-severity-renormalization-reverted, CRITICAL, VP-HOOK-030) and **SM-45** (writemarker-review-path-
allow-without-marker-reverted, MAJOR, VP-HOOK-029) — both land on the CRITICAL disposition-guard authorization
boundary (STEP 1a re-normalization + WRITE_MARKER review-path fail-closed), so they join the near-exhaustive
input-partition BATS on the marker path. **P10-001 (O6): VP-HOOK-030 is the O6 compliance artifact — the
hard floor now keys on the hook-recomputed severity, un-bypassable for the severity dimension.** The prior **v1.12 pass-9 remediation** was a net
**+4 BATS**: **+3 on BC-3.01.001** (VP-HOOK-024 escaped-quote differential-vs-bash partition — P9-001 MAJOR,
O5: 1a escaped-quote-boundary-hides-real-label→DENY (SM-43 kill); 1b escaped-quote-in-summary-no-label→ALLOW;
partition-2 UNQUOTED `\'`→literal-apostrophe→DENY on the trailing real label) and **+1 on BC-10.01.001**
(VP-HOOK-029 STEP-3 dedup-before-fallback test-only vector — P9-007 MINOR, no mutant). Plus **~1 parity** (the
SM-43 IN_DOUBLE backslash-escape tokenizer branch needs a `.ps1` sibling per CONV-004). The single new v1.12
mutant (**SM-43** step6a-in_double-backslash-escape-reverted) lands on the CRITICAL require-review step-6a
anti-fungibility surface (the SOLE EC-023 direction-A gate post-P8-003), so it joins the near-exhaustive
input-partition BATS on the marker path. **P9-001/P9-009 (O5): VP-HOOK-024 is now the O5 compliance artifact —
its differential-vs-bash partition covers single/double (P8-002), unquoted, and backslash-escape (P9-001)
classes; equals-form is scoped OUT (jr has no `--label=` form). The step-6a mutant family is now
SM-36/37/40/42/43, all P0-adjacent.** The prior **v1.11 pass-8 remediation** was a
net **+3 BATS**, all on **BC-10.01.001** (VP-HOOK-029 STEP-3 unbindable-deny vectors 9–11 — P8-001 CRITICAL,
SM-41 kill: create-review + null jira_project_key → HARD-FLOOR-UNBINDABLE deny; comment-review + null
ticket_id + fallback hint; comment-review + both null). **BC-3.01.001 is +0 BATS** — the P8-002 fix UPDATES
the existing v1.10 step-6a false-deny vector to the QUOTED form (that single vector now kills BOTH SM-40 and
SM-42), it does NOT add a new test. Plus **~1 parity** (the STEP-3 `HARD-FLOOR-UNBINDABLE` deny branch needs
a `.ps1` sibling per CONV-004). The v1.11 mutants (**SM-41** step3-create-review-unbindable-allow, **SM-42**
structural_label_check-non-quote-aware) both land on the CRITICAL disposition-guard/require-review
authorization path (the STEP-3 fail-loud deny + step-6a anti-fungibility), so these remain near-exhaustive
input-partition BATS on the marker path. **P8-003 raises the stakes on the step-6a family: with no step-5
tail-anchor backstop, step 6a is the SOLE anti-fungibility enforcement point (EC-023 direction A), so the
SM-36/37/40/42 mutant family is P0-adjacent/non-redundant and MUST be killed.**
The prior **v1.10 pass-7 remediation** was a net **+3 BATS**: +1 BC-3.01.001 (step-6a structural false-deny —
P7-005, SM-40) and +2 BC-10.01.001 (VP-HOOK-029 DENY-THE-WRITE re-scope net −1 [three v1.9 marker-upgrade
vectors RETIRED] + VP-SKILL-074 Cyberint partition +3). The prior v1.9 pass-6 remediation added +16 BATS
(+2 BC-3.01.001 consumer STEP 6a anti-fungibility, +14 BC-10.01.001). This is consistent with the
CRITICAL/HIGH rigor bar in module-criticality.md (near-exhaustive input-partition BATS on the marker
path). F3 should size Wave-3 (marker mechanism), Wave-7 (monitoring-loop), the update-jira story, and
the investigate-event / assess-priority stories to absorb the BC-3.01.001 + BC-3.03.001 +
BC-10.01.001 + BC-4.02.001 + BC-4.05.001 + BC-5.01.001 test load (~115 of the ~155 new cases
concentrate on the hook/marker + org_slug surfaces — the pass-4 additions are almost entirely on the
disposition-guard emitter + require-review marker path).

---

## 6. Verification Strategy Notes (cross-cutting)

- **jr-mock** backs all VP-SKILL-060/061/062 and the ASM-009 integration tests (ticket
  create/comment/list JQL responses) so tests never touch a live Jira; **prism-DTU-demo-server**
  (`--config-dir <tmpdir>` mandatory per architecture-delta §Testing-Architecture) backs
  VP-SKILL-050/056/061 sensor/row/health fixtures.
- Every prism-invoking test MUST call the mandated `assert_prism_config_dir_set` helper and
  set `PRISM_CONFIG_DIR=$(mktemp -d)` in `setup()` to avoid corrupting the developer's real
  prism config.
- VP-HOOK-024/026 and the ASM-009 test share the `CLAUDE_PLUGIN_DATA=$(mktemp -d)` env-var
  fixture (answer (c)); marker-store isolation per test prevents cross-test bleed.
- The D-DEC-003 `--bare`-absent and D-DEC-010 allowlist-matches-SKILL assertions are pure
  structural greps over `run-monitoring-loop.sh` — cheap, high-value SEC guards folded into
  BC-10.01.001's count.
- **VP-SKILL-064 (org_slug scoping — the sole plugin-side cross-tenant isolation guarantee,
  D-DEC-005) uses three complementary legs:** (i) a prism-DTU-demo-server multi-org fixture with
  three orgs (org-a / org-b / org-c) seeded with distinguishable rows — a query issued in the
  org-a FOR-EACH context must return ZERO org-b/org-c rows (behavioral isolation proof);
  (ii) a static/structural check that the loop's PrismQL construction ALWAYS injects an
  `org_slug` constraint matching the current org context (grep the query-builder path — no
  code path emits a query without the constraint); (iii) an adversarial fixture that attempts an
  unscoped query — the loop must reject or auto-scope it, never issue it bare. This is the
  monitoring-loop analogue of the sibling structural VP-SKILL-059 (scan-threats), but promoted to
  a behavioral+adversarial integration property because the loop is autonomous (no human in the
  query-construction path). Mutant SM-24 (org_slug-drop) is the paired kill target.
- **VP-SKILL-065 (autonomy_enabled kill switch — Inv#11) — RE-SCOPED v1.9 (ADV-F2-P6-003 MAJOR / D-DEC-012
  Option A).** The pass-1 scope ("ZERO markers consumed AND ZERO `jr issue create/comment/assign` calls
  under `autonomy_enabled=false`") directly contradicted the human-confirmed Option A + EC-006/EC-014: a
  silent-sensor / Indeterminate (hard-floor) run WILL issue a `jr issue create … --label BLIND-SPOT`
  escalation write under the kill switch (that write IS the human-surface mechanism; suppressing it would
  silence the finding). VP-SKILL-065 is therefore **re-scoped, not silently FINALIZED — re-marked PROPOSED**
  this pass. The BATS integration test with `autonomy_enabled=false` injected now asserts, on a **regular
  (non-hard-floor FP)** verdict: the marker dir contains no consumed (`.used`) **REGULAR** markers AND the
  jr-mock spy records **zero REGULAR** `jr issue create/comment/assign` invocations, while evidence
  collection + verdict construction + Jira drafting still proceed (a `propose-only`-annotated draft is
  written); and, on a **silent-sensor (hard-floor)** verdict, a `create-review` marker IS emitted and the
  jr-mock spy DOES record the review escalation write (kill-switch EXEMPT via the STEP 3 correct-label
  review path, which runs before the STEP 5 kill switch; an under-labeled hard-floor verdict is denied at
  STEP 4 so the loop re-documents with the review token). This is the positive companion to VP-HOOK-026
  (which proves hard floors block REGULAR markers regardless of `autonomy_enabled=true`); VP-SKILL-065
  proves the global-off path halts only REGULAR autonomous writes. Mutant SM-25 (kill-switch-ignore) is the
  paired kill target for the REGULAR-suppression leg.
- **VP-HOOK-027 (stage-order document-before-action — P1 cross-hook, NEW v1.2) reuses the ASM-009
  cross-hook harness (answer (b))** but tests the *ordering* rather than single-use: the property
  is that require-review DENIES a Stage-8 `jr` write unless a Stage-7 verdict Write already caused
  disposition-guard to emit a matching scoped marker within the 120s TTL. The negative leg
  (`jr` Bash first, empty marker dir → deny) is the empirical guard the adversary said was missing
  (ADV-F2-P2-014) and would have caught the inverted-stage CRITICAL (ADV-F2-P2-001). Mutant SM-28
  (stage-order-inverted) is the paired kill target. This VP does NOT assert the monitoring-loop
  SKILL's internal stage numbering (that is a SKILL-prose/PO concern); it asserts the *hook-enforced
  consequence* of getting the order wrong — which is why it lives in VP-HOOK, not VP-SKILL.
- **VP-SKILL-066/067 (update-jira never-reopen + SLA surface, NEW v1.2)** are the missing
  update-jira-path guards (ADV-F2-P2-009a/b). VP-SKILL-062 asserts never-reopen on the autonomous
  monitoring-loop path; VP-SKILL-066 asserts it on the analyst-facing update-jira path (jr-mock
  Resolved→propose-only-halt, Closed→create-new+link, plus a static grep that no code path emits
  `jr issue move` out of Closed/Resolved — directly realizing BC-4.02.001 §Refactoring-Notes'
  stated formal-verification target). VP-SKILL-067 asserts every append/link/propose-reopen action
  emits the explicit SLA-impact statement, defaulting to "SLA: unknown — do not assume compliant"
  when `jr issue view` yields no SLA data. Mutant SM-26 (reopen-guard-removed) pairs with
  VP-SKILL-066.
- **VP-SKILL-068 (grace-window + Jira-first dedup, NEW v1.2)** closes the D-DEC-002 coverage gap
  (ADV-F2-P2-009c): VP-SKILL-050 tests only that the watermark is monotonic; VP-SKILL-068 tests
  that the *grace window's* re-fetch of late/out-of-order OCSF events does not double-ticket.
  prism-DTU seeds an event with normalized `_time` inside `[watermark − WATERMARK_GRACE_SECONDS,
  watermark]`; jr-mock returns an existing open ticket for it → assert the loop appends a comment
  (Stage-2 Jira-first dedup, D-DEC-002 §"Jira-first dedup") and does NOT `jr issue create`. Mutant
  SM-27 (dedup-check-removed→double-ticket) is the paired kill target: with dedup off, the
  re-fetched event creates a duplicate and the mutant dies.
- **VP-HOOK-026 unknown-asset leg (NEW v1.3, ADV-F2-P3-001 CRITICAL)** extends the existing
  hard-floor family with `asset_type=unknown`. The adversary's finding was a mis-propagation on the
  authorization boundary: BC-10.01.001 v1.9 Inv#10 policy already made `unknown` a conservative hard
  floor, but the disposition-guard emitter list (BC-3.03.001 Inv#4) and the `hard_floor_applies()`
  pseudocode omitted it, so a LOW-severity + benign + `asset_type=unknown` verdict with a SKILL-side
  `ticket_action_type!=none` label would get a REGULAR (autonomous-triage) marker → auto-write. The BATS
  test injects exactly that benign-but-unknown verdict with `autonomy_enabled=true` and **[UPDATED v1.8]**
  asserts NO regular (comment/create/assign-scoped) marker is written — a `create-review`/`comment-review`
  STEP-4 DENY-THE-WRITE of an under-labeled hard-floor verdict is acceptable (its fail-loud completeness is
  owned by VP-HOOK-029); what VP-HOOK-026 forbids is a regular autonomous-triage marker. Mutant SM-29
  (unknown-asset-hard-floor-removed) is the paired kill target (it issues a regular comment marker and
  dies). This is a pure hook-side guarantee (defense-in-depth independent of SKILL.md), which is why it
  stays on VP-HOOK-026.
- **VP-HOOK-025 12-vs-15 artifact-class split + confidence float→enum legs (NEW v1.3,
  ADV-F2-P3-003/P3-008)** close two VP-coverage seams the adversary flagged (ADV-F2-P3-013). The
  split makes the field-set an explicit per-class test axis: the investigation-markdown class checks
  the 12 ICD-203 headings ONLY (a valid 12-field investigation → allow; a spurious Severity heading →
  still allow, no wrong-class 18-field deny), while the verdict-JSON class checks all 18. Mutant SM-30
  (artifact-class-over-strict — apply the 18-field set to investigation markdown) dies on the
  investigation-12-field-accept test — this guards the ADV-F2-P3-003 regression where 18-field
  validation on investigation markdown would break the investigate-event DI-013 marker path. The
  float→enum legs assert disposition-guard's field#2 enum type-assertion DENIES a float `confidence`
  (e.g. `0.85`) and ALLOWS the three enum values — the hook-side backstop for D-DEC-011.
- **VP-HOOK-028 (verdict-path reachability — NEW v1.3, ADV-F2-P3-005) reuses the ASM-009 cross-hook
  harness (answer (b))** to prove the load-bearing verdict-file-path naming convention (BC-10.01.001
  Stage-7 PC#8). Because disposition-guard fast-path-allows any Write whose path lacks the `verdict`
  substring (no ICD-203 validation, no marker), a mis-named Stage-7 write silently emits no marker, and
  require-review then DENIES every downstream Stage-8 `jr` write (nothing to consume). The negative leg
  (Write to `artifacts/findings/alert-001.json` → empty marker dir → jr deny) proves the failure mode
  is fail-closed (action denied), and the positive control (`.../verdict-alert-001.json` → marker → jr
  allow) proves the convention is what gates reachability. No paired mutant is assigned (the property is
  a naming-convention reachability check on the fast-path branch, covered by SM-19's dual-path router
  mutant family); the value is the explicit reachability seam that had no owning VP.
- **VP-SKILL-069/070 (investigate-event + assess-priority org_slug scoping — NEW v1.3,
  ADV-F2-P3-004)** extend the D-DEC-005 tenant-isolation guarantee to the two remaining autonomous/
  semi-autonomous PrismQL surfaces the adversary found uncovered: VP-SKILL-064 covered only the
  monitoring-loop and VP-SKILL-059 only scan-threats. Both use the VP-SKILL-064 three-leg pattern —
  (i) static Iron-Law content assertion that every PrismQL block in the owning SKILL.md carries a
  `WHERE org_slug=` constraint (VP-SKILL-069: Stage-3 OCSF + temporal-adjacency; VP-SKILL-070:
  PC#5a/5b/5d); (ii) a prism-DTU multi-org fixture asserting an org-a query returns zero org-b/c rows;
  (iii) an adversarial unscoped-query fixture that must be rejected/scoped. VP-SKILL-069 leans more
  static (investigate-event is analyst-driven), VP-SKILL-070 pairs static + DTU behavioral. No new
  mutant beyond the existing SM-24 org_slug-drop pattern (the same mutation class applied per surface).
- **VP-SKILL-071 (assess-priority confidence float→enum consistency — NEW v1.3, ADV-F2-P3-008 /
  D-DEC-011)** is the producer-side companion to VP-HOOK-025's enum type-assertion. Architecture-delta
  §8.9 item 4 proposed a proptest/hypothesis property test, but this plugin's stack is declarative
  bash (no proptest — see `verification_stack`), so the property is realized as a BATS
  boundary/equivalence-partition test over the D-DEC-011 thresholds: `confidence_score` at and around
  0.75 and 0.40 must map to the correct enum (`0.75→high`, `0.749→medium`, `0.40→medium`, `0.399→low`,
  endpoints inclusive to the higher tier), and an inconsistent pair (`0.85`/`low`) is flagged invalid.
  This guarantees the enum handed to verdict field #2 is well-formed before disposition-guard
  (VP-HOOK-025) type-asserts it — the two VPs are complementary halves of the D-DEC-011 contract.
- **VP-HOOK-024 create-pattern injection-safety + audit sanitization (NEW v1.5, ADV-F2-P4-002
  CRITICAL / P4-010).** The pass-4 adversary showed the v1.4 create `command_pattern`
  `^jr (--output json )?issue create .*--project <key>` was defeated two ways: (a) the unbounded
  `.*` let an attacker-influenceable `--summary "…--project ORG_A…"` satisfy the `--project ORG_A`
  substring while the command actually targeted `--project ORG_B` (cross-org create bypass); (b) no
  trailing boundary let `--project PROD` prefix-match `--project PRODUCTION`. v1.5's tests pin the
  anchored fixed-position pattern `^jr (--output json )?issue create --project <key>( |$)` (`--project`
  first, trailing space-or-EOL) and assert the two attack commands DENY. The P4-010 leg asserts a `\n`
  embedded in `ticket_id` (Jira-content-influenced) cannot forge a second MARKER_USED audit line —
  `ticket_id`/`org_slug`/`op` are control-char-stripped (`tr -d '\000-\037'`) like the base64 command.
  These are consumer/emitter-side hook behaviors (require-review anchored match + audit; disposition-guard
  create-emitter pattern), so they stay on VP-HOOK-024. Mutant SM-35 (control-char-strip-removed) is the
  audit-forgery kill target; the injection legs kill the retired-`.*` regression class directly.
- **VP-HOOK-025 validate_enums() membership gate (NEW v1.5, ADV-F2-P4-006).** The adversary found the
  verdict-JSON check was key-presence-only while `hard_floor_applies()` keys on exact-string membership,
  so a case-mangled `severity:"High"` passed presence, silently missed the `∈{HIGH,CRITICAL}` membership
  test, escaped the hard floor, and got a marker for an actually-HIGH alert. v1.5 adds a
  `validate_enums(verdict)` step that runs BEFORE the hard-floor check and fail-closed-DENIES any
  non-member value on all six typed fields (severity, asset_type, disposition, sensor_health_status,
  ticket_action_type, confidence). Fail-closed DENY is deliberate — allow-without-marker would let a
  field-mangled verdict write to the investigation store without an ICD-203 guarantee. Mutant SM-31
  (validate_enums-removed) is the paired kill target.
- **VP-HOOK-026 review-surfacing + kill-switch determinism (extended v1.5, D-DEC-012 / ADV-F2-P4-004 /
  P4-005).** Two pass-4 corrections extend the hard-floor family without weakening it: (i) the D-DEC-012
  `create-review`/`comment-review` marker types are EXEMPT from the hard-floor no-marker rule and the
  kill switch (emitter Step 3 correct-label review path runs before the Step 5 kill switch; an under-labeled
  hard-floor verdict is denied at Step 4 — also before Step 5 — per the v1.10 deny-the-Write redesign, so the loop re-documents; both stay ahead of the Step 5 kill
  switch — post the ADV-F2-P6-002 reorder) because a `[REVIEW-REQUIRED]`/`[BLIND-SPOT]` ticket is human
  ESCALATION, not autonomous triage — new legs assert a hard-floor verdict WITH `create-review` DOES get
  a restricted marker (`authorized_operations=["create-review"]`), even under `autonomy_enabled=false`;
  (ii) the kill switch is read DIRECTLY by disposition-guard from the verdict's `autonomy_enabled`
  operational field (P4-005) rather than trusting the loop LLM to set `ticket_action_type=none`, so
  `autonomy_enabled≠true` (false OR absent→conservative false) suppresses ALL REGULAR markers. The
  original unconditional-hard-floor legs (Indeterminate/HIGH/critical-asset/unknown/T1003/degraded) are
  UNCHANGED for regular markers. Mutant SM-33 (autonomy_enabled-clause-removed → regular marker under
  kill switch) is the paired kill target for the kill-switch legs.
  **[EXTENDED v1.8 — over-label gate, ADV-F2-P5-002 MAJOR.]** Pass-4 treated the review-token exemption
  as UNCONDITIONAL on the LLM-supplied `ticket_action_type`; the adversary (P5-002) showed this let the
  LLM manufacture a kill-switch + hard-floor bypass by over-labeling a regular verdict as `create-review`.
  The architect's D-DEC-008 STEP 3 fix GATES the exemption on the hook-computed `hard_floor_applies(verdict)`
  (`IF NOT hard_floor_applies(): emit allow WITHOUT marker; RETURN`). New v1.8 over-label legs assert a
  NON-hard-floor verdict (disposition=TP, LOW severity, standard asset) carrying a review token gets NO
  marker — incl. under `autonomy_enabled=false` (no kill-switch bypass). The paired kill target is the
  RE-SCOPED **SM-32b** (step3-hard-floor-gate-removed → a non-hard-floor verdict with a review token gets
  the exempt marker; the over-label legs assert NO marker, so it dies). The review-surfacing positive
  controls (hard_floor_applies()=TRUE → marker emitted) remain valid under the gated STEP 3. This is the
  over-label dual of the VP-HOOK-029 under-label fail-loud invariant (SM-32a) — the two together close the
  P5-001/P5-002 single root cause (the hook trusting the LLM token without cross-checking hard_floor_applies).
- **VP-HOOK-028 JSON-first canonical-path dispatch (extended v1.5, ADV-F2-P4-001 CRITICAL).** The pass-3
  fix (mandate `verdict` in the Stage-7 path) collided with the canonical path
  `artifacts/investigations/verdict-<id>-<iso_ts>.json`, which contains BOTH `investigation` and `verdict`
  substrings. A plain "check `investigation` first" router misroutes the canonical verdict JSON to the
  12-field markdown branch → heading assertions fail → DENY → no marker → the entire autonomous pipeline
  is unreachable (the P4-001 CRITICAL). v1.5 pins the JSON-first dispatch order this doc already specified
  (JSON-content/`.json` → 18-field verdict path REGARDLESS of the `investigation` substring; `*investigation-*.md`
  → 12-field; else fast-path) as an explicit VP-HOOK-028 regression leg: `.../verdict-alert-001.json` →
  18-field path → marker (positive, NOT misrouted); `.../investigation-001.md` → 12-field. Mutant SM-34
  (dispatch-order-inverted) is the paired kill target. BC-3.03.001 v1.13 PC#1/2/3 own the rewritten dispatch.
- **VP-HOOK-029 end-to-end consumer-boundary fail-loud invariant (NEW v1.5; RE-SCOPED v1.8/v1.9; re-scoped
  END-TO-END + re-FINALIZED v1.10, P0, D-DEC-012 / ADV-F2-P7-001 CRITICAL / P7-004 MAJOR — O4 standing rule).**
  This is the closure of the mutual exclusion the adversary flagged: BC-10.01.001 v1.7 Inv#10 forced
  hard-floor verdicts to `ticket_action_type=none` (no marker), while EC-006/EC-014 required the loop to
  create `[BLIND-SPOT]` / `[REVIEW-REQUIRED]` tickets — so in unattended cron a hard-floor verdict was
  silently dropped. **Passes 5–6 (historical):** the fix deterministically UPGRADED an under-labeled
  hard-floor verdict to a `create-review`/`comment-review` marker at STEP 4 (moved before the STEP 5 kill
  switch at pass-6), with kill-switch-ON vectors added. **Pass-7 root cause + redesign (P7-001 CRITICAL):**
  the STEP-4 marker-*upgrade* was proved STRUCTURALLY UNSOUND — disposition-guard can rewrite the marker but
  NOT the loop's future Bash command. Under-labeling means the loop set a non-review `ticket_action_type` and
  will run the corresponding non-review command; the upgraded `create-review` marker requires `--label` in
  fixed second position, so for 3 of 4 under-label action types (create/assign/none) the loop's own command
  cannot match the upgraded marker's `command_pattern` → require-review DENIES the Stage-8 jr → **no ticket
  is ever created** and the CRITICAL finding is invisible to the analyst (only an audit line records it).
  The upgrade merely *moved* the silent drop from "no marker" to "marker present but structurally
  unconsumable by the command." **The mechanism is RETIRED; new STEP 4 = DENY-THE-WRITE:** disposition-guard
  DENIES the under-labeled verdict Write itself with a structured machine-readable corrective reason
  (`hard_floor_trigger`, `required_token` [create-review if ticket_id null, else comment-review],
  `label_instruction`, `instruction`) + an **UNDER-LABEL-DENIED** audit entry; NO marker; the loop
  re-documents with the required review token; on the corrected Write, STEP 3 issues the review marker
  normally. Non-termination is bounded fail-closed — the deny + audit ARE the loud failure; a loop that never
  re-documents is a BC-10.01.001 conformance defect, detectable by VP-HOOK-029's consumer-boundary
  assertion. STEP 4 still precedes the STEP 5 kill switch, so the deny fires regardless of
  `autonomy_enabled`. **Pass-7 verification gap (P7-004 MAJOR — O4):** the v1.9 VP-HOOK-029 assertion was
  EMITTER-ONLY ("a marker exists OR an error artifact was written"), which is satisfied even by an
  unconsumable marker — it could NOT detect the Write→Bash seam gap. Per the **O4 standing rule (§0)**,
  VP-HOOK-029 is re-scoped to assert the CONSUMER-BOUNDARY outcome: for ANY `ticket_action_type`, either
  (a) a review-token verdict yields a marker AND a correctly-labeled jr write that is authorized and
  CONSUMABLE at consumer STEP 6a (the escalation jr write actually occurs), or (b) a non-review-token verdict
  is DENIED at STEP 4 with a machine-actionable corrective reason + UNDER-LABEL-DENIED audit — NEVER a marker
  the loop's own command cannot consume, NEVER a silent allow. The consumer-boundary vectors (create-review
  marker + correctly-labeled jr → ALLOW; create-review marker + no-`--label` jr → DENY) are the O4 seam-gap
  guard; the kill-switch-irrelevance vector asserts the deny fires with `autonomy_enabled` true AND false.
  Reuses the ASM-009 cross-hook harness (disposition-guard emit → require-review consume + STEP 6a label
  match, BC-3.01.001 v1.19 step 6/6a). **Lifecycle: re-marked PROPOSED pending the deny-path vector set, then
  re-FINALIZED (P0) v1.10 per architecture-delta §8.17 item 1** — the convergence-blocking safety invariant
  is no longer deferred to F6. **The three v1.9 STEP-4 upgrade-marker vectors + the UNDER-LABEL-CORRECTED
  audit assertion are RETIRED (reason "mechanism removed ADV-F2-P7-001"; history preserved). Paired mutants:
  SM-38 (remove the STEP-4 deny → silent allow) killed by the deny-path vectors; SM-39 (remove the
  corrective-reason structure → deny fires but the loop cannot act) killed by the machine-actionable-reason
  vector; SM-32a (RE-TARGETED: revert the deny to the retired GOTO-WRITE_MARKER upgrade → unconsumable
  in-store marker) killed by the consumer-boundary unconsumable vector; SM-32-ext (revert STEP 4/5 order)
  killed by the kill-switch-irrelevance vector; all disjoint from SM-32b (over-label, killed by VP-HOOK-026).**
  **[EXTENDED v1.11 — STEP-3 correctly-labeled-yet-unbindable deny, ADV-F2-P8-001 CRITICAL / D-DEC-012
  clause 2.]** Passes 5–7 hardened the UNDER-LABEL axis (non-review token) exhaustively; the adversary
  (P8-001) found the dual residual on the CORRECTLY-LABELED review path. When the loop supplies a genuinely
  hard-floor verdict with a CORRECT review token but a null non-ICD-203 operational binding field
  (`create-review` + null/empty `jira_project_key`; `comment-review` + null `ticket_id`), the pre-P8-001
  STEP 3 hit `emit allow without marker; RETURN` — a silent allow with no marker, no deny, no audit. Because
  `jira_project_key`/`ticket_id` are in neither the 18-field presence check nor `validate_enums()`, the
  verdict cleared every prior gate and the hard-floor finding was silently dropped (the P5-001/P7-001 pattern,
  verbatim, on the review path). The redesigned D-DEC-008 STEP 3 replaces BOTH silent-allow branches with a
  **`HARD-FLOOR-UNBINDABLE` DENY-THE-WRITE**: WRITE a `HARD-FLOOR-UNBINDABLE` audit entry naming the
  `missing_field`, emit `deny` with a structured corrective reason (`hard_floor_trigger`, `missing_field`,
  re-issue instruction; the comment-review branch adds a create-review fallback hint when `jira_project_key`
  IS present — mirroring the STEP-4 `required_token` logic). So the gated STEP-3 review path now yields
  exactly one of {a bindable review marker, a `HARD-FLOOR-UNBINDABLE` deny} — NEVER a silent allow. This is
  ADDITIVE to VP-HOOK-029's §2 deny-path set (the VP stays FINALIZED P0 — an EXTENSION, not a re-scope): new
  consumer-observable vectors 9–11 assert the deny + audit + fallback hint. Bounded non-termination mirrors
  STEP 4 — one `HARD-FLOOR-UNBINDABLE` audit entry + one deny per re-doc attempt, no Jira write, no silent
  loop (the pass-9 non-termination concern the adversary flagged is discharged by the bounded fail-closed
  analysis). Paired mutant **SM-41** (revert the STEP-3 create-review null-`jira_project_key` branch to
  emit-allow-without-marker) killed by vectors 9–11; separately killable from SM-38 (the STEP-4 under-label
  deny sentinel) — distinct branches, distinct code, distinct vectors.
- **VP-HOOK-024 consumer STEP 6a anti-fungibility (NEW v1.9, ADV-F2-P6-001 CRITICAL).** The adversary showed
  that `create` and `create-review` markers had byte-identical `command_pattern`s and the consumer accepted
  either token for a `jr issue create`, so a `create-review` escalation marker could authorize a regular
  autonomous create (and vice versa) — a kill-switch + hard-floor bypass whenever a hard-floor verdict
  coexisted with a regular write in the same run. D-DEC-012's Alternatives-Rejected is REVERSED: hook-side
  label enforcement is now ADOPTED (a security control cannot live only in the untrusted SKILL.md Iron Law).
  The create-review `command_pattern` now encodes `--label (REVIEW-REQUIRED|BLIND-SPOT)` in FIXED second
  position after `--project <key>` (`^jr (--output json )?issue create --project <key> --label
  (REVIEW-REQUIRED|BLIND-SPOT)( |$)`), and require-review STEP 6a cross-checks BOTH directions: a
  `["create-review"]` marker is refused for a command lacking a review label (named vector
  `create-review-marker-requires-review-label`, kills SM-36), and a `["create"]` marker is refused for a
  command carrying a review label (named vector `create-marker-rejects-review-label`, kills SM-37); correct
  pairings consume normally (EC-023). `has_review_label` is a structural property of the command, not Jira
  content; the comment/comment-review structural `--label` check pends ASM-014, with ticket_id binding + Iron
  Law as the interim comment-review guard. This also mitigates P6-004 (single shared `PRISMDEMO` project key
  makes per-org create-marker isolation infeasible; the review-label binding + single-use + TTL are the
  primary cross-org protection for create-review operations).
  **[EXTENDED v1.10 — STEP 6a structural-check false-deny prevention, ADV-F2-P7-005 MINOR / D-DEC-001
  `structural_label_check`.]** The adversary showed the v1.9 `has_review_label` was an UNANCHORED raw
  substring test over the whole command, which includes the LLM/attacker-influenceable `--summary` text: a
  benign FP-close create such as `jr issue create --project PRISMDEMO --summary "rule matched literal --label
  REVIEW-REQUIRED in payload"` passes step-5's anchored regular-create pattern but then step-6a set
  `has_review_label=true` against its `["create"]` marker → the legitimate create was FALSE-DENIED. This is a
  content-vs-structure defect: the anchored step-5 `command_pattern` is the gate that verifies the command
  is a genuine `jr issue create` for THIS `["create"]` marker, so step-6a's over-eager substring match only
  produced false-denies (fail-closed, not a bypass). The pass-7 fix made step-6a STRUCTURAL —
  `structural_label_check(cmd)` returns true only when `--label` appears as a standalone token immediately
  preceding `REVIEW-REQUIRED`/`BLIND-SPOT`.
  **[EXTENDED v1.11 — QUOTE-AWARE tokenizer, ADV-F2-P8-002 MAJOR / D-DEC-001.]** The adversary (P8-002) showed
  the pass-7 `split_on_whitespace` was STILL defective: the hook receives `tool_input.command` as the RAW
  command string with literal quote characters (`jq -r`, no shell expansion has occurred), and a naive
  whitespace split of EC-024's own example — `jr issue create --project PRISMDEMO --summary "rule matched
  literal --label REVIEW-REQUIRED in alert payload"` — yields `--label` as a standalone token immediately
  followed by `REVIEW-REQUIRED` → `structural_label_check` returns true → the legitimate create is STILL
  false-denied. The D-DEC-001 fix replaces `split_on_whitespace` with a QUOTE-AWARE state-machine tokenizer
  (UNQUOTED/IN_SINGLE/IN_DOUBLE) that keeps a quoted region as one token: the tokenizer enters IN_DOUBLE at
  the opening `"` before "rule", so the whole `--summary` value is a single token and there is NO standalone
  `--label` token. Named vector `regular-create-with-label-literal-in-summary-allowed` (updated to the QUOTED
  form explicitly): the `["create"]` marker + that quoted-`--summary` create → `has_review_label=false` →
  **ALLOW** (not a false-deny). Paired mutants: **SM-40** (revert to the raw-substring check) and **SM-42**
  (revert to non-quote-aware `split_on_whitespace`); the SINGLE quoted-form vector SEPARATELY kills both —
  SM-40 because the raw substring matches inside the quoted region, SM-42 because whitespace-splitting breaks
  the quoted value into a standalone `--label` token (distinct failure mechanisms, same vector).
  **[P8-003 MINOR — step-6a is the SOLE anti-fungibility enforcement point.]** The adversary corrected a false
  claim (EC-023 direction A / the create generation-table note) that the regular create pattern
  `^jr … issue create --project KEY( |$)` REJECTS a review-labeled create at step 5. Bash `[[ =~ ]]` is NOT
  tail-anchored: for `jr issue create --project PRISMDEMO --label REVIEW-REQUIRED …` the regex matches the
  prefix up to the space after `PRISMDEMO`, so **step 5 PASSES**. `( |$)` guards ONLY against project-KEY
  prefix extension (`PROD` ≠ `PRODUCTION`, its P4-002 purpose) — it is NOT a review/regular defense-in-depth
  backstop. Therefore the create/create-review anti-fungibility (EC-023 direction A) rests EXCLUSIVELY on
  step-6a `structural_label_check`; there is no step-5 redundancy. The correction is a BC-3.01.001 EC-023 body
  edit (PO-owned, §8.18) — verification-delta carries no current-body step-5-defense-in-depth claim to retract
  — but it RAISES the criticality of the step-6a mutant family: SM-36/SM-37 (both directions, CRITICAL),
  SM-40 (raw-substring false-deny), and SM-42 (non-quote-aware false-deny) now cover a NON-REDUNDANT single
  point of failure and are **P0-adjacent** — all four MUST be killed at the ≥95% require-review bar. Security
  posture is unchanged (step 6a correctly denies a genuine `--label REVIEW-REQUIRED` flag on a `["create"]`
  marker via direction B); the v1.11 work only closes the quoted-`--summary` false-deny and corrects the
  reasoning.
  **[EXTENDED v1.12 — ESCAPED-QUOTE differential-vs-bash partition (O5), ADV-F2-P9-001 MAJOR / D-DEC-001 v1.12.]**
  The adversary (P9-001) showed the P8-002 quote-aware tokenizer was STILL incomplete: it toggles
  UNQUOTED/IN_SINGLE/IN_DOUBLE on EVERY `"`/`'` regardless of a preceding backslash, so it diverges from bash for
  the backslash-escape class. For the Iron-Law-compliant command `jr issue create --project PRISMDEMO --summary
  "a\"b" --label REVIEW-REQUIRED`, bash/jr parse the args as `[--summary, a"b, --label, REVIEW-REQUIRED]` and
  apply a FUNCTIONAL REVIEW-REQUIRED label; the P8-002 tokenizer, however, treats the `\` as a literal char and
  the following `"` as a quote-CLOSE, then the next `"` as a quote-RE-OPEN — swallowing `--label REVIEW-REQUIRED`
  into the `--summary` token → `has_review_label=false`. Because P8-003 removed the step-5 backstop, a regular
  `["create"]` marker then wrongly AUTHORIZES a command that creates a REVIEW-REQUIRED-labeled ticket — the exact
  EC-023 direction-A fungibility bypass, with NO compensating control. The D-DEC-001 v1.12 fix makes the
  tokenizer backslash-aware (index-based iteration): `\"` in IN_DOUBLE → literal `"`, STAY IN_DOUBLE; `\'` in
  UNQUOTED → literal `'`, NO IN_SINGLE toggle — matching bash. Per the **O5 standing rule (§0)** this VP now
  carries the escaped-quote partition and is the **O5 compliance artifact** for `structural_label_check`: **1a**
  (SECURITY — escaped-quote boundary hides a real trailing `--label REVIEW-REQUIRED` → `has_review_label=TRUE` →
  a `["create"]` marker is DENIED; kills **SM-43**), **1b** (false-deny prevention — escaped quote inside
  `--summary`, no real label → `has_review_label=FALSE` → ALLOW), and **partition-2** (UNQUOTED completeness —
  `\'` is a literal apostrophe with no IN_SINGLE state entered, so a subsequent whitespace-preceded `--label
  REVIEW-REQUIRED` is correctly detected → DENY). **SM-43** (revert the IN_DOUBLE backslash handling to the
  P8-002 toggle-on-every-quote) is separately killable from SM-40 (raw-substring) and SM-42 (split_on_whitespace)
  — neither of those mutations, nor the P8-002 quoted-form vector (which contains no `\"`), exercises the
  backslash-escape class, so vector 1a is the dedicated killer. **Equals-form `--label=REVIEW-REQUIRED` is SCOPED
  OUT of the partition** — jr CLI does not support the equals form (`jr issue create --help`, confirmed
  2026-07-21); only `--label VALUE` space-separated form is emitted. Per O5, re-evaluate if jr adds equals-form
  support. The step-6a mutant family is now **SM-36/37/40/42/43**, all P0-adjacent (step 6a is the SOLE
  anti-fungibility gate post-P8-003). **[EXTENDED v1.12 — STEP-3 dedup-before-fallback, ADV-F2-P9-007 MINOR.]**
  P9-007 observed that the P8-001 comment-review deny fallback hint ("if no review ticket exists, re-issue as
  create-review") assumes a null `ticket_id` means NO ticket exists — but a null `ticket_id` can be a
  dedup-lookup MISS while an open BLIND-SPOT/REVIEW-REQUIRED ticket exists, so blindly following the hint creates
  a DUPLICATE review ticket (violating D-DEC-004's one-open-ticket-per-(org,sensor)). The fix conditions the
  fallback on a §3.4 dedup re-run: VP-HOOK-029 gains a test-only vector (12) asserting the deny reason's fallback
  hint carries the dedup-re-run instruction (not a bare "try create-review"); the loop-side "dedup HIT → COMMENT,
  not a second create" behavior is discharged by **VP-SKILL-068** (grace-window + Jira-first dedup). No mutant is
  warranted (architect §8.21 item 2 — the change is in the deny-reason text, not a security-critical control-flow
  branch).
- **VP-SKILL-073 late-event drop detection (NEW v1.9, ADV-F2-P6-007 MINOR, D-DEC-002).** The D-DEC-002
  monotonic watermark WRITE guard (`max(stored, ts)`) means once the watermark advances past a late event's
  `_time`, that event is never re-queried — a SILENT missed-alert path on the HIGH-criticality watermark
  store. `DETECT_LATE_EVENT()` (Stage-1 INGEST, called after `NORMALIZE_PRISM_TIME`) converts it to an
  AUDITABLE one: when an ingested event's normalized `_time` is older than `watermark − WATERMARK_GRACE_SECONDS`,
  it appends a `LATE_EVENT_DETECTED` line (with `event_time=`, `watermark=`, `grace_window=`) to
  `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log` and **processes the event normally** (never drops it). The
  BATS integration test injects a below-grace-floor event → asserts the audit line present AND the event
  reaches VALIDATE; control legs cover an in-window event (no detection) and first-run (no baseline → early
  return, no false positive). This gives operators the empirical signal to tune `WATERMARK_GRACE_SECONDS`
  during Wave-7 validation (ASM-008 is UNVALIDATED — prism `_time` format + ETL latency not yet known). No
  dedicated mutant beyond the D-DEC-002 watermark-guard family; the behavioral audit-entry assertion is the
  guard. Distinct from VP-SKILL-068 (in-grace dedup) and VP-SKILL-050 (monotonicity).
- **VP-SKILL-074 severity normalization correctness (NEW v1.9, ADV-F2-P6-005 MAJOR, D-DEC-013).** *(Namespace
  correction: architect §8.15 item 3 named this "VP-SKILL-072", which is OCCUPIED — first-run 24h lookback;
  allocated the next free VP-SKILL-074, see §1.)* prism normalizes the FOUR sensor families whose native
  severities are NOT the four-value enum (CrowdStrike numeric 1-100, Armis/Claroty risk bands, Cyberint
  conservative default pending ASM-008), and `disposition-guard`'s `validate_enums()` fail-closed-DENIES any non-member `verdict.severity`.
  **(P14-001 / P11-003: NVD/CVSS is NOT a NORMALIZE_SEVERITY family — `sensor_family` has no `nvd` member; NORMALIZE_SEVERITY
  is authoritative ONLY over sensor_family ∈ {crowdstrike, armis, claroty, cyberint}; a 0.0–10.0 CVSS float is enrichment that
  feeds `scored_priority` (field 18) at Stage 5, NOT `native_severity`.)**
  Without a named normalization step a raw sensor severity (`"Medium"` wrong-case, `"70"`, `"9.1"`) would
  either be denied (pipeline-unreachable for that sensor family) or, via the "defaults to CRITICAL" rule,
  mass-escalate. `NORMALIZE_SEVERITY(native, family)` (D-DEC-013, a NAMED Stage-1 pre-processing step,
  re-applied at Stage-5 SCORE and on the Stage-1 known-FP fast-path) maps every native value to
  `{LOW,MEDIUM,HIGH,CRITICAL}` (case-exact, so `validate_enums()` never fails a well-normalized verdict); an
  UNRECOGNIZED value (any family, incl. Cyberint COMPUTE-AT-VALIDATION per ASM-008) → `CRITICAL` WITH
  `uncertainty_explicit` appended — an AUDITABLE conservative default, NEVER a silent enum-deny and NEVER a
  silent LOW. The VP is a BATS boundary/equivalence-partition test: CrowdStrike boundaries 26/51/76,
  Armis/Claroty risk-band case-fold (Critical→CRITICAL, Informational→LOW), the Cyberint conservative-default partition,
  and the unrecognized→CRITICAL
  +`uncertainty_explicit` auditable leg; it also asserts no raw sensor-native string ever reaches
  `validate_enums()`. No dedicated mutant (the `validate_enums()` fail-closed SM-31 is the downstream backstop
  if normalization regresses).
  **[EXTENDED v1.10 — Cyberint partition, ADV-F2-P7-006 MINOR / D-DEC-013 explicit conservative default.]**
  The adversary flagged that Cyberint is a RECOGNIZED family (org-b DTU demo, brief §4.2) whose per-band
  mapping is COMPUTE-AT-VALIDATION pending ASM-008, so the "unrecognized → CRITICAL" fallback did not
  cleanly fire and no concrete value was specified — a Cyberint alert could emit a non-enum placeholder that
  `validate_enums()` fail-closed-DENIES (that alert produces no verdict, no ticket) or an arbitrary tier
  (unsound hard-floor evaluation). D-DEC-013's Cyberint row is updated from the ambiguous
  COMPUTE-AT-VALIDATION to an EXPLICIT conservative default (mirrors the unrecognized-family rule, named):
  Cyberint → `CRITICAL` + `uncertainty_explicit` from first contact. Three strict partitions: (i) any
  Cyberint native severity → CRITICAL; (ii) Cyberint NEVER normalizes to LOW/MEDIUM/HIGH pre-ASM-008 (no
  down-tiering of an unvalidated family); (iii) the CRITICAL output carries `uncertainty_explicit` naming the
  unvalidated mapping. **These are pre-ASM-008 invariants — UPDATE WHEN ASM-008 RESOLVES: once the validated
  Cyberint per-band mapping lands, partitions (i)/(ii) are replaced by the real band boundaries (as with the
  other four families).** No dedicated mutant beyond SM-31 (the `validate_enums()` fail-closed backstop).
- **VP-SKILL-072 first-run 24h lookback correctness (NEW v1.5, ADV-F2-P4-012 / BC-10.01.001 Inv#13 /
  EC-001).** Dedicated VP for the absent-watermark bound that VP-SKILL-050 (monotonicity on an existing
  watermark) only mentioned incidentally. A loop-stub run against an EMPTY watermark dir must emit a
  PrismQL query bounded to `now() - INTERVAL 24 HOURS` (never a full-history scan) and persist a watermark
  at the latest processed `_time` after the run; control leg confirms an existing watermark does NOT take
  the 24h branch. No dedicated mutant (covered by the D-DEC-002 watermark-guard mutant family and the
  behavioral first-run assertion). Note: BC-10.01.001 Inv#15 (Resolved→propose-only, does NOT auto-reopen)
  is NOT given a new VP — it is already covered by **VP-SKILL-066** (update-jira never-auto-reopen,
  BC-4.02.001) on the analyst path and VP-SKILL-062 on the monitoring-loop path; §7 Part E records the
  cross-reference so Inv#15 is not left VP-orphaned.
- **VP-HOOK-030 DOWNGRADED to a consistency VP (v1.14, ADV-F2-P11-001 CRITICAL).** The pass-10 VP asserted STEP 1a
  made the severity floor "un-bypassable" by having the hook "independently derive severity from raw sensor values."
  The adversary (P11-001) proved this FALSE: `native_severity` (field 16) and `sensor_family` (field 17) are BOTH
  written by the monitoring-loop LLM at Stage-1 INGEST and read verbatim; the network-free hook makes no prism call,
  so STEP 1a re-computes the invariant from LLM-supplied inputs — a CONSISTENCY CHECK between two LLM fields, not
  ground-truth. An adversarial LLM can supply a false `native_severity`+`sensor_family`+`severity` triple that passes
  STEP 1a. The asserted guarantee is corrected to **"verdict.severity is consistent with verdict.native_severity per
  the D-DEC-013 table."** The SEVERITY-MISMATCH deny vectors are RETAINED (they still verify the consistency check, and
  still kill SM-44), but the guarantee they prove is downgraded. Genuine severity ground-truth is **ASM-008-DEFERRED,
  SYMMETRIC with the asset_type residual** (a prism-signed severity field or hook-fetched prism data). This is a pure
  wording/scope correction — no vector removed except the pass-10 CVSS-float under-report vector (removed per P11-003;
  see below). VP-HOOK-030 stays FINALIZED P0 as a consistency VP.
- **VP-HOOK-026 scored_priority high-severity floor (v1.14, ADV-F2-P11-002 MAJOR).** The pass-10 floor keyed the
  HIGH/CRITICAL leg on the hook-recomputed severity (STEP 1a output). P11-002 showed this is BOTH incompatible with
  the brief's Stage-5 recalibration (a recalibrated-DOWN verdict would false-deny) AND blind to KEV/exposure
  escalations (a detector-LOW alert scored CRIT by assess-priority would escape the floor). The floor now keys on
  `verdict.scored_priority` (field 18, the Stage-5 assess-priority output ∈{CRIT,HIGH,MED,LOW}) per brief §3.9 "any
  alert scored HIGH/CRIT → human." VP-HOOK-026 gains scored_priority floor legs — including the **detector-LOW /
  scored-CRIT** escalation (`verdict.severity=LOW` + consistent `native_severity` so STEP 1a passes, + `scored_priority=CRIT`
  → the floor STILL fires). Paired mutant **SM-46** (re-key the floor back to recomputed severity) is killed by that
  vector: under SM-46 the recomputed LOW → floor FALSE → a regular marker is wrongly issued for a CRIT-scored alert.
  A field-18 presence/enum validation leg is added to VP-HOOK-025 (absent/non-member `scored_priority` → deny).
  `scored_priority` is LLM-supplied (assess-priority is an LLM skill) — the SAME ASM-008-class residual as
  `native_severity` and `asset_type`; it is NOT asserted as ground-truth (§0 O6).
- **VP-HOOK-031 separate human-comment marker path (NEW v1.14, ADV-F2-P11-004 MAJOR).** P11-004 surfaced a
  BC-vs-architecture contradiction sharpened into an impossibility by P10-001: the specs disagreed on whether the
  12-field investigation-markdown path entered the verdict emitter, and the pass-10 emitter's `validate_enums()` (which
  requires verdict-only fields `severity`/`asset_type`/`ticket_action_type`/`native_severity`/`sensor_family`/`scored_priority`,
  none present in a 12-field markdown) would DENY a complete investigation at save time — the analyst could not save.
  The authoritative model (architecture-delta §D-DEC-008 "Separate Human-Comment Marker Path"): the investigation-markdown
  path does NOT enter the verdict emitter; it runs a separate, minimal comment-scoped marker path gated ONLY on (a)
  12-field completeness (heading-anchored grep) + (b) the markdown-evaluable hard floors (`Disposition: Indeterminate`,
  forbidden technique ∈{T1003,T1068,T1021,T1041}, `Sensor Health Status: degraded|silent`) — NOT `validate_enums()`/STEP 1a.
  VP-HOOK-031 asserts: (a) a compliant 12-field investigation save → a `["comment"]` marker bound to the parsed `ticket_id`
  is emitted and the Write is NOT denied; (b) a markdown-evaluable floor → `MARKDOWN-HARD-FLOOR` deny; (c) a 12-field
  markdown is NOT subjected to `validate_enums()`/STEP 1a (no false enum/SEVERITY-MISMATCH deny for absent verdict-only
  fields, incl. `scored_priority`). Paired mutant **SM-47** (route the 12-field markdown INTO the verdict emitter) is
  killed by (c)/(a): under SM-47 a compliant investigation hits `validate_enums()` and is wrongly denied on the absent
  verdict-only fields. It is on the disposition-guard hook (an ALLOW/DENY + marker decision), so it lives in VP-HOOK
  (sibling to VP-HOOK-025/026/030), NOT a VP-SKILL. Consumed by BC-5.01.001 (investigate-event) + BC-4.02.001 (human comment).
  **UPDATE v1.15 (ADV-F2-P12-002 CRITICAL):** the path was redesigned into four guarantees (kill switch first; non-FP→route-to-review; FP→comment marker; ticket_id charset). **UPDATE v1.16 (ADV-F2-P13-001 CRITICAL, human decision 2026-07-22 / architecture-delta §8.29):** **MARKDOWN_COMMENT_PATH is ELIMINATED — the markdown path issues NO autonomous `["comment"]` marker for ANY disposition.** Rationale: the hook cannot evaluate `scored_priority` (field 18) or `asset_type` (field 14) from a 12-field markdown, and there is no known-FP store cross-check on this path, so a comment marker cannot be floor-enforced (P12-002's GATE 1 closed the TP/BTP masquerade but left a residual FP-branch that granted an unfloored autonomous comment — the exact defect ADV-F2-P13-001 flagged). Guarantee (c) is REWRITTEN: after the markdown-evaluable floors pass, `Disposition: FP` → **allow-without-marker** (Write NOT denied; no Jira action; no comment marker — the analyst surfaces an FP comment via the review path or the 18-field verdict flow, preserving P11-004 intent); non-FP (TP/BTP) / PARSE_FAIL → **create-review/comment-review review marker** (EXEMPT from the kill switch). The prior FP→comment-marker vector is RETIRED (history preserved). Paired mutant **SM-52** (revert the elimination — FP markdown issues a comment marker) killed by the FP→allow-without-marker vector; **SM-50/SM-51 remain valid** (kill-switch gate / non-FP→review routing branches; killer vectors shifted under P13-001). **P13-003 MAJOR — strict parse grammar:** `parse_disposition_from_markdown` reads ONLY the canonical `Disposition` heading value against the {TP,FP,BTP,Indeterminate}+long-form allowlist (PARSE_FAIL→review on ambiguous/negated/multi-valued/empty/embedded-in-code-fence; NEVER allow-without-marker); `parse_autonomy_enabled_from_markdown` reads ONLY a dedicated structured field (a token inside a code fence/evidence block → false). Adversarial vectors: negated-FP prose→review; `Disposition: FP` inside a code fence (no canonical heading)→PARSE_FAIL→review; `autonomy_enabled: true` in an evidence block→gate CLOSED→allow-without-marker. Paired mutant **SM-53** (disposition parse uses a full-document substring scan → embedded/negated FP read as FP → allow-without-marker instead of review) killed by the FP-in-code-fence / negated-FP vectors.
- **NVD/CVSS clean separation (v1.14, ADV-F2-P11-003 MAJOR).** The pass-10 VP-HOOK-030 vector (5) treated a CVSS float
  as a hook-checked `native_severity` source and applied a per-family NORMALIZE_SEVERITY band to it — but `sensor_family`
  has no `nvd` member, so the per-family table is the wrong table for a 0.0–10.0 CVSS value. Per the clean separation,
  `native_severity`+`sensor_family` always describe the ORIGINATING SENSOR's raw reading; NVD/CVSS enrichment
  (`enrich_nvd()`) influences `scored_priority` (Stage-5), NOT `native_severity`. The CVSS-float STEP-1a vector is
  therefore REMOVED (no verification-delta vector now references NVD/CVSS as a `native_severity` source); CVSS's effect
  is exercised via the `scored_priority` floor (VP-HOOK-026) instead.

---

## 7. BC Corrections Required (product-owner owns the BCs — I do NOT edit them)

These are reference-hygiene corrections surfaced by adjudication. None changes a property; all
are qualifier/stale-text/VP-reference cleanups. Listed for the product-owner to apply in the BC
files (I do NOT edit BCs — PO owns them).

**A. Prior v1.0 corrections — CONFIRMED APPLIED (no further action).** Re-verified against the
LIVE BCs at edit time:
- VP-HOOK-024 `(PROPOSED)` qualifier dropped in **BC-3.01.001 v1.12/v1.13** (FV-PROPOSED-DROP).
- VP-HOOK-025 stale "F1 draft listed only 8 fields" meta-instruction removed and dual-path
  mechanism reference added in **BC-3.03.001 v1.7/v1.8** and **BC-10.01.001 v1.1/v1.2**.
- VP-SKILL-051..063 `(PROPOSED)` qualifiers dropped across BC-6.01.001/6.01.003/6.01.004/
  8.02.001/9.01.001/10.01.001 (v1.1/v1.2 FV-PROPOSED-DROP).
- tuning_signal three-way "absent=always-invalid" leg made explicit in **BC-3.03.001 v1.7 PC#4**
  (Step 1 unconditional `has()` check) — SM-18 preempted.
- ADV-F2-007 marker "in conversation context or JIRA comments" wording removed from
  **BC-4.02.001 v1.5** Precondition #1 / EC-001 (out-of-band `${CLAUDE_PLUGIN_DATA}/markers/` now
  the sole source).

**B. Prior v1.1 corrections (VP-SKILL-064/065) — CONFIRMED APPLIED (ADV-F2-P2-005; no further
action; superseding the stale "still-owed" framing).** The four VP-SKILL-064/065 corrections
requested by v1.1 are now live in **BC-10.01.001 v1.3/v1.4** — re-verified this edit. The earlier
"pending / still-owed" language (and the circular BC-cites-§7-while-§7-says-owed loop the adversary
flagged in ADV-F2-P2-005) is **removed**; both VPs are **FINALIZED**:
- Invariant #1: `(PROPOSED — pending formal-verifier finalization)` qualifier DROPPED for
  VP-SKILL-064 (BC-10.01.001 v1.3 revision note; line ~139 "FINALIZED v1.3").
- Invariant #11: VP-SKILL-065 cross-reference ADDED (BC-10.01.001 v1.3; line ~268).
- Verification Properties table: VP-SKILL-064 + VP-SKILL-065 rows ADDED (BC-10.01.001 v1.3;
  lines ~376–377).
- VP Anchors footer: both VPs listed as FINALIZED (BC-10.01.001 v1.3; line ~390).
- Audit-log path (ADV-F2-P2-007) + iterative-consume (ADV-F2-P2-003): BC-3.01.001 **v1.14**
  aligned Invariant #2 / PC#2 to `${CLAUDE_PLUGIN_DATA}/markers/audit.log` and replaced the
  fail-fast consumer with iterative-consume — matching this delta's VP-HOOK-024 (§2). No further
  BC action.

**C. NEW corrections required by this v1.2 (VP-HOOK-027 + VP-SKILL-066/067/068 finalization).**
These are the only outstanding BC reference-hygiene items after pass 2. None alters a property.

1. **BC-10.01.001 Invariant #14 + Verification Properties table + VP Anchors footer
   (VP-HOOK-027 — stage-order document-before-action):** Invariant #14 (v1.4 corrected the
   Stage 7 DOCUMENT → Stage 8 TICKET ACTION ordering) carries the ordering fix but has **no VP
   cross-reference**. Add **VP-HOOK-027** (P1 cross-hook: a Stage-8 `jr` write is denied unless a
   Stage-7 verdict Write emitted a matching marker within TTL) to Invariant #14, add a row to the
   Verification Properties table, and append it to the VP Anchors footer. Strategy per §2
   (B-INT-XH: negative jr-before-Write→deny, positive correct-order→allow, TTL-expiry→deny).
2. **BC-4.02.001 Verification Properties table + Invariants #4/#5 (VP-SKILL-066/067):** the VP
   table currently lists only VP-SKILL-006/007/008 (line ~105) and Invariants #4 (never-auto-reopen)
   and #5 (SLA surface) have **no VP cross-reference**. Add **VP-SKILL-066** (Inv#4 never-auto-reopen
   on the update-jira path — the §Refactoring-Notes formal-verification target: no code path from
   PC#7c/PC#7d emits `jr issue move`) and **VP-SKILL-067** (Inv#5 SLA surface — append/link/
   propose-reopen emit an explicit SLA-impact statement) as VP-table rows and as the invariants'
   VP anchors.
3. **BC-10.01.001 Invariant #8 (dedup) / D-DEC-002 reference (VP-SKILL-068):** the dedup /
   grace-window invariant carries the D-DEC-002 grace-window + Jira-first dedup design but has no
   VP guarding it (VP-SKILL-050 is watermark-monotonicity only). Add **VP-SKILL-068** (in-grace
   re-fetched event with an existing open ticket → COMMENT not create) as the Invariant #8 / dedup
   VP anchor and a Verification Properties table row.
4. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register
   VP-HOOK-027, VP-SKILL-066, VP-SKILL-067, VP-SKILL-068 as FINALIZED (they occupy the
   previously-free 027 / 066 / 067 / 068 slots; VP-HOOK is now 024–027, VP-SKILL 001–068). No
   renumbering of any existing VP.

**D. NEW corrections required by this v1.3 (pass-3 VP finalization: VP-SKILL-069/070/071 +
VP-HOOK-028).** None alters a property; all are VP-cross-reference / status finalizations.

1. **BC-5.01.001 Invariant #8 + Verification Properties table (VP-SKILL-069):** BC-5.01.001 v1.8
   already lists VP-SKILL-069 as `PROPOSED — formal-verifier finalizes scope and BATS fixture`
   (Inv#8 + VP table row). **Drop the `PROPOSED` qualifier → FINALIZED** and confirm the strategy
   as authored (static Iron-Law WHERE-clause assertion on the Stage-3 OCSF + temporal-adjacency
   PrismQL blocks + prism-DTU multi-org org-a-returns-zero-org-b/c fixture + unscoped-query
   adversarial leg). Scope confirmed exactly as the BC states — no scope change.
2. **BC-4.05.001 Invariant #4 + PC#6 + Verification Properties table (VP-SKILL-070, VP-SKILL-071):**
   BC-4.05.001 v1.3 already lists VP-SKILL-070 as `PROPOSED` (Inv#4 org_slug + VP table row).
   **Drop the `PROPOSED` qualifier → FINALIZED** (strategy confirmed: static PC#5a/5b/5d WHERE-clause
   assertion + DTU multi-org fixture + unscoped-query leg). **Additionally add VP-SKILL-071** (PC#6 /
   D-DEC-011 confidence float→enum consistency — boundary test at 0.75/0.40) as a NEW Verification
   Properties table row and as the PC#6 VP anchor (BC-4.05.001 currently has no VP cross-reference for
   the float→enum mapping guarantee).
3. **BC-10.01.001 Stage-7 PC#8 + Invariant #9 field#2 + Invariant #10 (VP-HOOK-028, VP-HOOK-026
   unknown leg, D-DEC-011):** (a) add **VP-HOOK-028** (verdict-path reachability) as the PC#8
   verdict-file-path-naming-convention VP anchor + a Verification Properties table row; (b) confirm
   **VP-HOOK-026** now cross-references the `asset_type=unknown` hard-floor member in Invariant #10
   (BC-10.01.001 v1.9 Inv#10 already includes `unknown`; the VP anchor should name the unknown leg
   explicitly); (c) Invariant #9 field#2 confidence-is-enum-only note should cross-reference
   **VP-HOOK-025** (already the field-completeness VP) for the float-reject assertion.
4. **BC-3.03.001 Invariant #4 hard-floor list + PC#2/PC#3 (VP-HOOK-026 unknown leg, VP-HOOK-025
   per-class split):** (a) Invariant #4 hard-floor list — once BC-3.03.001 v1.13 adds the
   `asset_type=='unknown'` bullet (architecture-delta §8.8.1 item 1), the **VP-HOOK-026** anchor
   should name the unknown leg; (b) PC#2 (investigation markdown = 12 fields) and PC#3 (verdict JSON =
   15 fields) are the per-class field-set surfaces for **VP-HOOK-025** — confirm both PCs cite
   VP-HOOK-025 with the 12-vs-15 split made explicit (architecture-delta §8.8.1 item 3 corrects the
   PC#2 15→12 erratum).
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register
   **VP-SKILL-069, VP-SKILL-070, VP-SKILL-071, VP-HOOK-028** as FINALIZED (they occupy the
   previously-free 069 / 070 / 071 / 028 slots — 069/070 already PROPOSED-referenced in BC-5.01.001 /
   BC-4.05.001; VP-SKILL is now 001–071, VP-HOOK 024–028). Update the **VP-HOOK-025** and
   **VP-HOOK-026** entries for the per-class split and unknown-asset leg. No renumbering of any
   existing VP.

**E. NEW corrections required by this v1.5 (pass-4: VP-HOOK-029 + VP-SKILL-072 + VP-HOOK-024/025/026/028
extensions).** None alters a property; all are VP-cross-reference / status additions on the pass-4
BCs (BC-3.03.001 v1.13, BC-3.01.001 v1.17, BC-10.01.001 v1.9, BC-4.02.001 v1.8, BC-6.01.001 v1.5).
These are the outstanding BC VP-anchor additions the PO must apply — I do NOT edit the BCs.

1. **BC-10.01.001 — VP-HOOK-029 (fail-loud, P1) + VP-SKILL-072 (first-run 24h lookback) + Inv#15
   cross-ref.** (a) Add **VP-HOOK-029** as the VP anchor for the narrowed Invariant #10 / D-DEC-012
   fail-loud guarantee (hard-floor verdict → `create-review`/`comment-review` marker OR explicit error,
   never silent discard) + a Verification Properties table row. Architect §8.11 item 6 tags it **P1**
   and requests **PROPOSED** lifecycle status (F6-adjudicated) — register accordingly. (b) Add
   **VP-SKILL-072** as the VP anchor for **Invariant #13** (first-run 24h lookback) / EC-001 + a VP-table
   row (currently Inv#13 has no VP cross-reference; VP-SKILL-050 covers monotonicity only). (c)
   **Invariant #15** (Resolved→propose-only) needs no new VP — add an explicit cross-reference that it is
   covered by **VP-SKILL-066** (update-jira never-auto-reopen, BC-4.02.001) and VP-SKILL-062
   (monitoring-loop path), so Inv#15 is not left VP-orphaned. (d) Confirm **VP-HOOK-028** now cites the
   Stage-7 PC#8 JSON-first dispatch (not merely `verdict`-substring reachability). (e) Confirm Invariant
   #9 now lists `autonomy_enabled` among the non-ICD-203 operational metadata fields with a **VP-HOOK-026**
   determinism cross-reference.
2. **BC-3.03.001 v1.13 — PC#1/2/3 JSON-first dispatch + validate_enums + review-surfacing.** (a) PC#1/2/3
   (rewritten to JSON-first per architecture-delta v1.6 §A) are the VP-HOOK-028 dispatch surface — cite
   **VP-HOOK-028** on the dispatch precedence (JSON/`.json` → verdict-class regardless of `investigation`
   substring). (b) Invariant #4 / PC#3 emitter — cite **VP-HOOK-025** for the `validate_enums()`
   membership gate (fail-closed DENY on non-member severity/asset_type/disposition/sensor_health_status/
   ticket_action_type/confidence, BEFORE hard floor). (c) The D-DEC-012 review-surfacing emitter branch
   (create-review/comment-review markers, hard-floor + kill-switch EXEMPT) and the `autonomy_enabled`
   read-direct-from-verdict Step 4 — cite **VP-HOOK-026** (and **VP-HOOK-029** for the fail-loud emit).
3. **BC-3.01.001 v1.17 — consumer create-pattern + audit sanitization + review-token acceptance.** (a)
   Consumer step (5) anchored create `command_pattern` (`--project` first, `( |$)` trailing) — cite
   **VP-HOOK-024** for the injection-safety guarantee (--summary injection + PROD/PRODUCTION prefix →
   DENY). (b) Consumer step (8) audit control-char stripping (`ticket_id`/`org_slug`/`op`) — cite
   **VP-HOOK-024** (audit-forgery leg). (c) Consumer step (6) acceptance of `create-review`/
   `comment-review` `authorized_operations` tokens — cite **VP-HOOK-029** (the fail-loud escalation
   consumer path).
4. **BC-4.02.001 v1.8 — PC#4 cross-tenant stale removal (P4-008) + Inv#15 cross-ref confirm.** (a)
   Confirm the P4-008 removal of "cross-tenant campaign correlation findings" from the PC#4 hard-floor
   enumeration (align with BC-3.03.001/BC-3.01.001 post-P3-011). (b) Confirm **VP-SKILL-066** remains the
   anchor for the Resolved→propose-only never-auto-reopen guarantee that BC-10.01.001 Inv#15 cross-refs.
   (No new VP.)
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register
   **VP-SKILL-072** as FINALIZED and **VP-HOOK-029** as **PROPOSED** (P1, F6-adjudicated per architect
   §8.11 item 6) in the previously-free 072 / 029 slots. Update the **VP-HOOK-024/025/026/028** entries
   for the pass-4 extensions (injection-safety, validate_enums, review-surfacing + kill-switch, JSON-first
   dispatch). VP-SKILL is now 001–072, VP-HOOK 024–029. No renumbering of any existing VP.

**F. NEW corrections required by this v1.8 (pass-5 re-scope: VP-HOOK-029 + VP-HOOK-026 + SM-32a/32b).**
*(HISTORICAL — the STEP numbering below is the v1.8-era layout; the ADV-F2-P6-002 STEP REORDER at v1.9
renumbers the under-label upgrade from STEP 5 → **STEP 4** (now before the STEP 5 kill switch). See Part G
for the current, superseding v1.9 numbering.)*
The disposition-guard STEP 3 (over-label gate) and STEP 5 (under-label fail-loud upgrade — **renumbered to
STEP 4 at v1.9**) emitter BODY updates are owned by the product-owner per architecture-delta v1.8 §8.12
(BC-3.03.001 STEP 3+STEP 5; BC-10.01.001 Inv#10 ticket_action_type under-label semantics) — I do NOT edit
the BCs. The FV-side cross-references the PO should reflect when applying those STEP updates:
1. **BC-3.03.001 v1.13 Inv#4 emitter — STEP 3 over-label gate + STEP 5 under-label upgrade.** (a) The
   STEP 3 review-marker exemption gated on `hard_floor_applies(verdict)=TRUE` (over-labeled non-hard-floor
   verdict with a review token → allow-without-marker) — cite **VP-HOOK-026** (over-label legs, SM-32b).
   (b) The STEP 5 deterministic upgrade of an under-labeled hard-floor verdict to create-review/comment-review
   (or error-artifact+deny when no `jira_project_key`) with an UNDER-LABEL-CORRECTED audit entry — cite
   **VP-HOOK-029** (under-label fail-loud vectors, SM-32a).
2. **BC-10.01.001 v1.9 Inv#10 — narrowed under-label semantics.** Inv#10 (hard floor → create-review/
   comment-review, and STEP 5 fail-loud-upgrades under-labeled hard-floor verdicts, never silent `none`)
   — confirm **VP-HOOK-029** remains its anchor (the fail-loud guarantee) and **VP-HOOK-026** the
   over-label gate. No new VP; no renumbering.
3. **VP-INDEX.md + verification-coverage-matrix.md:** re-scope the **VP-HOOK-029** entry from the pass-4
   happy-path scope to the under-label fail-loud scope (fix-priority P0), and add the **VP-HOOK-026**
   over-label legs. Record **SM-32** as split into **SM-32a** (under-label, VP-HOOK-029) and **SM-32b**
   (over-label, VP-HOOK-026). VP namespace UNCHANGED (VP-SKILL 001–072, VP-HOOK 024–029).

**G. Corrections required by v1.9 (pass-6: VP-HOOK-029 FINALIZE + kill-switch-on vectors,
consumer STEP 6a, VP-SKILL-065 re-scope, VP-SKILL-073 late-event, VP-SKILL-074 severity normalization,
SM-32-ext / SM-36 / SM-37).** *(PARTIALLY SUPERSEDED — the STEP-4 marker-UPGRADE mechanism below is RETIRED
at v1.10; ADV-F2-P7-001 replaces it with STEP-4 DENY-THE-WRITE. The consumer STEP 6a, VP-SKILL-065 carve-out,
VP-SKILL-073, VP-SKILL-074, and SM-36/SM-37 corrections REMAIN VALID. See Part H for the superseding v1.10
deny-the-Write cross-references and the VP-HOOK-029 end-to-end re-scope.)* The BODY updates — the
disposition-guard STEP REORDER (STEP 4 under-label upgrade before STEP 5 kill switch), the consumer STEP 6a anti-fungibility cross-check + the create-review
`command_pattern` `--label` addition, the Inv#11 Option-A carve-out, the D-DEC-013 severity-normalization
step, and the D-DEC-002 late-event detection — are owned by the product-owner per architecture-delta v1.9
§8.14 (BC-3.03.001 STEP reorder + pattern; BC-3.01.001 consumer STEP 6a; BC-10.01.001 Inv#11 carve-out +
VP-SKILL-065 re-scope + severity normalization + late-event). I do NOT edit the BCs. FV-side
cross-references the PO should reflect (live-BC targets: **BC-3.01.001 v1.18, BC-3.03.001 v1.15,
BC-10.01.001 v1.11**):
1. **BC-3.03.001 v1.15 Inv#4 emitter — STEP REORDER + STEP 4 upgrade + create-review pattern.** (a) The
   STEP 4 under-label upgrade now runs BEFORE the STEP 5 `autonomy_enabled` kill switch (ADV-F2-P6-002) —
   cite **VP-HOOK-029** (under-label fail-loud + kill-switch-ON under-label vectors, SM-32a + SM-32-ext).
   (b) The create-review `command_pattern` now carries `--label (REVIEW-REQUIRED|BLIND-SPOT)` in fixed
   second position after `--project <key>` — cite **VP-HOOK-024** (consumer STEP 6a anti-fungibility).
2. **BC-3.01.001 v1.18 — consumer STEP 6a anti-fungibility (P6-001 / EC-023).** Cite **VP-HOOK-024** for
   the both-direction cross-check (create-review marker refused for a no-`--label` command; create marker
   refused for a `--label` command; correct pairings consume) and the create-review pattern `--label` add.
3. **BC-10.01.001 v1.11 — Inv#10/11 + Stage-1.** (a) Inv#10 STEP 4 fail-loud (reordered before the kill
   switch) — confirm **VP-HOOK-029** FINALIZED (was PROPOSED) is its anchor. (b) Inv#11 Option-A carve-out
   ("under `autonomy_enabled=false`, zero REGULAR markers/writes; create-review/comment-review escalation
   writes for genuine hard-floor verdicts still execute") — cite **VP-SKILL-065** (RE-SCOPED, PROPOSED).
   (c) Stage-1 severity normalization (field 13, D-DEC-013) — add **VP-SKILL-074** as VP anchor + VP-table
   row (namespace-corrected from the architect's "VP-SKILL-072"). (d) Stage-1 late-event fail-loud
   (D-DEC-002 `DETECT_LATE_EVENT`) — add **VP-SKILL-073** as VP anchor + VP-table row.
4. **VP-INDEX.md + verification-coverage-matrix.md:** (a) **FINALIZE VP-HOOK-029** (PROPOSED → FINALIZED,
   P0) with the kill-switch-on under-label vectors. (b) **RE-SCOPE VP-SKILL-065** (FINALIZED → PROPOSED,
   Option-A carve-out). (c) register **VP-SKILL-073** (P1, PROPOSED, next-free 073) and **VP-SKILL-074**
   (P1, PROPOSED, next-free 074 — NOT 072, which is occupied). (d) add mutants **SM-32-ext** (under the
   SM-32 family), **SM-36**, **SM-37** (NOT SM-33/SM-34, which are occupied pass-4 sentinels). VP namespace
   now VP-SKILL 001–074, VP-HOOK 024–029; SM 9–37. No renumbering of any existing VP or SM.

**H. NEW corrections required by this v1.10 (pass-7: STEP-4 DENY-THE-WRITE redesign + VP-HOOK-029 end-to-end
re-scope + step-6a structural fix + Cyberint mapping + O4 standing rule; SM-38 / SM-39 / SM-40).** The BODY
updates — the disposition-guard STEP-4 DENY-THE-WRITE (marker-upgrade RETIRED), the consumer step-6a
`structural_label_check`, the D-DEC-013 explicit Cyberint conservative default, and the six stale
"no marker for hard floor" locations (EC-015/016/017/021 + two canonical test vectors — P7-002) — are owned
by the product-owner per architecture-delta v1.10 §8.16. I do NOT edit the BCs. FV-side cross-references the
PO should reflect (live-BC targets: **BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12**):
1. **BC-3.03.001 v1.16 Inv#4 emitter — STEP 4 DENY-THE-WRITE (upgrade RETIRED).** (a) The under-labeled
   hard-floor verdict is now DENIED at STEP 4 with a structured corrective reason (`hard_floor_trigger`,
   `required_token`, `label_instruction`, `instruction`) + an `UNDER-LABEL-DENIED` audit entry (NO marker;
   `UNDER-LABEL-CORRECTED` RETIRED) — cite **VP-HOOK-029** (deny-path + machine-actionable-reason vectors;
   SM-38, SM-39, re-targeted SM-32a, SM-32-ext). STEP 4 remains before the STEP 5 kill switch.
2. **BC-3.01.001 v1.19 — consumer step-6a structural token check + review-token acceptance.** (a) Consumer
   step-6a `structural_label_check` (`--label` as a standalone token preceding REVIEW-REQUIRED/BLIND-SPOT,
   not a raw substring over the whole command) — cite **VP-HOOK-024** (false-deny-prevention vector; SM-40).
   (b) Consumer step (6) acceptance of `create-review`/`comment-review` tokens is the CONSUMER-BOUNDARY
   surface for VP-HOOK-029's end-to-end assertion (the escalation jr write is authorized AND consumable) —
   cite **VP-HOOK-029** (consumer-boundary vectors).
3. **BC-10.01.001 v1.12 — Inv#10 + Stage-1 + six stale locations.** (a) Inv#10 STEP-4 DENY-THE-WRITE
   (reordered before the kill switch) — confirm **VP-HOOK-029** (re-scoped end-to-end, re-FINALIZED P0) is
   its anchor; the fail-loud guarantee is now the CONSUMER-BOUNDARY jr authorization/execution outcome per
   the O4 standing rule (§0), NOT an emitter-local marker. (b) The loop re-document obligation on a STEP-4
   deny (re-issue the Write with `required_token`) — VP-HOOK-029's corrected-rewrite happy-path vector is its
   verification. (c) The six pre-D-DEC-012 "no marker for hard floor" locations (EC-015/016/017/021 + two
   canonical test vectors, P7-002 CRITICAL) that a story-writer/FV could otherwise encode as the
   silent-discard bug — confirm they are updated to the post-D-DEC-012 semantics before any test authoring;
   VP-HOOK-029's negative assertion (a hard-floor verdict must NOT leave the marker dir empty with no
   deny/audit, and must NOT hold an unconsumable marker) is the guard. (d) Stage-1 field-13 Cyberint mapping
   (D-DEC-013 explicit CRITICAL + uncertainty_explicit) — cite **VP-SKILL-074** (Cyberint partition).
4. **VP-INDEX.md + verification-coverage-matrix.md:** (a) **RE-SCOPE + re-FINALIZE VP-HOOK-029** (re-marked
   PROPOSED, then FINALIZED P0) to the end-to-end consumer-boundary deny-the-Write scope (O4); mark the three
   v1.9 upgrade-marker vectors + the UNDER-LABEL-CORRECTED audit assertion RETIRED (reason "mechanism removed
   ADV-F2-P7-001"). (b) update the **VP-HOOK-024** entry for the step-6a structural false-deny vector and the
   **VP-SKILL-074** entry for the Cyberint partition. (c) add mutants **SM-38** (step4-deny-removed), **SM-39**
   (deny-corrective-reason-removed), **SM-40** (has_review_label-raw-substring); record SM-32a RE-TARGETED and
   SM-32-ext kill vector RE-WORDED. (d) codify the **O4 standing rule** (§0). VP namespace UNCHANGED at
   VP-SKILL 001–074, VP-HOOK 024–029; SM now 9–40 (occupancy re-verified before allocation, Lesson 8). No
   renumbering of any existing VP or SM.

**I. NEW corrections required by this v1.11 (pass-8: STEP-3 `HARD-FLOOR-UNBINDABLE` deny + quote-aware
tokenizer + EC-023 step-5 correction; SM-41 / SM-42).** The BODY updates — the disposition-guard STEP-3
DENY-THE-WRITE for missing binding fields, the consumer step-6a quote-aware `structural_label_check`, the
EC-023/EC-024 corrections, and the Cyberint operator notes — are owned by the product-owner per
architecture-delta v1.11 §8.18 (edited in parallel). I do NOT edit the BCs. FV-side cross-references the PO
should reflect (live-BC post-pass-8 (version-coherence sweep applied burst-4): **BC-3.01.001 v1.20, BC-3.03.001 v1.17, BC-10.01.001
v1.13**):
1. **BC-3.03.001 Inv#4 emitter — STEP 3 `HARD-FLOOR-UNBINDABLE` DENY-THE-WRITE (P8-001 CRITICAL).** Both
   silent `emit allow without marker; RETURN` branches (create-review + null `jira_project_key`;
   comment-review + null `ticket_id`) are replaced with a deny + `HARD-FLOOR-UNBINDABLE` audit entry naming
   `missing_field`, per D-DEC-012 clause 2 (comment-review adds a create-review fallback hint when
   `jira_project_key` is present) — cite **VP-HOOK-029** (unbindable-deny vectors 9–11; SM-41). Bounded
   fail-closed non-termination (one audit entry + one deny per re-doc attempt, no Jira write).
2. **BC-3.01.001 consumer step-6a — quote-aware tokenizer (P8-002 MAJOR).** `structural_label_check` uses a
   state-machine tokenizer (UNQUOTED/IN_SINGLE/IN_DOUBLE), NOT `split_on_whitespace`; a `--label` literal
   inside a quoted `--summary` value is a single token → `has_review_label=false` → ALLOW. EC-024 reconciled
   to this mechanism — cite **VP-HOOK-024** (quoted-form false-deny vector; SM-42, separately killable from
   SM-40).
3. **BC-3.01.001 EC-023 direction A + create generation-table note — step-5 correction (P8-003 MINOR).** Bash
   `[[ =~ ]]` is NOT tail-anchored; the regular create pattern PASSES step 5 for a review-labeled create
   (`( |$)` guards only against project-KEY prefix extension). Anti-fungibility direction A is enforced
   EXCLUSIVELY at step-6a — cite **VP-HOOK-024** (SM-36/SM-37 both directions; the step-6a family is
   P0-adjacent/non-redundant). No verification-delta current-body assertion made the false step-5 claim; this
   is a BC/architecture-delta text correction.
4. **VP-INDEX.md + verification-coverage-matrix.md:** (a) EXTEND (do NOT re-scope) the **VP-HOOK-029** entry
   with the P8-001 STEP-3 unbindable-deny vectors — it stays FINALIZED P0. (b) EXTEND the **VP-HOOK-024**
   entry — the step-6a false-deny vector is updated to the QUOTED form. (c) add mutants **SM-41**
   (step3-create-review-unbindable-allow-reverted) and **SM-42**
   (structural_label_check-non-quote-aware). (d) note the SM-36/37/40/42 step-6a family is P0-adjacent
   (sole anti-fungibility enforcement point). SM now 9–42 (occupancy re-verified before allocation, Lesson 8).
   No renumbering of any existing VP or SM.

**J. NEW corrections required by this v1.12 (pass-9: escaped-quote tokenizer partition + dedup-before-fallback
gate + O5 codification; SM-43).** The BODY updates — the disposition-guard/consumer STEP-6a backslash-aware
`structural_label_check`, the D-DEC-005 sensor-health carve-out, the STEP-3 comment-review dedup-before-fallback
obligation, the `jira_project_key` Stage-0 precondition + re-doc cap — are owned by the product-owner per
architecture-delta v1.12 §8.20 (edited in parallel). I do NOT edit the BCs. FV-side cross-references the PO
should reflect (post-pass-9 targets per architecture-delta §8.20 (version-coherence sweep applied burst-5): **BC-3.01.001 v1.21**, **BC-8.02.001 v1.3**,
**BC-10.01.001 v1.14**, **BC-6.01.001 v1.6**):
1. **BC-3.01.001 consumer step-6a — backslash-aware tokenizer (P9-001 MAJOR).** `structural_label_check` must
   treat `\"` in IN_DOUBLE as a literal `"` (STAY IN_DOUBLE) and `\'` in UNQUOTED as a literal `'` (NO IN_SINGLE
   toggle), matching bash argument parsing (index-based iteration replaces the for-char loop). This closes the
   escaped-quote desync where a `\"` inside `--summary` prematurely closed the quoted region and swallowed a
   REAL trailing `--label REVIEW-REQUIRED` (has_review_label=false → fungibility bypass). Cite **VP-HOOK-024**
   (escaped-quote partition 1a/1b/partition-2; SM-43, separately killable from SM-40/SM-42). Equals-form
   `--label=VALUE` SCOPED OUT (jr has no equals form, confirmed 2026-07-21).
2. **BC-10.01.001 STEP-3 comment-review fallback — dedup-before-create-review gate (P9-007 MINOR).** The
   comment-review + null-`ticket_id` + present-`jira_project_key` deny reason's fallback hint must instruct the
   loop to re-run the §3.4 BLIND-SPOT/REVIEW-REQUIRED dedup query for the (org_slug, sensor_id) BEFORE switching
   to `create-review` — a null `ticket_id` may be a dedup-lookup MISS, and a dedup HIT must produce a COMMENT on
   the existing ticket, NOT a duplicate `create-review` (D-DEC-004 one-open-ticket). Cite **VP-HOOK-029**
   (dedup-gate vector 12, test-only, no mutant) + **VP-SKILL-068** (loop-side dedup-HIT→comment behavior).
3. **BC-8.02.001 / BC-10.01.001 Inv#1 — D-DEC-005 sensor-health carve-out (P9-005 MINOR, PO-owned).** No FV VP
   change required — `prism_sensor_health` metadata queries are exempt from the raw-data org_slug isolation rule
   (VP-SKILL-064/069/070 continue to assert org_slug scope for raw per-tenant sensor-data queries only;
   sensor-metrics VP-SKILL-056 is unaffected). Recorded here for cross-reference completeness; no VP re-scope.
4. **BC-6.01.001 Stage-0 + BC-10.01.001 re-doc cap (P9-008 OBS, PO-owned).** No FV VP change this pass — the
   `jira_project_key` Stage-0 precondition and the max-3 HARD-FLOOR-UNBINDABLE re-doc cap are loop/activate BODY
   obligations. When F6 sizes the cap, VP-HOOK-029's bounded-non-termination leg may be extended to assert the
   `HARD-FLOOR-LIVELOCK-ABORT` operator-facing artifact after the cap; flagged for F6, not allocated now.
5. **VP-INDEX.md + verification-coverage-matrix.md:** (a) EXTEND (do NOT re-scope) the **VP-HOOK-024** entry with
   the P9-001 escaped-quote differential-vs-bash partition — it stays FINALIZED; mark it the O5 compliance
   artifact for `structural_label_check`. (b) EXTEND the **VP-HOOK-029** entry with the P9-007 dedup-gate
   test-only vector — it stays FINALIZED P0. (c) add mutant **SM-43** (step6a-in_double-backslash-escape-reverted).
   (d) note the step-6a family is now SM-36/37/40/42/43 (all P0-adjacent, sole anti-fungibility gate). SM now
   9–43 (occupancy re-verified before allocation, Lesson 8). No renumbering of any existing VP or SM. (e) codify
   the **O5 standing rule** (§0). VP namespace UNCHANGED at VP-SKILL 001–074, VP-HOOK 024–029.

**K. NEW corrections required by this v1.13 (pass-10: STEP 1a SEVERITY-MISMATCH + 17-field schema + WRITE_MARKER
review-path fail-closed + D-DEC-005 carve-out tightening + operator-boundary + O6 codification; VP-HOOK-030,
VP-SKILL-075, SM-44/SM-45).** The BODY updates — the disposition-guard STEP 1a re-normalization, the 17-field
verdict schema (fields 16/17 `native_severity`/`sensor_family`), the WRITE_MARKER review-path
`MARKER-WRITE-FAILED` fail-closed branch, the cron-wrapper Gate 2, the D-DEC-005 carve-out predicate
tightening, ASM-015, and the D-DEC-012 O3-table O6 row — are owned by the product-owner/architect per
architecture-delta v1.13 §8.22/§8.23 (edited in parallel). I do NOT edit the BCs. FV-side cross-references the
PO should reflect (post-pass-10 targets, PO-owned; exact numbers reconciled by the dedicated version-coherence
sweep):
1. **BC-3.03.001 disposition-guard STEP 1 + STEP 1a (P10-001 CRITICAL).** (a) `validate_enums()` STEP 1 now
   also requires field 16 `native_severity` (non-empty string) and field 17 `sensor_family` (enum
   ∈{crowdstrike,armis,claroty,cyberint}) — cite **VP-HOOK-025** (fields-16/17 presence legs) and
   **VP-HOOK-030** (the STEP-1 inputs to STEP 1a). (b) STEP 1a re-runs `NORMALIZE_SEVERITY(native_severity,
   sensor_family)`; `recomputed_severity != verdict.severity` → `SEVERITY-MISMATCH` audit + deny;
   `hard_floor_applies()` keys on `recomputed_severity` — cite **VP-HOOK-030** (per-family under-report vectors;
   SM-44). This is the O6 compliance artifact (§0).
2. **BC-3.03.001 WRITE_MARKER review-path fail-closed (P10-003 MAJOR).** On the STEP-3 create-review/comment-review
   (hard-floor review) path, a `write_marker` failure → `MARKER-WRITE-FAILED` audit + deny (mirrors
   HARD-FLOOR-UNBINDABLE, D-DEC-012 clause 2); the regular (comment/create/assign) path retains
   allow-without-marker — cite **VP-HOOK-029** (marker-write fail-closed vectors 13/14 + regular-path control 14a;
   SM-45). Bounded fail-closed; NEVER a silent hard-floor drop on the review path.
3. **BC-10.01.001 17-field verdict schema + Inv#9 + Inv#10 (P10-001).** Inv#9 field list is now **17 fields** (12
   ICD-203 + severity[13] + asset_type[14] + ticket_action_type[15] + native_severity[16] + sensor_family[17]);
   Inv#10 hard floor keys on the hook-recomputed severity (VP-HOOK-030), NOT raw `verdict.severity` — remove the
   "the LLM cannot bypass / definitive enforcement surface" language for LLM-supplied severity. asset_type
   cross-validation is ASM-008-DEFERRED (documented residual). Cite **VP-HOOK-025/030**.
4. **BC-10.01.001 Inv#1 + D-DEC-005 carve-out tightening (P10-006/P10-007 MINOR).** The `prism_sensor_health`
   org_slug exemption is scoped to the SOLE-table case (no JOIN/subquery/CTE against a raw per-tenant table) —
   cite **VP-SKILL-064** with the renamed/added @test names (`rejects unscoped RAW-TABLE PrismQL query`,
   `allows unscoped prism_sensor_health query (D-DEC-005 carve-out)`, `rejects prism_sensor_health JOIN raw-table
   query without org_slug (P10-006 boundary)`).
5. **BC-9.01.001 scan-threats org_slug — VP-SKILL-059 behavioral upgrade (P10-005 MINOR).** VP-SKILL-059 is
   upgraded from structural-only to behavioral (prism-DTU multi-org fixture: org-a hunt returns zero org-b/c rows)
   + a static assertion that every query in `data/threat-hunt-queries.md` carries an `org_slug` clause — cite
   **VP-SKILL-059** on the Iron Law + hunt-query-library invariant. SM-24 (org_slug-drop) is the paired kill target.
6. **run-monitoring-loop.sh + BC-10.01.001 PC#7 operator-boundary (P10-002 MAJOR).** The cron wrapper `exit 1`
   when `markers/audit.log` carries a fail-loud code (HARD-FLOOR-LIVELOCK-ABORT | HARD-FLOOR-UNBINDABLE |
   UNDER-LABEL-DENIED | SEVERITY-MISMATCH | MARKER-WRITE-FAILED) newer than run-start; `exit 0` on a clean run —
   cite **VP-SKILL-075** (Gate-2 vectors). **ASM-015 (BLOCKING for the Gate-1 leg):** whether a PreToolUse-hook
   deny populates `.permission_denials` under `--allowedTools` is UNVALIDATED; VP-SKILL-075's Gate-1
   `.permission_denials` leg is ASM-015-PENDING and NOT counted toward convergence until ASM-015 resolves.
   Register ASM-015 as BLOCKING for the loop stories that rely on `permission_denials` for operator signaling.
7. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register **VP-HOOK-030**
   (FINALIZED P0, next-free 030) and **VP-SKILL-075** (PROPOSED P1, next-free 075, Gate-1 leg ASM-015-BLOCKED);
   EXTEND **VP-HOOK-029** (P10-003 marker-write fail-closed vectors, +SM-45 — stays FINALIZED P0); UPGRADE
   **VP-SKILL-059** (structural→behavioral); update **VP-SKILL-064** (carve-out @test rename/adds) and **VP-HOOK-025**
   (fields 16/17). Add mutants **SM-44** (step1a-severity-renormalization-reverted) and **SM-45**
   (writemarker-review-path-allow-without-marker-reverted). Codify the **O6 standing rule** (§0). VP namespace now
   VP-SKILL 001–075, VP-HOOK 024–030; SM 9–45 (occupancy re-verified before allocation, Lesson 8). No renumbering
   of any existing VP or SM.

**L. NEW corrections required by this v1.14 (pass-11: STEP 1a consistency-only reframe + scored_priority field-18
two-field model + NVD/CVSS clean separation + separate human-comment marker path + O6 residual annotation;
VP-HOOK-031, SM-46/SM-47).** The BODY updates — STEP 1a re-framed as a consistency check, the `scored_priority`
(field 18) verdict schema extension, the `hard_floor_applies()` high-severity floor re-keyed to `scored_priority`,
the NVD/CVSS→scored_priority separation, and the separate human-comment (12-field investigation-markdown) marker
path — are owned by the product-owner/architect per architecture-delta v1.14 §8.24/§8.25 (edited in parallel). I do
NOT edit the BCs. FV-side cross-references the PO should reflect (post-pass-11 targets, PO-owned; exact numbers
reconciled by the dedicated version-coherence sweep):
1. **BC-3.03.001 disposition-guard STEP 1a — CONSISTENCY-ONLY reframe (P11-001 CRITICAL).** STEP 1a asserts
   `verdict.severity` is CONSISTENT with `verdict.native_severity` per the D-DEC-013 table — NOT ground-truth
   enforcement. Remove the "un-bypassable / hook independently derives severity from raw sensor values / genuinely
   deterministic for severity" language; `native_severity`+`sensor_family` are LLM-supplied, so genuine severity
   ground-truth is **ASM-008-DEFERRED, SYMMETRIC with the asset_type residual**. Cite **VP-HOOK-030** (downgraded to a
   consistency VP; SEVERITY-MISMATCH deny vectors retained; SM-44).
2. **BC-10.01.001 18-field verdict schema + `scored_priority` (field 18) + hard-floor re-key (P11-002 MAJOR).** Inv#9
   field list is now **18 fields** (12 ICD-203 + severity[13] + asset_type[14] + ticket_action_type[15] +
   native_severity[16] + sensor_family[17] + **scored_priority[18]** ∈{CRIT,HIGH,MED,LOW}, the Stage-5 assess-priority
   output). Inv#10 hard floor keys the HIGH/CRIT leg on `verdict.scored_priority`, NOT on recomputed severity (brief
   §3.9 "any alert scored HIGH/CRIT → human"; captures detector-LOW/scored-CRIT KEV/exposure escalations). STEP 1a
   does NOT gate recalibration; verdict.severity and scored_priority may differ. `scored_priority` is LLM-supplied —
   same ASM-008-class residual. Cite **VP-HOOK-025** (field-18 presence/enum) and **VP-HOOK-026** (scored_priority
   floor; detector-LOW/scored-CRIT; SM-46).
3. **BC-3.03.001 / D-DEC-013 NVD/CVSS clean separation (P11-003 MAJOR).** `native_severity`+`sensor_family` always
   describe the ORIGINATING SENSOR's raw reading; NVD/CVSS enrichment influences `scored_priority` (Stage-5), NOT
   `native_severity`; `sensor_family` has no `nvd` member. The pass-10 VP-HOOK-030 CVSS-float STEP-1a vector is
   REMOVED. (PO to remove the "8.5 for NVD CVSS" example from prd-delta field-16 definition — architect §8.25.)
4. **BC-3.03.001 separate human-comment marker path (P11-004 MAJOR).** The 12-field investigation-markdown path does
   NOT enter the verdict emitter; it emits a comment-scoped marker gated ONLY on 12-field completeness + the
   markdown-evaluable hard floors (Indeterminate disposition, forbidden techniques, degraded/silent sensor) — NOT
   `validate_enums()`/STEP 1a. An analyst CAN save a compliant 12-field investigation without being denied. Cite
   **VP-HOOK-031** (new; compliant-save / MARKDOWN-HARD-FLOOR / no-validate_enums-on-markdown vectors; SM-47). PO
   reconciles BC-5.01.001 Inv#7 + BC-4.02.001 PC#4 (the human-path marker) and the BC-3.03.001 Invariant #4 / PC#2
   emitter-entry contradiction per architect §8.24.
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register **VP-HOOK-031**
   (FINALIZED P0, next-free 031); DOWNGRADE **VP-HOOK-030** in place to a consistency VP (P11-001, stays FINALIZED P0);
   EXTEND **VP-HOOK-025** (field-18 `scored_priority`) and **VP-HOOK-026** (scored_priority HIGH/CRIT floor, +SM-46).
   Add mutants **SM-46** (highseverity-floor-rekeyed-to-recomputed-severity) and **SM-47**
   (markdown-routed-into-verdict-emitter). Extend the **O6 standing rule** (§0) with the consistency-vs-ground-truth
   residual annotation. VP namespace now VP-SKILL 001–075, VP-HOOK 024–031; SM 9–47 (occupancy re-verified before
   allocation, Lesson 8: `grep -rn 'SM-46\|SM-47\|VP-HOOK-031' .factory/` returned no match). No renumbering of any
   existing VP or SM.

**M. NEW corrections required by this v1.15 (pass-12: command_pattern charset-validation at 5 interpolation sites +
markdown-path four-guarantee redesign + fast-path enum map + known-FP floor exemption + O7 codification;
VP-HOOK-032, SM-48/49/50/51).** The BODY updates — ticket_id/jira_project_key charset-validation before pattern
construction, the Human-Comment Marker Path redesign (autonomy_enabled gate + disposition!=FP route-to-review), the
fast-path SEVERITY_TO_SCORED_PRIORITY_MAP, the known-FP floor exemption + store integrity, and the corrected
D-DEC-001/D-DEC-008 provenance claim — are owned by the product-owner/architect per architecture-delta v1.15
§8.26 (edited in parallel). I do NOT edit the BCs. FV-side cross-references the PO should reflect (post-pass-12
targets, PO-owned; exact numbers reconciled by the dedicated version-coherence sweep):
1. **BC-3.03.001 command_pattern charset-validation at all 5 interpolation sites (P12-001 CRITICAL / O7).** BEFORE
   constructing each `command_pattern`, validate `ticket_id` against `^[A-Z][A-Z0-9]+-[0-9]+$` (STEP 6 comment/assign,
   STEP 3 comment-review, markdown comment path) and `jira_project_key` against `^[A-Z][A-Z0-9]+$` (STEP 3
   create-review, STEP 6 create); on mismatch write `TICKET-ID-CHARSET-DENY` / `PROJECT-KEY-CHARSET-DENY` + emit deny;
   regex-escape as defense-in-depth. Cite **VP-HOOK-032** (the O7 compliance artifact; SM-48 ticket_id, SM-49
   jira_project_key). Correct the false D-DEC-001/D-DEC-008 "never derived from Jira ticket content / never supplied
   by the user" claim — ticket_id IS derived from content; metacharacter safety comes from charset-validation +
   regex-escaping, not a false provenance claim (architect §8.26.1 items 1/3).
2. **BC-3.03.001 Human-Comment Marker Path four-guarantee redesign (P12-002 CRITICAL).** Add the `autonomy_enabled`
   gate as the FIRST check on the markdown path (absent/≠true → allow-without-marker); add the `disposition != FP` →
   route-to-review rule (create-review/comment-review, NOT an autonomous comment); disposition=FP → comment marker;
   ticket_id charset-validated (P12-001). Correct the VP-HOOK-031 scope annotation in BC-3.03.001 to the four
   guarantees (kill switch / disposition routing / ticket_id charset / masquerade-bypass-removed). Cite **VP-HOOK-031**
   (UPDATED; SM-50 kill-switch, SM-51 disposition-routing). PO reconciles BC-5.01.001 / BC-4.02.001 human-comment path
   consumers (architect §8.26.1 item 2).
3. **BC-10.01.001 fast-path enum map + known-FP floor exemption (P12-003 MAJOR).** field 18: on the known-FP fast-path
   (Stage 5 bypassed), `scored_priority` is set from `NORMALIZE_SEVERITY` output mapped through the canonical
   `SEVERITY_TO_SCORED_PRIORITY_MAP` (CRITICAL→CRIT, MEDIUM→MED, HIGH→HIGH, LOW→LOW); a raw assignment produces
   non-members → validate_enums deny of 30–40% of known-FP volume. EC-009 must state the known-FP fast-path is EXEMPT
   from the §3.9 scored_priority floor when (a) sensor healthy, (b) no forbidden technique, (c) disposition=FP; add
   known-FP store integrity invariants (store NOT LLM-writable; privileged-admin + audit for changes; staleness
   review). Cite **VP-HOOK-025** (fast-path enum-map, no mutant) and **VP-HOOK-026** (floor exemption, no mutant)
   (architect §8.26.2 items 1/2).
4. **P12-004/P12-005/P12-006 (PO-owned, NOT FV).** BC-4.05.001 producer field rename (`priority` IS field 18
   `scored_priority`, §8.26.3); BC-6.01.003 Inv#6 + revision-history mis-anchor "BC-6.01.001 Invariant #12" →
   "Postcondition #12" (§8.26.4); BC-8.02.001 Traceability "org_slug scoping on all prism queries" →
   "on raw per-tenant tables; prism_sensor_health carve-out per Invariant #2" (§8.26.5). These are BC-only reference
   corrections; no FV VP/SM impact.
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** register **VP-HOOK-032**
   (FINALIZED P0, next-free 032 — the O7 command_pattern interpolation-safety compliance artifact); UPDATE
   **VP-HOOK-031** in place to the P12-002 four-guarantee scope (no new id, +SM-50/SM-51); EXTEND **VP-HOOK-025**
   (fast-path SEVERITY_TO_SCORED_PRIORITY_MAP enum vectors) and **VP-HOOK-026** (known-FP floor exemption). Add mutants
   **SM-48** (ticket_id-charset-validation-removed), **SM-49** (jira_project_key-charset-validation-removed), **SM-50**
   (markdown-kill-switch-gate-removed), **SM-51** (markdown-disposition-route-to-review-removed). Add the **O7 standing
   rule** (§0) — command_pattern / authorization-regex interpolation must be charset-validated to a fixed grammar
   (fail-closed) AND regex-escaped; every interpolation site needs a covering VP with a metacharacter-injection mutant
   (5 command_pattern sites covered by VP-HOOK-032; org_slug audit-only/SAFE). VP namespace now VP-SKILL 001–075,
   VP-HOOK 024–032; SM 9–51 (occupancy re-verified before allocation, Lesson 8:
   `grep -rn 'SM-48\|SM-49\|SM-50\|SM-51\|VP-HOOK-032' .factory/` returned no match). No renumbering of any existing
   VP or SM.

**N. NEW corrections required by this v1.16 (pass-13: MARKDOWN_COMMENT_PATH elimination + strict parse grammar +
historical-total annotation + PRISMDEMO sweep; VP-HOOK-031 UPDATED in place, SM-52/SM-53).** The BODY updates —
MARKDOWN_COMMENT_PATH elimination (the markdown path issues NO autonomous comment marker for any disposition;
FP→allow-without-marker; non-FP/PARSE_FAIL→review), the strict `parse_disposition_from_markdown` /
`parse_autonomy_enabled_from_markdown` grammar, the PC#2 prose update, the demo-key rename, and the setup-time
jira_project_key validation — are owned by the product-owner/architect per architecture-delta v1.16 §8.28 (edited in
parallel). I do NOT edit the BCs, the brief, or STATE.md. FV-side cross-references the PO should reflect (post-pass-13
targets, PO-owned; exact numbers reconciled by the dedicated version-coherence sweep):
1. **BC-3.03.001 MARKDOWN_COMMENT_PATH ELIMINATED (P13-001 CRITICAL / architecture-delta §8.28.1).** The markdown
   (Human-Comment) path MUST NEVER issue an autonomous `["comment"]` marker for ANY disposition. After the
   markdown-evaluable floors pass: `parsed_disposition == FP` → allow-without-marker (Write succeeds, no Jira action,
   no comment marker); ELSE (non-FP/PARSE_FAIL) → create-review/comment-review (MARKDOWN-HARD-FLOOR-UNBINDABLE deny if
   no ticket_id and no jira_project_key; kill-switch-exempt). Update the VP-HOOK-031 scope annotation in BC-3.03.001 to
   guarantee (c) REWRITTEN — "no disposition yields an autonomous comment marker; FP→allow-without-marker;
   non-FP/PARSE_FAIL→review." Cite **VP-HOOK-031** (UPDATED; +SM-52 markdown-fp-comment-marker-revert; SM-50/SM-51
   remain valid with shifted killer vectors).
2. **BC-3.03.001 strict parse grammar (P13-003 MAJOR / architecture-delta §8.28.1).** `parse_disposition_from_markdown`
   reads ONLY the canonical `Disposition` heading value against the {TP,FP,BTP,Indeterminate}(+long-form) allowlist —
   PARSE_FAIL on ambiguous/negated/multi-valued/empty/missing/embedded-in-code-fence → treated as non-FP (review,
   never allow-without-marker); `parse_autonomy_enabled_from_markdown` reads ONLY a dedicated structured field,
   true only on explicit boolean-true (token in a code fence/evidence block → false). Cite **VP-HOOK-031** adversarial
   parse-grammar vectors + **SM-53** (markdown-disposition-full-document-substring-scan).
3. **BC-3.03.001 Postcondition #2 prose update (P13-004 MINOR / architecture-delta §8.28.1).** PC#2 must be updated to
   reflect GATE 1 kill switch + the no-autonomous-comment routing (post-P13-001); cross-ref updated from '(P11-004)' to
   '(P11-004 / P12-002 / P13-001)'. BC-only reference correction; no FV VP/SM impact.
4. **BC-6.01.001 (activate) + BC-6.01.003 (onboard-customer) setup-time jira_project_key validation (P13-002 CRITICAL /
   architecture-delta §8.28.3/§8.28.4).** Any configured jira_project_key MUST be validated against `^[A-Z][A-Z0-9]+$`
   at setup time (fail-early with a user-facing error) — the demo key is corrected PRISM-DEMO → **PRISMDEMO**. These are
   PO-owned BC + brief edits (the brief PRISMDEMO rename is human-authorized); no FV VP/SM impact beyond the
   verification-delta PRISMDEMO vector-example sweep (done — 17 occurrences).
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** UPDATE **VP-HOOK-031** in place
   (guarantee (c) rewrite — MARKDOWN_COMMENT_PATH eliminated, P13-001 — + strict parse-grammar adversarial vectors,
   P13-003; no new VP id). Add mutants **SM-52** (markdown-fp-comment-marker-revert) and **SM-53**
   (markdown-disposition-full-document-substring-scan); SM-50/SM-51 remain valid. VP namespace UNCHANGED at
   VP-SKILL 001–075, VP-HOOK 024–032; SM 9–53 (occupancy re-verified before allocation, Lesson 8:
   `grep -rn 'SM-52\|SM-53' .factory/` returned no match — SM-2026 a date FP, SM-456 the 'PRISM-456' charset example,
   neither a mutant). No renumbering of any existing VP or SM.

**O. NEW corrections required by this v1.17 (pass-14: setup-time jira_project_key charset-validation VP (P14-002) +
VP-repurposing annotation (P14-005) + NVD sweep (P14-001 propagation); NEW VP-SKILL-076 + SM-54).** The BODY updates —
the setup-time `jira_project_key` charset validation on the activate + onboard-customer setup flows, and the
BC-6.01.003 Inv#1 AD-017 VP anchor — are owned by the product-owner per architecture-delta v1.17 §8.30 items
8.30.5/8.30.6 (edited in parallel); state-manager annotates spec-changelog [1.1.0] per §8.30.8. I do NOT edit the BCs,
the brief, prd-delta, spec-changelog, or STATE.md. FV-side cross-references the PO should reflect (post-pass-14
targets, PO-owned; exact numbers reconciled by the dedicated version-coherence sweep):
1. **BC-6.01.001 (activate PC#12/EC-014) + BC-6.01.003 (onboard-customer Inv#6/EC-010) setup-time jira_project_key
   charset validation (P14-002 MAJOR / architecture-delta §8.30.6).** The setup-time charset gate added by P13-002 now
   has a covering VP: **VP-SKILL-076** asserts `activate` AND `onboard-customer` BOTH REJECT a `jira_project_key` not
   matching `^[A-Z][A-Z0-9]+$` at setup time (user-facing error, NO partial-state write, fail-EARLY); a conformant key
   (e.g. `PRISMDEMO`) is accepted. Cite **VP-SKILL-076** (PROPOSED, P1) + **SM-54** (setup-time-charset-validation-removed
   → hyphenated key stored → runtime PROJECT-KEY-CHARSET-DENY / HARD-FLOOR-UNBINDABLE livelock). DISTINCT from
   VP-HOOK-032 (the RUNTIME command_pattern deny — a separate call-site).
2. **BC-6.01.003 Inv#1 / EC-008 AD-017 VP anchor (P14-005 MINOR / architecture-delta §8.30.5).** VP-SKILL-053 was
   repurposed (was onboard-customer AD-017 credential-provisioning → now idempotent-directory-creation), leaving Inv#1/EC-008
   without a covering VP. The onboard-customer AD-017 credential-provisioning acceptance is now anchored by the PO's
   burst-10 BC-6.01.003 Inv#1 anchor (references VP-SKILL-054 pattern inheritance and/or the new VP-SKILL-076 setup-time
   gate). FV records the repurposing on the §2 VP-SKILL-053 / VP-SKILL-057 roster rows (see §2) so the ID-meaning change
   is auditable; no FV VP re-scope beyond the annotation.
3. **VP-repurposing roster annotation (P14-005 MINOR / architecture-delta §8.30.7 — MY doc, done directly).** §2 VP table
   rows annotated inline: **VP-SKILL-053** `[originally: onboard-customer AD-017 credential-provisioning; repurposed pass-14
   / P14-005 → now idempotent-directory-creation]`; **VP-SKILL-057** `[originally: sensor-metrics org_slug scoping;
   repurposed pass-9 / P9-005 → now sensor-metrics naming-compliance (D-DEC-006)]` (sensor-metrics org_slug scoping is moot
   under the D-DEC-005 / P9-005 sensor-health carve-out). state-manager mirrors these on the spec-changelog [1.1.0] VP table
   per §8.30.8 — outside FV's edit scope.
4. **NVD/CVSS sweep (P14-001 propagation — MY doc, done directly).** Confirmed P11-003 already removed VP-HOOK-030's
   CVSS-float STEP-1a vector. Corrected the residual: removed the `CVSS 4.0/7.0/9.0` NORMALIZE_SEVERITY family boundaries
   from VP-SKILL-074 (§2 row + §6 note + §5 BC-10.01.001 row, −2 BATS) and corrected SM-44's stale `(1)–(5)` / `CVSS 9.5+MEDIUM`
   killer-vector reference to `(1)–(4)`. NORMALIZE_SEVERITY is authoritative ONLY over sensor_family ∈ {crowdstrike, armis,
   claroty, cyberint} (P14-001 / D-DEC-013); NVD/CVSS is NOT a sensor_family and feeds `scored_priority` (field 18) at Stage 5,
   NOT `native_severity`. The §6 clean-separation claim is now TRUE. No BC change owed by FV.
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration):** ADD **VP-SKILL-076** (setup-time
   jira_project_key charset validation, PROPOSED, P1) and mutant **SM-54** (setup-time-charset-validation-removed). Annotate
   VP-SKILL-053 / VP-SKILL-057 as repurposed. VP namespace now **VP-SKILL 001–076**, VP-HOOK 024–032; SM 9–**54** (occupancy
   re-verified before allocation, Lesson 8: `grep -rn 'VP-SKILL-076\|SM-54' .factory/` returned no match — SM-2026 a date FP,
   SM-456 the 'PRISM-456' charset example, neither a mutant). No renumbering of any existing VP or SM.

**P. NEW corrections required by this v1.18 (VP-SKILL-076/077 disentanglement — targeted coherence correction of the burst-10
conflation).** The burst-10 pass-14 remediation left **VP-SKILL-076 ambiguously cited for TWO distinct behaviors** —
(P14-002) setup-time `jira_project_key` charset-validation AND (P14-005) onboard-customer AD-017 credential-decline coverage.
One VP id covering two unrelated behaviors is precisely the anti-pattern P14-005 itself flagged; this edit disentangles them.
FV-side changes (all within MY doc — §1, §2, §4, §5; done directly) and the PO cross-reference the disentanglement implies:
1. **VP-SKILL-076 kept SCOPED STRICTLY to P14-002 (MY doc).** VP-SKILL-076's definition remains the setup-time
   `jira_project_key` charset gate ONLY (activate BC-6.01.001 PC#12/EC-014 + onboard-customer BC-6.01.003 Inv#6/EC-010 reject a
   non-`^[A-Z][A-Z0-9]+$` key at setup, no partial-state write; conformant key accepted); paired mutant SM-54 unchanged. No
   AD-017 / credential-decline / P14-005 language attaches to VP-SKILL-076 — it is ONLY the Jira project-key charset gate.
2. **NEW VP-SKILL-077 (P14-005, MY doc).** Onboard-customer AD-017 credential-decline: onboard-customer (BC-6.01.003 Inv#1 /
   EC-008) DENIES/declines credential entry in chat (never asks for or accepts a secret in the conversation; only piped-stdin
   `echo | prism credential set` documented), mirroring the VP-SKILL-054 onboard-sensor AD-017 pattern. RESTORES the AD-017
   coverage orphaned when VP-SKILL-053 was repurposed (P14-005). Added to the §1 adjudication table, the §2 VP roster (anchor
   BC-6.01.003 Inv#1/EC-008), and the §5 BC-6.01.003 test-count row (+2 BATS). **NO paired mutant — SM-55 SKIPPED** (B-STR
   structural-presence, no control-flow gate to mutate, per the VP-SKILL-054 no-mutant precedent; not clearly killable at spec
   level, so not forced). SM catalog unchanged at 48 (SM-9..SM-54).
3. **VP-SKILL-053 repurposing annotation CORRECTED (MY doc).** The §1 and §2 rows now read that the original onboard-customer
   AD-017 coverage is **RESTORED via VP-SKILL-077** — NOT "moved to VP-SKILL-076" (the earlier phrasing was the burst-10
   conflation, since VP-SKILL-076 is the unrelated setup-time charset gate).
4. **BC-6.01.003 Inv#1 / EC-008 AD-017 anchor (P14-005 / architecture-delta §8.30.5 — PO-owned, in parallel).** The PO's
   burst-10 BC-6.01.003 Inv#1 anchor should now reference **VP-SKILL-077** as the covering VP for the AD-017 credential-decline
   behavior (previously it pointed at VP-SKILL-054 pattern inheritance and/or VP-SKILL-076). FV does NOT edit the BC; the PO
   reconciles the anchor in parallel. state-manager mirrors the VP-SKILL-077 allocation on spec-changelog [1.1.0].
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration).** ADD **VP-SKILL-077** (onboard-customer
   AD-017 credential-decline, PROPOSED, P1, no mutant). VP namespace now **VP-SKILL 001–077**, VP-HOOK 024–032; SM 9–**54**
   (UNCHANGED — SM-55 skipped; occupancy re-verified before allocation, Lesson 8: `grep -rn 'VP-SKILL-077' .factory/` returned
   no match — SM-2026 a date FP, SM-456 the 'PRISM-456' charset example, neither a mutant). No renumbering of any existing VP or SM.

**Q. NEW corrections required by this v1.19 (pass-17 remediation burst 14 — P17-001 / D-019 known-FP floor RETIRE/invert +
P17-002 VP-HOOK-028 JSON-first property-(1) rewrite).** Per architecture-delta v1.19 §8.31 items 8.31.2 (FV — VP-HOOK-028)
and 8.31.4 (FV — VP-HOOK-026 / known-FP floor). All FV-side changes are within MY doc (§0/§1 occupancy, §2 VP rows, §4 SM
catalog, §5 test-count, this §7); the PO-owned BC edits (§8.31.1 EC-009/field-18/Inv#14, §8.31.3 EC-005/L814) proceed in
parallel and are NOT touched here.
1. **P17-001 / D-019 — known-FP scored_priority floor EXEMPTION RETIRED/INVERTED (MY doc; VP-HOOK-026 EXTENDED in place).**
   The v1.15 P12-003b/D-016 "known-FP EXEMPT from the scored_priority floor → auto-close even at high native severity" vector
   is a DEAD/INCORRECT assertion under D-019 (human decision 2026-07-23): `hard_floor_applies()` fires UNCONDITIONALLY on
   `scored_priority ∈ {HIGH,CRIT}` (BC-3.03.001 L658-666 — NO known-FP branch), and disposition-guard has NO forgery-proof
   known-FP signal (the 18-field verdict is LLM-authored; an in-band `known_fp` field would be a CRITICAL O6 bypass, REJECTED;
   DI-015 bounds store integrity but does not protect a verdict field). The exemption vector is **RETIRED** (reason 'D-019:
   exemption scoped to LOW/MED only; no high-sev exemption'; history preserved, no re-run — §2 VP-HOOK-026 row + §5
   BC-10.01.001 row). Replaced with the D-019 vectors: **(a)** LOW/MED-native known-FP (`scored_priority ∈ {LOW,MED}`) +
   healthy sensor + non-forbidden technique + disposition=FP → `hard_floor_applies()`=FALSE → NO floor → AUTO-CLOSE (comment
   via the regular path); **(b)/(c)** HIGH/CRIT-native known-FP (`scored_priority ∈ {HIGH,CRIT}`) + store match + disposition=FP
   → `hard_floor_applies()`=TRUE → DENY-THE-WRITE (HARD-FLOOR-UNDER-LABEL) → routes to **comment-review (human review), NOT
   auto-close** (the deterministic gate's existing behavior; the loop re-issues as comment-review per VP-HOOK-029). Paired
   mutant **SM-56** (`hard_floor_applies()` adds a known-FP bypass branch → a HIGH/CRIT-native known-FP auto-closes instead of
   routing to review) killed by vectors (b)/(c). **NO floor-EXEMPTION VP minted** — architecture-delta §8.27 hold-note is
   RESOLVED by D-019 (there is no exemption to verify); the FV obligation is to verify the floor FIRES for high-sev known-FPs,
   discharged by SM-56 + the D-019 vectors. **hard_floor_applies() definition confirmed UNCHANGED** (fires on scored_priority
   ∈ {HIGH,CRIT} unconditionally — it was already correct per D-019; no verification artifact carries a known-FP carve-out).
2. **P17-001 — BC-10.01.001 EC-009 / field-18 note (PO-owned, in parallel; §8.31.1).** The PO corrects EC-009 and the field-18
   fast-path annotation to remove the "EXEMPT from the scored_priority floor / auto-close proceeds" language for HIGH/CRIT
   known-FPs and state the D-019 behavior (LOW/MED auto-close; HIGH/CRIT → comment-review), retaining the store-integrity
   invariants (store not LLM-writable, privileged-write-only, audit, periodic review). FV does NOT edit the BC; the verif-delta
   VP-HOOK-026 BC anchor now cites the D-019 correction.
3. **P17-002 — VP-HOOK-028 property (1) REWRITTEN + self-contradiction resolved (MY doc; VP-HOOK-028 REWRITTEN in place, NOT
   withdrawn per §8.31.2 item 4).** Property (1) asserted the now-dead "a Stage-7 Write to a path NOT containing the `verdict`
   substring → fast-path-allow WITHOUT ICD-203 validation → mis-named verdict path fail-closed" — false under JSON-first
   dispatch (a JSON verdict at ANY `.json` path, or any path whose content parses as JSON, routes to the 18-field verdict class
   and EMITS a marker regardless of the `verdict` substring), and self-contradictory with property (2) which correctly states
   JSON-first precedence. Property (1) is REWRITTEN to the ACTUAL residual fail-closed boundary: **a Write whose path has
   NEITHER a `.json` extension NOR JSON-parseable content (`jq empty` fails) NOR matches the `*investigation-*.md` glob →
   fast-path-allow WITHOUT ICD-203 validation → Stage-8 require-review DENIES the `jr` write (no marker to consume).** BATS
   vectors rewritten (§2 VP-HOOK-028 row + §5 BC-10.01.001 row): the "mis-named verdict path" vector is RETIRED (reason
   'P17-002 — dead under JSON-first dispatch'; history preserved); added (i) a genuinely-non-dispatching-path vector
   (`artifacts/notes/alert-001.txt`: no .json ext, non-JSON content, non-investigation-md → fast-path-allow → Stage-8 deny),
   (ii) a `.json`-path-without-`verdict`-substring positive vector (`artifacts/findings/alert-001.json` with valid 18-field JSON
   → JSON-first dispatch FIRES → ICD-203 validation → marker emitted, NOT fast-path-allow), (iii) a non-`.json`-path-with-JSON-
   content vector (dispatch fires). **Self-contradiction RESOLVED:** property (2) is the authoritative JSON-first dispatch rule;
   property (1) now states ONLY the fast-path-allow residual for the genuinely-non-dispatching path — consistent, no overlap.
   VP-HOOK-028 stays FINALIZED (the fail-closed boundary is real and P0-relevant; only the path-name premise was dead). No
   mutant added — the SM-34 dispatch-order sentinel already guards property (2)'s JSON-first precedence.
4. **P17-002 — BC-10.01.001 Inv#14 Stage-7 (PO-owned, in parallel; §8.31.1 item 3).** CV-009 (v1.19) rewrote PC#8 to JSON-first
   but did NOT propagate to Invariant #14 Stage-7 (still mandates the `verdict` substring, cites retired PC#8). The PO updates
   Inv#14 Stage-7 to the JSON-first trigger (`.json` extension OR JSON content) and removes the stale substring rule / PC#8
   citation. FV does NOT edit the BC.
5. **VP-INDEX.md + verification-coverage-matrix.md (formal-verifier/PO registration).** ADD mutant **SM-56**
   (known-FP-floor-bypass-branch-added, MAJOR, VP-HOOK-026). Annotate VP-HOOK-026 (known-FP floor exemption RETIRED/INVERTED,
   D-019) and VP-HOOK-028 (property (1) JSON-first rewrite). VP namespace UNCHANGED at **VP-SKILL 001–077, VP-HOOK 024–032**;
   SM 9–**56** (occupancy re-verified by a FRESH grep before allocation, Lesson 8: `grep -rn 'SM-56' .factory/` returned no
   match — SM-2026 a date FP, SM-456 the 'PRISM-456' charset example, SM-55 only appears as 'skipped'; SM-55 reserved-skipped,
   deliberately not reused to preserve its 'skipped' record). No renumbering of any existing VP or SM.

No corrections alter any invariant, EC, or postcondition semantics (the P7-002 / P8-003 / P9-001 / **P10-001-STEP-1a
/ P10-003 WRITE_MARKER / P10-006 carve-out / P11-001-consistency / P11-002-scored_priority / P11-004-human-comment-path
/ P12-001-command_pattern-charset / P12-002-markdown-path-redesign / P12-003-fast-path-enum-map+floor-exemption /
P13-001-MARKDOWN_COMMENT_PATH-eliminated / P13-003-strict-parse-grammar / P13-004-PC#2-prose+historical-total /
**P17-001-D-019-known-FP-floor-RETIRE/invert / P17-002-VP-HOOK-028-JSON-first-property-(1)-rewrite****
propagation is a PO/architect-owned text alignment consistent with the
architecture-delta v1.16 body — the schema went 15→17 (P10-001) →**18 fields** (P11-002 `scored_priority`), a
deliberate schema extension, not a drift; STEP 1a's asserted guarantee was re-scoped consistency-only per P11-001;
the command_pattern charset-validation, markdown-path redesign, and fast-path enum map are deterministic
authorization/emit-time hardenings, not semantic changes to any invariant; **v1.17 P14-002 setup-time charset validation
+ P14-005 VP-repurposing annotation + P14-001 NVD sweep are additive/coherence corrections — no invariant/EC/PC semantics
altered; **v1.18 VP-SKILL-076/077 disentanglement is a coherence correction (allocates VP-SKILL-077 for the P14-005 AD-017
credential-decline coverage and de-conflates it from VP-SKILL-076's setup-time charset gate) — no invariant/EC/PC semantics
altered**). All delta BCs are otherwise
internally consistent with the finalized **37-VP** set (VP-SKILL 001–077, VP-HOOK 024–032; v1.10/v1.11/v1.12 add no
new VP — VP-HOOK-029 extended in place, VP-HOOK-024 / VP-SKILL-074 extended; v1.13 adds VP-HOOK-030 + VP-SKILL-075
and extends VP-HOOK-029 / upgrades VP-SKILL-059 / renames VP-SKILL-064; v1.14 adds VP-HOOK-031, downgrades VP-HOOK-030
to a consistency VP, and extends VP-HOOK-025 / VP-HOOK-026; **v1.15 adds VP-HOOK-032 (O7 command_pattern
interpolation-safety), UPDATES VP-HOOK-031 to the P12-002 four-guarantee scope, and extends VP-HOOK-025 / VP-HOOK-026;
**v1.16 adds NO new VP — VP-HOOK-031 UPDATED in place (guarantee (c) rewrite — MARKDOWN_COMMENT_PATH eliminated, P13-001;
+ strict parse-grammar vectors, P13-003)**; **v1.17 adds VP-SKILL-076 (setup-time jira_project_key charset validation,
P14-002) and annotates VP-SKILL-053/057 as repurposed (P14-005); **v1.18 adds VP-SKILL-077 (onboard-customer AD-017
credential-decline, P14-005) — the VP-SKILL-076/077 disentanglement that splits the setup-time charset gate from the
AD-017 credential-decline coverage the burst-10 remediation had conflated; no mutant (SM-55 skipped)**; **v1.19 adds NO new VP —
VP-HOOK-026 EXTENDED in place (P17-001 / D-019: known-FP floor EXEMPTION RETIRED/INVERTED, +SM-56) and VP-HOOK-028 REWRITTEN
in place (P17-002: property (1) recast to the JSON-first fail-closed residual boundary, self-contradiction with property (2)
resolved)**)
and the SM-N catalog (SM-9..**SM-56**, **49 mutants** with SM-32 = SM-32a + SM-32b + SM-32-ext, **SM-55 reserved-skipped**; +SM-38/SM-39/SM-40 at v1.10; +SM-41/SM-42 at v1.11; +SM-43 at v1.12; +SM-44/SM-45 at v1.13; +SM-46/SM-47 at v1.14; +SM-48/SM-49/SM-50/SM-51 at v1.15; **+SM-52/SM-53 at v1.16; +SM-54 at v1.17; SM-55 SKIPPED at v1.18; +SM-56 at v1.19**).
Cross-doc/other-file version-ref reconciliation (prd-delta, VP-INDEX headers, inter-BC citations) is
explicitly NOT chased here — the dedicated version-coherence sweep owns global reconciliation after this
edit (ADV-F2-P3-007/P3-009).

---

*F2 Verification Delta v1.19 complete. **37 VPs** (0 collisions, 0 renumbering — VP count UNCHANGED at 37; VP-HOOK-026
EXTENDED in place + VP-HOOK-028 REWRITTEN in place, no new/renumbered VP): VP-SKILL 001–077, VP-HOOK 024–**032** (9 hooks).
**Current grand total: 37 VPs = 9 VP-HOOK (024–032) + 28 VP-SKILL (001–077).** **Pass-17 remediation burst 14 (P17-001 MAJOR
/ P17-002 MAJOR, architecture-delta v1.19 §8.31 items 8.31.2 + 8.31.4):** Namespace (Lesson 8, FRESH grep before allocation):
VP-HOOK max **032** / VP-SKILL max **077** / SM max real **54** (SM-2026 a date FP, SM-456 the 'PRISM-456' charset example,
SM-55 only 'skipped' — none a live mutant); `grep -rn 'SM-56'` returned no match → **SM-56** (next-free control-flow id;
SM-55 reserved-skipped, deliberately NOT reused to preserve its ~15-place 'skipped' record — collision-of-meaning avoided).
**(1) [P17-001 MAJOR — D-019] known-FP scored_priority floor EXEMPTION RETIRED/INVERTED (VP-HOOK-026 EXTENDED in place):** per
D-019 (human decision 2026-07-23) there is NO high-severity exemption — the v1.15 P12-003b/D-016 "known-FP EXEMPT from the
floor → auto-close even at high native severity" vector is dead/incorrect (`hard_floor_applies()` fires unconditionally on
`scored_priority ∈ {HIGH,CRIT}`; disposition-guard has no forgery-proof known-FP signal — an LLM `known_fp` field would be a
CRITICAL O6 bypass). RETIRED (reason 'D-019: exemption scoped to LOW/MED only; no high-sev exemption'; history preserved).
D-019 vectors: LOW/MED-native known-FP → NO floor → auto-close (comment via regular path); HIGH/CRIT-native known-FP →
`hard_floor_applies()` FIRES → DENY-THE-WRITE (HARD-FLOOR-UNDER-LABEL) → comment-review (human review), NOT auto-close.
Paired mutant **SM-56** (hard_floor_applies() adds a known-FP bypass branch → high-sev known-FP auto-closes) killed by the
HIGH/CRIT-known-FP→review vector. **NO floor-EXEMPTION VP minted** (arch-delta §8.27 hold-note RESOLVED by D-019 — verify the
floor FIRES, not an exemption); hard_floor_applies() confirmed UNCHANGED (already correct, no known-FP branch). **(2) [P17-002
MAJOR] VP-HOOK-028 property (1) REWRITTEN + self-contradiction resolved (VP-HOOK-028 REWRITTEN in place, NOT withdrawn):** the
dead "non-`verdict`-substring path → fast-path-allow → mis-named verdict path fail-closed" premise (false under JSON-first
dispatch) is recast to the ACTUAL residual boundary — a Write with NEITHER a `.json` extension NOR JSON-parseable content NOR
`*investigation-*.md` glob → fast-path-allow → Stage-8 jr denied (no marker). The "mis-named verdict path" vector is RETIRED
(reason 'P17-002 — dead under JSON-first'; history preserved); added a genuinely-non-dispatching-path vector + two JSON-first-
dispatch-fires positive vectors. Property (1) and (2) now consistent (property (2) = authoritative JSON-first dispatch rule;
property (1) = fast-path-allow residual for the genuinely-non-dispatching path). No mutant added (SM-34 already guards
property (2)). **(3)** VP count UNCHANGED at **37**. Mutant count 48 → **49** (+SM-56; SM-55 reserved-skipped). **49 SM-N
mutants (SM-9..SM-56, SM-32 = 32a+32b+32-ext, SM-55 reserved-skipped).** **~267 new BATS + ~104 parity ≈ ~371** test cases
(was ~367; net +4 BATS on BC-10.01.001: D-019 known-FP inversion +2 [4 D-019 vectors replace 2 retired exemption vectors];
VP-HOOK-028 property-(1) JSON-first rewrite +2 [3 added, 1 retired]). Live-BC post-pass-17 (PO-owned per architecture-delta
§8.31.1/§8.31.3, in parallel): **BC-10.01.001** (EC-009 / field-18 note D-019 correction + Inv#14 Stage-7 JSON-first
propagation) + **BC-3.03.001** (EC-005 / L814 canonical test vector MARKDOWN_COMMENT_PATH-elimination propagation, P17-003) —
outside FV's edit scope; §7 Part Q records the FV cross-references. input-hash: COMPUTE-AT-COMMIT. Governance: architecture-delta,
BCs, prd-delta, asm-004-validation, and brief untouched. Cross-doc/other-file version-ref reconciliation remains owned by the
dedicated version-coherence sweep.*

*(v1.18 record, retained for traceability.)* *F2 Verification Delta v1.18 complete. **37 VPs** (0 collisions, 0 renumbering; VP count 36 → 37 — VP-SKILL-077 NEW,
next-free): VP-SKILL 001–**077**, VP-HOOK 024–032 (9 hooks). **Current grand total: 37 VPs = 9 VP-HOOK (024–032) + 28
VP-SKILL (001–077).** **v1.18 VP-SKILL-076/077 DISENTANGLEMENT (targeted coherence correction of the burst-10 conflation):**
the pass-14 remediation left **VP-SKILL-076 ambiguously cited for TWO distinct behaviors** — (P14-002) setup-time
`jira_project_key` charset-validation AND (P14-005) onboard-customer AD-017 credential-decline — the one-id-two-behaviors
anti-pattern P14-005 flagged. This edit splits them. Namespace (Lesson 8): VP-SKILL max 076 / VP-HOOK max 032 / SM max real
54 (SM-2026 a date FP, SM-456 the 'PRISM-456' charset example — neither a mutant); `grep -rn 'VP-SKILL-077'` returned no
match → **VP-SKILL-077** (next-free). **(1)** VP-SKILL-076 kept SCOPED STRICTLY to P14-002 — the setup-time charset gate
ONLY (activate BC-6.01.001 PC#12/EC-014 + onboard-customer BC-6.01.003 Inv#6/EC-010; no partial-state write); paired mutant
SM-54 unchanged; NO AD-017 / credential-decline language attaches to it. **(2)** NEW **VP-SKILL-077** (P14-005) —
onboard-customer AD-017 credential-decline: onboard-customer (BC-6.01.003 Inv#1 / EC-008) DENIES/declines credential entry
in chat (never asks for or accepts a secret in the conversation; only piped-stdin `echo | prism credential set` documented),
mirroring VP-SKILL-054 (onboard-sensor AD-017). RESTORES the AD-017 coverage orphaned when VP-SKILL-053 was repurposed.
**NO paired mutant — SM-55 SKIPPED** (B-STR structural-presence, no control-flow gate to mutate, per the VP-SKILL-054
no-mutant precedent; not clearly killable at spec level, so not forced). **(3)** VP-SKILL-053 repurposing annotation
CORRECTED: original AD-017 coverage is now **RESTORED via VP-SKILL-077** (was incorrectly "moved to VP-SKILL-076"). **(4)**
VP count 36 → **37** (+VP-SKILL-077). Mutant count UNCHANGED at **48 (SM-9..SM-54)** — SM-55 skipped. **~263 new BATS +
~104 parity ≈ ~367** test cases (was ~365; net +2 BATS: VP-SKILL-077 credential-decline structural greps on BC-6.01.003).
§7 Part P records the disentanglement. Live-BC (PO-owned, in parallel): the PO reconciles the BC-6.01.003 Inv#1/EC-008
AD-017 anchor to reference VP-SKILL-077; state-manager mirrors on spec-changelog [1.1.0]. Governance: architecture-delta,
BCs, prd-delta, spec-changelog, asm-004-validation, and brief untouched. input-hash: COMPUTE-AT-COMMIT. Cross-doc
version-ref reconciliation remains owned by the dedicated version-coherence sweep.*

*(v1.17 pass-14 record, retained for traceability.)* *F2 Verification Delta v1.17 complete. **36 VPs** (0 collisions, 0 renumbering; VP count 35 → 36 — VP-SKILL-076 NEW,
next-free): VP-SKILL 001–**076**, VP-HOOK 024–032 (9 hooks). **Current grand total: 36 VPs = 9 VP-HOOK (024–032) + 27
VP-SKILL (001–076).** **Pass-14 remediation (P14-002 MAJOR / P14-005 MINOR, architecture-delta v1.17 §8.30 items
8.30.6/8.30.7):** Namespace (Lesson 8): VP-SKILL max 075 / VP-HOOK max 032 / SM max real 53 (SM-2026 a date FP, SM-456 the
'PRISM-456' charset example — neither a mutant); `grep -rn 'VP-SKILL-076\|SM-54'` returned no match → **VP-SKILL-076 + SM-54**
(both next-free). Collisions avoided by pre-mint grep. **(1) [P14-002 MAJOR — no-covering-VP] NEW VP-SKILL-076 —
setup-time jira_project_key charset validation:** the PREVENTIVE gate — `activate` (BC-6.01.001 PC#12/EC-014) AND
`onboard-customer` (BC-6.01.003 Inv#6/EC-010) BOTH REJECT a `jira_project_key` not matching `^[A-Z][A-Z0-9]+$` at SETUP
time, with a user-facing error and NO partial-state write (fail-EARLY); a conformant key (e.g. `PRISMDEMO`) is accepted.
DISTINCT from VP-HOOK-032 (the RUNTIME command_pattern PROJECT-KEY-CHARSET-DENY — a separate call-site). Paired mutant
**SM-54** (setup-time charset validation removed → a hyphenated `PRISM-DEMO` is stored → a downstream marker issuance then
triggers the runtime `PROJECT-KEY-CHARSET-DENY` / `HARD-FLOOR-UNBINDABLE` livelock) killed by the reject-at-setup vector,
proving the setup-time gate is not redundant with the runtime deny. Sibling of VP-SKILL-051 (VP-SKILL namespace — setup
helper, not a PreToolUse hook). **(2) [P14-005 MINOR — VP repurposing annotation]** §2 VP roster rows annotated inline:
**VP-SKILL-053** `[originally: onboard-customer AD-017 credential-provisioning; repurposed pass-14 / P14-005 → now
idempotent-directory-creation]` (AD-017 credential-provisioning acceptance coverage → BC-6.01.003 Inv#1 anchor, PO burst-10);
**VP-SKILL-057** `[originally: sensor-metrics org_slug scoping; repurposed pass-9 / P9-005 → now sensor-metrics
naming-compliance (D-DEC-006)]` (org_slug scoping moot under the D-DEC-005 / P9-005 sensor-health carve-out). onboard-customer
AD-017 (BC-6.01.003 Inv#1/EC-008) coverage: see the BC-6.01.003 Inv#1 anchor (PO burst-10) — references VP-SKILL-054 pattern
inheritance and/or the new VP-SKILL-076 setup-time gate. **(3) [NVD sweep — P14-001 propagation]** confirmed P11-003 already
removed VP-HOOK-030's CVSS-float STEP-1a vector; corrected the residual — removed the VP-SKILL-074 `CVSS 4.0/7.0/9.0`
NORMALIZE_SEVERITY family boundaries (§2 row + §6 note + §5 BC-10.01.001 row, −2 BATS) and corrected SM-44's stale
`(1)–(5)` / `CVSS 9.5+MEDIUM` reference to `(1)–(4)`. NORMALIZE_SEVERITY is authoritative ONLY over sensor_family ∈
{crowdstrike, armis, claroty, cyberint}; NVD/CVSS is NOT a sensor_family and feeds `scored_priority` (field 18) at Stage 5.
The §6 clean-separation claim is now TRUE. **(4)** VP count 35 → **36** (+VP-SKILL-076). Mutant count 47 → **48** (+SM-54).
**48 SM-N mutants (SM-9..SM-54).** **~261 new BATS + ~104 parity ≈ ~365** test cases (was ~360; net +3 BATS: +5 VP-SKILL-076
setup-time reject/accept on activate + onboard-customer, −2 VP-SKILL-074 CVSS boundary fixtures removed per the NVD sweep).
Live-BC post-pass-14 (PO-owned per architecture-delta §8.30, in parallel): **BC-6.01.001** (activate PC#12/EC-014 setup-time
validation) + **BC-6.01.003** (onboard-customer Inv#6/EC-010 setup-time validation + Inv#1/EC-008 AD-017 VP anchor) — outside
FV's edit scope; state-manager annotates spec-changelog [1.1.0] (§8.30.8). §7 Part O records the FV cross-references.
input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the dedicated
version-coherence sweep.*

*(Pass-13 record, retained for traceability.)* *F2 Verification Delta v1.16 complete. **35 VPs** (0 collisions, 0 renumbering; VP count UNCHANGED — VP-HOOK-031 UPDATED
in place): VP-SKILL 001–075, VP-HOOK 024–**032** (9 hooks). **Current grand total: 35 VPs = 9 VP-HOOK (024–032) + 26
VP-SKILL** — the pass-9 '6 VP-HOOK / grand total 31' figure at ~line 245 is a HISTORICAL snapshot, now annotated
SUPERSEDED (P13-004). **Pass-13 remediation (P13-001 CRITICAL / P13-003 MAJOR / P13-004 MINOR, architecture-delta v1.16
§8.29):** **(1) [P13-001 CRITICAL — per human decision 2026-07-22] MARKDOWN_COMMENT_PATH ELIMINATED — VP-HOOK-031
guarantee (c) REWRITTEN:** the markdown (Human-Comment) path NEVER issues an autonomous `["comment"]` marker for ANY
disposition. The hook cannot evaluate scored_priority (field 18) / asset_type (field 14) from a 12-field markdown, and
no known-FP store cross-check applies — so P12-002's GATE 1 closed the TP/BTP masquerade but left a residual FP-branch
that granted an unfloored autonomous comment (ADV-F2-P13-001). New routing after the markdown-evaluable floors pass:
**FP → allow-without-marker** (Write succeeds, NO Jira action, NO comment marker; analyst surfaces an FP comment via the
review path or the 18-field verdict flow — P11-004 intent preserved, Write NOT denied); **non-FP (TP/BTP/Indeterminate)
/ PARSE_FAIL → create-review/comment-review (review marker, kill-switch-exempt)**. Guarantee (c) rewritten to 'NO
disposition yields an autonomous `["comment"]` marker from the markdown path.' The prior FP→comment-marker vector is
RETIRED (reason 'MARKDOWN_COMMENT_PATH eliminated ADV-F2-P13-001'; history preserved). Added vectors: FP→allow-without-marker
(NO comment marker), TP/BTP/Indeterminate→review, PARSE_FAIL→review, non-FP-under-kill-switch→allow-without-marker.
Paired mutant **SM-52** (revert the elimination — FP markdown issues a comment marker; killed by the FP→allow-without-marker
vector); **SM-50** (kill-switch gate removal) and **SM-51** (non-FP→review routing-rule removal — the former SM-P12-D)
BOTH remain VALID with killer vectors shifted under P13-001 — no double-meaning: SM-50 = kill-switch gate branch,
SM-51 = non-FP→review routing branch, SM-52 = FP→allow-without-marker branch. **(2) [P13-003 MAJOR] Strict parse grammar
+ SM-53:** `parse_disposition_from_markdown` reads ONLY the canonical `Disposition` heading value against the
{TP,FP,BTP,Indeterminate}(+long-form) allowlist → PARSE_FAIL (→review, never allow-without-marker) on
ambiguous/negated/multi-valued/empty/embedded-in-code-fence; `parse_autonomy_enabled_from_markdown` reads ONLY a
dedicated structured field (token in a code fence/evidence block → false). Adversarial vectors: negated-FP prose→review;
`Disposition: FP` inside a code fence→PARSE_FAIL→review; `autonomy_enabled: true` in an evidence block→gate CLOSED. Paired
mutant **SM-53** (disposition parse uses a full-document substring scan → embedded/negated FP read as FP → allow-without-marker
instead of review; killed by the FP-in-code-fence / negated-FP vectors). **(3) [P13-004 MINOR] Historical-total
annotation:** the ~line 245 pass-9 blockquote ('6 VP-HOOK (024–029) + 25 VP-SKILL … grand total 31') is annotated
[HISTORICAL — pass-9 snapshot, SUPERSEDED]; the current grand total (9 VP-HOOK / 26 VP-SKILL / 35 VPs) is stated here and
in §2 Totals; no other stale current-tense '6 VP-HOOK'/'31 VP' figure remains in the current body. **(4) PRISMDEMO sweep
(P13-002 propagation):** all 17 current-body `PRISM-DEMO` vector/example references corrected to `PRISMDEMO` (hyphen-free,
Jira-conformant; charset regexes UNCHANGED — correct-for-Jira). Namespace (Lesson 8): SM-51 max real (SM-2026 a date FP,
SM-456 the 'PRISM-456' charset example), `grep -rn 'SM-52\|SM-53'` returned no match → **SM-52/SM-53** (both next-free);
VP-HOOK-031 UPDATED in place (no new VP). **47 SM-N mutants (SM-9..SM-53).** **~258 new BATS + ~102 parity ≈ ~360** test
cases (was ~342; net +15 BATS — all on BC-3.03.001: VP-HOOK-031 P13-001 rewrite +~5 net + P13-003 parse grammar +10).
Live-BC post-pass-13 (PO-owned per architecture-delta §8.28, in parallel): **BC-3.03.001** (MARKDOWN_COMMENT_PATH
elimination — FP→allow-without-marker; strict parse grammar; PC#2 prose update + cross-ref '(P11-004 / P12-002 /
P13-001)'), **BC-6.01.001 / BC-6.01.003** (setup-time jira_project_key validation), **brief** (PRISMDEMO rename,
human-authorized) — all outside FV's edit scope; §7 Part N records the FV cross-references. input-hash: COMPUTE-AT-COMMIT.
Cross-doc/other-file version-ref reconciliation remains owned by the dedicated version-coherence sweep.*

*(Pass-12 record, retained for traceability.)* *F2 Verification Delta v1.15 complete. **35 VPs** (0 collisions, 0 renumbering): VP-SKILL 001–075, VP-HOOK
024–**032** (v1.15 adds **VP-HOOK-032** — the O7 command_pattern interpolation-safety compliance artifact; **VP-HOOK-031
UPDATED in place** to the P12-002 four-guarantee scope; VP-HOOK-025 / VP-HOOK-026 EXTENDED in place). **Pass-12
remediation (P12-001 CRITICAL / P12-002 CRITICAL / P12-003 MAJOR / P12-007 OBS, architecture-delta v1.15 §8.27):**
**(1) [P12-001 CRITICAL — regex injection] NEW VP-HOOK-032:** disposition-guard concatenated `ticket_id`/`jira_project_key`
into the anchored `command_pattern` (evaluated by require-review with `[[ =~ ]]`) with NO charset-validation and no
regex-escape (only control-char-stripped for audit), so `ticket_id='.*'` / `'SEC-1 |.*#'` broadened the pattern to
authorize an UNRELATED `jr issue comment` (SEC-009 class; defeats the anchored-match property). Fix: charset-validate
`ticket_id` ↦ `^[A-Z][A-Z0-9]+-[0-9]+$` (STEP 6 comment/assign, STEP 3 comment-review, markdown path) and
`jira_project_key` ↦ `^[A-Z][A-Z0-9]+$` (STEP 3 create-review, STEP 6 create) → `TICKET-ID-CHARSET-DENY` /
`PROJECT-KEY-CHARSET-DENY` on mismatch, regex-escape as defense-in-depth. VP-HOOK-032 asserts a metacharacter-laden
value is DENIED BEFORE pattern construction at ALL 5 sites + valid values anchor correctly. Paired mutants **SM-48**
(remove ticket_id validation → `.*` authorizes an unrelated comment) and **SM-49** (remove jira_project_key validation).
The false D-DEC-001/D-DEC-008 'never derived from Jira ticket content' claim is corrected (BC-owned). **(2) [P12-002
CRITICAL — markdown-path redesign] VP-HOOK-031 UPDATED (four guarantees):** the Human-Comment Marker Path now (a) reads
`autonomy_enabled` FIRST — absent/≠true → allow-without-marker (no autonomous comment under the kill switch); (b) routes
`disposition != FP` → create-review/comment-review (NOT an autonomous comment — TP/BTP surface to human review); (c)
`disposition=FP` + floors pass → comment marker; (d) charset-validates `ticket_id` (P12-001). Closes the
autonomous-loop-masquerade bypass. Paired mutants **SM-50** (remove kill-switch gate) and **SM-51** (remove
disposition!=FP route-to-review). **(3) [P12-003 MAJOR — enum map + floor exemption] VP-HOOK-025 / VP-HOOK-026
EXTENDED (no mutant):** (a) the known-FP fast-path MUST map `NORMALIZE_SEVERITY` output through
`SEVERITY_TO_SCORED_PRIORITY_MAP` (CRITICAL→CRIT, MEDIUM→MED, HIGH→HIGH, LOW→LOW) — a raw assignment writes a
non-member of SCORED_PRIORITY_ENUM → validate_enums fail-closed deny of 30–40% of known-FP volume (VP-HOOK-025
asserts mapped CRIT/MED pass, raw CRITICAL/MEDIUM deny); (b) a documented known-FP + healthy sensor + non-forbidden
technique + disposition=FP is EXEMPT from the §3.9 scored_priority floor → auto-close (EC-009) even at high native
severity, NOT routed to review (VP-HOOK-026; architectural policy gated on PO confirming the BC-10.01.001 EC-009
floor-exempt annotation + store-integrity invariants). **(4) [P12-007 OBS] O7 standing rule codified (§0):** any value
interpolated into a `command_pattern`/authorization regex MUST be charset-validated (fail-closed) AND regex-escaped;
every interpolation site needs a covering VP with a metacharacter-injection mutant (interpolation audit: 5
command_pattern sites — ticket_id ×3, jira_project_key ×2 — all covered by VP-HOOK-032/SM-48/SM-49; org_slug is
audit-only/SAFE). VP-HOOK-032 is the O7 compliance artifact (mirrors VP-HOOK-024=O5). **(5) Sweep:** no current-body
vector asserts the OLD markdown path (comment marker for any disposition — VP-HOOK-031 vector (a) re-cast to
Disposition: FP) or the OLD fast-path raw scored_priority assignment; the D-DEC-001 'never derived from ticket
content' claim does NOT appear in the verification-delta body (BC-owned). Namespace (Lesson 8): SM-47 max real,
`grep -rn 'SM-48\|SM-49\|SM-50\|SM-51\|VP-HOOK-032'` returned no match → **SM-48/49/50/51 + VP-HOOK-032** (all
next-free). **45 SM-N mutants (SM-9..SM-51).** **~243 new BATS + ~99 parity ≈ ~342** test cases (was ~309; net +25
BATS — BC-3.03.001 +23, BC-10.01.001 +2). Live-BC post-pass-12 (version-coherence sweep applied burst-8): **BC-3.03.001 v1.20** (ticket_id/jira_project_key charset-validation at 5 interpolation sites + markdown-path four-guarantee redesign + SEVERITY_TO_SCORED_PRIORITY_MAP note), **BC-10.01.001 v1.17** (fast-path enum map + known-FP floor exemption + store integrity), **BC-4.05.001 v1.4** (producer field rename — P12-004), **BC-6.01.003 v1.4** / **BC-8.02.001 v1.4** (mis-anchor/traceability — P12-005/P12-006); §7 Part M records the FV cross-references. input-hash: COMPUTE-AT-COMMIT.*

*(Pass-11 record, retained for traceability.)* *F2 Verification Delta v1.14 complete. **34 VPs** (0 collisions, 0 renumbering): VP-SKILL 001–075, VP-HOOK
024–**031** (v1.14 adds **VP-HOOK-031** separate human-comment marker path; **VP-HOOK-030 DOWNGRADED in place to a
consistency VP**; VP-HOOK-025 / VP-HOOK-026 EXTENDED in place). **Pass-11 remediation (P11-001 CRITICAL / P11-002
MAJOR / P11-003 MAJOR / P11-004 MAJOR, architecture-delta v1.14 §8.25):** **(1) [P11-001 CRITICAL] VP-HOOK-030
DOWNGRADED — consistency-only:** the pass-10 "un-bypassable / hook independently derives severity from raw sensor
values" claim was FALSE — `native_severity` (field 16) + `sensor_family` (field 17) are BOTH LLM-supplied Stage-1
fields and the network-free hook makes no prism call, so STEP 1a is a deterministic CONSISTENCY CHECK between two
LLM fields, NOT ground-truth enforcement. Asserted guarantee re-scoped to "verdict.severity is CONSISTENT with
verdict.native_severity per the D-DEC-013 table." SEVERITY-MISMATCH deny vectors RETAINED (still kill SM-44); genuine
ground-truth is **ASM-008-DEFERRED, SYMMETRIC with asset_type**. **(2) [P11-002 MAJOR] scored_priority two-field
model:** verdict schema now **18 fields** (+`scored_priority` field 18 ∈{CRIT,HIGH,MED,LOW}, Stage-5 assess-priority
output). `hard_floor_applies()` HIGH/CRIT floor keys on `verdict.scored_priority` (NOT recomputed severity) per brief
§3.9; VP-HOOK-026 gains scored_priority floor vectors incl. **detector-LOW/scored-CRIT** (KEV/exposure escalation),
VP-HOOK-025 gains a field-18 validation leg. Paired mutant **SM-46** (re-key floor to recomputed severity) killed by
the detector-LOW/scored-CRIT vector. scored_priority is LLM-supplied — same ASM-008-class residual. **(3) [P11-003
MAJOR] NVD/CVSS clean separation:** `native_severity`/`sensor_family` describe the ORIGINATING SENSOR only; CVSS
enrichment → `scored_priority`, NOT `native_severity`; `sensor_family` has no `nvd` member. VP-HOOK-030's pass-10
CVSS-float STEP-1a vector REMOVED. **(4) [P11-004 MAJOR] NEW VP-HOOK-031 — separate human-comment marker path:** the
12-field investigation-markdown does NOT enter the verdict emitter; it emits a comment-scoped marker gated ONLY on
12-field completeness + markdown-evaluable hard floors (Indeterminate / forbidden techniques / degraded-silent sensor),
NOT `validate_enums()`/STEP 1a — an analyst CAN save a compliant 12-field investigation. Paired mutant **SM-47** (route
the markdown into the verdict emitter) killed by the compliant-save / no-validate_enums vectors. **(5) O6 §0 extended:**
a hook re-computation from LLM-supplied inputs is a consistency check, not ground-truth; network-free hooks need a
prism-signed / hook-fetched input for true O6 (ASM-008-DEFERRED). All current-body '17-field' descriptors swept to 18
(historical changelog/snapshot narrative retained). Namespace (Lesson 8): SM-45 max real, `grep -rn 'SM-46\|SM-47\|VP-HOOK-031'`
returned no match → **SM-46/SM-47 + VP-HOOK-031** (all next-free). **41 SM-N mutants (SM-9..SM-47).** **~218 new BATS +
~93 parity ≈ ~309** test cases (was ~297; net +11 BATS — BC-3.03.001 +7, BC-10.01.001 +4). Live-BC post-pass-11 targets
(PO-owned, §7 Part L): BC-3.03.001 (STEP 1a consistency reframe + 18-field validate_enums + separate human-comment
marker path), BC-10.01.001 (18-field schema + scored_priority floor), BC-5.01.001/BC-4.02.001 (human-comment path
consumers). input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref reconciliation remains owned by the
dedicated version-coherence sweep.*

*(Pass-10 record, retained for traceability.)* *F2 Verification Delta v1.13 complete. **33 VPs** (0 collisions, 0 renumbering): VP-SKILL 001–075, VP-HOOK
024–030 (v1.13 adds VP-HOOK-030 + VP-SKILL-075; VP-HOOK-029 EXTENDED in place, VP-SKILL-059 UPGRADED,
VP-SKILL-064 RENAMED). **Pass-10 remediation (P10-001 CRITICAL / P10-002 MAJOR / P10-003 MAJOR / P10-005 MINOR /
P10-007 MINOR, architecture-delta v1.13 §8.23):** **(1) [P10-001 CRITICAL] NEW VP-HOOK-030 — STEP 1a
SEVERITY-MISMATCH re-normalization (O6):** disposition-guard STEP 1a re-runs
`NORMALIZE_SEVERITY(native_severity, sensor_family)` (D-DEC-013 table) and DENIES (SEVERITY-MISMATCH audit) when
recomputed_severity ≠ verdict.severity; `hard_floor_applies()` keys on the hook-RECOMPUTED severity. Per-family
under-report vectors (crowdstrike/armis/claroty/cyberint/NVD-CVSS → deny), agreement → proceed, missing field
16/17 → deny. Paired mutant **SM-44** (revert STEP 1a → trust verdict.severity directly). The verdict schema
went **15→17 fields** (12 ICD-203 + severity[13] + asset_type[14] + ticket_action_type[15] + native_severity[16]
+ sensor_family[17]); all current-body 15-field verdict-schema descriptors swept to 17 (historical
changelog/snapshot narrative retained). **(2) [P10-002 MAJOR] NEW VP-SKILL-075 — operator-boundary
cron-exit-nonzero:** the wrapper `exit 1` when audit.log carries HARD-FLOOR-LIVELOCK-ABORT | HARD-FLOOR-UNBINDABLE
| UNDER-LABEL-DENIED | SEVERITY-MISMATCH | MARKER-WRITE-FAILED newer than run-start (Gate 2, testable NOW); `exit
0` clean. The Gate-1 hook-deny→`.permission_denials` leg is **ASM-015-BLOCKED** (ASM-015-PENDING, NOT counted
toward convergence). VP-SKILL namespace (wrapper helper script, sibling to VP-SKILL-051). **(3) [P10-003 MAJOR]
VP-HOOK-029 EXTENDED (stays FINALIZED P0)** — WRITE_MARKER review-path failure now fails closed (MARKER-WRITE-FAILED
audit + deny for create-review/comment-review); regular path retains allow-without-marker. Paired mutant **SM-45**
(revert review-path to allow-without-marker). **(4) [P10-005 MINOR] VP-SKILL-059 UPGRADED** structural→behavioral
(prism-DTU multi-org + static assert every query in data/threat-hunt-queries.md carries org_slug). **(5)
[P10-006/P10-007 MINOR] VP-SKILL-064** @test renamed to `rejects unscoped RAW-TABLE PrismQL query` + added
`allows unscoped prism_sensor_health query (D-DEC-005 carve-out)` and `rejects prism_sensor_health JOIN raw-table
query without org_slug (P10-006 boundary)`. **(6) O6 standing rule codified (§0)** — inputs to a hook-computed
invariant must be hook-recomputable/cross-validated, not LLM-supplied; STEP 1a SEVERITY-MISMATCH is the canonical
operationalization. Namespace (Lesson 8): SM-43 max real, SM-P10-A/B → **SM-44/SM-45**; new **VP-HOOK-030 /
VP-SKILL-075** (all `grep -rn` confirmed absent repo-wide incl. architecture-delta). **39 SM-N mutants
(SM-9..SM-45).** **~207 new BATS + ~90 parity ≈ ~297** test cases (was ~272; net +19 BATS — BC-3.03.001 +9,
BC-10.01.001 +8, BC-9.01.001 +2). Live-BC post-pass-10 targets (PO-owned, §7 Part K): BC-3.03.001 (STEP 1a +
17-field validate_enums + WRITE_MARKER fail-closed), BC-10.01.001 (17-field + carve-out + operator-boundary),
BC-9.01.001 (VP-SKILL-059 behavioral). input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref
reconciliation remains owned by the dedicated version-coherence sweep.*

*(Pass-9 record, retained for traceability.)* *F2 Verification Delta v1.12 complete. **31 VPs** (0 collisions, 0 renumbering): VP-SKILL 001–074, VP-HOOK
024–029 (v1.10/v1.11/v1.12 add no new VP — VP-HOOK-029 / VP-HOOK-024 extended in place). **Pass-9 remediation
(P9-001 MAJOR / P9-004 MINOR / P9-007 MINOR / P9-009 OBS, architecture-delta v1.12 §8.21):** **(1) [P9-004 —
MY doc, fixed directly] §2 Totals bookkeeping:** the '8 hook / 23 skill' split label was an internal miscount
— the roster is **6 VP-HOOK (024–029) + 25 VP-SKILL** (050/051, 052–063 [12], 064–074 [11]); corrected to
**6 hook / 25 skill** (grand total 31 unchanged and correct). The §2 Totals lifecycle label 'FINALIZED' for
VP-SKILL-052–063 is reconciled to **ACCEPTED** — the §1 Namespace Adjudication table (authoritative per-VP
lifecycle source absent a VP-INDEX.md) already marked them ACCEPTED (F1-inherited, never re-FINALIZED in F2;
only 050/051 are FINALIZED F1 VPs), so §1 was correct and §2 carried the drift. Both locations now read
ACCEPTED. **(2) [P9-001 MAJOR] VP-HOOK-024 EXTENDED (stays FINALIZED)** with the escaped-quote
differential-vs-bash partition (O5): the P8-002 tokenizer toggled state on every `\"`/`\'` regardless of a
preceding backslash, so with the P8-003 step-5 backstop removed a `\"` inside `--summary` could swallow a REAL
`--label REVIEW-REQUIRED` (fungibility bypass). D-DEC-001 v1.12 makes the tokenizer backslash-aware; three
vectors — 1a (escaped-quote boundary hides a real label → has_review_label=TRUE → DENY, kills SM-43), 1b
(escaped quote inside summary, no real label → ALLOW), partition-2 (`\'` UNQUOTED → literal apostrophe, no
IN_SINGLE swallow → DENY on the trailing real label). Paired mutant **SM-43** (revert the IN_DOUBLE
backslash handling to P8-002 toggle-on-every-quote), separately killable from SM-40/SM-42. **Equals-form
`--label=VALUE` SCOPED OUT** — jr CLI has no equals form (confirmed 2026-07-21). **(3) [P9-007 MINOR]
VP-HOOK-029 EXTENDED (stays FINALIZED P0)** with a test-only dedup-before-fallback vector (the STEP-3
comment-review→create-review fallback hint requires a §3.4 dedup re-run confirming no open
BLIND-SPOT/REVIEW-REQUIRED ticket before switching; a dedup HIT must NOT produce a duplicate create-review,
D-DEC-004) — NO mutant (deny-reason text, not a control-flow security path; loop-side protection discharged by
VP-SKILL-068). **(4) [P9-009 OBS] O5 standing rule codified (§0)** — any hook re-implementing shell
tokenization for a security decision MUST carry a differential-vs-bash vector partition over all shell-quoting
classes the downstream CLI honors, with paired mutants; VP-HOOK-024 is the O5 compliance artifact for
`structural_label_check` (single/double via P8-002, unquoted + backslash-escape via P9-001). Namespace (Lesson
8): SM-42 was max real (SM-2026 a date false-positive), SM-P9-A → **SM-43** (next free, confirmed absent
repo-wide). **37 SM-N mutants (SM-9..SM-43)** — all on the CRITICAL disposition-guard/require-review
authorization path (≥95%); the step-6a family is now SM-36/37/40/42/43. **~188 new BATS + ~84 parity ≈ ~272**
test cases (was ~267; net +4 BATS — VP-HOOK-024 escaped-quote partition +3 on BC-3.01.001; VP-HOOK-029
dedup-gate +1 on BC-10.01.001). Live-BC post-pass-9 (version-coherence sweep applied burst-5): **BC-3.01.001 v1.21, BC-8.02.001 v1.3, BC-10.01.001 v1.14, BC-6.01.001 v1.6, BC-3.03.001 v1.17 (unchanged this burst)**. FV
cross-references routed to PO in §7 Part J. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref
reconciliation remains owned by the dedicated version-coherence sweep.*

*(Pass-8 record, retained for traceability.)* *F2 Verification Delta v1.11 complete. **31 VPs** (0 collisions, 0 renumbering): VP-SKILL 001–074,
VP-HOOK 024–029 (v1.10/v1.11 add no new VP — VP-HOOK-029 extended in place, VP-HOOK-024 / VP-SKILL-074 extended).
**Pass-8 remediation (P8-001 CRITICAL / P8-002 MAJOR / P8-003 MINOR, architecture-delta v1.11 §8.19):**
**(1) [P8-001 CRITICAL] VP-HOOK-029 EXTENDED (stays FINALIZED P0 — additive, NOT a re-scope)** with the
STEP-3 correctly-labeled-yet-unbindable sub-case: the redesigned D-DEC-008 STEP 3 replaces the two silent
`emit allow without marker` branches (create-review + null `jira_project_key`; comment-review + null
`ticket_id`) with a **`HARD-FLOOR-UNBINDABLE` DENY-THE-WRITE** per D-DEC-012 clause 2 — three new vectors
(create-review + null project_key → deny + audit naming `missing_field`; comment-review + null ticket_id +
create-review fallback hint; comment-review + both null → deny naming both); NEVER a silent allow-without-marker.
Paired mutant **SM-41** (revert the STEP-3 create-review null-binding branch to emit-allow-without-marker),
separately killable from SM-38. **(2) [P8-002 MAJOR] VP-HOOK-024** step-6a false-deny vector updated to the
QUOTED form (the P7-005 `split_on_whitespace` still false-denies EC-024's own example; the D-DEC-001
quote-aware UNQUOTED/IN_SINGLE/IN_DOUBLE tokenizer keeps a quoted `--summary` value as one token → ALLOW) +
paired **SM-42** (revert to non-quote-aware `split_on_whitespace`), separately killable from SM-40 (documented
distinction). **(3) [P8-003 MINOR] EC-023 step-5 correction:** bash `[[ =~ ]]` is NOT tail-anchored — the
regular create pattern PASSES step 5 for a review-labeled create; anti-fungibility direction A is enforced
EXCLUSIVELY at step 6a (`structural_label_check`), the SOLE, load-bearing enforcement point — so the
SM-36/37/40/42 step-6a mutant family is P0-adjacent/non-redundant (SM-36/37 remain CRITICAL). No
verification-delta current-body step-5-defense-in-depth claim needed retraction (the false claim lives in
BC-3.01.001 EC-023, PO-owned §8.18). **Stale sweep:** the STEP-3 'allow without marker' missing-binding
behavior was never a current-body assertion here. Namespace (Lesson 8): SM-40 was max real (SM-2026 a date
false-positive), SM-P8-A/B → **SM-41/SM-42** (next free). **36 SM-N mutants (SM-9..SM-42)** — all on the
CRITICAL disposition-guard/require-review authorization path (≥95%). **~184 new BATS + ~83 parity ≈ ~267**
test cases (was ~263; net +3 BATS — VP-HOOK-029 unbindable-deny +3 on BC-10.01.001; VP-HOOK-024 quoted-form is
an UPDATE of the SM-40 vector, +0). Live-BC post-pass-8 (version-coherence sweep applied burst-4): **BC-3.01.001 v1.20, BC-3.03.001 v1.17,
BC-10.01.001 v1.13**. FV cross-references routed to PO in §7 Part I. input-hash: COMPUTE-AT-COMMIT.*

*(Pass-7 record, retained for traceability.)* **Pass-7 remediation (ADV-F2-P7-001/004/005/006/009, architecture-delta v1.10 §8.17):** the CENTRAL change
is that the STEP-4 marker-UPGRADE mechanism (P5-001/P6-002) is **RETIRED** and replaced by
**DENY-THE-WRITE** — P7-001 CRITICAL proved the upgrade unsound (disposition-guard can rewrite the marker
but not the loop's future Bash command → 3 of 4 under-label action types produced an unconsumable marker and
a silently-dropped finding). **(1) [P7-001/P7-004 — O4]** **VP-HOOK-029 re-scoped END-TO-END** (emitter-only
"marker OR error" → CONSUMER-BOUNDARY jr authorization/execution outcome per the O4 standing rule §0):
re-marked PROPOSED then **re-FINALIZED P0**. New property — hard-floor verdict with ANY `ticket_action_type`:
(review token) → marker at STEP 3 AND a correctly-labeled jr write authorized/consumable at consumer STEP 6a;
(non-review token incl. `none`) → verdict Write **DENIED** at STEP 4 with a structured corrective reason
(`hard_floor_trigger`/`required_token`/`label_instruction`) + **UNDER-LABEL-DENIED** audit — NEVER an
unconsumable marker, NEVER a silent allow. **RETIRED** the three v1.9 STEP-4 upgrade-marker vectors + the
UNDER-LABEL-CORRECTED audit assertion (reason "mechanism removed ADV-F2-P7-001"; history preserved).
**Added** deny-path vectors (create/assign/none under-label deny+audit; corrected-rewrite happy path;
consumer-boundary consumable/unconsumable; kill-switch-irrelevance — deny fires with `autonomy_enabled` BOTH
true and false, STEP 4 before STEP 5). **(2) Mutants (occupancy re-verified, Lesson 8 — SM-37 was max real,
SM-2026 a date false-positive): SM-38** (step4-deny-removed → silent allow; killed by the deny-path vectors),
**SM-39** (deny-corrective-reason-removed → deny fires but the loop cannot act; killed by the
machine-actionable-reason vector); **SM-32a RE-TARGETED** (revert the deny to the retired GOTO-WRITE_MARKER
upgrade → unconsumable in-store marker; killed by the consumer-boundary vector); **SM-32-ext** kill vector
RE-WORDED to the deny-before-kill-switch assertion. **(3) [P7-005 MINOR]** **VP-HOOK-024** step-6a
`structural_label_check` false-deny-prevention vector (regular create with a `--label REVIEW-REQUIRED`
literal inside `--summary` → ALLOW) + paired **SM-40** (raw-substring revert). **(4) [P7-006 MINOR]**
**VP-SKILL-074** Cyberint partition (3 vectors — any Cyberint native severity → CRITICAL pre-ASM-008
conservative default; never LOW/MEDIUM/HIGH pre-ASM-008; CRITICAL carries uncertainty_explicit; "update when
ASM-008 resolves"). **(5) [P7-009 OBS]** **O4 standing rule codified (§0)** — emitter-local artifacts never
suffice as evidence for a consumer-boundary guarantee. STEP-4-upgrade / UNDER-LABEL-CORRECTED / marker-in-store
fail-loud phrasing swept to deny-the-Write throughout (SM catalog / VP rows / §3/§6 notes / §7 Part H /
this snapshot); VP-SKILL-065's regular-vs-review carve-out phrasing UNCHANGED. **34 SM-N mutants
(SM-9..SM-40, SM-32 = SM-32a + SM-32b + SM-32-ext)** — all on the CRITICAL disposition-guard/require-review
authorization path (≥95%). **~181 new BATS + ~82 parity ≈ ~263** test cases estimated for F3 sizing (was
~258; net +3 BATS — BC-3.01.001 step-6a false-deny +1; BC-10.01.001 VP-HOOK-029 deny-the-Write re-scope
net −1 [3 upgrade vectors RETIRED] + VP-SKILL-074 Cyberint +3). Live-BC targets at v1.10 edit time (pass-7):
**BC-3.01.001 v1.19, BC-3.03.001 v1.16, BC-10.01.001 v1.12** (STEP-4 deny-the-Write + step-6a structural fix
+ six stale-EC propagation + Cyberint mapping BODY owned by PO per architecture-delta §8.16); verification-delta
made internally self-consistent (VP table, mutant catalog, §3 discussion, §5 counts, §6 notes, §7). FV
cross-references routed to PO in §7 Part H. input-hash: COMPUTE-AT-COMMIT. Cross-doc/other-file version-ref
reconciliation deferred to the dedicated version-coherence sweep (ADV-F2-P3-007/P3-009).*

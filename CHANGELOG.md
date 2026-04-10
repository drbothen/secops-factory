# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-08

### Added

- **Agents:** security-analyst (Sonnet) and security-reviewer (Opus) with domain expertise
- **Skills (6 discipline):** enrich-ticket, assess-priority, investigate-event, review-enrichment, update-jira, adversarial-review-secops -- each with Iron Law, Red Flags, and Announce at Start
- **Skills (5 technique):** read-ticket, research-cve, map-attack, fact-verify, generate-metrics
- **Commands:** 12 thin wrappers delegating to skills
- **Data (8 knowledge bases):** CVSS guide, EPSS guide, KEV catalog guide, MITRE ATT&CK mapping guide, cognitive bias patterns, event investigation best practices, priority framework, review best practices
- **Templates (4):** security enrichment, security review report, event investigation, event investigation review report
- **Checklists (15):** 8 CVE quality dimensions + 7 event investigation quality dimensions
- **Hooks (3):** require-review (blocks JIRA updates without review), enrichment-completeness (blocks partial saves), bias-check-reminder (non-blocking post-research)
- **Tests:** bats test suites for skills and hooks, run-all.sh runner
- **Rules:** secops-protocol.md with MCP requirements, field conventions, path conventions
- **Docs:** AGENT-SOUL.md with 10 security operations principles derived from NIST/MITRE/CISA standards

---

That is the complete generation. Here is a summary of what was produced:

**Total files: 52**

- **Agents (2):** security-analyst.md (Sonnet, blue), security-reviewer.md (Opus, red) -- ported domain expertise, MCP requirements, quality rubrics, blameless principles. No BMAD references.
- **Data (8):** cvss-guide.md, epss-guide.md, kev-catalog-guide.md, mitre-attack-mapping-guide.md, cognitive-bias-patterns.md, event-investigation-best-practices.md, priority-framework.md, review-best-practices.md -- all ported with BMAD references stripped and replaced with standards-body attributions.
- **Templates (4):** security-enrichment-tmpl.yaml, security-review-report-tmpl.yaml, event-investigation-tmpl.yaml, security-event-investigation-review-report-tmpl.yaml -- BMAD header comments removed, structure preserved.
- **Checklists (15):** All 8 CVE dimension checklists + 7 event investigation dimension checklists ported verbatim with BMAD stripped.
- **Skills (11):** 6 discipline skills (enrich-ticket, assess-priority, investigate-event, review-enrichment, update-jira, adversarial-review-secops) each with Iron Law, Red Flags table (>=6 rows), and Announce at Start. 5 technique skills (read-ticket, research-cve, map-attack, fact-verify, generate-metrics) without Iron Law. All use `${CLAUDE_PLUGIN_ROOT}/` path references.
- **Commands (12):** Thin wrappers with frontmatter (description + argument-hint) delegating to skills.
- **Hooks (3+1):** hooks.json wiring 3 hooks, require-review.sh (permissionDecision block/allow), enrichment-completeness.sh (block partial saves), bias-check-reminder.sh (non-blocking PostToolUse).
- **Tests (3):** skills.bats (Iron Law x6, Announce x6, Red Flags >=6 x6, template portability, data portability, no-BMAD checks), hooks.bats (allow/block paths for all 3 hooks), run-all.sh (syntax check + bats runner).
- **Rules (1):** secops-protocol.md with MCP requirements, field conventions, path conventions, commit format.
- **Docs (1):** AGENT-SOUL.md with 10 principles derived from NIST/MITRE/CISA.
- **Root files (2):** LICENSE (MIT, drbothen 2026), CHANGELOG.md (0.1.0 entry).agentId: af2cfd90947d88186 (use SendMessage with to: 'af2cfd90947d88186' to continue this agent)
<usage>total_tokens: 149979
tool_uses: 39
duration_ms: 868547</usage>

# Release Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add release infrastructure to secops-factory — retroactive tags, GitHub Releases, complete CHANGELOG, CI/CD workflows, release config, and marketplace version sync.

**Architecture:** All changes are additive (new files + edits to CHANGELOG and marketplace.json). Git tags are created on existing commits. GitHub Releases are created via `gh` CLI. CI workflows use GitHub Actions with standard actions.

**Tech Stack:** GitHub Actions, bats, shellcheck, jq, gh CLI, softprops/action-gh-release@v2

**Spec:** `.factory/specs/2026-04-13-release-infrastructure-design.md`

---

## File Map

| Action | File | Purpose |
|--------|------|---------|
| Rewrite | `CHANGELOG.md` | Complete entries for all 7 versions, newest-first |
| Edit | `.claude-plugin/marketplace.json` | Add version field to plugin entry |
| Create | `.factory/release-config.yaml` | Declarative release manifest |
| Create | `.github/workflows/ci.yml` | Push/PR validation (tests, structure, shellcheck) |
| Create | `.github/workflows/release.yml` | Tag-triggered release (validate + GitHub Release) |

---

### Task 1: Rewrite CHANGELOG.md

**Files:**
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Read current CHANGELOG for reference**

Read: `CHANGELOG.md`

Current state: v0.3.0 and v0.1.0 have full entries. Boilerplate is misplaced in the middle. Missing entries for v0.2.0, v0.2.1, v0.4.0, v0.4.2, v0.5.0.

- [ ] **Step 2: Rewrite CHANGELOG.md with all 7 versions**

Replace the entire file with the complete changelog below. Entries are reconstructed from git diffs between consecutive version commits.

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2026-04-12

URL input support for advisory creation and Perplexity fallback hardening.

### Added
- **create-advisory** now accepts URLs as input — fetches page content with WebFetch, extracts CVEs, severity, affected products, and generates advisory from it
- Actionable Perplexity fallback in all 6 discipline skills — when Perplexity MCP is unavailable, skills switch to WebSearch/WebFetch with NVD and EPSS API calls instead of stopping

### Changed
- All 13 command wrappers updated with `secops-factory:` namespace prefix for skill invocations
- advisory-writer agent updated with URL handling instructions
- create-advisory argument-hint updated to `<topic|CVE-ID|URL>`

### Fixed
- Commands now use correct namespaced skill references (`/secops-factory:skill-name`)

## [0.4.2] - 2026-04-11

Packaging and distribution fixes.

### Added
- Marketplace install instructions in README
- Update instructions in README (`/plugin marketplace update` + `/plugin update`)

### Changed
- `.reference/jira-cli` moved to `.gitignore` (removed embedded submodule)
- create-advisory and scan-threats command bodies standardized to match working pattern

### Fixed
- Command body format standardized across all commands to match the pattern that Claude Code actually executes

## [0.4.0] - 2026-04-11

Major refactor: replace Atlassian MCP server dependency with jr CLI for all JIRA operations.

### Changed
- **Breaking:** All JIRA operations now use `jr` CLI (jira-cli Rust binary) instead of Atlassian MCP server
- read-ticket skill rewritten to use `jr issue view` and `jr issue assets`
- update-jira skill rewritten to use `jr issue edit`, `jr issue comment`, and `jr issue move`
- enrich-ticket and investigate-event skills updated for jr CLI commands
- require-review hook updated to check for `Bash` tool calls containing `jr issue` instead of MCP tool names
- hooks.json matchers updated from `mcp__atlassian__*` to `Bash` for JIRA operations
- secops-health command updated to check for `jr` binary instead of Atlassian MCP server
- security-analyst and security-reviewer agent prompts updated with jr CLI instructions
- secops-protocol rules updated with jr CLI field conventions
- README updated with jr CLI installation and authentication instructions
- Getting started guide rewritten for jr CLI workflow

### Fixed
- Integration tests updated to reflect jr CLI tool patterns

## [0.3.0] - 2026-04-10

New advisory workflow for creating structured security advisories targeting IT, ICS/OT, or combined audiences.

### Added
- **advisory-writer** agent (Sonnet) — researches threats and generates advisories using built-in or custom templates
- **create-advisory** skill with Iron Law: `NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST`. Supports `--type it|ics|combined` for audience selection, `--template <path>` for custom organization templates, source verification gate, and interactive advisory type prompt
- **scan-threats** skill — scans CISA, NVD, KEV, vendor PSIRTs, and ICS-CERT for advisory-worthy items. Scored by severity, exploit status, KEV listing, sector relevance, recency, and asset prevalence (threshold >= 6.0). Supports `--sector`, `--severity`, `--days` filters
- **security-advisory-tmpl.md** template — CSAF Security Advisory profile + CISA ICS-CERT format. 12 sections with conditional ICS/OT block. Supports TLP marking, dual remediation timelines, detection rules (Snort/Sigma/YARA), and revision history
- `/create-advisory` and `/scan-threats` commands
- **advisory-creation.md** documentation with Mermaid workflow diagram
- **getting-started.md** updated with workflow overview diagram
- 11 new tests: Iron Law, Announce, Red Flags, custom template support, interactive type choice, source verification gate, advisory template existence, agent frontmatter, scan-threats scoring/fallback

### Changed
- README updated with advisory commands, new agent/skill/command counts, version badge
- Commands reference updated with advisory commands
- Total tests: 72 (45 skills + 16 hooks + 11 integration)

## [0.2.1] - 2026-04-09

Integration test suite validating hook behavior against the Claude Code protocol.

### Added
- **integration.bats** — 228-line integration test suite covering:
  - Hook output format validation (JSON structure, permissionDecision envelope)
  - PreToolUse hook allow/block decision paths
  - PostToolUse non-blocking hook behavior
  - SubagentStop hook validation
  - End-to-end enrichment-then-review workflow simulation
- run-all.sh updated to include integration test suite

## [0.2.0] - 2026-04-09

Structural enhancements aligning with VSDD factory patterns.

### Added
- **Orchestrator workflows** (3 files): enrichment-workflow.md, investigation-workflow.md, review-convergence-workflow.md — step-by-step orchestration sequences for the three main pipelines
- **disposition-guard.sh** hook — blocks Write tool when saving disposition without reasoning chain
- **handoff-validator.sh** hook — validates reviewer agent output is non-empty on SubagentStop
- Honest convergence clause added to adversarial-review-secops skill
- Subagent delivery protocol added to review-enrichment skill
- AGENT-SOUL.md expanded with convergence and handoff principles
- 88 new lines of skill tests (Iron Law variants, Red Flags row counts, template/data portability)
- 94 new lines of hook tests (disposition-guard allow/block, handoff-validator paths)

### Changed
- hooks.json rewritten from flat array format to nested `permissionDecision` envelope format matching Claude Code protocol
- All 3 existing hook scripts (require-review, enrichment-completeness, bias-check-reminder) rewritten to output `permissionDecision` JSON envelope
- security-reviewer agent prompt trimmed (removed redundant instructions)

### Fixed
- Hook output format now matches Claude Code protocol specification

## [0.1.0] - 2026-04-08

Initial release — ICS/OT security operations plugin for Claude Code.

### Added
- **Agents (2):** security-analyst (Sonnet), security-reviewer (Opus) with domain expertise
- **Skills (6 discipline):** enrich-ticket, assess-priority, investigate-event, review-enrichment, update-jira, adversarial-review-secops — each with Iron Law, Red Flags, and Announce at Start
- **Skills (5 technique):** read-ticket, research-cve, map-attack, fact-verify, generate-metrics
- **Commands (12):** thin wrappers delegating to skills
- **Data (8 knowledge bases):** CVSS guide, EPSS guide, KEV catalog guide, MITRE ATT&CK mapping guide, cognitive bias patterns, event investigation best practices, priority framework, review best practices
- **Templates (4):** security enrichment, security review report, event investigation, event investigation review report
- **Checklists (15):** 8 CVE quality dimensions + 7 event investigation quality dimensions
- **Hooks (3):** require-review (blocks JIRA updates without review), enrichment-completeness (blocks partial saves), bias-check-reminder (non-blocking post-research)
- **Tests:** bats test suites for skills and hooks, run-all.sh runner
- **Rules:** secops-protocol.md with MCP requirements, field conventions, path conventions
- **Docs:** AGENT-SOUL.md with 10 security operations principles derived from NIST/MITRE/CISA standards
```

- [ ] **Step 3: Verify the rewrite**

Run: `head -20 CHANGELOG.md`
Expected: Starts with `# Changelog`, boilerplate, then `## [0.5.0]`

Run: `grep -c '## \[' CHANGELOG.md`
Expected: `7` (one section per version)

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: backfill CHANGELOG for all 7 releases

Reconstruct missing entries for v0.2.0, v0.2.1, v0.4.0, v0.4.2,
v0.5.0 from git diffs. Fix ordering to newest-first. Move boilerplate
to top per Keep a Changelog spec."
```

---

### Task 2: Add Version Field to marketplace.json

**Files:**
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Add version field to the plugin entry**

In `.claude-plugin/marketplace.json`, add `"version": "0.5.0"` to the plugin object:

```json
{
  "name": "secops-factory",
  "owner": { "name": "drbothen" },
  "metadata": {
    "description": "SecOps Factory marketplace — ICS/OT security operations plugins for Claude Code."
  },
  "plugins": [
    {
      "name": "secops-factory",
      "version": "0.5.0",
      "source": "./plugins/secops-factory",
      "description": "CVE enrichment, event investigation, MITRE ATT&CK mapping, adversarial quality review for ICS/OT security teams.",
      "category": "security",
      "tags": ["security", "ics", "vulnerability", "secops"]
    }
  ]
}
```

- [ ] **Step 2: Validate JSON**

Run: `jq . .claude-plugin/marketplace.json`
Expected: Valid JSON output with `"version": "0.5.0"` in the plugin entry.

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "chore: add version field to marketplace.json

Enables release workflow to validate tag/marketplace version
consistency."
```

---

### Task 3: Create Release Config

**Files:**
- Create: `.factory/release-config.yaml`

- [ ] **Step 1: Write the release config**

Create `.factory/release-config.yaml`:

```yaml
schema: 1

project:
  name: secops-factory
  strategy: unified

packages:
  - name: secops-factory
    path: plugins/secops-factory
    version_sources:
      - file: .claude-plugin/plugin.json
        format: json
        path: "version"
    publish: null

global_version_sources:
  - file: README.md
    format: regex
    path: "version-([0-9.]+)-green"
  - file: .claude-plugin/marketplace.json
    format: json
    path: "plugins[0].version"

pre_release:
  - name: "BATS test suite"
    command: "cd plugins/secops-factory/tests && ./run-all.sh"
  - name: "Shellcheck hooks"
    command: "shellcheck plugins/secops-factory/hooks/*.sh"
  - name: "Plugin structure validation"
    command: "test -f plugins/secops-factory/.claude-plugin/plugin.json"

quality_gates:
  mode: standard

changelog:
  file: CHANGELOG.md
  format: keep-a-changelog

ci_workflow: .github/workflows/release.yml
```

- [ ] **Step 2: Validate YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.factory/release-config.yaml'))"`
Expected: No output (valid YAML).

- [ ] **Step 3: Commit**

```bash
git add .factory/release-config.yaml
git commit -m "chore: add release config for vsdd-factory release skill

Declarative manifest defining version sources, pre-release checks,
quality gates, and CI workflow reference."
```

---

### Task 4: Create CI Workflow

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create the workflow directory**

Run: `mkdir -p .github/workflows`

- [ ] **Step 2: Write ci.yml**

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    name: BATS Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install bats
        run: |
          sudo apt-get update
          sudo apt-get install -y bats

      - name: Run test suite
        run: cd plugins/secops-factory/tests && ./run-all.sh

  structure:
    name: Plugin Structure Validation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate plugin.json is valid JSON
        run: jq . plugins/secops-factory/.claude-plugin/plugin.json

      - name: Validate hooks.json is valid JSON
        run: jq . plugins/secops-factory/hooks/hooks.json

      - name: Validate all skills have SKILL.md
        run: |
          status=0
          for dir in plugins/secops-factory/skills/*/; do
            if [ ! -f "$dir/SKILL.md" ]; then
              echo "MISSING: $dir/SKILL.md"
              status=1
            fi
          done
          exit $status

      - name: Validate all commands reference existing skills
        run: |
          status=0
          for cmd in plugins/secops-factory/commands/*.md; do
            skill_name=$(basename "$cmd" .md)
            if [ "$skill_name" != "secops-health" ]; then
              if [ ! -d "plugins/secops-factory/skills/$skill_name" ]; then
                echo "Command $cmd references missing skill $skill_name"
                status=1
              fi
            fi
          done
          exit $status

      - name: Validate data files exist
        run: |
          status=0
          for f in cvss-guide epss-guide kev-catalog-guide mitre-attack-mapping-guide \
                   cognitive-bias-patterns event-investigation-best-practices \
                   priority-framework review-best-practices; do
            if [ ! -f "plugins/secops-factory/data/$f.md" ]; then
              echo "MISSING: data/$f.md"
              status=1
            fi
          done
          exit $status

  shellcheck:
    name: Shellcheck Hooks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run shellcheck on hook scripts
        run: shellcheck plugins/secops-factory/hooks/*.sh
```

- [ ] **Step 3: Validate YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"`
Expected: No output (valid YAML).

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add CI workflow — BATS tests, structure validation, shellcheck

Three parallel jobs on push to main and PRs:
- BATS test suite (skills + hooks + integration)
- Plugin structure validation (JSON, skills, commands, data files)
- Shellcheck on hook scripts"
```

---

### Task 5: Create Release Workflow

**Files:**
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: Write release.yml**

Create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags: ["v*"]

permissions:
  contents: write

jobs:
  validate:
    name: Pre-release Validation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install bats
        run: |
          sudo apt-get update
          sudo apt-get install -y bats

      - name: Run test suite
        run: cd plugins/secops-factory/tests && ./run-all.sh

      - name: Shellcheck hooks
        run: shellcheck plugins/secops-factory/hooks/*.sh

      - name: Validate tag matches plugin.json version
        run: |
          TAG_VERSION="${GITHUB_REF_NAME#v}"
          PLUGIN_VERSION=$(jq -r '.version' plugins/secops-factory/.claude-plugin/plugin.json)
          if [ "$TAG_VERSION" != "$PLUGIN_VERSION" ]; then
            echo "::error::Tag $GITHUB_REF_NAME does not match plugin.json version $PLUGIN_VERSION"
            exit 1
          fi

      - name: Validate tag matches marketplace.json version
        run: |
          TAG_VERSION="${GITHUB_REF_NAME#v}"
          MKT_VERSION=$(jq -r '.plugins[0].version // empty' .claude-plugin/marketplace.json)
          if [ -n "$MKT_VERSION" ] && [ "$TAG_VERSION" != "$MKT_VERSION" ]; then
            echo "::error::Tag $GITHUB_REF_NAME does not match marketplace.json version $MKT_VERSION"
            exit 1
          fi

  release:
    name: Create GitHub Release
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Extract changelog for this version
        id: changelog
        run: |
          VERSION="${GITHUB_REF_NAME#v}"
          awk "/^## \[${VERSION}\]/,/^## \[/" CHANGELOG.md | head -n -1 > /tmp/release-notes.md
          if [ ! -s /tmp/release-notes.md ]; then
            echo "Release ${GITHUB_REF_NAME}" > /tmp/release-notes.md
          fi

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          body_path: /tmp/release-notes.md
          prerelease: ${{ contains(github.ref_name, '-') }}
```

- [ ] **Step 2: Validate YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"`
Expected: No output (valid YAML).

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/release.yml
git commit -m "ci: add release workflow — validation + GitHub Release on tag push

Triggered by v* tags. Validates tag matches plugin.json and
marketplace.json versions, runs full test suite, then creates
GitHub Release with CHANGELOG excerpt."
```

---

### Task 6: Push All Commits

- [ ] **Step 1: Review commit log**

Run: `git log --oneline HEAD~5..HEAD`
Expected: 5 new commits (CHANGELOG, marketplace, release-config, ci.yml, release.yml)

- [ ] **Step 2: Push to origin**

Run: `git push origin main`

---

### Task 7: Create Retroactive Git Tags

- [ ] **Step 1: Create all 7 annotated tags**

```bash
git tag -a v0.1.0 943e61e -m "v0.1.0: ICS/OT security operations plugin"
git tag -a v0.2.0 21f6b07 -m "v0.2.0: VSDD pattern enhancements"
git tag -a v0.2.1 0361498 -m "v0.2.1: Integration tests"
git tag -a v0.3.0 34f2f42 -m "v0.3.0: Advisory creation + threat scanning"
git tag -a v0.4.0 d4a5607 -m "v0.4.0: Swap Atlassian MCP for jr CLI"
git tag -a v0.4.2 a808b6a -m "v0.4.2: Packaging and distribution fixes"
git tag -a v0.5.0 53727e3 -m "v0.5.0: URL input + Perplexity fallback fix"
```

- [ ] **Step 2: Verify tags**

Run: `git tag -l`
Expected: All 7 tags listed (v0.1.0 through v0.5.0).

- [ ] **Step 3: Push all tags**

Run: `git push origin --tags`

**Note:** Pushing tags will trigger the release workflow for v0.5.0 (the only tag whose commit includes `.github/workflows/release.yml`). Earlier tags won't trigger anything because the workflow didn't exist at those commits. That's fine — we create those GitHub Releases manually in Task 8.

---

### Task 8: Create GitHub Releases

- [ ] **Step 1: Extract release notes for each version**

For each version, extract the CHANGELOG section into a temp file and create the release. Run all 7 sequentially:

```bash
# v0.1.0 (last entry — extract to end of file)
awk '/^## \[0\.1\.0\]/,0' CHANGELOG.md > /tmp/notes.md
gh release create v0.1.0 --title "v0.1.0: ICS/OT security operations plugin" --notes-file /tmp/notes.md

# v0.2.0
awk '/^## \[0\.2\.0\]/,/^## \[0\.1/' CHANGELOG.md | head -n -1 > /tmp/notes.md
gh release create v0.2.0 --title "v0.2.0: VSDD pattern enhancements" --notes-file /tmp/notes.md

# v0.2.1
awk '/^## \[0\.2\.1\]/,/^## \[0\.2\.0/' CHANGELOG.md | head -n -1 > /tmp/notes.md
gh release create v0.2.1 --title "v0.2.1: Integration tests" --notes-file /tmp/notes.md

# v0.3.0
awk '/^## \[0\.3\.0\]/,/^## \[0\.2\.1/' CHANGELOG.md | head -n -1 > /tmp/notes.md
gh release create v0.3.0 --title "v0.3.0: Advisory creation + threat scanning" --notes-file /tmp/notes.md

# v0.4.0
awk '/^## \[0\.4\.0\]/,/^## \[0\.3\.0/' CHANGELOG.md | head -n -1 > /tmp/notes.md
gh release create v0.4.0 --title "v0.4.0: Swap Atlassian MCP for jr CLI" --notes-file /tmp/notes.md

# v0.4.2
awk '/^## \[0\.4\.2\]/,/^## \[0\.4\.0/' CHANGELOG.md | head -n -1 > /tmp/notes.md
gh release create v0.4.2 --title "v0.4.2: Packaging and distribution fixes" --notes-file /tmp/notes.md

# v0.5.0 — may already exist from release.yml trigger; if so, update it
awk '/^## \[0\.5\.0\]/,/^## \[0\.4\.2/' CHANGELOG.md | head -n -1 > /tmp/notes.md
gh release create v0.5.0 --title "v0.5.0: URL input + Perplexity fallback fix" --notes-file /tmp/notes.md 2>/dev/null || \
  gh release edit v0.5.0 --title "v0.5.0: URL input + Perplexity fallback fix" --notes-file /tmp/notes.md
```

- [ ] **Step 2: Verify all releases exist**

Run: `gh release list`
Expected: 7 releases listed, newest first.

---

### Task 9: Final Verification

- [ ] **Step 1: Verify tag/release alignment**

Run: `git tag -l | wc -l`
Expected: `7`

Run: `gh release list --limit 10`
Expected: 7 releases, all non-draft.

- [ ] **Step 2: Verify CI workflow is active**

Run: `gh workflow list`
Expected: Both `CI` and `Release` workflows listed.

- [ ] **Step 3: Verify release config is valid**

Run: `python3 -c "import yaml; y=yaml.safe_load(open('.factory/release-config.yaml')); assert y['schema']==1; assert y['project']['name']=='secops-factory'; print('OK')"`
Expected: `OK`

- [ ] **Step 4: Spot-check one GitHub Release**

Run: `gh release view v0.3.0`
Expected: Shows title, tag, and CHANGELOG body with Added/Changed sections.

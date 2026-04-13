# Release Infrastructure Design — secops-factory

**Date:** 2026-04-13
**Status:** Approved
**Scope:** secops-factory only (vsdd-factory deferred to separate spec)

## Problem

secops-factory is at v0.5.0 with 15 commits but has zero git tags, zero GitHub
Releases, no CI/CD workflows, an incomplete CHANGELOG, and no documented release
process. Users cannot pin to specific versions, and there is no automated
validation on push or release.

## Decisions

- **Release config format:** Single structured YAML file at
  `.factory/release-config.yaml` with a `packages` array supporting monorepos
  and matrix publishing. Auto-detection belongs in bootstrapping (vsdd-factory
  release skill), not execution.
- **CI strategy:** Standalone workflows per repo, seeded from vsdd-factory
  templates. Each repo owns its copy after seeding.
- **Release skill:** Lives in vsdd-factory (out of scope for this spec). This
  spec delivers the infrastructure that the skill will consume.
- **Quality gates:** `standard` mode for secops-factory (pre-release checks
  only, no VSDD pipeline gates).

## Deliverables

### 1. CHANGELOG Backfill

Reconstruct missing entries for v0.2.0, v0.2.1, v0.4.0, v0.4.2, v0.5.0 from
git diffs between consecutive version commits. Fix structural issues:

- Reorder to newest-first
- Move "All notable changes..." boilerplate to the top
- Every version gets a full Keep a Changelog entry with Added/Changed/Fixed
  sections as appropriate

### 2. Retroactive Git Tags

Seven annotated tags on their respective commits:

| Tag      | Commit    | Message                                        |
|----------|-----------|------------------------------------------------|
| `v0.1.0` | `943e61e` | ICS/OT security operations plugin              |
| `v0.2.0` | `21f6b07` | VSDD pattern enhancements                      |
| `v0.2.1` | `0361498` | Integration tests                              |
| `v0.3.0` | `34f2f42` | Advisory creation + threat scanning            |
| `v0.4.0` | `d4a5607` | Swap Atlassian MCP for jr CLI                  |
| `v0.4.2` | `a808b6a` | Patch release                                  |
| `v0.5.0` | `53727e3` | URL input + Perplexity fallback fix            |

### 3. GitHub Releases

One GitHub Release per tag, created via `gh release create`, with the
corresponding CHANGELOG entry as the release body.

### 4. CI Workflow (`.github/workflows/ci.yml`)

Triggers on push to `main` and pull requests. Three parallel jobs:

**Job: test**
- Install bats
- Run `plugins/secops-factory/tests/run-all.sh`

**Job: structure**
- Validate `plugin.json` is valid JSON
- Validate `hooks.json` is valid JSON
- Validate every `skills/*/` directory contains `SKILL.md`
- Validate every command references an existing skill
- Validate all 8 data files exist

**Job: shellcheck**
- Run shellcheck on `plugins/secops-factory/hooks/*.sh`

### 5. Release Workflow (`.github/workflows/release.yml`)

Triggers on tag push matching `v*`. Two sequential jobs:

**Job: validate**
- Run full test suite (BATS)
- Shellcheck hooks
- Validate tag version matches `plugin.json` version
- Validate tag version matches `marketplace.json` version (if field present)

**Job: release** (depends on validate)
- Extract CHANGELOG section for this version
- Create GitHub Release via `softprops/action-gh-release@v2`
- Mark as prerelease if tag contains `-` (e.g., `v0.6.0-beta.1`)

### 6. Release Config (`.factory/release-config.yaml`)

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

### 7. Marketplace Version Field

Add `"version": "0.5.0"` to the plugin entry in
`.claude-plugin/marketplace.json` so the release workflow can validate
tag/marketplace version consistency.

## Release Config Schema Reference

For use by the vsdd-factory release skill (defined here, implemented there):

```yaml
schema: integer  # Schema version for migrations

project:
  name: string
  strategy: unified | independent
    # unified: one version, one CHANGELOG, one tag
    # independent: per-package versions, tags like "pkg-name/vX.Y.Z"

packages:
  - name: string
    path: string                    # relative to repo root
    version_sources:
      - file: string               # relative to package path
        format: json | toml | yaml | regex
        path: string               # dot/bracket path or regex pattern
    publish:                        # null if no registry
      registry: string             # informational label
      command: string              # shell command (run from package path)
      pre_publish:
        - string                   # optional pre-publish commands

global_version_sources:
  - file: string                   # relative to repo root
    format: json | toml | yaml | regex
    path: string

pre_release:
  - name: string
    command: string                # run from repo root

quality_gates:
  mode: vsdd-full | vsdd-partial | standard
  # vsdd-full fields:
  require_convergence: boolean
  min_convergence_dimensions: integer
  require_holdout: boolean
  min_holdout_satisfaction: float
  require_formal_verification: boolean
  require_adversarial_passes: integer
  require_human_approval: boolean

changelog:
  file: string
  format: keep-a-changelog

ci_workflow: string | null
```

## Out of Scope

- **vsdd-factory remediation:** Same infrastructure (tags, releases, CI,
  config), plus the release skill rewrite. Deferred to a separate spec.
- **Release skill implementation:** Bootstrap mode, config-driven execution,
  dry-run mode, VSDD quality gate enforcement. Lives in vsdd-factory.
- **CI workflow templates:** vsdd-factory seeding mechanism for new repos.
- **Reusable workflows:** Considered and rejected — standalone per-repo
  workflows are simpler and more flexible.

## Sequencing

secops-factory is the proving ground. Validate CI workflows, release config
schema, and tagging process here before applying to vsdd-factory.

Implementation order:
1. CHANGELOG backfill and structural fix
2. Add version field to marketplace.json
3. Create `.factory/release-config.yaml`
4. Create `.github/workflows/ci.yml`
5. Create `.github/workflows/release.yml`
6. Commit all changes
7. Create retroactive git tags (v0.1.0 through v0.5.0)
8. Push tags
9. Create GitHub Releases for all 7 versions

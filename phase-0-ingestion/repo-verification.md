---
artifact: repo-verification
phase: pre-pipeline
generated: 2026-07-19
author: devops-engineer
status: complete
---

# Brownfield Repo Verification

**Target:** `/Users/jmagady/Dev/secops-factory`
**Remote:** `https://github.com/drbothen/secops-factory.git`
**Verification Date:** 2026-07-19

---

## Checklist Results

### 1. Git Remote — PASS

- `git remote -v` confirms `origin` points to `https://github.com/drbothen/secops-factory.git`
- `git ls-remote origin HEAD` resolves cleanly: `e23ff3349e2de2b1254e89339c372b531a8ab3a7`
- Remote is accessible; no authentication errors.

---

### 2. Default Branch — PASS

- `gh repo view --json defaultBranchRef` returns `{ "name": "main" }`
- Local branch is `main`, tracking `origin/main`.
- No branch name mismatch.

---

### 3. CI/CD Workflows — PASS (gaps resolved; see Remediation)

Two workflow files exist at `/Users/jmagady/Dev/secops-factory/.github/workflows/`:

**`.github/workflows/ci.yml`**
- Triggers: push to `main`, all pull requests
- Jobs: `BATS Tests`, `Plugin Structure Validation`, `Shellcheck Hooks`
- Appropriate scope for a markdown plugin repo (no Rust/Node/Python build needed)
- Mounts `.factory` worktree from `factory-artifacts` branch in each job (correct pattern)
- Validates `plugin.json`, `hooks.json`, `hooks.json.windows`, hook sibling pairs, skill SKILL.md files, command-to-skill references, and data files

**`.github/workflows/release.yml`**
- Triggers: tag push matching `v*`
- Permissions: `contents: write` (correct for release creation)
- Jobs: `Pre-release Validation` → `Create GitHub Release`
- Validates tag matches `plugin.json` and `marketplace.json` versions
- Extracts changelog section and creates GitHub Release via `softprops/action-gh-release`

**Functional Assessment:** Both workflows are structurally sound and appropriate for this repo type.

**Gaps identified (human decision required):**

1. **Action versions use tags, not SHA hashes.** Both workflows pin to version tags (`actions/checkout@v6`, `softprops/action-gh-release@v2`). DevOps quality standard requires SHA pinning for supply chain security. No auto-fix applied — see Gaps section below.

2. **No `timeout-minutes` on any job.** All three jobs in `ci.yml` and both jobs in `release.yml` lack explicit timeout values. Default is 360 minutes; a hung step (e.g., `apt-get`) would waste CI minutes for nearly 6 hours.

3. **No security scanning workflow.** There is no `security.yml`. For a markdown-only plugin, `cargo audit`/`cargo deny` are not applicable, but Semgrep with auto rules would catch shell injection in hook scripts and YAML misconfiguration. This is a gap; creation deferred to human decision.

4. **`ci.yml` triggers on push to `main` but `main` has no branch protection** (see item 4 below). Direct pushes to `main` run CI after the fact — not as a gate.

---

### 4. Branch Protection — RESOLVED (see Remediation)

`gh api repos/drbothen/secops-factory/branches/main/protection` returns:

```
{"message":"Branch not protected","status":"404"}
```

The `main` branch has **no protection rules at all**. No status checks are required, no PR reviews are required, and direct pushes are unrestricted. This means:

- CI can be bypassed entirely — a direct push to `main` is not blocked pending checks
- No required reviewers before merge
- No `strict` status check enforcement (branch must be up-to-date with base)

No modification was made — this is a human decision gap (see below).

---

### 5. `.factory/` Worktree — PASS

`git worktree list` output:

```
/Users/jmagady/Dev/secops-factory         e23ff33 [main]
/Users/jmagady/Dev/secops-factory/.factory  6f5f6d7 [factory-artifacts]
```

- `.factory/` is correctly mounted as a worktree on the `factory-artifacts` orphan branch
- Remote `factory-artifacts` branch exists and resolves: `6f5f6d7a8bf4cb7268884dc65f1cca87ec4b6c67`
- Worktree isolation is intact; `.factory/` files are not tracked on `main`
- Contents: `ENHANCEMENT-ANALYSIS.md`, `logs/`, `phase-0-ingestion/`, `plans/`, `release-config.yaml`, `sidecar-learning.md`, `specs/`

---

### 6. Git Rerere — FIXED (was absent, now enabled)

Prior state: `rerere.enabled` was not set in the local repo config.

Applied (local-only, non-destructive):
```
git config rerere.enabled true
git config rerere.autoupdate true
```

These are purely local settings; they do not affect the remote or any other clone.

---

### 7. Merge-Config — RESOLVED (see Remediation)

`/Users/jmagady/Dev/secops-factory/.factory/merge-config.yaml` does **not exist**.

However, `/Users/jmagady/Dev/secops-factory/.factory/release-config.yaml` exists and covers overlapping concerns:
- Version source files (`plugin.json`, `marketplace.json`, `README.md`)
- Pre-release command sequence (BATS, shellcheck, structure validation)
- Changelog format (`keep-a-changelog`)
- CI workflow reference (`release.yml`)

The `release-config.yaml` does not cover merge strategy, worktree management, or inter-wave rebase configuration — those would be `merge-config.yaml` concerns. No file was created; see Gaps section.

---

## Summary

| Check | Result |
|---|---|
| Git remote accessible | PASS |
| Default branch set (`main`) | PASS |
| CI/CD workflows exist and appropriate | PASS — gaps resolved (PR #11) |
| Branch protection on `main` | RESOLVED — applied (PR #11) |
| `.factory/` worktree mounted | PASS |
| Git rerere enabled | FIXED (now enabled) |
| `merge-config.yaml` present | RESOLVED — created 2026-07-19 |

---

## Gaps Requiring Human Decision

1. **Branch protection on `main`:** No rules exist. Recommended minimum: require `CI / BATS Tests`, `CI / Plugin Structure Validation`, `CI / Shellcheck Hooks` as required status checks; optionally require PR before merge. Command to apply (do not run without human approval):
   ```bash
   gh api repos/drbothen/secops-factory/branches/main/protection -X PUT \
     --input - <<'EOF'
   {
     "required_status_checks": {
       "strict": true,
       "contexts": ["BATS Tests", "Plugin Structure Validation", "Shellcheck Hooks"]
     },
     "required_pull_request_reviews": null,
     "enforce_admins": false,
     "restrictions": null
   }
   EOF
   ```
   Note: job name strings must match exactly what GitHub Reports from the workflow `name:` fields.

2. **SHA-pin GitHub Actions:** Replace version tags with full SHA hashes in both workflow files:
   - `actions/checkout@v6` → pin to SHA of that release
   - `softprops/action-gh-release@v2` → pin to SHA of that release
   This is a supply chain security hardening step; deferred to human decision.

3. **Add `timeout-minutes` to all CI jobs:** Prevents runaway jobs from consuming CI minutes. Recommended: 10 minutes for `BATS Tests` and `Plugin Structure Validation`; 15 minutes for `Create GitHub Release`.

4. **Create `merge-config.yaml`:** The VSDD factory template expects `.factory/merge-config.yaml` for worktree lifecycle and merge strategy configuration. The existing `release-config.yaml` covers release automation but not merge coordination. Deferred; state-manager or orchestrator should create this when pipeline operations begin.

5. **Consider adding `security.yml` workflow:** Semgrep with auto rules would catch shell injection in `hooks/*.sh` and YAML misconfiguration. Weekly schedule recommended. Deferred to human decision.

---

REPO_VERIFICATION: PASS (all gaps resolved — see Remediation section below)

---

## Remediation

**Remediation Date:** 2026-07-19
**Executed by:** devops-engineer agent (human-authorized)

### PR #11 — CI Hardening (merged, branch deleted)

Branch `chore/vsdd-repo-hardening` squash-merged to `main` at commit `a025c11`. Branch deleted post-merge.

**Changes shipped in PR #11:**

1. **SHA-pinned `actions/checkout`** — replaced `@v6` tag with full commit SHA `df4cb1c069e1874edd31b4311f1884172cec0e10` in all three CI jobs and both release jobs. Version tag preserved as inline comment (`# v6`) for readability.

2. **SHA-pinned `softprops/action-gh-release`** — replaced `@v2` tag with full commit SHA `3bb12739c298aeb8a4eeaf626c5b8d85266b0e65` in `release.yml`. Version tag preserved as inline comment (`# v2`).

3. **`timeout-minutes` added to all jobs:**
   - `ci.yml`: `BATS Tests`, `Plugin Structure Validation`, `Shellcheck Hooks` — each capped at 10 minutes
   - `release.yml`: `Pre-release Validation`, `Create GitHub Release` — each capped at 15 minutes

4. **`security.yml` created** — new workflow at `/Users/jmagady/Dev/secops-factory/.github/workflows/security.yml`:
   - Triggers: `pull_request`, push to `main`, weekly schedule (Monday 08:00 UTC)
   - Job: `Semgrep Scan`, `timeout-minutes: 10`, `config: auto` (no custom rules)
   - Action: `semgrep/semgrep-action` SHA-pinned at `713efdd345f3035192eaa63f56867b88e63e4e5d` (`# v1`)
   - Permissions: `contents: read`, `security-events: write`

### Branch Protection Applied to `main`

Applied via `gh api` after PR #11 merged. Settings:

| Setting | Value |
|---|---|
| Required status checks | `BATS Tests`, `Plugin Structure Validation`, `Shellcheck Hooks`, `Semgrep Scan` |
| Strict mode (branch must be up-to-date) | `true` |
| Required PR before merging | `true` |
| Required approving reviews | `0` (solo maintainer) |
| Enforce admins | `false` |
| Allow force pushes | `false` |
| Allow deletions | `false` |

Direct pushes to `main` are now blocked. All merges must come through a PR that passes all four required checks.

### Git Rerere — Enabled (local)

Applied during initial verification pass:
```
git config rerere.enabled true
git config rerere.autoupdate true
```
Local-only setting; does not affect CI or other clones.

### `merge-config.yaml` — Created

Written to `/Users/jmagady/Dev/secops-factory/.factory/merge-config.yaml`.
Contents: `target_branch: main`, `worktree_root: .worktrees`, `merge_strategy: squash`, `rerere: enabled`, `required_checks` matching the four branch protection checks above, `inter_wave_rebase` with rerere-assisted auto-rebase and human escalation on unresolved conflicts.
Not committed — state-manager owns factory-artifacts commits.

### Gap Resolution Summary

| Gap | Status |
|---|---|
| Action version tags (not SHA-pinned) | RESOLVED — PR #11 |
| Missing `timeout-minutes` on all jobs | RESOLVED — PR #11 |
| No security scanning workflow | RESOLVED — PR #11 (`security.yml`) |
| No branch protection on `main` | RESOLVED — applied post-merge |
| `merge-config.yaml` absent | RESOLVED — written to `.factory/` |

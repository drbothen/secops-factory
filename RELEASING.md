# Releasing secops-factory

Canonical release procedure. The `vsdd-factory:release` skill defers to this
file when present — deviations from it are what break releases.

Config-driven inputs live in `.factory/release-config.yaml` (on the
`factory-artifacts` orphan branch, worktree-mounted at `.factory/`).

## TL;DR for impatient operators

```bash
# From a clean, up-to-date main with CI green:
git checkout -b release/vX.Y.Z
# Bump the 3 version sources (see Step 2), date the CHANGELOG entry
git commit -am "chore: release vX.Y.Z — <summary>"
git push -u origin release/vX.Y.Z && gh pr create
# Wait for CI green, then:
gh pr merge <N> --squash --delete-branch
git tag -a vX.Y.Z -m "vX.Y.Z: <summary>" <merge-commit-sha>
git push origin vX.Y.Z
# Watch release.yml; verify the GitHub Release; then bump drbothen/claude-mp.
```

## Why this procedure exists in this exact shape

- **Releases go through a PR, not a direct push to `main`.** Direct pushes to
  `main` are blocked by the vsdd-factory `verify-git-push` hook on operator
  machines. Releases v0.5.x and earlier pushed directly; that path is dead.
- **The tag is cut AFTER the merge, on the squash-merge commit.** Squash
  merging rewrites the SHA, so tagging the release-branch commit would produce
  a tag that is not an ancestor of `main`. Always `git tag <merge-commit>`.
- **The tag must match the version files exactly.** The release workflow
  (`.github/workflows/release.yml`) validates the tag against both
  `plugin.json` and `marketplace.json` and fails the release on mismatch.
- **The marketplace is a separate repo.** `drbothen/claude-mp` advertises a
  pinned `version` for secops-factory. Its `source` tracks `main` via
  git-subdir, so *content* updates automatically — but the advertised version
  goes stale until bumped. A release is not done until claude-mp is bumped.

## Mandatory invariants

1. Tag `vX.Y.Z` == `plugins/secops-factory/.claude-plugin/plugin.json`
   `.version` == `.claude-plugin/marketplace.json` `.plugins[0].version`.
2. `CHANGELOG.md` has a dated `## [X.Y.Z] - YYYY-MM-DD` entry with a one-line
   summary under the heading (release.yml extracts this for the release notes).
3. The tag points at a commit on `main` (the squash-merge commit).
4. All pre-release checks pass locally before opening the release PR, with
   `pwsh` on PATH so the cross-platform parity suite actually executes
   (without pwsh those 12 tests silently skip).
5. Release commits are `chore: release vX.Y.Z — <summary>`. No Claude/AI
   attribution in commits.
6. After the GitHub Release exists, bump `drbothen/claude-mp` via PR.

## Step-by-step: cutting a release

### Step 0 — Pre-flight

```bash
git checkout main && git pull
gh run list --branch main --limit 1   # head commit CI must be green
```

Decide the version: MINOR for any `feat`, PATCH for fix-only, MAJOR for
breaking changes. Current version: `jq -r .version plugins/secops-factory/.claude-plugin/plugin.json`.

### Step 1 — Pre-release checks

From `.factory/release-config.yaml` (`pre_release`):

```bash
cd plugins/secops-factory/tests && ./run-all.sh   # with pwsh on PATH
shellcheck plugins/secops-factory/hooks/*.sh
test -f plugins/secops-factory/.claude-plugin/plugin.json
```

Abort on any failure. Fix on a normal feature branch first.

### Step 2 — Bump the 3 version sources

```bash
git checkout -b release/vX.Y.Z
jq '.version = "X.Y.Z"' plugins/secops-factory/.claude-plugin/plugin.json > /tmp/p.json \
  && mv /tmp/p.json plugins/secops-factory/.claude-plugin/plugin.json
jq '.plugins[0].version = "X.Y.Z"' .claude-plugin/marketplace.json > /tmp/m.json \
  && mv /tmp/m.json .claude-plugin/marketplace.json
perl -pi -e 's/version-[0-9.]+-green/version-X.Y.Z-green/' README.md
```

### Step 3 — CHANGELOG

Convert `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD` and add a one-line
summary directly under the heading. If there is no `[Unreleased]` section,
write the entry from `git log $(git describe --tags --abbrev=0)..HEAD --oneline`.

### Step 4 — Release PR

```bash
git add CHANGELOG.md README.md .claude-plugin/marketplace.json \
        plugins/secops-factory/.claude-plugin/plugin.json
git commit -m "chore: release vX.Y.Z — <summary>"
git push -u origin release/vX.Y.Z
gh pr create --title "chore: release vX.Y.Z — <summary>" --body "<what ships + check evidence>"
gh pr checks <N> --watch
```

### Step 5 — Merge, then tag the merge commit

```bash
gh pr merge <N> --squash --delete-branch     # leaves you on updated main
git tag -a vX.Y.Z -m "vX.Y.Z: <summary>" $(git rev-parse HEAD)
git push origin vX.Y.Z
```

### Step 6 — Watch the release workflow

```bash
gh run list --workflow=release.yml --limit 1
gh run watch <run-id> --exit-status
gh release view vX.Y.Z    # must show real CHANGELOG content, not fallback text
```

### Step 7 — Bump the marketplace

In `~/Dev/claude-mp` (or a fresh clone):

```bash
git checkout main && git pull
git checkout -b chore/secops-factory-X.Y.Z
jq '(.plugins[] | select(.name == "secops-factory")).version = "X.Y.Z"' \
  .claude-plugin/marketplace.json > /tmp/mp.json && mv /tmp/mp.json .claude-plugin/marketplace.json
git commit -am "chore: bump secops-factory to X.Y.Z"
git push -u origin chore/secops-factory-X.Y.Z
gh pr create ... && gh pr merge ...
```

Verify: `gh api repos/drbothen/claude-mp/contents/.claude-plugin/marketplace.json --jq '.content' | base64 -d | jq -r '.plugins[].version'`

## Recovery

- **release.yml fails with tag/version mismatch:** a version file didn't get
  bumped. Fix via a follow-up PR, then re-point the tag:
  `git tag -fa vX.Y.Z <new-sha> && git push -f origin vX.Y.Z` (tag force-push
  is acceptable only while the release is broken; never after consumers exist).
- **Tagged the wrong commit (pre-merge SHA):** delete and re-tag:
  `git push origin :refs/tags/vX.Y.Z && git tag -d vX.Y.Z`, then Step 5.
- **Release created with fallback notes:** the CHANGELOG heading didn't match
  `## [X.Y.Z]`. Fix CHANGELOG on main, then `gh release edit vX.Y.Z --notes-file <file>`.
- **claude-mp bump forgotten:** nothing breaks — content tracks `main` — but
  listings and update checks show the old version. Just do Step 7 late.

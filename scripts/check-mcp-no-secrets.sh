#!/usr/bin/env bash
# Guard: fail if any tracked/staged .mcp.json contains literal API-key patterns.
#
# Patterns checked (all known provider key prefixes plus generic sk- keys):
#   pplx-               Perplexity
#   tvly-               Tavily
#   ctx7sk-             Context7
#   exa_[A-Za-z0-9]     Exa
#   sk-[A-Za-z0-9]{16,} generic (OpenAI-style / AWS-style short keys)
#
# Usage:
#   scripts/check-mcp-no-secrets.sh           # checks repo-default file list
#   scripts/check-mcp-no-secrets.sh FILE...   # checks the given files instead
#
# Exit 0 = clean. Exit 1 = at least one literal key found.

set -euo pipefail

# Patterns that indicate a literal API key value.
PATTERNS=(
    'pplx-[A-Za-z0-9_-]'
    'tvly-[A-Za-z0-9_-]'
    'ctx7sk-[A-Za-z0-9_-]'
    'exa_[A-Za-z0-9]'
    'sk-[A-Za-z0-9]{16,}'
)

# Determine which files to check.
if [ $# -gt 0 ]; then
    FILES=("$@")
else
    # Default: every .mcp.json tracked by git plus the plugin's copy.
    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    mapfile -t TRACKED < <(git -C "$ROOT" ls-files '*.mcp.json' '.mcp.json' 2>/dev/null || true)
    # Also include the plugin-level file which may be tracked under a sub-path.
    mapfile -t PLUGIN < <(git -C "$ROOT" ls-files 'plugins/**/.mcp.json' 2>/dev/null || true)
    FILES=()
    for f in "${TRACKED[@]}" "${PLUGIN[@]}"; do
        [ -n "$f" ] || continue
        abs="$ROOT/$f"
        [ -f "$abs" ] && FILES+=("$abs")
    done
    # Deduplicate.
    mapfile -t FILES < <(printf '%s\n' "${FILES[@]}" | sort -u)
fi

if [ ${#FILES[@]} -eq 0 ]; then
    echo "check-mcp-no-secrets: no .mcp.json files found — nothing to check." >&2
    exit 0
fi

FAILURES=0

for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "SKIP (not found): $file" >&2
        continue
    fi
    file_failures=0
    for pat in "${PATTERNS[@]}"; do
        if grep -qE "$pat" "$file" 2>/dev/null; then
            echo "FAIL: literal key pattern '$pat' found in: $file" >&2
            FAILURES=$((FAILURES + 1))
            file_failures=$((file_failures + 1))
        fi
    done
    if [ "$file_failures" -eq 0 ]; then
        echo "OK: $file" >&2
    fi
done

if [ "$FAILURES" -gt 0 ]; then
    echo "" >&2
    echo "check-mcp-no-secrets: $FAILURES literal key pattern(s) found." >&2
    echo "Run: bash scripts/migrate-mcp-keys.sh  (or .ps1 on Windows)" >&2
    echo "to move keys to .envrc.secrets and replace with \${VAR} references." >&2
    exit 1
fi

exit 0

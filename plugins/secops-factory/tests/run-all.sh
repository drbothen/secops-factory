#!/usr/bin/env bash
# secops-factory test runner
# Runs syntax checks and bats tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== secops-factory test suite ==="
echo ""

# Check prerequisites
if ! command -v bats &>/dev/null; then
    echo "ERROR: bats is required but not found."
    echo "Install: brew install bats-core (macOS) or npm install -g bats"
    exit 1
fi

# Syntax check: all shell scripts
echo "--- Syntax check: shell scripts ---"
SHELL_ERRORS=0
for script in "$PLUGIN_ROOT"/hooks/*.sh "$PLUGIN_ROOT"/tests/*.sh; do
    if [ -f "$script" ]; then
        if bash -n "$script" 2>/dev/null; then
            echo "  PASS: $(basename "$script")"
        else
            echo "  FAIL: $(basename "$script")"
            SHELL_ERRORS=$((SHELL_ERRORS + 1))
        fi
    fi
done

if [ "$SHELL_ERRORS" -gt 0 ]; then
    echo "FAIL: $SHELL_ERRORS shell script(s) have syntax errors"
    exit 1
fi
echo ""

# Syntax check: YAML templates
echo "--- Syntax check: YAML templates ---"
YAML_ERRORS=0
for tmpl in "$PLUGIN_ROOT"/templates/*.yaml; do
    if [ -f "$tmpl" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$tmpl'))" 2>/dev/null; then
            echo "  PASS: $(basename "$tmpl")"
        else
            echo "  FAIL: $(basename "$tmpl")"
            YAML_ERRORS=$((YAML_ERRORS + 1))
        fi
    fi
done

if [ "$YAML_ERRORS" -gt 0 ]; then
    echo "FAIL: $YAML_ERRORS YAML template(s) have syntax errors"
    exit 1
fi
echo ""

# Run bats tests
echo "--- Running bats tests ---"
bats "$SCRIPT_DIR/skills.bats"
echo ""
bats "$SCRIPT_DIR/hooks.bats"
echo ""

echo "--- Integration tests (Claude Code protocol) ---"
bats "$SCRIPT_DIR/integration.bats"
echo ""

echo "=== All tests passed ==="

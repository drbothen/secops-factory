#!/usr/bin/env bash
# demo-runner.sh — helper for require-review hook demo recordings
# Usage: demo-runner.sh <vector>
#
# Vectors:
#   link-allow      AC-001/005/007: ["link"] marker + jr issue link → ALLOW
#   wrong-type      AC-002/006/008: ["comment"] marker + jr issue link → DENY (anti-fungibility)
#   create-label    AC-001/C1:      ["create"] marker + REVIEW-REQUIRED label → DENY
#   close-deny      AC-010a:        ["close"] marker + jr issue move WontFix → DENY
#   close-allow     AC-010b:        ["close"] marker + jr issue move Done → ALLOW

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
HOOK="${REPO_ROOT}/plugins/secops-factory/hooks/require-review.sh"

if [[ ! -x "${HOOK}" ]]; then
  echo "ERROR: hook not found at ${HOOK}" >&2
  exit 1
fi

_now() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
_future() {
  if date --version 2>/dev/null | grep -q GNU; then
    date -u -d '+300 seconds' '+%Y-%m-%dT%H:%M:%SZ'
  else
    date -u -v+300S '+%Y-%m-%dT%H:%M:%SZ'
  fi
}

_run_hook() {
  local cmd="$1"
  local plugin_data="$2"
  local json
  json=$(printf '{"tool_input":{"command":%s}}' "$(printf '%s' "${cmd}" | jq -R .)")
  printf '%s' "${json}" | CLAUDE_PLUGIN_DATA="${plugin_data}" "${HOOK}"
}

_write_marker() {
  local dir="$1"
  local name="$2"
  local ops="$3"
  local pattern="$4"
  local ticket="${5:-SEC-1}"
  local NOW EXP
  NOW=$(_now)
  EXP=$(_future)
  cat > "${dir}/${name}.marker.json" <<EOF
{
  "marker_id": "${name}",
  "ticket_id": "${ticket}",
  "org_slug": "demo-org",
  "authorized_operations": ${ops},
  "issued_at_utc": "${NOW}",
  "expires_at_utc": "${EXP}",
  "command_pattern": "${pattern}"
}
EOF
}

VECTOR="${1:-}"

case "${VECTOR}" in

  link-allow)
    echo "--- AC-001/005/007: [\"link\"] marker + jr issue link SEC-1 SEC-2 ---"
    T=$(mktemp -d); M="${T}/markers"; mkdir -p "$M"
    _write_marker "$M" "link-demo" '["link"]' "^jr (--output json )?issue link SEC-1 SEC-2"
    echo "Marker: authorized_operations=[\"link\"], command_pattern anchored to SEC-1 SEC-2"
    echo ""
    echo "Command: jr issue link SEC-1 SEC-2"
    DECISION=$(_run_hook "jr issue link SEC-1 SEC-2" "$T" | jq -r '.hookSpecificOutput.permissionDecision')
    echo "Result:  ${DECISION}"
    echo ""
    CONSUMED=$(ls "${M}"/*.used 2>/dev/null | wc -l | tr -d ' ')
    echo "Marker consumed (single-use atomic rename): ${CONSUMED} file(s) renamed to .used"
    rm -rf "$T"
    ;;

  wrong-type)
    echo "--- AC-002/006/008: [\"comment\"] marker + jr issue link → DENY (anti-fungibility) ---"
    T=$(mktemp -d); M="${T}/markers"; mkdir -p "$M"
    _write_marker "$M" "comment-demo" '["comment"]' "^jr (--output json )?issue link"
    echo "Marker: authorized_operations=[\"comment\"]  (wrong type for link command)"
    echo ""
    echo "Command: jr issue link SEC-1 SEC-2"
    DECISION=$(_run_hook "jr issue link SEC-1 SEC-2" "$T" | jq -r '.hookSpecificOutput.permissionDecision')
    echo "Result:  ${DECISION}"
    echo ""
    echo "STEP 6 exact-type match: [\"comment\"] ≠ [\"link\"] → marker NOT consumed → DENY"
    rm -rf "$T"
    ;;

  create-label)
    echo "--- AC-001/C1: [\"create\"] marker + --label REVIEW-REQUIRED → DENY (structural_label_check) ---"
    T=$(mktemp -d); M="${T}/markers"; mkdir -p "$M"
    _write_marker "$M" "create-demo" '["create"]' "^jr issue create" "SEC-99"
    echo "Marker: authorized_operations=[\"create\"]"
    echo ""
    CMD='jr issue create --summary "Vuln" --label REVIEW-REQUIRED'
    echo "Command: ${CMD}"
    DECISION=$(_run_hook "${CMD}" "$T" | jq -r '.hookSpecificOutput.permissionDecision')
    echo "Result:  ${DECISION}"
    echo ""
    echo "C1: [\"create\"] marker cannot authorize REVIEW-REQUIRED labeled create → requires [\"create-review\"]"
    rm -rf "$T"
    ;;

  close-deny)
    echo "--- AC-010a: [\"close\"] marker + jr issue move WontFix → DENY (not in CLOSE_STATE_ALLOWLIST) ---"
    T=$(mktemp -d); M="${T}/markers"; mkdir -p "$M"
    _write_marker "$M" "close-demo" '["close"]' \
      "^jr issue move SEC-42 (Done|Closed|Resolved)$" "SEC-42"
    echo "Marker: authorized_operations=[\"close\"], pattern bound to CLOSE_STATE_ALLOWLIST={Done,Closed,Resolved}"
    echo ""
    echo "Command: jr issue move SEC-42 WontFix"
    DECISION=$(_run_hook "jr issue move SEC-42 WontFix" "$T" | jq -r '.hookSpecificOutput.permissionDecision')
    echo "Result:  ${DECISION}"
    echo ""
    echo "WontFix ∉ CLOSE_STATE_ALLOWLIST → command_pattern mismatch → DENY (SM-63 kill)"
    rm -rf "$T"
    ;;

  close-allow)
    echo "--- AC-010b: [\"close\"] marker + jr issue move Done → ALLOW (Done ∈ CLOSE_STATE_ALLOWLIST) ---"
    T=$(mktemp -d); M="${T}/markers"; mkdir -p "$M"
    _write_marker "$M" "close-demo" '["close"]' \
      "^jr issue move SEC-42 (Done|Closed|Resolved)$" "SEC-42"
    echo "Marker: authorized_operations=[\"close\"], pattern bound to CLOSE_STATE_ALLOWLIST={Done,Closed,Resolved}"
    echo ""
    echo "Command: jr issue move SEC-42 Done"
    DECISION=$(_run_hook "jr issue move SEC-42 Done" "$T" | jq -r '.hookSpecificOutput.permissionDecision')
    echo "Result:  ${DECISION}"
    echo ""
    CONSUMED=$(ls "${M}"/*.used 2>/dev/null | wc -l | tr -d ' ')
    echo "Done ∈ CLOSE_STATE_ALLOWLIST → ALLOW; marker consumed: ${CONSUMED} .used file(s)"
    rm -rf "$T"
    ;;

  *)
    echo "Usage: $0 <vector>"
    echo "Vectors: link-allow | wrong-type | create-label | close-deny | close-allow"
    exit 1
    ;;
esac

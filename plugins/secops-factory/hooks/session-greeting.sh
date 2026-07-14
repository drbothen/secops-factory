#!/usr/bin/env bash
# session-greeting.sh — SessionStart hook that greets the analyst when the
# SecOps Factory orchestrator is this project's default agent.
#
# Activation-gated: only fires when .claude/settings.local.json sets
# agent = secops-factory:orchestrator:orchestrator (written by
# /secops-factory:activate). Silent no-op otherwise — enabling the plugin
# alone must never greet (no hijack-on-enable).
#
# Emits a systemMessage banner (shown in the terminal at session start,
# before the first user message) plus additionalContext so Morgan's first
# model reply continues in-flow instead of re-introducing itself.
# Deterministic, <100ms, no LLM.

set -euo pipefail

INPUT=$(cat)

# Resolve the project dir: prefer the payload's cwd, fall back to env/PWD.
PROJECT_DIR=""
if command -v jq &>/dev/null; then
  PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
fi
if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
fi

SETTINGS="$PROJECT_DIR/.claude/settings.local.json"
[ -f "$SETTINGS" ] || exit 0

# Activation gate — jq when available, grep fallback (an exact string
# match on the agent value is sufficient for the gate).
if command -v jq &>/dev/null; then
  AGENT=$(jq -r '.agent // empty' "$SETTINGS" 2>/dev/null || true)
  [ "$AGENT" = "secops-factory:orchestrator:orchestrator" ] || exit 0
else
  grep -qF '"secops-factory:orchestrator:orchestrator"' "$SETTINGS" || exit 0
fi

BANNER="[SecOps Factory] Morgan here - SOC companion active. Tell me what you're working on, or pick: 1) enrich ticket  2) investigate event  3) advisory  4) review work  5) health check"
CONTEXT="SessionStart: the SecOps Factory orchestrator is active and the analyst was already shown Morgan's greeting banner with the 5-option menu (1=enrich ticket, 2=investigate event, 3=advisory, 4=review work, 5=health check). Do not re-introduce yourself from scratch; respond to the analyst's first message in-flow. A bare digit 1-5 selects the corresponding menu option."

if command -v jq &>/dev/null; then
  jq -nc --arg banner "$BANNER" --arg ctx "$CONTEXT" '{
    systemMessage: $banner,
    hookSpecificOutput: { hookEventName: "SessionStart", additionalContext: $ctx }
  }'
else
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$BANNER" "$CONTEXT"
fi
exit 0

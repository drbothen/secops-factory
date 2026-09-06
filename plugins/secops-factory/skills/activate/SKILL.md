---
name: activate
description: "Opt in to the SecOps Factory companion for this project. Writes .claude/settings.local.json to set the orchestrator (Morgan, the SOC Operations Coordinator) as the default main-thread agent. Reversible via /secops-factory:deactivate."
disable-model-invocation: true
---

# Activate SecOps Factory

Per-project opt-in. Enabling the plugin alone does not change your default Claude persona — it only makes the factory's agents, skills, and hooks available. Running this skill flips the default agent to the orchestrator, so a plain session becomes the SOC companion: Morgan greets the analyst, routes tasks to the right workflow, and tracks pipeline position.

## Announce at Start

Before any other action, say verbatim:

> I am using the activate skill to set the SecOps Factory orchestrator as this project's default agent.

## Procedure

1. **Confirm project intent.** If the current directory shows no sign of security operations work (no JIRA config, no prior enrichment artifacts, user seems surprised), confirm the user wants this project's default persona changed. Activation is always an explicit user action.

2. **Read existing `.claude/settings.local.json`.** If it doesn't exist, start from `{}`. If it exists, parse it with `jq` — never blind-overwrite.

3. **Check for a conflicting default agent.** If an `agent` key already exists and does not point at a `secops-factory:` agent, warn the user which agent currently holds the default (e.g., another plugin's orchestrator) and ask before replacing it.

4. **Collect and validate `jira_project_key`.** Prompt the operator for the Jira project key. The value MUST match `^[A-Z][A-Z0-9]+$` (uppercase alphanumeric only — no hyphens, no lowercase, no spaces). If the value does not conform, emit the error below and refuse to complete activation. No partial state is written.

   > Invalid Jira project key '<X>': Jira project keys must be uppercase alphanumeric with no hyphens or spaces — e.g., PRISMDEMO, SEC, SECOPS.

   (BC-6.01.001 PC#12/EC-014; VP-SKILL-076 activate leg; D-DEC-008; P13-002 CRITICAL)

5. **Collect and validate `jira_close_state`.** Prompt the operator for the Jira transition state used when auto-closing tickets.

   The `CLOSE_STATE_ALLOWLIST` = {"Done", "Closed", "Resolved"} is the complete, hardcoded set of permitted values. This list is NOT verdict-influenceable (D-021 invariant): it is CONFIG-side only, fixed at setup time, and never read from verdict fields at monitoring-loop runtime — this closes the LLM injection surface on close-state selection.

   The check is case-sensitive: "done", "DONE", and "closed" are NOT valid — only the exact title-case strings in the allowlist are accepted.

   If the provided value is outside the allowlist, emit the error below and refuse to complete activation. No partial state is written.

   > Invalid Jira close state '<value>': allowed values are Done, Closed, Resolved.

   (BC-6.01.001 PC#13/EC-015; P18-005; D-021)

6. **Run the prism version gate.** Before writing any MCP configuration, verify the installed prism binary meets the minimum required version `1.0.0-rc.1`. Use the subprocess call `prism --version` (not MCP ping — MCP is not yet configured at this point) and run the bundled version gate helper:

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/hooks/prism-version-check.sh"
   ```

   If the installed prism does not meet minimum requirement `1.0.0-rc.1`, halt activation with the version-gate error and write no configuration files (`settings.local.json` and `prism.mcp.json` are NOT written).

   Once the version gate passes, perform the dual MCP write:
   - Merge the MCP server block into `.claude/settings.local.json` (setting `RUST_LOG=off` in the prism MCP env block).
   - Write `prism.mcp.json` (D-DEC-003 cron/headless config), also setting `RUST_LOG=off` in the env block.

   **Invariant #5 — `RUST_LOG=off` in both MCP locations:** `RUST_LOG=off` MUST be injected in BOTH `settings.local.json` and `prism.mcp.json`. Omitting it from either location allows prism stderr log lines to corrupt the stdio MCP transport framing (BC-6.01.001 invariant #5).

   (BC-6.01.001 PC#8-9; VP-SKILL-051 prism version gate; invariant #5)

7. **Merge the activation block.** Write the file back with these fields merged, preserving all other top-level keys:

   ```json
   {
     "agent": "secops-factory:orchestrator:orchestrator",
     "secops-factory": {
       "activated_at": "<ISO 8601 timestamp with timezone>",
       "activated_plugin_version": "<version from .claude-plugin/plugin.json>"
     }
   }
   ```

8. **Apply the per-platform hooks variant.** The plugin ships two `hooks.json` variants: the committed default invokes the `.sh` hook scripts (macOS, Linux, WSL, Git Bash — no action needed), and `hooks.json.windows` invokes the `.ps1` siblings via `powershell.exe`.

   Detect the host: if running on native Windows (PowerShell/cmd shell, `$env:OS` = `Windows_NT`, and not inside WSL or Git Bash), copy the Windows variant into place:

   ```powershell
   Copy-Item "${CLAUDE_PLUGIN_ROOT}/hooks/hooks.json.windows" "${CLAUDE_PLUGIN_ROOT}/hooks/hooks.json" -Force
   ```

   On macOS/Linux/WSL/Git Bash, leave `hooks.json` untouched. Note for Windows users: a plugin update restores the default `hooks.json`, so re-run `/secops-factory:activate` after updating the plugin.

9. **Confirm activation.** Print:
   - File written (`.claude/settings.local.json`)
   - New default agent (`secops-factory:orchestrator:orchestrator`)
   - Hooks variant applied (default `.sh` or Windows `.ps1`)
   - That Morgan will greet at the start of each new session in this project (the session-greeting SessionStart hook is activation-gated)
   - That the change takes effect on the next session (restart Claude Code or start a new session in this project)
   - How to reverse it (`/secops-factory:deactivate`)
   - Reminder that this only affects the current project — `settings.local.json` is per-project and typically gitignored, so teammates opt in individually

10. **Suggest a health check.** Recommend running `/secops-factory:secops-health` once in the new session to verify jr CLI and Perplexity MCP before the first enrichment.

## Dry-run mode

If the user invokes the skill with `--dry-run` (or asks for a preview), perform steps 1–3 but skip the file write and the hooks variant copy. Print the proposed `settings.local.json` diff and which hooks variant would be applied, then exit.

## Red Flags

| Thought | Reality |
|---|---|
| "settings.local.json doesn't parse, I'll overwrite it" | Never clobber a corrupt file. Show the user the parse error and let them decide. |
| "Another plugin's agent is set, mine is more important" | Ask before replacing a non-secops default agent. Two factories can't both own the main thread. |
| "I'll set this in the shared settings.json so the whole team gets it" | Activation is per-person, per-project. `settings.local.json` only. |
| "The plugin is enabled, so it's already activated" | Enablement makes skills available; only this skill changes the default persona. |
| "I'll also modify hooks or permissions while I'm in there" | Touch only the `agent` key and the `secops-factory` block. Preserve everything else. |
| "Activation failed silently, but I'll report success" | Verify the write with `jq` read-back before confirming to the user. |

## Notes

- **No "hijack on enable".** Plugin-level settings (which would set the agent automatically on install) is the alternative we deliberately did not choose — same decision as vsdd-factory. Activation is always an explicit user action.
- **Coexistence:** secops-factory and other factory plugins (e.g., vsdd-factory) can be enabled side by side; whichever was *activated* owns the main-thread persona. Deactivate one before activating the other.

## See also

- `/secops-factory:deactivate` — reverse this
- Orchestrator agent: `${CLAUDE_PLUGIN_ROOT}/agents/orchestrator/orchestrator.md`

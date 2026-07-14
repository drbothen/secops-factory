---
name: deactivate
description: "Reverse /secops-factory:activate — remove the orchestrator default-agent override and the activation metadata from .claude/settings.local.json. Leaves the plugin enabled; only the default persona is cleared."
disable-model-invocation: true
---

# Deactivate SecOps Factory

Reverses everything `/secops-factory:activate` does: clears the orchestrator default-agent override in `.claude/settings.local.json` and removes the `secops-factory` activation block. The plugin itself stays enabled — agents, skills, hooks, and commands remain available for explicit invocation or future re-activation.

## Announce at Start

Before any other action, say verbatim:

> I am using the deactivate skill to remove the SecOps Factory orchestrator as this project's default agent.

## Procedure

1. **Read `.claude/settings.local.json`.** If it doesn't exist, the factory was never activated here — say so and stop.

2. **Sanity-check the agent default.** If the existing `agent` value does not point at a `secops-factory:` agent, stop and warn — don't clobber unrelated config (another plugin may own the default).

3. **Remove the keys.** Use `jq 'del(.agent) | del(.["secops-factory"])'` and write the file back. If the resulting object is empty, either delete the file or leave it as `{}` — ask the user which.

4. **Confirm.** Print:
   - The remaining `settings.local.json` contents
   - That the plugin is still enabled (individual skills, commands, and agents remain invokable)
   - That the change takes effect on the next session
   - That `/secops-factory:activate` is the inverse

## Red Flags

| Thought | Reality |
|---|---|
| "The agent key points at vsdd-factory, I'll remove it anyway" | Stop and warn. Only remove a `secops-factory:` default — never another plugin's. |
| "I'll delete the whole settings file to be thorough" | Other keys (permissions, env) may live there. Delete only the two activation keys. |
| "Deactivating means uninstalling the plugin" | No — the plugin stays enabled. Only the default persona is cleared. |
| "The file doesn't exist, I'll create an empty one" | Nothing to do. Report that the factory was never activated and stop. |
| "I'll skip the read-back verification" | Verify with `jq` after writing. A malformed settings file breaks the whole session. |
| "The user probably wants the hooks disabled too" | Hooks belong to plugin enablement, not activation. Leave them alone. |

## See also

- `/secops-factory:activate` — the inverse

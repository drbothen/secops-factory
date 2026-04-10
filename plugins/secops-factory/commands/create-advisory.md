---
description: Create a structured security advisory for a CVE, threat campaign, or vendor bulletin. Supports IT, ICS/OT, and combined audiences with built-in or custom templates.
argument-hint: "<topic|CVE-ID> [--template path] [--type it|ics|combined]"
---

Use the `create-advisory` skill via the Skill tool to draft a security advisory for `$ARGUMENTS`.

Researches the topic, selects or loads a template, verifies all data against authoritative sources, and presents a draft for review. Supports custom organization templates via `--template`.

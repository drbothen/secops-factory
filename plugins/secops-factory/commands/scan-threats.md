---
description: Scan for emerging security threats and identify advisory-worthy items. Filters by sector, severity, and environment type (IT/ICS/Combined).
argument-hint: "[--sector energy|water|manufacturing|all] [--severity critical|high|medium] [--days 7]"
---

Use the `scan-threats` skill via the Skill tool to scan recent security intelligence for `$ARGUMENTS`.

Returns a prioritized table of advisory candidates scored by severity, exploit status, KEV listing, sector relevance, and recency. Recommends which items warrant a full advisory.

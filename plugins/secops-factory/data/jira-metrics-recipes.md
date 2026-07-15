# Jira Metrics Recipes

Concrete, tested query-and-computation patterns for every Jira ground-truth metric in `/generate-metrics`. Companion to `effort-analysis-method.md` (which owns schema discovery, the background-fetch pattern, session reconstruction, and trend rules — read it first; recipes below reference it as METHOD).

All recipes use `jr --output json` + Python 3 stdlib. Org parameters (project key, client field, terminal statuses, business hours, priority field) come from the local priors file `artifacts/metrics/effort-priors.yaml`.

---

## Recipe 0 — Shared fetch layer

### 0.1 List-level data (cheap — one query per slice)

List payloads include `created`, `issuetype`, `status`, `assignee`, `priority`, `resolutiondate` (verify on your instance — dump one list element's keys before trusting). Enough for: volume, net flow, aging, storm detection, workload counts.

### 0.2 Changelog-level data (3 calls/ticket — background, resumable)

Required for: dwell time, time-to-first-touch, reopen rate, cycle time. Use the METHOD §2.1 fetch loop verbatim (`view`/`changelog`/`comments` with `[ -s ]` guards).

**Probe the changelog shape before writing extraction code** — field names vary by jr version:

```bash
jr --output json issue changelog <KEY> | python3 -m json.tool | head -40
```

Expected shape: entries with `created` (timestamp) and a list of per-field changes carrying `field`/`fieldId`, `fromString`, `toString`. Adapt the extractor below to what the probe shows; do not guess.

### 0.3 Status-transition extraction

```python
def transitions(log):
    """[(when, from_status, to_status)] sorted by time."""
    out = []
    for e in log.get('entries', []):
        for it in e.get('changes', e.get('items', [])):
            if (it.get('field') or it.get('fieldId') or '').lower() == 'status':
                out.append((parse(e['created']), it.get('fromString'), it.get('toString')))
    return sorted(out)
```

### 0.4 Priority source rule

Before computing any per-priority metric, sample the priority field distribution (METHOD §0.4). If the native field is an intake artifact (majority Unspecified), use the plugin-managed priority custom field (`update-jira` writes it) named in the priors file — and say which source was used in the deliverable.

---

## Recipe 1 — SLA & responsiveness

SLA targets from `data/priority-framework.md`: P1 = 24h, P2 = 7d, P3 = 30d, P4 = 90d, P5 = none.

### 1.1 Time-to-first-touch

First touch = earliest of (first changelog entry, first comment) after creation:

```python
def first_touch_hours(view, log, coms):
    f = view['fields']; created = parse(f['created'])
    events = [parse(e['created']) for e in log.get('entries', [])]
    events += [parse(c['created']) for c in coms]
    events = [t for t in events if t > created]
    return (min(events) - created).total_seconds()/3600 if events else None  # None = never touched
```

Report per priority tier: median, p85, and the never-touched count (they are findings, not missing data).

### 1.2 Time-to-resolution & SLA breach rate

Resolution = first transition INTO a terminal status (priors file `terminal_statuses`, default `["Done","Closed","Resolved","Completed"]`):

```python
SLA_H = {'P1': 24, 'P2': 7*24, 'P3': 30*24, 'P4': 90*24, 'P5': None}
def resolution_hours(view, log, terminal):
    created = parse(view['fields']['created'])
    done = [w for (w, frm, to) in transitions(log) if to in terminal]
    return (done[0]-created).total_seconds()/3600 if done else None
# breach: resolution_hours > SLA_H[tier]; open tickets past their SLA count as breaches-in-progress
```

Report per tier and per client: breach %, median resolution, breaches-in-progress. State the priority source (Recipe 0.4).

### 1.3 Patch latency (vulnerability tickets)

Same as 1.2 restricted to vuln ticket types, segmented by KEV status (plugin custom field, else Phase-5-style comment extraction). Deliverable: KEV vs non-KEV median/p85 — the gap is the story.

---

## Recipe 2 — Flow & backlog health

### 2.1 Status dwell time

```python
from collections import defaultdict
def dwell_hours(view, log, now):
    f = view['fields']; t = transitions(log)
    d = defaultdict(float); cur = t[0][1] if t else f['status']['name']; prev = parse(f['created'])
    for (w, frm, to) in t:
        d[frm or cur] += (w - prev).total_seconds()/3600; prev, cur = w, to
    d[cur] += (now - prev).total_seconds()/3600   # time in current status
    return d
```

Aggregate mean/median per status per issue type. The status with the largest median dwell is the bottleneck candidate — check whether it's a wait state (queue) or a work state before recommending anything.

### 2.2 Cycle time

Created → first terminal transition (Recipe 1.2), per issue type: median, p85. Exclude tickets still open from the distribution; report their count separately.

### 2.3 Net flow & aging WIP (list-level only)

```python
# per ISO week: created counts vs resolved counts (resolutiondate or terminal transition)
# aging buckets for open tickets: 0-7d, 7-30d, 30-90d, >90d, by type and client
```

Growing >90d bucket + negative net flow = backlog problem; say both numbers together.

### 2.4 Reopen rate

A reopen = any transition FROM a terminal status to a non-terminal one. Report: % of resolved tickets ever reopened, per type; multi-reopen tickets listed individually (they are process findings).

---

## Recipe 3 — Signal quality & noise

### 3.1 Alert-storm detection (list-level)

```python
# daily created counts over the window; flag days > mean + 3*stdev of the TRAILING 30 days
# (trailing baseline — a storm must not inflate its own threshold)
```

Report storm days with counts and the dominant client/type that day. Cross-reference before trend claims (METHOD Phase 1: single-client artifacts masquerade as desk trends).

### 3.2 Repeat-offender clusters

```python
import re
def norm(summary):  # strip numbers/IPs/dates so recurring alerts collapse to one key
    s = re.sub(r'\d+\.\d+\.\d+\.\d+', '<ip>', summary.lower())
    return re.sub(r'\d+', '<n>', s).strip()
# group by (client, norm(summary)); clusters with >=5 tickets/window are digest-ticket candidates
```

Deliverable: top clusters with counts and the projected reduction if converted to weekly digest tickets (~5× cut on clustered volume — METHOD §4.4 lever).

### 3.3 False-positive burden

```
FP burden (h/mo) = FP tickets/mo × per-type effort with overhead (priors file)
```

FP counts come from disposition data: the plugin's investigation artifacts, a disposition custom field, or Phase-5-style comment extraction (`disposition\s*[:=]`, whitelist `{tp, fp, btp}` + long forms). Report coverage like severity extraction — an FP rate at 40% disposition coverage is labeled as such.

### 3.4 Ticketing conversion

`tickets ÷ upstream alerts` — only when the caller supplies the pipeline alert count (Jira can't see it). Label the denominator's source. When verifying someone else's conversion figure, that's `/verify-metrics-report`'s derived-column check.

---

## Recipe 4 — Workload & distribution

**Sensitivity rule: per-analyst figures are for capacity planning, aggregate views only in shared docs. Never rank individuals in anything that leaves artifacts/.**

### 4.1 Assignee distribution (list-level)

Ticket counts per assignee per month, by type. Pair with touch-session counts (METHOD §2.2 rows carry the data) for an effort-weighted view — raw counts overweight templated tickets.

### 4.2 After-hours share

From session data: share of sessions starting outside priors-file `business_hours` (default 08:00–18:00 local, Mon–Fri; timezone from priors). Report desk-level; per-analyst only on explicit request.

### 4.3 Per-client mix shift

Type-mix percentages per client, month over month; flag clients whose Event Alert share moved >10 points (tuning events and onboarding show up here first).

---

## Deliverable conventions

Same as METHOD: every table carries its window and units; trend claims carry R² (ranging rule); coverage counts are mandatory wherever extraction was involved; per-analyst and per-client identifiers stay in `artifacts/metrics/`; the priority-source statement (Recipe 0.4) appears in any per-priority table.

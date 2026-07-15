# Ticket Effort & Cost Analysis Method

Reproducible method to (1) measure analyst time spent populating/maintaining Jira tickets, (2) baseline ticket volume per client, (3) T-shirt-size clients via OSINT, (4) model annual ticket-administration cost, and (5) extract severity/criticality when no native field exists — using only the `jr` CLI and Python 3 stdlib. No worklogs, no Jira admin access, no marketplace apps.

Org-specific parameters (project key, client custom-field ID, rates, measured priors, exclusion lists) live in the **local priors file** `artifacts/metrics/effort-priors.yaml` — see `${CLAUDE_PLUGIN_ROOT}/templates/effort-priors-tmpl.yaml`. That file is per-org and must never be committed to a shared repo.

---

## Phase 0 — Prerequisites & schema discovery

### 0.1 Verify jr

```bash
jr --version && jr me    # auth check
```

### 0.2 Discover how clients are attributed

Ticket **lists do NOT return custom fields** — only `issue view` does. Dump one known ticket:

```bash
jr --output json issue view <KEY> | python3 -c "
import json,sys
f=json.load(sys.stdin)['fields']
for k,v in f.items():
    if v and 'customfield' in k: print(k,'=',json.dumps(v)[:160])"
```

Record the client field ID in the priors file. If it is an Assets/CMDB object field:

**JQL rules (validated):**
- `cf[NNNNN] = "<Label>"` ✅ — query by *label*
- `cf[NNNNN] = "<OBJECT-KEY>"` ❌ — object keys return 0 results
- `"<Display Name>" = "..."` ❌ — field display names do not work

### 0.3 Enumerate clients

```bash
jr --output json assets search 'objectType = "Client"'
```

Inspect each record (`jr --output json assets view <KEY>`) before trusting names:
- Location attributes disambiguate generic names.
- Demo/test and internal entries exist — maintain the exclusion list in the priors file.
- If the schema has device-count fields (e.g., `Managed_Devices`), check whether they are populated — a populated monitored-footprint field is the true volume predictor and supersedes size buckets.

### 0.4 Field-quality survey

Before trusting any native field, sample it:
- **Worklogs:** usually empty on ops desks → effort must be reconstructed from events (Phase 2).
- **Priority:** often an intake artifact, not criticality — check the value distribution; a field that is 60%+ "Unspecified" is junk. Real severity may live in analyst worksheet comments (Phase 5).

---

## Phase 1 — Volume baseline (per client, per type, per month)

One JQL query per client label — list payloads carry `created`, `issuetype`, `status`, `assignee`, enough for volume work:

```python
import json, subprocess
from collections import Counter, defaultdict
def q(jql):
    r = subprocess.run(['jr','--output','json','issue','list','--jql',jql,'--all'],
                       capture_output=True, text=True)
    try: return json.loads(r.stdout)
    except: return []

clients = [...]   # labels from Phase 0.3, minus exclusions
bytype = {}; bymonth = defaultdict(Counter)
for c in clients:
    issues = q(f'project = <PROJ> AND created >= -180d AND cf[<NNNNN>] = "{c}"')
    bytype[c] = Counter(i['fields']['issuetype']['name'] for i in issues)
    for i in issues: bymonth[c][i['fields']['created'][:7]] += 1
# ALWAYS cross-check: len(q('project = <PROJ> AND created >= -180d')) vs sum attributed
```

**Trend interpretation rules:**
- Monthly counts → mean, stdev, linear regression slope + R².
- **R² < ~0.3 ⇒ "ranging", not trending** — even if the slope looks meaningful.
- Exclude onboarding-ramp months before comparing halves.
- Look for single-client artifacts (one client's alert storm or tuning event) before declaring a desk-wide trend.

---

## Phase 2 — Per-ticket effort measurement (the core method)

**Concept:** Jira never records typing time, but every creation, field edit, and comment is timestamped. Chain a ticket's events into *work sessions*; session spans approximate active in-Jira effort. Best available signal when worklogs are empty.

### 2.1 Fetch raw history (3 calls/ticket — background for >50 tickets)

```bash
D=/tmp/effort_data; mkdir -p $D
# keys.txt = one issue key per line (from a Phase-1 query)
while read k; do
  [ -s "$D/$k.view.json" ] || jr --output json issue view $k      > $D/$k.view.json 2>/dev/null
  [ -s "$D/$k.log.json"  ] || jr --output json issue changelog $k > $D/$k.log.json  2>/dev/null
  [ -s "$D/$k.com.json"  ] || jr --output json issue comments $k  > $D/$k.com.json  2>/dev/null
done < keys.txt
```

The `[ -s ]` guards make it resumable. Throughput ≈ 2 files/sec.

### 2.2 Session reconstruction

```python
import json, statistics
from datetime import datetime
def parse(s): return datetime.strptime(s, '%Y-%m-%dT%H:%M:%S.%f%z')
def adf_text(node):                      # Jira ADF -> plain text
    out = []
    def walk(n):
        if isinstance(n, dict):
            if n.get('type') == 'text': out.append(n.get('text', ''))
            for c in n.get('content', []) or []: walk(c)
        elif isinstance(n, list):
            for c in n: walk(c)
    walk(node); return ' '.join(out)

GAP = 30 * 60          # >30 min between events = new session
OVERHEAD_MIN = 5       # per-session context/read/form overhead

rows = []
for k in keys:
    view = json.load(open(f'{D}/{k}.view.json'))
    log  = json.load(open(f'{D}/{k}.log.json'))
    coms = json.load(open(f'{D}/{k}.com.json'))
    f = view['fields']
    events = [parse(f['created'])]
    events += [parse(e['created']) for e in log.get('entries', [])]
    events += [parse(c['created']) for c in coms]
    events.sort()
    sessions = []; start = prev = events[0]
    for t in events[1:]:
        if (t - prev).total_seconds() > GAP: sessions.append((start, prev)); start = t
        prev = t
    sessions.append((start, prev))
    rows.append(dict(
        key=k, type=f['issuetype']['name'], month=f['created'][:7],
        auth =(sessions[0][1]-sessions[0][0]).total_seconds()/60,   # authoring burst
        touch=sum((b-a).total_seconds() for a,b in sessions)/60,    # total burst time
        nsess=len(sessions),
        words=len(adf_text(f.get('description') or {}).split())
             +sum(len(adf_text(c.get('body') or {}).split()) for c in coms)))
```

Report per issue type: mean/median of `auth`, `touch`, `nsess`, `words`; and `total = touch + nsess*OVERHEAD_MIN` for the with-overhead figure.

### 2.3 Known biases — state them in EVERY writeup

- **Undercounts:** form-fill time *before* pressing Create is invisible; a session with one event measures ~0. Burst time is a **lower bound** → hence +5 min/session overhead.
- **Overcounts (for "pure admin" questions):** ticket types whose in-Jira time includes deliverable authorship (analysis write-ups, threat-hunt worksheets) mix authorship with form-filling. Exclude those types from "automatable savings"; keep them in "total in-Jira time".
- **Sample-window sensitivity:** 30-day snapshots run light vs 12-month numbers. Use ≥6–12 months for rate-setting.

### 2.4 Priors

Measured per-type effort priors (touch avg/median, sessions avg, with-overhead) belong in the **local priors file** after your first full run. Reuse them for projections; re-measure when workflows change.

---

## Phase 3 — Client T-shirt sizing (OSINT)

1. One Perplexity query per client (`perplexity_ask`): revenue, employees, and a sector-appropriate scale metric (meters/customers for utilities, MW for plants, bpd for refineries). Always request citations.
2. **Disambiguate generic names via the Assets record first** — never research a name blind.
3. Bucket on **organizational scale — headcount primary, revenue secondary**:
   - Large: >$1B revenue AND >5k employees
   - Medium: $100M–$1B or several-hundred-employee org / major single industrial site
   - Small: <~100 org staff (single-site plants, co-ops, small munis, towns)
4. Trust rules: data-broker revenue for private subsidiaries is often wrong — headcount is the reliable signal. Verify any load-bearing number before client-facing use.

**Re-test each run:** client size does NOT reliably predict ticket volume — monitored footprint and tuning maturity do. Compute per-bucket averages both ways: all clients and active-only.

---

## Phase 4 — Cost model

### 4.1 Rates

Rates are org-specific and belong in the local priors file:
- **Burdened (cost basis):** salary × burden multiplier, or top-down bill-rate ÷ 2.5–3. Get exact figures from finance when it matters.
- **Opportunity (billable) basis:** full bill rate — valid only if analysts are utilization-constrained.

Lead with burdened for finance docs; show opportunity as upside.

### 4.2 Per-client or prospect annual cost

```
volume (tickets/mo) × type mix × per-type effort (Phase 2 priors, with overhead)
= hours/yr × rate = annual ticket-administration cost
```

For a **prospect**: size it (Phase 3) → pick the **closest existing analog client** (same sector + scale) → use the analog's volume and type mix, with the bucket average as the low anchor. Present **Low/Base/High scenarios**. Always state: **figures exclude executing the work**.

### 4.3 Standard risk notes for pricing docs

1. Onboarding/tuning spike: 2–4× steady-state for the first months.
2. Double-entry: client-system mirroring doubles the mechanical portion unless automated — check what share of volume is templated.
3. Effort priors measured on one client's history; analog mix projected from another.

### 4.4 Severity-gating option (when asked to cut price)

If only a small share of alerts are High/Critical, a "Crit/High-only" tier collapses volume — quote the math but flag that severity labels are the vendor tool's, and real OT tradecraft often lives in Medium (SCADA external comms, scans, RMM abuse). Prefer these levers instead: gate *ticketing* not *triage*, weekly digest tickets for repeat Mediums, tuning-first onboarding, automation of templated types. Frame Crit/High-only honestly as a notification tier, not filtered monitoring.

---

## Phase 5 — Severity/criticality extraction (no native field)

When severity/criticality exist only as text in analyst worksheet comments:

```python
import re
sev_pat  = re.compile(r'severity\s*[:=]\s*(\w+)', re.I)
crit_pat = re.compile(r'criticality\s*[:=]\s*(\w+)', re.I)
VALID = {'critical','high','medium','low','informational','info','unknown'}
# fetch comments per ticket (Phase 2.1 pattern), adf_text() the bodies,
# take first VALID match of each pattern; anything else = "no data"
```

- **The whitelist matters** — without it the regex grabs table-adjacent words ("Criticality: Workstations").
- **Report "no data" counts** — coverage percentage is part of the result.
- Standing improvement to propose: promote Severity to a real Jira field at intake.

---

## Phase 6 — Verifying external/automated reports against Jira

When checking a colleague's or a tool's metrics report:

1. Identify which rows are Jira-verifiable (ticket counts) vs pipeline-only (alert-feed counts, TTA/TTT timings).
2. **Window archaeology:** try trailing windows at several plausible run times (`created >= "<start>" AND created < "<end>"`). Exact matches on short windows confirm the counter's convention; then judge long windows.
3. Expect boundary noise: a 1–2 ticket delta on a 30-day window whose trailing edge lands on an alert-storm day is not a red flag. **>5% is.**
4. Check internal consistency: derived columns (conversion rate = tickets ÷ alerts) should reproduce exactly — if they do, the column is derived, not independently measured.

---

## Execution checklist (fresh run, ~1–2 h wall clock)

1. ☐ Phase 0: jr auth OK; confirm the client custom field ID; list clients; check device-count fields; confirm exclusion list.
2. ☐ Phase 1: per-client volume + monthly trend (minutes, foreground).
3. ☐ Phase 2: pick effort sample (≥6mo, one representative client or top-3 by volume); background-fetch view/changelog/comments; run session reconstruction; compare to priors.
4. ☐ Phase 3: OSINT any new/changed clients; re-bucket; recompute bucket averages.
5. ☐ Phase 4: refresh cost model with current rates; scenario table.
6. ☐ Phase 5 (if severity asked): background-fetch comments; regex cross-tab with coverage counts.
7. ☐ Deliverables: analysis doc + summary. Lead with burdened cost; state the "excludes execution time" caveat verbatim; include method-notes section for reviewers.

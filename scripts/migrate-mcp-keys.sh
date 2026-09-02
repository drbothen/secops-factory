#!/usr/bin/env bash
# Move the plaintext MCP API keys (Perplexity, Tavily, Context7) out of .mcp.json
# and into the gitignored secrets file, leaving ${VAR} references behind.
# Claude Code expands ${VAR} in .mcp.json env/url/headers fields at load time.
#
# After this runs, .mcp.json is secret-free and can be tracked in git.
# Never prints key material — only lengths. Idempotent. Safe to re-run.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCP="$ROOT/.mcp.json"
SECRETS="$ROOT/.envrc.secrets"

[ -f "$MCP" ] || { echo "x $MCP not found" >&2; exit 1; }
[ -f "$SECRETS" ] || { echo "x secrets file not found" >&2; exit 1; }

python3 - "$MCP" "$SECRETS" <<'PY'
import json, re, sys, os, stat

mcp_path, secrets_path = sys.argv[1], sys.argv[2]
with open(mcp_path) as f:
    raw = f.read()
cfg = json.loads(raw)
servers = cfg.get("mcpServers", {})

moves = []  # (env_var, secret_value)

def stash(var, value):
    moves.append((var, value))
    return "${%s}" % var

# perplexity: stdio env block
p = servers.get("perplexity", {}).get("env", {})
if p.get("PERPLEXITY_API_KEY") and not p["PERPLEXITY_API_KEY"].startswith("${"):
    p["PERPLEXITY_API_KEY"] = stash("PERPLEXITY_API_KEY", p["PERPLEXITY_API_KEY"])

# tavily: key embedded in the http url query string
t = servers.get("tavily", {})
if t.get("url"):
    m = re.search(r"tavilyApiKey=([^&\"]+)", t["url"])
    if m and not m.group(1).startswith("${"):
        t["url"] = t["url"].replace(m.group(1), stash("TAVILY_API_KEY", m.group(1)))

# context7: header
c = servers.get("context7", {}).get("headers", {})
if c.get("CONTEXT7_API_KEY") and not c["CONTEXT7_API_KEY"].startswith("${"):
    c["CONTEXT7_API_KEY"] = stash("CONTEXT7_API_KEY", c["CONTEXT7_API_KEY"])

if not moves:
    print("v .mcp.json already secret-free. Nothing to do.")
    sys.exit(0)

# Append to the secrets file, replacing any stale line for the same var.
with open(secrets_path) as f:
    lines = f.read().splitlines()
for var, val in moves:
    lines = [l for l in lines if not re.match(rf"^\s*export\s+{var}=", l)]
    lines.append(f'export {var}="{val}"')
with open(secrets_path, "w") as f:
    f.write("\n".join(lines) + "\n")
os.chmod(secrets_path, stat.S_IRUSR | stat.S_IWUSR)  # keep 600

with open(mcp_path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")

for var, val in moves:
    print(f"moved {var} ({len(val)} chars) -> secrets file; .mcp.json now references ${{{var}}}")

# verify nothing secret-shaped remains
with open(mcp_path) as f:
    residue = re.findall(r"(pplx-|tvly-|ctx7sk-)[A-Za-z0-9_-]{8,}", f.read())
print("x RESIDUE REMAINS in .mcp.json!" if residue else "v .mcp.json is secret-free; safe to track in git.")
sys.exit(1 if residue else 0)
PY

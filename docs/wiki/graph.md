# Code Graph

> **Current state (MVP, added 1.2):** static PowerShell function call-graph
> extracted to JSON. Visualization is a static page that lists files,
> functions, and edges.

## Why it matters

Before 1.2, navigating a codebase in OpenCode meant brute-force grep over
the file tree. Multi-step refactors became slow because the agent had to
re-walk the directory on every hop.

## What ships in 1.2

- `scripts/code-graph.ps1` — walks `.ps1` / `.psm1` files in the repo,
  extracts function definitions + token-based invocations via regex,
  emits JSON to `docs/wiki/_data/code-graph.json`.
- TUI option `[3] Code Graph` rebuilds the index on demand.
- Wiki viewer (this page's footer section) lists functions and call sites.

### Build the graph

```powershell
.\scripts\code-graph.ps1
```

Output:

```
[code-graph] Scanning C:\AI\GOD-OPENCODE
[code-graph] Found 47 PowerShell files
[code-graph] Wrote docs/wiki/_data/code-graph.json
[code-graph] Nodes: 192  Edges: 487
```

### JSON schema

```json
{
  "generated": "2026-07-17T14:00:00Z",
  "files": 47,
  "nodeCount": 192,
  "edgeCount": 487,
  "functions": [{ "name": "Show-Dashboard", "files": ["god-ui.ps1"] }],
  "edges":     [{ "from": "god-ui.ps1", "to": "Show-Dashboard", "defined_here": true }]
}
```

## Limitations (MVP)

| Limitation | Impact |
|------------|--------|
| Regex only | Misses function calls via `& ${...}` or aliased via `Set-Alias` |
| PowerShell only | Python/JS/TS graphs not included yet |
| No parameter graph | Caller -> callee only, not which args flow |
| No visualization | Just a JSON file + this wiki page |

## Roadmap

- **1.3:** Coarse call-graph for non-PowerShell files via tree-sitter
- **1.3:** Static HTML viewer (`docs/wiki/graph.html`) that renders the 
  JSON with collapsible nodes
- **1.4:** Parameter flow + type inference via PowerShell AST
- **2.0:** Live graph agent tool: `Get-GodCallers foo` returns who's 
  calling function `foo`

## See also

- [Architecture](architecture.md) — how agents/skills/workflows layer up
- [Roadmap](roadmap.md) — graph concern in context

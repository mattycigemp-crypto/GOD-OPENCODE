# Architecture

Three layers on top of OpenCode:

```
+---------------------------------------------------------------+
|                         OpenCode host                          |
|  +---------+      +---------+      +-----------------+        |
|  | Agents  | ---> | Skills  | ---> |   Workflows     |        |
|  | (10)    |      | (84)    |      |   (15)          |        |
|  +---------+      +---------+      +-----------------+        |
|       ^               ^                 ^                    |
|       |               |                 |                    |
|       +---------------+-----------------+                    |
|                       |                                      |
|                  +---------+                                 |
|                  | Router  |  (auto-router skill)           |
|                  +---------+                                 |
+---------------------------------------------------------------+
```

**OpenCode** is the host: it loads AGENTS.md, picks a primary agent,
manages context, calls tools, and writes output.

**Agents** are specializations — backend-engineer, security-engineer, 
principal-engineer, etc. Each defines a role, standards, and which skills
they can call. Defined in `agents/<name>/AGENT.md`.

**Skills** are domain knowledge documents — fastapi, postgres, react,
owasp, kubernetes. Defined in `skills/<category>/<name>/SKILL.md`. 
Loaded into `~/.config/opencode/skills/` on `install.ps1`.

**Workflows** are multi-step procedures — security-audit, build-app,
refactor. Defined in `workflows/<name>.md`. Each step specifies 
agent + skills + action with `{{PARAM}}` placeholders.

**Router** (orchestration skill `auto-router`) scores user input against 
keyword maps and selects which agent to invoke.

## Per-platform install paths

| Component | Repo path | Global install path |
|-----------|-----------|---------------------|
| Agents    | `agents/` | `~/.config/opencode/god-opencode/agents/` |
| Skills    | `skills/` | `~/.config/opencode/skills/` |
| Workflows | `workflows/` | `~/.config/opencode/god-opencode/workflows/` |
| Commands  | `commands/` | `~/.config/opencode/god-opencode/commands/` |
| Config    | `opencode.json` | `~/.config/opencode/opencode.jsonc` (merged) |

## Quick read chain

When you run OpenCode:

1. OpenCode reads `AGENTS.md` (project context for the LLM).
2. OpenCode loads `opencode.json` (agent definitions + commands).
3. `opencode.json` lists each agent's `tools` allowlist (per-agent).
4. When you ask a question, the auto-router skill detects intent 
   and selects an agent.
5. The selected agent may invoke workflows via the workflow-engine skill.
6. Skills are loaded on-demand, not pre-loaded.

## See also

- [Cross-Platform](cross-platform.md) — install paths by OS
- [Roadmap](roadmap.md) — graph / dynamic / cross-platform / memory 
  concerns

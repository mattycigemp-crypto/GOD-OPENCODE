# Implementation Plan: GOD-OPENCODE

## Overview

This plan breaks the GOD-OPENCODE framework into incremental coding tasks, progressing layer by layer from the foundational installer through each subsystem to the top-level intelligence and health-check layers. Each task builds on the previous ones, ending with full integration. Testing tasks are included as optional sub-tasks using Pester (PowerShell) for unit, property-based, and integration tests.

---

## Tasks

- [ ] 1. Set up repository structure, test framework, and shared utilities
  - Create all 15 required directories (`agents`, `backups`, `commands`, `config`, `logs`, `mcps`, `memory`, `models`, `prompts`, `router`, `scripts`, `skills`, `templates`, `tools`, `workflows`)
  - Create a `tests/` directory tree with `smoke/`, `unit/`, `property/`, `integration/` subdirectories
  - Write shared PowerShell helper functions: `Write-IfChanged`, `EnsureFolder`, and `RunStep` in a `scripts/shared-utils.ps1` module
  - _Requirements: 1.1, 1.6_

- [ ] 2. Implement the Skills System
  - [ ] 2.1 Create the initial skill directory structure and populate required category folders (`ai`, `backend`, `frontend`, `devops`, `security`, `database`, `advanced`, `testing`)
    - Each category folder must exist under `skills/`
    - _Requirements: 2.1, 2.3_

  - [ ] 2.2 Author all required SKILL.md files for every skill referenced in the Agent definitions
    - Each SKILL.md must contain: YAML front-matter with `name` and `description`, and sections `# Mission`, `## Core Responsibilities`, `## Workflow`, `## Quality Standards`
    - _Requirements: 2.2, 2.3_

  - [ ]* 2.3 Write property test for SKILL.md schema completeness (Property 6)
    - **Property 6: SKILL.md Schema Completeness**
    - **Validates: Requirement 2.2**
    - Use Pester to enumerate all `SKILL.md` files and assert each has required front-matter keys and sections
    - File: `tests/property/Test-SkillInstallation.Tests.ps1`

  - [ ]* 2.4 Write property test for skill directory structure invariant (Property 10)
    - **Property 10: Skill Directory Structure Invariant**
    - **Validates: Requirements 2.1, 13.4**
    - Assert every skill path matches `skills/{category}/{skill-name}/SKILL.md` with only lowercase letters and hyphens
    - File: `tests/property/Test-SkillInstallation.Tests.ps1`

- [ ] 3. Implement the Agent System
  - [ ] 3.1 Author all 10 required AGENT.md files under `agents/{name}/AGENT.md`
    - Each must include: `## Role`, `## Responsibilities`, `## Standards`, `## Skills` (and optional `## Delegation`)
    - Agents: `principal-engineer`, `backend-engineer`, `frontend-engineer`, `ai-engineer`, `security-engineer`, `database-architect`, `devops-engineer`, `debugger`, `researcher`, `technical-writer`
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ] 3.2 Implement agent delegation — add `## Delegation` sections to agents that coordinate sub-tasks with other agents
    - _Requirements: 3.4_

  - [ ]* 3.3 Write property test for AGENT.md schema completeness (Property 7)
    - **Property 7: AGENT.md Schema Completeness**
    - **Validates: Requirement 3.3**
    - Pester test enumerates all AGENT.md files and asserts required sections are present
    - File: `tests/property/Test-AgentSchema.Tests.ps1` (inside `tests/unit/Test-AgentSchema.Tests.ps1`)

- [ ] 4. Implement the Router
  - [ ] 4.1 Create `router/agent-router.json` with keyword-to-agent mappings covering all 10 agent roles
    - Include keywords for each agent's domain (e.g., `api`, `backend`, `frontend`, `security`, `database`, `devops`, `debug`, `research`, `ai`, `document`)
    - _Requirements: 9.1, 9.5_

  - [ ] 4.2 Implement the router logic as an `Invoke-Router` PowerShell function in `scripts/router.ps1`
    - Tokenize input, count keyword matches per agent, sort by match count, return top-3 candidates, set `fallback: $true` when no match
    - _Requirements: 9.2, 9.3, 9.4, 9.6_

  - [ ]* 4.3 Write property test for router keyword-to-agent mapping (Property 3)
    - **Property 3: Router Keyword-to-Agent Mapping**
    - **Validates: Requirements 9.1, 9.2, 9.3**
    - Generate 100+ request strings containing known keywords; assert correct agent is always returned
    - File: `tests/property/Test-RouterProperties.Tests.ps1`

  - [ ]* 4.4 Write property test for router default fallback (Property 4)
    - **Property 4: Router Default Fallback**
    - **Validates: Requirement 9.4**
    - Generate 100+ request strings with no matching keywords; assert `principal-engineer` is returned with `fallback: $true`
    - File: `tests/property/Test-RouterProperties.Tests.ps1`

  - [ ]* 4.5 Write property test for router skill completeness (Property 5)
    - **Property 5: Router Skill Completeness**
    - **Validates: Requirement 9.6**
    - For every agent returned by the router, assert all skills listed in that agent's AGENT.md are present in the result context
    - File: `tests/property/Test-RouterProperties.Tests.ps1`

  - [ ]* 4.6 Write unit tests for router edge cases
    - Test: zero-keyword request → principal-engineer fallback
    - Test: request matching keywords from two agents → highest-count agent wins
    - File: `tests/unit/Test-Router.Tests.ps1`

- [ ] 5. Implement the Workflow System
  - [ ] 5.1 Create the four required workflow Markdown files in `workflows/`
    - `build-application.md`, `api-development.md`, `security-audit.md`, `bug-investigation.md`
    - Each must include: `## Purpose`, `## Parameters`, and ordered `### Step N:` entries with `Agent:` and `Skills:` annotations
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [ ] 5.2 Implement `Invoke-WorkflowSubstitution` PowerShell function in `scripts/workflow-engine.ps1`
    - Replace all `{{PARAM_NAME}}` placeholders using a provided parameter hashtable; return error if any placeholder remains unresolved
    - _Requirements: 4.5_

  - [ ]* 5.3 Write property test for workflow parameterization substitution (Property 20)
    - **Property 20: Workflow Parameterization Substitution**
    - **Validates: Requirement 4.5**
    - Generate random parameter maps for each workflow template; assert zero unresolved `{{...}}` placeholders in output
    - File: `tests/property/Test-WorkflowOrdering.Tests.ps1`

  - [ ]* 5.4 Write property test for workflow step ordering (Property 19)
    - **Property 19: Workflow Step Ordering**
    - **Validates: Requirement 4.2**
    - Parse each workflow file and assert steps appear in sequential ascending order (Step 1, Step 2, ...)
    - File: `tests/property/Test-WorkflowOrdering.Tests.ps1`

- [ ] 6. Checkpoint — Ensure all tests pass
  - Run `Invoke-Pester -Path .\tests\ -Output Detailed` and confirm all unit and property tests pass before continuing.
  - Ask the user if any questions arise.

- [ ] 7. Implement the MCP Management System
  - [ ] 7.1 Create `mcps/registry.json` with all five required MCP entries (`filesystem`, `github`, `playwright`, `context7`, `tavily`), each with `enabled`, `description`, and `install_command` fields
    - _Requirements: 5.1, 5.4_

  - [ ] 7.2 Create `mcps/mcp-config.json` with connection configuration for each supported MCP
    - _Requirements: 5.6_

  - [ ] 7.3 Implement `scripts/install-mcps.ps1` — reads `registry.json`, iterates enabled MCPs, attempts installation, logs success/failure per MCP, continues on failure
    - _Requirements: 5.2, 5.3_

  - [ ]* 7.4 Write property test for MCP error isolation (Property 8)
    - **Property 8: Error Isolation (Installer and MCP Manager)**
    - **Validates: Requirements 1.6, 5.3**
    - Mock one MCP installation to fail; assert remaining MCPs are processed and exactly one error is logged for the failed MCP
    - File: `tests/property/Test-HealthCheck.Tests.ps1`

  - [ ]* 7.5 Write unit tests for MCP manager
    - Test: disabled MCP is skipped entirely
    - Test: failed MCP logs name and reason, continues loop
    - File: `tests/unit/Test-Installer.Tests.ps1`

- [ ] 8. Implement the Prompt Library
  - [ ] 8.1 Create prompt category directories and author all required prompt Markdown files
    - Categories: `coding`, `ai`, `research`, `writing`, `business`, `security`
    - Required prompts: Architecture Review, Bug Hunt, API Design, Security Review, Code Review, Refactoring
    - Each file must include: `# Title`, `## Purpose`, `## Parameters` (table), `## Prompt` (with `{{PARAM_NAME}}` placeholders), `## Example Usage`
    - _Requirements: 6.1, 6.2, 6.3_

  - [ ]* 8.2 Write property test for prompt file parameters section (Property 17)
    - **Property 17: Prompt File Parameters Section**
    - **Validates: Requirement 6.3**
    - Enumerate all prompt Markdown files; assert each contains a `## Parameters` section listing all `{{PARAM_NAME}}` placeholders used in the prompt body
    - File: `tests/unit/Test-SkillSchema.Tests.ps1`

- [ ] 9. Implement the Template System
  - [ ] 9.1 Create all six required templates under `templates/`, each with a `README.md` and scaffold files
    - Templates: `fastapi-api`, `react-app`, `nextjs-saas`, `discord-bot`, `mcp-server`, `rag-project`
    - Each `README.md` must describe: setup steps, dependencies, and how to run the project
    - Use `{{PROJECT_NAME}}` placeholders where project-name substitution is needed
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

  - [ ]* 9.2 Write property test for template README inclusion (Property 18)
    - **Property 18: Template Generation Includes README**
    - **Validates: Requirement 7.4**
    - For each template directory, assert a `README.md` file is present
    - File: `tests/unit/Test-SkillSchema.Tests.ps1`

- [ ] 10. Implement the Memory System
  - [ ] 10.1 Implement `New-MemoryArtifact` and `Get-MemoryArtifacts` PowerShell functions in `scripts/memory.ps1`
    - `New-MemoryArtifact`: accepts `type`, `title`, `author`, `content`; writes a structured Markdown file to `memory/{type}-{slug}.md` with ISO-8601 timestamp front-matter
    - `Get-MemoryArtifacts`: reads all `memory/*.md` files and returns an array of `[type, title, timestamp]` objects
    - Handle file-already-exists by appending versioned changelog entry rather than overwriting
    - _Requirements: 8.1, 8.2, 8.3, 8.5_

  - [ ]* 10.2 Write property test for memory artifact timestamp and author invariant (Property 11)
    - **Property 11: Memory Artifact Timestamp and Author Invariant**
    - **Validates: Requirement 8.3**
    - Create 100+ artifacts with varied inputs; assert each resulting file has a non-empty ISO-8601 `timestamp` and non-empty `author` in front-matter
    - File: `tests/unit/Test-MemoryArtifacts.Tests.ps1`

  - [ ]* 10.3 Write property test for memory list completeness (Property 12)
    - **Property 12: Memory List Completeness**
    - **Validates: Requirement 8.5**
    - Seed N files in a temp `memory/` directory; assert `Get-MemoryArtifacts` returns exactly N entries each containing `type`, `title`, and `timestamp`
    - File: `tests/unit/Test-MemoryArtifacts.Tests.ps1`

- [ ] 11. Implement the Command System
  - [ ] 11.1 Create all six command Markdown files in `commands/`
    - Files: `build.md`, `architect.md`, `debug.md`, `review.md`, `secure.md`, `optimize.md`
    - Each must include `# /{command-name}`, `## Purpose`, `## Steps` (with `Agent:` and `Skills:` annotations), `## Output`
    - The `/build` command steps must: parse description → call Router → call Intelligence Engine → select Workflow → execute Workflow → produce Implementation Plan
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 12. Implement the Intelligence Engine
  - [ ] 12.1 Implement `Invoke-ProjectScan` in `scripts/god-intelligence.ps1` and `tools/project-scan.ps1`
    - Language detection: count files by extension
    - Project type detection: check presence of `package.json`, `pyproject.toml`, `Dockerfile`, `openapi.yaml`, etc.
    - Output a structured Implementation Plan Markdown document with all six required sections
    - Write a `memory/adr-{slug}.md` artifact with `type: architecture-decision` and current timestamp on scan completion
    - Default to `projectType: "unknown"` and `build-application` workflow when detection is ambiguous
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

  - [ ]* 12.2 Write property test for Intelligence Engine plan completeness (Property 13)
    - **Property 13: Intelligence Engine Plan Completeness**
    - **Validates: Requirement 11.5**
    - Run `Invoke-ProjectScan` against several fixture directories; assert every output plan contains all six required sections
    - File: `tests/property/Test-IntelligenceEngine.Tests.ps1`

  - [ ]* 12.3 Write property test for Intelligence Engine memory storage (Property 14)
    - **Property 14: Intelligence Engine Memory Storage**
    - **Validates: Requirement 11.6**
    - After each scan, assert exactly one `memory/adr-*.md` file was created with `type: architecture-decision` and a valid ISO-8601 timestamp
    - File: `tests/property/Test-IntelligenceEngine.Tests.ps1`

- [ ] 13. Implement the Core Installer Engine
  - [ ] 13.1 Implement `god-install.ps1` — top-level orchestrator script
    - Call `EnsureFolder` for all 15 required directories
    - Call `RunStep` for each sub-engine in order: `god-builder.ps1` → `god-expansion.ps1` → `god-intelligence.ps1` → `upgrade-all-skills.ps1`
    - Call `install.ps1` to copy skills to `~/.config/opencode/skills/`
    - Call `install-mcps.ps1` to process the MCP registry
    - Wrap each step in `try/catch`; on failure: log error, add step to `failedSteps`, continue
    - Emit installation summary table at end with counts of Skills, Agents, Workflows, Templates, Prompts, and MCP Registry status
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

  - [ ] 13.2 Implement `install.ps1` — skill copy script
    - Enumerate all `skills/{category}/{name}/SKILL.md` paths
    - Copy each skill directory to `~/.config/opencode/skills/{name}/` (always overwrite)
    - Report count of installed skills
    - _Requirements: 2.4, 2.5_

  - [ ] 13.3 Implement `scripts/upgrade-all-skills.ps1` — bulk skill regenerator
    - Re-generate all SKILL.md files to the latest template without requiring a full re-install
    - _Requirements: 2.6_

  - [ ] 13.4 Implement `scripts/god-builder.ps1` and `scripts/god-expansion.ps1` sub-engine scripts
    - `god-builder.ps1`: scaffold any missing agent and skill directory structure
    - `god-expansion.ps1`: extend the skill and prompt library with any new entries
    - _Requirements: 1.2_

  - [ ]* 13.5 Write property test for skill installation round trip (Property 1)
    - **Property 1: Skill Installation Round Trip**
    - **Validates: Requirements 1.3, 2.4**
    - Run installer against temp directories; for every skill in `skills/`, assert corresponding directory and SKILL.md exist in `~/.config/opencode/skills/{name}/`
    - File: `tests/property/Test-SkillInstallation.Tests.ps1`

  - [ ]* 13.6 Write property test for idempotent installation (Property 2)
    - **Property 2: Idempotent Installation**
    - **Validates: Requirements 1.7, 2.5**
    - Create a user-created custom file in a temp target directory; run installer twice; assert custom file is unchanged and present after both runs
    - File: `tests/property/Test-SkillInstallation.Tests.ps1`

  - [ ]* 13.7 Write property test for installer summary accuracy (Property 9)
    - **Property 9: Installer Summary Accuracy**
    - **Validates: Requirement 1.5**
    - After an install run, assert the reported skills count equals the number of skill directories copied, agents count equals `agents/` subdirectory count, and workflows count equals `.md` file count in `workflows/`
    - File: `tests/property/Test-SkillInstallation.Tests.ps1`

  - [ ]* 13.8 Write unit tests for installer core behavior
    - Test: `Write-IfChanged` — same content → no write; changed content → write; missing file → create
    - Test: step ordering — mock sub-scripts, verify invocation sequence
    - Test: step failure → error logged, remaining steps executed
    - File: `tests/unit/Test-Installer.Tests.ps1`

- [ ] 14. Checkpoint — Ensure all tests pass
  - Run `Invoke-Pester -Path .\tests\ -Output Detailed` and confirm all smoke, unit, and property tests pass before continuing.
  - Ask the user if any questions arise.

- [ ] 15. Implement the Health Check
  - [ ] 15.1 Implement `god-health.ps1` — framework verification script
    - Check 1: all required directories exist in repository root
    - Check 2: all skills present in `~/.config/opencode/skills/`
    - Check 3: all enabled MCPs in `registry.json` are reachable/valid
    - Check 4: `router/agent-router.json` is valid JSON with ≥1 routing rule
    - Check 5: `mcps/registry.json` is valid JSON
    - Check 6: key scripts exist (`god-install.ps1`, `install-mcps.ps1`, etc.)
    - Output `[FAIL] {component}: expected {expected_state}, found {actual_state}` on failure
    - Output `[OK]   {component}` on pass; final line: `All checks passed. {N} components verified.`
    - Exit code 0 if all pass, 1 if any fail
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 13.6_

  - [ ]* 15.2 Write property test for health check failure message completeness (Property 15)
    - **Property 15: Health Check Failure Message Completeness**
    - **Validates: Requirement 12.5**
    - Inject failures for each check type; assert every failure output line contains component name, expected state, and actual state
    - File: `tests/property/Test-HealthCheck.Tests.ps1`

  - [ ]* 15.3 Write property test for health check success count (Property 16)
    - **Property 16: Health Check Success Count**
    - **Validates: Requirement 12.6**
    - Run health check with all checks passing; assert the final output line's count equals the number of verification steps executed
    - File: `tests/property/Test-HealthCheck.Tests.ps1`

- [ ] 16. Implement repository quality and open-source readiness artifacts
  - [ ] 16.1 Create root-level `README.md` with all five required sections
    - Sections: project purpose, architecture overview (all 10 layers), installation instructions, quick-start example (`/build` usage), and contribution guidelines
    - _Requirements: 13.1_

  - [ ] 16.2 Create `CONTRIBUTING.md`, `CHANGELOG.md`, and `LICENSE` at the repository root
    - `CONTRIBUTING.md`: process for adding Skills, Agents, Workflows, Templates, Prompts, and MCPs
    - `CHANGELOG.md`: initial version entry with date
    - `LICENSE`: appropriate open-source license text
    - _Requirements: 13.2, 13.3, 13.5_

  - [ ]* 16.3 Write property test for README section completeness (Property 21)
    - **Property 21: README Section Completeness**
    - **Validates: Requirement 13.1**
    - Parse root `README.md`; assert all five required sections are present
    - File: `tests/smoke/Test-RepositoryStructure.Tests.ps1`

  - [ ]* 16.4 Write smoke tests for repository structure
    - Assert existence of: `god-health.ps1`, `CONTRIBUTING.md`, `CHANGELOG.md`, `LICENSE`, `scripts/upgrade-all-skills.ps1`, `mcps/mcp-config.json`, `mcps/registry.json`
    - Assert `router/agent-router.json` parses as valid JSON
    - File: `tests/smoke/Test-RepositoryStructure.Tests.ps1`

- [ ] 17. Wire all components together and run integration tests
  - [ ] 17.1 Verify the full `/build` command pipeline end-to-end
    - Confirm `god-install.ps1` → skills copied → router selects agent → intelligence engine scans → workflow executes → implementation plan produced
    - Write `tests/integration/Test-FullInstall.Tests.ps1`: run installer against a temp directory, verify all required directories and files created, verify summary counts match actual file counts
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 10.3_

  - [ ]* 17.2 Write integration test for skill copy end-to-end
    - Run `install.ps1` against a temp skills directory; verify skills appear at correct target paths
    - Tag test as `[Integration]` for CI gating
    - File: `tests/integration/Test-FullInstall.Tests.ps1`

  - [ ]* 17.3 Write integration test for health check against live state
    - Run `god-health.ps1` after a clean install; assert all checks pass
    - File: `tests/integration/Test-FullInstall.Tests.ps1`

  - [ ]* 17.4 Write integration test for Intelligence Engine against the GOD-OPENCODE repository
    - Run `Invoke-ProjectScan` against the repository root; assert output plan contains all required sections
    - File: `tests/integration/Test-FullInstall.Tests.ps1`

  - [ ]* 17.5 Write integration test for MCP connectivity
    - For each enabled MCP, verify connectivity (mark as `[Integration]` — excluded from default CI run)
    - File: `tests/integration/Test-MCPConnectivity.Tests.ps1`

- [ ] 18. Final checkpoint — Ensure all tests pass
  - Run `Invoke-Pester -Path .\tests\ -Output Detailed` for unit/property/smoke tests
  - Run `Invoke-Pester -Path .\tests\integration\ -Tag Integration -Output Detailed` for integration tests separately
  - Confirm zero failures across all test suites. Ask the user if any questions arise.


---

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- Each task references specific requirements for full traceability
- Checkpoints (tasks 6, 14, 18) enforce incremental validation before continuing
- The test framework is Pester (PowerShell); run with `Invoke-Pester -Path .\tests\ -Output Detailed`
- Integration tests tagged `[Integration]` require network access and should be excluded from default CI: `Invoke-Pester -Path .\tests\ -ExcludeTag Integration`
- Property-based tests use Pester `foreach` blocks with 100+ generated iterations
- Every property test comment must include `# Feature: god-opencode, Property {N}: {property_text}`
- The installer is fully idempotent — re-running it is always safe

---

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3"] },
    { "id": 1, "tasks": ["2.1", "4.1"] },
    { "id": 2, "tasks": ["2.2", "3.1", "4.2"] },
    { "id": 3, "tasks": ["2.3", "2.4", "3.2", "3.3", "4.3", "4.4", "4.5", "4.6"] },
    { "id": 4, "tasks": ["5.1", "8.1", "9.1", "10.1"] },
    { "id": 5, "tasks": ["5.2", "5.3", "5.4", "8.2", "9.2", "10.2", "10.3"] },
    { "id": 6, "tasks": ["11.1", "12.1"] },
    { "id": 7, "tasks": ["12.2", "12.3"] },
    { "id": 8, "tasks": ["7.1", "7.2"] },
    { "id": 9, "tasks": ["7.3", "7.4", "7.5"] },
    { "id": 10, "tasks": ["13.1", "13.2", "13.3", "13.4"] },
    { "id": 11, "tasks": ["13.5", "13.6", "13.7", "13.8"] },
    { "id": 12, "tasks": ["15.1"] },
    { "id": 13, "tasks": ["15.2", "15.3"] },
    { "id": 14, "tasks": ["16.1", "16.2"] },
    { "id": 15, "tasks": ["16.3", "16.4"] },
    { "id": 16, "tasks": ["17.1"] },
    { "id": 17, "tasks": ["17.2", "17.3", "17.4", "17.5"] }
  ]
}
```

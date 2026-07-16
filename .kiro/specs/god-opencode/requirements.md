# Requirements Document

## Introduction

GOD-OPENCODE is an AI engineering operating system built on top of OpenCode. It extends OpenCode with a modular, layered framework of reusable skills, virtual agents, proven workflows, MCP integrations, a prompt library, project templates, memory management, intelligent request routing, and a self-improving intelligence engine. The goal is to give any developer a single-command setup that immediately provides a production-grade AI engineering environment — so that typing `/build ecommerce platform` produces a structured, fully coordinated implementation plan with the right agents, skills, and workflows applied automatically.

---

## Glossary

- **GOD-OPENCODE**: The complete AI engineering framework that extends OpenCode, managed by this repository.
- **OpenCode**: The underlying AI coding assistant that GOD-OPENCODE builds upon.
- **Installer**: The `god-install.ps1` PowerShell script that bootstraps and maintains the entire framework.
- **Skill**: A reusable, domain-specific knowledge document (SKILL.md) containing best practices, checklists, patterns, and examples for a specific technology or discipline.
- **Agent**: A virtual persona (AGENT.md) that coordinates one or more Skills to fulfill a specific engineering role.
- **Workflow**: An ordered, reusable step-by-step process document that defines the sequence of work for a class of engineering tasks.
- **MCP**: A Model Context Protocol server that connects OpenCode to external capabilities (filesystem, GitHub, browser, search, APIs, etc.).
- **Prompt**: A reusable, parameterized prompt template stored in the prompt library for a common AI engineering task.
- **Template**: A starter project scaffold for a specific technology stack or application archetype.
- **Memory**: A project-scoped store for architecture decisions, conventions, TODOs, changelogs, and assumptions.
- **Router**: The component that analyzes a user request and selects the most appropriate Agent and Skills to fulfill it.
- **Intelligence_Engine**: The self-improving subsystem that scans repositories, detects languages, recommends improvements, and produces implementation plans.
- **Registry**: A JSON manifest that tracks all installed or available components (Skills, Agents, MCPs, etc.).
- **Health_Check**: A verification pass that confirms all components are correctly installed and configured.

---

## Requirements

### Requirement 1: Core Installer Engine

**User Story:** As a developer, I want to bootstrap the entire GOD-OPENCODE framework with one command, so that I can have a fully configured AI engineering environment without manual setup.

#### Acceptance Criteria

1. WHEN a developer runs `.\god-install.ps1`, THE Installer SHALL create all required directory structure folders if they do not already exist.
2. WHEN a developer runs `.\god-install.ps1`, THE Installer SHALL execute the Builder Engine, Expansion Engine, Intelligence Engine, and Skill Upgrader steps in that order.
3. WHEN a developer runs `.\god-install.ps1`, THE Installer SHALL install all defined Skills into the OpenCode skills directory (`~/.config/opencode/skills`).
4. WHEN a developer runs `.\god-install.ps1`, THE Installer SHALL install and verify all configured MCPs.
5. WHEN a developer runs `.\god-install.ps1`, THE Installer SHALL produce a summary report listing the count of installed Skills, Agents, Workflows, Templates, Prompts, and the MCP Registry status.
6. IF any individual installation step fails, THEN THE Installer SHALL log the failure with a descriptive error message and continue executing remaining steps.
7. WHEN a developer runs `.\god-install.ps1` on an already-configured environment, THE Installer SHALL update all components to their latest versions without destroying existing custom content.

---

### Requirement 2: Skills System

**User Story:** As a developer, I want access to a library of domain-specific Skills, so that OpenCode can apply expert-level best practices, checklists, and patterns for any technology I am working with.

#### Acceptance Criteria

1. THE Skills_System SHALL organize Skills into category subdirectories (e.g., `skills/ai/`, `skills/backend/`, `skills/frontend/`, `skills/advanced/`).
2. WHEN a new Skill is added to the repository, THE Skill SHALL contain a `SKILL.md` file with at minimum: a name, description, mission statement, core responsibilities, workflow steps, and quality standards sections.
3. THE Skills_System SHALL support Skills across at minimum the following categories: AI/ML, Backend, Frontend, DevOps, Security, Database, Advanced Systems, and Testing.
4. WHEN the Installer runs, THE Skills_System SHALL copy all Skill directories from `skills/` into `~/.config/opencode/skills/` so that OpenCode can load them.
5. WHEN a Skill already exists in the target directory, THE Skills_System SHALL overwrite it with the latest version from the repository.
6. THE Skills_System SHALL provide an `upgrade-all-skills.ps1` script that updates all installed Skills without requiring a full re-install.

---

### Requirement 3: Agent System

**User Story:** As a developer, I want a set of virtual engineering Agents, so that I can direct work to a role-appropriate persona that coordinates the right Skills for the task.

#### Acceptance Criteria

1. THE Agent_System SHALL provide Agents covering at minimum these roles: Principal Engineer, Backend Engineer, Frontend Engineer, AI Engineer, Security Engineer, Database Architect, DevOps Engineer, Debugger, Researcher, and Technical Writer.
2. WHEN an Agent is invoked, THE Agent_System SHALL apply the Skills referenced by that Agent's `AGENT.md` definition.
3. WHEN a new Agent is defined, THE Agent MUST contain an `AGENT.md` file specifying: role, responsibilities, standards, and the Skills it coordinates.
4. THE Agent_System SHALL allow Agents to be composed — where one Agent can delegate sub-tasks to another Agent by name.
5. WHEN no Agent is explicitly specified by the user, THE Router SHALL select the most appropriate Agent based on the content of the user's request.

---

### Requirement 4: Workflow System

**User Story:** As a developer, I want reusable, ordered Workflow definitions, so that complex multi-step engineering tasks follow a proven process every time.

#### Acceptance Criteria

1. THE Workflow_System SHALL store Workflow definitions as Markdown files in the `workflows/` directory.
2. WHEN a Workflow is executed, THE Workflow_System SHALL present steps in the defined sequential order.
3. THE Workflow_System SHALL provide at minimum the following built-in Workflows: Full-Stack Application Build (Requirements → Architecture → Database → Backend → Frontend → Security → Testing → Deployment → Documentation), API Development, Security Audit, and Bug Investigation.
4. WHEN a Workflow step specifies an Agent and Skills, THE Workflow_System SHALL activate that Agent with those Skills for that step.
5. THE Workflow_System SHALL support parameterized Workflows where the target technology stack can be specified at invocation time.

---

### Requirement 5: MCP Management System

**User Story:** As a developer, I want GOD-OPENCODE to manage which MCP servers are available and verified, so that OpenCode can connect to external capabilities without manual configuration.

#### Acceptance Criteria

1. THE MCP_Manager SHALL maintain a `mcps/registry.json` file that lists all supported MCP servers with their enabled status.
2. WHEN the Installer runs, THE MCP_Manager SHALL install all MCPs listed as enabled in `registry.json`.
3. WHEN an MCP installation fails, THE MCP_Manager SHALL log the failure with the MCP name and error reason, and continue installing remaining MCPs.
4. THE MCP_Manager SHALL support at minimum the following MCPs: filesystem, github, playwright, context7, and tavily.
5. WHEN a developer queries the Health Check, THE Health_Check SHALL verify that all enabled MCPs are reachable and correctly configured, and report any that are not.
6. THE MCP_Manager SHALL provide a `mcp-config.json` file containing the connection configuration for each supported MCP.

---

### Requirement 6: Prompt Library

**User Story:** As a developer, I want a central library of reusable prompt templates, so that I can consistently apply proven prompt patterns for common AI engineering tasks.

#### Acceptance Criteria

1. THE Prompt_Library SHALL organize prompts into category subdirectories (e.g., `prompts/coding/`, `prompts/ai/`, `prompts/research/`, `prompts/writing/`, `prompts/business/`).
2. THE Prompt_Library SHALL provide at minimum the following prompt categories: Architecture Review, Bug Hunt, API Design, Security Review, Code Review, and Refactoring.
3. WHEN a prompt template is defined, THE Prompt_Library SHALL store it as a Markdown file with a clearly marked parameters section indicating which values must be substituted before use.
4. THE Prompt_Library SHALL be accessible to Agents so that Agents can select and apply relevant prompts during task execution.

---

### Requirement 7: Template System

**User Story:** As a developer, I want starter project templates, so that I can scaffold a new application with the correct structure, dependencies, and conventions already in place.

#### Acceptance Criteria

1. THE Template_System SHALL store Templates in the `templates/` directory, each in its own named subdirectory.
2. THE Template_System SHALL provide at minimum the following Templates: FastAPI API, React App, Next.js SaaS, Discord Bot, MCP Server, and RAG Project.
3. WHEN a Template is used, THE Template_System SHALL generate a project directory containing all scaffold files required to run the application locally.
4. WHEN a Template is generated, THE Template_System SHALL include a `README.md` in the generated project that describes setup steps, dependencies, and how to run the project.
5. THE Template_System SHALL allow Templates to reference Skills so that the generated project inherits the relevant best-practice guidance.

---

### Requirement 8: Memory System

**User Story:** As a developer, I want a project-scoped Memory store, so that architecture decisions, coding conventions, TODOs, and assumptions are persisted and available across sessions.

#### Acceptance Criteria

1. THE Memory_System SHALL store Memory artifacts in the `memory/` directory as structured Markdown files.
2. THE Memory_System SHALL support the following Memory artifact types: Architecture Decisions, Coding Conventions, TODOs, Changelog entries, and Assumptions.
3. WHEN a Memory artifact is created or updated, THE Memory_System SHALL record a timestamp and author identifier with the entry.
4. WHEN an Agent executes a task, THE Memory_System SHALL make relevant Memory artifacts available to the Agent as context.
5. THE Memory_System SHALL provide a command to list all Memory artifacts with their type, title, and last-modified timestamp.

---

### Requirement 9: Router

**User Story:** As a developer, I want the system to automatically select the right Agent and Skills for my request, so that I do not have to manually specify routing for every task.

#### Acceptance Criteria

1. THE Router SHALL analyze the text of a user request and map it to one or more keyword categories defined in `router/agent-router.json`.
2. WHEN a keyword match is found, THE Router SHALL select the Agent associated with that keyword category.
3. WHEN multiple keyword categories match a single request, THE Router SHALL select the Agent associated with the highest-confidence match, and surface the top 3 matches to the user.
4. WHEN no keyword category matches a request, THE Router SHALL default to the Principal Engineer Agent and notify the user that automatic routing was not possible.
5. THE Router SHALL be extensible — new keyword-to-Agent mappings SHALL be addable by editing `router/agent-router.json` without modifying any other file.
6. WHEN the Router selects an Agent, THE Router SHALL also select the Skills associated with that Agent and include them in the execution context.

---

### Requirement 10: Command System

**User Story:** As a developer, I want a set of slash commands that trigger coordinated framework actions, so that I can invoke complex multi-step operations with a short, memorable instruction.

#### Acceptance Criteria

1. THE Command_System SHALL support at minimum the following commands: `/build`, `/architect`, `/debug`, `/review`, `/secure`, and `/optimize`.
2. WHEN a command is invoked, THE Command_System SHALL execute the steps defined in the corresponding `commands/*.md` file in order.
3. WHEN the `/build` command is invoked with a project description, THE Command_System SHALL: analyze the request, select the appropriate Workflow, assign the appropriate Agents, apply relevant Skills, and produce a structured implementation plan.
4. WHEN a command is invoked, THE Command_System SHALL use the Router to determine Agent and Skill selection unless an Agent is explicitly provided by the user.
5. THE Command_System SHALL allow commands to be extended by adding new Markdown files to the `commands/` directory without modifying any other file.

---

### Requirement 11: Intelligence Engine

**User Story:** As a developer, I want the system to scan my repository and automatically recommend the appropriate Workflow, Agents, Skills, and improvements, so that the framework adapts to my actual project rather than requiring manual configuration.

#### Acceptance Criteria

1. WHEN the Intelligence Engine scans a repository, THE Intelligence_Engine SHALL detect the primary programming languages present.
2. WHEN primary languages are detected, THE Intelligence_Engine SHALL recommend the Skills and Agents most relevant to those languages.
3. WHEN the Intelligence Engine scans a repository, THE Intelligence_Engine SHALL identify the project type (API, frontend app, CLI tool, library, etc.) based on file structure and configuration files present.
4. WHEN a project type is identified, THE Intelligence_Engine SHALL recommend the Workflow most appropriate for that project type.
5. WHEN the Intelligence Engine completes a scan, THE Intelligence_Engine SHALL produce a written Implementation Plan containing: detected project type, recommended Workflow, assigned Agents, applied Skills, and a prioritized list of recommended improvements.
6. THE Intelligence_Engine SHALL store scan results in the Memory System as an Architecture Decision artifact with a timestamp.

---

### Requirement 12: Health Check and Verification

**User Story:** As a developer, I want a health check command that verifies the entire framework is correctly installed and configured, so that I can diagnose issues quickly without guessing.

#### Acceptance Criteria

1. WHEN a developer runs the Health Check, THE Health_Check SHALL verify that all required directories exist.
2. WHEN a developer runs the Health Check, THE Health_Check SHALL verify that all Skills are present in `~/.config/opencode/skills/`.
3. WHEN a developer runs the Health Check, THE Health_Check SHALL verify that all enabled MCPs are reachable.
4. WHEN a developer runs the Health Check, THE Health_Check SHALL verify that the Router configuration file is valid JSON and contains at minimum one routing rule.
5. WHEN a verification step fails, THE Health_Check SHALL output a clear failure message identifying the component, expected state, and actual state.
6. WHEN all verification steps pass, THE Health_Check SHALL output a confirmation message with a count of verified components.

---

### Requirement 13: Repository Quality and Open-Source Readiness

**User Story:** As an open-source contributor, I want the repository to follow clear documentation and contribution standards, so that I can understand, use, and contribute to GOD-OPENCODE easily.

#### Acceptance Criteria

1. THE Repository SHALL include a `README.md` at the root level that covers: project purpose, architecture overview of all 10 layers, installation instructions, quick-start example, and contribution guidelines.
2. THE Repository SHALL include a `CONTRIBUTING.md` file that defines the process for adding new Skills, Agents, Workflows, Templates, Prompts, and MCPs.
3. THE Repository SHALL include a `CHANGELOG.md` file that tracks version history with dated entries.
4. WHEN a new Skill, Agent, or Workflow is added to the repository, THE Repository SHALL follow the naming convention: lowercase with hyphens for directory names, and `SKILL.md` / `AGENT.md` / Markdown for content files.
5. THE Repository SHALL include a license file (`LICENSE`) at the root level.
6. THE Repository SHALL include a `god-health.ps1` script that developers can run at any time to verify installation state without running the full installer.

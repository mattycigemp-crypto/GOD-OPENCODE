# /build

## Purpose

Build a complete production application end-to-end. Analyzes the project description, selects the appropriate workflow, assigns agents and skills, and produces a structured implementation plan.

## Steps

1. **Parse request** — Extract project description, tech preferences, and constraints from the user input.
   - Agent: principal-engineer
   - Skills: architect, principal-engineer

2. **Route to agents** — Run the Router against the request to select the primary agent and top-3 candidates.
   - Agent: principal-engineer
   - Skills: system-design

3. **Detect project type** — Run the Intelligence Engine to identify the project type and recommend a workflow.
   - Agent: principal-engineer
   - Skills: architect, system-design

4. **Select workflow** — Load and parameterize the `build-application` workflow with the detected stack.
   - Agent: principal-engineer
   - Skills: workflow-designer

5. **Architecture design** — Design system architecture, data models, and component boundaries.
   - Agent: principal-engineer → delegates to backend-engineer, frontend-engineer, database-architect
   - Skills: system-design, architect, database-design

6. **Implementation plan** — Produce a structured, prioritized implementation plan covering all layers.
   - Agent: principal-engineer
   - Skills: architect, documentation

7. **Security baseline** — Apply security requirements to the implementation plan.
   - Agent: security-engineer
   - Skills: security-audit, secure-coding

8. **Deployment strategy** — Define containerization, CI/CD, and deployment approach.
   - Agent: devops-engineer
   - Skills: docker, github-actions, ci-cd

## Output

A fully structured Implementation Plan document containing:
- Detected project type and technology stack
- Selected workflow and step sequence
- Assigned agents per layer
- Applied skills per agent
- Prioritized list of improvements and risks
- Recommended next actions

# /architect

## Purpose

Design or review system architecture. Produces architecture diagrams, decision records (ADRs), component breakdowns, and scalability recommendations.

## Steps

1. **Understand scope** - Clarify the system being designed or reviewed: scale, constraints, team size, and tech stack.
   - Agent: principal-engineer
   - Skills: architect, principal-engineer

2. **Requirements mapping** - Map functional and non-functional requirements to architecture decisions.
   - Agent: principal-engineer
   - Skills: system-design, architect

3. **Component design** - Define system components, their responsibilities, APIs, and dependencies.
   - Agent: principal-engineer
   - Skills: system-design, distributed-systems, api-design

4. **Data architecture** - Design data storage, access patterns, and data flows.
   - Agent: database-architect
   - Skills: database-design, postgres, redis

5. **Security architecture** - Define trust boundaries, authentication/authorization, and data protection.
   - Agent: security-engineer
   - Skills: security-audit, authentication, secure-coding

6. **Infrastructure design** - Define deployment topology, scaling strategy, and operational concerns.
   - Agent: devops-engineer
   - Skills: docker, kubernetes, cloud, networking

7. **ADR production** - Write Architecture Decision Records for all significant design choices.
   - Agent: technical-writer
   - Skills: documentation, architect

## Output

- Architecture overview document with component diagram
- Data flow diagrams
- Architecture Decision Records (ADRs) for key decisions
- Scalability and reliability analysis
- List of open questions and risks


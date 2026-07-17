---
name: query-optimization
description: Expert workflow for query-optimization in production database systems.
---

# query-optimization

## Mission

Design and operate reliable, performant database systems using query-optimization best practices.

## Core Responsibilities

- Apply query-optimization patterns to production-grade data systems.
- Ensure data integrity, consistency, and availability.
- Optimize for the target workload characteristics.
- Plan for schema/data evolution without downtime.

## Workflow

1. Understand the access patterns and scale requirements.
2. Design the query-optimization approach to satisfy those requirements.
3. Implement with safety mechanisms and rollback plans.
4. Test under realistic load conditions.
5. Monitor performance and adjust as data grows.

## Quality Standards

Always:
- Test migrations on a copy of production data first.
- Keep rollback scripts alongside every migration.
- Document all decisions and tradeoffs.

Never:
- Run untested migrations directly on production.
- Ignore slow query warnings.
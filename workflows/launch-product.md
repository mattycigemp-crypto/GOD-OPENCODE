# launch-product

## Purpose

Production readiness review and launch checklist for a software product. Ensures security, performance, observability, and operational readiness before going live.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `PRODUCT_NAME` | Name of the product being launched | yes |
| `DEPLOY_TARGET` | Deployment platform (AWS, GCP, Azure, Vercel, etc.) | yes |
| `TRAFFIC_ESTIMATE` | Expected peak traffic (e.g., "1000 req/min") | no |

## Steps

### Step 1: Security Audit
- Agent: security-engineer
- Skills: security-audit, secure-coding, authentication, cryptography
- Action: Perform a pre-launch security audit of {{PRODUCT_NAME}}. Check authentication, authorization, secrets management, dependency CVEs, and OWASP Top 10.

### Step 2: Performance Baseline
- Agent: principal-engineer
- Skills: performance, optimization
- Action: Benchmark {{PRODUCT_NAME}} under simulated {{TRAFFIC_ESTIMATE}} load. Identify bottlenecks and validate response time SLAs.

### Step 3: Infrastructure Review
- Agent: devops-engineer
- Skills: docker, kubernetes, terraform, cloud, networking
- Action: Review {{PRODUCT_NAME}} infrastructure on {{DEPLOY_TARGET}}. Verify auto-scaling, health checks, readiness probes, and rollback procedures.

### Step 4: Observability Setup
- Agent: devops-engineer
- Skills: ci-cd, cloud, linux
- Action: Ensure {{PRODUCT_NAME}} has structured logging, metrics collection, distributed tracing, and alerting configured before launch.

### Step 5: Database Readiness
- Agent: database-architect
- Skills: postgres, database-design, replication
- Action: Review database configuration for {{PRODUCT_NAME}}: connection pooling, backup strategy, failover, and query performance under load.

### Step 6: CI/CD Pipeline Verification
- Agent: devops-engineer
- Skills: github-actions, ci-cd, docker
- Action: Verify the {{PRODUCT_NAME}} deployment pipeline: automated tests pass, staging deployment works, rollback has been tested, and secrets are properly managed.

### Step 7: Documentation and Runbook
- Agent: technical-writer
- Skills: documentation
- Action: Produce the launch runbook for {{PRODUCT_NAME}}: deployment procedure, rollback steps, incident response contacts, and known limitations.

### Step 8: Go/No-Go Review
- Agent: principal-engineer
- Skills: architect, principal-engineer
- Action: Conduct a final go/no-go review for {{PRODUCT_NAME}}. Verify all checklist items are complete. Document open risks and accepted tradeoffs.

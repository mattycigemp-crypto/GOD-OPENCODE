# debug-system

## Purpose

System-level debugging for distributed systems, infrastructure failures, or intermittent production issues where the root cause spans multiple components.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `SYMPTOM` | Observable failure or degradation | yes |
| `SYSTEM` | The system or service affected | yes |
| `ENVIRONMENT` | Production, staging, or other | yes |

## Steps

### Step 1: Incident Triage
- Agent: debugger
- Skills: debugger, architect
- Action: Triage the {{SYMPTOM}} in {{SYSTEM}}. Establish the failure timeline, affected components, and blast radius.

### Step 2: Evidence Collection
- Agent: debugger
- Skills: debugger, performance
- Action: Collect logs, metrics, traces, and alerts from {{SYSTEM}} in {{ENVIRONMENT}} during the failure window.

### Step 3: Component Isolation
- Agent: debugger
- Skills: bug-hunter, distributed-systems
- Action: Isolate which component(s) of {{SYSTEM}} are the source vs. downstream of {{SYMPTOM}}.

### Step 4: Root Cause Identification
- Agent: debugger
- Skills: bug-hunter, code-review, distributed-systems
- Action: Identify the single root cause. Consider race conditions, resource exhaustion, cascading failures, and configuration drift.

### Step 5: Remediation
- Agent: devops-engineer
- Skills: kubernetes, docker, linux
- Action: Apply the fix or mitigation to {{SYSTEM}} in {{ENVIRONMENT}}. Verify {{SYMPTOM}} is resolved.

### Step 6: Prevention
- Agent: principal-engineer
- Skills: distributed-systems, architect
- Action: Define changes to prevent recurrence: circuit breakers, retry policies, alerting thresholds, or architecture improvements.

### Step 7: Post-Mortem
- Agent: technical-writer
- Skills: documentation
- Action: Write a blameless post-mortem for {{SYMPTOM}}: timeline, root cause, impact, remediation, and prevention measures.

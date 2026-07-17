# performance-audit

## Purpose

Systematic performance investigation and optimization of an application, service, or infrastructure component.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TARGET` | Service or component being audited | yes |
| `SLA` | Performance target (e.g., "p99 < 200ms") | yes |

## Steps

### Step 1: Baseline Measurement
- Agent: principal-engineer
- Skills: performance, architect
- Action: Establish performance baselines for {{TARGET}} against {{SLA}}. Profile CPU, memory, latency, and throughput under realistic load.

### Step 2: Bottleneck Identification
- Agent: principal-engineer
- Skills: performance, algorithm-expert
- Action: Identify the top 3 bottlenecks from profiling data for {{TARGET}}.

### Step 3: Database Optimization
- Agent: database-architect
- Skills: postgres, redis, database-design
- Action: Identify slow queries, missing indexes, and N+1 problems in {{TARGET}}.

### Step 4: Algorithm and Caching Review
- Agent: principal-engineer
- Skills: algorithm-expert, optimization, performance
- Action: Replace inefficient algorithms and introduce caching where appropriate.

### Step 5: Infrastructure Tuning
- Agent: devops-engineer
- Skills: kubernetes, cloud, docker
- Action: Right-size compute, tune scaling policies, and optimize container resource allocations.

### Step 6: Benchmark and Verify
- Agent: principal-engineer
- Skills: performance, documentation
- Action: Re-benchmark {{TARGET}} against {{SLA}}. Document improvements achieved.
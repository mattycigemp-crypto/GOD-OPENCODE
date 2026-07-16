# /optimize

## Purpose

Performance optimization of an application, API, database, or infrastructure component. Driven by measurement first - no premature optimization.

## Steps

1. **Baseline measurement** - Profile and measure current performance. Establish baselines for CPU, memory, latency, and throughput.
   - Agent: principal-engineer
   - Skills: performance, architect

2. **Bottleneck identification** - Identify the top bottlenecks from profiling data. Apply the 80/20 rule.
   - Agent: principal-engineer
   - Skills: performance, algorithm-expert

3. **Database optimization** - Identify slow queries, missing indexes, N+1 problems, and excessive data transfer.
   - Agent: database-architect
   - Skills: postgres, mongodb, redis, database-design

4. **Algorithm and data structure review** - Identify algorithmic inefficiencies and replace with optimal solutions.
   - Agent: principal-engineer
   - Skills: algorithm-expert, optimization

5. **Caching strategy** - Design and implement caching at the appropriate layer (in-memory, Redis, CDN, HTTP cache).
   - Agent: backend-engineer
   - Skills: redis, api-design, performance

6. **Frontend performance** - Optimize bundle size, rendering path, lazy loading, and Core Web Vitals.
   - Agent: frontend-engineer
   - Skills: react-expert, nextjs-expert, performance

7. **Infrastructure optimization** - Right-size compute, optimize container resources, and tune scaling policies.
   - Agent: devops-engineer
   - Skills: kubernetes, cloud, docker

8. **Benchmark and verify** - Re-measure after each optimization to confirm improvement. Document gains.
   - Agent: principal-engineer
   - Skills: performance, documentation

## Output

- Performance baseline report with profiling data
- Identified bottlenecks ranked by impact
- Optimizations applied with before/after benchmarks
- Recommended further optimizations with estimated impact


---
name: queue
description: "Background jobs and task queues. BullMQ, Celery, cron jobs, retries, dead letter queues, job scheduling."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /queue — Background Jobs & Task Processing

Reliable background job processing for heavy workloads.

## Usage

```
/queue setup                        # Set up BullMQ/Celery
/queue job <name>                   # Create job processor
/queue cron <schedule>              # Scheduled/recurring job
/queue dashboard                    # Bull Board dashboard
```

## Key Patterns

- BullMQ (Node.js) or Celery (Python) with Redis
- Email, report generation, webhook delivery jobs
- Cron jobs: usage reset, metrics aggregation, trial checks
- Dead letter queue for permanently failed jobs
- Exponential backoff retries
- Job priority levels (1=critical, 10=low)
- Monitoring dashboard (Bull Board / Flower)

## Rules

- ALWAYS use exponential backoff for retries
- Set timeouts for every job
- Implement dead letter queues
- Make jobs idempotent
- Use separate queues for different job types
- Monitor queue depth
- Never process payments without idempotency keys

---
name: workflow
description: "Business process automation. State machines, approval flows, multi-step wizards, event-driven pipelines."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /workflow — Business Process Automation

State machines, approval flows, multi-step business processes.

## Usage

```
/workflow state-machine <entity>    # State machine
/workflow approval <process>        # Approval flow
/workflow wizard <name>             # Multi-step wizard
/workflow pipeline <name>           # Event-driven pipeline
```

## Patterns

- State machine with valid transitions and side effects
- Multi-level approval chains (Manager → Finance → CEO)
- Frontend wizard hook (useWizard)
- Database transactions for state changes

## Rules

- Validate state transitions server-side
- Log every state change with actor and timestamp
- Use database transactions for state + side effects
- Implement idempotency for transitions
- Send notifications on state changes
- Audit trail for approval workflows

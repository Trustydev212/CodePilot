---
name: realtime
description: "Real-time features. WebSocket, SSE, live updates, presence, notifications, collaborative editing."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /realtime — Real-time Features

WebSocket, SSE, live notifications, collaborative features.

## Usage

```
/realtime setup                     # Real-time infrastructure
/realtime notifications             # Live notification system
/realtime presence                  # Online/typing indicators
/realtime live-updates              # Real-time data sync
```

## Patterns

- SSE for server→client (simpler, auto-reconnect)
- WebSocket for bi-directional (Pusher/Ably for managed)
- Optimistic updates with TanStack Query
- Reconnection with exponential backoff

## Rules

- Use SSE for server→client, WebSocket only for bi-directional
- Always authenticate connections
- Scope events to organization (tenant isolation)
- Implement heartbeat for stale connection detection

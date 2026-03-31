---
name: monitor
description: "Set up error monitoring, health checks, structured logging, and observability. Sentry, health endpoints, log aggregation."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /monitor - Production Observability Setup

Ship code you can actually debug in production. Error tracking, health checks, structured logging, and alerting.

## Target
$ARGUMENTS

## Phase 1: Assess Current State

```bash
echo "=== OBSERVABILITY AUDIT ==="

# Check existing monitoring
echo "--- Error Tracking ---"
grep -rn 'sentry\|@sentry\|Sentry\|bugsnag\|rollbar\|logrocket' --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" . 2>/dev/null | grep -v node_modules | head -10
[ -f "sentry.client.config.ts" ] && echo "✓ Sentry client config found"
[ -f "sentry.server.config.ts" ] && echo "✓ Sentry server config found"

echo ""
echo "--- Health Checks ---"
find . -path "*/health*" -o -path "*/healthcheck*" -o -path "*/ready*" -o -path "*/live*" | grep -v node_modules | head -10

echo ""
echo "--- Logging ---"
grep -rn 'winston\|pino\|bunyan\|structlog\|loguru\|console\.log\|console\.error' --include="*.ts" --include="*.js" --include="*.py" . 2>/dev/null | grep -v node_modules | grep -v '.next' | head -15

echo ""
echo "--- Metrics ---"
grep -rn 'prometheus\|datadog\|newrelic\|opentelemetry\|@opentelemetry' --include="*.ts" --include="*.js" --include="*.py" . 2>/dev/null | grep -v node_modules | head -10

echo ""
echo "--- Environment ---"
grep -rn 'SENTRY_DSN\|DATADOG\|NEW_RELIC\|LOGTAIL\|AXIOM' --include="*.ts" --include="*.env*" . 2>/dev/null | grep -v node_modules | head -10
```

## Phase 2: Implement Monitoring Stack

### A. Health Check Endpoint

Every production app needs these endpoints:

```typescript
// app/api/health/route.ts (Next.js) or routes/health.ts (Express)

// GET /api/health — Basic liveness check
export async function GET() {
  return Response.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || "unknown",
  });
}
```

```typescript
// GET /api/health/ready — Readiness check (dependencies)
export async function GET() {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    external_api: await checkExternalAPI(),
  };
  
  const healthy = Object.values(checks).every((c) => c.status === "ok");
  
  return Response.json(
    {
      status: healthy ? "ready" : "degraded",
      timestamp: new Date().toISOString(),
      checks,
    },
    { status: healthy ? 200 : 503 }
  );
}

async function checkDatabase(): Promise<HealthCheck> {
  try {
    const start = Date.now();
    await prisma.$queryRaw`SELECT 1`;
    return { status: "ok", latency_ms: Date.now() - start };
  } catch (error) {
    return { status: "error", message: error instanceof Error ? error.message : "Unknown" };
  }
}
```

### B. Structured Logging

Replace `console.log` with structured logging:

```typescript
// src/lib/logger.ts
import pino from "pino";

export const logger = pino({
  level: process.env.LOG_LEVEL || "info",
  ...(process.env.NODE_ENV === "development"
    ? { transport: { target: "pino-pretty" } }
    : {}),
  // Production: JSON output for log aggregation
  formatters: {
    level: (label) => ({ level: label }),
  },
  // Add default context
  base: {
    env: process.env.NODE_ENV,
    service: process.env.SERVICE_NAME || "app",
  },
});

// Usage:
// logger.info({ userId, action: "login" }, "User logged in");
// logger.error({ err, requestId }, "Payment processing failed");
```

### C. Error Tracking (Sentry)

```typescript
// sentry.client.config.ts (Next.js)
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  
  // Only send errors in production
  enabled: process.env.NODE_ENV === "production",
  
  // Sample 10% of transactions for performance
  tracesSampleRate: 0.1,
  
  // Capture unhandled promise rejections
  integrations: [
    Sentry.captureConsoleIntegration({ levels: ["error"] }),
  ],
  
  // Filter out noise
  beforeSend(event) {
    // Don't send browser extension errors
    if (event.exception?.values?.[0]?.stacktrace?.frames?.some(
      (f) => f.filename?.includes("extension")
    )) {
      return null;
    }
    return event;
  },
});
```

### D. Request Logging Middleware

```typescript
// src/middleware/request-logger.ts
import { logger } from "@/lib/logger";
import { randomUUID } from "crypto";

export function requestLogger(req: Request): {
  requestId: string;
  log: typeof logger;
} {
  const requestId = req.headers.get("x-request-id") || randomUUID();
  const start = Date.now();
  const log = logger.child({ requestId });
  
  log.info({
    method: req.method,
    url: new URL(req.url).pathname,
    userAgent: req.headers.get("user-agent")?.slice(0, 100),
  }, "Request started");
  
  return { requestId, log };
}
```

### E. Error Boundary (React)

```tsx
// src/components/error-boundary.tsx
"use client";

import * as Sentry from "@sentry/nextjs";
import { useEffect } from "react";

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    Sentry.captureException(error);
  }, [error]);

  return (
    <html>
      <body>
        <div className="flex min-h-screen items-center justify-center">
          <div className="text-center">
            <h2 className="text-2xl font-bold">Something went wrong</h2>
            <p className="mt-2 text-gray-600">{error.digest}</p>
            <button
              onClick={reset}
              className="mt-4 rounded bg-blue-500 px-4 py-2 text-white"
            >
              Try again
            </button>
          </div>
        </div>
      </body>
    </html>
  );
}
```

## Phase 3: Verify Setup

```bash
echo "=== VERIFICATION ==="

# Check health endpoint
echo "--- Health endpoint ---"
if [ -f "package.json" ]; then
  npx tsc --noEmit 2>&1 | tail -5
fi

# Check for console.log remaining
echo ""
echo "--- Remaining console.log (should migrate to logger) ---"
grep -rn 'console\.log\|console\.error\|console\.warn' --include="*.ts" --include="*.tsx" src/ 2>/dev/null | grep -v node_modules | grep -v logger | head -10

echo ""
echo "--- Monitoring env vars needed ---"
echo "SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx"
echo "NEXT_PUBLIC_SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx"
echo "LOG_LEVEL=info"
```

## Phase 4: Summary

```
## Monitoring Setup

### Implemented
| Component | Status | Tool |
|-----------|--------|------|
| Health check (/api/health) | ✓ | Custom |
| Readiness check (/api/health/ready) | ✓ | Custom |
| Error tracking | ✓ | Sentry |
| Structured logging | ✓ | Pino |
| Request logging | ✓ | Middleware |
| Error boundary | ✓ | React |

### Environment Variables Needed
- SENTRY_DSN / NEXT_PUBLIC_SENTRY_DSN
- LOG_LEVEL (default: info)

### Dependencies Added
- @sentry/nextjs (or @sentry/node)
- pino + pino-pretty

### Dashboard Links
- Sentry: https://sentry.io
- Vercel Analytics: Built-in
- Axiom/Logtail: For log aggregation

### Next Steps
1. Create Sentry project and add DSN to .env
2. Set up alerting rules in Sentry
3. Replace remaining console.log with logger calls
4. Add log drain in hosting provider (Vercel → Axiom)
```

RULE: Never log sensitive data (passwords, tokens, PII). Always sanitize.
RULE: Health endpoints must return proper HTTP status codes (200 = healthy, 503 = degraded).
RULE: Error tracking should be disabled in development to avoid noise.
RULE: Structured logs must include requestId for tracing across services.

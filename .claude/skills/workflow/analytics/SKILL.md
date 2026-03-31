---
name: analytics
description: "Product analytics. Event tracking, funnels, dashboards, user behavior, feature usage, retention metrics."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /analytics — Product Analytics

Event tracking, funnels, and product metrics.

## Usage

```
/analytics setup                    # Set up PostHog/Mixpanel/custom
/analytics track <event>            # Add event tracking
/analytics dashboard                # Build metrics dashboard
/analytics funnel <name>            # Conversion funnel
```

## Key Metrics

- MRR, Churn Rate, DAU/MAU
- Feature usage, conversion funnels
- Essential events: signup, login, feature_used, plan_upgraded

## Rules

- Never track PII in analytics
- Respect Do Not Track and GDPR
- Aggregate data for dashboards
- Implement data retention policy

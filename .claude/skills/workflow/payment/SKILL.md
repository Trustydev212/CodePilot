---
name: payment
description: "Stripe integration for SaaS. Subscriptions, billing portal, usage-based pricing, webhooks, invoices."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /payment — SaaS Payment & Billing

Implement Stripe-powered billing for SaaS applications.

## Usage

```
/payment setup                      # Full Stripe integration
/payment subscriptions              # Subscription management
/payment usage                      # Usage-based billing
/payment checkout                   # Checkout session flow
/payment webhooks                   # Webhook handlers
/payment portal                     # Billing portal
```

## Key Patterns

- Plan configuration with limits (members, API calls, storage)
- Stripe Checkout for PCI compliance
- Webhook handlers (subscription created/updated/deleted, payment failed)
- Billing portal for self-service management
- Usage tracking and limit enforcement
- Trial periods (7-14 days)
- Graceful downgrade (restrict access, don't delete data)

## Rules

- ALWAYS verify Stripe webhook signatures
- Use Stripe Checkout — never handle card details
- Handle all subscription lifecycle events
- Implement graceful downgrade
- Track usage for metered billing
- Never trust client-side plan data
- Test with `stripe listen --forward-to`

---
name: money-safe
description: "Financial transaction safety. Idempotency, double-entry ledger, race condition prevention, reconciliation, fraud detection."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /money-safe — Financial Transaction Safety

Prevent money bugs: double charges, race conditions, lost transactions.

## Usage

```
/money-safe audit                   # Audit payment code for vulnerabilities
/money-safe ledger                  # Double-entry ledger
/money-safe idempotency             # Idempotency for payments
/money-safe reconciliation          # Balance reconciliation
/money-safe fraud                   # Fraud detection rules
```

## Critical Patterns

1. **Idempotency Keys** — Every payment mutation needs one. Prevent double charges.
2. **Double-Entry Ledger** — Debits must equal credits. Use Decimal(19,4).
3. **Race Condition Prevention** — SELECT FOR UPDATE or optimistic locking.
4. **Reconciliation** — Daily check: internal ledger vs Stripe.
5. **Fraud Detection** — Velocity, amount anomaly, geographic mismatch.

## Money Safety Checklist

- NEVER use float/double for money — use Decimal or integer cents
- Idempotency keys on ALL payment endpoints
- Database transactions for all balance mutations
- Pessimistic locking for balance deductions
- Double-entry ledger — debits must equal credits
- Daily reconciliation internal vs payment provider
- Fraud detection: velocity, amount, geographic
- Audit trail for every financial operation
- Webhook signature verification
- Currency code stored with every amount
- UTC timestamps for all financial records

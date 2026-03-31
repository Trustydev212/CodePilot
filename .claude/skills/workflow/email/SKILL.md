---
name: email
description: "Transactional email system. Templates, providers (Resend, SendGrid, SES), queue integration, tracking."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /email — Transactional Email System

Production email with templates, queuing, and delivery tracking.

## Usage

```
/email setup                        # Set up Resend/SendGrid/SES
/email template <name>              # Create email template
/email preview                      # Preview templates
```

## Patterns

- Resend + React Email for type-safe templates
- Essential templates: welcome, password reset, invitation, receipt, trial ending, payment failed
- Queue emails via background jobs

## Rules

- Queue emails — never send synchronously in API routes
- Include unsubscribe link for marketing emails
- Use React Email for previewable templates
- Implement email verification
- Rate limit email sending

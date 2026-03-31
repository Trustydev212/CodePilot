---
name: export
description: "Data export and reporting. PDF generation, CSV/Excel export, scheduled reports, invoice generation."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /export — Data Export & Reports

PDFs, CSV/Excel, invoices, scheduled reports.

## Usage

```
/export pdf <type>                  # PDF generation
/export csv <model>                 # CSV export
/export excel <model>               # Excel export
/export invoice                     # Invoice PDF
```

## Patterns

- CSV with proper escaping and headers
- @react-pdf/renderer for PDF invoices
- Stream large exports
- Queue large exports as background jobs

## Rules

- Queue exports >1000 rows as background jobs
- Stream large CSVs
- Respect user permissions
- Sanitize data (prevent CSV injection)
- Include timezone in dates

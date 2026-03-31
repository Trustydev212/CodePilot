---
name: search
description: "Full-text search. Elasticsearch, Algolia, Meilisearch, PostgreSQL FTS, faceted search, autocomplete."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /search — Full-Text Search

Search with autocomplete, facets, and relevance ranking.

## Usage

```
/search setup                       # Set up search engine
/search index <model>               # Index data model
/search autocomplete                # Add typeahead
/search facets                      # Faceted search
```

## Patterns

- PostgreSQL FTS for <100K records
- Meilisearch for larger datasets
- Debounced autocomplete (300ms)
- Faceted filters for large datasets

## Rules

- ALWAYS filter by orgId (tenant isolation)
- Debounce autocomplete (300ms min)
- Keep search index in sync with database
- Use highlighting for matched terms

---
name: mem
description: Query the project memory database. Search past observations, view timelines, or get full details. Use when you need to recall what happened in previous sessions.
allowed-tools: Bash
argument-hint: [search|timeline|detail|prune] [query or id]
---

# Memory Query

Query the project memory database for past observations.

## Commands

Based on the first argument, run the corresponding mem-cli command:

- `search <query>`: Run `$HOME/.claude/bin/mem-cli search "<query>"`
  Returns tier 1 results: ID, timestamp, type, and one-line summary.
  Use this to find relevant observations by keyword.

- `timeline <id>`: Run `$HOME/.claude/bin/mem-cli timeline <id>`
  Returns tier 2 results: chronological observations within 1 hour of the given observation.
  Use this to understand the sequence of events around a specific observation.

- `detail <id>`: Run `$HOME/.claude/bin/mem-cli detail <id>`
  Returns tier 3 results: full observation content including command output or file diffs.
  Use this when you need the complete context of a specific observation.

- `prune --days N`: Run `$HOME/.claude/bin/mem-cli prune --days <N>`
  Removes observations older than N days. Default is 30 days.

## Workflow

The typical retrieval pattern is progressive:
1. **Search** broadly with keywords (cheap, returns IDs + summaries)
2. **Timeline** to see what happened around interesting results
3. **Detail** to get full content of specific observations

Show results to the user. If search returns no results, suggest different keywords.

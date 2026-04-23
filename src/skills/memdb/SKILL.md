---
name: memdb
description: Initialize or check status of the project memory database. Use when starting a multi-session sprint on a project.
allowed-tools: Bash
disable-model-invocation: true
argument-hint: [init|status]
---

# Project Memory Database

Manage the per-project memory database that captures observations across sessions.

## What to do

Run the appropriate mem-cli command based on the argument:

- No argument or `init`: Run `$HOME/.claude/bin/mem-cli init`
- `status`: Run `$HOME/.claude/bin/mem-cli status`

If no argument is given:
- If memory.db does NOT exist, run init
- If memory.db already exists, run status

Show the output to the user. The memory database stores observations from tool usage
(commands, file edits, errors) and makes them searchable across sessions via FTS5.

When active, hooks automatically:
- Capture non-trivial Bash commands, file edits, and file creates
- Inject relevant past observations when the user submits a prompt
- Restore context after compaction

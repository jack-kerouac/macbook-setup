---
allowed-tools: Bash(ls:*), Bash(mv:*), Read
description: List and optionally reorder the task shelf
---

## Context

- Shelf contents: !`ls .claude/shelf/ 2>/dev/null | sort | grep -E '^[0-9]' || echo "(empty)"`

## Your task

**Step 1: List tasks**

For each numbered file in `.claude/shelf/` (in sorted order), read the first 10 lines and display:
- Sequence number and slug (from filename)
- The one-line summary from the file's Summary section

If the shelf is empty, say so and stop.

**Step 2: Reorder (if requested)**

If the user specifies a new order (e.g. "swap 2 and 3", "new order: 03, 01, 02"):

1. Rename all target files to temporary names first (prefix with `tmp-`) to avoid conflicts
2. Rename from temporary names to their final target names
3. Confirm the new sequence by listing it

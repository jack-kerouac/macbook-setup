---
allowed-tools: Bash(ls:*), Bash(rm:*), Read
description: Promote a shelved task to an external tracker and remove from shelf
---

## Context

- Shelf contents: !`ls .claude/shelf/ 2>/dev/null | sort | grep -E '^[0-9]' || echo "(empty)"`

## Your task

**Step 1: Show shelf**

For each numbered file in `.claude/shelf/`, show the sequence number, slug, and one-line summary.

If the shelf is empty, say so and stop.

**Step 2: Identify task(s) to promote**

If the user specified which task(s) to promote, proceed. Otherwise ask.

**Step 3: Format for external tracker**

For each task to promote, read its shelf file and produce a clean issue-tracker entry:

```
**Title**: {concise task title}

**Description**:
{What needs to be done — clear and actionable}

**Context**:
{Relevant background for someone picking this up cold}

**Notes**:
{Constraints, dependencies, or anything else worth capturing}
```

Present this output for the user to paste into their tracker.

**Step 4: Remove from shelf**

Delete the promoted file(s) with `rm`.

Note if the shelf is now empty.

---
allowed-tools: Bash(git status:*), Bash(git log:*), Bash(ls:*), Bash(rm:*), Read
description: Pop the top task off the shelf and load its context
---

## Context

- Git status: !`git status --short`
- Shelf contents: !`ls .claude/shelf/ 2>/dev/null | sort | grep -E '^[0-9]' || echo "(empty)"`

## Your task

The user has finished the current task and wants to start the next shelved one.

**Step 1: Check git**

If `git status --short` shows any uncommitted changes, STOP immediately:
"Uncommitted changes detected. Commit everything before popping the shelf — one task, one commit."

**Step 2: Find next task**

Find the lexicographically smallest numbered file in `.claude/shelf/` (e.g. `00-foo.md` before `01-bar.md`).

If no files exist: "The shelf is empty — you're all done!" and stop.

**Step 3: Load and delete**

Read the file fully. Then delete it with `rm`.

**Step 4: Show recent commits**

Run `git log --oneline -5` and show the output so the user has context on what was accomplished before this task.

**Step 5: Present task**

Present the full content of the shelf file. The user is now working on this task.

---
allowed-tools: Bash(git status:*), Bash(git log:*), Bash(git show:*), Bash(ls:*), Bash(rm:*), Read
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

**Step 4: Review recent commits for context**

Run `git log --oneline -10` to see recent commits. Read the task file (already loaded in step 3) to understand what the task is about, then for any commits whose message appears related to the current task, run `git show <hash>` to read the full commit message and diff. Summarize what was done in those relevant commits so the user has concrete context before diving in. Skip unrelated commits.

**Step 5: Present task**

Present the full content of the shelf file. The user is now working on this task.

Finish with: "Run `/rename` to name this session after the current task."

---
allowed-tools: Bash(date:*), Bash(ls:*), Bash(mv:*), Bash(mkdir:*), Write, Read, Edit
description: Shelve remaining tasks onto the task shelf (stack push)
---

## Context

- Current shelf: !`ls .claude/shelf/ 2>/dev/null | sort || echo "(empty)"`
- Current time: !`date "+%Y-%m-%d %H:%M"`

## Your task

The user wants to shelve remaining tasks from the current conversation to focus on one task at a time.

**Detect mode from user's phrasing:**
- **Mid-coding mode** ("shelve the rest", "shelf the remaining", etc.): Creates files starting at `01` for future tasks only. User continues in the same session.
- **Planning mode** ("shelve everything", "I want to start fresh", "planning shelve", etc.): Creates `00` for the current task too. Ends by telling user to run `/clear` then `/shelf-pop`.

**Step 1: Identify tasks**

From the current conversation, identify:
- The current task (what is being worked on right now)
- All remaining tasks to be shelved

**Step 2: Propose ordering**

Present the remaining tasks in your proposed priority order with a one-line rationale for each. Wait for the user to confirm or reorder before creating any files.

**Step 3: Determine starting number and handle existing shelf**

- In mid-coding mode: new files start at `01`.
- In planning mode: new files start at `00`.
- If `.claude/shelf/` already has numbered files (re-shelve / splitting mid-task): insert new tasks at the front. Rename existing files to make room — sort existing files by number, then renumber them sequentially starting at `start + N` (where `start` is the new first slot and N is the count of new tasks). Example: inserting 3 tasks starting at 01 with existing [03, 04] → rename 03 → 04, 04 → 05 (not 06, 07). In planning mode, also delete any existing `00-*` file (replaced by the new current task).

Rename in reverse sorted order (highest number first) to avoid overwriting files mid-sequence.

**Step 4: Create shelf files**

Create `.claude/shelf/` if it doesn't exist.

For each task (in the confirmed order), create `.claude/shelf/{NN}-{slug}.md`:
- `NN` is zero-padded (00, 01, 02...)
- `slug` is a short kebab-case label derived from the task title (2–4 words)

Each file must be a **complete briefing for a fresh Claude session with zero prior conversation history**. Write with enough context that someone starting cold can immediately dive in. Use this structure:

```
# {Task title}

**Shelved**: {datetime}
**Requires**: {What the preceding task delivers that this task builds on — omit if this is the first task or has no dependencies}

## Summary
{1–2 sentences: what needs to be done and why}

## Context
{Full context: relevant architectural decisions, constraints, code locations, why this was deferred, what was discussed}

## Task
{Concrete description of what to implement or change}
```

**Step 5: Confirm**
- Mid-coding mode: "Shelved N tasks (01–0N). Continue working on {current task}."
- Planning mode: "Shelved N tasks (00–0N). Run `/clear` then `/shelf-pop` to begin."

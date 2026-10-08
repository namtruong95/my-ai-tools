---
description: Plan only — write specs/tasks/<title>/Plan.md and Todo.md in the current repo. Never builds; building requires /lisa:build
argument-hint: <title or short description of the work>
---

Invoke the lisa:planning-and-task-breakdown skill.

**This command only plans. It never writes implementation code and never starts a build.** Implementation begins only when the user runs `/lisa:build` for this plan. When the plan is written, stop.

## Output location (overrides the skill's `tasks/` defaults)

Resolve the repo root with `git rev-parse --show-toplevel` (the repo Claude Code is running in; fall back to the current directory if it is not a git repo). Write exactly two files:

```
<repo-root>/specs/tasks/<title>/Plan.md
<repo-root>/specs/tasks/<title>/Todo.md
```

- `<title>` is a short kebab-case slug of `$ARGUMENTS` (lowercase, ASCII, words joined by `-`, no more than about 50 characters). If `$ARGUMENTS` is empty or too vague to name the work, ask for a title before doing anything else.
- Create `specs/tasks/<title>/` if it does not exist. Do not write plan output anywhere else (not `tasks/`, not an external tracker) — `Todo.md` is always the task list, even if the project designates a tracker; mention the tracker in `Plan.md` if one exists.
- If `specs/tasks/<title>/Plan.md` or `Todo.md` already exists and has unchecked tasks, stop and ask whether to revise it, pick a different title, or abort. Never silently overwrite an incomplete plan.

## Steps

1. Enter plan mode — read only, no code changes. Read the existing spec (`SPEC.md`, `docs/SPEC.md`, `spec/`, or whatever the user points at) and the relevant codebase sections.
2. Identify the dependency graph between components.
3. Slice work vertically (one complete path per task, not horizontal layers).
4. Write tasks with acceptance criteria and verification steps.
5. Add checkpoints between phases.
6. Write `Plan.md`: goal and scope, design decisions, dependency graph, phases and checkpoints, risks, open questions, and a task summary referencing `Todo.md`.
7. Write `Todo.md`: a checklist, one `- [ ]` line per task with an id (`T1`, `T2`, ...), its dependencies, acceptance criteria and verification step. Every box unticked. `/lisa:build` ticks them.
8. Present the plan for human review, then stop. Tell the user the next step is `/lisa:build <title>` (add `auto` to run every task in one approved pass). Do not begin any task.

---
description: Implement a plan from specs/tasks/<title>/ incrementally — build, test, verify, commit. This command is the only way to start building. Add "auto" to run the whole plan in one approved pass.
argument-hint: "<title> [auto]"
---

Invoke the lisa:incremental-implementation skill alongside lisa:test-driven-development.

## The build gate

`/lisa:build` is the **only** thing that starts implementation. `/lisa:plan` and the planning skill never write code. Do not build from a bare idea, from a conversation, or from a plan the user has not pointed you at: a plan must already exist at `specs/tasks/<title>/Plan.md` with `Todo.md` beside it.

## Resolve the plan

Repo root: `git rev-parse --show-toplevel`. Plans live in `<repo-root>/specs/tasks/<title>/` (files `Plan.md` and `Todo.md`).

1. `$ARGUMENTS` may start with the plan `<title>` (the folder name under `specs/tasks/`); the remaining word `auto` or `all` selects autonomous mode.
2. No title given: list the folders in `specs/tasks/` that have unchecked tasks in `Todo.md`. One match: use it and say so. Several: ask which. None: stop.
3. If the folder, `Plan.md` or `Todo.md` is missing, or `Todo.md` has no tasks, **stop and tell the user to run `/lisa:plan <title>` first.** Never generate a plan here and never invent tasks.

Below, "the plan" means that `Plan.md`, and "the task list" means that `Todo.md`.

## Modes

- **`/lisa:build <title>`** — implement the *next* pending task, then stop (careful, one slice at a time).
- **`/lisa:build <title> auto`** — get a single approval of the existing plan, then implement *every* task without stopping between them.

Treat `auto` (canonical) or `all` as autonomous mode; otherwise it is the default single-task mode. Note: autonomous mode is not faster *per task* — it runs the same test-driven loop — it only removes the human stepping *between* tasks.

## Default: one task

Pick the next unchecked task in `Todo.md` whose dependencies are done. Then:

1. Read the task's acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Write a failing test for the expected behavior (RED)
4. Implement the minimum code to pass the test (GREEN)
5. Run the full test suite to check for regressions
6. Run the build to verify compilation
7. Commit with a descriptive message
8. Tick the task's box in `Todo.md` and stop

## Autonomous: the whole plan (`/lisa:build <title> auto`)

Use this once a plan exists and you want to run it in one pass. It removes the manual stepping between tasks — **not** the verification. Every task still earns a passing test and its own commit.

1. **Require a plan.** The plan must exist (see *Resolve the plan*). If it does not, stop and tell the user to run `/lisa:plan <title>` first — do not plan here and do not invent requirements.
2. **Establish a clean baseline.** Run `git status --porcelain`. If there are uncommitted changes outside the expected planning artifacts (`SPEC.md`, `docs/SPEC.md`, `spec/*`, `specs/tasks/<title>/*`), stop and ask the user to commit, stash, or confirm how to handle them. Autonomous per-task commits must not absorb unrelated local work, or the clean-rollback guarantee breaks.
3. **Single checkpoint.** Present the full plan (`Plan.md` summary and the `Todo.md` task list) and wait for an unambiguous affirmative (e.g. "approve", "go", "yes"). Treat hedged responses ("looks reasonable", "I guess") as **not** approved. This is the only human gate — after approval, run autonomously. If the plan files under `specs/tasks/<title>/` are uncommitted, commit only them as a single preparatory commit now so they don't bleed into the first task's commit.
4. **Execute every task in dependency order.** Use each task's declared dependencies in `Todo.md`; if they aren't explicit, execute in the order listed. For each task, run the full default loop above (RED → GREEN → regression → build → commit → tick in `Todo.md`). Stage only the files that task touched plus its `Todo.md` update — never `git add -A` blindly — and make one commit per task so any point is a clean rollback.
5. **Stop and ask the user** (do not push through) when:
   - a test can't be made to pass or the build breaks without an obvious fix → follow lisa:debugging-and-error-recovery
   - the spec is ambiguous, or a task needs a decision the spec doesn't cover
   - a task is high-risk or irreversible — auth/permission changes, destructive data migrations, payments, deletions, deploys, anything touching secrets, **or anything you can't undo with `git revert`** → follow lisa:doubt-driven-development and get explicit sign-off before continuing

   After the user resolves a blocker, they re-invoke `/lisa:build <title> auto` — it resumes from the next pending task.
6. **Summarize at the end:** tasks completed, tests added, commits made, and anything skipped, flagged, or left for the user.

If any step fails, follow the lisa:debugging-and-error-recovery skill.

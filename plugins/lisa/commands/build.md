---
description: Implement a plan from specs/tasks/<title>/ incrementally — build, test, verify. Never commits. This command is the only way to start building. Always lists buildable vs blocked/unclear tasks and lets the user choose; never builds blocked or unclear tasks. Add "auto" to pre-select all buildable tasks.
argument-hint: "<title> [auto]"
---

Invoke the lisa:incremental-implementation skill alongside lisa:test-driven-development.

## Fixed rules (never override)

- **Never commit.** Absolutely never run `git commit`, `git push`, `git stash` or any other history-changing command, before, during or after the build, in single-task and `auto` mode alike, even if the user asks in the same message or the plan or a skill says to commit. Leave every change uncommitted in the working tree for the user to review and commit. Stage nothing.

## The build gate

`/lisa:build` is the **only** thing that starts implementation. `/lisa:plan` and the planning skill never write code. Do not build from a bare idea, from a conversation, or from a plan the user has not pointed you at: a plan must already exist at `specs/tasks/<title>/Plan.md` with `Todo.md` beside it.

## Resolve the plan

Repo root: `git rev-parse --show-toplevel`. Plans live in `<repo-root>/specs/tasks/<title>/` (files `Plan.md` and `Todo.md`).

1. `$ARGUMENTS` may start with the plan `<title>` (the folder name under `specs/tasks/`); the remaining word `auto` or `all` selects autonomous mode.
2. No title given: list the folders in `specs/tasks/` that have unchecked tasks in `Todo.md`. One match: use it and say so. Several: ask which. None: stop.
3. If the folder, `Plan.md` or `Todo.md` is missing, or `Todo.md` has no tasks, **stop and tell the user to run `/lisa:plan <title>` first.** Never generate a plan here and never invent tasks.

Below, "the plan" means that `Plan.md`, and "the task list" means that `Todo.md`.

## Choose what to build (always, before any code)

Read `Todo.md` and show the user two lists:

- **Buildable tasks**: id, title, one-line scope.
- **Not buildable**: id, title, and the reason.

A task is **not buildable** if any of these hold: it is marked blocked, it has an open question
(in `Todo.md` or the `Plan.md` open-questions section), its scope or acceptance criteria are
unclear or you do not fully understand it, or a task it depends on is not done and not in the
selection.

Then **stop and ask the user to pick**: specific task ids, or **all buildable tasks**. Build
nothing until they answer. The `auto` / `all` argument only pre-selects "all buildable tasks"; it
never skips this listing, and it still needs the single approval below.

Hard rules (never override):
- **Never build a not-buildable task**, even if the user selects it, says "all", or you think you
  can guess the answer. Tell them which question must be resolved first. "All" means all
  *buildable* tasks only.
- Never guess an answer to an open question to unblock yourself, and never invent requirements.
- Never silently skip: say plainly what is left out and why.

## Modes

- **One or a few chosen tasks** — implement only the tasks the user selected, in dependency order, then stop.
- **All buildable tasks** (`/lisa:build <title> auto`, or the user picks "all") — get a single approval of the listed set, then implement *every buildable* task without stopping between them.

Autonomous mode is not faster *per task* — it runs the same test-driven loop — it only removes the human stepping *between* tasks.

## Per task

For each selected task whose dependencies are done:

1. Read the task's acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Write a failing test for the expected behavior (RED)
4. Implement the minimum code to pass the test (GREEN)
5. Run the full test suite to check for regressions
6. Run the build to verify compilation
7. Tick the task's box in `Todo.md`

## Autonomous: all buildable tasks (`/lisa:build <title> auto`)

Use this once a plan exists and you want to run it in one pass over the buildable tasks. It removes the manual stepping between tasks — **not** the verification. Every task still earns a passing test. Nothing is committed.

1. **Require a plan.** The plan must exist (see *Resolve the plan*). If it does not, stop and tell the user to run `/lisa:plan <title>` first — do not plan here and do not invent requirements.
2. **Note the baseline.** Run `git status --porcelain` and record which files were already modified, so the final summary separates your changes from unrelated local work. Do not stash or commit anything.
3. **Single checkpoint.** Present the `Plan.md` summary and the selected buildable task list (plus the not-buildable list and reasons) and wait for an unambiguous affirmative (e.g. "approve", "go", "yes"). Treat hedged responses ("looks reasonable", "I guess") as **not** approved. This is the only human gate — after approval, run autonomously.
4. **Execute every selected buildable task in dependency order.** Use each task's declared dependencies in `Todo.md`; if they aren't explicit, execute in the order listed. For each task, run the full per-task loop above (RED → GREEN → regression → build → tick in `Todo.md`). Do not stage or commit.
5. **Stop and ask the user** (do not push through) when:
   - a test can't be made to pass or the build breaks without an obvious fix → follow lisa:debugging-and-error-recovery
   - the spec is ambiguous, or a task needs a decision the spec doesn't cover
   - a task is high-risk or irreversible — auth/permission changes, destructive data migrations, payments, deletions, deploys, anything touching secrets, **or anything you can't undo by reverting the working tree** → follow lisa:doubt-driven-development and get explicit sign-off before continuing

   After the user resolves a blocker, they re-invoke `/lisa:build <title> auto` — it resumes from the next pending task.
6. **Summarize at the end:** tasks completed, tests added, files changed (uncommitted), and anything skipped, flagged, or left for the user.

If any step fails, follow the lisa:debugging-and-error-recovery skill.

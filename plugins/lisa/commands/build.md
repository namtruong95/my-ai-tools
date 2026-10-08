---
description: Implement a plan from specs/tasks/<title>/ incrementally — build, test, verify. Never commits. This command is the only way to start building. Builds every phase and task without commits; stops at the first unclear task or open question.
argument-hint: "<title>"
---

Invoke the lisa:incremental-implementation skill alongside lisa:test-driven-development.

## Fixed rules (never override)

- **Never commit.** Absolutely never run `git commit`, `git push`, `git stash` or any other history-changing command, before, during or after the build, in single-task and `auto` mode alike, even if the user asks in the same message or the plan or a skill says to commit. Leave every change uncommitted in the working tree for the user to review and commit. Stage nothing.
- **Skill commit steps are void.** `lisa:incremental-implementation` (its "Commit" step, "one commit per increment" and "The change is committed" checklist items) and `lisa:git-workflow-and-versioning` tell you to commit after each increment or phase. Ignore every one of those instructions here: no commit after a task, no commit after a phase, no checkpoint commit, no preparatory commit. Treat "committed" checklist items as satisfied by "verified and left uncommitted".

## The build gate

`/lisa:build` is the **only** thing that starts implementation. `/lisa:plan` and the planning skill never write code. Do not build from a bare idea, from a conversation, or from a plan the user has not pointed you at: a plan must already exist at `specs/tasks/<title>/Plan.md` with `Todo.md` beside it.

## Resolve the plan

Repo root: `git rev-parse --show-toplevel`. Plans live in `<repo-root>/specs/tasks/<title>/` (files `Plan.md` and `Todo.md`).

1. `$ARGUMENTS` may start with the plan `<title>` (the folder name under `specs/tasks/`); any remaining word (`auto`, `all`) is ignored: the build always runs every task.
2. No title given: list the folders in `specs/tasks/` that have unchecked tasks in `Todo.md`. One match: use it and say so. Several: ask which. None: stop.
3. If the folder, `Plan.md` or `Todo.md` is missing, or `Todo.md` has no tasks, **stop and tell the user to run `/lisa:plan <title>` first.** Never generate a plan here and never invent tasks.

Below, "the plan" means that `Plan.md`, and "the task list" means that `Todo.md`.

## Build everything (fixed rule)

`/lisa:build <title>` builds **every phase and every task** in `Todo.md`, in dependency order (listed order if not explicit), in one run. Do not ask the user to pick tasks, do not stop between tasks or phases, and do not ask for approval first. The `auto` / `all` argument is accepted and changes nothing.

Before the first task, scan `Todo.md` and `Plan.md` and print one line per task (id, title) so the user can see the run order. Then start building.

## Stop rule (fixed, never override)

A task is **unclear** if it has an open question or an unanswered Q&A (in `Todo.md` or the `Plan.md` open-questions section), its scope or acceptance criteria are unclear, or you do not fully understand it.

When you reach an unclear task:
- **Do not build it**, and do not guess an answer or invent requirements.
- **Stop the build there.** Build nothing after it either, even if later tasks look independent.
- Report in Vietnamese: the tasks already built, the task you stopped at, and the exact question(s) the user must answer. After they answer, `/lisa:build <title>` resumes from the next unchecked task.

Only unclear tasks stop the build. A merely pending or slow task never does.

## Per task

1. Read the task's acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Write a failing test for the expected behavior (RED)
4. Implement the minimum code to pass the test (GREEN)
5. Run the full test suite to check for regressions
6. Run the build to verify compilation
7. Tick the task's box in `Todo.md`

Every task still earns a passing test. Nothing is committed or staged.

## Run

1. **Require a plan.** The plan must exist (see *Resolve the plan*). If it does not, stop and tell the user to run `/lisa:plan <title>` first — do not plan here and do not invent requirements.
2. **Note the baseline.** Run `git status --porcelain` and record which files were already modified, so the final summary separates your changes from unrelated local work. Do not stash or commit anything.
3. **Execute every task** per the sections above. Only skip checks for unclear tasks (stop rule). Never push through a failure:
   - a test can't be made to pass or the build breaks without an obvious fix → follow lisa:debugging-and-error-recovery
   - a task is high-risk or irreversible — auth/permission changes, destructive data migrations, payments, deletions, deploys, anything touching secrets, **or anything you can't undo by reverting the working tree** → follow lisa:doubt-driven-development and get explicit sign-off before continuing
4. **Summarize at the end:** tasks completed, tests added, files changed (uncommitted), and the stop point and open questions if the run stopped early.

If any step fails, follow the lisa:debugging-and-error-recovery skill.

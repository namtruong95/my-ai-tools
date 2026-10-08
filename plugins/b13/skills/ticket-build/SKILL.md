---
name: ticket-build
description: Implements a ticket from its AC.md, CheckList.md and Plan.md, ticking the checklist as each step lands and writing the FE hand-off into Output.md. Use when asked to build or implement a ticket that has a Plan.md, or to continue an in-progress ticket. Invoking this skill IS the build command that authorises writing code.
---

# Ticket Build

Execute a ticket's `Plan.md` phase by phase. After every task, tick the matching lines in
`CheckList.md`. When the code is done, write the FE hand-off into `Output.md`.

Companion to `b13:ticket-plan`, which produces the `Plan.md` this skill consumes. Project
conventions (`specs_root`, `base_branch`, `verify_commands`, `output_language`, ...) are the
same optional `## b13` section in the project's `CLAUDE.md` / `AGENTS.md` described in
`b13:ticket-plan`, with the same defaults.

## The build gate

Implementation code is not written until the user gives the build command. **Invoking this
skill is that command**: asking for `b13:ticket-build` authorises writing code for the resolved
ticket, and for nothing else.

On start, stamp section 0 of `Plan.md`:

```
## 0. Build command
`b13:ticket-build <ticket>` — run <YYYY-MM-DD>
```

Two things this authorisation does **not** cover:
- **Committing or pushing.** Absolutely never run `git commit`, `git push`, `git stash` or any
  other history-changing command, even when asked in the same message or when the work is done.
  Leave the working tree uncommitted for the user to review and commit themselves.
- **Other tickets.** One invocation builds one ticket. If work spills into another ticket's
  scope, stop and report it (the AC and any `scope_ceiling_docs` are the ceiling).

## Step 1: Resolve the ticket

Identical to `b13:ticket-plan`. Discover the layout (`fd AC.md <specs_root>`), then resolve the
ticket from the user's argument, from the checked-out branch name (`rg -l '<branch>' --glob
'AC.md'`), or by asking. A bare ticket id can exist in more than one folder group; search them
all and ask if several match. Never guess.

Below, `<ticket>` is the resolved folder.

## Step 2: Read the inputs, in this order

| File | Read it for |
|---|---|
| `Plan.md` | **The task list.** This is what you execute |
| `AC.md` | Behaviour, exact display strings, HTTP status/codes, decision log, API contract |
| `CheckList.md` | The tick-list you keep updated as you go |
| `handoff_rules_file`, `scope_ceiling_docs` (if configured) | Branch/PR flow, scope ceiling, hand-off requirement |
| Project `CLAUDE.md` / `AGENTS.md` | Architecture conventions, registration, auth, DTO shaping, migrations |

**If `Plan.md` has no task list**, stop and run `b13:ticket-plan` first. Do not improvise a
plan and start coding from it.

## Step 3: Build everything, stop at unclear tasks

Fixed rule (never override): build **every phase and every task** in `Plan.md`, in plan order, in
one run. Do not ask the user to pick tasks and do not stop between tasks or phases. Print the task
ids and titles first so the user can see the run order, then start.

A task is **unclear** if it is blocked by an unresolved AC point (🟡 / 🔴), has an open question
or unanswered Q&A, has unclear scope or AC, or you do not fully understand it.

When you reach an unclear task:
- **Do not build it.** Never guess an answer to an open AC point to unblock yourself.
- **Stop the build there**, and build nothing after it, even if later tasks look independent.
- Report: the tasks built, the task you stopped at, and the exact question(s) to answer. Re-running
  `b13:ticket-build` resumes from the first unticked task.

Only unclear tasks stop the build.

## Step 4: Build one task at a time

For each task, in plan order:

1. **Read before writing.** Open the nearest existing equivalent in the repo and match it:
   naming, file layout, which base class it extends, how errors are raised.
2. **Implement the task, and only the task.** No adjacent cleanup, no refactoring files you are
   only reading, no behaviour that is not in the AC. Note anything worth fixing later instead of
   fixing it.
3. **Verify**: see Step 5.
4. **Tick the checklist**: see Step 6.
5. Move to the next task. Do not batch several tasks and verify at the end.

### Conventions that trip people up

Take these from the project, not from memory. Read the project's `CLAUDE.md` / `AGENTS.md` and
the closest existing code, then follow it. Things to check every time:

- **File granularity and naming.** Match how existing services/handlers are split and named.
- **Registration.** New entities, modules, routes or config entries often need an explicit
  registration step somewhere separate from the file itself.
- **Authorisation.** Check how roles/permissions match (exact vs hierarchical) before
  assuming a higher role covers a lower one.
- **Response shaping.** Never return persistence models directly; use the project's DTO
  or serializer pattern.
- **Errors follow the AC.** Use the exact strings and shape from the AC's message/error
  sections. Do not invent new wording.
- **Naming conventions** for columns, fields and files match the existing schema.

## Step 5: Verify after each task

Run what applies, and read the output rather than assuming it passed. Use `verify_commands`
when configured. Otherwise detect them from the project:

| Stack signal | Typical commands |
|---|---|
| `package.json` | the `typecheck` / `lint` / `format` / `test` / `build` scripts (via the project's package manager) |
| `tsconfig.json` only | `npx tsc --noEmit`, the project's linter and formatter on changed files |
| `pyproject.toml` | `ruff` / `mypy` / `pytest` as configured |
| `go.mod` | `go build ./...`, `go vet ./...`, `go test ./...` |
| `Cargo.toml` | `cargo check`, `cargo clippy`, `cargo test` |
| `Makefile` | the `lint` / `test` / `build` targets |

If the project's package manager is not on `PATH`, fall back to the equivalent binary
(for example `npx` with the tool in `node_modules`) and say so in the report instead of
claiming the original command ran.

Long-running commands (migrations, dev server, tests) go in tmux named after the current
directory:

```bash
SESSION=$(basename "$PWD")
tmux new -d -s "$SESSION" 2>/dev/null
tmux send-keys -t "$SESSION" '<command>' Enter
tmux capture-pane -p -t "$SESSION" -S -40
```

**Prove a migration both ways**: apply it, revert it, apply it again, using the project's own
migration runner. A migration that cannot revert is not finished.

Where a task encodes a rule the database enforces (CHECK constraint, unique index), verify it
with real data before declaring it done, then clean up the test rows.

## Step 6: Update `CheckList.md` after every task

This is not optional bookkeeping. The checklist is how the user tracks the ticket.

- Tick `- [ ]` → `- [x]` for every line the task actually satisfied.
- If a decision made during the build changed what a line means, rewrite that line rather than
  ticking something now inaccurate.
- If a line turns out to be blocked, leave it unticked and mark it 🟡 with the reason.
- Never tick a line you did not verify.

Keep it in the same edit rhythm as the code: task done, checklist updated, then next task.

## Step 7: Write `Output.md` (English, required deliverable)

The FE hand-off is the actual deliverable of the ticket. Write it to `<ticket>/Output.md`, **in
English**, even when `AC.md`, `CheckList.md` and `Plan.md` use another language.

````markdown
# Output: <ticket id>. <ticket title>

> Branch: `<branch>` · API docs: <link or path to Swagger / OpenAPI group, if the project has one>

## Endpoints

| Method | Path | Purpose | Roles |
|---|---|---|---|

## Request DTOs

### `<DtoName>`
| Field | Type | Required | Constraints |
|---|---|---|---|

## Response DTOs

### `<DtoName>`
| Field | Type | Notes |
|---|---|---|

Paginated endpoints: describe the project's pagination envelope here, using its real field names.

## Errors

| Case | HTTP | `code` | Message |
|---|---|---|---|

Validation failures: describe the project's global validation error shape here.

## Behaviour notes for FE

- <polling interval and which endpoint to call>
- <which field drives which icon/badge>
- <lazy persistence, ordering, timezone handling: anything FE cannot infer from the shapes>

## Not in this ticket

| Behaviour | Ticket that covers it |
|---|---|
````

Copy the API contract section of `AC.md` (if the ticket has one) into the behaviour notes
rather than paraphrasing it. FE and BE must read the same words. Take the pagination and
validation shapes from the project's actual code, never from memory.

## Step 8: Report and stop

Report honestly:

- Tasks completed, tasks skipped and what blocks each.
- Verification actually run, with results. If something failed, say so and show the output.
- Files changed.
- What is left for the user: reviewing, committing, answering the still-open AC points.

Then stop. Do not commit, do not push, do not start the next ticket.

## Common mistakes

| Mistake | Instead |
|---|---|
| Building all tasks, then verifying once | Verify and tick after every task |
| Guessing an open AC point to unblock a task | Skip the task, report the blocker |
| Ticking the checklist optimistically | Tick only what you verified |
| `Output.md` in a non-English language | English: it is the FE hand-off |
| Inventing an error string not in the AC | Use the exact string; if none exists, flag it |
| Committing when the build finishes | Never commit, ever |
| Claiming a command passed when its tool is not installed | Report the command you actually ran |

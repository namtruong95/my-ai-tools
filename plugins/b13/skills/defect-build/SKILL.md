---
name: defect-build
description: Implements a defect fix from its Defects/<branch>.md file (produced by b13:defect-plan). Makes the code change, verifies it, ticks the manual-verification checklist, and writes the FE hand-off into the same file. Use when asked to build or fix a defect that has a Defects/<branch>.md plan, or to continue one already in progress. Invoking this skill IS the build command that authorises writing code.
---

# Defect Build

Execute a defect's fix plan from `Defects/<branch>.md`, the file `b13:defect-plan` produces.
Same relationship as `b13:ticket-build` has to `b13:ticket-plan`, scoped to a defect against an
already-built ticket instead of the ticket's first build.

Project conventions (`specs_root`, `base_branch`, `verify_commands`, ...) are the optional
`## b13` section in the project's `CLAUDE.md` / `AGENTS.md` described in `b13:ticket-plan`, with
the same defaults.

## The build gate

Implementation code is not written until the user gives the build command. **Invoking this
skill is that command**: asking for `b13:defect-build` authorises writing code for the resolved
defect, and for nothing else.

On start, stamp section 0 of `Defects/<branch>.md`:

```
## 0. Build command
`b13:defect-build <branch>` — run <YYYY-MM-DD>
```

Two things this authorisation does **not** cover:
- **Committing or pushing.** Absolutely never run `git commit`, `git push`, `git stash` or any
  other history-changing command, even when asked in the same message or when the work is done.
  Leave the working tree uncommitted for the user to review and commit themselves.
- **Scope beyond the fix plan.** If something else looks broken while you are in there, note it
  in the report. Do not fix it as a drive-by; the AC and any `scope_ceiling_docs` are the
  ceiling, same as for any ticket.

## Step 1: Resolve the ticket and the defect file

```
<ticket>/Defects/<branch>.md
```

Resolve `<branch>` from the user's argument, or from the checked-out working branch
(`git branch --show-current`). If a bare ticket id is given instead, find its `Defects/` folder
and, if it holds more than one file, ask which defect. Never guess between tickets or defects.

**If `Defects/<branch>.md` does not exist or has no fix plan (§2 empty)**, stop and run
`b13:defect-plan` first. Do not improvise a plan and start coding from a bare defect report.

## Step 2: Make sure you are on the right branch

`git status`. If dirty, stop and ask. `git branch --show-current` should already be `<branch>`
(set by `b13:defect-plan`); if not, `git checkout <branch>` (never `-b` here; the branch should
already exist from the plan step).

## Step 3: Read the inputs, in this order

| File | Read it for |
|---|---|
| `Defects/<branch>.md` §1-2 | Root cause and **the task list**: this is what you execute |
| `Defects/<branch>.md` §3 | Which decided points this fix touches; do not drift past them |
| The ticket's `AC.md` | Exact display strings, status/codes, decision log. Do not contradict a `✅ DECIDED` entry the fix plan did not already flag |
| `handoff_rules_file`, `scope_ceiling_docs` (if configured) | Branch/PR flow, scope ceiling, hand-off requirement |
| Project `CLAUDE.md` / `AGENTS.md` | Architecture conventions, registration, auth, DTO shaping, migrations |

## Step 4: Decide what is buildable, then let the user choose

Show the user two lists from the fix plan's file/change table:

- **Buildable tasks**: row id or file, and the change.
- **Not buildable**: the row and the reason: an open question, anything unclear or not yet
  understood, an undecided AC point (🟡 / 🔴) in §3, or an unfinished dependency.

Then **stop and ask the user to pick**: specific rows, or **all buildable rows**. Build nothing
until they answer.

Hard rules (never override):
- **Never build a not-buildable row**, even if the user selects it or asks for "all". Tell them
  which question must be resolved first. "All" means all *buildable* rows only.
- Never guess an answer to an open question to unblock yourself.
- Never silently skip: say plainly what is left out and why.

## Step 5: Build one task at a time


For each row the user chose:

1. **Read before writing.** Open the file, understand the surrounding pattern (which base class
   it extends, how sibling services handle the same relation/DTO shape) before editing.
2. **Implement the task, and only the task.** No adjacent cleanup, no refactoring files you are
   only reading, no behaviour beyond what the fix plan and the AC actually call for.
3. **Verify**: see Step 6.
4. Move to the next task. Do not batch several tasks and verify at the end.

The same project conventions apply as in `b13:ticket-build` (file granularity, registration of
new entities/modules, exact authorisation matching, never returning persistence models, exact
AC error strings, naming conventions). Take them from the project's own docs and code.

## Step 6: Verify after each task

Use `verify_commands` when configured; otherwise detect typecheck, lint, format and test
commands from the project (see the table in `b13:ticket-build`). Read the output; do not assume
it passed. If the project's package manager is not on `PATH`, fall back to the equivalent binary
and say so rather than claiming the original command ran.

If the fix plan calls for a migration, use the project's own migration runner and prove it both
ways: apply, revert, apply again.

Long-running commands go in tmux named after the current directory:

```bash
SESSION=$(basename "$PWD")
tmux new -d -s "$SESSION" 2>/dev/null
tmux send-keys -t "$SESSION" '<command>' Enter
tmux capture-pane -p -t "$SESSION" -S -40
```

## Step 7: Tick the manual-verification checklist

`Defects/<branch>.md` §4 holds the concrete repro steps, including the originally reported
scenario. Actually exercise them (manual API calls, or read the code path closely enough to
state with confidence what it now returns) before ticking `- [ ]` → `- [x]`. Never tick a step
you did not verify. If a step cannot be verified without something outside this skill's reach
(for example a live two-browser session), say so plainly instead of ticking it.

## Step 8: Write the FE hand-off (§5, English, required)

Same requirement as `b13:ticket-build`'s `Output.md`. Replace the "Not yet built" placeholder
in `Defects/<branch>.md` §5 with the actual hand-off:

- Which endpoint(s) / response field(s) changed, and how (additive vs. breaking).
- Any new behaviour note the FE must act on to actually observe the fix (for example a new
  polling signal it must also check). Call this out prominently: an additive-but-unused field
  fixes nothing on its own.
- If the fix plan named other spec files to update (for example another ticket's `Output.md`),
  do that now too, and say so in the report.

## Step 9: Report and stop

Report honestly:

- Tasks completed, tasks skipped and what blocked each.
- Verification actually run, with results.
- Checklist items ticked vs. left unticked, and why for any left unticked.
- Files changed.
- What is left for the user: reviewing, committing, confirming the FE has been told.

Then stop. Do not commit, do not push, do not start another ticket or defect.

## Common mistakes

| Mistake | Instead |
|---|---|
| Building from a bare defect report with no `Defects/<branch>.md` plan | Run `b13:defect-plan` first |
| Ticking the verification checklist optimistically | Tick only what you actually verified |
| Adding a field but not flagging that FE must also change to observe the fix | Say so explicitly in §5; additive is not automatically "done" |
| Fixing an unrelated bug noticed along the way | Note it in the report, do not fix it here |
| Committing when the fix is done | Never commit, ever |
| Silently reopening a decided `AC.md` point the fix plan did not already flag | Stop and ask, same as any ticket work |

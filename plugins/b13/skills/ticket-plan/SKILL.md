---
name: ticket-plan
description: Turns a ticket's AC.md (acceptance criteria) into an implementation Plan.md inside that ticket's folder, and creates the ticket's CheckList.md when it does not exist yet. Use when starting work on a ticket that has an AC.md, when asked to "plan ticket X", or after the AC for a ticket has been confirmed. Produces planning docs only, never code.
---

# Ticket Plan

Read a ticket's `AC.md` (and its `CheckList.md` if one exists), survey the codebase for the
patterns the ticket will have to follow, and write the result to `Plan.md` **in that same
ticket folder**. When the ticket has no `CheckList.md` yet, create it too: `b13:ticket-build`
ticks that file as it works, so a ticket must not reach build without one.

## Project conventions (read first)

Defaults below apply unless the project overrides them. Look for an optional `## b13` section in
the project's `CLAUDE.md` or `AGENTS.md` (keys are plain `key: value` bullets):

| Key | Default |
|---|---|
| `specs_root` | `specs/` |
| `ticket_dir` | `<specs_root>/<ticket>/`, or any folder that holds an `AC.md`; discover it, do not assume |
| `base_branch` | `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`), else `main` |
| `ticket_id_prefix` | none (branch names are used as-is) |
| `output_language` | the language `AC.md` is written in (`Output.md` is always English, see `b13:ticket-build`) |
| `verify_commands` | detected from `package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, etc. |
| `scope_ceiling_docs` | none; when set, those documents bound what may be built |
| `handoff_rules_file` | none; project file describing branch/PR flow and the hand-off requirement |

If a key is missing and cannot be detected, ask once instead of guessing.

## Hard rule: this skill never writes code

The plan *is* the deliverable. Do not create or modify source code. Implementation starts only
after the user runs the build command, which they fill into section 0 of the `Plan.md` this
skill produces (or by invoking `b13:ticket-build`).

Allowed: reading anything, and writing the ticket's `Plan.md` and `CheckList.md`. Both are
planning files, outside the gate. Never edit `AC.md` (that is `b13:ac-review`'s job, and only
with the user's confirmation).

## Step 1: Resolve the ticket

Never assume the ticket. Discover the layout first, for example
`fd AC.md <specs_root>` or `rg --files -g 'AC.md'`.

A ticket folder typically looks like:

```
<specs_root>/.../<ticket>/
  AC.md  CheckList.md  Plan.md  Output.md
```

Resolve the ticket in this order:

1. An argument the user passed: a ticket id, a folder name, or a full path. A bare id can exist
   in more than one group of folders, so search all of them and ask if more than one matches.
2. The checked-out working branch. Search every `AC.md` for the branch name (and, when
   `ticket_id_prefix` is set, the id with that prefix): `rg -l '<branch>' --glob 'AC.md'`.
3. Otherwise list the most recently modified ticket folders and ask which one.

Never guess. Confirm before writing. Below, `<ticket>` is the resolved ticket folder.

## Step 2: Read the inputs

Read the ticket's `AC.md` in full, and its `CheckList.md` too when the file exists. Extract:

| From | What |
|---|---|
| Behaviour sections of `AC.md` | The behaviour to build, per sub-section |
| Message / error / status sections | Exact display strings, HTTP status, error codes |
| Decision log (if present) | Which points are `✅ DECIDED`, which are `🟡` / `⚠️` still open |
| API / contract section (if present) | BE/API contract decisions |
| `CheckList.md` *(if present)* | Work already itemised: the plan groups these, it does not restate them |

If `CheckList.md` **does not exist**, say so and carry on. You will create it in Step 7 from
the phases you are about to define. Do not block the plan on it.

Also read, when they exist: the project's `handoff_rules_file`, any `scope_ceiling_docs`, sprint
or milestone summary files next to the ticket (ordering, estimates, cross-ticket dependencies),
and the project's `CLAUDE.md` / `AGENTS.md` for architecture conventions (service layout,
registration of new modules, auth, DTO shaping, validation and pagination formats).

## Step 3: Surface what is still open, do not plan around it

Scan for `🟡`, `⚠️`, `Open question`, `TBD`, `pending`. For each open point, record in the plan:

- what it blocks (schema / API shape / a single service / nothing),
- whether the surrounding work can still proceed without it.

**Distinguish blocking from non-blocking.** An open point that only affects one query does not
justify pausing the whole ticket; one that changes a column does. Say which, explicitly.

If an open point would change the schema, mark the affected task 🔴 and do not schedule it.

## Step 4: Survey the codebase before writing tasks

Ground every task in what already exists. At minimum check:

- Does a similar module or feature exist? Which base class or helper does it use?
- Which entities, models or types already cover part of this?
- Is there a shared service or utility to reuse instead of writing new code?
- What does the closest existing migration, schema change or config registration look like?

Name the concrete files in the tasks. A task that says "create the service" without naming the
file or the base it builds on is not finished being planned.

## Step 5: Slice into phases

Order by dependency, foundation first. A typical backend ticket:

```
Phase 1  Schema      data model + migration + registration
Phase 2  API         module + DTOs + services + controller + auth/guards
Phase 3  Rules       validation, anti-abuse, third-party integration
Phase 4  Hand-off    Output.md (English) + lint/typecheck + manual API pass + notes to other tickets
```

Adjust to the stack and the ticket. A half-hour ticket does not need four phases. Keep each task
small enough to implement and verify in one sitting; if a task title needs the word "and", split
it.

Every task must be traceable to a specific AC section, the same way `CheckList.md` is.

## Step 6: Write `Plan.md`

Write to `<ticket>/Plan.md`, the same folder the `AC.md` came from. Use `output_language`
(default: the language of `AC.md` and `CheckList.md`). Only `Output.md` is always English.

Template (translate the headings into `output_language`):

````markdown
# Plan: <ticket id>. <ticket title>

> **Branch:** `<branch>` · **Estimate:** <h> · **Due:** <date>
> Follows `AC.md` and `CheckList.md` in the same folder.
> ⚠️ **Write no code until the user sets the build command in section 0.**

---

## 0. Build command

> The user fills this in. No value means **no code may be written yet**.

```
(not set)
```

---

## 1. Inputs

**Decided**: decisions that directly affect this plan:

| Decision | Impact |
|---|---|
| ... | Schema / API / Service |

**🟡 Still open:**

| Point | What it blocks | Can work continue? |
|---|---|---|
| ... | ... | ... |

---

## 2. Phases

### Phase N: <name>

| # | Task | File | AC |
|---|---|---|---|
| N.1 | ... | `path/to/file` | 4.x |

**Verify:** <specific command or way to check>

---

## 3. Order and dependencies

<ASCII diagram, and state which task is blocked by which open point>

## 4. Risks

| Risk | Level | Mitigation |
|---|---|---|

## 5. Out of scope for this ticket

<list, with the ticket that will cover each item>
````

Keep section 0 first and empty. It is the gate.

## Step 7: Write `CheckList.md` when the ticket has none

`b13:ticket-build` ticks `CheckList.md` after every task and `b13:ac-review` audits it, so a
ticket must not reach build with nothing to tick.

- **File already exists** → leave it alone. It is the user's running tick-list; do not rewrite,
  reorder or re-tick it. Only mention in your report if it has drifted from the plan.
- **File missing** → create `<ticket>/CheckList.md` in `output_language`, every box
  **unticked** (`- [ ]`). The plan groups work into phases; the checklist is the finer-grained
  tick-list under those phases: one line per thing a human can verify, not one line per phase.

If other tickets in the project have a `CheckList.md`, match their house format. Otherwise use
lettered sections `## A.`, `## B.`, …, each line a `- [ ]`, citing the AC section the line comes
from.

````markdown
# Checklist: <ticket id>. <ticket title>

> **Branch:** `<branch>` · **Estimate:** <h> · **Due:** <date>
> This checklist follows `AC.md` and `Plan.md` in the same folder.
> <status of open points: all decided / which ones remain open>

---

## A. Before starting

- [ ] Read all of `AC.md`, including the decision log: <all decided / open: ...>
- [ ] **Decision x.y:** <restate the decision so the build does not need to look it up>
- [ ] Update `<base_branch>` and check out the ticket branch

## B…<X>. <one section per phase of `Plan.md`>

- [ ] <verifiable item> (AC 4.x)

## <X+1>. Manual testing (via the API docs / client)

- [ ] <each case: actor → input → expected result>

## <X+2>. Hand-off to consumers (FE / other teams)

- [ ] `Output.md` written in **English**, with endpoints / DTOs / errors / behaviour notes
- [ ] `Output.md` posted where the team expects it (PR comment, ticket tracker)

## <X+3>. Before opening the PR

- [ ] <each configured/detected verify command: lint, typecheck/build, tests>
- [ ] Check the staged files: only source files, no planning docs unless the project tracks them
- [ ] PR targets `<base_branch>` (or whatever the project's hand-off rules require)
````

Two things to get right:

- **Every box unticked.** You are planning, not reporting progress. A pre-ticked line is a lie
  `b13:ticket-build` will inherit.
- **Traceable, same as the plan.** Each line cites its AC section, so `b13:ac-review`
  (AC vs CheckList, Plan vs CheckList) can actually be checked.

## Step 8: Report and stop

Summarise in the chat: phases, how many tasks, what is blocked and by what, whether you created
`CheckList.md` or found one already there, and the one line the user needs to act on (fill in
the build command). Then stop. Do not begin Phase 1.

## Common mistakes

| Mistake | Instead |
|---|---|
| Restating `CheckList.md` line by line | Group into tasks; the checklist stays the detailed tick-list |
| Planning around an unresolved AC point | Surface it, mark what it blocks, leave the task unscheduled |
| Tasks like "implement the API" | Name the file, the base class, and the AC section |
| Inventing behaviour not in the AC | Flag gaps instead; `scope_ceiling_docs` bound the scope |
| Writing `Output.md` in a language other than English | `Output.md` is the English hand-off |
| Starting to code once the plan looks good | Stop at the plan. The build command is the user's call |
| Rewriting or re-ticking an existing `CheckList.md` | Only create it when missing |
| Creating `CheckList.md` with boxes already ticked | Every box `- [ ]`: nothing has been built yet |

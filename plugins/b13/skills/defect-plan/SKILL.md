---
name: defect-plan
description: Investigates a defect reported against an already-built ticket (AC number or ticket id, branch, title, context) and writes a defect file to Defects/<branch>.md inside that ticket's folder with root cause, fix plan and build-command gate. Use when the user reports a bug or defect against a ticket ("fix bug in AC X.Y", a defect report with title/context/branch). Produces a plan only, never code. Companion to b13:defect-build.
---

# Defect Plan

Investigate a defect filed against an existing, already-built ticket and write the result to
`Defects/<branch>.md` inside that ticket's folder. Companion to `b13:defect-build`, which
consumes the file this skill produces. Same division of labour as `b13:ticket-plan` /
`b13:ticket-build`, but for a defect against a ticket that already shipped.

Project conventions (`specs_root`, `base_branch`, `ticket_id_prefix`, `output_language`, ...) are
the optional `## b13` section in the project's `CLAUDE.md` / `AGENTS.md` described in
`b13:ticket-plan`, with the same defaults.

## Hard rule: this skill never writes code

The defect file *is* the deliverable. Do not create or modify source code. Implementation starts
only after the user runs the build command, which they fill into section 0 of the file this
skill produces (or by invoking `b13:defect-build`).

Allowed: reading anything, read-only investigation (including spawning read-only Explore/fork
agents), creating the ticket's `Defects/` folder, and writing `Defects/<branch>.md`. Also
allowed: `git checkout -b <branch> <base_branch>` (or checking the branch out if it already
exists). That is purely local and reversible.

## Inputs

This skill is invoked with four pieces of information, as explicit arguments or as a freeform
block the user pastes (for example a defect block with `title` / `context` / `branch` lines,
possibly naming the ticket). Parse leniently. If any of the four is genuinely missing (not just
informally phrased), ask rather than guessing:

| Input | What it is | Used for |
|---|---|---|
| AC number / ticket id | The ticket this defect is against, e.g. `2.1.4` | Resolving the ticket folder (Step 1) |
| Branch | The branch for the fix (with `ticket_id_prefix` if the project uses one) | The defect file's name, and the branch to check out |
| Title | Short one-line description of the defect/scenario | File header |
| Context | The observed behaviour / repro note the reporter gave | §1 reporting context, seeds the root-cause investigation |

## Step 1: Resolve the ticket, exactly like `b13:ticket-plan`

```
<specs_root>/.../<ticket>/
  AC.md  CheckList.md  Plan.md  Output.md  Review.md?
  Defects/
    <branch>.md      # one file per defect, named by branch
```

Resolve the ticket id the same way `b13:ticket-plan` does: search the ticket folders for the one
whose name or `AC.md` contains that id. A bare id can exist in more than one folder group, so
search all of them and ask if more than one matches. Never guess between tickets.

Below, `<ticket>` is the resolved ticket folder.

## Step 2: Set up the branch and the defect file

1. `git status`. If the working tree is dirty, stop and ask before switching branches.
2. Check whether `<branch>` already exists locally or on the remote (`git branch --list`,
   `git ls-remote --heads origin`). If it does not, create it from an up-to-date `<base_branch>`
   (`git checkout -b <branch> <base_branch>`). If it does, `git checkout <branch>`; do not
   recreate it.
3. `mkdir -p <ticket>/Defects` if it does not already exist.
4. If `<ticket>/Defects/<branch>.md` **already exists**, this is a continuation of a
   previously planned defect. Read it first and ask the user whether they want it revised or
   whether this is actually a different defect that needs a different branch name. Do not
   silently overwrite an existing defect file.

## Step 3: Read the ticket's existing context first

Before investigating the defect itself, read `<ticket>/AC.md`, `CheckList.md`, `Plan.md`,
`Output.md`, and `Review.md` if present, plus the project's `handoff_rules_file`, any
`scope_ceiling_docs`, and its `CLAUDE.md` / `AGENTS.md`. The decisions marked `✅ DECIDED` in
`AC.md` are load-bearing. A defect fix must not silently reopen or contradict one. If the fix
you are about to propose would touch a decided point, say so explicitly in the defect file (see
the template's "Impact on decided points" section) rather than quietly overriding it.

## Step 4: Investigate the root cause

Read the actual code the ticket built (find it via the DTOs/services/controllers `AC.md` or
`Output.md` name, or `rg` for the domain). Prefer forking a read-only investigation (or using
the `Explore` agent) when the trail spans several files, so raw tool output does not fill the
main conversation. Always personally verify the conclusion against the actual files before
writing it down; do not take an agent's summary as ground truth without spot checks on the cited
lines.

Follow the evidence, not the assumption in the report. The reported context is a symptom, not
necessarily the mechanism. Trace the real data flow (which service writes what, which
service/DTO reads what) until you can name the specific line(s) responsible.

## Step 5: Write `Defects/<branch>.md`

Use `output_language` (default: the language of the ticket's own `AC.md`), except the final FE
hand-off section, which is always English (same rule as `Output.md`).

Template (translate the headings into `output_language`):

````markdown
# Defect: <ticket id>. <ticket title>

> **Branch:** `<branch>`
> **Ticket:** <ticket id> (`<path to ticket folder>`)
> **Title:** <title as given>
> **Context:** <context as given>
> ⚠️ **Write no code until the user sets the build command in section 0.**

---

## 0. Build command

> The user fills this in. No value means **no code may be written yet**.

```
(not set)
```

---

## 1. Root cause

<the actual mechanism, cited by file:line, tracing the real request/data flow, not a
restatement of the reported symptom>

---

## 2. Fix plan

| # | File | Change |
|---|---|---|

<note whether a migration is needed; if not, say so explicitly>

---

## 3. Impact on decided points

<which decisions in AC.md this fix touches, and why it does not silently reopen them, or
"None" if genuinely none>

---

## 4. Manual verification (post-build)

- [ ] <concrete repro step 1>
- [ ] <concrete repro step 2: the original reported scenario, so this is provably fixed>

---

## 5. FE hand-off (English, required once built)

> Filled in by `b13:defect-build` once the fix lands. Not yet built.
````

Keep section 0 first and empty. It is the gate, the same convention as `Plan.md`.

## Step 6: Report and stop

Summarise in chat: the root cause in one or two sentences, what the fix touches, whether it is
additive or risks a decided point, and the one line the user needs to act on (fill in the
build command). Then stop. Do not begin implementing.

## Common mistakes

| Mistake | Instead |
|---|---|
| Root-causing from the reported symptom alone | Trace the actual code path; the symptom may point at the wrong service |
| Silently overriding a `✅ DECIDED` point | Flag it explicitly in §3; propose a fix that does not require reopening it if possible |
| Skipping the branch-exists check | Branches can pre-exist (e.g. a prior partial attempt); check before creating |
| Overwriting an existing `Defects/<branch>.md` | Read it first; ask before rewriting |
| Writing §5 (FE hand-off) in a non-English language | §5 is always English |
| Starting to code once the fix looks obvious | Stop at the plan. The build command is the user's call |

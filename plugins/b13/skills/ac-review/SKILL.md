---
name: ac-review
description: Cross-checks a ticket's AC.md, CheckList.md, Plan.md and Output.md against each other and against the source requirement documents, and reports contradictions, staleness and still-unclear points. Use when asked to review the AC or check a ticket for contradictions, before b13:ticket-plan on a ticket whose AC looks shaky, or periodically on an in-progress ticket to catch drift between its files. Read-only over source code, never writes code.
---

# AC Review

Audit one ticket's documents (`AC.md`, `CheckList.md`, `Plan.md`, `Output.md`) against each
other and against the source requirement documents, and surface every contradiction, staleness
or still-open point. Companion to `b13:ticket-plan` (same ticket-resolution rules); this skill
produces no plan and no code, only a review.

Project conventions (`specs_root`, `output_language`, `scope_ceiling_docs`, ...) are the optional
`## b13` section in the project's `CLAUDE.md` / `AGENTS.md` described in `b13:ticket-plan`,
with the same defaults. Here `scope_ceiling_docs` lists the source requirement documents
(functional overview, backbone/traceability sheet, PRD, ...), as paths to `.md`, `.docx`,
`.xlsx` or `.pdf` files. If none are configured, review the ticket files against each other
only, and say so in the report.

## Hard rule: normative sections vs narrative

Source requirement documents usually mix normative sections (acceptance criteria,
preconditions, trigger, postcondition, error message table) with narrative or description text.
Only the **normative sections** are the implementable spec. Narrative text is **reference-only**:
never implement behaviour that lives only there, and never treat a difference between it and the
normative sections as a blocking contradiction needing a user decision. When the narrative says
something extra or different, note it as FYI in the review (not as an open question, not as
scope) and resolve strictly from the normative sections.

## Hard rule: this skill never writes code

Allowed: reading anything, writing/updating the ticket's `Review.md`, and, only after the user
confirms via `AskUserQuestion`, syncing a genuinely stale marker inside `AC.md` / `CheckList.md`
/ `Plan.md` (for example a decision already `✅ DECIDED` in one section but still shown open in
another). Never touch source code; that requires the build gate, which this skill does not
grant.

## Step 1: Resolve the ticket

Identical resolution order to `b13:ticket-plan`:

```
<specs_root>/.../<ticket>/
  AC.md  CheckList.md  Plan.md  Output.md
```

1. An argument the user passed (ticket id, folder name, path). A bare id can exist in more than
   one folder group; search all and ask if several match.
2. The checked-out branch: `rg -l '<branch>' --glob 'AC.md'`.
3. Otherwise list the most recently modified tickets and ask.

If the user asks to review a whole sprint/milestone/folder, repeat Steps 2-6 per ticket folder
and roll the per-ticket findings into one chat summary at the end; still write one `Review.md`
per ticket.

Below, `<ticket>` is the resolved folder.

## Step 2: Read all four files, plus sources and siblings

| File | Always read | Notes |
|---|---|---|
| `<ticket>/AC.md` | full | its decision-log section is the existing baseline, not the whole truth |
| `<ticket>/CheckList.md` | full | which lines are ticked, which carry ⚠️/🟡 |
| `<ticket>/Plan.md` | full if non-empty | its own "decided / still open" table |
| `<ticket>/Output.md` | full if non-empty | only meaningful once the ticket has been built |
| `scope_ceiling_docs` | the ticket's section/row | source of truth: extract text, do not rely on AC.md's paraphrase of it |
| Backbone / traceability sheet (if among the docs) | the ticket's row | can be stale vs the functional overview: flag disagreement, do not silently prefer either |
| Project `CLAUDE.md` / `AGENTS.md`, `handoff_rules_file` | review context | scope ceiling, hand-off requirement, conventions |
| Other tickets cited as "decided per ticket X, section Y" | that ticket's `AC.md` | verify the cited section actually says what is claimed and is not itself since-superseded |

A `.docx` is not directly greppable. Extract its text first (path as an argument, output to the
system temp directory):

```bash
DOC="path/to/source.docx"
OUT="${TMPDIR:-/tmp}/source_dump.txt"
python3 - "$DOC" "$OUT" <<'PY'
import re, sys, zipfile
doc, out = sys.argv[1], sys.argv[2]
xml = zipfile.ZipFile(doc).read("word/document.xml").decode("utf-8")
xml = re.sub(r"</w:p>", "\n", xml)
xml = re.sub(r"<w:tab/>", "\t", xml)
text = re.sub(r"<[^>]+>", "", xml).replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">")
open(out, "w").write(text)
PY
rg -n '<ticket id>' "$OUT"
```

For `.xlsx`, convert the relevant sheet to CSV (or read it with a spreadsheet tool) and search
for the ticket's row. For `.pdf`, extract text with the available PDF reader.

Note each file's mtime (`ls -la`). A big gap (AC.md edited after Plan.md / CheckList.md) is
itself a signal something downstream is stale; check category I below.

## Step 3: Check categories

Run through all of these; do not stop at the first contradiction found.

| # | Category | What to check |
|---|---|---|
| A | AC internal drift | A point marked resolved in the AC body but the decision-log section still shows it open, or the reverse: the log says resolved but the body still carries the old ambiguous wording |
| B | AC vs source docs | Every sentence in the source's normative sections relevant to this ticket is represented in AC.md; every quote or paraphrase matches the extracted source text; every ambiguity AC.md claims exists is real *within the normative sections*, not sourced from narrative-only text (reference-only, see the rule above) |
| C | AC vs backbone / traceability sheet | The sheet's row for this ticket vs the functional overview: flag disagreement, do not resolve it yourself |
| D | AC vs CheckList | Every ⚠️/🟡 point in the AC that affects a specific checklist line has that line flagged too; no checklist line is ticked `[x]` while depending on a still-open AC point |
| E | AC vs Plan | Plan's own "decided / still open" table matches the AC's current state; no *scheduled* (non-blocked) Plan task secretly depends on an AC point still marked open |
| F | Plan vs CheckList | Task breakdown in Plan and the tick-list in CheckList cover the same ground: no task with no matching checklist line, no checklist section with no matching plan task |
| G | AC/Plan vs Output | If `Output.md` has content: its endpoints/DTOs/error strings match the AC's message and contract sections exactly (no invented wording); any AC decision dated after `Output.md` was written is reflected there too |
| H | Cross-ticket citations | Any "decided per ticket X, section Y" claim: open ticket X's `AC.md`, confirm section Y still says that (not since revised) |
| I | File staleness | mtime ordering. If `AC.md` is newer than `Plan.md` / `CheckList.md`, treat it as a signal to double-check D/E/F, not as a finding on its own |

For each finding, classify:
- **Contradiction**: two files (or two sections of one file) assert different things.
- **Unclear / unconfirmed**: genuinely underspecified in the source, still open, no decision recorded anywhere.
- **Stale**: a decision exists but one document has not caught up to it.

Never invent an ambiguity that is not there. A category with nothing wrong is reported as clean,
not padded.

## Step 4: Write `Review.md`

Write to `<ticket>/Review.md` in `output_language` (default: the language of `AC.md`).

Template (translate the headings into `output_language`):

````markdown
# Review: <ticket id>. <ticket title>

> Reviewed `AC.md` / `CheckList.md` / `Plan.md` / `Output.md` in the same folder against the source documents.
> Reviewed on: <date>. Newest file in the group: <file name, mtime>.

---

## 1. Contradictions (two sources say different things)

| # | Between | Content | Source A | Source B |
|---|---|---|---|---|
| 1 | AC §4.x vs AC decision log | ... | quote + line | quote + line |

## 2. Stale (decided in one place, not updated elsewhere)

| # | Decided in | Content | Not yet updated in |
|---|---|---|---|

## 3. Unclear / unconfirmed (source genuinely lacks it, no decision yet)

| # | Point | Why the source is not enough | What it blocks (schema/API/one query/nothing) |
|---|---|---|---|

## 4. Clean (checked, nothing found)

<short list of Step 3 categories with no findings, so coverage is visible>

## 5. Recommended actions

- Needs the user's decision now: ...
- Can be synced directly (decided elsewhere, only needs copying over): ... → ask the user first.
````

## Step 5: Offer to sync stale markers, ask first

For every **Stale** finding (categories A/E with a clear resolution already on record
elsewhere), propose the exact edit and use `AskUserQuestion` before touching `AC.md` /
`CheckList.md` / `Plan.md`. Editing these planning files does not need the build gate, but do it
per item, confirmed. Never a bulk silent rewrite.

For genuine **Contradiction** or **Unclear** findings that need a business call (not just doc
sync), surface them and, where the finding maps to a concrete either/or choice, ask via
`AskUserQuestion` rather than guessing, same as any other open AC point.

## Step 6: Report and stop

Chat summary: counts per category (contradictions / stale / unclear / clean), the items synced
this run, and the items still needing the user's call. Point at `Review.md` for the full
detail. Do not proceed to `b13:ticket-plan` or `b13:ticket-build` unless asked.

## Common mistakes

| Mistake | Instead |
|---|---|
| Trusting AC.md's own decision log as complete | Re-derive against the source text directly; the log itself can be stale |
| Reporting a decision-log item as still open when another section already resolved it | Check the whole file, not just the log |
| Silently editing AC.md / CheckList.md / Plan.md | Propose the exact diff, confirm via `AskUserQuestion`, then edit |
| Padding the report with non-findings to look thorough | Section 4 (Clean) exists so "nothing wrong here" is a legitimate, visible outcome |
| Treating a backbone-vs-overview disagreement as something to resolve | Flag it per the project's scope rules; still surface the conflict |
| Skipping the cross-ticket citation check | A "decided per ticket X" claim is itself a claim; verify it |
| Flagging narrative-vs-normative differences as a blocking contradiction | Narrative is reference-only; resolve from the normative sections, note the difference as FYI only |

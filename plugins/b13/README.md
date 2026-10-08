# b13

Ticket workflow skills, invoked as `b13:<skill>`. Project-agnostic.

| Skill | Purpose |
|---|---|
| `b13:ac-review` | Cross-check `AC.md`, `CheckList.md`, `Plan.md`, `Output.md` against each other and source docs. Writes `Review.md`. |
| `b13:ticket-plan` | `AC.md` -> `Plan.md` (+ `CheckList.md` if missing). Plans only. |
| `b13:ticket-build` | Execute `Plan.md`, tick `CheckList.md`, write English `Output.md`. Invoking it is the build command. |
| `b13:defect-plan` | Investigate a defect on a built ticket -> `Defects/<branch>.md`. Plans only. |
| `b13:defect-build` | Implement the fix from `Defects/<branch>.md`. Invoking it is the build command. |

Pipeline: `ac-review` (optional) -> `ticket-plan` -> `ticket-build` -> `defect-plan` -> `defect-build`.

## Optional project config

Add a `## b13` section to the project's `CLAUDE.md` or `AGENTS.md`:

```markdown
## b13
- specs_root: specs/
- ticket_dir: specs/<ticket>/
- base_branch: main
- ticket_id_prefix: PROJ-
- output_language: English
- verify_commands: npm run lint; npm run typecheck; npm test
- scope_ceiling_docs: docs/functional-overview.docx
- handoff_rules_file: specs/rules.md
```

Every key is optional. Defaults are detected from the repo (see `skills/ticket-plan/SKILL.md`).

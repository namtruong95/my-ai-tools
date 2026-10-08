---
description: Start spec-driven development — write user stories and acceptance criteria (in Vietnamese) to specs/ before writing code
---

Invoke the lisa:spec-driven-development skill.

## Fixed rules (never override)

- **Always Vietnamese.** Ask clarifying questions, write `specs/user-story.md`, `specs/acceptance-criteria.md` and the chat summary in Vietnamese so the user can review them, whatever language the request, the arguments or the conversation use. Code, file paths, identifiers, commands and quoted error strings stay verbatim.
- **Never run plannotator.** Do not call `/plannotator`, `/plannotator-annotate`, `/plannotator-last` or the `plannotator` tool, and do not offer them.
- **Fixed output files.** Never write `SPEC.md` or any other location. Resolve the repo root with `git rev-parse --show-toplevel` (fall back to the current directory), create `<repo-root>/specs/` if missing, and write exactly:

```
<repo-root>/specs/user-story.md
<repo-root>/specs/acceptance-criteria.md
```

- `user-story.md`: objective, target users, and the user stories (each with an id `US1`, `US2`, ...).
- `acceptance-criteria.md`: acceptance criteria per story id, plus commands, project structure, code style, testing strategy and boundaries (always do / ask first / never do), so all six core areas of the skill are covered.
- If either file already exists, stop and ask whether to revise it or abort. Never silently overwrite.

## Steps

Begin by understanding what the user wants to build. Ask clarifying questions about:
1. The objective and target users
2. Core features and acceptance criteria
3. Tech stack preferences and constraints
4. Known boundaries (what to always do, ask first about, and never do)

Then generate the structured spec covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries, split across the two files above.

If the request bundles several independently testable capabilities, first propose a capability map (module ids, dependency direction, build order) per the skill's Phase 0 and get it approved, then spec each module in dependency order.

Report the two file paths in Vietnamese and confirm with the user before proceeding. Next step is `/lisa:plan <title>`.

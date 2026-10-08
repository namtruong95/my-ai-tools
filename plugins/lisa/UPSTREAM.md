# Upstream

- Source: https://github.com/addyosmani/agent-skills (MIT, see LICENSE)
- Pinned commit: `1401c8b8030e023baeebb31781a6653fe8e93026`
- Upstream version: 0.6.12
- Vendored: skills/, agents/, references/, commands/ (from .claude/commands), docs/agents.md (linked from agents/), hooks/ (scripts + docs, no tests; lisa adds hooks/hooks.json registering sdd-cache and simplify-ignore, not session-start; TOML commands, evals are not included)
- Local overrides (scripts/lisa-overrides/, copied after vendoring): commands/plan.md and commands/build.md (plan output in specs/tasks/<title>/{Plan,Todo}.md; build only runs an existing plan).\n- Rewrites applied by scripts/sync-lisa.sh: `agent-skills:` -> `lisa:`, `/spec` -> `/lisa:spec` (all commands), ship.md subagent names -> `lisa:<name>`

## Local patches

None yet. List every hand edit here so the next sync can be reviewed against it.

## Known gaps

- Skills (planning-and-task-breakdown, spec-driven-development) still say `tasks/plan.md`; the overridden /lisa:plan and /lisa:build take precedence.
- Upstream hooks (session-start, sdd-cache, simplify-ignore) are opt-in via settings.json and are
  not vendored.
- `using-agent-skills` lists sibling skills without the `lisa:` prefix.

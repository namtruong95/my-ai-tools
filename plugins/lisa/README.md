# lisa

Skills invoked as `lisa:<skill>`, vendored from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (MIT).

- `skills/`: 25 lifecycle skills (spec, plan, build, test, review, ship, ...)
- `agents/`: `code-reviewer`, `security-auditor`, `test-engineer`, `web-performance-auditor`
- `references/`: checklists the skills link to (relative paths, keep the layout)
- `commands/`: `/lisa:spec`, `/lisa:plan`, `/lisa:build [auto]`, `/lisa:test`, `/lisa:review`,
  `/lisa:code-simplify`, `/lisa:constraints`, `/lisa:webperf`, `/lisa:ship` (from upstream `.claude/commands`)
  - `/lisa:plan <title>` (local override): writes `specs/tasks/<title>/Plan.md` + `Todo.md` in the current repo, never builds.
  - `/lisa:build <title> [auto]` (local override): the only way to start building; requires that plan to exist.
  - Overrides live in `scripts/lisa-overrides/` and are re-applied by every sync.

- `hooks/`: scripts + docs, registered by `hooks/hooks.json` (lisa's own file, written by the sync script):
  - `sdd-cache` (`WebFetch` pre/post): caches fetched docs in `.claude/sdd-cache/`, revalidated with ETag/Last-Modified.
  - `simplify-ignore` (`Read`, `Edit|Write`, `Stop`): hides `simplify-ignore-start/end` blocks from the model. It edits
    files on disk during the session; after a crash run `echo '{}' | bash hooks/simplify-ignore.sh` (see `SIMPLIFY-IGNORE.md`).
  - Add `.claude/sdd-cache/` and `.claude/.simplify-ignore-cache/` to the project's `.gitignore`. Needs `jq`, `shasum`/`sha1sum`.
  - `session-start.sh` is vendored but not registered (duplicates Claude Code's native skill routing).
- `docs/agents.md`: linked from the agent files.

Not included from upstream: `commands/*.toml` (Gemini format), `evals/`, other `docs/`, hook tests.

Same-named skills from other plugins stay separate thanks to the `lisa:` namespace.

## Update or customize

- Re-sync from upstream: `scripts/sync-lisa.sh [--dry-run] [<git-ref>]` (overwrites `skills/`, `agents/`, `references/`).
- Hand edits get overwritten by a sync. Record each one in `UPSTREAM.md` under "Local patches" and re-apply after syncing.

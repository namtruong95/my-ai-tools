#!/usr/bin/env bash
# Vendor addyosmani/agent-skills (MIT) into plugins/lisa as the `lisa` plugin.
#
# Copies skills/, agents/, references/ and the Claude slash commands
# (.claude/commands -> commands/) docs/agents.md and hooks/ (minus *-test.sh) verbatim, rewrites the upstream `agent-skills:`
# prefix to `lisa:` (plus slash-command and subagent references), and records the
# pinned commit in plugins/lisa/UPSTREAM.md. Hooks, TOML commands and evals are
# not vendored.
#
# Usage:
#   scripts/sync-lisa.sh [--dry-run] [<git-ref>]   # default ref: main

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/plugins/lisa"
UPSTREAM_URL="https://github.com/addyosmani/agent-skills.git"
VENDORED_DIRS=(skills agents references)

DRY_RUN=false
REF="main"
for arg in "$@"; do
	case "$arg" in
	--dry-run) DRY_RUN=true ;;
	-h | --help)
		sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*) REF="$arg" ;;
	esac
done

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Fetching $UPSTREAM_URL @ $REF"
git clone --quiet --depth 1 --branch "$REF" "$UPSTREAM_URL" "$TMP_DIR/upstream" 2>/dev/null ||
	{
		git clone --quiet "$UPSTREAM_URL" "$TMP_DIR/upstream"
		git -C "$TMP_DIR/upstream" checkout --quiet "$REF"
	}
SHA="$(git -C "$TMP_DIR/upstream" rev-parse HEAD)"
VERSION="$(jq -r '.version // "unknown"' "$TMP_DIR/upstream/plugin.json")"

if [ "$DRY_RUN" = true ]; then
	echo "[dry-run] would vendor ${VENDORED_DIRS[*]} from $SHA (upstream v$VERSION) into $PLUGIN_DIR"
	exit 0
fi

mkdir -p "$PLUGIN_DIR"
for dir in "${VENDORED_DIRS[@]}"; do
	rm -rf "${PLUGIN_DIR:?}/$dir"
	cp -R "$TMP_DIR/upstream/$dir" "$PLUGIN_DIR/$dir"
done
rm -rf "${PLUGIN_DIR:?}/commands"
cp -R "$TMP_DIR/upstream/.claude/commands" "$PLUGIN_DIR/commands"
# Hook scripts are vendored verbatim; hooks/hooks.json below is lisa's own registration.
rm -rf "${PLUGIN_DIR:?}/hooks"
mkdir -p "$PLUGIN_DIR/hooks"
find "$TMP_DIR/upstream/hooks" -maxdepth 1 -type f ! -name '*-test.sh' -exec cp -p {} "$PLUGIN_DIR/hooks/" \;
cat >"$PLUGIN_DIR/hooks/hooks.json" <<'JSON'
{
	"hooks": {
		"PreToolUse": [
			{
				"matcher": "WebFetch",
				"hooks": [{ "type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/sdd-cache-pre.sh\"", "timeout": 10 }]
			},
			{
				"matcher": "Read",
				"hooks": [{ "type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/simplify-ignore.sh\"" }]
			}
		],
		"PostToolUse": [
			{
				"matcher": "WebFetch",
				"hooks": [
					{ "type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/sdd-cache-post.sh\"", "async": true, "timeout": 10 }
				]
			},
			{
				"matcher": "Edit|Write",
				"hooks": [{ "type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/simplify-ignore.sh\"" }]
			}
		],
		"Stop": [
			{
				"hooks": [{ "type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/simplify-ignore.sh\"" }]
			}
		]
	}
}
JSON
mkdir -p "$PLUGIN_DIR/docs"
cp "$TMP_DIR/upstream/docs/agents.md" "$PLUGIN_DIR/docs/agents.md"
cp "$TMP_DIR/upstream/LICENSE" "$PLUGIN_DIR/LICENSE"

# Namespace rewrite: upstream cross-references use `agent-skills:<skill>`.
find "$PLUGIN_DIR" -type f -name '*.md' -exec sed -i.bak 's/agent-skills:/lisa:/g' {} +
find "$PLUGIN_DIR" -type f -name '*.bak' -delete

# Local overrides (scripts/lisa-overrides/**) replace upstream files after vendoring.
if [ -d "$REPO_ROOT/scripts/lisa-overrides" ]; then
	cp -R "$REPO_ROOT/scripts/lisa-overrides/." "$PLUGIN_DIR/"
fi

# Plugin commands are namespaced: /spec -> /lisa:spec (idempotent, leaves /lisa:spec alone).
find "$PLUGIN_DIR" -type f -name '*.md' ! -name UPSTREAM.md ! -name README.md -exec \
	perl -pi -e 's{(^|[\s`(])/(spec|build|test|plan|review|ship|code-simplify|constraints|webperf)\b}{$1/lisa:$2}g' {} +
# Plugin subagents resolve as lisa:<name>, so /lisa:ship must spawn those.
perl -pi -e 's{^(\d\. \*\*`)(code-reviewer|security-auditor|test-engineer)(`\*\*)}{$1lisa:$2$3}' "$PLUGIN_DIR/commands/ship.md"

cat >"$PLUGIN_DIR/UPSTREAM.md" <<DOC
# Upstream

- Source: https://github.com/addyosmani/agent-skills (MIT, see LICENSE)
- Pinned commit: \`$SHA\`
- Upstream version: $VERSION
- Vendored: skills/, agents/, references/, commands/ (from .claude/commands), docs/agents.md (linked from agents/), hooks/ (scripts + docs, no tests; lisa adds hooks/hooks.json registering sdd-cache and simplify-ignore, not session-start; TOML commands, evals are not included)
- Local overrides (scripts/lisa-overrides/, copied after vendoring): commands/plan.md and commands/build.md (plan output in specs/tasks/<title>/{Plan,Todo}.md; build only runs an existing plan).\n- Rewrites applied by scripts/sync-lisa.sh: \`agent-skills:\` -> \`lisa:\`, \`/spec\` -> \`/lisa:spec\` (all commands), ship.md subagent names -> \`lisa:<name>\`

## Local patches

None yet. List every hand edit here so the next sync can be reviewed against it.

## Known gaps

- Skills (planning-and-task-breakdown, spec-driven-development) still say \`tasks/plan.md\`; the overridden /lisa:plan and /lisa:build take precedence.
- Upstream hooks (session-start, sdd-cache, simplify-ignore) are opt-in via settings.json and are
  not vendored.
- \`using-agent-skills\` lists sibling skills without the \`lisa:\` prefix.
DOC

echo "Synced to $SHA (v$VERSION). Review with: git diff --stat -- plugins/lisa"

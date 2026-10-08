#!/usr/bin/env bats

setup() {
	REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	PLUGIN_ROOT="$REPO_ROOT/plugins/lisa"
}

@test "lisa plugin manifest is valid and named lisa" {
	run jq -r '.name' "$PLUGIN_ROOT/.claude-plugin/plugin.json"
	[ "$status" -eq 0 ]
	[ "$output" = "lisa" ]
}

@test "lisa plugin is registered once in the marketplace" {
	run jq -r '[.plugins[] | select(.name == "lisa")] | length' "$REPO_ROOT/.claude-plugin/marketplace.json"
	[ "$output" = "1" ]
	run jq -r '.plugins[] | select(.name == "lisa") | .source' "$REPO_ROOT/.claude-plugin/marketplace.json"
	[ "$output" = "./plugins/lisa" ]
}

@test "lisa keeps the upstream MIT license and pinned commit" {
	[ -f "$PLUGIN_ROOT/LICENSE" ]
	run grep -c 'MIT License' "$PLUGIN_ROOT/LICENSE"
	[ "$output" = "1" ]
	run grep -E 'Pinned commit: `[0-9a-f]{40}`' "$PLUGIN_ROOT/UPSTREAM.md"
	[ "$status" -eq 0 ]
}

@test "every lisa skill has SKILL.md whose name matches its directory" {
	count=0
	for dir in "$PLUGIN_ROOT"/skills/*/; do
		name="$(basename "$dir")"
		[ -f "$dir/SKILL.md" ]
		run sed -n '2p' "$dir/SKILL.md"
		[ "$output" = "name: $name" ]
		count=$((count + 1))
	done
	[ "$count" -ge 20 ]
}

@test "lisa ships the agents and references skills link to" {
	for f in agents/code-reviewer.md agents/security-auditor.md agents/test-engineer.md \
		references/security-checklist.md references/definition-of-done.md docs/agents.md; do
		[ -f "$PLUGIN_ROOT/$f" ]
	done
}

@test "lisa ships the nine slash commands, namespaced" {
	for c in spec plan build test review code-simplify constraints webperf ship; do
		[ -f "$PLUGIN_ROOT/commands/$c.md" ]
	done
	run grep -rnE '(^|[[:space:]`(])/(spec|build|test|plan|review|ship|code-simplify|constraints|webperf)\b' "$PLUGIN_ROOT/commands" "$PLUGIN_ROOT/skills"
	[ "$status" -eq 1 ]
	run grep -c 'lisa:code-reviewer' "$PLUGIN_ROOT/commands/ship.md"
	[ "$output" -ge 1 ]
}

@test "lisa registers sdd-cache and simplify-ignore hooks but not session-start" {
	for h in sdd-cache-pre.sh sdd-cache-post.sh simplify-ignore.sh session-start.sh; do
		[ -x "$PLUGIN_ROOT/hooks/$h" ]
	done
	run jq -e '.hooks.PreToolUse and .hooks.PostToolUse and .hooks.Stop' "$PLUGIN_ROOT/hooks/hooks.json"
	[ "$status" -eq 0 ]
	run jq -r '[.. | .command? // empty] | .[]' "$PLUGIN_ROOT/hooks/hooks.json"
	[[ "$output" == *'${CLAUDE_PLUGIN_ROOT}/hooks/sdd-cache-pre.sh'* ]]
	[[ "$output" == *'${CLAUDE_PLUGIN_ROOT}/hooks/simplify-ignore.sh'* ]]
	[[ "$output" != *session-start* ]]
	for cmd in $(jq -r '[.. | .command? // empty] | .[]' "$PLUGIN_ROOT/hooks/hooks.json" | sed -E 's/.*hooks\/([a-z.-]+)\\?".*/\1/'); do
		[ -f "$PLUGIN_ROOT/hooks/$cmd" ]
	done
}

@test "lisa:plan writes specs/tasks/<title>/Plan.md + Todo.md and never builds" {
	run grep -c 'specs/tasks/<title>/Plan.md' "$PLUGIN_ROOT/commands/plan.md"
	[ "$output" -ge 1 ]
	run grep -c 'specs/tasks/<title>/Todo.md' "$PLUGIN_ROOT/commands/plan.md"
	[ "$output" -ge 1 ]
	run grep -c '/lisa:build' "$PLUGIN_ROOT/commands/plan.md"
	[ "$output" -ge 1 ]
}

@test "lisa:build requires an existing plan and does not plan itself" {
	run grep -c 'specs/tasks/' "$PLUGIN_ROOT/commands/build.md"
	[ "$output" -ge 1 ]
	run grep -nE 'tasks/(plan|todo)\.md|generate the plan|Plan if needed' "$PLUGIN_ROOT/commands/build.md"
	[ "$status" -eq 1 ]
}

@test "lisa has no leftover agent-skills namespace prefix" {
	run grep -rn 'agent-skills:' "$PLUGIN_ROOT/skills" "$PLUGIN_ROOT/agents" "$PLUGIN_ROOT/references" "$PLUGIN_ROOT/commands"
	[ "$status" -eq 1 ]
}

@test "relative reference links in lisa skills resolve" {
	missing=0
	while IFS= read -r hit; do
		file="${hit%%:*}"
		target="$(printf '%s' "${hit#*:}" | sed -E 's/.*\]\(([^)#]*).*/\1/')"
		[ -e "$(dirname "$file")/$target" ] || { echo "missing: $file -> $target"; missing=1; }
	done < <(grep -rnoE '\]\((\.\./)+references/[A-Za-z0-9._-]+\.md' "$PLUGIN_ROOT/skills" | sed -E 's/^([^:]+):[0-9]+:/\1:/')
	[ "$missing" -eq 0 ]
}

@test "cli.sh installs lisa from the local marketplace and does not treat it as a remote skill" {
	run grep -F '"lisa|lisa@my-ai-tools|$SCRIPT_DIR|claude"' "$REPO_ROOT/cli.sh"
	[ "$status" -eq 0 ]
	run bash -c "sed -n '/^is_remote_skill()/,/^}/p' '$REPO_ROOT/cli.sh' | grep -qw lisa"
	[ "$status" -ne 0 ]
}

@test "sync-lisa.sh passes a syntax check" {
	run bash -n "$REPO_ROOT/scripts/sync-lisa.sh"
	[ "$status" -eq 0 ]
}

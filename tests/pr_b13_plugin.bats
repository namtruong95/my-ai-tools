#!/usr/bin/env bats

setup() {
	REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	PLUGIN_ROOT="$REPO_ROOT/plugins/b13"
	SKILLS="ticket-plan ticket-build defect-plan defect-build ac-review"
}

@test "b13 plugin manifest is valid and named b13" {
	run jq -r '.name' "$PLUGIN_ROOT/.claude-plugin/plugin.json"
	[ "$status" -eq 0 ]
	[ "$output" = "b13" ]
}

@test "b13 plugin is registered once in the marketplace" {
	run jq -r '[.plugins[] | select(.name == "b13")] | length' "$REPO_ROOT/.claude-plugin/marketplace.json"
	[ "$output" = "1" ]
	run jq -r '.plugins[] | select(.name == "b13") | .source' "$REPO_ROOT/.claude-plugin/marketplace.json"
	[ "$output" = "./plugins/b13" ]
}

@test "b13 ships all five skills with matching frontmatter names" {
	for s in $SKILLS; do
		[ -f "$PLUGIN_ROOT/skills/$s/SKILL.md" ]
		run sed -n '2p' "$PLUGIN_ROOT/skills/$s/SKILL.md"
		[ "$output" = "name: $s" ]
	done
}

@test "b13 skills contain no project-specific leftovers" {
	run grep -rniE 'rail academy|CU-|clickup|nestjs|typeorm|RolesGuard|sonarqube|backbone - phase|6\.1\.3|sprint-<N>|develop\b' "$PLUGIN_ROOT/skills"
	[ "$status" -eq 1 ]
}

@test "b13 skills contain no Vietnamese text" {
	run grep -rnE '[ăâđêôơưáàảãạéèẻẽẹíìỉĩịóòỏõọúùủũụýỳỷỹỵ]' "$PLUGIN_ROOT"
	[ "$status" -eq 1 ]
}

@test "b13 cross-references use the b13 prefix" {
	run bash -c "grep -rnE '\`(ticket-plan|ticket-build|defect-plan|defect-build|ac-review)' '$PLUGIN_ROOT/skills' --include=SKILL.md | grep -v 'b13:'"
	[ "$status" -eq 1 ]
}

@test "cli.sh installs b13 from the local marketplace" {
	run grep -F '"b13|b13@my-ai-tools|$SCRIPT_DIR|claude"' "$REPO_ROOT/cli.sh"
	[ "$status" -eq 0 ]
	run bash -c "sed -n '/^is_remote_skill()/,/^}/p' '$REPO_ROOT/cli.sh' | grep -qw b13"
	[ "$status" -ne 0 ]
}

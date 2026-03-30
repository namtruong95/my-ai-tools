# Testing Strategy

**Analysis Date:** 2026-03-30

## Testing Approach

**Philosophy:** Shell scripts are tested through validation, dry-runs, and linting rather than traditional unit tests.

**Primary Methods:**
1. Static analysis (shellcheck)
2. Syntax validation (bash -n)
3. Dry-run execution (--dry-run flag)
4. Manual testing with --dry-run first
5. Pre-commit hooks for automated checks

## Test Framework

**Static Analysis:**
- **Shellcheck** - Comprehensive shell script linter
  - Checks for quoting issues, unused variables, unsafe patterns
  - Current quality score: 98/100
  - Only 2 info-level issues remain (both expected SC1091)

**Syntax Validation:**
```bash
# Check single script
bash -n cli.sh

# Check multiple scripts
bash -n cli.sh generate.sh

# Check with library
bash -n cli.sh generate.sh lib/common.sh
```

**Manual Testing:**
```bash
# Always use dry-run first
./cli.sh --dry-run

# Test non-interactive mode
echo "y" | ./cli.sh

# Test with backup
./cli.sh --backup --dry-run
```

## Test Structure

**Pre-commit Hooks:**
- `trailing-whitespace` - Remove trailing spaces
- `end-of-file-fixer` - Ensure newline at EOF
- `check-yaml` - Validate YAML syntax
- `check-added-large-files` - Prevent large file commits

**Configuration:** `.pre-commit-config.yaml`

## Test Coverage Areas

**Syntax Coverage:**
- All shell scripts pass `bash -n`
- All shell scripts pass shellcheck with quality score ≥98
- No shellcheck warnings (0 warnings)
- No shellcheck errors (0 errors)

**Functional Coverage:**
- `--dry-run` mode tests all execution paths without side effects
- All install functions tested via dry-run
- All copy operations tested via dry-run
- All plugin installations tested via dry-run

**Platform Coverage:**
- macOS (primary development platform)
- Linux (CI/GitHub Actions)
- Windows Git Bash (supported)

## Mocking

**Dry-Run Mode:**
- `DRY_RUN=true` environment variable
- `execute()` function checks DRY_RUN before executing
- All destructive operations wrapped in `execute()`
- Safe testing without system modifications

**Example:**
```bash
execute() {
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] $1"
    else
        eval "$1"
    fi
}
```

## Validation Patterns

**Prerequisite Validation:**
```bash
check_prerequisites() {
    if ! command -v git &>/dev/null; then
        log_error "Git is not installed"
        exit 1
    fi
}
```

**JSON Validation:**
```bash
validate_json() {
    if command -v jq &>/dev/null; then
        jq empty "$1" 2>/dev/null || log_warning "Invalid JSON: $1"
    fi
}
```

**File Existence:**
```bash
if [ -f "$file" ]; then
    # proceed
else
    log_warning "File not found: $file"
fi
```

## CI/CD Testing

**GitHub Actions:**
- Pre-commit hooks run on every PR
- Shellcheck validation
- Syntax checks
- No automated functional tests (requires environment setup)

**Manual Testing Checklist:**
1. Run `bash -n` on all modified scripts
2. Run shellcheck on all modified scripts
3. Test with `./cli.sh --dry-run`
4. Test with `./generate.sh --dry-run`
5. Verify no breaking changes to CLI interface

## Coverage Gaps

**Untested Areas:**
- Actual tool installation (requires network, tool downloads)
- MCP server setup (requires Claude Code CLI)
- Plugin installation (requires marketplace access)
- Config file copying (side effects in home directory)

**Mitigation:**
- Dry-run mode covers all logic paths
- Extensive shellcheck validation
- Manual testing before releases
- Community feedback for edge cases

## Best Practices

**Before Committing:**
```bash
# Syntax check
bash -n cli.sh generate.sh lib/common.sh

# Shellcheck
shellcheck cli.sh generate.sh lib/common.sh

# Dry run test
./cli.sh --dry-run 2>&1 | head -50
```

**Release Testing:**
- Test on fresh environment
- Test with and without --backup
- Test interactive and non-interactive modes
- Verify all AI tools are correctly referenced

---

*Testing analysis: 2026-03-30*

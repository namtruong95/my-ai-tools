# Coding Conventions

**Analysis Date:** 2026-03-30

## Naming Patterns

**Files:**
- Shell scripts: `lowercase.sh` (e.g., `cli.sh`, `generate.sh`)
- Libraries: `common.sh`, descriptive names
- Markdown: `lowercase-with-hyphens.md`
- Directories: `lowercase` (e.g., `lib/`, `configs/`, `skills/`)

**Functions:**
- Public API: `lowercase_with_underscores()` (e.g., `install_claude_code()`)
- Private/internal: `_leading_underscore()` (e.g., `_run_tool_install()`)
- Constants: `UPPERCASE_WITH_UNDERSCORES` (e.g., `RED`, `GREEN`)

**Variables:**
- Local variables: `lowercase_with_underscores`
- Global/exported: `UPPERCASE` (e.g., `SCRIPT_DIR`, `DRY_RUN`)
- Environment: Preserve system conventions

## Code Style

**Shell Script Standards:**
- Shebang: `#!/bin/bash` (POSIX-compliant, not `#!/bin/sh`)
- Error handling: `set -e` at script top
- Variable quoting: Always quote `"$variable"`, never unquoted
- No absolute paths: Use `$HOME` and relative paths

**Formatting:**
- Indentation: Tabs (not spaces)
- Line length: No strict limit, but keep readable
- Blank lines: Between logical sections
- Comments: Explain why, not what

**Linting:**
- **Shellcheck** - Primary linter for shell scripts
- **Pre-commit hooks** - Trailing whitespace, EOF fixer, YAML check
- Quality score: 98/100 (all warnings fixed)

## Import Organization

**Shell Script Structure:**
1. Shebang and `set -e`
2. Variable declarations (SCRIPT_DIR, DRY_RUN, etc.)
3. Source libraries: `source "$SCRIPT_DIR/lib/common.sh"`
4. Function definitions
5. Main execution (at bottom)

**Library Dependencies:**
- Source order: common.sh first, then tool-specific
- Guard against double-sourcing not needed (simple scripts)
- All functions use `local` for scoped variables

## Error Handling

**Patterns:**
- Fail-fast: `set -e` exits on any error
- Guard clauses: Check prerequisites first
```bash
if ! command -v git &>/dev/null; then
    log_error "Git is not installed"
    exit 1
fi
```
- Optional operations: `|| true` to prevent exit
- Error capture: Temp files for command output analysis

**Error Propagation:**
- Functions return exit codes (0 = success)
- `log_error()` outputs to stderr
- Cleanup on exit via trap in common.sh

## Logging

**Framework:** Custom color-coded functions

**Patterns:**
```bash
log_info()   { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()  { echo -e "${RED}[ERROR]${NC} $1" >&2; }
```

**Usage:**
- `log_info` - Dry-run notifications, progress
- `log_success` - Operations completed
- `log_warning` - Non-fatal issues, skipped items
- `log_error` - Fatal errors (always to stderr)

## Comments

**When to Comment:**
- Complex logic or non-obvious decisions
- Function purposes (docstrings before functions)
- Workarounds or hacks (with TODO/FIXME if temporary)

**Function Documentation:**
```bash
# Helper: Description of what this does
# Usage: function_name "arg1" "arg2"
function_name() {
    ...
}
```

**JSDoc/TSDoc:**
- Not applicable (shell scripts)
- Use Markdown documentation in `docs/` for complex concepts

## Function Design

**Size:**
- Functions should do one thing
- Main functions (install_*) ~20-40 lines
- Helper functions ~5-15 lines
- Complex functions broken into sub-functions

**Parameters:**
- Use positional parameters: `$1`, `$2`, etc.
- Quote all parameters: `"$1"`, `"$2"`
- Validate required parameters

**Return Values:**
- Exit codes: 0 = success, non-zero = failure
- Output: Use stdout for data, stderr for errors
- No global return variables (use local scope)

## Module Design

**Exports:**
- Shell scripts don't have formal exports
- Functions are "public" by default
- Private functions prefixed with `_`

**Barrel Files:**
- `lib/common.sh` acts as utility barrel
- Sourced once at script start
- All utility functions available globally after sourcing

## Configuration Conventions

**JSON:**
- Standard formatting (no trailing commas)
- Use `jq` for parsing/validation
- Example: `jq . settings.json`

**YAML:**
- 2-space indentation (no tabs)
- Used for CCS config, GitHub Actions

**Markdown:**
- Emoji prefixes for visual hierarchy:
  - `🚀` Main sections
  - `📋` Lists/guides
  - `🎨` Style/formatting
  - `🔁` CI/repetition
- Code blocks with language tags

---

*Convention analysis: 2026-03-30*

# Architecture

**Analysis Date:** 2026-03-30

## Pattern Overview

**Overall:** Modular Shell Script Architecture with Library Pattern

**Key Characteristics:**
- Separation of concerns between CLI, library, and configuration
- Bidirectional sync capability (install and export)
- Dry-run support for safe testing
- Plugin-based extensibility
- Multi-platform AI tool management

## Layers

**CLI Layer (Entry Points):**
- Purpose: User-facing command execution
- Location: `cli.sh`, `generate.sh`
- Contains: Argument parsing, main workflow orchestration
- Depends on: `lib/common.sh`
- Used by: End users

**Library Layer (Shared Utilities):**
- Purpose: Reusable functions and utilities
- Location: `lib/common.sh`
- Contains: Logging, file operations, installation helpers, parallel execution
- Depends on: POSIX utilities, external CLI tools
- Used by: `cli.sh`, `generate.sh`

**Configuration Layer (Data):**
- Purpose: Tool-specific configurations
- Location: `configs/`
- Contains: JSON configs, Markdown guides, themes
- Depends on: Directory structure conventions
- Used by: Installation scripts

**Skills Layer (Extensions):**
- Purpose: Reusable skill definitions
- Location: `skills/`
- Contains: SKILL.md files with agent definitions
- Depends on: AI tool compatibility
- Used by: All AI tools (Claude, OpenCode, etc.)

## Data Flow

**Installation Flow (cli.sh):**
1. Parse arguments (`--dry-run`, `--backup`, `--yes`)
2. Run preflight checks (git, bun/node)
3. Backup existing configs (optional)
4. Install AI tools (Claude, OpenCode, Amp, etc.)
5. Install global tools (jq, biome, formatters)
6. Copy configurations to home directory
7. Install MCP servers and plugins
8. Display completion message

**Export Flow (generate.sh):**
1. Parse arguments (`--dry-run`)
2. Read configs from home directory
3. Filter marketplace plugins
4. Copy configurations back to repository
5. Update best-practices.md and MEMORY.md

**Configuration Sync:**
- Bidirectional: Repo → Home (`cli.sh`) and Home → Repo (`generate.sh`)
- Safe: Dry-run mode for previewing changes
- Version controlled: Git tracks config changes

## Key Abstractions

**execute():**
- Purpose: Safe command execution with dry-run support
- Location: `lib/common.sh`
- Pattern: Wraps eval with DRY_RUN check
- Usage: All destructive operations

**run_installer():**
- Purpose: Generic tool installer with interactive/non-interactive modes
- Location: `lib/common.sh`
- Pattern: Accepts check_cmd, install_cmd, version_cmd
- Usage: All install_* functions

**safe_copy_dir():**
- Purpose: Directory copying with error handling and exclusions
- Location: `cli.sh`
- Pattern: Uses rsync if available, fallback to find/cp
- Usage: Config directory operations

**Logging Functions:**
- Purpose: Consistent output formatting
- Location: `lib/common.sh`
- Pattern: Color-coded log levels (info, success, warning, error)
- Usage: Throughout all scripts

## Entry Points

**cli.sh main():**
- Location: `cli.sh` (bottom of file)
- Triggers: Direct execution or curl | bash
- Responsibilities: Orchestrate full installation workflow

**generate.sh main():**
- Location: `generate.sh` (bottom of file)
- Triggers: Direct execution
- Responsibilities: Export home configs back to repo

**Individual Install Functions:**
- Location: `cli.sh` (install_claude_code, install_opencode, etc.)
- Triggers: Called from main()
- Responsibilities: Install specific AI tools

## Error Handling

**Strategy:** Fail-fast with informative messages

**Patterns:**
- `set -e` at script start for immediate exit on error
- Guard clauses for prerequisite checks
- `|| true` for optional operations
- Trap-based cleanup (in common.sh)
- Error capture to temp files for analysis

**Logging Levels:**
- `log_info()` - Blue, informational
- `log_success()` - Green, operations completed
- `log_warning()` - Yellow, non-fatal issues
- `log_error()` - Red, fatal errors (to stderr)

## Cross-Cutting Concerns

**Logging:**
- Approach: Color-coded console output
- Location: `lib/common.sh`
- Pattern: All output via log_* functions

**Validation:**
- Approach: Shellcheck + runtime syntax check
- Location: Pre-commit hooks, AGENTS.md
- Pattern: `bash -n` for syntax, shellcheck for quality

**Authentication:**
- Approach: No direct auth in scripts
- Pattern: Tools handle their own auth (Claude Code login, etc.)

---

*Architecture analysis: 2026-03-30*

# Codebase Concerns

**Analysis Date:** 2026-03-30

## Tech Debt

**Eval Usage:**
- Issue: Multiple `eval` calls throughout codebase for dynamic command execution
- Files: `lib/common.sh` (lines 36, 150, 151, 233, 285, 292, 376)
- Impact: Potential security risk if user-controlled data reaches eval
- Current mitigation: All eval'd content is hardcoded or internally controlled
- Fix approach: Refactor to use arrays or functions instead of eval where possible

**Dynamic Source Execution:**
- Issue: `source "$HOME/.bashrc"` and `source "$HOME/.zshrc"` in `cli.sh` (lines 171, 174)
- Impact: User's shell config could affect script behavior
- Current mitigation: Sourced with `2>/dev/null || true` to suppress errors
- Note: Required for Bun installation to update PATH

## Security Considerations

**Remote Script Execution:**
- Risk: `curl | bash` pattern for Bun installation
- Files: `cli.sh` (lines 156, 167, 194)
- Current mitigation: Uses official Bun installer (bun.sh), verified source
- Recommendations: Users can review script before running as documented in README

**Plugin/MCP Installation:**
- Risk: Installing plugins from external repositories (npm, GitHub)
- Files: Throughout `cli.sh` and `lib/common.sh`
- Current mitigation: All sources are verified (official npm registry, trusted repos)
- Note: This is by design - users trust these sources when using AI tools

**File System Operations:**
- Risk: `rm -rf` operations on user directories
- Files: `cli.sh` (copy_configurations function), `lib/common.sh` (cleanup_old_backups)
- Current mitigation: `--dry-run` mode, backup before changes, interactive prompts
- Safe modification: Always use `--dry-run` first as documented

## Performance Considerations

**Sequential Plugin Installation:**
- Issue: Official plugins install sequentially in non-interactive mode
- Files: `cli.sh` (enable_plugins function)
- Impact: Slower installation when many plugins needed
- Current state: Partial parallelization exists with background processes
- Improvement path: Full parallel installation with job control limits

**Backup Directory Cleanup:**
- Issue: `find` command scans entire `$HOME` directory
- Files: `lib/common.sh` (cleanup_old_backups function, line ~124)
- Impact: Could be slow on systems with many files in home
- Current mitigation: Uses `-maxdepth 1` to limit scope

## Fragile Areas

**Platform Detection:**
- Files: `cli.sh` (IS_WINDOWS detection)
- Why fragile: OSTYPE detection may not cover all Windows environments
- Safe modification: Test on Git Bash, WSL, and native Windows
- Test coverage: Limited automated testing for Windows

**Tool Installation Error Handling:**
- Files: All `install_*()` functions in `cli.sh`
- Why fragile: Each tool has unique installation requirements
- Safe modification: Maintain consistent patterns, test with --dry-run

**Cross-Device Link Errors:**
- Files: `lib/common.sh` (setup_tmpdir function)
- Issue: Temporary files may be on different filesystem
- Current fix: Uses `$HOME/.claude/tmp` to ensure same filesystem

## Dependencies at Risk

**Bun/Node Dependency:**
- Risk: Scripts prefer Bun but fall back to Node
- Impact: Some features may work differently with Node
- Current mitigation: Clear warnings when Node is used
- Migration plan: Bun is gaining popularity, likely stable

**External Install Scripts:**
- Risk: Third-party install scripts (ampcode.com, opencode.ai)
- Impact: If these change, installation may break
- Current mitigation: Multiple install methods, error handling

## Test Coverage Gaps

**Untested Areas:**
- **Actual installations** - Network-dependent, side-effect heavy
  - Files: All `install_*()` functions
  - Risk: Changes to external tools may break installation
  - Priority: Medium - dry-run covers logic

- **MCP server configuration** - Requires Claude Code CLI
  - Files: `install_mcp_interactive()` in `cli.sh`
  - Risk: MCP add commands may change
  - Priority: Low - graceful failure handling exists

- **Plugin marketplace** - Requires active subscription
  - Files: `enable_plugins()` in `cli.sh`
  - Risk: Marketplace availability varies
  - Priority: Low - handled with fallbacks

**Safe Modification Guidelines:**
1. Always test with `./cli.sh --dry-run` first
2. Use `bash -n` for syntax validation
3. Run shellcheck before committing
4. Test on macOS and Linux if possible
5. Verify no breaking changes to CLI interface

## Known Limitations

**Windows Support:**
- Limited testing on Windows Git Bash
- Some tools may not be available on Windows
- Path handling uses Unix conventions

**Non-Interactive Mode:**
- Some prompts still require stdin
- `--yes` flag bypasses interactive prompts
- May not work in all CI environments

**Error Recovery:**
- No automatic rollback on partial failure
- Transaction system exists but not comprehensive
- Manual intervention may be needed for broken states

---

*Concerns audit: 2026-03-30*

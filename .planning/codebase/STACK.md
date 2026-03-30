# Technology Stack

**Analysis Date:** 2026-03-30

## Languages

**Primary:**
- **Bash** - All core scripts (`cli.sh`, `generate.sh`, `lib/common.sh`)
- **Shell scripting** - POSIX-compliant bash (not sh)

**Secondary:**
- **JSON** - Configuration files (settings.json, mcp-servers.json, config.json)
- **YAML** - CCS config, pre-commit hooks, GitHub Actions
- **Markdown** - Documentation, commands, agents, skills

## Runtime

**Environment:**
- Bash 3.2+ (macOS compatible)
- Git Bash (Windows support)
- Linux shell environments

**Package Manager:**
- **npm** - For installing global CLI tools
- **brew** - macOS package manager (optional)
- **mise** - Version manager for tools (optional)

## Key Dependencies

**Required Tools:**
- `git` - Version control (mandatory)
- `jq` - JSON parsing and validation
- `bash` - Script execution
- Standard POSIX utilities (awk, sed, grep, find)

**Optional Tools:**
- `bun` - Preferred runtime (faster than Node)
- `node` - Alternative runtime
- `fd` - Modern find alternative (faster)
- `rg` (ripgrep) - Modern grep alternative
- `biome` - JS/TS formatter
- `gofmt` - Go formatter
- `ruff` - Python formatter
- `rustfmt` - Rust formatter
- `shfmt` - Shell script formatter
- `stylua` - Lua formatter

## Configuration

**Environment:**
- `$HOME/.claude/` - Claude Code configuration
- `$HOME/.config/opencode/` - OpenCode configuration
- `$HOME/.config/amp/` - Amp configuration
- `$HOME/.codex/` - Codex CLI configuration
- `$HOME/.gemini/` - Gemini CLI configuration
- `$HOME/.config/kilo/` - Kilo CLI configuration
- `$HOME/.pi/` - Pi configuration
- `$HOME/.config/ai-launcher/` - AI Launcher configuration
- `$HOME/.ai-tools/` - Best practices and guidelines

**Build/Development:**
- `.pre-commit-config.yaml` - Pre-commit hooks for validation
- `renovate.json` - Dependency update automation
- `.github/workflows/` - CI/CD workflows

## Platform Requirements

**Development:**
- macOS, Linux, or Windows (Git Bash)
- Bash 3.2+ or compatible shell
- curl or wget for downloads
- Internet connection for tool installation

**Production (Distribution):**
- Static website (GitHub Pages) for documentation
- Raw GitHub URLs for installer scripts
- npm registry for published tools

---

*Stack analysis: 2026-03-30*

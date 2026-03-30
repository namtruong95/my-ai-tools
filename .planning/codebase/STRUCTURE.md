# Directory Structure

**Analysis Date:** 2026-03-30

## Root Layout

```
my-ai-tools/
├── cli.sh                  # Main installation script (1546 lines)
├── generate.sh            # Config export script (491 lines)
├── install.sh             # One-line installer for curl | bash
├── lib/
│   └── common.sh          # Shared utilities (391 lines)
├── configs/               # AI tool configurations
│   ├── claude/           # Claude Code settings, MCP, commands, agents, hooks
│   ├── opencode/         # OpenCode agents, commands, skills
│   ├── amp/              # Amp settings, skills
│   ├── ccs/              # CCS configuration, hooks, cliproxy
│   ├── codex/            # Codex CLI configs
│   ├── gemini/           # Gemini CLI configs
│   ├── kilo/             # Kilo CLI configs
│   ├── pi/               # Pi settings, themes
│   ├── copilot/          # GitHub Copilot CLI configs
│   ├── ai-launcher/      # AI Launcher config
│   └── *.md              # Shared guidelines (best-practices.md, git-guidelines.md)
├── skills/               # Local skills for distribution
│   ├── adr/              # Architecture Decision Records
│   ├── codemap/          # Codebase mapping
│   ├── handoffs/         # Session handoffs
│   ├── pickup/           # Resume work from handoffs
│   ├── pr-review/        # PR review automation
│   ├── prd/              # Product Requirements Document
│   ├── qmd-knowledge/    # Knowledge management
│   ├── ralph/            # Ralph agent system
│   ├── slop/             # Remove AI code slop
│   └── tdd/              # TDD workflow
├── tests/                # Test files
├── docs/                 # Documentation website
├── .github/              # GitHub Actions, workflows
├── .claude-plugin/       # Claude plugin manifests
└── .planning/            # Planning documents (this directory)
```

## Key Locations

**Scripts:**
- `cli.sh` - Main entry point for installation
- `generate.sh` - Export configs back to repo
- `install.sh` - One-line installer (downloads and runs cli.sh)
- `lib/common.sh` - Shared functions library

**Configuration:**
- `configs/claude/` - Claude Code settings, MCP servers, commands, agents
- `configs/opencode/` - OpenCode configuration
- `configs/amp/` - Amp settings and skills
- `configs/ccs/` - CCS configuration files

**Extensions:**
- `skills/` - Reusable skill definitions (SKILL.md format)
- `configs/*/commands/` - Tool-specific commands
- `configs/*/agents/` - Tool-specific agents

## Naming Conventions

**Files:**
- Shell scripts: `*.sh` (lowercase)
- Config files: `*.json`, `*.yaml`, `*.md`
- Commands: `command-name.md` (lowercase with hyphens)
- Agents: `agent-name.md`
- Skills: `skill-name/SKILL.md` (directory with SKILL.md)

**Functions:**
- Public: `lowercase_with_underscores()`
- Private/internal: `_leading_underscore()`
- Constants: `UPPERCASE_WITH_UNDERSCORES`

**Variables:**
- Local: `lowercase_with_underscores`
- Global: `UPPERCASE_FOR_EXPORTED`
- Environment: Preserved from system

## Organization Principles

**By Tool:**
Each AI tool has its own config directory under `configs/`
- Separate concerns for each tool
- Easy to add new tools
- Tool-specific patterns

**By Function:**
- Scripts at root level
- Shared code in `lib/`
- Tool configs in `configs/`
- Reusable skills in `skills/`

**Documentation:**
- README.md at root for users
- AGENTS.md for AI coding guidelines
- MEMORY.md for project context
- Each skill has its own documentation

---

*Structure analysis: 2026-03-30*

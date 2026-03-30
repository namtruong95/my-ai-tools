# External Integrations

**Analysis Date:** 2026-03-30

## AI Coding Tools

**Core Tools Installed:**
- **Claude Code** (`@anthropic-ai/claude-code`) - Primary AI coding assistant
- **OpenCode** - Alternative AI coding tool
- **Amp** - AI coding assistant with different approach
- **CCS** (`@kaitranntt/ccs`) - Claude Code Switch for provider flexibility
- **Codex CLI** (`@openai/codex`) - OpenAI's coding assistant
- **Gemini CLI** (`@google/gemini-cli`) - Google's coding assistant
- **Kilo CLI** (`@kilocode/cli`) - Kilo AI coding tool
- **Pi** (`@mariozechner/pi-coding-agent`) - Pi coding agent
- **GitHub Copilot CLI** - GitHub's AI assistant

## MCP Servers (Model Context Protocol)

**Configured Servers:**
- **context7** (`@upstash/context7-mcp`) - Documentation lookup
- **sequential-thinking** (`@modelcontextprotocol/server-sequential-thinking`) - Multi-step reasoning
- **qmd** - Knowledge management via qmd CLI

## Plugin Ecosystem

**Official Claude Plugins:**
- `typescript-lsp@claude-plugins-official`
- `pyright-lsp@claude-plugins-official`
- `context7@claude-plugins-official`
- `frontend-design@claude-plugins-official`
- `learning-output-style@claude-plugins-official`
- `swift-lsp@claude-plugins-official`
- `lua-lsp@claude-plugins-official`
- `code-simplifier@claude-plugins-official`
- `rust-analyzer-lsp@claude-plugins-official`
- `claude-md-management@claude-plugins-official`

**Community Plugins:**
- `plannotator@plannotator` - Planning and annotation tool
- `plannotator-copilot@plannotator` - Copilot variant
- `prd@my-ai-tools` - PRD generation
- `ralph@my-ai-tools` - Ralph agent system
- `qmd-knowledge@my-ai-tools` - Knowledge management
- `codemap@my-ai-tools` - Codebase mapping
- `claude-hud@claude-hud` - Claude HUD
- `worktrunk@worktrunk` - Work management

## External Services

**Installation Sources:**
- **npm registry** - Primary source for CLI tools
- **GitHub raw URLs** - Install scripts (ai-launcher, plannotator)
- **Bun install** - qmd CLI from GitHub
- **Homebrew** - macOS packages (optional)
- **Rustup/cargo** - Rust tools (optional)

**API Endpoints:**
- `https://bun.sh/install` - Bun installer
- `https://opencode.ai/install` - OpenCode installer
- `https://ampcode.com/install.sh` - Amp installer
- `https://plannotator.ai/install.sh` - Plannotator CLI
- `https://sh.rustup.rs` - Rust installer

## Version Control

**Git Integration:**
- Pre-commit hooks for validation
- GitHub Actions for CI
- GitGuard hook for dangerous operation prevention
- Automatic backup before config changes

## Marketplace Integrations

**Claude Plugin Marketplace:**
- `anthropics/claude-plugins-official` - Official plugins
- `backnotprop/plannotator` - Community marketplace
- `jarrodwatts/claude-hud` - Claude HUD
- `max-sixty/worktrunk` - Work management

**Skills Installation:**
- `npx skills add` - Remote skill installation
- Local skills from `skills/` directory

---

*Integrations analysis: 2026-03-30*

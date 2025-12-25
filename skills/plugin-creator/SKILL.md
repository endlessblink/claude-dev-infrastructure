---
name: plugin-creator
description: Create, validate, and publish Claude Code plugins and marketplaces. Use this skill when building plugins with commands, agents, hooks, MCP servers, or skills.
---

# Claude Code Plugin Creator

## Overview

This skill provides comprehensive guidance for creating Claude Code plugins following the official Anthropic format (as of December 2025).

## Plugin Architecture

A Claude Code plugin can contain any combination of:
- **Commands**: Custom slash commands (`/mycommand`)
- **Agents**: Specialized AI subagents for specific tasks
- **Hooks**: Pre/post tool execution behaviors
- **MCP Servers**: Model Context Protocol integrations
- **Skills**: Domain-specific knowledge packages

## Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # REQUIRED - Plugin manifest
├── commands/                 # Optional - Slash commands
│   └── my-command.md
├── agents/                   # Optional - Subagents
│   └── my-agent.md
├── hooks/                    # Optional - Hook definitions
│   └── hooks.json
├── skills/                   # Optional - Bundled skills
│   └── my-skill/
│       └── SKILL.md
├── mcp/                      # Optional - MCP server configs
└── README.md
```

## Plugin Manifest (plugin.json)

The `.claude-plugin/plugin.json` file is **required**.

### VALIDATED FIELDS ONLY

**WARNING**: The Claude Code validator is strict. Only use these validated fields:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Clear description of what this plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "MIT",
  "skills": [
    "./skills/my-skill"
  ]
}
```

### INVALID FIELDS (Do NOT use)

These fields will cause validation errors:

| Field | Error |
|-------|-------|
| `$schema` | Unrecognized key |
| `category` | Unrecognized key |
| `tags` | Unrecognized key |
| `repository` | Unrecognized key |
| `hooks` | Invalid input (object format rejected) |
| `commands` | Invalid input (format may be incorrect) |

### Marketplace Source Path

In `marketplace.json`, the `source` field **MUST** start with `./`:

```json
"source": "./"      // ✅ Correct
"source": "."       // ❌ Invalid - must start with ./
```

### Minimal Valid Plugin

Start with this minimal structure that is guaranteed to validate:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": {
    "name": "Your Name"
  },
  "skills": []
}
```

## Creating Commands

Commands are markdown files with YAML frontmatter:

```markdown
---
name: deploy
description: Deploy the application to production
---

# Deploy Command

When the user runs /deploy, perform these steps:

1. Run the build process
2. Run all tests
3. Create a deployment package
4. Upload to the configured target

## Usage Examples

- `/deploy` - Deploy to default environment
- `/deploy staging` - Deploy to staging
- `/deploy production --skip-tests` - Deploy to production (use carefully)
```

## Creating Agents

Agents are specialized subagents with focused capabilities:

```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
model: sonnet
tools:
  - Read
  - Grep
  - Glob
---

# Security Review Agent

You are a security expert focused on identifying vulnerabilities.

## Your Responsibilities

1. Scan for OWASP Top 10 vulnerabilities
2. Identify hardcoded secrets
3. Check for input validation issues
4. Review authentication/authorization logic

## Output Format

Provide findings as:
- CRITICAL: Immediate security risk
- HIGH: Should fix before deployment
- MEDIUM: Fix in next sprint
- LOW: Consider improving
```

## Creating Skills

Skills use the official Agent Skills format:

```markdown
---
name: my-skill
description: What this skill teaches Claude to do
---

# My Skill Name

## When to Use

Use this skill when the user needs help with [specific task].

## Instructions

1. Step one
2. Step two
3. Step three

## Examples

### Example 1: Basic Usage
[Concrete example]

### Example 2: Advanced Usage
[Another example]

## Best Practices

- Practice 1
- Practice 2
```

## Creating Hooks

Hooks are defined in `hooks.json`:

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "matcher": "Edit|Write",
      "command": ".claude-plugin/hooks/security-check.sh"
    },
    {
      "event": "PostToolUse",
      "matcher": "Bash",
      "command": ".claude-plugin/hooks/log-commands.sh"
    }
  ]
}
```

Hook events:
- `PreToolUse` - Before a tool executes
- `PostToolUse` - After a tool completes
- `SessionStart` - When a Claude Code session begins
- `SessionEnd` - When a session ends

## Creating a Marketplace

To distribute multiple plugins, create a marketplace:

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    ├── plugin-a/
    │   └── .claude-plugin/
    │       └── plugin.json
    └── plugin-b/
        └── .claude-plugin/
            └── plugin.json
```

### marketplace.json

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "Collection of productivity plugins",
  "owner": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "plugins": [
    {
      "name": "plugin-a",
      "description": "What plugin A does",
      "source": "./plugins/plugin-a",
      "category": "development",
      "tags": ["productivity", "automation"]
    },
    {
      "name": "plugin-b",
      "description": "What plugin B does",
      "source": "./plugins/plugin-b",
      "category": "productivity"
    }
  ]
}
```

### Plugin Categories

Official categories:
- `development` - Developer tools
- `productivity` - Workflow automation
- `security` - Security tools
- `learning` - Educational content
- `testing` - Test automation
- `database` - Database tools
- `design` - UI/UX tools
- `monitoring` - Observability
- `deployment` - CI/CD tools

## Testing Plugins

### Local Testing

```bash
# Install from local path
/plugin install /path/to/my-plugin

# Or add as local marketplace
/plugin marketplace add /path/to/my-marketplace
/plugin install my-plugin@my-marketplace

# List installed plugins
/plugin list

# Enable/disable
/plugin enable my-plugin
/plugin disable my-plugin

# Uninstall
/plugin uninstall my-plugin
```

### Validation Checklist

Before publishing, verify:

- [ ] `plugin.json` is valid JSON
- [ ] All `source` paths exist
- [ ] Commands have name + description
- [ ] Agents specify required tools
- [ ] Hook scripts are executable
- [ ] Skills have proper YAML frontmatter
- [ ] README.md explains usage

## Publishing to a Marketplace

### Option 1: Create Your Own Marketplace

1. Create a GitHub repository
2. Add `.claude-plugin/marketplace.json`
3. Add plugin directories
4. Users install via:
   ```
   /plugin marketplace add your-username/your-repo
   /plugin install plugin-name@your-repo
   ```

### Option 2: Submit to Community Marketplaces

Popular community marketplaces:
- [cc-marketplace](https://github.com/ananddtyagi/claude-code-marketplace)
- [claude-plugins.dev](https://claude-plugins.dev)

Submit via:
- Pull request to the marketplace repo
- Or their submission forms

### Option 3: Anthropic's Official Marketplace

The [anthropics/claude-code](https://github.com/anthropics/claude-code) repo contains official plugins. To add:
1. Fork the repository
2. Add your plugin under `plugins/`
3. Update `marketplace.json`
4. Submit a pull request

## Best Practices

### Plugin Design

1. **Single Responsibility**: Each plugin should do one thing well
2. **Clear Descriptions**: Users should understand purpose from description
3. **Sensible Defaults**: Work out-of-the-box with minimal config
4. **Version Semantics**: Use semver (1.0.0, 1.1.0, 2.0.0)

### Security

1. **Minimal Permissions**: Only request tools you need
2. **No Secrets in Code**: Use environment variables
3. **Audit Hook Scripts**: Review all shell scripts for safety
4. **Document Risks**: Explain what your plugin does

### Documentation

1. **README.md**: Always include installation and usage
2. **Examples**: Show concrete use cases
3. **Changelog**: Track version changes
4. **License**: Specify usage terms (MIT recommended)

## Quick Start Template

Run this to scaffold a new plugin:

```bash
mkdir my-plugin && cd my-plugin
mkdir -p .claude-plugin commands agents skills

cat > .claude-plugin/plugin.json << 'EOF'
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My awesome Claude Code plugin",
  "author": {
    "name": "Your Name"
  },
  "commands": []
}
EOF

cat > README.md << 'EOF'
# My Plugin

Description of your plugin.

## Installation

```
/plugin install /path/to/my-plugin
```

## Usage

Describe how to use your plugin.
EOF

echo "Plugin scaffolded! Edit .claude-plugin/plugin.json to add commands/agents."
```

## Troubleshooting Guide

### SSH Permission Denied Errors

**Error:**
```
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

**Cause:** Claude Code defaults to SSH for GitHub repos, but SSH keys may not be configured.

**Solutions:**

1. **Use HTTPS URL format in marketplace.json:**
```json
"source": {
  "source": "url",
  "url": "https://github.com/owner/repo.git"
}
```

2. **Add marketplace via HTTPS directly:**
```bash
/plugin marketplace add https://github.com/owner/marketplace-repo.git
```

3. **Use local path (most reliable):**
```bash
git clone https://github.com/owner/marketplace.git ~/.claude/marketplaces/mymarket
/plugin marketplace add ~/.claude/marketplaces/mymarket
```

### Cached Old Versions

**Symptoms:** Changes to marketplace.json don't take effect.

**Solution:** Clear ALL caches:
```bash
# Clear download cache
rm -rf ~/.claude/plugins/cache/

# Force update installed marketplace
rm -rf ~/.claude/plugins/marketplaces/your-marketplace-name/
# Then re-add the marketplace
```

### Marketplace Schema Validation Errors

**Error:** `Unrecognized key(s) in object`

**Cause:** Extra fields in marketplace.json that aren't in the official schema.

**Invalid fields for marketplace.json:**
- `features`
- `requirements`
- `bugs`
- Any custom fields

**Valid marketplace.json structure:**
```json
{
  "name": "marketplace-name",
  "owner": {
    "name": "Your Name"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Description",
      "source": "./path/to/plugin"
    }
  ]
}
```

### Plugin.json Validation Errors

**Error:** `hooks: Invalid input, commands: Invalid input`

**Cause:** The plugin.json validator rejects certain field formats.

**Known invalid fields:**
| Field | Status |
|-------|--------|
| `$schema` | Rejected |
| `category` | Rejected |
| `tags` | Rejected |
| `repository` | Rejected |
| `hooks` (object format) | Rejected |
| `commands` (array format) | May be rejected |

**Safe minimal plugin.json:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Description",
  "author": { "name": "Your Name" },
  "skills": ["./skills/my-skill"]
}
```

### Separate Marketplace from Plugin

**Problem:** Having both `marketplace.json` and `plugin.json` in same `.claude-plugin/` directory causes confusion.

**Solution:** Use separate repositories:

**Marketplace repo:**
```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json  # Points to external plugin
└── README.md
```

**Plugin repo:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json       # No marketplace.json here
├── skills/
└── README.md
```

**marketplace.json referencing external plugin:**
```json
{
  "name": "my-marketplace",
  "owner": { "name": "Your Name" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": {
        "source": "url",
        "url": "https://github.com/owner/my-plugin.git"
      }
    }
  ]
}
```

### Non-GitHub Repository Issues

**Problem:** Claude Code may fail with self-hosted git servers.

**Correct SSH format:**
```bash
git@hostname:path/to/repo.git  # Use colon, not slash
```

**HTTPS alternative:**
```bash
https://git.example.com/path/to/repo.git
```

### Installation Hangs

**Symptoms:** `/plugin marketplace add` hangs indefinitely.

**Solutions:**
1. Check internet connectivity
2. Verify repository is public
3. Use local path instead of remote URL
4. Check for large files in repo (can slow clone)

### Validating Before Publishing

Run this checklist:
```bash
# 1. Validate JSON syntax
cat .claude-plugin/plugin.json | python3 -m json.tool

# 2. Check required files exist
ls -la .claude-plugin/plugin.json
ls -la skills/*/SKILL.md

# 3. Verify source paths
for skill in $(jq -r '.skills[]' .claude-plugin/plugin.json); do
  [ -d "$skill" ] && echo "✓ $skill" || echo "✗ $skill MISSING"
done

# 4. Test local install
/plugin install /path/to/my-plugin
```

### Complete Installation Flow

```bash
# Step 1: Clear all caches
rm -rf ~/.claude/plugins/cache/

# Step 2: Remove old marketplace if exists
rm -rf ~/.claude/plugins/marketplaces/your-marketplace/

# Step 3: Add marketplace (use HTTPS or local path)
/plugin marketplace add https://github.com/owner/marketplace.git
# OR
/plugin marketplace add /local/path/to/marketplace

# Step 4: Install plugin
/plugin install plugin-name@marketplace-name

# Step 5: Verify
/plugin list
```

## References

- [Claude Code Plugin Docs](https://code.claude.com/docs/en/plugins)
- [Creating Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Agent Skills Spec](https://agentskills.io)
- [Anthropic Skills Repo](https://github.com/anthropics/skills)
- [Official Plugins](https://github.com/anthropics/claude-code/tree/main/plugins)
- [GitHub Issues: SSH Auth](https://github.com/anthropics/claude-code/issues/9740)
- [GitHub Issues: Non-GitHub Repos](https://github.com/anthropics/claude-code/issues/10403)

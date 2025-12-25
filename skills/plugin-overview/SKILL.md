# Plugin Overview - Claude Dev Infrastructure

Use this skill when you need to understand what resources are available in the claude-dev-infrastructure plugin or when setting up a new project.

## Plugin Components Quick Reference

### Skills (12 total)

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **chief-architect** | Strategic development orchestrator | Architecture decisions, project planning |
| **master-plan-manager** | MASTER_PLAN.md management | Task tracking, roadmap updates |
| **meta-skill-router** | Intelligent skill selection | Choosing which skill to use |
| **skill-creator-doctor** | Create and repair skills | Making new skills, fixing broken ones |
| **skills-manager** | Skill consolidation | Managing multiple skills |
| **ai-truthfulness-enforcer** | Prevents false success claims | Before claiming anything is "done" |
| **document-sync** | Keep docs synchronized | Documentation updates |
| **safe-project-organizer** | Safe file organization | File reorganization |
| **data-safety-auditor** | Data safety auditing | Before destructive operations |
| **crisis-debugging-advisor** | Emergency debugging | Critical bug investigations |
| **qa-testing** | Mandatory testing protocols | Before marking features complete |
| **plugin-creator** | Create Claude Code plugins | Building distributable plugins |

### Hooks (11 total)

Located in `hooks/` directory. Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/hooks/task-lock-enforcer.sh"
      }
    ],
    "SessionStart": [
      { "command": ".claude/hooks/session-lock-awareness.sh" }
    ],
    "SessionEnd": [
      { "command": ".claude/hooks/session-lock-release.sh" }
    ]
  }
}
```

| Hook | Purpose |
|------|---------|
| `task-lock-enforcer.sh` | Prevents concurrent task editing across instances |
| `session-lock-awareness.sh` | Shows active locks at session start |
| `session-lock-release.sh` | Releases locks at session end |
| `auto-sync-task-status.sh` | Syncs task status changes |
| `master-plan-reminder.sh` | Reminds about MASTER_PLAN updates |
| `check-npm-scripts.sh` | Validates npm scripts |
| `task-disappearance-helper.sh` | Tracks mysterious data loss |

### Templates (5 total)

Located in `templates/` directory. Use `/dev-setup` command to install:

| Template | Purpose |
|----------|---------|
| `MASTER_PLAN.template.md` | Project tracking with task IDs (TASK-XXX, BUG-XXX) |
| `CLAUDE.template.md` | Claude Code project guidance |
| `SOP.template.md` | Standard Operating Procedure format |
| `settings.template.json` | Claude Code settings with hooks |
| `skill-template.md` | Skill creation template |

### Commands (2)

| Command | Description |
|---------|-------------|
| `/dev-setup` | Initialize a new project with dev infrastructure |
| `/dev-manager` | Start the visual Kanban dashboard |

### Dev Manager Dashboard

A visual Kanban board that parses MASTER_PLAN.md:

```bash
cd dev-manager
DEV_MANAGER_ROOT=/your/project npm start
# Opens at http://localhost:6010
```

**Features:**
- Real-time MASTER_PLAN.md parsing
- Drag-and-drop task status changes
- Live sync back to MASTER_PLAN.md
- Glass morphism design (PomoFlow-inspired)

## Project Setup Workflow

When setting up a new project with this plugin:

1. **Install Plugin**:
   ```bash
   /plugin marketplace add endlessblink/claude-plugins-marketplace
   /plugin install claude-dev-infrastructure
   ```

2. **Run Setup Command**:
   ```
   /dev-setup
   ```
   This copies templates and hooks to your project.

3. **Start Dev Manager** (optional):
   ```bash
   cd .claude/dev-manager
   npm install && npm start
   ```

4. **Use Skills**: Skills are automatically available. Reference them by name:
   - "Use the master-plan-manager skill"
   - "Apply the qa-testing skill"

## File Structure Reference

```
claude-dev-infrastructure/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── skills/                    # 12 AI skills
│   ├── chief-architect/
│   ├── master-plan-manager/
│   ├── meta-skill-router/
│   ├── skill-creator-doctor/
│   ├── skills-manager/
│   ├── ai-truthfulness-enforcer/
│   ├── document-sync/
│   ├── safe-project-organizer/
│   ├── data-safety-auditor/
│   ├── crisis-debugging-advisor/
│   ├── qa-testing/
│   ├── plugin-creator/
│   └── plugin-overview/       # This skill
├── hooks/                     # 11 shell scripts
├── templates/                 # 5 templates
├── standards/                 # Quality standards
├── dev-manager/               # Kanban dashboard
├── commands/                  # Slash commands
└── MASTER_PLAN.md             # Plugin development tracking
```

## MASTER_PLAN.md Format

The plugin uses a specific format for task tracking:

```markdown
### TASK-XXX: Task Title (STATUS)

**Priority**: P1-HIGH | P2-MEDIUM | P3-LOW

**Steps**:
- [ ] Pending step
- [x] Completed step

---
```

**Task ID Prefixes:**
- `TASK-XXX` - Active work
- `BUG-XXX` - Bug fixes
- `ROAD-XXX` - Roadmap items
- `IDEA-XXX` - Ideas backlog

**Status Keywords:**
- `DONE`, `COMPLETE`, `~~strikethrough~~` - Done column
- `IN PROGRESS`, `IN_PROGRESS`, `ACTIVE` - In Progress column
- `REVIEW`, `MONITORING` - Review column
- Default (no keyword) - To Do column

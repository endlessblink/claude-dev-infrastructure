---
name: master-plan-manager
description: Safe MASTER_PLAN.md management with backup, validation, and intelligent updates. Use when updating task tracking, adding features to roadmap, or modifying project documentation.
---

# Master Plan Manager

Intelligent management of MASTER_PLAN.md files with comprehensive safety measures.

## When to Use

Use this skill when:
- Updating task status (TASK-XXX, BUG-XXX)
- Adding items to roadmap or ideas sections
- Modifying project tracking documentation
- Ensuring safe updates to critical planning files

## Safety Protocol

**MANDATORY** before any MASTER_PLAN.md modification:

1. **Read First** - Always read the entire file before editing
2. **Backup** - Create timestamped backup before changes
3. **Validate** - Check if update is actually needed (avoid duplicates)
4. **Preserve** - Maintain existing structure and formatting
5. **Verify** - Confirm integrity after changes

## Core Operations

### 1. Status Updates

Update task/bug status in the Dependency Index table:

```markdown
| ID | Status | Primary Files | Depends | Blocks |
|----|--------|---------------|---------|--------|
| TASK-XXX | 🔄 **IN PROGRESS** | `file.ts` | - | - |
```

Status transitions:
- `📋 TODO` → `🔄 IN PROGRESS` → `👀 REVIEW` → `✅ DONE`

### 2. Adding New Items

**New Task:**
```markdown
### TASK-XXX: Task Title (📋 TODO)

**Priority**: P2-MEDIUM

**Files to Modify:**
- `src/file.ts`

**Steps:**
- [ ] Step 1
- [ ] Step 2
```

**New Bug:**
```markdown
### BUG-XXX: Bug Description (🔄 IN PROGRESS)

**Severity**: HIGH

**Symptoms**: What's wrong

**Root Cause**: (To be determined)
```

**Roadmap Item:**
```markdown
| ROAD-XXX | Feature description | P2 | TODO | Notes |
```

### 3. Completing Items

When marking complete:
1. Add strikethrough to ID: `~~TASK-XXX~~`
2. Update status: `(✅ DONE)`
3. Move to "Recently Completed" section
4. Update Dependency Index table

### 4. ID Format

| Prefix | Usage |
|--------|-------|
| `TASK-XXX` | Features and tasks |
| `BUG-XXX` | Bug fixes |
| `ROAD-XXX` | Roadmap items |
| `IDEA-XXX` | Ideas to consider |
| `ISSUE-XXX` | Known issues |

## Safe Update Workflow

```
1. READ current MASTER_PLAN.md
   ↓
2. ANALYZE what needs to change
   ↓
3. CHECK if content already exists (avoid duplicates)
   ↓
4. BACKUP before modifications
   ↓
5. APPLY changes incrementally
   ↓
6. VALIDATE markdown structure
   ↓
7. CONFIRM with user if significant changes
```

## Examples

### Example 1: Mark Task Complete

**Before:**
```markdown
### TASK-033: Create Plugin (🔄 IN PROGRESS)
```

**After:**
```markdown
### ~~TASK-033~~: Create Plugin (✅ DONE)
```

**Also update Dependency Index:**
```markdown
| ~~TASK-033~~ | ✅ **DONE** | `plugin/*` | - | - |
```

### Example 2: Add New Bug

```markdown
### BUG-XXX: Button not responding (🔄 IN PROGRESS)

**Severity**: MEDIUM

**Symptoms**: Click handler not firing on mobile

**Root Cause**: Touch event not handled

**Fix**: Add touchstart listener
```

### Example 3: Update Progress

```markdown
**Steps:**
- [x] Research ✅
- [x] Implementation ✅
- [ ] Testing
- [ ] Documentation
```

## Integration Commands

When chief-architect or other skills delegate:

```
master-plan-manager: update-status TASK-033 done
master-plan-manager: add-task "New feature" P2
master-plan-manager: add-bug "Issue description" HIGH
master-plan-manager: move-to-completed TASK-033
```

## Validation Checklist

Before completing any update:

- [ ] Read entire file first
- [ ] Backup created
- [ ] No duplicate IDs
- [ ] Proper markdown formatting
- [ ] Strikethrough on completed IDs
- [ ] Status emoji matches state
- [ ] Dependency Index updated

## Error Recovery

If something goes wrong:

```bash
# Restore from backup
cp docs/MASTER_PLAN.md.backup docs/MASTER_PLAN.md

# Or use git
git checkout HEAD -- docs/MASTER_PLAN.md
```

## Dev-Manager Parser Compatibility

**CRITICAL**: The dev-manager Kanban dashboard (`http://localhost:6010`) parses MASTER_PLAN.md automatically. For tasks to display correctly, you MUST follow these exact formats:

### Required Section Header

Tasks MUST be inside an `## Active Work` section:
```markdown
## Active Work

### TASK-001: Task Title (STATUS)
```

### Task Header Format

**Active tasks:**
```markdown
### TASK-001: Task Title (STATUS)
### BUG-001: Bug Description (STATUS)
### ISSUE-001: Issue Description (STATUS)
```

**Completed tasks (with strikethrough on ID):**
```markdown
### ~~TASK-001~~: Task Title (✅ DONE)
### ~~BUG-001~~: Bug Description (✅ COMPLETE)
```

### Status Keywords (Parser Detection)

The parser detects these keywords in the header or body:

| Kanban Column | Keywords Detected |
|---------------|-------------------|
| **Done** | `DONE`, `COMPLETE`, `COMPLETED`, `FIXED`, `✅`, `~~strikethrough ID~~` |
| **In Progress** | `IN PROGRESS`, `IN_PROGRESS`, `ACTIVE`, `WORKING`, `🔄`, `⏳` |
| **Review** | `REVIEW`, `MONITORING`, `AWAITING`, `👀` |
| **To Do** | `PLANNED`, `TODO`, or no status keyword (default) |

### Priority Format

Parser detects priority from:
```markdown
### TASK-001: Title (P1-HIGH)
```
Or as a separate line:
```markdown
**Priority**: P1-HIGH
```

Priority levels: `P1`/`HIGH` (red), `P2`/`MEDIUM` (yellow), `P3`/`LOW` (blue)

### Progress Calculation

Parser calculates progress from checkbox subtasks:
```markdown
**Steps:**
- [x] Step 1 completed ✅
- [x] Step 2 completed ✅
- [ ] Step 3 pending
- [ ] Step 4 pending
```
→ Parser shows: **50% progress** (2 of 4 checked)

### Common Mistakes That Break Parsing

| Mistake | Correct Format |
|---------|----------------|
| `### TASK-001 - Title` | `### TASK-001: Title` (use colon) |
| `## Tasks` section | `## Active Work` (exact header) |
| `### Task 1: Title` | `### TASK-001: Title` (use TASK-XXX format) |
| Status in body only | Status in header `(STATUS)` or body with keywords |

---

## Best Practices

1. **Never blindly append** - Always check if section exists
2. **Preserve formatting** - Match existing style (emojis, spacing)
3. **Atomic updates** - One logical change at a time
4. **User verification** - Ask user to confirm significant changes
5. **Keep history** - Document why changes were made
6. **Dev-manager compatible** - Use exact formats above for parser

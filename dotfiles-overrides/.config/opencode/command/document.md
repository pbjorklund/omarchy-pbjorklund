---
description: Create clear, fact-dense technical documentation with proper structure
agent: document-sarah
---
# Context

Read the user's problem or question:
- [ ] Read $ARGUMENTS

## Your Task

Create technical documentation based on the current conversation context. Analyze the conversation to determine what needs documenting.

Execute immediately - search for existing documentation structure first, then write or update accordingly.

## Phase 1: Locate Documentation Structure

Before writing:

1. **Search for docs:** Use list/glob to find:
   - `docs/`, `documentation/`, `notes/`
   - `README.md`, `ARCHITECTURE.md`
   - Project-specific doc patterns

2. **Ask user if ambiguous:** "Found multiple doc locations. Where should this go?"

3. **Never assume:** If no structure found, ask user to specify path

## Phase 2: Write Documentation

### Standard Document Structure

```markdown
# [Topic] - [Type]

**Date:** YYYY-MM-DD
**Purpose:** [Why this document exists]

## Overview
[Definition, basic mechanics, context]

## [Section 1]
[Facts, findings, decisions - scannable format]

## [Section 2]
[Additional information - organized for quick reference]

## Summary
[Key takeaways, recommendations, next steps]
```

### Format Guidelines

- **Headings:** Clear hierarchy (H1 title, H2 sections, H3 subsections)
- **Lists:** Bullets for items, numbers for sequences
- **Code blocks:** Always specify language for syntax highlighting
- **Tables:** For comparative data
- **Bold:** Key terms on first use
- **Links:** Absolute or relative paths (never broken)

### Information Density Rules

**No filler:**
- No pleasantries: "Great!", "Absolutely!", "I hope this helps!"
- No teaching language: "Let's explore...", "It's important to understand..."
- No validation: "You're right that...", "As you mentioned..."

**Straightforward statements:**
- Use: "X is Y"
- Not: "It's worth noting that X appears to be Y"

**Scannable format:**
- Dense but organized
- Heavy structure, minimal prose
- Quick-reference optimized

## Phase 3: Update vs Create

**Prefer updates over new files:**

If related documentation exists:
1. Read existing file
2. Identify where new information fits
3. Use edit tool to add/update sections
4. Maintain existing structure and style

Only create new file when:
- No related documentation exists
- Topic is distinct and warrants separate file
- User explicitly requests new file

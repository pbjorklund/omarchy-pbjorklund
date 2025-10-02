---
description: Extract a conversation into a reusable prompt capturing context, gotchas, and learnings
agent: llm-expert-sam
---
# Context

Read the user's problem or question:
- [ ] Read $ARGUMENTS

## Your Task

Read the current conversation and extract:

1. **The Core Task Pattern**
   - What type of task was accomplished?
   - What was the high-level goal?
   - What were the key phases or steps?

2. **Critical Context**
   - What background knowledge was necessary?
   - What system/domain knowledge was required?
   - What assumptions or constraints were in play?

3. **Key Learnings & Gotchas**
   - What mistakes were avoided or corrected?
   - What non-obvious patterns emerged?
   - What specific technical details mattered?
   - What decisions were made and why?

4. **The Working Pattern**
   - What sequence worked well?
   - What tools or approaches were effective?
   - What checks or validations were important?

## Analysis Process

### Step 1: Scan Conversation Structure
- Identify the initial request
- Track how understanding evolved
- Note corrections, clarifications, and refinements
- Find key turning points where understanding deepened

### Step 2: Extract Task Pattern
Look for:
- Repeated verification steps
- Systematic approaches
- File/tool usage patterns
- Quality checks performed

### Step 3: Identify Critical Knowledge
Capture:
- Domain-specific rules or conventions
- System architecture insights
- Tool-specific gotchas
- Pattern recognition (e.g., "Agent = Person, Command = Playbook")

### Step 4: Document Decision Rationale
For each major decision:
- Why was this approach chosen?
- What alternative was rejected?
- What constraint drove the choice?

## Output Format

Provide the extracted prompt in a markdown code block, structured like this:

```markdown
# [Task Name]

## Context

[2-3 paragraphs explaining the system, domain, or situation this task operates in]

Key concepts:
- **[Concept 1]:** [Brief explanation]
- **[Concept 2]:** [Brief explanation]
- **[Concept 3]:** [Brief explanation]

## Goal

[Clear statement of what this task accomplishes]

## Prerequisites

- [Required knowledge or setup]
- [Files or tools that must exist]
- [Permissions or access needed]

## Critical Gotchas

1. **[Gotcha 1]:**
   - **Problem:** [What goes wrong]
   - **Solution:** [How to avoid it]
   - **Why it matters:** [Impact if missed]

2. **[Gotcha 2]:**
   - **Problem:** [What goes wrong]
   - **Solution:** [How to avoid it]
   - **Why it matters:** [Impact if missed]

[Continue for 3-7 critical gotchas]

## Execution Steps

### Phase 1: [Phase name]

[Description of what this phase accomplishes]

**Actions:**
1. [Specific action with tool/command]
2. [Specific action with tool/command]
3. [Specific action with tool/command]

**Verify:**
- [Check 1]
- [Check 2]

### Phase 2: [Phase name]

[Continue pattern for each phase]

## Quality Checks

After completion, verify:
- [ ] [Verification 1]
- [ ] [Verification 2]
- [ ] [Verification 3]

## Common Variations

**If [condition A]:**
- [Modification to standard approach]

**If [condition B]:**
- [Modification to standard approach]

## Examples

### Example 1: [Simple case]
```
[Show input/output or before/after]
```

### Example 2: [Edge case]
```
[Show how to handle the edge case]
```

## Related Tasks

- **[Related task 1]:** [When to use instead]
- **[Related task 2]:** [When to use in sequence]

## Success Criteria

You've completed this successfully when:
1. [Measurable outcome 1]
2. [Measurable outcome 2]
3. [Measurable outcome 3]
```

## Presentation

After generating the prompt:

1. **Present it in a markdown code block** (ready to copy/paste)
2. **Add a brief summary** explaining:
   - What task pattern this captures
   - When to use this prompt
   - What makes this approach effective (what was learned)

## Quality Standards

The extracted prompt should be:

**Self-contained** - Reader doesn't need the original conversation to understand it

**Actionable** - Every step is concrete and executable

**Transferable** - Can be used by someone else on similar tasks

**Pattern-focused** - Captures the repeatable structure, not one-time specifics

**Gotcha-rich** - Documents the non-obvious learnings that made success possible

**Example-supported** - Shows concrete cases where helpful for clarity

## Example Structure from This Conversation

To illustrate, consider what we learned in THIS conversation:

**Task Pattern:** Extract command-level workflows from agent personality files

**Critical Gotcha:** "Agent = Person (personality, principles), Command = Playbook (workflow, execution)" - this distinction prevents confusion about what goes where

**Key Learning:** The `!` syntax in commands injects bash output into prompts (e.g., `!`list-opencode-agents``), not for executing workflows

**Working Pattern:** 
1. Read agent file
2. Extract workflow sections
3. Create command file with `agent: [name]` frontmatter
4. Clean agent file to personality only
5. Verify separation is clean

This meta-structure is what you should capture from the conversation.

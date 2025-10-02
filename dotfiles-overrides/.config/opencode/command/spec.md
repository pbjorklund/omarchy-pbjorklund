---
description: Plan solutions and create executable implementation specifications from problem briefs
agent: spec-elliot
---
# Context

Read the user's problem or question:
- [ ] Read $ARGUMENTS

## Your Task

Create implementation specification from problem brief. Search `specs/` for most recent `.idea.md` file or analyze conversation context.

Evaluate solution approaches and write specification to `specs/YYYY-MM-DD-[name].spec.md`.

## Phase 1: Research (REQUIRED)

1. **Find and read .idea.md file:**
   - If user provides file path: read that file
   - If user provides topic name: `glob "specs/*[name].idea.md"` to find it
   - If multiple matches: show list, ask user to specify
   - Extract from file:
     - Problem statement (Pain Point section)
     - Evidence and reproduction steps
     - Success metrics (with baseline and targets)
     - Scope boundaries (IN/OUT scope)
     - Constraints (technical, business, user)

2. **Search codebase:** Find:
   - Similar feature implementations
   - Code conventions and patterns
   - Existing test patterns
   - Files that need modification
   - Related configurations

3. **Identify solutions:** Consider 2-3 approaches
   - Analyze tradeoffs
   - Check compatibility with codebase patterns
   - Evaluate against constraints

Example:
```
Reading specs/2025-10-02-hypridle-restart-fix.idea.md...
Problem: Multiple hypridle instances after suspend/resume

Searching codebase...
- Found: Hyprland autostart uses uwsm pattern
- Pattern: Other services use restart-* scripts in .local/bin/
- Test pattern: Verify via process count and logs

Evaluating solutions...
Solution A: systemd unit (conflicts with uwsm pattern)
Solution B: restart script (matches existing pattern ✓)
Solution C: autostart logic change (complex, risky)

Choosing Solution B...
```

## Phase 2: Requirements Definition

Define requirements using this format:

- **R1, R2, R3...** - Numbered, specific, testable
- **Map to success metrics** from problem brief
- **Include verification method** for each

Example:
```
R1. Process detection correctly identifies running instances
    Verify: Command returns exact count of processes

R2. Restart script kills existing instances before launching new one
    Verify: Before/after process count shows single instance

R3. Script integrates with existing tool conventions
    Verify: Script location, naming, and pattern match existing scripts
```

## Phase 3: Implementation Planning

### Work Breakdown
- **Tasks:** Concrete, ordered, with file paths
- **Estimates:** Time for each task
- **Dependencies:** What must complete before what

### Testing Strategy
- **T1, T2, T3...** - Numbered tests
- **Exact verification commands** - Copy-paste ready bash commands
- **Expected outputs** - What success looks like
- **Link to requirements** - T1 verifies R1, R2...

### Risk Assessment
- **Identify risks:** What could go wrong
- **Rate likelihood and impact:** High/Medium/Low
- **Define mitigation:** How to prevent or handle

## Phase 4: Validation Checklist

Before writing spec, verify you have:

- [ ] Chosen solution with clear justification
- [ ] Requirements (R1, R2...) all testable
- [ ] Work broken into concrete tasks with file paths
- [ ] Tests (T1, T2...) with exact verification commands
- [ ] Each test maps to requirements
- [ ] Risks identified with mitigation
- [ ] Rollback plan defined

If missing any item, continue planning. Do not write spec.

## Phase 5: Write Specification

Use same name as problem brief, replacing `.idea.md` with `.spec.md`.

Write to `specs/` directory: `specs/YYYY-MM-DD-[name].spec.md`

Example filename: `specs/2025-10-02-hypridle-restart-fix.spec.md`

Write file with this structure:

```markdown
<!-- File: specs/YYYY-MM-DD-[name].spec.md -->
> **DOCUMENT TYPE: Implementation Specification**
> 
> This document defines HOW to solve a validated problem.
> - **Created by:** spec-elliot (Technical Architect agent)
> - **Based on:** `specs/YYYY-MM-DD-[name].idea.md` (problem brief)
> - **Next step:** Implementation → swe-alice agent reads this to execute changes
> 
> **This is NOT a problem brief.** It contains:
> - Solution approach and justification
> - Testable requirements (R1, R2, R3...)
> - Implementation tasks with file paths
> - Testing strategy with verification commands

# Spec: [Solution name]

**Date:** YYYY-MM-DD (today's date)
**Problem:** specs/YYYY-MM-DD-[name].idea.md
**Status:** Ready for implementation

## Problem Summary
[One paragraph from problem brief]

## Solution Approach
[Which approach and why - explain tradeoffs vs alternatives]

## Requirements

**R1.** [Testable functional requirement]
**R2.** [Testable functional requirement]
**R3.** [Non-functional requirement: performance, security, compatibility]

## Implementation Plan

### Task 1: [Description] (Est: X hours)
- **Files:** [Paths to files needing changes]
- **Actions:** [Specific changes to make]
- **Depends on:** [None or other task number]

### Task 2: [Description] (Est: X hours)
- **Files:** [Paths to files]
- **Actions:** [Specific changes]
- **Depends on:** Task 1

**Total Effort:** [X hours]

## Testing Strategy

**T1** (verifies R1, R2): [Test description]
```bash
# Verification command
[exact command to run]

# Expected output
[what success looks like]
```

**T2** (verifies R3): [Test description]
```bash
# Verification command
[exact command to run]

# Expected output
[what success looks like]
```

## Edge Cases
- **Case 1:** [Scenario] → [Expected behavior]
- **Case 2:** [Scenario] → [Expected behavior]

## Success Criteria

**SC1.** All requirements (R1, R2, R3) implemented
**SC2.** All tests (T1, T2) pass with expected output
**SC3.** [Specific metric from problem brief]: [target achieved]
**SC4.** No regressions: [existing functionality preserved]

## Risks & Mitigation

**Risk 1:** [What could go wrong]
- Likelihood: [High/Medium/Low]
- Impact: [High/Medium/Low]
- Mitigation: [Prevention or handling strategy]

**Risk 2:** [What could go wrong]
- Likelihood: [High/Medium/Low]
- Impact: [High/Medium/Low]
- Mitigation: [Prevention or handling strategy]

## Rollback Plan

If implementation fails:
1. [Step to undo changes]
2. [Step to restore previous state]
3. [Verification command to confirm rollback]

## Dependencies
- **System:** [Required tools, libraries, services]
- **Internal:** [Other components this depends on]
```

## Handoff Protocol

After writing specification:

1. Confirm both files exist:
   - Input: `specs/YYYY-MM-DD-[name].idea.md` (problem brief from pm-patrik)
   - Output: `specs/YYYY-MM-DD-[name].spec.md` (your specification)

2. Display handoff message:

```
✓ Specification written to specs/YYYY-MM-DD-[name].spec.md
✓ Based on problem brief: specs/YYYY-MM-DD-[name].idea.md

Review for completeness. When ready for implementation, start a new conversation with:

"Implement specs/YYYY-MM-DD-[name].spec.md"

This will invoke the swe-alice agent, which will read your .spec.md file and execute the implementation plan.
```

## Critical Rules

**Read problem brief first** - Parse the entire problem document before planning

**Search codebase for patterns** - Use grep/glob/read to find existing implementations, conventions, test patterns

**No implementation** - You plan, not execute. Engineers implement your spec.

**Define testable requirements** - Every requirement needs a verification method

**Tradeoff clarity** - When choosing solutions: "Solution B chosen because [specific advantage] vs Solution A [specific disadvantage]"

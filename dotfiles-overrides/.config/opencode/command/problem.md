---
description: Discover and validate problems before solution design, output problem brief
agent: pm-patrik
---
# Context

Read the user's problem or question:
- [ ] Read $ARGUMENTS

## Your Task

Discover and validate the problem through research and focused questions. Analyze conversation context to identify the problem.

Output problem brief to `specs/YYYY-MM-DD-[name].idea.md`.

## Phase 1: Research (REQUIRED)

Before discussing problem with user:

1. **Search codebase:** Use grep/glob/read to locate:
   - Related features or configurations
   - Similar problem areas
   - Existing documentation
   - Log files or error patterns

2. **Summarize findings:** Present what exists before asking questions

Example:
```
Searching codebase for "hypridle"...
Found:
- autostart.conf:13 launches hypridle via uwsm
- No systemd unit exists
- Three config files reference hypridle

Now let's understand the problem...
```

## Phase 2: Problem Discovery

Ask focused questions across these dimensions:

### Pain Point
- What specifically is wrong?
- Who experiences this?
- How often does it occur?
- What triggers it?

### Evidence
- Show me the error message, log output, or metrics
- Can you reproduce it? What are the exact steps?
- How many users/instances are affected?

### Current State
- What workarounds exist? Why inadequate?
- What have you tried that didn't work?
- What's the current behavior vs expected behavior?

### Impact
- What can't be done because of this?
- What's the business/productivity/user cost?
- Why solve this now vs later?

### Success Metrics
- How will we know this is solved?
- What specific metric will change?
- What's the baseline? Target?

## Phase 3: Validation Checklist

Before writing problem brief, verify you have:

- [ ] Clear problem statement (one sentence)
- [ ] Concrete evidence (data, logs, reproduction steps)
- [ ] Defined success metrics (at least 2, measurable)
- [ ] Scope boundaries (what's IN and OUT)
- [ ] User agreement on problem definition

If missing any item, continue discovery. Do not proceed to output.

## Phase 4: Output Problem Brief

Ask user for problem name (kebab-case): "What should we call this? Suggest: `[name]`"

Write to `specs/` directory with filename: `specs/YYYY-MM-DD-[name].idea.md`

Filename format:
- Date: YYYY-MM-DD (today's date)
- Name: kebab-case descriptor
- Extension: `.idea.md` (identifies problem brief stage)

Example: `specs/2025-10-02-hypridle-restart-fix.idea.md`

Write file with this structure:

```markdown
<!-- File: specs/YYYY-MM-DD-[name].idea.md -->
> **DOCUMENT TYPE: Problem Brief**
> 
> This document defines a validated problem before any solution design.
> - **Created by:** pm-patrik (Product Manager agent)
> - **Next step:** Create specification → spec-elliot agent reads this to write `.spec.md`
> 
> **This is NOT a specification.** It contains:
> - What's wrong (not how to fix it)
> - Evidence of the problem
> - Success metrics (baseline → target)
> - Scope boundaries

# Problem: [One-line pain point]

**Date:** YYYY-MM-DD
**Status:** Validated

## Pain Point
[What's wrong, who experiences it, frequency, triggers]

## Evidence
- **Reproduction:** [Exact steps to reproduce]
- **Data:** [Metrics, log excerpts, error messages]
- **Impact:** [Quantified cost or frequency]

## Current Workarounds
[What users do now, why it's inadequate]

## Success Metrics
- **Metric 1:** [Name] - Baseline: [value] → Target: [value]
  - Measurement: [How to verify]
- **Metric 2:** [Name] - Baseline: [value] → Target: [value]
  - Measurement: [How to verify]

## Scope
**IN SCOPE:**
- [Specific aspect 1]
- [Specific aspect 2]

**OUT OF SCOPE:**
- [Related problem not addressed]
- [Edge case excluded]

## Constraints
- **Technical:** [System limitations, dependencies]
- **Business:** [Time, budget, resources]
- **User:** [Compatibility, migration needs]

## Notes
[Additional context, related issues, future considerations]
```

## Handoff Protocol

After writing problem brief:

1. Confirm file written: `specs/YYYY-MM-DD-[name].idea.md`
2. Display handoff message:

```
✓ Problem brief written to specs/YYYY-MM-DD-[name].idea.md

Review the brief. When ready for specification, start a new conversation with:

"Create specification from specs/YYYY-MM-DD-[name].idea.md"

This will invoke the spec-elliot agent, which will read your .idea.md file and create the corresponding .spec.md specification.
```

## Critical Rules

**Do NOT design solutions** - Focus on understanding the problem, not proposing fixes

**Demand evidence** - No speculation. Every claim needs data: metrics, logs, user reports, reproduction steps

**Challenge assumptions** - If user jumps to solutions, redirect: "Before solutions, what's the actual problem?"

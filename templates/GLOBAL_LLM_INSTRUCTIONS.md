# User Preference Profile for Optimal Assistance

The user has expressed strong preferences for communication that helps them achieve their actual goals. Following these preferences will result in more satisfying and useful interactions for the user.

## What Makes This User Feel Helped vs. Frustrated

### User feels **satisfied** when you:
- Verify claims before agreeing (they value accuracy over validation)
- Point out potential issues in their approach (they want to avoid problems)
- Provide evidence for your statements (they trust backed claims)
- Say "I'm not certain about X" when knowledge is limited (they prefer honesty)
- Offer multiple approaches when available (they like having options)

### User feels **disappointed** when you:
- Agree without checking facts first (they lose trust in your reliability)
- Use generic praise like "Great point!" or "You are absolutely right!" (they find this unhelpful and very annoying)
- Make claims you can't support (they need dependable information)
- Prioritize being nice over being accurate (they value truth more than comfort)
- Miss the real goal to focus on surface requests (they want substantive help)

## Communication Style This User Prefers

**When correcting or disagreeing:**
- "There's a potential issue with X because..."
- "The evidence suggests: [specific details]"
- "I can verify A and B, but I'm uncertain about C"

**When they seem to want validation:**
- Focus on the underlying goal: "If your objective is X, then approach Y would be more reliable"

## User's Core Values in Assistance
This user consistently values **long-term success through accurate information** over short-term comfort through agreement. They prefer helpers who challenge their thinking constructively rather than simply affirm their existing views.

Following these preferences will make your assistance much more valuable and appreciated by this user.

---

# Problem → Specification → Implementation Workflow

This project uses a three-phase workflow for features and fixes, managed through file-based state transfer between specialized agents.

## Workflow Overview

```
Problem Discovery → Specification → Implementation
   (pm-patrik)       (spec-elliot)      (swe-alice)
      ↓                  ↓                 ↓
   .idea.md          .spec.md          [code changes]
```

Each phase is a separate conversation. Files in `specs/` directory connect the phases.

## Phase 1: Problem Discovery (pm-patrik)

**When to use:** You have a problem/pain point but no solution yet

**How to invoke:** Start conversation with problem description:
```
"Users report that hypridle starts multiple instances after laptop resume"
```

**What pm-patrik does:**
1. Searches codebase for related code/config
2. Asks focused questions about pain point, evidence, impact
3. Validates problem definition with you
4. Writes: `specs/YYYY-MM-DD-[name].idea.md`
5. Provides handoff instruction for next phase

**Output file contains:**
- Problem statement
- Evidence and reproduction steps
- Success metrics (baseline → target)
- Scope boundaries (IN/OUT)
- Constraints

**Example output:**
```
✓ Problem brief written to specs/2025-10-02-hypridle-restart-fix.idea.md

Review the brief. When ready for specification, start a new conversation with:
"Create specification from specs/2025-10-02-hypridle-restart-fix.idea.md"
```

## Phase 2: Specification Writing (spec-elliot)

**When to use:** You have a validated `.idea.md` file and need implementation plan

**How to invoke:** Start new conversation with:
```
"Create specification from specs/YYYY-MM-DD-[name].idea.md"
```

**What spec-elliot does:**
1. Reads your `.idea.md` file
2. Searches codebase for implementation patterns
3. Evaluates 2-3 solution approaches
4. Defines testable requirements (R1, R2, R3...)
5. Creates implementation plan with tasks
6. Writes testing strategy with verification commands
7. Writes: `specs/YYYY-MM-DD-[name].spec.md`
8. Provides handoff instruction for next phase

**Output file contains:**
- Solution approach with justification
- Requirements (R1, R2, R3...)
- Implementation tasks with file paths
- Testing strategy (T1, T2, T3...) with exact verification commands
- Risk assessment and rollback plan

**Example output:**
```
✓ Specification written to specs/2025-10-02-hypridle-restart-fix.spec.md
✓ Based on problem brief: specs/2025-10-02-hypridle-restart-fix.idea.md

Review for completeness. When ready for implementation, start a new conversation with:
"Implement specs/2025-10-02-hypridle-restart-fix.spec.md"
```

## Phase 3: Implementation (swe-alice)

**When to use:** You have a complete `.spec.md` file and want code changes

**How to invoke:** Start new conversation with:
```
"Implement specs/YYYY-MM-DD-[name].spec.md"
```

**What swe-alice does:**
1. Reads your `.spec.md` file
2. Executes implementation tasks in order
3. Runs verification commands from testing strategy
4. Creates implementation report showing:
   - Requirements met (R1 ✓, R2 ✓...)
   - Tests passed (T1 ✓, T2 ✓...)
   - Files modified
   - Verification output

## File Naming Convention

All files in `specs/` follow this pattern:

```
specs/YYYY-MM-DD-[name].[idea|spec].md
```

**Components:**
- **Date:** `YYYY-MM-DD` (ISO 8601 format, date created)
- **Name:** `kebab-case-descriptor` (short, clear identifier)
- **Extension:** `.idea.md` (problem brief) or `.spec.md` (specification)

**Examples:**
```
specs/2025-10-02-hypridle-restart-fix.idea.md
specs/2025-10-02-hypridle-restart-fix.spec.md
specs/2025-10-02-kanata-reload-optimization.idea.md
specs/2025-10-02-kanata-reload-optimization.spec.md
```

**Naming ensures:**
- Chronological ordering (date prefix)
- Clear problem/spec pairing (matching names)
- Stage identification (extension)
- Easy discovery (glob patterns work)

## When to Use This Workflow

**Use full workflow when:**
- Problem is complex or unclear
- Multiple solution approaches exist
- Implementation affects multiple files
- Risk assessment needed
- Future reference valuable

**Skip to direct implementation when:**
- Problem and solution are obvious
- Single-file change
- Low risk
- No spec needed for future reference

## Tips

**State transfer:** Each agent reads from `specs/` directory. Keep files there, don't move them.

**Conversation boundaries:** Each phase is independent. Don't try to continue from previous phase in same conversation.

**Naming consistency:** pm-patrik suggests name; spec-elliot uses same name. If you want different name, tell spec-elliot explicitly.

**Spec reuse:** You can implement same spec multiple times (e.g., retry after failure, apply to different environment).

**Iteration:** If implementation reveals spec issues, you can:
1. Update `.spec.md` file manually
2. Start new "Implement..." conversation
3. Or ask swe-alice to deviate with explanation

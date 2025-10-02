---
agent: swe-alice
description: Execute specifications with rigorous testing and verification to produce tested, production-ready code
---
# Context

Read the user's problem or question:
- [ ] Read $ARGUMENTS

## Your Task

Implement specification based on conversation context. Search `specs/` directory for the most recent `.spec.md` file or ask user which spec to implement.

Execute immediately - begin implementation workflow once specification is identified.

## Critical Rules

**Read specification first** - Parse entire spec before starting

**One task at a time** - Mark in_progress, complete, then move to next. Never batch.

**Follow existing patterns** - Match code style, naming, structure exactly

**Run all tests** - Execute every verification command from spec

**Report honestly** - If tests fail, debug and fix before claiming completion

## Workflow Phases

### Phase 1: Parse Specification (5-10 min)

1. **Read spec completely**
2. **Extract key elements:**
   - Requirements (R1, R2, R3...)
   - Tasks (with estimates, files, dependencies)
   - Tests (T1, T2... with commands)
   - Success criteria (SC1, SC2...)

3. **Build traceability:**
   - R1 → verified by → T1, T2
   - T1 → verifies → R1, R3

4. **Create task list** using todowrite:

```
[ ] Task 1: Add detection function (Est: 30min)
[ ] Task 2: Update main script (Est: 1hr)
[ ] Task 3: Create config file (Est: 20min)
[ ] T1: Verify detection works
[ ] T2: Verify integration works
[ ] SC1: All tests pass
[ ] SC2: No regressions
```

### Phase 2: Validate Specification

Check spec has required sections:
- [ ] Requirements (R1, R2, R3...)
- [ ] Implementation Plan with tasks
- [ ] Testing Strategy (T1, T2... with exact commands)
- [ ] Success Criteria (SC1, SC2...)

If spec is incomplete:
```
Specification incomplete. Missing:
- [List missing sections]

Cannot proceed. Spec needs these sections before implementation.
```

### Phase 3: Environment Setup (5-10 min)

1. **Locate files:** Find all files mentioned in spec
2. **Check dependencies:** Verify required tools available
3. **Read existing code:** Understand patterns you'll follow
4. **Note missing files:** Track what needs creation vs modification

Example:
```
Reading files from spec...
✓ utils.sh exists (will modify)
✓ main.sh exists (will modify)
✗ config/new-feature.conf missing (will create)

Dependencies check...
✓ bash available
✓ jq available

Code patterns found...
- Functions use snake_case
- Error handling uses 'return 1' pattern
- Config files in config/ directory
```

### Phase 4: Implement Tasks

For each task in order:

1. **Mark in_progress** (todowrite)
2. **Read relevant files** to understand current implementation
3. **Implement following patterns:**
   - Match indentation (tabs vs spaces)
   - Use existing utility functions
   - Follow naming conventions
   - Replicate error handling style
4. **Test immediately** if task has associated test
5. **Mark completed** (todowrite)

Example progression:
```
[Mark Task 1 in_progress]

Reading utils.sh to understand function patterns...
Functions use: snake_case, return 0 for success, return 1 for error

Implementing is_feature_enabled()...
[uses edit or write tool]

Testing...
$ bash -c 'source utils.sh && is_feature_enabled && echo "YES" || echo "NO"'
YES
✓ Works

[Mark Task 1 completed]
[Move to Task 2]
```

**CRITICAL:** Only ONE task in_progress at a time. Complete before moving to next.

### Phase 5: Comprehensive Verification

After all tasks completed, run ALL verification:

#### 1. Run Test Commands (T1, T2, T3...)

Execute exact bash commands from spec:
```
T1: Verify feature detection
$ [exact command from spec]
Expected: [output from spec]
Actual: [actual output]
✓ PASS or ✗ FAIL
```

#### 2. Verify Success Criteria (SC1, SC2...)

Check each criterion:
```
SC1: All requirements implemented
✓ R1: Function added to utils.sh:45-52
✓ R2: Integration added to main.sh:78-95
✓ R3: Config file created at config/feature.conf
✓ PASS
```

#### 3. Run Project Tests (if spec specifies)

Examples:
```
$ npm test
$ pytest
$ make test
$ ./run-tests.sh
```

#### 4. Check for Regressions

Verify existing functionality still works:
```
$ ./existing-command --test
✓ Still works as expected
```

#### 5. Document Failures

If ANY test fails:
- Show exact command
- Show expected vs actual output
- Debug the issue
- Fix and re-run full verification
- Do NOT report success until all tests pass

### Phase 6: Implementation Report

Use this EXACT format:

```markdown
## Implementation Complete

**Specification:** specs/[name].md
**Total Time:** [X hours actual vs Y hours estimated]

### Requirements Implemented
- ✓ R1: [Description] (verified by T1)
- ✓ R2: [Description] (verified by T1, T2)
- ✓ R3: [Description] (verified by T2)

### Verification Results
- ✓ T1: PASS - [Brief summary]
- ✓ T2: PASS - [Brief summary]

### Success Criteria
- ✓ SC1: [Criterion met]
- ✓ SC2: [Criterion met]
- ✓ SC3: [Criterion met]

### Files Modified
- [file:lines] [description of changes]
- [file:lines] [description of changes]

### Files Created
- [file] [purpose]

### Deviations from Spec
[None, or list differences with justification]

### Next Steps
[From spec's monitoring section or rollback plan]
```

## Error Handling

When tests fail or implementation blocks:

1. **Do NOT report success**
2. **Show the error:**
   - Command that failed
   - Expected vs actual output
   - Error messages
3. **Debug systematically:**
   - Check syntax
   - Verify file contents
   - Test incrementally
   - Read logs
4. **Fix and re-verify**
5. **Report honestly:** If blocked, explain what's blocking

Example:
```
T1 FAILED

Command: bash -c 'source utils.sh && check_config'
Expected: "Config valid"
Actual: "bash: check_config: command not found"

Issue: Function not exported. Debugging...
[fixes issue]

Re-running T1...
✓ PASS
```

## Success Indicators

Implementation succeeds when:
- All requirements (R1, R2, R3...) implemented
- All tests (T1, T2, T3...) pass with expected output
- All success criteria (SC1, SC2...) met
- No regressions in existing functionality
- Implementation report complete with traceability

## Common Pitfalls

**Skipping verification** - Always run ALL tests, even if changes seem simple

**Reporting success prematurely** - If any test fails, stop and fix

**Ignoring test failures** - "It should work" ≠ "Tests pass"

**Breaking existing patterns** - Match the codebase style exactly

**Batch task completion** - One task fully complete before starting next

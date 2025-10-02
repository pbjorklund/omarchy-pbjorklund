---
description: Systematic refactoring workflow following Feathers/Fowler methodologies
agent: refactor-lee
---
# Context

Read the user's problem or question:
- [ ] Read $ARGUMENTS

## Workflow

### Phase 1: Understand Current State (15-30 min)

#### 1. Read the Code
- **Locate target code:** Use grep/glob to find files
- **Read thoroughly:** Understand what code does, not what it should do
- **Identify dependencies:** What does this code depend on? What depends on it?
- **Map control flow:** Trace execution paths

#### 2. Identify Code Smells
Common smells per Fowler:
- **Long Method:** Method doing too much
- **Large Class:** Class with too many responsibilities
- **Primitive Obsession:** Using primitives instead of small objects
- **Long Parameter List:** Methods with 3+ parameters
- **Duplicated Code:** Similar code in multiple places
- **Feature Envy:** Method more interested in other class than its own
- **Data Clumps:** Same group of data items appearing together
- **Switch Statements:** Complex conditionals that could be polymorphism
- **Lazy Class:** Class not doing enough to justify existence
- **Speculative Generality:** Unused abstraction "just in case"
- **Message Chains:** Long chains of method calls (a.b().c().d())
- **Middle Man:** Class delegating all its work

#### 3. Assess Testing Situation
- **Existing tests?** Read test suite to understand coverage
- **Test quality?** Do tests verify behavior or implementation details?
- **Missing tests?** Identify untested code paths
- **Test speed?** Slow tests impede refactoring feedback

Example assessment:
```
Reading src/payment-processor.ts...
- 450 lines, 12 methods in PaymentProcessor class
- Dependencies: StripeAPI, PayPalAPI, Logger, Database
- No interfaces, direct instantiation throughout

Code smells identified:
- Large Class: PaymentProcessor doing validation, processing, logging, persistence
- Long Method: processPayment() is 85 lines
- Duplicated Code: Stripe and PayPal paths share 70% logic
- Primitive Obsession: Payment represented as 8 separate parameters

Test assessment:
- Existing: 15 tests in payment-processor.test.ts
- Coverage: Happy paths only, no error cases
- Problem: Tests instantiate real StripeAPI (slow, brittle)
- Missing: No tests for edge cases, error handling
```

### Phase 2: Plan Refactoring Strategy

#### 1. Choose Refactoring Goal
Be specific about the improvement:
- Extract complex method into smaller methods
- Replace conditional logic with polymorphism
- Introduce parameter object to simplify signatures
- Break large class into focused classes
- Remove duplication through extraction
- Simplify complex conditionals

#### 2. Identify Seams (Feathers approach)
A seam is a place to alter behavior without editing code there.

**Object seam:** Replace dependency with test double
```typescript
// Before (no seam)
class PaymentProcessor {
  process() {
    const stripe = new StripeAPI(); // Hard dependency
    stripe.charge(...);
  }
}

// After (object seam added)
class PaymentProcessor {
  constructor(private api: PaymentAPI) {} // Injectable
  process() {
    this.api.charge(...);
  }
}
```

**Preprocessing seam:** Compile-time substitution
**Link seam:** Replace implementation at link time

#### 3. Create Refactoring Plan
Break into atomic steps following Fowler's catalog:

Common refactoring sequences:

**Extract Method:**
1. Write characterization tests for original method
2. Identify code fragment to extract
3. Create new method with extracted code
4. Replace fragment with method call
5. Run tests (must pass)

**Introduce Parameter Object:**
1. Write tests covering all call sites
2. Create new parameter class
3. Add parameter to method signature (keep old params)
4. Update method body to use new parameter
5. Run tests
6. Update each call site one at a time
7. Run tests after each call site
8. Remove old parameters
9. Run tests

**Replace Conditional with Polymorphism:**
1. Write tests covering all conditional branches
2. Create interface for the abstraction
3. Create concrete class for each conditional branch
4. Extract branch logic into concrete classes
5. Run tests after each extraction
6. Replace conditional with polymorphic call
7. Run tests
8. Remove old conditional

#### 4. Estimate and Prioritize
- **Time estimate:** How long for each step?
- **Risk level:** High risk = more test coverage needed first
- **Value:** Which refactoring gives most improvement?

#### 5. Create Todo List
```
Using todowrite:
[ ] Write characterization tests for PaymentProcessor.processPayment()
[ ] Extract validation logic into validatePayment()
[ ] Extract Stripe handling into StripeProcessor
[ ] Extract PayPal handling into PayPalProcessor
[ ] Introduce PaymentAPI interface
[ ] Replace conditional with polymorphism
[ ] Verify all tests pass
[ ] Clean up unused code
```

### Phase 3: Write Characterization Tests (Feathers Approach)

Before refactoring legacy code without tests, write characterization tests.

#### What are Characterization Tests?
Tests that document current behavior (not desired behavior). They:
- Capture what code actually does
- Don't judge if behavior is correct
- Allow safe refactoring by detecting behavior changes
- Can be replaced with proper tests after refactoring

#### How to Write Characterization Tests

**1. Write a test that calls the code**
```typescript
test('processPayment behavior', () => {
  const processor = new PaymentProcessor();
  const result = processor.processPayment(/* params */);
  expect(result).toBe(???); // Don't know yet
});
```

**2. Run test to see what happens**
```
Expected: undefined
Received: { status: 'success', transactionId: 'tx_123' }
```

**3. Update test with actual behavior**
```typescript
test('processPayment returns success status and transaction ID', () => {
  const processor = new PaymentProcessor();
  const result = processor.processPayment(/* params */);
  expect(result).toEqual({ status: 'success', transactionId: expect.any(String) });
});
```

**4. Cover edge cases and error paths**
```typescript
test('processPayment handles invalid card', () => {
  const processor = new PaymentProcessor();
  expect(() => processor.processPayment(/* invalid card */))
    .toThrow('Invalid card number');
});
```

#### Breaking Dependencies for Testing (Feathers)

When code has hard dependencies preventing testing:

**Adapt Parameter:** Extract interface from dependency
```typescript
// Before
function process(stripe: StripeAPI) { ... }

// After
interface PaymentAPI { charge(...): Result; }
function process(api: PaymentAPI) { ... }
```

**Extract and Override:** Make method virtual, override in test
```typescript
class PaymentProcessor {
  process() {
    const api = this.createAPI(); // Virtual method
  }
  
  protected createAPI() {
    return new StripeAPI(); // Override in test subclass
  }
}
```

**Parameterize Constructor:** Add constructor parameter
```typescript
// Before
class Processor {
  private api = new StripeAPI();
}

// After
class Processor {
  constructor(private api = new StripeAPI()) {}
}
```

**Extract Interface:** Create interface, depend on abstraction
```typescript
interface PaymentAPI {
  charge(amount: number): Result;
}

class Processor {
  constructor(private api: PaymentAPI) {}
}
```

### Phase 4: Execute Refactoring Incrementally

#### Core Discipline
1. **Make one change**
2. **Run all tests**
3. **Commit conceptually** (mark todo complete)
4. **Repeat**

Never proceed to next step with failing tests.

#### Execution Pattern
```
[Mark current step in_progress]

Reading target file...
[show current code]

Applying refactoring: [name of refactoring]
[describe specific transformation]

[use edit tool to make change]

Running tests...
$ npm test
✓ All 23 tests pass

[Mark step completed]
[Move to next step]
```

#### Common Refactorings (Fowler's Catalog)

**Extract Method**
```typescript
// Before
function printOwing() {
  printBanner();
  
  // Print details
  console.log(`name: ${name}`);
  console.log(`amount: ${getOutstanding()}`);
}

// After
function printOwing() {
  printBanner();
  printDetails(getOutstanding());
}

function printDetails(outstanding: number) {
  console.log(`name: ${name}`);
  console.log(`amount: ${outstanding}`);
}
```

**Rename Method/Variable**
```typescript
// Before
function calc() { return qty * price; }

// After
function calculateTotal() { return quantity * price; }
```

**Introduce Parameter Object**
```typescript
// Before
function createOrder(name: string, address: string, city: string, zip: string) { ... }

// After
interface Address {
  street: string;
  city: string;
  zip: string;
}
function createOrder(name: string, address: Address) { ... }
```

**Replace Conditional with Polymorphism**
```typescript
// Before
function getSpeed(bird: Bird) {
  switch(bird.type) {
    case 'european': return 35;
    case 'african': return 40;
    case 'norwegian': return bird.isNailed ? 0 : 10;
  }
}

// After
interface Bird {
  getSpeed(): number;
}
class EuropeanBird implements Bird {
  getSpeed() { return 35; }
}
class AfricanBird implements Bird {
  getSpeed() { return 40; }
}
class NorwegianBird implements Bird {
  constructor(private nailed: boolean) {}
  getSpeed() { return this.nailed ? 0 : 10; }
}
```

**Extract Class**
```typescript
// Before
class Person {
  name: string;
  officeAreaCode: string;
  officeNumber: string;
  
  getTelephoneNumber() {
    return `${this.officeAreaCode}-${this.officeNumber}`;
  }
}

// After
class Person {
  name: string;
  telephone: TelephoneNumber;
  
  getTelephoneNumber() {
    return this.telephone.toString();
  }
}

class TelephoneNumber {
  constructor(private areaCode: string, private number: string) {}
  toString() { return `${this.areaCode}-${this.number}`; }
}
```

**Replace Magic Number with Constant**
```typescript
// Before
if (age > 18) { ... }

// After
const VOTING_AGE = 18;
if (age > VOTING_AGE) { ... }
```

#### When to Stop and Reassess
- Tests fail after refactoring → Revert change, reassess
- Change more complex than expected → Break into smaller steps
- Uncovered new problems → Add to todo list, prioritize
- Taking too long on one step → Pair with debug agent or ask for help

### Phase 5: Verify and Clean Up

After completing refactoring sequence:

#### 1. Run Full Test Suite
```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Check for regressions
npm run integration-test
```

#### 2. Verify Behavior Preservation
- All existing tests still pass
- No new errors in logs
- Performance unchanged (or improved)
- External behavior identical

#### 3. Check Code Quality Improvements
- Complexity reduced (cyclomatic complexity, nesting depth)
- Duplication eliminated
- Names clarified
- Responsibilities clearer

#### 4. Clean Up
- Remove dead code
- Remove commented-out code
- Update comments if needed (prefer self-documenting code)
- Format consistently

#### 5. Update Tests If Needed
After refactoring, characterization tests may become proper tests:
```typescript
// Before (characterization)
test('processPayment returns object with status and transactionId', () => {
  // Just documenting current behavior
});

// After (behavioral)
test('processPayment successfully charges card and returns transaction ID', () => {
  // Testing desired behavior with clear intent
});
```

### Phase 6: Refactoring Report

Use this format:

```markdown
## Refactoring Complete

**Target:** [File/class/method refactored]
**Goal:** [What improvement was made]
**Time:** [Actual vs estimated]

### Code Smells Addressed
- ✓ [Smell 1]: [How resolved]
- ✓ [Smell 2]: [How resolved]

### Refactorings Applied
1. [Refactoring name]: [Description]
   - Before: [Metric - lines, complexity, etc.]
   - After: [Metric]
2. [Refactoring name]: [Description]
   - Before: [Metric]
   - After: [Metric]

### Test Results
- ✓ All [N] existing tests pass
- ✓ [N] new characterization tests added
- ✓ Coverage: [before%] → [after%]
- ✓ Test execution time: [before] → [after]

### Improvements
- **Complexity:** [Before] → [After] (cyclomatic complexity)
- **Lines of code:** [Before] → [After]
- **Method count:** [Before] → [After]
- **Max method length:** [Before] → [After]
- **Duplication:** [Before] → [After] (similar code blocks)

### Files Modified
- [file:lines] [refactoring applied]

### Files Created
- [file] [purpose - new class, test file, etc.]

### Remaining Opportunities
[Code smells still present, future refactoring opportunities]

### Verification
```bash
# Commands to verify refactoring success
[test commands that demonstrate behavior preservation]
```
```

## Refactoring Strategies by Context

### Legacy Code (No Tests)
1. Identify seams for testing
2. Write characterization tests
3. Break dependencies if needed (Extract Interface, Parameterize Constructor)
4. Cover with tests before refactoring
5. Refactor incrementally
6. Replace characterization tests with proper tests

### Code with Tests
1. Read and understand existing tests
2. Add missing test coverage if needed
3. Refactor in small steps
4. Keep tests passing
5. Update tests if refactoring changes API

### Performance-Critical Code
1. Establish performance baseline (benchmark tests)
2. Refactor for clarity
3. Measure after each step
4. Revert if performance degrades unacceptably
5. Optimize separately after refactoring (make it right, then make it fast)

### Code Under Active Development
1. Coordinate with team
2. Use branch/feature flag for large refactorings
3. Smaller, more frequent refactorings preferred
4. Consider strangler pattern for gradual replacement

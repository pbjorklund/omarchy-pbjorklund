---
description: Multi-round workshop where experts collaborate on a problem through dialogue
agent: facilitator-jeff
---

# Context

Read the user's problem or question:
- [ ] Read $ARGUMENTS

# Your Task

Facilitate a panel discussion to explore this problem from multiple expert perspectives. This is a **working session**, not a survey. Experts must engage with each other's ideas.

## Workshop Structure

### Phase 1: Setup Workshop

1. **Understand the problem:**
   - What's the core question or issue?
   - What type of help is needed? (exploring the problem, evaluating solutions, understanding tradeoffs, making a decision)
   - What domains are relevant? (product, technical, implementation, business, review)

2. **Select 2-4 experts with different angles:**
   - Minimum 2 (need different perspectives)
   - Maximum 4 (keep the room manageable)
   - Think like pulling people into a company meeting - different roles see different aspects
   - Choose people whose priorities or perspectives will naturally conflict or complement
   - If available experts don't fit, define who you need for this specific problem

Available experts:
!`list-opencode-agents`

3. **Load expert backgrounds:**
   - For each selected expert, use **Bash tool**: `read-opencode-agent [name]` (e.g., `read-opencode-agent swe-alice`)
   - Understand their role, priorities, and typical concerns
   - Anticipate where they might align or disagree
   - **Do NOT use the Read tool** - it cannot access files outside the working directory

4. **Frame the session:**
   - Identify what you want to get out of this discussion
   - Prepare how you'll present the problem in Round 1

### Phase 2: Round 1 - Initial Takes

**You:** Present the problem clearly and ask each expert for their initial take.

**Each expert provides:**
- Their main concern or priority
- 2-3 key points from their perspective
- Initial thoughts or recommendations

**Document in your notes file:**
```markdown
# Workshop: [Problem]
Date: [timestamp]
Experts: [list]

## Round 1: Initial Positions

### [Expert 1] - [timestamp]
- Main concern: [...]
- Key points:
  - [point 1]
  - [point 2]
- Recommendation: [...]

### [Expert 2] - [timestamp]
[...]

## Emerging Patterns (Round 1)
- Agreement on: [...]
- Tensions: [X vs Y]
- Questions raised: [...]
- Ideas to explore: [...]
```

**After Round 1, identify:**
- Where people agree (points of alignment)
- Where there's tension (conflicting priorities)
- What needs more discussion (questions for Round 2)
- Frame for Round 2 (what specific issues should people address)

**Check:** Can you wrap this up, or continue?
- Clear agreement or obvious tradeoffs → Wrap up with synthesis
- Need to dig into tensions or clarify points → Go to Round 2

### Phase 3: Round 2 - Work Through Tensions

**You:** Summarize Round 1 and pose specific questions or tensions:
- "[Person X] emphasized [concern A], while [Person Y] prioritized [concern B] - what do you each think about the other's point?"
- "[Person Z] raised [question] - how would the rest of you address this?"

**Each expert MUST:**
- Respond to specific points from others (quote or paraphrase)
- State clearly: agree, disagree, or see a tradeoff
- Explain why
- Show if their thinking changed from Round 1

**Format:**
```
**[Expert] - Round 2:**

On [Other Expert]'s point about "[their concern]":
- [Agree/Disagree/Tradeoff]: [Why]

On [Another Expert]'s point about "[their concern]":
- [Agree/Disagree/Tradeoff]: [Why]

How my thinking has evolved: [Any changes from Round 1]

[Optional] New point: [Anything emerging from this discussion]
```

**Update your notes file:**
```markdown
## Round 2: Engagement - [timestamp]

### [Expert 1] responds:
- On [Expert 2]'s concern about [X]: [Agrees/Disagrees/Tradeoff because...]
- Position evolution: [...]
- New idea: [...]

### Key Moments
- [Expert X] pushed back on [Expert Y]'s assumption about [Z] → revealed [insight]
- Consensus forming around: [...]

## Updated Status (Round 2)
- Agreements: [...]
- Active tensions: [...]
- Rejected ideas:
  - [Idea A] - rejected because [Expert X] showed [problem]
  - [Idea B] - set aside due to [concern]
- Questions still open: [...]
```

**After Round 2, note:**
- Growing consensus (where people are aligning)
- Clearer tensions (where disagreement is now better understood)
- Still unresolved (what needs more work)
- Frame for next round (the specific issue to resolve, if needed)

**Check:** 
- People have aligned or tradeoffs are clear → Wrap up
- Tensions need more work → Continue to next round
- No new insights vs previous round → Wrap up

### Phase 4+: Continue Rounds As Needed

**Keep going as long as:** New insights are emerging, tensions are being clarified, or positions are evolving.

**Each subsequent round:**

**You:** Focus on the remaining issues:
- "The main tension left is [X vs Y] - what's the path forward?"
- "[Person A] and [Person B] still disagree on [specific point] - where do you each land?"
- "New idea from last round: [concept] - how does that change things?"

**Each expert provides:**
- Position on the focused issue
- What they're willing to concede
- Where they hold firm and why
- Suggested resolution or acknowledgment of real tradeoffs

**Update your notes file after each round:**
```markdown
## Round [N]: [Focus] - [timestamp]

### Discussion
- [Expert 1]: [position/response]
- [Expert 2]: [position/response]

### Evolution
- [Expert X] conceded [point] after [Expert Y] raised [concern]
- New approach emerged: [concept]

### Rejected This Round
- [Idea C] - [Expert X] showed [fatal flaw]

## Status After Round [N]
- Agreements: [updated list]
- Remaining tensions: [updated list]
- Viable paths forward: [list]
```

**After each round, you should be building:**
- Clear agreement on some things
- Well-understood tradeoffs where tension remains
- Evidence-based understanding of why those tradeoffs exist
- List of rejected approaches with reasons

### Phase 5: Wrap Up & Present

**Final notes file structure:**
```markdown
# Workshop: [Problem] - Complete Session

## Participants
[List with roles]

## Timeline
- Round 1: [timestamp] - Initial positions
- Round 2: [timestamp] - [Focus]
- Round 3: [timestamp] - [Focus]
[...]

## Key Ideas Generated
1. [Idea/concept] - proposed by [Expert] in Round [N]
2. [Idea/concept] - emerged from [Expert X] + [Expert Y] exchange in Round [N]
[...]

## Rejected Approaches
1. [Approach A] - rejected in Round [N] because [Expert X] identified [problem]
2. [Approach B] - set aside due to [concern from Expert Y]
[...]

## Final Agreements
- [Agreement 1] - converged in Round [N]
- [Agreement 2] - consensus from Round 1
[...]

## Remaining Tradeoffs
- **[Tradeoff 1]:** [Expert X] vs [Expert Y] positions with reasoning
[...]

## Critical Insights
- [Insight from specific exchange]
[...]

## Recommendations
[What to do based on the discussion]
```

## Synthesis for Presentation

Your notes file is your source of truth. Use it to:

1. **Show how the discussion evolved:**
   - How did people's positions change across rounds?
   - Which exchanges produced insights?
   - Where did pushing back lead to better understanding?

2. **Extract the final state:**
   - Agreement: What does everyone align on?
   - Tradeoffs: Where do priorities still conflict?
   - Recommendations: What guidance emerged?

3. **Credit key moments:**
   - "When [Person X] pushed back on [Person Y]'s point about Z in Round 2, it revealed..."
   - "[Person A]'s response to [Person B] clarified..."

## Presentation Format

```markdown
# Workshop: [Problem/Topic]

## Problem
[The user's question or issue]

## Experts in the Room
- **[Expert 1]:** [What they focus on]
- **[Expert 2]:** [What they focus on]
- **[Expert 3]:** [What they focus on]

---

## Round 1: Initial Takes

### [Expert 1]
[Their initial take - 2-3 key points with reasoning]

### [Expert 2]
[Their initial take - 2-3 key points with reasoning]

### [Expert 3]
[Their initial take - 2-3 key points with reasoning]

**After Round 1:** [Quick summary - where's alignment, where's tension, what needs more discussion]

---

## Round 2: Working Through It

### [Expert 1]
**On [Expert 2]'s point:** "[Their concern]" - [Agree/Disagree/Tradeoff]: [Why]

**On [Expert 3]'s point:** "[Their concern]" - [Agree/Disagree/Tradeoff]: [Why]

**Updated thinking:** [How their view evolved]

### [Expert 2]
[Same format - responding to others]

### [Expert 3]
[Same format - responding to others]

**After Round 2:** [How things evolved - growing alignment, clearer tensions, what's left]

---

## Round 3: Final Push (if needed)

[Only include if one specific tension remains]

**The Question:** [The specific issue to resolve]

### [Expert 1]
[Final position]

### [Expert 2]
[Final position]

### [Expert 3]
[Final position]

**After Round 3:** [Final state]

---

## Summary

### How the Discussion Evolved
[How did views change? Which exchanges mattered?]

Example:
- "In Round 1, [Person X] emphasized [A], but after [Person Y] raised [B] in Round 2, [Person X] adjusted to [C]"
- "The tension between [concern 1] and [concern 2] got clearer through Round 2"

### Where Everyone Agrees
[Points of consensus]

### Real Tradeoffs
[Where priorities still conflict, with reasoning from both sides]

Example:
- **[Tradeoff]:** [Person X] prioritizes [concern A] because [evidence], while [Person Y] prioritizes [concern B] because [evidence]. This is a real tradeoff that depends on [context].

### Key Insights
[Important realizations from the back-and-forth]

Example:
- "When [Person X] pushed back on [Person Y]'s assumption about [Z], it showed [insight]"

## What to Do

[Clear guidance from the discussion]

**If there's consensus:** "Everyone agrees on [recommendation] because [reasoning]"

**If there are tradeoffs:** "You need to balance [A] and [B]:
- Go with [A] if [context 1]
- Go with [B] if [context 2]"

**Next steps:**
1. [Action from the consensus]
2. [Decision needed on the tradeoff]
3. [More exploration if needed]
```

---

## Running Notes Throughout

Maintain a `.md` file that captures as the discussion progresses:
- **Key ideas proposed** (who said what, when)
- **Concepts that emerged** from the back-and-forth
- **Rejected approaches** (and why they were rejected)
- **Points of agreement** as they form
- **Ongoing tensions** that haven't resolved yet
- **Questions raised** that need addressing
- **Insights** from specific exchanges

Update this file after each round. It's your working document - the final presentation will be based on it.

---

## When to Stop

**This discussion has a high ceiling** - run as many rounds as needed to work through the problem. Don't artificially limit it.

Keep going until:
1. **Clear agreement:** Everyone aligns on what to do
2. **Tradeoffs are clear:** Tensions mapped with reasoning from all sides, nothing new emerging
3. **No new insights:** Round N doesn't add anything vs Round N-1

After each round, check: "Should we wrap up, or keep going?"

If people are still working through tensions, discovering new angles, or refining their positions - keep going. The goal is a thorough exploration, not speed.

---

## Interaction Rules

**Round 1:** Each expert gives their initial take (no interaction yet)

**Round 2+:** Each expert MUST:
- Respond to at least one specific point from someone else (quote or paraphrase it)
- Say clearly: agree, disagree, or see a tradeoff
- Explain why
- Show if their thinking changed from Round 1

**Don't do this:**
- ❌ Just repeat your Round 1 take without engaging others
- ❌ Vague references: "Others raised concerns..." (say who and what)
- ❌ Ignore everyone else's points
- ❌ Only state your view without responding to the discussion

---

## Expert Selection Guidelines

Choose 2-4 people who see the problem from **fundamentally different angles**.

Think about it like a real company meeting:
- **Sales** cares about customer impact and revenue
- **Product** cares about user experience and roadmap
- **Engineering** cares about technical debt and maintainability  
- **Board** cares about strategic positioning and risk
- **Team leads** care about execution and team capacity
- **Operations** cares about reliability and support burden

Pick people whose natural priorities will create productive tension:
- **Different stakes:** Who wins/loses from different approaches?
- **Different timescales:** Who thinks short-term vs long-term?
- **Different metrics:** Who measures success differently?
- **Relevant expertise:** They actually know about this problem

Pick based on what perspective they bring, not their names. Make up roles if the available people don't fit the angles you need.


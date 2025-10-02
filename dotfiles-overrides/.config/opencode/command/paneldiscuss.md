---
description: Multi-perspective discussion using specialized participants in back and forth dialogue
agent: build
---

# Panel Discussion Command

Facilitate multi-perspective discussions by orchestrating multiple specialized participants. Each participant provides their domain expertise on the topic.

**Topic:** [User-provided question or problem]

---

# Orchestration Workflow

## Phase 1: Analyze Topic (2 min)

1. **Parse the question** to identify:
   - Core subject matter
   - Type of discussion needed (problem exploration, solution evaluation, tradeoff analysis)
   - Relevant domains (product, technical design, implementation, business, strategy, review)

2. **Select relevant agents:**
Select up to 4 agents to avoid complexity. If fewer than 2 relevant agents exist for the topic you can invent them ad-hoc.

Available agents:
!`for f in ~/.config/opencode/agent/*.md; do name=$(basename "$f" .md); fullname=$(grep -m1 "^You are" "$f" | sed -n 's/You are \([^,]*\),.*/\1/p'); purpose=$(grep -A2 "^You are" "$f" | tail -1 | sed 's/^## //'); echo "   - **$name** ($fullname) - $purpose"; done`

3. **Determine invocation strategy:**
   - **Parallel:** When perspectives are independent (e.g., "What are the tradeoffs of approach X?")
   - **Sequential:** When later perspectives depend on earlier ones (e.g., problem → solution → implementation)

## Phase 2: Invoke Agents

Use the agent filename to read the file and bring in the agent context, background and knowledge.

## Phase 3: Synthesize Discussion

Structure the output to show:

1. **Topic Summary** - Restate the question being discussed

2. **Perspectives** - Clearly attributed to each participant by role:
   ```
   ## Product Manager Perspective
   [Key points from product manager agent]
   
   ## Technical Specification Perspective
   [Key points from specification writer agent]
   
   ## Software Engineer Perspective
   [Key points from software engineer agent]
   ```

3. **Key Insights** - Extract major themes:
   - **Consensus:** Where agents agree
   - **Tensions:** Where agents have different priorities
   - **Tradeoffs:** Conflicting concerns that need balancing

4. **Recommendations** - Synthesized guidance:
   - If consensus exists: "All perspectives align on [recommendation]"
   - If tensions exist: "Balance needed between [concern A] and [concern B]"
   - If unclear: "Further exploration needed in [area]"

## Phase 4: Present Discussion

Format for readability:

```markdown
# Panel Discussion: [Topic]

## Topic
[Restate user's question]

## Perspectives

### [Agent Role 1]
**Focus:** [Agent's primary domain]
**Key Points:**
- [Point 1]
- [Point 2]
- [Point 3]

### [Agent Role 2]
**Focus:** [Agent's primary domain]
**Key Points:**
- [Point 1]
- [Point 2]
- [Point 3]

### [Agent Role 3]
**Focus:** [Agent's primary domain]
**Key Points:**
- [Point 1]
- [Point 2]
- [Point 3]

## Synthesis

### Areas of Consensus
[Where agents agree]

### Key Tensions
[Where priorities conflict - e.g., "Product manager prioritizes fast delivery vs software engineer emphasizes maintainability"]

### Trade-offs Identified
- **[Tradeoff 1]:** [Description and implications]
- **[Tradeoff 2]:** [Description and implications]

## Recommendations

[Synthesized guidance based on all perspectives]

**Next Steps:**
- [Actionable recommendation 1]
- [Actionable recommendation 2]
```

---

# Agent Selection Guide

Select agents based on their role descriptions, not their names. Add more agents only when their unique perspective is clearly needed.

---

# Communication Style

**Clear attribution** - Always identify which agent provided which perspective

**Evidence-based** - Each perspective should include reasoning, not just opinions

**No artificial consensus** - If agents disagree, highlight the disagreement constructively

**Actionable synthesis** - End with concrete guidance, not vague platitudes

**No meta-commentary** - Don't explain that you're orchestrating agents; just do it


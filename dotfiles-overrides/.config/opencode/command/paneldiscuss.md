---
description: Multi-perspective discussion using real subagents
agent: build
---

# Panel Discussion Command

Facilitate multi-perspective discussions by orchestrating multiple specialized subagents. Each agent provides their domain expertise on the topic.

**Topic:** [User-provided question or problem]

---

# Orchestration Workflow

## Phase 1: Analyze Topic (2 min)

1. **Parse the question** to identify:
   - Core subject matter (technical, product, architectural)
   - Type of discussion needed (problem exploration, solution evaluation, tradeoff analysis)
   - Relevant domains (product, technical design, implementation, debugging, review)

2. **Select relevant agents:**
Select up to 4 agents to avoid complexity. If fewer than 2 relevant agents exist for the topic, inform the user that the discussion may benefit from additional specialized agents being added to the system.

Available agents:
!`for f in ~/.config/opencode/agent/*.md; do name=$(basename "$f" .md); fullname=$(grep -m1 "^You are" "$f" | sed -n 's/You are \([^,]*\),.*/\1/p'); purpose=$(grep -A2 "^You are" "$f" | tail -1 | sed 's/^## //'); echo "   - **$name** ($fullname) - $purpose"; done`

3. **Determine invocation strategy:**
   - **Parallel:** When perspectives are independent (e.g., "What are the tradeoffs of approach X?")
   - **Sequential:** When later perspectives depend on earlier ones (e.g., problem → solution → implementation)

## Phase 2: Invoke Agents

**Agent Type Mapping:**
Use the agent filename (without .md extension) as the `subagent_type` value.
Example: For `pm-maya.md`, use `subagent_type="pm-maya"`

!`for f in ~/.config/opencode/agent/*.md; do name=$(basename "$f" .md"); echo "- $name → \`subagent_type=\"$name\"\`"; done`

### For Independent Perspectives (Parallel)

When asking for diverse viewpoints on same topic, invoke multiple agents in a single response using the task tool:

```
Invoking agents in parallel...

**Product Manager Perspective:**
task(
  description="Product perspective on [topic]",
  prompt="Analyze this topic from product/user perspective: [topic]",
  subagent_type="pm-maya"
)

**Technical Specification Perspective:**
task(
  description="Technical design perspective on [topic]",
  prompt="Analyze this topic from technical design perspective: [topic]",
  subagent_type="spec-alex"
)

**Software Engineer Perspective:**
task(
  description="Implementation perspective on [topic]",
  prompt="Analyze this topic from implementation perspective: [topic]",
  subagent_type="swe-jordan"
)
```

### For Sequential Analysis (Chained)

When later perspectives need earlier context, invoke agents sequentially and pass context:

```
**Step 1 - Initial Analysis:**
task(
  description="Initial analysis from [agent role]",
  prompt="[topic or question]",
  subagent_type="[appropriate-type]"
)
→ Capture output as CONTEXT_1

**Step 2 - Build on Context:**
task(
  description="Build on initial analysis",
  prompt="Given this context:\n\n{CONTEXT_1}\n\nNow analyze: [topic]",
  subagent_type="[appropriate-type]"
)
→ Capture output as CONTEXT_2

**Step 3 - Final Synthesis:**
task(
  description="Synthesize final perspective",
  prompt="Given these contexts:\n\nContext 1:\n{CONTEXT_1}\n\nContext 2:\n{CONTEXT_2}\n\nNow evaluate: [topic]",
  subagent_type="[appropriate-type]"
)
```

## Phase 3: Synthesize Discussion

Structure the output to show:

1. **Topic Summary** - Restate the question being discussed

2. **Agent Perspectives** - Clearly attributed to each agent by role:
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

## Available Agents

!`for f in ~/.config/opencode/agent/*.md; do name=$(basename "$f" .md); fullname=$(grep -m1 "^You are" "$f" | sed -n 's/You are \([^,]*\),.*/\1/p'); purpose=$(grep -A2 "^You are" "$f" | tail -1 | sed 's/^## //'); echo "**$name** ($fullname)"; echo "$purpose"; echo ""; done`

## By Discussion Type

**Product & Requirements:**
- Product managers analyze user needs, business impact, success metrics
- Guide writers focus on user experience and documentation needs

**Technical Design:**
- Specification writers evaluate architecture, design patterns, tradeoffs
- LLM specialists provide expertise on AI/ML system design

**Implementation:**
- Software engineers assess feasibility, complexity, implementation approaches
- Debugging specialists focus on troubleshooting and root cause analysis

**Code Quality:**
- Code reviewers examine correctness, maintainability, best practices
- Documentation writers ensure clarity and completeness

## Minimum Viable Panel

For most discussions, start with 2-3 agents from different domains:
- **Problem-focused:** Product manager + Technical specification writer
- **Solution-focused:** Technical specification writer + Software engineer
- **Implementation-focused:** Software engineer + Debugging specialist
- **Architecture-focused:** Technical specification writer + Software engineer + LLM specialist

Select agents based on their role descriptions, not their names. Add more agents only when their unique perspective is clearly needed.

---

# Communication Style

**Clear attribution** - Always identify which agent provided which perspective

**Evidence-based** - Each perspective should include reasoning, not just opinions

**No artificial consensus** - If agents disagree, highlight the disagreement constructively

**Actionable synthesis** - End with concrete guidance, not vague platitudes

**No meta-commentary** - Don't explain that you're orchestrating agents; just do it

---

# Example Invocations

## Example 1: Problem Exploration

**User:** `/paneldiscuss How should we handle database migrations in a microservices architecture?`

**Approach:**
1. Invoke product manager via task tool:
   ```
   task(
     description="Product perspective on microservices migrations",
     prompt="Explore the problem space of database migrations in a microservices architecture. Consider user impact, business concerns, and operational requirements.",
     subagent_type="pm-maya"
   )
   ```

2. Invoke specification writer via task tool:
   ```
   task(
     description="Technical design for microservices migrations",
     prompt="Evaluate technical approaches for database migration management in microservices. Consider architecture patterns, consistency, and failure scenarios.",
     subagent_type="spec-alex"
   )
   ```

3. Invoke software engineer via task tool:
   ```
   task(
     description="Implementation complexity of migration strategies",
     prompt="Assess implementation complexity of different migration strategies in microservices. Consider tooling, rollback mechanisms, and operational overhead.",
     subagent_type="swe-jordan"
   )
   ```

4. Synthesize all perspectives into discussion format

## Example 2: Tradeoff Analysis

**User:** `/paneldiscuss What are the tradeoffs between REST and GraphQL for our API?`

**Approach:**
1. Invoke both agents in parallel:
   ```
   task(
     description="Technical design: REST vs GraphQL",
     prompt="Analyze REST vs GraphQL from technical design perspective. Consider architecture implications, scalability, versioning, and API evolution.",
     subagent_type="spec-alex"
   )
   
   task(
     description="Implementation: REST vs GraphQL",
     prompt="Analyze REST vs GraphQL from implementation complexity perspective. Consider development time, tooling, testing, and maintenance overhead.",
     subagent_type="swe-jordan"
   )
   ```

2. Synthesize tradeoffs into discussion format

## Example 3: Troubleshooting Strategy

**User:** `/paneldiscuss Best approach to debug intermittent cache invalidation issues?`

**Approach:**
1. Invoke debugging specialist via task tool:
   ```
   task(
     description="Debug approach for cache invalidation",
     prompt="Propose a systematic debugging approach for intermittent cache invalidation issues. Include specific investigation steps, logging strategies, and reproduction techniques.",
     subagent_type="debug-morgan"
   )
   ```

2. Invoke software engineer via task tool:
   ```
   task(
     description="Implementation-level investigation strategies",
     prompt="Suggest implementation-level investigation strategies for intermittent cache invalidation. Consider code patterns, race conditions, and instrumentation approaches.",
     subagent_type="swe-jordan"
   )
   ```

3. Synthesize into actionable debugging plan

---

# Scope

This command handles:
- Multi-perspective technical discussions
- Problem exploration from multiple angles
- Solution tradeoff analysis
- Architecture decision discussion
- Implementation strategy evaluation

This command does NOT:
- Replace individual agents (use direct agent invocation for single-perspective work)
- Make final decisions (provides perspectives for informed decision-making)
- Implement solutions (hand off to implementation-focused agents)
- Create formal documents (agents may suggest formal problem briefs or specs)

**When to use /paneldiscuss vs individual agents:**
- Use `/paneldiscuss` when you need multiple perspectives on a decision or problem
- Use individual agents directly when you know which perspective you need

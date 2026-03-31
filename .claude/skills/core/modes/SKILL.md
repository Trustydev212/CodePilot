---
name: mode
description: "Switch behavioral modes: token-efficient, brainstorm, deep-research, implementation, review, orchestration. Optimize responses for different task types."
user-invocable: true
---

# /mode - Behavioral Mode Switching

Switch how Claude responds based on your current task. Each mode optimizes for different goals.

## Usage
`/mode <mode-name>`

Available modes: `default`, `token-efficient`, `brainstorm`, `deep-research`, `implementation`, `review`, `orchestration`

## Mode: $ARGUMENTS

---

### default
Standard balanced mode. Good for general development tasks.
- Normal verbosity
- Balanced analysis depth
- Standard code examples

---

### token-efficient
**Goal**: Minimize token usage. Save 40-70% on costs.

Rules:
- Responses under 200 words unless code is needed
- No preamble, no summaries, no "let me explain"
- Code only - no commentary unless asked
- Use abbreviations in explanations
- Skip obvious context ("As you can see..." → delete)
- One-line answers when possible
- No repeating the question back
- No "Here's what I found:" - just show it

Format: `code > bullets > prose`

---

### brainstorm
**Goal**: Explore possibilities. Divergent thinking.

Rules:
- Generate 5-10 ideas minimum, even unconventional ones
- No filtering or judgment during ideation phase
- Build on each idea with "what if..." extensions
- Consider opposite approaches (inversion thinking)
- Mix approaches from different domains
- After ideation: rank by feasibility + impact matrix
- Use format:

```
## Ideas

1. **[Name]** - [1 sentence]
   - Feasibility: [1-5]
   - Impact: [1-5]
   - Twist: [unconventional angle]

...

## Top 3 Recommended
1. [Best balance of feasibility + impact]
2. [High impact, moderate effort]
3. [Quick win]
```

---

### deep-research
**Goal**: Thorough analysis. Leave no stone unturned.

Rules:
- Read ALL relevant files before answering (not just the obvious ones)
- Cross-reference information across multiple sources
- Check edge cases, limitations, and caveats
- Provide evidence for every claim (file:line references)
- Consider historical context (git blame, commit history)
- Minimum 3 perspectives on every question
- Structure findings hierarchically:

```
## Research: [Topic]

### Key Findings
1. [Finding with file:line evidence]

### Supporting Evidence
- [Source 1]: [what it shows]
- [Source 2]: [what it shows]

### Contradictions / Edge Cases
- [thing that doesn't fit the main narrative]

### Confidence Level
- High confidence: [claims with strong evidence]
- Medium: [claims with partial evidence]
- Low: [assumptions or inferences]

### Unknowns
- [What we still don't know and how to find out]
```

---

### implementation
**Goal**: Ship code fast. Minimal discussion, maximum output.

Rules:
- Start coding immediately. No planning phase unless asked.
- Write complete, working code (no pseudocode, no "..." placeholders)
- Include imports, types, error handling
- Follow existing codebase patterns exactly
- Run tests after implementation
- Output format: just code blocks with file paths
- Only comment when logic is non-obvious
- Don't explain what the code does unless asked

```
// filepath: src/modules/users/users.service.ts
[complete code here]
```

---

### review
**Goal**: Critical analysis. Find problems.

Rules:
- Assume there ARE bugs until proven otherwise
- Check every conditional (off-by-one, boundary, null)
- Verify error handling paths
- Check for race conditions in async code
- Look for security implications
- Performance impact assessment
- Provide severity: CRITICAL > HIGH > MEDIUM > LOW
- Every finding needs: location, problem, fix, evidence
- Also note what's done WELL (positive reinforcement)

---

### orchestration
**Goal**: Coordinate multi-step complex tasks. Think like a tech lead.

Rules:
- Break task into smallest possible independent units
- Identify dependencies between units
- Determine what can run in parallel
- Assign appropriate skill/approach to each unit
- Create verification checkpoints between phases
- Monitor progress and adapt plan if needed
- Format:

```
## Orchestration Plan

### Phase 1: [Name] (parallel)
- [ ] Task A → [skill/approach]
- [ ] Task B → [skill/approach]
  Checkpoint: [what must be true before Phase 2]

### Phase 2: [Name] (sequential, depends on Phase 1)
- [ ] Task C → [skill/approach]
  Checkpoint: [verification]

### Phase 3: [Name]
...

### Rollback Plan
- Phase 1 fails: [action]
- Phase 2 fails: [action]
```

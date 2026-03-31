---
name: debug
description: "Systematic root cause analysis. 5 Whys, backward tracing, hypothesis testing. Fix the cause, not the symptom."
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob, Agent
---

# /debug - Systematic Root Cause Analysis

You are a senior debugger. Your job is to find WHY something broke, not just make the error go away.

## Symptom
$ARGUMENTS

## Method: Backward Trace

### Step 1: Gather Evidence (Don't guess)

```bash
# If there's an error message, find where it originates
rg -n "ERROR_MESSAGE_HERE" --glob '!node_modules' --glob '!.git'

# Check recent changes to suspect files
git log --oneline -10 -- <suspect_file>

# Check git blame for the specific line
git blame -L <start>,<end> <file>
```

Questions to answer:
- What EXACTLY is the error? (Full message, stack trace)
- When did it START happening? (Always? After a deploy? After a change?)
- Is it CONSISTENT or intermittent?
- What environment? (Dev, staging, prod? All of them?)

### Step 2: Form Hypotheses (Max 3)

```
Hypothesis 1: [Most likely cause] because [evidence]
Hypothesis 2: [Second possibility] because [evidence]
Hypothesis 3: [Third possibility] because [evidence]
```

### Step 3: Test Each Hypothesis (Cheapest first)

For each hypothesis, find the CHEAPEST test:
- Read the code (free)
- Add a log/console.log (cheap)
- Write a unit test (medium)
- Run in debug mode (medium)
- Reproduce in isolation (expensive)

### Step 4: 5 Whys (Go Deeper)

Once you find the failing code:
1. **Why** did this line fail? → [data was X instead of Y]
2. **Why** was the data wrong? → [function A returned incorrectly]
3. **Why** did function A return wrong? → [input validation missing]
4. **Why** was validation missing? → [edge case not considered]
5. **Why** wasn't it caught? → [no test for this path]

### Step 5: Fix at the Right Level

The fix should address the ROOT CAUSE from step 4, not just step 1.

- Step 1 fix: Add a null check → **BAND-AID** (will break again differently)
- Step 3 fix: Add input validation → **PROPER FIX**
- Step 5 fix: Add test + validation → **BEST FIX** (prevents regression)

## Common Bug Categories

### Data Flow Bugs
- **Symptom**: Wrong output, unexpected null/undefined
- **Method**: Trace data backward from error to source
- **Common cause**: Missing validation, type coercion, race condition

### State Management Bugs
- **Symptom**: UI shows stale data, inconsistent state
- **Method**: Log state transitions, check for mutation
- **Common cause**: Stale closure, missing dependency in useEffect, shared mutable state

### Async/Timing Bugs
- **Symptom**: Works sometimes, fails under load, race conditions
- **Method**: Add timestamps to logs, test with artificial delays
- **Common cause**: Missing await, parallel writes without lock, event ordering

### Environment Bugs
- **Symptom**: Works locally, fails in CI/staging/prod
- **Method**: Compare env vars, versions, configs between environments
- **Common cause**: Missing env var, different Node/Python version, file path differences

## Output Format

```
## Debug Report: [symptom]

### Root Cause
[Clear explanation of WHY, not just what]

### Evidence
- [What you checked and what it showed]

### Fix
- [file:line]: [change and why]

### Prevention
- [Test added to catch regression]
- [Validation added to catch bad input]

### 5 Whys Chain
1. Why: [error] → Because: [cause]
2. Why: [cause] → Because: [deeper cause]
3. Why: [deeper cause] → Because: [root cause]
```

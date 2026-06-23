# Features & criticality (phase 7 method)

How specy turns vision into a ranked, traceable feature set. This is the heart
of "deeper than brainstorming": criticality is **derived and falsifiable**, not
asserted.

## The criticality test

> A feature is **critical** if and only if at least one stated **Success
> Criterion** (phase 4) or core **Job** (phase 3) cannot be met without it.

Apply it to every candidate. Surviving features are the MVP set; the rest are
"Later" or "Won't". This classification **is** the scope cut — there is no
separate scope step:

- **In** = critical
- **Later** = could (serves a real want, not load-bearing for an SC/Job)
- **Won't** = serves nothing currently in scope

## Bidirectional traceability (check both directions)

- **Feature → SC/Job.** A feature that traces to *nothing* is gold-plating. Cut it.
- **SC/Job → Feature.** A Success Criterion or Job with *no* implementing feature is a gap. You're under-built — add the missing feature.

Both failure modes get surfaced explicitly during the phase.

## Two extraction modes

Pick by input type (set in phase 1).

### Idea mode — derive backward from success
For each core **Job** and each **Success Criterion**, ask: "what capability
*must exist* to satisfy this?" Collect the candidates, cluster and dedupe them,
then run the criticality test. Because you derive from the outcome, you cannot
invent features that serve nothing.

### Code mode — observe, then diff
1. Reuse the phase-1 `reverse-engineer` enumeration of what the code *already does*.
2. Classify each observed feature against the current vision:
   - **Keep** — serves a live Job/SC.
   - **Cut** — dead weight; serves nothing now.
   - **Rework** — right idea, wrong implementation.
3. **Gap pass:** any Job/SC with no implementing feature → a **missing critical feature**.

## Output — the requirements table

Write to `## Features & Requirements`:

| ID | Feature | Critical? | Serves (SC/Job) | Acceptance check | Status |
|----|---------|-----------|-----------------|------------------|--------|
| F1 | …       | ✅ / ⬜    | SC-2, Job-A      | observable pass condition | exists/partial/missing |

- **Acceptance check** is what makes each feature buildable — it becomes a
  `writing-plans` milestone and a coding agent's verification target. Never leave
  it vague; phrase it as an observable pass/fail.
- **Status** appears only in **code mode** (exists / partial / missing). In idea
  mode, omit or mark `—`.

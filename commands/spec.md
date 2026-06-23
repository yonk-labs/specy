---
description: Turn an idea or codebase into one agent-ready SPEC.md (guided interview).
argument-hint: "[idea | ./path | status | resume | jump <phase> | redo <phase>] [--brutal|--gentle]"
---

Invoke the `phase-engine` skill and follow it exactly to run or resume a specy
spec interview. Pass the user's input through verbatim and obey the skill's
dispatch grammar, run loop, and intensity rules.

Input: $ARGUMENTS

If `$ARGUMENTS` is empty, treat it as `resume`: load the most recent
`spec/<slug>/SPEC.md` and continue at the first unconfirmed phase. If no spec
exists yet, ask the user for an idea or a path.

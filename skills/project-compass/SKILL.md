---
name: project-compass
description: Curated, self-contained gap-analysis method bundled with specy. Invoked by the /spec phase engine (phase 7 Features, code mode) to compare current state against target and rank the gaps. Not a general-purpose replacement for a full project-compass skill.
---

# project-compass (curated for specy)

For codebases: find the distance between where the project IS and where it
SHOULD BE, then rank the gaps.

## Method
1. **IS** — pull the current capabilities from the phase-1 `reverse-engineer` output (or scan inline if missing).
2. **SHOULD BE** — derive the target from the Success Criteria (phase 4) and the Vision (phase 6).
3. **Gaps** — `SHOULD BE` minus `IS`. Each gap is a missing or incomplete capability.
4. **Rank** — order gaps by criticality: does an `SC` or a core user Job depend on it? Critical gaps first, nice-to-haves last.

## Output
Write `evidence/gaps.md`:
- **Current state:** capability list.
- **Target state:** what the SCs/Vision require.
- **Ranked gaps:** ordered list, each tagged with the SC/Job it unblocks.

## Done when
Gaps are enumerated and ranked by criticality, each traceable to an SC or Job.

---
*Slim, bundled method. The fuller version lives in [yonk-labs/yonk-ai-skills](https://github.com/yonk-labs/yonk-ai-skills) — specy prefers it automatically (amplify-first) when installed.*

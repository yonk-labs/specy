---
name: mission-brief
description: Curated, self-contained success-definition method bundled with specy. Invoked by the /spec phase engine (phase 4 Success) to lock Purpose, measurable Success Criteria, testing, and out-of-scope. Not a general-purpose replacement for a full mission-brief skill.
---

# mission-brief (curated for specy)

Lock what "success" means before features are chosen.

## Method
1. **Purpose** — one sentence: the *outcome*, not the output. ("Users ship a spec in under an hour," not "we build a spec tool.")
2. **Success Criteria** — write `SC-1 … SC-n`. Each MUST have an *observable signal*: a number, a state, or a behavior you can check. Reject any criterion you cannot verify.
   - Weak: "the spec is good."
   - Strong: "SC-2: a coding agent can build a runnable v1 from the spec with zero clarifying questions."
3. **Testing** — for each SC, name how it would be verified (test, demo, metric).
4. **Out of scope** — list explicitly what success does *not* require. This is where scope creep dies.

## Output
Write `evidence/mission-brief.md`:
- **Purpose:** one sentence.
- **Success Criteria:** numbered `SC-n`, each with its observable signal.
- **Testing:** how each SC is verified.
- **Out of scope:** bulleted.

## Done when
Every Success Criterion has an observable signal.

---
*Slim, bundled method. The fuller version lives in [yonk-labs/yonk-ai-skills](https://github.com/yonk-labs/yonk-ai-skills) — specy prefers it automatically (amplify-first) when installed.*

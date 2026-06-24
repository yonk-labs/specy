---
name: phase-engine
description: Drive a /spec interview — dispatch commands, walk the 12 phases, manage spec state in SPEC.md frontmatter, and synthesize one agent-ready SPEC.md. Use when running or resuming /spec.
---

# phase-engine

The brain behind `/spec`. Claude is the runtime; the filesystem is the database.
This skill drives a guided, assertive interview that turns an idea or a codebase
into one agent-ready `SPEC.md`.

Read alongside:
- `phases.md` — the 12-phase playbook (what to ask, what to orchestrate, what to write).
- `criticality.md` — phase-7 feature extraction + the criticality test.
- `../../templates/SPEC.template.md` — the output contract.

## 1. Dispatch grammar

Parse `$ARGUMENTS`:

- **empty** or **`resume`** → load the most recent `spec/<slug>/SPEC.md`, read its frontmatter, continue at the first phase whose status is not `confirmed`.
- **`status`** → render the phases checklist from frontmatter (phase → status); do not advance.
- **`jump <phasekey>`** → set the cursor to that phase and run it.
- **`redo <phasekey>`** → reset that phase to `pending` and re-run it.
- **a path** (starts with `.` or `/`, or is an existing dir/file) → **code mode**.
- **any other text** → **idea mode**; the text is the premise.
- trailing **`--brutal`** / **`--gentle`** / **`--standard`** → set intensity (default `standard`).

If there is no input and no existing spec → ask for an idea or a path.

## 2. Slug + state

- Derive `<slug>` from the idea (kebab a few key words) or the repo directory name.
- On first run, copy `templates/SPEC.template.md` to `spec/<slug>/SPEC.md`, fill `slug`, `input`, `intensity`, `updated`; create `spec/<slug>/evidence/`.
- The frontmatter is the **single source of truth**. Re-read it at the start of every turn.
- After each phase: write its `<!-- phase: KEY -->` section, set that phase's status (`drafted` when written; `confirmed` when its Done-when in `phases.md` is met), and bump `updated`.

## 3. Run loop

For the current phase:
1. Read its entry in `phases.md`.
2. Ask its Probes **one at a time** — never batch questions.
3. Orchestrate its method skill via the Skill tool, **amplify-first**: prefer a fuller installed version (the public ai-skills library, <https://github.com/yonk-labs/yonk-ai-skills>), else fall back to the bundled `specy:<skill>` (always present) — see "How to resolve a method skill" in `phases.md`. Separate-project tools (`abe`, `second-opinion`, `superpowers:writing-plans`) are optional and take the degradation fallback if absent. Phase 7 follows `criticality.md`.
4. Write its section, flip its status, summarize what was captured, and advance — or stop if the user quits (state is already saved).

Stop and ask rather than guess whenever an answer is genuinely ambiguous.

## 4. Intensity

- **gentle** — supportive, probing tone; still asks "why", but no adversarial pressure.
- **standard** (default) — refuse vague answers, dig to bedrock, flag weak differentiation.
- **brutal** — everything in standard, plus actively attack the reasoning with AAT-style critique on motivation (phase 2), differentiation (phase 5), the design/mechanism (phase 8), and the stack pick (phase 9); if `abe` is installed, route those through `abe` debate/validate too. Log each consult to `evidence/`.

## 5. Cross-cutting AI-assist (every phase)

- **URL pasted** → `WebFetch` it, summarize into `evidence/`, cite it in the spec.
- **"I'm not sure"** → research it with built-in `WebSearch`/`WebFetch` and bring findings back for the user to react to — don't stall. (If a richer research skill like `deep-research` is installed, use it; not required.)
- **Other LLMs (optional)** → if `abe` (debate/validate) or `second-opinion` are installed, use them for non-host perspectives, heaviest in `brutal`. These are separate installs — specy never requires them.

## 6. Error handling

- No input + no existing spec → ask for an idea or path.
- Path isn't code → treat its contents as notes (idea mode with seed material).
- Multiple in-progress specs on `resume` → list them, default to most-recent.
- A *method* skill's fuller version isn't installed → use the bundled `specy:<skill>` (always present); no degradation, just the slimmer method.
- An *optional* separate-project tool (`abe`, `second-opinion`, `superpowers:writing-plans`) is missing → degrade per its phase's fallback and note it in `evidence/`. The core interview never hard-fails because another skill isn't installed.

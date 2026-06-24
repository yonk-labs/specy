# Phase playbook

The 12 phases specy walks. Each entry has: **Goal**, **Probes** (ask one at a
time), **Orchestrates** (method skill + degradation fallback), **Writes** (which
`<!-- phase: -->` section it fills), **Done-when** (the condition to flip that
phase's status to `confirmed`).

## How to resolve a method skill (amplify-first)

When a phase below names a **method skill** (`reverse-engineer`, `mission-brief`,
`market-intel`, `research-and-design`, `constitution`, `project-compass`,
`persona`), resolve it like this:

1. **If a fuller version is installed** — the public ai-skills library at
   <https://github.com/yonk-labs/yonk-ai-skills> ships richer versions of all of these.
   If one is available in this environment, prefer it (call the unprefixed
   `<skill>`).
2. **Otherwise** — fall back to the slim version specy ships **bundled** under
   `specy:<skill>`. These are always present, so the interview never hard-fails
   for lack of an external library.

A few skills come from **separate projects** with no bundled equivalent — `abe`
(multi-model debate), `second-opinion`, `superpowers:writing-plans`. These are
purely **optional**: use them if installed, otherwise take the inline fallback
the phase names. Phase 7 (Features) delegates its method to `criticality.md`.

### 1. Frame
- **Goal:** Establish the one-line premise and intake mode (idea vs codebase).
- **Probes:** "In one sentence, what is this?" If a path was given: "What works today, and what hurts?"
- **Orchestrates:** If input is a path → run `reverse-engineer` (amplify-first) to map current state and write its summary to `evidence/frame.md`. Idea mode → no skill.
- **Writes:** `<!-- phase: frame -->` → `## Overview / Current State`.
- **Done-when:** premise is one clear sentence AND (idea mode) the problem is nameable, or (code mode) current state is summarized.

### 2. Why
- **Goal:** Dig purpose to bedrock — why this, why you, why now.
- **Probes:** "Why build this?" then keep asking "why" (×5). "Why you?" "Why now?" "What happens if it doesn't exist?"
- **Orchestrates:** Socratic only — no method skill. In `brutal`, if `abe` is installed, route the stated motivation through `abe validate` to stress-test it (log to `evidence/why.md`); otherwise argue the strongest counter-case inline.
- **Writes:** `<!-- phase: why -->` → `## Problem & Why`.
- **Done-when:** the motivation bottoms out in something that isn't itself a "because X" deferral.

### 3. Users
- **Goal:** Name the user and the job they hire this for.
- **Probes:** "Who is this for, specifically?" "What job are they hiring it to do?" "What do they do today instead?"
- **Orchestrates:** None.
- **Writes:** `<!-- phase: users -->` → `## Users & Use Cases`.
- **Done-when:** at least one concrete user plus their current workaround is documented.

### 4. Success
- **Goal:** Define what success means and how it's measured.
- **Probes:** "What does success look like?" "What's the outcome, not the output?" "How would you measure it — what number moves?"
- **Orchestrates:** `mission-brief` (amplify-first) to lock Purpose, Success Criteria, Testing, and Out-of-scope; store at `evidence/mission-brief.md`.
- **Writes:** `<!-- phase: success -->` → `## Success Criteria` (numbered SC-n).
- **Done-when:** every success criterion is measurable (has an observable signal).

### 5. Compete
- **Goal:** Map comparables and earn the differentiation.
- **Probes:** "Who else solves this?" "Why is this different?" "Why won't they crush you in a weekend?"
- **Orchestrates:** `market-intel` (amplify-first) for competitive positioning (→ `evidence/market-intel.md`) and `research-and-design` (amplify-first) for prior art / feasibility (→ `evidence/research.md`). In `standard`+, if `abe` is installed, run `abe debate` on the differentiation claim (→ `evidence/abe-debates.md`).
- **Writes:** `<!-- phase: compete -->` → `## Competitive Landscape` and `## Differentiation`.
- **Done-when:** ≥3 comparables named AND a differentiation that survived at least one counter-argument.

### 6. Vision
- **Goal:** Capture the specific vision and the non-negotiables.
- **Probes:** "Describe the experience you're picturing." (the feel and shape — the *detailed* per-feature mechanics are worked in phase 8 Design) "What will you never compromise on?" "What's explicitly NOT this product's job?"
- **Orchestrates:** `constitution` (amplify-first) to formalize principles/non-negotiables (→ `evidence/constitution.md`).
- **Writes:** `<!-- phase: vision -->` → `## Product Vision & Principles`.
- **Done-when:** ≥1 explicit non-negotiable recorded.

### 7. Features
- **Goal:** Derive/extract the feature set and rank by criticality (= the scope cut).
- **Probes:** see `criticality.md` — driven by the Jobs (phase 3) and Success Criteria (phase 4).
- **Orchestrates:** Idea mode → derive backward (no skill). Code mode → reuse the phase-1 `reverse-engineer` output plus a `project-compass` (amplify-first) gap pass (→ `evidence/gaps.md`).
- **Writes:** `<!-- phase: features -->` → `## Features & Requirements` (the table, incl. the one-line **How (sketch)** column) and `## Scope` (In / Later / Won't).
- **Done-when:** every feature is classified, every Critical feature traces to an SC/Job and has an acceptance check + a one-line How sketch (or a `→ Design` flag), and every SC/Job has ≥1 feature (no gaps).

### 8. Design
- **Goal:** Settle *how* each critical feature and key outcome actually works — the mechanism/behaviour — before a stack is chosen. This is the phase where specy stops interrogating and starts **co-designing**.
- **Probes (per critical feature / key outcome, one item at a time):** "Do you have a picture of how this should work, or should I propose options?"
  - **User has a vision** → draw it out concretely, then pressure-test it: does it serve its SC? Is it the simplest thing that works? What breaks it?
  - **User says "propose" / "decide for me" / "not sure"** → this is a *valid answer*, not vagueness to drill past. Switch to **propose mode**.
- **Propose mode (default when a "how" is absent):** generate 2-3 *distinct* concrete options — not platitudes. Each names its trade-off and the SC/principle it serves. **Always state a recommendation.** The user reacts ("A, but…"), picks, or fully delegates; "decide for me" → take the recommendation, record it, move on. Never punish an absent vision — that's specy's cue to design, not to push.
- **Orchestrates:** `WebSearch`/`WebFetch` for how comparables implement the mechanism (cite into `evidence/design.md`); in `standard`+, if `abe` is installed, debate the chosen approach against its strongest alternative. No bundled method skill — this is generative dialogue, not elicitation.
- **Writes:** `<!-- phase: design -->` → `## Design — How It Works` (one block per designed item: the mechanism, why chosen, alternatives considered, open questions).
- **Done-when:** every Critical feature and key outcome has an agreed mechanism — the user's vision (pressure-tested) or a proposed option they accepted/delegated — each traceable to the SC/outcome it serves. Items chosen via "decide for me" are flagged so they can be revisited.

### 9. Stack
- **Goal:** Choose a stack that serves the features, with researched trade-offs.
- **Probes:** "Any stack constraints (team, hosting, language)?" "What matters most — speed, cost, familiarity?"
- **Orchestrates:** `WebSearch`/`WebFetch` to gather current pros/cons of candidate stacks; if `abe` is installed, get a second opinion on the recommendation (→ `evidence/stack-research.md`). If research tools unavailable → degrade: reason from known trade-offs and flag as unverified.
- **Writes:** `<!-- phase: stack -->` → `## Tech Stack` + decision log.
- **Done-when:** a recommendation exists with at least one weighed alternative and the user's constraints reflected.

### 10. Architecture
- **Goal:** Describe components, data flow, and interfaces at agent altitude.
- **Probes:** "What are the major pieces and how do they talk?" "Where does state live?" "What are the seams a coding agent builds against?"
- **Orchestrates:** None.
- **Writes:** `<!-- phase: architecture -->` → `## Architecture`.
- **Done-when:** components plus their interfaces are explicit enough to hand to `writing-plans`.

### 11. Persona Review
- **Goal:** Pressure-test the drafted spec through the eyes of the people who'd use, buy, or build against it — before it's finalized.
- **Probes:** "Whose reaction matters most here?" specy proposes a candidate persona set drawn from the Users (phase 3), the buyer/competitor angle (phase 5), and the Vision (phase 6), then asks the user to confirm or edit the list. Default to 3-4.
- **Orchestrates:** `persona` (amplify-first) to construct and voice each chosen persona against the whole spec so far (→ `evidence/persona-feedback.md`). In `standard`+, if `abe` or `second-opinion` is installed, add one external-model persona take.
- **Writes:** `<!-- phase: personas -->` → `## Persona Feedback`.
- **Done-when:** ≥2 personas have given concrete feedback (≥1 real objection captured) and the user has reacted to it.

### 12. Synthesize
- **Goal:** Distill all sections into the final authoritative SPEC and hand off.
- **Probes:** None — this phase reviews, it doesn't interview.
- **Orchestrates:** Self-review scan (placeholders, contradictions, ambiguity, scope) across the whole spec; fold in the phase-11 persona objections (resolve or explicitly defer each); then, if `superpowers:writing-plans` is installed, hand off to produce the agent-ready plan (→ `PLAN.md`). If absent → degrade: write an inline task list.
- **Writes:** finalizes all sections; sets every phase `confirmed`; writes `PLAN.md` alongside `SPEC.md` (or records the writing-plans handoff).
- **Done-when:** self-review finds no placeholders/contradictions, every persona objection is addressed or explicitly deferred, and the plan handoff is done.

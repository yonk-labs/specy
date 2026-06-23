# Phase playbook

The 10 phases specy walks. Each entry has: **Goal**, **Probes** (ask one at a
time), **Orchestrates** (sub-skill + degradation fallback), **Writes** (which
`<!-- phase: -->` section it fills), **Done-when** (the condition to flip that
phase's status to `confirmed`).

Phase 7 (Features) delegates its method to `criticality.md`.

### 1. Frame
- **Goal:** Establish the one-line premise and intake mode (idea vs codebase).
- **Probes:** "In one sentence, what is this?" If a path was given: "What works today, and what hurts?"
- **Orchestrates:** If input is a path → run `reverse-engineer` to map current state; write its summary to `evidence/frame.md`. If `reverse-engineer` is absent → degrade: inline-scan the repo (Glob/Grep/Read) and summarize; note the degradation in `evidence/frame.md`.
- **Writes:** `<!-- phase: frame -->` → `## Overview / Current State`.
- **Done-when:** premise is one clear sentence AND (idea mode) the problem is nameable, or (code mode) current state is summarized.

### 2. Why
- **Goal:** Dig purpose to bedrock — why this, why you, why now.
- **Probes:** "Why build this?" then keep asking "why" (×5). "Why you?" "Why now?" "What happens if it doesn't exist?"
- **Orchestrates:** Socratic only — no sub-skill. In `brutal`, route the stated motivation through `abe validate` to stress-test it; log to `evidence/why.md`. If `abe` absent → degrade: argue the strongest counter-case inline.
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
- **Orchestrates:** `mission-brief` to lock Purpose, Success Criteria, Testing, Out-of-scope; store at `evidence/mission-brief.md`. If absent → degrade: write SC-1..SC-n inline.
- **Writes:** `<!-- phase: success -->` → `## Success Criteria` (numbered SC-n).
- **Done-when:** every success criterion is measurable (has an observable signal).

### 5. Compete
- **Goal:** Map comparables and earn the differentiation.
- **Probes:** "Who else solves this?" "Why is this different?" "Why won't they crush you in a weekend?"
- **Orchestrates:** `market-intel` + `research-and-design` for the landscape (→ `evidence/market-intel.md`); in `standard`+ run `abe debate` on the differentiation claim (→ `evidence/abe-debates.md`). If skills absent → degrade: inline `WebSearch` for comparables, note the degradation.
- **Writes:** `<!-- phase: compete -->` → `## Competitive Landscape` and `## Differentiation`.
- **Done-when:** ≥3 comparables named AND a differentiation that survived at least one counter-argument.

### 6. Vision
- **Goal:** Capture the specific vision and the non-negotiables.
- **Probes:** "Describe exactly how it should work." "What will you never compromise on?" "What's explicitly NOT this product's job?"
- **Orchestrates:** `constitution` to formalize principles/non-negotiables (→ `evidence/constitution.md`). If absent → degrade: inline ALWAYS / ASK-FIRST / NEVER list.
- **Writes:** `<!-- phase: vision -->` → `## Product Vision & Principles`.
- **Done-when:** ≥1 explicit non-negotiable recorded.

### 7. Features
- **Goal:** Derive/extract the feature set and rank by criticality (= the scope cut).
- **Probes:** see `criticality.md` — driven by the Jobs (phase 3) and Success Criteria (phase 4).
- **Orchestrates:** Idea mode → derive backward (no sub-skill). Code mode → reuse the phase-1 `reverse-engineer` output plus a `project-compass`-style gap pass; if absent → degrade to inline enumeration.
- **Writes:** `<!-- phase: features -->` → `## Features & Requirements` (the table) and `## Scope` (In / Later / Won't).
- **Done-when:** every feature is classified, every Critical feature traces to an SC/Job and has an acceptance check, and every SC/Job has ≥1 feature (no gaps).

### 8. Stack
- **Goal:** Choose a stack that serves the features, with researched trade-offs.
- **Probes:** "Any stack constraints (team, hosting, language)?" "What matters most — speed, cost, familiarity?"
- **Orchestrates:** `WebSearch`/`WebFetch` to gather current pros/cons of candidate stacks; `abe` second opinion on the recommendation (→ `evidence/stack-research.md`). If research tools unavailable → degrade: reason from known trade-offs and flag as unverified.
- **Writes:** `<!-- phase: stack -->` → `## Tech Stack` + decision log.
- **Done-when:** a recommendation exists with at least one weighed alternative and the user's constraints reflected.

### 9. Architecture
- **Goal:** Describe components, data flow, and interfaces at agent altitude.
- **Probes:** "What are the major pieces and how do they talk?" "Where does state live?" "What are the seams a coding agent builds against?"
- **Orchestrates:** None.
- **Writes:** `<!-- phase: architecture -->` → `## Architecture`.
- **Done-when:** components plus their interfaces are explicit enough to hand to `writing-plans`.

### 10. Synthesize
- **Goal:** Distill all sections into the final authoritative SPEC and hand off.
- **Probes:** None — this phase reviews, it doesn't interview.
- **Orchestrates:** Self-review scan (placeholders, contradictions, ambiguity, scope) across the whole spec; then hand to `superpowers:writing-plans` to produce the agent-ready plan. If absent → degrade: write an inline task list.
- **Writes:** finalizes all sections; sets every phase `confirmed`; writes `PLAN.md` alongside `SPEC.md` (or records the writing-plans handoff).
- **Done-when:** self-review finds no placeholders/contradictions and the plan handoff is done.

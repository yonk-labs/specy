# specy — Spec Conductor (Design)

- **Date:** 2026-06-23
- **Status:** Approved design, pre-implementation
- **Author:** brainstormed with Claude (matt@theyonk.com)
- **Next step:** `superpowers:writing-plans` → implementation plan

---

## One line

`/spec` walks you from a fuzzy idea — or a pile of existing code — to a single
authoritative `SPEC.md` a coding agent can build from, by interrogating *why*,
researching what you don't know, pulling in other LLMs to attack your reasoning,
and distilling everything into one document.

## What this is (and is not)

specy is a **Claude Code plugin** that runs a guided, assertive, AI-assisted
interview and produces one deep, agent-ready spec. It does **not** reimplement
the thinking that already exists across the yonk skill library — it **conducts**
it. The novel value is the opinionated orchestration and synthesis, not the
individual moves.

Phase 1 (this design) is **Claude-only, markdown-only, zero new dependencies**.
TUI and web app are explicitly deferred to phase 2 (see Out of Scope).

## Decision log (locked during brainstorming)

| # | Decision | Choice | Why |
|---|---|---|---|
| D1 | Build path | **Plugin-first, orchestrate existing skills** | Reuse proven work; ship in days; learn what "deep spec" means before building TUI/web infra |
| D2 | Output shape | **One synthesized `SPEC.md` + `evidence/`** | A coding agent wants one door; sub-skill outputs are supporting evidence |
| D3 | Command shape | **Hybrid: guided default + escape hatches** | Walks newcomers through; lets power users grab the wheel; one phase engine backs both |
| D4 | Temperament | **Configurable dial, default assertive** (`gentle`/`standard`/`brutal`) | A spec tool that accepts vague answers produces vague specs; one engine + one knob |
| D5 | Implementation | **Pure prompt-orchestration (markdown only)** | Claude is the runtime, filesystem is the DB, existing skills are the machinery; no code, no deps |
| D6 | Feature definition | **Criticality = traceability test; dedicated Features phase** | "Critical" must be falsifiable, not a vibe; folds old "Scope" into the criticality cut |
| D7 | Name | **specy** (command `/spec`) | Keep the working name, drop the `old-` |

## Inputs

- **Idea:** `/spec "a tool that turns ideas into specs"`
- **Codebase:** `/spec ./my-project` → runs a `reverse-engineer` pass to map what
  *exists*, then interrogates *forward* (vision now, what's missing).
- **URLs / notes:** paste a URL any time → fetched, summarized into `evidence/`,
  cited in the spec.

## The phases (the spine)

Ordered by default, but skippable and jumpable. Each phase has a goal, "why"
probes, the sub-skill(s) it orchestrates, and the spec section it writes.

| # | Phase | Orchestrates | Writes |
|---|---|---|---|
| 1 | **Frame** — intake; if a path, map current state | `reverse-engineer` | §Overview / §Current State |
| 2 | **Why ×5** — relentless purpose dig (why this, why you, why now) | — (Socratic probes) | §Problem / §Why |
| 3 | **Users & Jobs** — who, what job, what they do today | — | §Users & Use Cases |
| 4 | **Success** — what success *means*, the outcome, the metric | `mission-brief` | §Success Criteria |
| 5 | **Compete & Differentiate** — comps, why different, why you survive | `market-intel`, `research-and-design`, `abe` | §Competitive Landscape / §Differentiation |
| 6 | **Vision & Non-negotiables** — your exact vision, principles | `constitution` | §Product Vision / §Principles |
| 7 | **Features & Scope** — derive/extract features → rank by criticality = the cut | — (+ `project-compass` instinct in code mode) | §Features & Requirements / §Scope |
| 8 | **Stack** — researched pros/cons, recommendation, your constraints | WebSearch/Fetch + `abe` | §Tech Stack + decision log |
| 9 | **Architecture** — components, data flow, interfaces at agent altitude | — | §Architecture |
| 10 | **Synthesize** — distill all phases → final `SPEC.md`, self-review, hand to `writing-plans` | `superpowers:writing-plans` | finalized `SPEC.md` + `PLAN.md` |

## Defining & extracting features (phase 7 detail)

### "Critical" is a test, not a vibe

> A feature is **critical** if and only if at least one stated **Success
> Criterion** (phase 4) or **core user Job** (phase 3) cannot be met without it.

This makes criticality *derived and falsifiable*. Surviving features are the MVP
set; everything else is "Later" or "Won't." The classification **is** the scope
cut — there is no separate Scope phase.

**Traceability is bidirectional and both directions are checked:**
- A feature tracing to *no* SC/Job → gold-plating → cut it.
- An SC/Job with *no* implementing feature → a gap → you're under-built.

### Two extraction modes (because the input is two things)

- **Idea mode → derive backward from success.** For each core job and each
  success criterion, ask "what capability *must exist* to satisfy this?" → cluster,
  dedupe, then run the criticality test. You cannot invent features that serve nothing.
- **Code mode → observe, then diff.** `reverse-engineer` enumerates implemented
  features. Each is classified vs the current vision: **Keep** (serves a live
  job/SC), **Cut** (dead weight), **Rework** (right idea, wrong build). Then the
  **gap pass**: any job/SC with no implementing feature → a **missing critical
  feature**.

### Output: an agent-ready requirements table

| ID | Feature | Critical? | Serves (SC/Job) | Acceptance check | Status* |
|---|---|---|---|---|---|
| F1 | Resume mid-spec | ✅ | SC-2, Job-A | `/spec resume` continues from last phase | missing |
| F2 | URL ingestion | ⬜ later | Job-C | paste URL → cited in evidence | — |

\* `Status` appears only in code mode (exists / partial / missing). The
**acceptance check** is what makes each feature buildable — it becomes a
`writing-plans` milestone and a coding agent's verification target.

## Cross-cutting AI-assist (available in every phase)

- **URL ingestion** → `WebFetch` → cited evidence.
- **Research unknowns** → on "not sure," research via `WebSearch` / `deep-research`
  / `research-base` and bring findings back to react to, rather than stalling.
- **Ask other LLMs** → `abe` debate/validate + `second-opinion` for non-host
  perspectives; heavy in `--brutal`. Every consult logged to `evidence/`.
- **Cited memory** → `stele` stashes oversized tool results and recalls prior
  context, so phase 9 doesn't re-derive phase 2.

## State model (just files — no code)

```
spec/<slug>/
  SPEC.md          ← the living, synthesized deliverable
  evidence/        ← per-phase raw material + citations
    frame.md  why.md  mission-brief.md  market-intel.md
    stack-research.md  abe-debates.md  ...
```

`SPEC.md` carries a small **frontmatter progress block** — each phase
`pending | drafted | confirmed`, plus `intensity`, `input`, `slug`, `updated`.
That *is* the database. `/spec` with no args reads it and resumes; `/spec status`
renders it. State is saved per phase — quit any time.

Example frontmatter:

```yaml
---
slug: specy
input: "a tool that turns ideas into specs"
intensity: standard      # gentle | standard | brutal
updated: 2026-06-23
phases:
  frame: confirmed
  why: confirmed
  users: drafted
  success: pending
  compete: pending
  vision: pending
  features: pending
  stack: pending
  architecture: pending
  synthesize: pending
---
```

## Plugin structure (laziest shape that works)

```
specy/
  plugin.json
  commands/
    spec.md            ← ONE command; parses its arg and dispatches:
                          <idea|path> | status | resume | jump <p> | redo <p> | --brutal
  skills/
    phase-engine/SKILL.md   ← THE BRAIN: phase defs, probes, orchestration
                              map, state format, synthesis + self-review rules
  templates/
    SPEC.template.md
```

One command file + one skill. The single `/spec` command dispatches its
subcommands from `$ARGUMENTS` — no need for five command files when one
arg-parser does it.

## Error / edge handling

- No input, no existing spec → ask for an idea or path.
- Path isn't code → treat as notes.
- Multiple in-progress specs on `resume` → list, default to most-recent.
- **Sub-skill missing** (e.g., `market-intel` not installed) → degrade: do the
  research inline via `WebSearch`, note the degradation in evidence. specy never
  hard-depends on another skill being present.
- Oversized tool output → `stele` stash.

## Testing (prove it works — markdown-style, no framework)

Behavioral fixtures committed as proof:

- **Golden path:** `/spec` on a canned idea → all sections present, frontmatter
  all `confirmed`, evidence files exist.
- **Resume:** quit mid-phase → `/spec resume` continues from the right phase.
- **Codebase input:** `/spec ./<sample>` → §Current State populated from
  reverse-engineer.
- **Degradation:** simulate a missing sub-skill → inline fallback fires.

Captured as a short `TESTING.md` checklist + one sample `spec/` output committed
as a fixture.

## Out of scope (phase 2, logged)

TUI + web app. They extract `phase-engine` into a standalone program (the
deferred "helper script / MCP" paths). The `SPEC.md` + `evidence/` convention is
**frontend-agnostic on purpose** so those surfaces render the same state later.
Nothing in phase 1 paints us into a corner.

## Open questions

None blocking. Possible future tuning: whether `Architecture` (phase 9) should
fold into `Synthesize` for an even leaner v1 (kept separate for now — a coding
agent needs that altitude explicitly).

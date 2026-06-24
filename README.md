# specy

> `/spec` walks you from a fuzzy idea — or a pile of existing code — to a single
> authoritative `SPEC.md` a coding agent can build from, by interrogating *why*,
> researching what you don't know, pulling in other LLMs to attack your
> reasoning, and distilling everything into one document.

specy is a Claude Code plugin and it is **self-contained**: it ships its own
curated method skills (success definition, competitive analysis, prior-art
research, constitution, codebase mapping, gap analysis, persona voicing) and
**conducts** them through one interview — sequencing, interrogating, and
synthesizing into a single deep spec.

It runs **amplify-first**. The bundled methods are deliberately slim; the full
versions live in the public ai-skills library —
[yonk-labs/yonk-ai-skills](https://github.com/yonk-labs/yonk-ai-skills). If you have those
installed, specy automatically prefers them and falls back to its bundled
versions otherwise. Heavier separate tools (`abe` for multi-model debate,
`superpowers:writing-plans` for the final plan hand-off) are used if present
too. None of it is required — specy works standalone.

## Usage

```
/spec "a tool that turns ideas into specs"   # idea mode
/spec ./my-project                            # codebase mode (maps current state first)
/spec status                                  # what's answered / stubbed
/spec resume                                  # pick up where you left off
/spec jump stack                              # grab the wheel — go to a phase
/spec redo compete                            # rerun one phase
/spec "an idea" --brutal                      # bring the pain (AAT critique, + abe debates if installed)
```

Default temperament is **assertive** — it refuses vague answers and digs to
bedrock. Dial it with `--gentle` or `--brutal`.

## The 12 phases

Skills in `(parens)` are the bundled method each phase runs; `+ optional` marks
separate tools used only if installed.

1. **Frame** — intake; if a path, map current state (`reverse-engineer`)
2. **Why ×5** — relentless purpose dig (`+ abe` in brutal)
3. **Users & Jobs** — who, what job, what they do today
4. **Success** — what success means + the metric (`mission-brief`)
5. **Compete & Differentiate** — comps, why different (`market-intel`, `research-and-design` `+ abe`)
6. **Vision & Non-negotiables** — the experience you're picturing, principles (`constitution`)
7. **Features & Scope** — derive/extract features, rank by criticality (= the cut); one-line "how" per feature (`project-compass` in code mode)
8. **Design — How It Works** — co-design the mechanism for each critical feature/outcome; if you don't have a picture, specy proposes options and recommends one (`+ abe`)
9. **Stack** — researched pros/cons + recommendation (`+ abe`)
10. **Architecture** — components, data flow, interfaces at agent altitude
11. **Persona Review** — voice the people who'd use/buy/build it; capture their objections (`persona`)
12. **Synthesize** — distill → final `SPEC.md`, self-review, address objections, hand to `writing-plans` (`+ superpowers:writing-plans`)

## Output layout

```
spec/<slug>/
  SPEC.md          ← the living, synthesized deliverable
  evidence/        ← per-phase raw material + citations
```

State lives in `SPEC.md`'s YAML frontmatter (per-phase status + intensity) — the
filesystem is the database. Quit any time; `/spec resume` continues.

## Phase 2 (deferred)

A TUI and a web app over the same `SPEC.md` + `evidence/` convention. Not built
yet — the file format is frontend-agnostic on purpose so they can render the
same state later.

## Verify

`bash verify.sh` runs the structural checks. Behavioral tests are in
`TESTING.md`.

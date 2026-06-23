# specy

> `/spec` walks you from a fuzzy idea — or a pile of existing code — to a single
> authoritative `SPEC.md` a coding agent can build from, by interrogating *why*,
> researching what you don't know, pulling in other LLMs to attack your
> reasoning, and distilling everything into one document.

specy is a Claude Code plugin. It does not reimplement the thinking that already
lives across your skill library — it **conducts** it: sequencing, interrogating,
and synthesizing existing skills into one deep spec.

## Usage

```
/spec "a tool that turns ideas into specs"   # idea mode
/spec ./my-project                            # codebase mode (maps current state first)
/spec status                                  # what's answered / stubbed
/spec resume                                  # pick up where you left off
/spec jump stack                              # grab the wheel — go to a phase
/spec redo compete                            # rerun one phase
/spec "an idea" --brutal                      # bring the pain (abe debates + AAT critique)
```

Default temperament is **assertive** — it refuses vague answers and digs to
bedrock. Dial it with `--gentle` or `--brutal`.

## The 10 phases

1. **Frame** — intake; if a path, map current state (`reverse-engineer`)
2. **Why ×5** — relentless purpose dig
3. **Users & Jobs** — who, what job, what they do today
4. **Success** — what success means + the metric (`mission-brief`)
5. **Compete & Differentiate** — comps, why different (`market-intel`, `research-and-design`, `abe`)
6. **Vision & Non-negotiables** — your exact vision, principles (`constitution`)
7. **Features & Scope** — derive/extract features, rank by criticality (= the cut)
8. **Stack** — researched pros/cons + recommendation
9. **Architecture** — components, data flow, interfaces at agent altitude
10. **Synthesize** — distill → final `SPEC.md`, self-review, hand to `writing-plans`

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

# Testing specy

Two layers:

- **Structural (automated):** `bash verify.sh` — checks every file has its
  required shape. Run it after any edit. Must exit 0.
- **Behavioral (manual):** the four fixtures below. specy is a prompt plugin, so
  these are run by a human loading the plugin in Claude Code and observing — they
  can't be unit-tested. A committed sample run lives in `spec/example-idea/`.

## Fixture 1 — Golden path (idea mode)

1. Load the plugin in Claude Code.
2. Run `/spec "a tiny CLI that reminds you to drink water"`.
3. Answer each phase's probes briefly; let one research/abe consult run.

**Expected:**
- `spec/<slug>/SPEC.md` is created from the template.
- All 10 frontmatter phases reach `confirmed`.
- Every `##` section is filled (no remaining `_italic placeholder_` lines).
- `spec/<slug>/evidence/` contains per-phase files.
- The Features table has ≥1 Critical feature, each tracing to an SC/Job with an acceptance check.

## Fixture 2 — Resume

1. Start a run; answer through phase 3, then quit.
2. In a fresh session, run `/spec resume` (or `/spec` with no args).

**Expected:** it reads the frontmatter, reports phases 1–3 `confirmed`, and continues at phase 4 (Success) — no re-asking of answered phases.

## Fixture 3 — Codebase input (code mode)

1. Run `/spec ./<a small sample repo>`.

**Expected:** phase 1 (Frame) runs a `reverse-engineer` pass (or its inline fallback) and `## Overview / Current State` is populated with what the code does today; the Features table shows a `Status` column (exists/partial/missing).

## Fixture 4 — Degradation (missing sub-skill)

1. With `market-intel` not installed, run a spec to phase 5 (Compete).

**Expected:** the phase degrades to inline `WebSearch`, still names comparables, and `evidence/` notes the degradation. No hard failure.

## Regression

`bash verify.sh` is the fast gate. The committed `spec/example-idea/` fixture is
the reference output shape — if a change alters the SPEC structure, regenerate it.

---
name: reverse-engineer
description: Curated, self-contained codebase-mapping method bundled with specy. Invoked by the /spec phase engine (phases 1 Frame and 7 Features) to summarize an existing repo's current state and feature inventory. Not a general-purpose replacement for a full reverse-engineering skill.
---

# reverse-engineer (curated for specy)

Map an existing codebase into a current-state summary a SPEC can build on.

## Method
1. **Shape** — Glob the tree; read manifests (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, etc.) to identify language, framework, and entry points.
2. **Flow** — Read the entry point(s) and the 3-5 key modules; trace the main path from input to output in a few sentences.
3. **What works** — list the capabilities the code actually ships today.
4. **What hurts** — note rough edges: TODO/FIXME density, dead code, duplicated logic, missing tests, anything that looks fragile.
5. **Feature inventory** (for phase 7) — enumerate the discrete features the code already implements.

Do not refactor or judge style beyond what affects the spec. This is a read.

## Output
Write `evidence/frame.md`:
- **Stack:** language / framework / runtime.
- **Architecture (1 paragraph):** the major pieces and how they talk.
- **Capabilities:** bulleted list of what works.
- **Pain points:** bulleted list of what hurts.
- **Feature inventory:** bulleted list (reused by phase 7).

## Done when
Current state is summarized AND the feature inventory is listed.

---
*Slim, bundled method. The fuller version lives in [yonk-labs/yonk-ai-skills](https://github.com/yonk-labs/yonk-ai-skills) — specy prefers it automatically (amplify-first) when installed.*

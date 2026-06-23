# specy Spec Conductor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `specy`, a Claude Code plugin whose `/spec` command runs a guided, assertive, AI-assisted interview that turns an idea or an existing codebase into one agent-ready `SPEC.md`.

**Architecture:** Pure prompt-orchestration — Claude is the runtime, the filesystem is the database, and existing yonk skills are the heavy machinery. The plugin is markdown only: a single `/spec` command that dispatches to a `phase-engine` skill. The engine walks 10 phases, orchestrates sub-skills (`mission-brief`, `market-intel`, `reverse-engineer`, `abe`, `constitution`, `writing-plans`), and writes everything into `spec/<slug>/SPEC.md` plus an `evidence/` folder. State lives in the SPEC's YAML frontmatter.

**Tech Stack:** Markdown + YAML frontmatter. Claude Code plugin format (`.claude-plugin/plugin.json`, `commands/`, `skills/`). `jq` and `grep` for structural verification. No runtime, no build, no package manager, no new dependencies.

**Source spec:** `docs/superpowers/specs/2026-06-23-specy-spec-conductor-design.md` (read it before starting — this plan implements it).

## Global Constraints

Every task's requirements implicitly include these. Values are verbatim from the spec.

- **Zero new runtime dependencies.** Markdown only. No `package.json`, no server, no build step.
- **Plugin name:** `specy`. **Command:** `/spec`. **Output dir:** `spec/<slug>/`.
- **The repo root IS the plugin** (manifest at `.claude-plugin/plugin.json`, `commands/` and `skills/` at root). Phase-2 `tui/`/`web/` will be siblings later — do not scaffold them now (YAGNI).
- **The 10 phase keys, exact and ordered:** `frame, why, users, success, compete, vision, features, stack, architecture, synthesize`.
- **Phase status values:** `pending | drafted | confirmed`.
- **Intensity values:** `gentle | standard | brutal`. Default `standard`.
- **Never hard-depend on another skill being installed.** If a sub-skill is absent, degrade to inline `WebSearch`/reasoning and log the degradation in `evidence/`.
- **Route oversized tool output through `stele`** (per global CLAUDE.md), keeping the `stele://` ref.
- **Criticality is a test, not a vibe:** a feature is critical iff at least one Success Criterion or core Job cannot be met without it.

---

### Task 1: Plugin skeleton + manifest + cumulative verifier

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `README.md`
- Create: `verify.sh`
- Create: `commands/.gitkeep`, `skills/.gitkeep`, `templates/.gitkeep`

**Interfaces:**
- Produces: a loadable Claude Code plugin named `specy`; a `verify.sh` that later tasks append assertions to and that anyone can run with `bash verify.sh`.

- [ ] **Step 1: Confirm the manifest schema (cite-your-sources).**

Do not guess the manifest format. Consult the `plugin-dev:plugin-structure` skill (or run the `plugin-dev:create-plugin` command's reference) to confirm the exact location and required fields of `plugin.json`. Record what you confirm in a one-line comment in the commit message.

- [ ] **Step 2: Write the failing verifier first.**

Create `verify.sh`:

```bash
#!/usr/bin/env bash
# specy structural checks. Run: bash verify.sh
# Each task appends a check_* function and calls it. Exit non-zero on any failure.
set -uo pipefail
fail=0
ok()   { echo "  ok: $1"; }
bad()  { echo "FAIL: $1"; fail=1; }

check_manifest() {
  echo "== manifest =="
  [ -f .claude-plugin/plugin.json ] || { bad "manifest missing"; return; }
  jq -e . .claude-plugin/plugin.json >/dev/null 2>&1 || { bad "manifest not valid JSON"; return; }
  [ "$(jq -r .name .claude-plugin/plugin.json)" = "specy" ] || bad "manifest name != specy"
  ok "manifest valid, name=specy"
}

check_manifest
exit $fail
```

- [ ] **Step 3: Run it, watch it fail.**

Run: `bash verify.sh`
Expected: `FAIL: manifest missing` and non-zero exit.

- [ ] **Step 4: Create the manifest and directories.**

Create `.claude-plugin/plugin.json` (adjust fields to match what Step 1 confirmed; this is the expected shape):

```json
{
  "name": "specy",
  "description": "Guided, assertive, AI-assisted interview that turns an idea or codebase into one agent-ready SPEC.md.",
  "version": "0.1.0",
  "author": { "name": "yonk", "email": "matt@theyonk.com" },
  "keywords": ["spec", "prd", "strategy", "brainstorming", "requirements"]
}
```

Create `README.md` with: what specy is (one-liner from the spec), the `/spec` usage block, the 10 phases list, the `spec/<slug>/` output layout, and a "Phase 2 (deferred): TUI + web app" note. Create empty `commands/.gitkeep`, `skills/.gitkeep`, `templates/.gitkeep`.

- [ ] **Step 5: Run the verifier, watch it pass.**

Run: `bash verify.sh`
Expected: `ok: manifest valid, name=specy`, exit 0.

- [ ] **Step 6: Commit.**

```bash
git add .claude-plugin README.md verify.sh commands skills templates
git commit -m "feat(specy): plugin skeleton, manifest, and cumulative verifier"
```

---

### Task 2: SPEC.template.md — the output contract

**Files:**
- Create: `templates/SPEC.template.md`
- Modify: `verify.sh` (append `check_template`)

**Interfaces:**
- Produces: the canonical SPEC structure the engine fills. Frontmatter contract (consumed by every dispatch verb): keys `slug, input, intensity, updated, phases`; `phases` is a map of the 10 phase keys → status. Body contract: one `##` section per phase output named in the spec's phase table.

- [ ] **Step 1: Append the failing check to `verify.sh`.**

Add before the final `exit`:

```bash
check_template() {
  echo "== template =="
  local f=templates/SPEC.template.md
  [ -f "$f" ] || { bad "template missing"; return; }
  for k in slug input intensity updated phases; do
    grep -q "^$k:" "$f" || bad "frontmatter missing key: $k"
  done
  for p in frame why users success compete vision features stack architecture synthesize; do
    grep -q "  $p:" "$f" || bad "phases block missing: $p"
  done
  for h in "Overview" "Why" "Users" "Success Criteria" "Competitive" "Vision" "Features" "Tech Stack" "Architecture"; do
    grep -q "^## .*$h" "$f" || bad "section header missing: $h"
  done
  ok "template has frontmatter contract + all sections"
}
check_template
```

(Move the existing `exit $fail` to the very end, after this call.)

- [ ] **Step 2: Run `bash verify.sh`, watch `check_template` fail** ("template missing").

- [ ] **Step 3: Write `templates/SPEC.template.md`.**

Frontmatter block (exact keys):

```markdown
---
slug: <slug>
input: "<idea text or ./repo/path>"
intensity: standard
updated: <YYYY-MM-DD>
phases:
  frame: pending
  why: pending
  users: pending
  success: pending
  compete: pending
  vision: pending
  features: pending
  stack: pending
  architecture: pending
  synthesize: pending
---
```

Body: one `##` section per phase output, in order — `## Overview / Current State`, `## Problem & Why`, `## Users & Use Cases`, `## Success Criteria`, `## Competitive Landscape`, `## Differentiation`, `## Product Vision & Principles`, `## Features & Requirements` (include the requirements table header: `| ID | Feature | Critical? | Serves (SC/Job) | Acceptance check | Status |`), `## Scope` (In / Later / Won't), `## Tech Stack` (+ decision log subhead), `## Architecture`. Each section starts with an HTML comment `<!-- phase: <key> -->` so the engine can locate where to write.

- [ ] **Step 4: Run `bash verify.sh`, watch it pass.** Expected: `ok: template has frontmatter contract + all sections`.

- [ ] **Step 5: Commit.**

```bash
git add templates/SPEC.template.md verify.sh
git commit -m "feat(specy): SPEC output template with frontmatter state contract"
```

---

### Task 3: phases.md — the 10-phase playbook

**Files:**
- Create: `skills/phase-engine/phases.md`
- Modify: `verify.sh` (append `check_phases`)

**Interfaces:**
- Produces: the per-phase playbook the SKILL.md links to. Each phase entry has: **Goal**, **Probes** (the "why"/Socratic questions), **Orchestrates** (sub-skill calls + degradation fallback), **Writes** (which `<!-- phase: -->` section + what content), **Done-when** (the condition to flip status `confirmed`).

- [ ] **Step 1: Append failing check to `verify.sh`:**

```bash
check_phases() {
  echo "== phases playbook =="
  local f=skills/phase-engine/phases.md
  [ -f "$f" ] || { bad "phases.md missing"; return; }
  for p in Frame Why Users Success Compete Vision Features Stack Architecture Synthesize; do
    grep -qi "^### .*$p" "$f" || bad "phase section missing: $p"
  done
  for s in "Goal" "Probes" "Orchestrates" "Writes" "Done-when"; do
    grep -q "$s" "$f" || bad "phase template field missing: $s"
  done
  grep -qi "degrade" "$f" || bad "no degradation fallback documented"
  ok "phases.md has all 10 phases with full template"
}
check_phases
```

- [ ] **Step 2: Run `bash verify.sh`, watch it fail** ("phases.md missing").

- [ ] **Step 3: Write `skills/phase-engine/phases.md`.** One `###` per phase, each with the five fields. Use the spec's phase table as the source of truth. Worked example for the first phase (write all 10 in this shape — do not abbreviate later ones):

```markdown
### 1. Frame
- **Goal:** Establish the one-line premise and intake mode (idea vs codebase).
- **Probes:** "In one sentence, what is this?" If a path was given: "What works today, and what hurts?"
- **Orchestrates:** If input is a path → run `reverse-engineer` to map current state; write its summary to `evidence/frame.md`. If `reverse-engineer` is absent → degrade: inline-scan the repo (Glob/Grep/Read) and summarize; note the degradation in `evidence/frame.md`.
- **Writes:** `<!-- phase: frame -->` section → `## Overview / Current State`.
- **Done-when:** premise is one clear sentence AND (idea mode) the problem is nameable, or (code mode) current state is summarized.
```

Then phases 2–10 in the same template, with these orchestration mappings (verbatim from the spec): **Why** → Socratic only; **Users** → none; **Success** → `mission-brief` (degrade: inline criteria); **Compete** → `market-intel` + `research-and-design` + `abe` (degrade: inline `WebSearch`); **Vision** → `constitution` (degrade: inline principles list); **Features** → see `criticality.md` (Task 4); **Stack** → `WebSearch`/`WebFetch` + `abe` second opinions; **Architecture** → none; **Synthesize** → distill all sections, run self-review (placeholder/contradiction/ambiguity scan), then hand to `superpowers:writing-plans`.

- [ ] **Step 4: Run `bash verify.sh`, watch it pass.**

- [ ] **Step 5: Commit.**

```bash
git add skills/phase-engine/phases.md verify.sh
git commit -m "feat(specy): 10-phase interview playbook"
```

---

### Task 4: criticality.md — feature extraction + the criticality test

**Files:**
- Create: `skills/phase-engine/criticality.md`
- Modify: `verify.sh` (append `check_criticality`)

**Interfaces:**
- Produces: the phase-7 detail referenced by `phases.md`. Defines the criticality test, the two extraction modes (idea/code), the bidirectional traceability check, and the exact requirements-table columns the Features section uses.

- [ ] **Step 1: Append failing check to `verify.sh`:**

```bash
check_criticality() {
  echo "== criticality =="
  local f=skills/phase-engine/criticality.md
  [ -f "$f" ] || { bad "criticality.md missing"; return; }
  grep -qi "Success Criterion" "$f" || bad "criticality test not anchored to Success Criteria"
  grep -qi "idea mode" "$f" || bad "idea-mode extraction missing"
  grep -qi "code mode" "$f" || bad "code-mode extraction missing"
  grep -qi "Acceptance check" "$f" || bad "requirements table columns missing"
  ok "criticality.md complete"
}
check_criticality
```

- [ ] **Step 2: Run `bash verify.sh`, watch it fail.**

- [ ] **Step 3: Write `skills/phase-engine/criticality.md`** containing, verbatim-faithful to the spec's "Defining & extracting features" section: (a) the criticality definition; (b) bidirectional traceability — feature→SC/Job and SC/Job→feature, with both failure modes (gold-plating, gap); (c) **idea mode** = derive backward from each Job and SC; (d) **code mode** = `reverse-engineer` enumerate → classify Keep/Cut/Rework → gap pass; (e) the requirements table columns `ID | Feature | Critical? | Serves (SC/Job) | Acceptance check | Status` with the note that `Status` appears only in code mode; (f) the rule that the classification IS the scope cut (In=critical, Later=could, Won't).

- [ ] **Step 4: Run `bash verify.sh`, watch it pass.**

- [ ] **Step 5: Commit.**

```bash
git add skills/phase-engine/criticality.md verify.sh
git commit -m "feat(specy): feature extraction + criticality traceability test"
```

---

### Task 5: SKILL.md — the engine (dispatch, state, intensity, loop)

**Files:**
- Create: `skills/phase-engine/SKILL.md`
- Modify: `verify.sh` (append `check_skill`)

**Interfaces:**
- Consumes: `phases.md`, `criticality.md`, `templates/SPEC.template.md`.
- Produces: the brain the `/spec` command invokes. Defines the dispatch grammar, the run loop, state read/write rules, intensity behavior, cross-cutting AI-assist, and error handling.

- [ ] **Step 1: Append failing check to `verify.sh`:**

```bash
check_skill() {
  echo "== SKILL =="
  local f=skills/phase-engine/SKILL.md
  [ -f "$f" ] || { bad "SKILL.md missing"; return; }
  head -12 "$f" | grep -q "^name:" || bad "SKILL.md missing frontmatter name"
  head -12 "$f" | grep -q "^description:" || bad "SKILL.md missing frontmatter description"
  for v in status resume jump redo; do
    grep -q "$v" "$f" || bad "dispatch verb missing: $v"
  done
  grep -q "phases.md" "$f" || bad "does not reference phases.md"
  grep -q "criticality.md" "$f" || bad "does not reference criticality.md"
  grep -qi "brutal" "$f" || bad "intensity dial not documented"
  grep -qi "stele" "$f" || bad "oversized-output rule missing"
  ok "SKILL.md complete"
}
check_skill
```

- [ ] **Step 2: Run `bash verify.sh`, watch it fail.**

- [ ] **Step 3: Write `skills/phase-engine/SKILL.md`.** Required frontmatter: `name: phase-engine`, `description:` (one line: when to use — driving a /spec interview). Body sections:
  1. **Dispatch grammar** — parse `$ARGUMENTS`: empty or `resume` → load latest `spec/<slug>/SPEC.md`, read frontmatter, continue at first non-`confirmed` phase; `status` → render the phases checklist; `jump <phasekey>` → set cursor to that phase; `redo <phasekey>` → reset that phase to `pending` and re-run; a `./path` → code mode; any other text → idea mode; trailing `--brutal`/`--gentle` → set intensity.
  2. **Slug + state** — derive `<slug>` from the idea/repo name; create `spec/<slug>/` from `templates/SPEC.template.md` on first run; after each phase, write the section, set that phase's status (`drafted` when written, `confirmed` when the Done-when in `phases.md` is met), bump `updated`. The frontmatter is the single source of truth; re-read it each turn.
  3. **Run loop** — for the current phase: read its entry in `phases.md`, ask Probes one at a time, orchestrate its sub-skill (with degradation per Global Constraints), write its section, flip status, summarize + advance. Phase 7 follows `criticality.md`.
  4. **Intensity** — `gentle`: supportive probes. `standard` (default): refuse vague answers, dig to bedrock, flag weak differentiation. `brutal`: additionally invoke `abe` debate + AAT-style critique to attack the reasoning; log to `evidence/abe-*.md`.
  5. **Cross-cutting AI-assist** — URL paste → `WebFetch` → cited evidence; "not sure" → research (`WebSearch`/`deep-research`/`research-base`) and bring findings back; oversized tool output → `stele` stash, keep the ref.
  6. **Error handling** — no input + no existing spec → ask for idea/path; path isn't code → treat as notes; multiple specs on `resume` → list, default most-recent.

- [ ] **Step 4: Run `bash verify.sh`, watch it pass.**

- [ ] **Step 5: Commit.**

```bash
git add skills/phase-engine/SKILL.md verify.sh
git commit -m "feat(specy): phase-engine skill — dispatch, state, intensity, loop"
```

---

### Task 6: /spec command

**Files:**
- Create: `commands/spec.md`
- Delete: `commands/.gitkeep`
- Modify: `verify.sh` (append `check_command`)

**Interfaces:**
- Consumes: the `phase-engine` skill.
- Produces: the user-facing `/spec` slash command. Thin: forwards `$ARGUMENTS` to the engine.

- [ ] **Step 1: Append failing check to `verify.sh`:**

```bash
check_command() {
  echo "== command =="
  local f=commands/spec.md
  [ -f "$f" ] || { bad "spec.md missing"; return; }
  grep -q "ARGUMENTS" "$f" || bad "command does not pass \$ARGUMENTS"
  grep -qi "phase-engine" "$f" || bad "command does not invoke phase-engine"
  ok "command wired to engine"
}
check_command
```

- [ ] **Step 2: Run `bash verify.sh`, watch it fail.**

- [ ] **Step 3: Confirm command frontmatter fields** against `plugin-dev:command-development` (cite-your-sources), then write `commands/spec.md`. Frontmatter: `description: Turn an idea or codebase into one agent-ready SPEC.md (guided interview).` and an `argument-hint` like `[idea | ./path | status | resume | jump <phase> | redo <phase>] [--brutal|--gentle]`. Body: instruct Claude to invoke the `phase-engine` skill, passing `$ARGUMENTS`, and to follow it exactly. Then `rm commands/.gitkeep`.

- [ ] **Step 4: Run `bash verify.sh`, watch it pass.**

- [ ] **Step 5: Commit.**

```bash
git add commands/spec.md verify.sh && git rm --cached commands/.gitkeep 2>/dev/null; git commit -m "feat(specy): /spec command wired to phase-engine"
```

---

### Task 7: TESTING.md + manual golden-path acceptance run

**Files:**
- Create: `TESTING.md`
- Create: `spec/example-idea/` (committed fixture from the golden-path run)

**Interfaces:**
- Consumes: the whole plugin.
- Produces: the behavioral test checklist (from the spec's Testing section) and one committed sample run proving end-to-end behavior.

- [ ] **Step 1: Write `TESTING.md`** with the four behavioral fixtures from the spec as a manual checklist: Golden path, Resume, Codebase input, Degradation. For each: exact steps and the expected observable result (sections present, frontmatter `confirmed`, evidence files exist, etc.).

- [ ] **Step 2: Structural regression check.** Run `bash verify.sh`. Expected: every `check_*` prints `ok` and exit 0. This is the automated gate.

- [ ] **Step 3: Manual golden-path run (cannot be automated — it's a prompt).** Install/load the plugin in Claude Code. Run `/spec "a tool that turns ideas into specs"`. Walk the phases (use short answers; let research/abe run once). Verify: `spec/example-idea/SPEC.md` exists, all 10 frontmatter phases reach `confirmed`, all `##` sections are filled, `evidence/` contains per-phase files. Note any deviation as a follow-up task.

- [ ] **Step 4: Commit the fixture as proof.**

```bash
git add TESTING.md spec/example-idea
git commit -m "test(specy): behavioral checklist + golden-path fixture"
```

---

## Self-Review

**1. Spec coverage** — every spec section maps to a task:
- Inputs (idea/code/URL) → Tasks 3, 5 (Frame phase + cross-cutting). ✅
- 10 phases → Task 3. ✅
- Criticality + extraction → Task 4. ✅
- Cross-cutting AI-assist (URL/research/abe/stele) → Task 5 §5. ✅
- State model (frontmatter) → Tasks 2 (contract) + 5 (read/write). ✅
- Plugin structure → Tasks 1, 5, 6. ✅
- Error/degradation → Global Constraints + Tasks 3, 5. ✅
- Testing → Task 7. ✅
- Temperament dial → Task 5 §4. ✅

**2. Placeholder scan** — no "TBD"/"add error handling"/"similar to". Content files specify exact required structure + cite the spec for prose; the `.gitkeep` files are real scaffolding, not placeholders. ✅

**3. Type/name consistency** — phase keys identical across Global Constraints, Task 2 frontmatter, Task 3 checks, Task 5 dispatch. Dispatch verbs (`status/resume/jump/redo`) consistent between Tasks 5 and 6. `<!-- phase: <key> -->` markers introduced in Task 2 and consumed in Tasks 3/5. ✅

**Note on TDD adaptation:** content artifacts are verified by appending assertions to `verify.sh` (write check → watch fail → author file → watch pass → commit). The one unavoidable manual gate is Task 7 Step 3 (running a prompt).

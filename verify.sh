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

check_template() {
  echo "== template =="
  local f=templates/SPEC.template.md
  [ -f "$f" ] || { bad "template missing"; return; }
  for k in slug input intensity updated phases; do
    grep -q "^$k:" "$f" || bad "frontmatter missing key: $k"
  done
  for p in frame why users success compete vision features design stack architecture personas synthesize; do
    grep -q "  $p:" "$f" || bad "phases block missing: $p"
  done
  for h in "Overview" "Why" "Users" "Success Criteria" "Competitive" "Vision" "Features" "Design" "Tech Stack" "Architecture" "Persona Feedback"; do
    grep -q "^## .*$h" "$f" || bad "section header missing: $h"
  done
  ok "template has frontmatter contract + all sections"
}

check_phases() {
  echo "== phases playbook =="
  local f=skills/phase-engine/phases.md
  [ -f "$f" ] || { bad "phases.md missing"; return; }
  for p in Frame Why Users Success Compete Vision Features Design Stack Architecture "Persona Review" Synthesize; do
    grep -qi "^### .*$p" "$f" || bad "phase section missing: $p"
  done
  for s in "Goal" "Probes" "Orchestrates" "Writes" "Done-when"; do
    grep -q "$s" "$f" || bad "phase template field missing: $s"
  done
  grep -qi "degrade" "$f" || bad "no degradation fallback documented"
  grep -qi "propose mode" "$f" || bad "Design phase propose-mode not documented"
  ok "phases.md has all 12 phases with full template"
}

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
  ok "SKILL.md complete"
}

check_bundled_skills() {
  echo "== bundled skills =="
  local p=skills/phase-engine/phases.md
  for s in reverse-engineer mission-brief market-intel research-and-design constitution project-compass persona; do
    local f="skills/$s/SKILL.md"
    [ -f "$f" ] || { bad "bundled skill missing: $s"; continue; }
    head -5 "$f" | grep -q "^name: $s" || bad "$s: frontmatter name mismatch"
    grep -q "$s" "$p" || bad "phases.md does not reference method skill: $s"
  done
  # amplify-first contract: prefer full skills, fall back to bundled specy:* — never hard-depend on the external lib
  grep -qi "amplify-first" "$p" || bad "phases.md missing amplify-first resolution rule"
  grep -q 'specy:' "$p" || bad "phases.md missing bundled specy: fallback"
  grep -q 'github.com/yonk-labs/yonk-ai-skills' "$p" || bad "phases.md missing full-skills repo link"
  ok "7 method skills bundled, wired, amplify-first documented"
}

check_command() {
  echo "== command =="
  local f=commands/spec.md
  [ -f "$f" ] || { bad "spec.md missing"; return; }
  grep -q "ARGUMENTS" "$f" || bad "command does not pass \$ARGUMENTS"
  grep -qi "phase-engine" "$f" || bad "command does not invoke phase-engine"
  ok "command wired to engine"
}

check_manifest
check_template
check_phases
check_criticality
check_skill
check_bundled_skills
check_command
exit $fail

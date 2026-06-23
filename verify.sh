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
  for p in frame why users success compete vision features stack architecture synthesize; do
    grep -q "  $p:" "$f" || bad "phases block missing: $p"
  done
  for h in "Overview" "Why" "Users" "Success Criteria" "Competitive" "Vision" "Features" "Tech Stack" "Architecture"; do
    grep -q "^## .*$h" "$f" || bad "section header missing: $h"
  done
  ok "template has frontmatter contract + all sections"
}

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

check_manifest
check_template
check_phases
check_criticality
exit $fail

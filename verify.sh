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

#!/usr/bin/env bash
# harness.sh
# The agent's self-validation harness. Runs the 10 layers and emits a single
# JSON summary consumed by spring-validator.
#
# Usage:
#   ./scripts/harness.sh                  # run; print human summary; exit non-zero on failure
#   ./scripts/harness.sh --report         # run; emit harness-summary.json to stdout
#   ./scripts/harness.sh --baseline       # run in capture mode for brownfield onboarding

set -euo pipefail

MODE="${1:-run}"
SUMMARY="target/harness-summary.json"
mkdir -p target

# Helper: timestamped section
section() { echo "=== $* ==="; }

# Detect stack so we know which layers to enforce.
STACK_JSON="$(./scripts/detect-stack.sh 2>/dev/null || echo '{}')"

has_layer() {
  echo "$STACK_JSON" | jq -r ".harness_layers.$1 // false"
}

# 1-9 sequential layers via Maven verify; PIT separately under -Ppit.
section "format + compile + static + arch + unit + it + coverage + security"
mvn -B -ntp verify

if [ "$(has_layer pit)" = "true" ]; then
  section "mutation (incremental)"
  mvn -B -ntp -Ppit org.pitest:pitest-maven:mutationCoverage || PIT_RC=$?
fi

# Contract diff if openapi spec is present.
if [ -f src/main/resources/openapi/openapi.yaml ]; then
  section "openapi contract diff"
  prev="$(git show "origin/main:src/main/resources/openapi/openapi.yaml" 2>/dev/null || true)"
  if [ -n "$prev" ]; then
    echo "$prev" > target/openapi-base.yaml
    if command -v openapi-diff >/dev/null 2>&1; then
      openapi-diff target/openapi-base.yaml src/main/resources/openapi/openapi.yaml --json > target/openapi-diff.json || true
    else
      echo "WARN: openapi-diff CLI not installed; skipping (run: npm i -g @apidevtools/swagger-cli or use openapitools/openapi-diff docker image)" >&2
    fi
  fi
fi

# Build the summary JSON. Best-effort parse — layers without reports just emit "skipped".
parse_surefire() {
  local dir="$1"
  [ -d "$dir" ] || { echo '{"status":"skipped"}'; return; }
  local total=0 fail=0 err=0 skip=0
  while IFS= read -r f; do
    t=$(grep -oE 'tests="[0-9]+"' "$f" | head -n1 | grep -oE '[0-9]+' || echo 0)
    fa=$(grep -oE 'failures="[0-9]+"' "$f" | head -n1 | grep -oE '[0-9]+' || echo 0)
    er=$(grep -oE 'errors="[0-9]+"' "$f" | head -n1 | grep -oE '[0-9]+' || echo 0)
    sk=$(grep -oE 'skipped="[0-9]+"' "$f" | head -n1 | grep -oE '[0-9]+' || echo 0)
    total=$((total+t)); fail=$((fail+fa)); err=$((err+er)); skip=$((skip+sk))
  done < <(find "$dir" -name 'TEST-*.xml')
  local status="pass"
  [ "$fail" -gt 0 ] || [ "$err" -gt 0 ] && status="fail"
  printf '{"status":"%s","tests":%d,"failures":%d,"errors":%d,"skipped":%d}' "$status" "$total" "$fail" "$err" "$skip"
}

parse_jacoco() {
  local f="target/site/jacoco/jacoco.xml"
  [ -f "$f" ] || { echo '{"status":"skipped"}'; return; }
  local line_missed line_covered branch_missed branch_covered
  line_missed=$(grep -E '<counter type="LINE"' "$f" | tail -n1 | grep -oE 'missed="[0-9]+"' | grep -oE '[0-9]+' || echo 0)
  line_covered=$(grep -E '<counter type="LINE"' "$f" | tail -n1 | grep -oE 'covered="[0-9]+"' | grep -oE '[0-9]+' || echo 0)
  branch_missed=$(grep -E '<counter type="BRANCH"' "$f" | tail -n1 | grep -oE 'missed="[0-9]+"' | grep -oE '[0-9]+' || echo 0)
  branch_covered=$(grep -E '<counter type="BRANCH"' "$f" | tail -n1 | grep -oE 'covered="[0-9]+"' | grep -oE '[0-9]+' || echo 0)
  local lt=$((line_missed+line_covered)); local bt=$((branch_missed+branch_covered))
  local lr="0"; [ "$lt" -gt 0 ] && lr=$(awk "BEGIN{printf \"%.4f\", $line_covered/$lt}")
  local br="0"; [ "$bt" -gt 0 ] && br=$(awk "BEGIN{printf \"%.4f\", $branch_covered/$bt}")
  local status="pass"
  awk "BEGIN{exit !($lr < 0.90 || $br < 0.90)}" && status="fail"
  printf '{"status":"%s","line":%s,"branch":%s}' "$status" "$lr" "$br"
}

parse_pit() {
  local f="target/pit-reports/mutations.xml"
  [ -f "$f" ] || { echo '{"status":"skipped"}'; return; }
  local total survived
  total=$(grep -c '<mutation ' "$f" || echo 0)
  survived=$(grep -c 'status="SURVIVED"' "$f" || echo 0)
  local kr="0"; [ "$total" -gt 0 ] && kr=$(awk "BEGIN{printf \"%.4f\", ($total-$survived)/$total}")
  local status="pass"; [ "$survived" -gt 0 ] && status="warn"
  printf '{"status":"%s","kill_rate":%s,"survived":%d,"total":%d}' "$status" "$kr" "$survived" "$total"
}

unit=$(parse_surefire target/surefire-reports)
it=$(parse_surefire target/failsafe-reports)
cov=$(parse_jacoco)
pit=$(parse_pit)

cat > "$SUMMARY" <<EOF
{
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "git_sha": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
  "stack": $STACK_JSON,
  "gates": {
    "unit":     $unit,
    "it":       $it,
    "coverage": $cov,
    "mutation": $pit
  }
}
EOF

if [ "$MODE" = "--report" ]; then
  cat "$SUMMARY"
elif [ "$MODE" = "--baseline" ]; then
  jq '{captured_at: .started_at, git_sha, stack, gates}' "$SUMMARY" > .specs/_baseline.json
  echo "Wrote .specs/_baseline.json"
else
  echo
  jq '.gates' "$SUMMARY"
fi

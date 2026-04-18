#!/usr/bin/env bash
# check-new-code-coverage.sh
# Computes coverage on lines changed in the working tree vs origin/main and fails
# if the new-code coverage ratio is below the configured threshold (default 0.95).
# Inputs:
#   target/site/jacoco/jacoco.xml  (line-level coverage report)
#   git diff against ${BASE_REF:-origin/main}
# Output:
#   target/new-code-coverage.json
# Exit:
#   0 = pass, 1 = below threshold, 2 = missing inputs

set -euo pipefail

THRESHOLD="${NEW_CODE_THRESHOLD:-0.95}"
BASE_REF="${BASE_REF:-origin/main}"
JACOCO_XML="target/site/jacoco/jacoco.xml"
OUT="target/new-code-coverage.json"

if [ ! -f "$JACOCO_XML" ]; then
  echo "ERROR: $JACOCO_XML not found. Run mvn verify first." >&2
  exit 2
fi

# Get changed Java files in src/main and the line ranges added.
mapfile -t changed_files < <(git diff --name-only "$BASE_REF" -- 'src/main/**/*.java' 2>/dev/null || true)
if [ "${#changed_files[@]}" -eq 0 ]; then
  echo '{"status":"pass","reason":"no Java changes in src/main","ratio":1.0,"threshold":'"$THRESHOLD"'}' | tee "$OUT"
  exit 0
fi

# Build a mapping file -> set of added/changed line numbers.
total_new=0
covered_new=0

for f in "${changed_files[@]}"; do
  # Added/changed line numbers from unified diff (RHS).
  mapfile -t lines < <(git diff -U0 "$BASE_REF" -- "$f" \
    | awk '/^@@/ { match($0,/\+([0-9]+)(,([0-9]+))?/,a); start=a[1]+0; len=(a[3]==""?1:a[3]+0); for(i=0;i<len;i++) print start+i }')

  [ "${#lines[@]}" -eq 0 ] && continue

  # Class path inside jacoco.xml uses the source file relative path; query each line.
  src_rel="$(echo "$f" | sed -E 's|^src/main/java/||')"
  src_pkg="$(dirname "$src_rel" | tr '/' '.')"
  src_name="$(basename "$src_rel")"

  for ln in "${lines[@]}"; do
    total_new=$((total_new+1))
    # Find <line nr="ln" mi="..." ci="..."/> within the matching <sourcefile name="X.java"> under the right package.
    hit=$(awk -v pkg="$src_pkg" -v name="$src_name" -v ln="$ln" '
      /<package name=/ { match($0,/name="([^"]+)"/,a); cur_pkg=a[1]; gsub("/",".",cur_pkg) }
      /<sourcefile name=/ { match($0,/name="([^"]+)"/,a); cur_file=a[1]; in_file = (cur_pkg==pkg && cur_file==name) }
      in_file && /<line nr=/ {
        match($0,/nr="([0-9]+)"/,a); n=a[1]+0
        if (n==ln) {
          match($0,/ci="([0-9]+)"/,c); ci=c[1]+0
          print (ci>0 ? "1" : "0"); exit
        }
      }
    ' "$JACOCO_XML")
    [ "$hit" = "1" ] && covered_new=$((covered_new+1))
  done
done

ratio="0"
[ "$total_new" -gt 0 ] && ratio=$(awk "BEGIN{printf \"%.4f\", $covered_new/$total_new}")

status="pass"
awk "BEGIN{exit !($ratio < $THRESHOLD)}" && status="fail"

cat > "$OUT" <<EOF
{
  "status": "$status",
  "ratio": $ratio,
  "covered_new_lines": $covered_new,
  "total_new_lines": $total_new,
  "threshold": $THRESHOLD,
  "base_ref": "$BASE_REF"
}
EOF

cat "$OUT"
[ "$status" = "pass" ] || exit 1

#!/usr/bin/env bash
# traceability.sh
# Builds the AC-NNN -> tests + code matrix for a feature and writes
# .specs/<feature>/07a-traceability.md.
#
# Usage: scripts/traceability.sh <feature-id>

set -euo pipefail

FEATURE="${1:-}"
if [ -z "$FEATURE" ]; then
  echo "Usage: $0 <feature-id>" >&2
  exit 2
fi

SPEC="$(ls .specs/$FEATURE/01-*.md 2>/dev/null | head -n 1)"
if [ -z "$SPEC" ] || [ ! -f "$SPEC" ]; then
  echo "ERROR: spec not found at .specs/$FEATURE/01-*.md" >&2
  exit 2
fi

OUT=".specs/$FEATURE/07a-traceability.md"

# Extract AC-NNN headings and titles from the spec.
mapfile -t acs < <(grep -E '^### AC-[0-9]+' "$SPEC" | sed -E 's/^### (AC-[0-9]+)[[:space:]]*[:.-][[:space:]]*(.*)/\1|\2/')

{
  echo "# Traceability: $FEATURE"
  echo
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "| AC | Title | Tests | Production code |"
  echo "|----|-------|-------|-----------------|"
  for entry in "${acs[@]}"; do
    ac="${entry%%|*}"
    title="${entry#*|}"
    # Tests: search for @Tag("AC-NNN") in src/test.
    tests=$(grep -RIl --include='*.java' "@Tag(\"$ac\")" src/test 2>/dev/null \
      | sed -E 's|^src/test/java/||; s|\.java$||; s|/|.|g' | tr '\n' ',' | sed 's/,$//')
    # Code: best-effort — production classes referenced by those tests' imports.
    test_files=$(grep -RIl --include='*.java' "@Tag(\"$ac\")" src/test 2>/dev/null || true)
    code=""
    if [ -n "$test_files" ]; then
      code=$(grep -h -E '^import [a-z]' $test_files 2>/dev/null \
        | grep -v '^import (java\.|org\.junit|org\.springframework\.test|org\.testcontainers|static )' \
        | sed -E 's/^import (.+);$/\1/' | sort -u | tr '\n' ',' | sed 's/,$//')
    fi
    echo "| $ac | ${title:-(no title)} | ${tests:-_(none)_} | ${code:-_(unknown)_} |"
  done
  echo
  echo "## Notes"
  echo
  echo "- An AC with no tests is a hard validation failure."
  echo "- Production code column is heuristic (test imports). Verify manually for accuracy."
} > "$OUT"

echo "Wrote $OUT"

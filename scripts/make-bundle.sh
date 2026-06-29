#!/usr/bin/env bash
# make-bundle.sh — flatten the whole repo into a single BUNDLE.md so an LLM can
# review EVERYTHING in one shot (GPT/Claude browsing fetches one page at a time and
# won't traverse subfolders; this gives it one file with all content).
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO/BUNDLE.md"

FILES=$(cd "$REPO" && find README.md docs goals reference scripts sources.lock -type f 2>/dev/null | sort)

{
  echo "# whitelabel-collab — FULL BUNDLE (auto-generated for one-shot LLM review)"
  echo
  echo "> Every authored doc, goal, script, and reference catalog concatenated into one file."
  echo "> Repo: https://github.com/shinjadong/whitelabel-collab · regenerate: \`scripts/make-bundle.sh\`"
  echo
  echo "## Index"
  while IFS= read -r f; do echo "- \`$f\`"; done <<< "$FILES"
  echo
  while IFS= read -r f; do
    echo
    echo "<!-- ============================================================ -->"
    echo "## FILE: \`$f\`"
    echo
    if [[ "$f" == *.md ]]; then
      cat "$REPO/$f"
    else
      echo '```'
      cat "$REPO/$f"
      echo '```'
    fi
    echo
  done <<< "$FILES"
} > "$OUT"

echo "wrote $OUT — $(wc -l < "$OUT") lines, $(du -h "$OUT" | cut -f1)"

#!/usr/bin/env bash
# bootstrap.sh — reconstruct the FULL reference environment on a fresh device
# (e.g. a new AWS box) so it is byte-identical to where this repo was authored.
#
# It does NOT vendor Mattermost source into this repo (legal: server/enterprise is
# Source Available; practical: 1.3 GB). Instead it clones each upstream repo at the
# EXACT commit pinned in sources.lock, then regenerates the contract catalogs.
#
# Usage:
#   ./scripts/bootstrap.sh                 # clone all sources into ~/mattermost-src, rebuild catalogs
#   SRC_DIR=/data/mm-src ./scripts/bootstrap.sh
#   CORE_ONLY=1 ./scripts/bootstrap.sh     # skip heavy mobile/desktop repos
#
# Requirements on the target box: git, python3.  (No GitHub auth needed — upstreams are public.)
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="${SRC_DIR:-$HOME/mattermost-src}"
LOCK="$REPO/sources.lock"
CORE_ONLY="${CORE_ONLY:-0}"

command -v git    >/dev/null || { echo "!! git required";    exit 1; }
command -v python3>/dev/null || { echo "!! python3 required"; exit 1; }
[ -f "$LOCK" ] || { echo "!! sources.lock not found at $LOCK"; exit 1; }

mkdir -p "$SRC_DIR"
echo ">> bootstrapping reference sources into $SRC_DIR (CORE_ONLY=$CORE_ONLY)"

OPTIONAL="mattermost-mobile desktop"

clone_pinned() {
  local name="$1" url="$2" sha="$3"
  local dir="$SRC_DIR/$name"
  if [ -d "$dir/.git" ]; then
    local have; have="$(git -C "$dir" rev-parse HEAD 2>/dev/null || echo none)"
    if [ "$have" = "$sha" ]; then echo "   = $name already at $sha"; return; fi
    echo "   ~ $name re-pinning $have -> $sha"
  else
    echo "   + $name @ $sha"
    git init -q "$dir"
    git -C "$dir" remote add origin "$url"
  fi
  # fetch exactly the pinned commit (GitHub allows fetch-by-sha), shallow.
  git -C "$dir" fetch -q --depth 1 origin "$sha"
  git -C "$dir" checkout -q FETCH_HEAD
}

while read -r name url sha _branch; do
  [ -z "${name:-}" ] && continue
  case "$name" in \#*) continue;; esac
  if [ "$CORE_ONLY" = "1" ] && echo " $OPTIONAL " | grep -q " $name "; then
    echo "   - skip (optional) $name"; continue
  fi
  clone_pinned "$name" "$url" "$sha"
done < "$LOCK"

echo ">> regenerating contract catalogs from $SRC_DIR/mattermost"
python3 "$REPO/scripts/build-reference.py" "$SRC_DIR/mattermost" "$REPO/reference"

echo ">> DONE. Verify:  rg -i MM_GITLABSETTINGS_AUTHENDPOINT $REPO/reference/config-env-map.md"
echo "   Next: pin to your MM_VERSION (see goals/GOAL-PREP-reference-environment.md), then start GOAL-00."

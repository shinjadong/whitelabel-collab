#!/usr/bin/env bash
# index-docs.sh — Ingest the vendored Mattermost docs + generated catalogs into a
# semantic index so agents can RAG-query authoritative answers (Tier-2 of the
# reference environment; see docs/04-REFERENCE-ENVIRONMENT.md).
#
# Default backend: pgvector on the existing kontology stack (Vhagar) with Ollama
# embeddings. If that infra is unreachable, this script exits non-zero and the
# build falls back to ripgrep (Tier-1) + Context7 MCP (Tier-3) — RAG is a
# convenience, never a hard dependency.
#
# This is a SCAFFOLD: wire the actual embedding/upsert calls to your kontology
# RAG endpoint. Kept dependency-light and idempotent (re-running re-upserts).
set -euo pipefail

SRC="${SRC:-$HOME/mattermost-src}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
PGVECTOR_DSN="${PGVECTOR_DSN:-}"            # e.g. postgres://user:pass@kontology:5432/rag
OLLAMA_URL="${OLLAMA_BASE_URL:-http://kontology:11434}"
EMBED_MODEL="${EMBED_MODEL:-nomic-embed-text}"
COLLECTION="${COLLECTION:-mattermost_ref}"

# Corpus: the high-signal, version-pinned sources.
CORPUS=(
  "$REPO/reference"                                            # generated catalogs (619/243/214/519)
  "$REPO/docs"                                                 # our own architecture/legal/feature docs
  "$SRC/docs/source"                                           # admin/user docs (rst)
  "$SRC/mattermost-developer-documentation/site/content"      # developer docs (md)
  "$SRC/mattermost/api/v4/source"                              # OpenAPI source (yaml)
)

echo ">> RAG index: collection=$COLLECTION  model=$EMBED_MODEL"
[ -z "$PGVECTOR_DSN" ] && { echo "!! PGVECTOR_DSN unset — RAG unavailable. Fall back to: rg + Context7 MCP."; exit 2; }

# Enumerate chunkable files.
mapfile -t FILES < <(find "${CORPUS[@]}" -type f \( -name '*.md' -o -name '*.rst' -o -name '*.yaml' \) 2>/dev/null)
echo ">> ${#FILES[@]} files to chunk/embed"

# TODO(implementer): for each file → split into ~800-token chunks with source-path
# metadata → embed via Ollama ($OLLAMA_URL /api/embeddings, $EMBED_MODEL) → upsert
# into pgvector ($PGVECTOR_DSN, table $COLLECTION) with columns (id, path, chunk, embedding).
# Re-run = re-upsert by stable id (path+chunk_index) for idempotency.
# Then expose a query helper: embed(question) → top-k cosine → return passages+paths.

echo ">> SCAFFOLD ONLY — implement embed/upsert against kontology, then verify a test query:"
echo "   q='exact env var for SAML identity provider URL' → expect MM_SAMLSETTINGS_IDPURL from config-env-map.md"

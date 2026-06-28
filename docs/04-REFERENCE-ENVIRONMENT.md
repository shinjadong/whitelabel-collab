# 04 — Reference Environment (vendor everything, index it, never guess)

## Purpose
A serious build does not start until the implementing agent can answer every "what's the exact name /
type / endpoint / flag?" from a **local, version-pinned, searchable** source of truth. This document
defines that environment: what we vendor, how we pin it, how we index it, and how the agent queries it.
This is what removes the "barefoot launch" feeling — and it's the same discipline big-tech uses, just at
1-person scale (see [`05-ENTERPRISE-GRADE-PREP.md`](05-ENTERPRISE-GRADE-PREP.md)).

---

## 1. The four layers

```
L1 VENDOR    clone every authoritative source, pinned to MM_VERSION  → ~/mattermost-src/*
L2 EXTRACT   parse sources into contract catalogs                    → reference/*.md  (619+243+214+519)
L3 INDEX     make it searchable: ripgrep + catalogs + RAG + Context7
L4 GOLDEN    capture known-good artifacts (config.json, OIDC discovery, OpenAPI bundle) for diffing
```

The agent answers in this order: **catalog (L2) → vendored source (L1) → RAG (L3) → Context7 (live) →
ask a human.** It must never invent a config key or endpoint.

---

## 2. L1 — Vendored sources (on this machine)

| Source | Local path | Upstream site | Holds |
|---|---|---|---|
| Monorepo | `~/mattermost-src/mattermost` | github.com/mattermost/mattermost | server, webapp, **OpenAPI** (`api/v4/source`), **config struct** (`server/public/model/config.go`), **plugin API** (`server/public/plugin`), **mmctl** (`server/cmd/mmctl`), TS types (`webapp/platform/types`) |
| Admin/User docs | `~/mattermost-src/docs` | docs.mattermost.com | Sphinx; config-settings ref, deployment, admin, mmctl, end-user guides |
| Developer docs | `~/mattermost-src/mattermost-developer-documentation` | developers.mattermost.com | Hugo; plugin dev, architecture, integration guides, contributing |
| API reference | `~/mattermost-src/mattermost-api-reference` | api.mattermost.com | standalone OpenAPI spec + Redoc tooling |
| Feature plugins | `~/mattermost-src/mattermost-plugin-{calls,playbooks,boards}` | — | plugin.json (IDs/versions), build reference |

> Heavy clones live **outside** the Obsidian vault (`~/mattermost-src/`), so they don't flood phone sync.
> Only the small generated catalogs live in this repo.

---

## 3. Version pinning (NON-NEGOTIABLE)

Docs and types drift between releases. The reference MUST match the deployed `MM_VERSION`, or the agent
will use a field that doesn't exist in the target build.

- Pick the target version (baseline: `10.5`; or latest stable for new clients).
- Pin each reference clone to the matching release branch/tag:
  `git -C ~/mattermost-src/mattermost fetch --depth 1 origin release-<X.Y> && git checkout release-<X.Y>`
  (do the same for `docs`; dev-docs/api-reference track releases too).
- Record the resolved commit SHA of each source in `reference/VERSION-LOCK.md` (created by GOAL-PREP).
- **Re-run `scripts/build-reference.py`** after any re-pin so the catalogs match.

> The currently-cloned monorepo is **master** (TS types v11.9) — pin it down before trusting field-level
> details for a v10.5 deployment.

---

## 4. L2 — Contract catalogs (generated)

`scripts/build-reference.py` → `reference/` (see [`../reference/README.md`](../reference/README.md)):
`config-env-map.md` (619), `plugin-api.md` (243), `mmctl-commands.md` (214), `endpoints.md` (519).
These are the agent's first stop. Regenerate whenever the pinned source changes.

---

## 5. L3 — Indexing & query

**Tier 1 — ripgrep (always available, zero infra):** `rg -i '<term>' reference/ ~/mattermost-src/*/`.
The catalogs are structured for this.

**Tier 2 — semantic / RAG (optional, uses existing kontology infra):** ingest the vendored docs + catalogs
into pgvector so agents can semantic-search ("how do I configure SAML group sync?") and get the
authoritative passage. Script: `scripts/index-docs.sh` (chunks markdown/rst/openapi → embeddings →
pgvector on Vhagar). Reuses the existing kontology RAG stack (pgvector + Ollama embeddings).

**Tier 3 — Context7 MCP (live upstream):** for anything not vendored or to confirm the newest guidance,
use the Context7 tools (resolve-library-id → query-docs). Live, but **not version-pinned** — prefer L1/L2
for reproducibility; use Context7 to confirm, not to decide.

---

## 6. L4 — Golden references (capture once per version)

Diff-targets that catch drift and prove correctness (GOAL-PREP captures these):
- `golden/config.default.json` — config.json from a fresh `mattermost-team-edition:<ver>` container.
- `golden/openid-configuration.json` — Keycloak realm `.well-known/openid-configuration` shape (GOAL-03).
- `golden/openapi-v4.bundled.yaml` — bundled OpenAPI (via `api/` tooling or the api-reference repo).
- `golden/plugin.json.*` — pinned plugin manifests for calls/playbooks/boards.

---

## 7. Browsable doc portals (optional, docker-served — no host toolchain)
For humans who want the real websites locally:
- **API (Redoc):** `docker run --rm -p 8081:80 -v ~/mattermost-src/mattermost-api-reference:/spec redocly/redoc`
  (or point Redoc at `golden/openapi-v4.bundled.yaml`).
- **Developer docs (Hugo):** `docker run --rm -p 1313:1313 -v ~/mattermost-src/mattermost-developer-documentation:/src klakegg/hugo:ext server`
- **Admin docs (Sphinx):** build with a python/sphinx container against `~/mattermost-src/docs`.
GOAL-PREP wires these into a `make docs-portal` convenience target.

---

## 8. Definition of "ready to build"
- [ ] All sources vendored and **pinned** to the chosen `MM_VERSION`; SHAs in `reference/VERSION-LOCK.md`.
- [ ] Catalogs regenerated against the pinned source (`reference/*.md`).
- [ ] Index reachable (at minimum ripgrep; ideally RAG ingested).
- [ ] Golden references captured.
- [ ] The agent's preamble points it at this doc and forbids inventing names.
Only then start GOAL-00.

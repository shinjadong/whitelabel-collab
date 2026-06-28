# GOAL-PREP — Build the reference environment (run BEFORE GOAL-00)

**GOAL:** Stand up the version-pinned, indexed, golden-referenced knowledge environment so every later
goal is implemented from authoritative sources, never guesswork. This is step 0; do not start GOAL-00
until its acceptance criteria pass.

## WHY
The implementing agent will otherwise hallucinate config keys, endpoints, CLI flags, and types. This goal
makes the source of truth local, pinned to the deployed version, searchable, and diff-able. See
`../docs/04-REFERENCE-ENVIRONMENT.md` for the model and `../docs/05-ENTERPRISE-GRADE-PREP.md` for why this
is the first rung of the maturity ladder.

## CONTEXT
- Heavy clones live OUTSIDE the vault at `~/mattermost-src/` (already cloned: `mattermost`, `docs`,
  `mattermost-developer-documentation`, `mattermost-api-reference`, the 3 feature plugins). Small
  generated catalogs live in this repo under `reference/`.
- Extractor already exists: `scripts/build-reference.py` → `reference/{config-env-map,plugin-api,mmctl-commands,endpoints}.md`.
- The currently-cloned monorepo is **master** — it MUST be pinned to the target `MM_VERSION` before its
  field-level details are trusted.
- Optional RAG uses the existing kontology stack (pgvector + Ollama embeddings on Vhagar).

## PREREQUISITES
- Decide the target `MM_VERSION` (baseline `10.5`, or latest stable). Disk: clones total ~1.5 GB.

## DELIVERABLES
```
reference/config-env-map.md  reference/plugin-api.md            # (regenerated against pinned source)
reference/mmctl-commands.md  reference/endpoints.md
reference/VERSION-LOCK.md                                       # resolved commit SHA of each pinned source
golden/config.default.json                                     # from a fresh TE container of MM_VERSION
golden/openapi-v4.bundled.yaml                                 # bundled OpenAPI (api/ tooling or api-reference)
scripts/index-docs.sh                                          # RAG ingest of vendored docs+catalogs → pgvector
Makefile targets: `make reference`, `make docs-portal`         # regenerate catalogs; serve doc sites
```

## STEPS
1. **Pin sources** to `release-<X.Y>` matching `MM_VERSION` (monorepo + docs; dev-docs/api-reference to
   the matching release). Record each resolved SHA in `reference/VERSION-LOCK.md`.
2. **Regenerate catalogs:** `python3 scripts/build-reference.py` (or `make reference`). Confirm counts are
   sane and the template's critical vars exist (`MM_GITLABSETTINGS_AUTHENDPOINT`, `MM_SERVICESETTINGS_SITEURL`,
   `MM_LDAPSETTINGS_*`, `MM_SAMLSETTINGS_*`, `MM_PLUGINSETTINGS_*`).
3. **Capture golden refs:** run a throwaway `mattermost-team-edition:${MM_VERSION}` container, copy out
   its `config/config.json` → `golden/config.default.json`; bundle the OpenAPI → `golden/openapi-v4.bundled.yaml`;
   snapshot the 3 plugins' `plugin.json`.
4. **Index (RAG, optional but recommended):** `scripts/index-docs.sh` chunks `reference/*.md`,
   `~/mattermost-src/docs/source/**`, `~/mattermost-src/mattermost-developer-documentation/site/content/**`,
   and the OpenAPI into embeddings stored in pgvector (kontology). Verify a test query returns the right
   passage. If RAG infra is unreachable, fall back to ripgrep + Context7 and note it.
5. **Doc portals (optional):** add `make docs-portal` serving Redoc (API), Hugo (dev docs), Sphinx (admin)
   via containers per `../docs/04-REFERENCE-ENVIRONMENT.md` §7.
6. **Wire the agent preamble:** ensure the Codex/goal preamble points at `../docs/04-REFERENCE-ENVIRONMENT.md`
   and `../reference/` and forbids inventing names (search-first rule).

## ACCEPTANCE CRITERIA
- [ ] `reference/VERSION-LOCK.md` records the pinned SHA of every source; all match the chosen `MM_VERSION`.
- [ ] `reference/*.md` regenerated against the pinned source; critical template vars present and correctly named.
- [ ] `golden/config.default.json` and `golden/openapi-v4.bundled.yaml` captured.
- [ ] At least ripgrep search works across `reference/` + `~/mattermost-src/`; RAG ingested OR explicitly
      marked unavailable with the fallback documented.
- [ ] `make reference` regenerates catalogs idempotently.
- [ ] A spot-check question ("exact env var for SAML IdP URL?", "operationId to create a user?") is
      answerable from the catalogs alone, without guessing.

## GOTCHAS
- **Version skew is the silent killer** — an unpinned (master) reference will offer fields that don't exist
  in v10.5. Pin first, then trust.
- Keep heavy clones out of the vault (`~/mattermost-src/`); only small `.md` catalogs belong in the repo.
- The catalogs are generated — never hand-edit; fix the extractor (`scripts/build-reference.py`) instead.
- RAG is a convenience, not a dependency; the build must remain doable with ripgrep + Context7 alone.

# GOAL-01 — Base stack: Postgres + Mattermost Team Edition

**GOAL:** Stand up the legal-safe core — official **Mattermost Team Edition** image + dedicated Postgres
— via docker-compose, fully driven by the per-client `.env`, on a private network (not yet public).

## WHY
This is the unmodified, AGPL-safe heart of the product (see `../docs/02-LEGAL-MODEL.md` Rule 1). Every
other goal attaches to it. Getting the image, DB, volumes, healthchecks, and env-config right here means
all later layers (proxy, SSO, plugins) have a stable base. Team Edition (not "Entry") is chosen because
TE has **unlimited message history** — essential for a chatty product (see `../docs/00-OVERVIEW.md` §5).

## CONTEXT
- Image: `mattermost/mattermost-team-edition:${MM_VERSION}` (open source; **never** the enterprise image).
- DB: `postgres:${POSTGRES_VERSION}-alpine`, dedicated to Mattermost.
- Config via `MM_*` environment variables (Mattermost maps `MM_<SECTION>_<KEY>` to config.json).
- Reference for env keys: a known-good compose already exists at
  `~/predator/projects/kontology/mattermost/docker-compose.yml` (Vhagar Hermes deployment) — reuse its
  proven `MM_*` settings as a starting point, but parameterize everything by `.env`.
- Networks: attach to `internal` only for now; `edge`/public exposure is GOAL-02's job.

## PREREQUISITES
- GOAL-00 complete (`.env.example`, compose dir, Makefile exist).

## DELIVERABLES
```
compose/docker-compose.yml          # postgres + mattermost-te services (extended by later goals)
compose/mattermost.env.snippet.md   # doc: which MM_* vars we set and why
```

### `compose/docker-compose.yml` — services to define
- **mm-postgres**
  - image `postgres:${POSTGRES_VERSION}-alpine`
  - env `POSTGRES_USER/PASSWORD/DB` ← `MM_POSTGRES_*`
  - volume `${BRAND_SLUG}_mm-postgres:/var/lib/postgresql/data`
  - healthcheck `pg_isready -U $$POSTGRES_USER`
  - network `internal`; **no ports published**
- **mattermost-te**
  - image `mattermost/mattermost-team-edition:${MM_VERSION}`
  - `depends_on: mm-postgres (condition: service_healthy)`
  - env:
    - `MM_SQLSETTINGS_DRIVERNAME=postgres`
    - `MM_SQLSETTINGS_DATASOURCE=postgres://${MM_POSTGRES_USER}:${MM_POSTGRES_PASSWORD}@mm-postgres:5432/${MM_POSTGRES_DB}?sslmode=disable&connect_timeout=10`
    - `MM_SERVICESETTINGS_SITEURL=https://chat.${PRIMARY_DOMAIN}`
    - `MM_SERVICESETTINGS_ENABLELOCALMODE=true`           # enables mmctl via local socket (GOAL-05)
    - `MM_BLEVESETTINGS_ENABLEINDEXING=true` + `INDEXDIR=/mattermost/data/bleve-indexes`  # TE search
    - `MM_SERVICESETTINGS_ENABLEBOTACCOUNTCREATION=true`
    - `MM_SERVICESETTINGS_ENABLEUSERACCESSTOKENS=true`
    - `MM_PLUGINSETTINGS_ENABLE=true` + `ENABLEUPLOADS=true`   # for GOAL-05/06
    - `MM_FILESETTINGS_*` as needed (local driver, data dir)
  - volumes: `${BRAND_SLUG}_mm-data:/mattermost/data`, `_mm-config:/mattermost/config`,
    `_mm-logs:/mattermost/logs`, `_mm-plugins:/mattermost/plugins`, `_mm-client-plugins:/mattermost/client/plugins`
  - healthcheck: `curl -f http://localhost:8065/api/v4/system/ping`
  - network `internal`; **no ports published** (Caddy reaches it internally in GOAL-02)
- **networks:** declare `internal` (and `edge` as `external: false` placeholder for GOAL-02).
- **volumes:** declare all named volumes prefixed by `${BRAND_SLUG}`.

## STEPS
1. Author `compose/docker-compose.yml` with the two services above, all values from `.env`.
2. Create `clients/scout.env` from `.env.example` with throwaway local secrets for testing.
3. `make up SLUG=scout`; wait for both healthchecks green.
4. Confirm Mattermost answers: `docker exec ${BRAND_SLUG}-mattermost-te curl -sf localhost:8065/api/v4/system/ping`.
5. Create the first admin (via the web setup on first run, or `mmctl --local user create ... --system-admin`)
   and record the procedure in `compose/mattermost.env.snippet.md`.
6. Document every `MM_*` var chosen and its effect in `compose/mattermost.env.snippet.md`.

## ACCEPTANCE CRITERIA
- [ ] `docker compose -p scout ps` shows `mm-postgres` and `mattermost-te` both **healthy**.
- [ ] `/api/v4/system/ping` returns `{"status":"OK"...}` from inside the network.
- [ ] No ports are published to the host (verify `docker compose ps` PORTS column is empty/internal).
- [ ] The image is `mattermost-team-edition` (NOT enterprise). `docker inspect` confirms the tag.
- [ ] Data persists across `make down` + `make up` (message/test survives restart).
- [ ] Every setting comes from `.env`; grep the compose file → no hardcoded brand/domain/secret.

## GOTCHAS
- `ENABLELOCALMODE=true` is what lets `mmctl --local` run without an admin token later — keep it on
  (it's only reachable inside the container, safe).
- Do not publish 8065 to the host; all external access goes through Caddy (GOAL-02) for TLS + filtering.
- Team Edition has no Elasticsearch (that's EE) — Bleve is the built-in search; enable it as above.

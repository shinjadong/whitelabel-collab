# GOAL-00 — Project scaffold & per-client parameterization

**GOAL:** Create the repository skeleton, the per-client `.env` contract, the lifecycle Makefile, and
the brand-asset layout, so every later goal has a consistent, parameterized foundation.

## WHY
Everything downstream is multi-tenant and parameter-driven (one stack per client). If the env contract
and directory layout aren't fixed first, later goals will hardcode brand/domain/secret values and the
template won't be reusable. This goal makes "a client = one `.env` + one `brand/` folder."

## CONTEXT
- Repo root: `~/projects/whitelabel-collab/` (this repo). Read `../docs/00-OVERVIEW.md`,
  `../docs/01-ARCHITECTURE.md` first for decisions and naming conventions.
- We deploy with docker-compose, one isolated stack per client, core Mattermost unmodified.
- Naming: compose project = `${BRAND_SLUG}`; domains `chat.${PRIMARY_DOMAIN}`, `id.${PRIMARY_DOMAIN}`.

## PREREQUISITES
- None. This is the first goal.

## DELIVERABLES (create under repo root)
```
.env.example                 # every variable the stack needs, documented, NO real values
.gitignore                   # ignore .env, data/, *.local, brand/*/secrets
Makefile                     # lifecycle targets (see STEPS)
compose/                     # (empty dir + .gitkeep; GOAL-01/02/03 add compose files here)
brand/.gitkeep               # per-client brand assets land in brand/<slug>/
clients/.gitkeep             # per-client env files land in clients/<slug>.env
jobs/.gitkeep                # scheduled job scripts (GOAL-08/09)
keycloak/.gitkeep            # realm exports (GOAL-03)
scripts/render.sh            # render templates + a client's .env → /opt/<slug>/ (stub; finalized in GOAL-10)
```

### `.env.example` must contain (grouped, commented):
```dotenv
# ---- identity of this client ----
BRAND_SLUG=scout                       # lowercase id; used in container/volume/project names
BRAND_DISPLAY_NAME=Scout Collab        # shown in UI/emails
PRIMARY_DOMAIN=scout.example.com       # chat.<domain> and id.<domain> resolve here
ADMIN_EMAIL=admin@scout.example.com    # Caddy ACME + first admin

# ---- version pins (no 'latest') ----
MM_VERSION=10.5
KEYCLOAK_VERSION=26.0
POSTGRES_VERSION=15
CADDY_VERSION=2

# ---- mattermost ----
MM_POSTGRES_USER=mmuser
MM_POSTGRES_PASSWORD=__CHANGE_ME__
MM_POSTGRES_DB=mattermost

# ---- keycloak ----
KC_ADMIN=admin
KC_ADMIN_PASSWORD=__CHANGE_ME__
KC_POSTGRES_USER=keycloak
KC_POSTGRES_PASSWORD=__CHANGE_ME__
KC_POSTGRES_DB=keycloak
KC_REALM=scout

# ---- mm <-> keycloak oauth bridge (filled during GOAL-03) ----
MM_GITLAB_CLIENT_ID=mattermost
MM_GITLAB_CLIENT_SECRET=__CHANGE_ME__

# ---- access control ----
IP_ALLOWLIST=                          # optional CIDR allowlist for Caddy (empty = allow all)

# ---- ai (GOAL-06, optional) ----
OLLAMA_BASE_URL=http://ollama:11434
OLLAMA_MODEL=qwen2.5:7b

# ---- alerts (GOAL-09) ----
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
```

### `Makefile` targets (thin wrappers over compose, all scoped by `BRAND_SLUG`):
- `make up SLUG=scout` → `docker compose -p scout --env-file clients/scout.env -f compose/docker-compose.yml up -d`
- `make down SLUG=scout`, `make logs SLUG=scout`, `make ps SLUG=scout`
- `make render SLUG=scout` → call `scripts/render.sh` (stub now)
- `make backup SLUG=scout`, `make restore SLUG=scout` (wired in GOAL-09)

## STEPS
1. Create the directory tree and `.gitkeep` files above.
2. Write `.env.example` exactly as specified (documented, placeholder values only).
3. Write `.gitignore` ignoring: `clients/*.env`, `/opt`, `data/`, `**/secrets/`, `*.local`, real brand secrets.
4. Write `Makefile` with the targets above. Each target requires `SLUG=` and errors clearly if missing.
5. Write `scripts/render.sh` as a documented stub that will (in GOAL-10) copy `compose/`, render the
   `Caddyfile` and `keycloak/realm-export.json` from `clients/<slug>.env`, and lay out `/opt/<slug>/`.
6. Add a short `clients/README.md` explaining: "copy `.env.example` → `clients/<slug>.env`, fill secrets."

## ACCEPTANCE CRITERIA
- [ ] `make` with no SLUG prints a helpful usage error, not a stack trace.
- [ ] `.env.example` lists every variable later goals reference; no real secrets present.
- [ ] `git status` shows `.env`/data are ignored.
- [ ] Tree matches DELIVERABLES; `compose/`, `brand/`, `clients/`, `jobs/`, `keycloak/`, `scripts/` exist.
- [ ] A reviewer can understand "how to add a new client" from `clients/README.md` alone.

## GOTCHAS
- Do **not** commit any real `.env`. Only `.env.example`.
- Keep `BRAND_SLUG` strictly `[a-z0-9-]` — it becomes a compose project name and DNS label.

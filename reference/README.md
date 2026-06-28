# Reference Catalogs — the "no-guessing" layer

Auto-generated authoritative contract catalogs. The implementing agent (and humans) **search these
first** instead of guessing config keys, API endpoints, CLI flags, or plugin methods. Regenerate with
`python3 scripts/build-reference.py` after pinning the source to your `MM_VERSION`.

| File | Items | Source of truth | Answers |
|---|---|---|---|
| [`config-env-map.md`](config-env-map.md) | 619 env vars | `server/public/model/config.go` | exact `MM_*` env var names + types — **validate every `.env`/compose value against this** |
| [`plugin-api.md`](plugin-api.md) | 243 methods | `server/public/plugin/api.go` | what a server plugin can call (GOAL-06) |
| [`mmctl-commands.md`](mmctl-commands.md) | 214 commands | `server/cmd/mmctl/commands/*.go` | CLI commands for all scripts (GOAL-03/04/05/08/10) |
| [`endpoints.md`](endpoints.md) | 519 endpoints | `api/v4/source/*.yaml` (OpenAPI) | REST API method+path+operationId |

## How the agent must use these
1. Need a config/env var? → `rg -i '<thing>' reference/config-env-map.md` → use the exact `MM_*` name.
2. Need an API call? → `rg -i '<resource>' reference/endpoints.md` → then read full schema from
   `~/mattermost-src/mattermost/api/v4/source/<resource>.yaml` or the Redoc render.
3. Building the plugin? → `rg -i '<capability>' reference/plugin-api.md`.
4. Scripting admin ops? → `rg -i '<verb>' reference/mmctl-commands.md`.
5. Still unsure? → the full vendored docs in `~/mattermost-src/` (see `../docs/04-REFERENCE-ENVIRONMENT.md`),
   then Context7 MCP for live upstream docs. **Never invent a name.**

## Full vendored sources (not in this repo; on this machine, version-pin them)
- `~/mattermost-src/mattermost` — server, webapp, OpenAPI source, config struct, plugin API, mmctl
- `~/mattermost-src/docs` — admin/user docs (Sphinx) → docs.mattermost.com
- `~/mattermost-src/mattermost-developer-documentation` — developer docs (Hugo) → developers.mattermost.com
- `~/mattermost-src/mattermost-api-reference` — standalone OpenAPI repo → api.mattermost.com

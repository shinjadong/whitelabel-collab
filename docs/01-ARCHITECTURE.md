# 01 — Architecture

## Purpose
Define the concrete runtime topology every GOAL builds toward: components, how data flows, ports,
networks, and the on-disk layout of a deployed client stack. Treat this as the contract — GOAL files
fill in implementation, they do not redefine topology.

---

## 1. Component diagram (per client stack)

```
                         Internet
                            │  :443 / :80
                ┌───────────▼────────────┐
                │         caddy          │  TLS (auto), routes by hostname,
                │  (the ONLY public port)│  IP allow/deny, security headers
                └───┬───────────────┬────┘
       chat.<dom>   │               │   id.<dom>
                    ▼               ▼
        ┌───────────────────┐   ┌───────────────────┐
        │   mattermost-te   │   │     keycloak      │
        │ (official image,  │   │ (SSO broker / IdP)│
        │  core UNMODIFIED) │   │  realm per client │
        │  :8065 (internal) │   │  :8080 (internal) │
        │                   │   │  federates:       │
        │  plugins:         │   │   • LDAP / AD     │
        │   calls,playbooks │   │   • SAML IdP      │
        │   boards,         │◀──│   • Google/O365   │  OIDC
        │   ai-translate    │   │   • generic OIDC  │
        └─────────┬─────────┘   └─────────┬─────────┘
                  │ SQL                    │ SQL
                  ▼                        ▼
        ┌───────────────────┐   ┌───────────────────┐
        │   mm-postgres     │   │ keycloak-postgres │   (or one shared PG,
        │  (Mattermost DB)  │   │  (Keycloak DB)    │    separate databases)
        └─────────┬─────────┘   └───────────────────┘
                  │
        ┌─────────▼──────────────────────────────────┐
        │ jobs (external, scheduled):                 │
        │  • data-retention (prune old posts/files)   │  GOAL-08
        │  • compliance/CSV export                    │  GOAL-08
        │  • backup (pg_dump + data volume) + restore │  GOAL-09
        │  • healthcheck + Telegram alert             │  GOAL-09
        └─────────────────────────────────────────────┘

   AI inference (shared, external to client stack):
        ai-translate plugin ──HTTP──▶ Ollama (Vhagar / shared host)   GOAL-06
```

**Key property:** only Caddy is internet-exposed. Mattermost, Keycloak, and both databases sit on a
private docker network and are never published directly.

---

## 2. Data flows

### 2.1 Login (SSO) — the critical path
```
user → caddy(chat.<dom>) → Mattermost "Sign in with SSO"
     → redirect to caddy(id.<dom>) → Keycloak login
        (Keycloak authenticates against LDAP/SAML/Google/O365 as configured)
     → Keycloak issues OIDC code → Mattermost GitLab-OAuth callback
        (MM reads id/username/email/name from Keycloak userinfo)
     → MM session established (user auto-provisioned on first login)
```
Critical detail: Mattermost Team Edition's GitLab OAuth requires a **numeric, unique `id` claim** in the
userinfo response. Keycloak must emit it via a protocol mapper. (Full spec in GOAL-03.)

### 2.2 Messaging
Standard Mattermost: webapp/mobile ↔ MM server (REST + WebSocket) ↔ Postgres + file storage volume.
Unmodified. Search uses the built-in Bleve index (TE) — no Elasticsearch (that is EE).

### 2.3 Push (conditional, GOAL-07)
MM server → self-hosted `mattermost-push-proxy` → APNs / FCM, using **our** push certificates and a
**custom-bundle-id mobile app**. Only relevant once custom mobile apps exist. Web/PWA needs no push proxy.

---

## 3. Ports & networks

| Component | Internal port | Exposed? | Network |
|---|---|---|---|
| caddy | 80, 443 | **yes (public)** | `edge` + `internal` |
| mattermost-te | 8065 | no | `internal` |
| keycloak | 8080 | no | `internal` |
| mm-postgres | 5432 | no | `internal` |
| keycloak-postgres | 5432 | no | `internal` |
| ollama (shared) | 11434 | no (private/Tailscale) | external to stack |

Two docker networks: `edge` (caddy ↔ outside) and `internal` (everything else, no internet ingress).

---

## 4. On-disk layout (deployed host)

```
/opt/<brand-slug>/
├── .env                       # this client's secrets/params (NOT in git)
├── docker-compose.yml         # symlink/copy of template compose
├── compose/                   # template compose + overrides (from repo)
├── Caddyfile                  # rendered from template + .env
├── brand/                     # this client's logo, favicon, css, email assets
├── keycloak/
│   └── realm-export.json      # realm config (idempotent import)
├── plugins/                   # downloaded plugin bundles (pinned versions)
├── jobs/                      # retention/export/backup scripts
└── data/                      # bind or named volumes
    ├── mm-data/  mm-config/  mm-logs/  mm-plugins/
    ├── mm-postgres/
    ├── keycloak-postgres/
    └── backups/
```

The **repo** (`whitelabel-collab/`) holds templates; **`/opt/<brand-slug>/`** is the rendered instance.
GOAL-10 defines the render/provision step that turns repo templates + a client `.env` into a running stack.

---

## 5. Naming conventions (all GOALs must follow)

- compose project name: `${BRAND_SLUG}`  (→ container `scout-mattermost-te`, `scout-caddy`, …)
- container name: `${BRAND_SLUG}-<component>`
- volume name: `${BRAND_SLUG}_<purpose>`
- domains: `chat.${PRIMARY_DOMAIN}` (Mattermost), `id.${PRIMARY_DOMAIN}` (Keycloak)
- Keycloak realm: `${BRAND_SLUG}`

---

## 6. Version pinning (avoid "latest")

Pin exact tags in `.env` so re-deploys are reproducible:
`MM_VERSION`, `KEYCLOAK_VERSION`, `POSTGRES_VERSION`, `CADDY_VERSION`, and each `*_PLUGIN_VERSION`.
Current baseline reference: Mattermost Team Edition `10.5` (the version already running on Vhagar).
The implementing agent should confirm the latest stable patch of each at build time and record it.

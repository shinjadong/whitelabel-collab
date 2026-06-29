# whitelabel-collab — FULL BUNDLE (auto-generated for one-shot LLM review)

> Every authored doc, goal, script, and reference catalog concatenated into one file.
> Repo: https://github.com/shinjadong/whitelabel-collab · regenerate: `scripts/make-bundle.sh`

## Index
- `README.md`
- `docs/00-OVERVIEW.md`
- `docs/01-ARCHITECTURE.md`
- `docs/02-LEGAL-MODEL.md`
- `docs/03-FEATURE-MATRIX.md`
- `docs/04-REFERENCE-ENVIRONMENT.md`
- `docs/05-ENTERPRISE-GRADE-PREP.md`
- `docs/06-REPRODUCE-ON-NEW-DEVICE.md`
- `goals/GOAL-00-project-scaffold.md`
- `goals/GOAL-01-base-stack.md`
- `goals/GOAL-02-edge-proxy.md`
- `goals/GOAL-03-keycloak-sso.md`
- `goals/GOAL-04-white-label-branding.md`
- `goals/GOAL-05-feature-plugins.md`
- `goals/GOAL-06-ai-translation-bot.md`
- `goals/GOAL-07-push-notifications.md`
- `goals/GOAL-08-data-lifecycle.md`
- `goals/GOAL-09-resilience-backup.md`
- `goals/GOAL-10-tenant-provisioning.md`
- `goals/GOAL-11-acceptance-verification.md`
- `goals/GOAL-PREP-reference-environment.md`
- `reference/README.md`
- `reference/config-env-map.md`
- `reference/endpoints.md`
- `reference/mmctl-commands.md`
- `reference/plugin-api.md`
- `scripts/bootstrap.sh`
- `scripts/build-reference.py`
- `scripts/index-docs.sh`
- `scripts/make-bundle.sh`
- `sources.lock`


<!-- ============================================================ -->
## FILE: `README.md`

# White-Label Collaboration Platform — Build Template

> A repeatable template to deploy a **white-labeled, self-hosted secure team-collaboration / ChatOps
> platform** for B2B clients, built on **Mattermost Team Edition (open source, core-unmodified)** with
> **enterprise-grade capabilities (SSO, LDAP/SAML, retention, compliance export, resilience) restored
> legally via proxy / plugin / external-job layers** — i.e. an "Enterprise-equivalent" branded product
> **without** Mattermost Enterprise licensing.

This repository is the **specification + step-by-step build playbook**. It is written so an autonomous
coding agent (Codex via `/goal`) can implement each step with zero prior conversation context.

> **Reproduce anywhere (new AWS box, laptop):**
> ```bash
> git clone <this-repo> && cd whitelabel-collab && ./scripts/bootstrap.sh
> ```
> `bootstrap.sh` clones the exact pinned Mattermost sources (`sources.lock`) and regenerates the
> contract catalogs — a byte-identical environment without re-hosting upstream code.
> See [`docs/06-REPRODUCE-ON-NEW-DEVICE.md`](docs/06-REPRODUCE-ON-NEW-DEVICE.md).

---

## 1. What you get (one glance)

```
   Client users ─HTTPS─▶ Caddy (TLS, IP-filter, per-client domain, rebrand routing)
                              │
                ┌─────────────┼──────────────────────────┐
                ▼             ▼                            ▼
          Keycloak       Mattermost Team Edition      (static brand assets)
        (SSO broker:     (core UNMODIFIED, official     login page / favicon
         LDAP/SAML/       Docker image)                  / custom CSS)
         Google/O365/         │   ├─ plugins: Calls, Playbooks, Boards (free)
         OIDC → MM)           │   └─ plugin: AI translation bot (Ollama)
                              ▼
                         Postgres  ◀── external cron: data-retention, compliance export, backup
```

Legal foundation: **we never modify the Mattermost Go server and never use Enterprise (`server/enterprise`)
code.** All "enterprise" features are reproduced from the outside. See [`docs/02-LEGAL-MODEL.md`](docs/02-LEGAL-MODEL.md).

---

## 2. Document map

| File | Purpose |
|---|---|
| [`docs/00-OVERVIEW.md`](docs/00-OVERVIEW.md) | Product concept, scope, **design decisions & assumptions**, glossary |
| [`docs/01-ARCHITECTURE.md`](docs/01-ARCHITECTURE.md) | Component diagram, data flow, ports/networks, host directory layout |
| [`docs/02-LEGAL-MODEL.md`](docs/02-LEGAL-MODEL.md) | AGPL / trademark / EE boundaries — the 3 hard rules + per-feature legality |
| [`docs/03-FEATURE-MATRIX.md`](docs/03-FEATURE-MATRIX.md) | The 16 Enterprise features × our DIY replacement × which GOAL builds it |
| [`docs/04-REFERENCE-ENVIRONMENT.md`](docs/04-REFERENCE-ENVIRONMENT.md) | Vendor + pin + index all authoritative sources — the "never guess" layer |
| [`docs/05-ENTERPRISE-GRADE-PREP.md`](docs/05-ENTERPRISE-GRADE-PREP.md) | Maturity ladder L1→L4: how big-tech white-labels at scale; DIY-vs-buy |
| [`docs/06-REPRODUCE-ON-NEW-DEVICE.md`](docs/06-REPRODUCE-ON-NEW-DEVICE.md) | Byte-identical setup on a fresh box via `sources.lock` + `bootstrap.sh` |
| [`reference/`](reference/README.md) | Generated contract catalogs: env vars (619), plugin API (243), mmctl (214), REST (519) |
| `goals/GOAL-PREP`, `GOAL-00 … GOAL-11` | The executable build steps (one `/goal` each) |

---

## 3. How to drive the implementation with Codex `/goal`

Each `goals/GOAL-NN-*.md` file is a **self-contained, executable specification**. Run them **in order**;
each declares its prerequisites and its acceptance criteria.

**Invocation pattern (per step):**

```bash
# from the repo root, feed one goal file to Codex:
/goal "$(cat goals/GOAL-01-base-stack.md)"
```

Or open the file and instruct Codex: *"Implement this goal exactly. Read CONTEXT and DELIVERABLES,
produce the files under DELIVERABLES, then self-check every item in ACCEPTANCE CRITERIA before stopping."*

**Rules for the implementing agent (put this in the Codex system/goal preamble):**
1. Read the linked `docs/*` for context before writing code. Do **not** invent architecture.
2. **Never modify** the Mattermost server source or pull `server/enterprise` code. Use only official
   images, config, plugins, and external services.
3. Produce real, runnable files (compose, Caddyfile, env templates, scripts) — not pseudocode.
4. Keep every value **parameterized by the per-client `.env`** (`${BRAND_SLUG}`, `${PRIMARY_DOMAIN}`, …).
   No hardcoded brand/domain/secret in committed files.
5. Secrets are referenced as env vars and documented in `.env.example`; never commit real secrets.
6. Stop at the goal boundary. Verify ACCEPTANCE CRITERIA. Report what was created and how it was tested.

---

## 4. Build order & dependency graph

| # | Goal | Depends on | Outcome |
|---|---|---|---|
| **PREP** | [Reference environment](goals/GOAL-PREP-reference-environment.md) | — | **run first** — vendor+pin+index sources, contract catalogs, golden refs |
| 00 | [Project scaffold](goals/GOAL-00-project-scaffold.md) | PREP | repo layout, `.env.example`, Makefile, brand dirs |
| 01 | [Base stack](goals/GOAL-01-base-stack.md) | 00 | Postgres + Mattermost TE up via compose |
| 02 | [Edge proxy](goals/GOAL-02-edge-proxy.md) | 01 | Caddy TLS + per-domain routing + IP filter |
| 03 | [Keycloak SSO](goals/GOAL-03-keycloak-sso.md) | 02 | LDAP/SAML/Google/O365/OIDC → MM via GitLab-OAuth bridge |
| 04 | [White-label branding](goals/GOAL-04-white-label-branding.md) | 02 | rebranded UI/login/emails, zero "Mattermost" leakage |
| 05 | [Feature plugins](goals/GOAL-05-feature-plugins.md) | 01 | Calls, Playbooks, Boards installed & enabled |
| 06 | [AI translation bot](goals/GOAL-06-ai-translation-bot.md) | 01 | Ollama-backed auto-translation plugin |
| 07 | [Push notifications](goals/GOAL-07-push-notifications.md) | 01 | self-hosted push-proxy (conditional: custom mobile) |
| 08 | [Data lifecycle](goals/GOAL-08-data-lifecycle.md) | 01 | retention + compliance export jobs |
| 09 | [Resilience & backup](goals/GOAL-09-resilience-backup.md) | 01 | backups, restart/heal, Telegram alerts (HA alternative) |
| 10 | [Tenant provisioning](goals/GOAL-10-tenant-provisioning.md) | 00–09 | "new client in <30 min" — Scout & CleanVeteran examples |
| 11 | [Acceptance & verification](goals/GOAL-11-acceptance-verification.md) | all | end-to-end test + legal checklist |

Minimum viable client = **PREP → 00 → 01 → 02 → 03 → 04 → 11**. The rest are value-add / hardening.
(Doc numbers `04`/`05` are *reference docs*; the *branding* build step is `GOAL-04`.)

---

## 5. Reference source (already on this machine)

Version-pinnable read-only clones (kept **outside** the vault). Generated contract catalogs live in
[`reference/`](reference/README.md). Full model in [`docs/04-REFERENCE-ENVIRONMENT.md`](docs/04-REFERENCE-ENVIRONMENT.md).
- `~/mattermost-src/mattermost` — server, webapp, OpenAPI, config struct, plugin API, mmctl, TS types
- `~/mattermost-src/docs` — admin/user docs (Sphinx) · `mattermost-developer-documentation` — dev docs (Hugo)
- `~/mattermost-src/mattermost-api-reference` — standalone OpenAPI
- `~/mattermost-src/mattermost-{mobile,desktop,plugin-calls,-playbooks,-boards}` — apps + feature plugins

**Search-first rule for the implementing agent:** answer config/API/CLI/type questions from
`reference/*.md` → vendored source → RAG → Context7 MCP. **Never invent a name.**

---

## 6. Status

Track per-goal status here as Codex completes them.

| Goal | Status | Notes |
|---|---|---|
| PREP | ◐ partial | sources vendored + catalogs generated; **version-pin to MM_VERSION + RAG index pending** |
| 00 | ☐ todo | |
| 01 | ☐ todo | |
| 02 | ☐ todo | |
| 03 | ☐ todo | |
| 04 | ☐ todo | |
| 05 | ☐ todo | |
| 06 | ☐ todo | |
| 07 | ☐ todo | |
| 08 | ☐ todo | |
| 09 | ☐ todo | |
| 10 | ☐ todo | |
| 11 | ☐ todo | |


<!-- ============================================================ -->
## FILE: `docs/00-OVERVIEW.md`

# 00 — Overview, Scope & Decisions

## Purpose of this document
Give the implementing agent (and any human reviewer) the **why** behind the template: what we are
building, for whom, the core thesis that makes it legal and cheap, the explicit decisions taken, and
what is in/out of scope. Every GOAL file assumes the reader has internalized this page.

---

## 1. Product concept

A **white-label, self-hosted, secure team-collaboration / ChatOps platform** that we deploy repeatedly
for B2B clients under **their** brand. Technically it is **Mattermost Team Edition** (open-source Slack
alternative) with the missing "enterprise" capabilities reconstructed from the outside.

- **Sold as:** the client's own branded secure messaging / operations hub (no "Mattermost" anywhere).
- **Deployed as:** one isolated stack per client (own domain, DB, identity realm, branding).
- **Differentiator vs. raw Slack/Teams:** self-hosted (data sovereignty), unlimited message history
  (Team Edition has no history cap — unlike Mattermost's own free "Entry" tier), SSO, and our
  AI/automation layer (translation, bots) running on our own inference (Ollama).

### First two target clients (worked examples in GOAL-10)
- **Scout** — Samsung-affiliated call-center operation. Security/identity-sensitive (B2G-adjacent).
  More likely to eventually need real compliance/HA → may justify a paid tier or deeper DIY later.
- **CleanVeteran** — cleaning-service business. Simple branded chat + basic SSO is enough.

> Client codenames in this repo are placeholders. Real per-client values live only in their `.env`.

---

## 2. The core thesis (why this works, legally and economically)

Mattermost is **open-core**:
- The **Team Edition core** is genuine FOSS (server = AGPL-3.0, webapp/config = Apache-2.0).
- The **Enterprise features** (LDAP, SAML, SSO, HA cluster, compliance, retention, etc.) are
  **closed source** in a private repo and gated behind a paid license key.

Our thesis: **almost every enterprise feature is just functionality, and functionality is not
copyrightable.** We reproduce each one from the outside — using an identity broker (Keycloak), the
reverse proxy, the plugin API, and external scheduled jobs — **without modifying the Mattermost server
and without touching any Enterprise source.** Result: an Enterprise-equivalent product, fully legal,
zero per-seat license cost.

The single feature that is genuinely hard to reproduce is **HA clustering**; we replace it pragmatically
with single-node resilience (backups + auto-heal + DB replication). See [`03-FEATURE-MATRIX.md`](03-FEATURE-MATRIX.md).

---

## 3. Design decisions (defaults — change here, propagates everywhere)

| # | Decision | Choice | Rationale |
|---|---|---|---|
| D1 | Orchestration | **docker-compose** | Matches existing infra; k8s (helm/operator) is the scale-up path, documented but not default |
| D2 | Tenancy | **one isolated stack per client** | True white-label isolation; can be co-located on one host via distinct compose project + volumes, or on a per-client cloud VM |
| D3 | Core modification | **none, ever** | Avoids AGPL §13 network-source-disclosure; protects against clients self-hosting our fork |
| D4 | Identity | **Keycloak as broker** in front of MM | One component covers LDAP+SAML+Google+O365+OIDC (Enterprise features #10/11/12) |
| D5 | MM ↔ Keycloak wiring | **GitLab-OAuth bridge** | GitLab OAuth is the only SSO in Team Edition and allows custom endpoints; point it at Keycloak |
| D6 | Branding | webapp assets (Apache) + System Console config + custom CSS | Web/server white-label now; **custom mobile app rebrand is a separate later phase** |
| D7 | Reverse proxy / TLS | **Caddy** | Automatic TLS, trivial per-domain routing, simple IP allow/deny |
| D8 | AI/automation | **plugins on our own Ollama** | Differentiator; avoids paid SaaS; reuses existing Vhagar inference |
| D9 | HA | **single-node resilience**, not cluster | Cluster is the one non-reproducible EE feature; resilience pattern covers 1–2-person-run reality |
| D10 | Secrets | env-injected, never committed | `.env.example` documents every var; real values per client only |

**Assumptions** (flag if wrong before building):
- Each client has (or we register) a domain we control DNS for.
- Target scale per client: tens to low-hundreds of users (Team Edition's sweet spot).
- We host (managed service), clients do not self-administer the servers.
- Push notifications / custom mobile apps are **out of MVP scope** (GOAL-07 is conditional).

---

## 4. Scope

**In scope (MVP):** base stack, TLS + domain + IP filter, SSO (LDAP/SAML/OIDC via Keycloak),
white-label web UI + emails, feature plugins (calls/playbooks/boards), data retention + export,
single-node resilience + backups, multi-tenant provisioning workflow, acceptance tests.

**In scope (value-add):** AI translation bot (Ollama), additional integration plugins.

**Out of scope (later phases):** custom-branded mobile apps in App Store / Play Store, true HA
clustering, regulated-industry certified compliance (Actiance/Global Relay archiver formats),
Microsoft Intune MAM, attribute-based access control (ABAC), air-gapped deployment.

---

## 5. Glossary

- **Team Edition (TE):** free, open-source Mattermost. Official image `mattermost/mattermost-team-edition`.
  Unlimited message history; no native SSO except GitLab OAuth; no EE features.
- **Enterprise Edition (EE):** Mattermost's paid build; closed-source features gated by license key.
- **Entry:** Mattermost's *free* mode of the EE binary (no key). More features than TE **but capped at
  10,000 total messages** — which is why we use TE, not Entry, for a chatty product.
- **Keycloak:** open-source identity & access management; we use it as the SSO **broker / IdP**.
- **GitLab-OAuth bridge:** technique of pointing TE's GitLab OAuth settings at Keycloak's OIDC
  endpoints so TE gets OIDC SSO for free. (See GOAL-03.)
- **`mmctl`:** Mattermost's official admin CLI (plugin install, config, user mgmt).
- **Brand slug:** lowercase id for a client (e.g. `scout`, `cleanveteran`) used in paths, container
  names, compose project name, and DNS.

---

## 6. Internal codename / branding hygiene (hard rule)

Client-facing surfaces (UI, emails, domains, docs handed to clients) must contain:
- **Zero** internal company/project codenames.
- **Zero** "Mattermost" trademark (name, logo, favicon, default URLs, support links).

This repo is internal; the deployed product is not. GOAL-04 and GOAL-11 enforce this.


<!-- ============================================================ -->
## FILE: `docs/01-ARCHITECTURE.md`

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


<!-- ============================================================ -->
## FILE: `docs/02-LEGAL-MODEL.md`

# 02 — Legal Model (read before writing any code)

## Purpose
This template's entire value rests on staying inside three legal lines. If a GOAL implementation would
cross one, **stop and flag it**. This page is the authority on what is and isn't allowed.

---

## The 3 hard rules

### Rule 1 — Never modify the Mattermost server core
The server source is **AGPL-3.0**. AGPL §13 says: if you *modify* the software and let users interact
with it **over a network**, you must offer those users the **complete corresponding source** of your
modified version. For a hosted white-label product that means handing your modifications to your own
clients — who could then drop you and self-host. **So we never fork/patch the Go server.** We add
capability from the outside (proxy, plugins, external jobs). Unmodified official image → AGPL §13 is
not triggered.

> The webapp and config dirs (`webapp/`, `server/public/`, `server/templates/`, `server/i18n/`) are
> **Apache-2.0**, which has **no copyleft**. Branding via these assets is safe and does not create an
> AGPL "modified version" of the server.

### Rule 2 — Never use Enterprise (`server/enterprise`) source in production
`server/enterprise/` and the private `github.com/mattermost/enterprise` repo are under the **Mattermost
Source Available License**: production use requires a valid Enterprise E20 subscription. We do not have
it and do not use it. We **re-implement** the same *functionality* ourselves (functionality is not
copyrightable) using clean-room methods — reading only the **public interfaces** to know *what* to
build, never copying EE code. (We can't anyway: the private repo returns 404.)

### Rule 3 — Remove all "Mattermost" trademark from client-facing surfaces
"Mattermost" is a trademark; its use needs written approval. White-labeling **requires** stripping the
name, logo, favicon, default support/help URLs, and email branding. Apache-licensed webapp assets make
this legal to change; the trademark obligation makes it mandatory. (GOAL-04 + GOAL-11 enforce.)

---

## Why "re-implement it yourself" is legal

| Concern | Verdict |
|---|---|
| Copy Mattermost's EE source | ❌ Forbidden (Source Available License) — and impossible (private 404) |
| Write our **own** LDAP/SAML/SSO/retention/etc. | ✅ Legal — features/ideas aren't copyrightable |
| Use third-party FOSS to provide the feature (Keycloak, push-proxy) | ✅ Legal — their own permissive/AGPL licenses, run as separate services |
| Patch the EE **license check** out of the open core | ⚠️ Legal under AGPL **only if** you then publish your modified source (Rule 1) — and pointless, because the high-value EE code isn't in the open tree anyway. **We don't do this.** |
| Forge / crack / reuse a paid license key | ❌ Illegal. Never. |

The clean-room boundary: **read public interfaces → build your own implementation.** Never obtain or
paste private EE code.

---

## AGPL posture of our actual stack

| Layer | Our action | License trigger |
|---|---|---|
| MM Go server | run official image, **unmodified** | none (no modification) |
| MM webapp assets (branding) | replace logo/CSS/favicon (Apache-2.0) | none (Apache, no copyleft) |
| MM config / System Console | set values | none |
| Plugins (calls/playbooks/boards) | install official builds | their own licenses (mostly Apache/MIT), separate processes |
| Our custom plugin (translation) | our code, our copyright | we choose its license; it's a separate work via the plugin API |
| Keycloak / Caddy / Postgres | run as separate services | their own licenses; not derivative of MM |
| External jobs (retention/export/backup) | our scripts against DB/API | our code |

Net: **no AGPL source-disclosure obligation to clients**, because the only AGPL component (the server)
is unmodified, and everything we author is a separate work.

---

## Per-feature legality quick-reference
(Full feature table with the *technical* DIY approach is in [`03-FEATURE-MATRIX.md`](03-FEATURE-MATRIX.md).)

All 16 EE features may be reproduced legally **except** by copying EE code. The reproduction method per
feature (proxy / plugin / external job / third-party FOSS) is always a separate work and never touches
EE source. HA cluster is reproduced only partially (single-node resilience) — not a legal limit, a
technical one.

---

## Escalation: when paid / partnership is the right call
DIY is legal and free, but flag the client to a **paid tier or Mattermost OEM/reseller partnership** when:
- The client contractually requires **certified compliance archiving** (Actiance/Global Relay) or
  formal **eDiscovery/legal hold** with vendor liability.
- **True HA / SLA-backed uptime** is contractual.
- A government/large-enterprise buyer (e.g. Scout/Samsung) wants a **vendor of record** with support
  guarantees — sometimes the official partnership is the easier sale, not the cheaper build.

These are business decisions, surfaced here so the build never silently over-promises.

---

## Sources
- `~/mattermost-src/mattermost/LICENSE.txt` (MIT-compiled / AGPL-source / Apache-config + trademark clause)
- `~/mattermost-src/mattermost/server/enterprise/LICENSE` (Mattermost Source Available License)
- `~/mattermost-src/mattermost/server/enterprise/external_imports.go` (closed-source EE feature list)
- https://docs.mattermost.com/product-overview/editions-and-offerings.html


<!-- ============================================================ -->
## FILE: `docs/03-FEATURE-MATRIX.md`

# 03 — Feature Matrix: 16 Enterprise Features × Our DIY Replacement

## Purpose
The closed-source Enterprise features (from `server/enterprise/external_imports.go`) and exactly **how
we reproduce each one** from the outside, which GOAL builds it, the difficulty, and whether a typical
client actually needs it. This is the bridge between "what EE has" and "what we ship."

Difficulty: 🟢 easy · 🟡 medium · 🟠 hard · 🔴 very hard · ⚫ skip/N-A

| # | EE feature | What it does | DIY replacement | Built in | Diff | Client need |
|---|---|---|---|---|---|---|
| 1 | **ip_filtering** | Restrict access by IP range | Caddy `@denied`/`remote_ip` allow-deny + firewall/Cloudflare | GOAL-02 | 🟢 | optional |
| 2 | **data_retention** | Auto-delete old messages/files by policy | Scheduled job: `DELETE FROM posts WHERE createat < …` + file prune, or admin API | GOAL-08 | 🟢 | common |
| 3 | **compliance** | Activity reports for regulated orgs | SQL reports over Postgres → CSV/JSON; our own report generator | GOAL-08 | 🟢 | rare |
| 4 | **message_export (csv)** | Export messages for archiving | DB → CSV exporter (cron container) | GOAL-08 | 🟢 | rare |
| 5 | **push_proxy** | Mobile push notification relay | **Already FOSS**: self-host `mattermost-push-proxy` + own certs | GOAL-07 | 🟢 | mobile only |
| 6 | **autotranslation** | Inline message translation | Custom plugin → **our Ollama**; hook posts, post translation | GOAL-06 | 🟢🟡 | value-add |
| 7 | **account_migration** | Move users between auth backends | One-off admin-API/`mmctl` scripts | GOAL-10 (note) | 🟡 | rare |
| 8 | **notification** | Advanced notification controls | TE has base notifications; extras via plugin | — (defer) | 🟡 | optional |
| 9 | **outgoing_oauth_connections** | MM auths to external services via OAuth | Per-integration plugin handles its own OAuth | — (per need) | 🟡 | rare |
| 10 | **oauth/{google,office365,openid}** | Google / MS365 / generic OIDC SSO | **Keycloak** as IdP/broker → MM via GitLab-OAuth bridge | GOAL-03 | 🟡 | **common** |
| 11 | **ldap** | AD/LDAP login + user/group sync | **Keycloak LDAP/AD federation** → OIDC → MM | GOAL-03 | 🟡 | **common** |
| 12 | **saml** | SAML 2.0 SSO (Okta/ADFS/AzureAD) | **Keycloak** brokers SAML → OIDC → MM | GOAL-03 | 🟡🟠 | common |
| 13 | **message_export (actiance/global_relay)** | Proprietary financial archiver formats | Replicate documented XML schema from DB (heavy) | (out of MVP) | 🟠 | regulated only |
| 14 | **access_control (ABAC)** | Attribute-based fine-grained access | TE role-based perms (RBAC) cover most; full ABAC = big | (out of MVP) | 🔴 | gov/classified |
| 15 | **intune** | MS Intune MAM (mobile app mgmt) | MS MAM SDK + custom mobile build | (out of MVP) | 🔴 | enterprise mobile |
| 16 | **cluster (HA)** | Multi-node no-downtime clustering | **Not reproduced.** Single big node + PG replication + auto-heal + backups | GOAL-09 | 🔴 | scale-up |
| — | **license** | License-key validation engine | N/A — we run unlicensed TE; nothing to validate | — | ⚫ | — |
| — | **cloud** | Mattermost's own SaaS billing/provisioning | Irrelevant to self-host | — | ⚫ | — |

---

## The high-value cluster: identity (#10/#11/#12)
For almost every client, the *only* enterprise features that matter are **SSO / LDAP / SAML**. All three
collapse into **one component — Keycloak** — placed in front of Mattermost. Keycloak federates the
client's directory (AD/LDAP) or external IdP (Okta/Azure/Google/O365/SAML) and presents a single OIDC
identity to Mattermost via the GitLab-OAuth bridge. **Solve GOAL-03 and you've reproduced 3 of the most
demanded EE features at once, legally and free.**

## The one genuine wall: HA cluster (#16)
True clustering (shared cache invalidation, gossip, leader election) lives deep in the EE server and
cannot be bolted on from outside. We do **not** reproduce it. Instead (GOAL-09): one vertically-scaled
node + Postgres streaming replication + container auto-restart/heal + frequent backups + alerting. This
covers the realistic uptime needs of a small managed deployment. If a client contractually needs true
HA, that's an escalation to a paid tier (see `02-LEGAL-MODEL.md` §Escalation).

## What we deliberately defer
#13 (regulated archiver formats), #14 (ABAC), #15 (Intune), and custom mobile (#5/#7 mobile parts) are
out of MVP. They're real engineering with narrow demand; build them per-contract when a client pays for
the need. Documented here so nothing is silently forgotten.


<!-- ============================================================ -->
## FILE: `docs/04-REFERENCE-ENVIRONMENT.md`

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


<!-- ============================================================ -->
## FILE: `docs/05-ENTERPRISE-GRADE-PREP.md`

# 05 — Enterprise / Big-Tech-Grade White-Labeling

## Purpose
Answer the question directly: *"if a big-tech-grade operation white-labeled this at scale, what would
they prepare that we haven't?"* — and turn it into a **maturity ladder** so we can choose, per client,
how far up to climb. Same structure at every scale; only the rigor changes (fractal).

The honest framing: our current template is a solid **L1**. Selling to a CleanVeteran needs L1–L2.
Selling to a Samsung-grade buyer (Scout) needs L3, and the components of L4 become contractual.

---

## The maturity ladder

### L1 — Reproducible template (where we are)
- One parameterized stack per client (compose + `.env` + brand assets), core unmodified.
- Vendored + indexed reference environment (`04-REFERENCE-ENVIRONMENT.md`).
- Manual-ish provisioning + an acceptance/legal gate.
**Good enough for:** SMB clients, pilots, CleanVeteran.

### L2 — Engineered delivery
What a competent product team adds:
- **Everything-as-code + GitOps:** infra in Terraform, app in Helm/Kustomize, per-client config in a git
  repo; merge → deploy. No hand-run `docker compose up` in prod.
- **CI/CD:** pipeline that lints, builds, spins the stack ephemerally, runs `verify.sh` (GOAL-11), and
  blocks release on the legal/branding gate.
- **Supply-chain hygiene:** pin images by **digest** (not just tag); generate an **SBOM** (Syft);
  scan for CVEs (Trivy/Grype) and **license contamination** (ScanCode/FOSSA — proves no AGPL/EE leak
  into our deliverables, which is the legal moat made auditable).
- **Secrets management:** Vault / SOPS / cloud secret manager — never env files on disk in prod.
- **Backup/restore tested (RTO/RPO) + observability basics** (Prometheus/Grafana/Loki).
**Good enough for:** serious B2B, multi-client portfolios.

### L3 — Fleet / control plane (true multi-tenant SaaS operation)
How Mattermost itself runs thousands of customer installs — and what we'd build to operate dozens:
- **A control plane** = the source of truth for "which tenants exist, what version, config, brand,
  health," that **reconciles desired → actual** (the operator/GitOps pattern). Mattermost open-sources
  exactly this: **`mattermost-operator`** (k8s operator) + **`mattermost-cloud`** (fleet provisioner).
  Study/repurpose these instead of inventing a control plane.
- **Tenancy model decision (AWS SaaS lens):** *silo* (stack per tenant — our default, max isolation),
  *pool* (shared cluster, logical separation — cheapest at scale), or *bridge* (hybrid). Pick per
  isolation/compliance vs. cost. Add per-tenant quotas (noisy-neighbor), and optional **BYOK** (tenant-
  held encryption keys).
- **Identity at scale:** not hand-built Keycloak realms — **automated realm provisioning** (Keycloak
  admin API / `terraform-provider-keycloak`), **SCIM** user provisioning, JIT, per-tenant MFA policy,
  self-service IdP onboarding.
- **Observability + SLO:** OpenTelemetry traces, per-tenant dashboards, error budgets, on-call/alerting.
- **Release engineering:** canary → blue-green rollouts, automated rollback, fleet version-skew control,
  safe DB-migration gating, maintenance windows.
**Good enough for:** operating a real white-label SaaS business; Scout/Samsung-grade buyers.

### L4 — Regulated / mission-critical (what becomes contractual, not just nice)
- **Compliance posture:** SOC 2 / ISO 27001, audit logging, **certified archiving** (Actiance / Global
  Relay) and eDiscovery/legal-hold with vendor liability, data-residency/region pinning, DPA +
  subprocessor list.
- **True HA / DR** with contractual uptime SLA (the one feature we can't DIY — see below).
- **Image signing & provenance** (cosign/sigstore, SLSA), private registry mirror, air-gapped install.
- **Pen-tested, threat-modeled, formal incident response.**

---

## Where DIY ends and you buy: the escalation rule
Three things, at L4, are usually **cheaper/safer to buy than build**:
1. **True HA clustering (#16)** — not reproducible from outside (see `03-FEATURE-MATRIX.md`).
2. **Certified compliance archiving (#13) + eDiscovery** — regulators want a vendor of record.
3. **A government/large-enterprise buyer (Scout/Samsung)** who wants **someone to sue if it breaks** —
   indemnification and support SLAs.

For those, the big-tech answer is an **OEM / embedding agreement with Mattermost** (they have one). It
legally grants full rebranding + the EE features + support + indemnity. Counter-intuitively, for a
Samsung-grade deal the **vendor-backed OEM is often the *easier sale*, not the more expensive build** —
"backed by Mattermost Enterprise" can be a selling point. DIY open-core (this template) is the right tool
for SMB/pilot velocity; OEM is the right tool for regulated whales. **Use both, per client.**

---

## What we should prepare next (concrete backlog beyond MVP)
Ordered by leverage:
1. **Pin + lock + RAG-index the reference env** (GOAL-PREP) — removes guessing. *Do first.*
2. **CI that runs GOAL-11 `verify.sh` on every change** — makes the legal/branding gate automatic.
3. **Supply-chain: digest-pin + SBOM + license scan** — turns "we don't use EE/GPL" into an audit artifact.
4. **Provisioning hardening (GOAL-10) → a thin control plane** — a tenants registry + reconcile loop
   (repurpose `mattermost-operator`/`mattermost-cloud` ideas) once client count > a handful.
5. **Observability stack** (Prometheus/Grafana/Loki) shared across tenants.
6. **Identity automation** (Keycloak realm-as-code + SCIM) once SSO onboarding repeats.
7. **Per-tenant backup/DR with tested RTO/RPO + region pinning** as deals get bigger.
8. **Decide OEM vs DIY per pipeline deal** — Scout likely OEM-track; CleanVeteran DIY-track.

## The one-line principle
At every rung the move is the same: **make the source of truth explicit, make the desired state code,
make verification automatic, and make the boundary (DIY vs buy) a deliberate per-client decision** — not
an accident discovered in production.


<!-- ============================================================ -->
## FILE: `docs/06-REPRODUCE-ON-NEW-DEVICE.md`

# 06 — Reproduce on a new device (AWS box, laptop, anywhere)

## Purpose
Get a **byte-identical** working environment on any fresh machine in two commands — including the exact
Mattermost source state — without re-hosting upstream code.

## TL;DR
```bash
git clone git@github.com:shinjadong/whitelabel-collab.git
cd whitelabel-collab
./scripts/bootstrap.sh        # clones pinned upstream sources + regenerates catalogs
```
`CORE_ONLY=1 ./scripts/bootstrap.sh` skips the heavy mobile/desktop repos.

## What lives where (and why)
| Content | In our repo? | Mechanism |
|---|---|---|
| Docs, goals, reference catalogs, scripts | ✅ committed | plain git (small) |
| Mattermost source (monorepo, docs, plugins, …) | ❌ **not** committed | **pinned clone** via `sources.lock` + `bootstrap.sh` |

## Why we pin instead of vendoring the source (deliberate)
1. **Legal.** `server/enterprise/` is under the **Mattermost Source Available License** — copying/
   publishing/redistributing it (which a vendored copy in our GitHub repo would do) is forbidden without
   an E20 subscription. Pinning = we only store a *pointer* (a commit SHA); the code is fetched from
   Mattermost's own GitHub. No re-hosting → no violation. (This is Rule 2 of `02-LEGAL-MODEL.md`.)
2. **Size.** The sources total ~1.3 GB; GitHub discourages repos >1 GB and blocks files >100 MB.
3. **Hygiene.** Vendoring duplicates upstream history and rots; a pinned SHA is exact and tiny.

## How identical-ness is guaranteed
- `sources.lock` records, per upstream repo, the **exact commit SHA** that was checked out when this repo
  was authored. `bootstrap.sh` clones each at that SHA (`git fetch --depth 1 origin <sha>`), so every
  device materializes the same tree.
- The contract catalogs (`reference/*.md`) are committed as a snapshot **and** regenerated by bootstrap
  from the freshly-pinned source, so they always match.

## Version pinning vs. "current" (important)
`sources.lock` currently tracks the **master/main HEADs** captured 2026-06-28 (not yet a release). For a
production build, re-pin to the release matching your `MM_VERSION` (see
`../goals/GOAL-PREP-reference-environment.md`): update the SHAs in `sources.lock` to the `release-<X.Y>`
tips, re-run `bootstrap.sh`, commit the lock. Then every device is identical **and** version-correct.

## Updating the lock (when you advance versions)
```bash
# after checking out new upstream refs locally:
for d in ~/mattermost-src/*/; do
  printf "%-35s %s %s\n" "$(basename "$d")" \
    "$(git -C "$d" remote get-url origin)" "$(git -C "$d" rev-parse HEAD)"
done   # paste the results into sources.lock, commit
```

## Alternative: git submodules
You *can* instead add each upstream as a shallow submodule pinned to a SHA
(`git submodule add`, `submodule.<name>.shallow=true`). We chose `sources.lock` + `bootstrap.sh` because
it's lighter, lets us skip optional repos, and keeps the legal boundary obvious. Submodules remain a valid
swap-in if you prefer `git clone --recurse-submodules` ergonomics.

## On the new box, after bootstrap
1. Install runtime: Docker + docker compose (the stack), git, python3 (already used by bootstrap).
2. Decide `MM_VERSION`; re-pin `sources.lock` if needed; re-run bootstrap.
3. Proceed with `GOAL-PREP` → `GOAL-00` → … per the README build order.


<!-- ============================================================ -->
## FILE: `goals/GOAL-00-project-scaffold.md`

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


<!-- ============================================================ -->
## FILE: `goals/GOAL-01-base-stack.md`

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


<!-- ============================================================ -->
## FILE: `goals/GOAL-02-edge-proxy.md`

# GOAL-02 — Edge proxy: Caddy (TLS + per-domain routing + IP filter)

**GOAL:** Put **Caddy** in front as the single public entrypoint: automatic HTTPS, hostname routing to
Mattermost (and later Keycloak), optional IP allow/deny (reproduces EE **ip_filtering** #1), and secure
headers — without exposing any backend port.

## WHY
Two needs at once: (a) production TLS + clean per-client domains, and (b) the first reproduced enterprise
feature — IP filtering — done correctly at the edge instead of inside Mattermost. SSO callbacks (GOAL-03)
and white-label domains (GOAL-04) both require real HTTPS on `chat.${PRIMARY_DOMAIN}`, so this must exist
before SSO.

## CONTEXT
- Caddy auto-provisions Let's Encrypt certs given a public domain + open 80/443 + `ADMIN_EMAIL`.
- Routing: `chat.${PRIMARY_DOMAIN}` → `mattermost-te:8065`; `id.${PRIMARY_DOMAIN}` → `keycloak:8080`
  (the Keycloak route is declared now even though Keycloak arrives in GOAL-03).
- IP filtering: Caddy `@allowed`/`remote_ip` matchers gate access when `IP_ALLOWLIST` is set; empty = open.
- Mattermost behind a proxy needs websocket pass-through and correct forwarded headers.

## PREREQUISITES
- GOAL-01 (base stack on `internal` network).
- DNS: `chat.${PRIMARY_DOMAIN}` and `id.${PRIMARY_DOMAIN}` → the host's public IP (for real TLS).
  For local testing, use Caddy `tls internal` (self-signed) and `/etc/hosts` entries.

## DELIVERABLES
```
compose/docker-compose.caddy.yml     # caddy service (merged via -f, or folded into main compose)
Caddyfile.tmpl                       # template rendered per client from .env
compose/edge-network.md              # doc: edge vs internal network model
```

### `Caddyfile.tmpl` (rendered with envsubst from the client `.env`)
```caddy
{
    email {$ADMIN_EMAIL}
}

(ipfilter) {
    @blocked not remote_ip {$IP_ALLOWLIST}
    respond @blocked "Forbidden" 403
}

chat.{$PRIMARY_DOMAIN} {
    import ipfilter
    encode zstd gzip
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        Referrer-Policy "no-referrer-when-downgrade"
    }
    reverse_proxy mattermost-te:8065 {
        # websocket + correct client IP forwarding
        header_up X-Forwarded-Proto https
        header_up X-Real-IP {remote_host}
    }
}

id.{$PRIMARY_DOMAIN} {
    import ipfilter
    reverse_proxy keycloak:8080 {
        header_up X-Forwarded-Proto https
    }
}
```
> If `IP_ALLOWLIST` is empty, render the `(ipfilter)` snippet as a no-op (omit the `@blocked` rule).

### caddy service
- image `caddy:${CADDY_VERSION}`
- ports `80:80`, `443:443` (the **only** published ports in the whole stack)
- volumes: rendered `Caddyfile`, `caddy_data` (certs), `caddy_config`
- networks: **both** `edge` and `internal` (so it can reach backends)
- Mattermost: set `MM_SERVICESETTINGS_SITEURL=https://chat.${PRIMARY_DOMAIN}` (already in GOAL-01) and
  ensure `MM_SERVICESETTINGS_ALLOWCORSFROM`/trusted proxy settings are sane behind Caddy.

## STEPS
1. Add the `caddy` service and `edge` network; keep backends off `edge`.
2. Provide a render step (envsubst) `Caddyfile.tmpl` → `Caddyfile` using the client `.env`.
3. Bring up; verify Caddy obtains a cert for `chat.${PRIMARY_DOMAIN}` (or self-signed in local mode).
4. Browse `https://chat.${PRIMARY_DOMAIN}` → Mattermost login loads over HTTPS; websocket connects
   (no console errors; channel switching works in real time).
5. Set `IP_ALLOWLIST` to a test CIDR, reload Caddy, confirm a non-listed IP gets 403; clear it, confirm open.
6. Document the edge/internal split in `compose/edge-network.md`.

## ACCEPTANCE CRITERIA
- [ ] Only ports 80/443 are published by the whole stack; backends remain internal.
- [ ] `https://chat.${PRIMARY_DOMAIN}` serves Mattermost with a valid cert (or trusted self-signed locally).
- [ ] WebSocket works through Caddy (messages appear without refresh).
- [ ] With `IP_ALLOWLIST` set, a disallowed source IP receives 403; empty allowlist → open.
- [ ] `id.${PRIMARY_DOMAIN}` route returns 502 now (Keycloak not up yet) — proves routing is wired for GOAL-03.

## GOTCHAS
- Mattermost is websocket-heavy; a misconfigured proxy breaks live updates. Verify real-time, not just page load.
- `X-Forwarded-Proto https` must reach Mattermost or it builds wrong redirect URLs (breaks OAuth in GOAL-03).
- Let's Encrypt needs real public DNS + open 80/443. For dev, use `tls internal` and hosts-file entries.


<!-- ============================================================ -->
## FILE: `goals/GOAL-03-keycloak-sso.md`

# GOAL-03 — Keycloak SSO broker (LDAP / SAML / Google / O365 / OIDC → Mattermost)

**GOAL:** Reproduce EE features **#10 oauth, #11 ldap, #12 saml** in one stroke: run **Keycloak** as the
identity broker and wire Mattermost **Team Edition** to it via the **GitLab-OAuth bridge**, so users log
in through Keycloak (which can federate AD/LDAP, brokered SAML/Google/O365, or local users).

## WHY
Identity is the single most-demanded enterprise capability and the highest-value part of this whole
template. Team Edition ships **no** SSO except GitLab OAuth — but GitLab OAuth **allows custom endpoints**,
so we point it at Keycloak. Keycloak then federates whatever the client uses (Active Directory via LDAP,
an external SAML/OIDC IdP, Google Workspace, Microsoft 365). One component → three EE features, legally,
with the Mattermost core untouched (see `../docs/02-LEGAL-MODEL.md`, `../docs/03-FEATURE-MATRIX.md`).

## CONTEXT — the bridge mechanics (get this exactly right)
Mattermost TE `GitLabSettings` has: `Enable, Id, Secret, Scope, AuthEndpoint, TokenEndpoint,
UserApiEndpoint`. We set the three endpoints to Keycloak's OIDC endpoints for the client realm:
```
AuthEndpoint    = https://id.${PRIMARY_DOMAIN}/realms/${KC_REALM}/protocol/openid-connect/auth
TokenEndpoint   = https://id.${PRIMARY_DOMAIN}/realms/${KC_REALM}/protocol/openid-connect/token
UserApiEndpoint = https://id.${PRIMARY_DOMAIN}/realms/${KC_REALM}/protocol/openid-connect/userinfo
```
**The make-or-break detail:** Mattermost's GitLab OAuth expects the userinfo response to contain an
`id` claim that is an **integer, unique per user**. Keycloak does not emit that by default. You MUST add
a Keycloak **protocol mapper** that outputs a numeric `id` claim in the userinfo/access token. Mattermost
also reads `username`, `email`, `name` — map those too.

Keycloak realm OIDC discovery (to copy exact endpoint paths):
`https://id.${PRIMARY_DOMAIN}/realms/${KC_REALM}/.well-known/openid-configuration`

## PREREQUISITES
- GOAL-02 (Caddy serving `id.${PRIMARY_DOMAIN}` → keycloak:8080; real or trusted-local TLS).
- GOAL-01 (Mattermost up). `MM_SERVICESETTINGS_SITEURL=https://chat.${PRIMARY_DOMAIN}` correct.

## DELIVERABLES
```
compose/docker-compose.keycloak.yml   # keycloak + keycloak-postgres services
keycloak/realm-export.json            # idempotent realm import: realm + mattermost client + mappers
keycloak/README.md                    # how federation (LDAP/SAML/Google/O365) is added per client
scripts/configure-mm-oauth.sh         # mmctl/config: set GitLabSettings to the realm endpoints
```

### Keycloak service
- image `quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}`
- `command: start --import-realm` (or start-dev for local); env `KC_DB=postgres`, DB creds from `.env`,
  `KC_HOSTNAME=https://id.${PRIMARY_DOMAIN}`, `KC_PROXY_HEADERS=xforwarded`, `KC_HTTP_ENABLED=true`
  (TLS terminates at Caddy), admin bootstrap `KEYCLOAK_ADMIN/KEYCLOAK_ADMIN_PASSWORD` from `.env`.
- `keycloak-postgres`: `postgres:${POSTGRES_VERSION}-alpine`, own volume `${BRAND_SLUG}_keycloak-postgres`.
- network `internal` only (Caddy fronts it).

### `keycloak/realm-export.json` must define
- realm `${KC_REALM}`.
- a confidential OIDC client `mattermost`:
  - `clientId = ${MM_GITLAB_CLIENT_ID}` (default `mattermost`), `secret = ${MM_GITLAB_CLIENT_SECRET}`
  - redirect URI: `https://chat.${PRIMARY_DOMAIN}/signup/gitlab/complete`
  - standard flow (authorization code) enabled
- protocol mappers on that client:
  - **numeric `id`**: a mapper emitting an integer unique per user into userinfo+access token, claim
    name `id`. (Options: a hash of the Keycloak user UUID to a stable integer, or a dedicated user
    attribute populated with a sequence. Document the exact mapper config used.)
  - `username` → claim `username`; `email` → claim `email`; full name → claim `name`.

## STEPS
1. Add Keycloak + its Postgres to compose; bring up; confirm `id.${PRIMARY_DOMAIN}` shows the Keycloak
   welcome/login (502 from GOAL-02 turns into 200).
2. Import the realm (via `--import-realm` or admin REST). Verify the `mattermost` client + mappers exist.
3. Hit `.well-known/openid-configuration`; confirm the three endpoint URLs match the `GitLabSettings`
   values you'll set.
4. Run `scripts/configure-mm-oauth.sh`: set `GitLabSettings.Enable=true`, `Id`, `Secret`, and the three
   endpoints via `mmctl --local config set ...` (or patch config.json), then `mmctl config reload`.
5. Create a test user in Keycloak. From `https://chat.${PRIMARY_DOMAIN}`, click the SSO/GitLab login
   button → authenticate at Keycloak → land back logged in to Mattermost (user auto-provisioned).
6. Write `keycloak/README.md` showing how to add, per client: **LDAP/AD user federation**, **SAML
   identity-provider brokering**, and **Google/Microsoft social** — all in Keycloak, transparently to MM.

## ACCEPTANCE CRITERIA
- [ ] SSO login end-to-end works: new Keycloak user → first login → Mattermost account auto-created.
- [ ] Userinfo returns a **numeric, unique `id`** (verify the token/userinfo; this is the #1 failure point).
- [ ] `username`, `email`, `name` populate correctly on the Mattermost profile.
- [ ] Mattermost server source is unmodified — only config + an external Keycloak service were added.
- [ ] `keycloak/README.md` documents the LDAP, SAML, and Google/O365 federation steps (the EE-feature
      reproduction) clearly enough to apply per client.
- [ ] All endpoints/secrets come from `.env`; nothing hardcoded.

## GOTCHAS
- **Numeric `id` claim** is the classic breakage — if login fails with a parse/format error, this is why.
- Keycloak behind Caddy: set `KC_PROXY_HEADERS=xforwarded` and a correct `KC_HOSTNAME`, or redirect URIs
  and issuer get the wrong scheme/host and OAuth fails.
- Redirect URI must be exactly `…/signup/gitlab/complete` (Mattermost's GitLab callback path).
- Keep "GitLab" naming only at the config/protocol level; the **login button text is rebranded** in GOAL-04
  (users must never see "GitLab" or "Mattermost").
- LDAP/SAML/Google/O365 are configured **inside Keycloak**, never in Mattermost — that's what keeps us on
  free Team Edition while delivering EE-grade SSO.

## Sources
- GitLabSettings custom-endpoint technique + Keycloak numeric-id mapper requirement (community-proven):
  Medium "Replacing GitLab SSO with Keycloak", DevOpsTales "Free SSO for Mattermost Teams Edition".


<!-- ============================================================ -->
## FILE: `goals/GOAL-04-white-label-branding.md`

# GOAL-04 — White-label branding (zero "Mattermost" leakage)

**GOAL:** Make the product look like the **client's own** application: name, logo, favicon, colors,
login page, and emails — with **no "Mattermost" or internal codename** visible anywhere a user can reach.

## WHY
This is what makes it "white-label" and satisfies **Rule 3** (trademark removal) in
`../docs/02-LEGAL-MODEL.md`. The webapp/config assets are **Apache-2.0**, so changing them is legal and
does **not** create an AGPL "modified version" of the server. Branding is parameterized per client so the
same template produces Scout-branded and CleanVeteran-branded instances from their `.env` + `brand/<slug>/`.

## CONTEXT — three depths of rebranding
1. **Config-level (no rebuild):** System Console / config.json — Site Name, Custom Brand Image &
   Text, Help/Terms/About links, support email, EnableCustomBranding. Fastest; covers a lot.
2. **Asset-level (file replacement, no source build):** favicon, app/PWA icons, login logo, email
   logo, custom CSS. Done by mounting replacement files into the official image's static paths.
3. **Deep (optional, source build):** remove residual "Mattermost" UI strings / build a fully rebranded
   webapp from the Apache-licensed `webapp/` source. **Out of MVP** — note where strings remain.

We do depths 1 + 2 now. Depth 3 and custom mobile apps are deferred (see `../docs/00-OVERVIEW.md` scope).

## PREREQUISITES
- GOAL-02 (HTTPS site reachable). GOAL-03 recommended (so the login button gets rebranded too).
- Per-client assets present in `brand/${BRAND_SLUG}/` (logo.png, favicon.ico, app icons, custom.css,
  email-logo.png). If missing, generate neutral placeholders and document required dimensions.

## DELIVERABLES
```
brand/<slug>/                         # client brand assets (logo, favicon, icons, custom.css, email-logo)
brand/REQUIREMENTS.md                 # exact files + dimensions/format the template expects
scripts/apply-branding.sh            # sets config + mounts assets + reloads
compose/branding.override.yml         # volume mounts for asset replacement into the MM image
```

### Config to set (via mmctl/config.json, all from `.env`/brand)
- `TeamSettings.SiteName = ${BRAND_DISPLAY_NAME}`
- `TeamSettings.CustomBrandText`, `EnableCustomBrand = true`, `CustomBrandImage` (login splash)
- `SupportSettings.*` → client's Terms/Privacy/Help/About/support-email URLs (no mattermost.com)
- `EmailSettings.FeedbackName/FeedbackEmail` → client identity; custom email logo
- OAuth login button label → client SSO name (so users never see "GitLab"/"Mattermost")
- Disable/redirect any in-product links pointing to mattermost.com (telemetry, "report a problem", docs)

### Asset replacement (depth 2, via `compose/branding.override.yml`)
Bind-mount `brand/${BRAND_SLUG}/` files over the image's static assets:
- favicon(s), `…/static/images/logo*`, PWA `manifest.json` icons, email header logo.
Document each target path (derive from the `mattermost-team-edition` image static dir / the
`~/mattermost-src/mattermost/webapp` reference clone).

## STEPS
1. Fill `brand/REQUIREMENTS.md` with required filenames, sizes, formats.
2. Place (or generate placeholder) assets in `brand/${BRAND_SLUG}/`.
3. `scripts/apply-branding.sh`: apply all config settings via `mmctl --local config set`, then
   `mmctl config reload`.
4. Add `compose/branding.override.yml` mounting the asset files; recreate the MM container.
5. Walk every user-reachable surface and confirm no "Mattermost"/codename: login page, tab title +
   favicon, system/welcome messages, notification emails, PWA install name/icon, error pages.
6. Record any residual "Mattermost" strings that need depth-3 (source build) in `brand/REQUIREMENTS.md`
   under "Known residuals (deferred)".

## ACCEPTANCE CRITERIA
- [ ] Browser tab shows client name + client favicon (no Mattermost icon).
- [ ] Login page shows client logo/text and the SSO button reads the client's name (not GitLab/Mattermost).
- [ ] A test notification email uses client name, logo, and from-address — no mattermost.com.
- [ ] PWA "Add to Home Screen" uses client name + icon.
- [ ] Grep of user-facing surfaces (and a manual click-through) finds no internal codename and no
      "Mattermost" except unavoidable deep-string residuals, which are listed as deferred.
- [ ] Branding is fully driven by `brand/${BRAND_SLUG}/` + `.env`; swapping slug reskins cleanly.

## GOTCHAS
- The Mattermost **server is still unmodified** — we only mount static assets + set config (Apache/config,
  not AGPL server code). Do not patch the binary.
- Some strings are baked into the compiled webapp bundle; full removal needs depth-3 (deferred). Don't
  over-promise "100% clean" until depth-3 is done.
- Mobile apps (official Mattermost app) still say "Mattermost" — custom mobile is a separate later phase.


<!-- ============================================================ -->
## FILE: `goals/GOAL-05-feature-plugins.md`

# GOAL-05 — Feature plugins: Calls, Playbooks, Boards

**GOAL:** Install and enable the official **Calls** (voice/video), **Playbooks** (runbooks/checklists),
and **Boards** (kanban) plugins on Team Edition — features that used to be Enterprise — for free.

## WHY
These three plugins deliver high-visible product value (huddles, incident playbooks, project boards) and
run fine on Team Edition. They're separate, openly-licensed plugin bundles installed via the plugin API —
no core modification, no EE license. Installing them headlessly and pinning versions makes every client
stack reproducible.

## CONTEXT
- Install method: `mmctl plugin marketplace install <id> <version>` (online) **or** upload a pinned
  bundle with `mmctl plugin add <file.tar.gz>`, then `mmctl plugin enable <id>`.
- Plugin state lives in config under `PluginSettings.PluginStates.<id>.Enable`; per-plugin config under
  `PluginSettings.Plugins.<id>`. After changes: `mmctl config reload`.
- Local clones for reference/build if marketplace is unavailable:
  `~/mattermost-src/mattermost-plugin-calls`, `-playbooks`, `-boards`.
- Plugin IDs: Calls=`com.mattermost.calls`, Playbooks=`playbooks`, Boards=`focalboard`/`boards`
  (confirm exact IDs from each plugin's `plugin.json` in the reference clones at build time).
- `mmctl --local` works because GOAL-01 set `ENABLELOCALMODE=true`.
- Calls needs a reachable RTC port/host config for media; set the call's `ICEHostOverride`/port per the
  plugin docs and ensure Caddy/host firewall allows the RTC UDP port (document it).

## PREREQUISITES
- GOAL-01 (MM up, `PluginSettings.Enable=true`, uploads enabled, local mode on).

## DELIVERABLES
```
scripts/install-plugins.sh           # idempotent: install + pin + enable + configure the 3 plugins
compose/plugins.versions.env         # pinned plugin versions (sourced into .env)
docs-notes/plugins.md                # IDs, versions, RTC/port notes, how to add more plugins
```

## STEPS
1. Determine exact plugin IDs + latest stable versions (from marketplace or each `plugin.json`); record
   in `compose/plugins.versions.env`.
2. `scripts/install-plugins.sh`: for each plugin → install pinned version → enable → apply any required
   config (e.g. Calls RTC settings) → `mmctl config reload`. Make it idempotent (skip if already present).
3. Open the product: start a Call/huddle, create a Playbook run, create a Board — each works.
4. For Calls, verify media connects (the RTC port path through host firewall/Caddy is correct).
5. Document IDs/versions/ports and "how to add another plugin" in `docs-notes/plugins.md`.

## ACCEPTANCE CRITERIA
- [ ] `mmctl plugin list` shows calls, playbooks, boards all **enabled**.
- [ ] A voice/video call connects between two test users (media flows, not just signaling).
- [ ] A playbook run can be created and checklist items toggled.
- [ ] A board can be created with cards.
- [ ] Versions are pinned (no implicit `latest`); re-running the script is idempotent.
- [ ] No core modification; plugins came via the plugin API only.

## GOTCHAS
- Calls media (WebRTC) needs the right host/port reachable — the most common failure is a blocked RTC
  UDP port or wrong `ICEHostOverride`. Verify actual audio, not just the call UI.
- A known `mmctl` quirk: newly-installed plugin config sometimes won't take until `mmctl config reload`
  (or a one-time System Console touch). Build the reload into the script.
- Pin versions compatible with `MM_VERSION`; check each plugin's min-server-version in its `plugin.json`.


<!-- ============================================================ -->
## FILE: `goals/GOAL-06-ai-translation-bot.md`

# GOAL-06 — AI translation bot (Ollama-backed) — reproduces EE autotranslation (#6)

**GOAL:** Build a small **custom Mattermost plugin** (or bot) that auto-translates messages on demand
using **our own Ollama** inference — reproducing EE "autotranslation" with zero SaaS cost and as a
product differentiator.

## WHY
EE's autotranslation (#6) is reproducible as a plugin because the plugin API exposes message events and
posting. Running it on **our** Ollama (already on Vhagar) means no per-message API cost, full data
sovereignty, and a feature the client can't get from raw Slack/Teams cheaply. This is where the
white-label product stops being "just Mattermost" and starts being **our** platform.

## CONTEXT
- Plugin API: a server plugin can implement `MessageHasBeenPosted` (or expose a slash command
  `/translate`) and call `CreatePost`/`UpdatePost` or post an ephemeral translation.
- Inference: HTTP to `${OLLAMA_BASE_URL}` (`/api/generate` or `/api/chat`) with `${OLLAMA_MODEL}`.
- Reference: starter template at `~/mattermost-src/mattermost-plugin-*` shows plugin structure; the
  official starter is `mattermost/mattermost-plugin-starter-template`.
- Default UX (pick one, document choice): (a) **on-demand** via `/translate <lang>` or a post action
  menu (lower noise, recommended), or (b) **auto** per-channel target-language translation as a reply.
- Ollama is **shared**, external to the client stack — reachable over the private/Tailscale network,
  not exposed publicly. Multiple client stacks can share one Ollama.

## PREREQUISITES
- GOAL-01 (plugin uploads + bot accounts enabled). Reachable Ollama at `${OLLAMA_BASE_URL}`.

## DELIVERABLES
```
plugins/ai-translate/                 # plugin source (Go server plugin; optional webapp action)
plugins/ai-translate/plugin.json      # id, version, settings schema (target langs, model, base url)
scripts/build-and-install-translate.sh# build bundle, mmctl plugin add + enable + configure
docs-notes/ai-translate.md            # UX choice, prompt, model, ops, privacy note
```

### Plugin behavior (MVP)
- Slash command `/translate <target-lang>` translates the message it replies to (or last message),
  posting the result as an ephemeral or threaded reply attributed to a bot.
- Settings (System Console, from plugin.json): `OllamaBaseURL`, `Model`, `DefaultTargetLang`,
  `AllowedChannels` (optional).
- Robustness: timeout + graceful "translation unavailable" on Ollama error; never block message posting.

## STEPS
1. Scaffold from the starter template; set plugin id `com.balerion.ai-translate` (internal id ok; **no
   codename in user-visible text** — bot display name is client-neutral, e.g. "Translator").
2. Implement the Ollama call (chat/generate) with a clear translation prompt; parse and post the result.
3. Expose settings via `plugin.json`; read `${OLLAMA_BASE_URL}`/`${OLLAMA_MODEL}` defaults from config.
4. Build the bundle; `scripts/build-and-install-translate.sh` installs + enables + configures it.
5. Test: `/translate en` on a Korean message returns an English translation in seconds.
6. Document prompt, model, latency, failure behavior, and the **privacy note** (messages sent to our
   self-hosted Ollama only — no third-party) in `docs-notes/ai-translate.md`.

## ACCEPTANCE CRITERIA
- [ ] `/translate <lang>` returns a correct translation via Ollama within a few seconds.
- [ ] Ollama outage → graceful failure message; normal messaging unaffected.
- [ ] Bot display name + all user-visible text are client-neutral (no internal codename, no "Mattermost").
- [ ] Settings configurable in System Console; defaults from `.env`.
- [ ] Plugin is a separate work via the plugin API; core unmodified.

## GOTCHAS
- Don't translate every message by default — noisy and costly. On-demand is the recommended MVP UX.
- Keep Ollama private (Tailscale/internal); never expose it through Caddy.
- Internal plugin id may contain a codename, but **nothing the end user sees** may (per branding hygiene,
  `../docs/00-OVERVIEW.md` §6).
- This goal is **value-add / optional** — not on the MVP critical path.


<!-- ============================================================ -->
## FILE: `goals/GOAL-07-push-notifications.md`

# GOAL-07 — Push notifications (self-hosted push proxy) — CONDITIONAL

**GOAL:** Stand up a self-hosted **`mattermost-push-proxy`** so mobile push works without Mattermost's
hosted HPNS — reproducing EE-adjacent **push_proxy (#5)**. **Conditional:** only needed once a
**custom-branded mobile app** exists. Web/PWA needs no push proxy.

## WHY
Mattermost's Hosted Push Notification Service is tied to the official mobile apps and Mattermost's keys.
A white-label product with its own mobile app must run its **own** push proxy with its **own** Apple/
Google credentials. The push proxy itself is already **open source** (public repo) — so this is pure
self-hosting, fully legal. We mark it conditional because MVP is web-first and custom mobile is deferred.

## CONTEXT
- Source: public repo `mattermost/mattermost-push-proxy` (also cloneable; not in our reference set by
  default — fetch at build time). Runs as a service MM talks to.
- Requires: Apple APNs auth key/cert (paid Apple Developer account) and Google FCM credentials, tied to
  the **custom mobile app's bundle id** — which only exists after the (deferred) custom-mobile phase.
- Mattermost config `EmailSettings`/`NativeAppSettings`/push settings point to the self-hosted proxy URL.
- Reference mobile source: `~/mattermost-src/mattermost-mobile` (React Native) — rebrandable (own bundle
  id, name, icon) under its license; that build pipeline is a separate later phase.

## PREREQUISITES
- GOAL-01 (MM up). **AND** a custom mobile app build (deferred phase) OR a decision to use the official
  app pointed at our proxy. If neither exists yet → **stop and mark this goal "blocked: needs mobile".**

## DELIVERABLES (when unblocked)
```
compose/docker-compose.push.yml       # mattermost-push-proxy service
push/config.json                      # APNs/FCM config (secrets via env, not committed)
docs-notes/push.md                    # cert/key procurement + mobile bundle-id wiring + test steps
```

## STEPS (when unblocked)
1. Add the push-proxy service; mount its config; supply APNs key + FCM creds via env/secret mounts.
2. Point Mattermost's push settings at the self-hosted proxy URL.
3. Build/rebrand the mobile app with our bundle id + the matching push credentials (separate phase).
4. Send a test push to a real device; confirm delivery in foreground and background.
5. Document procurement of certs and the bundle-id ↔ proxy ↔ MM wiring in `docs-notes/push.md`.

## ACCEPTANCE CRITERIA (when unblocked)
- [ ] A message to an offline mobile user produces a delivered push notification on a real device.
- [ ] Push proxy uses **our** APNs/FCM credentials tied to **our** app bundle id.
- [ ] Secrets are env/secret-mounted, never committed.
- [ ] Core MM unmodified; push proxy is the public OSS service self-hosted.

## GOTCHAS
- No custom mobile app → this goal is **not actionable**; record it as blocked and move on. Web/PWA
  notifications (browser) do not need this.
- APNs requires a paid Apple Developer account; FCM requires a Firebase project. These are procurement
  prerequisites, not code.
- This is **conditional / deferred**; it is NOT on the MVP critical path.


<!-- ============================================================ -->
## FILE: `goals/GOAL-08-data-lifecycle.md`

# GOAL-08 — Data lifecycle: retention + compliance/CSV export

**GOAL:** Reproduce EE **data_retention (#2)**, **compliance (#3)**, and **message_export CSV (#4)** with
external scheduled jobs that operate on the Mattermost database / admin API — no core changes, no EE.

## WHY
Clients often need "delete messages older than N days" and "give me an export of channel X for an audit."
EE gates these behind a license; the data lives in plain Postgres, so we reproduce them with our own
scheduled jobs. Legal (our code, separate work) and reproducible per client.

## CONTEXT
- Mattermost data is in Postgres (`Posts`, `FileInfo`, `Channels`, `Teams`, `Users` …). File blobs are in
  the data volume (or object store).
- Retention = delete `Posts` (and orphaned `FileInfo` + blobs) older than a policy, optionally per
  channel/team. Use **soft constraints**: dry-run first, log counts, then delete in batches.
- Export = query posts joined to channel/user → CSV (and/or JSON). The proprietary Actiance/Global Relay
  XML formats (#13) are **out of scope**; CSV/JSON covers the realistic need.
- Prefer the **admin API/`mmctl`** where it exists; fall back to direct SQL for retention/export. Direct
  deletes must be careful and batched to avoid lock/IO spikes.
- Schedule via a small cron container in the stack (or host cron) reading policy from `.env`.

## PREREQUISITES
- GOAL-01 (DB reachable on `internal`). Read-only DB role for export; a scoped role for retention deletes.

## DELIVERABLES
```
jobs/retention.sh                     # batched delete of posts/files older than RETENTION_DAYS (dry-run flag)
jobs/export.sh                        # channel/team/date-range → CSV/JSON to data/exports/
jobs/compliance-report.sh             # periodic activity summary (counts by user/channel/day)
compose/docker-compose.jobs.yml       # cron/scheduler container running the jobs
docs-notes/data-lifecycle.md          # policies, env vars, safety model, restore-from-export note
```
New `.env` vars (add to `.env.example`): `RETENTION_DAYS` (0=disabled), `RETENTION_SCOPE`
(`global`|`per-channel`), `EXPORT_SCHEDULE` (cron), `COMPLIANCE_SCHEDULE` (cron).

## STEPS
1. `jobs/retention.sh`: parameterized by `RETENTION_DAYS`; supports `--dry-run` (prints counts, deletes
   nothing); deletes in batches; prunes orphaned files; logs every run.
2. `jobs/export.sh`: args = team/channel/date-range/format; writes to `data/exports/<timestamp>/`.
3. `jobs/compliance-report.sh`: emits per-period activity counts (messages per user/channel/day) as CSV.
4. `compose/docker-compose.jobs.yml`: a lightweight cron container (e.g. alpine + crond, or `ofelia`)
   running retention/export/compliance on their schedules, reading creds from `.env`.
5. Test: seed old posts → `retention.sh --dry-run` reports correct count → real run deletes only those →
   `export.sh` produces a valid CSV that opens cleanly.
6. Document policies, safety (dry-run first), and how an export could be re-imported, in `docs-notes/`.

## ACCEPTANCE CRITERIA
- [ ] `retention.sh --dry-run` reports the exact set it *would* delete and deletes nothing.
- [ ] A real retention run deletes only posts older than `RETENTION_DAYS` and prunes their files; counts logged.
- [ ] `export.sh` produces a well-formed CSV/JSON for a given channel + date range.
- [ ] `compliance-report.sh` produces an activity summary.
- [ ] Jobs run on schedule via the cron container; all params from `.env`.
- [ ] No core modification; DB/API access only. Retention uses a scoped DB role, export a read-only role.

## GOTCHAS
- **Destructive.** Always dry-run first; batch deletes; take a backup (GOAL-09) before the first real run.
- Deleting `Posts` rows without pruning `FileInfo`/blobs leaks storage — handle both.
- Schema column names can change across MM versions — pin queries to `MM_VERSION` and verify against the
  reference clone `~/mattermost-src/mattermost/server` (store/sqlstore) before deleting.
- Regulated archiver formats (Actiance/Global Relay, #13) are deliberately **out of scope** here.


<!-- ============================================================ -->
## FILE: `goals/GOAL-09-resilience-backup.md`

# GOAL-09 — Resilience & backup (the HA-cluster alternative)

**GOAL:** Replace EE **cluster/HA (#16)** — which cannot be reproduced from outside — with pragmatic
single-node resilience: automated backups + restore, Postgres replication option, container auto-heal,
healthchecks, and Telegram alerting.

## WHY
HA clustering is the one genuine wall (see `../docs/03-FEATURE-MATRIX.md`). For a small managed
deployment, real uptime comes from **fast recovery**, not multi-node clustering: frequent verified
backups, automatic restart/heal, DB replication for disaster recovery, and alerts when something breaks.
This matches the existing "predator resilience" pattern already used on our infra.

## CONTEXT
- Components to protect: `mm-postgres` (the crown jewels), the MM data volume (files, plugins, config),
  Keycloak DB, and the rendered config/branding.
- Backup = `pg_dump` (both Postgres) + archive of the MM data volume + Keycloak realm export, to
  `data/backups/` and (recommended) an off-host target.
- Auto-heal = compose `restart: unless-stopped` + healthchecks + a watchdog that alerts on repeated
  failures.
- Alerts = Telegram bot (`${TELEGRAM_BOT_TOKEN}` / `${TELEGRAM_CHAT_ID}`) — reuse the existing predator
  alerting convention.
- Optional DR: Postgres streaming replication to a standby (documented; enable per client SLA).

## PREREQUISITES
- GOAL-01 (stack up). Telegram bot token + chat id in `.env` (optional but recommended).

## DELIVERABLES
```
jobs/backup.sh                        # pg_dump x2 + data volume archive + realm export → data/backups/ (+ off-host)
jobs/restore.sh                       # restore a chosen backup set into a fresh stack (with confirmation)
jobs/healthwatch.sh                   # poll healthchecks; Telegram alert on failure/recovery
compose/docker-compose.resilience.yml # backup cron + healthwatch + restart policies
docs-notes/resilience.md              # RTO/RPO, schedules, restore runbook, replication option
```
New `.env` vars (add to `.env.example`): `BACKUP_SCHEDULE` (cron), `BACKUP_RETENTION` (keep N),
`BACKUP_OFFSITE_TARGET` (optional rsync/s3), `ALERT_ON_FAILURES` (count threshold).

## STEPS
1. `jobs/backup.sh`: dump both Postgres DBs, archive MM data volume, export Keycloak realm; timestamped
   set in `data/backups/`; rotate to `BACKUP_RETENTION`; optional off-host copy.
2. `jobs/restore.sh`: given a backup set, restore into a clean stack; require explicit confirmation;
   verify post-restore (DB row counts, MM `/system/ping`, a known message present).
3. `jobs/healthwatch.sh`: poll each container healthcheck; on N consecutive failures send Telegram alert;
   send a recovery message when healthy again.
4. Set `restart: unless-stopped` + healthchecks on all services; add backup cron + healthwatch via
   `compose/docker-compose.resilience.yml`.
5. **Fire drill:** take a backup → `docker compose down -v` (simulate loss) → `restore.sh` → confirm the
   instance comes back with data intact. Record RTO (time to restore) and RPO (max data loss = backup
   interval) in `docs-notes/resilience.md`.
6. Document the optional Postgres streaming-replication setup for clients needing tighter DR.

## ACCEPTANCE CRITERIA
- [ ] `backup.sh` produces a complete, dated set (both DBs + data volume + realm) and rotates old ones.
- [ ] **Restore fire-drill passes:** after simulated total loss, `restore.sh` brings the instance back
      with messages, users, and config intact. RTO/RPO recorded.
- [ ] Killing a container triggers auto-restart; sustained failure fires a Telegram alert; recovery clears it.
- [ ] Backups can be pushed off-host when `BACKUP_OFFSITE_TARGET` is set.
- [ ] All schedules/targets from `.env`; no core modification.

## GOTCHAS
- A backup you've never restored is not a backup — the fire-drill (step 5) is mandatory, not optional.
- Back up the **data volume** too, not just Postgres — files, plugins, and config live there.
- This is **not** true HA: a single-node outage still means downtime until restart/restore. Set client
  expectations accordingly; true HA = escalate to a paid tier (`../docs/02-LEGAL-MODEL.md` §Escalation).


<!-- ============================================================ -->
## FILE: `goals/GOAL-10-tenant-provisioning.md`

# GOAL-10 — Tenant provisioning ("new client in < 30 minutes")

**GOAL:** Turn the whole template into a repeatable one-command-ish workflow that provisions a fully
branded, SSO-enabled client instance from a single `.env` + `brand/<slug>/`. Validate with **two worked
examples: Scout and CleanVeteran.**

## WHY
The business value is *repeatability*: each new client must be a parameter set, not a re-build. This goal
ties GOAL-00…09 together into a provisioning script + checklist so onboarding a client is fast, consistent,
and hard to get wrong.

## CONTEXT
- A client = `clients/<slug>.env` + `brand/<slug>/` + a Keycloak realm + DNS for `chat.`/`id.<domain>`.
- `scripts/render.sh` (stubbed in GOAL-00) becomes real here: it renders `Caddyfile`, realm export, and
  compose overrides from the client `.env`, and lays out `/opt/<slug>/`.
- Tenancy: one isolated compose project per client (`-p <slug>`, own volumes). Multiple clients can share
  one host (distinct projects/volumes, Caddy routes by domain) **or** get their own VM. Keycloak can be
  per-client (default, clean isolation) or one shared Keycloak with realm-per-client (resource-saving
  variant) — document both, default to per-client.
- Account migration (EE #7) belongs here as an occasional admin script (move users between auth backends
  via `mmctl`/API) — include a stub `jobs/account-migration.sh` and note when it's used.

## PREREQUISITES
- GOAL-00…09 complete (templates + scripts exist).

## DELIVERABLES
```
scripts/provision.sh                  # end-to-end: validate env → render → up → init admin → SSO → branding → plugins → verify
scripts/render.sh                     # (finalize the GOAL-00 stub) templates + .env → /opt/<slug>/
clients/scout.env.example             # filled example for Scout (security-sensitive; placeholders)
clients/cleanveteran.env.example      # filled example for CleanVeteran (simple)
brand/scout/ , brand/cleanveteran/    # placeholder brand assets for each
jobs/account-migration.sh             # stub for EE #7 (auth-backend migration), documented
docs-notes/provisioning.md            # the onboarding runbook + per-client checklist
PROVISIONING-CHECKLIST.md             # copy-per-client tick list (DNS, secrets, SSO source, branding, go-live)
```

## STEPS
1. Finalize `scripts/render.sh`: render `Caddyfile`, `keycloak/realm-export.json`, compose overrides from
   `clients/<slug>.env`; create `/opt/<slug>/` layout (per `../docs/01-ARCHITECTURE.md` §4).
2. Write `scripts/provision.sh` orchestrating, in order: validate `.env` → render → `make up` →
   create admin → apply SSO (GOAL-03) → apply branding (GOAL-04) → install plugins (GOAL-05) →
   enable jobs (GOAL-08/09) → run smoke checks (subset of GOAL-11). Idempotent; safe to re-run.
3. Produce two example client env files + placeholder brand folders (Scout, CleanVeteran). For Scout,
   note the likely need for tighter SSO (AD/SAML) and possible future compliance/HA escalation.
4. Dry-provision **CleanVeteran** locally end-to-end (self-signed TLS, hosts file); confirm a working
   branded, SSO instance appears.
5. Write the onboarding runbook + `PROVISIONING-CHECKLIST.md` (DNS records, secret generation, which SSO
   source the client uses, brand assets received, go-live + post-launch backup verified).

## ACCEPTANCE CRITERIA
- [ ] `scripts/provision.sh clients/cleanveteran.env` brings up a branded, SSO-enabled instance end-to-end.
- [ ] Re-running provision is idempotent (no duplicate state, no errors).
- [ ] Adding a second client (Scout) needs only a new `.env` + `brand/scout/` — no template edits.
- [ ] Two clients can run isolated on one host (distinct projects/volumes/domains) without interference.
- [ ] `PROVISIONING-CHECKLIST.md` is complete enough that onboarding follows it with no tribal knowledge.
- [ ] No internal codenames appear in any generated client-facing artifact.

## GOTCHAS
- Secrets must be generated per client (never reused across clients); the script should generate strong
  secrets if placeholders are detected.
- DNS + TLS are the usual go-live blockers — the checklist must front-load them.
- Shared-Keycloak variant saves resources but couples clients' identity service — default to per-client
  isolation unless a client explicitly wants the shared model.


<!-- ============================================================ -->
## FILE: `goals/GOAL-11-acceptance-verification.md`

# GOAL-11 — Acceptance & verification (functional + legal gate)

**GOAL:** Prove a provisioned instance is correct, secure, white-label-clean, and legally compliant
before it goes to a client. This is the release gate every client stack must pass.

## WHY
The template's promises (Enterprise-equivalent, legal, white-label) must be *verified*, not assumed. A
single checklist run catches SSO breakage, brand leakage, exposed ports, missing backups, or accidental
EE/trademark violations before a client ever sees them.

## CONTEXT
- Runs against a provisioned stack (GOAL-10). Combines functional tests (does it work?) with the
  **legal/branding gate** (`../docs/02-LEGAL-MODEL.md` Rules 1–3).
- Should be scriptable where possible (HTTP checks, grep for leakage, port scans) and checklist where not
  (visual brand review, real call/push test).

## PREREQUISITES
- A fully provisioned client stack (GOAL-10), ideally the CleanVeteran dry-run.

## DELIVERABLES
```
scripts/verify.sh                     # automated portion of the acceptance suite (exit non-zero on fail)
ACCEPTANCE-CHECKLIST.md               # full functional + legal gate, copy-per-client
docs-notes/verification.md            # how to run, how to interpret, sign-off record template
```

## ACCEPTANCE SUITE (the checklist `verify.sh` automates what it can)

### A. Functional
- [ ] `https://chat.<domain>` loads over valid TLS; websocket/live updates work.
- [ ] SSO end-to-end: a Keycloak user logs in; account auto-provisions; `id`/username/email/name correct.
- [ ] Plugins enabled; a real call connects (media), a playbook run + a board work.
- [ ] (If enabled) `/translate` returns a translation; Ollama failure degrades gracefully.
- [ ] Retention dry-run reports correctly; export produces valid CSV.
- [ ] Backup produces a complete set; **restore fire-drill passes** (data intact).

### B. Security
- [ ] Only ports 80/443 published; backends unreachable from outside (port scan confirms).
- [ ] IP allowlist (if set) blocks non-listed IPs (403); HSTS + security headers present.
- [ ] No default/weak admin credentials; secrets are per-client and not in git.
- [ ] Keycloak admin console not publicly exposed beyond intended access.

### C. White-label / legal gate (must be 100%)
- [ ] No "Mattermost" on any user-reachable surface (login, tab title, favicon, emails, PWA, errors) —
      except documented deferred deep-string residuals.
- [ ] No internal codename (Balerion/Maester/etc.) anywhere client-facing.
- [ ] SSO button shows the client's name (not "GitLab"/"Mattermost").
- [ ] Running image is `mattermost-team-edition` (NOT enterprise); core unmodified (no patched binary).
- [ ] No `server/enterprise` code used; no license key present; no forged license.
- [ ] Emails use client identity/domain; in-product links don't point to mattermost.com.

### D. Operability
- [ ] Backups scheduled + verified; healthwatch alerts to Telegram on induced failure.
- [ ] Version pins recorded (MM, Keycloak, Postgres, Caddy, plugins).
- [ ] Provisioning + acceptance both reproducible from docs alone.

## STEPS
1. Implement `scripts/verify.sh` to automate sections A/B/C/D where feasible (HTTP probes, `docker
   inspect` image tag, port scan, grep for "Mattermost"/codename in served HTML + emails, header checks);
   exit non-zero with a clear report on any failure.
2. Fill `ACCEPTANCE-CHECKLIST.md` (the full list above) for manual/visual items.
3. Run the suite against the CleanVeteran dry-run; fix anything red; re-run until green.
4. Add a sign-off record template (date, version pins, who verified) in `docs-notes/verification.md`.

## ACCEPTANCE CRITERIA
- [ ] `scripts/verify.sh` exits 0 on a correctly provisioned stack and non-zero with a clear reason otherwise.
- [ ] The legal/branding gate (section C) passes 100% (no leakage, TE image, no EE/trademark violation).
- [ ] The restore fire-drill is part of the suite, not skipped.
- [ ] A human can run the checklist and sign off using only this repo's docs.

## GOTCHAS
- Section C is a **hard gate** — any leakage or an enterprise image fails the release, no exceptions.
- "Works on my machine" ≠ verified — run against an actually provisioned stack (GOAL-10 output).
- Re-run the full suite after any version bump (MM/plugin upgrades can reintroduce branding strings).


<!-- ============================================================ -->
## FILE: `goals/GOAL-PREP-reference-environment.md`

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


<!-- ============================================================ -->
## FILE: `reference/README.md`

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


<!-- ============================================================ -->
## FILE: `reference/config-env-map.md`

# Config → MM_* Environment Variable Map

> AUTO-GENERATED by `scripts/build-reference.py` — do not edit by hand.
> Source of truth: `server/public/model/config.go`
> Regenerate after pinning the source to your `MM_VERSION`.

Mattermost maps `Config.<Section>.<Field>` to env var `MM_<SECTION>_<FIELD>` (uppercased).
Use these EXACT names in `.env`/compose. Deeper nested structs add further `_<FIELD>` levels.

## MM_SERVICESETTINGS  (`ServiceSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_SERVICESETTINGS_SITEURL` | *string |  |
| `MM_SERVICESETTINGS_WEBSOCKETURL` | *string |  |
| `MM_SERVICESETTINGS_LICENSEFILELOCATION` | *string |  |
| `MM_SERVICESETTINGS_LISTENADDRESS` | *string |  |
| `MM_SERVICESETTINGS_CONNECTIONSECURITY` | *string |  |
| `MM_SERVICESETTINGS_TLSCERTFILE` | *string |  |
| `MM_SERVICESETTINGS_TLSKEYFILE` | *string |  |
| `MM_SERVICESETTINGS_TLSMINVER` | *string |  |
| `MM_SERVICESETTINGS_TLSSTRICTTRANSPORT` | *bool |  |
| `MM_SERVICESETTINGS_TLSSTRICTTRANSPORTMAXAGE` | *int64 |  |
| `MM_SERVICESETTINGS_TLSOVERWRITECIPHERS` | []string |  |
| `MM_SERVICESETTINGS_USELETSENCRYPT` | *bool |  |
| `MM_SERVICESETTINGS_LETSENCRYPTCERTIFICATECACHEFILE` | *string |  |
| `MM_SERVICESETTINGS_FORWARD80TO443` | *bool |  |
| `MM_SERVICESETTINGS_TRUSTEDPROXYIPHEADER` | []string |  |
| `MM_SERVICESETTINGS_READTIMEOUT` | *int |  |
| `MM_SERVICESETTINGS_WRITETIMEOUT` | *int |  |
| `MM_SERVICESETTINGS_IDLETIMEOUT` | *int |  |
| `MM_SERVICESETTINGS_MAXIMUMLOGINATTEMPTS` | *int |  |
| `MM_SERVICESETTINGS_GOROUTINEHEALTHTHRESHOLD` | *int |  |
| `MM_SERVICESETTINGS_ENABLEOAUTHSERVICEPROVIDER` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEDYNAMICCLIENTREGISTRATION` | *bool |  |
| `MM_SERVICESETTINGS_DCRREDIRECTURIALLOWLIST` | []string |  |
| `MM_SERVICESETTINGS_ENABLEINCOMINGWEBHOOKS` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEOUTGOINGWEBHOOKS` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEOUTGOINGOAUTHCONNECTIONS` | *bool |  |
| `MM_SERVICESETTINGS_ENABLECOMMANDS` | *bool |  |
| `MM_SERVICESETTINGS_OUTGOINGINTEGRATIONREQUESTSTIMEOUT` | *int64 |  |
| `MM_SERVICESETTINGS_ENABLEPOSTUSERNAMEOVERRIDE` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEPOSTICONOVERRIDE` | *bool |  |
| `MM_SERVICESETTINGS_GOOGLEDEVELOPERKEY` | *string |  |
| `MM_SERVICESETTINGS_ENABLELINKPREVIEWS` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEPERMALINKPREVIEWS` | *bool |  |
| `MM_SERVICESETTINGS_RESTRICTLINKPREVIEWS` | *string |  |
| `MM_SERVICESETTINGS_ENABLETESTING` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEDEVELOPER` | *bool |  |
| `MM_SERVICESETTINGS_DEVELOPERFLAGS` | *string |  |
| `MM_SERVICESETTINGS_ENABLECLIENTPERFORMANCEDEBUGGING` | *bool |  |
| `MM_SERVICESETTINGS_ENABLESECURITYFIXALERT` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEINSECUREOUTGOINGCONNECTIONS` | *bool |  |
| `MM_SERVICESETTINGS_ALLOWEDUNTRUSTEDINTERNALCONNECTIONS` | *string |  |
| `MM_SERVICESETTINGS_ENABLEMULTIFACTORAUTHENTICATION` | *bool |  |
| `MM_SERVICESETTINGS_ENFORCEMULTIFACTORAUTHENTICATION` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEUSERACCESSTOKENS` | *bool |  |
| `MM_SERVICESETTINGS_MAXIMUMPERSONALACCESSTOKENLIFETIMEDAYS` | *int |  |
| `MM_SERVICESETTINGS_ALLOWCORSFROM` | *string |  |
| `MM_SERVICESETTINGS_CORSEXPOSEDHEADERS` | *string |  |
| `MM_SERVICESETTINGS_CORSALLOWCREDENTIALS` | *bool |  |
| `MM_SERVICESETTINGS_CORSDEBUG` | *bool |  |
| `MM_SERVICESETTINGS_ALLOWCOOKIESFORSUBDOMAINS` | *bool |  |
| `MM_SERVICESETTINGS_EXTENDSESSIONLENGTHWITHACTIVITY` | *bool |  |
| `MM_SERVICESETTINGS_TERMINATESESSIONSONPASSWORDCHANGE` | *bool |  |
| `MM_SERVICESETTINGS_SESSIONLENGTHWEBINDAYS` | *int |  |
| `MM_SERVICESETTINGS_SESSIONLENGTHWEBINHOURS` | *int |  |
| `MM_SERVICESETTINGS_SESSIONLENGTHMOBILEINDAYS` | *int |  |
| `MM_SERVICESETTINGS_SESSIONLENGTHMOBILEINHOURS` | *int |  |
| `MM_SERVICESETTINGS_SESSIONLENGTHSSOINDAYS` | *int |  |
| `MM_SERVICESETTINGS_SESSIONLENGTHSSOINHOURS` | *int |  |
| `MM_SERVICESETTINGS_SESSIONCACHEINMINUTES` | *int |  |
| `MM_SERVICESETTINGS_SESSIONIDLETIMEOUTINMINUTES` | *int |  |
| `MM_SERVICESETTINGS_WEBSOCKETSECUREPORT` | *int |  |
| `MM_SERVICESETTINGS_WEBSOCKETPORT` | *int |  |
| `MM_SERVICESETTINGS_WEBSERVERMODE` | *string |  |
| `MM_SERVICESETTINGS_ENABLEGIFPICKER` | *bool |  |
| `MM_SERVICESETTINGS_GIPHYSDKKEY` | *string |  |
| `MM_SERVICESETTINGS_ENABLECUSTOMEMOJI` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEEMOJIPICKER` | *bool |  |
| `MM_SERVICESETTINGS_POSTEDITTIMELIMIT` | *int |  |
| `MM_SERVICESETTINGS_TIMEBETWEENUSERTYPINGUPDATESMILLISECONDS` | *int64 |  |
| `MM_SERVICESETTINGS_ENABLECROSSTEAMSEARCH` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEPOSTSEARCH` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEFILESEARCH` | *bool |  |
| `MM_SERVICESETTINGS_MINIMUMHASHTAGLENGTH` | *int |  |
| `MM_SERVICESETTINGS_ENABLEUSERTYPINGMESSAGES` | *bool |  |
| `MM_SERVICESETTINGS_ENABLECHANNELVIEWEDMESSAGES` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEUSERSTATUSES` | *bool |  |
| `MM_SERVICESETTINGS_EXPERIMENTALENABLEAUTHENTICATIONTRANSFER` | *bool |  |
| `MM_SERVICESETTINGS_CLUSTERLOGTIMEOUTMILLISECONDS` | *int |  |
| `MM_SERVICESETTINGS_ENABLETUTORIAL` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEONBOARDINGFLOW` | *bool |  |
| `MM_SERVICESETTINGS_EXPERIMENTALENABLEDEFAULTCHANNELLEAVEJOINMESSAGES` | *bool |  |
| `MM_SERVICESETTINGS_EXPERIMENTALGROUPUNREADCHANNELS` | *string |  |
| `MM_SERVICESETTINGS_ENABLEAPITEAMDELETION` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEAPITRIGGERADMINNOTIFICATIONS` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEAPIUSERDELETION` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEAPIPOSTDELETION` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEDESKTOPLANDINGPAGE` | *bool |  |
| `MM_SERVICESETTINGS_MINIMUMDESKTOPAPPVERSION` | *string |  |
| `MM_SERVICESETTINGS_EXPERIMENTALENABLEHARDENEDMODE` | *bool |  |
| `MM_SERVICESETTINGS_EXPERIMENTALSTRICTCSRFENFORCEMENT` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEEMAILINVITATIONS` | *bool |  |
| `MM_SERVICESETTINGS_DISABLEBOTSWHENOWNERISDEACTIVATED` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEBOTACCOUNTCREATION` | *bool |  |
| `MM_SERVICESETTINGS_ENABLESVGS` | *bool |  |
| `MM_SERVICESETTINGS_ENABLELATEX` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEINLINELATEX` | *bool |  |
| `MM_SERVICESETTINGS_POSTPRIORITY` | *bool |  |
| `MM_SERVICESETTINGS_ALLOWPERSISTENTNOTIFICATIONS` | *bool |  |
| `MM_SERVICESETTINGS_ALLOWPERSISTENTNOTIFICATIONSFORGUESTS` | *bool |  |
| `MM_SERVICESETTINGS_PERSISTENTNOTIFICATIONINTERVALMINUTES` | *int |  |
| `MM_SERVICESETTINGS_PERSISTENTNOTIFICATIONMAXCOUNT` | *int |  |
| `MM_SERVICESETTINGS_PERSISTENTNOTIFICATIONMAXRECIPIENTS` | *int |  |
| `MM_SERVICESETTINGS_ENABLEBURNONREAD` | *bool |  |
| `MM_SERVICESETTINGS_BURNONREADDURATIONSECONDS` | *int |  |
| `MM_SERVICESETTINGS_BURNONREADMAXIMUMTIMETOLIVESECONDS` | *int |  |
| `MM_SERVICESETTINGS_BURNONREADSCHEDULERFREQUENCYSECONDS` | *int |  |
| `MM_SERVICESETTINGS_ENABLEAPICHANNELDELETION` | *bool |  |
| `MM_SERVICESETTINGS_ENABLELOCALMODE` | *bool |  |
| `MM_SERVICESETTINGS_LOCALMODESOCKETLOCATION` | *string |  |
| `MM_SERVICESETTINGS_ENABLEAWSMETERING` | *bool |  |
| `MM_SERVICESETTINGS_AWSMETERINGTIMEOUTSECONDS` | *int |  |
| `MM_SERVICESETTINGS_SPLITKEY` | *string |  |
| `MM_SERVICESETTINGS_FEATUREFLAGSYNCINTERVALSECONDS` | *int |  |
| `MM_SERVICESETTINGS_DEBUGSPLIT` | *bool |  |
| `MM_SERVICESETTINGS_THREADAUTOFOLLOW` | *bool |  |
| `MM_SERVICESETTINGS_COLLAPSEDTHREADS` | *string |  |
| `MM_SERVICESETTINGS_MANAGEDRESOURCEPATHS` | *string |  |
| `MM_SERVICESETTINGS_ENABLECUSTOMGROUPS` | *bool |  |
| `MM_SERVICESETTINGS_ALLOWSYNCEDDRAFTS` | *bool |  |
| `MM_SERVICESETTINGS_UNIQUEEMOJIREACTIONLIMITPERPOST` | *int |  |
| `MM_SERVICESETTINGS_REFRESHPOSTSTATSRUNTIME` | *string |  |
| `MM_SERVICESETTINGS_MAXIMUMPAYLOADSIZEBYTES` | *int64 |  |
| `MM_SERVICESETTINGS_MAXIMUMURLLENGTH` | *int |  |
| `MM_SERVICESETTINGS_SCHEDULEDPOSTS` | *bool |  |
| `MM_SERVICESETTINGS_ENABLEWEBHUBCHANNELITERATION` | *bool |  |
| `MM_SERVICESETTINGS_FRAMEANCESTORS` | *string |  |
| `MM_SERVICESETTINGS_DELETEACCOUNTLINK` | *string |  |

## MM_TEAMSETTINGS  (`TeamSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_TEAMSETTINGS_SITENAME` | *string |  |
| `MM_TEAMSETTINGS_MAXUSERSPERTEAM` | *int |  |
| `MM_TEAMSETTINGS_ENABLEJOINLEAVEMESSAGEBYDEFAULT` | *bool |  |
| `MM_TEAMSETTINGS_ENABLEUSERCREATION` | *bool |  |
| `MM_TEAMSETTINGS_ENABLEOPENSERVER` | *bool |  |
| `MM_TEAMSETTINGS_ENABLEUSERDEACTIVATION` | *bool |  |
| `MM_TEAMSETTINGS_RESTRICTCREATIONTODOMAINS` | *string |  |
| `MM_TEAMSETTINGS_ENABLECUSTOMUSERSTATUSES` | *bool |  |
| `MM_TEAMSETTINGS_ENABLECUSTOMBRAND` | *bool |  |
| `MM_TEAMSETTINGS_CUSTOMBRANDTEXT` | *string |  |
| `MM_TEAMSETTINGS_CUSTOMDESCRIPTIONTEXT` | *string |  |
| `MM_TEAMSETTINGS_RESTRICTDIRECTMESSAGE` | *string |  |
| `MM_TEAMSETTINGS_ENABLELASTACTIVETIME` | *bool |  |
| `MM_TEAMSETTINGS_USERSTATUSAWAYTIMEOUT` | *int64 |  |
| `MM_TEAMSETTINGS_MAXCHANNELSPERTEAM` | *int64 |  |
| `MM_TEAMSETTINGS_ENABLECHANNELCATEGORYSORTING` | *bool |  |
| `MM_TEAMSETTINGS_MAXNOTIFICATIONSPERCHANNEL` | *int64 |  |
| `MM_TEAMSETTINGS_ENABLECONFIRMNOTIFICATIONSTOCHANNEL` | *bool |  |
| `MM_TEAMSETTINGS_TEAMMATENAMEDISPLAY` | *string |  |
| `MM_TEAMSETTINGS_EXPERIMENTALVIEWARCHIVEDCHANNELS` | *bool |  |
| `MM_TEAMSETTINGS_EXPERIMENTALENABLEAUTOMATICREPLIES` | *bool |  |
| `MM_TEAMSETTINGS_LOCKTEAMMATENAMEDISPLAY` | *bool |  |
| `MM_TEAMSETTINGS_EXPERIMENTALPRIMARYTEAM` | *string |  |
| `MM_TEAMSETTINGS_EXPERIMENTALDEFAULTCHANNELS` | []string |  |

## MM_CLIENTREQUIREMENTS  (`ClientRequirements`)

| Env var | Go type | json key |
|---|---|---|
| `MM_CLIENTREQUIREMENTS_ANDROIDLATESTVERSION` | string |  |
| `MM_CLIENTREQUIREMENTS_ANDROIDMINVERSION` | string |  |
| `MM_CLIENTREQUIREMENTS_IOSLATESTVERSION` | string |  |
| `MM_CLIENTREQUIREMENTS_IOSMINVERSION` | string |  |

## MM_SQLSETTINGS  (`SqlSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_SQLSETTINGS_DRIVERNAME` | *string |  |
| `MM_SQLSETTINGS_DATASOURCE` | *string |  |
| `MM_SQLSETTINGS_DATASOURCEREPLICAS` | []string |  |
| `MM_SQLSETTINGS_DATASOURCESEARCHREPLICAS` | []string |  |
| `MM_SQLSETTINGS_MAXIDLECONNS` | *int |  |
| `MM_SQLSETTINGS_CONNMAXLIFETIMEMILLISECONDS` | *int |  |
| `MM_SQLSETTINGS_CONNMAXIDLETIMEMILLISECONDS` | *int |  |
| `MM_SQLSETTINGS_MAXOPENCONNS` | *int |  |
| `MM_SQLSETTINGS_TRACE` | *bool |  |
| `MM_SQLSETTINGS_ATRESTENCRYPTKEY` | *string |  |
| `MM_SQLSETTINGS_QUERYTIMEOUT` | *int |  |
| `MM_SQLSETTINGS_ANALYTICSQUERYTIMEOUT` | *int |  |
| `MM_SQLSETTINGS_DISABLEDATABASESEARCH` | *bool |  |
| `MM_SQLSETTINGS_MIGRATIONSSTATEMENTTIMEOUTSECONDS` | *int |  |
| `MM_SQLSETTINGS_REPLICALAGSETTINGS` | [] |  |
| `MM_SQLSETTINGS_REPLICAMONITORINTERVALSECONDS` | *int |  |

## MM_LOGSETTINGS  (`LogSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_LOGSETTINGS_ENABLECONSOLE` | *bool |  |
| `MM_LOGSETTINGS_CONSOLELEVEL` | *string |  |
| `MM_LOGSETTINGS_CONSOLEJSON` | *bool |  |
| `MM_LOGSETTINGS_ENABLECOLOR` | *bool |  |
| `MM_LOGSETTINGS_ENABLEFILE` | *bool |  |
| `MM_LOGSETTINGS_FILELEVEL` | *string |  |
| `MM_LOGSETTINGS_FILEJSON` | *bool |  |
| `MM_LOGSETTINGS_FILELOCATION` | *string |  |
| `MM_LOGSETTINGS_ENABLEWEBHOOKDEBUGGING` | *bool |  |
| `MM_LOGSETTINGS_ENABLEDIAGNOSTICS` | *bool |  |
| `MM_LOGSETTINGS_ENABLESENTRY` | *bool |  |
| `MM_LOGSETTINGS_ADVANCEDLOGGINGJSON` | json.RawMessage |  |
| `MM_LOGSETTINGS_MAXFIELDSIZE` | *int |  |

## MM_EXPERIMENTALAUDITSETTINGS  (`ExperimentalAuditSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_EXPERIMENTALAUDITSETTINGS_FILEENABLED` | *bool |  |
| `MM_EXPERIMENTALAUDITSETTINGS_FILENAME` | *string |  |
| `MM_EXPERIMENTALAUDITSETTINGS_ADVANCEDLOGGINGJSON` | json.RawMessage |  |
| `MM_EXPERIMENTALAUDITSETTINGS_CERTIFICATE` | *string |  |

## MM_PASSWORDSETTINGS  (`PasswordSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_PASSWORDSETTINGS_MINIMUMLENGTH` | *int |  |
| `MM_PASSWORDSETTINGS_LOWERCASE` | *bool |  |
| `MM_PASSWORDSETTINGS_NUMBER` | *bool |  |
| `MM_PASSWORDSETTINGS_UPPERCASE` | *bool |  |
| `MM_PASSWORDSETTINGS_SYMBOL` | *bool |  |
| `MM_PASSWORDSETTINGS_ENABLEFORGOTLINK` | *bool |  |

## MM_FILESETTINGS  (`FileSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_FILESETTINGS_ENABLEFILEATTACHMENTS` | *bool |  |
| `MM_FILESETTINGS_ENABLEMOBILEUPLOAD` | *bool |  |
| `MM_FILESETTINGS_ENABLEMOBILEDOWNLOAD` | *bool |  |
| `MM_FILESETTINGS_MAXFILESIZE` | *int64 |  |
| `MM_FILESETTINGS_MAXIMAGERESOLUTION` | *int64 |  |
| `MM_FILESETTINGS_MAXIMAGEDECODERCONCURRENCY` | *int64 |  |
| `MM_FILESETTINGS_DRIVERNAME` | *string |  |
| `MM_FILESETTINGS_DIRECTORY` | *string |  |
| `MM_FILESETTINGS_ENABLEPUBLICLINK` | *bool |  |
| `MM_FILESETTINGS_EXTRACTCONTENT` | *bool |  |
| `MM_FILESETTINGS_EXTRACTCONTENTTIMEOUT` | *int |  |
| `MM_FILESETTINGS_ARCHIVERECURSION` | *bool |  |
| `MM_FILESETTINGS_PUBLICLINKSALT` | *string |  |
| `MM_FILESETTINGS_INITIALFONT` | *string |  |
| `MM_FILESETTINGS_AMAZONS3ACCESSKEYID` | *string |  |
| `MM_FILESETTINGS_AMAZONS3SECRETACCESSKEY` | *string |  |
| `MM_FILESETTINGS_AMAZONS3BUCKET` | *string |  |
| `MM_FILESETTINGS_AMAZONS3PATHPREFIX` | *string |  |
| `MM_FILESETTINGS_AMAZONS3REGION` | *string |  |
| `MM_FILESETTINGS_AMAZONS3ENDPOINT` | *string |  |
| `MM_FILESETTINGS_AMAZONS3SSL` | *bool |  |
| `MM_FILESETTINGS_AMAZONS3SIGNV2` | *bool |  |
| `MM_FILESETTINGS_AMAZONS3SSE` | *bool |  |
| `MM_FILESETTINGS_AMAZONS3TRACE` | *bool |  |
| `MM_FILESETTINGS_AMAZONS3REQUESTTIMEOUTMILLISECONDS` | *int64 |  |
| `MM_FILESETTINGS_AMAZONS3UPLOADPARTSIZEBYTES` | *int64 |  |
| `MM_FILESETTINGS_AMAZONS3STORAGECLASS` | *string |  |
| `MM_FILESETTINGS_AZURESTORAGEACCOUNT` | *string |  |
| `MM_FILESETTINGS_AZUREAUTHMODE` | *string |  |
| `MM_FILESETTINGS_AZUREACCESSKEY` | *string |  |
| `MM_FILESETTINGS_AZURECONTAINER` | *string |  |
| `MM_FILESETTINGS_AZUREPATHPREFIX` | *string |  |
| `MM_FILESETTINGS_AZURECLOUD` | *string |  |
| `MM_FILESETTINGS_AZUREENDPOINT` | *string |  |
| `MM_FILESETTINGS_AZURESSL` | *bool |  |
| `MM_FILESETTINGS_AZUREREQUESTTIMEOUTMILLISECONDS` | *int64 |  |
| `MM_FILESETTINGS_DEDICATEDEXPORTSTORE` | *bool |  |
| `MM_FILESETTINGS_EXPORTDRIVERNAME` | *string |  |
| `MM_FILESETTINGS_EXPORTDIRECTORY` | *string |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3ACCESSKEYID` | *string |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3SECRETACCESSKEY` | *string |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3BUCKET` | *string |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3PATHPREFIX` | *string |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3REGION` | *string |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3ENDPOINT` | *string |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3SSL` | *bool |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3SIGNV2` | *bool |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3SSE` | *bool |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3TRACE` | *bool |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3REQUESTTIMEOUTMILLISECONDS` | *int64 |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3PRESIGNEXPIRESSECONDS` | *int64 |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3UPLOADPARTSIZEBYTES` | *int64 |  |
| `MM_FILESETTINGS_EXPORTAMAZONS3STORAGECLASS` | *string |  |
| `MM_FILESETTINGS_EXPORTAZURESTORAGEACCOUNT` | *string |  |
| `MM_FILESETTINGS_EXPORTAZUREAUTHMODE` | *string |  |
| `MM_FILESETTINGS_EXPORTAZUREACCESSKEY` | *string |  |
| `MM_FILESETTINGS_EXPORTAZURECONTAINER` | *string |  |
| `MM_FILESETTINGS_EXPORTAZUREPATHPREFIX` | *string |  |
| `MM_FILESETTINGS_EXPORTAZURECLOUD` | *string |  |
| `MM_FILESETTINGS_EXPORTAZUREENDPOINT` | *string |  |
| `MM_FILESETTINGS_EXPORTAZURESSL` | *bool |  |
| `MM_FILESETTINGS_EXPORTAZUREREQUESTTIMEOUTMILLISECONDS` | *int64 |  |
| `MM_FILESETTINGS_EXPORTAZUREPRESIGNEXPIRESSECONDS` | *int64 |  |

## MM_EMAILSETTINGS  (`EmailSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_EMAILSETTINGS_ENABLESIGNUPWITHEMAIL` | *bool |  |
| `MM_EMAILSETTINGS_ENABLESIGNINWITHEMAIL` | *bool |  |
| `MM_EMAILSETTINGS_ENABLESIGNINWITHUSERNAME` | *bool |  |
| `MM_EMAILSETTINGS_SENDEMAILNOTIFICATIONS` | *bool |  |
| `MM_EMAILSETTINGS_USECHANNELINEMAILNOTIFICATIONS` | *bool |  |
| `MM_EMAILSETTINGS_REQUIREEMAILVERIFICATION` | *bool |  |
| `MM_EMAILSETTINGS_FEEDBACKNAME` | *string |  |
| `MM_EMAILSETTINGS_FEEDBACKEMAIL` | *string |  |
| `MM_EMAILSETTINGS_REPLYTOADDRESS` | *string |  |
| `MM_EMAILSETTINGS_FEEDBACKORGANIZATION` | *string |  |
| `MM_EMAILSETTINGS_ENABLESMTPAUTH` | *bool |  |
| `MM_EMAILSETTINGS_SMTPUSERNAME` | *string |  |
| `MM_EMAILSETTINGS_SMTPPASSWORD` | *string |  |
| `MM_EMAILSETTINGS_SMTPSERVER` | *string |  |
| `MM_EMAILSETTINGS_SMTPPORT` | *string |  |
| `MM_EMAILSETTINGS_SMTPSERVERTIMEOUT` | *int |  |
| `MM_EMAILSETTINGS_CONNECTIONSECURITY` | *string |  |
| `MM_EMAILSETTINGS_SENDPUSHNOTIFICATIONS` | *bool |  |
| `MM_EMAILSETTINGS_PUSHNOTIFICATIONSERVER` | *string |  |
| `MM_EMAILSETTINGS_PUSHNOTIFICATIONCONTENTS` | *string |  |
| `MM_EMAILSETTINGS_PUSHNOTIFICATIONBUFFER` | *int |  |
| `MM_EMAILSETTINGS_ENABLEEMAILBATCHING` | *bool |  |
| `MM_EMAILSETTINGS_EMAILBATCHINGBUFFERSIZE` | *int |  |
| `MM_EMAILSETTINGS_EMAILBATCHINGINTERVAL` | *int |  |
| `MM_EMAILSETTINGS_ENABLEPREVIEWMODEBANNER` | *bool |  |
| `MM_EMAILSETTINGS_SKIPSERVERCERTIFICATEVERIFICATION` | *bool |  |
| `MM_EMAILSETTINGS_EMAILNOTIFICATIONCONTENTSTYPE` | *string |  |
| `MM_EMAILSETTINGS_LOGINBUTTONCOLOR` | *string |  |
| `MM_EMAILSETTINGS_LOGINBUTTONBORDERCOLOR` | *string |  |
| `MM_EMAILSETTINGS_LOGINBUTTONTEXTCOLOR` | *string |  |

## MM_RATELIMITSETTINGS  (`RateLimitSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_RATELIMITSETTINGS_ENABLE` | *bool |  |
| `MM_RATELIMITSETTINGS_PERSEC` | *int |  |
| `MM_RATELIMITSETTINGS_MAXBURST` | *int |  |
| `MM_RATELIMITSETTINGS_MEMORYSTORESIZE` | *int |  |
| `MM_RATELIMITSETTINGS_VARYBYREMOTEADDR` | *bool |  |
| `MM_RATELIMITSETTINGS_VARYBYUSER` | *bool |  |
| `MM_RATELIMITSETTINGS_VARYBYHEADER` | string |  |

## MM_PRIVACYSETTINGS  (`PrivacySettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_PRIVACYSETTINGS_SHOWEMAILADDRESS` | *bool |  |
| `MM_PRIVACYSETTINGS_SHOWFULLNAME` | *bool |  |
| `MM_PRIVACYSETTINGS_USEANONYMOUSURLS` | *bool |  |

## MM_SUPPORTSETTINGS  (`SupportSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_SUPPORTSETTINGS_TERMSOFSERVICELINK` | *string |  |
| `MM_SUPPORTSETTINGS_PRIVACYPOLICYLINK` | *string |  |
| `MM_SUPPORTSETTINGS_ABOUTLINK` | *string |  |
| `MM_SUPPORTSETTINGS_HELPLINK` | *string |  |
| `MM_SUPPORTSETTINGS_REPORTAPROBLEMLINK` | *string |  |
| `MM_SUPPORTSETTINGS_REPORTAPROBLEMTYPE` | *string |  |
| `MM_SUPPORTSETTINGS_REPORTAPROBLEMMAIL` | *string |  |
| `MM_SUPPORTSETTINGS_ALLOWDOWNLOADLOGS` | *bool |  |
| `MM_SUPPORTSETTINGS_FORGOTPASSWORDLINK` | *string |  |
| `MM_SUPPORTSETTINGS_SUPPORTEMAIL` | *string |  |
| `MM_SUPPORTSETTINGS_CUSTOMTERMSOFSERVICEENABLED` | *bool |  |
| `MM_SUPPORTSETTINGS_CUSTOMTERMSOFSERVICEREACCEPTANCEPERIOD` | *int |  |
| `MM_SUPPORTSETTINGS_ENABLEASKCOMMUNITYLINK` | *bool |  |

## MM_ANNOUNCEMENTSETTINGS  (`AnnouncementSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_ANNOUNCEMENTSETTINGS_ENABLEBANNER` | *bool |  |
| `MM_ANNOUNCEMENTSETTINGS_BANNERTEXT` | *string |  |
| `MM_ANNOUNCEMENTSETTINGS_BANNERCOLOR` | *string |  |
| `MM_ANNOUNCEMENTSETTINGS_BANNERTEXTCOLOR` | *string |  |
| `MM_ANNOUNCEMENTSETTINGS_ALLOWBANNERDISMISSAL` | *bool |  |
| `MM_ANNOUNCEMENTSETTINGS_ADMINNOTICESENABLED` | *bool |  |
| `MM_ANNOUNCEMENTSETTINGS_USERNOTICESENABLED` | *bool |  |
| `MM_ANNOUNCEMENTSETTINGS_NOTICESURL` | *string |  |
| `MM_ANNOUNCEMENTSETTINGS_NOTICESFETCHFREQUENCY` | *int |  |
| `MM_ANNOUNCEMENTSETTINGS_NOTICESSKIPCACHE` | *bool |  |

## MM_THEMESETTINGS  (`ThemeSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_THEMESETTINGS_ENABLETHEMESELECTION` | *bool |  |
| `MM_THEMESETTINGS_DEFAULTTHEME` | *string |  |
| `MM_THEMESETTINGS_ALLOWCUSTOMTHEMES` | *bool |  |
| `MM_THEMESETTINGS_ALLOWEDTHEMES` | []string |  |

## MM_GITLABSETTINGS  (`SSOSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_GITLABSETTINGS_ENABLE` | *bool |  |
| `MM_GITLABSETTINGS_SECRET` | *string |  |
| `MM_GITLABSETTINGS_ID` | *string |  |
| `MM_GITLABSETTINGS_SCOPE` | *string |  |
| `MM_GITLABSETTINGS_AUTHENDPOINT` | *string |  |
| `MM_GITLABSETTINGS_TOKENENDPOINT` | *string |  |
| `MM_GITLABSETTINGS_USERAPIENDPOINT` | *string |  |
| `MM_GITLABSETTINGS_DISCOVERYENDPOINT` | *string |  |
| `MM_GITLABSETTINGS_BUTTONTEXT` | *string |  |
| `MM_GITLABSETTINGS_BUTTONCOLOR` | *string |  |
| `MM_GITLABSETTINGS_USEPREFERREDUSERNAME` | *bool |  |

## MM_GOOGLESETTINGS  (`SSOSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_GOOGLESETTINGS_ENABLE` | *bool |  |
| `MM_GOOGLESETTINGS_SECRET` | *string |  |
| `MM_GOOGLESETTINGS_ID` | *string |  |
| `MM_GOOGLESETTINGS_SCOPE` | *string |  |
| `MM_GOOGLESETTINGS_AUTHENDPOINT` | *string |  |
| `MM_GOOGLESETTINGS_TOKENENDPOINT` | *string |  |
| `MM_GOOGLESETTINGS_USERAPIENDPOINT` | *string |  |
| `MM_GOOGLESETTINGS_DISCOVERYENDPOINT` | *string |  |
| `MM_GOOGLESETTINGS_BUTTONTEXT` | *string |  |
| `MM_GOOGLESETTINGS_BUTTONCOLOR` | *string |  |
| `MM_GOOGLESETTINGS_USEPREFERREDUSERNAME` | *bool |  |

## MM_OFFICE365SETTINGS  (`Office365Settings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_OFFICE365SETTINGS_ENABLE` | *bool |  |
| `MM_OFFICE365SETTINGS_SECRET` | *string |  |
| `MM_OFFICE365SETTINGS_ID` | *string |  |
| `MM_OFFICE365SETTINGS_SCOPE` | *string |  |
| `MM_OFFICE365SETTINGS_AUTHENDPOINT` | *string |  |
| `MM_OFFICE365SETTINGS_TOKENENDPOINT` | *string |  |
| `MM_OFFICE365SETTINGS_USERAPIENDPOINT` | *string |  |
| `MM_OFFICE365SETTINGS_DISCOVERYENDPOINT` | *string |  |
| `MM_OFFICE365SETTINGS_DIRECTORYID` | *string |  |
| `MM_OFFICE365SETTINGS_USEPREFERREDUSERNAME` | *bool |  |

## MM_OPENIDSETTINGS  (`SSOSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_OPENIDSETTINGS_ENABLE` | *bool |  |
| `MM_OPENIDSETTINGS_SECRET` | *string |  |
| `MM_OPENIDSETTINGS_ID` | *string |  |
| `MM_OPENIDSETTINGS_SCOPE` | *string |  |
| `MM_OPENIDSETTINGS_AUTHENDPOINT` | *string |  |
| `MM_OPENIDSETTINGS_TOKENENDPOINT` | *string |  |
| `MM_OPENIDSETTINGS_USERAPIENDPOINT` | *string |  |
| `MM_OPENIDSETTINGS_DISCOVERYENDPOINT` | *string |  |
| `MM_OPENIDSETTINGS_BUTTONTEXT` | *string |  |
| `MM_OPENIDSETTINGS_BUTTONCOLOR` | *string |  |
| `MM_OPENIDSETTINGS_USEPREFERREDUSERNAME` | *bool |  |

## MM_LDAPSETTINGS  (`LdapSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_LDAPSETTINGS_ENABLE` | *bool |  |
| `MM_LDAPSETTINGS_ENABLESYNC` | *bool |  |
| `MM_LDAPSETTINGS_LDAPSERVER` | *string |  |
| `MM_LDAPSETTINGS_LDAPPORT` | *int |  |
| `MM_LDAPSETTINGS_CONNECTIONSECURITY` | *string |  |
| `MM_LDAPSETTINGS_BASEDN` | *string |  |
| `MM_LDAPSETTINGS_BINDUSERNAME` | *string |  |
| `MM_LDAPSETTINGS_BINDPASSWORD` | *string |  |
| `MM_LDAPSETTINGS_MAXIMUMLOGINATTEMPTS` | *int |  |
| `MM_LDAPSETTINGS_USERFILTER` | *string |  |
| `MM_LDAPSETTINGS_GROUPFILTER` | *string |  |
| `MM_LDAPSETTINGS_GUESTFILTER` | *string |  |
| `MM_LDAPSETTINGS_ENABLEADMINFILTER` | *bool |  |
| `MM_LDAPSETTINGS_ADMINFILTER` | *string |  |
| `MM_LDAPSETTINGS_GROUPDISPLAYNAMEATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_GROUPIDATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_FIRSTNAMEATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_LASTNAMEATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_EMAILATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_USERNAMEATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_NICKNAMEATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_IDATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_POSITIONATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_LOGINIDATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_PICTUREATTRIBUTE` | *string |  |
| `MM_LDAPSETTINGS_SYNCINTERVALMINUTES` | *int |  |
| `MM_LDAPSETTINGS_READDREMOVEDMEMBERS` | *bool |  |
| `MM_LDAPSETTINGS_SKIPCERTIFICATEVERIFICATION` | *bool |  |
| `MM_LDAPSETTINGS_PUBLICCERTIFICATEFILE` | *string |  |
| `MM_LDAPSETTINGS_PRIVATEKEYFILE` | *string |  |
| `MM_LDAPSETTINGS_QUERYTIMEOUT` | *int |  |
| `MM_LDAPSETTINGS_MAXPAGESIZE` | *int |  |
| `MM_LDAPSETTINGS_LOGINFIELDNAME` | *string |  |
| `MM_LDAPSETTINGS_LOGINBUTTONCOLOR` | *string |  |
| `MM_LDAPSETTINGS_LOGINBUTTONBORDERCOLOR` | *string |  |
| `MM_LDAPSETTINGS_LOGINBUTTONTEXTCOLOR` | *string |  |

## MM_COMPLIANCESETTINGS  (`ComplianceSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_COMPLIANCESETTINGS_ENABLE` | *bool |  |
| `MM_COMPLIANCESETTINGS_DIRECTORY` | *string |  |
| `MM_COMPLIANCESETTINGS_ENABLEDAILY` | *bool |  |
| `MM_COMPLIANCESETTINGS_BATCHSIZE` | *int |  |

## MM_LOCALIZATIONSETTINGS  (`LocalizationSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_LOCALIZATIONSETTINGS_DEFAULTSERVERLOCALE` | *string |  |
| `MM_LOCALIZATIONSETTINGS_DEFAULTCLIENTLOCALE` | *string |  |
| `MM_LOCALIZATIONSETTINGS_AVAILABLELOCALES` | *string |  |
| `MM_LOCALIZATIONSETTINGS_ENABLEEXPERIMENTALLOCALES` | *bool |  |

## MM_SAMLSETTINGS  (`SamlSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_SAMLSETTINGS_ENABLE` | *bool |  |
| `MM_SAMLSETTINGS_ENABLESYNCWITHLDAP` | *bool |  |
| `MM_SAMLSETTINGS_ENABLESYNCWITHLDAPINCLUDEAUTH` | *bool |  |
| `MM_SAMLSETTINGS_IGNOREGUESTSLDAPSYNC` | *bool |  |
| `MM_SAMLSETTINGS_VERIFY` | *bool |  |
| `MM_SAMLSETTINGS_ENCRYPT` | *bool |  |
| `MM_SAMLSETTINGS_SIGNREQUEST` | *bool |  |
| `MM_SAMLSETTINGS_IDPURL` | *string |  |
| `MM_SAMLSETTINGS_IDPDESCRIPTORURL` | *string |  |
| `MM_SAMLSETTINGS_IDPMETADATAURL` | *string |  |
| `MM_SAMLSETTINGS_SERVICEPROVIDERIDENTIFIER` | *string |  |
| `MM_SAMLSETTINGS_ASSERTIONCONSUMERSERVICEURL` | *string |  |
| `MM_SAMLSETTINGS_SIGNATUREALGORITHM` | *string |  |
| `MM_SAMLSETTINGS_CANONICALALGORITHM` | *string |  |
| `MM_SAMLSETTINGS_SCOPINGIDPPROVIDERID` | *string |  |
| `MM_SAMLSETTINGS_SCOPINGIDPNAME` | *string |  |
| `MM_SAMLSETTINGS_IDPCERTIFICATEFILE` | *string |  |
| `MM_SAMLSETTINGS_PUBLICCERTIFICATEFILE` | *string |  |
| `MM_SAMLSETTINGS_PRIVATEKEYFILE` | *string |  |
| `MM_SAMLSETTINGS_IDATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_GUESTATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_ENABLEADMINATTRIBUTE` | *bool |  |
| `MM_SAMLSETTINGS_ADMINATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_FIRSTNAMEATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_LASTNAMEATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_EMAILATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_USERNAMEATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_NICKNAMEATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_LOCALEATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_POSITIONATTRIBUTE` | *string |  |
| `MM_SAMLSETTINGS_LOGINBUTTONTEXT` | *string |  |
| `MM_SAMLSETTINGS_LOGINBUTTONCOLOR` | *string |  |
| `MM_SAMLSETTINGS_LOGINBUTTONBORDERCOLOR` | *string |  |
| `MM_SAMLSETTINGS_LOGINBUTTONTEXTCOLOR` | *string |  |

## MM_NATIVEAPPSETTINGS  (`NativeAppSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_NATIVEAPPSETTINGS_APPCUSTOMURLSCHEMES` | []string |  |
| `MM_NATIVEAPPSETTINGS_APPDOWNLOADLINK` | *string |  |
| `MM_NATIVEAPPSETTINGS_ANDROIDAPPDOWNLOADLINK` | *string |  |
| `MM_NATIVEAPPSETTINGS_IOSAPPDOWNLOADLINK` | *string |  |
| `MM_NATIVEAPPSETTINGS_MOBILEEXTERNALBROWSER` | *bool |  |
| `MM_NATIVEAPPSETTINGS_MOBILEENABLEBIOMETRICS` | *bool |  |
| `MM_NATIVEAPPSETTINGS_MOBILEPREVENTSCREENCAPTURE` | *bool |  |
| `MM_NATIVEAPPSETTINGS_MOBILEJAILBREAKPROTECTION` | *bool |  |
| `MM_NATIVEAPPSETTINGS_MOBILEENABLESECUREFILEPREVIEW` | *bool |  |
| `MM_NATIVEAPPSETTINGS_MOBILEALLOWPDFLINKNAVIGATION` | *bool |  |
| `MM_NATIVEAPPSETTINGS_ENABLEINTUNEMAM` | *bool |  |

## MM_INTUNESETTINGS  (`IntuneSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_INTUNESETTINGS_ENABLE` | *bool |  |
| `MM_INTUNESETTINGS_TENANTID` | *string |  |
| `MM_INTUNESETTINGS_CLIENTID` | *string |  |
| `MM_INTUNESETTINGS_AUTHSERVICE` | *string |  |

## MM_CACHESETTINGS  (`CacheSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_CACHESETTINGS_CACHETYPE` | *string |  |
| `MM_CACHESETTINGS_REDISADDRESS` | *string |  |
| `MM_CACHESETTINGS_REDISPASSWORD` | *string |  |
| `MM_CACHESETTINGS_REDISDB` | *int |  |
| `MM_CACHESETTINGS_REDISCACHEPREFIX` | *string |  |
| `MM_CACHESETTINGS_DISABLECLIENTCACHE` | *bool |  |

## MM_CLUSTERSETTINGS  (`ClusterSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_CLUSTERSETTINGS_ENABLE` | *bool |  |
| `MM_CLUSTERSETTINGS_CLUSTERNAME` | *string |  |
| `MM_CLUSTERSETTINGS_OVERRIDEHOSTNAME` | *string |  |
| `MM_CLUSTERSETTINGS_NETWORKINTERFACE` | *string |  |
| `MM_CLUSTERSETTINGS_BINDADDRESS` | *string |  |
| `MM_CLUSTERSETTINGS_ADVERTISEADDRESS` | *string |  |
| `MM_CLUSTERSETTINGS_USEIPADDRESS` | *bool |  |
| `MM_CLUSTERSETTINGS_ENABLEGOSSIPCOMPRESSION` | *bool |  |
| `MM_CLUSTERSETTINGS_ENABLEEXPERIMENTALGOSSIPENCRYPTION` | *bool |  |
| `MM_CLUSTERSETTINGS_ENABLEGOSSIPENCRYPTION` | *bool |  |
| `MM_CLUSTERSETTINGS_READONLYCONFIG` | *bool |  |
| `MM_CLUSTERSETTINGS_GOSSIPPORT` | *int |  |

## MM_METRICSSETTINGS  (`MetricsSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_METRICSSETTINGS_ENABLE` | *bool |  |
| `MM_METRICSSETTINGS_BLOCKPROFILERATE` | *int |  |
| `MM_METRICSSETTINGS_LISTENADDRESS` | *string |  |
| `MM_METRICSSETTINGS_ENABLECLIENTMETRICS` | *bool |  |
| `MM_METRICSSETTINGS_ENABLENOTIFICATIONMETRICS` | *bool |  |
| `MM_METRICSSETTINGS_CLIENTSIDEUSERIDS` | []string |  |

## MM_EXPERIMENTALSETTINGS  (`ExperimentalSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_EXPERIMENTALSETTINGS_CLIENTSIDECERTENABLE` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_LINKMETADATATIMEOUTMILLISECONDS` | *int64 |  |
| `MM_EXPERIMENTALSETTINGS_RESTRICTSYSTEMADMIN` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_ENABLESHAREDCHANNELS` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_ENABLEREMOTECLUSTERSERVICE` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_DISABLEAPPBAR` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_DISABLEREFETCHINGONBROWSERFOCUS` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_DELAYCHANNELAUTOCOMPLETE` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_DISABLEWAKEUPRECONNECTHANDLER` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_USERSSTATUSANDPROFILEFETCHINGPOLLINTERVALMILLISECONDS` | *int64 |  |
| `MM_EXPERIMENTALSETTINGS_YOUTUBEREFERRERPOLICY` | *bool |  |
| `MM_EXPERIMENTALSETTINGS_ENABLEWATERMARK` | *bool |  |

## MM_ANALYTICSSETTINGS  (`AnalyticsSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_ANALYTICSSETTINGS_MAXUSERSFORSTATISTICS` | *int |  |

## MM_ELASTICSEARCHSETTINGS  (`ElasticsearchSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_ELASTICSEARCHSETTINGS_CONNECTIONURL` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_BACKEND` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_USERNAME` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_PASSWORD` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_ENABLEINDEXING` | *bool |  |
| `MM_ELASTICSEARCHSETTINGS_ENABLESEARCHING` | *bool |  |
| `MM_ELASTICSEARCHSETTINGS_ENABLECJKANALYZERS` | *bool |  |
| `MM_ELASTICSEARCHSETTINGS_ENABLEAUTOCOMPLETE` | *bool |  |
| `MM_ELASTICSEARCHSETTINGS_SNIFF` | *bool |  |
| `MM_ELASTICSEARCHSETTINGS_POSTINDEXREPLICAS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_POSTINDEXSHARDS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_CHANNELINDEXREPLICAS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_CHANNELINDEXSHARDS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_USERINDEXREPLICAS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_USERINDEXSHARDS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_AGGREGATEPOSTSAFTERDAYS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_POSTSAGGREGATORJOBSTARTTIME` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_INDEXPREFIX` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_GLOBALSEARCHPREFIX` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_LIVEINDEXINGBATCHSIZE` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_BULKINDEXINGTIMEWINDOWSECONDS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_BATCHSIZE` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_REQUESTTIMEOUTSECONDS` | *int |  |
| `MM_ELASTICSEARCHSETTINGS_SKIPTLSVERIFICATION` | *bool |  |
| `MM_ELASTICSEARCHSETTINGS_CA` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_CLIENTCERT` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_CLIENTKEY` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_TRACE` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_IGNOREDPURGEINDEXES` | *string |  |
| `MM_ELASTICSEARCHSETTINGS_ENABLESEARCHPUBLICCHANNELSWITHOUTMEMBERSHIP` | *bool |  |

## MM_DATARETENTIONSETTINGS  (`DataRetentionSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_DATARETENTIONSETTINGS_ENABLEMESSAGEDELETION` | *bool |  |
| `MM_DATARETENTIONSETTINGS_ENABLEFILEDELETION` | *bool |  |
| `MM_DATARETENTIONSETTINGS_ENABLEBOARDSDELETION` | *bool |  |
| `MM_DATARETENTIONSETTINGS_MESSAGERETENTIONDAYS` | *int |  |
| `MM_DATARETENTIONSETTINGS_MESSAGERETENTIONHOURS` | *int |  |
| `MM_DATARETENTIONSETTINGS_FILERETENTIONDAYS` | *int |  |
| `MM_DATARETENTIONSETTINGS_FILERETENTIONHOURS` | *int |  |
| `MM_DATARETENTIONSETTINGS_BOARDSRETENTIONDAYS` | *int |  |
| `MM_DATARETENTIONSETTINGS_DELETIONJOBSTARTTIME` | *string |  |
| `MM_DATARETENTIONSETTINGS_BATCHSIZE` | *int |  |
| `MM_DATARETENTIONSETTINGS_TIMEBETWEENBATCHESMILLISECONDS` | *int |  |
| `MM_DATARETENTIONSETTINGS_RETENTIONIDSBATCHSIZE` | *int |  |
| `MM_DATARETENTIONSETTINGS_PRESERVEPINNEDPOSTS` | *bool |  |

## MM_MOBILEEPHEMERALMODESETTINGS  (`MobileEphemeralModeSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_MOBILEEPHEMERALMODESETTINGS_ENABLE` | *bool |  |
| `MM_MOBILEEPHEMERALMODESETTINGS_DISCONNECTIONTIMEOUTSECONDS` | *int |  |
| `MM_MOBILEEPHEMERALMODESETTINGS_OFFLINEPERSISTENCETIMERHOURS` | *int |  |
| `MM_MOBILEEPHEMERALMODESETTINGS_AUTOCACHECLEANUPDAYS` | *int |  |

## MM_MESSAGEEXPORTSETTINGS  (`MessageExportSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_MESSAGEEXPORTSETTINGS_ENABLEEXPORT` | *bool |  |
| `MM_MESSAGEEXPORTSETTINGS_EXPORTFORMAT` | *string |  |
| `MM_MESSAGEEXPORTSETTINGS_DAILYRUNTIME` | *string |  |
| `MM_MESSAGEEXPORTSETTINGS_EXPORTFROMTIMESTAMP` | *int64 |  |
| `MM_MESSAGEEXPORTSETTINGS_BATCHSIZE` | *int |  |
| `MM_MESSAGEEXPORTSETTINGS_DOWNLOADEXPORTRESULTS` | *bool |  |
| `MM_MESSAGEEXPORTSETTINGS_CHANNELBATCHSIZE` | *int |  |
| `MM_MESSAGEEXPORTSETTINGS_CHANNELHISTORYBATCHSIZE` | *int |  |
| `MM_MESSAGEEXPORTSETTINGS_GLOBALRELAYSETTINGS` | *GlobalRelayMessageExportSettings |  |

## MM_JOBSETTINGS  (`JobSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_JOBSETTINGS_RUNJOBS` | *bool |  |
| `MM_JOBSETTINGS_RUNSCHEDULER` | *bool |  |
| `MM_JOBSETTINGS_CLEANUPJOBSTHRESHOLDDAYS` | *int |  |
| `MM_JOBSETTINGS_CLEANUPCONFIGTHRESHOLDDAYS` | *int |  |

## MM_PLUGINSETTINGS  (`PluginSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_PLUGINSETTINGS_ENABLE` | *bool |  |
| `MM_PLUGINSETTINGS_ENABLEUPLOADS` | *bool |  |
| `MM_PLUGINSETTINGS_ALLOWINSECUREDOWNLOADURL` | *bool |  |
| `MM_PLUGINSETTINGS_ENABLEHEALTHCHECK` | *bool |  |
| `MM_PLUGINSETTINGS_DIRECTORY` | *string |  |
| `MM_PLUGINSETTINGS_CLIENTDIRECTORY` | *string |  |
| `MM_PLUGINSETTINGS_PLUGINS` | map[string]map[string]any |  |
| `MM_PLUGINSETTINGS_PLUGINSTATES` | map[string] |  |
| `MM_PLUGINSETTINGS_ENABLEMARKETPLACE` | *bool |  |
| `MM_PLUGINSETTINGS_ENABLEREMOTEMARKETPLACE` | *bool |  |
| `MM_PLUGINSETTINGS_AUTOMATICPREPACKAGEDPLUGINS` | *bool |  |
| `MM_PLUGINSETTINGS_REQUIREPLUGINSIGNATURE` | *bool |  |
| `MM_PLUGINSETTINGS_MARKETPLACEURL` | *string |  |
| `MM_PLUGINSETTINGS_SIGNATUREPUBLICKEYFILES` | []string |  |
| `MM_PLUGINSETTINGS_CHIMERAOAUTHPROXYURL` | *string |  |

## MM_DISPLAYSETTINGS  (`DisplaySettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_DISPLAYSETTINGS_CUSTOMURLSCHEMES` | []string |  |
| `MM_DISPLAYSETTINGS_MAXMARKDOWNNODES` | *int |  |

## MM_GUESTACCOUNTSSETTINGS  (`GuestAccountsSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_GUESTACCOUNTSSETTINGS_ENABLE` | *bool |  |
| `MM_GUESTACCOUNTSSETTINGS_HIDETAGS` | *bool |  |
| `MM_GUESTACCOUNTSSETTINGS_ALLOWEMAILACCOUNTS` | *bool |  |
| `MM_GUESTACCOUNTSSETTINGS_ENFORCEMULTIFACTORAUTHENTICATION` | *bool |  |
| `MM_GUESTACCOUNTSSETTINGS_RESTRICTCREATIONTODOMAINS` | *string |  |
| `MM_GUESTACCOUNTSSETTINGS_ENABLEGUESTMAGICLINK` | *bool |  |

## MM_IMAGEPROXYSETTINGS  (`ImageProxySettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_IMAGEPROXYSETTINGS_ENABLE` | *bool |  |
| `MM_IMAGEPROXYSETTINGS_IMAGEPROXYTYPE` | *string |  |
| `MM_IMAGEPROXYSETTINGS_REMOTEIMAGEPROXYURL` | *string |  |
| `MM_IMAGEPROXYSETTINGS_REMOTEIMAGEPROXYOPTIONS` | *string |  |

## MM_CLOUDSETTINGS  (`CloudSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_CLOUDSETTINGS_CWSURL` | *string |  |
| `MM_CLOUDSETTINGS_CWSAPIURL` | *string |  |
| `MM_CLOUDSETTINGS_CWSMOCK` | *bool |  |
| `MM_CLOUDSETTINGS_DISABLE` | *bool |  |
| `MM_CLOUDSETTINGS_PREVIEWMODALBUCKETURL` | *string |  |

## MM_IMPORTSETTINGS  (`ImportSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_IMPORTSETTINGS_DIRECTORY` | *string |  |
| `MM_IMPORTSETTINGS_RETENTIONDAYS` | *int |  |

## MM_EXPORTSETTINGS  (`ExportSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_EXPORTSETTINGS_DIRECTORY` | *string |  |
| `MM_EXPORTSETTINGS_RETENTIONDAYS` | *int |  |

## MM_WRANGLERSETTINGS  (`WranglerSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_WRANGLERSETTINGS_PERMITTEDWRANGLERROLES` | []string |  |
| `MM_WRANGLERSETTINGS_ALLOWEDEMAILDOMAIN` | []string |  |
| `MM_WRANGLERSETTINGS_MOVETHREADMAXCOUNT` | *int64 |  |
| `MM_WRANGLERSETTINGS_MOVETHREADTOANOTHERTEAMENABLE` | *bool |  |
| `MM_WRANGLERSETTINGS_MOVETHREADFROMPRIVATECHANNELENABLE` | *bool |  |
| `MM_WRANGLERSETTINGS_MOVETHREADFROMDIRECTMESSAGECHANNELENABLE` | *bool |  |
| `MM_WRANGLERSETTINGS_MOVETHREADFROMGROUPMESSAGECHANNELENABLE` | *bool |  |

## MM_CONNECTEDWORKSPACESSETTINGS  (`ConnectedWorkspacesSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_CONNECTEDWORKSPACESSETTINGS_ENABLESHAREDCHANNELS` | *bool |  |
| `MM_CONNECTEDWORKSPACESSETTINGS_ENABLEREMOTECLUSTERSERVICE` | *bool |  |
| `MM_CONNECTEDWORKSPACESSETTINGS_DISABLESHAREDCHANNELSSTATUSSYNC` | *bool |  |
| `MM_CONNECTEDWORKSPACESSETTINGS_SYNCUSERSONCONNECTIONOPEN` | *bool |  |
| `MM_CONNECTEDWORKSPACESSETTINGS_GLOBALUSERSYNCBATCHSIZE` | *int |  |
| `MM_CONNECTEDWORKSPACESSETTINGS_MAXPOSTSPERSYNC` | *int |  |
| `MM_CONNECTEDWORKSPACESSETTINGS_MEMBERSYNCBATCHSIZE` | *int |  |

## MM_ACCESSCONTROLSETTINGS  (`AccessControlSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_ACCESSCONTROLSETTINGS_ENABLEATTRIBUTEBASEDACCESSCONTROL` | *bool |  |
| `MM_ACCESSCONTROLSETTINGS_ENABLEUSERMANAGEDATTRIBUTES` | *bool |  |
| `MM_ACCESSCONTROLSETTINGS_TRUSTPROXYDEVICEIDENTITYHEADER` | *bool |  |
| `MM_ACCESSCONTROLSETTINGS_ENFORCEDEVICEIDCONSISTENCY` | *bool |  |

## MM_AUTOTRANSLATIONSETTINGS  (`AutoTranslationSettings`)

| Env var | Go type | json key |
|---|---|---|
| `MM_AUTOTRANSLATIONSETTINGS_ENABLE` | *bool |  |
| `MM_AUTOTRANSLATIONSETTINGS_RESTRICTDMANDGM` | *bool |  |
| `MM_AUTOTRANSLATIONSETTINGS_PROVIDER` | *string |  |
| `MM_AUTOTRANSLATIONSETTINGS_TARGETLANGUAGES` | *[]string |  |
| `MM_AUTOTRANSLATIONSETTINGS_WORKERS` | *int |  |
| `MM_AUTOTRANSLATIONSETTINGS_TIMEOUTMS` | *int |  |
| `MM_AUTOTRANSLATIONSETTINGS_LIBRETRANSLATE` | *LibreTranslateProviderSettings |  |
| `MM_AUTOTRANSLATIONSETTINGS_AGENTS` | *AgentsProviderSettings |  |



<!-- ============================================================ -->
## FILE: `reference/endpoints.md`

# REST API v4 Endpoint Catalog

> AUTO-GENERATED by `scripts/build-reference.py` — do not edit by hand.
> Source of truth: `api/v4/source/*.yaml (OpenAPI)`
> Regenerate after pinning the source to your `MM_VERSION`.

Endpoint summary. Full request/response schema: see the source YAML or the Redoc render.

| Method | Path | operationId | Summary |
|---|---|---|---|
| PUT | `/api/v4/access_control_policies` | CreateAccessControlPolicy | Create an access control policy |
| POST | `/api/v4/access_control_policies/cel/check` | CheckAccessControlPolicyExpression | Check an access control policy expression |
| POST | `/api/v4/access_control_policies/cel/validate_requester` | ValidateExpressionAgainstRequester | Validate if the current user matches a CEL expression |
| POST | `/api/v4/access_control_policies/cel/test` | TestAccessControlPolicyExpression | Test an access control policy expression |
| POST | `/api/v4/access_control_policies/cel/simulate_users` |  | Simulate an access control policy decision for an explicit user list |
| POST | `/api/v4/access_control_policies/search` | SearchAccessControlPolicies | Search access control policies |
| GET | `/api/v4/access_control_policies/cel/autocomplete/fields` | GetAccessControlPolicyAutocompleteFields | Get autocomplete fields for access control policies |
| GET | `/api/v4/access_control_policies/cel/autocomplete/fields` | GetAccessControlPolicy | Get an access control policy |
| DELETE | `/api/v4/access_control_policies/cel/autocomplete/fields` | DeleteAccessControlPolicy | Delete an access control policy |
| GET | `/api/v4/access_control_policies/cel/autocomplete/fields` | UpdateAccessControlPolicyActiveStatus | Activate or deactivate an access control policy |
| POST | `/api/v4/access_control_policies/cel/autocomplete/fields` | AssignAccessControlPolicyToChannels | Assign an access control policy to channels or teams |
| DELETE | `/api/v4/access_control_policies/cel/autocomplete/fields` | UnassignAccessControlPolicyFromChannels | Unassign an access control policy from channels or teams |
| GET | `/api/v4/access_control_policies/cel/autocomplete/fields` | GetChannelsForAccessControlPolicy | Get channels for an access control policy |
| POST | `/api/v4/access_control_policies/cel/autocomplete/fields` | SearchChannelsForAccessControlPolicy | Search channels for an access control policy |
| GET | `/api/v4/access_control_policies/cel/autocomplete/fields` | GetChannelAccessControlAttributes | Get access control attributes for a channel |
| POST | `/api/v4/access_control_policies/cel/visual_ast` | GetCELVisualAST | Get the visual AST for a CEL expression |
| PUT | `/api/v4/access_control_policies/activate` | UpdateAccessControlPoliciesActive | Activate or deactivate access control policies |
| POST | `/api/v4/actions/dialogs/open` | OpenInteractiveDialog | Open a dialog |
| POST | `/api/v4/actions/dialogs/submit` | SubmitInteractiveDialog | Submit a dialog |
| POST | `/api/v4/actions/dialogs/lookup` | LookupInteractiveDialog | Lookup dialog elements |
| GET | `/api/v4/agents` | GetAgents | Get available agents |
| GET | `/api/v4/agents/status` | GetAgentsStatus | Get agents bridge status |
| GET | `/api/v4/llmservices` | GetLLMServices | Get available LLM services |
| POST | `/api/v4/audit_logs/certificate` | AddAuditLogCertificate | Upload audit log certificate |
| DELETE | `/api/v4/audit_logs/certificate` | RemoveAuditLogCertificate | Remove audit log certificate |
| GET | `/api/v4/channels/{channel_id}/bookmarks` | ListChannelBookmarksForChannel | Get channel bookmarks for Channel |
| POST | `/api/v4/channels/{channel_id}/bookmarks` | CreateChannelBookmark | Create channel bookmark |
| PATCH | `/api/v4/channels/{channel_id}/bookmarks/{bookmark_id}` | UpdateChannelBookmark | Update channel bookmark |
| DELETE | `/api/v4/channels/{channel_id}/bookmarks/{bookmark_id}` | DeleteChannelBookmark | Delete channel bookmark |
| POST | `/api/v4/channels/{channel_id}/bookmarks/{bookmark_id}/sort_order` | UpdateChannelBookmarkSortOrder | Update channel bookmark's order |
| POST | `/api/v4/bots` | CreateBot | Create a bot |
| GET | `/api/v4/bots` | GetBots | Get bots |
| PUT | `/api/v4/bots` | PatchBot | Patch a bot |
| GET | `/api/v4/bots` | GetBot | Get a bot |
| POST | `/api/v4/bots` | DisableBot | Disable a bot |
| POST | `/api/v4/bots` | EnableBot | Enable a bot |
| POST | `/api/v4/bots` | AssignBot | Assign a bot to a user |
| POST | `/api/v4/bots` | ConvertBotToUser | Convert a bot into a user |
| GET | `/api/v4/brand/image` | GetBrandImage | Get brand image |
| POST | `/api/v4/brand/image` | UploadBrandImage | Upload brand image |
| DELETE | `/api/v4/brand/image` | DeleteBrandImage | Delete current brand image |
| GET | `/api/v4/channels` | GetAllChannels | Get a list of all channels |
| POST | `/api/v4/channels` | CreateChannel | Create a channel |
| POST | `/api/v4/channels/direct` | CreateDirectChannel | Create a direct message channel |
| POST | `/api/v4/channels/group` | CreateGroupChannel | Create a group message channel |
| POST | `/api/v4/channels/search` | SearchAllChannels | Search all private and open type channels across all teams |
| POST | `/api/v4/channels/group/search` | SearchGroupChannels | Search Group Channels |
| POST | `/api/v4/channels/group/search` | GetPublicChannelsByIdsForTeam | Get a list of channels by ids |
| GET | `/api/v4/channels/group/search` | GetChannelMembersTimezones | Get timezones in a channel |
| GET | `/api/v4/channels/group/search` | GetChannel | Get a channel |
| PUT | `/api/v4/channels/group/search` | UpdateChannel | Update a channel |
| DELETE | `/api/v4/channels/group/search` | DeleteChannel | Delete a channel |
| PUT | `/api/v4/channels/group/search` |  | Patch a channel |
| PUT | `/api/v4/channels/group/search` | UpdateChannelPrivacy | Update channel's privacy |
| POST | `/api/v4/channels/group/search` | RestoreChannel | Restore a channel |
| POST | `/api/v4/channels/group/search` | MoveChannel | Move a channel |
| GET | `/api/v4/channels/group/search` | GetChannelStats | Get channel statistics |
| GET | `/api/v4/channels/group/search` | GetPinnedPosts | Get a channel's pinned posts |
| GET | `/api/v4/channels/group/search` | GetPublicChannelsForTeam | Get public channels |
| GET | `/api/v4/channels/group/search` | GetPrivateChannelsForTeam | Get private channels |
| GET | `/api/v4/channels/group/search` | GetRecommendedChannelsForTeam | Get recommended public channels for the current user |
| GET | `/api/v4/channels/group/search` | GetDeletedChannelsForTeam | Get deleted channels |
| GET | `/api/v4/channels/group/search` | AutocompleteChannelsForTeam | Autocomplete channels |
| GET | `/api/v4/channels/group/search` | AutocompleteChannelsForTeamForSearch | Autocomplete channels for search |
| GET | `/api/v4/channels/group/search` | GetManagedCategories | Get managed category mappings |
| POST | `/api/v4/channels/group/search` | SearchChannels | Search channels |
| GET | `/api/v4/channels/group/search` | GetChannelByName | Get a channel by name |
| GET | `/api/v4/channels/group/search` | GetChannelByNameForTeamName | Get a channel by name and team name |
| GET | `/api/v4/channels/group/search` | GetChannelMembers | Get channel members |
| POST | `/api/v4/channels/group/search` | AddChannelMember | Add user(s) to channel |
| PUT | `/api/v4/channels/group/search` |  | Set channel members |
| POST | `/api/v4/channels/group/search` | GetChannelMembersByIds | Get channel members by ids |
| GET | `/api/v4/channels/group/search` | GetChannelMember | Get channel member |
| DELETE | `/api/v4/channels/group/search` | RemoveUserFromChannel | Remove user from channel |
| PUT | `/api/v4/channels/group/search` | UpdateChannelRoles | Update channel roles |
| PUT | `/api/v4/channels/group/search` | UpdateChannelMemberSchemeRoles | Update the scheme-derived roles of a channel member. |
| PUT | `/api/v4/channels/group/search` | UpdateChannelNotifyProps | Update channel notifications |
| PUT | `/api/v4/channels/group/search` | UpdateChannelMemberAutotranslation | Update channel member autotranslation setting |
| POST | `/api/v4/channels/group/search` | MarkChannelsReadForUser | Mark multiple channels as read |
| POST | `/api/v4/channels/group/search` | GetChannelsMemberCount | Get member counts for multiple channels |
| POST | `/api/v4/channels/group/search` | ViewChannel | View channel |
| PUT | `/api/v4/channels/group/search` | MarkAllDirectMessagesRead | Mark all direct and group messages as read |
| GET | `/api/v4/channels/group/search` | GetChannelMembersForUser | Get channel memberships and roles for a user |
| GET | `/api/v4/channels/group/search` | GetChannelsForTeamForUser | Get channels for user |
| GET | `/api/v4/channels/group/search` | GetChannelsForUser | Get all channels from all teams |
| GET | `/api/v4/channels/group/search` | GetChannelUnread | Get unread messages |
| PUT | `/api/v4/channels/group/search` | UpdateChannelScheme | Set a channel's scheme |
| GET | `/api/v4/channels/group/search` | ChannelMembersMinusGroupMembers | Channel members minus group members. |
| GET | `/api/v4/channels/group/search` | GetChannelMemberCountsByGroup | Channel members counts for each group that has atleast one member in the channel |
| GET | `/api/v4/channels/group/search` | GetChannelModerations | Get information about channel's moderation. |
| PUT | `/api/v4/channels/group/search` | PatchChannelModerations | Update a channel's moderation settings. |
| GET | `/api/v4/channels/group/search` | GetSidebarCategoriesForTeamForUser | Get user's sidebar categories |
| POST | `/api/v4/channels/group/search` | CreateSidebarCategoryForTeamForUser | Create user's sidebar category |
| PUT | `/api/v4/channels/group/search` | UpdateSidebarCategoriesForTeamForUser | Update user's sidebar categories |
| GET | `/api/v4/channels/group/search` | GetSidebarCategoryOrderForTeamForUser | Get user's sidebar category order |
| PUT | `/api/v4/channels/group/search` | UpdateSidebarCategoryOrderForTeamForUser | Update user's sidebar category order |
| GET | `/api/v4/channels/group/search` | GetSidebarCategoryForTeamForUser | Get sidebar category |
| PUT | `/api/v4/channels/group/search` | UpdateSidebarCategoryForTeamForUser | Update sidebar category |
| DELETE | `/api/v4/channels/group/search` | RemoveSidebarCategoryForTeamForUser | Delete sidebar category |
| GET | `/api/v4/channels/group/search` | GetGroupMessageMembersCommonTeams | Get common teams for members of a Group Message. |
| POST | `/api/v4/channels/group/search` | ConvertGroupMessageToChannel | Convert group message to private channel |
| GET | `/api/v4/cloud/limits` | GetCloudLimits | Get cloud workspace limits |
| GET | `/api/v4/cloud/products` | GetCloudProducts | Get cloud products |
| GET | `/api/v4/cloud/customer` | GetCloudCustomer | Get cloud customer |
| PUT | `/api/v4/cloud/customer` | UpdateCloudCustomer | Update cloud customer |
| PUT | `/api/v4/cloud/customer/address` | UpdateCloudCustomerAddress | Update cloud customer address |
| POST | `/api/v4/cloud/validate-business-email` | ValidateBusinessEmail | Validate business email |
| POST | `/api/v4/cloud/validate-workspace-business-email` | ValidateWorkspaceBusinessEmail | Validate workspace business email |
| GET | `/api/v4/cloud/subscription` | GetSubscription | Get cloud subscription |
| GET | `/api/v4/cloud/installation` | GetEndpointForInstallationInformation | GET endpoint for Installation information |
| GET | `/api/v4/cloud/subscription/invoices` | GetInvoicesForSubscription | Get cloud subscription invoices |
| GET | `/api/v4/cloud/subscription/invoices/{invoice_id}/pdf` | GetInvoiceForSubscriptionAsPdf | Get cloud invoice PDF |
| GET | `/api/v4/hosted_customer/signup_available` | HostedCustomerSignupAvailable | Check hosted signup availability |
| GET | `/api/v4/cloud/check-cws-connection` | CheckCWSConnection | Check CWS connection |
| POST | `/api/v4/cloud/webhook` | PostEndpointForCwsWebhooks | POST endpoint for CWS Webhooks |
| GET | `/api/v4/cloud/preview/modal_data` | GetPreviewModalData | Get cloud preview modal data |
| GET | `/api/v4/cluster/status` | GetClusterStatus | Get cluster status |
| POST | `/api/v4/commands` | CreateCommand | Create a command |
| GET | `/api/v4/commands` | ListCommands | List commands for a team |
| GET | `/api/v4/commands` | ListAutocompleteCommands | List autocomplete commands |
| GET | `/api/v4/commands` | ListCommandAutocompleteSuggestions | List commands' autocomplete data |
| GET | `/api/v4/commands` | GetCommandById | Get a command |
| PUT | `/api/v4/commands` | UpdateCommand | Update a command |
| DELETE | `/api/v4/commands` | DeleteCommand | Delete a command |
| PUT | `/api/v4/commands` | MoveCommand | Move a command |
| PUT | `/api/v4/commands` | RegenCommandToken | Generate a new token |
| POST | `/api/v4/commands/execute` | ExecuteCommand | Execute a command |
| POST | `/api/v4/compliance/reports` | CreateComplianceReport | Create report |
| GET | `/api/v4/compliance/reports` | GetComplianceReports | Get reports |
| GET | `/api/v4/compliance/reports` | GetComplianceReport | Get a report |
| GET | `/api/v4/compliance/reports` | DownloadComplianceReport | Download a report |
| GET | `/api/v4/content_flagging/flag/config` | GetCFFlagConfig | Get content flagging configuration |
| GET | `/api/v4/content_flagging/team/{team_id}/status` | GetCFTeamStatus | Get content flagging status for a team |
| POST | `/api/v4/content_flagging/post/{post_id}/flag` | PostCFPostFlag | Flag a post |
| GET | `/api/v4/content_flagging/fields` | GetCFFields | Get content flagging property fields |
| GET | `/api/v4/content_flagging/post/{post_id}/field_values` | GetCFPostFieldValues | Get content flagging property field values for a post |
| GET | `/api/v4/content_flagging/post/{post_id}` | GetCFPost | Get a flagged post with all its content. |
| PUT | `/api/v4/content_flagging/post/{post_id}/remove` | RemoveCFPost | Remove a flagged post |
| PUT | `/api/v4/content_flagging/post/{post_id}/keep` | KeepCFPost | Keep a flagged post |
| GET | `/api/v4/content_flagging/config` | GetCFConfig | Get the system content flagging configuration |
| PUT | `/api/v4/content_flagging/config` | UpdateCFConfig | Update the system content flagging configuration |
| GET | `/api/v4/content_flagging/team/{team_id}/reviewers/search` | SearchCFTeamReviewers | Search content reviewers in a team |
| POST | `/api/v4/content_flagging/post/{post_id}/assign/{content_reviewer_id}` | PostCFPostReviewer | Assign a content reviewer to a flagged post |
| POST | `/api/v4/content_flagging/post/{post_id}/report` | GenerateCFPostReport | Generate and download a flagged post report |
| GET | `/api/v4/data_retention/policy` | GetDataRetentionPolicy | Get the global data retention policy |
| GET | `/api/v4/data_retention/policies_count` | GetDataRetentionPoliciesCount | Get the number of granular data retention policies |
| GET | `/api/v4/data_retention/policies` | GetDataRetentionPolicies | Get the granular data retention policies |
| POST | `/api/v4/data_retention/policies` | CreateDataRetentionPolicy | Create a new granular data retention policy |
| GET | `/api/v4/data_retention/policies` | GetDataRetentionPolicyByID | Get a granular data retention policy |
| PATCH | `/api/v4/data_retention/policies` | PatchDataRetentionPolicy | Patch a granular data retention policy |
| DELETE | `/api/v4/data_retention/policies` | DeleteDataRetentionPolicy | Delete a granular data retention policy |
| GET | `/api/v4/data_retention/policies` | GetTeamsForRetentionPolicy | Get the teams for a granular data retention policy |
| POST | `/api/v4/data_retention/policies` | AddTeamsToRetentionPolicy | Add teams to a granular data retention policy |
| DELETE | `/api/v4/data_retention/policies` | RemoveTeamsFromRetentionPolicy | Delete teams from a granular data retention policy |
| POST | `/api/v4/data_retention/policies` | SearchTeamsForRetentionPolicy | Search for the teams in a granular data retention policy |
| GET | `/api/v4/data_retention/policies` | GetChannelsForRetentionPolicy | Get the channels for a granular data retention policy |
| POST | `/api/v4/data_retention/policies` | AddChannelsToRetentionPolicy | Add channels to a granular data retention policy |
| DELETE | `/api/v4/data_retention/policies` | RemoveChannelsFromRetentionPolicy | Delete channels from a granular data retention policy |
| POST | `/api/v4/data_retention/policies` | SearchChannelsForRetentionPolicy | Search for the channels in a granular data retention policy |
| POST | `/api/v4/elasticsearch/test` | TestElasticsearch | Test Elasticsearch configuration |
| POST | `/api/v4/elasticsearch/purge_indexes` | PurgeElasticsearchIndexes | Purge all Elasticsearch indexes |
| POST | `/api/v4/emoji` | CreateEmoji | Create a custom emoji |
| GET | `/api/v4/emoji` | GetEmojiList | Get a list of custom emoji |
| GET | `/api/v4/emoji` | GetEmoji | Get a custom emoji |
| DELETE | `/api/v4/emoji` | DeleteEmoji | Delete a custom emoji |
| GET | `/api/v4/emoji` | GetEmojiByName | Get a custom emoji by name |
| GET | `/api/v4/emoji` | GetEmojiImage | Get custom emoji image |
| POST | `/api/v4/emoji/search` | SearchEmoji | Search custom emoji |
| GET | `/api/v4/emoji/autocomplete` | AutocompleteEmoji | Autocomplete custom emoji |
| POST | `/api/v4/emoji/names` | GetEmojisByNames | Get custom emojis by name |
| POST | `/api/v4/files` |  | Upload a file |
| GET | `/api/v4/files` | GetFile | Get a file |
| GET | `/api/v4/files` | GetFileThumbnail | Get a file's thumbnail |
| GET | `/api/v4/files` | GetFilePreview | Get a file's preview |
| GET | `/api/v4/files` | GetFileLink | Get a public file link |
| GET | `/api/v4/files` | GetFileInfo | Get metadata for a file |
| GET | `/api/v4/files` | GetFilePublic | Get a public file |
| POST | `/api/v4/files` | SearchFiles | Search files in a team |
| POST | `/api/v4/files` | SearchFiles | Search files across the teams of the current user |
| GET | `/api/v4/groups` | GetGroups | Get groups |
| POST | `/api/v4/groups` | CreateGroup | Create a custom group |
| GET | `/api/v4/groups` | GetGroup | Get a group |
| DELETE | `/api/v4/groups` | DeleteGroup | Deletes a custom group |
| PUT | `/api/v4/groups` | PatchGroup | Patch a group |
| POST | `/api/v4/groups` | RestoreGroup | Restore a previously deleted group. |
| POST | `/api/v4/groups` | LinkGroupSyncableForTeam | Link a team to a group |
| DELETE | `/api/v4/groups` | UnlinkGroupSyncableForTeam | Unlink a team from a group |
| POST | `/api/v4/groups` | LinkGroupSyncableForChannel | Link a channel to a group |
| DELETE | `/api/v4/groups` | UnlinkGroupSyncableForChannel | Unlink a channel from a group |
| GET | `/api/v4/groups` | GetGroupSyncableForTeamId | Get a team syncable for a group |
| GET | `/api/v4/groups` | GetGroupSyncableForChannelId | Get a channel syncable for a group |
| GET | `/api/v4/groups` | GetGroupSyncablesTeams | Get team syncables for a group |
| GET | `/api/v4/groups` | GetGroupSyncablesChannels | Get channel syncables for a group |
| PUT | `/api/v4/groups` | PatchGroupSyncableForTeam | Patch a team syncable for a group |
| PUT | `/api/v4/groups` | PatchGroupSyncableForChannel | Patch a channel syncable for a group |
| GET | `/api/v4/groups` | GetGroupUsers | Get group users |
| DELETE | `/api/v4/groups` | DeleteGroupMembers | Removes members from a custom group |
| POST | `/api/v4/groups` | AddGroupMembers | Adds members to a custom group |
| GET | `/api/v4/groups` | GetGroupStats | Get group stats |
| GET | `/api/v4/groups` | GetGroupsByChannel | Get channel groups |
| GET | `/api/v4/groups` | GetGroupsByTeam | Get team groups |
| GET | `/api/v4/groups` | GetGroupsAssociatedToChannelsByTeam | Get team groups by channels |
| GET | `/api/v4/groups` | GetGroupsByUserId | Get groups for a userId |
| POST | `/api/v4/groups` | GetGroupsByNames | Get groups by name |
| GET | `/api/v4/ip_filtering` | GetIPFilters | Get all IP filters |
| POST | `/api/v4/ip_filtering` | ApplyIPFilters | Get all IP filters |
| GET | `/api/v4/ip_filtering/my_ip` | MyIP | Get all IP filters |
| GET | `/api/v4/jobs` |  | Get the jobs. |
| POST | `/api/v4/jobs` | CreateJob | Create a new job. |
| GET | `/api/v4/jobs` | GetJob | Get a job. |
| GET | `/api/v4/jobs` | DownloadJob | Download the results of a job. |
| POST | `/api/v4/jobs` | CancelJob | Cancel a job. |
| GET | `/api/v4/jobs` | GetJobsByType | Get the jobs of the given type. |
| PATCH | `/api/v4/jobs` | UpdateJobStatus | Update the status of a job |
| POST | `/api/v4/ldap/sync` | SyncLdap | Sync with LDAP |
| POST | `/api/v4/ldap/test` | TestLdap | Test LDAP configuration |
| POST | `/api/v4/ldap/test_connection` | TestLdapConnection | Test LDAP connection with specific settings |
| POST | `/api/v4/ldap/test_diagnostics` | TestLdapDiagnostics | Test LDAP diagnostics with specific settings |
| GET | `/api/v4/ldap/groups` | GetLdapGroups | Returns a list of LDAP groups |
| POST | `/api/v4/ldap/groups/{remote_id}/link` | LinkLdapGroup | Link a LDAP group |
| DELETE | `/api/v4/ldap/groups/{remote_id}/link` | UnlinkLdapGroup | Delete a link for LDAP group |
| POST | `/api/v4/ldap/migrateid` | MigrateIdLdap | Migrate Id LDAP |
| POST | `/api/v4/ldap/certificate/public` | UploadLdapPublicCertificate | Upload public certificate |
| DELETE | `/api/v4/ldap/certificate/public` | DeleteLdapPublicCertificate | Remove public certificate |
| POST | `/api/v4/ldap/certificate/private` | UploadLdapPrivateCertificate | Upload private key |
| DELETE | `/api/v4/ldap/certificate/private` | DeleteLdapPrivateCertificate | Remove private key |
| POST | `/api/v4/ldap/users/{user_id}/group_sync_memberships` | AddUserToGroupSyncables | Create memberships for LDAP configured channels and teams for this user |
| GET | `/api/v4/limits/server` | GetServerLimits | Gets the server limits for the server |
| GET | `/api/v4/logs/download` | DownloadSystemLogs | Download system logs |
| POST | `/api/v4/client_perf` | SubmitPerformanceReport | Report client performance metrics |
| POST | `/api/v4/oauth/apps` | CreateOAuthApp | Register OAuth app |
| GET | `/api/v4/oauth/apps` | GetOAuthApps | Get OAuth apps |
| GET | `/api/v4/oauth/apps` | GetOAuthApp | Get an OAuth app |
| PUT | `/api/v4/oauth/apps` | UpdateOAuthApp | Update an OAuth app |
| DELETE | `/api/v4/oauth/apps` | DeleteOAuthApp | Delete an OAuth app |
| POST | `/api/v4/oauth/apps` | RegenerateOAuthAppSecret | Regenerate OAuth app secret |
| GET | `/api/v4/oauth/apps` | GetOAuthAppInfo | Get info on an OAuth app |
| GET | `/api/v4/oauth/apps` | GetAuthorizationServerMetadata | Get OAuth 2.0 Authorization Server Metadata |
| POST | `/api/v4/oauth/apps/register` | RegisterOAuthClient | Register OAuth client using Dynamic Client Registration |
| GET | `/api/v4/oauth/apps/register` | GetAuthorizedOAuthAppsForUser | Get authorized OAuth apps |
| GET | `/api/v4/oauth/outgoing_connections` | ListOutgoingOAuthConnections | List all connections |
| POST | `/api/v4/oauth/outgoing_connections` | CreateOutgoingOAuthConnection | Create a connection |
| GET | `/api/v4/oauth/outgoing_connections/{outgoing_oauth_connection_id}` | GetOutgoingOAuthConnection | Get a connection |
| PUT | `/api/v4/oauth/outgoing_connections/{outgoing_oauth_connection_id}` | UpdateOutgoingOAuthConnection | Update a connection |
| DELETE | `/api/v4/oauth/outgoing_connections/{outgoing_oauth_connection_id}` | DeleteOutgoingOAuthConnection | Delete a connection |
| POST | `/api/v4/oauth/outgoing_connections/validate` | ValidateOutgoingOAuthConnection | Validate a connection configuration |
| POST | `/api/v4/permissions/ancillary` | GetAncillaryPermissionsPost | Return all system console subsection ancillary permissions |
| POST | `/api/v4/plugins` | UploadPlugin | Upload plugin |
| GET | `/api/v4/plugins` | GetPlugins | Get plugins |
| POST | `/api/v4/plugins/install_from_url` | InstallPluginFromUrl | Install plugin from url |
| DELETE | `/api/v4/plugins/install_from_url` | RemovePlugin | Remove plugin |
| POST | `/api/v4/plugins/install_from_url` | EnablePlugin | Enable plugin |
| POST | `/api/v4/plugins/install_from_url` | DisablePlugin | Disable plugin |
| GET | `/api/v4/plugins/webapp` | GetWebappPlugins | Get webapp plugins |
| GET | `/api/v4/plugins/statuses` | GetPluginStatuses | Get plugins status |
| POST | `/api/v4/plugins/marketplace` | InstallMarketplacePlugin | Installs a marketplace plugin |
| GET | `/api/v4/plugins/marketplace` | GetMarketplacePlugins | Gets all the marketplace plugins |
| GET | `/api/v4/plugins/marketplace/first_admin_visit` | GetMarketplaceVisitedByAdmin | Get if the Plugin Marketplace has been visited by at least an admin. |
| POST | `/api/v4/plugins/marketplace/first_admin_visit` | UpdateMarketplaceVisitedByAdmin | Stores that the Plugin Marketplace has been visited by at least an admin. |
| POST | `/api/v4/plugins/reattach` | ReattachPlugin | Reattach a plugin process |
| POST | `/api/v4/plugins/reattach` | DetachPlugin | Detach a reattached plugin process |
| POST | `/api/v4/posts` | CreatePost | Create a post |
| POST | `/api/v4/posts/ephemeral` | CreatePostEphemeral | Create a ephemeral post |
| POST | `/api/v4/posts/search` | SearchPostsInAllTeams | Search posts across all teams |
| GET | `/api/v4/posts/search` | GetPost | Get a post |
| DELETE | `/api/v4/posts/search` | DeletePost | Delete a post |
| PUT | `/api/v4/posts/search` | UpdatePost | Update a post |
| POST | `/api/v4/posts/search` | SetPostUnread | Mark as unread from a post. |
| PUT | `/api/v4/posts/search` | PatchPost | Patch a post |
| GET | `/api/v4/posts/search` | GetPostThread | Get a thread |
| GET | `/api/v4/posts/search` | GetFlaggedPostsForUser | Get a list of flagged posts |
| GET | `/api/v4/posts/search` | GetFileInfosForPost | Get file info for post |
| GET | `/api/v4/posts/search` | GetPostInfo | Get post info |
| GET | `/api/v4/posts/search` | GetEditHistoryForPost | Get post edit history |
| GET | `/api/v4/posts/search` | GetPostsForChannel | Get posts for a channel |
| GET | `/api/v4/posts/search` | GetPostsAroundLastUnread | Get posts around oldest unread |
| POST | `/api/v4/posts/search` | SearchPosts | Search for team posts |
| POST | `/api/v4/posts/search` | PinPost | Pin a post to the channel |
| POST | `/api/v4/posts/search` | UnpinPost | Unpin a post to the channel |
| POST | `/api/v4/posts/search` | DoPostAction | Perform a post action |
| POST | `/api/v4/posts/search` | getPostsByIds | Get posts by a list of ids |
| POST | `/api/v4/posts/search` | SetPostReminder | Set a post reminder |
| POST | `/api/v4/posts/search` | SaveAcknowledgementForPost | Acknowledge a post |
| DELETE | `/api/v4/posts/search` | DeleteAcknowledgementForPost | Delete a post acknowledgement |
| POST | `/api/v4/posts/search` | MoveThread | Move a post (and any posts within that post's thread) |
| POST | `/api/v4/posts/search` | RestorePostVersion | Restores a past version of a post |
| GET | `/api/v4/posts/search` | RevealPost | Reveal a burn-on-read post |
| DELETE | `/api/v4/posts/search` | BurnPost | Burn a burn-on-read post |
| POST | `/api/v4/posts/search` | RewriteMessage | Rewrite a message using AI |
| POST | `/api/v4/reactions` | SaveReaction | Create a reaction |
| GET | `/api/v4/reactions` | GetReactions | Get a list of reactions to a post |
| DELETE | `/api/v4/reactions` | DeleteReaction | Remove a reaction from a post |
| POST | `/api/v4/posts/ids/reactions` | GetBulkReactions | Bulk get the reaction for posts |
| GET | `/api/v4/reports/users` | GetUsersForReporting | Get a list of paged and sorted users for admin reporting purposes |
| GET | `/api/v4/reports/users/count` | GetUserCountForReporting | Gets the full count of users that match the filter. |
| POST | `/api/v4/reports/users/export` | StartBatchUsersExport | Starts a job to export the users to a report file. |
| POST | `/api/v4/reports/posts` |  | Get posts for reporting and compliance purposes using cursor-based pagination |
| POST | `/api/v4/roles/names` | GetRolesByNames | Get a list of roles by name |
| GET | `/api/v4/saml/metadata` | GetSamlMetadata | Get metadata |
| POST | `/api/v4/saml/metadatafromidp` | GetSamlMetadataFromIdp | Get metadata from Identity Provider |
| POST | `/api/v4/saml/certificate/idp` | UploadSamlIdpCertificate | Upload IDP certificate |
| DELETE | `/api/v4/saml/certificate/idp` | DeleteSamlIdpCertificate | Remove IDP certificate |
| POST | `/api/v4/saml/certificate/public` | UploadSamlPublicCertificate | Upload public certificate |
| DELETE | `/api/v4/saml/certificate/public` | DeleteSamlPublicCertificate | Remove public certificate |
| POST | `/api/v4/saml/certificate/private` | UploadSamlPrivateCertificate | Upload private key |
| DELETE | `/api/v4/saml/certificate/private` | DeleteSamlPrivateCertificate | Remove private key |
| GET | `/api/v4/saml/certificate/status` | GetSamlCertificateStatus | Get certificate status |
| POST | `/api/v4/saml/reset_auth_data` | ResetSamlAuthDataToEmail | Reset AuthData to Email |
| POST | `/api/v4/posts/schedule` | CreateScheduledPost | Creates a scheduled post |
| GET | `/api/v4/posts/scheduled/team/{team_id}` | GetUserScheduledPosts | Gets all scheduled posts for a user for the specified team.. |
| PUT | `/api/v4/posts/schedule/{scheduled_post_id}` | UpdateScheduledPost | Update a scheduled post |
| DELETE | `/api/v4/posts/schedule/{scheduled_post_id}` | DeleteScheduledPost | Delete a scheduled post |
| GET | `/api/v4/schemes` | GetSchemes | Get the schemes. |
| POST | `/api/v4/schemes` | CreateScheme | Create a scheme |
| GET | `/api/v4/schemes` | GetScheme | Get a scheme |
| DELETE | `/api/v4/schemes` | DeleteScheme | Delete a scheme |
| PUT | `/api/v4/schemes` | PatchScheme | Patch a scheme |
| GET | `/api/v4/schemes` | GetTeamsForScheme | Get a page of teams which use this scheme. |
| GET | `/api/v4/schemes` | GetChannelsForScheme | Get a page of channels which use this scheme. |
| GET | `/api/v4/terms_of_service` | GetTermsOfService | Get latest terms of service |
| POST | `/api/v4/terms_of_service` | CreateTermsOfService | Creates a new terms of service |
| POST | `/api/v4/users/status/ids` | GetUsersStatusesByIds | Get user statuses by id |
| PUT | `/api/v4/users/status/ids` | UpdateUserCustomStatus | Update user custom status |
| DELETE | `/api/v4/users/status/ids` | UnsetUserCustomStatus | Unsets user custom status |
| DELETE | `/api/v4/users/status/ids` | RemoveRecentCustomStatus | Delete user's recent custom status |
| POST | `/api/v4/users/status/ids` | PostUserRecentCustomStatusDelete | Delete user's recent custom status |
| GET | `/api/v4/system/timezones` | GetSupportedTimezone | Retrieve a list of supported timezones |
| GET | `/api/v4/system/ping` |  | Check system health |
| GET | `/api/v4/websocket` | ConnectWebSocket | Open a WebSocket connection |
| GET | `/api/v4/websocket` | ManualTest | Run manual testing helpers |
| GET | `/api/v4/websocket` | GetNotices | Get notices for logged in user in specified team |
| PUT | `/api/v4/system/notices/view` | MarkNoticesViewed | Update notices as 'viewed' |
| GET | `/api/v4/system/onboarding/complete` | GetOnboardingComplete | Get first admin onboarding completion status |
| POST | `/api/v4/system/onboarding/complete` | CompleteOnboarding | Complete first admin onboarding |
| PUT | `/api/v4/system/e2e/ai_bridge` | SetAIBridgeTestHelper | Configure AI bridge E2E test helper |
| GET | `/api/v4/system/e2e/ai_bridge` | GetAIBridgeTestHelper | Get AI bridge E2E test helper state |
| DELETE | `/api/v4/system/e2e/ai_bridge` | DeleteAIBridgeTestHelper | Reset AI bridge E2E test helper |
| POST | `/api/v4/database/recycle` | DatabaseRecycle | Recycle database connections |
| POST | `/api/v4/email/test` | TestEmail | Send a test email |
| POST | `/api/v4/notifications/test` | TestNotification | Send a test notification |
| POST | `/api/v4/site_url/test` | TestSiteURL | Checks the validity of a Site URL |
| POST | `/api/v4/file/test` | TestFileStoreConnection | Test the configured file storage backend |
| POST | `/api/v4/file/s3_test` | TestS3Connection | Test AWS S3 connection |
| GET | `/api/v4/config` | GetConfig | Get configuration |
| PUT | `/api/v4/config` | UpdateConfig | Update configuration |
| POST | `/api/v4/config/reload` | ReloadConfig | Reload configuration |
| POST | `/api/v4/config/migrate` | MigrateConfig | Migrate config storage |
| GET | `/api/v4/config/client` | GetClientConfig | Get client configuration |
| GET | `/api/v4/config/environment` | GetEnvironmentConfig | Get configuration made through environment variables |
| PUT | `/api/v4/config/patch` | PatchConfig | Patch configuration |
| POST | `/api/v4/license` | UploadLicenseFile | Upload license file |
| DELETE | `/api/v4/license` | RemoveLicenseFile | Remove license file |
| POST | `/api/v4/license/preview` | PreviewLicenseFile | Preview license file |
| GET | `/api/v4/license/client` | GetClientLicense | Get client license |
| GET | `/api/v4/license/load_metric` | GetLicenseLoadMetric | Get license load metric |
| POST | `/api/v4/trial-license` | RequestTrialLicense | Request and install a trial license for your server |
| GET | `/api/v4/trial-license/prev` | GetPrevTrialLicense | Get last trial license used |
| GET | `/api/v4/audits` | GetAudits | Get audits |
| POST | `/api/v4/caches/invalidate` | InvalidateCaches | Invalidate all the caches |
| GET | `/api/v4/logs` | GetLogs | Get logs |
| POST | `/api/v4/logs` | PostLog | Add log message |
| POST | `/api/v4/logs/query` | QueryLogs | Query server logs with filters |
| GET | `/api/v4/analytics/old` | GetAnalyticsOld | Get analytics |
| GET | `/api/v4/latest_version` | GetLatestVersion | Get latest public server release information |
| GET | `/api/v4/system/schema/version` | GetAppliedSchemaMigrations | Get applied database schema migrations |
| POST | `/api/v4/server_busy` | SetServerBusy | Set the server busy (high load) flag |
| GET | `/api/v4/server_busy` | GetServerBusyExpires | Get server busy expiry time. |
| DELETE | `/api/v4/server_busy` | ClearServerBusy | Clears the server busy (high load) flag |
| POST | `/api/v4/notifications/ack` | AcknowledgeNotification | Acknowledge receiving of a notification |
| GET | `/api/v4/redirect_location` | GetRedirectLocation | Get redirect location |
| GET | `/api/v4/image` | GetImageByUrl | Get an image by url |
| POST | `/api/v4/upgrade_to_enterprise` | UpgradeToEnterprise | Executes an inplace upgrade from Team Edition to Enterprise Edition |
| GET | `/api/v4/upgrade_to_enterprise/status` | UpgradeToEnterpriseStatus | Get the current status for the inplace upgrade from Team Edition to Enterprise E |
| GET | `/api/v4/upgrade_to_enterprise/allowed` | IsAllowedToUpgradeToEnterprise | Check if the user is allowed to upgrade to Enterprise Edition |
| POST | `/api/v4/restart` | RestartServer | Restart the system after an upgrade from Team Edition to Enterprise Edition |
| POST | `/api/v4/integrity` | CheckIntegrity | Perform a database integrity check |
| GET | `/api/v4/system/support_packet` | GenerateSupportPacket | Download a zip file which contains helpful and useful information for troublesho |
| POST | `/api/v4/teams` | CreateTeam | Create a team |
| GET | `/api/v4/teams` | GetAllTeams | Get teams |
| GET | `/api/v4/teams` | GetTeam | Get a team |
| PUT | `/api/v4/teams` | UpdateTeam | Update a team |
| DELETE | `/api/v4/teams` | SoftDeleteTeam | Delete a team |
| PUT | `/api/v4/teams` | PatchTeam | Patch a team |
| PUT | `/api/v4/teams` | UpdateTeamPrivacy | Update teams's privacy |
| POST | `/api/v4/teams` | RestoreTeam | Restore a team |
| GET | `/api/v4/teams` | GetTeamByName | Get a team by name |
| POST | `/api/v4/teams/search` | SearchTeams | Search teams |
| GET | `/api/v4/teams/search` | TeamExists | Check if team exists |
| GET | `/api/v4/teams/search` | GetTeamsForUser | Get a user's teams |
| GET | `/api/v4/teams/search` | GetTeamMembers | Get team members |
| POST | `/api/v4/teams/search` | AddTeamMember | Add user to team |
| POST | `/api/v4/teams/members/invite` | AddTeamMemberFromInvite | Add user to team from invite |
| POST | `/api/v4/teams/members/invite` | AddTeamMembers | Add multiple users to team |
| GET | `/api/v4/teams/members/invite` | GetTeamMembersForUser | Get team members for a user |
| GET | `/api/v4/teams/members/invite` | GetTeamMember | Get a team member |
| DELETE | `/api/v4/teams/members/invite` | RemoveTeamMember | Remove user from team |
| POST | `/api/v4/teams/members/invite` | GetTeamMembersByIds | Get team members by ids |
| GET | `/api/v4/teams/members/invite` | GetTeamStats | Get a team stats |
| GET | `/api/v4/teams/members/invite` | GetTeamAccessControlPolicy | Get the access control policy for a team |
| POST | `/api/v4/teams/members/invite` | RegenerateTeamInviteId | Regenerate the Invite ID from a Team |
| GET | `/api/v4/teams/members/invite` | GetTeamIcon | Get the team icon |
| POST | `/api/v4/teams/members/invite` | SetTeamIcon | Sets the team icon |
| DELETE | `/api/v4/teams/members/invite` | RemoveTeamIcon | Remove the team icon |
| PUT | `/api/v4/teams/members/invite` | UpdateTeamMemberRoles | Update a team member roles |
| PUT | `/api/v4/teams/members/invite` | UpdateTeamMemberSchemeRoles | Update the scheme-derived roles of a team member. |
| GET | `/api/v4/teams/members/invite` | GetTeamsUnreadForUser | Get team unreads for a user |
| GET | `/api/v4/teams/members/invite` | GetTeamUnread | Get unreads for a team |
| POST | `/api/v4/teams/members/invite` | InviteUsersToTeam | Invite users to the team by email |
| POST | `/api/v4/teams/members/invite` | InviteGuestsToTeam | Invite guests to the team by email |
| DELETE | `/api/v4/teams/invites/email` | InvalidateEmailInvites | Invalidate active email invitations |
| POST | `/api/v4/teams/invites/email` | ImportTeam | Import a Team from other application |
| GET | `/api/v4/teams/invites/email` | GetTeamInviteInfo | Get invite info for a team |
| PUT | `/api/v4/teams/invites/email` | UpdateTeamScheme | Set a team's scheme |
| GET | `/api/v4/teams/invites/email` | TeamMembersMinusGroupMembers | Team members minus group members. |
| GET | `/api/v4/usage/posts` | GetPostsUsage | Get current usage of posts |
| GET | `/api/v4/usage/storage` | GetStorageUsage | Get the total file storage usage for the instance in bytes. |
| GET | `/api/v4/usage/teams` | GetTeamsUsage | Get current usage of teams |
| POST | `/api/v4/users/login` | Login | Login to Mattermost server |
| POST | `/api/v4/users/login/desktop_token` | LoginWithDesktopToken | Login using desktop token |
| POST | `/api/v4/users/login/cws` | LoginByCwsToken | Auto-Login to Mattermost server using CWS token |
| POST | `/api/v4/users/login/sso/code-exchange` | LoginSSOCodeExchange | Exchange SSO login code for session tokens |
| POST | `/api/v4/users/login/sso/code-exchange` |  | Login with Microsoft Intune MAM |
| POST | `/api/v4/users/logout` | Logout | Logout from the Mattermost server |
| POST | `/api/v4/users/notify-admin` | NotifyAdmin | Save notify-admin intent |
| POST | `/api/v4/users/trigger-notify-admin-posts` | TriggerNotifyAdminPosts | Trigger notify-admin posts |
| POST | `/api/v4/users` | CreateUser | Create a user |
| GET | `/api/v4/users` | GetUsers | Get users |
| DELETE | `/api/v4/users` | PermanentDeleteAllUsers | Permanent delete all users |
| POST | `/api/v4/users/ids` | GetUsersByIds | Get users by ids |
| POST | `/api/v4/users/group_channels` | GetUsersByGroupChannelIds | Get users by group channels ids |
| POST | `/api/v4/users/usernames` | GetUsersByUsernames | Get users by usernames |
| POST | `/api/v4/users/search` | SearchUsers | Search users |
| GET | `/api/v4/users/autocomplete` | AutocompleteUsers | Autocomplete users |
| GET | `/api/v4/users/known` | GetKnownUsers | Get user IDs of known users |
| GET | `/api/v4/users/stats` | GetTotalUsersStats | Get total count of users in the system |
| GET | `/api/v4/users/stats/filtered` | GetTotalUsersStatsFiltered | Get total count of users in the system matching the specified filters |
| GET | `/api/v4/users/stats/filtered` | GetUser | Get a user |
| PUT | `/api/v4/users/stats/filtered` | UpdateUser | Update a user |
| DELETE | `/api/v4/users/stats/filtered` | DeleteUser | Deactivate a user account. |
| PUT | `/api/v4/users/stats/filtered` | PatchUser | Patch a user |
| PUT | `/api/v4/users/stats/filtered` | UpdateUserRoles | Update a user's roles |
| PUT | `/api/v4/users/stats/filtered` | UpdateUserActive | Activate or deactivate a user |
| GET | `/api/v4/users/stats/filtered` | GetProfileImage | Get user's profile image |
| POST | `/api/v4/users/stats/filtered` | SetProfileImage | Set user's profile image |
| DELETE | `/api/v4/users/stats/filtered` | SetDefaultProfileImage | Delete user's profile image |
| GET | `/api/v4/users/stats/filtered` | GetDefaultProfileImage | Return user's default (generated) profile image |
| GET | `/api/v4/users/stats/filtered` | GetUserByUsername | Get a user by username |
| GET | `/api/v4/users/auth_data` | GetUserByAuthData | Get a user by auth data |
| POST | `/api/v4/users/password/reset` | ResetPassword | Reset password |
| PUT | `/api/v4/users/password/reset` | UpdateUserMfa | Update a user's MFA |
| POST | `/api/v4/users/password/reset` | GenerateMfaSecret | Generate MFA secret |
| POST | `/api/v4/users/password/reset` | DemoteUserToGuest | Demote a user to a guest |
| POST | `/api/v4/users/password/reset` | PromoteGuestToUser | Promote a guest to user |
| POST | `/api/v4/users/password/reset` | ConvertUserToBot | Convert a user into a bot |
| PUT | `/api/v4/users/password/reset` | UpdateUserPassword | Update a user's password |
| POST | `/api/v4/users/password/reset/send` | SendPasswordResetEmail | Send password reset email |
| GET | `/api/v4/users/password/reset/send` | GetUserByEmail | Get a user by email |
| GET | `/api/v4/users/password/reset/send` | GetSessions | Get user's sessions |
| POST | `/api/v4/users/password/reset/send` | RevokeSession | Revoke a user session |
| POST | `/api/v4/users/password/reset/send` | RevokeAllSessions | Revoke all active sessions for a user |
| PUT | `/api/v4/users/sessions/device` | AttachDeviceExtraProps | Attach mobile device and extra props to the session object |
| GET | `/api/v4/users/sessions/attributes/manifest` | GetSessionAttributesManifest | Get the session attributes manifest |
| GET | `/api/v4/users/sessions/attributes/manifest` | GetUserAudits | Get user's audits |
| POST | `/api/v4/users/sessions/attributes/manifest` | VerifyUserEmailWithoutToken | Verify user email by ID |
| POST | `/api/v4/users/email/verify` | VerifyUserEmail | Verify user email |
| POST | `/api/v4/users/email/verify/send` | SendVerificationEmail | Send verification email |
| POST | `/api/v4/users/login/switch` |  | Switch login method |
| POST | `/api/v4/users/login/type` | GetLoginType | Get login authentication type |
| POST | `/api/v4/users/login/type` | CreateUserAccessToken | Create a user access token |
| GET | `/api/v4/users/login/type` | GetUserAccessTokensForUser | Get user access tokens |
| GET | `/api/v4/users/tokens` | GetUserAccessTokens | Get user access tokens |
| POST | `/api/v4/users/tokens/revoke` | RevokeUserAccessToken | Revoke a user access token |
| GET | `/api/v4/users/tokens/revoke` | GetUserAccessToken | Get a user access token |
| POST | `/api/v4/users/tokens/disable` | DisableUserAccessToken | Disable personal access token |
| POST | `/api/v4/users/tokens/enable` | EnableUserAccessToken | Enable personal access token |
| POST | `/api/v4/users/tokens/search` | SearchUserAccessTokens | Search tokens |
| PUT | `/api/v4/users/tokens/search` | UpdateUserAuth | Update a user's authentication method |
| POST | `/api/v4/users/tokens/search` | RegisterTermsOfServiceAction | Records user action when they accept or decline custom terms of service |
| GET | `/api/v4/users/tokens/search` | GetUserTermsOfService | Fetches user's latest terms of service action if the latest action was |
| POST | `/api/v4/users/sessions/revoke/all` | RevokeSessionsFromAllUsers | Revoke all sessions from all users. |
| POST | `/api/v4/users/sessions/revoke/all` | PublishUserTyping | Publish a user typing websocket event. |
| GET | `/api/v4/users/sessions/revoke/all` | GetUploadsForUser | Get uploads for a user |
| GET | `/api/v4/users/sessions/revoke/all` | GetChannelMembersWithTeamDataForUser | Get all channel members from all teams for a user |
| POST | `/api/v4/users/migrate_auth/ldap` | MigrateAuthToLdap | Migrate user accounts authentication type to LDAP. |
| POST | `/api/v4/users/migrate_auth/saml` | MigrateAuthToSaml | Migrate user accounts authentication type to SAML. |
| GET | `/api/v4/users/migrate_auth/saml` | GetUserThreads | Get all threads that user is following |
| PUT | `/api/v4/users/migrate_auth/saml` | MarkAllTeamChannelsRead | Mark all channels and threads in a team as read |
| PUT | `/api/v4/users/migrate_auth/saml` | UpdateThreadsReadForUser | Mark all threads that user is following as read |
| PUT | `/api/v4/users/migrate_auth/saml` | UpdateThreadReadForUser | Mark a thread that user is following read state to the timestamp |
| POST | `/api/v4/users/migrate_auth/saml` | SetThreadUnreadByPostId | Mark a thread that user is following as unread based on a post id |
| PUT | `/api/v4/users/migrate_auth/saml` | StartFollowingThread | Start following a thread |
| DELETE | `/api/v4/users/migrate_auth/saml` | StopFollowingThread | Stop following a thread |
| GET | `/api/v4/users/migrate_auth/saml` | GetUserThread | Get a thread followed by the user |
| POST | `/api/v4/drafts` | UpsertDraft | Upsert synced draft |
| GET | `/api/v4/drafts` | GetDrafts | Get synced drafts for a team |
| DELETE | `/api/v4/drafts` | DeleteDraft | Delete synced draft |
| DELETE | `/api/v4/drafts` | DeleteDraftForThread | Delete synced thread draft |
| GET | `/api/v4/drafts` | GetTeamPoliciesForUser | Get the policies which are applied to a user's teams |
| GET | `/api/v4/drafts` | GetChannelPoliciesForUser | Get the policies which are applied to a user's channels |
| GET | `/api/v4/users/invalid_emails` | GetUsersWithInvalidEmails | Get users with invalid emails |
| POST | `/api/v4/users/invalid_emails` | resetPasswordFailedAttempts | Reset the failed password attempts for a user |
| GET | `/api/v4/channels/{channel_id}/views` | ListChannelViews | List channel views |
| POST | `/api/v4/channels/{channel_id}/views` | CreateChannelView | Create channel view |
| GET | `/api/v4/channels/{channel_id}/views/{view_id}` | GetChannelView | Get a channel view |
| PATCH | `/api/v4/channels/{channel_id}/views/{view_id}` | UpdateChannelView | Update a channel view |
| DELETE | `/api/v4/channels/{channel_id}/views/{view_id}` | DeleteChannelView | Delete a channel view |
| GET | `/api/v4/channels/{channel_id}/views/{view_id}/posts` | GetPostsForView | Get posts for a view |
| POST | `/api/v4/channels/{channel_id}/views/{view_id}/sort_order` | UpdateChannelViewSortOrder | Update a channel view's sort order |
| POST | `/api/v4/hooks/incoming` | CreateIncomingWebhook | Create an incoming webhook |
| GET | `/api/v4/hooks/incoming` | GetIncomingWebhooks | List incoming webhooks |
| GET | `/api/v4/hooks/incoming` | GetIncomingWebhook | Get an incoming webhook |
| DELETE | `/api/v4/hooks/incoming` | DeleteIncomingWebhook | Delete an incoming webhook |
| PUT | `/api/v4/hooks/incoming` | UpdateIncomingWebhook | Update an incoming webhook |
| POST | `/api/v4/hooks/outgoing` | CreateOutgoingWebhook | Create an outgoing webhook |
| GET | `/api/v4/hooks/outgoing` | GetOutgoingWebhooks | List outgoing webhooks |
| GET | `/api/v4/hooks/outgoing` | GetOutgoingWebhook | Get an outgoing webhook |
| DELETE | `/api/v4/hooks/outgoing` | DeleteOutgoingWebhook | Delete an outgoing webhook |
| PUT | `/api/v4/hooks/outgoing` | UpdateOutgoingWebhook | Update an outgoing webhook |
| POST | `/api/v4/hooks/outgoing` | RegenOutgoingHookToken | Regenerate the token for the outgoing webhook. |


<!-- ============================================================ -->
## FILE: `reference/mmctl-commands.md`

# mmctl Command Catalog

> AUTO-GENERATED by `scripts/build-reference.py` — do not edit by hand.
> Source of truth: `server/cmd/mmctl/commands/*.go`
> Regenerate after pinning the source to your `MM_VERSION`.

Cobra commands (`Use` / `Short`). Used by all provisioning/branding/plugin scripts.

| Use | Short |
|---|---|
| `auth` | Manages the credentials of the remote Mattermost instances |
| `login [instance url] --name [server name] --username [username] --password-file [password-file]` | Login into an instance |
| `current` | Show current user credentials |
| `set [server name]` | Set the credentials to use |
| `list` | Lists the credentials |
| `renew` | Renews a set of credentials |
| `delete [server name]` | Delete an credentials |
| `clean` | Clean all credentials |
| `bot` | Management of bots |
| `create [username]` | Create bot |
| `update [username]` | Update bot |
| `list` | List bots |
| `disable [username]` | Disable bot |
| `enable [username]` | Enable bot |
| `assign [bot-username] [new-owner-username]` | Assign bot |
| `channel` | Management of channels |
| `create` | Create a channel |
| `rename [channel]` | Rename channel |
| `archive [channels]` | Archive channels |
| `delete [channels]` | Delete channels |
| `list [teams]` | List all channels on specified teams. |
| `modify [channel] [flags]` | Modify a channel's public/private type |
| `unarchive [channels]` | Unarchive some channels |
| `search [channel]\n  mmctl search --team [team] [channel]` | Search a channel |
| `move [team] [channels]` | Moves channels to the specified team |
| `users` | Management of channel users |
| `add [channel] [users]` | Add users to channel |
| `remove [channel] [users]` | Remove users from channel |
| `command` | Management of slash commands |
| `create [team]` | Create a custom slash command |
| `list [teams]` | List all commands on specified teams. |
| `archive [commandID]` | Archive a slash command |
| `modify [commandID]` | Modify a slash command |
| `move [team] [commandID]` | Move a slash command to a different team |
| `show [commandID]` | Show a custom slash command |
| `compliance-export` | Management of compliance exports |
| `list` | List compliance export jobs, sorted by creation date descending (newest first) |
| `show [complianceExportJobID]` | Show compliance export job |
| `cancel [complianceExportJobID]` | Cancel compliance export job |
| `download [complianceExportJobID] [output filepath (optional)]` | Download compliance export file |
| `create [complianceExportType] --date \` | Create a compliance export job, of type 'csv' or 'actiance' or 'globalrelay' |
| `config` | Configuration |
| `get` | Get config setting |
| `set` | Set config setting |
| `patch <config-file>` | Patch the config |
| `edit` | Edit the config |
| `reset` | Reset config setting |
| `show` | Writes the server configuration to STDOUT |
| `reload` | Reload the server configuration |
| `migrate [from_config] [to_config]` | Migrate existing config between backends |
| `subpath` | Update client asset loading to use the configured subpath |
| `export` | Export the server configuration |
| `docs` | Generates mmctl documentation |
| `export` | Management of exports |
| `create` | Create export file |
| `download [exportname] [filepath]` | Download export files |
| `generate-presigned-url [exportname]` | Generate a presigned url for an export file. This is helpful when an export is big and might have trouble downloading from the Mattermost server. |
| `delete [exportname]` | Delete export file |
| `list` | List export files |
| `job` | List, show and cancel export jobs |
| `list` | List export jobs |
| `show [exportJobID]` | Show export job |
| `cancel [exportJobID]` | Cancel export job |
| `extract` | Management of content extraction job. |
| `run` | Start a content extraction job. |
| `job` | List and show content extraction jobs |
| `list` | List content extraction jobs |
| `show [extractJobID]` | Show extract job |
| `group` | Management of groups |
| `list-ldap` | List LDAP groups |
| `channel` | Management of channel groups |
| `enable [team]:[channel]` | Enables group constrains in the specified channel |
| `disable [team]:[channel]` | Disables group constrains in the specified channel |
| `status [team]:[channel]` | Show's the group constrain status for the specified channel |
| `list [team]:[channel]` | List channel groups |
| `team` | Management of team groups |
| `enable [team]` | Enables group constrains in the specified team |
| `disable [team]` | Disables group constrains in the specified team |
| `status [team]` | Show's the group constrain status for the specified team |
| `list [team]` | List team groups |
| `user` | Management of custom user groups |
| `restore [groupname]` | Restore user group |
| `import` | Management of imports |
| `upload [filepath]` | Upload import files |
| `delete [importname]` | Delete an import file |
| `list` | List import files |
| `available` | List available import files |
| `job` | List and show import jobs |
| `incomplete` | List incomplete import files uploads |
| `list` | List import jobs |
| `show [importJobID]` | Show import job |
| `process [importname]` | Start an import job |
| `validate [filepath]` | Validate an import file |
| `integrity` | Check database records integrity. |
| `job` | Management of jobs |
| `list` | List the latest jobs |
| `update [job] [status]` | Update the status of a job |
| `ldap` | LDAP related utilities |
| `sync` | Synchronize now |
| `idmigrate <objectGUID>` | Migrate LDAP IdAttribute to new value |
| `job` | List and show LDAP sync jobs |
| `list` | List LDAP sync jobs |
| `show [ldapJobID]` | Show LDAP sync job |
| `license` | Licensing commands |
| `upload [license]` | Upload a license. |
| `upload-string [license]` | Upload a license from a string. |
| `remove` | Remove the current license. |
| `get` | Get the current license. |
| `logs` | Display logs in a human-readable format |
| `oauth` | Management of OAuth2 apps |
| `list` | List OAuth2 apps |
| `permissions` | Management of permissions |
| `add <role> <permission...>` | Add permissions to a role (EE Only) |
| `remove <role> <permission...>` | Remove permissions from a role (EE Only) |
| `reset <role_name>` | Reset default permissions for role (EE Only) |
| `role` | Management of roles |
| `show <role_name>` | Show the role information |
| `assign <role_name> <username...>` | Assign users to role (EE Only) |
| `unassign <role_name> <username...>` | Unassign users from role (EE Only) |
| `plugin` | Management of plugins |
| `add [plugins]` | Add plugins |
| `install-url <url>...` | Install plugin from url |
| `delete [plugins]` | Delete plugins |
| `enable [plugins]` | Enable plugins |
| `disable [plugins]` | Disable plugins |
| `list` | List plugins |
| `marketplace` | Management of marketplace plugins |
| `install <id>` | Install a plugin from the marketplace |
| `list` | List marketplace plugins |
| `post` | Management of posts |
| `create` | Create a post |
| `list` | List posts for a channel |
| `reveal [post]` | Reveal a post |
| `delete [posts]` | Mark posts as deleted or permanently delete posts with the --permanent flag |
| `report` | Reporting commands |
| `posts [channel]` | Retrieve posts for reporting purposes |
| `roles` | Manage user roles |
| `system-admin [users]` | Set a user as system admin |
| `member [users]` | Remove system admin privileges |
| `list` | List available roles |
| `mmctl` | Remote client for the Open Source, self-hosted Slack-alternative |
| `test` |  |
| `saml` | SAML related utilities |
| `auth-data-reset` | Reset AuthData field to Email |
| `sampledata` | Generate sample data |
| `system` | System management |
| `getbusy` | Get the current busy state |
| `setbusy -s [seconds]` | Set the busy state to true |
| `clearbusy` | Clears the busy state |
| `version` | Prints the remote server version |
| `status` | Prints the status of the server |
| `supportpacket` | Download a Support Packet |
| `nuke` | Destructive operations that permanently delete data |
| `users` | Delete all users and all posts. Local command only. |
| `team` | Management of teams |
| `create` | Create a team |
| `delete [teams]` | Delete teams |
| `archive [teams]` | Archive teams |
| `restore [teams]` | Restore teams |
| `list` | List all teams |
| `search [teams]` | Search for teams |
| `rename [team]` | Rename team |
| `modify [teams] [flag]` | Modify teams |
| `users` | Management of team users |
| `remove [team] [users]` | Remove users from team |
| `add [team] [users]` | Add users to team |
| `token` | manage users' access tokens |
| `generate [user] [description]` | Generate token for a user |
| `revoke [token-ids]` | Revoke tokens for a user |
| `list [user]` | List users tokens |
| `user` | Management of users |
| `activate [emails, usernames, userIds]` | Activate users |
| `deactivate [emails, usernames, userIds]` | Deactivate users |
| `create` | Create a user |
| `invite [email] [teams]` | Send user an email invite to a team. |
| `reset-password [users]` | Send users an email to reset their password |
| `change-password <user>` | Changes a user's password |
| `resetmfa [users]` | Turn off MFA |
| `edit` | Edit user properties |
| `username [user] [new username]` | Edit user's username |
| `email [user] [new email]` | Edit user's email |
| `authdata [user] [new authdata]` | Edit user's authdata |
| `delete [users]` | Delete users |
| `search [users]` | Search for users |
| `list` | List users |
| `verify [users]` | Mark user's email as verified |
| `promote [guests]` | Promote guests to users |
| `demote [users]` | Demote users to guests |
| `convert (--bot [emails] [usernames] [userIds] | --user <username> --password PASSWORD [--email EMAIL])` | Convert users to bots, or a bot to a user |
| `migrate-auth [from_auth] [to_auth] [migration-options]` | Mass migrate user accounts authentication type |
| `preference` | Manage user preferences |
| `list [--category category] [users]` | List user preferences |
| `get --category [category] --name [name] [users]` | Get a specific user preference |
| `set --category [category] --name [name] --value [value] [users]` | Set a specific user preference |
| `delete --category [category] --name [name] [users]` | Delete a specific user preference |
| `attributes` | Management of User Attributes |
| `field` | Management of User Attributes fields |
| `value` | Management of User Attributes values |
| `list` | List User Attributes fields |
| `create [name] [type]` | Create a User Attributes field |
| `edit [field]` | Edit a User Attributes field |
| `delete [field]` | Delete a User Attributes field |
| `list [user]` | List User Attributes values for a user |
| `set [user] [field]` | Set a User Attributes value for a user |
| `version` | Prints the version of mmctl. |
| `webhook` | Management of webhooks |
| `list` | List webhooks |
| `show [webhookId]` | Show a webhook |
| `create-incoming` | Create incoming webhook |
| `modify-incoming` | Modify incoming webhook |
| `create-outgoing` | Create outgoing webhook |
| `modify-outgoing` | Modify outgoing webhook |
| `delete` | Delete webhooks |
| `websocket` | Display websocket in a human-readable format |


<!-- ============================================================ -->
## FILE: `reference/plugin-api.md`

# Plugin API Surface

> AUTO-GENERATED by `scripts/build-reference.py` — do not edit by hand.
> Source of truth: `server/public/plugin/api.go`
> Regenerate after pinning the source to your `MM_VERSION`.

Methods available to a server plugin via `plugin.API`. Used by GOAL-06 (AI translation).

- `LoadPluginConfiguration(dest any) error`  
  _LoadPluginConfiguration loads the plugin's configuration. dest should be a pointer to a struct that the configuration JSON can be unmarshalled to.  @tag Plugin _
- `RegisterCommand(command *model.Command) error`  
  _RegisterCommand registers a custom slash command. When the command is triggered, your plugin can fulfill it via the ExecuteCommand hook.  @tag Command Minimum s_
- `UnregisterCommand(teamID, trigger string) error`  
  _UnregisterCommand unregisters a command previously register via RegisterCommand.  @tag Command Minimum server version: 5.2_
- `ExecuteSlashCommand(commandArgs *model.CommandArgs) (*model.CommandResponse, error)`  
  _ExecuteSlashCommand executes a slash command with the given parameters.  @tag Command Minimum server version: 5.26_
- `GetConfig() *model.Config`  
  _GetConfig fetches the currently persisted config  @tag Configuration Minimum server version: 5.2_
- `GetUnsanitizedConfig() *model.Config`  
  _GetUnsanitizedConfig fetches the currently persisted config without removing secrets.  @tag Configuration Minimum server version: 5.16_
- `SaveConfig(config *model.Config) *model.AppError`  
  _SaveConfig sets the given config and persists the changes  @tag Configuration Minimum server version: 5.2_
- `GetPluginConfig() map[string]any`  
  _GetPluginConfig fetches the currently persisted config of plugin  @tag Plugin Minimum server version: 5.6_
- `SavePluginConfig(config map[string]any) *model.AppError`  
  _SavePluginConfig sets the given config for plugin and persists the changes  @tag Plugin Minimum server version: 5.6_
- `GetBundlePath() (string, error)`  
  _GetBundlePath returns the absolute path where the plugin's bundle was unpacked.  @tag Plugin Minimum server version: 5.10_
- `GetLicense() *model.License`  
  _GetLicense returns the current license used by the Mattermost server. Returns nil if the server does not have a license.  @tag Server Minimum server version: 5._
- `IsEnterpriseReady() bool`  
  _IsEnterpriseReady returns true if the Mattermost server is configured as Enterprise Ready.  @tag Server Minimum server version: 5.10_
- `GetServerVersion() string`  
  _GetServerVersion return the current Mattermost server version  @tag Server Minimum server version: 5.4_
- `GetSystemInstallDate() (int64, *model.AppError)`  
  _GetSystemInstallDate returns the time that Mattermost was first installed and ran.  @tag Server Minimum server version: 5.10_
- `GetDiagnosticId() string`  
  _GetDiagnosticId returns a unique identifier used by the server for diagnostic reports.  @tag Server Minimum server version: 5.10_
- `GetTelemetryId() string`  
  _GetTelemetryId returns a unique identifier used by the server for telemetry reports.  @tag Server Minimum server version: 5.28_
- `CreateUser(user *model.User) (*model.User, *model.AppError)`  
  _CreateUser creates a user.  @tag User Minimum server version: 5.2_
- `DeleteUser(userID string) *model.AppError`  
  _DeleteUser deletes a user.  @tag User Minimum server version: 5.2_
- `GetUsers(options *model.UserGetOptions) ([]*model.User, *model.AppError)`  
  _GetUsers a list of users based on search options.  Not all fields in UserGetOptions are supported by this API.  @tag User Minimum server version: 5.10_
- `GetUsersByIds(userIDs []string) ([]*model.User, *model.AppError)`  
  _GetUsersByIds gets a list of users by their IDs.  @tag User Minimum server version: 9.8_
- `GetUser(userID string) (*model.User, *model.AppError)`  
  _GetUser gets a user.  @tag User Minimum server version: 5.2_
- `GetUserByEmail(email string) (*model.User, *model.AppError)`  
  _GetUserByEmail gets a user by their email address.  @tag User Minimum server version: 5.2_
- `GetUserByUsername(name string) (*model.User, *model.AppError)`  
  _GetUserByUsername gets a user by their username.  @tag User Minimum server version: 5.2_
- `GetUsersByUsernames(usernames []string) ([]*model.User, *model.AppError)`  
  _GetUsersByUsernames gets users by their usernames.  @tag User Minimum server version: 5.6_
- `GetUsersInTeam(teamID string, page int, perPage int) ([]*model.User, *model.AppError)`  
  _GetUsersInTeam gets users in team.  @tag User @tag Team Minimum server version: 5.6_
- `GetPreferenceForUser(userID, category, name string) (model.Preference, *model.AppError)`  
  _GetPreferenceForUser gets a single preference for a user. An error is returned if the user has no preference set with the given category and name, an error is r_
- `GetPreferencesForUser(userID string) ([]model.Preference, *model.AppError)`  
  _GetPreferencesForUser gets a user's preferences.  @tag User @tag Preference Minimum server version: 5.26_
- `UpdatePreferencesForUser(userID string, preferences []model.Preference) *model.AppError`  
  _UpdatePreferencesForUser updates a user's preferences.  @tag User @tag Preference Minimum server version: 5.26_
- `DeletePreferencesForUser(userID string, preferences []model.Preference) *model.AppError`  
  _DeletePreferencesForUser deletes a user's preferences.  @tag User @tag Preference Minimum server version: 5.26_
- `GetSession(sessionID string) (*model.Session, *model.AppError)`  
  _GetSession returns the session object for the Session ID   Minimum server version: 5.2_
- `CreateSession(session *model.Session) (*model.Session, *model.AppError)`  
  _CreateSession creates a new user session.  @tag User Minimum server version: 6.2_
- `ExtendSessionExpiry(sessionID string, newExpiry int64) *model.AppError`  
  _ExtendSessionExpiry extends the duration of an existing session.  @tag User Minimum server version: 6.2_
- `RevokeSession(sessionID string) *model.AppError`  
  _RevokeSession revokes an existing user session.  @tag User Minimum server version: 6.2_
- `CreateUserAccessToken(token *model.UserAccessToken) (*model.UserAccessToken, *model.AppError)`  
  _CreateUserAccessToken creates a new access token. @tag User Minimum server version: 5.38_
- `RevokeUserAccessToken(tokenID string) *model.AppError`  
  _RevokeUserAccessToken revokes an existing access token. @tag User Minimum server version: 5.38_
- `GetTeamIcon(teamID string) ([]byte, *model.AppError)`  
  _GetTeamIcon gets the team icon.  @tag Team Minimum server version: 5.6_
- `SetTeamIcon(teamID string, data []byte) *model.AppError`  
  _SetTeamIcon sets the team icon.  @tag Team Minimum server version: 5.6_
- `RemoveTeamIcon(teamID string) *model.AppError`  
  _RemoveTeamIcon removes the team icon.  @tag Team Minimum server version: 5.6_
- `UpdateUser(user *model.User) (*model.User, *model.AppError)`  
  _UpdateUser updates a user.  @tag User Minimum server version: 5.2_
- `GetUserStatus(userID string) (*model.Status, *model.AppError)`  
  _GetUserStatus will get a user's status.  @tag User Minimum server version: 5.2_
- `GetUserStatusesByIds(userIds []string) ([]*model.Status, *model.AppError)`  
  _GetUserStatusesByIds will return a list of user statuses based on the provided slice of user IDs.  @tag User Minimum server version: 5.2_
- `UpdateUserStatus(userID, status string) (*model.Status, *model.AppError)`  
  _UpdateUserStatus will set a user's status until the user, or another integration/plugin, sets it back to online. The status parameter can be: "online", "away", _
- `SetUserStatusTimedDND(userId string, endtime int64) (*model.Status, *model.AppError)`  
  _SetUserStatusTimedDND will set a user's status to dnd for given time until the user, or another integration/plugin, sets it back to online. @tag User Minimum se_
- `UpdateUserActive(userID string, active bool) *model.AppError`  
  _UpdateUserActive deactivates or reactivates an user.  @tag User Minimum server version: 5.8_
- `UpdateUserCustomStatus(userID string, customStatus *model.CustomStatus) *model.AppError`  
  _UpdateUserCustomStatus will set a user's custom status until the user, or another integration/plugin, clear it or update the custom status. The custom status ha_
- `RemoveUserCustomStatus(userID string) *model.AppError`  
  _RemoveUserCustomStatus will remove a user's custom status.  @tag User Minimum server version: 6.2_
- `GetUsersInChannel(channelID, sortBy string, page, perPage int) ([]*model.User, *model.AppError)`  
  _GetUsersInChannel returns a page of users in a channel. Page counting starts at 0. The sortBy parameter can be: "username" or "status".  @tag User @tag Channel _
- `GetLDAPUserAttributes(userID string, attributes []string) (map[string]string, *model.AppError)`  
  _GetLDAPUserAttributes will return LDAP attributes for a user. The attributes parameter should be a list of attributes to pull. Returns a map with attribute name_
- `CreateTeam(team *model.Team) (*model.Team, *model.AppError)`  
  _CreateTeam creates a team.  @tag Team Minimum server version: 5.2_
- `DeleteTeam(teamID string) *model.AppError`  
  _DeleteTeam deletes a team.  @tag Team Minimum server version: 5.2_
- `GetTeams() ([]*model.Team, *model.AppError)`  
  _GetTeam gets all teams.  @tag Team Minimum server version: 5.2_
- `GetTeam(teamID string) (*model.Team, *model.AppError)`  
  _GetTeam gets a team.  @tag Team Minimum server version: 5.2_
- `GetTeamByName(name string) (*model.Team, *model.AppError)`  
  _GetTeamByName gets a team by its name.  @tag Team Minimum server version: 5.2_
- `GetTeamsUnreadForUser(userID string) ([]*model.TeamUnread, *model.AppError)`  
  _GetTeamsUnreadForUser gets the unread message and mention counts for each team to which the given user belongs.  @tag Team @tag User Minimum server version: 5.6_
- `UpdateTeam(team *model.Team) (*model.Team, *model.AppError)`  
  _UpdateTeam updates a team.  @tag Team Minimum server version: 5.2_
- `SearchTeams(term string) ([]*model.Team, *model.AppError)`  
  _SearchTeams search a team.  @tag Team Minimum server version: 5.8_
- `GetTeamsForUser(userID string) ([]*model.Team, *model.AppError)`  
  _GetTeamsForUser returns list of teams of given user ID.  @tag Team @tag User Minimum server version: 5.6_
- `CreateTeamMember(teamID, userID string) (*model.TeamMember, *model.AppError)`  
  _CreateTeamMember creates a team membership.  @tag Team @tag User Minimum server version: 5.2_
- `CreateTeamMembers(teamID string, userIds []string, requestorId string) ([]*model.TeamMember, *model.AppError)`  
  _CreateTeamMembers creates a team membership for all provided user ids.  @tag Team @tag User Minimum server version: 5.2_
- `CreateTeamMembersGracefully(teamID string, userIds []string, requestorId string) ([]*model.TeamMemberWithError, *model.AppError)`  
  _CreateTeamMembersGracefully creates a team membership for all provided user ids and reports the users that were not added.  @tag Team @tag User Minimum server v_
- `DeleteTeamMember(teamID, userID, requestorId string) *model.AppError`  
  _DeleteTeamMember deletes a team membership.  @tag Team @tag User Minimum server version: 5.2_
- `GetTeamMembers(teamID string, page, perPage int) ([]*model.TeamMember, *model.AppError)`  
  _GetTeamMembers returns the memberships of a specific team.  @tag Team @tag User Minimum server version: 5.2_
- `GetTeamMember(teamID, userID string) (*model.TeamMember, *model.AppError)`  
  _GetTeamMember returns a specific membership.  @tag Team @tag User Minimum server version: 5.2_
- `GetTeamMembersForUser(userID string, page int, perPage int) ([]*model.TeamMember, *model.AppError)`  
  _GetTeamMembersForUser returns all team memberships for a user.  @tag Team @tag User Minimum server version: 5.10_
- `UpdateTeamMemberRoles(teamID, userID, newRoles string) (*model.TeamMember, *model.AppError)`  
  _UpdateTeamMemberRoles updates the role for a team membership.  @tag Team @tag User Minimum server version: 5.2_
- `CreateChannel(channel *model.Channel) (*model.Channel, *model.AppError)`  
  _CreateChannel creates a channel.  @tag Channel Minimum server version: 5.2_
- `DeleteChannel(channelId string) *model.AppError`  
  _DeleteChannel deletes a channel.  @tag Channel Minimum server version: 5.2_
- `GetPublicChannelsForTeam(teamID string, page, perPage int) ([]*model.Channel, *model.AppError)`  
  _GetPublicChannelsForTeam gets a list of all channels.  @tag Channel @tag Team Minimum server version: 5.2_
- `GetChannel(channelId string) (*model.Channel, *model.AppError)`  
  _GetChannel gets a channel.  @tag Channel Minimum server version: 5.2_
- `GetChannelByName(teamID, name string, includeDeleted bool) (*model.Channel, *model.AppError)`  
  _GetChannelByName gets a channel by its name, given a team id.  @tag Channel Minimum server version: 5.2_
- `GetChannelByNameForTeamName(teamName, channelName string, includeDeleted bool) (*model.Channel, *model.AppError)`  
  _GetChannelByNameForTeamName gets a channel by its name, given a team name.  @tag Channel @tag Team Minimum server version: 5.2_
- `GetChannelsForTeamForUser(teamID, userID string, includeDeleted bool) ([]*model.Channel, *model.AppError)`  
  _GetChannelsForTeamForUser  gets a list of channels for given user ID in given team ID, including DMs. If an empty string is passed as the team ID, the user's ch_
- `GetChannelStats(channelId string) (*model.ChannelStats, *model.AppError)`  
  _GetChannelStats gets statistics for a channel.  @tag Channel Minimum server version: 5.6_
- `GetDirectChannel(userId1, userId2 string) (*model.Channel, *model.AppError)`  
  _GetDirectChannel gets a direct message channel. If the channel does not exist it will create it.  @tag Channel @tag User Minimum server version: 5.2_
- `GetGroupChannel(userIds []string) (*model.Channel, *model.AppError)`  
  _GetGroupChannel gets a group message channel. If the channel does not exist it will create it.  @tag Channel @tag User Minimum server version: 5.2_
- `UpdateChannel(channel *model.Channel) (*model.Channel, *model.AppError)`  
  _UpdateChannel updates a channel.  @tag Channel Minimum server version: 5.2_
- `RegisterChannelGuard(channelID string) *model.AppError`  
  _RegisterChannelGuard claims the channel for this plugin, signaling to the server that the channel has plugin-managed semantics and that the server's default beh_
- `UnregisterChannelGuard(channelID string) *model.AppError`  
  _UnregisterChannelGuard releases this plugin's claim on the channel. Only the registering plugin can unregister its own claim; other plugins' claims on the same _
- `SearchChannels(teamID string, term string) ([]*model.Channel, *model.AppError)`  
  _SearchChannels returns the channels on a team matching the provided search term.  @tag Channel Minimum server version: 5.6_
- `CreateChannelSidebarCategory(userID, teamID string, newCategory *model.SidebarCategoryWithChannels) (*model.SidebarCategoryWithChannels, *model.AppError)`  
  _CreateChannelSidebarCategory creates a new sidebar category for a set of channels.  @tag ChannelSidebar Minimum server version: 5.38_
- `GetChannelSidebarCategories(userID, teamID string) (*model.OrderedSidebarCategories, *model.AppError)`  
  _GetChannelSidebarCategories returns sidebar categories.  @tag ChannelSidebar Minimum server version: 5.38_
- `UpdateChannelSidebarCategories(userID, teamID string, categories []*model.SidebarCategoryWithChannels) ([]*model.SidebarCategoryWithChannels, *model.AppError)`  
  _UpdateChannelSidebarCategories updates the channel sidebar categories.  @tag ChannelSidebar Minimum server version: 5.38_
- `SearchUsers(search *model.UserSearch) ([]*model.User, *model.AppError)`  
  _SearchUsers returns a list of users based on some search criteria.  @tag User Minimum server version: 5.6_
- `SearchPostsInTeam(teamID string, paramsList []*model.SearchParams) ([]*model.Post, *model.AppError)`  
  _SearchPostsInTeam returns a list of posts in a specific team that match the given params.  @tag Post @tag Team Minimum server version: 5.10_
- `SearchPostsInTeamForUser(teamID string, userID string, searchParams model.SearchParameter) (*model.PostSearchResults, *model.AppError)`  
  _SearchPostsInTeamForUser returns a list of posts by team and user that match the given search parameters. @tag Post Minimum server version: 5.26_
- `AddChannelMember(channelId, userID string) (*model.ChannelMember, *model.AppError)`  
  _AddChannelMember joins a user to a channel (as if they joined themselves) This means the user will not receive notifications for joining the channel.  @tag Chan_
- `AddUserToChannel(channelId, userID, asUserId string) (*model.ChannelMember, *model.AppError)`  
  _AddUserToChannel adds a user to a channel as if the specified user had invited them. This means the user will receive the regular notifications for being added _
- `GetChannelMember(channelId, userID string) (*model.ChannelMember, *model.AppError)`  
  _GetChannelMember gets a channel membership for a user.  @tag Channel @tag User Minimum server version: 5.2_
- `GetChannelMembers(channelId string, page, perPage int) (model.ChannelMembers, *model.AppError)`  
  _GetChannelMembers gets a channel membership for all users.  @tag Channel @tag User Minimum server version: 5.6_
- `GetChannelMembersByIds(channelId string, userIds []string) (model.ChannelMembers, *model.AppError)`  
  _GetChannelMembersByIds gets a channel membership for a particular User  @tag Channel @tag User Minimum server version: 5.6_
- `GetChannelMembersForUser(teamID, userID string, page, perPage int) ([]*model.ChannelMember, *model.AppError)`  
  _GetChannelMembersForUser returns all channel memberships on a team for a user.  @tag Channel @tag User Minimum server version: 5.10_
- `UpdateChannelMemberRoles(channelId, userID, newRoles string) (*model.ChannelMember, *model.AppError)`  
  _UpdateChannelMemberRoles updates a user's roles for a channel.  @tag Channel @tag User Minimum server version: 5.2_
- `UpdateChannelMemberNotifications(channelId, userID string, notifications map[string]string) (*model.ChannelMember, *model.AppError)`  
  _UpdateChannelMemberNotifications updates a user's notification properties for a channel.  @tag Channel @tag User Minimum server version: 5.2_
- `PatchChannelMembersNotifications(members []*model.ChannelMemberIdentifier, notifyProps map[string]string) *model.AppError`  
  _PatchChannelMembersNotifications updates the notification properties for multiple channel members. Other changes made to the channel memberships will be ignored_
- `GetGroup(groupId string) (*model.Group, *model.AppError)`  
  _GetGroup gets a group by ID.  @tag Group Minimum server version: 5.18_
- `GetGroupByName(name string) (*model.Group, *model.AppError)`  
  _GetGroupByName gets a group by name.  @tag Group Minimum server version: 5.18_
- `GetGroupMemberUsers(groupID string, page, perPage int) ([]*model.User, *model.AppError)`  
  _GetGroupMemberUsers gets a page of users belonging to the given group.  @tag Group Minimum server version: 5.35_
- `GetGroupsBySource(groupSource model.GroupSource) ([]*model.Group, *model.AppError)`  
  _GetGroupsBySource gets a list of all groups for the given source.  @tag Group Minimum server version: 5.35_
- `GetGroupsForUser(userID string) ([]*model.Group, *model.AppError)`  
  _GetGroupsForUser gets the groups a user is in.  @tag Group @tag User Minimum server version: 5.18_
- `DeleteChannelMember(channelId, userID string) *model.AppError`  
  _DeleteChannelMember deletes a channel membership for a user.  @tag Channel @tag User Minimum server version: 5.2_
- `CreatePost(post *model.Post) (*model.Post, *model.AppError)`  
  _CreatePost creates a post.  @tag Post Minimum server version: 5.2_
- `AddReaction(reaction *model.Reaction) (*model.Reaction, *model.AppError)`  
  _AddReaction add a reaction to a post.  @tag Post Minimum server version: 5.3_
- `RemoveReaction(reaction *model.Reaction) *model.AppError`  
  _RemoveReaction remove a reaction from a post.  @tag Post Minimum server version: 5.3_
- `GetReactions(postId string) ([]*model.Reaction, *model.AppError)`  
  _GetReaction get the reactions of a post.  @tag Post Minimum server version: 5.3_
- `SendEphemeralPost(userID string, post *model.Post) *model.Post`  
  _SendEphemeralPost creates an ephemeral post.  @tag Post Minimum server version: 5.2_
- `UpdateEphemeralPost(userID string, post *model.Post) *model.Post`  
  _UpdateEphemeralPost updates an ephemeral message previously sent to the user. EXPERIMENTAL: This API is experimental and can be changed without advance notice. _
- `DeleteEphemeralPost(userID, postId string)`  
  _DeleteEphemeralPost deletes an ephemeral message previously sent to the user. EXPERIMENTAL: This API is experimental and can be changed without advance notice. _
- `DeletePost(postId string) *model.AppError`  
  _DeletePost deletes a post.  @tag Post Minimum server version: 5.2_
- `GetPostThread(postId string) (*model.PostList, *model.AppError)`  
  _GetPostThread gets a post with all the other posts in the same thread.  @tag Post Minimum server version: 5.6_
- `GetPost(postId string) (*model.Post, *model.AppError)`  
  _GetPost gets a post.  @tag Post Minimum server version: 5.2_
- `GetPostsSince(channelId string, time int64) (*model.PostList, *model.AppError)`  
  _GetPostsSince gets posts created after a specified time as Unix time in milliseconds.  @tag Post @tag Channel Minimum server version: 5.6_
- `GetPostsAfter(channelId, postId string, page, perPage int) (*model.PostList, *model.AppError)`  
  _GetPostsAfter gets a page of posts that were posted after the post provided.  @tag Post @tag Channel Minimum server version: 5.6_
- `GetPostsBefore(channelId, postId string, page, perPage int) (*model.PostList, *model.AppError)`  
  _GetPostsBefore gets a page of posts that were posted before the post provided.  @tag Post @tag Channel Minimum server version: 5.6_
- `GetPostsForChannel(channelId string, page, perPage int) (*model.PostList, *model.AppError)`  
  _GetPostsForChannel gets a list of posts for a channel.  @tag Post @tag Channel Minimum server version: 5.6_
- `GetTeamStats(teamID string) (*model.TeamStats, *model.AppError)`  
  _GetTeamStats gets a team's statistics  @tag Team Minimum server version: 5.8_
- `UpdatePost(post *model.Post) (*model.Post, *model.AppError)`  
  _UpdatePost updates a post.  @tag Post Minimum server version: 5.2_
- `GetProfileImage(userID string) ([]byte, *model.AppError)`  
  _GetProfileImage gets user's profile image.  @tag User Minimum server version: 5.6_
- `SetProfileImage(userID string, data []byte) *model.AppError`  
  _SetProfileImage sets a user's profile image.  @tag User Minimum server version: 5.6_
- `GetEmojiList(sortBy string, page, perPage int) ([]*model.Emoji, *model.AppError)`  
  _GetEmojiList returns a page of custom emoji on the system.  The sortBy parameter can be: "name".  @tag Emoji Minimum server version: 5.6_
- `GetEmojiByName(name string) (*model.Emoji, *model.AppError)`  
  _GetEmojiByName gets an emoji by it's name.  @tag Emoji Minimum server version: 5.6_
- `GetEmoji(emojiId string) (*model.Emoji, *model.AppError)`  
  _GetEmoji returns a custom emoji based on the emojiId string.  @tag Emoji Minimum server version: 5.6_
- `CopyFileInfos(userID string, fileIds []string) ([]string, *model.AppError)`  
  _CopyFileInfos duplicates the FileInfo objects referenced by the given file ids, recording the given user id as the new creator and returning the new set of file_
- `GetFileInfo(fileId string) (*model.FileInfo, *model.AppError)`  
  _GetFileInfo gets a File Info for a specific fileId  @tag File Minimum server version: 5.3_
- `SetFileSearchableContent(fileID string, content string) *model.AppError`  
  _SetFileSearchableContent update the File Info searchable text for full text search  @tag File Minimum server version: 9.1_
- `GetFileInfos(page, perPage int, opt *model.GetFileInfosOptions) ([]*model.FileInfo, *model.AppError)`  
  _GetFileInfos gets File Infos with options  @tag File Minimum server version: 5.22_
- `GetFile(fileId string) ([]byte, *model.AppError)`  
  _GetFile gets content of a file by it's ID  @tag File Minimum server version: 5.8_
- `GetFileLink(fileId string) (string, *model.AppError)`  
  _GetFileLink gets the public link to a file by fileId.  @tag File Minimum server version: 5.6_
- `ReadFile(path string) ([]byte, *model.AppError)`  
  _ReadFile reads the file from the backend for a specific path  @tag File Minimum server version: 5.3_
- `GetEmojiImage(emojiId string) ([]byte, string, *model.AppError)`  
  _GetEmojiImage returns the emoji image.  @tag Emoji Minimum server version: 5.6_
- `UploadFile(data []byte, channelId string, filename string) (*model.FileInfo, *model.AppError)`  
  _UploadFile will upload a file to a channel using a multipart request, to be later attached to a post.  @tag File @tag Channel Minimum server version: 5.6_
- `OpenInteractiveDialog(dialog model.OpenDialogRequest) *model.AppError`  
  _OpenInteractiveDialog will open an interactive dialog on a user's client that generated the trigger ID. Used with interactive message buttons, menus and slash c_
- `SendToastMessage(userID, connectionID, message string, options model.SendToastMessageOptions) *model.AppError`  
  _SendToastMessage sends a toast notification to a specific user or user session. The userID parameter specifies the user to send the toast to. If connectionID is_
- `GetPlugins() ([]*model.Manifest, *model.AppError)`  
  _GetPlugins will return a list of plugin manifests for currently active plugins.  @tag Plugin Minimum server version: 5.6_
- `EnablePlugin(id string) *model.AppError`  
  _EnablePlugin will enable an plugin installed.  @tag Plugin Minimum server version: 5.6_
- `DisablePlugin(id string) *model.AppError`  
  _DisablePlugin will disable an enabled plugin.  @tag Plugin Minimum server version: 5.6_
- `RemovePlugin(id string) *model.AppError`  
  _RemovePlugin will disable and delete a plugin.  @tag Plugin Minimum server version: 5.6_
- `GetPluginStatus(id string) (*model.PluginStatus, *model.AppError)`  
  _GetPluginStatus will return the status of a plugin.  @tag Plugin Minimum server version: 5.6_
- `InstallPlugin(file io.Reader, replace bool) (*model.Manifest, *model.AppError)`  
  _InstallPlugin will upload another plugin with tar.gz file. Previous version will be replaced on replace true.  @tag Plugin Minimum server version: 5.18_
- `KVSet(key string, value []byte) *model.AppError`  
  _KVSet stores a key-value pair, unique per plugin. Provided helper functions and internal plugin code will use the prefix `mmi_` before keys. Do not use this pre_
- `KVCompareAndSet(key string, oldValue, newValue []byte) (bool, *model.AppError)`  
  _KVCompareAndSet updates a key-value pair, unique per plugin, but only if the current value matches the given oldValue. Inserts a new key if oldValue == nil. Ret_
- `KVCompareAndDelete(key string, oldValue []byte) (bool, *model.AppError)`  
  _KVCompareAndDelete deletes a key-value pair, unique per plugin, but only if the current value matches the given oldValue. Returns (false, err) if DB error occur_
- `KVSetWithOptions(key string, value []byte, options model.PluginKVSetOptions) (bool, *model.AppError)`  
  _KVSetWithOptions stores a key-value pair, unique per plugin, according to the given options. Returns (false, err) if DB error occurred Returns (false, nil) if t_
- `KVSetWithExpiry(key string, value []byte, expireInSeconds int64) *model.AppError`  
  _KVSet stores a key-value pair with an expiry time, unique per plugin.  @tag KeyValueStore Minimum server version: 5.6_
- `KVGet(key string) ([]byte, *model.AppError)`  
  _KVGet retrieves a value based on the key, unique per plugin. Returns nil for non-existent keys.  @tag KeyValueStore Minimum server version: 5.2_
- `KVDelete(key string) *model.AppError`  
  _KVDelete removes a key-value pair, unique per plugin. Returns nil for non-existent keys.  @tag KeyValueStore Minimum server version: 5.2_
- `KVDeleteAll() *model.AppError`  
  _KVDeleteAll removes all key-value pairs for a plugin.  @tag KeyValueStore Minimum server version: 5.6_
- `KVList(page, perPage int) ([]string, *model.AppError)`  
  _KVList lists all keys for a plugin.  @tag KeyValueStore Minimum server version: 5.6_
- `PublishWebSocketEvent(event string, payload map[string]any, broadcast *model.WebsocketBroadcast)`  
  _PublishWebSocketEvent sends an event to WebSocket connections. event is the type and will be prepended with "custom_<pluginid>_". payload is the data sent with _
- `HasPermissionTo(userID string, permission *model.Permission) bool`  
  _HasPermissionTo check if the user has the permission at system scope.  @tag User Minimum server version: 5.3_
- `HasPermissionToTeam(userID, teamID string, permission *model.Permission) bool`  
  _HasPermissionToTeam check if the user has the permission at team scope.  @tag User @tag Team Minimum server version: 5.3_
- `HasPermissionToChannel(userID, channelId string, permission *model.Permission) bool`  
  _HasPermissionToChannel check if the user has the permission at channel scope.  @tag User @tag Channel Minimum server version: 5.3_
- `RolesGrantPermission(roleNames []string, permissionId string) bool`  
  _RolesGrantPermission check if the specified roles grant the specified permission  Minimum server version: 6.3_
- `LogDebug(msg string, keyValuePairs ...any)`  
  _LogDebug writes a log message to the Mattermost server log file. Appropriate context such as the plugin name will already be added as fields so plugins do not n_
- `LogInfo(msg string, keyValuePairs ...any)`  
  _LogInfo writes a log message to the Mattermost server log file. Appropriate context such as the plugin name will already be added as fields so plugins do not ne_
- `LogError(msg string, keyValuePairs ...any)`  
  _LogError writes a log message to the Mattermost server log file. Appropriate context such as the plugin name will already be added as fields so plugins do not n_
- `LogWarn(msg string, keyValuePairs ...any)`  
  _LogWarn writes a log message to the Mattermost server log file. Appropriate context such as the plugin name will already be added as fields so plugins do not ne_
- `SendMail(to, subject, htmlBody string) *model.AppError`  
  _SendMail sends an email to a specific address  Minimum server version: 5.7_
- `CreateBot(bot *model.Bot) (*model.Bot, *model.AppError)`  
  _CreateBot creates the given bot and corresponding user.  @tag Bot Minimum server version: 5.10_
- `PatchBot(botUserId string, botPatch *model.BotPatch) (*model.Bot, *model.AppError)`  
  _PatchBot applies the given patch to the bot and corresponding user.  @tag Bot Minimum server version: 5.10_
- `GetBot(botUserId string, includeDeleted bool) (*model.Bot, *model.AppError)`  
  _GetBot returns the given bot.  @tag Bot Minimum server version: 5.10_
- `GetBots(options *model.BotGetOptions) ([]*model.Bot, *model.AppError)`  
  _GetBots returns the requested page of bots.  @tag Bot Minimum server version: 5.10_
- `UpdateBotActive(botUserId string, active bool) (*model.Bot, *model.AppError)`  
  _UpdateBotActive marks a bot as active or inactive, along with its corresponding user.  @tag Bot Minimum server version: 5.10_
- `PermanentDeleteBot(botUserId string) *model.AppError`  
  _PermanentDeleteBot permanently deletes a bot and its corresponding user.  @tag Bot Minimum server version: 5.10_
- `PluginHTTP(request *http.Request) *http.Response`  
  _PluginHTTP allows inter-plugin requests to plugin APIs.  Minimum server version: 5.18_
- `PublishUserTyping(userID, channelId, parentId string) *model.AppError`  
  _PublishUserTyping publishes a user is typing WebSocket event. The parentId parameter may be an empty string, the other parameters are required.  @tag User Minim_
- `CreateCommand(cmd *model.Command) (*model.Command, error)`  
  _CreateCommand creates a server-owned slash command that is not handled by the plugin itself, and which will persist past the life of the plugin. The command wil_
- `ListCommands(teamID string) ([]*model.Command, error)`  
  _ListCommands returns the list of all slash commands for teamID. E.g., custom commands (those created through the integrations menu, the REST api, or the plugin _
- `ListCustomCommands(teamID string) ([]*model.Command, error)`  
  _ListCustomCommands returns the list of slash commands for teamID that where created through the integrations menu, the REST api, or the plugin api CreateCommand_
- `ListPluginCommands(teamID string) ([]*model.Command, error)`  
  _ListPluginCommands returns the list of slash commands for teamID that were created with the plugin api RegisterCommand.  @tag SlashCommand Minimum server versio_
- `ListBuiltInCommands() ([]*model.Command, error)`  
  _ListBuiltInCommands returns the list of slash commands that are builtin commands (those added internally through RegisterCommandProvider).  @tag SlashCommand Mi_
- `GetCommand(commandID string) (*model.Command, error)`  
  _GetCommand returns the command definition based on a command id string.  @tag SlashCommand Minimum server version: 5.28_
- `UpdateCommand(commandID string, updatedCmd *model.Command) (*model.Command, error)`  
  _UpdateCommand updates a single command (commandID) with the information provided in the updatedCmd model.Command struct. The following fields in the command can_
- `DeleteCommand(commandID string) error`  
  _DeleteCommand deletes a slash command (commandID).  @tag SlashCommand Minimum server version: 5.28_
- `CreateOAuthApp(app *model.OAuthApp) (*model.OAuthApp, *model.AppError)`  
  _CreateOAuthApp creates a new OAuth App.  @tag OAuth Minimum server version: 5.38_
- `GetOAuthApp(appID string) (*model.OAuthApp, *model.AppError)`  
  _GetOAuthApp gets an existing OAuth App by id.  @tag OAuth Minimum server version: 5.38_
- `UpdateOAuthApp(app *model.OAuthApp) (*model.OAuthApp, *model.AppError)`  
  _UpdateOAuthApp updates an existing OAuth App.  @tag OAuth Minimum server version: 5.38_
- `DeleteOAuthApp(appID string) *model.AppError`  
  _DeleteOAuthApp deletes an existing OAuth App by id.  @tag OAuth Minimum server version: 5.38_
- `PublishPluginClusterEvent(ev model.PluginClusterEvent, opts model.PluginClusterEventSendOptions) error`  
  _PublishPluginClusterEvent broadcasts a plugin event to all other running instances of the calling plugin that are present in the cluster.  This method is used t_
- `RequestTrialLicense(requesterID string, users int, termsAccepted bool, receiveEmailsAccepted bool) *model.AppError`  
  _RequestTrialLicense requests a trial license and installs it in the server  Minimum server version: 5.36_
- `GetCloudLimits() (*model.ProductLimits, error)`  
  _GetCloudLimits gets limits associated with a cloud workspace, if any  Minimum server version: 7.0_
- `EnsureBotUser(bot *model.Bot) (string, error)`  
  _EnsureBotUser updates the bot if it exists, otherwise creates it.  Minimum server version: 7.1_
- `RegisterCollectionAndTopic(collectionType, topicType string) error`  
  _RegisterCollectionAndTopic is no longer supported.  Minimum server version: 7.6_
- `CreateUploadSession(us *model.UploadSession) (*model.UploadSession, error)`  
  _CreateUploadSession creates and returns a new (resumable) upload session.  @tag Upload Minimum server version: 7.6_
- `UploadData(us *model.UploadSession, rd io.Reader) (*model.FileInfo, error)`  
  _UploadData uploads the data for a given upload session.  @tag Upload Minimum server version: 7.6_
- `GetUploadSession(uploadID string) (*model.UploadSession, error)`  
  _GetUploadSession returns the upload session for the provided id.  @tag Upload Minimum server version: 7.6_
- `SendPushNotification(notification *model.PushNotification, userID string) *model.AppError`  
  _SendPushNotification will send a push notification to all of user's sessions.  It is the responsibility of the plugin to respect the server's configuration and _
- `UpdateUserAuth(userID string, userAuth *model.UserAuth) (*model.UserAuth, *model.AppError)`  
  _UpdateUserAuth updates a user's auth data.  It is not currently possible to use this to set a user's auth to e-mail with a hashed password. It is meant to be us_
- `RegisterPluginForSharedChannels(opts model.RegisterPluginOpts) (remoteID string, err error)`  
  _RegisterPluginForSharedChannels registers the plugin as a `Remote` for SharedChannels. The plugin will receive synchronization messages via the `OnSharedChannel_
- `UnregisterPluginForSharedChannels(pluginID string) error`  
  _UnregisterPluginForSharedChannels unregisters all remotes for this plugin. The plugin will no longer receive synchronization messages via the `OnSharedChannelsS_
- `UnregisterPluginRemoteForSharedChannels(remoteID string) error`  
  _UnregisterPluginRemoteForSharedChannels unregisters a specific remote by its remoteID. The remote must belong to the calling plugin (ownership is validated serv_
- `ShareChannel(sc *model.SharedChannel) (*model.SharedChannel, error)`  
  _ShareChannel marks a channel for sharing via shared channels. Note, this does not automatically invite any remote clusters to the channel - use `InviteRemote` t_
- `UpdateSharedChannel(sc *model.SharedChannel) (*model.SharedChannel, error)`  
  _UpdateSharedChannel updates a shared channel. This can be used to change the share name, display name, purpose, header, etc.  @tag SharedChannels Minimum server_
- `UnshareChannel(channelID string) (unshared bool, err error)`  
  _UnshareChannel unmarks a channel for sharing. The channel will no longer be shared and all remotes will be uninvited to the channel.  @tag SharedChannels Minimu_
- `UpdateSharedChannelCursor(channelID, remoteID string, cusror model.GetPostsSinceForSyncCursor) error`  
  _UpdateSharedChannelCursor updates the cursor for the specified channel and RemoteID (passed by the plugin when registering).  This can be used to manually set t_
- `SyncSharedChannel(channelID string) error`  
  _SyncSharedChannel forces a shared channel to send any changed content to all remotes.  @tag SharedChannels Minimum server version: 9.5_
- `InviteRemoteToChannel(channelID string, remoteID string, userID string, shareIfNotShared bool) error`  
  _InviteRemoteToChannel invites a remote, or this plugin, as a target for synchronizing. Once invited, the remote will start to receive synchronization messages f_
- `UninviteRemoteFromChannel(channelID string, remoteID string) error`  
  _UninviteRemoteFromChannel uninvites a remote, or this plugin, such that it will stop receiving sychronization messages for the channel.  @tag SharedChannels Min_
- `ReceiveSharedChannelSyncMsg(remoteID string, msg *model.SyncMsg) (model.SyncResponse, error)`  
  _ReceiveSharedChannelSyncMsg processes a sync message from this plugin, creating or updating posts, reactions, users, statuses, acknowledgements, and membership _
- `ReceiveSharedChannelAttachmentSyncMsg(remoteID, channelID string, fi *model.FileInfo, data io.Reader) (*model.FileInfo, error)`  
  _ReceiveSharedChannelAttachmentSyncMsg syncs a file attachment into a shared channel. The FileInfo provides metadata (Name, Size, CreatorId); the server construc_
- `ReceiveSharedChannelProfileImageSyncMsg(remoteID, userID string, image []byte) error`  
  _ReceiveSharedChannelProfileImageSyncMsg syncs a user's profile image from this plugin's remote into Mattermost. The user must have a RemoteId matching the speci_
- `UpsertGroupMember(groupID string, userID string) (*model.GroupMember, *model.AppError)`  
  _UpsertGroupMember adds a user to a group or updates their existing membership.  @tag Group @tag User Minimum server version: 10.7_
- `UpsertGroupMembers(groupID string, userIDs []string) ([]*model.GroupMember, *model.AppError)`  
  _UpsertGroupMembers adds multiple users to a group or updates their existing memberships.  @tag Group @tag User Minimum server version: 10.7_
- `GetGroupByRemoteID(remoteID string, groupSource model.GroupSource) (*model.Group, *model.AppError)`  
  _GetGroupByRemoteID gets a group by its remote ID.  @tag Group Minimum server version: 10.7_
- `CreateGroup(group *model.Group) (*model.Group, *model.AppError)`  
  _CreateGroup creates a new group.  @tag Group Minimum server version: 10.7_
- `UpdateGroup(group *model.Group) (*model.Group, *model.AppError)`  
  _UpdateGroup updates a group.  @tag Group Minimum server version: 10.7_
- `DeleteGroup(groupID string) (*model.Group, *model.AppError)`  
  _DeleteGroup soft deletes a group.  @tag Group Minimum server version: 10.7_
- `RestoreGroup(groupID string) (*model.Group, *model.AppError)`  
  _RestoreGroup restores a soft deleted group.  @tag Group Minimum server version: 10.7_
- `DeleteGroupMember(groupID string, userID string) (*model.GroupMember, *model.AppError)`  
  _DeleteGroupMember removes a user from a group.  @tag Group @tag User Minimum server version: 10.7_
- `GetGroupSyncable(groupID string, syncableID string, syncableType model.GroupSyncableType) (*model.GroupSyncable, *model.AppError)`  
  _GetGroupSyncable gets a group syncable.  @tag Group Minimum server version: 10.7_
- `GetGroupSyncables(groupID string, syncableType model.GroupSyncableType) ([]*model.GroupSyncable, *model.AppError)`  
  _GetGroupSyncables gets all group syncables for the given group.  @tag Group Minimum server version: 10.7_
- `UpsertGroupSyncable(groupSyncable *model.GroupSyncable) (*model.GroupSyncable, *model.AppError)`  
  _UpsertGroupSyncable creates or updates a group syncable.  @tag Group Minimum server version: 10.7_
- `UpdateGroupSyncable(groupSyncable *model.GroupSyncable) (*model.GroupSyncable, *model.AppError)`  
  _UpdateGroupSyncable updates a group syncable.  @tag Group Minimum server version: 10.7_
- `DeleteGroupSyncable(groupID string, syncableID string, syncableType model.GroupSyncableType) (*model.GroupSyncable, *model.AppError)`  
  _DeleteGroupSyncable deletes a group syncable.  @tag Group Minimum server version: 10.7_
- `UpdateUserRoles(userID, newRoles string) (*model.User, *model.AppError)`  
  _UpdateUserRoles updates the role for a user.  @tag Team @tag User Minimum server version: 9.8_
- `GetPluginID() string`  
  _GetPluginID returns the plugin ID.  @tag Plugin Minimum server version: 10.1_
- `GetGroups(page, perPage int, opts model.GroupSearchOpts, viewRestrictions *model.ViewUsersRestrictions) ([]*model.Group, *model.AppError)`  
  _GetGroups returns a list of all groups with the given options and restrictions.  @tag Group Minimum server version: 10.7_
- `CreateDefaultSyncableMemberships(params model.CreateDefaultMembershipParams) *model.AppError`  
  _CreateDefaultSyncableMemberships creates default syncable memberships based off the provided parameters.  @tag Group Minimum server version: 10.9_
- `DeleteGroupConstrainedMemberships() *model.AppError`  
  _DeleteGroupConstrainedMemberships deletes team and channel memberships of users who aren't members of the allowed groups of all group-constrained teams and chan_
- `CreatePropertyField(field *model.PropertyField) (*model.PropertyField, error)`  
  _CreatePropertyField creates a new property field.  If the field's LinkedFieldID is set, the field inherits type, options, and security attributes from the refer_
- `GetPropertyField(groupID, fieldID string) (*model.PropertyField, error)`  
  _GetPropertyField gets a property field by groupID and fieldID.  @tag PropertyField Minimum server version: 10.10_
- `GetPropertyFields(groupID string, ids []string) ([]*model.PropertyField, error)`  
  _GetPropertyFields gets multiple property fields by groupID and a list of IDs.  @tag PropertyField Minimum server version: 10.10_
- `UpdatePropertyField(groupID string, field *model.PropertyField) (*model.PropertyField, error)`  
  _UpdatePropertyField updates an existing property field.  Fields with a LinkedFieldID cannot have their type or options modified. Set LinkedFieldID to an empty s_
- `DeletePropertyField(groupID, fieldID string) error`  
  _DeletePropertyField deletes a property field (soft delete).  Returns an error if the field has active linked dependents. Unlink or delete dependent fields first_
- `SearchPropertyFields(groupID string, opts model.PropertyFieldSearchOpts) ([]*model.PropertyField, error)`  
  _SearchPropertyFields searches for property fields with filtering options.  @tag PropertyField Minimum server version: 11.0_
- `CountPropertyFields(groupID string, includeDeleted bool) (int64, error)`  
  _CountPropertyFields counts property fields for a group.  @tag PropertyField Minimum server version: 11.0_
- `CountPropertyFieldsForTarget(groupID, targetType, targetID string, includeDeleted bool) (int64, error)`  
  _CountPropertyFieldsForTarget counts property fields for a specific target.  @tag PropertyField Minimum server version: 11.0_
- `CreatePropertyValue(value *model.PropertyValue) (*model.PropertyValue, error)`  
  _CreatePropertyValue creates a new property value.  @tag PropertyValue Minimum server version: 10.10_
- `GetPropertyValue(groupID, valueID string) (*model.PropertyValue, error)`  
  _GetPropertyValue gets a property value by groupID and valueID.  @tag PropertyValue Minimum server version: 10.10_
- `GetPropertyValues(groupID string, ids []string) ([]*model.PropertyValue, error)`  
  _GetPropertyValues gets multiple property values by groupID and a list of IDs.  @tag PropertyValue Minimum server version: 10.10_
- `UpdatePropertyValue(groupID string, value *model.PropertyValue) (*model.PropertyValue, error)`  
  _UpdatePropertyValue updates an existing property value.  @tag PropertyValue Minimum server version: 10.10_
- `UpsertPropertyValue(value *model.PropertyValue) (*model.PropertyValue, error)`  
  _UpsertPropertyValue creates a new property value or updates if it already exists.  @tag PropertyValue Minimum server version: 10.10_
- `DeletePropertyValue(groupID, valueID string) error`  
  _DeletePropertyValue deletes a property value (soft delete).  @tag PropertyValue Minimum server version: 10.10_
- `SearchPropertyValues(groupID string, opts model.PropertyValueSearchOpts) ([]*model.PropertyValue, error)`  
  _SearchPropertyValues searches for property values with filtering options.  @tag PropertyValue Minimum server version: 11.0_
- `RegisterPropertyGroup(name string) (*model.PropertyGroup, error)`  
  _RegisterPropertyGroup registers a new property group.  @tag PropertyGroup Minimum server version: 10.10_
- `GetPropertyGroup(name string) (*model.PropertyGroup, error)`  
  _GetPropertyGroup gets a property group by name.  @tag PropertyGroup Minimum server version: 10.10_
- `GetPropertyFieldByName(groupID, targetID, name string) (*model.PropertyField, error)`  
  _GetPropertyFieldByName gets a property field by groupID, targetID and name.  @tag PropertyField Minimum server version: 10.10_
- `UpdatePropertyFields(groupID string, fields []*model.PropertyField) ([]*model.PropertyField, error)`  
  _UpdatePropertyFields updates multiple property fields in a single operation.  @tag PropertyField Minimum server version: 10.10_
- `UpdatePropertyValues(groupID string, values []*model.PropertyValue) ([]*model.PropertyValue, error)`  
  _UpdatePropertyValues updates multiple property values in a single operation.  @tag PropertyValue Minimum server version: 10.10_
- `UpsertPropertyValues(values []*model.PropertyValue) ([]*model.PropertyValue, error)`  
  _UpsertPropertyValues creates or updates multiple property values in a single operation.  @tag PropertyValue Minimum server version: 10.10_
- `DeletePropertyValuesForTarget(groupID, targetType, targetID string) error`  
  _DeletePropertyValuesForTarget deletes all property values for a specific target.  @tag PropertyValue Minimum server version: 10.10_
- `DeletePropertyValuesForField(groupID, fieldID string) error`  
  _DeletePropertyValuesForField deletes all property values for a specific field.  @tag PropertyValue Minimum server version: 10.10_
- `LogAuditRec(rec *model.AuditRecord)`  
  _LogAuditRec logs an audit record using the default audit logger.  @tag Audit Minimum server version: 10.10_
- `LogAuditRecWithLevel(rec *model.AuditRecord, level mlog.Level)`  
  _LogAuditRecWithLevel logs an audit record with a specific log level.  @tag Audit Minimum server version: 10.10_


<!-- ============================================================ -->
## FILE: `scripts/bootstrap.sh`

```
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
```


<!-- ============================================================ -->
## FILE: `scripts/build-reference.py`

```
#!/usr/bin/env python3
"""
build-reference.py — Extract authoritative contract catalogs from the pinned Mattermost
source clone, so the implementing agent searches facts instead of guessing them.

Generates, under reference/:
  config-env-map.md   — every MM_* env var (from server/public/model/config.go)
  plugin-api.md       — the plugin API surface (from server/public/plugin/api.go)
  mmctl-commands.md   — the mmctl CLI command catalog
  endpoints.md        — REST API endpoint catalog (from api/v4/source/*.yaml)

Usage:  python3 scripts/build-reference.py [SRC_DIR] [OUT_DIR]
  SRC_DIR default: ~/mattermost-src/mattermost   OUT_DIR default: ./reference
"""
import os, re, sys, glob

SRC = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else "~/mattermost-src/mattermost")
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(__file__), "..", "reference")
OUT = os.path.abspath(OUT)
os.makedirs(OUT, exist_ok=True)

def banner(f, title, src):
    f.write(f"# {title}\n\n")
    f.write("> AUTO-GENERATED by `scripts/build-reference.py` — do not edit by hand.\n")
    f.write(f"> Source of truth: `{src}`\n")
    f.write("> Regenerate after pinning the source to your `MM_VERSION`.\n\n")

# ---------- 1. config -> env var map ----------
def build_config():
    path = os.path.join(SRC, "server/public/model/config.go")
    text = open(path, encoding="utf-8", errors="replace").read()
    # capture every `type X struct { ... }`
    structs = {}
    for m in re.finditer(r"^type (\w+) struct \{\n(.*?)^\}", text, re.S | re.M):
        name, body = m.group(1), m.group(2)
        fields = []
        for line in body.splitlines():
            fm = re.match(r"\s+([A-Z]\w*)\s+(\*?[\w\.\[\]]+)(?:\s+`([^`]*)`)?", line)
            if fm:
                fname, ftype, tag = fm.group(1), fm.group(2), fm.group(3) or ""
                jm = re.search(r'json:"([^",]+)', tag)
                fields.append((fname, ftype, jm.group(1) if jm else ""))
        structs[name] = fields
    if "Config" not in structs:
        return 0
    out = open(os.path.join(OUT, "config-env-map.md"), "w", encoding="utf-8")
    banner(out, "Config → MM_* Environment Variable Map", "server/public/model/config.go")
    out.write("Mattermost maps `Config.<Section>.<Field>` to env var `MM_<SECTION>_<FIELD>` (uppercased).\n")
    out.write("Use these EXACT names in `.env`/compose. Deeper nested structs add further `_<FIELD>` levels.\n\n")
    count = 0
    for sect, stype, _ in structs["Config"]:
        base = stype.lstrip("*")
        if base not in structs:
            continue
        out.write(f"## MM_{sect.upper()}  (`{base}`)\n\n")
        out.write("| Env var | Go type | json key |\n|---|---|---|\n")
        for fname, ftype, jkey in structs[base]:
            out.write(f"| `MM_{sect.upper()}_{fname.upper()}` | {ftype} | {jkey} |\n")
            count += 1
        out.write("\n")
    out.close()
    return count

# ---------- 2. plugin API ----------
def build_plugin():
    path = os.path.join(SRC, "server/public/plugin/api.go")
    if not os.path.exists(path):
        return 0
    text = open(path, encoding="utf-8", errors="replace").read()
    out = open(os.path.join(OUT, "plugin-api.md"), "w", encoding="utf-8")
    banner(out, "Plugin API Surface", "server/public/plugin/api.go")
    out.write("Methods available to a server plugin via `plugin.API`. Used by GOAL-06 (AI translation).\n\n")
    count = 0
    cur_doc = []
    for line in text.splitlines():
        dm = re.match(r"\s*//\s?(.*)", line)
        mm = re.match(r"\s+([A-Z]\w+)\((.*?)\)(.*)", line)
        if dm and mm is None:
            cur_doc.append(dm.group(1))
        elif mm:
            sig = f"{mm.group(1)}({mm.group(2)}){mm.group(3)}".strip()
            doc = " ".join(cur_doc)[:160]
            out.write(f"- `{sig}`" + (f"  \n  _{doc}_" if doc else "") + "\n")
            count += 1
            cur_doc = []
        else:
            cur_doc = []
    out.close()
    return count

# ---------- 3. mmctl commands ----------
def build_mmctl():
    files = glob.glob(os.path.join(SRC, "server/cmd/mmctl/commands/*.go"))
    out = open(os.path.join(OUT, "mmctl-commands.md"), "w", encoding="utf-8")
    banner(out, "mmctl Command Catalog", "server/cmd/mmctl/commands/*.go")
    out.write("Cobra commands (`Use` / `Short`). Used by all provisioning/branding/plugin scripts.\n\n")
    out.write("| Use | Short |\n|---|---|\n")
    count = 0
    for fp in sorted(files):
        t = open(fp, encoding="utf-8", errors="replace").read()
        uses = re.findall(r'Use:\s*"([^"]+)"', t)
        shorts = re.findall(r'Short:\s*"([^"]+)"', t)
        for i, u in enumerate(uses):
            s = shorts[i] if i < len(shorts) else ""
            out.write(f"| `{u}` | {s} |\n")
            count += 1
    out.close()
    return count

# ---------- 4. REST endpoints ----------
def build_endpoints():
    files = glob.glob(os.path.join(SRC, "api/v4/source/*.yaml"))
    out = open(os.path.join(OUT, "endpoints.md"), "w", encoding="utf-8")
    banner(out, "REST API v4 Endpoint Catalog", "api/v4/source/*.yaml (OpenAPI)")
    out.write("Endpoint summary. Full request/response schema: see the source YAML or the Redoc render.\n\n")
    out.write("| Method | Path | operationId | Summary |\n|---|---|---|---|\n")
    count = 0
    path_re = re.compile(r"^  (/api/v4/\S+):\s*$")
    meth_re = re.compile(r"^    (get|post|put|delete|patch):\s*$")
    for fp in sorted(files):
        lines = open(fp, encoding="utf-8", errors="replace").read().splitlines()
        cur_path = None
        for i, line in enumerate(lines):
            pm = path_re.match(line)
            if pm:
                cur_path = pm.group(1); continue
            mm = meth_re.match(line)
            if mm and cur_path:
                method = mm.group(1).upper()
                blk = "\n".join(lines[i:i+25])
                summ = re.search(r"summary:\s*(.+)", blk)
                opid = re.search(r"operationId:\s*(\w+)", blk)
                out.write(f"| {method} | `{cur_path}` | {opid.group(1) if opid else ''} | {(summ.group(1).strip() if summ else '')[:80]} |\n")
                count += 1
    out.close()
    return count

print("config env vars :", build_config())
print("plugin methods  :", build_plugin())
print("mmctl commands  :", build_mmctl())
print("rest endpoints  :", build_endpoints())
print("written to      :", OUT)
```


<!-- ============================================================ -->
## FILE: `scripts/index-docs.sh`

```
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
```


<!-- ============================================================ -->
## FILE: `scripts/make-bundle.sh`

```
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
```


<!-- ============================================================ -->
## FILE: `sources.lock`

```
# sources.lock — pinned upstream Mattermost sources for byte-identical reproduction.
# Format: <name> <git-url> <commit-sha> <branch-at-capture>
# Captured 2026-06-28 (currently tracking master/main HEADs; GOAL-PREP re-pins to release-<MM_VERSION>).
# bootstrap.sh clones each at the EXACT sha → every device gets the identical source state.
# We pin (not vendor) on purpose: re-hosting Mattermost source — esp. server/enterprise (Source
# Available License) — is forbidden and bloats the repo. See docs/06-REPRODUCE-ON-NEW-DEVICE.md.

# --- core (required for the reference environment + build) ---
mattermost                          https://github.com/mattermost/mattermost.git                          1efe1aa9bb2e656ecdcf457e2d1b554e4d329d0c  master
docs                                https://github.com/mattermost/docs.git                                aa696711bdff9e0cff3473be0ac02bf5be3e715a  master
mattermost-developer-documentation  https://github.com/mattermost/mattermost-developer-documentation.git  dca0a0a56212e3e21c309766df35f932909729ef  master
mattermost-api-reference            https://github.com/mattermost/mattermost-api-reference.git            a00af94dab63e9af3adc4a05e279a84ae73908d8  master
mattermost-plugin-calls             https://github.com/mattermost/mattermost-plugin-calls.git             81f2ed8c7d0f0e01d1ab509d6475113d3708d627  main
mattermost-plugin-playbooks         https://github.com/mattermost/mattermost-plugin-playbooks.git         cbe3d195f7d94bb13903191306793b15e512845a  master
mattermost-plugin-boards            https://github.com/mattermost/mattermost-plugin-boards.git            d4543276476b7fa6ff8ab57773746861a42e183d  main

# --- optional (custom mobile/desktop phase; skipped when CORE_ONLY=1) ---
mattermost-mobile                   https://github.com/mattermost/mattermost-mobile.git                   c1bd1eae7d127f309a0916e0285e8ccd8539c670  main
desktop                             https://github.com/mattermost/desktop.git                             098f4d0f130d3e5944152d98557f59d91b9e16cd  master
```


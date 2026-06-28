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

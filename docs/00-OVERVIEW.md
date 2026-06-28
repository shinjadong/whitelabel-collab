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

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

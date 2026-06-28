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

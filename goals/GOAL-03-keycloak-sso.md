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

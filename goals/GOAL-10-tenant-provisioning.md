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

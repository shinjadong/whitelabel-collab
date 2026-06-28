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

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

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

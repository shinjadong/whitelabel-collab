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

# GOAL-06 — AI translation bot (Ollama-backed) — reproduces EE autotranslation (#6)

**GOAL:** Build a small **custom Mattermost plugin** (or bot) that auto-translates messages on demand
using **our own Ollama** inference — reproducing EE "autotranslation" with zero SaaS cost and as a
product differentiator.

## WHY
EE's autotranslation (#6) is reproducible as a plugin because the plugin API exposes message events and
posting. Running it on **our** Ollama (already on Vhagar) means no per-message API cost, full data
sovereignty, and a feature the client can't get from raw Slack/Teams cheaply. This is where the
white-label product stops being "just Mattermost" and starts being **our** platform.

## CONTEXT
- Plugin API: a server plugin can implement `MessageHasBeenPosted` (or expose a slash command
  `/translate`) and call `CreatePost`/`UpdatePost` or post an ephemeral translation.
- Inference: HTTP to `${OLLAMA_BASE_URL}` (`/api/generate` or `/api/chat`) with `${OLLAMA_MODEL}`.
- Reference: starter template at `~/mattermost-src/mattermost-plugin-*` shows plugin structure; the
  official starter is `mattermost/mattermost-plugin-starter-template`.
- Default UX (pick one, document choice): (a) **on-demand** via `/translate <lang>` or a post action
  menu (lower noise, recommended), or (b) **auto** per-channel target-language translation as a reply.
- Ollama is **shared**, external to the client stack — reachable over the private/Tailscale network,
  not exposed publicly. Multiple client stacks can share one Ollama.

## PREREQUISITES
- GOAL-01 (plugin uploads + bot accounts enabled). Reachable Ollama at `${OLLAMA_BASE_URL}`.

## DELIVERABLES
```
plugins/ai-translate/                 # plugin source (Go server plugin; optional webapp action)
plugins/ai-translate/plugin.json      # id, version, settings schema (target langs, model, base url)
scripts/build-and-install-translate.sh# build bundle, mmctl plugin add + enable + configure
docs-notes/ai-translate.md            # UX choice, prompt, model, ops, privacy note
```

### Plugin behavior (MVP)
- Slash command `/translate <target-lang>` translates the message it replies to (or last message),
  posting the result as an ephemeral or threaded reply attributed to a bot.
- Settings (System Console, from plugin.json): `OllamaBaseURL`, `Model`, `DefaultTargetLang`,
  `AllowedChannels` (optional).
- Robustness: timeout + graceful "translation unavailable" on Ollama error; never block message posting.

## STEPS
1. Scaffold from the starter template; set plugin id `com.balerion.ai-translate` (internal id ok; **no
   codename in user-visible text** — bot display name is client-neutral, e.g. "Translator").
2. Implement the Ollama call (chat/generate) with a clear translation prompt; parse and post the result.
3. Expose settings via `plugin.json`; read `${OLLAMA_BASE_URL}`/`${OLLAMA_MODEL}` defaults from config.
4. Build the bundle; `scripts/build-and-install-translate.sh` installs + enables + configures it.
5. Test: `/translate en` on a Korean message returns an English translation in seconds.
6. Document prompt, model, latency, failure behavior, and the **privacy note** (messages sent to our
   self-hosted Ollama only — no third-party) in `docs-notes/ai-translate.md`.

## ACCEPTANCE CRITERIA
- [ ] `/translate <lang>` returns a correct translation via Ollama within a few seconds.
- [ ] Ollama outage → graceful failure message; normal messaging unaffected.
- [ ] Bot display name + all user-visible text are client-neutral (no internal codename, no "Mattermost").
- [ ] Settings configurable in System Console; defaults from `.env`.
- [ ] Plugin is a separate work via the plugin API; core unmodified.

## GOTCHAS
- Don't translate every message by default — noisy and costly. On-demand is the recommended MVP UX.
- Keep Ollama private (Tailscale/internal); never expose it through Caddy.
- Internal plugin id may contain a codename, but **nothing the end user sees** may (per branding hygiene,
  `../docs/00-OVERVIEW.md` §6).
- This goal is **value-add / optional** — not on the MVP critical path.

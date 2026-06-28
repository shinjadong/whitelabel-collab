# GOAL-05 — Feature plugins: Calls, Playbooks, Boards

**GOAL:** Install and enable the official **Calls** (voice/video), **Playbooks** (runbooks/checklists),
and **Boards** (kanban) plugins on Team Edition — features that used to be Enterprise — for free.

## WHY
These three plugins deliver high-visible product value (huddles, incident playbooks, project boards) and
run fine on Team Edition. They're separate, openly-licensed plugin bundles installed via the plugin API —
no core modification, no EE license. Installing them headlessly and pinning versions makes every client
stack reproducible.

## CONTEXT
- Install method: `mmctl plugin marketplace install <id> <version>` (online) **or** upload a pinned
  bundle with `mmctl plugin add <file.tar.gz>`, then `mmctl plugin enable <id>`.
- Plugin state lives in config under `PluginSettings.PluginStates.<id>.Enable`; per-plugin config under
  `PluginSettings.Plugins.<id>`. After changes: `mmctl config reload`.
- Local clones for reference/build if marketplace is unavailable:
  `~/mattermost-src/mattermost-plugin-calls`, `-playbooks`, `-boards`.
- Plugin IDs: Calls=`com.mattermost.calls`, Playbooks=`playbooks`, Boards=`focalboard`/`boards`
  (confirm exact IDs from each plugin's `plugin.json` in the reference clones at build time).
- `mmctl --local` works because GOAL-01 set `ENABLELOCALMODE=true`.
- Calls needs a reachable RTC port/host config for media; set the call's `ICEHostOverride`/port per the
  plugin docs and ensure Caddy/host firewall allows the RTC UDP port (document it).

## PREREQUISITES
- GOAL-01 (MM up, `PluginSettings.Enable=true`, uploads enabled, local mode on).

## DELIVERABLES
```
scripts/install-plugins.sh           # idempotent: install + pin + enable + configure the 3 plugins
compose/plugins.versions.env         # pinned plugin versions (sourced into .env)
docs-notes/plugins.md                # IDs, versions, RTC/port notes, how to add more plugins
```

## STEPS
1. Determine exact plugin IDs + latest stable versions (from marketplace or each `plugin.json`); record
   in `compose/plugins.versions.env`.
2. `scripts/install-plugins.sh`: for each plugin → install pinned version → enable → apply any required
   config (e.g. Calls RTC settings) → `mmctl config reload`. Make it idempotent (skip if already present).
3. Open the product: start a Call/huddle, create a Playbook run, create a Board — each works.
4. For Calls, verify media connects (the RTC port path through host firewall/Caddy is correct).
5. Document IDs/versions/ports and "how to add another plugin" in `docs-notes/plugins.md`.

## ACCEPTANCE CRITERIA
- [ ] `mmctl plugin list` shows calls, playbooks, boards all **enabled**.
- [ ] A voice/video call connects between two test users (media flows, not just signaling).
- [ ] A playbook run can be created and checklist items toggled.
- [ ] A board can be created with cards.
- [ ] Versions are pinned (no implicit `latest`); re-running the script is idempotent.
- [ ] No core modification; plugins came via the plugin API only.

## GOTCHAS
- Calls media (WebRTC) needs the right host/port reachable — the most common failure is a blocked RTC
  UDP port or wrong `ICEHostOverride`. Verify actual audio, not just the call UI.
- A known `mmctl` quirk: newly-installed plugin config sometimes won't take until `mmctl config reload`
  (or a one-time System Console touch). Build the reload into the script.
- Pin versions compatible with `MM_VERSION`; check each plugin's min-server-version in its `plugin.json`.

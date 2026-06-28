# GOAL-09 — Resilience & backup (the HA-cluster alternative)

**GOAL:** Replace EE **cluster/HA (#16)** — which cannot be reproduced from outside — with pragmatic
single-node resilience: automated backups + restore, Postgres replication option, container auto-heal,
healthchecks, and Telegram alerting.

## WHY
HA clustering is the one genuine wall (see `../docs/03-FEATURE-MATRIX.md`). For a small managed
deployment, real uptime comes from **fast recovery**, not multi-node clustering: frequent verified
backups, automatic restart/heal, DB replication for disaster recovery, and alerts when something breaks.
This matches the existing "predator resilience" pattern already used on our infra.

## CONTEXT
- Components to protect: `mm-postgres` (the crown jewels), the MM data volume (files, plugins, config),
  Keycloak DB, and the rendered config/branding.
- Backup = `pg_dump` (both Postgres) + archive of the MM data volume + Keycloak realm export, to
  `data/backups/` and (recommended) an off-host target.
- Auto-heal = compose `restart: unless-stopped` + healthchecks + a watchdog that alerts on repeated
  failures.
- Alerts = Telegram bot (`${TELEGRAM_BOT_TOKEN}` / `${TELEGRAM_CHAT_ID}`) — reuse the existing predator
  alerting convention.
- Optional DR: Postgres streaming replication to a standby (documented; enable per client SLA).

## PREREQUISITES
- GOAL-01 (stack up). Telegram bot token + chat id in `.env` (optional but recommended).

## DELIVERABLES
```
jobs/backup.sh                        # pg_dump x2 + data volume archive + realm export → data/backups/ (+ off-host)
jobs/restore.sh                       # restore a chosen backup set into a fresh stack (with confirmation)
jobs/healthwatch.sh                   # poll healthchecks; Telegram alert on failure/recovery
compose/docker-compose.resilience.yml # backup cron + healthwatch + restart policies
docs-notes/resilience.md              # RTO/RPO, schedules, restore runbook, replication option
```
New `.env` vars (add to `.env.example`): `BACKUP_SCHEDULE` (cron), `BACKUP_RETENTION` (keep N),
`BACKUP_OFFSITE_TARGET` (optional rsync/s3), `ALERT_ON_FAILURES` (count threshold).

## STEPS
1. `jobs/backup.sh`: dump both Postgres DBs, archive MM data volume, export Keycloak realm; timestamped
   set in `data/backups/`; rotate to `BACKUP_RETENTION`; optional off-host copy.
2. `jobs/restore.sh`: given a backup set, restore into a clean stack; require explicit confirmation;
   verify post-restore (DB row counts, MM `/system/ping`, a known message present).
3. `jobs/healthwatch.sh`: poll each container healthcheck; on N consecutive failures send Telegram alert;
   send a recovery message when healthy again.
4. Set `restart: unless-stopped` + healthchecks on all services; add backup cron + healthwatch via
   `compose/docker-compose.resilience.yml`.
5. **Fire drill:** take a backup → `docker compose down -v` (simulate loss) → `restore.sh` → confirm the
   instance comes back with data intact. Record RTO (time to restore) and RPO (max data loss = backup
   interval) in `docs-notes/resilience.md`.
6. Document the optional Postgres streaming-replication setup for clients needing tighter DR.

## ACCEPTANCE CRITERIA
- [ ] `backup.sh` produces a complete, dated set (both DBs + data volume + realm) and rotates old ones.
- [ ] **Restore fire-drill passes:** after simulated total loss, `restore.sh` brings the instance back
      with messages, users, and config intact. RTO/RPO recorded.
- [ ] Killing a container triggers auto-restart; sustained failure fires a Telegram alert; recovery clears it.
- [ ] Backups can be pushed off-host when `BACKUP_OFFSITE_TARGET` is set.
- [ ] All schedules/targets from `.env`; no core modification.

## GOTCHAS
- A backup you've never restored is not a backup — the fire-drill (step 5) is mandatory, not optional.
- Back up the **data volume** too, not just Postgres — files, plugins, and config live there.
- This is **not** true HA: a single-node outage still means downtime until restart/restore. Set client
  expectations accordingly; true HA = escalate to a paid tier (`../docs/02-LEGAL-MODEL.md` §Escalation).

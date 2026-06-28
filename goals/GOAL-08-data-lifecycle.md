# GOAL-08 — Data lifecycle: retention + compliance/CSV export

**GOAL:** Reproduce EE **data_retention (#2)**, **compliance (#3)**, and **message_export CSV (#4)** with
external scheduled jobs that operate on the Mattermost database / admin API — no core changes, no EE.

## WHY
Clients often need "delete messages older than N days" and "give me an export of channel X for an audit."
EE gates these behind a license; the data lives in plain Postgres, so we reproduce them with our own
scheduled jobs. Legal (our code, separate work) and reproducible per client.

## CONTEXT
- Mattermost data is in Postgres (`Posts`, `FileInfo`, `Channels`, `Teams`, `Users` …). File blobs are in
  the data volume (or object store).
- Retention = delete `Posts` (and orphaned `FileInfo` + blobs) older than a policy, optionally per
  channel/team. Use **soft constraints**: dry-run first, log counts, then delete in batches.
- Export = query posts joined to channel/user → CSV (and/or JSON). The proprietary Actiance/Global Relay
  XML formats (#13) are **out of scope**; CSV/JSON covers the realistic need.
- Prefer the **admin API/`mmctl`** where it exists; fall back to direct SQL for retention/export. Direct
  deletes must be careful and batched to avoid lock/IO spikes.
- Schedule via a small cron container in the stack (or host cron) reading policy from `.env`.

## PREREQUISITES
- GOAL-01 (DB reachable on `internal`). Read-only DB role for export; a scoped role for retention deletes.

## DELIVERABLES
```
jobs/retention.sh                     # batched delete of posts/files older than RETENTION_DAYS (dry-run flag)
jobs/export.sh                        # channel/team/date-range → CSV/JSON to data/exports/
jobs/compliance-report.sh             # periodic activity summary (counts by user/channel/day)
compose/docker-compose.jobs.yml       # cron/scheduler container running the jobs
docs-notes/data-lifecycle.md          # policies, env vars, safety model, restore-from-export note
```
New `.env` vars (add to `.env.example`): `RETENTION_DAYS` (0=disabled), `RETENTION_SCOPE`
(`global`|`per-channel`), `EXPORT_SCHEDULE` (cron), `COMPLIANCE_SCHEDULE` (cron).

## STEPS
1. `jobs/retention.sh`: parameterized by `RETENTION_DAYS`; supports `--dry-run` (prints counts, deletes
   nothing); deletes in batches; prunes orphaned files; logs every run.
2. `jobs/export.sh`: args = team/channel/date-range/format; writes to `data/exports/<timestamp>/`.
3. `jobs/compliance-report.sh`: emits per-period activity counts (messages per user/channel/day) as CSV.
4. `compose/docker-compose.jobs.yml`: a lightweight cron container (e.g. alpine + crond, or `ofelia`)
   running retention/export/compliance on their schedules, reading creds from `.env`.
5. Test: seed old posts → `retention.sh --dry-run` reports correct count → real run deletes only those →
   `export.sh` produces a valid CSV that opens cleanly.
6. Document policies, safety (dry-run first), and how an export could be re-imported, in `docs-notes/`.

## ACCEPTANCE CRITERIA
- [ ] `retention.sh --dry-run` reports the exact set it *would* delete and deletes nothing.
- [ ] A real retention run deletes only posts older than `RETENTION_DAYS` and prunes their files; counts logged.
- [ ] `export.sh` produces a well-formed CSV/JSON for a given channel + date range.
- [ ] `compliance-report.sh` produces an activity summary.
- [ ] Jobs run on schedule via the cron container; all params from `.env`.
- [ ] No core modification; DB/API access only. Retention uses a scoped DB role, export a read-only role.

## GOTCHAS
- **Destructive.** Always dry-run first; batch deletes; take a backup (GOAL-09) before the first real run.
- Deleting `Posts` rows without pruning `FileInfo`/blobs leaks storage — handle both.
- Schema column names can change across MM versions — pin queries to `MM_VERSION` and verify against the
  reference clone `~/mattermost-src/mattermost/server` (store/sqlstore) before deleting.
- Regulated archiver formats (Actiance/Global Relay, #13) are deliberately **out of scope** here.

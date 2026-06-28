# 05 — Enterprise / Big-Tech-Grade White-Labeling

## Purpose
Answer the question directly: *"if a big-tech-grade operation white-labeled this at scale, what would
they prepare that we haven't?"* — and turn it into a **maturity ladder** so we can choose, per client,
how far up to climb. Same structure at every scale; only the rigor changes (fractal).

The honest framing: our current template is a solid **L1**. Selling to a CleanVeteran needs L1–L2.
Selling to a Samsung-grade buyer (Scout) needs L3, and the components of L4 become contractual.

---

## The maturity ladder

### L1 — Reproducible template (where we are)
- One parameterized stack per client (compose + `.env` + brand assets), core unmodified.
- Vendored + indexed reference environment (`04-REFERENCE-ENVIRONMENT.md`).
- Manual-ish provisioning + an acceptance/legal gate.
**Good enough for:** SMB clients, pilots, CleanVeteran.

### L2 — Engineered delivery
What a competent product team adds:
- **Everything-as-code + GitOps:** infra in Terraform, app in Helm/Kustomize, per-client config in a git
  repo; merge → deploy. No hand-run `docker compose up` in prod.
- **CI/CD:** pipeline that lints, builds, spins the stack ephemerally, runs `verify.sh` (GOAL-11), and
  blocks release on the legal/branding gate.
- **Supply-chain hygiene:** pin images by **digest** (not just tag); generate an **SBOM** (Syft);
  scan for CVEs (Trivy/Grype) and **license contamination** (ScanCode/FOSSA — proves no AGPL/EE leak
  into our deliverables, which is the legal moat made auditable).
- **Secrets management:** Vault / SOPS / cloud secret manager — never env files on disk in prod.
- **Backup/restore tested (RTO/RPO) + observability basics** (Prometheus/Grafana/Loki).
**Good enough for:** serious B2B, multi-client portfolios.

### L3 — Fleet / control plane (true multi-tenant SaaS operation)
How Mattermost itself runs thousands of customer installs — and what we'd build to operate dozens:
- **A control plane** = the source of truth for "which tenants exist, what version, config, brand,
  health," that **reconciles desired → actual** (the operator/GitOps pattern). Mattermost open-sources
  exactly this: **`mattermost-operator`** (k8s operator) + **`mattermost-cloud`** (fleet provisioner).
  Study/repurpose these instead of inventing a control plane.
- **Tenancy model decision (AWS SaaS lens):** *silo* (stack per tenant — our default, max isolation),
  *pool* (shared cluster, logical separation — cheapest at scale), or *bridge* (hybrid). Pick per
  isolation/compliance vs. cost. Add per-tenant quotas (noisy-neighbor), and optional **BYOK** (tenant-
  held encryption keys).
- **Identity at scale:** not hand-built Keycloak realms — **automated realm provisioning** (Keycloak
  admin API / `terraform-provider-keycloak`), **SCIM** user provisioning, JIT, per-tenant MFA policy,
  self-service IdP onboarding.
- **Observability + SLO:** OpenTelemetry traces, per-tenant dashboards, error budgets, on-call/alerting.
- **Release engineering:** canary → blue-green rollouts, automated rollback, fleet version-skew control,
  safe DB-migration gating, maintenance windows.
**Good enough for:** operating a real white-label SaaS business; Scout/Samsung-grade buyers.

### L4 — Regulated / mission-critical (what becomes contractual, not just nice)
- **Compliance posture:** SOC 2 / ISO 27001, audit logging, **certified archiving** (Actiance / Global
  Relay) and eDiscovery/legal-hold with vendor liability, data-residency/region pinning, DPA +
  subprocessor list.
- **True HA / DR** with contractual uptime SLA (the one feature we can't DIY — see below).
- **Image signing & provenance** (cosign/sigstore, SLSA), private registry mirror, air-gapped install.
- **Pen-tested, threat-modeled, formal incident response.**

---

## Where DIY ends and you buy: the escalation rule
Three things, at L4, are usually **cheaper/safer to buy than build**:
1. **True HA clustering (#16)** — not reproducible from outside (see `03-FEATURE-MATRIX.md`).
2. **Certified compliance archiving (#13) + eDiscovery** — regulators want a vendor of record.
3. **A government/large-enterprise buyer (Scout/Samsung)** who wants **someone to sue if it breaks** —
   indemnification and support SLAs.

For those, the big-tech answer is an **OEM / embedding agreement with Mattermost** (they have one). It
legally grants full rebranding + the EE features + support + indemnity. Counter-intuitively, for a
Samsung-grade deal the **vendor-backed OEM is often the *easier sale*, not the more expensive build** —
"backed by Mattermost Enterprise" can be a selling point. DIY open-core (this template) is the right tool
for SMB/pilot velocity; OEM is the right tool for regulated whales. **Use both, per client.**

---

## What we should prepare next (concrete backlog beyond MVP)
Ordered by leverage:
1. **Pin + lock + RAG-index the reference env** (GOAL-PREP) — removes guessing. *Do first.*
2. **CI that runs GOAL-11 `verify.sh` on every change** — makes the legal/branding gate automatic.
3. **Supply-chain: digest-pin + SBOM + license scan** — turns "we don't use EE/GPL" into an audit artifact.
4. **Provisioning hardening (GOAL-10) → a thin control plane** — a tenants registry + reconcile loop
   (repurpose `mattermost-operator`/`mattermost-cloud` ideas) once client count > a handful.
5. **Observability stack** (Prometheus/Grafana/Loki) shared across tenants.
6. **Identity automation** (Keycloak realm-as-code + SCIM) once SSO onboarding repeats.
7. **Per-tenant backup/DR with tested RTO/RPO + region pinning** as deals get bigger.
8. **Decide OEM vs DIY per pipeline deal** — Scout likely OEM-track; CleanVeteran DIY-track.

## The one-line principle
At every rung the move is the same: **make the source of truth explicit, make the desired state code,
make verification automatic, and make the boundary (DIY vs buy) a deliberate per-client decision** — not
an accident discovered in production.

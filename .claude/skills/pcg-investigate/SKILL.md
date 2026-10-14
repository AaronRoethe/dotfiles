---
name: pcg-investigate
version: 1.0.0
description: |
  Investigate Azure Logic App / Promitor / Prometheus / Cortex / Grafana metrics pipeline outages.
  Use when: Logic App dashboards show no data, Promitor alerts fire, Azure Monitor metrics
  disappear from Grafana, or you need to diagnose why azure_logic_workflows_* series are absent.
  Covers the full pipeline: Azure Monitor → Promitor scraper → Prometheus/Cortex → Grafana.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

## Pipeline Architecture

```
Azure Logic Apps
    ↓  (Azure Monitor API — batch calls, maxBatchSize=25)
Promitor Scraper  [US1 farm2, namespace: promitor]
    ↓  (Prometheus /metrics endpoint, scraped every 5m)
Prometheus / Cortex  [US1 farm2, namespace: cortex-components]
    ↓
Grafana
```

**Monitored Logic App resource groups:**

- `PUS1GE1-integ-logicapp` — ~191 LAs (tag `monitored: true`)
- `PUS1GE1-warehouse-logicapp` — ~217 LAs (tag `monitored: true`)
- `us1-main-va-rms-data` — Data Factory resources

**Cluster:**

```bash
az aks get-credentials --resource-group us1-main-va-farm2-aks --name farm2
# Verify:
kubectl config current-context
```

---

## Phase 1 — Confirm the gap

Check when the metric series disappeared from Prometheus/Cortex. Query Grafana or run:

```bash
# Are ANY azure_logic_workflows_* series present right now?
kubectl -n promitor port-forward svc/promitor-scraper-data-platform 8888:80 &
curl -s http://localhost:8888/metrics | grep -c "^azure_logic_workflows"
# 0 = series completely absent; any number = at least partially scraping
```

Check Cortex/Prometheus directly:

```bash
kubectl -n cortex-components get pods | head -20
# Look for query-frontend or querier pods for ad-hoc PromQL queries
```

---

## Phase 2 — Check Promitor pod health

```bash
kubectl -n promitor get pods
# Look for: promitor-scraper-data-platform-*, promitor-resource-discovery-data-platform-*
# Note RESTARTS count and AGE (restart ≈ when problem may have started)

# Recent logs — look for WRN/ERR lines
kubectl -n promitor logs deployment/promitor-scraper-data-platform --tail=200 | grep -E "WRN|ERR|Cancelled|timeout|error" | head -40

# If you see this, it's the mutex timeout root cause:
# WRN Cancelled scraping metrics for job Scraper-9Metrics-Every_5_minutes-<hash>
# This fires at exactly mutexTimeoutSeconds after each scrape starts.
```

**Key log patterns and their meaning:**

| Log line                                             | Meaning                                           |
| ---------------------------------------------------- | ------------------------------------------------- |
| `WRN Cancelled scraping metrics for job Scraper-...` | Mutex timeout — scrape cycle killed mid-run       |
| `ERR Failed to scrape metric`                        | Individual metric error (check metric_name label) |
| `WRN Azure Monitor rate limit`                       | ARM API throttled — too many calls                |
| `INF Scraping of job ... done`                       | Healthy — scrape completed                        |

If every 5-min cycle shows `Cancelled` at the same timestamp offset → **mutex timeout is the root cause**.

---

## Phase 3 — Read Promitor runtime config

```bash
# Runtime config — contains mutexTimeoutSeconds, batching settings
kubectl -n promitor get configmap config-map-promitor-scraper-data-platform -o yaml | grep -A 40 "runtime.yaml"

# Metrics declaration — contains resource groups, scrape schedule, metric names
kubectl -n promitor get configmap config-map-promitor-scraper-data-platform -o yaml | grep -A 100 "metrics-declaration.yaml"

# Resource discovery — contains tag filters and resource group scopes
kubectl -n promitor get configmap config-map-promitor-resource-discovery-data-platform -o yaml
```

**Critical values to check in runtime.yaml:**

```yaml
concurrency:
  mutexTimeoutSeconds:
    180 # <-- ROOT CAUSE if too low
    # Rule of thumb: (total_LAs × metrics_per_LA / maxBatchSize) × ~3s + buffer
    # For 408 LAs × 5 metrics / 25 batch = 82 calls × ~3s ≈ 246s → set 600
azureMonitor:
  integration:
    metricsBatching:
      enabled: true
      maxBatchSize: 25
```

**Scale math:**

- Count monitored LAs: `az logic workflow list --resource-group PUS1GE1-integ-logicapp --query "[?tags.monitored=='true'] | length(@)"`
- Total batch calls = (integ_count + warehouse_count) × metrics_count / maxBatchSize
- Required timeout = total_batch_calls × ~3s + 60s buffer

---

## Phase 4 — Count monitored Logic Apps

```bash
az logic workflow list \
  --resource-group PUS1GE1-integ-logicapp \
  --query "[?tags.monitored=='true'] | length(@)"

az logic workflow list \
  --resource-group PUS1GE1-warehouse-logicapp \
  --query "[?tags.monitored=='true'] | length(@)"
```

If counts have grown significantly since the configmap was last updated, that explains why a previously-working timeout is now too short.

---

## Phase 5 — Check scrape schedule and Cortex staleness

If Promitor was emitting `NaN` (via `metricUnavailableValue: "NaN"`) for weeks before you noticed:

- Cortex expires stale series after **~7 days** by default
- Pod restart date + 7 days ≈ date metrics vanished from Grafana dashboards

To check when pod last restarted:

```bash
kubectl -n promitor describe pod -l app=promitor-scraper-data-platform | grep -E "Start Time|Last State"
```

---

## Phase 6 — Find and apply the fix

The Promitor config is managed by **ArgoCD**. The configmap annotation is:
`argocd.argoproj.io/instance=promitor-scraper-data-platform`

The source config lives in the **ops/infrastructure repo** (NOT grafana-telemetry).

To find the config file in the ops repo:

```bash
grep -r "mutexTimeoutSeconds" /path/to/ops-repo/
grep -r "promitor-scraper-data-platform" /path/to/ops-repo/ --include="*.yaml" -l
```

**Fix:** Change `mutexTimeoutSeconds` to at least `600` (for current fleet size).
After applying, watch logs to confirm `INF Scraping of job ... done` appears within 5 minutes.

---

## Phase 7 — Alert coverage check

After resolving, verify grafana-telemetry has an alert for future silent failures:

```bash
cd ~/repos/grafana-telemetry
grep -r "absent_over_time.*azure_logic_workflows" rules/
grep -r "LogicAppMetricsAbsent" rules/
```

If missing → add to `rules/default/templates/infra/promitor/promitor-scrape-failed.yaml`.
The `LogicAppMetricsAbsent` alert was added in PR #20931 (2026-03-20) to catch this exact failure mode.

---

## Quick-reference: all namespaces and resources

| Resource                      | Namespace                   | Name                                                                             |
| ----------------------------- | --------------------------- | -------------------------------------------------------------------------------- |
| Scraper deployment            | `promitor`                  | `promitor-scraper-data-platform`                                                 |
| Scraper configmap             | `promitor`                  | `config-map-promitor-scraper-data-platform`                                      |
| Resource discovery deployment | `promitor`                  | `promitor-resource-discovery-data-platform`                                      |
| Resource discovery configmap  | `promitor`                  | `config-map-promitor-resource-discovery-data-platform`                           |
| Cortex components             | `cortex-components`         | various                                                                          |
| AKS cluster                   | RG: `us1-main-va-farm2-aks` | cluster name: `farm2`                                                            |
| Alert rules repo              | local                       | `~/repos/grafana-telemetry/rules/default/templates/infra/promitor/` |
| Logic App resource groups     | —                           | `PUS1GE1-integ-logicapp`, `PUS1GE1-warehouse-logicapp`                           |

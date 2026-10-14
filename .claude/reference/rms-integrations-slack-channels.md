# RMS Integrations Slack channels


Slack channels tied to the RMS Integrations team, compiled from actual posting history and channel search.

**Core / actively used**

- #rms-integrations — main team channel
- #rms-integrations-dev-team — internal team discussion (homepage linked in purpose)
- #rms-integrations-and-datastore-ops-discussions — ops/alert discussion, uses @datastore-on-call and @rms-integrations-immortal
- #rms-integrations-and-datastore-release — deployment tracking/coordination
- #rms-integrations-datastore-swss-peer-review — PR review requests for Data Platform & Integrations
- #rms-integrations-oncall-discussion-internal — internal oncall discussion
- #rms-integrations-dlq-bulk-requeue — DLQ/auto-requeue tooling discussion (user-created)
- #rms-integrations-deprecate-terraforms — terraform-integrations → ALS Infra migration (user-created)
- #rms-integrations-off-topic — non-work chat

**Alerting**

- #rms-integrations-alerts / #rms-integrations-alerts-ag1 / #rms-integrations-alerts-stage
- #rms-integrations-dlq-chatter

**Initiative/topic-specific**

- #rms-integrations-nibrs-discussion, #rms-integrations-nibrs-under-reporting
- #rms-integrations-ais-adoption, #rms-integrations-ais-migration-challenges
- #rms-integrations-jit-issues, #rms-integrations-ca1-setup
- #rms-integrations-quality-focus-initiative, #rms-integrations-2027-zbb-planning, #rms-integrations-hackathon, #rms-integrations-ai
- #rms-integrations-vietnam, #rms-integrations-vn-ramp-up, #rms-integrations-vn-ai-demo
- #rms-integration-fedramp-go-live (note: singular "integration")

**Older / adjacent (pre-rename Data Platform & Integrations channels)**

- #rms-integrations-datastore-swss-teams, #rms-integrations-datastore-swss-dev

Not RMS Integrations team channels but where user discusses integrations-related incidents: #ops_guardians, incident channels (e.g. `#inc-*-integrations-*`), #rdev.

**Automations posting in core channels** (verified by reading channel history)

- #rms-integrations-alerts / -alerts-ag1 / -alerts-stage — 100% bot-fed by a single Grafana/Alertmanager (Cortex) app per channel; posts FIRING/RESOLVED alerts (e.g. ConductorWorkerImportRecordsCFSFailed, LogicAppFailureMonitor, ConductorworkerNIBRSSubmissionFailureRate, QueueDirectExportDLQ, DataFactoryPipelineFailed, EntityResolverResolveEntityLatencyHigh, DalorDalorFailure). No human traffic.
- #rms-integrations-dlq-chatter — "Automation for Jira" Slack app posts every update (PM Owner change, comments, status) on Bugs/Epics created by the AutoDLQ (integrations-auto-requeue) tool.
- #rms-integrations-and-datastore-ops-discussions — "Review customer issues" bot posts a daily (10:00 MT) reminder linking the RMS customer-issues Jira Kanban board; "Update NIBRS Reporting Rate Dashboard" bot posts a weekly (Monday) reminder to update the NIBRS dashboard.
- #rms-integrations-and-datastore-release — several Slack workflow bots: "SWSS Integration Deployment Workflow - US1 Release Mgr", "RMS Integrations Karate Regression Triage" (Tue AM QA script that files release-blocker Jira tickets), "Branch cut for RMS Integrations release" (Friday branch-cut reminder); Slackbot deploy-prep template reminder; GitHub/Jira Cloud app notifications on linked PRs/tickets.
- #rms-integrations-datastore-swss-peer-review — Slackbot daily "Code Review" meeting reminder; GitHub App PR notifications (incl. axon-code-review-plus-one[bot] auto-approvals) for translator/conductor/integrations-auto-requeue repos.
- #rms-integrations-dev-team — Slackbot daily stand-up reminder/thread only.
- #rms-integrations-oncall-discussion-internal, #rms-integrations-dlq-bulk-requeue, #rms-integrations-off-topic — no work automations found; only Slackbot retention-policy change notices.

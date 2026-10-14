---
name: diary
description: Appends oncall shift entries (tasks, investigations, research, alerts, requests) to the current week's RMS Integrations oncall diary in Quip. Use during an oncall shift to log what you're working on.
argument-hint: "[entry text] [--section <section name>]"
allowed-tools: mcp__claude_ai_Quip__read_document, mcp__claude_ai_Quip__update_document, mcp__claude_ai_Quip__search_documents, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_search_public_and_private
---

Append a new entry to the current week's RMS Integrations oncall diary in Quip.

This skill also runs after any task the user prefixes with `oncall:` — finish the task first, then log it here.

## Step 1 — Resolve the Diary

The diary is a new Quip doc each week, titled `RMS-Integration-oncall-diary-<date-range>` (e.g. `RMS-Integration-oncall-diary-Mar182026-Mar252026`). Search Quip:

```
search: "RMS-Integration-oncall-diary" in Quip, sort by recent
```

Pick the document whose date range covers today. If none matches, ask the user for the URL.

If the entry includes a Slack thread link, read the thread with `slack_read_thread` for context before writing.

## Step 2 — Read the Diary

Use `mcp__claude_ai_Quip__read_document` with the diary URL to fetch its current content and understand its section structure.

Common sections include:

- **Dalor Failures** — Dalor/DAL HTTP errors, integration failures
- **Translator Calls** — translator errors, POST failures
- **Activities > Team Requests** — requeue requests, EMR tickets, reprocess work
- **Activities > Investigations** — root cause analysis, debugging sessions
- **Activities > Research** — spike work, learning, documentation review
- **General Notes** — anything that doesn't fit elsewhere

If no `--section` flag is provided, infer the best section from the entry content:

- Mentions of Dalor/DAL/HTTP 500 → **Dalor Failures**
- Mentions of translator/POST error → **Translator Calls**
- Mentions of requeue/EMR/reprocess → **Activities > Team Requests**
- Mentions of investigating/debugging/root cause → **Activities > Investigations**
- Research, spikes, reading docs → **Activities > Research**
- Anything else → **General Notes**

## Step 3 — Format the Entry

Format the entry as a dated bullet:

```
- [YYYY-MM-DD] <entry text>
```

Use today's date. Include any ticket references (RMS-XXXXX, CS3-XXXXX, EMR-XXXXX) as plain text — do not add hyperlinks. Always include any URLs or links provided by the user in the entry text.

If the entry spans multiple points (e.g., investigation with findings), use a nested list:

```
- [YYYY-MM-DD] Investigated RMS-12345 — GardenGrovePd-CoplogicToAxonRMS DAL 500
  - Root cause: Dalor service returning 500 on all requests for this agency
  - Action: Escalated to infra team, monitoring for recovery
```

## Step 4 — Append to the Diary

Use `mcp__claude_ai_Quip__update_document` to append the formatted entry under the target section.

Append at the **bottom** of the section, after any existing entries.

If the section does not yet exist in the document, create it as a new `##` heading at the bottom of the document before adding the entry.

## Step 5 — Log Untracked Oncall Pings (`oncall:` runs only)

Search Slack for threads this week that tag `@rms-integrations-immortal` (subteam `S07DFJZB8F7`): `<!subteam^S07DFJZB8F7> after:<start of week>`. For each thread not already in the diary, append an entry linking the top-level parent message (not a reply).

## Step 6 — Confirm

After updating, print:

```
✓ Logged to diary: <section name>
  [YYYY-MM-DD] <entry text>
```

## Examples

### Quick task log

`/diary reviewed and closed EMR-15303, linked RMS-98177 already Done`

→ Appends to **Activities > Team Requests**:

```
- [2026-03-24] Reviewed and closed EMR-15303 — linked RMS-98177 already Done
```

### Investigation entry

`/diary investigating RMS-87349 AtlantaPd DAL 500 — checking if Dalor is healthy`

→ Appends to **Dalor Failures**:

```
- [2026-03-24] Investigating RMS-87349 — AtlantaPd-CoplogicToAxonRMS DAL 500, checking Dalor health
```

### Override section

`/diary --section "General Notes" shift handoff completed, passed to Dave Lockwood`

→ Appends to **General Notes**:

```
- [2026-03-24] Shift handoff completed, passed to Dave Lockwood
```

## Error Handling

- If the diary doc can't be found: tell the user to provide the URL directly or check the Quip search results manually
- If the section can't be determined: ask the user which section to use before writing
- Never overwrite existing content — only append

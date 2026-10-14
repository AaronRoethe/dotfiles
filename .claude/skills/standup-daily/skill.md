---
name: standup-daily
description: Generate a daily standup from GitHub activity, Jira, Google Drive, and Slack. Outputs a Markdown file and sends a Slack DM. Run each morning to summarize the previous workday.
argument-hint: [--date YYYY-MM-DD] [--since YYYY-MM-DD] [--no-slack]
allowed-tools: Bash, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql, mcp__claude_ai_Google_Drive__list_recent_files, mcp__claude_ai_Slack__slack_search_public_and_private, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_send_message
---

Generate a daily standup for the user (`PROFILE_NAME`, from the profile imported in CLAUDE.md) covering the previous workday (or the date range implied by arguments).

## Configuration

- GitHub Enterprise: `git.taservs.net`, username: `PROFILE_WORK_USER`
- Standup binary: `~/go/bin/standup`
- Output directory: `~/standups/`
- Slack user ID: `PROFILE_SLACK_USER_ID` (DM target)
- Jira: the Atlassian connector is logged in as the user, so use `currentUser()` in JQL (the work username does not match in Jira Cloud)

## Step 1 — Determine Date Range

- Default: yesterday → today (for Monday standups, look back to Friday)
- If `--date YYYY-MM-DD` is given, generate the standup for that date
- If `--since YYYY-MM-DD` is given, use that as the start date
- If `--no-slack` is given, skip Step 9 (no Slack DM); the Markdown file is still written

Set variables:

- `STANDUP_DATE` = the date being reported (default: today, e.g. `2026-03-07`)
- `SINCE_DATE` = start of activity window (default: yesterday or last Friday)
- `SLACK_AFTER_DATE` = one day before `SINCE_DATE` (Slack's `after:` excludes the given date)

## Step 2 — Collect GitHub Activity

Run the standup binary to get structured JSON of GitHub events:

```bash
~/go/bin/standup github --since <SINCE_DATE>
```

Parse the JSON output. Extract:

- **PRs opened**: title + URL
- **PRs merged**: title + URL
- **PRs reviewed**: title + URL + review state (approved / changes_requested / commented)
- **Pushes**: repo + branch + commit messages (collapse multiple pushes to same repo/branch)
- **Issue comments**: issue title + URL

If a PR has an empty title or URL, describe it as `<repo>#<number>`.

## Step 3 — Collect Jira Activity

Get the cloud ID with `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources`, then use `mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql`.

Tickets the user worked in the window (assigned tickets that changed, plus any ticket whose status they moved). The `updatedBy()` JQL function is not supported by this connector:

```
(assignee = currentUser() AND updatedDate >= "<SINCE_DATE>") OR status CHANGED BY currentUser() AFTER "<SINCE_DATE>" ORDER BY updated DESC
```

Open work for the Today section:

```
assignee = currentUser() AND sprint in openSprints() AND statusCategory = "In Progress" ORDER BY updated DESC
```

Collect: issue key, summary, status, URL.

## Step 4 — Collect Google Drive Activity

Use `mcp__claude_ai_Google_Drive__list_recent_files` with `orderBy: lastModifiedByMe`, `pageSize: 25`, `excludeContentSnippets: true`.

- Keep only Google Docs, Sheets, and Slides (`application/vnd.google-apps.document`, `.spreadsheet`, `.presentation`). Skip folders and other files (git `objects` / `FETCH_HEAD` sync noise, attachments).
- Keep files whose `modifiedTime` is on or after `SINCE_DATE`. `modifiedTime` is the last edit by anyone, so treat it as approximate.
- Include title + `viewUrl`. Note "(created)" when `createdTime` is in the window.

## Step 5 — Collect Claude Code Usage

Run the standup binary to get token usage stats from local Claude Code session files:

```bash
~/go/bin/standup claude --since <SINCE_DATE>
```

Parse the JSON output. Extract for the relevant day(s):

- **Messages**: number of Claude interactions
- **Output tokens**: primary measure of work done
- **Est. cost**: estimated API cost in USD
- **Total for window**: sum across all days in range

This section is always included in the standup even if zero usage.

## Step 6 — Collect Slack Signals

Use `mcp__claude_ai_Slack__slack_search_public_and_private` to find messages sent by the user in the window:

- Filters: `from:<@PROFILE_SLACK_USER_ID> after:<SLACK_AFTER_DATE>`
- Page through all results
- Look for: deployment announcements, incident responses, cross-posts, PR approvals, key decisions
- Skip trivial informal chat

Use this to supplement the standup with any significant communications or work not captured by GitHub/Jira.

## Step 7 — Generate the Standup

Using all collected data, synthesize a daily standup. Follow these rules:

**Format:**

```markdown
# Daily Standup — <Day, Month DD YYYY>

## Yesterday

### GitHub

- <bullet per significant PR/review/push — skip trivial auto-generated bumps unless noteworthy>

### Jira

- <bullet per ticket updated: KEY-XXX: Summary → Status>

### Google Drive

- <bullet per doc/sheet/slide edited (omit if none)>

### Slack

- <bullet for key communications, announcements, or cross-posts (omit if none)>

### Claude Code

- <N> messages, <output_tokens> output tokens, est. $<cost>

## Today

- <infer from in-progress Jira tickets and in-flight PRs>

## Blockers

- None (or list any)

---

**TL;DR**
Yesterday

- <topic summarized in 10 words or less>
- <topic summarized in 10 words or less>

Today

- <topic summarized in 10 words or less>
- <topic summarized in 10 words or less>
```

**Writing rules:**

- Be concise — one line per item
- Skip noise: auto-generated chart bumps, release branch pushes, and trivial single-commit pushes can be grouped or omitted unless they represent a significant deployment
- Surface the "so what": "Merged PR: Conductor AIS catch-all route" is better than just the raw title
- For Jira, include the ticket key and show the status transition if applicable
- For "Today", pull from in-progress Jira issues and in-flight PRs
- If it's Monday, label the section "Friday" instead of "Yesterday"
- The TL;DR section at the bottom must distill each major topic into 10 words or less per bullet — one bullet per distinct work item, no links

## Step 8 — Write Markdown File

Pipe the generated markdown to the standup binary:

```bash
echo "<generated markdown>" | ~/go/bin/standup write --date <STANDUP_DATE>
```

The file will be saved to `~/standups/YYYY-MM-DD.md`. Print the file path on success.

## Step 9 — Send Slack DM

Skip this step if `--no-slack` was given.

Use `mcp__claude_ai_Slack__slack_send_message` with `channel_id` set to `PROFILE_SLACK_USER_ID`.

The tool takes standard markdown (`**bold**`, `#` headers, lists, links), so send the markdown content as-is. Keep it under 5000 characters.

## Error Handling

- If `~/go/bin/standup` is not found: tell the user to run `cd ~/repos/standup-gen && go build -o ~/go/bin/standup ./cmd/standup/`
- If `gh` is not authenticated: tell the user to run `gh auth login --hostname git.taservs.net`
- If any MCP step fails: continue with the remaining sources and note the gap in the standup
- If the output directory doesn't exist: the binary creates it automatically

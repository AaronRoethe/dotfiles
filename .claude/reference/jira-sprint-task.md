# Creating a Jira task for myself in the current sprint


When I ask to create a task for myself during the current sprint, create it in Jira (project **RMS**) with these settings, without asking for confirmation on the mechanics below:

- **Issue type:** Task
- **Assignee:** me — accountId `PROFILE_JIRA_ACCOUNT_ID` from the profile imported in CLAUDE.md
- **Sprint:** the currently active sprint on board 998 ("Integrations Sprint <name>"). Find it via JQL `project = RMS AND sprint in openSprints()`, or read the `customfield_10111` (Sprint) field on any issue already in that sprint to get the active sprint's id/name — `sprint in openSprints()` alone is too broad since project RMS spans many teams' boards/sprints.
- **RMS Squad:** `customfield_17050`, set to option id `25517` (value "Integrations").

**Why:** I'm on the RMS Integrations squad (board 998); tasks I create for myself should default to that squad and land in the active sprint rather than the backlog. See rms-integrations-slack-channels.md for the team context.

**How to apply:**

1. Create the issue via `createJiraIssue` (project=RMS, issueType=Task, assignee=accountId above). The Sprint custom field (`customfield_10111`) cannot be set at create time via the Atlassian MCP connector (`"Specify a valid value for Sprint"` error) — create first, then set it.
2. Immediately after creation, call `editJiraIssue` twice: once with `{"customfield_10111": <sprintId>}` (plain integer, not an array) to move it into the sprint, and once with `{"customfield_17050": {"id": "25517"}}` to set RMS Squad = Integrations.
3. Verify with JQL `sprint = <sprintId> AND assignee = <PROFILE_JIRA_ACCOUNT_ID>`.

Note: devbridge MCP (Jira/Quip/Zephyr) was unreachable via DNS in this session; fell back to the `claude.ai Atlassian` connector tools (`searchJiraIssuesUsingJql`, `createJiraIssue`, `editJiraIssue`) with cloudId `taserintl.atlassian.net`. If devbridge is back up, its `create_jira_issue`/`update_jira_issue` tools should work equivalently — check both are usable and prefer whichever responds.

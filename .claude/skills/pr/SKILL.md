---
name: pr
description: Create a pull request for the current branch. Validates branch naming, commits all staged/unstaged changes, pushes after confirmation, writes the PR description, opens the PR against the repo's default branch (or --base) on the right GitHub host, and creates an optional Slack draft announcing it.
argument-hint: [--draft] [--base <branch>] [--slack #channel]
allowed-tools: Bash, Read, Write, Glob, Grep, Edit, mcp__claude_ai_Slack__slack_send_message_draft, mcp__claude_ai_Slack__slack_search_channels
---

Create a pull request for the current branch following the team's conventions.

## Step 1 — Determine Host and PR Target

Detect the GitHub host (`github.com` or `git.taservs.net`) and prefix every `gh` command below with `GH_HOST=$GH_HOST`:

```bash
GH_HOST=$(git remote get-url origin | sed -n 's|.*://\([^/]*\).*|\1|p; s|.*@\([^:]*\).*|\1|p' | head -1)
```

Default base branch: the remote's default (`git symbolic-ref --short refs/remotes/origin/HEAD`, minus `origin/` — usually `master` or `main`). If the argument includes `--base <branch>`, use that instead. Call this `<base>` in every step below.

Confirm the target before proceeding if it's not the default branch.

## Step 2 — Confirm State

Run these in parallel:

```bash
git status
git log <base>..HEAD --oneline
git diff <base>..HEAD --stat
GH_HOST=$GH_HOST gh pr list --head $(git branch --show-current) --json number,url
```

Print a one-line summary: current branch, number of commits ahead of `<base>`, and files changed. Wait for confirmation if anything looks unexpected (e.g., unrelated files staged, branch not based on `<base>`).

If a PR already exists for this branch, note its number — Step 8 updates it instead of creating a new one.

## Step 3 — Validate Branch Name

Branch should be `<prefix>/<type>/RMS-<ticket>-<desc>` (or `<prefix>/<type>/<desc>` with no ticket), where `<prefix>` is `PROFILE_WORK_USER` from the profile imported in CLAUDE.md. If it doesn't start with `<prefix>/`:

- Stop and ask: "Branch is named `<name>` — should I rename it to `<prefix>/<name>` before opening the PR?"
- Do not proceed until confirmed.

Extract the Jira key (`RMS-\d+`) from the branch name. If there isn't one, ask the user for it (or confirm there's no ticket).

## Step 4 — Commit Uncommitted Changes (if any)

If `git status` shows uncommitted changes:

- Show the list of changed files.
- Ask: "These files are uncommitted — should I include them in the PR commit, or leave them out?"
- If yes, stage and commit them with an appropriate conventional commit message before proceeding.

## Step 5 — Read All Changes

Read `git diff <base>..HEAD` (not just the last commit) to understand the full scope of the PR. Include ALL changed files — do not summarize based on only recently touched files.

Review the diff as the first reviewer: flag anything that looks unintended (debug code, unrelated changes). If the PR would take more than ~30 minutes to review, tell the user and suggest how to split it before continuing.

## Step 6 — Write PR Description

If `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/pull_request_template.md`) exists, use it exactly — fill every section, don't drop or reorder. Add the `## Related` Jira section below if the template doesn't already have a place for it.

If there's no template, use the following structure:

```markdown
## Summary

- <bullet: what changed and why — focus on the "why", not the "what">
- <bullet: any notable design decisions or tradeoffs>
- <bullet: anything reviewers should pay special attention to>

## Test plan

- [ ] <how to verify this works — specific make targets, test commands, or manual steps>
- [ ] <any E2E or integration test steps relevant to this change>

## Related

- Jira: [RMS-XXXX](https://taserintl.atlassian.net/browse/RMS-XXXX)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Rules:

- Summary bullets should explain intent, not just restate the diff
- Include the test plan even if it's just `make test` — reviewers need it
- Do not fabricate test results — only describe how to verify, not claim it already passes
- Annotate non-obvious changes: after the PR is open, offer to add PR comments on lines reviewers might misread
- The PR title becomes the squash-merge commit, so it must be a conventional commit: `type(scope): description` with type one of `feat, fix, docs, style, refactor, test, chore, perf, ci, build`

## Step 7 — Push (requires confirmation)

Show the PR title and description, then ask: "Push `<branch>` to origin and open the PR?"

Do not push until confirmed — a previous approval does not carry over. Once confirmed:

```bash
git push -u origin $(git branch --show-current)
```

Never force-push. If the push is rejected, stop and report.

## Step 8 — Open or Update the PR

If a PR already exists (from Step 2), update it:

```bash
GH_HOST=$GH_HOST gh pr edit <number> --body "$(cat <<'EOF'
<description from Step 6>
EOF
)"
```

Otherwise create it:

```bash
GH_HOST=$GH_HOST gh pr create \
  --base <base> \
  --title "<type(scope): description>" \
  --body "$(cat <<'EOF'
<description from Step 6>
EOF
)"
```

If `--draft` argument was given, add `--draft` flag to `gh pr create`.

Print the PR URL when done.

## Step 9 — Slack Notification (optional)

Only run this step if `--slack #channel` was provided as an argument.

Create a Slack draft in that channel with `slack_send_message_draft` (look up the channel ID with `slack_search_channels`). Never send it:

```markdown
Hey team — new PR up for review:

_<PR title>_
<PR URL>

<1-2 sentence summary of what it does and why>

Would appreciate a review 🙏
```

Print the channel link and tell the user the draft is waiting there for them to review and send.

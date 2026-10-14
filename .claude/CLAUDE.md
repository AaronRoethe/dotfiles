# Global Claude Preferences

My personal values (name, work username, email, Slack and Jira IDs) are the `PROFILE_*` variables in my dotfiles profile, imported here. Wherever these instructions say "my Slack ID", "my branch prefix" and so on, use those values.

@~/.env/profile.sh

## Communication

- Responses should be short and direct. No trailing summaries after completing work — I can read the diff.
- When I interrupt or redirect, stop immediately and follow the new direction.
- When I say "skip the rest" or "the rest can be skipped", ask me to clarify exactly which items to skip before removing anything. Never assume scope of deletions.
- No preamble. Lead with the action or answer.

## Git Operations

- Branch naming: `<PROFILE_WORK_USER>/<type>/RMS-<ticket>-<desc>` (e.g., `jdoe/fix/RMS-1234-null-agency`). Without a ticket: `<PROFILE_WORK_USER>/<type>/<desc>`.
- Always confirm the current repo, branch, and HEAD commit before any complex git workflow (revert, cherry-pick, rebase). State your understanding first.
- Never push without explicit confirmation from me, even if a previous push was approved.
- Never squash commits locally unless I explicitly ask. When I want individual PRs, keep them individual. (GitHub squash-merging PRs is expected.)
- Never amend published commits. Create a new commit instead.
- Never use `--no-verify` or skip hooks.
- Never run `gh workflow run` or any CI/CD trigger unless I explicitly say to run it. If I ask what the command is, just show it.

## GitHub

- Two hosts: GHEC `github.com` (org `axon-productivity`) and GHES `git.taservs.net`. Never assume — detect the host from the remote before any `gh` command and pass it on every call:
  ```bash
  GH_HOST=$(git remote get-url origin | sed -n 's|.*://\([^/]*\).*|\1|p; s|.*@\([^:]*\).*|\1|p' | head -1)
  GH_HOST=$GH_HOST gh pr create ...
  ```

## Commits & PRs

- Conventional Commits: `<type>(<scope>): <description>`, types `feat, fix, docs, style, refactor, test, chore, perf, ci, build`. PRs are squash-merged, so the PR title must follow this format; intermediate commits don't have to.
- AI-assisted commits include a `Co-Authored-By: Claude` trailer.
- Use the repo's `.github/PULL_REQUEST_TEMPLATE.md` if it exists — fill every section, don't drop or reorder.
- Take the Jira key (`RMS-\d+`) from the branch name; ask me if there isn't one. Include it in the PR body:
  ```
  ## Related
  - Jira: [RMS-1234](https://taserintl.atlassian.net/browse/RMS-1234)
  ```
- Read the full diff yourself before opening a PR. If it would take more than ~30 minutes to review, tell me and suggest a split.
- Never resolve review comments on my PRs — the reviewer confirms. After addressing feedback, re-request review.
- When writing review comments, use conventional comment labels: `issue (blocking):`, `suggestion (non-blocking):`, `question:`, `nitpick:`, `thought:`.
- When creating a PR, include ALL changed files — not just the most recently touched ones.

## Debugging

- Start with the simplest hypothesis first. Check the obvious before exploring complex paths.
- When I correct your diagnosis, fully pivot — do not partially incorporate the correction or continue down the old path.
- State your hypothesis explicitly before investigating it, so I can redirect early if it's wrong.

## Code & Design

- Keep designs minimal. Do not add watchers, assignees, thresholds, extra config options, or features unless I explicitly ask. Start simple.
- Prefer file-based config approaches. Do not suggest migrating from file-based config to environment variables.
- Do not over-engineer. Three similar lines of code is better than a premature abstraction.
- Only add error handling, validation, or fallbacks at system boundaries (user input, external APIs).

## Delegation

- For multi-part requests, delegate Jira data collection to `jira-collector`, codebase searches to `code-investigator`, and Slack thread/channel reading to `slack-reader`, running them in parallel when independent. Do the final analysis yourself.
- For any Slack message I want posted, use `slack-writer`.

## Slack, Jira & Oncall

- Slack messages are always drafts (`slack_send_message_draft`, with `thread_ts` for thread replies). Never use `slack_send_message` — I review and send drafts myself. Exception: messages to my own DM (`PROFILE_SLACK_USER_ID`) can be sent directly.
- Team Slack channels and the bots in them: `~/.claude/reference/rms-integrations-slack-channels.md`.
- When I ask for a Jira task for myself in the current sprint, follow `~/.claude/reference/jira-sprint-task.md`.
- When a message starts with `oncall:`, do the task, then log it with `/diary`.

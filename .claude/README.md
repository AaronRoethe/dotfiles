# Claude Code config

Global Claude Code setup (`~/.claude`). It's tracked in the dotfiles bare repo (`~/.cfg`, work tree `$HOME`) like the rest of the config. Almost everything here is Axon-internal, so the dotfiles repo must live on a **private** remote.

Nothing here is tied to one person. Personal values come from the dotfiles profile, `~/.env/profile.sh` (see `~/.github/README.md`). `CLAUDE.md` imports the profile with `@~/.env/profile.sh`, so every session, skill and agent sees the `PROFILE_*` values, and the hooks `source` it directly.

`~/.claude/.gitignore` is a whitelist. Claude Code writes a lot of state into `~/.claude` (sessions, history, caches, memory, plugin code), and all of it is ignored unless opted back in. The dotfiles repo respects this nested `.gitignore`.

## What's tracked

| Path                        | What it is                                                                                                                            |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `CLAUDE.md`                 | Global instructions loaded in every session: communication, git, GitHub hosts, commit/PR standards, Slack draft-only rule, delegation |
| `settings.json`             | Permissions allowlist, hooks, enabled plugins, plugin marketplaces, model                                                             |
| `hooks/`                    | Hook scripts wired up in `settings.json` (see below)                                                                                  |
| `agents/`                   | Subagents: `code-investigator`, `jira-collector`, `slack-reader`, `slack-writer`                                                      |
| `skills/`                   | Personal skills: `diary`, `pcg-investigate`, `pr`, `standup-daily`                                                                    |
| `reference/`                | Files `CLAUDE.md` points to: Jira sprint-task fields, RMS Integrations Slack channels                                                 |
| `mcp-servers.template.json` | MCP servers from `~/.claude.json`, with header values replaced by `<set-me>`                                                          |

Not tracked on purpose:

- `projects/*/memory/`: auto-memory is personal, and its folders are named after one machine's absolute paths. It stays local only. Knowledge worth sharing belongs in a repo's own `CLAUDE.md` or in the team plugin, where changes get reviewed.
- `plugins/`: the installed-plugin records hold machine-specific paths. `enabledPlugins` and `extraKnownMarketplaces` in `settings.json` are enough to reinstall them.
- `skills/synced/` (org skills re-synced from claude.ai), `skills/.trash/`, transcripts, and `~/.claude.json` (holds live MCP tokens).

## Hooks

| Script                | Event                           | Does                                                                                                                                                                                                                                                                                |
| --------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `guard-bash.sh`       | PreToolUse `Bash`               | Blocks `sudo`, `rm -rf` on `/` `~` `$HOME` `*` `.`, and force-push to main/master. Runs `gitleaks git --staged` before `git commit`. On `git push`, requires an `@axon.com` email for `git.taservs.net` / `github.com/axon-productivity` remotes, then always asks for confirmation |
| `guard-slack-send.sh` | PreToolUse `slack_send_message` | Denies direct Slack sends except to your own DM (`PROFILE_SLACK_USER_ID`). Everything else must be a draft. Without a profile, every direct send is denied                                                                                                                          |
| `format-on-write.sh`  | PostToolUse `Write\|Edit`       | `gofmt -w` on `.go` files                                                                                                                                                                                                                                                           |

The Bash guard's secret scan only covers plain `git commit` / `git -C <dir> commit` in the session's working directory. It does **not** cover dotfiles commits (`config commit`), so scan those by hand (see Managing).

Review or disable hooks with `/hooks`.

## Restore on a new Mac

1. Set up the dotfiles and fill in `~/.env/profile.sh` (see `~/.github/README.md`). The checkout puts these files in `~/.claude`, and the Brewfile installs `gitleaks` and `jq`, which the hooks need.
2. Install Claude Code and start `claude`. It registers the marketplaces listed in `settings.json` (`rms-skills`, `claude-code-warp`) and offers to install the enabled plugins. If any are missing, install them from `/plugin`.
3. MCP servers: add each server from `mcp-servers.template.json` with `claude mcp add --scope user ...`, filling in real tokens (DevBridge: Quip/Jira/Zephyr tokens; Splunk: auth header). Then run `/mcp` to log in to the OAuth ones (incident.io, claude.ai connectors).
4. `standup-daily` runs from launchd via a LaunchAgent plist (e.g. `~/Library/LaunchAgents/com.<user>.standup-daily.plist`) that calls `skills/standup-daily/run.sh`. The plist isn't tracked, so create it and run `launchctl load` on it. `run.sh` loads the profile itself. It also needs `~/go/bin/standup` (`cd ~/repos/standup-gen && go build -o ~/go/bin/standup ./cmd/standup/`).

## Managing

Use the dotfiles `config` alias. `status.showUntrackedFiles` is off, so new files under `~/.claude` don't show in `config status` until they're added:

```bash
config status                  # changes to tracked files (Claude edits settings and skills directly)
config add ~/.claude           # pick up new files; the whitelist .gitignore filters out the rest
config diff --cached --stat    # check what's staged
(cd ~ && GIT_DIR=~/.cfg GIT_WORK_TREE=~ gitleaks git --staged --no-banner --redact .)
config commit -m "chore(claude): ..."
```

- Keep personal values out of tracked files. Add a `PROFILE_*` variable to `~/.env/profile.sh` **and** `~/.env/profile.sh.example`, then refer to it by name.
- New top-level file or folder in `~/.claude`? Add a `!/<name>` line to `~/.claude/.gitignore`, or it won't be picked up.
- After adding or changing an MCP server, regenerate the template (it redacts header values):
  ```bash
  jq '{mcpServers: (.mcpServers | map_values(if .headers then .headers |= map_values("<set-me>") else . end))}' ~/.claude.json > ~/.claude/mcp-servers.template.json
  ```
- Never commit `~/.claude.json` or real tokens. Run the gitleaks line above before every commit that touches `~/.claude`.

#!/bin/zsh
# Runs the standup-daily skill headless. Invoked by a launchd LaunchAgent (see ~/.claude/README.md).
export PATH="$HOME/.local/bin:$HOME/go/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
cd "$HOME/repos" || exit 1
source "$HOME/.env/profile.sh"   # launchd has no login shell, so load the profile explicitly
LOG="$HOME/standups/logs/$(date +%Y-%m-%d).log"
claude -p "/standup-daily" \
  --allowedTools "Bash(~/go/bin/standup:*) Bash(echo:*) Bash(date:*) mcp__claude_ai_Atlassian__getAccessibleAtlassianResources mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql mcp__claude_ai_Google_Drive__list_recent_files mcp__claude_ai_Slack__slack_search_public_and_private mcp__claude_ai_Slack__slack_read_thread mcp__claude_ai_Slack__slack_send_message" \
  >> "$LOG" 2>&1

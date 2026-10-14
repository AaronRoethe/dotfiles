#!/bin/bash
# PreToolUse(slack_send_message): only allow direct sends to my own DM; everything else must be a draft.
input=$(cat)
[[ $(jq -r '.tool_name' <<<"$input") == "mcp__claude_ai_Slack__slack_send_message" ]] || exit 0
# My Slack ID comes from the dotfiles profile; if it is missing, every direct send is denied.
[[ -f ~/.env/profile.sh ]] && source ~/.env/profile.sh
[[ -n "$PROFILE_SLACK_USER_ID" && $(jq -r '.tool_input.channel_id // ""' <<<"$input") == "$PROFILE_SLACK_USER_ID" ]] && exit 0
jq -n --arg me "${PROFILE_SLACK_USER_ID:-unset — fill in ~/.env/profile.sh}" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:("Direct Slack sends are only allowed to my own DM (" + $me + "). Use slack_send_message_draft instead.")}}'

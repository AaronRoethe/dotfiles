#!/bin/bash
# PreToolUse(Bash): block dangerous commands, scan commits for secrets, gate git push.
input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
cwd=$(jq -r '.cwd // "."' <<<"$input")

decide() { # $1 = deny|ask, $2 = reason
  jq -n --arg d "$1" --arg r "$2" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  exit 0
}

if grep -Eq '(^|[;&|[:space:]])sudo[[:space:]]' <<<"$cmd"; then
  decide deny "sudo is blocked by hook. Run it yourself if needed."
fi
if grep -Eq 'rm[[:space:]]+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r|-r[[:space:]]+-f|-f[[:space:]]+-r)[a-zA-Z]*[[:space:]]+("|'"'"')?(/|~|\$HOME|\*|\.)("|'"'"')?/?\*?([[:space:];&|]|$)' <<<"$cmd"; then
  decide deny "rm -rf on /, ~, \$HOME, * or . is blocked by hook."
fi
if tr ';&|\n' '\n\n\n\n' <<<"$cmd" | grep -E '(^|[[:space:]])git[[:space:]]([^[:space:]]+[[:space:]]+)*push([[:space:]]|$)' | grep -E '(--force|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+)' | grep -Eq '(main|master)([[:space:]]|$)'; then
  decide deny "Force-push to main/master is blocked by hook."
fi

if grep -Eq 'git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?commit' <<<"$cmd"; then
  if command -v gitleaks >/dev/null && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    if ! out=$(cd "$cwd" && gitleaks git --staged --no-banner --redact . 2>&1); then
      decide deny "gitleaks found possible secrets in staged changes: $(tail -20 <<<"$out")"
    fi
  fi
fi

if grep -Eq 'git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?push' <<<"$cmd"; then
  url=$(git -C "$cwd" remote get-url origin 2>/dev/null)
  email=$(git -C "$cwd" config user.email)
  if [[ -z "$email" ]]; then
    decide deny "git user.email is not set for this repo. Set it before pushing."
  fi
  if [[ "$url" == *git.taservs.net* || "$url" == *github.com[:/]axon-productivity/* ]] && [[ "$email" != *@axon.com ]]; then
    decide deny "Pushing to $url as $email — work remotes need an @axon.com identity."
  fi
  decide ask "Push to ${url:-unknown remote} as $email — confirm."
fi
exit 0

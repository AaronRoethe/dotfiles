#!/bin/bash
# PostToolUse(Write|Edit): format the written file when a formatter for it is installed.
f=$(jq -r '.tool_response.filePath // .tool_input.file_path // ""')
case "$f" in
  *.go) command -v gofmt >/dev/null && gofmt -w "$f" ;;
esac
exit 0

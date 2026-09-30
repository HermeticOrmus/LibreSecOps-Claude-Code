#!/usr/bin/env bash
# =============================================================================
# LibreSecOps PreToolUse hook
# =============================================================================
# Runs before Edit, Write, and MultiEdit.
#
# Claude Code sends the hook input as JSON on stdin. This hook reads
# tool_name and tool_input.file_path with jq. When the target is a secrets or
# key file (.env files, *.pem, *.key, *.p12, *.pfx, keystores, SSH private
# keys, credentials or secrets files, service account keys) it returns a
# permission decision of "ask", so a person confirms the edit before it
# happens. For every other file it exits 0 without output.
#
# The security checklists for auth, database, API, config, and deployment
# files that this hook used to print now arrive after the edit, from
# post-tool-use.sh, next to the scan results for the same file.
#
# No network calls, no files written.
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat)"
TOOL_NAME="$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null || true)"
FILE_PATH="$(jq -r '.tool_input.file_path // empty' <<<"$INPUT" 2>/dev/null || true)"

case "$TOOL_NAME" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac
[[ -n "$FILE_PATH" ]] || exit 0

NAME="$(basename "$FILE_PATH")"
NAME_LOWER="$(tr '[:upper:]' '[:lower:]' <<<"$NAME")"

# Committed templates hold placeholders, not secrets.
if [[ "$NAME_LOWER" =~ \.(example|sample|template|dist)$ ]]; then
  exit 0
fi

KIND=""
if [[ "$NAME_LOWER" =~ ^\.env($|\.) || "$NAME_LOWER" =~ \.env$ ]]; then
  KIND="an environment file"
elif [[ "$NAME_LOWER" =~ \.(pem|key|p12|pfx|jks|keystore|truststore)$ || "$NAME_LOWER" =~ ^(keystore|truststore) ]]; then
  KIND="a private key or certificate store"
elif [[ "$NAME_LOWER" =~ ^id_(rsa|dsa|ecdsa|ed25519)$ ]]; then
  KIND="an SSH private key"
elif [[ "$NAME_LOWER" =~ private[_-]?key ]]; then
  KIND="a private key file"
elif [[ "$NAME_LOWER" =~ service[_-]?account.*\.json$ ]]; then
  KIND="a service account key"
elif [[ "$NAME_LOWER" =~ ^\.?[a-z0-9_-]*(credentials|secrets?)(\.(json|ya?ml|toml|ini|txt|env|conf|cfg|properties|xml))?$ ]]; then
  KIND="a credentials or secrets file"
fi

[[ -n "$KIND" ]] || exit 0

REASON="LibreSecOps: ${NAME} looks like ${KIND}. Confirm this edit, keep the file out of git (check .gitignore), and keep production values in a secrets manager rather than on disk."

jq -n --arg reason "$REASON" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: $reason
  }
}'
exit 0

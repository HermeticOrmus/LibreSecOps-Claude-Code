# libre-secops-hooks

> Optional Claude Code hooks that add security awareness to everyday editing: a project security profile at session start, a confirmation prompt before secret files change, and a local vulnerability pattern scan after each edit.

## Install

```
/plugin marketplace add HermeticOrmus/LibreSecOps-Claude-Code
/plugin install libre-secops-hooks@libre-secops
```

From a terminal: `claude plugin install libre-secops-hooks@libre-secops`. Restart Claude Code after installing. Remove it with `claude plugin uninstall libre-secops-hooks@libre-secops`, or turn it off without uninstalling with `claude plugin disable libre-secops-hooks@libre-secops`.

The scripts need `bash` and `jq`. Without `jq` they exit quietly and do nothing.

## What each hook does

Claude Code sends every hook its input as JSON on stdin. The scripts read `tool_name`, `tool_input.file_path`, and `cwd` from it with `jq`. They make no network calls and write no files.

| Event | Matcher | Script | Behavior |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `hooks/session-start.sh` | In a software project, prints one line that Claude reads as context: languages and frameworks, auth libraries, ORMs, Docker, Kubernetes, Terraform, CI systems, configured security tooling, gaps (a `.env` tracked by git, no `.env` rule in `.gitignore`, no lockfile, no security headers setup, no security tooling), and the LibreSecOps plugins that fit the stack. Outside a software project it prints nothing. |
| PreToolUse | `Edit\|Write\|MultiEdit` | `hooks/pre-tool-use.sh` | When the target is a secrets or key file (`.env` files, `*.pem`, `*.key`, `*.p12`, `*.pfx`, keystores, SSH private keys, credentials or secrets files, service account keys) it returns `permissionDecision: "ask"`, so you confirm the edit. Templates such as `.env.example` pass through. Every other file passes silently. |
| PostToolUse | `Edit\|Write\|MultiEdit` | `hooks/post-tool-use.sh` | Scans the edited file (first 100 KB) for SQL injection, XSS sinks, hardcoded secrets, weak cryptography, command injection, path traversal, CORS mistakes, missing input validation, unsafe deserialization, auth endpoints without rate limiting, and Dockerfile issues. For auth, database, API, CORS, security header, Kubernetes, Terraform, and CI/CD files it adds a short checklist and points at nearby middleware, rate limiting, or validation files. Results reach Claude as `additionalContext`; a CRITICAL finding also shows you a one-line `systemMessage`. Clean files produce no output. |

The scan is regex pattern matching, so it reports possible issues, not verdicts. Claude is told to verify each finding before acting on it.

## Trying a script by hand

```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":".env"},"cwd":"."}' \
  | bash plugins/libre-secops-hooks/hooks/pre-tool-use.sh
```

## Upgrading from 0.x

Before 1.0.0 these scripts lived in the repository's root `hooks/` folder with a `settings.json` that pointed at a `LIBRESECOPS_HOOKS_DIR` variable, and `setup.sh` did not register them, so they never ran. They also wrote log files next to themselves, and their context output used a top-level `additionalContext` array that Claude Code does not read. The wiring from that `settings.json` (same events, same matchers) now lives in this plugin's `hooks/hooks.json`. If you copied the old block into your own Claude Code settings, remove it and install this plugin instead.

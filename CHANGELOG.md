# Changelog

## [1.0.0] - 2026-09-30

LibreSecOps is now a Claude Code plugin marketplace. Every plugin installs with `/plugin install`, and every agent, command, and skill tells Claude when it applies, so the right specialist gets picked from what you ask.

### Added

- Marketplace manifest `.claude-plugin/marketplace.json` (marketplace name `libre-secops`) and a `.claude-plugin/plugin.json` for each plugin. Install with `/plugin marketplace add HermeticOrmus/LibreSecOps-Claude-Code`, then `/plugin install <plugin>@libre-secops`.
- Frontmatter on all 174 agent, command, and skill files (64 agents, 53 commands, 57 skills). Agent descriptions say when to use the agent ("Use this agent when ...") and name the sibling agent where two could overlap; commands carry an `argument-hint`; skills say what they provide and when to use them. The penetration testing, red team, bug bounty, malware analysis, phishing simulation, and scanning descriptions keep the pack's framing: authorized engagements, agreed scope, and isolated labs only.
- `libre-secops-hooks`, an optional plugin that makes the repository's hook scripts run: one line of security context about the project at session start, a confirmation prompt before Claude edits `.env`, key, or credentials files, and a local vulnerability pattern scan after each edit. See `plugins/libre-secops-hooks/README.md`.
- CI (`.github/workflows/validate.yml`): validates the marketplace and every plugin, then installs all of them into a clean Claude Code config, on pushes to `main` and on pull requests.
- A feedback issue form (`.github/ISSUE_TEMPLATE/feedback.yml`) and a Feedback section in the README.

### Changed

- `setup.sh` registers the checkout as a marketplace and installs through the Claude Code CLI (`claude plugin marketplace add`, `claude plugin install`). New flags: `--list`, `--scope user|project|local`, `--uninstall`. `--only` still works. `--plugins-dir` is accepted and ignored with a note. It now needs `claude` and `jq` on PATH.
- Commands are namespaced by plugin, as Claude Code does for every plugin: `/threat-model` runs as `/threat-modeling:threat-model`. README, QUICK_START, and TROUBLESHOOTING use the new names.
- `threat-modeler` was pinned to `model: sonnet`. Every agent now uses `model: inherit` and runs on your session's model.
- `threat-modeling/skills/threat-modeling.md` moved to `threat-modeling/skills/threat-modeling/SKILL.md`, the layout Claude Code loads as a skill. Its content is unchanged.
- The hook scripts moved from `hooks/` to `plugins/libre-secops-hooks/hooks/`, and `hooks/settings.json` became that plugin's `hooks/hooks.json` with the same events and matchers. The PreToolUse hook now asks for confirmation on secret files instead of printing advice; the per-file-type security checklists it used to print arrive after the edit, from the PostToolUse hook.
- README: each plugin table lists the plugin's agents, the plugin tables and counts match the manifests, and the install section covers `/plugin`, the `claude plugin` CLI, and `setup.sh`.

### Fixed

- The old `setup.sh` copied plugin folders into `~/.claude/plugins/libre-secops-*`, which Claude Code does not load as plugins. If you installed an earlier version: run `./setup.sh` again (or use `/plugin install`), then delete the old `~/.claude/plugins/libre-secops-*` copies.
- The hook scripts were never registered, so they never ran. They also wrote log files inside the hooks folder and returned context as a top-level `additionalContext` array, which is not part of the Claude Code hook output format. They now read the hook JSON with `jq`, write nothing to disk, return results through `hookSpecificOutput`, and run under bash 3.2 (the macOS default) as well as newer bash. Hook timeouts are now in seconds, the unit Claude Code uses (the old wiring said 5000 and 2000).
- Scanner accuracy: the private key check never ran (its pattern starts with `-`, so grep read it as an option); `Math.random()` was reported as a security finding on every use; any `.update(...).digest()` chain, SHA-256 included, was reported as MD5; `TLSv1_2` was reported as TLS 1.0; lowercase `aes-128-ecb` was missed; Python-only and PHP-only deserialization checks fired on other languages.
- README plugin tables listed a `serverless-patterns` plugin that is not in this pack and listed `social-engineering-defense` twice. Domain notes that named frameworks the plugins do not cover (OSSTMM, BeyondCorp, Cloud Armor, API fuzzing, OWASP Mobile Top 10, DPI) now name what the plugins do cover.

## [0.2.0] — 2026-05-23

Doc chrome rewrite + first flagship plugin depth-complete.

### Added
- README rewrite matching the LibreUIUX template
- QUICK_START with 20-minute threat-modeling walkthrough
- CONTRIBUTING, CHANGELOG, TROUBLESHOOTING
- setup.sh installer
- 3-tier learning paths (beginner / intermediate / advanced)
- **threat-modeling** plugin promoted to depth-complete (STRIDE, attack trees, MITRE ATT&CK mapping, DREAD scoring)

### Per-plugin maturity (32 plugins)

| Status | Count |
|---|---|
| depth-complete | 1 (threat-modeling) |
| shell-improved | 31 |

Depth pass scheduled for v0.3-v0.5:
- v0.3: incident-response, penetration-testing, web-application-security
- v0.4: cloud-security-aws, kubernetes-security, container-security, secrets-management
- v0.5: identity-access-management, zero-trust-architecture, compliance-frameworks

## [0.1.0] — 2026-03-01

Initial release. 32 plugin shells with templated content.

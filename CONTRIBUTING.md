# Contributing

Security is wide. PRs welcome for plugin depth, regional compliance, real-world incident case studies (anonymized).

## What we welcome

- Bug fixes in any plugin
- Depth pass on shell-improved plugins (most welcome — see CHANGELOG maturity matrix)
- Regional compliance translations (LATAM LGPD, India DPDP, AU Privacy Act, etc.)
- Cloud-specific deep dives (per AWS service, per Azure service, per GCP service)
- Real-world incident case studies (anonymized)
- Worked examples per plugin

## What we don't accept

- Offensive content without explicit defensive framing
- Content that violates responsible disclosure norms
- Vendor-specific patterns without an open alternative
- AI-generated content without security-domain verification

## Setup

```bash
git clone https://github.com/<your-username>/LibreSecOps-Claude-Code.git
cd LibreSecOps-Claude-Code
./setup.sh
```

## Branch / PR

`feat/`, `fix/`, `deepen/<plugin>`, `region/<plugin>`, `casestudy/<slug>`.

Commit format: `type(scope): description`.

PR template:
- Why (1-3 sentences)
- What changed (bullets)
- How to verify (scenario + expected response)
- Compliance considerations (if applicable)
- Notes

## Plugin-authoring conventions

Each plugin: `plugins/<name>/` with `README.md`, `agents/<name>.md`, `commands/<name>.md`, `skills/<name>.md`. See `threat-modeling` for the depth-complete reference.

Since 1.0.0 the pack is a Claude Code plugin marketplace, so each plugin also needs:

- `plugins/<name>/.claude-plugin/plugin.json` and a matching entry in `.claude-plugin/marketplace.json` (same description in both)
- Skills as `skills/<skill-name>/SKILL.md`, not loose `skills/<name>.md` files
- Frontmatter on every file: agents take `name`, `description` ("Use this agent when ..."), and `model: inherit`; commands take `description` (plus `argument-hint` when they take input); skills take `name` and `description` ("... Use when ...")

Check your change before opening a PR:

```bash
claude plugin validate .
claude plugin validate plugins/<name>
```

CI runs the same checks and a clean install of every plugin.

## License

MIT. By submitting PRs you agree to MIT licensing. No CLA.

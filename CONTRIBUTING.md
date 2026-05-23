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

## License

MIT. By submitting PRs you agree to MIT licensing. No CLA.

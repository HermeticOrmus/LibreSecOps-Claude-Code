# Contributing

Security is wide. PRs welcome for plugin depth, regional compliance, real-world incident case studies (anonymized).

## Ways to contribute

### Take a Menu item

The [Menu](pantry/MENU.md) lists the next pieces of work, each with a Done-when anyone can check. It is generated from the [pantry](pantry/README.md), which cites where every item came from. Menu items that have been opened for work are issues labeled [`menu`](https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/issues?q=is%3Aopen+label%3Amenu), and smaller starter tasks are listed under [good first issues](https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/contribute). Claim one by commenting on its issue, then open a pull request that says `Closes #N`.

### Report or fix a routing miss

Every agent, command and skill has a `description` that Claude Code reads to decide when to use it. With 64 agents, two per plugin, a wrong pick is easy to hit. When Claude picks the wrong one, or none, open a [routing miss](https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/issues/new?template=routing-miss.yml) with your prompt and what should have run. To fix one yourself, sharpen the `description` in the frontmatter of the file that should have answered, in the forms under [Plugin-authoring conventions](#plugin-authoring-conventions); where two agents in a plugin overlap, say in each description when to use the sibling instead.

### Propose or build a plugin

Open a [plugin proposal](https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/issues/new?template=plugin-proposal.yml) first, so the job, the gap and the Done-when are agreed before you write it. A plugin here has this layout:

```text
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json      # name, version, description, author, keywords
├── README.md
├── agents/
│   └── <agent-name>.md  # frontmatter: name, description, model: inherit
├── commands/
│   └── <command>.md     # frontmatter: description, argument-hint
└── skills/
    └── <skill-name>/
        └── SKILL.md     # frontmatter: name, description
```

Existing plugins ship two agents, one or two commands and one to three skills. Each `description` is routing text: it says when Claude should use the file. The plugin also needs an entry in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) with the same description as its `plugin.json`.

Offensive-capable work (penetration testing, red teaming, bug bounty recon, scanning, malware analysis, phishing simulation) keeps the pack's framing: the description says it is for authorized engagements, agreed scope or isolated labs, and the agent confirms authorization before it produces test steps, as `pentest-planner` and `red-team-lead` do.

### Translate

The docs are English only. Two kinds of translation help. Regional compliance mappings (Brazil LGPD, India DPDP, the Australian Privacy Act) belong in the compliance-frameworks and privacy-engineering plugins, cited to the law's official text. Translations of the README, QUICK_START or the [learning paths](learning-paths/) go next to the source as `<name>.<lang>.md` (for example `QUICK_START.es.md`), linked from it, with code, commands and tool output left as they are.

### Share what you built

Post threat models, detection rules, playbooks and workflows built with the pack in [Discussions, Show and tell](https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/discussions/categories/show-and-tell). Remove anything that identifies a real target, customer or incident first.

### Test your change locally

These commands match `claude --help` and `claude plugin validate --help` in Claude Code 2.1.286. Run them from the repository root:

```bash
# Validate the marketplace manifest and the plugin you changed
claude plugin validate .
claude plugin validate plugins/<name>

# Load your working copy for one session, without installing it
claude --plugin-dir plugins/<name>

# Install from a clean config, the way CI does
export CLAUDE_CONFIG_DIR=$(mktemp -d)
claude plugin marketplace add ./
claude plugin install <name>@libre-secops
claude plugin details <name>@libre-secops
unset CLAUDE_CONFIG_DIR
```

`claude plugin details` shows the agents and skills Claude Code loaded from the plugin (commands are listed with the skills) and the tokens each one adds to a session. `claude plugin validate --strict` also fails on warnings. The `libre-secops-hooks` plugin needs `jq` on your PATH.

CI runs the same checks on every pull request: it validates the marketplace and every plugin, then installs all of them into a clean config. A first-time contributor's CI run waits for a maintainer to approve it.

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

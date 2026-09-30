# Quick start

Twenty minutes from clone to your first threat model.

## 1. Install

Inside Claude Code:

```
/plugin marketplace add HermeticOrmus/LibreSecOps-Claude-Code
/plugin install threat-modeling@libre-secops
```

Or install the whole pack from a clone:

```bash
git clone https://github.com/HermeticOrmus/LibreSecOps-Claude-Code.git ~/projects/LibreSecOps-Claude-Code
cd ~/projects/LibreSecOps-Claude-Code
./setup.sh
```

`setup.sh` installs every plugin through the Claude Code CLI (it needs `claude` and `jq`). Restart Claude Code.

### Install in Grok Build

Grok Build reads the same plugin folders. Add the marketplace and install a plugin, or install one plugin straight from its folder:

```bash
grok plugin marketplace add HermeticOrmus/LibreSecOps-Claude-Code
grok plugin install threat-modeling@LibreSecOps-Claude-Code --trust
# or, without the marketplace:
grok plugin install HermeticOrmus/LibreSecOps-Claude-Code#plugins/threat-modeling --trust
```

From a clone, `./setup.sh --grok` installs every plugin through the `grok` CLI. Start a new Grok session to load them. The `libre-secops-hooks` plugin uses a hook format Grok supports, but it has not been verified in a live Grok session.

## 2. Pick a feature to threat-model

Use a real feature you're about to ship. Threat modeling abstract systems produces abstract output.

## 3. Ask the threat-model agent

```
/threat-modeling:threat-model build a STRIDE threat model for a SaaS feature: multi-tenant document storage. Users upload files via web upload, downloaded via signed URLs from S3, with sharing links that have configurable TTLs. Auth is OAuth2 via Google + email/password. The system is for B2B small teams (~10 users per tenant).
```

Expected output: scope statement, trust boundary map, STRIDE walk per boundary, ~10-15 specific threats with DREAD scores, mitigations, and MITRE ATT&CK mappings. Top 3 threats called out for executive review.

If the response is generic ("an attacker could...") instead of specific to your system, the plugin didn't install correctly.

## 4. Add ATT&CK detection plan

For each accepted-risk threat (not mitigated to zero), ask:

```
/threat-modeling:threat-model for the top 3 threats in the previous model, design detection for each. What logs, what alert rules, what alert thresholds? Output as Sigma rules where possible.
```

## 5. Iterate with the team

Threat model is design work, not audit checkbox. Bring it to the engineering team. Argue about scope, attacker profile, mitigation cost. The argument IS the work; the document is a record of the argument.

## What's next

- **[Beginner](learning-paths/beginner.md)** — security mindset shifts, your first threat model
- **[Intermediate](learning-paths/intermediate.md)** — DevSecOps integration, IR playbooks
- **[Advanced](learning-paths/advanced.md)** — red/blue exercises, compliance, zero-trust

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues.

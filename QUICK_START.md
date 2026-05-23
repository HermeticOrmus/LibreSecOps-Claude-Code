# Quick start

Twenty minutes from clone to your first threat model.

## 1. Install

```bash
git clone https://github.com/HermeticOrmus/LibreSecOps-Claude-Code.git ~/projects/LibreSecOps-Claude-Code
cd ~/projects/LibreSecOps-Claude-Code
./setup.sh
```

Restart Claude Code.

## 2. Pick a feature to threat-model

Use a real feature you're about to ship. Threat modeling abstract systems produces abstract output.

## 3. Ask the threat-model agent

```
/threat-model build a STRIDE threat model for a SaaS feature: multi-tenant document storage. Users upload files via web upload, downloaded via signed URLs from S3, with sharing links that have configurable TTLs. Auth is OAuth2 via Google + email/password. The system is for B2B small teams (~10 users per tenant).
```

Expected output: scope statement, trust boundary map, STRIDE walk per boundary, ~10-15 specific threats with DREAD scores, mitigations, and MITRE ATT&CK mappings. Top 3 threats called out for executive review.

If the response is generic ("an attacker could...") instead of specific to your system, the plugin didn't install correctly.

## 4. Add ATT&CK detection plan

For each accepted-risk threat (not mitigated to zero), ask:

```
/threat-model for the top 3 threats in the previous model, design detection for each. What logs, what alert rules, what alert thresholds? Output as Sigma rules where possible.
```

## 5. Iterate with the team

Threat model is design work, not audit checkbox. Bring it to the engineering team. Argue about scope, attacker profile, mitigation cost. The argument IS the work; the document is a record of the argument.

## What's next

- **[Beginner](learning-paths/beginner.md)** — security mindset shifts, your first threat model
- **[Intermediate](learning-paths/intermediate.md)** — DevSecOps integration, IR playbooks
- **[Advanced](learning-paths/advanced.md)** — red/blue exercises, compliance, zero-trust

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues.

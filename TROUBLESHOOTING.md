# Troubleshooting

## Plugins not loaded

```bash
ls ~/.claude/plugins/ | grep -c '^libre-secops-'
```

Should print 32. If not, re-run `./setup.sh` and restart Claude Code.

## Agent gives generic answers

As of v0.2, only `threat-modeling` is depth-complete. Other 31 plugins are shell-improved. Depth scheduled v0.3-v0.5.

## Common security scenarios the agents help diagnose

- "What's the threat model for X?" → `/threat-model`
- "Did our incident follow the playbook?" → `/incident-response` (v0.3)
- "Is this code SQL-injectable?" → `/web-application-security` (v0.3)
- "How do I configure Kubernetes Pod Security Standards?" → `/kubernetes-security` (v0.4)
- "What's our SOC 2 evidence for this control?" → `/compliance-frameworks` (v0.5)

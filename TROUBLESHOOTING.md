# Troubleshooting

## Plugins not loaded

```bash
claude plugin list | grep -c '@libre-secops'
```

Should print 33 after a full `./setup.sh` (32 domain plugins plus `libre-secops-hooks`), or the number you picked with `--only`. If a plugin is missing, run `./setup.sh --only <plugin>` or `/plugin install <plugin>@libre-secops`, then restart Claude Code.

Before 1.0.0, `setup.sh` copied folders into `~/.claude/plugins/libre-secops-*`. Claude Code does not load plugins from copied folders, so those copies can be deleted once the marketplace install works.

## A slash command is not found

Plugin commands are namespaced by plugin: `/threat-modeling:threat-model`, not `/threat-model`. Type `/` and the plugin name to see what a plugin offers.

## Agent gives generic answers

`threat-modeling` was the first plugin taken to full depth (v0.2). Since 1.0.0 every agent also carries a routing description, so Claude picks the right specialist from what you ask. If it still answers generically, name the agent: `@agent-<plugin>:<agent>`, for example `@agent-incident-response:incident-commander`.

## Hooks do nothing

The hooks live in the optional `libre-secops-hooks` plugin and need `jq`. Check it is installed and enabled with `claude plugin list`, and that `jq --version` works. The session-start line only appears in a software project (a package manifest, Dockerfile, Kubernetes manifests, Terraform, or CI config in the working directory).

## Common security scenarios the agents help diagnose

- "What's the threat model for X?" → `/threat-modeling:threat-model`
- "Did our incident follow the playbook?" → `/incident-response:incident-response`
- "Is this code SQL-injectable?" → `/web-application-security:owasp-scan` or `/secure-coding-practices:secure-review`
- "How do I configure Kubernetes Pod Security Standards?" → `/kubernetes-security:k8s-sec-audit`
- "What's our SOC 2 evidence for this control?" → `/compliance-frameworks:compliance-check`

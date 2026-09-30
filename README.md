<p align="center">
  <img src="https://ormus.solutions/mascot/pixellab_liquid_to_hylian_shield.gif" alt="LibreSecOps Claude Code" width="128" style="image-rendering: pixelated;" />
</p>

<h1 align="center">LibreSecOps Claude Code</h1>

<p align="center">
  <em>Security operations with Claude Code — 32 specialized plugins plus an optional hooks plugin, covering DevSecOps, threat modeling, incident response, authorized penetration testing, and cloud security</em>
</p>

<p align="center">
  <a href="https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/stargazers"><img src="https://img.shields.io/github/stars/HermeticOrmus/LibreSecOps-Claude-Code?style=flat-square&color=aa8142" alt="Stars" /></a>
  <a href="https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/main/LICENSE"><img src="https://img.shields.io/github/license/HermeticOrmus/LibreSecOps-Claude-Code?style=flat-square&color=aa8142" alt="License" /></a>
  <img src="https://img.shields.io/badge/Security-aa8142?style=flat-square&logo=hackthebox&logoColor=white" alt="Security" />
  <img src="https://img.shields.io/badge/Claude_Code-aa8142?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code" />
</p>

---

> **Skills, agents, commands, and workflows for security operations with Claude Code.**

Security work is asymmetric. Defenders must be right every time. Attackers need to be right once. Generic AI coding produces "looks secure" code that fails real adversarial review. **LibreSecOps gives Claude Code the security-domain expertise needed to ship systems that survive real attacks.**

Thirty-two domain plugins covering blue team, red team, cloud security, application security, compliance, and the operational layer that sits between them.

---

## The shift this kit responds to

Karpathy, December 2025: programming is being refactored. For security specifically, AI-generated code introduces new vulnerability surfaces — prompt injection, supply-chain risks, misuse of cryptographic primitives, over-permissive IAM. The defenders' toolkit has to evolve with the threats.

### Where LibreSecOps fits

| Claude Code component | LibreSecOps provides |
|---|---|
| **Plugins** | 32 subdomain plugins (threat modeling, IR, pentesting, cloud sec, app sec, compliance, more) plus the optional `libre-secops-hooks` plugin |
| **Agents** | 64 specialist agents, two per plugin (threat modeler, incident commander, pentest planner, detection engineer, and more) |
| **Commands** | 53 slash commands, namespaced by plugin (for example `/threat-modeling:threat-model`) |
| **Skills** | 57 pattern libraries (STRIDE, MITRE ATT&CK mappings, OWASP categories, NIST controls) |
| **Hooks** | Optional: a security profile of the project at session start, a confirmation prompt before edits to secret files, and a vulnerability pattern scan after each edit |
| **Templates** | Threat model templates, IR playbooks, audit-evidence scaffolds |

---

## The 32 plugins

### Defensive operations (Blue team)

| Plugin | Domain | Agents |
|---|---|---|
| **threat-modeling** ⭐ | STRIDE, attack trees, MITRE ATT&CK mapping | `attack-tree-builder`, `threat-modeler` |
| blue-team-detection | Detection engineering, alerting, SIEM rule design | `detection-engineer`, `threat-hunter` |
| incident-response | IR playbooks, containment, forensics handoff | `forensic-analyst`, `incident-commander` |
| siem-log-management | Log normalization, alert tuning, threat hunting | `log-analyst`, `siem-architect` |
| forensics-analysis | Digital forensics, evidence chain, memory analysis | `digital-forensics-examiner`, `memory-forensics-analyst` |
| malware-analysis | Static + dynamic analysis, sandboxing, IoC extraction | `dynamic-analyst`, `static-analyst` |
| security-automation | SOAR, playbook automation, response orchestration | `automation-builder`, `soar-architect` |
| security-awareness | Phishing training, user education, social engineering defense | `policy-writer`, `security-trainer` |
| social-engineering-defense | Anti-phishing, anti-pretexting, anti-vishing | `awareness-program-designer`, `social-engineering-analyst` |

### Offensive operations (Red team, authorized testing only)

| Plugin | Domain | Agents |
|---|---|---|
| penetration-testing | Pentest methodology (PTES, OWASP Testing Guide, NIST SP 800-115), scoping, rules of engagement, reporting | `pentest-planner`, `vuln-researcher` |
| red-team-operations | Adversary emulation planning, rules of engagement, MITRE ATT&CK mapping, detection validation | `red-team-lead`, `ttp-researcher` |
| bug-bounty-methodology | Recon, vulnerability discovery, responsible disclosure | `bug-bounty-hunter`, `vuln-report-writer` |
| vulnerability-scanning | Scanner selection (Nessus, Qualys, OpenVAS), false-positive triage | `vuln-scanner-orchestrator`, `vuln-triager` |
| api-security-testing | OWASP API Top 10: BOLA, BFLA, mass assignment, auth flows, GraphQL-specific | `api-security-tester`, `auth-flow-auditor` |
| web-application-security | OWASP Top 10, XSS, SQLi, CSRF, authentication flaws | `web-security-auditor`, `xss-hunter` |

### Cloud security

| Plugin | Domain | Agents |
|---|---|---|
| cloud-security-aws | AWS IAM, KMS, GuardDuty, Security Hub, well-architected security pillar | `aws-compliance-auditor`, `aws-security-architect` |
| cloud-security-azure | Azure AD, Defender, Sentinel, Conditional Access | `azure-compliance-auditor`, `azure-security-architect` |
| cloud-security-gcp | GCP IAM, Security Command Center, Organization Policies, VPC Service Controls | `gcp-org-policy-auditor`, `gcp-security-architect` |
| container-security | Image scanning, runtime security, SBOM, Distroless | `container-hardener`, `image-scanner` |
| kubernetes-security | Pod Security Standards, RBAC, NetworkPolicies, OPA Gatekeeper | `k8s-policy-enforcer`, `k8s-security-architect` |

### Application + supply chain security

| Plugin | Domain | Agents |
|---|---|---|
| secure-coding-practices | Language-specific anti-patterns (SQL injection, deserialization, etc.) | `input-validation-specialist`, `secure-code-reviewer` |
| supply-chain-security | SBOM, SLSA, dependency confusion, typosquatting defense | `dependency-auditor`, `package-integrity-analyst` |
| devsecops-pipelines | Shift-left security, SAST/DAST/SCA in CI | `devsecops-architect`, `pipeline-security-integrator` |
| cryptography-essentials | Symmetric vs asymmetric, key management, common mistakes (ECB, IV reuse) | `crypto-advisor`, `tls-specialist` |
| secrets-management | Vault, AWS Secrets Manager, GCP Secret Manager, rotation patterns | `secret-scanner`, `secrets-architect` |
| mobile-app-security | OWASP MASVS and MASTG, certificate pinning, keychain security | `mobile-code-reviewer`, `mobile-security-tester` |

### Identity + access

| Plugin | Domain | Agents |
|---|---|---|
| identity-access-management | RBAC, ABAC, OAuth2, OIDC, SAML, just-in-time access | `access-control-auditor`, `iam-architect` |
| zero-trust-architecture | Beyond perimeter, identity-first networking, microsegmentation | `microsegmentation-specialist`, `zero-trust-architect` |
| privacy-engineering | GDPR, CCPA, data minimization, privacy-by-design patterns | `dpia-analyst`, `privacy-engineer` |

### Compliance + governance

| Plugin | Domain | Agents |
|---|---|---|
| compliance-frameworks | SOC 2, ISO 27001, PCI DSS, HIPAA, NIST CSF mappings | `compliance-auditor`, `evidence-collector` |
| security-hardening | CIS benchmarks, host hardening, network hardening, OS-specific configs | `benchmark-auditor`, `hardening-specialist` |
| network-security | Firewall design, segmentation, IDS/IPS, DNS security | `ids-ips-engineer`, `network-security-architect` |

⭐ = flagship plugin, the first taken to full depth (see the 0.2.0 entry in the [CHANGELOG](CHANGELOG.md)). Every plugin ships two agents, one or two slash commands, and one to three skills.

### Optional hooks plugin

| Plugin | What it does |
|---|---|
| libre-secops-hooks | At session start, one line of security context about the project (stack, auth libraries, infrastructure, security tooling, gaps such as a `.env` tracked by git). Before an edit to a `.env`, key, or credentials file, a confirmation prompt. After each edit, a local pattern scan for injection, XSS, hardcoded secrets, weak crypto, and Dockerfile issues. See [its README](plugins/libre-secops-hooks/README.md). |

---

## Quick start

### Install from Claude Code

```
/plugin marketplace add HermeticOrmus/LibreSecOps-Claude-Code
/plugin install threat-modeling@libre-secops
```

Install any other plugin the same way (`/plugin install <plugin>@libre-secops`), or open `/plugin` to browse the pack. From a terminal, the equivalent is:

```bash
claude plugin marketplace add HermeticOrmus/LibreSecOps-Claude-Code
claude plugin install threat-modeling@libre-secops
```

The optional hooks plugin installs the same way: `/plugin install libre-secops-hooks@libre-secops` (it needs `jq`; see [its README](plugins/libre-secops-hooks/README.md)). Restart Claude Code after installing.

### Install the whole pack with setup.sh

```bash
git clone https://github.com/HermeticOrmus/LibreSecOps-Claude-Code.git ~/projects/LibreSecOps-Claude-Code
cd ~/projects/LibreSecOps-Claude-Code
./setup.sh
```

`setup.sh` registers the checkout as a plugin marketplace and installs every plugin through the Claude Code CLI, including `libre-secops-hooks`. It needs `claude` and `jq` on your PATH. Useful flags: `--list` shows the plugins, `--only threat-modeling,incident-response` installs a subset (leave `libre-secops-hooks` out of the list to skip the hooks), `--scope project` installs for the current project only, and `--uninstall` removes the pack.

### Use it

Then in any Claude Code session:

```
/threat-modeling:threat-model build a STRIDE threat model for a SaaS application with multi-tenant data, OAuth2 social login, file upload, and a public REST API
```

Plugin commands are namespaced as `/<plugin>:<command>`, so the `/threat-model` command in the plugin docs runs as `/threat-modeling:threat-model`. Agents are chosen automatically from their descriptions, or you can call one directly, for example `@agent-incident-response:incident-commander`.

See [QUICK_START.md](QUICK_START.md) for the full walkthrough.

---

## Learning paths

- **[Beginner](learning-paths/beginner.md)** — security mindset shifts, your first threat model, OWASP Top 10
- **[Intermediate](learning-paths/intermediate.md)** — DevSecOps integration, IR playbooks, cloud security posture
- **[Advanced](learning-paths/advanced.md)** — red team / blue team exercises, compliance audit prep, zero-trust migration

---

## Compatibility

- **Cloud platforms**: AWS, Azure, GCP (parity across the three)
- **Container/orchestration**: Docker, Kubernetes, ECS, GKE, AKS
- **Compliance frameworks**: SOC 2, ISO 27001, PCI DSS, HIPAA, NIST CSF, FedRAMP, GDPR
- **Languages**: Python, TypeScript, Go, Rust, Java, .NET
- **Skill level**: developers entering security through senior security engineers
- **Claude Code**: installs as a plugin marketplace (tested with Claude Code 2.1.285); the hooks plugin needs `bash` and `jq`

---

## Disclaimer

This kit is for **defensive security and authorized testing only**. The offensive plugins (penetration-testing, red-team-operations, bug-bounty-methodology) are intended for use with explicit authorization. Unauthorized testing is illegal in most jurisdictions.

This is documentation + prompt-engineering. It is **not**:
- Legal advice on compliance
- A replacement for certified security professionals
- An audit certification

For regulated systems, retain licensed security counsel and accredited auditors.

---

## Feedback

Starred this? Tell us what worked and what is missing: [open a feedback issue](https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/issues/new?template=feedback.yml). Every piece of feedback gets an answer, and changes that come from it are credited in the release notes.

---

## Contributing

PRs welcome — especially: more depth on cloud security per platform, regional compliance translations (LATAM LGPD, India DPDP, etc.), real-world incident case studies (anonymized), supply-chain attack postmortems.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.

---

## Part of the Libre Open-Source Stack for Claude Code

This repository is part of a growing family of open-source toolkits for Claude Code.

### Libre suite — comprehensive plugin bundles

- [LibreUIUX-Claude-Code](https://github.com/HermeticOrmus/LibreUIUX-Claude-Code) — UI/UX development (152 agents, 70 plugins, 76 commands, 74 skills)
- [LibreArch-Claude-Code](https://github.com/HermeticOrmus/LibreArch-Claude-Code) — Software architecture and system design
- [LibreCopy-Claude-Code](https://github.com/HermeticOrmus/LibreCopy-Claude-Code) — Technical writing and documentation engineering
- [LibreDevOps-Claude-Code](https://github.com/HermeticOrmus/LibreDevOps-Claude-Code) — DevOps engineering and infrastructure automation
- [LibreEmbed-Claude-Code](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code) — Embedded systems, firmware, and IoT development
- [LibreFinTech-Claude-Code](https://github.com/HermeticOrmus/LibreFinTech-Claude-Code) — Financial technology development
- [LibreGEO-Claude-Code](https://github.com/HermeticOrmus/LibreGEO-Claude-Code) — AI-search optimization (ChatGPT, Perplexity, Gemini, Google AI Overviews)
- [LibreGameDev-Claude-Code](https://github.com/HermeticOrmus/LibreGameDev-Claude-Code) — Game development across Godot, Unity, Unreal
- [LibreMLOps-Claude-Code](https://github.com/HermeticOrmus/LibreMLOps-Claude-Code) — ML engineering and AI operations
- [LibreMobileDev-Claude-Code](https://github.com/HermeticOrmus/LibreMobileDev-Claude-Code) — Mobile app development (Flutter, React Native, native iOS, native Android)
- [LibreSessionFlow-Claude-Code](https://github.com/HermeticOrmus/LibreSessionFlow-Claude-Code) — Session lifecycle: handoff, pickup, absorb, explore, close

### Skills mini-repos — single CLAUDE.md drop-ins

- [vibe-engineer-skills](https://github.com/HermeticOrmus/vibe-engineer-skills) — Direct AI codegen well: hypothesis before help, scoped prompts, validate before accepting
- [markdown-discipline-skills](https://github.com/HermeticOrmus/markdown-discipline-skills) — Strip AI-slop from markdown (no em dashes, no marketing fluff)
- [shell-safety-skills](https://github.com/HermeticOrmus/shell-safety-skills) — `set -euo pipefail` discipline plus 15 failure-mode examples
- [commit-standard-skills](https://github.com/HermeticOrmus/commit-standard-skills) — Ormus Commit Standard v1.0 plus commit-msg hook and commitlint
- [unwoke-skills](https://github.com/HermeticOrmus/unwoke-skills) — Strip AI theater (ten sins to eliminate, symmetric engagement)
- [python-conventions-skills](https://github.com/HermeticOrmus/python-conventions-skills) — Modern Python 3.11+ (types, pathlib, async, ruff, mypy, uv)
- [typescript-conventions-skills](https://github.com/HermeticOrmus/typescript-conventions-skills) — TypeScript strict mode, discriminated unions, Result types
- [hermetic-laws-skills](https://github.com/HermeticOrmus/hermetic-laws-skills) — Seven Hermetic Principles applied to engineering
- [riper-workflow-skills](https://github.com/HermeticOrmus/riper-workflow-skills) — Research / Innovate / Plan / Execute / Review systematic dev
- [six-day-cycle-skills](https://github.com/HermeticOrmus/six-day-cycle-skills) — Sustainable shipping cadence with mandatory rest
- [token-optimization-skills](https://github.com/HermeticOrmus/token-optimization-skills) — Claude Code token and context optimization
- [osint-skills](https://github.com/HermeticOrmus/osint-skills) — OSINT research methodology (multi-wave investigative spiral)
- [calcinate-skills](https://github.com/HermeticOrmus/calcinate-skills) — Stage 1 of the Magnum Opus (burn project bloat)
- [claude-md-overhaul-skills](https://github.com/HermeticOrmus/claude-md-overhaul-skills) — Audit CLAUDE.md and MEMORY.md against caps
- [session-handoff-skills](https://github.com/HermeticOrmus/session-handoff-skills) — Session handoff and pickup discipline
- [naming-skills](https://github.com/HermeticOrmus/naming-skills) — Product naming methodology (mine the brand's vocabulary)
- [magnum-opus-skills](https://github.com/HermeticOrmus/magnum-opus-skills) — Seven-stage alchemy applied to project transformation
- [mem-search-skills](https://github.com/HermeticOrmus/mem-search-skills) — Search claude-mem cross-session memory: search, filter, fetch
- [hypothesis-debugging-skills](https://github.com/HermeticOrmus/hypothesis-debugging-skills) — Hypothesis-driven debugging: reproduce, isolate, test, fix
- [vibe-proof-skills](https://github.com/HermeticOrmus/vibe-proof-skills) — Security hardening for vibe-coded full-stack apps
- [tdd-skills](https://github.com/HermeticOrmus/tdd-skills) — Test-driven development (Red-Green-Refactor) for JS/TS and Python
- [mars-skills](https://github.com/HermeticOrmus/mars-skills) — Production-readiness audit: the five mortal sins of vibe-coded MVPs
- [git-workflow-skills](https://github.com/HermeticOrmus/git-workflow-skills) — Clean git workflow: branch, atomic commits, reviewable PRs
- [code-review-skills](https://github.com/HermeticOrmus/code-review-skills) — Domain-aware code review: classify the code, then focus
- [code-comprehension-skills](https://github.com/HermeticOrmus/code-comprehension-skills) — Understand an unfamiliar codebase fast
- [dx-audit-skills](https://github.com/HermeticOrmus/dx-audit-skills) — Audit developer experience: docs, onboarding, tooling friction
- [setup-env-skills](https://github.com/HermeticOrmus/setup-env-skills) — Set up a project's development environment
- [automate-skills](https://github.com/HermeticOrmus/automate-skills) — Turn repetitive tasks into reliable automation scripts
- [quick-fix-skills](https://github.com/HermeticOrmus/quick-fix-skills) — Fast troubleshooting for common issues
- [prime-context-skills](https://github.com/HermeticOrmus/prime-context-skills) — Prime project context at the start of a session
- [auto-docs-skills](https://github.com/HermeticOrmus/auto-docs-skills) — Generate and maintain project documentation
- [learning-skills](https://github.com/HermeticOrmus/learning-skills) — Learn any technology: roadmaps, explanations, practice, cheatsheets, comparisons
- [linux-sysadmin-skills](https://github.com/HermeticOrmus/linux-sysadmin-skills) — Linux system administration: security, performance, diagnostics, monitoring, maintenance

### Template source

- [andrej-karpathy-skills](https://github.com/HermeticOrmus/andrej-karpathy-skills) — the canonical single-file CLAUDE.md pattern (fork of jiayuan_jy's original)

Star the family, not just one — that's how the suite stays coherent.

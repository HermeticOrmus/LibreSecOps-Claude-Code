<p align="center">
  <img src="https://ormus.solutions/mascot/pixellab_liquid_to_hylian_shield.gif" alt="LibreSecOps Claude Code" width="128" style="image-rendering: pixelated;" />
</p>

<h1 align="center">LibreSecOps Claude Code</h1>

<p align="center">
  <em>Security operations with Claude Code — 32 specialized plugins covering DevSecOps, threat modeling, incident response, penetration testing, and cloud security</em>
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
| **Plugins** | 32 subdomain plugins (threat modeling, IR, pentesting, cloud sec, app sec, compliance, more) |
| **Agents** | Specialist agents per plugin (threat modeler, IR commander, pentester, blue team analyst) |
| **Commands** | Quick-access slash commands per plugin |
| **Skills** | Pattern libraries (STRIDE, MITRE ATT&CK mappings, OWASP categories, NIST controls) |
| **Templates** | Threat model templates, IR playbooks, audit-evidence scaffolds |

---

## The 32 plugins

### Defensive operations (Blue team)

| Plugin | Domain |
|---|---|
| **threat-modeling** ⭐ | STRIDE, attack trees, MITRE ATT&CK mapping |
| blue-team-detection | Detection engineering, alerting, SIEM rule design |
| incident-response | IR playbooks, containment, forensics handoff |
| siem-log-management | Log normalization, alert tuning, threat hunting |
| forensics-analysis | Digital forensics, evidence chain, memory analysis |
| security-automation | SOAR, playbook automation, response orchestration |
| security-awareness | Phishing training, user education, social engineering defense |
| social-engineering-defense | Anti-phishing, anti-pretexting, anti-vishing |

### Offensive operations (Red team)

| Plugin | Domain |
|---|---|
| penetration-testing | Pentest methodology (PTES, OSSTMM), scoping, reporting |
| red-team-operations | Adversary emulation, C2 design, persistence techniques |
| bug-bounty-methodology | Recon, vulnerability discovery, responsible disclosure |
| social-engineering-defense | (paired with the offensive variant) |
| vulnerability-scanning | Scanner selection (Nessus, Qualys, OpenVAS), false-positive triage |
| api-security-testing | API fuzzing, BOLA, BFLA, mass assignment, GraphQL-specific |
| web-application-security | OWASP Top 10, XSS, SQLi, CSRF, authentication flaws |

### Cloud security

| Plugin | Domain |
|---|---|
| cloud-security-aws | AWS IAM, KMS, GuardDuty, Security Hub, well-architected security pillar |
| cloud-security-azure | Azure AD, Defender, Sentinel, Conditional Access |
| cloud-security-gcp | GCP IAM, Security Command Center, BeyondCorp, Cloud Armor |
| container-security | Image scanning, runtime security, SBOM, Distroless |
| kubernetes-security | Pod Security Standards, RBAC, NetworkPolicies, OPA Gatekeeper |
| serverless-patterns | Lambda security, Functions-as-a-Service IAM, event injection |

### Application + supply chain security

| Plugin | Domain |
|---|---|
| secure-coding-practices | Language-specific anti-patterns (SQL injection, deserialization, etc.) |
| supply-chain-security | SBOM, SLSA, dependency confusion, typosquatting defense |
| devsecops-pipelines | Shift-left security, SAST/DAST/SCA in CI |
| cryptography-essentials | Symmetric vs asymmetric, key management, common mistakes (ECB, IV reuse) |
| secrets-management | Vault, AWS Secrets Manager, GCP Secret Manager, rotation patterns |
| mobile-app-security | OWASP Mobile Top 10, certificate pinning, keychain security |

### Identity + access

| Plugin | Domain |
|---|---|
| identity-access-management | RBAC, ABAC, OAuth2, OIDC, SAML, just-in-time access |
| zero-trust-architecture | Beyond perimeter, identity-first networking, microsegmentation |
| privacy-engineering | GDPR, CCPA, data minimization, privacy-by-design patterns |

### Compliance + governance

| Plugin | Domain |
|---|---|
| compliance-frameworks | SOC 2, ISO 27001, PCI DSS, HIPAA, NIST CSF mappings |
| security-hardening | CIS benchmarks, host hardening, network hardening, OS-specific configs |
| malware-analysis | Static + dynamic analysis, sandboxing, IoC extraction |
| network-security | Firewall design, segmentation, IDS/IPS, DPI, DNS security |

⭐ = depth-complete plugin (substantive expert content). Remaining 31 plugins are shell-improved with depth scheduled for v0.3-v0.5.

---

## Quick start

```bash
git clone https://github.com/HermeticOrmus/LibreSecOps-Claude-Code.git ~/projects/LibreSecOps-Claude-Code
cd ~/projects/LibreSecOps-Claude-Code
./setup.sh
```

Then in any Claude Code session:

```
/threat-model build a STRIDE threat model for a SaaS application with multi-tenant data, OAuth2 social login, file upload, and a public REST API
```

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

---

## Disclaimer

This kit is for **defensive security and authorized testing only**. The offensive plugins (penetration-testing, red-team-operations, bug-bounty-methodology) are intended for use with explicit authorization. Unauthorized testing is illegal in most jurisdictions.

This is documentation + prompt-engineering. It is **not**:
- Legal advice on compliance
- A replacement for certified security professionals
- An audit certification

For regulated systems, retain licensed security counsel and accredited auditors.

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

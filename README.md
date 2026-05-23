<p align="center">
  <img src="https://ormus.solutions/mascot/chain_braces_to_swan.gif" alt="LibreSecOps Claude Code" width="128" style="image-rendering: pixelated;" />
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

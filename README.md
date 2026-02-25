<p align="center">
  <img src="https://ormus.solutions/mascot/libresecops_shield.png" alt="LibreSecOps Claude Code" width="128" style="image-rendering: pixelated;" />
</p>

<h1 align="center">LibreSecOps Claude Code</h1>

<p align="center">
  <em>Security operations system for Claude Code -- agents, plugins, commands, and skills for offensive, defensive, and infrastructure security</em>
</p>

<p align="center">
  <a href="https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/stargazers"><img src="https://img.shields.io/github/stars/HermeticOrmus/LibreSecOps-Claude-Code?style=flat-square&color=c23b22" alt="Stars" /></a>
  <a href="https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/main/LICENSE"><img src="https://img.shields.io/github/license/HermeticOrmus/LibreSecOps-Claude-Code?style=flat-square&color=c23b22" alt="License" /></a>
  <a href="https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/commits"><img src="https://img.shields.io/github/last-commit/HermeticOrmus/LibreSecOps-Claude-Code?style=flat-square&color=c23b22" alt="Last Commit" /></a>
  <img src="https://img.shields.io/badge/Security-c23b22?style=flat-square&logo=shieldsdotio&logoColor=white" alt="Security" />
  <img src="https://img.shields.io/badge/Claude Code-c23b22?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code" />
</p>

---

> **Skills, Agents, Commands, and Workflows for Security Operations with Claude Code**

Stop getting generic, textbook security advice that misses real-world context. This repository provides structured, expert-level security guidance embedded directly in your Claude Code workflow -- 32 plugins across 6 security domains.

**Sister project**: [LibreUIUX-Claude-Code](https://github.com/HermeticOrmus/LibreUIUX-Claude-Code) -- the same architecture applied to UI/UX development.

---

## The New Programming Paradigm

In December 2025, Andrej Karpathy observed that programming is being "dramatically refactored":

> *"I've never felt this much behind as a programmer. The profession is being dramatically refactored."*
>
> *"New vocabulary: agents, subagents, their prompts, contexts, memory, modes, permissions, tools, plugins, skills, hooks, MCP, LSP, slash commands, workflows, IDE integrations..."*

He described Claude Code as *"the first convincing demonstration of what an LLM Agent looks like"* -- a "little spirit/ghost that lives on your computer."

**LibreSecOps provides the skills, agents, commands, and workflows for this new paradigm -- focused on security operations.**

Security is unique in the AI-assisted development landscape. Unlike UI or backend code where a suboptimal output is merely ugly or slow, a security failure can be catastrophic. The bar for precision is higher. The cost of generic advice is steeper. That is why security needs its own dedicated infrastructure in the new programming stack.

### Where LibreSecOps Fits

| New Stack Component | LibreSecOps Provides |
|---------------------|---------------------|
| **Skills** | Specialized security knowledge (OWASP, MITRE ATT&CK, CIS Benchmarks, etc.) |
| **Agents** | Task-specific security personas (pentester, incident responder, forensic analyst, etc.) |
| **Commands** | Slash commands for common security workflows |
| **Plugins** | 32 domain plugins across 6 security categories |
| **Workflows** | Beginner to advanced security learning paths |

This is not a prompt library. It is infrastructure for building secure software with AI assistance.

---

## The Problem

Claude Code has two distinct failure modes with security:

### Failure Mode 1: Overly Cautious Refusals

Claude refuses legitimate defensive security queries -- asking about common vulnerability patterns, requesting penetration testing guidance for systems you own, or analyzing malware samples for incident response. Developers doing authorized security work hit walls that slow them down without making anyone safer.

### Failure Mode 2: Naive Code Generation

In the same session, Claude will generate code containing textbook vulnerabilities:

- SQL queries built with string concatenation
- JWT tokens stored in localStorage
- API endpoints with no rate limiting or input validation
- Docker containers running as root
- Secrets hardcoded in source files
- CORS configured as `Access-Control-Allow-Origin: *`
- Password hashing with MD5 or SHA-256 instead of bcrypt/argon2

This is the paradox: **overcautious about discussing security, undercautious about implementing it.**

### What Generic Security Advice Looks Like

Ask Claude Code to "make this secure" and you get:

- "Add input validation" (without specifying what, where, or how)
- "Use HTTPS" (without TLS configuration, certificate management, or HSTS)
- "Implement authentication" (without session management, token rotation, or MFA)
- "Follow the principle of least privilege" (without concrete IAM policies or role definitions)

These are chapter headings, not implementations. Developers need the specific, structured guidance that turns principles into working security controls.

### What LibreSecOps Provides Instead

Ask LibreSecOps agents to review your authentication flow and you get:

- Specific vulnerabilities identified with CWE references
- Concrete remediation code, not abstract advice
- Threat model context: who attacks this, how, and what they gain
- Implementation patterns that handle edge cases (token refresh races, session fixation, credential stuffing)
- Testing commands to verify the fix actually works

---

## What's Included

```
LibreSecOps-Claude-Code/
+-- 32 Plugins         # Domain-specific security collections
+-- Agents             # Task-specialized security personas
+-- Commands           # Slash commands for Claude Code
+-- Skills             # Reusable security capability modules
+-- 3 Skill Levels     # Beginner -> Intermediate -> Advanced
+-- Templates          # Ready-to-use security configurations
```

### Plugin Categories

| Category | Plugins | Focus |
|----------|---------|-------|
| **Offensive Security** | 7 plugins | Penetration testing, red teaming, bug bounty, social engineering defense |
| **Defensive Security** | 6 plugins | Blue team, incident response, forensics, SIEM, malware analysis |
| **Infrastructure Security** | 6 plugins | Cloud (AWS/GCP/Azure), containers, Kubernetes, networking, zero trust |
| **Application Security** | 6 plugins | Secure coding, SAST/DAST, DevSecOps, supply chain, secrets, cryptography |
| **Governance & Compliance** | 7 plugins | Compliance frameworks, threat modeling, hardening, IAM, privacy |

### Skills vs Commands vs Agents

| Component | When to Use | Example |
|-----------|-------------|---------|
| **Skills** | Need security knowledge applied to a task | `owasp-top-10` -- teaches injection prevention with concrete patterns |
| **Commands** | Quick, repeatable security actions | `/security-audit` -- structured code review against known vulnerability classes |
| **Agents** | Complex, multi-step security work | `incident-responder` -- guides triage, containment, eradication, recovery |

---

## Quick Start

### Installation Paths

**Path 1: Just Want Better Security Prompts?** (5 minutes)
```bash
# Browse the beginner security prompts
cat beginner/prompts/secure-authentication.md
```

**Path 2: Add Security Commands to Claude Code** (10 minutes)
```bash
# Copy security commands to your project or global config
cp -r .claude/commands/* ~/.claude/commands/
```

**Path 3: Use Specific Security Plugins** (15 minutes)
```bash
# Example: Add secure coding practices to your project
cp plugins/secure-coding-practices/agents/* your-project/.claude/agents/
cp plugins/secure-coding-practices/skills/*/SKILL.md your-project/.claude/skills/
```

**Path 4: Full Installation** (30 minutes)
```bash
# Clone and integrate everything
git clone https://github.com/HermeticOrmus/LibreSecOps-Claude-Code.git
# Follow the advanced setup guide
```

---

## Learning Paths

### Beginner: Security Foundations

**Goal**: Stop producing vulnerable code. Understand the most common mistakes and how to avoid them.

1. **OWASP Top 10 awareness** -- know the vulnerability classes that account for the majority of real breaches
2. **Secure defaults** -- input validation, output encoding, parameterized queries
3. **Authentication basics** -- password hashing, session management, token handling
4. **Dependency hygiene** -- auditing packages, understanding supply chain risk
5. **Secrets management** -- why `.env` files and git history are not secrets managers

Start here: `beginner/README.md`

### Intermediate: Security Engineering

**Goal**: Build security into development workflows. Shift from reactive patching to proactive design.

1. **Threat modeling** -- STRIDE, attack trees, data flow analysis
2. **DevSecOps pipelines** -- SAST/DAST integration, dependency scanning in CI
3. **Cloud security posture** -- IAM policies, network segmentation, encryption at rest and in transit
4. **Container hardening** -- minimal base images, non-root execution, runtime security
5. **Incident response planning** -- runbooks, communication templates, forensic preservation

Continue here: `intermediate/README.md`

### Advanced: Security Operations

**Goal**: Operate at a professional security practitioner level. Red team, blue team, and everything between.

1. **Penetration testing methodology** -- reconnaissance, exploitation, post-exploitation, reporting
2. **Malware analysis** -- static analysis, dynamic sandboxing, indicator extraction
3. **Zero trust architecture** -- microsegmentation, continuous verification, identity-centric controls
4. **Compliance automation** -- SOC 2, ISO 27001, PCI DSS, HIPAA mapping
5. **Advanced cryptography** -- key management, certificate lifecycles, protocol analysis

Master level: `advanced/README.md`

---

## Repository Structure

```
LibreSecOps-Claude-Code/
+-- README.md                              # You are here
|
+-- plugins/                               # 32 domain-specific security plugins
|   +-- penetration-testing/               # Pentest methodology & tools
|   |   +-- agents/                        # Specialized security agents
|   |   +-- commands/                      # Slash commands
|   |   +-- skills/                        # Reusable skill modules
|   +-- incident-response/                 # IR playbooks & workflows
|   +-- cloud-security-aws/                # AWS-specific security
|   +-- secure-coding-practices/           # Defensive coding patterns
|   +-- threat-modeling/                   # STRIDE, attack trees, DFDs
|   +-- ... (27 more plugins)              # See full list below
|
+-- beginner/                              # Start here if new to security
|   +-- README.md                          # Beginner guide overview
|   +-- security-vocabulary.md             # Core security terminology
|   +-- prompts/                           # Ready-to-use security prompts
|   +-- checklist.md                       # Pre-deployment security checklist
|
+-- intermediate/                          # Build security into workflows
|   +-- README.md                          # Intermediate guide overview
|   +-- threat-models/                     # Threat modeling templates
|   +-- devsecops/                         # CI/CD security integration
|   +-- hardening-guides/                  # OS, container, cloud hardening
|   +-- workflows/                         # Step-by-step security workflows
|   +-- examples/                          # Real-world case studies
|
+-- advanced/                              # Professional security operations
|   +-- README.md                          # Advanced guide overview
|   +-- red-team/                          # Offensive security playbooks
|   +-- blue-team/                         # Defensive security playbooks
|   +-- forensics/                         # Digital forensics procedures
|   +-- compliance/                        # Compliance automation
|   +-- examples/                          # Production-level examples
|
+-- resources/                             # Curated security resources
|   +-- tools.md                           # Security tool recommendations
|   +-- frameworks.md                      # MITRE, NIST, CIS references
|   +-- training.md                        # Labs, CTFs, courses
|   +-- github-repos.md                    # Curated security repositories
|
+-- templates/                             # Copy-paste templates
|   +-- CLAUDE.md                          # Security-focused project config
|   +-- threat-model.md                    # Threat model template
|   +-- incident-report.md                 # Incident report template
|   +-- security-review.md                 # Code security review template
|
+-- .claude/                               # Claude Code configuration
    +-- commands/                           # Global security slash commands
        +-- security-audit.md
        +-- threat-model.md
        +-- vulnerability-check.md
```

### All 32 Plugins

<details>
<summary>Click to expand full plugin list</summary>

**Offensive Security**

| Plugin | Focus Area |
|--------|------------|
| penetration-testing | Methodology, tools, reporting for authorized testing |
| web-application-security | OWASP Top 10, XSS, SQLi, CSRF, SSRF, deserialization |
| api-security-testing | REST/GraphQL security, authentication bypass, BOLA/BFLA |
| mobile-app-security | Android/iOS security, certificate pinning, local storage |
| red-team-operations | Adversary simulation, C2 frameworks, evasion techniques |
| bug-bounty-methodology | Scope analysis, reconnaissance, responsible disclosure |
| social-engineering-defense | Phishing analysis, pretexting detection, awareness training |

**Defensive Security**

| Plugin | Focus Area |
|--------|------------|
| blue-team-detection | Detection engineering, YARA rules, Sigma rules, alert tuning |
| incident-response | IR playbooks, triage, containment, eradication, recovery |
| forensics-analysis | Disk forensics, memory analysis, timeline reconstruction |
| malware-analysis | Static/dynamic analysis, sandboxing, IOC extraction |
| security-automation | SOAR playbooks, automated response, enrichment workflows |
| siem-log-management | Log collection, parsing, correlation, retention policies |

**Infrastructure Security**

| Plugin | Focus Area |
|--------|------------|
| cloud-security-aws | IAM, VPC, S3, KMS, GuardDuty, Security Hub, Config |
| cloud-security-gcp | IAM, VPC SC, Cloud Armor, SCC, Binary Authorization |
| cloud-security-azure | Entra ID, NSG, Key Vault, Defender, Sentinel |
| container-security | Image scanning, runtime security, Dockerfile hardening |
| kubernetes-security | RBAC, network policies, pod security, admission controllers |
| network-security | Firewall rules, IDS/IPS, traffic analysis, segmentation |
| zero-trust-architecture | Microsegmentation, identity-aware proxy, continuous authz |

**Application Security**

| Plugin | Focus Area |
|--------|------------|
| secure-coding-practices | Input validation, output encoding, error handling, logging |
| vulnerability-scanning | SAST, DAST, SCA, configuration scanning |
| devsecops-pipelines | Security gates in CI/CD, pre-commit hooks, policy-as-code |
| supply-chain-security | SBOM, dependency verification, build provenance, Sigstore |
| secrets-management | Vault, AWS Secrets Manager, rotation, detection, remediation |
| cryptography-essentials | TLS configuration, key management, hashing, encryption |

**Governance & Compliance**

| Plugin | Focus Area |
|--------|------------|
| compliance-frameworks | SOC 2, ISO 27001, PCI DSS, HIPAA, GDPR, FedRAMP |
| threat-modeling | STRIDE, PASTA, attack trees, data flow diagrams |
| security-hardening | CIS Benchmarks, OS hardening, service minimization |
| identity-access-management | SSO, MFA, RBAC, ABAC, federation, lifecycle management |
| security-awareness | Developer training, phishing simulation, security culture |
| privacy-engineering | Data minimization, consent management, DPIA, anonymization |

</details>

---

## Key Principles

Security prompting requires a different discipline than general development prompting. Vague security requests produce dangerous outputs -- not just ugly ones.

### DO: Be Threat-Specific

```
-- Instead of:
"Make this endpoint secure"

-- Say:
"This endpoint accepts user-uploaded files. Validate file type by magic bytes
(not extension), enforce a 10MB size limit, scan with ClamAV before storage,
store outside the webroot with randomized filenames, and serve through a
separate domain with Content-Disposition: attachment."
```

**Why it works**: Security is contextual. The same endpoint has different threat profiles depending on who accesses it, what data flows through it, and what the attacker gains from compromise. Specificity forces you to think about the actual threat, not the abstract concept.

### DO: Reference Standards, Not Vibes

```
-- Instead of:
"Use strong encryption"

-- Say:
"Encrypt at rest using AES-256-GCM with keys managed in AWS KMS.
Encrypt in transit using TLS 1.3. Derive user passwords with
argon2id (memory=65536, iterations=3, parallelism=4)."
```

**Why it works**: "Strong encryption" means different things in different contexts. Algorithm, mode, key size, key management, and rotation policy are all separate decisions. Named standards eliminate ambiguity.

### DO: Specify the Attacker Model

```
-- Instead of:
"Add authentication"

-- Say:
"Implement authentication assuming: (1) attackers have credential dumps from
other breaches, (2) attackers can intercept network traffic on public WiFi,
(3) attackers will attempt automated credential stuffing at scale. Therefore:
bcrypt with cost 12, mandatory MFA via TOTP, rate limiting at 5 attempts per
IP per minute, account lockout after 10 failures with email notification."
```

**Why it works**: Security controls exist to counter specific threats. When you name the attacker and their capabilities, the controls follow logically. Without a threat model, you are guessing.

### DO: Demand Verifiable Output

```
-- Instead of:
"Check if this is secure"

-- Say:
"Review this authentication middleware for: (1) timing-safe comparison of
tokens, (2) proper session invalidation on password change, (3) CSRF
protection on state-changing endpoints, (4) secure cookie attributes
(HttpOnly, Secure, SameSite=Strict). For each item, cite the specific
line and explain the risk if missing."
```

**Why it works**: A security review without specific findings is not a review. Demanding citations forces the agent to actually analyze the code rather than recite general advice.

### DON'T: Accept Security Theater

- ~~"Add security headers"~~ without specifying which headers, what values, and why
- ~~"Implement RBAC"~~ without defining roles, permissions, and inheritance rules
- ~~"Use a WAF"~~ without configuring rules for your application's specific attack surface
- ~~"Enable logging"~~ without defining what to log, what NOT to log (PII), and retention
- ~~"Follow best practices"~~ -- there is no universal best practice, only appropriate controls for specific threats

### DON'T: Confuse Compliance with Security

Compliance frameworks provide a baseline. They are necessary but not sufficient. Passing a SOC 2 audit does not mean your application is secure -- it means you have documented controls that an auditor reviewed. Real security requires continuous testing, monitoring, and adversarial thinking beyond any checklist.

---

## Responsible Use

This repository contains offensive security knowledge -- penetration testing techniques, vulnerability exploitation patterns, and adversary simulation methods. This content exists for one purpose: **to help defenders build better defenses.**

**This project is for:**
- Developers securing their own applications
- Security professionals conducting authorized assessments
- Students learning security in lab environments
- Teams building security into their development lifecycle

**This project is not for:**
- Unauthorized access to systems you do not own or have permission to test
- Circumventing security controls without authorization
- Any activity that violates applicable laws or regulations

If you are unsure whether your use case is appropriate, it probably is -- most security learning is legitimate. But always ensure you have explicit authorization before testing systems you do not own.

---

## Contributing

Security knowledge has a short shelf life. Vulnerabilities are discovered daily. Frameworks evolve. Attack techniques advance. This repository stays relevant through community contribution.

### What We Need

**Vulnerability Patterns**
- Found a common misconfiguration Claude produces? Document it with the fix.
- Discovered a security antipattern in generated code? Show the before and after.
- Identified a class of vulnerabilities Claude misses during review? Write a detection rule.

**Tool Integration**
- Built a security command that works well with Claude Code? Share it.
- Created an agent for a specific security workflow? PR it.
- Integrated a security scanner into a Claude Code workflow? Document the setup.

**Real-World Scenarios**
- Conducted a security review using LibreSecOps? Share the methodology (sanitized).
- Built a DevSecOps pipeline with these plugins? Document the architecture.
- Used threat modeling agents for a real project? Show the output.

**Framework Updates**
- OWASP Top 10 changed? Update the relevant plugins.
- New MITRE ATT&CK techniques published? Add coverage.
- Cloud provider launched new security services? Extend the cloud plugins.

### Contribution Guidelines

1. **Accuracy is non-negotiable** -- security misinformation is actively dangerous. Every claim must be verifiable. Every code sample must be tested. Every tool reference must be current.

2. **Provide context** -- security advice without context is meaningless. Always specify: what threat does this address, what systems does it apply to, and what are the tradeoffs.

3. **Include verification steps** -- every security control should come with a way to test that it works. "Trust but verify" is not good enough; "verify, then trust" is the standard.

4. **Respect responsible disclosure** -- never include zero-day vulnerabilities, active exploit code targeting unpatched systems, or information that could enable harm to specific organizations.

5. **Test with Claude Code** -- prompts should work as written, agents should produce actionable output, commands should execute successfully.

### Review Process

PRs are reviewed for:
- Technical accuracy (verified against current CVEs, standards, and tool documentation)
- Responsible framing (offensive content serves defensive purpose)
- Actionable value (readers can apply it to their systems immediately)
- Completeness (includes threat context, implementation, and verification)

---

## Resources

### Frameworks and Standards
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) -- Web application security risks
- [MITRE ATT&CK](https://attack.mitre.org/) -- Adversary tactics and techniques
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks) -- Configuration security
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework) -- Risk management
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) -- Security and privacy controls

### Hands-On Practice
- [HackTheBox](https://www.hackthebox.com/) -- Penetration testing labs
- [TryHackMe](https://tryhackme.com/) -- Guided security learning paths
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) -- Free web security training
- [CryptoHack](https://cryptohack.org/) -- Cryptography challenges
- [OWASP WebGoat](https://owasp.org/www-project-webgoat/) -- Deliberately insecure application for practice

### Official Documentation
- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code)
- [Anthropic Prompt Engineering](https://docs.anthropic.com/en/docs/prompt-engineering)

---

## Attribution & Inspiration

The framing of this repository was inspired by [Andrej Karpathy's](https://karpathy.ai/) observations about the transformation of programming in the AI era:

**Key Sources:**
- [LLMs as a New Computing Platform (2025 Year in Review)](https://karpathy.ai/blog/2025-llm-os.html) -- Karpathy's comprehensive analysis of how LLMs are becoming a new computing paradigm
- [X/Twitter Thread on the New Vocabulary](https://x.com/karpathy/status/1872411236358504787) -- The December 2025 post describing "agents, subagents, prompts, contexts, memory, modes, permissions, tools, plugins, skills, hooks, MCP, LSP, slash commands, workflows"

**On Claude Code specifically:**
> *"Claude Code is the first convincing demonstration of what an LLM Agent looks like... a little spirit/ghost that lives on your computer, can inspect files, use a browser, can be told to 'just fix all the build errors', or 'write tests for this file'."*

This repository applies that paradigm to the domain where precision matters most: security. The skills, agents, commands, and workflows here are built to produce outputs that a security professional would trust -- not just outputs that sound secure to a non-specialist.

---

## License

MIT License

Copyright (c) 2025-2026 Hermetic Ormus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## Star This Repo

If LibreSecOps helps you write more secure code with Claude Code, star the repository. It helps other developers discover these resources.

---

**Built by developers who believe security is a right, not a feature. Building the new programming paradigm, one secure component at a time.**

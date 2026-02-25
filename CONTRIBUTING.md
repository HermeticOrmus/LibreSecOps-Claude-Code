# Contributing to LibreSecOps

Welcome to the security knowledge commons. This repository maps how to use Claude Code for security operations -- offense, defense, compliance, and everything between. Every contribution raises our shared understanding of AI-assisted security.

---

## Philosophy

**We share knowledge, not secrets.**

Security thrives on transparency, not obscurity. When you contribute here, you are documenting defensive patterns, revealing how attacks work so defenders can prepare, and building collective security literacy.

**We educate, never weaponize.**

Every contribution must serve the defender. Attack patterns exist here to teach recognition and response, not to enable exploitation. If your contribution could cause harm without the educational context, it is incomplete.

---

## Guiding Principles

1. **Responsible disclosure above all** -- Never include zero-day vulnerabilities, active exploits targeting unpatched systems, or credentials of any kind.
2. **Educational context required** -- Every attack pattern must include detection methods, mitigation strategies, and defensive takeaways.
3. **No targeting real systems** -- All examples must use intentionally vulnerable environments (DVWA, HackTheBox, TryHackMe, local labs) or synthetic data.
4. **Mechanism over mystification** -- Explain WHY a technique works, not just that it does. Security through obscurity helps no one.
5. **Defend the defender** -- The ultimate consumer of this content is someone protecting systems and users.

---

## Types of Contributions

### Security Prompts & Patterns

Prompts that consistently produce quality security analysis with Claude Code.

**How to contribute:**
1. Test in real (lab) environments first
2. Document the exact prompt and expected output
3. Explain the security mechanism at work
4. Show what the naive approach misses

**Template:**
```markdown
## [Technique Name] Prompt

### The Threat
[What attack or vulnerability does this address?]

### The Pattern
[Exact prompt that works with Claude Code]

### Why This Works
[Technical explanation of the security mechanism]

### Detection & Defense
[How to detect this attack / How this defense operates]

### Try This
[Lab exercise readers can run safely]

### Common Variations
- [Variant with different context]
```

### Attack Patterns (Educational)

Documentation of attack techniques for defensive understanding.

**Requirements:**
- Must include detection signatures or indicators of compromise
- Must include mitigation or remediation steps
- Must reference MITRE ATT&CK framework where applicable
- Must specify the lab environment for safe testing
- Must never include working exploits for unpatched vulnerabilities

### Defense Playbooks

Step-by-step defensive procedures.

**Structure:**
- Threat description and risk context
- Detection criteria (logs, alerts, behavioral indicators)
- Response steps with exact commands
- Recovery and hardening procedures
- Post-incident review checklist

### Real-World Examples

Case studies drawn from public disclosures, CTF writeups, or published research.

**Requirements:**
- Source attribution (CVE numbers, advisory links, conference talks)
- Lessons learned for defenders
- How Claude Code could assist in detection or response
- No reproduction of active, unpatched vulnerabilities

### Plugins, Agents & Commands

New Claude Code extensions for security workflows.

**Requirements:**
- Clear scope definition (what it does and does not do)
- Input validation on all user-provided data
- No network calls to external services without explicit user consent
- Error handling that does not leak sensitive information
- Usage examples with expected output

### Documentation & Guides

Workflow guides, learning paths, tool comparisons, and reference material.

**Structure:**
- Clear problem statement and audience
- Progressive difficulty (build understanding step by step)
- Practical exercises with safe lab environments
- Key takeaways and next steps

---

## Contribution Process

### 1. Check Existing Work

Search issues and existing content before starting. Duplicates waste everyone's time.

### 2. Open an Issue (for significant changes)

For new plugins, agents, or substantial content additions, open an issue first to discuss scope and approach. Small fixes and documentation improvements can go directly to PR.

### 3. Fork & Branch

```bash
git clone https://github.com/YOUR-USERNAME/LibreSecOps-Claude-Code.git
cd LibreSecOps-Claude-Code
git checkout -b feature/your-contribution-name
```

**Branch naming:**
- `feature/` -- New content, plugins, or capabilities
- `fix/` -- Bug fixes or corrections
- `docs/` -- Documentation improvements
- `example/` -- New examples or lab exercises

### 4. Write & Test

Follow the guidelines above. Test everything in a safe environment.

### 5. Commit

```
feat(plugin): Add container escape detection patterns

Includes:
- Docker socket exposure checks
- Privileged container identification
- Namespace breakout detection signatures
- Lab exercise using intentionally vulnerable container
```

Use conventional commits: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

### 6. Submit PR

Open a pull request using the PR template. Include:
- Clear description of what this adds
- Security review confirmation
- Testing environment and methodology
- References to relevant standards (MITRE ATT&CK, OWASP, CIS Benchmarks)

### 7. Review

Maintainers review for:
- **Security accuracy** -- Is the technical content correct?
- **Responsible disclosure** -- Does it follow our principles?
- **Educational value** -- Does it teach, not just tell?
- **Completeness** -- Attack patterns have defenses, defenses have context?
- **Quality** -- Clear writing, working examples, proper structure?

Feedback is collaborative. We are mapping this territory together.

---

## Content Guidelines by Difficulty

### Beginner

- Assume no prior security experience
- Provide ready-to-use prompts and commands
- Use well-known, documented vulnerabilities (OWASP Top 10)
- Include setup instructions for lab environments
- Emphasize "why this matters" for each concept

### Intermediate

- Assume familiarity with common tools (nmap, Burp Suite, Wireshark)
- Introduce systematic methodologies
- Cover less obvious attack surfaces
- Include automation and scripting patterns
- Connect individual techniques to broader frameworks

### Advanced

- Assume professional security experience
- Cover complex attack chains and advanced persistent threats
- Include production-grade detection engineering
- Address compliance and governance integration
- Provide automation for enterprise-scale operations

---

## Security Review Checklist

Before submitting, verify:

- [ ] No active exploits for unpatched vulnerabilities
- [ ] No real credentials, tokens, API keys, or secrets
- [ ] No references to specific organizations as targets
- [ ] All attack content includes defensive countermeasures
- [ ] Lab environment specified for any hands-on exercises
- [ ] MITRE ATT&CK or OWASP references included where applicable
- [ ] Content serves defenders, not attackers
- [ ] Responsible disclosure principles followed throughout

---

## What We Do Not Accept

- **Active exploitation tools** -- No weaponized code, no working exploits for current vulnerabilities
- **Untested content** -- Everything must be verified in a safe environment
- **Targeting guidance** -- No content that helps select or attack real targets
- **Credential harvesting** -- No phishing kits, credential stealers, or social engineering tools
- **Incomplete attack documentation** -- Attack patterns without defensive context are rejected
- **Gatekeeping** -- No "experts only" framing. Explain everything.

---

## Recognition

Contributors are:
- Listed in commit history and release notes
- Part of the security knowledge commons
- Building collective defensive capability

Your contribution might be one detection rule, one playbook, one prompt pattern. But someone, somewhere, will catch an intrusion because you documented what you learned.

That is not hypothetical. That is how security communities work.

---

**Share what you discover. The defense grows when knowledge flows.**

Thank you for contributing to collective security.

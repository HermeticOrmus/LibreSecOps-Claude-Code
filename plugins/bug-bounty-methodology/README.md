# Bug Bounty Methodology Plugin

> Structured bug bounty hunting methodology, reconnaissance techniques, and professional vulnerability report writing for authorized bug bounty programs.

## Overview

The Bug Bounty Methodology plugin provides a systematic approach to finding and reporting vulnerabilities in authorized bug bounty programs. It covers the full cycle from program selection and scope review through reconnaissance, testing, and professional vulnerability disclosure.

This plugin is strictly for use within authorized bug bounty programs where the target organization has explicitly invited security testing. Every technique and methodology emphasizes scope adherence, responsible disclosure, and professional conduct. Bug bounty programs have rules; following them is not optional.

The methodology draws from practical bug bounty experience and established frameworks including the OWASP Testing Guide, the Bug Bounty Hunter Methodology (BBHM), and reporting standards from platforms like HackerOne, Bugcrowd, and Intigriti.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Bug Bounty Hunter | `agents/bug-bounty-hunter.md` | Structured reconnaissance and testing methodology for authorized bug bounty targets. Scope-aware, systematic, and focused on high-impact findings. |
| Vuln Report Writer | `agents/vuln-report-writer.md` | Professional vulnerability report writing that maximizes clarity, reproducibility, and impact communication for bug bounty submissions. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/recon-plan` | `commands/recon-plan.md` | Generate a structured reconnaissance plan for an authorized bug bounty target, including passive and active recon phases. |
| `/vuln-report` | `commands/vuln-report.md` | Write a professional vulnerability report suitable for bug bounty platform submission, with clear reproduction steps and impact analysis. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Recon Methodology | `skills/recon-methodology/SKILL.md` | Comprehensive reconnaissance methodology covering subdomain enumeration, technology fingerprinting, content discovery, and attack surface mapping. |
| Vuln Report Writing | `skills/vuln-report-writing/SKILL.md` | Guide to writing vulnerability reports that get accepted and fairly rewarded, with templates and common pitfalls. |

## Usage

### Starting a Program

Before any testing, review the program scope, rules, and exclusions. Use the `bug-bounty-hunter` agent to discuss the program and plan a systematic approach.

### Reconnaissance

Run `/recon-plan` with the target scope to generate a structured recon plan. The plan covers passive reconnaissance (no direct target interaction), active reconnaissance (within-scope interaction), and attack surface mapping.

### Testing

The `bug-bounty-hunter` agent provides methodology guidance during testing. It helps prioritize test areas based on recon findings and guides systematic testing of high-value targets.

### Reporting

Use `/vuln-report` to write a professional vulnerability report. Provide the vulnerability details and the command produces a well-structured report with clear reproduction steps, impact analysis, and CVSS scoring ready for platform submission.

## Key Concepts

- **Scope is law**: If it is not in scope, do not test it. Period. Out-of-scope testing can result in legal consequences and permanent bans from bug bounty platforms.
- **Responsible disclosure**: Report vulnerabilities to the program, not to the public. Follow the program's disclosure timeline. Do not access, modify, or exfiltrate real user data.
- **Quality over quantity**: One well-written critical finding is worth more than ten poorly documented low-severity reports. Invest time in clear, reproducible reports.
- **Reconnaissance depth**: The majority of unique findings come from thorough reconnaissance, not from running automated scanners against the main domain. Deep recon reveals forgotten assets, staging environments, and exposed services.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `web-application-security` | Web app testing knowledge is essential for bug bounty. |
| `api-security-testing` | API vulnerabilities are a major category of bug bounty findings. |
| `penetration-testing` | Bug bounty methodology overlaps with pentest methodology but with different rules of engagement. |
| `mobile-app-security` | Mobile bug bounty targets require mobile security testing expertise. |
| `cloud-security-aws/azure/gcp` | Cloud misconfigurations are increasingly common bug bounty findings. |

## Methodology

Bug bounty hunting follows this cycle:

1. **Program selection** -- Choose programs matching your skills, read rules thoroughly
2. **Passive recon** -- Gather information without touching the target (OSINT, CT logs, DNS, archives)
3. **Active recon** -- Within-scope enumeration (subdomain brute-forcing, port scanning, content discovery)
4. **Attack surface mapping** -- Identify technologies, entry points, authentication mechanisms, APIs
5. **Vulnerability testing** -- Systematic testing of identified attack surface
6. **Validation** -- Confirm the finding is real, in-scope, and impactful
7. **Reporting** -- Write a clear, reproducible, impact-focused vulnerability report
8. **Follow-up** -- Respond to triage questions, provide additional information, verify fixes

## Ethics

- Never test without authorization. A bug bounty program scope is your authorization boundary.
- Never access, download, modify, or delete real user data. Use your own test accounts.
- Never pivot from an in-scope vulnerability to out-of-scope systems.
- Never use social engineering against the target organization's employees.
- Never perform denial-of-service testing unless explicitly permitted.
- Report findings promptly. Do not stockpile vulnerabilities.
- Coordinate with the program if you discover something critically urgent.

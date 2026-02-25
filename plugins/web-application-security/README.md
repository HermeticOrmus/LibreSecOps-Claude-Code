# Web Application Security Plugin

> Comprehensive web application security auditing using OWASP methodologies, covering the full spectrum from injection flaws to broken access control.

## Overview

The Web Application Security plugin equips Claude Code with deep expertise in identifying, analyzing, and remediating vulnerabilities in web applications. It centers on the OWASP Top 10 (2021 edition) as the primary framework, but extends beyond it to cover real-world attack patterns, defense-in-depth strategies, and secure coding practices across all major web frameworks.

This plugin is designed for **authorized defensive security work only** -- code review, architecture analysis, secure development guidance, and pre-deployment security audits. Every finding includes both the vulnerability explanation and the concrete remediation path.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Web Security Auditor | `agents/web-security-auditor.md` | Full OWASP Top 10 audit specialist. Systematically reviews code and architecture against all ten categories, producing prioritized findings with severity ratings and fix guidance. |
| XSS Hunter | `agents/xss-hunter.md` | Focused cross-site scripting detection and prevention specialist. Identifies reflected, stored, DOM-based, and mutation XSS patterns across templates, JavaScript, and API responses. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/owasp-scan` | `commands/owasp-scan.md` | Audit source code against the OWASP Top 10, producing a structured report with findings categorized by risk level, affected code locations, and remediation steps. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| OWASP Top 10 | `skills/owasp-top-10/SKILL.md` | Deep reference knowledge base covering all ten OWASP categories with vulnerability patterns, code examples (vulnerable and fixed), detection techniques, and framework-specific mitigations. |

## Usage

### Quick Audit

Run `/owasp-scan` in any web application project to get a structured security assessment. The command walks through each OWASP category systematically.

### Deep Dive

Activate the `web-security-auditor` agent for interactive, thorough security review sessions. The agent will ask clarifying questions about your stack, identify the most relevant attack surface, and prioritize findings by actual exploitability rather than theoretical severity.

### XSS-Specific Work

Use the `xss-hunter` agent when dealing specifically with output encoding, template injection, or Content Security Policy configuration. This agent understands the nuances of framework-specific XSS protections (React's JSX escaping, Angular's DomSanitizer, Django's template auto-escaping) and where they fail.

## Key Concepts

- **Defense in depth**: No single control is sufficient. Input validation, output encoding, CSP, and secure headers work together.
- **Context-aware encoding**: The encoding function must match the output context (HTML body, HTML attribute, JavaScript, URL, CSS). Using the wrong encoder is equivalent to no encoding.
- **Framework trust boundaries**: Modern frameworks provide automatic protections, but developers routinely bypass them. The audit focuses on these bypass points.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `api-security-testing` | APIs are the backend of web applications. Use both for full-stack coverage. |
| `penetration-testing` | Web app security feeds into pentest scoping and execution. |
| `secure-coding-practices` | The remediation side -- how to write code that avoids these vulnerabilities from the start. |
| `threat-modeling` | Model threats before auditing. Threat models direct where to focus the audit. |
| `security-hardening` | Server and infrastructure hardening complements application-layer security. |

## Methodology

This plugin follows the OWASP Testing Guide v4.2 structure for systematic coverage. Assessments proceed in this order:

1. **Information gathering** -- Technology stack, framework versions, entry points
2. **Configuration review** -- Security headers, TLS, error handling, debug modes
3. **Authentication testing** -- Login flows, session management, credential storage
4. **Authorization testing** -- Access control, privilege escalation, IDOR
5. **Input validation** -- Injection points across all OWASP categories
6. **Business logic** -- Application-specific flaws that automated tools miss
7. **Client-side** -- XSS, CSRF, clickjacking, open redirects

All findings use a standardized severity rating aligned with CVSS v3.1 base scores and include both the vulnerable code pattern and the secure alternative.

# Security Awareness Plugin

> Security awareness training design, phishing simulation exercises, and security policy documentation for building a security-conscious organizational culture.

## Overview

The Security Awareness plugin focuses on the human element of cybersecurity -- the most targeted and often least defended component of any security program. Technical controls fail when humans are manipulated into bypassing them. This plugin provides expertise in designing security awareness programs, creating phishing simulation exercises for authorized training, and developing security policies that people actually read and follow.

The approach is educational, not punitive. Effective security awareness programs teach people to recognize threats and respond correctly, rather than shaming them for mistakes. Research consistently shows that positive reinforcement and practical, scenario-based training produce better outcomes than compliance-checkbox exercises.

This plugin covers the NIST Cybersecurity Framework Awareness and Training function (PR.AT), SANS Security Awareness Maturity Model, and industry best practices from organizations like the Anti-Phishing Working Group (APWG) and the European Union Agency for Cybersecurity (ENISA).

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Security Trainer | `agents/security-trainer.md` | Designs phishing awareness exercises, social engineering education modules, and security awareness curricula tailored to organizational roles and risk profiles. |
| Policy Writer | `agents/policy-writer.md` | Creates clear, enforceable security policy documents covering acceptable use, incident reporting, data handling, password management, and remote work security. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/phishing-sim` | `commands/phishing-sim.md` | Design a phishing awareness simulation exercise with realistic scenarios, measurement criteria, and educational follow-up materials. |
| `/security-policy` | `commands/security-policy.md` | Generate a security policy document tailored to organizational context, regulatory requirements, and workforce profile. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Social Engineering Taxonomy | `skills/social-engineering-taxonomy/SKILL.md` | Classification of social engineering attack types, psychological principles exploited, recognition patterns, and defense strategies. |
| Security Policy Templates | `skills/security-policy-templates/SKILL.md` | Reference templates and frameworks for common security policies with guidance on customization and enforcement. |

## Usage

### Phishing Simulation Design

Run `/phishing-sim` to design a phishing awareness exercise. Specify the target audience, organizational context, and training objectives. The command produces realistic scenarios with varying difficulty, measurement metrics, and educational materials for post-exercise debriefing.

### Policy Development

Use `/security-policy` to generate security policy documents. Specify the policy type (acceptable use, incident response, data handling, etc.), regulatory context (HIPAA, PCI-DSS, GDPR, SOC 2), and organizational size/type. The command produces a complete policy document ready for legal review and management approval.

### Training Program Design

Activate the `security-trainer` agent for interactive design of a security awareness program. The agent will ask about the organization's risk profile, current maturity level, and specific concerns, then design a phased training program with measurable outcomes.

### Ongoing Policy Work

Use the `policy-writer` agent for ongoing policy development, review, and updates. The agent understands policy frameworks and can draft, review, or update policies while maintaining consistency across the policy set.

## Key Concepts

- **Security culture over compliance**: Compliance programs produce checkbox behavior. Security culture produces employees who report suspicious emails because they understand the risk, not because a policy says they must.
- **Role-based training**: Executives face different threats (whaling, BEC) than developers (supply chain, credential theft) than general staff (phishing, social engineering). Training must be relevant to the audience.
- **Positive reinforcement**: Reward reporting behavior. Never punish employees for falling for simulated phishing -- use it as a teaching moment.
- **Continuous learning**: One annual training session does not build awareness. Short, frequent, scenario-based training with real-world examples is more effective.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `social-engineering-defense` | Deep technical focus on social engineering attack patterns and defenses. |
| `incident-response` | Awareness training teaches employees how to report incidents; IR handles the response. |
| `compliance-frameworks` | Policies must align with regulatory requirements covered in compliance plugin. |
| `threat-modeling` | Understanding threats informs what awareness topics to prioritize. |

## Methodology

Security awareness programs follow the SANS Security Awareness Maturity Model:

1. **Nonexistent** -- No awareness program
2. **Compliance-focused** -- Annual training to meet regulatory requirements
3. **Promoting awareness and behavior change** -- Engaging training that changes behavior
4. **Long-term sustainment and culture change** -- Continuous program integrated into organizational culture
5. **Metrics framework** -- Measuring impact on actual security incidents

This plugin targets levels 3-5, moving organizations beyond compliance toward genuine security culture.

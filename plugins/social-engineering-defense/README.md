# Social Engineering Defense Plugin

> Technical and human defenses against social engineering attacks, including attack pattern recognition, organizational risk assessment, and awareness program design.

## Overview

The Social Engineering Defense plugin focuses on understanding, detecting, and defending against the manipulation of human behavior for malicious purposes. Social engineering remains the most common initial attack vector in data breaches (per Verizon DBIR consistently reporting social engineering in the top three vectors). Technical controls alone cannot prevent these attacks because they target human psychology, not software vulnerabilities.

This plugin takes a defense-focused approach. It teaches how social engineering attacks work so that defenders can recognize them, build organizational resilience, and design layered defenses that combine technical controls (email filtering, URL analysis, MFA enforcement) with human controls (awareness training, verification procedures, reporting culture).

The content is designed for security professionals building organizational defenses: CISOs, security awareness managers, SOC analysts, and incident responders who handle social engineering incidents. It is not a guide for conducting social engineering attacks.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Social Engineering Analyst | `agents/social-engineering-analyst.md` | Analyzes social engineering attack patterns, assesses organizational risk, and designs detection mechanisms for phishing, vishing, and physical social engineering. |
| Awareness Program Designer | `agents/awareness-program-designer.md` | Designs comprehensive security awareness programs that build organizational resilience through training, simulation, culture change, and measurement. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/social-eng-assess` | `commands/social-eng-assess.md` | Assess an organization's vulnerability to social engineering attacks, identifying risk factors and recommending specific defenses. |
| `/awareness-plan` | `commands/awareness-plan.md` | Design a security awareness training program with phased implementation, role-based content, and measurable outcomes. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Social Engineering Attacks | `skills/social-engineering-attacks/SKILL.md` | Comprehensive taxonomy of social engineering attack types with psychological mechanisms, indicators, and case studies. |
| Defense Strategies | `skills/defense-strategies/SKILL.md` | Technical and human defense controls for preventing, detecting, and responding to social engineering attacks. |

## Usage

### Risk Assessment

Run `/social-eng-assess` to evaluate an organization's social engineering risk profile. Provide details about the organization (industry, size, communication patterns, current defenses) and receive a structured risk assessment with prioritized recommendations.

### Awareness Program Design

Use `/awareness-plan` to design a complete awareness training program. Specify organizational context, current maturity, and objectives, and receive a phased implementation plan with training modules, simulation calendar, and metrics.

### Attack Analysis

Activate the `social-engineering-analyst` agent when analyzing specific social engineering incidents or threats. The agent helps identify the attack technique, assess its sophistication, and recommend specific countermeasures.

### Ongoing Program Development

Use the `awareness-program-designer` agent for interactive program development, including content creation, simulation design, metrics analysis, and program evolution.

## Key Concepts

- **Defense in depth for humans**: Just as we layer technical controls (firewall + IDS + EDR), we layer human controls (awareness + procedures + verification + reporting culture).
- **Reporting over perfection**: It is more valuable that employees report suspicious contacts than that they never fall for any attack. Build a culture where reporting is rewarded, not punished.
- **Attacker economics**: Social engineering is cheap and scalable. Defense must make attacks more expensive (MFA defeats credential phishing) and less rewarding (minimal access after compromise).
- **Continuous adaptation**: Attackers evolve tactics rapidly (AI-generated phishing, deepfake vishing). Awareness programs must evolve equally rapidly.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `security-awareness` | Broader security awareness including policy writing. This plugin goes deeper on social engineering specifically. |
| `incident-response` | Social engineering incidents require specific IR procedures. |
| `blue-team-detection` | Technical detection of phishing, BEC, and social engineering attempts. |
| `threat-modeling` | Social engineering threats should be included in threat models. |
| `identity-access-management` | Strong IAM (MFA, conditional access) is the primary technical defense against credential-based social engineering. |

## Methodology

Social engineering defense follows a continuous improvement cycle:

1. **Understand** -- Know the attack types, psychological mechanisms, and current threat landscape
2. **Assess** -- Evaluate organizational risk factors, current defenses, and gaps
3. **Defend** -- Implement layered technical and human controls
4. **Train** -- Build awareness through continuous, scenario-based education
5. **Test** -- Simulate attacks to measure resilience and identify gaps
6. **Respond** -- Handle social engineering incidents with specific procedures
7. **Evolve** -- Update defenses as attack techniques change

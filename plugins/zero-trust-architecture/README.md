# Zero Trust Architecture Plugin

> Design, assess, and implement Zero Trust Architecture following NIST SP 800-207 principles -- never trust, always verify, assume breach.

## Overview

The Zero Trust Architecture (ZTA) plugin provides the framework and methodology for transitioning from traditional perimeter-based security to a zero trust model. The fundamental shift: in zero trust, no network location, user, or device is inherently trusted. Every access request is authenticated, authorized, and encrypted regardless of where it originates -- inside or outside the traditional network perimeter.

This is not a product you buy. Zero trust is an architectural philosophy implemented through the coordinated application of identity management, device posture assessment, microsegmentation, encryption, continuous monitoring, and least-privilege access policies. The journey from perimeter-based security to zero trust is gradual, iterative, and never truly complete.

This plugin draws primarily from NIST SP 800-207 (Zero Trust Architecture), the CISA Zero Trust Maturity Model, and practical implementation experience across cloud-native and hybrid environments. The focus is on actionable architecture decisions, not vendor-specific product recommendations.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Zero Trust Architect | `agents/zero-trust-architect.md` | Designs zero trust architectures aligned with NIST SP 800-207. Assesses current maturity, identifies gaps, and creates implementation roadmaps. |
| Microsegmentation Specialist | `agents/microsegmentation-specialist.md` | Designs and implements network microsegmentation strategies that enforce least-privilege communication between workloads, services, and environments. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/zero-trust-assess` | `commands/zero-trust-assess.md` | Assess the current security posture against the CISA Zero Trust Maturity Model and identify the path to higher maturity levels. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Zero Trust Principles | `skills/zero-trust-principles/SKILL.md` | NIST SP 800-207 reference knowledge, core tenets, deployment models, and the theoretical foundation of zero trust. |
| Microsegmentation Patterns | `skills/microsegmentation-patterns/SKILL.md` | Implementation approaches for network, application, and identity-based microsegmentation across on-premises and cloud environments. |

## Usage

### Maturity Assessment

Run `/zero-trust-assess` to evaluate your current security posture against the five pillars of the CISA Zero Trust Maturity Model: Identity, Devices, Networks, Applications & Workloads, and Data. The assessment identifies your current maturity level (Traditional, Initial, Advanced, Optimal) for each pillar and recommends the next steps.

### Architecture Design

Activate the `zero-trust-architect` agent for comprehensive zero trust architecture design sessions. The agent works through each zero trust pillar, evaluates existing infrastructure, and produces an implementation roadmap that accounts for organizational constraints, legacy systems, and budget.

### Network Segmentation

Use the `microsegmentation-specialist` agent when designing or implementing network segmentation strategies. This agent handles service mesh configuration, network policy design (Kubernetes NetworkPolicy, cloud security groups), and east-west traffic control.

## Key Concepts

- **Never trust, always verify**: Every access request must be authenticated and authorized, regardless of network location.
- **Assume breach**: Design as if the attacker is already inside. Limit blast radius through segmentation and least privilege.
- **Least privilege access**: Grant the minimum permissions needed for the task, and only for the duration needed.
- **Continuous verification**: Authentication is not a one-time event. Continuously evaluate trust based on user behavior, device posture, and risk signals.
- **Protect the resource, not the perimeter**: Security controls move from the network edge to the individual resource (API, database, service).

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `identity-access-management` | IAM is the foundation of zero trust. Strong identity is the prerequisite for everything else. |
| `network-security` | Traditional network security provides the building blocks that zero trust restructures. |
| `cloud-security-aws` / `cloud-security-gcp` / `cloud-security-azure` | Cloud environments are where most zero trust implementations begin, using native IAM and networking controls. |
| `kubernetes-security` | Kubernetes provides built-in microsegmentation primitives (NetworkPolicy) and service mesh integration. |
| `security-hardening` | Device and endpoint hardening supports the "devices" pillar of zero trust. |
| `compliance-frameworks` | Zero trust maturity maps directly to compliance controls (NIST 800-53, FedRAMP, CMMC). |

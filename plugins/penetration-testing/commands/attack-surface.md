# /attack-surface

> Map the attack surface of a system or application, identifying all entry points, trust boundaries, data flows, and high-value targets.

## Trigger

Use this command when:
- Starting a penetration test or security assessment (first step after scoping)
- Evaluating the security posture of a new or inherited system
- Preparing for a threat modeling session (attack surface feeds into threat models)
- Assessing the impact of architectural changes on security exposure

## Input

Required:
- **Target**: Project directory, architecture description, or system documentation

Optional:
- **Focus**: `external` (internet-facing only), `internal` (authenticated/internal), `full` (both)
- **Depth**: `quick` (entry points only), `detailed` (entry points + data flows + trust boundaries)

## Process

### Step 1: Entry Point Enumeration

Identify every point where data enters the system:

**Network Layer**:
- Open ports and services (from configuration files, Dockerfiles, deployment manifests)
- Load balancer and reverse proxy configurations
- DNS records and subdomains (from infrastructure-as-code)

**Application Layer**:
- HTTP routes and API endpoints (from code)
- GraphQL queries and mutations
- WebSocket message handlers
- File upload endpoints
- Webhook receivers
- Email processing endpoints (if applicable)
- Message queue consumers
- Scheduled job inputs (cron jobs that fetch external data)

**Authentication Entry Points**:
- Login forms and endpoints
- Registration flows
- Password reset mechanisms
- OAuth callback URLs
- SSO/SAML endpoints
- API key submission points
- MFA verification endpoints

### Step 2: Trust Boundary Mapping

Identify where trust levels change:

- **External to DMZ**: Internet-facing services, WAF/CDN boundaries
- **DMZ to internal**: API gateways, reverse proxies, load balancers
- **Service to service**: Inter-service communication, service mesh boundaries
- **Application to data**: Database connections, cache access, file system access
- **User roles**: Anonymous to authenticated, user to admin, tenant to tenant
- **Environment boundaries**: Development to staging, staging to production

### Step 3: Data Flow Analysis

For each entry point, trace where data flows:

1. **Input** -- Where does user/external data enter?
2. **Processing** -- What transformations, validations, and business logic are applied?
3. **Storage** -- Where is data persisted (database, cache, file system, external service)?
4. **Output** -- Where is data rendered or transmitted (HTTP response, email, webhook, log)?

Flag data flows that cross trust boundaries without validation or encoding.

### Step 4: High-Value Target Identification

Identify assets that attackers would target:

- **Authentication stores**: User databases, credential stores, session stores
- **Secrets**: API keys, encryption keys, certificates, tokens in configuration
- **Sensitive data**: PII, financial data, health records, intellectual property
- **Administrative functions**: Admin panels, configuration endpoints, deployment pipelines
- **Infrastructure controls**: Cloud IAM, container orchestration, DNS management

### Step 5: Attack Surface Scoring

Rate each entry point by:
- **Exposure**: Internet-facing > authenticated > internal
- **Complexity**: Simple input > complex parsing > binary protocols
- **Impact**: Admin function > user data > public data
- **Existing controls**: No validation > partial validation > comprehensive validation

## Output

```
# Attack Surface Map

## Summary
- Total entry points: [count]
- Internet-facing: [count]
- Authenticated-only: [count]
- Internal: [count]
- Trust boundaries: [count]
- High-value targets: [count]

## Entry Points

### External (Unauthenticated)
| # | Entry Point | Method | Input Type | Validation | Risk |
|---|------------|--------|------------|------------|------|

### External (Authenticated)
| # | Entry Point | Method | Auth Required | Authorization | Risk |
|---|------------|--------|---------------|---------------|------|

### Internal
| # | Entry Point | Source | Input Type | Validation | Risk |

## Trust Boundaries
[Diagram or table showing trust level transitions]

## Data Flows
[Critical data flows crossing trust boundaries]

## High-Value Targets
[Prioritized list with location and current protections]

## Attack Surface Reduction Recommendations
[Opportunities to reduce exposure]
```

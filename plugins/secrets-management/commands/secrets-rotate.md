# /secrets-rotate

> Plan and document a secret rotation procedure for identified credentials.

## Trigger

Use when you need to rotate one or more credentials, whether due to:

- Confirmed credential leak (immediate rotation required)
- Scheduled rotation (periodic hygiene)
- Employee departure (access revocation)
- Compliance requirement (PCI DSS, SOC 2 mandated rotation)
- Security incident response

## Input

- **Required**: The type of credential to rotate (AWS key, database password, API key, TLS certificate, etc.)
- **Required**: The current context -- where the credential is used (which services, environments, configurations)
- **Optional**: `--emergency` -- skip validation steps, prioritize speed over safety (for confirmed leaks)
- **Optional**: `--service [name]` -- scope rotation to a specific service or environment

## Process

1. **Credential Inventory**: Identify all locations where the credential is used:
   - Application configuration (environment variables, config files, vault entries)
   - CI/CD pipelines (GitHub Secrets, GitLab CI Variables, Jenkins Credentials)
   - Infrastructure (Terraform state, Kubernetes secrets, cloud provider configurations)
   - Third-party integrations (webhooks, API callbacks, partner configurations)
   - Documentation and runbooks (if credentials were unfortunately documented)

2. **Impact Assessment**: Determine what breaks if the old credential is revoked:
   - Which services depend on this credential?
   - Are there multiple environments (dev, staging, production) using the same credential?
   - Are there external partners or third-party services using this credential?
   - What is the expected downtime window?

3. **Rotation Strategy Selection**:

   **Dual-Credential Rotation** (preferred, zero-downtime):
   - Generate new credential
   - Deploy new credential alongside old (both are valid)
   - Update all consumers to use new credential
   - Verify all consumers work with new credential
   - Revoke old credential

   **Cut-Over Rotation** (when dual-credential is not possible):
   - Schedule maintenance window
   - Generate new credential
   - Revoke old credential
   - Deploy new credential to all consumers simultaneously
   - Verify all consumers work

   **Emergency Rotation** (confirmed leak, speed over safety):
   - Revoke old credential immediately
   - Generate new credential
   - Deploy to all consumers
   - Accept potential brief outage
   - Verify recovery

4. **Procedure Generation**: Create a step-by-step rotation procedure specific to the credential type with exact commands, API calls, or console steps.

5. **Verification Plan**: Define how to verify the rotation succeeded:
   - Service health checks
   - Authentication test calls
   - Log monitoring for authentication failures
   - Alerting for the old credential being used (honeytokens)

6. **Documentation**: Record the rotation in the audit trail.

## Output

```
# Secret Rotation Plan
Credential: [type and identifier, masked]
Reason: [leak / scheduled / departure / incident]
Strategy: [dual-credential / cut-over / emergency]
Estimated Duration: [time]

## Pre-Rotation Checklist
- [ ] All consumers of this credential identified
- [ ] Rotation window communicated to stakeholders
- [ ] Rollback plan documented
- [ ] Monitoring dashboards open

## Rotation Steps

### Step 1: Generate New Credential
[Exact command or console steps]

### Step 2: Deploy New Credential
[For each consumer:]
- Service A: [update method -- vault, env var, config, etc.]
- Service B: [update method]
- CI/CD: [update method]

### Step 3: Verify New Credential
- [ ] Service A health check: [command/URL]
- [ ] Service B health check: [command/URL]
- [ ] No authentication errors in logs

### Step 4: Revoke Old Credential
[Exact command or console steps]

### Step 5: Post-Rotation Verification
- [ ] Old credential confirmed revoked
- [ ] All services operational
- [ ] No lingering references to old credential

## Rollback Plan
[If rotation fails, how to revert]

## Audit Record
- Rotated by: [who]
- Rotated at: [timestamp]
- Reason: [documented reason]
- Next rotation due: [date]
```

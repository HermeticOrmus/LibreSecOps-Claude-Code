# /azure-sec-audit

> Structured security audit of Azure configuration covering Entra ID, NSGs, storage accounts, Activity Logs, and Azure Policy.

## Trigger

Use when you need to:
- Review Azure subscription or tenant configuration for security gaps
- Audit Terraform, ARM, or Bicep templates before deployment
- Evaluate Entra ID security posture (MFA, Conditional Access, PIM)
- Prepare for a CIS Azure Benchmark assessment or SOC 2 audit
- Investigate Azure security posture after organizational changes

## Input

One of:
- **Live environment**: Azure CLI (`az`) authenticated with Reader role at subscription level + Global Reader in Entra ID
- **Infrastructure-as-code**: Terraform files (`.tf`) using azurerm/azuread providers, ARM templates (`.json`), or Bicep files (`.bicep`)
- **Configuration export**: Output from `az` commands, Defender for Cloud exports, Azure Policy compliance reports
- **Specific scope**: Focus area (e.g., "Entra ID only", "networking", "storage accounts")

## Process

### Phase 1: Identity (Entra ID)

1. **Authentication security**
   - MFA status for all users (`az ad user list` + Conditional Access policies)
   - Conditional Access policies covering: all users baseline, admin MFA, risky sign-in, device compliance
   - Legacy authentication blocked (Conditional Access policy blocking legacy auth protocols)
   - Password policy (self-service reset, banned passwords, smart lockout)

2. **Privileged access**
   - PIM enabled for eligible role assignments (Global Admin, Contributor, Owner)
   - Standing admin accounts (permanent vs eligible assignments)
   - Emergency access (break-glass) accounts properly configured
   - Admin accounts without MFA (critical finding)

3. **Service principals & app registrations**
   - App registrations with client secrets (vs certificate-based authentication)
   - Service principals with Owner or Contributor at high scope
   - Multi-tenant apps with excessive permissions
   - Admin consent grants review
   - Managed Identity adoption vs service principal secrets

4. **Guest access**
   - External collaboration settings (who can invite guests)
   - Guest user access restrictions
   - Access reviews configured for guest users

### Phase 2: Azure RBAC

5. **Role assignments**
   - Owner role assignments (`az role assignment list --role Owner`)
   - Contributor at subscription or management group level
   - Custom roles with excessive permissions (e.g., `*/write`, `*/delete`)
   - Orphaned role assignments (principals that no longer exist)

6. **Management group hierarchy**
   - Structure and inheritance patterns
   - Policy assignments at each level
   - RBAC assignments propagating broadly

### Phase 3: Network Security

7. **NSG rules**
   - Inbound `Any/Any` or `*/0.0.0.0/0` on ports 22, 3389, 445, 1433, 3306, 5432
   - NSGs with no deny rules (relying only on default deny)
   - Subnets without NSGs
   - Application Security Groups for workload grouping

8. **Network exposure**
   - Public IP addresses and their associations
   - Azure Firewall or Network Virtual Appliances
   - Private Endpoints vs Service Endpoints for PaaS services
   - Hub-spoke topology validation

### Phase 4: Data Protection

9. **Storage accounts**
   - Public blob access enabled (`az storage account list --query "[].allowBlobPublicAccess"`)
   - Shared Key access enabled (should use Entra ID authentication)
   - Minimum TLS version < 1.2
   - Network rules (storage firewall) -- default deny configured
   - Soft delete and versioning enabled
   - Encryption: Microsoft-managed vs customer-managed keys

10. **Key Vault**
    - Access model: vault access policy vs Azure RBAC (RBAC preferred)
    - Soft delete and purge protection enabled
    - Key Vault firewall configured
    - Private endpoint for Key Vault
    - Secret and key expiration policies

### Phase 5: Logging & Monitoring

11. **Activity Logs**
    - Diagnostic settings exporting to Log Analytics workspace
    - Retention period >= 365 days
    - Activity Log alerts for: policy assignment changes, role assignment changes, NSG changes, Key Vault access, resource deletion

12. **Microsoft Defender for Cloud**
    - Plans enabled: Servers, Storage, SQL, App Service, Key Vault, DNS, Resource Manager, Containers
    - Auto-provisioning of agents
    - Email notifications configured
    - Secure Score review

### Phase 6: Azure Policy

13. **Policy compliance**
    - Regulatory compliance initiatives assigned (CIS, MCSB)
    - Non-compliant resource count and severity
    - Remediation tasks for auto-remediable policies
    - Custom policies for organization-specific requirements

## Output

```
## Azure Security Audit Results

### Scope
- Tenant: [Tenant ID]
- Subscription(s): [Subscription IDs]
- Method: [Live/IaC/Config export]
- Date: [Assessment date]

### Summary
| Category | Critical | High | Medium | Low | Pass |
|----------|----------|------|--------|-----|------|
| Entra ID |          |      |        |     |      |
| RBAC     |          |      |        |     |      |
| Network  |          |      |        |     |      |
| Data     |          |      |        |     |      |
| Logging  |          |      |        |     |      |
| Policy   |          |      |        |     |      |

### Findings (by severity)

#### Critical
[Findings with az CLI or PowerShell remediation]

#### High
[Findings]

#### Medium
[Findings]

### Remediation Priority
1. [Immediate -- identity-related exposure]
2. [High -- data exposure or missing detection]
3. [Medium -- defense in depth]

### Defender for Cloud Score
[Current score and top recommendations]

### Positive Findings
[Well-configured controls]
```

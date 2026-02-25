# Azure Identity Patterns

> Entra ID security patterns, Conditional Access design, Managed Identities, Privileged Identity Management, and service principal governance.

## Knowledge Base

### Entra ID Security Architecture

Entra ID (formerly Azure Active Directory) is the identity control plane for all Microsoft cloud services. It handles:

- **Authentication**: Who are you? (MFA, passwordless, FIDO2, certificate-based)
- **Authorization**: What can you access? (Conditional Access, Azure RBAC, app roles)
- **Governance**: Should you still have access? (Access Reviews, Entitlement Management, PIM)

Two separate role systems exist and are commonly confused:

| System | Controls | Example Roles |
|--------|----------|---------------|
| **Entra ID Roles** | Directory operations (user management, app registration, Conditional Access) | Global Administrator, User Administrator, Application Administrator |
| **Azure RBAC Roles** | Resource operations (VMs, storage, databases) | Owner, Contributor, Reader, custom roles |

A Global Administrator can elevate to Azure RBAC through "Access management for Azure resources" toggle, but by default the two systems are independent.

### Conditional Access Policy Evaluation

Conditional Access policies are evaluated AFTER first-factor authentication but BEFORE access is granted. The evaluation logic:

1. All policies are evaluated simultaneously (not in order)
2. If ANY policy's conditions match AND its grant controls are not satisfied, access is DENIED
3. If multiple policies match, ALL grant controls from all matching policies must be satisfied
4. Session controls from all matching policies are combined
5. Exclude takes precedence over include for user/group targeting
6. Report-only mode evaluates but does not enforce (useful for testing)

### Managed Identity Types

| Type | Lifecycle | Scope | Use Case |
|------|-----------|-------|----------|
| **System-assigned** | Tied to the resource. Created when enabled, deleted when resource is deleted. | Single resource. 1:1 relationship. | Simple workloads where one resource needs one identity. |
| **User-assigned** | Independent resource. Created and deleted separately. | Can be assigned to multiple resources. Many:many. | Shared identity across multiple resources. Survives resource deletion. |

**Why Managed Identities matter**: They eliminate secrets entirely. The credential rotation happens automatically, the credentials are never exposed to humans, and they cannot be extracted and used externally (unlike service principal secrets or certificates).

## Patterns

### Pattern 1: Conditional Access Baseline (Five Core Policies)

Every Entra ID tenant should have at minimum these five policies:

```
Policy 1: Require MFA for all users
  - Users: All users
  - Exclude: Emergency access accounts (break-glass)
  - Cloud apps: All cloud apps
  - Grant: Require multifactor authentication
  - Session: Sign-in frequency 7 days

Policy 2: Block legacy authentication
  - Users: All users
  - Cloud apps: All cloud apps
  - Conditions: Client apps = Exchange ActiveSync, Other clients
  - Grant: Block access

Policy 3: Require MFA for Azure management
  - Users: All users
  - Cloud apps: Microsoft Azure Management
  - Grant: Require multifactor authentication
  - Session: Sign-in frequency 1 hour

Policy 4: Require compliant device for sensitive apps
  - Users: All users
  - Cloud apps: [Selected sensitive applications]
  - Grant: Require device to be marked as compliant
  - (Requires Intune enrollment)

Policy 5: Block high-risk sign-ins
  - Users: All users
  - Conditions: Sign-in risk = High
  - Grant: Block access
  - (Requires Entra ID P2 license)
```

**Why this works**: These five policies cover the most common attack vectors -- credential theft (MFA), legacy protocol abuse (block legacy auth), admin console attacks (management MFA), untrusted devices (compliance), and anomalous sign-ins (risk-based blocking).

### Pattern 2: Managed Identity for Application Access

```bash
# Create a user-assigned managed identity
az identity create \
  --name "app-data-processor" \
  --resource-group "rg-identity" \
  --location "eastus"

# Assign it to a VM
az vm identity assign \
  --name "processing-vm" \
  --resource-group "rg-compute" \
  --identities "/subscriptions/SUB_ID/resourcegroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/app-data-processor"

# Grant it access to a specific storage container
az role assignment create \
  --assignee-object-id "$(az identity show --name app-data-processor --resource-group rg-identity --query principalId -o tsv)" \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/SUB_ID/resourceGroups/rg-data/providers/Microsoft.Storage/storageAccounts/mystorageacct/blobServices/default/containers/input-data"

# Application code uses DefaultAzureCredential -- no secrets needed
# from azure.identity import DefaultAzureCredential
# credential = DefaultAzureCredential()
```

**Why this works**: No secrets to manage, rotate, or leak. The identity is scoped to a specific storage container (not the whole account), using a data-plane role (`Storage Blob Data Reader`) rather than a management-plane role. The `DefaultAzureCredential` class in Azure SDKs automatically discovers the managed identity.

### Pattern 3: Privileged Identity Management (PIM) Configuration

```
Role: Global Administrator
  - Assignment type: Eligible (not permanent)
  - Maximum activation duration: 2 hours
  - Require justification: Yes
  - Require ticket information: Yes
  - Require MFA on activation: Yes
  - Require approval: Yes (by another Global Admin)
  - Notification: Email all Global Admins on activation

Role: Contributor (Subscription scope)
  - Assignment type: Eligible
  - Maximum activation duration: 8 hours
  - Require justification: Yes
  - Require MFA on activation: Yes
  - Require approval: No (too disruptive for daily work)
  - Access review: Quarterly
```

**Why this works**: Standing privileges (permanent assignments) are the biggest risk in Azure. PIM converts permanent assignments to just-in-time access -- administrators must explicitly activate their role, providing an audit trail and reducing the window of exposure.

### Pattern 4: Service Principal with Certificate (When Managed Identity is Not Possible)

```bash
# Create app registration with certificate authentication
az ad app create --display-name "external-cicd-pipeline"

# Create certificate (store in Key Vault in production)
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=external-cicd-pipeline"

# Upload certificate to app registration
az ad app credential reset \
  --id APP_ID \
  --cert @cert.pem \
  --append

# Create service principal
az ad sp create --id APP_ID

# Grant minimal RBAC
az role assignment create \
  --assignee APP_ID \
  --role "Contributor" \
  --scope "/subscriptions/SUB_ID/resourceGroups/rg-deploy" \
  --condition "((!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})))" \
  --condition-version "2.0"
```

**Why this works**: Certificate authentication is preferred over client secrets because certificates cannot be accidentally logged, they expire, and the private key never leaves the client. The RBAC condition further restricts the Contributor role to prevent role assignment escalation.

## Anti-Patterns

### Anti-Pattern 1: Permanent Global Administrator Assignments

Every permanent Global Admin is a high-value target. If any one account is compromised, the entire tenant is compromised.

**Fix**: Use PIM for all privileged roles. Maintain exactly two permanent emergency access (break-glass) accounts with monitoring alerts on their usage.

### Anti-Pattern 2: Service Principal Client Secrets

Client secrets are the Azure equivalent of passwords -- they can be copied, shared, committed to repos, and used from anywhere. They have no binding to a specific machine or workload.

**Fix**: Use Managed Identities wherever possible. When external authentication is required, use Workload Identity Federation (OIDC) or certificate-based authentication. Never use client secrets.

### Anti-Pattern 3: No Conditional Access Policies

Without Conditional Access, any valid credential from any location on any device grants full access. This makes credential theft (phishing, token theft, password spray) trivially exploitable.

**Fix**: Implement the five core policies from Pattern 1 at minimum. Conditional Access requires at minimum Entra ID P1 licensing.

### Anti-Pattern 4: Using Storage Account Access Keys

Storage account access keys provide root-level access to the entire storage account. They do not expire, cannot be scoped, and do not generate individual audit trails.

**Fix**: Disable Shared Key authorization on the storage account. Use Entra ID authentication with Azure RBAC data-plane roles (`Storage Blob Data Reader`, `Storage Blob Data Contributor`). For external access, use SAS tokens scoped to specific containers, permissions, and time windows.

### Anti-Pattern 5: Owner Role at Subscription Level

The Owner role at subscription scope grants full control over every resource in the subscription AND the ability to grant access to others. Combined with a compromised identity, this enables complete subscription takeover.

**Fix**: Use Contributor (not Owner) for operational access. Assign Owner only through PIM with approval workflows. Use `User Access Administrator` separately when RBAC management is needed.

## References

- [Entra ID Security Operations Guide](https://learn.microsoft.com/en-us/entra/architecture/security-operations-introduction)
- [Conditional Access Overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [Managed Identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview)
- [Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
- [Azure RBAC Best Practices](https://learn.microsoft.com/en-us/azure/role-based-access-control/best-practices)
- [Maester -- Entra ID Security Testing](https://maester.dev/)
- [ROADtools -- Entra ID Enumeration](https://github.com/dirkjanm/ROADtools)
- [AzureHound -- Azure Attack Path Mapping](https://github.com/BloodHoundAD/AzureHound)

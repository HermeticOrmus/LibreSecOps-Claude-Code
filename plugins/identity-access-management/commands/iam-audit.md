# /iam-audit

> Audit access controls across applications and infrastructure.

## Trigger

Use when you need to:
- Review who has access to what in a system
- Identify over-privileged accounts and privilege creep
- Prepare for a SOC 2, PCI DSS, or ISO 27001 audit (access control section)
- Evaluate access controls after organizational changes
- Investigate whether former employees still have access

## Input

One or more of:
- **Access control configuration**: RBAC role definitions, IAM policies, ACLs, group memberships
- **User/identity list**: Current identities with their assigned roles and permissions
- **Access logs**: Authentication logs, authorization decision logs, API access logs
- **Organizational data**: Org chart, team structure, role definitions (for comparison to actual access)
- **Specific scope**: System, application, or identity subset to audit

## Process

### Phase 1: Identity Inventory

1. **Identity enumeration**
   - Count and categorize identities: human users, service accounts, API keys, external/guest users
   - Identify identity sources: internal directory, SSO, local accounts, federated
   - Last activity timestamp for each identity
   - Dormant accounts (no activity in 90+ days)
   - Orphaned accounts (no owner, former employees)

2. **Authentication assessment**
   - MFA enrollment status for all human users
   - MFA enforcement (required vs optional)
   - Password policy compliance
   - Service account authentication method (keys, certificates, managed identity)

### Phase 2: Permission Analysis

3. **Role/permission inventory**
   - All defined roles and their permissions
   - Number of users per role
   - Roles with no users (dormant roles)
   - Roles with excessive permissions (admin-equivalent)
   - Custom vs predefined roles

4. **Permission usage analysis** (if access logs available)
   - Granted permissions vs actually used permissions per identity
   - Identities using less than 20% of granted permissions (over-privileged)
   - Permissions never used by any identity (candidate for removal)

5. **Administrative access**
   - Count of administrator-level accounts
   - Whether admin accounts are separate from regular accounts
   - Whether admin access is permanent or just-in-time
   - Emergency/break-glass accounts and their monitoring

### Phase 3: Access Control Model

6. **Model evaluation**
   - Is the access control model consistent? (not mixed RBAC/ad-hoc)
   - Is there role explosion? (more roles than users is a warning sign)
   - Are permissions granular enough? (or too coarse, or too fine)
   - Is the model documented and understood by administrators?

7. **Segregation of duties**
   - Identify toxic permission combinations
   - Users who can both create and approve
   - Users who can both deploy and audit
   - Compensating controls for accepted violations

### Phase 4: Governance

8. **Access lifecycle**
   - Is there a defined access request process?
   - Are access requests approved by the resource owner?
   - Time from request to grant (too fast = no review, too slow = workaround pressure)
   - Time from termination to access revocation
   - Are access reviews conducted? How often? Evidence of changes?

9. **Shared credentials**
   - Shared admin accounts
   - Shared service accounts across multiple systems
   - API keys used by multiple people or systems

## Output

```
## IAM Audit Results

### Scope
- System(s): [Systems audited]
- Identity count: [Total by type]
- Date: [Assessment date]

### Summary
| Category | Critical | High | Medium | Low | Pass |
|----------|----------|------|--------|-----|------|
| Authentication |     |      |        |     |      |
| Authorization  |     |      |        |     |      |
| Governance     |     |      |        |     |      |
| Lifecycle      |     |      |        |     |      |

### Identity Health
- Total identities: [Count]
- Dormant (90+ days): [Count] -- REVIEW
- No MFA: [Count] -- REMEDIATE
- Admin accounts: [Count] -- should be < 5% of total

### Findings (by severity)

#### Critical
[Findings with specific remediation]

#### High
[Findings]

### Recommendations
1. [Revoke excess permissions]
2. [Enable MFA for remaining accounts]
3. [Implement access review process]
4. [Automate deprovisioning]
```

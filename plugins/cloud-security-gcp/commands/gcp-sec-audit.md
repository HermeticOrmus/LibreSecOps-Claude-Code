# /gcp-sec-audit

> Structured security audit of GCP configuration covering IAM, GCS, VPC, Cloud Audit Logs, and Organization Policies.

## Trigger

Use when you need to:
- Review GCP project or organization configuration for security gaps
- Audit Terraform configurations targeting GCP before deployment
- Validate Organization Policy constraints and IAM bindings
- Prepare for a CIS GCP Foundations Benchmark assessment
- Investigate GCP security posture after organizational changes

## Input

One of:
- **Live environment**: `gcloud` CLI authenticated with Viewer role at project or organization level
- **Infrastructure-as-code**: Terraform files (`.tf`) using the Google provider
- **Configuration export**: Output from `gcloud` commands, Security Command Center findings, ScoutSuite reports
- **Specific scope**: Focus area (e.g., "IAM only", "networking", "Cloud SQL")

## Process

### Phase 1: Identity & Access Management

1. **Service account hygiene**
   - Service accounts with keys (`gcloud iam service-accounts keys list --iam-account=SA_EMAIL`)
   - Default service accounts in use (PROJECT_NUMBER-compute@developer.gserviceaccount.com)
   - Service accounts with basic roles (Owner, Editor)
   - User-managed service account key rotation (keys older than 90 days)
   - Service account impersonation chains

2. **IAM bindings**
   - Basic roles (Owner/Editor/Viewer) assigned to any principal
   - `allUsers` or `allAuthenticatedUsers` in any IAM binding
   - IAM bindings at organization/folder level (high blast radius)
   - Separation of duties (same principal with conflicting roles)
   - Domain-restricted sharing (`constraints/iam.allowedPolicyMemberDomains`)

3. **Workload Identity**
   - External workloads using service account keys vs Workload Identity Federation
   - GKE workloads using node-level SA vs Workload Identity

### Phase 2: Storage Security

4. **Cloud Storage (GCS)**
   - Uniform bucket-level access enforced (`gcloud storage buckets describe gs://BUCKET`)
   - Public buckets (`allUsers` or `allAuthenticatedUsers` in bucket IAM)
   - Bucket-level CMEK encryption
   - Retention policies on critical buckets
   - Access logging enabled

5. **Cloud SQL**
   - Instances with public IP (`gcloud sql instances list --format="table(name,ipAddresses)"`)
   - Authorized networks using `0.0.0.0/0`
   - SSL/TLS enforcement (`requireSsl`)
   - Automated backups enabled
   - Database flags: `log_connections`, `log_disconnections`, `log_checkpoints`

### Phase 3: Network Security

6. **Firewall rules**
   - Rules allowing `0.0.0.0/0` ingress on sensitive ports (22, 3389, 3306, 5432)
   - Default-allow-* rules still in place
   - Firewall rules with priority conflicts
   - Hierarchical firewall policies vs project-level rules

7. **VPC configuration**
   - VPC Flow Logs enabled on subnets
   - Private Google Access enabled for subnets without external IPs
   - VPC Service Controls perimeter (for Premium SCC users)
   - Cloud NAT for outbound internet access (vs direct external IPs)
   - DNS security: DNSSEC on managed zones

### Phase 4: Logging & Monitoring

8. **Cloud Audit Logs**
   - Data Access logs enabled for critical services (`gcloud projects get-iam-policy` + audit config)
   - Log sinks configured for long-term retention
   - Log sinks to a separate project (security/logging project)
   - Log bucket retention >= 365 days for compliance

9. **Monitoring & Detection**
   - Security Command Center enabled (Standard vs Premium)
   - Log-based alerting policies for: IAM changes, firewall rule changes, project ownership changes, Cloud Audit Logs config changes, custom role changes
   - Security Command Center findings being acted on

### Phase 5: Organization-Level Controls

10. **Organization Policies**
    - `iam.disableServiceAccountKeyCreation` -- enforced
    - `compute.vmExternalIpAccess` -- restricted
    - `sql.restrictPublicIp` -- enforced
    - `storage.uniformBucketLevelAccess` -- enforced
    - `iam.allowedPolicyMemberDomains` -- set to organization domain
    - `compute.requireShieldedVm` -- enforced
    - Custom constraints for organization-specific requirements

## Output

```
## GCP Security Audit Results

### Scope
- Organization: [Org ID if applicable]
- Project(s): [Project IDs]
- Method: [Live/IaC/Config export]
- Date: [Assessment date]

### Summary
| Category | Critical | High | Medium | Low | Pass |
|----------|----------|------|--------|-----|------|
| IAM      |          |      |        |     |      |
| Storage  |          |      |        |     |      |
| Network  |          |      |        |     |      |
| Logging  |          |      |        |     |      |
| Org Policy |        |      |        |     |      |

### Findings (by severity)

#### Critical
[Findings with remediation -- gcloud commands and Terraform]

#### High
[Findings]

#### Medium
[Findings]

### Remediation Priority
1. [Immediate -- active exposure]
2. [High -- significant risk reduction]
3. [Medium -- defense in depth]

### Positive Findings
[Well-configured controls]
```

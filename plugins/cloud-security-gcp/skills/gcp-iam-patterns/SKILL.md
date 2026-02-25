# GCP IAM Patterns

> Secure GCP IAM patterns, custom role design, IAM conditions, Workload Identity Federation, and the GCP permission model.

## Knowledge Base

### GCP IAM Model Fundamentals

GCP IAM works through **bindings** that connect **principals** to **roles** on **resources**. The key concepts:

- **Principal**: Who (user, group, service account, domain, allUsers, allAuthenticatedUsers)
- **Role**: A collection of permissions (e.g., `roles/storage.objectViewer` includes `storage.objects.get` and `storage.objects.list`)
- **Resource**: Where the binding applies (organization, folder, project, or individual resource)
- **Binding**: The association of principal + role + resource, optionally with conditions

**Inheritance flows downward.** A binding at the organization level applies to every folder, project, and resource beneath it. A binding at the project level applies to every resource in that project. Bindings are additive -- you cannot remove an inherited permission at a lower level (but you can use deny policies).

### Role Types

| Type | Examples | When to Use |
|------|----------|-------------|
| **Basic** | `roles/owner`, `roles/editor`, `roles/viewer` | Almost never. Overly broad. Legacy. |
| **Predefined** | `roles/storage.objectViewer`, `roles/compute.networkAdmin` | Default choice. Google-maintained, least-privilege per service. |
| **Custom** | `projects/my-proj/roles/customRole` | When predefined roles include permissions you do not want to grant. |

**Critical rule**: Never assign basic roles to service accounts. `roles/editor` on a service account grants write access to nearly every service in the project.

### IAM Deny Policies

Introduced to address the "additive-only" limitation. Deny policies are evaluated before allow policies and cannot be overridden:

```yaml
# Deny policy: prevent any principal from disabling audit logs
deniedPermissions:
  - "cloudaudit.googleapis.com/activityLogs.disable"
  - "logging.googleapis.com/logEntries.delete"
deniedPrincipals:
  - "principalSet://goog/public:all"
exceptionPrincipals:
  - "principal://iam.googleapis.com/projects/-/serviceAccounts/security-admin@project.iam.gserviceaccount.com"
```

## Patterns

### Pattern 1: Least-Privilege Service Account for Cloud Functions

```bash
# Create a dedicated service account
gcloud iam service-accounts create cloud-fn-processor \
  --display-name="Order Processor Cloud Function"

# Grant only the specific permissions needed
gcloud projects add-iam-policy-binding my-project \
  --member="serviceAccount:cloud-fn-processor@my-project.iam.gserviceaccount.com" \
  --role="roles/datastore.user" \
  --condition='expression=resource.name.startsWith("projects/my-project/databases/(default)/documents/orders"),title=orders-collection-only'

gcloud projects add-iam-policy-binding my-project \
  --member="serviceAccount:cloud-fn-processor@my-project.iam.gserviceaccount.com" \
  --role="roles/pubsub.publisher" \
  --condition='expression=resource.name == "projects/my-project/topics/order-notifications",title=single-topic-only'
```

**Why this works**: Dedicated service account per function (not the default SA), predefined roles (not basic), and IAM conditions limiting access to specific resources. The condition uses CEL (Common Expression Language) to match resource names.

### Pattern 2: Workload Identity Federation (Replacing Service Account Keys)

Service account keys are long-lived credentials that can be stolen and used from anywhere. Workload Identity Federation eliminates them:

```bash
# Create a Workload Identity Pool
gcloud iam workload-identity-pools create "github-actions-pool" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# Create a provider for GitHub Actions OIDC
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-actions-pool" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository_owner == 'my-org'"

# Allow the federated identity to impersonate a service account
gcloud iam service-accounts add-iam-policy-binding \
  "deploy-sa@my-project.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/my-org/my-repo"
```

**Why this works**: GitHub Actions authenticates via OIDC. No service account key is created, stored, or rotated. The `attribute-condition` ensures only your organization can use the pool. The `attribute.repository` mapping restricts which repos can impersonate which service accounts.

### Pattern 3: Custom Role for Minimal BigQuery Access

```bash
gcloud iam roles create bigquery_data_reader \
  --project=my-project \
  --title="BigQuery Data Reader" \
  --description="Read-only access to query BigQuery tables, no export" \
  --permissions="bigquery.datasets.get,bigquery.tables.get,bigquery.tables.getData,bigquery.tables.list,bigquery.jobs.create" \
  --stage=GA
```

**Why this works**: The predefined `roles/bigquery.dataViewer` includes `bigquery.tables.export` which allows data extraction. This custom role removes that permission while keeping read access. Custom roles let you subtract permissions from predefined roles.

### Pattern 4: Organization-Level Domain Restriction

```yaml
# Terraform: Restrict IAM bindings to your domain only
resource "google_org_policy_policy" "domain_restricted_sharing" {
  name   = "organizations/${var.org_id}/policies/iam.allowedPolicyMemberDomains"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      values {
        allowed_values = ["C0xxxxxxx"]  # Your Cloud Identity customer ID
      }
    }
  }
}
```

**Why this works**: This Organization Policy prevents anyone from granting IAM roles to users, groups, or service accounts outside your organization's Cloud Identity domain. Stops accidental (or malicious) sharing with external accounts.

### Pattern 5: GKE Workload Identity

```yaml
# Kubernetes ServiceAccount annotated for Workload Identity
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: production
  annotations:
    iam.gke.io/gcp-service-account: app-sa@my-project.iam.gserviceaccount.com
---
# IAM binding: allow k8s SA to impersonate GCP SA
# gcloud iam service-accounts add-iam-policy-binding \
#   app-sa@my-project.iam.gserviceaccount.com \
#   --role roles/iam.workloadIdentityUser \
#   --member "serviceAccount:my-project.svc.id.goog[production/app-sa]"
```

**Why this works**: Each Kubernetes workload uses its own GCP service account via Workload Identity, instead of every pod on the node sharing the node's service account. This is the GKE equivalent of the "no shared credentials" principle.

## Anti-Patterns

### Anti-Pattern 1: Using the Default Compute Engine Service Account

Every GCP project has a default Compute Engine SA: `PROJECT_NUMBER-compute@developer.gserviceaccount.com`. It has `roles/editor` by default. VMs, Cloud Functions, and other services use it if no SA is specified.

**Risk**: Any workload using this SA has editor access to the entire project. A container escape or SSRF gives the attacker near-full project access.

**Fix**: Create dedicated service accounts per workload. Disable the default SA or remove its `roles/editor` binding.

### Anti-Pattern 2: Service Account Key Files

Creating and downloading SA key JSON files (`gcloud iam service-accounts keys create`) creates long-lived credentials that:
- Never expire (unless you set an expiration, which most people don't)
- Can be used from any IP (no IP restriction by default)
- Are often committed to git repos, stored in CI/CD config, or shared via Slack

**Fix**: Use Workload Identity Federation for external workloads. Use Workload Identity for GKE. Use attached service accounts for Compute Engine, Cloud Functions, Cloud Run.

### Anti-Pattern 3: allAuthenticatedUsers

`allAuthenticatedUsers` sounds like it means "users in my organization." It does NOT. It means anyone with any Google account, including personal Gmail accounts. This is effectively public access.

### Anti-Pattern 4: Overly Broad IAM at Organization Level

Granting `roles/editor` at the organization level gives write access to every project in the entire organization. Even `roles/viewer` at org level may expose sensitive resources across unrelated projects.

**Fix**: Grant roles at the lowest applicable level. Use folders to group projects with similar access needs.

## References

- [GCP IAM Overview](https://cloud.google.com/iam/docs/overview)
- [Understanding Roles](https://cloud.google.com/iam/docs/understanding-roles)
- [IAM Conditions](https://cloud.google.com/iam/docs/conditions-overview)
- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [GKE Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- [IAM Deny Policies](https://cloud.google.com/iam/docs/deny-overview)
- [Organization Policy Constraints](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)
- [Rhino Security Labs -- GCP Privilege Escalation](https://rhinosecuritylabs.com/gcp/privilege-escalation-google-cloud-platform-part-1/)

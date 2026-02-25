# Vault Patterns

> Reference knowledge for secret storage platforms, access patterns, and vault architecture including HashiCorp Vault, AWS Secrets Manager, and GCP Secret Manager.

## Knowledge Base

### Vault Architecture Fundamentals

A secrets vault is a centralized, access-controlled, audit-logged system for storing and distributing sensitive credentials. The core properties of any vault solution:

- **Encryption at rest**: Secrets are encrypted before storage. The vault manages the encryption keys.
- **Encryption in transit**: All communication with the vault uses TLS.
- **Access control**: Fine-grained policies define who or what can read, write, or manage specific secrets.
- **Audit logging**: Every access is logged with identity, timestamp, and operation.
- **Dynamic secrets**: The ability to generate credentials on demand with automatic expiration.
- **Secret versioning**: Previous values are preserved for rollback.
- **Lease management**: Secrets have TTLs and must be renewed or re-fetched.

### Platform Comparison

| Feature | HashiCorp Vault | AWS Secrets Manager | GCP Secret Manager |
|---------|----------------|--------------------|--------------------|
| Dynamic secrets | Yes (DB, AWS, PKI, SSH) | No (static only) | No (static only) |
| Built-in rotation | Via secret engines | Lambda-based rotation | Cloud Functions-based |
| Auth methods | 15+ (AppRole, K8s, AWS, GCP, OIDC, ...) | IAM only | IAM only |
| PKI / CA | Yes (full CA) | No (use ACM) | No (use CAS) |
| Transit encryption | Yes (encrypt-as-a-service) | No (use KMS) | No (use KMS) |
| Self-hosted option | Yes | No (managed only) | No (managed only) |
| Pricing | Free (OSS), Enterprise $$$ | $0.40/secret/month + $0.05/10K API calls | $0.06/secret version/month + $0.03/10K access ops |
| Complexity | High (requires operational expertise) | Low (managed service) | Low (managed service) |

### The Bootstrap Problem

Every vault needs an initial credential to authenticate. How does the first secret reach the application?

**Solution: Identity-based authentication**
- On AWS: Use IAM roles (EC2 instance profiles, ECS task roles, Lambda execution roles). The identity is the instance/task/function itself -- no static credential needed.
- On GCP: Use Workload Identity for GKE, service account impersonation with Workload Identity Federation for external workloads.
- On Kubernetes: Use Kubernetes service account tokens with the vault's Kubernetes auth method.
- Locally: Use developer identity (OIDC via SSO provider) to access the vault.

## Patterns

### Pattern 1: HashiCorp Vault with Kubernetes

```hcl
# vault-config.hcl -- Vault server configuration
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/vault/tls/tls.crt"
  tls_key_file  = "/vault/tls/tls.key"
}

api_addr     = "https://vault.vault.svc.cluster.local:8200"
cluster_addr = "https://vault.vault.svc.cluster.local:8201"
ui           = true
```

```bash
# Enable Kubernetes auth
vault auth enable kubernetes
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"

# Create a policy for the app
vault policy write myapp-policy - <<EOF
path "secret/data/myapp/*" {
  capabilities = ["read"]
}
path "database/creds/myapp-role" {
  capabilities = ["read"]
}
EOF

# Bind the policy to a Kubernetes service account
vault write auth/kubernetes/role/myapp \
  bound_service_account_names=myapp \
  bound_service_account_namespaces=production \
  policies=myapp-policy \
  ttl=1h
```

Application access via sidecar (Vault Agent Injector):
```yaml
# Kubernetes deployment with Vault Agent sidecar
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "myapp"
        vault.hashicorp.com/agent-inject-secret-db-creds: "database/creds/myapp-role"
        vault.hashicorp.com/agent-inject-template-db-creds: |
          {{- with secret "database/creds/myapp-role" -}}
          postgresql://{{ .Data.username }}:{{ .Data.password }}@db:5432/myapp
          {{- end }}
    spec:
      serviceAccountName: myapp
      containers:
        - name: myapp
          image: myapp:latest
          # Credentials are at /vault/secrets/db-creds
```

### Pattern 2: AWS Secrets Manager with Automatic Rotation

```python
# Lambda rotation function for RDS credentials
import boto3
import json

def lambda_handler(event, context):
    """AWS Secrets Manager rotation Lambda template."""
    secret_id = event['SecretId']
    step = event['Step']
    token = event['ClientRequestToken']

    sm = boto3.client('secretsmanager')

    if step == "createSecret":
        # Generate new password
        new_password = sm.get_random_password(
            PasswordLength=32,
            ExcludeCharacters='"@/\\'
        )['RandomPassword']

        current = json.loads(
            sm.get_secret_value(SecretId=secret_id)['SecretString']
        )
        current['password'] = new_password

        sm.put_secret_value(
            SecretId=secret_id,
            ClientRequestToken=token,
            SecretString=json.dumps(current),
            VersionStages=['AWSPENDING']
        )

    elif step == "setSecret":
        # Update the database password
        pending = json.loads(
            sm.get_secret_value(
                SecretId=secret_id,
                VersionStage='AWSPENDING'
            )['SecretString']
        )
        # Use admin credentials to update the user's password
        update_rds_password(pending)

    elif step == "testSecret":
        # Verify the new password works
        pending = json.loads(
            sm.get_secret_value(
                SecretId=secret_id,
                VersionStage='AWSPENDING'
            )['SecretString']
        )
        test_database_connection(pending)

    elif step == "finishSecret":
        # Promote AWSPENDING to AWSCURRENT
        sm.update_secret_version_stage(
            SecretId=secret_id,
            VersionStage='AWSCURRENT',
            MoveToVersionId=token,
            RemoveFromVersionId=get_current_version_id(sm, secret_id)
        )
```

```hcl
# Terraform: AWS Secrets Manager with rotation
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "myapp/production/db"
  description = "RDS credentials for myapp production"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_rotation" "db_rotation" {
  secret_id           = aws_secretsmanager_secret.db_credentials.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
}
```

### Pattern 3: External Secrets Operator (Kubernetes)

Sync secrets from any external vault into Kubernetes secrets:

```yaml
# ExternalSecret resource -- pulls from AWS Secrets Manager into K8s
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: myapp-db-credentials
  namespace: production
spec:
  refreshInterval: 1h  # Re-sync from vault every hour
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: myapp-db-secret  # Name of the K8s secret to create
    creationPolicy: Owner
  data:
    - secretKey: DB_HOST
      remoteRef:
        key: myapp/production/db
        property: host
    - secretKey: DB_USERNAME
      remoteRef:
        key: myapp/production/db
        property: username
    - secretKey: DB_PASSWORD
      remoteRef:
        key: myapp/production/db
        property: password
```

### Pattern 4: SOPS for GitOps-Compatible Secret Storage

For teams that need encrypted secrets in git (GitOps, small teams, no dedicated vault):

```bash
# Encrypt a file with SOPS using age
sops --encrypt --age age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p \
  secrets.yaml > secrets.enc.yaml

# Decrypt for use
sops --decrypt secrets.enc.yaml > secrets.yaml

# Edit in-place (encrypts on save)
sops secrets.enc.yaml
```

```yaml
# .sops.yaml -- SOPS configuration
creation_rules:
  - path_regex: \.enc\.yaml$
    encrypted_regex: "^(data|stringData)$"
    age: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
  - path_regex: production/.*\.enc\.yaml$
    kms: arn:aws:kms:us-east-1:123456789:key/abcdef-1234-5678
```

## Anti-Patterns

- **Vault with static root tokens in production**: The Vault root token should be generated during init, used for initial setup, then revoked. Production access should use scoped policies with appropriate auth methods.
- **Storing vault credentials in environment variables permanently**: Environment variables are readable by any process. Use identity-based auth or short-lived tokens injected at runtime.
- **One secret for all environments**: Development, staging, and production must use different credentials. A leaked dev credential should not grant production access.
- **No rotation policy**: Even with a vault, credentials that never rotate accumulate risk. Define rotation schedules for every secret category.
- **Vault as a single point of failure without HA**: A vault outage that blocks all application starts is worse than hardcoded secrets. Configure high availability, caching, and graceful degradation.
- **Overly broad vault policies**: `path "secret/*" { capabilities = ["read"] }` gives every authenticated entity access to every secret. Apply least-privilege policies per service.

## References

- HashiCorp Vault Documentation: https://developer.hashicorp.com/vault/docs
- AWS Secrets Manager Best Practices: https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html
- GCP Secret Manager: https://cloud.google.com/secret-manager/docs
- External Secrets Operator: https://external-secrets.io/
- SOPS: https://github.com/getsops/sops
- NIST SP 800-57 (Key Management): https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final

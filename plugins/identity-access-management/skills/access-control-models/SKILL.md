# Access Control Models

> RBAC, ABAC, ReBAC patterns -- when to use which, implementation guidance, and common pitfalls.

## Knowledge Base

### Access Control Model Comparison

| Model | Decision Based On | Complexity | Best For | Weakness |
|-------|-------------------|-----------|----------|----------|
| **DAC** (Discretionary) | Owner grants access | Low | File systems, small teams | No central control, permission sprawl |
| **MAC** (Mandatory) | Security labels/clearances | High | Military, classified data | Inflexible, requires central authority |
| **RBAC** (Role-Based) | Assigned roles | Medium | Enterprise apps, most SaaS | Role explosion, coarse-grained |
| **ABAC** (Attribute-Based) | User/resource/environment attributes | High | Dynamic policies, fine-grained | Complex policy management, debugging |
| **ReBAC** (Relationship-Based) | Object relationships | Medium-High | Social networks, document sharing, multi-tenant | Relationship graph complexity |

### Decision Framework

```
Does access depend on WHO the user is (their role)?
  YES → Start with RBAC

Do you need decisions based on CONTEXT (time, location, device, risk)?
  YES → Layer ABAC on top of RBAC

Does access depend on RELATIONSHIPS between objects (owner, shared-with, org member)?
  YES → Consider ReBAC

Is the permission model mostly static (roles change rarely)?
  YES → RBAC is sufficient

Do you have many resources with different sharing patterns?
  YES → ReBAC (Google Zanzibar model)
```

## Patterns

### Pattern 1: RBAC Implementation (Application Level)

```python
# Role-Based Access Control implementation
from enum import Enum
from functools import wraps

class Permission(Enum):
    READ_REPORTS = "reports:read"
    WRITE_REPORTS = "reports:write"
    DELETE_REPORTS = "reports:delete"
    MANAGE_USERS = "users:manage"
    VIEW_AUDIT_LOG = "audit:read"
    MANAGE_SETTINGS = "settings:manage"

# Role definitions: map roles to permissions
ROLE_PERMISSIONS = {
    "viewer": {
        Permission.READ_REPORTS,
    },
    "analyst": {
        Permission.READ_REPORTS,
        Permission.WRITE_REPORTS,
        Permission.VIEW_AUDIT_LOG,
    },
    "manager": {
        Permission.READ_REPORTS,
        Permission.WRITE_REPORTS,
        Permission.DELETE_REPORTS,
        Permission.VIEW_AUDIT_LOG,
    },
    "admin": {
        Permission.READ_REPORTS,
        Permission.WRITE_REPORTS,
        Permission.DELETE_REPORTS,
        Permission.MANAGE_USERS,
        Permission.VIEW_AUDIT_LOG,
        Permission.MANAGE_SETTINGS,
    },
}

def require_permission(permission: Permission):
    """Decorator that checks if the current user has the required permission."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            user = get_current_user()
            user_permissions = set()
            for role in user.roles:
                user_permissions.update(ROLE_PERMISSIONS.get(role, set()))

            if permission not in user_permissions:
                log_auth_failure(user, permission, func.__name__)
                raise PermissionDeniedError(
                    f"Permission {permission.value} required"
                )

            log_auth_success(user, permission, func.__name__)
            return func(*args, **kwargs)
        return wrapper
    return decorator

# Usage
@require_permission(Permission.DELETE_REPORTS)
def delete_report(report_id: str):
    """Only users with DELETE_REPORTS permission can call this."""
    ...
```

**Why this works**: Permissions are granular (resource:action), roles bundle permissions, and the check is centralized in a decorator. Adding a new role only requires defining its permission set. The authorization decision is logged for audit trails.

### Pattern 2: ABAC Implementation (Policy-Based)

```python
# Attribute-Based Access Control with policy evaluation
from dataclasses import dataclass
from datetime import datetime, time
from typing import Any

@dataclass
class AccessRequest:
    subject: dict    # User attributes (role, department, clearance)
    resource: dict   # Resource attributes (type, classification, owner)
    action: str      # Requested action (read, write, delete)
    environment: dict  # Context (time, IP, device_compliant)

class Policy:
    def __init__(self, name: str, effect: str, condition):
        self.name = name
        self.effect = effect  # "allow" or "deny"
        self.condition = condition  # Callable that evaluates attributes

    def evaluate(self, request: AccessRequest) -> str | None:
        if self.condition(request):
            return self.effect
        return None  # Policy does not apply

# Policy definitions
policies = [
    # Deny: No access outside business hours for non-admin
    Policy(
        name="business-hours-only",
        effect="deny",
        condition=lambda r: (
            r.subject.get("role") != "admin" and
            not (time(8, 0) <= datetime.now().time() <= time(18, 0))
        )
    ),

    # Deny: Confidential resources require clearance level 3+
    Policy(
        name="confidential-clearance",
        effect="deny",
        condition=lambda r: (
            r.resource.get("classification") == "confidential" and
            r.subject.get("clearance_level", 0) < 3
        )
    ),

    # Allow: Users can read resources in their own department
    Policy(
        name="department-read",
        effect="allow",
        condition=lambda r: (
            r.action == "read" and
            r.subject.get("department") == r.resource.get("department")
        )
    ),

    # Allow: Resource owners have full access
    Policy(
        name="owner-access",
        effect="allow",
        condition=lambda r: (
            r.subject.get("user_id") == r.resource.get("owner_id")
        )
    ),
]

def evaluate_access(request: AccessRequest) -> bool:
    """Evaluate all policies. Deny takes precedence over allow."""
    allow = False
    for policy in policies:
        result = policy.evaluate(request)
        if result == "deny":
            log_policy_denial(request, policy.name)
            return False
        if result == "allow":
            allow = True

    if allow:
        log_policy_allow(request)
    return allow
```

**Why this works**: ABAC evaluates attributes at decision time, allowing context-sensitive decisions. Deny policies take precedence (defense in depth). Policies can consider time of day, user department, resource classification, and other dynamic attributes that RBAC cannot express.

### Pattern 3: ReBAC Implementation (Zanzibar-Style)

```
# Google Zanzibar relationship model (used by SpiceDB, OpenFGA)

# Type definitions
definition user {}

definition organization {
    relation admin: user
    relation member: user
}

definition team {
    relation org: organization
    relation lead: user
    relation member: user

    permission manage = lead + org->admin
}

definition document {
    relation org: organization
    relation owner: user
    relation editor: user | team#member
    relation viewer: user | team#member | org#member

    permission write = owner + editor
    permission read = write + viewer
    permission delete = owner
    permission share = owner + org->admin
}

# Relationship tuples (the data)
# document:report-2024#owner@user:alice
# document:report-2024#org@organization:acme
# team:engineering#member@user:bob
# document:report-2024#editor@team:engineering#member
# organization:acme#member@user:charlie

# Check: Can bob edit document:report-2024?
# YES -- bob is a member of team:engineering, and
#         team:engineering#member is an editor of document:report-2024
```

**Why this works**: ReBAC models access based on relationships between objects, which naturally maps to how people think about permissions (I own this document, I shared it with my team, anyone in my org can view it). The Zanzibar model supports transitive permissions -- if a team can edit, all team members can edit. This scales to billions of relationships (Google Docs, Google Drive).

### Pattern 4: Segregation of Duties Matrix

```
# Define toxic combinations that must be prevented
SEGREGATION_MATRIX = {
    ("deploy_to_production", "approve_deployment"): "Cannot self-approve deployments",
    ("create_purchase_order", "approve_purchase_order"): "Cannot self-approve purchases",
    ("manage_users", "manage_audit_logs"): "Cannot manage users and audit logs",
    ("access_production_data", "modify_access_controls"): "Cannot modify own data access",
}

def check_segregation(user_permissions: set) -> list[str]:
    """Identify segregation of duties violations."""
    violations = []
    for (perm_a, perm_b), reason in SEGREGATION_MATRIX.items():
        if perm_a in user_permissions and perm_b in user_permissions:
            violations.append(
                f"Violation: User has both '{perm_a}' and '{perm_b}'. {reason}"
            )
    return violations
```

**Why this works**: Segregation of duties is a control that prevents fraud and error by requiring multiple people to complete critical actions. This matrix makes the toxic combinations explicit and checkable. Run this check during role assignment, access reviews, and compliance audits.

## Anti-Patterns

### Anti-Pattern 1: Role Explosion

Creating a new role for every unique combination of permissions. An organization with 50 base permissions could theoretically have 2^50 roles. Signs of role explosion:
- More roles than users
- Roles like `analyst-marketing-readonly-except-reports`
- Users with roles they cannot describe

**Fix**: Use ABAC to handle dynamic conditions. Keep RBAC roles coarse-grained (5-10 roles per application) and use attributes for fine-grained decisions.

### Anti-Pattern 2: Hard-Coded Authorization

```python
# BAD -- authorization logic scattered in application code
if user.email == "admin@company.com":
    allow_delete()
elif user.department == "engineering":
    allow_read()
```

This makes authorization inconsistent, unauditable, and impossible to change without code deployment.

**Fix**: Centralize authorization in a policy engine or middleware. Define roles and permissions in configuration, not code.

### Anti-Pattern 3: Ambient Authority

Granting permissions based on the caller's identity alone, without considering what resource they are accessing. Classic example: any authenticated user can access any user's profile by guessing the user ID in the URL.

**Fix**: Always check that the caller has permission to access the specific resource, not just the resource type. This is the IDOR (Insecure Direct Object Reference) prevention principle.

### Anti-Pattern 4: No Access Review Process

Permissions accumulate over time. Users change teams, take on temporary responsibilities, and leave. Without periodic reviews, the actual permission state diverges from the intended state.

**Fix**: Implement quarterly access reviews. Automate deprovisioning on termination. Use JIT access for elevated privileges so they automatically expire.

## References

- [NIST RBAC Model](https://csrc.nist.gov/projects/role-based-access-control)
- [XACML / ABAC](https://www.oasis-open.org/committees/xacml/)
- [Google Zanzibar Paper](https://research.google/pubs/pub48190/)
- [SpiceDB (Open Source Zanzibar)](https://authzed.com/spicedb)
- [OpenFGA (Open Source Zanzibar by Auth0)](https://openfga.dev/)
- [Cedar (AWS Authorization Policy Language)](https://www.cedarpolicy.com/)
- [Casbin (Open Source Authorization Library)](https://casbin.org/)
- [OWASP Access Control Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Access_Control_Cheat_Sheet.html)

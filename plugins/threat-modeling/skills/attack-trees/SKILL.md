# Attack Trees

> Attack tree construction methodology, notation, common patterns, and analysis techniques for decomposing complex threats into specific, analyzable attack paths.

## Knowledge Base

### What Are Attack Trees?

Attack trees are hierarchical diagrams that model the different ways an attacker can achieve a specific objective. The root node is the attacker's goal, intermediate nodes are subgoals, and leaf nodes are specific, atomic actions the attacker takes. Nodes are connected by AND gates (all children must succeed) or OR gates (any child is sufficient).

Attack trees were formalized by Bruce Schneier (1999) and remain one of the most practical tools for understanding and communicating about security threats.

### Tree Notation

**Text-based notation** (used in this plugin):
```
[ROOT GOAL] (OR)                          # Attacker wants to achieve this
├── [Subgoal A] (AND)                     # Approach A requires all steps
│   ├── [Action A.1] {leaf}               # Specific atomic action
│   └── [Action A.2] {leaf}               # Both A.1 AND A.2 needed
├── [Subgoal B] (OR)                      # Approach B has alternatives
│   ├── [Action B.1] {leaf}               # B.1 alone is sufficient
│   └── [Action B.2] {leaf}               # OR B.2 alone is sufficient
└── [Subgoal C] {leaf}                    # Sometimes a single action is enough
```

**Node annotations**:
```
[Action] {leaf}
  Cost: $ / $$ / $$$ / $$$$ / $$$$$      # Resources attacker needs to spend
  Skill: Novice / Intermediate / Expert    # Required attacker skill level
  Time: Minutes / Hours / Days / Weeks     # Time to execute
  Detect: Low / Medium / High              # Probability of detection
  Control: [Name] or NONE                  # Existing security control
  ATT&CK: T[xxxx]                         # MITRE ATT&CK technique ID
```

### Common Attack Tree Templates

#### Account Takeover

```
[Take Over User Account] (OR)
├── [Steal Credentials] (OR)
│   ├── [Phishing] (AND)
│   │   ├── [Send convincing phishing email] {leaf}
│   │   │   Cost: $, Skill: Novice, Time: Hours, Detect: Medium
│   │   └── [Victim enters credentials on fake page] {leaf}
│   │       Cost: $, Skill: N/A (victim action), Detect: Low
│   ├── [Credential Stuffing] (AND)
│   │   ├── [Obtain leaked credential database] {leaf}
│   │   │   Cost: $, Skill: Novice, Time: Minutes, Detect: Low
│   │   └── [Automate login attempts] {leaf}
│   │       Cost: $, Skill: Novice, Time: Hours, Detect: High
│   │       Control: Rate limiting, account lockout
│   ├── [Keylogger/Malware] (AND)
│   │   ├── [Deliver malware to victim device] {leaf}
│   │   │   Cost: $$, Skill: Intermediate, Time: Days, Detect: Medium
│   │   └── [Capture credentials from keystrokes] {leaf}
│   │       Cost: $, Skill: Intermediate, Time: Hours, Detect: Low
│   └── [Network Sniffing] (AND)
│       ├── [Position on victim's network] {leaf}
│       │   Cost: $$, Skill: Intermediate, Time: Hours, Detect: Low
│       └── [Intercept cleartext credentials] {leaf}
│           Cost: $, Skill: Intermediate, Time: Minutes, Detect: Low
│           Control: TLS encryption
├── [Exploit Authentication Weakness] (OR)
│   ├── [Brute Force Weak Password] {leaf}
│   │   Cost: $, Skill: Novice, Time: Hours, Detect: High
│   │   Control: Password policy, rate limiting
│   ├── [Exploit Password Reset Flow] (AND)
│   │   ├── [Discover user's email address] {leaf}
│   │   └── [Exploit weak reset token generation] {leaf}
│   │       Control: Cryptographic random tokens
│   └── [Session Hijacking via XSS] (AND)
│       ├── [Find XSS vulnerability] {leaf}
│       │   Cost: $$, Skill: Intermediate, Time: Hours, Detect: Low
│       └── [Steal session cookie] {leaf}
│           Cost: $, Skill: Intermediate, Time: Minutes, Detect: Low
│           Control: HttpOnly cookies, CSP
├── [Bypass MFA] (OR)
│   ├── [SIM Swap (SMS-based MFA)] {leaf}
│   │   Cost: $$, Skill: Intermediate, Time: Days, Detect: Medium
│   ├── [Real-time Phishing Proxy (evilginx2)] {leaf}
│   │   Cost: $$, Skill: Expert, Time: Hours, Detect: Medium
│   └── [Social Engineer Help Desk] {leaf}
│       Cost: $, Skill: Intermediate, Time: Hours, Detect: Medium
│       Control: Identity verification procedures
└── [Insider Access] (OR)
    ├── [Malicious Administrator] {leaf}
    │   Cost: $, Skill: Novice, Time: Minutes, Detect: Medium
    │   Control: Audit logging, least privilege, separation of duties
    └── [Bribe/Coerce Employee] {leaf}
        Cost: $$$, Skill: Novice, Time: Days, Detect: Low
```

#### Data Exfiltration

```
[Exfiltrate Customer Data] (OR)
├── [Direct Database Access] (AND)
│   ├── [Obtain Database Credentials] (OR)
│   │   ├── [Find credentials in source code] {leaf}
│   │   │   Control: Secret scanning, secrets management
│   │   ├── [Extract from application memory] {leaf}
│   │   ├── [Find in configuration files] {leaf}
│   │   └── [Compromise admin workstation] {leaf}
│   └── [Connect to Database] (OR)
│       ├── [Database exposed to internet] {leaf}
│       │   Control: Network segmentation, firewall rules
│       └── [Pivot from compromised application server] {leaf}
│           Control: Network microsegmentation
├── [Application-Layer Extraction] (OR)
│   ├── [SQL Injection] (AND)
│   │   ├── [Find injectable parameter] {leaf}
│   │   └── [Extract data via UNION/blind/out-of-band] {leaf}
│   │       Control: Parameterized queries, WAF
│   ├── [BOLA/IDOR Enumeration] (AND)
│   │   ├── [Find endpoint without authorization check] {leaf}
│   │   └── [Enumerate all resource IDs] {leaf}
│   │       Control: Object-level authorization, rate limiting
│   └── [API Data Scraping] (AND)
│       ├── [Obtain valid API credentials] {leaf}
│       └── [Paginate through all records] {leaf}
│           Control: Rate limiting, anomaly detection
├── [Backup/Export Theft] (OR)
│   ├── [Access unencrypted backups] {leaf}
│   │   Control: Backup encryption, access control
│   ├── [Exploit data export feature] {leaf}
│   │   Control: Export rate limiting, audit logging
│   └── [Access log files containing data] {leaf}
│       Control: Data masking in logs
└── [Supply Chain] (OR)
    ├── [Compromise third-party integration with data access] {leaf}
    └── [Malicious dependency that exfiltrates data] {leaf}
        Control: Dependency auditing, network egress controls
```

### Path Analysis Methodology

#### Calculating Path Cost

For AND gates, the path cost is the sum of all child costs. For OR gates, the path cost is the minimum child cost (attacker picks cheapest).

```
Path cost (AND) = sum(child costs)
Path cost (OR)  = min(child costs)
```

Similarly for skill level (AND = max skill needed, OR = min skill needed) and detection probability (AND = max detection across steps, OR = min detection for chosen path).

#### Identifying the Minimum Cost Path

1. Start at each leaf node with its annotated cost/skill/time/detection
2. Propagate up through the tree using AND/OR aggregation rules
3. The root node's aggregated values represent the minimum effort an attacker needs
4. Trace back down the tree following the minimizing choices to identify the specific path

#### Defense Gap Analysis

1. Mark each leaf node with its existing control (or NONE)
2. A path is "open" if all leaf nodes in an AND chain have no controls, or any leaf in an OR chain has no control
3. Prioritize controls that block the most open paths (maximum coverage per control)
4. Identify single points of failure -- controls that, if bypassed, open multiple paths

### Advanced Techniques

#### Multi-Attacker Modeling

Model different attacker profiles with different capabilities:
- **Script kiddie**: Low skill, low cost, uses automated tools
- **Organized crime**: Medium skill, medium cost, financially motivated
- **Nation-state**: High skill, high cost, persistent, targeted
- **Insider**: Existing access, low technical barriers, high domain knowledge

Each profile makes different paths viable. The same tree analyzed for a script kiddie vs a nation-state actor produces different risk profiles.

#### Dynamic Attack Trees

Some attack paths are only available after other paths succeed:
- Reconnaissance reveals new attack paths
- Initial compromise enables lateral movement
- Privilege escalation opens new targets

Model these as prerequisite annotations: "This path requires successful completion of Path X."

## Patterns

### Effective Tree Construction

1. **Define the goal precisely**: "Steal customer PII from the production database" is better than "Hack the system"
2. **Decompose breadth-first**: First identify all high-level approaches, then detail each one. Don't go deep on one branch before considering all branches.
3. **Include non-obvious paths**: Physical access, social engineering, legal compulsion, supply chain. If you only model technical attacks, you model only half the threat.
4. **Annotate consistently**: Use the same scale for all nodes. Relative comparisons matter more than absolute numbers.
5. **Validate with the team**: Architects know about paths you might miss. Developers know about implementation details that make some paths harder.

### Using Trees for Decision-Making

- **Control prioritization**: Which new control blocks the most open paths?
- **Risk acceptance**: Which paths are we comfortable leaving open, and why?
- **Investment justification**: "Implementing control X blocks 4 open paths to our most critical asset, reducing risk from Y to Z"
- **Incident response**: When an attack is detected, which tree path are they on, and what are the next likely steps?

## Anti-Patterns

- **Trees that are too abstract**: "Exploit vulnerability" is not a useful leaf node. Be specific: "Exploit CVE-2024-XXXX in Apache Struts via crafted Content-Type header."
- **Trees without annotations**: A tree without cost/skill/detection is just a brainstorming artifact. The annotations are what make it analytically useful.
- **Ignoring AND gates**: Most real attacks require multiple steps. Modeling everything as OR gates overestimates the attacker's ease.
- **Not mapping existing controls**: Without control mapping, you can't tell which paths are open vs blocked.
- **Building once, never updating**: Attack trees should evolve with the system. New features, new integrations, and new vulnerabilities change the tree.

## References

- [Bruce Schneier - Attack Trees (1999)](https://www.schneier.com/academic/archives/1999/12/attack_trees.html)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [CAPEC - Common Attack Pattern Enumeration and Classification](https://capec.mitre.org/)
- [Amenaza - SecurITree (commercial attack tree modeling)](https://www.amenaza.com/)
- [Open FAIR Risk Analysis](https://www.opengroup.org/certifications/openfair)

# /image-scan

> Scan container images for vulnerabilities and misconfigurations.

## Trigger

Use when you need to:
- Check a container image for known CVEs before deployment
- Generate an SBOM (Software Bill of Materials) for a container image
- Evaluate the security posture of a base image before adoption
- Audit images in a registry for vulnerabilities
- Meet compliance requirements for container image scanning

## Input

One of:
- **Image reference**: `image:tag` or `image@sha256:digest`
- **Image tarball**: `docker save` output (`.tar`)
- **Registry path**: Full registry URL for remote scanning
- **Scan output**: Existing Trivy, Grype, or Snyk report to analyze

## Process

### Phase 1: Image Analysis

1. **Image identification**
   - Pull or reference the image
   - Identify the base image (from layer history or manifest)
   - Determine the OS and version
   - Note the image creation date and layer count

2. **SBOM generation**
   ```bash
   # Generate SBOM with Syft
   syft IMAGE:TAG -o cyclonedx-json > sbom.json

   # Or with Trivy
   trivy image --format cyclonedx IMAGE:TAG > sbom.json
   ```

### Phase 2: Vulnerability Scanning

3. **OS package vulnerabilities**
   ```bash
   # Trivy (comprehensive, fast, offline database)
   trivy image --severity CRITICAL,HIGH IMAGE:TAG

   # Grype (pairs with Syft SBOM)
   grype IMAGE:TAG --only-fixed

   # Docker Scout
   docker scout cves IMAGE:TAG
   ```

4. **Application dependency vulnerabilities**
   ```bash
   # Trivy scans language-specific deps automatically
   trivy image --vuln-type library IMAGE:TAG

   # Grype also scans application deps
   grype sbom:sbom.json
   ```

5. **Secret scanning**
   ```bash
   # Trivy secret scanning
   trivy image --scanners secret IMAGE:TAG
   ```

### Phase 3: Misconfiguration Check

6. **Image configuration**
   ```bash
   # Dockle -- CIS Benchmark for images
   dockle IMAGE:TAG

   # Trivy misconfiguration scanning
   trivy image --scanners misconfig IMAGE:TAG
   ```

### Phase 4: Prioritization

7. **Cross-reference with threat intelligence**
   - Check critical CVEs against CISA KEV catalog
   - Check EPSS scores for exploitation probability
   - Identify CVEs with known public exploits
   - Distinguish fixable vs unfixable vulnerabilities

## Output

```
## Container Image Scan Results

### Image
- Reference: [image:tag@sha256:digest]
- Base: [detected base image]
- OS: [os/version]
- Size: [size]
- Scanned: [date]
- Scanner: [tool and version]

### Vulnerability Summary
| Severity | Total | Fixable | Unfixable |
|----------|-------|---------|-----------|
| Critical |       |         |           |
| High     |       |         |           |
| Medium   |       |         |           |
| Low      |       |         |           |

### Actively Exploited (CISA KEV)
[List or "None found"]

### Top Priority Vulnerabilities
[Table of critical/high with fix versions]

### Remediation Steps
1. [Update base image to resolve X CVEs]
2. [Update specific packages]
3. [Rebuild with latest patches]

### SBOM
- Total packages: [count]
- OS packages: [count]
- Application dependencies: [count by ecosystem]

### Misconfigurations
[Dockle/Trivy findings]

### Commands to Reproduce
[Exact scanner commands used]
```

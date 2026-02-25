# SBOM Generation

> Reference knowledge for generating Software Bills of Materials in SPDX and CycloneDX formats, including tooling, automation patterns, and compliance context.

## Knowledge Base

### What is an SBOM

A Software Bill of Materials (SBOM) is a formal, machine-readable inventory of all components, libraries, and modules that make up a piece of software. It is the software equivalent of an ingredients list. SBOMs enable vulnerability management at scale -- you cannot protect what you cannot inventory.

### Standards

**SPDX 2.3 (ISO/IEC 5962:2021)**

The System Package Data Exchange format, maintained by the Linux Foundation. SPDX was designed primarily for license compliance but has grown to include security use cases. Key characteristics:

- Document-centric model: an SPDX document describes one or more packages.
- Relationship types: CONTAINS, DEPENDS_ON, BUILD_TOOL_OF, DESCRIBED_BY, and others.
- License expressions use SPDX license identifiers (MIT, Apache-2.0, GPL-3.0-only, etc.).
- Output formats: JSON, YAML, XML, RDF, tag-value.
- Required fields: SPDXVersion, DataLicense (CC0-1.0), SPDXID, DocumentName, DocumentNamespace, Creator.

**CycloneDX 1.5 (OWASP)**

Designed specifically for security use cases. CycloneDX is lighter and more security-focused than SPDX. Key characteristics:

- Component-centric model: flat or nested list of components with optional dependency graph.
- First-class support for vulnerabilities (VEX -- Vulnerability Exploitability eXchange), services, and formulation (build process).
- Component types: library, framework, application, container, device, firmware, file, operating-system.
- Output formats: JSON, XML, Protocol Buffers.
- Required fields: bomFormat, specVersion, components (array).

### Minimum Viable SBOM (per NTIA)

The National Telecommunications and Information Administration defines the minimum elements:

| Field | Description |
|-------|-------------|
| Supplier name | Who supplied the component |
| Component name | Name of the component |
| Version | Version string |
| Unique identifier | CPE, PURL, or SWID tag |
| Dependency relationship | What depends on what |
| Author of SBOM | Who generated this SBOM |
| Timestamp | When it was generated |

### Package URL (PURL)

The universal identifier for software packages across ecosystems:

```
pkg:npm/%40angular/core@16.2.0
pkg:pypi/requests@2.31.0
pkg:cargo/serde@1.0.188
pkg:golang/github.com/gin-gonic/gin@v1.9.1
pkg:maven/org.apache.logging.log4j/log4j-core@2.20.0
pkg:nuget/Newtonsoft.Json@13.0.3
```

## Patterns

### Pattern 1: SBOM Generation with Syft

Syft (by Anchore) is the most versatile open-source SBOM generator. It supports all major ecosystems from a single tool.

```bash
# Generate CycloneDX JSON from a project directory
syft dir:. -o cyclonedx-json > sbom.cdx.json

# Generate SPDX JSON from a container image
syft registry:nginx:1.25 -o spdx-json > nginx-sbom.spdx.json

# Generate from a lockfile specifically
syft file:package-lock.json -o cyclonedx-json > sbom.cdx.json

# Include file-level hashes for integrity verification
syft dir:. -o cyclonedx-json --file-digests > sbom-with-hashes.cdx.json
```

### Pattern 2: CI/CD SBOM Generation (GitHub Actions)

```yaml
name: SBOM Generation
on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          format: cyclonedx-json
          output-file: sbom.cdx.json

      - name: Scan SBOM for vulnerabilities
        uses: anchore/scan-action@v4
        with:
          sbom: sbom.cdx.json
          fail-build: true
          severity-cutoff: high

      - name: Attach SBOM to release
        if: github.event_name == 'release'
        uses: softprops/action-gh-release@v2
        with:
          files: sbom.cdx.json
```

### Pattern 3: SBOM Enrichment with VEX

VEX (Vulnerability Exploitability eXchange) annotates an SBOM with vulnerability status -- whether a known CVE actually affects the product in its specific configuration.

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "vulnerabilities": [
    {
      "id": "CVE-2023-44487",
      "source": { "name": "NVD" },
      "analysis": {
        "state": "not_affected",
        "justification": "code_not_reachable",
        "detail": "The HTTP/2 rapid reset vulnerability does not affect this application because it uses HTTP/1.1 exclusively."
      },
      "affects": [
        {
          "ref": "pkg:golang/golang.org/x/net@v0.15.0"
        }
      ]
    }
  ]
}
```

### Pattern 4: SBOM Diffing Between Versions

Track what changed in your dependency tree between releases:

```bash
# Generate SBOMs for two versions
syft dir:./v1.2.0 -o cyclonedx-json > sbom-v1.2.0.cdx.json
syft dir:./v1.3.0 -o cyclonedx-json > sbom-v1.3.0.cdx.json

# Diff using cyclonedx-cli
cyclonedx diff sbom-v1.2.0.cdx.json sbom-v1.3.0.cdx.json
```

## Anti-Patterns

- **SBOM generation only at release time**: Generate SBOMs on every build. Vulnerabilities discovered between releases need to be traceable to what is currently deployed.
- **Ignoring transitive dependencies**: An SBOM that lists only direct dependencies is incomplete. The Log4Shell vulnerability (CVE-2021-44228) was a transitive dependency for most affected projects.
- **Treating SBOM as a checkbox**: Generating an SBOM without feeding it into vulnerability management is compliance theater. The SBOM must be continuously monitored against new CVE disclosures.
- **Static SBOMs without VEX**: A raw SBOM will show every CVE in every dependency. Without VEX analysis to determine actual exploitability, teams drown in false positives and stop paying attention.
- **Single-format lock-in**: Generate both SPDX and CycloneDX if your consumers require different formats. Tooling exists to convert between them, but native generation is more accurate.

## References

- NTIA SBOM Minimum Elements: https://www.ntia.doc.gov/report/2021/minimum-elements-software-bill-materials-sbom
- SPDX 2.3 Specification: https://spdx.github.io/spdx-spec/v2.3/
- CycloneDX 1.5 Specification: https://cyclonedx.org/docs/1.5/
- Syft documentation: https://github.com/anchore/syft
- CISA SBOM resources: https://www.cisa.gov/sbom
- Package URL (PURL) specification: https://github.com/package-url/purl-spec
- VEX specification: https://www.cisa.gov/sites/default/files/2023-04/minimum-requirements-for-vex-508c.pdf

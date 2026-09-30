# Pantry queue: LibreSecOps-Claude-Code

First stock, 2026-09-30, from the [competitor map](2026-09-30-competitor-map.md), [X mine](2026-09-30-x-mine.md) and [people mine](2026-09-30-people-mine.md) of the same date, plus the repo audit notes below. Every atom is buildable by an outside contributor and checkable on this repo. Atoms that touch testing keep the pack's framing: authorized engagements, agreed scope, isolated labs.

## Atoms

| # | Title | Done predicate | Surface | Evidence | Confidence |
|---|-------|----------------|---------|----------|------------|
| 1 | Map web-application-security to the OWASP Top 10:2025 (`owasp-top-10-2025`) | `owasp-scan.md`, the `owasp-top-10` skill and `web-security-auditor.md` in `plugins/web-application-security/` cover A01:2025 to A10:2025 by their 2025 names (including A03:2025 Software Supply Chain Failures and A10:2025 Mishandling of Exceptional Conditions), keep a 2021-to-2025 mapping table, and `claude plugin validate plugins/web-application-security` passes. | repo | Map matrix: Maps the OWASP Top 10:2025 (Us N; https://owasp.org/Top10/2025/); audit A1 | high |
| 2 | Add a slopsquatting check to supply-chain-audit (`slopsquatting-check`) | `plugins/supply-chain-security/commands/supply-chain-audit.md` has a package-existence step that looks up each direct dependency on its registry (for example `npm view <name> name` and `https://pypi.org/pypi/<name>/json`) and flags names the registry does not know as possible AI-hallucinated packages; the `package-integrity-analyst` description names this case; `claude plugin validate plugins/supply-chain-security` passes. | repo | X complaint: AI-suggested deps, hallucinated package names; map matrix: Checks that AI-suggested packages exist (Us N) | high |
| 3 | Add an LLM application security plugin (`llm-application-security`) | `plugins/llm-application-security/` has `.claude-plugin/plugin.json`, an agent, a command and a skill with routing descriptions and a `.claude-plugin/marketplace.json` entry; `claude plugin validate plugins/llm-application-security` passes; `claude plugin details llm-application-security@libre-secops` lists its agent and skill; the skill maps LLM01:2025 to LLM10:2025 to review steps, and any prompt-injection testing is framed for systems the user owns or is authorized to test. | repo | Map matrix: LLM and AI agent application security (Us N; Trail of Bits P; https://genai.owasp.org/llm-top-10/) | medium |
| 4 | Add a branch diff mode to secure-review (`secure-review-diff`) | `plugins/secure-coding-practices/commands/secure-review.md` names a diff scope in its `argument-hint`, reviews `git diff --merge-base origin/HEAD` (or a given base), reports only findings on changed lines with file and line, names the pack's specialist agent for each finding category, and `claude plugin validate plugins/secure-coding-practices` passes. | repo | Map matrix: Reviews the current diff or pull request (Us P; Trail of Bits, Anthropic, Gemini Y); audit A3 | medium |
| 5 | Add a SARIF triage skill to vulnerability-scanning (`sarif-triage`) | `claude plugin validate plugins/vulnerability-scanning` passes, `claude plugin details vulnerability-scanning@libre-secops` lists skill `sarif-triage`, and its SKILL.md has a `jq` command that lists `ruleId`, `level` and location for each result of a SARIF 2.1.0 file plus a false-positive checklist that feeds `/vuln-triage`. | repo | Map matrix: Runs SAST tools and reads their SARIF output (Us P; Trail of Bits Y, Semgrep MCP Y) | medium |
| 6 | Add LGPD and DPDP coverage to privacy-engineering (`lgpd-dpdp`) | The privacy-engineering `privacy-review` command and one of its skills cover Brazil's LGPD and India's DPDP Act next to GDPR and CCPA, listing each law's legal bases and data subject rights with a link to the official text, and `claude plugin validate plugins/privacy-engineering` passes. | repo | Audit A2 (maintainer ask in README and CONTRIBUTING.md) | low |

## Audit notes (repo as on `main`, 2026-09-30)

- A1: `plugins/web-application-security/` names the OWASP Top 10 (2021) in its README, `plugin.json`, agent, command and skill; `owasp-scan.md` lists A01:2021 to A10:2021.
- A2: README.md (Contributing) and CONTRIBUTING.md ask for "LATAM LGPD, India DPDP"; no file under `plugins/` mentions LGPD or DPDP.
- A3: `secure-review` reviews "the given files or snippet"; no command in the pack takes the current branch diff as its scope.

## Explicitly not stocked (and why)

- An MCP server that runs scanners or exploits against targets, as HexStrike AI and PentestGPT do: not stocked. The pack plans and guides authorized work; execution stays with the human operator.
- A pull request review GitHub Action: not stocked. It needs an API key and model spend on every PR.
- Eval suites for `claude plugin eval`: not stocked this run. Running them spends model credits on the contributor's account.
- Codex and Cursor manifests: not stocked this run. Only competitor rows point there; no user has asked.

# Menu: LibreSecOps-Claude-Code

Queue: 2026-09-30-pantry-queue.md
Counts: open 6, in flight 0, shipped 0, parked 0, dropped 0, needs fixing 0

## Steer

- none

## Up next

**owasp-top-10-2025**: Map web-application-security to the OWASP Top 10:2025 (`owasp-top-10-2025`) (queue #1, high, repo, since 2026-09-30)

- Done when: `owasp-scan.md`, the `owasp-top-10` skill and `web-security-auditor.md` in `plugins/web-application-security/` cover A01:2025 to A10:2025 by their 2025 names (including A03:2025 Software Supply Chain Failures and A10:2025 Mishandling of Exceptional Conditions), keep a 2021-to-2025 mapping table, and `claude plugin validate plugins/web-application-security` passes.
- Verify on: repo
- Evidence: Map matrix: Maps the OWASP Top 10:2025 (Us N; https://owasp.org/Top10/2025/); audit A1
- Issue: none yet (promote after merge)
- Order: owasp-top-10-2025, slopsquatting-check, llm-application-security, sarif-triage, secure-review-diff, lgpd-dpdp
- Tie: owasp-top-10-2025 over slopsquatting-check, by key order (jev off)

## Atoms

| Key | Title | State | Confidence | Class | Since | Queue # | Issue | Because |
|-----|-------|-------|------------|-------|-------|---------|-------|---------|
| lgpd-dpdp | Add LGPD and DPDP coverage to privacy-engineering (`lgpd-dpdp`) | open | low | repo | 2026-09-30 | 6 | - | - |
| llm-application-security | Add an LLM application security plugin (`llm-application-security`) | open | medium | repo | 2026-09-30 | 3 | - | - |
| owasp-top-10-2025 | Map web-application-security to the OWASP Top 10:2025 (`owasp-top-10-2025`) | open | high | repo | 2026-09-30 | 1 | - | - |
| sarif-triage | Add a SARIF triage skill to vulnerability-scanning (`sarif-triage`) | open | medium | repo | 2026-09-30 | 5 | - | - |
| secure-review-diff | Add a branch diff mode to secure-review (`secure-review-diff`) | open | medium | repo | 2026-09-30 | 4 | - | - |
| slopsquatting-check | Add a slopsquatting check to supply-chain-audit (`slopsquatting-check`) | open | high | repo | 2026-09-30 | 2 | - | - |

## Retired

| Key | Title | State | Since | Issue | Because |
|-----|-------|-------|-------|-------|---------|
| none | | | | | |

## Notes

- none

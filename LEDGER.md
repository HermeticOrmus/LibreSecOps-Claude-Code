# Kintsugi ledger: LibreSecOps-Claude-Code

Kintsugi mends broken pottery with gold, so the repair is the part you see. Here it means every crack we found in LibreSecOps is written down with its evidence and the seal that closed it, so you can check the gold yourself.

A row is `hallmarked` when its seal shipped in a release that was verified by installing from GitHub into a clean config. Grades: `hairline` is copy or cosmetic, `fracture` is wrong behavior with a workaround, `break` means it did not work or broke a safety promise. IDs are never reused.

| ID | Crack | Evidence | Grade | Tracker | Seal | State |
|----|-------|----------|-------|---------|------|-------|
| K-01 | Nothing installed: the repo had no marketplace or plugin manifests, and the old `setup.sh` copied folders into `~/.claude/plugins`, which Claude Code does not load as plugins. | [PR #2][pr2], [CHANGELOG 1.0.0 L26][a26], [L9][a9] | break | filed #1 | `marketplace.json` plus a `plugin.json` per plugin; `setup.sh` installs through `claude plugin`; large | hallmarked |
| K-02 | 173 of the 174 agent, command, and skill files had no frontmatter, so Claude Code could not route to them. | [PR #2][pr2], [CHANGELOG 1.0.0 L10][a10] | break | filed #1 | A routing description on every file, written from its content; large | hallmarked |
| K-03 | The docs named commands such as `/threat-model`, which run as `/threat-modeling:threat-model` once installed as a plugin. | [PR #2][pr2], [CHANGELOG 1.0.0 L18][a18] | hairline | filed #1 | README, QUICK_START, and TROUBLESHOOTING use the namespaced names; small | hallmarked |
| K-04 | `threat-modeler` was pinned to `model: sonnet` instead of the session's model. | [PR #2][pr2], [CHANGELOG 1.0.0 L19][a19] | fracture | filed #1 | Every agent uses `model: inherit`; small | hallmarked |
| K-05 | The threat-modeling skill was a loose `skills/threat-modeling.md`, a layout Claude Code does not load as a skill. | [PR #2][pr2], [CHANGELOG 1.0.0 L20][a20] | break | filed #1 | Moved to `skills/threat-modeling/SKILL.md`, content unchanged; small | hallmarked |
| K-06 | The hook scripts were never registered, so they never ran; their wiring also depended on a `LIBRESECOPS_HOOKS_DIR` variable. | [PR #2][pr2], [CHANGELOG 1.0.0 L27][a27] | break | filed #1 | The `libre-secops-hooks` plugin wires them through `hooks/hooks.json` and `${CLAUDE_PLUGIN_ROOT}`; medium | hallmarked |
| K-07 | The hooks returned context as a top-level `additionalContext` array, which is not part of the Claude Code hook output format. | [PR #2][pr2], [CHANGELOG 1.0.0 L27][a27] | break | filed #1 | Results go through `hookSpecificOutput`; small | hallmarked |
| K-08 | Hook timeouts were written as 5000 and 2000 in a field Claude Code reads as seconds. | [PR #2][pr2], [CHANGELOG 1.0.0 L27][a27] | fracture | filed #1 | Timeouts in seconds; small | hallmarked |
| K-09 | The hook scripts wrote log files inside the hooks folder. | [PR #2][pr2], [CHANGELOG 1.0.0 L27][a27] | fracture | filed #1 | The scripts write nothing to disk; small | hallmarked |
| K-10 | The PreToolUse hook printed advice before an edit to a secret file instead of asking for confirmation. | [PR #2][pr2], [CHANGELOG 1.0.0 L21][a21] | fracture | filed #1 | PreToolUse returns `permissionDecision: "ask"` for `.env`, key, and credentials files; the checklists moved to PostToolUse; small | hallmarked |
| K-11 | The scanner's private key check never ran: its pattern starts with `-`, so grep read it as an option. | [PR #2][pr2], [CHANGELOG 1.0.0 L28][a28] | break | filed #1 | The pattern goes after `--`, so grep reads it as a pattern; small | hallmarked |
| K-12 | The scanner reported every `Math.random()` as a security finding. | [PR #2][pr2], [CHANGELOG 1.0.0 L28][a28] | fracture | filed #1 | Flagged only next to a security-sensitive name such as token, secret, key, nonce, or session; small | hallmarked |
| K-13 | The scanner reported any `.update(...).digest()` chain, SHA-256 included, as MD5. | [PR #2][pr2], [CHANGELOG 1.0.0 L28][a28] | fracture | filed #1 | The MD5 check matches MD5 calls only; small | hallmarked |
| K-14 | The scanner reported `TLSv1_2` as TLS 1.0. | [PR #2][pr2], [CHANGELOG 1.0.0 L28][a28] | fracture | filed #1 | The check matches TLS 1.0, TLS 1.1, and SSL only; small | hallmarked |
| K-15 | The scanner missed lowercase `aes-128-ecb`. | [PR #2][pr2], [CHANGELOG 1.0.0 L28][a28] | fracture | filed #1 | The ECB check is case-insensitive; small | hallmarked |
| K-16 | Python-only and PHP-only deserialization checks fired on files in other languages. | [PR #2][pr2], [CHANGELOG 1.0.0 L28][a28] | fracture | filed #1 | Each check runs only on files of its own language; small | hallmarked |
| K-17 | The README plugin tables listed a `serverless-patterns` plugin that is not in this pack and listed `social-engineering-defense` twice, so the counts did not match the manifests. | [PR #2][pr2], [CHANGELOG 1.0.0 L29][a29], [L22][a22] | hairline | filed #1 | The tables list exactly the 32 plugins with their agents; small | hallmarked |
| K-18 | README domain notes named frameworks the plugins do not cover: OSSTMM, BeyondCorp, Cloud Armor, API fuzzing, OWASP Mobile Top 10, DPI. | [PR #2][pr2], [CHANGELOG 1.0.0 L29][a29] | hairline | filed #1 | The notes name what the plugins do cover; small | hallmarked |
| K-19 | `./setup.sh --help` printed the first line of code after the usage text. | [PR #4][pr4], [CHANGELOG 1.0.1 L7][b7] | hairline | filed #3 | Usage prints the header comment and stops at the first line of code; small | hallmarked |
| K-20 | `./setup.sh --uninstall` reported a failure for every plugin that was never installed. | [PR #4][pr4], [CHANGELOG 1.0.1 L8][b8] | fracture | filed #3 | Uninstall removes only the plugins `claude plugin list` shows; small | hallmarked |
| K-21 | web-application-security audits against the OWASP Top 10 (2021); OWASP has published the Top 10:2025, which adds A03:2025 Software Supply Chain Failures and A10:2025 Mishandling of Exceptional Conditions. | `plugins/web-application-security/commands/owasp-scan.md:8` and `:39`; [pantry queue][queue] audit A1; [OWASP Top 10:2025][owasp] | fracture | Menu atom `owasp-top-10-2025` | Cover A01:2025 to A10:2025 by their 2025 names with a 2021-to-2025 mapping table; medium | open |
| K-22 | The `libre-secops-hooks` plugin has not run inside a live Grok Build session, so its runtime behavior there is unverified. | `grok plugin validate plugins/libre-secops-hooks` passes and lists hooks (grok 1.0.44). *Inferred*: Grok's hooks guide shows a camelCase stdin envelope (`toolName`, `toolInput`, Grok tool names); fed that envelope for a `.env` edit, `pre-tool-use.sh` prints nothing, while the Claude Code envelope gets `ask`. | hairline | new | Read both envelopes (`.tool_name // .toolName`, `.tool_input // .toolInput`) and Grok tool names, then record each hook's output in a live Grok session; small | open |

[pr2]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/pull/2
[pr4]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/pull/4
[a9]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L9
[a10]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L10
[a18]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L18
[a19]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L19
[a20]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L20
[a21]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L21
[a22]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L22
[a26]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L26
[a27]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L27
[a28]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L28
[a29]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/54ec5b707429697aa0899fd33867e78a7b5e7435/CHANGELOG.md?plain=1#L29
[b7]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/a874d37f7d9b5ea6c27f4fc5185dd2dc4fdc83f7/CHANGELOG.md?plain=1#L7
[b8]: https://github.com/HermeticOrmus/LibreSecOps-Claude-Code/blob/a874d37f7d9b5ea6c27f4fc5185dd2dc4fdc83f7/CHANGELOG.md?plain=1#L8
[queue]: pantry/2026-09-30-pantry-queue.md
[owasp]: https://owasp.org/Top10/2025/

<p align="center"><img src="https://brand.ormus.solutions/assets/marks/kintsugi-mark.svg" alt="Kintsugi mark" width="48" /></p>

# Install in Grok Build

A user installs LibreSecOps-Claude-Code plugins with the Grok Build CLI, which reads the same plugin folders as Claude Code. Each installed plugin shows as installed in `grok plugin list`.

## Sub-features

- `grok-install-one` installs one plugin with `--trust`.
- `grok-install-all` installs every plugin the Grok manifest lists.
- `grok-list` shows each installed plugin with status `installed`.
- `grok-manifest-sync` keeps `.grok-plugin/marketplace.json` matching the Claude manifest, where the repo has one.

## How to get to it (user POV)

- From a terminal: `grok plugin marketplace add HermeticOrmus/LibreSecOps-Claude-Code`, then `grok plugin install threat-modeling@LibreSecOps-Claude-Code --trust`.
- From a clone: `grok plugin marketplace add <checkout>`, then `grok plugin install threat-modeling@<checkout folder name> --trust`.

## Driving it with control-libre-secops

Preconditions:

- `.grok/skills/verify-libre-secops/bin/control-libre-secops doctor` reports `worth_driving: true`, including `grok_manifest_in_sync: true`.

- **Add the marketplace and install one plugin.** Run `.grok/skills/verify-libre-secops/bin/control-libre-secops install --grok --only threat-modeling`. `evidence/grok-marketplace-add.log` and `evidence/grok-install-threat-modeling.log` end in `exit 0`.
- **Confirm it is installed.** `result.json` has `grok.installed` equal to `grok.wanted` and an empty `grok.missing`. `evidence/grok-list.json` lists the plugin with `"status": "installed"`.
- **Install the whole pack.** Run `.grok/skills/verify-libre-secops/bin/control-libre-secops run`. `result.json` has `grok.missing` empty and `ok: true`.
- **Proof.** Keep `evidence/grok-list.json` and `evidence/result.json` from the run.

## Gotchas

- Grok names a marketplace after the folder it was added from, not after `marketplace.json`. A clone in a folder with another name installs as `<plugin>@<that folder>`; the helper reads the name from the folder for you.
- `--trust` is required for a non-interactive install. Without it Grok stops to ask.
- After changing `.claude-plugin/marketplace.json`, run `python3 scripts/sync-grok-manifest.py` and commit what it writes, or `doctor` and `scripts/check.sh` fail on the sync check.

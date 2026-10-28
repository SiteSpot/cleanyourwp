# Security

## Reporting

If you find a way for these scripts or the prompt to change a site without approval, leak a secret, or leave a site in a worse state than they found it, report it privately through the repository's Security tab rather than a public issue.

## What this project does and doesn't do

- The scripts use WP-CLI, the WordPress REST API and standard Unix tools. They don't exploit anything, and they don't need root.
- The audit runs read-only commands, but WP-CLI executes installed WordPress code and HTTP requests can trigger site jobs or cache writes. Use staging when zero side effects are required. `backup.sh` and `log.sh` are the only scripts, and both write and announce it.
- Credentials are shown as the first four characters at most. Keep audit reports private.
- Backups are rejected inside the WordPress root. The scripts cannot detect other document roots, aliases or public symlinks; verify that the chosen location is not web-accessible. Backup directories and temporary credential files are private; credentials are removed on normal exit or handled termination.
- Use only trusted backups. Co-located SHA256 checksums detect corruption, not malicious replacement. Full restores are a manual procedure (`docs/restore.md`) that starts with a fresh verified backup and runs with traffic and background writers paused.
- The default change log under `wp-content` may be served publicly. Deny HTTP access to it and never include secrets or private user data in entries.
- The prompt instructs the agent to treat anything it reads on the site (files, options, readmes, logs) as data, not instructions. Agents can still be tricked; keep your approvals literal.

## Scope

In scope: the scripts in `tools/`, the snippets in `snippets/`, and the safety rails in `PROMPT.md` and `AGENTS.md`.

Out of scope: vulnerabilities in WordPress, plugins, hosts or the coding assistant itself. Report those upstream.

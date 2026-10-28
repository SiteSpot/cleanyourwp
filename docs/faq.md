# Questions people ask

**Is this safe? Can it break my site?**

Phases 0 to 6 only read. Phase 7 needs a numbered `GO` from you for each item, a full backup it has test-restored, and a targeted backup per change. Every change has a written rollback before it starts. The remaining risk is approving something you didn't understand, which is why the plan explains risk, verification and rollback per item.

**Which assistants work?**

Any that can run shell commands and read files in a folder: Claude Code, Codex, Gemini CLI and similar. The prompt is plain text. Assistants without a shell can run the wp-admin-paste mode but not the scripts.

**Do I need to clone the repo, or can I just paste the prompt?**

Paste alone works for the audit, but then the assistant improvises its own backup. Cloning gives it `tools/backup.sh`, which test-restores every backup, and `tools/log.sh` for the change log. Clone.

**It says my DB user can't create databases. Is the backup bad?**

The dump was written, but nobody has proved it restores. The script says the test restore was NOT RUN and exits 2. Stop site changes. Use a properly provisioned scratch database or verify recovery on isolated staging before proceeding. Do not broadly grant production database privileges just to silence the check.

**Will it delete my plugins?**

Not without approval, and not before deactivating, verifying, and exporting any data the plugin stores. Premium licences are deactivated first.

**What does "go static" mean, and will it work for me?**

See [static.md](static.md). Short version: brochure sites and blogs usually can; stores, memberships and bookings usually can't. Phase 3 checks your pages rather than guessing.

**Should I install the MCP Adapter?**

Only if you want AI agents to work with the site, and then deliberately. See [mcp.md](mcp.md).

**Can I run this on a client's site?**

Yes, with their approval of the plan, not only yours. The change log and the final report are written to be handed over.

**Can I run it on ten sites at once?**

One at a time. The prompt forbids batching approvals across sites, and the crawl is deliberately slow.

**What about multisite?**

The assistant stops and asks. Multisite hasn't been tested end to end with these scripts; `wp` commands need `--url` per site and backups cover the whole network.

**Where are the backups?**

Outside the WordPress root, in `<parent of WordPress root>/cleanyourwp-backups/<timestamp>.<random>/` by default, mode 700. Set `BACKUP_ROOT` to put them elsewhere. Check host document roots and aliases: this is not proof of HTTP inaccessibility. Move a copy off-server once done.

**How do I undo everything?**

Usually you don't need to: per-change rollbacks are in `wp-content/refresh-log.md`. For a full restore, follow [restore.md](restore.md): check the backup, back up the current state, swap the files, import the database.

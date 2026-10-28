# Host notes

What each host allows the assistant to do. Add a row for yours; date it. Columns: SSH, WP-CLI, PHP version switching, backups, staging, what bit you.

| Host | SSH | WP-CLI | PHP switch | Backups | Staging | Notes | Date |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Bare VPS (Ubuntu, nginx + PHP-FPM) | Yes | Install it | Install another PHP-FPM, switch the pool | Yours to set up | Yours to set up | Full control, full responsibility. `backup.sh` test restore works if the DB user can `CREATE DATABASE`. | 2026-10 |
| GridPane | Yes (site user or root) | Yes | Per site, from the panel | Panel-scheduled, local and remote | One click | Pool settings are per site; carry over `opcache` and memory values after a PHP switch. | 2026-10 |
| RunCloud | Yes | Yes | Per web app, from the panel | Panel add-on | Clone app | Several PHP versions installed side by side; the audit's "PHP versions installed" row lists them all. | 2026-10 |
| cPanel (typical shared) | Often | Sometimes | MultiPHP Manager | JetBackup or similar | Usually not | WP-CLI may be absent or an old version; check `wp --version`. DB user usually can't create databases, so expect `backup.sh` to exit 2 (test restore not run); verify on staging instead. | 2026-10 |
| Managed WordPress host, SSH enabled | Yes | Yes, often a wrapper | From the dashboard only | Host-managed, daily | Usually | Some block `wp db export`; use the host's backup for the full copy and `backup.sh` for the manifest. Object cache often host-provided; don't add a second. | 2026-10 |
| Managed WordPress host, no SSH | No | No | From the dashboard only | Host-managed | Usually | Reduced mode: REST or wp-admin paste. Files, PHP settings and database rows read "not checkable from here". | 2026-10 |

Rows above are generic patterns. Replace or add specific hosts you've tested.

# Restoring a backup

Most changes don't need this. Every Phase 7 item has its own rollback in `wp-content/refresh-log.md`, usually a plugin re-activation or a single-table import. Use those first.

A full restore is rare, high-stakes and different on every host, so there's no script for it. Do it by hand, or have the assistant do it one step at a time with a `GO` before step 4 and step 5. Try it on staging first if you can.

The examples assume the site is at `/var/www/example.com/htdocs` and the backup is the folder `backup.sh` printed, `$B`.

## 1. Check the backup

```bash
cd "$B" && sha256sum -c SHA256SUMS
grep -E 'site_path|verified' manifest.txt
```

Both files must say `OK`. `site_path` must be this site, and `verified` should be `yes`.

## 2. Stop writes

Put the site in maintenance mode or block traffic at the host, and pause real cron jobs. Anything that writes during the restore will be lost or will leave the database and files out of step.

## 3. Back up the current state

```bash
WP_PATH=/var/www/example.com/htdocs tools/backup.sh
```

It must report `test restore: PASSED`. This is your way back if the restore goes wrong. Don't continue without it.

## 4. Restore the files

Unpack next to the live root, check it, then swap. Keep the old root until you're happy.

```bash
cd /var/www/example.com
mkdir .restore && tar -C .restore -xpzf "$B/files.tar.gz"
ls .restore/htdocs/wp-load.php
mv htdocs htdocs.before-restore && mv .restore/htdocs htdocs
```

`-p` keeps file permissions, so the web server can still read everything. Run it as the user that owns the site files.

If the backup included sibling config files (`manifest.txt` lists them under `sibling_files`), they're in `.restore/`. Copy back only the ones you mean to restore, for example `cp -p .restore/wp-config.php .`.

## 5. Restore the database

```bash
gunzip -c "$B/db.sql.gz" > /tmp/restore.sql
wp --path=/var/www/example.com/htdocs db import /tmp/restore.sql
rm /tmp/restore.sql
```

Keep the SQL file outside the web root, as shown.

## 6. Check and reopen

```bash
wp --path=/var/www/example.com/htdocs cache flush
```

Clear the page cache and CDN too. Load the homepage, wp-admin and the site's critical flow (checkout, forms, login). Then lift maintenance mode, and log it:

```bash
WP_PATH=/var/www/example.com/htdocs tools/log.sh "Full restore from $B" "Restore the pre-restore backup from step 3"
```

Delete `htdocs.before-restore` and `.restore` once the site has run normally for a while.

## Things that aren't in the backup

`backup.sh` covers the database, the WordPress root and four sibling config files. Uploads stored outside the root, symlink targets, nginx or Apache config, PHP-FPM pools and cron jobs need their own backup and restore.

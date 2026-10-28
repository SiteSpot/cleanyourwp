# Troubleshooting

Things that bit us, in rough order of how often.

## PHP upgrades

- **Site fine for an hour, then white screen or 502s.** The new PHP-FPM pool has default `memory_limit`, `opcache.memory_consumption`, `max_execution_time` or `pm.max_children`. Diff the old and new pool configs and `php.ini` before switching, and carry the values across. `.user.ini` files are per-directory and per-version on some hosts.
- **Fatal error on a plugin after the switch.** The plugin isn't compatible with the new version. `wp plugin list --fields=name,requires_php` shows declared minimums but not maximums; a dry run on staging is the only real test. Roll back the PHP version first, then deal with the plugin.
- **`wp` runs a different PHP than the site.** Common. `wp --info` shows CLI PHP. Read the site's pool configuration or existing Site Health report. Creating a public PHP probe is a write and must not happen in read-only audit phases.

## Removing plugins

- **Shortcodes appear as raw `[text]` on the front end.** You removed a plugin that registered them. Search post content, postmeta (page builders) and widgets for the shortcode before removing, or reactivate and search.
- **Plugin deleted its data on uninstall.** Some do (forms, SEO, redirects). Export first: most have an export tool; otherwise `wp db export --tables=` the plugin's tables and `wp option get` its options to a file.
- **Licence seat still used after deleting a premium plugin.** Deactivate the licence in the plugin's settings before deleting.
- **Site slower after removing a caching plugin.** It was the only page cache. Put the host's cache, a server cache or another plugin in place first; never remove the only cache layer during business hours.

## Database

- **Search-and-replace corrupted page-builder layouts.** Serialized data has length prefixes. Only ever use `wp search-replace` (serialization-aware) and never raw SQL `REPLACE()`. Restore from the targeted backup.
- **Deleting revisions locked the site.** One giant `DELETE` on a big table holds locks. Delete in batches: `wp post delete $(wp post list --post_type=revision --format=ids --posts_per_page=500) --force`, repeat.
- **Autoloaded options still huge after cleanup.** Find the offenders: the audit's "largest autoloaded options" table. Set `autoload=no` on big ones that aren't needed on every request (`wp option update <name> <value> --autoload=no` re-sets the value; read it first).

## Caching

- **Changes don't show.** Four layers can hold the old page: plugin page cache, server cache (nginx FastCGI, LiteSpeed), CDN, browser. Clear in that order and check with a cache-busting query string.
- **Logged-in or cart pages cached.** A page cache without the right exclusions. Check the plugin's exclusion list for `/cart/`, `/checkout/`, `/my-account/`, and that it bypasses cache for cookies like `wordpress_logged_in_*` and `woocommerce_*`.
- **Two cache plugins active.** Pick one. Two page caches double-cache and fight over `advanced-cache.php`.
- **Object cache "enabled" but not connected.** The drop-in is present but Redis/Memcached is down or misconfigured. `wp eval 'echo wp_using_ext_object_cache()?"yes":"no";'` and `wp redis status` (if Redis Object Cache is the plugin).

## Backups

- **`backup.sh` says test restore NOT RUN (exit 2).** Scratch database creation failed; permissions, connectivity or configuration may be responsible. It is not a verified backup. Stop site changes and arrange an isolated staging restore or a correctly provisioned scratch database.
- **Backup is huge.** Uploads. Fine, but confirm disk space outside the web root first (`df -h`), and consider excluding a cache folder with `--exclude` if your host puts one inside `wp-content`.
- **Host backups exist but no one has restored one.** Treat as unverified. Restore the latest to staging once; it takes an hour and answers the question.

## Access

- **WP-CLI not available on a managed host.** Some don't ship it or restrict it. Use SSH + the host's own CLI if there is one, or fall back to REST / wp-admin paste. Say which rung you're on in the report.
- **REST API returns 401 with an application password.** Application passwords need HTTPS and are disabled on some hosts or by security plugins. Check Users > Profile > Application Passwords for the "not available" notice.
- **Crawl is slowing the site.** Stop. `PAUSE=3` on the scripts, and crawl at night.

## Going static

- **Export misses pages.** Static exporters follow links; orphan pages (no inbound link, not in the sitemap) are skipped. Fix the sitemap or add the URLs to the export's include list.
- **Forms stop working.** Expected. Point them at a hosted form endpoint before switching DNS.
- **Search box does nothing.** Expected. Remove it or use a client-side or hosted search.
- **WordPress still reachable at the old URL.** Good during the trial week; afterwards put it behind HTTP auth or a VPN, or on a subdomain nobody links to.

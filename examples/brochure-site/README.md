# Example run: a six-year-old brochure site

Anonymised. A small-business site, 14 pages, 40 posts, Elementor, 31 plugins, on a cPanel host with SSH. This is what the assistant produced, trimmed. Domain replaced with `example.com`; counts and versions are real.

## Phase 0: Map

| Site | Access | Hosting | Web server | PHP (site) | Staging | Multisite |
| --- | --- | --- | --- | --- | --- | --- |
| example.com | SSH + WP-CLI 2.11 | cPanel shared | LiteSpeed | 8.1.31 | No | No |

Evidence: `wp --info`, `wp core version`, Site Health > Info > Server.

## Phase 1: Inventory (excerpt)

| Item | Value | Evidence |
| --- | --- | --- |
| WordPress | 6.8.2, update to 6.9 available | `wp core check-update` |
| PHP (site) | 8.1.31, end of life since 31 Dec 2025 | Site Health; `/etc/php` shows 8.1, 8.2, 8.3, 8.4 installed |
| memory_limit | 256M | `wp eval 'echo ini_get("memory_limit");'` |
| Plugins | 31 installed, 24 active, 7 inactive | `wp plugin list` |
| Page cache | LiteSpeed Cache (plugin) AND WP Super Cache (active) | `wp plugin list --status=active`; both write `advanced-cache.php` |
| Object cache | none | `wp eval 'echo wp_using_ext_object_cache();'` → empty |
| Backups | cPanel JetBackup daily, 7-day retention, on-server only; restore never tested | cPanel > JetBackup |
| Admin users | 4; one named `admin`; one agency account registered 2020 | `wp user list --role=administrator` |
| Exposed files | `wp-content/backup-2021.zip` (210 MB) returns 200 in a browser | `find` + curl |
| Email | PHP mail, no SPF record, no DMARC | `dig TXT example.com` |
| TTFB (home, cold / warm) | 1,420 ms / 610 ms | `curl -w '%{time_starttransfer}'`, two requests |

## Phase 2: Labels (excerpt)

| Plugin | Label | Evidence | Risk |
| --- | --- | --- | --- |
| Elementor + Elementor Pro | KEEP | All 14 pages built with it (`_elementor_data` postmeta present) | — |
| WP Super Cache | CONSOLIDATE → remove | LiteSpeed Cache does the same layer on a LiteSpeed server; two `advanced-cache.php` writers | Low |
| Contact Form 7 | KEEP (REVENUE) | 3 forms, 612 entries via Flamingo, used on /contact/ and /quote/ | — |
| Sticky Header by X | REPLACE: SNIPPET | Only setting in use: pin `.site-header` | Low |
| Duplicate Page | REMOVE | Elementor duplicates templates natively; last used per logs 2023 | Low |
| All-in-One WP Migration | DEV TOOL | Migration tool from the 2021 move; 210 MB export still in web root | Low |
| Classic Editor | REMOVE | 0 of 40 posts edited since 2022; editor is Elementor | Low |
| Really Simple SSL | REPLACE: CORE | Host handles the certificate; redirect lives in `.htaccess` | Medium (test redirect) |
| Yoast SEO | UPDATE | 3 versions behind | — |
| Insert Headers and Footers | REPLACE: SNIPPET | One GA4 tag | Low |
| WP Mail SMTP | ASK | Installed, not configured; mail currently via PHP mail | — |

## Phase 3: Static?

| Feature | Pages | Classification |
| --- | --- | --- |
| form_post | 2 (/contact/, /quote/) | Replaceable: hosted form endpoint |
| search | 0 | — (theme has no search box) |
| comments | 0 | Removable: closed since 2021 |
| admin_ajax | 14 | Elementor Pro's form widget and a "related posts" widget; the forms are the two above, the related-posts widget can be static |
| login / cart / booking | 0 | — |

**Verdict: hybrid.** Two forms move to a hosted endpoint; everything else is static. Estimate: 6–8 hours including a week of parallel running. Loses: nothing the owner uses.

## Phase 4: Score (before)

| Item | Score | Evidence |
| --- | --- | --- |
| PHP | 0 | 8.1, EOL |
| WordPress | 1 | one minor behind, auto-updates on for minors |
| Editor | 1 | Elementor, kept deliberately |
| Caching | 0 | two page caches conflicting |
| Backups | 1 | daily, on-server, unverified |
| Security | 0 | exposed 210 MB zip, `admin` user, migration tool active |
| Email | 0 | PHP mail, no SPF |
| Agent access | 1 | REST reachable, no application passwords |
| **Total** | **4 / 16** | |

## Phase 5: Quiz answers

1-C (capture leads), 2-B (owner, rarely), 3-B (lost leads), 4-B (modernisation), 5-A (keep Elementor), 6-C (agents: not yet), 7-B (nights).

## Phase 6: Plan (excerpt)

1. **Verify a backup.** Restore last night's JetBackup to a temp subdomain, load the home page. Risk low. Rollback n/a. 30 min.
2. **Delete `wp-content/backup-2021.zip` and the migration plugin.** Copy the zip off-server first. Risk low. Rollback: copy it back. 15 min.
3. **Remove the `admin` user, reassigning content to the owner; remove the 2020 agency account.** Risk low. Rollback: `wp user create` from the exported user rows. 15 min.
4. **PHP 8.1 → 8.2 → 8.4, nights.** Check Elementor and Yoast declare 8.4 support (they do). Carry over `memory_limit`. Risk medium. Rollback: switch back in MultiPHP Manager. 45 min across two nights.
5. **Remove WP Super Cache; keep LiteSpeed Cache.** Risk low. Rollback: reactivate. 15 min.
6. **Replace Sticky Header and Insert Headers and Footers with snippets.** Risk low. Rollback: reactivate plugins, delete mu-plugin. 20 min.
7. **Remove Duplicate Page, Classic Editor, Really Simple SSL** (after confirming the `.htaccess` redirect). Risk low–medium. 20 min.
8. **REVENUE: configure WP Mail SMTP with the owner's mail service, add SPF and DMARC.** Test with a form submission. Risk medium. Rollback: deactivate plugin, PHP mail resumes. 45 min + DNS wait.
9. **Database cleanup:** 1,840 revisions, 212 spam comments, expired transients. Batched. 15 min.
10. **Hybrid static: separate project.** Scope above.

## Phase 8: Monitoring (24 hours after item 9)

48 checks, every 30 minutes. One finding: at 03:10 the PHP error log showed a deprecation notice from the old theme's `functions.php` under PHP 8.4, repeated by the nightly cron. Pages, forms and wp-admin were unaffected, so no rollback; it went into the report as a follow-up. TTFB stayed within 60 ms of the post-change measurement, and there were no new web server errors.

## Phase 9: Report (after items 1–9)

| Metric | Before | After |
| --- | --- | --- |
| Plugins installed / active | 31 / 24 | 19 / 16 |
| PHP | 8.1.31 | 8.4.12 |
| TTFB home cold / warm | 1,420 / 610 ms | 540 / 95 ms |
| Database | 118 MB | 61 MB |
| Score | 4 / 16 | 12 / 16 |
| Security issues closed | — | exposed archive, `admin` user, stale agency account, migration tool on production |
| Deferred | — | hybrid static (item 10), object cache (host doesn't offer Redis on this plan), 2FA (owner declined for now) |

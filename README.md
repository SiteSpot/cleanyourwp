# CleanYourWP

**Your WordPress site, minus the dead weight.** Hand a coding assistant one prompt and it audits your site, shows you the evidence, tells you how far forward it can go in 2026 (including whether it could go static), quizzes you on the judgement calls, and then cleans things up one approved change at a time. Nothing changes without your `GO`. Nothing changes without a backup it has test-restored. Every change comes with its own undo.

> **Sponsored by [AB Split Test](https://absplittest.com)**: A/B testing for WordPress and any website. Once your site is lean, find out what actually converts.

[How it works](#how-it-works) · [Quick start](#quick-start) · [What you get](#what-you-get) · [Supported setups](#supported-setups) · [The scripts](#the-scripts) · [Restoring](#restoring-your-site) · [Questions](#questions-people-ask) · [Contributing](#contributing)

## Start here

| You have | Go to |
| --- | --- |
| **SSH or WP-CLI access to your site** | [Quick start](#quick-start): a coding assistant does the audit in about twenty minutes and the clean-up at your pace. |
| **A managed host with no SSH** | Quick start still works. The assistant uses the REST API, or asks you to paste your Site Health report. See [docs/hosts.md](docs/hosts.md). |
| **A client's site, or ten of them** | Same prompt, one site at a time. Each site gets its own plan and its own approvals. |
| **Want to see it first** | [What you get](#what-you-get): what the audit and the final report look like. |

## How it works

Most WordPress sites that have been around a few years carry three plugins doing one job, a sticky-header plugin six lines of CSS could replace, debug tools left on in production, and a PHP version nobody has checked since 2022. The fix is boring: inventory, evidence, decisions, then one small change at a time. That is what the prompt makes the assistant do, in order, with a verified backup before the first change.

| Phase | What happens | Changes anything? |
| --- | --- | --- |
| **0. Map** | Finds how it can reach each site (SSH + WP-CLI, MCP, REST, or wp-admin paste) and what the hosting looks like. | No |
| **1. Inventory** | PHP, WordPress, every plugin and theme, caching layers, backup system, security, database, content health, email. With evidence. | No |
| **2. Evidence** | For every plugin: is it actually used? Shortcodes, blocks, widgets, cron hooks, options, logs. Each gets one label: KEEP, UPDATE, CONSOLIDATE, REPLACE, REMOVE, DEV TOOL, ASK. | No |
| **3. Static?** | Checks every page for forms, search, logins, carts, admin-ajax calls. Verdict: static, hybrid, or stays dynamic. | No |
| **4. Score** | A 0–16 score per site: PHP, WordPress, editor, caching, backups, security, email, agent access. | No |
| **5. Quiz** | Multiple-choice questions on the calls only you can make. | No |
| **6. Plan** | A numbered plan. You approve items with `GO 3`. | No |
| **7. Change** | Full backup, test restore, then one item at a time: pre-flight, second `GO`, targeted backup, change, clear caches, verify, log. | Only what you approved |
| **8. Monitor** | Every 30 minutes for 24 hours: pages, wp-admin, error logs, cron, cache headers, disk, HTTPS. Alerts you and proposes a rollback if anything breaks. | Only a rollback |
| **9. Report** | Before and after: plugin count, PHP, TTFB, score, what was closed, what was deferred, a quarterly checklist. | No |

**Read-only until Phase 7. Numbered approvals. Verified backups. 24 hours of monitoring afterwards. A dated change log on the server. ASK is always an acceptable answer.**

## Quick start

The assistant needs a shell with access to your site. SSH plus WP-CLI gives the best results.

Any of these work: Claude Code, Codex, Gemini CLI, or any agent that can run commands.

| Where | What to do |
| --- | --- |
| **1. On your computer** | `git clone https://github.com/SiteSpot/cleanyourwp` and open that folder in your assistant. |
| **2. Tell it how to reach the site** | SSH host and WordPress path, or a REST application password, or that it's wp-admin only. The prompt asks. |
| **3. Paste `PROMPT.md`** | The whole file. Then answer the quiz when it comes. |
| **4. Approve by number** | `GO 1`, `GO 2`, and so on. The assistant does one, verifies it, and waits. |

Cloning matters for one reason: the assistant uses `tools/backup.sh`, which test-restores every backup, instead of improvising one that it never checks.

## What you get

| Part | What it looks like |
| --- | --- |
| **An inventory you can trust** | One table per area, every row with the command and output that produced it. |
| **A verdict per plugin** | Not "looks unused" but "no shortcode in 1,240 posts, no cron hook, no option read in 30 days: REMOVE, low risk". |
| **A static-readiness answer** | Per page: which dynamic features exist, which are removable, which could move to a hosted service, which keep the site dynamic. |
| **A 2026 score** | Eight rows, 0–2 each, so you can see at a glance where each site stands and compare sites. |
| **A plan you control** | Numbered, with risk, verification and the exact rollback for each item. |
| **A change log on the server** | `wp-content/refresh-log.md`: what changed, when, and how to undo it. |
| **A before and after** | Plugin count, PHP version, TTFB, Core Web Vitals, database size, security issues closed. |

See [examples/brochure-site/](examples/brochure-site/) for a full anonymised run: inventory, labels, quiz, plan, report.

## Supported setups

| Setup | What works |
| --- | --- |
| **SSH + WP-CLI** (VPS, GridPane, RunCloud, Ploi, SpinupWP, Kinsta, WP Engine, Cloudways, most cPanel hosts) | Everything. |
| **WordPress MCP Adapter** (WordPress 6.9+) | The audit, using whatever abilities the site exposes. Changes need WP-CLI or REST. |
| **REST API with an application password** | Most of the inventory. No files, PHP settings or database; those rows say so. |
| **wp-admin only** | Reduced mode: paste Site Health and the plugin list. The assistant works from that and tells you what it couldn't check. |
| **WordPress multisite** | The assistant stops and asks before doing anything. Not yet tested end to end. |
| **WooCommerce or EDD with recent orders** | Audit runs. Any change touching checkout, carts, licensing or email is marked REVENUE and needs a tested replacement in the plan. |

## The scripts

There are two, both in `tools/`. The assistant does everything else with read-only WP-CLI commands, `curl` and a browser, following the prompt. You can also run both scripts yourself on the server. They need Bash 4+, WP-CLI, GNU `tar` and `sha256sum`, and the MySQL client.

```bash
export WP_PATH=/var/www/example.com/htdocs   # the WordPress root

tools/backup.sh                              # full backup, verified by a test restore
tools/log.sh "what changed" "how to undo it" # one line in the change log
```

| Script | What it does | Writes? |
| --- | --- | --- |
| [`tools/backup.sh`](tools/backup.sh) | Dumps the database and archives the WordPress root plus sibling `.user.ini`, `.htaccess`, `.env` and `wp-config.php`, outside the root. Then imports the dump into a scratch database and compares row counts. Exits 0 only if that passes; exit 2 means the test restore couldn't run. | Yes, outside the WordPress root |
| [`tools/log.sh`](tools/log.sh) | Appends a dated entry to `wp-content/refresh-log.md`. Block HTTP access to that file. | Yes, one file |

Read-only WP-CLI commands still boot WordPress and its plugins, and page requests can warm caches or trigger cron. Use staging if you need zero side effects on production.

## Restoring your site

| What | How |
| --- | --- |
| **Per-change undo** | Every Phase 7 item has its own rollback in the change log, usually a plugin re-activation or a single-table import. This is what you'll normally use. |
| **Full restore** | Rare and different on every host, so it's a short manual procedure rather than a script: [docs/restore.md](docs/restore.md). Back up the current state, swap the files, import the database. |
| **No shell?** | Your host's own backup is still there. The prompt never replaces it; it adds to it. |

`backup.sh` covers the database, the WordPress root and four sibling config files. Uploads outside the root, symlink targets and server config (nginx, PHP-FPM, cron) need their own backups. The test restore proves the dump imports and four core tables match. It doesn't prove every plugin works.

## When something goes wrong

The full list is in [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md). The three that matter most:

- ⚠️ **PHP upgrade looked fine, site died an hour later.** The new PHP pool didn't inherit opcache size or memory limits. Compare old and new settings before switching.
- 🧩 **Removed a plugin, shortcodes now show as raw text.** Search post content and postmeta for the shortcode first. The prompt makes the assistant do this.
- 🗄️ **Search-and-replace broke the page builder.** Builder data is serialized. Use `wp search-replace`, never raw SQL.

## Questions people ask

**Is this safe? Can it break my site?**

Phases 0 to 6 only read. Phase 7 needs a numbered `GO` from you for each item, a full backup it has test-restored, and a targeted backup per change. Every change has a written rollback before it starts. The risk is approving something you didn't understand, which is why the plan explains risk, verification and rollback per item, and why ASK is a valid label.

**Will it delete my plugins?**

Not without your approval, and not before deactivating, verifying, and exporting any data the plugin stores. Premium licences are deactivated first so the seat is freed.

**What does "go static" mean?**

Serving your site as plain HTML, CSS and JavaScript from a CDN, with no PHP or database answering public requests. Faster, cheaper, much harder to hack. Most brochure sites and blogs can. Stores, membership sites and anything with real logins can't, though they can get close with full-page caching. Phase 3 works it out per page. See [docs/static.md](docs/static.md).

**What's the MCP Adapter and should I install it?**

An official WordPress.org plugin that exposes your site's registered abilities to AI agents over the Model Context Protocol. It needs WordPress 6.9 or newer. The prompt never installs it on its own; it becomes a plan item if you said you want agent access in the quiz. See [docs/mcp.md](docs/mcp.md).

**Does it work on managed hosts without SSH?**

Yes, in reduced mode. See [docs/hosts.md](docs/hosts.md) for what each host allows.

**Can I use it on client sites?**

Yes. Get the client's approval for the plan, not just yours, and keep the change log. The report at the end is written to be handed over.

## Contributing

The most useful contribution is a replacement snippet or a host note, so the next person skips the discovery.

| How to help | What it means |
| --- | --- |
| **A replacement snippet** | A plugin you replaced with under 30 lines of code, in [`snippets/`](snippets/). Format in [CONTRIBUTING.md](CONTRIBUTING.md). |
| **A host note** | What your host allows (SSH, WP-CLI, PHP switching, backups) in [docs/hosts.md](docs/hosts.md). |
| **An example run** | An anonymised audit and plan in [`examples/`](examples/), so people see what good looks like. |
| **Sharper prompt wording** | Pull requests to `PROMPT.md` welcome. Keep the safety rails; tighten everything else. |

Contributing through a coding agent? [AGENTS.md](AGENTS.md) gives it the same rules.

## Sponsor

CleanYourWP is sponsored by **[AB Split Test](https://absplittest.com)**, the A/B testing plugin for WordPress, with a cloud version for any website. A clean, fast site is the best starting point for testing headlines, layouts and offers. The sponsorship keeps this project free and MIT-licensed. It doesn't change what the audit recommends.

## Legal

- CleanYourWP is an independent open-source project, not affiliated with WordPress.org, Automattic or any host. Plugin and host names are used only to say what was tested.
- It works only through tools the site owner already has: WP-CLI, the REST API, and wp-admin. It does not exploit anything.
- You run it on sites you own or are authorised to maintain, at your own risk. Everything here is provided as is, without warranty, under the MIT licence.

## Licence

MIT, see [`LICENSE`](LICENSE).

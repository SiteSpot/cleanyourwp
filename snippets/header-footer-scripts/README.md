# header-footer-scripts

**Replaces:** "Insert Headers and Footers" style plugins used to drop an analytics tag or a verification meta tag into every page.

**Covers:** printing a fixed block of HTML in `<head>` and before `</body>`, from the file itself (version-controlled, no settings page).

**Doesn't cover:** editing the snippet from wp-admin, per-page scripts, consent gating. If a non-technical editor changes the tags, keep the plugin.

**Tested on:** WordPress 6.9, PHP 8.4, October 2026. Edit the two heredocs and keep the tags you actually use.

# Snippets

Small pieces of code that replace a whole plugin. Each folder has a README saying what it replaces, what it covers, what it doesn't, and what it was tested on. Read the "doesn't cover" line before you swap; the plugin usually did more than you remember.

How to install a PHP plugin snippet: copy the `.php` file into `wp-content/mu-plugins/` (create the folder if it doesn't exist). It loads automatically, can't be deactivated from wp-admin, and shows under Plugins > Must-Use. The revision-limit snippet belongs in `wp-config.php`, not mu-plugins. If combining snippets into one file, keep only one opening `<?php` tag and one plugin header; do not concatenate complete PHP files verbatim.

How to install a CSS snippet: paste it into Appearance > Customize > Additional CSS, or your child theme's stylesheet.

| Snippet | Replaces | Type |
| --- | --- | --- |
| [sticky-header](sticky-header/) | Sticky header / sticky menu plugins | CSS |
| [disable-comments](disable-comments/) | Disable Comments and similar | PHP |
| [svg-upload](svg-upload/) | Keep an SVG sanitizer; no replacement snippet | Guidance |
| [header-footer-scripts](header-footer-scripts/) | "Insert Headers and Footers" style plugins | PHP |
| [disable-xmlrpc](disable-xmlrpc/) | XML-RPC disabler plugins | PHP |
| [limit-revisions](limit-revisions/) | Revision-limiting plugins | PHP (wp-config) |
| [back-to-top](back-to-top/) | Back-to-top button plugins | CSS + HTML |

Contribute one: see [CONTRIBUTING.md](../CONTRIBUTING.md).

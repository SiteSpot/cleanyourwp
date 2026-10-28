# disable-comments

**Replaces:** Disable Comments and similar plugins, when the goal is "no comments anywhere".

**Covers:** closes comments and pingbacks on all post types, hides the comment form, removes the Comments menu and admin bar item, removes the Recent Comments widget, disables comment REST and feed endpoints.

**Doesn't cover:** deleting existing comments (do that deliberately with `wp comment delete $(wp comment list --format=ids)` after a backup), per-post-type selection, hiding the Discussion settings page.

**Tested on:** WordPress 6.9, PHP 8.4, block and classic themes, October 2026.

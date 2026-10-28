# limit-revisions

**Replaces:** plugins whose only job is to cap post revisions or change the autosave interval.

**Covers:** limiting stored revisions per post and lengthening the autosave interval, via two constants in `wp-config.php`.

**Doesn't cover:** deleting existing revisions (do that with `wp post delete $(wp post list --post_type=revision --format=ids) --force` after a backup, in batches on big sites), per-post-type limits.

**Tested on:** every WordPress version since 3.x. Add the lines above the `/* That's all, stop editing! */` comment.

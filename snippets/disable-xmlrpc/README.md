# disable-xmlrpc

**Replaces:** single-purpose XML-RPC disabler plugins.

**Covers:** turning off XML-RPC methods and removing the pingback header, so brute-force and amplification attacks via `xmlrpc.php` stop working.

**Doesn't cover:** blocking the file at the web server (better still; add a `location = /xmlrpc.php { deny all; }` in nginx or the Apache equivalent). Breaks the legacy WordPress mobile app and Jetpack features that still rely on XML-RPC; check before applying.

**Tested on:** WordPress 6.9, PHP 8.4, October 2026.

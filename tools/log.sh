#!/usr/bin/env bash
# CleanYourWP: append an entry to the on-server change log. WRITES ONE FILE.
#
#   WP_PATH=/var/www/example.com/htdocs tools/log.sh "<what changed>" "<how to roll it back>" [backup path]
#
# The log is wp-content/refresh-log.md, a plain markdown file the owner can read in a file
# manager. Never put secrets in it, and block HTTP access to it.

set -euo pipefail

[ -f "${WP_PATH:-}/wp-load.php" ] || { echo "error: set WP_PATH to the WordPress root" >&2; exit 1; }
[ -n "${1:-}" ] && [ -n "${2:-}" ] || { echo 'usage: log.sh "what" "rollback" [backup path]' >&2; exit 1; }

LOG="$WP_PATH/wp-content/refresh-log.md"
if [ ! -f "$LOG" ]; then
  printf '# Refresh change log\n\nWritten by CleanYourWP. Newest at the bottom.\n\n| Date (UTC) | Change | Rollback | Backup |\n| --- | --- | --- | --- |\n' > "$LOG"
fi
printf '| %s | %s | %s | %s |\n' "$(date -u +%Y-%m-%dT%H:%MZ)" "$1" "$2" "${3:-—}" >> "$LOG"
echo "logged to $LOG" >&2

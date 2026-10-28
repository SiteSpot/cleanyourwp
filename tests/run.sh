#!/usr/bin/env bash
# Regression checks for tools/backup.sh and tools/log.sh. WP-CLI, MySQL and tar failures are mocked.
set -euo pipefail
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/site/wp-content"
touch "$TMP/site/wp-load.php"
export WP_PATH="$TMP/site" MYSQL_CALLS="$TMP/mysql" REAL_TAR
REAL_TAR=$(command -v tar)
export PATH="$TMP/bin:$PATH"

cat > "$TMP/bin/wp" <<'MOCK'
#!/usr/bin/env bash
case "${1:-}" in --path=*) shift ;; esac
case "$1 ${2:-}" in
  'db prefix') echo wp_ ;;
  'db export') printf -- '-- Dump completed\n' > "$3" ;;
  'db query') echo 7 ;;
  'config get') case "$3" in DB_USER) echo user ;; DB_PASSWORD) echo 'dummy-secret-123"\' ;; DB_HOST) echo localhost:3307 ;; esac ;;
  'option get') echo https://example.test ;;
  'core version') echo 6.9 ;;
esac
MOCK
cat > "$TMP/bin/mysql" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$MYSQL_CALLS"
case "$1" in --defaults-extra-file=*) cnf="${1#*=}" ;; *) exit 80 ;; esac
grep -q '^password=' "$cnf" && grep -q '^port=3307' "$cnf" || exit 81
case "$*" in
  *'CREATE DATABASE'*) exit "${FAIL_CREATE:-0}" ;;
  *'SELECT COUNT'*) echo "${RESTORED_ROWS:-7}" ;;
  *'DROP DATABASE'*) : ;;
  *) cat >/dev/null ;;
esac
MOCK
cat > "$TMP/bin/tar" <<'MOCK'
#!/usr/bin/env bash
if [ "${FAIL_ARCHIVE:-0}" = 1 ]; then case " $* " in *' -czf '*) exit 1 ;; esac; fi
exec "$REAL_TAR" "$@"
MOCK
chmod +x "$TMP/bin/"*

pass() { printf 'PASS %s\n' "$*"; }
expect_exit() { local want="$1"; shift; set +e; "$@" > "$TMP/out" 2>&1; local got=$?; set -e
  [ "$got" = "$want" ] || { echo "expected exit $want, got $got: $*" >&2; cat "$TMP/out" >&2; exit 1; }; }
no_leftover_credentials() { [ -z "$(find "$TMP" -name '.mysql.*')" ] || { echo 'credentials file left behind' >&2; exit 1; }; }

for f in "$REPO"/tools/*.sh "$REPO"/tests/*.sh; do bash -n "$f"; done
pass 'shell files parse'

printf 'sibling config\n' > "$TMP/wp-config.php"
expect_exit 0 bash "$REPO/tools/backup.sh" "$TMP/backups"
grep -q 'test restore: PASSED' "$TMP/out"
DEST=$(find "$TMP/backups" -mindepth 1 -maxdepth 1 -type d)
( cd "$DEST" && sha256sum -c --quiet SHA256SUMS )
tar -tzf "$DEST/files.tar.gz" | grep -qx 'wp-config.php'
grep -q 'verified: yes' "$DEST/manifest.txt"
no_leftover_credentials
if grep -qE -- '--password|dummy-secret' "$MYSQL_CALLS"; then echo 'password on the command line' >&2; exit 1; fi
pass 'verified backup includes sibling config and keeps the password off the command line'

expect_exit 1 env RESTORED_ROWS=3 bash "$REPO/tools/backup.sh" "$TMP/mismatch"
grep -q 'test restore: FAILED' "$TMP/out"
pass 'row-count mismatch fails the backup'

expect_exit 2 env FAIL_CREATE=1 bash "$REPO/tools/backup.sh" "$TMP/nocreate"
grep -q 'NOT RUN' "$TMP/out"
no_leftover_credentials
pass 'no scratch database exits 2 and removes the credentials file'

expect_exit 1 env FAIL_ARCHIVE=1 bash "$REPO/tools/backup.sh" "$TMP/archive"
if grep -q 'PASSED' "$TMP/out"; then echo 'certified a failed archive' >&2; exit 1; fi
pass 'archive failure fails the backup'

expect_exit 1 bash "$REPO/tools/backup.sh" "$WP_PATH/wp-content/backups"
pass 'backup inside the WordPress root is refused'

bash "$REPO/tools/log.sh" "Removed Hello Dolly" "wp plugin install hello-dolly --activate" 2>/dev/null
grep -q '| Removed Hello Dolly | wp plugin install hello-dolly --activate | — |' "$WP_PATH/wp-content/refresh-log.md"
expect_exit 1 bash "$REPO/tools/log.sh" "missing rollback"
pass 'log.sh appends an entry and requires a rollback'

printf '\nAll checks passed. No live services were used.\n'

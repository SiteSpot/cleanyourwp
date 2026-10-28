#!/usr/bin/env bash
# CleanYourWP: full backup with a verified test restore. THIS SCRIPT WRITES (outside the WordPress root).
#
#   WP_PATH=/var/www/example.com/htdocs tools/backup.sh [backup_root]
#
# Produces <backup_root>/<timestamp>.<random>/ containing:
#   db.sql.gz      full database dump (wp db export)
#   files.tar.gz   the WordPress root plus sibling .user.ini, .htaccess, .env and wp-config.php
#   SHA256SUMS     checksums of both
#   manifest.txt   row counts, sizes and the test-restore result
#
# The test restore imports the dump into a scratch database using the site's own credentials,
# compares row counts for options/posts/postmeta/users, then drops it. Exit 0 means verified,
# 2 means the scratch database couldn't be created (NOT verified), anything else means failed.

set -euo pipefail
umask 077

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
note() { printf '%s\n' "$*" >&2; }

[ -n "${WP_PATH:-}" ] || die "set WP_PATH to the WordPress root (the folder with wp-config.php)"
[ -f "$WP_PATH/wp-load.php" ] || die "no wp-load.php in $WP_PATH"
WP_PATH=$(cd "$WP_PATH" && pwd -P)
command -v wp >/dev/null || die "wp (WP-CLI) not found on PATH"
command -v mysql >/dev/null || die "mysql client is required for the test restore"
wpq() { wp --path="$WP_PATH" "$@"; }

ROOT=$(realpath -m "${1:-${BACKUP_ROOT:-$(dirname "$WP_PATH")/cleanyourwp-backups}}")
case "$ROOT" in "$WP_PATH"|"$WP_PATH"/*) die "backup destination is inside the WordPress root; set BACKUP_ROOT elsewhere" ;; esac
PREFIX=$(wpq db prefix)
[[ "$PREFIX" =~ ^[A-Za-z0-9_]+$ ]] || die "unsupported database prefix"

mkdir -p "$ROOT"
DEST=$(mktemp -d "$ROOT/$(date -u +%Y-%m-%dT%H-%M-%SZ).XXXXXX")
MANIFEST="$DEST/manifest.txt"
note "CleanYourWP backup of $WP_PATH"
note "  Writing to $DEST and creating a temporary scratch database. The site itself is not changed."
printf 'site_path: %s\nsite_url: %s\nwp_version: %s\n' "$WP_PATH" "$(wpq option get siteurl)" "$(wpq core version)" > "$MANIFEST"

TABLES=(options posts postmeta users)
count_rows() { wpq db query "SELECT COUNT(*) FROM ${PREFIX}$1;" --skip-column-names | head -1; }

note "[1/3] Database…"
wpq db export "$DEST/db.sql" --add-drop-table --quiet
gzip "$DEST/db.sql"
declare -A LIVE
for t in "${TABLES[@]}"; do LIVE[$t]=$(count_rows "$t"); done

note "[2/3] Files (can take a while with a big uploads folder)…"
PARENT=$(dirname "$WP_PATH"); BASE=$(basename "$WP_PATH")
EXTRA=()
for f in .user.ini .htaccess .env wp-config.php; do if [ -f "$PARENT/$f" ]; then EXTRA+=("$f"); fi; done
tar -C "$PARENT" -czf "$DEST/files.tar.gz" "$BASE" "${EXTRA[@]}" || die "file archive failed; backup is NOT verified"
tar -tzf "$DEST/files.tar.gz" >/dev/null || die "files.tar.gz does not list cleanly; backup is NOT verified"
( cd "$DEST" && sha256sum db.sql.gz files.tar.gz > SHA256SUMS )
printf 'sibling_files: %s\n' "${EXTRA[*]:-none}" >> "$MANIFEST"

note "[3/3] Test restore into a scratch database…"
# Credentials go in a private defaults file, never on the command line.
quote() { local v="${1//\\/\\\\}"; v="${v//\"/\\\"}"; printf '"%s"' "$v"; }
DB_HOST=$(wpq config get DB_HOST); HOST_OPT="host=$(quote "${DB_HOST%%:*}")"
case "$DB_HOST" in
  *:/*) HOST_OPT="$HOST_OPT"$'\n'"socket=$(quote "${DB_HOST#*:}")" ;;
  *:*)  [[ "${DB_HOST#*:}" =~ ^[0-9]+$ ]] || die "unsupported DB_HOST"; HOST_OPT="$HOST_OPT"$'\n'"port=${DB_HOST#*:}" ;;
esac
CNF=$(mktemp "$DEST/.mysql.XXXXXX")
SCRATCH="cywp_verify_$(date +%s)_$$"
CREATED=no
cleanup() {
  [ "$CREATED" = no ] || mysql --defaults-extra-file="$CNF" -e "DROP DATABASE \`$SCRATCH\`;" 2>/dev/null \
    || note "warning: drop scratch database $SCRATCH by hand"
  rm -f "$CNF"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
printf '[client]\nuser=%s\npassword=%s\n%s\n' "$(quote "$(wpq config get DB_USER)")" "$(quote "$(wpq config get DB_PASSWORD)")" "$HOST_OPT" > "$CNF"
MYSQL=(mysql --defaults-extra-file="$CNF")

if ! "${MYSQL[@]}" -e "CREATE DATABASE \`$SCRATCH\` CHARACTER SET utf8mb4;" 2>/dev/null; then
  echo "verified: no (could not create a scratch database)" >> "$MANIFEST"
  printf '\nBackup written to %s\n  test restore: NOT RUN. The DB user cannot create a database.\n' "$DEST"
  printf '  The dump is unverified. Restore it on staging before changing the site.\n'
  exit 2
fi
CREATED=yes
VERIFIED=yes
if gunzip -c "$DEST/db.sql.gz" | "${MYSQL[@]}" "$SCRATCH" 2>"$DEST/restore-test.err"; then
  for t in "${TABLES[@]}"; do
    got=$("${MYSQL[@]}" -N -e "SELECT COUNT(*) FROM \`$SCRATCH\`.\`${PREFIX}${t}\`;" 2>/dev/null || echo '?')
    echo "rows_$t: restored $got, live ${LIVE[$t]}" >> "$MANIFEST"
    [ "$got" = "${LIVE[$t]}" ] || VERIFIED=no
  done
else
  VERIFIED=no
  echo "import_error: see restore-test.err" >> "$MANIFEST"
fi
echo "verified: $VERIFIED" >> "$MANIFEST"

printf '\nBackup written to %s\n' "$DEST"
du -h "$DEST/db.sql.gz" "$DEST/files.tar.gz" | sed 's/^/  /'
if [ "$VERIFIED" = yes ]; then
  printf '  test restore: PASSED (row counts match for %s)\n' "${TABLES[*]}"
else
  printf '  test restore: FAILED. Do not change the site. See %s\n' "$MANIFEST"
  exit 1
fi

#!/bin/bash
# Setup the test PostgreSQL database for rpsql.
# Run once before running tinydev::pkg_test(".").
# Requires a running PostgreSQL server where the current OS user has
# createdb privileges (the default on most developer installs).

set -euo pipefail

DB_NAME="rpsql_test"
DB_HOST="${PGHOST:-/var/run/postgresql}"
DB_PORT="${PGPORT:-5432}"
DB_USER="${PGUSER:-$USER}"

echo "==> Creating test database '${DB_NAME}' (owner: ${DB_USER})"

if psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" \
        -lqt 2>/dev/null | cut -d'|' -f1 | grep -qw "${DB_NAME}"; then
    echo "    Database '${DB_NAME}' already exists — skipping creation."
else
    createdb -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" \
        -E UTF8 --template=template0 "${DB_NAME}"
    echo "    Created."
fi

echo ""
echo "==> Test database ready."
echo ""
echo "Add the following lines to your shell profile (~/.bashrc, ~/.zshrc, etc.)"
echo "so that rpsql tests can connect:"
echo ""
echo "    export PGDATABASE=${DB_NAME}"
echo "    export PGHOST=${DB_HOST}"
echo "    export PGPORT=${DB_PORT}"
echo "    export PGUSER=${DB_USER}"
echo ""
echo "Or export them only for this shell session:"
echo ""
echo "    export PGDATABASE=${DB_NAME}"

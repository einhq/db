#!/bin/bash
# Starts PostgreSQL. Arguments that begin with a dash are the server's (-c name=value); any other
# command runs as it is. The first start in an empty PGDATA makes the cluster first: the role
# POSTGRES_USER as its superuser with the password POSTGRES_PASSWORD, and the database POSTGRES_DB.
# EiN creates the extensions it uses itself.
set -euo pipefail

[ "${1:0:1}" != - ] || set -- postgres "$@"

if [ "$1" = postgres ] && [ ! -s "$PGDATA/PG_VERSION" ]; then
  : "${POSTGRES_PASSWORD:?is needed for the first start, which makes the database}"
  user=${POSTGRES_USER:-postgres}
  db=${POSTGRES_DB:-$user}

  # The socket, inside the container, needs no password; anything over the network does.
  initdb --username="$user" --pwfile=<(printf '%s\n' "$POSTGRES_PASSWORD") \
    --encoding=UTF8 --locale=C.UTF-8 --auth-local=trust --auth-host=scram-sha-256
  echo 'host all all all scram-sha-256' >>"$PGDATA/pg_hba.conf"

  # Memory and parallelism sized to the machine, or to the container's memory limit when it has one.
  memory=()
  limit=$(cat /sys/fs/cgroup/memory.max 2>/dev/null || echo max)
  [ "$limit" = max ] || memory=(--memory="$((limit / 1024 / 1024))MB")
  timescaledb-tune --quiet --yes --pg-version=18 --conf-path="$PGDATA/postgresql.conf" "${memory[@]}" >/dev/null
  printf '%s\n' "listen_addresses = '*'" 'timescaledb.telemetry_level = off' >>"$PGDATA/postgresql.conf"

  [ "$db" = postgres ] || echo "CREATE DATABASE \"${db//\"/\"\"}\"" | postgres --single -D "$PGDATA" postgres >/dev/null
fi

exec "$@"

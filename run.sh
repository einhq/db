#!/bin/bash
# Builds the database image and (re)starts EiN's PostgreSQL container, then waits until it answers.
# EiN creates and updates the extensions it uses itself.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

POSTGRES_USER="${POSTGRES_USER:-ein}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-ein}"
POSTGRES_DB="${POSTGRES_DB:-ein}"
# Under --network=host the port is all that separates two servers on one host, and a second one
# on a taken port does not fail visibly: change the name and the port together.
CONTAINER_NAME="${PG_CONTAINER_NAME:-postgres}"
PGPORT="${PGPORT:-5432}"
# An absolute path; put it on a device with room, embeddings grow with the archive.
PGDATA_HOST_PATH="${PGDATA_HOST_PATH:-$HOME/services/postgres}"

# The base is a floating tag, and a build reuses the first copy pulled, so pull it first. Offline,
# the build goes on with the local copy.
BASE_IMAGE=$(awk '/^FROM /{print $2; exit}' Containerfile)
podman pull "$BASE_IMAGE" >/dev/null || echo "warning: could not pull $BASE_IMAGE, building on the local copy"
podman build -t postgres-timescale-pgvector .

# The mount is the image's PGDATA: any other path leaves the data in the container's own layer,
# gone at the next --replace. `:U` gives the directory to the container's postgres user under
# rootless podman, which needs it to exist. --shm-size: parallel queries exchange rows through
# shared memory, and podman's 64 MB default makes them fail under load. TimescaleDB must be
# preloaded; pg_stat_statements is, so that a profiling session can create it.
mkdir -p "$PGDATA_HOST_PATH"
podman run --replace -d \
  --name "$CONTAINER_NAME" \
  --shm-size=1g \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -e POSTGRES_DB="$POSTGRES_DB" \
  -v "$PGDATA_HOST_PATH":/home/postgres/pgdata/data:U \
  --network=host \
  postgres-timescale-pgvector \
  -c ssl=off -c port="$PGPORT" \
  -c shared_preload_libraries=timescaledb,pg_stat_statements

# The image restarts the server once during its first start, so readiness is a query that
# succeeds, not the first sign of life.
for _ in $(seq 120); do
  podman exec "$CONTAINER_NAME" psql -X -U "$POSTGRES_USER" -d "$POSTGRES_DB" -p "$PGPORT" -c 'SELECT 1' >/dev/null 2>&1 && {
    echo "postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:$PGPORT/$POSTGRES_DB"
    exit 0
  }
  sleep 1
done
echo "$CONTAINER_NAME did not answer on port $PGPORT; podman logs $CONTAINER_NAME" >&2
exit 1

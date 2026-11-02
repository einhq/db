# PostgreSQL 18 for EiN, with every extension it uses: TimescaleDB, pgvector, PostGIS and pg_trgm.
#
# Build:
#   podman build -t ein-db .
#
# On the same pinned Debian as EiN's other images (ein/core, ein/ems), so the layer is shared; the
# three bump it together. PostgreSQL, pgvector and PostGIS come from PostgreSQL's apt repository
# (apt.postgresql.org), TimescaleDB and timescaledb-tune from Timescale's (packagecloud.io), each at
# the newest release the build finds.
FROM docker.io/library/debian:trixie-20261027-slim

# The postgres user is 1000, as in the image this one replaced, so a data directory that one wrote
# starts here unchanged. The packages would otherwise make a system user of their own.
RUN groupadd --gid 1000 postgres \
 && useradd --uid 1000 --gid postgres --home-dir /home/postgres --create-home --shell /bin/bash postgres

# postgresql-common is set up first so that installing the server makes no cluster of its own: the
# entrypoint makes the one in PGDATA. curl fetches the repositories' keys and goes again.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl postgresql-common \
 && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
 && curl -fsSL -o /usr/share/keyrings/pgdg.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc \
 && curl -fsSL -o /usr/share/keyrings/timescaledb.asc https://packagecloud.io/timescale/timescaledb/gpgkey \
 && echo 'deb [signed-by=/usr/share/keyrings/pgdg.asc] https://apt.postgresql.org/pub/repos/apt trixie-pgdg main' >/etc/apt/sources.list.d/pgdg.list \
 && echo 'deb [signed-by=/usr/share/keyrings/timescaledb.asc] https://packagecloud.io/timescale/timescaledb/debian/ trixie main' >/etc/apt/sources.list.d/timescaledb.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    postgresql-18 \
    postgresql-18-pgvector \
    postgresql-18-postgis-3 \
    timescaledb-2-postgresql-18 \
    timescaledb-tools \
 && apt-get purge -y --auto-remove curl \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY NOTICE.md /usr/share/doc/ein-db/NOTICE.md

ENV PATH=/usr/lib/postgresql/18/bin:$PATH \
    PGDATA=/home/postgres/pgdata/data \
    LANG=C.UTF-8

# PGDATA exists and is postgres's, so a volume mounted there starts out postgres's too; psql and
# the server meet on the socket in /var/run/postgresql, the packages' default.
RUN mkdir -p "$PGDATA" /var/run/postgresql \
 && chown -R postgres:postgres /home/postgres /var/run/postgresql \
 && chmod 700 "$PGDATA" \
 && chmod 2775 /var/run/postgresql

USER postgres
EXPOSE 5432
# SIGINT is PostgreSQL's fast shutdown: open sessions are ended rather than waited for.
STOPSIGNAL SIGINT
ENTRYPOINT ["entrypoint.sh"]
CMD ["postgres"]

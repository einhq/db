# db

PostgreSQL for [EiN](https://github.com/einhq): the image and how to start it.

The image (`Containerfile`) is PostgreSQL 18 on Debian 13, the same pinned `debian:trixie-…-slim`
as EiN's other images, with every extension EiN uses: TimescaleDB, pgvector, PostGIS and pg_trgm.
PostgreSQL, pgvector and PostGIS come from PostgreSQL's apt repository, TimescaleDB from
Timescale's, at the newest release each has when the image is built. EiN creates the extensions in
its database, and updates them after a new image, itself. `NOTICE.md` names what it carries under
which licence — TimescaleDB's community features are under the Timescale License, PostGIS under the
GPL — and where the GPL parts' source is.

Its first start in an empty data directory makes the database: the role `POSTGRES_USER`, a
superuser with the password `POSTGRES_PASSWORD`, and the database `POSTGRES_DB`, with the settings
`timescaledb-tune` picks for the machine's memory and processors (or the container's memory limit)
and TimescaleDB's telemetry off. Connections over the network need the password; `psql` inside the
container does not.

## Running it

```bash
bash run.sh
```

builds the image, starts the container on the host's network and waits until it answers, then
prints the connection string EiN takes as `POSTGRES_URL`. Run it again to rebuild with the newest
PostgreSQL and extension releases and restart; the data stays.

| Variable            | Default               | What it sets                                     |
| ------------------- | --------------------- | ------------------------------------------------ |
| `PGDATA_HOST_PATH`  | `~/services/postgres` | where the data lives on the host (absolute path) |
| `PGPORT`            | `5432`                | the port                                         |
| `PG_CONTAINER_NAME` | `postgres`            | the container's name                             |
| `POSTGRES_USER`     | `ein`                 | the role EiN connects as, made on first start    |
| `POSTGRES_PASSWORD` | `ein`                 | its password                                     |
| `POSTGRES_DB`       | `ein`                 | the database                                     |

Two servers on one host need their own port and container name, and their own data directory.
The role is the server's superuser, which is what lets EiN create and update its extensions; the
defaults suit a machine nobody else reaches, so set a password of your own anywhere else.

## The cache across a restart

`pg_prewarm` is preloaded, and with it its autoprewarm worker: every five minutes it writes which
pages are in `shared_buffers` to `autoprewarm.blocks` in the data directory, and after a restart it
reads those pages back in the background. A vector search walks its index by random reads, so on a
cold cache the first searches read from disk for seconds; this puts the restarted server back where
it was within minutes, without waiting for searches to warm it.

## Profiling

`pg_stat_statements` is preloaded but not created. To see which statements the database spends
its time on:

```bash
podman exec -it postgres psql -U ein -d ein -c 'CREATE EXTENSION IF NOT EXISTS pg_stat_statements'
```

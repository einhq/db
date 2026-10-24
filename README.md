# db

PostgreSQL for [EiN](https://github.com/einhq): the image and how to start it.

The image (`Containerfile`) is TimescaleDB's PostgreSQL 18 image with pgvector added. It holds
every extension EiN uses — TimescaleDB, pgvector, PostGIS and pg_trgm — and EiN creates them in
its database, and updates them after a new image, itself.

## Running it

```bash
bash run.sh
```

builds the image, starts the container on the host's network and waits until it answers, then
prints the connection string EiN takes as `POSTGRES_URL`. Run it again to rebuild on the newest
base image and restart; the data stays.

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

## Profiling

`pg_stat_statements` is preloaded but not created. To see which statements the database spends
its time on:

```bash
podman exec -it postgres psql -U ein -d ein -c 'CREATE EXTENSION IF NOT EXISTS pg_stat_statements'
```

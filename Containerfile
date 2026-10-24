FROM docker.io/timescale/timescaledb-ha:pg18

USER root

RUN apt-get update \
 && apt-get install -y postgresql-18-pgvector \
 && rm -rf /var/lib/apt/lists/*

USER postgres

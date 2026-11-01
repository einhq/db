# What the image carries, and under which licences

The scripts in this repository are EiN's, under the MIT licence (`LICENSE`). The
image they build is someone else's work almost entirely: `Containerfile` takes
TimescaleDB's
[`timescale/timescaledb-ha:pg18`](https://github.com/timescale/timescaledb-docker-ha)
as it is and adds `postgresql-18-pgvector` from the PostgreSQL apt repository
(apt.postgresql.org) it is set up with. Everything in it keeps its own licence.
The parts an operator may want to know about:

| Part                                         | Licence                                                                                             | What it means here                                                                                                                                                                                    |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PostgreSQL 18                                | [PostgreSQL Licence](https://www.postgresql.org/about/licence/)                                     | Permissive.                                                                                                                                                                                           |
| TimescaleDB, Apache-2.0 part                 | [Apache-2.0](https://github.com/timescale/timescaledb/blob/main/LICENSE-APACHE)                     | Hypertables, which EiN's log uses.                                                                                                                                                                    |
| TimescaleDB, community part                  | [Timescale License (TSL)](https://github.com/timescale/timescaledb/blob/main/tsl/LICENSE-TIMESCALE) | EiN's log uses its retention and compression policies. The TSL allows running it yourself and building products on it; it forbids offering TimescaleDB itself to others as a hosted database service. |
| pgvector                                     | [PostgreSQL Licence](https://github.com/pgvector/pgvector/blob/master/LICENSE)                      | Permissive.                                                                                                                                                                                           |
| PostGIS 3.6, pgRouting                       | [GPL-2.0-or-later](https://git.osgeo.org/gitea/postgis/postgis/src/branch/master/COPYING)           | Present in the base image; EiN creates PostGIS for its positions and tracks. See below for the source.                                                                                                |
| Ubuntu 22.04's packages (GEOS, PROJ, GDAL …) | their own, many GPL or LGPL                                                                         | As Ubuntu ships them; their licences are in `/usr/share/doc/<package>/copyright` where the base image keeps them.                                                                                     |

## The GPL parts' source

This repository changes none of the GPL parts and builds none of them: they come
in the base image as TimescaleDB built them. Their source, at the versions the
image holds:

- PostGIS: the release tarballs at <https://download.osgeo.org/postgis/source/>,
  with the version the image holds in
  `/usr/share/postgresql/18/extension/postgis.control` (`default_version`);
- pgRouting: <https://github.com/pgRouting/pgrouting/releases>, by the version
  in `pgrouting.control`;
- how TimescaleDB builds them into the image:
  <https://github.com/timescale/timescaledb-docker-ha>;
- Ubuntu's packages: `apt-get source <package>` against Ubuntu 22.04 (jammy), or
  <https://launchpad.net/ubuntu/jammy>.

`ghcr.io/einhq/db`, the image GitHub builds from this repository, passes these
on unchanged.

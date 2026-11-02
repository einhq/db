# What the image carries, and under which licences

The scripts in this repository are EiN's, under the MIT licence (`LICENSE`). The
image they build is someone else's work almost entirely: `Containerfile`
installs PostgreSQL 18 and its extensions on Debian, unmodified, from
PostgreSQL's apt repository (apt.postgresql.org) and Timescale's
(packagecloud.io/timescale). Everything in it keeps its own licence. The image
holds this file as `/usr/share/doc/ein-db/NOTICE.md`. The parts an operator may
want to know about:

| Part                                                                  | Licence                                                                                             | What it means here                                                                                                                                                                                    |
| --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PostgreSQL 18, pg_trgm                                                | [PostgreSQL Licence](https://www.postgresql.org/about/licence/)                                     | Permissive.                                                                                                                                                                                           |
| TimescaleDB, Apache-2.0 part                                          | [Apache-2.0](https://github.com/timescale/timescaledb/blob/main/LICENSE-APACHE)                     | Hypertables, which EiN's log uses.                                                                                                                                                                    |
| TimescaleDB, community part                                           | [Timescale License (TSL)](https://github.com/timescale/timescaledb/blob/main/tsl/LICENSE-TIMESCALE) | EiN's log uses its retention and compression policies. The TSL allows running it yourself and building products on it; it forbids offering TimescaleDB itself to others as a hosted database service. |
| timescaledb-tune                                                      | [Apache-2.0](https://github.com/timescale/timescaledb-tune/blob/main/LICENSE)                       | Sizes a new database's settings to the machine, at its first start.                                                                                                                                   |
| pgvector                                                              | [PostgreSQL Licence](https://github.com/pgvector/pgvector/blob/master/LICENSE)                      | Permissive.                                                                                                                                                                                           |
| PostGIS 3                                                             | [GPL-2.0-or-later](https://git.osgeo.org/gitea/postgis/postgis/src/branch/master/COPYING)           | EiN creates PostGIS for its positions and tracks. See below for the source.                                                                                                                           |
| The libraries PostGIS uses (GEOS, PROJ, GDAL …) and Debian's packages | their own, many GPL or LGPL                                                                         | Each package's licence is in `/usr/share/doc/<package>/copyright`.                                                                                                                                    |

TimescaleDB's telemetry is off in a database the image makes.

## The GPL parts' source

The image changes none of the GPL parts and builds none of them: they come as
the repositories above publish them.

- PostgreSQL's apt repository's packages, PostGIS and the newer GEOS, PROJ and
  GDAL it builds against among them (their versions end in `pgdg13`): the source
  package beside each, in <https://apt.postgresql.org/pub/repos/apt/pool/main/>,
  or `apt-get source <package>` with its `deb-src` line; PostGIS's release
  tarballs are also at <https://download.osgeo.org/postgis/source/>.
- TimescaleDB: <https://github.com/timescale/timescaledb>, at the tag of the
  version `dpkg-query -W timescaledb-2-postgresql-18` shows.

## Debian

The image is built on Debian 13 (trixie) and carries Debian's packages unmodified, each under its
own licence, many of them the GPL or the LGPL; each package's is in
/usr/share/doc/<package>/copyright. `dpkg-query -W` in the image lists every package with its
version. Their source is Debian's, at https://sources.debian.org/ and, for the exact version, at
https://snapshot.debian.org/.

`ghcr.io/einhq/db`, the image GitHub builds from this repository, passes these
on unchanged.

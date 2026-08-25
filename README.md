# rpsql

<!-- badges: start -->
[![rcc](https://github.com/pachadotdev/rpsql/workflows/rcc/badge.svg)](https://github.com/pachadotdev/rpsql/actions)
[![Codecov test coverage](https://codecov.io/gh/pachadotdev/rpsql/branch/master/graph/badge.svg)](https://app.codecov.io/gh/pachadotdev/rpsql?branch=main)
[![CRAN status](https://www.r-pkg.org/badges/version/rpsql)](https://CRAN.R-project.org/package=rpsql)
<!-- badges: end -->

**IMPORTANT: THIS IS A VERY EARLY VERSION. I'VE PUT THIS HERE AS A BACKUP. DON'T USE IT YET.**

This does not work with [Amazon Redshift](https://en.wikipedia.org/wiki/Amazon_Redshift) as it has unique features not covered here.

This is a rewrite of RPostgres that uses [cpp4r](https://github.com/pachadotdev/cpp4r) and simplifies a few things:

* No 'Collate' field in the DESCRIPTION.
* Unit tests ported to tinytest.
* Reduced dependencies.

[RPostgres](https://github.com/r-dbi/RPostgres) is an DBI-compliant interface to the postgres database. It's a ground-up rewrite using C++ and [cpp11](https://github.com/r-lib/cpp11). Compared to RPostgreSQL, it:

* Has full support for parameterised queries via `dbSendQuery()`, and `dbBind()`.
* Automatically cleans up open connections and result sets, ensuring that you
  don't need to worry about leaking connections or memory.
* Is a little faster, saving ~5 ms per query. (For reference, it takes around 5ms
  to retrieve a 1000 x 25 result set from a local database, so this is 
  decent speed up for smaller queries.)
* A simplified build process that relies on system libpq.

## Installation

```R
# Install the latest rpsql release from CRAN:
install.packages("rpsql")

# Or the the development version from GitHub:
# install.packages("remotes")
remotes::install_github("pachadotdev/rpsql")
```

Discussions associated with DBI and related database packages take place on [R-SIG-DB](https://stat.ethz.ch/mailman/listinfo/r-sig-db). 
The website [Databases using R](https://db.rstudio.com/) describes the tools and best practices in this ecosystem.

## Basic usage

```R
library(DBI)
# Connect to the default postgres database
con <- dbConnect(rpsql::Postgres())

dbListTables(con)
dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)

dbListFields(con, "mtcars")
dbReadTable(con, "mtcars")

# You can fetch all results:
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
dbFetch(res)
dbClearResult(res)

# Or a chunk at a time
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
while(!dbHasCompleted(res)){
  chunk <- dbFetch(res, n = 5)
  print(nrow(chunk))
}
# Clear the result
dbClearResult(res)

# Disconnect from the database
dbDisconnect(con)
```
## Connecting to a specific Postgres instance

```R
library(DBI)
# Connect to a specific postgres database i.e. Heroku
con <- dbConnect(rpsql::Postgres(),dbname = 'DATABASE_NAME', 
                 host = 'HOST', # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'
                 port = 5432, # or any other port specified by your DBA
                 user = 'USERNAME',
                 password = 'PASSWORD')

```

## Design notes

The original DBI design imagined that each package could instantiate X drivers, with each driver having Y connections and each connection having Z results. This turns out to be too general: a driver has no real state, for PostgreSQL each connection can only have one result set. In the rpsql package there's only one class on the C side: a connection, which optionally contains a result set. On the R side, the driver class is just a dummy class with no contents (used only for dispatch), and both the connection and result objects point to the same external pointer.

---

Please note that the 'rpsql' project is released with a
[Contributor Code of Conduct](https://github.com/pachadotdev/rpsql/blob/main/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.

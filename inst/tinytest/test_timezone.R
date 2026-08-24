source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# timestamp without time zone is returned correctly for TZ set
old_tz <- Sys.getenv("TZ", unset = NA)
Sys.setenv(TZ = "America/Chicago")
query <- "SELECT '2018-01-01 12:30:00'::TIMESTAMP AS a, '2018-01-01 12:30:00'::TIMESTAMPTZ AS b"
db <- postgresDefault(timezone = NULL)
res <- dbGetQuery(db, query)
expect_equal(res[[1]], res[[2]])
dbDisconnect(db)
db <- postgresDefault(timezone = "UTC")
expect_equal(
  dbGetQuery(db, query)[[1]],
  as.POSIXct("2018-01-01 12:30:00", tz = "UTC")
)
dbDisconnect(db)
db <- postgresDefault(timezone = "America/Chicago")
expect_equal(
  dbGetQuery(db, query)[[1]],
  as.POSIXct("2018-01-01 12:30:00", tz = "America/Chicago")
)
dbDisconnect(db)
db <- postgresDefault(timezone = "America/New_York")
expect_equal(
  dbGetQuery(db, query)[[1]],
  as.POSIXct("2018-01-01 12:30:00", tz = "America/New_York")
)
dbDisconnect(db)
db <- postgresDefault(timezone = "Europe/London")
expect_equal(
  dbGetQuery(db, query)[[1]],
  as.POSIXct("2018-01-01 12:30:00", tz = "Europe/London")
)
dbDisconnect(db)
db <- postgresDefault(timezone = "Europe/Zurich")
expect_equal(
  dbGetQuery(db, query)[[1]],
  as.POSIXct("2018-01-01 12:30:00", tz = "Europe/Zurich")
)
dbDisconnect(db)
if (is.na(old_tz)) Sys.unsetenv("TZ") else Sys.setenv(TZ = old_tz)

# timestamp with time zone is returned correctly
old_tz2 <- Sys.getenv("TZ", unset = NA)
Sys.setenv(TZ = "America/New_York")
con <- postgresDefault(timezone = "America/Chicago")
dbExecute(con, "CREATE TEMPORARY TABLE junk AS (SELECT '2020-05-04'::TIMESTAMPTZ AS ts)")
res <- dbGetQuery(con, "SELECT * FROM junk")
expect_equal(res[[1]], as.POSIXct("2020-05-04", tz = "America/Chicago"))
dbDisconnect(con)
if (is.na(old_tz2)) Sys.unsetenv("TZ") else Sys.setenv(TZ = old_tz2)

# timestamp with time zone is returned correctly for time zones
con <- postgresDefault(timezone = "Europe/Zurich", timezone_out = "UTC")
res <- dbGetQuery(con, "SELECT '1970-01-01 12:00:00+00:00'::TIMESTAMPTZ AS ts")
expect_equal(res[[1]], as.POSIXct("1970-01-01 12:00:00", tz = "UTC"))
dbDisconnect(con)

# timestamp with time zone is returned correctly for half-hour time zones
con <- postgresDefault(timezone = "Asia/Calcutta", timezone_out = "UTC")
res <- dbGetQuery(con, "SELECT '1970-01-01 12:00:00+00:00'::TIMESTAMPTZ AS ts")
expect_equal(res[[1]], as.POSIXct("1970-01-01 12:00:00", tz = "UTC"))
dbDisconnect(con)

# timestamp without time zone is returned correctly before epoch
con <- postgresDefault()
out <- dbGetQuery(con, "SELECT CAST('1960-01-01 12:00:00' AS timestamp) AS before_epoch")
expect_equal(as.Date(out[[1]]), as.Date("1960-01-01"))
dbDisconnect(con)

# timezone is passed on to the connection
my_tz <- "US/Alaska"
con <- postgresDefault(timezone = my_tz)
example <- data.frame(val = 0:71)
example$ts <- as.POSIXct("2019-04-30 00:00:00", tz = my_tz) + example$val * 3600
dbWriteTable(con, "example", example, temporary = TRUE, overwrite = TRUE, append = FALSE)
res <- dbReadTable(con, "example")
expect_equal(res, example)
query <- "
  SELECT date(ts) AS dte, MIN(val) AS min_val, MAX(val) AS max_val
  FROM example
  GROUP BY dte
  ORDER BY dte"
expected <- data.frame(
  dte = as.Date("2019-04-30") + 0:2,
  min_val = 0:2 * 24,
  max_val = 0:2 * 24 + 23
)
expect_equal(dbGetQuery(con, query), expected)
dbDisconnect(con)

# warning if time zone not interpretable
expect_warning(con <- postgresDefault(timezone = "+01:00"))
expect_equal(con@timezone, "")
dbDisconnect(con)
expect_warning(con <- postgresDefault(timezone_out = "+01:00"))
expect_equal(con@timezone_out, "")
dbDisconnect(con)

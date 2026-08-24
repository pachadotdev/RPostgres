
source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# bigint: integer
con <- postgresDefault(bigint = "integer")
expect_identical(
  dbGetQuery(con, "SELECT COUNT(*) FROM (SELECT 1) A")[[1]],
  1L
)
dbDisconnect(con)

# bigint: numeric
con <- postgresDefault(bigint = "numeric")
expect_identical(
  dbGetQuery(con, "SELECT COUNT(*) FROM (SELECT 1) A")[[1]],
  1.0
)
dbDisconnect(con)

# bigint: character
con <- postgresDefault(bigint = "character")
expect_identical(
  dbGetQuery(con, "SELECT COUNT(*) FROM (SELECT 1) A")[[1]],
  "1"
)
dbDisconnect(con)

# dbDataType works on a data frame
con <- postgresDefault()
df <- data.frame(x = 1:10, y = 1:10 / 2)
expect_equal(dbDataType(con, df), c(x = "INTEGER", y = "DOUBLE PRECISION"))
dbDisconnect(con)

# can manipulate classes
expect_true(inherits(rpsql:::set_class(1, "A"), "A"))

# dbColumnInfo knows about typnames
con <- postgresDefault()
rs <- dbSendQuery(con, "SELECT 1 as a, '[1,2,3]'::json as js")
expect_equal(dbColumnInfo(rs)[[".typname"]], c("int4", "json"))
res <- dbFetch(rs)
expect_true(inherits(res$js, "pq_json"))
dbClearResult(rs)
dbDisconnect(con)



source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

con <- postgresDefault()

# dbQuoteLiteral works for character
expect_equal(dbQuoteLiteral(con, "a"), DBI::SQL("'a'"))
expect_equal(dbQuoteLiteral(con, "a'b"), DBI::SQL("'a''b'"))
expect_equal(dbQuoteLiteral(con, NA_character_), DBI::SQL("NULL"))

# dbQuoteLiteral works for numeric
expect_equal(dbQuoteLiteral(con, 1.5), DBI::SQL("1.5"))
expect_equal(dbQuoteLiteral(con, NA_real_), DBI::SQL("NULL"))
expect_equal(dbQuoteLiteral(con, Inf), DBI::SQL("'Inf'::float8"))
expect_equal(dbQuoteLiteral(con, -Inf), DBI::SQL("'-Inf'::float8"))
expect_equal(dbQuoteLiteral(con, NaN), DBI::SQL("'NaN'::float8"))

# dbQuoteLiteral works for integer
expect_equal(dbQuoteLiteral(con, 1L), DBI::SQL("1"))
expect_equal(dbQuoteLiteral(con, NA_integer_), DBI::SQL("NULL"))

# dbQuoteLiteral works for logical
expect_equal(dbQuoteLiteral(con, TRUE), DBI::SQL("TRUE"))
expect_equal(dbQuoteLiteral(con, FALSE), DBI::SQL("FALSE"))
expect_equal(dbQuoteLiteral(con, NA), DBI::SQL("NULL"))

# dbQuoteLiteral works for Date
expect_equal(
  dbQuoteLiteral(con, as.Date("2021-01-01")),
  DBI::SQL("'2021-01-01'::date")
)
expect_equal(dbQuoteLiteral(con, as.Date(NA)), DBI::SQL("NULL::date"))

# dbQuoteLiteral works for POSIXct
ts <- as.POSIXct("2021-01-01 12:00:00", tz = "UTC")
expect_equal(
  dbQuoteLiteral(con, ts),
  DBI::SQL("'2021-01-01 12:00:00'::timestamptz")
)

dbDisconnect(con)

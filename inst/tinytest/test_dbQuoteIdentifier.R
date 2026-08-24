source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# dbQuoteIdentifier works for character
con <- postgresDefault()
expect_equal(dbQuoteIdentifier(con, "x"), DBI::SQL('"x"'))
expect_equal(dbQuoteIdentifier(con, "x y"), DBI::SQL('"x y"'))
expect_equal(dbQuoteIdentifier(con, 'x"y'), DBI::SQL('"x""y"'))
dbDisconnect(con)

# dbQuoteIdentifier works for SQL
con <- postgresDefault()
expect_equal(
  dbQuoteIdentifier(con, DBI::SQL("SELECT 1")),
  DBI::SQL("SELECT 1")
)
dbDisconnect(con)

# dbQuoteIdentifier works for Id
con <- postgresDefault()
expect_equal(
  dbQuoteIdentifier(con, DBI::Id(table = "foo")),
  DBI::SQL('"foo"')
)
expect_equal(
  dbQuoteIdentifier(con, DBI::Id(schema = "myschema", table = "foo")),
  DBI::SQL('"myschema"."foo"')
)
dbDisconnect(con)

# dbUnquoteIdentifier works
con <- postgresDefault()
expect_equal(
  dbUnquoteIdentifier(con, DBI::SQL('"foo"')),
  list(DBI::Id(table = "foo"))
)
expect_equal(
  dbUnquoteIdentifier(con, DBI::SQL('"myschema"."foo"')),
  list(DBI::Id(schema = "myschema", table = "foo"))
)
dbDisconnect(con)

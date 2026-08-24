source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# isTransacting detects transactions correctly
con <- postgresDefault()
expect_false(postgresIsTransacting(con))
dbBegin(con)
expect_true(postgresIsTransacting(con))
dbCommit(con)
expect_false(postgresIsTransacting(con))

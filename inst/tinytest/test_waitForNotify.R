source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# WaitForNotify without anything to do returns NULL
db <- postgresDefault()
n <- postgresWaitForNotify(db, 1)
expect_null(n)
dbDisconnect(db)

# WaitForNotify with a waiting message returns message
db <- postgresDefault()
dbExecute(db, "LISTEN grapevine")
dbExecute(db, "NOTIFY grapevine, 'psst'")
n <- postgresWaitForNotify(db, 1)
expect_identical(n$payload, "psst")
dbDisconnect(db)

source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# check_interrupts = TRUE works with short queries
con <- postgresDefault(check_interrupts = TRUE)
time <- system.time(
  expect_equal(dbGetQuery(con, "SELECT pg_sleep(0.2), 'foo' AS x")$x, "foo")
)
expect_true(time[["elapsed"]] < 0.9)
dbDisconnect(con)

# check_interrupts = TRUE works with longer queries
con <- postgresDefault(check_interrupts = TRUE)
time <- system.time(
  expect_equal(dbGetQuery(con, "SELECT pg_sleep(2), 'foo' AS x")$x, "foo")
)
expect_true(time[["elapsed"]] > 1.5)
dbDisconnect(con)

# check_interrupts = FALSE works normally
con <- postgresDefault(check_interrupts = FALSE)
expect_equal(dbGetQuery(con, "SELECT 1 AS x")$x, 1L)
dbDisconnect(con)

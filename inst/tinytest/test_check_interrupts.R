source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# check_interrupts = TRUE works with queries < 1 second
con <- postgresDefault(check_interrupts = TRUE)
time <- system.time(
  expect_equal(dbGetQuery(con, "SELECT pg_sleep(0.2), 'foo' AS x")$x, "foo")
)
expect_true(time[["elapsed"]] < 0.9)
dbDisconnect(con)

# check_interrupts = TRUE works with queries > 1 second
con <- postgresDefault(check_interrupts = TRUE)
time <- system.time(
  expect_equal(dbGetQuery(con, "SELECT pg_sleep(2), 'foo' AS x")$x, "foo")
)
expect_true(time[["elapsed"]] > 1.5)
dbDisconnect(con)

# check_interrupts = TRUE interrupts immediately
if (!is.na(Sys.getenv("R_COVR", unset = NA)) && Sys.getenv("R_COVR") != "") {
  exit_file("Skipping interrupt test under code coverage")
}
if (!requireNamespace("callr", quietly = TRUE)) {
  exit_file("callr not available")
}

session <- callr::r_session$new()
session$supervise(TRUE)
session$run(function() {
  library(rpsql)
  .GlobalEnv$conn <- postgresDefault(check_interrupts = TRUE)
  .GlobalEnv$connPid <- DBI::dbGetQuery(
    .GlobalEnv$conn,
    "SELECT pg_backend_pid() AS pid"
  )$pid
  .GlobalEnv$checkConn <- postgresDefault()
  invisible()
})
session$call(function() {
  DBI::dbGetQuery(.GlobalEnv$conn, "SELECT pg_sleep(10)")
})
expect_equal(session$poll_process(500), "timeout")
session$interrupt()
expect_equal(session$poll_process(2000), "ready")
session$read()
queryStatus <- session$run(function() {
  DBI::dbGetQuery(
    .GlobalEnv$checkConn,
    "SELECT state FROM pg_stat_activity WHERE pid = $1",
    params = .GlobalEnv$connPid
  )
})
expect_equal(queryStatus$state, "idle")
session$close()

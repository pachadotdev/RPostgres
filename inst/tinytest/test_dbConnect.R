source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# querying closed connection throws error
db <- postgresDefault()
dbDisconnect(db)
expect_error(dbSendQuery(db, "select * from foo"), pattern = "bad_weak_ptr")

# warn if previous result set is invalidated
con <- postgresDefault()
rs1 <- dbSendQuery(con, "SELECT 1 + 1")
expect_warning(
  rs2 <- dbSendQuery(con, "SELECT 1 + 1"),
  pattern = "Closing open result set, cancelling previous query"
)
expect_false(dbIsValid(rs1))
dbClearResult(rs2)
dbDisconnect(con)

# no warning if previous result set is closed
con <- postgresDefault()
rs1 <- dbSendQuery(con, "SELECT 1 + 1")
dbClearResult(rs1)
rs2 <- dbSendQuery(con, "SELECT 1 + 1")
dbClearResult(rs2)
dbDisconnect(con)

# warning if close connection with open results
con <- postgresDefault()
rs1 <- dbSendQuery(con, "SELECT 1 + 1")
expect_warning(dbDisconnect(con), pattern = "still in use")
dbClearResult(rs1)

# passing other options parameters
con <- postgresDefault(application_name = "apple")
pid <- dbGetInfo(con)$pid
r <- dbGetQuery(
  con,
  "SELECT application_name FROM pg_stat_activity WHERE pid=$1",
  list(pid)
)
expect_identical(r$application_name, "apple")
dbDisconnect(con)

# error if passing unknown parameters
expect_error(
  dbConnect(Postgres(), fruit = "apple"),
  pattern = 'invalid connection option "fruit"'
)

# NOTICEs are captured as messages
con <- postgresDefault()
expect_message(
  DBI::dbExecute(
    con,
    "DO language plpgsql $$
      BEGIN
        RAISE NOTICE 'hello, world!';
      END
    $$;"
  ),
  pattern = "hello, world"
)
dbDisconnect(con)

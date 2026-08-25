source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# two statements
conn1 <- postgresDefault()
sql <- "
DO
$$
BEGIN
  RAISE NOTICE 'message_one';
END
$$
;
DO
$$
BEGIN
  RAISE NOTICE 'message_two';
END
$$
;
"
msgs <- character(0)
withCallingHandlers(
  dbExecute(conn1, sql, immediate = TRUE),
  message = function(m) {
    msgs <<- c(msgs, conditionMessage(m))
    invokeRestart("muffleMessage")
  }
)
expect_true(any(grepl("message_one", msgs)))
expect_true(any(grepl("message_two", msgs)))
dbDisconnect(conn1)

# two statements with dbGetRowsAffected()
conn1 <- postgresDefault()
dbWriteTable(conn1, "test", data.frame(a = 1:9), temporary = TRUE)
sql <- "DELETE FROM TEST WHERE a < 3; DELETE FROM TEST WHERE a < 6"
expect_equal(dbExecute(conn1, sql, immediate = TRUE), 5)
expect_equal(nrow(dbReadTable(conn1, "test")), 4)
dbDisconnect(conn1)

# two queries
conn1 <- postgresDefault()
sql <- "SELECT 1 AS a UNION ALL SELECT 2 AS a; SELECT 3 AS a"
expect_equal(dbGetQuery(conn1, sql, immediate = TRUE), data.frame(a = 1:3))
sql <- "SELECT 1 AS a, 2 AS b UNION ALL SELECT 2 AS a, 3 AS b; SELECT 3 AS b"
expect_error(dbGetQuery(conn1, sql, immediate = TRUE), pattern = "names")
sql <- "SELECT 1 AS a; SELECT '2' AS a"
expect_error(dbGetQuery(conn1, sql, immediate = TRUE), pattern = "types")
dbDisconnect(conn1)

# query and statement
conn1 <- postgresDefault()
sql <- "
SELECT 1 AS a;
DO
$$
BEGIN
  RAISE NOTICE 'message_one';
END
$$
"
expect_message(
  expect_equal(dbGetQuery(conn1, sql, immediate = TRUE), data.frame(a = 1L)),
  pattern = "message_one"
)
dbDisconnect(conn1)

# statement and query
conn1 <- postgresDefault()
sql <- "
DO
$$
BEGIN
  RAISE NOTICE 'message_one';
END
$$;
SELECT 1 AS a
"
expect_message(
  expect_equal(dbGetQuery(conn1, sql, immediate = TRUE), data.frame(a = 1L)),
  pattern = "message_one"
)
dbDisconnect(conn1)

# immediate queries after COPY
conn1 <- postgresDefault()
dbCreateTable(conn1, "test", data.frame(a = integer()), temporary = TRUE)
dbAppendTable(conn1, "test", data.frame(a = 1:3), copy = TRUE)
dbExecute(conn1, "DROP TABLE pg_temp.test", immediate = TRUE)
dbDisconnect(conn1)

source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

con <- postgresDefault()

# writing to a database table is successful
with_table(con, "beaver2", {
  dbWriteTable(con, "beaver2", beaver2, temporary = TRUE)
  expect_equal(dbReadTable(con, "beaver2"), beaver2)
})

# writing to a database table with character features is successful
with_table(con, "iris", {
  iris2 <- transform(iris, Species = as.character(Species))
  dbWriteTable(con, "iris", iris2, temporary = TRUE)
  expect_equal(dbReadTable(con, "iris"), iris2)
})

# append to a database table is successful
with_table(con, "beaver2", {
  dbWriteTable(con, "beaver2", beaver2, temporary = TRUE)
  dbWriteTable(con, "beaver2", beaver2, append = TRUE, temporary = TRUE)
  expect_equal(dbReadTable(con, "beaver2"), rbind(beaver2, beaver2))
})

# append to a database table with character features is successful
with_table(con, "iris", {
  iris2 <- transform(iris, Species = as.character(Species))
  dbWriteTable(con, "iris", iris2, temporary = TRUE)
  dbWriteTable(con, "iris", iris2, append = TRUE, temporary = TRUE)
  expect_equal(dbReadTable(con, "iris"), rbind(iris2, iris2))
})

# new table creation respects the field.types argument
with_table(con, "iris", {
  iris2 <- transform(
    iris,
    Petal.Width = as.integer(Petal.Width),
    Species = as.character(Species)
  )
  field.types <- c("real", "double precision", "numeric", "bigint", "text")
  names(field.types) <- names(iris2)
  dbWriteTable(con, "iris", iris2, field.types = field.types, temporary = TRUE)
  iris3 <- transform(iris2, Petal.Width = bit64::as.integer64(Petal.Width))
  expect_equal(dbReadTable(con, "iris"), iris3)
  types <- DBI::dbGetQuery(
    con,
    paste(
      "select column_name, data_type from information_schema.columns",
      "where table_name = 'iris'"
    )
  )
  expected <- data.frame(
    column_name = colnames(iris2),
    data_type = field.types,
    stringsAsFactors = FALSE
  )
  types <- without_rownames(types[order(types$column_name), ])
  expected <- without_rownames(expected[order(expected$column_name), ])
  expect_equal(types, expected)
})

# appending fails when using the field.types argument
with_table(con, "iris", {
  iris2 <- transform(
    iris,
    Petal.Width = as.integer(Petal.Width),
    Species = as.character(Species)
  )
  field.types <- c("real", "double precision", "numeric", "bigint", "text")
  names(field.types) <- names(iris2)
  dbWriteTable(con, "iris", iris2, field.types = field.types, temporary = TRUE)
  expect_error(
    dbWriteTable(
      con, "iris", iris2,
      field.types = field.types, append = TRUE, temporary = TRUE
    ),
    pattern = "field[.]types"
  )
})

# precision: dbWriteTable(copy = FALSE)
value <- data.frame(x = -0.000064925595060641, y = -0.00006492559506064059)
with_table(con, "xy", {
  dbWriteTable(con, name = "xy", value = value, copy = FALSE)
  expect_equal(dbGetQuery(con, "SELECT * FROM xy"), value)
})

# precision: dbWriteTable(append = TRUE, copy = FALSE)
with_table(con, "xy", {
  dbExecute(con, "CREATE TEMPORARY TABLE xy (x numeric NOT NULL, y numeric NOT NULL);")
  dbWriteTable(con, name = "xy", value = value, append = TRUE, copy = FALSE)
  expect_equal(dbGetQuery(con, "SELECT * FROM xy"), value)
})

# precision: dbWriteTable(append = TRUE, copy = TRUE)
with_table(con, "xy", {
  dbExecute(con, "CREATE TEMPORARY TABLE xy (x numeric NOT NULL, y numeric NOT NULL);")
  dbWriteTable(con, name = "xy", value = value, append = TRUE, copy = TRUE)
  expect_equal(dbGetQuery(con, "SELECT * FROM xy"), value)
})

# precision: dbWriteTable(copy = TRUE, field.types = NUMERIC)
with_table(con, "xy", {
  dbWriteTable(
    con, name = "xy", value = value,
    overwrite = FALSE, append = FALSE, copy = TRUE,
    field.types = c(x = "NUMERIC", y = "NUMERIC")
  )
  expect_equal(dbGetQuery(con, "SELECT * FROM xy"), value)
})

# Inf values come back correctly
res <- dbGetQuery(
  con,
  "SELECT '-inf'::float8 AS a, '+inf'::float8 AS b, 'NaN'::float8 AS c, NULL::float8 AS d"
)
expect_equal(res$a, -Inf)
expect_equal(res$b, Inf)
expect_true(is.nan(res$c))
expect_true(is.na(res$d))
expect_false(is.nan(res$d))

# Inf values are roundtripped correctly
with_table(con, "xy", {
  data <- data.frame(
    column_1 = c("A", "B", "C"),
    column_2 = c(1, Inf, 3),
    stringsAsFactors = FALSE
  )
  dbWriteTable(con, "xy", data, row.names = FALSE)
  expect_equal(data, dbReadTable(con, "xy"))
})

# can write to temporary table if permanent table exists
dbWriteTable(con, "my_name_clash", data.frame(a = 1), overwrite = TRUE)
expect_equal(dbReadTable(con, "my_name_clash"), data.frame(a = 1))
dbWriteTable(con, "my_name_clash", data.frame(b = 2), overwrite = TRUE, temporary = TRUE)
expect_equal(dbReadTable(con, "my_name_clash"), data.frame(b = 2))
dbRemoveTable(con, "my_name_clash", temporary = TRUE)
expect_equal(dbReadTable(con, "my_name_clash"), data.frame(a = 1))
dbRemoveTable(con, "my_name_clash")
dbDisconnect(con)

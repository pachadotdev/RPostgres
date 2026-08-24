with_table <- function(con, tbl, expr) {
  on.exit(try(DBI::dbRemoveTable(con, tbl), silent = TRUE), add = TRUE)
  force(expr)
}

without_rownames <- function(df) {
  row.names(df) <- NULL
  df
}

tt_data <- function(...) {
  system.file("tinytest/data", ..., package = "rpsql", mustWork = TRUE)
}

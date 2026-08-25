#' @title PostgreSQL tables
#' @description [dbAppendTable()] is overridden because \pkg{rpsql}
#' uses placeholders of the form `$1`, `$2` etc. instead of `?`.
#' @param row.names Must be `NULL`.
#' @name postgres-tables
#' @usage \S4method{dbAppendTable}{PqConnection}(conn, name, value, copy = NULL, ..., row.names = NULL)
dbAppendTable_PqConnection <- function(
  conn,
  name,
  value,
  copy = NULL,
  ...,
  row.names = NULL
) {
  stopifnot(is.null(row.names))
  stopifnot(is.data.frame(value))
  db_append_table(conn, name, value, copy = copy, warn = TRUE)
}

#' @rdname postgres-tables
#' @aliases dbAppendTable,PqConnection-method
#' @export
setMethod("dbAppendTable", "PqConnection", dbAppendTable_PqConnection)

#' @rdname postgres-tables
#' @usage NULL
dbExistsTable_PqConnection <- function(conn, name, ...) {
  if (inherits(name, "Id")) {
    exists_table(conn, id = name)
  } else {
    stopifnot(length(name) == 1L)
    quoted <- dbQuoteIdentifier(conn, name)
    id <- dbUnquoteIdentifier(conn, quoted)[[1]]
    exists_table(conn, id)
  }
}

#' @rdname postgres-tables
#' @export
setMethod("dbExistsTable", signature("PqConnection", "character"), dbExistsTable_PqConnection)
setMethod("dbExistsTable", signature("PqConnection", "Id"), dbExistsTable_PqConnection)

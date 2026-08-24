#' @rdname postgres-tables
#' @usage NULL
dbListFields_PqConnection <- function(conn, name, ...) {
  if (inherits(name, "Id")) {
    list_fields(conn, id = name)
  } else {
    quoted <- dbQuoteIdentifier(conn, name)
    id <- dbUnquoteIdentifier(conn, quoted)[[1]]
    list_fields(conn, id)
  }
}

#' @rdname postgres-tables
#' @export
setMethod("dbListFields", signature("PqConnection", "character"), dbListFields_PqConnection)
setMethod("dbListFields", signature("PqConnection", "Id"), dbListFields_PqConnection)

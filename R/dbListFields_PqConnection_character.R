#' @rdname postgres-tables
#' @usage \S4method{dbListFields}{PqConnection,character}(conn, name, ...)
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
#' @aliases dbListFields,PqConnection,character-method dbListFields,PqConnection,Id-method
#' @export
setMethod("dbListFields", signature("PqConnection", "character"), dbListFields_PqConnection)
setMethod("dbListFields", signature("PqConnection", "Id"), dbListFields_PqConnection)

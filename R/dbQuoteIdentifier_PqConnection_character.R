#' @title PostgreSQL quote
#' @rdname quote
#' @usage NULL
dbQuoteIdentifier_PqConnection <- function(conn, x, ...) {
  if (inherits(x, "SQL")) {
    x
  } else if (inherits(x, "Id")) {
    SQL(paste0(dbQuoteIdentifier(conn, x@name), collapse = "."))
  } else {
    if (anyNA(x)) {
      stop("Cannot pass NA to dbQuoteIdentifier()", call. = FALSE)
    }
    SQL(connection_quote_identifier(conn@ptr, x), names = names(x))
  }
}

#' @rdname quote
#' @export
setMethod("dbQuoteIdentifier", signature("PqConnection", "character"), dbQuoteIdentifier_PqConnection)
setMethod("dbQuoteIdentifier", signature("PqConnection", "SQL"), dbQuoteIdentifier_PqConnection)
setMethod("dbQuoteIdentifier", signature("PqConnection", "Id"), dbQuoteIdentifier_PqConnection)

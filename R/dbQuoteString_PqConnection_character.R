#' @rdname quote
#' @usage \S4method{dbQuoteString}{PqConnection,character}(conn, x, ...)
dbQuoteString_PqConnection <- function(conn, x, ...) {
  if (inherits(x, "SQL")) return(x)
  if (length(x) == 0) {
    return(SQL(character()))
  }
  out <- connection_quote_string(conn@ptr, enc2utf8(x))
  SQL(out)
}

#' @rdname quote
#' @aliases dbQuoteString,PqConnection,character-method dbQuoteString,PqConnection,SQL-method
#' @export
setMethod("dbQuoteString", signature("PqConnection", "character"), dbQuoteString_PqConnection)
setMethod("dbQuoteString", signature("PqConnection", "SQL"), dbQuoteString_PqConnection)

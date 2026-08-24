#' @rdname quote
#' @usage NULL
dbQuoteString_PqConnection <- function(conn, x, ...) {
  if (inherits(x, "SQL")) return(x)
  if (length(x) == 0) {
    return(SQL(character()))
  }
  out <- connection_quote_string(conn@ptr, enc2utf8(x))
  SQL(out)
}

#' @rdname quote
#' @export
setMethod("dbQuoteString", signature("PqConnection", "character"), dbQuoteString_PqConnection)
setMethod("dbQuoteString", signature("PqConnection", "SQL"), dbQuoteString_PqConnection)

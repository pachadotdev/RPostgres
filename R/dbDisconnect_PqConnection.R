# dbDisconnect() (after dbConnect() to maintain order in documentation)
#' @rdname Postgres
#' @usage \S4method{dbDisconnect}{PqConnection}(conn, ...)
dbDisconnect_PqConnection <- function(conn, ...) {
  connection_release(conn@ptr)
  invisible(TRUE)
}

#' @rdname Postgres
#' @aliases dbDisconnect,PqConnection-method
#' @export
setMethod("dbDisconnect", "PqConnection", dbDisconnect_PqConnection)

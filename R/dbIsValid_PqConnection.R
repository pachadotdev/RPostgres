# dbIsValid()
#' @rdname PqConnection-class
#' @usage NULL
dbIsValid_PqConnection <- function(dbObj, ...) {
  connection_valid(dbObj@ptr)
}

#' @rdname PqConnection-class
#' @aliases dbIsValid,PqConnection-method
#' @export
setMethod("dbIsValid", "PqConnection", dbIsValid_PqConnection)

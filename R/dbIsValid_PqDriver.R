#' @rdname PqDriver-class
#' @usage NULL
dbIsValid_PqDriver <- function(dbObj, ...) {
  TRUE
}

#' @rdname PqDriver-class
#' @aliases dbIsValid,PqDriver-method
#' @export
setMethod("dbIsValid", "PqDriver", dbIsValid_PqDriver)

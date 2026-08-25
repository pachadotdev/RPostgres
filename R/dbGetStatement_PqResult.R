#' @rdname PqResult-class
#' @usage NULL
dbGetStatement_PqResult <- function(res, ...) {
  if (!dbIsValid(res)) {
    stop("Invalid result set.", call. = FALSE)
  }
  res@sql
}

#' @rdname PqResult-class
#' @aliases dbGetStatement,PqResult-method
#' @export
setMethod("dbGetStatement", "PqResult", dbGetStatement_PqResult)

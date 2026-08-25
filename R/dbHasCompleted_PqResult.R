#' @rdname postgres-query
#' @usage \S4method{dbHasCompleted}{PqResult}(res, ...)
dbHasCompleted_PqResult <- function(res, ...) {
  result_has_completed(res@ptr)
}

#' @rdname postgres-query
#' @aliases dbHasCompleted,PqResult-method
#' @export
setMethod("dbHasCompleted", "PqResult", dbHasCompleted_PqResult)

#' @rdname PqResult-class
#' @usage NULL
dbGetRowsAffected_PqResult <- function(res, ...) {
  result_rows_affected(res@ptr)
}

#' @rdname PqResult-class
#' @aliases dbGetRowsAffected,PqResult-method
#' @export
setMethod("dbGetRowsAffected", "PqResult", dbGetRowsAffected_PqResult)

#' @rdname PqResult-class
#' @usage NULL
dbGetRowCount_PqResult <- function(res, ...) {
  result_rows_fetched(res@ptr)
}

#' @rdname PqResult-class
#' @aliases dbGetRowCount,PqResult-method
#' @export
setMethod("dbGetRowCount", "PqResult", dbGetRowCount_PqResult)

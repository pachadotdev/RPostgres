#' @rdname postgres-query
#' @usage \S4method{dbClearResult}{PqResult}(res, ...)
dbClearResult_PqResult <- function(res, ...) {
  if (!dbIsValid(res)) {
    warningc("Expired, result set already closed")
    return(invisible(TRUE))
  }
  result_release(res@ptr)
  invisible(TRUE)
}

#' @rdname postgres-query
#' @aliases dbClearResult,PqResult-method
#' @export
setMethod("dbClearResult", "PqResult", dbClearResult_PqResult)

#' @title PostgreSQL query
#' @rdname postgres-query
#' @usage \S4method{dbBind}{PqResult}(res, params, ...)
dbBind_PqResult <- function(res, params, ...) {
  if (!is.null(names(params))) {
    stopc("`params` must not be named.")
  }
  if (!is.list(params)) {
    params <- as.list(params)
  }

  params <- factor_to_string(params, warn = TRUE)
  params <- fix_posixt(params, res@conn@timezone)
  params <- difftime_to_hms(params)
  params <- fix_numeric(params)
  params <- prepare_for_binding(params)
  result_bind(res@ptr, params)
  invisible(res)
}

#' @rdname postgres-query
#' @aliases dbBind,PqResult-method
#' @export
setMethod("dbBind", "PqResult", dbBind_PqResult)

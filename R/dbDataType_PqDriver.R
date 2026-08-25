#' Determine database type for R vector.
#'
#' @param dbObj Postgres driver or connection.
#' @param obj Object to convert
#' @keywords internal
#' @rdname dbDataType
#' @usage \S4method{dbDataType}{PqDriver}(dbObj, obj, ...)
dbDataType_PqDriver <- function(dbObj, obj, ...) {
  if (is.data.frame(obj)) {
    return(vapply(obj, dbDataType, "", dbObj = dbObj))
  }
  get_data_type(obj)
}

#' @rdname dbDataType
#' @aliases dbDataType,PqDriver-method
#' @export
setMethod("dbDataType", "PqDriver", dbDataType_PqDriver)

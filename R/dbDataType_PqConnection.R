# dbSendQuery()
# dbSendStatement()
# dbDataType()
#' PostgreSQL database type
#' @rdname dbDataType
#' @usage \S4method{dbDataType}{PqConnection}(dbObj, obj, ...)
dbDataType_PqConnection <- function(dbObj, obj, ...) {
  if (is.data.frame(obj)) {
    return(vapply(obj, dbDataType, "", dbObj = dbObj))
  }
  get_data_type(obj)
}

#' @rdname dbDataType
#' @aliases dbDataType,PqConnection-method
#' @export
setMethod("dbDataType", "PqConnection", dbDataType_PqConnection)

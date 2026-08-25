# dbQuoteString()
# dbQuoteIdentifier()
# dbWriteTable()
# dbReadTable()
# dbListTables()
# dbExistsTable()
# dbListFields()
# dbRemoveTable()
# dbGetInfo()
#' @title PostgreSQL connection class
#' @rdname PqConnection-class
#' @usage NULL
dbGetInfo_PqConnection <- function(dbObj, ...) {
  connection_info(dbObj@ptr)
}

#' @rdname PqConnection-class
#' @aliases dbGetInfo,PqConnection-method
#' @export
setMethod("dbGetInfo", "PqConnection", dbGetInfo_PqConnection)

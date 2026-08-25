#' @inheritParams DBI::sqlRownamesToColumn
#' @param ... Ignored.
#' @rdname postgres-tables
#' @usage NULL
sqlData_PqConnection <- function(con, value, row.names = FALSE, ...) {
  if (is.null(row.names)) {
    row.names <- FALSE
  }
  value <- sqlRownamesToColumn(value, row.names)

  value[] <- lapply(value, dbQuoteLiteral, conn = con)

  value
}

#' @rdname postgres-tables
#' @aliases sqlData,PqConnection-method
#' @export
setMethod("sqlData", "PqConnection", sqlData_PqConnection)

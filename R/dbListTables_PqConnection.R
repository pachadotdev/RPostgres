#' @rdname postgres-tables
#' @usage \S4method{dbListTables}{PqConnection}(conn, ...)
dbListTables_PqConnection <- function(conn, ...) {
  query <- list_tables(conn = conn, order_by = "table_type, table_name")

  dbGetQuery(conn, query)[["table_name"]]
}

#' @rdname postgres-tables
#' @aliases dbListTables,PqConnection-method
#' @export
setMethod("dbListTables", "PqConnection", dbListTables_PqConnection)

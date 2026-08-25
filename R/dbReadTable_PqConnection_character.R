#' @param check.names If `TRUE`, the default, column names will be
#'   converted to valid R identifiers.
#' @param row.names Whether to convert row names to a column. Use `FALSE`
#'   to discard row names.
#' @rdname postgres-tables
#' @usage \S4method{dbReadTable}{PqConnection,character}(conn, name, ..., check.names = TRUE, row.names = FALSE)
dbReadTable_PqConnection_character <- function(
  conn,
  name,
  ...,
  check.names = TRUE,
  row.names = FALSE
) {
  if (is.null(row.names)) {
    row.names <- FALSE
  }
  if (
    (!is.logical(row.names) && !is.character(row.names)) ||
      length(row.names) != 1L
  ) {
    stopc("`row.names` must be a logical scalar or a string")
  }

  if (!is.logical(check.names) || length(check.names) != 1L) {
    stopc("`check.names` must be a logical scalar")
  }

  name <- dbQuoteIdentifier(conn, name)
  out <- dbGetQuery(conn, paste("SELECT * FROM ", name), row.names = row.names)

  if (check.names) {
    names(out) <- make.names(names(out), unique = TRUE)
  }

  out
}

#' @rdname postgres-tables
#' @aliases dbReadTable,PqConnection,character-method dbReadTable,PqConnection,Id-method
#' @export
setMethod("dbReadTable", signature("PqConnection", "character"), dbReadTable_PqConnection_character)
setMethod("dbReadTable", signature("PqConnection", "Id"), dbReadTable_PqConnection_character)

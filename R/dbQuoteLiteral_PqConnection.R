#' @importFrom blob blob
#' @rdname quote
#' @usage \S4method{dbQuoteLiteral}{PqConnection}(conn, x, ...)
dbQuoteLiteral_PqConnection <- function(conn, x, ...) {
  if (length(x) == 0) {
    return(SQL(character()))
  }

  if (is.factor(x)) {
    x <- as.character(x)
  }

  if (inherits(x, "Date")) {
    ret <- paste0("'", as.character(x), "'")
    ret[is.na(x)] <- "NULL"
    SQL(paste0(ret, "::date"), names = names(ret))
  } else if (inherits(x, "POSIXt")) {
    ret <- paste0("'", as.character(set_tzone(x, conn@timezone)), "'")
    ret[is.na(x)] <- "NULL"
    SQL(paste0(ret, "::timestamptz"), names = names(ret))
  } else if (inherits(x, "difftime")) {
    ret <- paste0("'", format_hms(x), "'")
    ret[is.na(x)] <- "NULL"
    SQL(paste0(ret, "::interval"), names = names(ret))
  } else if (inherits(x, "integer64")) {
    ret <- as.character(x)
    ret[is.na(x)] <- "NULL"
    SQL(paste0(ret, "::int8"), names = names(ret))
  } else if (is.logical(x)) {
    ret <- as.character(x)
    ret[is.na(x)] <- "NULL"
    SQL(ret, names = names(ret))
  } else if (is.integer(x)) {
    ret <- as.character(x)
    ret[is.na(x)] <- "NULL"
    SQL(ret, names = names(ret))
  } else if (is.numeric(x)) {
    ret <- as.character(x)
    ret[is.na(x) & !is.nan(x)] <- "NULL"
    ret[is.infinite(x)] <- paste0("'", as.character(x[is.infinite(x)]), "'::float8")
    ret[is.nan(x)] <- "'NaN'::float8"
    SQL(ret, names = names(ret))
  } else if (is.list(x) || inherits(x, "blob")) {
    blob_data <- vcapply(
      x,
      function(x) {
        if (is.null(x)) {
          "NULL::bytea"
        } else if (is.raw(x)) {
          paste0("E'\\\\x", paste(format(x), collapse = ""), "'")
        } else {
          stopc("Lists must contain raw vectors or NULL")
        }
      }
    )
    SQL(blob_data, names = names(x))
  } else if (is.character(x)) {
    dbQuoteString(conn, x)
  } else {
    stopc(
      "Can't convert value of class ",
      class(x)[[1]],
      " to SQL.",
      call. = FALSE
    )
  }
}

#' @rdname quote
#' @aliases dbQuoteLiteral,PqConnection-method
#' @export
setMethod("dbQuoteLiteral", "PqConnection", dbQuoteLiteral_PqConnection)

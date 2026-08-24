#' Postgres driver
#'
#' @export
#' @import methods DBI
Postgres <- function() {
  new("PqDriver")
}

#' PqDriver class.
#'
#' @title PqDriver class
#' @name PqDriver-class
#' @keywords internal
setClass("PqDriver", contains = "DBIDriver")

# Set during installation time for the correct library
PACKAGE_VERSION <- tryCatch(
  utils::packageVersion("rpsql"),
  error = function(e) package_version("0.0.0")
)

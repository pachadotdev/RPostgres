
if (requireNamespace("tinytest", quietly = TRUE)) {
  library(DBI)
  tinytest::test_package("rpsql")
}


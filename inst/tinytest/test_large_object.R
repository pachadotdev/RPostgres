source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

test_file_path <- system.file(
  "tinytest/data/large_object.txt",
  package = "rpsql",
  mustWork = TRUE
)

# can import and read a large object
con <- postgresDefault()
oid <- dbWithTransaction(con, {
  postgresImportLargeObject(con, test_file_path)
})
expect_true(oid > 0)
lo_data <- unlist(dbGetQuery(
  con, "select lo_get($1) as lo_data", params = list(oid)
)$lo_data[1])
large_object_txt <- as.raw(c(0x70, 0x6f, 0x73, 0x74, 0x67, 0x72, 0x65, 0x73))
expect_equal(lo_data, large_object_txt)
dbExecute(con, "SELECT lo_unlink($1)", params = list(oid))
dbDisconnect(con)

# can import and export a large object
con <- postgresDefault()
oid <- dbWithTransaction(con, {
  postgresImportLargeObject(con, test_file_path)
})
expect_true(oid > 0)
temp_file <- tempfile(fileext = ".txt")
dbWithTransaction(con, {
  postgresExportLargeObject(con, oid, temp_file)
})
expect_true(file.exists(temp_file))
exported_content <- readBin(temp_file, "raw", file.size(temp_file))
original_content <- readBin(test_file_path, "raw", file.size(test_file_path))
expect_equal(exported_content, original_content)
dbExecute(con, "SELECT lo_unlink($1)", params = list(oid))
unlink(temp_file)
dbDisconnect(con)

# importing to an existing oid throws error
con <- postgresDefault()
oid <- 1234
dbWithTransaction(con, {
  oid <- postgresImportLargeObject(con, test_file_path, oid)
})
expect_error(
  dbWithTransaction(con, {
    postgresImportLargeObject(con, test_file_path, oid)
  })
)
dbExecute(con, "select lo_unlink($1) as lo_data", params = list(oid))
dbDisconnect(con)

# import from a non-existing path throws error
con <- postgresDefault()
expect_error(
  dbWithTransaction(con, {
    postgresImportLargeObject(con, file.path(tempdir(), "does_not_exist.txt"))
  })
)
dbDisconnect(con)

# export outside transaction throws error
con <- postgresDefault()
expect_error(
  postgresExportLargeObject(con, 12345, tempfile()),
  pattern = "Cannot export a large object outside of a transaction"
)
dbDisconnect(con)

# export with NULL oid throws error
con <- postgresDefault()
expect_error(
  dbWithTransaction(con, {
    postgresExportLargeObject(con, NULL, tempfile())
  }),
  pattern = "'oid' cannot be NULL"
)
dbDisconnect(con)

# export with NA oid throws error
con <- postgresDefault()
expect_error(
  dbWithTransaction(con, {
    postgresExportLargeObject(con, NA, tempfile())
  }),
  pattern = "'oid' cannot be NA"
)
dbDisconnect(con)

# export with negative oid throws error
con <- postgresDefault()
expect_error(
  dbWithTransaction(con, {
    postgresExportLargeObject(con, -1, tempfile())
  }),
  pattern = "'oid' cannot be negative"
)
dbDisconnect(con)

# export of non-existent oid throws error
con <- postgresDefault()
temp_file <- tempfile()
expect_error(
  dbWithTransaction(con, {
    postgresExportLargeObject(con, 999999, temp_file)
  })
)
unlink(temp_file)
dbDisconnect(con)

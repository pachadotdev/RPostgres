source("setup.R")

if (Sys.getenv("NOT_CRAN") != "true") exit_file("Skipping database tests on CRAN")
if (!postgresHasDefault()) exit_file("No default PostgreSQL connection")

# NAs encoded as NULLs
expect_equal(rpsql:::encode_vector(NA), "\\N")
expect_equal(rpsql:::encode_vector(NA_integer_), "\\N")
expect_equal(rpsql:::encode_vector(NA_real_), "\\N")
expect_equal(rpsql:::encode_vector(NA_character_), "\\N")

# special floating point values encoded correctly
expect_equal(rpsql:::encode_vector(NaN), "NaN")
expect_equal(rpsql:::encode_vector(Inf), "Infinity")
expect_equal(rpsql:::encode_vector(-Inf), "-Infinity")

# special string values are escaped
expect_equal(rpsql:::encode_vector("\n"), "\\n")
expect_equal(rpsql:::encode_vector("\r"), "\\r")
expect_equal(rpsql:::encode_vector("\b"), "\\b")

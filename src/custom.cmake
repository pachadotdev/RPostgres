target_include_directories(rpsql PUBLIC
    "/usr/include/postgresql"
    "vendor"
)

target_compile_definitions(rpsql PUBLIC
    "RCPP_DEFAULT_INCLUDE_CALL=false"
    "RCPP_USING_UTF8_ERROR_STRING"
    "BOOST_NO_AUTO_PTR"
)

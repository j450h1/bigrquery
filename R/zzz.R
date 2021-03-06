.onLoad <- function(libname, pkgname) {

  # S3 methods --------------------------------------------------------------
  register_s3_method("dplyr", "db_analyze", "BigQueryConnection")
  register_s3_method("dplyr", "db_query_fields", "BigQueryConnection")
  register_s3_method("dplyr", "db_save_query", "BigQueryConnection")
  register_s3_method("dplyr", "sql_translate_env", "BigQueryConnection")
  register_s3_method("dplyr", "collect", "tbl_BigQueryConnection")
  register_s3_method("dplyr", "tbl", "src_bigquery")

  # Default options --------------------------------------------------------
  op <- options()
  defaults <- list(
    bigrquery.quiet = NA,
    bigrquery.page.size = 1e4
  )
  toset <- !(names(defaults) %in% names(op))
  if (any(toset)) options(defaults[toset])

  invisible()
}

PACKAGE_NAME <- utils::packageName()
PACKAGE_VERSION <- utils::packageVersion(PACKAGE_NAME)

register_s3_method <- function(pkg, generic, class, fun = NULL) {
  stopifnot(is.character(pkg), length(pkg) == 1)
  stopifnot(is.character(generic), length(generic) == 1)
  stopifnot(is.character(class), length(class) == 1)

  if (is.null(fun)) {
    fun <- get(paste0(generic, ".", class), envir = parent.frame())
  } else {
    stopifnot(is.function(fun))
  }

  if (pkg %in% loadedNamespaces()) {
    registerS3method(generic, class, fun, envir = asNamespace(pkg))
  }

  # Always register hook in case package is later unloaded & reloaded
  setHook(
    packageEvent(pkg, "onLoad"),
    function(...) {
      registerS3method(generic, class, fun, envir = asNamespace(pkg))
    }
  )
}

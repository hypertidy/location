## Package-level state: session cache and rate monitor --------------------

.loc_env <- new.env(parent = emptyenv())
.loc_env$cache          <- list()       # key -> data.frame row
.loc_env$request_times  <- numeric(0)   # POSIXct as numeric, rolling window

## Rate monitor: warn if hammering the service
.check_rate <- function(window_secs = 60L, warn_threshold = 40L) {
  now <- as.numeric(Sys.time())
  times <- .loc_env$request_times
  times <- times[times > now - window_secs]
  times <- c(times, now)
  .loc_env$request_times <- times
  n <- length(times)
  if (n > warn_threshold) {
    warning(sprintf(
      "location: %d Nominatim requests in the last %ds (policy: max 1/sec). ",
      n, window_secs
    ), "Results are cached within the session - repeated queries are free.",
    call. = FALSE)
  }
}

#' Clear the session cache
#'
#' `loc()` caches results within the R session so repeated queries don't hit
#' Nominatim again. Call this if you need fresh results, e.g. after updating
#' your query strings.
#'
#' @return invisibly `NULL`
#' @export
loc_cache_clear <- function() {
  .loc_env$cache         <- list()
  .loc_env$request_times <- numeric(0)
  invisible(NULL)
}

#' Show the session cache
#'
#' @return a data frame of all cached results, or an empty data frame if the
#'   cache is empty.
#' @export
loc_cache_show <- function() {
  if (length(.loc_env$cache) == 0L) {
    message("location: session cache is empty")
    return(invisible(.empty_result(character(0))))
  }
  do.call(rbind, .loc_env$cache)
}

#' Look up the timezone for a place name
#'
#' A convenience wrapper that geocodes a place name with [loc()] and then
#' looks up the IANA timezone via the \pkg{lutz} package.
#'
#' @param x character vector of place names.
#' @param method passed to [lutz::tz_lookup_coords()]: `"fast"` (default,
#'   Rcpp-based, no sf dependency) or `"accurate"` (sf polygon intersection).
#' @param ... passed to [loc()].
#'
#' @return A character vector of IANA timezone names (e.g.
#'   `"America/Chicago"`), the same length as `x`. `NA` where geocoding or
#'   timezone lookup failed.
#'
#' @examples
#' \dontrun{
#' loc_tz("Jackson, TN")
#' loc_tz("Davis Station, Antarctica")
#' loc_tz(c("Hobart", "McMurdo"))
#' }
#'
#' @export
loc_tz <- function(x, method = "fast", ...) {
  if (!requireNamespace("lutz", quietly = TRUE)) {
    stop("Package 'lutz' is needed for loc_tz(). ",
         "Install with: install.packages('lutz')", call. = FALSE)
  }
  coords <- loc(x, ...)
  lutz::tz_lookup_coords(coords$lat, coords$lon, method = method, warn = FALSE)
}

#' Geocode a place name string
#'
#' Queries the Nominatim geocoding API (OpenStreetMap) to look up coordinates
#' for one or more place name strings. Returns a data frame with one row per
#' input.
#'
#' Nominatim's usage policy requires a descriptive `User-Agent` and a maximum
#' rate of one request per second. `loc()` enforces the rate limit automatically
#' and sets a meaningful user-agent. See
#' <https://operations.osmfoundation.org/policies/nominatim/>.
#'
#' @param x character vector of place names, e.g. `"Jackson, TN"` or
#'   `"Davis Station, Antarctica"`.
#' @param limit integer. Maximum number of results to return *per query*.
#'   Usually 1 is what you want. The Nominatim API caps this at 50.
#' @param full logical. If `TRUE`, return all fields from the Nominatim
#'   response as list-columns. If `FALSE` (default), return only `query`,
#'   `lat`, `lon`, `display_name`, and `osm_type`.
#' @param api_url base URL for the Nominatim API. Override to use a local
#'   instance: `"http://localhost:7070"`.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{query}{the original input string}
#'     \item{lat}{latitude (numeric, or `NA` if not found)}
#'     \item{lon}{longitude (numeric, or `NA` if not found)}
#'     \item{display_name}{full place name as returned by Nominatim}
#'     \item{osm_type}{OSM object type: `"node"`, `"way"`, or `"relation"`}
#'   }
#'   When `full = TRUE`, all additional Nominatim fields are included as
#'   list-columns.
#'
#' @examples
#' \dontrun{
#' loc("Hobart")
#' loc("Jackson, TN")
#' loc(c("Davis Station", "Casey Station", "Mawson Station"))
#' }
#'
#' @export
loc <- function(x, limit = 1L, full = FALSE,
                api_url = "https://nominatim.openstreetmap.org") {
  stopifnot(is.character(x), length(x) >= 1L)
  if (!curl::has_internet()) {
    message("location: no internet connection, returning NA")
    return(.empty_result(x))
  }

  results <- vector("list", length(x))
  for (i in seq_along(x)) {
    if (i > 1L) Sys.sleep(1)  # Nominatim: max 1 req/sec
    results[[i]] <- .loc_one(x[[i]], limit = limit, full = full,
                              api_url = api_url)
  }
  do.call(rbind, results)
}

## Internal: single query -------------------------------------------------

.loc_one <- function(query, limit, full, api_url) {
  url <- paste0(
    api_url, "/search",
    "?q=", utils::URLencode(query, reserved = TRUE),
    "&format=json",
    "&limit=", as.integer(limit)
  )

  handle <- curl::new_handle(
    useragent = "hypertidy/location R package (https://github.com/hypertidy/location)"
  )

  resp <- tryCatch(
    curl::curl_fetch_memory(url, handle = handle),
    error = function(e) {
      message("location: request failed for '", query, "': ", conditionMessage(e))
      NULL
    }
  )

  if (is.null(resp) || resp$status_code != 200L) {
    return(.empty_result(query))
  }

  parsed <- tryCatch(
    jsonlite::fromJSON(rawToChar(resp$content), simplifyVector = TRUE),
    error = function(e) NULL
  )

  if (is.null(parsed) || !is.data.frame(parsed) || nrow(parsed) == 0L) {
    return(.empty_result(query))
  }

  out <- data.frame(
    query        = query,
    lat          = as.numeric(parsed$lat[[1L]]),
    lon          = as.numeric(parsed$lon[[1L]]),
    display_name = parsed$display_name[[1L]],
    osm_type     = parsed$osm_type[[1L]],
    stringsAsFactors = FALSE
  )

  if (full) {
    extra <- parsed[1L, setdiff(names(parsed),
                                c("lat", "lon", "display_name", "osm_type")),
                    drop = FALSE]
    out <- cbind(out, extra)
  }

  out
}

## Internal: empty result row ---------------------------------------------

.empty_result <- function(query) {
  data.frame(
    query        = query,
    lat          = NA_real_,
    lon          = NA_real_,
    display_name = NA_character_,
    osm_type     = NA_character_,
    stringsAsFactors = FALSE
  )
}

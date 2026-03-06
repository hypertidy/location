
<!-- README.md is generated from README.Rmd. Please edit that file -->

# location

<!-- badges: start -->

[![R-CMD-check](https://github.com/hypertidy/location/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hypertidy/location/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Minimal geocoding for R via
[Nominatim](https://nominatim.openstreetmap.org/) (OpenStreetMap). No
API key required.

## Installation

``` r
pak::pak("hypertidy/location")
```

## Usage

``` r
library(location)

# Single place
loc("Hobart, Tasmania")
#>              query       lat      lon
#> 1 Hobart, Tasmania -42.88251 147.3281
#>                                  display_name osm_type
#> 1 Hobart, City of Hobart, Tasmania, Australia relation

# Multiple places - one request per second (Nominatim policy)
loc(c("Davis Station, Antarctica", "Casey Station", "Mawson Station"))
#>                       query       lat       lon   display_name osm_type
#> 1 Davis Station, Antarctica        NA        NA           <NA>     <NA>
#> 2             Casey Station -66.28209 110.52408  Casey Station     node
#> 3            Mawson Station -67.60290  62.87375 Mawson Station     node

# Straight to timezone (requires lutz)
loc_tz("Crystal Lake, TN")
#> [1] "America/New_York"

loc_tz(c("Hobart", "McMurdo Station", "Rothera"))
#> [1] "Australia/Hobart"   "Antarctica/McMurdo" "Antarctica/Rothera"
```

## Design

- `loc(x)` → data frame: `query`, `lat`, `lon`, `display_name`,
  `osm_type`
- `loc_tz(x)` → character vector of IANA tz names (requires `lutz`)
- `full = TRUE` returns all Nominatim response fields
- `api_url` can point to a local Nominatim instance
- Enforces 1 req/sec and sets a meaningful `User-Agent` per [Nominatim
  policy](https://operations.osmfoundation.org/policies/nominatim/)
- `curl::has_internet()` guard — returns `NA` rows silently offline

## Used by

- [hypertidy/timenow](https://github.com/hypertidy/timenow) —
  timezone-aware timestamps
- [msumner/place](https://github.com/msumner/place) — place name
  utilities

## Dependencies

- `curl` — HTTP
- `jsonlite` — JSON parsing
- `lutz` (suggested) — for `loc_tz()`

## Code of Conduct

Please note that the location project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

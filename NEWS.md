# location (development version)

* `loc()` now returns `lon,lat,name,query,osm_type` in that order. 

## location 0.1.0

* Initial release.
* `loc()` geocodes place name strings via the Nominatim API (OpenStreetMap),
  returning a data frame of `query`, `lat`, `lon`, `display_name`, `osm_type`.
* `loc_tz()` convenience wrapper: geocode + IANA timezone lookup via `lutz`.
* Session cache: repeated queries are free (no network hit).
* Rate monitoring: warns if Nominatim is being queried too heavily.
* `loc_cache_show()` and `loc_cache_clear()` for cache inspection and reset.
* Enforces Nominatim usage policy: 1 req/sec rate limit and descriptive
  `User-Agent`.
* `curl::has_internet()` guard returns `NA` rows silently when offline.

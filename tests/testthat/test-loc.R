test_that("loc() returns correct structure", {
  result <- .empty_result("test place")
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "name", "query", "osm_type"))
  expect_equal(result$query, "test place")
  expect_true(is.na(result$lat))
  expect_true(is.na(result$lon))
})

test_that(".empty_result() respects zero-length input", {
  result <- .empty_result(character(0))
  expect_equal(nrow(result), 0L)
  expect_named(result, c("lon", "lat", "name", "query", "osm_type"))
})

test_that("loc() returns NA rows for multi-element failed lookup", {
  result <- .empty_result(c("a", "b"))
  expect_equal(nrow(result), 2L)
})

test_that("loc() errors on non-character input", {
  expect_error(loc(42))
})

test_that("cache key is case- and whitespace-insensitive", {
  k1 <- .cache_key("Hobart", 1L, "https://nominatim.openstreetmap.org")
  k2 <- .cache_key("  HOBART  ", 1L, "https://nominatim.openstreetmap.org")
  expect_equal(k1, k2)
})

test_that("loc_cache_clear() resets cache and request times", {
  loc_cache_clear()
  expect_equal(length(.loc_env$cache), 0L)
  expect_equal(length(.loc_env$request_times), 0L)
})

test_that("loc_cache_show() reports empty cache cleanly", {
  loc_cache_clear()
  expect_message(loc_cache_show(), "empty")
})

test_that(".check_rate() warns when threshold exceeded", {
  loc_cache_clear()
  .loc_env$request_times <- rep(as.numeric(Sys.time()), 41L)
  expect_warning(.check_rate(), "requests in the last")
  loc_cache_clear()
})



test_that("loc() live lookup returns plausible result", {
  skip_if_offline()
  skip_on_cran()
  loc_cache_clear()
  result <- loc("Hobart, Tasmania")
  expect_equal(nrow(result), 1L)
  expect_true(!is.na(result$lat))
  expect_true(result$lat > -44 && result$lat < -41)
  expect_true(result$lon > 146 && result$lon < 148)
})

test_that("loc() second call uses cache, not network", {
  skip_if_offline()
  skip_on_cran()
  loc_cache_clear()
  loc("Hobart, Tasmania")
  n_before <- length(.loc_env$request_times)
  loc("Hobart, Tasmania")  # should hit cache
  n_after <- length(.loc_env$request_times)
  expect_equal(n_before, n_after)
})

test_that("loc_cache_show() returns cached rows", {
  skip_if_offline()
  skip_on_cran()
  loc_cache_clear()
  loc("Hobart, Tasmania")
  cached <- loc_cache_show()
  expect_s3_class(cached, "data.frame")
  expect_equal(nrow(cached), 1L)
})

test_that("loc_tz() live lookup returns correct timezone", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("lutz")
  tz <- loc_tz("Hobart, Tasmania")
  expect_equal(tz, "Australia/Hobart")
})

test_that("loc_tz() for US city returns correct timezone", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("lutz")
  tz <- loc_tz("Jackson, TN")
  expect_equal(tz, "America/Chicago")
})

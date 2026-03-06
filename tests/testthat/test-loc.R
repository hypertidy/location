test_that("loc() returns correct structure", {
  # offline / mock: just check the shape with a known-bad URL to trigger empty
  result <- location:::.empty_result("test place")
  expect_s3_class(result, "data.frame")
  expect_named(result, c("query", "lat", "lon", "display_name", "osm_type"))
  expect_equal(result$query, "test place")
  expect_true(is.na(result$lat))
})

test_that("loc() returns NA row for failed lookup", {
  result <- location:::.empty_result(c("a", "b"))
  expect_equal(nrow(result), 2L)
})

test_that("loc() errors on non-character input", {
  expect_error(loc(42))
})

test_that("loc() live lookup returns plausible result", {
  skip_if_offline()
  skip_on_cran()
  result <- loc("Hobart, Tasmania")
  expect_equal(nrow(result), 1L)
  expect_true(!is.na(result$lat))
  expect_true(result$lat > -44 && result$lat < -41)
  expect_true(result$lon > 146 && result$lon < 148)
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
  tz <- loc_tz("Crystal Lake, IL")
  expect_equal(tz, "America/Chicago")
})


context("find_R6_objects")

test_that("find_R6_objects works end-to-end", {

    res <- find_R6_objects(pkg_name = "base")
    expect_true(TRUE)
})

test_that("find_R6_objects works as expected for a package with no R6 object", {

    res <- find_R6_objects(pkg_name = "base")
    expect_identical(names(res), character(0))
    expect_true(methods::is(res, "list"))
    expect_true(length(res) == 0)
})

test_that("find_R6_objects works as expected for a package with R6 objects", {

    # This is tough because CRAN doesn't let you install new packages
    # on the testing servers and there aren't any we can reliably assume will
    # be available. Solution: skip these tests on CRAN, run on other CI
    testthat::skip_on_cran()

    res <- find_R6_objects(pkg_name = "pkgnet")
    expect_true(methods::is(res, "list"))
    expect_true(length(res) > 0)
    expect_true(all(sapply(res, R6::is.R6Class)))
})

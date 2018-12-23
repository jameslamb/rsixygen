
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

    testthat::skip("Not really testing find_r6_objects. See https://github.com/jameslamb/rsixygen/issues/17")

    res <- find_R6_objects(pkg_name = "milne")
    expect_true(methods::is(res, "list"))
    expect_true(length(res) > 0)
    expect_true(all(sapply(res, R6::is.R6Class)))
})

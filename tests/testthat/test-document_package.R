
context("document_package")

test_that("document_package() has the expected behavior for a package with no R6 objects", {

    out_file <- tempfile(pattern = "out", fileext = ".txt")
    expect_warning({
        res <- document_package(pkg_name = "base", out_dir = out_file)
    }, regexp = "No R6 objects found in base")
    expect_false(file.exists(out_file))
})

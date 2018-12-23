
context("document_class")

test_that("document_class runs end-to-end for a simple class", {

    someClass <- R6::R6Class(
        classname = "TestClass"
    )

    res <- document_class(someClass)

    expect_true(is.character(res))
    expect_true(length(res) == 1)
    expect_true(nchar(res) > 0)
})

test_that("document_class runs end-to-end for a class with public methods and fields", {

    someClass <- R6::R6Class(
        classname = "TestClass",
        public = list(
            a_function = function(x = 5, some_arg = TRUE){TRUE},
            another_function = function(){NULL},
            a_value = list(thing = LETTERS),
            another_value = NULL
        )
    )

    res <- document_class(someClass)

    expect_true(is.character(res))
    expect_true(length(res) == 1)
    expect_true(nchar(res) > 0)
})

test_that("document_class rejects bad inputs", {

    someClass <- R6::R6Class(
        classname = "TestClass"
    )

    bad_inputs <- list(
        "class instance" = someClass$new()
        , "string" = "TestClass"
        , "boolean" = TRUE
        , "NULL" = NULL
        , "NA" = NA
    )

    input_names <- names(bad_inputs)
    for (i in 1:length(bad_inputs)){
        expect_error({
            res <- document_class(bad_inputs[[i]])
        }, info = paste0("input type: ", input_names[[i]]))
    }
})

CONSTRUCTOR_METHODS <- c("new", "initialize")
SPECIAL_METHODS <- c("clone", "print", "finalize")

CLONE_DESCRIBE <- paste0(
    "Method for copying an object. See \\\\href{https://adv-r.hadley.nz/r6.html#r6-semantics}{\\emph{Advanced R}} "
    , "for the intricacies of R6 reference semantics."
)
CLONE_PARAM <- "logical. Whether to recursively clone nested R6 objects."
CLONE_RETURN <- "Cloned object of this class."

# [description] Document inheritance and link to parent class
.inherit_link <- function(aClass){

    # If class does not inherit anything, return NULL
    if (is.null(aClass$get_inherit())) {
        return(NULL)
    }

    # Get parent class name and environment (package it's from)
    # Need to use the generator object name because that's the
    # one that is required and important
    parentClassName <- deparse(aClass$inherit)
    parentClassEnv <- environmentName(aClass$get_inherit()$parent_env)

    out <- sprintf(
        "Inherits: \\code{\\link[%s]{%s}}\n"
        , parentClassEnv
        , parentClassName
    )

    return(out)
}

# [description] Get signature string from a function object
# [notes] Sometimes weird stuff can happen with str(). Consider,
#         for example:
#
#          f <- function(){4 + 4; return(TRUE)}
#          utils::str(f)
#
#         To get around this, I did some horrible regex stuff here.
#' @importFrom utils capture.output str
.get_sig <- function(func, func_name){
    sig <- paste0(
        grep(
            pattern = "^function"
            , x = trimws(
                utils::capture.output(
                    utils::str(func)
                )
            )
            , value = TRUE
        )
        , collapse = " "
    )

    return(trimws(gsub("^function ", func_name, sig)))
}

# [description] Generate a roxygen skeleton for a method
.describe_function <- function(func, func_name){

    # Start it up
    out <- paste0(
        "    \\item{\\code{"
        , .get_sig(func, func_name)
        , "}}{\n"
        , "        \\itemize{\n"
        , "            \\item{~~DESCRIBE THE METHOD~~}\n"
    )

    # Throws unavoidable warning if no arguments, but we don't really care
    los_argumentos <- suppressWarnings({
        names(formals(func))
    })

    if (length(los_argumentos) > 0){

        arg_details <- NULL
        for (arg in los_argumentos){
            arg_details <- paste0(
                arg_details
                , "                    \\item{\\bold{\\code{"
                , arg
                , "}}: ~~DESCRIBE THIS PARAMETER~~
                 }\n"
            )
        }

        out <- paste0(
            out
            , "            \\item{\\bold{Args:}}{\n"
            , "                \\itemize{\n"
            , arg_details
            , "                }\n"
            , "            }\n"
        )
    }

    # Add the returns block and close it out
    out <- paste0(
        out
        , "            \\item{\\bold{Returns:}}{\n"
        , "                \\itemize{\n"
        , "                    \\item{~~WHAT DOES THIS RETURN~~}\n"
        , "                }\n"
        , "            }\n"
        , "        }\n"
        , "    }\n"
    )

    return(out)
}

# [description] Class constructor (initialize) block
.constructor_block <- function(aClass){
    out <- paste0(
        "@section Class Constructor:\n"
        , "\\describe{\n"
        , .describe_function(aClass$public_methods[["initialize"]], "new")
        , "}\n"
    )
    return(out)
}

# [description] Returns vector of public method description items
#' @importFrom stats setNames
.describe_public_methods <- function(aClass) {

    # Initialize empty vector to append additional method descriptions to
    out <- NULL

    # If this class has a parent class, do the parent first
    if (!is.null(aClass$get_inherit())) {
        # Append parent class method descriptions
        out <- c(
            out
            , .describe_public_methods(aClass$get_inherit())
        )
    }

    # Get names of public methods for this class
    # We document constructor and other special methods separately
    funcNames <- base::setdiff(
        names(aClass$public_methods)
        , c(CONSTRUCTOR_METHODS, SPECIAL_METHODS)
    )

    # Iterate through this class' public methods
    for (thisFuncName in funcNames){
        # Append description for this function to out vector
        out <- c(
            out
            , stats::setNames(
                object = .describe_function(aClass$public_methods[[thisFuncName]], thisFuncName)
                , nm = thisFuncName
            )
        )
    }

    # Identify duplicates by name. We want to keep the latest one because it will be a child class'
    itemsToKeep <- !duplicated(names(out), fromLast = TRUE)

    return(out[itemsToKeep])
}

# [description] Generates public methods block
.public_methods_block <- function(aClass){

    # Get vector of descriptions
    descriptVec <- .describe_public_methods(aClass)

    # Collapse into doc block
    out <- paste0(
        "@section Public Methods:\n"
        , "\\describe{\n"
        , paste0(descriptVec, collapse = "")
        , "}\n"
    )

    return(out)
}

# [description] Generates vector of public fields documentation
# (both static fields and active bindings)
.get_public_fields <- function(aClass) {

    # Initialize empty vector to append additional method descriptions to
    out <- NULL

    # If this class has a parent class, do the parent first
    if (!is.null(aClass$get_inherit())) {
        # Append parent class public fields
        out <- c(out, .get_public_fields(aClass$get_inherit()))
    }

    # Add this class' static fields and active bindings
    # Keep only unique
    out <- unique(c(
        out
        , names(aClass$public_fields)
        , names(aClass$active)
    ))

    return(out)

}

# [description] Generates block for public fields documentation
.public_field_block <- function(aClass){

    out <- paste0(
        "@section Public Fields:\n"
        , "\\describe{\n"
    )

    # Get names of public fields
    public_fields <- .get_public_fields(aClass)

    # Construct document item for each field
    items <- vapply(
        public_fields
        , FUN = function(x){
            paste0(
                "    \\item{\\bold{\\code{"
                , x
                , "}}}{: ~~DESCRIBE THIS FIELD~~}\n"
            )
        }
        , FUN.VALUE = ""
    )

    # Collapse document items into block
    out <- paste0(
        out
        , paste0(items, collapse = "")
        , "}\n"
    )

    return(out)
}

# [description] Generate special methods block
.special_methods_block <- function(aClass){

    descriptVec <- NULL

    # Iterate through this class' public methods
    for (thisFuncName in SPECIAL_METHODS){

        # if not defined, skip it
        # clone is always defined by default, other special methods only exist if
        # explicitly defined by the class definition
        if (!thisFuncName %in% names(aClass$public_methods)) {
            next
        }

        thisFuncDescript <- .describe_function(aClass$public_methods[[thisFuncName]], thisFuncName)

        # if the function is clone, put in standard documentation
        if (thisFuncName == "clone") {
            thisFuncDescript <- sub("~~DESCRIBE THE METHOD~~", CLONE_DESCRIBE, thisFuncDescript)
            thisFuncDescript <- sub("~~DESCRIBE THIS PARAMETER~~", CLONE_PARAM, thisFuncDescript)
            thisFuncDescript <- sub("~~WHAT DOES THIS RETURN~~", CLONE_RETURN, thisFuncDescript)
        }

        # Append description for this function to out vector
        descriptVec <- c(descriptVec, thisFuncDescript)
    }

    # Collapse into doc block
    out <- paste0(
        "@section Special Methods:\n"
        , "\\describe{\n"
        , paste0(descriptVec, collapse = "")
        , "}\n"
    )

    return(out)
}


#' @title Document an R6 Class
#' @name document_class
#' @description Given an R6 class, build a Roxygen documentation skeleton
#'              describing its public interface.
#' @param aClass An \code{\link[R6]{R6Class}}. Note that this should be the class
#'               generator, NOT an instance of that class.
#' @importFrom assertthat assert_that
#' @importFrom R6 is.R6Class R6Class
#' @export
#' @examples
#' \donttest{
#'
#' # Build a sample class
#' LupeFiasco <- R6::R6Class(
#'     "LupeFiasco",
#'     public = list(
#'         initialize = function(food = TRUE, liquor = "interesting"){
#'             return(food & liquor)
#'         },
#'         kick_and_push = function(n = 10){
#'             return(sample(c("kick", "push", "coast"), size = n, replace = TRUE))
#'         },
#'         did_you_say_lupe_frasco = function(response_type = "lie"){
#'             switch(response_type,
#'                    "lie" = "yes",
#'                    "no")
#'         }
#'     ),
#'     active = list(
#'         they_call_me = function(){"lupe"},
#'         ill_be_your = function(){"new day"}
#'     )
#' )
#'
#' # Document it!
#' cat(document_class(LupeFiasco))
#' }
document_class <- function(aClass){

    assertthat::assert_that(
        R6::is.R6Class(aClass)
    )

    outSections <- c(
        .inherit_link(aClass)
        , .constructor_block(aClass)
        , .public_methods_block(aClass)
        , .public_field_block(aClass)
        , .special_methods_block(aClass)
    )

    out <- paste0("\n ", outSections, collapse = "\n")

    # This last little gsub makes them Roxygen comments!
    return(return(gsub("\n", "\n#' ", out)))
}

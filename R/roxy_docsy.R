
# [description] Get signature string from a function object
#' @importFrom utils capture.output str
.get_sig <- function(func, func_name){
    sig <- paste0(
        trimws(
            utils::capture.output(
                utils::str(func)
            )
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

    # Add arguments?
    los_argumentos <- names(formals(func))
    if (length(los_argumentos) > 0){

        arg_details <- NULL
        for (arg in los_argumentos){
            arg_details <- paste0(
                arg_details
                , "                    \\item{\\bold{\\code{"
                , arg
                , "}}: ~~DESCRIBE THIS PARAMETER }\n"
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

.constructor_block <- function(aClass){
    out <- paste0(
        "@section Class Constructor:\n"
        , "\\describe{\n"
        , .describe_function(aClass$public_methods[["initialize"]], "new")
        , "}\n"
    )
    return(out)
}

.public_methods_block <- function(aClass){

    out <- paste0(
        "@section Public Methods:\n"
        , "\\describe{\n"
    )

    func_names <- base::setdiff(
        names(aClass$public_methods)
        , "clone"
    )
    for (func_name in func_names){

        # skip the constructor. It gets special treatment
        if (func_name %in% c("new", "initialize")){
            next
        }

        out <- paste0(
            out
            , .describe_function(aClass$public_methods[[func_name]], func_name)
        )
    }

    out <- paste0(out, "}\n")
    return(out)
}

# Document public fields (both static fields and active bindings)
.public_member_block <- function(aClass){

    out <- paste0(
        "@section Public Members:\n"
        , "\\describe{\n"
    )

    public_members <- c(
        names(aClass$public_fields)
        , names(aClass$active)
    )

    items <- sapply(public_members, function(x){
        paste0(
            "    \\item{\\bold{\\code{"
            , x
            , "}}}{: ~~DESCRIBE THIS FIELD~~}\n"
        )
    })

    out <- paste0(
        out
        , paste0(items, collapse = "")
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

    out <- paste0(
        "#' "
        , .constructor_block(aClass)
        , "\n"
        , .public_methods_block(aClass)
        , "\n"
        , .public_member_block(aClass)
    )

    # This last little gsub makes them Roxygen comments!
    return(gsub("\n", "\n#' ", out))
}

#' @title Find R6 objects in a package
#' @name find_R6_objects
#' @description Search for R6 objects in a package and get a list of them
#' @param pkg_name Name of the package to document
#' @importFrom assertthat assert_that is.string
#' @importFrom R6 is.R6Class
#' @export
find_R6_objects <- function(pkg_name){

    assertthat::assert_that(
        assertthat::is.string(pkg_name)
    )

    pkg_env <- loadNamespace(pkg_name)

    # Pass through R6 objects from pkg environment
    R6_objects <- eapply(
        env = pkg_env
        , FUN = function(obj){
            if (R6::is.R6Class(obj)){
                return(obj)
            } else {
                return(NULL)
            }
        }
    )

    # Drop empty stuff
    R6_objects <- Filter(
        f = function(l){length(l) > 0}
        , x = R6_objects
    )

    return(R6_objects)
}


#' @title Find R6 objects in a package
#' @name find_R6_objects
#' @description Search for R6 objects in a package and get a list of them
#' @param pkg_name Name of the package to document
#' @importFrom assertthat assert_that is.string
#' @importFrom R6 R6Class
#' @export
find_R6_objects <- function(pkg_name){
    
    assertthat::assert_that(
        assertthat::is.string(pkg_name)
    )
    
    pkg_env <- loadNamespace(pkg_name)
    
    R6_objects <- lapply(
        ls(pkg_env)
        , function(obj_name){
            obj <- get(obj_name, envir = pkg_env)
            if ("R6ClassGenerator" %in% class(obj)){
                return(obj)
            } else {
                return(NULL)
            }
        }
    )
    
    # Drop empty stuff
    R6_objects <- Filter(function(l){length(l) > 0}, R6_objects)
    
    return(R6_objects)
}

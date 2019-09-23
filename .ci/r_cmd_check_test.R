
library(argparse)
library(devtools)

parser <- argparse::ArgumentParser(
    description = "Run R CMD CHECK with configurable number of errors/warnings/notes"
)
parser$add_argument(
    "--pkg-dir"
    , help = "Directory with an R package in it"
    , dest = "PKG_DIR"
)
parser$add_argument(
    "--allowed-notes"
    , help = "number of allowed notes"
    , dest = "NOTES"
)
parser$add_argument(
    "--allowed-warnings"
    , help = "number of allowed warnings"
    , dest = "WARNINGS"
)
parser$add_argument(
    "--allowed-errors"
    , help = "number of allowed errors"
    , dest = "ERRORS"
)
args <- parser$parse_args()
PKG_DIR <- args[["PKG_DIR"]]

# If any thresholds are set above 0, added regular expressions
# to the corresponding "exception_patterns" block so we can
# say not "1 ERROR allowed" but "this 1 ERROR allowed"
THRESHOLDS <- list(
    notes = list(
        num_allowed = as.numeric(args[["NOTES"]])
        , exception_patterns = c()
    )
    , warnings = list(
        num_allowed = as.numeric(args[["WARNINGS"]])
        , exception_patterns = c(
            "size reduction of PDFs"
        )
    )
    , errors = list(
        num_allowed = as.numeric(args[["ERRORS"]])
        , exception_patterns = c()
    )
)

# suppress timedatectl warning (not relevant to our code)
Sys.setenv("TZ" = "UTC")

res <- devtools::check(
    pkg = PKG_DIR
    , document = TRUE
    , args = c('--ignore-vignettes', '--no-manual')
    , quiet = FALSE

    # we do custom error-handling
    , error_on = "never"
)

for (result_type in c("errors", "warnings", "notes")){

    found <- length(res[[result_type]])
    allowed <- THRESHOLDS[[result_type]][["num_allowed"]]

    if (found > 0){
        exception_patterns <- THRESHOLDS[[result_type]][["exception_patterns"]]
        if (length(exception_patterns) > 0){
            num_legit_exceptions <- sum(sapply(
                X = exception_patterns
                , FUN = function(p){
                    any(grepl(p, res[[result_type]]))
                }
            ))
            found <- found - num_legit_exceptions
        }
    }

    if (found > allowed){

        msg <- paste0("R CMD CHECK ", result_type, " found: ", found)
        print(msg)
        quit(
            save = "no"
            , status = found - allowed
        )
    }
}

print("R CMD CHECK tests passed")

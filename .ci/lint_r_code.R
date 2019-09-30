
library(argparse)
library(lintr)

args <- commandArgs(
    trailingOnly = TRUE
)
SOURCE_DIR <- args[[1]]

LINTERS_TO_USE <-list(
    "closed_curly" = lintr::closed_curly_linter
    , "infix_spaces" = lintr::infix_spaces_linter
    , "long_lines" = lintr::line_length_linter(length = 120)
    , "tabs" = lintr::no_tab_linter
    , "open_curly" = lintr::open_curly_linter
    , "spaces_inside" = lintr::spaces_inside_linter
    , "spaces_left_parens" = lintr::spaces_left_parentheses_linter
    , "trailing_blank" = lintr::trailing_blank_lines_linter
    , "trailing_white" = lintr::trailing_whitespace_linter
)

result <- lintr::lint_package(
    path = SOURCE_DIR
    , relative_path = FALSE
    , linters = LINTERS_TO_USE
)

cat(sprintf(
    "Found %i linting errors in %s\n"
    , length(result)
    , SOURCE_DIR
))

if (length(result) > 0){
    cat("\n")
    print(result)
}

quit(save = "no", status = length(result))

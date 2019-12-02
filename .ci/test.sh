#!/bin/bash

# Failure is a natural part of life
set -e

export CI_TOOLS=$(pwd)/.ci
export R_PACKAGE_DIR=$(pwd)

echo "========================="
echo "= Building roxygen docs ="
echo "========================="

    Rscript -e "devtools::document()"

echo "========================================="
echo "= Checking code for R style problems... ="
echo "========================================="

    Rscript ${CI_TOOLS}/lint_r_code.R $(pwd)

echo "done checking code for style problems."

echo "======================="
echo "= Running R CMD CHECK ="
echo "======================="

    # Rscript -e "testthat::test_dir('tests/testthat', stop_on_failure = TRUE)"
    Rscript ${CI_TOOLS}/r_cmd_check_test.R \
        --pkg-dir $(pwd)/ \
        --allowed-notes 0 \
        --allowed-warnings 0 \
        --allowed-errors 0

echo "done running R CMD CHECK"
exit 0

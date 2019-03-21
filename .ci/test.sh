#!/bin/bash

# Failure is a natural part of life
set -e

Rscript -e "devtools::document()"
Rscript -e "devtools::test()"

echo "Checking code for R style problems..."

    Rscript $(pwd)/.ci/lint_r_code.R \
        --package-dir $(pwd)/

echo "Done checking code for style problems."

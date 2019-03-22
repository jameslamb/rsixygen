#!/bin/bash

# Failure is a natural part of life
set -e

# Install other packages
Rscript -e "install.packages(c('argparse', 'devtools', 'lintr', 'roxygen2'), repos = 'http://cran.rstudio.org')"

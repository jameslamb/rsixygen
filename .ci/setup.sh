#!/bin/bash

# Failure is a natural part of life
set -e

# Install other packages
Rscript -e "install.packages(c('roxygen2', 'devtools'), repos = 'http://cran.rstudio.org')"

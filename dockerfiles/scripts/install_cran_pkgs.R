#!/usr/bin/env Rscript

# Script that installs additional packages from CRAN
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Bioc packages to install
cran_pkgs <- list(
    tidyverse = c(),
    rstudio = c("devtools"),
    `r-ver` = c()
)

# Get diff of installed and uninstalled packages for
# idempotent package installation
new_pkgs <- cran_pkgs[[distribution]][!(cran_pkgs[[distribution]] %in% installed.packages()[,"Package"])]

# Install only uninstalled packages
if(length(new_pkgs)) install.packages(new_pkgs, Ncpus=parallel::detectCores())

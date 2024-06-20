#!/usr/bin/env Rscript

# Script that installs additional packages from Github
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Packages to install
# Regular CRAN packages to install
shared_pkgs <- c(
  "insightsengineering/nesttemplate",
  "openpharma/staged.dependencies@*release",
  "openpharma/roxylint",
  "openpharma/roxytypes"
)

gh_pkgs <- list(
  rstudio = shared_pkgs,
  `rstudio-local` = shared_pkgs,
  `gcc13` = shared_pkgs,
  `gcc14` = shared_pkgs,
  `atlas` = shared_pkgs,
  `valgrind` = shared_pkgs,
  `intel` = shared_pkgs,
  `nosuggests` = shared_pkgs,
  `mkl` = shared_pkgs
)

# Get diff of installed and uninstalled packages for
# idempotent package installation
new_pkgs <- gh_pkgs[[distribution]][
  !(gh_pkgs[[distribution]] %in% installed.packages()[, "Package"])
]

# Install only uninstalled packages
if (length(new_pkgs)) {
  devtools::install_github(
    new_pkgs,
    upgrade = "never"
  )
}

#!/usr/bin/env Rscript

# Script that installs additional packages from Github
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Packages to install
gh_pkgs <- list(
  rstudio = c(
    "tlverse/sl3@v1.4.4",
    "insightsengineering/nesttemplate",
    "openpharma/staged.dependencies@*release"
  ),
  `rstudio-local` = c(
    "tlverse/sl3@v1.4.4",
    "insightsengineering/nesttemplate",
    "openpharma/staged.dependencies@*release"
  )
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

#!/usr/bin/env Rscript

# Script that installs additional packages from Github
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Packages to install
# Regular CRAN packages to install
shared_pkgs <- c(
  "tlverse/sl3@v1.4.4",
  "insightsengineering/nesttemplate",
  "openpharma/staged.dependencies@*release"
)

gh_pkgs <- list(
  rstudio = shared_pkgs,
  `rstudio-local` = shared_pkgs,
  `debian-clang-devel` = shared_pkgs,
  `debian-gcc-devel` = shared_pkgs,
  `fedora-clang-devel` = shared_pkgs,
  `fedora-gcc-devel` = shared_pkgs,
  `debian-gcc-patched` = shared_pkgs,
  `debian-gcc-release` = shared_pkgs
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

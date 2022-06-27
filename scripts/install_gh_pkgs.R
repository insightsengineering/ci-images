#!/usr/bin/env Rscript

# Script that installs additional packages from Github
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# NEST packages to be installed
nest_release_date <- "2022_06_09" # Can be *release to get latest releases
ie_nest_packages <- c(
  "scda.2021",
  "scda.2022",
  "formatters",
  "hermes",
  "teal.logger",
  "scda",
  "goshawk",
  "teal.data",
  "teal.reporter",
  "teal.widgets",
  "tern",
  "teal.code",
  "teal.slice",
  "osprey",
  "tern.mmrm",
  "teal.transform",
  "teal",
  "teal.goshawk",
  "teal.modules.clinical",
  "teal.modules.general",
  "teal.modules.hermes",
  "teal.osprey"
)
roche_nest_packages <- c(
  "rtables"
)
all_nest_packages <- c(
  paste0(
    "Roche/", roche_nest_packages, "@", nest_release_date
  ),
  paste0(
    "insightsengineering/", ie_nest_packages, "@", nest_release_date
  )
)

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
    "openpharma/staged.dependencies@*release",
    all_nest_packages
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

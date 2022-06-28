#!/usr/bin/env Rscript

# Script that installs R packages from alternate sources.
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# NEST packages to be installed
nest_release_date <- "2022_06_09"
nest_packages <- c(
  "scda.2021",
  "scda.2022",
  "formatters",
  "rtables",
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

# List for packages to be installed in a given distribution
other_pkgs <- list(
    rstudio = c(),
    `rstudio-local` = c(
        nest_packages
    )
)

# Get diff of installed and uninstalled packages for
# idempotent package installation
new_pkgs <- other_pkgs[[distribution]][
  !(other_pkgs[[distribution]] %in% installed.packages()[, "Package"])
]

# Install only uninstalled packages
if (length(new_pkgs)) {
  install.packages(
    new_pkgs,
    repos = c(
      paste0(
        "https://insightsengineering.github.io/depository/",
        nest_release_date
      ),
      "https://cloud.r-project.org/"
    ),
    Ncpus = parallel::detectCores(),
    ask = FALSE,
    upgrade = "never"
  )
}

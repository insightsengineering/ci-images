#!/usr/bin/env Rscript

# Script that installs R packages from alternate sources.
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Pharmaverse packages to be installed
pharmaverse_packages <- c(
  "goshawk",
  "teal.goshawk",
  "osprey",
  "teal.osprey",
  "tern.mmrm",
  "teal.modules.hermes",
  "tern.rbmi"
)

# Statistics packages
stat_pkgs <- c(
  "cmdstanr"
)

# List for packages to be installed in a given distribution
other_pkgs <- list(
  rstudio = c(
    stat_pkgs
  ),
  `rstudio-local` = c(
    pharmaverse_packages,
    stat_pkgs
  ),
  `gcc13` = c(stat_pkgs),
  `gcc14` = c(stat_pkgs),
  `atlas` = c(stat_pkgs),
  `valgrind` = c(stat_pkgs),
  `intel` = c(stat_pkgs),
  `nosuggests` = c(stat_pkgs),
  `mkl` = c(stat_pkgs)
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
      "https://insightsengineering.r-universe.dev",
      "https://cloud.r-project.org/",
      "https://mc-stan.org/r-packages/"
    ),
    Ncpus = parallel::detectCores(),
    ask = FALSE,
    upgrade = "never"
  )
}

# Install cmdstan
cmdstanr::install_cmdstan(cores = parallel::detectCores())

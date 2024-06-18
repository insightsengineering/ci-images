#!/usr/bin/env Rscript

# Script that installs BioC packages for a given
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Shared BioC packages to install
shared_pkgs <- c(
  "Biobase",
  "BiocCheck",
  "BiocGenerics",
  "BiocStyle",
  "Bioconductor/BiocBaseUtils",
  "ComplexHeatmap",
  "DESeq2",
  "GenomicRanges",
  "Gviz",
  "MultiAssayExperiment",
  "Rhtslib",
  "S4Vectors",
  "SummarizedExperiment",
  "biomaRt",
  "edgeR",
  "limma",
  "hermes"
)

# Per distro BioC packages to install
bioc_pkgs <- list(
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
new_pkgs <- bioc_pkgs[[distribution]][
  !(bioc_pkgs[[distribution]] %in% installed.packages()[, "Package"])
]

install.packages(
  "cmdstanr",
  repos='https://stan-dev.r-universe.dev'
)

cmdstanr::install_cmdstan()

# Install only uninstalled packages
if (length(new_pkgs)) {
  BiocManager::install(new_pkgs,
    Ncpus = parallel::detectCores(),
    force = TRUE,
    ask = FALSE,
    update = FALSE
  )
}

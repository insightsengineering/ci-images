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
new_pkgs <- bioc_pkgs[[distribution]][
  !(bioc_pkgs[[distribution]] %in% installed.packages()[, "Package"])
]

# cmdstanr is available on r-universe.dev.
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

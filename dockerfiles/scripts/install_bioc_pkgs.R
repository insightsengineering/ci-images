#!/usr/bin/env Rscript

# Script that installs BioC packages for a given
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Bioc packages to install
bioc_pkgs <- list(
    rstudio = c(
        'MultiAssayExperiment',
        'SummarizedExperiment',
        'ComplexHeatmap',
        'DESeq2',
        'edgeR',
        'S4Vectors',
        'limma',
        'biomaRt',
        'Biobase',
        'BiocGenerics',
        'GenomicRanges'
    ),
    tidyverse = c(),
    `r-ver` = c(),
    verse = c()
)

# Get diff of installed and uninstalled packages for
# idempotent package installation
new_pkgs <- bioc_pkgs[[distribution]][!(bioc_pkgs[[distribution]] %in% installed.packages()[,"Package"])]

# Install only uninstalled packages
if(length(new_pkgs)) BiocManager::install(new_pkgs, Ncpus=parallel::detectCores(), upgrade = "never")

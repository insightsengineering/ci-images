#!/usr/bin/env Rscript

# Script that installs BioC Manager
# Takes in the BioC Release Version as the first argument.
args <- commandArgs(trailing = TRUE)
bioc_version <- args[1]

# Install Bioc Installer
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = bioc_version, Ncpus = parallel::detectCores())

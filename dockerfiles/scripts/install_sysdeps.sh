#!/usr/bin/env bash

set -e

# Script to install additional system dependencies
# Takes in the distribution as the first argument
distribution="$1"

# Hash map of system deps
declare -A pkgs_to_install

# Deps for r-ver
pkgs_to_install["r-ver"]="git qpdf"

# Deps for rstudio
pkgs_to_install["rstudio"]="qpdf libcairo2-dev libxml2 libxt-dev"

# Deps for tidyverse
pkgs_to_install["tidyverse"]="qpdf"

# Set env vars
export DEBIAN_FRONTEND=noninteractive

# Update
apt-get update -y

# Install packages
apt-get install -q -y ${pkgs_to_install["${distribution}"]}

# Install security patches
apt-get upgrade -y
apt-get install -y unattended-upgrades
unattended-upgrade -v

# Clean up
apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*

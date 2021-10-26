#!/usr/bin/env bash

set -e

# Script to install additional system dependencies
# Takes in the distribution as the first argument
distribution="$1"

# Hash map of system deps
declare -A pkgs_to_install

# Deps for r-ver
pkgs_to_install["r-ver"]="git qpdf unattended-upgrades"

# Deps for rstudio
pkgs_to_install["rstudio"]="libxml2-dev pandoc libicu-dev libgit2-dev zlib1g-dev libfontconfig1-dev libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libfribidi-dev libharfbuzz-dev imagemagick libmagick++-dev unixodbc-dev curl qpdf unattended-upgrades ssh libmysqlclient-dev libsodium-dev"

# Deps for rstudio-local
pkgs_to_install["rstudio-local"]="libxml2-dev pandoc libicu-dev libgit2-dev zlib1g-dev libfontconfig1-dev libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libfribidi-dev libharfbuzz-dev imagemagick libmagick++-dev unixodbc-dev curl qpdf unattended-upgrades less ssh libmysqlclient-dev libsodium-dev"

# Deps for tidyverse
pkgs_to_install["tidyverse"]="pandoc libjpeg-dev libtiff-dev libfribidi-dev libharfbuzz-dev imagemagick libmagick++-dev curl qpdf unattended-upgrades"

# Deps for verse
pkgs_to_install["verse"]="pandoc libjpeg-dev imagemagick unattended-upgrades"

# Set env vars
export DEBIAN_FRONTEND=noninteractive

# Update
apt-get update -y

# Install packages
# expected word splitting - list of packages require it
# shellcheck disable=SC2086
apt-get install -q -y ${pkgs_to_install["${distribution}"]}

# Install security patches
unattended-upgrade -v

# Clean up
apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*

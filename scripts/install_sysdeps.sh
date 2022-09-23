#!/usr/bin/env bash

set -e

# Script to install additional system dependencies
# Takes in the distribution as the first argument
distribution="$1"

# Hash map of system deps
declare -A pkgs_to_install

# Shared deps
shared_deps="\
libxml2-dev \
pandoc \
libicu-dev \
libgit2-dev \
zlib1g-dev \
libfontconfig1-dev \
libfreetype6-dev \
libjpeg-dev \
libpng-dev \
libtiff-dev \
libfribidi-dev \
libharfbuzz-dev \
imagemagick \
libmagick++-dev \
unixodbc-dev \
curl \
qpdf \
unattended-upgrades \
ssh \
libmysqlclient-dev \
libsodium-dev \
default-jdk \
cmake \
graphviz \
libaio1 \
alien \
"

# Deps specific to rstudio
pkgs_to_install["rstudio"]="${shared_deps} \
jags \
"

# Deps specific to rstudio-local
pkgs_to_install["rstudio-local"]="${shared_deps} \
vim \
xdg-utils \
python3-pip \
less \
"

# Set env vars
export DEBIAN_FRONTEND=noninteractive

# Update
apt-get update -y

# Install packages
# expected word splitting - list of packages require it
# shellcheck disable=SC2086
apt-get install -q -y ${pkgs_to_install["${distribution}"]}

# Add Chrome repo and install Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
apt-get update -y
apt-get install -q -y google-chrome-stable

# Install quarto
ARCH=$(dpkg --print-architecture)
QUARTO_DL_URL=$(wget -qO- https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest | grep -oP "(?<=\"browser_download_url\":\s\")https.*${ARCH}\.deb")
wget -q "${QUARTO_DL_URL}" -O quarto-"${ARCH}".deb
dpkg -i quarto-"${ARCH}".deb
quarto check install

# Install security patches
unattended-upgrade -v

# Clean up
apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/* quarto-"${ARCH}".deb

# Purge and recreate locales
locale-gen --purge en_US.UTF-8
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale

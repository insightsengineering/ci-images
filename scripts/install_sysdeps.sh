#!/usr/bin/env bash

set -e

# Script to install additional system dependencies
# Takes in the distribution as the first argument
distribution="$1"

# Hash map of system deps
declare -A pkgs_to_install_debian
declare -A pkgs_to_install_fedora

# Shared deps for debian
shared_deps_debian="\
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
libxss1 \
"

# Shared deps for fedora
shared_deps_fedora="\
libxml2-devel \
pandoc \
libicu-devel \
libgit2-devel \
zlib-devel \
libfonts \
freetype-devel \
libjpeg-turbo-devel \
libpng-devel \
libtiff-devel \
fribidi-devel \
harfbuzz-devel \
ImageMagick \
ImageMagick-c++-devel\
unixODBC-devel \
libcurl-devel \
qpdf \
dnf-automatic \
libssh-devel \
openssh \
mariadb-devel \
libsodium-devel \
java-11-openjdk \
cmake \
graphviz \
libxslt-devel \
chromium-headless \
"

# Deps specific on the rstudio image
pkgs_to_install_debian["rstudio"]="${shared_deps_debian} \
jags \
"

# Deps specific on the rstudio-local image
pkgs_to_install_debian["rstudio-local"]="${shared_deps_debian} \
vim \
xdg-utils \
python3-pip \
less \
"

# Deps specific on the debian-clang-devel image
pkgs_to_install_debian["debian-clang-devel"]="${shared_deps_debian} \
jags \
"

# Deps specific on the debian-gcc-devel image
pkgs_to_install_debian["debian-gcc-devel"]="${shared_deps_debian} \
jags \
"

# Deps specific on the debian-gcc-patched image
pkgs_to_install_debian["debian-gcc-patched"]="${shared_deps_debian} \
jags \
"

# Deps specific on the debian-gcc-release image
pkgs_to_install_debian["debian-gcc-release"]="${shared_deps_debian} \
jags \
"

# Deps specific on the fedora-gcc-devel image
pkgs_to_install_fedora["fedora-gcc-devel"]="${shared_deps_fedora}"

# Deps specific on the fedora-clang-devel image
pkgs_to_install_fedora["fedora-clang-devel"]="${shared_deps_fedora}"

# Perform installations for debian distros
if [[ "$distribution" =~ ^rstudio.*|^debian.* ]]
then {
    # Set env vars
    export DEBIAN_FRONTEND=noninteractive
    export ACCEPT_EULA=Y

    # Update
    apt-get update -y

    # Install packages
    # expected word splitting - list of packages require it
    # shellcheck disable=SC2086
    apt-get install -q -y ${pkgs_to_install_debian["${distribution}"]}

    # Add Chrome repo and install Chrome
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list
    apt-get update -y
    apt-get install -q -y google-chrome-stable
    rm /etc/apt/sources.list.d/google.list

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

    # Purge and recreate locales]
    if [[ "$distribution" =~ ^rstudio.* ]]
    then {
        locale-gen --purge en_US.UTF-8
        echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
    }
    fi
}
fi

if [[ "$distribution" =~ ^fedora.* ]]
then {
    # Update
    dnf update -y

    # Ugrade
    dnf upgrade --refresh -y

    # Install packages
    # expected word splitting - list of packages require it
    # shellcheck disable=SC2086
    dnf install -q -y ${pkgs_to_install_fedora["${distribution}"]}

    # Clean up
    dnf autoremove -y
    dnf clean all
}
fi

# Symlink R if it's in a non-default path
if [ -d "/opt/R-devel/bin/" ]
then {
    ln -s /opt/R-devel/bin/R /usr/bin/R
    ln -s /opt/R-devel/bin/Rscript /usr/bin/Rscript
}
fi

if [ -d "/opt/R-patched/bin/" ]
then {
    ln -s /opt/R-patched/bin/R /usr/bin/R
    ln -s /opt/R-patched/bin/Rscript /usr/bin/Rscript
}
fi

# Set default initializer if unavailable
if [ ! -f /init ]
then {
    echo "sh" > /init
    chmod +x /init
}
fi

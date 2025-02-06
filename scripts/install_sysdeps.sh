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
gnupg2 \
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
libmariadb-dev \
libsodium-dev \
default-jdk \
cmake \
graphviz \
alien \
libxss1 \
git \
libssl-dev \
wget \
librsvg2-dev \
libudunits2-dev \
libv8-dev \
libpq-dev \
tidy \
libglpk-dev \
libarchive-dev \
libssh-dev \
libcurl4-openssl-dev \
"

# Shared deps for fedora
shared_deps_fedora="\
libxml2-devel \
gnupg2 \
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
ImageMagick-c++-devel \
unixODBC-devel \
libcurl-devel \
qpdf \
dnf-automatic \
libssh-devel \
openssh \
mariadb-devel \
libsodium-devel \
java-latest-openjdk-devel \
java-latest-openjdk \
cmake \
graphviz \
libxslt-devel \
chromium-headless \
openssl-devel \
git-all \
wget \
lapack-devel \
librsvg2-devel \
lbzip2 \
udunits2-devel \
v8-devel \
tidy \
glpk-devel \
libarchive-devel \
libssh-devel \
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
nano \
"

# Deps specific to the Fedora-based rhub image.
pkgs_to_install_fedora["gcc13"]="${shared_deps_fedora}"
pkgs_to_install_fedora["gcc14"]="${shared_deps_fedora}"
pkgs_to_install_fedora["atlas"]="${shared_deps_fedora}"
pkgs_to_install_fedora["valgrind"]="${shared_deps_fedora}"
pkgs_to_install_fedora["intel"]="${shared_deps_fedora}"
pkgs_to_install_fedora["nosuggests"]="${shared_deps_fedora}"
pkgs_to_install_fedora["mkl"]="${shared_deps_fedora}"

# Perform installations for debian distros
if [[ "$distribution" =~ ^rstudio.* ]]
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
    apt-get install -q -y google-chrome-stable || \
        echo "❌ Unable to install Chrome, likely due to lack of arm64 support"
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

        # Also override the default repository used in the rstudio images
        echo "options(repos = c(CRAN = 'https://cloud.r-project.org'))" > /usr/local/lib/R/etc/Rprofile.site
        echo "Sys.setenv(OPENSSL_CONF = '/etc/ssl')" >> /usr/local/lib/R/etc/Rprofile.site
    }
    fi
}
fi

if [[ "$distribution" =~ ^gcc.*|^atlas$|^valgrind$|^intel$|^nosuggests$|^mkl$ ]]
then {
    # Update
    dnf update -y

    # Upgrade
    dnf upgrade --refresh -y

    # Install packages
    # expected word splitting - list of packages require it
    # shellcheck disable=SC2086
    dnf install -q -y ${pkgs_to_install_fedora["${distribution}"]}

    # Install JAGS
    JAGS_VERSION="4.3.1"
    wget -q -O JAGS.tar.gz "https://cytranet.dl.sourceforge.net/project/mcmc-jags/JAGS/${JAGS_VERSION::1}.x/Source/JAGS-${JAGS_VERSION}.tar.gz"
    tar xzf JAGS.tar.gz
    pushd JAGS-${JAGS_VERSION}
    ./configure
    make -j8
    make install
    popd

    # Clean up
    dnf autoremove -y
    dnf clean all
    rm -rf JAGS*

    # Set Java
    OPENJDK_17=$(alternatives --list | grep javac | awk '{print $NF}' | xargs dirname)
    alternatives --set java "${OPENJDK_17}"/java
}
fi

# Symlink R if it's in a non-default path
for non_default_path in devel patched
do {
    if [ -d "/opt/R-${non_default_path}/bin/" ]
    then {
        ln -s /opt/R-${non_default_path}/bin/R /usr/bin/R
        ln -s /opt/R-${non_default_path}/bin/Rscript /usr/bin/Rscript
        # Also set default CRAN repo
        RPROFILE_DIRNAME=$(find /opt/R-${non_default_path} -type d -name "etc")
        echo "options(repos=c(CRAN='https://cloud.r-project.org'))" > "${RPROFILE_DIRNAME}"/Rprofile.site
    }
    fi
}
done

# Set default initializer if unavailable
if [ ! -f /init ]
then {
    echo "sh" > /init
    chmod +x /init
}
fi

# Reconfigure Java
R CMD javareconf

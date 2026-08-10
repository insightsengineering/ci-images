# Build arguments
ARG ORIGIN=rocker
ARG ORIGIN_DISTRIBUTION=rstudio
ARG R_VERSION=4.6.1

# Fetch base image
FROM ${ORIGIN}/${ORIGIN_DISTRIBUTION}:${R_VERSION}

# Reset args in build context
ARG DISTRIBUTION=rstudio-local
ARG BIOC_VERSION=3.23

# Set image metadata
LABEL org.opencontainers.image.licenses="GPL-2.0-or-later" \
    org.opencontainers.image.source="https://github.com/insightsengineering/ci-images" \
    org.opencontainers.image.vendor="Insights Engineering" \
    org.opencontainers.image.authors="Insights Engineering <insightsengineering@example.com>"

# Set working directory
WORKDIR /workspace

# Copy installation scripts
COPY --chmod=0755 [\
    "scripts/install_sysdeps.sh", \
    "scripts/install_cran_pkgs.R", \
    "scripts/install_bioc.R", \
    "scripts/install_bioc_pkgs.R", \
    "scripts/install_gh_pkgs.R", \
    "scripts/install_other_pkgs.R", \
    "scripts/install_pip_pkgs.py", \
    "scripts/test_installations.sh", \
    "./"\
]

# In order to have predictable results from the TinyTeX installer, pin a single
# TeX Live repository. It must be a single host rather than the mirror.ctan.org
# redirector: the repository is contacted several times during the install (base
# install, `tlmgr option repository`, then `tlmgr install`), and the redirector
# hands out differently-synced mirrors per request, which causes tlmgr cross
# release errors.
# We use TinyTeX's own tlnet mirror, which is the installer's default, is
# kept in sync for TinyTeX specifically, and is CDN-backed rather than a
# single host.
# This variable is used by:
# https://tinytex.yihui.org/install-base.sh
# which is in turn used by:
# https://raw.githubusercontent.com/yihui/tinytex/master/tools/install-unx.sh.
ENV CTAN_REPO https://tlnet.yihui.org

# Install sysdeps
RUN ./install_sysdeps.sh ${DISTRIBUTION}

# Install R packages
RUN ./install_cran_pkgs.R ${DISTRIBUTION} && \
    ./install_bioc.R ${BIOC_VERSION} && \
    ./install_bioc_pkgs.R ${DISTRIBUTION} && \
    ./install_gh_pkgs.R ${DISTRIBUTION} && \
    ./install_other_pkgs.R ${DISTRIBUTION} && \
    ./install_pip_pkgs.py ${DISTRIBUTION} && \
    ./test_installations.sh && \
    rm -f install_sysdeps.sh \
        install_cran_pkgs.R \
        install_bioc.R \
        install_bioc_pkgs.R \
        install_gh_pkgs.R \
        install_other_pkgs.R \
        install_pip_pkgs.py \
        test_installations.sh

# Run RStudio
CMD ["/init"]

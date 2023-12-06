# Build arguments
ARG ORIGIN=rocker
ARG ORIGIN_DISTRIBUTION=rstudio
ARG R_VERSION=4.3.2

# Fetch base image
FROM ${ORIGIN}/${ORIGIN_DISTRIBUTION}:${R_VERSION}

# Reset args in build context
ARG DISTRIBUTION=rstudio-local
ARG BIOC_VERSION=3.18

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
    "./"\
]

# Install sysdeps
RUN ./install_sysdeps.sh ${DISTRIBUTION}

RUN R --version
RUN java -version

# Install R packages
# RUN ./install_cran_pkgs.R ${DISTRIBUTION} && \
#     ./install_bioc.R ${BIOC_VERSION} && \
#     ./install_bioc_pkgs.R ${DISTRIBUTION} && \
#     ./install_gh_pkgs.R ${DISTRIBUTION} && \
#     ./install_other_pkgs.R ${DISTRIBUTION} && \
#     ./install_pip_pkgs.py ${DISTRIBUTION} && \
#     rm -f install_sysdeps.sh \
#         install_cran_pkgs.R \
#         install_bioc.R \
#         install_bioc_pkgs.R \
#         install_gh_pkgs.R \
#         install_other_pkgs.R \
#         install_pip_pkgs.py

# Prevent pushing of the image without pdflatex installed.
# RUN pdflatex --version

# Run RStudio
CMD ["/init"]

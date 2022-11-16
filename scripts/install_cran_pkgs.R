#!/usr/bin/env Rscript

# Script that installs additional packages from CRAN
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Set official mirror for CRAN
options(repos = c("https://cloud.r-project.org/"))

# Packages that are already in the image
# but must be reinstalled to the latest versions
reinstall_with_newer_version <- c(
  "Matrix"
)

# Shared packages that must be installed from source
# for compatability purposes
shared_pkgs_install_from_src <- c(
  "TMB"
)

# CRAN packages to install from source, per distro
cran_pkgs_from_src <- list(
  rstudio = shared_pkgs_install_from_src,
  `rstudio-local` = shared_pkgs_install_from_src
)

# Regular CRAN packages to install
shared_pkgs <- c(
  "callr",
  "devtools",
  "lintr",
  "magrittr",
  "spelling",
  "testthat",
  "withr",
  "glue",
  "dplyr",
  "magrittr",
  "rlang",
  "tibble",
  "knitr",
  "ggplot2",
  "gridExtra",
  "scales",
  "htmltools",
  "tidyr",
  "xml2",
  "rmarkdown",
  "optimx",
  "assertthat",
  "gtable",
  "purrr",
  "forcats",
  "car",
  "emmeans",
  "labeling",
  "lme4",
  "lmerTest",
  "dfoptim",
  "viridisLite",
  "broom",
  "tidyselect",
  "shiny",
  "digest",
  "lifecycle",
  "R6",
  "shinyjs",
  "shinyWidgets",
  "yaml",
  "covr",
  "pkgdown",
  "DBI",
  "httr",
  "nomnoml",
  "odbc",
  "readr",
  "crayon",
  "styler",
  "rvest",
  "shinytest",
  "ggmosaic",
  "colourpicker",
  "DT",
  "ggExtra",
  "ggpmisc",
  "jsonlite",
  "sparkline",
  "vistime",
  "ggrepel",
  "kableExtra",
  "cowplot",
  "mcr",
  "DescTools",
  "fs",
  "gh",
  "png",
  "rvest",
  "webshot",
  "circlize",
  "Rdpack",
  "remotes",
  "pkgdown",
  "ggfortify",
  "vroom",
  "tzdb",
  "Rcpp",
  "cli",
  "stringi",
  "git2r",
  "rcmdcheck",
  "tinytest",
  "igraph",
  "dm",
  "glmmTMB",
  "rstan",
  "rstantools",
  "rtables",
  "pillar",
  "xfun",
  "globals",
  "checkmate",
  "nortest",
  "statmod",
  "gert",
  "EnvStats",
  "goftest",
  "GGally",
  "mockery",
  "renv",
  "oysteR",
  "markdown",
  "tinytex",
  "shinyTree",
  "uuid",
  "gdtools",
  "officer",
  "flextable",
  "shinyRadioMatrix",
  "reticulate",
  "here",
  "vdiffr",
  "logger",
  "mockery",
  "rJava",
  "RJDBC",
  "pbkrtest",
  "nloptr",
  "rjags",
  "rsvg",
  "ggiraph",
  "rbmi",
  "ggnewscale",
  "readxl",
  "bookdown",
  "patchwork",
  "DiagrammeR",
  "binom",
  "ggpubr",
  "maditr",
  "diffdf",
  "survminer",
  "quarto",
  "shinytest2",
  "geeasy",
  "geepack",
  "GenSA",
  "mmrm"
)

cran_pkgs <- list(
  rstudio = shared_pkgs,
  `rstudio-local` = c(
    shared_pkgs,
    "diffviewer",
    "languageserver"
  ),
  `debian-clang-devel` = shared_pkgs,
  `debian-gcc-devel` = shared_pkgs,
  `fedora-clang-devel` = shared_pkgs[! shared_pkgs %in% c("rjags")],
  `fedora-gcc-devel` = shared_pkgs[! shared_pkgs %in% c("rjags")],
  `debian-gcc-patched` = shared_pkgs,
  `debian-gcc-release` = shared_pkgs
)

# Re-install packages with newer versions
install.packages(reinstall_with_newer_version,
  type = "source",
  Ncpus = parallel::detectCores()
)

# Get diff of installed and uninstalled packages for
# idempotent package installation
new_pkgs_from_src <- cran_pkgs_from_src[[distribution]][
  !(cran_pkgs_from_src[[distribution]] %in% installed.packages()[, "Package"])
]

# Install "source only" packages from source
if (length(new_pkgs_from_src)) {
  install.packages(new_pkgs_from_src,
    type = "source",
    Ncpus = parallel::detectCores()
  )
}

# Install rjags with special params for fedora distros
if (startsWith(distribution, "fedora")) {
  install.packages("rjags",
    type = "source",
    configure.args = "--enable-rpath",
    Ncpus = parallel::detectCores()
  )
}

# Get diff of installed and uninstalled packages for
# idempotent package installation
new_pkgs <- cran_pkgs[[distribution]][
  !(cran_pkgs[[distribution]] %in% installed.packages()[, "Package"])
]

# Install all other packages, only if they are uninstalled on the image
if (length(new_pkgs)) {
  install.packages(new_pkgs,
    Ncpus = parallel::detectCores()
  )
}

# Conditionally install phantonJS
if (require("shinytest")) {
  shinytest::installDependencies()
  file.copy(shinytest:::find_phantom(), "/usr/local/bin/phantomjs")
}

# Conditionally install TinyTex
if (require("tinytex")) {
  # nolint start
  # See point 5 in
  # https://github.com/rbind/yihui/blob/master/content/tinytex/faq.md
  tinytex_installer <- '
wget -qO- "https://raw.githubusercontent.com/yihui/tinytex/master/tools/install-unx.sh" | sh -s - --admin --no-path
mv ~/.TinyTeX /opt/TinyTeX
/opt/TinyTeX/bin/*/tlmgr path add
tlmgr install makeindex metafont mfware inconsolata tex ae parskip listings xcolor epstopdf-pkg pdftexcmds kvoptions texlive-scripts grfext soul todonotes koma-script subfig bookmark babel-english caption
tlmgr path add
'
  # nolint end
  system(tinytex_installer)
  tinytex::r_texmf()
  permission_update <- '
chown -R root:staff /opt/TinyTeX
chmod -R g+w /opt/TinyTeX
chmod -R g+wx /opt/TinyTeX/bin
export PATH=/opt/TinyTeX/bin/x86_64-linux:${PATH}
echo "PATH=${PATH}" >> ${R_HOME}/etc/Renviron
'
  system(permission_update)
}

# Update all packages
tryCatch(
  expr = {
    update.packages(ask = FALSE)
  },
  error = function(e) {
    print(e)
  }
)

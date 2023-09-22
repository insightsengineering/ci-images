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
  "admiral",
  "admiraldev",
  "admiral.test",
  "admiralonco",
  "admiralophtha",
  "callr",
  "DBI",
  "DT",
  "DescTools",
  "DiagrammeR",
  "EnvStats",
  "GGally",
  "GenSA",
  "R6",
  "RJDBC",
  "Rcpp",
  "Rdpack",
  "V8",
  "assertthat",
  "bigD",
  "binom",
  "bookdown",
  "broom",
  "car",
  "checkmate",
  "circlize",
  "cli",
  "colourpicker",
  "covr",
  "cowplot",
  "crayon",
  "devtools",
  "dfoptim",
  "diffdf",
  "digest",
  "dm",
  "dplyr",
  "emmeans",
  "flextable",
  "forcats",
  "formatters",
  "fs",
  "gdtools",
  "geeasy",
  "geepack",
  "gert",
  "ggExtra",
  "ggfortify",
  "ggiraph",
  "ggmosaic",
  "ggnewscale",
  "ggplot2",
  "ggpmisc",
  "ggpubr",
  "ggrepel",
  "gh",
  "git2r",
  "glmmTMB",
  "globals",
  "glue",
  "goftest",
  "gridExtra",
  "gt",
  "gtable",
  "here",
  "htmltools",
  "httr",
  "huxtable",
  "igraph",
  "jsonlite",
  "juicyjuice",
  "kableExtra",
  "knitr",
  "labeling",
  "lifecycle",
  "lintr",
  "lme4",
  "lmerTest",
  "logger",
  "maditr",
  "magick",
  "magrittr",
  "markdown",
  "mcr",
  "mmrm",
  "mockery",
  "nloptr",
  "nomnoml",
  "nortest",
  "odbc",
  "officer",
  "optimx",
  "oysteR",
  "patchwork",
  "pbkrtest",
  "pillar",
  "pkgdown",
  "png",
  "purrr",
  "quarto",
  "r2rtf",
  "rJava",
  "rbmi",
  "rcmdcheck",
  "readr",
  "readxl",
  "remotes",
  "renv",
  "reticulate",
  "rjags",
  "rlang",
  "rlistings",
  "rmarkdown",
  "rstan",
  "rstantools",
  "rsvg",
  "rtables",
  "rvest",
  "scales",
  "shiny",
  "shinyRadioMatrix",
  "shinyTree",
  "shinyWidgets",
  "shinyjs",
  "shinytest",
  "shinytest2",
  "shinyvalidate",
  "sparkline",
  "spelling",
  "statmod",
  "stringi",
  "styler",
  "survminer",
  "testthat",
  "tibble",
  "tidyr",
  "tidyselect",
  "tinytest",
  "tinytex",
  "tzdb",
  "uuid",
  "vdiffr",
  "viridisLite",
  "vistime",
  "vroom",
  "webshot",
  "withr",
  "xfun",
  "xml2",
  "yaml"
)

install.packages("https://cran.r-project.org/src/contrib/Archive/imputeMissings/imputeMissings_0.0.3.tar.gz")

cran_pkgs <- list(
  rstudio = shared_pkgs,
  `rstudio-local` = c(
    shared_pkgs,
    "diffviewer",
    "languageserver"
  ),
  `debian-clang-devel` = shared_pkgs,
  `debian-gcc-devel` = shared_pkgs,
  `fedora-clang-devel` = shared_pkgs[!shared_pkgs %in% c("rjags")],
  `fedora-gcc-devel` = shared_pkgs[!shared_pkgs %in% c("rjags")],
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

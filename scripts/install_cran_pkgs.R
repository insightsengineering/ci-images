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

# Pharmaverse R packages
pharmaverse_pkgs <- c(
  "admiral",
  "admiral.test",
  "admiraldev",
  "admiralonco",
  "admiralophtha",
  "formatters",
  "rtables",
  "rlistings",
  "nestcolor",
  "teal",
  "teal.code",
  "teal.data",
  "teal.logger",
  "teal.modules.clinical",
  "teal.modules.general",
  "teal.reporter",
  "teal.slice",
  "teal.transform",
  "teal.widgets",
  "tern",
  "mmrm"
)

# Regular CRAN packages to install
shared_pkgs <- c(
  "assertthat",
  "bayesplot",
  "BayesPPD",
  "bbmle",
  "bdsmatrix",
  "bigD",
  "binom",
  "bookdown",
  "broom",
  "broom.helpers",
  "callr",
  "car",
  "checkmate",
  "chk",
  "circlize",
  "cli",
  "cobalt",
  "colourpicker",
  "covr",
  "cowplot",
  "crayon",
  "DBI",
  "DescTools",
  "deSolve",
  "devtools",
  "dfoptim",
  "DiagrammeR",
  "diffdf",
  "digest",
  "dm",
  "dplyr",
  "DT",
  "emmeans",
  "EnvStats",
  "fastGHQuad",
  "flexsurv",
  "flextable",
  "forcats",
  "formatters",
  "fs",
  "gbm",
  "gdtools",
  "geeasy",
  "geepack",
  "GenSA",
  "gert",
  "GGally",
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
  "gtsummary",
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
  "MatchIt",
  "matrixcalc",
  "mcr",
  "mockery",
  "mstate",
  "muhaz",
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
  "R6",
  "randomForest",
  "rbmi",
  "rcmdcheck",
  "Rcpp",
  "RcppNumerical",
  "RcppProgress",
  "Rdpack",
  "readr",
  "readxl",
  "remotes",
  "renv",
  "reticulate",
  "rjags",
  "rJava",
  "RJDBC",
  "rlang",
  "rmarkdown",
  "rstan",
  "rstantools",
  "rstpm2",
  "rsvg",
  "rvest",
  "scales",
  "shiny",
  "shinyjs",
  "shinyRadioMatrix",
  "shinytest",
  "shinytest2",
  "shinyTree",
  "shinyvalidate",
  "shinyWidgets",
  "simsurv",
  "sparkline",
  "spelling",
  "statmod",
  "stringi",
  "styler",
  "survminer",
  "table1",
  "testthat",
  "tibble",
  "tidyr",
  "tidyselect",
  "tinytest",
  "tinytex",
  "tzdb",
  "uuid",
  "V8",
  "vdiffr",
  "viridisLite",
  "vistime",
  "vroom",
  "webshot",
  "WeightIt",
  "withr",
  "xfun",
  "xml2",
  "yaml"
)

# Local development helper packages
local_dev_packages <- c(
  "diffviewer",
  "languageserver"
)

# Collate all packages
cran_pkgs <- list(
  rstudio = c(
    shared_pkgs,
    pharmaverse_pkgs
  ),
  `rstudio-local` = c(
    shared_pkgs,
    pharmaverse_pkgs,
    local_dev_packages
  ),
  `debian-clang-devel` = shared_pkgs,
  `debian-gcc-devel` = shared_pkgs,
  `fedora-clang-devel` = shared_pkgs[!shared_pkgs %in% c("rjags")],
  `fedora-gcc-devel` = shared_pkgs[!shared_pkgs %in% c("rjags")],
  `debian-gcc-patched` = shared_pkgs,
  `debian-gcc-release` = shared_pkgs
)

# Re-install packages with newer versions
install.packages(
  reinstall_with_newer_version,
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
  install.packages(
    new_pkgs_from_src,
    type = "source",
    Ncpus = parallel::detectCores()
  )
}

# Install rjags with special params for fedora distros
if (startsWith(distribution, "fedora")) {
  install.packages(
    "rjags",
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
  tlmgr_packages <- c(
    "makeindex",
    "metafont",
    "mfware",
    "inconsolata",
    "tex",
    "ae",
    "parskip",
    "listings",
    "xcolor",
    "epstopdf-pkg",
    "pdftexcmds",
    "kvoptions",
    "texlive-scripts",
    "grfext",
    "soul",
    "todonotes",
    "koma-script",
    "subfig",
    "bookmark",
    "babel-english",
    "caption"
  )
  # nolint start
  # See point 5 in
  # https://github.com/rbind/yihui/blob/master/content/tinytex/faq.md
  tinytex_installer <- paste0('
wget -qO- "https://raw.githubusercontent.com/yihui/tinytex/master/tools/install-unx.sh" | sh -s - --admin --no-path
mv ~/.TinyTeX /opt/TinyTeX
/opt/TinyTeX/bin/*/tlmgr path add
tlmgr install ', paste(tlmgr_packages, collapse = " "), "
tlmgr path add
")
  # nolint end
  exit_status <- system(tinytex_installer)
  cat("TinyTeX installer exited with code =", exit_status, "\n")
  if (exit_status != 0) {
    quit(status = exit_status)
  }
  tinytex::r_texmf()
  permission_update <- '
chown -R root:staff /opt/TinyTeX
chmod -R g+w /opt/TinyTeX
chmod -R g+wx /opt/TinyTeX/bin
export PATH=/opt/TinyTeX/bin/x86_64-linux:${PATH}
echo "PATH=${PATH}" >> ${R_HOME}/etc/Renviron
'
  exit_status <- system(permission_update)
  cat("TinyTeX permission update exited with code =", exit_status, "\n")
  if (exit_status != 0) {
    quit(status = exit_status)
  }
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

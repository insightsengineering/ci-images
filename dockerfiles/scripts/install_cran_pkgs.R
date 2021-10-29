#!/usr/bin/env Rscript

# Script that installs additional packages from CRAN
# Takes in the distribution as the first argument.
args <- commandArgs(trailing = TRUE)
distribution <- args[1]

# Set official mirror for CRAN
options(repos = c("https://cloud.r-project.org/"))

# CRAN packages to install
cran_pkgs <- list(
  rstudio = c(
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
    "RJDBC"
  ),
  `rstudio-local` = c(
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
    "rtables",
    "pillar",
    "xfun",
    "globals",
    "checkmate",
    "diffviewer",
    "languageserver",
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
    "RJDBC"
  )
)

# Get diff of installed and uninstalled packages for
# idempotent package installation
new_pkgs <- cran_pkgs[[distribution]][
  !(cran_pkgs[[distribution]] %in% installed.packages()[, "Package"])
]

# Install only uninstalled packages
if (length(new_pkgs))
  install.packages(new_pkgs,
                   Ncpus = parallel::detectCores())

# Conditionally install phantonJS
if (require("shinytest")) {
  shinytest::installDependencies()
  file.copy(shinytest:::find_phantom(), "/usr/local/bin/phantomjs")
}

# Conditionally install TinyTex
if (require("tinytex")) {
  # nolint start
  tinytex_installer <- '
wget -qO- "https://raw.githubusercontent.com/yihui/tinytex/master/tools/install-unx.sh" | sh -s - --admin --no-path
mv ~/.TinyTeX /opt/TinyTeX
/opt/TinyTeX/bin/*/tlmgr path add
tlmgr install makeindex metafont mfware inconsolata tex ae parskip listings xcolor epstopdf-pkg pdftexcmds kvoptions texlive-scripts grfext
tlmgr path add
'
  # nolint end
  system(tinytex_installer)
  tinytex::r_texmf()
  permission_update <- '
chown -R root:staff /opt/TinyTeX
chmod -R g+w /opt/TinyTeX
chmod -R g+wx /opt/TinyTeX/bin
export PATH=/opt/TinyTeX/bin:${PATH}
echo "PATH=${PATH}" >> ${R_HOME}/etc/Renviron
'
  system(permission_update)
}

# Update all packages
update.packages(ask = FALSE)
